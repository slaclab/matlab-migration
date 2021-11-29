function set_laser_full_power()

% SC: outdated function.

% % Laser energy scan motor PVs
% laser_waveplate = 'XPS:LA20:LS24:M1';
% laser_polarizer = 'XPS:LA20:LS24:M2';
% laser_filters = 'XPS:LA20:LS24:M3';
% 
% lcaPutSmart('TRIG:LA20:LS25:TCTL',0);
% 
% 
% % Move the filters to the Out position
% lcaPutSmart(laser_filters, 25);
% while abs( lcaGetSmart([laser_filters '.RBV'])-25 ) > 0.1; end;
% 
% % Rotate the waveplate to the max power position
% lcaPutSmart(laser_waveplate, 8.5);
% while abs( lcaGetSmart([laser_waveplate '.RBV'])-8.5 ) > 0.1; end;
% 
% 
% display('The laser is now at full power.');
% 
% lcaPutSmart('TRIG:LA20:LS25:TCTL',1);
% 
