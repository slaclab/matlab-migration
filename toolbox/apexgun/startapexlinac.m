function [] = startapexlinac(power_W, Nsteps,TriggerMode, RepRate_Hz) % FS Sept. 23, 2015
% To be used for starting and bringing the Linac at the desired power level and repetition rate. 
% RepRate_Hz sets the repetition rate only when TriggerMode=0, otherwise the repettion rate is 
% set by an externally applied trigger RepRate_Hz is ignored.
% Syntax: startapexlinac(power_W, Nsteps,TriggerMode, RepRate_Hz)
% power_W: desired power in W
% Nsteps: number of steps while going from the initial duty cycle to the final one. 
% TriggerMode 0=internal trigger; any other valued set the trigger to be external
% RepRate_Hz sets the repetition rate in Hz when TriggerMode=0. Max repetition rate is 10 Hz
%

['STARTING APEX LINAC RAMP PROCEDURE']

% Function internal inputs
PulseLenght_s=14.e-6;% %DO NOT CHANGE THIS VALUE!!!!
PowerToDAC_cal_factor=15000/25.e6;% Power to DAC calibration factor
MaxPowerDAC=15000;% Klystron is saturated at this value
ZeroTimeDAC=3000; % initial DAC value
StartingDAC=ZeroTimeDAC; % initial DAC value
InitialPower=StartingDAC/PowerToDAC_cal_factor; % Initial RF power in W
InitialFPGAFreq_set=285993; % Initial FPGA setting for the gun RF frequency
FinalFPGAFreq_set=285993; % Final FPGA setting for the gun RF frequency (285993 for 1.3 GHz)
FPGAFreq_fine_set=3830;% Initial FPGA fine setting for the gun RF frequency (3830 for 1.3 GHz)
minRepRate=0.1;
maxRepRate=10; %DO NOT CHANGE THIS VALUE!!!!
minNsteps=10;

TimeScaleCalFactor=1.;% 1.02143; %Time Calibration Factor required after March 2014 LLRF upgrade.

setpv('L2llrf:mask_boundary_reset',1);
setpv('L2llrf:pulse_boundary_ao',1);

setpv('Lmon21:mask_boundary_reset',1);
setpv('Lmon21:pulse_boundary_ao',1);

setpv('Lmon22:mask_boundary_reset',1);
setpv('Lmon22:pulse_boundary_ao',1);

setpv('Lmon31:mask_boundary_reset',1);
setpv('Lmon31:pulse_boundary_ao',1);

setpv('Lmon32:mask_boundary_reset',1);
setpv('Lmon32:pulse_boundary_ao',1);

power_W=abs(power_W);% remove negative signs
PulseLenght_s=abs(PulseLenght_s);
RepRate_Hz=abs(RepRate_Hz);
Nsteps=abs(Nsteps);

FinalPowerDAC=power_W*PowerToDAC_cal_factor;
if FinalPowerDAC>MaxPowerDAC
    FinalPowerDAC=MaxPowerDAC
    power_W=FinalPowerDAC/PowerToDAC_cal_factor;
    ['WARNING: final peak power set to maximum: ',num2str(MaxPowerDAC/PowerToDAC_cal_factor),' W']
end

if TriggerMode == 0
    if RepRate_Hz<minRepRate
        RepRate_Hz=minRepRate;
        ['WARNING: Repetition rate increased to ',num2str(minRepRate),' Hz']
        pause(10)
    end
    
    if RepRate_Hz>maxRepRate
        RepRate_Hz=maxRepRate;
        ['WARNING: Repetition rate decreased to 10 kHz']
        pause(10)
    end
    
    InitialRepRate=RepRate_Hz; % Initial repetition rate in Hz
    
    ['Repetition rate in Hz: ',num2str(RepRate_Hz)]
    pause(4)
end


if Nsteps<minNsteps
    Nsteps=minNsteps;
    ['WARNING: Number of steps increased to ',num2str(Nsteps)]
    pause(10);
else
    ['Number of steps: ',num2str(Nsteps)]
    pause(4)
end

%Set phase frequency feedback OFF
setpv('L2llrf:freq_loop_close',0);
FdbckStatus=getpv('L2llrf:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

if TriggerMode ~=0
    %Set L2llrf trigger to external. Requires external trigger to be provided (13 microseconds, TTL, 10 Hz MAX)
    setpv('L2llrf:ext_trig_sel_bo',1);
    RepPeriod= 20e-9; % RF pulse delay after trigger in s. MUST BE > THAN 20 ns.
else
    %Set L2llrf trigger to internal. 
    setpv('L2llrf:ext_trig_sel_bo',0);
    RepPeriod= 1/RepRate_Hz; % RF pulse perios in s.
end

setpv('L2llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetition period or delay after trigger
setpv('L2llrf:pulse_length_ao', PulseLenght_s*1e8*TimeScaleCalFactor); % set pulse lenght.

linacRFenable(1)

% Reset Gun RF interlocks
['Resetting Linac RF interlocks']
InterlockCell= {
    'L2llrf:reset_inlk_1_bo'
    'L2llrf:reset_inlk_2_bo'
    'L2llrf:reset_inlk_3_bo'
    'L2llrf:reset_inlk_4_bo'
    'Lmon21:reset_inlk_1_bo'
    'Lmon21:reset_inlk_2_bo'
    'Lmon21:reset_inlk_3_bo'
    'Lmon21:reset_inlk_4_bo'    
    'Lmon22:reset_inlk_1_bo'
    'Lmon22:reset_inlk_2_bo'
    'Lmon22:reset_inlk_3_bo'
    'Lmon22:reset_inlk_4_bo'
    'Lmon31:reset_inlk_1_bo'
    'Lmon31:reset_inlk_2_bo'
    'Lmon31:reset_inlk_3_bo'
    'Lmon31:reset_inlk_4_bo'
    'Lmon32:reset_inlk_1_bo'
    'Lmon32:reset_inlk_2_bo'
    'Lmon32:reset_inlk_3_bo'
    'Lmon32:reset_inlk_4_bo'
};
for i = 1:length(InterlockCell)
    setpv(InterlockCell{i},1);
    pause(0.1)
    setpv(InterlockCell{i},0);
end
    

tic;

%Set RF drive to zero start value;
PowerAmp=ZeroTimeDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('L2llrf:source_re_ao',PowerReal);
setpv('L2llrf:source_im_ao',PowerImag);

%Reset LLRF (this turns the RF ON)
['Resetting the Linac LLRF (this turns the Linac RF ON)']
setpv('L2llrf:ddsa_phstep_h_ao',InitialFPGAFreq_set);% set initial frequency
setpv('L2llrf:ddsa_phstep_l_ao',FPGAFreq_fine_set); % set initial fine frequency
ii=1;
LLRFData{1}.Prefix = 'L2llrf:';
setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);

for ii=1:10    %do frequency correction (using "decay mode")
    setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
    pause(.1)
end

%Set RF drive to initial value;
['Setting RF drive to initial value']
PowerAmp=StartingDAC; %Set initial drive power in DAC units
PowerPhase=0;
PowerReal=PowerAmp;
PowerImag=PowerPhase;
setpv('L2llrf:source_re_ao',PowerReal);
setpv('L2llrf:source_im_ao',PowerImag);

for ii=1:100    %do frequency correction (using "decay mode")
    setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.1)
    setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
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

%FinalPulseLenght=PulseLenght_s;
%if CWFlag==1
%    FinalPulseLenght=PulseLenght_s*0.98;
%end

%DeltaPulse=(FinalPulseLenght-InitialPulseLength)/(Nsteps-1);
%TotalRampDuration_s=180.; % Ramp duration is s
%StepDuration_s=TotalRampDuration_s/Nsteps; %Step Duration in s
%ClickPerSecond=2.; %Number of decay frequency feedback intervention per second
%Ncycles=floor(abs(StepDuration_s*ClickPerSecond));
%for ActPulseLength=InitialPulseLength:DeltaPulse:FinalPulseLenght
    
%    setpv('L1llrf:pulse_length_ao', ActPulseLength*1e8*TimeScaleCalFactor); % set pulse lenght.
    
%    ['Present duty cycle: ',num2str(ActPulseLength/RepPeriod)]
   
 %   for ii=1:Ncycles    %do frequency correction (using "decay mode")
%        setpvonline('L1llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
%        pause(1./ClickPerSecond/2);
%        setpvonline('L1llrf:bt_do_freq_correction',0,'float',1);
%        pause(1./ClickPerSecond/2);
%   end
%    powerfeedback(InitialA3Power,0.03,0.02)

%end

%Set cavity steel heaters at the nominal operation value
%setpv('CavityHeater1:DutyCycle',13);
%setpv('CavityHeater2:DutyCycle',13);

% Ramp to final power if different from initial power
PowerImag=0;
if abs(power_W-InitialPower)>0
    DeltaPower=(power_W-InitialPower)/(Nsteps-1);
    for ActPower=InitialPower:DeltaPower:power_W
        %powerfeedback(ActA3,0.005,0.1)
        ['Present peak power: ',num2str(ActPower/1e6),' MW']
        PowerReal=ActPower*PowerToDAC_cal_factor;
        setpvonline('L2llrf:source_re_ao',PowerReal,'float',1);
        setpvonline('L2llrf:source_im_ao',PowerImag,'float',1);
        for jj=1:50
            setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
            pause(.05)
            setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
            pause(.05)
        end
    end
end

%Set phase frequency feedback ON
%setpv('L2llrf:freq_loop_close',1);
%FdbckStatus=getpv('L2llrf:freq_loop_close');
%['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

%wait for frequency feedback to settle
%['WAITING FOR FREQUENCY FEEDBACK TO SET']
%while mean(abs(getpv('L2llrf:phase_diff',1:1:120)))> 2
%    if abs(getpv('L2llrf:phase_diff'))>4 
%        if DutyCycle ~= 1
%            %do frequency correction (using "decay mode")
%            setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
%            pause(.2);
%            setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
%            pause(.2);
%         end
%    end
%end


%CWcycleduration_s=60;
%if CWFlag==1
%    PulseLenghtHelp=PulseLenght_s*.985;
%    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
%    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
%    ['Present duty cycle is 98.5%']
%    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
%    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
    
%    PulseLenghtHelp=PulseLenght_s*.99;
%    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
%    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
%    ['Present duty cycle is 99.0%']
%    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
%    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
    
%    PulseLenghtHelp=PulseLenght_s*.995;
%    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
%    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
%    ['Present duty cycle is 99.5%']
%    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
%    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
    
%    PulseLenghtHelp=PulseLenght_s;
%    setpv('L1llrf:pulse_length_ao', PulseLenghtHelp*1e8*TimeScaleCalFactor); % set pulse lenght.
%    setpv('L1llrf:rep_period_ao', RepPeriod*1e8*TimeScaleCalFactor); %set repetiton period
    
%    ['The gun is now running in CW mode']
%    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
%    while mean(abs(getpv('L1llrf:phase_diff',1:1:CWcycleduration_s)))> 2;end
%else
['Ramping Complete. Running a perpetual loop. Use Ctrl C to exit']
setpv('L2llrf:ddsa_phstep_h_ao',FinalFPGAFreq_set);% set final frequency
setpv('L2llrf:ddsa_phstep_l_ao',FPGAFreq_fine_set); % set final fine frequency
while 1
    setpvonline('L2llrf:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.2);
    setpvonline('L2llrf:bt_do_freq_correction',0,'float',1);
    pause(.2);
end
%end


end


