function varargout = BUNCH_PHASEgui(varargin)
% BUNCH_PHASEGUI M-file for BUNCH_PHASEgui.fig
%      BUNCH_PHASEGUI, by itself, creates a new BUNCH_PHASEGUI or raises the existing
%      singleton*.
%
%      H = BUNCH_PHASEGUI returns the handle to a new BUNCH_PHASEGUI or the handle to
%      the existing singleton*.
%
%      BUNCH_PHASEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUNCH_PHASEGUI.M with the given input arguments.
%
%      BUNCH_PHASEGUI('Property','Value',...) creates a new BUNCH_PHASEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BUNCH_PHASEgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BUNCH_PHASEgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BUNCH_PHASEgui

% Last Modified by GUIDE v2.5 02-May-2008 13:13:28
% Last modified by vojtech:   03-Jun-2010

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BUNCH_PHASEgui_OpeningFcn, ...
                   'gui_OutputFcn',  @BUNCH_PHASEgui_OutputFcn, ...
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


% --- Executes just before BUNCH_PHASEgui is made visible.
function BUNCH_PHASEgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BUNCH_PHASEgui (see VARARGIN)

%%%%%*****************************
%DEFINE HANDLES PARAMETERS
handles = struct( 'output', ...
    hObject, ...  % pointer to figure window
    'cavity','1',...
    'NumOfReading','10',...
    'Return',0,...
    'exportFig',[]);
%%%*******************************

% Choose default command line output for BUNCH_PHASEgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BUNCH_PHASEgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BUNCH_PHASEgui_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit2_Callback(hObject, eventdata, handles)
 
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)

String = get(findobj('Tag','Start'),'String');
        if strcmp(String,'STOP')
            handles.Return = 1;
            guidata(handles.output,handles); %updating handles
        else
            set(findobj('Tag','Start'),'String','STOP');
            handles.cavity = get(findobj('Tag','popupmenu1'),'Value');
            handles.NumOfReading = get(findobj('Tag','edit2'),'String');
            drawnow
            handles.exportFig = [];
            guidata(handles.output,handles); %updating handles
            set(findobj('-regexp','Tag','txt[1]'),'String','0/0')
            BUNCH_PHASEgui_acquire(hObject, eventdata, handles);
            handles.Return = 0;
            set(findobj('Tag','Start'),'string','START')
            guidata(handles.output,handles);
        end

% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
close all

% --- Executes on button press in Logbook.
function Logbook_Callback(hObject, eventdata, handles)
%util_printLog(handles.exportFig)
for k = 1:length(handles.exportFig)
print(handles.exportFig(k),'-dpsc2','-Pphysics-lclslog');
drawnow
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/acclegr/BUNCH_PHASESgui.m', which('BUNCH_PHASEgui'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
 


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotGraph.
function PlotGraph_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of PlotGraph
PlotGraph = get(findobj('Tag','PlotGraph'),'Value');
if PlotGraph == 0
    set(findobj('Tag','PlotGraph'),'String','No Graph');
else
    set(findobj('Tag','PlotGraph'),'String','Show Graph');
end

