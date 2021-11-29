function [newOffsets, oldOffsets] = girderLinearPotZero(segmentList)
%
%  [newOffsets, oldOffsets] = girderLinearPotZero(segmentList)
% 
% Set the offsets in the girder linear pots so girder positions read zero
% for all segments in segmentList 
% 
% segmentList is an array of segment numbers, e.g. [1:4 22 31:33]
%

for p=1:length(segmentList)
    segmentNo = segmentList(p);
    [LP,offsets] = girderLinearPot(segmentNo); % get the raw data
    % 1 = LP1-'Y' Wall -x side 3-cam plane (upstream)
    % 2 = LP2-'Y' Aisle +x side 3-cam plane
    % 3 = LP3-'X' 2-cam plane
    %
    % 5 = LP5-'Y' Wall -x side, 2-cam plane (downstream)
    % 6 = LP6-'Y' Aisle +x side, 2-cam plane (downstream)
    % 7 = LP7-'X' 3-cam plane (downstream)
    %

    oldOffsets = offsets;

    newOffsets = LP + offsets;% this should make the calculated position = zero.

    % put in new offsets - just the six linear pots for the girder motion
    segmentString = ['U' num2str(segmentNo)];
    if segmentNo < 10
        segmentString = ['U0' num2str(segmentNo)];
    end

    pv1 = [segmentString ':LP1:zeroOffsetC'];
    mlcaPut(pv1,newOffsets(1));
    pv2 = [segmentString ':LP2:zeroOffsetC'];
    mlcaPut(pv2,newOffsets(2));
    pv3 = [segmentString ':LP3:zeroOffsetC'];
    mlcaPut(pv3,newOffsets(3));
    pv5 = [segmentString ':LP5:zeroOffsetC'];
    mlcaPut(pv5,newOffsets(5));
    pv6 = [segmentString ':LP6:zeroOffsetC'];
    mlcaPut(pv6,newOffsets(6));
    pv7 = [segmentString ':LP7:zeroOffsetC'];
    mlcaPut(pv7,newOffsets(7));

end
