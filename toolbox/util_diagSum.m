function [y, a] = util_diagSum(a)
%DIAGSUM
%  DIAGSUM(A) calculates the sum of the anti-diagonals in A.

% Features:
% Y(k) =   Sum   A(k-i+1,i)
%        1<=i<=k

% Input arguments:
%    A: 2-d array:

% Output arguments:
%    Y: sum of anti-diagonals
%    A: tilted array

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
[n,m]=size(a);
a(n+1:n+m,:)=0;
a=reshape([a(:);zeros(n-1,1)],[],m+1);
y=sum(a,2);
