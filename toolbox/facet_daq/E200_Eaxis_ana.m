% Usage :
%     function bunch_sep = E200_tcav_analysis(mydata, prof_name, MYIDs, tcav_calib, visu);

%% Changelog :
%% E. Adli, May 13, 2014
%%   First version!

%
% Analytical calculation of Dispersion (as used in profmon GUI)
%
% p = E200_Eaxis_ana(1:2159, 2160-915, 24.88e-6,  2015.9298);
function p = E200_Eaxis_ana(yrange, y0, res, z_prof, theta0, p0)

if nargin < 5,
  theta0 = 5.73e-3; % 5.73 mrad bend angle is the calibrated value for B5D36 = 20.35 GeV in 2014 (Poositron Nature Paper).
end; %if

if nargin < 6,
  p0 = 20.35;
end; %if

z_B5D36 = 2005.65085; % middle of magnet
L = z_prof - z_B5D36;
D0 = theta0 * L;

p = p0 ./ (1-(yrange-y0)*res/D0);

%plot(y, p, 'r')

