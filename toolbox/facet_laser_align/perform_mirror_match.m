% This file performs the motion as derived by the mirror_match function.


function perform_mirror_match(handles)

% This value cuts the total jump size to prevent unstable situations.
safety_factor_x = 0.95;
safety_factor_y = 0.95;

M1X = safety_factor_x * handles.mirrormotion.M1X;
M2X = safety_factor_x * handles.mirrormotion.M2X;
M1Y = safety_factor_y * handles.mirrormotion.M1Y;
M2Y = safety_factor_y * handles.mirrormotion.M2Y;

motor_M1X = handles.mirror_motors.M1X;
motor_M2X = handles.mirror_motors.M2X;
motor_M1Y = handles.mirror_motors.M1Y;
motor_M2Y = handles.mirror_motors.M2Y;

% divide the total step to take into many steps, so the beam doesn't move
% so far on each iteration.

% Turns out, this makes it really slow.  So leave it at 1.

N_STEP = 1;

for i = 1 : N_STEP

    motor_perform_step(motor_M1X,M1X/N_STEP)
    motor_perform_step(motor_M1Y,M1Y/N_STEP)
    motor_perform_step(motor_M2X,M2X/N_STEP)
    motor_perform_step(motor_M2Y,M2Y/N_STEP)

end


% % This is the PV to put the new step value into.
% M1X_step_PV = [motor_M1X,':MOTOR.TWV'];
% M2X_step_PV = [motor_M2X,':MOTOR.TWV'];
% M1Y_step_PV = [motor_M1Y,':MOTOR.TWV'];
% M2Y_step_PV = [motor_M2Y,':MOTOR.TWV'];
% 
% % Switching this PV to 1 will perform the jump.
% M1X_jump_PV = [motor_M1X,':MOTOR.TWF'];
% M2X_jump_PV = [motor_M2X,':MOTOR.TWF'];
% M1Y_jump_PV = [motor_M1Y,':MOTOR.TWF'];
% M2Y_jump_PV = [motor_M2Y,':MOTOR.TWF'];
% 
% 
% % Enter the step value
% lcaPut(M1X_step_PV,M1X);
% lcaPut(M2X_step_PV,M2X);
% lcaPut(M1Y_step_PV,M1Y);
% lcaPut(M2Y_step_PV,M2Y);
% 
% % pause(0.1)
% % 
% % % perform the jump!
% lcaPut(M1X_jump_PV,1)
% lcaPut(M2X_jump_PV,1)
% lcaPut(M1Y_jump_PV,1)
% lcaPut(M2Y_jump_PV,1)




