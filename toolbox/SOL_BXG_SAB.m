function varargout = SOL_BXG_SAB(varargin)
% SOL_BXG_SAB M-file for SOL_BXG_SAB.fig
%      SOL_BXG_SAB, by itself, creates a new SOL_BXG_SAB or raises the existing
%      singleton*.
%
%      H = SOL_BXG_SAB returns the handle to a new SOL_BXG_SAB or the handle to
%      the existing singleton*.
%
%      SOL_BXG_SAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOL_BXG_SAB.M with the given input arguments.
%
%      SOL_BXG_SAB('Property','Value',...) creates a new SOL_BXG_SAB or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before SOL_BXG_SAB_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SOL_BXG_SAB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help SOL_BXG_SAB

% Last Modified by GUIDE v2.5 09-Jun-2014 15:07:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SOL_BXG_SAB_OpeningFcn, ...
                   'gui_OutputFcn',  @SOL_BXG_SAB_OutputFcn, ...
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


% --- Executes just before SOL_BXG_SAB is made visible.
function SOL_BXG_SAB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SOL_BXG_SAB (see VARARGIN)

% Choose default command line output for SOL_BXG_SAB
handles.output = hObject;

% Update handles structure
handles.beamOffPV    = 'IOC:BSY0:MP01:PCELLCTL';
handles.SOL1BK_pv    = 'SOLN:IN20:111';
handles.SOL1_pv      = 'SOLN:IN20:121';
handles.BXG_pv       = 'BEND:IN20:231';
handles.BXGT_pv      = 'BTRM:IN20:231';
handles.gun_energy_pv= 'GUN:IN20:1:GN1_ADES';
handles.ONOFFBXG_pv  = 'BEND:IN20:231:STATE';  % changed from LGPS 2 (July 5, 2010 - PE)
handles.BX01_pv      = 'BEND:IN20:751';
handles.BX01T_pv     = 'BTRM:IN20:661';
handles.ONOFFBX01_pv = 'BEND:IN20:751:STATE';
handles.WK_PNEU      = 'PLUG:IN20:231:WKFLD_PNEU'; % set it to 1: Spectrometer mode,  set it to 0: StraightAhead mode
handles.WK_IN        = 'PLUG:IN20:231:WKFLD_IN';   % reads "Sectrometer" or "-------------"
handles.WK_OUT       = 'PLUG:IN20:231:WKFLD_OUT';  % reads "StraightAhead" or "-------------"
handles.BXS_energy   = lcaGetSmart('BEND:IN20:931:BDES');    % get present energy from BXS [GeV]
handles.gun_energy   = lcaGetSmart('SIOC:SYS0:ML00:AO105');  % get nominal (OP GUI) gun energy [MeV]
handles.L0a_energy   = lcaGetSmart('SIOC:SYS0:ML00:AO108');  % get nominal (OP GUI) L0a energy gain [MeV]
set(handles.GUNENERGY,'String',handles.gun_energy)
set(handles.BX01ENERGY,'String',handles.BXS_energy*1E3)
set(handles.INIT_ENERGY,'String',handles.BXS_energy*1E3)
%set(handles.NEW_ENERGY,'String',handles.gun_energy+handles.L0a_energy)
set(handles.NEW_ENERGY,'String',handles.BXS_energy*1E3)
guidata(hObject, handles);

update(handles);

% UIWAIT makes SOL_BXG_SAB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SOL_BXG_SAB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function update(handles)

gun = get(handles.GUN1,'Value');
if gun==1
  handles.gun_number = 1;
else
  handles.gun_number = 2;
end
handles.sol1bkbact = lcaGetSmart([handles.SOL1BK_pv ':BACT']);
handles.sol1bkbdes = lcaGetSmart([handles.SOL1BK_pv ':BDES']);
handles.sol1bact   = lcaGetSmart([handles.SOL1_pv ':BACT']);
handles.sol1bdes   = lcaGetSmart([handles.SOL1_pv ':BDES']);
handles.bxgbact    = lcaGetSmart([handles.BXG_pv ':BACT']);
handles.bxgbdes    = lcaGetSmart([handles.BXG_pv ':BDES']);
handles.bxgtbact   = lcaGetSmart([handles.BXGT_pv ':BACT']);
handles.bxgtbdes   = lcaGetSmart([handles.BXGT_pv ':BDES']);
handles.bx01bact   = lcaGetSmart([handles.BX01_pv ':BACT']);
handles.bx01bdes   = lcaGetSmart([handles.BX01_pv ':BDES']);
handles.bx01tbact  = lcaGetSmart([handles.BX01T_pv ':BACT']);
handles.bx01tbdes  = lcaGetSmart([handles.BX01T_pv ':BDES']);
handles.gun_energy = lcaGetSmart(handles.gun_energy_pv);
if handles.bxgbact > 0.001; % > 1 MeV/c
  handles.onoffbxg = 1; % BXG above zero enough to call "ON"
  set(handles.BXGTRIMMED,'String','ON')
  set(handles.BXGTRIMMED,'ForegroundColor','green')
else
  handles.onoffbxg = 0; % BXG near enough to zero to call "OFF"
  set(handles.BXGTRIMMED,'String','DAC-ZEROed')
  set(handles.BXGTRIMMED,'ForegroundColor','red')
end
handles.onoffbxgD = lcaGetSmart(handles.ONOFFBXG_pv,0,'integer');      % read if BXG is 'ON' or 'OFF'
if handles.onoffbxgD == 0  % BXG BEND OFF
  set(handles.BXGISOFF,'String','OFF')
  set(handles.BXGISOFF,'ForegroundColor','red')
else
  set(handles.BXGISOFF,'String','ON')
  set(handles.BXGISOFF,'ForegroundColor','green')
end

handles.wakeIN    = lcaGetSmart(handles.WK_IN,0,'integer');              % BXG wake-plug-IN  (1='Spectrometer',  0=not)
handles.wakeOUT   = lcaGetSmart(handles.WK_OUT,0,'integer');             % BXG wake-plug-OUT (1='StraightAhead', 0=not)

if handles.bx01bact > 0.01; % > 10 MeV/c
  handles.onoffbx01 = 1; % BX01 above zero enough to call "ON"
  set(handles.BX01TRIMMED,'String','ON')
  set(handles.BX01TRIMMED,'ForegroundColor','green')
else
  handles.onoffbx01 = 0; % BX01 near enough to zero to call "OFF"
  set(handles.BX01TRIMMED,'String','DAC-ZEROed')
  set(handles.BX01TRIMMED,'ForegroundColor','red')
end
handles.onoffbx01D = lcaGetSmart(handles.ONOFFBX01_pv,0,'integer');      % read if BXG is 'ON' or 'OFF'
if handles.onoffbx01D == 0  % BEND OFF
  set(handles.BX01ISOFF,'String','OFF')
  set(handles.BX01ISOFF,'ForegroundColor','red')
else
  set(handles.BX01ISOFF,'String','ON')
  set(handles.BX01ISOFF,'ForegroundColor','green')
end

str = sprintf('%8.5f',handles.sol1bkbact);
set(handles.SOL1BKBACT,'String',str);
str = sprintf('%8.5f',handles.sol1bkbdes);
set(handles.SOL1BKBDES,'String',str);
set(handles.SOL1BKBDES,'ForegroundColor','green');
str = sprintf('%8.5f',handles.sol1bact);
set(handles.SOL1BACT,'String',str);
str = sprintf('%8.5f',handles.sol1bdes);
set(handles.SOL1BDES,'String',str);

str = sprintf('%8.5f',handles.bxgbact);
set(handles.BXGBACT,'String',str);
str = sprintf('%8.5f',handles.bxgbdes);
set(handles.BXGBDES,'String',str);
str = sprintf('%8.5f',handles.bxgtbact);
set(handles.BXGTBACT,'String',str);
str = sprintf('%8.5f',handles.bxgtbdes);
set(handles.BXGTBDES,'String',str);
str = sprintf('%5.2f',handles.gun_energy);
set(handles.GUNENERGY,'String',str);

str = sprintf('%8.5f',handles.bx01bact);
set(handles.BX01BACT,'String',str);
str = sprintf('%8.5f',handles.bx01bdes);
set(handles.BX01BDES,'String',str);
str = sprintf('%8.5f',handles.bx01tbact);
set(handles.BX01TBACT,'String',str);
str = sprintf('%8.5f',handles.bx01tbdes);
set(handles.BX01TBDES,'String',str);

if handles.wakeIN==1 & handles.wakeOUT==0
  set(handles.WAKEINOUT,'String','Spectrometer');
  set(handles.WAKEINOUT,'ForegroundColor','green');
end
if handles.wakeOUT==1 & handles.wakeIN==0
  set(handles.WAKEINOUT,'String','StraightAhead');
  set(handles.WAKEINOUT,'ForegroundColor','red');
end
if handles.wakeOUT==0 & handles.wakeIN==0
  set(handles.WAKEINOUT,'String','Unknown');
  set(handles.WAKEINOUT,'ForegroundColor','magenta');
end
set(handles.ONOFFBXG,'Value',handles.onoffbxg);
if handles.onoffbxg == 1    % BXG is ON
  set(handles.ONOFFBXG,'BackgroundColor','green');
  set(handles.ONOFFBXG,'String','BXG ON/OFF');
else                        % BXG is OFF
  set(handles.ONOFFBXG,'BackgroundColor','red');
  set(handles.ONOFFBXG,'String','BXG ON/OFF');
end

set(handles.ONOFFBX01,'Value',handles.onoffbx01);
if handles.onoffbx01 == 1    % BX01 is ON
  set(handles.ONOFFBX01,'BackgroundColor','green');
  set(handles.ONOFFBX01,'String','BX01 ON/OFF');
else                        % BX01 is OFF
  set(handles.ONOFFBX01,'BackgroundColor','red');
  set(handles.ONOFFBX01,'String','BX01 ON/OFF');
end

set(handles.BXGSTATUS,'String','Done')
set(handles.BXGSTATUS,'ForegroundColor','green')
set(handles.BX01STATUS,'String','Done')
set(handles.BX01STATUS,'ForegroundColor','green')
guidata(handles.figure1,handles);


function GUNENERGY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function GUNENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SOL1BACT_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function SOL1BACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcBk.
function calcBk_Callback(hObject, eventdata, handles)
handles.sol1bact = str2double(get(handles.SOL1BACT,'String'));
[handles.sol1bkbdes,Ib] = bucking_coil_BDES(handles.sol1bact,handles.gun_number);
str = sprintf('%8.5f',handles.sol1bkbdes);
set(handles.SOL1BKBDES,'String',str);
set(handles.SOL1BKBDES,'ForegroundColor','red');
guidata(handles.figure1,handles);


function SOL1BKBACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function SOL1BKBACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SOLTRIM.
function SOLTRIM_Callback(hObject, eventdata, handles)
trim_magnet(handles.SOL1BK_pv,handles.sol1bkbdes);
update(handles)


function BXGBDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BXGBDES_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ONOFFBXG.
function ONOFFBXG_Callback(hObject, eventdata, handles)
onoff = get(hObject,'Value');
if onoff == 1                   % BXG is being turned ON (Spectrometer mode)
%  if handles.onoffbxgD == 0;    % BXG BEND is OFF
%    warndlg('BXG BEND is OFF - please turn it ON first','BXG BEND OFF')
%    set(handles.BXGSTATUS,'String','BXG BEND is OFF - please turn on first')
%    set(handles.BXGSTATUS,'ForegroundColor','red')
%    set(handles.BXGSTATUS,'FontWeight','bold')
%    drawnow
%  else                          % BXG BEND is ON
    lcaPut([handles.BXG_pv ':CTRL'],'TURN_ON');    % turn ON new BXG supply in any case (7/5/10 -PE)
    set(handles.ONOFFBXG,'BackgroundColor','green');
    set(handles.ONOFFBXG,'String','BXG ON/OFF');
    pause(2)
    energy = str2double(get(handles.GUNENERGY,'String'))/1E3;
    set(handles.BXGBDES,'String',energy);
    set(handles.BXGTBDES,'String',0);
    set(handles.BXGSTATUS,'String','Beam OFF...  started switching...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    shutter_open = lcaGetSmart(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of MPS shutter
    lcaPut(handles.beamOffPV,0);      % turn off beam at MPS shutter
    lcaPut(handles.WK_PNEU,1);
    set(handles.WAKEINOUT,'String','moving...');
    set(handles.WAKEINOUT,'ForegroundColor','yellow');
    set(handles.BXGSTATUS,'String','Beam OFF...  ramping up BXG...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','blue')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
%    nnu = 10;                               % take nnu steps to get up to BDES
%    for j = 1:(nnu-1)
%      BDES = energy*j/nnu;                  % zero to BDES in "nnu" steps
%      trim_magnet(handles.BXG_pv,BDES,'P'); % perturb used to ramp up
%      pause(2)
%    end
    trim_magnet(handles.BXG_pv,energy,'P');  % final TRIM to full BDES
    set(handles.BXGSTATUS,'String','Beam OFF...  setting TRIM to zero...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    trim_magnet(handles.BXGT_pv,0);          % set trim-coil to zero
    set(handles.BXGSTATUS,'String','Beam OFF...  waiting for wake plug...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    for j = 1:15
      pause(1)
      handles.wakeIN = lcaGetSmart(handles.WK_IN,0,'integer');
      if handles.wakeIN==1
        handles.onoffbxg  = 1;              % Spectrometer mode  
        break
      end
    end
    lcaPut(handles.beamOffPV,shutter_open); % restore MPS shutter
    set(handles.BXGSTATUS,'String','DONE - MPS shutter restored!')
    set(handles.BXGSTATUS,'ForegroundColor','green')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    pause(1)
%  end
else                                        % BXG is being turned OFF (StraightAhead mode)
  if handles.onoffbxgD == 0;                % BXG BEND is OFF
    warndlg('BXG BEND is OFF - cannot switch OFF if already so','BXG BEND OFF')
    set(handles.BXGSTATUS,'String','BXG BEND is already OFF!')
    set(handles.BXGSTATUS,'ForegroundColor','red')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
  else                                      % BXG BEND is ON
    set(handles.ONOFFBXG,'BackgroundColor','red');
    set(handles.ONOFFBXG,'String','BXG ON/OFF');
    set(handles.BXGBDES,'String',0);
    BCON = lcaGetSmart([handles.BXGT_pv ':BCON']);  % read BXG trim BCON as best setting to go to
%    set(handles.BXGTBDES,'String',-1.06);    % use design of -1.06 (1/25/08)
    set(handles.BXGTBDES,'String',BCON);      % set to BCON as best operational setting (7/5/10 - PE)
    set(handles.BXGSTATUS,'String','Beam OFF...  started switching...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    shutter_open = lcaGetSmart(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of MPS shutter
    lcaPut(handles.beamOffPV,0);              % turn off beam at MPS shutter
    lcaPut(handles.WK_PNEU,0);
    set(handles.WAKEINOUT,'String','moving...');
    set(handles.WAKEINOUT,'ForegroundColor','yellow');
    drawnow
    BDES0 = lcaGetSmart([handles.BXG_pv ':BDES']);
    BMAX  = lcaGetSmart([handles.BXG_pv ':BACT.HOPR']);
    set(handles.BXGSTATUS,'String','Beam OFF...  TRIM set to zero & cycling magnet...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','blue')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    trim_magnet(handles.BXGT_pv,0,'P');  % first set BXG-Trim to zero before cycling BXG
    nnu = 4;      % take n steps to get from BDES0 to BMAX
    for j = 1:nnu
      BDES = BDES0 + (BMAX - BDES0)*j/nnu;   % BDES0 to BMAX in "nnu" steps
      trim_magnet(handles.BXG_pv,BDES,'P');  % 8.518 trim-coil amps but 8-times less main-coil amps (wants -0.2 A - 5/22/07)
      pause(2)
    end
    set(handles.BXGSTATUS,'String','Beam OFF...  settle time pause...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    pause(5)    % settle time at BMAX
    set(handles.BXGSTATUS,'String','Beam OFF...  ramping down...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','blue')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    nnd = round(nnu*BMAX/(BMAX-BDES0));
    for j = 1:nnd                   % ramp down, then DAC-zero
      BDES = BMAX*(1 - j/nnd);      % BDES0 to BMAX in "nn" steps
      trim_magnet(handles.BXG_pv,BDES,'P');  % 8.518 trim-coil amps but 8-times less main-coil amps (wants -0.2 A - 5/22/07)
      pause(2)
    end
    set(handles.BXGSTATUS,'String','Beam OFF...  DAC-zeroing BXG...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    lcaPut([handles.BXG_pv ':CTRL'],'DAC_ZERO');
    pause(2)        % allow DAC-zero to settle
    lcaPut([handles.BXG_pv ':CTRL'],'TURN_OFF');    % turn off new BXG supply (7/5/10 -PE)
    set(handles.BXGSTATUS,'String','Beam OFF...  Setting BDES to BACT after BXG OFF...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','blue')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    BACT = lcaGetSmart([handles.BXG_pv ':BACT']);
    lcaPut([handles.BXG_pv ':BDES'],BACT);  % set BDES to BACT after DAC-zero so no alarms in this condition
    
%   Set BXG Trim...
%    trim_magnet(handles.BXGT_pv,-1.06);  % Use design of -1.06 A (1/25/08) - 8.518 trim-coil amps but 8-times less main-coil amps (wants -1.03 A - 7/25/07)
    trim_magnet(handles.BXGT_pv,BCON);  % Use BCON as best operations trim setting (7/5/10 - PE)
    set(handles.BXGSTATUS,'String','Beam OFF...  waiting for wake plug...  please wait')
    set(handles.BXGSTATUS,'ForegroundColor','magenta')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    for j = 1:15
      pause(1)
      handles.wakeOUT = lcaGetSmart(handles.WK_OUT,0,'integer');
      if handles.wakeOUT==1
        handles.onoffbxg  = 0;              % StraightAhead mode  
        break
      end
    end
    lcaPut(handles.beamOffPV,shutter_open);      % restore the MPS shutter
    set(handles.BXGSTATUS,'String','DONE - MPS shutter restored!')
    set(handles.BXGSTATUS,'ForegroundColor','green')
    set(handles.BXGSTATUS,'FontWeight','bold')
    drawnow
    pause(1)
  end
end
update(handles)


function BXGBACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BXGBACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BXGTBDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BXGTBDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BXGTBACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BXGTBACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BX01BDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BX01BDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BX01BACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BX01BACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BX01TBDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BX01TBDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BX01TBACT_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function BX01TBACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ONOFFBX01.
function ONOFFBX01_Callback(hObject, eventdata, handles)
onoff = get(hObject,'Value');
if onoff == 1    % BX01 is being turned ON
  if handles.onoffbx01D == 0;  % if supply is OFF
    set(handles.BX01STATUS,'String','BX01/BX02 BEND is OFF - please turn on first')
    set(handles.BX01STATUS,'ForegroundColor','red')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    pause(2)
  else
    set(handles.ONOFFBX01,'BackgroundColor','green');
    set(handles.ONOFFBX01,'String','BX01 ON/OFF');
    energy = str2double(get(handles.BX01ENERGY,'String'))/1E3;
    [BDES,Imain,Itrim] = DL1_BDES(17.5,energy);
    set(handles.BX01BDES ,'String',BDES(1))
    set(handles.BX01TBDES,'String',BDES(2))
    set(handles.BX01STATUS,'String','Beam OFF...  ramping up...  please wait')
    set(handles.BX01STATUS,'ForegroundColor','magenta')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    shutter_open = lcaGetSmart(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of MPS shutter
    lcaPut(handles.beamOffPV,0);      % turn off beam at MPS shutter
    trim_magnet(handles.BX01_pv,energy);
    trim_magnet(handles.BX01T_pv,BDES(2));  % set trim-coil
    Ides = lcaGetSmart('BEND:IN20:751:IDES');
    rate = lcaGetSmart('PSC:IN20:MG01:IRAMPRATE');  % A/sec
    tau = Ides/rate;
    itry = 0;
    while 1
      pause(tau/20)
      bact = lcaGetSmart([handles.BX01_pv ':BACT']);
      str = sprintf('%8.5f',bact);
      set(handles.BX01BACT ,'String',str)
      drawnow
      itry = itry + 1;
      if itry == 25
        lcaPut([handles.BX01_pv ':CTRL'],'PERTURB');
      end
      if itry == 40
        set(handles.BX01STATUS,'String','BX01/BX02 failed to TRIM to within 1% - please TRIM - shutter restored.')
        set(handles.BX01STATUS,'ForegroundColor','red')
        set(handles.BX01STATUS,'FontWeight','bold')
        lcaPut(handles.beamOffPV,shutter_open);      % turn on beam at MPS shutter
        drawnow
        break
      end
      if abs(bact-BDES(1))/BDES(1) <0.01
        pause(1)
        bact = lcaGetSmart([handles.BX01_pv ':BACT']);
        str = sprintf('%8.5f',bact);
        set(handles.BX01BACT ,'String',str)
        set(handles.BX01STATUS,'String','Done - beam back ON.')
        set(handles.BX01STATUS,'ForegroundColor','green')
        lcaPut(handles.beamOffPV,shutter_open);      % restore the MPS shutter
        drawnow
        break
      end
    end
  end
else                        % BX01 is being turned OFF
  if handles.onoffbx01D == 0;  % if supply is OFF
    set(handles.BX01STATUS,'String','BX01/BX02 is OFF - cannot turn OFF if already so')
    set(handles.BX01STATUS,'ForegroundColor','red')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    pause(2)
  else
    set(handles.ONOFFBX01,'BackgroundColor','red');
    set(handles.ONOFFBX01,'String','BX01 ON/OFF');
    energy = str2double(get(handles.BX01ENERGY,'String'))/1E3;
    [BDES,Imain,Itrim] = DL1_BDES(0,energy);
    str = sprintf('%8.5f',BDES(1));
    set(handles.BX01BDES ,'String',str)
    str = sprintf('%8.5f',BDES(2));
    set(handles.BX01TBDES,'String',str)
    set(handles.BX01STATUS,'String','Beam OFF...  cycling BX01/02...  please wait')
    set(handles.BX01STATUS,'ForegroundColor','magenta')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    shutter_open = lcaGetSmart(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of MPS shutter
    lcaPut(handles.beamOffPV,0);      % turn off beam at MPS shutter
    BMAX  = lcaGetSmart([handles.BX01_pv ':BDES.HOPR']);
    trim_magnet(handles.BX01_pv,BMAX,'P');
    set(handles.BX01STATUS,'String','Beam OFF...  pausing at BMAX...  please wait')
    set(handles.BX01STATUS,'ForegroundColor','blue')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    pause(10)
    set(handles.BX01STATUS,'String','Beam OFF...  ramping down BX01/02...  please wait')
    set(handles.BX01STATUS,'ForegroundColor','magenta')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    trim_magnet(handles.BX01_pv,BDES(1),'P');
    lcaPut([handles.BX01_pv ':CTRL'],'DAC_ZERO');
    set(handles.BX01STATUS,'String','Beam OFF...  DAC-zeroing BX02 & setting TRIM...  please wait')
    set(handles.BX01STATUS,'ForegroundColor','blue')
    set(handles.BX01STATUS,'FontWeight','bold')
    drawnow
    trim_magnet(handles.BX01T_pv,BDES(2));  % set trim-coil
    Iact = lcaGetSmart('PSC:IN20:MG01:IACT');
    rate = lcaGetSmart('PSC:IN20:MG01:IRAMPRATE');  % A/sec
    tau = Iact/rate;
    itry = 0;
    while 1
      pause(tau/20)
      bact = lcaGetSmart([handles.BX01_pv ':BACT']);
      str = sprintf('%8.5f',bact);
      set(handles.BX01BACT ,'String',str)
      drawnow
      itry = itry + 1;
      if itry == 40
        set(handles.BX01STATUS,'String','BX01/BX02 failed to DAC-zero below 0.005 GeV/c - shutter restored')
        set(handles.BX01STATUS,'ForegroundColor','red')
        set(handles.BX01STATUS,'FontWeight','bold')
        lcaPut(handles.beamOffPV,shutter_open);      % restore the MPS shutter
        drawnow
        pause(2)
        break
      end
      if bact <0.005
        pause(5)
        bact = lcaGetSmart([handles.BX01_pv ':BACT']);
        lcaPut([handles.BX01_pv ':BDES'],bact);     % set BDES = BACT after DAC-zero so readback is IN tolerance
        str = sprintf('%8.5f',bact);
        set(handles.BX01BACT ,'String',str)
        set(handles.BX01STATUS,'String','Done - beam back ON.')
        set(handles.BX01STATUS,'ForegroundColor','green')
        drawnow
        pause(2)
        lcaPut(handles.beamOffPV,shutter_open);      % restore the MPS shutter
        break
      end
    end
  end
end
pause(1)
update(handles)
guidata(handles.figure1,handles);


function BX01ENERGY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BX01ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function INSTALLED_SelectionChangeFcn(hObject, eventdata, handles)
switch get(hObject,'Tag')   % Get Tag of selected object
  case 'GUN1'
    handles.gun_number = 1;
  case 'GUN2'
    handles.gun_number = 2;
end
guidata(handles.figure1,handles);


% --- Executes on button press in UPDATE.
function UPDATE_Callback(hObject, eventdata, handles)
update(handles)
str = get_time;
set(handles.DATE,'String',str)



function SOL1BDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function SOL1BDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SOL1BKBDES_Callback(hObject, eventdata, handles)
warndlg('This is not a data-entry window','OUTPUT ONLY')

% --- Executes during object creation, after setting all properties.
function SOL1BKBDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
delete(hObject);
% exit from Matlab when not running the desktop
if usejava('desktop')
    % don't exit from Matlab
else
    exit
end


% --- Executes on button press in SCALE_MAGNETS.
function SCALE_MAGNETS_Callback(hObject, eventdata, handles)
E0 = str2double(get(handles.INIT_ENERGY,'String'));
En = str2double(get(handles.NEW_ENERGY,'String'));
mag_PVs = {'QUAD:IN20:425'
           'QUAD:IN20:441'
           'QUAD:IN20:511'
           'QUAD:IN20:525'
           'QUAD:IN20:631'
           'QUAD:IN20:651'
           'QUAD:IN20:941'
           'QUAD:IN20:961'
           'BEND:IN20:461'
           'XCOR:IN20:411'
           'XCOR:IN20:491'
           'XCOR:IN20:521'
           'XCOR:IN20:641'
           'XCOR:IN20:911'
           'XCOR:IN20:951'
           'YCOR:IN20:412'
           'YCOR:IN20:492'
           'YCOR:IN20:522'
           'YCOR:IN20:642'
           'YCOR:IN20:912'
           'YCOR:IN20:952'
           'BEND:IN20:931'
                            };      % magnets to scale
nmags = length(mag_PVs);
disp('Scaling the following injector magnet BDES values...')
for j = 1:nmags
  BDES(j) = lcaGetSmart([mag_PVs{j} ':BDES']);
  newBDES(j) = BDES(j)*En/E0;
  disp(sprintf('%s: %10.6f -> %10.6f',mag_PVs{j},BDES(j),newBDES(j)))
end
set(handles.BX01STATUS,'ForegroundColor','black')
set(handles.BX01STATUS,'String','Trimming all injector magnets (see Matlab terminal window)...')
drawnow
trim_magnet(mag_PVs, newBDES, 'T');
set(handles.BX01STATUS,'ForegroundColor','green')
set(handles.BX01STATUS,'String','All injector magnets now scaled and trimmed (see Matlab terminal window).')
drawnow


function INIT_ENERGY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function INIT_ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NEW_ENERGY_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function NEW_ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
pos = get(gcf,'Position');
set(0,'Units','characters');
scrnsz=get(0,'ScreenSize');
set(0,'Units','pixels');
newx = pos(1) + 90;
newy = pos(2);

if newx > (scrnsz(3) - 76)
    newx = pos(1) - 76;
end


% Launch a new figure for the help page
figure('Units','characters','Position',[newx newy 95 24],'Color',[1 0 1], ...
                'Name','GXB/SAB Help','NumberTitle','off','MenuBar','none','Resize','off');
uipanel('Title','Spectrometer Switching GUI Help','units','characters', ...
           'Position',[0 0 95 24],'BorderType','none', ...
            'FontSize',15,'BackgroundColor',[0.85 0.85 0.85],'HighlightColor','white', ...
            'BorderWidth',1,'TitlePosition','centertop');


% All the text nonsense
props={'Style','text','HorizontalAlignment','left','units','characters'};
uicontrol(props{:},'String','How do I go down the Gun Spectrometer Line?', ...
           'FontSize',14,'FontWeight','bold','Position',[2 19 73 2.8],'BackgroundColor',[0.85 0.85 0.85]); 
uicontrol(props{:},'String','When you hit the BXG ON/OFF button, BXG will be turned on and ramped up so you can go down the spectrometer line.  When you hit this button to turn BXG off, it will degauss and then DAC zero BXG for normal running.', ...
           'FontSize',12,'FontWeight','normal','Position',[5 14 85 6],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String','How do I go down the Injector Spectrometer Line or Scale Magnets?', ...
           'FontSize',14,'FontWeight','bold','Position',[2 10 93 3],'BackgroundColor',[0.85 0.85 0.85]);
uicontrol(props{:},'String',['During normal running, BX01 is On.  When you hit the BX01 ON/OFF button, BX01 will be degaussed and then turned off.  This allows you to go down the Spectrometer line.'...
    char(10) char(13) char(10) char(13) 'IF DESIRED, the Scale Magnets button can additionally scale BX01/02 based on new BC1 energy'],  ...      
           'FontSize',12,'FontWeight','normal','Position',[5 -1 85 10],'BackgroundColor',[0.85 0.85 0.85]);

       
       
       
  
