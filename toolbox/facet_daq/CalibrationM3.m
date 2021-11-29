function [M3]=CalibrationM3(x1,y1)


    %Calibration for Ax_img Cameras //// I tried to calibrate exactly the
    %length measured on the cameras, even if this is not useful.
        Calibration1=6.4*40/6;
        Calibration2=11.2*40/8;
        Calibration3=4.6*40/15;

    %BM for Ax_img Cameras in pixels to be deter:
        X0_1=lcaGetSmart('SIOC:SYS1:ML00:AO980');
        Y0_1=lcaGetSmart('SIOC:SYS1:ML00:AO981');
        X0_2=lcaGetSmart('SIOC:SYS1:ML00:AO982');
        Y0_2=lcaGetSmart('SIOC:SYS1:ML00:AO983');
        X0_3=lcaGetSmart('SIOC:SYS1:ML00:AO984');
        Y0_3=lcaGetSmart('SIOC:SYS1:ML00:AO985');

    % typical values for x1,2 and y1,2 are ;
    %Calculation of the first two coefficient of the M3 Matrix thanks to
    %Ax_img1 and 3
        lcaPut('MOTR:LI20:MC14:S2:CH1:MOTOR',lcaGet('MOTR:LI20:MC14:S2:CH1:MOTOR')+x1);
        %[value1X,x1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3307').img),1);
        %[value1Y,y1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3307').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3307')));colorbar();
        [x1P,y1P]=ginput(1);
        %[value3X,x3P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3313').img),1);
        %[value4Y,y3P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3313').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3313')));colorbar();
        [x3P,y3P]=ginput(1);
        m11=(((x1P-X0_1)*Calibration1-(x3P-X0_3)*Calibration3))/(1.83*(x2-x1));
        m21=(((y1P-Y0_1)*Calibration1-(y3P-Y0_3)*Calibration3))/(1.83*(x2-x1));
        lcaPut('MOTR:LI20:MC14:S2:CH1:MOTOR',lcaGet('MOTR:LI20:MC14:S2:CH1:MOTOR')-x1);


    %Calculation of the lasr two coefficient of the M3 Matrix  thanks to
    %Ax_img1,3
        lcaPut('MOTR:LI20:MC14:S2:CH2:MOTOR',lcaGet('MOTR:LI20:MC14:S2:CH2:MOTOR')+y1);
        %[value1X,x1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3307').img),1);
        %[value1Y,y1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3307').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3307')));colorbar();
        [x1P,y1P]=ginput(1);
        %[value3X,x3P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3313').img),1);
        %[value4Y,y3P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3313').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3313')));colorbar();
        [x3P,y3P]=ginput(1);    
        m12=(((x1P-X0_1)*Calibration1-(x3P-X0_3)*Calibration3))/(1.83*(y2-y1));
        m22=(((y1P-Y0_1)*Calibration1-(y3P-Y0_3)*Calibration3))/(1.83*(y2-y1));
        lcaPut('MOTR:LI20:MC14:S2:CH2:MOTOR',lcaGet('MOTR:LI20:MC14:S2:CH2:MOTOR')-y1);

        M3=[m11 , m12 ; m21,m22];
    
end