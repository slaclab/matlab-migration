function [id, n] = bba_responseMatDesc(static, RAll, xMeas, varargin)

% Set defaults.
optsdef=struct( ...
    'nFit',1 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Parameter vector is x = [xInit(2) xQuad(2) xBPM(2) xUnd(4) xCorr(2)]'
% Measurement vector is y = [yBPM]'
% Response matrix is y = R * x

% Get number of parameters.
nFit=opts.nFit;
nMeas=numel(xMeas)/nFit;
RAll=reshape(RAll,nMeas,[]);
nPar=size(RAll,2);

n.quad=length(static.quadList);
n.BPM=length(static.bpmList);
n.und=length(static.undList);
n.corr=length(static.corrList);
n.FI=0;
n.drift=0;

nEn=nMeas/n.BPM/2;

if isfield(static,'numR'), n=static.numR;end

n.init=(nPar-2*(n.quad+n.BPM+2*n.und+n.corr+2*n.FI+n.drift))/nEn;

% Get index range for parameters
idMax=0;
id.init=reshape(idMax+(1:nEn*n.init),n.init,[]);idMax=max([idMax id.init(:)']);
id.quad=reshape(idMax+(1:2*n.quad),2,[]);idMax=max([idMax id.quad(:)']);
id.BPM=reshape(idMax+(1:2*n.BPM),2,[]);idMax=max([idMax id.BPM(:)']);
id.und=reshape(idMax+(1:4*n.und),4,[]);idMax=max([idMax id.und(:)']);
id.corr=reshape(idMax+(1:2*n.corr),2,[]);idMax=max([idMax id.corr(:)']);
id.FI=reshape(idMax+(1:4*n.FI),4,[]);idMax=max([idMax id.FI(:)']);
id.drift=reshape(idMax+(1:2*n.drift),2,[]);
