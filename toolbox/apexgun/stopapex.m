function [] = stopapex % FS April 29, 2014
% Stop APEX safely 

% Close Laser Shutter
setpv('Laser:Shutter:CloseReq',1);
setpv('IOL01:CH0_BO',0); % UED pump laser shutter
setpv('IOL01:CH1_BO',0); % 60 deg photocathode laser shutter



% Open Gun and Buncher llrf phase and ampl. loops
opengunllrfloop;
openbuncherllrfloop;


% Set Gun RF Power to zero (in the llrf amp/phase loop) and disable RF permit
setpvonline('llrf1:set_iloop_re_ao',  0,'float',1);
setpvonline('llrf1:set_iloop_im_ao',  0,'float',1);

setpv('Gun:RF:RF_Off_Cmd',1);
pause(.05)
setpv('Gun:RF:RF_Off_Cmd',0);
pause(.05)


% Set Gun, Buncher and Linac RF power to zero on llrf matlab GUIs
PowerReal=0;
PowerImag=0;
setpvonline('llrf1:source_re_ao',PowerReal,'float',1);% Gun
setpvonline('llrf1:source_im_ao',PowerImag,'float',1);% Gun

setpvonline('L1llrf:source_re_ao',PowerReal,'float',1);% Buncher
setpvonline('L1llrf:source_im_ao',PowerImag,'float',1);% Gun

setpvonline('L2llrf:source_re_ao',PowerReal,'float',1);% Linac
setpvonline('L2llrf:source_im_ao',PowerImag,'float',1);% Gun

% Disable gun, buncher, linac RFs
gunRFenable(0);
buncherRFenable(0);
linacRFenable(0);

%Cavity steel heaters OFF
setpv('CavityHeater1:DutyCycle',15);
setpv('CavityHeater2:DutyCycle',15);
setpv('CavityHeater1:OnReq',0);
setpv('CavityHeater2:OnReq',0);


%Extract screens, slits and Faraday cup
setpv('Screen1:Command',0);
setpv('Screen2:Command',0);
setpv('Screen3:Command',0);
setpv('Screen4:Command',0);
setpv('Slit1:M1:PCMD',0);
setpv('Slit1:M2:PCMD',0);

%Insert Beam Dump
%setpv('BeamDump:InReq',1)

%Turn OFF laser feedback
openlaserloop

%close Valves
setpv('VVR1:CloseReq',1);
setpv('VVR2:CloseReq',1);
setpv('UED:VVR1:CloseReq',1);
setpv('UED:VVR2:CloseReq',1);


%Magnets OFF
if getpv('ACC:Branchline') % check which one between APEX and HiRES is running
        magnetpsoff;
    else
       magnetpsoff_UED;
    end

%Set Gun HPA in Standby Mode
SetGunHPAinStandby;

% set gun tuner to low force
%Set tuner mode.
setpvonline('CavityTuner:ModeReq',2,'float',1);% Motor only mode
%setpvonline('CavityTuner:ModeReq',3,'float',1);% Motor+piezo mode
setpvonline('CavityTuner:LoadReq.OMSL',0,'float',1);% Tuner in supervisory mode (PLC feedback open)
FT_i=getpv('CavityTuner:LoadAvg');
FT_step=-(FT_i-100)/9;
['Setting Gun tuner to rest position. This can require few minutes']
for FT_act=FT_i:FT_step:100
    setpvonline('CavityTuner:LoadReq',FT_act,'float',1);
    pause(10)
end
setpvonline('CavityTuner:LoadReq',100,'float',1);


SteelTemp=getpv('Gun:RF:Temp15');
% waiting for the gun stainless steel to cool down before putting gun tuner in idle mode
while SteelTemp>27
    ['Waiting for the steel to cool down before setting tuner in idle mode']
    pause(60)
    SteelTemp=getpv('Gun:RF:Temp15');
end

%Set tuner in idle mode.
setpvonline('CavityTuner:ModeReq',1,'float',1);% idle mode
['APEX is safely OFF!']


end


