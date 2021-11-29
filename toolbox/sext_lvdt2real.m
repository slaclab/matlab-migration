function coord = sext_lvdt2real(mover, lvdt, geom)
% COORD = SEXT_LVDT2REAL() calculates the triplet of real space coordinates
% [x y theta] that corresponding to a triplet of LVDT positions [l1 l2 l3].
% This function is the inverse of sext_real2lvdt().
%
% Input arguments:
%   MOVER:  1 or 2, corresponding to the mover at sextupole 2165 or 2135
%   LVDT:   Vector [l1 l2 l3] of input LVDT readbacks, in mm.  LVDT = [0 0 0] when
%       the mover-magnet system is at home (mid-lift) position.
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

if (nargin < 3 || isempty(geom)), [geom, pvs] = sext_init(); end
g = geom;
n = mover;

y = (lvdt(1) + lvdt(2)) / 2;

t = atan((lvdt(1) - lvdt(2)) / (g.dx(n, 1) + g.dx(n, 2)));

x = lvdt(3) - (tan(t) * (y + g.dy(n)));

coord = [x, y, t * 1e3];  % output is in mrad

end


