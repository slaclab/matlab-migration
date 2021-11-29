
function [MeasurementTime] = darkcurrentvsdutycycle( A3power_W, PulseLenght_s, RepRate_Hz, DutyCycleNoSteps) % FS Dec 20, 2011
% To be used for measuring the dark vs the duty cycle for a fixed RF power. 
%
%
% Syntax: darkcurrentvsdutycycle( A3power_W, PulseLenght_s, RepRate_Hz, DutyCycleNoSteps)
%
% A3power_W: desired A3 FWD power in W
% PulseLenght_s: Pulse duration in s
% RepRate_Hz: Repetition rate in s
% DutyCycleNoSteps: Number of steps from going to the initial duty cycle to CW

['STARTING DARK CURRENT VS DUTY CYCLE MEASUREMENT']


A3power_W=abs(A3power_W);
if A3power_W>58000;
    A3power_W=58000;
end
['A3 FWD target power in W: ',num2str(A3power_W)]

PulseLenght_s=abs(PulseLenght_s);% remove negative signs
RepRate_Hz=abs(RepRate_Hz);

% Fuction internal inputs

DACloopInt=15.; % Interval duration for the DAC ramp loop in s
PWfdbckAcc=1.; % A3 FWD power feedback relative accuracy. A value=1 generates a single loop in the powerfeedback function
PWfdbckGain=0.02;% A3 FWD power feedback gain
VacuumThrshld=1e-7; % Vacuum threshold in Torr
KeiAvrg=100; %Set average sample number for Keithley
KeiDelta_t=0.1; % Set interval between samples in s for Keithley
NRFSamp=10; % number of RF samples
RF_deltat=0.1; % time interval between RF samples


% Calculate initial DAC value
DACval=calcdac(A3power_W)*0.95;%call calcdac function
if DACval<5000
    InDAC=DACval;
else
    InDAC=5000;
end

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
lcnt=0;
while 1
    %set RF repetition rate;
    RepPeriod= 1/RepRate_Hz; % repetition period in s.
    DutyCycle=RepRate_Hz*PulseLenght_s; % print duty cycle
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
            setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
            pause(DACloopInt/2/finaljj)
            setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
            pause(DACloopInt/2/finaljj)
            
            while getpv('Gun:RF:Cav_Vacuum_Mon')>VacuumThrshld % check cavity vacuum
                %do frequency correction (using "decay mode")
                setpvonline('llrf1:bt_do_freq_correction',1,'float',1); % use this version for quick refresh
                pause(DACloopInt/2/finaljj)
                setpvonline('llrf1:bt_do_freq_correction',0,'float',1);
                pause(DACloopInt/2/finaljj)
                if vacuumflg==0
                    ['WARNING: waiting for vacuum pressure to decrease (< ',num2str(VacuumThrshld),' Torr)!   Presently: ',num2str(getpv('Gun:RF:Cav_Vacuum_Mon')),' Torr']
                    vacuumflg=1;
                end
            end
            
        end
    end
            
    % Start duty cycle ramp to CW
    ['START INCREASING DUTY CYCLE MEASUREMENT']
    PulseStep=(RepPeriod-PulseLenght_s)/DutyCycleNoSteps;
    for ActPulseLen=PulseLenght_s:PulseStep:RepPeriod
        vacuumflg=0;
        setpv('llrf1:pulse_length_ao', ActPulseLen*1e8); % set pulse lenght.
        setpv('llrf1:rep_period_ao', RepPeriod*1e8); %set repetiton period
        ['Actual Duty Cycle: ',num2str(ActPulseLen/RepPeriod)]
        while mean(abs(getpv('llrf1:phase_diff',1:1:30)))> 3
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
        % set Keithley range
        CurrVec=getpv('PA:1:Measure',0:KeiDelta_t:KeiDelta_t*KeiAvrg);
        CurrAvrg=1.15*abs(mean(CurrVec(find(abs(CurrVec<20e-3)))));
        KeiRngSet= ceil(log10(CurrAvrg/(2*1e-9)));
        if KeiRngSet<0
            KeiRngSet=0;
        end
        if KeiRngSet>7
            KeiRngSet=7;
            setpv('PA:1:Range',KeiRngSet);
            CurrAvrg=abs(mean(CurrVec(find(abs(CurrVec<20e-3)))));
            KeiRngSet= ceil(log10(CurrAvrg/(2*1e-9)));
        end
        setpv('PA:1:Range',KeiRngSet);
        ['Keithley Range [A]: ',num2str(2*1e-9*10^KeiRngSet)]
        pause(2)
        
        %read and average current
        CurrVct=getpv('PA:1:Measure',0:KeiDelta_t:KeiDelta_t*KeiAvrg);% Current vector
        CurrAct=mean(CurrVct(find(abs(CurrVct)<20.e-3)));% actual current
        ActDutyCycle=ActPulseLen/RepPeriod;
        NormCurr=CurrAct/ActDutyCycle;% Current normalized to duty cycle
        
        %read and average vacuum in cavity
        VacuumAvrg=mean(getpv('Gun:RF:Cav_Vacuum_Mon',0:KeiDelta_t:KeiDelta_t*KeiAvrg));% Vacuum average
        
        
        
        %read A3 FWD RF power
        ii=1;%select llrf1 FPGA board
        LLRF_Prefix='llrf1:';
        
        Wave1=0;
        Wave2=0;
        for jj=1:1:NRFSamp
            Wave1= getpvonline([LLRF_Prefix, 'w3'])/NRFSamp+Wave1;
            Wave2= getpvonline([LLRF_Prefix, 'w4'])/NRFSamp+Wave2;
            pause(RF_deltat);
        end
        
        LLRFData{ii}.Inp2.Real.Data = Wave1;
        
        LLRFData{ii}.Inp2.Imag.Data = Wave2;
        
        LLRFData{ii}.Inp2.ScaleFactor=267.5778; %Calibration Factor
        LLRFData{ii}.yscale = getpvonline([LLRF_Prefix, 'yscale']);
        y2 = LLRFData{ii}.Inp2.ScaleFactor * (LLRFData{ii}.Inp2.Real.Data/LLRFData{ii}.yscale + LLRFData{ii}.Inp2.Imag.Data/LLRFData{ii}.yscale * 1i);
        y2mag = abs(y2).^2;% Signal magnitude
        y2ph=180*angle(y2)/pi;% Signal phase
        
        LLRFData{ii}.t = getpvonline([LLRF_Prefix, 'xaxis']);  % ns (int)
        x2=LLRFData{ii}.t/1e6; %time variable in ms
        
        
        %measure the average plateaux of y2mag (A3 FWD)
        cnt=0.;
        y2avg=0.;
        y2magSize=size(y2mag);
        for jj=1:1:y2magSize(1,2)
            if y2mag(1,jj)<0.3*max(y2mag)
                y2avg=y2avg;
            else
                y2avg=y2avg+y2mag(1,jj);
                cnt=cnt+1;
            end
        end
        y2avg=y2avg/cnt;% A3 FWD average value
        Efield=sqrt(y2avg/5.e4)*19.46e6; % estimated electric field at the cathode
        
        
        % Data structure: 1) DAC value 2) A3 power [W] 3) Estimated Electric Field [V/m] 4) Current [A] 5) Norm Curr [A]
        % 6) Vacuum Average [Torr] 7) Pulse length [s]  8) Duty Cycle [Hz]   9) feedback phase error [RF deg]
        DataPoint=[ ActDAC y2avg Efield CurrAct NormCurr VacuumAvrg ActPulseLen ActPulseLen/RepPeriod abs(getpv('llrf1:phase_diff')) ];
        DataMatrix=[DataMatrix;DataPoint];
  
        setpv('PA:1:Range',5);%prepare Keithley range for next cycle

        % ****Plot data***
        lcnt=lcnt+1;
        DACvalPlt=DataMatrix(1:lcnt,1)';
        y2avgPlt=DataMatrix(1:lcnt,2)';
        EfieldPlt=DataMatrix(1:lcnt,3)';
        CurrActPlt=abs(DataMatrix(1:lcnt,4)');
        NormCurrPlt=abs(DataMatrix(1:lcnt,5)');
        VacuumPlt=DataMatrix(1:lcnt,6);
        FeedbckFlagPlt=DataMatrix(1:lcnt,9)';
        DutyCyclePlt=DataMatrix(1:lcnt,8)';
        
        figure(1);
        plot(DutyCyclePlt,FeedbckFlagPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        xlabel('DutyCycle');
        ylabel('Phase error [RF deg]');
        title('Freq. Feedback Error vs. DutyCycle');
        
        figure(2);
        plot(DutyCyclePlt,y2avgPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        xlabel('DutyCycle');
        ylabel('A3 FWD [W]');
        title('A3 FWD Power vs. Duty Cycle');
        
        figure(3);
        %semilogy(DutyCyclePlt,CurrActPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        plot(DutyCyclePlt,CurrActPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        xlabel('Duty Cycle');
        ylabel('Current [A]');
        Auxttl=(['Unnormalized current vs. Duty Cycle.']);
        title(Auxttl);
        
        figure(4);
        %semilogy(DutyCyclePlt,NormCurrPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        plot(DutyCyclePlt,NormCurrPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        xlabel('Duty Cycle');
        ylabel('Current [A]');
        title('Normalized Current vs. Duty Cycle');
        
        figure(5);
        plot(DutyCyclePlt,VacuumPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        xlabel('Duty Cycle');
        ylabel('Avg. Vacuum [Torr]');
        title('Vacuum vs. Duty Cycle');
        
        %figure(5)  ;
        %semilogy(y2avgPlt,CurrActPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        %plot(y2avgPlt,CurrActPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        %xlabel('A3 FWD Power [W]');
        %ylabel('Current [A]');
        %Auxttl=(['Unnormalized current vs. A3 FWD Power.    (' num2str(DutyCycle) ' duty cycle)']);
        %title(Auxttl);
        
        %figure(6);
        %semilogy(y2avgPlt,NormCurrPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        %plot(y2avgPlt,NormCurrPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        %xlabel('A3 FWD Power [W]');
        %ylabel('Current [A]');
        %title('Normalized Current vs. A3 FWD Power');
        
        %figure(7)  ;
        %semilogy(EfieldPlt,CurrActPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        %plot(y2avgPlt,CurrActPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        %xlabel('E field [V/m]');
        %ylabel('Current [A]');
        %Auxttl=(['Unnormalized current vs. Estimated E field at the cathode.    (' num2str(DutyCycle) ' duty cycle)']);
        %title(Auxttl);
        
        %figure(8);
        %semilogy(EfieldPlt,NormCurrPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
        %plot(y2avgPlt,NormCurrPlt,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10);
        %xlabel('E field [V/m]');
        %ylabel('Current [A]');
        %title('Normalized Current vs. vs. Estimated E field at the cathode');
        
    end 
    MeasurementDuration=toc;
    ['Measurement duration [s]: ',num2str(MeasurementDuration)]
    
    % save data
    % open a file for writing
    dt=clock;
    dtfl=[num2str(dt(1,1)),'_',num2str(dt(1,2)),'_',num2str(dt(1,3)),'_'];
    dtfl=[dtfl,num2str(dt(1,4)),'_',num2str(dt(1,5)),'_',num2str(fix(dt(1,6)))];
    FileName=['DarkCurrentVsDutyFactor_',dtfl,'.txt'];
    
    [file,path] = uiputfile(FileName,'Save file name');%Save dialog box
    fid = fopen([path,file], 'w');
    
    % print the first line, followed by a carriage return
    ttl='%%DAC_value A3powerFWD_W Efield_V_m Current_A NormCurr_A Vacuum PulseLength_s DutyCycle FdbckPhRError_RFdeg';
    FirstLine=[ttl,'\n'];
    fprintf(fid,FirstLine);
    
    % print values in column order
    % seven values appear on each row of the file
    %fprintf(fid, '%e %e %e %e %e %e %e\n', DataMatrix');
    dlmwrite([path,file],DataMatrix,'delimiter','\t','-append'); % output file can be read by all programs
    fclose(fid);
    
type([path,file]);

end

end


