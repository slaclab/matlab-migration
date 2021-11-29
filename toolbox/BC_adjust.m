function [BDES, xpos, phi, theta, eta, R560, Lm, dL, X0, r56, eta0, phi0, delay0] = BC_adjust(name, val, energy, BDES0, Lm, dL)

%   [BDES, xpos, phi, theta, eta, R560, Lm, dL] = BC_adjust(name, R56, X, energy[, BDES0, Lm, dL])
%
%   Function to calculate BDES of main BCn supply, the three trims (BXn1, BXn3, BXn4),
%   and the nearby quads, plus the x-displacement and the RF S-band phase shift for any
%   |R56| and beam energy.  The four quad solutions assume at LI25BEG: BETAX=11.111 m
%   and ALPHAX = -0.927, BETAY=70.511 m, and ALPHAY = 2.236.  The BDES settings for these four quads
%   are differential, with respect to the BDES settings at R56=24.7 mm, so they are
%   added to the nominal absolute BDES settings at R56=24.7 mm.
%
%    INPUTS:    NAME:       Name of the chicane (BCH, BC1, BC2)
%               VAL:        The absolute R56 value requested - always >0 here (m)
%                           For BCH, the new X-offset of the chicane - always >0 here (m)
%                           For seeding chicanes, the new delay value requested - always >0 here (fs)
%               energy:     The e- beam energy (GeV), for BCH is [E_QA01 E_QE01]
%               BDES0:      [Optional,DEF=0] Reverse calc. (BDES0 => R560) [kG-m]
%               Lm:         Magnet eff. length along straight axis (Optional) (m)
%               dL:         B1-B2 Drift along straight axis (Optional) (m)
%
%   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
%               BDES(2):    The BXn1 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(3):    The BXn3 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(4):    The BXn4 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(5:end):The Qs delta-BDES (wrt nominal R56) - to be added to BDES (in kG)
%               xpos:       The chicane absolute displacement needed (m)
%               phi:        Absolute RF phase shift needed upstream when changing from 0 to R56 (deg S-band)
%                           (SLC convention where <0 phase shift fixes delay of chicane)
%               theta:      Absolute value of bend angle of each dipole (rad)
%               eta:        Value of x-dispersion at chicane center (m) - negative for BCH, BC1 & BC2
%               R560:       The R56 based on BDES0 (m, or um for seeding chicanes)
%               Lm:         Magnet eff. length along straight axis - echo of optional input arg. (m)
%               dL:         B1-B2 Drift along straight axis - echo of optional input arg. (m)
%               X0:         The chicane absolute displacement based on BDES0 (m)
%               r56:        The R56 based on X (m, or um for seeding chicanes)
%               eta0:       Value of x-dispersion based on BDES0 (m)

% Defaults:
% BCH: X offset 0.035 m, BDES0 0.5908 kG-m, energy [0.064 0.135] GeV, Lm 0.1244 m, dL 0.1406 m
% Quads are QA01, QA02, QE01, QE02, QE03, QE04
% Quad changes based on L0a exit BETAX=1.410 m, ALPHAX = -2.613, BETAY=6.706 m, ALPHAY = 0.506

% BC1: R56 0.039 m, energy 0.250 GeV, Lm 0.2032 m, dL 2.4349 m
% Quads are QA12, Q21201, QM11, QM12, QM13
% Quad changes based on WS12 BETAX=BETAY=0.956 m, ALPHAX=ALPHAY = 0, BX14 exit BETAX=1.771 m, ALPHAX=-0.159
% QA12 energy is 90.8% of the BC1 energy

% BC2: R56 0.0247 m, energy 4.300 GeV, Lm 0.549 m, dL 9.8602 m
% Quads are Q24702, QM21, QM22, Q24901
% Quad changes based on LI25BEG BETAX=11.111 m, ALPHAX = -0.927, BETAY=70.511 m, ALPHAY = 2.236

% ========================================================================================

[Xmax,R56max,dLmax,dMax]=deal(Inf);
switch name
    case 'BCH'
        enMin=0.05;
        Xmax=0.040;
        Lm0 = 0.1244;   % BCH nominal bend length - meas'd along linac "z" (m)
        dL = 0.1406;    % BCH nominal drift length BXH1-BXH2 (& BXH3-BXH4) - meas'd along linac "z" (m)
        dLmax=1;
    case 'BC1'
        enMin=0.01;
        R56max=0.065;
        Lm0 = 0.2032;   % BC1 nominal bend length - meas'd along linac "z" (m)
        dL0 = 2.4349;   % BC1 nominal drift length BX11-BX12 (& BX13-BX14) - meas'd along linac "z" (m)
        dLmax=10;
    case 'BC2'
        enMin=0.1;
        R56max=0.050;
        Lm0=0.549;      % BC2 nominal bend length - meas'd along linac "z" (m)
        dL0=9.8602;     % BC2 nominal drift length BX21-BX22 (& BX23-BX24) - meas'd along linac "z" (m)
        dLmax=20;
    case {'BCSS' 'HXRSS'}
        enMin=1;
        dMax = 50;
        Lm0 = 0.3636;   % HXRSS nominal bend length - meas'd along linac "z" (m)
        dL0 = 0.5828;   % HXRSS nominal drift length BXHS1-BXHS2 (& BXHS3-BXHS4) - meas'd along linac "z" (m)
    case {'SXRSS'}
        enMin=1;
        dMax = 1000;
        Lm0 = 0.3636;   % SXRSS nominal bend length - meas'd along linac "z" (m)
        dL0 = 0.8294;   % SXRSS nominal drift length BXSS1-BXSS2 (& BXSS3-BXSS4) - meas'd along linac "z" (m)
    otherwise
        error('Unknown bunch compressor NAME.')
end
[R56,X,delay]=deal([]);
if ismember(name,{'BCSS' 'HXRSS' 'SXRSS'})
    delay=val;
elseif ismember(name,{'BCH'})
    X=val;
else
    R56=val;
end

if any(energy <= enMin)
  error('Electron energy must be > %5.0f GeV - try again.',enMin)
end

R56 = abs(R56);         % use positive R56 here (m)
if R56 > R56max
  error('%s |R56| can only be set between 0 and %5.0f mm - try again.',name,R56max*1000)
end

X = abs(X);             % use positive X here (m)
if X > Xmax
  error('%s X can only be set between 0 and %5.0f mm - try again.',name,Xmax*1000)
end

delay = abs(delay);     % use positive delay here (fs)
if delay > dMax
  error('%s delay can only be set between 0 and %d fs - try again.',name,dMax)
end

gam = energy(end)/510.99906E-6;  % Lorentz factor [ ]

if ~exist('Lm','var')
  Lm = Lm0;
else
  if Lm > 1 || Lm < 0.001
    error('%s dipole length can only be set between 0.001 m and 1 m - try again.',name)
  end
end
if ~exist('dL','var')
  dL = dL0;
else
  if dL > dLmax || dL < 0.001
    error('%s drift length can only be set between 0.001 m and %5.0f m - try again.',name,dLmax)
  end
end

if ~exist('BDES0','var')
  BDES0 = 0;      % Initial BDES only needed for a reverse calc (i.e., BDES0=>R560) (m)
end

c   = 2.99792458e8;                  % light speed (m/s)
lam = c/2856e6;                      % S-band RF wavelength (m)
theta0 = asin(c*BDES0/1E10/energy(end));  % bend angle (rad)
theta0 = abs(theta0);
[X0,phi0,R560,eta0]=chic_params(theta0,Lm,dL,lam,gam);
delay0=-phi0/360*lam/c*1e15;

try
if ~isempty(delay)
    theta  = sqrt(1E-15*c*delay/(dL+2*Lm/3));    % desired bend angle per chicane dipole (rad)
elseif ~isempty(X)
    % Non-linear solve for "theta" which produces the right X:
    theta1 = X/(Lm + dL);   % initial estimate of bend angle (rad)
    theta  = fzero(@(theta1) 2*Lm*tan(theta1/2) + dL*tan(theta1) - X,theta1); % more accurate angle, from Juhao [rad]
else
    % Non-linear solve for "theta" which produces the right R56:
    theta1 = sqrt(R56/2/(dL+2*Lm/3));   % first estimate of angle (rad)
    theta = fzero(@(theta1) 2*sec(theta1)*(2*Lm*(theta1+eps)*cot(theta1+eps)-2*Lm-dL*(tan(theta1))^2) + R56,theta1);  % more accurate angle, from Juhao [rad]
end
theta = abs(theta);
catch
    theta = 0;
end

[xpos,phi,r56,eta]=chic_params(theta,Lm,dL,lam,gam);
if ismember(name,{'BCSS' 'HXRSS' 'SXRSS'}),r56=r56*1e6;R560=R560*1e6;end

% Get quad values.
switch name
    case 'BCH'
        % polynomials for adjusting 6 quads as func of X in mm [m^-2/mm^(i-1)] (X = 0 to 40 mm; 9/14/08, from LCLS11SEP08 MAD file)
        k_QA01 = [-1.411204629390134e+001    4.217347548425910e-003    1.777716904755344e-004    1.024765095038003e-004   -3.659894286888399e-006    4.832297834070687e-008];
        k_QA02 = [ 1.460469173473512e+001   -4.199602673736802e-003    5.631603657552020e-004   -1.019148299205028e-004    3.625897590015015e-006   -4.786274254955925e-008];
        k_QE01 = [-9.434597011592731e+000    2.245785689345707e-002   -4.621708262155577e-003    5.465126752758476e-004   -1.945545751799238e-005    2.583732622695911e-007];
        k_QE02 = [ 6.632624435029086e+000   -1.685704124278180e-002    4.040324462217129e-003   -4.083346707281663e-004    1.455685225892727e-005   -1.906153239151062e-007];
        k_QE03 = [ 7.013460902866437e+000   -2.051894161696932e-004   -5.842857332938678e-004   -5.712469360327432e-006    1.586540797625657e-007   -3.838541159288389e-009];
        k_QE04 = [-6.588911101721322e+000    2.019481285758573e-004    8.912519514548833e-004    5.683451944895168e-006   -1.456576038797674e-007    3.853330572668456e-009];
        k_Q = [k_QA01;k_QA02;k_QE01;k_QE02;k_QE03;k_QE04];

        Leff = 0.108;                             % effective magnetic length of QA01-QE04 quads (m)
        Brho1 = 1E10/c*energy(1)*Leff;            % magnetic rigidity at QA01-QA02 energy times effective length (kG-m^2)
        Brho2 = 1E10/c*energy(end)*Leff;          % magnetic rigidity at QE01-QE04 energy times effective length (kG-m^2)
        pScaled = diag([Brho1 Brho1 Brho2 Brho2 Brho2 Brho2])*k_Q;

        v  = ( X*1E3).^(0:5)';   % new X vector to calculate new quad BDES's...
        v0 = (X0*1E3).^(0:5)';   % present X vector to calculate approx. present quad BDES's...
    case 'BC1'
        p_QA12   = [ 3.101264E-3 -1.227497E-4  1.121094E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_Q21201 = [ 7.600967E-2 -1.771781E-3 -4.551025E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_QM11   = [-2.659841E-2  6.132963E-4  1.770450E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_QM12   = [-3.261309E-1  7.860926E-3  1.260354E-5];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_QM13   = [ 1.439382E-1 -3.377421E-3 -7.937800E-6];    % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        pScaled = diag(energy*[0.908/0.227 1/0.250 1/0.250 1/0.250 1/0.250])*[p_QA12;p_Q21201;p_QM11;p_QM12;p_QM13];

        v  = ( R56*1E3).^(0:2)';        % at desired R56
        v0 = (R560*1E3).^(0:2)';        % at present R56
    case 'BC2'
        p_Q24701 = [ 0.0931 -0.003769208640237];  % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_QM21   = [-0.0790  0.003199782418856];  % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_QM22   = [-0.5979  0.024206130141106];  % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        p_Q24901 = [ 0.1636 -0.006624253754015];  % polynomials for adjusting quads as func of R56 in mm [kG/mm^i]
        pScaled = energy/4.3*[p_Q24701;p_QM21;p_QM22;p_Q24901];

        v  = ( R56*1E3).^(0:1)';        % at desired R56
        v0 = (R560*1E3).^(0:1)';        % at present R56
    otherwise
        [pScaled,v,v0]=deal([]);
end
Q_BDES  = pScaled*v;        % BDES or dBDES for Qs [kG]
Q_BDES0 = pScaled*v0;       % BDES or dBDES for Qs at present setting [kG]
Q_dBDES = Q_BDES - Q_BDES0; % delta-BDES for Qs going from present to new setting [kG]

BDES = model_energyBTrim(theta*180/pi,energy(end),name);
BDES = [BDES Q_dBDES']; % now 4+n BDES values (BEND, 3-BTRMs, & n quads)


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
