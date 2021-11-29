
function [RampTime] = rampapex( A3power_W, PulseLenght_s, RepRate_Hz, Pulse2CW) % FS Dec 12, 2011
% To be used for starting and bringing the RF gun at a desired power level. 
% The function will remain in a perpetual loop calling the powerfeedback function.
%
% Syntax: rampapex( A3power_W, PulseLenght_s, RepRate_Hz, Pulse2CW )
%
% A3power_W: desired A3 FWD power in W
% PulseLenght_s: Pulse duration in s
% RepRate_Hz: Repetition rate in s
% Pulse2CW: if not zero the function ramps the power with the pulse duration PulseLenght_s 
% and repetition rate RepRate_Hz and then gradually increase the duty cycle to 1 (CW mode).
%
% WARNING: if the duty cycle (PulseLenght_s*RepRate_Hz) >= 1 the gun will be set in CW mode

['STARTING APEX GUN RAMP PROCEDURE']

if Pulse2CW~=0
    Pulse2CW=1;
    ['FROM PULSE TO RAMP MODE SELECTED']
end

A3power_W=abs(A3power_W);
if A3power_W>58000;
    A3power_W=58000;
end
['A3 FWD target power in W: ',num2str(A3power_W)]

PulseLenght_s=abs(PulseLenght_s);% remove negative signs
RepRate_Hz=abs(RepRate_Hz);

% Function internal inputs

DACloopInt=60.; % Interval duration for the DAC ramp loop in s
PWfdbckAcc=1.2; % A3 FWD power feedback relative accuracy. A value>1 generates a single loop in the powerfeedback function
PWfdbckGain=0.02;% A3 FWD power feedback gain
VacuumThrshld=1e-7; % Vacuum threshold in Torr
StartingDAC=15000; % initial DAC value

% Calculate initial DAC value
DACval=calcdac(A3power_W)*0.95;%call calcdac function
if DACval<StartingDAC
    InDAC=DACval;
else
    InDAC=StartingDAC;
end

% Set frequency feedback OFF
setpv('llrf1:freq_loop_close',0);
FdbckStatus=getpv('llrf1:freq_loop_close');
['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]

%Set RF pulse duration;
if PulseLenght_s<100*1e-6
    PulseLenght_s=100*1e-6;
    ['Pulse duration set to: ',num2str(PulseLenght)]
end
tic;
DataMatrix=[];
while 1
    %set RF repetition rate;
    RepPeriod= 1/RepRate_Hz; % repetition period in s.
    DutyCycle=RepRate_Hz*PulseLenght_s; % calculate duty cycle
    if DutyCycle>0.98
        if DutyCycle>=1
            RepRate_Hz=1/PulseLenght_s;
            RepPeriod= 1/RepRate_Hz;
            DutyCycle=1;
            Pulse2CW=0;
            ['WARNING: CW Mode']
        else
            ['Repetition rate [Hz]: ',num2str(RepRate_Hz)]
            ['Pulse lenght [s]: ',num2str(PulseLenght_s)]
            ['Duty cycle: ',num2str(DutyCycle)]
        end
        InRepPeriod=1.e-3;
        InPulseLenght=0.98e-3;
    else
        InRepPeriod=RepPeriod;
        InPulseLenght=PulseLenght_s;
        ['Repetition rate [Hz]: ',num2str(RepRate_Hz)]
        ['Pulse lenght [s]: ',num2str(PulseLenght_s)]
        ['Duty cycle: ',num2str(DutyCycle)]
    end
    setpv('llrf1:pulse_length_ao', InPulseLenght*1e8); % set pulse lenght.
    setpv('llrf1:rep_period_ao', InRepPeriod*1e8); %set repetition period


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
    
    setpv('llrf1:ddsa_phstep_h_ao',148000)% set initial frequency

    ii=1;
    LLRFData{1}.Prefix = 'llrf1:';
    setpvonline([LLRFData{ii}.Prefix, 'rf_go_bo'],1);
    
    %do frequency correction (using "decay mode")
    if DutyCycle ~= 1.    
        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
        pause(.2)
        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
    end
    
    %DAC ramping loop
    ['STARTING DAC RAMP IN PULSED MODE']
    DAC0=DACval-floor((DACval-InDAC)/1000.)*1000;
    for ActDAC=DAC0:1000:DACval
        ['Actual DAC value: ',num2str(ActDAC),'. Target value: ',num2str(DACval)]
        %set DAC
        PowerPhase=0;
        PowerReal=ActDAC;
        PowerImag=PowerPhase;
        setpv('llrf1:source_re_ao',PowerReal);
        setpv('llrf1:source_im_ao',PowerImag);
        
        %force frequency correction during loop
        vacuumflg=0;
        finaljj=abs(round(DACloopInt))*2.;
        for jj=1:1:finaljj
            %do frequency correction (using "decay mode")
            if DutyCycle ~= 1
                setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                pause(DACloopInt/2/finaljj)
                setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
                pause(DACloopInt/2/finaljj)
            end
            
            while getpv('Gun:RF:Cav_Vacuum_Mon')>VacuumThrshld % check cavity vacuum
                %do frequency correction (using "decay mode")
                if DutyCycle ~= 1
                    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                    pause(DACloopInt/2/finaljj)
                    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
                    pause(DACloopInt/2/finaljj)
                end
                if vacuumflg==0
                    ['WARNING: waiting for vacuum pressure to decrease (< ',num2str(VacuumThrshld),' Torr)!   Presently: ',num2str(getpv('Gun:RF:Cav_Vacuum_Mon')),' Torr']
                    vacuumflg=1;
                end
            end
            
        end
    end
    
    powerfeedback(A3power_W,0.01,PWfdbckGain);% correct to the proper RF output
            
    if Pulse2CW% Increase duty cycle up to CW if Pulse2CW=1
        PulseStep=(.98*RepPeriod-PulseLenght_s)/10;
        for ActPulseLen=PulseLenght_s:PulseStep:RepPeriod
            vacuumflg=0;
            setpv('llrf1:pulse_length_ao', ActPulseLen*1e8); % set pulse lenght.
            setpv('llrf1:rep_period_ao', RepPeriod*1e8); %set repetiton period
            ['Actual Duty Cycle: ',num2str(ActPulseLen/RepPeriod)]
            while mean(abs(getpv('llrf1:phase_diff',1:1:30)))> 20
                if abs(getpv('llrf1:phase_diff'))>4
                    %do frequency correction (using "decay mode")
                    setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                    pause(.1);
                    setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
                    while getpv('Gun:RF:Cav_Vacuum_Mon')>VacuumThrshld% check cavity vacuum
                        %do frequency correction (using "decay mode")
                        setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                        pause(.1)
                        setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
                        pause(.1)
                        if vacuumflg==0
                            ['WARNING: waiting for vacuum pressure to decrease (< ',num2str(VacuumThrshld),' Torr)!   Presently: ',num2str(getpv('Gun:RF:Cav_Vacuum_Mon')),' Torr']
                            vacuumflg=1;
                        end
                    end
                end
            end
        end
        PulseLenght_s=RepPeriod;
    end
    
    powerfeedback(A3power_W,0.01,PWfdbckGain);% correct to the proper RF output

    % Set frequency feedback ON
    setpv('llrf1:freq_loop_close',1);
    FdbckStatus=getpv('llrf1:freq_loop_close');
    ['Frequency Feedback (0=OFF, 1=ON): ',num2str(FdbckStatus)]
             
    %wait for frequency feedback to settle
    ['WAITING FOR FREQUENCY FEEDBACK TO SET']
    while mean(abs(getpv('llrf1:phase_diff',1:1:300)))> 2
        if abs(getpv('llrf1:phase_diff'))>4
            if DutyCycle ~= 1 
                %do frequency correction (using "decay mode")
                setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                pause(.1);
                setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
            end
        end
    end
    
    % Set final pulse length and period
    ['SETTING FINAL MODE OF OPERATION']
    %pause(120);
    if Pulse2CW
        PulseLenghtHelp=PulseLenght_s*.99;
        setpv('llrf1:pulse_length_ao', PulseLenghtHelp*1e8); % set pulse lenght.
        setpv('llrf1:rep_period_ao', RepPeriod*1e8); %set repetiton period
        pause(180);
        
        PulseLenghtHelp=PulseLenght_s*.995;
        setpv('llrf1:pulse_length_ao', PulseLenghtHelp*1e8); % set pulse lenght.
        setpv('llrf1:rep_period_ao', RepPeriod*1e8); %set repetiton period
        pause(180);
    end
    setpv('llrf1:pulse_length_ao', PulseLenght_s*1e8); % set pulse lenght.
    setpv('llrf1:rep_period_ao', RepPeriod*1e8); %set repetiton period
    
    RampTime=toc;
    ['Ramp duration [s]: ',num2str(RampTime)]
    
    % call A3 FWD power feedback'
    ['ENTERED INTO THE POWER FEEDBACK LOOP']
    InitVacuum=getpv('Gun:RF:Cav_Vacuum_Mon');
    RunInitTime=toc;
    A3PowerAct=10000;
    while getpv('Gun:RF:RSS_RFPermit_Intlk') && getpv('Gun:RF:EPS_RFPermit_Intlk') && A3PowerAct>1000
        [ FinalAccuracy, A3PowerAct, AccuracyWindow0, Gain0 ] = powerfeedback(A3power_W,PWfdbckAcc,PWfdbckGain);
    end
    
    % On fault exit and save run summary
    ['ATTENTION: FAULT!']
    RunFinalTime=toc;
    FinalVacuum=getpv('Gun:RF:Cav_Vacuum_Mon');
    % Data structure: 1) Run initial time [s] 2) Run final time [s] 3) A3 FWD power [W] 4) Initial vacuum [Torr] 5) Final vacuum [Torr] 6) Duty cycle
    DataVector=[RunInitTime RunFinalTime A3PowerAct InitVacuum FinalVacuum DutyCycle];
    DataMatrix=[DataMatrix;DataVector];
    
    dt=clock;
    dtfl=[num2str(dt(1,1)),'_',num2str(dt(1,2)),'_',num2str(dt(1,3)),'_'];
    dtfl=[dtfl,num2str(dt(1,4)),'_',num2str(dt(1,5)),'_',num2str(fix(dt(1,6)))];
    FileName=['RampAPEX_',dtfl,'.txt'];

    %[file,path] = uiputfile(FileName,'Save file name');%Save dialog box
    %fid = fopen([path,file], 'w');
    fid = fopen(FileName, 'w');

    % print the first line, followed by a carriage return
    ttl='%%RunInitTime RunFinalTime A3PowerAct InitVacuum FinalVacuum DutyCycle]';
    FirstLine=[ttl,'\n'];
    fprintf(fid,FirstLine);

    % print values in column order
    % seven values appear on each row of the file
    %fprintf(fid, '%e %e %e %e %e %e %e\n', DataMatrix');
    dlmwrite(FileName,DataMatrix,'delimiter','\t','-append'); % output file can be read by all programs
    fclose(fid);

    %type([path,file]);
    type(FileName);
end

end


