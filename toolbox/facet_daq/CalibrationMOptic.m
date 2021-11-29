function [MOptic]=CalibrationMOptic(x1,x2,y1,y2)

    %Typical values for x1,2 is +-0.2 and typical value for y1,2 is 50


    %BM for Ax_img Cameras in pixels to be deter:
        X0_1=lcaGetSmart('SIOC:SYS1:ML00:AO980');
        Y0_1=lcaGetSmart('SIOC:SYS1:ML00:AO981');
        X0_2=lcaGetSmart('SIOC:SYS1:ML00:AO982');
        Y0_2=lcaGetSmart('SIOC:SYS1:ML00:AO983');
        X0_3=lcaGetSmart('SIOC:SYS1:ML00:AO984');
        Y0_3=lcaGetSmart('SIOC:SYS1:ML00:AO985');

    %Calculation of first two coefficients of the MOptic matrix thanks to Ax_img2
        lcaPut('XPS:LI20:MC04:M6',lcaGet('XPS:LI20:MC04:M6')+x1);
        %[value1X,x1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3310').img),1);
        %[value1Y,y1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3310').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3310')));colorbar();
        [x1P,y1P]=ginput(1);
        lcaPut('XPS:LI20:MC04:M6',lcaGet('XPS:LI20:MC04:M6')-x1);
        lcaPut('XPS:LI20:MC04:M6',lcaGet('XPS:LI20:MC04:M6')+x2);
        %[value2x,x2P]=max(sum(profmon_grab('EXPT:LI20:3310'),1);
        %[value2y,y2P]=max(sum(profmon_grab('EXPT:LI20:3310'),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3310')));colorbar();
        [x2P,y2P]=ginput(1);
        lcaPut('XPS:LI20:MC04:M6',lcaGet('XPS:LI20:MC04:M6')-x2);
        m11=(x2P-x1P)/(x2-x1);
        m21=(y2P-y1P)/(x2-x1);

    %Calculation of last two coefficients of the MOptic matrix thanks to Ax_img2
        lcaPut('MOTR:LI20:MC14:M0:CH3:MOTOR',lcaGet('MOTR:LI20:MC14:M0:CH3:MOTOR')+y1);
        %[value1X,x1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3310').img),1);
        %[value1Y,y1P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3310').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3310')));colorbar();
        [x1P,y1P]=ginput(1);
        lcaPut('MOTR:LI20:MC14:M0:CH3:MOTOR',lcaGet('MOTR:LI20:MC14:M0:CH3:MOTOR')-y1);
        lcaPut('MOTR:LI20:MC14:M0:CH3:MOTOR',lcaGet('MOTR:LI20:MC14:M0:CH3:MOTOR')+y2);
        %[value2x,x2P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3310').img),1);
        %[value2y,y2P]=max(sum(medfilt2(profmon_grab('EXPT:LI20:3310').img),2);
        imagesc(medfilt2(profmon_grab('EXPT:LI20:3310')));colorbar();
        [x2P,y2P]=ginput(1);
        lcaPut('MOTR:LI20:MC14:M0:CH3:MOTOR',lcaGet('MOTR:LI20:MC14:M0:CH3:MOTOR')-y2);
        m12=(x2P-x1P)/(x2-x1);
        m22=(y2P-y1P)/(x2-x1);

        MOptic=[m11 m12 ; m21 m22];
end










