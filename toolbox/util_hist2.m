function [h, x, y] = util_hist2(xi, yi, x, y, dither)
%HIST2
%  HIST2(XI, YI, X, Y, DITHER) calculates the 2-d histogram of the (XI YI)
%  values. The number and location of the x and y bins is set by the
%  vectors X and Y. If X and Y are scalars, they specify the number of
%  bins. The location of the bins is then determined by the data range in
%  XI and YI. The default for X and Y is 100. The flag DITHER applies
%  smoothing by representing each (XI,YI) data point as a Gaussian with
%  sigma of 1 in the output array.

% Input arguments:
%    XI: Column data values
%    YI: Row data values
%    X: Column bin number or locations
%    Y: Row bin bumber or locations
%    DITHER: Flag to smooth the output array

% Output arguments:
%    H: Histogram array
%    X: Column bin locations
%    Y: Row bin locations

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
dims=[];
if nargin < 5, dither=0;end
if nargin < 3, x=100;y=100;end
if length(x) == 1, dims=[x y];end

if any(dims)
    x=[min(xi) max(xi)];
    y=[min(yi) max(yi)];
    if ~diff(x), x=[2-dims(1) dims(1)]/2;end
    if ~diff(y), y=[2-dims(2) dims(2)]/2;end
    x=linspace(x(1),x(2),dims(1));
    y=linspace(y(1),y(2),dims(2));
else dims=[length(x) length(y)];
end

xi=interp1(x,1:dims(1),xi,'nearest',NaN);
yi=interp1(y,1:dims(2),yi,'nearest',NaN);
use=~isnan(xi) & ~isnan(yi);
yi=yi(use);xi=xi(use);yi=yi(:);xi=xi(:);n=1;one=1;
if dither
    one=[.14 .37 .14;.37 1 .37;.14 .37 .14];n=sum(one(:));
    one=kron(one,ones(length(xi),1));
    xi=repmat([xi-1;xi;xi+1],1,3);
    yi=repmat([yi-1 yi yi+1],3,1);
    use=xi > 0 & yi > 0 & xi <= dims(1) & yi <= dims(2);
    xi=xi(use);yi=yi(use);one=one(use);
end

h=accumarray({yi xi},one,dims([2 1]))/n;
