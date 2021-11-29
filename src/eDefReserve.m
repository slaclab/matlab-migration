% Reserve an event definition. Needed to read beam synchronous devices.
% Michael Zelazny (zelazny@slac.stanford.edu).
% 
% eDefName is a unique name for your beam synchronous acquisition request.
% 
% If successful, this function returns a valid eDef number.  Otherwise this
% function returns 0.

function [eDefNumber] = eDefReserve (eDefName)

persistent sys;
persistent accelerator;

if isempty(accelerator)
    [ sys , accelerator ] = getSystem();
end

eDefNumber = 0; % Should probably be NaN, but user software already checks against 0
%
% Determine caller (for later finger pointing)
%
stack = dbstack; % call stack
if length(stack) > 1
    caller = stack(2).file;
else
    caller = getenv('PHYSICS_USER');
end

% Reserve an eDef number
if isequal('LCLS',accelerator)
    lcaPut ('IOC:IN20:EV01:EDEFNAME',eDefName); % prod
else
    lcaPut(sprintf('IOC:%s:EV01:EDEFNAME',sys),eDefName);
end

pause (0.5); % give IOC time to assign my edef number

% Find my eDef number
for eacheDefNumber = 1:20 % 20 is the number of eDefs - hardcoded
    eacheDefName = lcaGetSmart (sprintf('EDEF:%s:%d:NAME',sys,eacheDefNumber));
    if isequal(eDefName, eacheDefName{1})
        eDefNumber = eacheDefNumber;
        if isempty(whos('global','eDefQuiet'))
            put2log(sprintf('%s eDefReserved #%d, with name=''%s''',caller, eDefNumber, eDefName));
        end
        break;
    end
end

if eDefNumber
    % Update user/host name, where available
    try
        hostname = getenv('HOSTNAME');
        username = getenv('PHYSICS_USER');
        if isempty(username),username = getenv('USERNAME');end;
        if ~isempty(username) && ~isempty(hostname)
            hostname = [username '@' hostname];
        end
        if ~isempty(hostname)
            lcaPutSmart(['EDEF:SYS0:' num2str(eDefNumber) ':USERNAME'],...
                hostname);
        end
    catch % Oh, I'm sure it's fine...
    end
end