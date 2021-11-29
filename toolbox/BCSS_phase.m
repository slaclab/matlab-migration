function [BDES,theta,Itrim,R56] = BCSS_phase(Angstroms,energy)

%   [BDES,theta,Itrim] = BCSS_phase(Angstroms,energy);
%
%   Function to calculate, with the main supply off, the 4 trim settings of the HXRSS chicane supply
%   to vary the phasing given the desired chicane delay (Angstroms) and the elecron energy (GeV).
%
%    INPUTS:    Angstroms:  The HXRSS chicane delay value requested - always >0 here (Angstroms)
%               energy:     The e- energy (GeV)
%
%   OUTPUTS:    BDES:       The BXSS1,2,3,4 BTRM BDES needed for "Angstrom" delay (in main-coil Amperes)
%               theta:      Absolute value of bend angle of each dipole (rad)
%               Itrim:      Actual excitation current in each trim (amps, not main-coil amps)

% ========================================================================================

p = [3.040 3.040 3.040 3.040];            % per P. Emma (10/24/2011)
ptrim = 68.5;         % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
% ptrim = 576/10;     % BTRM linear polynomial coeff. (N_main/N_trim)
Lm = 0.3636;        % BCSS nominal bend length - meas'd along linac "z" (m)
dL = 0.5828;        % BCSS nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)
c  = 2.99792458e8;  % light speed (m/s)

if energy<=1
  error('Electron energy must be > 1 GeV - try again.')
end

Imax=5.5;
BDESmax=Imax/ptrim;
thetamax=c*BDESmax/(1E10*energy*p(1));
AngstromsMax=thetamax^2*(dL+2*Lm/3)/1E-10;

Angstroms = abs(Angstroms); % use positive delay here (fs)
if Angstroms>AngstromsMax
    strError=sprintf('BCSS trim delay can only be set between 0 and %3.1f Angstroms - try again.',AngstromsMax);
  disp(strError)
end

theta = sqrt(1E-10*Angstroms/(dL+2*Lm/3));  % desired bend angle per HXRSS dipole (rad)
R56   = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2))*1e6;
BDES  = 1E10/c*energy*theta*p;              % BDES needed, including Leff increase as "1/fac" (kG-m)
Itrim = BDES*ptrim;                         % BDES needed, including Leff increase as "1/fac" (kG-m)
