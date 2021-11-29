K1_arr = 0;
K2_arr = 0;
n = 0;
QS_setting = 0;
E0 = 20.35;
ds_range = -1:0.1:1;
% 2013_2 value
z_MIP = 1993.285;
z_ELANEX = 2015.22;
z_CHERFAR = 2016.0398;  
z_CHERNEAR = 2015.9298; 
for d_from_MIP = ds_range,
  n = n + 1;
  [isok, BDESQS1, BDESQS2, KQS1, KQS2, m12, m34, M4] = E200_calc_QS(z_MIP+ds_range(n), z_CHERFAR, QS_setting, 20.35);
  isok_arr(n) = isok;
  KQS1_arr(n) = KQS1;
  KQS2_arr(n) = KQS2;
end% if
disp('All iterations OK, if all the next line is all 1s');
isok_arr
plot(ds_range, KQS1_arr, '-xr');
hold on;
plot(ds_range, -KQS2_arr, '-ob');
hold off;
xlabel('\Delta waist pos [m]');
ylabel('QS K-value [m^-2]');
legend('K_{QS1}', '|K_{QS2}|');
