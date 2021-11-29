function [sevr, stat, ts] = epicsSimul_lcaGetStatus(pv)

global epicsDataBase epicsUseAida

if isempty(epicsDataBase), epicsSimul_clear;end

pvList=cellstr(pv);
[sevr,stat,ts]=deal(zeros(size(pvList)));

if epicsUseAida
    return
end

ts(:)=now;
