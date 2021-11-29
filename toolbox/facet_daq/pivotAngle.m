    % function that sets new values for axicon (kinoform) motor and USHM motor
% based on a requested pivot angle about the centre of the plasma oven
% (= image plane of ax_img2).

function S2 = pivotAngle(angle_hor_abs, angle_ver_abs)

currentPV_X = lcaGetSmart('SIOC:SYS1:ML03:AO044');
currentPV_Y = lcaGetSmart('SIOC:SYS1:ML03:AO045');

angle_hor = angle_hor_abs-currentPV_X;
angle_ver = angle_ver_abs-currentPV_Y;

T1 = [-46.27 -4.26 
    -4.53 37.61];
M1 = [-44.18 0.097       
    -4.36 -0.98];
R1 = 28.5/1.04*[-24.45 -1.28
                -0.98 17.77];

T2 = [-46.27 -4.26/1.14 
    -4.53 37.61/1.14];
M2 = [-44.18 0.097/0.98       
    -4.36 -0.98/0.98];
R2 = 28.5/1.04*[-24.45 -1.28/1.14
                -0.98 17.77/1.14];

T3 = [-46.27/1.011 -4.26 
    -4.53/1.011 37.61];
M3 = [-44.18 0.097       
    -4.36 -0.98];
R3 = 28.5/1.04*[-24.45/1.011 -1.28
                -0.98/1.011 17.77];

T4 = [-46.27/1.011 -4.26/1.14 
    -4.53/1.011 37.61/1.14];
M4 = [-44.18 0.097/0.98       
    -4.36 -0.98/0.98];
R4 = 28.5/1.04*[-24.45/1.011 -1.28/1.14
                -0.98/1.011 17.77/1.14];

S1 = struct('T1',T1,'T2',T2,'T3',T3,'T4',T4);
S2 = struct('M1',M1,'M2',M2,'M3',M3,'M4',M4);
S3 = struct('R1',R1,'R2',R2,'R3',R3,'R4',R4);


if (angle_hor>=0 && angle_ver>=0)
    T=S1.T1; M=S2.M1; R=S3.R1;
elseif (angle_hor>=0 && angle_ver<=0)
    T=S1.T2; M=S2.M2; R=S3.R2;
elseif (angle_hor<=0 && angle_ver>=0)
    T=S1.T3; M=S2.M3; R=S3.R3;
elseif (angle_hor<=0 && angle_ver<=0)
    T=S1.T4; M=S2.M4; R=S3.R4;
else
    disp('fail');
end
    
%{    
% these matrices can be obtained from calibration.m
if (angle_hor>=0 && angle_ver>=0)
    T = [-65.9 0 
        0 48.45];
    M = [1.17 0.1         % M(1,1) was 1.23 before
        0.095 -1.15];
    R = [-686 0
        0 488];
elseif (angle_hor>=0 && angle_ver<=0)
    T = [-65.9 0 
        0 42.3];
    M = [1.17 0.1         % M(1,1) was 1.23 before
        0.095 -1.16];
    R = [-686 0
        0 425];
elseif (angle_hor<=0 && angle_ver>=0)
    T = [-59.2 0 
        0 48.45];
    M = [1.30 0.1
        0.085 -1.15];
    R = [-589 0
        0 488];
elseif (angle_hor<=0 && angle_ver<=0)
    T = [-59.2 0 
        0 42.3];
    M = [1.30 0.1
        0.085 -1.16];
    R = [-589 0
        0 425];
else
    disp('fail');
end
%}    
waveplate = lcaGetSmart('XPS:LA20:LS24:M1');  

if abs(waveplate-59.6)< 0.1
    
    % convert requested angle changes to horizontal and vertical tilts of USHM
    R_inv = inv(R);
    tilt_hor = R_inv(1,1)*angle_hor + R_inv(1,2)*angle_ver;
    tilt_ver = R_inv(2,1)*angle_hor + R_inv(2,2)*angle_ver;

    % tilt induces a translation of ax_img2
    delta_x = T(1,1)*tilt_hor + T(1,2)*tilt_ver;
    delta_y = T(2,1)*tilt_hor + T(2,2)*tilt_ver;

    % compensate for this translation using translation axicon (kinoform)
    M_inv = inv(M);
    delta_pos_hor = -M_inv(1,1)*delta_x - M_inv(1,2)*delta_y;
    delta_pos_ver = -M_inv(2,1)*delta_x - M_inv(2,2)*delta_y;
    
    % set horizontal and vertical tilt to new value
    fprintf('horiz. tilt = %.4f\n',tilt_hor);
    fprintf('vert. tilt = %.4f\n',tilt_ver);
    fprintf('hor. axicon tranl. = %.4f\n',delta_pos_hor);
    fprintf('ver. axicon tranl. = %.4f\n',delta_pos_ver);
    
    % current tilt USHM
    current_tilt_hor = lcaGetSmart('MOTR:LI20:MC14:M0:CH1:MOTOR.RBV'); %get horizontal tilt of the USHM
    current_tilt_ver = lcaGetSmart('MOTR:LI20:MC14:M0:CH2:MOTOR.RBV'); %get vertical tilt of the USHM
    
    % current position axicon (kinoform)
    current_pos_hor = lcaGetSmart('XPS:LI20:MC04:M6.RBV');
    current_pos_ver = lcaGetSmart('MOTR:LI20:MC14:M0:CH3:MOTOR.RBV');
    
%     flag = 0;
%     while (flag == 0)
        %str = input('Suggested tilts and translations acceptable? (y or n) ', 's');
        %if (strcmp('y',str))
            % tilt USHM to required value
            lcaPutSmart('MOTR:LI20:MC14:M0:CH1:MOTOR', current_tilt_hor+tilt_hor);
            lcaPutSmart('MOTR:LI20:MC14:M0:CH2:MOTOR', current_tilt_ver+tilt_ver);
            
            % translate axicon (kinoform) to required value
            lcaPutSmart('XPS:LI20:MC04:M6',current_pos_hor+delta_pos_hor);
            lcaPutSmart('MOTR:LI20:MC14:M0:CH3:MOTOR',current_pos_ver+delta_pos_ver);
            
            % wait for the USHM motors to stop
            wait_for_motor('MOTR:LI20:MC14:M0:CH1:MOTOR',current_tilt_hor+tilt_hor,0.001);
            wait_for_motor('MOTR:LI20:MC14:M0:CH2:MOTOR',current_tilt_ver+tilt_ver,0.001);
            
            % wait for axicon motors to stop
            wait_for_motor('XPS:LI20:MC04:M6',current_pos_hor+delta_pos_hor);
            wait_for_motor('MOTR:LI20:MC14:M0:CH3:MOTOR',current_pos_ver+delta_pos_ver);
                        
%             flag = 1;
%         elseif (strcmp('n',str))
%             disp('no moves');
%             flag = 1;
%         else
%             flag = 0;
%         end
%     end

    lcaPutSmart('SIOC:SYS1:ML03:AO044', angle_hor_abs);
    lcaPutSmart('SIOC:SYS1:ML03:AO045', angle_ver_abs);

end

end





