function [] = startapexgun_nominal(JumpFlag) % FS April 9, 2014
% Start APEX from OFF to the nominal starting point defined by the values of the following variables hardwired in this code
% A3FWD_0 in W
% PulseLength_0 in s.
% RepRate_0 in Hz.
% Sintax: startapex_nominal(JumpFlag).
% if JumpFlag is 0 the routine performs the items required for the initial operation (ope valves, remove screens. ...)
% At the end of the procedure (it takes ~30 min), the function enters a perpetual feddback loop that keeps A3FWD at the the A3FWD_0 value
% The loop can be interrupted by Ctrl+C.

if JumpFlag==0
    % Check solenoid motors
    ['Checking solenoid motors']
    sm(1)=getpv('Sol1:M1:PNOW');
    sm(2)=getpv('Sol1:M2:PNOW');
    sm(3)=getpv('Sol1:M3:PNOW');
    sm(4)=getpv('Sol1:M4:PNOW');
    sm(5)=getpv('Sol1:M5:PNOW');
    
    sm(6)=getpv('Sol2:M1:PNOW');
    sm(7)=getpv('Sol2:M2:PNOW');
    sm(8)=getpv('Sol2:M3:PNOW');
    sm(9)=getpv('Sol2:M4:PNOW');
    sm(10)=getpv('Sol2:M5:PNOW');
    
    
    PosThreshold=3.0;
    err=0;
    for ii=1:10
        if sm(ii)<PosThreshold
            err=1;
 %           ['****ERROR: Solenoids position potentially out of range. Check before restarting****']
 %           return
        end
    end
        
    
    setpv('llrf1:ddsa_modulo_ao',4);
    
    % set gun tuner
    %Set tuner mode.
    ['Setting gun tuner mode']
    %setpvonline('CavityTuner:ModeReq',2,'float',1);% Motor only mode
    setpvonline('CavityTuner:ModeReq',3,'float',1);% Motor+piezo mode
    setpvonline('CavityTuner:LoadReq.OMSL',0,'float',1);% Tuner in supervisory mode (PLC feedback open)
    
    % set gun tuner at the initial value
    ['Setting gun tuner at the initial value (it can require few minutes)']
    TunerInit_N=2000; %tuner initial value in N
    PresTuner=getpv('CavityTuner:LoadAvg');
    Ntunersteps=28;
    TunSteps=(TunerInit_N-PresTuner)/(Ntunersteps-1);
    for ActTuner=PresTuner:TunSteps:TunerInit_N
        setpvonline('CavityTuner:LoadReq',ActTuner,'float',1);
        pause(5)
    end
    setpvonline('CavityTuner:LoadReq',TunerInit_N,'float',1);
    
    
    %Reset Slow EPS
    ['Resetting Slow EPS']
    setpv('EPS:Reset',1);
    pause(1);
    setpv('EPS:Reset',0);
    
    %open Valves
    ['Opening Vacuum Valves']
    setpv('VVR1:OpenReq',1);
    setpv('VVR2:OpenReq',1);
    
    %Magnets ON
    ['Turning MagnetPSs ON']
    if getpv('ACC:Branchline') % check which one between APEX and HiRES is running
        restoremagnetpss;
    else
       restoremagnetpss_UED;
    end
    % Cycle Spectrometer magnet
    %cyclespectrometermagnet
    
    %Extract screens and slits
    ['Extracting screens,slits']
    setpv('Screen1:Command',0);
    setpv('Screen2:Command',0);
    setpv('Screen3:Command',0);
    setpv('Screen4:Command',0);
    setpv('Slit1:M1:PCMD',41);
    setpv('Slit1:M2:PCMD',41);
    
    %Insert Beam Dump
    %['Inserting Beam Dump']
    %setpv('BeamDump:InReq',1)
    
    %Close Laser Shutter
    ['Closing Laser Shutter']
    setpv('Laser:Shutter:CloseReq',1);
end

% Open Gun llrf phase and ampl. loops
opengunllrfloop

% Set initial gun llrf parameter
setpv('llrf1:ddsa_phstep_h_ao',194000); %Set initial frequency rough
setpv('llrf1:ddsa_phstep_l_ao',744);%Set initial frequency fine
setpv('llrf1:ddsa_modulo_ao',4);
setpv('llrf1:ext_trig_sel_bo',0);
gunRFenable(1) % enable RF gun PLC

%['Setting Gun RF Parameters']
Probe1_W=85000
PulseLength_0=1.0e-3
RepRate_0=1e3
Nsteps=40
startapexgun(Probe1_W,PulseLength_0,RepRate_0,Nsteps)

end


