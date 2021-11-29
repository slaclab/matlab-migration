function [ bpmd ] = getBPMD( dgrp)
% Returns FACET BPMD given FACET DGRP - Zelazny

if isequal('NDRFACET',dgrp)
    bpmd = 57;
    return;
end

if isequal('SDRFACET',dgrp)
    bpmd = 58;
    return;
end

if isequal('INJ_ELEC',dgrp)
    bpmd = 1;
    return;
end

if isequal('ELECEP01',dgrp)
    bpmd = 8;
    return;
end

put2log(sprintf('Sorry, getBPMD(%s) - Unknown dgrp.',dgrp));
bpmd = 0;
