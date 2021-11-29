function [val, ts] = mlcaGet(oldPVs)
%
% same as lcaGet but takes old PV names 
%

newPVs = undulatorPVchange(oldPVs);
[val, ts] = lcaGet(newPVs);

