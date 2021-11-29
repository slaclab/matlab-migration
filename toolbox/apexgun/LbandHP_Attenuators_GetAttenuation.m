function [Attn_dB, Phase_RFdeg, Motor] = LbandHP_Attenuators_GetAttenuation(AttnID)
% Get the attenuation and relative phase in Rf deg and motor settings
% for the high power L-band attenuator motors. 
% PhShfID=0 selects the T-Cav.
% SINTAX: [Attn_dB, Phase_RFdeg, Motor] = LbandHP_Attenuators_GetAttenuation(AttnID)
% Fit parameters from Slawek measurements on June 3, 2015.

Delta_dBMax=30;
Delta_dBMin=0;

PhMin=-191.835;
PhMax=179.71;

if AttnID==0
    %T-Cav (Slawek ID 2)
    PhsStrSet='HPRF:MOT:deflectorPhase.VAL';
    PhsStrRBV='HPRF:MOT:deflectorPhase.RBV';
    AttStrSet='HPRF:MOT:deflectorAtt.VAL';
    AttStrRBV='HPRF:MOT:deflectorAtt.RBV';
elseif AttnID==2
    %Linac 2 (Slawek ID 3)
    PhsStrSet='HPRF:MOT:linac2phase.VAL';
    PhsStrRBV='HPRF:MOT:linac2phase.RBV';
    AttStrSet='HPRF:MOT:linac2att.VAL';
    AttStrRBV='HPRF:MOT:linac2att.RBV';
elseif AttnID==3
    %Linac 3 (Slawek ID 4)
    PhsStrSet='HPRF:MOT:linac3phase.VAL';
    PhsStrRBV='HPRF:MOT:linac3phase.RBV';
    AttStrSet='HPRF:MOT:linac3att.VAL';
    AttStrRBV='HPRF:MOT:linac3att.RBV';
else
    if AttnID~=1
        ['ERROR: wrong attenuator ID!']
        return
    end
    % Linac 1 (Slawek ID 1)
    PhsStrSet='HPRF:MOT:linac1phase.VAL';
    PhsStrRBV='HPRF:MOT:linac1phase.RBV';
    AttStrSet='HPRF:MOT:linac1att.VAL';
    AttStrRBV='HPRF:MOT:linac1att.RBV';
end

Motor=getpv(AttStrSet)
[Attn_dB, Phase_RFdeg]=LbandHP_Attenuators_Attenuation(AttnID,Motor)

end

