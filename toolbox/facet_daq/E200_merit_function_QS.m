% Usage :
%     function [m12, m34, M4] = E200_calc_QS(KQS1, KQS2, ds)

%% Changelog :
%% E. Adli, February 26, 2013
%%   First version!
%% E. Adli, November 12, 2013
%%   Updated to use absolute coordinates

function chi2 = E200_merit_function_QS(K)

KQS1 = K(1);
KQS2 = K(2);

% load ds and delta_E_E0
load -mat /tmp/QS_optim.temp

%[m12, m34, M4] = E200_calc_QS_M(KQS1, KQS2, delta_E_E0, d_from_MIP);
[m12, m34, M4] = E200_calc_QS_M_abs(KQS1, KQS2, delta_E_E0, z_OB, z_IM);
chi2 = (m12-m12_req)^2 + (m34-m34_req)^2;

return;
