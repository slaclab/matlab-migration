function varargout = tcav_gui(varargin)
% TCAV_GUI M-file for tcav_gui.fig
%      TCAV_GUI, by itself, creates a new TCAV_GUI or raises the existing
%      singleton*.
%
%      H = TCAV_GUI returns the handle to a new TCAV_GUI or the handle to
%      the existing singleton*.
%
%      TCAV_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TCAV_GUI.M with the given input arguments.
%
%      TCAV_GUI('Property','Value',...) creates a new TCAV_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tcav_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tcav_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tcav_gui

% Last Modified by GUIDE v2.5 05-Sep-2020 22:59:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tcav_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @tcav_gui_OutputFcn, ...
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


% --- Executes just before tcav_gui is made visible.
function tcav_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tcav_gui (see VARARGIN)

% Choose default command line output for tcav_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tcav_gui wait for user response (see UIRESUME)
% uiwait(handles.tcav_gui);


% --- Outputs from this function are returned to the command line.
function varargout = tcav_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close tcav_gui.
function tcav_gui_CloseRequestFcn(hObject, eventdata, handles)

if strcmp(handles.accelerator,'LCLS'), lcaPut(handles.tcavGuiPV,0);end
util_appClose(hObject);


% ------------------------------------------------------------------------
function data = appRemote(hObject, devName, measureType)

if nargin < 3, measureType='blen';end
[hObject,handles]=util_appFind('tcav_gui');
[sector,devId]=measureDevFind(hObject,handles,devName);
handles=sectorControl(hObject,handles,sector);
handles=measureTypeInit(hObject,handles,measureType);
handles=measureDevListControl(hObject,handles,devId);

handles.process.saved=1;
handles=acquireStart(hObject,handles);
data=handles.data;
handles.process.saved=1;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function data = appQuery(hObject)

[hObject,handles]=util_appFind('tcav_gui');
data=handles.data;


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of index names.
handles.indexList={'LCLS' {'IN20' 'LI21' 'LI24' 'LI29' 'LTUH' 'DMPH'};...%suspending DMPH option for XTCAV control fix
%handles.indexList={'LCLS' {'IN20' 'LI21' 'LI24' 'LI29' 'LTUH'}; ...
    'FACET' {'IN10' 'LI20'}; ...
%    'LCLS2' {'IN10' 'LI11' 'LI14' 'BA21' 'LTU2'}; ...
    'XTA'   {'XT01'}; ...
    };

% TCav MAD names by sector
handles.sector.IN20.tcavMADList={ ...
    'TCAV0'};
handles.sector.LI21.tcavMADList={ ...
    'L1S'};
handles.sector.LI24.tcavMADList={ ...
    'L2'};
handles.sector.LI25.tcavMADList={ ...
    'TCAV3'};
handles.sector.LI29.tcavMADList={ ...
    'TCAV3'};
handles.sector.LTUH.tcavMADList={ ...
    'TCAV3'};
handles.sector.DMPH.tcavMADList={ ...
    'XTCAV'};
handles.sector.LI20.tcavMADList={ ...
    'XTCAVF'};
handles.sector.IN10.tcavMADList={ ...
    'TCY10490'};
handles.sector.XT01.tcavMADList={ ...
    'TCAVX'};

% TCav Klys names by sector
handles.sector.IN20.tcavKlysList={ ...
    'KLYS:LI20:51'};
handles.sector.LI21.tcavKlysList={ ...
    'L1'};
handles.sector.LI24.tcavKlysList={ ...
    'L2'};
handles.sector.LI25.tcavKlysList={ ...
    'KLYS:LI24:81'};
handles.sector.LI29.tcavKlysList={ ...
    'KLYS:LI24:81'};
handles.sector.LTUH.tcavKlysList={ ...
    'KLYS:LI24:81'};
handles.sector.DMPH.tcavKlysList={ ...
    'KLYS:DMPH:K1'};
handles.sector.LI20.tcavKlysList={ ...
    'KLYS:LI20:41'};
handles.sector.IN10.tcavKlysList={ ...
    'KLYS:LI10:51'};
handles.sector.XT01.tcavKlysList={ ...
    'KLYS:XT01:11'};

% Profile monitor MAD names by sector
handles.sector.IN20.profMADList={ ...
    'OTR2' 'OTR3' 'OTR4' 'YAGS2'};
handles.sector.LI21.profMADList={ ...
    'OTR11'};
handles.sector.LI24.profMADList={ ...
    'OTR21'};
handles.sector.LI25.profMADList={ ...
    'OTR_TCAV'};
handles.sector.LI29.profMADList={ ...
    'WS27644' 'WS28144' 'WS28444' 'WS28744' 'PR55'};
handles.sector.LTUH.profMADList={ ...
    'YAGPSI'};
handles.sector.DMPH.profMADList={ ...
    'OTRDMP'};
handles.sector.LI20.profMADList={ ...
    'USTHZ' 'USOTR' 'IPOTR1' 'DSOTR' 'WDSOTR'};
handles.sector.IN10.profMADList={ ...
    'PR10571' 'PR10711' 'PR10921' 'WS10561'};
handles.sector.XT01.profMADList={ ...
    'OTR250X' 'OTR350X' 'YAG550X'};

% Devices to use and data initialization for each wire scanner by sector
%for tag=handles.sector.nameList
for tag=fieldnames(handles.sector)'
    sector=handles.sector.(tag{:});
    if ~isstruct(sector), continue, end
    sector.tcavDevList=model_nameConvert(sector.tcavMADList,'EPICS');
    sector.profDevList=model_nameConvert(sector.profMADList,'EPICS');
    num=length(sector.profDevList);
    sector.profId=1;
    sector.measurePhaseRange=zeros(num,2);
    sector.tcavCal=ones(num,2);
    sector.tcavCalStd=zeros(num,2);
    handles.sector.(tag{:})=sector;
end

handles.measurePhaseRange={0 0};
handles.measurePhaseValNum=7;
handles.processNumBG=0;
handles.processAverage=0;
handles.processSampleNum=1;
handles.emittance=1;%um
handles.processSelectMethod=1;
%handles.sectorSel='IN20';
handles.measureType='blen';
handles.fdbkList={'FBCK:INL0:1:ENABLE';'FBCK:INL1:1:ENABLE';'FBCK:IN20:TR01:MODE'; ...
    'FBCK:FB04:LG01:MODE';'ACCL:LI22:1:FANCY_PH_CTRL'};
handles.acclList={'L1' 'L2'};
handles.tcavGuiPV='SIOC:SYS0:ML00:AO603';

handles.configList={'measurePhaseValNum' 'processNumBG' 'processAverage' ...
    'processSampleNum' 'processSelectMethod' 'sectorSel' 'emittance'};
handles.sector.configList={'profId' 'measurePhaseRange' 'tcavCal' 'tcavCalStd'};

%handles=gui_useBoxInit(hObject,handles,'dataDevice','');

% Initialize indices (a.k.a. facilities).
handles=gui_indexInit(hObject,handles,'Bunch Length Measurement');

if strcmp(handles.accelerator,'FACET')
     handles.fdbkList = {'SIOC:SYS1:ML00:AO659'; 'SIOC:SYS1:ML00:AO661'} ;
end
if strcmp(handles.accelerator,'LCLS'), lcaPut(handles.tcavGuiPV,1);pause(1);end

% Finish initialization.
guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=appSetup(hObject,handles);
handles=processInit(hObject,handles);
handles=gui_appLoad(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=gui_indexControl(hObject,handles,[]);
%handles=sectorControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);
handles=processAverageControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, name)

[handles,cancd,name]=gui_dataRemove(hObject,handles,name);
handles=gui_radioBtnControl(hObject,handles,'sectorSel',name, ...
    numel(handles.sector.nameList) > 0,'_btn');
if cancd, return, end
handles=measureTypeInit(hObject,handles,[]);
str={'Off' 'On'};
set(handles.tcav1Hz_btn,'Visible',str{ismember(handles.sectorSel,{'LI25' 'LI29' 'LTUH'})+1}); 


% ------------------------------------------------------------------------
function handles = measureTypeInit(hObject, handles, tag)

[handles,cancd,tag]=gui_dataRemove(hObject,handles,tag);
handles=gui_popupMenuControl(hObject,handles,'measureType',tag,{'blen' 'cal'});
if cancd, return, end
sector=handles.sector.(handles.sectorSel);
set(handles.measureDevList_pmu,'String',sector.profMADList);
handles=measureDevListControl(hObject,handles,[]);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [sector, devId] = measureDevFind(hObject, handles, devName)

sector='';devId=0;
for tag=handles.sector.nameList
    val=strcmpi(handles.sector.(tag{:}).profDevList,devName);
    if any(val)
        sector=tag{:};
        devId=find(val);
    end
end


% ------------------------------------------------------------------------
function handles = measureDevListControl(hObject, handles, val)

sector=handles.sector.(handles.sectorSel);
if strcmp(handles.sectorSel,'LI20')
    profId=4;
else
    profId=sector.profId;
end
handles.measureDevId=profId;

% Set devList control.
[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
if isempty(val)
    val=handles.measureDevId;
end
handles.measureDevId=val;
set(handles.measureDevList_pmu,'Value',val);
if cancd, return, end
handles.sector.(handles.sectorSel).profId=val;
sector=handles.sector.(handles.sectorSel);
handles.measureDevName=sector.profDevList{handles.measureDevId};
set(handles.measureTcavDev_pmu,'String',sector.tcavMADList);
if strcmp(handles.measureType,'blen')
    handles.dataDevice.nVal=3;
    handles.measureValList=[-1 0 1];
    set(handles.measurePhaseSet_btn,'String','Set Amp');
    set(handles.measurePhaseReset_btn,'String','Reset Amp');
else
    set(handles.measurePhaseSet_btn,'String','Set Phase');
    set(handles.measurePhaseReset_btn,'String','Reset Phase');
end
handles.measureProfOrig=0;
if ~strncmp(handles.measureDevName,'WIRE',4)
     handles.measureProfOrig=lcaGetSmart(strcat(handles.measureDevName,':PNEUMATIC'),0,'double');
end
handles=measurePhaseValNumControl(hObject,handles,[]);
handles=measureTcavControl(hObject,handles,[]);
set(handles.dataDeviceLabel_txt,'String',handles.measureTcavName);
handles=processSampleNumControl(hObject,handles,[]);
handles=processNumBGControl(hObject,handles,[]);
handles=emittanceGet(hObject,handles,[]);
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireReset(hObject, handles)

[handles,cancd]=gui_dataRemove(hObject,handles);
if cancd, return, end
handles=dataCurrentDeviceControl(hObject,handles,1,[]);
handles.process.saved=0;
handles.process.done=0;
handles.fileName='';
handles.data.status=zeros(handles.dataDevice.nVal,1);
handles.data.type=handles.measureType;
handles.data.name=handles.measureDevName;
handles.data.val=handles.measureValList;
if strcmp(handles.measureType,'blen')
    sector=handles.sector.(handles.sectorSel);
    handles.data.tcavCal=sector.tcavCal(sector.profId);
    handles.data.tcavCalStd=sector.tcavCalStd(sector.profId);
end
handles.data.use=ones(handles.dataDevice.nVal,1);
handles=processUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureTcavControl(hObject, handles, val)

sector=handles.sector.(handles.sectorSel);
if isempty(val)
    val=1;
end
set(handles.measureTcavDev_pmu,'Value',val);
handles=measurePhaseRangeControl(hObject,handles,1:2,[]);
if ~isfield(handles,'measureTcavName')
    handles.measureTcavName='';
end
if ~strcmp(handles.measureTcavName,sector.tcavDevList{1})
    if ~isempty(handles.measureTcavName) && ~ismember(handles.measureTcavKlys,handles.acclList)
        control_klysStatSet(handles.measureTcavKlys,0);
    end
% Don't turn on at program start
%    control_klysStatSet(sector.tcavKlysList{1},1);
end
handles.measureTcavName=sector.tcavDevList{1};
handles.measureTcavKlys=sector.tcavKlysList{1};
handles.measurePhaseOrigVal=control_phaseGet(sector.tcavMADList{1});
set([handles.measurePhaseResetVal_txt handles.measurePhaseVal_txt], ...
    'String',sprintf('%5.2f deg',handles.measurePhaseOrigVal));
set([handles.measurePhaseRangeLowUnits_txt handles.measurePhaseRangeHighUnits_txt],'String','deg');
if strcmp(handles.measureTcavName,'TCAV:LI24:800:TC3')
    handles.measurePhaseOrigVal=lcaGetSmart('SIOC:SYS0:ML00:AO386');
    set([handles.measurePhaseResetVal_txt handles.measurePhaseVal_txt], ...
        'String',sprintf('%5.2f mm',handles.measurePhaseOrigVal));
    set([handles.measurePhaseRangeLowUnits_txt handles.measurePhaseRangeHighUnits_txt],'String','mm');
elseif strcmp(handles.measureTcavName,'TCAV:DMPH:360')
    handles.measurePhaseOrigVal=lcaGetSmart('SIOC:SYS0:ML01:AO163');
    set([handles.measurePhaseResetVal_txt handles.measurePhaseVal_txt], ...
        'String',sprintf('%5.2f mm',handles.measurePhaseOrigVal));
    set([handles.measurePhaseRangeLowUnits_txt handles.measurePhaseRangeHighUnits_txt],'String','mm');
end
if ~ismember(handles.measureTcavKlys,handles.acclList)
    handles.measureAmpOrigVal=control_klysStatGet(sector.tcavMADList{1});
else
    handles.measureAmpOrigVal=control_phaseGet(handles.measureTcavKlys,'ADES');
end
measurePhaseDisp(hObject,handles,handles.measureAmpOrigVal,[]);
set(handles.dataDeviceLabel_txt,'String',handles.measureTcavName);
handles=tcavCalControl(hObject,handles,[]);
%set(handles.tcavCal_txt,'String',num2str(sector.tcavCal(sector.profId),'%5.2f um/deg'));
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = tcavCalControl(hObject, handles, val)

sector=handles.sector.(handles.sectorSel);
handles.tcavCal=sector.tcavCal(sector.profId);

handles=gui_editControl(hObject,handles,'tcavCal',val);
set(handles.tcavCal_txt,'String',num2str(handles.tcavCal,'%5.2f um/deg'));
handles.sector.(handles.sectorSel).tcavCal(sector.profId)=handles.tcavCal;


% ------------------------------------------------------------------------
function handles = measurePhaseValNumControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_editControl(hObject,handles,'measurePhaseValNum',val,1,1,[0 2]);
if cancd, return, end
if strcmp(handles.measureType,'cal')
    handles.measureValList=linspace(handles.measurePhaseRange{:}, ...
        handles.measurePhaseValNum);
    handles.dataDevice.nVal=handles.measurePhaseValNum;
end
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = measurePhaseRangeControl(hObject, handles, tag, val)

sector=handles.sector.(handles.sectorSel);
profId=sector.profId;
handles.measurePhaseRange=num2cell(sector.measurePhaseRange(profId,:));

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_rangeControl(hObject,handles,'measurePhaseRange',tag,val);
if cancd, return, end

handles.sector.(handles.sectorSel).measurePhaseRange(profId,:)=[handles.measurePhaseRange{:}];
if strcmp(handles.measureType,'cal')
    handles.measureValList=linspace(handles.measurePhaseRange{:}, ...
        handles.measurePhaseValNum);
    handles.dataDevice.nVal=handles.measurePhaseValNum;
end
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = measurePhaseDisp(hObject, handles, act, val)

if ismember(handles.measureTcavKlys,handles.acclList)
    act=[];set(handles.measureAmpVal_txt,'String',num2str(act));
end
stateStr={'ERR' 'on' 'off' '' 'bad'};act=bitand(act,7);
if ~isempty(act)
    set(handles.measureAmpVal_txt,'String',stateStr{act+1});
end
if ~isempty(val)
    set(handles.measurePhaseVal_txt,'String',sprintf('%5.2f deg',val));
end


% ------------------------------------------------------------------------
function handles = measurePhaseSet(hObject, handles)

if strcmp(handles.measureType,'blen')
    handles=measureAmpSet(hObject,handles);
    return
end
if ~ismember(handles.measureTcavKlys,handles.acclList)
    act=control_klysStatSet(handles.sector.(handles.sectorSel).tcavKlysList{1},1);
else
    act=[];
end
tcav1Hz_btn_Callback(hObject,[],handles);
pv=handles.sector.(handles.sectorSel).tcavDevList{1};
guidata(hObject,handles);
val=handles.measureValList(handles.dataDevice.iVal);
set(handles.measurePhaseSet_btn,'String','Setting...');
if strcmp(pv,'TCAV:LI24:800:TC3')
    lcaPutSmart('SIOC:SYS0:ML00:AO398',val);pause(5.);
    val=control_phaseGet(pv);
elseif strcmp(pv,'TCAV:DMPH:360')
    lcaPutSmart('SIOC:SYS0:ML01:AO163',val);pause(5.);
    val=control_phaseGet(pv);
else
    val=control_phaseSet(pv,val);
end
handles=guidata(hObject);
measurePhaseDisp(hObject,handles,act,val);
set(handles.measurePhaseSet_btn,'String','Set Phase');
handles.data.val(handles.dataDevice.iVal)=val;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measurePhaseReset(hObject, handles)

if strcmp(handles.measureType,'blen')
    handles=measureAmpReset(hObject,handles);
    return
end
pv=handles.sector.(handles.sectorSel).tcavDevList{1};
val=handles.measurePhaseOrigVal;
set(handles.measurePhaseReset_btn,'String','Setting');
if strcmp(pv,'TCAV:LI24:800:TC3')
    lcaPutSmart('SIOC:SYS0:ML00:AO398',val);pause(1.);
    val=control_phaseGet(pv);
elseif strcmp(pv,'TCAV:DMPH:360')
    lcaPutSmart('SIOC:SYS0:ML01:AO163',val);pause(1.);
    val=control_phaseGet(pv);
else
    val=control_phaseSet(pv,val);
end
val=control_phaseSet(pv,val);
measurePhaseDisp(hObject,handles,[],val);
set(handles.measurePhaseReset_btn,'String','Reset Phase');


% ------------------------------------------------------------------------
function handles = measureAmpSet(hObject, handles)

sector=handles.sector.(handles.sectorSel);
pv=sector.tcavDevList{1};
val=handles.measureValList(handles.dataDevice.iVal)
set(handles.measurePhaseSet_btn,'String','Setting...');
guidata(hObject,handles);
is1Hz=get(handles.tcav1Hz_btn,'Value');
if ~is1Hz, measureTcavSet(hObject,handles,val);end
if val
    if is1Hz && isfield(handles,'tcav3')
        lcaPut('SIOC:SYS0:ML00:AO038',handles.tcav3.gain);
        control_ampSet('TCAV3',handles.tcav3.aDes);
        control_phaseSet('TCAV3',handles.tcav3.pDes);
        handles=rmfield(handles,'tcav3');
        guidata(hObject,handles);
    end
    pDes=abs(mean([handles.measurePhaseRange{:}]));
    if ismember(handles.measureTcavKlys,handles.acclList)
        pDes=val*pDes;
    elseif val == -1
        pDes=util_phaseBranch(pDes+180,0);
    end
    if strcmp(pv,'TCAV:LI24:800:TC3')
        lcaPut('SIOC:SYS0:ML00:AO387',90*val);pause(4.);
        while ~lcaGet('SIOC:SYS0:ML00:AO385'), pause(.1);end
        pAct=control_phaseGet(pv);
    elseif strcmp(pv,'TCAV:DMPH:360')
        lcaPut('SIOC:SYS0:ML01:AO170',90*val);pause(4.);
        while ~lcaGet('SIOC:SYS0:ML01:AO171'), pause(.1);end
        pAct=control_phaseGet(pv);
    else
        pAct=control_phaseSet(pv,pDes);
    end
elseif is1Hz
    [d,handles.tcav3.pDes,d,handles.tcav3.aDes]=control_phaseGet(pv);
    handles.tcav3.gain=lcaGet('SIOC:SYS0:ML00:AO038');
    guidata(hObject,handles);
    lcaPut('SIOC:SYS0:ML00:AO038',0);
    control_ampSet('TCAV3',0.25);
    control_phaseSet('TCAV3',handles.tcav3.pDes+20);
    pAct=control_phaseGet(pv);
else
    pAct=control_phaseGet(pv);
end
handles=guidata(hObject);
measurePhaseDisp(hObject,handles,[],pAct);
set(handles.measurePhaseSet_btn,'String','Set Amp');
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = measureAmpReset(hObject, handles)

sector=handles.sector.(handles.sectorSel);
set(handles.measurePhaseReset_btn,'String','Setting');
guidata(hObject,handles);
measureTcavSet(hObject,handles,1);
pDes=mean([handles.measurePhaseRange{:}]);
if strcmp(sector.tcavDevList{1},'TCAV:LI24:800:TC3')
    lcaPut('SIOC:SYS0:ML00:AO387',90);
    pAct=control_phaseGet(sector.tcavDevList{1});
elseif strcmp(sector.tcavDevList{1},'TCAV:DMPH:360')
    lcaPut('SIOC:SYS0:ML01:AO170',90);
    pAct=control_phaseGet(sector.tcavDevList{1});
else
    pAct=control_phaseSet(sector.tcavDevList{1},pDes);
end
handles=guidata(hObject);
set(handles.measurePhaseReset_btn,'String','Reset Amp');
measurePhaseDisp(hObject,handles,[],pAct);


% ------------------------------------------------------------------------
function handles = measureTcavSet(hObject, handles, val, flag)

pv=handles.sector.(handles.sectorSel).tcavKlysList{1};
if ~ismember(pv,handles.acclList)
%     if strcmp(pv,'KLYS:LI20:41') && nargin == 4 && flag
    if strcmp(pv,'KLYS:LI20:41') && nargin == 4 && flag
        act = control_tcavPAD(double(logical(val)),'XTCAVF');  
    else
        act=control_klysStatSet(pv,double(logical(val)));
    end
elseif strcmp(pv,'L2')
    pDes=control_phaseGet(pv);
    [ho,h]=util_appFind('Phase_Scans');
    if ~val && pDes
    % val == 0, goto crest
        Phase_Scans('CRESTL2_Callback',ho,[],h);
    elseif val && ~pDes
    % val ~= 0, go off crest
        Phase_Scans('OFFCRESTL2_Callback',ho,[],h);
    end
    act=[];
else
    pDes=control_phaseGet('L1S');
    [ho,h]=util_appFind('Phase_Scans');
    if ~val && pDes
    % val == 0, goto crest
        dPhase=control_phaseGet('L1S','PDES');
        Phase_Scans('control_phaseEnergySetCallback',ho,[],h,'L1S',[],[],dPhase,0,1,Inf);
    elseif val && ~pDes
    % val ~= 0, go off crest
        dPhase=str2double(get(h.(['FINALPHASE_' 'L1S']),'String'));
        Phase_Scans('control_phaseEnergySetCallback',ho,[],h,'L1S',[],[],0,dPhase,1,Inf);
    end
    act=[];
end
tcav1Hz_btn_Callback(hObject,[],handles);
measurePhaseDisp(hObject,handles,act,[]);
act



% ------------------------------------------------------------------------
function handles = measureProfSet(hObject, handles, val)

if strncmp(handles.measureDevName,'WIRE',4), return, end
if strcmp(handles.accelerator, 'FACET'), return, end
if strcmp(handles.measureDevName,'YAGS:LTUH:743'), return, end
gui_statusDisp(handles,['Moving screen ' handles.measureDevName ' ...']);
profmon_activate(handles.measureDevName,val,1);
gui_statusDisp(handles,['Moving screen ' handles.measureDevName ' done']);


% ------------------------------------------------------------------------
function handles = dataCurrentDeviceControl(hObject, handles, iVal, nVal)

units='deg';str=sprintf('%6.0f',handles.measureValList(iVal));
if strcmp(handles.measureType,'blen')
    units='';if ~handles.measureValList(iVal), str='off';end
end
handles=gui_sliderControl(hObject,handles,'dataDevice',iVal,nVal,1,1,[str ' ' units]);


% ------------------------------------------------------------------------
function handles = measureCurrentGet(hObject, handles, state)

iVal=handles.dataDevice.iVal;
devName=handles.measureDevName;
handles.data.tcavName=handles.measureTcavName;
if strcmp(handles.measureType,'blen') && iVal==2 && strcmp(devName(1:8),'OTRS:DMP')
        disp('XTCAV non-deflection point')
   % Ding 20200629; not changing XTCAV during non-deflecting
elseif strcmp(state,'remote')   
        handles=measurePhaseSet(hObject,handles);   
        if ~strcmp(handles.measureTcavName,'TCAV:LI20:2400')
         measureProfSet(hObject,handles,1);
        end
end
guidata(hObject,handles);

switch devName(1:4)
    case 'WIRE'
        [ho,h]=util_appFind('wirescan_gui');
        val=get(handles.tcav1Hz_btn,'Value');
        if val
            wirescan_gui('scanWireModeControl',ho,h,'step');
            if strcmp(handles.measureType,'blen') && ~handles.measureValList(handles.dataDevice.iVal)
                stepNum=12;
            else stepNum=3;
            end
            wirescan_gui('scanWireStepNumControl',ho,guidata(ho),stepNum);
        else
%            wirescan_gui('scanWireModeControl',ho,h,'wire');
        end
        tcavEDefSet(hObject,handles);
        if strcmp(state,'remote')
            data=wirescan_gui('appRemote',0,devName,'y',0);
        else
            data=wirescan_gui('appRemote',0,devName,'y',0);
%            data=wirescan_gui('appQuery',0,devName,'y',0);
        end
        handles=guidata(hObject);
        handles.data.status(iVal)=data.status;
        if data.status
            handles.data.ts=data.ts;
            handles.data.beam(iVal,:)=data.beam;
            handles.data.beamList(iVal,:,:)=data.beam;
            if isfield(data.beam,'statsStd')
                data.beamStd=data.beam;
                [data.beamStd.stats]=deal(data.beamStd.statsStd);
                handles.data.beamStd(iVal,:)=data.beamStd;
            end
        end
    otherwise
            opts.axes=handles.plotProf_ax;
        if strcmp(handles.measureType,'blen') && iVal==2 && strcmp(devName(1:8),'OTRS:DMP')
            %emittance_txt=1;%um
            %emittance=str2double(get(handles.emittance_txt,'string'));
            opts.nBG =0;
            opts.emit =handles.emittance;
            dataList=profmon_getSimulData_xtcav(devName,handles.processSampleNum,opts);
            %save('dataListExamp.mat','dataList')
            
            % Ding 20200629: get simulated image based on model beam size
        else
            opts.bufd=1;
            opts.nBG=handles.processNumBG;
            dataList=profmon_measure(devName,handles.processSampleNum,opts);
            %save('XTCAVsimul_dataListExamp2.mat','dataList')
        end 
        handles=guidata(hObject);
        data.beamList=permute(cat(3,dataList.beam),[3 2 1]);
        [data.beam,data.beamStd]=beamAnalysis_beamAverage(data.beamList);
        data.status=1;
        data.ts=dataList(1).ts;
        handles.data.status(iVal)=data.status;
        handles.data.ts=data.ts;
        handles.data.dataList(iVal,:)=dataList;
        if data.status
            handles.data.beam(iVal,:,:)=data.beam;
            handles.data.beamStd(iVal,:,:)=data.beamStd;
            handles.data.beamList(iVal,:,:,1:size(data.beamList,3))=data.beamList;
        end
end
guidata(hObject,handles);
charge=zeros(1,5);
bpmPV='BPMS:IN20:221:TMIT';
if strcmp(handles.accelerator,'FACET')
    if strcmp(handles.sectorSel,'IN10')
        bpmPV='BPMS:IN10:221:TMIT';
    else
        bpmPV='BPMS:LI19:201:TMIT57';
    end
end
if ismember(handles.accelerator,{'LCLS' 'FACET'})
    for j=1:5
        charge(j)=lcaGet(bpmPV)*1.6021e-10; %nC
        pause(.1);
    end
end
handles=guidata(hObject);
if strcmp(handles.measureTcavName,'TCAV:LI24:800:TC3') && ~strcmp(handles.measureType,'blen')
    val=control_phaseGet(handles.measureTcavName);
    handles.data.val(iVal)=mean([handles.data.val(iVal) val]);
    if ~ispc && strncmp(devName,'WIRE',4)
%        num=lcaGet(num2str(h.eDefNumber,'TCAV:LI24:800:PHST%d.NUSE'));
%        val=lcaGet(num2str(h.eDefNumber,'TCAV:LI24:800:PHST%d'),num);
        for j=1:10,val(j)=lcaGet('TCAV:LI24:800:PBR');pause(.2);end
        handles.data.val(iVal)=mean(val);
    end
end
if strcmp(handles.measureTcavName,'TCAV:LI20:2400')
    handles.data.val(iVal)=handles.measureValList(handles.dataDevice.iVal);
end

handles.data.chargeList(iVal,:)=charge;
handles.data.charge=mean(handles.data.chargeList(:));
handles.data.chargeStd=std(handles.data.chargeList(:));
handles.process.done=0;

handles=processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end
handles=acquireReset(hObject,handles);

if strcmp(handles.measureType,'cal') || ismember(handles.measureTcavKlys,handles.acclList)
    if ismember(handles.accelerator,{'LCLS' 'FACET'})
        fbck=lcaGetSmart(handles.fdbkList,0,'double');
        if ~strcmp(handles.measureTcavKlys,'KLYS:DMPH:K1')
            lcaPutSmart(handles.fdbkList,0);
        end
    end
end

for j=1:handles.dataDevice.nVal
    handles=dataCurrentDeviceControl(hObject,handles,j,[]);
    handles=measureCurrentGet(hObject,handles,'remote');
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
measurePhaseReset(hObject,handles);
if strcmp(handles.measureType,'cal') || ismember(handles.measureTcavKlys,handles.acclList)
    if ismember(handles.accelerator,{'LCLS' 'FACET'})
        lcaPut(handles.fdbkList,fbck);
    end
end

measureProfSet(hObject,handles,handles.measureProfOrig);

uploadPVs(hObject,handles,1);
gui_acquireStatusSet(hObject,handles,0);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = processSampleNumControl(hObject, handles, val)

vis=~strncmp(handles.measureDevName,'WIRE',4);
[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_editControl(hObject,handles,'processSampleNum',val,1,vis,[0 1]);
if cancd, return, end
val=handles.processSampleNum;
if ~vis, val=1;end
handles=dataCurrentSampleControl(hObject,handles,1,val);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSampleControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSample',iVal,nVal);


% ------------------------------------------------------------------------
function handles = processNumBGControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'processNumBG',val,1,~strncmp(handles.measureDevName,'WIRE',4),[0 0]);

%-----
function handles = emittanceGet(hObject,handles,val)
handles=gui_editControl(hObject,handles,'emittance',val,1);

% ------------------------------------------------------------------------
function handles = dataMethodControl(hObject, handles, iVal, nVal)

if isempty(iVal)
    iVal=handles.processSelectMethod;
end
handles=gui_sliderControl(hObject,handles,'dataMethod',iVal,nVal);

handles.processSelectMethod=iVal;
guidata(hObject,handles);
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = processAverageControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'processAverage',val);
handles.process.done=0;
guidata(hObject,handles);
processUpdate(hObject,handles);


% ------------------------------------------------------------------------
function plotProfile(hObject, handles)

iVal=handles.dataDevice.iVal;
set(handles.dataDeviceUse_box,'Value',handles.data.use(iVal));

data=handles.data;
if ~data.status(handles.dataDevice.iVal)
    cla(handles.plotProf_ax);
    return
end

if handles.process.showImg && isfield(data,'dataList')
    imgData=data.dataList(iVal,handles.dataSample.iVal);
    profmon_imgPlot(imgData,'axes',handles.plotProf_ax,'bits',8);
    return
end

iMethod=handles.dataMethod.iVal;
beam=data.beam(iVal,iMethod);
if isfield(data,'beamList')
    beam=data.beamList(iVal,handles.dataSample.iVal,iMethod);
end
set(handles.dataMethod_txt,'String',beam.method);
devName=cellstr(handles.measureDevName);devName=devName{min(iVal,end)};
opts.axes=handles.plotProf_ax;opts.xlab=[devName ' Position  (\mum)'];
if strcmp(data.type,'cal'), str=sprintf(' at %5.1f deg',data.val(iVal));else
str=sprintf(' at %2.0f',data.val(iVal));end
opts.title=['Profile ' datestr(data.ts) ' ' data.beam(1,iMethod).method str];
plane='y';
if ismember(handles.measureTcavKlys,[handles.acclList 'KLYS:DMPH:K1'])
    plane='x';
end
beamAnalysis_profilePlot(beam,plane,opts);


% ------------------------------------------------------------------------
function handles = processInit(hObject, handles)

handles.process.done=0;
handles.process.saved=0;
handles.process.saveImg=0;
handles.process.showImg=0;
handles.process.displayExport=0;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = processUpdate(hObject, handles)

guidata(hObject,handles);
set(handles.output,'Name',['TCAV Application - [' handles.fileName ']']);
data=handles.data;
%if ~all(data.status), processPlot(hObject,handles);return, end
if sum(data.status) < 2, processPlot(hObject,handles);return, end
use=data.status & data.use;

val=data.val(use);
if strcmp(data.type,'blen')
    opts.xlab=[data.tcavName ':AACT  (norm)'];
    opts.title='bunch length';
    opts.unitsT='\mum';
else
    opts.xlab=[data.tcavName ':PACT  (deg)'];
    opts.title='calibration';
    opts.unitsT='degree';
end
if ~handles.processAverage && isfield(data,'beamList')
    val=reshape(repmat(val(:)',size(data.beamList,2),1),[],1);
end

sector=handles.sector.(handles.sectorSel);
opts.doPlot=0;opts.units='\mum';scl=1;opts.plane='y';
if ismember(handles.measureTcavKlys,[handles.acclList 'KLYS:DMPH:K1']), opts.plane='x';end
if 1
%    opts.unitsT='ps';
%    scl=1e12/2856e6/360;
%    scl=1e12/2856e6/360/299.792458; % Wrong, 308.23 um/degree
    scl=2856e6*360/1e12/299.792458; % Correct, 291.58 um/degree
    if ismember(handles.measureTcavName,{'TCAV:LI20:2400' 'TCAV:DMPH:360'})
        scl=4*scl; %for X-band
    end
end
if ~handles.process.done
    for iMethod=1:size(data.beam,2)
        beam=data.beam(use,iMethod);
        beamStd=[];
        if ~handles.processAverage && isfield(data,'beamList')
            beam=data.beamList(use,:,iMethod)';
            beam=beam(:);
        end
        if handles.processAverage && isfield(data,'beamStd')
            beamStd=data.beamStd(use,iMethod);
        end
        if strcmp(data.type,'blen')
            try
                [data.sigx(:,iMethod),data.blen(:,iMethod),sigxstd, ...
                    data.blenStd(:,iMethod),data.r15(:,iMethod),r15std]= ...
                    tcav_bunchLength(val,beam,data.tcavCal*scl,data.tcavCalStd*scl,opts,beamStd);
            catch
            end
        else
            [data.tcavCal(iMethod),data.tcavCalStd(iMethod)]= ...
                tcav_calibration(val,beam,opts,beamStd);
        end
    end
    
    if strcmp(data.type,'blen')
        pvRec=repmat(struct,1,1);
        tags={'BLEN'}';
        desc={'Bunch length'}';

        nameList=strcat(data.name,':',tags);
        descList=desc;
%        eguList={'degree'};
        eguList={'um'};
        blen=data.blen(:,:);
        blen=num2cell(reshape(blen,1,[]),2);
        [pvRec(1:1,1).name]=deal(nameList{:});
        [pvRec(1:1,1).val]=deal(blen{:});
        [pvRec(1:1,1).ts]=deal(data.ts);
        [pvRec(1:1,1).desc]=deal(descList{:});
        [pvRec(1:1,1).egu]=deal(eguList{:});
        data.blenPV=pvRec;
    end

    handles.process.done=all(data.status);
end
handles.data=data;
if strcmp(data.type,'cal')
    handles.sector.(handles.sectorSel).tcavCal(sector.profId)=data.tcavCal(handles.dataMethod.iVal);
    handles.sector.(handles.sectorSel).tcavCalStd(sector.profId)=data.tcavCalStd(handles.dataMethod.iVal);
%    sector=handles.sector.(handles.sectorSel);
%    set(handles.tcavCal_txt,'String',num2str(sector.tcavCal(sector.profId),'%5.2f um/deg'));
    handles=tcavCalControl(hObject,handles,[]);
end
guidata(hObject,handles);

iMethod=handles.dataMethod.iVal;
opts.figure=[];opts.axes=handles.plotBLen_ax;
opts.title=['TCAV ' sprintf('%s on %s ',opts.title,data.name) ' ' datestr(data.ts)];
opts.title=[opts.title ' ' data.beam(1,iMethod).method];
opts.doPlot=1;
if handles.process.displayExport
    handles.exportFig=figure;
    opts.axes=subplot(1,1,1);
    guidata(hObject,handles);
end

beam=data.beam(use,iMethod);
beamStd=[];
if ~handles.processAverage && isfield(data,'beamList')
    beam=data.beamList(use,:,iMethod)';
    beam=beam(:);
end
if handles.processAverage && isfield(data,'beamStd')
    beamStd=data.beamStd(use,iMethod);
end

if strcmp(data.type,'blen')
    tcav_bunchLength(val,beam,data.tcavCal*scl,data.tcavCalStd*scl,opts,beamStd);
%    emittance_process(val,beam,beamStd,1e-6,data.energy,{data.charge data.chargeStd},opts);
else
    tcav_calibration(val,beam,opts,beamStd);
end
processPlot(hObject,handles);


% ------------------------------------------------------------------------
function uploadPVs(hObject, handles, val)

data=handles.data;
if ~all(data.status), return, end

iMethod=handles.dataMethod.iVal;

if strcmp(handles.measureTcavKlys,'KLYS:DMPH:K1')
    model_init('source','MATLAB');
    dispList = model_rMatGet({'OTRDMP' 'BPMDL1' 'BPMDL3'},[],[],'twiss');
    dispList=dispList(11*[0 1 2]+[10 5 5])';
end

if ~strcmp(data.type,'blen')
    scl=2856e6*360/1e12/299.792458; % Correct, 291.58 um/degree
    if ismember(handles.measureTcavName,{'TCAV:LI20:2400' 'TCAV:DMPH:360'})
        scl=4*scl; %for X-band
    end
    if strcmp(handles.accelerator,'FACET')
        if strcmp(handles.sectorSel,'IN10')
            lcaPut('SIOC:SYS1:ML00:AO019',data.tcavCal(iMethod)*scl); % R_15 [um/um]
        else
            lcaPut('SIOC:SYS1:ML00:AO025',data.tcavCal(iMethod)*scl); % R_15 [um/um]
        end
    end
    xyStr={'X' 'Y'};
    plane=1+~ismember(handles.measureTcavKlys,{'KLYS:DMPH:K1'});
    pvList=strcat(handles.measureDevName,':',{'';'D'},'TCAL_',xyStr(plane));
    val=[data.tcavCal(iMethod);data.tcavCalStd(iMethod)]*scl;
    lcaPutSmart(pvList,val);
    if strcmp(handles.measureTcavKlys,'KLYS:DMPH:K1')
%        lcaPutSmart('SIOC:SYS0:ML01:AO214',lcaGet('TCAV:DMPH:360:ADES'));
        % ADDED LINES - TJM 2014/31/01
        xtcDES = lcaGetSmart({'TCAV:DMPH:360:ADES' 'TCAV:DMPH:360:PDES'});
        pvList=strcat('SIOC:SYS0:ML01:AO',{'214' '215' '216' '217' '218'});
        lcaPutSmart(pvList,[xtcDES;dispList]);
        % END ADDED LINES - TJM 2014/31/01
    end
else
    for iPlane=val
        pvList=strcat(handles.measureDevName,':',{'BLEN' 'DBLEN'}');
        val=[data.blen(:,iMethod);data.blenStd(:,iMethod)]; % Already in um
        lcaPut(pvList,val);
%        lcaPut([handles.devRef,':FIT_METHOD'],data.beam(1,iMethod).method);
    end
    if strcmp(handles.measureTcavKlys,'KLYS:DMPH:K1') && isfield(data,'sigx')
%        pvList=strcat('SIOC:SYS0:ML01:AO',{'212' '213'});
%        val=[data.sigx(:,iMethod);data.r15(:,iMethod)];
        % ADDED LINES - TJM 2014/31/01
        pvList=strcat('SIOC:SYS0:ML01:AO',{'212' '213' '216' '217' '218'});
        val=[data.sigx(:,iMethod);data.r15(:,iMethod);dispList];
        % END ADDED LINES - TJM 2014/31/01
        lcaPutSmart(pvList,val);
    end
end


% ------------------------------------------------------------------------
function processPlot(hObject, handles)

plotProfile(hObject,handles);
if sum(handles.data.status) < 2
    cla(handles.plotBLen_ax);
end


% --- Executes on slider movement.
function dataDevice_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentDeviceControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);


% --- Executes on slider movement.
function dataSample_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentSampleControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

handles.process.displayExport=1;
handles=processUpdate(hObject,handles);
handles.process.displayExport=0;
guidata(hObject,handles);
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
if val
    tStr='Bunch Length ';
    if strcmp(handles.data.type,'cal'), tStr=[tStr 'Calibration '];end
    util_printLog(handles.exportFig,'title',[tStr handles.data.name]);
    dataSave(hObject,handles,0);
end


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

data=handles.data;
if ~all(data.status), return, end
if ~handles.process.saveImg && isfield(data,'dataList')
    data=rmfield(data,'dataList');
end
if isfield(data,'dataList')
    if handles.process.saveImg
        butList={'Proceed' 'Discard Images'};
        button=questdlg('Save data with images?','Save Images',butList{:},butList{2});
        if strcmp(button,butList{2}), data=rmfield(data,'dataList');end
    else
        data=rmfield(data,'dataList');
    end
end
fileName=util_dataSave(data,['TCav-' data.type],data.name,data.ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
set(handles.output,'Name',['TCAV Application - [' handles.fileName ']']);
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles, val)

[data,fileName,pathName]=util_dataLoad('Open bunch length measurement');
if ~ischar(fileName), return, end
handles.fileName=fileName;

% Check fields.
if ~isfield(data,'use'), data.use=data.status*0+1;end

% Put data in storage.
handles.data=data;

% Initialize controls.
handles.measureType=data.type;
handles.measureDevName=data.name;
handles.measureTcavName=data.tcavName;
set(handles.dataDeviceLabel_txt,'String',handles.measureTcavName);
if strcmp(handles.measureType,'blen')
    handles.measureValList=data.val;
else
%    set(handles.dataDeviceLabel_txt,'String','multi');
    handles.measureValList=data.val;
end
handles=dataCurrentDeviceControl(hObject,handles,1,size(data.beam,1));
handles=dataCurrentSampleControl(hObject,handles,1,size(data.beamList,2));
handles.process.saved=1;

handles=processUpdate(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in dataSaveImg_box.
function dataSaveImg_box_Callback(hObject, eventdata, handles)

handles.process.saveImg=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in showImg_box.
function showImg_box_Callback(hObject, eventdata, handles)

handles.process.showImg=get(hObject,'Value');
guidata(hObject,handles);
plotProfile(hObject,handles);


% --- Executes on button press in dataDeviceUse_box.
function dataDeviceUse_box_Callback(hObject, eventdata, handles)

handles.data.use(handles.dataDevice.iVal)=get(hObject,'Value');
handles.process.done=0;
processUpdate(hObject,handles);


function processNumBG_txt_Callback(hObject, eventdata, handles)

processNumBGControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in uploadPVs_btn.
function uploadPVs_btn_Callback(hObject, eventdata, handles)

uploadPVs(hObject,handles,1);


% --- Executes on button press in measureCurrentGet_btn.
function measureCurrentGet_btn_Callback(hObject, eventdata, handles)

measureCurrentGet(hObject,handles,'query');


% --- Executes on slider movement.
function dataMethod_sl_Callback(hObject, eventdata, handles)

dataMethodControl(hObject,handles,round(get(hObject,'Value')),[]);


function measurePhaseValNum_txt_Callback(hObject, eventdata, handles)

measurePhaseValNumControl(hObject,handles,str2double(get(hObject,'String')));


function measurePhaseRange_txt_Callback(hObject, eventdata, handles, tag)

measurePhaseRangeControl(hObject,handles,tag,str2double(get(hObject,'String')));


% --- Executes on button press in measurePhaseSet_btn.
function measurePhaseSet_btn_Callback(hObject, eventdata, handles)

measurePhaseSet(hObject,handles);


% --- Executes on button press in measurePhaseReset_btn.
function measurePhaseReset_btn_Callback(hObject, eventdata, handles)

measurePhaseReset(hObject,handles);


function processSampleNum_txt_Callback(hObject, eventdata, handles)

processSampleNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


% --- Executes on button press in processAverage_box.
function processAverage_box_Callback(hObject, eventdata, handles)

processAverageControl(hObject,handles,get(hObject,'Value'));


% --- Executes on selection change in measureDevList.
function measureDevList_Callback(hObject, eventdata, handles)

measureDevListControl(hObject,handles,get(hObject,'Value'));


% --- Executes on selection change in measureQuad_btn.
function measureTcav_btn_Callback(hObject, eventdata, handles)

measureTcavControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in sectorSelIN20_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag)

sectorControl(hObject,handles,tag);


% --- Executes on selection change in measureType_pmu.
function measureType_pmu_Callback(hObject, eventdata, handles)

measureTypeInit(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);

% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

gui_appLoad(hObject,handles);


% --- Executes on button press in tcavOn_btn.
function tcavOnOff_btn_Callback(hObject, eventdata, handles, val)

measureTcavSet(hObject,handles,val,1);


% --- Executes on button press in prof2log_btn.
function prof2log_btn_Callback(hObject, eventdata, handles)

allProf=0;
handles.process.showImg=0;
n=handles.dataDevice.nVal;
m{2}=ceil(sqrt(n));m{1}=ceil(n/m{2});
if ~allProf, m={1 1};
else h=figure;end
for j=1:n
    handles.dataDevice.iVal=j;
    if ~allProf, h=figure;end
    handles.plotProf_ax=subplot(m{:},min(prod([m{:}]),j),'Parent',h);
    plotProfile(hObject,handles);drawnow;
    if ~allProf || j == n
        util_appFonts(h,'fontName','Times','lineWidth',1,'fontSize',14);
        tStr='Bunch Length ';
        if strcmp(handles.data.type,'cal'), tStr=[tStr 'Calibration '];end
        util_printLog(h,'title',[tStr 'Profile ' handles.data.name]);
    end
end


% --- Executes on button press in tcav1Hz_btn.
function tcav1Hz_btn_Callback(hObject, eventdata, handles)

if ~strcmp(handles.sector.(handles.sectorSel).tcavMADList{1},'TCAV3'), return, end
val=get(handles.tcav1Hz_btn,'Value');
tcavEDefSet(hObject,handles);
if val
    set(handles.tcav1Hz_btn,'String','1 Hz','BackgroundColor','r');
    if ~ispc
%        SetBgrpVariable('LCLS','T_CAV3','N');
%        SetBgrpVariable('LCLS','TC3_STEAL','Y');
    end
else
    set(handles.tcav1Hz_btn,'String','10 Hz','BackgroundColor','default');
    if ~ispc
%        SetBgrpVariable('LCLS','TC3_STEAL','N');
%        SetBgrpVariable('LCLS','T_CAV3','Y');
    end
end


function eDefTcavFB = tcavFBfind()

if ispc, eDefTcavFB=1;return, end

name=lcaGet(strcat('EDEF:SYS0:',cellstr(num2str((1:15)','%d')),':NAME'));
eDefTcavFB=find(strcmp(name,'tcav_feedback'));


function tcavEDefSet(hObject, handles)

if ispc, return, end

eDefTcavFB=tcavFBfind;
%val=get(handles.tcav1Hz_btn,'Value');
val=1;
if strcmp(handles.measureType,'blen')
    val=double(logical(handles.measureValList(handles.dataDevice.iVal)));
end

% Check if wirescan is running in same process
[ho,h]=util_appFind;
id=find(strcmp(get(ho,'tag'),'wirescan_gui'));
eDefNum=[];
if any(id), eDefNum=h{id}.eDefNumber;end

%{
% Exclude TCAV3 from all edefs but tcav_feedback & wirescan
eDefOther=setdiff(1:15,[eDefTcavFB eDefNum]);
pv=strcat('EDEF:SYS0:',cellstr(num2str(eDefOther','%d')),':EXCM92');
excl=lcaGet(pv,0,'double');
if any(excl ~= val), lcaPut(pv(excl ~= val),val);end
%}

% Include TCAV for wirescan
if any(id)
    pv=strcat('EDEF:SYS0:',cellstr(num2str(eDefNum','%d')),':INCM92');
    incl=lcaGet(pv,0,'double');
    if any(incl ~= val), lcaPut(pv(incl ~= val),val);end
    pv=strcat('EDEF:SYS0:',cellstr(num2str(eDefNum','%d')),':EXCM92');
    excl=lcaGet(pv,0,'double');
    if any(excl ~= 0), lcaPut(pv(excl ~= 0),0);end
end


% --- Executes on button press in dataDeviceUse_box.
function tcavCal_txt_Callback(hObject, eventdata, handles)

handles=tcavCalControl(hObject,handles,str2double(strtok(get(hObject,'String'))));
handles.process.done=0;
processUpdate(hObject,handles);



function emittance_txt_Callback(hObject, eventdata, handles)
% hObject    handle to emittance_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emittance_txt as text
%        str2double(get(hObject,'String')) returns contents of emittance_txt as a double
emittanceGet(hObject,handles,str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function emittance_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emittance_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
