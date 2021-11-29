function d = scan_SCP_phases(tag,dphi)

% d = scan_SCP_phases(tag,dphi);
%
% This routine phase shift all SBST's in L3 linac, but uses the new L2 PAC for
% L2 when use_SBST=0.  It does not re-GOLD the phases.  It shifts the RF phases
% (PDES) of the old SCP-controlled sub-boosters in the LCLS L2 or L3-linacs.
% It changes the PDES  of the SBSTs and seems to TRIM all by itself
% (not sure why - but good).
%
% If "tag" = 'L2': Set phases from 21-3 through 24-6
% If "tag" = 'L3': Set phases from 25-1 through 30-8
%
%   INPUTS:     dphi:   The delta phas shift requested (degS)
%   OUTPUTS:    d:      Presently not used (=1)
%
% =========================================================================

use_SBSTL2 = 0;       % if =0, use Joe's phase_control.m script to control the L2 PAC (if = 1, use the 21-24 SBST's as we used to do)
use_SBSTL3 = 0;       % if =0, use Joe's phase_control.m script to control the L3 PAC (if = 1, use the 25-30 SBST's as we used to do)

prim  = [];
micro = [];
unit  = [];
secn  = [];
if strcmp(tag,'L2')
  if ~use_SBSTL2
    phi0 = lcaGet('SIOC:SYS0:ML00:AO061');            % get present L2 phase from Joe's phase_control.m PV [deg]
    lcaPut('SIOC:SYS0:ML00:AO061',phi0+dphi);         % send absolute phase shift to Joe's phase_control.m [deg]
    d = 1;
    return
  else
    % sector-21 klystrons 3-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI21'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-22 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI22'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-23 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI23'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-24 klystrons 1-6:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI24'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
  end
elseif strcmp(tag,'L3')
  if ~use_SBSTL3
    phi0 = lcaGet('SIOC:SYS0:ML00:AO064');            % get present L2 phase from Joe's phase_control.m PV [deg]
    lcaPut('SIOC:SYS0:ML00:AO064',phi0+dphi);         % send absolute phase shift to Joe's phase_control.m [deg]
    d = 1;
    return
  else
    % sector-25 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI25'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-26 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI26'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-27 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI27'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-28 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI28'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-29 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI29'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
    % sector-30 klystrons 1-8:
    prim  = [prim;  'SBST'];
    micro = [micro; 'LI30'];
    unit  = [unit;      1 ];
    secn  = [secn;  'PDES'];
  end
else
  errordlg('Error in scan_SCP_phases: "tag" string is not "L2" or "L3"','ERROR')
  return
end

delta = dphi*ones(size(unit));
d = delta_klys_devices(prim,micro,unit,secn,delta');
