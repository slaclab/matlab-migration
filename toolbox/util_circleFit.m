function [par, info] = util_circleFit(x, y, isEllipse)
%CIRCLEFIT
%  CIRLEFIT(X, Y, ISELLIPSE) fits a circle or ellipse using
%  Levenberg-Marquardt algorithm. If ISELLIPSE is set it fits an ellipse.
%  The default is to fit a circle.

% Input arguments:
%    X: x-value
%    Y: y-value
%    ISELLIPSE: 0: fit circle (default), 1: fit ellipse

% Output arguments:
%    PAR: fitted parameters [X0, Y0, A, [B]]
%         1=(X-X0)^2/A^2+(Y-Y0)^2/B^2
%         The length of PAR depends on ISELLIPSE
%    INFO: information structure returned from marquardt()

% Compatibility: Version 7 and higher
% Called functions: marquardt

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 3, isEllipse=0;end

% Determine starting parameters for non-linear fit.
x=x(:);
y=y(:);
x0=mean(x);
y0=mean(y);
a=mean(sqrt((x-x0).^2+(y-y0).^2));

% Initialize fit parameters.
par=[x0 y0 a];mar_par=[1 1e-9 1e-9 20];

% Switchyard for different functions
if isEllipse
    par=[par a];
end
fcn=@ellipse;
[par,info]=util_marquardt(fcn,[x y],par,mar_par);


function [f,J] = ellipse(x,fpar)
%Ellipse Fit function for Levenberg-Marquardt algorithm.
%  Ellipse

xval=fpar(:,1);
yval=fpar(:,2);
x0=x(1);
y0=x(2);
a=x(3);
if length(x) > 3
    b=x(4);
else
    b=a;
end
xf=(xval-x0)/a;
yf=(yval-y0)/b;
f=xf.^2+yf.^2-1;
J(:,1)=-2*xf/a;
J(:,2)=-2*yf/b;
J(:,3)=-2*xf.^2/a;
if length(x) > 3
    J(:,4)=-2*yf.^2/b;
end
