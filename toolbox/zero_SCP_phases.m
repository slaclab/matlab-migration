function d = zero_SCP_phases(tag,phi,phi_new)

% d = zero_SCP_phases(tag,phi,phi_new);
%
% This routine re-GOLDs all SBST's in the L2 or L3 linac. It changes the PDES
% of the SBSTs to zero after sending the proper GOLD value, but no real phase
% change should occur at all.  It also sets the KLYS GOLDs as necessary.
%
% If "tag" = 'L2': Gold the phases from 21-3 through 24-6
% If "tag" = 'L3': Gold the phases from 25-1 through 30-8
%
%   INPUTS:     tag:        'L2' or 'L3'
%               phi:        The array (one per SBST) of delta phase shift requested (degS)
%               phi_new:    The final SBST phase needed (deg)
%   OUTPUTS:    d:          Presently not used (=1)
%
% =========================================================================

use_SBSTL2 = 0;       % if =0, use Joe's phase_control.m script to control the L2 PAC (if = 1, use the 21-24 SBST's as we used to do)
use_SBSTL3 = 0;       % if =0, use Joe's phase_control.m script to control the L2 PAC (if = 1, use the 25-30 SBST's as we used to do)

prim  = [];
micro = [];
unit  = [];
secn  = [];
if strcmp(tag,'L2')
  if ~use_SBSTL2
    phi0 = lcaGet('SIOC:SYS0:ML00:AO062');          % get present L2 phase from Joe's phase_control.m PV [deg]
    lcaPut('SIOC:SYS0:ML00:AO062',phi0+mean(phi));  % send phase shift to Joe's phase_control.m [deg]
    lcaPut('SIOC:SYS0:ML00:AO061',phi_new);         % send absolute phase shift to Joe's phase_control.m [deg]
    d = 1;
    return
  else
    % sector-21 klystrons 3-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI21';  'LI21';  'LI21';  'LI21';  'LI21';  'LI21';  'LI21';  'LI21'];
    unit  = [unit;      1 ;      1 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-22 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI22';  'LI22';  'LI22';  'LI22';  'LI22';  'LI22';  'LI22';  'LI22';  'LI22';  'LI22'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-23 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI23';  'LI23';  'LI23';  'LI23';  'LI23';  'LI23';  'LI23';  'LI23';  'LI23';  'LI23'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-24 klystrons 1-6:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI24';  'LI24';  'LI24';  'LI24';  'LI24';  'LI24';  'LI24';  'LI24'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    delta = [-phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) ...
             -phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) ...
             -phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) ...
             -phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) phi(4)];
  end
elseif strcmp(tag,'L3')
  if ~use_SBSTL3
    phi0 = lcaGet('SIOC:SYS0:ML00:AO065');          % get present L3 phase from Joe's phase_control.m PV [deg]
    lcaPut('SIOC:SYS0:ML00:AO065',phi0+mean(phi));  % send phase shift to Joe's phase_control.m [deg]
    lcaPut('SIOC:SYS0:ML00:AO064',phi_new);         % send absolute phase shift to Joe's phase_control.m [deg]
    d = 1;
    return
  else
    % sector-25 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI25';  'LI25';  'LI25';  'LI25';  'LI25';  'LI25';  'LI25';  'LI25';  'LI25';  'LI25'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-26 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI26';  'LI26';  'LI26';  'LI26';  'LI26';  'LI26';  'LI26';  'LI26';  'LI26';  'LI26'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-27 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI27';  'LI27';  'LI27';  'LI27';  'LI27';  'LI27';  'LI27';  'LI27';  'LI27';  'LI27'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-28 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI28';  'LI28';  'LI28';  'LI28';  'LI28';  'LI28';  'LI28';  'LI28';  'LI28';  'LI28'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-29 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI29';  'LI29';  'LI29';  'LI29';  'LI29';  'LI29';  'LI29';  'LI29';  'LI29';  'LI29'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    % sector-30 klystrons 1-8:
    prim  = [prim;  'SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
    micro = [micro; 'LI30';  'LI30';  'LI30';  'LI30';  'LI30';  'LI30';  'LI30';  'LI30';  'LI30';  'LI30'];
    unit  = [unit;      1 ;      1 ;     11 ;     21 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
    secn  = [secn;  'PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
    delta = [-phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) ...
             -phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) phi(2) ...
             -phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) phi(3) ...
             -phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) phi(4) ...
             -phi(5) phi(5) phi(5) phi(5) phi(5) phi(5) phi(5) phi(5) phi(5) phi(5) ...
             -phi(6) phi(6) phi(6) phi(6) phi(6) phi(6) phi(6) phi(6) phi(6) phi(6)];
  end
else
  errordlg('Error in scan_SCP_phases: "tag" string is not "L2" or "L3"','ERROR')
  return
end
d = 1;
d = delta_klys_devices(prim,micro,unit,secn,delta','n');