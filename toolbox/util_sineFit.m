function [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_sineFit(x, y, bgord, yStd, xFit)
%SINEFIT
%  SINEFIT(X, Y, BGORD, YSTD, XFIT) fits gaussian distribution with linear
%  background using Levenberg-Marquardt algorithm. BGORD set the number of
%  parameters for the background polynomial. The default is 0 for no
%  background. BGORD set to 1 uses a constant background. BGORD set to 1
%  uses a linear one. TWOSIDE sets a flag for an asymmetric Gaussian, the
%  default is 0.

% Input arguments:
%    X: x-value
%    Y: y-value
%    BGORD: 0: zero offset (default), 1: constant offset, 2: linear offset

% Output arguments:
%    PAR: fitted parameters [AMP, XM, SIG, BG, BGS]
%         Y=AMP EXP(-(X-XM)^2/2/SIG^2) + BG + X BGS
%         The length of PAR depends on BGORD
%    FY: fitted function
%    INFO: information structure returned from marquardt()

% Compatibility: Version 7 and higher
% Called functions: marquardt

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 3, bgord=0;end
if nargin < 4, yStd=[];end
if nargin < 5, xFit=[];end

[x,y,yStd,xFit]=util_fitInit(x,y,yStd,xFit);

% Determine starting parameters for non-linear fit.
len=length(y);
par=polyfit(x,y,1);bgf=par(1);

% Find peak value and peak position.
[xs,ix]=sort(x);ys=y(ix);
%dx=mean(diff(xs));
ffty=fft(ys-polyval([par(1) 0],x));
ym=real(ffty(1))/len;
ffty(1)=0;
[amp,ix]=max(abs(ffty));
xL=max(x)-min(x);
f=2*pi/xL*(ix-1);
amp=amp/len*2;
ph=-angle(ffty(ix))/f;

bg=ym;
if bgord < 1, bg=[];end
if bgord < 2, bgf=[];end

% Initialize fit parameters.
par=[1 ph f bg/amp bgf/amp];mar_par=[1 1e-9 1e-9 20];

% Switchyard for different functions
fcn=@sine;
par=util_marquardt(fcn,[x y/amp],par,mar_par);
par([1 4:end])=par([1 4:end])*amp;par0=par;

% Get fitted function values.
[parstd,mse,xFit,yFit,yFitStd,pcov,rfe]=util_processFit(fcn,par0,x,y,yStd,xFit);
%plot(x,y,x,bgf,x,x*0+bgf(indx)+amp,[x0 x0],bgf(indx)+[0 amp],x,fy);


function [f,J] = sine(x,fpar)
%SINE Fit function for Levenberg-Marquardt algorithm.
%  Sine

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
x0=x(2);xx=xval-x0;
sigma=x(3)+1e-20;
f0=amp*sin(xx*sigma);
J(:,1)=f0/amp;
J(:,2)=amp*cos(xx*sigma)*(-sigma);
J(:,3)=amp*cos(xx*sigma).*xx;
if max(size(x)) > 3
   bg=x(4);
   J(:,4)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 4
   bgs=x(5);
   J(:,5)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;
