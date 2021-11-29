function varargout = LEM_SelectGroupGUI(varargin)
% LEM_SELECTGROUPGUI M-file for LEM_SelectGroupGUI.fig
%      LEM_SELECTGROUPGUI, by itself, creates a new LEM_SELECTGROUPGUI or raises the existing
%      singleton*.
%
%      H = LEM_SELECTGROUPGUI returns the handle to a new LEM_SELECTGROUPGUI or the handle to
%      the existing singleton*.
%
%      LEM_SELECTGROUPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEM_SELECTGROUPGUI.M with the given input arguments.
%
%      LEM_SELECTGROUPGUI('Property','Value',...) creates a new LEM_SELECTGROUPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LEM_SelectGroupGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LEM_SelectGroupGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LEM_SelectGroupGUI

% Last Modified by GUIDE v2.5 28-Oct-2008 16:04:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LEM_SelectGroupGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LEM_SelectGroupGUI_OutputFcn, ...
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


% --- Executes just before LEM_SelectGroupGUI is made visible.
function LEM_SelectGroupGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LEM_SelectGroupGUI (see VARARGIN)

% Initialize flags array
handles.groupFlags = varargin{1};
set(handles.checkbox1, 'Value', handles.groupFlags(2)) % Non-Undulator XCORs and YCORs
set(handles.checkbox2, 'Value', handles.groupFlags(3)) % Undulator XCORs and YCORs
set(handles.checkbox3, 'Value', handles.groupFlags(4)) % Undulator QUADs

% Choose default command line output for LEM_SelectGroupGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LEM_SelectGroupGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LEM_SelectGroupGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Return the (possibly) modified flags array
varargout{1} = handles.groupFlags;

% Close the GUI window on the way out ... bye!
close(handles.figure1)


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.groupFlags(2) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
handles.groupFlags(3) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
handles.groupFlags(4) = get(hObject, 'Value');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% return control to caller
uiresume(handles.figure1);

