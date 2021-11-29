function [BDES, theta, Itrim, R56, Angstroms0, R560, X0, phi0] = BC_phase(Angstroms, energy, str, BDES0)

%   [BDES,theta,Itrim] = BC_phase(Angstroms,energy);
%
%   Function to calculate, with the main supply off, the 4 trim settings of the self seeding chicane supply
%   to vary the phasing given the desired chicane delay (Angstroms) and the elecron energy (GeV).
%
%    INPUTS:    Angstroms:  The chicane delay value requested - positive,
%                           if negative a negative bend angle will be chosen (Angstroms)
%               energy:     The e- energy (GeV)
%               BDES0:      [Optional,DEF=0] Reverse calc. (BDES0 => R560) [kG-m]
%
%   OUTPUTS:    BDES:       The BX*S1,2,3,4 BTRM BDES needed for "Angstrom" delay (in main-coil Amperes)
%               theta:      Value of bend angle of each dipole (rad)
%               Itrim:      Actual excitation current in each trim (amps, not main-coil amps)

% ========================================================================================

switch str
    case {'BCSS' 'HXRSS'}
        p = [3.040 3.040 3.040 3.040];            % per P. Emma (10/24/2011)
        ptrim = 68.5;       % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
        % ptrim = 576/10;    % BTRM linear polynomial coeff. (N_main/N_trim)
        Lm = 0.3636;        % BCSS nominal bend length - meas'd along linac "z" (m)
        dL = 0.5828;        % BCSS nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)
  
    case {'SXRSS'}
        p = [2.849488 2.846475 2.839548 2.852310];            % per JW (9/23/2013)
        ptrim = 68.5;       % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
        Lm = 0.3636;        % BCSS nominal bend length - meas'd along linac "z" (m)
        dL = 0.8294;        % BCSS nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)
        
    case {'XLEAP'}
        p = [4.620713 4.625987 4.62226 4.639716];            
        ptrim = 38.4;       % BTRM linear polynomial coeff. (N_main/N_trim) (measured)
        Lm = 0.3636;        % BCSS nominal bend length - meas'd along linac "z" (m)
        dL = 0.8294;        % BCSS nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)        
end

if energy<=1
  error('Electron energy must be > 1 GeV - try again.')
end

if ~exist('BDES0','var')
  BDES0 = 0;      % Initial BDES only needed for a reverse calc (i.e., BDES0=>R560) (m)
end

c = 2.99792458e8;  % light speed (m/s)
theta0 = asin(c*BDES0/1E10/energy/p(1));  % bend angle (rad)
Angstroms0=theta0^2*(dL+2*Lm/3)*1e10;
lam=0.03/2/(energy/511e-6)^2*(1+(3.5^2)/2);
%phi0=Angstroms0*1e-10*360/lam;
[X0,phi0,R560]=chic_params(theta0,Lm,dL,lam);R560=R560*1e6;phi0=-phi0;
%Angstroms0=phi0/360*lam*1e10;

Imax=5.5;
BDESmax=Imax/ptrim;
thetamax=c*BDESmax/(1E10*energy*p(1));
AngstromsMax=thetamax^2*(dL+2*Lm/3)/1E-10;

if abs(Angstroms) > AngstromsMax
    strError=sprintf('%s trim delay can only be set between +- %3.1f Angstroms - try again.',str,AngstromsMax);
    disp(strError);
end

theta = sign(Angstroms)*sqrt(1E-10*abs(Angstroms)/(dL+2*Lm/3));  % desired bend angle per dipole (rad)
R56   = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2))*1e6;
%[X,phi,R56]=chic_params(theta,Lm,dL,1);R56=R56*1e6;
BDES  = 1E10/c*energy*theta*p;              % BDES needed, including Leff increase as "1/fac" (kG-m)
Itrim = BDES*ptrim;                         % BDES needed, including Leff increase as "1/fac" (kG-m)


function [xpos, phi, R56, eta] = chic_params(theta, Lm, dL, lam, gam)

% more accurate x-displacement of chicane center, from Juhao (m)
xpos = 2*Lm*tan(theta/2) + dL*tan(theta);

% RF phase needed at theta, from Juhao (deg)
phi = -(4*Lm/util_sinc(theta) + 2*dL/cos(theta) - 4*Lm - 2*dL)*360/lam;

% R56 value (abs value in meters)
R56 = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2));
%R56 = abs((4*Lm/util_sinc(theta)-4*Lm/cos(theta)-2*dL*(tan(theta))^2/cos(theta)));

if nargout < 4, return, end
% x-dispersion at chicane center, from Juhao [m]
eta = -gam^2/(gam^2-1)*( 2*Lm*tan(theta)/(1+cos(theta)) + dL*(tan(theta) + (tan(theta))^3) );
