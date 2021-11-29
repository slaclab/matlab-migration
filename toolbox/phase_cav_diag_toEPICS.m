function phase_cav_diag_toEPICS()
lcaSetSeverityWarnLevel(5);
pv_t = {'UND:R02:IOC:10:BAT:FitTime1'; 'UND:R02:IOC:10:BAT:FitTime2'};
pv_q = {'UND:R02:IOC:10:BAT:Charge1'; 'UND:R02:IOC:10:BAT:Charge2'};
pv_pid = {'PATT:SYS0:1:PULSEID'};
pv_bpm = {'BPMS:DMP1:299:TMIT'; 'BPMS:LTU1:250:X'; 'BPMS:LTU1:250:TMIT'; 'BPMS:LI24:801:X'};
pv_all = [pv_t; pv_q; pv_pid; pv_bpm];
%pv_rate = 'EVNT:SYS0:1:LCLSBEAMRATE';
pv_mon = pv_q(1);    % _t

lcaSetMonitor(pv_mon);
runCounter = 0;
fprintf('%s Started phase cavity diag to EPICS\n', datestr(now))
try
while(1)
    runCounter = runCounter+1;
    lcaPutSmart('SIOC:SYS0:ML01:AO005', runCounter);
    %rate = lcaGetSmart(pv_rate);
    num = 1000;
    val = zeros(numel(pv_all), num);
    ts = zeros(size(val));
    pid = zeros(1, num);
    

    for ix = 1:num
        try
        lcaNewMonitorWait(pv_mon);
        catch
            fprintf('%s --- %s\n', datestr(now), lasterr)
        end
        

        [val(:, ix), ts(:, ix)] = lcaGetSmart(pv_all);
        pid(ix) = lcaGetSmart(pv_pid);
    end
    %toc;
    
    % flag no-charge data
    ok   =  val(3,:) > 50 & ...                     % charge < 50 pC
        val(4,:) > 50;                          % charge < 50 pC
    ok_val = val(:,ok);
    %ok_ts = ts(:,ok);
    nok = sum(ok);
    %disp(sprintf('%d out of %d points are flagged as OK (charge > 50 pC).', nok, num));
    midpt = mean(ok_val(:,:), 2);
    %stdev = std(ok_val(:,:) - repmat(midpt, 1, nok), [], 2);
    
    % flag outliers (fit time more than 1 ps away from mean)
    good =  ok & ...
        val(1,:) < (midpt(1) + 1) & val(1,:) > (midpt(1) - 1) & ...
        val(2,:) < (midpt(2) + 1) & val(2,:) > (midpt(2) - 1);
    good_val = val(:,good);
    good_ts = ts(:,good);
    ngood = sum(good);
    midpt = mean(good_val(:,:), 2);
    %stdev = std(good_val(:,:) - repmat(midpt, 1, ngood), [], 2);
    %disp(sprintf('%d out of %d points are flagged as good (OK and time inside 2 ps window).', ngood, num));
    
    %fit_time = good_val(1:2,:);
    %charge = good_val(3:4,:);
    
  
    
    ts_pid = lcaTs2PulseId(good_ts(:,:));
    
    
    mm2 = min(int32(ts_pid(2,:)))/3;
    dmm2 = mm2 - floor(mm2/2)*2;
    shot=(int32(ts_pid(2,:))/3-mm2) + dmm2;
    [is,iso]=find(floor(shot/2)*2 ~= shot);
    [is,ise]=find(floor(shot/2)*2 == shot);
    
    
    cav1_rms=std(good_val(1,:));
    cav1_TS1rms=std(good_val(1,iso(:)));
    cav1_TS4rms=std(good_val(1,ise(:)));
    cav1_TS1mean = mean(good_val(1,iso(:)));
    cav1_TS4mean = mean(good_val(1,ise(:)));
     TS_diffCav1= cav1_TS1mean - cav1_TS4mean;

    %Write to EPICS
    lcaPutSmart('PCAV:DMP1:31:CAV1:RMS', round(cav1_rms*1000)/1000);
    lcaPutSmart('PCAV:DMP1:31:CAV1:TS1RMS', round(cav1_TS1rms*1000)/1000 );
    lcaPutSmart('PCAV:DMP1:31:CAV1:TS4RMS',  round(cav1_TS4rms*1000)/1000);
    lcaPutSmart('PCAV:DMP1:31:CAV1:TS1MEAN',  round(cav1_TS1mean*1000)/1000); 
    lcaPutSmart('PCAV:DMP1:31:CAV1:TS4MEAN',  round(cav1_TS4mean*1000)/1000);     
    lcaPutSmart('PCAV:DMP1:31:CAV1:DELTATS', round(TS_diffCav1*1000)/1000);

 
    cav2_rms=std(good_val(2,:));
    cav2_TS1rms=std(good_val(2,iso(:)));
    cav2_TS4rms=std(good_val(2,ise(:)));
     cav2_TS1mean = mean(good_val(2,iso(:)));
    cav2_TS4mean = mean(good_val(2,ise(:)));
    TS_diffCav2= cav2_TS1mean - cav2_TS4mean;

    
    lcaPutSmart('PCAV:DMP1:32:CAV2:RMS', round(cav2_rms*1000)/1000);
    lcaPutSmart('PCAV:DMP1:32:CAV2:TS1RMS', round(cav2_TS1rms*1000)/1000 );
    lcaPutSmart('PCAV:DMP1:32:CAV2:TS4RMS',  round(cav2_TS4rms*1000)/1000);
    lcaPutSmart('PCAV:DMP1:32:CAV2:TS1MEAN',  round(cav2_TS1mean*1000)/1000);
    lcaPutSmart('PCAV:DMP1:32:CAV2:TS4MEAN',  round(cav2_TS4mean*1000)/1000);
    lcaPutSmart('PCAV:DMP1:32:CAV2:DELTATS', round(TS_diffCav2*1000)/1000);   
    
 
end
catch
    keyboard
end


