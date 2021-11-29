function [par, parCov, parStd, fphase, fdata, fdataStd, mse] = ...
    beamAnalysis_phaseFit(phase, data, dataStd, varargin)
%PHASEFIT
%  [PAR, PARCOV, PARSTD] = PHASEFIT(PHASE, DATA, DATASTD, OPTS) fits a
%  amplitude, phase and offset to a phase scan.

% Features:

% Input arguments:
%    PHASE: Vector of measured phases
%    DATA: Measured BPM positions
%    DATASTD: Optional standard deviations of DATA. They are assumed to
%              be uniform if not provided, empty, or not all non-zero
%    OPTS: Options stucture with fields (optional):
%          N: Number of points for fit-line
%          OFFSET: Flag to fit offset, default is 1

% Output arguments:
%    PAR: [3x1] vector of [amplitude, phase0, offset]
%    PARCOV: covariance matrix of PAR
%    PARSTD: Standard deviation of PAR
%    FPHASE: x-values for fit-line
%    FDATA: Fitted BPM positions
%    FDATASTD: Standard deviation of FDATA
%    MSE: Mean standard error, chi^2/NDF

% Compatibility: Version 2007b, 2012a
% Called functions: parseOptions

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set default options.
optsdef=struct( ...
    'offset',1, ...
    'n',100);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Parse input parameters.
if nargin < 3, dataStd=[];end
data=data(:);dataStd=dataStd(:);
if isempty(dataStd) || ~all(dataStd), dataStd=data*0+.05*mean(data);end

% Phase is in degree.
phase=phase(:);
m=[sind(phase) cosd(phase) ones(size(phase))];
if ~opts.offset, m(:,3)=[];end

use=~isnan(data);
par=zeros(size(m,2),1);
parCov=zeros(size(m,2));
mse=0;
if sum(use) >= size(m,2)
    [par,parStd,mse,parCov]=lscov(m(use,:),data(use),1./dataStd(use).^2);
    % parCov is normalized by mse, and 0 if exact fit with mse = 0.
end
if mse ~= 0 % undo normalization
    parCov=parCov/mse;
elseif size(m,1) == size(m,2) % if exact fit, recalculate parCov
    parCov=inv(m)*diag(dataStd.^2)*inv(m)';
end

if nargout > 3
    fphase=linspace(min(phase),max(phase),opts.n);
    fm=[sind(fphase)' cosd(fphase)' ones(size(fphase))'];
    if ~opts.offset, fm(:,3)=[];end
    fdata=fm*par;
    fdataStd=sqrt(diag(fm*parCov*fm'));
%    dRange=[min(m*par) max(m*par)];use=fdata <= dRange(2) & fdata >= dRange(1);
%    fphase(~use)=NaN;
end

ph0=atan2(par(1),par(2))*180/pi;
amp=sqrt(par(1)^2+par(2)^2);

fm=eye(size(m,2));
fm(1:2,1:2)=[par(1:2)'/amp;[par(2) -par(1)]/amp^2];
par(1:2)=[amp ph0];
parCov=fm*parCov*fm';
parStd=sqrt(diag(parCov));
