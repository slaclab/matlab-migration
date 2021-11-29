function set_laser_alignment_attenuation()

% SC: outdated function.

% % Laser energy scan motor PVs
% laser_waveplate = 'XPS:LA20:LS24:M1';
% laser_polarizer = 'XPS:LA20:LS24:M2';
% laser_filters = 'XPS:LA20:LS24:M3';
% 
% % Move the polarizer to the In position
% lcaPutSmart(laser_polarizer, 3);
% while abs( lcaGetSmart([laser_polarizer '.RBV'])-3 ) > 0.1; end;
% 
% % Rotate the waveplate to the one degree off the extinction angle
% lcaPutSmart(laser_waveplate, 15);
% while abs( lcaGetSmart([laser_waveplate '.RBV'])-15 ) > 0.1; end;
% 
% % Move the filters to the In position
% lcaPutSmart(laser_filters, 0);
% while abs( lcaGetSmart([laser_filters '.RBV'])-0 ) > 0.1; end;
% 
% display('The laser is now attenuated for laser alignment on the IPOTR foils.');
% 
