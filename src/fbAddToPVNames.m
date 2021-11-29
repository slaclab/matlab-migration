function newnames = fbAddToPVNames(pvnames, str)
%
%  add the passed in string to the end of the PV name. This will usuallybe
%  an attribute of the PV such as the .EGU in XCOR:IN20:381:BDES.EGU
%
%  pvnames - a cell array of pv name strings
%  str    - string to add to the PV names
%  newnames - the concatenation of pvnames and str
for i=1:length(pvnames)
    newnames{i,1} = strcat(pvnames{i,1}, str);
end