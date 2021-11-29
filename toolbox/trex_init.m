function handles = trex_init(handles,hObject)

% path at launch not consistent across OPIs...
cd /home/physics

% define and set constants
handles.e0           = 1.602176565E-19; % elementary charge 
handles.c0           = 299792458;       % speed of light
handles.xtcav_freq   = 11.424E9;        % xtcav frequency
handles.charge_thres = 5E-12;           % charge threshold [pC] to detect beam on/off
handles.magicCal     = 0.885;          % magic xtcav calibration number
handles.roi_ini      = 0.5;             % ROI padding; not needed for TREX2.0
handles.screen_cut_x = 1360;            % screen cut; not needed for TREX2.0
handles.img_limit    = 100;             % limits readout images; not needed for TREX2.0

% load custom colors for decent plots
handles.colors = trex_colors; % assign colors

% prepare synchronous readout -- Now using HST buffers
%handles = gui_BSAControl(hObject,handles,1); % request EDEF number

% pv list orignilaly used in TREX1.0
handles.pv_list      = {'BLEN:LI21:265:AIMAX','BLEN:LI24:886:BIMAX',...
                        'BPMS:LTUH:250:X','BPMS:LTUH:450:X',...
                        'BPMS:DMPH:502:TMIT',...
                        'GDET:FEE1:241:ENRC','GDET:FEE1:242:ENRC',...
                        'TCAV:DMPH:360:P','TCAV:DMPH:360:A','KLYS:DMPH:K1:FWD_P','KLYS:DMPH:K1:FWD_A',...
                        'BPMS:DMPH:502:X','BPMS:DMPH:502:Y','BPMS:DMPH:693:X','BPMS:DMPH:693:Y',...
                        };
                        %'BLD:SYS0:500:PCAV_CHARGE1','BLD:SYS0:500:PCAV_FITTIME1','BLD:SYS0:500:PCAV_CHARGE2','BLD:SYS0:500:PCAV_FITTIME2',...
                        %};

% some initialization                    
handles.beam_on      = 0;
handles.init         = 0;

% set camera for non-free mode; not clear yet how to deal with that
% lcaPut('EVR:DMPH:PM01:EVENT4CTRL.ENM',159);

% define needed process cariables (PVs); actually not need in TREX1.1
handles.pv_charge  = 'BPMS:DMPH:502:TMIT'; % charge (e number) in dump line 
handles.pv_xray1   = 'GDET:FEE1:241:ENRC'; % X-ray pulse energy from GDET21
handles.pv_xray2   = 'GDET:FEE1:242:ENRC'; % X-ray pulse energy from GDET22
handles.pv_erg1    = 'BPMS:LTUH:250:X';    % horizontal offset in DL2 (250)
handles.pv_erg2    = 'BPMS:LTUH:450:X';    % horizontal offset in DL2 (450)
handles.pv_erg     = 'REFS:DMPH:400:EDES'; % mean energy from magnet server
handles.pv_camera  = 'OTRDMP';             % camera address label
handles.pv_xtcav   = 'OTRDMP';             % xtcav address label
handles.pv_DL250   = 'BPMDL1';             % DL2 BPM (250) label
handles.pv_DL450   = 'BPMDL3';             % DL2 BPM (450) label
handles.pv_xtcav_V = 'TCAV:DMPH:360:ADES'; % xtcav setpoint voltage
handles.pv_xtcav_P = 'TCAV:DMPH:360:PDES'; % xtcav setpoint phase


handles.pv_xtcav_state = 'SIOC:SYS0:ML01:AO172'; % xtacv on/off state
handles.pv_xtcav_cal   = 'OTRS:DMPH:695:TCAL_X'; % xtcav calibration
handles.pv_xtcav_cal_V = 'SIOC:SYS0:ML01:AO214'; % xtcav voltage at calib.
handles.pv_xtcav_cal_P = 'SIOC:SYS0:ML01:AO215'; % xtcav phase at calib.
handles.pv_xtcav_cal_I = 'SIOC:SYS0:ML01:AO213'; % intrinsic r_15 
handles.pv_xtcav_cal_X = 'SIOC:SYS0:ML01:AO212'; % sigma_x at calib. 
handles.pv_xtcav_cal_Z = 'OTRS:DMPH:695:BLEN';   % sigma_z at calib. 

handles.pv_feedback_mode = 'UND0:UND1:FB01:STATSUMY'; % check feedback mode
handles.pv_feedback_one  = 'FBCK:UND0:1:ENABLE';      % feedback mode: 1
handles.pv_feedback_two  = 'FBCK:FB03:TR04:MODE';     % feedback mode: 2

% generate PV list for synchronous read-out 
handles.pv_list2 = {handles.pv_charge, ...
                   handles.pv_xray1, handles.pv_xray2,...
                   handles.pv_erg1, handles.pv_erg2,...
                  };
              
% initialize number of signal images  
set(handles.trex_num_sig,'String',...
    num2str(20));   

% initialize number of background images  
set(handles.trex_num_bgr,'String',...
    num2str(5)); 

% initialize number of baseline images  
set(handles.trex_num_bsl,'String',...
    num2str(10)); 

% initialize number of slices
set(handles.trex_set_slice_num,'String',...
    num2str(100)); 

% initialize mean electron energy                    
handles.mean_erg  = lcaGet(handles.pv_erg)*1E3; 

% initialize bump amplitude                   
set(handles.trex_bump_amp,'String',...
    num2str(0)); 

% initialize synchronous readout                   
set(handles.trex_check_sync,'Value',1); 

% initialize dispersion from model in DL2 (250 and 450)             
disp_tmp      = model_rMatGet(handles.pv_DL250,[],[],'twiss'); 
handles.disp1 = disp_tmp(5);
disp_tmp      = model_rMatGet(handles.pv_DL450,[],[],'twiss'); 
handles.disp2 = disp_tmp(5);              

% initialize dispersion from model at OTRDMP  
disp_tmp           = model_rMatGet(handles.pv_camera,[],[],'twiss');
handles.dispersion = disp_tmp(10);
set(handles.trex_set_dispersion,'String',...
    num2str(handles.dispersion,'%.3f'));

% initialize shear parameter from model at OTRDMP  
handles.xtcav_V = lcaGet(handles.pv_xtcav_V);
handles.streak  = handles.magicCal/handles.mean_erg*handles.xtcav_V*1E3;
set(handles.trex_set_streak,'String',...
    num2str(handles.streak,'%.3f'));  
set(handles.trex_xtcav_V_at_cal,'String',...
    num2str(handles.xtcav_V,'%.1f'));  

% initialize intrinsic shear parameter at OTRDMP  
set(handles.trex_set_correlation,'String',...
    num2str(0.,'%.3f'));  



