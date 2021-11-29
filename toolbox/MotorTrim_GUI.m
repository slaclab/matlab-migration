function varargout = MotorTrim_GUI(varargin)
% MotorTrim_GUI M-file for MotorTrim_GUI.fig
%  
%
%       J. Turner 14 Feb 2011
%       R. Coy    24 May 2011
%
%
%
%
%
%
%      MotorTrim_GUI, by itself, creates a new MotorTrim_GUI or raises the
%      existing
%      singleton*.
%
%      H = MotorTrim_GUI returns the handle to a new MotorTrim_GUI or the handle to
%      the existing singleton*.
%
%      MotorTrim_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MotorTrim_GUI.M with the given input arguments.
%
%      MotorTrim_GUI('Property','Value',...) creates a new MotorTrim_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MotorTrim_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MotorTrim_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MotorTrim_GUI

% Last Modified by GUIDE v2.5 13-May-2011 12:22:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MotorTrim_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MotorTrim_GUI_OutputFcn, ... 
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


% --- Executes just before MotorTrim_GUI is made visible.
function MotorTrim_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Three member device input array
% Column 1 - Description
% Column 2 - Motor PV
% Column 3 - LVDT Readback PV
% Column 4 - LVDT Step Size
% Column 5 - Tolerence
deviceArray={...
% XRAY MIRRORS COMMENDED OUT
     'M1S Position','STEP:FEE1:1561:MOTR','LVDT:FEE1:1561', 0.8, 2;
     'M1S Angle','STEP:FEE1:1562:MOTR','LVDT:FEE1:1562', 2.5, 4;
     'M2S Position','STEP:FEE1:1661:MOTR','LVDT:FEE1:1661', 0.8, 2;
     'M2S Angle','STEP:FEE1:1662:MOTR','LVDT:FEE1:1662', 2.5, 4;
     'M3S1/2 Position','STEP:FEE1:1811:MOTR','LVDT:FEE1:1811', 0.8, 2;
     'M3S1/2 Angle','STEP:FEE1:1812:MOTR','LVDT:FEE1:1812', 2.5, 4;
     'M1H Position','STEP:FEE1:611:MOTR','LVDT:FEE1:611', 0.8, 2;
     'M1H Angle','STEP:FEE1:612:MOTR','LVDT:FEE1:612', 2.5, 4;
     'M2H Position','STEP:FEE1:861:MOTR','LVDT:FEE1:861', 0.8, 2;
     'M2H Angle','STEP:FEE1:862:MOTR','LVDT:FEE1:862', 2.5, 4;
     'Xray Slit Right' ,'STEP:FEE1:151:MOTR','LVDT:FEE1:151', 0.0015, 0.015;
     'Xray Slit Left'  ,'STEP:FEE1:152:MOTR','LVDT:FEE1:152', 0.0015, 0.015;
     'Xray Slit Bottom','STEP:FEE1:153:MOTR','LVDT:FEE1:153', 0.0015, 0.015;
     'Xray Slit Top'   ,'STEP:FEE1:154:MOTR','LVDT:FEE1:154', 0.0015, 0.015;
    };


handles.ROOT_NAME=deviceArray(:,1); %Decription

handles.PVMotrRBV=deviceArray(:,2); %PV MotorReadback

handles.PVMotrVAL=deviceArray(:,2); %PV MotorSetpoint

handles.PVMotrOFF=deviceArray(:,2); %PV MotorOffset

handles.PVMotrDBD=deviceArray(:,2); %PV MotorDeadband

handles.PVMotrEGU=deviceArray(:,2); %PV MotorEGU

handles.PVLvdtRBV=deviceArray(:,3); %PV LVDTReadback

handles.PVLvdtPoll=deviceArray(:,3); %PV LVDTPollRate

handles.DeviceLvdtStep=deviceArray(:,4); %Device LVDT Step Size

handles.DeviceTol=deviceArray(:,5); %Device Tolerance

handles.PVMotrRBV= strcat(handles.PVMotrRBV, '.RBV');
handles.PVMotrVAL= strcat(handles.PVMotrVAL, '.VAL');
handles.PVMotrOFF= strcat(handles.PVMotrOFF, '.OFF');
handles.PVMotrDBD= strcat(handles.PVMotrDBD, '.RDBD');
handles.PVMotrEGU= strcat(handles.PVMotrEGU, '.EGU');
handles.PVLvdtRBV= strcat(handles.PVLvdtRBV, ':LVPOS');
handles.PVLvdtPoll=strcat(handles.PVLvdtPoll,':LVSCANRATE');

set(handles.num_trims,'string',5);

%
% Initiate variable1
%
set( handles.variable1, 'String', handles.ROOT_NAME );
handles.foundVar1Indx = 1:1:length(handles.ROOT_NAME);
%
% Initiate Other Variables
handles.des = str2double(get(handles.desired_value,'string'));
handles.n_trims = str2double(get(handles.num_trims,'string'));
handles.tols = str2double(get(handles.tolerance_value,'string'));
%
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MotorTrim_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes when user attempts to close MotorTrimFigure.
function MotorTrimFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MotorTrimFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
util_appClose(hObject);


% --- Executes on selection change in variable1.
function variable1_Callback(hObject, eventdata, handles)
% hObject    handle to variable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns variable1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variable1
% example handles.lvdt       = lcaGetSmart(handles.lvdt_pv);                  % um

handles.choice = get(hObject, 'Value');
[handles.lvdt, handles.motr, handles.des, handles.tols, ...
    handles.MotorDB, handles.units, handles.n_trims] = variable1_refresh(handles);
guidata(hObject, handles);


function [lvdt, motr, des_value, tols, MotorDB, units, n_trims] = variable1_refresh(handles)
num_ave=5;

pollrate = lcaGetSmart(handles.PVLvdtPoll(handles.choice));
lvdt=0;
for i = 1:1:num_ave
    lvdt = lcaGetSmart(handles.PVLvdtRBV(handles.choice)) + lvdt;
    if pollrate ~= 0
        pause(1/pollrate);
    end
end
lvdt = lvdt/num_ave;
set(handles.LVDT_value,'string',sprintf('%1.4f',lvdt))

motr = lcaGetSmart(handles.PVMotrRBV(handles.choice));
set(handles.Motor_value,'string',sprintf('%1.4f',motr))

des_value = lcaGetSmart(handles.PVMotrVAL(handles.choice));
set(handles.desired_value,'string',sprintf('%1.3f',des_value))

% Set Default Tolerane
MotorDB = 2.*lcaGetSmart(handles.PVMotrDBD(handles.choice));
%set(handles.tolerance_value,'string',sprintf('%1.1f',MotorDB))
%tols = MotorDB;
set(handles.tolerance_value, 'string',handles.DeviceTol(handles.choice));
tols = cell2mat(handles.DeviceTol(handles.choice));

% Calculate Errors
Set_error = des_value - lvdt;
set(handles.Set_Error_Value,'string',sprintf('%1.3f',Set_error))
L_M_error = motr - lvdt;
set(handles.Motor_LVDT_Error_value,'string',sprintf('%1.3f',L_M_error))

% Error Colors
if (abs(Set_error) > abs(tols)) 
    set(handles.Set_Error_Value_HL,'BackgroundColor','red');
else
    set(handles.Set_Error_Value_HL,'BackgroundColor','green');
end

if (abs(L_M_error) > abs(tols))
    set(handles.LVDT_Motor_Value_HL,'BackgroundColor','red');
else 
    set(handles.LVDT_Motor_Value_HL,'BackgroundColor','green');
end

% Set Correct Units on Display
units = lcaGetSmart(handles.PVMotrEGU(handles.choice));

set(handles.LVDT_units,'string',units);
set(handles.Motor_units,'string',units);
set(handles.Des_units,'string',units);
set(handles.Tol_units,'string',units);
set(handles.Set_units,'string',units);
set(handles.Error_units,'string',units);

n_trims = str2double(get(handles.num_trims,'string'));

% --- Executes during object creation, after setting all properties.
function variable1_CreateFcn(hObject, eventdata, handles)

function variable1_KeyPressFcn(hObject, eventdata, handles)

function num_trims_Callback(hObject, eventdata, handles)
if mod(str2double(get(hObject,'string')),1) ~= 0
    msgbox ('Please enter an integer number of trims');
    set(hObject,'string','');
    return;
end

handles.n_trims = str2double(get(hObject,'String'));
guidata(hObject, handles);

function num_trims_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '3');
guidata(hObject, handles);

function desired_value_Callback(hObject, eventdata, handles)
    
handles.des = desired_value_refresh(handles);
guidata(hObject, handles);

function des = desired_value_refresh(handles)

des = str2double(get(handles.desired_value,'String'));

% Calculate Errors
Set_error = des - handles.lvdt;
set(handles.Set_Error_Value,'string',sprintf('%1.3f',Set_error))

% Error Colors
if (abs(Set_error) > abs(handles.tols)) 
    set(handles.Set_Error_Value_HL,'BackgroundColor','red');
else
    set(handles.Set_Error_Value_HL,'BackgroundColor','green');
end

function desired_value_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '1');
guidata(hObject, handles);

function tolerance_value_Callback(hObject, eventdata, handles)
if ~(str2double(get(hObject,'string')) > 0)
    msgbox ('Please enter a small positive tolerence');
    set(hObject,'string','');
    return;
end

if str2double(get(hObject,'string')) < (handles.MotorDB/2)
    msgbox (['Tolerance is less than motor deadband. Deadband = ' num2str(handles.MotorDB/2)])
end

handles.tols = str2double(get(hObject,'String'));

% Calculate Errors
Set_error = handles.des - handles.lvdt;
set(handles.Set_Error_Value,'string',sprintf('%1.3f',Set_error))
L_M_error = handles.motr - handles.lvdt;
set(handles.Motor_LVDT_Error_value,'string',sprintf('%1.3f',L_M_error))

% Error Colors
if (abs(Set_error) > abs(handles.tols)) 
    set(handles.Set_Error_Value_HL,'BackgroundColor','red');
else
    set(handles.Set_Error_Value_HL,'BackgroundColor','green');
end

if (abs(L_M_error) > abs(handles.tols))
    set(handles.LVDT_Motor_Value_HL,'BackgroundColor','red');
else 
    set(handles.LVDT_Motor_Value_HL,'BackgroundColor','green');
end

guidata(hObject, handles);

function tolerance_value_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '1');
guidata(hObject, handles);

% --- Executes on Trim_button press.
function Trim_button_Callback(hObject, eventdata, handles)
%
% Change Button Readout "Trimming"
set( hObject, 'Value', 0 );
set( hObject, 'String', 'Trimming' );
%
% Trim algorithm
%
% look at LVDT and Desired
% delta to motor

des = handles.des;

tols = handles.tols./1000;
n_trims = handles.n_trims;

for itry = 1:1:n_trims
   lvdt = str2double(get(handles.LVDT_value,'string'));
   motor = str2double(get(handles.Motor_value,'string'));
   delta = des - lvdt;
   
   disp(['NumTrims ' num2str(itry) ' Error ' num2str(delta)])

   % Verify Position Outside Tolerence
   if (abs(delta) < tols)
       break;
   end
   
   % Move To New Position
   new_motor = motor + delta;
   lcaSetTimeout(0.5);
   lcaPutSmart(handles.PVMotrVAL(handles.choice),new_motor);
   
   % Wait until LVDT stops or 1 minute
   LVDT_pos1 = lvdt;
   for waitval = 1:1:120
        pause(0.5);
        
        % Update Readback of Motor and Lvdt
        handles.lvdt = lcaGetSmart(handles.PVLvdtRBV(handles.choice));
        set(handles.LVDT_value,'string',sprintf('%1.4f',handles.lvdt))
        handles.motr = lcaGetSmart(handles.PVMotrRBV(handles.choice));
        set(handles.Motor_value,'string',sprintf('%1.4f',handles.motr))
   
        % Recalc Errors
        Set_error = handles.des - handles.lvdt;
        set(handles.Set_Error_Value,'string',sprintf('%1.3f',Set_error))
        L_M_error = handles.motr - handles.lvdt;
        set(handles.Motor_LVDT_Error_value,'string',sprintf('%1.3f',L_M_error))
   
        % Error Colors
        if (abs(Set_error) > abs(handles.tols)) 
            set(handles.Set_Error_Value_HL,'BackgroundColor','red');
        else
            set(handles.Set_Error_Value_HL,'BackgroundColor','green');
        end

        if (abs(L_M_error) > abs(handles.tols))
            set(handles.LVDT_Motor_Value_HL,'BackgroundColor','red');
        else 
            set(handles.LVDT_Motor_Value_HL,'BackgroundColor','green');
        end
        
        LVDT_pos2 = handles.lvdt;
        %Check is LVDT difference is less than 2x LVDT Steps
        if (LVDT_pos2 - LVDT_pos1) < (cell2mat(handles.DeviceLvdtStep(handles.choice))/500)
            break;
        end
        LVDT_pos1 = LVDT_pos2;
        set( hObject, 'String', ['Trimming ',num2str(waitval/2)] );
   end
end
%
% Return Button Readout "TRIM"
set( hObject, 'Value', 0 );
set( hObject, 'String', 'Done' );
pause(1);
set( hObject, 'String', 'TRIM' );
%
guidata(hObject, handles);


% --- Executes on Green_Motor button press.
function green_motor_Callback(hObject, eventdata, handles)
set( hObject, 'Value', 0 );
set( hObject, 'String', 'Greening' );
%
% Greening algorithm
lvdt = str2double(get(handles.LVDT_value,'string'));
motor = str2double(get(handles.Motor_value,'string'));
offset = lcaGetSmart(handles.PVMotrOFF(handles.choice));

offset = offset - motor + lvdt;
lcaPutSmart(handles.PVMotrOFF(handles.choice),offset);
pause(1);
% Update Readback of Motor
handles.motr = lcaGetSmart(handles.PVMotrRBV(handles.choice));
set(handles.Motor_value,'string',sprintf('%1.4f',handles.motr))

% Recalc Errors
Set_error = handles.des - handles.lvdt;
set(handles.Set_Error_Value,'string',sprintf('%1.3f',Set_error))
L_M_error = handles.motr - handles.lvdt;
set(handles.Motor_LVDT_Error_value,'string',sprintf('%1.3f',L_M_error))

% Error Colors
if (abs(Set_error) > abs(handles.tols)) 
    set(handles.Set_Error_Value_HL,'BackgroundColor','red');
else
    set(handles.Set_Error_Value_HL,'BackgroundColor','green');
end

if (abs(L_M_error) > abs(handles.tols))
    set(handles.LVDT_Motor_Value_HL,'BackgroundColor','red');
else 
    set(handles.LVDT_Motor_Value_HL,'BackgroundColor','green');
end


%
set( hObject, 'String', 'Green Motor' );
%
guidata(hObject, handles);
guidata(handles.output, handles);


% --- Executes on button press in AMO_button.
function AMO_button_Callback(hObject, eventdata, handles)
% NO CURRENT FUNCTION

% hObject    handle to AMO_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Mirror Setpoints - AMO
M1S_X_Set = -175.01;
M1S_dX_Set=  152.00;
M3S_X_Set = 4913.93;
M3S_dX_Set= -56.40;

% Temp Setpoints
Jaw_Right = -10;
Jaw_Left  = 10;

%deviceCall(handles, 'Xray Slit Right', Jaw_Right)
%deviceCall(handles, 'Xray Slit Left', Jaw_Left)

guidata(hObject, handles);

% --- Executes on button press in SXR_button.
function SXR_button_Callback(hObject, eventdata, handles)
% NO CURRENT FUNCTION

% hObject    handle to SXR_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Mirror Setpoints - SXR
M1S_X_Set = -175.01;
M1S_dX_Set=  152.00;
M3S_X_Set = -4591.98;
M3S_dX_Set= -528.26;

% --- Executes on button press in XPP_button.
function XPP_button_Callback(hObject, eventdata, handles)
% NO CURRENT FUNCTION

% hObject    handle to XPP_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Mirror Setpoints - XPP
M1S_X_Set = -5000.02;
M1S_dX_Set=  0.00;

function deviceCall(handles, device, position)

handles.choice = strmatch(device, strvcat(handles.ROOT_NAME));
set(handles.variable1,'Value', handles.choice); 

[handles.lvdt, handles.motr, handles.des, handles.tols, ...
    handles.MotorDB, handles.units, handles.n_trims] = variable1_refresh(handles);

set(handles.desired_value, 'String', num2str(position));
handles.des = desired_value_refresh(handles);
Trim_button_Callback(handles.Trim_button, 0, handles);