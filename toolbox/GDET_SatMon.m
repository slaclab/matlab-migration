% GDET_SatMon.m
% Script to check if any gas detector PMTs are saturated
%  - J. Rzepiela, 09/15/11
lcaPut('SIOC:SYS0:ML00:AO734.DESC','GDET PMT monitor heartbeat')
msgout=sprintf('%s: Starting GDET_SatMon\n',datestr(now)');
disp(msgout)
counter_max = 50000; %counter wraps here
counter=0;
nratio=5; %check every 5 secs
while(1) %infinite loop
    counter = mod(counter, counter_max);
    counter=counter+1;
    lcaPut('SIOC:SYS0:ML00:AO734',counter) %watcher heartbeat
    pause(1)
    try
        daq1Running=lcaGet('DIAG:FEE1:202:240:MDAQStatus',0,'double');
    catch
        daq1Running=0;
    end
    try
        daq2Running=lcaGet('DIAG:FEE1:202:360:MDAQStatus',0,'double');
    catch
        daq2Running=0;
    end
    if daq1Running && daq2Running
        if mod(counter, nratio) == 0
            PMTList={'DIAG:FEE1:202:241:Data';'DIAG:FEE1:202:242:Data';'DIAG:FEE1:202:361:Data';'DIAG:FEE1:202:362:Data'};
            startIdxList={'GDET:FEE1:241:STRT';'GDET:FEE1:242:STRT';'GDET:FEE1:361:STRT';'GDET:FEE1:362:STRT'};
            stopIdxList={'GDET:FEE1:241:STOP';'GDET:FEE1:242:STOP';'GDET:FEE1:361:STOP';'GDET:FEE1:362:STOP'};
            outPVList={'SIOC:SYS0:ML00:AO730';'SIOC:SYS0:ML00:AO731';'SIOC:SYS0:ML00:AO732';'SIOC:SYS0:ML00:AO733'};
            dataPMT=lcaGet(PMTList);
            startIdx=lcaGet(startIdxList);
            stopIdx=lcaGet(stopIdxList);
            minVal=min(dataPMT(:,startIdx(:):stopIdx(:)),[],2);
            saturated=minVal<-31000;
            lcaPut(outPVList,double(saturated));
        end
    end
end