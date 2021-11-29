function d = scan_L2_phases(dphi);

% d = scan_L2_phases(dphi);
%
% This routine phase shift all SBST's from 21-3 through 24-6.  It does not
% re-GOLD the phases.  It shifts the RF phases of the old SCP-controlled
% sub-boosters in the LCLS L2-linac.  It changes the phase shifter (KPHR)
% of the SBST.
%
%   INPUTS:     dphi:   The delta phas shift requested (degS)
%   OUTPUTS:    d:      Presently not used (=1)
%
% =========================================================================

prim  = [];
micro = [];
unit  = [];
secn  = [];
% sector-21 klystrons 3-8:
prim  = [prim;  'SBST'];
micro = [micro; 'LI21'];
unit  = [unit;      1 ];
secn  = [secn;  'KPHR'];
% sector-22 klystrons 1-8:
prim  = [prim;  'SBST'];
micro = [micro; 'LI22'];
unit  = [unit;      1 ];
secn  = [secn;  'KPHR'];
% sector-23 klystrons 1-8:
prim  = [prim;  'SBST'];
micro = [micro; 'LI23'];
unit  = [unit;      1 ];
secn  = [secn;  'KPHR'];
% sector-24 klystrons 1-6:
prim  = [prim;  'SBST'];
micro = [micro; 'LI24'];
unit  = [unit;      1 ];
secn  = [secn;  'KPHR'];

delta = dphi*ones(length(prim),1);

d = delta_klys_devices(prim,micro,unit,secn,delta);