function newPVs = fbGetPVNames(m, PVs)
% --- create a new PV cellstr array of strings extracted from the PVs list 
% --- as indicated by the m vector
% m      a vector of flags that indicate which strings should be extracted
%        1 means extract, 0 means don't 
% PVs    the list of PVs to extract from
% newPVs the new list of PVs returned
np = 0;
nPVs = cell(0);
if (isempty(m)==0) && (isempty(PVs)==0) % if neither array is empty
    for i=1:length(m)
        if m(i)==1
            np = np+1;
            nPVs(np) = PVs(i);
        end
    end 
end
newPVs = nPVs';

