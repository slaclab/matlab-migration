function epicsSimul_clear()

global epicsDataBase epicsUseAida epicsVerbose epicsSimul_lcaHandles

epicsDataBase=cell(0,2);
if isempty(epicsUseAida), epicsUseAida=0;end
if isempty(epicsVerbose), epicsVerbose=0;end
epicsSimul_lcaHandles=[];