function w = tomo_sart_spnew(x,y,yf,mat,tmat)
%TOMO_SART_SPNEW
%  TOMO_SART_SPNEW(X,Y,YF,MAT,TMAT)
%  Implementation of SART (Simultaneous Algebraic Reconstruction Technique)
%  Algorithm with use of sparse matrices.
%
% Features:

% Input arguments:
%    X:    x coordinates of reconstruction domain
%    Y:    y coordinates of reconstruction domain
%    YF:   Coordinates of measured profiles, assumed to be on y axis of
%          phase space
%    MAT:  Transport matrices [2 2 M]. Profiles assumed to be obtained
%          along 2nd axis, so if measured along 1st axis, provide
%          K0([2 1],:,:) instead
%    TMAT: 2nd order transport matrices, not used yet
%
% Output arguments:
%    W: Imaging matrix from reconstruction domain to profiles
%
% The reconstruction in the unnormalized coordinates can be obtained by
% F = TOMO_TRANSPHASESPACE(XVAL, YVAL, FRHO, B, XVAL0, YVAL0)

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Build coordinate grid and determine vector lengths.
[x2,y2]=meshgrid(x(:)',y(:));
dx=x(2)-x(1);
dy=y(2)-y(1);

if size(yf,2) == 1, yf=yf';end
yf=repmat(yf,size(mat,3)/size(yf,1),1);
dyf=yf(:,2)-yf(:,1);
nxy=numel(x2);
nyf=length(yf);
nmat=length(mat);
w=sparse([],[],[],nxy,nyf*nmat);

% Get transformed Y coordinate and normalize to YF.
m=reshape(mat(2,:,:),2,[]); % Reduce MAT to M for transport of Y coordinate.
yp0=[x2(:) y2(:)]*m*diag(1./dyf); % 
%ysig0=max(abs(diag([dx dy])*m),1); % Maximum norm.
ysig0=sqrt([dx dy].^2*m.^2); % Geometric norm.

for j=1:nmat
    % Normalize Y coordinates.
    yn=yp0(:,j)-yf(j,1)/dyf(j)+1;
    ysig=ysig0(j);
    ysign=ysig/dyf(j);
    yl=yn-ysign/2;
    yu=yn+ysign/2;
    iymin=round(yl);
    iymax=round(yu);
    yld=yl-iymin;
    yud=yu-iymax;
    nysig=max(iymax-iymin+1);

    iloc=iymax-iymin+1;
    iiloc=(1:nxy)'+(iloc-1)*nxy;
    wy=ones(nxy,nysig);
    wy(:,end)=0;
    wy(iiloc)=yud+.5;
    wy(:,1)=wy(:,1)-(yld+.5);
    wy(abs(wy) < 1e-10)=0;

    iy=(iymin-1)*ones(1,nysig)+ones(nxy,1)*(1:nysig);
    good=(iy >= 1) & (iy <= nyf);
    ind=repmat((1:nxy)',1,nysig);
%    iind=ind+(iy-1)*nxy;
%    w0=zeros(nxy,nyf);
%    w0(iind(good))=wy(good);
    w=w+sparse(ind(good),iy(good)+(j-1)*nyf,wy(good)/ysig*dy*dx,nxy,nyf*nmat);
    disp('.');
end
