function [twiss, twissStd, twissCov] = model_sigma2Twiss(sig, sigCov, energy)
%MODEL_SIGMA2TWISS
%  [TWISS, TWISSSTD, TWISSCOV] = MODEL_SIGMA2TWISS(SIG, SIGCOV, ENERGY)
%  computes the uncoupled Twiss parameters TWISS from sigma vector SIG.  If
%  ENERGY is not given, the emittance in TWISS(1,:) is computed as geometric.
%  SIG has the unique elements of the 2x2 sigma matrix as the first 3 row
%  elements and arbitrary further dimensions holding multiple sigma tuples.
%  TWISS is returned with same size as SIG. If SIGCOV is given, TWISSSTD
%  and TWISSCOV are computed as standard deviation and covariance matrix
%  for TWISS.

% Features:

% Input arguments:
%    SIG:    Sigma matrix parameters, [3 x M x N x ...]
%    SIGCOV: Covariance matrix of SIG, [3 x 3 x M x N ...]
%    ENERGY: Energy in GeV (optional), scalar or M*N elements array

% Output arguments:
%    TWISS:    Twiss parameters, [[eps_n; beta; alpha] x M x N ...]
%    TWISSSTD: Std of TWISS, [3 x M x N ...]
%    TWISSCOV: Covariance matrix of TWISS, [3 x 3 x M x N ...]

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

e0=0.511e-3; % Energy in GeV
if nargin < 3, energy=[];end
if nargin < 2, sigCov=[];end
if isempty(energy), energy=e0;end
gam=energy(:)'/e0;
twiss=sig*0;twissStd=twiss;twissCov=repmat(shiftdim(twiss,-1),3,1);

eps=sqrt(sig(1,:).*sig(3,:)-sig(2,:).^2);
twiss(:,:)=[eps.*gam;sig(1,:)./eps;-sig(2,:)./eps];
twissI=twiss;twiss=real(twiss);

if isempty(sigCov), return, end

for j=1:numel(eps)
    deps=[sig(3,j) -2*sig(2,j) sig(1,j)]/2/eps(j);
    dtwiss=(diag([1 -1 -1])*twissI(:,j)*deps+diag([1 -1],-1))/eps(j);
    twissCov(:,:,j)=dtwiss*sigCov(:,:,j)*dtwiss';
    twissStd(:,j)=sqrt(diag(twissCov(:,:,j)));
end
