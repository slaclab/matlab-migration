function static = bba_simulInit(varargin)

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit girdPos
global strayB quadErr bpmScale bpmRoll undFI driftB

optsdef=struct( ...
    'useBPMOff',0, ...
    'useBPMScale',0, ...
    'useBPMRoll',0, ...
    'useQuadOff',0, ...
    'useQuadErr',0, ...
    'useUndOff',0, ...
    'useGirdOff',0, ...
    'useGirdSlope',0, ...
    'useLaunch',1, ...
    'useUnd',1, ...
    'useStray',0, ...
    'useUndFI',1, ...
    'useDriftB',0, ...
    'bpmOff',50, ... % um
    'bpmScale',1, ... % (%)
    'bpmRoll',1, ... % Deg
    'quadOff',100, ... % um
    'quadErr',1, ... % (%)
    'undOff',100, ...% um
    'girdOff',[100 -200], ...% um
    'girdSlope',[1000 500], ... % um/100m
    'launch',[30 -2 -20 -3], ... % [um urad um urad]
    'strayB',1e-3, ...
    'undFI',[10 14], ... % [uTm uTm^2]
    'driftB',[18 -38], ... % uT
    'sector','UND', ...
    'devList',{{'BPMS' 'QUAD' 'XCOR' 'YCOR'}}, ...
    'noEPlusCorr',0, ...
    'noSLC',0 ...
    );
%    'devList',{{'BPMS' 'QUAD' 'XCOR' 'YCOR' 'TORO' 'VVPG'}}, ...

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

lcaPutSmart('SIOC:SYS0:ML00:AO877',opts.useUnd);

static=bba_init(opts);

nQuad=length(static.quadList);
nGird=length(static.undList);
nBPM=length(static.bpmList);
nUnd=length(static.undList);
zBPM=static.zBPM;
zQuad=static.zQuad;
zUnd=static.zUnd;
lUnd=static.lUnd;

girdSlope=opts.girdSlope(:)*1e-6/100*opts.useGirdSlope;
girdOff=opts.girdOff(:)*1e-6*opts.useGirdOff;
zBeg=zBPM(min(end,3));
z1=(zBPM-zBeg).*(zBPM > zBeg);
bpmDrift=girdSlope*z1+girdOff*(zBPM*0+1);
quadDrift=girdSlope*(zQuad-zBeg)+girdOff*(zQuad*0+1);
undDrift=girdSlope*(zUnd-lUnd/2-zBeg)+girdOff*(zUnd*0+1);
undDriftE=girdSlope*(zUnd+lUnd/2-zBeg)+girdOff*(zUnd*0+1);

% Quad offsets.
quadOff=opts.quadOff*1e-6*opts.useQuadOff;
quadOff=quadDrift+randn(2,nQuad)*quadOff;%+[1e-3;.5e-3]*sin((1:nGird)*2*pi/nGird);

% BPM offsets.
bpmOff=opts.bpmOff*1e-6*opts.useBPMOff;
bpmOff=bpmDrift+randn(2,nBPM)*bpmOff;

% Und offsets and angles.
undOff=opts.undOff*1e-6*opts.useUndOff;
undOffE=undDriftE+randn(2,nUnd)*undOff;
undOff=undDrift+randn(2,nUnd)*undOff;

undAngle=(undOffE-undOff)./[lUnd;lUnd];
undOff=[undOff(1,:);undAngle(1,:);undOff(2,:);undAngle(2,:)];

% Set offsets of zero-length undulators to 0.
undOff(:,~lUnd)=0;

% Field integrals.
undFI=opts.undFI*1e-6*10*opts.useUndFI; % [kGm kGm^2]
undFI=randn(4,nUnd).*repmat(undFI([1 2 1 2])',1,nUnd);

% Gird position.
girdPos=zeros(4,nGird); %[xBeg;yBeg;xEnd;yEnd]

% Initial launch.
xInit=opts.launch(:)*1e-6*opts.useLaunch;

% Corrector strengths.
bba_setCorr(static,0,0,'init',1);

% Stray field strength.
strayB=corrB*0+randn(size(corrB))*opts.strayB*opts.useStray;

% Quad strength errors.
quadErr=opts.quadErr/100*opts.useQuadErr;
quadErr=randn(1,nBPM)*quadErr;

% BPM scale errors.
bpmScale=opts.bpmScale/100*opts.useBPMScale;
bpmScale=randn(1,nBPM)*bpmScale;

% BPM roll errors.
bpmRoll=opts.bpmRoll*opts.useBPMRoll;
bpmRoll=randn(1,nBPM)*bpmRoll;

% Get drift lengths.
[zAll,id]=sort([zQuad zBPM zUnd static.zCorr]);id(~zAll)=[];
lAll=[zQuad*0 zBPM*0 lUnd static.zCorr*0];
zDrift=zAll(~~zAll);
lAll=lAll(id);
zB=zDrift-lAll/2;
zE=zDrift+lAll/2;
lDrift=zB(2:end)-zE(1:end-1);
nDrift=sum(lDrift > 0);

% Drift fields.
driftB=opts.driftB*1e-6*10*opts.useDriftB; % kG
driftB=repmat(driftB',1,nDrift);
%driftB=driftB.*randn(2,nDrift);
