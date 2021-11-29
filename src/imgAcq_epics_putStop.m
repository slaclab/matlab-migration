function imgAcq_epics_putStop(val)
try
    lcaPut ('PROF:PM00:1:STOP', val);
catch
    %do nothing
end
