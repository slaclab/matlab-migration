% this file finds the motion of the mirrors necesary to get the beam where
% we want it on Screens 1 and 2.

% It takes in the current position, the desired position and the
% calibration matrix elements.  It performs one axes at a time, because why
% not?

% Each entry should be a struct.  For example:
% current_in.x1, current_in.x2 and so on.

function [M] = mirror_motion_solver(current_in, desired_in,calib)



% DESIRED - CURRENT = C * M
% or D - H = C * M
% So M = inv(C) * (D - H)


% Start with x.
C = [calib.xC11, calib.xC12; calib.xC21, calib.xC22];
D = [desired_in.x1; desired_in.x2];
H = [current_in.x1; current_in.x2];

if strcmp(H,'double') == 0;
    H = double(H);
end

temp_M = C \ (D - H);

M = temp_M;

% keyboard

% now y.
C = [calib.yC11, calib.yC12; calib.yC21, calib.yC22];
D = [desired_in.y1; desired_in.y2];
H = [current_in.y1; current_in.y2];

if strcmp(H,'double') == 0;
    H = double(H);
end

temp_M = C \ (D - H);

M = [M, temp_M];

M = -M;  % This minus sign is necessary.  I am not sure why.