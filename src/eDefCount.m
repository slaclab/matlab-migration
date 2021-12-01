% How many elements has the eDef collected?

% Mike Zelazny (zelazny@slac.stanford.edu)

% eDefNumber returned from eDefReserve

function [count] = eDefCount (eDefNumber)

persistent sys;
persistent accelerator;

if isempty(accelerator)
    [ sys , accelerator ] = getSystem();
end

count = NaN;

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
% Make sure event definition is reserved
%
pv = sprintf('EDEF:%s:%d:NAME', sys, eDefNumber);
reservedBy = lcaGetSmart(pv);
if ~iscell(reservedBy) && isnan(reservedBy)

    put2log(sprintf('Sorry %s, eDefCount can''t find pv %s', caller, pv));

elseif isempty(char(reservedBy))

    put2log(sprintf('Sorry %s, eDefCount(%d) app name is empty', caller, eDefNumber));

else
    
    numSteps = lcaGetSmart (sprintf('EDEF:%s:%d:CNT',sys,eDefNumber));
    numPerStep = lcaGetSmart (sprintf('EDEF:%s:%d:AVGCNT',sys,eDefNumber));
    count = min(2800,double(numSteps)/double(numPerStep));
    if isempty(whos('global','eDefQuiet'))
        put2log(sprintf('%s eDefCount(%d)=%d reserved by ''%s''',caller, eDefNumber, count, char(reservedBy)));
    end
end
