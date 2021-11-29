function kmAngleBump(segmentNo, angleX, angleY, debug)
%
% function kmAngleBump(segmentNo, angle)
%
% Applies a bump to the electron beam that has an angle but no offset in
% segment segmentNo 3:33. The bump is not closed. Segments 1:2 cannot be
% used.
%
% Be sure to save initial corrector settings if you want to undo the bump.
%
% angles X/Y are in microradians
%
% if debug=1, no lcaPuts will be executed

% Check inputs
if length(segmentNo) ~= 1
    display('Can only make one bump at a time')
    return
end
if (segmentNo <3) || (segmentNo > 33)
    display('Can only make bumps in segments 3:33')
    return
end
if nargin < 4
    debug =0; % default is to actuall perform bmps
end


% make pvs
for q=1:33
    pvXcors(q,1) = {sprintf('XCOR:UND1:%d80:BCTRL',q)};
    pvYcors(q,1) = {sprintf('YCOR:UND1:%d80:BCTRL',q)};
    pvQuads(q,1) = {sprintf('QUAD:UND1:%d80:BCTRL',q)};
end

% Get intial values
GeV = lcaGet('BEND:LTU0:125:BACT');
initXcorrVals = lcaGet(pvXcors);
initYcorrVals = lcaGet(pvYcors);
qkG = lcaGet(pvQuads); % kG
qZ = undulatorQuadCenters; % same as correctors

% Calculate net kick angles for beam
kickNetX = kickNetCalc(segmentNo, angleX);
kickNetY = kickNetCalc(segmentNo, angleY);

% Scale the net kicks to kG-m
kickNetXkGm = kickNetX *1e-6 * GeV/0.03;
kickNetYkGm = kickNetY *1e-6 * GeV/0.03;

% Calculate the quad kicks implied
m = segmentNo;
kickQuadXkGm(33,1) = 0; % initialize
kickQuadYkGm(33,1) = 0; % initialize
kickQuadXkGm(m-1) = -( kickNetXkGm(m-2) * (qZ(m-1) - qZ(m-2)) ) * qkG(m-1) *.03/GeV;
kickQuadYkGm(m-1) =  ( kickNetYkGm(m-2) * (qZ(m-1) - qZ(m-2)) ) * qkG(m-1) *.03/GeV;

% Calculate corrector deltas to apply
kickXcorrkGm = kickNetXkGm - kickQuadXkGm;
kickYcorrkGm = kickNetYkGm - kickQuadYkGm;

% Apply the corrector kicks
XcorVal = initXcorrVals; % intialize
YcorVal = initYcorrVals;
if any(  abs(XcorVal + kickXcorrkGm) >.0054 ) ||...
   any(  abs(YcorVal + kickYcorrkGm) >.0054 )
    display('Correctors set beyond limits! Reduce bump size!')
end
try
%     display('Attempting to implement bump');
%     display(XcorVal + kickXcorrkGm) ;
%     display(YcorVal + kickYcorrkGm) ;
if ~debug
    lcaPut(pvXcors, XcorVal + kickXcorrkGm);
    lcaPut(pvYcors, YcorVal + kickYcorrkGm);
end

catch
    display('Could not changes all correctors properly')
end
    
function kickNet = kickNetCalc(m, angle)
%   kickNet = kickNetCalc(m, angle)
%
% return a kick array that produce the desire bump angle for segment m
% taking into account the quadrupoles

segZ = segmentCenters;
qZ = undulatorQuadCenters; % same as correctors
kickNet(33,1) = 0; % intial to 33,1 array

% calculate the require combined kick from quads and correctors
kickNet(m-2) = -angle * ( segZ(m) - qZ(m-1) ) / ( qZ(m-1) - qZ(m-2) );
kickNet(m-1) = angle - kickNet(m-2);


