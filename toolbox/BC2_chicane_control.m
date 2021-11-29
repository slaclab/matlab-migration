function varargout = BC2_chicane_control(varargin)
% BC2_CHICANE_CONTROL M-file for BC2_chicane_control.fig
%      BC2_CHICANE_CONTROL, by itself, creates a new BC2_CHICANE_CONTROL or
%      raises the existing
%      singleton*.
%
%      H = BC2_CHICANE_CONTROL returns the handle to a new
%      BC2_CHICANE_CONTROL or the handle to
%      the existing singleton*.
%
%      BC2_CHICANE_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BC2_CHICANE_CONTROL.M with the given input arguments.
%
%      BC2_CHICANE_CONTROL('Property','Value',...) creates a new BC2_CHICANE_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before BC2_chicane_control_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BC2_chicane_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help BC2_chicane_control

% Last Modified by GUIDE v2.5 18-Oct-2011 16:43:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BC2_chicane_control_OpeningFcn, ...
                   'gui_OutputFcn',  @BC2_chicane_control_OutputFcn, ...
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


% --- Executes just before BC2_chicane_control is made visible.
function BC2_chicane_control_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

handles.dirstr = [getenv('MATLABDATAFILES') '/script/'];
handles.save_cmnd = ['save ' handles.dirstr 'BC2_chicane_control.mat QBDES_sav sav_date'];
handles.load_cmnd = ['load ' handles.dirstr 'BC2_chicane_control.mat'];
if ~exist([handles.dirstr 'BC2_chicane_control.mat'],'file')
    QBDES_sav(1:6) = [0 0 0 0 0 0];
    sav_date = '(none)';
    eval(handles.save_cmnd)
else
    eval(handles.load_cmnd)
end
set(handles.SAVDATE,'String',sav_date)

%handles.beamOffPV='MPS:IN20:1:SHUTTER_TCTL';
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
handles.r56max = 50;        % max. R56 (mm)
handles.r56min =  0;        % min. R56 (mm)
handles.energymax = 7.000;  % max. e- energy (GeV)
handles.energymin = 0.100;  % min. e- energy (GeV)
set(handles.R56SLIDER,'Max',handles.r56max);
set(handles.R56SLIDER,'Min',handles.r56min);
set(handles.R56SLIDER,'SliderStep',[0.5 5]/(handles.r56max-handles.r56min));
set(handles.R56MAX,'String',handles.r56max);
set(handles.R56MIN,'String',handles.r56min);
handles.R56_pv    = 'SIOC:SYS0:ML00:AO119';         % operating point BC2 R56 target value (mm)
handles.Energy_pv = 'SIOC:SYS0:ML00:AO124';         % operating point BC2 energy target value (GeV)
handles.r56    = abs(lcaGet(handles.R56_pv)/1E3);   % read OP target value for BC2 R56 (mm -> m)
handles.energy = lcaGet(handles.Energy_pv);         % read OP target value for BC2 energy (GeV)
set(handles.R56DES,'String',handles.r56*1E3);
set(handles.ENERGY,'String',handles.energy);
set(handles.R56SLIDER,'Value',handles.r56*1E3)
guidata(hObject, handles);
act_trim = 0;
calc_all(handles,act_trim,hObject)

% UIWAIT makes BC2_chicane_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BC2_chicane_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


function calc_all(handles,act_trim,hObject)

handles.BC2_pv    = 'BEND:LI24:790';            % BC2 chicane main bend [kG-m]
handles.BX21T_pv  = 'BTRM:LI24:720';            % BX21 trim coil [main-coil Amperes]
handles.BX23T_pv  = 'BTRM:LI24:810';            % BX23 trim coil [main-coil Amperes]
handles.BX24T_pv  = 'BTRM:LI24:880';            % BX24 trim coil [main-coil Amperes]
handles.CQ21_pv   = 'QUAD:LI24:740';            % BC2 1st tweaker quad [kG]
handles.CQ22_pv   = 'QUAD:LI24:860';            % BC2 2nd tweaker quad [kG]
handles.XMOVD_pv  = 'BMLN:LI24:805:MOTR.VAL';   % BC2 chicane stage desired position [mm]
handles.XMOVA_pv  = 'BMLN:LI24:805:LVPOS';      % BC2 chicane stage actual LVDT position [mm]
handles.phase_pv  = 'SIOC:SYS0:ML00:AO063';     % beam phase prior to BC1 [deg-2856MHz] (move PDES more neg. if |R56| decreases)
handles.Q24601_pv = 'QUAD:LI24:601';            % Q24601 quad PV
handles.Q24701_pv = 'QUAD:LI24:701';            % Q24701 quad PV
handles.QM21_pv   = 'QUAD:LI24:713';            % QM21 quad PV
handles.QM22_pv   = 'QUAD:LI24:892';            % QM22 quad PV
handles.Q24901_pv = 'QUAD:LI24:901';            % Q24901 quad PV

handles.bact     = lcaGet([handles.BC2_pv   ':BACT']);
handles.bdes     = lcaGet([handles.BC2_pv   ':BDES']);
handles.r56      = str2double(get(handles.R56DES,'String'))/1E3;
handles.energy   = str2double(get(handles.ENERGY,'String'));
if handles.bdes<=0.02
  handles.bc2on  = 0;
else
  handles.bc2on  = 1;
end

%[BDES,xpos,dphi] = BC_adjust('BC2',handles.r56,handles.energy); % Return absolute phase delay
[BDES,xpos,dphi] = BC2_adjust(handles.r56,handles.energy); % Return absolute phase delay
BDES(5:8)=0;  % stop adjusting Q24701 - Q24901 (causing more trouble than good - 6/15/08 - PE)
handles.q24701bdes = lcaGet([handles.Q24701_pv ':BDES']);
handles.qm21bdes = lcaGet([handles.QM21_pv ':BDES']);
handles.qm22bdes = lcaGet([handles.QM22_pv ':BDES']);
handles.q24901bdes = lcaGet([handles.Q24901_pv ':BDES']);
if abs(handles.qm22bdes)<2                  % if QM22 is effectively OFF...
  handles.emitmode = 1;                     % flag we are in emittance mode
  set(handles.EMIT_PANEL,'Visible','on')
  set(handles.SETUPEMIT,'String','emit-mode','Value',1,'BackgroundColor','magenta');
else
  handles.emitmode = 0;
  set(handles.EMIT_PANEL,'Visible','off')
  set(handles.SETUPEMIT,'String','setup emit','Value',0,'BackgroundColor','green');
end
drawnow

if act_trim
% turn off BC2 energy feedback
  iw = write_message('BC2 feedback switched OFF','MESSAGE',handles);
  fdbkList={ ...
      'SIOC:SYS0:ML00:AO023'; ...       % turn off BC2 energy feedback
      'FBCK:LNG4:1:ENABLE'; ...         % turn off EPICS BC2 energy feedback
      'FBCK:LNG5:1:ENABLE'; ...         % turn off EPICS BC2 energy feedback
      'FBCK:LNG6:1:ENABLE'; ...         % turn off EPICS BC2 energy feedback
      'SIOC:SYS0:ML00:AO294'; ...       % turn off Joe's BC2 energy feedback
      'SIOC:SYS0:ML00:AO295'; ...       % turn off Joe's BC2 energy feedback
      'FBCK:FB04:LG01:STATE'; ...       % New fast 6x6 feedback
      };
  lcaPut(fdbkList,0);                   % turn off feedbacks

% Close Pockels cell shutter:
  iw = write_message('Beam OFF - Pockels cell shutter closed (disabled)','MESSAGE',handles);
  shutter_open = lcaGet(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of Pockels cell shutter
  lcaPut(handles.beamOffPV,0);              % disable Pockels cell laser shutter open-trigger to inhibit e- beam

% set BC2 mover to new position:
  iw = write_message(sprintf('Beam OFF - BC2 mover set to %5.1f mm',xpos*1E3),'MESSAGE',handles);
  lcaPutNoWait(handles.XMOVD_pv,xpos*1E3,'double'); % set abs position for BC2 chicane mover
  lcaDelay(0.0000001);                              % delay is just for the NoWait above

% shift injector RF_ref_phase and its tolerances:
  phi = -dphi;                                % (minus for MALAB variable)
  iw = write_message(sprintf('Beam OFF - adjusting RF_ref_setpoint to %5.1f deg (& tols)',phi),'MESSAGE',handles);
  lcaPut(handles.phase_pv,phi);                     % act_trim (set PDES - dPDES) for pre-BC2 beam phase (minus for MALAB variable)

  if abs(BDES(1)) < abs(handles.bdes)               % if reducing main supply setting...
    BMAX = lcaGet([handles.BC2_pv   ':BDES.HOPR']); % uncomment when BMAX is accurate (new supply)
%    BMAX = 5.0;                                     % temporary until new BC2 supply installed (~225 A)

    iw = write_message('Beam OFF - trimming BC2 main supply to BMAX for STDZ','MESSAGE',handles);
    trim_magnet(handles.BC2_pv,BMAX,'T');           % set BC2 main supply to max for 10 sec

    iw = write_message('Beam OFF - pause for 10 sec at BMAX for STDZ','MESSAGE',handles);
    pause(10)

    iw = write_message('Beam OFF - trimming BC2 main supply to zero for STDZ','MESSAGE',handles);
    trim_magnet(handles.BC2_pv,0,'T');              % set BC2 supply to zero for 5 sec

    if BDES(1) <= 0
      iw = write_message('Beam OFF - DAC-zeroing BC2 main supply','MESSAGE',handles);
      lcaPut([handles.BC2_pv ':CTRL'],'DAC_ZERO');
      pause(5)
      iw = write_message('Beam OFF - writing BC2 BACT -> BDES','MESSAGE',handles);
      bact = lcaGet([handles.BC2_pv   ':BACT']);
      lcaPut([handles.BC2_pv ':BDES'],bact);        % keep BC2 readback in tolerance by BACT -> BDES
      handles.bc2on  = 0;
    else
      handles.bc2on  = 1;
      pause(5)
    end
  end
  if BDES(1) > 0
    iw = write_message(sprintf('Beam OFF - trimming BC2 BDES to %7.4f kG-m',BDES(1)),'MESSAGE',handles);
    trim_magnet(handles.BC2_pv,BDES(1),'T');        % act & trim BC2 main supply, if not to be left OFF
    handles.bc2on  = 1;
  end

  iw = write_message('Beam OFF - setting BC2 trim & quad supplies to new settings','MESSAGE',handles);
  pvs = {handles.BX21T_pv; handles.BX23T_pv; handles.BX24T_pv; handles.Q24701_pv; handles.QM21_pv; handles.QM22_pv; handles.Q24901_pv};
  BDESt = [BDES(2:4) BDES(5)+handles.q24701bdes BDES(6)+handles.qm21bdes BDES(7)+handles.qm22bdes BDES(8)+handles.q24901bdes];
  trim_magnet(pvs,BDESt,'T');           % act & trim 3 BTRMs + 4 quads (not Q21201)    

  n={handles.BC2_pv;handles.Q24701_pv;handles.QM21_pv;handles.QM22_pv;handles.Q24901_pv};
  lcaPut(strcat(n,':EDES'),handles.energy); % Set EDES PVs
  
%  iw = write_message('Beam OFF - re-GOLDing L2 SBST phases','MESSAGE',handles);
%  d = zero_SCP_phases('L2',-[dphi dphi dphi dphi]); % re-GOLD L2 SBST phases to accomodate "dphi" phase shift earlier
  if handles.bc2on
    gain = 0.5;
    iw = write_message(sprintf('Beam OFF - setting BC2 feedback gain to %4.2f',gain),'MESSAGE',handles);
    lcaPut(fdbkList(1),gain);                          % restore BC2 feedback gain
    warndlg('BC2 feedback loop may need to be enabled again.','WARNING')
  else
    iw = write_message('Beam OFF - disabling BC2 feedback','MESSAGE',handles);
    lcaPut(fdbkList,0);                                 % turn feedbacks off
%}
  end

% Now wait for BC2 mover to converge to its proper position...
  for j = 1:40
    xpos_act = lcaGet(handles.XMOVA_pv);                % read BC2 LVDT position (mm)
    if abs(xpos_act - xpos*1E3) < 5
      iok = 1;
      break
    else
      if j==40
        iw = write_message('BC2 mover is not converging - beam left OFF','MESSAGE',handles);
        iok = 0;
        break
      end
      iw = write_message(sprintf('Waiting for BC2 mover: %5.1f mm should be %5.1f mm',xpos_act,xpos*1E3),'MESSAGE',handles);
      pause(3)
    end
  end
  if iok
    iw = write_message('All finished - Pockels cell shutter restored','MESSAGE',handles);
    lcaPut(handles.beamOffPV,shutter_open);       % restore state of Pockels cell shutter
  end
end

handles.bact       = lcaGet([handles.BC2_pv    ':BACT']);   % read final BACT (kG-m)
%[BDESf,xposf,dphif,thetaf,etaf,r56f] = BC_adjust('BC2',handles.r56,handles.energy,handles.bact); % update actual R56 (r56f)
[BDESf,xposf,dphif,thetaf,etaf,r56f] = BC2_adjust(handles.r56,handles.energy,handles.bact); % update actual R56 (r56f)
str = sprintf('%5.2f',r56f*1E3);
set(handles.R56ACT,'String',str);

handles.btrm1act   = lcaGet([handles.BX21T_pv  ':BACT']);
handles.btrm3act   = lcaGet([handles.BX23T_pv  ':BACT']);
handles.btrm4act   = lcaGet([handles.BX24T_pv  ':BACT']);
handles.cq21act    = lcaGet([handles.CQ21_pv   ':BACT']);
handles.cq22act    = lcaGet([handles.CQ22_pv   ':BACT']);
handles.q24701bact = lcaGet([handles.Q24701_pv ':BACT']);
handles.qm21bact   = lcaGet([handles.QM21_pv   ':BACT']);
handles.qm22bact   = lcaGet([handles.QM22_pv   ':BACT']);
handles.q24901bact = lcaGet([handles.Q24901_pv ':BACT']);
handles.xact       = lcaGet(handles.XMOVA_pv);       % read LVDT pos. of BC2 (mm)

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
str = sprintf('%5.1f',xpos*1E3);
set(handles.XDES,'String',str);
str = sprintf('%5.1f',handles.xact);
set(handles.XACT,'String',str);
str = sprintf('%6.3f',handles.cq21act);
set(handles.CQ21ACT,'String',str);
str = sprintf('%6.3f',handles.cq22act);
set(handles.CQ22ACT,'String',str);

str = sprintf('%6.3f',handles.q24701bact);
set(handles.Q24701,'String',str);
str = sprintf('%6.3f',handles.qm21bact);
set(handles.QM21,'String',str);
str = sprintf('%6.3f',handles.qm22bact);
set(handles.QM22,'String',str);
str = sprintf('%6.3f',handles.q24901bact);
set(handles.Q24901,'String',str);

str = sprintf('%6.3f',handles.q24701bdes+BDES(5));
set(handles.Q24701NEW,'String',str);
str = sprintf('%6.3f',handles.qm21bdes+BDES(6));
set(handles.QM21NEW,'String',str);
str = sprintf('%6.3f',handles.qm22bdes+BDES(7));
set(handles.QM22NEW,'String',str);
str = sprintf('%6.3f',handles.q24901bdes+BDES(8));
set(handles.Q24901NEW,'String',str);

set(handles.DATE,'String',get_time)
drawnow
guidata(hObject, handles);


function R56SLIDER_Callback(hObject, eventdata, handles)
handles.r56 = get(hObject,'Value')/1E3;
set(handles.R56DES,'String',handles.r56*1E3);
guidata(hObject, handles);
act_trim = 0;
calc_all(handles,act_trim,hObject)


function R56DES_Callback(hObject, eventdata, handles)
handles.r56 = str2double(get(hObject,'String'))/1E3;
if (handles.r56*1E3>handles.r56max)
  errordlg(sprintf('R56 must be <= %5.2f mm',handles.r56max),'Error');
  set(handles.R56DES,'String',handles.r56max);
  handles.r56 = handles.r56max/1E3;
end
if (handles.r56*1E3<handles.r56min)
  errordlg(sprintf('R56 must be >= %5.2f mm',handles.r56min),'Error');
  set(handles.R56DES,'String',handles.r56min);
  handles.r56 = handles.r56min/1E3;
end
set(handles.R56SLIDER,'Value',handles.r56*1E3)
act_trim = 0;
calc_all(handles,act_trim,hObject)
guidata(hObject, handles);


function ENERGY_Callback(hObject, eventdata, handles)
handles.energy = str2double(get(hObject,'String'));
if (handles.energy<handles.energymin)
  errordlg(sprintf('Energy must be >= %5.3f GeV',handles.energymin),'Error');
  set(handles.ENERGY,'String',handles.energymin);
  handles.energy = handles.energymin;
end
if (handles.energy>handles.energymax)
  errordlg(sprintf('Energy must be <= %5.3f GeV',handles.energymax),'Error');
  set(handles.ENERGY,'String',handles.energymax);
  handles.energy = handles.energymax;
end
act_trim = 0;
calc_all(handles,act_trim,hObject)
guidata(hObject, handles);


function UPDATE_Callback(hObject, eventdata, handles)
act_trim  = 0;
calc_all(handles,act_trim,hObject)


function ACT_TRIM_Callback(hObject, eventdata, handles)
yn = questdlg('This will put the Pockels cell shutter IN, change the BC2 chicane position, adjust its magnet settings, change the injector & L2 phases, and then open the Pockels cell shutter when done.  Do you want to continue?','CAUTION');
if ~strcmp(yn,'Yes')
  return
end
if handles.emitmode==1
  warndlg('Cannot turn back ON BC2 until switched out of emittance measurement mode (i.e., must have QM22 |BDES| > 2).','STILL IN EMIT-MODE')
  return
end
act_trim  = 1;
calc_all(handles,act_trim,hObject)


function SETUPEMIT_Callback(hObject, eventdata, handles)
if handles.bc2on==1                             % if BC2 is still ON...
  set(hObject,'Value',0)  
  warndlg('Cannot setup for emittance measurement until BC2 is OFF (BX22 BDES <= 0.02).  Please first turn it OFF','NEED BC2 OFF FIRST')
  return
end
if get(hObject,'Value')==1                      % if switching to emit-meas mode...
  yn = questdlg('This will set and TRIM several BC2-area quads to new BDES values for OTR21 emittance measurements.  Do you really want to do this?','CAUTION','Yes');
  if ~strcmp('Yes',yn)
    set(hObject,'Value',0)
    return
  end
  handles.emitmode = 1;                         % flag we are in emittance mode
  set(handles.EMIT_PANEL,'Visible','on')
  set(hObject,'String','emit-mode');
  set(hObject,'BackgroundColor','magenta');
  shutter_open = lcaGet(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of Pockels cell shutter
%*  lcaPut(handles.beamOffPV,0);         % disable Pockels cell laser shutter open-trigger to inhibit e- beam
  iw = write_message('Beam OFF - setting quads to emit-mode - please wait...','MESSAGE',handles);
  QBDES_sav(1) = lcaGet([handles.Q24601_pv ':BDES']);   % save Q24601 BDES prior to emit-mode setting [kG]
  QBDES_sav(2) = lcaGet([handles.Q24701_pv ':BDES']);   % save Q24701 BDES prior to emit-mode setting [kG]
  QBDES_sav(3) = lcaGet([handles.QM21_pv ':BDES']);     % save QM21 BDES prior to emit-mode setting [kG]
  QBDES_sav(4) = lcaGet([handles.CQ21_pv ':BDES']);     % save CQ21 BDES prior to emit-mode setting [kG]
  QBDES_sav(5) = lcaGet([handles.QM22_pv ':BDES']);     % save QM22 BDES prior to emit-mode setting [kG]
  QBDES_sav(6) = lcaGet([handles.Q24901_pv ':BDES']);   % save Q24901 BDES prior to emit-mode setting [kG]
  sav_date = get_time;                          % time/date of save
  eval(handles.save_cmnd);                      % save quad BDES values to file
  set(handles.SAVDATE,'String',sav_date)                % show save date
  QBDES_emt(1) =  15.224*handles.energy/4.300;  % Q24601 BDES [kG] (4.155 GeV)
  QBDES_emt(2) = -15.520*handles.energy/4.300;  % Q24701 BDES [kG] (4.300 GeV)
  QBDES_emt(3) = 26.494*handles.energy/4.300;   % QM21 BDES [kG] (4.300 GeV)
  QBDES_emt(4) =  0;                            % CQ21 BDES set to 0
  QBDES_emt(5) =  -1;                           % QM22 BDES [kG] (4.300 GeV) - must be abs(B)<2 to flag state!
  handles.qm22bdes = -1;                        % flags state (emit-mode when =0)
  lcaPut([handles.QM22_pv ':BDES'],QBDES_emt(5));       % temporary for testing? (remove when Put's active?)
  QBDES_emt(6) = -5.222*handles.energy/4.300;   % Q24901 BDES [kG] (4.300 GeV)
  set(handles.Q24601NOM,'String',QBDES_sav(1))
  set(handles.Q24701NOM,'String',QBDES_sav(2))
  set(handles.QM21NOM,'String',QBDES_sav(3))
  set(handles.CQ21NOM,'String',QBDES_sav(4))
  set(handles.QM22NOM,'String',QBDES_sav(5))
  set(handles.Q24901NOM,'String',QBDES_sav(6))
  set(handles.Q24601EMT,'String',QBDES_emt(1))
  set(handles.Q24701EMT,'String',QBDES_emt(2))
  set(handles.QM21EMT,'String',QBDES_emt(3))
  set(handles.CQ21EMT,'String',QBDES_emt(4))
  set(handles.QM22EMT,'String',QBDES_emt(5))
  set(handles.Q24901EMT,'String',QBDES_emt(6))
  drawnow
%*  trim_magnet(handles.Q24601_pv,QBDES_emt(1),'P');     % set Q24601 to emit-mode BDES and trim
%*  trim_magnet(handles.Q24701_pv,QBDES_emt(2),'P');     % set Q24701 to emit-mode BDES and trim
%*  trim_magnet(handles.QM21_pv,QBDES_emt(3),'P');       % set QM21 to emit-mode BDES and trim
%*  trim_magnet(handles.CQ21_pv,QBDES_emt(4),'P');       % set CQ21 to emit-mode BDES and trim
%*  trim_magnet(handles.QM22_pv,QBDES_emt(5),'P');       % set QM22 to emit-mode BDES and trim
%*  trim_magnet(handles.Q24901_pv,QBDES_emt(6),'P');     % set Q24901 to emit-mode BDES and trim
%*  pause(1)
%*  lcaPut(handles.beamOffPV,shutter_open);      % restore Pockels cell laser shutter
  iw = write_message('Pockels cell shutter restored - done.','MESSAGE',handles);
else                                            % if switching back out of emit-meas mode...
  yn = questdlg('This will set and trim several BC2-area quads to undo the OTR21 emittance measurement setup.  Do you really want to do this?','CAUTION','Yes');
  if ~strcmp('Yes',yn)
    set(hObject,'Value',1)
    return
  end
  handles.emitmode = 0;                         % flag we are out of emittance mode
  set(handles.EMIT_PANEL,'Visible','off')
  set(hObject,'String','setup emit');
  set(hObject,'BackgroundColor','green');
  shutter_open = lcaGet(handles.beamOffPV,0,'double');      % save state (Opened=1/Closed=0) of Pockels cell shutter
%*  lcaPut(handles.beamOffPV,0);                    % disable Pockels cell laser shutter open-trigger to inhibit e- beam
  iw = write_message('Beam OFF - setting quads to normal-mode - please wait...','MESSAGE',handles);
  eval(handles.load_cmnd);                                  % load saved quad BDES values from file
%*  pause(1)
%*  trim_magnet(handles.Q24601_pv,QBDES_sav(1),'P');     % set Q24601 to saved BDES and trim
%*  trim_magnet(handles.Q24701_pv,QBDES_sav(2),'P');     % set Q24701 to saved BDES and trim
%*  trim_magnet(handles.QM21_pv,QBDES_sav(3),'P');       % set QM21 to saved BDES and trim
%*  trim_magnet(handles.CQ21_pv,QBDES_sav(4),'P');       % set CQ21 to savedBDES and trim
%*  trim_magnet(handles.QM22_pv,QBDES_sav(5),'P');       % set QM22 to saved BDES and trim
%*  trim_magnet(handles.Q24901_pv,QBDES_sav(6),'P');     % set Q24901 to saved BDES and trim
%*  pause(1)
%*  lcaPut(handles.beamOffPV,shutter_open);         % restore Pockels cell laser shutter
  iw = write_message('Beam back ON - done.','MESSAGE',handles);
end
guidata(hObject, handles);


% --- Executes on button press in BC2OFF.
function BC2OFF_Callback(hObject, eventdata, handles)
yn = questdlg('Caution, this will temporaily switch off beam and turn off and straighten out the BC2 chicane.  Do you really want to do this?','CAUTION');
if ~strcmp(yn,'Yes');
  return
end
handles.r56 = 0;
set(handles.R56SLIDER,'Value',handles.r56*1E3)
set(handles.R56DES,'String',handles.r56*1E3)
act_trim  = 1;
calc_all(handles,act_trim,hObject)
guidata(hObject, handles);


% --- Executes on button press in BC2ON.
function BC2ON_Callback(hObject, eventdata, handles)
yn = questdlg('Caution, this will turn ON and displace the BC2 chicane to its nominal settings.  Do you really want to do this?','CAUTION');
if ~strcmp(yn,'Yes');
  return
end
handles.r56    = abs(lcaGet(handles.R56_pv)/1E3);   % read OP target value for BC2 R56 (mm -> m)
handles.energy = lcaGet(handles.Energy_pv);         % read OP target value for BC2 energy (GeV)
set(handles.R56SLIDER,'Value',handles.r56*1E3)
set(handles.R56DES,'String',handles.r56*1E3);
set(handles.ENERGY,'String',handles.energy);
act_trim  = 1;
calc_all(handles,act_trim,hObject)
guidata(hObject, handles);


% --- Executes on button press in setLEMbutton.
function setLEMbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setLEMbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.MESSAGE,'String','Getting BC2 LEM Energy value from text field');
BC2LEM_eng = str2double(get(handles.ENERGY,'String'));
set(handles.MESSAGE,'String','Copying LEM Engy to Matlab Support PV');
model_energySetPoints(BC2LEM_eng,4);
set(handles.MESSAGE,'String','Finished copying BC2 LEM Engy to Matlab PV');


% ----------------------------------------------------------
% Create functions and inactive edit uicontrol callbacks
% ----------------------------------------------------------

function R56SLIDER_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function R56DES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function BTRM1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3_Callback(hObject, eventdata, handles)


function BTRM3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4_Callback(hObject, eventdata, handles)


function BTRM4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function XDES_Callback(hObject, eventdata, handles)


function XDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function phase_Callback(hObject, eventdata, handles)


function phase_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ21ACT_Callback(hObject, eventdata, handles)


function CQ21ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ22ACT_Callback(hObject, eventdata, handles)


function CQ22ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BDES_Callback(hObject, eventdata, handles)


function BDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHASE_Callback(hObject, eventdata, handles)


function PHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BACT_Callback(hObject, eventdata, handles)


function BACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM1ACT_Callback(hObject, eventdata, handles)


function BTRM1ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM3ACT_Callback(hObject, eventdata, handles)


function BTRM3ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BTRM4ACT_Callback(hObject, eventdata, handles)


function BTRM4ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function XACT_Callback(hObject, eventdata, handles)


function XACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function R56ACT_Callback(hObject, eventdata, handles)


function R56ACT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24701_Callback(hObject, eventdata, handles)


function Q24701_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24701NEW_Callback(hObject, eventdata, handles)


function Q24701NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM21_Callback(hObject, eventdata, handles)


function QM21_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM21NEW_Callback(hObject, eventdata, handles)


function QM21NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM22_Callback(hObject, eventdata, handles)


function QM22_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM22NEW_Callback(hObject, eventdata, handles)


function QM22NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24901_Callback(hObject, eventdata, handles)


function Q24901_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24901NEW_Callback(hObject, eventdata, handles)


function Q24901NEW_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24601EMT_Callback(hObject, eventdata, handles)


function Q24601EMT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24701EMT_Callback(hObject, eventdata, handles)


function Q24701EMT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM21EMT_Callback(hObject, eventdata, handles)


function QM21EMT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ21EMT_Callback(hObject, eventdata, handles)


function CQ21EMT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM22EMT_Callback(hObject, eventdata, handles)


function QM22EMT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24901EMT_Callback(hObject, eventdata, handles)


function Q24901EMT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24601NOM_Callback(hObject, eventdata, handles)


function Q24601NOM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24701NOM_Callback(hObject, eventdata, handles)


function Q24701NOM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM21NOM_Callback(hObject, eventdata, handles)


function QM21NOM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CQ21NOM_Callback(hObject, eventdata, handles)


function CQ21NOM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QM22NOM_Callback(hObject, eventdata, handles)


function QM22NOM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Q24901NOM_Callback(hObject, eventdata, handles)


function Q24901NOM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
