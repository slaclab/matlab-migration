% This function takes in the camera you have selected and auto picks teh
% cameras you should use.  I'll let you select them later.


% For now it decodes from the camera selection.  This may change.


function [motor_1,motor_2] = pop_up_motor_selection_decoder(selection)

switch selection
    case 'Laser Room Near'
        % camera_PV = 'PROF:LI20:B103';
        motor_1 = 'MOTR:LI20:MC06:M0:CH1';
        motor_2 = 'MOTR:LI20:MC06:M0:CH2';
    case 'Laser Room Far'
        % camera_PV = 'PROF:LI20:12';
        motor_1 = 'MOTR:LI20:MC06:M0:CH3';
        motor_2 = 'MOTR:LI20:MC06:M0:CH4';
    case 'B4'
        motor_1 = 'MOTR:LI20:MC07:S1:CH1';
        motor_2 = 'MOTR:LI20:MC07:S1:CH2';
    case 'B6'
        motor_1 = 'MOTR:LI20:MC08:M0:CH1';
        motor_2 = 'MOTR:LI20:MC08:M0:CH2';
    case 'Ax_Img_1'
        motor_1 = 'MOTR:LI20:MC10:M0:CH1';
        motor_2 = 'MOTR:LI20:MC10:M0:CH2';
    case 'Ax_Img_2'
        motor_1 = 'MOTR:LI20:MC10:S1:CH3';
        motor_2 = 'MOTR:LI20:MC10:S1:CH4';
end