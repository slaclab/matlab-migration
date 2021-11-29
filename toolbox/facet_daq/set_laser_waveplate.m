function waveplate = set_laser_waveplate(phi)

% Laser energy scan motor PVs
laser_waveplate = 'XPS:LA20:LS24:M1';
%laser_polarizer = 'XPS:LA20:LS24:M2';

% Move the polarizer to the In position
%lcaPutSmart(laser_polarizer, 3);
%while abs( lcaGetSmart([laser_polarizer '.RBV'])-3 ) > 0.1; end;

% Rotate the waveplate to the desired angle phi
lcaPutSmart(laser_waveplate, phi);
while abs( lcaGetSmart([laser_waveplate '.RBV'])-phi ) > 0.1; end;
waveplate = lcaGetSmart([laser_waveplate '.RBV']);

