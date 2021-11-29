function tsChecker(pv)

while (1)
    try
        [val,ts] = lcaGet(pv);
        pulseid = lcaTs2PulseId(ts);
        disp(sprintf('ts = %s pulse id = %d %X', ...
            imgUtil_matlabTime2String(lca2matlabTime(ts)), ...
            pulseid, pulseid));
    catch
        disp('Sorry, can''t understand');
        pv
        return;
    end
    pause(1.0);
end


