function [BDES, BACT] = set_QS_energy_PEXT_m12(E,  m12_req, m34_req, dZ_OB, dz_IM)


% 2013_2 value
z_MIP = 1993.285;
z_ELANEX = 2015.22;
z_CHERFAR = 2016.0398;  
z_CHERNEAR = 2015.9298; 
% 2012 and 2013_1
z_CHERFAR_2013 = 2016.27; 
z_CHERNEAR_2013 = 2016.143; 
%

if nargin < 2,
  m12_req = 0;
end; % of

if nargin < 3,
  m34_req = 0;
end; % of

if nargin < 4,
  dZ_OB = 0;
end; % of

if nargin < 5,
  dZ_IM = 0;
end; % of


E0 = 20.35;
QS_setting = E;
z_OB = z_MIP+1.685+dZ_OB;
z_IM = z_CHERFAR + dZ_IM;
[isok, BDESQS1, BDESQS2, KQS1, KQS2, m12, m34, M4] = E200_calc_QS(z_OB, z_IM, QS_setting, E0, m12_req, m34_req);
BDESQS1
BDESQS2
VAL = [BDESQS1, BDESQS2];


%set_QS1_BDES(BDESQS1)
%set_QS2_BDES(BDESQS2)

%pause;

control_magnetSet({'LGPS:LI20:3261', 'LGPS:LI20:3311'}, VAL,  'action', 'TRIM');

pause(1);

[BACT, BDES] = control_magnetGet({'LGPS:LI20:3261', 'LGPS:LI20:3311'});
disp(sprintf('\nQS1:\nBDES = %.4f\nBACT = %.4f\n\nQS2:\nBDES = %.4f\nBACT = %.4f\n', BDES(1), BACT(1), BDES(2), BACT(2)));

 
