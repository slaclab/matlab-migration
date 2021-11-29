E0 = 20.35;
K1_arr = 0;
K2_arr = 0;
n = 0;
QS_setting = 0;
ds_range = -1:0.1:1;
for d_from_MIP = ds_range,
  n = n + 1;
  [isok, BDES1, BDES2, K1, K2, m12, m34, M4] = E200_calc_QS(QS_setting, d_from_MIP+0.28, E0);
  K1_arr(n) = K1;
  K2_arr(n) = K2;
end% if

