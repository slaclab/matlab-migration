function [parstd, mse, xFit, yFit, yFitStd, pcov, rfe] = util_processFit(fcn, par, x, y, yStd, xFit)
%PROCESSFIT
%  PROCESSFIT(FCN, PAR, X, Y, YSTD, FX)

% Input arguments:
%    X: x-value

% Output arguments:
%    PAR: fitted parameters [AMP, XM, SIG, BG, BGS]

% Compatibility: Version 2007b, 2012a
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Get chi^2, covariance matrix and fit parameter error.
[fy,J]=feval(fcn,par,[x y yStd]);
mse=fy'*fy/max(length(x)-length(par),1); % Chi^2/NDF, mean standard error
C=J'*J;S=diag(1./sqrt(diag(C)));T=S*C*S;
if ~any(isnan(T(:))) && ~any(isinf(T(:)))
    pcov=S*pinv(T)*S*mse;
elseif ~any(isnan(C(:))) && ~any(isinf(C(:)))
    pcov=pinv(C)*mse;
else
    pcov=inv(C)*mse;
end
parstd=sqrt(diag(pcov));

% Get rms fit error.
fy=feval(fcn,par,[x y]);
rfe=sqrt(fy'*fy/max(length(x),1)); % RMS fit error, sqrt(dy/N)

% Get fit function and error.
if isempty(xFit) && ~isempty(x), xFit=linspace(min(x),max(x),100);end
[yFit,J]=feval(fcn,par,[xFit(:) xFit(:)*0]);
yFit=reshape(yFit,size(xFit));
yFitStd=reshape(sqrt(sum((J*pcov).*J,2)),size(xFit));
