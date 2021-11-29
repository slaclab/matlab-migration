function  girderCamSet(segmentList, angles, debug)
%
%    girderCamSet(segmentList, angles, debug)
%
% Simultaneously move the cam motors for all segments in segmentList to
% the specified angles [radians!] and update the associated bpm offsets.
%
% segmentList is an array of segment numbers, e.g. [1 2:23 33]
% angles is an array of angles in radians, e.g.
%     [ phi1 phi2 phi3 phi4 phi5
%        . . .
%       phi1 phi2 phi3 phi4 phi5 ]
% one row for each segment in the list.
%
% If only one row of angles is given, all segments will be given the same
% angles.
%
% if debug input is present (it could be anything), then the cams are not changed

% check inputs
angleSets = size(angles);
if ~(angleSets(1) == length(segmentList) || ...
        angleSets(1)==1)
    display('Set of angles does not match segmentList');
    display(segmentList);
    display(angles);
    display('Please try again');
    return;
end

% % sort segmentList and angles to get segment 1 first if it exist
% [segmentList, IX] = sort(segmentList); 
% angles = angles(IX,:);

% construct individual PVs
for p=1:length(segmentList)
    for m=1:5
        segmentNo = segmentList(p);
        camNo = m;
        pvs(5*p -5+m,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.VAL',segmentNo, camNo) };
    end
    pvsStatus(p,1) = { sprintf('USEG:UND1:%d50:CAMSMOVINGM',segmentNo) };
end

% check for moving motors
[motorStatus,ts] = lcaGetSmart(pvsStatus);
if (  any(motorStatus)  )
    display('Cam motors are moving, please wait and try again');
    return;
end

% save the current cam angle settings in case something bombs
[currentMotorSettings, ts] = lcaGetSmart(pvs);

% prepare angles
camAngles = angles;
if angleSets(1) == 1 %only one set of angles given, copy to all segments
    for p=1:length(segmentList)
        camAngles(p,:) = angles;
    end
    camAnglesVector = reshape(camAngles', 5*length(segmentList),1 );
else
    camAnglesVector = reshape(camAngles', 5*length(segmentList),1 );
end
values = (180/pi)*camAnglesVector;

% Get present and future BPM positions. Note there are 34 bpms for 33
% girders and girder 1 moves two bpms, Ugh. Present values collected for
% restore in case of crash.

geo=girderGeo; % for z position data

if any(segmentList == 1); % RFBU00 case

    % present BPM positions
    posBPM0_00(1,:) = girderAxisFind(1,geo.bpm00z,geo.quadz);%RFBU00
    posBPM0=girderAxisFind(segmentList,geo.bpmz,geo.quadz); %other BPMs
    posBPM0 = [posBPM0_00; posBPM0]; %[ x y z; x y z;...] RFBU00 is first 

    % future BPM positions
    posBPM1(1,:) =  girderAngle2Axis(geo.bpm00z, camAngles( (segmentList == 1),: ) );  % RFBU0 case
    for p=1:length(segmentList) % other BPMs
        posBPM1(p+1,:) = girderAngle2Axis(geo.bpmz, camAngles(p,:));
    end
    BPM = (  posBPM1(:,1:2) - 0 )';% [x x x...; y y y...] % updated for XOFF.B field change 3/31/10
    
else % no RFBU00
    % present BPM positions
    posBPM0=girderAxisFind(segmentList,geo.bpmz,geo.quadz); %only geo.bpmz axis point

    % future BPM positions
    for p=1:length(segmentList)
        posBPM1(p,:) = girderAngle2Axis(geo.bpmz, camAngles(p,:));
    end
    BPM = (  posBPM1(:,1:2) - 0 )';% [x x x...; y y y...]  updated for XOFF.B field change 3/31/10
end

% Update the associated BPM offsets
pvList=model_nameConvert({'BPMS'},'EPICS','UND1'); % all 34 pvs ...100 is RFBU00
segIndex = segmentList + 1;
if any(segmentList == 1) % if girder 1 is used, then include RFBU00 in pvList
    pvList = pvList([ 1 segIndex]); % just bpms that are changed
else % don't include RFBU00
    pvList=pvList(segIndex);
end
pvOff=[strcat(pvList(:),':XOFF.B') strcat(pvList(:),':YOFF.B')]'; % updated for XOFF.B field change 3/31/10
off=lcaGet(pvOff(:)); % present offset values

%  if debug mode, test lcaPuts but don't change anything
if nargin==3;
    display('girderCamSet is called in debug mode');
    [values ts] = lcaGet(pvs);
    lcaPutNoWait(pvs, values);
    lcaPut(pvOff(:),off);
    display(off);
    display(BPM);
    return
end

% Send commands to motors and bpms
try % send new angles to motors
    lcaPutNoWait(pvs, values) ;%use NoWait because it is so slow it times out
    % lcaPut(pvOff(:),off+dBPM(:)); % 
    lcaPut(pvOff(:), BPM(:)); % updated for XOFF.B field change 3/31/10
catch %restore  motors settings and bpm offsets
    display('Unable to change motors,attempting to restore.')
    lcaPut(pvs,currentMotorSettings);
    lcaPut(pvOff(:),off); 
end



