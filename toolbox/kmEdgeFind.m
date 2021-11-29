function [GeVedge, Fedge, dFdGeVedge, GeVplot, Fplot] = kmEdgeFind(Etrim,Ftrim, method)
%
% [GeVedge, Fedge, dFdGeVedge, GeVplot, Fplot] = kmEdgeFind(Etrim,Ftrim, method)
%
% returns effective edge values of x and y, dy/dx , and points arrays for
% plotting using method

if nargin ==2
    method = 'midpoint'; % default
end

switch method
    case 'inflection'
        [Fedge, GeVedge, dFdGeVedge, Fplot, GeVplot] = inflectionPoint3(Ftrim,Etrim);
    case 'midpoint'
        GeVedge = kmGeVMidSlope(Etrim, Ftrim);
        Fedge = 0;
        dFdGeVedge = 0;
        GeVplot = Etrim;
        npts = 100;
        GeVplot = [GeVedge GeVedge];
        Fplot = [min(Ftrim) max(Ftrim)];

    case 'erf'
        [Fplot, q] = erf_fit(Etrim, Ftrim);
        GeVedge = q(3);
        Fedge = q(1) + q(2)*erf( (q(3)-q(3))/q(4) );
        dFdGeVedge = 0;
        GeVplot = Etrim;
end

        