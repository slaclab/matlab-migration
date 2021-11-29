function bba_girdMove(static, quadDelta, appMode, varargin)
%BBA_GIRDMOVE
%  BBA_GIRDMOVE(STATIC, QUADDELTA, APPMODE, OPTS) moves undulator girder
%  quad ends based on STATIC struct by QUADDELTA. Simulation mode is
%  determined by APPMODE.

% Features:

% Input arguments:
%    STATIC:    As created by BBA_INIT
%    QUADDELTA: Quad end movements
%    APPMODE:   Production mode (1 production, 0 simulation)
%    OPTS:      Options struct

% Output arguments: none

% Compatibility: Version 2007b, 2012a
% Called functions: util_parseOptions, girderGeo, girderAxisFind,
%                   girderAxisMove, girderCamWait, model_nameConvert,
%                   lcaGet, lcaPut

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

% Real positions of quads, BPMs, undulators, and beam
global quadOff undOff bpmOff corrB xInit girdPos

% Set default options.
optsdef=struct( ...
    'useGirdBack',1, ...
    'girdBack',4, ... % um
    'init',1);

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

nGird=length(static.quadList);
zBPM=static.zBPM;
zQuad=static.zQuad;
zUnd=static.zUnd;
lUnd=static.lUnd;

% Calc gird motion from quad movement.
lGird=lUnd(1); % Distance between pivot points on girder
zGird=zUnd;
pQuad=zQuad-zGird; % Distance from girder center to quad;
uBPM=find(zBPM > zUnd(1),1)-1+(1:nGird); % BPMs within undulator
pBPM=zBPM(uBPM)-zGird; % Distance from gider center to BPM;
pUndB=zUnd-lUnd/2-zGird; % Distance from girder center to und beg;
pUndE=zUnd+lUnd/2-zGird; % Distance from girder center to und end;
dGird=lGird/(lGird/2+pQuad(1))*quadDelta;

% Add girder backlash.
dGirdAct=dGird+opts.girdBack*1e-6*(rand(size(dGird))-.5)*opts.useGirdBack.*(dGird ~= 0);
dGirdAct=[dGirdAct*0;dGirdAct]; % Move only end of girder
dGird=[dGird*0;dGird]; % Move only end of girder
girdPos=girdPos+dGirdAct;

% Move quads by actual amount.
quadOff=quadOff+1/lGird*kron(pQuad(1)*[-1 1]+lGird/2,eye(2))*dGirdAct;

% Move BPMs by actual amount and correct BPM offset by assumed amount.
bpmOff(:,uBPM)=bpmOff(:,uBPM)+1/lGird*kron(pBPM(1)*[-1 1]+lGird/2,eye(2))*(dGirdAct-dGird);

% Undulator offset,angle -> offsets
undOff=kron(eye(2),[1 0;1 lUnd(1)])*undOff;
undOff=undOff([1 3 2 4],:);

% Move undulator beg and end by actual amount.
undOff(1:2,:)=undOff(1:2,:)+1/lGird*kron(pUndB(1)*[-1 1]+lGird/2,eye(2))*dGirdAct;
undOff(3:4,:)=undOff(3:4,:)+1/lGird*kron(pUndE(1)*[-1 1]+lGird/2,eye(2))*dGirdAct;

% Undulator offsets -> offset,angle
undOff=undOff([1 3 2 4],:);
undOff=kron(eye(2),[1 0;-1/lUnd(1) 1/lUnd(1)])*undOff;

if appMode
    % Move girders
    geo=girderGeo;
    [posBPM0,posQuad]=girderAxisFind(1:nGird,geo.bpmz,geo.quadz);
    bfwDelta=interp1(zQuad',quadDelta',zQuad'-geo.quadz*1e-3+geo.bfwz*1e-3,[],0)';
    girderAxisMove(1:nGird,[bfwDelta'*1e3 repmat(geo.bfwz,nGird,1)],[quadDelta'*1e3 repmat(geo.quadz,nGird,1)]);
    girderCamWait(1:nGird);
    cData=[static.quadList num2cell([posQuad(:,1:2) posQuad(:,1:2)+quadDelta'*1e3])]';
    disp('Quad Pos  Old x    Old Y    New X    New Y');
    disp(sprintf('%-6s %8.3f %8.3f %8.3f %8.3f\n',cData{:}));

    % Save present TAPER XACT into POS1 slot
    undPV=model_nameConvert(cellstr(num2str((1:nGird)','US%02d')));
    xAct=lcaGet(strcat(undPV,':XACT'));
    lcaPut(strcat(undPV,':TMXSVDPOS1'),xAct);
    lcaPut(strcat(undPV,':TMXPOS1DESC'),'Last BBA Position, don''t touch!');
end
