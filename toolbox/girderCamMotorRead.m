function [camAngleReadbacks] = girderCamMotorRead(segmentList)
% 
% [camAngleReadbacks] = girderCamMotorRead(segmentList)
%
% Return the cam motor angles in radians for  segments in the list
%
% segmentList is an array of segment numbers, e.g.  [1, 3:12, 22] 
% camAngleReadbacks = [phi1 phi2 phi3 phi4 phi5;... ] (radians) from motor
% readback. Row n coresponds to the segment number in the nth entry of the
% segmentList

% construct PVs

for p=1:length(segmentList)
    for m=1:5
        segmentNo = segmentList(p);
        camNo = m;
        pvs(5*p -5+m,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.RBV',segmentNo, camNo) };
    end
end

[camAngleReadbacks,ts] = lcaGetSmart(pvs);
camAngleReadbacks = (pi/180)*camAngleReadbacks;
camAngleReadbacks = reshape(camAngleReadbacks,5, length(segmentList) );
camAngleReadbacks = camAngleReadbacks';
