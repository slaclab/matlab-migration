function varargout = example_multiple_axes(varargin)
% EXAMPLE_MULTIPLE_AXES M-file for example_multiple_axes.fig
%      EXAMPLE_MULTIPLE_AXES, by itself, creates a new EXAMPLE_MULTIPLE_AXES or raises the existing
%      singleton*.
%
%      H = EXAMPLE_MULTIPLE_AXES returns the handle to a new EXAMPLE_MULTIPLE_AXES or the handle to
%      the existing singleton*.
%
%      EXAMPLE_MULTIPLE_AXES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXAMPLE_MULTIPLE_AXES.M with the given input arguments.
%
%      EXAMPLE_MULTIPLE_AXES('Property','Value',...) creates a new EXAMPLE_MULTIPLE_AXES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before example_multiple_axes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to example_multiple_axes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help example_multiple_axes

% Last Modified by GUIDE v2.5 24-Feb-2008 13:49:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @example_multiple_axes_OpeningFcn, ...
    'gui_OutputFcn',  @example_multiple_axes_OutputFcn, ...
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


% --- Executes just before example_multiple_axes is made visible.
function example_multiple_axes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to example_multiple_axes (see VARARGIN)

% Choose default command line output for example_multiple_axes
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes example_multiple_axes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = example_multiple_axes_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp('GO',get(handles.pushbutton1,'String'))
    set(handles.pushbutton1,'String','STOP');
else
    set(handles.pushbutton1,'String','GO');
end

while(strcmp('STOP',get(handles.pushbutton1,'String')))
    axes(handles.axes1);
    plot(rand(3));
    axes(handles.axes2);
    plot(rand(6));
    pause(1.0);
end
