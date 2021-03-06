%load the Fmatrix for FB01:TR01:FMATRIX
coeffF_pv = 'FBCK:FB01:TR01:FMATRIX';
coeffF = [
      1, 0, 0, 0, 0, ...
      0.4, 0, 0, 0, 0, ...
      0.2, 0, 0, 0, 0, ...
      -0.76, 0, 0, 0, 0, ...
      -1.45, 0, 0, 0, 0, ...
      -2.011, 0, 0, 0, 0, ...
      -2.1, 0, 0, 0, 0, ...
      -2.7, 0, 0, 0, 0, ...
      -1.9, 0, 0, 0, 0, ...
      -1.55, 20.1, 0, 0, 0, ...
      0, 0, 1, 9.23, 0, ...
      0, 0, 1.05, 10.132, 0, ...
      0, 0, 1.13, 11.45, 0, ...
      0, 0, 1.78, 20.132, 0, ...
      0, 0, 2.132, 26.68, 0, ...
      0, 0, 2.678, 34.98, 0, ...
      0, 0, 3.019, 37.12, 0, ...
      0, 0, 3.768, 43.465, 0, ...
      0, 0, 4.23, 49.87, 0, ...
      0, 0, 4.64, 62.34, 0, ...
         ];
coeffG_pv = 'FBCK:FB01:TR01:GMATRIX';
coeffG = [
      -36.6018, 1.5953, 0, 0, ...
      -1.7435, -0.43733, 0, 0,...
      0, 0, -47.313, 7.8653,...
      0, 0, 3.1443, -1.7418,...
         ]; 
%install coefficients
lcaPut(coeffF_pv, coeffF);
lcaPut(coeffG_pv, coeffG);
