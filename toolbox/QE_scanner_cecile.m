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

% Last Modified by GUIDE v2.5 31-Mar-2008 14:26:31

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
handles.laser_power_pv  = 'LASR:BCIS:1:PCTRL';
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
laser_power_setting = lcaGet([handles.laser_power_pv]);
set(handles.LASERSET,'String',laser_power_setting)
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
handles.laser_power_min = str2double(get(handles.LASER_POWER_MIN,'String'));
handles.laser_power_max = str2double(get(handles.LASER_POWER_MAX,'String'));
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
initial_laser_power  = lcaGet(handles.laser_power_pv);
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

for j = 1:handles.nsettings
  pct = j/handles.nsettings*(handles.laser_power_max-handles.laser_power_min)+handles.laser_power_min;
  set(handles.TAKEDATA,'String',sprintf('%2.2f %%',pct))
  drawnow
  %   set laser power 
  if ~handles.fake_data
    lcaPut(handles.laser_power_pv,pct);
    set(handles.LASERSET,'String',pct)
  end
  pause(handles.wait)
  laser_power_reading = lcaGet([handles.laser_power_pv ]);
  set(handles.LASERSET,'String',laser_power_reading)
  acqtime = eDefAcq(eDefNumber,handles.timeout);
  handles.ts = acqtime(length(acqtime)); 
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
    % sets back the laser power to initial value (in 2 steps) 
  lcaPut(handles.laser_power_pv,(handles.laser_power_max + handles.laser_power_min)/2);
  pause(5)
  lcaPut(handles.laser_power_pv,initial_laser_power);
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

laser_power_setting = lcaGet(handles.laser_power_pv);
set(handles.LASERSET,'String',laser_power_setting)
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
%plot(handles.energy,handles.charge_yoff,'dr',handles.ElaserFit(isort),handles.Qfit(isort),'b-')
plot(handles.energy,handles.charge,'dr',handles.ElaserFit(isort),handles.Qfit(isort),'b-')
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

% --- Executes during object creation, after setting all properties.
function NAVG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NSETTINGS_Callback(hObject, eventdata, handles)
handles.nsettings = round(str2double(get(handles.NSETTINGS,'String')));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function NSETTINGS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function WAIT_Callback(hObject, eventdata, handles)
handles.wait = str2double(get(handles.WAIT,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function WAIT_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PHOTONENERGY_Callback(hObject, eventdata, handles)
handles.photon_energy = str2double(get(handles.PHOTONENERGY,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PHOTONENERGY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function E0_Callback(hObject, eventdata, handles)
handles.Efield = str2double(get(handles.E0,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function E0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LASERPHASE_Callback(hObject, eventdata, handles)
handles.laser_phase = str2double(get(handles.LASERPHASE,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LASERPHASE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LOGBOOK.
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

% --- Executes during object creation, after setting all properties.
function RANGEFRAC_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RSIG_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function RSIG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LASER_POWER_MIN_Callback(hObject, eventdata, handles)
handles.laser_power_min = str2double(get(handles.LASER_POWER_MIN,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LASER_POWER_MIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LASER_POWER_MAX_Callback(hObject, eventdata, handles)
handles.laser_power_max = str2double(get(handles.LASER_POWER_MAX,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LASER_POWER_MAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function QE_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QE_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in REFIT.
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
guidata(hObject, handles);


% --- Executes on button press in FAKEDATA.
function FAKEDATA_Callback(hObject, eventdata, handles)
handles.fake_data = get(handles.FAKEDATA,'Value');
guidata(hObject, handles);


function LASERSET_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function LASERSET_CreateFcn(hObject, eventdata, handles)
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


% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data.charge = handles.charge;          % e- charge [nC]
data.energy = handles.energy;          % 
data.rsigresult = handles.rsigresult;
data.QEval = handles.QEval;
data.ElaserFit = handles.ElaserFit;
data.Qfit = handles.Qfit; 
data.charge_yoff = handles.charge_yoff; 
data.Efield = handles.Efield;

data.Rguess = handles.Rguess;
data.laser_phase = handles.laser_phase;

data.input.navg = handles.navg ;
data.input.nsettings = handles.nsettings;
data.input.wait = handles.wait; 
data.input.laser_power_min = handles.laser_power_min;
data.input.laser_power_max = handles.laser_power_max;

data.input.photon_energy = handles.photon_energy;
data.input.Efield = handles.Efield; 
data.input.laser_phase = handles.laser_phase;
data.input.range_frac = handles.range_frac;

ts_= handles.ts; 
header = ['QE_scan'];
name = [''];
[fileName, pathName] = util_dataSave(data,header,name,ts_);


% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dlgTitle = 'load data';
[data, fileName, pathName] = util_dataLoad(dlgTitle);

handles.charge = data.charge ;          % e- charge [nC]
handles.energy = data.energy;          % 
handles.rsigresult = data.rsigresult;
handles.QEval = data.QEval;
handles.ElaserFit = data.ElaserFit ;
handles.Qfit = data.Qfit; 
handles.charge_yoff = data.charge_yoff; 
handles.Efield = data.Efield;

handles.Rguess = data.Rguess;
handles.laser_phase = data.laser_phase;

handles.navg  = data.input.navg ;
handles.nsettings = data.input.nsettings;
handles.wait = data.input.wait; 
handles.laser_power_min = data.input.laser_power_min;
handles.laser_power_max = data.input.laser_power_min;

handles.photon_energy = data.input.photon_energy ;
handles.Efield = data.input.Efield; 
handles.laser_phase = data.input.laser_phase;
handles.range_frac = data.input.range_frac;

% set values 
set(handles.NAVG,'String',handles.navg);
set(handles.NSETTINGS,'String',handles.nsettings);
set(handles.WAIT,'String',handles.wait);
set(handles.PHOTONENERGY,'String',handles.photon_energy);

set(handles.E0,'String',handles.Efield);
set(handles.LASERPHASE,'String',handles.laser_phase);
set(handles.RANGEFRAC,'String',handles.range_frac);
set(handles.LASER_POWER_MIN,'String',handles.laser_power_min);
set(handles.LASER_POWER_MAX,'String',handles.laser_power_max);







