function varargout = magnet_plotter(varargin)
% MAGNET_PLOTTER M-file for magnet_plotter.fig
%      MAGNET_PLOTTER, by itself, creates a new MAGNET_PLOTTER or raises the existing
%      singleton*.
%
%      H = MAGNET_PLOTTER returns the handle to a new MAGNET_PLOTTER or the handle to
%      the existing singleton*.
%
%      MAGNET_PLOTTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAGNET_PLOTTER.M with the given input arguments.
%
%      MAGNET_PLOTTER('Property','Value',...) creates a new MAGNET_PLOTTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before magnet_plotter_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to magnet_plotter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help magnet_plotter

% Last Modified by GUIDE v2.5 27-Mar-2009 13:11:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @magnet_plotter_OpeningFcn, ...
                   'gui_OutputFcn',  @magnet_plotter_OutputFcn, ...
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


% --- Executes just before magnet_plotter is made visible.
function magnet_plotter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to magnet_plotter (see VARARGIN)

% Choose default command line output for magnet_plotter
handles.output = hObject;

handles.mag_list = {
    'SOLN:IN20:111'
    'SOLN:IN20:121'
    'SOLN:IN20:311'
    'QUAD:IN20:121'
    'QUAD:IN20:122'
    'QUAD:IN20:361'
    'QUAD:IN20:371'
    'QUAD:IN20:425'
    'QUAD:IN20:441'
    'QUAD:IN20:511'
    'QUAD:IN20:525'
    'QUAD:IN20:631'
    'QUAD:IN20:651'
    'QUAD:IN20:731'
    'QUAD:IN20:771'
    'QUAD:IN20:781'
    'QUAD:IN20:941'
    'QUAD:IN20:961'
    'QUAD:LI21:131'
    'QUAD:LI21:161'
    'QUAD:LI21:211'
    'QUAD:LI21:221'
    'QUAD:LI21:251'
    'QUAD:LI21:271'
    'QUAD:LI21:278'
    'QUAD:LI21:315'
    'QUAD:LI21:335'
    'XCOR:IN20:121'
    'XCOR:IN20:221' 
    'XCOR:IN20:311' 
    'XCOR:IN20:341' 
    'XCOR:IN20:381' 
    'XCOR:IN20:411' 
    'XCOR:IN20:491' 
    'XCOR:IN20:521' 
    'XCOR:IN20:641' 
    'XCOR:IN20:721' 
    'XCOR:IN20:761' 
    'XCOR:IN20:811' 
    'XCOR:IN20:831' 
    'XCOR:IN20:911' 
    'XCOR:IN20:951' 
    'XCOR:LI21:101' 
    'XCOR:LI21:135' 
    'XCOR:LI21:165' 
    'XCOR:LI21:191' 
    'XCOR:LI21:275' 
    'XCOR:LI21:325' 
    'YCOR:IN20:122' 
    'YCOR:IN20:222' 
    'YCOR:IN20:312' 
    'YCOR:IN20:342' 
    'YCOR:IN20:382' 
    'YCOR:IN20:412' 
    'YCOR:IN20:492' 
    'YCOR:IN20:522' 
    'YCOR:IN20:642' 
    'YCOR:IN20:722' 
    'YCOR:IN20:762' 
    'YCOR:IN20:812' 
    'YCOR:IN20:832' 
    'YCOR:IN20:912' 
    'YCOR:IN20:952' 
    'YCOR:LI21:102' 
    'YCOR:LI21:136' 
    'YCOR:LI21:166' 
    'YCOR:LI21:192' 
    'YCOR:LI21:276' 
    'YCOR:LI21:325' 
    'BEND:IN20:231' 
    'BTRM:IN20:231' 
    'BTRM:IN20:451' 
    'BTRM:IN20:475' 
    'BTRM:IN20:481' 
    'BEND:IN20:461' 
    'BTRM:IN20:661' 
    'BEND:IN20:751' 
    'BEND:IN20:931' 
    'BEND:LI21:231' 
    'BTRM:LI21:215' 
    'BTRM:LI21:241' 
    'BTRM:LI21:261'
                                    };
handles.nmagnets = length(handles.mag_list);
for j = 1:handles.nmagnets
%  SLC_name = model_nameConvert(handles.mag_list{j},'SLC');
  MAD_name = model_nameConvert(handles.mag_list{j},'MAD');
  handles.mag_listp{j} = [handles.mag_list{j} '  (' MAD_name ')'];
end
set(handles.MAGNET_SELECT,'String',handles.mag_listp);
handles.imag_list = 1;
handles.magnet_pv  = handles.mag_list{handles.imag_list};
handles.delta_days = 24;
set(handles.LAST24HRS,'Value',1);
set(handles.BACT_BDES_DIFF,'Value',3);  % default to DIFF plots
handles.bact_bdes_diff = get(handles.BACT_BDES_DIFF,'Value');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes magnet_plotter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = magnet_plotter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function MAGNET_SELECT_Callback(hObject, eventdata, handles)
handles.imag_list = get(hObject,'Value');
handles.magnet_pv  = handles.mag_list{handles.imag_list};
guidata(hObject,handles);


function MAGNET_SELECT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PLOTREAL_Callback(hObject, eventdata, handles)
tags={'plot real time' 'running...'};
colr={'green' 'white '};
set(hObject,'String',tags{get(hObject,'Value')+1});
set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});
if get(hObject,'Value') == 0
  return
end
BDES_pv = [handles.magnet_pv ':BDES'];
BACT_pv = [handles.magnet_pv ':BACT'];
TOL1_pv = [handles.magnet_pv ':TRIMBTOL'];
TOL3_pv = [handles.magnet_pv ':CHCKBTOL'];
EGU_pv  = [handles.magnet_pv ':BDES.EGU'];
EGU     = cell2mat(lcaGet(EGU_pv));
[dum,ti] = lcaGet(BACT_pv);
t0 = real(ti);
t  = t0;
j = 0;
while get(hObject,'Value')
  j = j + 1;
  [BACT(j),ti] = lcaGet(BACT_pv);
  BDES(j) = lcaGet(BDES_pv);
  TOL3(j) = lcaGet(TOL3_pv);
  TOL1(j) = lcaGet(TOL1_pv);
  t(j) = real(ti);
  dt = t - t0;
  plot(dt,BACT,'.g',dt,BDES,'b-',dt,BDES+TOL3,'r-',dt,BDES-TOL3,'r-',dt,BDES+TOL1,'y-',dt,BDES-TOL1,'y-');
  xlabel('time (sec)');
  ylabel([BACT_pv ' (' EGU ')']);
  title([handles.mag_listp{handles.imag_list} sprintf(',  BACT = %11.7f ',BACT(j)) EGU]);
  ylim([(BDES(j)-2*TOL3(j)) (BDES(j)+2*TOL3(j))])
  pause(0.5);
end
guidata(hObject,handles);



function PLOTHIST_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==1
  handles.tols_scale = 0;
  set(handles.PLOTHIST,'BackgroundColor','white')
  set(handles.PLOTHIST,'String','working...')
  drawnow
  T0 = now;
  T1 = T0 - handles.delta_days;
  date_time  = datestr(T0);
  date_str   = datestr(datenum(date_time(1:11),'dd-mmm-yyyy'),23);
  date_time0 = [date_str date_time(12:20)];
  date_time  = datestr(T1);
  date_str   = datestr(datenum(date_time(1:11),'dd-mmm-yyyy'),23);
  date_time1 = [date_str date_time(12:20)];
  BMAX_pv = [handles.magnet_pv ':BMAX'];
  BDES_pv = [handles.magnet_pv ':BDES'];
  BACT_pv = [handles.magnet_pv ':BACT'];
  TOL1_pv = [handles.magnet_pv ':TRIMBTOL'];
  TOL3_pv = [handles.magnet_pv ':CHCKBTOL'];
  EGU_pv  = [handles.magnet_pv ':BDES.EGU'];
  EGU     = cell2mat(lcaGet(EGU_pv));
  [values,times] = get_archive(BACT_pv,date_time1,date_time0,0);
  if handles.tols_scale
    [BDES,times] = get_archive(BDES_pv,date_time1,date_time0,0);
    BMAX    = lcaGet(BMAX_pv);
    TOL1    = lcaGet(TOL1_pv);
    TOL3    = lcaGet(TOL3_pv);
    y = 100*(values - BDES)/BMAX;
    ylab = [handles.magnet_pv '(BACT - BDES)/BMAX (%)'];
  else
    TOL1    = lcaGet(TOL1_pv);
    TOL3    = lcaGet(TOL3_pv);
    y = values;
    ylab = [BACT_pv ' (' EGU ')'];
  end
  plot(datenum(times),y,'.g-');
  datetick('x');
  hor_line(y(end)+TOL3,'r-')
  hor_line(y(end)-TOL3,'r-')
  hor_line(y(end)+TOL1,'y-')
  hor_line(y(end)-TOL1,'y-')
  xlabel(sprintf('%s to %s',times(1,:),times(end,:)));
  ylabel(ylab);
  title([handles.mag_listp{handles.imag_list} sprintf(', rms=%5.3e, Npts=%5.3e',std(y),length(y))]);
  set(handles.PLOTHIST,'Value',0)
  set(handles.PLOTHIST,'BackgroundColor','yellow')
  set(handles.PLOTHIST,'String','plot history')
  drawnow
else
  return
end
guidata(hObject,handles);


function LAST1HR_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  set(handles.LAST8HRS,'Value',0);
  set(handles.LAST24HRS,'Value',0);
  set(handles.LAST7DAYS,'Value',0);
  set(handles.LAST30DAYS,'Value',0);
  handles.delta_days = 1/24;
else
  set(handles.LAST1HR,'Value',1);
end
guidata(hObject,handles);


function LAST8HRS_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  set(handles.LAST1HR,'Value',0);
  set(handles.LAST24HRS,'Value',0);
  set(handles.LAST7DAYS,'Value',0);
  set(handles.LAST30DAYS,'Value',0);
  handles.delta_days = 8/24;
else
  set(handles.LAST8HRS,'Value',1);
end
guidata(hObject,handles);


function LAST24HRS_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  set(handles.LAST1HR,'Value',0);
  set(handles.LAST8HRS,'Value',0);
  set(handles.LAST7DAYS,'Value',0);
  set(handles.LAST30DAYS,'Value',0);
  handles.delta_days = 1;
else
  set(handles.LAST24HRS,'Value',1);
end
guidata(hObject,handles);


function LAST7DAYS_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  set(handles.LAST1HR,'Value',0);
  set(handles.LAST8HRS,'Value',0);
  set(handles.LAST24HRS,'Value',0);
  set(handles.LAST30DAYS,'Value',0);
  handles.delta_days = 7;
else
  set(handles.LAST7DAYS,'Value',1);
end
guidata(hObject,handles);



function LAST30DAYS_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
  set(handles.LAST1HR,'Value',0);
  set(handles.LAST8HRS,'Value',0);
  set(handles.LAST24HRS,'Value',0);
  set(handles.LAST7DAYS,'Value',0);
  handles.delta_days = 30;
else
  set(handles.LAST30DAYS,'Value',1);
end
guidata(hObject,handles);



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



% --- Executes on selection change in BACT_BDES_DIFF.
function BACT_BDES_DIFF_Callback(hObject, eventdata, handles)
handles.bact_bdes_diff = get(hObject,'Value');  % BACT=1, BDES=2, DIFF=3
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function BACT_BDES_DIFF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


