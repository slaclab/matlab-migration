function E200_waitDAQ(par)

% Wait for Image DAQ to finish saving
while sum(lcaGetSmart(strcat(par.cams(:,2),':STATUS_DAQ'))) ~= 0; end;
disp(['Image saving complete ' datestr(clock,'HH:MM:SS')]);

% Disable DAQ when finished
lcaPut(strcat(par.cams(:,2),':ENABLE_DAQ'),0);

end