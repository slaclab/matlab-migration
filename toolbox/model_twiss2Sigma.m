function [sig, sigStd, sigCov] = model_twiss2Sigma(twiss, energy)
%MODEL_TWISS2SIGMA
%  [SIG, SIGSTD, SIGCOV] = MODEL_TWISS2SIGMA(TWISS, ENERGY) computes the
%  uncoupled sigma matrix SIG from Twiss parameters TWISS.  If ENERGY is
%  not given, the emittance in TWISS(1,:) is assumed to be geometric.
%  TWISS must have [epsilon; beta; alpha] as the first 3 row elements and
%  arbitrary further dimensions.  SIG is returned with same size.

% Features:

% Input arguments:
%    TWISS:  Twiss parameters, [3+ x N]
%    ENERGY: Energy in GeV (optional), scalar or N elements array

% Output arguments:
%    SIG:    Final Twiss parameters, [2|3 x 1|2 x 1|N]
%    SIGSTD: Std of SIG, not supported yet
%    SIGCOV: Covariance matrix of SIG, not supported yet

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

e0=0.511e-3; % Energy in GeV
if nargin < 2, energy=[];end
if isempty(energy), energy=e0;end
gam=energy(:)'/e0;
sig=twiss*0;sig(4:end,:)=[];sigStd=twiss;sigCov=repmat(shiftdim(sig,-1),3,1);

eps=twiss(1,:)./gam;
b=twiss(2,:);a=twiss(3,:);g=(1+a.^2)./b;
sig(:,:)=[b.*eps;-a.*eps;g.*eps];
