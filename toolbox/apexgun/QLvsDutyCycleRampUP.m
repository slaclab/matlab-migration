function [] = QLvsDutyCycleRampUP()
% Measure and save gun cavity loaded Q, filling time, vs duty cycle and anode temperature.
% To be used in combination with startapex or startapex_nominal.
% Enters a perpetual loop. Press Ctrl+c for interrupt.
Nsamp=30;
SampPeriod=0.5;
TimeCal_m=Nsamp*SampPeriod/60;

TimeScaleCalFactor=1.0177;%1.02143; %Time Calibration Factor required after March 2014 LLRF upgrade.

figure(51);
hline(51) = plot([0 1],[NaN NaN], '--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
xlabel('Time [min]');
ylabel('Gun Cavity Loaded Q');

figure(52);
hline(52) = plot([0 1],[NaN NaN], '--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
xlabel('Time [m]');
ylabel('Gun Cavity Filling Time [s]');

figure(53);
hline(53) = plot([0 1],[NaN NaN], '--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
xlabel('Time [m]');
ylabel('Gun Duty Cycle');

figure(54);
hline(54) = plot([0 1],[NaN NaN], '--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',3);
xlabel('Time [m]');
ylabel('Gun Anode Center Temp [deg C]');

QL=0;
Tau_s=0;
Time_min=0;
cnt=0;
lcnt=0;
PulseLenght_s=0;
PulsePeriod_s=0;
DutyCycle=0;
AnodeCenterTemp_degC=0;
while 1;
    cnt=cnt+1;
    if cnt==1
        [QL(cnt) Tau_s(cnt)]=gunQmeter(Nsamp,SampPeriod,1,0);
    else
        [QL(cnt) Tau_s(cnt)]=gunQmeter(Nsamp,SampPeriod,1,1);
    end
    
    Time_min(cnt)=(cnt-1)*TimeCal_m;
    
    % read RF pulse length and period
    PulseLenght_s(cnt)=getpv('llrf1:pulse_length_ao')/1e8/TimeScaleCalFactor;
    PulsePeriod_s(cnt)=getpv('llrf1:rep_period_ao')/1e8/TimeScaleCalFactor;
    DutyCycle(cnt)=PulseLenght_s(cnt)/PulsePeriod_s(cnt);
    
    %read Cavity anode center temperature
    AnodeCenterTemp_degC(cnt)=getpv('Gun:RF:Temp9');
    
    %figure(51);
    set(hline(51), 'XData', Time_min, 'YData', QL);

    %figure(52);
    set(hline(52), 'XData', Time_min, 'YData', Tau_s);
    
    %figure(53);
    set(hline(53), 'XData', Time_min, 'YData', DutyCycle);
    
    %figure(54);
    set(hline(54), 'XData', Time_min, 'YData', AnodeCenterTemp_degC);
        
    drawnow;
    
    lcnt=lcnt+1;
    DataGen=[lcnt Time_min(cnt) QL(cnt) Tau_s(cnt) PulseLenght_s(cnt) PulsePeriod_s(cnt) AnodeCenterTemp_degC(cnt)];

    dt=clock;
    if lcnt ==1
        dtfl=[num2str(dt(1,1)),'_',num2str(dt(1,2)),'_',num2str(dt(1,3)),'_'];
        dtfl=[dtfl,num2str(dt(1,4)),'_',num2str(dt(1,5)),'_',num2str(fix(dt(1,6)))];
        
        %[file,path] = uiputfile(FileName,'Save file name');%Save dialog box
        file=['QLvsDutyCycle_'];
        path=['/remote/apex/data/Gun/QL/'];
        FileNameGene=[file,dtfl,'.txt'];
    end
    
    fid1 = fopen([path,FileNameGene], 'a');
    % print the first line, followed by a carriage return
    if lcnt==1
        ttl='%%lcnt Time_min QL Tau_s PulseLenght_s PulsePeriod_s AnodeCenterTemp_degC';
        FirstLine=[ttl,'\n'];
        fprintf(fid1,FirstLine);
    end
    
    % print values in column order
    % seven values appear on each row of the file
    %fprintf(fid, '%e %e %e %e %e %e %e\n', DataMatrix');
    dlmwrite([path,FileNameGene],DataGen,'delimiter','\t','-append'); % output file can be read by all programs
    fclose(fid1);

end

end

