function alignment_laser_mover_module( delta_x, delta_y, s_screen, s_pivot)
% Injector Alignment Laser Beam Mover Module
% J. Welch, 3/8/07
% Change alignment laser beam position on a chosen screen,
% while pivoting the beam  on another screen or location,
% eg. move 2 mm up, -3 mm right on screen YAGS1, while pivoting 
% about AM01. This module is called by
% alignment_laser_mover or alignment_laser_scanner

% PVs for mirror commands from Sheng. Not 100%
% sure they are accurately transcribed

% AM1		MIRR:IN20:154:AM1_MOTR_H
%			MIRR:IN20:154:AM1_MOTR_V
		
% ALS1	ALS1:IN20:156:ALS1_POS

% ALS2	ALS2:IN20:158:ALS2_POS

% Write data to PV in millimeters.


%Calculate the mirror changes required
theta_z = delta_x / (2 * ( s_pivot - s_screen) ); % mrad
delta_zm5 = - delta_x *( s_pivot - 0 ) / (s_screen - s_pivot) ;
delta_xm6 = - delta_y *( s_pivot - 0) / (s_screen - s_pivot) ;
theta_y = delta_xm6/(s_pivot - 0)  ; % mrad


% Get original mirror configuration
[orig_mirror_config, orig_timestamps] = ...
lcaGet( {'MIRR:IN20:154:AM1_MOTR_H'; 'MIRR:IN20:154:AM1_MOTR_V'; ...
		 'ALS1:IN20:156:ALS1_POS'; 'ALS1:IN20:158:ALS2_POS' } )

% Calculate the required command values to send to actuators
% based on Newport 605 series Precision Gimbal Optic Mount
% signs may be wrong!
AM1_constant = 48.48 ; %rad of rotation per m of actuator travel
AM2_constant = 48.48 ; %rad of rotation per m of actuator travel
delta_AM1_h_command = theta_y / AM1_constant  % mm = mrad / (rad/m)
delta_AM1_v_command = theta_z / AM2_constant  % mm = mrad / (rad/m)
delta_ALS1_command = delta_xm6
delta_ALS2_command = delta_zm5
delta_mirror_config = [ delta_AM1_h_command delta_AM1_v_command ...
	delta_ALS1_command delta_ALS2_command ]

% Send the required positions (absolute) to epics
lcaPut({'MIRR:IN20:154:AM1_MOTR_H'; 'MIRR:IN20:154:AM1_MOTR_V'; ...
		'ALS1:IN20:156:ALS1_POS'; 'ALS1:IN20:158:ALS2_POS' },...
		orig_mirror_config + delta_miror_config )


