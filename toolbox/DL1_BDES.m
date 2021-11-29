function [BDES,Imain,Itrim] = DL1_BDES(angl,energy);

%   [BDES,Imain,Itrim] = DL1_BDES([angl,energy]);
%
%   Function to calculate BDES of main supply and the one trim (BX01)
%   for DL1-ON, DL1-off and any beam energy.
%
%    INPUTS:    angl:       (Optional, DEF=17.5 deg/bend) The abs value of the bend
%                           angle per dipole (deg)
%               energy:     (Optional, DEF=0.135 GeV) The e- beam energy (GeV)
%
%   OUTPUTS:    BDES(1):    The main supply BDES (GeV/c)
%               BDES(2):    The BX01 BTRM BDES (in main-coil Amperes)
%               Imain:      The required current in the main coils (main-coil Amperes)
%               Itrim(1):   The current required in the BX01 trim (trim-coil Amperes)

% ====================================================================================

if ~exist('angl')
  angl = 17.5;  % deg/bend
elseif angl>20 | angl<-2.5
  error('angl/bend must be >-2.5 deg and <20 deg (nom. is 17.5 deg) - try again.')  
end

if ~exist('energy')
  energy = 0.135;  % deg/bend
elseif energy>0.25 | energy<0.01
  error('energy must be >0.010 GeV and <0.25 GeV - try again.')  
end

p1 = [-0.3185546 1.643291E3 -2.731068E3 4.238484E4 -2.656437E5 6.149535E5];     % BDES to I polynomial for BX01 (A/kG^n)
p2 = [-0.2668666 1.642822E3 -2.430014E3 3.825926E4 -2.447695E5 5.780101E5];     % BDES to I polynomial for BX02 (A/kG^n)
ptrim = 1.0588;                                                                 % BTRM linear polynomial coeff. (N_main/N_trim)

anglR   = angl*pi/180;                 % degress to radians
BDES(1) = energy*angl/17.5;            % BDES needed, including Leff increase in poly (GeV/c)
v       = [1 BDES(1) BDES(1).^2 BDES(1).^3 BDES(1).^4 BDES(1).^5]';

I1    = p1*v;          % current needed in BX01 (A)
Imain = p2*v;          % current needed in BX02 (A) (no trim on BX02 - use this for main supply)

Imain = max([0 Imain]); % can't have negative main currents (A)

BDES(2) = I1 - Imain;   % extra (or less) current needed in BX01 (main-coil Amperes)

Itrim(1) = BDES(2)*ptrim;   % trim current (trim-coil Amperes) to get field in BX01 = field in BX02 (A)
