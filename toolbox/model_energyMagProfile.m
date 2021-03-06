function static = model_energyMagProfile(static, region, varargin)
%MODEL_ENERGYMAGPROFILE
% STATIC = MODEL_ENERGYMAGPROFILE(STATIC, REGION, OPTS) Acquires klystron amplitudes
% and phases and computes the fudged energy profile. The flag INIT
% indicates to only obtain static klystron information.

% Features:

% Input arguments:
%    STATIC: Structure, default is [] to get fields from
%            MODEL_ENERGYPROFILE and initialize additional fields
%            MAGNET:
%                    NAME:   Names of magnets in region
%                    Z:      Z-location of magnets
%                    LEFF:   Effective length of magnets
%                    KDES:   Design focusing strength of magnets
%                    BETA:   Beta functions at magnets [X Y] array
%                    REGION: String(s) indicating regions for data used
%    REGION: Optional parameter for accelerator areas, e.g. 'L2', default 'LCLS'
%    OPTS:   Options
%            DOPLOT: Default 1, if 1, produce LEM plot
%            FIGURE: Default 4, figure number for plot
%            AXES:   Default {4 1}, subplot pattern for plot or axes handles
%            COLOR:  Default [], if not empty, plot CUD style
%            UPDATE: Default 1, if 1 update EACT PVs
%            GETSCP: Default 0, if 1 read SCP klystron phases
%            INIT:   Default 0, if 1 only obtain static information

% Output arguments:
%    STATIC: Structure same as input argument STATIC with fields from
%            MODEL_ENERGYPROFILE and added fields
%            MAGNET:
%                    BDES: BDES of magnets
%                    EDES: EDES of magnets
%                    EACT: EACT of magnets
%                    KACT: Actual focusing strength of magnets
%                    BMAG: Beta mismatch of magnets [X Y] array

% Compatibility: Version 7 and higher
% Called functions: util_parseOptions, model_energyProfile,model_nameConvert,
%                   model_nameRegion, model_rMatGet, control_magnetGet,
%                   model_k1Get, control_energyNames, lcaPutSmart, util_plotInit

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'doPlot',1, ...
    'figure',4, ...
    'axes',{{4 1}}, ...
    'color',[], ...
    'update',1, ...
    'getSCP',0, ...
    'init',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 1, static=[];end
if nargin < 2, region=[];end
if isempty(region), region='LCLS';end
region=cellstr(region);

if any(ismember({'FACET' 'LI02_LI10' 'LI11_LI20' 'LI20'},region))
    static=model_energyProfile(static,opts.init,'getSCP',opts.getSCP,'region','FACET');
else
    static=model_energyProfile(static,opts.init,'getSCP',opts.getSCP,'region', region);
end

if ~isfield(static,'magnet') || ~isequal(static.magnet.region,region)

    names=model_nameRegion([],region,'LEM',1);
    [p,m]=model_nameSplit(names);
    isT=any(ismember([p m],{'BTRM' 'QTRM'}),2);
    names=model_nameConvert(names,'MAD');

    % Get design model.
    [z,lEff,k1,k,phix,betax,betay]=deal(zeros(numel(names),1));
    [r,z(~isT),lEff(~isT),twiss]=model_rMatGet(names(~isT),names(~isT),{'POS=BEG' 'POSB=END' 'TYPE=DESIGN' strcat('BEAMPATH=',region{:})});

    % Fix BTRM Z position.
    [isB,idB]=ismember(names,regexprep(names(isT),'_TRIM$',''));
    idT=find(isT);z(idT(idB(isB)))=z(isB);

    % Get design quad strength.
    phix(~isT)=acos(squeeze(r(1,1,:)));
    k1=real((phix./lEff).^2);

    % Get design bend strength.
    isB=strncmp(names,'B',1) & ~isT;
    psi=atan2(-r(3,6,:),r(1,6,:));s=-abs(sin(psi));c=abs(cos(psi)); % -90 <= psi <= 0
    k(~isT)=squeeze(2*(c.*r(1,6,:)-s.*r(3,6,:))./((c.*r(1,6,:)-s.*r(3,6,:)).^2+((c.^2.*r(1,2,:)+s.^2.*r(3,4,:))./(c.^2-s.^2)).^2));
    k1(isB)=abs(k(isB));

    % Set strength to 0 for zero length.
    k1(~lEff)=0;

    % Beta functions
    betax(~isT)=twiss(3,:);betay(~isT)=twiss(8,:);
%    beta=sqrt(prod([betax betay]));
%    k(~isT)=model_rMatModel(names(~isT),[],[],'K',1,'design',1);
%    disp([names num2cell([k1 k'])]);

    static.magnet=struct( ...
        'name',{names},'z',z,'lEff',lEff,'kDes',k1,'beta',[betax betay],'region',{region});
end

if opts.init, return, end

[d,bDes,d,eDes]=control_magnetGet(static.magnet.name);
eAct=interp1(static.prof.z,static.prof.eAct,static.magnet.z, 'previous');

%L3 and LTUH/S may have different EDES in 2020
switch static.magnet.region{:}
    case 'CU_HXR', ltuEdes = lcaGet('REFS:DMPH:400:EDES');
    case 'CU_SXR', ltuEdes = lcaGet('REFS:DMPS:400:EDES');
end
clthEnd =  model_rMatGet('ENDCLTH_1',[],[],'Z');
eAct(static.magnet.z > clthEnd) = ltuEdes;
%plot(static.magnet.z, eAct,'o')  

bDesT=bDes;

kAct=model_k1Get(bDesT,static.magnet.lEff',eAct')';
bMagX=1+.5*((kAct-static.magnet.kDes).*static.magnet.lEff.*static.magnet.beta(:,1)).^2;
bMagY=1+.5*((kAct-static.magnet.kDes).*static.magnet.lEff.*static.magnet.beta(:,2)).^2;

static.magnet.bDes=bDes;
static.magnet.eDes=eDes;
static.magnet.eAct=eAct;
static.magnet.kAct=kAct;
static.magnet.bMag=[bMagX bMagY];

if opts.update && ~ismember('FACET',region)
    name=control_energyNames(static.magnet.name);
    lcaPutSmart(strcat(name,':EACT'),static.magnet.eAct);
end

if opts.doPlot, model_energyMagPlot(static,opts);end


function model_energyMagPlot(static, opts)

col='k';if ~isempty(opts.color), col='w';opts.axes={5 1};end
if strcmp(opts.color,'f'), opts.axes={2 1};end
[hAxes,hFig]=util_plotInit(opts);iAx=1;

names=static.magnet.name;
magZ=static.magnet.z;
eDes=static.magnet.eDes;
eAct=static.magnet.eAct;
bMag=1+sqrt((static.magnet.bMag(:,1)-1).*(static.magnet.bMag(:,2)-1));
isBend=strncmp(model_nameConvert(names),'BEND',4);
isQuad=strncmp(names,'Q',1);
isCorr=strncmp(names,'X',1) | strncmp(names,'Y',1);
opts.units='MeV';opts.lim=magZ;
plotError(magZ(isQuad),eAct(isQuad),eDes(isQuad),hAxes(iAx),'Quad',opts);iAx=iAx+1;
if numel(hAxes) > 2
    plotError(magZ(isBend),eAct(isBend),eDes(isBend),hAxes(iAx),'Bend',opts);iAx=iAx+1;
    plotError(magZ(isCorr),eAct(isCorr),eDes(isCorr),hAxes(iAx),'Corr',opts);iAx=iAx+1;
opts.units='';
plotError(magZ(isQuad),bMag(isQuad)*1e-3,0,hAxes(iAx),'BMAG',opts);iAx=iAx+1;
end
title(hAxes(1),['Energy Error Profile ' static.magnet.region{:} ' ' datestr(now)],'Color',col);
str=[static.klys.region num2cell([static.klys.fudgeAct static.klys.fudgeDes])]';
str=['Fudge Act   Last' sprintf('\n%s    %6.3f %6.3f',str{:,~strcmp(str(1,:),'')})];
if ~isempty(opts.color)
    opts.units='GeV';
    plotError(static.klys.zEnd',(static.prof.eAct(1)+cumsum(static.klys.gainF))*1e-3,0,hAxes(iAx),'Klys',opts);
    set(hAxes(iAx),'XLim',get(hAxes(1),'XLim'));
    set(hFig,'Color','k','MenuBar','none');
end
text(.2,.9,str,'Parent',hAxes(2),'Units','normalized','VerticalAlignment','top','Color',col);
set(hAxes(2:end),'XLim',get(hAxes(1),'XLim'));
set(hAxes(end),'XTickLabelMode','auto');
util_marginSet(hFig,[.12 .05],[.12 0.03*ones(1,numel(hAxes)-1) .08]);


function plotError(z, eAct, eRef, ax, lab, opts)

col='k';if ~isempty(opts.color), col='w';end
plot(ax,z(~~z),z(~~z)*0,col);
if ~isempty(z), xlim(ax,[0 1.1*max(z)]);end
hold(ax,'on');
colList=get(ax,'ColorOrder');
delta=eAct-eRef;
good=abs(delta./eRef) < 5e-3 & z;
bad=~good & z;
if ~strcmp(opts.units,'MeV'), good=z > 0;bad=~good;end
stem(ax,z(good),delta(good)*1e3,'.','Color',colList(2,:),'ShowBaseLine','off');
hold(ax,'on');
h=stem(ax,z(bad),delta(bad)*1e3,'.r','ShowBaseLine','off');
plot(ax,opts.lim,opts.lim*0,col);
set(h,'ShowBaseLine','off');
if isempty(opts.units)
    set(get(h,'BaseLine'),'BaseValue',1);
    plot(ax,opts.lim,opts.lim*0+1,col);
    yLim=get(ax,'YLim');set(ax,'YLim',[1 max(1.1,yLim(2))]);
end
hold(ax,'off');
ylabel(ax,[lab ' (' opts.units ')']);
set(ax,{'XColor' 'YColor'},{col col});
col='w';if ~isempty(opts.color), col='k';end
set(ax,'Color',col,'XTickLabel','');
