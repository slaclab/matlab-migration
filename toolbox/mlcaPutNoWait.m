function mlcaPutNoWait(oldPVs, vals)
%
% same as lcaPutNoWait but takes old PV names 
%

newPVs = undulatorPVchange(oldPVs);
lcaPutNoWait(newPVs, vals);
