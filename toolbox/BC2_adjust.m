function [BDES,xpos,dphi,theta,eta,R560,Lm,dL] = BC2_adjust(R56,energy,BDES0,Lm,dL)

%   [BDES,xpos,dphi,theta,eta,R560,Lm,dL] = BC2_adjust(R56,energy[,BDES0,Lm,dL]);
%
%   Function to calculate BDES of main BC2 supply, the three trims (BX21, BX23, BX24),
%   and the 4 nearby quads, plus the x-displacement and the RF S-band phase shift for any
%   |R56| and beam energy.  The four quad solutions assume at LI25BEG: BETAX=11.111 m
%   and ALPHAX = -0.927, BETAY=70.511 m, and ALPHAY = 2.236.  The BDES settings for these four quads
%   are differential, with respect to the BDES settings at R56=24.7 mm, so they are
%   added to the nominal absolute BDES settings at R56=24.7 mm.
%
%    INPUTS:    R56:        The absolute R56 value requested (nom=0.0247 m) - always >0 here (m)
%               energy:     The e- beam energy (nom=4.300) (GeV)
%               BDES0:      [Otional,DEF=0] Reverse calc. (BDES0 => R560) [kG-m]
%               Lm:         Magnet eff. length along straight axis (DEF=0.549) (m)
%               dL:         B1-B2 Drift along straight axis (DEF=9.8602) (m)
%
%   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
%               BDES(2):    The BX21 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(3):    The BX23 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(4):    The BX24 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(5):    The Q24701 delta-BDES (wrt R56=24.7 mm) - to be added to BDES (in kG)
%               BDES(6):    The QM21 delta-BDES (wrt R56=24.7 mm) - to be added to BDES (in kG)
%               BDES(7):    The QM22 delta-BDES (wrt R56=24.7 mm) - to be added to BDES (in kG)
%               BDES(8):    The Q24901 delta-BDES (wrt R56=24.7 mm) - to be added to BDES (in kG)
%               xpos:       The chicane absolute displacement needed (m)
%               dphi:       RF phase shift needed upstream when changing from R560 to R56 (deg S-band)
%                           (SLC convention where <0 phase shift fixes delay of chicane)
%               theta:      Absolute value of bend angle of each dipole (rad)
%               eta:        Value of x-dispersion at chicane center (m) - negative for BC1 & BC2
%               R560:       The R56 based on BDES0 (m)
%               Lm:         Magnet eff. length along straight axis - echo of optional input arg. (m)
%               dL:         B1-B2 Drift along straight axis - echo of optional input arg. (m)

% ========================================================================================

if energy<=0.1
  error('Electron energy must be > 0.1 GeV - try again.')
end

R56 = abs(R56);             % use positive R56 here (m)
if R56>0.050
  error('BC2 |R56| can only be set between 0 and 50 mm - try again.')
end

gam = energy/510.99906E-6;  % Lorentz factor [ ]

if ~exist('Lm','var')
  Lm = 0.549;      % BC2 nominal bend length - meas'd along linac "z" (m)
else
  if Lm>1 || Lm<0.001
    error('BC2 dipole length can only be set between 0.001 m and 1 m - try again.')
  end
end
if ~exist('dL','var')
  dL = 9.8602;      % BC2 nominal drift length BX21-BX22 (& BX23-BX24) - meas'd along linac "z" (m)
else
  if dL>20 || dL<0.001
    error('BC1 drift length can only be set between 0.001 m and 20 m - try again.')
  end
end

if ~exist('BDES0','var')
  BDES0 = 0;      % Initial BDES only needed for a reverse calc (i.e., BDES0=>R560) (m)
end

c      = 2.99792458e8;                  % light speed (m/s)
lam    = c/2856e6;                      % S-band RF wavelength (m)
theta0 = asin(c*BDES0/1e10/energy);     % bend angle (rad)
theta0 = abs(theta0);
[X0,phi0,eta0,R560]=chic_params(theta0,Lm,dL,lam,gam);

% Non-linear solve for "theta" which produces the right R56:
theta1 = sqrt(R56/2/(dL+2*Lm/3));   % first estimate of angle (rad)
theta = fzero(@(theta1) 2*sec(theta1)*(2*Lm*(theta1+eps)*cot(theta1+eps)-2*Lm-dL*(tan(theta1))^2) + R56,theta1);  % more accurate angle, from Juhao [rad]
theta = abs(theta);

[xpos,phi,eta]=chic_params(theta,Lm,dL,lam,gam);
dphi = phi - phi0;      % RF phase shift needed when going from theta0 to theta [deg]


p_Q24701 = [ 0.0931 -0.003769208640237];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_QM21   = [-0.0790  0.003199782418856];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_QM22   = [-0.5979  0.024206130141106];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_Q24901 = [ 0.1636 -0.006624253754015];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
pbyE = [p_Q24701;p_QM21;p_QM22;p_Q24901]/4.3;

v = [1 (R56*1E3)]';
Q_dBDES = pbyE*v*energy;               % dBDES for Qs [kG]
BDESQ = Q_dBDES'; % now 8 BDES values (BEND, 3-BTRMs, & 4 quads)

BDES = BC2_BDES(theta*180/pi,energy);
BDES = [BDES BDESQ];


function [xpos, phi, eta, R56] = chic_params(theta, Lm, dL, lam, gam)

% more accurate x-displacement of chicane center, from Juhao (m)
xpos = 2*Lm*tan(theta/2) + dL*tan(theta);

% RF phase needed at theta, from Juhao (deg)
phi = -(4*Lm/util_sinc(theta) + 2*dL/cos(theta ) - 4*Lm - 2*dL)*360/lam;

% x-dispersion at chicane center, from Juhao [m]
eta = -gam^2/(gam^2-1)*( 2*Lm*tan(theta)/(1+cos(theta)) + dL*(tan(theta) + (tan(theta))^3) );

R56 = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2));
%R56 = abs((4*Lm/util_sinc(theta)-4*Lm/cos(theta)-2*dL*(tan(theta))^2/cos(theta)));
