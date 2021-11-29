function girderAxisMove(segmentList, dpa, dpb, droll)
%
%    girderAxisMove(segmentList, dpa, dpb, droll)
%
% Move the girder axis by dpa and dpb (Delta move)
%
% dpa [ dx1 dy1 za; dx2 dy2 za...], dpb = [dx1 dy1 zb; dx2 dy2 zb...], 
% droll = [dthetaz1 dthetaz2]. Each row corresponds to a segment number
% in  segmentList. If only one row of dpa or dpb is given, all segments
% will be given the same move.
%
% segmentList a vector of segment numbers, e.g. [1:3 13:33]
%

% Get the present Set positions at za and zb
nsegs = length(segmentList);
pa = zeros(nsegs, 3); % initialize
pb = zeros(nsegs, 3); % initialize
roll = zeros(1,nsegs); % initialize

if nargin==3
    droll = roll;
end

% Fill out dpa, dpb, and droll arrays if needed
[aRows, cols] = size(dpa);
[bRows, cols] = size(dpb);
[rRows, cols] = size(droll);
nSegs = length(segmentList);
if aRows < nSegs
    for p=2:length(segmentList)
        dpa(p,:) = dpa(1,:); % make same as first row
    end
end
if bRows < nSegs
    for p=2:length(segmentList)
        dpb(p,:) = dpb(1,:);  % make same as first row
    end
end
if rRows < nSegs
    for p=2:length(segmentList)
        droll(1,p) = droll(1);  % make same as first row
    end
end

% Loop through segments to get new positions
for p=1:length(segmentList)
    segmentNo = segmentList(p);

    camAngles = girderCamMotorRead(segmentNo); % find the present motor angles

    % calculate theoretical pa and pb and roll
    [pa(p,:), roll(p)] = girderAngle2Axis(dpa(p,3), camAngles);
    [pb(p,:), roll(p)] = girderAngle2Axis(dpb(p,3), camAngles);

    % add the deltas to the present Set position
    pa(p,1:2) = pa(p,1:2) + dpa(p,1:2);
    pb(p,1:2) = pb(p,1:2) + dpb(p,1:2);
    roll(p) = roll(p) + droll(1,p);

    pa(p,3) = dpa(p,3);
    pb(p,3) = dpb(p,3);

end

% set the new values simultaneously
girderAxisSet(segmentList, pa, pb, roll)
