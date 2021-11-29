function varargout = cathode_characterization(varargin)
% CATHODE_CHARACTERIZATION M-file for cathode_characterization.fig
%      CATHODE_CHARACTERIZATION, by itself, creates a new CATHODE_CHARACTERIZATION or raises the existing
%      singleton*.
%
%      H = CATHODE_CHARACTERIZATION returns the handle to a new CATHODE_CHARACTERIZATION or the handle to
%      the existing singleton*.
%
%      CATHODE_CHARACTERIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CATHODE_CHARACTERIZATION.M with the given input arguments.
%
%      CATHODE_CHARACTERIZATION('Property','Value',...) creates a new CATHODE_CHARACTERIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before QE_scanner_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cathode_characterization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cathode_characterization

% Last Modified by GUIDE v2.5 26-Mar-2008 16:00:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cathode_characterization_OpeningFcn, ...
                   'gui_OutputFcn',  @cathode_characterization_OutputFcn, ...
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

% --- Executes just before cathode_characterization is made visible.
function cathode_characterization_OpeningFcn(hObject, eventdata, handles, varargin)
handles.screen_pv       = 'YAGS:IN20:241:PNEUMATIC';

handles.bpm_pv          = 'BPMS:IN20:221';
handles.laser_energy_pv = 'LASR:IN20:196:PWR';
handles.waveplate_pv    = 'WPLT:LR20:116:WP2_ANGLE';

handles.VCC_x_pv = 'VCTD:IN20:186:VCC_POS_X';
handles.VCC_y_pv = 'VCTD:IN20:186:VCC_POS_Y';
handles.LaserPower = 'LASR:BCIS:1:PCTRL';
handles.BPM_Att_pv = 'IOC:IN20:BP01:QANN';
handles.YAG02_pos_pv = 'YAGS:IN20:241:PNEUMATIC';
handles.VCC_p2p_pv = 'CAMR:IN20:186:TSHD_P2P';
handles.wheel_pos_pv = 'IRIS:LR20:118:MOTR_ANGLE.RBV';
[d,d,handles.ebeam_fdbk_pv] = control_chargeName;
handles.laser_fdbk_pv = 'LASR:IN20:160:POS_FDBK';

handles.BPM2_tmit_pv = 'BPMS:IN20:221:TMIT';
handles.BPM3_tmit_pv = 'BPMS:IN20:235:TMIT';

handles.timeout         = 10;       % timeout for synch. acquisition
handles.output = [];
title_str = {'Cathode Characterization'};
            
handles.pvNameSol  = 'SOLN:IN20:121';   
handles.pv_YAG02 = 'YAGS:IN20:241';

lcaPut('YAGS:IN20:241:ROI_XNP_SET',500);
lcaPut('YAGS:IN20:241:ROI_X_SET',800);
lcaPut('YAGS:IN20:241:ROI_YNP_SET',600);

handles.GridType.nVal = 3;
handles.GridType_txt = {'load';'generate';'with_scan'};
handles=appSetup(hObject,handles);                                                  

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = cathode_characterization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

%handles=dataMethodControl(hObject,handles,[],3);
set(handles.GridMethod,'String',[{'Load'},{'Create Now'},{'Create with Scan'}]);
set(handles.GridMethod,'Value',1);
set(handles.Grid,'String','Load Grid');
set(handles.Grid,'Visible','on');
set(handles.n_images_saved,'Visible','off');
set(handles.n_images_saved,'String',1);

% -------------reads initial conditions -------------
handles.VCC_x_ini = lcaGet('VCTD:IN20:186:VCC_POS_X.RBV');
handles.VCC_y_ini = lcaGet('VCTD:IN20:186:VCC_POS_Y.RBV');

handles.M2_x_ini = lcaGet('MIRR:IN20:162:M2_MOTR_H.RBV');
handles.M2_y_ini = lcaGet('MIRR:IN20:162:M2_MOTR_V.RBV');

handles.LaserPower_ini = lcaGet('LASR:BCIS:1:PCTRL');
handles.BPM_Att_ini = lcaGet('IOC:IN20:BP01:QANN');
handles.YAG02_pos_ini = lcaGet('YAGS:IN20:241:PNEUMATIC');
handles.VCC_p2p_ini = lcaGet('CAMR:IN20:186:TSHD_P2P');
[handles.wheel_pos_ini] = set_wheel([],2);
handles.ebeam_fdbk_ini = lcaGet(handles.ebeam_fdbk_pv,0,'double');
handles.laser_fdbk_ini = lcaGet('LASR:IN20:160:POS_FDBK');
handles.M2_H_pv = 'MIRR:IN20:162:M2_MOTR_H';
handles.M2_V_pv = 'MIRR:IN20:162:M2_MOTR_V';

handles.Sol_ini = lcaGet('SOLN:IN20:121:BACT');
guidata(hObject, handles);

% --- Executes on button press in StartAcq.
function StartAcq_Callback(hObject, eventdata, handles)

n_sol = str2num(get(handles.n_sol,'String'));

% switch off laser feedback and set laser 
lcaPut('LASR:IN20:160:POS_FDBK',0);
laserPowerIni = lcaGet('LASR:BCIS:1:PCTRL');
laserPowerMeas  = str2num(get(handles.laser_power_meas,'String'));
lcaPut('LASR:BCIS:1:PCTRL',laserPowerMeas);


laser_diam = str2num(get(handles.iris_diam,'String'));
set_wheel(laser_diam);

for isol = 1:n_sol,
    strsol = sprintf('%1d',isol);
    eval(['solVal = get(handles.solval_' strsol ',''String'')']);
    solVal = str2num(solVal);
    trim_magnet(handles.pvNameSol,solVal,'T');
    
    [nx_max,ny_max,n_VCC] = size(handles.VCC_data); 
    for i = 1:nx_max,
        for j = 1:ny_max,
         M2_x_target  = handles.VCC_data(i,j,1);  
         M2_y_target  = handles.VCC_data(i,j,2);  
         
         str_message = sprintf('Status: \n sol = %2.3f \n i = %1d out of %2d,  j = %1d out of %2d \n', ...
             solVal,i,nx_max,j,ny_max);
         set(handles.status_msg,'String',str_message);
         
         dist = 1;
         while dist >0.1
         lcaPut(handles.M2_H_pv,M2_x_target);
         lcaPut(handles.M2_V_pv,M2_y_target);
         m2x = lcaGet([handles.M2_H_pv '.RBV']);
         m2y = lcaGet([handles.M2_V_pv '.RBV']);  
         dist= sqrt((m2x-M2_x_target).^2+(m2y-M2_y_target).^2);
         end
          
         handles.CurrSolNumber = isol;
         handles.ni = i;
         handles.nj = j;
         handles = AcquireSolData(hObject,handles);
        end
    end
end

header = 'Cathode_charac_sum';
name = [];
ts_= handles.ts; 
data.stats_table = handles.stats_table;
data.std_table = handles.std_table;
data.VCC_data = handles.VCC_data;
data.bpm_tmit = handles.bpm_tmit; 
[fileName, pathName] = util_dataSave(data,header,name,ts_);
% --------  partial restore 
lcaPut('LASR:BCIS:1:PCTRL',laserPowerIni);
lcaPut('LASR:IN20:160:POS_FDBK',1);

guidata(hObject, handles);

% -----------  acquire data for single solenoid and single M2 position 
function handles = AcquireSolData(hObject,handles)

    isol = handles.CurrSolNumber;
    ni = handles.ni;
    nj = handles.nj;
    %  ---------- acquire YAG02 image  ; make statistics on beam sizes (50 samples)
    data = profmon_measure(handles.pv_YAG02,str2num(handles.config.N_samples),'nBG',str2num(handles.config.N_samples)); 
    ts_ = data.ts;
    handles.ts = ts_;
    
    image_sum = data(1).img;
    for iii = 2:str2num(handles.config.N_samples),
        image_sum = image_sum+data(iii).img;
    end 
    data_image = data(1);
    data_image.img = image_sum;
    
    % extracts stats (x y rms_x rms_y xy TMIT) from images
    method_ = 5;
    [stats,std_] = compute_Stat(data,method_);
    
    % extract part of image (and do statistics)
    %data_image = extract_image(data);
    
    %stats = data(1).beam(method_).stats;
    handles.stats_table(ni,nj,(1:6)+(isol-1)*6) = stats;
    handles.std_table(ni,nj,(1:6)+(isol-1)*6) = std_;
    
    tmit_bpm2 = 0;tmit_bpm3 = 0;
    nCurrent = 10;
    for i = 1:nCurrent,
    tmit_bpm2 = lcaGet(handles.BPM2_tmit_pv)+tmit_bpm2;
    tmit_bpm3 = lcaGet(handles.BPM3_tmit_pv)+tmit_bpm3;
    end
    tmit_bpm2 = tmit_bpm2/nCurrent;
    tmit_bpm3 = tmit_bpm3/nCurrent;
    
    handles.bpm_tmit(ni,nj,(1:2)+(isol-1)*2) = [tmit_bmpm2 tmit_bpm3];
    
    save_image_case = get(handles.save_images,'Value');
    
    if save_image_case == 1,
      n_image = str2num(get(handles.n_images_saved,'String'));
      % saves images 
      strsol = sprintf('%1d',isol);
      header = ['image_sol' strsol '_'];
      name = sprintf('%02d_%02d',ni,nj);
      %[fileName, pathName] = util_dataSave(data(1:n_image),header,name,ts_);
      [fileName, pathName] = util_dataSave(data_image,header,name,ts_);
    end

guidata(hObject,handles);

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


% --- Executes on button press in save_config.
function save_config_Callback(hObject, eventdata, handles)
handles = read_config(hObject,handles);
config= handles.config;
util_configSave('cathode_characterization', config, 'saves config');
guidata(hObject,handles);


% --- Executes on button press in load_config.
function load_config_Callback(hObject, eventdata, handles)
config = util_configLoad('cathode_characterization','loads default config');
handles.config = config;
handles = refresh_config(hObject,handles);
guidata(hObject,handles)


% --- Executes on selection change in GridMethod.
function GridMethod_Callback(hObject, eventdata, handles)

val = get(handles.GridMethod,'Value');
switch val,
    case 1
        handles = loadGrid(hObject,handles); 
    case 2
        handles = createGrid(hObject,handles);
    case 3
        handles = with_scan(hObject,handles);
end
guidata(hObject,handles);


% --- Executes on button press in Grid.
function Grid_Callback(hObject, eventdata, handles)

val = get(handles.GridMethod,'Value');
switch val
    case 1
        handles = load_Grid_data(hObject,handles);
    case 2
        handles = generate_Grid_data(hObject,handles);
end
guidata(hObject,handles);

        
% --- Executes during object creation, after setting all properties.
function GridMethod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ----------------------------------------------------------
function handles = loadGrid(hObject,handles)

set(handles.Grid,'String','Load Grid');

set(handles.nstep_x,'Enable','off');
set(handles.nstep_y,'Enable','off');
set(handles.x_step,'Enable','off');
set(handles.y_step,'Enable','off');
set(handles.laser_power_level_fdbk,'Enable','off');

set(handles.Grid,'Visible','on','String','Load Grid');

guidata(hObject,handles);

function handles = createGrid(hObject,handles)

set(handles.Grid,'Visible','on','String','Create Grid Now');
v = get(handles.Grid,'Position');
set(handles.Grid,'Position',[v(1) v(2) 18 v(4)]);

set(handles.nstep_x,'Enable','on');
set(handles.nstep_y,'Enable','on');
set(handles.x_step,'Enable','on');
set(handles.y_step,'Enable','on');
set(handles.laser_power_level_fdbk,'Enable','on');

guidata(hObject,handles);

function with_scan(hObject,handles)
guidata(hObject,handles);

%------------ loads grid data (handles.VCC_data)-----------
function handles = load_Grid_data(hObject,handles)
dlgTitle = 'Load Grid Data File';
[data, fileName, pathName] = util_dataLoad(dlgTitle);
handles.VCC_data = data.VCC_data;
handles.config = data.config;
handles = refresh_config(hObject,handles);
 
set(handles.message_scan,'String',['loaded grid data from: ' pathName ' ' fileName]);
guidata(hObject,handles);

% ------------ generate grid data (creates handles.VCC_data and saves it) -------
function handles = generate_Grid_data(hObject,handles)
    
% increase laser power to level required for fdbk to work 
laserPowerIni = lcaGet('LASR:BCIS:1:PCTRL');
laserPower = num2str(get(handles.laser_power_level_fdbk,'String'));
lcaPut('LASR:BCIS:1:PCTRL',laserPower); 

% records fdbk initial setup values 
status_fdbk = lcaGet('LASR:IN20:160:POS_FDBK');
P2P_level = lcaGet('CAMR:IN20:186:TSHD_P2P');
n_average =lcaGet('LASR:IN20:100:POS_FDBK_AVGTIME');
min_displacement = lcaGet('LASR:IN20:160:POS_FDBK_MIN');

% close laser transverse feedback 
lcaPut('LASR:IN20:160:POS_FDBK',1);
lcaPut('CAMR:IN20:186:TSHD_P2P',0);
lcaPut('LASR:IN20:100:POS_FDBK_AVGTIME',10);
lcaPut('LASR:IN20:160:POS_FDBK_MIN',0.03);
    
nx_steps = str2num(get(handles.nstep_x,'String'));
ny_steps = str2num(get(handles.nstep_y,'String'));
x_step = str2num(get(handles.x_step,'String'));
y_step = str2num(get(handles.y_step,'String'));
handles.VCC_data = zeros(nx_steps,ny_steps,6);

handles =readLaserPosition(hObject,handles);
VCC_ini = handles.LaserCurrPos;

mx_o = VCC_ini(3);
my_o = VCC_ini(4);

handles.mx_o = mx_o;
handles.my_o = my_o;

ni = 0;
if 1

for i = -(nx_steps-1)/2:(nx_steps-1)/2,
    ni = ni+1;
    nj = 0;
  for j = -(ny_steps-1)/2:(ny_steps)/2,
     nj = nj+1;
     [ni nj]
    % calculates position 
    xpos = mx_o +i*x_step;
    ypos = my_o +j*y_step;    
    
    str_message = sprintf('Generate grid: i = %1d out of %2d , j = %1d out of %2d \n',i,nx_steps,j,ny_steps);
 
    % moves VCC in position 
    dist_ = 1;
    while dist_ > 3e-4,
     lcaPut('VCTD:IN20:186:VCC_POS_X',xpos);
     lcaPut('VCTD:IN20:186:VCC_POS_Y',ypos);
     xpos_new = lcaGet('VCTD:IN20:186:VCC_POS_X.RBV');
     ypos_new = lcaGet('VCTD:IN20:186:VCC_POS_Y.RBV');
     dist_ = sqrt((xpos-xpos_new)^2+(ypos-ypos_new)^2);
    end 
    
   % waits at end of line  
   if j == -(ny_steps-1),
       set(handles.message_scan,'String','pausing for 12 s');
       pause(12);
    else 
        set(handles.message_scan,'String','pausing for 5 s');
        pause(5);
   end
   
    set(handles.message_scan,'String',[str_message , 'Checking error signal']);
    
    % verifies error signal below 50 microns
    err_x_PV = 'CAMR:IN20:186:CTRD_H_ERR';
    err_y_PV = 'CAMR:IN20:186:CTRD_V_ERR';
    dist = 1;
    while dist > 0.050,
        err_x = lcaGet(err_x_PV);
        err_y = lcaGet(err_y_PV);
        dist = sqrt(err_x^2+err_y^2);
    end 

    % record M2,VCC positions 
    handles =readLaserPosition(hObject,handles);
    handles.VCC_data(ni,nj,:) = handles.LaserCurrPos;
  end
end
end


%
    % moves VCC back in position 
    dist_ = 1;
    while dist_ > 3e-4,
     lcaPut('VCTD:IN20:186:VCC_POS_X',mx_o);
     lcaPut('VCTD:IN20:186:VCC_POS_Y',my_o);
     xpos_new = lcaGet('VCTD:IN20:186:VCC_POS_X.RBV');
     ypos_new = lcaGet('VCTD:IN20:186:VCC_POS_Y.RBV');
     dist_ = sqrt((mx_o-xpos_new)^2+(my_o-ypos_new)^2);
    end 
% set laser power and transverse feedback back 

lcaPut('LASR:BCIS:1:PCTRL',laserPowerIni);
lcaPut('LASR:IN20:160:POS_FDBK',status_fdbk);
lcaPut('CAMR:IN20:186:TSHD_P2P',P2P_level);
lcaPut('LASR:IN20:100:POS_FDBK_AVGTIME',n_average);
lcaPut('LASR:IN20:160:POS_FDBK_MIN',min_displacement);

% save data 
data.VCC_data = handles.VCC_data;
handles = read_config(hObject,handles);
data.config = handles.config; 

header = 'lookup_table_M2';
[value,lcaTS]=lcaGet('SOLN:IN20:121:BACT');
ts = lca2matlabTime(lcaTS);
name = [];
[fileName, pathName] = util_dataSave(data, header, name, ts);

 set(handles.message_scan,'String',['Done saving Grid data in filename: ' pathName ' ' fileName]);
guidata(hObject,handles);


function  handles = with_scan(hObject,handles)
set(handles.Grid,'Visible','off');
guidata(hObject,handles);


function handles = read_config(hObject,handles)
handles.config.nx_ = get(handles.nstep_x,'String');
handles.config.ny_ = get(handles.nstep_y,'String');
handles.config.x_ = get(handles.x_step,'String');
handles.config.y_ = get(handles.y_step,'String');
handles.config.lsr_min = get(handles.laser_power_meas_txt,'String');
handles.config.lsr_max = get(handles.laser_power_level_fdbk,'String');
handles.config.iris_ = get(handles.iris_diam,'String');
handles.config.sol_num = get(handles.n_sol,'String');
sol_num = str2num(handles.config.sol_num);
for isol = 1:sol_num,
    strsol = sprintf('%1d',isol);
    eval(['handles.config.solval_' strsol ' = get(handles.solval_' strsol ',''String'');']);
end
handles.config.N_samples = get(handles.n_samples,'String');

guidata(hObject,handles);

function handles = refresh_config(hObject,handles)
 set(handles.nstep_x,'String',handles.config.nx_);
 set(handles.nstep_y,'String',handles.config.ny_);
 set(handles.x_step,'String',handles.config.x_);
 set(handles.y_step,'String',handles.config.y_);
 set(handles.laser_power_meas_txt,'String',handles.config.lsr_min);
 set(handles.laser_power_level_fdbk,'String',handles.config.lsr_max);
 set(handles.iris_diam,'String',handles.config.iris_);
 set(handles.n_sol,'String',handles.config.sol_num);
 sol_num = str2num(handles.config.sol_num);
for isol = 1:sol_num,
    strsol = sprintf('%1d',isol);
    eval(['set(handles.solval_' strsol ',''String'',handles.config.solval_' strsol ');']);
end
 set(handles.n_samples,'String',handles.config.N_samples);



% ------------------  redundant with generateGrid (need to combine them)
% ------------------  or will suppress scan Grid 
function handles = scanGrid(hObject,handles)
handles = storeInitialParam(hObject,handles);
nx_steps = str2num(get(handles.nstep_x,'String'));
ny_steps = str2num(get(handles.nstep_y,'String'));
x_step = str2num(get(handles.x_step,'String'));
y_step = str2num(get(handles.y_step,'String'));
handles.VCC_data = zeros(nx_steps,ny_steps,6);

handles =readLaserPosition(hObject,handles);
VCC_ini = handles.LaserCurrPos;

mx_o = VCC_ini(3);
my_o = VCC_ini(4);

handles.mx_o = mx_o;
handles.my_o = my_o;

ni = 0;

for i = -(nx_steps-1)/2:(nx_steps-1)/2,
    ni = ni+1;
    nj = 0;
  for j = -(ny_steps-1)/2:(ny_steps)/2,
     nj = nj+1;
     [ni nj]
    % -------- calculates position 
    xpos = mx_o +i*x_step;
    ypos = my_o +j*y_step;    
    
    str_message = sprintf(' i = %1d out of %2d , j = %1d out of %2d \n',i,nx_steps,j,ny_steps);
    
    %-----------  increase laser power max
    lcaPut('LASR:BCIS:1:PCTRL',handles.laserPowerHigh); 
              
    % close laser transverse feedback 
    lcaPut('LASR:IN20:160:POS_FDBK',1);
    lcaPut('CAMR:IN20:186:TSHD_P2P',1);
 

    % --------  move VCC in position 
    dist_ = 1;
    while dist_ > 3e-4,
     lcaPut('VCTD:IN20:186:VCC_POS_X',xpos);
     lcaPut('VCTD:IN20:186:VCC_POS_Y',ypos);
     xpos_new = lcaGet('VCTD:IN20:186:VCC_POS_X.RBV');
     ypos_new = lcaGet('VCTD:IN20:186:VCC_POS_Y.RBV');
     dist_ = sqrt((xpos-xpos_new)^2+(ypos-ypos_new)^2);
    end 
    
    
   % waits  
   if j == -(ny_steps-1),
       set(handles.message_scan,'String','pausing for 12 s');
       pause(12);
    else 
        set(handles.message_scan,'String','pausing for 5 s');
        pause(5);
   end
   
    set(handles.message_scan,'String',[str_message , 'Checking error signal']);
    % test on centroid on VCC image (needs to be back to zero)
    % check on error signal of the transverse feedback loop 
    err_x_PV = 'CAMR:IN20:186:CTRD_H_ERR';
    err_y_PV = 'CAMR:IN20:186:CTRD_V_ERR';
    dist = 1;
    while dist > 0.02,
        err_x = lcaGet(err_x_PV);
        err_y = lcaGet(err_y_PV);
        dist = sqrt(err_x^2+err_y^2);
    end 

    % record M2,VCC positions 
     
    handles =readLaserPosition(hObject,handles)
    handles.VCC_data(ni,nj,:) = handles.LaserCurrPos;
        
    %  --------------     ends laser transverse feedback       
  end   % for j
end     % for i 

handles = restoreInitialParam(hObject,handles);
guidata(hObject,handles);


function handles = readLaserPosition(hObject,handles)
data=zeros(1,6);
data(1) = lcaGet('MIRR:IN20:162:M2_MOTR_H.RBV');
data(2) = lcaGet('MIRR:IN20:162:M2_MOTR_V.RBV');
data(3) = lcaGet('VCTD:IN20:186:VCC_POS_X.RBV');
data(4) = lcaGet('VCTD:IN20:186:VCC_POS_Y.RBV');
data(5) = lcaGet('CAMR:IN20:186:CTRD_V');
data(6) = lcaGet('CAMR:IN20:186:CTRD_H');
handles.LaserCurrPos = data; 
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



% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)


% --- Executes on button press in plot_data.
function plot_data_Callback(hObject, eventdata, handles)



% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
header = ['Cathode_Characterization_' ];
name = [];
ts_ = handles.ts;
[fileName, pathName] = util_dataSave([handles.stats_table handles.VCC_data],header,name,ts_);
guidata(hObject,handles);


% --- Executes on button press in save_images.
function save_images_Callback(hObject, eventdata, handles)
val = get(handles.save_images,'Value');
switch val 
    case 1, 
    set(handles.n_images_saved,'Visible','on');
    case 2
    set(handles.n_images_saved,'Visible','off');     
end
guidata(hObject,handles);


% --- Executes on button press in restores_initial_state.
function restores_initial_state_Callback(hObject, eventdata, handles)

 lcaPut('VCTD:IN20:186:VCC_POS_X',handles.VCC_x_ini);
 lcaPut('VCTD:IN20:186:VCC_POS_Y',handles.VCC_y_ini);
 [handles.wheel_pos_ini] = set_wheel(handles.wheel_pos_ini,2);
 
 lcaGet('MIRR:IN20:162:M2_MOTR_H',handles.M2_x_ini);
 lcaGet('MIRR:IN20:162:M2_MOTR_V',handles.M2_y_ini);

 handles.Sol_ini = lcaGet('SOLN:IN20:121:BACT');
 solVal = handles.Sol_ini;
 trim_magnet(handles.pvNameSol,solVal,'T');
 
 
 lcaPut('LASR:BCIS:1:PCTRL',handles.LaserPower_ini);
 lcaPut('IOC:IN20:BP01:QANN',handles.BPM_Att_ini);
 lcaPut('YAGS:IN20:241:PNEUMATIC',handles.YAG02_pos_ini);
 lcaPut('CAMR:IN20:186:TSHD_P2P',handles.VCC_p2p_ini);
 
 lcaPut(handles.ebeam_fdbk_pv,handles.ebeam_fdbk_ini);
 lcaPut('LASR:IN20:160:POS_FDBK',handles.laser_fdbk_ini);

guidata(hObject,handles);

% --- Executes on selection change in list_of_graphics.
function list_of_graphics_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function list_of_graphics_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function x_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function x_step_Callback(hObject, eventdata, handles)


function y_step_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function y_step_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function n_sol_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function solval_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function solval_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function solval_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function n_samples_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function n_samples_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nstep_x_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function nstep_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nstep_y_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function nstep_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function laser_power_meas_Callback(hObject, eventdata, handles)
    

% --- Executes during object creation, after setting all properties.
function laser_power_meas_txt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function laser_power_level_fdbk_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function laser_power_meas_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function laser_power_level_fdbk_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function iris_diam_Callback(hObject, eventdata, handles)
    
% --- Executes during object creation, after setting all properties.
function iris_diam_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function solval_1_Callback(hObject, eventdata, handles)

function solval_2_Callback(hObject, eventdata, handles)

function solval_3_Callback(hObject, eventdata, handles)



function n_sol_Callback(hObject, eventdata, handles)
 sol_num = str2num(get(handles.n_sol,'String'));
switch sol_num 
    case 1
        set(handles.solval_1,'Visible','on');
        set(handles.solval_2,'Visible','off');
        set(handles.solval_3,'Visible','off');    
    case 2 
         set(handles.solval_1,'Visible','on');
         set(handles.solval_2,'Visible','on');
         set(handles.solval_3,'Visible','off');
    case 3
         set(handles.solval_1,'Visible','on');
         set(handles.solval_2,'Visible','on');
         set(handles.solval_3,'Visible','on');
    otherwise
    h = msgbox('needs to be < 4 and > 0');
end

function [stats,std_] = compute_Stat(data,method_)
%
n = length(data);
p = length([data(1).beam(method_).stats]);
table = zeros(n,p);

for i = 1:n,
    table(i,:) = data(i).beam(method_).stats;
end
stats = mean(table);
std_ = std(table);


function n_images_saved_Callback(hObject, eventdata, handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function n_images_saved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_images_saved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


