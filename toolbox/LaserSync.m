function varargout = LaserSync(varargin)
% LaserSync scans the 476-MHz phase shifter for the Ti:sapphire laser on
% the terahertz table over several 360-degree scanrange to let the user
% synchronize the laser pulses with the THz pulses.

% LASERSYNC M-file for LaserSync.fig
%      LASERSYNC, by itself, creates a new LASERSYNC or raises the existing
%      singleton*.
%
%      H = LASERSYNC returns the handle to a new LASERSYNC or the handle to
%      the existing singleton*.
%
%      LASERSYNC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASERSYNC.M with the given input arguments.
%
%      LASERSYNC('Property','Value',...) creates a new LASERSYNC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LaserSync_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      incrementcount.  All inputs are passed to LaserSync_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LaserSync

% Last Modified by GUIDE v2.5 03-May-2014 10:25:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LaserSync_OpeningFcn, ...
                   'gui_OutputFcn',  @LaserSync_OutputFcn, ...
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
end



% --- Executes just before LaserSync is made visible.
function LaserSync_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LaserSync (see VARARGIN)

% Choose default command line output for LaserSync
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LaserSync wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global before start increment delay scanRange PauseScan StopScan

before    = lcaGetSmart('OSC:LA20:10:FS_TGT_TIME'); % Initial setting (ns)
start     = before;
increment = 1;      % Increment (ns)
delay     = 1;      % Time per step (s)
scanRange = 50;     % Total increment of phase shifter (ns)
PauseScan = 0;
StopScan  = 0;

set(handles.Before,        'String',num2str(before))
set(handles.Start,         'String',num2str(start))
set(handles.Increment,     'String',num2str(increment))
set(handles.Delay,         'String',num2str(delay,'%4.2f'))
set(handles.ScanRange,     'String',num2str(scanRange))
set(handles.TimeNow,       'String',num2str(before))
end



% --- Outputs from this function are returned to the command line.
function varargout = LaserSync_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



function Before_Callback(hObject, eventdata, handles)
% hObject    handle to Before (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Before as text
%        str2double(get(hObject,'String')) returns contents of Before as a double
global before
set(hObject,'String',num2str(before))
end


% --- Executes during object creation, after delay all properties.
function Before_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Before (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Start as text
%        str2double(get(hObject,'String')) returns contents of Start as a double
global before start
s = str2double(get(hObject,'String'));
if isnan(s) || s < 0 || abs(s-before) > 5000
    s = before;
end
start = s;
set(hObject,'String',num2str(start))
end


% --- Executes during object creation, after delay all properties.
function Start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Increment_Callback(hObject, eventdata, handles)
% hObject    handle to Increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Increment as text
%        str2double(get(hObject,'String')) returns contents of Increment as a double
global increment scanRange
t = str2double(get(hObject,'String'));
if ~isnan(t) && abs(t) < 2
    increment = t;
end
set(hObject,'String',num2str(increment))
scanRange = increment*round(abs(scanRange/increment));
set(handles.ScanRange,'String',num2str(scanRange))
end


% --- Executes during object creation, after delay all properties.
function Increment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Increment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function ScanRange_Callback(hObject, eventdata, handles)
% hObject    handle to ScanRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanRange as text
%        str2double(get(hObject,'String')) returns contents of ScanRange as a double
global scanRange increment
s = str2double(get(hObject,'String'));
if isnan(s) || abs(s) > 5000
    s = 50*sign(increment);
end
scanRange = s;
set(hObject,'String',num2str(scanRange,'%6.1f'))
increment = scanRange/round(abs(scanRange/increment));
set(handles.IncrementCount,'String',num2str(increment))
end


% --- Executes during object creation, after setting all properties.
function ScanRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Delay_Callback(hObject, eventdata, handles)
% hObject    handle to Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Delay as text
%        str2double(get(hObject,'String')) returns contents of Delay as a double
global delay
s = str2double(get(hObject,'String'));
if isnan(s) || s <= 0.5 || s > 10
    s = 1;
end
delay = s;
set(hObject,'String',num2str(s))
end


% --- Executes during object creation, after delay all properties.
function Delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function TimeNow_Callback(hObject, eventdata, handles)
% hObject    handle to TimeNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeNow as text
%        str2double(get(hObject,'String')) returns contents of TimeNow as a double
set(hObject,'String',...
    num2str(lcaGetSmart('OSC:LA20:10:FS_TGT_TIME'),'%11.6f'))
end


% --- Executes during object creation, after setting all properties.
function TimeNow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PauseButton
global PauseScan
if PauseScan
    PauseScan = 0;
    set(handles.PauseButton,'String','Pause')
else
    PauseScan = 1;
    set(handles.PauseButton,'String','Resume')
end
end



% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopButton
global StopScan
StopScan = 1;
end



% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Exit
exit
end



% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StartButton

global before start increment delay scanRange PauseScan StopScan

PauseScan = 0;
StopScan  = 0;
set(hObject,'String','Running')
set(handles.PauseButton,'Value',0)
set(handles.StopButton,'Value',0)

n = 0;
finish = start+scanRange;
nSteps = length(start:increment:finish);
while n < nSteps && ~StopScan
    if PauseScan
        pause(1)
    else
        tic
        t = start+increment*n;
        n = n+1;
        lcaPutSmart('OSC:LA20:10:FS_TGT_TIME',t);
        set(handles.TimeNow,'String',num2str(t,'%11.6f'))
        pause(max(delay-toc,0.05))
    end
end

start = t;
set(handles.Start, 'String',num2str(start))
PauseScan = 0;
StopScan  = 0;
set(handles.StartButton,'Value',0,'String','Start')
set(handles.PauseButton,'Value',0,'String','Pause')
set(handles.StopButton,'Value',0);
end
