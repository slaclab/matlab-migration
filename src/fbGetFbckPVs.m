function fbckPVs = fbGetFbckPVs(pvs)
%
% get only BPM FBCK PVs 
%
% take any BLEN PVs out of the list
%
fbckPVs = [];
fpvs = fbChangeAttribute(pvs, 'FBCK');
f=0;
k = regexp(fpvs, 'BPMS');
for i=1:length(k)
   if ~isempty(k{i})
      f= f+1;
      fbckPVs{f} = fpvs{i};
   end
end
fbckPVs = fbckPVs';
end


