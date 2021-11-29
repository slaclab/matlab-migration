function [BDES,Imain,Itrim] = BCH_BDES(angl,energy);

%   [BDES,Imain,Itrim] = BCH_BDES(angl,energy);
%
%   Function to calculate BDES of main laser heater chicane bend supply and its three
%   trims (BXH1, BXH3, BXH4) for any bend angle and beam energy.  Since the bend
%   were measured with a straight probe, here we add a BDES reduction factor,
%   sin(theta)/theta, to include the slightly increased path length of the e- arcing
%   through the bends (see "fac").
%
%    INPUTS:    angl:       The abs value of the bend angle per dipole (deg}
%               energy:     The e- beam energy (GeV)
%
%   OUTPUTS:    BDES(1):    The main supply BDES (kG-m)
%               BDES(2):    The BXH1 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BXH3 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BXH4 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the main coils (main-coil Amperes)
%               Itrim(1):   The current required in the BX11 trim (trim-coil Amperes)
%               Itrim(2):   The current required in the BX13 trim (trim-coil Amperes)
%               Itrim(3):   The current required in the BX14 trim (trim-coil Amperes)

% ====================================================================================

p1 = [-1.3000880 2.871939E2 -1.851752E2 6.095439E2 -8.801983E2 4.603718E2];   % BDES to I polynomial for BXH1 (A/kG-m^n)
p2 = [-0.3783284 2.764696E2 -1.385662E2 5.186152E2 -7.957934E2 4.302896E2];   % BDES to I polynomial for BXH2 (A/kG-m^n)
p3 = [-0.3702678 2.766265E2 -1.375625E2 5.119401E2 -7.819566E2 4.216546E2];   % BDES to I polynomial for BXH3 (A/kG-m^n)
p4 = [-0.4765466 2.747545E2 -1.182852E2 4.486741E2 -7.003644E2 3.854325E2];   % BDES to I polynomial for BXH4 (A/kG-m^n) - Sep. 8, '08
ptrim = 3.00;                                       % BTRM linear polynomial coeff. (N_main/N_trim)

c       = 2.99792458e8;                 % light speed (m/s)
anglR   = angl*pi/180;                  % degress to radians
fac     = sin(anglR+eps)/(anglR+eps);   % rectangular bend Leff factor, <=1 ("eps" added so fac=1 at anglR=0)
BDES(1) = 1E10*fac/c*energy*anglR;      % BDES needed, including Leff increase as "1/fac" (kG-m)
v       = [1 BDES(1) BDES(1).^2 BDES(1).^3 BDES(1).^4 BDES(1).^5]';

I1    = p1*v;           % current needed in BXH1 (A)
Imain = p2*v;           % current needed in BXH2 (A) (no trim on BXH2 - use this for main supply)
I3    = p3*v;           % current needed in BXH3 (A)
I4    = p4*v;           % current needed in BXH4 (A)

Imain = max([0 Imain]); % can't have negative main currents (A)

BDES(2) = I1 - Imain;   % extra (or less) current needed in BXH1 (main-coil Amperes)
BDES(3) = I3 - Imain;   % extra (or less) current needed in BXH3 (main-coil Amperes)
BDES(4) = I4 - Imain;   % extra (or less) current needed in BXH4 (main-coil Amperes)

if Imain==0
  BDES(3) = BDES(3)+p2(1);  % if BXH2 remnant is not compensated, add BXH2 remnant to BXH3 (A)
end

Itrim(1) = BDES(2)*ptrim;   % trim current (trim-coil Amperes) to get field in BXH1 = field in BXH2 (A)
Itrim(2) = BDES(3)*ptrim;   % trim current (trim-coil Amperes) to get field in BXH3 = field in BXH2 (A)
Itrim(3) = BDES(4)*ptrim;   % trim current (trim-coil Amperes) to get field in BXH4 = field in BXH2 (A)
