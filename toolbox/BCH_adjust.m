function [BDES,X0,dphi,theta,eta,eta0,R56,R560] = BCH_adjust(X,BDES0,energy1,energy2,Lm,dL)

%   [BDES,X0,dphi,theta,eta,eta0,R56,R560] = BCH_adjust(X,BDES0[,energy1,energy2,Lm,dL]);
%
%   Function to calculate BDES of main laser-heater chicane bend supply, its three trims
%   (BXH1, BXH3, BXH4), and the 6 nearby quad BDES changes (QA01-02, QE01-04), plus the
%   RF S-band phase shift for any X and beam energies (at L0a & L0b exits).  The
%   six quad solutions assume at L0a-exit: BETAX=1.410 m, ALPHAX = -2.613, BETAY=6.706 m,
%   ALPHAY = 0.506 (measured at OTR2 & back-tracked) and also assume that the laser heater
%   undulator gap is set for a 758-nm IR laser.  The BDES settings for the six quads are
%   differential and are added to the present absolute BDES settings, depending on BDES0
%   (present chicane BDES).
%
%   INPUTS:     X:        The new X-offset of the chicane (nom=0.035 m) - always >0 here (m)
%               BDES0:    The present laser-heater chicane main BDES setting (kG-m, nom = 0.5908)
%               energy1:  [Otional,DEF=0.064 GeV] The e- beam energy at QA01 & QA02 (GeV)
%               energy2:  [Otional,DEF=0.135 GeV] The e- beam energy at QE01-QE04 (GeV)
%               Lm:       [Otional,DEF=0.1244 m] Chicane bend magnet eff. length along
%                         straight axis (m)
%               dL:       [Otional,DEF=0.1406 m] B1-B2 drift along straight axis (m)
%
%   OUTPUTS:    BDES(1):  Main chicane supply BDES to get X - absolute BDES (kG-m)
%               BDES(2):  BXH1 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(3):  BXH3 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(4):  BXH4 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(5):  QA01 delta-BDES (to change from X0 to X) - adds to BDES (kG)
%               BDES(6):  QA02 delta-BDES (to change from X0 to X) - adds to BDES (kG)
%               BDES(7):  QE01 delta-BDES (to change from X0 to X) - adds to BDES (kG)
%               BDES(8):  QE02 delta-BDES (to change from X0 to X) - adds to BDES (kG)
%               BDES(9):  QE03 delta-BDES (to change from X0 to X) - adds to BDES (kG)
%               BDES(10): QE04 delta-BDES (to change from X0 to X) - adds to BDES (kG)
%               X0:       The present X-offset of the chicane (nom=0.035 m) - always >0 here (m)
%               dphi:     Add this upstream beam/RF phase shift when changing from 
%                         X0 to X (deg S-band) - (e.g., dphi > 0 if X goes from 35 mm to 0,
%                         which means injector RF/timing should be changed more positive
%                         to delay injector bunch more, which compensates the now missing
%                         chicane delay)
%               theta:    Absolute value of new bend angle of each dipole (rad)
%               eta:      Value of new x-dispersion at chicane center (m) - negative for BCH, BC1, BC2
%               eta0:     Value of present x-dispersion at chicane center (m) - negative for BCH, BC1, BC2
%               R56:      Absolute value of new R56 of the chicane (ignores undulator)
%               R560:     Absolute value of present R56 of the chicane (ignores undulator)

% ========================================================================================

if ~exist('energy1','var')
  energy1 = 0.064;            % default e- beam energy at QA01-QA02 (GeV)
end
if energy1<=0.05
  error('Electron energy at QA01-QA02 must be > 0.05 GeV - try again.')
end

if ~exist('energy2','var')
  energy2 = 0.135;            % default e- beam energy at QE01-QE04 (GeV)
end
if energy2<=0.05
  error('Electron energy at QE01-QE04 must be > 0.05 GeV - try again.')
end

X = abs(X);                   % use positive X here (m)
if X>0.040
  error('BCH X can only be set between 0 and 40 mm - try again.')
end

gam2 = energy2/510.99906E-6;  % Lorentz factor [ ]

if ~exist('Lm','var')
  Lm = 0.1244;                % BCH nominal bend length - meas'd along linac "z" (m)
else
  if Lm>1 || Lm<0.001
    error('BCH dipole length can only be set between 0.001 m and 1 m - try again.')
  end
end
if ~exist('dL','var')
  dL = 0.1406;                % BCH nominal drift length BX21-BX22 (& BX23-BX24) - meas'd along linac "z" (m)
else
  if dL>20 || dL<0.001
    error('BC1 drift length can only be set between 0.001 m and 1 m - try again.')
  end
end

c   = 2.99792458e8;                  % light speed (m/s)
lam = c/2856e6;                      % S-band RF wavelength (m)
theta0 = asin(c*BDES0/1e10/energy2); % accurate present bend angle [rad]
theta0 = abs(theta0);
[X0,phi0,eta0,R560]=chic_params(theta0,Lm,dL,lam,gam2);

% Non-linear solve for "theta" which produces the right X:
theta1 = X/(Lm + dL);   % initial estimate of bend angle (rad)
theta  = fzero(@(theta1) 2*Lm*tan(theta1/2) + dL*tan(theta1) - X,theta1); % more accurate angle, from Juhao [rad]
theta  = abs(theta);

[xpos,phi,eta,R56]=chic_params(theta,Lm,dL,lam,gam2);
dphi = phi - phi0;      % RF phase shift needed when going from theta0 to theta [deg]


% polynomials for adjusting 6 quads as func of X in mm [m^-2/mm^(i-1)] (X = 0 to 40 mm; 9/14/08, from LCLS11SEP08 MAD file)
k_QA01 = [-1.411204629390134e+001    4.217347548425910e-003    1.777716904755344e-004    1.024765095038003e-004   -3.659894286888399e-006    4.832297834070687e-008];
k_QA02 = [ 1.460469173473512e+001   -4.199602673736802e-003    5.631603657552020e-004   -1.019148299205028e-004    3.625897590015015e-006   -4.786274254955925e-008];
k_QE01 = [-9.434597011592731e+000    2.245785689345707e-002   -4.621708262155577e-003    5.465126752758476e-004   -1.945545751799238e-005    2.583732622695911e-007];
k_QE02 = [ 6.632624435029086e+000   -1.685704124278180e-002    4.040324462217129e-003   -4.083346707281663e-004    1.455685225892727e-005   -1.906153239151062e-007];
k_QE03 = [ 7.013460902866437e+000   -2.051894161696932e-004   -5.842857332938678e-004   -5.712469360327432e-006    1.586540797625657e-007   -3.838541159288389e-009];
k_QE04 = [-6.588911101721322e+000    2.019481285758573e-004    8.912519514548833e-004    5.683451944895168e-006   -1.456576038797674e-007    3.853330572668456e-009];
k_Q = [k_QA01;k_QA02;k_QE01;k_QE02;k_QE03;k_QE04];

v  = [1  (X*1E3)  (X*1E3)^2  (X*1E3)^3  (X*1E3)^4  (X*1E3)^5]';   % new X vector to calculate new quad BDES's...
v0 = [1 (X0*1E3) (X0*1E3)^2 (X0*1E3)^3 (X0*1E3)^4 (X0*1E3)^5]';   % present X vector to calculate approx. present quad BDES's...

Leff = 0.108;                           % effective magnetic length of QA01-QE04 quads (m)
Brho1 = 1E10/c*energy1*Leff;            % magnetic rigidity at QA01-QA02 energy times effective length (kG-m^2)
Brho2 = 1E10/c*energy2*Leff;            % magnetic rigidity at QE01-QE04 energy times effective length (kG-m^2)

bpk_Q = diag([Brho1 Brho1 Brho2 Brho2 Brho2 Brho2])*k_Q;

Q_BDES0 = bpk_Q*v0;           % BDES for Qs at present X [kG]
Q_BDES = bpk_Q*v;             % BDES for Qs at new X [kG]
Q_dBDES = Q_BDES - Q_BDES0;    % delta-BDES for Qs going from present to new X [kG]
BDESQ = Q_dBDES'; % now 10 BDES values (BEND, 3-BTRMs, & 6 quads)

BDES = BCH_BDES(theta*180/pi,energy2);
BDES = [BDES BDESQ]; % now 10 BDES values (BEND, 3-BTRMs, & 6 quads)


function [xpos, phi, eta, R56] = chic_params(theta, Lm, dL, lam, gam)

% more accurate x-displacement of chicane center, from Juhao (m)
xpos = 2*Lm*tan(theta/2) + dL*tan(theta);

% RF phase needed at theta, from Juhao (deg)
phi = -(4*Lm/util_sinc(theta) + 2*dL/cos(theta ) - 4*Lm - 2*dL)*360/lam;

% x-dispersion at chicane center, from Juhao [m]
eta = -gam^2/(gam^2-1)*( 2*Lm*tan(theta)/(1+cos(theta)) + dL*(tan(theta) + (tan(theta))^3) );

% R56 value (abs value in meters)
R56 = abs(2*sec(theta)*(2*Lm*(theta+eps)*cot(theta+eps)-2*Lm-dL*(tan(theta))^2));
%R56 = abs((4*Lm/util_sinc(theta)-4*Lm/cos(theta)-2*dL*(tan(theta))^2/cos(theta)));