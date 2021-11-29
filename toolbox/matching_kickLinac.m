function [SIGMA_out, R] = matching_kickLinac(SIG, optics_i, Ein, kick_type, direction)
%
% USAGE:
%    SIGMA_out = matching_kickLinac(SIG,optics_i,Ein,kick_type)
%
%  INPUT:
%       SIG         : 6 x 6 matrix
%       optics_i    : structure for optics
%       Ein         : Energy of particle
%       kick_type   : 1 converging , 0 diverging
%       direction   : 1 downstream , -1 backwards
%

if nargin < 5
    direction = 1;
end

DE = optics_i.ampl;
Phi = optics_i.phase;

f = 2*Ein/(DE*cos(Phi/180*pi));
%f = 2*Ein/(DE*cos(Phi/180*pi))*optics_i.length;
R = eye(6,6);

switch kick_type
    case 0  %  ----- divergerging   (exit)
        R(2,1) = 1/f;
        R(4,3) = 1/f;
    case 1  % ------ converging  (entrance)
        R(2,1) = -1/f;
        R(4,3) = -1/f;
end

switch direction
    case 1  %  ----- downstream
        SIGMA_out = R*SIG*R';
    case -1 %  -----  backwards
        SIGMA_out = inv(R)* SIG * inv(R)';
        R=inv(R);
end
