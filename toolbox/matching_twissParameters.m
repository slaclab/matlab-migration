function twiss = matching_twissParameters(SIGMA, Ek)
%
%  USAGE : twiss = matching_twissParameters(SIGMA,Ek)
%
%  INPUT :
%      SIGMA : vector of the 21 elements (upper triangle of 2nd order
%      moments )
%      Ek    : Kinetic Energy 
%
%  OUTPUT : 
%        twiss = twiss = [exn bx ax  eyn by ay ex ey sx sy ]
%

gama = 1+Ek/0.511; 

sig11 = SIGMA(1,:);
sig21 = SIGMA(2,:); 
sig22 = SIGMA(3,:);
sig33 = SIGMA(6,:);
sig43 = SIGMA(9,:);
sig44 = SIGMA(10,:);

%
ex = sqrt(sig11.*sig22-sig21.^2);
ey = sqrt(sig33.*sig44-sig43.^2);
exn = ex.*gama;
eyn = ey.*gama; 

bx = sig11./ex;
by = sig33./ey;

ax = -sig21./ex;
ay = -sig43./ey;

sx = sqrt(sig11);
sy = sqrt(sig33);

twiss = [exn;bx;ax;eyn;by;ay;ex;ey;sx;sy];
