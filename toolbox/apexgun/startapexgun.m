function [] = startapexgun( CavityProbe1power_W, PulseLenght_s, RepRate_Hz, Nsteps) % FS Nov. 2, 2012
% To be used for starting and bringing the RF gun probe 1 at the desired power level, repetition rate and pulse lenght. 
% At completion, the function will enter a perpetual loop calling the powerfeedback function.
%
% Syntax: startapexgun( CavityProbe1power_W, PulseLenght_s, RepRate_Hz, Nsteps)
%
% CavityProbe1power_W: desired Cavity probe 1 power in W
% PulseLenght_s: final pulse duration in s (1e-4 s min; 1e-2 s max)
% RepRate_Hz: final repetition rate in Hz (10 Hz min; 10 kHz max)
% Nsteps: number of steps while going from the initial duty cycle to the final one. 
%
% WARNING: if the duty cycle (PulseLenght_s*RepRate_Hz) >= 1 the gun will be set in CW mode

['STARTING APEX GUN RAMP PROCEDURE']

% Function internal inputs

ZeroTimeDAC=1000; % initial DAC value
StartingDAC=17000; % initial DAC value
InitialPulseLength=0.98e-3; %Initial pulse length in s
InitialRepRate=1/(100.e-3); % Initial repetition rate in Hz
IntermediateRepRate=1/(10.e-3);% Intermediate rep rate in Hz
InitialCavityProbe1Power=85000; % Initial Cavity Probe RF power in W
InitialFPGAFreq_set=194000; % Initial FPGA setting for the gun RF frequency
minRepRate=10.;
maxRepRate=10000.; %DO NOT CHANGE THIS VALUE!!!!
minPulseLenght=1e-4;
maxPulseLenght=1e-2;
minNsteps=20;
MaxProbe1Power_W=95000;
CavityHeatersDutyCycle=12;

TimeScaleCalFactor=1.017699667;% 


CavityProbe1power_W=abs(CavityProbe1power_W);% remove negative signs
if CavityProbe1power_W>MaxProbe1Power_W
    CavityProbe1power_W=MaxProbe1Power_W;
    ['WARNING: cavity probe power set to ',numestr(MaxProbe1Power_W),' W']
end

PulseLenght_s=abs(PulseLenght_s);
RepRate_Hz=abs(RepRate_Hz);
Nsteps=abs(Nsteps);

%FinalProbe1Power_W=abs(CavityProbe1power_W)/39000*80000;
%MaxProbe1Power_W=abs(MaxProbe1Power_W);
%if FinalProbe1Power_W>MaxProbe1Power_W
%    FinalProbe1Power_W=MaxProbe1Power_W
%    ['WARNING: final Probe 1 power set to',num2str(MaxProbe1Power_W)]
%end

if RepRate_Hz<minRepRate
    RepRate_Hz=minRepRate;
    ['WARNING: final repetition rate increased to 10 Hz']
    pause(5)
end

if RepRate_Hz>maxRepRate
    RepRate_Hz=maxRepRate;
    ['WARNING: final repetition rate decreased to 10 kHz']
    pause(5)
end

if RepRate_Hz<InitialRepRate
    InitialRepRate=RepRate_Hz;
end

['Final repetition rate in Hz: ',num2str(RepRate_Hz)]
pause(5)

if PulseLenght_s<minPulseLenght
    PulseLenght_s=minPulseLenght;
    ['WARNING: final pulse length increased to 0.1 ms']
    pause(5)
end

if PulseLenght_s>maxPulseLenght
    PulseLenght_s=maxPulseLenght;
    ['WARNING: final pulse length decreased to 10 ms']
    pause(5)
end


if PulseLenght_s<InitialPulseLength
    PulseLenght_s=InitialPulseLength;
end
['Final pulse length in s: ',num2str(PulseLenght_s)]
pause(5)

DutyCycle=PulseLenght_s*RepRate_Hz;

CWFlag=0;
if DutyCycle>=1
   PulseLenght_s=1./RepRate_Hz;
   ['WARNING: CW MODE final state']
   CWFlag=1;
   DutyCycle=1;
   pause(5)
end



if CavityProbe1power_W<InitialCavityProbe1Power
    InitialCavityProbe1Power=CavityProbe1power_W;
end

['A3 FWD target power in W: ',num2str(CavityProbe1power_W)]
pause(4)


if Nsteps<minNsteps
    Nsteps=minNsteps;
    ['WARNING: Number of steps increased to ',num2str(Nsteps)]
    pause(10);
else
    ['Number of steps: ',num2str(Nsteps)]
    pause(4)
end

% Set cavity wall heaters
setpv('CavityHeater1:OnReq',1);
setpv('CavityHeater2:OnReq',1);
setpv('CavityHeater1:DutyCycle',CavityHeatersDutyCycle);
setpv('CavityHeater2:DutyCycle',CavityHeatersDutyCycle);

%Set phase frequency feedback OFF
setpv('llrf1:freq_loop_close',0);
FdbckStatus=getpv('llrf1:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

% Reset Gun RF interlocks and PLC (Enable gun PLC)
gunRFenable(1)

tic;

RepPeriod= 1/InitialRepRate; % repetition period in s.
setpv('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetition period
setpv('llrf1:pulse_length_ao', InitialPulseLength*1e8*TimeScaleCalFactor); % set pulse lenght.

%Set RF drive to zero start value;
PowerAmp=ZeroTimeDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('llrf1:source_re_ao',PowerReal);
setpv('llrf1:source_im_ao',PowerImag);

%Reset LLRF (this turns the RF ON)
['Resetting the Gun LLRF (this turns the Gun RF ON)']
setpv('llrf1:ddsa_phstep_h_ao',InitialFPGAFreq_set)% set initial frequency
ii=1;
LLRFData{1}.Prefix = 'llrf1:';
setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);

% multiple frequency correction by decay mode
for ii=1:30    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

%Set RF drive to initial value;
['Setting RF drive to initial value']
PowerAmp=StartingDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('llrf1:source_re_ao',PowerReal);
setpv('llrf1:source_im_ao',PowerImag);

% multiple frequency correction by decay mode
for ii=1:50    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

% multiple frequency correction by decay mode and set the cavity power to operation value
for ii=1:20    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    powerfeedback_cavityprobe(CavityProbe1power_W,0.05,0.02);
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
end

% multiple frequency correction by decay mode
for ii=1:50    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

RepPeriod= 1/IntermediateRepRate; % intermediate repetition period in s.
setpv('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set intermediate repetition period

% multiple frequency correction by decay mode
for ii=1:100    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

% multiple frequency correction by decay mode and set the cavity power to operation value
for ii=1:20    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    powerfeedback_cavityprobe(CavityProbe1power_W,0.05,0.02);
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
end

% multiple frequency correction by decay mode
for ii=1:100    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.05)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    pause(.05)
end

% Ramp to final Duty Cycle
Duty0=InitialPulseLength*IntermediateRepRate;
Duty1=0.98;
DeltaDuty=(Duty1-Duty0)/(Nsteps-1);
TotalRampDuration_s=300.; % Ramp duration is s
StepDuration_s=TotalRampDuration_s/Nsteps; %Step Duration in s
ClickPerSecond=5.; %Number of decay frequency feedback intervention per second
Ncycles=floor(abs(StepDuration_s*ClickPerSecond));
for ActDuty=Duty0:DeltaDuty:Duty1
    
    setpv('llrf1:rep_period_ao', InitialPulseLength/ActDuty*1e8*TimeScaleCalFactor); % set pulse lenght.
    
    ['Present duty cycle: ',num2str(ActDuty)]
   
    for ii=1:Ncycles    %do frequency correction (using "decay mode")
        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(1./ClickPerSecond/2);
        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
        pause(1./ClickPerSecond/2);
    end
    powerfeedback_cavityprobe(CavityProbe1power_W,0.03,0.02)
end

% Ramp to final cavity probe 1 power if different from initial cavity probe 1 power
if abs(CavityProbe1power_W-InitialCavityProbe1Power)>0
    DeltaProbe1=(CavityProbe1power_W-InitialCavityProbe1Power)/(Nsteps-1);
    for ActProbe1=InitialCavityProbe1Power:DeltaProbe1:CavityProbe1power_W
        % multiple frequency correction by decay mode
        for kk=1:5
            powerfeedback_cavityprobe(ActProbe1,0.05,0.02);
            for jj=1:18
                setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                pause(.1)
                setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
            end
        end
    end
end

%Set phase frequency feedback ON
setpv('llrf1:freq_loop_close',1);
FdbckStatus=getpv('llrf1:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

%wait for phase frequency feedback to settle
count=0;
['WAITING FOR FREQUENCY FEEDBACK TO SET']
while mean(abs(getpv('llrf1:phase_diff',1:1:30)))> 2 || count<3
    if abs(getpv('llrf1:phase_diff'))>2 
        %do frequency correction (using "decay mode")
        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.05);
        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
        pause(.05);
    end
    count=count+1;
end

RepPeriod=1./RepRate_Hz;
CWcycleduration_s=60;
if CWFlag==1
    powerfeedback_cavityprobe(CavityProbe1power_W,0.05,0.02);
    PulseLenghtHelp=PulseLenght_s*.985;
    setpv('llrf1:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['Present duty cycle is 98.5%']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('llrf1:phase_diff',1:1:CWcycleduration_s)))> 2;end
        
    powerfeedback_cavityprobe(CavityProbe1power_W,0.05,0.02);
    PulseLenghtHelp=PulseLenght_s*.99;
    setpv('llrf1:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['Present duty cycle is 99.0%']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('llrf1:phase_diff',1:1:CWcycleduration_s)))> 2;end
        
    powerfeedback_cavityprobe(CavityProbe1power_W,0.05,0.02);
    PulseLenghtHelp=PulseLenght_s*.995;
    setpv('llrf1:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period

    ['Present duty cycle is 99.5%']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('llrf1:phase_diff',1:1:CWcycleduration_s)))> 2;end

    powerfeedback_cavityprobe(CavityProbe1power_W,0.05,0.02);
    PulseLenghtHelp=PulseLenght_s;
    setpv('llrf1:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
    setpv('llrf1:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
    ['The gun is now running in CW mode']
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('llrf1:phase_diff',1:1:CWcycleduration_s)))> 2;end
end


while 1
    powerfeedback_cavityprobe(CavityProbe1power_W,0.01,0.01);
    ['Ramping complete. Running the power stability loop. Probe 1 set at: ',num2str(CavityProbe1power_W)]
end

end


