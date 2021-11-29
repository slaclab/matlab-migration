% wrapper function for use in DAQ
function [BDES, BACT] = set_QS0_objectplane_from_MIP(dz_OB);


% input dz is relative to MIP
z_MIP = 1993.21; % = CUBE1

set_QS0_position_energy_2015(z_MIP + dz_OB);

