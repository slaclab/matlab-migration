function [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_erfFit(x, y, bgord, yStd, xFit)
%ERFFIT
%  ERFFIT(X, Y, BGORD) fits an error function distribution with linear
%  background using Levenberg-Marquardt algorithm. BGORD set the number of
%  parameters for the background polynomial. The default is 0 for no
%  background. BGORD set to 1 uses a constant background. BGORD set to 2
%  uses a linear one.

% Input arguments:
%    X: x-value
%    Y: y-value
%    BGORD: 0: zero offset (default), 1: constant offset, 2: linear offset

% Output arguments:
%    PAR: fitted parameters [AMP, XM, SIG, BG, BGS]
%         Y=AMP/2 ERFC(-(X-XM)/SIG) + BG + X BGS
%         The length of PAR depends on BGORD
%    YFIT: fitted function
%    PARSTD: error of fit parameters
%    YFITSTD: error of fitted function
%    MSE: mean standard error, chi^2/NDF
%    PCOV: covariance matrix
%    RFE: rms fit error

% Compatibility: Version 7 and higher
% Called functions: marquardt, processFit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 3, bgord=0;end
if nargin < 4, yStd=[];end
if nargin < 5, xFit=[];end

[x,y,yStd,xFit]=util_fitInit(x,y,yStd,xFit);

% Determine starting parameters for non-linear fit.
len=length(y);xx=x;y0=y;[x,id]=sort(x);y=y(id);
ind1=1:ceil(len/10);
ind2=max(1,ceil(len-len/10)):len;
xm1=mean(x(ind1));xm2=mean(x(ind2));
ilen1=length(unique(ind1));par1=zeros(1,2);ilen1=min(ilen1,2);
ilen2=length(unique(ind2));par2=zeros(1,2);ilen2=min(ilen2,2);
if ilen1 > 0, par1(1:ilen1)=fliplr(polyfit(x(ind1)-xm1,y(ind1),ilen1-1));end
if ilen2 > 0, par2(1:ilen2)=fliplr(polyfit(x(ind2)-xm2,y(ind2),ilen2-1));end
bg=[min([par1(1) par2(1)]) mean([par1(2) par2(2)])];bg(bgord+1:end)=[];

% Find amplitude.
yy=y(:);
amp=diff(yy([1 end]));
[d,indx]=min((mean(yy([1 end]))-yy).^2);
x0=x(indx);
if isempty(x0), x0=0;end

% Find width from peak value and area.
if isempty(amp) || amp == 0 , amp=1;end
sig=diff(x([1 end]))/3*sign(amp);amp=abs(amp);
if sig == 0 || isnan(sig), sig=1;end

% Initialize fit parameters.
par=[1 x0 sig bg/amp];mar_par=[1 1e-9 1e-9 20];

fcn=@gaussErf;
%par=fminsearch(@(p) sum(fcn(p,[x y/amp]).^2),par);
[par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
par([1 4:end])=par([1 4:end])*amp;par0=par;

% Get fitted function values.
[parstd,mse,xFit,yFit,yFitStd,pcov,rfe]=util_processFit(fcn,par0,xx,y0,yStd,xFit);


function [f,J] = gaussErf(x,fpar)
%GAUSSERF Fit function for Levenberg-Marquardt algorithm.
%  Error function

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
%amp=x(1);
x0=x(2);xx=xval-x0;
sigma=x(3)+1e-20;
f0=amp/2*erfc(-xx/sigma);
ed=-amp/2*exp(-(xx/sigma).^2)*2/sqrt(pi);
J(:,1)=f0/amp;
J(:,2)=ed/sigma;
J(:,3)=ed.*xx/sigma^2;
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

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));
