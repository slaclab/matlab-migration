function girderAxisSet(segmentList, pa, pb, roll)
%
%    girdersAxisSet(segmentList, pa, pb, roll)
%
% Moves girder axes to go through points pa and pb with optional roll.
% Returns immediately, does not wait for motion to finish. Use
% girderCamWait if you need to wait. (this is for continuously
% updating displays for instance).
% 
% segmentList is an array of segment numbers of segments to move, 
% e.g. [1 2:14 31 33].
%
% pa/pb are arrays of the x, y, z coordinates [mm] of points that you want the
% axes to go through. 
%
% roll is an 1D of roll angles in radians. The row
% goes with the corresponding segment in the segment list.
%
% If pa, pb, or r has only one row, the same axes points and roll will be
% used for all segments in the list.
%
% Example: Suppose you want the segment 26 quad at x=1 mm and y = 0 mm, and the 
% BFW at x=0 and y=0. Suppose you also want the segment 33 quad at x= -1 mm and y =
% 0.5 for the BFW.  First get the z positions: geo = girderGeo, then
% pa = [1 0 geo.quadz; -1 .5 geo.quadz], and 
% pb = [0 0 geo.bfwz; 0 0 geo.bfwz]
% run the command girderAxisSet([26 33], pa, pb)


camAngles = [0 0 0 0 0]; %initialize

% Allow for missing roll argument
if nargin == 3
    roll(length(segmentList)) = 0;
end

% Fill out pa, pb, and roll arrays if needed
[aRows, cols] = size(pa);
[bRows, cols] = size(pb);
[rRows, cols] = size(roll);
nSegs = length(segmentList);
if aRows < nSegs
    for p=2:length(segmentList)
        pa(p,:) = pa(1,:); % make same as first row
    end
end
if bRows < nSegs
    for p=2:length(segmentList)
        pb(p,:) = pb(1,:);  % make same as first row
    end
end
if rRows < nSegs
    for p=2:length(segmentList)
        roll(p) = roll(1);  % make same as first row
    end
end
    
    
% Calculate the angles needed
for p=1:length(segmentList)
    camAngles(p,:) = girderAxis2Angle(pa(p,:), pb(p,:), roll(p));
end

% Move girder to new angles
girderCamSet(segmentList, camAngles);

% Wait for motion to finish
%girderCamWait(segmentList);
% 
% % Measure actual position of cam axis, use first segment to set z planes
% % for all
% [p2m, p3m, rollm] = girderAxisMeasure(segmentList, pa(1,3), pb(1,3) ); % displacement at cam planes
% 
% % Extrapolate to pa an pb planes
% pam = p2m + ( (pa(1,3) - p2m(3))/(p3m(3) - p2m(3)) ) * (p3m-p2m);
% pbm = p2m + ( (pb(1,3) - p2m(3))/(p3m(3) - p2m(3)) ) * (p3m-p2m);
