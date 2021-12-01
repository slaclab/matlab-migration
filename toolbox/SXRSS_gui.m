function varargout = SXRSS_B_gui(varargin)
% SXRSS_B_GUI MATLAB code for SXRSS_B_gui.fig
%      SXRSS_B_GUI, by itself, creates a new SXRSS_B_GUI or raises the existing
%      singleton*.
%
%      H = SXRSS_B_GUI returns the handle to a new SXRSS_B_GUI or the handle to
%      the existing singleton*.
%
%      SXRSS_B_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SXRSS_B_GUI.M with the given input arguments.
%
%      SXRSS_B_GUI('Property','Value',...) creates a new SXRSS_B_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SXRSS_B_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SXRSS_B_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SXRSS_B_gui

% Last Modified by GUIDE v2.5 25-Oct-2021 21:56:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SXRSS_B_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SXRSS_B_gui_OutputFcn, ...
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


% --- Executes just before SXRSS_B_gui is made visible.
function SXRSS_B_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;

timerRunning= false;
timerRestart= false;
timerDelay= 1;      % sec
timerData.hObject= hObject;
% Choose default command line output for SXRSS_B_gui
handles.output = hObject;

handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SXRSS_B_gui_OutputFcn(hObject, eventdata, handles) 
  
global timerData;
global timerRunning;
% Get default command line output from handles structure
varargout{1} = handles.output;
handles=RefreshGUI(handles);
if timerRunning
timerData.handles = handles;
end   
varargout{1} = handles.output;


function handles=appInit(hObject,handles)
handles.readback.tag.string={...
    'readChicanePower_txt';...
    'readChicaneStatus_txt';...
   };

handles.readback.readPV.string={...
    'BEND:UNDS:3510:STATE';... %'readChicanePower_txt'
    'BEND:UNDS:3510:CTRLSTATE';...  %'readChicaneStatus_txt'
    }; 

handles.readback.tag.double3={...
     'readPhaseMono_txt';...
    'readBdes_txt';...
    'readBact_txt';...
    'readChicane1_txt';...
    'readChicane2_txt';...
    'readChicane3_txt';...
    'readChicane4_txt';...
    'readChicane5_txt';...
    'readChicane6_txt';...
    'readChicane7_txt';...
    'readChicane8_txt';...
    };
     
handles.readback.readPV.double3={...
    'SIOC:SYS0:ML01:AO810';...
    'BEND:UNDS:3510:BDES';...  
    'BEND:UNDS:3510:BACT';  
    'BEND:UNDS:3510:IDES';...
    'BEND:UNDS:3510:IACT';...        
    'BEND:UNDS:3530:IDES';...
    'BEND:UNDS:3530:IACT';...
    'BEND:UNDS:3550:IDES';...
    'BEND:UNDS:3550:IACT';...
    'BEND:UNDS:3570:IDES';...
    'BEND:UNDS:3570:IACT';...
    };  

handles.readback.tag.int={...
    'readDelayMono_txt';...
    };

handles.readback.readPV.int={...
    'SIOC:SYS0:ML01:AO809';... 
    };

handles.readback.tag.double2={...
    'readR56Mono_txt';...
    'readDxMono_txt';...
    };

handles.readback.readPV.double2={...
    'SIOC:SYS0:ML01:AO813';... 'r56Mono_txt';
    'SIOC:SYS0:ML01:AO812';...   
    };


handles.editBoxPvs={'SIOC:SYS0:ML00:AO627';'SIOC:SYS0:ML01:AO809';'SIOC:SYS0:ML01:AO810';
};
handles.delayPV='SIOC:SYS0:ML01:AO809'; %delay 
%handles.delay_old=lcaGetSmart(handles.delayPV);
handles.phasePV='SIOC:SYS0:ML01:AO810'; %Angstroms
handles.phaseDegPV='SIOC:SYS0:ML01:AO908'; %Degrees
handles.xposPV='SIOC:SYS0:ML01:AO812'; %displacement of ebeam
handles.R56PV='SIOC:SYS0:ML01:AO813'; %R56 Matrix Element
%handles.modePV='SIOC:SYS0:ML01:AO900'; % Mode
handles.bdesPV='BEND:UNDS:3510:BDES';
handles.magnetMainPV='BEND:UNDS:3510';
handles.magnetTrimPV={'BTRM:UNDS:3510'; 'BTRM:UNDS:3530'; 'BTRM:UNDS:3550'; 'BTRM:UNDS:3570'};
handles.photonEnergyPV='SIOC:SYS0:ML00:AO628';
handles.tdundPV='DUMP:LTUS:972:PNEUMATIC';
handles.bykikPV='IOC:BSY0:MP01:BYKIKSCTL';  %O-OFF 1-0N
handles.dumpEnergyPV='BEND:DMPS:400:BDES';
handles.bendStatePV='BEND:UNDS:3510:STATE';
handles.trimPVs={'BTRM:UNDS:3510:BACT';'BTRM:UNDS:3530:BACT'; 'BTRM:UNDS:3550:BACT'; 'BTRM:UNDS:3570:BACT'};
handles = initGUI(handles);

pvs=handles.readback.readPV;
monitorPVs = unique([pvs.string; pvs.double2;pvs.double3;pvs.int]);
lcaSetMonitor(monitorPVs);



 function handles=updateGUIvals(hObject,handles)
 set (handles.datestr_txt,'String',datestr(now));    
 if ~ispc    
     idx = find(lcaNewMonitorValue(handles.readback.readPV.double3));
     if ~isempty(idx)
         val=lcaGetSmart(handles.readback.readPV.double3(idx),0,'double');
         for loopcnt=1:length(idx)
             str=sprintf('%6.3f',val(loopcnt));
             set(handles.(handles.readback.tag.double3{idx(loopcnt)}),'String',str);
         end
         listenval= get(handles.listen_checkbox, 'Value'); % 1 is checked
         if listenval == 1
             if idx(1) ==1
               handles=adjustChicane(handles,1,1);
             end
         end
         
     end
     

    idx = find(lcaNewMonitorValue(handles.readback.readPV.double2));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.double2(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%6.2f',val(loopcnt));
            set(handles.(handles.readback.tag.double2{idx(loopcnt)}),'String',str);
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.readback.readPV.int));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.int(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%3.0f',val(loopcnt));
            set(handles.(handles.readback.tag.int{idx(loopcnt)}),'String',str);
        end
        listenval= get(handles.listen_checkbox, 'Value'); % 1 is checked
         if listenval == 1
             if idx(1) ==1
               handles=adjustChicane(handles,1,0);
             end
         end
    end
    
    idx = find(lcaNewMonitorValue(handles.readback.readPV.string));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.readPV.string(idx));
        for loopcnt=1:length(idx)
            set(handles.(handles.readback.tag.string{idx(loopcnt)}),'String',val(loopcnt));
        end
    end
    v = get(handles.(['delay' '_slider']),'value');
    set(handles.delay_sliderRB_txt, 'String', num2str(v))
    
 end
    
 
 
function updateGUInow(hObject,handles)
    val=lcaGetSmart(handles.readback.readPV.double3,0,'double');
    for loopcnt=1:length(val)
        str=sprintf('%6.3f',val(loopcnt));
        set(handles.(handles.readback.tag.double3{(loopcnt)}), 'String', str);
    end
    
    val=lcaGetSmart(handles.readback.readPV.double2,0,'double');
    for loopcnt=1:length(val)
        str=sprintf('%6.2f',val(loopcnt));
        set(handles.(handles.readback.tag.double2{(loopcnt)}), 'String', str);
    end
    
    val=lcaGetSmart(handles.readback.readPV.string);
    for loopcnt=1:length(val)
        str=val(loopcnt);
        set(handles.(handles.readback.tag.string{(loopcnt)}), 'String', str);
    end
  
    
RefreshGUI(handles);

 
function handles=initGUI(handles)
    
val=lcaGetSmart(handles.readback.readPV.double3(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.3f',val(loopcnt));
    set(handles.(handles.readback.tag.double3{loopcnt}),'String',str);
end
val=lcaGetSmart(handles.readback.readPV.string(:));
for loopcnt=1:length(val)
    set(handles.(handles.readback.tag.string{loopcnt}),'String',val(loopcnt));
end

val=lcaGetSmart(handles.readback.readPV.double2(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.2f',val(loopcnt));
    set(handles.(handles.readback.tag.double2{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.readPV.double3(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.3f',val(loopcnt));
    set(handles.(handles.readback.tag.double3{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.readPV.int(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%d',val(loopcnt));
    set(handles.(handles.readback.tag.int{loopcnt}),'String',str);
end     
     
 
function handles=RefreshGUI(handles)
global timerObj;
global timerDelay;
global timerRestart;
global timerRunning;
global timerData;
if (timerRunning)
    stop (timerObj);
end

ff=handles.output;
timerObj=timer('TimerFcn', @(obj, eventdata) timer_Callback(ff) , 'Period', timerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop' );
timerRestart = true;
timerData.handles = handles;
start(timerObj);
timerRunning = true;

 

function timer_Callback (handleToGuiFigure0)
% global timerData;
% global timerRunning;
% handles    = timerData.handles;
% hObject    = timerData.hObject;
handles = guidata(handleToGuiFigure0); % added to unlock handles 
handles = updateGUIvals(handleToGuiFigure0, handles);
guidata (handleToGuiFigure0, handles );
%timerData.handles = handles;



% --- Executes on button press in chicanePowerOn_button.
function chicanePowerOn_button_Callback(hObject, eventdata, handles)
dev = get(handles.dev_checkbox, 'Value');
if ~dev
    lcaPutSmart(handles.tdundPV, 0); %Insert
    control_magnetSet('BCXSS1',[],'action','TURN_ON');
    pause(2);
    control_magnetSet('BCXSS1',[],'action','STDZ');
    %set chicane to delay to zero when turning on / sets trims to extra (or
    %less needed according to polynomials
    val =lcaGet(handles.delayPV);
    energy=lcaGet(handles.dumpEnergyPV);
    [BDES,~,~,~,~] = BCSS_adjust(val,energy,'SXRSS');
    magPV=[handles.magnetMainPV;handles.magnetTrimPV(2:4)];
    control_magnetSet(magPV,BDES,'wait',.25)
    %control_magnetSet({'BCXSS2_TRIM' 'BCXSS3_TRIM' 'BCXSS4_TRIM'}, BDES,'action','TRIM');
    lcaPutSmart(handles.tdundPV, 1); %Insert
end

% --- Executes on button press in chicanePowerOff_button.
function chicanePowerOff_button_Callback(hObject, eventdata, handles)
dev = get(handles.dev_checkbox, 'Value');
if ~dev
    lcaPutSmart(handles.tdundPV, 0); %Insert
    control_magnetSet({'BCXSS1_TRIM' 'BCXSS2_TRIM' 'BCXSS3_TRIM' 'BCXSS4_TRIM'}, 0,'action','TRIM');
    control_magnetSet('BCXSS1',[],'action','DEGAUSS');
    lcaPutSmart(handles.tdundPV, 1); %Extract
end
%add a readback for the status PV no log needed

function delay_txt_Callback(hObject, eventdata, handles)
val = get(handles.delay_txt,'String');
val = str2double(val);
if isnan(val), val=lcaGetSmart(handles.delayPV); end 
lcaPutSmart(handles.delayPV, val);
set(handles.delay_slider,'Value', val);
energy=lcaGetSmart(handles.dumpEnergyPV);
chicanePower=strcmp(lcaGetSmart(handles.bendStatePV),'ON');

if chicanePower  %delay adjust
    [BDES,~,xpos,~,R56] = BCSS_adjust(val, energy, 'SXRSS');
    lcaPutSmart(handles.bdesPV, BDES(1));
    lcaPutSmart(handles.R56PV,R56);
    lcaPutSmart(handles.xposPV, 1000*xpos);
    
    steerVal= get(handles.steerCor_checkbox, 'Value');
    if steerVal
        BDES=[abs(BDES(1)) BDES(5:8)];
    end
    moveMagnet(BDES, handles)

end
         
         
% --- Executes during object creation, after setting all properties.
function delay_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function phase_txt_Callback(hObject, eventdata, handles)
dev = get(handles.dev_checkbox, 'Value');   
val = get(handles.phase_txt,'String');
val = str2double(val);
if isnan(val), val=lcaGetSmart(handles.phasePV); end 
lcaPutSmart(handles.phasePV, val);
energy=lcaGetSmart(handles.dumpEnergyPV);
chicanePower=strcmp(lcaGetSmart('BEND:UND1:940:STATE'),'ON');
if chicanePower == 1 %phase adjust
    lambda=12398.4/lcaGet(handles.photonEnergyPV);
    phase=360*val/lambda;   %Degrees
    period=floor(phase/360.0);
    phaseDeg=phase-period*360;
    [BDES,theta,Itrim,R56] = BC_phase(val,energy,'SXRSS');
    lcaPutSmart(handles.phaseDegPV, phaseDeg);
    lcaPutSmart(handles.R56PV,R56);
    BDES(1:4)=BDES;
    magPV=handles.magnetTrimPV;
    if ~dev
        control_magnetSet(magPV,BDES,'wait',.25)
    end
end





% --- Executes during object creation, after setting all properties.
function phase_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stdz.
function stdz_Callback(hObject, eventdata, handles)
dev = get(handles.dev_checkbox, 'Value');
    valbykik=lcaGet(handles.bykikPV,0,'short');
if valbykik == 0  %If beam Disabled
    lcaPutSmart(handles.bykikPV,1); %Enable Beam
end
pause(1.);
if ~dev
    control_magnetSet('BCXSS1',BDES(1),'action','STDZ');
end



function handles=adjustChicane(handles,adjust,stdz)
dev = get(handles.dev_checkbox, 'Value');
if nargin<3, stdz=0; end
if nargin<2, adjust=0;end

stdz=1;
energy=lcaGetSmart(handles.dumpEnergyPV);

chicanePower=strcmp(lcaGetSmart(handles.dumpEnergyPV),'ON');

if chicanePower == 1 %phase adjust
    Angstroms=lcaGet(handles.phasePV);
    set(handles.phase_txt,'String',sprintf('%3.2f',Angstroms));
    lambda=12398.4/lcaGet(handles.photonEnergyPV);
    phase=360*Angstroms/lambda;   %Degrees
    period=floor(phase/360.0);
    phaseDeg=phase-period*360;
    [BDES,theta,Itrim,R56] = BC_phase(Angstroms,energy,'SXRSS');
    lcaPutSmart(handles.phaseDegPV, phaseDeg);
    lcaPutSmart(handles.R56PV,R56);
    BDES(1:4)=BDES;
    magPV=handles.magnetTrimPV;
else
    %delay adjust
    delay=lcaGetSmart(handles.delayPV);
    [BDES,iMain,xpos,theta,R56] = BCSS_adjust(delay,energy,'SXRSS');
    lcaPutSmart(handles.bdesPV, BDES(1));
    lcaPutSmart(handles.R56PV,R56);
    lcaPutSmart(handles.xposPV, 1000*xpos);
    %oldtrims=lcaGet(handles.trimPVs(2:4)); %*added because polynomial trim soln obvioiusly wrong
    magPV=[handles.magnetMainPV;handles.magnetTrimPV(2:4)];
    
%     if stdz
%         lcaPutSmart(handles.tdundPV, 0); %Insert
%         pause(1.)
%         control_magnetSet(handles.magnetTrimPV(2:4),0,'wait',.25)
%         control_magnetSet('BCXSS1',BDES(1),'action','STDZ');
%     end
end
%BDES(2:4)=oldtrims;%*
steerVal= get(handles.steerCor_checkbox, 'Value');
if steerVal
    magPV=[handles.magnetMainPV;handles.magnetTrimPV(1:4)];
    BDES=[BDES(1) BDES(5:8)];
end
if ~dev
    control_magnetSet(magPV,BDES,'wait',.25)
end
%lcaPutSmart(handles.tdundPV, 1); 
lcaPut('SIOC:SYS0:ML02:AO325',1) %placed here to automate alberto's scan
%code


% --- Executes on button press in listen_checkbox.
function listen_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to listen_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of listen_checkbox


% --- Executes on slider movement.
function delay_slider_Callback(hObject, eventdata, handles)
newVal = get(handles.delay_slider,'value'); 
good = lcaPutSmart(handles.delayPV, newVal);
if good
    set(handles.delay_sliderRB_txt, 'String', num2str(newVal))
    energy=lcaGetSmart(handles.dumpEnergyPV);
    [BDES,~,xpos,~,R56] = BCSS_adjust(newVal,energy,'SXRSS');
    lcaPutSmart(handles.bdesPV, BDES(1));
    lcaPutSmart(handles.R56PV,R56);
    lcaPutSmart(handles.xposPV, 1000*xpos);
    chicanePower=strcmp(lcaGetSmart(handles.bendStatePV),'ON');
    if chicanePower  %delay adjust
        steerVal= get(handles.steerCor_checkbox, 'Value');
        if steerVal
            BDES=[BDES(1) BDES(5:8)];
        end
        moveMagnet(BDES, handles)
    end
end



% --- Executes during object creation, after setting all properties.
function delay_slider_CreateFcn(hObject, eventdata, handles)
set(hObject,'Min',0,'Max',1200,'Value',lcaGetSmart( 'SIOC:SYS0:ML01:AO809'));
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]); 
end




function steerCor_checkbox_Callback(hObject, eventdata, handles)

function dev_checkbox_Callback(hObject, eventdata, handles)

function moveMagnet(BDES, handles)
dev = get(handles.dev_checkbox, 'Value'); 
magPV=[handles.magnetMainPV;handles.magnetTrimPV(2:4)];

if ~dev
    control_magnetSet(magPV,BDES,'wait',.25)
else
    disp('devMode')
    disp(BDES)
end
