function val=imgAcq_epics_getStatus()
try
    val = lcaGet('PROF:PM00:1:STATUS');
    val = val{1};
catch
    val = 'N/A';
end