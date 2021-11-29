function varargout = sol_QE(varargin)
% SOL_QE M-file for sol_QE.fig
%      SOL_QE, by itself, creates a new SOL_QE or raises the existing
%      singleton*.
%
%      H = SOL_QE returns the handle to a new SOL_QE or the handle to
%      the existing singleton*.
%
%      SOL_QE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOL_QE.M with the given input arguments.
%
%      SOL_QE('Property','Value',...) creates a new SOL_QE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sol_QE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sol_QE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sol_QE

% Last Modified by GUIDE v2.5 02-Feb-2012 10:48:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sol_QE_OpeningFcn, ...
                   'gui_OutputFcn',  @sol_QE_OutputFcn, ...
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



% --- Executes just before sol_QE is made visible.
function sol_QE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sol_QE (see VARARGIN)

% Choose default command line output for sol_QE
handles.output = hObject;
handles.exportFig = 1; 

global bunch_charge_value_orig
global attenuation_factor_orig
global LASER
global bunch_charge_value_new
global lp1_new
global lp2_new
global lp3_new
global lp4_new
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sol_QE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sol_QE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_take_image.
function pushbutton_take_image_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_take_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check beam rate
rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
if rate < 10
    sprintf('insufficient beam rate');
    c='Insufficient beam rate, rate less than 10Hz, if you can, fix it and launch GUI again.';
    set(handles.message_out_text,'String',c);
    pause(0.5);
    c='Make sure you have at least 10 Hz beam rate. Then hit any key to continue.'
    set(handles.message_out_text,'String',c);
    pause
else

% Check if MPS shutter is out
 MPS_Shutter=lcaGet('IOC:BSY0:MP01:MS_RATE');
 MPS_Shutter_state=strcat('MPS Shutter is :', MPS_Shutter);
 set(handles.message_out_text,'String',MPS_Shutter_state);
 pause(0.5);

% if MPS shutter is in, fix it and resume 
 a=struct;
 a.state = MPS_Shutter{1,:};
 a=str2num(a.state(1));
 while a == 0
  MPS_Shutter=lcaGet('IOC:BSY0:MP01:MS_RATE');
 a=struct;
 a.state = MPS_Shutter{1,:};
 a=str2num(a.state(1));
 c='Make sure MPS shutter is out.'
 set(handles.message_out_text,'String',c);
  user_response=modaldlg_2;
  pause(.5);
 end

% check if G- and T- lamp are off
 lcaPut('PFMC:IN20:GP02:G_LAMP_ENA', 0);
 lcaPut('PFMC:IN20:GP01:T_LAMP_ENA', 0);
 c='disabeling G-lamp and T-Lamp';
 set(handles.message_out_text,'String',c);
 pause(0.5);

% Get conditions before
global LASER
global IRIS
global SOL_val
global XC00_val
global YC00_val
global bunch_charge_value_orig
global attenuation_factor_orig
global bunch_charge_value_new
global lp1_new
global lp2_new
global lp3_new
global lp4_new

IRIS=lcaGet('IRIS:LR20:118:CONFG_SEL');
SOL_val=lcaGet('SOLN:IN20:121:BDES');
XC00_val=lcaGet('XCOR:IN20:121:BDES');
YC00_val=lcaGet('YCOR:IN20:122:BDES');
LASER=lcaGet('IOC:IN20:LS11:PCTRL');

c='Getting initial conditions for Solenoid, XC00, YC00, Laser Power, and IRIS';
set(handles.message_out_text,'String',c);
pause(0.5);
  
 VCC_LOOP=lcaGet('LASR:IN20:160:POS_FDBK');
 lcaPut('LASR:IN20:160:POS_FDBK','Open Loop');
 c='Turning VCC loop off';
 set(handles.message_out_text,'String',c);
 set(handles.ind_vcc_loop,'BackgroundColor','red');
 pause(0.5);

% get original bunch charge feedback value and bpm attenuator factor 
% comment out the old fdbk value on 01/25/2012
  %bunch_charge_value_orig = lcaGet('FBCK:BCI0:1:CHRGSP');
 bunch_charge_value_orig = lcaGet('FBCK:FB02:GN01:S1DES');
 attenuation_factor_orig = lcaGet('IOC:IN20:BP01:QANN');

%turn off charge feedback 
lcaPut('FBCK:FB02:GN01:MODE','0')
c='Bunch charge feedback should be off';
 set(handles.message_out_text,'String',c);
 pause(0.5);

% to make sure iris =1.0 mm for each measurements
 if strcmp(IRIS, '1.0 mm')==0
lcaPut('TRIG:LR20:LS01:TCTL','0')
c='Turning off Pockels cell';
set(handles.message_out_text,'String',c);
pause(0.5);

% move iris and wait until movement stops
c='Moving Iris to imaging position';
set(handles.message_out_text,'String',c);
pause(0.5);

lcaPut('IRIS:LR20:118:CONFG_SEL','1.0 mm');
move=0;
while move == 0 
  c='Waiting for Iris movement';
  pause(0.5);
  set(handles.message_out_text,'String',c);
  move=lcaGet('IRIS:LR20:118:MOTR_ANGLE.DMOV');
  pause(0.5);
end
set(handles.ind_IRIS,'BackgroundColor','red');

% Turn on Pockel's cell
lcaPut('TRIG:LR20:LS01:TCTL','1')
c='Iris stopped, turning on Pockels cell';
set(handles.message_out_text,'String',c);
pause(0.5);

else 
    c='Iris already at 1.0 mm';
    set(handles.message_out_text,'String',c);
    set(handles.ind_IRIS,'BackgroundColor','red');
end

% below is to measure QE
% setting laser power percent values to measure QE
lp1_new=get(handles.laserpower1,'String');
lp1_new2value=str2num(lp1_new);

lp2_new=get(handles.laserpower2,'String');
lp2_new2value=str2num(lp2_new);

lp3_new=get(handles.laserpower3,'String');
lp3_new2value=str2num(lp3_new);

lp4_new=get(handles.laserpower4,'String');
lp4_new2value=str2num(lp4_new);

laserpower=[lp1_new2value lp2_new2value lp3_new2value lp4_new2value];

for i=1:4
    lcaput('IOC:IN20:BP01:QANN',laserpower(i)*attenuation_factor_orig/LASER);
    lcaput('IOC:IN20:LS11:PCTRL',laserpower(i));
    pause(1.0);
    laserenergy(i)=lcaGet('LASR:IN20:196:PWR1H'); 
    pause(0.5);
    chargeforQE(i)=lcaGet('BPMS:IN20:221:TMIT1H')*1.602e-10;
    %chargeforQE(i)=lcaGet('FBCK:FB02:GN01:S1P1');
    pause(1.0);
end

coefQE=laserenergy'\chargeforQE';
coefLaser=laserpower'\chargeforQE';

bunch_charge_value_new=get(handles.bunch_charge_val,'String');
bunch_charge_value_new2value=str2num(bunch_charge_value_new);
laserforimaging=bunch_charge_value_new2value/coefLaser;

val.coefQE=coefQE;
val.laserenergy=laserenergy;
val.chargeforQE=chargeforQE;
set(hObject,'UserData',val);

% put laser power and bpm attenuator factor for imaging
lcaput('IOC:IN20:BP01:QANN',bunch_charge_value_new2value);
lcaput('IOC:IN20:LS11:PCTRL',laserforimaging);
set(handles.ind_BPM_ATTN,'BackgroundColor','red');
pause(2);

% set bunch charge feedback to new values 
%% comment out old one on 01/25/2012
%% lcaPut('FBCK:BCI0:1:CHRGSP', bunch_charge_value_new2value);
lcaPut('FBCK:FB02:GN01:S1DES', bunch_charge_value_new2value);
c='setting bunch charge to new value';
set(handles.message_out_text,'String',c);
set(handles.ind_BC_FDBK,'BackgroundColor','red');

%turn on charge feedback 
%% comment out on 01/25/2012
%% lcaPut('FBCK:BCI0:1:ENABLE','1');
lcaPut('FBCK:FB02:GN01:MODE','1')
c='Bunch charge feedback should be on';
set(handles.message_out_text,'String',c);
pause(10.0);

%display final charge
%% comment out old fdbk setting on 01/25/2012
%% current_charge=lcaGet('FBCK:BCI0:1:CHRG_S');
current_charge=lcaGet('BPMS:IN20:221:TMIT1H')*1.602e-10;
%%current_charge=lcaGet('FBCK:FB02:GN01:S1P1');
current_charge_disp=num2str(current_charge);
set(handles.current_charge,'String',current_charge_disp);

% Insert YAG02 target and take filters out
lcaPut('YAGS:IN20:241:FLT2_PNEU','OUT');
lcaPut('YAGS:IN20:241:FLT1_PNEU','OUT');
lcaPut('YAGS:IN20:241:PNEUMATIC','IN');

c='Inserting YAG02 target and removing filters';
set(handles.message_out_text,'String',c);
set(handles.ind_YAG02,'BackgroundColor','red');

% turns on trigger
lcaPut('EVR:IN20:PM02:CTRL.DG0E',1);
c='Turning on camera trigger';
set(handles.message_out_text,'String',c);
pause(0.5);


% Set Solenoid, XC00, YC00 to imaging
lcaPut('SOLN:IN20:121:BDES',0.55);
lcaPut('SOLN:IN20:121:FUNC','PERTURB');
lcaPut('XCOR:IN20:121:BDES',-0.0008333);
lcaPut('XCOR:IN20:121:FUNC','PERTURB');
lcaPut('YCOR:IN20:122:BDES',0.0000533);
lcaPut('YCOR:IN20:122:FUNC','PERTURB');

c='Setting Solenoid, XC00 and YC00 to imaging values, now go to Step 3';
set(handles.message_out_text,'String',c);
set(handles.ind_SOL1,'BackgroundColor','red');
set(handles.ind_XC00,'BackgroundColor','red');
set(handles.ind_YC00,'BackgroundColor','red');
pause(0.5);

end

guidata(hObject, handles);

% --- Executes on button press in Restore.
function Restore_Callback(hObject, eventdata, handles)
% hObject    handle to Restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global bunch_charge_value_orig
global attenuation_factor_orig
global SOL_val
global XC00_val
global YC00_val
global IRIS
global LASER

% Restore Solenoid, XC00, and YC00

lcaPut('SOLN:IN20:121:BDES',SOL_val);
lcaPut('SOLN:IN20:121:FUNC','PERTURB');
lcaPut('XCOR:IN20:121:BDES',XC00_val);
lcaPut('XCOR:IN20:121:FUNC','PERTURB');
lcaPut('YCOR:IN20:122:BDES',YC00_val);
lcaPut('YCOR:IN20:122:FUNC','PERTURB');

c='Restore Solenoid, XC00, YC00';
set(handles.message_out_text,'String',c);

set(handles.ind_SOL1,'BackgroundColor','green');
set(handles.ind_XC00,'BackgroundColor','green');
set(handles.ind_YC00,'BackgroundColor','green');

pause(0.5);

% to check whether iris is moved or not
current_iris=lcaGet('IRIS:LR20:118:CONFG_SEL')

if strcmp(current_iris, IRIS)==0

% Turn OFF Pockel's cell
lcaPut('TRIG:LR20:LS01:TCTL','0')
c='Turning off Pockels cell';
set(handles.message_out_text,'String',c);
pause(0.5);

% Set Iris to original
c='Setting Iris to original configuration';
set(handles.message_out_text,'String',c);
pause(0.5);


lcaPut('IRIS:LR20:118:CONFG_SEL',IRIS);
move=0;
while move == 0 %waits for iris movement
  c='Waiting for Iris movement';
  set(handles.message_out_text,'String',c);
  pause(0.5);
  move=lcaGet('IRIS:LR20:118:MOTR_ANGLE.DMOV');
  pause(0.5);
end
set(handles.ind_IRIS,'BackgroundColor','green');


% Turn On Pockel's Cell
lcaPut('TRIG:LR20:LS01:TCTL','1')
c='Iris removed, turning on Pockels cell';
set(handles.message_out_text,'String',c);
pause(0.5);
else
    c='Iris is recovered'
    set(handles.message_out_text,'String',c);
    set(handles.ind_IRIS,'BackgroundColor','green');
end

% turn off charge feedback
%lcaPut('FBCK:BCI0:1:ENABLE','0');
lcaPut('FBCK:FB02:GN01:MODE','0')
c='Bunch charge feedback should be off';
set(handles.message_out_text,'String',c);
pause(0.5);

% restore laser power
lcaPut('IOC:IN20:LS11:PCTRL', LASER);
c='Restoring Laser Power';
set(handles.message_out_text,'String',c);
pause(0.5);

% Restore original Bunch charge feedback and bpm attenuation factor
%lcaPut('FBCK:BCI0:1:CHRGSP', bunch_charge_value_orig);
lcaPut('FBCK:FB02:GN01:S1DES', bunch_charge_value_orig);
set(handles.ind_BC_FDBK,'BackgroundColor','green');
lcaPut('IOC:IN20:BP01:QANN', attenuation_factor_orig);
c='Restoring original Bunch Charge Feedback and BPM attenuation factor value';
set(handles.message_out_text,'String',c);
set(handles.ind_BPM_ATTN,'BackgroundColor','green');
pause(5);

% turn on bunch charge feedback 
%lcaPut('FBCK:BCI0:1:ENABLE','1');
lcaPut('FBCK:FB02:GN01:MODE','1')
c='Bunch charge feedback should be on';
set(handles.message_out_text,'String',c);
pause(0.5);

% Turn on VCC feedback
lcaPut('LASR:IN20:160:POS_FDBK','Close Loop');
c='Closing VCC loop, and we are done, make sure bunch charge feedback is happy';
set(handles.message_out_text,'String',c);
set(handles.ind_vcc_loop,'BackgroundColor','green');
pause(0.5);

% Take out YAG screen
lcaPut('YAGS:IN20:241:PNEUMATIC','OUT');
c='Taking out YAG screen';
set(handles.message_out_text,'String',c);
set(handles.ind_YAG02,'BackgroundColor','green');
pause(0.5);

guidata(hObject, handles);


% --- Executes on button press in NoIris_imaging.
function NoIris_imaging_Callback(hObject, eventdata, handles)
% hObject    handle to NoIris_imaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% turn off Pockel's cell
lcaPut('TRIG:LR20:LS01:TCTL','0')
c='Turning off Pockels cell';
set(handles.message_out_text,'String',c);
pause(0.5);

% move iris and wait until movement stops
c='Moving Iris to imaging position';
set(handles.message_out_text,'String',c);
pause(0.5);


lcaPut('IRIS:LR20:118:CONFG_SEL','No Iris');
move=0;
while move == 0 %waits for iris movement
  c='Waiting for Iris movement';
  pause(0.5);
  set(handles.message_out_text,'String',c);
  move=lcaGet('IRIS:LR20:118:MOTR_ANGLE.DMOV');
  pause(0.5);

end

% Turn on Pockel's cell
lcaPut('TRIG:LR20:LS01:TCTL','1')
c='Iris stopped, turning on Pockels cell. Now go to Step 6 (Profile Monitor GUI)';
set(handles.message_out_text,'String',c);
pause(0.5);

% January 10, 2012: insert YAG02 filters in 
lcaPut('YAGS:IN20:241:FLT2_PNEU','OUT');
lcaPut('YAGS:IN20:241:FLT1_PNEU','IN');

guidata(hObject, handles);


function bunch_charge_val_Callback(hObject, eventdata, handles)
% hObject    handle to bunch_charge_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bunch_charge_val as text
%        str2double(get(hObject,'String')) returns contents of bunch_charge_val as a double
global bunch_charge_value_new
% is the below correct?
bunch_charge_value_new=get(hObject,'String');
%bunch_charge_value_new=str2num('bunch_charge_value_new');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bunch_charge_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bunch_charge_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function current_charge_Callback(hObject, eventdata, handles)
% hObject    handle to current_charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_charge as text
%        str2double(get(hObject,'String')) returns contents of current_charge as a double


% --- Executes during object creation, after setting all properties.
function current_charge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ind_vcc_loop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_vcc_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ind_BC_FDBK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_BC_FDBK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ind_BPM_ATTN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_BPM_ATTN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ind_YAG02_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_YAG02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ind_IRIS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_IRIS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ind_SOL1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_SOL1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ind_XC00_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_XC00 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ind_YC00_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ind_YC00 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function bunch_charge_val_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to bunch_charge_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over bunch_charge_val.
function bunch_charge_val_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to bunch_charge_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on bunch_charge_val and no controls selected.
function bunch_charge_val_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to bunch_charge_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function current_charge_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to current_charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over current_charge.
function current_charge_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to current_charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on current_charge and no controls selected.
function current_charge_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to current_charge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function text7_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text7.
function text7_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function text9_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text9.
function text9_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function NoIris_imaging_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NoIris_imaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function NoIris_imaging_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to NoIris_imaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over NoIris_imaging.
function NoIris_imaging_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to NoIris_imaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on NoIris_imaging and no controls selected.
function NoIris_imaging_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to NoIris_imaging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function text10_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text10.
function text10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function Restore_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function Restore_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to Restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Restore.
function Restore_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on Restore and no controls selected.
function Restore_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Restore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function text21_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to text21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function uipanel1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipanel1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text21.
function text21_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function ind_vcc_loop_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ind_vcc_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ind_vcc_loop.
function ind_vcc_loop_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ind_vcc_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pushbutton_take_image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_take_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function pushbutton_take_image_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_take_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_take_image.
function pushbutton_take_image_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_take_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function text11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton_QE_plot.
function pushbutton_QE_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_QE_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%coefQE=get(handles.coefQE,'Value')
%global coefQE
%global laserpower
%global chargeforQE

val=get(handles.pushbutton_take_image,'UserData');
%newx=[0 2 3 5 7 ];
newx=[1 3 5 7 15];
coefQE=val.coefQE;
laserenergy=val.laserenergy;
chargeforQE=val.chargeforQE;
newy=newx*coefQE;


%conversion of 1 nC to number of electrons
Nelectron=1/1.6*1.e10;

%conversion of 1uj to number of photons
Nlaser=1.e-6*253.e-9/(6.626e-34*3.e8);

realQE=coefQE*Nelectron/Nlaser;
strrealQE=num2str(realQE);
QEout=strcat('QE=',strrealQE)

plot(handles.axes2,laserenergy,chargeforQE,'o',newx,newy,'-r')
grid on
set(get(handles.axes2,'Ylabel'),'String','Charge (nC)');
set(get(handles.axes2,'Xlabel'),'String','Laser energy (uJ)');
set(get(handles.axes2,'Title'),'String',QEout)

%function dataExport_btn_Callback(hObject, eventdata, handles)
%util_printLog(1)

%dataExport(hObject,handles);

% --- Executes on button press in pushtoLog.
%function printLog_btn_Callback(hObject, eventdata, handles)
% hObject    handle to pushtoLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%util_printLog(1)

function pushtoLog_Callback(hObject, eventdata, handles)
% hObject    handle to pushtoLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(handles.exportFig);
util_copyAxes(handles.axes2,gca);
util_printLog(handles.exportFig);

% --- Executes on button press in pushtoLog.
%function printLog_btn_Callback(hObject, eventdata, handles)
% hObject    handle to pushtoLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pushbutton_QE_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_QE_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2



function laserpower1_Callback(hObject, eventdata, handles)
% hObject    handle to laserpower1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of laserpower1 as text
%        str2double(get(hObject,'String')) returns contents of laserpower1 as a double
global lp1_new
lp1_new=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function laserpower1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserpower1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function laserpower2_Callback(hObject, eventdata, handles)
% hObject    handle to laserpower2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global lp2_new
lp2_new=get(hObject,'String');
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of laserpower2 as text
%        str2double(get(hObject,'String')) returns contents of laserpower2 as a double


% --- Executes during object creation, after setting all properties.
function laserpower2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserpower2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function laserpower3_Callback(hObject, eventdata, handles)
% hObject    handle to laserpower3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global lp3_new
lp3_new=get(hObject,'String');
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of laserpower3 as text
%        str2double(get(hObject,'String')) returns contents of laserpower3 as a double


% --- Executes during object creation, after setting all properties.
function laserpower3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserpower3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function laserpower4_Callback(hObject, eventdata, handles)
% hObject    handle to laserpower4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global lp4_new
lp4_new=get(hObject,'String');
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of laserpower4 as text
%        str2double(get(hObject,'String')) returns contents of laserpower4 as a double


% --- Executes during object creation, after setting all properties.
function laserpower4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserpower4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


