function [orbit, orbitCov, orbitStd, fpar, fpos, fposstd, mse] = ...
         beamAnalysis_orbitFit(par, r, pos, posStd, varargin)
%ORBITFIT
%  [ORBIT, ORBITCOV, ORBITSTD] = ORBITFIT(PAR, R, POS, POSSTD, OPTS)
%  calculates the orbit vector for transport matrix R and beam positions POS.

% Features:

% Input arguments:
%    PAR: Vector indicating the values of the device that was changed for
%         the measurement
%    R: Matrix [2x2xN] or [2x3xN] containing N transport matrices of a 2-D
%       sub-space of the 6-D electron beam phase space at N locations,
%       optionally with energy term
%    POS: Matrix [NxP] of the beam position at N locations for P orbits
%    POSSTD: Optional standard deviations of POS. They are assumed to
%            be uniform if not provided or empty
%    OPTS: Options stucture with fields (optional):
%          N: Number of points for fit-line, default is 100
%          PAR: Vector indicating the values of the device that was changed
%               for the measurement, used to interpolate positions for the
%               fit curve, default is 1:N measurement

% Output arguments:
%    ORBIT: [2xP] or [3xP] vector of the 2-D (3-D) phase space
%    ORBITCOV: covariance matrix of ORBIT
%    ORBITSTD: Standard deviation of ORBIT
%    FPAR: x-values for fit-line
%    FPOS: Fitted beam sizes
%    FPOSSTD: Standard deviation of FPOS
%    MSE: Mean standard error, chi^2/NDF

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'n',100,'cov',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Parse input parameters.
if nargin < 4, posStd=[];end
if isempty(posStd) || ~all(posStd(:)), posStd=pos*0+1e-6;end

data=pos;dataStd=posStd;
if size(r,2) == 5 && max(max(abs(r([1 3],5,:)))) > 1e-4 %check if energy terms are non-zero
    r=reshape(permute(r([1 3],:,:),[1 3 2]),[],5); %include energy term in fit
elseif size(r,2) == 3 && max(abs(r(1,3,:))) > 1e-4 %check if energy terms are non-zero
    r=reshape(r(1,:),3,[])'; %include energy term in fit
elseif size(r,2) > 3
    r=reshape(permute(r([1 3],1:4,:),[1 3 2]),[],4); %exclude energy term from fit
else
    r=reshape(r(1,1:2,:),2,[])'; %exclude energy term from fit
end
m=r;

%[orbit,orbitCov,orbitStd]=fit_svd(m,data,dataStd);
%[orbit,orbitStd,mse,orbitCov]=lscov(m,data,1./dataStd.^2);
[orbit,orbitStd]=deal(zeros(size(m,2),size(data,2)));
orbitCov=zeros(size(m,2),size(m,2),size(data,2));
mse=zeros(1,size(data,2));
if opts.cov || size(data,2) == 1
    for j=1:size(data,2)
        use=~isnan(data(:,j));mu=m(use,:);
        if sum(use) < 2, continue, end
        [orbit(:,j),orbitStd(:,j),mse(j),orbitCov(:,:,j)]=lscov(mu,data(use,j),1./dataStd(use,j).^2);
        if size(mu,1) == size(mu,2)
            orbitCov(:,:,j)=inv(mu)*diag(dataStd(use,j).^2)*inv(mu)';
        end
        orbitStd(:,j)=sqrt(diag(orbitCov(:,:,j)));
    end
else
    use=all(~isnan(data),2);mu=m(use,:);
    if sum(use) > 1 && size(data,2)
        [orbit,orbitStd,mse]=lscov(mu,data(use,:),1./dataStd(use,1).^2);
        if size(mu,1) == size(mu,2)
            orbitStd=sqrt(inv(mu).^2*dataStd(use,:).^2);
        end
    end
    orbitCov=[];
end
orbitStd=real(orbitStd);

if nargout < 4, return, end

fpar=linspace(min(par),max(par),opts.n);
[upar,ix]=unique(par);
if numel(upar) < 2, fr=repmat(r(ix,:),numel(fpar),1);
else
    fr=interp1(upar,r(ix,:),fpar,'spline');
end
%fm=[fr(:,1) fr(:,3)];
fm=fr;
fpos=fm*orbit;
if isempty(orbitCov)
    for j=1:size(data,2)
        fposstd(:,j)=sqrt(diag(fm*diag(orbitStd(:,j)).^2*fm'));
    end
else
    fposstd=sqrt(diag(fm*orbitCov*fm'));
end
