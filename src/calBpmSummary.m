function[] = calBpmSummary(bpms, nbpms, bpmparms)
%
%   Print the calibration calculation results to screen.
%

fprintf('Summary of results:\n\n') 
for j=1:nbpms
    if (bpmparms.sel(j)==1 && bpmparms.ur(j)==1 && bpmparms.vr(j)==1)
        fprintf('%s X: scale=%.5f, prev scale=%.5f, new/prev=%.3f, phase=%.1f, prev phase=%.1f\n',bpms{j},bpmparms.uscl(j),bpmparms.uscl_i(j),bpmparms.uscl(j)/bpmparms.uscl_i(j),bpmparms.uphas(j),bpmparms.uphas_i(j));
        fprintf('%s Y: scale=%.5f, prev bpmparms.vscl=%.5f, new/prev=%.3f, phase=%.1f, prev phase=%.1f\n',bpms{j},bpmparms.vscl(j),bpmparms.vscl_i(j),bpmparms.vscl(j)/bpmparms.vscl_i(j),bpmparms.vphas(j),bpmparms.vphas_i(j));
        fprintf('%s coupling: bpmparms.phi = %.1f, prev bpmparms.phi = %.1f, bpmparms.psi = %.1f, prev bpmparms.psi = %.1f\n',bpms{j},bpmparms.phi(j),bpmparms.phi_i(j),bpmparms.psi(j),bpmparms.psi_i(j));
    end
end
