function d = zero_KLYS_SBST_phases(sect_klys,phi)

% d = zero_KLYS_SBST_phases(sect_klys,phi);
%
% This routine re-GOLDs all a KLYS or SBST. It changes the PDES
% to zero after sending the proper GOLD value, but no real phase
% change should occur at all.  It also sets the KLYS GOLDs as necessary.
%
%   INPUTS:     sect_klys:  e.g., '21-3' or '21-SBST'
%               dphi:       The delta phase shift requested (degS)
%   OUTPUTS:    d:          Presently not used (=1)
%
% =========================================================================

%  prim  = ['SBST';  'SBST';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS';  'KLYS'];
%  micro = ['LI21';  'LI21';  'LI21';  'LI21';  'LI21';  'LI21';  'LI21';  'LI21'];
%  unit  = [    1 ;      1 ;     31 ;     41 ;     51 ;     61 ;     71 ;     81 ];
%  secn  = ['PDES';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD';  'GOLD'];
%  delta = [-phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1) phi(1)];

micro = ['LI' sect_klys(1:2)];
if sect_klys(4)=='S'
  d = delta_klys_devices('SBST',micro,  1 ,'PDES',-phi','n');
  d = delta_klys_devices('SBST',micro,  1 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 11 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 21 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 31 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 41 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 51 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 61 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 71 ,'GOLD', phi','n');
  d = delta_klys_devices('KLYS',micro, 81 ,'GOLD', phi','n');
else
  unit  = 1 + 10*str2int(sect_klys(4));
  d = delta_klys_devices('KLYS',micro,unit,'PDES',-phi','n');
  d = delta_klys_devices('KLYS',micro,unit,'GOLD', phi','n');
end
d = 1;
