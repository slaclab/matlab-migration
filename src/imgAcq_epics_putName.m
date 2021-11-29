function imgAcq_epics_putName(appId)
try
    lcaPut('PROF:PM00:1:NAME', appId);
    pause(0.5);
catch
    %do nothing
end
