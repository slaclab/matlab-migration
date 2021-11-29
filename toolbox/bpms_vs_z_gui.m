function varargout = bpms_vs_z_gui(varargin)

% BPMS_VS_Z_GUI M-file for bpms_vs_z_gui.fig
%      BPMS_VS_Z_GUI, by itself, creates a new BPMS_VS_Z_GUI or raises the
%      existing
%      singleton*.
%
%      H = BPMS_VS_Z_GUI returns the handle to a new BPMS_VS_Z_GUI or the handle to
%      the existing singleton*.
%
%      BPMS_VS_Z_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BPMS_VS_Z_GUI.M with the given input arguments.
%
%      BPMS_VS_Z_GUI('Property','Value',...) creates a new BPMS_VS_Z_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bpms_vs_z_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bpms_vs_z_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help bpms_vs_z_gui

% Last Modified by GUIDE v2.5 26-Aug-2016 14:25:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bpms_vs_z_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bpms_vs_z_gui_OutputFcn, ...
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


% --- Executes just before bpms_vs_z_gui is made visible.
function bpms_vs_z_gui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for bpms_vs_z_gui
handles.output = hObject;

[handles.system,accel]=getSystem;if strcmp(accel,'FACET'), accel='';end
handles.beamRatePV=['EVNT:' handles.system ':1:' accel 'BEAMRATE'];
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
%handles.beamOffPV='MPS:IN20:1:SHUTTER_TCTL';
handles.wait    = str2double(get(handles.WAIT,'String'));
handles.xyscale = str2double(get(handles.XYSCALE,'String'));
handles.tscale  = str2double(get(handles.TSCALE,'String'));
handles.navg    = str2double(get(handles.NAVG,'String'));
handles.diff    = get(handles.DIFF,'Value');
handles.showmagnets = get(handles.SHOWMAGNETS,'Value');
handles.first_beam = get(handles.FIRST_BEAM,'Value');
handles.fitI(1) = get(handles.FIT1,'Value');
handles.fitI(2) = get(handles.FIT2,'Value');
handles.fitI(3) = get(handles.FIT3,'Value');
handles.fitI(4) = get(handles.FIT4,'Value');
handles.fitI(5) = get(handles.FIT5,'Value');
handles.fitI(6) = get(handles.FIT6,'Value');
handles.fitI(7) = get(handles.FIT7,'Value');
handles.one_shot = get(handles.ONE_SHOT,'Value');
if any(handles.fitI)
  handles.fiton = 1;
else
  handles.fiton = 0;
end
handles.takeref = 0;
handles.region = get(handles.REGION,'Value');
handles = set_region(hObject,handles);
handles.exportFig=1; % Added 08/05/2007, H. Loos
handles.edefN = eDefReserve('bpms_vs_z_gui');
guidata(hObject, handles);  % Update handles structure

% UIWAIT makes bpms_vs_z_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bpms_vs_z_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% --- Executes on selection change in REGION.
function REGION_Callback(hObject, eventdata, handles)
handles.region = get(hObject,'Value');
handles = set_region(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function REGION_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = set_region(hObject,handles,flag)

set(handles.STARTSTOP,'String','wait...')
set(handles.STARTSTOP,'Enable','off')
iname = get(handles.REGION,'Value');
names = get(handles.REGION,'String');
handles.region_name = char(names(iname));

switch handles.region
    case 1 % if Gun-SAB
        handles.region_color = [190 220 200]/255;
        mSource='MATLAB';
        regions={'SP' 'IN20:231' 'IN20:661'};
    case 2 % if Gun-TD11
        handles.region_color = [250 235 200]/255;
        mSource='MATLAB';
        regions={'L0' 'L1' 'IN20:231'};
    case 3 % if Gun-LI21
        handles.region_color = [255 204 204]/255;
        mSource='MATLAB';
        regions={'L0' 'L1' 'LI21' 'IN20:231'};
    case 4 % if LTU-TDUND
        mSource='MATLAB';
        handles.region_color = [180 200 255]/255;
        regions={'BSY' 'LTU0' 'LTU1'};
    case 5 % if UNDULATOR
        mSource='MATLAB';
        handles.region_color = [220 180 255]/255;
        set(handles.XYSCALE,'String','0.2');
        handles.xyscale = str2double(get(handles.XYSCALE,'String'));
        regions={'UND' 'UND_DMP'};
    case 6 % if BSY-DMP
        mSource='MATLAB';
        handles.region_color = [200 200 200]/255;
        regions={'LI29' 'LI30' 'BSY' 'LTU'};
    case 7 % if L1-L3
        mSource='MATLAB';
        handles.region_color = [230 220 210]/255;
        regions={'LI21' 'LI22' 'LI23' 'LI24' 'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30'};
    case 8 % if LCLS
        mSource='MATLAB';
        handles.region_color = [240 240 240]/255;
        regions={'LCLS'};
    case 9 % if FACET
        mSource='SLC';
        handles.region_color = [230 210 220]/255;
        regions={'LI19' 'LI20'};
end
if nargin < 3, gui_modelSourceControl(hObject,handles,mSource);end

% Get device names.
mags={'XCOR' 'YCOR' 'QUAD' 'QTRM' 'QUAS' 'SOLN' 'BEND' 'BTRM' 'BNDS' 'KICK'};
prim=[{'BPMS' 'TORO' 'OTRS' 'YAGS' 'PROF' 'BFW'} mags];
[pvs,id]=model_nameRegion(prim,regions);
% William Colocho, Aug 2016 Remove this BPM for now...
id(strmatch('BPMS:UND1:3395',pvs)) = [];
pvs(strmatch('BPMS:UND1:3395',pvs)) = []; 


is.MAGS=id >= 7;idMAGS=find(is.MAGS);
hsta=max(0,min(ceil(control_deviceGet(pvs(is.MAGS),'HSTA')),2^16-1));
isNoCtrl=bitand(hsta,hex2dec('F00')) == hex2dec('F00');
isOffline=bitand(hsta,hex2dec('004'));
is.MAGS(idMAGS(isNoCtrl | isOffline))=0;

% Get Z positions. If from XAL, some devices don't work, so remove them when Z zero.
set(handles.MSG,'String','Getting Z-values...');
drawnow;
Zs=model_rMatGet(pvs,[],[],'Z')';
is.BPMS=id == 1 & Zs;
is.TORO=id == 2;
is.PROF=ismember(id,3:6);

handles.BPM_pvs   =pvs(is.BPMS);
handles.Zs        = Zs(is.BPMS);
handles.screen_pvs=pvs(is.PROF);
handles.Zs_screens= Zs(is.PROF);
handles.magnet_pvs=pvs(is.MAGS);
handles.Zs_magnets= Zs(is.MAGS);
handles.toroid_pvs=pvs(is.TORO);
handles.Zs_toroids= Zs(is.TORO);

nbpms = length(handles.BPM_pvs);
[p,m,handles.BPM_units]=model_nameSplit(handles.BPM_pvs);
set(handles.MSG,'String','Getting BPM Twiss parameters...')
drawnow
handles.twiss=model_rMatGet(handles.BPM_pvs,[],'TYPE=DESIGN','twiss');
handles.betax = handles.twiss(3,:);
handles.betay = handles.twiss(8,:);
handles.etax  = handles.twiss(5,:);
handles.etay  = handles.twiss(10,:);
handles.etaxi = find(abs(handles.etax) > 0.05);
handles.etayi = find(abs(handles.etay) > 0.05);
handles.screen_full_pvs = strcat(handles.screen_pvs,':PNEUMATIC');
isBFW=strncmp(handles.screen_pvs,'BFW',3);
handles.screen_full_pvs(isBFW) = strcat(handles.screen_pvs(isBFW),':ACTPOSM');
handles.screen_full_pvs(strncmp(handles.screen_pvs,'YAGS:UND1',9))={''};
handles.screen_full_pvs(strncmp(handles.screen_pvs,'PROF:UND1',9))={''};

if handles.region==4 || handles.region==5
%  pv = strcat(handles.BPM_pvs,':CALC.D');
%  strip_BPM = lcaGetSmart(pv);
  if handles.first_beam     % if 1st beam in und and using URMS, VRMS, RRMS (amplitudes) rather than X, Y, TMIT
    for j = 1:nbpms   %
      if handles.BPM_pvs{j}(6)=='U' || (handles.BPM_pvs{j}(6)=='L' && handles.BPM_pvs{j}(7)=='T' && handles.BPM_pvs{j}(11)=='9')
        handles.temp(j) = 1;
      else
        handles.temp(j) = 0;
      end
    end
  else
    handles.temp = zeros(nbpms,1);
  end
else
  handles.temp = zeros(nbpms,1);
end

set([handles.FIRSTBPM handles.LASTBPM],'String',handles.BPM_pvs);
handles.firstbpmN = 1;
handles.firstbpm  = handles.BPM_pvs(1);
set(handles.FIRSTBPM,'Value',1);
handles.lastbpmN  = length(handles.BPM_pvs);
handles.lastbpm   = handles.BPM_pvs(end);
set(handles.LASTBPM ,'Value',nbpms);
handles.fitpointE = handles.BPM_pvs{1};
set(handles.FITPOINT,'String',handles.fitpointE);
handles.Z0=handles.Zs(1);   % get Z0 of fitpoint

set(handles.MSG,'String','Getting BPM R-matrices...')
drawnow
r=model_rMatGet(handles.fitpointE,handles.BPM_pvs);
set(handles.MSG,'String',' ')
drawnow
handles.R1s=permute(r(1,[1 2 3 4 6],:),[3 2 1]);
handles.R3s=permute(r(3,[1 2 3 4 6],:),[3 2 1]);

[handles.XsR,handles.YsR,handles.TsR,handles.Xs,handles.Ys,handles.Ts, ...
    handles.dXs,handles.dYs,handles.dTs] = deal(0*handles.Zs);
%handles.bx02 = lcaGetSmart('BEND:IN20:751:BACT');
%handles.bxs  = lcaGetSmart('BEND:IN20:931:BACT');
%handles.bx12 = lcaGetSmart('BEND:IN20:231:BACT');
set(handles.STARTSTOP,'String','Start')
set(handles.STARTSTOP,'Enable','on')
guidata(hObject,handles);


% --- Executes on button press in STARTSTOP.
function STARTSTOP_Callback(hObject, eventdata, handles)

nbpms = length(handles.BPM_pvs(:,1));
tags={'Start' 'Stop'};
colr={'green' 'red '};
if ~strcmp('loadOrbit',get(hObject,'Tag'))
    set(hObject,'String',tags{get(hObject,'Value')+1});
    set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});
end
h_fig = figure(1);
set(h_fig,'DefaultAxesFontName','Times','DefaultAxesFontSize',16);
set(h_fig,'DefaultTextFontName','Times','DefaultTextFontSize',16);
set(h_fig,'DefaultLineLineWidth',2,'DefaultLineMarkerSize',2);
h_x = subplot(3,1,1,'Parent',h_fig);
h_y = subplot(3,1,2,'Parent',h_fig);
h_t = subplot(3,1,3,'Parent',h_fig);
handles.exportFig=1; % Added 08/05/2007, H. Loos
set(h_fig,'Color',handles.region_color)
%only make the menus once
% isMenu = findobj(h_fig,'Type', 'uimenu');
% if  ~any(isMenu)
%         handles.menuH = uimenu(h_fig,'Label', 'X Scale', 'Callback', 'dir');
%         uimenu(h_fig,'Label', 'Y Scale', 'Callback', 'setScale');
%         uimenu(h_fig,'Label', 'T Scale', 'Callback', 'setScale');  
% end



while get(hObject,'Value')
  tstr = get_time;
  try
    rate = lcaGetSmart(handles.beamRatePV);   % rep. rate [Hz]
  catch
    disp(['Error on lcaGetSmart for ' handles.beamRatePV ' - defaulting to 1 Hz rate.'])
    rate = 1;
  end
  if rate < 1
    rate = 1;
  end

  if handles.one_shot
    lcaPut(handles.beamOffPV,1);                % turn ON beam at MPS shutter
    set(handles.MSG,'String','Pockels cell shutter enabled')
    set(handles.MSG,'ForegroundColor','green')
    disp('MPS shutter enabled')
    pause(1.05/rate)                                    % at 30 Hz I get a one-shot with no misses (1.25 * 1/30)
  end

  if handles.region == 9                                        % if FACET
      [X,Y,T]=control_bpmAidaGet(handles.BPM_pvs,handles.navg);
      dX=std(X,0,2)';X=mean(X,2)';
      dY=std(Y,0,2)';Y=mean(Y,2)';
      dT=std(T,0,2)';T=mean(T,2)';
  else
      if ~strcmp('loadOrbit',get(hObject,'Tag')) %Don't update orbit if we got it from SCORE.
         % [X,Y,T,dX,dY,dT,iok] = read_BPMs(handles.BPM_pvs,handles.navg,rate,handles.temp);  % read all BPMs, X, Y, & TMIT with averaging
          [X,Y,T,dX,dY,dT,iok]=control_bpmGetBSA(handles.BPM_pvs,handles.navg,rate, 'eDef', handles.edefN);
      end
        
  end
  
  if ~strcmp('loadOrbit',get(hObject,'Tag')) 
      %Don't update orbit if it is an orbit load callback.
      handles.Xs  =  X';                % mean X-position for all BPMs [mm]
      handles.Ys  =  Y';                % mean Y-position for all BPMs [mm]
      handles.Ts  =  1.602E-10*T';      % mean charge for all BPMs [nC]
      handles.dXs =  dX';               % standard error on mean [mm]
      handles.dYs =  dY';               % standard error on mean [mm]
      handles.dTs =  1.602E-10*dT';     % standard error on mean [nC]
      handles.Xs(isnan(handles.Xs)) = 0;    % zero all NaN readings
      handles.Ys(isnan(handles.Ys)) = 0;    % zero all NaN readings
  end
  if handles.one_shot
    lcaPut(handles.beamOffPV,0);           % turn off beam at MPS shutter
    set(handles.MSG,'String','Pockels cell shutter disabled')
    set(handles.MSG,'ForegroundColor','red')
    disp('MPS shutter disabled')
    for j = 1:length(handles.BPM_pvs)
      disp([handles.BPM_pvs{j} sprintf(':  X=%6.3f mm, Y=%6.3f mm, TMIT=%6.3f nC',X(j),Y(j),handles.Ts(j))])
    end
  end

  MPS = lcaGetSmart(handles.beamOffPV,0,'double');       % read MPS shutter status
  if isnan(MPS)
    MPS = 0;
  end
  if MPS
    set(handles.MSG,'String',' ')
    set(handles.MSG,'ForegroundColor','black')
  end

  if handles.region == 9
      fbck = zeros(size(handles.BPM_pvs));
  else
    try
      fbck = lcaGetSmart(strcat(handles.BPM_pvs,':FBCK'),0,'double');   % find any BPMs that are used by feedback
    catch
      fbck = zeros(size(handles.BPM_pvs));
    end
  end

  try
      screen_in_out = lcaGetSmart(handles.screen_full_pvs,0,'double');   % find any screens INserted
  catch
      screen_in_out = zeros(size(handles.screen_full_pvs));
  end
  screen_in_out = screen_in_out == 1; % BFW's read 1=IN and 2=OUT (switch to 1=IN, 0=OUT)

  toro_pvs=strcat(handles.toroid_pvs,':TMIT');
  if handles.region == 9
      handles.toros = zeros(size(toro_pvs));
  else
    try
      handles.toros = 1.602E-10*lcaGetSmart(toro_pvs,0,'double');   % read all toroids (from 1E9 to nC)
    catch
      handles.toros = zeros(size(toro_pvs));
    end
  end

  if handles.showmagnets
      if handles.region == 9
          [outoftol,offconfig] = deal(zeros(size(handles.magnet_pvs)));
      else
          [outoftol,offconfig] = check_magnet(handles.magnet_pvs);      % read magnets out of tol & set off config values
      end
      ixcor = find(strncmp(handles.magnet_pvs,'X',1));
      iycor = find(strncmp(handles.magnet_pvs,'Y',1));
      iquad = find(strncmp(handles.magnet_pvs,'Q',1) | strncmp(handles.magnet_pvs,'S',1));
      ibend = find(strncmp(handles.magnet_pvs,'B',1));
  end
  
  if handles.diff == 1
    dXs = handles.Xs - handles.XsR;
    dYs = handles.Ys - handles.YsR;
    ylabelX = '\Delta{\itx} (mm)';
    ylabelY = '\Delta{\ity} (mm)';
    titleX  = [handles.region_name ' DIFFERENCE'];
    titleY  = [handles.region_name ' DIFFERENCE'];
  else
    dXs = handles.Xs;
    dYs = handles.Ys;
    ylabelX = '{\itx} (mm)';
    ylabelY = '{\ity} (mm)';
    titleX  = [handles.region_name ' ABSOLUTE'];
    titleY  = [handles.region_name ' ABSOLUTE'];
  end
  
  ix = find(handles.Xs~=0);
  iy = find(handles.Ys~=0);
  it = find(handles.Ts~=0);

  if handles.fiton==1
    ii = handles.firstbpmN:handles.lastbpmN;
    i0 = find(handles.Ts(ii)>0.005);
    if ~isempty(i0)     % if some BPMs have TMIT > 0
      ii = ii(i0);
      ddXs = ones(size(dXs));
      ddYs = ones(size(dYs));
      ddXs(ii) = ddXs(ii)/1E3;    % fit these only by increasing weight
      ddYs(ii) = ddYs(ii)/1E3;    % fit these only by increasing weight
      i = 1:nbpms;
      [Xsf,Ysf,p,dp,chisq,Q] = ...
          xy_traj_fit_kick(dXs(i)',ddXs(i)',dYs(i)',ddYs(i)',0*dXs(i)',0*dYs(i)',handles.R1s(i,:),handles.R3s(i,:),handles.Zs(i),handles.Z0,handles.fitI);	% fit trajectory
      rmsX = std(Xsf(ii)-dXs(ii)');
      rmsY = std(Ysf(ii)-dYs(ii)');
      I = find(handles.fitI);
      if handles.fitI(1) == 1    % if fitting X0
        set(handles.X0,'String',sprintf('%8.5f',p(1)))
        lcaPut(['SIOC:' handles.system ':ML00:AO431'],p(1))
      else
        set(handles.X0,'String',' ')
      end
      if handles.fitI(2) == 1    % if fitting XP0
        set(handles.XP0,'String',sprintf('%8.5f', p(I==2) ))
        lcaPut(['SIOC:' handles.system ':ML00:AO432'], p(I==2))
      else
        set(handles.XP0,'String',' ')
      end
      if handles.fitI(3) == 1    % if fitting Y0
        set(handles.Y0,'String',sprintf('%8.5f', p(I==3) ))
        lcaPut(['SIOC:' handles.system ':ML00:AO433'], p(I==3))
      else
        set(handles.Y0,'String',' ')
      end
      if handles.fitI(4) == 1    % if fitting YP0
        set(handles.YP0,'String',sprintf('%8.5f', p(I==4) ))
        lcaPut(['SIOC:' handles.system ':ML00:AO434'], p(I==4))
      else
        set(handles.YP0,'String',' ')
      end
      if handles.fitI(5) == 1    % if fitting dE/E
        set(handles.dE,'String',sprintf('%8.5f', p(I==5)/10 ))
        lcaPut(['SIOC:' handles.system ':ML00:AO435'], p(I==5)/10)
      else
        set(handles.dE,'String',' ')
      end
      if handles.fitI(6) == 1    % if fitting X-kick
        set(handles.XK,'String',sprintf('%8.5f', p(I==6) ))
        lcaPut(['SIOC:' handles.system ':ML00:AO436'], p(I==6))
      else
        set(handles.XK,'String',' ')
      end
      if handles.fitI(7) == 1    % if fitting Y-kick
        set(handles.YK,'String',sprintf('%8.5f', p(I==7) ))
        lcaPut(['SIOC:' handles.system ':ML00:AO437'], p(I==7))
      else
        set(handles.YK,'String',' ')
      end
      set(handles.RMSX,'String',sprintf('%8.5f',rmsX))
      lcaPut(['SIOC:' handles.system ':ML00:AO438'], rmsX)
      set(handles.RMSY,'String',sprintf('%8.5f',rmsY))
      lcaPut(['SIOC:' handles.system ':ML00:AO439'], rmsY)
      set(handles.MSG,'String','Fit OK')
      set(handles.MSG,'ForegroundColor','blue')
    else        % else if NO BPMs have TMIT > 0
      Xsf = 0*dXs';
      Ysf = 0*dYs';
      set(handles.MSG,'String','No BPMs have TMIT > 0')
      set(handles.MSG,'ForegroundColor','blue')
    end
  else    % if no fits applied...
%    set(handles.MSG, 'String','No fitting applied')
%    set(handles.MSG,'ForegroundColor','black')
    set([handles.X0 handles.XP0 handles.Y0 handles.YP0 handles.dE ...
        handles.XK handles.YK handles.RMSX handles.RMSY],'String',' ');
  end

%  if all(handles.Ts<0.001)  % if no beam (nC)...
%    fac = 0;                % set X & Y data to zero (was latching without beam)
%  else
%    fac = 1;
%  end

  fac = handles.Ts>0.001;
  
  Zmin = min(handles.Zs)-1;
  Zmax = max(handles.Zs)+1;

% plot X...   
  plot(handles.Zs,0*handles.Zs,'dk','Parent',h_x);
  hold(h_x,'on');
  if handles.showmagnets
    itol = find(outoftol(ixcor));
    if ~isempty(itol)
      h_x1 = plot(handles.Zs_magnets(ixcor(itol)),0*handles.Zs_magnets(ixcor(itol)),'r^','Parent',h_x);
      set(h_x1,'MarkerSize',7)
      set(h_x1,'LineWidth',2)
    end
    icon = find(offconfig(ixcor));
    if ~isempty(icon)
      h_x2 = plot(handles.Zs_magnets(ixcor(icon)),0*handles.Zs_magnets(ixcor(icon)),'y^','Parent',h_x);
      set(h_x2,'MarkerSize',7)
      set(h_x2,'MarkerFaceColor','yellow')
    end
    iboth = find(outoftol(ixcor) & offconfig(ixcor));
    if ~isempty(iboth)
      h_x3 = plot(handles.Zs_magnets(ixcor(iboth)),0*handles.Zs_magnets(ixcor(iboth)),'r^','Parent',h_x);
      set(h_x3,'MarkerSize',7)
      set(h_x3,'MarkerFaceColor','yellow')
      set(h_x3,'LineWidth',2)
    end
    titleXM = ' (XCORs: off-config=YELLOW, out-of-tol=RED)';
  else
    titleXM = ' ';
  end

%  hxs  = plot([1;1]*handles.Zs(:)',[0;fac]*dXs(:)','b','Parent',h_x);
  hxs  = plot([1;1]*handles.Zs(:)',[0;1]*(fac'.*dXs(:)'),'b','Parent',h_x);
  iXsat = find(abs(fac.*dXs)>handles.xyscale);
  if ~isempty(iXsat)
    for j = 1:length(iXsat)
      text(handles.Zs(iXsat(j)),0.80*sign(dXs(iXsat(j)))*handles.xyscale,sprintf('%6.2f',dXs(iXsat(j))),'Parent',h_x,'Rotation',0,'FontSize',10,'Color','blue');
    end
  end
  hxse = plot(handles.Zs(handles.etaxi)',sign(dXs(handles.etaxi)').*min(fac(handles.etaxi)'.*abs(dXs(handles.etaxi)'),handles.xyscale),'rs','Parent',h_x);
  set(hxse,'MarkerSize',6)
  if handles.fiton==1
    plot(handles.Zs,Xsf,'--c','Parent',h_x);
    plot(handles.Zs(ii),Xsf(ii),'-b','Parent',h_x);
  end
  plot(get(h_x,'XLim'),[0 0],':k','Parent',h_x);
  
  ifbck = find(fbck==1);
  if ~isempty(ifbck)
    h_xf = plot(handles.Zs(ifbck),0*handles.Zs(ifbck),'dc','Parent',h_x);
    set(h_xf,'MarkerSize',6)
  end
  
  iscr = find(screen_in_out);
  if ~isempty(iscr)
    h_xs = plot(handles.Zs_screens(iscr),0*handles.Zs_screens(iscr),'sm','Parent',h_x);
    set(h_xs,'MarkerSize',6)
    set(h_xs,'MarkerFaceColor','magenta')
  end
  text(Zmin-0.14*(Zmax-Zmin),0,[int2str(rate) ' Hz'],'Parent',h_x,'Rotation',0,'FontSize',16,'Color','blue');
  
  
  axis(h_x,[Zmin Zmax -handles.xyscale handles.xyscale]);
  xlabel(h_x,'Z (m)');
  ylabel(h_x,ylabelX);
  set(hxs,'LineWidth',3);
  if ~isempty(ix)
    Xrms = std(fac(ix).*dXs(ix));
    if isnan(Xrms)
      Xrms = 0;
    end
  else
    Xrms = 0;
  end
  title(h_x,[titleX ':  ' sprintf('Xrms=%5.3f mm',Xrms) sprintf(', Navg=%2.0f',handles.navg) titleXM]);
  hold(h_x,'off');

  
% plot Y...   
  h_y = subplot(3,1,2,'Parent',h_fig);
  plot(handles.Zs,0*handles.Zs,'dk','Parent',h_y);
  hold(h_y,'on');
  if handles.showmagnets
    itol = find(outoftol(iycor));
    if ~isempty(itol)
      h_y1 = plot(handles.Zs_magnets(iycor(itol)),0*handles.Zs_magnets(iycor(itol)),'rv','Parent',h_y);
      set(h_y1,'MarkerSize',7)
      set(h_y1,'LineWidth',2)
    end
    icon = find(offconfig(iycor));
    if ~isempty(icon)
      h_y2 = plot(handles.Zs_magnets(iycor(icon)),0*handles.Zs_magnets(iycor(icon)),'yv','Parent',h_y);
      set(h_y2,'MarkerSize',7)
      set(h_y2,'MarkerFaceColor','yellow')
    end
    iboth = find(outoftol(iycor) & offconfig(iycor));
    if ~isempty(iboth)
      h_y3 = plot(handles.Zs_magnets(iycor(iboth)),0*handles.Zs_magnets(iycor(iboth)),'rv','Parent',h_y);
      set(h_y3,'MarkerSize',7)
      set(h_y3,'MarkerFaceColor','yellow')
      set(h_y3,'LineWidth',2)
    end
    titleYM = ' (YCORs: off-config=YELLOW, out-of-tol=RED)';
  else
    titleYM = ' ';
  end

%  hys = plot([1;1]*handles.Zs(:)',[0;fac]*dYs(:)','g','Parent',h_y);
  hys = plot([1;1]*handles.Zs(:)',[0;1]*(fac'.*dYs(:)'),'g','Parent',h_y);
  iYsat = find(abs(fac.*dYs)>handles.xyscale);
  if ~isempty(iYsat)
    for j = 1:length(iYsat)
      text(handles.Zs(iYsat(j)),0.80*sign(dYs(iYsat(j)))*handles.xyscale,sprintf('%6.2f',dYs(iYsat(j))),'Parent',h_y,'Rotation',0,'FontSize',10,'Color','green');
    end
  end
  hyse = plot(handles.Zs(handles.etayi)',sign(dYs(handles.etayi)').*min(fac(handles.etayi)'.*abs(dYs(handles.etayi)'),handles.xyscale),'rs','Parent',h_y);
  set(hyse,'MarkerSize',6)
  if handles.fiton==1
    plot(handles.Zs,Ysf,'--y','Parent',h_y);
    plot(handles.Zs(ii),Ysf(ii),'-g','Parent',h_y);
  end
  plot(get(h_y,'XLim'),[0 0],':k','Parent',h_y);
  
  ifbck = find(fbck==1);
  if ~isempty(ifbck)
    h_yf = plot(handles.Zs(ifbck),0*handles.Zs(ifbck),'dc','Parent',h_y);
    set(h_yf,'MarkerSize',6)
  end

  iscr = find(screen_in_out);
  if ~isempty(iscr)
    h_ys = plot(handles.Zs_screens(iscr),0*handles.Zs_screens(iscr),'sm','Parent',h_y);
    set(h_ys,'MarkerSize',6)
    set(h_ys,'MarkerFaceColor','magenta')
  end
  axis(h_y,[Zmin Zmax -handles.xyscale handles.xyscale])
  
  
  xlabel(h_y,'Z (m)')
  ylabel(h_y,ylabelY)
  set(hys,'LineWidth',3);
  if ~isempty(iy)
    Yrms = std(fac(iy).*dYs(iy));
    if isnan(Yrms)
      Yrms = 0;
    end
  else
    Yrms = 0;
  end
  title(h_y,[titleY ':  ' sprintf('Yrms = %5.3f mm',Yrms) titleYM])
  hold(h_y,'off');

  if handles.region == 1      % if displaying GUN-SAB region...
      if ~isequal(Xrms,lcaGet('SIOC:SYS0:ML00:AO923'))
          lcaPut('SIOC:SYS0:ML00:AO923',Xrms)    % save GUN-SAB X-trajectory rms in MATLAB variables for archiving
      end
      if ~isequal(Yrms,lcaGet('SIOC:SYS0:ML00:AO924'))
          lcaPut('SIOC:SYS0:ML00:AO924',Yrms)    % save GUN-SAB Y-trajectory rms in MATLAB variables for archiving
      end
  elseif handles.region==2        % if displaying GUN-TD11 region...
      if ~isequal(Xrms,lcaGet('SIOC:SYS0:ML00:AO921'))
          lcaPut('SIOC:SYS0:ML00:AO921',Xrms)    % save GUN-TD11 X-trajectory rms in MATLAB variables for archiving
      end
      if ~isequal(Yrms,lcaGet('SIOC:SYS0:ML00:AO922'))
          lcaPut('SIOC:SYS0:ML00:AO922',Yrms)    % save GUN-TD11 Y-trajectory rms in MATLAB variables for archiving
      end
  elseif handles.region==3      % if displaying GUN-LI21 region...                          % if displaying GUN-LI21 region...
      %    lcaPut('SIOC:SYS0:ML00:AO927',Xrms)    % save GUN-LI21 X-trajectory rms in MATLAB variables for archiving
      %    lcaPut('SIOC:SYS0:ML00:AO928',Yrms)    % save GUN-LI21 Y-trajectory rms in MATLAB variables for archiving
  end

  
% plot TMIT...   
  h_t = subplot(3,1,3,'Parent',h_fig);
  plot(handles.Zs,0*handles.Zs,'dk','Parent',h_t);
  hold(h_t,'on');
  hts = plot([1;1]*handles.Zs(:)',[0;1]*handles.Ts(:)','r','Parent',h_t);
  iscr = find(screen_in_out);
  if ~isempty(iscr)
    h_ts = plot(handles.Zs_screens(iscr),0*handles.Zs_screens(iscr),'sm','Parent',h_t);
    set(h_ts,'MarkerSize',6)
    set(h_ts,'MarkerFaceColor','magenta')
  end

% plot Toroids...
  plot(handles.Zs_toroids,0*handles.Zs_toroids,'ok','Parent',h_t);
  hts = plot([1;1]*handles.Zs_toroids(:)',[0;1]*handles.toros(:)','c','Parent',h_t);

  if handles.showmagnets
      itol = find(outoftol(iquad));     % plot quads out of tol...
      if ~isempty(itol)
        h_t1 = plot(handles.Zs_magnets(iquad(itol)),0*handles.Zs_magnets(iquad(itol)),'rd','Parent',h_t);
        set(h_t1,'MarkerSize',7)
        set(h_t1,'LineWidth',2)
      end
      icon = find(offconfig(iquad));
      if ~isempty(icon)
        h_t2 = plot(handles.Zs_magnets(iquad(icon)),0*handles.Zs_magnets(iquad(icon)),'yd','Parent',h_t);
        set(h_t2,'MarkerSize',7)
        set(h_t2,'MarkerFaceColor','yellow')
      end
      iboth = find(outoftol(iquad) & offconfig(iquad));
      if ~isempty(iboth)
        h_t3 = plot(handles.Zs_magnets(iquad(iboth)),-0.1*handles.Zs_magnets(iquad(iboth)),'rd','Parent',h_t);
        set(h_t3,'MarkerSize',7)
        set(h_t3,'MarkerFaceColor','yellow')
        set(h_t3,'LineWidth',2)
      end

      itol = find(outoftol(ibend));     % plot bends out of tol...
      if ~isempty(itol)
        h_t1 = plot(handles.Zs_magnets(ibend(itol)),0*handles.tscale*handles.Zs_magnets(ibend(itol)),'r^','Parent',h_t);
        set(h_t1,'MarkerSize',8)
        set(h_t1,'LineWidth',2)
      end
      icon = find(offconfig(ibend));
      if ~isempty(icon)
        h_t2 = plot(handles.Zs_magnets(ibend(icon)),0*handles.tscale*handles.Zs_magnets(ibend(icon)),'y^','Parent',h_t);
        set(h_t2,'MarkerSize',8)
        set(h_t2,'MarkerFaceColor','yellow')
      end
      iboth = find(outoftol(ibend) & offconfig(ibend));
      if ~isempty(iboth)
        h_t3 = plot(handles.Zs_magnets(ibend(iboth)),0*handles.tscale*handles.Zs_magnets(ibend(iboth)),'r^','Parent',h_t);
        set(h_t3,'MarkerSize',8)
        set(h_t3,'MarkerFaceColor','yellow')
        set(h_t3,'LineWidth',2)
      end
      titleTM = ' (QUAD/SOL/BENDs: off-config=YELLOW, out-of-tol=RED)';
  else
      titleTM = ' ';
  end
  
  axis(h_t,[Zmin Zmax 0 handles.tscale]);
  ylabel(h_t,'Charge (nC)');
  set(hts,'LineWidth',3);
  text(handles.Zs,handles.Zs*0-handles.tscale*0.5,handles.BPM_units, ...
      'Parent',h_t,'Rotation',90,'FontSize',9,'Color','blue');
  if ~isempty(it)
    Tbar = mean(handles.Ts(1));
  else
    Tbar = 0;
  end
  title(h_t,[sprintf('1st BPM Charge = %5.3f nC',Tbar) ',         ' tstr titleTM]);
  hold(h_t,'off');
  guidata(hObject,handles); % Save current state
  pause(handles.wait); % Allow other callbacks to change state
  handles=guidata(hObject); % Retrieve changed state, Added 08/05/2007, H. Loos
  if handles.one_shot
    set(hObject,'Value',0)
    set(hObject,'String',tags{get(hObject,'Value')+1});
    set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});
    drawnow
  end
  if strcmp('loadOrbit',get(hObject,'Tag')), break; end

end


function WAIT_Callback(hObject, eventdata, handles)
handles.wait = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function WAIT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function XYSCALE_Callback(hObject, eventdata, handles)
handles.xyscale = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function XYSCALE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TSCALE_Callback(hObject, eventdata, handles)
handles.tscale = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function TSCALE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DIFF.
function DIFF_Callback(hObject, eventdata, handles)
handles.diff = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in TAKEREF.
function TAKEREF_Callback(hObject, eventdata, handles)
handles.takeref = get(hObject,'Value');
handles.XsR = handles.Xs;
handles.YsR = handles.Ys;
handles.TsR = handles.Ts;
guidata(hObject,handles);


% --- Executes on selection change in FIRSTBPM.
function FIRSTBPM_Callback(hObject, eventdata, handles)
str = get(hObject,'String');
handles.firstbpmN = get(hObject,'Value');
handles.firstbpm  = str(handles.firstbpmN);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FIRSTBPM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LASTBPM.
function LASTBPM_Callback(hObject, eventdata, handles)
str = get(hObject,'String');
handles.lastbpmN = get(hObject,'Value');
handles.lastbpm  = str(handles.lastbpmN);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function LASTBPM_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FITPOINT_Callback(hObject, eventdata, handles)
handles.fitpointE = get(hObject,'String');
[handles.fitpointE,stat] = model_nameConvert(handles.fitpointE,'EPICS');
if stat==0
  warndlg('Device name not recognized - try again.')
  return
end
set(handles.MSG,'String','Getting BPM R-matrices...')
drawnow
r=model_rMatGet(handles.fitpointE,handles.BPM_pvs);
set(handles.MSG,'String',' ')
drawnow
handles.R1s=permute(r(1,[1 2 3 4 6],:),[3 2 1]);
handles.R3s=permute(r(3,[1 2 3 4 6],:),[3 2 1]);
handles.Z0=model_rMatGet(handles.fitpointE,[],[],'Z');   % get Z0 of fitpoint
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function FITPOINT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FIT0_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI = [0 0 0 0 0 0 0];
  set([handles.FIT1 handles.FIT2 handles.FIT3 handles.FIT4 handles.FIT5 handles.FIT6 handles.FIT7],'Value',0);
  handles.fiton = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
end
guidata(hObject,handles);


function FIT1_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(1) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(1) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


function FIT2_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(2) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(2) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


function FIT3_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(3) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(3) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


function FIT4_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(4) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(4) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


function FIT5_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(5) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(5) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


% --- Executes on button press in FIT6.
function FIT6_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(6) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(6) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


% --- Executes on button press in FIT7.
function FIT7_Callback(hObject, eventdata, handles)
N = get(hObject,'Value');
if N == 1
  handles.fitI(7) = 1;
  set(handles.FIT0,'Value',0);
else
  handles.fitI(7) = 0;
end
if ~any(handles.fitI)
  set(handles.FIT0,'Value',1);
  handles.fiton = 0;
else
  handles.fiton = 1;
end
guidata(hObject,handles);


function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SHOWMAGNETS.
function SHOWMAGNETS_Callback(hObject, eventdata, handles)
handles.showmagnets = get(hObject,'Value');
guidata(hObject,handles);


% Added 08/05/2007, H. Loos
% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)

if ~any(ishandle(handles.exportFig)), return, end
util_printLog(handles.exportFig);


% --- Executes on button press in modelSource_btn.
function modelSource_btn_Callback(hObject, eventdata, handles)

val=strcmp(model_init,'EPICS')+1;
gui_modelSourceControl(hObject, handles, val+1);
set_region(hObject,handles,1);


% --- Executes on button press in ONE_SHOT.
function ONE_SHOT_Callback(hObject, eventdata, handles)
one_shot = get(hObject,'Value');
if one_shot
  yn = questdlg('This enables a one-shot mode and will disable the MPS shutter after clicking "Start".  Do you really want to do this?', 'WARNING: One-Shot Mode', 'No');
else
  yn = 'Yes';
end
if strcmp(yn,'Yes')
  handles.one_shot = one_shot;
else
  handles.one_shot = 0;
  set(handles.ONE_SHOT,'Value',0)
end
guidata(hObject,handles);


% --- Executes on button press in FIRST_BEAM.
function FIRST_BEAM_Callback(hObject, eventdata, handles)
handles.first_beam = get(hObject,'Value');
nbpms = length(handles.BPM_pvs);
if handles.region==4 || handles.region==5
  if handles.first_beam     % if 1st beam in und and using URMS, VRMS, RRMS (amplitudes) rather than X, Y, TMIT
    for j = 1:nbpms
      if handles.BPM_pvs{j}(6) == 'U' || (handles.BPM_pvs{j}(6) == 'L' && handles.BPM_pvs{j}(7) == 'T' && handles.BPM_pvs{j}(11) == '9')
        handles.temp(j) = 1;
      else
        handles.temp(j) = 0;
      end
    end
  else
    handles.temp = zeros(nbpms,1);
  end
else
  handles.temp = zeros(nbpms,1);
end
guidata(hObject,handles);


% --- Executes on button press in loadRefOrbit.
function loadRefOrbit_Callback(hObject, eventdata, handles)
% hObject    handle to loadRefOrbit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.useScoreCheckbox,'Value') % Use SCORE
    
    [Xs, Ys, Ts, names] = orbitFromScore;
    % William Colocho: Remove BPMS:UND1:3395 for now
    [C, ia, ib] = intersect(handles.BPM_pvs, names);
    handles.XsR = Xs(ib);
    handles.YsR = Ys(ib);
    handles.TsR = Ts(ib);
    handles.dX = zeros(size(ib)); 
    handles.dY = zeros(size(ib)); 
    handles.dT = zeros(size(ib)); 
    set(handles.MSG,'String', 'Loaded Reference Orbit')    
else % Use file system
    [data, fileName, pathName] = util_dataLoad;
    handles.XsR = data.Xs;
    handles.YsR = data.Ys;
    handles.TsR = data.Ts;
    handles.dX = zeros(size(data.Xs)); %We did't save this :( sorry.
    handles.dY = zeros(size(dataYs));
    handles.dT = zeros(size(data.Ts));
    set(handles.MSG,'String', ['Loaded Reference from '  pathName(end-10:end-1) ' directory']) 

end
guidata(hObject,handles);





% --- Executes on button press in loadOrbit.
function loadOrbit_Callback(hObject, eventdata, handles)
% hObject    handle to loadOrbit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.useScoreCheckbox,'Value') % Use SCORE
    
    [Xs, Ys, Ts, names] = orbitFromScore;
    [C, ia, ib] = intersect(handles.BPM_pvs, names);
    handles.Xs = Xs(ib);
    handles.Ys = Ys(ib);
    handles.Ts = 1.602E-10 * Ts(ib);
    handles.dX = zeros(size(ib));
    handles.dY = zeros(size(ib));
    handles.dT = zeros(size(ib));
    set(handles.MSG,'String', 'Loaded Orbit from SCORE as data')
    
else
    [data, fileName, pathName] = util_dataLoad;
    
    handles.Xs = data.Xs;
    handles.Ys = data.Ys;
    handles.Ts = data.Ts;
    handles.dXs = data.dXs;
    handles.dYs = data.dYs;
    handles.dTs = data.dTs;
    set(handles.MSG,'String', ['Loaded Orbit from '  pathName(end-10:end-1) ' directory']) 

    
end
guidata(hObject,handles);
STARTSTOP_Callback(hObject, eventdata, handles)






% --- Executes on button press in useScoreCheckbox.
function useScoreCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to useScoreCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useScoreCheckbox


% --- Executes on button press in saveOrbit.
function saveOrbit_Callback(hObject, eventdata, handles)
% hObject    handle to saveOrbit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


data.Xs = handles.Xs;
data.Ys = handles.Ys;
data.Ts = handles.Ts;
data.dXs =  handles.dXs;
data.dYs =  handles.dYs;
data.dTs =  handles.dTs;
[fileName, pathName] = util_dataSave(data, 'bpms_vs_z_gui',[handles.region_name '_orbit'], now,1,0,'.mat');
data.Xs = handles.XsR;
data.Ys = handles.YsR;
data.Ts = handles.TsR;
[fileName, pathName] = util_dataSave(data, 'bpms_vs_z_gui',[handles.region_name '_reference'], now,1,0,'.mat');


set(handles.MSG,'String', ['Saved Orbit and Reference to '  pathName(end-10:end-1) ' directory']) 

 


