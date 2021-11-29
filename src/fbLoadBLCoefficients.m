%coeff1_pv = 'SIOC:SYS0:FB00:BC1_BLEN_COEFF';
coeff1_pv = 'BLEN:LI21:265:IPK_COEFF';
coeff1 = [0, 433.6, -0.5, 0.75, 0, 0, 0, 0, 0, 0];
coeff2_pv = 'BLEN:LI24:886:IPK_COEFF';
coeff2 = [0, 5.4625e3, -0.5, 0.75, 0, 0, 0, 0, 0, 0]; %BL21_B with right-hand filter

%coeff2 = [0, 5.3112e4, -0.5, 0.75, 0, 0, 0, 0, 0, 0]; BL21_A
%coeff2 = [4333.17, 0.00148462, 0.681539, 0.0902008, 0, 0, 0, 0, 0];

%install coefficients
lcaPut(coeff1_pv, coeff1);
lcaPut(coeff2_pv, coeff2);
