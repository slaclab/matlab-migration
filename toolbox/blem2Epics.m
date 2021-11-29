function blem2Epics()
%function blem2Epics()
%calls MATLAB EXTANT model and writes it to EPCIS PVs

% William Colocho 8/2018
lcaSetSeverityWarnLevel(4)
for ii = 1:5
    isRunningCounter(ii) = lcaGet('SIOC:SYS0:ML01:AO004');
    pause(1)
end

if sum(diff(isRunningCounter)), 
    fprintf('\n%s Another instance of "blem2Epics" seems to be already running\nNot Starting\n', datestr(now))
else
    fprintf('\n%s Starting blem2Epics \n', datestr(now))
end

isRunningCounter = 0;
while 1
    try
    extantModelToEpics
    pause(2)
    isRunningCounter = isRunningCounter + 1;
    lcaPutSmart('SIOC:SYS0:ML01:AO004', isRunningCounter);
    catch 
        keyboard
    end
end