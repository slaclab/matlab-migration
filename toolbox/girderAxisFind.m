function [pa, pb, roll] = girderAxisFind(segmentList, za, zb)
%
% [pa, pb, roll] = girderAxisFind(segmentList, za, zb)
%
% Returns current [x y z] position of the girder axis for specified z coordinates
% as well as the roll.
%
% segmentList is an array of segment numbers of segments to move, e.g. [1
% 2:14 31 33].
%
% pa/pb are arrays of the x, y, z coordinates [mm] of points that the axes
% to go through. Each row of the array corresponds to a girder in the
% segmentList.
%
% roll is an 1D of roll angles in radians. The row goes with the
% corresponding segment in the segment list
%
% za, and zb, are the z coordinates in the girder coordinate system of
% points of interest For example the quad center is at za = 1807.9 mm and
% the BFW is at z = -1795.3 mm. Units are mm and radians. 
%
% This function calculates girder axis based on the motor readback angles -
% not based on the linear potentiometer readings.
%
% Useful z locations can be obtained via the structure geo which is obtained via 
% geo = girderGeo(). geo.quadz = 1807.9, etc.

nsegs =length(segmentList);
camAngles = zeros(nsegs,5); % preallocate. It really doesn't matter.
pa = zeros(nsegs,3);
pb = zeros(nsegs,3);
roll = zeros(nsegs,1);

for p=1:length(segmentList)
    segmentNo = segmentList(p);
% get the cam angles
camAngles(p,:) = girderCamMotorRead(segmentNo);

% calculate pa and pb and roll
[pa(p,:), roll(p,1)] = girderAngle2Axis(za, camAngles(p,:));
[pb(p,:), roll(p,1)] = girderAngle2Axis(zb, camAngles(p,:));
end

% That's all folks!