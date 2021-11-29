% LCLS Bunch Length Measurement GUI entry point
% Mike Zelazny - zelazny@stanford.edu
function varargout = BunchLengthGUI(varargin)
% BUNCHLENGTHGUI M-file for BunchLengthGUI.fig
%      BUNCHLENGTHGUI, by itself, creates a new BUNCHLENGTHGUI or raises the existing
%      singleton*.
%
%      H = BUNCHLENGTHGUI returns the handle to a new BUNCHLENGTHGUI or the handle to
%      the existing singleton*.
%
%      BUNCHLENGTHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUNCHLENGTHGUI.M with the given input arguments.
%
%      BUNCHLENGTHGUI('Property','Value',...) creates a new BUNCHLENGTHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BunchLengthGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BunchLengthGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BunchLengthGUI

% Last Modified by GUIDE v2.5 21-Feb-2008 16:19:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BunchLengthGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BunchLengthGUI_OutputFcn, ...
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


% --- Executes just before BunchLengthGUI is made visible.
function BunchLengthGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BunchLengthGUI (see VARARGIN)

% Choose default command line output for BunchLengthGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BunchLengthGUI wait for user response (see UIRESUME)
% uiwait(handles.BunchLengthGUI);

% setup for TCAV0
BunchLengthTCAV0;

% issue startup message
BunchLengthLogMsg ('Bunch Length Measurement GUI started.');

colormap(jet(256)); % as per Henrik Loos

global gBunchLengthGUI;
gBunchLengthGUI.debug = 0;
gBunchLengthGUI.CalibrationInProgress = 0;
gBunchLengthGUI.MeasurementInProgress = 0;

global gBunchLength;
gBunchLength.gui = 1;
gBunchLength.gui_pause_time = 0.05;

% set available screens
set(handles.selScreen,'String',gBunchLength.screen.a);

% set available calibration bpms
set(handles.selBPM,'String',gBunchLength.bpm.a);


algs = get (handles.selScreenCalConstAlg,'String');
for each_alg = 1:size(algs,1)   
    if strcmp (algs(each_alg), gBunchLength.screen.blen_phase.alg{1})
        set (handles.selScreenCalConstAlg,'Value',each_alg);
        break;
    end
end

% save handles
gBunchLengthGUI.handles = handles;

% setup GUI timer
gBunchLengthGUI.t = timer;
set (gBunchLengthGUI.t, 'TimerFcn', 'BunchLengthGUIupdate');
set (gBunchLengthGUI.t, 'ExecutionMode', 'fixedSpacing');
set (gBunchLengthGUI.t, 'StartDelay', 1);
set (gBunchLengthGUI.t, 'Period', 1.0); % update GUI at roughly 1 Hz
set (gBunchLengthGUI.t, 'StopFcn', '');

% start GUI timer
start (gBunchLengthGUI.t);

% setup channel access
BunchLengthChannelAccessSetup;

BunchLengthGUIWindowName(handles.BunchLengthGUI,'Measurement');

set(gBunchLengthGUI.handles.MM,'ForegroundColor','Blue');
set(gBunchLengthGUI.handles.SIGT,'ForegroundColor','Blue');

% --- Outputs from this function are returned to the command line.
function varargout = BunchLengthGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in MeasGUI.
function MeasGUI_Callback(hObject, eventdata, handles)
% hObject    handle to MeasGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthGUIsetMeas (handles);

% --- Executes on button press in OptsGUI.
function OptsGUI_Callback(hObject, eventdata, handles)
% hObject    handle to OptsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthGUIsetOpts (handles);

% --- Executes on button press in OptsGUI.
function CalGUI_Callback(hObject, eventdata, handles)
% hObject    handle to OptsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthGUIsetCal (handles);

% --- Executes on button press in BatchGUI.
function BatchGUI_Callback(hObject, eventdata, handles)
% hObject    handle to BatchGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthGUIsetBatch (handles);


% --- Executes on button press in Measure.
function Measure_Callback(hObject, eventdata, handles)
% hObject    handle to Measure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;
BunchLengthGUIWindowName(handles.BunchLengthGUI,'Measurement');
gBunchLengthGUI.MeasurementInProgress = 1;
BunchLengthMeasure(1,1,1);
gBunchLengthGUI.MeasurementInProgress = 0;
gBunchLength.cancel = 0;

% --- Executes on button press in mCancel.
function mCancel_Callback(hObject, eventdata, handles)
% hObject    handle to mCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

if gBunchLengthGUI.MeasurementInProgress
    gBunchLength.cancel = 1;
end

% --- Executes on button press in mImageAnalysis.
function mImageAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to mImageAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;
global gIMG_MAN_DATA;

if isfield (gBunchLength, 'meas')
    if isfield (gBunchLength.meas, 'gIMG_MAN_DATA')
        gIMG_MAN_DATA = gBunchLength.meas.gIMG_MAN_DATA;
        imgBrowserData.ipParam.subtractBg.acquired = 1; 
        imgBrowserData.ipParam.beamSizeUnits = 'um';
        if isempty(gIMG_MAN_DATA.dataset{1})
            gIMG_MAN_DATA.dataset{1} = gIMG_MAN_DATA.dataset{2};
            gIMG_MAN_DATA.dataset{2} = [];
        end
        if isempty (gIMG_MAN_DATA.dataset{2})
            gIMG_MAN_DATA.dataset{2} = gIMG_MAN_DATA.dataset{3};
            gIMG_MAN_DATA.dataset{3} = [];
        end
        imgBrowserData.validDsIndex = 1;
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        imgBrowserData.ipOutput = gIMG_MAN_DATA.dataset{dsIndex}.ipOutput;
        gBunchLengthGUI.imgBrowser_handle = imgBrowser_main(imgBrowserData);
        set (gBunchLengthGUI.imgBrowser_handle,'Name', sprintf(...
            '%s %s Bunch Length Measurement', ...
            char(gBunchLength.mode{1}), gBunchLength.tcav.name));
        gBunchLength.lastLoadedImageData = 2;
    end
end

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;

if strcmp(gBunchLength.windowName,'Measurement')
    BunchLengthSaveMeas_pvs;
end

if strcmp(gBunchLength.windowName,'Calibration')
    BunchLengthSaveCal_pvs;
end

if strcmp(gBunchLength.windowName,'Options')
    BunchLengthSaveOpts_pvs;
end

BunchLengthGUIWindowName(handles.BunchLengthGUI,gBunchLength.windowName);


% --- Executes on button press in Restore.
function Restore_Callback(hObject, eventdata, handles)
% hObject    handle to Restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% FWIW, unlike Save, the Restore doesn't get called in any kind of batch mode 
% that I can think of. 

BunchLengthGUIRestore;
BunchLengthGUIWindowName(handles.BunchLengthGUI,'Measurement');

% --- Executes when user attempts to close BunchLengthGUI.
function BunchLengthGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to BunchLengthGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;
global gBunchLengthCA;
    
% stop GUI timer
stop (gBunchLengthGUI.t);

% stop Channel Access timer
stop (gBunchLengthCA.t);

% do we need to save?
% if gBunchLength.saveNeeded
%     saveDialog = questdlg('You save unsaved data. Save now?',...
%         sprintf('%s Bunch Length Measurement',gBunchLength.tcav.name),...
%         'Yes','No','Yes');
%     if isequal(saveDialog,'Yes')
%         BunchLengthGUISave;
%     end
% end


if usejava('desktop')
else
    % disconnet from Channel Access
    lcaClear();

    % cd back to where we came from
    cd ('..');
end

% issue completion message
BunchLengthLogMsg ('Bunch Length Measurement GUI exited.');

% Hint: delete(hObject) closes the figure
delete(hObject);

% exit from Matlab when running production
if strcmp('/usr/local/lcls/tools/matlab/src/BunchLengthGUI.m', which('BunchLengthGUI'))    
    exit
end


% --- Executes on button press in ScreenIn.
function ScreenIn_Callback(hObject, eventdata, handles)
% hObject    handle to ScreenIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthScreenControl ('IN');


% --- Executes on button press in ScreenOut.
function ScreenOut_Callback(hObject, eventdata, handles)
% hObject    handle to ScreenOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthScreenControl ('OUT');


% --- Executes on selection change in selScreen.
function selScreen_Callback(hObject, eventdata, handles)
% hObject    handle to selScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selScreen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selScreen

global gBunchLength;
global gBunchLengthGUI;

if isfield (gBunchLength, 'cal')
    gBunchLength.cal = [];
    set (gBunchLengthGUI.handles.CALIMGALGSEL,'Visible','off');
end

if isfield (gBunchLength, 'meas')
    gBunchLength.meas = [];
    set (gBunchLengthGUI.handles.MEASIMGALGSEL,'Visible','off');
    set (gBunchLengthGUI.handles.SaveToFile,'Visible','off');
    set (gBunchLengthGUI.handles.SmallSaveToFile,'Visible','off');
    set (gBunchLengthGUI.handles.EXPORT,'Visible','off');
end

gBunchLength.fileName = 'Untitled.mat';

gBunchLength.screen.i = get(handles.selScreen, 'Value');
gBunchLength.screen.desc = gBunchLength.screen.a{gBunchLength.screen.i};
if isfield(gBunchLength.screen.pv,'a')
    gBunchLength.screen.pv.name = {gBunchLength.screen.pv.a{gBunchLength.screen.i}};
    if strcmp('NONE',gBunchLength.screen.pv.name{1})
        gBunchLength.screen.movable = 0;
    else
        gBunchLength.screen.movable = 1;
    end      
end
gBunchLength.screen.pv.force = {1};
if isfield(gBunchLength.screen.rb_pv,'a')
    gBunchLength.screen.rb_pv.name = {gBunchLength.screen.rb_pv.a{gBunchLength.screen.i}};
end
gBunchLength.screen.rb_pv.force = {1};

try
    gBunchLength.screen.blen_phase_pv.name = {gBunchLength.screen.blen_phase_pv.a{gBunchLength.screen.i}};
    gBunchLength.screen.blen_phase.value{1} = lcaGet(gBunchLength.screen.blen_phase_pv.name);
catch
end

try
    gBunchLength.screen.blen_phase.std_pv.name = {gBunchLength.screen.blen_phase.std_pv.a{gBunchLength.screen.i}};
    gBunchLength.screen.blen_phase.std{1} = lcaGet(gBunchLength.screen.blen_phase.std_pv.name);
catch
end

try
    gBunchLength.screen.blen_phase.alg_pv.name = {gBunchLength.screen.blen_phase.alg_pv.a{gBunchLength.screen.i}};
    gBunchLength.screen.blen_phase.alg{1} = lcaGet(gBunchLength.screen.blen_phase.alg_pv.name);
    algs = get (gBunchLengthGUI.handles.selScreenCalConstAlg,'String');
    set (gBunchLengthGUIhandles.selScreenCalConstAlg,'Value',2); % defaults to lscov
    for each_alg = 1:size(algs,1)
        if strcmp (algs(each_alg), gBunchLength.screen.blen_phase.alg{1})
            set (gBunchLengthGUIhandles.selScreenCalConstAlg,'Value',each_alg);
            break;
        end
    end
    gBunchLength.screen.blen_phase.alg{1} = algs(get(gBunchLengthGUIhandles.selScreenCalConstAlg,'Value'));
catch
end

try
    gBunchLength.screen.blen_phase.timestamp_pv.name = {gBunchLength.screen.blen_phase.timestamp_pv.a{gBunchLength.screen.i}};
    gBunchLength.screen.blen_phase.timestamp{1} = lcaGet(gBunchLength.screen.blen_phase.timestamp_pv.name);
catch
end

try
    gBunchLength.screen.blen_phase.tcav_power_pv.name = {gBunchLength.screen.blen_phase.tcav_power_pv.a{gBunchLength.screen.i}};
    gBunchLength.screen.blen_phase.tcav_power{1} = lcaGet(gBunchLength.screen.blen_phase.tcav_power_pv.name);
catch
end

gBunchLength.screen.blen_phase.desc_pv.name = {gBunchLength.screen.blen_phase.desc_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.desc_pv.force = {1};
gBunchLength.screen.blen_phase.egu_pv.name = {gBunchLength.screen.blen_phase.egu_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.blen_phase.egu_pv.force = {1};

gBunchLength.screen.image.resolution_pv.name = {gBunchLength.screen.image.resolution_pv.a{gBunchLength.screen.i}};
gBunchLength.screen.image.resolution_pv.force = {1};

BunchLengthGUIsetCalBtnNames;


% --- Executes on button press in Measure1. Measure at -pi/2
function Measure1_Callback(hObject, eventdata, handles)
% hObject    handle to Measure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

BunchLengthGUIWindowName(handles.BunchLengthGUI,'Measurement');
gBunchLengthGUI.MeasurementInProgress = 1;
BunchLengthMeasure(0,1,0);
gBunchLengthGUI.MeasurementInProgress = 0;
gBunchLength.cancel = 0;


% --- Executes on button press in Measure2. Measure with Klystron
% deactivated
function Measure2_Callback(hObject, eventdata, handles)
% hObject    handle to Measure2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

BunchLengthGUIWindowName(handles.BunchLengthGUI,'Measurement');
gBunchLengthGUI.MeasurementInProgress = 1;
BunchLengthMeasure(1,0,0);
gBunchLengthGUI.MeasurementInProgress = 0;
gBunchLength.cancel = 0;


% --- Executes on button press in Measure3. Measure at +pi/2
function Measure3_Callback(hObject, eventdata, handles)
% hObject    handle to Measure3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

BunchLengthGUIWindowName(handles.BunchLengthGUI,'Measurement');
gBunchLengthGUI.MeasurementInProgress = 1;
BunchLengthMeasure(0,0,1);
gBunchLengthGUI.MeasurementInProgress = 0;
gBunchLength.cancel = 0;

% --- Executes on button press in Calibrate.
function Calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to Calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

gBunchLengthGUI.CalibrationInProgress = 1;
BunchLengthCalibration;
gBunchLengthGUI.CalibrationInProgress = 0;
gBunchLength.cancel = 0;


% --- Executes on button press in cCancel.
function cCancel_Callback(hObject, eventdata, handles)
% hObject    handle to cCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

if gBunchLengthGUI.CalibrationInProgress
   gBunchLength.cancel = 1;
end


% --- Executes on button press in cImageAnalysis.
function cImageAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to cImageAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;
global gIMG_MAN_DATA;

if isfield (gBunchLength, 'cal')
    if isfield (gBunchLength.cal, 'gIMG_MAN_DATA')
        gIMG_MAN_DATA = gBunchLength.cal.gIMG_MAN_DATA;
        imgBrowserData.ipParam.subtractBg.acquired = 1; 
        imgBrowserData.ipParam.beamSizeUnits = 'um';
        imgBrowserData.validDsIndex = 1;
        dsIndex = imgBrowser_valid2actualDsIndex(imgBrowserData.validDsIndex);
        imgBrowserData.ipOutput = gIMG_MAN_DATA.dataset{dsIndex}.ipOutput;
        gBunchLengthGUI.imgBrowser_handle = imgBrowser_main(imgBrowserData);
        set (gBunchLengthGUI.imgBrowser_handle,'Name', sprintf(...
            '%s %s Bunch Length Calibration', ...
            char(gBunchLength.mode{1}), gBunchLength.tcav.name));
        gBunchLength.lastLoadedImageData = 1;
    end
end



% --- Executes during object creation, after setting all properties.
function RateEgu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RateEgu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in selBPM.
function selBPM_Callback(hObject, eventdata, handles)
% hObject    handle to selBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selBPM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selBPM

global gBunchLength;
global gBunchLengthGUI;

if isfield (gBunchLength, 'cal')
    gBunchLength.cal = [];
    set (gBunchLengthGUI.handles.CALIMGALGSEL,'Visible','off');
end

if isfield (gBunchLength, 'meas')
    gBunchLength.meas = [];
    set (gBunchLengthGUI.handles.MEASIMGALGSEL,'Visible','off');
    set (gBunchLengthGUI.handles.SaveToFile,'Visible','off');
    set (gBunchLengthGUI.handles.SmallSaveToFile,'Visible','off');
    set (gBunchLengthGUI.handles.EXPORT,'Visible','off');
end

gBunchLength.fileName = 'Untitled.mat';

gBunchLength.bpm.i = get(handles.selBPM, 'Value');
gBunchLength.bpm.a{gBunchLength.bpm.i};
gBunchLength.bpm.desc = gBunchLength.bpm.a{gBunchLength.bpm.i};
if isfield(gBunchLength.bpm.x.egu_pv,'a')
    gBunchLength.bpm.x.egu_pv.name = {gBunchLength.bpm.x.egu_pv.a{gBunchLength.bpm.i}};
end
gBunchLength.bpm.x.egu_pv.force = {1};
if isfield(gBunchLength.bpm.tmit.egu_pv,'a')
    gBunchLength.bpm.tmit.egu_pv.name = {gBunchLength.bpm.tmit.egu_pv.a{gBunchLength.bpm.i}};
end
gBunchLength.bpm.tmit.egu_pv.force = {1};
gBunchLength.bpm.blen_phase_pv.name = {gBunchLength.bpm.blen_phase_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.desc_pv.name = {gBunchLength.bpm.blen_phase.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.desc_pv.force = {1};
gBunchLength.bpm.blen_phase.egu_pv.name = {gBunchLength.bpm.blen_phase.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.egu_pv.force = {1};
gBunchLength.bpm.blen_phase.timestamp_pv.name = {gBunchLength.bpm.blen_phase.timestamp_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_power_pv.name = {gBunchLength.bpm.blen_phase.tcav_power_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.name = {gBunchLength.bpm.blen_phase.tcav_phase.egu_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.name = {gBunchLength.bpm.blen_phase.tcav_phase.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.apply_pv.name = {gBunchLength.bpm.blen_phase.apply_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.apply.desc_pv.name = {gBunchLength.bpm.blen_phase.apply.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.apply.desc_pv.force = {1};
gBunchLength.bpm.blen_phase.gain_factor_pv.name = {gBunchLength.bpm.blen_phase.gain_factor_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.gain_factor.desc_pv.name = {gBunchLength.bpm.blen_phase.gain_factor.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.gain_factor.desc_pv.force = {1};
if isfield(gBunchLength.bpm.blen_phase.y_ref_pv,'a')
    gBunchLength.bpm.blen_phase.y_ref_pv.name = {gBunchLength.bpm.blen_phase.y_ref_pv.a{gBunchLength.bpm.i}};
end
gBunchLength.bpm.blen_phase.y_ref.desc_pv.name = {gBunchLength.bpm.blen_phase.y_ref.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_ref.desc_pv.force = {1};
if isfield(gBunchLength.bpm.blen_phase.y_ref.egu_pv,'a')
    gBunchLength.bpm.blen_phase.y_ref.egu_pv.name = {gBunchLength.bpm.blen_phase.y_ref.egu_pv.a{gBunchLength.bpm.i}};
end
gBunchLength.bpm.blen_phase.y_ref.egu_pv.force = {1};
if isfield(gBunchLength.bpm.blen_phase.y_tol_pv,'a')
    gBunchLength.bpm.blen_phase.y_tol_pv.name = {gBunchLength.bpm.blen_phase.y_tol_pv.a{gBunchLength.bpm.i}};
end
gBunchLength.bpm.blen_phase.y_tol.desc_pv.name = {gBunchLength.bpm.blen_phase.y_tol.desc_pv.a{gBunchLength.bpm.i}};
gBunchLength.bpm.blen_phase.y_tol.desc_pv.force = {1};
if isfield(gBunchLength.bpm.blen_phase.y_tol.egu_pv,'a')
    gBunchLength.bpm.blen_phase.y_tol.egu_pv.name = {gBunchLength.bpm.blen_phase.y_tol.egu_pv.a{gBunchLength.bpm.i}};
end
gBunchLength.bpm.blen_phase.y_tol.egu_pv.force = {1};

try
    gBunchLength.bpm.blen_phase.value{1} = lcaGet(gBunchLength.bpm.blen_phase_pv.name);
    gBunchLength.bpm.blen_phase.timestamp{1} = lcaGet(gBunchLength.bpm.blen_phase.timestamp_pv.name);
    gBunchLength.bpm.blen_phase.tcav_power{1} = lcaGet(gBunchLength.bpm.blen_phase.tcav_power_pv.name);
    gBunchLength.bpm.blen_phase.tcav_phase.value{1} = lcaGet(gBunchLength.bpm.blen_phase.tcav_phase_pv.name);
    gBunchLength.bpm.blen_phase.apply.value{1} = lcaGet(gBunchLength.bpm.blen_phase.apply_pv.name);
    gBunchLength.bpm.blen_phase.gain_factor.value{1} = lcaGet(gBunchLength.bpm.blen_phase.gain_factor_pv.name);
    gBunchLength.bpm.blen_phase.y_ref.value{1} = lcaGet(gBunchLength.bpm.blen_phase.y_ref_pv.name);
    gBunchLength.bpm.blen_phase.y_tol.value{1} = lcaGet(gBunchLength.bpm.blen_phase.y_tol_pv.name);
catch
end

BunchLengthGUIsetCalBtnNames;



% --- Executes during object creation, after setting all properties.
function selBPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function NBI_Callback(hObject, eventdata, handles)
% hObject    handle to NBI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NBI as text
%        str2double(get(hObject,'String')) returns contents of NBI as a double

global gBunchLength;

try
    test_value = str2num(get(handles.NBI,'String'));
    if isempty(test_value)
        set(handles.NBI,'String',gBunchLength.blen.num_bkg.value{1});
    else
        if test_value < 0
            set(handles.NBI,'String',gBunchLength.blen.num_bkg.value{1});
        else
            if isequal (test_value, round(test_value))
                num_bkg_images = test_value;
                num_images = str2num(get(handles.NI,'String'));
                tot_images = num_bkg_images + num_images;
                max_images = abs(gBunchLength.screen.maxImgs.value{1});
                if (tot_images > max_images)
                    num_bkg_images = max_images - num_images;
                    BunchLengthLogMsg(sprintf('%d background images exceeds max, changing to %d', test_value, num_bkg_images));
                end
                gBunchLength.blen.num_bkg.value{1} = num_bkg_images;
                set(handles.NBI,'String',gBunchLength.blen.num_bkg.value{1});
                BunchLengthGUIWindowName(handles.BunchLengthGUI);
            else
                set(handles.NBI,'String',gBunchLength.blen.num_bkg.value{1});
            end
        end
    end
catch
    set(handles.NBI,'String',gBunchLength.blen.num_bkg.value{1});
end


% --- Executes during object creation, after setting all properties.
function NBI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NBI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NI_Callback(hObject, eventdata, handles)
% hObject    handle to NI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NI as text
%        str2double(get(hObject,'String')) returns contents of NI as a double

global gBunchLength;

try
    test_value = str2num(get(handles.NI,'String'));
    if isempty(test_value)
        set(handles.NI,'String',gBunchLength.blen.num_img.value{1});
    else
        if test_value < 1
            set(handles.NI,'String',gBunchLength.blen.num_img.value{1});
        else
            if isequal (test_value, round(test_value))
                num_images = test_value;
                num_bkg_images = str2num(get(handles.NBI,'String'));
                tot_images = num_bkg_images + num_images;
                max_images = abs(gBunchLength.screen.maxImgs.value{1});
                if (tot_images > max_images)
                    num_images = max_images - num_bkg_images;
                    BunchLengthLogMsg(sprintf('%d images exceeds max, changing to %d', test_value, num_images));
                end
                gBunchLength.blen.num_img.value{1} = num_images;
                set(handles.NI,'String',gBunchLength.blen.num_img.value{1});
                BunchLengthGUIWindowName(handles.BunchLengthGUI);
            else
                set(handles.NI,'String',gBunchLength.blen.num_img.value{1});
            end
        end
    end
catch
    set(handles.NI,'String',gBunchLength.blen.num_img.value{1});
end


% --- Executes during object creation, after setting all properties.
function NI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function STCAVPDES_Callback(hObject, eventdata, handles)
% hObject    handle to STCAVPDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of STCAVPDES as text
%        str2double(get(hObject,'String')) returns contents of STCAVPDES as a double

global gBunchLength;

try
    test_value = str2num(get(handles.STCAVPDES,'String'));
    if isempty(test_value)
        set(handles.STCAVPDES,'String',gBunchLength.tcav.cal.start_phase.value{1});
    else
        if (test_value >= -180)  && (test_value <= 180)
            gBunchLength.tcav.cal.start_phase.value{1} = test_value;
        else
            BunchLengthLogMsg('Sorry, TCAV supporting software requires phase between -180 and 180 degrees');
            set(handles.STCAVPDES,'String',gBunchLength.tcav.cal.start_phase.value{1});
        end
    end
catch
    set(handles.STCAVPDES,'String',gBunchLength.tcav.cal.start_phase.value{1});
end


% --- Executes during object creation, after setting all properties.
function STCAVPDES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STCAVPDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETCAVPDES_Callback(hObject, eventdata, handles)
% hObject    handle to ETCAVPDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETCAVPDES as text
%        str2double(get(hObject,'String')) returns contents of ETCAVPDES as a double

global gBunchLength;

try
    test_value = str2num(get(handles.ETCAVPDES,'String'));
    if isempty(test_value)
        set(handles.ETCAVPDES,'String',gBunchLength.tcav.cal.end_phase.value{1});
    else
        if (test_value >= -180)  && (test_value <= 180)
            gBunchLength.tcav.cal.end_phase.value{1} = test_value;
        else
            BunchLengthLogMsg('Sorry, TCAV supporting software requires phase between -180 and 180 degrees');
            set(handles.ETCAVPDES,'String',gBunchLength.tcav.cal.end_phase.value{1});
        end
    end
catch
    set(handles.ETCAVPDES,'String',gBunchLength.tcav.cal.end_phase.value{1});
end


% --- Executes during object creation, after setting all properties.
function ETCAVPDES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETCAVPDES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TCAVCN_Callback(hObject, eventdata, handles)
% hObject    handle to TCAVCN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TCAVCN as text
%        str2double(get(hObject,'String')) returns contents of TCAVCN as a double

global gBunchLength;

try
    test_value = str2num(get(handles.TCAVCN,'String'));
    if isempty(test_value)
        set(handles.TCAVCN,'String',gBunchLength.tcav.cal.num_phase.value{1});
    else
        if (test_value < 2)
            set(handles.TCAVCN,'String',gBunchLength.tcav.cal.num_phase.value{1});
        else
            if isequal(test_value,round(test_value))

                gBunchLength.tcav.cal.num_phase.value{1} = test_value;
                BunchLengthGUIWindowName(handles.BunchLengthGUI);
            else
                set(handles.TCAVCN,'String',gBunchLength.tcav.cal.num_phase.value{1});
            end
        end
    end
catch
    set(handles.TCAVCN,'String',gBunchLength.tcav.cal.num_phase.value{1});
end


% --- Executes during object creation, after setting all properties.
function TCAVCN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TCAVCN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function screenCalConst_Callback(hObject, eventdata, handles)
% hObject    handle to screenCalConst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of screenCalConst as text
%        str2double(get(hObject,'String')) returns contents of screenCalConst as a double

global gBunchLength;

try
    test_value = str2num(get(handles.screenCalConst,'String'));
    if isempty (test_value)
        set(handles.screenCalConst,'String',gBunchLength.screen.blen_phase.value{1});
    else
        gBunchLength.screen.blen_phase.value{1} = test_value;
        gBunchLength.screen.blen_phase.tcav_power{1} = gBunchLength.tcav.aact.value{1};
        gBunchLength.screen.blen_phase.timestamp{1} = imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.tcav.aact.ts{1}),1);
        BunchLengthGUIWindowName(handles.BunchLengthGUI);
    end
catch
    set(handles.screenCalConst,'String',gBunchLength.screen.blen_phase.value{1});
end


% --- Executes during object creation, after setting all properties.
function screenCalConst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenCalConst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bpmCalConst_Callback(hObject, eventdata, handles)
% hObject    handle to bpmCalConst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bpmCalConst as text
%        str2double(get(hObject,'String')) returns contents of bpmCalConst as a double

global gBunchLength;

try
    test_value = str2num(get(handles.bpmCalConst,'String'));
    if isempty (test_value)
        set(handles.bpmCalConst,'String',gBunchLength.bpm.blen_phase.value{1});
    else
        gBunchLength.bpm.blen_phase.value{1} = test_value;
        gBunchLength.bpm.blen_phase.tcav_power{1} = gBunchLength.tcav.aact.value{1};
        gBunchLength.bpm.blen_phase.timestamp{1} = imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.tcav.aact.ts{1}),1);
        BunchLengthGUIWindowName(handles.BunchLengthGUI);
    end
catch
    set(handles.bpmCalConst,'String',gBunchLength.bpm.blen_phase.value{1});
end

% --- Executes during object creation, after setting all properties.
function bpmCalConst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpmCalConst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function FPHASE_Callback(hObject, eventdata, handles)
% hObject    handle to FPHASE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FPHASE as text
%        str2double(get(hObject,'String')) returns contents of FPHASE as a double

global gBunchLength;

try
    test_value = str2num(get(handles.FPHASE,'String'));
    if isempty (test_value)
        set(handles.FPHASE,'String',gBunchLength.blen.first_phase.value{1});
    else
        if (test_value >= -180)  && (test_value <= 180)
            gBunchLength.blen.first_phase.value{1} = test_value;
        else
            BunchLengthLogMsg('Sorry, TCAV supporting software requires phase between -180 and 180 degrees');
            set(handles.FPHASE,'String',gBunchLength.blen.first_phase.value{1});
        end        
    end
catch
    set(handles.FPHASE,'String',gBunchLength.blen.first_phase.value{1});
end


% --- Executes during object creation, after setting all properties.
function FPHASE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FPHASE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPHASE_Callback(hObject, eventdata, handles)
% hObject    handle to TPHASE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPHASE as text
%        str2double(get(hObject,'String')) returns contents of TPHASE as a double

global gBunchLength;

try
    test_value = str2num(get(handles.TPHASE,'String'));
    if isempty (test_value)
        set(handles.TPHASE,'String',gBunchLength.blen.third_phase.value{1});
    else

        if (test_value >= -180)  && (test_value <= 180)
            gBunchLength.blen.third_phase.value{1} = test_value;
        else
            BunchLengthLogMsg('Sorry, TCAV supporting software requires phase between -180 and 180 degrees');
            set(handles.TPHASE,'String',gBunchLength.blen.third_phase.value{1});
        end
    end
catch
    set(handles.TPHASE,'String',gBunchLength.blen.third_phase.value{1});
end

% --- Executes during object creation, after setting all properties.
function TPHASE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPHASE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TMITTOL_Callback(hObject, eventdata, handles)
% hObject    handle to TMITTOL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TMITTOL as text
%        str2double(get(hObject,'String')) returns contents of TMITTOL as a double

global gBunchLength;

try
    test_value = str2num(get(handles.TMITTOL,'String'));
    if isempty (test_value)
        set(handles.TMITTOL,'String',gBunchLength.blen.tmit_tol.value{1});
    else
        if test_value > 100
            set(handles.TMITTOL,'String',gBunchLength.blen.tmit_tol.value{1});
        else
            if test_value < 0
                set(handles.TMITTOL,'String',gBunchLength.blen.tmit_tol.value{1});
            else
                gBunchLength.blen.tmit_tol.value{1} = test_value;
                BunchLengthGUIWindowName(handles.BunchLengthGUI);
            end
        end
    end
catch
    set(handles.TMITTOL,'String',gBunchLength.blen.tmit_tol.value{1});
end


% --- Executes during object creation, after setting all properties.
function TMITTOL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TMITTOL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in CFOApply.
function CFOApply_Callback(hObject, eventdata, handles)
% hObject    handle to CFOApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CFOApply

global gBunchLength;

if isequal(get(handles.CFOApply,'Value'),1)
    gBunchLength.bpm.blen_phase.apply.value{1} = 'Yes';
else
    gBunchLength.bpm.blen_phase.apply.value{1} = 'No';
end


function bpmG_Callback(hObject, eventdata, handles)
% hObject    handle to bpmG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bpmG as text
%        str2double(get(hObject,'String')) returns contents of bpmG as a double

global gBunchLength;

try
    test_value = str2num(get(handles.bpmG,'String'));
    if isempty (test_value)
        set(handles.bpmG,'String',gBunchLength.bpm.blen_phase.gain_factor.value{1});
    else
        gBunchLength.bpm.blen_phase.gain_factor.value{1} = test_value;
        BunchLengthGUIWindowName(handles.BunchLengthGUI);
    end
catch
    set(handles.bpmG,'String',gBunchLength.bpm.blen_phase.gain_factor.value{1});
end

% --- Executes during object creation, after setting all properties.
function bpmG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpmG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bpmref_Callback(hObject, eventdata, handles)
% hObject    handle to bpmref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bpmref as text
%        str2double(get(hObject,'String')) returns contents of bpmref as a double

global gBunchLength;

try
    test_value = str2num(get(handles.bpmref,'String'));
    if isempty (test_value)
        set(handles.bpmref,'String',gBunchLength.bpm.blen_phase.y_ref.value{1});
    else
        gBunchLength.bpm.blen_phase.y_ref.value{1} = test_value;
        BunchLengthGUIWindowName(handles.BunchLengthGUI);
    end
catch
    set(handles.bpmref,'String',gBunchLength.bpm.blen_phase.y_ref.value{1});
end


% --- Executes during object creation, after setting all properties.
function bpmref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpmref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bpmtol_Callback(hObject, eventdata, handles)
% hObject    handle to bpmtol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bpmtol as text
%        str2double(get(hObject,'String')) returns contents of bpmtol as a double

global gBunchLength;

try
    test_value = str2num(get(handles.bpmtol,'String'));
    if isempty (test_value)
        set(handles.bpmtol,'String',gBunchLength.bpm.blen_phase.y_tol.value{1});
    else
        if test_value < 0
            set(handles.bpmtol,'String',gBunchLength.bpm.blen_phase.y_tol.value{1});
        else
            gBunchLength.bpm.blen_phase.y_tol.value{1} = test_value;
            BunchLengthGUIWindowName(handles.BunchLengthGUI);
        end
    end
catch
    set(handles.bpmtol,'String',gBunchLength.bpm.blen_phase.y_tol.value{1});
end


% --- Executes during object creation, after setting all properties.
function bpmtol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bpmtol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CFOMAXPULSES_Callback(hObject, eventdata, handles)
% hObject    handle to CFOMAXPULSES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CFOMAXPULSES as text
%        str2double(get(hObject,'String')) returns contents of CFOMAXPULSES as a double

global gBunchLength;

try
    test_value = str2num(get(handles.CFOMAXPULSES,'String'));
    if isempty (test_value)
        set(handles.CFOMAXPULSES,'String',gBunchLength.blen.cf_np.value{1});
    else
        if test_value < 1
            set(handles.CFOMAXPULSES,'String',gBunchLength.blen.cf_np.value{1});
        else
            gBunchLength.blen.cf_np.value{1} = test_value;
            BunchLengthGUIWindowName(handles.BunchLengthGUI);
        end
    end
catch
    set(handles.CFOMAXPULSES,'String',gBunchLength.blen.cf_np.value{1});
end

% --- Executes during object creation, after setting all properties.
function CFOMAXPULSES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CFOMAXPULSES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function cplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate cplot

global gBunchLengthGUI;

gBunchLengthGUI.cal.display.num = 10; % Screen YMEAN vs TCAV Phase
gBunchLengthGUI.cal.display.type = 1; % 1=plot, 0=table




% --- Executes on selection change in ctable.
function ctable_Callback(hObject, eventdata, handles)
% hObject    handle to ctable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ctable contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ctable


% --- Executes during object creation, after setting all properties.
function ctable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ctable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in cScreenPlot.
function cScreenPlot_Callback(hObject, eventdata, handles)
% hObject    handle to cScreenPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cScreenPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cScreenPlot

global gBunchLengthGUI;
gBunchLengthGUI.cal.display.type = 1;
gBunchLengthGUI.cal.display.num  =  get (handles.cScreenPlot,'Value') + 8;


% --- Executes during object creation, after setting all properties.
function cScreenPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cScreenPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cBPMPlot.
function cBPMPlot_Callback(hObject, eventdata, handles)
% hObject    handle to cBPMPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cBPMPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cBPMPlot

global gBunchLengthGUI;
gBunchLengthGUI.cal.display.type = 1;
gBunchLengthGUI.cal.display.num = get (handles.cBPMPlot,'Value') + 4;


% --- Executes during object creation, after setting all properties.
function cBPMPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cBPMPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cfBPMPlot.
function cfBPMPlot_Callback(hObject, eventdata, handles)
% hObject    handle to cfBPMPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns cfBPMPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        cfBPMPlot

global gBunchLengthGUI;
gBunchLengthGUI.cal.display.type = 1;
gBunchLengthGUI.cal.display.num = get (handles.cfBPMPlot,'Value');


% --- Executes during object creation, after setting all properties.
function cfBPMPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cfBPMPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cValues.
function cValues_Callback(hObject, eventdata, handles)
% hObject    handle to cValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLengthGUI;
gBunchLengthGUI.cal.display.type = 0;

function TPBZ_Callback(hObject, eventdata, handles)
% hObject    handle to TPBZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPBZ as text
%        str2double(get(hObject,'String')) returns contents of TPBZ as a double

global gBunchLength;

try
    test_value = str2num(get(handles.TPBZ,'String'));
    if isempty (test_value)
        set(handles.TPBZ,'String',gBunchLength.bpm.blen_phase.tcav_phase.value{1});
    else
        if (test_value >= -180)  && (test_value <= 180)
            gBunchLength.bpm.blen_phase.tcav_phase.value{1} = test_value;
        else
            BunchLengthLogMsg('Sorry, TCAV supporting software requires phase between -180 and 180 degrees');
            set(handles.TPBZ,'String',gBunchLength.bpm.blen_phase.tcav_phase.value{1});
        end
    end
catch
    set(handles.TPBZ,'String',gBunchLength.bpm.blen_phase.tcav_phase.value{1});
end


% --- Executes during object creation, after setting all properties.
function TPBZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPBZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TPST_Callback(hObject, eventdata, handles)
% hObject    handle to TPST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TPST as text
%        str2double(get(hObject,'String')) returns contents of TPST as a double

global gBunchLength;

try
    test_value = str2num(get(handles.TPST,'String'));
    if isempty(test_value)
    else
        if (test_value < 0)
        else
            lcaPutNoWait (gBunchLength.tcav.settle_time.pv.name, test_value);
            set(handles.TPST,'String',test_value);
        end
    end
catch
end


% --- Executes during object creation, after setting all properties.
function TPST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TPST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in table.
function table_Callback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns table contents as cell array
%        contents{get(hObject,'Value')} returns selected item from table


% --- Executes during object creation, after setting all properties.
function table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function screenCalConstSTD_Callback(hObject, eventdata, handles)
% hObject    handle to screenCalConstSTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of screenCalConstSTD as text
%        str2double(get(hObject,'String')) returns contents of screenCalConstSTD as a double


global gBunchLength;

try
    test_value = str2num(get(handles.screenCalConstSTD,'String'));
    if isempty (test_value)
        set(handles.screenCalConstSTD,'String',gBunchLength.screen.blen_phase.std{1});
    else
        gBunchLength.screen.blen_phase.std{1} = abs(test_value);
        gBunchLength.screen.blen_phase.tcav_power{1} = gBunchLength.tcav.aact.value{1};
        gBunchLength.screen.blen_phase.timestamp{1} = imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.tcav.aact.ts{1}),1);
        BunchLengthGUIWindowName(handles.BunchLengthGUI);
    end
catch
    set(handles.screenCalConstSTD,'String',gBunchLength.screen.blen_phase.std{1});
end

% --- Executes during object creation, after setting all properties.
function screenCalConstSTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenCalConstSTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MMSTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MMSTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function BunchLengthGUI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BunchLengthGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function screenCalConstSign_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenCalConstSign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set (hObject,'String',char(177));




% --- Executes on selection change in selScreenCalConstAlg.
function selScreenCalConstAlg_Callback(hObject, eventdata, handles)
% hObject    handle to selScreenCalConstAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selScreenCalConstAlg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selScreenCalConstAlg

global gBunchLength;

algs = get (hObject,'String');
gBunchLength.screen.blen_phase.alg{1} = algs(get(hObject,'Value'));

if isfield(gBunchLength,'cal')
    [gBunchLength.cal.polyfit.ok, gBunchLength.cal.polyfit, gBunchLength.cal.lscov] = ...
        BunchLengthCalibrationCalcs (gBunchLength.cal);
end


% --- Executes during object creation, after setting all properties.
function selScreenCalConstAlg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selScreenCalConstAlg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in EXPORT.
function EXPORT_Callback(hObject, eventdata, handles)
% hObject    handle to EXPORT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Bring up a new figure with the Bunch Length Measurement results suitable
% for printing to the eLog book.

global gBunchLength;
global gBunchLengthGUI;

if isfield(gBunchLengthGUI,'meas_export_handle')
    if ishandle(gBunchLengthGUI.meas_export_handle)
        close (gBunchLengthGUI.meas_export_handle);
    end
end

BunchLengthSaveMeas_pvs;
BunchLengthSaveCal_pvs;

% Temporal Profile

if isfield(gBunchLengthGUI,'meas_tp_handle')
    if ishandle(gBunchLengthGUI.meas_tp_handle)
        close (gBunchLengthGUI.meas_tp_handle);
    end
end

gBunchLengthGUI.meas_tp_handle = figure();
gBunchLengthGUI.meas_tp_axes = axes();
BunchLengthTemporalProfilePlot(gBunchLengthGUI.meas_tp_axes);
set (gBunchLengthGUI.meas_tp_handle,'Name',sprintf('Temporal Profile %s',char(gBunchLength.blen.meas_ts.value)));
util_printLog(gBunchLengthGUI.meas_tp_handle);

% The Bunch Length

gBunchLengthGUI.meas_export_handle = figure();
opts.figure = gBunchLengthGUI.meas_export_handle;
amp = gBunchLength.meas.results.amp;
beamlist = gBunchLength.meas.results.beamlist;
calConst = gBunchLength.meas.results.calConstpix;
calConstSTD = gBunchLength.meas.results.calConstSTDpix;

[results.sigxpix, ...
    results.sigt, ...
    results.sigxstdpix, ...
    results.sigtstd, ...
    results.r35, ...
    results.r35std] = tcav_bunchLength (...
    amp, ...
    beamlist, ...
    calConst, ...
    calConstSTD, ...
    opts);

set (gBunchLengthGUI.meas_export_handle,'Name',sprintf('Bunch Length Measurement Results %s',char(gBunchLength.blen.meas_ts.value)));

tString = cell(0);
bl.sigx = gBunchLength.blen.sigx.value{1};
bl.sigx_std = gBunchLength.blen.sigx.std{1};
bl.mm = gBunchLength.blen.mm.value{1};
bl.mm_std = gBunchLength.blen.mm.std{1};
bl.deg = gBunchLength.blen.sigt.value{1};
bl.deg_std = gBunchLength.blen.sigt.std{1};
bl.r35 = gBunchLength.blen.r35.value{1};
bl.r35_std = gBunchLength.blen.r35.std{1};

tString{end+1} = sprintf ('Bunch Length FWHM=%.3f ps %.5f\\pm%.5f %s %.3f\\pm%.3f %s r35=%.3f\\pm%.3f',...
    gBunchLength.meas.results.FWHM, ...
    bl.mm, bl.mm_std, char(gBunchLength.blen.mm.egu{1}),...
    bl.deg, bl.deg_std, char(gBunchLength.blen.sigt.egu{1}),...
    bl.r35, bl.r35_std);

bl.first_phase = gBunchLength.blen.first_phase.value{1};
bl.third_phase = gBunchLength.blen.third_phase.value{1};
bl.tcav_ampl = gBunchLength.meas.tcav{1}.aact.val(1);

tString{end+1} = sprintf ('%s     %.0f %s     %.0f %s     %.1f %s',...
    gBunchLength.tcav.name, ...
    bl.first_phase, char(gBunchLength.tcav.pdes.egu{1}), ...
    bl.third_phase, char(gBunchLength.tcav.pdes.egu{1}), ...
    bl.tcav_ampl, char(gBunchLength.tcav.aact.egu{1}));

if isfield(gBunchLength.blen,'nel')
    tString{end+1} = sprintf('%s: %.3fx10e9 %s', char(gBunchLength.blen.nel.desc{1}),...
        gBunchLength.blen.nel.value{1}/1e9, char(gBunchLength.blen.nel.egu{1}));
end

bl.screenCalConst = gBunchLength.meas.results.calConst;
bl.screenCalConstSTD = gBunchLength.meas.results.calConstSTD;

tString{end+1} = sprintf ('%s     %.3f\\pm%.3f %s     Calibration Time: %s',...
    char(gBunchLength.meas.option.screen.desc), ...
    bl.screenCalConst, bl.screenCalConstSTD, ...
    char(gBunchLength.meas.option.screen.blen_phase.egu{1}), ...
    char(gBunchLength.screen.blen_phase.timestamp{1}));

tString{end+1} = sprintf ('Measurement Time: %s     Image Processing Algorithm: %s', ...
    char(gBunchLength.blen.meas_ts.value{1}), ...
    char(gBunchLength.blen.meas_img_alg.value{1}));
    
title (tString,'FontSize',12);

util_printLog(gBunchLengthGUI.meas_export_handle);

BunchLengthLogMsg('Measurement results sent to eLog book.');

% --- Executes on selection change in MEASIMGALGSEL.
function MEASIMGALGSEL_Callback(hObject, eventdata, handles)
% hObject    handle to MEASIMGALGSEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MEASIMGALGSEL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MEASIMGALGSEL

global gBunchLength;
global gBunchLengthGUI;
global gIMG_MAN_DATA;

algIndex = get(gBunchLengthGUI.handles.MEASIMGALGSEL,'Value');
for each_dataset=1:size(gBunchLength.meas.gIMG_MAN_DATA.dataset,2)
    for each_image=(1+gBunchLength.meas.gIMG_MAN_DATA.dataset{each_dataset}.nrBgImgs):size(gBunchLength.meas.gIMG_MAN_DATA.dataset{each_dataset}.ipOutput,2)
        gBunchLength.meas.gIMG_MAN_DATA.dataset{each_dataset}.ipParam{each_image}.algIndex = algIndex;
    end
end
gIMG_MAN_DATA = gBunchLength.meas.gIMG_MAN_DATA;
gBunchLength.lastLoadedImageData = 2;
gIMG_MAN_DATA.hasChanged = 1;
algs = get(gBunchLengthGUI.handles.MEASIMGALGSEL,'String');
gBunchLength.blen.meas_img_alg.value{1} = algs{algIndex};

% --- Executes during object creation, after setting all properties.
function MEASIMGALGSEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MEASIMGALGSEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in CALIMGALGSEL.
function CALIMGALGSEL_Callback(hObject, eventdata, handles)
% hObject    handle to CALIMGALGSEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CALIMGALGSEL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CALIMGALGSEL

global gBunchLength;
global gBunchLengthGUI;
global gIMG_MAN_DATA;

algIndex = get(gBunchLengthGUI.handles.CALIMGALGSEL,'Value');
for each_dataset=1:size(gBunchLength.cal.gIMG_MAN_DATA.dataset,2)
    for each_image=(1+gBunchLength.cal.gIMG_MAN_DATA.dataset{each_dataset}.nrBgImgs):size(gBunchLength.cal.gIMG_MAN_DATA.dataset{each_dataset}.ipOutput,2)
        gBunchLength.cal.gIMG_MAN_DATA.dataset{each_dataset}.ipParam{each_image}.algIndex = algIndex;
    end
end
gIMG_MAN_DATA = gBunchLength.cal.gIMG_MAN_DATA;
gBunchLength.lastLoadedImageData = 1;
gIMG_MAN_DATA.hasChanged = 1;
algs = get(gBunchLengthGUI.handles.CALIMGALGSEL,'String');
gBunchLength.blen.cal_img_alg.value{1} = algs{algIndex};


% --- Executes during object creation, after setting all properties.
function CALIMGALGSEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CALIMGALGSEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in SaveToFile.
function SaveToFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveToFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthGUISave;


% --- Executes on button press in NextProfile.
function NextProfile_Callback(hObject, eventdata, handles)
% hObject    handle to NextProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;

gBunchLength.meas.results.profIndex = 1 + gBunchLength.meas.results.profIndex;
ok = 0;
while ~ok
    if gBunchLength.meas.results.profIndex > size(gBunchLength.meas.results.amp,2)
        gBunchLength.meas.results.profIndex = 1;
    end
    if isequal(0,gBunchLength.meas.results.amp(gBunchLength.meas.results.profIndex))
        gBunchLength.meas.results.profIndex = 1 + gBunchLength.meas.results.profIndex;
    else
        ok = 1;
    end
end
gBunchLength.meas.results.profy = gBunchLength.meas.results.beamlist(gBunchLength.meas.results.profIndex).profy(2,:);

% --- Executes on button press in PrevProfile.
function PrevProfile_Callback(hObject, eventdata, handles)
% hObject    handle to PrevProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global gBunchLength;

gBunchLength.meas.results.profIndex = gBunchLength.meas.results.profIndex - 1;
ok = 0;
while ~ok
    if gBunchLength.meas.results.profIndex <= 0
        gBunchLength.meas.results.profIndex = size(gBunchLength.meas.results.amp,2);
    end
    if isequal(0,gBunchLength.meas.results.amp(gBunchLength.meas.results.profIndex))
        gBunchLength.meas.results.profIndex = gBunchLength.meas.results.profIndex - 1;
    else
        ok = 1;
    end
end
gBunchLength.meas.results.profy = gBunchLength.meas.results.beamlist(gBunchLength.meas.results.profIndex).profy(2,:);


% --- Executes on button press in toTCAV0.
function toTCAV0_Callback(hObject, eventdata, handles)
% hObject    handle to toTCAV0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

gBunchLength.skip=1;
gBunchLengthGUI.skip=1;

BunchLengthTCAV0;
BunchLengthSwitch;

gBunchLength.skip=0;
gBunchLengthGUI.skip=0;


% --- Executes on button press in cExport.
function cExport_Callback(hObject, eventdata, handles)
% hObject    handle to cExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

if isfield(gBunchLengthGUI,'cal_export_handle')
    if ishandle(gBunchLengthGUI.cal_export_handle)
        close (gBunchLengthGUI.cal_export_handle);
    end
end

BunchLengthSaveCal_pvs;
gBunchLengthGUI.cal_export_handle = figure();
opts.figure = gBunchLengthGUI.cal_export_handle;
phase = gBunchLength.cal.lscov.phase;
beamlist = gBunchLength.cal.lscov.beamlist;
[results.cal, results.calstd] = tcav_calibration (phase, beamlist, opts);

set (gBunchLengthGUI.cal_export_handle,'Name',sprintf('Bunch Length Calibration Results %s',imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.cal.ts),1)));

tString = cell(0);

tString{end+1} = sprintf ('%s   %f\\pm%f %s  %s', char(gBunchLength.screen.blen_phase.desc{1}), ...
    gBunchLength.screen.blen_phase.value{1}, gBunchLength.screen.blen_phase.std{1}, ...
    char(gBunchLength.screen.blen_phase.egu{1}),...
    char(gBunchLength.blen.cal_img_alg.value{1}));

tString{end+1} = sprintf('%s %.1f %s  %s', char(gBunchLength.tcav.aact.desc{1}),...
    gBunchLength.screen.blen_phase.tcav_power{1}, char(gBunchLength.tcav.aact.egu{1}),...
    imgUtil_matlabTime2String(lca2matlabTime(gBunchLength.cal.ts),1));

title (tString,'FontSize',12);

util_printLog(gBunchLengthGUI.cal_export_handle);

BunchLengthLogMsg('Calibration results sent to eLog book.');


% --- Executes on button press in toTCAV3.
function toTCAV3_Callback(hObject, eventdata, handles)
% hObject    handle to toTCAV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gBunchLength;
global gBunchLengthGUI;

gBunchLength.skip=1;
gBunchLengthGUI.skip=1;

BunchLengthTCAV3;
BunchLengthSwitch;

gBunchLength.skip=0;
gBunchLengthGUI.skip=0;


% --- Executes on button press in TCAVON.
function TCAVON_Callback(hObject, eventdata, handles)
% hObject    handle to TCAVON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthTCAVControl('ACTIVATE');



% --- Executes on button press in TCAVOFF.
function TCAVOFF_Callback(hObject, eventdata, handles)
% hObject    handle to TCAVOFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthTCAVControl('STANDBY');




% --- Executes on button press in SmallSaveToFile.
function SmallSaveToFile_Callback(hObject, eventdata, handles)
% hObject    handle to SmallSaveToFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BunchLengthGUISaveSmall;
