
function [] = startbuncher_nominal_lowduty % FS January 8, 2016
% Start APEX Buncher from OFF to the nominal values defined by the following variables hardwired in this code
% Syntax: startbuncher_nominal_lowduty.
% At the end of the procedure the function enters a perpetual loop that keeps Probe 1 at the value hardwired in this code.
% The loop can be interrupted by Ctrl+C.

InitialPulseLength_ms=1.; %pulselenght in ms
FinalPulseLength_ms=30.83; %61.67; %pulselenght in ms *****DO NOT CHANGE THIS VALUE*****
PulseSteps=20;% number of steps in increasing the pulse lenght

InitialPowerDAC=1000;%Initial power DAC value
FinalPowerDAC=13500;%Final power DAC value

BuncherProbe1_operPower_AU=0.6;%0.3; % Buncher cavity operational power as measured by probe 1
PowerFeedbackGain=0.02;% Power Feedback Gain


TimeScaleCalFactor=1; %1.01769983554; %Time scale correcting factor


%Set phase frequency feedback OFF
setpv('L1llrf:freq_loop_close',0);
FdbckStatus=getpv('L1llrf:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

% Set LLRF frequency parameters
setpv('L1llrf:ddsa_phstep_h_ao',281000);
setpv('L1llrf:ddsa_phstep_l_ao',4096);
setpv('L1llrf:ddsa_modulo_ao',4);

% Set LLRF to external trigger mode
setpv('L1llrf:ext_trig_sel_bo',1);

% Check delay from external trigger not to be 0
rep_period=getpv('L1llrf:rep_period_ao')/1e5; %get repetition period in ms
if rep_period < 1
    setpv('L1llrf:rep_period_ao', 1e5*TimeScaleCalFactor); %set delay from external trigger
    ['****WARNING: Buncher timing could be wrong. Please check it! ****']
end

setpv('L1llrf:pulse_length_ao', InitialPulseLength_ms*1e5*TimeScaleCalFactor); % set initial pulse lenght.

%Set initial time scale
Tscale=round(InitialPulseLength_ms/0.44)+1;
setpv('L1llrf:wave_samp_per_ao', Tscale);

%Set RF drive to zero start value;
PowerAmp=InitialPowerDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('L1llrf:source_re_ao',PowerReal);
setpv('L1llrf:source_im_ao',PowerImag);

%Enable buncher RF PLC and reset RF monitors interlocks and buncher PLC. It does not reset the LLRF
buncherRFenable(1)

%Reset LLRF (this turns the RF ON)
['Resetting the Buncher LLRF (this turns the Gun RF ON)']
ii=1;
LLRFData{1}.Prefix = 'L1llrf:';
setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);

for ii=1:3    %do frequency correction (using "decay mode")
    setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
    pause(.1)
end

%Set RF drive to final value;
['Setting RF drive to final value']
NumPwstep=20;
PwStep=(FinalPowerDAC-InitialPowerDAC)/(NumPwstep-1);
for kk=1:NumPwstep
    ActDAC=InitialPowerDAC+(kk)*PwStep;
    PowerAmp=ActDAC; %Set drive power in DAC units
    PowerPhase=0;
    PowerReal=PowerAmp;
    PowerImag=PowerPhase;
    setpv('L1llrf:source_re_ao',PowerReal);
    setpv('L1llrf:source_im_ao',PowerImag);

    for ii=1:10    %do frequency correction (using "decay mode")
        setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.1)
        setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
        pause(.1)
    end
end

% Go to probe 1 operational power
['Going to operational power']
    
for ii=1:100    %do frequency correction (using "decay mode")
    powerfeedback_buncherprobe(BuncherProbe1_operPower_AU,10,PowerFeedbackGain);% Single cycle power feedback
    setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
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
    setpv('L1llrf:wave_samp_per_ao', Tscale);%set time scale

    setpv('L1llrf:pulse_length_ao', ActPulseLength*1e5*TimeScaleCalFactor); % set pulse lenght.
    
    for ii=1:30    %do frequency correction (using "decay mode")
        powerfeedback_buncherprobe(BuncherProbe1_operPower_AU,10,PowerFeedbackGain);% Single cycle power feedback
        setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.05)
        setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
        pause(.05)
    end
end

%Enter perpetual loop
['Entering Perpetual Loop (Ctrl+c to interrupt).']

while 1
    powerfeedback_buncherprobe(BuncherProbe1_operPower_AU,10,PowerFeedbackGain);% Single cycle power feedback
    setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

    
end


