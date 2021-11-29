function static = bba2_init(varargin)
%BBA_INIT
%  STATIC = BBA_INIT(OPTS) initializes STATIC structure with device name
%  and z position lists for BPMs, quads, correctors & undulators. Option
%  'sector' specifies accelerator region and 'noEPlusCorr' excludes the
%  positron correctors in L3.

% Features:

% Input arguments:
%    OPTS: Options
%          SECTOR:      Default 'UND', accepts any items specified in
%                       model_nameRegion()
%          NOEPLUSCORR: Excludes L3 positron correctors, default off
%          NOSLC:       Excludes SLC controlled BPMs, default off

% Output arguments:
%    STATIC: Struct with fiels for device names and z positions
%            BPMLIST:  Names of BPMs
%            QUADLIST: Names of QUADs
%            CORRLIST: Names of CORRs
%            UNDLIST:  Names of UNDs
%            BENDLIST: Names of BENDs
%            EFCORRLIST: Names of UNDs Environmental Correctors
%            ZBPM: Z positions of BPMs
%            ZQUAD: Z positions of quads
%            ZCORR: Z positions of correctors
%            ZUND: Z positions of undulators
%            LUND: Effective lengths of undulators

% Compatibility: Version 7 and higher
% Called functions: model_nameRegion, model_nameConvert, util_parseOptions,
%                   model_nameSplit, model_init, model_rMatGet

% Author: Henrik Loos, SLAC, Modified Alberto Lutman

% --------------------------------------------------------------------

% Set defaults.
optsdef=struct( ...
    'sector','UND', ...
    'noEPlusCorr',0, ...
    'noSLC',0, ...
    'devList',{{'BPMS' 'QUAD' 'XCOR' 'YCOR'}}, ...
    'refDev',[], ...
    'beampath', 'CU_HXR', ...
    'sortZ',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Get list of BPMs, quads, correctors and undulators.
devList0={'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'BEND' 'PHAS' 'XEFC' 'YEFC' 'BTRM'};
isUnd=all(ismember(opts.sector,{'UND' 'UNDOld'})) | all(strncmp(opts.sector,'UND1',4));
if isUnd, opts.devList(strcmp(opts.devList,'YCOR'))={'USEG'};end

[nameListEpics,is,isSLC]=model_nameRegion(opts.devList,opts.sector);
nameList=model_nameConvert(nameListEpics,'MAD');

[d,id]=ismember(devList0,opts.devList);id(~id)=-1;

% Exclude offline and pulsed BSY correctors.
is(ismember(nameList,{'XCBSY26' 'XCBSY36' 'XCBSY71' 'XCBSY81' 'YCBSY27' 'YCBSY37' 'YCBSY72' 'YCBSY82'}))=0;

% Use opts.sector as nameList if nothing found.
if isempty(nameList)
    nameList=reshape(cellstr(opts.sector),[],1);
    [nameListEpics,d,isSLC]=model_nameConvert(nameList);
    is=zeros(size(nameList));
    is(strncmp(nameList,'B',1) | strncmp(nameList,'R',1) | strncmp(nameList,'W',1))=id(1); %this may need change!
    is(strncmp(nameList,'Q',1))=id(2);
    is(strncmp(nameList,'X',1))=id(3);
    is(strncmp(nameList,'Y',1))=id(4);
    is(strncmp(nameList,'U',1))=id(5);
end

% Exclude SLC BPMs is selected.
if opts.noSLC, is(is == id(1) & isSLC)=0;end

% Remove positron correctors if selected.
[p,m,u]=model_nameSplit(nameListEpics);
if opts.noEPlusCorr
    u=floor(reshape(str2num(char(u)),[],1)/100);
    useM=ismember(m,{'LI22' 'LI23' 'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30'});
    useM=useM |strcmp(m,'LI24') & u < 6;
    useX=strcmp(p,'XCOR') & mod(u,2) & ~strcmp(nameList,'XC30900');
    useY=strcmp(p,'YCOR') & ~mod(u,2);
    is(useM & (useX | useY))=0;
end

% Use XAL model if any device in LI**, Matlab otherwise.
model_init('source','MATLAB','online',0);
if any(strncmp([p;m],'LI',2)) && ~epicsSimul_status && ~any(strncmp([p;m],'LI0',3)) && ~any(strncmp([p;m],'LI1',3))
%    model_init('source','EPICS','online',1);
end
if any(strncmp([p;m],'LI0',3)) || any(strncmp([p;m],'LI1',3))
    model_init('source','SLC','online',1);
end

%{
% Remove items upstream of refDev.
if isempty(opts.refDev), refDev=nameList(find(is == 1,1));
else refDev=opts.refDev;
    if ~any(strcmp(nameList,refDev))
        nameList=[nameList;cellstr(refDev)];
        is=[is;5];
    end
end
%}

BEAMPATH=['BEAMPATH=',opts.beampath];

% Get z positions and undulator lengths.
z=model_rMatGet(nameList,[],{'TYPE=DESIGN',BEAMPATH},'Z'); l=zeros(1,0);
l=model_rMatGet(nameList,[],{'TYPE=DESIGN',BEAMPATH},'LEFF');

%{
% Remove items upstream of refDev.
refDev=nameList(find(is == 1,1));
z0=z(strcmp(nameList,refDev));
is(z < z0)=0;
%}

% Put everything into struct.
static.bpmList=nameList(is == id(1));
static.quadList=nameList(is == id(2));
%static.corrList=nameList(is == id(3) | is == id(4) | is == id(6));
static.corrList=nameList(is == id(3) | is == id(4));
static.bendList=nameList(is == id(6));
static.phasList=nameList(is == id(7));
static.efcorrList=nameList(is == id(8) | is == id(9));
static.undList=nameList(is == id(5));
static.btrimList=nameList(is==id(10));

static.bpmList_e=nameListEpics(is == id(1));
static.quadList_e=nameListEpics(is == id(2));
%static.corrList=nameList(is == id(3) | is == id(4) | is == id(6));
static.corrList_e=nameListEpics(is == id(3) | is == id(4));
static.bendList_e=nameListEpics(is == id(6));
static.phasList_e=nameListEpics(is == id(7));
static.efcorrList_e=nameListEpics(is == id(8) | is == id(9));
static.undList_e=nameListEpics(is == id(5));
static.btrimList_e=nameListEpics(is==id(10));

static.zBPM=z(is == id(1));
static.zQuad=z(is == id(2));
%static.zCorr=z(is == id(3) | is == id(4) | is == id(6));
static.zCorr=z(is == id(3) | is == id(4));
static.zBend=z(is == id(6));
static.zPhas=z(is == id(7));
static.zEfcorr=z(is == id(8) | is == id(9));
static.zUnd=z(is == id(5));
static.zBtrim=z(is==id(10));

static.lBPM=l(is == id(1));
static.lQuad=l(is == id(2));
%static.zCorr=z(is == id(3) | is == id(4) | is == id(6));
static.lCorr=l(is == id(3) | is == id(4));
static.lBend=l(is == id(6));
static.lPhas=l(is == id(7));
static.lEfcorr=l(is == id(8) | is == id(9));
static.lUnd=l(is == id(5));
static.lBtrim=l(is==id(10));

if(opts.sortZ)
    if(~isempty(static.zBPM))
        [~,zOrder]=sort(static.zBPM,'ascend');
        static.bpmList=static.bpmList(zOrder);
        static.bpmList_e=static.bpmList_e(zOrder);
        static.lBPM=static.lBPM(zOrder);
        static.zBPM=static.zBPM(zOrder);
    end
    if(~isempty(static.zQuad))
        [~,zOrder]=sort(static.zQuad,'ascend');
        static.quadList=static.quadList(zOrder);
        static.quadList_e=static.quadList_e(zOrder);
        static.lQuad=static.lQuad(zOrder);
        static.zQuad=static.zQuad(zOrder);
    end
    if(~isempty(static.zCorr))
        XorY=cellfun(@(x) x(1),static.corrList);
        xPos=find(XorY=='X'); yPos=find(XorY=='Y');
        [~,zxOrder]=sort(static.zCorr(xPos),'ascend');
        [~,zyOrder]=sort(static.zCorr(yPos),'ascend');
        static.corrList=[static.corrList(xPos(zxOrder));static.corrList(yPos(zyOrder))];
        static.corrList_e=[static.corrList_e(xPos(zxOrder));static.corrList_e(yPos(zyOrder))];
        static.lCorr=[static.lCorr(xPos(zxOrder)),static.lCorr(yPos(zyOrder))];
        static.zCorr=[static.zCorr(xPos(zxOrder)),static.zCorr(yPos(zyOrder))];
    end
    if(~isempty(static.zBend))
        [~,zOrder]=sort(static.zBend,'ascend');
        static.bendList=static.bendList(zOrder);
        static.bendList_e=static.bendList_e(zOrder);
        static.lBend=static.lBend(zOrder);
        static.zBend=static.zBend(zOrder);
    end
    if(~isempty(static.zPhas))
        [~,zOrder]=sort(static.zPhas,'ascend');
        static.phasList=static.phasList(zOrder);
        static.phasList_e=static.phasList_e(zOrder);
        static.lPhas=static.lPhas(zOrder);
        static.zPhas=static.zPhas(zOrder);
    end
    if(~isempty(static.zUnd))
        [~,zOrder]=sort(static.zUnd,'ascend');
        static.undList=static.undList(zOrder);
        static.undList_e=static.undList_e(zOrder);
        static.lUnd=static.lUnd(zOrder);
        static.zUnd=static.zUnd(zOrder);
    end
    if(~isempty(static.zEfcorr))
        XorY=cellfun(@(x) x(1),static.efcorrList);
        xPos=find(XorY=='X'); yPos=find(XorY=='Y');
        [~,zxOrder]=sort(static.zEfcorr(xPos),'ascend');
        [~,zyOrder]=sort(static.zEfcorr(yPos),'ascend');
        static.efcorrList=[static.efcorrList(xPos(zxOrder));static.efcorrList(yPos(zyOrder))];
        static.efcorrList_e=[static.efcorrList_e(xPos(zxOrder));static.efcorrList_e(yPos(zyOrder))];
        static.lEfcorr=[static.lEfcorr(xPos(zxOrder)),static.lEfcorr(yPos(zyOrder))];
        static.zEfcorr=[static.zEfcorr(xPos(zxOrder)),static.zEfcorr(yPos(zyOrder))];
    end
    
    static.corrRange(:,1)=lcaGetSmart(strcat(static.corrList_e,':BMIN'));
    static.corrRange(:,2)=lcaGetSmart(strcat(static.corrList_e,':BMAX'));
    static.quadRange(:,1)=lcaGetSmart(strcat(static.quadList_e,':BMIN'));
    static.quadRange(:,2)=lcaGetSmart(strcat(static.quadList_e,':BMAX'));
end
