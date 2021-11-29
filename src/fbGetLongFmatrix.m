function [fmat, ok] = fbGetLongFmatrix()
%
% the matrix loop.matrix.f takes delta energy and current:
% dDL1E, dBC1E, dBC1I, dBC2E, dBC2I, dDL2E and produces delta 
% amp,phase, energy, and chirp:
% dDL1amp, dBC1amp, dBC1phase, dBC2amp, dBC2phase, dDL2amp 
%
% notice that the response matrix is Omat and the feedback matrix is fmat. jw
%config = getappdata(0,'Config_structure');
ok=1; %return value of 1 means all OK

      
% calculate parameters for L2 phase actuators
params = getappdata(0,'tempParams');
A6 = (params.Ev(5) - params.Ev(4))/cosd(params.phiv(5));

%conversion factor degrees to radians
d2r = pi/180.0; % 
%r2d = 180/pi;

 
% get the response matrix
Omat = fbMatrixElementFull();
m=Omat;

% create orthogonal BC1
t = (m(2,3) - m(2,2)*(m(3,3)/m(3,2)));
f21 = t^(-1);
f11 = (-m(3,3)/m(3,2)) * f21;
t= (m(3,3) - m(3,2)*(m(2,3)/m(2,2)));
f22 = t^(-1);
f12 = (-m(2,3)/m(2,2)) * f22;

% create orthogonal BC2
%t = (m(4,3) - m(4,4)*(m(5,5)/m(5,4)));
t = (m(4,5) - m(4,4)*(m(5,5)/m(5,4)));
g21 = t^(-1);
g11 = (-m(5,5)/m(5,4)) * g21;
t= (m(5,5) - m(5,4)*(m(4,5)/m(4,4)));
g22 = t^(-1);
g12 = (-m(4,5)/m(4,4)) * g22;

% now create 6x6 matrix
m=Omat(1:6,1:6);
m(6,6) = 1.0/A6;
invM = inv(m);

% use BC1 orthogonal
invM(1:3,1:3) = [invM(1,1)       0       0;...
                 invM(2,1)      f11     f12;...
                 invM(3,1)*d2r  f21*d2r f22*d2r];

% use BC2 orthogonal
invM(3:5,3:5) = [invM(3,3)       0       0;...
                 invM(4,3)      g11     g12;...
                 invM(5,3)*d2r  g21*d2r g22*d2r];


fmat = invM;              
end

