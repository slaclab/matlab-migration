function [BDES,xpos,dphi,theta,eta,R560,Lm,dL] = BC1_adjust(R56,energy,BDES0,Lm,dL)

%   [BDES,xpos,dphi,theta,eta,R560,Lm,dL] = BC1_adjust(R56,energy[,BDES0,Lm,dL]);
%
%   Function to calculate BDES of main BC1 supply, the three trims (BX11, BX13, BX14),
%   and the 5 nearby quads, plus the x-displacement and the RF S-band phase shift for any
%   |R56| and beam energy.  The five quad solutions assume at WS12: BETAX=BETAY=0.956 m
%   and ALPHAX=ALPHAY = 0, plus BETAX=1.771 m and ALPHAX=-0.159 at BX14 exit, plus the
%   QA12 energy is 90.8% of the BC1 energy.  The BDES settings for these five quads
%   are differential, with respect to the BDES settings at R56=39.05 mm, so they are
%   added to the nominal absolute BDES settings at R56=39.05 mm.
%
%    INPUTS:    R56:        The absolute R56 value requested (nom=0.039 m) - always >0 here (m)
%               energy:     The e- beam energy (nom=0.250) (GeV)
%               BDES0:      [Otional,DEF=0] Reverse calc. (BDES0 => R560) [kG-m]
%               Lm:         Magnet eff. length along straight axis (DEF=0.2032) (m)
%               dL:         B1-B2 Drift along straight axis (DEF=2.4349) (m)
%
%   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
%               BDES(2):    The BX11 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(3):    The BX13 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(4):    The BX14 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(5):    The QA12 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(6):    The Q21201 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(7):    The QM11 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(8):    The QM12 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               BDES(9):    The QM13 delta-BDES (wrt R56=39mm) - to be added to BDES (in kG)
%               xpos:       The chicane absolute displacement needed (m)
%               dphi:       RF phase shift needed upstream when changing from R560 to R56 (deg S-band)
%                           (SLC convention where <0 phase shift fixes delay of chicane)
%               theta:      Absolute value of bend angle of each dipole (rad)
%               eta:        Value of x-dispersion at chicane center (m) - negative for BC1 & BC2
%               R560:       The R56 based on BDES0 (m)
%               Lm:         Magnet eff. length along straight axis - echo of optional input arg. (m)
%               dL:         B1-B2 Drift along straight axis - echo of optional input arg. (m)

% ========================================================================================

if energy<=0.01
  error('Electron energy must be > 0.01 GeV - try again.')
end

R56 = abs(R56);             % use positive R56 here (m)
if R56>0.065
  error('BC1 |R56| can only be set between 0 and 65 mm - try again.')
end

gam = energy/510.99906E-6;  % Lorentz factor [ ]

if ~exist('Lm','var')
  Lm = 0.2032;      % BC1 nominal bend length - meas'd along linac "z" (m)
else
  if Lm>1 || Lm<0.001
    error('BC1 dipole length can only be set between 0.001 m and 1 m - try again.')
  end
end
if ~exist('dL','var')
  dL = 2.4349;      % BC1 nominal drift length BX11-BX12 (& BX13-BX14) - meas'd along linac "z" (m)
else
  if dL>10 || dL<0.001
    error('BC1 drift length can only be set between 0.001 m and 10 m - try again.')
  end
end

if ~exist('BDES0','var')
  BDES0 = 0;      % Initial BDES only needed for a reverse calc (i.e., BDES0=>R560) (m)
end

c   = 2.99792458e8;                     % light speed (m/s)
lam = c/2856e6;                         % S-band RF wavelength (m)
theta0 = asin(c*BDES0/1e10/energy);     % bend angle (rad)
theta0 = abs(theta0);
[X0,phi0,eta0,R560]=chic_params(theta0,Lm,dL,lam,gam);

% Non-linear solve for "theta" which produces the right R56:
theta1 = sqrt(R56/2/(dL+2*Lm/3));   % first estimate of angle (rad)
theta = fzero(@(theta1) 2*sec(theta1)*(2*Lm*(theta1+eps)*cot(theta1+eps)-2*Lm-dL*(tan(theta1))^2) + R56,theta1);  % more accurate angle, from Juhao [rad]
theta = abs(theta);

[xpos,phi,eta]=chic_params(theta,Lm,dL,lam,gam);
dphi = phi - phi0;      % RF phase shift needed when going from theta0 to theta [deg]


p_QA12   = [ 3.101264E-3 -1.227497E-4  1.121094E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_Q21201 = [ 7.600967E-2 -1.771781E-3 -4.551025E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_QM11   = [-2.659841E-2  6.132963E-4  1.770450E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_QM12   = [-3.261309E-1  7.860926E-3  1.260354E-5];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
p_QM13   = [ 1.439382E-1 -3.377421E-3 -7.937800E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
pbyE = [p_QA12*0.908/0.227;p_Q21201/0.250;p_QM11/0.250;p_QM12/0.250;p_QM13/0.250];

v = [1 (R56*1E3) (R56*1E3)^2]';                         % at desired R56
Q_dBDESd   = pbyE*v*energy;                  % dBDES for Qs [kG]

v0 = [1 (R560*1E3) (R560*1E3)^2]';                      % at present R56
Q_dBDES0   = pbyE*v0*energy;                 % dBDES for Qs [kG]
Q_dBDES   = Q_dBDESd - Q_dBDES0;               % dBDES to be applied...
BDESQ = Q_dBDES'; % now 9 BDES values (BEND, 3-BTRMs, & 5 quads)

BDES = BC1_BDES(theta*180/pi,energy);
BDES = [BDES BDESQ]; % now 9 BDES values (BEND, 3-BTRMs, & 5 quads)


function [xpos, phi, eta, R56] = chic_params(theta, Lm, dL, lam, gam)

% more accurate x-displacement of chicane center, from Juhao (m)
xpos = 2*Lm*tan(theta/2) + dL*tan(theta);

% RF phase needed at theta, from Juhao (deg)
phi = -(4*Lm/util_sinc(theta) + 2*dL/cos(theta) - 4*Lm - 2*dL)*360/lam;

% x-dispersion at chicane center, from Juhao [m]
eta = -gam^2/(gam^2-1)*( 2*Lm*tan(theta)/(1+cos(theta)) + dL*(tan(theta) + (tan(theta))^3) );

R56 = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2));
%R56 = abs((4*Lm/util_sinc(theta)-4*Lm/cos(theta)-2*dL*(tan(theta))^2/cos(theta)));
