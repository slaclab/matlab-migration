function [success,badis,pvVals] = pollPV( pvNames, goodVals, Ntries, pausePeriod )
% pollPV polls a given PV a given number of times, until either the
% returned value is equal to a given returned value (success) or
% the given retry count is exhaused (failure), or it detects a
% communication error (failure).
% PVNAME EPICS CA Process variable names. Cell array of strings. The given
% pv must be acquireable as short value.
% GOODVALS The values of the PVNAME PVs which is considered
% good. Row vector.
% NTRIES must be >= 1. 1 just means do the check only once, don't poll.
% PAUSEPERIOD is time in seconds to wait between each set of reads of the pv statuses.    

i=1;
success=false;
abort=false;
% oks=int16(goodVals)';    % cast to type of lcaGetStatus

while i<=Ntries && ~success 
    pvVals=lcaGet( pvNames,0,'short' );
    conditionArray=pvVals-goodVals';  % If any elem val ~= 0 that's bad
    badis=find(conditionArray);    % indexes of any bad ones
    if isempty(badis)
        success=true;
        return;
    else
        if (i<Ntries), pause(pausePeriod), end   % Pause only if there will be another iter
    end
    i=i+1;
end

