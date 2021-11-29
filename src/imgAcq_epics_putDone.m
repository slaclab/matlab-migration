function imgAcq_epics_putDone(val)
try
    lcaPut('PROF:PM00:1:DONE', val);
    pause(0.5);
catch
    %do nothing
end