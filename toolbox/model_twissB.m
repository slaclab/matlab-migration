function B = model_twissB(twiss, energy)
%MODEL_TWISSB
%  MODEL_TWISSB(TWISS, ENERGY) computes the B matrix from the Twiss
%  parameters in TWISS.  This matrix is defined as B = [beta 0;-alpha
%  1]/sqrt(beta).  If ENERGY is provided, B is normalized to B_N =
%  SQRT(EPS) B with EPS the geometric emittance and B_N is returned.  Two
%  additional dimensions in TWISS are preserved and shifted to the right by
%  one to accomodate the two dimensions in a single B matrix.  ENERGY can
%  be scalar or vector and is replicated to match the numnber of Twiss
%  parameters provided.

% Features:

% Input arguments:
%    TWISS:    Actual Twiss parameters, [2|3 x M x N]
%    ENERGY:   Ideal Twiss parameters, scalar or M*N elements

% Output arguments:
%    B: B-matrix [2 x 2 x M x N]

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

beta=shiftdim(twiss(end-1,:,:),-1);
alpha=shiftdim(twiss(end,:,:),-1);
B=[sqrt(beta) 0*beta;-alpha./sqrt(beta) 1./sqrt(beta)];

if nargin < 2, return, end

e0=0.511e-3; % Energy in GeV
gam=repmat(energy(:)',numel(beta)/numel(energy),1)/e0;
eps=twiss(1,:)./gam(:)';

B(:)=B(:).*reshape(repmat(sqrt(eps(:)'),4,1),[],1);
