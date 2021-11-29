function  alignment_laser_scanner()
% Injector Alignment Laser Beam Scanning Program
% J. Welch, 3/8/07
% Scan alignment laser beam position on a chosen screen,
% while pivoting the beam position on another screen or location,
% eg. scan 2 mm vertical, 3 mm horizontal rectangular region on screen
% YAGS1, while pivoting about AM01.

Program_intro = {'Program to scan the injector alignment laser beam spot'; ....
 'at one screen, while keeping it fixed on another. '}

screen_names = [ 'AM01   '; 'YAG01  '; 'CR01   '; 'YAG02  '; 'YAGG1  ';...
    'CRG1   '; ...
    'YAG03  '; 'YAG04  '; 'OTR1   '; 'OTR2   '; 'OTR3   '; 'YAGS1  ' ] ;
screen_dist_M3 = [ 0.35; 0.96; 1.57; 1.74; 2.19; 2.2; 4.97; 10.59; ...
    12.67; 14.59; 16.5; 18.94 ] ;  % distance from M3 (tilting mirror)

screen_dist_table = [screen_names num2str(screen_dist_M3)]


% Get user input
s_screen = input('Enter screen location for beam motion [m]... ') ;% change x,y here
s_pivot = input('Enter location of pivot [m]...') ; %fix x,y here
range_x = input('Enter horz (full) range to scan [mm]... ') ; %beam x
range_y = input('Enter vert (full) range to scan [mm].. ') ; %beam y 

% User_inputs = [range_x range_y  s_screen s_pivot]

% Get original mirror configuration
[orig_mirror_config, orig_timestamps] = ...
lcaGet( {'MIRR:IN20:154:AM1_MOTR_H'; 'MIRR:IN20:154:AM1_MOTR_V'; ...
		 'ALS1:IN20:156:ALS1_POS'; 'ALS1:IN20:158:ALS2_POS' } )

% Do the scan
% First move to lower left corner
alignment_laser_mover_module( -0.5*range_x, -0.5*range_y, s_screen, s_pivot)

% Start scanning
nsteps = 11; % number of points in each direction
delta_x =  range_x/(nsteps-1);
delta_y =  range_y/(nsteps-1);

for ky = 1:nsteps 
	for kx = 1:nsteps;
		alignment_laser_mover_module( delta_x, 0, s_screen, s_pivot );
	end
	alignment_laser_mover_module( -nsteps*delta_x, delta_y, s_screen, s_pivot ); %reset x
end

% Restore the original mirror positions 
%lcaPut({'MIRR:IN20:154:AM1_MOTR_H'; 'MIRR:IN20:154:AM1_MOTR_V'; ...
		'ALS1:IN20:156:ALS1_POS'; 'ALS1:IN20:158:ALS2_POS' },...
		orig_mirror_config )


