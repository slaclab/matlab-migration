pv = cell(0);
pv{end+1} = 'BPMS:LI21:278:X1H';
pvs = cell(0);
pvs{end+1} = sprintf('%s.STAT',pv{1});
pvs{end+1} = sprintf('%s.SEVR',pv{1});
lcaSetMonitor(pv);
while (1)
    lcaNewMonitorWait(pv);
    [val,ts] = lcaGet(pv); % to clear the monitor
    [vals,tss]=lcaGet(pvs', 0, 'char');
    disp (sprintf ('%s %f %s %s %s', char(pv), val, char(vals{1}), char(vals{2}), imgUtil_matlabTime2String(lca2matlabTime(ts))));
end