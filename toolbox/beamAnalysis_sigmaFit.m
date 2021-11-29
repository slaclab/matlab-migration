function [sigma, sigmaCov, sigmaStd, fpar, fsizes, fsizesStd, mse] = ...
         beamAnalysis_sigmaFit(par, r, sizes, sizesStd, varargin)
%SIGMAFIT
%  [SIGMA, SIGMACOV, SIGMASTD, SIGTSTD] = SIGMAFIT(PAR, R, SIZES, SIZESSTD, OPTS)
%  calculates the 2-D sigma matrix for transport matrix R and beam sizes SIZES.

% Features:

% Input arguments:
%    PAR: Vector indicating the values of the device that was changed for
%         the measurement
%    R: Matrix [2x2xN] containing N transport matrices of a 2-D sub-space
%       of the 6-D electron beam phase space
%    SIZES: N measurements of the square root of the [1,1] element of the
%           sigma matrix
%    SIZESSTD: Optional standard deviations of SIZES. They are assumed to
%              be uniform if not provided or empty
%    OPTS: Options stucture with fields (optional):
%          N: Number of points for fit-line

% Output arguments:
%    SIGMA: [3x1] vector of the 3 independent elements of the sigma matrix
%    SIGMACOV: covariance matrix of SIGMA
%    SIGMASTD: Standard deviation of SIGMA
%    FPAR: x-values for fit-line
%    FSIZES: Fitted beam sizes
%    FSIZESSTD: Standard deviation of FSIZES
%    MSE: Mean standard error, chi^2/NDF

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, util_lssvd

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'n',100);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Parse input parameters.
if nargin < 4, sizesStd=[];end

use=~isnan(sizes) & ~isinf(sizes);
data=sizes(use).^2;
if ~isempty(sizesStd), sizesStd=sizesStd(use);end

if isempty(sizesStd) || ~all(sizesStd(:))
    sizesStd=sizes(use)*0+.05*mean(sizes(use));
    if sum(use) > 3, sizesStd=[];end
end
if ~isempty(sizesStd)
    dataStd=2*sizes(use).*sizesStd;
else
    dataStd=[];
end
dataStd(dataStd == 0)=mean(dataStd);

r=reshape(r,4,[])';
m=[r(:,1).^2 2*r(:,1).*r(:,3) r(:,3).^2];m=m(use,:);
sigma=zeros(size(m,2),1);
sigmaCov=zeros(size(m,2));
mse=0;
if sum(use) > 2
    [sigma,sigmaStd,mse,sigmaCov]=lscov(m,data,1./dataStd.^2);
elseif sum(use) > 0
    [sigma,sigmaStd,mse,sigmaCov]=util_lssvd(m,data,1./dataStd.^2);
end

% MSE or Chi^2/NDF is ratio of fit error to beam size error.  Covariance
% matrix is already scaled by MSE to reflect goodness of fit.  Don't scale
% back to simple error propagation via M^-1*Cov_data*M'^-1 if MSE > 0.
%{
if mse ~= 0 && ~isempty(dataStd)
    sigmaCov=sigmaCov/mse;
elseif size(m,1) == size(m,2)
    sigmaCov=inv(m)*diag(dataStd.^2)*inv(m)';
end
%}
if size(m,1) == size(m,2)
    sigmaCov=inv(m)*diag(dataStd.^2)*inv(m)';
end
sigmaStd=sqrt(diag(sigmaCov));

if nargout < 4, return, end

fpar=linspace(min(par),max(par),opts.n);
[upar,ix]=unique(par);
if numel(upar) < 2, fr=repmat(r(ix,:),numel(fpar),1);
else
    fr=interp1(upar,r(ix,:),fpar,'spline');
end
fm=[fr(:,1).^2 2*fr(:,1).*fr(:,3) fr(:,3).^2];
fsizes=sqrt(fm*sigma);
fsizesStd=sqrt(diag(fm*sigmaCov*fm'))./fsizes/2;
