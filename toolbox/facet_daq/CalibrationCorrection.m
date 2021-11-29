function []=CalibrationCorrection(x1,x2,y1,y2)

    %this function calculates the matrix of Optic mount movement and of M3
    %movements

    %BM for Ax_img Cameras in pixels to be deter:
        X0_1=lcaGetSmart('SIOC:SYS1:ML00:AO980');
        Y0_1=lcaGetSmart('SIOC:SYS1:ML00:AO981');
        X0_2=lcaGetSmart('SIOC:SYS1:ML00:AO982');
        Y0_2=lcaGetSmart('SIOC:SYS1:ML00:AO983');
        X0_3=lcaGetSmart('SIOC:SYS1:ML00:AO984');
        Y0_3=lcaGetSmart('SIOC:SYS1:ML00:AO985');

    %Calculate the matrices
        M1=CalibrationM3(x1,y1)
        M=CalibrationMOptic(x1,x2,y1,y2)

end