function varargout = und_quad_align(varargin)
% UND_QUAD_ALIGN M-file for und_quad_align.fig
%      UND_QUAD_ALIGN, by itself, creates a new UND_QUAD_ALIGN or raises
%      the existing
%      singleton*.
%
%      H = UND_QUAD_ALIGN returns the handle to a new UND_QUAD_ALIGN or the
%      handle to
%      the existing singleton*.
%
%      UND_QUAD_ALIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UND_QUAD_ALIGN.M with the given input arguments.
%
%      UND_QUAD_ALIGN('Property','Value',...) creates a new UND_QUAD_ALIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before und_quad_align_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to und_quad_align_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help und_quad_align

% Last Modified by GUIDE v2.5 03-Feb-2009 13:14:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @und_quad_align_OpeningFcn, ...
                   'gui_OutputFcn',  @und_quad_align_OutputFcn, ...
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



% --- Executes just before und_quad_align is made visible.
function und_quad_align_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to und_quad_align (see VARARGIN)

global modelSource modelOnline
modelSource='EPICS';modelOnline=0;
set(handles.MSG,'String','Ready')
drawnow
handles.fakedata = get(handles.FAKE,'Value');
handles.do_xycor = get(handles.DO_XYCOR,'Value');
set(handles.DO_QUADS,'Value',1)
set(handles.WRTBEAM,'Visible','on') % 'on' goes with handles.DO_QUADS=1
set(handles.DO_XYCOR,'Value',0)
set(handles.DO_GIRDER,'Value',0)
set(handles.GIRDER,'String','32')
handles.girder = str2double(get(handles.GIRDER,'String'));
handles.mode = 1;   % do quad offsets by default
set(handles.XPLANE,'Visible','off')
set(handles.YPLANE,'Visible','off')
handles.have_data = 0;
handles.saved = 0;
handles.q1 = str2double(get(handles.Q1,'String'));
handles.qN = str2double(get(handles.QN,'String'));
handles.Nmagnets_selected = handles.qN - handles.q1 + 1;
handles.dB_B = str2double(get(handles.DB_B,'String'));
handles.dBDES = str2double(get(handles.DBDES,'String'));    % dBDES is normalized to BMAX (0 < dBDES <= 1)
handles.dMOV = str2double(get(handles.DMOV,'String'));      % mover tweak (mm)
handles.navg = str2double(get(handles.NAVG,'String'));
handles.ibpm1 = str2double(get(handles.BPM1,'String'));
handles.ibpm2 = str2double(get(handles.BPM2,'String'));
handles.wrtbeam = get(handles.WRTBEAM,'Value');
handles.showolddata = get(handles.SHOWOLDDATA,'Value');
handles.X1 = 0;
handles.X2 = 0;
handles.X3 = 0;
handles.xpos = 0;
ixy = get(handles.X_OR_Y,'Value');
xy  = get(handles.X_OR_Y,'String');
handles.x_or_y = lowcase(cell2mat(xy(ixy)));
handles.amplitude = get(handles.AMPLITUDE,'Value');
handles.traj_j = get(handles.TRAJ_J,'Value');
set(handles.TRAJ_SETTING,'String',num2str(handles.traj_j))
handles.E0  = lcaGetSmart('BEND:DMP1:400:BDES');    % beam energy [GeV]
handles.ixy = 1;    % set for X-plane traj-plots initially
set(handles.XPLANE,'Value',handles.ixy);
set(handles.YPLANE,'Value',not(handles.ixy));
set(handles.ENERGY,'String',sprintf('Energy=%5.2f GeV',handles.E0))
set(handles.TRAJ_J,'Min',1)
set(handles.TRAJ_J,'Max',handles.qN-handles.q1+1)
if handles.qN-handles.q1 == 0
  set(handles.TRAJ_J,'Visible','off')
  set(handles.QMIN,'Visible','off')
  set(handles.QMAX,'Visible','off')
  set(handles.TRAJ_SETTING,'Visible','off')
else
  set(handles.TRAJ_J,'Visible','on')
  set(handles.QMIN,'Visible','on')
  set(handles.QMAX,'Visible','on')
  set(handles.TRAJ_SETTING,'Visible','on')
  set(handles.TRAJ_J,'SliderStep',[1 5]/(handles.qN-handles.q1));
end
handles.meas_done = 0;

handles.BPM_pvs   =   {'BPMS:LTU1:910'  % need to change handles.BPM_ioffset when adding BPMs to top of array (quad-180 is at BPM-190, for offset = 3)
                       'BPMS:LTU1:960'
                       'BPMS:UND1:100'
                       'BPMS:UND1:190'  % this is where QUAD 180 is located (handles.BPM_ioffset=3 here)
                       'BPMS:UND1:290'
                       'BPMS:UND1:390'
                       'BPMS:UND1:490'
                       'BPMS:UND1:590'
                       'BPMS:UND1:690'
                       'BPMS:UND1:790'
                       'BPMS:UND1:890'
                       'BPMS:UND1:990'
                       'BPMS:UND1:1090'
                       'BPMS:UND1:1190'
                       'BPMS:UND1:1290'
                       'BPMS:UND1:1390'
                       'BPMS:UND1:1490'
                       'BPMS:UND1:1590'
                       'BPMS:UND1:1690'
                       'BPMS:UND1:1790'
                       'BPMS:UND1:1890'
                       'BPMS:UND1:1990'
                       'BPMS:UND1:2090'
                       'BPMS:UND1:2190'
                       'BPMS:UND1:2290'
                       'BPMS:UND1:2390'
                       'BPMS:UND1:2490'
                       'BPMS:UND1:2590'
                       'BPMS:UND1:2690'
                       'BPMS:UND1:2790'
                       'BPMS:UND1:2890'
                       'BPMS:UND1:2990'
                       'BPMS:UND1:3090'
                       'BPMS:UND1:3190'
                       'BPMS:UND1:3290'
                       'BPMS:UND1:3390'
                       'BPMS:DMP1:299'
                       'BPMS:DMP1:381'
                       'BPMS:DMP1:398'};

handles.QUAD_pvs   =  {'QUAD:UND1:180'
                       'QUAD:UND1:280'
                       'QUAD:UND1:380'
                       'QUAD:UND1:480'
                       'QUAD:UND1:580'
                       'QUAD:UND1:680'
                       'QUAD:UND1:780'
                       'QUAD:UND1:880'
                       'QUAD:UND1:980'
                       'QUAD:UND1:1080'
                       'QUAD:UND1:1180'
                       'QUAD:UND1:1280'
                       'QUAD:UND1:1380'
                       'QUAD:UND1:1480'
                       'QUAD:UND1:1580'
                       'QUAD:UND1:1680'
                       'QUAD:UND1:1780'
                       'QUAD:UND1:1880'
                       'QUAD:UND1:1980'
                       'QUAD:UND1:2080'
                       'QUAD:UND1:2180'
                       'QUAD:UND1:2280'
                       'QUAD:UND1:2380'
                       'QUAD:UND1:2480'
                       'QUAD:UND1:2580'
                       'QUAD:UND1:2680'
                       'QUAD:UND1:2780'
                       'QUAD:UND1:2880'
                       'QUAD:UND1:2980'
                       'QUAD:UND1:3080'
                       'QUAD:UND1:3180'
                       'QUAD:UND1:3280'
                       'QUAD:UND1:3380'};

handles.BPM_ioffset = 3;    % BPM 190 is located at QUAD 180 so use this to line up above QUAD and BPM arrays
handles.nbpms  = length(handles.BPM_pvs);
handles.nquads = length(handles.QUAD_pvs);
handles.Zs  = model_rMatGet(handles.BPM_pvs,[],{},'Z')';
handles.QZs = model_rMatGet(handles.QUAD_pvs,[],{},'Z')';
handles.fdbkList={'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE'};

% Choose default command line output for und_quad_align
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes und_quad_align wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = und_quad_align_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
if handles.have_data && ~handles.saved
  save_yn = questdlg('Save last data set?','SAVE DATA?');
else
  save_yn = 'No';
end
if strcmp(save_yn,'Yes') && ~handles.fakedata
  save_data(handles)    % save last data set so it can be plotted with new data
  handles.saved = 1;
else
  disp('Not saved since this is faked data.')
end
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN') && ~handles.fakedata
  set(handles.MSG,'String','TDUND is IN - scan aborted.')
  warndlg('TDUND is IN - no beam - scan aborted.','Stopper is IN')
  set(handles.START,'Value',0)
  return
end
handles.datestr0 = get_time;
handles.E0  = lcaGetSmart('BEND:DMP1:400:BDES');    % beam energy [GeV]
handles.Brho = 33.35640952*handles.E0;
set(handles.ENERGY,'String',sprintf('Energy=%5.2f GeV',handles.E0))
set(handles.START,'BackgroundColor','white')
set(handles.MSG,'String','Started...')
drawnow
handles.Nmagnets_selected = handles.qN - handles.q1 + 1;
handles.iN = handles.q1:1:handles.qN;
handles.Xs00 = zeros(1,handles.nbpms);
handles.Ys00 = zeros(1,handles.nbpms);
handles.Xs0  = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.Ys0  = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.Xs   = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.Ys   = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.dXs0 = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.dYs0 = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.dXs  = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.dYs  = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.Xsf  = zeros(handles.Nmagnets_selected,handles.nbpms,2);
handles.Ysf  = zeros(handles.Nmagnets_selected,handles.nbpms,2);
set(handles.TRAJ_J,'Max',handles.qN-handles.q1+1)
set(handles.QMAX,'String',handles.qN-handles.q1+1)
if handles.qN-handles.q1 == 0
  set(handles.TRAJ_J,'Visible','off')
  set(handles.QMIN,'Visible','off')
  set(handles.QMAX,'Visible','off')
  set(handles.TRAJ_SETTING,'Visible','off')
else
  set(handles.TRAJ_J,'Visible','on')
  set(handles.QMIN,'Visible','on')
  set(handles.QMAX,'Visible','on')
  set(handles.TRAJ_SETTING,'Visible','on')
end
clc
handles.meas_done = 0;
guidata(hObject,handles);
fdbk_on = lcaGetSmart(handles.fdbkList,0,'double');     % get state of und feedback
lcaPutSmart(handles.fdbkList,0);                        % turn off und feedback
handles = measure_response(hObject,handles,handles.mode);   % measure response over all und quads
lcaPutSmart(handles.fdbkList,fdbk_on);                  % restore state of und feedback
handles.meas_done = 1;
set(handles.START,'BackgroundColor','green')
set(handles.START,'String','Start')
set(handles.START,'Value',0)
set(handles.MSG,'String','All done')
drawnow
guidata(hObject,handles);



function handles = measure_response(hObject,handles,mode)
handles.Xfac   = zeros(1,handles.nquads);
handles.Yfac   = zeros(1,handles.nquads);
handles.dXfac  = zeros(1,handles.nquads);
handles.dYfac  = zeros(1,handles.nquads);
handles.Xfac2  = zeros(1,handles.nquads);
handles.Yfac2  = zeros(1,handles.nquads);
handles.dXfac2 = zeros(1,handles.nquads);
handles.dYfac2 = zeros(1,handles.nquads);
handles.px     = zeros(6,handles.nquads);
handles.dpx    = zeros(6,handles.nquads);
handles.py     = zeros(6,handles.nquads);
handles.dpy    = zeros(6,handles.nquads);
handles.chisqX = zeros(1,handles.nquads);
handles.chisqY = zeros(1,handles.nquads);
if mode == 1
  Xprim = 'QUAD';    % quad gradient variation
  Yprim = 'QUAD';    % quad gradient variation
elseif mode == 2
  Xprim = 'XCOR';    % Corrector strength variation
  Yprim = 'YCOR';    % Corrector strength variation
else
  Xprim = 'QUAD';    % girder (quad) position variation
  Yprim = 'QUAD';    % girder (quad) position variation
end

[handles.Xs00,handles.Ys00,Ts00,dXs00,dYs00,dTs00,beam00,abort00] = read_orbitf(hObject,handles);  % read ref. orbit (used wrt quad offset data)

for j = 1:handles.Nmagnets_selected             % Loop over all magnets selected (QUADs or X&YCORs)

% do X first:

  Xmagname = num2str(handles.iN(j),[Xprim(1:2) '%02d']);
  set(handles.XPLANE,'Value',1)
  set(handles.YPLANE,'Value',0)
  handles.ixy = 1;
  set(handles.START,'String',[Xmagname '...'])
  PV = cell2mat(handles.QUAD_pvs(handles.iN(j)));
  Xmag_pv = strcat([Xprim ':'],PV(6:end));
  handles.Z0  = model_rMatGet(Xmag_pv,[],{},'Z');
  set(handles.TRAJ_J,'Value',j)
  handles.traj_j = j;
  set(handles.TRAJ_SETTING,'String',num2str(handles.traj_j))
  handles.ibpm = set_BPM_pointers(j,hObject, handles);
  set(handles.MSG,'String','Reading initial orbit...')
  drawnow
  if mode == 1                              % use only initial ref. orbit for quad alignment (i.e., do not retake each time)
    handles.Xs0(j,:,1) = handles.Xs00;
    handles.Ys0(j,:,1) = handles.Ys00;
    Ts0 = Ts00;
    handles.dXs0(j,:,1) = dXs00;
    handles.dYs0(j,:,1) = dYs00;
    dTs0 = dTs00;
    beam0 = beam00;
    abort = abort00;
  else
    [handles.Xs0(j,:,1),handles.Ys0(j,:,1),Ts0,dXs0(j,:,1),dYs0(j,:,1),dTs0,beam0,abort] = read_orbitf(hObject,handles);
  end
  if abort
    set(handles.START,'BackgroundColor','green')
    set(handles.START,'String','Start')
    set(handles.START,'Value',0)
    set(handles.MSG,'String',['Aborted at ' Xmagname ' due to no beam and user abort.'])
    drawnow
    return
  end
  BDES0 = lcaGetSmart(strcat(Xmag_pv,':BDES'));
  BACT0 = lcaGetSmart(strcat(Xmag_pv,':BACT'));
  if mode == 1      % if quad gradient variation...
    BDES1 = BDES0*(1-handles.dB_B/100);
    set(handles.MSG,'String',['Perturbing ' Xmagname ' to new value...'])
    drawnow
    if ~handles.fakedata
      trim_magnet(Xmag_pv,BDES1,'P');
    end
  elseif mode == 2  % if X/YCOR field variation...
    BMAX  = lcaGetSmart(strcat(Xmag_pv,':BMAX'));
    if BDES0>(BMAX-handles.dBDES*BMAX)
      BDES1 = BDES0 - handles.dBDES*BMAX;
    else
      BDES1 = BDES0 + handles.dBDES*BMAX;
    end
    set(handles.MSG,'String',['Perturbing ' Xmagname ' to new value...'])
    drawnow
    if ~handles.fakedata
      trim_magnet(Xmag_pv,BDES1,'P');
    end
  else              % if quad MOVER variation...
    [X0,Y0] = girderQUADposition(handles.iN(j));
    set(handles.MSG,'String',['Moving ' Xmagname ' to new X-position...'])
    drawnow
    if ~handles.fakedata
      girderQuadMove(handles.iN(j),handles.dMOV,0);
      girderCamWait(handles.iN(j));    
    end
  end
  set(handles.MSG,'String',['Getting model for ' Xmagname ' to all BPMs'])
  drawnow
  R = model_rMatGet(Xmag_pv,handles.BPM_pvs);
  R1s = permute(R(1,[1 2 3 4 6],:),[3 2 1]);
  R3s = permute(R(3,[1 2 3 4 6],:),[3 2 1]);
  if mode ~=3       % if QUAD or X/YCOR change...
    if ~handles.fakedata
      BACT1 = lcaGetSmart(strcat(Xmag_pv,':BACT'));
    else
      BACT1 = BDES1;  % fake magnet change
    end
    disp(sprintf('%s dBACT = %8.5f kG',Xmagname,BACT1-BACT0))
    outoftol = check_magnet({Xmag_pv},4);   % allow 4-time larger error on BDES-BACT for this tweak (but restore exactly below)
    if outoftol
      disp([Xmagname ' did not perturb to new BDES - TRIMming now'])
      set(handles.MSG,'String',[Xmagname ' did not perturb well - TRIMming to new value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Xmag_pv,BDES1,'T');
      end
    end
  else
    if ~handles.fakedata
      [X,Y] = girderQUADposition(handles.iN(j));
    else
      X = X0 + handles.dMOV;
    end
    dX = X - X0;
    disp(sprintf('%s dXMOV = %6.3f mm',Xmagname,dX))
    if abs(dX-handles.dMOV)>0.01
      disp([Xmagname ' did not move to new X-position - what to do?'])
      set(handles.MSG,'String',[Xmagname ' did not move to new X-position - what to do?'])
      drawnow      
    end
  end
  set(handles.MSG,'String','Reading kicked orbit...')
  drawnow
  pause(1)
  [handles.Xs(j,:,1),handles.Ys(j,:,1),Ts,dXs(j,:,1),dYs(j,:,1),dTs,beam,abort] = read_orbitf(hObject,handles);
  if abort
    set(handles.START,'BackgroundColor','green')
    set(handles.START,'String','Start')
    set(handles.START,'Value',0)
    set(handles.MSG,'String',['Aborted at ' Xmagname ' due to no beam and user abort.'])
    drawnow
    if ~handles.fakedata
      trim_magnet(Xmag_pv,BDES0,'T');   % restore original quad setting
    end
    disp(['Aborted at ' Xmagname ' due to no beam and user abort.  Magnet BDES restored & TRIMmed.'])
    return
  end
  [handles.Xsf(j,handles.ibpm,1),handles.Ysf(j,handles.ibpm,1),p,dp,chisq,Q] = ...
      xy_traj_fit_kick(handles.Xs(j,handles.ibpm,1),dXs(j,handles.ibpm,1),handles.Ys(j,handles.ibpm,1),dYs(j,handles.ibpm,1),handles.Xs0(j,handles.ibpm,1),handles.Ys0(j,handles.ibpm,1),R1s(handles.ibpm,:),R3s(handles.ibpm,:),handles.Zs(handles.ibpm),handles.Z0,[1 1 1 1 0 1 1]);	% fit trajectory (only x' & y' fitted)
  if mode == 1
    handles.Xfac(handles.iN(j))  =  p(5)*handles.Brho/(BACT1-BACT0) + p(1);                 % QUAD X-offset (mm)
    handles.dXfac(handles.iN(j)) =  sqrt( (dp(5)*handles.Brho/(BACT1-BACT0))^2 + dp(1)^2 ); % error bar (mm)
    handles.Yfac(handles.iN(j))  = -p(6)*handles.Brho/(BACT1-BACT0) + p(3);                 % QUAD Y-offset (mm)
    handles.dYfac(handles.iN(j)) =  sqrt( (dp(6)*handles.Brho/(BACT1-BACT0))^2 + dp(3)^2 ); % error bar (mm)
  elseif mode == 2
    handles.Xfac(handles.iN(j))  = 1E-3*p(5)*handles.Brho/(BACT1-BACT0);                    % X/YCOR scale (should be 1)
    handles.dXfac(handles.iN(j)) = 1E-3*abs(dp(5)*handles.Brho/(BACT1-BACT0));              % error bar (1)
  else
    handles.Xfac(handles.iN(j))   = -(handles.Xs(j,handles.iN(j)+handles.BPM_ioffset,1) - handles.Xs0(j,handles.iN(j)+handles.BPM_ioffset,1) - p(1) - handles.dMOV)/handles.dMOV;       % BPM calib. (should be 1)
    handles.dXfac(handles.iN(j))  = abs(sqrt(handles.dXs0(j,handles.iN(j)+handles.BPM_ioffset,1)^2 + handles.dXs(j,handles.iN(j)+handles.BPM_ioffset,1)^2 + dp(1)^2)/handles.dMOV);    % error bar (1)
    handles.Xfac2(handles.iN(j))  = p(5)*handles.Brho/((dX+1E-6)*BACT0);                 % kick angle scale
    handles.dXfac2(handles.iN(j)) = abs(dp(5)*handles.Brho/((dX+1E-6)*BACT0));           % kick angle scale error
      disp( [Xmagname sprintf(' X-BPM calib. factor = %6.3f +- %5.3f',handles.Xfac(handles.iN(j)),handles.dXfac(handles.iN(j)))] )
  end
  handles.px(:,handles.iN(j)) = p';
  handles.dpx(:,handles.iN(j)) = dp';
  handles.chisqX(handles.iN(j)) = chisq;
  handles = plot_trajectory(0,j,1,hObject,handles,handles.mode);        % plot X & Y diff. trajectory vs Z and the fitted kicks
  plot_data_vs_z(0,j,hObject,handles,handles.mode)                      % plot X & Y scale factors vs Z
  handles.have_data = 1;
  handles.saved = 0;
  if mode == 1      % if quad gradient variation...
    set(handles.MSG,'String',['Perturbing ' Xmagname ' back to initial value...'])
    drawnow
    if ~handles.fakedata
      trim_magnet(Xmag_pv,BDES0,'P');
    end
    outoftol = check_magnet({Xmag_pv},1);   % use 1-times the tols for best reset of quad
    if outoftol
      disp([Xmagname ' did not perturb back to original BDES - TRIMming now'])
      set(handles.MSG,'String',[Xmagname ' did not perturb well - TRIMming to back to initial value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Xmag_pv,BDES0,'T');
      end
    end
  elseif mode == 2  % if X/YCOR field variation...
    set(handles.MSG,'String',['Perturbing ' Xmagname ' back to initial value...'])
    drawnow
    if ~handles.fakedata
      trim_magnet(Xmag_pv,BDES0,'P');
    end
    outoftol = check_magnet({Xmag_pv},1);   % use 1-times the tols for best reset of quad
    if outoftol
      disp([Xmagname ' did not perturb back to original BDES - TRIMming now'])
      set(handles.MSG,'String',[Xmagname ' did not perturb well - TRIMming to back to initial value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Xmag_pv,BDES0,'T');
      end
    end
  else              % if quad MOVER variation...
    set(handles.MSG,'String',['Moving ' Xmagname ' back to initial X-position...'])
    drawnow
    if ~handles.fakedata
      girderQuadMove(handles.iN(j),-handles.dMOV,0);
      girderCamWait(handles.iN(j));    
    end
    [X,Y] = girderQUADposition(handles.iN(j));
    disp(sprintf('%s dXMOV = %6.3f mm',Xmagname,X-X0))
    if abs(X-X0)>0.01
      disp([Xmagname ' did not move back to original X-position - what to do?'])
      set(handles.MSG,'String',[Xmagname ' did not move back to original X-position - what to do?'])
      drawnow      
    end
  end  

% do Y next:

  if mode~=1    % don't do Y for quad offsets (changing gradient gives both X & Y offsets)
    pause(1)
    Ymagname = num2str(handles.iN(j),[Yprim(1:2) '%02d']);
    set(handles.XPLANE,'Value',0)
    set(handles.YPLANE,'Value',1)
    handles.ixy = 2;
    set(handles.START,'String',[Ymagname '...'])
    PV = cell2mat(handles.QUAD_pvs(handles.iN(j)));
    Ymag_pv = strcat([Yprim ':'],PV(6:end));
    set(handles.TRAJ_J,'Value',j)
    handles.traj_j = j;
    set(handles.TRAJ_SETTING,'String',num2str(handles.traj_j))
    handles.ibpm = set_BPM_pointers(j,hObject, handles);
    set(handles.MSG,'String','Reading initial orbit...')
    drawnow
    [handles.Xs0(j,:,2),handles.Ys0(j,:,2),Ts0,dXs0(j,:,2),dYs0(j,:,2),dTs0,beam0,abort] = read_orbitf(hObject,handles);
    if abort
      set(handles.START,'BackgroundColor','green')
      set(handles.START,'String','Start')
      set(handles.START,'Value',0)
      set(handles.MSG,'String',['Aborted at ' Ymagname ' due to no beam and user abort.'])
      drawnow
      return
    end
    BDES0 = lcaGetSmart(strcat(Ymag_pv,':BDES'));
    BACT0 = lcaGetSmart(strcat(Ymag_pv,':BACT'));
    if mode == 1      % if quad gradient variation...
      BDES1 = BDES0*(1-handles.dB_B/100);
      set(handles.MSG,'String',['Perturbing ' Ymagname ' to new value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Ymag_pv,BDES1,'P');
      end
    elseif mode == 2  % if X/YCOR field variation...
      BMAX  = lcaGetSmart(strcat(Ymag_pv,':BMAX'));
      if BDES0>(BMAX-handles.dBDES*BMAX)
        BDES1 = BDES0 - handles.dBDES*BMAX;
      else
        BDES1 = BDES0 + handles.dBDES*BMAX;
      end
      set(handles.MSG,'String',['Perturbing ' Ymagname ' to new value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Ymag_pv,BDES1,'P');
      end
    else              % if quad MOVER variation...
      [X0,Y0] = girderQUADposition(handles.iN(j));
      set(handles.MSG,'String',['Moving ' Ymagname ' to new Y-position...'])
      drawnow
      if ~handles.fakedata
        girderQuadMove(handles.iN(j),0,handles.dMOV);
        girderCamWait(handles.iN(j));    
      end
    end
    set(handles.MSG,'String',['Getting model for ' Ymagname ' to all BPMs'])
    drawnow
    if mode ~=3       % if NOT QUAD of X/YCOR change...
      if ~handles.fakedata
        BACT1 = lcaGetSmart(strcat(Ymag_pv,':BACT'));
      else
        BACT1 = BDES1;  % fake magnet change
      end
      disp(sprintf('%s dBACT = %8.5f kG',Ymagname,BACT1-BACT0))
      outoftol = check_magnet({Ymag_pv},4);   % allow 4-time larger error on BDES-BACT for this tweak (but restore exactly below)
      if outoftol
        disp([Ymagname ' did not perturb to new BDES - TRIMming now'])
        set(handles.MSG,'String',[Ymagname ' did not perturb well - TRIMming to new value...'])
        drawnow
        if ~handles.fakedata
          trim_magnet(Ymag_pv,BDES1,'T');
        end
      end
    else
      if ~handles.fakedata
        [X,Y] = girderQUADposition(handles.iN(j));
      else
        Y = Y0 + handles.dMOV;
      end
      dY = Y - Y0;
      disp(sprintf('%s dYMOV = %6.3f mm',Ymagname,dY))
      if abs(dY-handles.dMOV)>0.01
        disp([Ymagname ' did not move to new Y-position - what to do?'])
        set(handles.MSG,'String',[Ymagname ' did not move to new Y-position - what to do?'])
        drawnow      
      end
    end
    set(handles.MSG,'String','Reading kicked orbit...')
    drawnow
    pause(1)
    [handles.Xs(j,:,2),handles.Ys(j,:,2),Ts,dXs(j,:,2),dYs(j,:,2),dTs,beam,abort] = read_orbitf(hObject,handles);
    if abort
      set(handles.START,'BackgroundColor','green')
      set(handles.START,'String','Start')
      set(handles.START,'Value',0)
      set(handles.MSG,'String',['Aborted at ' Ymagname ' due to no beam and user abort.'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Ymag_pv,BDES0,'T');   % restore original quad setting
      end
      disp(['Aborted at ' Ymagname ' due to no beam and user abort.  Magnet BDES restored & TRIMmed.'])
      return
    end
    [handles.Xsf(j,handles.ibpm,2),handles.Ysf(j,handles.ibpm,2),p,dp,chisq,Q] = ...
        xy_traj_fit_kick(handles.Xs(j,handles.ibpm,2),dXs(j,handles.ibpm,2),handles.Ys(j,handles.ibpm,2),dYs(j,handles.ibpm,2),handles.Xs0(j,handles.ibpm,2),handles.Ys0(j,handles.ibpm,2),R1s(handles.ibpm,:),R3s(handles.ibpm,:),handles.Zs(handles.ibpm),handles.Z0,[1 1 1 1 0 1 1]);	% fit trajectory (only x' & y' fitted)
    if mode ~= 3
      handles.Yfac(handles.iN(j))  = -1E-3*p(6)*handles.Brho/(BACT1-BACT0);             % X/YCOR scale, or QUAD offset (1 or mm)
      handles.dYfac(handles.iN(j)) =  1E-3*abs(dp(6)*handles.Brho/(BACT1-BACT0));       % error bar (1)
    else
      handles.Yfac(handles.iN(j))   = -(handles.Ys(j,handles.iN(j)+handles.BPM_ioffset,2) - handles.Ys0(j,handles.iN(j)+handles.BPM_ioffset,2) - p(3) - handles.dMOV)/handles.dMOV;     % BPM calib. (should be 1)
      handles.dYfac(handles.iN(j))  = abs(sqrt(handles.dYs0(j,handles.iN(j)+handles.BPM_ioffset,2)^2 + handles.dYs(j,handles.iN(j)+handles.BPM_ioffset,2)^2 + dp(3)^2)/handles.dMOV);  % error bar (1)
      handles.Yfac2(handles.iN(j))  = -p(6)*handles.Brho/((dY+1E-6)*BACT0);             % kick angle scale
      handles.dYfac2(handles.iN(j)) = abs(dp(6)*handles.Brho/((dY+1E-6)*BACT0));        % kick angle scale error
      disp( [Ymagname sprintf(' Y-BPM calib. factor = %6.3f +- %5.3f',handles.Yfac(handles.iN(j)),handles.dYfac(handles.iN(j)))] )
    end
    handles.py(:,handles.iN(j)) = p';
    handles.dpy(:,handles.iN(j)) = dp';
    handles.chisqY(handles.iN(j)) = chisq;
    handles = plot_trajectory(0,j,2,hObject,handles,handles.mode);           % plot X & Y diff. trajectory vs Z and the fitted kicks
    plot_data_vs_z(0,j,hObject,handles,handles.mode)                 % plot X & Y scale factors vs Z
    if mode == 1      % if quad gradient variation...
      set(handles.MSG,'String',['Perturbing ' Ymagname ' back to initial value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Ymag_pv,BDES0,'P');
      end
      outoftol = check_magnet({Ymag_pv},1);   % use 1-times the tols for best reset of quad
      if outoftol
        disp([Ymagname ' did not perturb back to original BDES - TRIMming now'])
        set(handles.MSG,'String',[Ymagname ' did not perturb well - TRIMming to back to initial value...'])
        drawnow
        if ~handles.fakedata
          trim_magnet(Ymag_pv,BDES0,'T');
        end
      end
    elseif mode == 2  % if X/YCOR field variation...
      set(handles.MSG,'String',['Perturbing ' Ymagname ' back to initial value...'])
      drawnow
      if ~handles.fakedata
        trim_magnet(Ymag_pv,BDES0,'P');
      end
      outoftol = check_magnet({Ymag_pv},1);   % use 1-times the tols for best reset of quad
      if outoftol
        disp([Ymagname ' did not perturb back to original BDES - TRIMming now'])
        set(handles.MSG,'String',[Ymagname ' did not perturb well - TRIMming to back to initial value...'])
        drawnow
        if ~handles.fakedata
          trim_magnet(Ymag_pv,BDES0,'T');
        end
      end
    else              % if quad MOVER variation...
      set(handles.MSG,'String',['Moving ' Ymagname ' back to initial Y-position...'])
      drawnow
      if ~handles.fakedata
        girderQuadMove(handles.iN(j),0,-handles.dMOV);
        girderCamWait(handles.iN(j));    
      end
      [X,Y] = girderQUADposition(handles.iN(j));
      disp(sprintf('%s dYMOV = %6.3f mm',Ymagname,Y-Y0))
      if abs(Y-Y0)>0.01
        disp([Ymagname ' did not move back to original Y-position - what to do?'])
        set(handles.MSG,'String',[Ymagname ' did not move back to original Y-position - what to do?'])
        drawnow      
      end
    end
  end
end
disp(handles.datestr0)
if mode == 1
  for j = 1:handles.Nmagnets_selected
    str = num2str(handles.iN(j),'%02d');
    disp(sprintf('QU%s:  dX=%6.3f +- %5.3f mm,  dY=%6.3f +- %5.3f mm,  chisq=%6.2f',str,handles.Xfac(handles.iN(j)),handles.dXfac(handles.iN(j)),handles.Yfac(handles.iN(j)),handles.dYfac(handles.iN(j)),handles.chisqX(handles.iN(j))))
  end
elseif mode == 2
  for j = 1:handles.Nmagnets_selected
    str = num2str(handles.iN(j),'%02d');
    disp(sprintf('XYCU%s:  Xfac=%6.3f +- %5.3f mm,  Yfac=%6.3f +- %5.3f mm,  chisqX=%6.2f,  chisqY=%6.2f',str,handles.Xfac(handles.iN(j)),handles.dXfac(handles.iN(j)),handles.Yfac(handles.iN(j)),handles.dYfac(handles.iN(j)),handles.chisqX(handles.iN(j)),handles.chisqY(handles.iN(j))))
  end
else
  for j = 1:handles.Nmagnets_selected
    str = num2str(handles.iN(j),'%02d');
    disp(sprintf('XYMOV%s:  Xfac=%6.3f +- %5.3f mm,  Yfac=%6.3f +- %5.3f mm,  Xkick=%6.3f +- %5.3f, Ykick=%6.3f +- %5.3f, chisqX=%6.2f,  chisqY=%6.2f',str,handles.Xfac(handles.iN(j)),handles.dXfac(handles.iN(j)),handles.Yfac(handles.iN(j)),handles.dYfac(handles.iN(j)),handles.Xfac2(handles.iN(j)),handles.dXfac2(handles.iN(j)),handles.Yfac2(handles.iN(j)),handles.dYfac2(handles.iN(j)),handles.chisqX(handles.iN(j)),handles.chisqY(handles.iN(j))))
  end
end
if mode == 1
  if ~handles.fakedata
    trim_magnet(handles.QUAD_pvs(handles.iN))       % TRIM all QUADs one more time to be sure not out of tolerance
  end
elseif mode == 2
  XCOR_pvs = handles.QUAD_pvs(handles.iN);
  YCOR_pvs = handles.QUAD_pvs(handles.iN);
  for j = 1:handles.Nmagnets_selected
    PV = cell2mat(handles.QUAD_pvs(handles.iN(j)));
    XCOR_pvs(j) = {strcat('XCOR',PV(5:end))};
    YCOR_pvs(j) = {strcat('YCOR',PV(5:end))};
  end
  PVs = cat(1,XCOR_pvs,YCOR_pvs);
  if ~handles.fakedata
    trim_magnet(PVs)     % TRIM all correctors one more time to be sure not out of tolerance
  end
else
%
end
guidata(hObject,handles);



function save_data(handles)
handles1.BPM_ioffset = handles.BPM_ioffset;
handles1.QZs  = handles.QZs;
handles1.iN   = handles.iN;
handles1.Xs00 = handles.Xs00;
handles1.Ys00 = handles.Ys00;
handles1.Xfac = handles.Xfac;
handles1.Yfac = handles.Yfac;
handles1.datestr0 = handles.datestr0;
handles1.handles = handles; % Added by HDN 09/08/2009
save und_quad_align.mat handles1

% save to a known directory
save /u1/lcls/matlab/undulator/motion/und_quad_align.mat handles1 
display('Saving data to /u1/lcls/matlab/undulator/motion/und_quad_align.mat ')

data.name='';
data.ts=datenum(handles.datestr0);
str={'BPM_ioffset' 'QZs' 'iN' 'Xs00' 'Ys00' 'Xfac' 'Yfac'};
for tag=str, data.(tag{:})=handles.(tag{:});end
fileName=util_dataSave(data,'UndQuadAlign','',data.ts,0);
if ~ischar(fileName), return, end
handles.fileName=fileName;
%guidata(handles.output,handles);


function [Xs,Ys,Ts,dXs,dYs,dTs,beam,abort] = read_orbitf(hObject,handles)
Q0   = lcaGetSmart('IOC:IN20:BP01:QANN');
[sys,accelerator]=getSystem();
rate=lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);   % rep. rate [Hz]
if rate < 1
  rate = 10;    % don't spend all day at rate = 0
end
while 1
  for j = 1:3
    set(handles.MSG,'String',['Reading orbit: try #' int2str(j)])
    drawnow
    if ~handles.fakedata
      [X,Y,T,dX,dY,dT,iok] = read_BPMs(handles.BPM_pvs,handles.navg,rate);  % read all BPMs, X, Y, & TMIT with averaging
    else
      X = 0.1*randn(1,handles.nbpms);Y = 0.1*randn(1,handles.nbpms);T = 1.56E9*(1+randn(1,handles.nbpms)/100);  % temporary data faker
      dX = 0.01*(1+rand(1,handles.nbpms));dY = 0.01*(1+rand(1,handles.nbpms));dT = 1.56E9*(1+rand(1,handles.nbpms)/5)/100;  % temporary data faker
    end
    Xs = X;                   % mean X-position for all BPMs [mm]
    Ys = Y;                   % mean Y-position for all BPMs [mm]
    Ts = 1.602E-10*T';        % mean charge for all BPMs [nC]
    dXs = dX;                 % std/sqrt(N) of X-position for all BPMs [mm]
    dYs = dY;                 % std/sqrt(N) of Y-position for all BPMs [mm]
    dTs = 1.602E-10*dT';      % std/sqrt(N) of charge for all BPMs [nC]
    min_charge = max([0.005 Q0/5]);
    if mean(Ts)<min_charge
      set(handles.MSG,'String',['Bunch charge < ' sprintf('%1.0f',min_charge*1E3) ' pC - retrying...'])
      drawnow
      beam = 0;
    elseif any(isnan(X)) || any(isnan(Y))
      set(handles.MSG,'String','some X or Y reads NaN - retrying...')
      drawnow
      beam = 0;
    else
      beam = 1;
      abort = 0;
      set(handles.MSG,'String','Beam OK...')
      drawnow
      break
    end
    pause(1)
  end
  if ~beam
    yn = questdlg(['Bunch charge is < ' sprintf('%1.0f',min_charge*1E3) ' pC.  Do you want to try again?'],'LOW CHARGE WARNING');
    if ~strcmp(yn,'Yes')
      abort = 1;
      break
    else
      abort = 0;
    end
  else
    break
  end
end
guidata(hObject,handles);



function handles = plot_trajectory(Elog_fig,j,ixy,hObject,handles,mode)
if handles.have_data==0
  return
end
if Elog_fig
  figure(Elog_fig)
  ax1=subplot(2,1,1);
  ax2=subplot(2,1,2);
else
  ax1=handles.AXES1;
  ax2=handles.AXES2;
end
% do X-orbit plot with fit
axes(ax1);
plot([1;1]*handles.Zs(:)',[0;1]*(handles.Xs(j,:,ixy)-handles.Xs0(j,:,ixy)),'b');
hold on
plot(handles.Zs(handles.ibpm)',handles.Xsf(j,handles.ibpm,ixy),'.b-')
ver_line(handles.Zs(handles.iN(j)+handles.BPM_ioffset),':k')
name = cell2mat(handles.QUAD_pvs(handles.iN(j)));
if mode == 1
  plot(handles.Zs(handles.iN(j)+handles.BPM_ioffset),0,'dr')
  title(sprintf('Traj #%2.0f: %s, x0=%7.4f mm, x0''=%7.4f mr, dx''=%7.4f mr, chisqx=%5.2f,  %s',j,name(6:end),handles.px(1,handles.iN(j)),handles.px(2,handles.iN(j)),handles.px(5,handles.iN(j)),handles.chisqX(handles.iN(j)),handles.datestr0))
elseif mode == 2
  if ixy==1
    plot(handles.Zs(handles.iN(j)+handles.BPM_ioffset),0,'^r')
    title(sprintf('Traj #%2.0f: %s, x0=%7.4f mm, x0''=%7.4f mr, dx''=%7.4f mr, chisqx=%5.2f,  %s',j,name(6:end),handles.px(1,handles.iN(j)),handles.px(2,handles.iN(j)),handles.px(5,handles.iN(j)),handles.chisqX(handles.iN(j)),handles.datestr0))
  end
else
  if ixy==1
    plot(handles.Zs(handles.iN(j)+handles.BPM_ioffset),0,'dr')
    title(sprintf('Traj #%2.0f: %s, x0=%7.4f mm, x0''=%7.4f mr, dx''=%7.4f mr, chisqx=%5.2f,  %s',j,name(6:end),handles.px(1,handles.iN(j)),handles.px(2,handles.iN(j)),handles.px(5,handles.iN(j)),handles.chisqX(handles.iN(j)),handles.datestr0))
  end
end
hor_line(0,'-k')
hold off
ylabel('\DeltaX (mm)')
handles.vx = axis;

% do Y-orbit plot with fit
axes(ax2);
plot([1;1]*handles.Zs(:)',[0;1]*(handles.Ys(j,:,ixy)-handles.Ys0(j,:,ixy)),'g');
hold on
plot(handles.Zs(handles.ibpm)',handles.Ysf(j,handles.ibpm,ixy),'.g-')
ver_line(handles.Zs(handles.iN(j)+handles.BPM_ioffset),':k')
if mode == 1
  plot(handles.Zs(handles.iN(j)+handles.BPM_ioffset),0,'dr')
  title(sprintf('Traj #%2.0f: %s, y0=%7.4f mm, y0''=%7.4f mr, dy''=%7.4f mr,  %s',j,name(6:end),handles.px(3,handles.iN(j)),handles.px(4,handles.iN(j)),handles.px(6,handles.iN(j)),handles.datestr0))
elseif mode == 2
  if ixy==2
    plot(handles.Zs(handles.iN(j)+handles.BPM_ioffset),0,'^r')
    title(sprintf('Traj #%2.0f: %s, y0=%7.4f mm, y0''=%7.4f mr, dy''=%7.4f mr, chisqy=%5.2f,  %s',j,name(6:end),handles.py(3,handles.iN(j)),handles.py(4,handles.iN(j)),handles.py(6,handles.iN(j)),handles.chisqY(handles.iN(j)),handles.datestr0))
  end
else
  if ixy==2
    plot(handles.Zs(handles.iN(j)+handles.BPM_ioffset),0,'dr')
    title(sprintf('Traj #%2.0f: %s, y0=%7.4f mm, y0''=%7.4f mr, dy''=%7.4f mr, chisqy=%5.2f,  %s',j,name(6:end),handles.py(3,handles.iN(j)),handles.py(4,handles.iN(j)),handles.py(6,handles.iN(j)),handles.chisqY(handles.iN(j)),handles.datestr0))
  end
end
hor_line(0,'-k')
hold off
xlabel('Z (m)')
ylabel('\DeltaY (mm)')
handles.vy = axis;
guidata(hObject,handles);



function plot_data_vs_z(Elog_fig,j,hObject,handles,mode)        % plot X & YCOR scale factors vs Z
if handles.have_data==0
  return
end
if mode == 1                % QUAD offset results
  xmrk  = 'bd';
  ymrk  = 'gs';
  ylbl1 = 'QUAD \DeltaX (mm)';
  ylbl2 = 'QUAD \DeltaY (mm)';
elseif handles.mode == 2    % X/YCOR scale results
  xmrk  = 'c^';
  ymrk  = 'mv';
  ylbl1 = 'XCOR factors (1)';
  ylbl2 = 'YCOR factors (1)';
else                        % QUAD translation results
  xmrk  = 'ro';
  ymrk  = 'kx';
  ylbl1 = 'BPM X-calib. (1)';
  ylbl2 = 'BPM Y-calib. (1)';
end
if Elog_fig
  figure(Elog_fig)
  ax1=subplot(2,1,1);
  ax2=subplot(2,1,2);
else
  ax1=handles.AXES3;
  ax2=handles.AXES4;
end
if exist('und_quad_align.mat','file')
  load und_quad_align.mat
  old_data = 1;
else
  old_data = 0;
end
% do X plot
axes(ax1);
if ~handles.wrtbeam && mode==1
  errorbar(handles.QZs(handles.iN(1:j))',handles.Xfac(handles.iN(1:j))'+handles.Xs00(handles.iN(1:j)+handles.BPM_ioffset)',handles.dXfac(handles.iN(1:j))',xmrk);
  if old_data && handles.showolddata
    hold on
    plot(handles1.QZs(handles1.iN)',handles1.Xfac(handles1.iN)'+handles1.Xs00(handles1.iN+handles1.BPM_ioffset)','r.');
    hold off
  end
elseif mode==1
  errorbar(handles.QZs(handles.iN(1:j))',handles.Xfac(handles.iN(1:j))',handles.dXfac(handles.iN(1:j))',xmrk);
  hold on
  plot(handles.Zs,handles.Xs00,'r--.')
  hold off
else
  errorbar(handles.QZs(handles.iN(1:j))',handles.Xfac(handles.iN(1:j))',handles.dXfac(handles.iN(1:j))',xmrk);
  if old_data && handles.showolddata
    hold on
    plot(handles1.QZs(handles1.iN)',handles1.Xfac(handles1.iN)','r.');
    hold off
  end
end
ylabel(ylbl1)
xlim(handles.vx(1:2))
hor_line(0,'-k')
title(sprintf('<X>=%6.3f mm, Xrms=%5.3f mm,  %s',mean(handles.Xfac(handles.iN)),std(handles.Xfac(handles.iN)),handles.datestr0))
% do Y plot
axes(ax2);
if ~handles.wrtbeam && mode==1
  errorbar(handles.QZs(handles.iN(1:j))',handles.Yfac(handles.iN(1:j))'+handles.Ys00(handles.iN(1:j)+handles.BPM_ioffset)',handles.dYfac(handles.iN(1:j))',ymrk);
  if old_data && handles.showolddata
    hold on
    plot(handles1.QZs(handles1.iN)',handles1.Yfac(handles1.iN)'+handles1.Ys00(handles1.iN+handles1.BPM_ioffset)','r.');
    hold off
  end
elseif mode==1
  errorbar(handles.QZs(handles.iN(1:j))',handles.Yfac(handles.iN(1:j))',handles.dYfac(handles.iN(1:j))',ymrk);
  hold on
  plot(handles.Zs,handles.Ys00,'m--.')
  hold off
else
  errorbar(handles.QZs(handles.iN(1:j))',handles.Yfac(handles.iN(1:j))',handles.dYfac(handles.iN(1:j))',ymrk);
  if old_data && handles.showolddata
    hold on
    plot(handles1.QZs(handles1.iN)',handles1.Yfac(handles1.iN)','r.');
    hold off
  end
end
xlabel('Z (m)')
ylabel(ylbl2)
xlim(handles.vy(1:2))
hor_line(0,'-k')
if old_data && handles.showolddata
  title(sprintf('<Y>=%6.3f mm, Yrms=%5.3f mm (RED old data: %s)',mean(handles.Yfac(handles.iN)),std(handles.Yfac(handles.iN)),handles1.datestr0))
else
  title(sprintf('<Y>=%6.3f mm, Yrms=%5.3f mm',mean(handles.Yfac(handles.iN)),std(handles.Yfac(handles.iN))))
end
  

function Q1_Callback(hObject, eventdata, handles)
handles.q1 = str2double(get(hObject,'String'));
if handles.q1 < 1
  handles.q1 = 1;
  set(handles.Q1,'String',num2str(handles.q1))
  warndlg('First index cannot be < 1','WARNING')
end
if handles.q1 > handles.nquads
  handles.q1 = handles.nquads;
  set(handles.Q1,'String',num2str(handles.q1))
  warndlg(sprintf('First index cannot be > %2.0f',handles.nquads),'WARNING')
end
if handles.q1 > handles.qN
  handles.q1 = 1;
  set(handles.Q1,'String',num2str(handles.q1))
  warndlg('First index cannot be larger than last','WARNING')
end
set(handles.QMAX,'String',handles.qN-handles.q1+1)
set(handles.TRAJ_J,'Max',handles.qN-handles.q1+1)
if handles.qN-handles.q1 == 0
  set(handles.TRAJ_J,'Visible','off')
  set(handles.QMIN,'Visible','off')
  set(handles.QMAX,'Visible','off')
  set(handles.TRAJ_SETTING,'Visible','off')
else
  set(handles.TRAJ_J,'Visible','on')
  set(handles.QMIN,'Visible','on')
  set(handles.QMAX,'Visible','on')
  set(handles.TRAJ_SETTING,'Visible','on')
  set(handles.TRAJ_J,'SliderStep',[1 5]/(handles.qN-handles.q1));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Q1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QN_Callback(hObject, eventdata, handles)
handles.qN = str2double(get(hObject,'String'));
if handles.qN < 1
  handles.qN = handles.nquads;
  set(handles.QN,'String',num2str(handles.qN))
  warndlg('Last index cannot be < 1','WARNING')
end
if handles.qN > handles.nquads
  handles.qN = handles.nquads;
  set(handles.QN,'String',num2str(handles.qN))
  warndlg(sprintf('Last index cannot be > %2.0f',handles.nquads),'WARNING')
end
if handles.qN < handles.q1
  handles.qN = handles.nquads;
  set(handles.QN,'String',num2str(handles.qN))
  warndlg('Last index cannot be larger than first','WARNING')
end
set(handles.QMAX,'String',handles.qN-handles.q1+1)
set(handles.TRAJ_J,'Max',handles.qN-handles.q1+1)
if handles.qN-handles.q1 == 0
  set(handles.TRAJ_J,'Visible','off')
  set(handles.QMIN,'Visible','off')
  set(handles.QMAX,'Visible','off')
  set(handles.TRAJ_SETTING,'Visible','off')
else
  set(handles.TRAJ_J,'Visible','on')
  set(handles.QMIN,'Visible','on')
  set(handles.QMAX,'Visible','on')
  set(handles.TRAJ_SETTING,'Visible','on')
  set(handles.TRAJ_J,'SliderStep',[1 5]/(handles.qN-handles.q1));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function QN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DB_B_Callback(hObject, eventdata, handles)
handles.dB_B = str2double(get(hObject,'String'));
if handles.dB_B < 1
  handles.dB_B = 1;
  set(handles.DB_B,'String',num2str(handles.dB_B))
  warndlg('QUAD strength change cannot be < 1%','WARNING')
end
if handles.dB_B > 90
  handles.dB_B = 90;
  set(handles.DB_B,'String',num2str(handles.dB_B))
  warndlg('QUAD strength change cannot be > 90%','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DB_B_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
if handles.navg < 1
  handles.navg = 1;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be < 1','WARNING')
end
if handles.navg > 100
  handles.navg = 100;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be > 100','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in printLog_btn1.
function printLog_btn1_Callback(hObject, eventdata, handles)
if handles.have_data==0
  return
end
j = round(get(handles.TRAJ_J,'Value'));
handles.ibpm = set_BPM_pointers(j,hObject, handles);
plot_trajectory(1,j,handles.ixy,hObject,handles,handles.mode);          % plot X & Y diff. trajectory vs Z and the fitted quad kicks
util_printLog(1);
guidata(hObject,handles);



% --- Executes on button press in printLog_btn2.
function printLog_btn2_Callback(hObject, eventdata, handles)
if handles.have_data% edit jjw 6/7/09  && ~handles.saved
  save_yn = questdlg('Save this data set?','SAVE DATA?');
else
  save_yn = 'No';
end
if strcmp(save_yn,'Yes') && ~handles.fakedata
  save_data(handles)    % save last data set so it can be plotted with new data
  handles.saved = 1;    % data is saved
else
  disp('Not saved since this is faked data.')
end
guidata(hObject,handles);
plot_data_vs_z(2,handles.Nmagnets_selected,hObject,handles,handles.mode)           % plot X & Y corrector scales vs Z
util_printLog(2);
guidata(hObject,handles);



% --- Executes on button press in FAKE.
function FAKE_Callback(hObject, eventdata, handles)
handles.fakedata = get(hObject,'Value');
guidata(hObject,handles);



% --- Executes on slider movement.
function TRAJ_J_Callback(hObject, eventdata, handles)
handles.traj_j = round(get(hObject,'Value'));
j = handles.traj_j;
set(handles.TRAJ_SETTING,'String',num2str(handles.traj_j))
if handles.meas_done
  handles.ibpm = set_BPM_pointers(j,hObject, handles);
  plot_trajectory(0,handles.traj_j,handles.ixy,hObject,handles,handles.mode);          % plot X & Y diff. trajectory vs Z and the fitted quad kicks
  guidata(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function TRAJ_J_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in XPLANE.
function XPLANE_Callback(hObject, eventdata, handles)
X = get(hObject,'Value');
if X
  handles.ixy = 1;
else
  handles.ixy = 2;
end
set(handles.YPLANE,'Value',not(handles.ixy))
j = handles.traj_j;
if handles.meas_done
  handles.ibpm = set_BPM_pointers(j,hObject, handles);
  plot_trajectory(0,handles.traj_j,handles.ixy,hObject,handles,handles.mode);          % plot X & Y diff. trajectory vs Z and the fitted quad kicks
end
guidata(hObject,handles);



% --- Executes on button press in YPLANE.
function YPLANE_Callback(hObject, eventdata, handles)
Y = get(hObject,'Value');
if Y
  handles.ixy = 2;
else
  handles.ixy = 1;
end
set(handles.XPLANE,'Value',not(handles.ixy))
j = handles.traj_j;
if handles.meas_done
  handles.ibpm = set_BPM_pointers(j,hObject, handles);
  plot_trajectory(0,handles.traj_j,handles.ixy,hObject,handles,handles.mode);          % plot X & Y diff. trajectory vs Z and the fitted quad kicks
end
guidata(hObject,handles);



function BPM1_Callback(hObject, eventdata, handles)
handles.ibpm1 = str2double(get(hObject,'String'));
if handles.ibpm1 < 1
  handles.ibpm1 = 1;
  set(handles.BPM1,'String',num2str(handles.ibpm1))
  warndlg('First BPM cannot be < 1','WARNING')
end
if handles.ibpm1 > handles.nquads
  handles.ibpm1 = handles.nquads;
  set(handles.BPM1,'String',num2str(handles.nquads))
  warndlg(sprintf('First BPM cannot be > %2.0f',handles.nquads),'WARNING')
end
if handles.ibpm1 > handles.ibpm2
  handles.ibpm1 = handles.ibpm2;
  set(handles.BPM1,'String',num2str(handles.ibpm1))
  warndlg('First BPM cannot be > Last BPM','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function BPM1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BPM2_Callback(hObject, eventdata, handles)
handles.ibpm2 = str2double(get(hObject,'String'));
if handles.ibpm2 < 1
  handles.ibpm2 = 1;
  set(handles.BPM2,'String',num2str(handles.ibpm2))
  warndlg('Last BPM cannot be < 1','WARNING')
end
if handles.ibpm2 > handles.nquads
  handles.ibpm2 = handles.nquads;
  set(handles.BPM2,'String',num2str(handles.nquads))
  warndlg(sprintf('Last BPM cannot be > %2.0f',handles.nquads),'WARNING')
end
if handles.ibpm2 < handles.ibpm1
  handles.ibpm2 = handles.ibpm1;
  set(handles.BPM2,'String',num2str(handles.ibpm2))
  warndlg('Last BPM cannot be < First BPM','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function BPM2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DBDES_Callback(hObject, eventdata, handles)
handles.dBDES = str2double(get(hObject,'String'));
if handles.dBDES <= 0
  handles.dBDES = 0.5;
  set(handles.DBDES,'String',num2str(handles.dBDES))
  warndlg('Corrector change cannot be <= 0','WARNING')
end
if handles.dBDES > 1
  handles.dBDES = 1;
  set(handles.DBDES,'String',num2str(handles.dBDES))
  warndlg('Corrector change cannot be > 1','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DBDES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DMOV_Callback(hObject, eventdata, handles)
handles.dMOV = str2double(get(hObject,'String'));
if handles.dMOV < 0.05
  handles.dMOV = 0.05;
  set(handles.DMOV,'String',num2str(handles.dMOV))
  warndlg('Girder motion cannot be < 0.05 mm','WARNING')
end
if handles.dMOV > 0.5
  handles.dMOV = 0.5;
  set(handles.DMOV,'String',num2str(handles.dMOV))
  warndlg('Girder motion cannot be > 0.5 mm','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function DMOV_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in DO_QUADS.
function DO_QUADS_Callback(hObject, eventdata, handles)
do_quads = get(hObject,'Value');
if do_quads
  set(handles.XPLANE,'Visible','off')
  set(handles.YPLANE,'Visible','off')
  set(handles.DO_XYCOR,'Value',0)
  set(handles.DO_GIRDER,'Value',0)
  set(handles.WRTBEAM,'Visible','on')
  handles.mode = 1;
  handles.do_xycor = 0;
else
  set(handles.DO_QUADS,'Value',1)
end
guidata(hObject,handles);



% --- Executes on button press in DO_XYCOR.
function DO_XYCOR_Callback(hObject, eventdata, handles)
handles.do_xycor = get(hObject,'Value');
if handles.do_xycor
  set(handles.XPLANE,'Visible','on')
  set(handles.YPLANE,'Visible','on')
  set(handles.QMIN,'Visible','on')
  set(handles.QMAX,'Visible','on')
  set(handles.TRAJ_SETTING,'Visible','on')
  set(handles.TRAJ_J,'Visible','on')
  set(handles.WRTBEAM,'Visible','off')
  set(handles.DO_QUADS,'Value',0)
  set(handles.DO_GIRDER,'Value',0)
  handles.mode = 2;
else
  set(handles.DO_XYCOR,'Value',1)
end
guidata(hObject,handles);



% --- Executes on button press in DO_GIRDER.
function DO_GIRDER_Callback(hObject, eventdata, handles)
do_girder = get(hObject,'Value');
if do_girder
  set(handles.XPLANE,'Visible','on')
  set(handles.YPLANE,'Visible','on')
  set(handles.QMIN,'Visible','on')
  set(handles.QMAX,'Visible','on')
  set(handles.TRAJ_SETTING,'Visible','on')
  set(handles.TRAJ_J,'Visible','on')
  set(handles.WRTBEAM,'Visible','off')
  set(handles.DO_QUADS,'Value',0)
  set(handles.DO_XYCOR,'Value',0)
  handles.mode = 3;
  handles.do_xycor = 0;
else
  set(handles.DO_GIRDER,'Value',1)
end
guidata(hObject,handles);



% --- Executes on button press in WRTBEAM.
function WRTBEAM_Callback(hObject, eventdata, handles)
handles.wrtbeam = get(hObject,'Value');
plot_data_vs_z(0,handles.Nmagnets_selected,hObject,handles,handles.mode)           % plot X & Y vs Z
guidata(hObject,handles);



% --- Executes on button press in SHOWOLDDATA.
function SHOWOLDDATA_Callback(hObject, eventdata, handles)
handles.showolddata = get(hObject,'Value');
plot_data_vs_z(0,handles.Nmagnets_selected,hObject,handles,handles.mode)           % plot X & Y vs Z
guidata(hObject,handles);



function ibpm = set_BPM_pointers(j,hObject,handles)
ibpm = min(handles.iN(j)+handles.BPM_ioffset + handles.ibpm1,handles.nbpms-1):1:min(handles.iN(j)+handles.BPM_ioffset + handles.ibpm2,handles.nbpms);
ibpm = [((handles.iN(j)+handles.BPM_ioffset-min(10,handles.iN(j)+handles.BPM_ioffset-1))):1:(handles.iN(j)+handles.BPM_ioffset-1) ibpm];



% --- Executes on button press in APPLY.
function APPLY_Callback(hObject, eventdata, handles)
set(handles.APPLY,'String','wait...')
set(handles.APPLY,'BackgroundColor','white')
drawnow
girders = [handles.girder-1 handles.girder handles.girder+1];
[X0,Y0] = girderQUADposition(girders);
if strcmp(handles.x_or_y,'x')
  dx = [handles.X1 handles.X2 handles.X3];
  dy = [0 0 0];
else
  dx = [0 0 0];
  dy = [handles.X1 handles.X2 handles.X3];
end
girderQuadMove(girders,dx,dy);
girderCamWait(girders);
[X1,Y1] = girderQUADposition(girders);
if strcmp(handles.x_or_y,'x')
  set(handles.GIRDER1,'String',num2str(X1(1)-X0(1),'%6.3f'))
  set(handles.GIRDER2,'String',num2str(X1(2)-X0(2),'%6.3f'))
  set(handles.GIRDER3,'String',num2str(X1(3)-X0(3),'%6.3f'))
else
  set(handles.GIRDER1,'String',num2str(Y1(1)-Y0(1),'%6.3f'))
  set(handles.GIRDER2,'String',num2str(Y1(2)-Y0(2),'%6.3f'))
  set(handles.GIRDER3,'String',num2str(Y1(3)-Y0(3),'%6.3f'))
end
set(handles.GIRDER1,'ForegroundColor','green')
set(handles.GIRDER2,'ForegroundColor','green')
set(handles.GIRDER3,'ForegroundColor','green')
set(handles.APPLY,'String','APPLY')
set(handles.APPLY,'BackgroundColor','yellow')
set(handles.APPLY,'Enable','off')
drawnow



% --- Executes on button press in CALC.
function CALC_Callback(hObject, eventdata, handles)
set(handles.CALC,'String','wait...')
set(handles.CALC,'BackgroundColor','white')
drawnow
[X,xpos,iok] = girder_bump(handles.girder,handles.amplitude,handles.x_or_y);
handles.X1 = X(1);
handles.X2 = X(2);
handles.X3 = X(3);
handles.xpos = xpos;
set(handles.GIRDER1,'String',num2str(handles.X1,'%6.3f'))
set(handles.GIRDER2,'String',num2str(handles.X2,'%6.3f'))
set(handles.GIRDER3,'String',num2str(handles.X3,'%6.3f'))
set(handles.BEAMPOS,'String',num2str(handles.xpos,'%6.3f'))
set(handles.GIRDER1,'ForegroundColor','black')
set(handles.GIRDER2,'ForegroundColor','black')
set(handles.GIRDER3,'ForegroundColor','black')
set(handles.CALC,'String','CALC')
set(handles.CALC,'BackgroundColor',[212 208 200]/255)
set(handles.APPLY,'Enable','on')
drawnow
guidata(hObject,handles);



function GIRDER_Callback(hObject, eventdata, handles)
handles.girder = str2double(get(hObject,'String'));
if handles.girder < 2
  handles.girder = 2;
  set(handles.GIRDER,'String',num2str(handles.girder))
  warndlg('Center girder for 3-bump cannot be < 2','WARNING')
end
if handles.girder > 32
  handles.girder = 32;
  set(handles.GIRDER,'String',num2str(handles.girder))
  warndlg('Center girder for 3-bump cannot be > 32','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GIRDER_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AMPLITUDE_Callback(hObject, eventdata, handles)
handles.amplitude = str2double(get(hObject,'String'));
if abs(handles.amplitude) > 1
  handles.amplitude = 0;
  set(handles.AMPLITUDE,'String',num2str(handles.amplitude))
  warndlg('Center girder |amplitude| for 3-bump cannot be > 1 mm','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function AMPLITUDE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GIRDER1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function GIRDER1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GIRDER2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function GIRDER2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GIRDER3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function GIRDER3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in X_OR_Y.
function X_OR_Y_Callback(hObject, eventdata, handles)
ixy = get(hObject,'Value');
xy  = get(hObject,'String');
handles.x_or_y = lowcase(cell2mat(xy(ixy)));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function X_OR_Y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BEAMPOS_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function BEAMPOS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in APPLYALL.
function APPLYALL_Callback(hObject, eventdata, handles)
set(handles.APPLYALL,'String','wait...')
set(handles.APPLYALL,'BackgroundColor','white')
drawnow
[X0,Y0] = girderQUADposition(handles.girders);
if strcmp(handles.x_or_y,'x')
else
end
XMOV = -handles.dXmov
YMOV = -handles.dYmov
girderQuadMove(handles.girders,-handles.dXmov,-handles.dYmov);
girderCamWait(handles.girders);
[X1,Y1] = girderQUADposition(handles.girders);
set(handles.APPLYALL,'String','APPLY ALL')
set(handles.APPLYALL,'BackgroundColor','yellow')
set(handles.APPLYALL,'Enable','off')
drawnow



% --- Executes on button press in CALCALL.
function CALCALL_Callback(hObject, eventdata, handles)
if ~handles.have_data
  disp('No quad alignment data available yet')
  return
end
if handles.mode ~= 1
  disp('Not in "Quad offsets" (alignment) mode')
  return
end  
handles.girders = find(handles.Xfac & handles.Xfac); % find quads with real data
nquads = length(handles.girders);
if nquads < 3
  disp('Need at least 3 quad positions to correct - quitting.')
  return
end
set(handles.CALCALL,'String','wait...')
set(handles.CALCALL,'BackgroundColor','white')
drawnow
R = model_rMatGet(handles.QUAD_pvs(1),handles.QUAD_pvs,{'POS=MID' 'POSB=MID'});
quad_bdes_pvs = strcat(handles.QUAD_pvs,':BDES');
BDES = lcaGetSmart(quad_bdes_pvs);
handles.E0   = lcaGetSmart('BEND:DMP1:400:BDES');    % beam energy [GeV]
handles.Brho = 33.35640952*handles.E0;
Qx = zeros(nquads,nquads-2);
Qy = zeros(nquads,nquads-2);
for j = 2:(nquads-1)    % loop over all quads, except 1st and last
  R12 = R(:,:,j  )*inv(R(:,:,j-1));
  R13 = R(:,:,j+1)*inv(R(:,:,j-1));
  R23 = R(:,:,j+1)*inv(R(:,:,j  ));
  Ax = [R12(1,2) 0              0
        R13(1,2) R23(1,2)       0
        R13(2,2) R23(2,2)       1];
  Ay = [R12(3,4) 0              0
        R13(3,4) R23(3,4)       0
        R13(4,4) R23(4,4)       1];
  Xn = inv(Ax)*[1 0 0]';
  Yn = inv(Ay)*[1 0 0]';
  Xu = handles.Brho*Xn./[BDES(j-1) BDES(j) BDES(j+1)]';
  Yu = handles.Brho*Yn./[BDES(j-1) BDES(j) BDES(j+1)]';
  Xu = Xu/Xu(2);
  Yu = Yu/Yu(2);
  Qx(:,j-1) = [zeros(1,j-2) Xu' zeros(1,nquads-1-j)];
  Qy(:,j-1) = [zeros(1,j-2) Yu' zeros(1,nquads-1-j)];
end
[xf,dxf,qx,dqx,chisqx] = fit(Qx,handles.Xfac(handles.girders));     % fit for best steering using 31 3-bumps in X
[yf,dyf,qy,dqy,chisqy] = fit(Qy,handles.Yfac(handles.girders));     % fit for best steering using 31 3-bumps in Y
handles.dXmov = xf;
handles.dYmov = yf;
%
figure(1)
subplot(211)
plot(handles.QZs(handles.girders),handles.Xfac(handles.girders),'bo',handles.QZs(handles.girders),handles.Xfac(handles.girders)-handles.dXmov','rd')
xlabel('Z (m)')
ylabel('QUAD \DeltaX & corrected (mm)')
hor_line
subplot(212)
plot(handles.QZs(handles.girders),handles.Yfac(handles.girders),'gs',handles.QZs(handles.girders),handles.Yfac(handles.girders)-handles.dYmov','rd')
xlabel('Z (m)')
ylabel('QUAD \DeltaY & corrected (mm)')
hor_line
%
set(handles.CALCALL,'String','CALC ALL')
set(handles.CALCALL,'BackgroundColor',[212 208 200]/255)
set(handles.APPLYALL,'Enable','on')
drawnow
guidata(hObject,handles);


