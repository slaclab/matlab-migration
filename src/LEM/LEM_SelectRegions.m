function stat=LEM_SelectRegions()
%
% Select LEM regions to include when scaling

global lemRegions
global noFudgeCalc

oldRegions=lemRegions;
lemRegions=LEM_SelectRegionGUI(lemRegions);
noFudgeCalc=isempty(intersect(find(lemRegions),[1,2,3,4]));

% if region selection has changed, remind user to load optics

if (any(lemRegions~=oldRegions))
  disp('*** The list of selected LEM regions has been changed')
  disp('*** Be sure to Load Optics (Saved or Design)')
end

stat=1;

end