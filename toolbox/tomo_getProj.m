function p = tomo_getProj(x,y,f0,m,z,dim,w)
%GET_PROJ
%  GET_PROJ(X,Y,F0,M,Z,DIM,OZ) applies the linear transformation in 2x2xN
%  matrix M to the distribution F0 given in the interval specified by the
%  vectors X and Y. The transformed distribution is integrated over X to
%  obtain the projection onto Y. If M has 3rd dimension, then multiple
%  projections P are generated. If Z is given, the projections are
%  calculated at these locations. DIM specified the dimension where the
%  integration is taken along and defaults to 2.

% Compatibility: Version 7 and higher
% Called functions: tomo_transPhaseSpace

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input parameters.
if nargin < 7, w=[];end
if nargin < 6, dim=2;end
if nargin < 5, z=[];end

yx={y x};
if ~isempty(z), yx{3-dim}=z;end
if ~isempty(w), yx{dim}=w;end
dyx=diff(yx{dim}([1 2]));
f=tomo_transPhaseSpace(x,y,f0,m,yx{:});
p=reshape(sum(f,dim)*dyx,[],size(f,3));
%pp=reshape(sum(f,3-dim)*dyx,[],size(f,3));

%figure(1);clf
%subplot(2,2,3);imagesc(x*1e6,y*1e6,f0);
%subplot(2,2,2);
%imagesc(z*1e6,w*1e6,f(:,:,1));
%imagesc(f(:,:,1));
%subplot(2,2,4);plot(z*1e6,p);axis tight
%subplot(2,2,1);plot(pp,w*1e6);axis tight
