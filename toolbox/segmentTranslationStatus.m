function status = segmentTranslationStatus(segmentList)
%
% status = segmentTranslateStatus(segmentList)
%
% returns the current translation status of the segments in segmentList
% 
%  status's:   1= moving, 0 = not moving
%
% position is an array 1:33 of segment translations

if nargin == 0
    segmentList = 1:33;
end

% make PVs
for p=1:length(segmentList)
    pvs{p}  = sprintf('USEG:UND1:%d50:LOCATIONSTAT',segmentList(p));
end

% get data
val = lcaGetSmart(pvs);
%status(length(segmentList)) = 0; %initialize
status(segmentList) = strcmp('MOVING',val);

% exclude special girders
status(9) = 0; %SXRSS
status(33) = 0; %DELTA