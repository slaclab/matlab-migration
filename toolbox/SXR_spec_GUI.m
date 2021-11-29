function varargout = SXR_spec_GUI(varargin)
% SXR_SPEC_GUI M-file for SXR_spec_GUI.fig
%      SXR_SPEC_GUI, by itself, creates a new SXR_SPEC_GUI or raises the
%      existing
%      singleton*.
%
%      H = SXR_SPEC_GUI returns the handle to a new SXR_SPEC_GUI or the handle to
%      the existing singleton*.
%
%      SXR_SPEC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SXR_SPEC_GUI.M with the given input arguments.
%
%      SXR_SPEC_GUI('Property','Value',...) creates a new SXR_SPEC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SXR_spec_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SXR_spec_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SXR_spec_GUI

% Last Modified by GUIDE v2.5 12-Jan-2012 15:44:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SXR_spec_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SXR_spec_GUI_OutputFcn, ...
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


% --- Executes just before SXR_spec_GUI is made visible.
function SXR_spec_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SXR_spec_GUI (see VARARGIN)

[sys,accelerator]=getSystem();

handles.PVlist = {'SXR:EXS:HIST' 'SXR:EXS:HISTP';'XPP:OPAL1K:1:LiveImage:HPrj' 'XPP:OPAL1K:1:LiveImage:HPrj'};
handles.nameList = {'SXR' 'XPP'};
handles.sourceSel=1;
set(handles.sourceSel_pmu,'String',handles.nameList);
handles=sourceSel_pmu_Callback(handles.sourceSel_pmu,[],handles);
%handles.PV_avg = 'SXR:EXS:HIST';
%handles.PV_ss  = 'SXR:EXS:HISTP';
handles.method = {'Gaussian' 'Asym-Gauss' 'Super-Gauss' 'RMS' 'RMS-cut-pk' 'RMS-cut-area'};
%handles.calcoef = str2double(get(handles.CALCOEF,'String'));
handles.ss  = get(handles.SS,'Value');
handles.avg  = get(handles.AVG1,'Value');
handles.navg = str2double(get(handles.NAVG,'String'));
handles.rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);
handles.fitype = round(get(handles.FITYPE,'Value'));
set(handles.FITYPE,'Value',handles.fitype)
handles.methstr = cell2mat(handles.method(handles.fitype));
handles.timestr = get_time;
handles.rms = get(handles.RMS,'Value');
handles.ref = 0;
handles.P  = 0*lcaGetSmart(handles.PV_ss);
handles.NP = length(handles.P);
handles.x  = ((-handles.NP/2):1:((handles.NP-1)/2))*handles.calcoef;
handles.Pref  = handles.P;
handles.xref  = handles.x;

% Choose default command line output for SXR_spec_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SXR_spec_GUI wait for user response (see UIRESUME)
% uiwait(handles.SXR_spec_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = SXR_spec_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close SXR_spec_GUI.
function SXR_spec_GUI_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% --- Executes on button press in TAKEDATA.
function TAKEDATA_Callback(hObject, eventdata, handles)
[sys,accelerator]=getSystem();
handles.ss  = get(handles.SS,'Value');
handles.avg = get(handles.AVG1,'Value');
handles.navg = str2double(get(handles.NAVG,'String'));
handles.rate = lcaGetSmart(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);
if handles.rate < 1
  warndlg('Beam rate is < 1 Hz - cannot continue.','LOW BEAM RATE')
  return
end
if ~handles.avg
  N = 1;
  delay = 0;
else
  if handles.sourceSel == 1
      N = round(abs(handles.navg/handles.rate));
      delay = 1;
  else
      N = handles.navg;
      delay = 1/handles.rate;
  end
end
if N*delay > 30
  yn = questdlg(sprintf('This will require %4.0f seconds at %3.0f Hz.  Are you sure you want to do this?',N,handles.rate),'WARNING');
  if ~strcmp(yn,'Yes')
    return
  end
end
if handles.ss==0
  PV = handles.PV_avg;
else
  PV = handles.PV_ss;
end
Pj = zeros(N,handles.NP);
for j = 1:N
  set(handles.TAKEDATA,'BackgroundColor','white')
  set(handles.TAKEDATA,'String',sprintf('count: %3.0f',N-j+1))
  Pj(j,:)  = lcaGetSmart(PV);
  drawnow
  pause(delay)
end
set(handles.TAKEDATA,'BackgroundColor','yellow')
set(handles.TAKEDATA,'String','Take One-Shot')
if ~handles.avg
  handles.P = Pj;
else
  handles.P = mean(Pj);
end
handles.timestr = get_time;
guidata(hObject, handles);
plot_profile(0,hObject,handles)


function plot_profile(Elog_fig,hObject,handles)
if Elog_fig
  figure(Elog_fig)
  ax1 = subplot(1,1,1);
else
  ax1 = handles.axes1;
end
%axes(ax1)
n = length(handles.P);
handles.x  = ((-n/2):1:((n-1)/2))*handles.calcoef;
if handles.rms
  profs.x=[handles.x(:)'; handles.P(:)'];
%  beam = beamAnalysis_beamParams(profs,[],[],0,'isimage',0,'fitbg',1);
  beam = beamAnalysis_beamParams(profs,[],[],0,'isimage',0,'fitbg',1,'cut',0.05);
  i = handles.fitype;  % Gaussian=1, etc
  beamAnalysis_profilePlot(beam(i),'x','axes',ax1,'units','eV','cal',1,'xlab','Photon Diff. Energy (eV)');
  lcaPutSmart('SIOC:SYS0:ML00:AO741',beam(i).stats(3));
else
  plot(handles.x,handles.P,'b:.','Parent',ax1)
end
bg=0;
if length(handles.x)>10
  bg=util_bgLevel(handles.P);
  [xFWHM,i1,i2] = FWHM(handles.x,handles.P-bg);
else
  xFWHM = 0;
  i1 = 1;
  i2 = 1;
end
lcaPutSmart('SIOC:SYS0:ML00:AO740',xFWHM); % Don't do this when loading old data
hold(ax1,'on');
plot([handles.x(i1) handles.x(i2)],(bg+max(handles.P))*[.5 .5],'cs-','Parent',ax1)
if handles.rms
  str2 = [', ' handles.methstr];
else
  str2 = ' ';
end
if handles.ss==0
  if handles.avg
    str1 = sprintf('(Navg=%4.0f)',handles.navg);
  else
    str1 = '(1-sec avg)';
  end
else
  str1 = '(one-shot)';
end
str=handles.nameList{handles.sourceSel};
title(ax1,[str ' Spec ' str1 sprintf(', cal=%8.5f eV/px, FWHM=%5.2f eV',handles.calcoef,xFWHM) str2])
if handles.ref
  plot(handles.xref,handles.Pref,'g--','Parent',ax1)
end
xlabel(ax1,'Photon Diff. Energy (eV)')
ylabel(ax1,['{\itN} (arb),  ' handles.timestr])
xlim(ax1,[min(0.99*handles.x) max(1.01*handles.x)])
hold(ax1,'off');
guidata(hObject, handles);


% --- Executes on button press in ELOG.
function ELOG_Callback(hObject, eventdata, handles)
plot_profile(1,hObject,handles)
util_printLog(1);


% --- Executes on button press in FREERUN.
function FREERUN_Callback(hObject, eventdata, handles)
tags={'Free Run' 'Stop'};
colr={'green' 'red '};
set(hObject,'String',tags{get(hObject,'Value')+1});
set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});
handles.ss  = get(handles.SS,'Value');
while get(hObject,'Value')
  if handles.ss==0
    PV = handles.PV_avg;
  else
    PV = handles.PV_ss;
  end
  handles.P  = lcaGetSmart(PV);
  handles.timestr = get_time;
  plot_profile(0,hObject,handles)
  if handles.sourceSel == 1, pause(1);else pause(.03);end
end
guidata(hObject, handles);


% --- Executes on button press in SAVEASREF.
function SAVEASREF_Callback(hObject, eventdata, handles)
handles.Pref = handles.P;
handles.xref = handles.x;
guidata(hObject, handles);


% --- Executes on button press in SHOWREF.
function SHOWREF_Callback(hObject, eventdata, handles)
handles.ref = get(hObject,'Value');
plot_profile(0,hObject,handles)
guidata(hObject, handles);


function CALCOEF_Callback(hObject, eventdata, handles)
handles.calcoef = str2double(get(hObject,'String'));
guidata(hObject, handles);
lcaPutSmart(['SIOC:SYS0:ML00:AO73' num2str(5+handles.sourceSel)],handles.calcoef);
plot_profile(0,hObject,handles)

% --- Executes during object creation, after setting all properties.
function CALCOEF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function FITYPE_Callback(hObject, eventdata, handles)
handles.fitype = round(get(hObject,'Value'));
set(hObject,'Value',handles.fitype)
handles.methstr = cell2mat(handles.method(handles.fitype));
set(handles.METHOD','String',handles.methstr);
plot_profile(0,hObject,handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FITYPE_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in RMS.
function RMS_Callback(hObject, eventdata, handles)
handles.rms = get(hObject,'Value');
plot_profile(0,hObject,handles)
guidata(hObject, handles);


function NAVG_Callback(hObject, eventdata, handles)
navg = str2double(get(hObject,'String'));
if navg > 5000
  navg = 5000;
  set(hObject,'String',navg)
end
if navg < 1
  navg = 1;
  set(hObject,'String',navg)
end
handles.navg = navg;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

list={'P' 'calcoef' 'ss' 'avg' 'ref' 'Pref' 'xref'};

data.name=handles.nameList{handles.sourceSel};
data.ts=datenum(handles.timestr);
for j=list
    if isfield(handles,j{:})
        data.(j{:})=handles.(j{:});
    end
end

%data=handles.data;
%if ~any(data.status), return, end

fileName=util_dataSave(data,'SXR_spect',data.name,data.ts,val);
if ~ischar(fileName), return, end
%handles.fileName=fileName;
%handles.process.saved=1;

%str={'*' ''};
%set(handles.output,'Name',['Correlation Plot - [' handles.fileName ']' str{handles.process.saved+1}]);
%guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles)

[data,fileName]=util_dataLoad('Open SXR Spectrum');
if ~ischar(fileName), return, end
%handles=acquireReset(hObject,handles);
%handles.process.saved=1;

% Put data in storage and update.
%handles.data=data;
%handles.fileName=fileName;
%str={'*' ''};
%set(handles.output,'Name',['Correlation Plot - [' handles.fileName ']' str{handles.process.saved+1}]);
%handles=acquireUpdate(hObject,handles);

list={'P' 'calcoef' 'ss' 'avg' 'ref' 'Pref' 'xref'};

for j=list
    if isfield(data,j{:})
        handles.(j{:})=data.(j{:});
    end
end

handles.timestr=datestr(data.ts);
set(handles.sourceSel_pmu,'Value',max([1 find(strcmp(data.name,handles.nameList),1)]));
handles=sourceSel_pmu_Callback(handles.sourceSel_pmu,[],handles);
%guidata(hObject,handles);
plot_profile(0,hObject,handles);
handles=guidata(hObject);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

dataSave(hObject,handles,0);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on selection change in sourceSel_pmu.
function handles = sourceSel_pmu_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.sourceSel=val;
handles.PV_avg = handles.PVlist{val,1};
handles.PV_ss  = handles.PVlist{val,2};
set(handles.text1,'String',strcat(handles.nameList{val},' Spectrometer'));
handles.calcoef=lcaGetSmart(['SIOC:SYS0:ML00:AO73' num2str(5+handles.sourceSel)]);
set(handles.CALCOEF,'String',num2str(handles.calcoef));
handles.ROIY=[0;0];
if val == 2
    handles.ROIY=lcaGetSmart(strcat('XPP:OPAL1K:1:ROI_Y_',{'Start';'End'}));
end
set([handles.ROIYStart_txt handles.ROIYEnd_txt],{'String'},cellstr(num2str(handles.ROIY)));
str={'off' 'on'};
set([handles.ROIYStart_txt handles.ROIYEnd_txt handles.ROIYStartLabel_txt ...
    handles.ROIYEndLabel_txt],'Visible',str{1+(val == 2)});
guidata(hObject,handles);


function ROIYStart_txt_Callback(hObject, eventdata, handles)

handles.ROIY(1) = str2double(get(hObject,'String'));
guidata(hObject, handles);
lcaPutSmart('XPP:OPAL1K:1:ROI_Y_Start',handles.ROIY(1));


function ROIYEnd_txt_Callback(hObject, eventdata, handles)

handles.ROIY(2) = str2double(get(hObject,'String'));
guidata(hObject, handles);
lcaPutSmart('XPP:OPAL1K:1:ROI_Y_End',handles.ROIY(2));
