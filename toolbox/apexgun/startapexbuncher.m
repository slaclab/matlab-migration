function [] = startapexbuncher(power_W, PulseLenght_s, RepRate_Hz, Nsteps) % FS Sept. 23, 2015
% To be used for starting and bringing the RF buncher at the desired power level, repetition rate and pulse lenght. 
%
% Syntax: startabuncher(power_W, PulseLenght_s, RepRate_Hz, Nsteps)
%
% power_W: desired power in W
% PulseLenght_s: final pulse duration in s (1e-4 s min; 1e-2 s max)
% RepRate_Hz: final repetition rate in Hz (100 Hz min; 10 kHz max)
% Nsteps: number of steps while going from the initial duty cycle to the final one. 
%
% WARNING: if the duty cycle (PulseLenght_s*RepRate_Hz) >= 1 the buncher will be set in CW mode

['STARTING APEX BUNCHER RAMP PROCEDURE']

% Function internal inputs

PowerToDAC_cal_factor=26480/1850;% Power to DAC calibration factor
ZeroTimeDAC=3000; % initial DAC value
StartingDAC=ZeroTimeDAC; % initial DAC value
InitialPulseLength=1e-4; %Initial pulse length in s
InitialRepRate=1.e3; % Initial repetition rate in Hz
InitialPower=StartingDAC/PowerToDAC_cal_factor; % Initial RF power in W
InitialFPGAFreq_set=285300; % Initial FPGA setting for the gun RF frequency
FinalFPGAFreq_set=285993; % Final FPGA setting for the gun RF frequency (285993 for 1.3 GHz)
%FPGAFreq_fine_set=3830;% Initial FPGA fine setting for the gun RF frequency (3830 for 1.3 GHz)
FPGAFreq_fine_set=4092;% Initial FPGA fine setting for the gun RF frequency (3830 for 1.3 GHz)

minRepRate=10.;
maxRepRate=10000.; %DO NOT CHANGE THIS VALUE!!!!
minPulseLenght_s=1e-4;
maxPulseLenght_s=1e-1;
minNsteps=10;
PowerToDAC_cal_factor=26480/1850;% Power to DAC calibration factor
% MaxProbe1Power_W=90000;

TimeScaleCalFactor=1.;% 1.02143; %Time Calibration Factor required after March 2014 LLRF upgrade.


power_W=abs(power_W);% remove negative signs
PulseLenght_s=abs(PulseLenght_s);
RepRate_Hz=abs(RepRate_Hz);
Nsteps=abs(Nsteps);

FinalPowerDAC=power_W*PowerToDAC_cal_factor;
MaxPowerDAC=32767;
if FinalPowerDAC>MaxPowerDAC
    FinalPowerDAC=MaxPowerDAC
    ['WARNING: final peak power set to maximum: ',num2str(MaxPowerDAC/PowerToDAC_cal_factor),' W']
end

if RepRate_Hz<minRepRate
    RepRate_Hz=minRepRate;
    ['WARNING: final repetition rate increased to ',num2str(minRepRate),' Hz']
    pause(10)
end

if RepRate_Hz>maxRepRate
    RepRate_Hz=maxRepRate;
    ['WARNING: final repetition rate decreased to ',num2str(maxRepRate),' Hz']
    pause(10)
end

if RepRate_Hz<InitialRepRate
    InitialRepRate=RepRate_Hz;
end

['Final repetition rate in Hz: ',num2str(RepRate_Hz)]
pause(4)

if PulseLenght_s<minPulseLenght_s
    PulseLenght_s=minPulseLenght_s;
    ['WARNING: final pulse length increased to ',num2str(minPulseLenght_s),' s']
    pause(10)
end

if PulseLenght_s>maxPulseLenght_s
    PulseLenght_s=maxPulseLenght_s;
    ['WARNING: final pulse length decreased to ',num2str(maxPulseLenght_s),' s']
    pause(10)
end

CWFlag=0;
if RepRate_Hz*PulseLenght_s>=1
   PulseLenght_s=1./RepRate_Hz;
   ['WARNING: CW MODE final state']
   CWFlag=1;
   pause(10)
end

if PulseLenght_s<InitialPulseLength
    PulseLenght_s=InitialPulseLength;
end
['Final pulse length in s: ',num2str(PulseLenght_s)]
pause(4)



%if power_W<InitialA3Power
%    InitialA3Power=power_W;
%end

%['A3 FWD target power in W: ',num2str(power_W)]
%pause(4)


if Nsteps<minNsteps
    Nsteps=minNsteps;
    ['WARNING: Number of steps increased to ',num2str(Nsteps)]
    pause(10);
else
    ['Number of steps: ',num2str(Nsteps)]
    pause(4)
end

%Set phase frequency feedback OFF
setpv('L1llrf:freq_loop_close',0);
FdbckStatus=getpv('L1llrf:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

%Set L1llrf trigger to internal
setpv('L1llrf:ext_trig_sel_bo',0);

RepPeriod= 1/InitialRepRate; % repetition period in s.
setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetition period
setpv('L1llrf:pulse_length_ao', InitialPulseLength*1e8*TimeScaleCalFactor); % set pulse lenght.

% Reset Gun RF interlocks
['Resetting Buncher RF interlocks']
InterlockCell= {
    'L1llrf:reset_inlk_1_bo'
    'L1llrf:reset_inlk_2_bo'
    'L1llrf:reset_inlk_3_bo'
    'L1llrf:reset_inlk_4_bo'
    'Lmon11:reset_inlk_1_bo'
    'Lmon11:reset_inlk_2_bo'
    'Lmon11:reset_inlk_3_bo'
    'Lmon11:reset_inlk_4_bo'
};
for i = 1:length(InterlockCell)
    setpv(InterlockCell{i},1);
    pause(0.1)
    setpv(InterlockCell{i},0);
end
    
%['Resetting Gun PLC']
%while  ~(getpv('Gun:RF:EPS_RFPermit_Intlk') && getpv('Gun:RF:RSS_RFPermit_Intlk'))
%    setpv('Gun:RF:InterlockReset',1);
%    pause(1.);
%    setpv('Gun:RF:InterlockReset',0);
%end


tic;

%Set RF drive to zero start value;
PowerAmp=ZeroTimeDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('L1llrf:source_re_ao',PowerReal);
setpv('L1llrf:source_im_ao',PowerImag);

% Set triggers for Matlab application
setpv('L1llrf:pulse_boundary_ao',2);
setpv('Lmon11:pulse_boundary_ao',2);
setpv('Lmon12:pulse_boundary_ao',2);


%Reset LLRF (this turns the RF ON)
['Resetting the Buncher LLRF (this turns the Buncher RF ON)']
setpv('L1llrf:ddsa_phstep_h_ao',InitialFPGAFreq_set);% set initial frequency
setpv('L1llrf:ddsa_phstep_l_ao',FPGAFreq_fine_set); % set initial fine frequency
ii=1;
LLRFData{1}.Prefix = 'L1llrf:';
setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);

for ii=1:10    %do frequency correction (using "decay mode")
    setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
    pause(.1)
end

%Set RF drive to initial value;
['Setting RF drive to initial value']
PowerAmp=StartingDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('L1llrf:source_re_ao',PowerReal);
setpv('L1llrf:source_im_ao',PowerImag);

for ii=1:100    %do frequency correction (using "decay mode")
    setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
    pause(.1)
end


%for ii=1:10    %do frequency correction (using "decay mode")
%    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
%    powerfeedback(InitialA3Power,0.05,0.02);
%    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
%end

%for ii=1:100    %do frequency correction (using "decay mode")
%    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
%    pause(.1)
%    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
%end

FinalPulseLenght=PulseLenght_s;
if CWFlag==1
    FinalPulseLenght=PulseLenght_s*0.98;
end

DeltaPulse=(FinalPulseLenght-InitialPulseLength)/(Nsteps-1);
TotalRampDuration_s=60.; % Ramp duration is s
StepDuration_s=TotalRampDuration_s/Nsteps; %Step Duration in s
ClickPerSecond=5.; %Number of decay frequency feedback intervention per second
Ncycles=floor(abs(StepDuration_s*ClickPerSecond));
for ActPulseLength=InitialPulseLength:DeltaPulse:FinalPulseLenght
    
    setpv('L1llrf:pulse_length_ao', ActPulseLength*1e8*TimeScaleCalFactor); % set pulse lenght.
    
    ['Present duty cycle: ',num2str(ActPulseLength/RepPeriod)]
   
    for ii=1:Ncycles    %do frequency correction (using "decay mode")
        setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(1./ClickPerSecond/2);
        setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
        pause(1./ClickPerSecond/2);
   end
%    powerfeedback(InitialA3Power,0.03,0.02)

end

%Set cavity steel heaters at the nominal operation value
%setpv('CavityHeater1:DutyCycle',13);
%setpv('CavityHeater2:DutyCycle',13);

% Ramp to final power if different from initial power
PowerImag=0;
if abs(power_W-InitialPower)>0
    DeltaPower=(power_W-InitialPower)/(Nsteps-1);
    for ActPower=InitialPower:DeltaPower:power_W
        %powerfeedback(ActA3,0.005,0.1)
        ['Present peak power: ',num2str(ActPower),' W']
        PowerReal=ActPower*PowerToDAC_cal_factor;
        setpvonline('L1llrf:source_re_ao',PowerReal,'float',1);
        setpvonline('L1llrf:source_im_ao',PowerImag,'float',1);
        for jj=1:90
            setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
            pause(.15)
            setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
            pause(.15)
        end
    end
end

%Set phase frequency feedback ON
setpv('L1llrf:freq_loop_close',1);
FdbckStatus=getpv('L1llrf:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

%wait for frequency feedback to settle
%['WAITING FOR FREQUENCY FEEDBACK TO SET']
%while mean(abs(getpv('L1llrf:phase_diff',1:1:120)))> 2
%    if abs(getpv('L1llrf:phase_diff'))>4 
%        if DutyCycle ~= 1
%            %do frequency correction (using "decay mode")
%            setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
%            pause(.2);
%            setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
%            pause(.2);
%    end
%end


CWcycleduration_s=60;
if CWFlag==1
    PulseLenghtHelp=PulseLenght_s*.985;
    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['Present duty cycle is 98.5%']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
    
    PulseLenghtHelp=PulseLenght_s*.99;
    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['Present duty cycle is 99.0%']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
    
    PulseLenghtHelp=PulseLenght_s*.995;
    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['Present duty cycle is 99.5%']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
    
    PulseLenghtHelp=PulseLenght_s;
    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['The gun is now running in CW mode']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
else
    ['Ramping Complete. Running a perpetual loop. Use Ctrl C to exit']
    while 1 
        setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.2);
        setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
        pause(.2);
   end
end

['Ramping complete. Running the power stability loop. Probe 1 set at: ',num2str(FinalPowerDAC)]
while 1
%    powerfeedback_cavityprobe(FinalPowerDAC,0.01,0.01);
end

end


