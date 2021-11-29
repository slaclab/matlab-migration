function flag = imgAcq_epics_isProduction()

try
    val = lcaGet('IOC:SYS0:AL00:MODE');
    val =val{1};
    flag = strcmpi(val, 'production');
catch
    flag = 0;
end