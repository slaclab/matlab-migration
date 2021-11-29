function [xstar, ystar, dydxstar, xplot, yplot] = inflectionPoint3(x,y)
%
%  [xstar, ystar, dydxstar, xplot, yplot] = inflectionPoint3(x,y)
%
% Find inflection point and slope using cubic fitting. Also return vectors
% for plots
%
% For K measurement, x is the Flux and y is the Energy.
% xstar/ystar/dxdystar are the x/y/dydx values at the inflection point. 
% xplot and yplot are 100 point arrays of points of the fitted polynomial
% for plotting.

[p,S,mu] = polyfit(x, y, 3);
xnstar = -p(2)/3/p(1); 
ystar= polyval(p,xnstar);
xstar = xnstar * mu(2)+mu(1);
dydxstar = ( 3*p(1)*xnstar^2+2*p(2)*xnstar+p(3) )/mu(2);
%dxdystar = 1/dydxstar;

npts = 100;
dx = (max(x) - min(x))/(npts-1);
xplot = min(x):dx:max(x);
yplot = polyval(p,(xplot-mu(1))/mu(2) );