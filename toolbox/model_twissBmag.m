function [twiss, twissstd] = model_twissBmag(twiss, twiss0, twisscov)
%MODEL_TWISSBMAG
%  MODEL_TWISSBMAG(TWISS, TWISS0, TWISSCOV) computes the BMAG or emittance
%  mismatch between actual parameters TWISS and ideal parameters TWISS0.
%  It is defined as xi = (beta_0 gamma - 2 alpha_0 alpha + gamma_0 beta)/2.
%  Optionally, if the covariance matrix TWISSCOV is provided, the error for
%  BMAG is also computed.  The BMAG values are appended to the input array
%  TWISS as an additional row.  Beta and alpha are expected to reside in
%  the second but last and the last row. The function works for multiple
%  Twiss parameters where columns and further dimensions in the input are
%  preserved.  The first 2 dimensions of TWISSCOV must match the first
%  dimension of TWISS, and the remaning dimensions in TWISSCOV must have
%  the same number of elements as the remaining ones in TWISS.

% Features:

% Input arguments:
%    TWISS:    Actual Twiss parameters, [2|3 x M x N x ...]
%    TWISS0:   Ideal Twiss parameters, [2|3 x M x N x ...] or [2|3 x 1]
%    TWISSCOV: Optional covariance matrix for TWISS, [2|3 x 2|3 x M x N x ...]

% Output arguments:
%    TWISS:    Twiss parameters with BMAG appended as additional row
%    TWISSSTD: Standard deviation of TWISS including BMAG is TWISSCOV provided

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

bet=twiss(end-1,:);alp=twiss(end,:);gam=(1+alp.^2)./bet;
bet0=twiss0(end-1,:);alp0=twiss0(end,:);gam0=(1+alp0.^2)./bet0;

xi=(bet0.*gam-2*alp0.*alp+gam0.*bet)/2;
twiss(end+1,:)=xi;

twissstd=twiss*0;

if nargin < 3, return, end

for j=1:numel(xi)
    dxi=[gam0(j)*bet(j)-bet0(j)*gam(j) 2*bet0(j)*alp(j)-2*bet(j)*alp0(j)]/bet(j)/2;
    twissstd(1:end-1,j)=sqrt(diag(twisscov(:,:,j)));
    twissstd(end,j)=sqrt(dxi*twisscov(end-1:end,end-1:end,j)*dxi');
end
