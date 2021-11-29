function [ MotorSet ] = LbandHP_PhaseShifters_Motor(Phase_RFdeg)
% Calculate the setting for the motor for a given Phase the high power L-band attenuators. 
% Return Motor set.
% SINTAX: [ MotorSet ] = LbandHP_PhaseShifters_MotorSet(Phase_RFdeg)
% Fit parameters from Slawek measurements on June 3, 2015.

PhMin=-191.835;
PhMax=179.71;

% Calibration factors
P0= 15848;
P1=  -88.203;

Size_Phase=size(Phase_RFdeg);
for jj=1:Size_Phase(2)
    if Phase_RFdeg(jj) > PhMax
        %Attn_dB=AtMax;
        ['ERROR: Phase > ',num2str(PhMax),' RF deg']
        Phase_RFdeg(jj)=NaN;
    end
    if Phase_RFdeg(jj) < PhMin
        %Attn_dB=Atmin;
        ['ERROR: Phase < ',num2str(PhMin),' RF deg']
        Phase_RFdeg(jj)=NaN;
    end
end
Size_Phase=size(Phase_RFdeg);

MotorSet=zeros(1,Size_Phase(2));
for ii=1:Size_Phase(2)
    At=Phase_RFdeg(ii);
    MotorSet(ii)= P0+P1*At;
end

end

