function [ivb]=magpolydb(polyPVname)
%
% MAGPOLYDB returns the polynomial coefficients which map the
% current to field of the given electromagent device in the LCLS.
% These are retrieved from the MAGNET_POLYS database.
%
% INPUT ARG polyPVName is :POLY PV, eg QUAD:LTUH:880:POLY
% 
% Output is a fixed length 9 element array, of the the (1st 9) coeffs,
% including those 0 valued, lowest power first.
%   
try
    ivb_s=nttable2struct(erpc(nturi(polyPVname)));
    ivb = [ivb_s.value.coeff_0_val ...
           ivb_s.value.coeff_1_val ivb_s.value.coeff_2_val ...
           ivb_s.value.coeff_3_val ivb_s.value.coeff_4_val ...
           ivb_s.value.coeff_5_val ivb_s.value.coeff_6_val ...
           ivb_s.value.coeff_7_val ivb_s.value.coeff_8_val ];
catch ex
    sprintf(['Eror occurred getting polynomials with PV %s. Check ' ...
             'PV spelling, then magpolys server status'],polyPVname);
end




