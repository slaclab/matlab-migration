function newnames = fbStripEDefFromPVs(pvs)
%
% Strip the eDef F1 or F2 from the name, to get the base PV name
%
% pvs - cell array of strings, list of PV names to strip F1 or F2 from
% newnames - cell array of strings, list of new names without edef chars
%
newnames = regexprep(pvs, 'F2', '');
newnames = regexprep(newnames, 'F1', '');
newnames = regexprep(newnames, 'BR', '');
newnames = regexprep(newnames, 'TH', '');
newnames = regexprep(newnames, '1H', '');



