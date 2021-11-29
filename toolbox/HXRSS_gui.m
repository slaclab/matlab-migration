function varargout = HXRSS_gui(varargin)
% HXRSS_GUI M-file for HXRSS_gui.fig
%      HXRSS_GUI, by itself, creates a new HXRSS_GUI or raises the existing
%      singleton*.
%
%      H = HXRSS_GUI returns the handle to a new HXRSS_GUI or the handle to
%      the existing singleton*.
%
%      HXRSS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HXRSS_GUI.M with the given input arguments.
%
%      HXRSS_GUI('Property','Value',...) creates a new HXRSS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HXRSS_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HXRSS_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HXRSS_gui

% Last Modified by GUIDE v2.5 27-Mar-2013 15:14:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HXRSS_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @HXRSS_gui_OutputFcn, ...
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


% --- Executes just before HXRSS_gui is made visible.
function HXRSS_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HXRSS_gui (see VARARGIN)
% set (hObject, 'Resize','off');

global timerRunning;
global timerRestart;
global timerDelay;
global timerData;

timerRunning= false;
timerRestart= false;
timerDelay= 1;      % sec
timerData.hObject= hObject;

handles=appInit(hObject,handles);

% Choose default command line output for HXRSS_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HXRSS_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HXRSS_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global timerData;
global timerRunning;
% Get default command line output from handles structure
varargout{1} = handles.output;
handles=RefreshGUI(handles);
handles=timerChicane(handles);
handles=timerProfMon(handles);
if timerRunning
timerData.handles = handles;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes when user attempts to close HXRSS_gui.
function HXRSS_gui_CloseRequestFcn(hObject, eventdata, handles)
global timerRunning;
global timerObj;
global profMonTimerObj;
global chicaneTimerObj;


stop ( timerObj );
stop ( profMonTimerObj );
stop ( chicaneTimerObj );

pause (2);
if ~ispc
    util_appClose(hObject);
    pause(2.5);
end
if ispc
    delete (hObject);
end
lcaClear
delete(timerObj);
delete ( profMonTimerObj );
delete ( chicaneTimerObj );


function handles=appInit(hObject,handles)
global timerData;
global xstalAngleOld;
global modeOld;

set(gcf,'Units','inches','Position',[1,1,13.2,9.5]); %sets GUI to correct size
set(gcf,'Units','normalized');

handles.enableXstal=1; 
handles.enableCamera=1;
handles.enableMPS=1;

const=util_PhysicsConstants;    
handles.echarge=const.echarge;  

handles.configList={'lamp'};

handles.control.tag.double={...
'readElectronEnergy_txt'; ...
'readPeakCurrent_txt';'readBunchCharge_txt';'readTheta_txt';'readY_txt';...
'readX_txt';'readPhi_txt';'raftLeft_txt';'raftRight_txt';'xstalTheta_txt';...
'charge_txt';'readLamp_txt' ...
};

handles.control.readPV.double={...
'BEND:DMP1:400:BDES';'SIOC:SYS0:ML00:AO044';...
'FBCK:FB02:GN01:S1P1';'XTAL:UND1:1653:ACT';'XTAL:UND1:1650:ACT';...
'XTAL:UND1:1651:ACT';'XTAL:UND1:1652:ACT';'USEG:UND1:1650:TM1MOTOR.RBV';...
'USEG:UND1:1650:TM2MOTOR.RBV';'XTAL:UND1:1653:ACT';'BPMS:UND1:1790:TMIT1H';...
'YAGS:UND1:1650:LED' ... 
};

handles.control.tag.string={...
'TDUND_txt';'BFW_txt';'mpsStatus_txt' ...
};

handles.control.readPV.string={...
'DUMP:LTU1:970:TDUND_PNEU';'BFW:UND1:1610:STATUSM';...
'MPS:UND1:1650:HXRSS_MODE'
};

handles.control.tag.int={'readFocus_txt';'readIris_txt';'readZoom_txt'};
handles.control.readPV.int={ 'YAGS:UND1:1650:FOCUSPOS';...
    'YAGS:UND1:1650:IRISPOS';'YAGS:UND1:1650:ZOOMPOS'};


handles.control.tag.exp={'pump_txt';'gauge_txt'};
handles.control.readPV.exp={'VPIO:UND1:1650:P';'VGXX:UND1:1650:P'};

handles.delayPV  = 'SIOC:SYS0:ML01:AO901';%delay 
handles.phasePV  = 'SIOC:SYS0:ML01:AO902';%phase in Angstroms
handles.xposPV   = 'SIOC:SYS0:ML01:AO903';%x displacement of e beam
handles.R56PV    = 'SIOC:SYS0:ML01:AO904';% R56 matrix element
handles.lambdaPV = 'SIOC:SYS0:ML01:AO905';% photon wavelength from Bragg Eq.
handles.phaseAngPV= 'SIOC:SYS0:ML01:AO906';%phase in degrees
handles.thicknessPV='XTAL:UND1:1650:THICKNESS';%diamond xstal thickness


handles.camPV='YAGS:UND1:1650'; 
% handles.camPV='OTRS:LI24:807'  %FOR DEBUG
handles.motorTheta='XTAL:UND1:1653';
handles.motorX='XTAL:UND1:1651';
handles.motorY='XTAL:UND1:1650';
handles.motorPhi='XTAL:UND1:1652';
handles.magnetMainPV='BEND:UND1:1640';
handles.magnetTrimPV={'BTRM:UND1:1640'; 'BTRM:UND1:1630'; 'BTRM:UND1:1660'; 'BTRM:UND1:1670'};
handles.bykikPV='IOC:BSY0:MP01:BYKIKCTL';
handles.tdundPV='DUMP:LTU1:970:TDUND_PNEU';

handles.BDES=zeros(1,4);

nUnd=1:33;
nUnd=nUnd';
undPV=model_nameConvert(cellstr(num2str(nUnd,'US%02d')));
typePV=strcat(undPV,':TYPEDISP');
typeUnd=lcaGet(typePV,0,'char');
handles.chicaneIdx=find(strncmp(typeUnd,'CHICANE',7),1,'last'); %locate which girder has chicane
% handles.chicaneIdx=16;

% Taper configuration
handles.taperStandard = [ 
     80.0000
   80.0000
    0.3498
    0.4351
    0.3607
    0.3856
    0.3734
    0.1541
    0.1419
    0.2760
    0.0337
   -0.1448
   -0.0489
    0.0747
    0.1620
         0
   -0.1529
    0.0470
    0.0238
   -0.0094
   -0.0243
   -0.2387
   -0.0291
   -0.0475
   -0.1762
   -0.0542
   -0.0474
    0.2237
    0.8520
    1.0787
    2.0336
    3.0466
    3.4379
]; % From 7/11/12 5:31:48
handles.taperInitial = segmentTranslate;


val=lcaGetSmart(handles.bykikPV,0,'double');
if any(val)
    str='BEAM ON';
else
    str='BEAM OFF';
end
set(handles.beam_btn,'String',str);
set(handles.beam_btn,'Value',val);

val=lcaGetSmart(handles.tdundPV,0,'double');
if any(val)
    str='TDUND OUT';
else
    str='TDUND IN';
end
set(handles.tdund_btn,'String',str);
set(handles.tdund_btn,'Value',1-val);

handles.thetaDefault=56.330;
handles.defaultDelay=20; %20fs delay

if handles.enableXstal
    xstalAngle=lcaGetSmart([handles.motorTheta ':ACT']);
else
    xstalAngle=handles.thetaDefault;
end
xstalAngleOld=xstalAngle;
set(handles.theta_txt,'String',num2str(xstalAngle)); 
set (handles.xstalStatus_txt,'String','');
set (handles.raftStatus_txt,'String','');

%Draw objects on hidden axes in GUI
axes(handles.beamline_ax);
cla(handles.beamline_ax); %clear main axis on GUI
set (handles.beamline_ax,'Color','none');

% Main components along beamline

rectangle('Position',[2.16,-.53,5.8,1.78],'FaceColor',[.5 .5 .65],'Parent',handles.beamline_ax);%raft
hold on
xlim([0,10])
ylim([-3,3.0])

line([0.07 .91],[0 0],'Color',[.3 .3 .35],'LineWidth',6);% ebeam line
line([2.67 4.12 5.92 7.42],[0 .88 .88 0],'Color',[.2 .2 .2],'LineWidth',6); %chicane lines
handles = arrow([5.25 0],[4.55 1.87],handles,handles.beamline_ax,'m',1);%to camera
line([.86 .94],[-.09 .09],'Color','k','LineWidth',2); %first break
line([.96 1.04],[-.09 .09],'Color','k','LineWidth',2); %2nd break
line([1.01 2.25],[0 0],'Color',[.3 .3 .35],'LineWidth',6);% ebeam line
line([1.01 2.25],[0 0],'Color','m','LineWidth',3);% Xray line
rectangle('Position',[.49,-.375,.31,.78],'FaceColor',[.5 .5 .5]); %TDUND box
text(.645,.5,'\bfTDUND','HorizontalAlignment','center'); %TDUND label
handles.TDUND_txt=text(.645,0,'OUT','HorizontalAlignment','center','Color',[.5 1 1]); %TDUND state
rectangle('Position',[1.1,-.375,.45,.75],'FaceColor',[0 .82 1]); %U15 box
text(1.33,0,sprintf('U%d',handles.chicaneIdx-1),'HorizontalAlignment','center','FontWeight','bold'); %Und label
rectangle('Position',[1.63,-.375,.42,.78],'FaceColor',[.5 .5 .5]); %BFW
text(1.85,.5,'\bfBFW','HorizontalAlignment','center'); %BFW label
handles.BFW_txt=text(1.85,0,'OKOUT','HorizontalAlignment','center','Color',[.5 1 1]); %BFW state

rectangle('Position',[2.25,-.26,.84,.52],'FaceColor',[.6 .6 .6]);%1st chicane mag
handles.BDES2_txt=text(2.65,.09,'','HorizontalAlignment','center','Color','b','FontWeight','bold');
handles.BACT2_txt=text(2.65,-.1,'','HorizontalAlignment','center','Color','g','FontWeight','bold');
handles.lblBACT{2}=text(2.95,-.1,'\bfA','HorizontalAlignment','center','Color','g');
handles.lblBDES{2}=text(2.95,.09,'\bfA','HorizontalAlignment','center','Color','b');
rectangle('Position',[3.7,.62,.84,.52],'FaceColor',[.6 .6 .6]);%2nd chicane mag
handles.BDES1_txt=text(4.1,1,'','HorizontalAlignment','center','Color','b','FontWeight','bold');
handles.BACT1_txt=text(4.1,.8,'','HorizontalAlignment','center','Color','g','FontWeight','bold');
handles.lblBACT{1}=text(4.35,.8,'\bfA','HorizontalAlignment','center','Color','g');
handles.lblBDES{1}=text(4.35,1,'\bfA','HorizontalAlignment','center','Color','b');
rectangle('Position',[5.53,.62,.84,.52],'FaceColor',[.6 .6 .6]);%3rd chicane mag
handles.BDES3_txt=text(5.9,1,'','HorizontalAlignment','center','Color','b','FontWeight','bold');
handles.BACT3_txt=text(5.9,.8,'','HorizontalAlignment','center','Color','g','FontWeight','bold');
handles.lblBACT{3}=text(6.2,.8,'\bfA','HorizontalAlignment','center','Color','g');
handles.lblBDES{3}=text(6.2,1,'\bfA','HorizontalAlignment','center','Color','b');
line([7.84 9.8],[0 0],'Color',[.3 .3 .35],'LineWidth',6);% ebeam line
handles = arrow([5.3 0],[9.8 0],handles,handles.beamline_ax,'m',2);% Xray line
 line([5.3 9.8],[0 0],'Color','m','LineWidth',2);% Xray line
rectangle('Position',[7.0,-.26,.84,.52],'FaceColor',[.6 .6 .6]);%4th chicane mag
handles.BDES4_txt=text(7.4,.09,'','HorizontalAlignment','center','Color','b','FontWeight','bold');
handles.BACT4_txt=text(7.4,-.1,'','HorizontalAlignment','center','Color','g','FontWeight','bold');
handles.lblBACT{4}=text(7.65,-.1,'\bfA','HorizontalAlignment','center','Color','g');
handles.lblBDES{4}=text(7.65,.09,'\bfA','HorizontalAlignment','center','Color','b');
rectangle('Position',[8.04,-.43,.24,.86],'Curvature',[1,1],'FaceColor',[1 .5 .5])%quad
rectangle('Position',[8.47,-.125,.25,.25],'FaceColor',[1 .7 0]); %BPM
rectangle('Position',[8.3,-.45,.6,.2],'FaceColor',[.5 .5 .5]);%bkg box for contrast
text(8.6,.20,'\bfBPM','HorizontalAlignment','center'); %BPM label
handles.charge_txt=text(8.52,-.38,'21','HorizontalAlignment','center','Color','g','FontWeight','bold'); %BPM value
text(8.77,-.38,'\bf pC','HorizontalAlignment','center','Color','g');
rectangle('Position',[9.0,-.375,.45,.75],'FaceColor',[0 .82 1]); %U17 box
text(9.22,0,sprintf('U%d',handles.chicaneIdx+1),'HorizontalAlignment','center','FontWeight','bold'); %UND label
text(2.75,1.0,'MCOR Relay','HorizontalAlignment','center');
text(4.2,.35,'Pump:                   Torr','HorizontalAlignment','center');
text(4.2,.15,'Gauge:                  Torr','HorizontalAlignment','center');
handles.pump_txt=text(4.28,.35,'\bf1.48e- 8','HorizontalAlignment','center','Color','g');
handles.gauge_txt=text(4.28,.15,'\bf1.46e- 8','HorizontalAlignment','center','Color','g');
text(4.2,-.25,'\theta =','HorizontalAlignment','center');
handles.xstalTheta_txt=text(4.48,-.25,'\bf56.534','HorizontalAlignment','center','Color','g');%xstal angle
text(4.75,-.25,char(176),'HorizontalAlignment','center'); %degree symbol
text(5.5,-.25,'w =','HorizontalAlignment','center');
xstalThickness=lcaGetSmart(handles.thicknessPV);
% xstalThickness=0.1;
strThickness=sprintf('%3.3f',xstalThickness);
handles.xstalThickness=xstalThickness;
handles.xstalW_txt=text(5.75,-.25,strThickness,'HorizontalAlignment','center','Color','b','FontWeight','bold'); %xstal thickness
text(6.0,-.25,' mm','HorizontalAlignment','center');
delay=calcPredictedDelay(handles,xstalThickness);
strDelay=sprintf('(Predicted Chicane Delay=%3.1f fs)',delay);
handles.predDelay_txt=text(6.3,-.4,strDelay,'HorizontalAlignment','center','Color','b','FontWeight','bold'); %xstal thickness
xstalVert = [5.2 -.5 0; 5.2 .5 0; 5.3 .5 0; 5.3 -.5 0];
xstalFac = [1 2 3 4];
handles.xstalBlock= patch('Faces',xstalFac,'Vertices',xstalVert,'facecolor',[.5 .5 .85]); %xstal representation
center = [5.25 0 0];
rotate(handles.xstalBlock,[0 0 1],xstalAngle-90,center) %rotate xstal to correct angle
daspect([1,1,1]);
plot(5.25,0,'bo', 'MarkerFaceColor','k','MarkerSize',8); %beam on xstal
handles = arrow([3.1 0],[5.2 0],handles,handles.beamline_ax,'m',3);% Xray line
camVert = [4.23 1.975 0; 4.23 2.6 0; 4.58 2.6 0; 4.58 1.975 0]; 
lensVert = [4.3175 1.85 0; 4.3175 1.975 0; 4.4925 1.975 0; 4.4925 1.85 0];
camFac = [1 2 3 4];
lensFac=camFac;

h_cam= patch('Faces',camFac,'Vertices',camVert,'facecolor',[.5 .5 .5]); %camera representation
h_lens= patch('Faces',lensFac,'Vertices',lensVert,'facecolor','b');%lens representation
camCenter = [4.405 2.225 0];
camAngle=23.07;
rotate(h_cam,[0 0 1],camAngle,camCenter) %rotate camera
rotate(h_lens,[0 0 1],camAngle,camCenter)%rotate lens
hold on
rectangle('Position',[3.4,1.6,.9,.25],'FaceColor',[.5 .5 .5]);%bkg box for contrast
text(3.6,1.7,'\lambda =','HorizontalAlignment','center');
handles.lambda_txt=text(3.9,1.7,'\bf1.4876','HorizontalAlignment','center','color','b','FontWeight','bold'); %photon wavelength
text(4.2,1.68,char(197),'HorizontalAlignment','center');

valve1Vert = [4.64 1.085; 4.76 1.085; 4.7 .88; 4.64 .675; 4.76 .675];
valve2Vert = [5.28 1.085; 5.4 1.085; 5.34 .88; 5.28 .675; 5.4 .675];
valveFac = [1 2 3;3 4 5];

valve1State=lcaGetSmart('VVMG:UND1:1645:OPEN_LMTSW_MPSC',0,'double')+1;
valve2State=lcaGetSmart('VVMG:UND1:1655:OPEN_LMTSW_MPSC',0,'double')+1;
valveColor={'r' 'g'};

h_valve1= patch('Faces',valveFac,'Vertices',valve1Vert,'facecolor',valveColor{valve1State}); %valve 1 representation
h_valve2= patch('Faces',valveFac,'Vertices',valve2Vert,'facecolor',valveColor{valve2State}); %valve 2 representation

handles=indCircle(handles);
handles = arrow([3.32 -1],[3.32 -.55],handles,handles.beamline_ax,'b',2,.2);% left raft arrow
rectangle('Position',[2.57,-.88,.68,.2],'FaceColor',[.5 .5 .5]);%bkg box for contrast
handles.raftLeft_txt=text(2.8,-.78,'\bf0.20','HorizontalAlignment','center','Color','g');
text(3.1,-.78,'mm','HorizontalAlignment','center');
handles = arrow([6.9 -1],[6.9 -.55],handles,handles.beamline_ax,'b',2,.2);% right raft arrow
rectangle('Position',[7.0,-.88,.68,.2],'FaceColor',[.5 .5 .5]);%bkg box for contrast
handles.raftRight_txt=text(7.2,-.78,'\bf0.01','HorizontalAlignment','center','Color','g');
text(7.55,-.78,'mm','HorizontalAlignment','center');
% rectangle('Position',[4.74,-.88,.64,.2],'FaceColor',[.5 .5 .5]);%bkg box for contrast
% text(5.05,-.78,'\bfSKEW OK','HorizontalAlignment','center','Color','g');
line([3.27 3.37],[-1 -1],'Color','b','LineWidth',2); %left raft arrow base
line([6.85 6.95],[-1 -1],'Color','b','LineWidth',2); %right raft arrow base
set (handles.R56unit_txt, 'String','m','FontName','symbol');
set (handles.delx_txt, 'String','D','FontName','symbol');
ax=handles.profstats_ax;cla(ax);set(ax,'Visible','off');

set(handles.delay_sl,'Visible','off');
set(handles.delay_txt,'Visible','off');
set(handles.delayLo_txt,'Visible','off');
set(handles.delayHi_txt,'Visible','off');
set(handles.delayUnit_txt,'Visible','off');
set(handles.phase_sl,'Visible','on');
set(handles.phase_txt,'Visible','on');
set(handles.phaseLo_txt,'Visible','on');
set(handles.phaseHi_txt,'Visible','on');
set(handles.phaseUnit_txt,'Visible','on');
set(handles.bactStat_txt,'Visible','off');
set(handles.bactCond_txt,'Visible','off');
set(handles.ebeamX_txt,'Visible','off');
set(handles.R56_txt,'Visible','on');
set(handles.degree_lbl,'Visible','on');
set(handles.period_lbl,'Visible','on');
set(handles.period_txt,'Visible','on');
set(handles.phaseAngle_txt,'Visible','on');
set(handles.lambda_txt,'Visible','off');

handles=initGUI(handles);
if ~ispc
lcaSetMonitor(handles.control.readPV.double);
lcaSetMonitor(handles.control.readPV.string);
lcaSetMonitor(handles.control.readPV.int);
lcaSetMonitor(handles.control.readPV.exp);
lcaSetMonitor(handles.delayPV);
lcaSetMonitor(handles.phasePV);
end

handles=appSetup(hObject,handles);
timerData.handles = handles;
guidata(hObject,handles);

function handles=appSetup(hObject,handles)
global timerData
global modeOld

handles=plotXstal(handles);
handles=drawUndulators(handles);
handles=updateUndulators(handles);
set (handles.chicaneControl_pmu,'Value',3); % start in no mode
modeOld=3;
set (handles.chicaneUpdate_txt, 'String','');
handles=readBmax(handles);
handles=initChicaneCtrls(handles);
handles=initMotorCtrls(handles);
handles=initLampCtrl(handles);
mode=get(handles.chicaneControl_pmu,'Value');
if mode==2
handles=checkBDESinit(handles);
end
handles=chicaneControl_pmu_Callback(handles.chicaneControl_pmu, [], handles);
timerData.handles = handles;
guidata(hObject,handles);

function handles=indCircle(handles)

indicator.name={'indMCOR' 'indPump' 'indRaftLeftIn' 'indRaftLeftOut' ...
'indRaftRightIn' 'indRaftRightOut' 'indThetaLo'...
'indYLo' 'indXLo' 'indPhiLo' 'indThetaHi'};  

indicator.position={[2.3,1.0,.06,.06] [3.5,.35,.06,.06] [3.4,-.65,.06,.06]...
[3.4,-.95,.06,.06] [6.75,-.65,.06,.06] [6.75,-.95,.06,.06]...
[6.15,-1.71,.06,.06] [6.15,-1.9,.06,.06]  [6.15,-2.12,.06,.06] [6.15,-2.33,.06,.06] [8.23,-1.71,.06,.06]};  

indicator.PV={'BEND:UND1:1640:STATE' 'VPIO:UND1:1650:STATE' 'BMLN:UND1:1650:IN_LMTSW_MPS'...
'BMLN:UND1:1650:OUT_LMTSW_MPS' 'BMLN:UND1:1650:IN_LMTSW_MPS' ...
'BMLN:UND1:1650:OUT_LMTSW_MPS' 'XTAL:UND1:1653:POSITION' 'XTAL:UND1:1650:OUT_LMTSW_MPS' ...
'XTAL:UND1:1651:OUT_LMTSW_MPS' 'XTAL:UND1:1652:OUT_LMTSW_MPS' 'XTAL:UND1:1653:OUTPOSITION'};

indicator.color={[.5 .5 .65] [.5 .5 .65] [.92 .91 .84] [.92 .91 .84] ...
[.92 .91 .84] [.92 .91 .84] [.5 .5 .5] [.5 .5 .5] [.5 .5 .5] [.5 .5 .5] [.5 .5 .5]};
% handles.ind=indicator;
for idx=1:length(indicator.name)
    handles.ind.h(idx)=rectangle('Position',indicator.position{idx},'Curvature',[1,1],'FaceColor',indicator.color{idx},'Parent',handles.beamline_ax);
end
handles.ind.color=indicator.color;
handles.ind.PV=indicator.PV';
if ~ispc
lcaSetMonitor(handles.ind.PV,0,'double');
end


function handles=drawUndulators(handles)

cla(handles.und_ax);
set (handles.und_ax,'Color','none','Visible','off');
delX=1;
nUnd=1:33;
nUnd=nUnd';
undPV=model_nameConvert(cellstr(num2str(nUnd,'US%02d')));
posPV=strcat(undPV,':LOCATIONSTAT');
handles.und.PV=posPV;
undInOut=~strcmp(lcaGet(posPV),'AT-XOUT');
for indUnd=1:33
    fc={[.92 .91 .84] [.6 .6 .6] };
    if indUnd==handles.chicaneIdx, fc={[.92 .91 .84] [.5 .5 .65] }; end
    handles.und.h(indUnd)=rectangle('Position',[delX*(indUnd-1),0,delX,1],'FaceColor',fc{undInOut(indUnd)+1},'Parent',handles.und_ax);
    text(delX*(indUnd-.5),.4,num2str(indUnd),'HorizontalAlignment','center','Parent',handles.und_ax);
    handles.und.color{indUnd}=fc;
end
if ~ispc
lcaSetMonitor(handles.und.PV);
end
guidata(handles.figure1,handles);

function handles=updateUndulators(handles)
% axes(handles.und_ax);
if ~ispc
idx = find(lcaNewMonitorValue(handles.und.PV));
if any(idx)
    undInOut=~strcmp(lcaGet(handles.und.PV(idx)),'AT-XOUT');
    for cnt=1:length(idx)
        set(handles.und.h(idx(cnt)),'FaceColor',handles.und.color{1,idx(cnt)}{1,undInOut(cnt)+1});
    end
end
end
% posPV=handles.und.PV;
% for idx = 1:33
% undInOut=~strcmp(lcaGet(posPV{idx}),'AT-XOUT');
% set(handles.und.h(idx),'FaceColor',handles.und.color{1,idx}{1,undInOut+1})
% end
guidata(handles.figure1,handles);


function handles=updateIndicators(handles)

% axes(handles.beamline_ax);
if ~ispc
indColor=handles.ind.color;
newval = find(lcaNewMonitorValue(handles.ind.PV,'double'));
if any(newval)
    indState=lcaGet(handles.ind.PV(newval),0,'double');
    for idx=1:length(newval)
        if indState(idx)
            set(handles.ind.h(newval(idx)),'FaceColor', 'g');
        else
            set(handles.ind.h(newval(idx)),'FaceColor', indColor{newval(idx)});
        end
    end
end
end
% indState=lcaGet(handles.ind.PV,0,'double');
% for idx=1:length(indState)
%     if indState(idx)
%         set(handles.ind.h(idx),'FaceColor', 'g');
%     else
%         set(handles.ind.h(idx),'FaceColor', indColor{idx});
%     end
% end
guidata(handles.figure1,handles);


function handles=updateProfMon(handles)   
if handles.enableCamera
    try
        data = profmon_grab(handles.camPV,0,[]);
    catch
        disp_log('Camera Error');
        return
    end
    beam=profmon_process(data,'doPlot',0,'usemethod',1,'useCal',0);
    data.name='';
    profmon_imgPlot(data,'axes',handles.profmon_ax, ...
        'bits',8,'title','');
    ax=handles.profstats_ax;cla(ax);
    beam.stats(5)=beam.stats(5)/prod(beam.stats(3:4));
    str=[strcat('x',{'mean\n' 'rms\n'});
        strcat('y',{'mean\n' 'rms\n'})];
    text(0,0.5,sprintf([str{:} 'corr\nsum']), ...
        'Parent',ax);
    text(0.4,0.4,sprintf('=\n=\n=\n=\n=\n=\n'),'Parent',ax);
    text(0.9,0.4,sprintf('%5.2f\n%5.2f\n%5.2f\n%5.2f\n%5.2f\n%5.2f\n',beam.stats.*[1 1 1 1 1 1e-6])...
        ,'horizontalAlignment', 'right','Parent',ax);
    text(.95,0.48,sprintf('pixel\npixel\npixel\npixel\n\nMcts'),'Parent',ax);
    guidata(handles.figure1,handles);
end

function handles=plotXstal(handles)
% global timerData
ebeamX=lcaGet(handles.xposPV);
if handles.enableXstal
    xstalAngle=(pi/180)*lcaGet([handles.motorTheta ':ACT']);
    xoff=lcaGet([handles.motorX ':ACT'],0);
    yoff=lcaGet([handles.motorY ':ACT'],0);
else
    xstalAngle=(pi/180)*handles.thetaDefault;
    xoff=0;
    yoff=0;
end
xstalAngle = max([1e-7,xstalAngle]); % Avoid <= zero length error below.

axes(handles.xstal_ax);
cla(handles.xstal_ax);

xstalx=[1 1 -1 -1] + xoff;
xstaly=([2.25 -2.25 -2 2] + yoff).*sin(xstalAngle);
R1x=1+xoff;
R2x=3+xoff;
R1y=(-12+yoff)*sin(xstalAngle);
R2y=R1y;
R1Length=15*sin(xstalAngle);
R2Length=R1Length;

handles.xstalPatch=patch(xstalx,xstaly,[.5 .5 .85]);
hold on
handles.holderBase=rectangle('Position',[R1x,R1y,2,R1Length],'FaceColor',[.25 .25 .25]);
handles.holderMain=rectangle('Position',[R2x,R2y,2,R2Length],'FaceColor',[.5 .5 .5]);
daspect([1,1,1])
rectangle('Position',[-4,-4,8,8],'Curvature',[1,1],'Linewidth',2) %HXRSS chamber aperture
rectangle('Position',[-5.5,-2.5,11,5],'Curvature',0.4,'Linewidth',2) %Undulator chamber aperture
rectangle('Position',[-.2,-.2,.4,.4],'Curvature',[1,1],'FaceColor','b'); %xray location
handles.ebeamLocation=rectangle('Position',[-(ebeamX+.2),-.2,.4,.4],'Curvature',[1,1],'FaceColor','r'); %ebeam location
handles=arrow([-7 -9],[-7 -6],handles,handles.xstal_ax,'k',1,.3); %yaxis indicator
handles=arrow([-7 -9],[-5 -9],handles,handles.xstal_ax,'k',1,.4); %xaxis indicator
text(-7,-5,'+Y','HorizontalAlignment','center','Parent',handles.xstal_ax);
text(-4,-9,'+X','HorizontalAlignment','center','Parent',handles.xstal_ax);
xlim([-10,10])
ylim([-10,10])
axis off;
hold off
% timerData.handles = handles;
guidata(handles.figure1,handles);

function handles=updateXstal(handles)
% global timerData
global xstalAngleOld
ebeamX=lcaGet(handles.xposPV);
if handles.enableXstal
    xstalAngle=(pi/180)*lcaGet([handles.motorTheta ':ACT']);
    xoff=lcaGet([handles.motorX ':ACT'],0);
    yoff=lcaGet([handles.motorY ':ACT'],0);
else
    xstalAngle=(pi/180)*handles.thetaDefault;
    xoff=0;
    yoff=0;
end
center = [5.25 0 0];
rotate(handles.xstalBlock,[0 0 1],xstalAngle*(180/pi)-xstalAngleOld,center);
xstalAngleOld=xstalAngle*(180/pi);
xstalx=[1 1 -1 -1] + xoff;
xstaly=([2.25 -2.25 -2 2] + yoff).*sin(xstalAngle);
R1x=1+xoff;
R2x=3+xoff;
R1y=(-12+yoff)*sin(xstalAngle);
R2y=R1y;
R1Length=15*sin(xstalAngle);
R2Length=R1Length;
set(handles.xstalPatch,'XData',xstalx,'YData',xstaly);
set(handles.holderBase,'Position',[R1x,R1y,2,R1Length]);
set(handles.holderMain,'Position',[R2x,R2y,2,R2Length]);
set(handles.ebeamLocation,'Position',[-(ebeamX+.2),-.2,.4,.4]);

% timerData.handles = handles;
guidata(handles.figure1,handles);

% --- Executes on button press in loadCamConfig_btn.
function loadCamConfig_btn_Callback(hObject, eventdata, handles)
% hObject    handle to loadCamConfig_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
config=util_configLoad('HXRSS_gui',0);
if isempty(config), return, end

for tag=handles.configList
    if isfield(config,tag{:})
        set(handles.([tag{:} '_txt']),'String',num2str(config.(tag{:})));
        handles=hxrss_txt_Callback(handles.([tag{:} '_txt']), handles, tag{:});
    end
end
basePV=handles.camPV;
lcaPut('YAGS:UND1:1650:ZOOMSPEED',0);
lcaPut('YAGS:UND1:1650:FOCUSSPEED',0);
for tags={':ZOOMTOHOME' ':IRISTOHOME' ':FOCUSTOHOME'};
    lcaPut(strcat(basePV, tags),1);
    pause (.25);
    lcaPut(strcat(basePV, tags),0);
end
lcaPut('YAGS:UND1:1650:ZOOMSPEED',1);
lcaPut('YAGS:UND1:1650:FOCUSSPEED',1);
guidata(hObject,handles);


% --- Executes on button press in saveCamConfig_btn.
function saveCamConfig_btn_Callback(hObject, eventdata, handles)
% hObject    handle to saveCamConfig_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for tag=handles.configList
    config.(tag{:})=get(handles.([tag{:} '_txt']),'String');
end
util_configSave('HXRSS_gui',config,0);
basePV=handles.camPV;
for tags={':ZOOMSAVEHOME.PROC'; ':IRISSAVEHOME.PROC'; ':FOCUSSAVEHOME.PROC'};
    lcaPut(strcat(basePV, tags),1);
end

% --- Executes on button press in beam_btn.
function handles=beam_btn_Callback(hObject, eventdata, handles)
% hObject    handle to beam_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.beam_btn,'Value');
lcaPut(handles.bykikPV,val);
if val
    str='BEAM ON';
else
    str='BEAM OFF';
end
set(handles.beam_btn,'String',str);


% --- Executes on button press in tdund_btn.
function handles=tdund_btn_Callback(hObject, eventdata, handles)
% hObject    handle to tdund_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.tdund_btn,'Value');
val=1-val;
lcaPut(handles.tdundPV,val);
if val
    str='TDUND OUT';
else
    str='TDUND IN';
end
set(handles.tdund_btn,'String',str);


% --- Executes on button press in xstalOut_btn.
function handles=moveXstal_btn_Callback(hObject, eventdata, handles, state)
% hObject    handle to xstalOut_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.enableXstal
    if strcmp(state,'IN')
        thetaVal=handles.thetaDefault;
        YVal=-0.2;
        % XVal=0.2; W. Colocho Oct 5, 2017 New default X IN position.
        XVal=-0.6;
        phiVal=0;
    else
        thetaVal=get(handles.theta_sl,'Value');
        YVal=-6.5;
        XVal=get(handles.X_sl,'Value');
        phiVal=get(handles.phi_sl,'Value');
    end
    
    set (handles.theta_sl,'Value',thetaVal);
    set (handles.theta_txt,'String',num2str(thetaVal));
    set (handles.Y_sl,'Value',YVal);
    set (handles.Y_txt,'String',num2str(YVal));
    set (handles.X_sl,'Value',XVal);
    set (handles.X_txt,'String',num2str(XVal));
    set (handles.phi_sl,'Value',phiVal);
    set (handles.phi_txt,'String',num2str(phiVal));
    set (gcbo, 'Enable','off');
    set (handles.xstalStatus_txt,'String','Crystal Moving');
    handles=moveXstalMotor(handles,[],'all');
    set (gcbo, 'Enable','on');
    set (handles.xstalStatus_txt,'String','');
    guidata(hObject,handles);
end

function handles=hxrss_txt_Callback(hObject, handles, tag)
motorTags={'theta';'Y';'X';'phi'};
chicaneTags={'delay';'phase'};
cameraTags={'lamp';'focus';'iris';'zoom'};
hText=handles.([tag '_txt']);
hSl=handles.([tag '_sl']);
newval=min(str2double(get(hText,'String')),get(hSl,'Max'));
newval=max(newval,get(hSl,'Min')); %coerce value to be in limits
set (hSl,'Value',newval);
set (hText,'String',num2str(newval));

if any(strcmp(tag,motorTags))
    moveXstalMotor(handles, newval, tag);
    return
end
if any(strcmp(tag,chicaneTags))
    if strcmp(tag,'delay')
        lcaPut(handles.delayPV,newval);
    else
        lcaPut(handles.phasePV,newval);
    end
    handles=adjustChicane(handles,1,0);
    return
end
if any(strcmp(tag,cameraTags))
    handles=adjustCamera(handles, newval, tag);
    return
end
guidata(hObject,handles);

function handles=hxrss_sl_Callback(hObject, handles, tag, init)
if nargin<4,init=0; end
motorTags={'theta';'Y';'X';'phi'};
chicaneTags={'delay';'phase'};
cameraTags={'lamp';'focus';'iris';'zoom'};
hText=handles.([tag '_txt']);
hSl=handles.([tag '_sl']);
newval=get(hSl,'Value');
newval=round(newval*1000)/1000;
numStr=sprintf('%3.3f',newval);
set (hText,'String',numStr);
if init,return; end
if any(strcmp(tag,motorTags))
    handles=moveXstalMotor(handles, newval, tag);
    return
end
if any(strcmp(tag,chicaneTags))
    if strcmp(tag,'delay')
        lcaPut(handles.delayPV,newval);
    else
        lcaPut(handles.phasePV,newval);
    end
    handles=adjustChicane(handles,1,0);
    return
end
if any(strcmp(tag,cameraTags))
    handles=adjustCamera(handles, newval, tag);
    return
end
guidata(hObject,handles);

function handles=moveXstalMotor(handles, value, motor)
if handles.enableXstal
    switch motor
        case 'theta'
            motorPV=handles.motorTheta;
            disp_log('Moving Theta motor ...');
            currTheta=lcaGet(strcat(motorPV, ':ACT'));
            if value < currTheta % reset motor below desired value then move up
                handles=stdzThetaMotor(handles,value);
            end              
        case 'Y'
            motorPV=handles.motorY;
            disp_log('Moving Y motor ...');
        case 'X'
            motorPV=handles.motorX;
            disp_log('Moving X motor ...');
        case 'phi'
            motorPV=handles.motorPhi;
            disp_log('Moving Phi motor ...');
        case 'all'
            motorPV={handles.motorTheta; handles.motorY; handles.motorX;handles.motorPhi};
            value=[str2double(get(handles.theta_txt,'String')); ...
                str2double(get(handles.Y_txt,'String')); ...
                str2double(get(handles.X_txt,'String')); ...
                str2double(get(handles.phi_txt,'String'))];
            disp_log('Moving All crystal motors ...');
            handles=stdzThetaMotor(handles);
    end
    % Move motor.
    lcaPut(strcat(motorPV, ':DES'), value);
    lcaPutNoWait(strcat(motorPV,':TRIM.PROC'),1); 
%     pause(1.);
    % Wait until all completed.
%     while any(strcmp(lcaGet(strcat(motorPV,':LOCATIONSTAT')),'MOVING')), pause(.25);end
%     disp_log('Motor move complete');
    guidata(handles.figure1,handles);
end
 

function handles=moveRaftMotor(handles, value)
disp_log('Moving HXRSS raft ...');
segmentMoveInOut(handles.chicaneIdx, value)
disp_log('Moving HXRSS raft complete');

function handles=adjustChicane(handles,adjust,stdz)
if nargin<3, stdz=0; end;
if nargin<2, adjust=0;end;
newDelay=0;newPhase=0;
if ~ispc
newDelay=lcaNewMonitorValue(handles.delayPV);
newPhase=lcaNewMonitorValue(handles.phasePV);
end
if ~adjust && ~newPhase && ~newDelay, return; end %if no changes, return
energy=lcaGet('BEND:DMP1:400:BDES');
mode=get(handles.chicaneControl_pmu,'Value');

switch mode
    case 1
        if (newDelay)
            delay=lcaGet(handles.delayPV);
            set(handles.delay_txt,'String',sprintf('%3.2f',delay));
            set(handles.delay_sl,'Value',delay);
            adjust=1;
        end
        if stdz || adjust
            delay=get(handles.delay_sl,'Value');
            [BDES,iMain,xpos,theta,R56] = BCSS_adjust(delay,energy,'HXRSS');
            lcaPut(handles.R56PV,R56);
            BDESstring=sprintf('%5.3f',BDES(1));
            set(handles.bdes_txt,'String',BDESstring);
            xstring=sprintf('%4.2f',1000*xpos);
            set(handles.ebeamX_txt,'String',xstring);
            lcaPut(handles.xposPV,1000*xpos);
            R56string=sprintf('%5.3f',R56);
            set(handles.R56_txt,'String',R56string);
            adjust=1;
            if stdz
                val=lcaGet(handles.tdundPV,0,'double'); %check that TDUND is in (val=0 is IN)
                if val %TDUND is OUT
                    lcaPut(handles.tdundPV,0); %insert TDUND
                end
                pause(1.);
                disp_log('Standardizing HXRSS Main ...');
                control_magnetSet('BXHS2',BDES(1),'action','STDZ');
                disp_log('Standardizing HXRSS Main complete');
            end
        end
    case 2
        if (newPhase)
            Angstroms=lcaGet(handles.phasePV);
            set(handles.phase_txt,'String',sprintf('%3.2f',Angstroms));
            set(handles.phase_sl,'Value',Angstroms);
            adjust=1;
        end
        if adjust
            Angstroms=get(handles.phase_sl,'Value');
            lambda=12398.4/lcaGet('SIOC:SYS0:ML00:AO627');
            phase=360*Angstroms/lambda;
            lcaPut(handles.phaseAngPV,phase);
            period=floor(phase/360.0);
            phaseAngle=phase-period*360;
            set(handles.phaseAngle_txt,'String',sprintf('%5.2f',phaseAngle));
            set(handles.period_txt,'String',sprintf('%d',period));
            [BDES,theta,Itrim,R56] = BC_phase(Angstroms,energy,'HXRSS');
            lcaPut(handles.R56PV,R56);
            lcaPut(handles.xposPV,0);
            BDES(1:4)=BDES;
            BDESstring=sprintf('%5.3f',BDES(1));
            set(handles.bdes_txt,'String',BDESstring);
            R56string=sprintf('%5.3f',R56);
            set(handles.R56_txt,'String',R56string);
            adjust=1;
        end
    otherwise
        BDES=[0 0 0 0];
        adjust=0;
end
if  adjust
    handles=setMags(handles, BDES);     %BDES has changed, adjust mags
end
guidata(handles.figure1,handles);

function handles=setMags(handles, BDES)
if ~ispc
    state=get(handles.chicaneControl_pmu,'Value');
    if state ==1 %Seeded
        delay=get(handles.delay_txt,'String');
        disp_log(['Delay:' delay]);        
        magPV=[handles.magnetMainPV;handles.magnetTrimPV(2:4)];
    else
        phase=get(handles.phase_txt,'String');
        phaseAng=lcaGet(handles.phaseAngPV);
        disp_log(['Phase: ' phase ' Angstroms; ' sprintf('%6.3f',phaseAng) ' Degrees']);
        magPV=handles.magnetTrimPV;
    end
%     currBDES=lcaGet(strcat(magPV(1),':BDES'),0,'double')
%     if currBDES>BDES(1)
%         disp_log('Mini-STDZ HXRSS magnets ...');
%         disp(BDES./2)
%         control_magnetSet(magPV,BDES./2,'wait',1.0)
%     end
    disp_log('Setting HXRSS magnets to BDES ...');
    disp(BDES)
    control_magnetSet(magPV,BDES,'wait',.25)
end
disp(BDES)
disp_log('Setting HXRSS magnets to BDES complete');
guidata(handles.figure1,handles);

function handles=degaussMags(handles)
if ~ispc
    val=lcaGet(handles.tdundPV,0,'double'); %check that TDUND is in (val=0 is IN)
    if val %TDUND is OUT
        lcaPut(handles.tdundPV,0); %insert TDUND
    end
    pause(1.);
    disp_log('Turning MCOR Relay ON for degauss');
    control_magnetSet('BXHS2',[],'action','TURN_ON'); %turn on MCOR Relay for degauss
%    pause (1.);
    relayState=lcaGet('BEND:UND1:1640:STATE');
    disp_log(strcat('Relay: ',relayState));
    disp_log('Degaussing HXRSS magnets ...');
    control_magnetSet('BXHS2',[],'action','DEGAUSS');
    disp_log('Degaussing HXRSS magnets complete');
    disp_log('Turning MCOR Relay OFF after degauss');
    control_magnetSet('BXHS2',[],'action','TURN_OFF'); %turn off MCOR Relay after degauss
%    pause (1.);
    relayState=lcaGet('BEND:UND1:1640:STATE');
    disp_log(strcat('Relay: ',relayState));
end


function handles=updateMags(handles)

magPV=handles.magnetTrimPV;
BACT=lcaGet(strcat(magPV, ':BACT'));
BACTsevr=lcaGet(strcat(magPV, ':BACT.SEVR'),0,'double');
BDES=lcaGet(strcat(magPV, ':BDES'));
p = [2.966 2.986 2.968 2.975];  

for idx=1:4
    strBDES=sprintf('%4.3f',BDES(idx));
    strBACT=sprintf('%4.3f',BACT(idx));
    set(handles.(sprintf('BDES%d_txt', idx)),'String',strBDES);
    switch BACTsevr(idx)
        case 0
            strColor='g';
        case 1
            strColor='y';
        case 2
            strColor='r';
        otherwise
            strColor='k';
    end
    set(handles.(sprintf('BACT%d_txt', idx)),'String',strBACT, 'Color', strColor);
    set(handles.lblBACT{idx}, 'Color', strColor);
end
guidata(handles.figure1,handles);

function handles=adjustCamera(handles, value, tag)

if handles.enableCamera
    basePV='YAGS:UND1:1650';
    switch tag
        case 'lamp'
            pv=[basePV ':LED'];
            outVal=value*255; %LED range 0-->255
        case 'focusIN'
            pv=[basePV ':FOCUSIN'];
            outVal=value;
            lcaPut('YAGS:UND1:1650:FOCUSSPEED',1);
        case 'irisIN'
            pv=[basePV ':IRISCLOSE'];
            outVal=value;
        case 'zoomIN'
            pv=[basePV ':ZOOMIN'];
            lcaPut('YAGS:UND1:1650:ZOOMSPEED',1);
            outVal=value;
        case 'focusOUT'
            pv=[basePV ':FOCUSOUT'];
            lcaPut('YAGS:UND1:1650:FOCUSSPEED',1);
            outVal=value;
        case 'irisOUT'
            pv=[basePV ':IRISOPEN'];
            outVal=value;
        case 'zoomOUT'
            pv=[basePV ':ZOOMOUT'];
            lcaPut('YAGS:UND1:1650:ZOOMSPEED',1);
            outVal=value;
    end
    lcaPut(pv, outVal);
    pause(.25);
    if ~strcmp(tag,'lamp')
        lcaPut(pv, 0);
    end
    
    handles=updateProfMon(handles);
    guidata(handles.figure1,handles);
end

function scanMotorRes_rbn_Callback(hObject,eventdata,handles,axis,tag)

scanMotorResolution(hObject,handles,axis,tag);

function handles=scanMotorResolution(hObject,handles,axis,tag)
if isempty(tag), tag='Coarse';end
if isempty(axis), axis='theta';end
handles=gui_radioBtnControl(hObject,handles,axis,tag);
hSl=handles.([axis '_sl']);
if strcmp(tag,'Coarse')
    switch axis
        case 'theta'
            set (hSl,'SliderStep',[9.804e-4 9.804e-3]);
        case 'Y'
            set (hSl,'SliderStep',[0.01 0.05]);
        case 'X'
            set (hSl,'SliderStep',[0.025 0.125]);
        case 'phi'
            set (hSl,'SliderStep',[1.6667e-2 8.3333e-2]);
        otherwise
            set (hSl,'SliderStep',[0.01 0.1]);
    end
else
    switch axis
        case 'theta'
            set (hSl,'SliderStep',[1.9608e-005 1.9608e-004]);
        case 'Y'
            set (hSl,'SliderStep',[0.005 0.01]);
        case 'X'
            set (hSl,'SliderStep',[0.0125 0.025]);
        case 'phi'
            set (hSl,'SliderStep',[8.3333e-3 1.6667e-2]);
        otherwise
            set (hSl,'SliderStep',[0.01 0.1]);
    end
end
guidata(hObject,handles);


% --- Executes on button press in raftOut_btn.
function moveRaft_btn_Callback(hObject, eventdata, handles, state)
% hObject    handle to raftOut_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.beam_btn,'Value',0); %turn off beam
handles=beam_btn_Callback(handles.beam_btn, eventdata, handles);
if ~ispc
    disp_log('Setting HXRSS magnets to zero ...');
    control_magnetSet(handles.magnetMainPV,0);
    control_magnetSet(handles.magnetTrimPV,0);
end
if strcmp(state,'IN')
    val=1;
else
    val=0;
end
set (gcbo, 'Enable','off');
set (handles.raftStatus_txt,'String','Raft Moving');
handles=moveRaftMotor(handles,val);
set (gcbo, 'Enable','on');
set (handles.raftStatus_txt,'String','');
guidata(hObject,handles);


% --- Executes on selection change in chicaneControl_pmu.
function handles=chicaneControl_pmu_Callback(hObject, eventdata, handles)
% hObject    handle to chicaneControl_pmu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global modeOld
val=get(hObject,'Value');

switch val
    case 1  %Seeded
        disp_log('Switch to HXRSS Seeded Mode ...');
        set(handles.delay_sl,'Visible','on');
        set(handles.delay_txt,'Visible','on');
        set(handles.delay_txt,'String',handles.defaultDelay);
        set(handles.delayLo_txt,'Visible','on');
        set(handles.delayHi_txt,'Visible','on');
        set(handles.delayUnit_txt,'Visible','on');
        set(handles.phase_sl,'Visible','off');
        set(handles.phase_txt,'Visible','off');
        set(handles.phaseLo_txt,'Visible','off');
        set(handles.phaseHi_txt,'Visible','off');
        set(handles.phaseUnit_txt,'Visible','off');
        set(handles.bactStat_txt,'Visible','on');
        set(handles.bactCond_txt,'Visible','on');
        set(handles.ebeamX_txt,'Visible','on');
        set(handles.R56_txt,'Visible','on');
        set(handles.degree_lbl,'Visible','off');
        set(handles.period_lbl,'Visible','off');
        set(handles.period_txt,'Visible','off');
        set(handles.phaseAngle_txt,'Visible','off');
        set(handles.lambda_txt,'Visible','on');
        stateXstal='IN';
        button = questdlg({'Run Auto Script?','','Script includes:','', ...
            'Insert TDUND','Insert Raft (if not already in)',...
            'Adjust chicane (including standardize)','Insert Crystal',...
            'Check MPS',''},'Run Auto Script?','Yes','No','Yes');
        if strcmp(button, 'Yes')
            disp_log('Insert TDUND');
            set(handles.chicaneUpdate_txt,'String','Inserting TDUND');
            lcaPut(handles.tdundPV,0); %Insert TDUND
            pause(1.0);
            set(handles.tdund_btn,'Enable','off');
            if ~lcaGet('BMLN:UND1:1650:IN_LMTSW_MPS',0,'double') % if raft not in, insert
                set(handles.chicaneUpdate_txt,'String','Inserting Raft');
                handles=moveRaftMotor(handles, 1);
            end
            disp_log('Adjusting HXRSS chicane ...')
            unix('StripTool /u1/lcls/tools/StripTool/config/rg_HXRSS_degauss.stp &');
            set(handles.chicaneUpdate_txt,'String','Adjusting HXRSS chicane');
            disp_log('Turning MCOR Relay ON for seeded mode');
            lcaPut('BEND:UND1:1640:FUNC','TURN_ON'); %turn on MCOR Relay for seeded
            pause (1.);
            relayState=lcaGet('BEND:UND1:1640:STATE');
            disp_log(strcat('Relay: ',relayState));
            disp_log('Set BTRM2 to zero');
            control_magnetSet('BXHS2T',0,'wait',1.0); %explicitly set BTRM2 to 0
            set(handles.chicaneUpdate_txt,'String','Standardizing Chicane Magnets...');
            handles=adjustChicane(handles,1,1); %include standardize
            button = questdlg('Insert Crystal?','Insert Crystal?','Yes','No','Yes');
            if strcmp(button, 'Yes')
                disp_log('Inserting HXRSS crystal ...')
                set(handles.chicaneUpdate_txt,'String','Inserting Crystal');
                handles=moveXstal_btn_Callback(handles.xstalIn_btn, [], handles, stateXstal);
                
                inState=lcaGet('XTAL:UND1:1650:IN_ENCDR_MPS',0,'double');
                nTry=0;
                while ~inState && nTry < 250
                    handles=updateGUIvals(hObject,handles);
                    pause(0.25)
                    inState=lcaGet('XTAL:UND1:1650:IN_ENCDR_MPS',0,'double');
                    nTry=nTry+1;
                end
            end
            mpsState=lcaGet('MPS:UND1:1650:HXRSS_MODE',0,'double');
            if ~(mpsState==1)
                handles=checkMPS(handles);
                h=warndlg('MPS state incorrect','!! Warning !!');
                uiwait(h);
            end
            set(handles.tdund_btn,'Enable','on');
            button = questdlg('Remove TDUND?','Remove TDUND??','Yes','No','Yes');
            if strcmp(button, 'Yes')
                disp_log('Remove TDUND');
                set(handles.chicaneUpdate_txt,'String','Removing TDUND');
                lcaPut(handles.tdundPV,1); %Remove TDUND
                pause(1.0);
            end
        end
        xstalThickness=lcaGet(handles.thicknessPV);
        predDelay=calcPredictedDelay(handles,xstalThickness);
        strStatus=sprintf('Seeded Mode Active\nPred. delay = %3.1f fs',predDelay);
        set(handles.chicaneUpdate_txt,'String',strStatus);
        disp_log('HXRSS Seeded Mode Active');
        modeOld=1;
    case 2  %Phase Shifter
        disp_log('Switch to HXRSS Phase Shifter Mode ...');
        set(handles.delay_sl,'Visible','off');
        set(handles.delay_txt,'Visible','off');
        set(handles.delayLo_txt,'Visible','off');
        set(handles.delayHi_txt,'Visible','off');
        set(handles.delayUnit_txt,'Visible','off');
        set(handles.phase_sl,'Visible','on');
        set(handles.phase_txt,'Visible','on');
        set(handles.phaseLo_txt,'Visible','on');
        set(handles.phaseHi_txt,'Visible','on');
        set(handles.phaseUnit_txt,'Visible','on');
        set(handles.bactStat_txt,'Visible','off');
        set(handles.bactCond_txt,'Visible','off');
        set(handles.ebeamX_txt,'String','0.0');
        set(handles.ebeamX_txt,'Visible','off');
        set(handles.R56_txt,'Visible','on');
        set(handles.degree_lbl,'Visible','on');
        set(handles.period_lbl,'Visible','on');
        set(handles.period_txt,'Visible','on');
        set(handles.phaseAngle_txt,'Visible','on');
        set(handles.lambda_txt,'Visible','off');
        set(handles.lblBDES{2}, 'String','\bfA');
        set(handles.lblBACT{2}, 'String','\bfA');
        stateXstal='OUT';
        if ~(modeOld==1) % if not switching from Seeded
            disp ('checking BDES and phase')
            handles=checkBDESinit(handles); %check BDES agrees with phase
        end
        button = questdlg({'Run Auto Script?','','Script includes:','', ...
            'Insert TDUND','Remove Crystal','Adjust chicane (including degauss)' ...
            'Insert Raft (if not already in)',...
            'Check MPS',''},'Run Auto Script?','Yes','No','Yes');
        if strcmp(button, 'Yes')
            disp_log('Insert TDUND');
            set(handles.chicaneUpdate_txt,'String','Inserting TDUND');
            lcaPut(handles.tdundPV,0); %Insert TDUND
            pause(1.0);
            set(handles.tdund_btn,'Enable','off');
            disp_log('Removing HXRSS crystal ...')
            set(handles.chicaneUpdate_txt,'String','Removing Crystal');
            handles=moveXstal_btn_Callback(handles.xstalIn_btn, [], handles, stateXstal);
            outState=lcaGet('XTAL:UND1:1650:OUT_LMTSW_MPS',0,'double');
            nTry=0;
            while ~outState && nTry < 250
                handles=updateGUIvals(hObject,handles);
                pause(0.25)
                outState=lcaGet('XTAL:UND1:1650:OUT_LMTSW_MPS',0,'double');
                nTry=nTry+1;
            end
            unix('StripTool /u1/lcls/tools/StripTool/config/rg_HXRSS_degauss.stp &');
            set(handles.chicaneUpdate_txt,'String','Degaussing Magnets');
            handles=degaussMags(handles);
            handles.BDES=[0 0 0 0];
            if ~lcaGet('BMLN:UND1:1650:IN_LMTSW_MPS',0,'double') % if raft not in, insert
                set(handles.chicaneUpdate_txt,'String','Inserting Raft');
                handles=moveRaftMotor(handles, 1);
            end
            button = questdlg('Restore Trim Magnet Setting or leave at zero?','Restore Trims?','Restore','Zero','Zero');
            if strcmp(button, 'Zero')
                lcaPut(handles.phasePV,0);
            end
            disp_log('Adjusting HXRSS chicane ...')
            set(handles.chicaneUpdate_txt,'String','Adjusting Chicane Magnets');
            handles=adjustChicane(handles,1,0);
            mpsState=lcaGet('MPS:UND1:1650:HXRSS_MODE',0,'double');
            if ~(mpsState==3)
                handles=checkMPS(handles);
                h=warndlg('MPS state incorrect','!! Warning !!');
                uiwait(h);
            end
            set(handles.tdund_btn,'Enable','on');
            button = questdlg('Remove TDUND?','Remove TDUND??','Yes','No','Yes');
            if strcmp(button, 'Yes')
                disp_log('Remove TDUND');
                set(handles.chicaneUpdate_txt,'String','Removing TDUND');
                lcaPut(handles.tdundPV,1); %Remove TDUND
                pause(1.0);
            end
        end
        set(handles.chicaneUpdate_txt,'String','Phase Shifter Mode Active');
        disp_log('HXRSS Phase Shifter Mode Active');
        modeOld=2;
    otherwise
        set(handles.delay_sl,'Visible','off');
        set(handles.delay_txt,'Visible','off');
        set(handles.delayLo_txt,'Visible','off');
        set(handles.delayHi_txt,'Visible','off');
        set(handles.delayUnit_txt,'Visible','off');
        set(handles.phase_sl,'Visible','off');
        set(handles.phase_txt,'Visible','off');
        set(handles.phaseLo_txt,'Visible','off');
        set(handles.phaseHi_txt,'Visible','off');
        set(handles.phaseUnit_txt,'Visible','off');
        set(handles.degree_lbl,'Visible','off');
        set(handles.period_lbl,'Visible','off');
        set(handles.period_txt,'Visible','off');
        set(handles.phaseAngle_txt,'Visible','off');
        set(handles.R56_txt,'Visible','off');
        set(handles.chicaneUpdate_txt,'String','Choose chicane mode');
        modeOld=3;
end
handles=readBmax(handles);
guidata(handles.figure1,handles);

% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);

function handles = dataExport(hObject, handles, val)
set(handles.figure1,'Units','inches')
figColor=get(handles.figure1,'Color');
pos=get(handles.figure1,'Position');
units=get(handles.figure1,'Units');
handles.exportFig=figure;
set (handles.exportFig,'Color',figColor);
ch = get(handles.figure1, 'children');
if ~isempty(ch)
    nh = copyobj(ch,handles.exportFig);
end;
set (nh,'Units','normalized');
set(handles.exportFig,'Units',units,'Position',pos);
set(handles.exportFig,'PaperSize',[pos(3) pos(4)]);
if val
    mode=get(handles.chicaneControl_pmu,'Value');
    switch mode
        case 1
            modeStr='Seeded';
        case 2
            modeStr='Phase Shifter';
        otherwise
            modeStr='';
    end
    lambda=get(handles.readFELWavelength_txt,'String');
    title=[modeStr ',' lambda ' Angstroms'];
    util_printLog_wComments(handles.exportFig,'HXRSS_gui',title,'',[960 800]);
    close(handles.exportFig);
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
timerObj=timer('TimerFcn', @timer_Callback, 'Period', timerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop' );
timerRestart = true;
timerData.handles = handles;
start (timerObj);
timerRunning = true;




function timer_Callback (obj, event)
global timerData;
global timerRunning;
handles    = timerData.handles;
hObject    = timerData.hObject;
handles=updateGUIvals(hObject,handles);
guidata ( hObject, handles );
timerData.handles = handles;

function handles=timerChicane(handles)
global chicaneTimerObj;
chicaneTimerDelay=0.5;
chicaneTimerObj=timer('TimerFcn', @chicaneTimer_Callback, 'Period', chicaneTimerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop' );
start (chicaneTimerObj);

function chicaneTimer_Callback (obj, event)
global timerData;
handles    = timerData.handles;
hObject    = timerData.hObject;
handles=adjustChicane(handles,0,0);
guidata ( hObject, handles );
timerData.handles = handles;

function handles=timerProfMon(handles)
global profMonTimerObj;
profMonTimerDelay=15;
profMonTimerObj=timer('TimerFcn', @profMonTimer_Callback, 'Period', profMonTimerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop' );
start (profMonTimerObj);

function profMonTimer_Callback (obj, event)
global timerData;
handles    = timerData.handles;
hObject    = timerData.hObject;
handles=updateProfMon(handles);
guidata ( hObject, handles );
timerData.handles = handles;


function handles=updateGUIvals(hObject,handles)
global timerData;
set (handles.datestr_txt,'String',datestr(now));
if ~ispc
    idx = find(lcaNewMonitorValue(handles.control.readPV.string));
    if ~isempty(idx)
        val=lcaGet(handles.control.readPV.string(idx));
        for loopcnt=1:length(idx)
            set(handles.(handles.control.tag.string{idx(loopcnt)}),'String',val(loopcnt));
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.control.readPV.double));
    if ~isempty(idx)
        val=lcaGet(handles.control.readPV.double(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%6.3f',val(loopcnt));
            set(handles.(handles.control.tag.double{idx(loopcnt)}),'String',str);
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.control.readPV.int));
    if ~isempty(idx)
        val=lcaGet(handles.control.readPV.int(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%d',val(loopcnt));
            set(handles.(handles.control.tag.int{idx(loopcnt)}),'String',str);
        end
    end
    
    idx = find(lcaNewMonitorValue(handles.control.readPV.exp));
    if ~isempty(idx)
        val=lcaGet(handles.control.readPV.exp(idx),0,'double');
        for loopcnt=1:length(idx)
            str=sprintf('%0.3g',val(loopcnt));
            set(handles.(handles.control.tag.exp{idx(loopcnt)}),'String',str);
        end
    end
end
if handles.enableXstal
    xstalAngle=lcaGet('XTAL:UND1:1653:ACT');
else
    xstalAngle=handles.thetaDefault;
end
lambda=1.7834*sin((pi/180)*xstalAngle);
set(handles.lambda_txt,'String',sprintf('%6.4f',lambda));
wavelength=12398.4/lcaGet('SIOC:SYS0:ML00:AO627');
set(handles.readFELWavelength_txt,'String',sprintf('%6.3f',wavelength));
maxDelay=ceil(8*wavelength);
set (handles.phase_sl,'Max',maxDelay);
set (handles.phaseHi_txt,'String',num2str(maxDelay));
if get(handles.phase_sl,'Value')>maxDelay
    set(handles.phase_sl,'Value',maxDelay)
    handles=hxrss_sl_Callback(hObject, handles, 'phase');
end
charge=lcaGet('BPMS:UND1:1790:TMIT1H')*handles.echarge/10e-13;
set(handles.charge_txt,'String',sprintf('%3.1f',charge));

handles=updateXstal(handles);

handles=updateIndicators(handles);
handles=updateUndulators(handles);
handles=updateMags(handles);
handles=updateMagPVs(handles);
drawnow
timerData.handles = handles;
guidata(hObject,handles);

function handles=initGUI(handles)
val=lcaGet(handles.control.readPV.string(:));
for loopcnt=1:length(val)
    set(handles.(handles.control.tag.string{loopcnt}),'String',val(loopcnt));
end

val=lcaGet(handles.control.readPV.double(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%6.3f',val(loopcnt));
    set(handles.(handles.control.tag.double{loopcnt}),'String',str);
end

val=lcaGet(handles.control.readPV.int(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%d',val(loopcnt));
    set(handles.(handles.control.tag.int{loopcnt}),'String',str);
end

val=lcaGet(handles.control.readPV.exp(:),0,'double');
for loopcnt=1:length(val)
    str=sprintf('%0.3g',val(loopcnt));
    set(handles.(handles.control.tag.exp{loopcnt}),'String',str);
end
guidata(handles.figure1,handles);


function handles=readBmax(handles)
val=get(handles.chicaneControl_pmu,'Value');
if val==1
    bmax=lcaGet(strcat(handles.magnetMainPV,':BMAX'));
else
    bmax=lcaGet(strcat(handles.magnetTrimPV{1},':BMAX'));
end
set(handles.bmax_txt,'String',sprintf('%3.1f',bmax));
guidata(handles.figure1,handles);

function braggCalc_txt_Callback(hObject, eventdata, handles)


lambda=str2double(get(hObject,'String'));
angle=asin(lambda*2/3.5668)*180/pi;
strAngle=sprintf('%6.3f',angle);
set(handles.bragg_txt, 'String',strAngle);

function delay=calcPredictedDelay(handles,xstalThickness)
if handles.enableXstal
    xstalAngle=lcaGet('XTAL:UND1:1653:ACT');
else
    xstalAngle=handles.thetaDefault;
end
delay=2.2*sin(pi/180*xstalAngle)/xstalThickness;



function handles=checkBDESinit(handles)
bdesCalc=lcaGet('SIOC:SYS0:ML01:CALC801')
BDES=lcaGet('BTRM:UND1:1630:BDES')
phaseCalc=lcaGet('SIOC:SYS0:ML01:CALC802')
if BDES<1.1*bdesCalc && BDES>.99*bdesCalc
    disp('Initial Trim BDES correct')
else
    strErr={'Mismatch between phase delay and Btrim setting.','','Update Phase PV to match existing BDES or Change Btrim BDES values?',''};
    button = questdlg(strErr,'Reset?','Change Btrims','Update Phase','Update Phase');
        if strcmp(button, 'Update Phase')
            lcaPut(handles.phasePV,phaseCalc);
            set(handles.phase_sl,'Value',phaseCalc);
            set(handles.phase_txt,'String',sprintf('%5.2f',phaseCalc));
            disp('Resetting phase to match existing BDES')
        else
            disp('Resetting BDES to match existing phase')
            handles=adjustChicane(handles,1,0);
        end
end
guidata(handles.figure1,handles);


function handles=initChicaneCtrls(handles)
delay=lcaGet(handles.delayPV);
set(handles.delay_txt,'String',sprintf('%3.2f',delay));
set(handles.delay_sl,'Value',delay);
Angstroms=lcaGet(handles.phasePV);
set(handles.phase_txt,'String',sprintf('%3.2f',Angstroms));
set(handles.phase_sl,'Value',Angstroms);
guidata(handles.figure1,handles);

function handles=initMotorCtrls(handles)
motorTags={'theta';'Y';'X';'phi'};
motorPV={handles.motorTheta; handles.motorY; handles.motorX;handles.motorPhi};
currPos=lcaGet(strcat(motorPV, ':ACT'));
for idx=1:4
    hObject=handles.([motorTags{idx} '_sl']);
    set (hObject,'Value',currPos(idx));
    handles=hxrss_sl_Callback(hObject, handles, motorTags{idx}, 1);
end
guidata(handles.figure1,handles);

function handles=initLampCtrl(handles)
tag={'lamp'};
camPV=handles.camPV;
currVal=lcaGet(strcat(camPV, ':LED'));
hObject=handles.lamp_sl;
set (hObject,'Value',currVal/255);
handles=hxrss_sl_Callback(hObject, handles, 'lamp', 1);
guidata(handles.figure1,handles);

function handles=updateMagPVs(handles)
magPV=handles.magnetMainPV;
mode=get(handles.chicaneControl_pmu,'Value');
if mode == 2
    magPV=handles.magnetTrimPV{1};
end

BDES=lcaGet(strcat(magPV,':BDES'));
BACT=lcaGet(strcat(magPV,':BACT'));

BDESstring=sprintf('%5.3f',BDES);
set(handles.bdes_txt,'String',BDESstring);
BACTstring=sprintf('%5.3f',BACT);
set(handles.bact_txt,'String',BACTstring);
if BACT > 0.6
    set(handles.bactStat_txt,'String','OK','ForegroundColor','g')
else
    set(handles.bactStat_txt,'String','NO','ForegroundColor','r')
end
guidata(handles.figure1,handles);

function handles=stdzThetaMotor(handles,value)
if nargin <2, value=55; end
% reset motor to 0.5 degrees less than desired then move up to remove theta motor backlash
motorPV=handles.motorTheta;
disp_log('Standardizing theta crystal motor ...');
lcaPut(strcat(motorPV, ':DES'), value-.5);
lcaPutNoWait(strcat(motorPV,':TRIM.PROC'),1);
% Wait until all completed.
while any(strcmp(lcaGet(strcat(motorPV,':LOCATIONSTAT')),'MOVING'))
        pause(.5);
end
guidata(handles.figure1,handles);

function handles=checkMPS(handles)
disp_log('HXRSS MPS State:');

PVList={'MPS:UND1:1650:HXRSS_MODE';'BMLN:UND1:1650:IN_LMTSW_MPS'; ...
'BMLN:UND1:1650:OUT_LMTSW_MPS'; 'BEND:UND1:1640:ON_MPS';'BEND:UND1:1640:OFF_MPS'; ...
'BEND:UND1:1640:INTOL_BMIN_MPS';'XTAL:UND1:1650:IN_ENCDR_MPS'; ...
'XTAL:UND1:1650:OUT_LMTSW_MPS';'BEND:DMP1:400:INTOL_BRANGE_MPS'};
nameList={'State:';'RaftIn:';'RaftOut:';'ChicaneOn:';'ChicaneOff:';'MagTol:'; ...
'XtalIn:';'XtalOut:';'BeamE:'};

for idx=1:length(PVList)
    strState=lcaGet(PVList{idx});
    strLog=strcat(nameList{idx},strState);
    disp_log(strLog);
end




% --- Executes on button press in taperInitialRestoreButton.
function taperInitialRestoreButton_Callback(hObject, eventdata, handles)
% Load the initial taper into the machine

qstring = 'Move undulator segments to the Taper when GUI was started?';
button = questdlg(qstring);
if strcmp(button, 'Yes')
    segmentTranslate(handles.taperInitial);
end

% --- Executes on button press in taperStandardLoadButton.
function taperStandardLoadButton_Callback(hObject, eventdata, handles)
% Load the standard taper into the machine

qstring = 'Move undulator segments to the standard Taper?';
button = questdlg(qstring);
if strcmp(button, 'Yes')
    segmentTranslate(handles.taperStandard);
end




function eV2degEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to eV2degEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eV2degEditBox as text
%        str2double(get(hObject,'String')) returns contents of eV2degEditBox as a double

degrees = eV2deg( str2double(get(hObject,'String')), [0 0 4],'diamond'  );
if isreal(degrees)
    set(handles.text310,'String',num2str(degrees,5))
else
    set(handles.text310,'String','None')
end

% --- Executes during object creation, after setting all properties.
function eV2degEditBox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)

degrees = 90-eV2deg( str2double(get(hObject,'String')), [2 2 0],'diamond'  );
if isreal(degrees)
    set(handles.text313,'String',num2str(degrees,5))
else
    set(handles.text313,'String','None')
end



% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in braggCalculatorCloseButton.
function braggCalculatorCloseButton_Callback(hObject, eventdata, handles)
set(handles.uipanel15,'Visible','off')


% --- Executes on button press in braggCalcOpenButton.
function braggCalcOpenButton_Callback(hObject, eventdata, handles)
set(handles.uipanel15,'Visible','on')


function edit12_Callback(hObject, eventdata, handles)
braggDegrees =  eV2deg( str2double(get(hObject,'String')), [1 1 1],'diamond'  );
dtheta = (180/pi)* acos( sqrt(1/3)); % rotation angle between 004 and 111
degrees = dtheta + braggDegrees;
if isreal(degrees)
    set(handles.text316,'String',num2str(degrees,5))
else
    set(handles.text316,'String','None')
end


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


