function varargout = QE_scanner(varargin)
% QE_SCANNER M-file for QE_scanner.fig
%      QE_SCANNER, by itself, creates a new QE_SCANNER or raises the existing
%      singleton*.
%
%      H = QE_SCANNER returns the handle to a new QE_SCANNER or the handle to
%      the existing singleton*.
%
%      QE_SCANNER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QE_SCANNER.M with the given input arguments.
%
%      QE_SCANNER('Property','Value',...) creates a new QE_SCANNER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QE_scanner_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to QE_scanner_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help QE_scanner

% Last Modified by GUIDE v2.5 04-Apr-2008 18:05:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @QE_scanner_OpeningFcn, ...
                   'gui_OutputFcn',  @QE_scanner_OutputFcn, ...
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

% --- Executes just before QE_scanner is made visible.
function QE_scanner_OpeningFcn(hObject, eventdata, handles, varargin)
handles.screen_pv       = 'YAGS:IN20:241:PNEUMATIC';
[d,d,handles.fdbk_pv]   = control_chargeName;
handles.bpm_pv          = 'BPMS:IN20:221';
handles.laser_energy_pv = 'LASR:IN20:196:PWR';
handles.waveplate_pv    = 'WPLT:LR20:116:WP2_ANGLE';
handles.max_angle_pv    = 'WPLT:LR20:116:ANG_MAX';
handles.power_meter_status_pv = 'PMTR:IN20:196:DATA_MODEDES';
handles.max_angle       = lcaGetSmart(handles.max_angle_pv);
set(handles.WAVEPLATEMAX,'String',num2str(handles.max_angle))
set(handles.WAVEPLATEMIN,'String',num2str(handles.max_angle - 45.))
handles.max_angle       = lcaGetSmart(handles.max_angle_pv);
power_meter_status      = lcaGetSmart(handles.power_meter_status_pv,0,'double');
if isnan(power_meter_status)
  warndlg('Power meter is unavailable.','POWER METER UNAVAILABLE');
elseif power_meter_status
  warndlg('Power meter is in "STATISTICS" mode - you must switch it to "NORMAL" mode before proceeding.','BAD POWER METER SETTING');
end
handles.timeout         = 10;       % timeout for synch. acquisition
title_str = {
                'Professor Dowell''s QE Scanner'
                'Dave''s Damn QE Scanner'
                'QE Scanner alla Dave'
                'QE Scanner por Monsieur Dowell'
                'Dr. Dowell''s Special QE Potion Mixer'
                'Mr. Dowell''s Scanner of Pitiful QE Levels'
                'Dowell-San''s QE Cooker'
                'Go Cubs!'
                'Dave''s Poor Excuse for a QE Scanner'
                'QE?  What QE?'
                'Captain Dave''s Barnacle-Covered QE Scooner...  AAargh!'
                'Dave''s Brewery and Part-Time QE Scanner'
                'Master Dowell''s QE Data Faker'
                'Senior Dowell''s QE Random Generator'
                'Dave''s Cheap, Splashy QE Advertisement'
                'Herr Dowell''s Kleine QE Damensalon'
                'Dave''s Duck Pond - QUACK!'
                'Dave''s Private QE Peep Show'
                'Dave''s QE Scanner and Traveling Parrot Show'
                'Who''s Dave?'
                                                         };
nstr = length(title_str);
rand('twister',sum(100*clock));
istr = randperm(nstr);
set(handles.TITLE,'String',title_str(istr(1)))
set(handles.MSGBOX,'String',' ')
set(handles.MSGBOX,'ForegroundColor','black')
waveplate_reading = lcaGet([handles.waveplate_pv '.RBV']);
waveplate_setting = lcaGet(handles.waveplate_pv);
set(handles.WAVESET,'String',waveplate_setting)
set(handles.WAVEPLATE,'String',waveplate_reading)
drawnow
handles.output = hObject;
handles.OK_data = 0;
handles.navg = round(str2double(get(handles.NAVG,'String')));
handles.nsettings = round(str2double(get(handles.NSETTINGS,'String')));
handles.wait = str2double(get(handles.WAIT,'String'));
handles.photon_energy = str2double(get(handles.PHOTONENERGY,'String'));
handles.Efield = str2double(get(handles.E0,'String'));
handles.laser_phase = str2double(get(handles.LASERPHASE,'String'));
handles.range_frac = str2double(get(handles.RANGEFRAC,'String'));
handles.waveplate_min = str2double(get(handles.WAVEPLATEMIN,'String'));
handles.waveplate_max = str2double(get(handles.WAVEPLATEMAX,'String'));
handles.fake_data = get(handles.FAKEDATA,'Value');
guidata(hObject, handles);

% UIWAIT makes QE_scanner wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = QE_scanner_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in TAKEDATA.
function TAKEDATA_Callback(hObject, eventdata, handles)
plot(0,0,'.')
set(handles.TAKEDATA,'BackgroundColor','white')
set(handles.TAKEDATA,'String','wait...')
drawnow
[sys,accelerator]=getSystem();
rate = lcaGet(['EVNT:' sys ':1:' accelerator 'BEAMRATE']);  % rep. rate [Hz]
if rate < 1
  rate = 1;
end
navg = min(handles.navg, 10);   % limit averages to 10
handles.initial_screen = lcaGet(handles.screen_pv);
handles.initial_fdbk   = lcaGet(handles.fdbk_pv,0,'double');
initial_waveplate  = lcaGet(handles.waveplate_pv);
if strcmp('OUT',handles.initial_screen) % screen was out
  if ~handles.fake_data
    lcaPut(handles.screen_pv,'IN');
  end
  set(handles.MSGBOX,'String','Inserting YAG02')
  set(handles.MSGBOX,'ForegroundColor','red')
  drawnow
  pause(2)
end
if ~handles.fake_data
  lcaPut(handles.fdbk_pv,0);
end
set(handles.MSGBOX,'String','reserving synch. acq.')
set(handles.MSGBOX,'ForegroundColor','red')
drawnow
eDefNumber = eDefReserve('QE_scanner.m');
if eDefNumber==0
  errordlg('Could not reserve synchronous acquisition definition number - quitting','ERROR')
  handles = quit_scan(handles);
  return
end
eDefParams(eDefNumber,1,handles.navg,{''},{''},{''},{''});
handles.charge  = zeros(handles.navg,handles.nsettings);
handles.energy  = zeros(handles.navg,handles.nsettings);
set(handles.MSGBOX,'String','Taking data...')
set(handles.MSGBOX,'ForegroundColor','red')
drawnow
waveplate_angle = round(10*linspace(handles.waveplate_max,handles.waveplate_min,handles.nsettings))/10;
for j = 1:handles.nsettings
  pct = 100*(1 - (waveplate_angle(j)-min(waveplate_angle))/(max(waveplate_angle)-min(waveplate_angle)));
  set(handles.TAKEDATA,'String',sprintf('%3.0f %%',pct))
  drawnow
  if ~handles.fake_data
    lcaPut(handles.waveplate_pv,waveplate_angle(j));
    set(handles.WAVESET,'String',waveplate_angle(j))
  end
  pause(handles.wait)
  waveplate_reading = lcaGet([handles.waveplate_pv '.RBV']);
  set(handles.WAVEPLATE,'String',waveplate_reading)
  acqtime = eDefAcq(eDefNumber,handles.timeout);
  tmit = lcaGet({[handles.bpm_pv, ':TMITHST', num2str(eDefNumber)]},handles.navg);
  pwr  = lcaGet({[handles.laser_energy_pv, 'HST', num2str(eDefNumber)]},handles.navg);
  handles.charge(:,j)  = tmit'*1.602E-10;          % e- charge [nC]
  handles.energy(:,j)  = pwr'*1;                   % laser energy [uJ]
  pause(1/rate);
%  ii = find(handles.charge>=1E-3);
  plot(handles.energy,handles.charge,'dr');
  xlabel('Laser Energy (\muJ)')
  ylabel('Bunch Charge (nC)')
  title(get_time)
  yl = ylim;
  ylim([0 yl(2)])
  xl = xlim;
  xlim([0 xl(2)])
  enhance_plot('Times',14,2,4)
end
if handles.fake_data
  handles.energy = 0:((300/(handles.nsettings-1))):300;
  handles.charge = sqrt(handles.energy/300);
  handles.energy = [handles.energy.*(1+0.02*randn(1,handles.nsettings)); handles.energy];
  handles.charge = [handles.charge.*(1+0.02*randn(1,handles.nsettings)); handles.charge];
  if exist('QE_scanner1.mat')
    load QE_scanner1.mat
    handles.charge = charge_sav;
    handles.energy = energy_sav;
    handles.navg = navg_sav;
    handles.nsettings = nsettings_sav;
  end
else
  lcaPut(handles.waveplate_pv,(handles.waveplate_max + handles.waveplate_min)/2);
  pause(5)
  lcaPut(handles.waveplate_pv,initial_waveplate);
  save QE_scanner.mat
end
set(handles.TAKEDATA,'BackgroundColor','green')
set(handles.TAKEDATA,'String','take data')
drawnow
eDefRelease(eDefNumber);
handles = quit_scan(handles);
handles.OK_data = 1;
handles = fit_data(handles);
if handles.QE_fit == 0
%  return
end
waveplate_reading = lcaGet([handles.waveplate_pv '.RBV']);
set(handles.WAVEPLATE,'String',waveplate_reading)
waveplate_setting = lcaGet(handles.waveplate_pv);
set(handles.WAVESET,'String',waveplate_setting)
handles = plot_data(handles,0);
guidata(hObject, handles);


function handles = quit_scan(handles)
if strcmp('OUT',handles.initial_screen) % screen was out
  if ~handles.fake_data
    lcaPut(handles.screen_pv,'OUT');
  end
  set(handles.MSGBOX,'String','Removing YAG02')
  set(handles.MSGBOX,'ForegroundColor','red')
  drawnow
  pause(1)
end
if ~handles.fake_data
  lcaPut(handles.fdbk_pv,handles.initial_fdbk);
end
set(handles.MSGBOX,'String','Done')
set(handles.MSGBOX,'ForegroundColor','black')
drawnow
return


function handles = fit_data(handles)
  set(handles.REFIT,'BackgroundColor','white')
  set(handles.REFIT,'String','fitting...')
  set(handles.MSGBOX,'String','Fitting...')
  set(handles.MSGBOX,'ForegroundColor','red')
  drawnow
  handles.Rguess = 0.00035;
  handles = QE_fit(handles);
  set(handles.REFIT,'BackgroundColor','yellow')
  set(handles.REFIT,'String','re-fit data')
  set(handles.MSGBOX,'String','Fitting Done!')
  set(handles.MSGBOX,'ForegroundColor','black')
  drawnow
return


function handles = plot_data(handles,logbook)
set(handles.RSIG,'String',sprintf('%5.3f',handles.rsigresult));
set(handles.QE,'String',sprintf('%4.2f',handles.QEval/1E-5));
if logbook
  fignum = 1;
  figure(fignum);
  handles.fig = fignum;
end
[Esort,isort] = sort(handles.ElaserFit);
plot(handles.energy,handles.charge_yoff,'dr',handles.ElaserFit(isort),handles.Qfit(isort),'b-')
ver_line(handles.energy_break,'k:')
xlabel('Laser Energy (\muJ)')
ylabel('Bunch Charge (nC)')
title([get_time ',  {\itQE}=' sprintf('%4.2f',handles.QEval/1E-5) '\times10^{-5},  {\itR_{eff}}=' sprintf('%5.3f mm',handles.rsigresult)])
enhance_plot('Times',14,2,4)
yl = ylim;
ylim([0 yl(2)])
xl = xlim;
xlim([0 xl(2)])
return


function NAVG_Callback(hObject, eventdata, handles)
handles.navg = round(str2double(get(handles.NAVG,'String')));
guidata(hObject, handles);

function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NSETTINGS_Callback(hObject, eventdata, handles)
handles.nsettings = round(str2double(get(handles.NSETTINGS,'String')));
guidata(hObject, handles);

function NSETTINGS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WAIT_Callback(hObject, eventdata, handles)
handles.wait = str2double(get(handles.WAIT,'String'));
guidata(hObject, handles);

function WAIT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHOTONENERGY_Callback(hObject, eventdata, handles)
handles.photon_energy = str2double(get(handles.PHOTONENERGY,'String'));
guidata(hObject, handles);

function PHOTONENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function E0_Callback(hObject, eventdata, handles)
handles.Efield = str2double(get(handles.E0,'String'));
guidata(hObject, handles);

function E0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LASERPHASE_Callback(hObject, eventdata, handles)
handles.laser_phase = str2double(get(handles.LASERPHASE,'String'));
guidata(hObject, handles);

function LASERPHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LOGBOOK_Callback(hObject, eventdata, handles)
if handles.OK_data
  handles = plot_data(handles,1);
  util_printLog(handles.fig);
else
  set(handles.MSGBOX,'String','No data yet')
  set(handles.MSGBOX,'ForegroundColor','red')
  drawnow
end
guidata(hObject, handles);


function RANGEFRAC_Callback(hObject, eventdata, handles)
handles.range_frac = str2double(get(handles.RANGEFRAC,'String'));
guidata(hObject, handles);

function RANGEFRAC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RSIG_Callback(hObject, eventdata, handles)

function RSIG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WAVEPLATEMIN_Callback(hObject, eventdata, handles)
handles.waveplate_min = str2double(get(handles.WAVEPLATEMIN,'String'));
guidata(hObject, handles);

function WAVEPLATEMIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WAVEPLATEMAX_Callback(hObject, eventdata, handles)
handles.waveplate_max = str2double(get(handles.WAVEPLATEMAX,'String'));
guidata(hObject, handles);

function WAVEPLATEMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE_Callback(hObject, eventdata, handles)

function QE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function REFIT_Callback(hObject, eventdata, handles)
if handles.OK_data
  set(handles.REFIT,'BackgroundColor','white')
  set(handles.REFIT,'String','fitting...')
  set(handles.MSGBOX,'String','Fitting...')
  set(handles.MSGBOX,'ForegroundColor','red')
  drawnow
  handles = fit_data(handles);
  if handles.QE_fit == 0
    return
  end
  handles = plot_data(handles,0);
  handles.OK_data = 1;
  set(handles.REFIT,'BackgroundColor','yellow')
  set(handles.REFIT,'String','re-fit data')
  set(handles.MSGBOX,'String','Fitting Done!')
  set(handles.MSGBOX,'ForegroundColor','black')
  drawnow
else
  set(handles.MSGBOX,'String','No data yet')
  set(handles.MSGBOX,'ForegroundColor','red')
  drawnow
end
save_data(handles);
guidata(hObject, handles);


function save_data(handles)
data.energy = handles.energy;
data.charge =handles.charge;
data.QEval = handles.QEval;
data.rsigresult = handles.rsigresult;
data.input.photon_energy = handles.photon_energy;
data.input.Efield = handles.Efield; 
data.input.laser_phase = handles.laser_phase;
data.input.range_frac = handles.range_frac;
ts_= clock; 
header = ['QE_scan'];
name = [''];
[fileName, pathName] = util_dataSave(data,header,name,ts_);


function FAKEDATA_Callback(hObject, eventdata, handles)
handles.fake_data = get(handles.FAKEDATA,'Value');
guidata(hObject, handles);


function WAVEPLATE_Callback(hObject, eventdata, handles)

function WAVEPLATE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
delete(hObject);
% exit from Matlab when not running the desktop
if usejava('desktop')
    % don't exit from Matlab
else
    exit
end


function handles = load_data_Callback(hObject, eventdata, handles)
dlgTitle = 'load data';
[data, fileName, pathName] = util_dataLoad(dlgTitle);

handles.energy = data.energy;           % 
handles.charge = data.charge ;          % e- charge [nC]
handles.QEval = data.QEval;
handles.rsigresult = data.rsigresult;

handles.photon_energy = data.input.photon_energy ;
handles.Efield = data.input.Efield; 
handles.laser_phase = data.input.laser_phase;
handles.range_frac = data.input.range_frac;

handles.OK_data = 1;
guidata(hObject, handles);


function save_data_Callback(hObject, eventdata, handles)
save_data(handles);


function load_data_CreateFcn(hObject, eventdata, handles)


function save_data_CreateFcn(hObject, eventdata, handles)


