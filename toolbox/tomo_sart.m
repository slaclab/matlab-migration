function rho = tomo_sart(x, y, profs, w, varargin)
%TOMO_SART
%  TOMO_SART(X,Y,PROFS,W,...)
%  Implementation of the Simultaneous Algebraic Reconstruction Technique
%  (SART) tomographic reconstruction algorithm.
%
% Features:

% Input arguments:
%    X:     x coordinates of reconstruction domain
%    Y:     y coordinates of reconstruction domain
%    PROFS: Array of M measured profiles [N M] with N points in each
%    W:     Imaging matrix from reconstruction domain to profiles
%
% Output arguments:
%    RHO: Reconstructed density function

% Compatibility: Version 7 and higher
% Called functions: tomo_sart_plot

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Get weight norm and remove roundoff errors.
w2=full(sum(w.^2,1))';w2(abs(w2) <= 1e-10)=1;
w1=full(sum(w,1))';w1(abs(w1) <= 1e-10)=1;

nx=length(x);
ny=length(y);
nxy=nx*ny;
[nyf,nmat]=size(profs);

% Reorder projections to random.
morder=randperm(nmat);
morder=1:nmat;
morder=mod(floor(((1:nmat)-1)*(nmat+1)/2)+1,nmat)+1;

rho=zeros(nxy,1);
canvas=[1:ny 1-ny+nxy:nxy 1:ny:1-ny+nxy ny:ny:nxy];
lambda=[.01 .99 .99 .99 .99 .99 .99 .99 .99 1.];
nlam=12;
floorval=.0;
lambda=1*ones(1,nlam);lambda(1)=.9;
for n=1:length(lambda)
    for j=morder
        yind=(1:nyf)'+(j-1)*nyf;
        q=full(w(:,yind)'*rho);
        w3=full(sum(w(:,yind),2));w3(abs(w3) <= 1e-10)=1;
%        rho=rho+lambda(n)*full(w(:,yind)*((profs(yind)-q)./w2(yind)));
        rho=rho+lambda(n)*full(w(:,yind)*((profs(yind)-q)./w1(yind)))./w3;
        rho(rho < floorval*max(rho))=0;
%        sart_plot(x,y,reshape(rho,ny,[]),varargin{:});
    end
    rho(rho < floorval*max(rho))=0;
%    rho(canvas)=0;
    tomo_sart_plot(x,y,reshape(rho,ny,[]),varargin{:});
end
rho(rho < floorval*max(rho))=0;
rho=reshape(rho,ny,[]);

return
