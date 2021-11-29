function [result, opts] = bba_fitOrbit(static, RAll, xMeas, xMeasStd, varargin)

% Set defaults.
optsdef=struct( ...
    'use',struct('init',1,'quad',1,'BPM',1,'corr',0,'und',0,'FI',0,'drift',0), ...
    'iQuad',[], ...
    'iBPM',[], ...
    'iUnd',[], ...
    'iCorr',[], ...
    'iInit',[], ...
    'iFI',[], ...
    'iDrift',[], ...
    'fitSVDRatio',0, ...
    'fitScale',1, ...
    'fitBPMLin',0, ...
    'fitBPMSlope',0, ...
    'fitBPMMin',0, ...
    'fitQuadLin',0, ...
    'fitQuadMin',0, ...
    'fitQuadAbs',0, ...
    'fitQuadKick',0, ...
    'fitCorrMin',0, ...
    'fitCorrAbs',0, ...
    'fitQuadErr',0, ...
    'nFit',1, ...
    'quadB',[], ...
    'corrB',[] ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);
opts.use=util_parseOptions(opts.use,optsdef.use);

% Parameter vector is x = [xInit(2) xQuad(2) xBPM(2) xUnd(4) xCorr(2)]'
% Measurement vector is y = [yBPM]'
% Response matrix is y = R * x

% Get number of parameters.
nFit=opts.nFit;
nMeas=numel(xMeas)/nFit;
RAll=reshape(RAll,nMeas,[]);
nPar=size(RAll,2);

% Get parameter indices.
[id,num]=bba_responseMatDesc(static,RAll,xMeas,opts);
nInit=num.init;nQuad=num.quad;nBPM=num.BPM;nUnd=num.und;
nCorr=num.corr;nFI=num.FI;nDrift=num.drift;
nEn=nMeas/nBPM/2;

iInit=id.init;iQuad=id.quad;iBPM=id.BPM;iUnd=id.und;
iCorr=id.corr;iFI=id.FI;iDrift=id.drift;

% Check correctors.
if isempty(opts.corrB)
    opts.corrB=zeros(2,length(static.corrList),nEn);
end

% Set nonexisting corrs to NaN.
useX=strncmp(static.corrList,'X',1) | strncmp(static.corrList,'BX',2);
useY=strncmp(static.corrList,'Y',1) | strncmp(static.corrList,'BY',2);
opts.corrB(1,~useX,:)=NaN;
if any(useY), opts.corrB(2,~useY,:)=NaN;end
corrB=reshape(opts.corrB(:,:,1),[],1);
badCorr=isnan(corrB);

% Subtract orbit from non-zero correctors.
if nEn > 1 && nCorr && any(opts.corrB(:))
    RC=num2cell(reshape(RAll(:,iCorr(:))',[],2*nBPM,nEn),[1 2]);
    RC=blkdiag([],RC{:})';
    opts.corrB(isnan(opts.corrB))=0;
    xCorr=RC*opts.corrB(:);
else
    xCorr=0;
end
xMeas(:)=xMeas(:)-xCorr;

% Set up used measurements.
useMeas=false(size(xMeas));useMeas(:,1:nBPM,:)=true;
useMeas=useMeas & ~isnan(xMeas);
useMeas=find(all(reshape(useMeas,[],nFit),2));

% Check for measurement std.
if nargin < 4, xMeasStd=[];end
if isempty(xMeasStd) || ~all(xMeasStd(:)) || any(isnan(xMeasStd(useMeas)))
    xMeasStd=xMeas*0+.1e-6;
end

% Constraints
sigBPM=nQuad*opts.fitScale;
sigCorr=nCorr*opts.fitScale;
[RBLin,RBMin,RQLin,RQMin,RCMin]=deal(zeros(0,nPar));
[xBLin,xBMin,xQLin,xQMin,xCMin]=deal(zeros(0,1));

% Linear BPM Constraint
if opts.fitBPMLin
    RBLin(1:4,iBPM)=kron([ones(1,nBPM);static.zBPM],eye(2));
    xBLin=RBLin(:,1)*0;
end

% Min BPM Constraint
if opts.fitBPMMin
    RBMin(1:2*nBPM,iBPM)=eye(2*nBPM)/sigBPM;
    xBMin=RBMin(:,1)*0;
end

% Linear Quad Constraint
if opts.fitQuadLin
    RQLin(1:4,iQuad)=kron([ones(1,nQuad);static.zQuad],eye(2));
    xQLin=RQLin(:,1)*0;

    % Linear Quad Kick Constraint
    if opts.fitQuadKick && ~isempty(opts.quadB)
        RQLin(1:4,iQuad)=RQLin(1:4,iQuad)*kron(diag(abs(opts.quadB)),eye(2));
    end
end

% Min Quad Constraint
if opts.fitQuadMin || opts.fitQuadAbs
    RQMin(1:2*nQuad,iQuad)=eye(2*nQuad)/sigBPM;
    xQMin=RQMin(:,1)*0;
    if opts.fitQuadAbs, xQMin=[1 -.5 0 .1]'*1e-3/sigBPM;end
end

% Min corr Constraint
if opts.fitCorrMin || opts.fitCorrAbs
    RCMin(1:2*nCorr,iCorr)=eye(2*nCorr)/sigCorr;
    RCMin(badCorr,:)=[];
    xCMin=RCMin(:,1)*0;
    if opts.fitCorrAbs, xCMin=corrB(~badCorr)/sigCorr;end
end

% Assemble constraint matrix and vector
RLagr=[RBLin;RBMin;RQLin;RQMin;RCMin];
xLagr=[xBLin;xBMin;xQLin;xQMin;xCMin];
xLagr=repmat(xLagr,1,nFit);
xLagrStd=ones(size(xLagr));
if ~isempty(useMeas), xLagrStd=xLagrStd*mean(xMeasStd(useMeas));end

% Set up used parameters.
xParF=zeros(nPar,nFit);
xParFStd=zeros(nPar,nFit);
r.xMeasF=xMeas*0;
if isempty(opts.iInit), opts.iInit=1:nInit;end
if isempty(opts.iQuad), opts.iQuad=1:nQuad;end
if isempty(opts.iBPM), opts.iBPM=1:nBPM;end
if isempty(opts.iCorr), opts.iCorr=1:nCorr;end
if isempty(opts.iUnd), opts.iUnd=1:nUnd;end
if isempty(opts.iFI), opts.iFI=1:nFI;end
if isempty(opts.iDrift), opts.iDrift=1:nDrift;end
usePar=[reshape(opts.use.init*iInit(opts.iInit,:),1,[]) ...
        reshape(opts.use.quad*iQuad(:,opts.iQuad),1,[]) ...
        reshape(opts.use.BPM*iBPM(:,opts.iBPM),1,[]) ...
        reshape(opts.use.corr*iCorr(:,opts.iCorr),1,[]) ...
        reshape(opts.use.und*iUnd(:,opts.iUnd),1,[]) ...
        reshape(opts.use.FI*iFI(:,opts.iFI),1,[]) ...
        reshape(opts.use.drift*iDrift(:,opts.iDrift),1,[]) ...
        ];
usePar(~usePar)=[];
usePar=setdiff(usePar,iCorr(badCorr));

% Linear BPM Fit
if opts.fitBPMSlope
    usePar=union(usePar,iBPM(1:4));
    RAll(:,iBPM(1:4))=kron([static.zBPM' ones(nBPM,1)],eye(2));
end

% Fit initial conditions and offsets.
RF=RAll(useMeas,usePar);
R=[RF;RLagr(:,usePar)];
xMeas=reshape(xMeas,[],nFit);
xMeasStd=reshape(xMeasStd,[],nFit);
x=[xMeas(useMeas,:);xLagr];
w=1./[xMeasStd(useMeas,:);xLagrStd].^2;
for j=1:nFit
    if opts.fitSVDRatio || isempty(R)
        [xParF(usePar,j),xParFStd(usePar,j)]=util_lssvd(R,x(:,j),w(:,j),opts.fitSVDRatio);
    elseif ~isempty(R)
        [xParF(usePar,j),xParFStd(usePar,j)]=lscov(R,x(:,j),w(:,j));
    end
end

% Put results into individual parameter vectors.
%r.xMeasF(useMeas)=RAll(useMeas,usePar)*xParF(usePar);
r.xMeasF(:)=RAll(:,usePar)*xParF(usePar,:);
r.xInit=reshape(xParF(iInit,:),nInit,[]);
r.xInitStd=reshape(xParFStd(iInit,:),nInit,[]);
r.quadOff=reshape(xParF(iQuad(:),:),[size(iQuad) nFit]);
r.quadOffStd=reshape(xParFStd(iQuad(:),:),[size(iQuad) nFit]);
r.bpmOff=reshape(xParF(iBPM(:),:),[size(iBPM) nFit]);
r.bpmOffStd=reshape(xParFStd(iBPM(:),:),[size(iBPM) nFit]);
r.corrOff=reshape(xParF(iCorr(:),:),[size(iCorr) nFit]);
r.corrOffStd=reshape(xParFStd(iCorr(:),:),[size(iCorr) nFit]);
r.undOff=reshape(xParF(iUnd(:),:),[size(iUnd) nFit]);
r.undOffStd=reshape(xParFStd(iUnd(:),:),[size(iUnd) nFit]);
r.xMeasF(:)=r.xMeasF(:)+xCorr;
result=r;
