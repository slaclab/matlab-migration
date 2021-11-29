function varargout = LRoomFarFeedbackGUI(varargin)
% LROOMFARFEEDBACKGUI MATLAB code for LRoomFarFeedbackGUI.fig
%      LROOMFARFEEDBACKGUI, by itself, creates a new LROOMFARFEEDBACKGUI or raises the existing
%      singleton*.
%
%      H = LROOMFARFEEDBACKGUI returns the handle to a new LROOMFARFEEDBACKGUI or the handle to
%      the existing singleton*.
%
%      LROOMFARFEEDBACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LROOMFARFEEDBACKGUI.M with the given input arguments.
%
%      LROOMFARFEEDBACKGUI('Property','Value',...) creates a new LROOMFARFEEDBACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LRoomFarFeedbackGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LRoomFarFeedbackGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LRoomFarFeedbackGUI

% Last Modified by GUIDE v2.5 11-Apr-2015 03:45:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LRoomFarFeedbackGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LRoomFarFeedbackGUI_OutputFcn, ...
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


% --- Executes just before LRoomFarFeedbackGUI is made visible.
function LRoomFarFeedbackGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LRoomFarFeedbackGUI (see VARARGIN)

% Choose default command line output for LRoomFarFeedbackGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LRoomFarFeedbackGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LRoomFarFeedbackGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_feedback.
function start_feedback_Callback(hObject, eventdata, handles)
% hObject    handle to start_feedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('SIOC:SYS1:ML00:AO699',1); % LRoomFarFeedback_stop
pause(1);
lcaPut('SIOC:SYS1:ML00:AO699',0); % LRoomFarFeedback_stop
LRoomFarFeedback;


% --- Executes on button press in stop_feedback.
function stop_feedback_Callback(hObject, eventdata, handles)
% hObject    handle to stop_feedback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPut('SIOC:SYS1:ML00:AO699',1); % LRoomFarFeedback_stop