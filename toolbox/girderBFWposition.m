function [ x, y ] = girderBFWposition ( segmentList )
%
% [ x, y ] = girderBFWposition ( segmentList )
%
% Report the x, y positions of bfws in the segment list relative
% to the home position.
%
% segmentList is an array of segment numbers, e.g. [1:3 5 22:33]
%
% x and y are arrays of postions in meters.
%

% construct dpa and dpb

geo = girderGeo(); 
n   = length ( segmentList );

x   = zeros ( 1, n );
y   = zeros ( 1, n );

for j = 1 : n
    segment   = segmentList ( j );
    camAngles = girderCamMotorRead ( segment ); % find the present motor angles
    p         = girderAngle2Axis ( geo.bfwz, camAngles );
    x ( j )   = p ( 1 );
    y ( j )   = p ( 2 );
end

end