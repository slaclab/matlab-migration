function [] = vvs20_30CloseBreaker()
%
%   vvs20_30CloseBreaker.m
%
%   This function closes the breaker of all LI20-LI30 VVSs. 
%   It first checks that the VVS breaker is not already closed.
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


% Define breaker closed string
breakerClosed = 'ON';

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

% Loop through VVSs, closing breaker if it is not already closed
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
    if (~strcmp(breakerState,breakerClosed))
        try
            lcaPut(sprintf('VVS:%s:1:BREAKER_CLOSECMD',loc{i}),1);
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


