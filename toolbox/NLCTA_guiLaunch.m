function varargout = NLCTA_guiLaunch(varargin)
% NLCTA_GUILAUNCH M-file for NLCTA_guiLaunch.fig
%      NLCTA_GUILAUNCH, by itself, creates a new NLCTA_GUILAUNCH or raises the existing
%      singleton*.
%
%      H = NLCTA_GUILAUNCH returns the handle to a new NLCTA_GUILAUNCH or the handle to
%      the existing singleton*.
%
%      NLCTA_GUILAUNCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NLCTA_GUILAUNCH.M with the given input arguments.
%
%      NLCTA_GUILAUNCH('Property','Value',...) creates a new NLCTA_GUILAUNCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NLCTA_guiLaunch_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NLCTA_guiLaunch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NLCTA_guiLaunch

% Last Modified by GUIDE v2.5 01-Jun-2011 16:36:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NLCTA_guiLaunch_OpeningFcn, ...
                   'gui_OutputFcn',  @NLCTA_guiLaunch_OutputFcn, ...
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


% --- Executes just before NLCTA_guiLaunch is made visible.
function NLCTA_guiLaunch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NLCTA_guiLaunch (see VARARGIN)

% Choose default command line output for NLCTA_guiLaunch
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NLCTA_guiLaunch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NLCTA_guiLaunch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in launch_corrPlot_btn.
function launch_Callback(hObject, eventdata, handles,tag)
% hObject    handle to launch_corrPlot_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch tag
    case 'match'
        name='matching_gui';
        [hObject, handles] = util_appFind(name);
        matching_gui('appInit',hObject,handles);
    case 'corrPlot'
        name='corrPlot_gui';
        [hObject, handles] = util_appFind(name);
        corrPlot_gui('appInit',hObject,handles);
    case 'emit'
        name='emittance_gui';
        [hObject, handles] = util_appFind(name);
        emittance_gui('appInit',hObject,handles);
    case 'orbit'
        name='orbit_response_full';
        [hObject, handles] = util_appFind(name);
        orbit_response_full('appInit',hObject,handles);
    case 'schottky'
        name='schottky_scan_NLCTA';
        [hObject, handles] = util_appFind(name);
        schottky_scan_NLCTA('appInit',hObject,handles);
    case 'profmon'
        name='profmon_gui';
        [hObject, handles] = util_appFind(name);
        profmon_gui('appInit',hObject,handles);
    case 'ST3RF'
        name='ESBXbandStn3';
        [hObject, handles] = util_appFind(name);
        ESBXbandStn3_OpeningFcn(hObject, [], handles);
end

[hObject, handles] = util_appFind(name);

% --- Executes on button press in launch_corrPlot_btn.
function help_Callback(hObject, eventdata, handles,tag)
% hObject    handle to launch_corrPlot_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd /home/nlcta/matlab/toolbox;
switch tag
    case 'match'
        system(['acroread ' 'Matching_GUI_help.pdf']); 
    case 'corrPlot'
        system(['acroread ' 'Correlation_Plot_GUI_help.pdf']);
    case 'emit'
        system(['acroread ' 'Emittance_GUI_help.pdf']);
    case 'orbit'
        system(['acroread ' 'orbit_response_help.pdf']);
    case 'schottky'
%         system(['ggv ' 'Phase_Scans_help.pdf']);
    case 'profmon'
        system(['acroread ' 'Profmon_GUI_help.pdf']);
end



