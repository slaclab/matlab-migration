function varargout = FEE_MirrorSwitch_gui(varargin)
% FEE_MIRRORSWITCH_GUI M-file for FEE_MirrorSwitch_gui.fig
%      FEE_MIRRORSWITCH_GUI, by itself, creates a new FEE_MIRRORSWITCH_GUI or raises the existing
%      singleton*.
%
%      H = FEE_MIRRORSWITCH_GUI returns the handle to a new FEE_MIRRORSWITCH_GUI or the handle to
%      the existing singleton*.
%
%      FEE_MIRRORSWITCH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEE_MIRRORSWITCH_GUI.M with the given input arguments.
%
%      FEE_MIRRORSWITCH_GUI('Property','Value',...) creates a new FEE_MIRRORSWITCH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FEE_MirrorSwitch_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FEE_MirrorSwitch_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FEE_MirrorSwitch_gui

% Last Modified by GUIDE v2.5 30-Aug-2010 12:43:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FEE_MirrorSwitch_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @FEE_MirrorSwitch_gui_OutputFcn, ...
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


% --- Executes just before FEE_MirrorSwitch_gui is made visible.
function FEE_MirrorSwitch_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FEE_MirrorSwitch_gui (see VARARGIN)

% Choose default command line output for FEE_MirrorSwitch_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FEE_MirrorSwitch_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FEE_MirrorSwitch_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -----------------------------------------------------------------------
function handles = appInit(hObject, handles)

%each state has number, execution text, and action
handles.states.exec_txt= { ...
    'Initializing ...\n\n Click Next'%1
    'Verifying shutter status ...\n\nS1, S2, and S1H should be IN.\n\n Click Next (button disabled until shutters IN)' %2
    'Calculating Solid Attentuation and Inserting (if needed) ...\n\nClick Next' %3
    'If necessary, adjust Gas Attenuator'%4
    'Acquiring image from profile monitor ...\n\nIf beam is not visible, increase Sensitivity setting\n\nClick Next' %5
    'Image saved to log. \n\n Click Next' %6
   % 'Saving Motor and LVDT values ...' %7
    'Choose desired station'%8 
    'Moving mirrors ...\n\nPress Next when motors stop moving' %9
    'Press Change Energy if required. \n Press NEXT when energy is correct' %10
    'Calculating Solid Attentuation and Inserting (if needed) ...\n\nClick Next' %11
    'If necessary, adjust Gas Attenuator'%12
    'Removing B4C. \n\nMonitor gas detector signal and optimize.\n\nClick Next when optimized.' %13
    'Acquiring image from profile monitor ...\n\nIf beam is not visible, increase Sensitivity setting\n\nClick Next' %14
    'Image saved to log. \n\n Click Next' %15
    'Procedure Complete' %16
    };
handles.action={...
    'initialize(hObject,handles);'%1
    'verify_shutter_status(hObject,handles);'%2
    'insert_solid_att(hObject,handles);'%3
    'adjust_gas_att(hObject,handles)'%4
    'handles=acquire_image(hObject,handles);'%5
    'handles=process_image(hObject, handles);'%6
%    'util_printLog(figure(1));save_motor_params(hObject,handles);'%7
   'set_BYKIK(hObject,handles,0);get_station(hObject,handles);'%8
%     'util_printLog(figure(1));set_BYKIK(hObject,handles,0);get_station(hObject,handles);'%8
    'move_mirrors(hObject,handles);'%9
    ''%10
    'insert_solid_att(hObject,handles);'%11
    'adjust_gas_att(hObject,handles)'%12
    'set_BYKIK(hObject,handles,1);move_B4C(hObject,handles,1);'%13
    'handles=acquire_image(hObject,handles);'%14
    'handles=process_image(hObject, handles);'%15
    'retract_popins(hObject,handles);'%16
%     'util_printLog(figure(1));retract_popins(hObject,handles);'%16

    };
if ~ispc
    handles.debug=0;
else
    handles.debug=1;
end
nstates=length(handles.states.exec_txt);
handles.states.num=1:nstates;
handles.new_station='';
handles.b4c_flag=0;
handles=bitsControl(hObject,handles,8,12);
handles=sensitivityControl(hObject,handles,3,8);
set(handles.maxT_txt,'String','0.1');
set(handles.nstates_txt,'String',nstates);
set(handles.state_pmu, 'String',1:nstates);
set(handles.state_pmu, 'Value',handles.states.num(1));
set(handles.stationSelAMO_btn, 'Visible', 'off');
set(handles.stationSelSXR_btn, 'Visible', 'off');
set(handles.stationSelHXL_btn, 'Visible', 'off');
set(handles.energy_btn, 'Visible', 'off');
handles.photonEnergy=[];
handles.totalT=[];
handles.bitShift=[];
guidata(hObject, handles);
handles=state_update(hObject,handles);
% --- Executes on selection change in state_pmu.
function state_pmu_Callback(hObject, eventdata, handles)
% hObject    handle to state_pmu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns state_pmu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from state_pmu
handles=state_update(hObject,handles);

% --- Executes on button press in previous_btn or next_btn.
function change_state_Callback(hObject, eventdata, handles, val)
% hObject    handle to previous_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_state=get(handles.state_pmu, 'Value');
new_state=curr_state+val;
if (new_state>max(handles.states.num))
    new_state=new_state-1;
end
if (new_state<min(handles.states.num))
    new_state=new_state+1;
end
set(handles.state_pmu, 'Value',new_state);
handles=state_update(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in energy_btn.
function handles=energy_btn_Callback(hObject, eventdata, handles)
% hObject    handle to energy_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

move_B4C(hObject,handles,handles.b4c_flag);
set_BYKIK(hObject,handles,1);
status_update(hObject,handles);
[hObject_p,h]=util_appFind('energyramp');

% --- Executes on button press in stationSel_btn.
function handles=stationSel_btn_Callback(hObject, eventdata, handles, tag)
% hObject    handle to stationSelAMO_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_station=get_station_status(hObject,handles);
if strcmp(curr_station,'AMO') || strcmp(curr_station,'SXR') %if current = soft XRay
    if strcmp(tag,'AMO') || strcmp(tag,'SXR')% if new =  soft XRay
        handles.b4c_flag=1; %don't insert B4C
    else
        handles.b4c_flag=0; %do insert B4C
    end
else
    handles.b4c_flag=0; %do insert B4C
end
handles.new_station=tag;
change_state_Callback(hObject, eventdata, handles, 1);
guidata(hObject, handles);

% --- Initialize
function initialize(hObject,handles)
handles=status_update(hObject,handles);
curr_state=get(handles.state_pmu, 'Value');
new_state=curr_state+1;
% if (new_state>max(handles.states.num))
%     new_state=new_state-1;
% end
% set(handles.state_pmu, 'Value',new_state);
% handles=state_update(hObject,handles);
guidata(hObject, handles);

% --- Updates indicators on status section of GUI
function handles=status_update(hObject,handles)

handles=get_photon_status(hObject,handles);
handles=get_BYKIK_status(hObject,handles);
handles=get_B4C_status(hObject,handles);
handles=get_SATT_status(hObject,handles);
handles=get_profmon_status(hObject,handles);
handles=get_motor_position(hObject,handles);
get_shutter_status(hObject,handles);
get_station_status(hObject,handles);
guidata(hObject, handles);

% --- Updates shutter indicators on status section of GUI
function shutters_state=get_shutter_status(hObject,handles)
state={'OUT','IN'};
% S1=lcaGet('PPS:NEH1:1:ST01',0,'double') && lcaGet('PPS:NEH1:1:ST02',0,'double');
% S2=lcaGet('PPS:NEH1:2:ST01',0,'double') && lcaGet('PPS:NEH1:2:ST02',0,'double');
% S3=lcaGet('PPS:NEH1:3:ST01',0,'double') && lcaGet('PPS:NEH1:3:ST02',0,'double');
S1=strcmp(lcaGet('PPS:NEH1:1:S1STPRSUM',0,'char'),'IN');
S2=strcmp(lcaGet('PPS:NEH1:2:S2STPRSUM',0,'char'),'IN');
S3=strcmp(lcaGet('PPS:NEH1:3:SH1STPRSUM',0,'char'),'IN');
shutters_state= S1 && S2 && S3;
set (handles.S1_txt,'String', state{S1+1});
set (handles.S2_txt,'String', state{S2+1});
set (handles.S3H_txt,'String', state{S3+1});
guidata(hObject, handles);

% --- Verify shutter status
function handles=verify_shutter_status(hObject,handles)
enable={'on','off'};
shutters_state=get_shutter_status(hObject,handles);
set (handles.next_btn, 'Enable',enable{~shutters_state+1});
while ~shutters_state
    set (handles.next_btn, 'Enable',enable{~shutters_state+1});
    guidata(hObject, handles);
    pause (1.0)
    shutters_state=get_shutter_status(hObject,handles);
end

% --- Updates station indicator on status section of GUI
function curr_station=get_station_status(hObject,handles)
station={'AMO','SXR','HXL',''};
curr_station=station{4};
m1s=lcaGet('MIRR:FEE1:0561:POSITION',0,'double'); % IN=1= Soft Xray
m3s1=lcaGet('MIRR:FEE1:1811:POSITION',0,'double');
m3s2=lcaGet('MIRR:FEE1:2811:POSITION',0,'double');
if m1s
    if m3s1
        curr_station=station{1}; %AMO
    else
        if m3s2
            curr_station=station{2}; %SXR
        end
    end
else
    curr_station=station{3}; %HXL
end
set (handles.station_txt,'String', curr_station);
if strcmp(curr_station,'')
    errordlg('Unable to determine current station')
end

% --- Updates photon indicator on status section of GUI
function handles=get_photon_status(hObject,handles)
photon_energy=lcaGet('SIOC:SYS0:ML00:AO627',0,'char');
handles.photonEnergy=str2double(photon_energy);
set (handles.photonEnergy_txt,'String', photon_energy);
guidata(hObject, handles);

% --- Updates BYKIK indicator on status section of GUI
function handles=get_BYKIK_status(hObject,handles)
state={'OUT','IN'};
bykik_state=lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'double');
set (handles.BYKIK_txt,'String', state{bykik_state+1});

% --- Changes BYKIK state
function handles=set_BYKIK(hObject,handles,val)
lcaPut('IOC:BSY0:MP01:BYKIKCTL',val);
get_BYKIK_status(hObject,handles);

% --- Updates B4C indicator on status section of GUI
function handles=get_B4C_status(hObject,handles)
state={'IN','OUT'};
b4c_state=lcaGet('YAGS:DMP1:500:FOIL2_PNEU',0,'double');
set (handles.B4C_txt,'String', state{b4c_state+1});

% --- Updates SATT indicator on status section of GUI
function handles=get_SATT_status(hObject,handles)
satt_thickness=lcaGet('SATT:FEE1:320:TACT',0,'char');
set (handles.sattThickness_txt,'String', satt_thickness);

% --- Updates profmon indicator on status section of GUI
function handles=get_profmon_status(hObject,handles)
str='';
P3S1=lcaGet('CAMR:FEE1:1953:POSITION',0,'double');
P3S2=lcaGet('CAMR:FEE1:2953:POSITION',0,'double');
P3H=lcaGet('CAMR:FEE1:913:POSITION',0,'double');
if P3S1
    str=strcat(str,'P3S1');
end
if P3S2
    str=strcat(str,' P3S2');
end
if P3H
    str=strcat(str,' P3H');
end
set (handles.profMon_txt,'String',str);

% --- Inserts solid attenuators
function handles=insert_solid_att(hObject,handles)
set (handles.next_btn, 'Enable','off');
handles.Be_fit_coeffs_lo= [-6.4782E-15 4.7725E-10 -5.59E-07 5.4979E-04];
handles.Be_fit_coeffs_hi= [9.5594E-13 -2.3827E-08 2.0159E-04 -5.5852e-1];

handles.atten_ratio=0.1;

handles.Be_cmd_pvs = {
                    'SATT:FEE1:321:CMD'
                    'SATT:FEE1:322:CMD'
                    'SATT:FEE1:323:CMD'
                    'SATT:FEE1:324:CMD'
                    'SATT:FEE1:325:CMD'
                    'SATT:FEE1:326:CMD'
                    'SATT:FEE1:327:CMD'
                    'SATT:FEE1:328:CMD'
                    'SATT:FEE1:329:CMD'};

handles.Be_read_pvs = {
                    'SATT:FEE1:321:STATE'
                    'SATT:FEE1:322:STATE'
                    'SATT:FEE1:323:STATE'
                    'SATT:FEE1:324:STATE'
                    'SATT:FEE1:325:STATE'
                    'SATT:FEE1:326:STATE'
                    'SATT:FEE1:327:STATE'
                    'SATT:FEE1:328:STATE'
                    'SATT:FEE1:329:STATE'};

handles.Be_total = 'SATT:FEE1:320:TACT';

handles.Be_matrix = [
0	0	0	0	0	0	0	0	0	0
0.4	1	0	0	0	0	0	0	0	0
4	0	1	0	0	0	0	0	0	0
4.4	1	1	0	0	0	0	0	0	0
20	0	0	0	1	0	0	0	0	0
20.4	1	0	0	1	0	0	0	0	0
24	0	1	0	1	0	0	0	0	0
24.4	1	1	0	1	0	0	0	0	0
40	0	0	0	0	1	0	0	0	0
40.4	1	0	0	0	1	0	0	0	0
44	0	1	0	0	1	0	0	0	0
44.4	1	1	0	0	1	0	0	0	0
60	0	0	0	1	1	0	0	0	0
60.4	1	0	0	1	1	0	0	0	0
64	0	1	0	1	1	0	0	0	0
64.4	1	1	0	1	1	0	0	0	0
80	0	0	0	0	0	1	0	0	0
80.4	1	0	0	0	0	1	0	0	0
84	0	1	0	0	0	1	0	0	0
84.4	1	1	0	0	0	1	0	0	0
100	0	0	0	1	0	1	0	0	0
100.4	1	0	0	1	0	1	0	0	0
104	0	1	0	1	0	1	0	0	0
104.4	1	1	0	1	0	1	0	0	0
120	0	0	0	0	1	1	0	0	0
120.4	1	0	0	0	1	1	0	0	0
124	0	1	0	0	1	1	0	0	0
124.4	1	1	0	0	1	1	0	0	0
140	0	0	0	1	1	1	0	0	0
140.4	1	0	0	1	1	1	0	0	0
144	0	1	0	1	1	1	0	0	0
144.4	1	1	0	1	1	1	0	0	0
160	0	0	0	0	0	0	1	0	0
160.4	1	0	0	0	0	0	1	0	0
164	0	1	0	0	0	0	1	0	0
164.4	1	1	0	0	0	0	1	0	0
180	0	0	0	1	0	0	1	0	0
180.4	1	0	0	1	0	0	1	0	0
184	0	1	0	1	0	0	1	0	0
184.4	1	1	0	1	0	0	1	0	0
200	0	0	0	0	1	0	1	0	0
200.4	1	0	0	0	1	0	1	0	0
204	0	1	0	0	1	0	1	0	0
204.4	1	1	0	0	1	0	1	0	0
220	0	0	0	1	1	0	1	0	0
220.4	1	0	0	1	1	0	1	0	0
224	0	1	0	1	1	0	1	0	0
224.4	1	1	0	1	1	0	1	0	0
240	0	0	0	0	0	1	1	0	0
240.4	1	0	0	0	0	1	1	0	0
244	0	1	0	0	0	1	1	0	0
244.4	1	1	0	0	0	1	1	0	0
260	0	0	0	1	0	1	1	0	0
260.4	1	0	0	1	0	1	1	0	0
264	0	1	0	1	0	1	1	0	0
264.4	1	1	0	1	0	1	1	0	0
280	0	0	0	0	1	1	1	0	0
280.4	1	0	0	0	1	1	1	0	0
284	0	1	0	0	1	1	1	0	0
284.4	1	1	0	0	1	1	1	0	0
300	0	0	0	1	1	1	1	0	0
300.4	1	0	0	1	1	1	1	0	0
304	0	1	0	1	1	1	1	0	0
304.4	1	1	0	1	1	1	1	0	0
320	0	0	0	0	0	0	0	1	0
320.4	1	0	0	0	0	0	0	1	0
324	0	1	0	0	0	0	0	1	0
324.4	1	1	0	0	0	0	0	1	0
340	0	0	0	1	0	0	0	1	0
340.4	1	0	0	1	0	0	0	1	0
344	0	1	0	1	0	0	0	1	0
344.4	1	1	0	1	0	0	0	1	0
360	0	0	0	0	1	0	0	1	0
360.4	1	0	0	0	1	0	0	1	0
364	0	1	0	0	1	0	0	1	0
364.4	1	1	0	0	1	0	0	1	0
380	0	0	0	1	1	0	0	1	0
380.4	1	0	0	1	1	0	0	1	0
384	0	1	0	1	1	0	0	1	0
384.4	1	1	0	1	1	0	0	1	0
400	0	0	0	0	0	1	0	1	0
400.4	1	0	0	0	0	1	0	1	0
404	0	1	0	0	0	1	0	1	0
404.4	1	1	0	0	0	1	0	1	0
420	0	0	0	1	0	1	0	1	0
420.4	1	0	0	1	0	1	0	1	0
424	0	1	0	1	0	1	0	1	0
424.4	1	1	0	1	0	1	0	1	0
440	0	0	0	0	1	1	0	1	0
440.4	1	0	0	0	1	1	0	1	0
444	0	1	0	0	1	1	0	1	0
444.4	1	1	0	0	1	1	0	1	0
460	0	0	0	1	1	1	0	1	0
460.4	1	0	0	1	1	1	0	1	0
464	0	1	0	1	1	1	0	1	0
464.4	1	1	0	1	1	1	0	1	0
480	0	0	0	0	0	0	1	1	0
480.4	1	0	0	0	0	0	1	1	0
484	0	1	0	0	0	0	1	1	0
484.4	1	1	0	0	0	0	1	1	0
500	0	0	0	1	0	0	1	1	0
500.4	1	0	0	1	0	0	1	1	0
504	0	1	0	1	0	0	1	1	0
504.4	1	1	0	1	0	0	1	1	0
520	0	0	0	0	1	0	1	1	0
520.4	1	0	0	0	1	0	1	1	0
524	0	1	0	0	1	0	1	1	0
524.4	1	1	0	0	1	0	1	1	0
540	0	0	0	1	1	0	1	1	0
540.4	1	0	0	1	1	0	1	1	0
544	0	1	0	1	1	0	1	1	0
544.4	1	1	0	1	1	0	1	1	0
560	0	0	0	0	0	1	1	1	0
560.4	1	0	0	0	0	1	1	1	0
564	0	1	0	0	0	1	1	1	0
564.4	1	1	0	0	0	1	1	1	0
580	0	0	0	1	0	1	1	1	0
580.4	1	0	0	1	0	1	1	1	0
584	0	1	0	1	0	1	1	1	0
584.4	1	1	0	1	0	1	1	1	0
600	0	0	0	0	1	1	1	1	0
600.4	1	0	0	0	1	1	1	1	0
604	0	1	0	0	1	1	1	1	0
604.4	1	1	0	0	1	1	1	1	0
620	0	0	0	1	1	1	1	1	0
620.4	1	0	0	1	1	1	1	1	0
624	0	1	0	1	1	1	1	1	0
624.4	1	1	0	1	1	1	1	1	0
640	0	0	0	0	0	0	0	0	1
640.4	1	0	0	0	0	0	0	0	1
644	0	1	0	0	0	0	0	0	1
644.4	1	1	0	0	0	0	0	0	1
660	0	0	0	1	0	0	0	0	1
660.4	1	0	0	1	0	0	0	0	1
664	0	1	0	1	0	0	0	0	1
664.4	1	1	0	1	0	0	0	0	1
680	0	0	0	0	1	0	0	0	1
680.4	1	0	0	0	1	0	0	0	1
684	0	1	0	0	1	0	0	0	1
684.4	1	1	0	0	1	0	0	0	1
700	0	0	0	1	1	0	0	0	1
700.4	1	0	0	1	1	0	0	0	1
704	0	1	0	1	1	0	0	0	1
704.4	1	1	0	1	1	0	0	0	1
720	0	0	0	0	0	1	0	0	1
720.4	1	0	0	0	0	1	0	0	1
724	0	1	0	0	0	1	0	0	1
724.4	1	1	0	0	0	1	0	0	1
740	0	0	0	1	0	1	0	0	1
740.4	1	0	0	1	0	1	0	0	1
744	0	1	0	1	0	1	0	0	1
744.4	1	1	0	1	0	1	0	0	1
760	0	0	0	0	1	1	0	0	1
760.4	1	0	0	0	1	1	0	0	1
764	0	1	0	0	1	1	0	0	1
764.4	1	1	0	0	1	1	0	0	1
780	0	0	0	1	1	1	0	0	1
780.4	1	0	0	1	1	1	0	0	1
784	0	1	0	1	1	1	0	0	1
784.4	1	1	0	1	1	1	0	0	1
800	0	0	0	0	0	0	1	0	1
800.4	1	0	0	0	0	0	1	0	1
804	0	1	0	0	0	0	1	0	1
804.4	1	1	0	0	0	0	1	0	1
820	0	0	0	1	0	0	1	0	1
820.4	1	0	0	1	0	0	1	0	1
824	0	1	0	1	0	0	1	0	1
824.4	1	1	0	1	0	0	1	0	1
840	0	0	0	0	1	0	1	0	1
840.4	1	0	0	0	1	0	1	0	1
844	0	1	0	0	1	0	1	0	1
844.4	1	1	0	0	1	0	1	0	1
860	0	0	0	1	1	0	1	0	1
860.4	1	0	0	1	1	0	1	0	1
864	0	1	0	1	1	0	1	0	1
864.4	1	1	0	1	1	0	1	0	1
880	0	0	0	0	0	1	1	0	1
880.4	1	0	0	0	0	1	1	0	1
884	0	1	0	0	0	1	1	0	1
884.4	1	1	0	0	0	1	1	0	1
900	0	0	0	1	0	1	1	0	1
900.4	1	0	0	1	0	1	1	0	1
904	0	1	0	1	0	1	1	0	1
904.4	1	1	0	1	0	1	1	0	1
920	0	0	0	0	1	1	1	0	1
920.4	1	0	0	0	1	1	1	0	1
924	0	1	0	0	1	1	1	0	1
924.4	1	1	0	0	1	1	1	0	1
940	0	0	0	1	1	1	1	0	1
940.4	1	0	0	1	1	1	1	0	1
944	0	1	0	1	1	1	1	0	1
944.4	1	1	0	1	1	1	1	0	1
960	0	0	0	0	0	0	0	1	1
960.4	1	0	0	0	0	0	0	1	1
964	0	1	0	0	0	0	0	1	1
964.4	1	1	0	0	0	0	0	1	1
980	0	0	0	1	0	0	0	1	1
980.4	1	0	0	1	0	0	0	1	1
984	0	1	0	1	0	0	0	1	1
984.4	1	1	0	1	0	0	0	1	1
1000	0	0	0	0	1	0	0	1	1
1000.4	1	0	0	0	1	0	0	1	1
1004	0	1	0	0	1	0	0	1	1
1004.4	1	1	0	0	1	0	0	1	1
1020	0	0	0	1	1	0	0	1	1
1020.4	1	0	0	1	1	0	0	1	1
1024	0	1	0	1	1	0	0	1	1
1024.4	1	1	0	1	1	0	0	1	1
1040	0	0	0	0	0	1	0	1	1
1040.4	1	0	0	0	0	1	0	1	1
1044	0	1	0	0	0	1	0	1	1
1044.4	1	1	0	0	0	1	0	1	1
1060	0	0	0	1	0	1	0	1	1
1060.4	1	0	0	1	0	1	0	1	1
1064	0	1	0	1	0	1	0	1	1
1064.4	1	1	0	1	0	1	0	1	1
1080	0	0	0	0	1	1	0	1	1
1080.4	1	0	0	0	1	1	0	1	1
1084	0	1	0	0	1	1	0	1	1
1084.4	1	1	0	0	1	1	0	1	1
1100	0	0	0	1	1	1	0	1	1
1100.4	1	0	0	1	1	1	0	1	1
1104	0	1	0	1	1	1	0	1	1
1104.4	1	1	0	1	1	1	0	1	1
1120	0	0	0	0	0	0	1	1	1
1120.4	1	0	0	0	0	0	1	1	1
1124	0	1	0	0	0	0	1	1	1
1124.4	1	1	0	0	0	0	1	1	1
1140	0	0	0	1	0	0	1	1	1
1140.4	1	0	0	1	0	0	1	1	1
1144	0	1	0	1	0	0	1	1	1
1144.4	1	1	0	1	0	0	1	1	1
1160	0	0	0	0	1	0	1	1	1
1160.4	1	0	0	0	1	0	1	1	1
1164	0	1	0	0	1	0	1	1	1
1164.4	1	1	0	0	1	0	1	1	1
1180	0	0	0	1	1	0	1	1	1
1180.4	1	0	0	1	1	0	1	1	1
1184	0	1	0	1	1	0	1	1	1
1184.4	1	1	0	1	1	0	1	1	1
1200	0	0	0	0	0	1	1	1	1
1200.4	1	0	0	0	0	1	1	1	1
1204	0	1	0	0	0	1	1	1	1
1204.4	1	1	0	0	0	1	1	1	1
1220	0	0	0	1	0	1	1	1	1
1220.4	1	0	0	1	0	1	1	1	1
1224	0	1	0	1	0	1	1	1	1
1224.4	1	1	0	1	0	1	1	1	1
1240	0	0	0	0	1	1	1	1	1
1240.4	1	0	0	0	1	1	1	1	1
1244	0	1	0	0	1	1	1	1	1
1244.4	1	1	0	0	1	1	1	1	1
1260	0	0	0	1	1	1	1	1	1
1260.4	1	0	0	1	1	1	1	1	1
1264	0	1	0	1	1	1	1	1	1
1264.4	1	1	0	1	1	1	1	1	1
1280	0	0	1	1	1	1	1	1	1
1280.4	1	0	1	1	1	1	1	1	1
1284	0	1	1	1	1	1	1	1	1
1284.4	1	1	1	1	1	1	1	1	1
];

photon_energy=lcaGet('SIOC:SYS0:ML00:AO627',0,'double')

if photon_energy < 7000
    att_length=(handles.Be_fit_coeffs_lo(1)*photon_energy^4+ ...
        handles.Be_fit_coeffs_lo(2)*photon_energy^3+ ...
        handles.Be_fit_coeffs_lo(3)*photon_energy^2+ ...
        handles.Be_fit_coeffs_lo(4)*photon_energy);
elseif photon_energy > 7500
    att_length=(handles.Be_fit_coeffs_hi(1)*photon_energy^4+ ...
        handles.Be_fit_coeffs_hi(2)*photon_energy^3+ ...
        handles.Be_fit_coeffs_hi(3)*photon_energy^2+ ...
        handles.Be_fit_coeffs_hi(4)*photon_energy);
else
    att_length=(handles.Be_fit_coeffs_lo(1)*7000^4+ ...
        handles.Be_fit_coeffs_lo(2)*7000^3+ ...
        handles.Be_fit_coeffs_lo(3)*7000^2+ ...
        handles.Be_fit_coeffs_lo(4)*7000);
end

thickness=att_length*log(1/handles.atten_ratio)

[mn,imn] = min(abs(handles.Be_matrix(:,1)-thickness));
state={'OUT','IN'};
for idx=1:length(handles.Be_cmd_pvs)
    lcaPut(handles.Be_cmd_pvs(idx),state(handles.Be_matrix(imn,idx+1)+1));
end
cmd_state=lcaGet(handles.Be_cmd_pvs,0,'char');
cmd_state(3)=[]; %third atten disabled
SATT_status=0;
while SATT_status == 0
    satt_state=lcaGet(handles.Be_read_pvs,0,'char');
    satt_state(3)=[]; %third atten disabled
    SATT_status=isequal(satt_state,cmd_state);
    pause(1.);
end
get_SATT_status(hObject,handles);
set (handles.next_btn, 'Enable','on');

function adjust_gas_att(hObject,handles)
SATT_T = lcaGet('SATT:FEE1:320:RACT',0,'double');
Total_T=str2double(get(handles.maxT_txt,'String'));
GATT_T= Total_T/SATT_T;
set(handles.instruct_txt,'String',sprintf('Using EDM screen, manually adjust Gas Attenuator Actual Transmission to:\n\n %4.3e ',GATT_T));

% --- Acquire image from profile monitor
function handles=acquire_image(hObject,handles)
% satt_thickness=lcaGet('SATT:FEE1:320:TACT',0,'char');
SATT_T = lcaGet('SATT:FEE1:320:RACT',0,'double')
GATT_T = lcaGet('GATT:FEE1:310:R_ACT',0,'double')
Total_T = SATT_T * GATT_T
handles.totalT=Total_T;
set (handles.next_btn, 'Enable','off');
if (Total_T>.15) || (Total_T<.05)
    uiwait(msgbox('Attenuation not set properly','Warning message!','Warn'))
end
for idx=1:500
    %     FELpower(idx)=(lcaGet('GDET:FEE1:241:ENRCTH',0,'double')+lcaGet('GDET:FEE1:242:ENRCTH',0,'double'))/2;
    FELpower(idx)=lcaGet('GDET:FEE1:241:ENRC',0,'double');
end
avgPower=mean(FELpower)
handles.avgP=avgPower;
if (avgPower<.5)
    uiwait(msgbox('FEL power too low','Warning message!','Warn'))
end
if handles.debug
    handles.cam='OTRS:LI24:807';
    bitShift=3;
    lcaPut([handles.cam ':SHIFT'],bitShift); %set bit shift explicitly
    set(handles.sensitivity_sl,'Value',8-bitShift);
    handles=sensitivityControl(hObject,handles,8-bitShift,8);
    guidata(hObject, handles);
    get_profmon_status(hObject,handles);
    handles=grab_image(hObject, handles);
    guidata(hObject, handles);
    set (handles.next_btn, 'Enable','on');
    return
else
    cam={'CAMR:FEE1:1953','CAMR:FEE1:2953','CAMR:FEE1:913'};
    curr_station=get_station_status(hObject,handles);
    ax=handles.img_ax;
    switch curr_station
        case 'AMO'
            handles.cam=cam{1};
            bitShift=3;
        case 'SXR'
            handles.cam=cam{2};
            bitShift=3;
        case 'HXL'
            handles.cam=cam{3};
            bitShift=3;
    end
    lcaPut([handles.cam ':SHIFT'],bitShift); %set bit shift explicitly
    set(handles.sensitivity_sl,'Value',8-bitShift);
    handles=sensitivityControl(hObject,handles,8-bitShift,8);
    guidata(hObject, handles);
    profmon_activate(handles.cam,1,0);
    pm_status=0;
    while pm_status == 0 %delay loop to let pop-in move
        pm_status=lcaGet([handles.cam ':POSITION'],0,'double');
        pause(1.);
    end
    get_profmon_status(hObject,handles);
    handles=grab_image(hObject, handles);
    guidata(hObject, handles);
end
set (handles.next_btn, 'Enable','on');
% --- Retracts 3 popins 
function retract_popins(hObject,handles)
cam={'CAMR:FEE1:1953','CAMR:FEE1:2953','CAMR:FEE1:913'};
for idx=1:length(cam)
    profmon_activate(cam{idx},0,1);
end
pm_status=1;
for idx=1:length(cam)
    while ~(pm_status == 0) %delay loop to let pop-in move
        pm_status=lcaGet([cam{idx} ':POSITION'],0,'double');
        pause(.1);
    end
    pm_status=1;
end
get_profmon_status(hObject,handles);
lcaPut('CAMR:XTOD:SELECT',0);
pause (.5);
trigStatus=lcaGet('CAMR:XTOD:SELECT',0,'double')
% handles.Be_cmd_pvs = {
%                     'SATT:FEE1:321:CMD'
%                     'SATT:FEE1:322:CMD'
%                     'SATT:FEE1:323:CMD'
%                     'SATT:FEE1:324:CMD'
%                     'SATT:FEE1:325:CMD'
%                     'SATT:FEE1:326:CMD'
%                     'SATT:FEE1:327:CMD'
%                     'SATT:FEE1:328:CMD'
%                     'SATT:FEE1:329:CMD'};
% for idx=1:length(handles.Be_cmd_pvs)
%     lcaPut(handles.Be_cmd_pvs(idx),'OUT');
% end
% pause(1.);
% get_SATT_status(hObject,handles);
                

 % --- Saves motor and LVDT vals    
function save_motor_params(hObject,handles)
curr_station=get_station_status(hObject,handles);
switch curr_station
    case 'AMO'
        lcaPut('MIRR:FEE1:0561:SAVE',1);
        lcaPut('MIRR:FEE1:1811:SAVE',1);
    case 'SXR'
        lcaPut('MIRR:FEE1:0561:SAVE',1);
        lcaPut('MIRR:FEE1:2811:SAVE',1);
    case 'HXL'
        lcaPut('MIRR:FEE1:1561:SAVE',1);
end
% --- Saves motor and LVDT vals    
function handles=get_motor_position(hObject,handles)
M1S_X=lcaGet('STEP:FEE1:1561:MOTR.RBV',0,'CHAR');
M1S_dX=lcaGet('STEP:FEE1:1562:MOTR.RBV',0,'CHAR');
M3_X=lcaGet('STEP:FEE1:1811:MOTR.RBV',0,'CHAR');
M3_dX=lcaGet('STEP:FEE1:1812:MOTR.RBV',0,'CHAR');
set(handles.m1sX_txt, 'String', M1S_X);
set(handles.m1sdX_txt, 'String', M1S_dX);
set(handles.m3X_txt, 'String', M3_X);
set(handles.m3dX_txt, 'String', M3_dX);
guidata(hObject, handles);

% --- Get new station
function get_station(hObject,handles)
set(handles.stationSelAMO_btn, 'Visible', 'on');
set(handles.stationSelSXR_btn, 'Visible', 'on');
set(handles.stationSelHXL_btn, 'Visible', 'on');

function printToLog(hFig,hObject,handles)
curr_station=get_station_status(hObject,handles);
author='FEE_MirrorSwitch_gui';
energy=handles.photonEnergy
transmission=handles.totalT
bitshift=handles.bitShift
note=sprintf('Photon E: %6.1f, Total T: %3.2f, bitShift: %d, avgPower: %5.3f', ... 
    handles.photonEnergy, handles.totalT, handles.bitShift, handles.avgP);
switch curr_station
    case 'AMO'
        title='AMO: P3S1';
    case 'SXR'
        title='SXR: P3S2';
    case 'HXL'
        title='XPP: P3H';
end
util_printLog_wComments(hFig,author,title,note);

% --- Moves mirrors to select correct station
function move_mirrors(hObject,handles)
set (handles.next_btn, 'Enable','off');
guidata (hObject,handles);
lcaPut('MIRR:FEE1:1560:LOCK', 1) % Unlock M1
switch handles.new_station
    case 'AMO'
        lcaPutNoWait('MIRR:FEE1:1810:LOCK', 1) % Unlock M3
        lcaPutNoWait('MIRR:FEE1:0561:MOVE',1);
        lcaPutNoWait('MIRR:FEE1:1811:MOVE',1);
        while lcaGet('MIRR:FEE1:0561:POSITION',0,'double') == 0 || ...
                lcaGet('MIRR:FEE1:1811:POSITION',0,'double') == 0
            get_motor_position(hObject,handles);
            pause (1.);
        end
    case 'SXR'
        lcaPutNoWait('MIRR:FEE1:1810:LOCK', 1) % Unlock M3
        lcaPutNoWait('MIRR:FEE1:0561:MOVE',1);
        lcaPutNoWait('MIRR:FEE1:2811:MOVE',1);
        while lcaGet('MIRR:FEE1:0561:POSITION',0,'double') == 0 || ...
                lcaGet('MIRR:FEE1:2811:POSITION',0,'double') == 0
            get_motor_position(hObject,handles);
            pause (1.);
        end
    case 'HXL'
        lcaPutNoWait('MIRR:FEE1:1561:MOVE',1);
        while lcaGet('MIRR:FEE1:0561:POSITION',0,'double') == 0
            get_motor_position(hObject,handles);
            pause (1.);
        end
end
lcaPut('MIRR:FEE1:1810:LOCK', 0) % Lock M3
lcaPut('MIRR:FEE1:1560:LOCK', 0) % Lock M1
set (handles.next_btn, 'Enable','on');
get_motor_position(hObject,handles);
get_station_status(hObject,handles);
guidata (hObject,handles);

% --- Moves Joe's B4C    
function move_B4C(hObject,handles,val)
lcaPut('YAGS:DMP1:500:FOIL2_PNEU',val);


% -----------------------------------------------------------------------
function handles = state_update(hObject,handles)
curr_state=get(handles.state_pmu, 'Value');
set(handles.instruct_txt,'String',sprintf(handles.states.exec_txt{curr_state}));
guidata(hObject, handles);
set (handles.next_btn, 'Enable','on');
switch curr_state
    case 7
        set(handles.stationSelAMO_btn, 'Visible', 'on');
        set(handles.stationSelSXR_btn, 'Visible', 'on');
        set(handles.stationSelHXL_btn, 'Visible', 'on');
        set(handles.energy_btn, 'Visible', 'off');
    case 9
        set(handles.stationSelAMO_btn, 'Visible', 'off');
        set(handles.stationSelSXR_btn, 'Visible', 'off');
        set(handles.stationSelHXL_btn, 'Visible', 'off');
        set(handles.energy_btn, 'Visible', 'on');
    case 8
        set(handles.stationSelAMO_btn, 'Visible', 'off');
        set(handles.stationSelSXR_btn, 'Visible', 'off');
        set(handles.stationSelHXL_btn, 'Visible', 'off');
        set(handles.energy_btn, 'Visible', 'off');
        set (handles.next_btn, 'Enable','off');
    case {5, 14}
        set(handles.sensitivity_sl, 'Visible', 'on');
        set(handles.sensitivityLabel_txt, 'Visible', 'on');
        set(handles.sensitivity_txt, 'Visible', 'on');
    otherwise
        set(handles.stationSelAMO_btn, 'Visible', 'off');
        set(handles.stationSelSXR_btn, 'Visible', 'off');
        set(handles.stationSelHXL_btn, 'Visible', 'off');
        set(handles.energy_btn, 'Visible', 'off');
        set(handles.sensitivity_sl, 'Visible', 'off');
        set(handles.sensitivityLabel_txt, 'Visible', 'off');
        set(handles.sensitivity_txt, 'Visible', 'off');
end
eval(handles.action{curr_state});
handles=status_update(hObject,handles);
guidata(hObject, handles);
% -----------------------------------------------------------    
function handles = grab_image(hObject, handles)
guidata(hObject,handles);
bitShift=lcaGet([handles.cam ':SHIFT'],0,'double')
handles.bitShift=bitShift;
handles.data=profmon_grab(handles.cam,0,[]);
handles=bitsControl(hObject,handles,[],handles.data.bitdepth);
guidata(hObject, handles);
plot_image(hObject,handles);

% -----------------------------------------------------------
function handles = plot_image(hObject, handles)
if ~isfield(handles,'data'), return, end
data=handles.data;
ax=handles.img_ax;
crossV=lcaGetSmart(strcat(data.name,{':X';':Y'},'_BM_CTR'));
[cross.x,cross.y,cross.units,cross.isRaw]=deal(crossV(1),crossV(2),'mm',0);
bits=handles.bits.iVal;
profmon_imgPlot(data,'axes',ax,'useBG',0, ...
    'title',['Profile Monitor %s ' datestr(data.ts,'dd-mmm-yyyy HH:MM:SS')], ...
    'bits',bits*(bits > 4),'cross',cross);
% beam=profmon_process(data,'back',0,'useCal',1);
% handles.profFig=gcf;
% control_profDataSet(data.name,beam);
% printToLog(figure(1),hObject,handles);
% guidata(hObject, handles);

% -----------------------------------------------------------
function handles = process_image(hObject, handles)
if ~isfield(handles,'data'), return, end
data=handles.data;
beam=profmon_process(data,'back',0,'useCal',1);
handles.profFig=gcf;
control_profDataSet(data.name,beam);
printToLog(figure(1),hObject,handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function bits_sl_Callback(hObject, eventdata, handles)
handles=bitsControl(hObject,handles,round(get(hObject,'Value')),[]);
plot_image(hObject,handles);

% --- Executes on sensitivity slider movement.
function sensitivity_sl_Callback(hObject, eventdata, handles)
handles=sensitivityControl(hObject,handles,round(get(hObject,'Value')),[]);
bitShift=8-handles.sensitivity.iVal;
lcaPut([handles.cam ':SHIFT'],bitShift); %set bit shift explicitly
handles = grab_image(hObject, handles);
guidata(hObject,handles);

% -----------------------------------------------------------
function handles = bitsControl(hObject, handles, val, nVal)
handles=gui_sliderControl(hObject,handles,'bits',val,nVal);
str=num2str(handles.bits.iVal);if handles.bits.iVal == 4, str='Auto';end
set(handles.bits_txt,'String',str);
% -----------------------------------------------------------
function handles = sensitivityControl(hObject, handles, val, nVal)
handles=gui_sliderControl(hObject,handles,'sensitivity',val,nVal);
str=num2str(handles.sensitivity.iVal);
set(handles.sensitivity_txt,'String',str);
% -----------------------------------------------------------

function m1sdX_txt_Callback(hObject, eventdata, handles)
% hObject    handle to m1sdX_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m1sdX_txt as text
%        str2double(get(hObject,'String')) returns contents of m1sdX_txt as a double

function m1sX_txt_Callback(hObject, eventdata, handles)
% hObject    handle to m1sX_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m1sX_txt as text
%        str2double(get(hObject,'String')) returns contents of m1sX_txt as a double

function m3X_txt_Callback(hObject, eventdata, handles)
% hObject    handle to m3X_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m3X_txt as text
%        str2double(get(hObject,'String')) returns contents of m3X_txt as a double

function m3dX_txt_Callback(hObject, eventdata, handles)
% hObject    handle to m3dX_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m3dX_txt as text
%        str2double(get(hObject,'String')) returns contents of m3dX_txt as a double

% --- Executes on button press in energy_btn.
function execute_btn_Callback(hObject, eventdata, handles)
% hObject    handle to energy_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when user attempts to close FEE_MirrorSwitch_gui.
function FEE_MirrorSwitch_gui_CloseRequestFcn(hObject, eventdata, handles)
retract_popins(hObject,handles);
util_appClose(hObject);

% --- Executes on button press in help_btn.
function help_btn_Callback(hObject, eventdata, handles)
% hObject    handle to help_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
system(['ggv ' 'FEE_Mirror_Switching_GUI_documentation.pdf']); 



function maxT_txt_Callback(hObject, eventdata, handles)
% hObject    handle to maxT_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxT_txt as text
%        str2double(get(hObject,'String')) returns contents of maxT_txt as a double


% --- Executes during object creation, after setting all properties.
function maxT_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxT_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





