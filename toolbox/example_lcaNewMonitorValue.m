%
% Example on how to uselca NewMonitorValue
%

Logger = getLogger('example lca monitor');
try
    pv = cell(0);
    pv{end+1} = 'SIOC:SYS0:ML00:AO199';
    pv{end+1} = 'SIOC:SYS0:ML00:AO200';
    lcaSetMonitor(pv');
    while 1
        nv = lcaNewMonitorValue(pv');
        for i = 1:size(nv)
            if 1 == nv(i)
                put2log(sprintf('%s=%d', pv{i}, lcaGet(pv{i})));
            end
            pause(0.1);
        end
    end
catch
    put2log('Channel Access failure'); % logs to both the message log and terminal
    lcaLastError % channel access status codes
end
