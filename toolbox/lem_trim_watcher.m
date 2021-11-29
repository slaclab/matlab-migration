function lem_trim_watcher
% Watch for listenPV and perform requested action by calling
% model_energyBLEMTrim

%W. Colocho Dec. 2012.
lcaPutSmart('SIOC:SYS0:ML01:AO140.DESC', 'I am Alive Counter');
listenPV = 'SIOC:SYS0:ML01:AO143';
lcaPutSmart([listenPV, '.MDEL'], -1); %Get a callback anytime PV is put to.
lcaPutSmart(listenPV, 0);
disp_log('lem_trim_watcher.m started') ;
lcaSetMonitor(listenPV)
pause(1)
lcaGetSmart(listenPV); %clear monitor
aliveCounter = 0;
while(1)
    newAction = lcaNewMonitorValue(listenPV);
    while ~newAction, 
        pause(0.1)
        newAction = lcaNewMonitorValue(listenPV); 
        aliveCounter = aliveCounter + 1;
        lcaPutSmart('SIOC:SYS0:ML01:AO140', aliveCounter);
    end
    actionVal = lcaGetSmart(listenPV);
    switch actionVal
        case 1 % trim
            disp_log('LEM trim request started');
            model_energyBLEMTrim('quiet', 1)
            lcaPutSmart(listenPV, 0);
        case 2 % undo
            disp_log('LEM undo request started');
            model_energyBLEMTrim('undo',1, 'quiet', 1)
            lcaPutSmart(listenPV, 0);
        case 3 % STDZ
            lcaPut('IOC:BSY0:MP01:MSHUTCTL','No');
            disp_log('LEM beam disabled for STDZ');
            pause(0.5);
            disp_log('LEM STDZ request started');
            model_energyBLEMTrim('action','STDZ', 'quiet', 1)
            lcaPut('IOC:BSY0:MP01:MSHUTCTL','Yes');
            lcaPutSmart(listenPV, 0);
        otherwise %do nothing   
            fprintf('%s LEM Action Done\n',datestr(now))
    end    
end
