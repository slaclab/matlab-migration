function [BDES,Imain,Itrim] = BC1_BDES(angl,energy);

%   [BDES,Imain,Itrim] = BC1_BDES(angl,energy);
%
%   Function to calculate BDES of main supply and the three trims (BX11, BX13, BX14)
%   for any bend angle and beam energy.  Since the bends were measured with a staright
%   probe, here we add a BDES reduction factor, sin(theta)/theta, to include the
%   slightly increased path length of the e- arcing through the bends (see "fac").
%
%    INPUTS:    angl:       The abs value of the bend angle per dipole (deg}
%               energy:     The e- beam energy (GeV)
%
%   OUTPUTS:    BDES(1):    The main supply BDES (kG-m)
%               BDES(2):    The BX11 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BX13 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BX14 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the main coils (main-coil Amperes)
%               Itrim(1):   The current required in the BX11 trim (trim-coil Amperes)
%               Itrim(2):   The current required in the BX13 trim (trim-coil Amperes)
%               Itrim(3):   The current required in the BX14 trim (trim-coil Amperes)

% ====================================================================================

p1 = [-0.192767 , 308.401 , -6.47041  , 5.07454 0 0 0 0 0 0];   % BDES to I polynomial for BX11 (A/kG^n)
%p2 = [-0.322616 , 307.702 , -4.81872  , 4.25820];   % BDES to I polynomial for BX12 (A/kG^n)
%p3 = [-0.333022 , 307.866 , -4.07724  , 3.41429];   % BDES to I polynomial for BX13 (A/kG^n)
p2 = [-4.004983e-001  3.041257e+002  3.190752e+001 -1.351165e+003  1.178857e+004 -4.865154e+004  1.094169e+005 -1.369621e+005  8.930395e+004 -2.353094e+004];   % BDES to I polynomial for BX12 (A/kG^n) after poles replaced (Nov. 12, 2007)
p3 = [-3.637365e-001  3.027337e+002  1.102520e+002 -2.282392e+003  1.693391e+004 -6.425975e+004  1.368579e+005 -1.647365e+005  1.042660e+005 -2.684397e+004];   % BDES to I polynomial for BX13 (A/kG^n) after poles replaced (Nov. 12, 2007)
p4 = [-0.158268 , 307.674 , -3.90914  , 3.50885 0 0 0 0 0 0];   % BDES to I polynomial for BX14 (A/kG^n)
%ptrim = 0.63;                           % BTRM linear polynomial coeff. (N_main/N_trim)
ptrim = 28/45;                          % J. Welch, Dec. 9, 2007

c       = 2.99792458e8;                 % light speed (m/s)
anglR   = angl*pi/180;                  % degress to radians
fac     = sin(anglR+eps)/(anglR+eps);   % rectangular bend Leff factor, <=1 ("eps" added so fac=1 at anglR=0)
BDES(1) = 1E10*fac/c*energy*anglR;      % BDES needed, including Leff increase as "1/fac" (kG-m)
v       = [1 BDES(1) BDES(1).^2 BDES(1).^3 BDES(1).^4 BDES(1).^5 BDES(1).^6 BDES(1).^7 BDES(1).^8 BDES(1).^9]';

I1    = p1*v;           % current needed in BX11 (A)
Imain = p2*v;           % current needed in BX12 (A) (no trim on BX12 - use this for main supply)
I3    = p3*v;           % current needed in BX13 (A)
I4    = p4*v;           % current needed in BX14 (A)

if Imain <=0
%  BDES(3) = BDES(3)+p2(1);  % if BX12 remnant is not compensated, add BX12 remnant to BX13 (A)
  b13 = 2*BDES(1) + p2(1)/p2(2);
  w = [1 b13 b13.^2 b13.^3 b13.^4 b13.^5 b13.^6 b13.^7 b13.^8 b13.^9]'; % J. welch, Dec. 9, 2007
  I3 = p3*w;                                                            % J. welch, Dec. 9, 2007
end

Imain = max([0 Imain]); % can't have negative main currents (A)

BDES(2) = 1.16*(I1 - Imain);   % extra (or less) current needed in BX11 (main-coil Amperes) (1.16 factor to get BPMS:LI21:278:X at zero - 3/28/09 -PE)
BDES(3) = I3 - Imain;   % extra (or less) current needed in BX13 (main-coil Amperes)
BDES(4) = I4 - Imain;   % extra (or less) current needed in BX14 (main-coil Amperes)

Itrim(1) = BDES(2)*ptrim;   % trim current (trim-coil Amperes) to get field in BX11 = field in BX12 (A)
Itrim(2) = BDES(3)*ptrim;   % trim current (trim-coil Amperes) to get field in BX13 = field in BX12 (A)
Itrim(3) = BDES(4)*ptrim;   % trim current (trim-coil Amperes) to get field in BX14 = field in BX12 (A)
