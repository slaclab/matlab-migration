% Abort a running event definition

% Mike Zelazny (zelazny@slac.stanford.edu)

% eDefNumber returned from eDefReserve

function eDefAbort (eDefNumber)

global eDefQuiet;

persistent sys;
persistent accelerator;

if isempty(accelerator)
    [ sys , accelerator ] = getSystem();
end

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

    put2log(sprintf('Sorry %s, eDefAbort(%d) prohibited.', caller, eDefNumber));

else

    pv = sprintf('EDEF:%s:%d:NAME', sys, eDefNumber);
    reservedBy = lcaGetSmart(pv);
    if ~iscell(reservedBy) && isnan(reservedBy)

        put2log(sprintf('Sorry %s, eDefabort can''t find pv %s', caller, pv));

    elseif isempty(char(reservedBy))

        put2log(sprintf('Sorry %s, eDefAbort(%d) app name is empty', caller, eDefNumber));

    else

        if isempty(whos('global','eDefQuiet'))
            put2log(sprintf('%s about to eDefAbort(%d) reserved by ''%s''',caller, eDefNumber, char(reservedBy)));
        end
        lcaPut (sprintf('EDEF:%s:%d:CTRL',sys,eDefNumber), 0);

    end

end
