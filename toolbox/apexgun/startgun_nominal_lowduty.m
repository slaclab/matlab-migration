function [] = startgun_nominal_lowduty(JumpFlag) % FS January 8, 2016
% Start APEX Gun from OFF to the nominal values defined by the following variables hardwired in this code
% Sintax: startgun_nominal_lowduty(JumpFlag).
% if JumpFlag is 0 the routine performs the items required for the initial operation (open valves, remove screens. ...)
% At the end of the procedure the function enters a perpetual loop that keeps Probe 1 at the value hardwired in this code.
% The loop can be interrupted by Ctrl+C.

InitialPulseLength_ms=1.; %pulselenght in ms
FinalPulseLength_ms=18.0; %pulselenght in ms *****DO NOT CHANGE THIS VALUE*****
PulseSteps=18;% number of steps in increasing the pulse lenght

InitialPowerDAC=1000;%Initial power DAC value
FinalPowerDAC=15000;%Final power DAC value

CavityProbe1_operPower_kW=70.;% Gun cavity operational power as measured by probe 1
PowerFeedbackGain=0.05;% Power Feedback Gain


TimeScaleCalFactor=1.0177; %1.01769983554; %Time scale correcting factor

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
    
    
    PosThreshold=7;
    err=0;
    for ii=1:10
        if sm(ii)>PosThreshold
            err=1;
            ['****ERROR: Solenoids position potentially out of range. Check before restarting****']
            return
        end
    end
        
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
    Ntunersteps=4;
    TunSteps=(TunerInit_N-PresTuner)/(Ntunersteps-1);
    for ActTuner=PresTuner:TunSteps:TunerInit_N
        setpvonline('CavityTuner:LoadReq',ActTuner,'float',1);
        pause(8)
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
    restoremagnetpss;
    
    
    %Extract screens and slits
    ['Extracting screens,slits']
    setpv('Screen1:Command',0);
    setpv('Screen2:Command',0);
    setpv('Screen3:Command',0);
    setpv('Screen4:Command',0);
    setpv('Slit1:M1:PCMD',41);
    setpv('Slit1:M2:PCMD',41);
    
    
    %Close Laser Shutter
    ['Closing Laser Shutter']
    setpv('Laser:Shutter:CloseReq',1);
    
    % Set off cavity wall heaters
    setpv('CavityHeater1:OnReq',0);
    setpv('CavityHeater2:OnReq',0);
    setpv('CavityHeater1:DutyCycle',0);
    setpv('CavityHeater2:DutyCycle',0);

end

%Set phase frequency feedback ON
setpv('llrf1:freq_loop_close',1);
FdbckStatus=getpv('llrf1:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

% Set LLRF frequency parameters
setpv('llrf1:ddsa_phstep_h_ao',194000);
setpv('llrf1:ddsa_phstep_l_ao',4092);
setpv('llrf1:ddsa_modulo_ao',4);

% Set LLRF to external trigger mode
setpv('llrf1:ext_trig_sel_bo',1);

% Check delay from external trigger not to be 0
rep_period=getpv('llrf1:rep_period_ao')/1e5; %get repetition period in ms
if rep_period < 1
    setpv('llrf1:rep_period_ao', 1e5*TimeScaleCalFactor); %set delay from external trigger
    ['****WARNING: Gun timing could be wrong. Please check it! ****']
end

setpv('llrf1:pulse_length_ao', InitialPulseLength_ms*1e5*TimeScaleCalFactor); % set initial pulse lenght.

%Set initial time scale
Tscale=round(InitialPulseLength_ms/0.44)+1;
setpv('llrf1:wave_samp_per_ao', Tscale);

%Set RF drive to zero start value;
PowerAmp=InitialPowerDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('llrf1:source_re_ao',PowerReal);
setpv('llrf1:source_im_ao',PowerImag);

%Enable gun RF PLC and reset RF monitors interlocks and gun PLC. It does not reset the LLRF
gunRFenable(1)

%Reset LLRF (this turns the RF ON)
['Resetting the Gun LLRF (this turns the Gun RF ON)']
ii=1;
LLRFData{1}.Prefix = 'llrf1:';
setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);

for ii=1:3    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.1)
end

%Set RF drive to final value;
['Setting RF drive to final value']
PowerAmp=FinalPowerDAC; %Set final drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('llrf1:source_re_ao',PowerReal);
setpv('llrf1:source_im_ao',PowerImag);

for ii=1:10    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.1)
end

% Go to probe 1 operational power
['Going to operational power']
    
for ii=1:20    %do frequency correction (using "decay mode")
    powerfeedback_cavityprobe(CavityProbe1_operPower_kW*1e3,10,PowerFeedbackGain);% Single cycle power feedback
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.1)
end


% Increase pulse lenght to final value
['Increasing RF Pulse Length']
DeltaPulse_ms=(FinalPulseLength_ms-InitialPulseLength_ms)/(PulseSteps-1);
for jj=1:PulseSteps
    
    ActPulseLength=InitialPulseLength_ms+(jj-1)*DeltaPulse_ms;
    
    Tscale=round(ActPulseLength/0.44)+1;
    if Tscale > 22
        Tscale=22;
    end
    setpv('llrf1:wave_samp_per_ao', Tscale);%set time scale

    setpv('llrf1:pulse_length_ao', ActPulseLength*1e5*TimeScaleCalFactor); % set pulse lenght.
    
    for ii=1:40    %do frequency correction (using "decay mode")
        powerfeedback_cavityprobe(CavityProbe1_operPower_kW*1e3,10,PowerFeedbackGain);% Single cycle power feedback
        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.05)
        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
        pause(.05)
    end
end

%Enter perpetual loop
['Entering Perpetual Loop (Ctrl+c to interrupt).']

while 1
    powerfeedback_cavityprobe(CavityProbe1_operPower_kW*1e3,10,PowerFeedbackGain);% Single cycle power feedback
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

    
end


