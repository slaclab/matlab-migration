function fbStoreL3BPMCoeffs()
%
% calculate the coefficients for the three BPM estimate of bunch centroid
% energy and write them to the softIOC for later use by longitudinal feedback
%

% BSY first
bpm_PVs = {'BPMS:BSY0:29';'BPMS:BSY0:39';'BPMS:BSY0:52'};
[coeffs(1), coeffs(2)] = fbGetL3BPMCoeffs(bpm_PVs);
coeffPVs = {'SIOC:SYS0:FB00:BSY_COEFF1';'SIOC:SYS0:FB00:BSY_COEFF2'};
coeffs = coeffs';
lcaPut(coeffPVs, coeffs);
      
% LTU
bpm_PVs = {'BPMS:LTU0:180';'BPMS:LTU0:190';'BPMS:LTU1:250'};
[coeffs(1), coeffs(2)] = fbGetL3BPMCoeffs(bpm_PVs);
coeffPVs = {'SIOC:SYS0:FB00:DL2K_COEFF1';'SIOC:SYS0:FB00:DL2K_COEFF2'};
lcaPut(coeffPVs, coeffs);

end