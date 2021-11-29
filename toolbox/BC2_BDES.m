function [BDES,Imain,Itrim] = BC2_BDES(angl,energy)

%   [BDES,Imain,Itrim] = BC2_BDES(angl,energy);
%
%   Function to calculate BDES of main supply and the three trims (BX21, BX23, BX24)
%   for any bend angle and beam energy.  Since the bends were measured with a staright
%   probe, here we add a BDES reduction factor, sin(theta)/theta, to include the
%   slightly increased path length of the e- arcing through the bends (see "fac").
%
%    INPUTS:    angl:       The abs value of the bend angle per dipole (deg}
%               energy:     The e- beam energy (GeV)
%
%   OUTPUTS:    BDES(1):    The main supply BDES (kG-m)
%               BDES(2):    The BX21 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BX23 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BX24 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the main coils (main-coil Amperes)
%               Itrim(1):   The current required in the BX11 trim (trim-coil Amperes)
%               Itrim(2):   The current required in the BX13 trim (trim-coil Amperes)
%               Itrim(3):   The current required in the BX14 trim (trim-coil Amperes)

% ====================================================================================

p1 = [-2.620139E-1  2.323024E1 -3.523976E-1  1.388913E-1 -2.270363E-2  1.345011E-3];   % BDES to I polynomial for BX21 (A/kG^n)
p2 = [-2.542380E-1  2.317352E1 -3.033643E-1  1.249265E-1 -2.101173E-2  1.271024E-3];   % BDES to I polynomial for BX22 (A/kG^n)
p3 =   [-0.265760432535308  22.565930365695806  -0.3463651   0.1347859  -0.02183821 0.001289172];
p4 =   [-0.326169948755355  23.253779647380899  -0.4168129   0.1512411  -0.02365816 0.001369928];
        
ptrim = 2.2917;                                       % BTRM linear polynomial coeff. (N_main/N_trim)

c       = 2.99792458e8;                 % light speed (m/s)
anglR   = angl*pi/180;                  % degress to radians
fac     = sin(anglR+eps)/(anglR+eps);   % rectangular bend Leff factor, <=1 ("eps" added so fac=1 at anglR=0)
BDES(1) = 1E10*fac/c*energy*anglR;      % BDES needed, including Leff increase as "1/fac" (kG-m)
v       = [1 BDES(1) BDES(1).^2 BDES(1).^3 BDES(1).^4 BDES(1).^5]';

I1    = p1*v;           % current needed in BX21 (A)
Imain = p2*v;           % current needed in BX22 (A) (no trim on BX22 - use this for main supply)
I3    = p3*v;           % current needed in BX23 (A)
I4    = p4*v;           % current needed in BX24 (A)

Imain = max([0 Imain]); % can't have negative main currents (A)

BDES(2) = I1 - Imain;   % extra (or less) current needed in BX21 (main-coil Amperes)
BDES(3) = I3 - Imain;   % extra (or less) current needed in BX23 (main-coil Amperes)
BDES(4) = I4 - Imain;   % extra (or less) current needed in BX24 (main-coil Amperes)

if Imain==0
  BDES(3) = BDES(3)+p2(1);  % if BX22 remnant is not compensated, add BX22 remnant to BX23 (A)
end

Itrim(1) = BDES(2)*ptrim;   % trim current (trim-coil Amperes) to get field in BX21 = field in BX22 (A)
Itrim(2) = BDES(3)*ptrim;   % trim current (trim-coil Amperes) to get field in BX23 = field in BX22 (A)
Itrim(3) = BDES(4)*ptrim;   % trim current (trim-coil Amperes) to get field in BX24 = field in BX22 (A)
