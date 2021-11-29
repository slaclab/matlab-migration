function varargout = LEM_SelectRegionGUI(varargin)
% LEM_SELECTREGIONGUI M-file for LEM_SelectRegionGUI.fig
%      LEM_SELECTREGIONGUI, by itself, creates a new LEM_SELECTREGIONGUI or raises the existing
%      singleton*.
%
%      H = LEM_SELECTREGIONGUI returns the handle to a new LEM_SELECTREGIONGUI or the handle to
%      the existing singleton*.
%
%      LEM_SELECTREGIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEM_SELECTREGIONGUI.M with the given input arguments.
%
%      LEM_SELECTREGIONGUI('Property','Value',...) creates a new LEM_SELECTREGIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LEM_SelectRegionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LEM_SelectRegionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LEM_SelectRegionGUI

% Last Modified by GUIDE v2.5 04-Dec-2008 09:22:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LEM_SelectRegionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LEM_SelectRegionGUI_OutputFcn, ...
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


% --- Executes just before LEM_SelectRegionGUI is made visible.
function LEM_SelectRegionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LEM_SelectRegionGUI (see VARARGIN)

% Initialize flags array
handles.regionFlags = varargin{1};
set(handles.checkbox1, 'Value', handles.regionFlags(1)) % Gun to BX02 (L0)
set(handles.checkbox2, 'Value', handles.regionFlags(2)) % BX02 to QM15 (L1)
set(handles.checkbox3, 'Value', handles.regionFlags(3)) % QM15 to BC2 (L2)
set(handles.checkbox4, 'Value', handles.regionFlags(4)) % BC2 to 50B1 (L3)
set(handles.checkbox5, 'Value', handles.regionFlags(5)) % 50B1 to dump (LTU)
set(handles.checkbox6, 'Value', handles.regionFlags(6)) % Gun Spectrometer
set(handles.checkbox7, 'Value', handles.regionFlags(7)) % 135 MeV Spectrometer
set(handles.checkbox8, 'Value', handles.regionFlags(8)) % 52 Line

% Choose default command line output for LEM_SelectRegionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LEM_SelectRegionGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LEM_SelectRegionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Return the (possibly) modified flags array
varargout{1} = handles.regionFlags;

% Close the GUI window on the way out ... bye!
close(handles.figure1)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.regionFlags(1) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
handles.regionFlags(2) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
handles.regionFlags(3) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
handles.regionFlags(4) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
handles.regionFlags(5) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
handles.regionFlags(6) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
handles.regionFlags(7) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
handles.regionFlags(8) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% return control to caller
uiresume(handles.figure1);


