function stat=LEM_SelectGroups()
%
% Select LEM groups to include when scaling

global lemGroups

oldGroups=lemGroups;
lemGroups=LEM_SelectGroupGUI(lemGroups);

% if groups selection has changed, remind user to load optics

if (any(lemGroups~=oldGroups))
  disp('*** The list of selected LEM optional magnet groups has been changed')
  disp('*** Be sure to Load Optics (Saved or Design)')
end

stat=1;

end