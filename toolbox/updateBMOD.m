function updateBMOD()
% function updateBMOD updates BMOD for CU_HXR and CU_SXR
% expected to run as a tmux service and calls model_compareeLatticeDesign.m
% to get BMOD calculated from EACT
%
% Author: William Colocho, Aug. 2021

fprintf('%s Startig BMOD updates\n', datestr(now))
doPlot = 0;

while 1
    n = now;
    timeOfDay = n - fix(n);
    lcaPutSmart('SIOC:SYS0:ML01:AO019', timeOfDay);
    cuhxr = model_compareLatticeDesign('CU_HXR', doPlot);
    cusxr = model_compareLatticeDesign('CU_SXR', doPlot);
    
    lcaPutSmart(strcat(cuhxr.names,':BMOD'), cuhxr.bMod);
    lcaPutSmart(strcat(cusxr.names,':BMOD'), cusxr.bMod);
end



