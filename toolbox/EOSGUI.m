function varargout = EOSGUI(varargin)
% EOSGUI MATLAB code for EOSGUI.fig
%      EOSGUI, by itself, creates a new EOSGUI or raises the existing
%      singleton*.
%
%      H = EOSGUI returns the handle to a new EOSGUI or the handle to
%      the existing singleton*.
%
%      EOSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EOSGUI.M with the given input arguments.
%
%      EOSGUI('Property','Value',...) creates a new EOSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EOSGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EOSGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EOSGUI

% Last Modified by GUIDE v2.5 17-Jan-2016 22:01:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EOSGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @EOSGUI_OutputFcn, ...
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


% --- Executes just before EOSGUI is made visible.
function EOSGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EOSGUI (see VARARGIN)

% Choose default command line output for EOSGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

CalibrationValueReadout=lcaGet('SIOC:SYS1:ML00:CALC171');
set(handles.Calibration_value,'String',num2str(CalibrationValueReadout));


% UIWAIT makes EOSGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EOSGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
lcaPut('SIOC:SYS1:ML00:CALC172',0); % set  EOS_Timing_stop to running
TimingValueIter=0;
%timinglist();
while true
    TimingValueIter=TimingValueIter+1;
    if (TimingValueIter==1000)
        TimingValueIter=1;
    end
  if (lcaGet('SIOC:SYS1:ML00:CALC172'))
     break;
  end
  timingval=EOSLO;
  set(handles.Timing_text,'String',[num2str(timingval) ' ps']);
  timinglist(:,TimingValueIter)=timingval;
  meantiming=mean(timinglist);
  stdtiming=std(timinglist);
  set(handles.MeanTimingText,'String',[num2str(meantiming) ' ps']);
  set(handles.StdTimingText,'String',[num2str(stdtiming) ' ps']);
  TimingValueIter
end;

% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in endbutton.
function endbutton_Callback(hObject, eventdata, handles)
lcaPut('SIOC:SYS1:ML00:CALC172',1)
clear timinglist;
% hObject    handle to endbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Calibration_value_Callback(hObject, eventdata, handles)
% hObject    handle to Calibration_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Calibration_value as text
%        str2double(get(hObject,'String')) returns contents of Calibration_value as a double


% --- Executes during object creation, after setting all properties.
function Calibration_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Calibration_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in set_calib_button.
function set_calib_button_Callback(hObject, eventdata, handles)
CalibrationValue=get(handles.Calibration_value,'String');
lcaPut('SIOC:SYS1:ML00:CALC171',CalibrationValue);
% hObject    handle to set_calib_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
