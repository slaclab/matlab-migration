function newlimits = fbCalcNewActLimits(actvals, limits)
%
% find all pvs with X in the name, replace with TMIT
% pvs - cell array of strings, list of PV names to create TMIT name from
% newnames - cell array of strings, list of new names with TMIT
%

%limits.low = actvals - ((actvals.*limits.percent)/100);
%limits.high = actvals + ((actvals.*limits.percent)/100);
newlimits  = limits;
   

