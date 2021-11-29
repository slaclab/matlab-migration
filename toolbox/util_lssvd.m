function [x, stdx, mse, S] = util_lssvd(A, b, w, c)
%LSSVD
%  [X, STDX, MSE, S] = LSSVD(A, B, W, C) least square fit using SVD, B can
%  be a matrix in which case the columns correspond to different fits, but
%  weights will be taken from first column.

% Input arguments:
%    A: Response matrix
%    B: Measurement vector
%    W: Weight vector, optional (default to 1 when [] or omitted)
%    C: SVD threshold, optional (defaults to 0, i.e. use all). Positive
%       number interpreted as fractional threshold, negative value as # to use

% Output arguments:
%    X:    Fitted parameters
%    STDX: Estimated standard errors of fitted parameters
%    MSE:  Mean squared error, based on singular values used after
%          threshold applied
%    S:    Estimated covariance matrix of fitted parameters

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.

if nargin < 4, c=0;end
if nargin < 3, w=[];end
if isempty(w), w=1;end

M=diag(sqrt(w(:,1)))*A; % Weighted response matrix
B=sqrt(w).*b; % Weighted measurement vector

[U,S,V]=svd(M);
if isvector(S) && ~isempty(S), s=S(1);else s=diag(S);end
if isempty(s), s=0;end
if c < 0, c=s(min(-c,end))/s(1);end
S(S < c*s(1))=0;
S2inv=pinv(S'*S); % Change to not use pinv, this calls svd again.
x=V*S2inv*S'*U'*B;
nMeas=size(A,1);
dfe=(nMeas-sum(S(:) ~= 0));
if dfe
    %mse=B'*(B-M*x)/dfe;
    mse=sum(B.*((eye(nMeas)-U*S*S2inv*S'*U')*B/dfe));
else
    mse=0;
end
S=V*S2inv*V';
stdx=sqrt(diag(S)*mse);
S=reshape(kron(mse,S),size(S,1),size(S,2),[]); % Scale covariance matrix by MSE
