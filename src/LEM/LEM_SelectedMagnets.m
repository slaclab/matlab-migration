function id=LEM_SelectedMagnets()
%
% id=LEM_SelectedMagnets();
%
% Return pointers to currently selected MAGNETs

global lemRegions lemGroups
global MAGNET

idr=find(ismember([MAGNET.region]',find(lemRegions))); % in selected region(s)
idg=find(ismember([MAGNET.scaleGroup]',find(lemGroups))); % in selected group
id=intersect(idr,idg); % these are the ones

end
