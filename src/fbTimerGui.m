function varargout = fbTimerGui(varargin)
% FBTIMERGUI M-file for fbTimerGui.fig
%      FBTIMERGUI, by itself, creates a new FBTIMERGUI or raises the existing
%      singleton*.
%
%      H = FBTIMERGUI returns the handle to a new FBTIMERGUI or the handle to
%      the existing singleton*.
%
%      FBTIMERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBTIMERGUI.M with the given input arguments.
%
%      FBTIMERGUI('Property','Value',...) creates a new FBTIMERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbTimerGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbTimerGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fbTimerGui

% Last Modified by GUIDE v2.5 16-May-2006 10:53:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbTimerGui_OpeningFcn, ...
                   'gui_OutputFcn',  @fbTimerGui_OutputFcn, ...
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


% --- Executes just before fbTimerGui is made visible.
function fbTimerGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbTimerGui (see VARARGIN)

% Choose default command line output for fbTimerGui
handles.output = hObject;

%get the config data structure
config = getappdata(0,'Config_structure');

% initialize the values in the edit boxes from the loop values
set(handles.periodEdit, 'String', num2str(config.timer.period) );
set(handles.maxIntrEdit, 'String', num2str(config.timer.max) );

% save the loop values in the handles structure for now
% we'll keep them here for gui work, and move them back to 'loop'
% when the done button is pressed
handles.period = config.timer.period;
handles.max = config.timer.max;
handles.configchanged = config.configchanged;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fbTimerGui wait for user response (see UIRESUME)
uiwait(handles.timerFig);


% --- Outputs from this function are returned to the command line.
function varargout = fbTimerGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.timerFig);


function maxIntrEdit_Callback(hObject, eventdata, handles)
% hObject    handle to maxIntrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIntrEdit as text
%        str2double(get(hObject,'String')) returns contents of maxIntrEdit as a double

handles.max = str2num(get(hObject, 'String') );
handles.configchanged = 1;
guidata(gcbf,handles);

% --- Executes during object creation, after setting all properties.
function maxIntrEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxIntrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function periodEdit_Callback(hObject, eventdata, handles)
% hObject    handle to periodEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of periodEdit as text
%        str2double(get(hObject,'String')) returns contents of periodEdit as a double

handles.period = str2double(get(hObject, 'String') );
handles.configchanged = 1;
guidata(gcbf,handles);

% --- Executes during object creation, after setting all properties.
function periodEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periodEdit (see GCBO)
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
config.timer.period = handles.period;
config.timer.max = handles.max;
config.configchanged = handles.configchanged;
setappdata(0,'Config_structure',config);

uiresume(handles.timerFig);

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(figure) closes the figure
uiresume(handles.timerFig)

% --- Executes when user attempts to close timerFig.
function timerFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to timerFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
if isequal(get(handles.timerFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
   uiresume(handles.timerFig);
else
   % The GUI is no longer waiting, just close it
   delete(handles.timerFig);
end




