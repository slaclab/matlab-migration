% This function takes the camera name from the gui and decodes it into the
% variables necessary to put into the handles and returns the camera PV.

function camera_PV = pop_up_camera_selection_decoder(selection)

switch selection
    case 'Laser Room Near'
        camera_PV = 'PROF:LI20:B103';
    case 'Laser Room Far'
        camera_PV = 'PROF:LI20:12';
    case 'B4'
        camera_PV = 'EXPT:LI20:3306';
    case 'B6'
        camera_PV = 'EXPT:LI20:3075';
    case 'Ax_Img_1'
        camera_PV = 'EXPT:LI20:3309';
    case 'Ax_Img_2'
        camera_PV = 'EXPT:LI20:3310';
end

