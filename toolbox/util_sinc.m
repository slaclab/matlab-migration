function val = util_sinc(phi)
%UTIL_SINC
%  VAL = UTIL_SINC(PHI) calculates SINC function for PHI including PHI=0.
%  Resulting array has same shape as PHI.  NaNs are returned as NaNs.

% Features:

% Input arguments:
%    PHI: Argument of SINC function.

% Output arguments:
%    VAL: SINC(PHI)

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

val=ones(size(phi));
bad=phi == 0;
val(~bad)=sin(phi(~bad))./phi(~bad);
