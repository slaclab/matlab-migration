function [ Phase_RFdeg1_3GHz ] = LbandHP_PhaseShifters_Phase(MotorSetting)
% Calculate the phase for the high power L-band Phase Shifters (valid for all 4 of them). 
% Return phase in RF degrees at 1.3 GHz.
% SINTAX: [ Phase_RFdeg1_3GHz ] = LbandHP_PhaseShifters_Phase(MotorSetting)
% Fit parameters from Slawek measurements on June 3, 2015.

MotSetMax=32767;
MotSetMin=0;
MotorSetting=abs(MotorSetting);
    
% Calibration factors
P0 	=  179.71;
P1 	= -.011339;

Size_motor=size(MotorSetting);

Phase_RFdeg1_3GHz=zeros(1,Size_motor(2));
for ii=1:Size_motor(2)
    
    if MotorSetting(ii)>MotSetMax
        ['ERROR: Motor Setting > ',num2str(MotSetMax),' counts']
        MotorSetting(ii)=NaN;
    end
    if MotorSetting(ii)<MotSetMin
        ['ERROR: Motor Setting < ',num2str(MotSetMin),' counts']
        MotorSetting(ii)=NaN;
    end
        
    mt=MotorSetting(ii);
    Phase_RFdeg1_3GHz(ii)=P0+P1*mt;
end

end

