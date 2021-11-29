function [success,badis] = pollPVSeverity( pvNames, pvMaxSevrSuccessConds, Ntries, pausePeriod )
% pollPV polls a given PV a given number of times, until either the
% returned value is equal to a given returned value (success) or
% the given retry count is exhaused (failure), or it detects a
% communication error (failure).
% PVNAME must be a valid EPICS CA Process variable name. The given
% pv must be acquireable as short value.
% PVMAXSEVRSUCCESSCOND ok == severity of PV <= PVMAXSEVRSUCCESSCOND
% Eg, if a PV has MINOR severity, and PVMAXSEVRSUCCESSCOND is MINOR, then
% that will be treaded as ok severity. If the PV had MAJOR severity
% the cehck would fail, pollPVSeverity would return false.
% the pv's valexue, pollFWS will return success
% pausePeriod in seconds, but may be fractional.
% NTRIES must be >= 1. 1 just means do the check only once, don't poll.
% PAUSEPERIOD is time in seconds to wait between each set of reads of the pv statuses.    
%
% throws exception per http://www.slac.stanford.edu/~strauman/labca/manual/node4.html
% when channel access I/O error. 
% -----------------------------------------------------------------------------
% Auth: G. White, 14-Mar-2018
% Mod:
% =============================================================================
i=1;
success=false;
abort=false;
maxOkSeverities=int16(pvMaxSevrSuccessConds)';    % cast to type of lcaGetStatus

while i<=Ntries && ~success 
    pvSeverities=lcaGetStatus( pvNames );
    conditionArray=pvSeverities-maxOkSeverities;  % If any condArray elem val >0 that's bad
    badis=find(conditionArray>0);
    if isempty(badis)
        success=true;
        return;
    else
        if (i<Ntries), pause(pausePeriod), end   % Pause if there will be another iter
    end
    i=i+1;
end

