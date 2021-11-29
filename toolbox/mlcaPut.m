function mlcaPut(oldPVs, vals)
%
% same as lcaPut but takes old PV names 
%

newPVs = undulatorPVchange(oldPVs);
lcaPut(newPVs, vals);
