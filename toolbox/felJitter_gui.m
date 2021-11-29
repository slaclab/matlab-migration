function varargout = felJitter_gui(varargin)
% FELJITTER_GUI M-file for felJitter_gui.fig
%      FELJITTER_GUI, by itself, creates a new FELJITTER_GUI or raises the existing
%      singleton*.
%
%      H = FELJITTER_GUI returns the handle to a new FELJITTER_GUI or the handle to
%      the existing singleton*.
%
%      FELJITTER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FELJITTER_GUI.M with the given input arguments.
%
%      FELJITTER_GUI('Property','Value',...) creates a new FELJITTER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before felJitter_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to felJitter_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help felJitter_gui

% Last Modified by GUIDE v2.5 12-Apr-2009 14:18:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @felJitter_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @felJitter_gui_OutputFcn, ...
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


% --- Executes just before felJitter_gui is made visible.
function felJitter_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to felJitter_gui (see VARARGIN)

% Choose default command line output for felJitter_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes felJitter_gui wait for user response (see UIRESUME)
% uiwait(handles.felJitter_gui);


% --- Outputs from this function are returned to the command line.
function varargout = felJitter_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close felJitter_gui.
function template_gui_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function appSave(hObject, handles)

config=struct;
for tag=handles.configList
    config.(tag{:})=handles.(tag{:});
end
[d,name]=fileparts(get(handles.output,'FileName'));
util_configSave(name,config);


% ------------------------------------------------------------------------
function handles = appLoad(hObject, handles)

[d,name]=fileparts(get(handles.output,'FileName'));
config=util_configLoad(name);
for tag=handles.configList
    if isfield(config,tag{:})
        handles.(tag{:})=config.(tag{:});
    end
end
guidata(hObject,handles);
handles=appSetup(hObject,handles);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

handles.fileHeader='FELJitter';
handles.acquireSampleNum=10;
handles.showXMax=3;
handles.showNBin=15;
handles.process.saved=0;
handles.configList={};
%handles.sector.configList={};
guidata(hObject,handles);

util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=appSetup(hObject,handles);
%handles=processInit(hObject,handles);
handles=appLoad(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=acquireSampleNumControl(hObject,handles,[]);
handles=showNBinControl(hObject,handles,[]);
handles=showXMaxControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function [handles, cancd] = acquireReset(hObject, handles)

[handles,cancd]=gui_dataRemove(hObject,handles);
if cancd, return, end
%handles=dataCurrentDeviceControl(hObject,handles,1,1:2);
handles.fileName='';
%handles.data.status=zeros(prod(handles.dataDevice.nVal),1);
handles.data.status=0;
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end
[handles,cancd]=acquireReset(hObject,handles);
if cancd, gui_acquireStatusSet(hObject,handles,0);return, end

pv='YAGS:DMP1:500';
%pv='OTRS:IN20:571';
handles.data.dataList=profmon_measure(pv,handles.dataSample.nVal,'bufd',1,'nBG',1,'axes',handles.plotImg_ax);
handles.data.status=1;
handles.data.ts=handles.data.dataList(1).ts;
handles.data.name=handles.data.dataList(1).name;
gui_acquireStatusSet(hObject,handles,0);
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireUpdate(hObject, handles)

guidata(hObject,handles);
data=handles.data;
if ~any(data.status), return, end
fel_jitterStat(data.dataList,1,'nBin',handles.showNBin,'xMax',handles.showXMax,'figure',2);
return

if ~any(data.status), acquirePlot(hObject,handles);return, end

if ~isfield(handles.data,'use'), handles.data.use=ones(prod(handles.dataDevice.nVal),handles.dataSample.nVal);end
if handles.process.displayExport
    handles.exportFig=figure;
end
guidata(hObject,handles);
acquirePlot(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

%handles.process.displayExport=1;
%handles=processUpdate(hObject,handles);
%handles.process.displayExport=0;
handles.exportFig=2;
guidata(hObject,handles);
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
if val
    data=handles.data;
%    util_appPrintLog(handles.exportFig,handles.fileHeader,data.name,data.ts);
    util_printLog(handles.exportFig);
    dataSave(hObject,handles,0);
end


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

data=handles.data;
if ~all(data.status), return, end
fileName=util_dataSave(data,handles.fileHeader,data.name,data.ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
set(handles.output,'Name',[handles.fileHeader '- [' handles.fileName ']']);
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles)

[data,fileName,pathName]=util_dataLoad('Open data');
if ~ischar(fileName), return, end
handles.fileName=fileName;

% Put data in storage.
handles.data=data;

handles.process.saved=1;

%handles=processUpdate(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)

dataExport(hObject,handles,1);


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles)

dataExport(hObject,handles,0);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

dataSave(hObject,handles,0);


% --- Executes on button press in dataSaveAs_btn.
function dataSaveAs_btn_Callback(hObject, eventdata, handles)

dataSave(hObject,handles,1);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

appLoad(hObject,handles);


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

appSave(hObject,handles);



function acquireSampleNum_txt_Callback(hObject, eventdata, handles)

acquireSampleNumControl(hObject,handles,str2double(get(hObject,'String')));


% ------------------------------------------------------------------------
function handles = showXMaxControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'showXMax',val,1,1,[1 1]);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = showNBinControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'showNBin',val,1,1,[0 1]);
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireSampleNumControl(hObject, handles, val)

[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
handles=gui_editControl(hObject,handles,'acquireSampleNum',val,1,1,[0 2]);
if cancd, return, end
handles=dataCurrentSampleControl(hObject,handles,1,handles.acquireSampleNum);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSampleControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSample',iVal,nVal);


% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)

acquireUpdate(hObject,handles);


function showXMax_txt_Callback(hObject, eventdata, handles)

showXMaxControl(hObject,handles,str2double(get(hObject,'String')));


function showNBin_txt_Callback(hObject, eventdata, handles)

showNBinControl(hObject,handles,str2double(get(hObject,'String')));
