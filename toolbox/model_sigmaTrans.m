function sigma = model_sigmaTrans(sigma0, rMat)
%MODEL_SIGMATRANS
%  SIGMA = MODEL_SIGMATRANS(SIGMA0, RMAT) computes the sigma matrix SIGMA
%  from initial matrix SIGMA0 and beam transport matrix RMAT.

% Features:

% Input arguments:
%    SIGMA0: Initial sigma matrix, [2 x 2] or [3 x 1] or [3 x 2 x N]
%    RMAT:   R-matrix, [2|4|6 x 2|4|6 x 1|N]

% Output arguments:
%    TWISS2: Final sigma matrix, [2 x 2] or [3 x 1] or [3 x 2 x N]

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

nSigma=size(sigma0,1);
if nSigma ~= 3 || size(sigma0,2) == 1
    if nSigma == 3
        sigma0=reshape(sigma0([1 2;2 3],:),2,2,[]);
    end

    sigma=rMat*sigma0*rMat';

    if nSigma == 3
        sigma=sigma([1 2 4]');
    end
else
    nSig=max(size(sigma0,3),size(rMat,3));
    sigma=zeros(size(sigma0,1),2,nSig);
    for j=1:nSig
        js=min(j,size(sigma0,3));jr=min(j,size(rMat,3));
        sigma(:,1,j)=model_sigmaTrans(sigma0(:,1,js),rMat(1:2,1:2,jr));
        sigma(:,2,j)=model_sigmaTrans(sigma0(:,2,js),rMat(3:4,3:4,jr));
    end
end
