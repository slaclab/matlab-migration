function twiss2 = model_twissTrans(twiss, rMat)
%MODEL_TWISSTRANS
%  TWISS2 = MODEL_TWISSTRANS(TWISS, RMAT) computes the Twiss parameters
%  from initial parameters TWISS and beam transport matrix RMAT.

% Features:

% Input arguments:
%    TWISS: Initial Twiss parameters, [2|3 x 1|2 x 1|N]
%    RMAT:  R-matrix, [2|4|6 x 2|4|6 x 1|N]

% Output arguments:
%    TWISS2: Final Twiss parameters, [2|3 x 1|2 x 1|N]

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

if size(twiss,2) == 1
    use=1:2;if size(twiss,1) > 2, use=2:3;end
    b=twiss(use(1));
    a=twiss(use(2));
    g=(1+a^2)/b;
    t=[b -a;-a g];
    t=rMat(1:2,1:2)*t*rMat(1:2,1:2)';
    t=t/sqrt(det(t));
    twiss(use)=[t(1) -t(2)];twiss2=twiss;
else
    twiss2 = twiss;
    for j=1:max(size(twiss,3),size(rMat,3))
        twiss2(:,1,j)=model_twissTrans(twiss(:,1,min(j,end)),rMat(1:2,1:2,min(j,end)));
        twiss2(:,2,j)=model_twissTrans(twiss(:,2,min(j,end)),rMat(3:4,3:4,min(j,end)));
    end
end
