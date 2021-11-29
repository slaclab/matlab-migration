function varargout = SXRSS_BOD_gui(varargin)
% SXRSS_BOD_GUI M-file for SXRSS_BOD_gui.fig
%      SXRSS_BOD_GUI, by itself, creates a new SXRSS_BOD_GUI or raises the existing
%      singleton*.
%
%      H = SXRSS_BOD_GUI returns the handle to a new SXRSS_BOD_GUI or the handle to
%      the existing singleton*.
%
%      SXRSS_BOD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SXRSS_BOD_GUI.M with the given input arguments.
%
%      SXRSS_BOD_GUI('Property','Value',...) creates a new SXRSS_BOD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SXRSS_BOD_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to SXRSS_BOD_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SXRSS_BOD_gui

% Last Modified by GUIDE v2.5 29-May-2014 16:17:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SXRSS_BOD_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SXRSS_BOD_gui_OutputFcn, ...
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


% --- Executes just before SXRSS_BOD_gui is made visible.
function SXRSS_BOD_gui_OpeningFcn(hObject, eventdata, handles, varargin)

global timerRunning1;
global timerRestart1;
global timerDelay1;
global timerData1;

timerRunning1= false;
timerRestart1= false;
timerDelay1= 1;      % sec
timerData1.hObject= hObject;

% Choose default command line output for SXRSS_BOD_gui
handles.output = hObject;

set(handles.image_ax,'PlotBoxAspectRatio',[1392 1040 1]);

handles.bufd=1;
handles.nAverage=1;
handles.dataStream=0;
handles.displayExport=0;


handles.activePV1 = 1;
handles.activePV2 = 10;


active=11;
handles=appInit(hObject,handles);
handles.PVList={ ...
    'CAMR:IN20:186'
    'YAGS:UND1:1005'
    'YAGS:UND1:1305'
    };

handles.PVId=15;

set(handles.uipanel15, 'SelectionChangeFcn', ...
    {@uipanel15_SelectionChangeFcn, handles}) %setup uipanel

set(handles.uipanel16, 'SelectionChangeFcn', ...
    {@uipanel16_SelectionChangeFcn, handles}) %setup uipanel

lcaPutSmart('SIOC:SYS0:ML01:AO899',1); %set Active PV to 1 'U10'

for j=1:length(handles.PVList)
    handles.bg{j}=0;
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SXRSS_BOD_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SXRSS_BOD_gui_OutputFcn(hObject, eventdata, handles) 
global timerData1;
global timerRunning1;

varargout{1} = handles.output;

handles=RefreshGUI(handles);
if timerRunning1
   timerData1.handles = handles;
end
guidata(hObject, handles);




function handles = appInit(hObject, handles)

global timerData1;

set(handles.text87,'String','q','FontName','symbol') %theta

handles.sepPV = {...
    'SIOC:SYS0:ML01:AO801';...
    'SIOC:SYS0:ML01:AO802';...
    'SIOC:SYS0:ML01:AO803';...
    'SIOC:SYS0:ML01:AO804';...
    };

handles.Offset10PV = 'SIOC:SYS0:ML01:AO805';
handles.Offset13PV = 'SIOC:SYS0:ML01:AO806';

handles=modeManager(hObject, handles);
states = handles.states;

handles.parameters.tags={
    'readGirderX_txt';...
    'readGirderY_txt';...
    'readEbeamX_txt';...
    'readEbeamY_txt';...
    'readWireX_txt';...
    'readWireY_txt';...
    'readXrayX_txt';...
    'readXrayY_txt';...
    'readSepX_txt';...
    'readSepY_txt';...
    'readScreenX_txt';...
    'readScreenY_txt';...
    };

handles.parameters.pv={...
    'SIOC:SYS0:ML01:AO820';...
    'SIOC:SYS0:ML01:AO821';...
    'SIOC:SYS0:ML01:AO826';...
    'SIOC:SYS0:ML01:AO827';...
    'SIOC:SYS0:ML01:AO838';...
    'SIOC:SYS0:ML01:AO839';...
    'SIOC:SYS0:ML01:AO831';...
    'SIOC:SYS0:ML01:AO832';...
    'SIOC:SYS0:ML01:AO801';...
    'SIOC:SYS0:ML01:AO802';...
    'YAGS:UND1:1005:X_BM_CTR';...    %removed 'SIOC:SYS0:ML01:AO842';...
    'YAGS:UND1:1005:Y_BM_CTR';...    %removed 'SIOC:SYS0:ML01:AO843';...
    };

handles.readback.BODreadPV.double33={...
    'GRAT:UND1:934:X:MOTOR.RBV';...
    'GRAT:UND1:934:Y:MOTOR.RBV';...
    'MIRR:UND1:966:X:MOTOR.RBV';...
    'MIRR:UND1:966:P:MOTOR.RBV';...
    'MIRR:UND1:966:O:MOTOR.RBV';...
    'MIRR:UND1:936:P:MOTOR.RBV';...
    'SIOC:SYS0:ML01:AO814';...
    'SIOC:SYS0:ML01:AO815';...
    'SIOC:SYS0:ML01:AO817';...
    'SIOC:SYS0:ML01:AO818';...
    'SIOC:SYS0:ML01:AO819';...
    'SIOC:SYS0:ML01:AO816';...
    };

handles.readback.BODtag.double33={...
    'readG1X_txt';...
    'readG1Y_txt';...
    'readM3X_txt';...
    'readM3P_txt';...
    'readM3O_txt';...
    'readPitchMono2_txt';...
    'nextReadG1X_txt';...
    'nextReadG1Y_txt';...
    'nextReadM3X_txt';...
    'nextReadM3P_txt';...
    'nextReadM3O_txt';...
    'nextReadPitchMono2_txt';...
    };


handles.readback.BODtag.string={...
    'readG1_txt';...
    'readM2_txt';...
    'readM3_txt';...
    'readBODU10_txt';...
    'readBODU13_txt';...
    };

handles.readback.BODreadPV.string={...
    'GRAT:UND1:934:X:LOCATIONSTAT';...
    'MIRR:UND1:964:X:LOCATIONSTAT';...
    'MIRR:UND1:966:X:LOCATIONSTAT';...
    'BOD:UND1:1005:LOCATIONSTAT';...
    'BOD:UND1:1305:LOCATIONSTAT';...
    };


active1=handles.activePV1;
active2=handles.activePV2;
active=active1+active2;
handles.active=active;


handles.readback.BODtag.double3={...
    'readBODX_txt'...
    'dx_txt'...
    'readMoveBOD10X_txt'...
    'readMoveBOD10Y_txt'...
    'readMoveBOD13X_txt'...
    'readMoveBOD13Y_txt'...
    };

if states == 1 || states ==2

    handles.readback.readPV.image='YAGS:UND1:1005';
%     handles.readback.BODreadPV.double3={...
%         'BOD:UND1:1005:ACT';...
%         };
else
    handles.readback.readPV.image='YAGS:UND1:1305';
%     handles.readback.BODreadPV.double3={...
%         'BOD:UND1:1305:ACT';...
%         };
end

handles.readback.BODreadPV.double3={...
    'BOD:UND1:1005:ACT';...
    'BOD:UND1:1305:ACT';...
    };

handles = initGUI(handles);
if ~ispc
    lcaSetMonitor(handles.readback.BODreadPV.double3);
    lcaSetMonitor(handles.readback.BODreadPV.double33);
    lcaSetMonitor(handles.readback.BODreadPV.string);
    lcaSetMonitor(handles.parameters.pv);
end

handles.PV=handles.readback.readPV.image;
guidata(hObject,handles);





function handles = grab_image(hObject, handles)

guidata(hObject,handles);
[d,is]=profmon_names(handles.PV);
nImg=[];
if handles.bufd && is.Bufd
    nImg=0;
    lcaPutSmart([handles.PV ':SAVE_IMG'],1);
end
%data=profmon_grabSeries(handles.PV,handles.nAverage,0,'bufd',handles.bufd);
ts=-Inf;if isfield(handles,'data'), ts=handles.data.ts;end
for j=1:handles.nAverage

    ts0=ts;
    while ts <= ts0
        data(j)=profmon_grab(handles.PV,0,nImg);ts=data(j).ts;
        if handles.nAverage < 2, ts=Inf;end
    end
end

handles.data=data(1);

if numel(data) > 1
    handles.data.img=feval(class(data(1).img),mean(cat(4,data.img),4));
end

%handles.data.back=handles.bg{handles.PVId};
handles.data.back=0;
handles.process.saved=0;
handles = plot_image(hObject,handles,1);
guidata(hObject,handles);


function handles = plot_image(hObject, handles, update)

if ~isfield(handles,'data'), return, end
data=handles.data;
if ~data.img(end), data.img(end)=max([min(data.img(1:end-1)) 0]);end

ax=handles.image_ax;
if handles.displayExport
    handles.exportFig=figure;
    ax=subplot(1,1,1,'Box','on');
end

pvs=handles.parameters.pvs;
crossV1=lcaGetSmart(handles.yagXCTR);
crossV2=lcaGetSmart(handles.yagYCTR);

%crossV=lcaGetSmart(strcat(data.name,{':X';':Y'},'_BM_CTR'));
%[cross.x,cross.y,cross.units,cross.isRaw]=deal(crossV1,crossV2,'mm',0);

profmon_imgPlot(data,'axes',ax,'useBG',0);



function pv_txt_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function pv_txt_CreateFcn(hObject, eventdata, handles)
%

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)
acquireStart(hObject, eventdata, handles);




function acquireStart(hObject, eventdata, handles)

handles=appInit(hObject,handles);
tags={'Start' 'Stop'};
cols=[.502 1 .502;1 .502 .502];
style=strcmp(get(hObject,'Type'),'uicontrol');
state=gui_acquireStatusGet(hObject,handles);
if style, set(hObject,'String',tags{state+1},'BackgroundColor',cols(state+1,:));end
if state, profmon_evrSet(handles.PV);end

while gui_acquireStatusGet(hObject,handles)
    handles = grab_image(hObject,handles);
    pause(0.05);
    guidata(hObject,handles);
    handles=guidata(hObject);
end




function BODX_txt_Callback(hObject, eventdata, handles)
BODX_input = str2double(get(handles.BODX_txt,'String'));
handles=modeManager(hObject, handles);
motorpvs = handles.motors.pv;

if get(handles.guiActive_checkbox, 'Value');
    BODX_input_old=lcaGetSmart(motorpvs(3));
    if isnan(BODX_input)
        set(handles.BODX_txt,'String', BODX_input_old);
    else
        disp(BODX_input)
        lcaPutSmart(motorpvs(1), BODX_input);
        lcaPutSmart(motorpvs(2), 1);
    end
else
    disp('GUI Not Active...BODX_txt_callback')
end



% --- Executes during object creation, after setting all properties.
function BODX_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function handles=updateGUIvals(hObject,handles)
global timerData1;


set (handles.datestr_txt,'String',datestr(now));

if ~ispc
    idx = find(lcaNewMonitorValue(handles.readback.BODreadPV.double3));
    if ~isempty(idx)
        val=lcaGet(handles.readback.BODreadPV.double3(idx),0,'double');
        for loopcnt=1:length(idx)
            %str=sprintf('%6.3f',val(loopcnt));
            states =  handles.states;
            if states == 1 || states == 2
                str=sprintf('%6.3f',val(1));
            elseif states ==3 || states ==4 
                str=sprintf('%6.3f',val(1));
            end
            %set(handles.(handles.readback.BODtag.double3{idx(loopcnt)}),'String',str);
            set(handles.readBODX_txt,'String',str)
        end
    end

    idx = find(lcaNewMonitorValue(handles.readback.BODreadPV.double33));
    if ~isempty(idx)
        val=lcaGet(handles.readback.BODreadPV.double33(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%6.3f',val(loopcnt));
            set(handles.(handles.readback.BODtag.double33{idx(loopcnt)}),'String',str);
        end
    end

    idx = find(lcaNewMonitorValue(handles.parameters.pv));
    if ~isempty(idx)
        val=lcaGet(handles.parameters.pv(idx),0,'double');

        val(11:12)=val(11:12)*1e3; %change BM_CTR pv to um
        for loopcnt=1:length(idx)
            str=sprintf('%6.0f',val(loopcnt));
            set(handles.(handles.parameters.tags{idx(loopcnt)}),'String',str);
        end
    end

    idx = find(lcaNewMonitorValue(handles.readback.BODreadPV.string));
    if ~isempty(idx)
        val=lcaGetSmart(handles.readback.BODreadPV.string(idx));
        for loopcnt=1:length(idx)
            set(handles.(handles.readback.BODtag.string{idx(loopcnt)}),'String',val(loopcnt));

        end
    end
end



function handles=initGUI(handles)

val=lcaGet(handles.readback.BODreadPV.double3,0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.3f',val(loopcnt));
    set(handles.(handles.readback.BODtag.double3{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.BODreadPV.double33(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.3f',val(loopcnt));
    set(handles.(handles.readback.BODtag.double33{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.parameters.pv(:),0,'double');

val(11:12)=val(11:12)*1e3; %change BM_CTR pv to um
for loopcnt=1:length(val)
    str=sprintf('%6.0f',val(loopcnt));
    set(handles.(handles.parameters.tags{loopcnt}),'String',str);
end

val=lcaGetSmart(handles.readback.BODreadPV.string(:));
for loopcnt=1:length(val)
set(handles.(handles.readback.BODtag.string{loopcnt}),'String',val(loopcnt));
end



function handles=RefreshGUI(handles)
global timerObj1;
global timerDelay1;
global timerRestart1;
global timerRunning1;
global timerData1;
if (timerRunning1)
    stop (timerObj1);
end

f=gcf;
timerObj1=timer('TimerFcn', @(obj, eventdata) timer_Callback(f), 'Period', 2.0, 'ExecutionMode', 'fixedRate', 'BusyMode','drop' );
timerRestart1 = true;
timerData1.handles = handles;
start (timerObj1);
timerRunning1 = true;



function timer_Callback (handleToGuiFigure)
% global timerData1;
% global timerRunning1;

handles=guidata(handleToGuiFigure);

% handles    = timerData1.handles;
% hObject    = timerData1.hObject;
handles=updateGUIvals(handleToGuiFigure,handles);
guidata (handleToGuiFigure, handles );



function Girder_txt_Callback(hObject, eventdata, handles)

Girder_input_old=lcaGetSmart(handles.readback.BODreadPV.double3(2));
Girder_input = str2double(get(hObject,'String'));

if isnan(Girder_input)
    set(hObject,'String', Girder_input_old);
else lcaPutSmart(handles.readback.BODreadPV.double3(2), Girder_input);
    handles=appInit(hObject,handles);
end



% --- Executes during object creation, after setting all properties.
function Girder_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WireX_txt_Callback(hObject, eventdata, handles)
pvs = handles.parameters.pvs;


Xray_input_old=lcaGetSmart(pvs(5));
Xray_input = str2double(get(hObject,'String'));

if isnan(Xray_input)
    set(hObject,'String', Xray_input_old);
else 
    lcaPutSmart(pvs(5), Xray_input);
end
handles = updateGUI2(handles);



% --- Executes during object creation, after setting all properties.
function WireX_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bodOut_button.
function bodOut_button_Callback(hObject, eventdata, handles)
val=get(handles.guiActive_checkbox, 'Value');
if val==0
    disp('GUI NOT ACTIVE....bodOut_button');
elseif val ==1
    lcaPutSmart('BOD:UND1:1005:EXTRACT.PROC', 1);
    lcaPutSmart('BOD:UND1:1305:EXTRACT.PROC', 1);
end

    


% --- Executes on button press in bodIn_button.
function bodIn_button_Callback(hObject, eventdata, handles)
val=get(handles.guiActive_checkbox, 'Value');
states = handles.states;

if val==0
    disp('GUI NOT ACTIVE....bodIn_button');
    disp(states)
elseif val ==1

    if states ==1 || states ==2 %U10
        lcaPutSmart('BOD:UND1:1005:INSERT.PROC', 1);
        lcaPutSmart('BOD:UND1:1305:EXTRACT.PROC', 1);
    elseif states ==3 || states ==4 %U13
        lcaPutSmart('BOD:UND1:1305:INSERT.PROC', 1);
        lcaPutSmart('BOD:UND1:1005:EXTRACT.PROC', 1);
    end
end



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;



% --- Executes on button press in acquireStart2_btn.
function acquireStart2_btn_Callback(hObject, eventdata, handles)
states=handles.states;
n=handles.N;
devName = handles.device;
pvs = handles.parameters.pvs;
processSelectPlane = handles.dim;


%find girder coords
geo=girderGeo;
p=girderAxisFind(n,geo.bodz,geo.quadz);
p=p(:,1:2)*1e3;    
girderX=p(1); girderY=p(2); %Both in um
lcaPutSmart(pvs(1), girderX);
lcaPutSmart(pvs(2), girderY);


%Wire Scan
if get(handles.dev_checkbox, 'Value')
    data=wirescan_gui('appQuery',0,devName,processSelectPlane)
else
    if get(handles.guiActive_checkbox, 'Value')
    data=wirescan_gui('appRemote',0,devName,processSelectPlane)
    end
end

d=data.beam(1).stats; %um [x y]

switch states
    case 1 
        d=d(1);
        pv=pvs(3);

    case 2 
        d=d(2);
        pv=pvs(4);

    case 3
        d=d(1);
        pv=pvs(3);

    case 4
        d=d(2);
        pv=pvs(4);
        
end

lcaPutSmart(pv,d);
set(handles.ebeamDateX_txt, 'String', lcaGetSmart(handles.ebeamDateX))
set(handles.ebeamDateY_txt, 'String', lcaGetSmart(handles.ebeamDateY))

handles = updateGUI2(handles);


%Get Wire Positions


if get(handles.guiActive_checkbox, 'Value')
    profmon_lampSet(handles.yagpv,1,1); % Turn on target lamp
    %lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL', 0); % Disable beam
end

data1=profmon_measure(handles.yagpv,1,'nBG',0,'doProcess',0,'doPlot',0,'bufd',1,'nAvg',10);

if states == 1 || states == 2
    posx=[640 710 425 465];    % BOD10 crop area for X-wire
    posy=[640 670 480 510];   % BOD10 crop area for Y-wire

elseif states == 3 || states == 4
    posx=[700 740 530 560]; %BOD13 crop area for X-wire
    posy=[660 700 470 510]; %BOD13 crop area for Y-wire
end

datax=profmon_imgCrop(data1,posx); % Crop image for X-wire
datay=profmon_imgCrop(data1,posy); % Crop image for Y-wire
beamx=profmon_process(datax); % Get stats
beamy=profmon_process(datay); % Get stats

if get(handles.guiActive_checkbox, 'Value')
    profmon_lampSet(handles.yagpv,0,1); % Turn off target lamp
end

%lcaPutSmart('IOC:BSY0:MP01:BYKIKCTL', 1); % Allow Beam
lcaPutSmart(pvs(5), beamx(1).stats(1));
lcaPutSmart(pvs(6), beamy(1).stats(2));




% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
%


function edit7_Callback(hObject, eventdata, handles)
%



% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
%

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
%

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
%



% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
%



% --- Executes on button press in minusX.
function minusX_Callback(hObject, eventdata, handles)
if get(handles.guiActive_checkbox, 'Value');
    handles = modeManager(hObject, handles);
    motorpvs = handles.motors.pv;
    val=lcaGetSmart(motorpvs(3));
    dx=lcaGetSmart(motorpvs(4));
    set(handles.dx_txt, 'string', dx)
    newVal = val-dx;
    lcaPutSmart(motorpvs(1), newVal);
    lcaPutSmart(motorpvs(2), 1);
end



% --- Executes on button press in plusX.
function plusX_Callback(hObject, eventdata, handles)
if get(handles.guiActive_checkbox, 'Value');
    handles=modeManager(hObject, handles);
    motorpvs = handles.motors.pv;
    val=lcaGetSmart(motorpvs(3));
    dx=lcaGetSmart(motorpvs(4));
    set(handles.dx_txt, 'string', dx)
    newVal = val+dx;
    lcaPutSmart(motorpvs(1), newVal);
    lcaPutSmart(motorpvs(2), 1);
end



% --- Executes on button press in guiActive_checkbox.
function guiActive_checkbox_Callback(hObject, eventdata, handles)
val=get(handles.guiActive_checkbox, 'Value');
if val==0
    set(handles.active_text,'Visible','On')
elseif val ==1
    set(handles.active_text,'Visible','Off')
end




% --- Executes on button press in go_button.
function go_button_Callback(hObject, eventdata, handles)
if get(handles.guiActive_checkbox,'Value');
    
    
    handles.G1Y_old = lcaGetSmart('GRAT:UND1:934:Y:ACT');
    handles.M3X_old = lcaGetSmart('MIRR:UND1:966:X:ACT');
    handles.M3P_old = lcaGetSmart('MIRR:UND1:966:P:ACT');
    handles.M3Roll_old = lcaGetSmart('MIRR:UND1:966:O:ACT');
    guidata(hObject, handles);
    
    
    
    G1Y_new=lcaGetSmart('SIOC:SYS0:ML01:AO815');
    M3X_new=lcaGetSmart('SIOC:SYS0:ML01:AO817');
    M3P_new=lcaGetSmart('SIOC:SYS0:ML01:AO818');
    M3Roll_new=lcaGetSmart('SIOC:SYS0:ML01:AO819');


    lcaPutSmart('GRAT:UND1:934:Y:DES', G1Y_new);
    lcaPutSmart('MIRR:UND1:966:X:DES', M3X_new);
    lcaPutSmart('MIRR:UND1:966:P:DES', M3P_new);
    lcaPutSmart('MIRR:UND1:966:O:DES', M3Roll_new);


    lcaPutSmart('GRAT:UND1:934:Y:TRIM.PROC', 1);
    lcaPutSmart('MIRR:UND1:966:X:TRIM.PROC', 1);
    lcaPutSmart('MIRR:UND1:966:P:TRIM.PROC', 1);
    lcaPutSmart('MIRR:UND1:966:O:TRIM.PROC', 1);
else
    disp('Gui Not Active....Go Button');
end



function WireY_txt_Callback(hObject, eventdata, handles)
pvs = handles.parameters.pvs;


Xray_input_old=lcaGetSmart(pvs(6));
Xray_input = str2double(get(hObject,'String'));
if isnan(Xray_input)
    set(hObject,'String', Xray_input_old);
else
    lcaPutSmart(pvs(6), Xray_input);
end
handles = updateGUI2(handles);



% --- Executes during object creation, after setting all properties.
function WireY_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% 


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% 

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% 


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% 

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XrayX_txt_Callback(hObject, eventdata, handles)
pvs = handles.parameters.pvs;
Xray_input_old=lcaGetSmart(pvs(7));
Xray_input = str2double(get(hObject,'String'));
if isnan(Xray_input)
    set(hObject,'String', Xray_input_old);
else
    lcaPutSmart(pvs(7), Xray_input);
end
handles = updateGUI2(handles);



% --- Executes during object creation, after setting all properties.
function XrayX_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XrayY_txt_Callback(hObject, eventdata, handles)
pvs = handles.parameters.pvs;
Xray_input_old=lcaGetSmart(pvs(8));
Xray_input = str2double(get(hObject,'String'));
if isnan(Xray_input)
    set(hObject,'String', Xray_input_old);
else
    lcaPutSmart(pvs(8), Xray_input);
end
handles = updateGUI2(handles);



% --- Executes during object creation, after setting all properties.
function XrayY_txt_CreateFcn(hObject, eventdata, handles)
%

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when selected object is changed in uipanel140.
function uipanel15_SelectionChangeFcn(hObject, eventdata, handles)
newButton=get(eventdata.NewValue,'tag');

switch newButton
    case 'radiobuttonU10'
        

    case 'radiobuttonU13'

end
handles = modeManager(handles.figure1, handles);



% --- Executes when selected object is changed in uipanel140.
function uipanel16_SelectionChangeFcn(hObject, eventdata, handles)
newButton=get(eventdata.NewValue,'tag');

switch newButton
    case 'radiobuttonX'


    case 'radiobuttonY'

end
handles = modeManager(handles.figure1, handles);


function handles=modeManager(hObject, handles)

BOD=get(get(handles.uipanel15,'SelectedObject'), 'Tag');
DIM=get(get(handles.uipanel16,'SelectedObject'), 'Tag');

if strcmp(BOD, 'radiobuttonU10') && strcmp(DIM,'radiobuttonX')
    states=1;
    plane='x';
elseif strcmp(BOD, 'radiobuttonU10') && strcmp(DIM,'radiobuttonY')
    states=2;
    plane='y';
elseif strcmp(BOD, 'radiobuttonU13') && strcmp(DIM,'radiobuttonX')
    states=3;
    plane='x';
elseif strcmp(BOD, 'radiobuttonU13') && strcmp(DIM,'radiobuttonY')
    states=4;
    plane='y';
end


if states == 1 || states ==2

    handles.motors.pv={...
        'BOD:UND1:1005:DES';...
        'BOD:UND1:1005:TRIM.PROC';...
        'BOD:UND1:1005:ACT';...
        'BOD:UND1:1005:MOTOR.TWV';...
        };
    
    handles.parameters.pvs={...
        'SIOC:SYS0:ML01:AO820';...
        'SIOC:SYS0:ML01:AO821';...
        'SIOC:SYS0:ML01:AO826';...
        'SIOC:SYS0:ML01:AO827';...
        'SIOC:SYS0:ML01:AO838';...
        'SIOC:SYS0:ML01:AO839';...
        'SIOC:SYS0:ML01:AO831';...
        'SIOC:SYS0:ML01:AO832';...
        'SIOC:SYS0:ML01:AO801';...
        'SIOC:SYS0:ML01:AO802';...
        };
    
    handles.yagXCTR = 'YAGS:UND1:1005:X_BM_CTR';        
    handles.yagYCTR = 'YAGS:UND1:1005:Y_BM_CTR';       
    handles.ebeamDateX = 'SIOC:SYS0:ML01:AO828TS';      
    handles.ebeamDateY = 'SIOC:SYS0:ML01:AO829TS';      
    
    
    handles.yagpv='YAGS:UND1:1005';
    DevName = 'BOD10';
    n = 10;
    set(handles.textUnum, 'String','U10 BODX')


elseif states == 3  || states == 4

    handles.motors.pv={...
        'BOD:UND1:1305:DES';...
        'BOD:UND1:1305:TRIM.PROC';...
        'BOD:UND1:1305:ACT';...
        'BOD:UND1:1305:MOTOR.TWV';...
        };


    handles.parameters.pvs={...
        'SIOC:SYS0:ML01:AO822';...
        'SIOC:SYS0:ML01:AO823';...
        'SIOC:SYS0:ML01:AO828';...
        'SIOC:SYS0:ML01:AO829';...
        'SIOC:SYS0:ML01:AO840';...
        'SIOC:SYS0:ML01:AO841';...
        'SIOC:SYS0:ML01:AO833';...
        'SIOC:SYS0:ML01:AO834';...
        'SIOC:SYS0:ML01:AO803';...
        'SIOC:SYS0:ML01:AO804';...
        'SIOC:SYS0:ML01:AO828TS';...
        'SIOC:SYS0:ML01:AO829TS';...     
        };
           
    handles.yagXCTR = 'YAGS:UND1:1305:X_BM_CTR';        
    handles.yagYCTR = 'YAGS:UND1:1305:Y_BM_CTR';        
    handles.ebeamDateX = 'SIOC:SYS0:ML01:AO828TS';      
    handles.ebeamDateY = 'SIOC:SYS0:ML01:AO829TS';      
    
    handles.yagpv='YAGS:UND1:1305';...


    DevName = 'BOD13';
    n = 13;
    set(handles.textUnum, 'String','U13 BODX')

end

handles.states=states;
handles.dim=plane;
handles.N=n;
handles.device=DevName;

guidata(hObject, handles);
handles = updateGUI2(handles);


function handles = updateGUI2(handles)
pvs=handles.parameters.pvs;
motorpvs = handles.motors.pv;
states =  handles.states;


vals = lcaGetSmart(pvs,0,'double');
WX=vals(5); WY=vals(6);
GX=vals(3); GY=vals(4);
GX0=vals(1); GY0=vals(2);
XrayX=vals(7);XrayY=vals(8);

EbeamScreenX= WX+GX-GX0;
EbeamScreenY= WY+GY-GY0;

lcaPutSmart(handles.yagXCTR, EbeamScreenX*1e-3);
lcaPutSmart(handles.yagYCTR, EbeamScreenY*1e-3);


SepX = XrayX - EbeamScreenX;
SepY = XrayY - EbeamScreenY;

lcaPutSmart(pvs(9), SepX);
lcaPutSmart(pvs(10), SepY);


set(handles.readGirderX_txt, 'string', sprintf('%6.0f', vals(1)));
set(handles.readGirderY_txt, 'string', sprintf('%6.0f', vals(2)));
set(handles.readEbeamX_txt, 'string', sprintf('%6.0f', vals(3)));
set(handles.readEbeamY_txt, 'string', sprintf('%6.0f', vals(4)));
set(handles.readWireX_txt, 'string', sprintf('%6.0f', vals(5)));
set(handles.readWireY_txt, 'string', sprintf('%6.0f', vals(6)));
set(handles.readScreenX_txt, 'string', sprintf('%6.0f', EbeamScreenX));
set(handles.readScreenY_txt, 'string', sprintf('%6.0f', EbeamScreenY));
set(handles.readXrayX_txt, 'string', sprintf('%6.0f', vals(7)));
set(handles.readXrayY_txt, 'string', sprintf('%6.0f', vals(8)));  
set(handles.readSepX_txt, 'string', sprintf('%6.0f', SepX));
set(handles.readSepY_txt, 'string', sprintf('%6.0f', SepY)); 


vals2=lcaGetSmart(motorpvs,0,'double');
set(handles.readBODX_txt, 'string', sprintf('%6.3f', vals2(3)));
set(handles.BODX_txt,  'string', sprintf('%6.3f',lcaGetSmart(motorpvs(3))));
set(handles.WireX_txt,'string', sprintf('%6.0f',lcaGetSmart(pvs(5))));
set(handles.WireY_txt, 'string', sprintf('%6.0f',lcaGetSmart(pvs(6))));
set(handles.XrayX_txt, 'string', sprintf('%6.0f',lcaGetSmart(pvs(7))));
set(handles.XrayY_txt, 'string', sprintf('%6.0f',lcaGetSmart(pvs(8)))); 
set(handles.ebeamDateX_txt, 'string', lcaGetSmart(handles.ebeamDateX));
set(handles.ebeamDateY_txt, 'string', lcaGetSmart(handles.ebeamDateY));


%old set button
%opts = 2;
%M1P=lcaGetSmart('MIRR:UND1:936:P:ACT');
G1Y=lcaGetSmart('GRAT:UND1:934:Y:ACT');
M3X=lcaGetSmart('MIRR:UND1:966:X:ACT');
M3P=lcaGetSmart('MIRR:UND1:966:P:ACT');
M3Roll=lcaGetSmart('MIRR:UND1:966:O:ACT');

sep = lcaGetSmart(handles.sepPV);
off1 = get(handles.Offset10_txt, 'String');
off2 = get(handles.Offset13_txt, 'String');

off = [str2double(off1) str2double(off2)];
off = off*-1;


[A, B] = SXRSS_bodSteer(sep, off);
set(handles.readMoveBOD10X_txt, 'string', sprintf('%6.0f', -B(1)));
set(handles.readMoveBOD10Y_txt, 'string', sprintf('%6.0f', -B(2)));
set(handles.readMoveBOD13X_txt, 'string', sprintf('%6.0f', -B(3)));
set(handles.readMoveBOD13Y_txt, 'string', sprintf('%6.0f', -B(4)));

newG1Y = G1Y+A(1);
newM3X = M3X+A(2);
newM3P = M3P+A(3);
newM3Roll =  M3Roll+A(4);

lcaPutSmart('SIOC:SYS0:ML01:AO815', newG1Y);
lcaPutSmart('SIOC:SYS0:ML01:AO817', newM3X);
lcaPutSmart('SIOC:SYS0:ML01:AO818', newM3P);
lcaPutSmart('SIOC:SYS0:ML01:AO819', newM3Roll);
guidata(handles.output, handles);


% --- Executes on button press in takeBG_button.
function takeBG_button_Callback(hObject, eventdata, handles)
if get(handles.guiActive_checkbox, 'Value');
M1P=lcaGetSmart('MIRR:UND1:936:P:ACT',0,'double');

buttonState=get(handles.takeBG_button,'Value');
switch buttonState
    case 1
        lcaPutSmart('MIRR:UND1:936:P:DES', M1P+0.5);
        lcaPutSmart('MIRR:UND1:936:P:TRIM.PROC', 1);
        set(handles.seed_disabled_txt, 'Visible', 'on');
    case 0

        lcaPutSmart('MIRR:UND1:936:P:DES', M1P-0.5);
        lcaPutSmart('MIRR:UND1:936:P:TRIM.PROC', 1);
        set(handles.seed_disabled_txt, 'Visible', 'off');
end
else
    disp('GUI Not Active ...Take BG')
end


% --- Executes on button press in dev_checkbox.
function dev_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to dev_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dev_checkbox



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- Executes on button press in togglebutton4.
function togglebutton4_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton4


% --- Executes on button press in lampPow_button.
function lampPow_button_Callback(hObject, eventdata, handles)
status=get(handles.lampPow_button, 'Value');
profmon_lampSet(handles.yagpv,status,0); 





% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global timerRunning1;
global timerObj1;
stop ( timerObj1 );
pause (2);
if ~ispc
    util_appClose(hObject);
    pause(2.5);
end
if ispc
    delete (hObject);
end


% --- Executes on button press in elog_button.
function elog_button_Callback(hObject, eventdata, handles)
set(handles.figure1,'Units','characters')
figColor=get(handles.figure1,'Color');
pos=get(handles.figure1,'Position');

handles.exportFig=figure;
set(handles.exportFig,'Units','characters','Position',pos);
set(handles.exportFig,'PaperSize',[pos(3) pos(4)+2]);
set (handles.exportFig,'Color',figColor);
ch = get(handles.figure1, 'children');

if ~isempty(ch)
    nh = copyobj(ch,handles.exportFig);
end;
set (nh,'Units','characters');

util_printLog_wComments(handles.exportFig,'SXRSS_BOD_gui',[960 800]);
close(handles.exportFig);



function Offset10_txt_Callback(hObject, eventdata, handles)
Offset10_input = str2double(get(handles.Offset10_txt,'String'));
Offset10_input_old=lcaGetSmart(handles.Offset10PV);
if isnan(Offset10_input)
    Offset10_input = Offset10_input_old;
   set(handles.Offset10_txt,'String', Offset10_input_old);
end
lcaPutSmart(handles.Offset10PV, Offset10_input);
handles = updateGUI2(handles);

% --- Executes during object creation, after setting all properties.
function Offset10_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Offset13_txt_Callback(hObject, eventdata, handles)
Offset13_input = str2double(get(handles.Offset13_txt,'String'));
Offset13_input_old=lcaGetSmart(handles.Offset13PV);
if isnan(Offset13_input)
    Offset13_input = Offset13_input_old;
   set(handles.Offset13_txt,'String', Offset13_input_old);
end
lcaPutSmart(handles.Offset13PV, Offset13_input);

% --- Executes during object creation, after setting all properties.
function Offset13_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in undo_button.
function undo_button_Callback(hObject, eventdata, handles)
lcaPutSmart('GRAT:UND1:934:Y:DES', handles.G1Y_old);
lcaPutSmart('MIRR:UND1:966:X:DES', handles.M3X_old);
lcaPutSmart('MIRR:UND1:966:P:DES', handles.M3P_old);
lcaPutSmart('MIRR:UND1:966:O:DES', handles.M3Roll_old);

lcaPutSmart('GRAT:UND1:934:Y:TRIM.PROC', 1);
lcaPutSmart('MIRR:UND1:966:X:TRIM.PROC', 1);
lcaPutSmart('MIRR:UND1:966:P:TRIM.PROC', 1);
lcaPutSmart('MIRR:UND1:966:O:TRIM.PROC', 1);
