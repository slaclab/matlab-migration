function [] = vvs10Ramp(type, varargin)
%
%   vvs10Ramp.m
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
%                   loc       Sector name string, for example 'LI10'  
%
%       Return:
%                   None
%
%
%

% For error logging
facility = 'FACET';

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
    loc = varargin{1};
    numLoc = 1;
else
    loc = 'LI10';
end

% Done = 1 if VVS finished ramping, else = 0
% Init to 0
done = 0;

% Decrementing or incrementing VVS voltage, as appropriate
% When VVSs is at goal voltage, break
while(1)
    disp(sprintf('Location is %s\n',loc));

    try
        refVoltage = lcaGet(sprintf('VVS:%s:1:REFERENCE',loc));
    catch
        err = lasterror;
        if strfind(err.identifier,'timedOut')
            msg = sprintf('%s VVS PV timed out. Quitting.',loc);
            message = sprintf('%s: %s\n',mfilename,msg);
            vvs10Err(msg);
            disp(message);
            gpLogMsg(facility,message);
            quit;
        else
           dbstack;
           rethrow(lasterror);
        end
    end

    if ((strcmp(type,'down')) && refVoltage > (goal + 1))
        try
            lcaPut(sprintf('VVS:%s:1:VOLTAGE_DECRCMD',loc),1);
        catch
            err = lasterror;
            if strfind(err.identifier,'timedOut')
                msg = sprintf('%s VVS PV timed out. Quitting.',loc);
                message = sprintf('%s: %s\n',mfilename,msg);
                vvs10Err(msg);
                disp(message);
                gpLogMsg(facility,message);
                quit;
            elseif strfind(err.message,'Write access denied')
                msg = sprintf('User/host has no write permission. Quitting.');
                message = sprintf('%s: %s\n',mfilename,msg);
                vvs10Err(msg);
                disp(message);
                gpLogMsg(facility,message);
                quit;
            else
                dbstack;
                rethrow(lasterror);
            end
        end
    elseif (refVoltage < (goal - 1))
        try
            lcaPut(sprintf('VVS:%s:1:VOLTAGE_INCRCMD',loc),1);
        catch
            err = lasterror;
            if strfind(err.identifier,'timedOut')
                msg = sprintf('%s VVS PV timed out. Quitting.',loc);
                message = sprintf('%s: %s\n',mfilename,msg);
                vvs10Err(msg);
                disp(message);
                gpLogMsg(facility,message);
                quit;
            elseif strfind(err.message,'Write access denied')
                msg = sprintf('User/host has no write permission. Quitting.');
                message = sprintf('%s: %s\n',mfilename,msg);
                vvs10Err(msg);
                disp(message);
                gpLogMsg(facility,message);
                quit;
            else
                dbstack;
                rethrow(lasterror);
            end
        end
    else
        done = 1;
    end

    if (done == 1)
        disp('VVS done ramping')
        break;
    end

    pause(delay);
end
    quit;
end

function [] = vvs10Err(msg)
nmsg=sprintf('ERROR: %s',msg);
uiwait(msgbox(nmsg,'Error - VVS Ramp Program'));
end
