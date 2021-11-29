function [ Rbetagamma betagamma1 betagamma2 ] = BrhoScaler( E1_eV, E2_eV)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
mm=9.1095e-31;
cc=2.9979e8;
ee=1.6022e-19;

E1=E1_eV*ee;
E2=E2_eV*ee;
gamma1=1+E1/mm/cc^2;
gamma2=1+E2/mm/cc^2;
betagamma1=sqrt(gamma1^2-1);
betagamma2=sqrt(gamma2^2-1);
Rbetagamma=betagamma2/betagamma1;


end

