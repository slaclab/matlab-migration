% Release eDefNumber reserved with eDefReserve

% Mike Zelazny (zelazny@slac.stanford.edu)

function eDefRelease (eDefNumber)

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
try
    if (eDefNumber == OneHertz) || (eDefNumber == TenHertz) || (eDefNumber == BeamRate)

        put2log(sprintf('Sorry %s, eDefRelease(%d) prohibited.', caller, eDefNumber));

    else

        pv = sprintf('EDEF:%s:%d:NAME', sys, eDefNumber);
        reservedBy = lcaGetSmart(pv);
        if ~iscell(reservedBy) && isnan(reservedBy)

            put2log(sprintf('Sorry %s, eDefRelease can''t find pv %s', caller, pv));

        elseif isempty(char(reservedBy))

            put2log(sprintf('Sorry %s, eDefRelease(%d) app name is empty', caller, eDefNumber));

        else

            if isempty(whos('global','eDefQuiet'))
                put2log(sprintf('%s about to eDefRelease(%d) reserved by ''%s''',caller, eDefNumber, char(reservedBy)));
            end
            lcaPut (sprintf('EDEF:%s:%d:FREE',sys,eDefNumber), 1);

        end
    end
catch
    disp('eDefRelease: eDefNumber appears to be invalid');
    eDefNumber
end
