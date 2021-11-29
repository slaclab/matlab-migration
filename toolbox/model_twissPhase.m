function [psi, pMat] = model_twissPhase(twiss, rMat)
%MODEL_TWISSPHASE
%  MODEL_TWISSPHASE(TWISS, RMAT) computes the phase advance from initial
%  Twiss parameters TWISS and beam transport matrix RMAT.  

% Features:

% Input arguments:
%    TWISS: Initial Twiss parameters, [2|3 x 1|2 x 1|N]
%    RMAT:  R-matrix, [2|4|6 x 2|4|6 x 1|N]

% Output arguments:
%    PSI:  Phase advance, [1|2 x N]
%    PMAT: Rotation matrix, only returned if single Twiss parameter present

% Compatibility: Version 7 and higher
% Called functions: model_twissTrans, model_twissB

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if size(twiss,2) == 1
    t2=model_twissTrans(twiss,rMat);
    pMat=inv(model_twissB(t2))*rMat(1:2,1:2)*model_twissB(twiss);
    psi=atan2(real(pMat(1,2)),real(pMat(1,1)));
elseif size(twiss,3) == 1 && size(rMat,3) == 1
    psi(1,1)=model_twissPhase(twiss(:,1),rMat(1:2,1:2));
    psi(2,1)=model_twissPhase(twiss(:,2),rMat(3:4,3:4));
else
    psi=zeros(2,size(twiss,3));
    for j=1:max(size(twiss,3),size(rMat,3))
        psi(:,j)=model_twissPhase(twiss(:,:,min(j,end)),rMat(:,:,min(j,end)));
    end
end
