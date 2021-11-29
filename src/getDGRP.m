function [ dgrp ] = getDGRP( bpmd )
% Returns FACET DGRP Name given FACET BPMD - Zelazny

if isequal(57,bpmd)
    dgrp = 'NDRFACET';
    return;
end

if isequal(58,bpmd)
    dgrp = 'SDRFACET';
    return;
end

if isequal(1,bpmd)
    dgrp = 'INJ_ELEC';
    return;
end

if isequal(8,bpmd)
    dgrp = 'ELECEP01';
    return;
end

put2log(sprintf('Sorry, getDGRP(%d) - Unknown BPM Definition.',bpmd));
dgrp = 0;
