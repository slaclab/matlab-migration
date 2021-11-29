function d = shift_L2_phases(dphi);

% d = shift_L2_phases(dphi);
%
% This routine phase shift all SBST's and re-gold all klystrons from 21-3
% through 24-6.  It shifts the RF phases of the old SCP-controlled sub-boosters
% in the LCLS L2-linac.  It changes the phase shifter (KPHR) of the SBST, then
% offset the GOLD values for all effected devices (keeps SLC control system
% 'PHAS' readback unaffected).  The SBST phase shifter is the only phase
% shifter which needs to actually move.
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
prim  = [prim;  'SBST'; 'SBST'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'];
micro = [micro; 'LI21'; 'LI21'; 'LI21'; 'LI21'; 'LI21'; 'LI21'; 'LI21'; 'LI21'];
unit  = [unit;      1 ;     1 ;    31 ;    41 ;    51 ;    61 ;    71 ;    81 ];
secn  = [secn;  'KPHR'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'];
% sector-22 klystrons 1-8:
prim  = [prim;  'SBST'; 'SBST'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'];
micro = [micro; 'LI22'; 'LI22'; 'LI22'; 'LI22'; 'LI22'; 'LI22'; 'LI22'; 'LI22'; 'LI22'; 'LI22'];
unit  = [unit;      1 ;     1 ;    11 ;    21 ;    31 ;    41 ;    51 ;    61 ;    71 ;    81 ];
secn  = [secn;  'KPHR'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'];
% sector-23 klystrons 1-8:
prim  = [prim;  'SBST'; 'SBST'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'];
micro = [micro; 'LI23'; 'LI23'; 'LI23'; 'LI23'; 'LI23'; 'LI23'; 'LI23'; 'LI23'; 'LI23'; 'LI23'];
unit  = [unit;      1 ;     1 ;    11 ;    21 ;    31 ;    41 ;    51 ;    61 ;    71 ;    81 ];
secn  = [secn;  'KPHR'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'];
% sector-24 klystrons 1-6:
prim  = [prim;  'SBST'; 'SBST'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'; 'KLYS'];
micro = [micro; 'LI24'; 'LI24'; 'LI24'; 'LI24'; 'LI24'; 'LI24'; 'LI24'; 'LI24'];
unit  = [unit;      1 ;     1 ;    11 ;    21 ;    31 ;    41 ;    51 ;    61 ];
secn  = [secn;  'KPHR'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'; 'GOLD'];

delta = dphi*ones(length(prim),1);

d = delta_klys_devices(prim,micro,unit,secn,delta);