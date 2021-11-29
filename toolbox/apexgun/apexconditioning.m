function [] = apexconditioning( InitialA3power_W, FinalA3power_W, PulseLenght_s, RepRate_Hz ) %FS Dec. 19, 2011
% To be used for RF conditioning the RF gun from to desired power levels. 
% The function will remain in a perpetual loop calling the powerfeedback function.
% and will restart if a fault happens.
%
% Syntax: rampapex( InitialA3power_W, FinalA3power_W,PulseLenght_s, RepRate_Hz )
%
% InitialA3power_W: desired initial A3 FWD power in W
% FinalA3power_W: desired final A3 FWD power in W
% PulseLenght_s: Pulse duration in s
% RepRate_Hz: Repetition rate in s
%
% WARNING: CW mode not allowed with this function!
% If the duty cycle (PulseLenght_s*RepRate_Hz) >= 1 the gun will be forved in 0.98 duty cycle (0.98 ms 1 kHz)


['STARTING APEX GUN CONDITIONING PROCEDURE']


InitialA3power_W=abs(InitialA3power_W);
FinalA3power_W=abs(FinalA3power_W);
if FinalA3power_W>58000;
    FinalA3power_W=58000;
end
if InitialA3power_W>58000;
    InitialA3power_W=58000;
end
if FinalA3power_W<InitialA3power_W
    FinalA3power_W=InitialA3power_W
end
['Initial A3 FWD power in W: ',num2str(InitialA3power_W)]
['Target A3 FWD power in W: ',num2str(FinalA3power_W)]

PulseLenght_s=abs(PulseLenght_s);% remove negative signs
RepRate_Hz=abs(RepRate_Hz);

% Fuction internal inputs

DACstep=10.; % DAC increase step
PWfdbckAcc=1.; % A3 FWD power feedback relative accuracy. A value=1 generates a single loop in the powerfeedback function
PWfdbckGain=0.02;% A3 FWD power feedback gain
VacuumThrshld=1e-7; % Vacuum threshold in Torr

% Calculate initial DAC value
InDAC=calcdac(InitialA3power_W)*0.95;%call calcdac function

% Calculate final DAC value
FinalDAC=calcdac(FinalA3power_W)*0.95;%call calcdac function

% Set frequency feedback ON
setpv('llrf1:freq_loop_close',1);
FdbckStatus=getpv('llrf1:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

%Set RF pulse duration;
if PulseLenght_s<100*1e-6
    PulseLenght_s=100*1e-6;
end
tic;
DataMatrix=[];
RunCnt=0;
while 1
    %set RF repetition rate;
    RepPeriod= 1/RepRate_Hz; % repetition period in s.
    DutyCycle=RepRate_Hz*PulseLenght_s; % print duty cycle
    if DutyCycle>0.98
        PulseLenght_s=0.98e-3;
        RepRate_Hz=1.e3;
        RepPeriod= 1/RepRate_Hz;
        DutyCycle=0.98;
        ['WARNING: Forced to 0.98 duty cycle (0.98 ms 1 kHz)']
    else
        ['Repetition rate [Hz]: ',num2str(RepRate_Hz)]
        ['Pulse lenght [s]: ',num2str(PulseLenght_s)]
        ['Duty cycle: ',num2str(DutyCycle)]
    end
    InRepPeriod=RepPeriod;
    InPulseLenght=PulseLenght_s;

    setpv('llrf1:pulse_length_ao', InPulseLenght*1e8); % set pulse lenght.
    setpv('llrf1:rep_period_ao', InRepPeriod*1e8); %set repetiton period


    %Set RF drive to initial value;
    PowerAmp=InDAC; %Set drive power in DAC units (max is 32768)
    PowerPhase=0;
    PowerReal=PowerAmp;
    PowerImag=PowerPhase;
    setpv('llrf1:source_re_ao',PowerReal);
    setpv('llrf1:source_im_ao',PowerImag);
    
    %Reset PLC;
    while  ~(getpv('Gun:RF:EPS_RFPermit_Intlk') && getpv('Gun:RF:RSS_RFPermit_Intlk'))
        setpv('Gun:RF:InterlockReset',1);
        pause(1.);
        setpv('Gun:RF:InterlockReset',0);
    end
    
    %Reset LLRF (this turns the RF ON)
    ii=1;
    LLRFData{1}.Prefix = 'llrf1:';
    setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);
    
    setpv('llrf1:ddsa_phstep_h_ao',148000)% set initial frequency

    %do frequency correction (using "decay mode")
    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
    pause(.2)
    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    
    %DAC ramping loop
    ['STARTING DAC RAMP IN PULSED MODE']
    for ActDAC=InDAC:DACstep:FinalDAC
        ['Actual DAC value: ',num2str(ActDAC),'. Target value: ',num2str(FinalDAC)]
        %set DAC
        PowerPhase=0;
        PowerReal=ActDAC;
        PowerImag=PowerPhase;
        setpv('llrf1:source_re_ao',PowerReal);
        setpv('llrf1:source_im_ao',PowerImag);
        pause(1);
        %force frequency correction during loop
        vacuumflg=0;
        %do frequency correction (using "decay mode")
        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.2)
        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);

            
        while getpv('Gun:RF:Cav_Vacuum_Mon')>VacuumThrshld % check cavity vacuum
            %do frequency correction (using "decay mode")
            setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
            pause(.1)
            setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
            if vacuumflg==0
               ['WARNING: waiting for vacuum pressure to decrease (< ',num2str(VacuumThrshld),' Torr)!   Presently: ',num2str(getpv('Gun:RF:Cav_Vacuum_Mon')),' Torr']
               vacuumflg=1;
            end
        end 
    end
            
    %wait for frequency feedback to settle
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('llrf1:phase_diff',1:1:120)))> 2
        if abs(getpv('llrf1:phase_diff'))>4
            %do frequency correction (using "decay mode")
            setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
            pause(.1);
            setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
        end
    end
    
    RampTime=toc;
    ['Conditioning duration [s]: ',num2str(RampTime)]
    
    % call A3 FWD power feedback'
    ['ENTERED INTO THE POWER FEEDBACK LOOP']
    InitVacuum=getpv('Gun:RF:Cav_Vacuum_Mon');
    RunInitTime=toc;
    while getpv('Gun:RF:RSS_RFPermit_Intlk') && getpv('Gun:RF:EPS_RFPermit_Intlk')
        [ FinalAccuracy, FinalA3power_W, AccuracyWindow0, Gain0 ] = powerfeedback(A3power_W,PWfdbckAcc,PWfdbckGain);
    end
    
    % On fault exit and save run summary
    ['ATTENTION: FAULT!']
    RunFinalTime=toc;
    FinalVacuum=getpv('Gun:RF:Cav_Vacuum_Mon');
    % Data structure: 1) Run initial time [s] 2) Run final time [s] 3) Initial vacuum [Torr] 4) Final vacuum [Torr] 5) Duty cycle
    DataVector=[RunInitTime RunFinalTime InitVacuum FinalVacuum DutyCycle];
    DataMatrix=[DataMatrix;DataVector];
    [ 'Data structure: 1) Run initial time [s] 2) Run final time [s] 3) Initial vacuum [Torr] 4) Final vacuum [Torr] 5) Duty ycle']
    
    RunCnt=RunCnt+1;
    dt=clock;
    dtfl=[num2str(dt(1,1)),'_',num2str(dt(1,2)),'_',num2str(dt(1,3)),'_'];
    dtfl=[dtfl,num2str(dt(1,4)),'_',num2str(dt(1,5)),'_',num2str(fix(dt(1,6)))];
    FileName=['RFConditioning_',dtfl,'.txt'];

    %[file,path] = uiputfile(FileName,'Save file name');%Save dialog box
    %fid = fopen([path,file], 'w');
    fid = fopen(FileName, 'w');

    % print the first line, followed by a carriage return
    ttl='%%RunInitTime RunFinalTime InitVacuum FinalVacuum DutyCycle';
    FirstLine=[ttl,'\n'];
    fprintf(fid,FirstLine);

    % print values in column order
    % seven values appear on each row of the file
    %fprintf(fid, '%e %e %e %e %e %e %e\n', DataMatrix');
    dlmwrite([path,file],DataMatrix,'delimiter','\t','-append'); % output file can be read by all programs
    fclose(fid);

    %type([path,file]);
    type(FileName);
end



end

