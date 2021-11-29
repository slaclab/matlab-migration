function varargout = THzLaserSync(varargin)
% THzLaserSync scans the 476-MHz phase shifter for the Ti:sapphire laser on
% the terahertz table over several 360-degree scanrange to let the user
% synchronize the laser pulses with the THz pulses.

% THZLASERSYNC M-file for THzLaserSync.fig
%      THZLASERSYNC, by itself, creates a new THZLASERSYNC or raises the existing
%      singleton*.
%
%      H = THZLASERSYNC returns the handle to a new THZLASERSYNC or the handle to
%      the existing singleton*.
%
%      THZLASERSYNC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THZLASERSYNC.M with the given input arguments.
%
%      THZLASERSYNC('Property','Value',...) creates a new THZLASERSYNC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before THzLaserSync_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      incrementcount.  All inputs are passed to THzLaserSync_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help THzLaserSync

% Last Modified by GUIDE v2.5 04-Aug-2012 05:56:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @THzLaserSync_OpeningFcn, ...
                   'gui_OutputFcn',  @THzLaserSync_OutputFcn, ...
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



% --- Executes just before THzLaserSync is made visible.
function THzLaserSync_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to THzLaserSync (see VARARGIN)

% Choose default command line output for THzLaserSync
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes THzLaserSync wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global before start increment delay scanRange oneCycle PauseScan StopScan
before    = lcaGetSmart('DMP:THZ:PHS:01:PHASEVAL');
start     = before; % Initial phase-shifter setting (counts)
increment = 10;     % Increment of phase shifter (counts)
delay     = 0.25;   % Time per step (s)
scanRange = 15000;  % Total increment of phase shifter (ps)
oneCycle  = 942;    % Change in phase shifter corresponding to 360 degrees
PauseScan = 0;
StopScan  = 0;

set(handles.Before,        'String',num2str(before))
set(handles.Start,         'String',num2str(start))
set(handles.IncrementCount,'String',num2str(increment))
set(handles.IncrementTime, 'String',num2str(increment/(oneCycle*476e-6),'%6.1f'))
set(handles.Delay,         'String',num2str(delay,'%4.2f'))
set(handles.ScanRange,     'String',num2str(scanRange))
set(handles.OneCycle,      'String',num2str(oneCycle))
set(handles.CountsNow,     'String',num2str(before))
set(handles.TimeNow,       'String',num2str(before/(oneCycle*476e-6),'%6.1f'))
end



% --- Outputs from this function are returned to the command line.
function varargout = THzLaserSync_OutputFcn(hObject, eventdata, handles) 
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
before = lcaGetSmart('DMP:THZ:PHS:01:PHASEVAL');
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
global start
s = str2double(get(hObject,'String'));
if isnan(s) || s < 0 || s > 1023
    s = 0;
end
start = round(s);
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



function IncrementCount_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IncrementCount as text
%        str2double(get(hObject,'String')) returns contents of IncrementCount as a double
global increment scanRange oneCycle
s = str2double(get(hObject,'String'));
if isnan(s) || abs(s) > 400
    s = 10;
end
increment = round(s);
set(hObject,'String',num2str(increment))
set(handles.IncrementTime,'String',num2str(increment/(oneCycle*476e-6),'%6.1f'))
scanRange = sign(increment)*abs(scanRange);
set(handles.ScanRange,'String',num2str(scanRange))
end


% --- Executes during object creation, after delay all properties.
function IncrementCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IncrementCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function IncrementTime_Callback(hObject, eventdata, handles)
% hObject    handle to IncrementTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IncrementTime as text
%        str2double(get(hObject,'String')) returns contents of IncrementTime as a double
global increment scanRange oneCycle
t = str2double(get(hObject,'String'));
if isnan(t) || abs(t) > 1050
    t = increment/(oneCycle*476e-6);
else
    increment = round(t*oneCycle*476e-6);
    t = increment/(oneCycle*476e-6);
    set(handles.IncrementCount,'String',num2str(increment))
end
set(hObject,'String',num2str(t,'%6.1f'))
scanRange = sign(increment)*abs(scanRange);
set(handles.ScanRange,'String',num2str(scanRange))
end


% --- Executes during object creation, after delay all properties.
function IncrementTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IncrementTime (see GCBO)
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
if isnan(s) || s <= 0 || s > 5
    s = 0.25;
end
delay = s;
set(hObject,'String',num2str(s,'%4.2f'))
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



function ScanRange_Callback(hObject, eventdata, handles)
% hObject    handle to ScanRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScanRange as text
%        str2double(get(hObject,'String')) returns contents of ScanRange as a double
global scanRange increment oneCycle
s = str2double(get(hObject,'String'));
if isnan(s) || abs(s) > 5e4
    s = 15000;
end
scanRange = s;
set(hObject,'String',num2str(scanRange,'%6.1f'))
increment = sign(scanRange)*abs(increment);
set(handles.IncrementCount,'String',num2str(increment))
set(handles.IncrementTime,'String',num2str(increment/(oneCycle*476e-6),'%6.1f'))
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



function OneCycle_Callback(hObject, eventdata, handles)
% hObject    handle to OneCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OneCycle as text
%        str2double(get(hObject,'String')) returns contents of OneCycle as a double
global oneCycle
set(hObject,'String',num2str(oneCycle))
end


% --- Executes during object creation, after setting all properties.
function OneCycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OneCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function CountsNow_Callback(hObject, eventdata, handles)
% hObject    handle to CountsNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CountsNow as text
%        str2double(get(hObject,'String')) returns contents of CountsNow as a double
set(hObject,'String',num2str(lcaGetSmart('DMP:THZ:PHS:01:PHASEVAL')))
end


% --- Executes during object creation, after setting all properties.
function CountsNow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CountsNow (see GCBO)
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
    num2str(lcaGetSmart('DMP:THZ:PHS:01:PHASEVAL')/(oneCycle*476e-6),'%6.1f'))
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
global before start increment delay scanRange oneCycle PauseScan StopScan
PauseScan = 0;
StopScan  = 0;
set(hObject,'String','Running')
set(handles.PauseButton,'Value',0)
set(handles.StopButton,'Value',0)

n = 0;
finish = start + round(scanRange*oneCycle*476e-6);
nSteps = length(start:increment:finish);
while n < nSteps && ~StopScan
    if PauseScan
        pause(1)
    else
        tic
        p = start+increment*n;
        n = n+1;
        s = mod(p,oneCycle);    % Setting of phase shifter
        lcaPutSmart('DMP:THZ:PHS:01:PHASEVAL',s);
        set(handles.CountsNow,'String',num2str(s))
        set(handles.TimeNow,  'String',num2str(p/(oneCycle*476e-6),'%6.1f'))
        pause(max(delay-toc,0.05))
    end
end

before = lcaGetSmart('DMP:THZ:PHS:01:PHASEVAL');
start = before;
set(handles.Before,'String',num2str(before))
set(handles.Start, 'String',num2str(start))
set(handles.CountsNow,'String',num2str(start))
set(handles.TimeNow,  'String',num2str(start/(oneCycle*476e-6),'%6.1f'))
PauseScan = 0;
StopScan  = 0;
set(handles.StartButton,'Value',0,'String','Start')
set(handles.PauseButton,'Value',0,'String','Pause')
set(handles.StopButton,'Value',0)
end
