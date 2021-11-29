function [taper] = taperRecall(time)
%
% Example:  [taper] = taperRecall(time)(now -1) will return
% the various taper parameters offsets one day previous to the present time.
%


time = datestr(time); % convert all formats to datestr
time = datenum(time); % convert to serial date number

% set up time interval for archive recall
starttime = time;
stoptime = starttime + 	1/(24*3600);% long period because get_archive bombs if no data is availble
stoptime =datestr(stoptime);
starttime = datestr(starttime);

taper.time = datestr(time);

taperData = {...
'useSpontaneous' ,'SIOC:SYS0:ML00:AO413';...
'useWakefields' ,'SIOC:SYS0:ML00:AO414';...
'addGainTaper' ,'SIOC:SYS0:ML00:AO422';...
'gainTaperStart' ,'SIOC:SYS0:ML00:AO423';...
'gainTaperEnd' ,'SIOC:SYS0:ML00:AO424';...
'gainTaperAmp' ,'SIOC:SYS0:ML00:AO425';...
'addSatTaper' ,'SIOC:SYS0:ML00:AO426';...
'satTaperStart' ,'SIOC:SYS0:ML00:AO427';...
'satTaperStop' ,'SIOC:SYS0:ML00:AO428';...
'satTaperAmp' ,'SIOC:SYS0:ML00:AO429'};

taperPV = taperData(:,2);
[~, v] = history(taperPV, {starttime; stoptime}, 'verbose',0);

for q=1:length(taperData)
    fn = taperData{q,1};
    value = mean(v{q});
    taper.(fn) = value ;
end

for q=1:33
    KactPV{q,1} = sprintf('USEG:UND1:%d50:KACT',q);
    xActPV{q,1} = sprintf('USEG:UND1:%d50:XACT',q);
end

[~,K] = history(KactPV,{starttime; stoptime}, 'verbose',0);
[~,x] = history(xActPV,{starttime; stoptime}, 'verbose',0);
for q=1:33
taper.Kact(q) = mean(K{q});
taper.xAct(q) = mean(x{q});
end

