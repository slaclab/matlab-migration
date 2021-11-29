function [cams, valid] = sext_real2cams(mover, coord, geom)
% [CAMS, VALID] = SEXT_REAL2CAMS() calculates a triplet of cam angles that
% correspond to a desired position in real [x y theta] space for the FACET
% sector 20 sextupole movers.
%
% Input arguments:
%   MOVER:  1 or 2, corresponding to the mover at sextupole 2165 or 2135
%   COORD:  Vector [x y theta] in real-space coordinates of the desired
%       magnet center.  Units are mm for x y, and mrad for theta.  [0 0 0]
%       in these coordinates correspond to the "home" (mid-lift) position.
%   GEOM:   [Optional] Struct returned by sext_init() containing
%       geometric constants of the magnet mover system.
%
% Output arguments:
%   CAMS:       Vector [c1 c2 c3] of calculated cam angles (degrees)
%       relative to those cam angles that define the "home" position.
%       These angles are [pi/2, 3pi/4, -pi/4] relative to the x axis.
%   VALID:      Flag (0 or 1) indicating whether the input coordinates are
%       reachable by the cam mover mechanism.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

if (nargin < 3) || isempty(geom), [geom, pvs] = set_init(); end
n = mover;
g = geom;

[x, y, t] = deal(coord(1), coord(2), coord(3));
t = t * 1e-3; % input is in mrad

% eq 1.1 - 1.6 in bowden
% as implemented in ATF2 code
x1 = x + (g.a(n) .* cos(t)) + (g.b(n) .* sin(t)) - g.a(n);
y1 = y - (g.b(n) .* cos(t)) + (g.a(n) .* sin(t)) + g.c(n);
bp = (cos(t) + sin(t))/sqrt(2);
bm = (cos(t) - sin(t))/sqrt(2);

p1 = t - asin((1/g.L(n, 1)) * (((x1 + g.S2(n)) * sin(t))  - (y1 * cos(t))  + (g.c(n) - g.b(n))));
p2 = t - asin((1/g.L(n, 2)) * (((x1 + g.S1(n)) * bm) + (y1 * bp) - g.R(n, 2)));
p3 = t - asin((1/g.L(n, 3)) * (((x1 - g.S1(n)) * bp) - (y1 * bm) + g.R(n, 3)));

cams = [p1, p2, p3] * 180/pi;  % output is in degrees
valid = 1;
if ~isreal(cams), valid = 0; end

end