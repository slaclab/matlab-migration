function varargout = ULT_SXU_RegularUndulator(varargin)
% ULT_SXU_REGULARUNDULATOR MATLAB code for ULT_SXU_RegularUndulator.fig
%      ULT_SXU_REGULARUNDULATOR, by itself, creates a new ULT_SXU_REGULARUNDULATOR or raises the existing
%      singleton*.
%
%      H = ULT_SXU_REGULARUNDULATOR returns the handle to a new ULT_SXU_REGULARUNDULATOR or the handle to
%      the existing singleton*.
%
%      ULT_SXU_REGULARUNDULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT_SXU_REGULARUNDULATOR.M with the given input arguments.
%
%      ULT_SXU_REGULARUNDULATOR('Property','Value',...) creates a new ULT_SXU_REGULARUNDULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_SXU_RegularUndulator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_SXU_RegularUndulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT_SXU_RegularUndulator

% Last Modified by GUIDE v2.5 16-Jun-2020 14:27:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ULT_SXU_RegularUndulator_OpeningFcn, ...
                   'gui_OutputFcn',  @ULT_SXU_RegularUndulator_OutputFcn, ...
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


% --- Executes just before ULT_SXU_RegularUndulator is made visible.
function ULT_SXU_RegularUndulator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT_SXU_RegularUndulator (see VARARGIN)

% Choose default command line output for ULT_SXU_RegularUndulator
handles.output = hObject;
handles.USEG=varargin{3};
handles.RefPeriod=varargin{4};
handles.UL=varargin{5};
handles.USEG=handles.USEG.f.Useg_Init(handles.USEG);
handles.MAX=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod,'max');
handles.MIN=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod,'min');

ColorOn=[0,1,0]; ColorWait=[1,1,0]; ColorOff=[1,0,0]; Color_CU_SXR=[230/255,184/255,179/255]; Color_CU_HXR=[202/255,214/255,230/255]; Color_FACET=[230,184,179]; Color_Unknown=[0.7,0.7,0.7];
handles.Color_CU_HXR=Color_CU_HXR; handles.Color_CU_SXR=Color_CU_SXR; handles.Color_FACET=Color_FACET; handles.Color_Unknown=Color_Unknown;
handles.ColorOn=ColorOn; handles.ColorOff=ColorOff; handles.ColorWait=ColorWait; handles.ColorLogBook=[0.4,0.4,1];


if(any(strfind(upper(handles.UL.name),'HARD')))
    set_gui_color(handles,handles.Color_CU_HXR);
elseif(any(strfind(upper(handles.UL.name),'SOFT')))
    set_gui_color(handles,handles.Color_CU_SXR);
else
    set_gui_color(handles,handles.Color_Unknown);
end

set(handles.slider1,'SliderStep',[0.0001,0.001]);
set(handles.slider2,'SliderStep',[0.0001,0.001]);
set(handles.slider3,'SliderStep',[0.0001,0.001]);


[K,Kend]=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod);
set(handles.editset,'string',num2str(K));
set(handles.Krbv,'string',num2str(K));

set(handles.slider1,'value',(K-handles.MIN)/(handles.MAX-handles.MIN));
set(handles.slider2,'value',(K-handles.MIN)/(handles.MAX-handles.MIN));
set(handles.slider3,'value',(Kend-handles.MIN)/(handles.MAX-handles.MIN));

set(handles.DeviceName,'string',handles.USEG.PV(1:end));

set(handles.editset2,'string',num2str(K));

set(handles.editset3,'string',num2str(Kend));
set(handles.Krbv_end,'string',num2str(Kend));

handles=DelayRate_Callback(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ULT_SXU_RegularUndulator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ULT_SXU_RegularUndulator_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function set_gui_color(handles,COLOR)
set(handles.figure1,'color',COLOR);
set(handles.text2,'backgroundcolor',COLOR);
set(handles.DeviceName,'backgroundcolor',COLOR);
set(handles.text10,'backgroundcolor',COLOR);
set(handles.text11,'backgroundcolor',COLOR);
set(handles.text12,'backgroundcolor',COLOR);
set(handles.text5,'backgroundcolor',COLOR);
set(handles.text13,'backgroundcolor',COLOR);
set(handles.Krbv,'backgroundcolor',COLOR);
set(handles.Krbv_end,'backgroundcolor',COLOR);
set(handles.text8,'backgroundcolor',COLOR);
set(handles.Datestring,'backgroundcolor',COLOR);

% --- Executes during object creation, after setting all properties.
function DeviceName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DeviceName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
VAL=get(handles.slider1,'value');
K=handles.MIN + VAL*(handles.MAX-handles.MIN);
set(handles.editset,'string',num2str(K));
drawnow
pushbutton1_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editset_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function editset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_consistent_all(handles,TargetK)
set(handles.slider1,'value',handles.MIN + (TargetK(1) - handles.MIN)/(handles.MAX -handles.MIN));
set(handles.editset,'string',num2str(TargetK(1)));

set(handles.slider2,'value',handles.MIN + (TargetK(1) - handles.MIN)/(handles.MAX -handles.MIN));
set(handles.editset2,'string',num2str(TargetK(1)));

set(handles.slider3,'value',handles.MIN + (TargetK(2) - handles.MIN)/(handles.MAX -handles.MIN));
set(handles.editset3,'string',num2str(TargetK(2)));

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[CurrentK,CurrentKend]=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod);
K=str2double(get(handles.editset,'string'));
TargetK=[K,CurrentKend];
Destination=handles.USEG.f.Set_K_struct(handles.USEG,[TargetK(1),TargetK(2)],1,handles.RefPeriod); 
set_consistent_all(handles,TargetK);
handles.UL.f.UndulatorLine_K_set(handles.UL,Destination);


function handles=DelayRate_Callback(hObject, eventdata, handles)
Delay=str2num(get(handles.DelayRate,'string'));
try 
    stop(handles.TIMER)
end
try 
    delete(handles.TIMER)
end
handles.TIMER=timer('StartDelay', 0, 'Period', Delay, 'TasksToExecute', inf, 'ExecutionMode', 'fixedSpacing','Busymode','drop');

%handles.TIMER=timer('StartDelay', 0, 'Period', Delay, 'TasksToExecute', inf, 'ExecutionMode', 'fixedRate');
handles.TIMER.StartFcn = {@Timer_Update,handles,2};
handles.TIMER.StopFcn = {@Timer_Update,handles,0};
handles.TIMER.TimerFcn = {@Timer_Update,handles,1};
handles.TIMER.ErrorFcn = {@Timer_Update,handles,-1};
guidata(hObject, handles);
start(handles.TIMER)


% --- Executes during object creation, after setting all properties.
function DelayRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DelayRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Timer_Update(TimerObject,Type_and_when,handles,MODE)
switch(MODE)
    case -1
        %disp('Timer function called in error mode')
    case 0
        %disp('Timer function called in stop mode')
    case 1
        %disp('Timer function called in normal mode')
        PlotUpdate(handles)
        %e fa anche l'update degli altri!
    case 2
        %disp('Timer function called in start mode')
end

function PlotUpdate(handles)
[K,Kend]=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod);
set(handles.Krbv,'string',num2str(K)); set(handles.Krbv_end,'string',num2str(Kend));
set(handles.Datestring,'string',datestr(now));


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
try 
    stop(handles.TIMER)
end
try 
    delete(handles.TIMER)
end
delete(hObject);


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
VAL=get(handles.slider2,'value');
K=handles.MIN + VAL*(handles.MAX-handles.MIN);
set(handles.editset2,'string',num2str(K));
drawnow
pushbutton2_Callback(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editset2_Callback(hObject, eventdata, handles)
% hObject    handle to editset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editset2 as text
%        str2double(get(hObject,'String')) returns contents of editset2 as a double


% --- Executes during object creation, after setting all properties.
function editset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
[CurrentK,CurrentKend]=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod);
K=str2double(get(handles.editset2,'string'));
TargetK=[K,K+CurrentKend-CurrentK];
Destination=handles.USEG.f.Set_K_struct(handles.USEG,[TargetK(1),TargetK(2)],1,handles.RefPeriod); 
set_consistent_all(handles,TargetK);
handles.UL.f.UndulatorLine_K_set(handles.UL,Destination);


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
VAL=get(handles.slider3,'value');
K=handles.MIN + VAL*(handles.MAX-handles.MIN);
set(handles.editset3,'string',num2str(K));
drawnow
pushbutton3_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editset3_Callback(hObject, eventdata, handles)
% hObject    handle to editset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editset3 as text
%        str2double(get(hObject,'String')) returns contents of editset3 as a double


% --- Executes during object creation, after setting all properties.
function editset3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editset3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
[CurrentK,CurrentKend]=handles.USEG.f.Get_K(handles.USEG,handles.RefPeriod);
K=str2double(get(handles.editset3,'string'));
TargetK=[CurrentK(1),K];
Destination=handles.USEG.f.Set_K_struct(handles.USEG,[TargetK(1),TargetK(2)],1,handles.RefPeriod); 
set_consistent_all(handles,TargetK);
handles.UL.f.UndulatorLine_K_set(handles.UL,Destination);


% --- Executes on button press in closefunction.
function closefunction_Callback(hObject, eventdata, handles)
try 
    stop(handles.TIMER)
end
try
    delete(handles.TIMER)
end
close(handles.figure1);
