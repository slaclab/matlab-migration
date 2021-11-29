function varargout = meas_dispersion_gui(varargin)
% MEAS_DISPERSION_GUI M-file for meas_dispersion_gui.fig
%      MEAS_DISPERSION_GUI, by itself, creates a new MEAS_DISPERSION_GUI or
%      raises the existing
%      singleton*.
%
%      H = MEAS_DISPERSION_GUI returns the handle to a new
%      MEAS_DISPERSION_GUI or the handle to
%      the existing singleton*.
%
%      MEAS_DISPERSION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEAS_DISPERSION_GUI.M with the given
%      input arguments.
%
%      MEAS_DISPERSION_GUI('Property','Value',...) creates a new MEAS_DISPERSION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before meas_dispersion_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to meas_dispersion_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help meas_dispersion_gui

% Last Modified by GUIDE v2.5 26-Jan-2008 20:36:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @meas_dispersion_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @meas_dispersion_gui_OutputFcn, ...
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


% --- Executes just before meas_dispersion_gui is made visible.
function meas_dispersion_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to meas_dispersion_gui (see VARARGIN)

% Choose default command line output for meas_dispersion_gui
handles.output = hObject;
handles=appInit(hObject,handles);

% add init here...
model_init('source','MATLAB','online',0);
[sys,accelerator]=getSystem();
handles.area  = get(handles.AREA,'Value');              % 1='BC1', 2='DL1', 3='BC2', 4='DL2', 5='CLTS', 6='LTUS'
handles.area_str = get(handles.AREA,'String');          % 'BC1' or 'DL1' or 'BC2', 5='CLTS', 6='LTUS'
handles.nsamp = str2int(get(handles.NSAMP,'String'));   % number of energy settings
handles.navg  = str2int(get(handles.NAVG,'String'));    % number of shots to average per Energy setting
handles.waiti = str2int(get(handles.WAITI,'String'));   % pause time at first set [sec]
handles.wait  = str2int(get(handles.WAIT,'String'));    % pause time between sets [sec]
handles.rate  = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);  % pause between BPM lcagGet's (1/rate) [sec]
if handles.rate < 1
  handles.rate = 1;
end
handles.showplots = get(handles.SHOWPLOTS,'Value');
handles.useL1 = get(handles.USEL1,'Value');
handles.sec_order = get(handles.ORDER,'Value');
handles.exportFig=[];
handles.abstrPV='ACCL:LI22:1:ABSTR_ACTIVATE';

handles = setup(hObject,handles);                       % setup basic stuff for the area
handles = initialize(hObject,handles);                  % re-init before next meas.

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes meas_dispersion_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = meas_dispersion_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

%{
% List of index names
handles.sector.indexList={'LCLS' {'IN20' 'LI21' 'LI28' 'LTU1' 'UND1'}; ...
%    'FACET' {'LI10' 'LI19'}; ...
    'FACET' {}; ...
    'NLCTA' {'NLCTA'}; ...
    'LCLSII' {'IN10' 'LI11' 'LI14' 'BA21' 'LTU2'}; ...
    };
handles.sector.indexList(:,3)=num2cell(gui_indexColor,2);
[sys,accelerator]=getSystem;
if ~isempty(accelerator)
    handles.sector.indexList(~strcmp(handles.sector.indexList(:,1),accelerator),:)=[];
end
handles.accelerator=accelerator;
%}

% List of sector names
%handles.sector.nameList={'DL1' 'BC1' 'BC2' 'DL2'};
handles.sector.nameList={'BC1' 'DL1' 'BC2' 'DL2' 'CLTS' 'LTUS'};
%handles.sector.nameList=[handles.sector.indexList{:,2}];

handles.area=2;



function handles = setup(hObject,handles)

% get machine reference energies - added 11/17/10 nate
handles.energy_setpoints = model_energySetPoints();
set(handles.USEL1,'Value',0);
str={'off' 'on'};
set(handles.USE_L1X,'Visible',str{(handles.area == 1)+1}); % make L1X select button visible for BC1 area
handles.use_L1X = get(handles.USE_L1X,'Value');   % scan L1X amplitude when this is set

area_str=handles.area_str{handles.area};
str={'bends' 'chicane'};
bends={'BX12' 'BX02' 'BX22' 'BYD1' 'BYD1B' 'BYD1B'};
BACT = control_magnetGet(bends{handles.area});
bLim=[0.1 0.05 1 2 2 2]; % note: changing lower limit from 3 GeV to below 2.5 GeV see in plans here: https://portal.slac.stanford.edu/sites/lcls_public/lcls_ii/acc_phy/technotes_lib/LCLS-II-TN-19-09.pdf
if abs(BACT) < bLim(handles.area)
    warndlg([area_str ' ' str{strncmp(area_str,'BC',2)+1} ' appear(s) to be "OFF".  For now, the "use energy command" flag will be set (i.e., energy not measured).'],'BENDS OFF?');
    set(handles.USEL1,'Value',1);
    handles.useL1 = get(handles.USEL1,'Value');
end

dE_pvs={'L1S' 'L0B' 'L2' 'L3' 'L3' 'L3'};
handles.dE_pv=dE_pvs(handles.area);
crest_phase = 0;
if handles.area == 1
    if handles.use_L1X
        crest_phase = -180;
        handles.dE_pv = {'L1X'};     % L1X
    end
end
Phase = control_phaseGet(handles.dE_pv,'PDES');
str1 = [handles.dE_pv{:} ' RF phase is >10 deg off crest at ' num2str(crest_phase) ' deg.  It should be on crest for dispersion measurement.'];
if abs(Phase-crest_phase) > 10
    warndlg(str1,'INITIAL PHASE WARNING');
end

switch handles.area
    case 1        % BC1

    case 2        % DL1

    case 3        % BC2
  yn = questdlg('L2 phase should be on crest for dispersion measurement.  Continue anyway?','INITIAL PHASE WARNING');
  if ~strcmp(yn,'Yes')
    return
  end

    case 4        % DL2

    case 5        % CLTS

    case 6        % LTUS

    otherwise
        errordlg('Invalid area chosen - quitting.', 'Area Invalid');
        error('Invalid area chosen - quitting.')
end

handles.model_options = {}; 

switch handles.area
    case 1        % BC1
  handles.range_dE_E=[-3.6 3.6]/100;
  handles.sigd     = 1.3E-2;    % nom. BC1 energy spread [ ] (250 pC is 1.3%)
  handles.nom_E_id=3;
  handles.M        = [33 -88; -44 450];         % [k1 k2]' = -M*[etax0 etaxp0]';
  handles.Qpv      = { 'QUAD:LI21:221'; ...
                       'QUAD:LI21:251'};        % CQ11 & CQ12 PV's
  handles.eta_pv0 =  { 'BPMS:LI21:201'};        % BPM just before BC1 BPMS11
  handles.eta_pv1 =  { 'BPMS:LI21:233'};        % BPMS11
  handles.BPM_pvs =  { 'BPMS:LI21:278'          % BPMs after BC1 ..
                       'BPMS:LI21:301'};
  handles.fdbkReg = 'L0B';
  handles.model_options(end+1) = {'BEAMPATH=CU_HXR'};

    case 2        % DL1
  handles.range_dE_E=[-1.0 1.0]/100;
  handles.sigd     = 0.1E-2;    % nom. DL1 energy spread [ ]
  handles.nom_E_id=2;
  handles.M = 0.222*[1/0.008 1/0.010]/2;   % [k1 k2]' = -M*[etax0 etaxp0]';
  handles.Qpv      = { 'QUAD:IN20:731'};            % QB PV
  handles.eta_pv0 =  { 'BPMS:IN20:651'};            % BPM just before DL1 BPM13
  handles.eta_pv1 =  { 'BPMS:IN20:731'};            % BPM13
  handles.BPM_pvs =  { 'BPMS:IN20:771'              % BPMs after DL1
                       'BPMS:IN20:781'
                       'BPMS:LI21:131'
                       'BPMS:LI21:161'
                       'BPMS:LI21:201'};
  handles.fdbkReg = 'L0B';
  handles.model_options(end+1) = {'BEAMPATH=CU_HXR'};

    case 3        % BC2
  handles.range_dE_E=[-2.5 2.5]/100;
  handles.sigd     = 0.35E-2;   % nom. BC2 energy spread [ ] (250 pC is 0.35%)
  handles.nom_E_id=4;
  handles.M        = -[-1.5045  100.4412; -4.1245 -241.8941]; % [k1 k2]' = -M*[etax0 etaxp0]' at BPM LI25 201;
  handles.Qpv      = { 'QUAD:LI24:740'
                       'QUAD:LI24:860'};        % CQ21 & CQ22 PV's
  handles.eta_pv0 =  { 'BPMS:LI24:701'};        % BPM just before BC2 BPMS21
  handles.eta_pv1 =  { 'BPMS:LI24:801'};        % BPMS21
  handles.BPM_pvs =  { 'BPMS:LI25:201'
                       'BPMS:LI25:301'
                       'BPMS:LI25:401'
                       'BPMS:LI25:501'
                       'BPMS:LI25:601'};        % Old SLC BPMs after BC2
  handles.fdbkReg = 'L2';
  handles.model_options(end+1) = {'BEAMPATH=CU_HXR'};

    case 4        % DL2
  handles.range_dE_E=[-1.0 1.0]/100;
  handles.sigd     = 0.1E-2;    % nom. DL2 energy spread [ ]
  handles.nom_E_id=5;
  handles.M        = -[-13.88 -132.8; 6.534 -145.8]; % [k1 k2]' = -M*[etax0 etaxp0]' at BPMDL4;
  handles.Qpv      = { 'QUAD:LTUH:440'
                       'QUAD:LTUH:460'};        % CQ31 & CQ32 PV's
  handles.eta_pv0 =  { 'BPMS:LTUH:190'};        % BPM just before DL2
  handles.eta_pv1 =  { 'BPMS:LTUH:250'};          % BPMDL1
%                       'BPMS:LTUH:450'};        % BPMDL3
  handles.BPM_pvs =  { 'BPMS:LTUH:550'
                       'BPMS:LTUH:590'
                       'BPMS:LTUH:620'
                       'BPMS:LTUH:640'
                       'BPMS:LTUH:660'};        % BPMs after DL2
  handles.fdbkReg = 'DL2';
  handles.model_options(end+1) = {'BEAMPATH=CU_HXR'};

    case 5        % CLTS
  handles.range_dE_E=[-1.0 1.0]/100;
  handles.sigd     = 0.1E-2;    % nom. DL2 energy spread [ ]
  handles.nom_E_id=5;
  handles.M        = [47.725 42.882 -0.142 0.437; 32.827 440.216 -0.705 -2.974; -27.141 -370.671 0.006 9.261; -36.237 -476.345 11.442 -337.981]; % [k1 k2]' = -M*[etax0 etaxp0]' at BPMDL4;
  handles.Qpv      = { 'QUAD:CLTS:420'          % QCUS1 PV
                       'QUAD:CLTS:450'          % QCUS2 PV
                       'QUAD:CLTS:470'          % QCUS3+8 PV; QCUS8 is QUAD:CLTS:570, but on the same string?
                       'QUAD:CLTS:510'};        % QCUS5+6 PV; QCUS6 is QUAD:CLTS:530, but on the same string?
%    handles.eta_pv0 =  { 'BPMS:CLTS:210?'};        % BPMCUS?: BPM right before dog-leg
  handles.eta_pv0 =  { 'BPMS:CLTH:215'};        % BPMCUS: BPM right before dog-leg
%    handles.eta_pv1 =  { 'BPMS:CLTS:420??'};        % BPMCUS1: BPM near max dispersion in both planes in dog leg
  handles.eta_pv1 =  { 'BPMS:CLTS:420'};        % BPMCUS1: BPM near max dispersion in both planes in dog leg
  handles.BPM_pvs =  { 'BPMS:BSYS:865'
%                         'BPMS:LTUS:110' % DNE
                       'BPMS:LTUS:120'
                       'BPMS:LTUS:150'};        % BPMs after DL2
  handles.fdbkReg = 'CLTS';
  handles.model_options(end+1) = {'BEAMPATH=CU_SXR'};

    case 6        % LTUS
  handles.range_dE_E=[-1.0 1.0]/100;
  handles.sigd     = 0.1E-2;    % nom. DL2 energy spread [ ]
  handles.nom_E_id=5;
  handles.M        = [-1.5065 -11.2322; -0.3618 1.8389]; % [k1 k2]' = -M*[etax0 etaxp0]' at BPMDL4;
  handles.Qpv      = { 'QUAD:LTUS:180'          % 1st string (QDL12,15,16,19) PVs; in the database, they are QUAD:LTUS:180,300,345,450 in that order
                       'QUAD:LTUS:235'};        % 2nd string (QDL13,14,17,18) PVs; in the database, they are QUAD:LTUS:235,270,370,430 in that order
  handles.eta_pv0 =  { 'BPMS:LTUS:150'};        % BPM just before DL
%    handles.eta_pv1 =  { 'BPMS:LTUS:235'};          % BPM with max dispersion - looks like they changed this
  handles.eta_pv1 =  { 'BPMS:LTUS:300'};          % BPM with max dispersion - they never added BPMs near max dispersion so this will have to do :/ (BPMDL13,14,17,18 only exist in the oracle database but not the real beamline)
%                       'BPMS:LTU1:450'};        % BPMDL3
  handles.BPM_pvs =  { 'BPMS:LTUS:570'      % others with small dispersion:
                       'BPMS:LTUS:580'      % BPMS:LTUS:470,500,510
                       'BPMS:LTUS:620'
                       'BPMS:LTUS:640'
                       'BPMS:LTUS:660'};        % BPMs after DL
  handles.fdbkReg = 'LTUS';
  handles.model_options(end+1) = {'BEAMPATH=CU_SXR'};
  
end

% needed to call the design model
handles.design_model_options = handles.model_options;
handles.design_model_options(end+1) = {'TYPE=DESIGN'};

handles.nom_E = handles.energy_setpoints(handles.nom_E_id) * 1000;      % nominal energy (MeV)
handles.fdbkList=control_fbNames(handles.fdbkReg);

set([handles.MIN_ENERGY handles.MAX_ENERGY],{'String'}, ...
    cellstr(num2str(handles.range_dE_E(:)*100,'%+4.1f')));

handles.max_dE_E = str2double(get(handles.MAX_ENERGY,'String'))/100; % Max. dE/E setting [ ]
handles.min_dE_E = str2double(get(handles.MIN_ENERGY,'String'))/100; % Min. dE/E setting [ ]

handles.nbpms = length(handles.BPM_pvs);
handles.all_BPM_pvs = [handles.eta_pv1; handles.BPM_pvs];

handles.Zs=model_rMatGet(handles.BPM_pvs,[],handles.model_options,'Z');
handles.Zs0=handles.Zs(1);

r=model_rMatGet(handles.BPM_pvs(1),handles.BPM_pvs,handles.model_options);
handles.R1s=permute(r(1,[1 2 3 4 6],:),[3 2 1]);
handles.R3s=permute(r(3,[1 2 3 4 6],:),[3 2 1]);

r=model_rMatGet(handles.eta_pv0,handles.eta_pv1,handles.model_options);
R1=permute(r(1,[1 2 3 4 6],:),[3 2 1]);

handles.Leff=model_rMatGet(handles.Qpv,[],handles.model_options,'LEFF'); % effective length of dispersion quads [m]
twiss=num2cell(model_twissGet(handles.BPM_pvs{1},handles.design_model_options));
[handles.bx0,handles.ax0,handles.by0,handles.ay0]=deal(twiss{[2 3 5 6]});

eta=model_rMatGet(handles.eta_pv0,handles.Qpv,handles.design_model_options);
eta=diag(squeeze(eta(1,6,:)));
r=model_rMatGet(handles.Qpv,handles.BPM_pvs(1),handles.design_model_options);
handles.M1=-pinv(squeeze(r(1:2,2,:))*eta*diag(handles.Leff));
if handles.area == 4, handles.M1=-handles.M1;end

handles.etaX = R1(5);   % R16 from prime0 micre0 unite0 to 'BPMS' micre1 unite1 [m]
if abs(handles.etaX) < 10E-3
  warndlg('Dispersion at energy BPM in XAL model database < 10 mm.  Please re-run model with BC1, BC2, or DL1 ON.  For now, the "use energy command" flag will be set (i.e., energy not measured).','MODEL PROBLEM');
  set(handles.USEL1,'Value',1);
  handles.useL1 = get(handles.USEL1,'Value');
end
guidata(hObject, handles);


function handles = initialize(hObject,handles)
set(handles.MESSAGE,'String',' ')
set([handles.Q1BDES handles.Q2BDES handles.Q3BDES handles.Q4BDES handles.CORRECT],'Visible','off');
n = length(handles.eta_pv1);
[handles.Xs,handles.Ys,handles.Ts] = deal(zeros(handles.navg ,(handles.nbpms+n)));
[handles.Xsa,handles.Ysa,handles.Tsa,handles.dXsa,handles.dYsa,handles.dTsa] = ...
    deal(zeros(handles.nsamp,(handles.nbpms+n)));
guidata(hObject, handles);


function AREA_Callback(hObject, eventdata, handles)
handles.area = get(hObject,'Value');
handles.area_str = get(hObject,'String');          % 'BC1' or 'DL1' or 'BC2' or 'DL2' or 'CLTS' or 'LTUS'
handles = setup(hObject,handles);
handles = initialize(hObject,handles);
guidata(hObject, handles);


function TAKEDATA_Callback(hObject, eventdata, handles)
set(handles.TAKEDATA,'BackgroundColor','white')
set(handles.MESSAGE,'String',' ')

fdbkList=handles.fdbkList;
X = lcaGetSmart(strcat(handles.eta_pv1,':X'));       % first read dispersion BPM to see if energy is way off
switch handles.area
    case {1 2}               % if DL1 or BC1...
  if abs(X) > abs(handles.etaX*0.01E3)              % if energy is more than 1% off initially...
    yne = questdlg('The beam energy is more than 1% off right now.  Do you really want to continue.','ENERGY NOT RIGHT');
    if ~strcmp(yne,'Yes')
      set(handles.TAKEDATA,'BackgroundColor','yellow')
      set(handles.TAKEDATA,'String','Scan Energy')
      set(handles.MESSAGE,'String','Energy is wrong.')
      drawnow
      return
    end
  end
  fdbkListOn=lcaGet(fdbkList,1,'double'); % get status of feedbacks
  lcaPut(fdbkList,0);                                 % turn off feedbacks temporarily
  handles.V0 = control_phaseGet(handles.dE_pv,'ADES');
  handles.dE_E0 = (handles.max_dE_E - handles.min_dE_E)/2*linspace(-1,1,handles.nsamp);
  handles.V = handles.V0+handles.dE_E0*handles.nom_E;
  for j = 1:handles.nsamp
    control_ampSet(handles.dE_pv,handles.V(j));
    set(handles.TAKEDATA,'String',sprintf('point %2.0f...',j))
    drawnow
    if j==1
      pause(handles.waiti);
    else
      pause(handles.wait);
    end
    [X,Y,T,dX,dY,dT,iok] = read_BPMs(handles.all_BPM_pvs,handles.navg,handles.rate);
    handles.Xsa(j,:)  = X;
    handles.Ysa(j,:)  = Y;
    handles.Tsa(j,:)  = T;
    handles.dXsa(j,:)  = dX;
    handles.dYsa(j,:)  = dY;
    handles.dTsa(j,:)  = dT;
    handles.dE_E  = handles.Xsa(:,1)/handles.etaX;
    handles.ddE_E = handles.dXsa(:,1)/handles.etaX;

    if ~any(iok)
      control_ampSet(handles.dE_pv,handles.V0);  % put energy setpoint back after BAD scan
      errordlg('No beam - restoring RF - quitting.','NO BEAM');
      set(handles.TAKEDATA,'String','NO BEAM...')
      drawnow
      pause(2)
      set(handles.TAKEDATA,'BackgroundColor','yellow')
      set(handles.TAKEDATA,'String','Scan Energy')
      set(handles.MESSAGE,'String','No beam - retry?')
      drawnow
      lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
      return
    end

    for n = 1:(handles.nbpms+1)
      if iok(n)==0
        control_ampSet(handles.dE_pv,handles.V0);    % put energy setpoint back after BAD scan
        errordlg(['No beam seen on ' handles.all_BPM_pvs{n,:}],'BAD BPM')
        set(handles.TAKEDATA,'String','Dead BPM...')
        drawnow
        pause(2)
        set(handles.TAKEDATA,'BackgroundColor','yellow')
        set(handles.TAKEDATA,'String','Scan Energy')
        set(handles.MESSAGE,'String',['No beam seen on ' handles.all_BPM_pvs{n,:}])
        drawnow
        lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
        return
      end
    end
  end
  control_ampSet(handles.dE_pv,handles.V0);        % put energy setpoint back after GOOD scan

    case 3    % if BC2...
  if abs(X) > abs(handles.etaX*0.01E3)                       % if energy is more than 1% off initially...
    yne = questdlg('The beam energy is more than 1% off right now.  Do you really want to continue.','ENERGY NOT RIGHT');
    if ~strcmp(yne,'Yes')
      set(handles.TAKEDATA,'BackgroundColor','yellow')
      set(handles.TAKEDATA,'String','Scan Energy')
      set(handles.MESSAGE,'String','Energy is wrong.')
      drawnow
      return
    end
  end
  fdbkList=[fdbkList;{handles.abstrPV}];
  fdbkListOn=lcaGet(fdbkList,1,'double'); % get status of feedbacks
  lcaPut(fdbkList,0);                                 % turn off feedbacks temporarily
  handles.dE_E0 = linspace(handles.min_dE_E,handles.max_dE_E,handles.nsamp);    % dE/E steps [ ]
  all_phase_pvs = {'ACCL:LI24:100:KLY_PDES'; ...
                   'ACCL:LI24:200:KLY_PDES'; ...
                   'ACCL:LI24:300:KLY_PDES'};
  phase = lcaGetSmart(all_phase_pvs);
  iact=bitand(control_klysStatGet({'24-1' '24-2' '24-3'}),1);
  iklys = find(iact);
  if length(iklys)<2
    errordlg('More than one of 24-1, 24-2, and 24-3 are deactivated off beam code 1 - cannot proceed.','NOTE ENOUGH KLYSTRONS');
    set(handles.TAKEDATA,'BackgroundColor','yellow')
    set(handles.TAKEDATA,'String','Scan Energy')
    set(handles.MESSAGE,'String','More than one of 24-1, 24-2, or 24-3 are deactivated')
    drawnow
    lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
    return
  else
    iklys = iklys(1:2);                     % choose only two of 24-1, 24-2, or 24-3
  end
  phase_pvs = all_phase_pvs(iklys);         % these are now just two PV's (2 of 24-1,-2, or -3)
  phases = phase(iklys);                    % these are now just two phases (2 of 24-1,-2, or -3)
  V0 = 220;                                 % energy gain at crest per klystron (MeV)
  y = handles.dE_E0*handles.nom_E/V0 + cosd(phases(1)) + cosd(phases(2));
  a = cosd(phases(1)) + cosd(phases(2));
  b = sind(phases(2)) - sind(phases(1));
  phi = asind(y/sqrt(a^2+b^2)) - asind(a/sqrt(a^2+b^2));   % delta-phases to step through (deg)
  i1 = any(sign(phases(1))*(phases(1)+phi)<0 | sign(phases(1))*(phases(1)+phi)> 180);  % any phase settings out of range?
  i2 = any(sign(phases(2))*(phases(2)-phi)<0 | sign(phases(2))*(phases(2)-phi)> 180);  % ...
  if i1 || i2    % if RF phases are outside of range - quit.
    errordlg('The BC2 energy feedback RF phases are too close to accel or decel crest to run this scan.','PHASES OUT OF RANGE')
    set(handles.TAKEDATA,'BackgroundColor','yellow')
    set(handles.TAKEDATA,'String','Scan Energy')
    set(handles.MESSAGE,'String','Phases are out of range')
    drawnow
    lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
    return
  end
  disp(['Initial phase of ' phase_pvs{1} ' = ' sprintf('%6.1f degS',phases(1)) ' and ' phase_pvs{2} ' = ' sprintf('%6.1f degS',phases(2))])
  for j = 1:handles.nsamp
    disp(['Setting ' phase_pvs{1} ' to ' sprintf('%6.1f degS',phases(1)-phi(j)) ' and ' phase_pvs{2} ' to ' sprintf('%6.1f degS',phases(2)+phi(j))])
    lcaPut(phase_pvs,[phases(1)-phi(j); phases(2)+phi(j)]);     % set two phases for each step
    set(handles.TAKEDATA,'String',sprintf('point %2.0f...',j))
    drawnow
    if j==1
     pause(handles.waiti);
    else
      pause(handles.wait);
    end
    [X,Y,T,dX,dY,dT,iok] = read_BPMs(handles.all_BPM_pvs,handles.navg,handles.rate);
    handles.Xsa(j,:)  = X;
    handles.Ysa(j,:)  = Y;
    handles.Tsa(j,:)  = T;
    handles.dXsa(j,:)  = dX;
    handles.dYsa(j,:)  = dY;
    handles.dTsa(j,:)  = dT;
    handles.dE_E = handles.Xsa(:,1)/handles.etaX;
    handles.ddE_E = handles.dXsa(:,1)/handles.etaX;

    if ~any(iok)
      lcaPut(phase_pvs,phases);      % restore two phases after bad scan
      errordlg('No beam - restoring RF - quitting.','NO BEAM');
      set(handles.TAKEDATA,'String','NO BEAM...')
      drawnow
      pause(2)
      set(handles.TAKEDATA,'BackgroundColor','yellow')
      set(handles.TAKEDATA,'String','Scan Energy')
      set(handles.MESSAGE,'String','No beam - retry?')
      drawnow
      lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
      return
    end

    for n = 1:(handles.nbpms+1)
      if iok(n)==0
        lcaPut(phase_pvs,phases);      % restore two phases after bad scan
        errordlg(['No beam seen on ' handles.all_BPM_pvs{n,:}],'BAD BPM')
        set(handles.TAKEDATA,'String','Dead BPM...')
        drawnow
        pause(2)
        set(handles.TAKEDATA,'BackgroundColor','yellow')
        set(handles.TAKEDATA,'String','Scan Energy')
        set(handles.MESSAGE,'String',['No beam seen on ' handles.all_BPM_pvs{n,:}])
        drawnow
        lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
        return
      end
    end
  end
  lcaPut(phase_pvs,phases);         % restore two phases after scan

    case {4 5 6}    % if DL2, CLTS, or LTUS...
  if abs(X) > abs(handles.etaX*0.01E3)                 % if energy is more than 1% off initially...
    yne = questdlg('The beam energy is more than 1% off right now.  Do you really want to continue.','ENERGY NOT RIGHT');
    if ~strcmp(yne,'Yes')
      set(handles.TAKEDATA,'BackgroundColor','yellow')
      set(handles.TAKEDATA,'String','Scan Energy')
      set(handles.MESSAGE,'String','Energy is wrong.')
      drawnow
      return
    end
  end
  fdbkList=[fdbkList;{handles.abstrPV}];
  fdbkListOn=lcaGet(fdbkList,1,'double');           % get status of feedbacks
  lcaPut(fdbkList,0);pause(3.);                       % turn off feedbacks temporarily
  handles.dE_E0 = linspace(handles.min_dE_E,handles.max_dE_E,handles.nsamp);    % dE/E steps [ ]
  phase_pvs = {'ACCL:LI29:0:KLY_PDES'; ...
               'ACCL:LI30:0:KLY_PDES'};
  phases = lcaGetSmart(phase_pvs);
  numKlys=sum(bitand(control_klysStatGet(strcat({'29-'},num2str((1:8)'))),1));
  V0 = 220*numKlys;                                       % energy gain at crest per sub-booster (MeV)
  y = handles.dE_E0*handles.nom_E/V0 + cosd(phases(1)) + cosd(phases(2));
  a = cosd(phases(1)) + cosd(phases(2));
  b = sind(phases(2)) - sind(phases(1));
  phi = asind(y/sqrt(a^2+b^2)) - asind(a/sqrt(a^2+b^2));   % delta-phases to step through (deg)
  i1 = any(sign(phases(1))*(phases(1)+phi)<0 | sign(phases(1))*(phases(1)+phi)> 180);  % any phase settings out of range?
  i2 = any(sign(phases(2))*(phases(2)-phi)<0 | sign(phases(2))*(phases(2)-phi)> 180);  % ...
  if i1 || i2    % if RF phases are outside of range - quit.
    errordlg('The 29/30 sub-booster phases are too close to accel or decel crest to run this scan.','PHASES OUT OF RANGE')
    set(handles.TAKEDATA,'BackgroundColor','yellow')
    set(handles.TAKEDATA,'String','Scan Energy')
    set(handles.MESSAGE,'String','Phases are out of range')
    drawnow
    lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
    return
  end
  disp(['Initial phase of ' phase_pvs{1} ' = ' sprintf('%6.1f degS',phases(1)) ' and ' phase_pvs{2} ' = ' sprintf('%6.1f degS',phases(2))])
  for j = 1:handles.nsamp
    disp(['Setting ' phase_pvs{1} ' to ' sprintf('%6.1f degS',phases(1)-phi(j)) ' and ' phase_pvs{2} ' to ' sprintf('%6.1f degS',phases(2)+phi(j))])
    lcaPut(phase_pvs,[phases(1)-phi(j); phases(2)+phi(j)]);     % set two phases for each step
    set(handles.TAKEDATA,'String',sprintf('point %2.0f...',j))
    drawnow
    if j==1
      pause(handles.waiti);
    else
      pause(handles.wait);
    end
    [X,Y,T,dX,dY,dT,iok] = read_BPMs(handles.all_BPM_pvs,handles.navg,handles.rate);
    handles.Xsa(j,:)  = X;
    handles.Ysa(j,:)  = Y;
    handles.Tsa(j,:)  = T;
    handles.dXsa(j,:) = dX;
    handles.dYsa(j,:) = dY;
    handles.dTsa(j,:) = dT;
    handles.dE_E  = handles.Xsa(:,1)/handles.etaX;
    handles.ddE_E = handles.dXsa(:,1)/handles.etaX;

    if ~any(iok)
      lcaPut(phase_pvs,phases);      % restore two phases after bad scan
      errordlg('No beam - restoring RF - quitting.','NO BEAM');
      set(handles.TAKEDATA,'String','NO BEAM...')
      drawnow
      pause(2)
      set(handles.TAKEDATA,'BackgroundColor','yellow')
      set(handles.TAKEDATA,'String','Scan Energy')
      set(handles.MESSAGE,'String','No beam - retry?')
      drawnow
      lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
      return
    end

    for n = 1:(handles.nbpms+1)
      if iok(n)==0
        lcaPut(phase_pvs,phases);      % restore two phases after bad scan
        errordlg(['No beam seen on ' handles.all_BPM_pvs{n,:}],'BAD BPM')
        set(handles.TAKEDATA,'String','Dead BPM...')
        drawnow
        pause(2)
        set(handles.TAKEDATA,'BackgroundColor','yellow')
        set(handles.TAKEDATA,'String','Scan Energy')
        set(handles.MESSAGE,'String',['No beam seen on ' handles.all_BPM_pvs{n,:}])
        drawnow
        lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
        return
      end
    end
  end
  lcaPut(phase_pvs,phases);      % restore two phases after scan
end

lcaPut(fdbkList,fdbkListOn);            % restore feedbacks to their initial state (ON or OFF)
set(handles.TAKEDATA,'BackgroundColor','yellow')
set(handles.TAKEDATA,'String','Scan Energy')

if handles.useL1==1
  handles.dE_E  = handles.dE_E0*1000;
end

[handles.etax,handles.detax,handles.etay,handles.detay] = deal(zeros(handles.nbpms,1));
figure(2)
close
order = 1;
if handles.sec_order
  order = 2;
  [handles.etax2,handles.detax2,handles.etay2,handles.detay2] = deal(zeros(handles.nbpms,1));
end

for j = 1:handles.nbpms
  if any(handles.dXsa(:,j+1)==0)
    [q,dq,xf1,yf1] = plot_polyfit(handles.dE_E,handles.Xsa(:,j+1),1,order,'dE/E',[handles.BPM_pvs{j} ':X'],' ','mm',1);
  else
    [q,dq,xf1,yf1] = plot_polyfit(handles.dE_E,handles.Xsa(:,j+1),handles.dXsa(:,j+1),order,'dE/E',[handles.BPM_pvs{j} ':X'],' ','mm',1);
  end
  handles.etax(j)  = 1E3*q(2);
  handles.detax(j) = 1E3*dq(2);
  if handles.sec_order
    handles.etax2(j)  = 1E6*q(3);
    handles.detax2(j) = 1E6*dq(3);
  end
  if handles.showplots == 1
    figure(2)
    subplot(2,3,j);
    plot_bars(handles.dE_E/10,handles.Xsa(:,j+1),handles.dXsa(:,j+1),'o')
    hold on
    plot(xf1/10,yf1,'-')
    xlabel('\Delta{\itE}/{\itE}_0 (%)')
    ylabel([handles.BPM_pvs{j} ' {\itX} (mm)'])
    title(['{\it\eta_x}=' sprintf('%7.3f',handles.etax(j)) '\pm' sprintf('%6.3f',handles.detax(j)) ' mm'])
    axis tight
    v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
    axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
    enhance_plot('times',12)
    hold off
  end
end

if any(handles.ddE_E==0)
  [q0,dq0,xf0,yf0] = plot_polyfit(100*handles.dE_E0,handles.dE_E/10,1,1,'dE/E','dE/E','%','%',1);
else
  [q0,dq0,xf0,yf0] = plot_polyfit(100*handles.dE_E0,handles.dE_E/10,handles.ddE_E/10,1,'dE/E','dE/E','%','%',1);
end
handles.dE_E_slope = q0(2);

if handles.showplots == 1
  subplot(2,3,6);
  plot_bars(100*handles.dE_E0,handles.dE_E/10,handles.ddE_E/10,'sm')
  hold on
  plot(xf0,yf0,'-g')
  xlabel('Desired \Delta{\itE}/{\itE}_0 (%)')
  ylabel('Actual \Delta{\itE}/{\itE}_0 (%)')
  title(['slope = ' sprintf('%6.3f',q0(2)) '\pm' sprintf('%5.3f',dq0(2))])
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  enhance_plot('times',12)
  hold off
end
figure(3)
close
for j = 1:handles.nbpms
  if any(handles.dYsa(:,j+1)==0);
    [q,dq,xf1,yf1] = plot_polyfit(handles.dE_E,handles.Ysa(:,j+1),1,order,'dE/E',[handles.BPM_pvs{j} ':Y'],' ','mm',1);
  else
    [q,dq,xf1,yf1] = plot_polyfit(handles.dE_E,handles.Ysa(:,j+1),handles.dYsa(:,j+1),order,'dE/E',[handles.BPM_pvs{j} ':Y'],' ','mm',1);
  end
  handles.etay(j)  = 1E3*q(2);
  handles.detay(j) = 1E3*dq(2);
  if handles.sec_order
    handles.etay2(j)  = 1E6*q(3);
    handles.detay2(j) = 1E6*dq(3);
  end
  if handles.showplots==1
    figure(3)
    subplot(2,3,j);
    plot_bars(handles.dE_E/10,handles.Ysa(:,j+1),handles.dYsa(:,j+1),'o')
    hold on
    plot(xf1/10,yf1,'r-')
    xlabel('\Delta{\itE}/{\itE}_0 (%)')
    ylabel([handles.BPM_pvs{j} ' {\itY} (mm)'])
    title(['{\it\eta_y}=' sprintf('%7.3f',handles.etay(j)) '\pm' sprintf('%6.3f',handles.detay(j)) ' mm'])
    axis tight
    v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
    axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
    enhance_plot('times',12)
    hold off
  end
end

[handles.etaxf,handles.etayf,handles.eta0,handles.deta0,handles.chisq] = ...
    xy_traj_fit(handles.etax',handles.detax',handles.etay',handles.detay',0*handles.etax',0*handles.etay',handles.R1s,handles.R3s,[1 2 3 4 0]);
handles.eta0m = handles.eta0*1E-3;

if handles.sec_order
  [handles.etax2f,handles.etay2f,handles.eta20,handles.deta20,handles.chisq2] = ...
      xy_traj_fit(handles.etax2',handles.detax2',handles.etay2',handles.detay2',0*handles.etax2',0*handles.etay2',handles.R1s,handles.R3s,[1 2 3 4 0]);
  handles.eta20m = handles.eta20*1E-3;
end

if handles.area == 5
    K = -sign(handles.dE_E_slope)*handles.M*handles.eta0m(1:4)';   % dispersion quad k values to cancel this dispersion
    % NOTE: xy_traj_fit's third return is ordered as follows: x,x',y,y',dE/E
else
    K = -sign(handles.dE_E_slope)*handles.M*handles.eta0m(1:2)';   % dispersion quad k values to cancel this dispersion
end
handles.BDES = K.*handles.Leff'*33.356*handles.nom_E*1E-3;    % change to dispersion quads BDES to cancel this dispersion

ex0 = 0.5E-6/(handles.nom_E/511E-3);
ey0 = 0.5E-6/(handles.nom_E/511E-3);

ex_ex0 = sqrt(1 + handles.sigd^2*( (handles.eta0m(1)*handles.ax0 + handles.eta0m(2)*handles.bx0)^2 + handles.eta0m(1)^2 )/(handles.bx0*ex0));
ey_ey0 = sqrt(1 + handles.sigd^2*( (handles.eta0m(3)*handles.ay0 + handles.eta0m(4)*handles.by0)^2 + handles.eta0m(3)^2 )/(handles.by0*ey0));

if handles.sec_order
  ex_ex0_2 = sqrt(1 + 2*handles.sigd^4*( (handles.eta20m(1)*handles.ax0 + handles.eta20m(2)*handles.bx0)^2 + handles.eta20m(1)^2 )/(handles.bx0*ex0));
  ey_ey0_2 = sqrt(1 + 2*handles.sigd^4*( (handles.eta20m(3)*handles.ay0 + handles.eta20m(4)*handles.by0)^2 + handles.eta20m(3)^2 )/(handles.by0*ey0));
end

% Plot linear dispersion in x and y plus phase space plots:
figure(1)
subplot(2,2,1);
plot_bars(handles.Zs,handles.etax,handles.detax)
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
hold on
plot(handles.Zs,handles.etax,'--b',handles.Zs,handles.etaxf,'-g')
xlabel('{\itz} (m)')
ylabel('{\it\eta_x} (mm)')
hor_line(0)
ver_line(handles.Zs0)
if handles.area==1      % 'BC1'
  title(['CQ11 \DeltaB=' sprintf('%5.2f kG',handles.BDES(1)) ', CQ12 \DeltaB=' sprintf('%5.2f kG',handles.BDES(2))])
elseif handles.area==2  % 'DL1'
  title(['QB \DeltaB=' sprintf('%5.2f kG',handles.BDES(1))])
elseif handles.area==3  % 'BC2'
  title(['CQ21 \DeltaB=' sprintf('%5.2f kG',handles.BDES(1)) ', CQ22 \DeltaB=' sprintf('%5.2f kG',handles.BDES(2))])
elseif handles.area==4  % 'DL2'
  title(['CQ31 \DeltaB=' sprintf('%5.2f kG',handles.BDES(1)) ', CQ32 \DeltaB=' sprintf('%5.2f kG',handles.BDES(2))])
  
elseif handles.area==5  % 'CLTS'
  title(['QCUS1 \DeltaB=' sprintf('%5.2f kG',handles.BDES(1)) ', QCUS2 \DeltaB=' sprintf('%5.2f kG',handles.BDES(2)) ', QCUS3+8 \DeltaB=' sprintf('%5.2f kG',handles.BDES(3)) ', QCUS5+6 \DeltaB=' sprintf('%5.2f kG',handles.BDES(4))])
  
elseif handles.area==6  % 'LTUS'
  title(['QDL12,15,16,19 \DeltaB=' sprintf('%5.2f kG',handles.BDES(1)) ', QDL13,14,17,18 \DeltaB=' sprintf('%5.2f kG',handles.BDES(2))])
end
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
enhance_plot('times',12,2)
hold off

subplot(2,2,2);
X0 = 1E6*ex0*[handles.bx0 -handles.ax0; -handles.ax0 (1+handles.ax0^2)/handles.bx0];
X  = 1E6*handles.sigd^2*[handles.eta0m(1)^2 handles.eta0m(1)*handles.eta0m(2); handles.eta0m(1)*handles.eta0m(2) handles.eta0m(2)^2];
plot_ellipse(inv(X0),1,'b-')
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
hold on
plot_ellipse(inv(X0 + X),1,'r--')
plot_bars2(handles.sigd*handles.eta0(1),handles.sigd*handles.eta0(2),handles.sigd*handles.deta0(1),handles.sigd*handles.deta0(2),'.r')
hor_line(0)
ver_line(0)
xlabel('{\it x} (mm)')
ylabel('{\it x}^{\prime} (mrad)')
title(['{\it\eta_{x}}_0=' sprintf('%5.2f mm',handles.eta0(1)) ', {\it\eta_{x}}^{\prime}_0 =' sprintf('%5.2f mrad',handles.eta0(2)) ', {\it\epsilon_{x}/\epsilon_x}_0=' sprintf('%5.3f',ex_ex0)])
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
enhance_plot('times',12,2)
hold off

subplot(2,2,3);
plot_bars(handles.Zs,handles.etay,handles.detay)
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
hold on
plot(handles.Zs,handles.etay,'--r',handles.Zs,handles.etayf,'-m')
xlabel('{\itz} (m)')
ylabel('{\it\eta_y} (mm)')
hor_line(0)
ver_line(handles.Zs0)
str = cell2mat(handles.area_str(handles.area));
title([str ':  ' get_time])
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
enhance_plot('times',12,2)
hold off

subplot(2,2,4);
Y0 = 1E6*ey0*[handles.by0 -handles.ay0; -handles.ay0 (1+handles.ay0^2)/handles.by0];
Y  = 1E6*handles.sigd^2*[handles.eta0m(3)^2 handles.eta0m(3)*handles.eta0m(4); handles.eta0m(3)*handles.eta0m(4) handles.eta0m(4)^2];
plot_ellipse(inv(Y0),1,'g-')
axis tight
v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
hold on
plot_ellipse(inv(Y0 + Y),1,'c--')
plot_bars2(handles.sigd*handles.eta0(3),handles.sigd*handles.eta0(4),handles.sigd*handles.deta0(3),handles.sigd*handles.deta0(4),'.c')
hor_line(0)
ver_line(0)
xlabel('{\it y} (mm)')
ylabel('{\it y}^{\prime} (mrad)')
title(['{\it\eta_{y}}_0=' sprintf('%5.2f mm',handles.eta0(3)) ', {\it\eta_{y}}^{\prime}_0 =' sprintf('%5.2f mrad',handles.eta0(4)) ', {\it\epsilon_{y}/\epsilon_y}_0=' sprintf('%5.3f',ey_ey0)])
enhance_plot('times',12,2)
hold off

handles.exportFig=1; % print this one plot to log?

% Plot 2nd-order dispersion in x and y plus phase space plots:
if handles.sec_order
  figure(4)
  subplot(2,2,1);
  plot_bars(handles.Zs,handles.etax2,handles.detax2)
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  hold on
  plot(handles.Zs,handles.etax2,'--m',handles.Zs,handles.etax2f,'-c')
  xlabel('{\itz} (m)')
  ylabel('{\itT_{166}} (mm)')
  hor_line(0)
  ver_line(handles.Zs0)
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  enhance_plot('times',12,2)
  hold off

  subplot(2,2,2);
  X0 = 1E6*ex0*[handles.bx0 -handles.ax0; -handles.ax0 (1+handles.ax0^2)/handles.bx0];
  X  = 1E6*2*handles.sigd^4*[handles.eta20m(1)^2 handles.eta20m(1)*handles.eta20m(2); handles.eta20m(1)*handles.eta20m(2) handles.eta20m(2)^2];
  plot_ellipse(inv(X0),1,'m-')
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  hold on
  plot_ellipse(inv(X0 + X),1,'c--')
  plot_bars2(2*handles.sigd^2*handles.eta20(1),2*handles.sigd^2*handles.eta20(2),2*handles.sigd^2*handles.deta20(1),2*handles.sigd^2*handles.deta20(2),'.r')
  hor_line(0)
  ver_line(0)
  xlabel('{\it x} (mm)')
  ylabel('{\it x}^{\prime} (mrad)')
  title(['{\itT}_{166,}_0=' sprintf('%5.2f mm',handles.eta20(1)) ', {\itT}_{266,}_0 =' sprintf('%5.2f mrad',handles.eta20(2)) ', {\it\epsilon_{x}/\epsilon_x}_0=' sprintf('%5.3f',ex_ex0_2)])
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  enhance_plot('times',12,2)
  hold off

  subplot(2,2,3);
  plot_bars(handles.Zs,handles.etay2,handles.detay2)
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  hold on
  plot(handles.Zs,handles.etay2,'--r',handles.Zs,handles.etay2f,'-m')
  xlabel('{\itz} (m)')
  ylabel('{\itT}_{366} (mm)')
  hor_line(0)
  ver_line(handles.Zs0)
  str = cell2mat(handles.area_str(handles.area));
  title([str ':  ' get_time])
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  enhance_plot('times',12,2)
  hold off

  subplot(2,2,4);
  Y0 = 1E6*ey0*[handles.by0 -handles.ay0; -handles.ay0 (1+handles.ay0^2)/handles.by0];
  Y  = 1E6*2*handles.sigd^4*[handles.eta20m(3)^2 handles.eta20m(3)*handles.eta20m(4); handles.eta20m(3)*handles.eta20m(4) handles.eta20m(4)^2];
  plot_ellipse(inv(Y0),1,'b-')
  axis tight
  v = axis;dx=v(2)-v(1);dy=v(4)-v(3);
  axis([v(1)-dx/20 v(2)+dx/20 v(3)-dy/20 v(4)+dy/20])
  hold on
  plot_ellipse(inv(Y0 + Y),1,'k--')
  plot_bars2(2*handles.sigd^2*handles.eta20(3),2*handles.sigd^2*handles.eta20(4),2*handles.sigd^2*handles.deta20(3),2*handles.sigd^2*handles.deta20(4),'.c')
  hor_line(0)
  ver_line(0)
  xlabel('{\it y} (mm)')
  ylabel('{\it y}^{\prime} (mrad)')
  title(['{\itT}_{366,}_0=' sprintf('%5.2f mm',handles.eta20(3)) ', {\itT}_{466,}_0 =' sprintf('%5.2f mrad',handles.eta20(4)) ', {\it\epsilon_{y}/\epsilon_y}_0=' sprintf('%5.3f',ey_ey0_2)])
  enhance_plot('times',12,2)
  hold off
end

if handles.area == 1    % 'BC1'
  handles.BDES0 = control_magnetGet(handles.Qpv,'BDES');
  disp(sprintf('Change CQ11 & CQ12 BDES by: %6.3f and %6.3f kG',handles.BDES(1),handles.BDES(2)))
  set([handles.Q1BDES handles.Q2BDES],'Visible','on');
  set(handles.Q1BDES,'String',sprintf('CQ11 BDES:  %6.3f -> %6.3f kG',handles.BDES0(1),handles.BDES0(1)+handles.BDES(1)));
  set(handles.Q2BDES,'String',sprintf('CQ12 BDES:  %6.3f -> %6.3f kG',handles.BDES0(2),handles.BDES0(2)+handles.BDES(2)));
elseif handles.area == 2    % 'DL1'
  handles.BDES0 = control_magnetGet(handles.Qpv,'BDES');
  disp(sprintf('Change QB BDES by: %6.3f kG',handles.BDES(1)))
  set(handles.Q1BDES,'Visible','on');
  set(handles.Q1BDES,'String',sprintf('QB BDES:  %6.3f -> %6.3f kG',handles.BDES0(1),handles.BDES0(1)+handles.BDES(1)));
elseif handles.area == 3    % 'BC2'
  handles.BDES0 = control_magnetGet(handles.Qpv,'BDES');
  disp(sprintf('Change CQ21 & CQ22 BDES by: %6.3f and %6.3f kG',handles.BDES(1),handles.BDES(2)))
  set([handles.Q1BDES handles.Q2BDES],'Visible','on');
  set(handles.Q1BDES,'String',sprintf('CQ21 BDES:  %6.3f -> %6.3f kG',handles.BDES0(1),handles.BDES0(1)+handles.BDES(1)));
  set(handles.Q2BDES,'String',sprintf('CQ22 BDES:  %6.3f -> %6.3f kG',handles.BDES0(2),handles.BDES0(2)+handles.BDES(2)));
elseif handles.area == 4    % 'DL2'
  handles.BDES0 = control_magnetGet(handles.Qpv,'BDES');
  disp(sprintf('Change CQ31 & CQ32 BDES by: %6.3f and %6.3f kG',handles.BDES(1),handles.BDES(2)))
  set([handles.Q1BDES handles.Q2BDES],'Visible','on');
  set(handles.Q1BDES,'String',sprintf('CQ31 BDES:  %6.3f -> %6.3f kG',handles.BDES0(1),handles.BDES0(1)+handles.BDES(1)));
  set(handles.Q2BDES,'String',sprintf('CQ32 BDES:  %6.3f -> %6.3f kG',handles.BDES0(2),handles.BDES0(2)+handles.BDES(2)));
elseif handles.area == 5    % 'CLTS'
  handles.BDES0 = control_magnetGet(handles.Qpv,'BDES');
  disp(sprintf('Change QCUS1, QCUS2, QCUS3+8, and QCUS5+6 BDES by: %6.3f, %6.3f, %6.3f and %6.3f kG',handles.BDES(1),handles.BDES(2),handles.BDES(3),handles.BDES(4)))
  set([handles.Q1BDES handles.Q2BDES handles.Q3BDES handles.Q4BDES],'Visible','on');
  set(handles.Q1BDES,'String',sprintf('QCUS1 BDES:  %6.3f -> %6.3f kG',handles.BDES0(1),handles.BDES0(1)+handles.BDES(1)));
  set(handles.Q2BDES,'String',sprintf('QCUS2 BDES:  %6.3f -> %6.3f kG',handles.BDES0(2),handles.BDES0(2)+handles.BDES(2)));
  set(handles.Q2BDES,'String',sprintf('QCUS3 BDES:  %6.3f -> %6.3f kG',handles.BDES0(3),handles.BDES0(3)+handles.BDES(3)));
  set(handles.Q2BDES,'String',sprintf('QCUS5 BDES:  %6.3f -> %6.3f kG',handles.BDES0(4),handles.BDES0(4)+handles.BDES(4)));
elseif handles.area == 6    % 'LTUS'
  handles.BDES0 = control_magnetGet(handles.Qpv,'BDES');
  disp(sprintf('Change QDL12,15,16,19 & QDL13,14,17,18 BDES by: %6.3f and %6.3f kG',handles.BDES(1),handles.BDES(2)))
  set([handles.Q1BDES handles.Q2BDES],'Visible','on');
  set(handles.Q1BDES,'String',sprintf('QDL12 BDES:  %6.3f -> %6.3f kG',handles.BDES0(1),handles.BDES0(1)+handles.BDES(1)));
  set(handles.Q2BDES,'String',sprintf('QDL13 BDES:  %6.3f -> %6.3f kG',handles.BDES0(2),handles.BDES0(2)+handles.BDES(2)));
end
set(handles.CORRECT,'Visible','on');
drawnow
guidata(hObject, handles);


% --- Executes on button press in CORRECT.
function CORRECT_Callback(hObject, eventdata, handles)
set(handles.CORRECT,'Visible','off');
if handles.area == 1    % 'BC1'
  trim_magnet(handles.Qpv{1},handles.BDES0(1)+handles.BDES(1),'P');
  trim_magnet(handles.Qpv{2},handles.BDES0(2)+handles.BDES(2),'P');
elseif handles.area == 2    % 'DL1'
  trim_magnet(handles.Qpv{1},handles.BDES0(1)+handles.BDES(1),'P');
elseif handles.area == 3    % 'BC2'
  trim_magnet(handles.Qpv{1},handles.BDES0(1)+handles.BDES(1),'P');
  trim_magnet(handles.Qpv{2},handles.BDES0(2)+handles.BDES(2),'P');
elseif handles.area == 4    % 'DL2'
  trim_magnet(handles.Qpv{1},handles.BDES0(1)+handles.BDES(1),'P');
  trim_magnet(handles.Qpv{2},handles.BDES0(2)+handles.BDES(2),'P');
elseif handles.area == 5    % 'CLTS'
  trim_magnet(handles.Qpv{1},handles.BDES0(1)+handles.BDES(1),'P');
  trim_magnet(handles.Qpv{2},handles.BDES0(2)+handles.BDES(2),'P');
  trim_magnet(handles.Qpv{3},handles.BDES0(3)+handles.BDES(3),'P');
  trim_magnet(handles.Qpv{4},handles.BDES0(4)+handles.BDES(4),'P');
elseif handles.area == 6    % 'LTUS'
  trim_magnet(handles.Qpv{1},handles.BDES0(1)+handles.BDES(1),'P');
  trim_magnet(handles.Qpv{2},handles.BDES0(2)+handles.BDES(2),'P');
end
guidata(hObject, handles);

%====================================================================================
function NSAMP_Callback(hObject, eventdata, handles)
handles.nsamp = str2int(get(hObject,'String'));
handles = initialize(hObject,handles);
guidata(hObject, handles);


function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2int(get(hObject,'String'));
handles = initialize(hObject,handles);
guidata(hObject, handles);


function WAIT_Callback(hObject, eventdata, handles)
handles.wait = str2double(get(hObject,'String'));
handles = initialize(hObject,handles);
guidata(hObject, handles);


function WAITI_Callback(hObject, eventdata, handles)
handles.waiti = str2double(get(hObject,'String'));
handles = initialize(hObject,handles);
guidata(hObject, handles);


function MIN_ENERGY_Callback(hObject, eventdata, handles)
handles.min_dE_E = str2double(get(hObject,'String'))/100;
handles = initialize(hObject,handles);
guidata(hObject, handles);


function MAX_ENERGY_Callback(hObject, eventdata, handles)
handles.max_dE_E = str2double(get(hObject,'String'))/100;
handles = initialize(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in SHOWPLOTS.
function SHOWPLOTS_Callback(hObject, eventdata, handles)
handles.showplots = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in USEL1.
function USEL1_Callback(hObject, eventdata, handles)
handles.useL1 = get(hObject,'Value');
guidata(hObject, handles);


function USE_L1X_Callback(hObject, eventdata, handles)
handles.use_L1X = get(hObject,'Value');
if handles.use_L1X
  handles.dE_pv = {'L1X'};     % L1X
else
  handles.dE_pv = {'L1S'};     % L1S
end
guidata(hObject, handles);


function ORDER_Callback(hObject, eventdata, handles)
handles.sec_order = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)
if ~any(ishandle(handles.exportFig)), return, end
util_printLog(handles.exportFig,'title',['Dispersion ' handles.area_str{handles.area}]);


function AREA_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function NSAMP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function WAIT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function WAITI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MIN_ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function MAX_ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
