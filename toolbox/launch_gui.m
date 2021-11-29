function varargout = launch_gui(varargin)
% LAUNCH_GUI M-file for launch_gui.fig
%      LAUNCH_GUI, by itself, creates a new LAUNCH_GUI or raises the existing
%      singleton*.
%
%      H = LAUNCH_GUI returns the handle to a new LAUNCH_GUI or the handle to
%      the existing singleton*.
%
%      LAUNCH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAUNCH_GUI.M with the given input arguments.
%
%      LAUNCH_GUI('Property','Value',...) creates a new LAUNCH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before launch_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to launch_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help launch_gui

% Last Modified by GUIDE v2.5 10-Sep-2010 14:21:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @launch_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @launch_gui_OutputFcn, ...
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


% --- Executes just before launch_gui is made visible.
function launch_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to launch_gui (see VARARGIN)

% Choose default command line output for launch_gui
handles.output = hObject;

handles.phaseList={'Schottky' 'L0a' 'L0b' 'L1S' 'L1X' 'L2' 'L3' 'SBST' 'Klys'};
handles.emitList={'OTR2' 'OTR2' 'WS02' 'WS02' 'WS12' 'WS12' 'WS28144' 'WS32'; ...
                  'scan' 'multi' 'scan' 'multi' 'scan' 'multi' 'multi' 'multi'};
handles.miscList={'XCOR'};
handles.undList={'Und' 'KlysKick'};

handles.noChanges=1;
set(handles.numSBST_txt,'String','21:30');
set(handles.numUnd_txt,'String','1:33');
handles.numSBST=str2num(get(handles.numSBST_txt,'String'));
handles.numUnd=str2num(get(handles.numUnd_txt,'String'));
handles=selectAll(hObject,handles,'phase',1);
handles=selectAll(hObject,handles,'emit',1);
handles=selectAll(hObject,handles,'misc',0);
handles=selectAll(hObject,handles,'und',0);

handles.timer=timer('TasksToExecute',Inf,'TimerFcn',{@timerFcn hObject}, ...
    'StartDelay',0,'ExecutionMode','fixedRate');
handles.timerStep=10; % Seconds
handles.timerDelay=1; % Minutes
set(handles.timer,'Period',handles.timerStep);
handles=timerPeriodControl(hObject,handles,60); % Minutes
handles=timeLeftControl(hObject,handles,handles.timerDelay);
gui_statusDisp(handles,'Ready');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes launch_gui wait for user response (see UIRESUME)
% uiwait(handles.launch_gui);


% --- Outputs from this function are returned to the command line.
function varargout = launch_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close launch_gui.
function launch_gui_CloseRequestFcn(hObject, eventdata, handles)

delete(handles.timer);
util_appClose(hObject);


% --------------------------------------------------------------------
function handles = selectAll(hObject, handles, name, val)

for tag=handles.([name 'List'])
    handles=acquireUseControl(hObject,handles,[tag{:}],val);
end


% --------------------------------------------------------------------
function handles = acquireUseControl(hObject, handles, tag, val)

if isempty(val)
    val=handles.(['use' tag]);
end
handles.(['use' tag])=val;

set(handles.(['use' tag '_box']),'Value',val);
guidata(hObject,handles);


% --------------------------------------------------------------------
function emitScan(handles, name, type)

gui_statusDisp(handles,['Emittance scan ' name ' in progress ...']);
[hObject,h]=util_appFind('emittance_gui');
method=2;if strncmp(name,'OTR',3), method=6;end

emittance_gui('dataMethodControl',hObject,h,method,[]);
for plane='xy'
    emittance_gui('appRemote',0,name,type,plane);
    emittance_gui('dataExport_btn_Callback',hObject,[],guidata(hObject),1);
    if strcmp(name,'OTR2'), break, end
end
gui_statusDisp(handles,['Emittance scan ' name ' done']);


% --------------------------------------------------------------------
function phaseScan(handles, name)

gui_statusDisp(handles,['Phase scan ' name ' in progress ...']);
[hObject,h]=util_appFind('Phase_Scans');
h.nochanges=handles.noChanges;guidata(hObject,h);
callback=[upper(name) '_Callback'];
if strcmp(name,'L1X'), callback='LX_Callback';end
if ismember(name,{'SBST' 'Klys'}), callback='SCAN_Callback';end

if ismember(name,{'SBST' 'Klys'})
    gui_acquireStatusSet(hObject,handles,1);
    iKlys=1;if strcmp(name,'Klys'), iKlys=2:9;end
    iSBST=handles.numSBST-20;if strcmp(name,'SBST'), iSBST(iSBST == 4)=[];end
    for j=iSBST
        set(h.SECTOR,'Value',j);
        Phase_Scans('SECTOR_Callback',h.SECTOR,[],guidata(hObject));
        for k=iKlys
            set(h.KLYS,'Value',k);
            Phase_Scans('KLYS_Callback',h.KLYS,[],guidata(hObject));
            gui_statusDisp(handles,['Phase scan ' sprintf('%s %d-%d',name,j+20,k-1) ' in progress ...']);
            iok=Phase_Scans(callback,hObject,[],guidata(hObject),1);
            if iok, Phase_Scans('printLog_btn_Callback',hObject,[],guidata(hObject));end
            if ~gui_acquireStatusGet(hObject,handles), break, end
        end
        if ~gui_acquireStatusGet(hObject,handles), break, end
    end
else
    Phase_Scans(callback,hObject,[],h,1);
    Phase_Scans('printLog_btn_Callback',hObject,[],guidata(hObject));
end
gui_statusDisp(handles,['Phase scan ' name ' done']);


% --------------------------------------------------------------------
function xcorScan(handles)

name='';
gui_statusDisp(handles,['X-correlator scan ' name ' in progress ...']);
hObject=util_appFind('xcor_scan');
xcor_scan('appRemote',0);
xcor_scan('dataExport',hObject,guidata(hObject),1);
dataExport(hObject,handles,val);
gui_statusDisp(handles,['X-correlator scan ' name ' done']);


% --------------------------------------------------------------------
function undScan(handles)

name='';
gui_statusDisp(handles,['Undulator scan ' name ' in progress ...']);
[hObject,h]=util_appFind('bba_gui');
h.process.saved=1;
bba_gui('setUndInOut_btn_Callback',hObject,[],h);

gui_acquireStatusSet(hObject,handles,1);
iUnd=handles.numUnd;
for j=iUnd
    set(h.girderNum_txt,'String',num2str(j));
    bba_gui('girderNum_txt_Callback',h.girderNum_txt,[],guidata(hObject));
    gui_statusDisp(handles,['Undulator scan ' sprintf('%s %d',name,j) ' in progress ...']);
    set(h.acquireStart_btn,'Value',1);
    h=guidata(hObject);h.process.saved=1;guidata(hObject,h);
    bba_gui('acquireStart_btn_Callback',h.acquireStart_btn,[],guidata(hObject));
    bba_gui('dataExport_btn_Callback',hObject,[],guidata(hObject),1);
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
gui_statusDisp(handles,['Undulator scan ' name ' done']);
gui_acquireStatusSet(hObject,handles,0);


% --------------------------------------------------------------------
function klysKickScan(handles)

name='';
gui_statusDisp(handles,['Klys Kick scan ' name ' in progress ...']);
[hObject,h]=util_appFind('bba_gui');
h.process.saved=1;
bba_gui('setKlysKick_btn_Callback',hObject,[],h);

gui_acquireStatusSet(hObject,handles,1);
iSBST=handles.numSBST;
for j=iSBST
    iKlys=1:8;
    if j == 21, iKlys=3:8;end
    if j == 24, iKlys=1:6;end
    for k=iKlys
        klysName=sprintf('%d-%d',j,k);
        set(h.klysName_txt,'String',klysName);
        bba_gui('klysName_txt_Callback',h.klysName_txt,[],guidata(hObject));
        gui_statusDisp(handles,['Klys Kick scan ' klysName ' in progress ...']);
        set(h.acquireStart_btn,'Value',1);
        h=guidata(hObject);h.process.saved=1;guidata(hObject,h);
        bba_gui('acquireStart_btn_Callback',h.acquireStart_btn,[],guidata(hObject));
        bba_gui('dataExport_btn_Callback',hObject,[],guidata(hObject),1);
        if ~gui_acquireStatusGet(hObject,handles), break, end
    end
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
gui_statusDisp(handles,['Klys Kick scan ' name ' done']);
gui_acquireStatusSet(hObject,handles,0);


% --------------------------------------------------------------------
function timerFcn(obj, event, hObject)

% Get current handles structure for timer function.
handles=guidata(hObject);
handles=timeLeftControl(hObject,handles,handles.timeLeft-handles.timerStep/60);
if handles.timeLeft <= 0
    handles=timeLeftControl(hObject,handles,handles.timerPeriod);
    acquireStart(hObject,handles);
end


% --------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end

for tag=handles.phaseList
    handles=guidata(hObject);
    if handles.(['use' tag{:}])
        try
            phaseScan(handles,tag{:});
        catch
            gui_statusDisp(handles,['Phase scan ' tag{:} ' failed']);
        end
    end
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
for tag=handles.emitList
    handles=guidata(hObject);
    if handles.(['use' tag{:}])
        try
            emitScan(handles,tag{:});
        catch
            gui_statusDisp(handles,['Emittance scan ' tag{:} ' failed']);
        end
    end
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
for tag=handles.miscList
    handles=guidata(hObject);
    if handles.(['use' tag{:}])
        try
            xcorScan(handles);
        catch
            gui_statusDisp(handles,['X-correlator scan ' ' failed']);
        end
    end
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
gui_acquireStatusSet(hObject,handles,0);


% --------------------------------------------------------------------
function handles = timerPeriodControl(hObject, handles, val)

if isempty(val) || isnan(val)
    val=handles.timerPeriod;
end
handles.timerPeriod=max(1,round(val));
set(handles.timerPeriod_txt,'String',num2str(handles.timerPeriod));
guidata(hObject,handles);


% --------------------------------------------------------------------
function handles = timeLeftControl(hObject, handles, val)

if isempty(val) || isnan(val)
    val=handles.timeLeft;
end
handles.timeLeft=val;
timeStr=sprintf('%d:%02d',fix(handles.timeLeft),round(rem(handles.timeLeft,1)*60));
cols={'default' 'yellow'};
set(handles.timeLeft_txt,'String',timeStr,'BackgroundColor',cols{(val < 1)+1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function handles = timerStatusControl(hObject, handles, val)

set(handles.timerStatus_btn,'Value',val);
if val
    set(handles.timerStatus_btn,'BackgroundColor','red','String','Timer Active');
    handles=timeLeftControl(hObject,handles,handles.timerDelay);
    start(handles.timer);
else
    stop(handles.timer);
    handles=timeLeftControl(hObject,handles,handles.timerDelay);
    set(handles.timerStatus_btn,'BackgroundColor','green','String','Timer Stopped');
    gui_acquireAbortAll;
end


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in selectAllEmit_btn.
function selectAllEmit_btn_Callback(hObject, eventdata, handles)

selectAll(hObject,handles,'emit',1);


% --- Executes on button press in selectAllPhase_btn.
function selectAllPhase_btn_Callback(hObject, eventdata, handles)

selectAll(hObject,handles,'phase',1);


% --- Executes on button press in deSelectAllEmit_btn.
function deSelectAllEmit_btn_Callback(hObject, eventdata, handles)

selectAll(hObject,handles,'emit',0);


% --- Executes on button press in deSelectAllPhase_btn.
function deSelectAllPhase_btn_Callback(hObject, eventdata, handles)

selectAll(hObject,handles,'phase',0);


function timerPeriod_txt_Callback(hObject, eventdata, handles)

timerPeriodControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in timerStatus_btn.
function timerStatus_btn_Callback(hObject, eventdata, handles)

timerStatusControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;
timerStatusControl(hObject,handles,0);


% --- Executes on button press in useOTR2scan_box.
function useOTR2scan_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'OTR2scan',get(hObject,'Value'));


% --- Executes on button press in acquireOTR2_btn.
function acquireOTR2_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'OTR2','scan');


% --- Executes on button press in useOTR2multi_box.
function useOTR2multi_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'OTR2multi',get(hObject,'Value'));


% --- Executes on button press in acquireOTR2multi_btn.
function acquireOTR2multi_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'OTR2','multi');


% --- Executes on button press in useWS02scan_box.
function useWS02scan_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'WS02scan',get(hObject,'Value'));


% --- Executes on button press in acquireWS02_btn.
function acquireWS02_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'WS02','scan');


% --- Executes on button press in useWS02multi_box.
function useWS02multi_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'WS02multi',get(hObject,'Value'));


% --- Executes on button press in acquireWS02multi_btn.
function acquireWS02multi_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'WS102','multi');


% --- Executes on button press in useWS12scan_box.
function useWS12scan_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'WS12scan',get(hObject,'Value'));


% --- Executes on button press in acquireWS12_btn.
function acquireWS12_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'WS12','scan');


% --- Executes on button press in useWS12multi_box.
function useWS12multi_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'WS12multi',get(hObject,'Value'));


% --- Executes on button press in acquireWS12multi_btn.
function acquireWS12multi_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'WS12','multi');


% --- Executes on button press in useWS28144multi_box.
function useWS28144multi_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'WS28144multi',get(hObject,'Value'));


% --- Executes on button press in acquireWS28144_btn.
function acquireWS28144_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'WS28144','multi');


% --- Executes on button press in useWS32multi_box.
function useWS32multi_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'WS32multi',get(hObject,'Value'));


% --- Executes on button press in acquireWS32_btn.
function acquireWS32_btn_Callback(hObject, eventdata, handles)

emitScan(handles,'WS32','multi');


% --- Executes on button press in useSchottky_box.
function useSchottky_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'Schottky',get(hObject,'Value'));


% --- Executes on button press in acquireSchottky_btn.
function acquireSchottky_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'Schottky');


% --- Executes on button press in useL0a_box.
function useL0a_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'L0a',get(hObject,'Value'));


% --- Executes on button press in acquireL0a_btn.
function acquireL0a_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'L0a');


% --- Executes on button press in useL0b_box.
function useL0b_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'L0b',get(hObject,'Value'));


% --- Executes on button press in acquireL0b_btn.
function acquireL0b_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'L0b');


% --- Executes on button press in useL1S_box.
function useL1S_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'L1S',get(hObject,'Value'));


% --- Executes on button press in acquireL1S_btn.
function acquireL1S_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'L1S');


% --- Executes on button press in useL1X_box.
function useL1X_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'L1X',get(hObject,'Value'));


% --- Executes on button press in acquireL1X_btn.
function acquireL1X_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'L1X');


% --- Executes on button press in useL2_box.
function useL2_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'L2',get(hObject,'Value'));


% --- Executes on button press in acquireL2_btn.
function acquireL2_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'L2');


% --- Executes on button press in useL3_box.
function useL3_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'L3',get(hObject,'Value'));


% --- Executes on button press in acquireL3_btn.
function acquireL3_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'L3');


% --- Executes on button press in useSBST_box.
function useSBST_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'SBST',get(hObject,'Value'));


% --- Executes on button press in acquireSBST_btn.
function acquireSBST_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'SBST');
gui_acquireStatusSet(hObject,handles,0);


% --- Executes on button press in useSBST_box.
function useKlys_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'Klys',get(hObject,'Value'));


% --- Executes on button press in acquireSBST_btn.
function acquireKlys_btn_Callback(hObject, eventdata, handles)

phaseScan(handles,'Klys');
gui_acquireStatusSet(hObject,handles,0);


% --- Executes on button press in useXCOR_box.
function useXCOR_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'XCOR',get(hObject,'Value'));


% --- Executes on button press in acquireXCOR_btn.
function acquireXCOR_btn_Callback(hObject, eventdata, handles)

xcorScan(handles);


function timeLeft_txt_Callback(hObject, eventdata, handles)



function numSBST_txt_Callback(hObject, eventdata, handles)

num=str2num(get(hObject,'String'));
handles.numSBST=num;
guidata(hObject,handles);


% --- Executes on button press in noChanges_box.
function noChanges_box_Callback(hObject, eventdata, handles)

handles.noChanges=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in useUnd_box.
function useUnd_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'Und',get(hObject,'Value'));


% --- Executes on button press in acquireUnd_btn.
function acquireUnd_btn_Callback(hObject, eventdata, handles)

undScan(handles);


function numUnd_txt_Callback(hObject, eventdata, handles)

num=str2num(get(hObject,'String'));
handles.numUnd=num;
guidata(hObject,handles);


% --- Executes on button press in useKlysKick_box.
function useKlysKick_box_Callback(hObject, eventdata, handles)

acquireUseControl(hObject,handles,'KlysKick',get(hObject,'Value'));


% --- Executes on button press in acquireKlysKick_btn.
function acquireKlysKick_btn_Callback(hObject, eventdata, handles)

klysKickScan(handles);
