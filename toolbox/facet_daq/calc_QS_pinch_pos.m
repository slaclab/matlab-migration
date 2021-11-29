%% Example script for E200 experiment spectrometer functions
%%
%% Changelog :
%% E. Adli, February 26, 2013
%%   First version!
%% E. Adli, November 12, 2013
%%   Updated to use absolute coordinates
%% E. Adli, April 7, 2015
%%   Updated for QS0
QS_setting = +0;
E0 = 20.35;

% 2015 values
z_MIP = 1993.21; % = CUBE1
z_CUBE2 = 1993.71;
z_CUBE3 = 1994.21;
z_CUBE4 = 1994.71;
z_CUBE5 = 1995.09; 
z_PEXT = 1995.67; 
z_ELANEX = 2015.22;
z_CHERFAR = 2016.0398;  
z_CHERNEAR = 2015.9298; 
%
%
%
z_OB = z_MIP;
z_IM = z_ELANEX;

% use this function to calculate the imaging condition from an experiment (before
% spectrometer quads and diplole) to a position on the dump table
% (after spectrometer quads and dipole)
[isok, BDESQS0, BDESQS1, BDESQS2, KQS0, KQS1, KQS2, m12, m34, M4] = E200_calc_QS0_pos_energy_2015(z_OB, z_IM, QS_setting, E0);
%[isok, BDESQS1, BDESQS2,KQS1, KQS2, m12, m34, M4] = E200_calc_QS(z_OB, z_IM, QS_setting, E0);

if(0)

%
% E scan
%
n = 0;
dE_range = -3:0.01:3;
for dE = dE_range,
  n = n + 1;
  [m12(n), m34(n)] =  E200_calc_QS0_M_abs(KQS1, KQS2, dE / E0, z_OB, z_IM, KQS0);
end% if
hh = plot(dE_range+E0, m34, '-x');
set(hh, 'MarkerSize', 15);

%
% Z scan
%
n = 0;
dE = 0;
dZ_range = 0:0.01:3;
for dZ = dZ_range,
  n = n + 1;
  [m12(n), m34(n)] =  E200_calc_QS0_M_abs(KQS1, KQS2, dE / E0, z_OB+dZ, z_IM, KQS0);
end% for
hh = plot(dZ_range+z_OB, m12, '-x');
set(hh, 'MarkerSize', 15);
xlabel('z_{Objectplane} [m]');
ylabel('R_{12} [m/rad]');

end% if

% Z scan - finding imaging energy per Z
%
n = 0;
dE = 0;
dZ_range = 0:0.1:3;
%dZ_range = 0:1;
for dZ = dZ_range,
  n = n + 1;
  [m12(n), m34(n)] =  E200_calc_QS0_M_abs(KQS1, KQS2, dE / E0, z_OB+dZ, z_IM, KQS0);
  dE_range = -5:0.1:5;
  m = 0;
  abs_m12_min = 1e9;
  for dE = dE_range,
    m = m + 1;
    [m12(m), m34(m)] =  E200_calc_QS0_M_abs(KQS1, KQS2, dE / E0, z_OB+dZ, z_IM, KQS0);
    if( abs(m12(m)) < abs_m12_min );
      abs_m12_min = abs(m12(m));
      m_min(n) = m;
    end% if
  end% for
end% for
hh = plot(dZ_range+z_OB, dE_range(m_min), '-x');
set(hh, 'MarkerSize', 15);
xlabel('z_{Objectplane} [m]');
ylabel('X-imaging energy, relative to QS setting [GeV]');
grid on;

