function [camAngleReadback] = girderCamPot(segmentNo)
% Read the rotary potentiometers on the cams for the specified girder
%
% segmentNo  is an integer 1 through 33
% camAngleReadback = [phi1 phi2 phi3 phi4 phi5] (radians) from rotary pots

% construct PVs
segmentString = ['U' num2str(segmentNo)];
if segmentNo < 10
    segmentString = ['U0' num2str(segmentNo)];
end

for i=1:5
    pvs(i) = { [segmentString ':CM' num2str(i) ':motor.RBV']};
end
pvs = pvs';

[camAngleReadback,ts] = mlcaGetSmart(pvs);
camAngleReadback = (pi/180)*camAngleReadback';
%display(camAngleReadback);
% send commands
