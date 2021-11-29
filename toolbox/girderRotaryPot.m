function [readback, offsets] = girderRotaryPot(segmentNo)
%
% Read the rotary potentiometers (degrees) on the cams for the specified girder
%
% segmentNo  is an integer 1 through 33
% girderPotReadback = [LP1 - LP9] (mm) from all linear pots
%

% construct PVs for readbacks
segmentString = ['U' num2str(segmentNo)];
if segmentNo < 10
    segmentString = ['U0' num2str(segmentNo)];
end

for i=1:5
    pvs(i) = { [segmentString ':CM' num2str(i) ':readDeg']};
end
pvs = pvs';

% get data
[readback,ts] = mlcaGetSmart(pvs);
readback = readback';

% construct PVs for offsets
for i=1:5
    pvs(i) = { [segmentString ':CM' num2str(i) ':ZeroOffsetC']};
end
pvs = pvs;% can't seem to get columns and rows straight

% get data
[offsets,ts] = mlcaGetSmart(pvs);
offsets = offsets';
