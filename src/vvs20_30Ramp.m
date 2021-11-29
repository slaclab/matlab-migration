function [] = vvs20_30Ramp(type, varargin)
%
%   vvs20_30Ramp.m
%
%   This function ramps the VVS reference voltage, in 10 V increments.
%   Depending on the argument values, it ramps all VVSs or one, up or down.
%
%   If ramping down, it ramps to 90 V.
%
%   If ramping up, it ramps to 120 V, with 3 minute pauses between each
%   step.
%
%
%       Argument:
%                   type      string; "up" to ramp up, "down" to ramp down
%
%   	Optional Argument:
%                   loc       Sector name string, for example 'LI30'  
%
%       Return:
%                   None
%
%
%

% For error logging
facility = 'LCLS';

% Define goal volage
if (strcmp(type,'up'))
    goal  = 120;
    delay = 180;
elseif (strcmp(type,'down'))
    goal  = 90;
    delay = 10;
else
    message = sprintf('%s: Ramp type (up or down) not specified. Quitting.\n',mfilename);
    disp(message);
    gpLogMsg(facility,message);
    quit;
end

% Get VVS locations
if (length(varargin) == 1)
    loc = cellstr(varargin{1});
    numLoc = 1;
else
    try
        [loc,numLoc] = vvs20_30Common;
    catch
        message = sprintf('%s: Failed to get list of VVSs. Quitting.\n',mfilename);
        disp(message);
        gpLogMsg(facility,message);
        quit;
    end
end

% Done = 1 if VVS finished ramping, else = 0
% Init to 0
done = zeros(1,numLoc);

% Loop through VVSs, decrementing or incrementing voltage, as appropriate
% When all VVSs are at goal voltage, break
while(1)
    for i=1:numLoc
        disp(sprintf('location is %s\n',loc{i}));
        try
            refVoltage(i) = lcaGet(sprintf('VVS:%s:1:REFERENCE',loc{i}));
        catch
            err = lasterror;
            if strfind(err.identifier,'timedOut')
                msg = sprintf('%s VVS PV timed out. Quitting.',loc{i});
                message = sprintf('%s: %s\n',mfilename,msg);
                disp(message);
                gpLogMsg(facility,message);
                quit;
            else
                dbstack;
                rethrow(lasterror);
            end
        end
        if ((strcmp(type,'down')) && refVoltage(i) > (goal + 1))
            try
                lcaPut(sprintf('VVS:%s:1:VOLTAGE_DECRCMD',loc{i}),1);
            catch
                err = lasterror;
                if strfind(err.identifier,'timedOut')
                    msg = sprintf('%s VVS PV timed out. Quitting.',loc{i});
                    message = sprintf('%s: %s\n',mfilename,msg);
                    vvs20_30Err(msg);
                    disp(message);
                    gpLogMsg(facility,message);
                    quit;
                elseif strfind(err.message,'Write access denied')
                    msg = sprintf('User/host has no write permission. Quitting.');
                    message = sprintf('%s: %s\n',mfilename,msg);
                    vvs20_30Err(msg);
                    disp(message);
                    gpLogMsg(facility,message);
                    quit;
                else
                    dbstack;
                    rethrow(lasterror);
                end
            end
        elseif (refVoltage(i) < (goal - 1))
            try
                lcaPut(sprintf('VVS:%s:1:VOLTAGE_INCRCMD',loc{i}),1);
            catch
                err = lasterror;
                if strfind(err.identifier,'timedOut')
                    msg = sprintf('%s VVS PV timed out. Quitting.',loc{i});
                    message = sprintf('%s: %s\n',mfilename,msg);
                    vvs20_30Err(msg);
                    disp(message);
                    gpLogMsg(facility,message);
                    quit;
                elseif strfind(err.message,'Write access denied')
                    msg = sprintf('User/host has no write permission. Quitting.');
                    message = sprintf('%s: %s\n',mfilename,msg);
                    vvs20_30Err(msg);
                    disp(message);
                    gpLogMsg(facility,message);
                    quit;
                else
                    dbstack;
                    rethrow(lasterror);
                end
            end
        else
            done(i) = 1;
        end
    end
    if (length(nonzeros(done)) == numLoc)
        disp('All VVS done ramping')
        break;
    end
    pause(delay);
end
end

function [] = vvs20_30Err(msg)
nmsg=sprintf('ERROR: %s',msg);
uiwait(msgbox(nmsg,'Error - VVS Ramp Program'));
end
