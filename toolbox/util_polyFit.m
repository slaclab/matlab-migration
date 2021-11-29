function [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_polyFit(x, y, pOrd, yStd, xFit)
%POLYFIT
%  POLYFIT(X, Y, PORD, YSTD) fits polynomial of order PORD. The default is
%  0 for fitting a constant.

% Input arguments:
%    X:    x-value
%    Y:    y-value
%    PORD: Order of polynomial
%    YSTD: Standard deviation of y-values

% Output arguments:
%    PAR: fitted parameters
%         Y=PAR(1) X^N ... + PAR(N) X^0
%    FY: fitted function

% Compatibility: Version 7 and higher
% Called functions: marquardt

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 3, pOrd=0;end
if nargin < 4, yStd=[];end
if nargin < 5, xFit=[];end

% Determine starting parameters for non-linear fit.
[x,y,yStd,xFit]=util_fitInit(x,y,yStd,xFit);

m=repmat(x,1,pOrd+1).^repmat(pOrd:-1:0,numel(x),1);
[par,parstd,mse,pcov]=lscov(m,y,1./yStd.^2);

% Get fitted function values.
[parstd,mse,xFit,yFit,yFitStd,pcov,rfe]=util_processFit(@polynom,par,x,y,yStd,xFit);


function [f,J] = polynom(x,fpar)
%POLYNOM Fit function for Levenberg-Marquardt algorithm.
%  Polynomial

xval=fpar(:,1);
yval=fpar(:,2);
f0=polyval(x,xval);
pOrd=numel(x)-1;
J=repmat(xval,1,pOrd+1).^repmat(pOrd:-1:0,numel(xval),1);
f=f0-yval;

yvalstd=yval*0+1;
if size(fpar,2) == 3, yvalstd=fpar(:,3);end
f=f./yvalstd;
J=J./repmat(yvalstd,1,size(J,2));
