function lcaHandles = epicsSimul_lcaHandlesInit()

global epicsSimul_lcaHandles

if isempty(epicsSimul_lcaHandles)
    p=fileparts(which('lcaClear'));
    pNow=pwd;
    cd(p);
    epicsSimul_lcaHandles.lcaGet=@lcaGet;
    epicsSimul_lcaHandles.lcaGetStatus=@lcaGetStatus;
    epicsSimul_lcaHandles.lcaPut=@lcaPut;
    epicsSimul_lcaHandles.lcaPutNoWait=@lcaPutNoWait;
    epicsSimul_lcaHandles.lcaSetMonitor=@lcaSetMonitor;
    epicsSimul_lcaHandles.lcaNewMonitorValue=@lcaNewMonitorValue;
    cd(pNow);
end

lcaHandles=epicsSimul_lcaHandles;
