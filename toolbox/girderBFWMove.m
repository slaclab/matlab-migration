function girderBFWMove(segmentList, dx, dy)
%
%  girderBFWMove(segmentList, dx, dy)
%
% Move the BFWs (beam finder wires) in the segment list by dx, and dy, while keeping the
% quadrupoles in the present position. 
%
% segmentList is an array of segment numbers, e.g. [1:3 5 22:33]
%
% dx and dy are arrays of "delta" moves in millimeters.If the number of
% segments to move is m, then dx and dy are mx1 arrays, except if
% only one row for dx or dy is given, then all segments in the list will be
% given the same move.
%

% construct dpa and dpb
geo = girderGeo(); 
dpa = zeros(length(segmentList),3);
dpb = zeros(length(segmentList),3);

dpa(:,1) = dx;
dpa(:,2) = dy;
dpa(:,3) = geo.bfwz;

dpb(:,3) = geo.quadz;

% make the move
girderAxisMove(segmentList, dpa,dpb)