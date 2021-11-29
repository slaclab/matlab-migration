% Set optional event definition parameters.

% Mike Zelazny (zelazny@slac.stanford.edu)

% If this function is not called, the number of pulses to average per step
% will be 1, the number of steps to acquire will be 1, and the inclusion
% and exclusion timing masks will default to the values in
% VX00:DGRP:1150:INCM and VX00:DGRP:1150:EXCM.

% eDefNumber is the number returned from eDefReserve
% navg is the number of pulses to average per step
% nrpos is the number of steps (readings, measurements) to acquire
% *OPTIONAL* incmSet, incmReset, excmSet, & excmReset are cell arrays
% that contain the names of the inclusion/exclusion timing bits to
% set/reset.  These arguments MODIFY the default values found in
% VX00:DGRP:1150:INCM and VX00:DGRP:1150:EXCM.  For a list of valif names
% see MP00:PNBN:*:NAME.

function eDefParams (eDefNumber, navg, nrpos, incmSet, incmReset, excmSet, excmReset, beamcode)

persistent numDESC;
persistent savedDESC;
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

    put2log(sprintf('Sorry %s, eDefParams(%d) prohibited.', caller, eDefNumber));

else

    pv = sprintf('EDEF:%s:%d:NAME', sys, eDefNumber);
    reservedBy = lcaGetSmart(pv);
    if ~iscell(reservedBy) && isnan(reservedBy)

        put2log(sprintf('Sorry %s, eDefParams can''t find pv %s', caller, pv));

    elseif isempty(char(reservedBy))

        put2log(sprintf('Sorry %s, eDefParams(%d) app name is empty', caller, eDefNumber));

    else

        if isempty(whos('global','eDefQuiet'))
            put2log(sprintf('%s about to set eDefParams(%d) for eDef reserved by ''%s''',caller, eDefNumber, char(reservedBy)));
        end

        % set my number of pulses to average
        LOPR = lcaGetSmart (sprintf('EDEF:%s:%d:AVGCNT.LOPR',sys,eDefNumber));
        HOPR = lcaGetSmart (sprintf('EDEF:%s:%d:AVGCNT.HOPR',sys,eDefNumber));

        lcaPut (sprintf('EDEF:%s:%d:AVGCNT',sys, eDefNumber), min(HOPR,max(LOPR,navg)));

        if isempty(whos('global','eDefQuiet'))
            put2log(sprintf('%s %s (NAVG) = %d', caller, char(lcaGetSmart(sprintf('EDEF:%s:%d:AVGCNT.DESC',sys,eDefNumber))), lcaGetSmart(sprintf('EDEF:%s:%d:AVGCNT',sys,eDefNumber))));
        end

        % set my number of pulses to acquire
        LOPR = lcaGetSmart (sprintf('EDEF:%s:%d:MEASCNT.LOPR',sys,eDefNumber));
        HOPR = lcaGetSmart (sprintf('EDEF:%s:%d:MEASCNT.HOPR',sys,eDefNumber));

        lcaPut (sprintf('EDEF:%s:%d:MEASCNT',sys,eDefNumber), min(HOPR,max(LOPR,nrpos)));

        if isempty(whos('global','eDefQuiet'))
            put2log(sprintf('%s %s (NRPOS) = %d', caller, char(lcaGetSmart(sprintf('EDEF:%s:%d:MEASCNT.DESC',sys,eDefNumber))), lcaGetSmart(sprintf('EDEF:%s:%d:MEASCNT',sys,eDefNumber))));
        end

        % set/reset INCM & EXCM
        maxDESC = 160; % number of INCM & EXCM bo's.
        
        % set beam code
        if (nargin > 7)
            lcaPut(sprintf('EDEF:%s:%d:BEAMCODE',sys,eDefNumber),beamcode);
        end

        if (nargin > 3)
            if (isequal([],numDESC))
                savedDESC = {};
                numDESC = 0;
                DESC_pv_list = {};
                for eachDESC = 1:maxDESC
                    DESC_pv_list{1+end} = sprintf('EDEF:%s:%d:INCM%d.DESC',sys,eDefNumber,eachDESC);
                end
                DESC_values = lcaGetSmart(DESC_pv_list);
                for eachDESC = 1:maxDESC
                    DESC = DESC_values(eachDESC);
                    if (isequal(DESC,{''}))
                        break;
                    end
                    savedDESC{1+end} = deblank(DESC{1});
                    numDESC = 1 + numDESC;
                end
            end
        end

        try
            if (nargin > 3) && ~isempty(incmSet)
                if ~isequal(incmSet(1),{''})
                    for eachMask = 1:length(incmSet)
                        for eachDESC = 1:numDESC
                            if (isequal(savedDESC{eachDESC},incmSet{eachMask}))
                                lcaPut (sprintf('EDEF:%s:%d:INCM%d',sys,eDefNumber,eachDESC), 1);
                                break;
                            end
                        end
                    end
                end
            end
        catch
            disp('***ERROR*** eDefParams.m unable to set INCM');
            incmSet
        end

        try
            if (nargin > 4) && ~isempty(incmReset)
                if ~isequal(incmReset(1),{''})
                    for eachMask = 1:length(incmReset)
                        for eachDESC = 1:numDESC
                            if (isequal(savedDESC{eachDESC},incmReset{eachMask}))
                                lcaPut (sprintf('EDEF:%s:%d:INCM%d',sys,eDefNumber,eachDESC), 0);
                                break;
                            end
                        end
                    end
                end
            end
        catch
            disp('***ERROR*** eDefParams.m unable to reset INCM');
            incmReset
        end

        try
            if (nargin > 5) && ~isempty(excmSet)
                if ~isequal(excmSet(1),{''})
                    for eachMask = 1:length(excmSet)
                        for eachDESC = 1:numDESC
                            if (isequal(savedDESC{eachDESC},excmSet{eachMask}))
                                lcaPut (sprintf('EDEF:%s:%d:EXCM%d',sys,eDefNumber,eachDESC), 1);
                                break;
                            end
                        end
                    end
                end
            end
        catch
            disp('***ERROR*** eDefParams.m unable to set EXCM');
            excmSet
        end

        try
            if (nargin > 6) && ~isempty(excmReset)
                if ~isequal(excmReset(1),{''})
                    for eachMask = 1:length(excmReset)
                        for eachDESC = 1:numDESC
                            if (isequal(savedDESC{eachDESC},excmReset{eachMask}))
                                lcaPut (sprintf('EDEF:%s:%d:EXCM%d',sys,eDefNumber,eachDESC), 0);
                                break;
                            end
                        end
                    end
                end
            end
        catch
            disp('***ERROR*** eDefParams.m unable to set EXCM');
            excmReset
        end

        pause(0.1); % to make sure EVG has properly set the INCM & EXCM

    end

end
