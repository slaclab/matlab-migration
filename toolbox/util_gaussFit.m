function [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_gaussFit(x, y, bgord, style, yStd, xFit)
%GAUSSFIT
%  GAUSSFIT(X, Y, BGORD, STYLE) fits Gaussian distribution with linear
%  background using Levenberg-Marquardt algorithm. BGORD set the number of
%  parameters for the background polynomial. The default is 0 for no
%  background. BGORD set to 1 uses a constant background. BGORD set to 2
%  uses a linear one. TWOSIDE sets a flag for an asymmetric Gaussian, the
%  default is 0.
%
% Input arguments:
%    X: x-value
%    Y: y-value
%    BGORD: 0: zero offset (default), 1: constant offset, 2: linear offset
%    STYLE: 0: Gaussian (default), 1: Asymmetric Gaussian, 2: Supergaussian, 
%           3: Asymmetric supergaussian, 4: 4th order Gaussian
%
% Output arguments:
%    PAR: fitted parameters [AMP, XM, SIG, BG, BGS]
%         Y=AMP EXP(-(X-XM)^2/2/SIG^2) + BG + X BGS
%         for TWOSIDE = 1, [AMP, XM, MEAN(SIG), ASYM, BG, BGS],
%         ASYM = (SIG_H-SIG_L)/SUM(SIG)
%         for SUPER = 1, [AMP, XM, SIG, N, BG, BGS],
%         Y=AMP EXP(-ABS((X-XM)/SQRT(2)/SIG)^N) + BG + X BGS
%         RMS^2 = 2 SIG^2 GAMMA(3/N)/GAMMA(1/N)
%         The length of PAR depends on BGORD
%    YFIT: fitted function
%    PARSTD: error of fit parameters
%    YFITSTD: error of fitted function
%    MSE: mean standard error, chi^2/NDF
%    PCOV: covariance matrix
%    RFE: rms fit error

% Compatibility: Version 7 and higher
% Called functions: util_marquardt, util_processFit
% Author: Henrik Loos, SLAC
%         Greg White, SLAC, 14-AUG-17. Init bg to 0 in case no
%         data points left after fitinit, which may be caused by 
%         all NaN or Inf. 
%         Greg White, SLAC, 17-JUL-17. Fixed background fit and
%         removal, and hence properly seeding fit params.
% --------------------------------------------------------------------

%% Parse input parameters.
if nargin < 3, bgord=0;end
if nargin < 4, style=0;end
if nargin < 5, yStd=[];end
if nargin < 6, xFit=[];end

% Kludge for peaks removal.
if ischar(style), style=str2double(style);useMed=1;else useMed=0;end

%% Determine starting parameters for non-linear fit.
%
[x,y,yStd,xFit]=util_fitInit(x,y,yStd,xFit);
xm=mean(x);
len=length(y);
ind=[1:ceil(len/10) max(1,ceil(len-len/10)):len];
ilen=length(unique(ind));
par=[];
bg=0;

% Evaluate background fit function.
%
% In principle use a polyfit to find a line expressing the background.
% Mod: Greg, 14-Jul-17: Replaced Henrik's original compact algorithm
% since often gets the wrong answer - manifested as a misplaced
% baseline.  Replaced with case expansion which is longer but clearer
% and gets right answers I think. Formerly, bg was sometimes
% computed as Empty matrix (wrong), rather than 0 (right). 
% Thre cases of background order == 0 (no background) order =1 (flat), or
% order = 2 (linear sloping). 
if ilen > 0
%   par=polyfit(x(ind)-xm,y(ind),min(ilen-1,1));end
%   bg=par(end:-1:end-min(ilen,bgord)+1);bgf=polyval(fliplr(bg),x-xm); 
    switch bgord
        case 0 % No background
            bg=0;
        case 1 % Offset (flat) background, so degree 0 poly
           par=polyfit(x(ind)-xm,y(ind),0); 
           bg=par(1);
        case 2 % Linear (sloping) background, so degree 1 poly
           par=polyfit(x(ind)-xm,y(ind),1);
           bg=par(end:-1:1);
    end
end
bgf=polyval(fliplr(bg),x-xm);
    
% Find peak value and peak position.
yy=y(:);if useMed, yy=util_medfilt2(yy,[5,1]);end
[amp,indx]=max(yy);amp=amp-bgf(indx);x0=x(indx);
if isempty(x0), x0=0;end

% Find width from peak value and area.
y1=y-bgf;y1(y1 < amp/3)=0;
if isempty(amp) || amp == 0 , amp=1;end
sig=abs(sum(y1)*mean(diff(x))/amp/sqrt(2*pi));
if sig == 0 || isnan(sig), sig=1;end

% .. and hence initialize fit parameters.
par=[1 x0 sig bg/amp];mar_par=[1 1e-9 1e-9 20];


%% Switchyard for different fitting functions
%
switch style
    case 0
        fcn=@gaussExp;
%        par=fminsearch(@(p) sum(fcn(p,[x y/amp]).^2),par);
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 4:end])=par([1 4:end])*amp;par0=par;
    case 1
%        fcn=@gauss2side;par=par([1:3 3 4:end]);
        fcn=@gaussAsym;par=par([1:3 3 4:end]);par(4)=0;
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 5:end])=par([1 5:end])*amp;par0=par;
%        asym=(par(4)-par(3))/(par(4)+par(3));
%        par(3)=mean(par(3:4));par(4)=asym;
    case 2
        fcn=@gaussSup;par=[par(1:3) 2 par(4:end)];
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 5:end])=par([1 5:end])*amp;par0=par;
    case 3
        fcn=@gaussSupAsym;par=par([1:3 3 2 4:end]);par(4)=0;
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 6:end])=par([1 6:end])*amp;par0=par;
    case 4
        fcn=@gauss4th2;
%        par=[par(1:3) 0 par(3:end)];
        l4=1/4/par(3)^4;
        par=[par(1) par(2) l4 par(2) 0 par(4:end)];
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 6:end])=par([1 6:end])*amp;par0=par;
        par(3)=(1/4/par(3))^(1/4);
        par(5)=(1/2/par(5))^(1/4);
    case 5
        fcn=@gauss4th;
%        par=[par(1:3) 0 par(3:end)];
        l4=1/4/par(3)^4;
        par=[par(1) par(2) l4 par(2) 0 par(4:end)];
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 6:end])=par([1 6:end])*amp;par0=par;
%        par(3)=(1/4/par(3))^(1/4);
%        par(5)=(1/2/par(5))^(1/4);
    case 6
        use=y/amp > 1/6;xFit=xFit-mean(x(use));x=x-mean(x(use));
        pl=polyfit(x(use),log(y(use)/amp),6);
        fcn=@gauss6th;n=6;
        if pl(1) > 0
            pl=polyfit(x(use),log(y(use)/amp),4);
            fcn=@gauss4th4;n=4;
        end
        par=[exp(pl(end)) pl(1:end-1) bg/amp];
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 n+2:end])=par([1 n+2:end])*amp;par0=par;
    case 7
        use=y/amp > 1/4;xFit=xFit-mean(x(use));x=x-mean(x(use));
        pl=polyfit(x(use),log(y(use)/amp),4);
        par=[exp(pl(5)) pl(1:end-1) bg/amp];
        fcn=@gauss4th4;
        [par,info]=util_marquardt(fcn,[x y/amp],par,mar_par);
        par([1 6:end])=par([1 6:end])*amp;par0=par;
%        par(3)=(1/4/par(3))^(1/4);
%        par(5)=(1/2/par(5))^(1/4);
end

% Get fitted function values.
[parstd,mse,xFit,yFit,yFitStd,pcov,rfe]=util_processFit(fcn,par0,x,y,yStd,xFit);


function [f,J] = gaussExp(x,fpar)
%GAUSSEXP Fit function for Levenberg-Marquardt algorithm.
%  Gaussian

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
x0=x(2);xx=xval-x0;
sigma=x(3)+1e-20;
f0=amp*exp(-(xx/sigma).^2/2);
J(:,1)=f0/amp;
J(:,2)=f0.*xx/sigma^2;
J(:,3)=f0.*xx.^2/sigma^3;
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


function [f,J] = gauss2side(x,fpar)
%GAUSS2SIDE Fit function for Levenberg-Marquardt algorithm.
%  Asymmetric Gaussian

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
x0=x(2);xx=xval-x0;
xl=1*(xval < x0);
xr=1*(xval >= x0);
sigmal=x(3)+1e-20;
sigmar=x(4)+1e-20;
fl=amp*xl.*exp(-(xx/sigmal).^2/2);
fr=amp*xr.*exp(-(xx/sigmar).^2/2);
f0=fl+fr;
J(:,1)=f0/amp;
J(:,2)=fl.*xx/sigmal^2+fr.*xx/sigmar^2;
J(:,3)=fl.*xx.^2/sigmal^3;
J(:,4)=fr.*xx.^2/sigmar^3;
if max(size(x)) > 4
   bg=x(5);
   J(:,5)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 5
   bgs=x(6);
   J(:,6)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gaussAsym(x,fpar)
%GAUSSASYM Fit function for Levenberg-Marquardt algorithm.
%  Asymmetric Gaussian

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
x0=x(2);xx=xval-x0;
sigma=x(3)+1e-20;
E=sign(x(4))*min(1-1e-10,abs(x(4)));
as=1+sign(xx)*E;
f0=amp*exp(-(xx/sigma./as).^2/2);
J(:,1)=f0/amp;
J(:,2)=f0.*xx/sigma^2./as.^2;
J(:,3)=f0.*xx.^2/sigma^3./as.^2;
J(:,4)=f0.*xx.^2/sigma^2./as.^3.*sign(xx);
if max(size(x)) > 4
   bg=x(5);
   J(:,5)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 5
   bgs=x(6);
   J(:,6)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gaussSup(x,fpar)
%GAUSSSUP Fit function for Levenberg-Marquardt algorithm.
%  Super-Gaussian

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));n=x(4);
x0=x(2);xx=xval-x0;
sigma=x(3)+1e-20;
z=abs(xx/sqrt(2)/sigma);
f0=amp*exp(-z.^n);
use=z ~= 0;
logz=z*0;logz(use)=log(z(use));
invx=z*0;invx(use)=1./xx(use);
J(:,1)=f0/amp;
J(:,2)=f0.*z.^n*n.*invx;
J(:,3)=f0.*z.^n*n./sigma;
J(:,4)=f0.*z.^n*(-1).*logz;
if max(size(x)) > 4
   bg=x(5);
   J(:,5)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 5
   bgs=x(6);
   J(:,6)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gaussSupAsym(x,fpar)
%GAUSSSUP Fit function for Levenberg-Marquardt algorithm.
%  Super-Gaussian

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));n=x(5);
x0=x(2);xx=xval-x0;
sigma=x(3)+1e-20;
E=sign(x(4))*min(1-1e-10,abs(x(4)));
as=1+sign(xx)*E;
z=abs(xx/sqrt(2)/sigma./as);
f0=amp*exp(-z.^n);

use=z ~= 0;
logz=z*0;logz(use)=log(z(use));
invx=z*0;invx(use)=1./xx(use);
J(:,1)=f0/amp;
J(:,2)=f0.*z.^n*n.*invx;
J(:,3)=f0.*z.^n*n./sigma;
J(:,4)=f0.*z.^n*n./as.*sign(xx);
J(:,5)=f0.*z.^n*(-1).*logz;
if max(size(x)) > 5
   bg=x(6);
   J(:,6)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 6
   bgs=x(7);
   J(:,7)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gauss4th(x,fpar)
%GAUSS4TH Fit function for Levenberg-Marquardt algorithm.
%  Gaussian with 4th order polynomial

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));x0=x(2);l4=x(3);x3=x(4);l2=x(5);
xx=xval-x0;dx=x3-x0;
f0=amp*exp(-l4*xx.^4-l2*(xx-dx).^2);
J(:,1)= f0/amp;
J(:,2)= f0.*(l4*4.*xx.^3+l2*2*(xx-dx));
J(:,3)=-f0.*xx.^4;
J(:,4)= f0.*l2*2.*(xx-dx);
J(:,5)=-f0.*(xx-dx).^2;
if max(size(x)) > 5
   bg=x(6);
   J(:,6)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 6
   bgs=x(7);
   J(:,7)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gauss4th2(x,fpar)
%GAUSS4TH Fit function for Levenberg-Marquardt algorithm.
%  Gaussian with 4th order polynomial

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));x0=x(2);l4=x(3);x3=x(4);l2=(x(5));
xx=xval-x0;dx=x3-x0;
f0=amp*exp(-l4*xx.^2.*((xx-dx).^2+l2));
J(:,1)= f0/amp;
J(:,2)= f0*2.*l4.*xx.*((xx-dx).^2+l2);
J(:,3)=-f0.*xx.^2.*((xx-dx).^2+l2);
J(:,4)= f0*2.*l4.*xx.^2.*(xx-dx);
J(:,5)=-f0.*l4.*xx.^2;
if max(size(x)) > 5
   bg=x(6);
   J(:,6)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 6
   bgs=x(7);
   J(:,7)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gauss4th4(x,fpar)
%GAUSS4TH Fit function for Levenberg-Marquardt algorithm.
%  Gaussian with 4th order polynomial

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
xx=xval;
f0=amp*exp(x(2)*xx.^4+x(3)*xx.^3+x(4)*xx.^2+x(5)*xx);
J(:,1)= f0/amp;
J(:,2)= f0.*xx.^4;
J(:,3)= f0.*xx.^3;
J(:,4)= f0.*xx.^2;
J(:,5)= f0.*xx;
if max(size(x)) > 5
   bg=x(6);
   J(:,6)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 6
   bgs=x(7);
   J(:,7)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

%plot(xval,yval,xval,f+yval);input('');

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));


function [f,J] = gauss6th(x,fpar)
%GAUSS6TH Fit function for Levenberg-Marquardt algorithm.
%  Gaussian with 6th order polynomial

xval=fpar(:,1);
yval=fpar(:,2);
amp=abs(x(1));
xx=xval;
f0=amp*exp((((((x(2)*xx+x(3)).*xx+x(4)).*xx+x(5)).*xx+x(6)).*xx+x(7)).*xx);
J(:,1)= f0/amp;
J(:,2)= f0.*xx.^6;
J(:,3)= f0.*xx.^5;
J(:,4)= f0.*xx.^4;
J(:,5)= f0.*xx.^3;
J(:,6)= f0.*xx.^2;
J(:,7)= f0.*xx.^1;
if max(size(x)) > 7
   bg=x(8);
   J(:,8)=xval*0+1;
else
   bg=0;
end
if max(size(x)) > 8
   bgs=x(9);
   J(:,9)=xval;
else
   bgs=0;
end
f=f0-yval+bg+xval*bgs;

%plot(xval,yval,xval,f+yval);input('');

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));
