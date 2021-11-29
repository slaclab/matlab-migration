function varargout = scan_backlash_gui(varargin)
% SCAN_BACKLASH_GUI M-file for scan_backlash_gui.fig
%      SCAN_BACKLASH_GUI, by itself, creates a new SCAN_BACKLASH_GUI or raises the existing
%      singleton*.
%
%      H = SCAN_BACKLASH_GUI returns the handle to a new SCAN_BACKLASH_GUI or the handle to
%      the existing singleton*.
%
%      SCAN_BACKLASH_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCAN_BACKLASH_GUI.M with the given input arguments.
%
%      SCAN_BACKLASH_GUI('Property','Value',...) creates a new SCAN_BACKLASH_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scan_backlash_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scan_backlash_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scan_backlash_gui

% Last Modified by GUIDE v2.5 10-Feb-2009 14:48:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scan_backlash_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @scan_backlash_gui_OutputFcn, ...
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


% --- Executes just before scan_backlash_gui is made visible.
function scan_backlash_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scan_backlash_gui (see VARARGIN)

handles.fakedata = get(handles.FAKE,'Value');
handles.show_avg = get(handles.SHOW_AVG,'Value');
ig = get(handles.GIRDER,'Value');
gs = str2double(get(handles.GIRDER,'String'));
handles.girder = gs(ig);
ixy = get(handles.XORY,'Value');
xy  = get(handles.XORY,'String');
handles.xory = lowcase(cell2mat(xy(ixy)));
handles.dMOV_lo = str2double(get(handles.dMOV_LO,'String'));
handles.dMOV_hi = str2double(get(handles.dMOV_HI,'String'));
handles.dMOV_step = str2double(get(handles.dMOV_STEP,'String'));
handles.navg = str2double(get(handles.NAVG,'String'));
handles.nsamples = str2double(get(handles.NSAMPLES,'String'));
handles.BPM_pvs = {
           'BPMS:LTU1:750'
           'BPMS:LTU1:760'
           'BPMS:LTU1:770'
           'BPMS:LTU1:820'
           'BPMS:LTU1:840'
           'BPMS:LTU1:860'
           'BPMS:LTU1:880'
           'BPMS:LTU1:910'
           'BPMS:LTU1:960'
           'BPMS:UND1:100'
           'BPMS:UND1:190'
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
           'BPMS:DMP1:398'
                           };
handles.nbpms = length(handles.BPM_pvs);
handles = calc_MOV(hObject,handles);
set(handles.MSG,'String','Ready')
drawnow
handles.fdbkList={'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE'};

% Choose default command line output for scan_backlash_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scan_backlash_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = scan_backlash_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN') && ~handles.fakedata
  set(handles.START,'BackgroundColor','white')
  set(handles.START,'String','TDUND IN...')
  disp('TDUND is IN - scan aborted.')
  set(handles.MSG,'String','TDUND is IN - scan aborted.')
  drawnow
  pause(0.5)
  set(handles.START,'BackgroundColor','green')
  set(handles.START,'String','Start')
  drawnow
  return
end
set(handles.START,'BackgroundColor','white')
set(handles.MSG,'String','Started...')
drawnow
global modelSource modelOnline
modelSource='EPICS';modelOnline=0;
handles.Xkick  = zeros(handles.nsamples,length(handles.ddMOV));
handles.Ykick  = zeros(handles.nsamples,length(handles.ddMOV));
handles.dXkick = zeros(handles.nsamples,length(handles.ddMOV));
handles.dYkick = zeros(handles.nsamples,length(handles.ddMOV));
X = zeros(1,length(handles.ddMOV));
Y = zeros(1,length(handles.ddMOV));
unit = zeros(handles.nbpms,1);
for j = 1:length(handles.BPM_pvs)
  str = cell2mat(handles.BPM_pvs(j));
  unit(j) = str2int(str(11:end));
end
iBPMoff = find(unit==190);   % 1st und BPM (190) is this index in the above PV list
ibpm  = (handles.girder+iBPMoff-1-min(10,handles.girder+iBPMoff-2)):(handles.girder+iBPMoff-1+min(10,handles.nbpms-(handles.girder+iBPMoff)+1));
Zs   = model_rMatGet(handles.BPM_pvs,[],{},'Z');
Z0   = Zs(handles.girder+iBPMoff-1);
R    = model_rMatGet(handles.BPM_pvs(handles.girder+iBPMoff-1),handles.BPM_pvs);
R1s  = permute(R(1,[1 2 3 4 6],:),[3 2 1]);
R3s  = permute(R(3,[1 2 3 4 6],:),[3 2 1]);
fdbk_on = lcaGetSmart(handles.fdbkList,0,'double');     % get state of und feedback
lcaPutSmart(handles.fdbkList,0);                        % turn off und feedback
if ~handles.fakedata
  if strcmp(handles.xory(1),'x')
    disp('Moving girder by -5 um in X (standardizing)')
    set(handles.MSG,'String','Moving girder by -5 um in X (standardizing)')
    drawnow
    girderQuadMove(handles.girder,-0.005,0);
    girderCamWait(handles.girder);
    pause(2)
    disp('Moving girder by +5 um in X (standardizing)')
    set(handles.MSG,'String','Moving girder by +5 um in X (standardizing)')
    drawnow
    girderQuadMove(handles.girder, 0.005,0);
    girderCamWait(handles.girder);
  else
    disp('Moving girder by -5 um in Y (standardizing)')
    set(handles.MSG,'String','Moving girder by -5 um in Y (standardizing)')
    drawnow
    girderQuadMove(handles.girder,0,-0.005);
    girderCamWait(handles.girder);
    pause(2)
    disp('Moving girder by +5 um in Y (standardizing)')
    set(handles.MSG,'String','Moving girder by +5 um in Y (standardizing)')
    drawnow
    girderQuadMove(handles.girder,0, 0.005);
    girderCamWait(handles.girder);
  end
end
pause(2)
[Xs0,Ys0,Ts0,dXs0,dYs0,dTs0,beam0,abort0] = read_orbit(handles.BPM_pvs,handles.navg,0.2,handles.fakedata);
if abort0
  set(handles.START,'BackgroundColor','green')
  set(handles.START,'String','Start')
  set(handles.MSG,'String','Scan aborted.')
  disp('Scan aborted.')
  lcaPutSmart(handles.fdbkList,fdbk_on);                  % restore state of und feedback
  drawnow
  return
end
charge_lim = mean(Ts0);
[X0,Y0] = girderQUADposition(handles.girder);
MOV = zeros(size(handles.ddMOV));
for j = 1:length(handles.ddMOV)
  set(handles.START,'String',sprintf('%2.0f/%2.0f...',j,length(handles.ddMOV)))
  disp(' ')
  drawnow
  MOV(j) = sum(handles.ddMOV(1:j));
  if strcmp(handles.xory(1),'x')
    if ~handles.fakedata
      girderQuadMove(handles.girder,handles.ddMOV(j),0);
    end
    disp(sprintf('Moving girder %2.0f in X to %4.1f um',handles.girder,MOV(j)*1E3))
    set(handles.MSG,'String',sprintf('Moving girder %2.0f in X to %4.1f um',handles.girder,MOV(j)*1E3))
    drawnow
  else
    if ~handles.fakedata
      girderQuadMove(handles.girder,0,handles.ddMOV(j));
    end
    disp(sprintf('Moving girder %2.0f in Y to %4.1f um',handles.girder,MOV(j)*1E3))
    set(handles.MSG,'String',sprintf('Moving girder %2.0f in Y to %4.1f um',handles.girder,MOV(j)*1E3))
    drawnow
  end
  if ~handles.fakedata
    girderCamWait(handles.girder);
  end
  pause(3)
  [X(j),Y(j)] = girderQUADposition(handles.girder);
  for k = 1:handles.nsamples
    [Xs,Ys,Ts,dXs,dYs,dTs,beam,abort] = read_orbit(handles.BPM_pvs,handles.navg,charge_lim*0.85,handles.fakedata);
    disp(sprintf('Girder position = %4.1f um, sample # %1.0f',MOV(j)*1E3,k))
    set(handles.MSG,'String',sprintf('Girder position = %4.1f um, sample # %1.0f',MOV(j)*1E3,k))
    drawnow
    if abort
      if strcmp(handles.xory(1),'x')
        if ~handles.fakedata
          girderQuadMove(handles.girder,-MOV(j),0);     % restore x-girder before quitting
        end
      else
        if ~handles.fakedata
          girderQuadMove(handles.girder,0,-MOV(j));     % restore y-girder before quitting
        end
      end
      if ~handles.fakedata
        girderCamWait(handles.girder);
      end
      set(handles.START,'BackgroundColor','green')
      set(handles.START,'String','Start')
      set(handles.MSG,'String','Scan aborted - girder position restored.')
      disp('Scan aborted - girder position restored.')
      drawnow
      lcaPutSmart(handles.fdbkList,fdbk_on);                  % restore state of und feedback
      return
    end
%    [Xsf,Ysf,p,dp,chisq] = xy_traj_fit_kick(Xs(ibpm),dXs(ibpm),Ys(ibpm),dYs(ibpm),Xs0(ibpm),Ys0(ibpm),R1s(ibpm,:),R3s(ibpm,:),Zs(ibpm),Z0,[1 1 1 1 0 1 1]);	% fit trajectory
    [Xsf,Ysf,p,dp,chisq] = xy_traj_fit_kick(Xs(ibpm),1,Ys(ibpm),1,Xs0(ibpm),Ys0(ibpm),R1s(ibpm,:),R3s(ibpm,:),Zs(ibpm),Z0,[1 1 1 1 0 1 1]);	% fit trajectory
    handles.Xkick(k,j)  =  p(5);
    handles.Ykick(k,j)  =  p(6);
    handles.dXkick(k,j) = dp(5)*sqrt(chisq);
    handles.dYkick(k,j) = dp(6)*sqrt(chisq);
  end
  plot_data(0,hObject,handles,j)
end
lcaPutSmart(handles.fdbkList,fdbk_on);                  % restore state of und feedback
if ~abort
  plot_data(0,hObject,handles,j)
end
set(handles.START,'BackgroundColor','green')
set(handles.START,'String','Start')
disp('Done - girder position restored.')
set(handles.MSG,'String','Done - girder position restored.')
drawnow
guidata(hObject,handles);



function plot_data(Elog_fig,hObject,handles,j)
if Elog_fig
  figure(Elog_fig)
else
  axes(handles.AXES1)
end
if strcmp(handles.xory(1),'x')
  kick = handles.Xkick;
else
  kick = handles.Ykick;
end
x = cumsum(handles.ddMOV)*1E3;
dx = [1 diff(x(1:j))];
iup = find(dx>=0);
idn = find(dx<0);
if handles.show_avg
  ku  = mean(kick(:,iup))*1E6;
  dku = std(kick(:,iup))/sqrt(handles.nsamples-1)*1E6;
  kd  = mean(kick(:,idn))*1E6;
  dkd = std(kick(:,idn))/sqrt(handles.nsamples-1)*1E6;
  errorbar(x(iup),ku,dku,'r^','MarkerFaceColor','r','Color','k','MarkerEdgeColor','r','MarkerSize',8)
  hold on
  errorbar(x(idn),kd,dkd,'bv','MarkerFaceColor','b','Color','k','MarkerEdgeColor','b','MarkerSize',8)
  if j < length(x)
    plot(x(j),mean(kick(:,j))*1E6,'y.','MarkerFaceColor','y')
  end
  hold off
else
  ku  = kick(:,iup)*1E6;
  kd  = kick(:,idn)*1E6;
  plot(x(iup),ku,'r^','MarkerFaceColor','r','Color','k','MarkerEdgeColor','r','MarkerSize',8)
  hold on
  plot(x(idn),kd,'bv','MarkerFaceColor','b','Color','k','MarkerEdgeColor','b','MarkerSize',8)
  hold off
end
xlabel(['Girder#' num2str(handles.girder,'%2.0f') ' Quad ' handles.xory(1) '-position (microns)'])
ylabel([handles.xory(1) '-kick angle (nrad)'])
title([get_time ' (RED=up, BLUE=down)'])
xlim([min(x)-0.5 max(x)+0.5])
hor_line(0);
ver_line(0);



function dMOV_LO_Callback(hObject, eventdata, handles)
handles.dMOV_lo = str2double(get(hObject,'String'));
if handles.dMOV_lo < -200
  handles.dMOV_lo = -200;
  set(handles.dMOV_LO,'String',num2str(handles.dMOV_lo))
  warndlg('Girder lower limit cannot be < -200 micron','WARNING')
end
if handles.dMOV_lo > -0.1
  handles.dMOV_lo = -0.1;
  set(handles.dMOV_LO,'String',num2str(handles.dMOV_lo))
  warndlg('Girder lower limit cannot be > -0.1 micron','WARNING')
end
handles = calc_MOV(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function dMOV_LO_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dMOV_HI_Callback(hObject, eventdata, handles)
handles.dMOV_hi = str2double(get(hObject,'String'));
if handles.dMOV_hi < 0.1
  handles.dMOV_hi = 0.1;
  set(handles.dMOV_HI,'String',num2str(handles.dMOV_hi))
  warndlg('Girder upper limit cannot be < 0.1 micron','WARNING')
end
if handles.dMOV_hi > 200
  handles.dMOV_hi = 200;
  set(handles.dMOV_HI,'String',num2str(handles.dMOV_hi))
  warndlg('Girder upper limit cannot be > +200 micron','WARNING')
end
handles = calc_MOV(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function dMOV_HI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dMOV_STEP_Callback(hObject, eventdata, handles)
handles.dMOV_step = str2double(get(hObject,'String'));
if handles.dMOV_step < 0.1
  handles.dMOV_step = 0.1;
  set(handles.dMOV_STEP,'String',num2str(handles.dMOV_step))
  warndlg('Girder movement step size cannot be < 0.1 micron','WARNING')
end
if handles.dMOV_step > 10
  handles.dMOV_step = 10;
  set(handles.dMOV_STEP,'String',num2str(handles.dMOV_step))
  warndlg('Girder movement step size cannot be > 10 microns','WARNING')
end
handles = calc_MOV(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function dMOV_STEP_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in XORY.
function XORY_Callback(hObject, eventdata, handles)
ixy = get(hObject,'Value');
xy  = get(hObject,'String');
handles.xory = lowcase(cell2mat(xy(ixy)));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function XORY_CreateFcn(hObject, eventdata, handles)
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



function NSAMPLES_Callback(hObject, eventdata, handles)
handles.nsamples = str2double(get(hObject,'String'));
if handles.nsamples < 2
  handles.nsamples = 2;
  set(handles.NSAMPLES,'String',num2str(handles.nsamples))
  warndlg('Number of orbit-reads per girder setting cannot be < 2','WARNING')
end
if handles.nsamples > 10
  handles.nsamples = 10;
  set(handles.NSAMPLES,'String',num2str(handles.nsamples))
  warndlg('Number of shots to average cannot be > 10','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NSAMPLES_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in GIRDER.
function GIRDER_Callback(hObject, eventdata, handles)
ig = get(hObject,'Value');
gs = str2double(get(hObject,'String'));
handles.girder = gs(ig);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GIRDER_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in printLog.
function printLog_Callback(hObject, eventdata, handles)
plot_data(1,hObject,handles,length(handles.ddMOV))
util_printLog(1);
guidata(hObject,handles);



% --- Executes on button press in FAKE.
function FAKE_Callback(hObject, eventdata, handles)
handles.fakedata = get(hObject,'Value');
guidata(hObject,handles);


function handles = calc_MOV(hObject,handles)
handles.dMOV  = [0:handles.dMOV_step:handles.dMOV_hi (handles.dMOV_hi-handles.dMOV_step):(-handles.dMOV_step):handles.dMOV_lo (handles.dMOV_lo+handles.dMOV_step):handles.dMOV_step:0]*1E-3;
handles.ddMOV = [0 diff(handles.dMOV)];
guidata(hObject,handles);


% --- Executes on button press in SHOW_AVG.
function SHOW_AVG_Callback(hObject, eventdata, handles)
handles.show_avg = get(hObject,'Value');
guidata(hObject,handles);
plot_data(0,hObject,handles,length(handles.ddMOV))
guidata(hObject,handles);


