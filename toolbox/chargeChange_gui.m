function varargout = chargeChange_gui(varargin)
% CHARGECHANGE_GUI M-file for chargeChange_gui.fig
%      CHARGECHANGE_GUI, by itself, creates a new CHARGECHANGE_GUI or raises the existing
%      singleton*.
%
%      H = CHARGECHANGE_GUI returns the handle to a new CHARGECHANGE_GUI or the handle to
%      the existing singleton*.
%
%      CHARGECHANGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHARGECHANGE_GUI.M with the given input arguments.
%
%      CHARGECHANGE_GUI('Property','Value',...) creates a new CHARGECHANGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chargeChange_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chargeChange_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chargeChange_gui

% Last Modified by GUIDE v2.5 01-Mar-2011 15:23:53
%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chargeChange_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @chargeChange_gui_OutputFcn, ...
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

% --- Executes just before chargeChange_gui is made visible.
function chargeChange_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chargeChange_gui (see VARARGIN)

% Choose default command line output for chargeChange_gui
handles.output = hObject;
handles=appInit(hObject,handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chargeChange_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chargeChange_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% -----------------------------------------------------------------------
function handles = appInit(hObject, handles)

%each state has number, execution text, parameter name, old value, new
%value and action
handles.states.exec_txt= { ...
    'Save current configuration values' %1
    'Choose desired charge\nChoose Mode (Express mode omits some extra diagnostics)' %2
    'Close Mechanical Shutter' %3
    'Load and activate appropriate score injector config' %4
    %'Configure UV laser \n(e.g. block ''S'' arm for 20pC operation; unblock for 250pC).' %5
    'Choose Manual or Automatic mode to change parameters.\n(Auto mode changes several parameters at once; manual mode steps through each change)'%5 
    'Insert YAG02' %6
    'Insert TD11' %7
    'Turn BYKIK On' %8
    'Insert TDUND' %9
    'Set Guardian minimum TMIT' %10
    'Configure Laser Heater' %11
    'Turn Charge Feedback Off\nChange bunch charge feedback setpoint' %12
    'Change feedbacks lower TMIT limit' %13
    'Change VCC settings' %14
    'Change iris' %15
    'Change BPM Attenuation factor beam charge' %16
    'Change laser power set point' %17
    'Change gun phase' %18
    'Change laser phase' %19
    'Set BC1 and BC2 peak current feedback to zero' %20
    'Change PMT Voltages'%21
  %  'Set PMT755 gate'%23
    'Remove OTR2 and OTR4 filters' %22
    'Open Mechanical Shutter'%23
    'Turn on bunch charge feedback'%24
    'Switch beam to 10Hz \n\nClick Execute to launch RF Phase Scans GUI and start Schottky Scan \n\n(If it fails, find Schottky zero phase manually'%25
    'Click Execute to gold Schottky Scan results\n'%26
    'Click Execute to launch Cathode Position Scan'%27
    'Remove YAG02'%28
    'L0a phase scan\n\n(Should only move 1-2 degrees --if larger, stop and evaluate)'%29
    'L0b phase scan'%30
    'L1s phase scan'%31
    'L1x phase scan'%32
    'Steer BPM2 & BPM3 (right after gun) after a change to the solenoid strength' %33
    'Measure OTR2 emittance'%34
    'Measure bunch length on OTR2'%35
    'Measure TCAV0. Check slice emittance (<0.2 um ok to go on)'%36
    'Check OTR4 chirp and adjust L0b phase'%37
    'Switch to highest beam rate. Measure WS12 emittance'%38
    'Remove TD11'%39
    'Configure 30um filter from BC2 bunch length monitor'%40
    'Set BC2 peak current setpoint and turn on feedback\n\nVerify L1S phase setting'%41
    'Turn off BC2 feedback prior to Correlation plot'%42
    'Correlation plot of Peak Current vs. L2 Phase'%43
    'Turn on BC2 feedback after Correlation plot'%44
    'Insert TD11'%45
    'LEM.'%46
    'Remove TD11'%47
    'Measure emittance in LI28. Match as needed'%48
    'Turn BYKIK Off' %49
    'Lower Beam Rate. Measure emittance in LTU1. Match as needed'%50
    'Set Undulator configuration\n (0=OUT, 1=IN)'%51
    'Set linear taper\nSet Energy and Current in Undulator GUI\n (Current reading for 20pC is ~2x too large)'%52
    'Remove TDUND'%53
    'Set appropriate gas detector pressure based on energy. \nWhen done, hit Execute to calibrate'%54
    'Procedure Complete'}; 
handles.param.name= {...
    ''%1
    ''%2
    'Mechanical Shutter'%3
    ''%4
    %'Laser Arm Shutter'%5
    ''%5
    'YAG02'%6
    'TD11'%7
    'BYKIK'%8
    'TDUND'%9
    'Guardian minimum TMIT'%10
    'Laser Heater'%11
    'Old Bunch Charge Fdbk Setpoint\nOld Charge Fdbk Enable\nNew Bunch Charge Fdbk Setpoint\nNew Charge Fdbk Enable'%12
    'Feedbacks lower TMIT limit'%13
    'VCC P2P Threshold/pixel\nNoise Ratio'%14
    'Pockels Cell\nIris\nPockels Cell'%15
    'BPM Attenuation factor'%16
    'Laser power set point'%17
    'Gun phase'%18
    'Laser phase'%19
    'BC1 Energy \nBC1 Current\nBC2 Energy\nBC2 Current'%20
    'PMT:LI21:401\nPMT:LI28:150\nPMT:LTU1:246\nPMT:LTU1:755\nPMT:LTU1:820'%21
  %  'PMT755 Gate'%23
    'OTR2 Filters\n\nOTR4 Filters'%22
    'Mechanical Shutter'%23
    'Old Bunch Charge Fdbk Setpoint\nOld Charge Fdbk Enable\nNew Bunch Charge Fdbk Setpoint\nNew Charge Fdbk Enable'%24
    'Schottky Scan Phase Offset\nL0B Final Phase\nL1S Final Phase\nL2 Final Phase'%25
    'Schottky Scan Phase Offset\nL0B Final Phase\nL1S Final Phase\nL2 Final Phase'%26
    ''%27
    'YAG02'%28
    'Schottky Scan Phase Offset\nL0B Final Phase\nL1S Final Phase\nL2 Final Phase'%29
    'Schottky Scan Phase Offset\nL0B Final Phase\nL1S Final Phase\nL2 Final Phase'%30
    'Schottky Scan Phase Offset\nL0B Final Phase\nL1S Final Phase\nL2 Final Phase'%31
    'Schottky Scan Phase Offset\nL0B Final Phase\nL1S Final Phase\nL2 Final Phase'%32
    ''%33
    'OTR2'%34
    ''%35
    'TCAV0'%36
    ''%37
    'WS12'%38
    'TD11'%39
    'BC2 Filter'%40
    'L2 Chirp\nBC2 setpnt\nBC1 Energy\nBC1 Current\nBC2 Energy\nBC2 Current'%41
    'BC2 enable'%42
    'simple_L2_20pc_scan_config.mat'%43
    'BC2 enable'%44
    'TD11'%45
    'LEM'%46
    'TD11'%47
    'LI28'%48
    'BYKIK'%49
    'LTU1'%50
    'Undulators (Und #, State) \nState=0 --> Out\nState=1 --> In'%51
    'Use Spontaneous Radiation\nUse Wakefields\nUseGain Taper\nGain Taper Start\nGain Taper End\nGain Taper Amplitude\nBunch Charge\nPost Saturation Taper'%52
    'TDUND\nTimer (Matlab PV)'%53
    'Gas detector calibration'%54
    ''};%55
handles.param.tag= {...
    []%1
    []%2
    'mshut'%3
    []%4
    %'larm'%5
    []%5
    'yag'%6
    'td11'%7
    'bykik'%8
    'tdund'%9
    'grdmintmit'%10
    'lheat'%11
    ['bchrgsetp';'bchrgenbl';'bchrgsetp';'bchrgenbl']%12
    'fbcklowtmit'%13
    ['vccp2p';'vccrat']%14
    ['pcel';'iris';'pcel']%15
    'bpmatt'%16
    'lpow'%17
    'gphs'%18
    'lphs'%19
    ['bc1Eenab'; 'bc1Ienab'; 'bc2Eenab'; 'bc2Ienab']%20
    ['pmt401';'pmt150';'pmt246';'pmt755';'pmt820']%21
%    '755gate'%23
    [] %22
    'mshut'%23
    ['bchrgsetp';'bchrgenbl';'bchrgsetp';'bchrgenbl']%24
    []%25
    [] %26
    []%27
    'yag'%28
    []%29
    []%30
    []%31
    []%32
    []%33
    []%34
    []%35
    []%36
    []%37
    []%38
    'td11'%39
    'bc2filter'%40
    ['l2_chirp';'bc2_stpt';'bc1Eenab';'bc1Ienab';'bc2Eenab';'bc2Ienab']%41
    'bc2Ienab'%42
    []%43
    'bc2Ienab'%44
    'td11'%45
    []%46
    'td11'%47
    []%48
    'bykik'%49
    []%50
    []%51
    []%52
    ['tdund';'timer']%53
    []%54
    []};%55
handles.action={...
    'save_params(hObject,handles);'%1
    'pause(1);'%2
    'change_params(hObject,handles,val);'%3
    'pause(1);'%4
    %'change_params(hObject,handles,val);'%5
    'mode_change(hObject,handles);'%5
    'change_params(hObject,handles,val);'%6
    'change_params(hObject,handles,val);'%7
    'change_params(hObject,handles,val);'%8
    'change_params(hObject,handles,val);'%9
    'change_params(hObject,handles,val);'%10
    'change_params(hObject,handles,val);'%11
    'change_params(hObject,handles,val);'%12
    'change_params(hObject,handles,val);'%13
    'change_params(hObject,handles,val);'%14
    'set_iris(hObject,handles);'%15
    'change_params(hObject,handles,val);'%16
    'change_params(hObject,handles,val);'%17
    'change_params(hObject,handles,val);'%18
    'change_params(hObject,handles,val);'%19
    'change_params(hObject,handles,val);'%20
    'change_params(hObject,handles,val);'%21
  %  'change_params(hObject,handles,val);'%23
    'change_params(hObject,handles,val);'%22
    'change_params(hObject,handles,val);'%23
    'change_params(hObject,handles,val);'%24
    'launch_phase_scans(hObject,handles,1);'%25
    'launch_phase_scans(hObject,handles,0);'%26
    'launch_cathode_scan(hObject,handles);'%27
    'change_params(hObject,handles,val);'%28
    'launch_phase_scans(hObject,handles,2);'%29
    'launch_phase_scans(hObject,handles,3);'%30
    'launch_phase_scans(hObject,handles,4);'%31
    'launch_phase_scans(hObject,handles,5);'%32
    ''%33
    'meas_emit(hObject,handles);'%34
    'otr2_bunchlength(hObject,handles);'%35
    'meas_emit(hObject,handles);'%36
    ''%37
    'meas_emit(hObject,handles);'%38
    'change_params(hObject,handles,val);'%39
    'change_params(hObject,handles,val);'%40
    'change_params(hObject,handles,val);'%41
    'change_params(hObject,handles,val);'%42
    'corr_plot(hObject,handles);'%43
    'change_params(hObject,handles,val);'%44
    'change_params(hObject,handles,val);'%45
    'LEM(hObject,handles)'%46
    'change_params(hObject,handles,val);'%47
    'meas_emit(hObject,handles);'%48
    'change_params(hObject,handles,val);'%49
    'meas_emit(hObject,handles);'%50
    'move_undulators(hObject,handles,val)'%51
    'set_taper(hObject,handles,val)'%52
    'change_params(hObject,handles,val);'%53
    'calibrate_gasDetector(hObject,handles)'%54
    ''};%55
handles.param.PV={...
    []%1
    ''%2
    'IOC:BSY0:MP01:MSHUTCTL'%3
    ''%4
    %'SHTR:LR20:117:SARM_ENBL'%5
    ''%5
    'YAGS:IN20:241:PNEUMATIC'%6
    'DUMP:LI21:305:TD11_PNEU'%7
    'IOC:BSY0:MP01:BYKIKCTL'%8
    'DUMP:LTU1:970:TDUND_PNEU'%9
    'SIOC:SYS0:ML00:AO453'%10
    'IOC:BSY0:MP01:LSHUTCTL'%11
    {'FBCK:BCI0:1:CHRGSP';'FBCK:BCI0:1:ENABLE';'FBCK:FB02:GN01:S1DES';'FBCK:FB02:GN01:MODE'}%12
    'SIOC:SYS0:FB00:TMITLOW'%13
    {'CAMR:IN20:186:TSHD_P2P';'CAMR:IN20:186:NOISE_RATIO'}%14
    {'TRIG:LR20:LS01:TCTL';'IRIS:LR20:130:CONFG_SEL';'TRIG:LR20:LS01:TCTL'}%15
    'IOC:IN20:BP01:QANN'%16
    'IOC:IN20:LS11:PCTRL'%17
%     'LASR:BCIS:1:PCTRL'%17
    'GUN:IN20:1:GN1_PDES'%18
    'LASR:IN20:2:LSR_PDES2856'%19
    {'SIOC:SYS0:ML00:AO292';'SIOC:SYS0:ML00:AO293';...
    'SIOC:SYS0:ML00:AO294';'SIOC:SYS0:ML00:AO295'}%20     
    {'HVM:LI21:401:VoltageSet';'HVM:LI28:150:VoltageSet';'HVM:LTU1:246:VoltageSet';'HVM:LTU1:755:VoltageSet';'HVM:LTU1:820:VoltageSet'}%21
%    'QADC:LTU1:100:TWID'%22
    {'OTRS:IN20:571:FLT1_PNEU';'OTRS:IN20:571:FLT2_PNEU';'OTRS:IN20:711:FLT1_PNEU';'OTRS:IN20:711:FLT2_PNEU'}%22
    'IOC:BSY0:MP01:MSHUTCTL'%23
    {'FBCK:BCI0:1:CHRGSP';'FBCK:BCI0:1:ENABLE';'FBCK:FB02:GN01:S1DES';'FBCK:FB02:GN01:MODE'}%24
    ''%25
    ''%26
    ''%27
    'YAGS:IN20:241:PNEUMATIC'%28
    ''%29
    ''%30
    ''%31
    ''%32
    ''%33
    ''%34
    ''%35
    ''%36
    ''%37
    ''%38
    'DUMP:LI21:305:TD11_PNEU'%39
    'BLEN:LI24:886:P1FLT1_PNEU'%40
    {'SIOC:SYS0:ML00:AO267';'SIOC:SYS0:ML00:AO044'; ...
    'SIOC:SYS0:ML00:AO292';'SIOC:SYS0:ML00:AO293'; ...
    'SIOC:SYS0:ML00:AO294';'SIOC:SYS0:ML00:AO295'}%41       
    'SIOC:SYS0:ML00:AO295'%42
    ''%43
    'SIOC:SYS0:ML00:AO295'%44
    'DUMP:LI21:305:TD11_PNEU'%45
    ''%46
    'DUMP:LI21:305:TD11_PNEU'%47
    ''%48
    'IOC:BSY0:MP01:BYKIKCTL'%49
    ''%50
    ''%51
    ''%52
    {'DUMP:LTU1:970:TDUND_PNEU';'SIOC:SYS0:ML00:AO988'}%53
    ''%54
    ''};%55
newFdbkActive=lcaGetSmart('FBCK:FB04:LG01:STATE',0,'double');
if newFdbkActive
    handles.param.PV{20}={'FBCK:FB04:LG01:S2USED';'FBCK:FB04:LG01:S3USED'; ...
        'FBCK:FB04:LG01:S4USED';'FBCK:FB04:LG01:S5USED'};
    handles.param.PV{41}={'FBCK:FB04:LG01:CHIRPDES';'FBCK:FB04:LG01:S5DES'; ...
        'FBCK:FB04:LG01:S2USED';'FBCK:FB04:LG01:S3USED'; ...
        'FBCK:FB04:LG01:S4USED';'FBCK:FB04:LG01:S5USED'};
    handles.param.PV{42}={'FBCK:FB04:LG01:S5USED'};
    handles.param.PV{44}={'FBCK:FB04:LG01:S5USED'};
end
if ~strcmp(lcaGetSmart('LASR:LR20:1:UV_LASER_MODE'),'COHERENT #1')
    handles.param.PV{19}='SIOC:SYS0:ML01:AO495';
end

nstates=length(handles.states.exec_txt);
handles.states.num=1:nstates;
set(handles.nstates_txt,'String',nstates);
set(handles.state_pmu, 'String',1:nstates);
handles.param.origval=get_current_vals(hObject,handles);
handles.param.currval=handles.param.origval;
handles=set_phases(handles);
handles=update_params_list(hObject,handles);
handles.param.newval= {...
    [],[],[],[],[],[]%1
    [],[],[],[],[],[]%2
    0,0,0,0,0,0%3
    [],[],[],[],[],[]%4
    %1,0%5
    [],[],[],[],[],[]%5
    1,1,1,1,1,1%6
    0,0,0,0,0,0%7
    0,0,0,0,0,0%8
    0,0,0,0,0,0%9
    0.01,0.01,0.02,0.02,0.02,0.02%10
    0,0,1,1,1,1%11
    [0.02;0;0.02;0],[0.04;0;0.04;0],[0.08;0;0.08;0],[0.10;0;0.10;0],[0.15;0;0.15;0],[0.25;0;0.25;0]%12
    50e6,50e6,100e6,100e6,200e6,200e6%13
    [3;0.150],[3;0.150],[3;0.150],[6;0.150],[6;0.150],[6;0.150]%14
    [0; 8; 1],[0; 8; 1],[0; 7; 1],[0; 6; 1],[0; 6; 1],[0; 5; 1]%15
    .02,.04,.08,.10,.15,.25%16
    20,20,25,30,35,50%17
    -8,-8,-4,0,0,0%18
    -23,-23,-29,-30,-30,-30%19
    [1;0;1;0],[1;0;1;0],[1;0;1;0],[1;0;1;0],[1;0;1;0],[1;0;1;0]%20
    [725; 800; 1100; 1050; 1100],[725; 800; 1100; 1000; 1050], ...
    [600; 650; 900; 800; 800],[600; 650; 900; 800; 800], ...
    [600; 650; 900; 800; 800],[600; 650; 900; 800; 800]%21
%    200,100%23
    [0; 0; 0; 0],[0; 0; 0; 0],[0; 0; 0; 0],[0; 0; 0; 0],[0; 1; 0; 0],[0; 1; 0; 0]%22
    1,1,1,1,1,1%23
    [0.02;1;0.02;1],[0.04;1;0.04;1],[0.08;1;0.08;1],[0.10;1;0.10;1],[0.15;1;0.15;1],[0.25;1;0.25;1]%24
    [-15; -0.5; -25; -33],[-15; -0.5; -25; -33], ...
    [-25; -2.5; -24; -36],[-30; -2.5; -22; -36], ...
    [-30; -2.5; -22; -36],[-30; -2.5; -22; -36]%25
    [-15; -0.5; -25; -33],[-15; -0.5; -25; -33], ...
    [-25; -2.5; -24; -36],[-30; -2.5; -22; -36], ...
    [-30; -2.5; -22; -36],[-30; -2.5; -22; -36]%26
    [],[],[],[],[],[]%27
    0,0,0,0,0,0%28
    [-15; -0.5; -25; -33],[-15; -0.5; -25; -33], ...
    [-25; -2.5; -24; -36],[-30; -2.5; -22; -36], ...
    [-30; -2.5; -22; -36],[-30; -2.5; -22; -36]%29
    [-15; -0.5; -25; -33],[-15; -0.5; -25; -33], ...
    [-25; -2.5; -24; -36],[-30; -2.5; -22; -36], ...
    [-30; -2.5; -22; -36],[-30; -2.5; -22; -36]%30
    [-15; -0.5; -25; -33],[-15; -0.5; -25; -33], ...
    [-25; -2.5; -24; -36],[-30; -2.5; -22; -36], ...
    [-30; -2.5; -22; -36],[-30; -2.5; -22; -36]%31
    [-15; -0.5; -25; -33],[-15; -0.5; -25; -33], ...
    [-25; -2.5; -24; -36],[-30; -2.5; -22; -36], ...
    [-30; -2.5; -22; -36],[-30; -2.5; -22; -36]%32
    [],[],[],[],[],[]%33
    [],[],[],[],[],[]%34
    [],[],[],[],[],[]%35
    [],[],[],[],[],[]%36
    [],[],[],[],[],[]%37
    [],[],[],[],[],[]%38
    1,1,1,1,1,1%39
    0,0,1,1,1,1%40
    [-4000;-5500;1;0;1;1],[-4500;-5500;1;0;1;1], ...
    [-4100;1500;1;1;1;1],[-3000;3000;1;1;1;1], ...
    [-3000;3000;1;1;1;1],[-3000;3000;1;1;1;1]%41
    0,0,0,0,0,0%42
    [],[],[],[],[],[]%43
    1,1,1,1,1,1%44
    0,0,0,0,0,0%45
    [],[],[],[],[],[]%46
    1,1,1,1,1,1%47
    [],[],[],[],[],[]%48
    1,1,1,1,1,1%49
    [],[],[],[],[],[]%50
    [(1:33)' [zeros(5,1);ones(18,1);zeros(10,1)]], ...
    [(1:33)' [zeros(5,1);ones(18,1);zeros(10,1)]], ...
    [(1:33)' [ones(23,1);zeros(10,1)]],...
    [(1:33)' [ones(23,1);zeros(10,1)]],...
    [(1:33)' [ones(23,1);zeros(10,1)]],...
    [(1:33)' [ones(23,1);zeros(10,1)]];%51
    [1;1;1;6;23;-5;20;0],[1;1;1;6;23;-5;40;0], ...
    [1;1;1;1;23;-2;80;1],[1;1;1;1;23;-2;100;1], ...
    [1;1;1;1;23;-2;150;1],[1;1;1;1;23;-2;250;1];%52
    [1;0],[1;0],[1;0],[1;0],[1;0],[1;0]%53
    '','','','','',''%54
    '','','','','',''};%55

lcaPutSmart('SIOC:SYS0:ML00:AO988',1);   %PV for time accounting
handles=chargeList_pmu_Callback(handles.mode_btn, [], handles);
handles.param.currval=get_current_vals(hObject,handles);
handles=update_params_list(hObject,handles);
set(handles.state_pmu, 'Value',handles.states.num(1));
set(handles.mode_btn,'Value', 0); %assume Express mode to start
handles=mode_btn_Callback(handles.mode_btn, [], handles);
handles=set_laser_power(hObject,handles); %overides laser power setting based on current laser in use.
guidata(hObject, handles);
state_update(hObject,handles);

% -----------------------------------------------------------------------
function vals = get_current_vals(hObject,handles)
vals=cell(length(handles.states.num),1);
for nstate=1:length(handles.param.PV)
    if ~isempty(handles.param.PV{nstate})
        vals{nstate}=lcaGetSmart(handles.param.PV{nstate},0,'double');
    end
end
guidata(hObject, handles);
% -----------------------------------------------------------------------

function handles = update_params_list(hObject,handles)
% updates GUI with values. 

for state_idx=1:length(handles.param.origval)
    param_c=handles.param.currval{state_idx};
    param_o=handles.param.origval{state_idx};
    param_tag=handles.param.tag{state_idx};
    if ~isempty(param_c) && ~isempty(param_tag)
        for param_idx=1:length(param_c)
            str=sprintf('set(handles.curr_%s,''String'',param_c(%d),''FontWeight'',''normal'');'...
                ,param_tag(param_idx,:),param_idx);
            str2=sprintf('set(handles.orig_%s,''String'',param_o(%d),''FontWeight'',''normal'');', ...
                param_tag(param_idx,:),param_idx);
            try
                eval(str);
                eval(str2);
            catch
            end
        end
    end
end
curr_state=get(handles.state_pmu, 'Value');
param_tag=handles.param.tag{curr_state};
for param_idx=1:size(handles.param.tag{curr_state},1)
    str=sprintf('set(handles.curr_%s,''FontWeight'',''bold'');'...
        ,param_tag(param_idx,:));
    str2=sprintf('set(handles.orig_%s,''FontWeight'',''bold'');'...
        ,param_tag(param_idx,:));
    eval(str);
    eval(str2);
end
guidata(hObject, handles);
% -----------------------------------------------------------------------

function handles = state_update(hObject,handles)
curr_state=get(handles.state_pmu, 'Value');
handles = update_params_list(hObject,handles);
set(handles.instruct_txt,'String',sprintf(handles.states.exec_txt{curr_state}));
set(handles.param_txt,'String',sprintf(handles.param.name{curr_state}));
set(handles.origVal_txt,'String',handles.param.origval{curr_state});
new_val=num2str(handles.param.newval{curr_state,handles.charge_idx});
if size(new_val,1) > 1
    set (handles.newVal_txt,'Position',[84,2.0,14.2,12.25]);
else
    set (handles.newVal_txt,'Position',[84,12.8,14.2,1.615]);
end
set(handles.newVal_txt,'String',new_val);
switch curr_state
    case {2,4,33,37}
        set(handles.instruct_txt,'ForegroundColor','r');
        set(handles.manual_btn,'Visible','off');
        set(handles.automatic_btn,'Visible','off');
        set(handles.execute_btn,'Visible','on');
        set(handles.undo_btn,'Visible','on');
        set(handles.execute_btn,'Enable','off');
    case 5
        set(handles.instruct_txt,'ForegroundColor','r');
        set(handles.manual_btn,'Visible','on');
        set(handles.automatic_btn,'Visible','on');
        set(handles.execute_btn,'Visible','off');
        set(handles.undo_btn,'Visible','off');
        set(handles.execute_btn,'Enable','off');
    otherwise
        set(handles.instruct_txt,'ForegroundColor','k');
        set(handles.manual_btn,'Visible','off');
        set(handles.automatic_btn,'Visible','off');
        set(handles.execute_btn,'Visible','on');
        set(handles.undo_btn,'Visible','on');
        set(handles.execute_btn,'Enable','on');
end
guidata(hObject, handles);
% -----------------------------------------------------------------------
function handles = save_params(hObject,handles)
name=['chargeChange_gui_' datestr(now,30)] ;
config.param=handles.param;
util_configSave(name,config,1);
guidata(hObject, handles);
% -----------------------------------------------------------------------
function handles = load_params(hObject,handles)
config=util_configLoad('chargeChange_gui',1);
if isempty(config), return, end
handles.param=config.param;
switch handles.param.origval{17}
    case 0.02
        set(handles.chargeList_pmu,'Value',1);
        handles.param.newval{:,1}=handles.param.origval{:,1};
    case 0.04
        set(handles.chargeList_pmu,'Value',1);
        handles.param.newval{:,2}=handles.param.origval{:,1};
    case 0.08
        set(handles.chargeList_pmu,'Value',1);
        handles.param.newval{:,3}=handles.param.origval{:,1};
    case 0.10
        set(handles.chargeList_pmu,'Value',1);
        handles.param.newval{:,4}=handles.param.origval{:,1};
    case 0.15
        set(handles.chargeList_pmu,'Value',1);
        handles.param.newval{:,5}=handles.param.origval{:,1};
    case 0.25
        set(handles.chargeList_pmu,'Value',1);
        handles.param.newval(:,6)=handles.param.origval(:,1);
end
chargeList_pmu_Callback(hObject, [], handles);
handles=set_phases(handles);
guidata(hObject,handles);
% -----------------------------------------------------------------------
function handles = change_params(hObject,handles,val)
%val=1 sets new val; val=-1 restores original val
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
curr_state=get(handles.state_pmu, 'Value');
curr_val=get_current_vals(hObject,handles);
if val==1
    handles.param.origval{curr_state}=curr_val{curr_state};
    lcaPut(handles.param.PV{curr_state},str2num(get(handles.newVal_txt,'String')));
    handles.param.newval{curr_state,handles.charge_idx}=str2num(get(handles.newVal_txt,'String'));
else
    lcaPut(handles.param.PV{curr_state},handles.param.origval{curr_state});
end
pause(.5);
handles.param.currval=get_current_vals(hObject,handles);
update_params_list(hObject,handles);
guidata(hObject, handles);
% -----------------------------------------------------------------------

% -----------------------------------------------------------------------
function handles=set_iris(hObject,handles)
switch handles.charge_val
    case 250
        iris_val=5;
    case 20 
        iris_val=8;
    case 40
        iris_val=8;
    case {80,100,150}
        iris_val=6;
end
lcaPut('TRIG:LR20:LS01:TCTL',0);
lcaPut('IRIS:LR20:130:CONFG_SEL',iris_val);
moving=1;
while moving
    mot_x=lcaGet('IRIS:LR20:130:MOTR_X.DMOV',0,'double');
    mot_ang=lcaGet('IRIS:LR20:130:MOTR_ANGLE.DMOV',0,'double');
    if mot_x == 1 && mot_ang==1
        moving=0;
    end
    pause (1.)
end
lcaPut('TRIG:LR20:LS01:TCTL',1);
handles.param.currval=get_current_vals(hObject,handles);
update_params_list(hObject,handles);
guidata(hObject, handles);
% -----------------------------------------------------------------------
function handles=set_laser_power(hObject,handles)
laser_type=lcaGet('LASR:LR20:1:UV_LASER_MODE');
if strcmp(laser_type,'COHERENT #1')
    handles.param.newval{17,1}=20; %20pC
    handles.param.newval{17,2}=20; %40pC
    handles.param.newval{17,3}=25; %80pC
    handles.param.newval{17,4}=30; %100pC
    handles.param.newval{17,5}=35; %150pC
    handles.param.newval{17,6}=50; %250pC
else
    handles.param.newval{17,1}=20; %20pC
    handles.param.newval{17,2}=20; %40pC
    handles.param.newval{17,3}=25; %80pC
    handles.param.newval{17,4}=30; %100pC
    handles.param.newval{17,5}=35; %150pC
    handles.param.newval{17,6}=50; %250pC
end
guidata(hObject, handles);
% -----------------------------------------------------------------------
function handles=set_phases(handles)
if handles.param.origval{16}> 0.07 %80,100,150 or 250 pC
    handles.param.origval{25}=[-30;-2.5;-22;-36];
else
    handles.param.origval{25}=[-15;-0.5;-22;-33];
end
handles.param.origval{26}=handles.param.origval{25};
handles.param.origval(29:32)=repmat(handles.param.origval(25),1,4);
% -----------------------------------------------------------------------

function launch_phase_scans(hObject,handles,val)

[hObject_p,h]=util_appFind('Phase_Scans');
phases=get(handles.newVal_txt,'String');
curr_state=get(handles.state_pmu, 'Value');
handles.param.newval{curr_state,handles.charge_idx}=str2num(get(handles.newVal_txt,'String'));
set(h.FINALPHASE_SCHOTTKY,'String',phases(1,:));
Phase_Scans('FINALPHASE_SCHOTTKY_Callback',h.FINALPHASE_SCHOTTKY,[],guidata(hObject_p));
set(h.FINALPHASE_L0B,'String',phases(2,:));
Phase_Scans('FINALPHASE_L0B_Callback',h.FINALPHASE_L0B,[],guidata(hObject_p));
set(h.FINALPHASE_L1S,'String',phases(3,:));
Phase_Scans('FINALPHASE_L1S_Callback',h.FINALPHASE_L1S,[],guidata(hObject_p));
set(h.FINALPHASE_L2,'String',phases(4,:));
Phase_Scans('FINALPHASE_L2_Callback',h.FINALPHASE_L2,[],guidata(hObject_p));
switch val
    case 0 %Zero phase for Schottky
        callback='LASRZERO_Callback';
    case 1 %Schottky scan
        callback='SCHOTTKY_Callback';
    case 2 %L0a scan
        callback='L0A_Callback';
    case 3 %L0b scan
        callback='L0B_Callback';
    case 4 %L1s scan
        callback='L1S_Callback';
        set_L1S_phase(str2num(phases(3,:)),3);
    case 5 %Lx scan
        callback='L1X_Callback';
end

Phase_Scans(callback,hObject_p,[],guidata(hObject_p));
Phase_Scans('printLog_btn_Callback',hObject_p,[],guidata(hObject_p));
guidata(hObject, handles);

function set_L1S_phase(phase_angle,iter)
disp('Setting L1S Phase');
nFB={'SIOC:SYS0:ML00:AO292';'FBCK:FB04:LG01:S2USED'; ...
     'SIOC:SYS0:ML00:AO293';'FBCK:FB04:LG01:S3USED'};
for idx=1:iter
    disp('Setting L1S Phase');
    lcaPut(nFB,0); %turn fdbk off
    lcaPut('ACCL:LI21:1:L1S_PDES',phase_angle)% set phase
    lcaPut(nFB,1); %turn fdbk on
    pause (2.0);
end
lcaPut({'SIOC:SYS0:ML00:AO293';'FBCK:FB04:LG01:S3USED'},0); %turn fdbk off

function launch_cathode_scan(hObject,handles)

[hObject,h]=util_appFind('laser_cathodeAlign');
slope_OK=zeros(4,1);
iter=0;
while ~slope_OK
    h=laser_cathodeAlign('appInit',hObject,guidata(hObject));
    h=laser_cathodeAlign('acquireStart',hObject,guidata(hObject));
    h=laser_cathodeAlign('posPVSet',hObject,guidata(hObject),[]);
    h=laser_cathodeAlign('dataExport',hObject, guidata(hObject), 1);
    slope_OK=isempty(find(abs(h.slope)>0.5));
    iter=iter+1;
    if iter>3
        str=sprintf('Position has not converged (slope > 0.5) after %d iterations. Scan Again?',iter);
        btn=questdlg(str,'Warning','Continue','Cancel','Cancel');
        if strcmp(btn,'Cancel') return; end;
    end
end
% guidata(hObject, handles);

function meas_emit(hObject,handles)
[hObject,h]=util_appFind('emittance_gui');
h = emittance_gui('acquireReset',hObject, h);
curr_state=get(handles.state_pmu, 'Value');

switch handles.param.name{curr_state}
    case 'OTR2'
        dev='OTRS:IN20:571';
        type='scan';
        method=6;
    case 'TCAV0'
        dev='OTRS:IN20:571';
        type='scan';
        [hObject_tcav,h_tcav]=util_appFind('tcav_gui');
        tcav_gui('measureTcavSet',hObject_tcav, guidata(hObject_tcav),1);
        method=6;
        h=emittance_gui('dataMethodControl',hObject,h,method,6);
        h=emittance_gui('processSlicesNumControl',hObject, h, 11, []);
        h=emittance_gui('dataCurrentSliceControl',hObject, h, 7, 12);
        guidata(hObject,h);
        h.data=emittance_gui('appRemote',hObject,dev,type,'x');
        emittance_gui('dataExport',hObject,guidata(hObject),1);
        tcav_gui('measureTcavSet',hObject_tcav, guidata(hObject_tcav),0);
        h=emittance_gui('processSlicesNumControl',hObject, h, 0, []);
        h=emittance_gui('measureProfSet',hObject, h, 0);%remove OTR2
        return
    case 'WS12'
        dev='WIRE:LI21:293';
        type='scan';
        method=2;
    case 'LI28'
%         dev='WIRE:LI28:144 WIRE:LI28:444 WIRE:LI28:744';
        dev='WIRE:LI28:144';
        type='multi';
        method=2;
    case 'LTU1'
%         dev=['WIRE:LTU1:715'; 'WIRE:LTU1:735'; 'WIRE:LTU1:755'; 'WIRE:LTU1:775'];
        dev='WIRE:LTU1:715';
        type='multi';
        method=2;
end
h=emittance_gui('dataMethodControl',hObject,guidata(hObject),method,6);
wireID=get(h.processSelectPlaneY_rbn,'Value'); %0= X wire; 1= Y wire
plane={'x';'y'};
h.data=emittance_gui('appRemote',hObject,dev,type,plane{wireID+1});
emittance_gui('dataExport',hObject,guidata(hObject),1);
if strmatch('WIRE',dev)
    h.data=emittance_gui('appRemote',hObject,dev,type,plane{-wireID+2});
    emittance_gui('dataExport',hObject,guidata(hObject),1);
else
    h=emittance_gui('measureProfSet',hObject, h, 0);%remove OTR2
end

function otr2_bunchlength(hObject,handles)
[hObject,h]=util_appFind('tcav_gui');
h.data=tcav_gui('appRemote',hObject, 'OTRS:IN20:571', 'cal');
tcav_gui('dataExport',hObject,guidata(hObject),1);
h.data=tcav_gui('appRemote',hObject, 'OTRS:IN20:571', 'blen');
tcav_gui('dataExport',hObject,guidata(hObject),1);
tcav_gui('measureTcavSet',hObject, guidata(hObject),0);

function corr_plot(hObject,handles)
[hObject,h]=util_appFind('corrPlot_gui');
curr_state=get(handles.state_pmu, 'Value');
config_file=handles.param.name{curr_state};
h.data=corrPlot_gui('appRemote',hObject,config_file,1);
corrPlot_gui('dataExport',hObject,guidata(hObject),1);

function LEM(hObject,handles)
static=model_energyMagProfile([],{'L2' 'L3-BSY'},'doPlot',0,'init',1);
static=model_energyMagProfile(static,{'L2' 'L3-BSY'},'doPlot',1);
[m,k]=model_energyMagScale(static.magnet,static.klys);
model_energyMagTrim(m,k);


function move_undulators(hObject,handles,val)
val=str2num(get(handles.newVal_txt,'String'));
nUnd=1:33;
segmentMoveInOut(nUnd, val(:,2));

function set_taper(hObject,handles,val)
[hObject_und,h_und]=util_appFind('UndulatorTaperControl_gui');
curr_state=get(handles.state_pmu, 'Value');
params=get(handles.newVal_txt,'String');
set (h_und.USE_SPONT_RAD_BOX, 'Value',str2num(params(1,:)));
UndulatorTaperControl_gui('USE_SPONT_RAD_BOX_Callback',hObject_und, [], h_und);
set (h_und.USE_WAKEFIELDS_BOX, 'Value',str2num(params(2,:)));
UndulatorTaperControl_gui('USE_WAKEFIELDS_BOX_Callback',hObject_und, [], h_und);
set (h_und.ADD_GAIN_TAPER_BOX, 'Value',str2num(params(3,:)));
UndulatorTaperControl_gui('ADD_GAIN_TAPER_BOX_Callback',hObject_und, [], h_und);
set (h_und.GAIN_TAPER_START_SEGMENT,'String',params(4,:));
UndulatorTaperControl_gui('GAIN_TAPER_START_SEGMENT_Callback',hObject_und, [], h_und);
set (h_und.GAIN_TAPER_END_SEGMENT,'String',params(5,:));
UndulatorTaperControl_gui('GAIN_TAPER_END_SEGMENT_Callback',hObject_und, [], h_und);
set (h_und.GAIN_TAPER_AMPLITUDE,'String',params(6,:));
UndulatorTaperControl_gui('GAIN_TAPER_AMPLITUDE_Callback',hObject_und, [], h_und);
set (h_und.MODEL_BUNCH_CHARGE,'String',params(7,:));
set (h_und.ADD_POST_SATURATION_TAPER_BOX, 'Value',str2num(params(8,:)));
UndulatorTaperControl_gui('ADD_POST_SATURATION_TAPER_BOX_Callback',hObject_und, [], h_und);
guidata(hObject_und,h_und);

function calibrate_gasDetector(hObject,handles)
[hObject,h]=util_appFind('E_loss_scan');
E_loss_scan('CALIBRATE_Callback',h.CALIBRATE, [], h);
E_loss_scan('ELOG_CAL_Callback',hObject, [], guidata(hObject));
h.data=E_loss_scan('appRemote',hObject);
E_loss_scan('ELOG_Callback',hObject, [], guidata(hObject));



% --- Executes on button press in previous_btn.
function change_state_Callback(hObject, eventdata, handles,val)
% hObject    handle to previous_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_state=get(handles.state_pmu, 'Value');
state_ok=0;
while ~state_ok
    new_state=curr_state+val;
    if (new_state>max(handles.states.num))
        new_state=new_state-1;
    end
    if (new_state<min(handles.states.num))
        new_state=new_state+1;
    end
    if handles.state_enabled(new_state) == 1
        state_ok=1;
    end
    curr_state=new_state;
end
set(handles.state_pmu, 'Value',new_state);
state_update(hObject,handles);

% mark start time
if (new_state == 6)
	try
		% if this succeeds, we've already recorded a start time
		handles.start_time;
	catch
		handles.start_time = tic;
	end
end

% record time elapsed
if (new_state == 40)
	try
		elapsed_time = toc(handles.start_time);
		old_value = lcaGetSmart('SIOC:SYS0:ML03:AO704', 0, 'double');
		lcaPutSmart('SIOC:SYS0:ML03:AO704', old_value + elapsed_time);
		handles.start_time = -1; % marks start time as logged
	catch
		% either didn't log or already logged start time, so don't update
	end
end

guidata(hObject, handles);

% --- Executes on button press in execute_btn.
function execute_btn_Callback(hObject, eventdata, handles)
% hObject    handle to execute_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_state=get(handles.state_pmu, 'Value');
val=1;
eval(handles.action{curr_state});


% --- Executes on button press in undo_btn.
function undo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to undo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_state=get(handles.state_pmu, 'Value');
val=-1;
eval(handles.action{curr_state});

% --- Executes during object creation, after setting all properties.
function instruct_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to instruct_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in state_pmu.
function state_pmu_Callback(hObject, eventdata, handles)
% hObject    handle to state_pmu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns state_pmu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from state_pmu
state_update(hObject,handles);

% --- Executes on button press in loadConfig.
function loadConfig_Callback(hObject, eventdata, handles)
% hObject    handle to loadConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_params(hObject,handles);

% --- Executes on button press in saveConfig.
function saveConfig_Callback(hObject, eventdata, handles)
% hObject    handle to saveConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_params(hObject,handles);


% --- Executes on button press in manual_btn.
function manual_btn_Callback(hObject, eventdata, handles)
% hObject    handle to manual_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_state_Callback(hObject, eventdata, handles,1) %move ahead to next state

% --- Executes on button press in automatic_btn.
function automatic_btn_Callback(hObject, eventdata, handles)
% hObject    handle to automatic_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = waitbar(0,'Changing parameters...');
for state=6:22;
waitbar((state-6)/16);
change_state_Callback(hObject, eventdata, handles,1) %move ahead to next state
set(handles.state_pmu, 'Value',state);
state_update(hObject,handles);
val=1;
eval(handles.action{state});
end
close(h);
change_state_Callback(hObject, eventdata, handles,1) %move ahead to next state

% --- Executes when user attempts to close chargeChange_gui.
function chargeChange_gui_CloseRequestFcn(hObject, eventdata, handles)
lcaPut('SIOC:SYS0:ML00:AO988',0);   %PV for time accounting
if ~ispc
util_appClose(hObject);
end
delete(hObject);

% --- Executes on button press in mode_btn.
function handles=mode_btn_Callback(hObject, eventdata, handles)
handles.state_enabled=zeros(55,1);
switch get(hObject,'Value')
    case 0
        handles.mode='Express';
        handles.state_enabled([1:34,39:41,46,49:53,55])=1;
    case 1
        handles.mode='Normal';
        handles.state_enabled=ones(55,1);
end
set(hObject,'String',handles.mode);
handles = state_update(hObject,handles);
guidata(hObject, handles);

% --- Executes on selection change in chargeList_pmu.
function handles=chargeList_pmu_Callback(hObject, eventdata, handles)
val=get(handles.chargeList_pmu,'Value');
switch val
    case 1
        handles.charge_idx=1;
        handles.charge_val=20;
    case 2
        handles.charge_idx=2;
        handles.charge_val=40;
    case 3
        handles.charge_idx=3;
        handles.charge_val=80;
    case 4
        handles.charge_idx=4;
        handles.charge_val=100;
    case 5
        handles.charge_idx=5;
        handles.charge_val=150;
    case 6
        handles.charge_idx=6;
        handles.charge_val=250;
end
handles = state_update(hObject,handles);
guidata(hObject, handles);
