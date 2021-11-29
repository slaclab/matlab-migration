function varargout = BCH_chicane_control(varargin)
% BCH_CHICANE_CONTROL M-file for BCH_chicane_control.fig
%      BCH_CHICANE_CONTROL, by itself, creates a new BCH_CHICANE_CONTROL or
%      raises the existing
%      singleton*.
%
%      H = BCH_CHICANE_CONTROL returns the handle to a new BCH_CHICANE_CONTROL or the handle to
%      the existing singleton*.
%
%      BCH_CHICANE_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BCH_CHICANE_CONTROL.M with the given input arguments.
%
%      BCH_CHICANE_CONTROL('Property','Value',...) creates a new BCH_CHICANE_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BCH_chicane_control_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BCH_chicane_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help BCH_chicane_control

% Last Modified by GUIDE v2.5 17-Oct-2008 15:27:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BCH_chicane_control_OpeningFcn, ...
                   'gui_OutputFcn',  @BCH_chicane_control_OutputFcn, ...
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


% --- Executes just before BCH_chicane_control is made visible.
function BCH_chicane_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BCH_chicane_control (see VARARGIN)

% Choose default command line output for BCH_chicane_control
handles.output = hObject;

% Update handles structure
%handles.beamOffPV='MPS:IN20:1:SHUTTER_TCTL';
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
handles.Xmax = 40;        % max. Xpos (mm)
handles.Xmin =  0;        % min. Xpos (mm)
handles.Xnom = 35;        % nom. Xpos (mm)
handles.energy1max = 0.100;  % max. e- energy at QA01/02 (GeV)
handles.energy1min = 0.030;  % min. e- energy at QA01/02 (GeV)
handles.energy1nom = 0.064;  % nom. e- energy at QA01/02 (GeV)
handles.energy2max = 0.200;  % max. e- energy at chicane (GeV)
handles.energy2min = 0.050;  % min. e- energy at chicane (GeV)
handles.energy2nom = 0.135;  % nom. e- energy at chicane (GeV)
handles.fdbkList={'FBCK:INL0:1:ENABLE';'FBCK:INL1:1:ENABLE';'FBCK:IN20:TR01:MODE'};

set(handles.Dave,'CData',imread('DD.bmp'));

set(handles.XposSLIDER,'Max',handles.Xmax);
set(handles.XposSLIDER,'Min',handles.Xmin);
set(handles.XposSLIDER,'SliderStep',[0.5 5]/(handles.Xmax-handles.Xmin));
set(handles.XMAX,'String',handles.Xmax);
set(handles.XMIN,'String',handles.Xmin);

handles.X = handles.Xnom*1E-3;                  % default for BCH Xpos (mm -> m)
handles.energy1 = handles.energy1nom;           % default for QA01/02 energy (GeV)
handles.energy2 = handles.energy2nom;           % default for BCH energy (GeV)

BCH_pv = 'BEND:IN20:461';                       % BCH chicane main bend [kG-m]
bdes0  = lcaGetSmart([BCH_pv   ':BDES']);       % read initial BCH setting [kG-m]
bmin   = lcaGetSmart([BCH_pv   ':BMIN']);       % read BCH minimum setting [kG-m]
if abs(bdes0)<0.01                              % if chicane is OFF for all practical purposes...
  bnow = bdes0 - bmin;
  iw = write_message('Laser-Heater chicane is OFF','MESSAGE',handles);
else
  bnow = bdes0;
  iw = write_message('Laser-Heater chicane is ON','MESSAGE',handles);
end
[BDES,Xact] = BCH_adjust(0,bnow,handles.energy1,handles.energy2);


set(handles.ENERGY1,'String',handles.energy1);  % show QA01/02 energy (GeV)
set(handles.ENERGY2,'String',handles.energy2);  % show BCH energy (GeV)
set(handles.XDES,'String',Xact*1E3);            % show present Xpos (mm)
set(handles.XposSLIDER,'Value',Xact*1E3)        % show slider position correctly
guidata(hObject, handles);
act_trim = 0;                                   % is act_trim = 0: update, but DON'T send data to hardware on "calc_all" call below
calc_all(hObject,handles,act_trim)

% UIWAIT makes BCH_chicane_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BCH_chicane_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


function calc_all(hObject,handles,act_trim)

BCH_pv    = 'BEND:IN20:461';            % BCH chicane main bend [kG-m]
BXH1T_pv  = 'BTRM:IN20:451';            % BXH1 trim coil [main-coil Amperes]
BXH3T_pv  = 'BTRM:IN20:475';            % BXH3 trim coil [main-coil Amperes]
BXH4T_pv  = 'BTRM:IN20:481';            % BXH4 trim coil [main-coil Amperes]
phase_pv  = 'SIOC:SYS0:ML00:AO080';     % A0080 beam phase prior to BCH [deg-2856 MHz] (move PDES more neg. if X decreases)
QA01_pv   = 'QUAD:IN20:361';            % QA01 quad PV
QA02_pv   = 'QUAD:IN20:371';            % QA02 quad PV
QE01_pv   = 'QUAD:IN20:425';            % QE01 quad PV
QE02_pv   = 'QUAD:IN20:441';            % QE02 quad PV
QE03_pv   = 'QUAD:IN20:511';            % QE03 quad PV
QE04_pv   = 'QUAD:IN20:525';            % QE04 quad PV
OTRH1_pv  = 'OTRS:IN20:465:PNEUMATIC';  % OTRH1 IN/OUT status PV
OTRH2_pv  = 'OTRS:IN20:471:PNEUMATIC';  % OTRH2 IN/OUT status PV
handles.UND_pv = 'USEG:IN20:466';       % undulator gap control PV

%handles.gap    = lcaGetSmart([handles.UND_pv ':MOTR.RBV']);
%handles.gapDES = lcaGetSmart([handles.UND_pv ':MOTR.VAL']);
%handles.gapmin = lcaGetSmart([handles.UND_pv ':MOTR.LLM']);
%handles.gapmax = lcaGetSmart([handles.UND_pv ':MOTR.HLM']);
handles.gap    = 0;     % temporary until this undulator gap control PV works (10/16/08 - PE)
handles.gapDES = 0;
handles.gapmin = -30000;
handles.gapmax = 30000;

handles.bact = lcaGetSmart([BCH_pv   ':BACT']);
handles.X        = str2double(get(handles.XDES,'String'))/1E3;
handles.energy1  = str2double(get(handles.ENERGY1,'String'));
handles.energy2  = str2double(get(handles.ENERGY2,'String'));

gamma = handles.energy2/511E-6;
lambda_u = 5.4E-2;  % LH und. period [m]
%lambda_IR = lcaGetSmart('IR wavelength PV in m');
lambda_IR = 758E-9;     % temporary until OP_GUI PV is available (10/16/08 - PE) [m]
handles.K = sqrt(2*(2*gamma^2*lambda_IR/lambda_u - 1));

[BDES,Xact,dphi] = BCH_adjust(handles.X,0,handles.energy1,handles.energy2);
[BDES,Xact,d,theta,eta,eta0,r56,r560] = BCH_adjust(handles.X,handles.bact,handles.energy1,handles.energy2);

%   OUTPUTS:    BDES(1):    The main supply BDES - absolute BDES (kG-m)
%               BDES(2):    The BXH1 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(3):    The BXH3 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(4):    The BXH4 BTRM BDES - absolute BDES (in main-coil Amperes)
%               BDES(5):    The QA01 delta-BDES (to change frpm X0 to X) - adds to BDES (kG)
%               BDES(6):    The QA02 delta-BDES (to change frpm X0 to X) - adds to BDES (kG)
%               BDES(7):    The QE01 delta-BDES (to change frpm X0 to X) - adds to BDES (kG)
%               BDES(8):    The QE02 delta-BDES (to change frpm X0 to X) - adds to BDES (kG)
%               BDES(9):    The QE03 delta-BDES (to change frpm X0 to X) - adds to BDES (kG)
%               BDES(10):   The QE04 delta-BDES (to change frpm X0 to X) - adds to BDES (kG)

handles.qa01bdes   = lcaGetSmart([QA01_pv   ':BDES']);   % read present quad BDES values (kG-m)
handles.qa02bdes   = lcaGetSmart([QA02_pv   ':BDES']);
handles.qe01bdes   = lcaGetSmart([QE01_pv   ':BDES']);
handles.qe02bdes   = lcaGetSmart([QE02_pv   ':BDES']);
handles.qe03bdes   = lcaGetSmart([QE03_pv   ':BDES']);
handles.qe04bdes   = lcaGetSmart([QE04_pv   ':BDES']);
handles.otrh1      = lcaGetSmart(OTRH1_pv,0,'double');   % =1 if OTR is IN beam (otherwise =0)
handles.otrh2      = lcaGetSmart(OTRH2_pv,0,'double');   % =1 if OTR is IN beam (otherwise =0)

%phi0 = lcaGetSmart(phase_pv);                        % read Joe's initial phase first ? (degS)
%phi  = phi0 + dphi;                             % add dphi to Joe's present phase (degS)
phi  = dphi;                             % add dphi to Joe's present phase (degS)

if act_trim
%  fdbkStat = lcaGetSmart(handles.fdbkList,0,'double'); % check if feedback is ON

% Close Pockels cell shutter:
  iw = write_message('Beam OFF - working - please wait...','MESSAGE',handles);
  shutter_open = lcaGetSmart(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of Pockels cell shutter
  lcaPut(handles.beamOffPV,0);                              % turn off beam at Pockels cell shutter

% shift injector RF_ref_phase and its tolerances:
  iw = write_message(sprintf('Beam OFF - adjusting upstream phases by %5.1f deg',dphi),'MESSAGE',handles);
  lcaPut(phase_pv,phi);                 % act_trim (set PDES + dPDES) for pre-BCH beam phases (laswer, L0a, L0b - done by Joe's phase_control script)

% set BCH to new currents:
  if abs(BDES(1)) < abs(handles.bact)   % if reducing main supply setting...
    BMAX = lcaGetSmart([BCH_pv   ':BDES.HOPR']);

    iw = write_message('Beam OFF - trimming BCH main supply to BMAX for STDZ','MESSAGE',handles);
    trim_magnet(BCH_pv,BMAX,'T');       % set BCH main supply to max for 10 sec    

    iw = write_message('Beam OFF - pause for 10 sec at BMAX for STDZ','MESSAGE',handles);
    pause(10)

    iw = write_message('Beam OFF - trimming BCH main supply to zero for STDZ','MESSAGE',handles);
    trim_magnet(BCH_pv,0,'T');          % set BCH supply to zero
    
    if BDES(1) <= 0                         % if setting chicane completely OFF...
      iw = write_message('Beam OFF - DAC-zeroing BCH main supply','MESSAGE',handles);
      lcaPut([BCH_pv ':CTRL'],'DAC_ZERO');  % DAC zero
      pause(5)
      iw = write_message('Beam OFF - copying BACT to BDES for BCH chicane','MESSAGE',handles);
      bact = lcaGetSmart([BCH_pv   ':BACT']);    % set BDES to BACT
      lcaPut([BCH_pv ':BDES'],bact);
    else                                    % if setting chicane to  low value, but not OFF...
      pause(5)
    end
  end
  if BDES(1) > 0                            % if BDES of chicane is not exactly zero (i.e., OFF)...
    iw = write_message(sprintf('Beam OFF - trimming BCH BDES to %7.4f kG-m',BDES(1)),'MESSAGE',handles);
    trim_magnet(BCH_pv,BDES(1),'T');        % act & trim BCH to non-zero BDES value, if not to be left OFF
  end

  iw = write_message('Beam OFF - setting 6 quad supplies to BMIN for STDZ','MESSAGE',handles);
  pvs = {[QA01_pv ':BMIN']; [QA02_pv ':BMIN']; [QE01_pv ':BMIN']; [QE02_pv ':BMIN']; [QE03_pv ':BMIN']; [QE04_pv ':BMIN']};
  BMIN =lcaGet(pvs);
  pvs = {QA01_pv; QA02_pv; QE01_pv; QE02_pv; QE03_pv; QE04_pv};
  trim_magnet(pvs,BMIN,'T');           % act & trim 6 quads to BMIN for STDZ
  pause(2)

  iw = write_message('Beam OFF - setting BCH trim & quad supplies to new settings','MESSAGE',handles);
  pvs = {BXH1T_pv; BXH3T_pv; BXH4T_pv; QA01_pv; QA02_pv; QE01_pv; QE02_pv; QE03_pv; QE04_pv};
  BDESt = [BDES(2:4) BDES(5)+handles.qa01bdes BDES(6)+handles.qa02bdes BDES(7)+handles.qe01bdes BDES(8)+handles.qe02bdes BDES(9)+handles.qe03bdes BDES(10)+handles.qe04bdes];
  trim_magnet(pvs,BDESt,'T');           % act & trim 3 BTRMs + 6 quads
  if BDES(1) <= 0                       % if BCH being switched off...
    lcaPut(handles.fdbkList,0);         % turn off feedback
    iw = write_message('BCH OFF, so launch feedback disabled','MESSAGE',handles);
  end
  pause(2)
  iw = write_message('All finished - Pockels cell shutter restored','MESSAGE',handles);
  lcaPut(handles.beamOffPV,shutter_open);       % restore state of Pockels cell shutter
end

handles.btrm1act   = lcaGetSmart([BXH1T_pv  ':BACT']);   % read present BTRM BACTs...
handles.btrm3act   = lcaGetSmart([BXH3T_pv  ':BACT']);
handles.btrm4act   = lcaGetSmart([BXH4T_pv  ':BACT']);
handles.qa01bact   = lcaGetSmart([QA01_pv   ':BACT']);   % read present quad BACTs...
handles.qa02bact   = lcaGetSmart([QA02_pv   ':BACT']);
handles.qe01bact   = lcaGetSmart([QE01_pv   ':BACT']);
handles.qe02bact   = lcaGetSmart([QE02_pv   ':BACT']);
handles.qe03bact   = lcaGetSmart([QE03_pv   ':BACT']);
handles.qe04bact   = lcaGetSmart([QE04_pv   ':BACT']);

str = sprintf('%5.2f',r56*1E3);
set(handles.R56NEW,'String',str);
str = sprintf('%5.2f',r560*1E3);
set(handles.R56ACT,'String',str);
str = sprintf('%5.2f',r56*1E3 - 6.32);  % 6.32 mm is the constant R56 of DL1 (opposit sign of chicane)
set(handles.R56TNEW,'String',str);
str = sprintf('%5.2f',r560*1E3 - 6.32); % 6.32 mm is the constant R56 of DL1 (opposit sign of chicane)
set(handles.R56TACT,'String',str);
str = sprintf('%5.3f',handles.gap/1E3);
set(handles.UNDGAP_ACT,'String',str);
str = sprintf('%5.3f',handles.gapDES/1E3);
set(handles.UNDGAP_DES,'String',str);
str = sprintf('%5.2f',eta*1E3);
set(handles.ETAXNEW,'String',str);
str = sprintf('%5.2f',eta0*1E3);
set(handles.ETAXACT,'String',str);
str = sprintf('%6.4f',handles.bact);
set(handles.BACT,'String',str);
str = sprintf('%6.4f',BDES(1));
set(handles.BDES,'String',str);
str = sprintf('%6.3f',BDES(2));
set(handles.BTRM1,'String',str);
str = sprintf('%6.3f',BDES(3));
set(handles.BTRM3,'String',str);
str = sprintf('%6.3f',BDES(4));
set(handles.BTRM4,'String',str);
str = sprintf('%6.3f',handles.btrm1act);
set(handles.BTRM1ACT,'String',str);
str = sprintf('%6.3f',handles.btrm3act);
set(handles.BTRM3ACT,'String',str);
str = sprintf('%6.3f',handles.btrm4act);
set(handles.BTRM4ACT,'String',str);
str = sprintf('%7.1f',dphi);
set(handles.PHASE,'String',str);
str = sprintf('%5.1f',handles.X*1E3);
set(handles.XDES,'String',str);
str = sprintf('%5.3f',handles.K);
set(handles.K_VALUE,'String',str)

str = sprintf('%6.3f',handles.qa01bact);
set(handles.QA01,'String',str);
str = sprintf('%6.3f',handles.qa02bact);
set(handles.QA02,'String',str);
str = sprintf('%6.3f',handles.qe01bact);
set(handles.QE01,'String',str);
str = sprintf('%6.3f',handles.qe02bact);
set(handles.QE02,'String',str);
str = sprintf('%6.3f',handles.qe03bact);
set(handles.QE03,'String',str);
str = sprintf('%6.3f',handles.qe04bact);
set(handles.QE04,'String',str);

if handles.otrh1==0
  set(handles.OTRH1OUT,'Visible','on')
  set(handles.OTRH1IN ,'Visible','off')
else
  set(handles.OTRH1OUT,'Visible','off')
  set(handles.OTRH1IN ,'Visible','on')
end
if handles.otrh2==0
  set(handles.OTRH2OUT,'Visible','on')
  set(handles.OTRH2IN ,'Visible','off')
else
  set(handles.OTRH2OUT,'Visible','off')
  set(handles.OTRH2IN ,'Visible','on')
end

str = sprintf('%6.3f',handles.qa01bdes+BDES(5));
set(handles.QA01NEW,'String',str);
str = sprintf('%6.3f',handles.qa02bdes+BDES(6));
set(handles.QA02NEW,'String',str);
str = sprintf('%6.3f',handles.qe01bdes+BDES(7));
set(handles.QE01NEW,'String',str);
str = sprintf('%6.3f',handles.qe02bdes+BDES(8));
set(handles.QE02NEW,'String',str);
str = sprintf('%6.3f',handles.qe03bdes+BDES(9));
set(handles.QE03NEW,'String',str);
str = sprintf('%6.3f',handles.qe04bdes+BDES(10));
set(handles.QE04NEW,'String',str);
set(handles.DATE,'String',get_time)
drawnow
guidata(hObject, handles);


function BTRM1_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BTRM1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BTRM3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BTRM4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function XposSLIDER_Callback(hObject, eventdata, handles)
handles.X = get(hObject,'Value')/1E3;
set(handles.XDES,'String',handles.X*1E3);
guidata(hObject, handles);
act_trim = 0;
calc_all(hObject,handles,act_trim)

% --- Executes during object creation, after setting all properties.
function XposSLIDER_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function XDES_Callback(hObject, eventdata, handles)
handles.X = str2double(get(hObject,'String'))/1E3;
if (handles.X*1E3>handles.Xmax)
  errordlg(sprintf('Xpos must be <= %5.2f mm',handles.Xmax),'Error');
  set(handles.XDES,'String',handles.Xmax);
  handles.X = handles.Xmax/1E3;
end
if (handles.X*1E3<handles.Xmin)
  errordlg(sprintf('Xpos must be >= %5.2f mm',handles.Xmin),'Error');
  set(handles.XDES,'String',handles.Xmin);
  handles.X = handles.Xmin/1E3;
end
set(handles.XposSLIDER,'Value',handles.X*1E3)
act_trim = 0;
calc_all(hObject,handles,act_trim)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function XDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHASE_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ENERGY2_Callback(hObject, eventdata, handles)
handles.energy2 = str2double(get(hObject,'String'));
if (handles.energy2<handles.energy2min)
  errordlg(sprintf('BCH energy must be >= %5.3f GeV',handles.energy2min),'Error');
  set(handles.ENERGY2,'String',handles.energy2min);
  handles.energy2 = handles.energy2min;
end
if (handles.energy2>handles.energy2max)
  errordlg(sprintf('BCH energy must be <= %5.3f GeV',handles.energy2max),'Error');
  set(handles.ENERGY2,'String',handles.energy2max);
  handles.energy2 = handles.energy2max;
end
act_trim = 0;
calc_all(hObject,handles,act_trim)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ENERGY2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ENERGY1_Callback(hObject, eventdata, handles)
handles.energy1 = str2double(get(hObject,'String'));
if (handles.energy1<handles.energy1min)
  errordlg(sprintf('QA01/02 energy must be >= %5.3f GeV',handles.energy1min),'Error');
  set(handles.ENERGY1,'String',handles.energy1min);
  handles.energy1 = handles.energy1min;
end
if (handles.energy1>handles.energy1max)
  errordlg(sprintf('QA01/02 energy must be <= %5.3f GeV',handles.energy1max),'Error');
  set(handles.ENERGY1,'String',handles.energy1max);
  handles.energy1 = handles.energy1max;
end
act_trim = 0;
calc_all(hObject,handles,act_trim)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ENERGY1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1ACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BTRM1ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3ACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BTRM3ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4ACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function BTRM4ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UPDATE.
function UPDATE_Callback(hObject, eventdata, handles)
iw = write_message('Parameters now updated','MESSAGE',handles);
act_trim  = 0;
calc_all(hObject,handles,act_trim)


% --- Executes on button press in ACT_TRIM.
function ACT_TRIM_Callback(hObject, eventdata, handles)
yn = questdlg('This will put the Pockels cell shutter IN, change the BCH chicane and nearby quadrupole magnet settings, change the injector phase, and then open the Pockels cell shutter when done.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
  return
end
act_trim  = 1;
calc_all(hObject,handles,act_trim)


function QA01_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QA01_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QA01NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QA01NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QA02_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QA02_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QA02NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QA02NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE01_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE01_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE01NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE01NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE02_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE02_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE02NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE02NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE03_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE03_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE03NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE03NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE04_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE04_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE04NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function QE04NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BCHOFF.
function BCHOFF_Callback(hObject, eventdata, handles)
yn = questdlg('Caution, this will temporaily switch off beam and turn off the BCH chicane.  Do you really want to do this?','CAUTION');
if ~strcmp(yn,'Yes');
  return
end
handles.X = 0;
set(handles.XposSLIDER,'Value',handles.X*1E3)
set(handles.XDES,'String',handles.X*1E3)
act_trim  = 1;
calc_all(hObject,handles,act_trim)
guidata(hObject, handles);


% --- Executes on button press in BCHON.
function BCHON_Callback(hObject, eventdata, handles)
yn = questdlg('Caution, this will turn ON the BCH chicane to its nominal settings.  Do you really want to do this?','CAUTION');
if ~strcmp(yn,'Yes');
  return
end
handles.X = handles.Xnom*1E-3;   % nominal value for BCH Xpos (mm -> m)
set(handles.XposSLIDER,'Value',handles.X*1E3)
set(handles.XDES,'String',handles.X*1E3);
act_trim  = 1;
calc_all(hObject,handles,act_trim)
guidata(hObject, handles);


function ETAXACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function ETAXACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56ACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function R56ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ETAXNEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function ETAXNEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56NEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function R56NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56TACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function R56TACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56TNEW_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function R56TNEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function UNDGAP_ACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','output only')

% --- Executes during object creation, after setting all properties.
function UNDGAP_ACT_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function UNDGAP_DES_Callback(hObject, eventdata, handles)
yn = questdlg('This will change the heater-undulator gap.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
  act_trim = 0;
  calc_all(hObject,handles,act_trim)
  guidata(hObject, handles);
  return
end
handles.gapDES = str2double(get(hObject,'String'))*1E3;
if (handles.gapDES>handles.gapmax)
  errordlg(sprintf('gap must be <= %5.3f mm',handles.gapmax/1E3),'Error');
  handles.gapDES = handles.gapmax;
end
if (handles.gapDES<handles.gapmin)
  errordlg(sprintf('gap must be >= %5.3f mm',handles.gapmin/1E3),'Error');
  handles.gapDES = handles.gapmin;
end
%lcaPut([handles.UND_pv ':MOTR.VAL'],handles.gapDES)
act_trim = 0;
calc_all(hObject,handles,act_trim)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function UNDGAP_DES_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Dave.
function Dave_Callback(hObject, eventdata, handles)


% --- Executes on button press in SHOWDAVE.
function SHOWDAVE_Callback(hObject, eventdata, handles)
x = get(hObject,'Value');
if x ==1
  set(handles.Dave,'Visible','on')
else
  set(handles.Dave,'Visible','off')
end


% --- Executes on button press in SET_K.
function SET_K_Callback(hObject, eventdata, handles)
yn = questdlg('This will change the heater-undulator gap.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
  set(handles.SET_K,'Value',0);
  return
end
set(handles.K_VALUE,'String','...')
drawnow
pause(1)    % temporary
%gap = f(K) ???
%lcaPut([handles.UND_pv ':MOTR.VAL'],handles.gapDES)
act_trim = 0;
calc_all(hObject,handles,act_trim)
set(handles.SET_K,'Value',0);
drawnow
guidata(hObject, handles);


