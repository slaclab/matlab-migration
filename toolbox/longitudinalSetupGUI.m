function varargout = longitudinalSetupGUI(varargin)
% LONGITUDINALSETUPGUI M-file for longitudinalSetupGUI.fig
%      LONGITUDINALSETUPGUI, by itself, creates a new LONGITUDINALSETUPGUI or raises the existing
%      singleton*.
%
%      H = LONGITUDINALSETUPGUI returns the handle to a new LONGITUDINALSETUPGUI or the handle to
%      the existing singleton*.
%
%      LONGITUDINALSETUPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LONGITUDINALSETUPGUI.M with the given input arguments.
%
%      LONGITUDINALSETUPGUI('Property','Value',...) creates a new LONGITUDINALSETUPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before longitudinalSetupGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to longitudinalSetupGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help longitudinalSetupGUI

% Last Modified by GUIDE v2.5 02-Jun-2014 13:49:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @longitudinalSetupGUI_OpeningFcn, ...
    'gui_OutputFcn',  @longitudinalSetupGUI_OutputFcn, ...
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


% --- Executes just before longitudinalSetupGUI is made visible.
function longitudinalSetupGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to longitudinalSetupGUI (see VARARGIN)

% Choose default command line output for longitudinalSetupGUI
handles.output = hObject;

%%%% Release version 1.0 23-May-2014 yocky
%%%% Updates:
%%%%           DD-MMM-YYYY username - comments about updates
%%%%

startLCLS
handles.PVList={ ...
    'PROF:LI20:2432' ...
    'PROF:LI20:3230' ...
    'PROF:LI20:3158' ...
    };
handles.PVId=[1 2 3];
handles.nPV=3;
handles.PV=handles.PVList(handles.PVId);
handles.bufd=1;
handles=bitsControl(hObject,handles,8,16);
handles.slice.plotSlice = 0;
handles.slice.Dir = 'y';
handles.slice.active = 0;
%handles=dataMethodControl(hObject,eventdata,handles,1,6);

handles.useBG=0;
handles.zoom=0;
handles.nAverage=1;
handles.zoomStats=0;
%handles.lampSel=0;
handles.dataStream=0;
handles.show.cal=1;
handles.show.stats=0;
handles.show.hist=0;
handles.show.rawImg=0;
handles.show.tcav=0;
handles.show.ener=0;
handles.show.lineOut=0;
handles.show.target.x=320;
handles.show.target.y=240;
handles.show.colorbar=0;
handles.show.bg=0;
handles.show.bmCross=0;
handles.displayExport=0;
%handles.calibrate=0;
%handles.cal.rad=8000;
%handles.cal.nFit=4;
%handles.fileName='';
%handles.process.saved=0;
%handles.gain=0;
%handles.exposureTime=0.05;
%handles.xPixelBin=1;
%handles.yPixelBin=1;
handles.profmonXSig=10;
handles.profmonYSig=10;
%
handles.tcav_box=[-1.5 -3.5 3 5];

util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',8);
[sys,accelerator]=getSystem;
handles.accelerator=accelerator;

handles.QFF.names={'LI20:LGPS:3011'...
    'LI20:LGPS:3031'...
    'LI20:LGPS:3091'...
    'LI20:LGPS:3141'...
    'LI20:LGPS:3151'...
    'LI20:LGPS:3261'...
    'LI20:LGPS:3311'};

% MIP 50x500cm quad settings as of 06-May-2014
%handles.QFF.MIP500=[144.56 -102.41 160 -605.42 429.61 214.54 -161.68];
QFF.pvs={'SIOC:SYS1:ML00:AO884'...
    'SIOC:SYS1:ML00:AO885'...
    'SIOC:SYS1:ML00:AO886'...
    'SIOC:SYS1:ML00:AO887'...
    'SIOC:SYS1:ML00:AO888'...
    'SIOC:SYS1:ML00:AO889'...
    'SIOC:SYS1:ML00:AO890'...
    };
handles.QFF.MIP500=lcaGetStruct(QFF,0,'Double');


handles.PartyTime=0;
handles.CurrentGUIFigure=hObject;


%Start the timer objects last

handles.UpdateTimer=timer('ExecutionMode', 'fixedDelay', 'Period', .1);
handles.UpdateTimer.BusyMode='queue';
handles.UpdateTimer.StartFcn=@(x,y)gui_messageDisp(handles,'Readback Timer Started');
handles.UpdateTimer.ErrorFcn=@(x,y)gui_messageDisp(handles,'Readback Timer Croaked');
handles.UpdateTimer.TimerFcn=@(x,y,w,z)timer_function(hObject,handles);


handles.ProfmonTimer=timer('ExecutionMode', 'fixedDelay', 'Period', 1);
handles.ProfmonTimer.BusyMode='drop';
%handles.ProfmonTimer.StartFcn=@(x,y)gui_messageDisp(handles,'Profmon Timer Started');
%handles.ProfmonTimer.ErrorFcn=@(x,y)gui_messageDisp(handles,'Profmon Timer Croaked');
handles.ProfmonTimer.TimerFcn=@(x,y)profTimer_function(hObject,handles);




global PrintData

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = longitudinalSetupGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start(handles.UpdateTimer);
start(handles.ProfmonTimer);

% Get default command line output from handles structure
varargout{1} = handles.output;

function party_time_Callback(hObject, eventdata, handles)
handles.PartyTime=(get(hObject,'Value'));
guidata(hObject,handles)

function party_time_CreateFcn(hObject, eventdata, handles)
handles.PartyTime=(get(hObject,'Value'));
guidata(hObject,handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Timers Start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function profTimer_function(hObject,handles)
handles = guidata(hObject);
if handles.AcquireStart==1
    handles.slice.plotSlice = 1;
    handles=grab_image(handles);
    handles=plot_image(hObject,handles);
else
    return
end


function timer_function(hObject,handles)
handles = guidata(hObject);
%functionalize this for more than just this one shit...
pvs.update.names={'TCAV:LI20:2400:S_AV'...
    'TCAV:LI20:2400:0:POC'...
    'COLL:LI20:2069:MOTR.RBV', 'COLL:LI20:2069:MOTR'... %Translation
    'COLL:LI20:2072:MOTR.RBV', 'COLL:LI20:2072:MOTR'... %Elevator
    'COLL:LI20:2085:MOTR.RBV', 'COLL:LI20:2085:MOTR'... %JawL
    'COLL:LI20:2086:MOTR.RBV', 'COLL:LI20:2086:MOTR'... %JawR
    'COLL:LI20:2073:MOTR.RBV', 'COLL:LI20:2073:MOTR'... %Yaw
    'DR12:PHAS:61:VACT'... %phase ramp, index=13
    'BLEN:LI20:3014:BRAW'...
    'LI02:GAPM:204:DATA'...
    'LI20:TORO:3255:DATA'...
    'EVNT:SYS1:1:BEAMRATE'...
    'LI18:GAPM:930:DATA'...
    'SIOC:SYS1:ML00:AO025'...
    'PROF:LI20:3230:BLEN'...%index=20
    'TCAV:LI20:2400:S_PV'...
    'DR13:AMPL:11:VACT'
    };
%    'SIOC:SYS1:ML00:SO0353'...
%    'SIOC:SYS1:ML00:AO354'...

Num_readbacks=10;

handles.TimerUpdateData=lcaGetStruct(pvs,0,'Double');
handles.TimerUpdateData.update.names(16)=handles.TimerUpdateData.update.names(16)/1e10; %get dump charge in 1e10
set(handles.TCAVAmpAct,'String',sprintf('%2.1f',  handles.TimerUpdateData.update.names(1)))
set(handles.nullPhase,'String',sprintf('%3.1f',  handles.TimerUpdateData.update.names(2)))
set(handles.waist_location,'String',sprintf('%5s', cell2mat(lcaGetSmart('SIOC:SYS1:ML00:SO0353'))))
set(handles.waist_beta_star,'String',sprintf('%2.1f', lcaGetSmart('SIOC:SYS1:ML00:AO354')))
set(handles.TCAV_on_stat,'String',sprintf('%6s',  cell2mat(lcaGetSmart('TCAV:LI20:2400:C_1_TCTL'))))

%Set Notch/Jaw readbacks
for ix=1:5
    set(handles.(strcat('notchAct_',num2str(ix))),'String',...
        sprintf('%5.1f', handles.TimerUpdateData.update.names(2*ix+1)))
    set(handles.(strcat('notch_',num2str(ix))),'String',...
        sprintf('%5.1f', handles.TimerUpdateData.update.names(2*ix+2)))
end

%Set "Readback" redbacks
for jx=1:Num_readbacks
    set(handles.(strcat('Readback_',num2str(jx))),'String',...
        sprintf('%5.1f', handles.TimerUpdateData.update.names(jx+12)))
    handles.TimerUpdateData.update.names(jx+12);
end

if handles.PartyTime==1
    PissOffNate=[rand rand rand];
    set(handles.figure1,'Color',PissOffNate)
else
   set(handles.figure1,'Color',[.871 .922 .98])%bbeeff
end

guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Timer END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Image Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%AXES CREATION
% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
stop(handles.ProfmonTimer);
set(gcf,'CurrentAxes',handles.axes2)
rectangle('Position',handles.tcav_box,'edgecolor',[.7 .7 .7],'linewidth',2,'linestyle','--');
point1 = get(gca,'CurrentPoint');
handles.finalRect = rbbox;
point2 = get(gca,'CurrentPoint');
point1 = point1(1,1:2);
point2 = point2(1,1:2);
p1 = min(point1,point2);
p2 = max(point1,point2);
handles.tcav_box = [p1(1),p1(2),p2(1)-p1(1),p2(2)-p1(2)];
rectangle('Parent',handles.axes2,'Position',handles.tcav_box,'edgecolor','r','linewidth',2,'linestyle','--');
drawnow;
start(handles.ProfmonTimer);
guidata(hObject,handles);

function axes4_CreateFcn(hObject, eventdata, handles)
%handles.axes4=get(gcf,'CurrentAxes');
function handles = bitsControl(hObject, handles, val, nVal)

handles=gui_sliderControl(hObject,handles,'bits',val,nVal);
str=num2str(handles.bits.iVal);
if handles.bits.iVal == 4
    str='Auto';
end
set(handles.bitsLabel_txt,'String',str);

% --- Executes on slider movement.
function bits_sl_Callback(hObject, eventdata, handles)

handles=bitsControl(hObject,handles,round(get(hObject,'Value')),[]);
plot_image(hObject,handles);

function bits_sl_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%GRAB IMAGE
function handles = grab_image(handles)
[d,is]=profmon_names(handles.PV);
nImg=[];
for j=1:3
    if ~handles.PVId(j)
        continue
    end
    % Return if FACET camera is in data acquisition mode.
    if is.FACET(j) && ~is.AreaDet(j) && lcaGetSmart(strcat(handles.PV(j),':TRIGGER_DAQ'),0,'double')
        cla(handles.image_ax);
        text(0,0,['Profile Monitor ' handles.PV ' DAQ Trigger Enabled'], ...
            'Parent',handles.image_ax,'HorizontalAlignment','center', ...
            'Color',rand(1,3),'FontSize',20);
        pause(0.01);
        sprintf('DAQ')
        return
    end
    if handles.bufd && is.Bufd(j)
        nImg=0;
        lcaPutSmart([handles.PV{j} ':SAVE_IMG'],1);
    end
    try
        handles.data(j)=profmon_grab(handles.PV{j},0,nImg);
    catch
        gui_messageDisp(handles,'What?');
    end
end

% PLOT IMAGE
function handles = plot_image(hObject,handles)
global PrintData
if ~isfield(handles,'data'), return, end
for j=1:3
    str=num2str(j);
    ax=handles.(['axes' str]);
    if ~handles.PVId(j) || numel(handles.data) < j || isempty(handles.data(j).name)
        cla(ax,'reset');
        set(ax,'Box','on');
        continue
    end
    data=handles.data(j);
    bits=handles.bits.iVal;
    switch j
        case 1
            handles.data(1).img=handles.data(1).img(1:end/2,:);
            if isfield(handles,'bg1')
                handles.data(1).back=handles.bg1(1:end/2,:);
            end
        case 2
            if isfield(handles,'bg2')
                handles.data(2).back=handles.bg2;
            end
        case 3
            if isfield(handles,'bg3')
                handles.data(3).back=handles.bg3;
            end
    end
    profmon_imgPlot(handles.data(j),'axes',handles.(['axes' str]),'useBG',1, ...
        'cal',1,'colormap','jet','figure',handles.CurrentGUIFigure,...
        'title',['%s ' datestr(handles.data(j).ts,'dd-mmm-yyyy HH:MM:SS')], ...
        'bits',bits*(bits > 4));
    datestr(handles.data(j).ts);
    if j==2
        set(handles.CurrentGUIFigure,'CurrentAxes',handles.axes2)
        rectangle('Parent',handles.axes2,'Position',handles.tcav_box,'edgecolor','r','linewidth',2,'linestyle','--');
        drawnow;
    end
end
handles=bunch_separation(handles);
handles=PlotTwoBunch(handles);
PrintData=handles;

%%%%GRAB BG
function bg_btn_Callback(hObject, eventdata, handles)
handles=guidata(hObject);
try
    bg3=profmon_grabBG(handles.PV{3},handles.nAverage,'bufd',1);
    if exist('bg3')
        handles.bg3=mean(cat(4,bg3.img),4);
        gui_messageDisp(handles,'USOTR BG Grabbed');
    end
catch
    gui_messageDisp(handles,'BG not acquired for USOTR');
end
try
    bg2=profmon_grabBG(handles.PV{2},handles.nAverage,'bufd',1);
    if exist('bg2')
        handles.bg2=mean(cat(4,bg2.img),4);
        gui_messageDisp(handles,'IP2B BG Grabbed');
    end
catch
    gui_messageDisp(handles,'BG not acquired for IP2B');
end
try
    bg1=profmon_grabBG(handles.PV{1},handles.nAverage,'bufd',1);
    if exist('bg1')
        handles.bg1=mean(cat(4,bg1.img),4);
        gui_messageDisp(handles,'SYAG BG Grabbed');
    end
catch
    gui_messageDisp(handles,'BG not acquired for SYAG');
end
guidata(hObject,handles);

%%%SINGLE SHOT
function single_btn_Callback(hObject, eventdata, handles)
handles.slice.plotSlice = 1;
handles=grab_image(handles);
handles=plot_image(hObject,handles);

% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)
handles.AcquireStart=get(hObject, 'Value');
switch handles.AcquireStart;
    case 1
        set(hObject,'String','Start')
    case 0
        set(hObject,'String','Stop')
end
guidata(hObject,handles)

function acquireStart_btn_CreateFcn(hObject, eventdata, handles)
if isfield(handles,'AcquireStart')==0
    handles.AcquireStart=0;
end
guidata(hObject,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End Image plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%
%Profile Monitor Controls
%%%%%%%%%%%%%%%%%%%%%%%%

% --- IP2B ladder control
function IP2Bcontrol_Callback(hObject, eventdata, handles)
IP2BIN=lcaGetSmart('SIOC:SYS1:ML00:AO860');
IP2BOUT=lcaGetSmart('SIOC:SYS1:ML00:AO861');
InOutStat=get(hObject, 'Value');
switch InOutStat;
    case 1
        lcaPutSmart('OTRS:LI20:3230:MOTR',IP2BIN);
        set(hObject,'String','Retract IP2B')
    case 0
        lcaPutSmart('OTRS:LI20:3230:MOTR',IP2BOUT);
        set(hObject,'String','Insert IP2B #1')
end

function IP2Bcontrol_ButtonDownFcn(hObject, eventdata, handles)

function USOTRControl_Callback(hObject, eventdata, handles)
USOTRIN=lcaGetSmart('SIOC:SYS1:ML00:AO869');
USOTROUT=lcaGetSmart('SIOC:SYS1:ML00:AO870');
InOutStat=get(hObject, 'Value');
switch InOutStat;
    case 1
        lcaPutSmart('OTRS:LI20:3158:MOTR',USOTRIN);
        set(hObject,'String','Retract USOTR')
    case 0
        lcaPutSmart('OTRS:LI20:3158:MOTR',USOTROUT);
        set(hObject,'String','Insert USOTR')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Profile Monitor Controls END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%
%TCAV Contols start
%%%%%%%%%%%%%%%%%%%

function TCAV_AMP_set_Callback(hObject, eventdata, handles)
TCAVADES=str2double(get(hObject,'String'));
lcaPut('TCAV:LI20:2400:ADES',TCAVADES);

function TCAV_AMP_set_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('TCAV:LI20:2400:ADES'))

function nullPhase_Callback(hObject, eventdata, handles)
NullOffset=str2double(get(hObject,'String'));
lcaPut('TCAV:LI20:2400:0:POC',NullOffset);

function nullPhase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('TCAV:LI20:2400:0:POC'))

function TCAVAmpAct_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('TCAV:LI20:2400:S_AV'))

function zeroX_ctrl_Callback(hObject, eventdata, handles)
zeroXing=str2double(get(hObject,'String'));
lcaPut('TCAV:LI20:2400:PDES',zeroXing);

function zeroX_ctrl_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('TCAV:LI20:2400:PDES'))


%%%TCAV ON OFF
function tcav_onoff_Callback(hObject, eventdata, handles)
OnOffStat=get(hObject, 'Value');
%act=control_klysStatSet('KLYS:LI20:41',double(logical(OnOffStat)));
control_tcavPAD(OnOffStat,'XTCAVF')
switch OnOffStat;
    case 1
        set(hObject,'String','Turn TCAV OFF')
        set(hObject,'BackgroundColor',[.5 .5 0])
    case 0
        set(hObject,'String','Turn TCAV ON')
        set(hObject,'BackgroundColor',[1 1 0])
end

%TCAV ONOFF READBACK
function TCAV_on_stat_Callback(hObject, eventdata, handles)
function TCAV_on_stat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%Phase ramp
function phs_rmp_ctrl_Callback(hObject, eventdata, handles)
CurrentKnobValue=str2num(get(handles.phs_rmp_ctrl,'String'));
knobDelta=CurrentKnobValue-handles.LastKnobValue;
pause(.01)
handles.LastKnobValue=CurrentKnobValue;
pause(.01)
handles.knobDelta=knobDelta;
handles=SetPhaseRamp(handles);
guidata(hObject,handles);

function phs_rmp_ctrl_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.knob = 'MKB:PHSRMP.MKB';
if ~exist('handles.LastKnobValue')
    handles.LastKnobValue=0;
end
guidata(hObject,handles);


function handles=SetPhaseRamp(handles)
requestBuilder = pvaRequest('MKB:VAL');
requestBuilder.with('MKB',handles.knob);

CurrentNullPhase=lcaGetSmart('TCAV:LI20:2400:0:POC');
PhaseRampSet = handles.knobDelta;
XTCAV_OFFSET=-handles.knobDelta*4;
NewNullPhase=CurrentNullPhase+XTCAV_OFFSET;
answer = requestBuilder.set(PhaseRampSet);
PhaseRampAsSet=answer.get(1).get(0);
handles.ansstr = getStrings(answer);
lcaPutSmart('TCAV:LI20:2400:0:POC',NewNullPhase);
handles.updateText=sprintf('Phase Ramp changed to %3.1fdeg, XTCAV changed to %3.1fdeg',PhaseRampAsSet,NewNullPhase);
gui_messageDisp(handles,handles.updateText);



%Reproduce TCAV GUI here
function axes5_CreateFcn(hObject, eventdata, handles)
function TCAVCalButton_Callback(hObject, eventdata, handles)
if get(handles.tcav_onoff, 'Value') ~=1
    tcav_onoff_Callback(handles.tcav_onoff,[],handles);
end
handles=FitTCAVslope(hObject,handles);

function TCAVMeasButton_Callback(hObject, eventdata, handles)
handles=MeasTCAVSigZ(hObject,handles);

function handles=FitTCAVslope(hObject,handles)
NumSteps=5;
StartPhase=lcaGetSmart('SIOC:SYS1:ML00:AO871');
EndPhase=lcaGetSmart('SIOC:SYS1:ML00:AO872');
Samples=lcaGetSmart('SIOC:SYS1:ML00:AO873');
NumBG=1;
handles.CalFitLine=linspace(StartPhase,EndPhase,100);
handles.TCAVPhaseSteps=StartPhase:((EndPhase-StartPhase)/(NumSteps-1)):EndPhase;
fbck = lcaGetSmart('SIOC:SYS1:ML00:AO661');
lcaPutSmart('SIOC:SYS1:ML00:AO661', 0);
for T=1:NumSteps
    gui_messageDisp(handles,strcat(['Setting TCAV phase to ',num2str(handles.TCAVPhaseSteps(T))]));
    lcaPutSmart('TCAV:LI20:2400:PDES',handles.TCAVPhaseSteps(T));
    for ClownShoes=1:Samples
        data=profmon_grab(handles.PVList(2));
        beam=profmon_process(data,'doPlot',0);
        CentroidPreAvg(ClownShoes)=beam(2).stats(2);
        CentroidSTDPreAvg(ClownShoes)=beam(2).statsStd(2);
        gui_messageDisp(handles,sprintf('Grabbing Sample %2.0f of %2.0f on TCAV setting %2.0f of %2.0f',...
            ClownShoes,Samples,T,NumSteps));
    end
    handles.Centroid(T)=mean(CentroidPreAvg);
    handles.CentroidSTD(T)=mean(CentroidSTDPreAvg);
end
lcaPutSmart('TCAV:LI20:2400:PDES',90);
lcaPutSmart('SIOC:SYS1:ML00:AO661', fbck);
[par, handles.yFit, parstd, handles.yFitStd, mse, pcov, rfe]=...
    util_polyFit(handles.TCAVPhaseSteps,handles.Centroid,1,handles.CentroidSTD,handles.CalFitLine);
handles.TCAVCalSlope=par(1); %um/deg xband
handles.MicronsPerMicron=abs(handles.TCAVCalSlope/72.9);
lcaPutSmart('SIOC:SYS1:ML00:AO025',handles.MicronsPerMicron);
set(gcf,'CurrentAxes',handles.axes5)
cla
util_errorBand(handles.CalFitLine,handles.yFit,handles.yFitStd./(length(handles.CentroidSTD(T))));
hold on;
errorbar(handles.TCAVPhaseSteps,handles.Centroid,handles.CentroidSTD,'b.');
text(88,max((handles.Centroid)),sprintf('Calibration = %3.1f um/deg',handles.TCAVCalSlope))
xlabel('TCAV phase')
if abs(handles.TCAVCalSlope) < 320
    text(87.5,mean(handles.Centroid),'Weak Calibration','FontSize',18,'Color','r')
end
hold off;
axis tight;
handles.T=T;
guidata(hObject,handles);

function handles=MeasTCAVSigZ(hObject,handles)
Samples=12;
for FitSigZ=1:3
    switch FitSigZ
        case 1
            lcaPutSmart('TCAV:LI20:2400:PDES',-90);
%             act=control_klysStatSet('KLYS:LI20:41',1);
            control_tcavPAD(1,'XTCAVF');
            gui_messageDisp(handles,'TCAV Phase set to 90 ');
        case 2
            gui_messageDisp(handles,'TCAV Off ');
%             act=control_klysStatSet('KLYS:LI20:41',0);
%             control_tcavPAD(1,'XTCAVF');
            control_tcavPAD(0,'XTCAVF');
        case 3
            lcaPutSmart('TCAV:LI20:2400:PDES',90);
%             act=control_klysStatSet('KLYS:LI20:41',1);
            control_tcavPAD(1,'XTCAVF');
            gui_messageDisp(handles,'TCAV Phase set to -90 ');
    end
    for ClownShoes=1:Samples
        gui_messageDisp(handles,strcat(['Taking Sample ',num2str(ClownShoes)]));
        data=profmon_grab(handles.PVList(2));
        beam=profmon_process(data,'doPlot',0);
        handles.SizePreAvg(ClownShoes)=beam(2).stats(4);
        handles.SizeSTDPreAvg(ClownShoes)=beam(2).statsStd(4);
    end
    handles.Size(FitSigZ)=mean(handles.SizePreAvg);
    handles.SizeSTD(FitSigZ)=mean(handles.SizeSTDPreAvg);
end
%tcav_bunchLength([-1 0 1],data,lcaGetSmart('SIOC:SYS1:ML00:AO025'),'axes',handles.axes5);
handles.TCAVMeas=(handles.Size(1)+handles.Size(3))/2;
handles.SigZ=sqrt(handles.TCAVMeas^2-handles.Size(2)^2)/abs(lcaGetSmart('SIOC:SYS1:ML00:AO025'));
[par, handles.yFitSigZ, parstd, handles.yFitStdSigZ, mse, pcov, rfe] = ...
    util_parabFit([-90 0 90],handles.Size, handles.SizeSTD, linspace(-90,90,100));
set(gcf,'CurrentAxes',handles.axes5)
errorbar([-90 0 90],handles.Size,handles.SizeSTD,'r.')
hold on
util_errorBand(linspace(-90,90,100),handles.yFitSigZ,handles.yFitStdSigZ./length(handles.SizeSTD))
%plot(linspace(-90,90,100),handles.yFitSigZ,'b-')
text(0,max(handles.Size),sprintf('sig_z=%3.1f',handles.SigZ))
xlabel('TCAV Phase')
hold off
axis tight
lcaPutSmart('PROF:LI20:3230:BLEN',handles.SigZ);
guidata(hObject,handles);


function printTCAV_Callback(hObject, eventdata, handles)
handles=printTCAV(handles);


function handles=printTCAV(handles)
%if ~isfield(handles,'Size') ||
scrsz = get(0,'ScreenSize'); %[left, bottom, width, height]
TCAVFig=figure('Position',[scrsz(1) scrsz(4)/2 900 480],...
        'Name','TCAV Calibration and Bunch Length Measurement');
    set(TCAVFig,'Color',[.733 .933 1])%bbeeff
%set(SumDispFig,'Color',[.871 .922 .98])
BunchLengthPlot=subplot(2,2,[1 3]);
errorbar([-90 0 90],handles.Size,handles.SizeSTD,'r.')
hold on
util_errorBand(linspace(-90,90,100),handles.yFitSigZ,handles.yFitStdSigZ./length(handles.SizeSTD))
%plot(linspace(-90,90,100),handles.yFitSigZ,'b-')
text(0,max(handles.Size)*.8,sprintf('sig_z=%3.1f',handles.SigZ))
xlabel('TCAV Phase')
hold off
axis tight
title('Bunch Length')
CalibrationSubPlot=subplot(2,2,[2 4]);
util_errorBand(handles.CalFitLine,handles.yFit,handles.yFitStd./(length(handles.CentroidSTD(handles.T))));
hold on;
errorbar(handles.TCAVPhaseSteps,handles.Centroid,handles.CentroidSTD,'b.');
text(88,max((handles.Centroid)),sprintf('Calibration = %3.1f um/deg',handles.TCAVCalSlope))
xlabel('TCAV phase')
if abs(handles.TCAVCalSlope) < 320
    text(87.5,mean(handles.Centroid),'Weak Calibration','FontSize',18,'Color','r')
end
title('TCAV Calibration')
hold off;
axis tight;
util_printLog_wComments(TCAVFig, ...
    'Longitudinal Setup GUI', ...
    'TCAV calibration and bunch length measurement', ...
    'TCAV calibration and bunch length measurement.');
%%%%%%%%%%%%%%%%%%
%TCAV Controls end
%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%
%2-Bunch fitting Start
%%%%%%%%%%%%%%%%%%%%%%

function TwoBunchFitOnOff_Callback(hObject, eventdata, handles)
handles.TwoBunchFitOnOff=(get(hObject,'Value'));
if handles.TwoBunchFitOnOff==1
    set(handles.axes4,'Visible','on')
else
    set(handles.axes4,'Visible','off')
end
guidata(hObject,handles)

function TwoBunchFitOnOff_CreateFcn(hObject, eventdata, handles)
handles.TwoBunchFitOnOff=1;
guidata(hObject,handles)




function handles=bunch_separation(handles)
global PrintData
charge = lcaGetSmart('LI20:TORO:3255:DATA');
tccharge = charge/1E10;
tcav_img=handles.data(2).img;
if isfield(handles,'bg2')
    tcav_img=int16(handles.data(2).img)-int16(handles.bg2);
end
im_dat = tcav_img;
[xx, yy] = CalculateAxes(handles.data(2));
xInd = (xx > handles.tcav_box(1) & xx < handles.tcav_box(1)+handles.tcav_box(3));
yInd = (yy > handles.tcav_box(2) & yy < handles.tcav_box(2)+handles.tcav_box(4));
BoxY = yy(yInd);
Lineout = mean(im_dat(yInd,xInd),2);
Line_minBG = Lineout-Lineout(1);
[MaxLine,max_ind] = max(Line_minBG);
tcav_prof = flipud(Line_minBG);
prof = tcav_prof;
degXband = 72.9; % um
tcav_cal = abs(lcaGetSmart('SIOC:SYS1:ML00:AO025')*degXband);
prof_cent = sum((BoxY').*Line_minBG)/sum(Line_minBG);
tcav_axis = BoxY;
zz_axis  = flipud(1000*degXband*(BoxY-prof_cent)'/tcav_cal);
tcav_prof = flipud(Line_minBG);

tcav_max  = MaxLine;
dz = zz_axis(2) - zz_axis(1);
prof = tcav_prof/sum(dz*tcav_prof);
prof = tcav_prof;
zz = zz_axis;
zz_cen = mean(zz);
zz_win = zz(end) - zz(1);
dz = zz(2) - zz(1);
zz_area = sum(dz*prof);


tcav_fitobject = peakfit([zz prof],zz_cen,zz_win,2,1,0,0,0,0,0,0);
tcav_bunchfit1 = tcav_fitobject(1,3)*exp(-((zz-tcav_fitobject(1,2))/(tcav_fitobject(1,4)/2.354)).^2/2);
tcav_bunchfit2 = tcav_fitobject(2,3)*exp(-((zz-tcav_fitobject(2,2))/(tcav_fitobject(2,4)/2.354)).^2/2);

handles.dbrms=(tcav_fitobject(1,4)/2.354);
handles.dbc=(tccharge*tcav_fitobject(1,5)/zz_area);
handles.wbrms=(tcav_fitobject(2,4)/2.354);
handles.wbc=(tccharge*tcav_fitobject(2,5)/zz_area);
handles.bs=(tcav_fitobject(2,2)-tcav_fitobject(1,2));
lcaPutSmart('SIOC:SYS1:ML00:AO864',handles.dbrms);
lcaPutSmart('SIOC:SYS1:ML00:AO865',handles.dbc);
lcaPutSmart('SIOC:SYS1:ML00:AO866',handles.wbrms);
lcaPutSmart('SIOC:SYS1:ML00:AO867',handles.wbc);
lcaPutSmart('SIOC:SYS1:ML00:AO868',handles.bs);
set(handles.DBRMS_text,'String',sprintf('%3.1f', handles.dbrms))
set(handles.DBC_text,'String',sprintf('%3.1f', handles.dbc))
set(handles.WBRMS_text,'String',sprintf('%3.1f', handles.wbrms))
set(handles.WBC_text,'String',sprintf('%3.1f', handles.wbc))
set(handles.BS_text,'String',sprintf('%3.1f', handles.bs))

%Export for print
handles.zz_axis=zz_axis;
handles.tcav_fitobject=tcav_fitobject;
handles.tcav_bunchfit1=tcav_bunchfit1;
handles.tcav_bunchfit2=tcav_bunchfit2;
handles.tcav_prof=tcav_prof;
PrintData=handles;


function handles=PlotTwoBunch(handles)
set(gcf,'CurrentAxes',handles.axes4)
plot(handles.zz_axis,handles.tcav_prof,'.')
xlabel('Microns');ylabel('Intesity (AU)');
%title('Streaked longitudinal profile')
hold on;
plot(handles.zz_axis,handles.tcav_bunchfit1,'r.-');
plot(handles.zz_axis,handles.tcav_bunchfit2,'r-.');
%enhance_plot;
axis tight
hold off;

function DBRMS_text_Callback(hObject, eventdata, handles)
function DBRMS_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BS_text_Callback(hObject, eventdata, handles)
function BS_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DBC_text_Callback(hObject, eventdata, handles)
function DBC_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WBRMS_text_Callback(hObject, eventdata, handles)
function WBRMS_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WBC_text_Callback(hObject, eventdata, handles)
function WBC_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%
%2-Bunch fitting STOP
%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%
% Start Manget Control
%%%%%%%%%%%%%%%%%%%%%%

function waist_location_CreateFcn(hObject, eventdata, handles)

function waist_beta_star_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in waistMover.
function waistMover_Callback(hObject, eventdata, handles)
handles.QFF.pvs.currentVal=control_magnetGet(handles.QFF.names,'BACT');
gui_messageDisp(handles,'Putting Beam on 2-9');
pause(.5)
set_2_9(1)
is2_9_On=get_2_9;
if is2_9_On ==1
    gui_messageDisp(handles,'Trimming FF magnets');
    pause(.5)
    handles.QFF.afterTrim=control_magnetSet(handles.QFF.names,handles.QFF.MIP500.pvs);
    if handles.QFF.afterTrim(1)==handles.QFF.MIP500.pvs
        gui_messageDisp(handles,'Magnets trimmed');
    else
        gui_messageDisp(handles,'Problem with trim');
    end
else
    gui_messageDisp(handles,'Problem with 2-9');
end


%handles.QFF.afterTrim=control_magnetGet(handles.QFF.names,'BACT');

% --- Executes during object creation, after setting all properties.
function trimming_stat_CreateFcn(hObject, eventdata, handles)



%%%%%%%%%%%%%%%%%%%%
% END Manget Control
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
% Notch and Jaw control
%%%%%%%%%%%%%%%%%%%%%%%

%Y elevator
function notch_2_Callback(hObject, eventdata, handles)
YPositionDES=str2double(get(hObject,'String'));
lcaPutSmart('COLL:LI20:2072:MOTR',YPositionDES);
function notch_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('COLL:LI20:2072:MOTR'))
function notchAct_2_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('COLL:LI20:2072:MOTR.RBV'))

%X Translation
function notch_1_Callback(hObject, eventdata, handles)
XTranslationDES=str2double(get(hObject,'String'));
lcaPutSmart('COLL:LI20:2069:MOTR',XTranslationDES);
function notch_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('COLL:LI20:2069:MOTR'))
function notchAct_1_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('COLL:LI20:2069:MOTR.RBV'))

%JawL
function notch_3_Callback(hObject, eventdata, handles)
JawLDES=str2double(get(hObject,'String'));
lcaPutSmart('COLL:LI20:2085:MOTR',JawLDES);
function notch_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('COLL:LI20:2085:MOTR'))
function notchAct_3_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('COLL:LI20:2085:MOTR.RBV'))


%JawR
function notch_4_Callback(hObject, eventdata, handles)
JawRDES=str2double(get(hObject,'String'));
lcaPutSmart('COLL:LI20:2086:MOTR',JawRDES);
function notch_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('COLL:LI20:2086:MOTR'))
function notchAct_4_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('COLL:LI20:2086:MOTR.RBV'))

%Yaw
function notch_5_Callback(hObject, eventdata, handles)
YawDES=str2double(get(hObject,'String'));
lcaPutSmart('COLL:LI20:2073:MOTR',YawDES);
function notch_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',lcaGet('COLL:LI20:2073:MOTR'))
function notchAct_5_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',lcaGet('COLL:LI20:2073:MOTR.RBV'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End of Notch and Jaw Control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%
%Print it
%%%%%%%%%%%

function print_1_Callback(hObject, eventdata, handles)
global PrintData;
if ~isfield(PrintData,'data')
    return
end
bits=handles.bits.iVal;
scrsz = get(0,'ScreenSize'); %[left, bottom, width, height]
if scrsz(3)==3600 %3 screen OPIs
    SumDispFig= figure('Position',[(scrsz(1)+2*scrsz(3)/3+10) scrsz(4)/2 900 960],...
        'Name','Longitudinal GUI Figure');
elseif scrsz(3)==4880 %4 screen OPIs in main horseshoe
    SumDispFig= figure('Position',[scrsz(1)+2*scrsz(3)/4-20 scrsz(4)/2 900 960],...
        'Name','Longitudinal GUI Figure');
else %default screens
    SumDispFig= figure('Position',[scrsz(1)+2*scrsz(3)/4-20 scrsz(4)/2 900 960],...
        'Name','Longitudinal GUI Figure');
end
set(SumDispFig,'Color',[.733 .933 1])%bbeeff
%set(SumDispFig,'Color',[.871 .922 .98])
StreakSubPlot=subplot(3,3,[2 5]);
profmon_imgPlot(PrintData.data(3),'axes',StreakSubPlot,'useBG',0,'rawImg',handles.show.rawImg, ...
    'cal',1,'scale',~handles.zoom, ...
    'bits',bits*(bits > 4));
title('USOTR')
StreakSubPlot=subplot(3,3,[1 4]);
profmon_imgPlot(PrintData.data(2),'axes',StreakSubPlot,'useBG',1,'rawImg',handles.show.rawImg, ...
    'cal',1,'scale',~handles.zoom, ...
    'bits',bits*(bits > 4));
title('IP2B')
SpectrumSubPlot=subplot(3,3,[7 9]);
profmon_imgPlot(PrintData.data(1),'axes',SpectrumSubPlot,'useBG',1,...
    'cal',1,'scale',~handles.zoom, 'colormap','jet',...
    'bits',bits*(bits > 4));
title('Energy Spectrum')
%if handles.TwoBunchFitOnOff==1
    FittedSubPlot=subplot(3,3,6);
    plot(PrintData.zz_axis,PrintData.tcav_prof,'.')
    xlabel('Microns');ylabel('Intesity (AU)');title('Streaked longitudinal profile')
    hold on;
    plot(PrintData.zz_axis,PrintData.tcav_bunchfit1,'r.-');
    plot(PrintData.zz_axis,PrintData.tcav_bunchfit2,'r-.');
    enhance_plot;
    axis tight
%end
TextAxis=subplot(3,3,3);
axis([0 1 0 1000])
%set(TextAxis,'Visible','off');
set(TextAxis,'Color',[.733 .933 1])
%set(TextAxis,'Color',[.267 .733 .733])
set(TextAxis,'XColor',[.733 .933 1])
set(TextAxis,'YColor',[.733 .933 1])
text(0,900,sprintf('Phase Ramp = %3.1f\n',handles.TimerUpdateData.update.names(13)),'FontName','Monospaced','FontSize',12)
text(0.65,900,sprintf('NRTLComp = %3.1f\n',handles.TimerUpdateData.update.names(22)),'FontName','Monospaced','FontSize',12)
text(0,800,sprintf('S20 Pyro   = %3.1f\n',handles.TimerUpdateData.update.names(14)),'FontName','Monospaced','FontSize',12)
text(0,700,sprintf('LI02 Gap   = %3.1f\n',handles.TimerUpdateData.update.names(15)),'FontName','Monospaced','FontSize',12)
%if handles.TwoBunchFitOnOff==1
    text(0,600,sprintf('DSigZ      = %3.1fum\n',PrintData.dbrms),'FontName','Monospaced','FontSize',12)
    text(0,500,sprintf('WSigZ      = %3.1fum\n',PrintData.wbrms),'FontName','Monospaced','FontSize',12)
    text(.75,600,sprintf('DQ = %3.1f\n',PrintData.dbc),'FontName','Monospaced','FontSize',12)
    text(.75,500,sprintf('WQ = %3.1f\n',PrintData.wbc),'FontName','Monospaced','FontSize',12)
    text(0,400,sprintf('Separation = %3.1fum\n',PrintData.bs),'FontName','Monospaced','FontSize',12)
%end
text(0,250,sprintf('Jaw L = %3.1fmm\n',lcaGet('COLL:LI20:2085:MOTR.RBV')),'FontName','Monospaced','FontSize',12)
text(0.75,250,sprintf('Jaw R = %3.1fmm\n',lcaGet('COLL:LI20:2086:MOTR.RBV')),'FontName','Monospaced','FontSize',12)
text(0,150,sprintf('Tranlation = %3.1fum\n',lcaGet('COLL:LI20:2069:MOTR.RBV')),'FontName','Monospaced','FontSize',12)
text(0.75,150,sprintf('Yaw = %3.1fdeg\n',lcaGet('COLL:LI20:2073:MOTR.RBV')),'FontName','Monospaced','FontSize',12)
text(0,50,sprintf('Elevator = %3.1fum\n',lcaGet('COLL:LI20:2072:MOTR.RBV')),'FontName','Monospaced','FontSize',12)
set(TextAxis,'FontSize',18)
% annotation('textbox',[.54 .66 .4 .3],'String',...
%     sprintf('\n \n\nPhaseRamp = %3.1f\nS20 Pyro = %3.1f\nGAP02 = %3.1f\nDB-sig_z=%3.1f\n',...
%     handles.TimerUpdateData.update.names(15),handles.TimerUpdateData.update.names(16),...
%     handles.TimerUpdateData.update.names(17),handles.dbrms),...
%     'FontSize',14,'BackgroundColor',[.894,.941,.902]);



util_printLog_wComments(SumDispFig, ...
    'Longitudinal Setup GUI', ...
    'current state of longitudinal setup', ...
    'Current machine state and settings.');
util_dataSave(PrintData,'longitudinalSetupGUI','save-data',datestr(now));

%%%%%%%%%%%%%%%%%%%%
%%% END! %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
stop(handles.UpdateTimer);
%delete(handles.UpdateTimer);
stop(handles.ProfmonTimer);
util_appClose(hObject);


function figure1_ResizeFcn(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Readbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Readback_1_Callback(hObject, eventdata, handles)
function Readback_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_2_Callback(hObject, eventdata, handles)
function Readback_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_3_Callback(hObject, eventdata, handles)
function Readback_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_4_Callback(hObject, eventdata, handles)
function Readback_4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_5_Callback(hObject, eventdata, handles)
function Readback_5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_6_Callback(hObject, eventdata, handles)
function Readback_6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_7_Callback(hObject, eventdata, handles)
function Readback_7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_8_Callback(hObject, eventdata, handles)
function Readback_8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Readback_9_Callback(hObject, eventdata, handles)
function Readback_9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Readback_10_Callback(hObject, eventdata, handles)
function Readback_10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%
%Other Functions
%%%%
function handles=gui_messageDisp(handles,str)
str=cellstr(str);
strDisp=[str{:}];
if isfield(handles,'status_txt')
    handles=handles.status_txt;
end
if ishandle(handles)
    set(handles,'String',str);
    drawnow;
end


function loadDataButton_Callback(hObject, eventdata, handles)
global PrintData
stop(handles.UpdateTimer);
stop(handles.ProfmonTimer);
util_dataLoad;
handles=PrintData;
handles = plot_image(hObject,handles);
