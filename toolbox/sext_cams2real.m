function coord = sext_cams2real(mover, cams, geom)
% COORD = SEXT_CAMS2REAL() calculates the triplet of real space coordinates
% [x y theta] that corresponding to a triplet of cam angles [c1 c2 c3].
% This function is the inverse of sext_real2cams().
%
% Input arguments:
%   MOVER:  1 or 2, corresponding to the mover at sextupole 2165 or 2135
%   CAMS:   Vector [c1 c2 c3] of input cam angles in degrees relative
%       to those cam angles that define the "home" position. These angles
%       are [pi/2, 3pi/4, -pi/4] relative to the x axis.
%   GEOM:   [Optional] Struct returned by sext_init() containing
%       geometric constants of the magnet mover system.
%
% Output arguments:
%   COORD:  Vector [x y theta] in real-space coordinates of the calculated
%       magnet center.  Units are mm for x y, and mrad for theta.  [0 0 0]
%       in these coordinates correspond to the "home" (mid-lift) position.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

if ((nargin < 2) || isempty(geom)), [geom, pvs] = sext_init(); end
n = mover;
g = geom;
imax = 20;  % number of iterations to solve

% input in degrees
c = cos(cams * pi/180);
s = sin(cams * pi/180);

camlift = mean(g.L(n,:));
camrad = mean(g.R(n,:));

% starting values for x y theta
x = 0;
y = g.c(n) - g.b(n);
t = 0;

% iterate to solution
for ix = 1:imax
    t_new = ((y + g.b(n) - g.c(n)) + (camlift * ((t * c(1)) - s(1)))) / (g.S2(n) + x);
    x_new = (t * (g.S1(n) - y)) + ((camlift/sqrt(2)) * ((t * c(2)) - s(2) + (t * c(3)) - s(3)));
    y_new = (sqrt(2) * camrad) - g.S1(n) + (t * x) + ...
        ((camlift/sqrt(2)) * ((t * c(2)) - s(2) - (t * c(3)) + s(3)));
    
    x = x_new; y = y_new; t = t_new;
end

x = x + g.a(n) - (cos(t) * g.a(n)) - (sin(t) * g.b(n));
y = y - g.c(n) + (cos(t) * g.b(n)) - (sin(t) * g.a(n));

coord = [x, y, t * 1e3];  % output in mm, mm, mrad

end