% counts the number of spare AO MATLAB PVs
[ sys, accelerator ] = getSystem();
count = 0;
for m = 0:3
    disp(sprintf('Searching for spare %s MATLAB PVs in ML0%d...', accelerator, m));
    for a = 0:999
        try
            pv = sprintf('SIOC:%s:ML0%d:AO%3.3d.DESC', sys, m, a);
            d = lcaGet(pv);
            if strcmp('spare', d)
                count = count + 1;
                disp(sprintf('     %d %s is %s', count, pv, char(d)));
            end
        catch
            disp(sprintf('Failed to lcaGet(%s)', pv));
        end
    end
end
disp(sprintf('%d TOTAL spare AOs for %s', count, accelerator));
try
    pv = sprintf('SIOC:%s:ML01:AO735', sys);
    lcaPut(pv, count);
catch
    disp(sprintf('Failed to lcaPut(%s)=%d', pv, count));
end
