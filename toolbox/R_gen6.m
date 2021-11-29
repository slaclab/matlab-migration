function R = R_gen6(L,angle,k1,roll,dum,E1,E2,hgap,FINT,FINTX)

%    R = R_gen6(L, angle, k1, roll, dum, E1, E2, hgap, FINT, FINTX);
%
%    Returns a general 6X6 R matrix (x,x',y,y',dp/p)
%    where:
%
%       L:      is magnetic length (see below for L=0)  [meters]
%       angle:  is bending angle (if any)               [rads]
%       k1:     is quad strength                        [1/meter^2]
%                 (k1>0 gives x focusing
%                  k1<0   "   y    "    )
%       roll:   (Opt,DEF=0) is roll angle around longitudinal axis  [rads]
%               (roll>0: roll is clockwise about positive Z-axis.
%                        i.e. clockwise next element rotation as beam
%                        leaves the observer)
%            ==>(NOTE: if L=0, then R = rotation through "roll" angle)
%       dum:   	Histroical - just put a one here (or any number)
%		E1:		(Opt,DEF=0) Pole-face rotation at bend
%				entrance [rads]
%		E2:		(Opt,DEF=0) Pole-face rotation at bend
%				exit [rads]
%		hgap:	(Opt,DEF=0) Vertical half-gap of bend magnet used for fringe field
%				vertical focusing (uses K1=0.5 - see MAD manual) [m]
%       FINT:   (Opt,DEF=0.5) Field edge integral.
%       FINTX:  (Opt,DEF=FINT) Field edge integral at exit.
%
%    eg.  R_gen6(L,0    ,0 )             gives drift matrix
%         R_gen6(L,angle,0 )             gives pure sector dipole
%         R_gen6(L,angle,0,0,1,angle/2,angle/2)    gives rectangular bend (E1 & E2 pole-face rotations)
%         R_gen6(L,0    ,k1)             gives pure quadrupole
%         R_gen6(L,0    ,k1,pi/4)        gives skew quadrupole
%         R_gen6(L,angle,k1)             gives combo function magnet
%         R_gen6(0,0,0,roll)             gives coord. rotation matrix
%         R_gen6(L,angle,k1,roll)        gives rotated combo func mag (like in SLC ars)

%===============================================================================

if nargin < 4      
  roll = 0;
end
if nargin < 6
  E1 = 0;
end
if nargin < 7
  E2 = 0;
end
if nargin < 8
  hgap = 0;
end
if nargin < 9
  FINT = 0.5;
end
if nargin < 10
  FINTX = FINT;
end
if roll ~=0
  c = cos(-roll);               % -sign gives TRANSPORT convention
  s = sin(-roll);
  O = [ c  0  s  0  0  0
        0  c  0  s  0  0
       -s  0  c  0  0  0
        0 -s  0  c  0  0
        0  0  0  0  1  0
        0  0  0  0  0  1];
else
  O = eye(6,6);
end

if L == 0
  R = O;
  return
end

h = angle/L;
kx2 = (k1+h*h);
ky2 = -k1;

if angle ~= 0
  psi1 = FINT*2*h*hgap*(1+(sin(E1))^2)/cos(E1);
  psi2 = FINTX*2*h*hgap*(1+(sin(E2))^2)/cos(E2);
  Rpr1 = eye(6,6);
  Rpr2 = eye(6,6);
  Rpr1(2,1) = tan(E1)*h;
  Rpr2(2,1) = tan(E2)*h;
  Rpr1(4,3) = -tan(E1-psi1)*h;
  Rpr2(4,3) = -tan(E2-psi2)*h;
end

% horizontal plane first:
% ======================

kx   = sqrt(abs(kx2));
phix = kx*L;
if abs(phix) < 1E-12
  Rx = [1 L
        0 1];

  Dx = zeros(2,2);
  R56 = 0;
else
  if kx2>0
    co = cos(phix);
    si = sin(phix);
    Rx = [     co  si/kx
           -kx*si  co   ];
  else
    co = cosh(phix);
    si = sinh(phix);
    Rx = [     co  si/kx
            kx*si  co  ];
  end
  Dx = [0 h*(1-co)/kx2
        0 h*si/kx ];
  R56 = -(h^2)*(phix-kx*Rx(1,2))/(kx^3);
end


% vertical plane:
% ==============

ky   = sqrt(abs(ky2));
phiy = ky*L;
if abs(phiy) < 1E-12
  Ry = [1 L
        0 1];
else
  if ky2>0
    co = cos(phiy);
    si = sin(phiy);
    Ry = [     co  si/ky ;
           -ky*si  co   ];
  else
    co = cosh(phiy);
    si = sinh(phiy);
    Ry = [     co  si/ky;
            ky*si  co  ];
  end
end

R          = zeros(6,6);
R(1:2,1:2) = Rx;
R(3:4,3:4) = Ry;
R(1:2,5:6) = Dx;
R(5,1)     = -Dx(2,2);
R(5,2)     = -Dx(1,2);
R(5,5)     = 1;
R(5,6)     = R56;
R(6,6)     = 1;

R          = O*R*O';

if angle~=0
  R = Rpr2*R*Rpr1;
end
