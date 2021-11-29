cd ~

    
clear  phase_cavity_signal_1A phase_cavity_signal_2A heater_1A heater_2A cavity_1_temp cavity_2_temp cavity_1_tempA cavity_2_tempA tsA tsB tsC tsD resynchSave cav1FBgain cav2FBgain bpm_current

%save(datestr(now, 0));

[phase_cavity_signal_1, ts] = lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
[phase_cavity_signal_2, ts] = lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
t1=linspace(0,4096,numel(phase_cavity_signal_1));
t2=linspace(0,4096,numel(phase_cavity_signal_2));


[cavity_1_temp, ts] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
[cavity_2_temp, ts] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
%t3=linspace(0,1000,numel(cavity_1_temp));
%t4=linspace(0,1000,numel(cavity_2_temp));

%{
figure(1);
plot(t1,phase_cavity_signal_1 );
ylabel('Signal');
xlabel('time');
title('Phase Cavity 1');

figure(2);
plot(t2,phase_cavity_signal_2 );
ylabel('Signal');
xlabel('time');
title('Phase Cavity 2');
%}


resynchSave = lcaGet('SIOC:SYS0:ML00:AO747'); %status of resync (on or off)
cav1FBgain = lcaGet('SIOC:SYS0:ML00:AO761'); %Cavity 1 feedback gain
cav2FBgain = lcaGet('SIOC:SYS0:ML00:AO773'); %Cavity 2 feedback gain

lcaPut('SIOC:SYS0:ML00:AO761',0); %turn off feedback gain cavity 1
lcaPut('SIOC:SYS0:ML00:AO773',0); %turn off feedback gain cavity 2
lcaPut('SIOC:SYS0:ML00:AO747',1000); %turn off resynch

%resynchSave = lcaGet('SIOC:SYS0:ML00:AO747'); %status of resynch (on or off)
while resynchSave ~= 1000
    lcaPut('SIOC:SYS0:ML00:AO747',1000); %turn off rescynch
    disp(sprintf('Please wait while resynch is disabled.,resynch = %d', resynchSave));
end


cav1FBgain = lcaGet('SIOC:SYS0:ML00:AO761'); %Cavity 1 feedback gain status
while cav1FBgain ~= 0
    disp(sprintf('Please wait while feedback gain is disabled.,cav1FBgain = %d', cav1FBgain));    
    cav1FBgain = lcaPut('SIOC:SYS0:ML00:AO761',0); %turn off feedback gain cavity 1

end


cav2FBgain = lcaGet('SIOC:SYS0:ML00:AO773'); %Cavity 2 feedback gain status
while cav2FBgain ~= 0
    disp(sprintf('Please wait while feedback gain is disabled.,cav2FBgain = %d', cav2FBgain'));
    cav2FBgain = lcaPut('SIOC:SYS0:ML00:AO773',0); %turn off feedback gain cavity 2
end

tstart = now;
j=0;
while now < tstart + 10/60/60/24 %wait ten seconds
    j = j+1;
    
    [phase_cavity_signal_1A(j,:),tsA(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
    [phase_cavity_signal_2A(j,:), tsB(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
    
    [cavity_1_tempA(j), tsC(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
    [cavity_2_tempA(j), tsD(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
    figure(1);
    ts = lca2matlabTime(tsC);
    plot(ts, cavity_1_tempA,ts, cavity_2_tempA); 
    datetick('x', 13);
    ylabel('Temperature (degrees C)');
    xlabel('Time');
    title('Cavity Temperature');
    
    heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
    heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
    bpm_currentA(j) = lcaGet ('BPMS:DMP1:398:TMIT1H');
    
    pause (1);
end

try
    
lcaPut('UND:R02:IOC:16:Cavity1:HeaterOn',1); % Turn cavity 1 heater ON
disp(sprintf('Heating cavity 1...'));

%{
tstart = now;
while now < tstart + 30/60/24 %heat for 30 minutes
    j = j+1;
    phase_cavity_signal_1A(j,:)= lcaGet('UND:R02:IOC:16:dig1:WAV1',1000); %phase cavity 1; RAW WAVEFORM
    phase_cavity_signal_2A(j,:)= lcaGet('UND:R02:IOC:16:dig1:WAV2',1000); %phase cavity 2; RAW WAVEFORM
    figure(1);
    plot(t1,phase_cavity_signal_1 );
    ylabel('Signal');
    xlabel('time');
    title('Phase Cavity 1');

    figure(2);
    plot(t2,phase_cavity_signal_2 );
    ylabel('Signal');
    xlabel('time');
    title('Phase Cavity 2');
    
    cavity_1_tempA(j) = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
    cavity_2_tempA(j) = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
    
    heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
    heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
    pause (1);
end
%}

cavity_1_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
while cavity_1_temp < 28.9000
    if lcaGet('SIOC:SYS0:ML01:AO989') == 0
        error('script aborted')
    end
    cavity_1_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
    
    if cavity_1_temp >28.8000
    lcaPut('UND:R02:IOC:16:Cavity1:HeaterOn',0); %cavity 1 heater OFF
    heater_1 = lcaGet('UND:R02:IOC:16:Cavity1:HeaterOn');
    disp(sprintf('Heater 1 = %s', heater_1{1}));
    break
    
    else
         tstart = now;
        while now < tstart + 1/60/60/24 %if temperature is less than 28.8 degrees C, heat 1 more second
            j = j+1;
            [phase_cavity_signal_1A(j,:), tsA(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
            [phase_cavity_signal_2A(j,:), tsB(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
            
            [cavity_1_tempA(j), tsC(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
            [cavity_2_tempA(j), tsD(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
            figure(1);
            ts = lca2matlabTime(tsC);
            plot(ts, cavity_1_tempA,ts, cavity_2_tempA);  
            datetick('x', 13);
            ylabel('Temperature (degrees C)');
            xlabel('Time');
            title('Cavity Temperature');
            
            
            heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
            heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
            bpm_currentA(j) = lcaGet ('BPMS:DMP1:398:TMIT1H');
            
            pause (1);
        end

    end
end

cavity_1_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
while cavity_1_temp > 19.8000
    if lcaGet('SIOC:SYS0:ML01:AO989') == 0
        error('script aborted')
    end
    cavity_1_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
    if cavity_1_temp > 19.8000
        disp(sprintf('Cavity 1 cooling...')); 
        tstart = now;
        while now < tstart + 2/60/60/24 %wait two more seconds for cavity to cool
            j = j+1;
            [phase_cavity_signal_1A(j,:), tsA(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
            [phase_cavity_signal_2A(j,:), tsB(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
            
            [cavity_1_tempA(j), tsC(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
            [cavity_2_tempA(j), tsD(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
            figure(1);
            ts = lca2matlabTime(tsC);
            plot(ts, cavity_1_tempA,ts, cavity_2_tempA);  
            datetick('x', 13);
            ylabel('Temperature (degrees C)');
            xlabel('Time');
            title('Cavity Temperature');
            
    
            heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
            heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
            bpm_currentA(j) = lcaGet ('BPMS:DMP1:398:TMIT1H');
            
            pause (1);
        end
    end
end


lcaPut('UND:R02:IOC:16:Cavity2:HeaterOn',1); %Turn cavity 2 heater ON
disp(sprintf('Heating cavity 2...'));

%{
while now < tstart + 30/60/24 %heat for 30 minutes
 j = j+1;
    phase_cavity_signal_1A(j,:)= lcaGet('UND:R02:IOC:16:dig1:WAV1',1000); %phase cavity 1; RAW WAVEFORM
    phase_cavity_signal_2A(j,:)= lcaGet('UND:R02:IOC:16:dig1:WAV2',1000); %phase cavity 2; RAW WAVEFORM
    figure(1);
    plot(t1,phase_cavity_signal_1 );
    ylabel('Signal');
    xlabel('time');
    title('Phase Cavity 1');

    figure(2);
    plot(t2,phase_cavity_signal_2 );
    ylabel('Signal');
    xlabel('time');
    title('Phase Cavity 2');
    
    cavity_1_tempA(j) = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
    cavity_2_tempA(j) = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
    
    heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
    heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
    pause (1);
end
%}
cavity_2_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
while cavity_2_temp < 28.9000
    if lcaGet('SIOC:SYS0:ML01:AO989') == 0
        error('script aborted')
    end
    
    cavity_2_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
    
    if cavity_2_temp > 28.8000 
    lcaPut('UND:R02:IOC:16:Cavity2:HeaterOn',0); %cavity 2 heater OFF
    heater_2 = lcaGet('UND:R02:IOC:16:Cavity2:HeaterOn');
    disp(sprintf('Heater 2 = %s', heater_2{1}));
    break
   
    else
    tstart = now;
    
        while now < tstart + 1/60/60/24 %if temperature is less than 28.8 degrees C, heat 1 more second
             j = j+1;
            [phase_cavity_signal_1A(j,:), tsA(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
            [phase_cavity_signal_2A(j,:), tsB(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
        
            [cavity_1_tempA(j), tsC(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
            [cavity_2_tempA(j), tsD(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
            figure(1);
            ts = lca2matlabTime(tsC);
            plot(ts, cavity_1_tempA,ts, cavity_2_tempA); 
            datetick('x', 13);
            ylabel('Temperature (degrees C)');
            xlabel('Time');
            title('Cavity Temperature');
            
    
            heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
            heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
            bpm_currentA(j) = lcaGet ('BPMS:DMP1:398:TMIT1H');
            
            pause (1);
        end
    end
end

cavity_2_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
while cavity_2_temp > 19.80000
    if lcaGet('SIOC:SYS0:ML01:AO989') == 0
        error('script aborted')
    end
    
    cavity_2_temp = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
    if cavity_2_temp > 19.8000
        disp(sprintf('Cavity 2 cooling...'));
        tstart = now;
        while now < tstart + 1/60/60/24 %cool for one more second 
            j = j+1;
            [phase_cavity_signal_1A(j,:), tsA(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
            [phase_cavity_signal_2A(j,:), tsB(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
            
            [cavity_1_tempA(j), tsC(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
            [cavity_2_tempA(j), tsD(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
            figure(1);
            ts = lca2matlabTime(tsC);
            plot(ts, cavity_1_tempA,ts, cavity_2_tempA); 
            datetick('x', 13);
            ylabel('Temperature (degrees C)');
            xlabel('Time');
            title('Cavity Temperature');
            
    
            heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
            heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
            bpm_currentA(j) = lcaGet ('BPMS:DMP1:398:TMIT1H');
            
            pause (1);
        end
    end

end

tstart = now;
while now < tstart + 10/60/60/24 %wait ten seconds
    j = j+1;
    [phase_cavity_signal_1A(j,:), tsA(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV1',4096); %phase cavity 1; RAW WAVEFORM
    [phase_cavity_signal_2A(j,:), tsB(j)]= lcaGet('UND:R02:IOC:16:dig1:WAV2',4096); %phase cavity 2; RAW WAVEFORM
    
    [cavity_1_tempA(j), tsC(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP5'); %cavity 1 temperature
    [cavity_2_tempA(j), tsD(j)] = lcaGet ('UND:R01:BHC:05:KL3314:SLOT2:TEMP6'); %cavity 2 temperature
    figure(1);
    ts = lca2matlabTime(tsC);
    plot(ts, cavity_1_tempA,ts, cavity_2_tempA);  
    datetick('x', 13);
    ylabel('Temperature (degrees C)');
    xlabel('Time');
    title('Cavity Temperature');
    
    
    heater_1A(j)= lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn'); %status of heater cavity 1
    heater_2A(j)= lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn'); %status of heater cavity 2
    
    bpm_currentA(j) = lcaGet ('BPMS:DMP1:398:TMIT1H');
    
    pause (1);
end

lcaPut('UND:R02:IOC:16:Cavity1:HeaterOn',0); %cavity 1 heater OFF
heater_1 = lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn');
disp(sprintf('Heater 1 = %s', heater_1{1}));

lcaPut('UND:R02:IOC:16:Cavity2:HeaterOn',0); %cavity 2 heater OFF
heater_2 = lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn');
disp(sprintf('Heater 2 = %s', heater_2{1}));

lcaPut('SIOC:SYS0:ML00:AO761',.05); %turn ON feedback
cav1FBgain = lcaGet('SIOC:SYS0:ML00:AO761');
disp(sprintf('Cavity 1 feedback is enabled = %d', cav1FBgain));

lcaPut('SIOC:SYS0:ML00:AO773',.05); %turn ON feedback
cav2FBgain = lcaGet('SIOC:SYS0:ML00:AO773');
disp(sprintf('Cavity 2 feedback is enabled = %d', cav2FBgain));

lcaPut('SIOC:SYS0:ML00:AO747', resynchSave); %reset resynch
resynchSave = lcaGet('SIOC:SYS0:ML00:AO747');
disp(sprintf('Resynch reset = %d', resynchSave));
pause (10);


%heater_time_1A(j) = heater_time_1; 
%heater_time_2A(j) = heater_time_2; 


resynchSave = lcaGet('SIOC:SYS0:ML00:AO747'); %status of resync (on or off)
cav1FBgain = lcaGet('SIOC:SYS0:ML00:AO761'); %Cavity 1 feedback gain
cav2FBgain = lcaGet('SIOC:SYS0:ML00:AO773'); %Cavity 2 feedback gain

catch
    err = lasterror
    err.stack
lcaPut('UND:R02:IOC:16:Cavity1:HeaterOn',0); %cavity 1 heater OFF
heater_1 = lcaGet ('UND:R02:IOC:16:Cavity1:HeaterOn');
disp(sprintf('Heater 1 = %s', heater_1{1}));

lcaPut('UND:R02:IOC:16:Cavity2:HeaterOn',0); %cavity 2 heater OFF
heater_2 = lcaGet ('UND:R02:IOC:16:Cavity2:HeaterOn');
disp(sprintf('Heater 2 = %s', heater_2 {1}));

lcaPut('SIOC:SYS0:ML00:AO761',.05); %turn ON feedback
cav1FBgain = lcaGet('SIOC:SYS0:ML00:AO761');
disp(sprintf('Cavity 1 feedback is enabled = %d', cav1FBgain));

lcaPut('SIOC:SYS0:ML00:AO773',.05); %turn ON feedback
cav2FBgain = lcaGet('SIOC:SYS0:ML00:AO773');
disp(sprintf('Cavity 2 feedback is enabled = %d', cav2FBgain));

lcaPut('SIOC:SYS0:ML00:AO747', resynchSave); %reset resynch
resynchSave = lcaGet('SIOC:SYS0:ML00:AO747');
disp(sprintf('Resynch reset = %d', resynchSave));

lcaPut('SIOC:SYS0:ML01:AO989', 1); %reset abort
disp(sprintf('Abort reset = 1'));

pause (10);  
end

[fname,pname]=uiputfile('*.mat','file name');
 
save ([pname filesep fname],'phase_cavity_signal_1A','phase_cavity_signal_2A','heater_1A','heater_2A','cavity_1_tempA','cavity_2_tempA','resynchSave', 'cav1FBgain','cav2FBgain','bpm_currentA','tsA', 'tsB', 'tsC', 'tsD');




