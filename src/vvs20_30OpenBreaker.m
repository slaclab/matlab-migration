function [] = vvs20_30OpenBreaker()
%
%   vvs20_30OpenBreaker.m
%
%   This function opens the breaker of all LI20-LI30 VVSs. 
%   It first checks that the VVS breaker is not already open.
%
%
%   	Arguments:
%                   None
%
%       Return:
%                   None
%
%
%


% Define breaker open string
breakerOpen = 'OFF';

% For error logging
facility = 'MATLAB';

% Get VVS locations
try
    [loc,numLoc] = vvs20_30Common;
catch
    message=sprintf('%s: Failed to get list of VVSs. Quitting.\n',mfilename);
    disp(message);
    gpLogMsg(facility,message);
    quit;
end

% Loop through VVSs, opening breaker if it is not already open
for i=1:numLoc
    try
        breakerState(i) = lcaGet(sprintf('VVS:%s:1:BREAKER_TIU',loc{i}));
    catch
        err = lasterror;
        if strfind(err.identifier,'timedOut')
            message=sprintf('%s: %s VVS PV timed out. Quitting.\n',mfilename,loc{i});
            disp(message);
            gpLogMsg(facility,message);
            quit;
        else
            dbstack;
            rethrow(lasterror);
        end 
    end
    if (~strcmp(breakerState,breakerOpen))
        try
            lcaPut(sprintf('VVS:%s:1:BREAKER_OPENCMD',loc{i}),1);
        catch
            err = lasterror;
            if strfind(err.identifier,'timedOut')
                message=sprintf('%s: %s VVS PV timed out. Quitting.\n',mfilename,loc{i});
                disp(message);
                gpLogMsg(facility,message);
                quit;
            else
                dbstack;
                rethrow(lasterror);
            end
        end            
    end
end


