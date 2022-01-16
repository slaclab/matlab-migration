%%
function varargout = GainLengthGUI(varargin)
% GAINLENGTHGUI M-file for GainLengthGUI.fig
%      GAINLENGTHGUI, by itself, creates a new GAINLENGTHGUI or raises the existing
%      singleton*.
%
%      H = GAINLENGTHGUI returns the handle to a new GAINLENGTHGUI or the handle to
%      the existing singleton*.
%
%      GAINLENGTHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAINLENGTHGUI.M with the given input arguments.
%
%      GAINLENGTHGUI('Property','Value',...) creates a new GAINLENGTHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GainLengthGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GainLengthGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GainLengthGUI

% Last Modified by GUIDE v2.5 28-Jan-2014 19:35:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GainLengthGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GainLengthGUI_OutputFcn, ...
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



% --- Executes when user attempts to close JitterGui.
function GainLengthGUI_CloseRequestFcn(hObject, eventdata, handles)

% if ~ispc
%     eDefRelease(handles.eDefNumber);
% end
util_appClose(hObject);

%%
% --- Executes just before GainLengthGUI is made visible.
function GainLengthGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GainLengthGUI (see VARARGIN)


% AIDA-PVA imports
global pvaRequest;
global AIDA_DOUBLE_ARRAY;

% Choose default command line output for GainLengthGUI
handles.output = hObject;

% offline debugging
% FINISH FINISH FINISH
handles.online = 1;

% conversion factor for yag
handles.yag_conv = 4e-9;


% Default PV values
handles.x_emit = 1.2;
handles.y_emit = 1.2;
handles.max_e = 13.65;      % energy in GeV
handles.e_spread = 2.8;     % espread in gamma
handles.curr = 3.4;         % current in kA
handles.bl = 7;             % bunch length in um

handles.und_num = 33;       % number of undulators
handles.num_shots = 120;     % number of shots per data point
handles.in_pos = 30;         % maximum position of undulator considered 'in'
handles.out_pos = 80;       % maximum position of undulator when 'out'
handles.out_enough = 78;       % maximum position of undulator considered 'out'
handles.move_in_wait = 20;     % time to wait after undulator reaches 'in' position to be exactly correct

% FINISH FINISH FINISH
handles.scram_amp = 2;          % amplitude of random motion for scrambling undulators
handles.min_und_scram_pos = 1;          % min position of scrambled undulators
handles.max_und_scram_pos = 3;          % max position of scrambled undulators


handles.und_length = 3.35;     % length of undulators in meters
handles.seg_length = 4;     % length of undulator segment in meters including drift spaces
handles.orbit_to_kick = 10^-5;  % conversion for orbit to kick strength at 13.6GeV
handles.max_kick = 0.00550;   % Maximum kick size (corresponds to 200um)
handles.mag_diff = 0.003  ;   % Above this limit, consider beam has been 'kicked'
handles.phase_advance = 15;   % number of undulators corresponding to slightly more than pi/2 phase advance at 13 GeV
handles.nC_to_ne = 6.241506e9;  % convert nC to electrons
handles.e_rest   = 5.11e-4;     % electron rest mass in GeV
handles.start_ykick = 1;        % filter level at which to start kicking in y
% FINISH FINISH FINISH
handles.low_energy = 0;         % use 2 kicks when energy below handles.low_energy*handles.nom_e

% camera values
handles.OD = 10;   % filter factor, 9.6 for OD1, 9.6^2 for OD2
handles.camera_max = 1e7;     % maximum signal for camera.  (always want OD2 above this limit)
handles.camera_min = 8e5;
handles.rec_roi    = 3e4;   % recommended number of pixels for yagxray camera roi
handles.camera_pixel_sat = 2^12-1-100;   % max pixel count for yagxray camera
handles.di_camera_pixel_sat = 50000/2; % max pixel count for direct imager camera
handles.filter_strength = handles.OD;  % yagxray filter strength
handles.di_filter_strength = 3.1623;  % di filter strength (sqrt(10))


handles.dirimg_max = 10^-1;       % saturation level for direct imager (units?)
handles.dicutoff_low = 10;        % if 10X below saturation level, retake data
handles.dicutoff_getting_low = 5; % if 5X below saturation level, change attenuation for next point
handles.di_change_atten = 4;      % when changing attenuation, change by factor of 4

% File names for Genesis
handles.base_file = 'lcls_gl_base.in';
handles.input_file = 'lcls_gl_input.in';
handles.filename_file = 'GEN_INPUT_FILE_NAMES';       % contains names of all genesis input files
handles.gen_result_file = 'gen_result.txt';
handles.mystatus = 'gen_status.txt';
handles.output_file = 'gen_output.out';
handles.data_file = 'gen_power_data.txt';

% Save data to folder
%handles.save_folder = '/u1/lcls/matlab/data/gainlength/';
handles.save_folder = '/home/physics/';

% Default Values
%handles.LogGen = get(handles.LOGGEN,'Value');
handles.genZ = [];
handles.genP = [];
handles.gen_f = [];
handles.measZ = [];
handles.meas_p = [];
handles.meas_f = [];
handles.meas_gl = 0;

if handles.online
  requestBuilder = pvaRequest('BPMS:LTU1:250:twiss');
  requestBuilder.returning(AIDA_DOUBLE_ARRAY);
  requestBuilder.with('TYPE','DESIGN');
  twiss(:,1) = ML(requestBuilder.get());

  requestBuilder = pvaRequest('BPMS:LTU1:450:twiss');
  requestBuilder.returning(AIDA_DOUBLE_ARRAY);
  requestBuilder.with('TYPE','DESIGN');
  twiss(:,2) = ML(requestBuilder.get());

  twiss = cell2mat(twiss);
  handles.dl2_eta = twiss(5,:)*1000;
end

handles.meas_e = 0;

% make undulator pv names
for j=1:handles.und_num
  handles.und_names{j} = ['USEG:UND1:' num2str(j) '50:TMXPOSC'];
  handles.und_names1{j} = ['USEG:UND1:' num2str(j) '50:LP4POSCALC'];
  handles.und_names2{j} = ['USEG:UND1:' num2str(j) '50:LP8POSCALC'];
end

% make magnet pv names
for j=1:handles.und_num
    % X/Y MAG BDES
    handles.xmag_names{j} = ['XCOR:UND1:' num2str(j) '80'];
    handles.ymag_names{j} = ['YCOR:UND1:' num2str(j) '80'];

    handles.xmag_bdes{j} = ['XCOR:UND1:' num2str(j) '80:BDES'];
    handles.ymag_bdes{j} = ['YCOR:UND1:' num2str(j) '80:BDES'];

end


% default for firstmag is the first xcorr;
handles.firstmag = handles.xmag_names(1);
handles.first_mag_bdes = handles.xmag_bdes(1);
handles.firstmag_kick = str2num(get(handles.MAGDIST,'String'))*handles.orbit_to_kick;  % convert orbit distortion to mag strength
if handles.online
    handles.firstmag_start_pos = lcaGetSmart(handles.first_mag_bdes);
end


% Undulator insertion status pvs
for j=1:handles.und_num
  handles.und_insert_pvs{j} = ['USEG:UND1:' num2str(j) '50:INSTALTNSTAT'];
end




handles.feedback = {'FBCK:UND0:1:ENABLE';'FBCK:FB03:TR04:MODE'};
% FINISH FINISH FINISH
handles.HXRSS_feedback = {'SIOC:SYS0:ML00:AO818'};


% PVs for filtering data
handles.event_pvs =   {'BPMS:LTU1:250'
                       'BPMS:LTU1:450'
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
                       };

handles.curr_pvs =    {'BLEN:LI24:886:BIMAX'};

handles.eloss_pvs =    {'SIOC:SYS0:ML00:AO562'};


% Simulation PVs
handles.tmit_softpvs = 'SIOC:SYS0:ML00:AO175';
handles.curr_softpvs = 'SIOC:SYS0:ML00:AO195';
handles.bl_softpvs   = 'SIOC:SYS0:ML00:AO196';
handles.curr_set_pt_pvs = 'FBCK:FB04:LG01:S5DES';
handles.energy_pvs   = 'BEND:DMP1:400:BDES';
handles.IN20_emitx    = 'WIRE:IN20:561:EMITN_X';
handles.IN20_emity    = 'WIRE:IN20:561:EMITN_Y';
handles.IN20_bmagx    = 'WIRE:IN20:561:BMAG_X';
handles.IN20_bmagy    = 'WIRE:IN20:561:BMAG_Y';
handles.LTU_emitx    = 'WIRE:LTU1:735:EMITN_X';
handles.LTU_emity    = 'WIRE:LTU1:735:EMITN_Y';
handles.LTU_bmagx    = 'WIRE:LTU1:735:BMAG_X';
handles.LTU_bmagy    = 'WIRE:LTU1:735:BMAG_Y';
handles.lh_energy_pvs = 'LASR:IN20:475:PWR1H';


% ELoss BPMs
handles.eloss_bpm_pvs =   {'BPMS:LTU0:190'
                           'BPMS:LTU1:250'
                           'BPMS:LTU1:450'
                           'BPMS:DMP1:299'
                           'BPMS:DMP1:381'
                           'BPMS:DMP1:398'
                           'BPMS:DMP1:502'
                           'BPMS:DMP1:693'};
%

% % Near FOV Direct Image PVs
% handles.ndir_img_pvs =  {'DIAG:FEE1:481:RawMax'
%                          'DIAG:FEE1:481:RoiMax'
%                          'DIAG:FEE1:481:FitPulseE'
%                          'DIAG:FEE1:481:RoiPulseE'
%                          'DIAG:FEE1:481:FitAttnPulseE'
%                          'DIAG:FEE1:481:RoiAttnPulseE'
%                          'DIAG:FEE1:481:FitAbsorbPulseE'
%                          'DIAG:FEE1:481:RoiAbsorbPulseE'};
%
% % Wide FOV Direct Image PVs
% handles.wdir_img_pvs =  {'DIAG:FEE1:482:RawMax'
%                          'DIAG:FEE1:482:RoiMax'
%                          'DIAG:FEE1:482:FitPulseE'
%                          'DIAG:FEE1:482:RoiPulseE'
%                          'DIAG:FEE1:482:FitAttnPulseE'
%                          'DIAG:FEE1:482:RoiAttnPulseE'
%                          'DIAG:FEE1:482:FitAbsorbPulseE'
%                          'DIAG:FEE1:482:RoiAbsorbPulseE'};

% Near FOV Direct Image PVs
handles.ndir_img_pvs =  {'DIAG:FEE1:481:RawMax'
                         'DIAG:FEE1:481:RoiMax'
                         'DIAG:FEE1:481:FitPulseE'
                         'DIAG:FEE1:481:RawSumGrays'%'DIAG:FEE1:481:RoiPulseE'
                         'DIAG:FEE1:481:RawXCent'
                         'DIAG:FEE1:481:RawYCent'
                         'DIAG:FEE1:481:RoiXCentSigma'
                         'DIAG:FEE1:481:RoiYCentSigma'};

% Wide FOV Direct Image PVs
handles.wdir_img_pvs =  {'DIAG:FEE1:482:RawMax'
                         'DIAG:FEE1:482:RoiMax'
                         'DIAG:FEE1:482:FitPulseE'
                         'DIAG:FEE1:482:RawSumGrays'%'DIAG:FEE1:482:RoiPulseE'
                         'DIAG:FEE1:482:RawXCent'
                         'DIAG:FEE1:482:RawYCent'
                         'DIAG:FEE1:482:RoiXCentSigma'
                         'DIAG:FEE1:482:RoiYCentSigma'};

% Processing for NFOV Camera
handles.nfov_process = {'DIAG:FEE1:481:ClusterOPT'
                        'DIAG:FEE1:481:FitOPT'
                        'DIAG:FEE1:481:PulseEOPT'};

% Gas Detector PVs
handles.gdet_pvs =  {'GDET:FEE1:241:ENRC'
                     'GDET:FEE1:242:ENRC'
                     'GDET:FEE1:361:ENRC'
                     'GDET:FEE1:362:ENRC'};


% Total Energy Detector PVs
handles.tedet_pvs =  {'ELEC:FEE1:452:DATA'
                      'ELEC:FEE1:453:DATA'};



handles.fee_atten_pvs = {'SATT:FEE1:320:RACT'
                         'GATT:FEE1:310:R_ACT'};

handles.atten_control_pvs = {'SATT:FEE1:320:RDES'
                             'SATT:FEE1:320:GO'
                             'SATT:FEE1:320:RACT'};

handles.attens_status_pvs = {'SATT:FEE1:321:STATE'
                           'SATT:FEE1:322:STATE'
                           'SATT:FEE1:323:STATE'
                           'SATT:FEE1:324:STATE'
                           'SATT:FEE1:325:STATE'
                           'SATT:FEE1:326:STATE'
                           'SATT:FEE1:327:STATE'
                           'SATT:FEE1:328:STATE'
                           'SATT:FEE1:329:STATE'};
% Direct imager PVs

handles.di_cw_pvs =   {'STEP:FEE1:484:MOVECW'
                           'STEP:FEE1:485:MOVECW'};

handles.di_ccw_pvs =  {'STEP:FEE1:484:MOVECCW'
                           'STEP:FEE1:485:MOVECCW'};

handles.ndi_pos_pvs = {'STEP:FEE1:484:POSITION0'
                       'STEP:FEE1:484:POSITION1'
                       'STEP:FEE1:484:POSITION2'
                       'STEP:FEE1:484:POSITION3'
                       'STEP:FEE1:484:POSITION4'};

handles.wdi_pos_pvs = {'STEP:FEE1:485:POSITION0'
                       'STEP:FEE1:485:POSITION1'
                       'STEP:FEE1:485:POSITION2'
                       'STEP:FEE1:485:POSITION3'
                       'STEP:FEE1:485:POSITION4'};


handles.di_OD_pos_pvs = {'STEP:FEE1:484:POSITION'
                         'STEP:FEE1:485:POSITION'};

% K-Mono
handles.kmono_pvs = {'KMON:FEE1:421:ENRC'};


handles.gen_pvs =   {handles.energy_pvs
                     handles.curr_softpvs
                     handles.bl_softpvs
                     handles.IN20_emitx
                     handles.IN20_emity
                     handles.IN20_bmagx
                     handles.IN20_bmagy};

handles.num_pvs = length(handles.event_pvs);

for j=1:length(handles.event_pvs)
  handles.event_x_pvs{j} = [handles.event_pvs{j} ':X'];
  handles.event_dat_pvs{3*j-2} = [handles.event_pvs{j} ':X'];
  handles.event_y_pvs{j} = [handles.event_pvs{j} ':Y'];
  handles.event_dat_pvs{3*j-1} = [handles.event_pvs{j} ':Y'];
  handles.event_tmit_pvs{j} = [handles.event_pvs{j} ':TMIT'];
  handles.event_dat_pvs{3*j} = [handles.event_pvs{j} ':TMIT'];
end

for j=1:length(handles.eloss_bpm_pvs)
  handles.eloss_xbpm_pvs{j} = [handles.eloss_bpm_pvs{j} ':X'];
  handles.eloss_ybpm_pvs{j} = [handles.eloss_bpm_pvs{j} ':Y'];
end


% parameters for a closed orbit kick
handles.closed_orbit = 1; % for now hard code in closed orbit
handles.two_plane_kick = 1; % for now hard code in two plane
handles.last_closed_corr = 27;  % last corrector that works with closed orbit kick
handles.max_E_closed = 6;   % max energy for which closed orbit works
handles.max_E_no_spont = 6;   % max energy for you can ignore spontaneous
handles.kick_plane = 'xy';

% Current energy
if handles.online
    handles.nom_e = lcaGetSmart(handles.energy_pvs);
else
    handles.nom_e=handles.max_e;
end
handles.energy = handles.nom_e;


if handles.online; handles = UpdateGUI(hObject,eventdata,handles); end

% energy loss in undulators.
handles.eloss = 0;
handles.eloss_val = 0;
handles.eloss_navg = 30;
if handles.online; handles.eloss_Loss_per_Ipk = lcaGetSmart('PHYS:SYS0:1:ELOSSPERIPK');end
handles.eloss_last_ipk_pv = 'PHYS:SYS0:1:ELOSSIPK';
handles.eloss_ipk_setpnt_pv = 'SIOC:SYS0:ML00:AO188';


% Tolerances for orbit, charge and energy
handles.sig_tmit = 0.1;
handles.sig_energy = 0.1;
handles.sig_curr = 0.1;
handles.sig_orbit = 0.5;
handles.min_charge = 1e7; %10^7
%handles.min_charge=1e1;

% Misc PVs

handles.xpp_spec = 'XPP:OPAL1K:1';  % replace DI with XPP Opal
%handles.xpp_spec = 'XPP:OPAL1K:1:LiveImage';  % replace DI with XPP Opal projection
%handles.xpp_spec = 'CAMR:FEE1:441:IMAGE_CMPX';  % replace DI with FEE spectrometer
%handles.xpp_spec = 'SXR:EXS:CVV:01:IMAGE_CMPX';  % replace DI with SXR spectrometer
handles.fee_spec = 'CAMR:FEE1:441';  % replace DI with FEE spectrometer
handles.sxr_spec = 'SXR:EXS:CVV:01:IMAGE_CMPX';  % replace DI with SXR spectrometer
%handles.sxr_spec = 'SXR:EXS:CVV:01:IMAGE:CMPX:Hprj';  % replace DI with SXR spectrometer, vertical projection
handles.ndirimg_profmon = 'DIAG:FEE1:481';  % X-ray profmon
handles.wdirimg_profmon = 'DIAG:FEE1:482';  % X-ray profmon
handles.xray_profmon = 'YAGS:DMP1:500';       % X-ray profmon
handles.xray_tmit    = 'SIOC:SYS0:ML00:AO594';  % X-ray total signal
handles.BYKick = 'IOC:BSY0:MP01:BYKIKCTL';    % BYKick
handles.TDUND = 'DUMP:LTU1:970:TDUND_PNEU';   % TDUND control
handles.TDUND_stat = 'DUMP:LTU1:970:TGT_STS'; % TDUND Status
handles.rate = 'IOC:IN20:MC01:LCLSBEAMRATE';  % BeamRate
handles.pockel = 'TRIG:LR20:LS01:TCTL';  % pockel cell

% wait for a few shots for beam to stabilize after turning on BYKick60
% FINISH FINISH FINISH
handles.BYKick_pause = 0.2;
handles.TDUND_pause = 3;

% use xpp spectrometer (for self seeding)
acq_types = get(handles.ACQ_METHOD,'String');
curr_type = get(handles.ACQ_METHOD,'Value');
handles.acq_method = acq_types(curr_type);

if strcmp(handles.acq_method,'FEE Spectrometer') || strcmp(handles.acq_method,'XPP Spectrometer') || strcmp(handles.acq_method,'SXR Spectrometer')
    set(handles.DETECTOR,'Value',7)
    handles.use_yag=0;
elseif strcmp(handles.acq_method,'YAGXRAY/DIR_IMG')
    handles.use_yag=1;
end


% optical density filters for yagx camera and Ni Foil
handles.OD_pvs =     {'YAGS:DMP1:500:FLT1_PNEU'
                      'YAGS:DMP1:500:FLT2_PNEU'};

handles.yagxray_status_pvs = {'YAGS:DMP1:500:PNEUMATIC'};

% % Initialize Data Register
handles.data = [];


% Initialize config as present status
if handles.online
    handles.kicked_mag = 0;
    handles = UndStatusCheck(hObject, handles);
    handles.saved_config_und = handles.und_pos';
    handles.saved_config_xmag = lcaGetSmart(handles.xmag_bdes);
    handles.saved_config_ymag = lcaGetSmart(handles.ymag_bdes);
else
    handles.kicked_mag = 33;
    handles.und_pos=ones(1,33);
    handles.saved_config_und = handles.und_pos';
end

temp16pos=handles.saved_config_und(16); handles.saved_config_und(16)=handles.out_pos;    % don't count und16
first_und = find(handles.saved_config_und < handles.in_pos,1,'first');
last_und = find(handles.saved_config_und < handles.in_pos,1,'last');
handles.saved_config_und(16)=temp16pos;
first_good_und=str2double(get(handles.LOOPBEG,'String'));   % read in first undulator from GUI fig
set(handles.LOOPBEG,'String',num2str(max(first_und,first_good_und)));
set(handles.LOOPEND,'String',num2str(last_und));

set(handles.CUTOFFLOW,'String',num2str(first_und));
set(handles.CUTOFFHIGH,'String',num2str(last_und));

% GUI colors
handles.start_col = [187 255 119]/255;

% Default to RMS
set(handles.PROFMON_METHOD,'Value',4);

% last position to be used for fitting orbit.  (registry remembers from
% last fit)
handles.last = 0;

% =1 if used load data button
handles.saved_data = 1;
handles.file_name = [];


% if offline
if ~handles.online
  handles.min_charge = 10^-1;
  handles.in_pos = 1;
  handles.out_pos = 3;
  handles.out_enough = 2.5;
  handles.move_in_wait = 3;

  handles.saved_config_xmag = zeros(33,1);
  handles.saved_config_ymag = zeros(33,1);
end

if ~handles.online
    handles.yag_tag=0;
end

if handles.yag_tag
  set(handles.DETECTOR,'Value',1)
  set(handles.SPONTBG,'Value',1);
end


handles.methods = get(handles.MEASMETHOD,'String');
handles.currmethod = get(handles.MEASMETHOD,'Value');

handles.llnl_nightmare=0;     % set to 1 to engage nightmare of llnl DI software


% variables for gas detector
% FINISH FINISH FINISH
handles.last_gdet1_power=1;     % last measured power in mJ
handles.gdet_cutoff_power=5e-2; % power cutoff in mJ to when signal considered low
handles.gdet_data1_1_pv = 'DIAG:FEE1:202:241:Data';       % pv for data from gdet1, PMT1
handles.gdet_data1_2_pv = 'DIAG:FEE1:202:242:Data';       % pv for data from gdet1, PMT2
handles.gdet_data2_1_pv = 'DIAG:FEE1:202:361:Data';       % pv for data from gdet2, PMT1
handles.gdet_data2_2_pv = 'DIAG:FEE1:202:362:Data';       % pv for data from gdet2, PMT2
handles.gain_gdet2_1_pv = 'HVCH:FEE1:361:VoltageSet';     % pv for gain of gdet2, PMT1
handles.gain_gdet2_2_pv = 'HVCH:FEE1:362:VoltageSet';     % pv for gain of gdet2, PMT2
handles.gain_gdet2_1_status = 'HVCH:FEE1:361:STATUS';      % status for gain of gdet2
handles.gain_gdet2_2_status = 'HVCH:FEE1:362:STATUS';      % status for gain of gdet2
handles.pressure_gdet2_high_pv = 'VFC:FEE1:E207:P_DES_RB'; % pv for pressure of gdet2, high recipe
handles.pressure_gdet2_low_pv = 'VFC:FEE1:E207:P_DES_RB'; % pv for pressure of gdet2, low recipe
handles.pressure_gdet2_recipe_pv='VFC:FEE1:E207:RECIPE';      % status of gdet2 recipe
handles.pressure_gdet2_status = 'VFC:FEE1:E207:PSTAT';        % status of gdet2 gas (0 if at setpoint)
handles.gain_mult = str2double(get(handles.GDET2_GAINMULT,'String'));   % multiplier for gain when signal low
handles.pressure_mult = str2double(get(handles.GDET2_PRESSMULT,'String'));   % multiplier for pressure when signal low
handles.gain_max = 1840;   % maximum gain in V for Gdet2
handles.pressure_max = 2;   % maximum pressure in T for Gdet2
handles.need_gdet2_cal = 1;     % flag for gdet2 calibration: recalibrate whenever gdet settings change
handles.need_gdet1_offset = 1;  % flag for getting gdet 1 offset
handles.need_gdet2_offset = 1;  % flag for getting gdet 2 offset: retake after changes to gdet2
handles.gdet1_offset = [0 0];   % initialize offsets
handles.gdet2_offset = [0 0];   % initialize offsets
handles.gdet_good_data = 1.5e4;    % gdet data should be less than 1e4 to be considered good

handles.kick_fudge = 1.3;   % fudge even correctors to be smaller to account for beta function

handles.gdet2_set = 'initial_gain';  % flag that gdet is at initial setting and can still be changed

handles.take_BSA = 0;           % default is now NO BSA data.  Can turn on with checkbox.

handles.use_atten=0; % turn off attenuator control for yagxray and direct imager

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes GainLengthGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% %%
% % --- Executes when user attempts to close GainLengthGUI.
% function GainLengthGUI_CloseRequestFcn(hObject, eventdata, handles)
%
% %util_appClose(hObject);
% % Put below into properties of GUI fig file
% GainLengthGUI('GainLengthGUI_CloseRequestFcn',gcbf,[],guidata(gcbf))


%%
% --- Outputs from this function are returned to the command line.
function varargout = GainLengthGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%%
% --- Executes on button press in STARTMEAS.
function STARTMEAS_Callback(hObject, eventdata, handles)
% hObject    handle to STARTMEAS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tic

set(handles.STARTMEAS,'String','Abort');
set(hObject,'BackgroundColor',[1 1 0]);


% If abort called end program
handles.abort = get(hObject,'Value');
if handles.abort == 0
    return;
else
    disp('Startup')
end

handles.fail = 0;

set(handles.STATUS,'String','Starting measurement');
drawnow

% Clear data
if ~isempty(handles.data)
  handles = ClearData(handles);
end
guidata(hObject, handles);
handles=ClearPlot(handles);
drawnow

% Check beam parameters before operating
if handles.yag_tag
    handles.use_atten=1;
else
    handles.use_atten=0;
end

% get current energy
if handles.online
  handles.nom_e = lcaGetSmart(handles.energy_pvs);
else
  handles.nom_e = handles.max_e;
end

first_und = str2num(get(handles.LOOPBEG,'String'));
last_und = str2num(get(handles.LOOPEND,'String'));
%n_steps = str2num(get(handles.UNDSTEPS,'String'));
n_steps=1;      % now hard coded in to step 1 undulator at a time.
kick_size = str2num(get(handles.MAGDIST,'String'))*handles.orbit_to_kick;  % convert orbit distortion to mag strength
if abs(kick_size)>handles.max_kick
  handles.fail = 1;
  set(handles.STATUS,'String',['Error: kick size must be smaller than ' ...
      num2str(handles.max_kick/handles.orbit_to_kick) 'um']); drawnow;
  questdlg(['Kick size (' num2str(kick_size) ') is too large. Setting kick to -' ...
      num2str(handles.max_kick) ' and aborting'] ...
      ,'Kick Amplitude','OK','OK');
  kick_size = -handles.max_kick;
elseif abs(kick_size) < handles.mag_diff
  questdlg(['Kick size (' num2str(kick_size) ') is too small. Setting kick to -' ...
      num2str(handles.mag_diff) ' and aborting'] ...
      ,'Kick Amplitude','OK','OK');
  handles.fail = 1;
  kick_size = -handles.mag_diff;
end

% force negative kick so that 'restore' automatically standardizes magnet
kick_size = -abs(kick_size);

handles = UndStatusCheck(hObject,handles);
handles.start_config_und = handles.und_pos';   % save starting position of undulators
start_status = handles.und_status;

% Check that all undulators in range already inserted
if sum(start_status(first_und:last_und)) < last_und-first_und+1;
  set(handles.STATUS,'String','Error: all undulators in range must be inserted');   drawnow;
  %handles.fail = 1;
end

if first_und<=last_und
  up_temp = last_und:-n_steps:first_und;
  und_pos = up_temp(end):n_steps:last_und;
  n_points = length(und_pos);
else
  set(handles.STATUS,'String','Error: invalid Undulator Range');   drawnow;
  handles.fail = 1;
end


handles = TakeReference(hObject,eventdata,handles);

handles.methods = get(handles.MEASMETHOD,'String');
handles.currmethod = get(handles.MEASMETHOD,'Value');


if handles.online
  % Initial status of und feedback
  feedback_status = lcaGetSmart(handles.feedback,0,'double');

  % Initial camera filter status
  OD_init = lcaGetSmart(handles.OD_pvs,1,'double');
  di_OD_init = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');
  attens_init = lcaGetSmart(handles.atten_control_pvs{3});
  dirimg_filter_status = di_OD_init;

  % Wait if BYKick on
  while (~lcaGet(handles.BYKick,1,'double'))
      set(handles.STATUS,'String','BYKick on, Waiting for beam in Undulators');
      drawnow
      handles.abort = get(hObject,'Value');
      if handles.abort == 0
          disp('User abort');
          set(handles.STATUS,'String','Aborting');  drawnow;
          handles.fail=1;
          break;
      end
      pause(1);
  end
else
  % Initial status of und feedback
  feedback_status = 1;

  % Initial camera filter status
  OD_init = [1 1];
  di_OD_init = [1 1];
  attens_init = .1;
  dirimg_filter_status = di_OD_init;
end
handles.OD_init=OD_init;

% Check that E-loss Calibration is up to date
last_ipk = lcaGetSmart(handles.eloss_last_ipk_pv);
curr_ipk = lcaGetSmart(handles.eloss_ipk_setpnt_pv);
% if abs(last_ipk-curr_ipk)>0.1*last_ipk
%   last_ipk = questdlg(['Last E-loss calibration was at ' num2str(last_ipk)...
%       'A. Current set point is ' num2str(curr_ipk) 'A. Recalibrating '...
%       'the E-loss GUI will improve jitter of E-loss measurements. '...
%       'Press continue to ignore warning, or press abort if you would like to '...
%       'recalibrate using the E-loss GUI.']...
%       ,'E-loss Calibration','Bravely Continue','Heroically Abort to Calibrate'...
%       ,'Bravely Continue');
% end
if strcmp(last_ipk,'Heroically Abort to Calibrate')
  handles.fail = 1;
  set(handles.STATUS,'String','Ready'); drawnow;
end


% Request new calibrations
handles.need_gdet2_cal = 1;     % flag for gdet2 calibration: recalibrate whenever gdet settings change
handles.need_gdet1_offset = 1;  % flag for getting gdet 1 offset
handles.need_gdet2_offset = 1;  % flag for getting gdet 2 offset: retake after changes to gdet2
handles.last_gdet1_power=1;     % initialize last gdet power to 1mJ
handles.gdet2_set = 'initial_gain';   % assume starting with initial gdet gain
handles.gain_mult = str2double(get(handles.GDET2_GAINMULT,'String'));   % multiplier for gain when signal low
handles.pressure_mult = str2double(get(handles.GDET2_PRESSMULT,'String'));   % multiplier for pressure when signal low


% Make sure YAGXRAY camera ROI isn't too large
opts.nBG=0;opts.bufd=1;
opts.doProcess=0;
%opts.doPlot=get(handles.SHOWIMG,'Value');
opts.doPlot=1;
if handles.yag_tag
  dat=profmon_measure(handles.xray_profmon,1,opts);
  roi = size(dat.img);
  if handles.nom_e > 10
      rec_roi = handles.rec_roi;
  else
      rec_roi = handles.rec_roi*10;
  end
  if roi(1)*roi(2) > rec_roi
      camera_roi = questdlg(['Camera ROI (' num2str(roi(1)) 'x' num2str(roi(2)) ...
          ') is above recommended limit.  Selecting smaller ROI speeds measurements on YAGXRAY.']...
          ,'YAGXRAY Camera ROI','Continue','Abort','Continue');
  else
      camera_roi = 'fine';
  end

  if strcmp(camera_roi,'Abort')
      handles.fail = 1;
      set(handles.STATUS,'String','Ready'); drawnow;
  end
elseif handles.llnl_nightmare  && handles.online
  init_nfov_process = lcaGetSmart(handles.nfov_process,1,'double');
  lcaPutSmart(handles.nfov_process,1)
end


% use xpp spectrometer (for self seeding)
acq_types = get(handles.ACQ_METHOD,'String');
curr_type = get(handles.ACQ_METHOD,'Value');
handles.acq_method = acq_types(curr_type);


% turn off HXRSS feedback
handles.HXRSS_feedback_status = lcaGetSmart(handles.HXRSS_feedback,1,'Double');
lcaPutSmart(handles.HXRSS_feedback,0);

% record initial gain and pressure for gdet2
handles.pressure_gdet2_recipe = lcaGetSmart(handles.pressure_gdet2_recipe_pv);  % choose pressure PV based on recipe
if handles.pressure_gdet2_recipe == 3
    handles.pressure_gdet2_pv=handles.pressure_gdet2_high_pv;
else
    handles.pressure_gdet2_pv=handles.pressure_gdet2_low_pv;
end
init_gain_gdet2_1=lcaGetSmart(handles.gain_gdet2_1_pv);     % initial value for gdet2 gain, PMT1
init_gain_gdet2_2=lcaGetSmart(handles.gain_gdet2_2_pv);     % initial value for gdet2 gain, PMT2
init_pressure_gdet2=lcaGetSmart(handles.pressure_gdet2_pv);

% check if GDet has sufficient signal
if ~handles.yag_tag
    handles=GDET_signal(handles);
end

% reserve event data variable
if handles.take_BSA
    handles.eDefNumber = eDefReserve('GainLengthGUI');
    if ~isfield(handles,'eDefNumber')
        handles.fail=1;
        set(handles.STATUS,'String','No eDefNumber available. Aborting.'); drawnow;
    end
end

% initialize variables for Henrik's closed undulator orbit function
r_cu=[]; s_cu=[]; handles.r_cu=r_cu; handles.s_cu=s_cu;
kick_plane=handles.kick_plane;

if handles.fail
    % done
else
    if strcmp(handles.methods(handles.currmethod),'Move Undulators')
      % UNDULATOR CASE
      % Save current undulator status
      handles = UndStatusCheck(hObject, handles);
      handles.saved_config_und = handles.und_pos';
    end

    % Load magnet names
    mag_names_x = handles.xmag_names;
    mag_names_y = handles.ymag_names;
    mag_bdes_x = handles.xmag_bdes;
    mag_bdes_y = handles.ymag_bdes;
    if strcmp(handles.methods(handles.currmethod),'Move Y Corr')
        % Y magnets
        mag_names = handles.ymag_names;
        mag_bdes  = handles.ymag_bdes;
        mag_names2 = handles.ymag_names;  % if using 2 kicks
        mag_bdes2  = handles.ymag_bdes;
    else
        % X magnets for X Corr and for measuring spontaneous in
        % Undulator case
        mag_names = handles.xmag_names;
        mag_bdes  = handles.xmag_bdes;
        mag_names2 = handles.xmag_names;
        mag_bdes2  = handles.xmag_bdes;
    end

    % Define current magnet positions as undisturbed orbit
    if handles.online
      handles.saved_config_xmag = lcaGetSmart(handles.xmag_bdes);
      handles.saved_config_ymag = lcaGetSmart(handles.ymag_bdes);
    end



    % identify first magnet (used for supressing FEL in spontaneous
    % background function in all move methods)
    handles.firstmag = mag_names(1);
    first_mag_bdes = mag_bdes(1);
    if handles.online
      handles.firstmag_start_pos = lcaGetSmart(first_mag_bdes);
    else
      handles.firstmag_start_pos = 0;
    end
    handles.firstmag_kick = kick_size;



    % Check filters and attenuators
    if handles.online && handles.use_atten
      temp = lcaGetSmart(handles.OD_pvs,1,'double');
      attens_status = lcaGetSmart(handles.attens_status_pvs,1,'Double');
    else
      temp = [1 1];
      attens_status = [1 1];
    end
    filter_status = temp(1) + 2*temp(2);      % number of filters in (double counting OD2)

    toc
    disp('starting loop')

    % Take data for n_points  (START OF LOOP)
    for j=1:n_points

        % If abort called end program
        handles.abort = get(hObject,'Value');
        if handles.abort == 0
            handles = abort_loop(handles);
            break;
        end

        j
        tic

        curr_pos = und_pos(end-j+1);
        handles.curr_pos=curr_pos;
          % turn off und_launch feedback for first 10 unds
        if curr_pos < 10 && handles.online
          lcaPutSmart(handles.feedback,0);
        end



        if strcmp(handles.methods(handles.currmethod),'Move Undulators')
          % UNDULATOR CASE
          % Undulator method is ready
        else
          % MAGNET CASE

          % Move corrector after last und
          curr_mag = mag_names(curr_pos);
          curr_mag_bdes = mag_bdes(curr_pos);
          curr_mag_x = mag_names_x(curr_pos);
          curr_mag_y = mag_names_y(curr_pos);
          curr_mag_bdes_x = mag_bdes_x(curr_pos);
          curr_mag_bdes_y = mag_bdes_y(curr_pos);



          % wait for a bit more than a pi/2 phase advance, then kick again
          % adjust number of undulators for energy dependence of beta func
          mag_delay = round(handles.phase_advance*handles.nom_e/handles.max_e);
          handles.mag_delay=mag_delay;

          % check if second kick will be before last undulator
          if curr_pos < handles.und_num-mag_delay
            curr_pos2 = curr_pos + mag_delay;
          else
            curr_pos2 = handles.und_num;
          end
          curr_mag2 = mag_names(curr_pos2);
          curr_mag_bdes2 = mag_bdes2(curr_pos2);

          % initial values of magnets
          if handles.online
            start_pos = lcaGetSmart(curr_mag_bdes);
            start_pos_x = lcaGetSmart(curr_mag_bdes_x);
            start_pos_y = lcaGetSmart(curr_mag_bdes_y);
            start_pos2 = lcaGetSmart(curr_mag_bdes2);
          else
            start_pos = 1;
            start_pos_x=1; start_pos_y=1;
            start_pos2=1;
          end
          set(handles.STATUS,'String',['Moving corrector for position: ' num2str(j)]);
          drawnow

          % make even corrector kick smaller to account for beta function
          if mod(curr_pos/2,1) == 0
              new_pos = kick_size/handles.kick_fudge;
          else
              new_pos = kick_size;
          end

          % save values to handles
          handles.curr_mag=curr_mag; handles.curr_mag2=curr_mag2;
          handles.start_pos=start_pos; handles.start_pos2=start_pos2;
          handles.curr_mag_x=curr_mag_x; handles.curr_mag_y=curr_mag_y;


          % FINISH FINISH FINISH
          % check if starting corrector position is already large
          if abs(new_pos-start_pos) < 0.9*abs(new_pos)
              new_pos=start_pos-new_pos;
%               if kick_size > 0
%                 new_pos=start_pos-kick_size;
%               else
%                 new_pos=-start_pos+kick_size;
%               end
          end

          % move multiple magnets to suppress low energy FEL or just one
          % magnet for high energy FEL (now using 2 for both)
          % FINISH FINISH FINISH
          if curr_pos < handles.und_num-mag_delay && handles.nom_e/handles.max_e < handles.low_energy && handles.online
            MoveMag(handles,[curr_mag curr_mag2],[new_pos new_pos],'perturb');
          elseif handles.closed_orbit && curr_pos<=handles.last_closed_corr && handles.nom_e<handles.max_E_closed


            % FINISH FINISH FINISH
            % calculate change
            [mymags,mag_coeffs,r_cu,s_cu]=control_undCloseOsc_fast(curr_mag_x,kick_size,handles.kick_plane,handles.r_cu,handles.s_cu);
            handles.r_cu=r_cu; handles.s_cu=s_cu;
            mags_to_change_x=mag_names_x(mymags);
            mags_to_change_y=mag_names_y(mymags);
            mags_to_change_bdes_x=mag_bdes_x(mymags);
            mags_to_change_bdes_y=mag_bdes_y(mymags);
            mag_coeffs_x=mag_coeffs(:,1);
            mag_coeffs_y=mag_coeffs(:,2);

            % make sure kicks aren't above max allowed value
            if any(abs(mag_coeffs_x) > abs(kick_size))
                mag_coeffs_x = mag_coeffs_x*kick_size/max(abs(mag_coeffs_x));
            end
            if any(abs(mag_coeffs_y) > abs(kick_size))
                mag_coeffs_y = mag_coeffs_y*kick_size/max(abs(mag_coeffs_y));
            end

            % record starting values
            ref_mag_coeffs_x = lcaGetSmart(mags_to_change_bdes_x);
            ref_mag_coeffs_y = lcaGetSmart(mags_to_change_bdes_y);

            % move magnets
            MoveMag(handles,mags_to_change_x,mag_coeffs_x,'perturb');
            MoveMag(handles,mags_to_change_y,mag_coeffs_y,'perturb');

          else
            MoveMag(handles,curr_mag,new_pos,'perturb');
          end
          handles.kicked_mag = und_pos(end-j+1);
        end

        % Turn on beam (turned off in previous loop to protect camera)
        % FINISH FINISH FINISH
        if j > 1 && handles.online
          lcaPut(handles.BYKick,1);
        end

        % wait for magnets and BYKick to finish moving
        pause(.5);

        toc
        tic

        % increase gain/pressure of gdet2
        if handles.last_gdet1_power<handles.gdet_cutoff_power && strcmp(handles.gdet2_set,'initial_gain');
            set(handles.STATUS,'String','Changing Gas Detector Settings'); drawnow;
            handles = ChangeGDET(hObject, eventdata, handles);
            handles.gdet2_set = 'high_gain';
            %handles = ScrambleUnd(hObject, eventdata, handles, curr_pos+1,last_und);
        end



        % Check for beam again
        if handles.online
          check_beam = lcaGetSmart(handles.event_tmit_pvs{end});
          while ~isfinite(check_beam) || check_beam < handles.min_charge
            set(handles.STATUS,'String','waiting for BYKick'); drawnow;
            disp('No Charge: waiting for beam');
            pause(1)
            check_beam = lcaGetSmart(handles.event_tmit_pvs{end});

            % If abort called end program
            handles.abort = get(hObject,'Value');
            if handles.abort == 0
              break;
            end
          end
        end



        % If abort called end program
        handles.abort = get(hObject,'Value');
        if handles.abort == 0
            handles = abort_loop(handles);
            break;

        end


        toc
        tic

        disp('Taking Data')

        % TAKE DATA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        set(handles.STATUS,'String','Taking data'); drawnow;
        handles = TakeData(hObject, eventdata, handles);


        toc

        disp('Taking Data')

        tic

        % Insert filter for yagxray if necessary
        while(handles.yagcam_sat ~= 0) && handles.abort~=0  && handles.use_atten
          inserted = OD_filter(handles);
          if inserted ~= filter_status
            set(handles.STATUS,'String','Retaking data'); drawnow;
            handles = TakeData(hObject, eventdata, handles);                  % retake data
          else
            break
          end
          filter_status = inserted;
          handles.abort = get(hObject,'Value');
        end

        if strcmp(handles.acq_method,'YAGXRAY/DIR_IMG') && handles.use_atten
            % Insert attenuator for direct imager YAG if necessary
            while handles.dirimg_sat == 1 || ((handles.dirimg_sat == -1) && any(attens_status==1)) && handles.abort~=0
              inserted = Move_Attens(handles);
              if any(inserted ~= attens_status)
                set(handles.STATUS,'String','Retaking data'); drawnow;
                handles = TakeData(hObject, eventdata, handles);                  % retake data
              else
                break
              end
              attens_status = inserted;
              handles.abort = get(hObject,'Value');
            end

            % Insert filters for direct imager cameras if necessary
    %        while(handles.ncam_dirimg_sat ~= 0 || handles.wcam_dirimg_sat ~= 0)
            while(handles.ncam_dirimg_sat ~= 0) && handles.abort~=0
              inserted = Move_DirImg_Filters(handles);
              if any(inserted ~= dirimg_filter_status)
                set(handles.STATUS,'String','Retaking data'); drawnow;
                handles = TakeData(hObject, eventdata, handles);                  % retake data
              else
                break;
              end
              dirimg_filter_status = inserted;
              handles.abort = get(hObject,'Value');
            end

            % change filters and attens for next round if getting low (unless filters already at minimum)
            if handles.abort~=0
              if handles.ncam_di_getting_low
                dirimg_filter_status = Rotate_di_filters(handles,'near','ccw');
              end
              if handles.wcam_di_getting_low
                dirimg_filter_status = Rotate_di_filters(handles,'wide','ccw');
              end
              if handles.diyag_getting_low && any(attens_status==1)
                attens_status = Move_Attens(handles);
              end
              if handles.yag_getting_low
                filter_status = OD_filter(handles);
              end
            end
        end

        % Clear plot, guess best undulator range for gain length fit, analyze data and re-plot measured data
        handles=ClearPlot(handles);
        handles = AnalyzeMeas(hObject,  eventdata, handles);
        GuessGLRange(handles);
        handles = AnalyzeMeas(hObject,  eventdata, handles);
        drawnow


        % If abort called end program
        handles.abort = get(hObject,'Value');
        if handles.abort == 0
            handles = abort_loop(handles);

            % reset magnets
            if curr_pos < handles.und_num-mag_delay && handles.nom_e/handles.max_e < handles.low_energy
                MoveMag(handles,[curr_mag curr_mag2],[start_pos start_pos2],'trim');
            elseif handles.closed_orbit && curr_pos<=handles.last_closed_corr && handles.nom_e<handles.max_E_closed
                MoveMag(handles,mags_to_change_x,ref_mag_coeffs_x,'trim');
                MoveMag(handles,mags_to_change_y,ref_mag_coeffs_y,'trim');
            end
            break;
        end


        % Move undulators/magnets to set up next data point
        if strcmp(handles.methods(handles.currmethod),'Move Undulators')
          %UNDULATOR CASE
          % remove jth undulator
          set(handles.STATUS,'String',['Moving undulator #',num2str(j)]); drawnow;

          if j < n_points && handles.online
            % Desired undulator positions
            handles = UndStatusCheck(hObject, handles);
            %und_des = handles.und_status;
            %und_des(und_pos(end-j)+1:und_pos(end)) = 0;

            % turn off beam
            lcaPut(handles.BYKick,0);

            % new position
            new_pos = segmentTranslate();
            new_pos(und_pos(end-j)+1:und_pos(end-j+1)) = handles.out_pos;
            segmentTranslate(new_pos);
            segmentTranslateWait_GL(hObject,handles);
          end

          % turn on beam again
          lcaPut(handles.BYKick,1); pause(handles.BYKick_pause)

        else
          % MAGNET CASE

          % Turn off beam until next magnet into position (to protect camera -- ignore for gdet)
          if ~strcmp(handles.acq_method,'Gas Detectors')
            if j < n_points && handles.online
                lcaPut(handles.BYKick,0);       % turn off beam
              elseif handles.online && handles.use_atten
                reset_filters(handles,OD_init,di_OD_init,attens_init)
                pause(1);
            end
          end

          % Move magnet back to starting position
          set(handles.STATUS,'String',['Restoring corrector for position: ' num2str(j)]); drawnow;



          % FINISH FINISH FINISH (turned off for now)
          if curr_pos < handles.und_num-mag_delay && handles.nom_e/handles.max_e < handles.low_energy
              MoveMag(handles,[curr_mag curr_mag2],[start_pos start_pos2],'trim');


          elseif handles.closed_orbit && curr_pos<=handles.last_closed_corr && handles.nom_e<handles.max_E_closed
              % x magnets
              MoveMag(handles,mags_to_change_x,ref_mag_coeffs_x,'trim');

              % y magnets
              MoveMag(handles,mags_to_change_y,ref_mag_coeffs_y,'trim');
          else
              MoveMag(handles,curr_mag,start_pos,'trim');
          end


        end


        guidata(hObject, handles);

        toc
    end

end

% release event data variable
if handles.take_BSA
    eDefRelease(handles.eDefNumber);
end

% Reset undulators for move undulator case
if ~handles.fail && strcmp(handles.methods(handles.currmethod),'Move Undulators')
  reset = questdlg('Reset undulators and filters to starting position?','Undulator Reset','Reset','Let be','Reset');
  if strcmp(reset,'Reset') && handles.online && handles.use_atten

    % reset filters to initial position
    reset_filters(handles,OD_init,di_OD_init,attens_init)
    handles = UndStatusCheck(hObject, handles);

    % turn off beam
    if handles.online
      lcaPut(handles.BYKick,0);
    end
    set(handles.STATUS,'String','Moving undulators'); drawnow;

    % Move undulators
    handles = get_in_pos(handles,und_pos(1),und_pos(end));
    new_pos = segmentTranslate();
    new_pos(und_pos(1):und_pos(end)) = handles.config_pos;
    segmentTranslate(new_pos);
    segmentTranslateWait_GL(hObject,handles);

    % turn on beam
    if handles.online
      lcaPut(handles.BYKick,1);
    end
  end
end



handles.kicked_mag = 0;


% Check undulator status
handles = UndStatusCheck(hObject, handles);



% restart feedback if feedback originally was on
if handles.online
  lcaPutSmart(handles.feedback,feedback_status);

  % reset HXRSS feedback
  % FINISH FINISH FINISH
  lcaPutSmart(handles.HXRSS_feedback,handles.HXRSS_feedback_status);
end


%reset gain/pressure of gdet2
%FINISH FINISH FINISH
if handles.gain_mult ~=1 || handles.pressure_mult ~= 1
    lcaPutSmart(handles.gain_gdet2_1_pv,init_gain_gdet2_1);
    lcaPutSmart(handles.gain_gdet2_2_pv,init_gain_gdet2_2);
    lcaPutSmart(handles.pressure_gdet2_pv,init_pressure_gdet2);
    gdet_count=0;
    while lcaGetSmart(handles.pressure_gdet2_status)~=0 || ~strcmp(lcaGetSmart(handles.gain_gdet2_1_status),'ON') || ~strcmp(lcaGetSmart(handles.gain_gdet2_2_status),'ON')
        pause(1);
        set(handles.STATUS,'String','Waiting for GDet2'); drawnow;
        gdet_count=gdet_count+1;    if gdet_count>20; break; end;
    end
end
handles.gdet2_set = 'initial_gain';

%reset undulator positions
%FINISH FINISH FINISH
%lcaPutSmart(handles.und_names(first_und:last_und),handles.saved_config_und(first_und:last_und));
segmentTranslate(handles.start_config_und');

%trim all correctors

% % reset processing to original condition
% if ~handles.yag_tag && handles.online
%   lcaPutSmart(handles.nfov_process,init_nfov_process)
% end

% Don't bother with analysis if abort called or failure found
if handles.abort == 0 || handles.fail
  set(handles.STARTMEAS,'String','Start');
  set(handles.STARTMEAS,'Value',0);
  set(hObject,'BackgroundColor',handles.start_col);
  if handles.fail == 0
    set(handles.STATUS,'String','Ready'); drawnow;
  end
  set(handles.STATUS,'String','Ready'); drawnow;
  return
end




% % Analyze and plot genesis data
% handles.gen_gl = AnalyzeGenesis(hObject,  eventdata, handles);



% Read and record Ming Xie gain length
MingXieGL(hObject, eventdata, handles);

%TAKE OUT (or add in)
% Write data to archives

handles = AnalyzeMeas(hObject,  eventdata, handles);
drawnow




% Update status
set(handles.STARTMEAS,'String','Start');
set(handles.STARTMEAS,'Value',0);
set(hObject,'BackgroundColor',handles.start_col);
set(handles.STATUS,'String','Ready'); drawnow;


% Check undulator status
handles = UndStatusCheck(hObject, handles);


guidata(hObject, handles);



%%
% --- Executes on button press in STARTGEN.
function STARTGEN_Callback(hObject, eventdata, handles)
% hObject    handle to STARTGEN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.STATUS,'String','Running Genesis');
drawnow

% Read and record Ming Xie gain length
MingXieGL(hObject, eventdata, handles);

% Read in current values from PV
handles = ReadFromGUI(hObject, eventdata, handles);

% Convert units for Genesis
M_e=5.11e-4;       % electron mass GeV
energyGamma = handles.energy/M_e*10^(-4);    % energy in units of gamma*10^4

% Update Genesis input file
task = 'input';
perl('GainLengthPerl.pl',task,handles.base_file,handles.input_file,...
    handles.output_file,handles.filename_file,num2str(handles.x_emit),...
    num2str(handles.y_emit),num2str(energyGamma),num2str(handles.curr),...
    num2str(handles.bl),num2str(handles.e_spread));


% Run Genesis in background
mycommand = ['genesis < ',handles.filename_file,' > ',handles.gen_result_file,' &'];
system(mycommand);


% Analyze and plot genesis data
handles.gen_gl = AnalyzeGenesis(hObject,  eventdata, handles);

AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;



%%
% --- Executes on button press in UPDATE_UNDSTAT.
function UPDATE_UNDSTAT_Callback(hObject, eventdata, handles)
% hObject    handle to UPDATE_UNDSTAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = UndStatusCheck(hObject, handles);


%%
% --- Executes on button press in TAKEDATA.
function TAKEDATA_Callback(hObject, eventdata, handles)
% hObject    handle to TAKEDATA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tic

handles.fail = 0;


set(handles.TAKEDATA,'String','Abort');
set(handles.TAKEDATA,'BackgroundColor',[1 1 0]);
drawnow

% If abort called end program
handles.abort = get(hObject,'Value');
if handles.abort == 0
  return;
end


set(handles.STATUS,'String','Taking Orbit Reference');
drawnow


handles = TakeReference(hObject,eventdata,handles);

set(handles.STATUS,'String','Taking Data');
drawnow

% start taking event data
if handles.take_BSA
    handles.eDefNumber = eDefReserve('GainLengthGUI');
    eDefParams(handles.eDefNumber,1,2800);
    eDefOn(handles.eDefNumber);
end

% TAKE DATA
if handles.fail == 0
  handles = TakeData(hObject, eventdata, handles);
end

guidata(hObject, handles);

UndStatusCheck(hObject, handles)

% analyze data and plot
handles = AnalyzeMeas(hObject, eventdata, handles);



handles.abort = get(hObject,'Value');
if handles.abort == 0 || handles.fail
        disp('User abort');
end

% Update status
set(handles.TAKEDATA,'String','Take Data');
set(handles.TAKEDATA,'Value',0);
set(handles.TAKEDATA,'BackgroundColor',handles.start_col);
set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);

toc


%%
function handles = TakeData(hObject, eventdata, handles)
% hObject    handle to TAKEDATA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% new data taken
handles.saved_data = 0;


handles = UndStatusCheck(hObject, handles);

% position of last undulator
und_end = find(handles.und_status==1,1,'last');
if isempty(und_end)
    und_end = 0.01;
end

% make even corrector kick smaller to account for beta function
mag_diff=handles.mag_diff*ones(1,handles.und_num);
for j=2:2:handles.und_num
    mag_diff(j)=mag_diff(j)/handles.kick_fudge;
end


% Check for kicked beam
if handles.online
  curr_xmag = lcaGetSmart(handles.xmag_bdes);
  curr_ymag = lcaGetSmart(handles.ymag_bdes);
else
  curr_xmag = handles.mag_diff+1;
  curr_ymag = handles.mag_diff+1;
end
xdiff = find(abs(handles.saved_config_xmag - curr_xmag) > mag_diff');
ydiff = find(abs(handles.saved_config_ymag - curr_ymag) > mag_diff');


% Assume gain ends after the first kick unless 'Move Undulators' selected
mag_end = handles.und_num;
if ~isempty(xdiff) || ~isempty(ydiff)
    if isempty(xdiff)
        mag_end = ydiff(1);
    elseif isempty(ydiff)
        mag_end = xdiff(1);
    else
        mag_end = min(xdiff(1),ydiff(1));
    end
end

methods = get(handles.MEASMETHOD,'String');
curr_method = get(handles.MEASMETHOD,'Value');
meas_method = methods(curr_method);
if strcmp(meas_method,'Move Undulators')
    und_end = und_end*handles.und_length;
else
    und_end = min(mag_end,und_end)*handles.und_length;
end
handles.und_end = und_end;


% For gdet case, measure offset with beam OFF
%FINISH FINISH FINISH
if strcmp(handles.acq_method,'Gas Detectors') && handles.online && (handles.need_gdet1_offset || handles.need_gdet2_offset)
    handles = MeasureGDetOffset(hObject,handles);
    handles.gdet1_offset=[0 0];         % for now forcing GDet1 offset to 0 so we always have one good data set if offset function fails
    %handles.gdet2_offset=[0 0];
end


% Read in data synchronously
[handles,outstruc] = GetSynchData(hObject,handles);

eloss_bpms_x = outstruc.x_eloss;
eloss_bpms_y = outstruc.y_eloss;
curr = outstruc.curr;


if handles.fail
    return;
end

% calculate energy loss in undulators
eloss_in.navg = handles.num_shots;                     % number of points to average
eloss_in.Loss_per_Ipk = handles.eloss_Loss_per_Ipk;


% check for initialization
if isfield(handles,'eloss_static')
  eloss_in.initialize = 0;
  eloss_in.static_data = handles.eloss_static;
else
  eloss_in.initialize = 1;
end


% initialize in case of failure
handles.eloss.dE = 0;
handles.eloss.ddE = 0;
handles.eloss.Ipk = 0;


% if online and BSA, calculate eloss
if handles.online && handles.take_BSA
  check_beam = lcaGetSmart(handles.event_tmit_pvs{end}); % check for beam

  n_shots = size(eloss_bpms_x);             % number of shots recorded synchronously
  for j=1:n_shots
    eloss_in.x = eloss_bpms_x(j,:);         % x bpms read synchronously
    eloss_in.y = eloss_bpms_y(j,:);         % y bpms read synchronously
    eloss_in.ipk = curr(j);                 % peak current read synchronously
    eloss = DL2toDumpEnergyLoss_GL(handles,eloss_in);
    raw_eloss(j) = eloss.dE;
    eloss_in.initialize = 0;                % no need for initialization now
    eloss_in.static_data = eloss.static_data;   % record static data explicitly
  end
  % Need to fix eloss so set to 0 FINISH FINISH FINISH
  handles.eloss_static = 0;
  %handles.eloss_static = eloss.static_data;
else
  raw_eloss = zeros(1,handles.num_shots);
end

% Need to fix eloss FINISH FINISH FINISH
raw_eloss = zeros(1,handles.num_shots);

% initialize handles.data if empty
if isempty(handles.data)
    data_pos = 0;
else
    data_pos = vertcat(handles.data.pos);
end
nval = length(data_pos);


% find correct position for new data point
if data_pos == 0
    myindex = 1;       % if first data point
elseif ~any(data_pos == und_end)
    myindex = nval+1;     % if new data point
else
    myindex = find(data_pos == und_end);   % if repeat data point
end

% FINISH FINISH FINISH
if handles.need_gdet2_cal
    handles.gdet2_cal=mean(outstruc.gdet1(:))/mean(outstruc.gdet2(:));
    handles.need_gdet2_cal=0;
end

% Update data registry
handles.data(myindex).pos = und_end;
handles.data(myindex).raw_yag = outstruc.yag_data;
handles.data(myindex).yag_tot_pix = outstruc.yag_tot_pix;
handles.data(myindex).di_raw_yag = outstruc.di_data;      % near direct imager data with henrik's profmon
handles.data(myindex).raw_eloss = raw_eloss;
handles.data(myindex).tmit = outstruc.tmit;
handles.data(myindex).delta_e = outstruc.delta_e;
handles.data(myindex).curr = outstruc.curr;
handles.data(myindex).xorb_max = outstruc.xorb_max;
handles.data(myindex).yorb_max = outstruc.yorb_max;
handles.data(myindex).raw_orbit = outstruc.orbit;
handles.data(myindex).OD = outstruc.OD;                  % Yagxray ODs
handles.data(myindex).di_OD = outstruc.di_OD;                  % direct imager ODs
handles.data(myindex).attens = outstruc.attens;          % attenuator
handles.data(myindex).n_dir_img = outstruc.n_dir_img;    % linda's near direct imager data
handles.data(myindex).w_dir_img = outstruc.w_dir_img;    % linda's wide direct imager data
handles.data(myindex).gdet1 = outstruc.gdet1;             % gas detector
handles.data(myindex).gdet2 = outstruc.gdet2;             % gas detector
handles.data(myindex).tot_energy = outstruc.tot_energy;   % total energy detector
handles.data(myindex).gdet2_cal = handles.gdet2_cal;       % calibration for gdet2 based on gdet1 (changes at different settings in run)
handles.data(myindex).kmono = outstruc.kmono;             % K-Mono


% set last power value to check if detector gdet2 gain/pressure should be increased
% FINISH FINISH FINISH
handles.last_gdet1_power=mean(outstruc.gdet1(:));

% Update energy, current, and laser heater and save to data structure
nom_e = lcaGetSmart(handles.energy_pvs);
curr_des = lcaGetSmart(handles.curr_set_pt_pvs);
lh_des = lcaGetSmart(handles.lh_energy_pvs);

handles.data(myindex).e_des = nom_e;            % desired energy dump
handles.data(myindex).curr_des = curr_des;      % desired current from set point
handles.data(myindex).lh_energy_des = lh_des;          % laser heater power

handles.most_recent = myindex;

if strcmp(handles.acq_method,'FEE Spectrometer') || strcmp(handles.acq_method,'XPP Spectrometer')
    handles.data(myindex).use_xpp_spec = 1;
else
    handles.data(myindex).use_xpp_spec = 0;
end

if strcmp(handles.acq_method,'SXR Spectrometer')
    handles.data(myindex).use_sxr_spec = 1;
else
    handles.data(myindex).use_sxr_spec = 0;
end

if strcmp(handles.acq_method,'Gas Detectors')
    handles.data(myindex).use_gdet = 1;
else
    handles.data(myindex).use_gdet = 0;
end

if strcmp(handles.acq_method,'K-Mono')
    handles.data(myindex).use_kmono = 1;
else
    handles.data(myindex).use_kmono = 0;
end


guidata(hObject, handles);


% Inserts OD filters if necessary
function inserted = OD_filter(handles)

if ~handles.online
  inserted=[1 1];
  return
end

OD_init = lcaGetSmart(handles.OD_pvs,1,'double');


if handles.yagcam_sat == 1
  if ~OD_init(1)
    lcaPutSmart(handles.OD_pvs(1),1);             % if no OD1, put in OD1
  elseif ~OD_init(2)
    lcaPutSmart(handles.OD_pvs(2),1);             % if just OD1, put in OD2, take out OD1
    lcaPutSmart(handles.OD_pvs(1),0);
  end
elseif handles.yagcam_sat == -1
  if OD_init(1)
    lcaPutSmart(handles.OD_pvs(1),0);             % if OD1 in, take out OD1
  elseif OD_init(2)
    lcaPutSmart(handles.OD_pvs(1),1);           % if just OD2, take out OD2, put in OD1
    lcaPutSmart(handles.OD_pvs(2),0);
  end
end

temp = lcaGetSmart(handles.OD_pvs,1,'double');
inserted = temp(1) + 2*temp(2);      % number of filters in (double counting OD2)



% Inserts Attenuators if necessary
function inserted = Move_Attens(handles)

if ~handles.online
  inserted=[1 1];
  return
end

% initial level of attenuation for solid (1) and gas (2) attenuators
attens_init = lcaGetSmart(handles.fee_atten_pvs,1,'double');

% desired attenuation change
atten_change = handles.di_change_atten;

if handles.dirimg_sat == -1
  new_atten =  attens_init(1)*atten_change;         % decrease attenuation
  if new_atten > 1
    new_atten = 1;
  end
  lcaPutSmart(handles.atten_control_pvs{1},new_atten);
  lcaPutSmart(handles.atten_control_pvs{2},3);
  %Rotate_di_filters(handles,'near','cw');
  %Rotate_di_filters(handles,'wide','cw');
elseif handles.dirimg_sat == 1                     % increase attenuation
  new_atten =  attens_init(1)/atten_change;
  lcaPutSmart(handles.atten_control_pvs{1},new_atten);
  lcaPutSmart(handles.atten_control_pvs{2},3);
  %Rotate_di_filters(handles,'near','ccw');
  %Rotate_di_filters(handles,'wide','ccw');
end


% wait for attenuators to move
if handles.dirimg_sat ~= 0
  pause(5)
end

inserted = lcaGetSmart(handles.attens_status_pvs,1,'Double');




% Inserts direct imager camera filters if necessary
function inserted = Move_DirImg_Filters(handles)

if ~handles.online
  inserted=[1 1];
  return
end

inserted = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');

if handles.ncam_dirimg_sat == 1
  inserted = Rotate_di_filters(handles,'near','cw');
elseif handles.ncam_dirimg_sat == -1
  if inserted(1) == 0
    return
  end
  inserted = Rotate_di_filters(handles,'near','ccw');
end

if handles.wcam_dirimg_sat == 1
  inserted = Rotate_di_filters(handles,'wide','cw');
elseif handles.wcam_dirimg_sat == -1
  if inserted(2) == 0
    return
  end
  inserted = Rotate_di_filters(handles,'wide','ccw');
end




% Rotates filter wheel for direct imager cameras
function inserted = Rotate_di_filters(handles,camera,direction)

% initial condition
filters_init = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');

% order of pvs
near=1;
wide=2;

if strcmp(camera,'near')
  if strcmp(direction,'cw')
    if filters_init(near) < 4                  % don't Rotate if at end
%      lcaPutSmart(handles.di_cw_pvs(near),1);
      lcaPutSmart(handles.ndi_pos_pvs(filters_init(near)+1+1),1)
    end
  else
    if filters_init(near) ~= 0 && filters_init(near) < 5                 % don't Rotate if at begining
%      lcaPutSmart(handles.di_ccw_pvs(near));
      lcaPutSmart(handles.ndi_pos_pvs(filters_init(near)+1-1),1)
    end
  end
else
%   if strcmp(direction,'cw')
%     if filters_init(wide) < 5
% %      lcaPutSmart(handles.di_cw_pvs(wide));
%       lcaPutSmart(handles.wdi_pos_pvs(filters_init(wide)+1+1),1)
%     end
%   else
%     if filters_init(wide) ~= 0 && filters_init(wide) < 6
% %      lcaPutSmart(handles.di_ccw_pvs(wide));
%       lcaPutSmart(handles.wdi_pos_pvs(filters_init(wide)+1-1),1)
%     end
%   end
end

% wait for filter to move
inserted = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');
while any(inserted==8) || any(isnan(inserted))
  pause(1)
  set(handles.STATUS,'String','Waiting for Dir Img Filter'); drawnow;
  inserted = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');
end


%%
% --- Executes on button press in PLOTDATA.
function PLOTDATA_Callback(hObject, eventdata, handles)
% hObject    handle to PLOTDATA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%guidata(hObject, handles);

% Analyze and plot data
handles = AnalyzeMeas(hObject,  eventdata, handles);


MingXieGL(hObject, eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);



%%
% --- Executes on button press in CLEARDATA.
function CLEARDATA_Callback(hObject, eventdata, handles)
% hObject    handle to CLEARDATA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = ClearData(handles);
guidata(hObject, handles);

function handles = ClearData(handles)
% Clear data and re-initialize data structure


if ~handles.saved_data
  clear = questdlg('Clear data? Data will not be saved.','Clear data','Clear Data','Keep Data','Keep Data');
else
  clear = questdlg('Clear data?','Clear data','Clear Data','Keep Data','Keep Data');
end

if strcmp(clear,'Clear Data')
  handles.data = [];
  handles.pxl_roi=[];
  handles=ClearPlot(handles);
  handles.need_gdet1_offset = 1;
  handles.need_gdet2_offset = 1;
  handles.need_gdet2_cal = 1;
end








% --- Executes on button press in CLEARPLOT.
function CLEARPLOT_Callback(hObject, eventdata, handles)
% hObject    handle to CLEARPLOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=ClearPlot(handles);


function handles=ClearPlot(handles)
% Clear Plot
hold(handles.GLAX,'off');
a = [0 0];
semilogy(a(1),a(2),'w','Parent',handles.GLAX);


%%
% --- Executes on button press in MOVEMAG.
function MOVEMAG_Callback(hObject, eventdata, handles)
% hObject    handle to MOVEMAG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.online
  return
end

% kick_size = str2num(get(handles.MAGDIST,'String'))*handles.orbit_to_kick*(handles.nom_e/handles.max_e);
kick_size = str2num(get(handles.MAGDIST,'String'))*handles.orbit_to_kick;
last_und = str2num(get(handles.LASTUND,'String'));
mag_options = get(handles.MAGTYPE,'String');
type = get(handles.MAGTYPE,'Value');
mag_type = mag_options(type);



if strcmp(mag_type,'X Corr')
    mag_name = handles.xmag_names(last_und);
    kick_size = kick_size + handles.saved_config_xmag(last_und);
else
    mag_name = handles.ymag_names(last_und);
    kick_size = kick_size + handles.saved_config_ymag(last_und);
end

if kick_size>handles.max_kick
  set(handles.STATUS,'String',['Error: kick size must be smaller than ' ...
    num2str(handles.max_kick/handles.orbit_to_kick) 'um']);   drawnow;
  return
end

% if kick_size>handles.max_kick/(handles.max_e/handles.nom_e)
%   set(handles.STATUS,'String',['Error: kick size must be smaller than ' ...
%     num2str(handles.max_kick/(handles.max_e/handles.nom_e)/handles.orbit_to_kick) 'um']);
%   return
% end

set(handles.STATUS,'String','Changing Corrector: Please Wait'); drawnow;

% turn off HXRSS feedback
% FINISH FINISH FINISH
handles.HXRSS_feedback_status = lcaGetSmart(handles.HXRSS_feedback,1,'Double');
lcaPutSmart(handles.HXRSS_feedback,0);

MoveMag(handles,mag_name,kick_size,'trim');

handles = find_kicked_mag(handles);

handles = UndStatusCheck(hObject, handles);


set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);


%%
% Move magnet
function MoveMag(handles,curr_mag,mag_strength,accuracy)
% Change corrector values

% number of magnets to move
n = length(curr_mag);

% First perturb
for j=1:n
  % TAKE OUT WHEN AIDA FIXED
  lcaPutSmart(strcat(curr_mag(j),':BCTRL'),mag_strength(j));
  %trim_magnet(curr_mag(j),mag_strength(j),'P');
end



% if kicking, perturb is sufficient
if strcmp(accuracy,'perturb')
    return;
end


return;

% check if magnet reached goal
for j=1:n
  [outoftol(j)] = check_magnet(curr_mag(j));
end

set(handles.STATUS,'String','Done perturbing magnet'); drawnow;

% if not at goal, trim
if any(outoftol)
  set(handles.STATUS,'String','Perturb failed, trying Trim'); drawnow;
  for j=1:n
    trim_magnet(curr_mag(j),mag_strength(j),'T');
  end
end

return;

% keep checking and trimming until succeeded
for j=1:n
  [outoftol(j)] = check_magnet(curr_mag(j));
end
while any(outoftol)
  pause(1)
  % If abort called end program
  handles.abort = get(handles.STARTMEAS,'Value');
  if handles.abort == 0
      set(handles.STATUS,'String','Aborting');
      drawnow
      return;
  end
  for j=1:n
    [outoftol(j)] = check_magnet(curr_mag(j));
  end
end


set(handles.STATUS,'String','Done moving magnet');
drawnow


function handles = find_kicked_mag(handles)

if ~handles.online
  return
end

% position of last undulator
und_end = find(handles.und_status==1,1,'last');
if isempty(und_end)
    und_end = 0.01;
end

% make even corrector kick smaller to account for beta function
mag_diff=handles.mag_diff*ones(1,handles.und_num);
for j=2:2:handles.und_num
    mag_diff(j)=mag_diff(j)/handles.kick_fudge;
end

% Check for kicked beam
curr_xmag = lcaGetSmart(handles.xmag_bdes);
curr_ymag = lcaGetSmart(handles.ymag_bdes);
xdiff = find(abs(handles.saved_config_xmag - curr_xmag) > mag_diff');
ydiff = find(abs(handles.saved_config_ymag - curr_ymag) > mag_diff');


% Assume gain ends after the first kick
mag_end = handles.und_num;
if ~isempty(xdiff) || ~isempty(ydiff)
    if isempty(xdiff)
        mag_end = ydiff(1);
    elseif isempty(ydiff)
        mag_end = xdiff(1);
    else
        mag_end = min(xdiff(1),ydiff(1));
    end
end

if mag_end < und_end
  handles.kicked_mag = mag_end;
else
  handles.kicked_mag = 0;
end



%%
% --- Executes on button press in MOVEUNDIN.
function MOVEUNDIN_Callback(hObject, eventdata, handles)
% hObject    handle to MOVEUNDIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.online
  return
end

handles.fail = 0;

% undulator range to move
first_und = str2num(get(handles.UNDBEG,'String'));
last_und = str2num(get(handles.UNDEND,'String'));


% if only one number, just move that undulator
if isempty(last_und)
    last_und = first_und;
end

% Desired undulator positions
handles = UndStatusCheck(hObject, handles);
% und_des = handles.und_status;
% und_des(first_und:last_und) = 1;

if first_und < 1 || last_und > handles.und_num || first_und > last_und
  set(handles.STATUS,'String','Invalid Undulator Range'); drawnow;
  return
end

% turn off beam
lcaPut(handles.BYKick,0);

set(handles.STATUS,'String','Moving undulators'); drawnow;

handles = get_in_pos(handles,first_und,last_und);
new_pos = segmentTranslate();
new_pos(first_und:last_und) = handles.config_pos;
segmentTranslate(new_pos);
segmentTranslateWait_GL(hObject,handles)

%handles = MoveUnd(hObject, eventdata, handles,first_und,last_und,'in');
%MovingUndCheck(hObject, handles, und_des);

% Wait an extra seconds when returning magnets to in position.
% (check only makes sure undulator is less than 6mm, not actually previous position)
% pause(handles.move_in_wait);

% turn on beam
lcaPut(handles.BYKick,1);

handles = UndStatusCheck(hObject, handles);

if ~handles.fail
  set(handles.STATUS,'String','Ready'); drawnow;
end


% --- Executes on button press in MOVEUNDOUT.
function MOVEUNDOUT_Callback(hObject, eventdata, handles)
% hObject    handle to MOVEUNDOUT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.online
  return
end

handles.fail = 0;

% undulator range to move
first_und = str2num(get(handles.UNDBEG,'String'));
last_und = str2num(get(handles.UNDEND,'String'));


% if only one number, just move that undulator
if isempty(last_und)
    last_und = first_und;
end


% Desired undulator positions
handles = UndStatusCheck(hObject, handles);
% und_des = handles.und_status;
% und_des(first_und:last_und) = 0;

% turn off beam
lcaPut(handles.BYKick,0);

set(handles.STATUS,'String','Moving undulators'); drawnow;

new_pos = segmentTranslate();
new_pos(first_und:last_und) = handles.out_pos;
segmentTranslate(new_pos);
segmentTranslateWait_GL(hObject,handles);

%handles = MoveUnd(hObject, eventdata, handles,first_und,last_und,'out');
%MovingUndCheck(hObject, handles, und_des);

% turn on beam
lcaPut(handles.BYKick,1);

handles = UndStatusCheck(hObject, handles);

set(handles.STATUS,'String','Ready'); drawnow;



function segmentTranslateWait_GL(hObject,handles)
%
% segmentTranslateWait_GL(segmentList)
%
% Waits until all segments in list have stopped translating
% If no arguments is given, it will wait for all segments to stop

segmentList = 1:33;

pause(1); % let the pvs update before checking
movingStatus = segmentTranslationStatus(segmentList);

while any(movingStatus)
    pause(1);
    handles = UndStatusCheck(hObject,handles);
    movingStatus = segmentTranslationStatus(segmentList);
    movingStatus(9)=0; movingStatus(16)=0; % fudge self-seeding girders to 0 (why 1 anyway?)
end



function handles = get_in_pos(handles,first_und,last_und)
% Gets desired in positions

config_pos = handles.saved_config_und(first_und:last_und)';

for j=1:length(config_pos)
  if config_pos(j) < 0
    config_pos(j) = 0;
  end
end

handles.config_pos = config_pos;

check_in = 0;
check_in = find(config_pos >= handles.out_enough);
if check_in > 0
    set(handles.STATUS,'String',['Error: Saved position for und ' num2str(first_und + check_in(1) - 1) ' not an IN position']); drawnow;
    handles.fail = 1;
    return
end

%%
% --- Executes on button press in MOVEUNDIN.
function handles = MoveUnd(hObject, eventdata, handles,first_und,last_und,in_or_out)
% hObject    handle to MOVEUNDIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.online
  return
end

if strcmp(in_or_out,'in')
    final_pos = handles.saved_config_und(first_und:last_und)';

    for j=1:length(final_pos)
      if final_pos(j) < 0
        final_pos(j) = 0;
      end
    end

    check_in = 0;
    check_in = find(final_pos >= handles.out_enough);
    if check_in > 0
        set(handles.STATUS,'String',['Error: Saved position for und ' num2str(first_und + check_in(1) - 1) ' not an IN position']); drawnow;
        handles.fail = 1;
        return
    end
elseif strcmp(in_or_out,'out')
    final_pos = handles.out_pos*ones(last_und-first_und+1,1);
end


 % check that range is valid
und_num = handles.und_num;
if (first_und < 1 || first_und > und_num) || (last_und < 1 || last_und > und_num) || (first_und > last_und)
        set(handles.UNDSTATUS,'String','Illegal undulator range');
        set(handles.UNDSTATUS,'ForegroundColor','r');
        return;
else
    set(handles.UNDSTATUS,'String','');
end



set(handles.STATUS,'String','Moving Undulators: Please Wait');
drawnow

lcaPutSmart(handles.und_names(first_und:last_und),final_pos);



guidata(hObject, handles);



%%
% ----------------------------------------
function MovingUndCheck(hObject, handles, und_des)
% Check if undulators are still moving

% TAKE OUT   need to get this working! possibly check against
% desired undulator position, instead of just movement?
% (replaced by Jim's program)


if handles.fail
  return
end
while(1)
  handles = UndStatusCheck(hObject, handles);
  % TAKE OUT (need to make the equals sign loose -- approximately equal is
  % fine)
  if handles.und_status == und_des
    break
  else
    pause(1)
  end
end



%%
% ----------------------------------------
function handles = AnalyzeMeas(hObject, eventdata, handles)
% Analyze measurement and write to GUI

guidata(hObject, handles);


if isempty(handles.data)
  return
end


% yag conversion factor (counts to J)
avg_charge = mean(vertcat(handles.data.tmit))/handles.nC_to_ne;
handles.yag_conv_norm = handles.yag_conv*avg_charge;
handles.yag_conv_norm = 1;

und_pos = vertcat(handles.data.pos);
num_points = length(und_pos);

avg_power = zeros(1,num_points);
peak_power = zeros(1,num_points);
rms_power = zeros(1,num_points);
filt_pts = {};
good_frac = 0;
for j=1:num_points
  [handles,outstruc]= CheckTol_ParseData(handles,hObject,j);

  avg_power(j) = outstruc.avg_power*handles.yag_conv_norm;
  peak_power(j) = outstruc.peak_power*handles.yag_conv_norm;
  rms_power(j) = outstruc.rms_power*handles.yag_conv_norm;
  xrms(j) =outstruc.xrms;
  yrms(j) = outstruc.yrms;
  xrms_rms(j) = outstruc.xrms_rms;
  yrms_rms(j) = outstruc.yrms_rms;
  xpos(j) = outstruc.xpos;
  ypos(j) = outstruc.ypos;
  xpos_rms(j) = outstruc.xpos_rms;
  ypos_rms(j) = outstruc.ypos_rms;
  filt_pts{j} = outstruc.power_hist*handles.yag_conv_norm;
  eloss(j) = outstruc.eloss;
  eloss_rms(j) = outstruc.eloss_rms;
  filter_stat(j) = outstruc.filter_stat;

  gdet2_cal(j) = handles.data(j).gdet2_cal;

  good_frac = good_frac + handles.good_fraction;
end
good_frac = round(100*good_frac/num_points)/100;
if handles.tol_status
    set(handles.GOODFRAC,'String',num2str(good_frac));
else
    set(handles.GOODFRAC,'String','');
end


if isfield(handles,'most_recent')
  % convert averages of most recent data to exponents, using MW
  [avg_power_str,parg,pexp] = ExpFormat(avg_power(handles.most_recent),3);
  [peak_power_str,parg,pexp] = ExpFormat(peak_power(handles.most_recent),3);
  [rms_power_str,parg,pexp] = ExpFormat(rms_power(handles.most_recent),3);

end

% number of shots per data point
if isfield(handles.data,'tmit')
  for j=1:num_points
    %num_shots(j) = length(handles.data(j).tmit);
    num_shots(j) = max(length(handles.data(j).tmit),length(handles.data(j).gdet1));
  end
end

% make matrix with z position and filtered power data
if num_points > 1
  power_data = sortrows(cat(1,und_pos',avg_power,peak_power,rms_power,filter_stat,num_shots,gdet2_cal)');
else
  power_data = [und_pos avg_power peak_power rms_power filter_stat num_shots gdet2_cal];
end

% ordered z positions
handles.measZ = power_data(:,1);

% ordered gdet2 calibration
handles.plot.gdet2_cal = power_data(:,7);



% read chosen data type
data_type = get(handles.DATATYPE,'String');
curr_type = get(handles.DATATYPE,'Value');
curr_data_type = data_type(curr_type);

detectors = get(handles.DETECTOR,'String');
curr_detector = get(handles.DETECTOR,'Value');
det = detectors(curr_detector);

if strcmp(curr_data_type,'Power (Peak)')
  handles.meas_p = power_data(:,3);
else
  handles.meas_p = power_data(:,2);
end


% normalize by the square root of the number of shots
sig_norm = sqrt(power_data(:,6));
sig_w = power_data(:,4)./sig_norm;   % weight sigma by sqrt(num_shots)
handles.meas_err = sig_w;

z_plot = handles.measZ;

% cutoff point to remove non-linear data
cutoff_high = str2num(get(handles.CUTOFFHIGH,'String'));
cutoff_low = str2num(get(handles.CUTOFFLOW,'String'));

if isempty(cutoff_high)
  cutoff_high = max(handles.meas_p);
end

if isempty(cutoff_low)
  cutoff_low = min(handles.meas_p);
end



% power for normalizing genesis plot and saved data structure
for j=1:num_points
    handles.data(j).plot.power = avg_power(j);
    handles.data(j).plot_power = avg_power(j);    % easier to read by vertcat
    handles.data(j).plot.power_sig = rms_power(j);
    handles.data(j).plot.eloss = eloss(j);
    handles.data(j).plot_eloss = eloss(j);        % easier to read by vertcat
    handles.data(j).plot.eloss_sig = eloss_rms(j);
    handles.data(j).plot.xrms = xrms(j);
    handles.data(j).plot.yrms = yrms(j);
    handles.data(j).plot.xrms_sig = xrms_rms(j)/sig_norm(j);
    handles.data(j).plot.yrms_sig = yrms_rms(j)/sig_norm(j);
    handles.data(j).plot.xpos = xpos(j);
    handles.data(j).plot.ypos = ypos(j);
    handles.data(j).plot.xpos_sig = xpos_rms(j)/sig_norm(j);
    handles.data(j).plot.ypos_sig = ypos_rms(j)/sig_norm(j);
end

% Calculate measured gain length, with fit
meas_gl = 0;
meas_gl_sig = 0;
if num_points > 1
  [meas_gl,meas_f,chisq,meas_gl_sig,handles] = CalcGainLength(handles,z_plot,handles.meas_p,sig_w,cutoff_high,cutoff_low);
  handles.meas_f = meas_f;
  handles.chisq = chisq;
end
handles.meas_gl = meas_gl;
handles.meas_gl_sig = meas_gl_sig;



% plot measured power with gain length fit
GLax=handles.GLAX;
hold(GLax,'off');



% Plot Data
if strcmp(det,'ELoss (e-)')
  eloss = sortrows(cat(1,und_pos',eloss-min(eloss),eloss_rms./sig_norm')');
  errorbar(z_plot,eloss(:,2),eloss(:,3),'*b','MarkerSize',7,'Parent',GLax);
  ylabel(GLax,'Energy Loss (MeV)');
  handles.eloss_val = eloss;
elseif strcmp(curr_data_type,'RMS Size')
  rms = sortrows(cat(1,und_pos',xrms,yrms,xrms_rms./sig_norm',yrms_rms./sig_norm')');
  errorbar(z_plot,rms(:,2),rms(:,4),'*b','MarkerSize',7,'Parent',GLax);
  hold(GLax,'on');
  errorbar(z_plot,rms(:,3),rms(:,5),'*r','MarkerSize',7,'Parent',GLax);
  ylabel(GLax,'RMS (um)');
  legend(GLax,'X RMS','Y RMS','Location','Best');
  %ylim(GLax,[min(min(rms(:,2)),min(rms(:,3)))-100
  %max(max(rms(:,2)),max(rms(:,3)))+150]);
  handles.rms_plot = rms;
elseif strcmp(curr_data_type,'Position')
  pos = sortrows(cat(1,und_pos',xpos,ypos,xpos_rms./sig_norm',ypos_rms./sig_norm')');
  errorbar(z_plot,pos(:,2),pos(:,4),'*b','MarkerSize',7,'Parent',GLax);
  hold(GLax,'on');
  errorbar(z_plot,pos(:,3),pos(:,5),'*r','MarkerSize',7,'Parent',GLax);
  ylabel(GLax,'Position (um)');
  legend(GLax,'X Position','Y Position','Location','Best');
  %ylim(GLax,[min(min(pos(:,2)),min(pos(:,3)))-100 max(max(pos(:,2)),max(pos(:,3)))+500]);
  handles.pos_plot = pos;
elseif strcmp(curr_data_type,'Position Jitter')
  pos = sortrows(cat(1,und_pos',xpos,ypos,xpos_rms./sig_norm',ypos_rms./sig_norm')');
  x=pos(:,2)-mean(pos(:,2));
  y=pos(:,3)-mean(pos(:,3));
  errorbar(z_plot,x,pos(:,4),'*b','MarkerSize',7,'Parent',GLax);
  hold(GLax,'on');
  errorbar(z_plot,y,pos(:,5),'*r','MarkerSize',7,'Parent',GLax);
  ylabel(GLax,'Position Jitter (um)');
  legend(GLax,'X Jitter','Y Jitter','Location','Best');
  %ylim(GLax,[min(min(x),min(y))-100 max(max(x),max(y))+200]);
  handles.pos_plot = pos;
elseif strcmp(curr_data_type,'Power Jitter')
  plot(z_plot,power_data(:,4)./handles.meas_p,'*b','MarkerSize',7,'Parent',GLax);
  ylabel(GLax,'Power Jitter (rel)');
  handles.powerrms_plot = power_data(:,4);
elseif any(isfinite(avg_power) == 0)
  set(handles.STATUS,'String','Bad data');  drawnow;
else

  handles=ClearPlot(handles);
  hold(GLax,'on');

  % Plot all data points if desired.  otherwise plot average/peak
  if strcmp(curr_data_type,'Power (All)')
      for j=1:num_points
          all_points = filt_pts{j};
          z=handles.data(j).pos*ones(1,length(all_points));
          semilogy(z,all_points,'*r','MarkerSize',5,'MarkerFaceColor','r','Parent',GLax);
      end
  else
      for j=1:num_points
          if get(handles.LOGSCALE,'Value')
              set(GLax,'YScale','log');
          else
              set(GLax,'YScale','linear');
          end
          if strcmp(det,'Gas Det Both') && (handles.plot.gdet2_cal(j) == max(vertcat(handles.data.gdet2_cal))  || handles.plot.gdet2_cal(j)>0.95)   % for gdet1 case
              mycolor = [1 0 0];
          elseif strcmp(det,'Gas Det Both')    % for gdet2 case
              mycolor = [0 1 0];
          elseif strcmp(det,'Gas Det2')
              mycolor = [0 1 0];
          else
              mycolor = [0.33*power_data(j,5) .65-.2*power_data(j,5) 0];
          end
          errorbar(z_plot(j),handles.meas_p(j),sig_w(j),'or','MarkerSize',7,'Color',mycolor,'Parent',GLax);
          handles.filter_color(j,:) = mycolor;
      end
  end



  % plot fit
  if num_points > 1  && get(handles.LOGSCALE,'Value')

    % plot fit range
    fit_low = [handles.gl_fit_range(1) handles.gl_fit_range(1)];
    fit_high = [handles.gl_fit_range(2) handles.gl_fit_range(2)];
    vertline = [10^-20 10^20];
    plot(fit_low,vertline,'--k',fit_high,vertline,'--k','Parent',GLax);

    % plot fit
    bad_points = find(meas_f<=-50);
    fit_z = z_plot;
    fit_f = handles.meas_f;
    if isempty(bad_points)
      semilogy(z_plot,exp(meas_f),'-g','Parent',GLax);
    else
      set(handles.STATUS,'String',['Error: invalid power at position ' num2str(z_plot(bad_points(1)))]); drawnow;
      meas_f(bad_points) = 1;
      semilogy(z_plot,exp(meas_f),'-g','Parent',GLax);
    end
  end

  if num_points > 1 && max(handles.meas_p)*5 > min(handles.meas_p)/5
    temp_p = sort(handles.meas_p);
    mymin = temp_p(find(temp_p>0,1));
    mymax = max(handles.meas_p);
    if get(handles.LOGSCALE,'Value') && mymin ~= 0
      ylim(GLax,[mymin/5 mymax*5]);
      logrange = floor(log10(mymin)):1:ceil(log10(mymax));
      set(GLax,'YTick',10.^logrange);
    elseif ~get(handles.LOGSCALE,'Value')
      mymin = min(temp_p);
      ylim(GLax,[min(mymin*1.1,-mymax/5) mymax*1.2]);
    end
  end

  xlabel(GLax,'z (m)');
  %ylabel(GLax,'Energy (mJ) Rough Estimate');

  if strcmp(det,'Gas Det1') || strcmp(det,'Gas Det2') || strcmp(det,'Gas Det Both')
      ylabel(GLax,'Energy (mJ)');
  else
      ylabel(GLax,'Energy (arb. units)');
  end
  %set(GLax,'yscale','log');
  set(GLax,'YMinorTick','on');
  %set(GLax,'YTickLabel',num2str(10^(0:12)));
  grid(GLax,'on');
  set(GLax,'YMinorGrid','off');
  xlim(GLax,[0 (handles.und_num+1)*handles.und_length]);

end

if get(handles.LOGSCALE,'Value')
  set(GLax,'YScale','log');
else
  set(GLax,'YScale','linear');
end

grid(GLax,'on');

xlim(GLax,[0 (handles.und_num+1)*handles.und_length]);

if num_points > 1
  result = [num2str(sig_dig(meas_gl,2)) '+-' num2str(sig_dig(meas_gl_sig,2))];
  set(handles.MEASGAINL,'String',result);
  set(handles.CHISQ,'String',num2str(sig_dig(chisq,2)));
end

guidata(hObject, handles);



%%
% ----------------------------------------
function gen_gl = AnalyzeGenesis(hObject, eventdata,  handles)
% Analyze genesis data and write to GUI


% Check if genesis run finished.  If not, wait for it to finish
set(handles.STATUS,'String','Waiting for Genesis run to finish'); drawnow;
task = 'check run';
perl('GainLengthPerl.pl',task,handles.gen_result_file,handles.mystatus);
gen_status = load(handles.mystatus);

if gen_status
    set(handles.STATUS,'String','Processing data'); drawnow;
    % perl('FormatGenOutput.pl');
    task = 'output';
    perl('GainLengthPerl.pl',task,handles.output_file,handles.data_file);
else
    set(handles.STATUS,'String','Genesis run failed'); drawnow;
end


    % Load data from formatted genesis output
if gen_status
    A = load(handles.data_file);
    colA = size(A,1);
    if colA ~= 2
        set(handles.STATUS,'String','Genesis run failed'); drawnow;
        genStatus = 0;
    else
        genZ = A(1,:); genP = A(2,:);
        genZ = genZ*handles.und_length/handles.seg_length;  % convert to undulator length (removes drifts)
    end
end

if gen_status

    % Calculate Genesis gain length, with fit
    cutoff_high = 0;
    cutoff_low = 0;
    %cutoff_high = max(genP)/10;
    %cutoff_low = min(genP)*10;
    sig = ones(size(genZ));
    [gen_gl,gen_f] = CalcGainLength(handles,genZ',genP',sig',cutoff_high,cutoff_low);

    % Match Genesis coordinates to undulator coordinates
    handles = UndStatusCheck(hObject, handles);
    first_und = find(handles.und_status==1,1);
    if isempty(first_und)
      first_und = 0;
    end
    genZ = genZ + (first_und-1)*handles.und_length;
    handles.genZ = genZ;
    handles.genP = genP;
    handles.gen_fit = gen_f;

    % normalize genesis power to measured signal
    if isempty(handles.data.plot.power)
      mynorm = 1;
    else
      meas_pow = vertcat(handles.data.plot.power);
      meas_z = vertcat(handles.data.pos);
      j = find(min(meas_pow));
      zstart = meas_z(j);
      gen_j = find(genZ>=zstart,1);
      mynorm = meas_pow(j)/genP(gen_j);
    end

    % plot genesis power with gain length fit
    GLax=handles.GLAX;
    hold(GLax,'on');
    semilogy(genZ,genP*mynorm,'.',genZ,exp(gen_f)*mynorm,'-','Parent',GLax);
    xlabel(GLax,'z (m)');
    ylabel(GLax,'Power (A.U.)');
    set(GLax,'yscale','log');
    set(GLax,'YMinorTick','on');
    grid(GLax,'on');
    set(GLax,'YMinorGrid','off');
    xlim(GLax,[0 100]);
    %if isfinite(max(max(THist),max(LasPowHist)))
    %    ylim(TMITax,[0 1.1*max(max(THist),max(LasPowHist))+.1]);
    %end
end


% Write data to GUI
set(handles.GENGAINL,'String',num2str(gen_gl));

MingXieGL(hObject, eventdata, handles);

guidata(hObject, handles);
%UpdateGUI(hObject,eventdata, handles);


%%
% ----------------------------------------
function handles = UndStatusCheck(hObject, handles)
% Read and Plot Undulator Status

%return

und_num = handles.und_num;
und_status = zeros(1,und_num);
in_j = 0;
out_j = 0;
ill_j = 0;



UndIn = [];
UndOut = [];

% get status
%und_pos = ones(1,und_num)*80;

% Jim Welch's position function
% if handles.online
%   und_pos = segmentTranslate();
% else
%   und_pos = zeros(33,1);
% end
% FIX FIXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxxx
und_pos=segmentTranslate();


% Check for uninstalled undulators, and relable as out
if handles.online
  insert_status = lcaGet(handles.und_insert_pvs',1,'double');
  for j=1:und_num
    if ~insert_status(j)
      und_pos(j) = handles.out_enough;
    end
  end
end

for j=1:und_num
    if abs(und_pos(j)) <= handles.in_pos
        in_j = in_j+1;
        und_status(j) = 1;
        UndIn(in_j,1) = j;
        UndIn(in_j,2) = und_pos(j)/handles.out_pos;
    elseif und_pos(j) >= handles.out_enough
        out_j = out_j+1;
        UndOut(out_j,1) = j;
        UndOut(out_j,2) = 1;
    else
        % illegal position
        ill_j = ill_j+1;
        und_status(j) = -1;
        UndIll(ill_j,1) = j;
        UndIll(ill_j,2) = und_pos(j)/handles.out_pos;
    end
end



USax=handles.UNDSTATAX;
hold(USax,'off');
my_x=(0:35);
my_y=zeros(size(my_x));
plot(my_x,my_y,'k','linewidth',2,'Parent',USax);
hold(USax,'on');
%stem(und_status,'Parent',USax);
% Plot 'in' undulators
if in_j > 0
    plot(UndIn(:,1),UndIn(:,2),'sg','markersize',10,'Parent',USax);
end

% Plot 'out' undulators
if out_j > 0
    plot(UndOut(:,1),UndOut(:,2),'sk','markersize',10,'Parent',USax);
end

% Plot bad undulators
if ill_j > 0
    plot(UndIll(:,1),UndIll(:,2),'sr','markersize',10,'Parent',USax);
end

if handles.kicked_mag > 0
  plot(handles.kicked_mag,0,'vr','markersize',15,'Parent',USax)
end

hold(USax,'off');
xlabel(USax,'Undulator Number');
%ylabel(USax,'Out=0,In=1');
%set(USax,'ytick',[0 1]);
set(USax,'ytick',[]);
XTicks = 5:5:32;
set(USax,'xtick',XTicks);
set(USax,'xminortick','on');
xlim(USax,[0,34])
ylim(USax,[-.5,1.2])

% tag showing if yagxray is inserted
if handles.online
  yag_tag_stat = lcaGetSmart(handles.yagxray_status_pvs);
else
  yag_tag_stat = 'IN';
end

if strcmp(yag_tag_stat,'IN')
  handles.yag_tag = 1;
  set(handles.ACQ_METHOD,'Value',1);
  set(handles.TAKE_BSA,'Value',1);
  handles.acq_method='YAGXRAY/DIR_IMG';
else
  handles.yag_tag = 0;
end

% FIX FIXXXXXXXXX
und_pos(16)=lcaGetSmart('USEG:UND1:1650:XACT');
handles.und_status = und_status;
handles.und_pos = und_pos;


%%
% ----------------------------------------
function [powerGL,f,chisq,powerGL_sig,handles] = CalcGainLength(handles,z,p,sig,cutoff_high,cutoff_low)
% Calculate fit parameters


n = length(p);


%limitH = round(cutoff_high-z(1)/handles.und_length)+1;
%limitL = round(cutoff_low-z(1)/handles.und_length)+1;

limitH = find(z==cutoff_high*handles.und_length);
limitL = find(z==cutoff_low*handles.und_length);

if isempty(limitL)
  limitL = 1;
end

if isempty(limitH)
  limitH = n;
end

if n<3
  limitL=1;
  limitH=n;
end

if limitL < 1
  limitL = 1;
elseif limitL >= n
  limitL = n-1;
end

if limitH <=limitL
  limitH = limitL+1;
elseif limitH > n
  limitH = n;
end

bad_points = find(p<=0);
p(bad_points) = 1e-10;

% normalize sigma to data
sig = sig./p;

% fit data
z_fit = z(limitL:limitH);
p_fit = log(p(limitL:limitH));
sig_fit = sig(limitL:limitH);


Q = [z_fit ones(length(z_fit),1)];

for j=1:length(sig_fit)
  if sig_fit(j) < 10^-7;
    sig_fit(j) = 1;
  end
end

[y,dy,R,dR,chisq] = fit(Q,p_fit,sig_fit);

% Evaluate the bunching2 fit
f = polyval(R,z);

% gain length
powerGL = 1/R(1);
powerGL_sig = dR(1)/R(1)^2*sqrt(chisq);

handles.gl_fit_range = [z(limitL) z(limitH)];


%%
% ----------------------------------------
function MingXieGL(hObject, eventdata, handles)
% Read and write Ming Xie data to GUI

handles = ReadFromGUI(hObject, eventdata, handles);

handles.mx_gl = 0;

eps = sqrt(handles.x_emit*handles.y_emit);
curr = handles.curr*1000;

% TAKE OUT IF HEINZ-DIETER CHANGES GUI.
% If so, then need to add option back to GUI
handles.bl = 1;  % seems not to be necessary?  should check...

mx_struc = util_LCLS_FEL_Performance_Estimate(handles.energy,eps,curr,handles.bl,handles.e_spread);

handles.mx_gl = mx_struc.L_G3D;


set(handles.MXGAINL,'String',num2str(handles.mx_gl));

%%
% ----------------------------------------
function handles = ReadFromGUI(hObject, eventdata,  handles)
% Read in current values from GUI
handles.x_emit = str2double(get(handles.XEMIT,'String'));
handles.y_emit = str2double(get(handles.YEMIT,'String'));
handles.energy = str2double(get(handles.ENERGY,'String'));
%handles.energy = 13.64;   % hard coded until we figure out energy scan problem
handles.curr = str2double(get(handles.CURR,'String'));
%handles.bl = str2double(get(handles.BL,'String'));
handles.bl = 1;  % hardcoded until henrik changes code to use this
e_spread = str2double(get(handles.ESPREAD,'String'));

% convert percentage relative espread to delta gamma
handles.e_spread = e_spread*handles.energy/handles.e_rest/100;

guidata(hObject, handles);

%%
% ----------------------------------------
function handles = UpdateGUI(hObject,eventdata,handles)
% Writes new PV values to GUI

gen_param = lcaGetSmart(handles.gen_pvs);
handles.energy = sig_dig(gen_param(1),2);
%handles.energy = 13.64; % hard coded for now
handles.curr = sig_dig(gen_param(2)/1000,2); % convert to kA
handles.bl = sig_dig(gen_param(3),2);
x_emit = gen_param(4);
y_emit = gen_param(5);
x_bmag = gen_param(6);
y_bmag = gen_param(7);
%handles.e_spread = gen_param(4);

% scale measured emittance by Bmag
handles.x_emit = sig_dig(x_emit*x_bmag,2);
handles.y_emit = sig_dig(y_emit*y_bmag,2);

% convert percentage relative espread to delta gamma
e_spread = handles.e_spread/handles.energy*handles.e_rest*100;

e_spread = sig_dig(e_spread,3);

set(handles.XEMIT,'String',num2str(handles.x_emit));
set(handles.YEMIT,'String',num2str(handles.y_emit));
set(handles.ENERGY,'String',num2str(handles.energy));
set(handles.CURR,'String',num2str(handles.curr));
%set(handles.BL,'String',num2str(handles.bl));
set(handles.ESPREAD,'String',num2str(e_spread));
set(handles.NUMSHOTS,'String',num2str(handles.num_shots));

MingXieGL(hObject, eventdata, handles)

guidata(hObject, handles);


%% round x to n significant digits
function x_out = sig_dig(x,n)

x_out = round(x*10^n)/10^n;


%%
% ----------------------------------------
function [mystring,myarg,myexp] = ExpFormat(num,prec)

if num <= 0
  myarg = 0;
  myexp = 0;
else
  myexp = floor(log10(num));
  myarg = num/10^myexp;
  myarg = round(10^(prec-1)*myarg)/10^(prec-1);
end
mystring = [num2str(myarg),'E',num2str(myexp)];


%%
% --- Executes on button press in ABORT.
function ABORT_Callback(hObject, eventdata, handles)
% hObject    handle to ABORT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%
% --- Executes on button press in INCLUDEGEN.
function INCLUDEGEN_Callback(hObject, eventdata, handles)
% hObject    handle to INCLUDEGEN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of INCLUDEGEN



%%
% ----------------------------------------
function XEmit_Callback(hObject, eventdata, handles)
% hObject    handle to XEmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XEmit as text
%        str2double(get(hObject,'String')) returns contents of XEmit as a double


% --- Executes during object creation, after setting all properties.
function XEmit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XEmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function XEMIT_Callback(hObject, eventdata, handles)
% hObject    handle to XEMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XEMIT as text
%        str2double(get(hObject,'String')) returns contents of XEMIT as a double


% --- Executes during object creation, after setting all properties.
function XEMIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XEMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YEMIT_Callback(hObject, eventdata, handles)
% hObject    handle to YEMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YEMIT as text
%        str2double(get(hObject,'String')) returns contents of YEMIT as a double



% --- Executes during object creation, after setting all properties.
function YEMIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YEMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function Current_Callback(hObject, eventdata, handles)
% hObject    handle to curr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of curr as text
%        str2double(get(hObject,'String')) returns contents of curr as a double


% --- Executes during object creation, after setting all properties.
function Current_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function CURR_Callback(hObject, eventdata, handles)
% hObject    handle to CURR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CURR as text
%        str2double(get(hObject,'String')) returns contents of CURR as a double


% --- Executes during object creation, after setting all properties.
function CURR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CURR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Energy_Callback(hObject, eventdata, handles)
% hObject    handle to Energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Energy as text
%        str2double(get(hObject,'String')) returns contents of Energy as a double


% --- Executes during object creation, after setting all properties.
function Energy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ENERGY_Callback(hObject, eventdata, handles)
% hObject    handle to ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ENERGY as text
%        str2double(get(hObject,'String')) returns contents of ENERGY as a double


% --- Executes during object creation, after setting all properties.
function ENERGY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function MEASGAINL_Callback(hObject, eventdata, handles)
% hObject    handle to MEASGAINL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MEASGAINL as text
%        str2double(get(hObject,'String')) returns contents of MEASGAINL as a double


% --- Executes during object creation, after setting all properties.
function MEASGAINL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MEASGAINL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GENGAINL_Callback(hObject, eventdata, handles)
% hObject    handle to GENGAINL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GENGAINL as text
%        str2double(get(hObject,'String')) returns contents of GENGAINL as a double


% --- Executes during object creation, after setting all properties.
function GENGAINL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GENGAINL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MXGAINL_Callback(hObject, eventdata, handles)
% hObject    handle to MXGAINL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MXGAINL as text
%        str2double(get(hObject,'String')) returns contents of MXGAINL as a double


% --- Executes during object creation, after setting all properties.
function MXGAINL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MXGAINL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MEASMETHOD.
function MEASMETHOD_Callback(hObject, eventdata, handles)
% hObject    handle to MEASMETHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MEASMETHOD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MEASMETHOD


% --- Executes during object creation, after setting all properties.
function MEASMETHOD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MEASMETHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BL_Callback(hObject, eventdata, handles)
% hObject    handle to BL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BL as text
%        str2double(get(hObject,'String')) returns contents of BL as a double


% --- Executes during object creation, after setting all properties.
function BL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function ESPREAD_Callback(hObject, eventdata, handles)
% hObject    handle to ESPREAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ESPREAD as text
%        str2double(get(hObject,'String')) returns contents of ESPREAD as a double


% --- Executes during object creation, after setting all properties.
function ESPREAD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ESPREAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function MAGDIST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAGDIST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function NUMSHOTS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NUMSHOTS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes during object creation, after setting all properties.
function DETECTOR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DETECTOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit43_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function MAGTYPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAGTYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function UNDEND_Callback(hObject, eventdata, handles)
% hObject    handle to UNDEND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UNDEND as text
%        str2double(get(hObject,'String')) returns contents of UNDEND as a double



% --- Executes during object creation, after setting all properties.
function UNDEND_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UNDEND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function LOOPEND_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LOOPEND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in RESTOREUND.
function RESTOREUND_Callback(hObject, eventdata, handles)
% hObject    handle to RESTOREUND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Removed because it's preferred to use the move undulator GUI that
% corrects for orbit errors

set(handles.Status,'String','Restore Und not working.'); drawnow;
return;

RestoreUnd(hObject,eventdata,handles);
set(handles.STATUS,'String','Ready');

function handles = RestoreUnd(hObject, eventdata, handles)

if ~handles.online
  return
end

und_num = handles.und_num;
config = handles.saved_config_und;
handles = UndStatusCheck(hObject, handles);


set(handles.STATUS,'String','Moving Undulators: Please Wait'); drawnow;

in_und = find (abs(config) <= handles.in_pos);


handles.my_position = config;

% turn off beam
lcaPut(handles.BYKick,0);

% restore undulator positions
lcaPutSmart(handles.und_names(1:end),config);

und_des = ones(1,und_num);
for j=1:und_num
  if config(j)>=handles.out_enough
    und_des(j) = 0;
  elseif abs(config(j))>handles.in_pos
    und_des(j) = -1;
  end
end

MovingUndCheck(hObject, handles,und_des);

% turn on beam
lcaPut(handles.BYKick,1);



UndStatusCheck(hObject, handles);
guidata(hObject, handles);



% --- Executes on button press in RESTOREMAG.
function RESTOREMAG_Callback(hObject, eventdata, handles)
% hObject    handle to RESTOREMAG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RestoreMag(hObject, eventdata, handles);

handles = find_kicked_mag(handles);

handles = UndStatusCheck(hObject, handles);

AnalyzeMeas(hObject, eventdata, handles);

% reset HXRSS feedback
% FINISH FINISH FINISH
if isfield(handles,'HXRSS_feedback_status')
    lcaPutSmart(handles.HXRSS_feedback,handles.HXRSS_feedback_status);
end

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);

% Restore current magnet to last saved value
function handles = RestoreMag(hObject, eventdata, handles)


last_und = str2num(get(handles.LASTUND,'String'));
mag_options = get(handles.MAGTYPE,'String');
type = get(handles.MAGTYPE,'Value');
mag_type = mag_options(type);
if strcmp(mag_type,'X Corr')
    mag_name = handles.xmag_names(last_und);
    myconfig = handles.saved_config_xmag;
else
    mag_name = handles.ymag_names(last_und);
    myconfig = handles.saved_config_ymag;
end

set(handles.STATUS,'String','Changing Corrector: Please Wait'); drawnow;


%MoveMag(handles,mag_name,-handles.max_kick/(handles.max_e/handles.nom_e));
MoveMag(handles,mag_name,myconfig(last_und),'trim');





% --- Executes on button press in SAVEMAG.
function SAVEMAG_Callback(hObject, eventdata, handles)
% hObject    handle to SAVEMAG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.online
  return
end
handles.saved_config_xmag = lcaGetSmart(handles.xmag_bdes);
handles.saved_config_ymag = lcaGetSmart(handles.ymag_bdes);
guidata(hObject, handles);

% --- Executes on button press in SAVEUND.
function SAVEUND_Callback(hObject, eventdata, handles)
% hObject    handle to SAVEUND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = UndStatusCheck(hObject, handles);
handles.saved_config_und = handles.und_pos';
guidata(hObject, handles);

% --- Executes on button press in UPDATEINP.
function UPDATEINP_Callback(hObject, eventdata, handles)
% hObject    handle to UPDATEINP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.STATUS,'String','Loading data'); drawnow;
handles = UpdateGUI(hObject,eventdata,handles);
set(handles.STATUS,'String','Ready'); drawnow;




function UNDBEG_Callback(hObject, eventdata, handles)
% hObject    handle to UNDBEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UNDBEG as text
%        str2double(get(hObject,'String')) returns contents of UNDBEG as a double


% --- Executes during object creation, after setting all properties.
function UNDBEG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UNDBEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function LOOPEND_Callback(hObject, eventdata, handles)
% hObject    handle to LOOPEND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LOOPEND as text
%        str2double(get(hObject,'String')) returns contents of LOOPEND as a double




function MAGDIST_Callback(hObject, eventdata, handles)
% hObject    handle to MAGDIST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MAGDIST as text
%        str2double(get(hObject,'String')) returns contents of MAGDIST as a double


% --- Executes during object creation, after setting all properties.
function edit51_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MAGDIST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NUMSHOTS_Callback(hObject, eventdata, handles)
% hObject    handle to NUMSHOTS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NUMSHOTS as text
%        str2double(get(hObject,'String')) returns contents of NUMSHOTS as a double


% --- Executes on selection change in MAGTYPE.
function MAGTYPE_Callback(hObject, eventdata, handles)
% hObject    handle to MAGTYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MAGTYPE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MAGTYPE


% --- Executes on selection change in DETECTOR.
function DETECTOR_Callback(hObject, eventdata, handles)
% hObject    handle to DETECTOR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DETECTOR contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DETECTOR

% read chosen data type
detector_type = get(handles.DETECTOR,'String');
curr_type = get(handles.DETECTOR,'Value');
det = detector_type(curr_type);

% read chosen data type
data_type = get(handles.DATATYPE,'String');
curr_type = get(handles.DATATYPE,'Value');
dat = data_type(curr_type);

if strcmp(det,'ELoss (e-)') %|| strcmp(det,'Gas Det1') || strcmp(det,'Gas Det2')
  set(handles.LOGSCALE,'Value',0);
elseif strfind(data_type{curr_type},'Power')
  set(handles.LOGSCALE,'Value',1);
else
  set(handles.LOGSCALE,'Value',0);
end

if strcmp(det,'Spectrometer')
  set(handles.PROFMON_METHOD,'Value',8);
end

handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready');

guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function ANALYZEMETHOD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ANALYSISMETHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenu15.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu15


% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function edit59_Callback(hObject, eventdata, handles)
% hObject    handle to edit59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit59 as text
%        str2double(get(hObject,'String')) returns contents of edit59 as a double


% --- Executes during object creation, after setting all properties.
function edit59_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit58_Callback(hObject, eventdata, handles)
% hObject    handle to edit58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit58 as text
%        str2double(get(hObject,'String')) returns contents of edit58 as a double


% --- Executes during object creation, after setting all properties.
function edit58_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit57_Callback(hObject, eventdata, handles)
% hObject    handle to edit57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit57 as text
%        str2double(get(hObject,'String')) returns contents of edit57 as a double


% --- Executes during object creation, after setting all properties.
function edit57_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit56_Callback(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit56 as text
%        str2double(get(hObject,'String')) returns contents of edit56 as a double


% --- Executes during object creation, after setting all properties.
function edit56_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in CLEARPOINT.
function CLEARPOINT_Callback(hObject, eventdata, handles)
% hObject    handle to CLEARPOINT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







%%
% --- Executes on button press in LOG.
function LOG_Callback(hObject, eventdata, handles)
% hObject    handle to LOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tic


% undulator range
if handles.online
    handles = UndStatusCheck(hObject, handles);
    first_und = find(handles.und_status==1,1,'first');
    last_und = find(handles.und_status==1,1,'last');
else
    first_und=1;
    last_und=33;
end

% if data is new, save data
if ~handles.saved_data
  und_in = find(handles.und_status);
  handles.data(1).inserted_und = und_in;

  save_data = handles.data;
  mydate = clock;
  [save_file] = util_dataSave(save_data,'GainLength','',mydate);
  handles.saved_data = 1;
  handles.file_name = save_file;
else
  save_file = handles.file_name;
end






if isempty(handles.genZ);
  handles.genZ = zeros(size(handles.measZ));
  handles.genP = handles.genZ;
  handles.gen_f = handles.genZ;
end

% make log plot
figure(101);
hold off
%LogGen = get(handles.LOGGEN,'Value');
LogGen = 0;
if ~isempty(handles.genZ) && LogGen
  semilogy(handles.genZ,handles.genP,'.',handles.genZ,exp(handles.gen_f),'-');
  hold off
end


% read chosen data type
data_type = get(handles.DATATYPE,'String');
curr_type = get(handles.DATATYPE,'Value');
curr_data_type = data_type(curr_type);

detectors = get(handles.DETECTOR,'String');
curr_detector = get(handles.DETECTOR,'Value');
det = detectors(curr_detector);

und_pos = vertcat(handles.data.pos);
num_points = length(und_pos);


% yag conversion factor (counts to J)
avg_charge = mean(vertcat(handles.data.tmit))/handles.nC_to_ne;



filt_pts = {};
good_frac = 0;
for j=1:num_points
  [handles,outstruc]= CheckTol_ParseData(handles,hObject,j);

  filt_pts{j} = outstruc.power_hist*handles.yag_conv_norm;
  eloss(j) = outstruc.eloss;
  eloss_rms(j) = outstruc.eloss_rms;
  filter_stat(j) = outstruc.filter_stat;

  good_frac = good_frac + handles.good_fraction;
end




z_plot = handles.measZ;
if isempty(z_plot)
    z_plot = vertcat(handles.data.pos);
end


% Plot Data
if strcmp(det,'ELoss (e-)')
  % plot eloss
  eloss = handles.eloss;
  errorbar(z_plot,eloss(:,2),eloss(:,3),'*b','MarkerSize',7);
  hold('on');

  % plot undulator range

  h = min(eloss(:,2))-1;
  my_x=(0:34)*handles.und_length;
  my_y=ones(size(my_x))*h;
  plot(my_x,my_y,'k','linewidth',2);
  hold('on');
  % plot undulator range
  if isfield(handles.data(1),'inserted_und')
      z = handles.data(1).inserted_und*handles.und_length;
      plot(z,h,'sg','markersize',10);
  end
  title('Energy loss from DL2 to dump');
  ylim([h-.5 max(eloss(:,2))+1]);
  ylabel('Energy Loss (MeV)');
  set(gca,'YScale','linear');
elseif strcmp(curr_data_type,'RMS Size')
  rms = handles.rms_plot;
  h1=errorbar(z_plot,rms(:,2),rms(:,4),'*b','MarkerSize',7);
  hold('on');
  h2=errorbar(z_plot,rms(:,3),rms(:,5),'*r','MarkerSize',7);
  set(gca,'YScale','linear');
  legend([h1 h2],'X RMS','Y RMS','Location','Best');
  %ylim(gca,[min(min(rms(:,2)),min(rms(:,3)))-100 max(max(rms(:,2)),max(rms(:,3)))+150]);
  ylabel('RMS (microns)');
elseif strcmp(curr_data_type,'Position')
  pos = handles.pos_plot;
  set(gca,'YScale','linear');
  h1=errorbar(z_plot,pos(:,2),pos(:,4),'*b','MarkerSize',7);
  hold('on');
  h2=errorbar(z_plot,pos(:,3),pos(:,5),'*r','MarkerSize',7);
  ylabel(gca,'Position (um)');
  legend([h1 h2],'X Position','Y Position','Location','Best');
  %ylim(GLax,[min(min(pos(:,2)),min(pos(:,3)))-100 max(max(pos(:,2)),max(pos(:,3)))+500]);
elseif strcmp(curr_data_type,'Position Jitter')
  pos = handles.pos_plot;
  x=pos(:,2)-mean(pos(:,2));
  y=pos(:,3)-mean(pos(:,3));
  h1=errorbar(z_plot,x,pos(:,4),'*b','MarkerSize',7);
  hold('on')
  h2=errorbar(z_plot,y,pos(:,5),'*r','MarkerSize',7);
  set(gca,'YScale','linear');
  legend([h1 h2],'X Jitter','Y Jitter','Location','Best');
  %ylim(gca,[min(min(pos(:,2)),min(pos(:,3)))-100 max(max(pos(:,2)),max(pos(:,3)))+300]);
  ylabel('Position Jitter');
elseif strcmp(curr_data_type,'Power Jitter')
  power_rms = handles.powerrms_plot;
  plot(z_plot,power_rms./handles.meas_p,'*','MarkerSize',7);
  hold('on');
  set(gca,'YScale','linear');
  ylabel('Power Jitter (rel)');
else
  % Plot all data points if desired.  otherwise plot average/peak
  if ~isempty(z_plot)
    if strcmp(curr_data_type,'Power (All)')
        for j=1:num_points
            all_points = filt_pts{j};
            %all_points = filt_pts(j).data;
            z=handles.data(j).pos*ones(1,length(all_points));
            semilogy(z,all_points,'*r','MarkerSize',5,'MarkerFaceColor','r');
            hold on
        end
        semilogy(handles.measZ,exp(handles.meas_f),'-g');
    else
        for j=1:num_points
          mycolor = handles.filter_color(j,:);
          errorbar(z_plot(j),handles.meas_p(j),handles.meas_err(j),'o','MarkerSize',9,'Color',mycolor);
          hold on
        end
        if get(handles.LOGSCALE,'Value') && length(handles.meas_f) == length(handles.measZ)
          semilogy(handles.measZ,exp(handles.meas_f),'-g');
        end
        hold on
    end
  end

  % plot fit range
  if isfield(handles,'gl_fit_range') && get(handles.LOGSCALE,'Value')
    fit_low = [handles.gl_fit_range(1) handles.gl_fit_range(1)];
    fit_high = [handles.gl_fit_range(2) handles.gl_fit_range(2)];
    vertline = [10^-20 10^20];
    plot(fit_low,vertline,'--k',fit_high,vertline,'--k')
  end



  % plot undulator range
  if isfield(handles.data(1),'inserted_und')
      z = handles.data(1).inserted_und*handles.und_length;
      %z = (first_und:last_und)*handles.und_length;

      h = min(handles.meas_p(handles.meas_p>0))/3;

      my_x=(0:34)*handles.und_length;
      my_y=ones(size(my_x))*h;
      plot(my_x,my_y,'k','linewidth',2);
      plot(z,h,'sg','markersize',10);

  end

  xlabel('z (m)');

  if strcmp(det,'Gas Det1') || strcmp(det,'Gas Det2') || strcmp(det,'Gas Det Both')
      ylabel('Energy (mJ)');
  else
      ylabel('Energy (arb. units)');
  end



  temp_p = sort(handles.meas_p);
  mymin = temp_p(find(temp_p>0,1));
  mymax = max(handles.meas_p);
  if get(handles.LOGSCALE,'Value') && mymin > 0
    ylim(gca,[mymin/5 mymax*5]);
    logrange = floor(log10(mymin)):1:ceil(log10(mymax));
    set(gca,'YTick',10.^logrange);
  else
    ylim(gca,[-mymax/5 mymax*1.2]);
  end




  methods = get(handles.PROFMON_METHOD,'String');
  curr_method = get(handles.PROFMON_METHOD,'Value');
  meas_method = methods(curr_method);


end

xlim([0 (handles.und_num+1)*handles.und_length]);

if get(handles.LOGSCALE,'Value')
  set(gca,'YScale','log');
else
  set(gca,'YScale','linear');
end

grid on
set(gca,'yminorgrid','on');

methods = get(handles.MEASMETHOD,'String');
curr_method = get(handles.MEASMETHOD,'Value');
meas_method = methods(curr_method);

% Measurement method
if strcmp(meas_method,'Move X Corr') || strcmp(meas_method,'Move Y Corr')
  meas_method = '';  % used to by XC or YC, but now use both
else
  meas_method = 'Und-';
end



if strcmp(handles.acq_method,'XPP Spectrometer') || strcmp(handles.acq_method,'FEE Spectrometer') || strcmp(handles.acq_method,'SXR Spectrometer')
    detector = 'SPEC';
elseif any(strcmp(det,{'Dir Img Near'; 'Dir Img Wide'; 'Dir Img Henrik'}))
  detector = 'DirImg';
elseif strcmp(det,'YAGXRAY Henrik')
  detector = 'YagX';
elseif strcmp(det,'Gas Det1')
  detector = 'GDet1';
elseif strcmp(det,'Gas Det2')
  detector = 'GDet2';
elseif strcmp(det,'Gas Det Both')
  detector = 'GDet';
elseif strcmp(det,'Total Energy')
  detector = 'TotE';
elseif strcmp(det,'ELoss (e-)')
  detector = 'ELoss';
elseif strcmp(det,'K-Mono')
  detector = 'KMono';
end

% gainlength
gl = sprintf('%4.2f',handles.meas_gl);
gl_sig = sprintf('%4.2f',handles.meas_gl_sig);

% only added field to data structure in April, 2010
if isfield(handles.data,'e_des')
  nom_e = num2str(sprintf('%4.2f',handles.data(1).e_des));            % desired energy dump
  curr_des = num2str(sprintf('%3.1f',handles.data(1).curr_des/1000));      % desired current from set point
  lh_des = num2str(sprintf('%4.1f',handles.data(1).lh_energy_des));          % laser heater power
else
  nom_e='--';
  curr_des='--';
  lh_des='--';
end

str_n = strfind(save_file,'--');
str_end = length(save_file);
filedate = save_file(str_n+2:str_end-4);

%mytitle = ['Und:' num2str(first_und) 'to' num2str(last_und) ','...
%    nom_e 'GeV,' curr_des 'kA,' 'LH=' lh_des 'uJ,'  meas_method '-' detector ',' filedate];
mytitle = [nom_e 'GeV,' curr_des 'kA,' 'LH=' lh_des 'uJ,'  meas_method detector ',' filedate];


if ~strcmp(det,'ELoss (e-)')
  mytitle = ['GL=' num2str(gl) '+-' num2str(gl_sig) 'm,' mytitle];
end

title(mytitle);

drawnow

% save gain length to matlab pvs
if handles.online
  lcaPutSmart('SIOC:SYS0:ML00:AO518',handles.meas_gl);
  lcaPutSmart('SIOC:SYS0:ML00:AO519',handles.meas_gl_sig);
end

opts.title=['Gain Length: ' num2str(gl) '+-' num2str(gl_sig) 'm,' detector ' - ' filedate ];

% put to log
util_printLog(101,opts);



guidata(hObject,handles);





function LOOPBEG_Callback(hObject, eventdata, handles)
% hObject    handle to LOOPBEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LOOPBEG as text
%        str2double(get(hObject,'String')) returns contents of LOOPBEG as a double


% --- Executes during object creation, after setting all properties.
function LOOPBEG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LOOPBEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function LASTUND_Callback(hObject, eventdata, handles)
% hObject    handle to LASTUND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LASTUND as text
%        str2double(get(hObject,'String')) returns contents of LASTUND as a double


% --- Executes during object creation, after setting all properties.
function LASTUND_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LASTUND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%
function EBEAM_Callback(hObject, eventdata, handles)
% hObject    handle to EBEAM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EBEAM as text
%        str2double(get(hObject,'String')) returns contents of EBEAM as a double

%%
% --- Executes during object creation, after setting all properties.
function EBEAM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EBEAM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function handles = EBeam(handles)

if ~handles.online
  handles.meas_e=handles.max_e;
  return
end

ltu_bpms = {'BPMS:LTU1:250:X'
            'BPMS:LTU1:450:X'};

dl2_pos = lcaGetSmart(ltu_bpms);
handles.nom_e = lcaGetSmart('BEND:LTU0:125:BDES');

while isnan(dl2_pos)
  set(handles.STATUS,'String','Cannot read energy: waiting for beam'); drawnow;
  pause(1);
  dl2_pos = lcaGetSmart(ltu_bpms);

  % If abort called end program
  handles.abort = max(get(handles.STARTMEAS,'Value'),get(handles.TAKEDATA,'Value'));
  if handles.abort == 0
      set(handles.STATUS,'String','Aborting');
      drawnow
      return;
  end

end


delta_e = (dl2_pos(1)/handles.dl2_eta(1)+dl2_pos(2)/handles.dl2_eta(2))/2;
my_energy = (1-delta_e)*handles.nom_e;


handles.meas_e = round(my_energy*100)/100;

%%
function [handles,outstruc] = GetSynchData(hObject,handles)
% Do beam synchronous acquisition


% TAKE OUT SET 0 IF BSA BROKEN
di_bsa = 0;
use_henrik=1;     % until llnl software fixed (never) use henrik's profmon


% number of shots to take
handles.num_shots = str2double(get(handles.NUMSHOTS,'String'));

% initialize variables
yag_data = num2cell(zeros(1,handles.num_shots));
di_yag_data = yag_data;
outstruc.yag_data = yag_data;
outstruc.di_data = di_yag_data;
outstruc.x_eloss = [];
outstruc.y_eloss = [];
outstruc.tmit = 0;
outstruc.delta_e = 0;
outstruc.curr = 0;
outstruc.xorb_max = 0;
outstruc.yorb_max = 0;
outstruc.orbit = 0;
outstruc.di_OD = [0 0];
outstruc.OD = [0 0 0];
outstruc.attens = [0 0];
outstruc.n_dir_img = zeros(1,handles.num_shots);
outstruc.w_dir_img = zeros(1,handles.num_shots);
outstruc.gdet1 = zeros(1,handles.num_shots);
outstruc.gdet2 = zeros(1,handles.num_shots);
outstruc.tot_energy = zeros(1,handles.num_shots);
outstruc.yag_tot_pix = zeros(1,handles.num_shots);
outstruc.kmono = zeros(1,handles.num_shots);

handles.dirimg_sat = 0;
handles.ncam_dirimg_sat = 0;
handles.wcam_dirimg_sat = 0;
handles.yagcam_sat = 0;

handles.ncam_di_getting_low = 0;
handles.wcam_di_getting_low = 0;
handles.diyag_getting_low = 0;
handles.yag_getting_low = 0;

gdet1 = 0;
gdet2 = 0;
tedet = 0;


n_di_temp = zeros(handles.num_shots,7);
w_di_temp = zeros(handles.num_shots,7);
n_dir_img.power = 0;
n_dir_img.x = 0;
n_dir_img.y = 0;
n_dir_img.xrms = 0;
n_dir_img.yrms = 0;
w_dir_img.power = 0;
w_dir_img.x = 0;
w_dir_img.y = 0;
w_dir_img.xrms = 0;
w_dir_img.yrms = 0;
tot_energy = 0;
tot_pix = zeros(1,handles.num_shots);
kmono=0;

% if in offline mode, make fake data and return
if ~handles.online
  outstruc.yag_data = num2cell(rand(1,handles.num_shots)*10^10);
  return
end



% wait for beam to turn on
handles.ref_tmit = lcaGetSmart(handles.event_tmit_pvs{end});
while ~isfinite(handles.ref_tmit) || handles.ref_tmit < handles.min_charge
  pause(1)
  set(handles.STATUS,'String','No charge: waiting for beam');
  drawnow
  disp('NoCharge: waiting for beam');
  handles.ref_tmit = lcaGetSmart(handles.event_tmit_pvs{end});

  % If abort called end program
  handles.abort = get(handles.STARTMEAS,'Value');
  if handles.abort == 0
    handles.fail = 1;
    return;
  end
end


% start taking event data
if handles.take_BSA
    eDefParams(handles.eDefNumber,1,2800);
    eDefOn(handles.eDefNumber);
end

% crop status
handles.di_roi_crop=get(handles.USEROI,'Value');

% use xpp spectrometer (for self seeding)
acq_types = get(handles.ACQ_METHOD,'String');
curr_type = get(handles.ACQ_METHOD,'Value');
handles.acq_method = acq_types(curr_type);

% get beam rate
rate = lcaGetSmart('IOC:IN20:MC01:LCLSBEAMRATE');   % rep. rate % [Hz]
if rate < 10
rate = 10;
end


%----------------------
% Gas Detectors
%----------------------

if strcmp(handles.acq_method,'Gas Detectors')

  if ~handles.take_BSA

    gdet1=zeros(handles.num_shots,2);
    gdet2=zeros(handles.num_shots,2);
    %x_eloss=zeros(handles.num_shots,length(handles.eloss_bpm_pvs));
    %y_eloss=zeros(handles.num_shots,length(handles.eloss_bpm_pvs));
    %curr=zeros(handles.num_shots,1);
    for j=1:handles.num_shots

        % read in data
        gdet1(j,1:2)=lcaGetSmart(handles.gdet_pvs(1:2))' - handles.gdet1_offset(1:2);   % gdets
        gdet2(j,1:2)=lcaGetSmart(handles.gdet_pvs(3:4))' - handles.gdet2_offset(1:2);
        %x_eloss(j,:)=lcaGetSmart(handles.eloss_xbpm_pvs)';   % eloss
        %y_eloss(j,:)=lcaGetSmart(handles.eloss_xbpm_pvs)';
        %curr(j)=lcaGetSmart(handles.curr_pvs);              % current

        % check that new data is different from last point.  if not, keep
        % checking until it is different
        pause(1/rate-0.002)     % takes about 3ms to read data
        mycount=0;
        while j>1 && (any(gdet1(j,:)==gdet1(j-1,:)) || any(gdet2(j,:)==gdet2(j-1,:)))
            gdet1(j,1:2)=lcaGetSmart(handles.gdet_pvs(1:2))' - handles.gdet1_offset(1:2);
            gdet2(j,1:2)=lcaGetSmart(handles.gdet_pvs(3:4))' - handles.gdet2_offset(1:2);
            %x_eloss(j,:)=lcaGetSmart(handles.eloss_xbpm_pvs)';
            %y_eloss(j,:)=lcaGetSmart(handles.eloss_xbpm_pvs)';
            %curr(j)=lcaGetSmart(handles.curr_pvs);              % current

            % stop infinite loop that happened once -- problem with GDet?
            mycount=mycount+1;
            if mycount>1e6
                break
            end
        end

        % or be lazy and just wait a little longer
        %pause(1.1/rate);
    end



  else
      % wait for beam;
      pause(handles.num_shots/rate+0.1);

      % check if data collection finished
      while eDefCount(handles.eDefNumber) < handles.num_shots
          pause(0.2);

          % If abort called end program
          handles.abort = get(handles.STARTMEAS,'Value');
          if handles.abort == 0
            handles.fail = 1;
            return;
          end
      end

      % turn eDef OFF
      eDefOff(handles.eDefNumber);
  end

%----------------------
% K-Mono
%----------------------

elseif strcmp(handles.acq_method,'K-Mono')

  if ~handles.take_BSA

    gdet1=zeros(handles.num_shots,2);
    gdet2=zeros(handles.num_shots,2);
    kmono=zeros(1,handles.num_shots);
    for j=1:handles.num_shots

        % read in data
        kmono(j)=lcaGetSmart(handles.kmono_pvs);   % kmono
        gdet1(j,1:2)=lcaGetSmart(handles.gdet_pvs(1:2))' - handles.gdet1_offset(1:2);   % gdets
        gdet2(j,1:2)=lcaGetSmart(handles.gdet_pvs(3:4))' - handles.gdet2_offset(1:2);

        % check that new data is different from last point.  if not, keep
        % checking until it is different
        pause(1/rate)
        mycount=0;
        while j>1 && (kmono(j)==kmono(j-1) || any(gdet1(j,:)==gdet1(j-1,:)) || any(gdet2(j,:)==gdet2(j-1,:)))
            kmono(j)=lcaGetSmart(handles.kmono_pvs);
            gdet1(j,1:2)=lcaGetSmart(handles.gdet_pvs(1:2))' - handles.gdet1_offset(1:2);
            gdet2(j,1:2)=lcaGetSmart(handles.gdet_pvs(3:4))' - handles.gdet2_offset(1:2);

            % stop infinite loop that happened once -- problem with GDet?
            mycount=mycount+1;
            if mycount>1e6
                break
            end
        end
    end

  else
      % wait for beam;
      pause(handles.num_shots/rate+0.1);

      % check if data collection finished
      while eDefCount(handles.eDefNumber) < handles.num_shots
          pause(0.2);

          % If abort called end program
          handles.abort = get(handles.STARTMEAS,'Value');
          if handles.abort == 0
            handles.fail = 1;
            return;
          end
      end

      % turn eDef OFF
      eDefOff(handles.eDefNumber);
  end
  % skip this step for speed

%----------------------
% YAGXRAY
%----------------------

elseif handles.yag_tag        % using YAGXRAY


  % get data from yag xray
  % take background of spontaneous radiation
  spont_bkgrnd = get(handles.SPONTBG,'Value');
  if spont_bkgrnd
    opts.nBG=0;
    opts.doProcess=0;
  else
    opts.nBG=1;
  end
  opts.bufd=1;
  opts.doPlot=1;
  dataList=profmon_measure(handles.xray_profmon,handles.num_shots,opts);

  eDefOff(handles.eDefNumber);

  if spont_bkgrnd
    handles = spont_background(hObject, handles);
  end


  % read out data
  yag_sat = zeros(1,handles.num_shots);
  for j=1:handles.num_shots

    % subtract spontaneous background
    if spont_bkgrnd
      opts.doProcess=1;
      dataList(j).back=handles.spont_img;
      dataList(j).beam=profmon_process(dataList(j),opts);
      %img = img - handles.spont_img;
    else
      % medfilt image
      %dataList(j).img = util_medfilt2(dataList(j).img);
    end


    img=util_medfilt2_DR(dataList(j).img);

    yag_data{j} = dataList(j).beam;       % analyzed yag data

    tot_pix(j) = sum(sum(img));     % total pixel sum (for intensity measurement)
    maxcount = max(max(img));       % maximum pixel (for yag saturation check)
    if maxcount > handles.camera_pixel_sat
        yag_sat(j) = 1;
    elseif maxcount < handles.camera_pixel_sat/(1.5*handles.filter_strength)
        yag_sat(j) = -1;
    else
        yag_sat(j) = 0;
        if maxcount < handles.camera_pixel_sat/(1.1*handles.filter_strength)
          handles.yagcam_getting_low = 1;
        else
          handles.yagcam_getting_low = 0;
        end
    end
  end
  handles.yagcam_sat = max(yag_sat);

%----------------------
% Direct Imager
%----------------------

elseif use_henrik     %  using henrik's profmon GUI on the Direct Imager. set to 1 for time being

  % get data from NFOV direct imager

  % take background of spontaneous radiation
  spont_bkgrnd = get(handles.SPONTBG,'Value');
  if spont_bkgrnd
    opts.nBG=0;
    opts.doProcess=0;
  else
    opts.nBG=1;
  end
  opts.bufd=1;
  opts.doPlot=1;
  if strcmp(handles.acq_method,'XPP Spectrometer')
    dataList=profmon_measure(handles.xpp_spec,handles.num_shots,opts);
  elseif strcmp(handles.acq_method,'FEE Spectrometer')
    dataList=profmon_measure(handles.fee_spec,handles.num_shots,opts);
  elseif strcmp(handles.acq_method,'SXR Spectrometer')
    dataList=profmon_measure(handles.sxr_spec,handles.num_shots,opts);
  else
    dataList=profmon_measure(handles.ndirimg_profmon,handles.num_shots,opts);
  end
  %dataList=profmon_measure(handles.wdirimg_profmon,handles.num_shots,opts)

  eDefOff(handles.eDefNumber);

  % find digital ROI if it doesn't already exist
  if handles.di_roi_crop && (~isfield(handles,'pxl_roi') && ~strcmp(handles.acq_method,'Gas Detectors') || isempty(handles.pxl_roi))
    handles = find_roi(handles,dataList);
  end

  % abort if roi is unacceptable
  if handles.abort==0
    handles.fail=1;
    return
  end

  % take background of spontaneous radiation
  spont_bkgrnd = get(handles.SPONTBG,'Value');
  if spont_bkgrnd
    handles = spont_background(hObject, handles);
  end


  % read out data
  yag_sat = zeros(1,handles.num_shots);
  for j=1:handles.num_shots

    % crop image digitally since ROI is unavailable
    if handles.di_roi_crop && (strcmp(handles.xpp_spec,'XPP:OPAL1K:1:LiveImage') || strcmp(handles.sxr_spec,'SXR:EXS:CVV:01:IMAGE_CMPX'))
        dataList(j).img = dataList(j).img(handles.pxl_roi(1):handles.pxl_roi(2));
    elseif handles.di_roi_crop
      dataList(j) = profmon_imgCrop(dataList(j),handles.pxl_roi);
    end


    % subtract spontaneous background
    if spont_bkgrnd
      opts.doProcess=1;
      dataList(j).back=handles.spont_img;
      dataList(j).beam=profmon_process(dataList(j),opts);
      %img = img - handles.spont_img;
    else
      % medfilt image
      % dataList(j).img = util_medfilt2(dataList(j).img);
    end

    if (strcmp(handles.acq_method,'XPP Spectrometer') || strcmp(handles.acq_method,'FEE Spectrometer') || strcmp(handles.acq_method,'SXR Spectrometer')) ...
            && (strcmp(handles.xpp_spec,'XPP:OPAL1K:1:LiveImage') || strcmp(handles.fee_spec,'CAMR:FEE1:441:IMAGE_CMPX') || strcmp(handles.sxr_spec,'SXR:EXS:CVV:01:IMAGE_CMPX'))
        img = dataList(j).img;
    else
        img=util_medfilt2(double(dataList(j).img));
    end

    di_yag_data{j} = dataList(j).beam;       % analyzed yag data

    tot_pix(j) = sum(sum(img));

    % CHECK IF RAWMAX WORKING YET OR TAKE OUT !!!!!
    %maxcount = lcaGet('DIAG:FEE1:481:RawMax');
    maxcount = max(max(img));
    if maxcount > handles.di_camera_pixel_sat
        yag_sat(j) = 1;
    elseif maxcount < handles.di_camera_pixel_sat/(1.5*handles.filter_strength)
        yag_sat(j) = -1;
    else
        yag_sat(j) = 0;
        if maxcount < handles.di_camera_pixel_sat/(1.1*handles.di_filter_strength)
          handles.ncam_di_getting_low = 1;
        else
          handles.ncam_di_getting_low = 0;
        end
    end
  end
  handles.ncam_dirimg_sat = max(yag_sat);


%----------------------
% Broken LLNL crap
%----------------------

elseif handles.llnl_nightmare       % the LLNL nightmare software

  rate = lcaGetSmart('IOC:IN20:MC01:LCLSBEAMRATE');   % rep. rate % [Hz]
  if rate < 1
    rate = 1;
  end

  if ~di_bsa
      n_di_temp = zeros(handles.num_shots,8);
      w_di_temp = zeros(handles.num_shots,8);
      % TAKE OUT WHEN FEE WORKS (YEAH RIGHT!)
      for j=1:handles.num_shots
        n_di_temp(j,:) = lcaGetSmart(handles.ndir_img_pvs);
        w_di_temp(j,:) = lcaGetSmart(handles.wdir_img_pvs);
        if rate ~=0 && rate > 1
          pause(.2)
        else
          pause(1);
        end
      end
  else
      pause(handles.num_shots/rate+0.3);  % wait extra 0.3 seconds just in case...
  end



  % no yagxray inserted to saturate
  handles.yagcam_sat = 0;

  eDefOff(handles.eDefNumber);
end

% Record optical density filters on camera
OD = lcaGetSmart(handles.OD_pvs,1,'double');
di_OD = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');

% Ignore for now -- OD3 is replaced by YAGXRAY
% % flip OD(3) to match convention of 1 and 2
% if OD(3)==1
%   OD(3) = 0;
% else
%   OD(3) = 1;
% end

attens = lcaGetSmart(handles.fee_atten_pvs);

% ignore all these steps if using GDET a-synchronously
if handles.take_BSA

    % read in data from event pvs
    [readPV,pulseId]=util_readPVHst(handles.event_dat_pvs,handles.eDefNumber,1);      % orbit and tmit
    [readPV_curr]=util_readPVHst(handles.curr_pvs,handles.eDefNumber,1);              % current
    [readPV_x_eloss]=util_readPVHst(handles.eloss_xbpm_pvs,handles.eDefNumber,1);     % x eloss bpms
    [readPV_y_eloss]=util_readPVHst(handles.eloss_ybpm_pvs,handles.eDefNumber,1);     % y eloss bpms
    if di_bsa
      [readPV_n_dir_img]=util_readPVHst(handles.ndir_img_pvs,handles.eDefNumber,1);     % near direct imager
      [readPV_w_dir_img]=util_readPVHst(handles.wdir_img_pvs,handles.eDefNumber,1);     % wide direct imager
    end
    [readPV_gdet]=util_readPVHst(handles.gdet_pvs,handles.eDefNumber,1);              % gas detector
    if strcmp(handles.acq_method,'K-Mono')
        [readPV_kmono]=util_readPVHst(handles.kmono_pvs,handles.eDefNumber,1);              % gas detector
    end
    %[readPV_tedet]=util_readPVHst(handles.gdet_pvs,handles.eDefNumber,1);              % total energy detector

    rate=mode(diff(pulseId,1,2),2);
    if isnan(rate)
      rate=1;
    end



    % Use handles.yag_tag == 10 when pulseId not working
    %if handles.yag_tag == 10
    if (handles.yag_tag || use_henrik) && ~strcmp(handles.acq_method,'Gas Detectors')
      % compare pulse IDs to match up event data with yag xray data (since
      % yagxray is not synchronous)
      use=zeros(numel(dataList),1);
      for j=1:handles.num_shots
          idx=find(dataList(j).pulseId >= pulseId);
          [d,id]=min(double(dataList(j).pulseId)-pulseId(idx));
          if isempty(idx), idx=1;id=1;end
          use(j)=idx(id);
      end
    else
      use = 1:handles.num_shots;    % if using DI acquisition (BSA broken), just use first 'handles.numshots' shots
    end

    % raw = 1, roi = 2;  For now hardcoded -- maybe make an option later if DI ever works?
    raw_or_roi = 1;

    % save event data from pulse IDs that matched
    for j=1:handles.num_shots
        % tolerance data (current, orbit and tmit)
        if numel(readPV_curr.val)>use(j)
            curr(j)=readPV_curr.val(use(j));
        else
            curr(j)=0;
        end
        for k=1:size(readPV,1)
            tsList=(1-length(readPV(k).val):0)/24/60/60/360*rate+readPV(k).ts;
            synch_val(j,k)=readPV(k).val(use(j));
            synch_ts(j,k)=tsList(use(j));
        end

        % bpms for eloss
        for k=1:size(readPV_x_eloss,1)
            x_eloss(j,k)=readPV_x_eloss(k).val(use(j));
            y_eloss(j,k)=readPV_y_eloss(k).val(use(j));
        end


        % gas detector
        % FINISH FINISH FINISH
        for k=1:2
            gdet1(j,k)=readPV_gdet(k).val(use(j)) - handles.gdet1_offset(k);
            gdet2(j,k)=readPV_gdet(k+2).val(use(j)) - handles.gdet2_offset(k);
        end

        if strcmp(handles.acq_method,'K-Mono')
            kmono(j)=readPV_kmono.val(use(j));              % gas detector
        end


    %     % total energy detector
    %     for k=1:size(readPV_tedet,1)
    %         tedet(j,k)=readPV_tedet(k).val(use(j));
    %     end

        % direct imager, saturation and power data
        if di_bsa
          for k=1:size(readPV_n_dir_img,1)
              n_di_temp(j,k)=readPV_n_dir_img(k).val(use(j));
              w_di_temp(j,k)=readPV_w_dir_img(k).val(use(j));
          end
        end
    end

    % break data into x_orbit, y_orbit and tmit (energy comes from orbits)
    for j=1:3:size(synch_val,2)
      synch_x(:,(j+2)/3) = synch_val(:,j);
      synch_y(:,(j+2)/3) = synch_val(:,j+1);
      synch_tmit(:,(j+2)/3) = synch_val(:,j+2);
    end

    tmit = synch_tmit(:,1);
    dl2_pos = synch_x(:,1:2);

    % don't compare data past corrector kick  (check these numbers?  fencepost correct?)
    if handles.kicked_mag > 0
      last = size(synch_x,2) - (handles.und_num-handles.kicked_mag);
    else
      last = size(synch_x,2);
    end




    x_orbit = synch_x(:,3:last);
    y_orbit = synch_x(:,3:last);

    orbit = [x_orbit; y_orbit];


    % energy difference
    delta_e = (dl2_pos(:,1)/handles.dl2_eta(1)+dl2_pos(:,2)/handles.dl2_eta(2))/2;


    % take maximum orbit (instead of fitting)
    xorb_max = max(abs(x_orbit),[],2);
    yorb_max = max(abs(y_orbit),[],2);


    if handles.yag_tag || use_henrik
      n_di_temp = zeros(handles.num_shots,8);
      w_di_temp = zeros(handles.num_shots,8);
    end

    % parse out direct imager data
    temp_dir = n_di_temp;
    ncam_dirimg_sat = temp_dir(:,raw_or_roi);
    n_dir_img.power = temp_dir(:,4);
    n_dir_img.x = temp_dir(:,5);
    n_dir_img.y = temp_dir(:,6);
    n_dir_img.xrms = temp_dir(:,7);
    n_dir_img.yrms = temp_dir(:,8);

    temp_dir = w_di_temp;
    wcam_dirimg_sat = temp_dir(:,raw_or_roi);
    w_dir_img.power = temp_dir(:,4);
    w_dir_img.x = temp_dir(:,5);
    w_dir_img.y = temp_dir(:,6);
    w_dir_img.xrms = temp_dir(:,7);
    w_dir_img.yrms = temp_dir(:,8);



    % check saturation of camera for direct image software
    if ~handles.yag_tag && ~use_henrik

      % Check for direct imager camera saturation
      nmax = max(ncam_dirimg_sat);
      wmax = max(wcam_dirimg_sat);

      % check near FOV
      if nmax > handles.di_camera_pixel_sat
        handles.ncam_dirimg_sat = 1;
      elseif nmax < handles.di_camera_pixel_sat/(1.5*handles.filter_strength)
        handles.ncam_dirimg_sat = -1;
      else
        handles.ncam_dirimg_sat = 0;
        if nmax < handles.di_camera_pixel_sat/(1.1*handles.di_filter_strength)
          handles.ncam_di_getting_low = 1;
        else
          handles.ncam_di_getting_low = 0;
        end
      end

      % check wide FOV
      if wmax > handles.camera_pixel_sat
        handles.wcam_dirimg_sat = 1;
      elseif wmax < handles.camera_pixel_sat/(1.5*handles.filter_strength)
        handles.wcam_dirimg_sat = -1;
      else
        handles.wcam_dirimg_sat = 0;
        if wmax < handles.di_camera_pixel_sat/(1.1*handles.di_filter_strength)
          handles.wcam_di_getting_low = 1;
        else
          handles.wcam_di_getting_low = 0;
        end
      end
    end


    % check direct imager YAG saturation by total power level
    if ~handles.yag_tag

      power_level = mean(gdet1)*attens(1)*attens(2);

      if power_level >= handles.dirimg_max
          handles.dirimg_sat = 1;
      elseif power_level < handles.dirimg_max/handles.dicutoff_low
          handles.dirimg_sat = -1;
      else
          handles.dirimg_sat = 0;
          if power_level < handles.dirimg_max/handles.dicutoff_getting_low
            handles.diyag_getting_low = 1;
          else
            handles.diyag_getting_low = 0;
          end
      end

    end

end

if handles.take_BSA
    outstruc.yag_data = yag_data;
    outstruc.yag_tot_pix = tot_pix;
    outstruc.di_data = di_yag_data;
    outstruc.tmit = tmit;
    outstruc.delta_e = delta_e;
    outstruc.xorb_max = xorb_max;
    outstruc.yorb_max = yorb_max;
    outstruc.orbit = orbit;
    outstruc.OD = OD;
    outstruc.di_OD = di_OD;
    outstruc.attens = attens;
    outstruc.n_dir_img = n_dir_img;
    outstruc.w_dir_img = w_dir_img;
    outstruc.tot_energy = tedet;
end

% variables for ELoss
%outstruc.x_eloss = x_eloss;
%outstruc.y_eloss = y_eloss;
%outstruc.curr = curr;
outstruc.gdet1 = gdet1;
outstruc.gdet2 = gdet2;
outstruc.kmono = kmono;

guidata(hObject,handles);




%%
function [handles,outstruc] = CheckTol_ParseData(handles,hObject,entry)
% Parse data and filter synchronously

handles.tol_status = get(handles.FILTER,'Value');



detector_list = get(handles.DETECTOR,'String');
det_numb = get(handles.DETECTOR,'Value');
detector = detector_list(det_numb);

eloss = [];
xpos = [];

% Check for old versions of data
if  isfield(handles.data,'raw_data')
  raw_pwr = handles.data(entry).raw_data;
  eloss = zeros(size(raw_pwr));
  if ~isfield(handles.data,'OD')
    OD = [0 0 0];
  else
    OD = handles.data(entry).OD;
  end
  if ~any(strcmp(detector,{'YAGXRAY Henrik'; 'ELoss (e-)'}))
    set(handles.DETECTOR,'Value',1);
    detector = 'YAGXRAY Henrik';
  end
elseif isfield(handles.data,'raw_pwr')
  raw_pwr = handles.data(entry).raw_pwr;
  xpos = handles.data(entry).raw_x;
  ypos = handles.data(entry).raw_y;
  xrms = handles.data(entry).raw_xrms;
  yrms = handles.data(entry).raw_yrms;
  OD = handles.data(entry).OD;
  if ~any(strcmp(detector,{'YAGXRAY Henrik'; 'ELoss (e-)'}))
    set(handles.DETECTOR,'Value',1);
    detector = 'YAGXRAY Henrik';
  end
elseif strcmp(detector,'YAGXRAY Henrik')
  % read profmon analysis method of choice
  prof_meth = get(handles.PROFMON_METHOD,'Value');
  mydat = handles.data(entry).raw_yag;
  % check for null data
  for j=1:length(mydat)
    tempdat = mydat{j};
    if isfield(tempdat(1),'stats')
        if prof_meth == 8                   % use total pixel count
            raw_pwr(j) = handles.data(entry).yag_tot_pix(j);
            xpos(j) = 0;
            ypos(j) = 0;
            xrms(j) = 0;
            yrms(j) = 0;
        else
            mystats = tempdat(prof_meth).stats;
            xpos(j) = mystats(1);
            ypos(j) = mystats(2);
            xrms(j) = mystats(3);
            yrms(j) = mystats(4);
            raw_pwr(j) = mystats(6);
        end
    else
        xpos(j) = 0;
        ypos(j) = 0;
        xrms(j) = 0;
        yrms(j) = 0;
        raw_pwr(j) = 0;
    end

  end
  OD = handles.data(entry).OD;
elseif strcmp(detector,'Dir Img Henrik') || strcmp(detector,'Spectrometer')
  % read profmon analysis method of choice
  prof_meth = get(handles.PROFMON_METHOD,'Value');
  mydat = handles.data(entry).di_raw_yag;
  % check for null data
  for j=1:length(mydat)
    tempdat = mydat{j};
    if isfield(tempdat(1),'stats')
        if prof_meth == 8                   % use total pixel count
            raw_pwr(j) = handles.data(entry).yag_tot_pix(j);
            xpos(j) = 0;
            ypos(j) = 0;
            xrms(j) = 0;
            yrms(j) = 0;
        else
            mystats = tempdat(prof_meth).stats;
            xpos(j) = mystats(1);
            ypos(j) = mystats(2);
            xrms(j) = mystats(3);
            yrms(j) = mystats(4);
            raw_pwr(j) = mystats(6);
        end
    else
        xpos(j) = 0;
        ypos(j) = 0;
        xrms(j) = 0;
        yrms(j) = 0;
        raw_pwr(j) = 0;
    end


  end
  di_OD = handles.data(entry).di_OD;
  total_trans = handles.data(entry).attens(1)*handles.data(entry).attens(2);  % total attenuator transmission factor
elseif strcmp(detector, 'Dir Img Near')
  raw_pwr = handles.data(entry).n_dir_img.power;
  xpos = handles.data(entry).n_dir_img.x;
  ypos = handles.data(entry).n_dir_img.y;
  xrms = handles.data(entry).n_dir_img.xrms;
  yrms = handles.data(entry).n_dir_img.yrms;
  di_OD = handles.data(entry).di_OD;
  total_trans = handles.data(entry).attens(1)*handles.data(entry).attens(2);
elseif strcmp(detector, 'Dir Img Wide')
  raw_pwr = handles.data(entry).w_dir_img.power;
  xpos = handles.data(entry).w_dir_img.x;
  ypos = handles.data(entry).w_dir_img.y;
  xrms = handles.data(entry).w_dir_img.xrms;
  yrms = handles.data(entry).w_dir_img.yrms;
elseif strcmp(detector, 'Gas Det1')
  gdet1 = handles.data(entry).gdet1;
  raw_pwr = mean(gdet1,2);
  total_trans=1;
elseif strcmp(detector, 'Gas Det2')
  gdet2 = handles.data(entry).gdet2;
  raw_pwr = mean(gdet2,2);
  total_trans = handles.data(entry).attens(1)*handles.data(entry).attens(2);
elseif strcmp(detector, 'Gas Det Both')
  gdet1 = handles.data(entry).gdet1;
  gdet2 = handles.data(entry).gdet2;
  % for low pulse energies (lower gdet2_cal) use gdet2
  if handles.data(entry).gdet2_cal<max(vertcat(handles.data.gdet2_cal))
      gdetboth=gdet2;
      total_trans = handles.data(entry).attens(1)*handles.data(entry).attens(2);
  else % otherwise use gdet1
      gdetboth=gdet1;
      total_trans=1;
  end
  raw_pwr = mean(gdetboth,2);

elseif strcmp(detector, 'Total Energy')
  tedet = handles.data(entry).tot_energy;
  raw_pwr = mean(tedet,2);
  total_trans = handles.data(entry).attens(1)*handles.data(entry).attens(2);
elseif strcmp(detector, 'ELoss (e-)')
  eloss = handles.data(entry).raw_eloss;
  raw_pwr = eloss;
elseif strcmp(detector, 'K-Mono')
  kmono = handles.data(entry).kmono;
  raw_pwr = mean(kmono);
  total_trans=1;
end

if isempty(eloss)
  eloss = handles.data(entry).raw_eloss;
end

if isempty(xpos)
  xpos = zeros(size(raw_pwr));
  ypos = zeros(size(raw_pwr));
  xrms = zeros(size(raw_pwr));
  yrms = zeros(size(raw_pwr));
end



% Account for camera filters and attenuators
if strcmp(detector,'YAGXRAY Henrik')
  if any(~isfinite(OD))
    errordlg('Cannot read YAGXRAY OD filter status','OD error');
  end

  if length(OD) < 3;
    OD(3) = 0;
  end
  OD_val1 = str2num(get(handles.ODFILTER1,'String'));
  OD_val2 = str2num(get(handles.ODFILTER2,'String'));
  Ni_val = str2num(get(handles.NIFOIL,'String'));

  raw_pwr = raw_pwr*OD_val1^OD(1)*OD_val2^(OD(2))*Ni_val^(OD(3));
  filter_stat = OD(1)+2*OD(2);
elseif strcmp(detector,'Dir Img Henrik') || strcmp(detector,'Spectrometer')
  if any(~isfinite(di_OD)) && ~handles.yag_tag && handles.use_yag
    errordlg('Cannot read Direct Imager OD filter status','di_OD error');
  end

  raw_pwr = raw_pwr*handles.di_filter_strength^(di_OD(1))/total_trans;
  log_trans = -log(total_trans+eps);
  if log_trans > 3; log_trans = 3; end;
  filter_stat = 3-log_trans;
  %filter_stat = 3;
elseif strcmp(detector,'Dir Img Near')
  if any(~isfinite(di_OD)) && ~handles.yag_tag && handles.use_yag
    errordlg('Cannot read Direct Imager OD filter status','di_OD error');
  end

  raw_pwr = raw_pwr*handles.di_filter_strength^(di_OD(1));
  log_trans = -log(total_trans+eps);
  if log_trans > 3; log_trans = 3; end;
  filter_stat = 3-log_trans;
  %filter_stat = 3;
elseif any(strcmp(detector,{'Gas Det2';'Gas Det Both'; 'Total Energy'}))

  if isfield(handles.data,'gdet2_cal')
      raw_pwr = raw_pwr*handles.data(entry).gdet2_cal;
  else
      raw_pwr = raw_pwr/total_trans;
  end

  log_trans = -log(total_trans+eps);
  if log_trans > 3; log_trans = 3; end;
  filter_stat = 3-log_trans;
else
  filter_stat = 3;
end

num_shots = length(raw_pwr);






% Look for bad pulses outside the tolerance
if handles.tol_status && handles.online
    tmit = handles.data(entry).tmit;
    delta_e = handles.data(entry).delta_e;
    curr = handles.data(entry).curr;

    % Account for bug in orbit calculation
    if isfield(handles.data,'xorb_max')
      if length(handles.data(entry).xorb_max) ~= length(tmit)
        x = handles.data(entry).raw_orbit(1:30,:);
        y = handles.data(entry).raw_orbit(31:60,:);
        xorb_max = max(x,[],2);
        yorb_max = max(y,[],2);
      else
        xorb_max = handles.data(entry).xorb_max;
        yorb_max = handles.data(entry).yorb_max;
      end
    else
      xorb_max = zeros(size(tmit));
      yorb_max = zeros(size(tmit));
    end

    % calculate average angular orbit jitter in urad;
    %d=x-circshift(x,[-1 0]); a=d/3.4; mean(std(a,[],2))*1e3

    handles.sig_tmit = str2num(get(handles.SIGTMIT,'String'));
    handles.sig_energy = str2num(get(handles.SIGENERGY,'String'));
    handles.sig_curr = str2num(get(handles.SIGCURR,'String'));
    handles.sig_orbit = str2num(get(handles.SIGORBIT,'String'));

    % Check tol for tmit, energy, and orbit
    nval = length(tmit);
    handles.within_tol =ones(nval,1);

%     if ~isfield(handles,'ref_tmit')
%       handles.ref_tmit = mean(tmit);
%     end
%     if ~isfield(handles,'ref_curr')
%       handles.ref_curr = mean(curr);
%     end
    handles.ref_tmit=median(tmit);
    handles.ref_curr=median(curr);
    handles.ref_e=median(delta_e);
    if length(delta_e)<nval
      delta_e = ones(1,nval)*delta_e(1);
    end
    for j=1:nval;
      if abs(tmit(j)-handles.ref_tmit)/handles.ref_tmit > handles.sig_tmit
        handles.within_tol(j) = 0;
        %set(handles.STATUS,'String','Bad charge, skipping pulse');
        %drawnow
      elseif abs(delta_e(j)-handles.ref_e) > handles.sig_energy
        handles.within_tol(j) = 0;
        %set(handles.STATUS,'String','Bad energy, skipping pulse');
        %drawnow
      elseif abs(curr(j)-handles.ref_curr)/handles.ref_curr > handles.sig_curr
        handles.within_tol(j) = 0;
        %set(handles.STATUS,'String','Bad energy, skipping pulse');
        %drawnow
      elseif max([xorb_max(j) yorb_max(j)]) > handles.sig_orbit/1000
        handles.within_tol(j) = 0;
        %set(handles.STATUS,'String','Bad orbit, skipping pulse');
        %drawnow
      end
    end

    % fraction within tol
    handles.good_fraction = sum(handles.within_tol)/num_shots;
    if handles.good_fraction < 1/2
      set(handles.STATUS,'String','Poor stability: throwing out most points'); drawnow;
    end

else
    handles.good_fraction = 1;
    handles.within_tol = 1:num_shots;
end


% list of good shots
j=1;
power_hist = 0;
xrms_hist = 0;
yrms_hist = 0;
xpos_hist = 0;
ypos_hist = 0;
eloss_hist = 0;
for p=1:num_shots
  if handles.within_tol(p)
    power_hist(j) = raw_pwr(p);
    xrms_hist(j) = xrms(p);
    yrms_hist(j) = yrms(p);
    xpos_hist(j) = xpos(p);
    ypos_hist(j) = ypos(p);
    eloss_hist(j) = eloss(p);
    j=j+1;
  end
end

outstruc.avg_power = mean(power_hist);
outstruc.peak_power = max(power_hist);
outstruc.rms_power = std(power_hist);
outstruc.xrms = mean(xrms_hist);
outstruc.yrms = mean(yrms_hist);
outstruc.xrms_rms = std(xrms_hist);
outstruc.yrms_rms = std(yrms_hist);
outstruc.xpos = mean(xpos_hist);
outstruc.ypos = mean(ypos_hist);
outstruc.xpos_rms = std(xpos_hist);
outstruc.ypos_rms = std(ypos_hist);
outstruc.power_hist = power_hist;
outstruc.eloss = mean(eloss_hist);
outstruc.eloss_rms = std(eloss_hist);
outstruc.filter_stat  = filter_stat;


%%
function JSet = Fit_Setup(BPM_pvs, hObject, handles)
% Setup for fitting orbit (not used unless orbit fitting turned back on)

JSet.ifit = [1 1 1 1 0];                     % fit x0, x0', y0, y0'
gex  = 1.2E-6;
gey  = 1.2E-6;
mc2  = 511E-6;

%BPM_pvs = BPM_pvs(3:end);

nbpms = length(BPM_pvs);
BPM_micrs = zeros(nbpms,4);
BPM_units = zeros(nbpms,1);
energy = zeros(nbpms,1);
betax  = zeros(nbpms,1);
alfax  = zeros(nbpms,1);
betay  = zeros(nbpms,1);
alfay  = zeros(nbpms,1);
etax   = zeros(nbpms,1);



global modelSource;

if isempty(strfind(BPM_pvs{1},'LTU')) && isempty(strfind(BPM_pvs{1},'UND'))
    modelSource='SLC';
else
    modelSource='EPICS';
end

for j = 1:nbpms
  BPM_SLC_name = model_nameConvert(BPM_pvs{j},'SLC');
  BPM_micrs(j,:) = BPM_SLC_name(6:9);
  BPM_units(j)   = str2int(BPM_SLC_name(11:end));
  try
    %twiss2 = aidaget([BPM_SLC_name ':twiss'],'doublea',{'TYPE=DATABASE'});
    twiss = model_rMatGet(BPM_pvs{j},[],'TYPE=DESIGN','twiss');
  catch
    disp(['You have angered the EPICS Gods by asking for twiss params from ',BPM_pvs{j}]);
  end
  %twiss = cell2mat(twiss);
  energy(j) = twiss(1,:);
  betax(j)  = twiss(3,:);
  alfax(j)  = twiss(4,:);
  betay(j)  = twiss(8,:);
  alfay(j)  = twiss(9,:);
  etax(j)   = twiss(5,:);
end


r=model_rMatGet(BPM_pvs{end},BPM_pvs);
JSet.R1s = permute(r(1,[1 2 3 4 6],:),[3 2 1]);
JSet.R3s = permute(r(3,[1 2 3 4 6],:),[3 2 1]);


JSet.ex = gex*mc2/energy(end);
JSet.ey = gey*mc2/energy(end);
JSet.bx = betax(end);
JSet.by = betay(end);
JSet.ax = alfax(end);
JSet.ay = alfay(end);

guidata(hObject, handles);

%%
function [uvx,uvy] = Fit_Orbit(handles,Xs,Ys,JSet)
% Fit orbit (from JitterGui)

[Nsamp,nbpms] = size(Xs);

R1s = JSet.R1s;
R3s = JSet.R3s;
%Zs = JSet.Zs;
%Zs0 = JSet.Zs0;
ifit = JSet.ifit;
ex = JSet.ex;
ey = JSet.ey;
bx = JSet.bx;
by = JSet.by;
ax = JSet.ax;
ay = JSet.ay;



Xsf  = zeros(Nsamp,nbpms);
Ysf  = zeros(Nsamp,nbpms);
ps   = zeros(Nsamp,sum(ifit));
dps  = zeros(Nsamp,sum(ifit));
dps12= zeros(Nsamp,1);
dps34= zeros(Nsamp,1);


% tstr = get_time;

Xs0 = mean(Xs);
Ys0 = mean(Ys);

dXs = Xs - ones(Nsamp,1)*Xs0;
dYs = Ys - ones(Nsamp,1)*Ys0;



for j = 1:Nsamp
    [Xf,Yf,p,dp,chisq,Q,Vv] = ...
      xy_traj_fit(dXs(j,:),1,dYs(j,:),1,0*dXs(j,:),0*dYs(j,:),R1s,R3s,ifit);	% fit trajectory
    Xsf(j,:) = Xf;
    Ysf(j,:) = Yf;
    ps(j,:)  = p;
    dps(j,:) = dp;
    V = reshape(Vv,sum(ifit),sum(ifit));
    dps12(j,:) = V(1,2);
    dps34(j,:) = V(3,4);
end





ii = 1:Nsamp;
iQx = [1 0; ax bx]/sqrt(ex*bx);
uvx = 1E-3*iQx*[ps(ii,1)'; ps(ii,2)'];
dux = 1E-3*dps(ii,1)/sqrt(ex*bx);
dvx = 1E-3*sqrt(( ax^2*dps(ii,1).^2 + bx^2*dps(ii,2).^2 + ax*bx*dps12(ii) ))/sqrt(ex*bx);


rx = sqrt(uvx(1,:).^2 + uvx(2,:).^2);





iQy = [1 0; ay by]/sqrt(ey*by);
uvy = 1E-3*iQy*[ps(ii,3)'; ps(ii,4)'];
duy = 1E-3*dps(ii,3)/sqrt(ey*by);
dvy = 1E-3*sqrt(( ay^2*dps(ii,3).^2 + by^2*dps(ii,4).^2 + ay*by*dps34(ii) ))/sqrt(ey*by);

ry = sqrt(uvy(1,:).^2 + uvy(2,:).^2);


Xstd = std(rx);
Ystd = std(ry);




function CUTOFFHIGH_Callback(hObject, eventdata, handles)
% hObject    handle to CUTOFFHIGH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = AnalyzeMeas(hObject,  eventdata, handles);

%set(handles.STATUS,'String','Ready');

guidata(hObject, handles);


% Hints: get(hObject,'String') returns contents of CUTOFFHIGH as text
%        str2double(get(hObject,'String')) returns contents of CUTOFFHIGH as a double


% --- Executes during object creation, after setting all properties.
function CUTOFFHIGH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CUTOFFHIGH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function handles = TakeReference(hObject,eventdata, handles)

fail = handles.fail;

% % reference charge
% handles.ref_tmit = lcaGetSmart(handles.event_tmit_pvs{end});
% while ~isfinite(handles.ref_tmit) || handles.ref_tmit < handles.min_charge
%   set(handles.STATUS,'String','No charge: waiting for beam');
%   disp('NoCharge: waiting for beam');
%   pause(1)
%   handles.ref_tmit = lcaGetSmart(handles.event_tmit_pvs{end});
%
%   % If abort called end program
%   handles.abort = get(hObject,'Value');
%   if handles.abort == 0
%     fail = 1;
%     break;
%   end
% end
%
% % Take reference orbit
% accept = 'Retake';
% xpos = zeros(size(handles.event_x_pvs));
% ypos = zeros(size(handles.event_y_pvs));
% if handles.kicked_mag > 0
%   last = length(xpos) - (handles.und_num-handles.kicked_mag);
% else
%   last = length(xpos);
% end
% while strcmp(accept,'Retake') && ~fail
%   handles.JSet = Fit_Setup(handles.event_pvs(3:last), hObject, handles);    % setup for fitting orbits
%   xpos = lcaGetSmart(handles.event_x_pvs)';
%   ypos = lcaGetSmart(handles.event_y_pvs)';
%
%   % reference charge
%   handles.ref_tmit = lcaGetSmart(handles.event_tmit_pvs{end});
%
%   % Reference energy
%   dl2_pos = xpos(1:2);
%   delta_e = (dl2_pos(1)/handles.dl2_eta(1)+dl2_pos(2)/handles.dl2_eta(2))/2;
%   handles.ref_energy = delta_e;
%
%   % Reference current
%   handles.ref_curr = lcaGetSmart(handles.curr_pvs);
%
%   [handles.ref_xlaunch,handles.ref_ylaunch] = Fit_Orbit(handles,xpos(3:last),ypos(3:last),handles.JSet);
%   figure(100);
%   subplot(2,1,1),stem(xpos(3:end));ylabel('x(mm)');xlabel('BPM');
%   subplot(2,1,2),stem(ypos(3:end));ylabel('y(mm)');xlabel('BPM');
%
%   mycharge = ExpFormat(handles.ref_tmit,3);
%   mycurr = ExpFormat(handles.ref_curr,3);
%   subplot(2,1,1);title(['Charge=' mycharge ' Current=' mycurr]);
%
%   % Prompt user to OK reference orbit
%   % Plot orbit
%   accept = questdlg('Reference orbit OK?','Reference Orbit','Accept','Retake','Accept');
%
%   % Check for beam again
%   check_beam = lcaGetSmart(handles.event_tmit_pvs{end});
%   while ~isfinite(check_beam) || check_beam < handles.min_charge
%     set(handles.STATUS,'String','No charge: waiting for beam');
%     disp('NoCharge: waiting for beam');
%     pause(1)
%     check_beam = lcaGetSmart(handles.event_tmit_pvs{end});
%     % If abort called end program
%     handles.abort = get(hObject,'Value');
%     if handles.abort == 0
%       fail = 1;
%       break;
%     end
%   end
% end

% instead of taking reference orbit, assume reference orbit is 0.
handles.ref_xlaunch=[0;0];
handles.ref_ylaunch=[0;0];

% read references from soft pvs
handles.ref_curr = lcaGetSmart(handles.curr_softpvs);
handles.ref_energy = lcaGetSmart(handles.energy_pvs);
handles.ref_tmit = lcaGetSmart(handles.tmit_softpvs)*handles.nC_to_ne;

% check if failed
handles.fail = fail;



function SIGTMIT_Callback(hObject, eventdata, handles)
% hObject    handle to SIGTMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of SIGTMIT as text
%        str2double(get(hObject,'String')) returns contents of SIGTMIT as a double


% --- Executes during object creation, after setting all properties.
function SIGTMIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGTMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SIGENERGY_Callback(hObject, eventdata, handles)
% hObject    handle to SIGENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of SIGENERGY as text
%        str2double(get(hObject,'String')) returns contents of SIGENERGY as a double


% --- Executes during object creation, after setting all properties.
function SIGENERGY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SIGCURR_Callback(hObject, eventdata, handles)
% hObject    handle to SIGCURR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of SIGCURR as text
%        str2double(get(hObject,'String')) returns contents of SIGCURR as a double


% --- Executes during object creation, after setting all properties.
function SIGCURR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGCURR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function GOODFRAC_Callback(hObject, eventdata, handles)
% hObject    handle to GOODFRAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GOODFRAC as text
%        str2double(get(hObject,'String')) returns contents of GOODFRAC as a double


% --- Executes during object creation, after setting all properties.
function GOODFRAC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GOODFRAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function SIGORBIT_Callback(hObject, eventdata, handles)
% hObject    handle to SIGORBIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of SIGORBIT as text
%        str2double(get(hObject,'String')) returns contents of SIGORBIT as a double


% --- Executes during object creation, after setting all properties.
function SIGORBIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGORBIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in FILTER.
function FILTER_Callback(hObject, eventdata, handles)
% hObject    handle to FILTER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% check if there was any BSA
if isfield(handles,'take_BSA') && ~handles.take_BSA && handles.FILTER
    set(handles.FILTER,'Value',0);
    set(handles.STATUS,'String','No BSA available for this run');
    return
end

handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of FILTER





function CHISQ_Callback(hObject, eventdata, handles)
% hObject    handle to CHISQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CHISQ as text
%        str2double(get(hObject,'String')) returns contents of CHISQ as a double


% --- Executes during object creation, after setting all properties.
function CHISQ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CHISQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function CUTOFFLOW_Callback(hObject, eventdata, handles)
% hObject    handle to CUTOFFLOW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of CUTOFFLOW as text
%        str2double(get(hObject,'String')) returns contents of CUTOFFLOW as a double


% --- Executes during object creation, after setting all properties.
function CUTOFFLOW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CUTOFFLOW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ODFILTER2_Callback(hObject, eventdata, handles)
% hObject    handle to ODFILTER2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of ODFILTER2 as text
%        str2double(get(hObject,'String')) returns contents of ODFILTER2 as a double


% --- Executes during object creation, after setting all properties.
function ODFILTER2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ODFILTER2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function ODFILTER1_Callback(hObject, eventdata, handles)
% hObject    handle to ODFILTER1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of ODFILTER1 as text
%        str2double(get(hObject,'String')) returns contents of ODFILTER1 as a double


% --- Executes during object creation, after setting all properties.
function ODFILTER1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ODFILTER1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function NIFOIL_Callback(hObject, eventdata, handles)
% hObject    handle to NIFOIL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

set(handles.STATUS,'String','Ready'); drawnow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of NIFOIL as text
%        str2double(get(hObject,'String')) returns contents of NIFOIL as a double


% --- Executes during object creation, after setting all properties.
function NIFOIL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NIFOIL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in DATATYPE.
function DATATYPE_Callback(hObject, eventdata, handles)
% hObject    handle to DATATYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Analyze and plot data

% read chosen data type
data_type = get(handles.DATATYPE,'String');
curr_type = get(handles.DATATYPE,'Value');

if strfind(data_type{curr_type},'Power')
  set(handles.LOGSCALE,'Value',1);
else
  set(handles.LOGSCALE,'Value',0);
end

handles = AnalyzeMeas(hObject,  eventdata, handles);

% set(handles.STATUS,'String','Ready');

guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns DATATYPE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DATATYPE


% --- Executes during object creation, after setting all properties.
function DATATYPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DATATYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in LOAD.
function LOAD_Callback(hObject, eventdata, handles)
% hObject    handle to LOAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = dataOpen(hObject, handles);

if isfield(handles.data,'use_gdet') && handles.data(1).use_gdet
    set(handles.DETECTOR,'Value',5)
elseif isfield(handles.data,'use_kmono') && handles.data(1).use_kmono
    set(handles.DETECTOR,'Value',8)
elseif ~isfield(handles.data, 'di_raw_yag') || ~isfield(handles.data(1).di_raw_yag{1},'stats')
    set(handles.DETECTOR,'Value',5)
elseif isfield(handles.data,'use_xpp_spec') && handles.data(1).use_xpp_spec
    set(handles.DETECTOR,'Value',7)
elseif isfield(handles.data,'use_sxr_spec') && handles.data(1).use_sxr_spec
    set(handles.DETECTOR,'Value',7)
elseif isfield(handles.data,'use_spec') && handles.data(1).use_spec
    set(handles.DETECTOR,'Value',7)
else
    set(handles.DETECTOR,'Value',2)
end



% Analyze and plot data
handles = AnalyzeMeas(hObject,eventdata, handles);


% Guess best range for fitting gain length
GuessGLRange(handles);

% Replot data with best guess
handles = AnalyzeMeas(hObject,eventdata, handles);

guidata(hObject,handles);

% -----------------------------------------------------------
function handles = dataOpen(hObject, handles)


[data,file_name]=util_dataLoad('Open image file');

if ~ischar(file_name), return, end

handles.data=data;
handles.saved_data=1;
handles.file_name = file_name;

guidata(hObject,handles);


% Guesses proper range for fitting gain length
function GuessGLRange(handles)

%return

if ~isfield(handles.data,'pos')
    set(handles.CUTOFFLOW,'String',num2str(33));
    set(handles.CUTOFFHIGH,'String',num2str(33));
    return;
end

z = vertcat(handles.data.pos);
p = vertcat(handles.data.plot_power);
n = length(p);

dat = [z p];
dat = sortrows(dat,1);

z = dat(:,1);
p = dat(:,2);

if n < 3
  return
end

% fudge so it doesn't die on the next line...
if isempty(p(p>0))
    return
end

%z1 = find(p<min(p(p>0))*5,1,'last')+1;
z1 = find(p==min(p));
z2 = find(p>max(p)/5,1,'first');

if p(z1)<0
    z1=z1+1;
end

if isempty(z1)
  z1 = 1;
end

if isempty(z2)
  z2 = n;
end


if z2 < 2
  z2 = 2;
end

if z1 >= z2
  z1 = z2-1;
end

u1 = round(z(z1)/handles.und_length);
u2 = round(z(z2)/handles.und_length);


% Don't let guess go around HXRSS chicane
if (u1==15 || u1==16) && u2>17
    u1=17;
elseif u1<15 && u2>15
    u2=15;
end

% Don't let guess go around SXRSS chicane
if u2>13 && u1 < 10
    u1=10;
elseif(u1==8 || u1==9) && u2>10
    u1=10;
elseif u1<8 && u2>8
    u2=8;
end


set(handles.CUTOFFLOW,'String',num2str(u1));
set(handles.CUTOFFHIGH,'String',num2str(u2));





function OUT_struc = DL2toDumpEnergyLoss_GL(handles,IN_struc)

%   function OUT_struc = DL2toDumpEnergyLoss(IN_struc);
%
%   Function to measure the energy loss between DL2 and the dump.  It
%   gets the model (Henrik's Matlab model), the present beam energy, and a
%   new reference orbit only when IN_struc.initialize = 1, otherwise these
%   parameters are persistent.  The returned energy loss is in MeV and
%   moves in the positive direction when the energy in the dump is lower
%   (loss is higher), and has a persistent arbitrary offset. The arbitrary
%   offset is reset when IN_struc.initialize =1.
%
%   INPUTS:     IN_struc.initialize:    If =1, gets model and beam energy
%               IN_struc.navg:          Number of shots to average per call
%               IN_struc.Loss_per_Ipk:  Slope of E-loss per BC2 Ipk (MeV/A)
%
%   OUTPUTS:    OUT_struc.dE:           The energy loss from DL2 to Dump (MeV)
%               OUT_struc.ddE:          The energy loss error bar (MeV)
%               OUT_struc.Ipk:          The BC2 peak current (A)

%==========================================================================

if ~handles.online
  OUT_struc = IN_struc;
  return
end

persistent static_data
global modelSource modelOnline

X = IN_struc.x;
Y = IN_struc.y;
Ipk = IN_struc.ipk;

init = IN_struc.initialize;             % if = 1, get model
navg = IN_struc.navg;                   % beam shots to average
Loss_per_Ipk = IN_struc.Loss_per_Ipk;   % MeV of wake-loss per Ampere of BC2 Ipk (MeV/A)
%Loss_per_Ipk= 1.43E-2;                 % MeV of wake-loss per Ampere of BC2 Ipk (MeV/A at 0.25 nC)

BPM_pvs = {'BPMS:LTU0:190'
           'BPMS:LTU1:250'
           'BPMS:LTU1:450'
           'BPMS:DMP1:299'
           'BPMS:DMP1:381'
           'BPMS:DMP1:398'
           'BPMS:DMP1:502'
           'BPMS:DMP1:693'
                          };
idl2 = 1:3;
idmp = 4:8;
rate = lcaGetSmart('IOC:IN20:MC01:LCLSBEAMRATE');   % rep. rate % [Hz]
if rate < 1
  rate = 1;
end

if init
  modelSource='EPICS';modelOnline=0;

  static_data.E0 = lcaGetSmart('BEND:DMP1:400:BDES');       % beam energy in the undulator [GeV]

  Rdmp   = model_rMatGet(BPM_pvs(idmp(1)),BPM_pvs(idmp));
  static_data.Rdmp1s = permute(Rdmp(1,[1 2 3 4 6],:),[3 2 1]);
  static_data.Rdmp3s = permute(Rdmp(3,[1 2 3 4 6],:),[3 2 1]);

  Rdl2   = model_rMatGet(BPM_pvs(idl2(1)),BPM_pvs(idl2));
  static_data.Rdl21s = permute(Rdl2(1,[1 2 3 4 6],:),[3 2 1]);
  static_data.Rdl23s = permute(Rdl2(3,[1 2 3 4 6],:),[3 2 1]);

  USCL_pvs = strcat(BPM_pvs,':USCL');                       % BPM USCL scalars PV names [mm]
  USCLs = lcaGetSmart(USCL_pvs);                            % BPM USCLs for resolution estimates [mm]

  %[static_data.X0,static_data.Y0,T0,dX0,dY0,dT0,iok,Ipk0] = read_BPMs(BPM_pvs,navg,rate);  % read all BPMs, X, Y, & TMIT with averaging
  static_data.dXY = USCLs/sqrt(navg)/1E3;                               % estimate of BPM resoltions per BPM [mm]
  static_data.X0 = X;
  static_data.Y0 = Y;

else
  static_data = IN_struc.static_data;
end
% try
%   sync = 0;
%   while sync < 1
%     [X,Y,T,dX,dY,dT,iok,Ipk, sync] = read_BPMs(BPM_pvs,navg,rate);  % read all BPMs, X, Y, & TMIT with averaging
%   end
%   bad = 0;
% catch
%   bad = 1;
% end
% if any(T==0) || any(iok==0) || (bad == 1)
%   OUT_struc.dE  = 0;            % Dump minus DL2 energy - with arb. offset (MeV)
%   OUT_struc.ddE = 1E-12;        % error bar on Dump minus DL2 energy - with arb. offset (MeV)
%   OUT_struc.Ipk = 0;            % BC2 Ipk (A)
%   return
% end

OUT_struc.static_data = static_data;

try
  [Xsf,Ysf,p,dp,chisq] = xy_traj_fit(X(idmp),static_data.dXY(idmp)',Y(idmp),static_data.dXY(idmp)',static_data.X0(idmp),static_data.Y0(idmp),static_data.Rdmp1s,static_data.Rdmp3s,[1 1 1 1 1]);  % fit dump trajectory
  dEdmp  = p(5)*static_data.E0;   % dump energy (MeV)
  ddEdmp = dp(5)*static_data.E0;  % error bar on dump energy (MeV)

  %subplot(211)
  %plot(idmp,Y(idmp)-static_data.Y0(idmp),'oc',idmp,Ysf,'-b')

  [Xsf,Ysf,p,dp,chisq] = xy_traj_fit(X(idl2),static_data.dXY(idl2)',Y(idl2),static_data.dXY(idl2)',static_data.X0(idl2),static_data.Y0(idl2),static_data.Rdl21s,static_data.Rdl23s,[0 0 0 0 1]);	% fit trajectory
  dEdl2  = p*static_data.E0;      % DL2 energy (MeV)
  ddEdl2 = dp*static_data.E0;     % error bar on DL2 energy (MeV)

  %subplot(212)
  %plot(idl2,X(idl2)-static_data.X0(idl2),'or',idl2,Xsf,'-g')
  IpkSP = lcaGetSmart('SIOC:SYS0:ML00:AO044');

  OUT_struc.dE  = -(dEdmp - dEdl2) - Loss_per_Ipk*(Ipk - IpkSP);     % Dump minus DL2 energy - with arb. offset (MeV)
  OUT_struc.ddE = sqrt(ddEdmp^2 + ddEdl2^2);  % error bar on Dump minus DL2 energy - with arb. offset (MeV)
  OUT_struc.Ipk = Ipk;
catch
  OUT_struc.dE  = 0;            % Dump minus DL2 energy - with arb. offset (MeV)
  OUT_struc.ddE = 1E-12;        % error bar on Dump minus DL2 energy - with arb. offset (MeV)
  OUT_struc.Ipk = 0;
  return
end


% --- Executes on selection change in PROFMON_METHOD.
function PROFMON_METHOD_Callback(hObject, eventdata, handles)
% hObject    handle to PROFMON_METHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Analyze and plot data
handles = AnalyzeMeas(hObject,  eventdata, handles);



% set(handles.STATUS,'String','Ready');

guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns PROFMON_METHOD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PROFMON_METHOD


% --- Executes during object creation, after setting all properties.
function PROFMON_METHOD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PROFMON_METHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in LOGSCALE.
function LOGSCALE_Callback(hObject, eventdata, handles)
% hObject    handle to LOGSCALE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = AnalyzeMeas(hObject,  eventdata, handles);

% set(handles.STATUS,'String','Ready');

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LOGSCALE




function reset_filters(handles,OD_init,di_OD_init,attens_init)

if ~handles.online
  return
end

% reset YAGXRAY filter
lcaPutSmart(handles.OD_pvs,OD_init);  % otherwise, reset filters

% reset di filters to initial positions
if di_OD_init(1) < 6
  lcaPutSmart(handles.ndi_pos_pvs{di_OD_init(1)+1},1);
end
if di_OD_init(2) < 6
  lcaPutSmart(handles.wdi_pos_pvs{di_OD_init(2)+1},1);
end

%reset atten
lcaPutSmart(handles.atten_control_pvs{1},attens_init);
lcaPutSmart(handles.atten_control_pvs{2},3);




% --- Executes on button press in SPONTBG.
function SPONTBG_Callback(hObject, eventdata, handles)
% hObject    handle to SPONTBG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SPONTBG




function handles = spont_background(hObject, handles)
% Take background with spontaneous signal present

if ~handles.online
  return
end

% Record optical density filters on camera
if handles.yag_tag
    OD = lcaGetSmart(handles.OD_pvs,1,'double');
else
    OD = lcaGetSmart(handles.di_OD_pos_pvs,1,'double');
end

if isfield(handles,'spont_img') && handles.last_spont(1) == OD(1) && handles.last_spont(2)==OD(2) && ~strcmp(handles.methods(handles.currmethod),'Move Undulators')
    return
else
    handles.last_spont = OD;
end


% Alert user
curr_status=get(handles.STATUS,'String');
set(handles.STATUS,'String','Taking spontaneous background'); drawnow;

% Record and Turn off und_launch feedback
synch_feedback_status = lcaGetSmart(handles.feedback,0,'double');
lcaPutSmart(handles.feedback,0);

% Suppress FEL process by kicking first mag
MoveMag(handles,handles.firstmag,handles.firstmag_kick,'perturb');


opts.nBG=0;
opts.bufd=1;
opts.median=0;  % take median of nearest neighbors
opts.doPlot=1;


if handles.yag_tag
    dataList=profmon_measure(handles.xray_profmon,handles.num_shots,opts);
elseif strcmp(handles.acq_method,'XPP Spectrometer')
    dataList=profmon_measure(handles.xpp_spec,handles.num_shots,opts);
elseif strcmp(handles.acq_method,'FEE Spectrometer')
    dataList=profmon_measure(handles.fee_spec,handles.num_shots,opts);
elseif strcmp(handles.acq_method,'SXR Spectrometer')
    dataList=profmon_measure(handles.sxr_spec,handles.num_shots,opts);
else
    dataList=profmon_measure(handles.ndirimg_profmon,handles.num_shots,opts);
end
for j=1:handles.num_shots

%     if j==1
%         spont_img = util_medfilt2(dataList(j).img);
%     else
%         spont_img = spont_img + util_medfilt2(dataList(j).img);
%     end
    if j==1
        spont_img = dataList(j).img;
    else
        spont_img = spont_img + dataList(j).img;
    end
end
handles.spont_img = spont_img/handles.num_shots;


% Restore mag to revive FEL process
MoveMag(handles,handles.firstmag,handles.firstmag_start_pos,'trim');



% crop image digitally since ROI is unavailable
if ~handles.yag_tag && handles.di_roi_crop
  dataList(j) = profmon_imgCrop(dataList(j),handles.pxl_roi);
end

% Restore feedback to start status
lcaPutSmart(handles.feedback,synch_feedback_status);

% Reset status for user
set(handles.STATUS,'String',curr_status); drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function handles = find_roi(handles,dataList)
% finds ROI for the direct imager and returns the recommended pixels

% average images
N=length(dataList);
img=dataList(1).img;
for j=2:N
  img=img+dataList(j).img;
end
img=img/N;



% sum columns and rows
col_sum=sum(img,1);
row_sum=sum(img,2);

% identify FEL as pixel of maximum column and maximum row
[mymax,fel_col]=max(col_sum);
[mymax,fel_row]=max(row_sum);

[Npy,Npx]=size(img);
w=str2double(get(handles.ROIRANGEW,'String'));
h=str2double(get(handles.ROIRANGEH,'String'));
roi(1)=max(round(fel_col-w/2),1);
roi(2)=min(round(fel_col+w/2),Npx);
roi(3)=max(round(fel_row-h/2),1);
roi(4)=min(round(fel_row+h/2),Npy);

% hard code ROI for spectrometer
if (strcmp(handles.xpp_spec,'XPP:OPAL1K:1:LiveImage') || strcmp(handles.sxr_spec,'SXR:EXS:CVV:01:IMAGE_CMPX'))  % LiveImage and Hprj give only vector output
    roi(1) = 1; roi(2) = 1024;
    clim=[min(img(:)) max(img(:))];
    figure(102); imagesc(img(roi(1):roi(2)),clim);
    roi_ans = questdlg('Is ROI of direct imager acceptable?','Spectrometer Digital ROI','Continue','Enter New ROI','Continue');
    % FINISH FINISH FINISH
    while strcmp(roi_ans,'Enter New ROI')
        roi(1) = str2num(char(inputdlg('Enter minimum X pixel','New ROI Input')));
        roi(2) = str2num(char(inputdlg('Enter maximum X pixel','New ROI Input')));
        if roi(2) > Npx; roi(2)=Npx; end
        if roi(1) < 1; roi(1) = 1; end
        xplot=roi(1):roi(2); yplot=0;
        figure(102); imagesc(xplot,yplot,img(1,roi(1):roi(2)),clim);
        %figure(102); imagesc(img(roi(1):roi(2)));
        roi_ans = questdlg('Is ROI of direct imager acceptable?','HXSSS Spectrometer Digital ROI','Continue','Enter New ROI','Continue');
    end
elseif strcmp(handles.acq_method,'FEE Spectrometer') || strcmp(handles.acq_method,'XPP Spectrometer') || strcmp(handles.acq_method,'SXR Spectrometer')
    %roi(1)=153; roi(2)=173;
    %roi(3)=220; roi(4)=315;
    roi(1)=1; roi(2)=Npx; roi(3)=1; roi(4)=Npy;
    clim=[min(img(:)) max(img(:))];
    figure(102); imagesc(img(roi(3):roi(4),roi(1):roi(2)),clim);
    roi_ans = questdlg('Is ROI of direct imager acceptable?','Spectrometer Digital ROI','Continue','Enter New ROI','Continue');
    while strcmp(roi_ans,'Enter New ROI')
        roi(1) = str2num(char(inputdlg('Enter minimum X pixel','New ROI Input')));
        roi(2) = str2num(char(inputdlg('Enter maximum X pixel','New ROI Input')));
        roi(3) = str2num(char(inputdlg('Enter minimum Y pixel','New ROI Input')));
        roi(4) = str2num(char(inputdlg('Enter maximum Y pixel','New ROI Input')));
        if roi(4) > Npy; roi(4)=Npy; end
        if roi(2) > Npx; roi(2)=Npx; end
        if roi(3) < 1; roi(3) = 1; end
        if roi(1) < 1; roi(1) = 1; end
        xplot=roi(1):roi(2); yplot=roi(3):roi(4);
        figure(102); imagesc(xplot,yplot,img(roi(3):roi(4),roi(1):roi(2)),clim);
        roi_ans = questdlg('Is ROI of direct imager acceptable?','Spectrometer Digital ROI','Continue','Enter New ROI','Continue');
    end
else

    % ask user to verify that ROI covers the FEL
    figure(102); imagesc(img(roi(3):roi(4),roi(1):roi(2)));
    good_roi = questdlg(['Is ROI of direct imager acceptable? If not, retake' ...
        ' data and/or change ROI'],'Direct Imager Digital ROI','Continue','Abort','Continue');
    if strcmp(good_roi,'Abort')
      handles.abort=0;
      roi=[];
    end
end

handles.pxl_roi=roi;


function edit85_Callback(hObject, eventdata, handles)
% hObject    handle to SIGTMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SIGTMIT as text
%        str2double(get(hObject,'String')) returns contents of SIGTMIT as a double


% --- Executes during object creation, after setting all properties.
function edit85_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGTMIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit86_Callback(hObject, eventdata, handles)
% hObject    handle to SIGENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SIGENERGY as text
%        str2double(get(hObject,'String')) returns contents of SIGENERGY as a double


% --- Executes during object creation, after setting all properties.
function edit86_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGENERGY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit87_Callback(hObject, eventdata, handles)
% hObject    handle to SIGCURR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SIGCURR as text
%        str2double(get(hObject,'String')) returns contents of SIGCURR as a double


% --- Executes during object creation, after setting all properties.
function edit87_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGCURR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit88_Callback(hObject, eventdata, handles)
% hObject    handle to GOODFRAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GOODFRAC as text
%        str2double(get(hObject,'String')) returns contents of GOODFRAC as a double


% --- Executes during object creation, after setting all properties.
function edit88_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GOODFRAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit89_Callback(hObject, eventdata, handles)
% hObject    handle to SIGORBIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SIGORBIT as text
%        str2double(get(hObject,'String')) returns contents of SIGORBIT as a double


% --- Executes during object creation, after setting all properties.
function edit89_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SIGORBIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FILTER.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to FILTER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FILTER




% --- Executes on button press in MINGXIE.
function MINGXIE_Callback(hObject, eventdata, handles)
% hObject    handle to MINGXIE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MingXieGL(hObject, eventdata, handles)


% --- Executes on button press in USEROI.
function USEROI_Callback(hObject, eventdata, handles)
% hObject    handle to USEROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USEROI



function ROIRANGEW_Callback(hObject, eventdata, handles)
% hObject    handle to ROIRANGEW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIRANGEW as text
%        str2double(get(hObject,'String')) returns contents of ROIRANGEW as a double


% --- Executes during object creation, after setting all properties.
function ROIRANGEW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIRANGEW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function ROIRANGEH_Callback(hObject, eventdata, handles)
% hObject    handle to ROIRANGEH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIRANGEH as text
%        str2double(get(hObject,'String')) returns contents of ROIRANGEH as a double


% --- Executes during object creation, after setting all properties.
function ROIRANGEH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIRANGEH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in ACQ_METHOD.
function ACQ_METHOD_Callback(hObject, eventdata, handles)
% hObject    handle to ACQ_METHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ACQ_METHOD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ACQ_METHOD



acq_types = get(handles.ACQ_METHOD,'String');
curr_type = get(handles.ACQ_METHOD,'Value');
handles.acq_method = acq_types(curr_type);


if strcmp(handles.acq_method,'FEE Spectrometer') || strcmp(handles.acq_method,'XPP Spectrometer') || strcmp(handles.acq_method,'SXR Spectrometer')
    set(handles.DETECTOR,'Value',7)
    handles.use_yag=0;
    set(handles.USEROI,'Value',1)
elseif strcmp(handles.acq_method,'YAGXRAY/DIR_IMG')
    if handles.yag_tag
        set(handles.DETECTOR,'Value',1)
    else
        set(handles.DETECTOR,'Value',2)
    end
    handles.use_yag=1;
    set(handles.USEROI,'Value',0)
elseif strcmp(handles.acq_method,'Gas Detectors')
    set(handles.DETECTOR,'Value',5)
    handles.use_yag=1;
    set(handles.USEROI,'Value',0)
elseif strcmp(handles.acq_method,'K-Mono')
    set(handles.DETECTOR,'Value',8)
    handles.use_yag=1;
    set(handles.TAKE_BSA,'Value',0);
    handles.take_BSA=0;
    set(handles.USEROI,'Value',0)
end

% turn on BSA (beam synchronous acquisition)
if ~strcmp(handles.acq_method,'Gas Detectors') && ~strcmp(handles.acq_method,'K-Mono')
    set(handles.TAKE_BSA,'Value',1);
    handles.take_BSA=1;
end

if strcmp(handles.acq_method,'YAGXRAY/DIR_IMG')
    set(handles.SPONTBG,'Value',1);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ACQ_METHOD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ACQ_METHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in exportPlotButton.
function exportPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ishandle(handles.GLAX)
    elogFigure = figure;     % Make figure suitable for elog
    ha = axes;
    new_handle = copyobj(allchild(handles.GLAX),ha); % copy objects to axes ha in elogFigure
end


function GDET2_GAINMULT_Callback(hObject, eventdata, handles)
% hObject    handle to GDET2_GAINMULT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GDET2_GAINMULT as text
%        str2double(get(hObject,'String')) returns contents of GDET2_GAINMULT as a double


% --- Executes during object creation, after setting all properties.
function GDET2_GAINMULT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GDET2_GAINMULT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GDET2_PRESSMULT_Callback(hObject, eventdata, handles)
% hObject    handle to GDET2_PRESSMULT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GDET2_PRESSMULT as text
%        str2double(get(hObject,'String')) returns contents of GDET2_PRESSMULT as a double


% --- Executes during object creation, after setting all properties.
function GDET2_PRESSMULT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GDET2_PRESSMULT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% Change GDET2 Settings
function handles = ChangeGDET(hObject, eventdata, handles)
% changes GDET2 settings by value specified in handles.pressure_mult and
% gain by value in handles.gain_mult.

%FINISH FINISH FINISH

% change gain
if handles.gain_mult ~= 1
    gain_gdet2_1=lcaGetSmart(handles.gain_gdet2_1_pv);
    gain_gdet2_2=lcaGetSmart(handles.gain_gdet2_2_pv);

    new_gain1 = gain_gdet2_1*handles.gain_mult;
    new_gain2 = gain_gdet2_2*handles.gain_mult;

    % check for maximum gain
    if new_gain1 > handles.gain_max;
        new_gain1=handles.gain_max;
    end
    if new_gain2 > handles.gain_max;
        new_gain2=handles.gain_max;
    end

    lcaPutSmart(handles.gain_gdet2_1_pv,new_gain1);
    lcaPutSmart(handles.gain_gdet2_2_pv,new_gain2);

    % request new cal and offset
    handles.need_gdet2_offset = 1;
    handles.need_gdet2_cal = 1;
    pause(1);
end

% change pressure
if handles.pressure_mult ~= 1
    pressure_gdet2=lcaGetSmart(handles.pressure_gdet2_pv);
    new_press=pressure_gdet2*handles.pressure_mult;

    % check for maximum pressure
    if new_press > handles.pressure_max;
        new_press=handles.pressure_max;
    end

    lcaPutSmart(handles.pressure_gdet2_pv,new_press);

    % request new cal and offset
    handles.need_gdet2_offset = 1;
    handles.need_gdet2_cal = 1;
end

% check for gdet to be finished making changes
gdet_count=0;

while lcaGetSmart(handles.pressure_gdet2_status)~=0 || ~strcmp(lcaGetSmart(handles.gain_gdet2_1_status),'ON') || ~strcmp(lcaGetSmart(handles.gain_gdet2_2_status),'ON')
    pause(0.5);
    set(handles.STATUS,'String','Waiting for GDet2'); drawnow;
    gdet_count=gdet_count+1;    if gdet_count>20; break; end;
end

gdet_count;



% Change GDET2 Settings
function handles = ScrambleUnd(hObject, eventdata, handles, curr_und, last_und)
% Scramble undulators after current position

%FINISH FINISH FINISH
% save current undulator position
handles = UndStatusCheck(hObject, handles);
handles.saved_config_und = handles.und_pos';

% Calculate new positions
und_range = curr_und:last_und;
start_pos = handles.saved_config_und(und_range);

% random scramble
scramble = handles.scram_amp*(rand(size(und_range)));

% sine scramble
% k=2*pi/4.5;
% scramble = start_pos.*(1+handles.scram_amp*sin(k*und_range));    % sine

scram_und_pos = start_pos + scramble;    % scramble

% make sure none are pushed past limits
scram_und_pos(scram_und_pos<handles.min_und_scram_pos) = handles.min_und_scram_pos + scramble(scram_und_pos<handles.min_und_scram_pos);
scram_und_pos(scram_und_pos>handles.max_und_scram_pos) = handles.min_und_scram_pos + scramble(scram_und_pos>handles.max_und_scram_pos);


% Move undulators
new_pos = handles.und_pos;
new_pos(und_range) = scram_und_pos;
new_pos(9)=handles.und_pos(9); new_pos(16)=handles.und_pos(16); % don't scramble self-seeding chicanes
segmentTranslate(new_pos);
segmentTranslateWait_GL(hObject,handles);

%lcaPutSmart(handles.und_names(und_range),scram_und_pos);


function handles = MeasureGDetOffset(hObject,handles)
% measure offset of the Gas detectors with no beam.


% Initialize variables
gdet1_1_offset = 0;
gdet1_2_offset = 0;
gdet2_1_offset = 0;
gdet2_2_offset = 0;

% Make sure that TDUND is OUT
while ~strcmp(lcaGet(handles.BYKick),'Yes')
    set(handles.STATUS,'String','waiting for BYKick'); drawnow;
    disp('No Charge: waiting for beam');
    pause(1)

    % If abort called end program
    handles.abort = get(hObject,'Value');
    if handles.abort == 0
      break;
    end
end

if handles.abort == 0
    return;
end


% set background conditions
if handles.nom_e < handles.max_E_no_spont

    % turn off beam
    lcaPut(handles.BYKick,0);
    pause(handles.BYKick_pause);

else
    % turn off und launch feedback
    feedback_status = lcaGetSmart(handles.feedback,0,'double');
    lcaPutSmart(handles.feedback,0);

    mag_names_x = handles.xmag_names;
    mag_names_y = handles.ymag_names;
    mag_bdes_x = handles.xmag_bdes;
    mag_bdes_y = handles.ymag_bdes;

    first_mag = mag_names_x(1);  % start orbit at beginning of undulator

    kick_size = str2num(get(handles.MAGDIST,'String'))*handles.orbit_to_kick;

    r_cu=handles.r_cu;
    s_cu=handles.s_cu;

    [mymags,mag_coeffs,r_cu,s_cu]=control_undCloseOsc_fast(first_mag,kick_size,handles.kick_plane,r_cu,s_cu);
    handles.r_cu=r_cu; handles.s_cu=s_cu;
    mags_to_change_x=mag_names_x(mymags);
    mags_to_change_y=mag_names_y(mymags);
    mags_to_change_bdes_x=mag_bdes_x(mymags);
    mags_to_change_bdes_y=mag_bdes_y(mymags);
    mag_coeffs_x=mag_coeffs(:,1);
    mag_coeffs_y=mag_coeffs(:,2);

    % record starting values
    ref_mag_coeffs_x = lcaGetSmart(mags_to_change_bdes_x);
    ref_mag_coeffs_y = lcaGetSmart(mags_to_change_bdes_y);

    % move magnets
    MoveMag(handles,mags_to_change_x,mag_coeffs_x,'perturb');
    MoveMag(handles,mags_to_change_y,mag_coeffs_y,'perturb');
end

rate = lcaGetSmart('IOC:IN20:MC01:LCLSBEAMRATE');   % rep. rate % [Hz]
if rate < 1; rate = 1;  end

% read data
gdet1=zeros(handles.num_shots,2);
gdet2=zeros(handles.num_shots,2);
for j=1:handles.num_shots

    % read in data
    gdet1(j,1:2)=lcaGetSmart(handles.gdet_pvs(1:2))';   % gdets
    gdet2(j,1:2)=lcaGetSmart(handles.gdet_pvs(3:4))';

    % check that new data is different from last point.  if not, keep
    % checking until it is different
    pause(1/rate-0.005)     % takes about 2ms to read data
    mycount=0;
    while j>1 && (any(gdet1(j,:)==gdet1(j-1,:)) || any(gdet2(j,:)==gdet2(j-1,:)))
        gdet1(j,1:2)=lcaGetSmart(handles.gdet_pvs(1:2))';
        gdet2(j,1:2)=lcaGetSmart(handles.gdet_pvs(3:4))';

        % stop infinite loop that happened once -- problem with GDet?
        mycount=mycount+1;
        if mycount>1e8
            break
        end
    end

    % or be lazy and just wait a little longer
    %pause(1.1/rate);
end

% set offsets
if handles.need_gdet1_offset
    gdet1_1_offset = gdet1(:,1);
    gdet1_2_offset = gdet1(:,2);
    handles.gdet1_offset=[mean(gdet1_1_offset) mean(gdet1_2_offset)];
    %handles.gdet1_offset=[0 0];
    handles.need_gdet1_offset = 0;
end
if handles.need_gdet2_offset
    gdet2_1_offset = gdet2(:,1);
    gdet2_2_offset = gdet2(:,2);
    handles.gdet2_offset=[mean(gdet2_1_offset) mean(gdet2_2_offset)];
    %handles.gdet2_offset=[0 0];
    handles.need_gdet2_offset = 0;
end


% reset initial conditions
if handles.nom_e < handles.max_E_no_spont

    % turn on beam
    lcaPut(handles.BYKick,1);  pause(handles.BYKick_pause);

else

    % restore x magnets
    MoveMag(handles,mags_to_change_x,ref_mag_coeffs_x,'trim');

    % restore y magnets
    MoveMag(handles,mags_to_change_y,ref_mag_coeffs_y,'trim');

    % reset und launch feedback to initial state
    lcaPutSmart(handles.feedback,feedback_status);

end







function handles = abort_loop(handles)
% subfunction for aborting within a loop

handles.fail = 1;
disp('User abort');
set(handles.STATUS,'String','Aborting'); drawnow;

% reset filters to initial position
if handles.online && isfield(handles,'OD_init')
  lcaPutSmart(handles.OD_pvs,handles.OD_init);
end

% Move magnet back to starting position
if ~strcmp(handles.methods(handles.currmethod),'Move Undulators') && isfield(handles,'curr_mag')
  if handles.curr_pos < handles.und_num-handles.mag_delay && handles.nom_e/handles.max_e < handles.low_energy
    MoveMag(handles,[handles.curr_mag handles.curr_mag2],[handles.start_pos handles.start_pos2],'perturb');
  else
    MoveMag(handles,handles.curr_mag,handles.start_pos,'perturb');
  end
end






% --- Executes on button press in TAKE_BSA.
function TAKE_BSA_Callback(hObject, eventdata, handles)
% hObject    handle to TAKE_BSA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TAKE_BSA

handles.take_BSA = get(handles.TAKE_BSA,'Value');

if strcmp(handles.acq_method,'YAGXRAY/DIR_IMG')
    set(handles.TAKE_BSA,'Value',1);
    handles.take_BSA = get(handles.TAKE_BSA,'Value');
end

guidata(hObject, handles);


function img = util_medfilt2_DR(img, dom)
%MEDFILT2
%  MEDFILT2(IMG, DOM) applies a median filter to the 2-d array IMG using a
%  neighborhood of DOM = [M N] pixels. DOM has to be a vector of 2 odd
%  numbers, the default is a [3 3] neighborhood.

% Input arguments:
%    IMG: Image array
%    DOM: Neighborhood size [M N]

% Output arguments:
%    IMG: Filtered image

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Check input arguments
if nargin < 2, dom=[3 3];end

if isempty(img), return, end

dom=fix(dom/2);d1=1:dom(1);d2=1:dom(2);
img(dom(1)+(1:end),dom(2)+(1:end))=img;
img([d1 end+d1],:)=img([2*ones(1,dom(1)) end*ones(1,dom(1))],:);
img(:,[d2 end+d2])=img(:,[2*ones(1,dom(2)) end*ones(1,dom(2))]);

if any(dom-1)
    m=0;
    for j=0:2*dom(1)
        for k=0:2*dom(2), m=m+1;
            im2(:,:,m)=img(1+j:end+j-2*dom(1),1+k:end+k-2*dom(2));
        end
    end
else
    im2=cat(3,img(1:end-2,1:end-2), ...
              img(1:end-2,2:end-1), ...
              img(1:end-2,3:end-0), ...
              img(2:end-1,1:end-2), ...
              img(2:end-1,2:end-1), ...
              img(2:end-1,3:end-0), ...
              img(3:end-0,1:end-2), ...
              img(3:end-0,2:end-1), ...
              img(3:end-0,3:end-0) ...
            );
end
img=median(double(im2),3);


function handles=GDET_signal(handles)

Nshots=20;

% record some data
rate = lcaGetSmart('IOC:IN20:MC01:LCLSBEAMRATE');
if rate==0; rate=1; end
for j=1:Nshots
    data1_1(j,:)=lcaGet(handles.gdet_data1_1_pv);
    data1_2(j,:)=lcaGet(handles.gdet_data1_2_pv);
    data2_1(j,:)=lcaGet(handles.gdet_data2_1_pv);
    data2_2(j,:)=lcaGet(handles.gdet_data2_2_pv);
    gdet_energy(j)=lcaGetSmart(handles.gdet_pvs(1));
    pause(1/rate);
end

% if pulse energy low, return (hard to assess GDet status)
if mean(gdet_energy)<1  % require more than 1mJ
    return
end

% average data (using median)
data1_1_med=median(data1_1,1);
data1_2_med=median(data2_1,1);
data2_1_med=median(data1_1,1);
data2_2_med=median(data2_1,1);

% check if data is bad
gdet1_bad=0; gdet2_bad=0;
if min(data1_1_med) > handles.gdet_good_data || min(data1_2_med) > handles.gdet_good_data
    gdet1_bad=1;
end
if min(data2_1_med) > handles.gdet_good_data || min(data2_2_med) > handles.gdet_good_data
    gdet2_bad=1;
end

% If bad, check if user wants to abort
if (gdet1_bad && gdet2_bad)
    gdet_warn='Both gas detectors have low gain. ';
elseif gdet1_bad
    gdet_warn='Gas detector 1 has low gain. ';
elseif gdet2_bad
    gdet_warn='Gas detector 2 has low gain. ';
else
    return;
end


cont='Continue: I like my data lousy';
abort='Abort: I will fix GDet and recalibrate';
gdet_ans = questdlg([gdet_warn 'Data will improve with signal below 10,000']...
  ,'GDet low signal',abort,cont,abort);
if strcmp(gdet_ans,abort)
    handles.fail=1;
end


function [mag_numbers, coeffs, r, s] = control_undCloseOsc_fast(name, val, plane, r, s)

% Adapted from Henrik's code

if nargin < 2, val=1e-3;end
if nargin < 3, plane='x';end

if nargin < 4 || isempty(r)
    s=bba_simulInit;
    r=bba_responseMatGet(s,1);
end


s=bba_simulInit;

iCorr=find(strcmp(s.corrList,model_nameConvert(name,'MAD')));
[d,iBPM]=max(abs(r(1:2:end-2,5+33*2+37*2+33*4+2*iCorr-1)));

x=zeros(2,numel(s.bpmList));
x(:,1:end-2)=NaN;
x(:,iBPM)=val;

opts.use=struct('init',0,'BPM',0,'quad',0,'corr',1);
opts.iCorr=[iCorr 30 33];

f=bba_fitOrbit(s,r,x,[],opts);

%bba_plotOrbit(s,x,[],f.xMeasF,[]);

%bba_corrSet(s,f.corrOff,1,'abs',1);

names=s.corrList(opts.iCorr);
mag_numbers=opts.iCorr;
names=[names strrep(names,'X','Y')];
names=names(:,lower(plane)=='xy');
coeffs=f.corrOff(lower(plane)=='xy',opts.iCorr)';



