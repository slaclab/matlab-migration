function lvdt = sext_real2lvdt(mover, coord, geom)
% COORD = SEXT_REAL2LVDT() calculates the triplet of LVDT positions [l1 l2
% l3] corresponding to a triplet of real space coordinates [x y theta].
% This function is the inverse of sext_lvdt2real().
%
% Input arguments:
%   COORD:  Vector [x y theta] in real-space coordinates of the desired
%       magnet center.  Units are mm for x y, and mrad for theta.  [0 0 0]
%       in these coordinates correspond to the "home" (mid-lift) position.
%   MOVER:  1 or 2, corresponding to the mover at sextupole 2165 or 2135
%   GEOM:   [Optional] Struct returned by sext_init() containing
%       geometric constants of the magnet mover system.
%
% Output arguments:
%   LVDT:   Vector [l1 l2 l3] of input LVDT readbacks, in mm.  LVDT = [0 0 0] when
%       the mover-magnet system is at home (mid-lift) position.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

if (nargin < 3 || isempty(geom)), [geom, pvs] = sext_init(); end
g = geom;
n = mover;

[x, y, t] = deal(coord(1), coord(2), coord(3));
t = t * 1e-3;  % input is in mrad

l1 = y + ((tan(t) * (g.dx(n, 1) + g.dx(n, 2))) / 2);

l2 = y - ((tan(t) * (g.dx(n, 1) + g.dx(n, 2))) / 2);

l3 = x + (tan(t) * (y + g.dy(n)));

lvdt = [l1, l2, l3];  % output is in mm

end


