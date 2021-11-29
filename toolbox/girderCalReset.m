function  girderCalReset(segmentList)
%
%  [newOffsets, oldOffsets] = girderCalReset(segmentList)
%
% Resets the all motor angle to match the rotary pot angles. Move girder to
% new home position Resets the linear pots to read zero
%
% Use this if the rotary pots angle is believed, but the motor is dubious
%
% segmentList is an array of segment numbers, e.g. [1:4 22 31:33]
%


% Turn off all Smart Monitors
for p=1:length(segmentList) % construct individual PVs
    segmentNo = segmentList(p);
    pvSM(p,1) = { sprintf('USEG:UND1:%d50:SMRTMONITORC',segmentNo) };
end
SMonOff = cell(length(segmentList),1);
SMonOff(:) = {'Off'};
lcaPut(pvSM,SMonOff);
pause(1); % give the monitor a chance to turn off



% Loop over segment, resetting one at a time
for p=1:length(segmentList)
    segmentNo = segmentList(p);

    % get rotary pot readbacks
    [readbacks,offsets] = girderRotaryPot(segmentNo);

    % Put all motors in SET mode
    for camNo=1:5 % construct individual PVs for each cam
        pvSet(camNo,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.SET',segmentNo, camNo) };
    end
    setArray = cell(5,1);
    setArray(:,1) = {'Set'};
    lcaPut(pvSet,setArray);

    % Set motor angle so motor angles match rotary pots
    for camNo=1:5
        pvCam(camNo,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.VAL',segmentNo, camNo) };
    end
    motorSetPoints = readbacks;
    lcaPut(pvCam,motorSetPoints');
    pause(1);
    
    % Set to MOVE if is in STOP state
    for camNo=1:5
        pvMove(camNo,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.SPMG',segmentNo, camNo) };
    end
    moveArray = cell(5,1);
    moveArray(:,1) = {'Go'};
    lcaPut(pvMove,moveArray);
    pause(1);


    % change motor.SET to 'USE'
    setArray(:,1) = {'Use'};
    lcaPut(pvSet,setArray);
end


% restore smart monitor ON status
SMonOff(:) = {'On'};
lcaPut(pvSM,SMonOff);


% Move to new home position
girderCamSet(segmentList, [0 0 0 0 0]);

% Reset Linear Pots to zero
girderCamWait(segmentList);
girderLinearPotZero(segmentList);
