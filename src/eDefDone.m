% Check if an event definition is complete.

% Mike Zelazny (zelazny@slac.stanford.edu)

% eDefNumber returned from eDefReserve

function [done] = eDefDone (eDefNumber)

persistent sys;
persistent accelerator;

if isempty(accelerator)
    [ sys , accelerator ] = getSystem();
end

done = false;

%
% Determine caller (for later finger pointing)
%
stack = dbstack; % call stack
if length(stack) > 1
    caller = stack(2).file;
else
    caller = getenv('PHYSICS_USER');
end

%
% Special reserved eDefNumbers
%
OneHertz = 16;
TenHertz = 17;
BeamRate = 18;

%
% Make sure event definition is reserved
%
if (eDefNumber == OneHertz) || (eDefNumber == TenHertz) || (eDefNumber == BeamRate)

    put2log(sprintf('Sorry %s, eDefDone(%d) is NEVER done.', caller, eDefNumber));

else

    if eDefNumber > 0

        pv = sprintf('EDEF:%s:%d:NAME', sys, eDefNumber);
        reservedBy = lcaGetSmart(pv);
        if ~iscell(reservedBy) && isnan(reservedBy)

            put2log(sprintf('Sorry %s, eDefDone can''t find pv %s', caller, pv));

        elseif isempty(char(reservedBy))

            put2log(sprintf('Sorry %s, eDefDone(%d) app name is empty', caller, eDefNumber));

        else

            if isequal(lcaGetSmart(sprintf('EDEF:%s:%d:CTRL',sys,eDefNumber)), {'OFF'})
                if isempty(whos('global','eDefQuiet'))
                    put2log(sprintf('%s eDefDone(%d) is DONE, reserved by ''%s''',caller, eDefNumber, char(reservedBy)));
                end
                done = true;
            else
                done = false;
            end

        end

    else
        
        put2log(sprintf('%s, eDefDone(%d) has invalid eDef Number', caller, eDefNumber));
        done = true; % May as well let the user's code continue
        
    end

end
