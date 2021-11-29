function varargout = solenoid_counter_gui(varargin)
% SOLENOID_COUNTER_GUI MATLAB code for solenoid_counter_gui.fig
%      SOLENOID_COUNTER_GUI, by itself, creates a new SOLENOID_COUNTER_GUI or raises the existing
%      singleton*.
%
%      H = SOLENOID_COUNTER_GUI returns the handle to a new SOLENOID_COUNTER_GUI or the handle to
%      the existing singleton*.
%
%      SOLENOID_COUNTER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOLENOID_COUNTER_GUI.M with the given input arguments.
%
%      SOLENOID_COUNTER_GUI('Property','Value',...) creates a new SOLENOID_COUNTER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before solenoid_counter_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to solenoid_counter_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help solenoid_counter_gui

% Last Modified by GUIDE v2.5 24-Apr-2015 18:08:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @solenoid_counter_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @solenoid_counter_gui_OutputFcn, ...
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


% --- Executes just before solenoid_counter_gui is made visible.
function solenoid_counter_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to solenoid_counter_gui (see VARARGIN)

% Choose default command line output for solenoid_counter_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes solenoid_counter_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = solenoid_counter_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Disable solenoid nozzle and stop counter
lcaPut('TRIG:LI20:EX01:FP2_TCTL',0);
lcaPut('SIOC:SYS1:ML00:AO193',0);

current_rate=lcaGet('EVR:LI20:EX01:EVENT14CTRL.ENM');
[rate,output]=get_rate(current_rate);
set(handles.solenoid_rate,'Value',output);


% --- Executes on button press in solenoid_on.
function solenoid_on_Callback(hObject, eventdata, handles)
% hObject    handle to solenoid_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('SIOC:SYS1:ML00:AO193',1); %Start counter
run_solenoid_on;


% --- Executes on button press in stop_counting.
function stop_counting_Callback(hObject, eventdata, handles)
% hObject    handle to stop_counting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('TRIG:LI20:EX01:FP2_TCTL',0);
lcaPut('SIOC:SYS1:ML00:AO193',0);

% --- Executes on button press in reset_count.
function reset_count_Callback(hObject, eventdata, handles)
% hObject    handle to reset_count (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('SIOC:SYS1:ML00:AO193',0);
lcaPut('SIOC:SYS1:ML00:AO194',0);
lcaPut('TRIG:LI20:EX01:FP2_TCTL',0);


% --- Executes on selection change in solenoid_rate.
function solenoid_rate_Callback(hObject, eventdata, handles)
% hObject    handle to solenoid_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns solenoid_rate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from solenoid_rate
option_selected = get(hObject,'Value');
menu_string = get(hObject,'String');
requested_rate=str2num(menu_string{option_selected});
lcaPut('EVR:LI20:EX01:EVENT14CTRL.ENM',get_rate_event(requested_rate));

% --- Executes during object creation, after setting all properties.
function solenoid_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solenoid_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
