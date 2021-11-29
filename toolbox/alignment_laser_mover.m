function alignment_laser_mover( )
% Injector Alignment Laser Beam Positioning Program
% J. Welch, 3/8/07
% Change alignment laser beam position on a chosen screen,
% while pivoting a constant beam position on another screen orlocation,
% eg. move 2 mm up, -3 mm right on screen YAGS1, while pivoting 
% about AM01. This function requires user input.


Program_intro = {'Program to move the injector alignment laser beam spot'; ....
 'at one screen, while keeping it fixed on another. '}

screen_names = [ 'AM01   '; 'YAG01  '; 'CR01   '; 'YAG02  '; 'YAGG1  ';...
    'CRG1   '; ...
    'YAG03  '; 'YAG04  '; 'OTR1   '; 'OTR2   '; 'OTR3   '; 'YAGS1  ' ] ;
screen_dist_M3 = [ 0.35; 0.96; 1.57; 1.74; 2.19; 2.2; 4.97; 10.59; ...
    12.67; 14.59; 16.5; 18.94 ] ;  % distance from M3 (tilting mirror)
%screen_dist_M3_str = num2str(screen_dist_M3);
screen_dist_table = [screen_names num2str(screen_dist_M3)]

% Get user input
s_screen = input('Enter screen location for beam motion [m]... ') ;% change x,y here
s_pivot = input('Enter location of pivot [m]...') ; %fix x,y here
delta_x = input('Enter delta x [mm] to move... ') ; %beam x change
delta_y = input('Enter delta y [mm] to move... ') ; %beam y change

% Call mover module to perform motion
alignment_laser_mover_module(delta_x, delta_y, s_screen, s_pivot )


