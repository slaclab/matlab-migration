% Usage :
%     function [m12, m34, M4] = E200_calc_QS0_M_abs(KQS1, KQS2, delta_E_E0, z_OB, z_IM, KQS0)
% calc's imaging terms of FACET spectrometer

%% Changelog :
%% E. Adli, February 26, 2013
%%   First version!
%% E. Adli, November 12, 2013
%%   Updated to use absolute coordinates
%% E. Adli, February 18, 2013
%%   Included QS0

function [m12, m34, M4] = E200_calc_QS0_M_abs(KQS1, KQS2, delta_E_E0, z_OB, z_IM, KQS0)
% K1, K2 [/m2] 
% delta_E_E0 [-], i.e. QS=+1, delta_E_E0 = +1/20.35

% absolute value of QS1 and QS2
z_QS0 = 1996.49; % [m], middle of quad
z_QS1 = 1999.206665; % [m], middle of quad
z_QS2 = 2004.206665; % [m], middle of quad
LEFF_QS0 = 0.461; % [m]
LEFF_QS1 = 1; % [m]
LEFF_QS2 = 1; % [m]
LEFF = LEFF_QS1; % [m]
LEFF_BEND = 0.9779; % [m]
z_BEND = 2005.938477; % [m], middle of bend


k0 =  abs(KQS0) / (1+delta_E_E0);
k1 =  abs(KQS1) / (1+delta_E_E0);
k2 =  abs(KQS2) / (1+delta_E_E0);

OO = zeros(2,2);

% Thick lens

% QS0 full
k = abs(k0);
if(k > 0)
phi = LEFF_QS0*sqrt(k);
M_F = [cos(phi)             (1/sqrt(k))*sin(phi)
       -sqrt(k)*sin(phi)    cos(phi)];
M_D = [cosh(phi)             (1/sqrt(k))*sinh(phi)
       sqrt(k)*sinh(phi)    cosh(phi)];
else
  M_D = [1 LEFF_QS0; 0 1];
  M_F = [1 LEFF_QS0; 0 1];
end% if
M4_D_QS0 = [M_D OO; OO M_F];


% QS1 full
k = abs(k1);
if(k > 0)
phi = LEFF_QS1*sqrt(k);
M_F = [cos(phi)             (1/sqrt(k))*sin(phi)
       -sqrt(k)*sin(phi)    cos(phi)];
M_D = [cosh(phi)             (1/sqrt(k))*sinh(phi)
       sqrt(k)*sinh(phi)    cosh(phi)];
else
  M_D = [1 LEFF; 0 1];
  M_F = [1 LEFF; 0 1];
end% if
M4_F = [M_F OO; OO M_D];

% QS2 full
k = abs(k2);
if(k > 0)
phi = LEFF_QS2*sqrt(k);
M_F = [cos(phi)             (1/sqrt(k))*sin(phi)
       -sqrt(k)*sin(phi)    cos(phi)];
M_D = [cosh(phi)             (1/sqrt(k))*sinh(phi)
       sqrt(k)*sinh(phi)    cosh(phi)];
else
  M_D = [1 LEFF; 0 1];
  M_F = [1 LEFF; 0 1];
end% if
M4_D = [M_D OO; OO M_F];


% B5D36 (as extracted from elegant, i.e. only correct of for nominal E)

M4_DIP = [
   0.999983104334567   0.977899999985955  -0.000000000000003   0.000000000000001
  -0.000034554704370   0.999983104334567  -0.000000000000007  -0.000000000000003
  -0.000000000000003   0.000000000000001   1.000000000000000   0.977894132610565
  -0.000000000000007  -0.000000000000003  -0.000000000000000   1.000000000000000];

%M4_DIP = [eye(2) zeros(2); zeros(2) eye(2)];
%M4_DIP(1,2) = 0.9779;
%M4_DIP(3,4) = 0.9779;


d0 = (z_QS0-LEFF_QS0/2) - z_OB;
d1 = (z_QS1-LEFF_QS1/2) - (z_QS0+LEFF_QS0/2);
d2 = (z_QS2-LEFF_QS2/2) - (z_QS1+LEFF_QS2/2);
d3 = (z_BEND-LEFF_BEND/2) - (z_QS2+LEFF_QS2/2);
d4 = z_IM - (z_BEND+LEFF_BEND/2);

M_o0 = [1 d0; 0 1];
M4_o0 = [M_o0 OO; OO M_o0];

M_01 = [1 d1; 0 1];
M4_01 = [M_01 OO; OO M_01];

M_02 = [1 d2; 0 1];
M4_02 = [M_02 OO; OO M_02];

M_03 = [1 d3; 0 1];
M4_03 = [M_03 OO; OO M_03];

M_04 = [1 d4; 0 1];
M4_04 = [M_04 OO; OO M_04];


% dump line optics

% w/o QS0
%M4 = M4_04*M4_DIP*M4_03*M4_D*M4_02*M4_F*M4_01;
%M4_D_QS0
% w/ QS0
M4 = M4_04*M4_DIP*M4_03*M4_D*M4_02*M4_F*M4_01*M4_D_QS0*M4_o0;

m12 = M4(1,2);
m34 = M4(3,4);

return;
