%% CONTROL GUI FOR THE AUTOMATED PROGRAM TO SYNCHRONIZE LCLS LLRF
% Development started:    Jan-11-2008
% Version 1: finished: Jan-15-2008
% Version 2: removed most of the commented lines; disable EXIT button when
% program is running; changed GUI actions when program stopped: Oct-17-2008

% Last update: Oct-17-2008
% Program name: RF_SYNCgui.m
% written:          Vojtech Pacak

function varargout = RF_SYNCgui(varargin)
% RF_SYNCgui M-file for RF_SYNCgui.fig
%      RF_SYNCgui, by itself, creates a new RF_SYNCgui or raises the existing
%      singleton*.
%
%      H = RF_SYNCgui returns the handle to a new RF_SYNCgui or the handle to
%      the existing singleton*.
%
%      RF_SYNCgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RF_SYNCgui.M with the given input arguments.
%
%      RF_SYNCgui('Property','Value',...) creates a new RF_SYNCgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RF_SYNCgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RF_SYNCgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RF_SYNCgui

% Last Modified by GUIDE v2.5 22-Jan-2008 16:09:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RF_SYNCgui_OpeningFcn, ...
    'gui_OutputFcn',  @RF_SYNCgui_OutputFcn, ...
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


% --- Executes just before RF_SYNCgui is made visible.
function RF_SYNCgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% input the current phase values into the corresponding GUI windows
pvNames_gui = {
    'LLRF:IN20:RH:MDL_I_ADJUST'
    'LLRF:IN20:RH:MDL_Q_ADJUST'
    'LLRF:IN20:RH:REF_3_S_PA'
    'LLRF:IN20:RH:REF_2_S_PA'
    'LASR:IN20:1:LSR_3_S_PA'
    };
phases = num2str(round(lcaGet(pvNames_gui)));

h=zeros(10,1);
h(1)=findobj('Tag','i_value');
h(2)=findobj('Tag','q_value');
h(3)=findobj('Tag','text8'); %window phase 25.2
h(4)=findobj('Tag','text9'); %window phase 119 FIDO
h(5)=findobj('Tag','text10');%window phase 119 LCLS
h(7)=findobj('Tag','start');
h(8)=findobj('Tag','text7'); %window # of rotations
h(9)=findobj('Tag','axes1');
%put the current values of phases into the GUI text windows
for n=1:5
    set(h(n),'String',phases(n,:));
end
Text = get(findobj('Tag','text18'),'String'); %original text for 119MHZ laser
%**************************************************************************
%Initialize the graph - invisible at first
h(6)=findobj('Tag','axes1');
P=get(h(6),'position');

%**************************************************************************
%DEFINE HANDLES PARAMETERS
handles = struct( 'output', ...
    hObject, ...  % pointer to figure window
    'MDL_I',h(1),...
    'MDL_Q',h(2),...
    'graph_position',P,...
    's',h(7),...
    'Ph_25',h(3),...
    'Ph_119_F',h(4),...
    'Ph_119_L',h(5),...
    'Num_rot',h(8),...
    'polar_plot',h(9),...
    'Return',0,...
    'Text',{Text});
%**************************************************************************

% Choose default command line output for RF_SYNCgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RF_SYNCgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RF_SYNCgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;


function i_value_Callback(hObject, eventdata, handles)
% str2double(get(hObject,'String')) returns contents of i_value as a double


% --- Executes during object creation, after setting all properties.
function i_value_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function q_value_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of q_value as text
% str2double(get(hObject,'String')) returns contents of q_value as a double


% --- Executes during object creation, after setting all properties.
function q_value_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)

String = get(handles.s,'String');
Value = get(handles.s,'Value');
if  strcmp(String,'STOP')
    handles.Return = 1;
    set(findobj('Tag','text18'),'Visible','ON','String',...
        'OPERATOR STOPPED PROGRAM. COMPLETING FULL ROTATION')
    drawnow
    guidata(handles.output,handles); %updating handles
    disp('PROGRAM STOPPED BY THE OPERATOR COMMAND')
else
    set(handles.s,'string','STOP');
    set(findobj('Tag','text3'),'visible','off')
    set(findobj('Tag','text18'),'Visible','OFF','String',handles.Text)
    set(handles.Num_rot,'visible','off')
    set(findobj('tag','text11'),'visible','off')
    set(handles.polar_plot,'position',[100,100,1,1])
    set(handles.Num_rot,'String','0');
    drawnow
    guidata(handles.output,handles); %updating handles
    RF_SYNCgui_synchronize(hObject, eventdata, handles);
end

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of exit

% disable EXIT button when program running
String   = get(findobj('Tag','start'),'String');
if strcmp(String,'STOP')
    return
end
close all
return

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure

delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/acclegr/RF_SYNCgui.m', which('RF_SYNCgui'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end
% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
