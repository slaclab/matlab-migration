function [BDES,Imain,Itrim] = BCSS_BDES(angl,energy);

%   [BDES,Imain,Itrim] = BCSS_BDES(angl,energy);
%
%   Function to calculate BDES of main HXRSS chicane supply and its three trims
%   (BXSS1, BXSS3, BXSS4) for any bend angle and beam energy.  Since the bends
%   were measured with a straight probe, here we add a BDES reduction factor,
%   sin(theta)/theta, to include the slightly increased path length of the e-
%   arcing through the bends (see "fac").
%
%    INPUTS:    angl:       The abs value of the bend angle per dipole (deg}
%               energy:     The e- beam energy (GeV)
%
%   OUTPUTS:    BDES(1):    The main supply BDES (kG-m)
%               BDES(2):    The BXSS1 BTRM BDES (in main-coil Amperes)
%               BDES(3):    The BXSS3 BTRM BDES (in main-coil Amperes)
%               BDES(4):    The BXSS4 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the main coils (main-coil Amperes)
%               Itrim(1):   The current required in the BXSS1 trim (trim-coil Amperes)
%               Itrim(2):   The current required in the BXSS3 trim (trim-coil Amperes)
%               Itrim(3):   The current required in the BXSS4 trim (trim-coil Amperes)

% ====================================================================================

p1 = [0 3.314 0 0 0 0];   % (temporary - 9/17/11) BDES to I polynomial for BXSS1 (A, A/kG-m, A/kG-m^2, ...)
p2 = [0 3.315 0 0 0 0];   % (temporary - 9/17/11) BDES to I polynomial for BXSS2 (A, A/kG-m, A/kG-m^2, ...)
p3 = [0 3.316 0 0 0 0];   % (temporary - 9/17/11) BDES to I polynomial for BXSS3 (A, A/kG-m, A/kG-m^2, ...)
p4 = [0 3.317 0 0 0 0];   % (temporary - 9/17/11) BDES to I polynomial for BXSS4 (A, A/kG-m, A/kG-m^2, ...)
pvList={'BEND:UND1:1630'; 'BEND:UND1:1640'; 'BEND:UND1:1660'; 'BEND:UND1:1670'};
coeffs=lcaGet(strcat(pvList,':IVB'));
p1 = coeffs(1,:);   % BDES to I polynomial for BXSS1 (A, A/kG-m, A/kG-m^2, ...)
p2 = coeffs(2,:);   % BDES to I polynomial for BXSS2 (A, A/kG-m, A/kG-m^2, ...)
p3 = coeffs(3,:);   % BDES to I polynomial for BXSS3 (A, A/kG-m, A/kG-m^2, ...)
p4 = coeffs(4,:);   % BDES to I polynomial for BXSS4 (A, A/kG-m, A/kG-m^2, ...)

ptrim = 576/10;          % BTRM linear polynomial coeff. (N_main/N_trim)

c       = 2.99792458e8;                 % light speed (m/s)
anglR   = angl*pi/180;                  % degress to radians
fac     = sin(anglR+eps)/(anglR+eps);   % rectangular bend Leff factor, <=1 ("eps" added so fac=1 at anglR=0)
BDES(1) = 1E10*fac/c*energy*anglR;      % BDES needed, including Leff increase as "1/fac" (kG-m)
v       = [1 BDES(1) BDES(1).^2 BDES(1).^3 BDES(1).^4 BDES(1).^5]';  % build polynomial

I1    = p1*v;           % current needed in BXSS1 (A)
Imain = p2*v;           % current needed in BXSS2 (A) (trim on BXSS2 not used here - use this for main supply)
I3    = p3*v;           % current needed in BXSS3 (A)
I4    = p4*v;           % current needed in BXSS4 (A)

Imain = max([0 Imain]); % can't have negative main currents (A)

BDES(2) = I1 - Imain;   % extra (or less) current needed in BXSS1 (main-coil Amperes)
BDES(3) = I3 - Imain;   % extra (or less) current needed in BXSS3 (main-coil Amperes)
BDES(4) = I4 - Imain;   % extra (or less) current needed in BXSS4 (main-coil Amperes)

if Imain==0
  BDES(3) = BDES(3)+p2(1);  % if BXSS2 remnant is not compensated, add BXSS2 remnant to BXSS3 (A)
end

Itrim(1) = BDES(2)*ptrim;   % trim current (trim-coil Amperes) to get field in BXSS1 = field in BXSS2 (A)
Itrim(2) = BDES(3)*ptrim;   % trim current (trim-coil Amperes) to get field in BXSS3 = field in BXSS2 (A)
Itrim(3) = BDES(4)*ptrim;   % trim current (trim-coil Amperes) to get field in BXSS4 = field in BXSS2 (A)
