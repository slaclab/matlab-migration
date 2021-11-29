function [P, L] = zernike(n, m, X)
%ZERNIKE
%  [P, L] = ZERNIKE(N, M, X) calculates the Zernike polynomial coefficients
%  P for mode number [N M] and optionally the polynomial values if X given.

% Features:

% Input arguments:
%    N: n coefficient
%    M: m coefficient
%    X: radial distance (optional)

% Output arguments:
%    P: polynomial coefficients in Matlab order
%    L: Polynomial values at radial locations X

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

P=zeros(1,n+1);m=abs(m);
if ~mod(n-m,2)
    k=0:(n-m)/2;
    P(2*k+1)=(-1).^k.*factorial(n-k)./factorial(k)./factorial((n+m)/2-k)./factorial((n-m)/2-k);
end

if exist('X','var')
	L = polyval(P,X);
end
