function [] = gunRFphasefeedback(llrffeedbackflag) % FS April 18, 2014 
% Set the gun RF phase at the "zero" target value.
% Sintax:gunRFphasefeedback(llrffeedbackflag).
% PGain sets the feedback proportional gain
% IGain sets the feedback integral gain
% llrffeedbackflag must be set to 0 when the MatLab gun RF amplitude feedback is used and to 1 if the llrf amplitude/phase feedback is used.
% The functions enters in a perpetual loop that can be interrupted by Ctrl+c.


if llrffeedbackflag==0
    PGain=2;% Proportional gain Aug 11,2016
    IGain=0.002;% Integral gain Aug 11,2016
else
    %PGain=0.02;% Proportional gain
    %IGain=0.0002;% Integral gain
    PGain=0.1;% Proportional gain
    PGain=0.5;% Proportional gain
    IGain=0.00002;% Integral gain
    IGain=0.0002;% Integral gain
end

%PGain=0.001;% Proportional gain Daniele
%IGain=0.0001;% Integral gain Daniele


RF_Phase_deg=0;% set phase target value. Must be zero!
BufferSize=1;%set the size of the buffer for the signal integral calculation
BufferBinDuration_s=.05;%set the deltat is seconds between points in the buffer. Also sets the duration fo each loop calculation.
settunecycle=40;% applies correction every setttunecycle number of cycles

GunTunerCal=19.1; %Calibration factor the gun tuner in Hz/Newton. R. Wells measurements in 2013.
CavityQL=13380; %Cavity loaded Q
RFfreq_Hz=1.3e9/7; % Gun nominal RF frequency
FreqToPhase_RFdeg=-180/pi*atan(2*CavityQL/RFfreq_Hz);%RF phase variation in deg for 1 Hz frequency variation
PhaseToForceCl_N=1/GunTunerCal/FreqToPhase_RFdeg;%RF Phase in RF deg to force in N calibration.
MaxDeltaSet=200.; % Max tuner delta pressure in Newton
TunerReadingPause=0.000; % Sampling period [s]
NSampTuner=1; % Number of sample for gun tuner pressure reading
TunerAlignTolerance=20; % Tuner read/set accuracy in Newton (MUST BE POSITIVE)

% set Gun RF frequency at 1300/7 GHz
setpv('llrf1:ddsa_phstep_l_ao',744);
setpv('llrf1:ddsa_modulo_ao',4);
ddsa_h=getpv('llrf1:ddsa_phstep_h_ao'); 
ddsa_diff=ddsa_h-190650;
ddsa_step=abs(ddsa_diff)/ddsa_diff;
if ddsa_diff ~=0
    for ddsa_act=ddsa_h:ddsa_step:190650
        setpv('llrf1:ddsa_phstep_h_ao',ddsa_act);
        ['Adjusting gun frequency']
        pause(3);
    end
end
    
%Set cavity tuner mode.
%setpvonline('CavityTuner:ModeReq',2,'float',1);% Motor only mode
setpvonline('CavityTuner:ModeReq',3,'float',1);% Motor+piezo mode
setpvonline('CavityTuner:LoadReq.OMSL',0,'float',1);% Tuner in supervisory mode (PLC feedback open)


%Check if Tuner set and readback values are aligned. If not wait.
TunerSet_hlp =getpv('CavityTuner:LoadReq');
TunerRead_hlp=getpv('CavityTuner:LoadAvg');
ifhlp2=abs(TunerSet_hlp-TunerRead_hlp);
while ifhlp2 > TunerAlignTolerance % wait for tuner force set and read to align
    TunerSet_hlp =getpv('CavityTuner:LoadReq');
    TunerRead_hlp=getpv('CavityTuner:LoadAvg');
    ifhlp2=abs(TunerSet_hlp-TunerRead_hlp);
    pause(TunerReadingPause)
    ['Waiting for gun tuner to align']
end

['ENTERING GUN PHASE FEEDBACK']

%Switch OFF LLRF1 Phase Diff Frequency Feedback.
setpvonline('llrf1:freq_loop_close',0,'float',1);

SignalBuffer=zeros(BufferSize,1);

%Enters a perpetual loop.
loopind=1;
IntPhase=0;
hlpcnt=1;
while loopind==1
    pause(BufferBinDuration_s)  
    
	%read phase diff
	Phase_diff= getpvonline('llrf1:phase_diff');
    
    % if phase control is lost go to emergency recovery routine
    if abs(Phase_diff) >25
        Emergencygunrftuningrecovery(llrffeedbackflag)
    end
    
    SignalBuffer(BufferSize+1)=Phase_diff;
    SignalBuffer=SignalBuffer(2:BufferSize+1);
    Integ_diff=sum(SignalBuffer)*BufferBinDuration_s;
    
    IntPhase=IntPhase+Phase_diff*BufferBinDuration_s;
    
%    TotalPhaseDiff=PGain*Phase_diff+IGain*Integ_diff;
    TotalPhaseDiff=PGain*Phase_diff+IGain*IntPhase;
    

	%read cavity tuner pressure
	TunerRead_N=0;
	for jj=1:NSampTuner
        %TunerRead_N= TunerRead_N+getpv('CavityTuner:LoadAvg')/NSampTuner;
        TunerRead_N= TunerRead_N+getpv('CavityTuner:LoadReq')/NSampTuner;
        pause(TunerReadingPause)
    end
        
	% Calculate new tuner pressure
	DeltaPhase_RFdeg=(TotalPhaseDiff-RF_Phase_deg);
	DeltaSet_N=DeltaPhase_RFdeg*PhaseToForceCl_N;
	if DeltaSet_N>MaxDeltaSet
        DeltaSet_N=MaxDeltaSet;
    end
	if DeltaSet_N<-MaxDeltaSet
        DeltaSet_N=-MaxDeltaSet;
    end
        
	NewTunerSet_N = TunerRead_N+DeltaSet_N;
          
    MaxTunerSet_N=4500;
    if NewTunerSet_N > MaxTunerSet_N
        NewTunerSet_N = MaxTunerSet_N;
    end
    
    MinTunerSet=100;
    if NewTunerSet_N < MinTunerSet
        NewTunerSet_N = MinTunerSet;
    end
    
    
    % Set Tuner
    if hlpcnt >= settunecycle
        setpvonline('CavityTuner:LoadReq',NewTunerSet_N,'float',1);% fast writing option
        hlpcnt=1;
        DeltaSet_N
        NewTunerSet_N
    end
    
    hlpcnt=hlpcnt+1;
    
    TunerSet_hlp =getpv('CavityTuner:LoadReq');
    TunerRead_hlp=getpv('CavityTuner:LoadAvg');
    ifhlp2=abs(TunerSet_hlp-TunerRead_hlp);
    while ifhlp2 > TunerAlignTolerance % wait for tuner force set and read to align
        TunerSet_hlp =getpv('CavityTuner:LoadReq');
        TunerRead_hlp=getpv('CavityTuner:LoadAvg');
        ifhlp2=abs(TunerSet_hlp-TunerRead_hlp);
        pause(TunerReadingPause)
        Phase_diff= getpvonline('llrf1:phase_diff');
        if abs(Phase_diff) >10
            ifhlp2=0;
        end
    end
    
    %open laser loop
    laserflag=abs(getpv('llrf1:laser_freq'));
    %lasergain=getpv('llrf1:laser3_kp_ao');
    %if laserflag>2 && lasergain ~= 0
    %    openlaserloop
    %end
      
end  
    
end


