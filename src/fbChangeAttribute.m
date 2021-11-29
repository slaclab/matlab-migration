function newnames = fbChangeAttribute(pvs, newAttribute)
%
% Strip the attribute from the PV name, to get the base device name
%
% pvs - cell array of strings, list of PV names to strip F1 or F2 from
% newnames - cell array of strings, list of new names without edef chars
%
 devnames = regexp(pvs, '\w*:\w*:\w*:', 'match', 'once');
 newnames = strcat(devnames, newAttribute);
end


