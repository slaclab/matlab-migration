function status = girderCamWaitLess(segmentList)
%
%   status = girderCamWaitLess(segmentList)
%
% wait for all cams in all segments in list to stop moving, then return
%
% segmentList is an array of segment number, e.g. [1 3:5, 25:33]
% 
% status is an optional output argument. status = 1 if moves are completed
% without errors, otherwise status = 0
%
% If a cam becomes "hung" or the emergency stop is set, girderCamWaitLess will
% ignore it so that it doesn't wait forever. 


pause(1); % make sure status pvs are updated
status = 1;
% check for moving motors
notReady(length(segmentList)) = 1; % notReady = 1 means moving or hung
while any(notReady);
    for p=1:length(segmentList) % Loop until all are either Ready or Hung
        segmentNo = segmentList(p);
        motorStatus = girderMotorStatusRead(segmentNo); % returns 'Moving', 'Hung',  'Ready', 'E stop'
        if  strcmp('Ready', motorStatus);
            notReady(p) = 0;
        elseif strcmp('Moving',motorStatus) ;
            notReady(p) = 1;
            pause(2);
        elseif strcmp('Hung',motorStatus)
            notReady(p) = 0; % return rather than wait forever
            status = 0;
        elseif strcmp('E stop', motorStatus)
            notReady(p) = 0; % return rather than wait forever
            status = 0;
        end
    end
end
%pause(1); % make sure other pvs update before returning


