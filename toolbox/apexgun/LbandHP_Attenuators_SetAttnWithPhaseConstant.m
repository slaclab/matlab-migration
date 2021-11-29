function [] = LbandHP_Attenuators_SetAttnWithPhaseConstant(AttnID, Attn_dB)
% Calculate and apply the setting for the high power L-band attenuator motors to apply 
% a given attenuation Attn_dB in dB. Also set the correspondent phase shifter to keep
% the phase constatnt
% AttnID=0 selects the T-Cav.
% SINTAX: [] = LbandHP_Attenuatorss_AttnPhaseConstant(AttnID, Attn_dB)
% Fit parameters from Slawek measurements on June 3, 2015.

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
    AttStrRBV='HPRF:MOT:linaca1att.RBV';
end
    
dBMax=LbandHP_Attenuators_Attenuation(AttnID,3000);
dBMin=LbandHP_Attenuators_Attenuation(AttnID,18500);

if Attn_dB > dBMax
    ['ERROR: Attenuation > ',num2str(dBMax),' dB']
    Attn_dB=NaN;
end
if Attn_dB < dBMin
    ['ERROR: Attenuation < ',num2str(dBMin),' dB']
    Attn_dB=NaN;
end

%Calculate attenuation and phase shifter setting
AttMot0=getpv(AttStrSet);% Attn motor initial value
[Att0,AttPh0]=LbandHP_Attenuators_Attenuation(AttnID,AttMot0);% Initial Attn attenuation and phase
AttMot1=LbandHP_Attenuators_Motor(AttnID,Attn_dB);% Attn motor final set
[Att1, AttPh1]=LbandHP_Attenuators_Attenuation(AttnID,AttMot1);% Final Attn attenuation and phase
AttShiftPh=AttPh1-AttPh0;% Phase shift induced by the attenuator
if AttShiftPh>PhMax
    AttShiftPh=AttShiftPh-360;
end
if AttShiftPh<PhMin
    AttShiftPh=AttShiftPh+360;
end

% Set Attenuator and compensate for the phase shift
Nsteps=1;% Set the HP Phase Shifters and Attenuators in Nsetp steps
Twait=.1;% Time per step in s
PhStep=AttShiftPh/Nsteps;
AttStep=(AttMot1-AttMot0)/Nsteps;
AttAct=AttMot0;
for ii=1:Nsteps
    AttAct=AttAct+AttStep;
    LbandHP_PhaseShifters_SetDeltaPhase(AttnID,PhStep);
    setpvonline(AttStrSet,AttAct,'float',1);
    pause(Twait);
end
['Attenuator number ',num2str(AttnID)];
['Set attenuation to :',num2str(Att1),' dB, kept phase constant'];
['Delta attenuation :',num2str(Att1-Att0),' dB'];
end

