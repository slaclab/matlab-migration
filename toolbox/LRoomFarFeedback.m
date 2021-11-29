%% Function to keep laser aligned on LRoomFar camera
%  inputs:
%     target_x : x target position in px
%     target_y : y target position in px
%     tol_x    : x alignment tolerance in px
%     tol_y    : y alignment tolerance in px
%
% M.Litos Apr. 11, 2015
function [ ] = LRoomFarFeedback( target_x, target_y, tol_x, tol_y )

if nargin<1
    target_x = 650; % px
end
if nargin<2
    target_y = 550; % px
end
if nargin<3
    tol_x = 0; % px
end
if nargin<4
    tol_y = 0; % px
end

% silence the stupid warnings from profmon_grab
lcaPut('PROF:LI20:12:BinX.PROC',1);
lcaPut('PROF:LI20:12:BinY.PROC',1);

% infinite loop!
iter=0;
while true

    % check EPICS PV LRoomFarFeedback_stop (bool)
    if (lcaGet('SIOC:SYS1:ML00:AO699'))
        break;
    end
    
    disp([(sprintf('Feedback loop iteration %.0f',iter))]);
    
    % grab LRoomFar profmon image
    LRoomFarPVName = 'PROF:LI20:12';
    prof = profmon_grab(LRoomFarPVName);

    % take projections
    px_x = [prof.roiX:prof.roiX+prof.roiXN-1];
    px_y = [prof.roiY:prof.roiY+prof.roiYN-1];
    proj_x = sum(prof.img,1);
    proj_y = sum(prof.img,2)';

    % % find centroid
    % Cx = sum(proj_x.*px_x)/sum(proj_x) % px
    % Cy = sum(proj_y.*px_y)/sum(proj_y) % px

    % find peak (better than centroid)
    [max_x peak_x] = max(proj_x); % px
    [max_y peak_y] = max(proj_y); % px
    
    % take 3 px wide strips to better determine peak
    roi_x = [peak_x-1:peak_x+1];
    roi_y = [peak_y-1:peak_y+1];
    proj_x = sum(prof.img(roi_y,:),1);
    proj_y = sum(prof.img(:,roi_x),2)';
    [max_x peak_x] = max(proj_x); % px
    [max_y peak_y] = max(proj_y); % px
    
    % set beam center pixel value
    Cx = px_x(peak_x);
    Cy = px_y(peak_y);
    
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
        M2H = lcaGet('MOTR:LI20:MC06:M0:CH3:MOTOR.RBV');

        % calc new motor position
        if abs(dx)>10 % px
            dH = 0.05; % rev (step)
        elseif abs(dx)<=10 && abs(dy)>2
            dH = 0.005; % rev (step)
        else
            dH = 0.001; % rev (step)
        end
        
        if dx<0; dH = -dH; end
        M2H = M2H+dH;
        
        % set new motor position
        lcaPut('MOTR:LI20:MC06:M0:CH3:MOTOR',M2H);
        
        % print to screen
        disp([(sprintf('Moved Horiz. Motor %.4f rev',dH))]);

    end
    if abs(dy) > tol_y

        % get current motor position for TransLaunch2 mirror motors
        M2V = lcaGet('MOTR:LI20:MC06:M0:CH4:MOTOR.RBV');

        % calc new motor position
        if abs(dy)>10 % px
            dV = 0.05; % rev (step)
        elseif abs(dy)<=10 && abs(dy)>2
            dV = 0.005; % rev (step)
        else
            dV = 0.001; % rev (step)
        end
        
        if dy<0; dV = -dV; end
        M2V = M2V+dV;

        % set new motor position
        lcaPut('MOTR:LI20:MC06:M0:CH4:MOTOR',M2V);
        
        % print to screen
        disp([(sprintf('Moved Vert. Motor %.4f rev',dV))]);

    end

    iter=iter+1;
    pause(1);
    
end

end

