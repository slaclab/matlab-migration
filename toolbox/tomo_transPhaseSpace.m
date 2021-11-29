function f=tomo_transPhaseSpace(x,y,f0,m,yf,xf)
%TRANS_PHASESPACE
%  TRANS_PHASESPACE(X,Y,F0,M,YF,XF) applies the linear transformation in 2x2xN
%  matrix M to the distribution F0 given in the interval specified by the
%  vectors X and Y. The transformed distribution F is defined on the same
%  domain. Areas within F which are not part of the original area are set
%  to zero and parts of F0 projected outside are lost. If M has 3rd
%  dimension, then multiple transformations F are generated. If YF or XF is
%  given, the distributions are calculated at these locations.


% --------------------------------------------------------------------
% Check optional parameters.
if nargin < 6, xf=x;end
if nargin < 5, yf=y;end
t=[];if iscell(m), [m,t]=deal(m{:});end

% Check input parameters.
x=reshape(x,1,[]);
y=reshape(y,[],1);
yf=reshape(yf,[],1);
xf=reshape(xf,1,[]);

% Get grid coordinates.
[x2,y2]=meshgrid(xf,yf);
f=zeros([size(x2) size(m,3)]);

% Transform coordinates according to M and find transformed distribution's
% values F at backtransformed locations inv(M)(x,y) in original F0.
for j=1:size(m,3)
    mi=inv(m(:,:,j));
    xi=mi(1,1)*x2+mi(1,2)*y2;
    yi=mi(2,1)*x2+mi(2,2)*y2;
    if ~isempty(t)
        yi=yi-t(2,1,j)*x2.^2;
    end
    f(:,:,j)=interp2(x,y,f0,xi,yi,'*linear');
end

% Set out of area values (NaN) to zero.
f(isnan(f))=0;

return
