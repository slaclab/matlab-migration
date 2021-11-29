function motorStatus = girderMotorStatusRead(segmentNo)
%
% motorStatus = girderMotorStatusRead(segmentNo)
%
% Return the overall moving status of a given segment
% Returns either, 'Ready', 'Moving', 'Hung',or 'E stop'

% construct PVs
for camNo=1:5
    pvsStatus(camNo,1) = { sprintf('USEG:UND1:%d50:CM%dMOTOR.MOVN', segmentNo, camNo) };% moving status
    pvsPositionError(camNo,1) = { sprintf('USEG:UND1:%d50:CM%dMOTORSTAT',segmentNo, camNo) } ;% 'Position Error', 'Normal'
end
pvsCamStatus = sprintf('USEG:UND1:%d50:CAMSMOVINGM',segmentNo);% 1 moving 0 if not
pvsEstopStatus = sprintf('USEG:UND1:%d50:ESTOPSTATUSM',segmentNo);% 'no stop' or 'stop'
pvsSummaryStatus =  { sprintf('USEG:UND1:%d50:CM:STATSUMY.SEVR', segmentNo) };% overall functionality

% Get current statuses
[motorStatus,ts] = lcaGetSmart(pvsStatus);
[camStatus,ts] = lcaGetSmart(pvsCamStatus);
[eStopStatus,ts] = lcaGetSmart(pvsEstopStatus);
[positionErrorStatus,ts] = lcaGetSmart(pvsPositionError);
[summaryStatus,ts] = lcaGet(pvsSummaryStatus);

if  (  any(isnan(motorStatus)) ) % if there are NaN return Hung
  motorStatus = 'Hung';
  return
end
if  (  any(isnan(camStatus)) ) % if there are NaN return Hung
  motorStatus = 'Hung';
  return
end
if (any(strcmp(eStopStatus,'stop') ) ) % if there is Estop status
    motorStatus = 'E stop';
    return;
end

% if (  any(motorStatus)  ) %if any not zero
%     motorStatus = 'Moving';
%     return;
% end

% if ( ~any(motorStatus) && camStatus) % motors not moving, but cam moving status says moving
%     motorStatus = 'Hung';
% end

% if (any(strcmp(positionErrorStatus,'Position Error') ) ) % when this happens nothing moves
%     motorStatus = 'Hung';
% end

if (strcmp(summaryStatus, 'MAJOR') || strcmp(summaryStatus,'INVALID')) % return Hung if any problems prevent moving or communication
    motorStatus = 'Hung';
    return;
end

% if ( ~any(motorStatus) && ~camStatus ) % ready to be moved
%     motorStatus = 'Ready';
% end

if ( camStatus) % at least one cam is moving
    motorStatus = 'Moving';
end
if (  ~camStatus ) % no cams are moving
    motorStatus = 'Ready';
end


