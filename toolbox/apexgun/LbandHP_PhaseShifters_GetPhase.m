function [Phase_RFdeg, Motor] = LbandHP_PhaseShifters_GetPhase(PhShftID)
% Get the present phase setting in RF deg at 1.3 GHz and the motor settings in counts
% for the High power L-band phase shifters. 
% PhShfID=0 selects the T-Cav.
% SINTAX: [Phase_RFdeg, Motor] = LbandHP_PhaseShifters_GetPhase(AttnID)
% Fit parameters from Slawek measurements on June 3, 2015.

if PhShftID==0
    %T-Cav (Slawek ID 2)
    PhsStrSet='HPRF:MOT:deflectorPhase.VAL';
    PhsStrRBV='HPRF:MOT:deflectorPhase.RBV';
    AttStrSet='HPRF:MOT:deflectorAtt.VAL';
    AttStrRBV='HPRF:MOT:deflectorAtt.RBV';
elseif PhShftID==2
    %Linac 2 (Slawek ID 3)
    PhsStrSet='HPRF:MOT:linac2phase.VAL';
    PhsStrRBV='HPRF:MOT:linac2phase.RBV';
    AttStrSet='HPRF:MOT:linac2att.VAL';
    AttStrRBV='HPRF:MOT:linac2att.RBV';
elseif PhShftID==3
    %Linac 3 (Slawek ID 4)
    PhsStrSet='HPRF:MOT:linac3phase.VAL';
    PhsStrRBV='HPRF:MOT:linac3phase.RBV';
    AttStrSet='HPRF:MOT:linac3att.VAL';
    AttStrRBV='HPRF:MOT:linac3att.RBV';
else
    if PhShftID~=1
        ['ERROR: wrong attenuator ID!']
        return
    end
    % Linac 1 (Slawek ID 1)
    PhsStrSet='HPRF:MOT:linac1phase.VAL';
    PhsStrRBV='HPRF:MOT:linac1phase.RBV';
    AttStrSet='HPRF:MOT:linac1att.VAL';
    AttStrRBV='HPRF:MOT:linac1att.RBV';
end

Motor=getpv(PhsStrSet)
Phase_RFdeg=LbandHP_PhaseShifters_Phase(Motor)

end

