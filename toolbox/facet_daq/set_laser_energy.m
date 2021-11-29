function set_laser_energy(energy_percent)

% Laser energy scan motor PVs
laser_waveplate = 'XPS:LA20:LS24:M1';
%laser_polarizer = 'XPS:LA20:LS24:M2';

% Move the polarizer to the In position
%lcaPutSmart(laser_polarizer, 3);
%while abs( lcaGetSmart([laser_polarizer '.RBV'])-3 ) > 0.1; end;

% Rotate the waveplate to the angle that gives the desired energy fraction
phi_extinction = 59.6;
phi = phi_extinction - (180/pi)*0.5*asin(sqrt(energy_percent/100));
lcaPutSmart(laser_waveplate, phi);
while abs( lcaGetSmart([laser_waveplate '.RBV'])-phi ) > 0.1; end;


