function varargout = steer_undulator_gui(varargin)
% STEER_UNDULATOR_GUI M-file for steer_undulator_gui.fig
%      STEER_UNDULATOR_GUI, by itself, creates a new STEER_UNDULATOR_GUI or
%      raises the existing
%      singleton*.
%
%      H = STEER_UNDULATOR_GUI returns the handle to a new STEER_UNDULATOR_GUI or the handle to
%      the existing singleton*.
%
%      STEER_UNDULATOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STEER_UNDULATOR_GUI.M with the given input arguments.
%
%      STEER_UNDULATOR_GUI('Property','Value',...) creates a new STEER_UNDULATOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before steer_undulator_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to steer_undulator_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help steer_undulator_gui

% Last Modified by GUIDE v2.5 26-Oct-2012 17:03:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @steer_undulator_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @steer_undulator_gui_OutputFcn, ...
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



% --- Executes just before steer_undulator_gui is made visible.
function steer_undulator_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to steer_undulator_gui (see VARARGIN)

handles.fakedata = 0;   % if ==1, uses fake BPM data and does NOT change any setting
handles.navg = str2double(get(handles.NAVG,'String'));
handles.nsections = str2double(get(handles.NSECTIONS,'String'));
set(handles.CALC,'Enable','off')
set(handles.APPLY,'Enable','off')
set(handles.UNDO,'Enable','off')
set(handles.printLog_btn1,'Enable','off')
iqc = get(handles.QUAD_CORS,'Value');
qc  = get(handles.QUAD_CORS,'String');
handles.girder_steer = get(handles.GIRDER_STEER,'Value') - 1;   % if ==0, use any steerers; if >0, use that girder only
handles.girder = get(handles.GIRDER,'Value');
ixy = get(handles.XORY,'Value');
xy  = get(handles.XORY,'String');
handles.xory = cell2mat(xy(ixy));
ixy = get(handles.XY1,'Value');
xy  = get(handles.XY1,'String');
handles.xy1 = cell2mat(xy(ixy));
handles.noinj = get(handles.NOINJ,'Value');
set(handles.UNDO_ZERO_BPM,'Enable','off')
handles.quad_or_cor = lower(cell2mat(qc(iqc)));

global modelSource modelOnline
modelSource='EPICS';modelOnline=0;

handles.BPM_pvs   =   {
%                       'BPMS:LTU1:910'
%                       'BPMS:LTU1:960'
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
                                        };

handles.XCOR_pvs   =  {
                       'XCOR:LTU1:758'
                       'XCOR:LTU1:878'
                       'XCOR:UND1:180'
                       'XCOR:UND1:280'
                       'XCOR:UND1:380'
                       'XCOR:UND1:480'
                       'XCOR:UND1:580'
                       'XCOR:UND1:680'
                       'XCOR:UND1:780'
                       'XCOR:UND1:880'
                       'XCOR:UND1:980'
                       'XCOR:UND1:1080'
                       'XCOR:UND1:1180'
                       'XCOR:UND1:1280'
                       'XCOR:UND1:1380'
                       'XCOR:UND1:1480'
                       'XCOR:UND1:1580'
                       'XCOR:UND1:1680'
                       'XCOR:UND1:1780'
                       'XCOR:UND1:1880'
                       'XCOR:UND1:1980'
                       'XCOR:UND1:2080'
                       'XCOR:UND1:2180'
                       'XCOR:UND1:2280'
                       'XCOR:UND1:2380'
                       'XCOR:UND1:2480'
                       'XCOR:UND1:2580'
                       'XCOR:UND1:2680'
                       'XCOR:UND1:2780'
                       'XCOR:UND1:2880'
                       'XCOR:UND1:2980'
                       'XCOR:UND1:3080'
                       'XCOR:UND1:3180'
                       'XCOR:UND1:3280'
                       'XCOR:UND1:3380'
                                        };
                     
handles.YCOR_pvs   =  {'YCOR:LTU1:747'
                       'YCOR:LTU1:857'
                       'YCOR:UND1:180'
                       'YCOR:UND1:280'
                       'YCOR:UND1:380'
                       'YCOR:UND1:480'
                       'YCOR:UND1:580'
                       'YCOR:UND1:680'
                       'YCOR:UND1:780'
                       'YCOR:UND1:880'
                       'YCOR:UND1:980'
                       'YCOR:UND1:1080'
                       'YCOR:UND1:1180'
                       'YCOR:UND1:1280'
                       'YCOR:UND1:1380'
                       'YCOR:UND1:1480'
                       'YCOR:UND1:1580'
                       'YCOR:UND1:1680'
                       'YCOR:UND1:1780'
                       'YCOR:UND1:1880'
                       'YCOR:UND1:1980'
                       'YCOR:UND1:2080'
                       'YCOR:UND1:2180'
                       'YCOR:UND1:2280'
                       'YCOR:UND1:2380'
                       'YCOR:UND1:2480'
                       'YCOR:UND1:2580'
                       'YCOR:UND1:2680'
                       'YCOR:UND1:2780'
                       'YCOR:UND1:2880'
                       'YCOR:UND1:2980'
                       'YCOR:UND1:3080'
                       'YCOR:UND1:3180'
                       'YCOR:UND1:3280'
                       'YCOR:UND1:3380'
                                        };

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
                       'QUAD:UND1:3380'
                                        };

handles.nbpms  = length(handles.BPM_pvs);
handles.nxcors = length(handles.XCOR_pvs);
handles.nycors = length(handles.YCOR_pvs);

handles.BPM_Zs  = model_rMatGet(handles.BPM_pvs,[],{},'Z')';
str = 'Getting BPM Zs...'; 
disp(str)
set(handles.MSG,'String',str)
drawnow

handles.XCOR_Zs = model_rMatGet(handles.XCOR_pvs,[],{},'Z')';
str = 'Getting XCOR Zs...';
disp(str)
set(handles.MSG,'String',str)
drawnow

handles.YCOR_Zs = model_rMatGet(handles.YCOR_pvs,[],{},'Z')';
str = 'Getting YCOR Zs...';
disp(str)
set(handles.MSG,'String',str)
drawnow

RXB = model_rMatGet(handles.XCOR_pvs(1),handles.BPM_pvs);
str = 'Getting XCOR-to-BPM R-Mats...';
disp(str)
set(handles.MSG,'String',str)
drawnow

RYB = model_rMatGet(handles.YCOR_pvs(1),handles.BPM_pvs);
str = 'Getting YCOR-to-BPM R-Mats...';
disp(str)
set(handles.MSG,'String',str)
drawnow

RXC = model_rMatGet(handles.XCOR_pvs(1),handles.XCOR_pvs);
str = 'Getting XCOR-to-XCOR R-Mats...';
disp(str)
set(handles.MSG,'String',str)
drawnow

RYC = model_rMatGet(handles.YCOR_pvs(1),handles.YCOR_pvs);
str = 'Getting YCOR-to-YCOR R-Mats...';
disp(str)
set(handles.MSG,'String',str)
drawnow

Z1 = 1;
for j = 1:handles.nbpms
  str = cell2mat(handles.BPM_pvs(j));
  if strcmp(str(11:13),'190')
    Z1 = handles.BPM_Zs(j);
    break
  end
end

Z33 = 33;
for j = 1:handles.nbpms
  str = cell2mat(handles.BPM_pvs(j));
  if strcmp(str(11:13),'339')
    Z33 = handles.BPM_Zs(j);
  end
end

m = (33 - 1)/(Z33 - Z1);
handles.BPM_Is  = m*(handles.BPM_Zs)  + (1 - m*Z1);   % approx. girder number per BPM scaled from Z
handles.XCOR_Is = m*(handles.XCOR_Zs) + (1 - m*Z1);   % approx. girder number per XCOR scaled from Z
handles.YCOR_Is = m*(handles.YCOR_Zs) + (1 - m*Z1);   % approx. girder number per YCOR scaled from Z


handles.QUAD_BDES_pvs = strcat(handles.QUAD_pvs,':BDES');
handles.BDES = lcaGetSmart(handles.QUAD_BDES_pvs);

handles.E0 = lcaGetSmart('BEND:DMP1:400:BDES');

handles.QX = zeros(handles.nbpms,handles.nxcors);
handles.QY = zeros(handles.nbpms,handles.nycors);

for j = 1:handles.nxcors
  for k = 1:handles.nbpms
    if handles.XCOR_Zs(j) < handles.BPM_Zs(k)
      invR =inv(RXC(:,:,j));
      R = RXB(:,:,k)*invR;
      handles.QX(k,j) = R(1,2);
    else
      handles.QX(k,j) = 0;
    end
  end
end
for j = 1:handles.nycors
  for k = 1:handles.nbpms
    if handles.YCOR_Zs(j) < handles.BPM_Zs(k)
      invR =inv(RYC(:,:,j));
      R = RYB(:,:,k)*invR;
      handles.QY(k,j) = R(3,4);
    else
      handles.QY(k,j) = 0;
    end
  end
end
str = 'Ready...';
disp(str)
set(handles.MSG,'String',str)
drawnow
handles.fdbkList={'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE'};

% Added on 10/26/12 by Rich Jones and Ben Ripman to support "zero
% correctors" and "undo" functions
handles.xcor_bctrl = lcaGetSmart(strcat(handles.XCOR_pvs(3:34),':BCTRL'));
handles.ycor_bctrl = lcaGetSmart(strcat(handles.YCOR_pvs(3:34),':BCTRL'));

% Choose default command line output for steer_undulator_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes steer_undulator_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = steer_undulator_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in READ_BPMS.
function READ_BPMS_Callback(hObject, eventdata, handles)
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN')
  set(handles.MSG,'String','TDUND is IN - scan aborted.')
  warndlg('TDUND is IN - no beam - scan aborted.','Stopper is IN')
  if ~handles.fakedata
    return
  end
end
Q0   = lcaGetSmart('IOC:IN20:BP01:QANN');           % Get lower charge limit from BPM attenuation factor (nC)
[sys,accelerator]=getSystem();
rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);   % rep. rate [Hz]
if rate < 10
  yn = questdlg('Beam rate is <10 Hz.  Do you want to continue?','Low Beam Rate');
  if ~strcmp(yn,'Yes')
    set(handles.MSG,'String','Beam rate is <10 Hz - scan aborted.')
    if ~handles.fakedata
      return
    end
  end
end
set(handles.READ_BPMS,'BackgroundColor','white')
set(handles.READ_BPMS,'String','wait...')
drawnow
[handles.Xs,handles.Ys,Ts,dXs,dYs,dTs,beam,abort] = read_orbit(handles.BPM_pvs,handles.navg,max([Q0/5 0.005]),handles.fakedata);
handles.Xs = 1E-3*handles.Xs';
handles.Ys = 1E-3*handles.Ys';
if abort
  set(handles.READ_BPMS,'BackgroundColor','green')
  str = 'BPM read aborted by user';
  disp(str)
  set(handles.MSG,'String',str)
  drawnow
  return
end
set(handles.READ_BPMS,'BackgroundColor','green')
set(handles.READ_BPMS,'String','Read BPMs')
set(handles.CALC,'Enable','on')
drawnow
handles = CALC_Callback(hObject, eventdata, handles);
guidata(hObject,handles);



% --- Executes on button press in CALC.
function handles = CALC_Callback(hObject, eventdata, handles)
handles.E0 = lcaGetSmart('BEND:DMP1:400:BDES');
set(handles.CALC,'BackgroundColor','white')
drawnow
ibpm = round(handles.nbpms/handles.nsections);
[Xsl,dXsl,pxl,dpxl] = fit(handles.QX(1:ibpm,1:2),handles.Xs(1:ibpm));   % fit the incoming X-launch
[Ysl,dYsl,pyl,dpyl] = fit(handles.QY(1:ibpm,1:2),handles.Ys(1:ibpm));   % fit the incoming Y-launch
Xsc = handles.Xs - handles.QX(:,1:2)*pxl;
Ysc = handles.Ys - handles.QY(:,1:2)*pyl;
handles.Xsf = Xsc;
handles.Ysf = Ysc;
handles.px = zeros(1,handles.nxcors);
handles.py = zeros(1,handles.nycors);

jj = 0;
if handles.girder_steer==0
  kk = round(3:((handles.nxcors-3)/handles.nsections):handles.nxcors);
else
  kk = [handles.girder_steer+2 handles.girder_steer+2];
end
for k = kk
  jj = jj + 1;
  if k == handles.nxcors || (kk(1)==kk(2) && jj>1)
    break
  end
  xrmsj = ones(handles.nxcors,1);
  for j = kk(jj):kk(jj+1)
    jbpm = find(handles.BPM_Zs>handles.XCOR_Zs(j));
    [Xsj,dXsj,pxj(j),dpxj] = fit(handles.QX(jbpm(1:min(ibpm,length(jbpm))),j),handles.Xsf(jbpm(1:min(ibpm,length(jbpm)))));
    xrmsj(j) = std(handles.Xsf(jbpm(1:min(ibpm,length(jbpm))))-Xsj);
  end
  xrmsj(xrmsj==0) = 1;  % don't allow xrmsj=0 to be a solution (otherwise last BPM gets perfect fix by one mover)
  [minx,ix] = min(xrmsj);
  handles.Xsf = handles.Xsf - handles.QX(:,ix)*pxj(ix);
  handles.px(ix) = pxj(ix);
end

jj = 0;
if handles.girder_steer==0
  kk = round(3:((handles.nycors-3)/handles.nsections):handles.nycors);
else
  kk = [handles.girder_steer+2 handles.girder_steer+2];
end
for k = kk
  jj = jj + 1;
  if k == handles.nycors || (kk(1)==kk(2) && jj>1)
    break
  end
  yrmsj = ones(handles.nycors,1);
  for j = kk(jj):kk(jj+1)
    jbpm = find(handles.BPM_Zs>handles.YCOR_Zs(j));
    [Ysj,dYsj,pyj(j),dpyj] = fit(handles.QY(jbpm(1:min(ibpm,length(jbpm))),j),handles.Ysf(jbpm(1:min(ibpm,length(jbpm)))));
    yrmsj(j) = std(handles.Ysf(jbpm(1:min(ibpm,length(jbpm))))-Ysj);
  end
  yrmsj(yrmsj==0) = 1;  % don't allow yrmsj=0 to be a solution (otherwise last BPM gets perfect fix by one mover)
  [miny,iy] = min(yrmsj);
  handles.Ysf = handles.Ysf - handles.QY(:,iy)*pyj(iy);
  handles.py(iy) = pyj(iy);
end
if (strcmp(handles.xy1,'X & Y') || strcmp(handles.xy1,'X-only'));
  xfac = 1;
else
  xfac = 0; % no x-correction to be applied
end
if (strcmp(handles.xy1,'X & Y') || strcmp(handles.xy1,'Y-only'));
  yfac = 1;
else
  yfac = 0; % no y-correction to be applied
end
handles.Brho = handles.E0*1E10/2.99792458E8;
handles.xmov = -handles.Brho*handles.px(3:end)*xfac./handles.BDES';
handles.ymov =  handles.Brho*handles.py(3:end)*yfac./handles.BDES';
handles.px(1:2) = pxl;
handles.py(1:2) = pyl;

handles.girders = find(abs(handles.xmov)>2E-7 | abs(handles.ymov)>2E-7);

handles.XCOR_BDES0 = lcaGetSmart(strcat(handles.XCOR_pvs(1:2),':BDES'));
handles.YCOR_BDES0 = lcaGetSmart(strcat(handles.YCOR_pvs(1:2),':BDES'));
if handles.noinj
  handles.XCOR_BDES  = handles.XCOR_BDES0;
  handles.YCOR_BDES  = handles.YCOR_BDES0;
else
  handles.XCOR_BDES  = handles.XCOR_BDES0 - handles.Brho*handles.px(1:2)';
  handles.YCOR_BDES  = handles.YCOR_BDES0 - handles.Brho*handles.py(1:2)';
end
XCOR_name = model_nameConvert(handles.XCOR_pvs(1:2),'MAD');
YCOR_name = model_nameConvert(handles.YCOR_pvs(1:2),'MAD');

display_changes(handles.girders,handles.xmov,handles.ymov,XCOR_name,YCOR_name,handles.XCOR_BDES0,handles.YCOR_BDES0,handles.XCOR_BDES,handles.YCOR_BDES)

plot_und_traj(0,hObject,handles)

str = 'Orbit read and correction calcuated (see terminal window for list)';
disp(str)
set(handles.MSG,'String',str)
set(handles.CALC,'BackgroundColor',[240 240 240]/255)
%set(handles.CALC,'Enable','off')
set(handles.APPLY,'Enable','on')
%set(handles.UNDO,'Enable','off')
set(handles.printLog_btn1,'Enable','on')
drawnow
guidata(hObject,handles);



function display_changes(girders,xmov,ymov,XCOR_name,YCOR_name,XCOR_BDES0,YCOR_BDES0,XCOR_BDES,YCOR_BDES)
disp(' ')
disp(' Girder   XMOV/um   YMOV/um')
disp(' ==========================')
for j = 1:length(girders)
  str = sprintf('   %2.0f     %6.1f    %6.1f',girders(j),xmov(girders(j))'*1E6,ymov(girders(j))'*1E6);
  disp(str)
end
disp(' ')
disp(' Corrector BDES changes:')
disp(' =======================')
for j = 1:2
  str = sprintf(' %s BDES: %8.5f -> %8.5f kG-m,  %s BDES: %8.5f -> %8.5f kG-m',cell2mat(XCOR_name(j)),XCOR_BDES0(j),XCOR_BDES(j),cell2mat(YCOR_name(j)),YCOR_BDES0(j),YCOR_BDES(j));
  disp(str)
end
disp(' ')



function plot_und_traj(Elog_fig,hObject,handles)
if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(2,1,1);
  ax3 = subplot(2,1,2);
else
  ax1 = handles.AXES1;
  ax3 = handles.AXES3;
end

axes(ax1)
plot(handles.BPM_Is,handles.Xs*1E6,'-b.',handles.BPM_Is,handles.Xsf*1E6,'--c.','LineWidth',1)
ylabel('X-BPMs and \DeltaXMOV (\mum)')
title(['SOLID=present, DASH=predicted, BAR=quad-move, ' sprintf('Xrms = %5.1f um -> %5.1f um, ',1E6*std(handles.Xs),1E6*std(handles.Xsf)) get_time])
xlim([min([handles.XCOR_Is(3:end)' handles.BPM_Is(:)']) max([handles.XCOR_Is(3:end)' handles.BPM_Is(:)'])])
hor_line(0,'k:')
hold on
plot([1;1]*handles.XCOR_Is(3:end)',[0;1]*handles.xmov*1E6,'g-','LineWidth',4)
%xlabel('Girder Number')
set(ax1,'XGrid','on')
%set(ax1,'XMinorGrid','on')
set(ax1,'XMinorTick','on')
hold off

axes(ax3)
plot(handles.BPM_Is,handles.Ys*1E6,'-g.',handles.BPM_Is,handles.Ysf*1E6,'--r.','LineWidth',1)
ylabel('Y-BPMs and \DeltaYMOV (\mum)')
title(['SOLID=present, DASH=predicted, BAR=quad-move' sprintf('Yrms = %5.1f um -> %5.1f um',1E6*std(handles.Ys),1E6*std(handles.Ysf))])
xlim([min([handles.YCOR_Is(3:end)' handles.BPM_Is(:)']) max([handles.YCOR_Is(3:end)' handles.BPM_Is(:)'])])
hor_line(0,'k:')
hold on
plot([1;1]*handles.YCOR_Is(3:end)',[0;1]*handles.ymov*1E6,'b-','LineWidth',4)
xlabel('Girder Number')
set(ax3,'XGrid','on')
%set(ax3,'XMinorGrid','on')
set(ax3,'XMinorTick','on')
hold off



% --- Executes on button press in APPLY.
function APPLY_Callback(hObject, eventdata, handles)
use_cors = 0;
if strcmp(handles.quad_or_cor,'quadrupole movers');
  xcor_bdes = lcaGetSmart(strcat(handles.XCOR_pvs(3:end),':BDES'));   % If using quad moves, check if any X or YCOR's are ON first...
  ycor_bdes = lcaGetSmart(strcat(handles.YCOR_pvs(3:end),':BDES'));
  ix = find(abs(xcor_bdes)>1E-6);
  iy = find(abs(ycor_bdes)>1E-6);
  if ~(isempty(ix) && isempty(iy))
    yn = questdlg('One or more undulator corrector BDES values are >1E-6 kG-m.  Do you want to continue?','Correctors are ON');
    if ~strcmp(yn,'Yes')
      set(handles.MSG,'String','Correctors are ON - APPLY aborted.')
      return
    end
  end
else
  use_cors = 1;
end

set(handles.APPLY,'String','wait...')
set(handles.APPLY,'BackgroundColor','white')
drawnow

XMOV_OK = 1;
if ~use_cors
  for j = handles.girders
    if abs(handles.xmov(j)) > 1E-3
      XMOV_OK = 0;
      str = ['Girder-' num2str(handles.girders,'%2.0f') ' is beyond 1-mm X-limits - no X-correction applied.'];
      disp(str)
      set(handles.MSG,'String',str)
      drawnow
    end
  end
end

YMOV_OK = 1;
if ~use_cors
  for j = handles.girders
    if abs(handles.ymov(j)) > 1E-3
      YMOV_OK = 0;
      str = ['Girder-' num2str(handles.girders,'%2.0f') ' is beyond 1-mm Y-limits - no Y-correction applied.'];
      disp(str)
      set(handles.MSG,'String',str)
      drawnow
    end
  end
end

if ~use_cors
  if ~isempty(handles.girders)
    if XMOV_OK && YMOV_OK
      [X0,Y0] = girderQUADposition(handles.girders);
      if ~handles.fakedata
        girderQuadMove(handles.girders,handles.xmov(handles.girders)*1E3,handles.ymov(handles.girders)*1E3); % move X-quads
        girderCamWait(handles.girders);
      end
      pause(2)
      [X1,Y1] = girderQUADposition(handles.girders);
    end
  else
    str = 'No quad moves needed.';
    disp(str)
    set(handles.MSG,'String',str)
    drawnow
  end
  handles.xcors = -handles.xmov(handles.girders).*handles.BDES(handles.girders)';
  handles.ycors =  handles.ymov(handles.girders).*handles.BDES(handles.girders)';
else                                                % if using steering coils rather than quad moves...
  XCOR_pvs = handles.XCOR_pvs(handles.girders+2);   % X-dipole-correctors used to correct
  YCOR_pvs = handles.YCOR_pvs(handles.girders+2);   % Y-dipole-correctors used to correct
  handles.xcors = -handles.xmov(handles.girders).*handles.BDES(handles.girders)';
  handles.ycors =  handles.ymov(handles.girders).*handles.BDES(handles.girders)';
  xbdes=lcaGetSmart(strcat(XCOR_pvs,':BCTRL'));
  ybdes=lcaGetSmart(strcat(YCOR_pvs,':BCTRL'));
  if ~handles.fakedata
    lcaPutSmart(strcat(XCOR_pvs,':BCTRL'),xbdes-handles.xcors(:));
    lcaPutSmart(strcat(YCOR_pvs,':BCTRL'),ybdes-handles.ycors(:));
  end
end

XCOR_BMAX = lcaGetSmart(strcat(handles.XCOR_pvs(1:2),':BMAX'));
YCOR_BMAX = lcaGetSmart(strcat(handles.YCOR_pvs(1:2),':BMAX'));

X_OK = 1;
for j = 1:2
  if abs(handles.XCOR_BDES(j)) > XCOR_BMAX(j)
    X_OK = 0;
    str = [cell2mat(handles.XCOR_pvs(j)) ' is beyond BMAX limits - no X-correction applied.'];
    disp(str)
    set(handles.MSG,'String',str)
    drawnow
  end
end

Y_OK = 1;
for j = 1:2
  if abs(handles.YCOR_BDES(j)) > YCOR_BMAX(j)
    Y_OK = 0;
    str = [cell2mat(handles.YCOR_pvs(j)) ' is beyond BMAX limits - no Y-correction applied.'];
    disp(str)
    set(handles.MSG,'String',str)
    drawnow
  end
end

fdbk = lcaGetSmart(handles.fdbkList,0,'double');
if ~handles.fakedata    % set LTU launch (probably not necessary)
  lcaPutSmart(handles.fdbkList,0)
  pause(1)
  if X_OK
    lcaPutSmart(strcat(handles.XCOR_pvs(1:2),':BCTRL'),handles.XCOR_BDES);
  end
  if Y_OK
    lcaPutSmart(strcat(handles.YCOR_pvs(1:2),':BCTRL'),handles.YCOR_BDES);
  end
  pause(1)
  lcaPutSmart(handles.fdbkList,fdbk)
end
handles.XCOR_BDESA  = handles.XCOR_BDES;
handles.YCOR_BDESA  = handles.YCOR_BDES;
handles.XCOR_BDES0A = handles.XCOR_BDES0;
handles.YCOR_BDES0A = handles.YCOR_BDES0;

handles.girdersA = handles.girders;
handles.xmovA = handles.xmov;
handles.ymovA = handles.ymov;
handles.xcorsA = handles.xcors;
handles.ycorsA = handles.ycors;

set(handles.APPLY,'String','Apply')
set(handles.APPLY,'BackgroundColor','yellow')
set(handles.APPLY,'Enable','off')
set(handles.UNDO,'Enable','on')
drawnow
guidata(hObject,handles);



function NAVG_Callback(hObject, eventdata, handles)
handles.navg = str2double(get(hObject,'String'));
if handles.navg < 1
  handles.navg = 1;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be < 1','WARNING')
end
if handles.navg > 15000
  handles.navg = 15000;
  set(handles.NAVG,'String',num2str(handles.navg))
  warndlg('Number of shots to average cannot be > 15000','WARNING')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NSECTIONS_Callback(hObject, eventdata, handles)
handles.nsections = str2double(get(hObject,'String'));
if handles.nsections < 1
  handles.nsections = 1;
  set(handles.NSECTIONS,'String',num2str(handles.nsections))
  warndlg('Number of undulator divisions cannot be < 1','WARNING')
end
if handles.nsections > 16
  handles.nsections = 16;
  set(handles.NSECTIONS,'String',num2str(handles.nsections))
  warndlg('Number of undulator divisions cannot be > 16','WARNING')
end
set(handles.CALC,'Enable','on')
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NSECTIONS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in UNDO.
function UNDO_Callback(hObject, eventdata, handles)
set(handles.UNDO,'String','wait...')
set(handles.UNDO,'BackgroundColor','white')
drawnow
if strcmp(handles.quad_or_cor,'quadrupole movers');
  if ~isempty(handles.girdersA)
    [X0,Y0] = girderQUADposition(handles.girdersA);
    if ~handles.fakedata
      girderQuadMove(handles.girdersA,-handles.xmovA(handles.girdersA)*1E3,-handles.ymovA(handles.girdersA)*1E3);   % signs flipped for UNDO
      girderCamWait(handles.girdersA);
    end
    pause(2)
    [X1,Y1] = girderQUADposition(handles.girdersA);
  else
    str = 'No quad moves needed.';
    disp(str)
    set(handles.MSG,'String',str)
    drawnow
  end
else
  XCOR_pvs = handles.XCOR_pvs(handles.girdersA+2);   % X-dipole-correctors used to correct
  YCOR_pvs = handles.YCOR_pvs(handles.girdersA+2);   % Y-dipole-correctors used to correct
  handles.xcors =  handles.xmovA(handles.girdersA).*handles.BDES(handles.girdersA)';    % signs flipped for UNDO
  handles.ycors = -handles.ymovA(handles.girdersA).*handles.BDES(handles.girdersA)';    % signs flipped for UNDO
  xbdes=lcaGetSmart(strcat(XCOR_pvs,':BCTRL'));
  ybdes=lcaGetSmart(strcat(YCOR_pvs,':BCTRL'));
  if ~handles.fakedata
    lcaPutSmart(strcat(XCOR_pvs,':BCTRL'),xbdes-handles.xcors(:));
    lcaPutSmart(strcat(YCOR_pvs,':BCTRL'),ybdes-handles.ycors(:));
  end
end

fdbk = lcaGetSmart(handles.fdbkList,0,'double');
if ~handles.fakedata
  lcaPutSmart(handles.fdbkList,0)
  pause(1)
  lcaPutSmart(strcat(handles.XCOR_pvs(1:2),':BCTRL'),handles.XCOR_BDES0A);
  lcaPutSmart(strcat(handles.YCOR_pvs(1:2),':BCTRL'),handles.YCOR_BDES0A);
  pause(1)
  lcaPutSmart(handles.fdbkList,fdbk)
end

XCOR_name = model_nameConvert(handles.XCOR_pvs(1:2),'MAD');
YCOR_name = model_nameConvert(handles.YCOR_pvs(1:2),'MAD');

display_changes(handles.girdersA,-handles.xmovA,-handles.ymovA,XCOR_name,YCOR_name,handles.XCOR_BDESA,handles.YCOR_BDESA,handles.XCOR_BDES0A,handles.YCOR_BDES0A)

set(handles.UNDO,'String','Undo')
set(handles.UNDO,'BackgroundColor',[255 177 100]/255)
set(handles.APPLY,'Enable','off')
set(handles.UNDO,'Enable','off')
drawnow



% --- Executes on button press in printLog_btn1.
function printLog_btn1_Callback(hObject, eventdata, handles)
plot_und_traj(1,hObject,handles)
util_printLog(1);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
util_appClose(hObject);



% --- Executes on selection change in QUAD_CORS.
function QUAD_CORS_Callback(hObject, eventdata, handles)
iqc = get(hObject,'Value');
qc  = get(hObject,'String');
handles.quad_or_cor = lower(cell2mat(qc(iqc)));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function QUAD_CORS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in ZERO_BPM.
function ZERO_BPM_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
TDUND = lcaGetSmart('DUMP:LTU1:970:TGT_STS');
if strcmp(TDUND,'IN')
  set(handles.MSG,'String','TDUND is IN - action aborted.')
  warndlg('TDUND is IN - no beam - action aborted.','Stopper is IN')
  if ~handles.fakedata
    return
  end
end
bpmpv = ['BPMS:UND1:' num2str(handles.girder) '90'];
[X,Y,Q,dX,dY,dQ,beam,abort] = read_orbit(bpmpv,handles.navg);
if Q < 0.005 || isnan(Q) || isnan(X) || isnan(Y)
  warndlg(sprintf('BPM #%2.0f charge is below 5 pC, or NaN X & Y readings - no action taken.',handles.girder),'CHARGE TOO LOW')
  if ~handles.fakedata
    return
  end
end
handles.xoffpv = ['BPMS:UND1:' num2str(handles.girder) '90:XAOFF'];
handles.yoffpv = ['BPMS:UND1:' num2str(handles.girder) '90:YAOFF'];
handles.XAOFF = lcaGetSmart(handles.xoffpv);
handles.YAOFF = lcaGetSmart(handles.yoffpv);
DX   = handles.XAOFF - X;  % new X-offset [mm]
DY   = handles.YAOFF - Y;  % new Y-offset [mm]
if strcmp(handles.xory,'X & Y') || strcmp(handles.xory,'X-only')
  disp(sprintf('BPM X-reading:    %7.4f mm',X));
  disp(sprintf('Old BPM X-offset: %7.4f mm',handles.XAOFF));
  disp(sprintf('New BPM X-offset: %7.4f mm',DX));
end
if strcmp(handles.xory,'X & Y') || strcmp(handles.xory,'Y-only')
  disp(sprintf('BPM Y-reading:    %7.4f mm',Y));
  disp(sprintf('Old BPM Y-offset: %7.4f mm',handles.YAOFF));
  disp(sprintf('New BPM Y-offset: %7.4f mm',DY));
end
yn = questdlg(sprintf('This will change the BPM offset(s) on undulator girder #%2.0f.  Do you really want to do this?',handles.girder),'CAUTION');
if strcmp(yn,'Yes')
  set(handles.ZERO_BPM,'BackgroundColor','white')
  drawnow
  set(handles.UNDO_ZERO_BPM,'Enable','on')
  if strcmp(handles.xory,'X & Y') || strcmp(handles.xory,'X-only')
    if ~handles.fakedata
      lcaPutSmart(handles.xoffpv,DX);
    end
  end
  if strcmp(handles.xory,'X & Y') || strcmp(handles.xory,'Y-only')
    if ~handles.fakedata
      lcaPutSmart(handles.yoffpv,DY);
    end
  end
  pause(0.5)
  set(handles.MSG,'String','BPM offset(s) updated')
  set(handles.ZERO_BPM,'BackgroundColor','yellow')
  drawnow
end
guidata(hObject,handles);



% --- Executes on selection change in XORY.
function XORY_Callback(hObject, eventdata, handles)
ixy = get(hObject,'Value');
xy  = get(hObject,'String');
handles.xory = cell2mat(xy(ixy));
set(handles.UNDO_ZERO_BPM,'Enable','off')
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function XORY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in GIRDER.
function GIRDER_Callback(hObject, eventdata, handles)
handles.girder = get(hObject,'Value');
set(handles.UNDO_ZERO_BPM,'Enable','off')
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GIRDER_CreateFcn(hObject, eventdata, handles)
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in UNDO_ZERO_BPM.
function UNDO_ZERO_BPM_Callback(hObject, eventdata, handles)
XAOFF0 = lcaGetSmart(handles.xoffpv);
YAOFF0 = lcaGetSmart(handles.yoffpv);
if ~handles.fakedata
  lcaPutSmart(handles.xoffpv,handles.XAOFF);
  lcaPutSmart(handles.yoffpv,handles.YAOFF);
end
disp(sprintf('Old BPM X-offset: %7.4f mm',XAOFF0));
disp(sprintf('New BPM X-offset: %7.4f mm',handles.XAOFF));
disp(sprintf('Old BPM Y-offset: %7.4f mm',YAOFF0));
disp(sprintf('New BPM Y-offset: %7.4f mm',handles.YAOFF));
set(handles.MSG,'String','BPM offset(s) backed out')
drawnow
set(handles.UNDO_ZERO_BPM,'Enable','off')



% --- Executes on selection change in GIRDER_STEER.
function GIRDER_STEER_Callback(hObject, eventdata, handles)
handles.girder_steer = get(hObject,'Value') - 1;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GIRDER_STEER_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in XY1.
function XY1_Callback(hObject, eventdata, handles)
ixy = get(hObject,'Value');
xy  = get(hObject,'String');
handles.xy1 = cell2mat(xy(ixy));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function XY1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NOINJ.
function NOINJ_Callback(hObject, eventdata, handles)
handles.noinj = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in ZeroCorrectors.
function ZeroCorrectors_Callback(hObject, eventdata, handles)
% hObject    handle to ZeroCorrectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Assuming all corrector BCTL values are not currently 0, save old bctrl
% values and then set all bctrl values to zero
if max(abs(lcaGetSmart(strcat(handles.XCOR_pvs(3:34),':BCTRL')))) > 0
    handles.xcor_bctrl = lcaGetSmart(strcat(handles.XCOR_pvs(3:34),':BCTRL'));
    handles.ycor_bctrl = lcaGetSmart(strcat(handles.YCOR_pvs(3:34),':BCTRL'));
    lcaPutSmart(strcat(handles.XCOR_pvs(3:34),':BCTRL'), 0);
    lcaPutSmart(strcat(handles.YCOR_pvs(3:34),':BCTRL'), 0);
end



% --- Executes on button press in UndoZeroCorrectors.
function UndoZeroCorrectors_Callback(hObject, eventdata, handles)
% hObject    handle to UndoZeroCorrectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set all bctrl values to the values saved when using zero correctors
% function
lcaPutSmart(strcat(handles.XCOR_pvs(3:34),':BCTRL'), handles.xcor_bctrl);
lcaPutSmart(strcat(handles.YCOR_pvs(3:34),':BCTRL'), handles.ycor_bctrl);




