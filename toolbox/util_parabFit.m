function [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_parabFit(x, y, yStd, xFit)
%PARABFIT
%  PARABFIT(X, Y, YSTD, XFIT) fits gaussian distribution with linear
%  background using Levenberg-Marquardt algorithm. BGORD set the number of
%  parameters for the background polynomial. The default is 0 for no
%  background. BGORD set to 1 uses a constant background. BGORD set to 1
%  uses a linear one. TWOSIDE sets a flag for an asymmetric Gaussian, the
%  default is 0.

% Input arguments:
%    X: x-value
%    Y: y-value
%    BGORD: 0: zero offset (default), 1: constant offset, 2: linear offset
%    TWOSIDE: uses two half Gaussians connected at the peak for asymmetric
%    fit if 1, default is 0 which is symmetric Gaussian.

% Output arguments:
%    PAR: fitted parameters [AMP, XM, SIG, BG, BGS]
%         Y=AMP EXP(-(X-XM)^2/2/SIG^2) + BG + X BGS
%         for TWOSIDE = 1, [AMP, XM, MEAN(SIG), ASYM, BG, BGS],
%         ASYM = (SIG_H-SIG_L)/SUM(SIG)
%         for SUPER = 1, [AMP, XM, SIG, N, BG, BGS],
%         Y=AMP EXP(-ABS((X-XM)/SQRT(2)/SIG)^N) + BG + X BGS
%         RMS^2 = 2 SIG^2 GAMMA(3/N)/GAMMA(1/N)
%         The length of PAR depends on BGORD
%    FY: fitted function
%    INFO: information structure returned from marquardt()

% Compatibility: Version 7 and higher
% Called functions: marquardt

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 3, yStd=[];end
if nargin < 4, xFit=[];end

[x,y,yStd,xFit]=util_fitInit(x,y,yStd,xFit);

% Determine starting parameters for non-linear fit.
par=polyfit(x,y,2);
amp=par(1)+1e-20;
x0=-par(2)/2/amp;
bg=par(3)-amp*x0^2;

% Initialize fit parameters.
par=[1 x0 bg/amp];mar_par=[1 1e-9 1e-9 20];

% Switchyard for different functions
fcn=@parab;
[par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
par([1 3])=par([1 3])*amp;par0=par;

% Get fitted function values.
[parstd,mse,xFit,yFit,yFitStd,pcov,rfe]=util_processFit(fcn,par0,x,y,yStd,xFit);
%plot(x,y,x,bgf,x,x*0+bgf(indx)+amp,[x0 x0],bgf(indx)+[0 amp],x,fy);


function [f,J] = parab(x,fpar)
%GAUSSEXP Fit function for Levenberg-Marquardt algorithm.
%  Gaussian

xval=fpar(:,1);
yval=fpar(:,2);
amp=x(1);
x0=x(2);xx=xval-x0;
f0=amp*xx.^2;
J(:,1)=xx.^2;
J(:,2)=-2*amp*xx;

bg=x(3);
J(:,3)=xval*0+1;
f=f0-yval+bg;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));
