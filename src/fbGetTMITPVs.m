function newnames = fbGetTMITPVs(pvs)
%
% find all pvs with X in the name, replace with TMIT
% pvs - cell array of strings, list of PV names to create TMIT name from
% newnames - cell array of strings, list of new names with TMIT
%
bpms = strfind(pvs,':X');
x=0;
newpvs={};
for i=1:length(bpms)
   if (bpms{i,1}>0)
      x=x+1;
      newpvs{x,1} = pvs{i,1};
   end
end
newnames = newpvs;
if ~isempty(newpvs)
   newnames  = regexprep(newpvs, 'X', 'TMIT');
   %now get the first PV, check the LOCA for debug case
   if ~isempty(strfind(pvs{1,1},'TRNS'))
      newnames{end+1,1} = 'BPMS:TRNS:221:TMIT';
   else 
      if ~isempty(strfind(pvs{1,1},'LNGS'))
         newnames{end+1,1} = 'BPMS:LNGS:221:TMIT';
      else
         newnames{end+1,1} = 'BPMS:IN20:221:TMIT';
      end
   end
end

