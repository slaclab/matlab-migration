function [val, ts] = mlcaGetSmart(oldPVs)
%
% same as lcaGetSmart but takes old PV names 
%

newPVs = undulatorPVchange(oldPVs);
[val, ts] = lcaGetSmart(newPVs);
