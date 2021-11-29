function [R, en, RQErr, static] = bba_responseMatGet(static, appMode, enOnly, varargin)
%BBA_RESPONSEMATGET
%  BBA_RESPONSEMATGET(STATIC, APPMODE, ENONLY) computes the response matrix
%  for BPMs from devices given in STATIC structure. Simulation mode is
%  determined by APPMODE.  If ENONLY is set only the energy is returned.

% Features:

% Input arguments:
%    STATIC:  As created by BBA_INIT
%    APPMODE: Production mode (1 production, 0 simulation)
%    ENONLY:  If given only energy EN is returned
%    OPTS:    Options

% Output arguments:
%    R:      Response matrix [2*NBPM x 2*NDEV]
%    EN:     Beam energy
%    STATIC: Adds R-mat descriptor N.(INIT,BPM,QUAD,UND,CORR,FI,DRIFT)

% Compatibility: Version 2007b, 2012a
% Called functions: model_energySetPoints, control_magnetGet, lcaGet,
%                   control_energyNames, control_deviceGet, model_energy,
%                   model_rMatGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Set defaults.
optsdef=struct( ...
    'getFI',0, ...
    'getDrift',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Calculate response matrix for energy EN.
% xMeas = R * [xInit; xQuadOff; xBPMOff; undOff; BCorr; [undFI; driftB]]

if nargin < 2, appMode=0;end
if nargin < 3, enOnly=0;end

if appMode
    if any(strncmp(static.bpmList,'M',1)) % FACET
        en=model_energySetPoints;en=en(end);
    else
        [d,en]=control_magnetGet('BYD1');
    end
else
    en=lcaGet('SIOC:SYS0:ML00:AO875');
end
if enOnly, R=[];return, end

name=control_energyNames(static.corrList);
if appMode && ~any(strncmp(name,'XCOR:UND1',9)) && ~isempty(name)
%if any(isSLC)
    if any(strncmp(static.bpmList,'M',1)) % FACET
        enList=control_deviceGet(name,'EMOD');
    else
        enList=lcaGet(strcat(name,':EDES'));
    end
else
%    enList=en;
    enList=model_energy(static.corrList)';
end
enList=kron(enList,[1;1]);
bp=enList/299.792458*1e4; % kG m
bp2=en/299.792458*1e4; % kG m

bpmList=static.bpmList;
quadList=static.quadList;
undList=static.undList;
corrList=static.corrList;
nQuad=length(static.quadList);
nUnd=length(static.undList);
nBPM=length(static.bpmList);
nCorr=length(static.corrList);
zQuad=static.zQuad;
zUnd=static.zUnd;
zBPM=static.zBPM;
zCorr=static.zCorr;
lUnd=static.lUnd;
nFI=0;

if strcmp(model_init,'SLC')
    rOpts=[repmat({'POS=BEG'},nQuad+nUnd,1);repmat({'POS=END'},nQuad+nUnd+nBPM+nCorr,1)];
    rList=model_rMatGet([quadList;undList;quadList;undList;bpmList;corrList],[],rOpts);
    r0=rList(:,:,2*nQuad+2*nUnd+1);
    for j=1:size(rList,3)
        rList(:,:,j)=rList(:,:,j)*inv(r0);
    end
else
    rOpts=[repmat({'POSB=BEG'},nQuad+nUnd,1);repmat({'POSB=END'},nQuad+nUnd+nBPM+nCorr,1)];
    rList=model_rMatGet(bpmList{1},[quadList;undList;quadList;undList;bpmList;corrList],rOpts);
end

bad=~any(reshape(rList,[],size(rList,3)));
rList(:,:,bad)=repmat(eye(6),[1 1 sum(bad)]);

rQuadB=rList(:,:,1:nQuad);
rUndB=rList(:,:,nQuad+(1:nUnd));
rQuadE=rList(:,:,nQuad+nUnd+(1:nQuad));
rUndE=rList(:,:,2*nQuad+nUnd+(1:nUnd));
rBPM=rList(:,:,2*nQuad+2*nUnd+(1:nBPM));
rCorrE=rList(:,:,2*nQuad+2*nUnd+nBPM+(1:nCorr));

%RQuad=kickMat(rQuadB,rQuadE,zQuad,zBPM,0,[1 3]);
%RUnd=kickMat(rUndB,rUndE,zUnd,zBPM,lUnd,1:4);
%RCorr=kickMat(0,rCorrE,zCorr,zBPM,0,[2 4]);

iInit=[1:4 6];nInit=numel(iInit);
[RQuad,RUnd,RCorr,RQErr,RFI,RDrift]=deal(zeros(nBPM*nInit,0));
rPar=eye(6);

% Get drift spaces.
[zDrift,lDrift,rB]=bba_driftGet(static,{rQuadB rBPM rUndB rCorrE});
%{
[zAll,id]=sort([zQuad zBPM zUnd zCorr]);id(~zAll)=[];
lAll=[zQuad*0 zBPM*0 lUnd zCorr*0];
rB=cat(3,rQuadB,rBPM,rUndB,rCorrE);
zDrift=zAll(~~zAll);
lAll=lAll(id);
zB=zDrift-lAll/2;
zE=zDrift+lAll/2;
rB=rB(:,:,id);
%nE=vertcat(static.quadList,static.bpmList,static.undList,static.corrList);nE=nE(id);
lDrift=zB(2:end)-zE(1:end-1);
zDrift=(zB(2:end)+zE(1:end-1))/2;
rB(:,:,1)=[];
uD=lDrift > 0;
lDrift(~uD)=[];zDrift(~uD)=[];rB(:,:,~uD)=[];
%}
nDrift=numel(lDrift);

% Get quad response matrices.
%lQuad=model_rMatGet(quadList,[],[],'LEFF');
'quads'
for j=1:nQuad
    j
    use=zQuad(j) < zBPM(:);
%    dQuad=blkdiag(kron(eye(2),[1 lQuad(j);0 1]),eye(2)); % only needed if angle offset
    dQuad=eye(6);
    rQuad0=inv(rQuadE(:,:,j))*dQuad-inv(rQuadB(:,:,j));
    rQuad=rQuad0(iInit,:)*rPar(:,[1 3]);
    RQuad=[RQuad(:,:) kron(use,rQuad)];
%{
    iBPM=[1;find(~use,2,'last');2]; % Find BPM upstream of quad
    iBPM=iBPM((0:1)+min(2,end-1));
    rB1B2=[1 0 0 0;0 0 1 0]*rBPM(1:4,1:4,iBPM(2))*inv(rBPM(1:4,1:4,iBPM(1)));
    rQErr=rQuad0(1:4,1:4)*rQuadB(1:4,1:4,j)*inv(rBPM(1:4,1:4,iBPM(1)))*inv([1 0 0 0;0 0 1 0;rB1B2]);
    RQErr=[RQErr(:,:) kron(use,[rQErr;zeros(nInit-4,4)])];
%}
end

% Get undulator response matrices.
'undulator'
for j=1:nUnd
    j
    use=zUnd(j) < zBPM(:);
    dUnd=blkdiag(kron(eye(2),[1 lUnd(j);0 1]),eye(2));
    rUnd=inv(rUndE(:,:,j))*dUnd-inv(rUndB(:,:,j));
    rUnd=rUnd(iInit,:)*rPar(:,1:4);
    RUnd=[RUnd(:,:) kron(use,rUnd)];
end

% Get corrector/bend response matrices.
'corrector'
for j=1:nCorr
    j
    use=zCorr(j) < zBPM(:);
    rCorr=inv(rCorrE(:,:,j));
    rCorr=rCorr(iInit,:)*rPar(:,[2 4]);
    RCorr=[RCorr(:,:) kron(use,rCorr)];
end

% Get Field integral response matrices.
'field integral'
if opts.getFI, nFI=nUnd;end
for j=1:nFI
    j
    use=zUnd(j) < zBPM(:);
    rFI=inv(rUndE(1:4,1:4,j))*flipud(diag([1 1 -1 -1]));
    RFI=[RFI(:,:) kron(use,[rFI;zeros(nInit-4,4)])];
end

% Get drift field response matrices.
'drift field'
if ~opts.getDrift, nDrift=0;end
for j=1:nDrift
    j
    use=zDrift(j) < zBPM(:);
%    rDrift=inv(rB(1:4,1:4,j))*[lDrift(j)/2 0;1 0;0 lDrift(j)/2;0 1]*lDrift(j);
    rDrift=inv(rB(:,:,j)); % rB is to the end of the preceeding drift
    rDrift=rDrift(iInit,1:4)*[0 -lDrift(j)/2;0 -1;lDrift(j)/2 0;1 0]*lDrift(j);
    RDrift=[RDrift(:,:) kron(use,rDrift)];
end

% Assemble full response matrix.
rBPMCell=num2cell(rBPM([1 3],iInit,:),[1 2]);
RBPM=blkdiag(rBPMCell{:});
RInit=repmat(eye(nInit),nBPM,1);
RBPMOff=-eye(2*nBPM);
R=[RBPM*[RInit RQuad] RBPMOff RBPM*[RUnd RCorr*diag(1./bp) RFI*diag(1./bp2) RDrift*diag(1./bp2)]];
RQErr=RBPM*RQErr;

for t={'nInit' 'nBPM' 'nQuad' 'nUnd' 'nCorr' 'nFI' 'nDrift'; ...
        'init'  'BPM'  'quad'  'und'  'corr'  'FI'  'drift'}
    static.numR.(t{2})=eval(t{1});
end


function [zDrift, lDrift, rB] = bba_driftGet(static, R)

% Get drift spaces.
zQuad=static.zQuad;
zUnd=static.zUnd;
zBPM=static.zBPM;
zCorr=static.zCorr;
lUnd=static.lUnd;

[zAll,id]=sort([zQuad zBPM zUnd zCorr]);id(~zAll)=[];
lAll=[zQuad*0 zBPM*0 lUnd zCorr*0];
zDrift=zAll(~~zAll);
lAll=lAll(id);
zB=zDrift-lAll/2;
zE=zDrift+lAll/2;
lDrift=zB(2:end)-zE(1:end-1);
zDrift=(zB(2:end)+zE(1:end-1))/2;
uD=lDrift > 0;
lDrift(~uD)=[];zDrift(~uD)=[];

if isempty(R), return, end
rB=cat(3,R{:});
rB=rB(:,:,id);
rB(:,:,1)=[];
rB(:,:,~uD)=[];


%function R = kickMat(rB, rE, z, zBPM, l, id)

%p=eye(4);nId=numel(id);
%R=[];R=zeros(4*numel(zBPM),nId*numel(z));
%for j=1:numel(z)
%    use=z(j) < zBPM(:);
%    rBinv=0;if numel(rB) > 1, rBinv=inv(rB(1:4,1:4,j));end
%    rD=kron(eye(2),[1 l(min(j,end));0 1]);
%    r=(inv(rE(1:4,1:4,j))*rD-rBinv)*p(:,id);
% %   R=[R kron(use,r)];
%    R(:,(1:nId)+(j-1)*nId)=kron(use,r);
%end
