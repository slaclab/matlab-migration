function []=modifyAximgCameraBM_PV(x1,y1,x2,y2,x3,y3)

%These PVs are used to record the well-aligned position of the laser.
%Modify it so that the MoveDelayStageCode works properly.
        
        lcaPutSmart('SIOC:SYS1:ML00:AO980',x1);
        lcaPutSmart('SIOC:SYS1:ML00:AO981',y1);
        lcaPutSmart('SIOC:SYS1:ML00:AO982',x2);
        lcaPutSmart('SIOC:SYS1:ML00:AO983',y2);
        lcaPutSmart('SIOC:SYS1:ML00:AO984',x3);
        lcaPutSmart('SIOC:SYS1:ML00:AO985',y3);
end
