function varargout = SXRSS_corrPlot_gui(varargin)
% SXRSS_CORRPLOT_GUI M-file for SXRSS_corrPlot_gui.fig
%      SXRSS_corrPlot_GUI, by itself, creates a new SXRSS_corrPlot_GUI or raises the existing
%      singleton*.
%
%      H = SXRSS_corrPlot_GUI returns the handle to a new SXRSS_corrPlot_GUI or the handle to
%      the existing singleton*.
%
%      SXRSS_corrPlot_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SXRSS_corrPlot_GUI.M with the given input arguments.
%
%      SXRSS_corrPlot_GUI('Property','Value',...) creates a new SXRSS_corrPlot_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SXRSS_corrPlot_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SXRSS_corrPlot_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SXRSS_corrPlot_gui

% Last Modified by GUIDE v2.5 29-Sep-2014 17:02:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SXRSS_corrPlot_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SXRSS_corrPlot_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SXRSS_corrPlot_gui is made visible.
function SXRSS_corrPlot_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SXRSS_corrPlot_gui (see VARARGIN)

% Choose default command line output for SXRSS_corrPlot_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SXRSS_corrPlot_gui wait for user response (see UIRESUME)
% uiwait(handles.SXRSS_corrPlot_gui);


% --- Outputs from this function are returned to the command line.
function varargout = SXRSS_corrPlot_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close SXRSS_corrPlot_gui.
function SXRSS_corrPlot_gui_CloseRequestFcn(hObject, eventdata, handles)

gui_BSAControl(hObject,handles,0);
util_appClose(hObject);


% ------------------------------------------------------------------------
function data = appRemote(hObject, configName, doSave)

% Find (or launch) application.
[hObject,handles]=util_appFind('SXRSS_corrPlot_gui');

% Load config file.
handles.process.saved=1;
handles=appLoad(hObject,handles,configName);

% Start acquisition.
handles=acquireStart(hObject,handles);
data=handles.data;
handles.process.saved=1;
guidata(hObject,handles);

% Save if requested.
if nargin > 2 && doSave
    dataSave(hObject,handles,0);
end


% ------------------------------------------------------------------------
function data = appQuery(hObject)

[hObject,handles]=util_appFind('SXRSS_corrPlot_gui');
data=handles.data;


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

[sys, accelerator] = getSystem();
handles.accelerator=accelerator;

% List of profile monitors
switch accelerator
    case 'NLCTA'
        handles.profmonList={ ...
            '13PS10:cam1' '13PS4:cam1' '13PS2:cam1' '13PS9:cam1' '13PS5:cam1' ...
            'BASL3:cam1'  'BASL4:cam1' '13PS11:cam1' '13PS12:cam1' '13PS1:cam1' ...
            '13PS8:cam1' '13PS7:cam1'  '13PS6:cam1'};
        handles.profmonMap=0:13;
    case {'XTA' 'ASTA'}
        handles.profmonList={...
            'YAGS:XT01:150' 'YAGS:XT01:550' 'YAGS:XT01:950' 'OTR:XT01:250' ...
            'OTR:XT01:350' 'ILL:XT01:1' 'VIS:XT01:10' 'VIS:XT01:26' ...
            'VCC:XT01:49' ...
            'TDS:XT01:WF:CH0:TRACE' 'TDS:XT01:WF:CH1:TRACE' ...
            'TDS:XT01:WF:CH2:TRACE' 'TDS:XT01:WF:CH3:TRACE' ...
            'VCC:AS01:186' 'VIS:AS01:2' 'YAGS:AS01:3'};
        handles.profmonMap=[0 1 4 5 2 3 6:10 11:13];
        if strcmp(accelerator,'ASTA'), handles.profmonMap=[0 14:16];end
    otherwise
        handles.profmonList={ ...
            'CAMR:IN20:186'  'YAGS:IN20:211'  'YAGS:IN20:841'  'YAGS:IN20:241' ...
            'YAGS:IN20:351'  'YAGS:IN20:465'  'OTRS:IN20:541'  'OTRS:IN20:571' ...
            'OTRS:IN20:621'  'OTRS:IN20:711'  'YAGS:IN20:921'  'YAGS:IN20:995' ...
            'OTRS:IN20:997'  'OTRS:LI21:237'  'OTRS:LI21:291'  'OTRS:LI24:807' ...
            'OTRS:LI25:342'  'OTRS:LI25:920'  'PROF:BSY0:55'   'CAMR:IN20:469' ...
            'OTRS:IN20:465'  'OTRS:IN20:471'  'OTRS:LTU1:449'  'OTRS:LTU1:745' ...
            'OTRS:DMP1:695'  'YAGS:DMP1:500'  'CAMR:FEE1:455'  'DIAG:FEE1:481' ...
            'DIAG:FEE1:482'  'YAGS:DMP1:498'  'CAMR:FEE1:852'  'CAMR:FEE1:913'  ...
            'CAMR:FEE1:1561' 'CAMR:FEE1:1692' 'CAMR:FEE1:1953' 'CAMR:FEE1:2953' ...
            'CAMR:NEH1:124'  'CAMR:NEH1:195'  'CAMR:NEH1:1124' 'CAMR:NEH1:2124' ...
            'PROF:BSY0:45'   'HXX:UM6:CVP:01' 'SXR:EXS'        'PROF:BSYA:1800' ...
            'OTRS:LI20:3158' 'YAGS:LI20:2432' 'OTRS:LI20:3180' 'OTRS:LI20:3206' ...
            'YAGS:UND1:1650' 'XPP:OPAL1K:1'   'XPP:OPAL1K:1:IMAGE_CMPX' ...
            'HFX:DG2:CVV:01' 'OTRS:LI20:3070' 'OTRS:LI20:3175' 'PROF:LI20:3202' ...
            'PROF:LI20:3208' 'OTRS:LI20:3208' 'PROF:LI20:3230' 'PROF:LI20:3483' ...
            'PROF:LI20:3485' 'CAMR:FEE1:441'  'CAMR:FEE1:441:IMAGE_CMPX' ...
            'CAMR:LR20:113'  'CAMR:LR20:114'  'CAMR:LR20:119'  'CTHD:IN20:206' ...
            'CAMR:IN20:461'  'SXR:YAG:CVV:01' 'HXX:UM6:CVV:02' 'HXX:HXM:CVV:01' ...
            'HFX:DG3:CVV:01' 'XCS:DG3:CVV:02' 'MEC:HXM:CVV:01' 'PROF:LI20:3484' ...
            'PROF:LI20:3075' 'PROF:LI20:3185' 'EXPT:LI20:3176' 'EXPT:LI20:3203' ...
            'EXPT:LI20:3206' 'PROF:LI20:3486' 'PROF:LI20:3487' 'PROF:LI20:3488' ...
            'YAGS:LTU1:743'  'PROF:UND1:960'  'YAGS:UND1:1005' 'YAGS:UND1:1305'  ...
            'SXR:EXS:CVV:01' 'SXR:EXS:CVV:01:IMAGE_CMPX' ...
            'MEC:OPAL1K:1'   'MEC:OPAL1K:1:IMAGE_CMPX' ...
            'PROF:LI20:10'   'PROF:LI20:12'   'PROF:LI20:B100' 'PROF:LI20:B101' ...
            'PROF:LI20:B102' 'PROF:LI20:B103' 'PROF:LI20:B104' 'PROF:LI20:2432' ...
            'EXPT:LI20:3300' 'EXPT:LI20:3301' 'EXPT:LI20:3302' 'EXPT:LI20:3303' ...
            'EXPT:LI20:3304' 'EXPT:LI20:3305' 'EXPT:LI20:3306' 'CMOS:LI20:3490' ...
            'CMOS:LI20:3491' 'CMOS:LI20:3492' };
        handles.profmonMap=[0 63 64 65 1 66 2:5 67 21 20 22 7:12 14:18 41 19 44 ...
            23 83:86 49 25 26 30 61:62 28:29 31:40 68 87 88 50:51 42 70 52 71 73 89 90];
        if strcmp(accelerator,'FACET')
            handles.profmonMap = [0 98 53 75 45 54 47 55 78 48 79 56:59 ...
                106:108 99:105 91:97];
            % nate 5/22/14 update PVs, put things in Z order and remove duplicates
            % handles.profmonMap =[0 46 53 75 45 54 47 76 48 55 77:79 56:59 74 60 80:82 91:98];
        end
end
handles.profmonId=0;
handles.profmonNumBG=1;
handles.profmonNumAve=1;
handles.profmonName='';

% List of wire scanners
switch accelerator
    case {'NLCTA' 'XTA' 'ASTA'}
        handles.wireList={};
        handles.wireMap=0;
    otherwise
        handles.wireList={ ...
            'WIRE:IN20:531'  'WIRE:IN20:561'  'WIRE:IN20:611' ...
            'WIRE:IN20:741'  'WIRE:LI21:285'  'WIRE:LI21:293'  'WIRE:LI21:301' ...
            'WIRE:LI27:644'  'WIRE:LI28:144'  'WIRE:LI28:444'  'WIRE:LI28:744' ...
            'WIRE:LTU1:715'  'WIRE:LTU1:735'  'WIRE:LTU1:755'  'WIRE:LTU1:775' ...
            'WIRE:LTU1:246'  'WIRE:DMP1:696' ...
            'WIRE:LI20:3179' 'WIRE:LI20:3206' 'WIRE:LI20:3229' 'WIRE:LI20:3252'};
        handles.wireMap=0:17;
        if strcmp(accelerator,'FACET'), handles.wireMap=[0 18 19 20 21];end
end
handles.wireId=0;
handles.wireName='';

% List of emittance measurements
switch accelerator
    case 'NLCTA'
        handles.emitList={'PROF0595' 'PROF1550' 'PROF2290' 'PROF2250' 'PROF2190'};
        handles.emitMap=0:5;
    case {'XTA' 'ASTA'}
        handles.emitList={'OTR:XT01:250' 'OTR:XT01:350' 'YAGS:XT01:550' 'YAGS:AS01:3' 'YAGS:XT01:150'};
        handles.emitMap=[0 5 1:3];
        if strcmp(accelerator,'ASTA'), handles.emitMap=[0 4];end
    otherwise
        handles.emitList={'OTRS:IN20:571' 'OTRS:LI21:291'  ...
            'WIRE:IN20:561' 'WIRE:LI21:293' 'WIRE:LI28:144' 'WIRE:LTU1:735' ...
            'OTRS:IN20:621' ...
            'PROF:LI20:3158' 'PROF:LI20:3180' 'PROF:LI20:3206' ...
            'WIRE:LI20:3179' 'WIRE:LI20:3206' 'WIRE:LI20:3229' 'WIRE:LI20:3252' ...
            'PROF:LI20:3208' 'PROF:LI20:3202' 'PROF:LI20:3230'};
        handles.emitMap=[0:2 7 3:6];
        if strcmp(accelerator,'FACET'), handles.emitMap=[0 11:14 8:9 15:17];end
end
handles.emitId=0;
handles.emitName='';

% List of bunch length measurements
switch accelerator
    case {'NLCTA' 'XTA' 'ASTA'}
        handles.blenList={};
        handles.blenMap=0;
    case {'FACET'}
        handles.blenList = {'OTRS:LI20:3070' 'PROF:LI20:3075' 'PROF:LI20:3158' ...
            'OTRS:LI20:3175' 'PROF:LI20:3180' 'OTRS:LI20:3206' ...
            'PROF:LI20:3202' 'PROF:LI20:3230' 'PROF:LI20:3208' ...
            'WIRE:LI20:3179' 'WIRE:LI20:3206' 'WIRE:LI20:3229' 'WIRE:LI20:3252' ...
            };
        handles.blenMap = [0 1:3 5 7:13];
    otherwise
        handles.blenList={'OTRS:IN20:571' 'OTRS:LI25:920' 'PROF:BSY0:55' ...
            'WIRE:LI28:144' 'WIRE:LI27:644' 'WIRE:LI28:444' 'WIRE:LI28:744' ...
            'OTRS:IN20:621' 'OTRS:DMP1:695'};
        handles.blenMap=[0 1 8 2 5 4 6 7 3 9];
%        if strcmp(accelerator,'FACET'), handles.blenMap=9;end
end
handles.blenId=0;
handles.blenName='';

% List of fields for config file
handles.configList={'ctrlPVNum' 'ctrlPVName' 'ctrlMKBName' 'ctrlPVValNum' 'ctrlPVRange' 'ctrlPVWait' ...
    'ctrlPVWaitInit' 'readPVNameList' 'plotHeader' 'acquireSampleNum' ...
    'showFit' 'showFitOrder' 'showAverage' 'showSmoothing' 'showWindowSize' ...
    'profmonId' 'wireId' 'plotXAxisId' 'plotYAxisId' ...
    'plotUAxisId' 'acquireBSA' 'profmonNumBG' 'profmonNumAve' 'emitId' 'show2D' 'acquireSampleDelay' ...
    'acquireRandomOrder' 'acquireSpiralOrder' 'acquireZigzagOrder' 'calcPVNameList' 'blenId' ...
    'profmonName' 'wireName' 'emitName' 'blenName'};

handles.ctrlPVNum=1;
handles.ctrlPVName={'';''};
handles.ctrlMKBName='';
handles.ctrlPVRange={0 0;0 0};
handles.ctrlPVValNum=[7 1];
handles.ctrlPVWait=[1. 1.];
handles.ctrlPVWaitInit=1.;
handles.readPVNameList={...
    'BPMS:IN20:221:TMIT';
    'GDET:FEE1:241:ENRC'
    'GDET:FEE1:242:ENRC'
    'GDET:FEE1:361:ENRC'
    'GDET:FEE1:362:ENRC'
    };


if ~strcmp(accelerator,'LCLS'), handles.readPVNameList={};end
handles.profPVNameList={};
handles.wirePVNameList={};
handles.emitPVNameList={};
handles.blenPVNameList={};
handles.calcPVNameList={};
handles.plotXAxisId=0;
handles.plotYAxisId=1;
handles.plotUAxisId=0;
handles.acquireBSA=0;
handles.acquireRandomOrder=0;
handles.acquireSpiralOrder=0;
handles.acquireZigzagOrder=0;
handles.acquireSampleForce=0;
handles.acquireUseLEM=0;
handles.plotHeader='Correlation Plot';
handles.showFitOrder=1;
handles.showFit=0;
handles.show2D=0;
handles.showAverage=0;
handles.showSmoothing=0;
handles.defWindowSize=5;
handles.showLines=0;
handles.showLogX=0;
handles.showLogY=0;
handles.processSelectMethod=1;
handles.useStaticBG=0;
handles.useImgCrop=1;
handles.useCal=1;
handles.profmonXSig=4.6;
handles.profmonYSig=4.6;
handles.profmonBSA=0;
handles.acquireSampleNum=1;
handles.acquireSampleDelay=0.1;

handles.pv ='SIOC:SYS0:ML01:AO846';
handles.ctrlPVControlLow=13;
handles.ctrlPVControlHigh=103;
handles.ctrlPVSteps=3;
handles.ctrlPV=util_readPV(handles.ctrlPVName(1),1);
handles.extGui =0;

guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=acquireInit(hObject,handles);
handles=appSetup(hObject,handles);


% % % ------------------------------------------------------------------------
% % function appSave(hObject, handles)
% %
% % for tag=handles.configList
% %     config.(tag{:})=handles.(tag{:});
% % end
% % util_configSave('SXRSS_corrPlot_gui',config,1);


% % % ------------------------------------------------------------------------
% % function handles = appLoad(hObject, handles, config)
% %
% % if nargin < 3, config=1;end
% % if ~isstruct(config)
% %     config=util_configLoad('SXRSS_corrPlot_gui',config);
% % end
% % if isempty(config), return, end
% %
% % %handles.ctrlMKBName='';handles.acquireZigzagOrder=0;
% % for tag=handles.configList
% %     if isfield(config,tag{:})
% %         handles.(tag{:})=config.(tag{:});
% %     end
% % end
% % guidata(hObject,handles);
% % handles=appSetup(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

%handles=ctrlPVControl(hObject,handles,[],1:2);
handles=ctrlPVControl(hObject,handles,[],1);
%handles=ctrlMKBControl(hObject,handles,[]);
% handles=ctrlPVWaitControl(hObject,handles,[],1:2);
%%handles=ctrlPVWaitControl(hObject,handles,[],1);
%%handles=ctrlPVWaitInitControl(hObject,handles,[]);
handles=readPVControl(hObject,handles,[]);
%handles=profmonControl(hObject,handles,[]);
handles=wireControl(hObject,handles,[]);
%handles=emitControl(hObject,handles,[]);
%handles=blenControl(hObject,handles,[]);
%handles=calcPVControl(hObject,handles,[]);
handles=acquireSampleNumControl(hObject,handles,[]);
% handles=acquireSampleDelayControl(hObject,handles,[]);
%handles=acquireBSAControl(hObject,handles,[]); % Called by acquireSampleNumControl
% handles=acquireRandomOrderControl(hObject,handles,[]);
% handles=acquireSpiralOrderControl(hObject,handles,[]);
% handles=acquireZigzagOrderControl(hObject,handles,[]);
%handles=acquireUseLEMControl(hObject,handles,[]);
%handles=plotHeaderControl(hObject,handles,[]);
%handles=showFitControl(hObject,handles,[]);
%handles=show2DControl(hObject,handles,[]);
%handles=showAverageControl(hObject,handles,[]);
%handles=showSmoothingControl(hObject,handles,[]);
%handles=showLinesControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);
%handles=profmonMultiControl(hObject,handles,0);
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function [handles, cancd] = acquireReset(hObject, handles, prescan)
if nargin<3, prescan=0; end;
cancd=0;
if ~prescan
    [handles,cancd]=gui_dataRemove(hObject,handles);
end
if cancd, return, end
handles=dataCurrentDeviceControl(hObject,handles,1,1);
handles.fileName='';
handles.data.accelerator=handles.accelerator;
handles.data.status=zeros(prod(handles.dataDevice.nVal),1);
% handles.showWindowSize.jVal=[];
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireInit(hObject, handles)

handles.process.displayExport=0;
handles.process.saved=0;
handles.process.loading=0;
handles.process.saveImg=0;
handles.process.showImg=0;
handles.process.holdImg=1;
handles.process.procImg=1;
handles.process.dataDisp=0;
guidata(hObject,handles);


% ------------------------------------------------------------------------
% % function handles = ctrlPVWaitControl(hObject, handles, val, num)
% %
% % handles=gui_editControl(hObject,handles,'ctrlPVWait',val,num);


% ------------------------------------------------------------------------
% % function handles = ctrlPVWaitInitControl(hObject, handles, val)
% %
% % handles=gui_editControl(hObject,handles,'ctrlPVWaitInit',val);


% ------------------------------------------------------------------------
function handles = ctrlPVControl(hObject, handles, val, num)

handles = guidata(hObject);
pv = handles.pv;

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);


%handles.acquireSampleDelay=0.1;


pv=cellstr(pv);

handles.ctrlPVName = pv;

%handles=gui_textControl(hObject,handles,'ctrlPVName',val,num);


if cancd, return, end

handles.ctrlPV(num)=util_readPV(handles.ctrlPVName(num),1);
%handles.ctrlPVNum=sum(~cellfhun('isempty',handles.ctrlPVName));
str={'' '2'};

if strcmpi(handles.ctrlPVName(num), 'MKB:VAL')
    handles.ctrlPV(num).val = 0;
end

for j=num
    set(handles.(['dataDevice' str{j} 'Label_txt']),'String',handles.ctrlPV(j).name);
    set([handles.(['ctrlPVVal' str{j} '_txt']) handles.(['ctrlPVInitVal' str{j} '_txt'])],'String',num2str(handles.ctrlPV(j).val,'%5.5g'));
    %%set([handles.(['ctrlPVEgu' str{j} '_txt']) handles.(['ctrlPVInitEgu' str{j} '_txt']) handles.(['ctrlPVRangeUnits' str{j} '_txt'])],'String',handles.ctrlPV(j).egu);

end
%handles=ctrlPVRangeControl(hObject,handles,1:2,[],num);
handles=ctrlPVRangeControl(hObject,handles,1,[],num);
handles=plotAxisControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = ctrlPVValNumControl(hObject, handles, val, num, prescan)
if nargin<5, prescan=0; end;
cancd=0;

if ~prescan
    [handles,cancd,val]=gui_dataRemove(hObject,handles,val);
end

%%handles=gui_editControl(hObject,handles,'ctrlPVValNum',val,num,1,[0 1]);

if cancd, return, end

str={'' '2'};

handles=guidata(hObject);
%handles.ctrlPVControlLow=13;
%handles.ctrlPVControlHigh=103;
%handles.ctrlPVSteps=3;

jj=cell(2,2);
jj{1}=handles.ctrlPVControlLow; jj{2}=0;
jj{3}=handles.ctrlPVControlHigh; jj{4}=0;
handles.ctrlPVRange=jj;

jjj=ones(1,2);
jjj(1)=handles.ctrlPVSteps;
handles.ctrlPVValNum =jjj;



for j=num
    handles.ctrlPVValList{j}=linspace(handles.ctrlPVRange{j,:},handles.ctrlPVValNum(j));
    step=mean(diff(handles.ctrlPVValList{j}));if isnan(step), step='N/A';end
    %%set(handles.(['ctrlPVValStep' str{j} '_txt']),'String',num2str(step,'%.3g'));
end

handles.dataDevice.nVal=[1 1];
handles.dataDevice.nVal(1:handles.ctrlPVNum)=handles.ctrlPVValNum(1:handles.ctrlPVNum);
guidata(hObject,handles);
handles=acquireReset(hObject,handles,prescan);


% ------------------------------------------------------------------------
function handles = ctrlPVValStepControl(hObject, handles, val, num)

if isempty(val) || any(isnan(val)) || ~val
    val=[]
else
    val=round(diff([handles.ctrlPVRange{num,:}])/val+1);
end
handles=ctrlPVValNumControl(hObject,handles,val,num);


% ------------------------------------------------------------------------
function handles = ctrlPVRangeControl(hObject, handles, tag, val, num, prescan)
if nargin<6, prescan=1; end;
cancd=0;

if ~prescan
    [handles,cancd,val]=gui_dataRemove(hObject,handles,val);
end


%%handles=gui_rangeControl(hObject,handles,'ctrlPVRange',tag,val,num);


if cancd, return, end

handles=ctrlPVValNumControl(hObject,handles,[],num, prescan);

guidata(hObject,handles);

% ------------------------------------------------------------------------
function handles = readPVControl(hObject, handles, val)
[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
%handles=gui_textControl(hObject,handles,'readPVNameList',val);
if cancd, return, end
handles.readPVValid=[];
handles.BSAPVValid=[];
guidata(hObject,handles);
handles=acquireReset(hObject,handles);
handles=plotAxisControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = gui_listControl(hObject, handles, name, val)

if isempty(val)
    val=handles.([name 'Id']);
else
    val=handles.([name 'Map'])(val);
end
if any(~val) && any(val), val(~val)=[];end
handles.([name 'Id'])=val;
nameList=model_nameConvert(handles.([name 'List']),'MAD');
nameList=nameList(handles.([name 'Map'])(2:end));
id=find(ismember(handles.([name 'Map']),val));
if isempty(id), id=1;end
set(handles.([name '_pmu']),'Value',id,'String',[{'none'} nameList]);
handles.([name 'Name'])='';
if any(val)
    handles.([name 'Name'])=handles.([name 'List']){val};
    if numel(val) > 1, handles.([name 'Name'])=handles.([name 'List'])(val);end
end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = profmonControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_listControl(hObject,handles,'profmon',val);
if cancd, return, end
handles.profPVNameList={};
if any(handles.profmonId)
    props={'X' 'Y' 'XRMS' 'YRMS' 'XY' 'TMIT'}';
    name=cellstr(handles.profmonName);
    nameList=cell(numel(props),numel(name));
    for j=1:numel(name)
        nameList(:,j)=strcat(name(j),':',props);
    end
    handles.profPVNameList=nameList(:);
end
%handles=profmonNumBGControl(hObject,handles,[]);
%handles=profmonNumAveControl(hObject,handles,[]);
handles=acquireReset(hObject,handles);
handles=plotAxisControl(hObject,handles,[]);
handles=wirePlaneControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);


% ------------------------------------------------------------------------
% % function handles = profmonNumBGControl(hObject, handles, val)
% %
% % handles=gui_editControl(hObject,handles,'profmonNumBG',val,1,any(handles.profmonId));
% % handles=useStaticBGControl(hObject,handles,[]);


% % % ------------------------------------------------------------------------
% % function handles = useStaticBGControl(hObject, handles, val)
% %
% % vvl=any(handles.profmonId) & handles.profmonNumBG;
% % handles=gui_checkBoxControl(hObject,handles,'useStaticBG',val,vvl);
% % handles.staticBG=0;
% % guidata(hObject,handles);
% % vis={'off' 'on'};
% % set(handles.staticBG_btn,'Visible',vis{1+(vvl & handles.useStaticBG)},'BackgroundColor','r');


% % % ------------------------------------------------------------------------
% % function handles = profmonNumAveControl(hObject, handles, val)
% %
% % handles=gui_editControl(hObject,handles,'profmonNumAve',val,1,any(handles.profmonId));


% ------------------------------------------------------------------------
function handles = wireControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
%handles=gui_listControl(hObject,handles,'wire',val);
if cancd, return, end
handles=acquireReset(hObject,handles);
handles=wirePlaneControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);


% ------------------------------------------------------------------------
function handles = wirePlaneControl(hObject, handles, tag)

if isempty(tag), tag='x';end

handles=gui_radioBtnControl(hObject,handles,'wirePlane',tag, ...
    handles.wireId | handles.emitId | any(handles.profmonId));

handles.wirePVNameList={};
if handles.wireId
    handles.wirePVNameList=strcat(handles.wireName,':', ...
        [strcat(upper(handles.wirePlane),{'' 'RMS'}');{'SUM'}]);
end
guidata(hObject,handles);
handles=plotAxisControl(hObject,handles,[]);


% % % ------------------------------------------------------------------------
% % function handles = emitControl(hObject, handles, val)
% %
% % [handles,cancd,val]=gui_dataRemove(hObject,handles,val);
% % handles=gui_listControl(hObject,handles,'emit',val);
% % if cancd, return, end
% % handles.emitPVNameList={};
% % if handles.emitId
% %     tags={'EMIT' 'BETA' 'ALPHA' 'BMAG'}';
% %     handles.emitPVNameList=strcat(handles.emitName,':', ...
% %         [strcat(tags,'X');strcat(tags,'Y')]);
% % end
% % typ='scan';if handles.emitId && ismember(handles.emitName,{'WIRE:LI28:144' 'WIRE:LTU1:735'}), typ='multi';end
% % handles=emitTypeControl(hObject,handles,typ);
% % handles=plotAxisControl(hObject,handles,[]);
% % handles=wirePlaneControl(hObject,handles,[]);
% % handles=dataMethodControl(hObject,handles,[],6);


% % % ------------------------------------------------------------------------
% % function handles = emitTypeControl(hObject, handles, tag)
% %
% % [handles,cancd,tag]=gui_dataRemove(hObject,handles,tag);
% % handles=gui_radioBtnControl(hObject,handles,'emitType',tag,handles.emitId);
% % if cancd, return, end
% % handles=acquireReset(hObject,handles);

% %
% % % ------------------------------------------------------------------------
% % function handles = blenControl(hObject, handles, val)
% %
% % [handles,cancd,val]=gui_dataRemove(hObject,handles,val);
% % handles=gui_listControl(hObject,handles,'blen',val);
% % if cancd, return, end
% % handles.blenPVNameList={};
% % if handles.blenId
% %     tags={'BLEN'}';
% %     handles.blenPVNameList=strcat(handles.blenName,':',tags);
% % end
% % guidata(hObject,handles);
% % handles=acquireReset(hObject,handles);
% % handles=plotAxisControl(hObject,handles,[]);
% % handles=dataMethodControl(hObject,handles,[],6);


% % % ------------------------------------------------------------------------
% % function handles = calcPVControl(hObject, handles, val)
% %
% % handles=gui_textControl(hObject,handles,'calcPVNameList',val);
% % handles=plotAxisControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = plotAxisControl(hObject, handles, val)
handles=plotXAxisControl(hObject,handles,val);
handles=plotYAxisControl(hObject,handles,val);
handles=plotUAxisControl(hObject,handles,val);


% ------------------------------------------------------------------------
function list = getPlotList(handles)

list=[handles.readPVNameList;handles.profPVNameList; ...
      handles.wirePVNameList;handles.emitPVNameList; ...
      handles.blenPVNameList;handles.calcPVNameList];
nCalc=length(handles.calcPVNameList);
nCtrl=handles.ctrlPVNum;
lettList=strcat(getLetters(nCtrl+length(list)),{': '});
lettList(nCtrl+length(list)-nCalc+1:end)={'*: '};
list=strcat(lettList(nCtrl+1:end),reshape(list,[],1));


% ------------------------------------------------------------------------
function handles = plotXAxisControl(hObject, handles, val,prescan)

if nargin<4, prescan=0; end
if isfield(handles.data,'prescan')
    prescan=1;
end
if isempty(val)
    val=handles.plotXAxisId;
end
lettList=strcat(getLetters(handles.ctrlPVNum),{': '},handles.ctrlPVName(1:handles.ctrlPVNum));
if ~handles.ctrlPVNum, lettList={};end
nameList=[{'TIME'};lettList;getPlotList(handles)];
handles.plotXAxisId=min(val,length(nameList)-1);
%set(handles.plotXAxisId_pmu,'Value',handles.plotXAxisId+1,'String',nameList);
guidata(hObject,handles);
handles=acquireUpdate(hObject,handles,prescan);


% ------------------------------------------------------------------------
function handles = plotYAxisControl(hObject, handles, val, prescan)

if nargin<4, prescan=0; end
if isfield(handles.data,'prescan')
    prescan=1;
end
if isempty(val)
    val=handles.plotYAxisId;
end
nameList=getPlotList(handles);
val=val(val <= length(nameList));if isempty(val), val=1;end
handles.plotYAxisId=val;
set(handles.plotYAxisId_lbx,'Value',val,'String',nameList);
guidata(hObject,handles);
handles=acquireUpdate(hObject,handles,prescan);


% ------------------------------------------------------------------------
function handles = plotUAxisControl(hObject, handles, val, prescan)

if nargin<4, prescan=0; end
if isfield(handles.data,'prescan')
    prescan=1;
end
if isempty(val)
    val=handles.plotUAxisId;
end
nameList=[{'none'};handles.ctrlPVName(1:handles.ctrlPVNum);getPlotList(handles)];
handles.plotUAxisId=min(val,length(nameList)-1);
%set(handles.plotUAxisId_pmu,'Value',handles.plotUAxisId+1,'String',nameList);
guidata(hObject,handles);
handles=acquireUpdate(hObject,handles, prescan);


% % % ------------------------------------------------------------------------
% % function handles = showFitOrderControl(hObject, handles, val, prescan)
% %
% % if nargin<4, prescan=0; end
% % if isfield(handles.data,'prescan')
% %     prescan=1;
% % end
% % handles=gui_editControl(hObject,handles,'showFitOrder',val,1,handles.showFit == 1);
% % handles=acquireUpdate(hObject,handles,prescan);
% %
% %
% % % ------------------------------------------------------------------------
% % function handles = showFitControl(hObject, handles, val)
% %
% % prescan=0;
% % if isfield(handles.data,'prescan')
% %     prescan=1;
% % end
% % if isempty(val)
% %     val=handles.showFit;
% % end
% % handles.showFit=val;
% % set(handles.showFit_pmu','Value',val+1);
% % handles=showFitOrderControl(hObject,handles,[],prescan);
% % guidata(hObject,handles);

% %
% % % --- Executes on change in showWindowSize_box.
% % function showWindowSize_sl_Callback(hObject, eventdata, handles)
% %
% % showSmoothingWindowControl(hObject,handles,round(get(hObject,'Value')));


% % % --- Executes on button press in showSmoothing_box.
% % function showSmoothing_box_Callback(hObject, eventdata, handles)
% %
% % handles=showAverageControl(handles.showAverage_box,handles,0);
% % showSmoothingControl(hObject,handles,get(hObject,'Value'));


% % % ------------------------------------------------------------------------
% % function handles = showSmoothingWindowControl(hObject, handles, val, prescan)
% %
% % if nargin<4, prescan=0; end
% % if isfield(handles.data,'prescan')
% %     prescan=1;
% % end
% % if isempty(val)
% %     val=handles.defWindowSize;
% % end
% % handles=gui_sliderControl(hObject,handles,'showWindowSize',val,50,handles.showSmoothing);
% % handles=acquireUpdate(hObject,handles,prescan);


% ------------------------------------------------------------------------
function handles = showSmoothingControl(hObject, handles, val)

prescan=0;
if isfield(handles.data,'prescan')
    prescan=1;
end
handles=gui_checkBoxControl(hObject,handles,'showSmoothing',val);
handles=acquirePlot(hObject,handles,prescan);
if isfield (handles,'showWindowSize')
    winSize=handles.showWindowSize.jVal;
else
    winSize=[];
end
%handles=showSmoothingWindowControl(hObject,handles,winSize,prescan);

% %
% % % ------------------------------------------------------------------------
% % function handles = show2DControl(hObject, handles, val)
% %
% % if isempty(val)
% %     val=handles.show2D;
% % end
% % handles.show2D=val;
% % set(handles.show2D_pmu','Value',val+1);
% % guidata(hObject,handles);
% % handles=acquirePlot(hObject,handles);

% %
% % % ------------------------------------------------------------------------
% % function handles = showAverageControl(hObject, handles, val)
% % prescan=0;
% % if isfield (handles.data,'prescan');
% %     prescan=1;
% % end
% % handles=gui_checkBoxControl(hObject,handles,'showAverage',val);
% % handles=acquirePlot(hObject,handles,prescan);


% % % ------------------------------------------------------------------------
% % function handles = showLinesControl(hObject, handles, val)
% % prescan=0;
% % if isfield (handles.data,'prescan');
% %     prescan=1;
% % end
% % handles=gui_checkBoxControl(hObject,handles,'showLines',val);
% % handles=acquirePlot(hObject,handles,prescan);


% ------------------------------------------------------------------------
function pvSet(pv, val)

global mkbRequestBuilder

% AIDA-PVA imports
global pvaSet;

[micro, prim, unit, secn] = model_nameSplit(pv);
if strncmp(pv,'LI',2) || strncmp(pv,'TA',2) || strncmp(pv,'DR12',4) || strncmp(pv,'MKB:VAL',8)
%    if strcmp(secn,'BDES') || strcmp(secn,'VDES')
    if strcmp(secn,'BDES')
        control_magnetSet(strcat(micro, ':', prim, ':', unit), val);
    else
        if ~ispc
            try
                if strncmp(pv,'MKB:VAL',8)
                    mkbRequestBuilder.set(val);
                else
                    pvaSet(strcat(prim, ':', micro, ':',unit,':',secn), val);
                end
            catch
                disp(['Error in setting value for ' pv]);
            end
        else
            lcaPutSmart(pv,val);
        end
    end
else
    lcaPutSmart(pv,val);
    if strcmp(pv,'SIOC:SYS0:ML00:AO9999') %Test input
        [hObj,h]=util_appFind('fxnTest_gui');
        set(h.fxn_pmu,'Value',3);
        set(h.fxnInput,'String',num2str(val));
        fxnTest_gui('fxnInput_Callback',hObj, [], guidata(hObj));
    end
end


% ------------------------------------------------------------------------
function handles = ctrlPVSet(hObject, handles, num, init, relative, valList, element)

if nargin < 7, element=[]; end
if nargin < 6, valList=[]; end
if nargin < 5, relative=0; end
if nargin < 4, init=0;end
if num > handles.ctrlPVNum, return, end

guidata(hObject,handles);
pv=handles.ctrlPVName{num};
if relative
    currVal=handles.ctrlPVValList{1}(element);
    idx=find(valList == element);
    if idx > 1
        oldVal=handles.ctrlPVValList{1}(valList(idx-1));
    else
        oldVal=currVal;
    end
    val=currVal-oldVal;
else
    val=handles.ctrlPVValList{num}(handles.dataDevice.jVal(num));
end
str={'' '2'};
set(handles.(['ctrlPVSet' str{num} '_btn']),'BackgroundColor','g');pause(.1);
pvSet(pv,val);

handles.ctrlPVWait = [1 1]; %settle time [2 1] is 2 seconds
handles.ctrlPVWaitInit = 1; %inital

pause(handles.ctrlPVWait(num)*(1-2*init)+handles.ctrlPVWaitInit*init);
set(handles.(['ctrlPVSet' str{num} '_btn']),'BackgroundColor','default');
set(handles.(['ctrlPVVal' str{num} '_txt']),'String',num2str(val,'%5.5g'));
doLEMTrim(hObject,handles);
if handles.extGui
    handles = updateExtGui(hObject, handles,val);
end
handles=guidata(hObject);


% ------------------------------------------------------------------------
function handles = ctrlPVReset(hObject, handles, relative, valList)

if nargin<4, valList=[]; end
if nargin<3, relative=0; end
guidata(hObject,handles);
for num=1:handles.ctrlPVNum
    pv=handles.ctrlPVName{num};
    if relative
        val=-handles.ctrlPVValList{1}(valList(end));
    else
        %val=handles.ctrlPV(num).val;
        val = lcaGetSmart(handles.pv);
    end
    valStr=sprintf('Resetting val: %g',val);

    disp(valStr);
    if handles.extGui
    handles = updateExtGui(hObject, handles,val);
    end

    str={'' '2'};
%     set(handles.ctrlPVReset_btn,'BackgroundColor','g');pause(.1);
    pvSet(pv,val);
    pause(handles.ctrlPVWait(num));
%     set(handles.ctrlPVReset_btn,'BackgroundColor','default');
    set([handles.(['ctrlPVVal' str{num} '_txt']) handles.(['ctrlPVInitVal' str{num} '_txt'])],'String',num2str(val,'%5.5g'));
end
doLEMTrim(hObject,handles);
handles=guidata(hObject);


% ------------------------------------------------------------------------
function doLEMTrim(hObject, handles)

if ~handles.acquireUseLEM, return, end
gui_statusDisp(handles,'LEM Trim starting ...');
model_energyBLEMTrim('action','PERTURB','quiet',1);
gui_statusDisp(handles,'LEM Trim completed.');


% ------------------------------------------------------------------------
function handles = plotHeaderControl(hObject, handles, val)

handles=gui_textControl(hObject,handles,'plotHeader',val,1,1,'CorrelationS Plot');

handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentDeviceControl(hObject, handles, val, num)


for j=num
    str=sprintf('%7.5g %s',handles.ctrlPVValList{j}(val),handles.ctrlPV(j).egu);
    handles=gui_sliderControl(hObject,handles,'dataDevice',val,[],1,j,str);
%     set(handles.dataDeviceUse_box,'Visible',get(handles.dataDevice_sl,'Visible'));
end
% set(handles.dataDeviceUse_box,'Visible',get(handles.dataDevice_sl,'Visible'));
try
    %set(handles.dataDeviceUse2_box,'Visible',get(handles.dataDevice2_sl,'Visible'));
catch
end


% ------------------------------------------------------------------------
function handles = acquireSampleNumControl(hObject, handles, val)

%handles.acquireSampleNum=5;
[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
%handles=gui_editControl(hObject,handles,'acquireSampleNum',val);
if cancd, return, end

handles=dataCurrentSampleControl(hObject,handles,1,handles.acquireSampleNum);
%set(handles.dataSampleUse_box,'Visible',get(handles.dataSample_sl,'Visible'));
handles=acquireBSAControl(hObject,handles,[]);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSampleControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSample',iVal,nVal);


% % % ------------------------------------------------------------------------
% % function handles = acquireSampleDelayControl(hObject, handles, val)
% %
% % handles=gui_editControl(hObject,handles,'acquireSampleDelay',val);
% %

% ------------------------------------------------------------------------
function handles = acquireBSAControl(hObject, handles, val)


if handles.process.loading, return, end
update=1;if isempty(val),update=0;end
eDef=0;if isfield(handles,'eDefNumber'), eDef=handles.eDefNumber;end

if (any(val) || (isempty(val) && handles.acquireBSA)) && handles.acquireSampleNum > 2800
    val=0;
    uiwait(warndlg('Sample number exceeds BSA limit of 2800.  Choose smaller number.', ...
        'BSA Disabled'));
end

handles=gui_BSAControl(hObject,handles,val);
val=handles.acquireBSA;
% set(handles.acquireBSA_box,'Value',val+1);
if ~ispc
    if handles.acquireBSA && (update || eDef ~= handles.eDefNumber)
        mask=get(handles.acquireBSA_box,'String');
        if ~strcmp(mask(val+1),'120_HERTZ')
            lcaPut(['EDEF:SYS0:' num2str(handles.eDefNumber) ':BEAMCODE'],1);
            eDefParams(handles.eDefNumber,1,2800,[mask(val+1);{'pockcel_perm'}],mask(setdiff(2:end-1,val+1)),{},{'TS2';'TS3';'TS5';'TS6'});
        else
            lcaPut(['EDEF:SYS0:' num2str(handles.eDefNumber) ':BEAMCODE'],0);
            eDefParams(handles.eDefNumber,1,2800,{},[mask(2:end-1);{'TS4';'pockcel_perm'}],{'TS2';'TS3';'TS5';'TS6'});
        end
    end
end
if update, handles.readPVValid=[];end
guidata(hObject,handles);


% ------------------------------------------------------------------------
% % function handles = acquireRandomOrderControl(hObject, handles, val)
% %
% % handles=gui_checkBoxControl(hObject,handles,'acquireRandomOrder',val);

% %
% % % ------------------------------------------------------------------------
% % function handles = acquireSpiralOrderControl(hObject, handles, val)
% %
% % handles=gui_checkBoxControl(hObject,handles,'acquireSpiralOrder',val);

% % % ------------------------------------------------------------------------
% % function handles = acquireZigzagOrderControl(hObject, handles, val)
% %
% % handles=gui_checkBoxControl(hObject,handles,'acquireZigzagOrder',val);


% ------------------------------------------------------------------------
% % function handles = acquireUseLEMControl(hObject, handles, val)
% %
% % if ~isempty(val) && val
% %     val=strcmp(questdlg('Do you really want to LEM at each data point?','LEM Selected'),'Yes');
% % end
% % handles=gui_checkBoxControl(hObject,handles,'acquireUseLEM',val);


% ------------------------------------------------------------------------
function handles = acquireImgProc(hObject, handles, iVal, dataList)

if nargin < 4 && ~isfield(handles.data,'dataList'), return, end
if nargin < 3, iVal=find(handles.data.status)';end
if nargin == 4, handles.data.dataList(iVal,:,:)=shiftdim(dataList,1);end
if ~handles.process.procImg, guidata(hObject,handles);return, end

gui_statusDisp(handles,sprintf('Processing images ...'));
opts.doPlot=1;opts.useCal=handles.useCal;opts.crop=handles.useImgCrop;
opts.xsig=handles.profmonXSig;opts.ysig=handles.profmonYSig;
for j=iVal
    for k=1:size(handles.data.dataList(j,:,:),2)
        for l=1:size(handles.data.dataList(j,:,:),3)
            data=handles.data.dataList(j,k,l);
            data.beam=profmon_process(data,opts);
            handles.data.beam(j,k,:,l)=data.beam;
            handles.data.profPV(:,j,k,l)=beamAnalysis_convert2PV(data);
        end
    end
end
if ~handles.process.holdImg, handles.data=rmfield(handles.data,'dataList');end
%if ~handles.process.holdImg, handles.data.dataList(iVal,:)=[];end
gui_statusDisp(handles,sprintf('Processing images complete.'));
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireCurrentGet(hObject, handles, state, prescan)
if nargin < 4, prescan=0;end
if handles.acquireBSA %&& ~handles.eDefNumber
    handles=acquireBSAControl(hObject,handles,[]);
end

if handles.acquireBSA
    lcaPut('SIOC:SYS0:ML00:AO526',handles.eDefNumber);
end

handles.process.saved=0;
iVal=handles.dataDevice.iVal;
isQuasiBSA=strncmp(handles.readPVNameList,'SIOC:SYS0:ML00:FWF',18);
isFELeLoss=strncmp(handles.readPVNameList,'PHYS:SYS0:1:ELOSSENERGY',20);
if strcmp(handles.ctrlPV(1).name, 'MKB:VAL')
    handles.data.ctrlPV(:,iVal) = util_readPV('');
    handles.data.ctrlPV(:,iVal).name = 'MKB:VAL';
    handles.data.ctrlPV(:,iVal).desc = handles.ctrlMKBName;
    handles.data.ctrlPV(:,iVal).val = handles.ctrlPVValList{handles.ctrlPVNum}(iVal);
else
    handles.data.ctrlPV(:,iVal)=util_readPV(handles.ctrlPVName(1:handles.ctrlPVNum),1);
end
if ~isempty(handles.readPVNameList) && (isempty(handles.readPVValid) || ~isfield(handles.data,'readPV'))
    timeout=lcaGetTimeout;lcaSetTimeout(0.5);
    [handles.data.readPV(:,iVal,1),handles.readPVValid]=util_readPV(handles.readPVNameList,1);
    lcaSetTimeout(timeout);
    handles.readPVValidId=iVal;handles.BSAPVValid=handles.readPVValid & 0;
    if handles.acquireBSA
        [readPV,handles.BSAPVValid]=util_readPV(strcat(handles.readPVNameList,'BR'),1);
        handles.BSAPVValid=handles.BSAPVValid | isQuasiBSA;
        handles.readPVValid=handles.readPVValid | handles.BSAPVValid;
        if ~all(handles.BSAPVValid)
            str=[{'Invalid BSA PVs:'};handles.readPVNameList(~handles.BSAPVValid)];
            btn=questdlg(str,'Invalid BSA PV Names','Cancel','OK','Cancel');
            if strcmp(btn,'Cancel')
                gui_acquireStatusSet(hObject,handles,0);
                return
            end
        end
    end
    if ~all(handles.readPVValid)
        str=[{'Invalid PVs:'};handles.readPVNameList(~handles.readPVValid)];
        btn=questdlg(str,'Invalid PV Names','Cancel','OK','Cancel');
        if strcmp(btn,'Cancel')
            gui_acquireStatusSet(hObject,handles,0);
            return
        end
    end
end
guidata(hObject,handles);

% Do FEL energy loss.
if any(isFELeLoss)
    E_loss_scan('appRemote',0);
end

% Do wire scan, only nonsynchronous.
if handles.wireId
    gui_statusDisp(handles,sprintf('Acquiring wire data'));
    if strcmp(state,'query')
        dataList=wirescan_gui('appQuery',0,handles.wireName,handles.wirePlane);
    else
        for j=1:(1+(handles.dataSample.nVal-1)*handles.acquireSampleForce)
            dataList(j)=wirescan_gui('appRemote',0,handles.wireName,handles.wirePlane);
            pause(handles.acquireSampleDelay);
        end
    end
    handles=guidata(hObject);
    handles.data.status(iVal)=all([dataList.status]);
    if ~all([dataList.status]), gui_acquireStatusSet(hObject,handles,0);return, end
    beamList=vertcat(dataList.beam);
    handles.data.wireBeam(iVal,1:numel(dataList),:)=beamList;
    dataList(end+1:handles.dataSample.nVal)=dataList(1);
    handles.data.wirePV(:,iVal,:)=[dataList.beamPV];
    guidata(hObject,handles);
end

% Do emittance scan, only nonsynchronous.
if handles.emitId
    gui_statusDisp(handles,sprintf('Acquiring emittance data'));
    clear dataList
    if strcmp(handles.emitType,'multi') && strcmp(state,'query')
        dataList=emittance_gui('appQuery',0);
    else
        for j=1:(1+(handles.dataSample.nVal-1)*handles.acquireSampleForce)
            dataList(j)=emittance_gui('appRemote',0,handles.emitName,handles.emitType,handles.wirePlane);
            pause(handles.acquireSampleDelay);
        end
    end
    handles=guidata(hObject);
    handles.data.status(iVal)=all([dataList.status]);
    if ~handles.data.status(iVal), gui_acquireStatusSet(hObject,handles,0);return, end
    dataList(end+1:handles.dataSample.nVal)=dataList(1);
    twissStd=reshape(dataList(1).twissstd(:,:,:,1),[],size(dataList(1).twissstd,3));
    twissStd([1 5],:)=twissStd([1 5],:)*1e6; % Scale emittance into um
    handles.data.twissStd(iVal,:,:)=twissStd;
    handles.data.twissPV(:,iVal,:)=[dataList.twissPV];
    guidata(hObject,handles);
end

% Do bunch length scan, only nonsynchronous.
if handles.blenId
    gui_statusDisp(handles,sprintf('Acquiring bunch length data'));
    clear dataList
    if strcmp(state,'query')
        dataList=tcav_gui('appQuery',0);
    else
        for j=1:(1+(handles.dataSample.nVal-1)*handles.acquireSampleForce)
            dataList(j)=tcav_gui('appRemote',0,handles.blenName,'blen');
            pause(handles.acquireSampleDelay);
        end
    end
    handles=guidata(hObject);
    handles.data.status(iVal)=all(all([dataList.status]));
    if ~all([dataList.status]), gui_acquireStatusSet(hObject,handles,0);return, end
    beamList=permute(cat(3,dataList.beam),[3 2 1]);
    handles.data.blenBeam(iVal,1:numel(dataList),:,:)=beamList;
    dataList(end+1:handles.dataSample.nVal)=dataList(1);
    blenStd=dataList(1).blenStd(:,:);
    handles.data.blenStd(iVal,:,:)=blenStd;
    handles.data.blenPV(:,iVal,:)=[dataList.blenPV];
    guidata(hObject,handles);
end

% Start beam synchronous acquisition.
if ~ispc && (any(handles.BSAPVValid) || handles.profmonBSA)
    if any(handles.profmonId) && ~handles.profmonBSA
        eDefParams(handles.eDefNumber,1,2800);
        eDefOn(handles.eDefNumber);
    else
        eDefParams(handles.eDefNumber,1,handles.dataSample.nVal);
        eDefOn(handles.eDefNumber);
        gui_statusDisp(handles,sprintf('Waiting for eDef completion'));
        drawnow;
        handles=guidata(hObject);
    end
end

% Get profile monitor data.
if any(handles.profmonId) && ~handles.profmonBSA
    gui_statusDisp(handles,sprintf('Getting Image Data'));
    opts.nBG=handles.profmonNumBG;opts.bufd=1;opts.nAvg=handles.profmonNumAve;
    %opts.axes=handles.plotProf_ax;
    opts.doPlot=1;opts.doProcess=0;
    if handles.useStaticBG, opts.nBG=handles.staticBG;end
    dataList=profmon_measure(handles.profmonName,handles.dataSample.nVal,opts);
    handles=guidata(hObject);
    gui_statusDisp(handles,sprintf('Done Image Acquisition'));
    handles=acquireImgProc(hObject,handles,iVal,dataList);
    dataList=handles.data.dataList(iVal,:,:);
end

% Do beam synchronous acquisition
%if handles.acquireBSA && ~isempty(handles.readPVNameList) && any(handles.BSAPVValid)
if ~ispc && (any(handles.BSAPVValid) || handles.profmonBSA)
    if any(handles.profmonId) && ~handles.profmonBSA
        eDefOff(handles.eDefNumber);
    else
        while ~eDefDone(handles.eDefNumber), end
        gui_statusDisp(handles,sprintf('eDef completed'));
        drawnow;
        handles=guidata(hObject);
    end
end

% Get profile monitor data.
if any(handles.profmonId) && handles.profmonBSA
    gui_statusDisp(handles,sprintf('Getting Image Data'));
    opts.nBG=handles.profmonNumBG;opts.bufd=1;opts.buffer=1;
    %opts.axes=handles.plotProf_ax;
    opts.doPlot=1;opts.doProcess=0;
    if handles.useStaticBG, opts.nBG=handles.staticBG;end
    dataList=profmon_measure(handles.profmonName,handles.dataSample.nVal,opts);
    handles=guidata(hObject);
    gui_statusDisp(handles,sprintf('Done Image Acquisition'));
    handles=acquireImgProc(hObject,handles,iVal,dataList);
    dataList=handles.data.dataList(iVal,:,:);
end

if any(handles.BSAPVValid)
    gui_statusDisp(handles,sprintf('Getting Synchronous Data'));
    handles=guidata(hObject);
    use=find(handles.BSAPVValid);
    use2=strncmp(handles.readPVNameList(use),'SIOC:SYS0:ML00:FWF',18);
    [readPV,pulseId]=util_readPVHst(handles.readPVNameList(use),handles.eDefNumber,1);
    if any(isQuasiBSA)
        util_quasiBSA;
        val=num2cell(lcaGetSmart(handles.readPVNameList(isQuasiBSA),numel(pulseId)),2);
        [readPV(use2).val]=deal(val{:});
    end
    rate=mode(diff(pulseId,1,2),2);if isnan(rate), rate=1;end
    gui_statusDisp(handles,sprintf('Done Data Acquisition'));
    useSample=1:handles.dataSample.nVal;
    if any(handles.profmonId)
        useSample=zeros(handles.dataSample.nVal,1);
        for j=1:numel(dataList)
            if (strncmp(dataList(j).name,'CAMR',4) && ~ strncmp(dataList(j).name,'CAMR:FEE1',9))
                dataList(j).pulseId=round((dataList(j).ts-readPV(use(1)).ts)*24*60*60*360+pulseId(end));
            end
            if strncmp(dataList(j).name,'DIAG:FEE1',9)
                dataList(j).pulseId=dataList(j).pulseId-3;
            end
        end
        for j=1:handles.dataSample.nVal
            idx=find(dataList(j).pulseId >= pulseId);
            [d,id]=min(double(dataList(j).pulseId)-pulseId(idx));
            if isempty(idx), idx=1;id=1;end
            useSample(j)=idx(id);
        end
    end
end
if any(handles.BSAPVValid) || handles.profmonBSA
    if any(handles.profmonId)
        % Find common set of pulse IDs.
        pID=[dataList(1,:,1).pulseId];
        for j=2:size(dataList,3)
            pID=intersect(pID,[dataList(1,:,j).pulseId]);
        end
        % Find IDs in first profmon.
        useID=ismember([dataList(1,:,1).pulseId],pID);
        pID=[dataList(1,useID,1).pulseId];
        % Match other screen pulse IDs.
        for j=2:size(dataList,3)
            [d,useID2]=ismember(pID,[dataList(1,:,j).pulseId]);
            dataList(1,useID,j)=dataList(1,useID2,j);
        end
        % Make beamPV NaN for bad pIDs.
        if isfield(handles.data,'profPV'), [handles.data.profPV(:,iVal,~useID,:).val]=deal(NaN(1,7));end
        for j=find(~useID), for k=1:size(dataList,3), dataList(1,j,k).img=dataList(1,j,k).img*NaN;end, end
        handles.data.dataList(iVal,:,:)=dataList;
    end
end
if any(handles.BSAPVValid)
    isBLD=strcmp({readPV.name},'BLD:SYS0:500:PCAV_FITTIME1');
    if any(isBLD)
        readPV(find(isBLD,1)).val=circshift(readPV(find(isBLD,1)).val,[0 -1]);
    end
    isBLD=strcmp({readPV.name},'BLD:SYS0:500:PCAV_FITTIME2');
    if any(isBLD)
        readPV(find(isBLD,1)).val=circshift(readPV(find(isBLD,1)).val,[0 -1]);
    end
    handles.data.readPV(use,iVal,1:handles.dataSample.nVal)=repmat(readPV,1,handles.dataSample.nVal);
    for j=1:handles.dataSample.nVal
        for k=1:length(use)
            tsList=(1-length(readPV(k).val):0)/24/60/60/360*rate+readPV(k).ts;
            handles.data.readPV(use(k),iVal,j).val=readPV(k).val(useSample(j));
            handles.data.readPV(use(k),iVal,j).ts=tsList(useSample(j));
        end
    end
    guidata(hObject,handles);
end
if ~all(handles.BSAPVValid)
    use=handles.readPVValid & ~handles.BSAPVValid;
    bad=~handles.readPVValid;id=handles.readPVValidId;
    for l=1:handles.dataSample.nVal
        gui_statusDisp(handles,sprintf('Getting Sample #%d',l));
        if any(use)
            handles.data.readPV(use,iVal,l)=handles.data.readPV(use,id,1);
            readPV=util_readPV(handles.readPVNameList(use),0,1);
            [handles.data.readPV(use,iVal,l).val]=deal(readPV.val);
            [handles.data.readPV(use,iVal,l).ts]=deal(readPV.ts);
        end
        handles.data.readPV(bad,iVal,l)=handles.data.readPV(bad,id,1);
        guidata(hObject,handles);
        pause(handles.acquireSampleDelay);
        handles=guidata(hObject);
    end
end

gui_statusDisp(handles,sprintf('Done Data Acquisition'));

% % if ~isempty(get(handles.pausePVName_txt, 'Value'));
% %     pauseDataAcq(hObject, handles);
% % end

handles.data.status(iVal)=1;
handles.data.ts=getTitle(handles.data);
if ~isfield(handles.data,'use'), handles.data.use=ones(prod(handles.dataDevice.nVal),handles.dataSample.nVal);end
handles.data.use(iVal,1:handles.dataSample.nVal)=1;
handles=acquireUpdate(hObject,handles,prescan);


% ------------------------------------------------------------------------
 function handles = acquireStart(hObject, handles, prescan)
if nargin < 3, prescan=0;end
% Set running or return if already running.
%handles.readPVNameList='GDET:FEE1:242:ENRC';

handles = appSetup(hObject, handles);


handles.readPVNameList={...
    'BPMS:IN20:221:TMIT';
    'GDET:FEE1:241:ENRC'
    'GDET:FEE1:242:ENRC'
    'GDET:FEE1:361:ENRC'
    'GDET:FEE1:362:ENRC'
    };

handles=ctrlPVControl(hObject,handles,[],1);



if gui_acquireStatusSet(hObject,handles,1);return, end
[handles,cancd]=acquireReset(hObject,handles);
if cancd, gui_acquireStatusSet(hObject,handles,0);return, end
relative=0; %flag for relative PV set vs. absolute

%if multiknob, assign PV prior to scan
% % mkb_str=get(handles.ctrlMKBName_txt,'String');
% % mkb_name=mkb_str{1};
% % if ~isempty(mkb_name)
% %     idx=strfind(lower(mkb_name),'.mkb');
% %     if isempty(idx)
% %         mkb_name=[mkb_name '.mkb'];
% %     end
% %     if ispc
% %         mkbPV = AssignMultiknob(mkb_name,'C:');
% %     else
% %         mkbPV = AssignMultiknob(mkb_name);
% %     end
% %     if ~isempty(mkbPV) && ~strcmpi(mkbPV, 'MKB:VAL')
% %         set(handles.ctrlPVName_txt,'String',[mkbPV ':VAL']);
% %         handles=ctrlPVControl(hObject,handles,[mkbPV ':VAL'],1);
% %     elseif ~isempty(mkbPV) && strcmpi(mkbPV, 'MKB:VAL')
% %         set(handles.ctrlPVName_txt,'String','MKB:VAL');
% %         handles=ctrlPVControl(hObject,handles,'MKB:VAL',1);
% %         relative=1;
% %     end
% % end

dataAcquire=1;
while dataAcquire

    if handles.ctrlPVNum > 0 && ~handles.acquireRandomOrder && ~handles.acquireZigzagOrder
        handles=ctrlPVSet(hObject,handles,1,1);
    end
    slowList=1:handles.dataDevice.nVal(1);
    fastList=1:handles.dataDevice.nVal(2);
    if handles.acquireRandomOrder
        slowList=randperm(slowList(end));
        fastList=randperm(fastList(end));
    end
    if handles.acquireZigzagOrder
        [slowList, fastList]=acquireZigzagList(handles,slowList,fastList);
        handles.ctrlPVValList{1}(slowList)
    end
    if handles.acquireSpiralOrder
        [x,y]=meshgrid(slowList,fastList);x=x(:);y=y(:);
        r=max(abs(x-mean(x)),abs(y-mean(y)));
        p=mod(atan2(y-mean(y),x-mean(x))+pi/4-1e-10,2*pi);
        [d,ix]=sortrows([r p]);
        slowList=[x(ix)';1:length(x)];fastList=y(ix);
    end
    for jj=slowList
        j=jj(1);
        if handles.ctrlPVNum > 0
            handles=dataCurrentDeviceControl(hObject,handles,j,1);
            str=sprintf('Data point #%d setting %s to %6.3f',j,handles.ctrlPVName{1},handles.ctrlPVValList{1}(j));
            disp(str);set(handles.status_txt,'String',str);
            handles=ctrlPVSet(hObject,handles,1,0,relative,slowList,j);
        end

        for k=fastList(min(end,jj(end)),:)
            if handles.ctrlPVNum > 1
                handles=dataCurrentDeviceControl(hObject,handles,k,2);
                str=sprintf('Data point #%d setting %s to %6.3f',k,handles.ctrlPVName{2},handles.ctrlPVValList{2}(k));
                disp(str);set(handles.status_txt,'String',str);
                handles=ctrlPVSet(hObject,handles,2);
            end
            handles=acquireCurrentGet(hObject,handles,'remote',prescan);
            if ~gui_acquireStatusGet(hObject,handles), break, end
        end
        if ~gui_acquireStatusGet(hObject,handles), break, end
    end



    dataAcquire=0;
    if prescan
        handles.data.prescan=1;
        prompt = {'Enter Control PV Low Value:','Enter Control PV High Value:', ...
            'Enter # of Control PV Values'};
        dlg_title = 'More Data?';
        num_lines = 1;
        nvals=get(handles.ctrlPVValNum_txt,'String');
        def={'','',nvals};
        options.Resize='on';
        answer = inputdlg(prompt,dlg_title,num_lines,def,options);
        if ~isempty(answer)
            dataAcquire=1;
            lo_val=str2num(answer{1});
            hi_val=str2num(answer{2});
            n_vals=str2num(answer{3});
            set(handles.ctrlPVRangeLow_txt,'String',num2str(lo_val));
            set(handles.ctrlPVRangeHigh_txt,'String',num2str(hi_val));
            set(handles.ctrlPVValNum_txt,'String',num2str(n_vals));
            handles.data_old=handles.data;
            handles = ctrlPVValNumControl(handles.ctrlPVValNum_txt, handles, n_vals, 1, 1);
            handles = ctrlPVRangeControl(handles.ctrlPVRangeLow_txt, handles, 1, lo_val, 1,1);
            handles = ctrlPVRangeControl(handles.ctrlPVRangeHigh_txt, handles, 2, hi_val, 1,1);
            handles=dataMerge(hObject,handles);
        end
    end
end

if prescan
    handles=sortData(hObject,handles);
end
handles=ctrlPVReset(hObject,handles,relative,slowList);
gui_acquireStatusSet(hObject,handles,0);

% % if ~isempty(mkb_name)
% %     DeassignMultiknob(mkbPV);
% % end


% ------------------------------------------------------------------------
function plotProfile(hObject, handles)

data=handles.data;
if ~data.status(handles.dataDevice.iVal)
    %cla(handles.plotProf_ax);
    return
end

if handles.process.showImg && isfield(data,'dataList')
    imgData=data.dataList(handles.dataDevice.iVal,handles.dataSample.iVal,:);
    bits=8;
    if isfield(handles.process,'showAutoScale') && handles.process.showAutoScale, bits=0;end
    if numel(imgData) > 1
        figure(2);
        for j=1:numel(imgData)
            profmon_imgPlot(imgData(j),'axes',subplot(2,2,j,'Parent',2),'bits',bits);
        end
    else
        %profmon_imgPlot(imgData,'axes',handles.plotProf_ax,'bits',bits);
    end
    return
end

iMethod=handles.dataMethod.iVal;
%opts.axes=handles.plotProf_ax;
plane=handles.wirePlane;beam={};

for tag={'beam' 'wireBeam' 'blenBeam'}
    if ~isfield(data,tag), continue, end
    if isempty(data.(tag{:})(1).stats), continue, end
    beam=[beam;num2cell(squeeze(data.(tag{:})(handles.dataDevice.iVal,min(handles.dataSample.iVal,end),iMethod,:)))];
end

if handles.blenId && isfield(data,'blenBeam'), plane='y';end

for j=1:numel(beam), opts.num=j;beamAnalysis_profilePlot(beam{j},plane,opts);end
%hold(opts.axes,'off');
if ~isempty(beam), set(handles.dataMethod_txt,'String',beam{1}.method);end


% ------------------------------------------------------------------------
function lettList = getLetters(nPV)

lett='a':'z';
[lett1,lett2]=meshgrid(lett);
lett=[cellstr(lett');cellstr([lett1(:) lett2(:)])];
lett(ismember(lett,iskeyword))=[];
lettList=cell(nPV,1);
lettList(1:min(length(lett),end))=lett(1:min(nPV,end));


% ------------------------------------------------------------------------
function [dispPV, dispPVVal] = calcPVs(hObject, handles, dispPV, dispPVVal)

nPV=size(dispPV,1);
lett=getLetters(nPV);
str=sprintf(',%s',lett{:});
fDecl=['f=@(' str(2:end) ') '];
valList=num2cell(dispPVVal,[2 3]);
for j=1:length(handles.calcPVNameList)
    name=lower(handles.calcPVNameList{j});
    x=NaN;
    try
        evalc([fDecl name]);
        x=f(valList{:});
    catch
    end
    dispPVVal(nPV+j,:)=x(:);
    [dispPV(nPV+j,:,:).name]=deal(name);
    [dispPV(nPV+j,:,:).val]=deal(0);
    [dispPV(nPV+j,:,:).ts]=deal(dispPV(1,:,:).ts);
    [dispPV(nPV+j,:,:).desc]=deal('');
    [dispPV(nPV+j,:,:).egu]=deal('');
end


% ------------------------------------------------------------------------
function handles = plotData(hObject, handles, prescan)
if nargin<3
    if isfield (handles.data, 'prescan')
        prescan=handles.data.prescan;
    else
    prescan=0;
    end
end
if ~any(handles.data.status)
    cla(handles.plotData_ax);
    return
end
if prescan
    nval=size(handles.data.status);
else
    nval=handles.dataDevice.nVal;
end
cols={'k' 'default'};
% use=reshape(handles.data.use,[handles.dataDevice.nVal([2 1]) handles.dataSample.nVal]);
use=reshape(handles.data.use,[nval([2 1]) handles.dataSample.nVal]);
use=use(:,handles.dataDevice.jVal(1),:);
% set(handles.dataDeviceUse_box,'Value',all(use(:)),'BackgroundColor',cols{(all(use(:)) | ~any(use(:)))+1});
try
    use=handles.data.use(handles.dataDevice.iVal,:);
    %set(handles.dataDeviceUse2_box,'Value',all(use),'BackgroundColor',cols{(all(use) | ~any(use))+1});
catch
end
% set(handles.dataSampleUse_box,'Value',handles.data.use(handles.dataDevice.iVal,handles.dataSample.iVal));

% Generate PV list.
nSample=handles.acquireSampleNum;
use=handles.data.status == 1;
dispPV=struct('name',{},'val',{},'ts',{},'desc',{},'egu',{});
nCtrl=handles.ctrlPVNum;
if ~isempty(handles.data.ctrlPV)
    dispPV=repmat(handles.data.ctrlPV(1:nCtrl,use),[1 1 nSample]);
end
if isfield(handles.data,'readPV')
    dispPV=[dispPV;handles.data.readPV(:,use,:)];
end
nPV=size(dispPV,1);

iMethod=handles.dataMethod.iVal;
iPlane=1;if strcmpi(handles.wirePlane,'y'), iPlane=2;end
beamStd=zeros(sum(use),0);

% Add PVs values if profmons used.
if any(handles.profmonId) && isfield(handles.data,'profPV')
    dispPV=[dispPV;reshape(permute(handles.data.profPV(:,use,:,:),[1 4 2 3]),[],sum(use),size(handles.data.profPV,3))];
end

% Add y values if wire scanner used.
if handles.wireId
    dispPV=[dispPV;handles.data.wirePV([[0 2]+iPlane 6],use,:)];
end

% Add y values if emittance scan used.
if handles.emitId
    dispPV=[dispPV;handles.data.twissPV(:,use,:)];
    beamStd=[beamStd handles.data.twissStd(use,:,iMethod)];
end

% Add y values if bunch length used.
if handles.blenId
    dispPV=[dispPV;handles.data.blenPV(:,use,:)];
    beamStd=[beamStd handles.data.blenStd(use,:,iMethod)];
end

val=num2cell(vertcat(dispPV(nPV+1:end,:).val));
[dispPV(nPV+1:end,:).val]=deal(val{:,iMethod});

dispSize=cellfun('size',{dispPV.val},2);
if ~all(dispSize == max(dispSize))
    for j=1:numel(dispPV)
        dispPV(j).val(1,end+1:max(dispSize))=0;
    end
end

dispPVVal=reshape([dispPV.val],size(dispPV,1),size(dispPV,2),[]);
idBeam=size(dispPVVal,1)+(-(size(beamStd,2)-1):0);
[dispPV,dispPVVal]=calcPVs(hObject,handles,dispPV,dispPVVal);
dispPVVal(:,~handles.data.use(use,:))=NaN;
dispPVValMean=util_meanNan(dispPVVal,3);
dispPVValStd=util_stdNan(dispPVVal,1,3)./sqrt(sum(~isnan(dispPVVal),3)); % !!! Error on mean value now
dispPVValStd(idBeam,:)=permute(beamStd,[2 1]);

if handles.process.dataDisp
    assignin('base','dispPVVal',dispPVVal);
    assignin('base','dispPVValStd',dispPVValStd);
    assignin('base','dispPVValMean',dispPVValMean);
    evalin('base','openvar(''dispPVValStd'')');
    evalin('base','openvar(''dispPVValMean'')');
end

id=handles.plotYAxisId+nCtrl;
yPV=dispPV(id,:,:);
yPVVal=dispPVVal(id,:,:);
yPVValMean=dispPVValMean(id,:);
yPVValStd=dispPVValStd(id,:);

% Generate x PV.
id=handles.plotXAxisId;
if id == 0
    xPV.name='TIME';xPV.desc='Elapsed Time';xPV.egu='s';
    xPV=repmat(xPV,[1 size(yPV,2) nSample]);
    xPVVal=reshape([yPV.ts],size(yPV,1),size(yPV,2),[])-yPV(1).ts;
    xPVValStd=std(xPVVal,1,3);
    xPVValMean=mean(xPVVal,3);
else
    xPV=dispPV(id,:,:);
    xPVVal=dispPVVal(id,:,:);
    xPVValStd=dispPVValStd(id,:);
    xPVValMean=dispPVValMean(id,:);
end

% Generate u PV.
id=handles.plotUAxisId;uPVVal=[];uPVValMean=[];
if id > 0
    uPV=dispPV(id,:,:);
    uPVVal=dispPVVal(id,:,:);
%    uPVValStd=dispPVValStd(id,:);
    uPVValMean=dispPVValMean(id,:);
end

% Fit functions.
if handles.showAverage
    xValList=xPVValMean;uValList=uPVValMean;
    yValList=yPVValMean;yStdList=yPVValStd;xStdList=xPVValStd;
    if ~all(xStdList), xStdList=xStdList*NaN;end
else
    xValList=reshape(permute(xPVVal,[1 3 2]),size(xPVVal,1),[]);
    uValList=reshape(permute(uPVVal,[1 3 2]),size(uPVVal,1),[]);
    yValList=reshape(permute(yPVVal,[1 3 2]),size(yPVVal,1),[]);
    yStdList=repmat(yValList,1,0);
end
if handles.showSmoothing
    [xValList,yValList]=util_scanSmooth(xValList,yValList,handles.showWindowSize.jVal);
end
xFit=linspace(min(xValList(:)),max(xValList(:)),100);
par=[];
for j=1:size(yPVVal,1)
    xVal=xValList(min(j,end),:);yVal=yValList(j,:);yStd=yStdList(j,:);

    switch handles.showFit
        case 0 % No Fit
            yFit(j,:)=NaN*xFit;
            yFitStd(j,:)=NaN*xFit;
            strFitList{j}='';
        case 1 % PolyFit
            pOrd=min(handles.showFitOrder,length(xVal)-1);
            [par,yFit(j,:),parstd,yFitStd(j,:),chisq,d,rfe]=util_polyFit(xVal,yVal,pOrd,yStd,xFit);
            ex=length(par)-1:-1:0;
            lab=cellstr(char(64+(1:length(par)))')';
            ch=[lab;num2cell(ex)];
            strFit=sprintf('+ %s x^%d ',ch{:});
        case 2 % Gaussian
            strFit='A exp((x - B)^2/C^2/2) + D';
            [par,yFit(j,:),parstd,yFitStd(j,:),chisq,d,rfe]=util_gaussFit(xVal,yVal,1,0,yStd,xFit);
        case 3 % Sine
            strFit='A sin((x - B)C) + D';
            [par,yFit(j,:),parstd,yFitStd(j,:),chisq,d,rfe]=util_sineFit(xVal,yVal,1,yStd,xFit);
        case 4 % ParabFit
            strFit='A (x - B)^2 + C';
            [par,yFit(j,:),parstd,yFitStd(j,:),chisq,d,rfe]=util_parabFit(xVal,yVal,yStd,xFit);
        case 5 % Error function
            strFit='A erfc(-(x - B)/C) + D';
            [par,yFit(j,:),parstd,yFitStd(j,:),chisq,d,rfe]=util_erfFit(xVal,yVal,1,yStd,xFit);
    end
    if handles.showFit
        lab=cellstr(char(64+(1:length(par)))')';
        str=[lab;num2cell([par parstd]')];
        strFitList{j}=[sprintf('y = %s\n',strFit) ...
                       sprintf('%s = %7.5g+-%7.5g\n',str{:}) ...
                       sprintf('\\chi^2/NDF = %5.3g\n',chisq) ...
                       sprintf('rms fit error = %5.3g %s',rfe,yPV(j).egu)];
    end
end
handles.fitPar=par;
guidata(hObject,handles);

% Plot results.
ax=handles.plotData_ax;
if handles.process.displayExport, ax=gca;end

util_errorBand(xFit,yFit,yFitStd,'Parent',ax);
hold(ax,'on');
plot(xFit,yFit,'Parent',ax);
pSym='*';
if handles.showLines
    if handles.showSmoothing
        pSym='-';
    else
        pSym=['--' pSym];
    end
end
if handles.showAverage
    if size(xValList,1) == 1
        xValList=repmat(xValList,size(yValList,1),1);
        xStdList=repmat(xStdList,size(yValList,1),1);
        uValList=repmat(uValList,size(yValList,1),1);
    end
    xtr=xValList(:,1)*NaN;
    h=errorbarh([xValList xtr]',[yValList xtr]',[xStdList xtr]',[yStdList xtr]',pSym,'Parent',ax);
else
    h=plot(xValList',yValList',pSym,'Parent',ax);
end
hold(ax,'off');
xLim=get(ax,'XLim');yLim=get(ax,'YLim');
for j=1:size(yPVVal,1)
    xTxt=[1-(.1+j/2-.5) (.1+j/2-.5)]*xLim(:);
    yTxt=[1-.90 .90]*yLim(:);
    col='k';if size(yPVVal,1) > 1, col=get(h(min(j,end)),'Color');end
    text(xTxt,yTxt,strFitList{j},'VerticalAlignment','top','Parent',ax, ...
        'Color',col);
end
xLim2=[min(xValList(:)) max(xValList(:))];if diff(xLim2), xLim=xLim2;end
set(ax,'XLim',mean(xLim)+diff(xLim)/2*[-1 1]*1.1);
set(ax,'YLim',mean(yLim)+diff(yLim)/2*[-1 1]*1.1);

if handles.plotXAxisId == 0
    datetick(ax,'x','keeplimits');
end
xlabel(ax,[strrep(xPV(1).name,'_','\_') ' ' xPV(1).desc ' (' xPV(1).egu ')']);
ylabel(ax,[strrep(yPV(1).name,'_','\_') ' ' yPV(1).desc ' (' yPV(1).egu ')']);
title(ax,strrep([handles.plotHeader ' ' datestr(handles.data.ts)],'_','\_'));
legend(ax,h,strrep({yPV(:,1).name},'_','\_'),'Location','NorthWest');
legend(ax,'boxoff');
str={'linear' 'log'};
set(ax,'XScale',str{handles.showLogX+1},'YScale',str{handles.showLogY+1});

if ~handles.show2D || ~id, return, end
figure(3);
switch handles.show2D
    case 1
        if ~all(handles.data.status), return, end
        siz=handles.dataDevice.nVal([2 1]);
        if ~all(siz > 1), return, end
        xPVValMean=reshape(xPVValMean,siz);
        uPVValMean=reshape(uPVValMean,siz);
        surf(xPVValMean,uPVValMean,reshape(yPVValMean(1,:),siz));
        shading interp
    case 2
        cols=get(gca,'ColorOrder');
        for j=1:size(yPVVal,1)
            y=yPVValMean(j,:);
            scatter(xPVValMean(min(j,end),:),uPVValMean(:),100*(.05+(y-min(y))/(max(y)-min(y))),cols(1+mod(j-1,7),:));
            hold on
        end
        hold off
    case 3
        plot3(xValList',uValList',yValList',pSym);
end
ax=gca;set(ax,'Box','on');
xlabel(ax,[strrep(xPV(1).name,'_','\_') ' ' xPV(1).desc ' (' xPV(1).egu ')']);
ylabel(ax,[strrep(uPV(1).name,'_','\_') ' ' uPV(1).desc ' (' uPV(1).egu ')']);
zlabel(ax,[strrep(yPV(1).name,'_','\_') ' ' yPV(1).desc ' (' yPV(1).egu ')']);
title(ax,strrep([handles.plotHeader ' ' datestr(handles.data.ts)],'_','\_'));



% ------------------------------------------------------------------------
function handles = dataMethodControl(hObject, handles, iVal, nVal)

if isempty(iVal)
    iVal=handles.processSelectMethod;
end
vis=any([handles.profmonId handles.wireId handles.emitId handles.blenId]);
handles=gui_sliderControl(hObject,handles,'dataMethod',iVal,nVal,vis);

handles.processSelectMethod=iVal;
guidata(hObject,handles);
acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireUpdate(hObject, handles, prescan)
if nargin<3, prescan=0; end
guidata(hObject,handles);

handles.plotHeader='Correlation Plot ';

data=handles.data;
if ~any(data.status), handles=acquirePlot(hObject,handles);return, end
if prescan
    nval=size(handles.data.status);else
    nval=handles.dataDevice.nVal;
end
if ~isfield(handles.data,'use'), handles.data.use=ones(prod(nval),handles.dataSample.nVal);end
% if ~isfield(handles.data,'use'), handles.data.use=ones(prod(handles.dataDevice.nVal),handles.dataSample.nVal);end
if handles.process.displayExport
    handles.exportFig=figure;
end
guidata(hObject,handles);
handles=acquirePlot(hObject,handles,prescan);


% ------------------------------------------------------------------------
    function handles = acquirePlot(hObject, handles, prescan)
        if nargin<3, prescan=0; end
        plotProfile(hObject,handles);
        try
            handles=plotData(hObject,handles,prescan);
            if handles.extGui
                test_btn_Callback(hObject, [], handles);
            end
        catch
end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function ts = getTitle(data)

ts=now;
if isfield(data,'readPV'), ts=[data.readPV(1).ts ts];end
if isfield(data,'profPV'), ts=[data.profPV(1).ts ts];end
if isfield(data,'wirePV'), ts=[data.wirePV(1).ts ts];end
if isfield(data,'twissPV'), ts=[data.twissPV(1).ts ts];end
if isfield(data,'blenPV'), ts=[data.blenPV(1).ts ts];end
if ts(1) < 733000 || ts(1) > now, ts=now;end
ts=ts(1);


% % % -----------------------------------------------------------
% % function handles = dataExport(hObject, handles, val)
% %
% % handles.process.displayExport=1;
% % handles=acquireUpdate(hObject,handles);
% % handles.process.displayExport=0;
% % guidata(hObject,handles);
% % util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
% % if val
% %     util_appPrintLog(handles.exportFig,handles.plotHeader,handles.ctrlPVName{1},handles.data.ts);
% %     dataSave(hObject,handles,0);
% % %    util_printLog(handles.exportFig);
% % end


% % % -----------------------------------------------------------
% % function handles = dataSave(hObject, handles, val)
% %
% % data=handles.data;
% % if ~any(data.status), return, end
% % if isfield(data,'dataList')
% %     if handles.process.saveImg
% %         butList={'Proceed' 'Discard Images'};
% %         button=questdlg('Save data with images?','Save Images',butList{:},butList{2});
% %         if strcmp(button,butList{2}), data=rmfield(data,'dataList');end
% %     else
% %         data=rmfield(data,'dataList');
% %     end
% % end
% % if isfield(data,'use'), data=rmfield(data,'use');end
% %
% % for tag=handles.configList
% %     data.config.(tag{:})=handles.(tag{:});
% % end
% % pvname = handles.ctrlPVName{1}(handles.ctrlPVName{1} ~= '/');
% % fileName=util_dataSave(data,strrep(handles.plotHeader,' ',''),pvname,data.ts,val);
% % if ~ischar(fileName), return, end
% % handles.fileName=fileName;
% % handles.process.saved=1;
% %
% % str={'*' ''};
% % set(handles.output,'Name',['Correlation Plot - [' handles.fileName ']' str{handles.process.saved+1}]);
% % guidata(hObject,handles);

% %
% % % -----------------------------------------------------------
% % function handles = dataOpen(hObject, handles, val)
% % prescan=0; handles.ctrlMKBName=''; handles.acquireZigzagOrder=0;
% % if nargin == 3, fileName=val;
% %     load(fileName,'data');
% % else
% %     [data,fileName]=util_dataLoad('Open Correlation Plot');
% % end
% % if ~ischar(fileName), return, end
% % handles=acquireReset(hObject,handles);
% % handles.process.saved=1;
% % handles.process.loading=1;
% %
% % if 0, data_test(data);end
% %
% % % Initialize.
% % for tag=handles.configList
% %     if isfield(data.config,tag{:})
% %         handles.(tag{:})=data.config.(tag{:});
% %     end
% % end
% % data=rmfield(data,'config');
% % handles=appSetup(hObject,handles);
% %
% % % Put data in storage and update.
% % handles.data=data;
% % handles.fileName=fileName;
% % handles.process.loading=0;
% % str={'*' ''};
% % set(handles.output,'Name',['Correlation Plot - [' handles.fileName ']' str{handles.process.saved+1}]);
% % guidata(hObject,handles);
% % if isfield (handles.data, 'prescan')
% %     prescan=1;
% % end
% % handles=acquireUpdate(hObject,handles,prescan);


% ------------------------------------------------------------------------
function data_test(data)

if ~isfield(data,'ts'), keyboard;end
[d,fn]=fileparts(fileName);
plotHeader=strtok(fn,'-');
ctrlPVNum=size(data.ctrlPV,1);
ctrlPVValNum=[1 1];ctrlPVName={'' ''}';ctrlPVRange={0 0;0 0};
if ctrlPVNum
    ctrlPVName(1:ctrlPVNum)={data.ctrlPV(:,1).name};
    ctrlPVValNum(1)=size(data.ctrlPV,2);
    ctrlPVRange(1:ctrlPVNum,:)=reshape({data.ctrlPV(:,[1 end]).val},[],2);
end
if ctrlPVNum > 1
    ctrlPVValNum(1)=length(unique([data.ctrlPV(1,:).val]));
    ctrlPVValNum(2)=size(data.ctrlPV,2)/ctrlPVValNum(1);
end
valnum=prod(ctrlPVValNum);

readPVNameList=cell(0,1);
acquireSampleNum=0;
if isfield(data,'readPV')
    readPVNameList={data.readPV(:,1).name}';
    acquireSampleNum=size(data.readPV,3);
    if valnum ~= size(data.readPV,2), keyboard;end
end
if xor(isfield(data,'beam'),isfield(data,'profPV')), keyboard;end
profmonName='';profmonId=0;
if isfield(data,'profPV')
    profmonName=data.profPV(1).name(1:end-2);profmonId=1;
    if valnum ~= size(data.profPV,2), keyboard;end
    if acquireSampleNum && acquireSampleNum ~= size(data.profPV,3), keyboard;end
    acquireSampleNum=size(data.profPV,3);
end
if isfield(data,'twiss')
    if ~isfield(data,'twissPV'), keyboard;end
    if ~isfield(data,'twissStd'), keyboard;end
end
if isfield(data,'twissPV')
    if ~isfield(data,'twissStd'), keyboard;end
end

emitName='';emitId=0;
if isfield(data,'twissPV')
    emitName=data.twissPV(1).name(1:end-6);emitId=1;
    if valnum ~= size(data.twissPV,2), keyboard;end
    if acquireSampleNum && acquireSampleNum ~= size(data.twissPV,3), keyboard;end
    acquireSampleNum=size(data.twissPV,3);
end
if xor(isfield(data,'wireBeam'),isfield(data,'wirePV')), keyboard;end
wireName='';wireId=0;
if isfield(data,'wirePV')
    wireName=data.wirePV(1).name(1:end-2);wireId=1;
    if valnum ~= size(data.wirePV,2), keyboard;end
    if acquireSampleNum && acquireSampleNum ~= size(data.wirePV,3), keyboard;end
    acquireSampleNum=size(data.wirePV,3);
end
ts=getTitle(data);
fntest=strrep([plotHeader '-' ctrlPVName '-' datestr(ts,'yyyy-mm-dd-HHMMSS')],':','_');

config=data.config;
if ~strcmp(strrep(config.plotHeader,' ',''),plotHeader), keyboard;end
if ~strncmp(fn,fntest,length(fntest)), keyboard;end
if config.ctrlPVNum ~= ctrlPVNum, keyboard;end
if ~all(strcmp(config.ctrlPVName(:),ctrlPVName(:))), keyboard;end
if ctrlPVNum && any([config.ctrlPVRange{1,:}] ~= [ctrlPVRange{1,:}]), keyboard;end
if ctrlPVNum > 1 && any([config.ctrlPVRange{:}] ~= [ctrlPVRange{:}]), keyboard;end
if ctrlPVNum && any(config.ctrlPVValNum(1) ~= ctrlPVValNum(1)), keyboard;end
if ctrlPVNum > 1 && any(config.ctrlPVValNum ~= ctrlPVValNum), keyboard;end
if numel(config.readPVNameList) ~= numel(readPVNameList), keyboard;end
if ~all(strcmp(config.readPVNameList,readPVNameList)), keyboard;end
if any(config.acquireSampleNum ~= acquireSampleNum), keyboard;end
if xor(config.profmonId,profmonId), keyboard;end
if xor(config.emitId,emitId), keyboard;end
if xor(config.wireId,wireId), keyboard;end
if profmonId && ~strcmp(handles.profmonList(config.profmonId),profmonName), keyboard;end
if emitId && ~strcmp(handles.emitList(config.emitId),emitName), keyboard;end
if wireId && ~strcmp(handles.wireList(config.wireId),wireName), keyboard;end


% % % --- Executes on slider movement.
% % function dataDevice_sl_Callback(hObject, eventdata, handles, num)
% %
% % handles=dataCurrentDeviceControl(hObject,handles,round(get(hObject,'Value')),num);
% % acquirePlot(hObject,handles);


% % % --- Executes on slider movement.
% % function dataMethod_sl_Callback(hObject, eventdata, handles)
% %
% % dataMethodControl(hObject,handles,round(get(hObject,'Value')),[]);


% % % --- Executes on slider movement.
% % function dataSample_sl_Callback(hObject, eventdata, handles)
% %
% % handles=dataCurrentSampleControl(hObject,handles,round(get(hObject,'Value')),[]);
% % acquirePlot(hObject,handles);


% % function acquireSampleNum_txt_Callback(hObject, eventdata, handles)
% %
% % acquireSampleNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


% % % --- Executes on button press in appSave_btn.
% % function appSave_btn_Callback(hObject, eventdata, handles)
% %
% % appSave(hObject,handles);


% % % --- Executes on button press in appLoad_btn.
% % function appLoad_btn_Callback(hObject, eventdata, handles)
% %
% % appLoad(hObject,handles);


% --- Executes on button press in sectorSelIN20_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag)

sectorInit(hObject,handles,tag);


% --- Executes on button press in _btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)
handles.extGui =0;
guidata(hObject, handles);
set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% % function ctrlPVValNum_txt_Callback(hObject, eventdata, handles, num)
% %
% % ctrlPVValNumControl(hObject,handles,round(str2double(get(hObject,'String'))),num);

% %
% % function ctrlPVRange_txt_Callback(hObject, eventdata, handles, tag, num)
% %
% % %If the value in the textbox is not parsable as a double, check if it is of
% % %the format 'number*init'.  If it is, use the inital value for the PV
% % %multiplied by 'number' for the low or high limit.
% % parsedNum = str2double(get(hObject,'String'));
% % if isnan(parsedNum)
% %     tokens = regexp(get(hObject,'String'),'^(\d*\.?\d+)(\s*\*\s*init)','tokens');
% %     if ~isempty(tokens)
% %         parsedNum = str2double(tokens{1}(1)) * handles.ctrlPV(num).val;
% %     else
% %         parsedNum = NaN;
% %     end
% % end
% %
% % ctrlPVRangeControl(hObject,handles,tag,parsedNum,num);

% %
% % function ctrlPVValStep_txt_Callback(hObject, eventdata, handles, num)
% %
% % ctrlPVValStepControl(hObject,handles,str2double(get(hObject,'String')),num);


% --- Executes on button press in ctrlPVSet_btn.
function ctrlPVSet_btn_Callback(hObject, eventdata, handles, num)

ctrlPVSet(hObject,handles,num);

% %
% % % --- Executes on button press in ctrlPVReset_btn.
% % function ctrlPVReset_btn_Callback(hObject, eventdata, handles)
% %
% % ctrlPVReset(hObject,handles);


% % % --- Executes on button press in acquireCurrentGet_btn.
% % function acquireCurrentGet_btn_Callback(hObject, eventdata, handles)
% %
% % acquireCurrentGet(hObject,handles,'query');


% % function ctrlPVName_txt_Callback(hObject, eventdata, handles, num)
% %
% % ctrlPVControl(hObject,handles,get(hObject,'String'),num);

% %
% % function readPVNameList_txt_Callback(hObject, eventdata, handles)
% %
% % readPVControl(hObject,handles,get(hObject,'String'));

% %
% % function ctrlPVWait_txt_Callback(hObject, eventdata, handles, num)
% %
% % ctrlPVWaitControl(hObject,handles,str2double(get(hObject,'String')),num);


% % % --- Executes on selection change in plotXAxisID_pmu.
% % function plotXAxisId_pmu_Callback(hObject, eventdata, handles)
% %
% % plotXAxisControl(hObject,handles,get(hObject,'Value')-1);


% --- Executes on selection change in plotYAxisID_lbx.
function plotYAxisId_lbx_Callback(hObject, eventdata, handles)

plotYAxisControl(hObject,handles,get(handles.plotYAxisId_lbx,'Value'));


% % % --- Executes on selection change in plotUAxisId_pmu.
% % function plotUAxisId_pmu_Callback(hObject, eventdata, handles)
% %
% % plotUAxisControl(hObject,handles,get(hObject,'Value')-1);


function plotHeader_txt_Callback(hObject, eventdata, handles)

plotHeaderControl(hObject,handles,get(hObject,'String'));


% % % --- Executes on button press in showAverage_box.
% % function showAverage_box_Callback(hObject, eventdata, handles)
% %
% % handles=showSmoothingControl(handles.showSmoothing_box,handles,0);
% % showAverageControl(hObject,handles,get(hObject,'Value'));


function ctrlPVWaitInit_txt_Callback(hObject, eventdata, handles)

ctrlPVWaitInitControl(hObject,handles,str2double(get(hObject,'String')));

% %
% % % --- Executes on button press in showFit_pmu.
% % function showFit_pmu_Callback(hObject, eventdata, handles)
% %
% % showFitControl(hObject,handles,get(hObject,'Value')-1);


% % function showFitOrder_txt_Callback(hObject, eventdata, handles)
% %
% % showFitOrderControl(hObject,handles,str2double(get(hObject,'String')));


% % % --- Executes on button press in show2D_pmu.
% % function show2D_pmu_Callback(hObject, eventdata, handles)
% %
% % show2DControl(hObject,handles,get(hObject,'Value')-1);


% % % --- Executes on button press in showLines_box.
% % function showLines_box_Callback(hObject, eventdata, handles)
% %
% % showLinesControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on selection change in profmonYAxisId_lbx_pmu.
% % function profmon_pmu_Callback(hObject, eventdata, handles)
% %
% % profmonControl(hObject,handles,get(hObject,'Value'));


% % --- Executes on selection change in wire_pmu.
% function wire_pmu_Callback(hObject, eventdata, handles)
%
% wireControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on button press in wirePlaneX_rbn.
% % function wirePlane_rbn_Callback(hObject, eventdata, handles, tag)
% %
% % wirePlaneControl(hObject,handles,tag);


% % % --- Executes on button press in acquireBSA_box.
% % function acquireBSA_box_Callback(hObject, eventdata, handles)
% %
% % acquireBSAControl(hObject,handles,get(hObject,'Value')-1);


% % function profmonNumBG_txt_Callback(hObject, eventdata, handles)
% %
% % profmonNumBGControl(hObject,handles,str2double(get(hObject,'String')));

% %
% % function profmonNumAve_txt_Callback(hObject, eventdata, handles)
% %
% % profmonNumAveControl(hObject,handles,str2double(get(hObject,'String')));


% % % --- Executes on selection change in emit_pmu.
% % function emit_pmu_Callback(hObject, eventdata, handles)
% %
% % emitControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on button press in emitTypeMulti_rbn.
% % function emitType_rbn_Callback(hObject, eventdata, handles, tag)
% %
% % emitTypeControl(hObject,handles,tag);

% %
% % function acquireSampleDelay_txt_Callback(hObject, eventdata, handles)
% %
% % acquireSampleDelayControl(hObject,handles,str2double(get(hObject,'String')));


% % % --- Executes on button press in acquireRandomOrder_box.
% % function acquireRandomOrder_box_Callback(hObject, eventdata, handles)
% %
% % acquireRandomOrderControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on button press in acquireSpiralOrder_box.
% % function acquireSpiralOrder_box_Callback(hObject, eventdata, handles)
% %
% % acquireSpiralOrderControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on button press in acquireZigzagOrder_box.
% % function acquireZigzagOrder_box_Callback(hObject, eventdata, handles)
% %
% % acquireZigzagOrderControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on button press in acquireUseLEM_box.
% % function acquireUseLEM_box_Callback(hObject, eventdata, handles)
% %
% % acquireUseLEMControl(hObject,handles,get(hObject,'Value'));
% %
% %
% % function calcPVNameList_txt_Callback(hObject, eventdata, handles)
% %
% % calcPVControl(hObject,handles,get(hObject,'String'));


% % % --- Executes on selection change in blen_pmu.
% % function blen_pmu_Callback(hObject, eventdata, handles)
% %
% % blenControl(hObject,handles,get(hObject,'Value'));


% % --- Executes on button press in dataExport_btn.
% function dataExport_btn_Callback(hObject, eventdata, handles, val)
%
% dataExport(hObject,handles,val);


% % --- Executes on button press in dataSave_btn.
% function dataSave_btn_Callback(hObject, eventdata, handles, val)
%
% dataSave(hObject,handles,val);

% %
% % % --- Executes on button press in dataOpen_btn.
% % function handles = dataOpen_btn_Callback(hObject, eventdata, handles)
% %
% % dataOpen(hObject,handles);


% % % --- Executes on button press in dataSaveImg_box.
% % function dataSaveImg_box_Callback(hObject, eventdata, handles)
% %
% % %dataSaveImgControl(hObject,handles,get(hObject,'Value'));
% % handles.process.saveImg=get(hObject,'Value');
% % guidata(hObject,handles);


% % % --- Executes on button press in showImg_box.
% % function showImg_box_Callback(hObject, eventdata, handles)
% %
% % handles.process.showImg=get(hObject,'Value');
% % guidata(hObject,handles);
% % plotProfile(hObject,handles);
% %
% %
% % % --- Executes on button press in dataHoldImg_box.
% % function dataHoldImg_box_Callback(hObject, eventdata, handles)
% %
% % %dataHoldImgControl(hObject,handles,get(hObject,'Value'));
% % handles.process.holdImg=get(hObject,'Value');
% % guidata(hObject,handles);
% % vis={'off' 'on'};
% % set([handles.dataSaveImg_box handles.showImg_box handles.showAutoScale_box],'Visible',vis{1+handles.process.holdImg});
% %

% % % --- Executes on button press in dataProcImg_box.
% % function dataProcImg_box_Callback(hObject, eventdata, handles)
% %
% % handles.process.procImg=get(hObject,'Value');
% % guidata(hObject,handles);
% % vis={'off' 'on'};
% % set([handles.dataImgProc_btn handles.useImgCrop_box handles.profmonXSig_txt ...
% %     handles.profmonYSig_txt handles.profmonXSigLabel_txt handles.profmonYSigLabel_txt],'Visible',vis{1+handles.process.procImg});


% % % --- Executes on button press in dataDisp_btn.
% % function dataDisp_btn_Callback(hObject, eventdata, handles)
% %
% % handles.process.dataDisp=1;
% % handles=plotData(hObject,handles);
% % handles.process.dataDisp=0;
% % guidata(hObject,handles);


% % % --- Executes on button press in acquireSampleForce_box.
% % function acquireSampleForce_box_Callback(hObject, eventdata, handles)
% %
% % %acquireSampleForceControl(hObject,handles,get(hObject,'Value'));
% % handles.acquireSampleForce=get(hObject,'Value');
% % guidata(hObject,handles);


% % % --- Executes on button press in dataDeviceUse_box.
% % function dataDeviceUse_box_Callback(hObject, eventdata, handles)
% %
% % val=get(handles.dataDeviceUse_box,'Value');
% % use=reshape(handles.data.use,[handles.dataDevice.nVal([2 1]) handles.dataSample.nVal]);
% % use(:,handles.dataDevice.jVal(1),:)=val;
% % handles.data.use=reshape(use,[],handles.dataSample.nVal);
% % guidata(hObject,handles);
% % acquirePlot(hObject,handles);


% % % --- Executes on button press in dataDeviceUse2_box.
% % function dataDeviceUse2_box_Callback(hObject, eventdata, handles)
% %
% % handles.data.use(handles.dataDevice.iVal,:)=get(handles.dataDeviceUse2_box,'Value');
% % guidata(hObject,handles);
% % acquirePlot(hObject,handles);


% --- Executes on button press in dataSampleUse_box.
function dataSampleUse_box_Callback(hObject, eventdata, handles)

handles.data.use(handles.dataDevice.iVal,handles.dataSample.iVal)=get(handles.dataSampleUse_box,'Value');
guidata(hObject,handles);
acquirePlot(hObject,handles);


% --- Executes on button press in showLogY_box.
% % function showLogY_box_Callback(hObject, eventdata, handles)
% % prescan=0;
% % if isfield(handles.data,'prescan')
% %     prescan=1;
% % end
% % handles.showLogY=get(hObject,'Value');
% % guidata(hObject,handles);
% % acquirePlot(hObject,handles,prescan);


% % % --- Executes on button press in showLogX_box.
% % function showLogX_box_Callback(hObject, eventdata, handles)
% % prescan=0;
% % if isfield(handles.data,'prescan')
% %     prescan=1;
% % end
% % handles.showLogX=get(hObject,'Value');
% % guidata(hObject,handles);
% % acquirePlot(hObject,handles,prescan);

% %
% % % --- Executes on button press in useStaticBG_box.
% % function useStaticBG_box_Callback(hObject, eventdata, handles)
% %
% % useStaticBGControl(hObject,handles,get(hObject,'Value'));


% % % --- Executes on button press in staticBG_btn.
% % function staticBG_btn_Callback(hObject, eventdata, handles)
% %
% % if handles.useStaticBG && ~isempty(handles.profmonName)
% %     if handles.profmonNumBG
% %         opts.nBG=0;opts.bufd=1;opts.doPlot=1;opts.doProcess=0;opts.axes=handles.plotProf_ax;
% %         opts.nAvg=haGDET:FEE1:242:ENRCndles.profmonNumBG;
% %         dataList=profmon_measure(handles.profmonName,1,opts);
% %         handles.staticBG={dataList.img};
% %         set(handles.staticBG_btn,'BackgroundColor','g');
% %     else
% %         handles.staticBG=0;
% %     end
% % end
% % guidata(hObject,handles);

% %
% % % --- Executes on button press in showAutoScale_box.
% % function showAutoScale_box_Callback(hObject, eventdata, handles)
% %
% % handles.process.showAutoScale=get(hObject,'Value');
% % guidata(hObject,handles);
% % plotProfile(hObject,handles);


% % % --- Executes on button press in profmonBSA_box.
% % function profmonBSA_box_Callback(hObject, eventdata, handles)
% %
% % handles.profmonBSA=get(hObject,'Value');
% % guidata(hObject,handles);


% % % --- Executes on button press in useImgCrop_box.
% % function useImgCrop_box_Callback(hObject, eventdata, handles)
% %
% % handles.useImgCrop=get(hObject,'Value');
% % guidata(hObject,handles);


% --- Executes on button press in useCal_box.
function useCal_box_Callback(hObject, eventdata, handles)

handles.useCal=get(hObject,'Value');
guidata(hObject,handles);


% % function profmonXSig_txt_Callback(hObject, eventdata, handles)
% %
% % handles.profmonXSig=str2num(get(hObject,'String'));
% % guidata(hObject,handles);


% % function profmonYSig_txt_Callback(hObject, eventdata, handles)
% %
% % handles.profmonYSig=str2num(get(hObject,'String'));
% % guidata(hObject,handles);


% % % --- Executes on button press in dataImgProc_btn.
% % function dataImgProc_btn_Callback(hObject, eventdata, handles)
% %
% % handles=acquireImgProc(hObject,handles);
% % acquirePlot(hObject,handles);


% % % --- Executes on button press in prescan_btn.
% % function prescan_btn_Callback(hObject, eventdata, handles)
% %
% % set(hObject,'Value',~get(hObject,'Value'));
% % acquireStart(handles.acquireStart_btn,handles,1);


% -----------------------------------------------------------------------
function handles = dataMerge(hObject,handles)

fields=fieldnames(handles.data)';
for tag=fields
    nvals=prod(handles.dataDevice.nVal);
    if isfield (handles.data,tag)
        str=cell2struct(tag,'tag',1);
        switch str.tag
            case 'status'
                temp.data.status=repmat(handles.data_old.status(1),nvals,1);
                handles.data.status=[temp.data.status;handles.data_old.status];
            case 'use'
%                 if handles.dataSample.nVal > 1
                    temp.data.use=repmat(handles.data_old.use(1,:),nvals,1);
                    handles.data.use=[temp.data.use;handles.data_old.use];
%                 else
%                     temp.data.use=repmat(handles.data_old.use(1),nvals,1);
%                     handles.data.use=[temp.data.use;handles.data_old.use];
%                 end
            case 'ctrlPV'
                temp.data.ctrlPV=repmat(handles.data_old.ctrlPV(:,1),1,nvals);
                handles.data.ctrlPV=[temp.data.ctrlPV handles.data_old.ctrlPV];
            case 'readPV'
%                 if handles.dataSample.nVal > 1
                    temp.data.readPV=repmat(handles.data_old.readPV(:,1,:),1,nvals);
                    handles.data.readPV=[temp.data.readPV handles.data_old.readPV];
%                 else
%                     temp.data.readPV=repmat(handles.data_old.readPV(:,1),1,nvals);
%                     handles.data.readPV=[temp.data.readPV handles.data_old.readPV];
%                 end
            case 'twissStd'
                temp.data.twissStd=repmat(handles.data_old.twissStd(1,:,:),nvals,1);
                handles.data.twissStd=[temp.data.twissStd; handles.data_old.twissStd];
            case 'twissPV'
%                 if handles.dataSample.nVal > 1
                    temp.data.twissPV=repmat(handles.data_old.twissPV(:,1,:),1,nvals);
                    handles.data.twissPV=[temp.data.twissPV handles.data_old.twissPV];
%                 else
%                     temp.data.twissPV=repmat(handles.data_old.twissPV(:,1),1,nvals);
%                     handles.data.twissPV=[temp.data.twissPV handles.data_old.twissPV];
%                 end
            case 'beam'
                temp.data.beam=repmat(handles.data_old.beam(1,:,:),nvals,1);
                handles.data.beam=[temp.data.beam; handles.data_old.beam];
            case 'profPV'
%                 if handles.dataSample.nVal > 1
                    temp.data.profPV=repmat(handles.data_old.profPV(:,1,:),1,nvals);
                    handles.data.profPV=[temp.data.profPV handles.data_old.profPV];
%                 else
%                     temp.data.profPV=repmat(handles.data_old.profPV(:,1),1,nvals);
%                     handles.data.profPV=[temp.data.profPV handles.data_old.profPV];
%                 end
            case 'wirePV'
                temp.data.wirePV=repmat(handles.data_old.wirePV(:,1,:),1,nvals);
                handles.data.wirePV=[temp.data.wirePV handles.data_old.wirePV];
            case 'wireBeam'
                temp.data.wireBeam=repmat(handles.data_old.wireBeam(1,1,:),nvals,1);
                handles.data.wireBeam=[temp.data.wireBeam; handles.data_old.wireBeam];
%             case 'blenBeam'
%                 temp.data.blenBeam=repmat(handles.data_old.blenBeam(1),nvals,1);
%                 handles.data.blenBeam=[temp.data.blenBeam;handles.data_old.blenBeam];
            case 'blenStd'
                temp.data.blenStd=repmat(handles.data_old.blenStd(1,1,:),nvals,1);
                handles.data.blenStd=[temp.data.blenStd; handles.data_old.blenStd];
            case 'blenPV'
%                 if handles.dataSample.nVal > 1
                    temp.data.blenPV=repmat(handles.data_old.blenPV(:,1,:),1,nvals);
                    handles.data.blenPV=[temp.data.blenPV handles.data_old.blenPV];
%                 else
%                     temp.data.readPV=repmat(handles.data_old.readPV(:,1),1,nvals);
%                     handles.data.readPV=[temp.data.readPV handles.data_old.readPV];
%                 end
            case 'dataList'
                    temp.data.dataList=repmat(handles.data_old.dataList(1,:),nvals,1);
                    handles.data.dataList=[temp.data.dataList; handles.data_old.dataList];
        end
    end
end
guidata(hObject,handles);


% -----------------------------------------------------------------------
function handles=sortData(hObject,handles)

for idx=1:length(handles.data.ctrlPV)
    ctrlPV_val(idx)=handles.data.ctrlPV(1,idx).val;
end
[out, sort_idx]=sort(ctrlPV_val);
    fields=fieldnames(handles.data)';
    for tag=fields
        if isfield (handles.data,tag)
            str=cell2struct(tag,'tag',1);
            switch str.tag
                case 'ctrlPV'
                    handles.data.ctrlPV=handles.data.ctrlPV(:,sort_idx);
                case 'readPV'
%                     if handles.dataSample.nVal > 1
                        handles.data.readPV=handles.data.readPV(:,sort_idx,:);
%                     else
%                         handles.data.readPV=handles.data.readPV(:,sort_idx);
%                     end
                case 'twissStd'
                    handles.data.twissStd=handles.data.twissStd(sort_idx,:,:);
                case 'twissPV'
%                     if handles.dataSample.nVal > 1
                        handles.data.twissPV=handles.data.twissPV(:,sort_idx,:);
%                     else
%                     handles.data.twissPV=handles.data.twissPV(:,sort_idx);
%                     end
                case 'beam'
                    handles.data.beam=handles.data.beam(sort_idx,:,:);
                case 'profPV'
%                     if handles.profmonId
                        handles.data.profPV=handles.data.profPV(:,sort_idx,:);
%                     else
%                         handles.data.profPV=handles.data.profPV(:,sort_idx);
%                     end
                case 'wireBeam'
                    handles.data.wireBeam=handles.data.wireBeam(sort_idx,:,:);
                case 'wirePV'
                    handles.data.wirePV=handles.data.wirePV(:,sort_idx,:);
                case 'dataList'
                    handles.data.dataList=handles.data.dataList(sort_idx,:);
            end
        end
    end
guidata(hObject,handles);


function ctrlMKBName_txt_Callback(hObject, eventdata, handles)

%ctrlMKBControl(hObject,handles,get(hObject,'String'));


function handles=ctrlMKBControl(hObject,handles,val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_textControl(hObject,handles,'ctrlMKBName',val);
if cancd, return, end
if strncmpi(handles.ctrlMKBName, 'MKB:', 4)
    set(handles.ctrlPVName_txt,'String','MKB:VAL');
    handles=ctrlPVControl(hObject,handles,'MKB:VAL',1);
end


% % % ------------------------------------------------------------------------
% % function handles = profmonMultiControl(hObject, handles, val)
% %
% % [handles,cancd,val]=gui_dataRemove(hObject,handles,val);
% % handles=gui_checkBoxControl(hObject,handles,'profmonMulti',val);
% % if cancd, return, end
% %
% % if handles.profmonMulti
% %     set(handles.profmon_pmu,'Style','listbox','Position',[167 35 20 25],'Max',2);
% %     set(handles.text27,'Position',[167 60.5 17 1.1538461538461537]);
% %     set(handles.output,'Position',get(handles.output,'Position').*[1 1 0 1]+[0 0 170.2+20 0]);
% % else
% %     handles.profmonId=handles.profmonId(1);
% %     set(handles.profmon_pmu,'Style','popupmenu','Position',[47.8 38.692307692307836 15 1.692307692307693],'Max',1);
% %     set(handles.text27,'Position',[47.8 40.6923076923078 17 1.1538461538461537]);
% %     set(handles.output,'Position',get(handles.output,'Position').*[1 1 0 1]+[0 0 170.2 0]);
% % end


% % % --- Executes on button press in profmonMulti_box.
% % function profmonMulti_box_Callback(hObject, eventdata, handles)
% %
% % profmonMultiControl(hObject,handles,get(hObject,'Value'));



% --- Executes on button press in setBest_btn.
function setBest_btn_Callback(hObject, eventdata, handles)

if handles.ctrlPVNum < 1 || ~isfield(handles,'fitPar') || numel(handles.fitPar) < 2, return, end

num=1;
str=questdlg(['Do you want to set ' handles.ctrlPV(num).name ' to best value at ' num2str(handles.fitPar(2)) '?'],'Set Best Value','Yes','No','No');
if ~strcmp(str,'Yes'), return, end
handles.ctrlPV(num).val=handles.fitPar(2);
ctrlPVReset(hObject,handles);


function [slowList, fastList]=acquireZigzagList(handles,slowList,fastList)

for num=1:2
    nmax=handles.ctrlPVValNum(num);

    if mod(nmax,2)
        scan_array=[nmax:-2:1 2:2:nmax-1];
    else
        scan_array=[nmax:-2:2 1:2:nmax-1];
    end

    [mn,imn] = min(abs(handles.ctrlPVValList{:,num}-handles.ctrlPV(num).val));
    [mn,imn] = min(abs(scan_array(:)-imn));
    scan_array=circshift(scan_array,[0 -imn+1]);
    if num==1
        slowList=scan_array;
    else
        fastList=scan_array;
    end
end


function par = decker_corr(a, b)

nd=size(a,2);
ns=size(a,3);
par=repmat(kron(eye(nd),[1 0])* ...
    lscov(kron(eye(nd),ones(ns,2)).* ...
    repmat([reshape(squeeze(a)',[],1) ones(nd*ns,1)],1,nd), ...
    reshape(squeeze(b)',[],1)),1,ns);


function pausePVName_txt_Callback(hObject, eventdata, handles)
handles.pausePV=handles.pausePVName_txt;


% --- Executes during object creation, after setting all properties.
function pausePVName_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pauseDataAcq(hObject, handles)

pausePV=get(handles.pausePVName_txt, 'string');
pauseValue = lcaGetSmart(pausePV);
    if pauseValue == 1
        warndlg('Data acqusition paused');
        beep;
        while pauseValue == 1
            pause(1)
            pauseValue = lcaGetSmart(pausePV);
        end
        warndlg('Data acqusition restarted');
        beep;
    end



    % --- Executes on button press in test_btn.
    function test_btn_Callback(hObject, eventdata, handles)
        [hu, handle1]=util_appFind('SXRSS_gui');
        axesChildHandles=get(handles.plotData_ax,'children');
        cla(handle1.step7plotData_ax);
        copyobj(axesChildHandles, handle1.step7plotData_ax);

function handles = updateExtGui(hObject, handles,val)
[hu, handle1]=util_appFind('SXRSS_gui');
set(handle1.step7ctrlPVVal_txt, 'String', sprintf('%6.0f',val))


