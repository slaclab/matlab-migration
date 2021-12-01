function [ incmSet, incmReset, excmSet, excmReset, beamcode ] = getINCMEXCM( dgrp )
% Changes to default INCM & EXCM for various FACET BPM Definitions

if isequal('FACET-II',dgrp)
    incmSet = {'MPS_POCKCELL','TS5'};
    incmReset =  {''};
    excmSet = {'TS1','TS2','TS3','TS4','TS6','TSLOT_U6','NO_GUN_PERM'};
    excmReset = {''};
    beamcode = 10;
    return;
end

if isequal('NDRFACET',dgrp)
    incmSet = {''};
    incmReset =  {''};
    excmSet = {''};
    excmReset = {''};
    beamcode = 10;
    return;
end


if isequal('SDRFACET',dgrp) % {} net setup yet
    incmSet = {''};
    incmReset =  {'FFTB_ext'};
    excmSet = {'NO_EXT_POSI','DUMP_2_9'};
    excmReset = {'NO_EXT_ELEC'};
    beamcode = 6;
    return;
end

if isequal('INJ_ELEC',dgrp)
    incmSet = {'SCAVINJ'};
    incmReset =  {'FFTB_ext'};
    excmSet = {'DUMP_K02','DUMP_BAS1','NO_GUN_PERM'};
    excmReset = {'DUMP_2_9','NO_EXT_ELEC'};
    beamcode = 10;
    return;
end

if isequal('ELECEP01',dgrp)
    incmSet = {''};
    incmReset =  {'FFTB_ext'};
    excmSet = {'FFTB_ext'};
    excmReset = {''};
    beamcode = 10;
    return;
end

if isequal('LASER1HZ',dgrp)
    incmSet = {'ONE_HERTZ','TS5'};
    incmReset =  {'FFTB_ext'};
    excmSet = {''};
    excmReset = {'DUMP_2_9','NO_EXT_ELEC'};
    beamcode = 0;
    return;
end

%if isequal('LASER10HZ',dgrp)
%    incmSet = {'TEN_HERTZ','TS5'};
%    incmReset =  {'FFTB_ext'};
%    excmSet = {''};
%    excmReset = {'DUMP_2_9','NO_EXT_ELEC'};
%    beamcode = 0;
%    return;
%end

if isequal('LASER10HZ',dgrp)
    incmSet = {'TEN_HERTZ','TS5'};
    incmReset =  {''};
    excmSet = {'TS1','TS2','TS3','TS4','TS6','TSLOT_U6'};
    excmReset = {''};
    beamcode = 10;
    return;
end

if isequal('PAMM10HZ',dgrp)
    incmSet = {'RATE_10HZ','TS5'};
    incmReset =  {'FFTB_ext'};
    excmSet = {''};
    excmReset = {'DUMP_2_9','NO_EXT_ELEC'};
    beamcode = 0;
    return;
end

if isequal('LASER10HZposi',dgrp)
    incmSet = {'POSI_10HZ','TS5'};
    incmReset =  {'FFTB_ext'};
    excmSet = {''};
    excmReset = {'DUMP_2_9','NO_EXT_ELEC'};
    beamcode = 0;
    return;
end

if isequal('LASER1HZposi',dgrp)
    incmSet = {'POSI_1HZ','TS5'};
    incmReset =  {'FFTB_ext'};
    excmSet = {''};
    excmReset = {'DUMP_2_9','NO_EXT_ELEC'};
    beamcode = 0;
    return;
end

put2log(sprintf('Sorry, getINCMEXCM(%s) - Unknown dgrp.',dgrp));
bpmd = 0;


