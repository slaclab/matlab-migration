function varargout = solenoid_counter_gui_2(varargin)
% SOLENOID_COUNTER_GUI_2 MATLAB code for solenoid_counter_gui_2.fig
%      SOLENOID_COUNTER_GUI_2, by itself, creates a new SOLENOID_COUNTER_GUI_2 or raises the existing
%      singleton*.
%
%      H = SOLENOID_COUNTER_GUI_2 returns the handle to a new SOLENOID_COUNTER_GUI_2 or the handle to
%      the existing singleton*.
%
%      SOLENOID_COUNTER_GUI_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOLENOID_COUNTER_GUI_2.M with the given input arguments.
%
%      SOLENOID_COUNTER_GUI_2('Property','Value',...) creates a new SOLENOID_COUNTER_GUI_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before solenoid_counter_gui_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to solenoid_counter_gui_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help solenoid_counter_gui_2

% Last Modified by GUIDE v2.5 23-Feb-2016 18:45:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @solenoid_counter_gui_2_OpeningFcn, ...
                   'gui_OutputFcn',  @solenoid_counter_gui_2_OutputFcn, ...
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


% --- Executes just before solenoid_counter_gui_2 is made visible.
function solenoid_counter_gui_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to solenoid_counter_gui_2 (see VARARGIN)

% Choose default command line output for solenoid_counter_gui_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes solenoid_counter_gui_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = solenoid_counter_gui_2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Set Trigger rate to 0.5 Hz
lcaPut('EVR:LI20:EX01:EVENT6CTRL.OUT2',1);
lcaPut('EVR:LI20:EX01:EVENT2CTRL.OUT2',0);

% Get current Delay and Gate
delay_current = lcaGet('TRIG:LI20:EX01:FP2_TDES')/(10^6)-16.6;
gate_current = lcaGet('TRIG:LI20:EX01:FP2_TWID')/(10^6);
delay_current_str = num2str(delay_current);
gate_current_str = num2str(gate_current);
set(handles.delay_input,'String',delay_current_str);
set(handles.gate_input,'String',gate_current_str);

% Get status of filters
h2_filter_current = char(lcaGet('APC:LI20:EX02:24VOUT_2'));
switch h2_filter_current
    case 'ON'
       set(handles.h2_filter,'Value',1);
    case 'OFF'
        set(handles.h2_filter,'Value',0);
end
he_filter_current = char(lcaGet('APC:LI20:EX02:24VOUT_1'));
switch he_filter_current
    case 'ON'
       set(handles.he_filter,'Value',1);
    case 'OFF'
        set(handles.he_filter,'Value',0);
end

% Disable solenoid nozzle and stop counter
lcaPut('TRIG:LI20:EX01:FP2_TCTL',0);
lcaPut('SIOC:SYS1:ML00:AO193',0);


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
% lcaPut('EVR:LI20:EX01:EVENT14CTRL.ENM',get_rate_event(requested_rate));
switch requested_rate
    case 0.5
        lcaPut('EVR:LI20:EX01:EVENT6CTRL.OUT2',1);
        lcaPut('EVR:LI20:EX01:EVENT2CTRL.OUT2',0);
    case 1
        lcaPut('EVR:LI20:EX01:EVENT6CTRL.OUT2',0);
        lcaPut('EVR:LI20:EX01:EVENT2CTRL.OUT2',1);
    otherwise
        error('invalid rate selected')
end


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



function delay_input_Callback(hObject, eventdata, handles)
% hObject    handle to delay_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay_input as text
%        str2double(get(hObject,'String')) returns contents of delay_input as a double
delay_string = get(hObject,'String');
delay_value = str2num(delay_string)+16.6;
delay_value_ns = delay_value*(10^6);
lcaPut('TRIG:LI20:EX01:FP2_TDES',delay_value_ns);


% --- Executes during object creation, after setting all properties.
function delay_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gate_input_Callback(hObject, eventdata, handles)
% hObject    handle to gate_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gate_input as text
%        str2double(get(hObject,'String')) returns contents of gate_input as a double
gate_string = get(hObject,'String');
gate_value = str2num(gate_string);
gate_value_ns = gate_value*(10^6);
lcaPut('TRIG:LI20:EX01:FP2_TWID',gate_value_ns);


% --- Executes during object creation, after setting all properties.
function gate_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gate_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in h2_filter.
function h2_filter_Callback(hObject, eventdata, handles)
% hObject    handle to h2_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of h2_filter
h2_filter_value = get(hObject,'Value');
if h2_filter_value == 1
    lcaPut('APC:LI20:EX02:24VOUT_2',1);
else
    lcaPut('APC:LI20:EX02:24VOUT_2',0);
end
    

% --- Executes on button press in he_filter.
function he_filter_Callback(hObject, eventdata, handles)
% hObject    handle to he_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of he_filter
he_filter_value = get(hObject,'Value');
if he_filter_value == 1
    lcaPut('APC:LI20:EX02:24VOUT_1',1);
else
    lcaPut('APC:LI20:EX02:24VOUT_1',0);
end