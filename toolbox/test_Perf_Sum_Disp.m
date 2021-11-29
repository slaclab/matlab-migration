function varargout = test_Perf_Sum_Disp(varargin)
% TEST_PERF_SUM_DISP M-file for test_Perf_Sum_Disp.fig
%      TEST_PERF_SUM_DISP, by itself, creates a new TEST_PERF_SUM_DISP or raises the existing
%      singleton*.
%
%      H = TEST_PERF_SUM_DISP returns the handle to a new TEST_PERF_SUM_DISP or the handle to
%      the existing singleton*.
%
%      TEST_PERF_SUM_DISP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_PERF_SUM_DISP.M with the given input arguments.
%
%      TEST_PERF_SUM_DISP('Property','Value',...) creates a new TEST_PERF_SUM_DISP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_Perf_Sum_Disp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_Perf_Sum_Disp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_Perf_Sum_Disp

% Last Modified by GUIDE v2.5 11-Nov-2008 16:02:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_Perf_Sum_Disp_OpeningFcn, ...
                   'gui_OutputFcn',  @test_Perf_Sum_Disp_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
clc
gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before test_Perf_Sum_Disp is made visible.
function test_Perf_Sum_Disp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_Perf_Sum_Disp (see VARARGIN)

% Choose default command line output for test_Perf_Sum_Disp
handles.output = hObject;
[sys,accelerator]=getSystem();

handles.energy_PV       = 'BEND:DMP1:400:BACT';
handles.wavelength_PV   = 'SIOC:SYS0:ML00:AO192';
handles.charge_PV       = 'BPMS:BSYH:445:TMIT';
handles.Lgain_PV        = 'SIOC:SYS0:ML00:AO193';
handles.Power_PV        = 'SIOC:SYS0:ML00:AO194';
handles.emitx_PV        = 'WIRE:LI28:144:EMITN_X';
handles.emity_PV        = 'WIRE:LI28:144:EMITN_Y';
handles.bmagx_PV        = 'WIRE:LI28:144:BMAG_X';
handles.bmagy_PV        = 'WIRE:LI28:144:BMAG_Y';
%handles.BC2Ipk_PV       = 'FBCK:LNG6:1:BC2BLSP';
handles.BC2Ipk_PV       = 'SIOC:SYS0:ML00:AO195';   % H-D's filtered BL21 readback
handles.rate_PV         = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
handles.delay = str2double(get(handles.SAMPLEDELAY,'String'));
handles.tmax = str2double(get(handles.TMAX,'String'));
handles.ymax = str2double(get(handles.YMAX,'String'));
set(hObject,'InvertHardcopy','off');
util_appFonts(hObject,'fontName','Helvetica','fontSize',16,'MarkerSize',1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_Perf_Sum_Disp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_Perf_Sum_Disp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
colr={'green' 'white '};
ss = get(hObject,'Value');
set(hObject,'BackgroundColor',colr{ss+1});
%if ss
%  [Lgain_H,t_Lgain] = get_archive(handles.Lgain_PV,[],[],0);
%  [Power_H,t_Power] = get_archive(handles.Power_PV,[],[],0);
%  plot(datenum(t_Lgain),Lgain,'bd')
%  datetick('x')
%  xlabel('time')
%  ylabel('FEL Gain Length (m)')
%  title('LCLS')
%  enhance_plot('times',18,1,5)
%end
tstr0 = get_time;
t0 = 60*24*datenum(tstr0);      % convert time string to seconds
jj = 0;
low_charge_lim = 0.1;           % call this "down" if too little charge (nC)
Planck = 4.13566733E-15;        % Planck's constant in eV-s
c = 2.99792458E8;               % speed of light (m/s)
e = 1.60217646E-19;             % charge of e- (C)
while ss
  jj = jj + 1;
  set(hObject,'BackgroundColor','green');
  drawnow
  pause(0.2)
  set(hObject,'BackgroundColor','white');
  drawnow
  handles.delay = str2double(get(handles.SAMPLEDELAY,'String'));    % sec
  handles.tmax = str2double(get(handles.TMAX,'String'));    % plot tmax (min)
  handles.ymax = str2double(get(handles.YMAX,'String'));    % plot ymax (m & GW)
%
  tstr = get_time;
  t(jj) = 60*24*datenum(tstr) - t0;                 % convert time string to seconds
  energy = lcaGet(handles.energy_PV)/0.5794;        % e- energy (GeV)
  wavelength = lcaGet(handles.wavelength_PV);       % FEL wavelength (nm)
  charge(jj) = lcaGet(handles.charge_PV)*1E9*e;     % bunch charge (nC)
  if isnan(charge(jj))
    charge(jj) = 0;
  end
  emitx = lcaGet(handles.emitx_PV);                 % normalized X-emittance [microns]
  emity = lcaGet(handles.emity_PV);                 % normalized Y-emittance [microns]
  bmagx = lcaGet(handles.bmagx_PV);
  bmagy = lcaGet(handles.bmagy_PV);
  BC2Ipk = lcaGet(handles.BC2Ipk_PV);               % peak current (A)
  if BC2Ipk < 10
    BC2Ipk = 1;
  end
  rate = lcaGet(handles.rate_PV);                   % rep, rate (Hz)
  up = charge > low_charge_lim;
  uptime = length(find(up))/length(charge);         % [ ]
  bunchlength = int16(charge(jj)*1E-3*c/sqrt(12)/BC2Ipk);  % rms final bunch length (microns)
  Lgain(jj) = up(jj)*lcaGet(handles.Lgain_PV)/20;   % est. FEL gain length (meters)
  Power(jj) = up(jj)*lcaGet(handles.Power_PV);      % est. FEL output power (GW)
  Ephot = 1E9*Planck*c/wavelength;                  % energy per photon (eV)
  Nphot = Power(jj)*1E9*sqrt(12)*bunchlength*1E-6/c/e/Ephot;    % number of photons [ ]
  hp=plot(t-t(jj),Power,'rs-',t-t(jj),Lgain,'bd--');
  set(gca,'XColor','yellow')
  set(gca,'YColor','yellow')
  xlim([-handles.tmax 0])
  ylim([0 handles.ymax])
  hxl=xlabel('time (min)');
  set(hxl,'Color','yellow')
  hyl =ylabel('FEL Gain Length (m) & Power (GW)');
  set(hyl,'Color','yellow')
  htl=title(['LCLS (' tstr ')']);
  set(htl,'Color','white')
  set(hp(1),'MarkerFaceColor','red')
  set(hp(2),'MarkerFaceColor','blue')
  set(hp(1),'MarkerSize',4)
  set(hp(2),'MarkerSize',4)
  legend('Power (GW)','Gain Length (m)','Location','NorthWest')
  legend('BoxOff')
  hor_line(132/20,'b:')
%  enhance_plot('Helvetica',16,1,4)
  set(handles.RATE,'String',sprintf('%3.0f',rate))
  set(handles.ENERGY,'String',sprintf('%5.2f',energy))
  set(handles.CHARGE,'String',sprintf('%5.3f',charge(jj)))
  set(handles.BC2IPK,'String',sprintf('%4.0f',BC2Ipk))
  set(handles.BUNCHLENGTH,'String',sprintf('%5.2f',bunchlength))
  set(handles.EMITX,'String',sprintf('%5.2f',emitx*bmagx))
  set(handles.EMITY,'String',sprintf('%5.2f',emity*bmagy))
  set(handles.POWER,'String',sprintf('%5.2f',Power(jj)))
  set(handles.LGAIN,'String',sprintf('%5.2f',Lgain(jj)))
  set(handles.WAVELENGTH,'String',sprintf('%5.3f',wavelength))
  set(handles.PHOTONENERGY,'String',sprintf('%5.3f',Ephot*1E-3))
  set(handles.NPHOTONS,'String',sprintf('%5.3f',Nphot*1E-12))
  set(handles.UPTIME,'String',sprintf('%5.1f',uptime*100))
  if charge(jj) < low_charge_lim
    set(handles.CHARGE,'ForegroundColor','red')
    set(handles.BC2IPK,'ForegroundColor','red')
    set(handles.BUNCHLENGTH,'ForegroundColor','red')
    set(handles.POWER,'ForegroundColor','red')
    set(handles.LGAIN,'ForegroundColor','red')
    set(handles.NPHOTONS,'ForegroundColor','red')
  else
    set(handles.CHARGE,'ForegroundColor','green')
    set(handles.BC2IPK,'ForegroundColor','green')
    set(handles.BUNCHLENGTH,'ForegroundColor','green')
    set(handles.POWER,'ForegroundColor','green')
    set(handles.LGAIN,'ForegroundColor','green')
    set(handles.NPHOTONS,'ForegroundColor','green')
  end
  for j = 1:handles.delay
    ss = get(hObject,'Value');
    if ss==0
      break
    end
    set(hObject,'String',['run ' int2str(j) '...']);
    pause(1)
  end
end
set(hObject,'String','Start');
set(hObject,'BackgroundColor','green');
guidata(hObject, handles);


function ELOG_Callback(hObject, eventdata, handles)
util_printLog(handles.output);
guidata(hObject, handles);


function ENERGY_Callback(hObject, eventdata, handles)

function ENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WAVELENGTH_Callback(hObject, eventdata, handles)

function WAVELENGTH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CHARGE_Callback(hObject, eventdata, handles)

function CHARGE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMITX_Callback(hObject, eventdata, handles)

function EMITX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EMITY_Callback(hObject, eventdata, handles)

function EMITY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BC2IPK_Callback(hObject, eventdata, handles)

function BC2IPK_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BUNCHLENGTH_Callback(hObject, eventdata, handles)

function BUNCHLENGTH_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function POWER_Callback(hObject, eventdata, handles)

function POWER_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LGAIN_Callback(hObject, eventdata, handles)

function LGAIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RATE_Callback(hObject, eventdata, handles)

function RATE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TMAX_Callback(hObject, eventdata, handles)
handles.tmax = str2double(get(hObject,'String'));
guidata(hObject, handles);

function TMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function YMAX_Callback(hObject, eventdata, handles)
handles.ymax = str2double(get(hObject,'String'));
guidata(hObject, handles);

function YMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SAMPLEDELAY_Callback(hObject, eventdata, handles)
handles.delay = str2double(get(hObject,'String'));
guidata(hObject, handles);

function SAMPLEDELAY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function UPTIME_Callback(hObject, eventdata, handles)

function UPTIME_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHOTONENERGY_Callback(hObject, eventdata, handles)

function PHOTONENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NPHOTONS_Callback(hObject, eventdata, handles)

function NPHOTONS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


