function [outoftol, offconfig] = check_magnet(pvs, fac)

if nargin < 2, fac = 1;end

[B1,B2,B3,B4]=control_deviceGet(pvs,{'BDES' 'BCON' 'BACT' 'CHCKBTOL'});
outoftol  = abs( B1 - B3 ) > fac*B4;
offconfig = abs( B1 - B2 ) > fac*B4;
