function [AttnStatus,PhShftStatus] = LbandHP_CheckVAL_RBV_Consistency(AttnPhsShftID)
% Compare set and readback values of the motors for L band HP attenuators and phase shifters. 
% Returns 0 if they agree within 1% or 1 if they do not.
% PhShfID=0 selects the T-Cav.
% SINTAX: [AttnStatus,PhShftStatus] = LbandHP_CheckVAL_RBV_Consistency(AttnPhsShftID)


if AttnPhsShftID==0
    %T-Cav (Slawek ID 2)
    PhsStrSet='HPRF:MOT:deflectorPhase.VAL';
    PhsStrRBV='HPRF:MOT:deflectorPhase.RBV';
    AttStrSet='HPRF:MOT:deflectorAtt.VAL';
    AttStrRBV='HPRF:MOT:deflectorAtt.RBV';
elseif AttnPhsShftID==2
    %Linac 2 (Slawek ID 3)
    PhsStrSet='HPRF:MOT:linac2phase.VAL';
    PhsStrRBV='HPRF:MOT:linac2phase.RBV';
    AttStrSet='HPRF:MOT:linac2att.VAL';
    AttStrRBV='HPRF:MOT:linac2att.RBV';
elseif AttnPhsShftID==3
    %Linac 3 (Slawek ID 4)
    PhsStrSet='HPRF:MOT:linac3phase.VAL';
    PhsStrRBV='HPRF:MOT:linac3phase.RBV';
    AttStrSet='HPRF:MOT:linac3att.VAL';
    AttStrRBV='HPRF:MOT:linac3att.RBV';
else
    if AttnPhsShftID~=1
        ['ERROR: wrong attenuator ID!']
        return
    end
    % Linac 1 (Slawek ID 1)
    PhsStrSet='HPRF:MOT:linac1phase.VAL';
    PhsStrRBV='HPRF:MOT:linac1phase.RBV';
    AttStrSet='HPRF:MOT:linac1att.VAL';
    AttStrRBV='HPRF:MOT:linac1att.RBV';
end

Accuracy=0.01;


AtSet=getpv(AttStrSet);
if AtSet==0
    AtSet=0.001;
end
AtRBV=getpv(AttStrRBV);
D_At_Rel=abs(AtSet-AtRBV)/AtSet;
AttnStatus=0;
if D_At_Rel>Accuracy
    AttnStatus=1;
    ['WARNING: Attenuator ',num2str(AttnPhsShftID),' set and readout out by ',num2str(D_At_Rel*100),' %']
else
    ['Attenuator ',num2str(AttnPhsShftID),' set consistent with readout']
end

PhSet=getpv(PhsStrSet);
if PhSet==0
    PhSet=0.001;
end
PhRBV=getpv(PhsStrRBV);
D_Ph_Rel=abs(PhSet-PhRBV)/PhSet;
PhShftStatus=0;
if D_Ph_Rel>Accuracy
    PhShftStatus=1;
    ['WARNING: Phase Shifter ',num2str(AttnPhsShftID),' set and readout out by ',num2str(D_Ph_Rel*100),' %']
else
    ['Phase Shifter ',num2str(AttnPhsShftID),' set consistent with readout']
end

end

