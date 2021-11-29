function [MotorSet] = LbandHP_PhaseShifters_CalcMotorForDeltaPhase(PhShftID, DeltaPhase_RFdeg, PresentMotorValue)
% Calculate the setting for the high power L-band phase shifters motors to apply 
% a given Delta Phase in RF deg at 1.3 GHz with respect to the present phase. 
% PhShfID=0 selects the T-Cav.
% SINTAX: [MotorSet] = LbandHP_PhaseShifters_CalcMotorForDeltaPhase(PhShftID, DeltaPhase_RFdeg, PresentMotorValue))
% Fit parameters from Slawek measurements on June 3, 2015.

PhMin=-191.835;
PhMax=179.71;

if PhShftID==0
    %T-Cav (Slawek ID 2)
    PhsStrSet='HPRF:MOT:deflectorPhase.VAL';
    PhsStrRBV='HPRF:MOT:deflectorPhase.RBV';
elseif PhShftID==2
    %Linac 2 (Slawek ID 3)
    PhsStrSet='HPRF:MOT:linac2phase.VAL';
    PhsStrRBV='HPRF:MOT:linac2phase.RBV';
elseif PhShftID==3
    %Linac 3 (Slawek ID 4)
    PhsStrSet='HPRF:MOT:linac3phase.VAL';
    PhsStrRBV='HPRF:MOT:linac3phase.RBV';
else
    if PhShftID~=1
        ['ERROR: wrong attenuator ID!']
        return
    end
    % Linac 1 (Slawek ID 1)
    PhsStrSet='HPRF:MOT:linac1phase.VAL';
    PhsStrRBV='HPRF:MOT:linac1phase.RBV';
end

if DeltaPhase_RFdeg > PhMax
    ['ERROR: Delta phase > ',num2str(PhMax),' RF deg']
    DeltaPhase_RFdeg=NaN;
end
if DeltaPhase_RFdeg < PhMin
    ['ERROR: Delta phase < ',num2str(PhMin),' RF deg']
    DeltaPhase_RFdeg=NaN;
end

DeltaPhase_RFdeg;
%Motor0=getpv(PhsStrSet)
Motor0=PresentMotorValue;
InitialPhase=LbandHP_PhaseShifters_Phase(Motor0);
FinalPhase=InitialPhase+DeltaPhase_RFdeg;
if FinalPhase>PhMax
    FinalPhase=FinalPhase-360;
end
if FinalPhase<PhMin
    FinalPhase=FinalPhase+360;
end
FinalPhase;
MotorSet=LbandHP_PhaseShifters_Motor(FinalPhase);
%setpvonline(PhsStrSet,MotorSet,'float',1);
%['Applied ',num2str(DeltaPhase_RFdeg),' to Phase Shifter ',num2str(PhShftID)]


end

