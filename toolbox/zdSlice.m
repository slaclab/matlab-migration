function [zSlice, dSlice] =  zdSlice(z,d, Dz)
%
% [zSlice, dSlice] =  zdSlice(z,d, Dz)
%
% Returns a subset of particle coordinates containing those within +/- Dz standard
% deviations of mean(z). If Dz is omitted 0.5 is assumed.

if nargin == 2
    Dz = 0.5;
end

zbar = mean(z);
sigmaZ = std(z);

zSliceI = z > (zbar - Dz*sigmaZ) & z < (zbar + Dz*sigmaZ);
zSlice = z(zSliceI);
dSlice = d(zSliceI);
