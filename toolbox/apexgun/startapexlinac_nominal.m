function [] = startapexlinac_nominal % FS January 8, 2016
% Start APEX linac from OFF to the nominal values defined by the following variables hardwired in this code
% Syntax: startlinac_nominal_lowduty.
% At the end of the procedure the function enters a perpetual loop that keeps Probe 1 at the value hardwired in this code.
% The loop can be interrupted by Ctrl+C.

PulseLength_ms=0.014; %pulselenght in ms *****DO NOT CHANGE THIS VALUE*****

InitialPowerDAC=1000;%Initial power DAC value
FinalPowerDAC=15000;%Final power DAC value

%BuncherProbe1_operPower_AU=0.425;% Buncher cavity operational power as measured by probe 1
%PowerFeedbackGain=0.02;% Power Feedback Gain


TimeScaleCalFactor=1; %1.01769983554; %Time scale correcting factor


%Set phase frequency feedback OFF
setpv('L2llrf:freq_loop_close',0);
FdbckStatus=getpv('L2llrf:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

% Set LLRF frequency parameters
setpv('L2llrf:ddsa_phstep_h_ao',281000);
setpv('L2llrf:ddsa_phstep_l_ao',4096);
setpv('L2llrf:ddsa_modulo_ao',4);

% Set LLRF to external trigger mode
setpv('L2llrf:ext_trig_sel_bo',1);

% Check delay from external trigger not to be 0
rep_period=getpv('L2llrf:rep_period_ao')/1e5; %get delay from external trigger in ms
if rep_period < 0.00001
    setpv('L2llrf:rep_period_ao',0.0001*1e5*TimeScaleCalFactor); %set delay from external trigger
    ['****WARNING: Linac timing could be wrong. Please check it! ****']
end

setpv('L2llrf:pulse_length_ao', PulseLength_ms*1e5*TimeScaleCalFactor); % set initial pulse lenght.

%Set initial time scale
Tscale=round(PulseLength_ms/0.44)+1;
setpv('L2llrf:wave_samp_per_ao', Tscale);

%Set RF drive to start value;
PowerAmp=InitialPowerDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('L2llrf:source_re_ao',PowerReal);
setpv('L2llrf:source_im_ao',PowerImag);

%Enable linac RF PLC and reset RF monitors interlocks and buncher PLC. It does not reset the LLRF
linacRFenable(1)

%Reset LLRF (this turns the RF ON)
['Resetting the Linac LLRF (this turns the Gun RF ON)']
ii=1;
LLRFData{1}.Prefix = 'L2llrf:';
setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);

for ii=1:3    %do frequency correction (using "decay mode")
    setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
    pause(.1)
end

%Set RF drive to final value;
['Setting RF drive to final value']
NumPwstep=15;
PwStep=(FinalPowerDAC-InitialPowerDAC)/(NumPwstep-1);
for kk=1:NumPwstep
    ActDAC=InitialPowerDAC+(kk)*PwStep;
    PowerAmp=ActDAC; %Set drive power in DAC units
    PowerPhase=0;
    PowerReal=PowerAmp;
    PowerImag=PowerPhase;
    setpv('L2llrf:source_re_ao',PowerReal);
    setpv('L2llrf:source_im_ao',PowerImag);

    for ii=1:10    %do frequency correction (using "decay mode")
        setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.1)
        setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
        pause(.1)
    end
end


['Linac ramp-up completed']

    
end


