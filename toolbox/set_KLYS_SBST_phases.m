function d = set_KLYS_SBST_phases(sect_klys,secn,dphi,trimflag)

% d = set_KLYS_SBST_phases(sect_klys,secn,dphi,trimflag);
%
% This routine phase shift any KLYS or SBST.  It does not
% re-GOLD the phases.  It shifts the RF phases (PDES) of the old SCP-controlled
% klystrons or sub-boosters in the LCLS.  It changes the PDES  of the KLYS or SBSTs
% and TRIMs.
%
%   INPUTS:     sect_klys:  e.g., '21-3' or '21-SBST'
%               secn:       e.g., 'PDES' or 'KPHR'
%               dphi:       The delta phase shift requested (degS)
%               trimflag:   If =='n', no trim is sent (defaults to 'y')
%   OUTPUTS:    d:          Presently not used (=1)
%
% =========================================================================

if ~exist('trimflag','var')
  trimflag = 'y';
end

if sect_klys(4)=='S'
  prim = 'SBST';
  unit  = 1;
else
  prim = 'KLYS';
  unit  = 1 + 10*str2int(sect_klys(4));
end
micro = ['LI' sect_klys(1:2)];

disp([prim ' ' micro ' ' int2str(unit) ' ' secn ': ' sprintf('dphase = %6.3f deg',dphi)])

d = delta_klys_devices(prim,micro,unit,secn,dphi,trimflag);
