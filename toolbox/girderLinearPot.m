function [girderPotReadback, offsets] = girderLinearPot(segmentNo)
%
% [girderPotReadback, offsets] = girderLinearPot(segmentNo)
%
% Read the linear potentiometers on the cams for the specified girder
%
% segmentNo  is an integer 1 through 33
% girderPotReadback = [LP1 - LP9] (mm) from all linear pots
%

% construct PVs for calculated position
segmentString = ['U' num2str(segmentNo)];
if segmentNo < 10
    segmentString = ['U0' num2str(segmentNo)];
end

for lpnum=1:9
    pvs(lpnum,1) = { sprintf('USEG:UND1:%d50:LP%dPOSCALC',segmentNo, lpnum) };
end


% get data
[girderPotReadback,ts] = lcaGetSmart(pvs);
girderPotReadback=girderPotReadback';


% construct PVs for calculated position

for lpnum=1:9
    pvsOffset(lpnum,1) = { sprintf('USEG:UND1:%d50:LP%dOFFSETC',segmentNo, lpnum) };
end


% get data
[offsets,ts] = lcaGetSmart(pvsOffset);
offsets = offsets';
