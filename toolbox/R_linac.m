function R = R_linac(L,Ein,DE,Phi,lambda)
%
% USAGE: 
%   R = R_linac(L,Ein,DE,Phi,lambda)
%
% INPUT:  
%   L       : effective length of accelerator   (m)
%   Ein     : Particle energy at start sector   (MeV)
%   DE      : Energy gain over sector length    (MeV)
%   Phi     : RF phase w.r.t crest              (degrees)
%   lambda  : wavelength accelerating wave      (m)
%
% OUTPUT:
%   R       : Transport matrix following K.Brown "Transport" manual P91
%
%

R = zeros(6,6);
frac = DE/Ein*cosd(Phi);

if DE ~= 0
    R(1,1) = 1;
    R(1,2) = L/frac*log(1+frac);
    R(2,2) = 1/(1+frac);
    R(3,3) = 1;
    R(3,4) = L/frac*log(1+frac);
    R(4,4) = 1/(1+frac);
    R(5,5) = 1;
    R(6,5) = DE/Ein*sind(Phi)/(1+frac)*(2*pi/lambda);
    R(6,6) = 1/(1+frac);
else 
    R = eye(6,6);
end
