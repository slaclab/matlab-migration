function imgAcq_epics_putGo(val)
try
    lcaPut ('PROF:PM00:1:GO',val);
catch
    %do nothing
end
