function varargout = undulatorHome(varargin)
% UNDULATORHOME M-file for undulatorHome.fig
%      UNDULATORHOME, by itself, creates a new UNDULATORHOME or raises the existing
%      singleton*.
%
%      H = UNDULATORHOME returns the handle to a new UNDULATORHOME or the handle to
%      the existing singleton*.
%
%      UNDULATORHOME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNDULATORHOME.M with the given input arguments.
%
%      UNDULATORHOME('Property','Value',...) creates a new UNDULATORHOME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before undulatorHome_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to undulatorHome_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help undulatorHome

% Last Modified by GUIDE v2.5 02-Jun-2009 17:19:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @undulatorHome_OpeningFcn, ...
                   'gui_OutputFcn',  @undulatorHome_OutputFcn, ...
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


% --- Executes just before undulatorHome is made visible.
function undulatorHome_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to undulatorHome (see VARARGIN)

% Choose default command line output for undulatorHome
handles.output = hObject;

% Save initial cams and tapers
geo = girderGeo();
za= geo.quadz;
zb= geo.bfwz;
[pa, pb, roll] = girderAxisFind(1:33, za, zb);
handles.paInit = pa;
handles.pbInit = pb;
handles.rollInit = roll;
handles.taperInit = segmentTranslate();


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes undulatorHome wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = undulatorHome_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Home.
function Home_Callback(hObject, eventdata, handles)
% hObject    handle to Home (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

status = get(handles.Home,'String');

switch status
    case 'Go to Home'
        % move everthing to home
        display('Moving all cams and translation stages to zero');
        girderCamSet(1:33,[0 0 0 0 0]);
        segmentTranslate(0*handles.taperInit);
        set(handles.Home,'String', 'Moving cams and segments...');
        pause(.5);
        segmentTranslateWait;
        % change button label
        set(handles.Home,'String', 'Restore');
    case 'Restore'
        % move back to where it stared
        display('Moving all cams and translation stages to intial settings');
        girderAxisSet(1:33, handles.paInit, handles.pbInit, handles.rollInit);
        segmentTranslate(handles.taperInit);
        set(handles.Home,'String', 'Moving cams and segments...');
        pause(.5);
        segmentTranslateWait;
        % change button label
        set(handles.Home,'String', 'Go to Home');
end

% Update handles structure
guidata(hObject, handles);

