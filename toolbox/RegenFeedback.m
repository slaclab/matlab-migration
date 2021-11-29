%% Function to keep laser aligned on LRoomFar camera
%  inputs:
%     target_x : x target position in px
%     target_y : y target position in px
%     tol_x    : x alignment tolerance in px
%     tol_y    : y alignment tolerance in px
%
% M.Litos Apr. 11, 2015
%
% Converted to RegenFeedback by B. O'Shea 11/24/2015
% Version 2: Changed the method of center determination to projection and
% gaussian fit (to better match the method from profMon stats).  Re-enabled
% remote shutdown by PV.  Set up step size to be calculated instead of
% fixed.


function [ ] = RegenFeedback( target_x, target_y, tol_x, tol_y )

if nargin<1
    target_x = 665; % px
end
if nargin<2
    target_y = 672; % px
end
if nargin<3
    tol_x = 0; % px
end
if nargin<4
    tol_y = 0; % px
end

% silence the stupid warnings from profmon_grab
lcaPut('PROF:LI20:10:BinX.PROC',1);
lcaPut('PROF:LI20:10:BinY.PROC',1);

% infinite loop!
iter=0;
while true

    % check EPICS PV RegenFeedbackStop (bool)
    if (lcaGet('SIOC:SYS1:ML00:AO700'))
        break;
    end
    
    disp([(sprintf('Feedback loop iteration %.0f',iter))]);
    
    % Since the laser can be a bit jittery, average N_samples shots before
    % moving.
    N_samples = 3;
    beam_position = zeros(N_samples,2);
    
    for i = 1 : N_samples
        % grab LRoomFar profmon image
        LRoomFarPVName = 'PROF:LI20:10';
        prof = profmon_grab(LRoomFarPVName);
        
        % take projections
        px_x = [prof.roiX:prof.roiX+prof.roiXN-1];
        px_y = [prof.roiY:prof.roiY+prof.roiYN-1];
        proj_x = sum(prof.img,1);
        proj_y = sum(prof.img,2)';
        
        [~, q_x] = gauss_fit(px_x,proj_x);
        [~, q_y] = gauss_fit(px_y,proj_y);
        
        beam_position(i,1) = q_x(3);
        beam_position(i,2) = q_y(3);
        
        pause(1)
    end
    
    
    
%     figure(1)
%     subplot(2,1,1)
%     cla
%     plot(proj_x)
%     hold on;
%     plot(x_fit,'Color','r')
%     y_limits = get(gca,'Ylim');
%     line([q_x(3) q_x(3)], y_limits, 'Color','r')
%     title('X')
%     
%     subplot(2,1,2)
%     cla
%     plot(proj_y)
%     hold on;
%     plot(y_fit,'Color','r')
%     y_limits = get(gca,'Ylim');
%     line([q_y(3) q_y(3)], y_limits, 'Color','r')
%     title('Y')
    
  
    % set beam center pixel value
    Cx = mean(beam_position(:,1));
    Cy = mean(beam_position(:,2));
    
    % check that laser is actually present
    if max(max(prof.img))<50
        disp('Cannot find laser peak. Ending feedback.');
        break;
    end

    % difference from target value
    dx = Cx-target_x; % px
    dy = Cy-target_y; % px

    % compare to alignment tolerance
    if abs(dx) > tol_x

        % get current motor position for TransLaunch2 mirror motors
        M2H = lcaGet('MOTR:LI20:MC06:S1:CH1:MOTOR.RBV');

        % The motor above moves the beam 540 pixels per revolution.
        x_calib = 350; %540;  The measured value is 540, but the jumps are too big.
        
        dH = dx / x_calib;

        M2H = M2H+dH;
        
        % set new motor position
        lcaPut('MOTR:LI20:MC06:S1:CH1:MOTOR',M2H);
        
        % print to screen
        disp([(sprintf('Moved Horiz. Motor %.4f rev',dH))]);

    end
    if abs(dy) > tol_y

        % The motor below moves -140 pixels per revolution.
        y_calib = 350; %500; Again, scaling down the calibration so the jumps are smaller.
        
        % get current motor position for TransLaunch2 mirror motors
        M2V = lcaGet('MOTR:LI20:MC06:S1:CH2:MOTOR.RBV');

        % calc new motor position
        dV = dy / y_calib;
        
        M2V = M2V+dV;

        % set new motor position
        lcaPut('MOTR:LI20:MC06:S1:CH2:MOTOR',M2V);
        
        % print to screen
        disp([(sprintf('Moved Vert. Motor %.4f rev',dV))]);

    end

    iter=iter+1;
    % This feedback system corrects for slow drift in the temperature of
    % the laser room, so it only needs to be updated infrequently.
    pause(30);
    
end

end

