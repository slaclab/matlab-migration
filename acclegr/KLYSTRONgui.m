function varargout = KLYSTRONgui(varargin)
% KLYSTRONGUI M-file for KLYSTRONgui.fig
%      KLYSTRONGUI, by itself, creates a new KLYSTRONGUI or raises the existing
%      singleton*.
%
%      H = KLYSTRONGUI returns the handle to a new KLYSTRONGUI or the handle to
%      the existing singleton*.
%
%      KLYSTRONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KLYSTRONGUI.M with the given input arguments.
%
%      KLYSTRONGUI('Property','Value',...) creates a new KLYSTRONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KLYSTRONgui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KLYSTRONgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KLYSTRONgui

% Last Modified by GUIDE v2.5 26-Jul-2012 12:22:21

%% Updates
%           Dec 22, 2007
%           Mar 26, 2008
%           Apr 18, 2008
%           May 25, 2011
%           Jul 19, 2012 ver 7
%           Aug  3, 2012 ver 8 New button to close open Figures
%           Aug  3, 2012 ver 9 Corrected bug in the "select program"


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @KLYSTRONgui_OpeningFcn, ...
    'gui_OutputFcn',  @KLYSTRONgui_OutputFcn, ...
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

% --- Executes just before KLYSTRONgui is made visible.
function KLYSTRONgui_OpeningFcn(hObject, eventdata, handles, varargin)
% store the initial string for klystron and signal selection
%signal_string = get(findobj('Tag','signal_select'),'String');
%this is the cell array, to change it to a string, use "char(signal_string)"

%%%%%*****************************
%DEFINE HANDLES PARAMETERS
handles = struct( 'output', ...
    hObject, ...  % pointer to figure window
    'klystron','1',...
    'signal','1',...
    'aver_time',10,...
    'Return',0,...
    'width',512,...
    'exportFig',[]);
%%%*******************************

handles.signal_list_1=get(findobj('Tag','signal_select'),'string');
handles.signal_list_2 = handles.signal_list_1(1:4,1);

%'rotation_direction',get(findobj('Tag','rotation_direction'),'Value'),...

% Choose default command line output for KLYSTRONgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KLYSTRONgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = KLYSTRONgui_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in klystron_select.
function klystron_select_Callback(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function klystron_select_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in signal_select.
function signal_select_Callback(hObject, eventdata, handles)

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function signal_select_CreateFcn(hObject, eventdata, handles)
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function averaging_time_Callback(hObject, eventdata, handles)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function averaging_time_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in start_progr.
function start_progr_Callback(hObject, eventdata, handles)

handles.klystron = get(findobj('Tag','klystron_select'),'Value');
handles.signal = get(findobj('Tag','signal_select'),'Value');
handles.aver_time = get(findobj('Tag','averaging_time'),'String');
handles.width = get(findobj('Tag','averaging_time'),'String');
program = get(findobj('Tag','program_select'),'Value');

switch program
    case 1
        h1 = findobj('Tag','start_progr');
        String = get(h1,'String');
        if strcmp(String,'STOP')
            set(findobj('Tag','txt4'),'Visible','Off')
            set(findobj('Tag','txt5'),'Visible','Off')
            handles.Return = 1;
            guidata(handles.output,handles); %updating handles
        else
            set(h1,'string','STOP');
            drawnow
            guidata(handles.output,handles); %updating handles
            KLYSTRONgui_average_ampl_phase(hObject, eventdata, handles);
            handles=guidata(handles.output);
        end
     case 2
        h1 = findobj('Tag','start_progr');
        String = get(h1,'String');
        if strcmp(String,'STOP')
            set(findobj('Tag','txt4'),'Visible','Off')
            set(findobj('Tag','txt5'),'Visible','Off')
            handles.Return = 1;
            guidata(handles.output,handles); %updating handles
        else
            set(h1,'string','STOP');
            drawnow
            guidata(handles.output,handles); %updating handles
            KLYSTRONgui_waveforms(hObject, eventdata, handles);
            handles=guidata(handles.output);
        end
    case 3
        guidata(handles.output,handles); %updating handles
        KLYSTRONgui_pulse_shape(hObject, eventdata, handles);
        handles=guidata(handles.output);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)

close all
return


% --- Executes during object creation, after setting all properties.
function exit_CreateFcn(hObject, eventdata, handles)
%
function program_select_Callback(hObject, eventdata, handles)
%
program = get(findobj('Tag','program_select'),'Value');
switch program
    case {1 2}
        set(findobj('Tag','txt3'),'String','Averaging Time [s]')
        set(findobj('Tag','averaging_time'),'String','10')
        set(findobj('Tag','signal_select'),'value',1)
        set(findobj('Tag','signal_select'),'string',handles.signal_list_1)

    case 3
        set(findobj('Tag','txt3'),'String','Pulse Width')
        set(findobj('Tag','averaging_time'),'String','512')
        set(findobj('Tag','signal_select'),'value',1)
        set(findobj('Tag','signal_select'),'string',handles.signal_list_2)
end

function program_select_CreateFcn(hObject, eventdata, handles)
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Logbook.
function Logbook_Callback(hObject, eventdata, handles)
print(handles.exportFig,'-dpsc2','-Pphysics-lclslog');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/acclegr/KLYSTRONgui.m', which('KLYSTRONgui'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end



% --- Executes on button press in close_fig.
function close_fig_Callback(hObject, eventdata, handles)
% hObject    handle to close_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(1:handles.exportFig)
return

