function [xMeas, x0, xtmit] = bba_bpmDataGet(static, R, appMode, handles, varargin)
%BBA_BPMDATAGET
%  BBA_BPMDATAGET(STATIC, R, APPMODE, HANDLES, OPTS) gets BPM orbits
%  based on device information in STATIC structure obtained via BBA_INIT.
%  Uses response matrix R in simulation mode determined by APPMODE.  Number
%  of points given by HANDLES or if structure by fields within.

% Features:

% Input arguments:
%    STATIC:  As created by BBA_INIT
%    R:       Response matrix for simulation
%    APPMODE: Production mode (1 production, 0 simulation)
%    HANDLES: Sample number or struct from GUI
%    OPTS:    Options struct

% Output arguments:
%    XMEAS: Measured orbits [2|3 x NBPM x NSAMPLE]
%    X0:    Initial orbits in simulation mode
%    XTMIT: 

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, model_nameConvert, eDefParams,
%                   eDefOn, control_bpmAidaGet, eDefDone, lcaGetSmart,
%                   bba_corrGet, control_magnetGet

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit strayB bpmScale bpmRoll undFI driftB

% Set default options.
optsdef=struct( ...
    'useBPMNoise',0, ...
    'bpmNoise',1, ... % um
    'useBeamJitt',0, ...
    'beamJitt',[10 1], ... % [um urad]
    'beamEnerJitt',0, ... % 10^-4
    'useCorrNoise',0, ...
    'corrNoise',1, ... % kGm 10^6
    'useSteer',0, ...
    'eDefNum',0, ...
    'eDefOn',1, ...
    'tmit',0);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% BPM PVs
[pvList,d,isSLC]=model_nameConvert(static.bpmList,'EPICS');
pv=[strcat(pvList(:),':X') strcat(pvList(:),':Y')]';
isSLC=[isSLC(:) isSLC(:)]';isSLC=isSLC(:);
pvT=strrep(strrep(pv,':X',':TMIT'),':Y',':TMIT');
pvStat=strrep(strrep(pv,':X',':ACCESS'),':Y',':ACCESS');
isFACET=strncmp(static.bpmList,'M',1);
isFACET=reshape([isFACET(:) isFACET(:)]',[],1);

nVal=handles;
if isstruct(handles)
    nVal=handles.dataSample.nVal;
    if isfield(handles,'eDefNumber')
        opts.eDefNum=handles.eDefNumber;
    end
end

% Production mode
if appMode && ~epicsSimul_status
    x0=0;
    if opts.eDefOn
        eDefParams(opts.eDefNum,1,nVal+1);
        eDefOn(opts.eDefNum);
    end
    xBPM=zeros(numel(pv),nVal);
    stat=zeros(numel(pv),1);
    if any(isFACET)
        nAcq=ceil(nVal/100);
        nSam=min(nVal,100);
        [x,y,tmit]=deal(zeros(numel(static.bpmList),nAcq*nSam));
        for j=1:nAcq
            id=(1:nSam)+(j-1)*100;
            [x(:,id),y(:,id),tmit(:,id)]=control_bpmAidaGet(static.bpmList,nSam);
        end
        x(:,nVal+1:end)=[];y(:,nVal+1:end)=[];tmit(:,nVal+1:end)=[];
        xBPM=reshape(permute(cat(3,x,y),[3 1 2]),[],nVal);
        tmit=reshape(permute(cat(3,tmit,tmit),[3 1 2]),[],nVal);
    end
    if any(isSLC & ~isFACET)
        for j=1:nVal
            xBPM(isSLC,j)=lcaGet(pv(isSLC))*1e-3;
            tmit(isSLC,j)=lcaGet(pvT(isSLC));
            pause(2.);
        end
    end
    nTry=300;if any(isFACET), nTry=0;end
    while nTry && ~eDefDone(opts.eDefNum), nTry=nTry-1;pause(.2);end

    hst=['HST' num2str(opts.eDefNum)];
    pvHst=strcat(pv(:),hst);
    pvTHst=strcat(pvT(:),hst);
    xBPM(~isSLC,:)=lcaGetSmart(pvHst(~isSLC),nVal)*1e-3;
    tmit(~isSLC,:)=lcaGetSmart(pvTHst(~isSLC),nVal);
    stat(~isSLC)=lcaGetSmart(pvStat(~isSLC),0,'double');
    xBPM(logical(stat),:)=NaN; % Flag invalid status
    xBPM(tmit < 1e7)=NaN; % Flag low TMIT on individual samples
    xMeas=reshape(xBPM,2,[],nVal);
    opts.tmit = 1;
    if opts.tmit
        %xMeas(3,:,:)=tmit(1:2:end,:);
        xtmit=tmit(1:2:end,:);
    end
    return
end

% Simulation mode

% Initial launch.
beamJitt=opts.beamJitt*1e-6;
beamEnerJitt=opts.beamEnerJitt*1e-4;
if epicsSimul_status
    beamJitt=ones(2,1)*beamJitt(:);
end

xInit0=[eye(2,3);eye(2,3);[0 0 1]]*[beamJitt(:);beamEnerJitt]*opts.useBeamJitt;

% Get corrector strengths and stray fields.
nCorr=length(static.corrList);
bDes=bba_corrGet(static,appMode);
bDes=bDes(:)+strayB(:);bDes(isnan(bDes))=0;
corrNoise0=opts.corrNoise(:)*1e-6*opts.useCorrNoise;
corrNoise0(1:2*nCorr,1)=corrNoise0(1:end);

% BPM noise.
nBPM=length(static.bpmList);
bpmNoise0=opts.bpmNoise(:)*1e-6*opts.useBPMNoise;
bpmNoise0(1:2*nBPM,1)=bpmNoise0(1:end);

% Get BPM noise.
bpmNoise=randn(2*nBPM,nVal).*repmat(bpmNoise0,1,nVal);

% Get Corr noise.
corrNoise=randn(2*nCorr,nVal).*repmat(corrNoise0,1,nVal);
corr0=repmat(bDes,1,nVal)+corrNoise;

% Initial conditions and offsets vector.
uOff=undOff;uFI=[];dB=[];
if isfield(static,'numR')
    if static.numR.FI, uFI=undFI;end
    if static.numR.drift, dB=driftB;end
end
%uPos=control_magnetGet(static.undList,'TMXPOSC')'*epicsSimul_status; % Only do on a PC.
%uOff=uOff+1e-5*[15;-5;-7;10]*((uPos > 0 & uPos < 70).*(80-uPos)/30); % [kG-m^2 kG-m]
xPar=[repmat([quadOff(:);bpmOff(:);uOff(:)],1,nVal);corr0;repmat([uFI(:);dB(:)],1,nVal)];

% Get initial launch.
nInit=4+mod(size(R,2),2);
xInit(end+1:nInit)=0;
xI=xInit;
xInitNoise=randn(nInit,nVal).*repmat(xInit0(1:nInit),1,nVal);

% Get initial condition for flat orbit.
xIdeal=lscov(R(7:end-2,1:nInit),-R(7:end-2,nInit+1:end)*xPar(:,1));
if opts.useSteer, xI=xIdeal;end

% Get beam jitter.
x0=repmat(xI,1,nVal)+xInitNoise;

xPar=[x0;xPar];
xPar(isnan(xPar))=0;

% Calculate orbit.
x=R*xPar+bpmNoise;

% Apply BPM scale & roll error.
scale=diag(kron(1+bpmScale,[1 1]));
roll1=kron(sind(bpmRoll),[1 0]);
roll=diag(kron(cosd(bpmRoll),[1 1]))+diag(roll1(1:end-1),1)-diag(roll1(1:end-1),-1);
x=scale*roll*x;

if epicsSimul_status
    %    pvOff=[strcat(pvList(:),':XAOFF') strcat(pvList(:),':YAOFF')]';
    %    off=lcaGet(strcat(pvOff(:)));
    %    lcaPut(pvOff(:),xMeas(:)*1e3+off);
    lcaPut(pv(:),x(:,end)*1e3);
end
xMeas=reshape(x,2,[],nVal);
opts.tmit = 1;
if opts.tmit
    %xMeas(3,:,:)=9.38e8;
    xtmit=9.38e8;
end
