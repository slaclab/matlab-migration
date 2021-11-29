% Usage :
%     function [m12, m34, M4] = E200_calc_QS(KQS1, KQS2, ds)

%% Changelog :
%% E. Adli, February 26, 2013
%%   First version!
%% E. Adli, November 12, 2013
%%   Updated to use absolute coordinates

function chi2 = E200_merit_function_QS0_2par(K)
KQS1 = K(1);
KQS2 = K(2);

% load ds and delta_E_E0
load -mat /tmp/QS_optim.temp

% set QS0 to same fraction as QS1, as for imaging from MIP to ELANEX
KQS0 = KQS1 * QS0_QS1_frac;

%[m12, m34, M4] = E200_calc_QS_M(KQS1, KQS2, delta_E_E0, d_from_MIP);
[m12, m34, M4] = E200_calc_QS0_M_abs(KQS1, KQS2, delta_E_E0, z_OB, z_IM, KQS0);
%chi2 = (m12-m12_req)^2 + (m34-m34_req)^2 + (KQS0^2); % test
%chi2 = (m12-m12_req)^2 + (m34-m34_req)^2 + (KQS0^2 + KQS1^2 + KQS2^2)/100^2;
chi2 = (m12-m12_req)^2 + (m34-m34_req)^2;

return;
