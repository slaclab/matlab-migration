function varargout = slotted_foil_control(varargin)
% SLOTTED_FOIL_CONTROL M-file for slotted_foil_control.fig
%      SLOTTED_FOIL_CONTROL, by itself, creates a new SLOTTED_FOIL_CONTROL
%      or raises the existing
%      singleton*.
%
%      H = SLOTTED_FOIL_CONTROL returns the handle to a new SLOTTED_FOIL_CONTROL or the handle to
%      the existing singleton*.
%
%      SLOTTED_FOIL_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLOTTED_FOIL_CONTROL.M with the given input arguments.
%
%      SLOTTED_FOIL_CONTROL('Property','Value',...) creates a new SLOTTED_FOIL_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before slotted_foil_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to slotted_foil_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help slotted_foil_control

% Last Modified by GUIDE v2.5 30-Jul-2021 15:34:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @slotted_foil_control_OpeningFcn, ...
                   'gui_OutputFcn',  @slotted_foil_control_OutputFcn, ...
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


% --- Executes just before slotted_foil_control is made visible.
function slotted_foil_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to slotted_foil_control (see VARARGIN)

% Choose default command line output for slotted_foil_control
handles.output = hObject;

% handles.bc2_Ipk_pv    = 'SIOC:SYS0:ML00:AO044';   % Matlab BC2 pkCurr OLD
handles.bc2_Ipk_pv    = 'FBCK:FB04:LG01:S5DES';     % A
handles.lh_energy_pv  = 'LASR:IN20:475:PWR1H';      % uJ
%handles.emitx_pv      = 'OTRS:IN20:571:EMITN_X';  % OTR emittance
handles.emitx_pv      = 'WIRE:IN20:561:EMITN_X';    % um
%handles.emity_pv      = 'OTRS:IN20:571:EMITN_Y';  % OTR emittance
handles.emity_pv      = 'WIRE:IN20:561:EMITN_Y';    % um
handles.bc2r56_pv     = 'SIOC:SYS0:ML00:AO119';     % mm
handles.bc2_energy_pv = 'SIOC:SYS0:ML00:AO124';     % GeV
% handles.bc1_Ipk_pv    = 'SIOC:SYS0:ML00:AO016';   % Matlab BC1 pkCurr OLD
handles.bc1_Ipk_pv    = 'FBCK:FB04:LG01:S3DES';     % A
handles.charge_pv = bc1_chargeName;         % nC
handles.bc2_bdes_pv   = 'BEND:LI24:790:BDES';       % kG-m
handles.lh_shutter_pv = 'MPS:IN20:200:LHSHT1_OUT_MPS';
tcav0_init = 550; % um
set(handles.TCAV0_BUNCH_LENGTH,'string',num2str(tcav0_init));

handles.devList={'FOIL:LI24:804' 'FOIL:LI24:807'};
handles.devID=1;
set(handles.device_pmu,'String',handles.devList,'Value',handles.devID);

% New slotted foil 11/1/2011.
foilPar(1).ySep = [11800 19900 28000 32100 36200 Inf];     % Separation lines [um]

foilPar(1).yLow = [2800 12800 20900 29000 33100 37200]; % Slot low position [um]
foilPar(1).yHigh = [10800 18900 27000 31100 35200 39200]; % Slot high position [um]

foilPar(1).xLow = [110 450 515 140 135 150]; % Lower outer edge[um]
foilPar(1).xHigh = [790 900 965 235 255 255]; % Upper outer edge[um]
foilPar(1).xWidth = [0 300 430 0 0 0]; % Width of slot

foilPar(1).xNum = [1 1 1 8 6 4]; % Number of slits or slot pairs
foilPar(1).xSep = [0 0 0 1200 1700 2400]; % Separation between slot centers
foilPar(1).xOff = [0 0 0 0 0 0]; % Horizontal slot offset

foilPar(1).areaStr = {'single-slot' 'thin double-slot' 'thick double-slot' ...
    '8-slot' '6-slot' '4-slot'};

% Second slotted foil 1/21/2016  (by FJD).
foilPar(2).ySep = [10000 25500  Inf];     % Separation lines [um]

foilPar(2).yLow  = [3117 11120 27103 ]+00; % Slot  low position [um]
foilPar(2).yHigh = [8147 24145 35165 ]+00; % Slot high position [um]

foilPar(2).xLow  = [ 69  755-131 -2467+10000 ]; % Lower outer edge[um]
foilPar(2).xHigh = [209 4000-131  6546+10000 ]; % Upper outer edge[um]
foilPar(2).xWidth = [0 262 4070]; % Width of slot

foilPar(2).xNum = [1 1 1 ]; % Number of slits or slot pairs
foilPar(2).xSep = [0 0 0 ]; % Separation between slot centers
foilPar(2).xOff = -[0 0 10000 ]; % Horizontal slot offset (foil installed reversed)

foilPar(2).areaStr = {'single thin slot' 'thick double-slot' 'parallelogram slot'};

handles.foilPar=foilPar;
%{
% OLD Second slotted foil 1/28/2015.
foilPar(2).ySep = [15500 27500 30500 Inf];     % Separation lines [um]

foilPar(2).yLow = [3000 16000 29000 31000]+100; % Slot low position [um]
foilPar(2).yHigh = [13000 26000 30000 32000]+100; % Slot high position [um]

foilPar(2).xLow = [800 675 1510 1515]; % Lower outer edge[um]
foilPar(2).xHigh = [2800 2675 1510 1515]; % Upper outer edge[um]
foilPar(2).xWidth = [600 350 0 0]; % Width of slot

foilPar(2).xNum = [1 1 1 1]; % Number of slits or slot pairs
foilPar(2).xSep = [0 0 0 0]; % Separation between slot centers
foilPar(2).xOff = -[0 0 1420 -1600]; % Horizontal slot offset (foil installed reversed)

foilPar(2).areaStr = {'thick double-slot' 'thin double-slot' 'right slot' 'left slot'};

handles.foilPar=foilPar;
%}

%{
% Old slotted foil
handles.ySep = [16000 29000 Inf];     % Separation lines [um]
handles.yLow = [3980 17980 30980]; % Slot low position [um]
handles.yHigh = [13980 26980 39980]; % Slot high position [um]

handles.xLow = [110 410 350]; % Lower outer edge[um]
handles.xHigh = [1100 1090 1030]; % Upper outer edge[um]
handles.xWidth = [0 250 120]; % Width of slot

handles.xNum = [1 1 1]; % Number of slits or slot pairs
handles.xSep = [0 0 0 ]; % Separation between slot centers

handles.areaStr = {'single-slot' '1st double-slot' '2nd double-slot'};
%}

%{
% Old slot definitions.
handles.ya  = 16000;        % separation line: single-slot area below this [um]
handles.yb  = 29000;        % separation line: first double-slot area below this & 2nd double-slot area above this [um]

handles.x1 =   110;         % lower hor. edge of single slot [um]
handles.x2 =  1100;         % upper hor. edge of single slot [um]
handles.y1 =  3980;         % lower ver. edge of single slot [um]
handles.y2 = 13980;         % upper ver. edge of single slot [um]

handles.xa1 =   410;        % lower-outer hor. edge of 1st double slot [um]
handles.xa2 =  1090;        % upper-outer hor. edge of 1st double slot [um]
handles.ya1 = 17980;        % lower ver. edge of 1st double slot [um]
handles.ya2 = 26980;        % upper ver. edge of 1st double slot [um]
handles.xaw = handles.xa1 - 160;    % hor. width of 1st double slot [um]

handles.xb1 =   350;        % lower-outer hor. edge of 2nd double slot [um]
handles.xb2 =  1030;        % upper-outer hor. edge of 2nd double slot [um]
handles.yb1 = 30980;        % lower ver. edge of 2nd double slot [um]
handles.yb2 = 39980;        % upper ver. edge of 2nd double slot [um]
handles.xbw = handles.xb1 - 230;    % hor. width of 2nd double slot [um]
%}

deviceControl(hObject,handles,[]);

% UIWAIT makes slotted_foil_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = slotted_foil_control_OutputFcn(hObject, eventdata, handles) 
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
function deviceControl(hObject, handles, num)

if isempty(num)
    num=handles.devID;
end
handles.devID=num;

handles.devName       = handles.devList{num};
handles.motor_pv      = strcat(handles.devName,':MOTR');       % um
handles.lvdt_pv       = strcat(handles.devName,':LVPOS');      % um
handles.foil_out_pv   = strcat(handles.devName,':MOTRHI.PROC');% -
if strcmp(handles.devName,'FOIL:LI24:807')
    set(handles.BC2BETA,'visible','on')
else
    set(handles.BC2BETA,'visible','off')
end

for tag=fieldnames(handles.foilPar)'
    handles.(tag{:})=handles.foilPar(num).(tag{:});
end
guidata(hObject, handles);
UPDATE_Callback(hObject,[],handles);


function Y0_Callback(hObject, eventdata, handles)
handles.y0 = str2double(get(handles.Y0,'string'));          % um
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function Y0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BC2_IPK_Callback(hObject, eventdata, handles)
handles.bc2_Ipk = str2double(get(handles.BC2_IPK,'string'));          % A
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function BC2_IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LH_ENERGY_Callback(hObject, eventdata, handles)
handles.lh_energy = str2double(get(handles.LH_ENERGY,'string'));          % keV
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function LH_ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EMITX_Callback(hObject, eventdata, handles)
handles.emitx = str2double(get(handles.EMITX,'string'));          % um
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function EMITX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BETAX_FOIL_Callback(hObject, eventdata, handles)
handles.betax_foil = str2double(get(handles.BETAX_FOIL,'string'));          % m
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function BETAX_FOIL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETAX_FOIL_Callback(hObject, eventdata, handles)
handles.etax_foil = str2double(get(handles.ETAX_FOIL,'string'));          % mm
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function ETAX_FOIL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ESPRD_Callback(hObject, eventdata, handles)
handles.esprd = str2double(get(handles.ESPRD,'string'));          % keV
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function ESPRD_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BC2R56_Callback(hObject, eventdata, handles)
handles.bc2r56 = str2double(get(handles.BC2R56,'string'));          % mm
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function BC2R56_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BC2_ENERGY_Callback(hObject, eventdata, handles)
handles.bc2_energy = str2double(get(handles.BC2_ENERGY,'string'));          % GeV
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function BC2_ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BC1_IPK_Callback(hObject, eventdata, handles)
handles.bc1_Ipk = str2double(get(handles.BC1_IPK,'string'));          % A
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function BC1_IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CHARGE_Callback(hObject, eventdata, handles)
handles.charge = str2double(get(handles.CHARGE,'string'));          % nC
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function CHARGE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TCAV0_BUNCH_LENGTH_Callback(hObject, eventdata, handles)
handles.tcav0_bunch_length = str2double(get(handles.TCAV0_BUNCH_LENGTH,'string'));          % um
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function TCAV0_BUNCH_LENGTH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MOTOR_Callback(hObject, eventdata, handles)
handles.motor = str2double(get(hObject,'string'));
calc(hObject, eventdata, handles)
guidata(hObject, handles);

function MOTOR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function calc(hObject, eventdata, handles)
c     = 2.99792458E8;                       % m/s
Q     = handles.charge*1E-9;                % nC -> C
E     = handles.bc2_energy;                 % BC2 energy [GeV]
eta   = handles.etax_foil*1E-3;             % mm -> m
beta  = handles.betax_foil;                 % m
emitg = handles.emitx*1E-6/(E/511E-6);      % um -> m
Ipk2  = handles.bc2_Ipk;                    % BC2 peak current [A]
Ipk1  = handles.bc1_Ipk;                    % BC1 peak current [A]
Ipk0  = 1E6*Q*c/sqrt(10)/handles.tcav0_bunch_length;    % peak current in the injector [A]
C     = Ipk1/Ipk0;                          % compression factor to before BC2 [ ]
R56   = handles.bc2r56*1E-3;                % BC2 R56 [mm -> m]
leff  = 0.54;                               % BC2 bend length [m]
ang   = handles.bc2_bdes/33.356/E;          % BC2 bend angle per magnet [rad]
sdlh  = C*7.5*sqrt(handles.lh_energy)/E/1E6*handles.lh_shutter; % heater's relative rms slice energy spread [ ]
sds   = C*handles.esprd/E/1E6;              % add gun slice energy spread (no update) [ ]
sdisr = synch_esprd(E,ang,leff)/sqrt(2);    % rel. ISR esprd for first BC2 bend [ ]
sd0   = sqrt(sdlh^2 + sds^2 + sdisr^2);
sz2   = Q*c/sqrt(12)/abs(Ipk2);             % post-BC2 rms bunch length [m]
sz1   = Q*c/sqrt(10)/abs(Ipk1);             % post-BC1 rms bunch length [m]
h     = (1 - sqrt(sz2^2 - R56^2*sd0^2)/sz1)/abs(R56);    % energy chirp in 1/m

sig3y = 2.5*1E3*sqrt(handles.betay_foil*handles.emity*1E-6/(E/511E-6));   % mm
sig3x = 2.5*1E3*sqrt(h^2*sz1^2*eta^2 + beta*emitg);                       % mm

ym    = handles.motor;      % [um]
dy    = handles.y0 - ym;    % [um]

%{
% Old slot width calculations.
if dy < handles.ya                        % if beam is on single slot area of foil
  
  set(handles.AREA,'String','Beam on single-slot area')
  if dy < handles.y1 || dy > handles.y2   % if beam is not on single slot
    handles.bad = 1;
    dx = 0;
    handles.tau = 0;
    set(handles.MOTOR,'ForegroundColor','red')
  else                                    % if beam is on single slot
    handles.bad = 0;
    dx = 1E-6*(handles.x1 + (handles.x2-handles.x1)/(handles.y2-handles.y1)*(dy - handles.y1));     % slot half-width [um]
    if dx > sig3x/1E3     % if slot half width > 2.5*sigmax...
      dx = sig3x/1E3;     % ...don't allow huge slot to limit beam size (i.e., beam is smaller than slot here)
    end
    handles.tau   = 1E15*2.355/abs(c*eta*h)*sqrt(eta^2*sd0^2 + (1+h*R56)^2*(dx^2/3 + emitg*beta));
    set(handles.MOTOR,'ForegroundColor','black')
  end
  if dx < 2.5*sqrt(beta*emitg);           % if slot is too narrow for betaron beam size
    if dy >= 0    % if on foil
      set(handles.STAT,'String','slot < 5*sigX - Ipk loss')
      set(handles.STAT,'ForegroundColor','red')
    else
      set(handles.STAT,'String','beam not on foil')
      set(handles.STAT,'ForegroundColor','red')    
    end
  else                                    % if slot is safely wider than betaron beam size
    set(handles.STAT,'String','slot > 5*sigX - OK')
    set(handles.STAT,'ForegroundColor','green')
  end
  set(handles.TAU1,'string',sprintf('%6.2f',handles.tau))
  set(handles.WIDTH_TEXT,'string','Slot width:')
  set(handles.SLOT_WIDTH1,'string',sprintf('%4.0f',2E6*dx))
  set(handles.DURATION_TEXT,'string','Est. Pulse Duration:')

  xmax  = 9000;   % approx. half width of entire foil for plot display only [um]
  dymax = 1800;   % amount of foil to show in plot that is above top of slot [um]
  ym    = -handles.motor;
  y0    = handles.y0;
  Xo = [-xmax -xmax  xmax xmax]/1E3;
  Yo = ([handles.y2-ym+dymax -ym  -ym handles.y2-ym+dymax] - y0)/1E3;
  plot(Xo,Yo,'k-')
  hold on
  Xs = [-handles.x2 -handles.x1 handles.x1 handles.x2 -handles.x2]/1E3;
  Ys = ([ handles.y2-ym  handles.y1-ym handles.y1-ym handles.y2-ym  handles.y2-ym] - y0)/1E3;
  plot(Xs,Ys,'b-')
  plot_ellipse([1/sig3x^2 0; 0 1/sig3y^2],1,'m-')
  v = axis;
  ylim([min(-1.000,1.1*v(3)) v(4)])
  xlabel('{\itx}  (mm)')
  ylabel('{\ity}  (mm)')
  title('BC2 Slotted-Foil Position')
  hold off

elseif dy < handles.yb && dy >= handles.ya  % if beam is on 1st double slot area of foil

  if dy < handles.ya1 || dy > handles.ya2   % if beam is not on slots
    handles.bad = 1;
    handles.tau = 0;
    set(handles.MOTOR,'ForegroundColor','red')
    set(handles.STAT,'String','Beam not on slots')
    set(handles.STAT,'ForegroundColor','red')
    dx   = 0;
    handles.tau   = 0;
  else                                    % if beam is on slots
    handles.bad = 0;
    handles.tau = 0;
    set(handles.MOTOR,'ForegroundColor','black')
    set(handles.STAT,'String',' ')
    set(handles.STAT,'ForegroundColor','black')
    dx = 2*(1E-6*(handles.xa1 + (handles.xa2-handles.xa1)/(handles.ya2-handles.ya1)*(dy - handles.ya1)) - handles.xaw/2E6);   % slot width [um]
    handles.tau   = 1E15/abs(c*eta*h)*(1+h*R56)*dx;
  end

  set(handles.TAU1,'string',sprintf('%6.2f',handles.tau))
  set(handles.WIDTH_TEXT,'string','Slot separation:')
  set(handles.SLOT_WIDTH1,'string',sprintf('%4.0f',dx*1e6))
  set(handles.DURATION_TEXT,'string','Est. Pulse Separation:')
  set(handles.AREA,'String','Beam on 1st double-slot area')
  xmax  = 9000;   % approx. half width of entire foil for plot display only [um]
  dymax = 1800;   % amount of foil to show in plot that is above top of slot [um]
  ym    = -handles.motor;
  y0    = handles.y0;
  Xo = [xmax xmax]/1E3;
  Yo = ([handles.ya2-ym+dymax handles.ya1-ym-dymax] - y0)/1E3;
  plot(Xo,Yo,'k-',-Xo,Yo,'k-')
  hold on
  Xs = [-handles.xa2 -handles.xa1 -handles.xa1+handles.xaw -handles.xa2+handles.xaw -handles.xa2]/1E3;
  Ys = ([ handles.ya2-ym  handles.ya1-ym handles.ya1-ym handles.ya2-ym  handles.ya2-ym] - y0)/1E3;
  plot(Xs,Ys,'b-',-Xs,Ys,'b-')
  plot_ellipse([1/sig3x^2 0; 0 1/sig3y^2],1,'m-')
  v = axis;
  ylim([min(-1.000,1.1*v(3)) v(4)])
  xlabel('{\itx}  (mm)')
  ylabel('{\ity}  (mm)')
  title('BC2 1st Double Slotted-Foil Position')
  hold off

elseif dy >= handles.yb                     % if beam is on 2nd souble slot area of foil

  if dy < handles.yb1 || dy > handles.yb2   % if beam is not on slots
    handles.bad = 1;
    handles.tau = 0;
    set(handles.MOTOR,'ForegroundColor','red')
    set(handles.STAT,'String','Beam not on slots')
    set(handles.STAT,'ForegroundColor','red')
    dx   = 0;
    handles.tau   = 0;
  else                                    % if beam is on slots
    handles.bad = 0;
    handles.tau = 0;
    set(handles.MOTOR,'ForegroundColor','black')
    set(handles.STAT,'String',' ')
    set(handles.STAT,'ForegroundColor','black')
    dx = 2*(1E-6*(handles.xb1 + (handles.xb2-handles.xb1)/(handles.yb2-handles.yb1)*(dy - handles.yb1)) - handles.xbw/2E6);   % slot width [um]
    handles.tau   = 1E15/abs(c*eta*h)*(1+h*R56)*dx;
  end

  set(handles.TAU1,'string',sprintf('%6.2f',handles.tau))
  set(handles.WIDTH_TEXT,'string','Slot separation:')
  set(handles.SLOT_WIDTH1,'string',sprintf('%4.0f',dx*1e6))
  set(handles.DURATION_TEXT,'string','Est. Pulse Separation:')
  set(handles.AREA,'String','Beam on 2nd double-slot area')
  xmax  = 9000;   % approx. half width of entire foil for plot display only [um]
  dymax = 1800;   % amount of foil to show in plot that is above top of slot [um]
  ym    = -handles.motor;
  y0    = handles.y0;
  Xo = [xmax xmax]/1E3;
  Yo = ([handles.yb2-ym+dymax handles.yb1-ym-dymax] - y0)/1E3;
  plot(Xo,Yo,'k-',-Xo,Yo,'k-')
  hold on
  Xs = [-handles.xb2 -handles.xb1 -handles.xb1+handles.xbw -handles.xb2+handles.xbw -handles.xb2]/1E3;
  Ys = ([ handles.yb2-ym  handles.yb1-ym handles.yb1-ym handles.yb2-ym  handles.yb2-ym] - y0)/1E3;
  plot(Xs,Ys,'b-',-Xs,Ys,'b-')
  plot_ellipse([1/sig3x^2 0; 0 1/sig3y^2],1,'m-')
  v = axis;
  ylim([min(-1.000,1.1*v(3)) v(4)])
  xlabel('{\itx}  (mm)')
  ylabel('{\ity}  (mm)')
  title('BC2 2nd Double Slotted-Foil Position')
  hold off

end
%}

iSlot = find(dy < handles.ySep,1);
if dy < handles.yLow(iSlot) || dy > handles.yHigh(iSlot)   % if beam is not on slots
    handles.bad = 1;
    dx = 0;
    handles.tau = 0;
    set(handles.MOTOR,'ForegroundColor','red')
    set(handles.STAT,'String','Beam not on slots')
    set(handles.STAT,'ForegroundColor','red')
  else                                    % if beam is on slots
    handles.bad = 0;
    set(handles.MOTOR,'ForegroundColor','black')

    dx = 1e-6*(handles.xLow(iSlot) + (handles.xHigh(iSlot)-handles.xLow(iSlot))/(handles.yHigh(iSlot)-handles.yLow(iSlot))*(dy - handles.yLow(iSlot)));     % slot half-width [um]
    if dx > sig3x*1e-3     % if slot half width > 2.5*sigmax...
        dx = sig3x*1e-3;     % ...don't allow huge slot to limit beam size (i.e., beam is smaller than slot here)
    end
    handles.tau   = 1E15*2.355/abs(c*eta*h)*sqrt(eta^2*sd0^2 + (1+h*R56)^2*(dx^2/3 + emitg*beta));

    if handles.xWidth(iSlot) || handles.xSep(iSlot)
        set(handles.STAT,'String',' ')
        set(handles.STAT,'ForegroundColor','black')

        dx = 2*1e-6*((handles.xLow(iSlot) + (handles.xHigh(iSlot)-handles.xLow(iSlot))/(handles.yHigh(iSlot)-handles.yLow(iSlot))*(dy - handles.yLow(iSlot))) - handles.xWidth(iSlot)/2);   % slot width [um]
        if handles.xSep(iSlot)
            dx = 1e-6*handles.xSep(iSlot);   % slot width [um]
        end
        handles.tau   = 1E15/abs(c*eta*h)*(1+h*R56)*dx;
    end
end

if ~handles.xWidth(iSlot) && ~handles.xSep(iSlot)
    if dx < 2.5*sqrt(beta*emitg);           % if slot is too narrow for betatron beam size
        if dy >= 0    % if on foil
            set(handles.STAT,'String','slot < 5*sigX - Ipk loss')
        else
            set(handles.STAT,'String','beam not on foil')
        end
        set(handles.STAT,'ForegroundColor','red')
    else                                    % if slot is safely wider than betaron beam size
        set(handles.STAT,'String','slot > 5*sigX - OK')
        set(handles.STAT,'ForegroundColor','green')
    end
end

% Update display.
set(handles.AREA,'String',['Beam on ' handles.areaStr{iSlot} ' area']);
set(handles.TAU1,'string',sprintf('%6.2f',handles.tau));
set(handles.WIDTH_TEXT,'String','Slot width:');
set(handles.SLOT_WIDTH1,'String',sprintf('%4.0f',dx*2e6))
set(handles.DURATION_TEXT,'String','Est. Pulse Duration:')
if handles.xWidth(iSlot) && handles.xSep(iSlot)
    set(handles.WIDTH_TEXT,'String','Slot separation:');
    set(handles.SLOT_WIDTH1,'String',sprintf('%4.0f',dx*1e6))
    set(handles.DURATION_TEXT,'String','Est. Pulse Separation:')
end

% Plot foil.
xmax  = 9000;   % approx. half width of entire foil for plot display only [um]
dymax = 1800;   % amount of foil to show in plot that is above top of slot [um]

Xo = [-xmax -xmax  xmax xmax]/1E3;
Yo = ((handles.yHigh(iSlot)+dymax)*[1 0  0 1]-dy)*1e-3;
if iSlot > 1
    Xo = [-xmax -xmax]/1E3;
    Yo = ([handles.yHigh(iSlot)+dymax handles.yLow(iSlot)-dymax]-dy)*1e-3;
end
Xo = [Xo NaN -Xo];
Yo = [Yo NaN Yo];

plot(Xo,Yo,'k-')
hold on

%Xs = [-handles.x2 -handles.x1 handles.x1 handles.x2 -handles.x2]/1E3;
%Xs = [-handles.xa2 -handles.xa1 -handles.xa1+handles.xaw -handles.xa2+handles.xaw -handles.xa2]/1E3;
%Xs = [-handles.xb2 -handles.xb1 -handles.xb1+handles.xbw -handles.xb2+handles.xbw -handles.xb2]/1E3;
%Ys = ([ handles.y2   handles.y1  handles.y1  handles.y2   handles.y2 ]-dy)/1E3;
Xs = [handles.xHigh(iSlot) handles.xLow(iSlot)]*[-1 0 0 -1+2 -1;0 -1 -1+2 0 0]*1e-3;
Ys = ([handles.yHigh(iSlot) handles.yLow(iSlot)]*[1 0 0 1 1;0 1 1 0 0]-dy)*1e-3;

if handles.xWidth(iSlot)
    Xs = [handles.xHigh(iSlot) handles.xLow(iSlot)]*[-1 0 0 -1 -1;0 -1 -1 0 0]*1e-3;
    Xs = Xs+handles.xWidth(iSlot)*[0 0 1 1 0]*1e-3;
    Xs = [Xs NaN -Xs];
    Ys = [Ys NaN Ys];
end

num=handles.xNum(iSlot);
if num > 1
    Xs = repmat([Xs NaN],1,num)+reshape(repmat(handles.xSep(iSlot)*1e-3*(-(num-1)/2:(num-1)/2),numel(Xs)+1,1),1,[]);
    Ys = repmat([Ys NaN],1,num);
end

Xs=Xs+handles.xOff(iSlot)*1e-3;
plot(Xs,Ys,'b-')

plot_ellipse([1/sig3x^2 0; 0 1/sig3y^2],1,'m-')
v = axis;
xlim([-10 10])
ylim([min(-1.000,1.1*v(3)) v(4)])
xlabel('{\itx}  (mm)')
ylabel('{\ity}  (mm)')
title(regexprep(['BC2 ' handles.areaStr{iSlot} 'ted-Foil Position'],'\<(\w)','${upper($1)}'));

hold off

guidata(hObject, handles);




% --- Executes on button press in UPDATE.
function UPDATE_Callback(hObject, eventdata, handles)
handles.bc2_Ipk   = lcaGetSmart(handles.bc2_Ipk_pv);                % A
handles.lh_energy = lcaGetSmart(handles.lh_energy_pv);              % uJ
handles.emitx = lcaGetSmart(handles.emitx_pv);                      % um
handles.emity = lcaGetSmart(handles.emity_pv);                      % um
handles.bc2r56 = lcaGetSmart(handles.bc2r56_pv);                    % mm
handles.bc2_energy = lcaGetSmart(handles.bc2_energy_pv);            % GeV
twss_otr21 = model_rMatGet('OTR21',[],'TYPE=DESIGN','twiss');
handles.betax_foil = twss_otr21(3);                                 % m
handles.betay_foil = twss_otr21(8);                                 % m
handles.etax_foil  = 1E3*twss_otr21(5);                             % m->mm
handles.bc1_Ipk    = lcaGetSmart(handles.bc1_Ipk_pv);               % A
handles.charge     = lcaGetSmart(handles.charge_pv);                % nC
handles.bc2_bdes   = lcaGetSmart(handles.bc2_bdes_pv);              % kG
handles.lvdt       = lcaGetSmart(handles.lvdt_pv);                  % um
handles.lh_shutter = lcaGetSmart(handles.lh_shutter_pv,0,'double'); % 0=closed or 1=open
handles.esprd      = str2double(get(handles.ESPRD,'string'));       % keV
handles.tcav0_bunch_length = str2double(get(handles.TCAV0_BUNCH_LENGTH,'string'));       % um
handles.motor      = lcaGetSmart(handles.motor_pv);                      % um
handles.y0         = str2double(get(handles.Y0,'string'));
%handles.x1         = str2double(get(handles.X1,'string'));
%handles.x2         = str2double(get(handles.X2,'string'));
%handles.y1         = str2double(get(handles.Y1,'string'));
%handles.y2         = str2double(get(handles.Y2,'string'));

set(handles.BC2_IPK,'string',sprintf('%4.0f',handles.bc2_Ipk))
set(handles.LH_ENERGY,'string',sprintf('%5.1f',handles.lh_energy*handles.lh_shutter))
set(handles.EMITX,'string',sprintf('%4.2f',handles.emitx))
set(handles.BETAX_FOIL,'string',sprintf('%5.1f',handles.betax_foil))
set(handles.ETAX_FOIL,'string',sprintf('%5.1f',handles.etax_foil))
set(handles.BC2R56,'string',sprintf('%5.1f',handles.bc2r56))
set(handles.BC2_ENERGY,'string',sprintf('%5.3f',handles.bc2_energy))
set(handles.BC1_IPK,'string',sprintf('%4.0f',handles.bc1_Ipk))
set(handles.CHARGE,'string',sprintf('%5.3f',handles.charge))
set(handles.MOTOR,'string',sprintf('%5.0f',handles.motor))
set(handles.LVDT,'string',sprintf('%5.0f',handles.lvdt))

calc(hObject, eventdata, handles)

guidata(hObject, handles);



function SET_MOTOR_Callback(hObject, eventdata, handles)
set(handles.SET_MOTOR,'BackgroundColor','white')
set(handles.SET_MOTOR,'string','wait...')
drawnow
lvdt0 = lcaGetSmart(handles.lvdt_pv);
handles.motor = str2double(get(handles.MOTOR,'string'));
lcaSetTimeout(0.5);
lcaPutSmart(handles.motor_pv,handles.motor);
pause(1)
handles.lvdt = lcaGetSmart(handles.lvdt_pv);
set(handles.LVDT,'string',sprintf('%5.0f',handles.lvdt))
set(handles.SET_MOTOR,'string','Set Motor')
set(handles.SET_MOTOR,'BackgroundColor','yellow')
guidata(hObject, handles);



% --- Executes on button press in XSCAN.
function XSCAN_Callback(hObject, eventdata, handles)
configFile = [fullfile(getenv('MATLABDATAFILES'),'config') '/'...
    'Slotted_Foil_Scan_With_Offset.mat'];
load(configFile,'config')
[hObjCP,handCP]=util_appFind('corrPlot_gui');
corrPlot_gui('appLoad',hObjCP,handCP,config);



% --- Executes on button press in FOIL_OUT.
function FOIL_OUT_Callback(hObject, eventdata, handles)
lcaSetTimeout(0.5);
lcaPutSmart(handles.foil_out_pv,1);
set(handles.STAT,'String','Foil is OUT')
set(handles.STAT,'ForegroundColor','red')
pause(1)
handles.lvdt       = lcaGetSmart(handles.lvdt_pv);                  % um
handles.motor      = lcaGetSmart(handles.motor_pv);                 % um
set(handles.LVDT,'string',sprintf('%5.0f',handles.lvdt))
set(handles.MOTOR,'string',sprintf('%5.0f',handles.motor))

% If there's a BPM offset, ask if user wants to remove it.
X_Offset = 'BPMS:LI24:801:XOFF.B';
if lcaGet(X_Offset) ~= 0
    answer = questdlg('BC2 BPM offset is not zero. Would you like to remove the offset?', ...
        'BC2 BPM Offset', 'Yes', 'No', 'No');
    switch answer
        case 'Yes'
            lcaPut(X_Offset, 0);
            disp('Removing X Offset.');
        otherwise
            disp('Keeping X Offset.');
    end
end

calc(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on selection change in device_pmu.
function device_pmu_Callback(hObject, eventdata, handles)

deviceControl(hObject,handles,get(hObject,'Value'));


function pv = bc1_chargeName()
% Get the name for the charge after BC1, including horn cutting
val = lcaGetSmart('BPMS:SYS0:2:ATTR_INUSE',1,'double');
switch val
    case 2
        pv = 'BPMS:SYS0:2:QANN';
    otherwise
        [~,pv] = control_chargeName;
end


% --- Executes on button press in BC2BETA.
function BC2BETA_Callback(hObject, eventdata, handles)
% hObject    handle to BC2BETA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BC2_match;
