function varargout = fbLoopGui(varargin)
% FBLOOPGUI M-file for fbLoopGui.fig
%      FBLOOPGUI, by itself, creates a new FBLOOPGUI or raises the existing
%      singleton*.
%
%      H = FBLOOPGUI returns the handle to a new FBLOOPGUI or the handle to
%      the existing singleton*.
%
%      FBLOOPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBLOOPGUI.M with the given input arguments.
%
%      FBLOOPGUI('Property','Value',...) creates a new FBLOOPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbLoopGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbLoopGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbLoopGui

% Last Modified by GUIDE v2.5 03-Oct-2006 15:50:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbLoopGui_OpeningFcn, ...
                   'gui_OutputFcn',  @fbLoopGui_OutputFcn, ...
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


% --- Executes just before fbLoopGui is made visible.
function fbLoopGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbLoopGui (see VARARGIN)

% Choose default command line output for fbLoopGui
handles.output = hObject;

% initialize the values in the edit boxes from the config values
config = getappdata(0,'Config_structure');
set(handles.loopNameEdit, 'String', config.feedbackName );
set(handles.tmrfcnNameEdit, 'String', config.timer.fcnName );
set(handles.initfcnNameEdit, 'String', config.initloopfcnName );
set(handles.filenameEdit, 'String', config.filename );
set(handles.filenameEdit, 'Enable', 'off' );%dont allow edit here
set(handles.goldorbitEdit, 'String', config.reforbitName );
set(handles.goldorbitEdit, 'Enable', 'off' ); %don't allow edit here

% save the config values in the handles structure for now
% we'll keep them here for gui work, and move them back to 'config'
% when the done button is pressed
handles.feedbackName = config.feedbackName;
handles.timerfcnName = config.timer.fcnName;
handles.initfcnName = config.initloopfcnName;
handles.filename = config.filename;
handles.reforbitName = config.reforbitName;
handles.configchanged = config.configchanged;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fbLoopGui wait for user response (see UIRESUME)
uiwait(handles.loopFig);


% --- Outputs from this function are returned to the command line.
function varargout = fbLoopGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.loopFig);



function loopNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to loopNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loopNameEdit as text
%        str2double(get(hObject,'String')) returns contents of loopNameEdit as a double
handles.feedbackName = get(hObject, 'String');
handles.configchanged = 1;
guidata(gcbf,handles);

% --- Executes during object creation, after setting all properties.
function loopNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loopNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tmrfcnNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to tmrfcnNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tmrfcnNameEdit as text
%        str2double(get(hObject,'String')) returns contents of tmrfcnNameEdit as a double
handles.timerfcnName = get(hObject, 'String');
handles.configchanged = 1;
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function tmrfcnNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tmrfcnNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenameEdit as text
%        str2double(get(hObject,'String')) returns contents of filenameEdit as a double
handles.filename = get(hObject, 'String');
handles.configchanged = 1;
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function filenameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function goldorbitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to goldOrbitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goldOrbitEdit as text
%        str2double(get(hObject,'String')) returns contents of goldOrbitEdit as a double
handles.reforbitName = get(hObject, 'String');
handles.configchanged = 1;
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function goldorbitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goldOrbitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% we're done with this window, store data changes 
% (we just assume there were changes)
config = getappdata(0, 'Config_structure');
config.feedbackName = handles.feedbackName;
config.timer.fcnName = handles.timerfcnName;
config.initloopfcnName = handles.initfcnName;
config.filename = handles.filename;
config.reforbitName = handles.reforbitName;
if ~strcmpi(config.reforbitName, '0')
   filename =  sprintf ('%s/Feedback/data/%s%s/%s', ...
         getenv('MATLABDATAFILES'), config.feedbackAcro, config.feedbackNum, config.reforbitName); 
   load(filename);
   config.refInit = 1;
   config.refData = refData;
   config.act.limits = fbCalcNewActLimits(config.refData.actvals, config.act.limits);
   fbSoftIOCFcn('PutActInfo',config.act);
else
    config.refInit = 0;
    config.refData.count = 0;
    config.refData.data = zeros(length(config.meas.allmeasPVs),1);
    config.refData.actvals = lcaGet(config.act.allactPVs);
end

config.configchanged = handles.configchanged;
setappdata(0,'Config_structure',config);
%resume - outputFcn will delete the figure and close dialog
uiresume(handles.loopFig);


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%resume - outputFcn will delete the figure and close dialog
uiresume(handles.loopFig);

% --- Executes when user attempts to close loopFig.
function loopFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to loopFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%just close without saving changes.
if isequal(get(handles.loopFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
   uiresume(handles.loopFig);
else
   % The GUI is no longer waiting, just close it
   delete(handles.loopFig);
end



function initfcnNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to initfcnNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initfcnNameEdit as text
%        str2double(get(hObject,'String')) returns contents of initfcnNameEdit as a double
handles.initfcnName = get(hObject, 'String');
handles.configchanged = 1;
guidata(gcbf,handles);



% --- Executes during object creation, after setting all properties.
function initfcnNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initfcnNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


