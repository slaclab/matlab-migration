function [x, y, yStd, xFit] = util_fitInit(x, y, yStd, xFit)
%FITINIT
%  FITINIT(X, Y, YSTD, FX) inititalzes fitting.

% Input arguments:
%    X:    x-value
%    Y:    y-value
%    YSTD: Standard deviation of y-values, default is []
%    XFIT: x-values to return fit function, default is [] (use x instead)

% Output arguments:
%    X:    x-value
%    Y:    y-value
%    YSTD: Standard deviation of y-values, set to 1 if []
%    XFIT: x-values to return fit function

% Compatibility: Version 7 and higher
% Called functions: marquardt

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Parse input parameters.
if nargin < 3, yStd=[];end
if nargin < 4, xFit=[];end

% Put x and y in standard form and remove NaNs.
if isempty(xFit), xFit=reshape(x,size(y));end
use=~isnan(y(:)) & ~isnan(x(:)) & ~isinf(y(:));
x=reshape(x(use),[],1);
y=reshape(y(use),[],1);
if ~isempty(yStd), yStd=reshape(yStd(use),[],1);end
if isempty(yStd) || ~all(yStd), yStd=ones(size(y));end
