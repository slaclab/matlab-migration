function [Phase_RFdegOut, Motor] = LbandHP_PhaseShifters_SetPhase(PhShfID, Phase_RFdeg)
% Set the phase in RF deg at 1.3 GHz for the High power L-band phase shifters. 
% PhShfID=0 selects the T-Cav.
% SINTAX: [Phase_RFdeg, Motor] = LbandHP_PhaseShifters_SetPhase(PhShfID, Phase_RFdeg)
% Fit parameters from Slawek measurements on June 3, 2015.

PhMin=-191.835;
PhMax=179.71;

if PhShfID==0
    %T-Cav (Slawek ID 2)
    PhsStrSet='HPRF:MOT:deflectorPhase.VAL';
    PhsStrRBV='HPRF:MOT:deflectorPhase.RBV';
    AttStrSet='HPRF:MOT:deflectorAtt.VAL';
    AttStrRBV='HPRF:MOT:deflectorAtt.RBV';
elseif PhShfID==2
    %Linac 2 (Slawek ID 3)
    PhsStrSet='HPRF:MOT:linac2phase.VAL';
    PhsStrRBV='HPRF:MOT:linac2phase.RBV';
    AttStrSet='HPRF:MOT:linac2att.VAL';
    AttStrRBV='HPRF:MOT:linac2att.RBV';
elseif PhShfID==3
    %Linac 3 (Slawek ID 4)
    PhsStrSet='HPRF:MOT:linac3phase.VAL';
    PhsStrRBV='HPRF:MOT:linac3phase.RBV';
    AttStrSet='HPRF:MOT:linac3att.VAL';
    AttStrRBV='HPRF:MOT:linac3att.RBV';
else
    if PhShfID~=1
        ['ERROR: wrong attenuator ID!']
        return
    end
    % Linac 1 (Slawek ID 1)
    PhsStrSet='HPRF:MOT:linac1phase.VAL';
    PhsStrRBV='HPRF:MOT:linac1phase.RBV';
    AttStrSet='HPRF:MOT:linac1att.VAL';
    AttStrRBV='HPRF:MOT:linac1att.RBV';
end

if Phase_RFdeg> 360
    ['ERROR: Phase > 360 RF deg']
    Phase_RFdeg=NaN;
end
if Phase_RFdeg< -360
    ['ERROR: Phase < 360 RF deg']
    Phase_RFdeg=NaN;
end

if Phase_RFdeg>PhMax
    Phase_RFdeg=Phase_RFdeg-360;
end
if Phase_RFdeg<PhMin
    Phase_RFdeg=Phase_RFdeg+360;
end

Motor=LbandHP_PhaseShifters_Motor(Phase_RFdeg)
setpvonline(PhsStrSet,Motor,'float',1);
Phase_RFdegOut=LbandHP_PhaseShifters_Phase(Motor)
['Set L-band Phase shifter ',num2str(PhShfID),' to ',num2str(Phase_RFdegOut),' RF deg']
end

