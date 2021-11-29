function varargout = bba_gui(varargin)
% BBA_GUI M-file for bba_gui.fig
%      BBA_GUI, by itself, creates a new BBA_GUI or raises the existing
%      singleton*.
%
%      H = BBA_GUI returns the handle to a new BBA_GUI or the handle to
%      the existing singleton*.
%
%      BBA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BBA_GUI.M with the given input arguments.
%
%      BBA_GUI('Property','Value',...) creates a new BBA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bba_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bba_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bba_gui

% Last Modified by GUIDE v2.5 02-Oct-2015 15:53:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bba_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bba_gui_OutputFcn, ...
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


% --- Executes just before bba_gui is made visible.
function bba_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bba_gui (see VARARGIN)

% Choose default command line output for bba_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bba_gui wait for user response (see UIRESUME)
% uiwait(handles.bba_gui);


% --- Outputs from this function are returned to the command line.
function varargout = bba_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close bba_gui.
function bba_gui_CloseRequestFcn(hObject, eventdata, handles)

gui_BSAControl(hObject,handles,0);
util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appLoad(hObject, handles)

[d,name]=fileparts(get(handles.output,'FileName'));
config=util_configLoad(name);
for tag=handles.configList
    if isfield(config,tag{:})
        if isstruct(config.(tag{:}))
            for t=fieldnames(config.(tag{:}))'
                handles.(tag{:}).(t{:})=config.(tag{:}).(t{:});
            end
        else
            handles.(tag{:})=config.(tag{:});
        end
    end
end
guidata(hObject,handles);
handles=appSetup(hObject,handles);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of index names
handles.indexList={ ...
    'LCLS'  {'UND' 'L2' 'LI25 LI26' 'LI27 LI28' 'LI29 LI30' 'BC2_L3END' 'BSY' 'LI30 BSY' ...
             'BSY_End LTU0 LTU1' 'BSY LTU0 LTU1' 'LI24_End BC2_L3END BSY LTU0 LTU1' ...
             'UND_Launch' 'L2 L3 50B1_BSY LTU0 LTU1 UND1' 'UND_Launch2' 'UNDOld'}; ...
    'FACET' {'LI02' 'FACET' 'LI02_LI10' 'LI11_LI20' 'LI02 LI03' 'LI03 LI04' ...
             'LI04 LI05 LI06' 'LI05 LI06 LI07' 'LI06 LI07 LI08' 'LI07 LI08 LI09' ...
             'LI08 LI09 LI10' 'LI09 LI10 LI11' 'LI10 LI11 LI12' 'LI11 LI12 LI13' ...
             'LI12 LI13 LI14' 'LI13 LI14 LI15' 'LI14 LI15 LI16' 'LI15 LI16 LI17' ...
             'LI16 LI17 LI18' 'LI17 LI18 LI19' 'LI18 LI19 LI20' 'LI19 LI20' 'LI20'}; ...
    };

% Initialize GUI control values.
handles.simul=struct( ...
    'useGirdBack',1, ...
    'useBeamJitt',1, ...
    'useBPMNoise',1, ...
    'useBPMOff',1, ...
    'useQuadOff',1, ...
    'useUndOff',1, ...
    'useGirdOff',1, ...
    'useGirdSlope',1, ...
    'useLaunch',1, ...
    'useSteer',0, ...
    'useUndFI',1, ...
    'useUnd',1, ...
    'useDriftB',0, ...
    'useStray',0, ...
    'girdBack',4, ... % um
    'beamJitt',[10 1], ... % [um urad]
    'bpmNoise',1, ... % um
    'bpmOff',50, ... % um
    'quadOff',100, ... % um
    'undOff',100, ... % um
    'girdOff',[100 -200], ...% um
    'girdSlope',[1000 500], ... % um/100m
    'launch',[30 -2 -20 -3], ... % [um urad um urad]
    'undFI',[10 10], ... % [uTm uTm^2]
    'driftB',[18 -38], ... % uT
    'nEnergy',3, ...
    'enRange',[4.3 13.64], ...
    'init',0, ...
    'girderNum',1, ...
    'corrGain',0.5, ...
    'fitScale',1, ...
    'fitBPMLin',1, ...
    'fitBPMMin',0, ...
    'fitQuadLin',0, ...
    'fitQuadMin',0, ...
    'fitQuadKick',0, ...
    'fitCorrAbs',0, ...
    'fitSVDRatio',0.1, ...
    'getFI',0, ...
    'getDrift',0, ...
    'noEPlusCorr',1 ...
    );

handles.sectorSel='UND';
handles.appMode=1;
handles.appTask=0;
handles.acquireSampleNum=10;
handles.acquireDataNum=3;
handles.dataAverage=1;
handles.dataShowAll=0;
handles.dataShowError=0;
handles.acquireDataRange={4.3 13.64};
handles.process.saved=0;
handles.fitCorr=0;
handles.fitGirderMove=0;
handles.fitUndI2=0;
handles.fitUnd=0;
handles.fitUndCorr=0;
handles.keepRMat=0;
handles.fitDiff=0;
handles.klysName='25-1';
handles.doLEM=1;
handles.devType='meas';
set([handles.devSel_pan handles.fitOpts_pan handles.expert_btn ...
    handles.allPurpose_box],'Visible','off');

% Select fields to be saved in config file.
handles.configList={'sectorSel' 'appMode' 'acquireSampleNum' 'acquireDataNum' ...
    'dataAverage' 'dataShowAll' 'dataShowError' 'acquireDataRange' 'simul'};
%handles.sector.configList={};

% Initialize indices (a.k.a. facilities).
handles=gui_indexInit(hObject,handles,'BBA Tools');

%util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=appSetup(hObject,handles);
%handles=processInit(hObject,handles);
handles=appLoad(hObject,handles);
gui_statusDisp(handles,'GUI ready for Undulator BBA.');
set(handles.output,'Name','Beam Based Undulator Alignment');


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

txtList={'girdOff' 'girdSlope' 'quadOff' 'undOff' 'bpmOff' 'bpmNoise' ...
    'beamJitt' 'enRange' 'nEnergy' 'girdBack' 'fitScale' ...
    'fitSVDRatio' 'corrGain' 'girderNum' 'launch' 'undFI' 'driftB'};
for tag=txtList
    txtControl(hObject,handles,tag{:},[]);
end
boxList=[strcat('use',{'GirdOff' 'GirdSlope' 'QuadOff' 'UndOff' 'BPMOff' ...
    'BPMNoise' 'BeamJitt' 'GirdBack' 'Und' 'Stray' 'Launch' 'UndFI' 'DriftB' 'Steer'}) ...
    strcat('fit',{'BPMLin' 'BPMMin' 'QuadMin' 'QuadLin' 'CorrAbs'}) ...
    {'getFI' 'getDrift' 'noEPlusCorr'}];
for tag=boxList
    boxControl(hObject,handles,tag{:},[]);
end

handles=gui_indexControl(hObject,handles,[]);
%handles=sectorControl(hObject,handles,[]);
handles=appModeControl(hObject,handles,[]);
handles=gui_BSAControl(hObject,handles,1);
handles=acquireSampleNumControl(hObject,handles,[]);
handles=dataAverageControl(hObject,handles,[]);
handles=dataShowAllControl(hObject,handles,[]);
handles=dataShowErrorControl(hObject,handles,[]);
handles=fitCorrControl(hObject,handles,[]);
handles=fitGirderMoveControl(hObject,handles,[]);
handles=fitUndI2Control(hObject,handles,[]);
handles=fitUndControl(hObject,handles,[]);
handles=fitUndCorrControl(hObject,handles,[]);
handles=fitDiffControl(hObject,handles,[]);
handles=doLEMControl(hObject,handles,[]);
handles=keepRMatControl(hObject,handles,[]);
handles=acquireReset(hObject,handles);
%set(handles.setUndFieldInt_btn,'Visible','on');
handles=klysNameControl(hObject,handles,[]);
%set(handles.setKlysKick_btn,'Visible','on');
%set([handles.klysName_txt handles.klysNameLabel_txt handles.doLEM_box],'Visible','off');


% ------------------------------------------------------------------------
function handles = boxControl(hObject, handles, tag, val)

if isempty(val)
    val=handles.simul.(tag);
end
handles.simul.(tag)=val;
set(handles.([tag '_box']),'Value',val);
guidata(hObject, handles);


% ------------------------------------------------------------------------
function handles = box2Control(hObject, handles, tag, val)

tag2=tag;tag2{1}='use';
if isempty(val)
    val=subsref(handles.simul,struct('type','.','subs',tag2));
end
handles.simul=subsasgn(handles.simul,struct('type','.','subs',tag2),val);
set(handles.([tag{1} '_' tag{2} '_box']),'Value',val);
guidata(hObject, handles);


% ------------------------------------------------------------------------
function handles = txtControl(hObject, handles, tag, val)

if isempty(val) || any(isnan(val))
    val=handles.simul.(tag);
end
handles.simul.(tag)=val;
set(handles.([tag '_txt']),'String',num2str(val,'%g '));
guidata(hObject, handles);


% ------------------------------------------------------------------------
function handles = dataFitStatusControl(hObject, handles, tag, val)

if iscell(tag)
    handles=box2Control(hObject,handles,tag,val);
else
    handles=boxControl(hObject,handles,tag,val);
end
acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataFitTxtControl(hObject, handles, tag, val)

handles=txtControl(hObject,handles,tag,val);
acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function [handles, cancd] = acquireReset(hObject, handles)

[handles,cancd]=gui_dataRemove(hObject,handles);
if cancd, return, end
handles=dataCurrentDeviceControl(hObject,handles,1,[]);
handles.data.status=zeros(handles.dataDevice.nVal,1);
handles.data.use=ones(handles.dataDevice.nVal,1);
handles.process.saved=0;
handles.fileName='';
handles.data.name='';
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = appModeControl(hObject, handles, val)

if isempty(val)
    val=handles.appMode;
end
handles.appMode=val;
appModeLabel={'Simulation' 'Production'};
appModeColor={'g' 'r'};
set(handles.appMode_btn,'Value',val,'String',appModeLabel{val+1},'BackgroundColor',appModeColor{val+1});
model_init('simul',~val);
guidata(hObject,handles);
state={'Off' 'On'};
set(handles.acquireStart_btn,'Enable', ...
    state{(handles.appTask > 0 | handles.acquireDataNum == 1 | epicsSimul_status)+1});
set([handles.simul_pan handles.acquireEnergySet_btn handles.acquireEnergyReset_btn],'Visible',state{(~val | epicsSimul_status)+1});
%set([handles.setKlysKick_btn handles.klysName_txt handles.klysNameLabel_txt ...
%    handles.doLEM_box],'Visible',state{(~val | epicsSimul_status)+1});
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
nameList=handles.indexList{strcmp(handles.index,handles.indexList(:,1)),2};
labelList={'UND' 'L2' '25-26' '27-28' '29-30' 'L3' 'BSY' '30-BSY' ...
           'LTU' 'BSY-LTU' 'L3-LTU' 'UND_Launch' 'L2-L3-LTU' 'UND_Launch2' 'UNDOld'};
if ~strcmp(handles.accelerator,'LCLS'), labelList=nameList;end
if ischar(val)
    handles=gui_textControl(hObject,handles,'sectorSel',val);
    nameList=get(handles.sectorSel_pmu,'String');
    val=find(strcmp(nameList,handles.sectorSel),1);
    if isempty(val)
        nameList{end+1}=handles.sectorSel;
        val=numel(nameList);
        labelList(end+1:numel(nameList))=nameList(numel(labelList)+1:end);
    end
end
if val > numel(nameList), nameList=get(handles.sectorSel_pmu,'String');labelList(end+1:numel(nameList))=nameList(numel(labelList)+1:end);end
handles=gui_popupMenuControl(hObject,handles,'sectorSel',val,nameList,labelList);
if cancd, return, end
set(handles.sectorSel_txt,'String',handles.sectorSel);
handles.simul.sector=regexp(handles.sectorSel,' ','split');
handles.static=bba_simulInit(handles.simul);
handles=acquireDataRangeControl(hObject,handles,1:2,[]);
handles=acquireReset(hObject,handles);
str={'off' 'on'};
set(handles.zeroCorrs_btn,'Enable',str{strcmp(handles.sectorSel,'UND')+1});


% ------------------------------------------------------------------------
function handles = acquireDataNumControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_editControl(hObject,handles,'acquireDataNum',val,1,1,[0 1]);
if cancd, return, end
handles.acquireDataList=1./linspace(1./handles.acquireDataRange{1}, ...
    1./handles.acquireDataRange{2},handles.acquireDataNum);
units='GeV';
if handles.appTask == 3
    handles.acquireDataList=linspace(handles.acquireDataRange{:}, ...
        handles.acquireDataNum);
    units='mm';
end
if handles.appTask == 4
    handles.acquireDataList=[NaN linspace(handles.acquireDataRange{:}, ...
        handles.acquireDataNum-1)];
    units='Deg';
end
handles=dataCurrentDeviceControl(hObject,handles,1,handles.acquireDataNum);
guidata(hObject,handles);
state={'Off' 'On'};
set(handles.acquireStart_btn,'Enable', ...
    state{(handles.appTask > 0 | handles.acquireDataNum == 1 | epicsSimul_status)+1});
lab={'Engy Vals' 'Set Points'};
set(handles.acquireDataNumLabel_txt,'String',lab{(handles.appTask > 0)+1});
state={'off' 'on'};
set(handles.acquireDataRangeUnits_txt,'String',units, ...
    'Visible',state{(handles.appTask == 4 | handles.appTask == 0 & epicsSimul_status)+1});
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireDataRangeControl(hObject, handles, tag, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
vis=handles.appTask == 4 | handles.appTask == 0 & epicsSimul_status;
handles=gui_rangeControl(hObject,handles,'acquireDataRange',tag,val,1,vis);
if cancd, return, end
handles=acquireDataNumControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = dataCurrentDeviceControl(hObject, handles, iVal, nVal)

units='GeV';fmt='%6.2f %s';if handles.appTask == 3, units='mm';
elseif handles.appTask == 4, units='Deg';fmt='%6.0f %s';end
str=cellstr(sprintf(fmt,handles.acquireDataList(iVal),units));
if handles.appTask == 2 || (handles.appTask == 0 && ~epicsSimul_status), str={};end
if handles.appTask == 4 && iVal == 1, str={'Off'};end
handles=gui_sliderControl(hObject,handles,'dataDevice',iVal,nVal,1,1,str{:});
lab={'Energy' 'Und Position' 'Klys Phase'};
set(handles.dataDeviceLabel_txt,'String',lab{fix(handles.appTask/2)+1});
state={'Off' 'On'};
set(handles.dataDeviceUse_box,'Visible',state{(handles.acquireDataNum > 1)+1});


% ------------------------------------------------------------------------
function handles = acquireEnergySet(hObject, handles)

if handles.acquireDataNum == 1, return, end
if handles.acquireDataNum == 2 && handles.appTask == 2
    val=2-handles.dataDevice.iVal;
    str={'Out' 'In'};
    gui_statusDisp(handles,['Setting Undulator to ' str{val+1} ' ...']);
    undInOutControl(hObject,handles,val);
    if val, undZeroControl(hObject,handles);end
    gui_statusDisp(handles,['Setting Undulator to ' str{val+1} ' done']);
    return
end
if handles.appTask == 3
    val=handles.acquireDataList(handles.dataDevice.iVal);
    gui_statusDisp(handles,['Setting Undulator to ' num2str(val) ' mm ...']);
    undPV=model_nameConvert(cellstr(num2str(handles.simul.girderNum(:)','US%02d')));
    lcaPutNoWait(strcat(undPV,':TMXPOSC'),val);if ~epicsSimul_status, pause(1.);end
    while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), pause(1.);end
    if ~epicsSimul_status, pause(3.);end
    gui_statusDisp(handles,['Setting Undulator to ' num2str(val) ' mm done']);
    return
end
if handles.appTask == 4
    val=handles.acquireDataList(handles.dataDevice.iVal);
    gui_statusDisp(handles,['Setting Klystron Phase to ' num2str(val) ' Deg ...']);
    name=handles.klysName;
    stat=handles.klysStatus;
    act=~isnan(val);
    ph=stat([2 7]);
    if act, ph=ph+val-stat(4);end
    lcaPut('IOC:BSY0:MP01:PCELLCTL',0);pause(.3);
    control_klysStatSet(name,act);
    control_phaseSet(name,ph,0,[],{'PDES' 'KPHR'});
    wait=1;
    if stat(1) && ~act, wait=10.;end
    if handles.dataDevice.iVal == 2, wait=10.;end
    if handles.doLEM, wait=1;end
    if ~epicsSimul_status
        pause(wait);
    end
    gui_statusDisp(handles,['Setting Klystron Phase to ' num2str(val) ' Deg done']);

    if ~handles.doLEM, lcaPut('IOC:BSY0:MP01:PCELLCTL',1);pause(1.+wait/3);return, end

    enFin0=stat(6)-stat(1)*stat(3)*cosd(stat(2)+stat(4))*1e-3;
    enFin=enFin0+act*stat(3)*cosd(ph(1)+stat(4))*1e-3;
    model_energySetPoints(enFin,5);
%    lcaPut('SIOC:SYS0:ML00:AO409',enFin);
    static=model_energyMagProfile(handles.energy,{'L3' 'LTU'},'doPlot',0);
    m=model_energyMagScale(static);
    gui_statusDisp(handles,'Scaling magnets ...');
    model_energyMagTrim(m,[],'action','PERTURB');
    gui_statusDisp(handles,'Scaling magnets done.');
    lcaPut('IOC:BSY0:MP01:PCELLCTL',1);pause(4.);
    return
end
val=handles.acquireDataList(handles.dataDevice.iVal);
set(handles.acquireEnergySet_btn,'String','Setting');
gui_statusDisp(handles,['Setting final energy to ' num2str(val) ' ...']);
guidata(hObject,handles);
if handles.appMode || epicsSimul_status
    model_energySet(val);
end
handles=guidata(hObject);
gui_statusDisp(handles,['Setting final energy to ' num2str(val) ' done']);
set(handles.acquireEnergySet_btn,'String','Set Energy');
%set(handles.measureQuadVal_txt,'String',sprintf('%5.2f kG',val));
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireEnergyReset(hObject, handles)

if handles.acquireDataNum == 1, return, end
if handles.acquireDataNum == 2 && handles.appTask == 2
    val=1;
    if isfield(handles,'undStatus'), val=1-handles.undStatus;end
    str={'Out' 'In'};
    gui_statusDisp(handles,['Resetting Undulator to ' str{val(1)+1} ' ...']);
    undInOutControl(hObject,handles,val);
    gui_statusDisp(handles,['Resetting Undulator to ' str{val(1)+1} ' done']);
    return
end
if handles.appTask == 3
    val=0;
    if isfield(handles,'undStatus'), val=handles.undStatus;end
    gui_statusDisp(handles,['Resetting Undulator to ' num2str(val) ' mm ...']);
    undPV=model_nameConvert(cellstr(num2str(handles.simul.girderNum(:)','US%02d')));
    lcaPutNoWait(strcat(undPV,':TMXPOSC'),val);if ~epicsSimul_status, pause(1.);end
    while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), pause(1.);end
    gui_statusDisp(handles,['Resetting Undulator to ' num2str(val) ' mm done']);
    return
end
if handles.appTask == 4
    val=[0 0];
    if isfield(handles,'klysStatus'), val=handles.klysStatus;end
    gui_statusDisp(handles,['Resetting Klystron Phase to ' num2str(val(2)) ' Deg ...']);
    name=handles.klysName;
    lcaPut('IOC:BSY0:MP01:PCELLCTL',0);pause(.3);
    control_klysStatSet(name,val(1));
    control_phaseSet(name,val([2 7]),0,[],{'PDES' 'KPHR'});
%    control_phaseSet(name,val(2));
    gui_statusDisp(handles,['Resetting Klystron Phase to ' num2str(val(2)) ' Deg done']);
    if isfield(handles,'fbStatus'), lcaPutSmart(handles.fbNames,handles.fbStatus);end

    if ~handles.doLEM, lcaPut('IOC:BSY0:MP01:PCELLCTL',1);pause(1.);return, end

    model_energySetPoints(handles.klysStatus(6),5);
%    lcaPut('SIOC:SYS0:ML00:AO409',handles.klysStatus(6));
    static=model_energyMagProfile(handles.energy,{'L3' 'LTU'},'doPlot',0,'getSCP',1);
    m=model_energyMagScale(static);
    gui_statusDisp(handles,'Scaling magnets ...');
%    model_energyMagTrim(m);
    model_energyMagTrim(m,[],'action','PERTURB');
    gui_statusDisp(handles,'Scaling magnets done.');
    lcaPut('IOC:BSY0:MP01:PCELLCTL',1);pause(4.);
    return
end
val=13.64;
set(handles.acquireEnergyReset_btn,'String','Setting');
gui_statusDisp(handles,['Resetting final energy to ' num2str(val) ' ...']);
if handles.appMode || epicsSimul_status
    model_energySet(val);
end
lcaPut('SIOC:SYS0:ML00:AO875',val);
gui_statusDisp(handles,['Resetting final energy to ' num2str(val) ' done']);
set(handles.acquireEnergyReset_btn,'String','Reset Energy');
%set(handles.measureQuadVal_txt,'String',sprintf('%5.2f kG',val));


% ------------------------------------------------------------------------
function handles = undInOutSave(hObject, handles)

iGird=handles.simul.girderNum;
if handles.appTask ==2
    [d,undStat]=segmentInOutOffsetApply(iGird,'noApply',1);
else
    undPV=model_nameConvert(cellstr(num2str(iGird(:)','US%02d')));
    undStat=lcaGet(strcat(undPV,':TMXPOSC'));
end
handles.undStatus=undStat;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = klysStatSave(hObject, handles)

[act,d,d,d,d,amp]=control_klysStatGet(handles.klysName);
[ampAct,phT]=model_energyKlys(handles.klysName);
if ampAct > 0, amp=ampAct;end
[ph,kp]=control_phaseGet(handles.klysName,{'PDES' 'KPHR'});
enDef=model_energySetPoints;
handles.klysStatus=[bitand(act,1) > 0 ph amp phT-ph act enDef(5) kp];
guidata(hObject,handles);
str={'' ' not'};
gui_statusDisp(handles,['Klystron ' handles.klysName str{bitand(act,4) > 0} ' available']);


% ------------------------------------------------------------------------
function handles = acquireSampleNumControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_editControl(hObject,handles,'acquireSampleNum',val,1,1,[0 1 2800]);
if cancd, return, end
handles=dataCurrentSampleControl(hObject,handles,1,handles.acquireSampleNum);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSampleControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSample',iVal,nVal);


% ------------------------------------------------------------------------
function handles = acquireCurrentGet(hObject, handles, state)

if strcmp(handles.sectorSel,'UND'), model_init('online',0);end

handles=gui_BSAControl(hObject,handles,[]);
if ~handles.acquireBSA
    uiwait(errordlg('No EDEF avaiable.  Please release unused EDEFs.','Out of EDEF'));
    return
end
iVal=handles.dataDevice.iVal;
handles.process.saved=0;
if strcmp(state,'remote')
    handles=acquireEnergySet(hObject,handles);
end
if ~isfield(handles.data,'ts'), handles.data.ts=now;end
if ~isfield(handles.data,'energy'), handles.data.energy=handles.acquireDataList;end
[d,en]=bba_responseMatGet(handles.static,handles.appMode,1);
if handles.appTask >= 3, handles.data.energy(:)=en;end
gui_statusDisp(handles,sprintf('Getting matrices for %5.2f GeV ...',handles.acquireDataList(iVal)));
if ~(handles.keepRMat || handles.fitGirderMove) || ~isfield(handles.data,'R') || handles.data.energy(iVal) ~= en
    [handles.data.R{iVal},handles.data.energy(iVal)]=bba_responseMatGet(handles.static,handles.appMode);
end
gui_statusDisp(handles,sprintf('Getting corrector strengths for %5.2f GeV ...',handles.acquireDataList(iVal)));
corrB=bba_corrGet(handles.static,handles.appMode);
if ~any(corrB(:)), corrB=[];end
handles.data.corrB{iVal}=corrB;
gui_statusDisp(handles,sprintf('Getting data for %5.2f GeV ...',handles.acquireDataList(iVal)));
if handles.appMode && ~epicsSimul_status
    handles.bykik=lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'double');
end
handles.data.xMeas{iVal}=bba_bpmDataGet(handles.static,handles.data.R{min(iVal,end)}, ...
    handles.appMode,handles,handles.simul);
gui_statusDisp(handles,sprintf('Getting data for %5.2f GeV done.',handles.acquireDataList(iVal)));
handles.data.status(iVal)=1;
guidata(hObject,handles);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end
[handles,cancd]=acquireReset(hObject,handles);
if cancd, gui_acquireStatusSet(hObject,handles,0);return, end
if handles.appTask == 2, handles=undInOutSave(hObject,handles);end
if handles.appTask == 3, handles=undInOutSave(hObject,handles);end
if handles.appTask == 4
    handles.fbNames=control_fbNames;
    if ~handles.doLEM
        handles.fbNames={'FBCK:FB02:TR01:MODE';'FBCK:L3L0:1:ENABLE'; ...
                         'FBCK:FB02:TR02:MODE';'FBCK:L280:1:ENABLE'};
    end
    handles.fbStatus=lcaGetSmart(handles.fbNames,0,'double');
    handles=klysStatSave(hObject,handles);
    if bitand(handles.klysStatus(5),4) > 1, gui_acquireStatusSet(hObject,handles,0);return, end
    lcaPutSmart(handles.fbNames,0);
end

for j=1:handles.dataDevice.nVal
    handles=dataCurrentDeviceControl(hObject,handles,j,[]);
    handles=acquireCurrentGet(hObject,handles,'remote');
    if ~gui_acquireStatusGet(hObject,handles), break, end
end

acquireEnergyReset(hObject,handles);
gui_acquireStatusSet(hObject,handles,0);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataAverageControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'dataAverage',val);
handles.process.done=0;
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataShowAllControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'dataShowAll',val);
handles=plotOrbit(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataShowErrorControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'dataShowError',val);
handles=plotOrbit(hObject,handles);


% ------------------------------------------------------------------------
function handles = fitCorrControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'fitCorr',val);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = fitUndI2Control(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'fitUndI2',val);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = fitUndControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'fitUnd',val);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = fitUndCorrControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'fitUndCorr',val);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = fitGirderMoveControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'fitGirderMove',val);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = fitDiffControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'fitDiff',val);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = keepRMatControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'keepRMat',val);


% ------------------------------------------------------------------------
function handles = undInOutControl(hObject, handles, val)

str={'Out' 'In'};
set(handles.(['und' str{val(1)+1} '_btn']),'String','Setting');
segmentMoveInOut(handles.simul.girderNum,val);
set(handles.(['und' str{val(1)+1} '_btn']),'String',['Und ' str{val(1)+1}]);


% ------------------------------------------------------------------------
function handles = undZeroControl(hObject, handles, num)

if nargin < 3, num=handles.simul.girderNum;end
undPV=model_nameConvert(cellstr(num2str(num(:),'US%02d')));
lcaPutNoWait(strcat(undPV,':TMXPOSC'),0);pause(1.);
while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), pause(1.);end


% ------------------------------------------------------------------------
function [xMeas, xMeasStd] = getMeas(handles, iVal, iSample)

data=handles.data;
if nargin < 2
    iVal=find(data.status & data.use);
end
if nargin < 3
    iSample=1:handles.dataSample.nVal;
end
xMeas=cat(4,data.xMeas{iVal});

if handles.dataAverage
    % Find BPMs with all bad samples for one measurement.
    isBadBPM=any(all(isnan(xMeas),3)); 
    for j=1:size(xMeas,4)
        % Find bad samples for good BPMs.
        isBadSample=any(any(isnan(xMeas(:,~isBadBPM(:,:,:,j),:,j)),2));
        xMeas(:,:,isBadSample,j)=NaN;
    end
    xMeasStd=util_stdNan(xMeas,0,3)./sqrt(sum(~isnan(xMeas),3));
    xMeas=util_meanNan(xMeas,3);
else
    xMeas=xMeas(:,:,iSample,:);
    xMeasStd=[];
end

if sum(data.status) > 1 && (handles.fitCorr || handles.appTask == 40) % don't know about the 40
    idx=size(cat(3,data.R{:}),2);idx=idx-numel(handles.static.corrList)*2+1:idx;
    xCorr=xMeas;
    for j=1:numel(iVal)
        corrB=data.corrB{iVal(j)};corrB(isnan(corrB))=0;
        if isempty(corrB), corrB=zeros(numel(idx),1);end
        xCorr(:,:,:,j)=repmat(reshape(data.R{min(iVal(j),end)}(:,idx)*corrB(:),2,[]),[1 1 size(xCorr,3) 1]);
    end
    xMeas=xMeas-xCorr;
end

if handles.fitDiff
    xMeas(:,:,:,2:end)=xMeas(:,:,:,2:end)-repmat(xMeas(:,:,:,1),[1 1 1 size(xMeas,4)-1]);
    xMeasStd(:,:,:,2:end)=sqrt(xMeasStd(:,:,:,2:end).^2+repmat(xMeasStd(:,:,:,1).^2,[1 1 1 size(xMeas,4)-1]));
end
xMeas=xMeas(:,:,:);xMeasStd=xMeasStd(:,:,:);


% ------------------------------------------------------------------------
function handles = acquireUpdate(hObject, handles)

if ~isfield(handles,'data'), return, end
data=handles.data;
use=data.status & data.use;

%if ~any(use) || sum(data.status) < 2 && ~handles.fitCorr || 0
if ~any(use)
    handles=plotOrbit(hObject,handles);
    return
end

[xMeas,xMeasStd]=getMeas(handles);

use=find(use);
R=cat(3,data.R{min(use,end)});
nBPM=size(R,1)/2;
nPar=size(R,2);
nEn=size(R,3);
nInit=4+mod(nPar,2); % assumes 4 or 5 nInit

r=zeros(2*nBPM,nEn,nPar+nInit*(nEn-1));
for k=1:nEn
    r(:,k,[(1:nInit)+nInit*(k-1) nInit*nEn+(1:nPar-nInit)])=R(:,:,k);
end

if ~handles.dataAverage
    for k=1:nEn*handles.acquireSampleNum
        r(:,k,[(1:nInit)+nInit*(k-1) nInit*nEn+(1:nPar-nInit)])=data.R{use(fix((k-1)/handles.acquireSampleNum)+1)};
    end
end

opts=handles.simul;
opts.use=struct('init',1,'quad',1,'BPM',1,'corr',0,'und',0);
opts.iInit=1:4;
tle=['BBA Scan Fit Result ' datestr(handles.data.ts)];
%handles.data.xMeasF=NaN(size(xMeas,1),size(xMeas,2),sum(data.status));
handles.data.xMeasF=repmat(xMeas(:,:,1),[1 1 sum(data.status)])*NaN;
if sum(data.status) == 2 && handles.fitGirderMove && handles.appTask ~= 3 % fit und IN/OUT
    use=1;
    iGird=handles.simul.girderNum;
    tle=['Undulator ' num2str(iGird(unique([1 end])),'US%02d ') ' In/Out Orbit Fit Result ' datestr(handles.data.ts)];
%    opts.iQuad=max(1,iGird-1):iGird;
%    opts.iBPM=find(handles.static.zBPM > handles.static.zQuad(iGird),1);
    opts.iQuad=reshape([iGird-1;iGird],1,[]);opts.iQuad(~opts.iQuad)=[];
    opts.iBPM=iGird+3;
    opts.iBPM=[opts.iBPM(iGird == 1)-1 opts.iBPM];
    f=bba_fitOrbit(handles.static,data.R{use},xMeas(:,:,end),xMeasStd(:,:,end),opts);
    disp(f.quadOff(:,opts.iQuad));
    disp(f.bpmOff(:,opts.iBPM));
    handles.data.xMeasF=f.xMeasF(:,:,[1 1]);
elseif sum(data.status) >= 2 && handles.fitGirderMove % fit und field integral vs. position
    val=handles.acquireDataList(use);
    use=1;
    iGird=handles.simul.girderNum;
    tle=['Undulator ' num2str(iGird(unique([1 end])),'US%02d ') ' Field Integral Orbit Fit Result ' datestr(handles.data.ts)];
    opts.iQuad=reshape(iGird,1,[]);
    if handles.fitUndI2 && ~handles.fitUnd
        opts.iQuad=reshape([iGird-1;iGird],1,[]);
    end
    opts.iQuad(~opts.iQuad)=[];
    opts.iBPM=iGird+3;
    opts.iBPM=[opts.iBPM(iGird == 1)-1 opts.iBPM];
    opts.iCorr=opts.iQuad;opts.iUnd=opts.iQuad;
    xM=xMeas(:,:,1);xMeas(:,:,1)=0;xMeasStd(:,:,1)=0;
    if handles.fitUnd, opts.use.quad=0;opts.use.und=1;end
    if handles.fitUndCorr, opts.use.quad=0;opts.use.corr=1;end
    for j=1:size(xMeas,3)
        fj=bba_fitOrbit(handles.static,data.R{use},xMeas(:,:,j),xMeasStd(:,:,j),opts);
        handles.data.xMeasF(:,:,j)=fj.xMeasF+xM*1;
        for t=fieldnames(fj)', f.(t{:})(:,:,j)=fj.(t{:});end
    end
    opts.use.quad=1;units=1e6;
    if opts.use.corr
        opts.use.corr=0;units=1e3;
        f.quadOff=f.corrOff;f.quadOffStd=f.corrOffStd;
    end
    if opts.use.und
        opts.iQuad=[opts.iUnd-1 opts.iUnd];
        bp=data.energy(1)/299.792458*1e4; % kG m
        f.quadOff=f.undOff([2 4],:,:);f.quadOff(:,1:end-1,:)=f.quadOff(:,1:end-1,:)+f.undOff([1 3],2:end,:);
        f.quadOffStd=f.undOffStd([2 4],:,:);f.quadOffStd(:,1:end-1,:)=f.quadOffStd(:,1:end-1,:)+f.undOffStd([1 3],2:end,:);
%        f.quadOff=f.quadOff/bp;f.quadOffStd=f.quadOffStd/bp;
    end

    hAxes=util_plotInit('figure',3,'axes',{3 1});
    xLim=sort(val([1 end]))*[1.1 -.1;-.1 1.1];
    qOff2=squeeze(f.quadOff(:,opts.iQuad(end),:));qOff2Std=squeeze(f.quadOffStd(:,opts.iQuad(end),:));
    qOff1=squeeze(f.quadOff(:,max(1,opts.iQuad(end)-1),:));qOff1Std=squeeze(f.quadOffStd(:,max(1,opts.iQuad(end)-1),:));
    bOff=squeeze(f.bpmOff(:,opts.iBPM(end),:));bOffStd=squeeze(f.bpmOffStd(:,opts.iBPM(end),:));
    disp([qOff2*units;qOff1*units;bOff*1e6]);
    valf=linspace(min(val),max(val),100);
    handles.poly=fitPolyVals(val,[qOff2;qOff1;bOff]);
    [qOff2f,qOff1f,bOfff]=getPolyVals(handles.poly,valf);
    errorbar(hAxes(1),[val;val]',qOff2'*units,qOff2Std'*units,'.');xlim(hAxes(1),xLim);ylabel(hAxes(1),'Quad Offset 2 (\mum)');
    errorbar(hAxes(2),[val;val]',qOff1'*units,qOff1Std'*units,'.');xlim(hAxes(2),xLim);ylabel(hAxes(2),'Quad Offset 1 (\mum)');
    errorbar(hAxes(3),[val;val]',bOff'*1e6,bOffStd'*1e6,'.');xlim(hAxes(3),xLim);ylabel(hAxes(3),'BPM Offset  (\mum)');
    hold(hAxes(1),'on');plot(hAxes(1),valf,qOff2f'*units,'-.');hold(hAxes(1),'off');
    hold(hAxes(2),'on');plot(hAxes(2),valf,qOff1f'*units,'-.');hold(hAxes(2),'off');
    hold(hAxes(3),'on');plot(hAxes(3),valf,bOfff'*1e6,'-.');hold(hAxes(3),'off');
    xlabel(hAxes(3),'Und Position  (mm)');
elseif sum(data.status) == 1 && handles.fitCorr % fit for SVD steering
    opts.use=struct('init',0,'quad',0,'BPM',0,'corr',1);
    if isfield(data,'corrB'), opts.corrB=cat(3,data.corrB{use});end
%    opts.corrB=bba_corrGet(handles.static,handles.appMode);
    isRFB=strncmp(handles.static.bpmList,'RFB',3);
    xMeasStd(:,isRFB)=xMeasStd(:,isRFB)*1e-1;
    if isfield(handles,'bykik') && ~handles.bykik
        isBYK=strcmp(handles.static.bpmList,'BPMDL2');
        xMeas(:,find(isBYK,1):end)=NaN;
    end
    f=bba_fitOrbit(handles.static,r,xMeas,xMeasStd,opts);
    handles.data.xMeasF=xMeas-f.xMeasF;
elseif sum(data.status) > 1 && handles.fitCorr % fit for SVD steering
    opts.use=struct('init',0,'quad',1,'BPM',1,'corr',1);
%    opts.corrB=cat(3,data.corrB{use});
%    use=use(2:end);
%    r=zeros(2*nBPM,nEn-1,nPar+4*(nEn-2));
    for k=1:nEn-1
%        r(:,k,[(1:4)+4*(k-1) 4*nEn+(1:nPar-4)])=diff(R(:,:,k:k+1),1,3);
    end
    if 0
        isBSY=strcmp(handles.static.bpmList,'BPMBSYQ2');
        xMeas(:,1:find(isBSY,1)-1)=NaN;
        opts.iCorr=find(handles.static.zCorr > handles.static.zBPM(isBSY));
    end
    f=bba_fitOrbit(handles.static,r,xMeas(:,:,use),xMeasStd(:,:,use),opts);
%    f=bba_fitOrbit(handles.static,r,xMeas,xMeasStd,opts);
    handles.data.xMeasF(:,:,use)=f.xMeasF;
    global strayB
    try
        err=(f.corrOff'-strayB')./strayB';
        disp(max(err(~isnan(err))));
    catch
    end
elseif sum(data.status) > 2 && handles.appTask == 4 % fit klystron kicks
    opts.use=struct('init',1,'quad',0,'BPM',0,'corr',1);
    opts.iInit=1:5;
    id=sscanf(handles.klysName,'%d-%d');
    iSect=id(1);
    iKlys=id(2);
    nameX=strrep(strcat('XC',cellstr(num2str(iSect)),cellstr(num2str(iKlys+1)),'02'),'902','900');
    nameY=strrep(strcat('YC',cellstr(num2str(iSect)),cellstr(num2str(iKlys+1)),'03'),'903','900');
    isFBX=ismember(handles.static.corrList,nameX);idFBX=find(isFBX);
    isFBY=ismember(handles.static.corrList,nameY);idFBY=find(isFBY);
%    isFBX(idFBX-1)=1;isFBY(idFBY-1)=1;
    opts.iCorr=isFBX | isFBY;
    r=R(:,:,1);
    use(1)=[];
    [corrX,corrStdX]=deal(zeros(sum(isFBX),numel(use)));
    [corrY,corrStdY]=deal(zeros(sum(isFBY),numel(use)));
    [en,enStd]=deal(zeros(1,numel(use)));
    isDL1=strcmp(handles.static.bpmList,'BPMDL1');
%    isBYK=strcmp(handles.static.bpmList,'BPMBSY92');
%    isBYK=strcmp(handles.static.bpmList,'BPM26301');
    zKlys=mean(handles.static.zCorr(isFBX));
    bad=abs(handles.static.zBPM-zKlys) > 150;
    bad=bad & ~isDL1';
% %   bad=find(isBYK,1):size(xMeas,2);
% %   bad=setdiff(bad,find(isDL1));
    xMeas(:,bad,:)=NaN;
    val=handles.acquireDataList(use);
%    bp0=4.3;
    for j=1:numel(use)
        f=bba_fitOrbit(handles.static,r,xMeas(:,:,j+1),xMeasStd(:,:,j+1),opts);
%        bba_plotOrbit(handles.static,xMeas(:,:,j+1),xMeasStd(:,:,j+1),f.xMeasF(:,:,1),data.energy(j+1));pause(1);
%        bp=bp0+.254*cosd(val(j));bp=bp0;
        corrX(:,j)=reshape(f.corrOff(1,isFBX),[],1);%*bp/bp0;
        corrY(:,j)=reshape(f.corrOff(2,isFBY),[],1);%*bp/bp0;
        corrStdX(:,j)=reshape(f.corrOffStd(1,isFBX),[],1);
        corrStdY(:,j)=reshape(f.corrOffStd(2,isFBY),[],1);
        en(j)=f.xInit(5);enStd(j)=f.xInitStd(5);
        handles.data.xMeasF(:,:,use(j))=f.xMeasF;
    end
    hAxes=util_plotInit('figure',2,'axes',{size(corrX,1)+1 1});
    for k=1:size(corrX,1)
        [parX,parCov,parXStd,fphaseX,fdataX,fdataStdX]=beamAnalysis_phaseFit(val,corrX(k,:),corrStdX(k,:),'offset',1);
        [parY,parCov,parYStd,fphaseY,fdataY,fdataStdY]=beamAnalysis_phaseFit(val,corrY(k,:),corrStdY(k,:),'offset',1);
        util_errorBand([fphaseX;fphaseY]',[fdataX fdataY]*1e3,[fdataStdX fdataStdY]*1e3,'Parent',hAxes(k));
        hold(hAxes(k),'on');
        errorbar([val;val]',[corrX(k,:);corrY(k,:)]'*1e3,[corrStdX(k,:);corrStdY(k,:)]'*1e3,'.','Parent',hAxes(k));
        hold(hAxes(k),'off');
        xlabel(hAxes(k),'Phase  (Deg)');
        ylabel(hAxes(k),'Corrector Strength  (G-m)');
    end
    k=k+1;
        [parE,parCov,parEStd,fphaseE,fdataE,fdataStdE]=beamAnalysis_phaseFit(val,en(1,:),enStd(1,:),'offset',1);
        util_errorBand(fphaseE',fdataE*1e3*4.3,fdataStdE*1e3*4.3,'Parent',hAxes(k));
        hold(hAxes(k),'on');
        errorbar(val',en(1,:)'*1e3*4.3,enStd(1,:)'*1e3*4.3,'.','Parent',hAxes(k));
        hold(hAxes(k),'off');
        xlabel(hAxes(k),'Phase  (Deg)');
        ylabel(hAxes(k),'Energy Error  (MeV)');
    title(hAxes(1),['Klystron ' handles.klysName ' Kick Measurement ' datestr(handles.data.ts)]);

    disp(diag([1e3 1 1e3])*[parX parXStd parY parYStd]);
    handles.klysPar=[parX' parY'];
    handles.klysParStd=[parXStd' parYStd'];
    opts.use.corr=0;
elseif sum(data.status) == 1 && handles.appTask == 0 % fit quick BBA
%    return
    opts.use=struct('init',1,'quad',0,'BPM',0,'corr',0,'und',0);
%    opts.use=struct('init',1,'quad',1,'BPM',0,'corr',0,'und',0);
%    opts.iQuad=15:16;
    opts.fitBPMSlope=1;xMeas2=xMeas;xMeas2(:,1:3)=NaN;
%    f=bba_fitOrbit(handles.static,r,xMeas,xMeasStd,opts);
    f=bba_fitOrbit(handles.static,r,xMeas2,[],opts); % Don't use errorbars, gives bias
    off2=zeros(2,numel(handles.static.zBPM));

    % Extract slope from fit.
    off2(:)=kron([handles.static.zBPM' ones(size(xMeas,2),1)],eye(2))*f.bpmOff(1:4)';
    handles.data.xMeasF(:,:,use)=f.xMeasF;
    f.bpmOff(:)=-(xMeas-(f.xMeasF-off2));
    f.bpmOffStd(:)=xMeasStd;
    opts.use.BPM=1;
else % fit standard BBA
    opts.quadB=control_magnetGet(handles.static.quadList,'BDES');
    opts.fitQuadKick=1;
    isRFB=strncmp(handles.static.bpmList,'RFB',3);
    xMeasStd(:,isRFB,:)=xMeasStd(:,isRFB,:)*1e-1;
    f=bba_fitOrbit(handles.static,r,xMeas,xMeasStd,opts);
    handles.data.xMeasF(:,:,use)=f.xMeasF;
end

handles.fitResult=f;
if opts.use.quad || opts.use.BPM
    bba_plotOffset(handles.static,{f.quadOff f.quadOffStd},{f.bpmOff f.bpmOffStd},handles.appMode, ...
        'title',tle,'ylim',str2num(get(handles.plotRange_txt,'String')));
end
if opts.use.corr
    bba_plotCorr(handles.static,-f.corrOff,handles.appMode);
end
guidata(hObject,handles);
plotOrbit(hObject,handles);


% ------------------------------------------------------------------------
function handles = plotOrbit(hObject, handles)

iVal=handles.dataDevice.iVal;
set(handles.dataDeviceUse_box,'Value',handles.data.use(iVal));
if handles.dataShowAll
    iVal=find(logical(handles.data.status) & handles.data.use);
end
if ~any(handles.data.status(iVal))
    bba_plotOrbit(handles.static,[],[],[],[]);
    return
end
if handles.fitDiff && ~any(iVal == 1)
    iVal=[1;2;iVal]; % Used for klys kick to always show the first 2 set points
end

iSample={};if ~handles.dataAverage, iSample={handles.dataSample.iVal};end
[xMeas,xMeasStd]=getMeas(handles,iVal,iSample{:});

if handles.fitDiff && ~handles.dataShowAll && numel(iVal) > 1
    xMeas(:,:,1)=[];xMeasStd(:,:,1)=[];
    iVal(1)=[];
end

if isfield(handles.data,'xMeasF')
    xMeasF=permute(reshape(handles.data.xMeasF(:,:,min(iVal,end)),2,size(xMeas,2),[],size(xMeas,3)),[1 2 4 3]);
    xMeasF=xMeasF(:,:,:,min(handles.dataSample.iVal,end));
else
    xMeasF=xMeas*NaN;
end
en=handles.data.energy(iVal);

if sum(handles.data.status) > 1 && handles.fitCorr && 0
    xMeasF(:,:,1)=xMeas(:,:,1);
    xMeas=cumsum(xMeas,3);
    xMeasF=cumsum(xMeasF,3);
end

if sum(handles.data.status) > 1 && handles.fitCorr && 1
    idx=size(cat(3,handles.data.R{:}),2);idx=idx-numel(handles.static.corrList)*2+1:idx;
    xCorr=xMeas;
    for j=iVal(:)'
        corrB=handles.data.corrB{j};corrB(isnan(corrB))=0;
        xCorr(:,:,j)=reshape(handles.data.R{j}(:,idx)*corrB(:),2,[]);
    end
    xMeas=xMeas+xCorr;
    xMeasF=xMeasF+xCorr;
end

% Plot results.
guidata(hObject,handles);
if handles.fitCorr && isfield(handles,'fitResult')
    opts.corrB=-handles.fitResult.corrOff;
end
opts.title=['BBA Scan Orbit ' datestr(handles.data.ts)];
opts.ylim=str2num(get(handles.plotRange_txt,'String'));
if handles.dataShowError, xMeas=xMeas-xMeasF;xMeasF=[];end
bba_plotOrbit(handles.static,xMeas,xMeasStd,xMeasF,en,opts);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles, val)

[data,fileName]=util_dataLoad('Open BBA scan',0);
if ~ischar(fileName), return, end
handles.fileName=fileName;

handles.process.saved=1;
handles=sectorControl(hObject,handles,'UND');
if isfield(data,'static'), handles.static=data.static;end
if ~isfield(data,'use'), data.use=data.status*0+1;end
handles=acquireDataRangeControl(hObject,handles,1:2,data.energy([1 end]));
if sum(data.status) > numel(data.R)
    handles.appTask=3;
    handles=acquireDataRangeControl(hObject,handles,1:2,[80 0]);
    handles.appTask=4;
    handles=acquireDataRangeControl(hObject,handles,1:2,[-90 90]);
end
if any(strfind(char(data.name),'-'))
    handles.appTask=4;
    handles=klysNameControl(hObject,handles,data.name);
    handles=acquireDataRangeControl(hObject,handles,1:2,data.val([2 end]));
    handles=fitDiffControl(hObject,handles,1);
end
if strncmp(char(data.name),'US',2)
    handles.appTask=2;
    handles=dataFitTxtControl(hObject,handles,'girderNum',str2num(data.name(3:end)));
    handles=fitDiffControl(hObject,handles,1);
    handles=fitGirderMoveControl(hObject,handles,1);
    handles=fitCorrControl(hObject,handles,0);
    set(handles.output,'Name','Undulator Segment Motion Measurement');
end
handles=acquireDataNumControl(hObject,handles,length(data.energy));
handles=acquireSampleNumControl(hObject,handles,size([data.xMeas{:}],3));
handles.data=data;
handles.process.saved=1;
guidata(hObject,handles);
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

data=handles.data;
if ~any(data.status), return, end
data.static=handles.static;
if handles.appTask == 2, data.name=num2str(handles.simul.girderNum(unique([1 end])),'US%02d ');end
if handles.appTask == 4, data.name=handles.klysName;data.val=handles.acquireDataList;end
fileName=util_dataSave(data,'BBAScan',data.name,data.ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

handles.exportFig=[1 2];
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',12);
if val
    util_printLog(handles.exportFig,'title',['Beam Based Alignment (BBA) in ' handles.sectorSel]);
    dataSave(hObject,handles,0);
end


% --- Executes on button press in test_btn.
function test_btn_Callback(hObject, eventdata, handles)

gui_statusDisp(handles,'Run Simulation ...');
[f.xInit,f.quadOff,f.bpmOff,f.xMeas]=bbaTest(handles.appMode,handles.simul);
handles.fitResult=f;
guidata(hObject,handles);
gui_statusDisp(handles,'Run Simulation Done');


% --- Executes on button press in useGirdOff_box.
function useGirdOff_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useGirdOff',get(hObject,'Value'));


% --- Executes on button press in useGirdSlope_box.
function useGirdSlope_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useGirdSlope',get(hObject,'Value'));


% --- Executes on button press in useQuadOff_box.
function useQuadOff_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useQuadOff',get(hObject,'Value'));


% --- Executes on button press in useUndOff_box.
function useUndOff_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useUndOff',get(hObject,'Value'));


% --- Executes on button press in useBPMOff_box.
function useBPMOff_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBPMOff',get(hObject,'Value'));


% --- Executes on button press in useBPMNoise_box.
function useBPMNoise_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBPMNoise',get(hObject,'Value'));


% --- Executes on button press in useBeamJitt_box.
function useBeamJitt_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useBeamJitt',get(hObject,'Value'));


% --- Executes on button press in useGirdBack_box.
function useGirdBack_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useGirdBack',get(hObject,'Value'));


% --- Executes on button press in useUnd_box.
function useUnd_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useUnd',get(hObject,'Value'));


% --- Executes on button press in useStray_box.
function useStray_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useStray',get(hObject,'Value'));


% --- Executes on button press in useLaunch_box.
function useLaunch_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useLaunch',get(hObject,'Value'));


% --- Executes on button press in useUndFI_box.
function useUndFI_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useUndFI',get(hObject,'Value'));


% --- Executes on button press in useDriftB_box.
function useDriftB_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useDriftB',get(hObject,'Value'));


% --- Executes on button press in useSteer_box.
function useSteer_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'useSteer',get(hObject,'Value'));


% --- Executes on button press in noEPlusCorr_box.
function noEPlusCorr_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'noEPlusCorr',get(hObject,'Value'));


% --- Executes on button press in getFI_box.
function getFI_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'getFI',get(hObject,'Value'));


% --- Executes on button press in getDrift_box.
function getDrift_box_Callback(hObject, eventdata, handles)

boxControl(hObject,handles,'getDrift',get(hObject,'Value'));


% --- Executes on button press in fit_init_box.
function fit_init_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,{'fit' 'init'},get(hObject,'Value'));


% --- Executes on button press in fit_quad_box.
function fit_quad_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,{'fit' 'quad'},get(hObject,'Value'));


% --- Executes on button press in fit_BPM_box.
function fit_BPM_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,{'fit' 'BPM'},get(hObject,'Value'));


% --- Executes on button press in fit_corr_box.
function fit_corr_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,{'fit' 'corr'},get(hObject,'Value'));


% --- Executes on button press in fit_FI_box.
function fit_FI_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,{'fit' 'FI'},get(hObject,'Value'));


% --- Executes on button press in fit_drift_box.
function fit_drift_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,{'fit' 'drift'},get(hObject,'Value'));


function girdBack_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'girdBack',str2num(get(hObject,'String')));


function girdOff_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'girdOff',str2num(get(hObject,'String')));


function girdSlope_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'girdSlope',str2num(get(hObject,'String')));


function quadOff_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'quadOff',str2num(get(hObject,'String')));


function undOff_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'undOff',str2num(get(hObject,'String')));


function launch_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'launch',str2num(get(hObject,'String')));


function bpmOff_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'bpmOff',str2num(get(hObject,'String')));


function bpmNoise_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'bpmNoise',str2num(get(hObject,'String')));


function beamJitt_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'beamJitt',str2num(get(hObject,'String')));


function enRange_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'enRange',str2num(get(hObject,'String')));


function nEnergy_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'nEnergy',str2num(get(hObject,'String')));


function undFI_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'undFI',str2num(get(hObject,'String')));


function driftB_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'driftB',str2num(get(hObject,'String')));


function corrGain_txt_Callback(hObject, eventdata, handles)

txtControl(hObject,handles,'corrGain',str2num(get(hObject,'String')));


function girderNum_txt_Callback(hObject, eventdata, handles)

dataFitTxtControl(hObject,handles,'girderNum',str2num(get(hObject,'String')));


function fitScale_txt_Callback(hObject, eventdata, handles)

dataFitTxtControl(hObject,handles,'fitScale',str2num(get(hObject,'String')));


function fitSVDRatio_txt_Callback(hObject, eventdata, handles)

dataFitTxtControl(hObject,handles,'fitSVDRatio',str2num(get(hObject,'String')));


% --- Executes on button press in fitBPMLin_box.
function fitBPMLin_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,'fitBPMLin',get(hObject,'Value'));


% --- Executes on button press in fitBPMMin_box.
function fitBPMMin_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,'fitBPMMin',get(hObject,'Value'));


% --- Executes on button press in fitQuadMin_box.
function fitQuadMin_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,'fitQuadMin',get(hObject,'Value'));


% --- Executes on button press in fitQuadLin_box.
function fitQuadLin_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,'fitQuadLin',get(hObject,'Value'));


% --- Executes on button press in fitCorrAbs_box.
function fitCorrAbs_box_Callback(hObject, eventdata, handles)

dataFitStatusControl(hObject,handles,'fitCorrAbs',get(hObject,'Value'));


% --- Executes on button press in acquireCurrentGet_btn.
function acquireCurrentGet_btn_Callback(hObject, eventdata, handles)

acquireCurrentGet(hObject,handles,'query');


% --- Executes on slider movement.
function dataDevice_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentDeviceControl(hObject,handles,round(get(hObject,'Value')),[]);
plotOrbit(hObject,handles);


% --- Executes on button press in dataDeviceUse_box.
function dataDeviceUse_box_Callback(hObject, eventdata, handles)

%handles=gui_checkBoxControl(hObject,handles,'data.use',get(hObject,'Value'),handles.dataDevice.nVal);
handles.data.use(handles.dataDevice.iVal)=get(hObject,'Value');
acquireUpdate(hObject,handles);


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


function acquireDataRangeLow_txt_Callback(hObject, eventdata, handles)

acquireDataRangeControl(hObject,handles,1,str2double(get(hObject,'String')));


function acquireDataRangeHigh_txt_Callback(hObject, eventdata, handles)

acquireDataRangeControl(hObject,handles,2,str2double(get(hObject,'String')));


function acquireDataNum_txt_Callback(hObject, eventdata, handles)

acquireDataNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


% --- Executes on button press in acquireEnergySet_btn.
function acquireEnergySet_btn_Callback(hObject, eventdata, handles)

acquireEnergySet(hObject,handles);


% --- Executes on button press in acquireEnergyReset_btn.
function acquireEnergyReset_btn_Callback(hObject, eventdata, handles)

acquireEnergyReset(hObject,handles);


% --- Executes on button press in simulInit_btn.
function simulInit_btn_Callback(hObject, eventdata, handles)

gui_statusDisp(handles,'Simulation initialization ...');
bba_simulInit(handles.simul);
if ~handles.appMode
    handles.process.saved=1;
    guidata(hObject,handles);
end
gui_statusDisp(handles,'Simulation initialization done.');


function acquireSampleNum_txt_Callback(hObject, eventdata, handles)

acquireSampleNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


% --- Executes on slider movement.
function dataSample_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentSampleControl(hObject,handles,round(get(hObject,'Value')),[]);
plotOrbit(hObject,handles);


% --- Executes on button press in dataAverage_box.
function dataAverage_box_Callback(hObject, eventdata, handles)

dataAverageControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in dataShowAll_box.
function dataShowAll_box_Callback(hObject, eventdata, handles)

dataShowAllControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in dataShowError_box.
function dataShowError_box_Callback(hObject, eventdata, handles)

dataShowErrorControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in appMode_btn.
function appMode_btn_Callback(hObject, eventdata, handles)

appModeControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fitCorr_box.
function fitCorr_box_Callback(hObject, eventdata, handles)

fitCorrControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fitGirderMove_box.
function fitGirderMove_box_Callback(hObject, eventdata, handles)

fitGirderMoveControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in applyLaunch_btn.
function applyLaunch_btn_Callback(hObject, eventdata, handles)

% Real positions of beam
global xInit

%if ~handles.data.status(handles.dataDevice.iVal), return, end
if ~isfield(handles,'fitResult') && ~handles.appMode, return, end
gui_statusDisp(handles,'Apply launch ...');

if isfield(handles,'fitResult')
    try
    xInitF=reshape(handles.fitResult.xInit,4,[],handles.dataDevice.nVal);
    if ~handles.dataAverage
        xInitF=mean(xInitF,2);
    end
    xInitF=xInitF(:,:,handles.dataDevice.iVal);
    xInit=xInit-xInitF;
    handles.fitResult.xInit=handles.fitResult.xInit*0;
    guidata(hObject,handles);
    catch
    end
end

if handles.appMode
    handles.dataSample.nVal=10;
    xMeas=bba_bpmDataGet(handles.static,[],1,handles);
    bpms={'RFB07' 'RFBU00' 'RFBU03' 'RFBU07' 'RFBU10'};
    [d,ix]=ismember(bpms,handles.static.bpmList);
    x=mean(xMeas(:,ix,:),3)';

    corrsX={'XCUM1' 'XCUM4'}';
    corrsY={'YCUM2' 'YCUM3'}';
%    r1=model_rMatGet([corrsX;corrsY],'RFB07');
%    r2=model_rMatGet([corrsX;corrsY],'RFBU00');
    r=model_rMatGet(repmat([corrsX;corrsY],2,1),repmat(bpms,4,1));
    r=reshape(r,6,6,4,[]);
%    r1=r(:,:,:,1);r2=r(:,:,:,2);
    Rx=squeeze(r(1,2,1:2,:))';
    Ry=squeeze(r(3,4,3:4,:))';
    R=blkdiag(Rx,Ry);

    [d,en]=control_magnetGet('BYD1');
    bp=en/299.792458*1e4; % kG m
%    cVal=inv(R)*x(:)*bp;
    cVal=lscov(R,x(:)*bp);
    val=control_magnetGet([corrsX;corrsY]);
    control_magnetSet([corrsX;corrsY],val-cVal);
end
gui_statusDisp(handles,'Launch set done.');


% --- Executes on button press in applyBPM_btn.
function applyBPM_btn_Callback(hObject, eventdata, handles)

f=handles.fitResult;
gui_statusDisp(handles,'Apply BPM offsets ...');
bba_setBPM(handles.static,-f.bpmOff,handles.appMode,handles.simul);
f.bpmOff=deal(0);
handles.fitResult=f;
guidata(hObject,handles);
gui_statusDisp(handles,'Apply BPM offsets done.');


% --- Executes on button press in applyQuads_btn.
function applyQuads_btn_Callback(hObject, eventdata, handles)

f=handles.fitResult;
gui_statusDisp(handles,'Apply quad movement ...');
bykik=lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'double');
lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
bba_girdMove(handles.static,-f.quadOff,handles.appMode,handles.simul);
lcaPut('IOC:BSY0:MP01:BYKIKCTL',bykik);
f.quadOff=deal(0);
handles.fitResult=f;
guidata(hObject,handles);
gui_statusDisp(handles,'Apply quad movement done.');


% --- Executes on button press in applyAll_btn.
function applyAll_btn_Callback(hObject, eventdata, handles)

f=handles.fitResult;
gui_statusDisp(handles,'Apply all offsets ...');
bykik=lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'double');
lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
bba_girdMove(handles.static,-f.quadOff,handles.appMode,handles.simul);
bba_setBPM(handles.static,-f.bpmOff,handles.appMode,handles.simul);
lcaPut('IOC:BSY0:MP01:BYKIKCTL',bykik);
[f.quadOff,f.bpmOff]=deal(0);
handles.fitResult=f;
guidata(hObject,handles);
gui_statusDisp(handles,'Apply all offsets done.');


% --- Executes on button press in applyCorrs_btn.
function applyCorrs_btn_Callback(hObject, eventdata, handles, plane)

if nargin < 4, plane='xy';end

gui_statusDisp(handles,'Apply corrector change ...');
f=handles.fitResult;
%if isfield(f,'quadOff')
if ~any(f.corrOff(:))
    bba_setCorr(handles.static,-f.quadOff,handles.appMode);
    f.quadOff=deal(0);
else
    f.corrOff('xy' ~= plane,:)=0;
    bba_corrSet(handles.static,-f.corrOff*handles.simul.corrGain,handles.appMode);
    f.corrOffF=deal(0);
end
handles.fitResult=f;
guidata(hObject,handles);
gui_statusDisp(handles,'Apply corrector change done.');


% --- Executes on button press in zeroCorrs_btn.
function zeroCorrs_btn_Callback(hObject, eventdata, handles)

gui_statusDisp(handles,'Zero all correctors ...');
bba_corrSet(handles.static,0,handles.appMode,'init',1);
gui_statusDisp(handles,'Zero all correctors done.');


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)

acquireUpdate(hObject,handles);


% --- Executes on selection change in sectorSel_pmu.
function sectorSel_pmu_Callback(hObject, eventdata, handles)

sectorControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

appLoad(hObject,handles);


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);


% --- Executes on button press in stdzMagnets_btn.
function stdzMagnets_btn_Callback(hObject, eventdata, handles)

% Undo undulator pointing.
%{
nBPM=model_nameRegion('BPMS',{'LTU1:900:Inf' 'UND1:0:3390'});
zBPM=model_rMatGet(nBPM,[],[],'Z');
zRef=model_rMatGet({'BFW01' 'QU33'},[],[],'Z');
[offX,offY]=control_deviceGet(nBPM,{'XOFF.D' 'YOFF.D'}); % Offsets in mm
parX=polyfit(zBPM,offX',1);parY=polyfit(zBPM,offY',1);
refX=polyval(parX,zRef)*1e3;refY=polyval(parY,zRef)*1e3; % repoint wants um
repointUndulatorLine(refX(1),refY(1),refX(2),refY(2)); % Offsets are opposite of pointing
%}

% Select BBA mode for LEM.
gui_statusDisp(handles,'LEM: Select BBA mode');
lcaPut('SIOC:SYS0:ML01:AO141',1);pause(1.);

% Insert all undulators.
gui_statusDisp(handles,'Und to zero: Insert undulators');
segmentMoveInOut([1:8 10:32],1);

% Set all undulators to 0.
gui_statusDisp(handles,'Und to zero: Set TMXPOSC to 0');
undPV=model_nameConvert({'USEG'},[],'UND1');undPV([9 33])=[];
lcaPutNoWait(strcat(undPV,':TMXPOSC'),0);pause(1.);

% Wait until all completed.
gui_statusDisp(handles,'Und to zero: Wait for motion competion');
while any(strcmp(lcaGet(strcat(undPV,':LOCATIONSTAT')),'MOVING')), pause(1.);end

% Turn undulator orbit correction off.
gui_statusDisp(handles,'Corr off: Turn und orbit correction off');
lcaPut(strcat(undPV,':BPMXCORSTAT'),0);
lcaPut(strcat(undPV,':BPMYCORSTAT'),0);
lcaPut(strcat(undPV,':XCORCORSTAT'),0);
lcaPut(strcat(undPV,':YCORCORSTAT'),0);pause(1.);

% Get TDUND state and then insert.
gui_statusDisp(handles,'STDZ Magnets: Insert TDUND');
tdStat=lcaGet('DUMP:LTU1:970:TDUND_PNEU');
lcaPut('DUMP:LTU1:970:TDUND_PNEU',0);pause(2.);

% Get EPICS names for undulator quads and correctors.
nameQuad=model_nameConvert({'QUAD'},[],'UND1');
nameXCor=model_nameConvert({'XCOR'},[],'UND1');
nameYCor=model_nameConvert({'YCOR'},[],'UND1');

% Set undulator correctors to zero.
gui_statusDisp(handles,'STDZ Magnets: Set XCOR/YCOR 0');
control_magnetSet([nameXCor;nameYCor],0,'action','TRIM');

% Standardize first quads, then x-corrs, then y-corrs.
gui_statusDisp(handles,'STDZ Magnets: Quads ...');
control_magnetSet(nameQuad,[],'action','STDZ');
gui_statusDisp(handles,'STDZ Magnets: X-Corrs ...');
control_magnetSet(nameXCor,[],'action','STDZ');
gui_statusDisp(handles,'STDZ Magnets: Y-Corrs ...');
control_magnetSet(nameYCor,[],'action','STDZ');

% Turn self-seeding chicane controls off.
gui_statusDisp(handles,'Turn off: H/SXRSS Chicane Control Phase Shift & BTRMs');
lcaPut('SIOC:SYS0:ML01:AO902',0);pause(2.); % Wait for HXRSS gui response.
control_magnetSet({'BXSS1T' 'BXSS2T' 'BXSS3T' 'BXSS4T' 'BXHS1T' 'BXHS2T' 'BXHS3T' 'BXHS4T'},0);

% Degauss self-seeding chicanes.
gui_statusDisp(handles,'DEGAUSS Magnets: S/HXRSS Chicane ...');
control_magnetSet({'BXSS2' 'BXHS2'},[],'action','TURN_ON');pause(2);
control_magnetSet({'BXSS2' 'BXHS2'},[],'action','DEGAUSS');

% Put TDUND back to what it was.
lcaPut('DUMP:LTU1:970:TDUND_PNEU',tdStat);pause(2.);
gui_statusDisp(handles,'STDZ Magnets: Done');


% --- Executes on button press in undOut_btn.
function undOut_btn_Callback(hObject, eventdata, handles)

undInOutControl(hObject,handles,0);


% --- Executes on button press in undIn_btn.
function undIn_btn_Callback(hObject, eventdata, handles)

undInOutControl(hObject,handles,1);


% --- Executes on button press in keepRMat_box.
function keepRMat_box_Callback(hObject, eventdata, handles)

keepRMatControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fitUndI2_box.
function fitUndI2_box_Callback(hObject, eventdata, handles)

fitUndI2Control(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fitUnd_box.
function fitUnd_box_Callback(hObject, eventdata, handles)

fitUndControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fitUndCorr_box.
function fitUndCorr_box_Callback(hObject, eventdata, handles)

fitUndCorrControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fitDiff_box.
function fitDiff_box_Callback(hObject, eventdata, handles)

fitDiffControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in updateMovePV_btn.
function updateMovePV_btn_Callback(hObject, eventdata, handles)

if handles.appTask == 3, writePoly(handles.simul.girderNum,handles.poly);return,end
if handles.appTask == 4, writeKlys(handles.klysName,handles.klysPar);return,end

if ~sum(handles.data.status) == 2 || ~handles.fitGirderMove, return, end

f=handles.fitResult;
iGird=handles.simul.girderNum;
undPV=model_nameConvert(cellstr(num2str(iGird(:),'US%02d')));
%iQuad=max(1,iGird-1):iGird;
%iBPM=find(handles.static.zBPM > handles.static.zQuad(iGird),1);
%if iGird == 1, iBPM=iBPM+[-1 0];end
%iQuad=reshape([iGird-1;iGird],1,[]);iQuad(~iQuad)=[];
iQuad=[iGird-1;iGird];iQuad2=max(iQuad,1);%iQuad(~iQuad)=1;
iBPM=iGird+3;iBPM2=iBPM(iGird == 1)-1;
%iBPM=[iBPM(iGird == 1)-1 iBPM];

[d,undStat,undInst,pvNames]=segmentInOutOffsetApply(iGird,'noApply',1);

%if any(undStat)
%    gui_statusDisp(handles,'Cannot update PVs when undulator retracted!');
%    return
%end
[d,bQuad]=control_magnetGet(handles.static.quadList(iQuad2(:)));
bQuad=[1;-1]*bQuad';
deltaCorr=-bQuad.*f.quadOff(:,iQuad2);
deltaCorr(:,~iQuad)=f.bpmOff(:,iBPM2)*1e3;
%if any(iGird == 1)
%    deltaCorr=[f.bpmOff(:,iBPM(iBPM == iBPM(1)))*1e3 deltaCorr];
%end
deltaCorr=reshape(deltaCorr,4,[]);
%disp(iGird);disp(iQuad);disp(iBPM);return

%bpmOPV=strcat(undPV,':XOUTBPMD',{'X';'Y'});
%cor2PV=strcat(undPV,':XOUT',{'X';'Y'},'COR2');
%cor1PV=strcat(undPV,':XOUT',{'X';'Y'},'COR1');
%lcaPut(bpmOPV,lcaGet(bpmOPV)+f.bpmOff(:,iBPM(end))*1e3);
%lcaPut(cor2PV,lcaGet(cor2PV)+deltaCorr(:,2));
%lcaPut(cor1PV,lcaGet(cor1PV)+deltaCorr(:,1));
%pvBase=strcat(undPV,':XOUT');
%bpmOPV=[strcat(pvBase,'BPMDX');strcat(pvBase,'BPMDY')];
%cor2PV=[strcat(pvBase,'XCOR2');strcat(pvBase,'YCOR2')];
%cor1PV=[strcat(pvBase,'XCOR1');strcat(pvBase,'YCOR1')];
dBPM=reshape(f.bpmOff(:,iBPM)',[],1)*1e3;
dCor2=reshape(deltaCorr(3:4,:)',[],1);
dCor1=reshape(deltaCorr(1:2,:)',[],1);
lcaPut(pvNames.bpmOff,lcaGet(pvNames.bpmOff)+dBPM);
lcaPut(pvNames.cor2Off,lcaGet(pvNames.cor2Off)+dCor2);
lcaPut(pvNames.cor1Off,lcaGet(pvNames.cor1Off)+dCor1);
use2=[undStat & undInst;undStat & undInst];
if any(use2)
    lcaPut(pvNames.bpm(use2),lcaGet(pvNames.bpm(use2))+dBPM(use2));
    lcaPut(pvNames.cor2(use2),lcaGet(pvNames.cor2(use2))+dCor2(use2));
    lcaPut(pvNames.cor1(use2),lcaGet(pvNames.cor1(use2))+dCor1(use2));
end
gui_statusDisp(handles,'PVs updated.');


% --- Executes on button press in zeroMovePV_btn.
function zeroMovePV_btn_Callback(hObject, eventdata, handles)

if handles.appTask == 3, writePoly(handles.simul.girderNum,[]);return,end
if handles.appTask == 4, writeKlys(handles.klysName,0);return,end

iGird=handles.simul.girderNum;
undPV=model_nameConvert(num2str(iGird,'US%02d'));
bpmOPV=strcat(undPV,':XOUTBPMD',{'X';'Y'});
cor2PV=strcat(undPV,':XOUT',{'X';'Y'},'COR2');
cor1PV=strcat(undPV,':XOUT',{'X';'Y'},'COR1');
lcaPut(bpmOPV,0);
lcaPut(cor2PV,0);
lcaPut(cor1PV,0);


% --- Executes on button press in setUndBBA_btn.
function setUndBBA_btn_Callback(hObject, eventdata, handles)

%util_appFind('energyChange_gui');

handles.simul.fitQuadLin=1;
handles.simul.fitCorrAbs=0;
handles.simul.fitSVDRatio=0;
handles.simul.noEPlusCorr=1;

handles.appTask=0;
handles.sectorSel='UND';
handles.acquireSampleNum=360;
handles.acquireDataNum=4;
handles.dataAverage=1;
handles.dataShowAll=1;
handles.acquireDataRange={4.3 13.64};
handles.fitCorr=0;
handles.fitGirderMove=0;
handles.fitDiff=0;
handles.keepRMat=0;
appSetup(hObject,handles);
gui_statusDisp(handles,'GUI ready for Undulator BBA.');
set(handles.output,'Name','Beam Based Undulator Alignment');
set([handles.stdzMagnets_btn handles.correction_pan],'Visible','on');
set([handles.updateMovePV_btn handles.zeroMovePV_btn handles.orbitCorr_pan ...
    handles.undInOut_pan handles.klysKick_pan handles.altFit_pan],'Visible','off');
set([handles.acquireDataNum_txt handles.acquireDataNumLabel_txt],'Visible','on');


% --- Executes on button press in setOrbitCorr_btn.
function setOrbitCorr_btn_Callback(hObject, eventdata, handles)

handles.simul.fitQuadLin=0;
handles.simul.fitCorrAbs=0;
handles.simul.fitSVDRatio=0.01;
handles.simul.noEPlusCorr=1;

handles.appTask=1;
handles.sectorSel='BSY_End LTU0 LTU1';
handles.acquireSampleNum=120;
handles.acquireDataNum=1;
handles.dataAverage=1;
handles.dataShowAll=1;
handles.acquireDataRange={13.64 13.64};
handles.fitCorr=1;
handles.fitGirderMove=0;
handles.fitDiff=0;
handles.keepRMat=1;
appSetup(hObject,handles);
gui_statusDisp(handles,'GUI ready for Orbit correction.');
set(handles.output,'Name','Orbit Correction');
set(handles.orbitCorr_pan,'Visible','on','Position',get(handles.orbitCorr_pan,'Position').*[0 1 1 1]+[46.4 0 0 0]);
set([handles.acquireDataNum_txt handles.acquireDataNumLabel_txt],'Visible','off');
set([handles.stdzMagnets_btn handles.updateMovePV_btn handles.zeroMovePV_btn ...
    handles.correction_pan handles.undInOut_pan handles.klysKick_pan handles.altFit_pan],'Visible','off');


% --- Executes on button press in setUndInOut_btn.
function setUndInOut_btn_Callback(hObject, eventdata, handles)

handles.simul.fitQuadLin=0;
handles.simul.fitCorrAbs=0;
handles.simul.fitSVDRatio=0;
handles.simul.noEPlusCorr=1;

handles.appTask=2;
handles.sectorSel='UND';
handles.acquireSampleNum=50;
handles.acquireDataNum=2;
handles.dataAverage=1;
handles.dataShowAll=1;
handles.acquireDataRange={13.64 13.64};
handles.fitCorr=0;
handles.fitGirderMove=1;
handles.fitDiff=1;
handles.keepRMat=1;

appSetup(hObject,handles);
gui_statusDisp(handles,'GUI ready for Undulator In/Out.');
set(handles.output,'Name','Undulator Segment Motion Measurement');
set([handles.updateMovePV_btn handles.zeroMovePV_btn handles.undInOut_pan],'Visible','on');
set([handles.stdzMagnets_btn handles.correction_pan handles.orbitCorr_pan ...
    handles.klysKick_pan handles.altFit_pan],'Visible','off');
set([handles.acquireDataNum_txt handles.acquireDataNumLabel_txt],'Visible','on');


% --- Executes on button press in setUndFieldInt_btn.
function setUndFieldInt_btn_Callback(hObject, eventdata, handles)

handles.simul.fitQuadLin=0;
handles.simul.fitCorrAbs=0;
handles.simul.fitSVDRatio=0;

handles.appTask=3;
handles.sectorSel='UND';
handles.acquireSampleNum=50;
handles.acquireDataNum=9;
handles.dataAverage=1;
handles.dataShowAll=0;
handles.acquireDataRange={0 80};
handles.fitCorr=0;
handles.fitGirderMove=1;
handles.fitDiff=1;
handles.keepRMat=1;

appSetup(hObject,handles);
gui_statusDisp(handles,'GUI ready for Undulator Field Integral');
set(handles.output,'Name','Undulator Field Integral Measurement');
set([handles.acquireDataNum_txt handles.acquireDataNumLabel_txt],'Visible','on');


% ------------------------------------------------------------------------
function writePoly(iGird, par)

nPoly=6;nReg=2;
par=flipud(reshape(par,[],6*nReg));
par(end+1:nPoly+1,:)=0;
par(nPoly+1+1:end,:)=[];

arr=lcaGet('SIOC:SYS0:ML01:FWF01');
id=(iGird-1)*(nPoly+1)*6*nReg+(1:(nPoly+1)*6*nReg);
arr(id)=arr(id)+par(:)';
if ~any(par(:)), arr(id)=0;end
lcaPut('SIOC:SYS0:ML01:FWF01',arr);


% ------------------------------------------------------------------------
function [qOff2, qOff1, bOff] = getPolyVals(par, x)

[qOff2, qOff1, bOff]=deal(zeros(2,numel(x)));
nReg=2;
par=reshape(par,[],6,nReg);
x=x(:)';
use=x < 40;xu=x(use);
qOff2(:,use)=[polyval(par(:,1,1)',xu);polyval(par(:,2,1)',xu)];
qOff1(:,use)=[polyval(par(:,3,1)',xu);polyval(par(:,4,1)',xu)];
bOff(:,use)=[polyval(par(:,5,1)',xu);polyval(par(:,6,1)',xu)];
use=x >= 40;xu=x(use);
qOff2(:,use)=[polyval(par(:,1,end)',xu);polyval(par(:,2,end)',xu)];
qOff1(:,use)=[polyval(par(:,3,end)',xu);polyval(par(:,4,end)',xu)];
bOff(:,use)=[polyval(par(:,5,end)',xu);polyval(par(:,6,end)',xu)];


% ------------------------------------------------------------------------
function par = fitPolyVals(x, offs)

x=x(:)';
nPol=min(6,numel(x)-1);
nReg=2;
par=zeros(nPol+1,6,nReg);
for j=1:6
    use=x <= 40;xu=x(use);
    par(:,j,1)=polyfit(xu/100,offs(j,use),nPol)./100.^(nPol:-1:0);
    use=x >= 40;xu=x(use);
    par(:,j,2)=polyfit(xu/100,offs(j,use),nPol)./100.^(nPol:-1:0);
end
par=par(:)';


% --- Executes on button press in setKlysKick_btn.
function setKlysKick_btn_Callback(hObject, eventdata, handles)

handles.simul.fitQuadLin=0;
handles.simul.fitCorrAbs=0;
handles.simul.fitSVDRatio=0;
handles.simul.noEPlusCorr=0;

handles.appTask=4;
handles.sectorSel='LI24_End BC2_L3END BSY LTU0 LTU1';
handles.acquireSampleNum=50;
handles.acquireDataNum=13;
handles.dataAverage=1;
handles.dataShowAll=0;
handles.acquireDataRange={-180 150};
handles.fitCorr=0;
handles.fitGirderMove=0;
handles.fitDiff=1;
handles.keepRMat=1;

handles.energy=model_energyMagProfile([],{'L3' 'LTU'},'init',1);

handles=appSetup(hObject,handles);
%set([handles.klysName_txt handles.klysNameLabel_txt handles.doLEM_box],'Visible','on');
gui_statusDisp(handles,'GUI ready for Klystron Kick');
set(handles.output,'Name','Klystron Kick Measurement');
set([handles.acquireEnergySet_btn handles.acquireEnergyReset_btn],'Visible','On');
set([handles.updateMovePV_btn handles.zeroMovePV_btn handles.klysKick_pan],'Visible','on');
set([handles.stdzMagnets_btn handles.correction_pan handles.undInOut_pan ...
    handles.orbitCorr_pan handles.altFit_pan],'Visible','off');
set([handles.acquireDataNum_txt handles.acquireDataNumLabel_txt],'Visible','on');


% ------------------------------------------------------------------------
function handles = klysNameControl(hObject, handles, val)

handles=gui_textControl(hObject,handles,'klysName',val,1,1,'25-1');
handles=klysStatSave(hObject,handles);


function klysName_txt_Callback(hObject, eventdata, handles)

klysNameControl(hObject,handles,get(hObject,'String'));


% ------------------------------------------------------------------------
function handles = doLEMControl(hObject, handles, val)

handles=gui_checkBoxControl(hObject,handles,'doLEM',val);


% --- Executes on button press in doLEM_box.
function doLEM_box_Callback(hObject, eventdata, handles)

doLEMControl(hObject,handles,get(hObject,'Value'));


% ------------------------------------------------------------------------
function writeKlys(name, par, mode)

% Mode 0 is absolute, Mode 1 is incremental.
if nargin < 3, mode=0;end

id=sscanf(name,'%d-%d');
iSect=id(1);
iKlys=id(2);
nPar=6;
id=((iSect-21)*8+iKlys-1)*nPar+(1:nPar);

pv='SIOC:SYS0:ML01:FWF02';
arr=lcaGet(pv);
% Set data to zero if par all zero.
if ~any(par(:)), arr(id)=0;end
arr(id)=arr(id)*mode+par(:)'; % Par [ampX phX offX ampY phY offY]
lcaPut(pv,arr);

[h,handles]=util_appFind('bba_gui');
global klysPar klysParStd
klysPar(:,iKlys,iSect-20)=handles.klysPar;
klysParStd(:,iKlys,iSect-20)=handles.klysParStd;


function sectorSel_txt_Callback(hObject, eventdata, handles)

sectorControl(hObject,handles,regexprep(strtrim(char(get(hObject,'String'))),'\s+',' '));


% ------------------------------------------------------------------------
function handles = devTypeControl(hObject, handles, val)

tList={'Meas' 'Quad' 'BPM' 'Und' 'Corr'};
handles=gui_popupMenuControl(hObject,handles,'devType',val,lower(tList),tList);
tag=handles.devType;list=tag;if strcmp(tag,'meas'),list='bpm';end
devStr=handles.static.([list 'List']);
devVal=handles.simul.(['i' tList{strcmpi(tList,tag)}]);
if isempty(devVal), devVal=1:numel(devStr);end
set(handles.devSel_lbx,'String',devStr,'Value',devVal);
handles.devSel=devVal;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = devSelInit(hObject, handles)

s=handles.simul;
[s.iMeas,s.iQuad,s.iBPM,s.iUnd,s.iCorr]=deal([]);
handles.simul=s;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = devSelControl(hObject, handles, val)

if isempty(val)
    val=handles.devSel;
end
handles.devSel=val;
if numel(val) == numel(get(handles.devSel_lbx,'String')), val=[];end

tList={'Meas' 'Quad' 'BPM' 'Und' 'Corr'};
handles.simul.(['i' tList{strcmpi(tList,handles.devType)}])=val;
guidata(hObject,handles);
handles=acquireUpdate(hObject,handles);


% --- Executes on selection change in devType_pmu.
function devType_pmu_Callback(hObject, eventdata, handles)

devTypeControl(hObject,handles,get(hObject,'Value'));


% --- Executes on selection change in devSel_lbx.
function devSel_lbx_Callback(hObject, eventdata, handles)

devSelControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in expert_btn.
function expert_btn_Callback(hObject, eventdata, handles)

set(findall(handles.output),'Visible','on');


function plotRange_txt_Callback(hObject, eventdata, handles)

acquireUpdate(hObject,handles);


% --- Executes on button press in allPurpose_box.
function allPurpose_box_Callback(hObject, eventdata, handles)

acquireUpdate(hObject,handles);


% --- Executes on button press in acquireRefOrbit_btn.
function acquireRefOrbit_btn_Callback(hObject, eventdata, handles)

handles.simul.fitQuadLin=0;
handles.simul.fitCorrAbs=0;
handles.simul.fitSVDRatio=0.01;
handles.simul.noEPlusCorr=1;

handles.appTask=1;
%handles.sectorSel='BSY_End LTU0 LTU1';
handles.acquireSampleNum=120;
handles.acquireDataNum=2;
handles.dataAverage=1;
handles.dataShowAll=0;
handles.acquireDataRange={13.64 13.64};
handles.fitCorr=1;
handles.fitGirderMove=0;
handles.fitDiff=1;
handles.keepRMat=1;
handles=appSetup(hObject,handles);
handles=dataShowAllControl(hObject,handles,[]);
gui_statusDisp(handles,'GUI ready for Orbit correction.');
set(handles.output,'Name','Orbit Correction');
set(handles.orbitCorr_pan,'Visible','on','Position',get(handles.orbitCorr_pan,'Position').*[0 1 1 1]+[46.4 0 0 0]);
set([handles.acquireDataNum_txt handles.acquireDataNumLabel_txt],'Visible','off');
set([handles.stdzMagnets_btn handles.updateMovePV_btn handles.zeroMovePV_btn ...
    handles.correction_pan handles.undInOut_pan handles.klysKick_pan handles.altFit_pan],'Visible','off');
acquireCurrentGet(hObject,handles,'remote');


% --- Executes on button press in acquireOrbit_btn.
function acquireOrbit_btn_Callback(hObject, eventdata, handles)

handles=dataCurrentDeviceControl(hObject,handles,handles.dataDevice.nVal,[]);
acquireCurrentGet(hObject,handles,'remote');
