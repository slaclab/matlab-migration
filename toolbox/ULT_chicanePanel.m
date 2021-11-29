function varargout = ULT_chicanePanel(varargin)
% ULT_CHICANEPANEL MATLAB code for ULT_chicanePanel.fig
%      ULT_CHICANEPANEL, by itself, creates a new ULT_CHICANEPANEL or raises the existing
%      singleton*.
%
%      H = ULT_CHICANEPANEL returns the handle to a new ULT_CHICANEPANEL or the handle to
%      the existing singleton*.
%
%      ULT_CHICANEPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT_CHICANEPANEL.M with the given input arguments.
%
%      ULT_CHICANEPANEL('Property','Value',...) creates a new ULT_CHICANEPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_chicanePanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_chicanePanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT_chicanePanel

% Last Modified by GUIDE v2.5 14-Jul-2021 10:58:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ULT_chicanePanel_OpeningFcn, ...
                   'gui_OutputFcn',  @ULT_chicanePanel_OutputFcn, ...
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


% --- Executes just before ULT_chicanePanel is made visible.
function ULT_chicanePanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT_chicanePanel (see VARARGIN)

% Choose default command line output for ULT_chicanePanel
handles.output = hObject;
handles.USEG=varargin{3};
handles.RefPeriod=varargin{4};
handles.UL=varargin{5};
handles.USEG=handles.USEG.f.Useg_Init(handles.USEG);

status=handles.BEND.f.get_Status(handles.BEND,handles.UL);
handles.ENERGY=status.Energy;
set(handles.ENEVALUE,'string',num2str(status.ENERGY));
set(handles.ENEVALUE,'UserData',status.Energy);
handles.BMAX=lcaGetSmart(strcat(handles.BEND.PVs{1},':BMAX'));
update_minmax(handles);

ColorOn=[0,1,0]; ColorWait=[1,1,0]; ColorOff=[1,0,0]; Color_CU_SXR=[230/255,184/255,179/255]; Color_CU_HXR=[202/255,214/255,230/255]; Color_FACET=[230,184,179]; Color_Unknown=[0.7,0.7,0.7];
handles.Color_CU_HXR=Color_CU_HXR; handles.Color_CU_SXR=Color_CU_SXR; handles.Color_FACET=Color_FACET; handles.Color_Unknown=Color_Unknown;
handles.ColorOn=ColorOn; handles.ColorOff=ColorOff; handles.ColorWait=ColorWait; handles.ColorLogBook=[0.4,0.4,1]; handles.ColorIdle=get(handles.closefunction,'backgroundcolor');


if(any(strfind(upper(handles.UL.name),'HARD')))
    set_gui_color(handles,handles.Color_CU_HXR);
elseif(any(strfind(upper(handles.UL.name),'SOFT')))
    set_gui_color(handles,handles.Color_CU_SXR);
else
    set_gui_color(handles,handles.Color_Unknown);
end

set(handles.DeviceName,'string',handles.USEG.PV(1:end));

handles=DelayRate_Callback(hObject, eventdata, handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ULT_chicanePanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ULT_chicanePanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function update_minmax(handles)
MIN=0; MAX=50;
if(any(strfind(handles.BEND.BCSS_AdjustString,'SXRSS')))
    MIN=0; MAX=1400;
end
if(any(strfind(handles.BEND.BCSS_AdjustString,'HXRSS')))
    MIN=0; MAX=50;
end
Energy=get(handles.ENEVALUE,'UserData');
ACTUALMAX=handles.BEND.f.calculate_delay(handles.BMAX,BEND.Lm,BEND.dL,Energy);
if(ACTUALMAX<MAX)
    MAX=ACTUALMAX;
end
set(handles.min,num2str(MIN,'%g'));set(handles.min,'UserData',MIN);
set(handles.max,num2str(MAX,'%g'));set(handles.max,'UserData',MAX);



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

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value');
TargetDelay=str2double(get(handles.editset,'string'));
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1;
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end


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
status=handles.BEND.f.get_Status(handles.BEND,handles.UL);
set(handles.ENEVALUE,'string',num2str(status.ENERGY,'%g'));
set(handles.ENEVALUE,'UserData',status.Energy);
update_minmax(handles);
set(handles.Krbv,'string',num2str(status.delay,'%g'));
set(handles.MBACT,'string',num2str(status.MainBACT,'%g'));
set(handles.MBDES,'string',num2str(status.MainBDES,'%g'));
set(handles.MBCTRL,'string',num2str(status.MainBCTRL,'%g'));
if(iscell(status.PowerSupplyState))
    if(strcmp(status.PowerSupplyState{1},'ON'))
        set(handles.PowerSupplyString,'Power supply ON','backgroundcolor',[0,1,0]); 
    else
        set(handles.PowerSupplyString,'Power supply OFF','backgroundcolor',[1,0,0]); 
    end
else
   set(handles.PowerSupplyString,'Power supply state not returned cell','backgroundcolor',[1,0,0]); 
end
for II=1:4
    set(handles.(['M',num2str(II),'BACT']),'string',num2str(status.AllMainBACT(II),'%g'));
    set(handles.(['T',num2str(II),'ACT']),'string',num2str(status.TrimBACT(II),'%g'));
    set(handles.(['T',num2str(II),'DES']),'string',num2str(status.TrimBDES(II),'%g'));
    set(handles.(['T',num2str(II),'BCTRL']),'string',num2str(status.TrimBCTRL(II),'%g'));
end
set(handles.R56VAL,'string',num2str(status.xpos,'%g'));
set(handles.X0VAL,'string',num2str(status.R56,'%g'));
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

% --- Executes on button press in closefunction.
function closefunction_Callback(hObject, eventdata, handles)
try 
    stop(handles.TIMER)
end
try
    delete(handles.TIMER)
end
close(handles.figure1);


% --- Executes on button press in RT.
function RT_Callback(hObject, eventdata, handles)
% hObject    handle to RT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RT


% --- Executes on button press in P1.
function P1_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value'); DELTA=str2double(get(handles.P1C,'string'));
TargetDelay=str2double(get(handles.editset,'string')) + DELTA; set(handles.editset,'string',num2str(TargetDelay,'%g'))
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1; 
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end


% --- Executes on button press in P2.
function P2_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value'); DELTA=str2double(get(handles.P2C,'string'));
TargetDelay=str2double(get(handles.editset,'string')) + DELTA; set(handles.editset,'string',num2str(TargetDelay,'%g'))
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1; 
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end


% --- Executes on button press in P3.
function P3_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value'); DELTA=str2double(get(handles.P3C,'string'));
TargetDelay=str2double(get(handles.editset,'string')) + DELTA; set(handles.editset,'string',num2str(TargetDelay,'%g'))
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1; 
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end



function P1V_Callback(hObject, eventdata, handles)
% hObject    handle to P1V (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P1V as text
%        str2double(get(hObject,'String')) returns contents of P1V as a double


% --- Executes during object creation, after setting all properties.
function P1V_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P1V (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P2C_Callback(hObject, eventdata, handles)
% hObject    handle to P2C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P2C as text
%        str2double(get(hObject,'String')) returns contents of P2C as a double


% --- Executes during object creation, after setting all properties.
function P2C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P2C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P3C_Callback(hObject, eventdata, handles)
% hObject    handle to P3C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P3C as text
%        str2double(get(hObject,'String')) returns contents of P3C as a double


% --- Executes during object creation, after setting all properties.
function P3C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P3C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in M3.
function M3_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value'); DELTA=str2double(get(handles.M3C,'string'));
TargetDelay=str2double(get(handles.editset,'string')) + DELTA; set(handles.editset,'string',num2str(TargetDelay,'%g'))
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1; 
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end


% --- Executes on button press in M2.
function M2_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value'); DELTA=str2double(get(handles.M2C,'string'));
TargetDelay=str2double(get(handles.editset,'string')) + DELTA; set(handles.editset,'string',num2str(TargetDelay,'%g'))
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1; 
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end


% --- Executes on button press in M1.
function M1_Callback(hObject, eventdata, handles)
status=handles.BEND.f.get_Status(handles.BEND,handles.UL); Relative=get(handles.RT,'value'); DELTA=str2double(get(handles.M1C,'string'));
TargetDelay=str2double(get(handles.editset,'string')) + DELTA; set(handles.editset,'string',num2str(TargetDelay,'%g'))
Energy=get(handles.ENEVALUE,'UserData'); no=0;
MIN=get(handles.min,'UserData'); MAX=get(handles.max,'UserData');
if((TargetDelat<=MAX) && (TargetDelat>=MIN))
    if(status.PowerSupplyState)
        handles.BEND.f.set_Delay(handles.BEND,handles.UL,TargetDelay,Relative);
    else
       disp('Chicane is off.'); no=1; 
    end
else
   disp(['Required delay = ',num2str(TargetDelay),' is out of range. Max = ',num2str(MAX),'. Min = ',num2str(MIN),' at Energy of ',num2str(Energy),' GeV']); no=1;
end
if(no)
    set(handles.hObject,'backgroundcolor',handles.ColorOff); pause(1); set(handles.hObject,'backgroundcolor',handles.ColorIdle);
end



function M3C_Callback(hObject, eventdata, handles)
% hObject    handle to M3C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M3C as text
%        str2double(get(hObject,'String')) returns contents of M3C as a double


% --- Executes during object creation, after setting all properties.
function M3C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M3C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function M2C_Callback(hObject, eventdata, handles)
% hObject    handle to M2C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M2C as text
%        str2double(get(hObject,'String')) returns contents of M2C as a double


% --- Executes during object creation, after setting all properties.
function M2C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M2C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function M1C_Callback(hObject, eventdata, handles)
% hObject    handle to M1C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M1C as text
%        str2double(get(hObject,'String')) returns contents of M1C as a double


% --- Executes during object creation, after setting all properties.
function M1C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M1C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
