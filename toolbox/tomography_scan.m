function varargout = tomography_scan(varargin)
% TOMOGRAPHY_SCAN M-file for tomography_scan.fig
%      TOMOGRAPHY_SCAN, by itself, creates a new TOMOGRAPHY_SCAN or raises the existing
%      singleton*.
%
%      H = TOMOGRAPHY_SCAN returns the handle to a new TOMOGRAPHY_SCAN or the handle to
%      the existing singleton*.
%
%      TOMOGRAPHY_SCAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TOMOGRAPHY_SCAN.M with the given input arguments.
%
%      TOMOGRAPHY_SCAN('Property','Value',...) creates a new TOMOGRAPHY_SCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tomography_scan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tomography_scan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tomography_scan

% Last Modified by GUIDE v2.5 24-May-2014 22:10:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tomography_scan_OpeningFcn, ...
                   'gui_OutputFcn',  @tomography_scan_OutputFcn, ...
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


% --- Executes just before tomography_scan is made visible.
function tomography_scan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tomography_scan (see VARARGIN)

% Choose default command line output for tomography_scan
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tomography_scan wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tomography_scan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

global imdata;
global imdata2;
global syag_box;
global syag_rect;
global camera2_box;
global camera2_rect;

% Change handles.do_scan = 0 for debug mode, and = 1 for scan mode.
handles.do_scan = 1;

if handles.do_scan == 1;
    handles.init_notch = lcaGetSmart('COLL:LI20:2072:MOTR');
    handles.init_jaw_left = lcaGetSmart('COLL:LI20:2085:MOTR.VAL');
    handles.init_jaw_right = lcaGetSmart('COLL:LI20:2086:MOTR.VAL');
end
handles.camera_PV_inuse = {'PROF:LI20:2432','PROF:LI20:3230'};
handles.camera_names_inuse = {'SYAG','IP2B'};
handles.camera_PVList = {'PROF:LI20:3158','PROF:LI20:3180','PROF:LI20:3208','PROF:LI20:3202',...
    'PROF:LI20:3230','EXPT:LI20:3303','CMOS:LI20:3490','CMOS:LI20:3492','PROF:LI20:2432'};
handles.DevNames = {'USOTR';'IPOTR1';'IPOTR2';'IP2A';'IP2B';'ELANEX';'CMOS_NEAR';'CMOS_FAR';'SYAG';};
set(handles.device_select,'String',handles.DevNames);
set(handles.device_select,'Value',5);
handles.dispersion_PVList = {'SIOC:SYS1:ML00:AO305','SIOC:SYS1:ML00:AO306',...
    'SIOC:SYS1:ML00:AO307','SIOC:SYS1:ML00:AO308','SIOC:SYS1:ML00:AO309'};
handles.tcav_calPV = {'SIOC:SYS1:ML00:AO025'};
lcaPutSmart('PROF:LI20:2432:BinX.PROC',1);
lcaPutSmart('PROF:LI20:2432:BinY.PROC',1);
lcaPutSmart('PROF:LI20:3230:BinX.PROC',1);
lcaPutSmart('PROF:LI20:3230:BinY.PROC',1);
handles.tcav_cal_val = lcaGetSmart(handles.tcav_calPV);
handles.tcav_cal_str = num2str(handles.tcav_cal_val);
handles.dispersion_value = lcaGetSmart(handles.dispersion_PVList(5));
set(handles.dispersion_selection,'Value',5);
handles.dispersion_str = num2str(handles.dispersion_value);
handles.set_slit_width_val = 0.5;
handles.set_slit_width_str = num2str(handles.set_slit_width_val);
handles.slit_position_val = 0;
handles.slit_position_str = num2str(handles.slit_position_val);
handles.scan_slit_width_val= 0.5;
handles.scan_slit_width_str = num2str(handles.scan_slit_width_val);
handles.slit_start_pos_val = -2;
handles.slit_start_pos_str = num2str(handles.slit_start_pos_val);
handles.slit_end_pos_val = 3.5;
handles.slit_end_pos_str = num2str(handles.slit_end_pos_val);
handles.slit_nstep_val = 12;
handles.slit_nstep_str = num2str(handles.slit_nstep_val);
handles.slit_nsample_val = 5;
handles.slit_nsample_str = num2str(handles.slit_nsample_val);

imdata2 = [];
imdata = profmon_grab(handles.camera_PV_inuse);
handles.syag.resolution = imdata(1).res;
handles.syag.pix_x = imdata(1).roiXN;
handles.syag.pix_y = imdata(1).roiYN;
syag_x_axis = (handles.syag.resolution*(1:handles.syag.pix_x))/1000;
handles.syag.x_axis = syag_x_axis - mean(syag_x_axis);
syag_y_axis = (handles.syag.resolution*(1:handles.syag.pix_y))/1000;
handles.syag.y_axis = syag_y_axis - mean(syag_y_axis);
handles.camera2.energy_axis = [];

handles.camera2.resolution = imdata(2).res;
handles.camera2.pix_x = imdata(2).roiXN;
handles.camera2.pix_y = imdata(2).roiYN;
camera2_x_axis = (handles.camera2.resolution*(1:handles.camera2.pix_x))/1000;
handles.camera2.x_axis = camera2_x_axis - mean(camera2_x_axis);
camera2_y_axis = (handles.camera2.resolution*(1:handles.camera2.pix_y))/1000;
handles.camera2.y_axis = camera2_y_axis - mean(camera2_y_axis);
handles.camera2.y_axis_flip = fliplr(handles.camera2.y_axis);

% Default Regions of Interest=======
syag_box = [ceil(handles.syag.pix_x*0.12) floor(handles.syag.pix_x*0.86)...
    floor(handles.syag.pix_y*0.12) ceil(handles.syag.pix_y*0.18)];
syag_rect = [handles.syag.x_axis(syag_box(1)) handles.syag.y_axis(syag_box(3)),...
    (handles.syag.x_axis(syag_box(2))-handles.syag.x_axis(syag_box(1))),...
    (handles.syag.y_axis(syag_box(4))-handles.syag.y_axis(syag_box(3)))];
camera2_box = [ceil(handles.camera2.pix_x*0.25) floor(handles.camera2.pix_x*0.75)...
    floor(handles.camera2.pix_y*0.25) ceil(handles.camera2.pix_y*0.75)];
camera2_rect = [handles.camera2.x_axis(camera2_box(1)) handles.camera2.y_axis_flip(camera2_box(4)),...
    (handles.camera2.x_axis(camera2_box(2))-handles.camera2.x_axis(camera2_box(1))),...
    (handles.camera2.y_axis_flip(camera2_box(3))-handles.camera2.y_axis_flip(camera2_box(4)))];                                                                                                                                                                                                                                                                                          
% =================================

update_syag_im(handles);
update_camera2_im(handles);
handles = update_gui(handles);
guidata(hObject, handles);


% Updates Gui State
function handles = update_gui(handles)
handles.syag_lineout = get(handles.syag_ROI,'Value');
handles.camera2_lineout = get(handles.camera2_ROI,'Value');
% handles.dispersion_str = num2str(handles.dispersion_value);
set(handles.dispersion_box,'String',handles.dispersion_str);
set(handles.tcav_cal_box,'String',handles.tcav_cal_str);
set(handles.camera_PV_box,'String',handles.camera_PV_inuse(2));
set(handles.set_slit_width_box,'String',handles.set_slit_width_str);
set(handles.slit_position_box,'String',handles.slit_position_str);
set(handles.scan_slit_width_box,'String',handles.scan_slit_width_str);
set(handles.slit_start_pos_box,'String',handles.slit_start_pos_str);
set(handles.slit_end_pos_box,'String',handles.slit_end_pos_str);
set(handles.slit_nstep_box,'String',handles.slit_nstep_str);
set(handles.slit_nsample_box,'String',handles.slit_nsample_str);
handles.plot = get(handles.plot_type,'Value');
handles.proj_xz = get(handles.projection_type,'Value');
handles.drift_check_on = get(handles.drift_correction_box,'Value');


function update_syag_im(handles)

global imdata;
global syag_rect;
global imdata2;
% global syag_box;

% Find new x indices for syag_box in case start or end position are changed
% x_min_ind = find(handles.syag.x_axis, syag_rect(1),'first');
% x_max_ind = find(handles.syag.x_axis, syag_rect(1)+syag_rect(3),'first');
% syag_box(1) = x_min_ind;
% syag_box(2) = x_max_ind;

% Plot image and lineout region
ax_1 = handles.syag_axes;
axes(ax_1);
cla;
hold on;
axis([min(handles.syag.x_axis) max(handles.syag.x_axis) min(handles.syag.y_axis) max(handles.syag.y_axis)]);
axis ij;
if ~isstruct(imdata2)
    imagesc(handles.syag.x_axis,handles.syag.y_axis,imdata(1).img,'HitTest','Off');
else
    imagesc(handles.syag.x_axis,handles.syag.y_axis,imdata2(1).img,'HitTest','Off');
end
% axis([min(handles.syag.x_axis) max(handles.syag.x_axis) min(handles.syag.y_axis) max(handles.syag.y_axis)]);
% axis xy;
caxis([0 256]);
xlabel('X [mm]');
ylabel('Y [mm]');
% hold on;
if ~isempty(syag_rect)
    if syag_rect(3) <= 0 || syag_rect(4) <= 0
        clear global syag_box;
        clear global syag_rect;
        display('sYAG region of interest width and/or height are less than or equal to zero.');
        return;
    else
        rectangle('Position',syag_rect,'edgecolor','r','linewidth',2,'linestyle','--');
    end
end
% handles.slit_start_pos_val = syag_rect(1);
% handles.slit_end_pos_val = syag_rect(3)-syag_rect(1);
% handles.scan_slit_width_val = (handles.slit_end_pos_val - handles.slit_start_pos_val)/(handles.slit_nstep_val - 1);
% handles.slit_start_pos_str = num2str(handles.slit_start_pos_val);
% handles.slit_end_pos_str = num2str(handles.slit_end_pos_val);
% handles.scan_slit_width_str = num2str(handles.scan_slit_width_val);
hold off;

function update_camera2_im(handles)

global imdata;
global camera2_rect;
global imdata2;

% Plot image and lineout region
ax_2 = handles.camera2_axes;
axes(ax_2);
cla;
hold on;
if ~isstruct(imdata2)
    imagesc(handles.camera2.x_axis,handles.camera2.y_axis_flip,imdata(2).img,'HitTest','Off');
else
    imagesc(handles.camera2.x_axis,handles.camera2.y_axis_flip,imdata2(2).img,'HitTest','Off');
end
axis([min(handles.camera2.x_axis) max(handles.camera2.x_axis) min(handles.camera2.y_axis) max(handles.camera2.y_axis)]);
axis xy;
caxis([0 768]);
xlabel('X [mm]');
ylabel('Y [mm]');
if ~isempty(camera2_rect)
    if camera2_rect(3) <= 0 || camera2_rect(4) <= 0
        clear global camera2_box;
        clear global camera2_rect;
        display('Camera 2 region of interest width and/or height are less than or equal to zero.');
        return;
    else
        rectangle('Position',camera2_rect,'edgecolor','r','linewidth',2,'linestyle','--');
    end
end
hold off;

function update_tcav_raw(handles)

global imdata2;
global tcav_raw_im;

ax_3 = handles.tcav_axes;
axes(ax_3);
tcav_raw_im = imdata2(2).img;
plot_tcav_raw(handles);


function plot_tcav_raw(handles)

global camera2_box;
global tcav_raw_im;

hold all;
% camera2_size = size(tcav_raw_im);
zoomed_im = tcav_raw_im(camera2_box(3):camera2_box(4), camera2_box(1):camera2_box(2));
x_axis_roi = handles.camera2.x_axis(camera2_box(1):camera2_box(2));
y_axis_roi = handles.camera2.y_axis_flip(camera2_box(3):camera2_box(4));
% y_axis_roi = fliplr(y_axis_roi_unflip);
imagesc(x_axis_roi, y_axis_roi, zoomed_im);
axis([min(x_axis_roi) max(x_axis_roi) min(y_axis_roi) max(y_axis_roi)]);
caxis([0 768]);
xlabel('X [mm]');
ylabel('Y [mm]');
title(strcat(handles.plot_str,' Fully Open'));
hold off;

% function get_energy_axis(handles)
% global syag_box;
% global imdata;
% set_slit(default); % What value to get the jaws/notch out?
% lcaPutSmart('SIOC:SYS1:ML01:AO075',default); % What value to ge the jaws/notch out?
% energy_axis = handles.syag.x_axis(syag_box(1):syag_box(2));
% energy_axis = energy_axis/handles.dispersion_value;
% energy_axis = energy_axis - mean(energy_axis);
% imdata = profmon_grab(handles.camera_PV_inuse);
% roi_syag_im = imdata(1).img(syag_box(3):syag_box(4), syag_box(1):syag_box(2));
% spectrum = mean(roi_syag_im);
% spectrum = spectrum/sum(spectrum);
% offset = sum(energy_axis.*spectrum');handles.data.ts
% handles.camera2.energy_axis = energy_axis - offset;

function handles = analyze_data(handles)
global camera2_box;
global syag_box;

% Calculate axes ===============================
handles.camera2.energy_axis = linspace((handles.slit_start_pos_val-(handles.scan_slit_width_val/2))/handles.dispersion_value,...
    (handles.slit_end_pos_val+(handles.scan_slit_width_val/2))/handles.dispersion_value,handles.slit_nstep_val);
syag_x_axis = handles.syag.x_axis(syag_box(1):syag_box(2));
syag_energy_axis = syag_x_axis/handles.dispersion_value;
handles.syag.energy_axis = syag_energy_axis - mean(syag_energy_axis);
z_axis_unscaled = handles.camera2.y_axis(camera2_box(3):camera2_box(4));
handles.z_axis = z_axis_unscaled/handles.tcav_cal_val;
handles.z_axis_flip = fliplr(handles.z_axis);
handles.x_axis_camera2_roi = handles.camera2.x_axis(camera2_box(1):camera2_box(2));

% Correct for shot to shot jitter ==================================
[junk, handles.y_prof_centers] = max(handles.y_camera2_proj,[],1);
[junk2, handles.x_prof_centers] = max(handles.x_camera2_proj,[],1);
% handles.median_of_y_prof = median(handles.z_axis(handles.y_prof_centers),2);
handles.median_of_y_prof = median(handles.z_axis_flip(handles.y_prof_centers),2);
handles.median_of_x_prof = median(handles.x_axis_camera2_roi(handles.x_prof_centers),2);
handles.y_camera2_proj_centered = zeros(camera2_box(4)-camera2_box(3)+1, handles.slit_nsample_val, handles.slit_nstep_val);
handles.x_camera2_proj_centered = zeros(camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val, handles.slit_nstep_val);
[junk3, handles.y_full_profs_center_ind_before] = max(handles.y_full_profs_tcav_before,[],1);
[junk4, handles.y_full_profs_center_ind_after] = max(handles.y_full_profs_tcav_after,[],1);
[junk5, handles.x_full_profs_center_ind_before] = max(handles.x_full_profs_tcav_before,[],1);
[junk6, handles.x_full_profs_center_ind_after] = max(handles.x_full_profs_tcav_after,[],1);
handles.median_of_full_y_prof_before = median(handles.z_axis_flip(handles.y_full_profs_center_ind_before),2);
handles.median_of_full_y_prof_after = median(handles.z_axis_flip(handles.y_full_profs_center_ind_after),2);
handles.median_of_full_x_prof_before = median(handles.x_axis_camera2_roi(handles.x_full_profs_center_ind_before),2);
handles.median_of_full_x_prof_after = median(handles.x_axis_camera2_roi(handles.x_full_profs_center_ind_after),2);
handles.y_full_profs_centered_before = zeros(camera2_box(4)-camera2_box(3)+1, handles.slit_nsample_val);
handles.y_full_profs_centered_after = zeros(camera2_box(4)-camera2_box(3)+1, handles.slit_nsample_val);
handles.x_full_profs_centered_before = zeros(camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val);
handles.x_full_profs_centered_after = zeros(camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val);
for ix = 1:handles.slit_nstep_val
    for iy = 1:handles.slit_nsample_val
        handles.y_camera2_proj_centered(:,iy,ix) = center_vec(handles.y_camera2_proj(:,iy,ix), handles.z_axis_flip,...
            handles.y_prof_centers(1,iy,ix), handles.median_of_y_prof(1,1,ix));
        handles.y_full_profs_centered_before(:,iy) = center_vec(handles.y_full_profs_tcav_before(:,iy), handles.z_axis_flip,...
            handles.y_full_profs_center_ind_before(1,iy), handles.median_of_full_y_prof_before);
        handles.y_full_profs_centered_after(:,iy) = center_vec(handles.y_full_profs_tcav_after(:,iy), handles.z_axis_flip,...
            handles.y_full_profs_center_ind_after(1,iy), handles.median_of_full_y_prof_after);
        handles.x_camera2_proj_centered(:,iy,ix) = center_vec(handles.x_camera2_proj(:,iy,ix), handles.x_axis_camera2_roi,...
            handles.x_prof_centers(1,iy,ix), handles.median_of_x_prof(1,1,ix));
        handles.x_full_profs_centered_before(:,iy) = center_vec(handles.x_full_profs_tcav_before(:,iy), handles.x_axis_camera2_roi,...
            handles.x_full_profs_center_ind_before(1,iy), handles.median_of_full_x_prof_before);
        handles.x_full_profs_centered_after(:,iy) = center_vec(handles.x_full_profs_tcav_after(:,iy), handles.x_axis_camera2_roi,...
            handles.x_full_profs_center_ind_after(1,iy), handles.median_of_full_x_prof_after);
    end
end

% handles.z_axis_flip = fliplr(handles.z_axis);
handles.avg_y_proj = squeeze(mean(handles.y_camera2_proj_centered,2))';
handles.avg_x_proj = squeeze(mean(handles.x_camera2_proj_centered,2))';
handles.y_tomo_prof = mean(handles.avg_y_proj,1);
handles.x_tomo_prof = mean(handles.avg_x_proj,1);
handles.max_y_tomo_prof = max(handles.y_tomo_prof);
handles.max_x_tomo_prof = max(handles.x_tomo_prof);
handles.y_tomo_spectra = mean(handles.avg_y_proj,2);
handles.x_tomo_spectra = mean(handles.avg_x_proj,2);
handles.y_raw_full_prof_avg_before = mean(handles.y_full_profs_centered_before,2);
handles.y_raw_full_prof_avg_after = mean(handles.y_full_profs_centered_after,2);
handles.x_raw_full_prof_avg_before = mean(handles.x_full_profs_centered_before,2);
handles.x_raw_full_prof_avg_after = mean(handles.x_full_profs_centered_after,2);
[handles.y_max_raw_prof_before, handles.y_max_raw_prof_before_ind] = max(handles.y_raw_full_prof_avg_before);
[handles.y_max_raw_prof_after, handles.y_max_raw_prof_after_ind] = max(handles.y_raw_full_prof_avg_after);
[handles.x_max_raw_prof_before, handles.x_max_raw_prof_before_ind] = max(handles.x_raw_full_prof_avg_before);
[handles.x_max_raw_prof_after, handles.x_max_raw_prof_after_ind] = max(handles.x_raw_full_prof_avg_after);
handles.z_max_raw_before = handles.z_axis_flip(handles.y_max_raw_prof_before_ind);
handles.z_max_raw_after = handles.z_axis_flip(handles.y_max_raw_prof_after_ind);
handles.x_max_raw_before = handles.x_axis_camera2_roi(handles.x_max_raw_prof_before_ind);
handles.x_max_raw_after = handles.x_axis_camera2_roi(handles.x_max_raw_prof_after_ind);
handles.syag_profs_avg_before = mean(handles.syag_profs_before,2);
handles.syag_profs_avg_after = mean(handles.syag_profs_after,2);
[handles.max_syag_spectra_before, handles.syag_center_ind_before] = max(handles.syag_profs_avg_before);
[handles.max_syag_spectra_after, handles.syag_center_ind_after] = max(handles.syag_profs_avg_after);
[handles.max_y_tomo_spectra, handles.y_tomo_spectra_center_ind] = max(handles.y_tomo_spectra,[],1);
[handles.max_x_tomo_spectra, handles.x_tomo_spectra_center_ind] = max(handles.x_tomo_spectra,[],1);
handles.y_spectra_center_value_tomo = handles.camera2.energy_axis(handles.y_tomo_spectra_center_ind);
handles.x_spectra_center_value_tomo = handles.camera2.energy_axis(handles.x_tomo_spectra_center_ind);
[junk7, handles.syag_center_val_ind_y] = min(abs(handles.syag.energy_axis-handles.y_spectra_center_value_tomo));
[junk8, handles.syag_center_val_ind_x] = min(abs(handles.syag.energy_axis-handles.x_spectra_center_value_tomo));
handles.y_spectra_center_value_syag = handles.syag.energy_axis(handles.syag_center_val_ind_y);
handles.x_spectra_center_value_syag = handles.syag.energy_axis(handles.syag_center_val_ind_x);
handles.y_syag_prof_center_before = center_vec(handles.syag_profs_avg_before, handles.syag.energy_axis, handles.syag_center_ind_before,...
    handles.y_spectra_center_value_syag);
handles.y_syag_prof_center_after = center_vec(handles.syag_profs_avg_after, handles.syag.energy_axis, handles.syag_center_ind_after,...
    handles.y_spectra_center_value_syag);
handles.x_syag_prof_center_before = center_vec(handles.syag_profs_avg_before, handles.syag.energy_axis, handles.syag_center_ind_before,...
    handles.x_spectra_center_value_syag);
handles.x_syag_prof_center_after = center_vec(handles.syag_profs_avg_after, handles.syag.energy_axis, handles.syag_center_ind_after,...
    handles.x_spectra_center_value_syag);

% Drift correction data ========================================
centroid_before = sum(handles.y_raw_full_prof_avg_before.*handles.z_axis')/sum(handles.y_raw_full_prof_avg_before);
centroid_after = sum(handles.y_raw_full_prof_avg_after.*handles.z_axis')/sum(handles.y_raw_full_prof_avg_after);
slope_num = centroid_before - centroid_after;
slope_den = handles.data.tomography.step_ts(1)-handles.data.tomography.step_ts(handles.slit_nstep_val + 2);
slope = slope_num/slope_den;
y_int = centroid_before - slope*handles.data.tomography.step_ts(1);
handles.drift_centroid = slope*(handles.data.tomography.step_ts) + y_int;
handles.drift_correction_val = handles.drift_centroid-centroid_before;
handles.avg_y_proj_dc = zeros(handles.slit_nstep_val,camera2_box(4)-camera2_box(3)+1);
    for iz = 1:handles.slit_nstep_val
        [junk9,handles.max_prof_drift_ind] = max(handles.avg_y_proj(iz,:));
        handles.prof_axis_dc_bad = handles.z_axis_flip(handles.max_prof_drift_ind) - handles.drift_correction_val(iz+1);
        [junk10, handles.prof_axis_dc_ind] = min(abs(handles.z_axis_flip - handles.prof_axis_dc_bad));
        handles.prof_axis_dc = handles.z_axis_flip(handles.prof_axis_dc_ind);
        handles.avg_y_proj_dc(iz,:) = center_vec(handles.avg_y_proj(iz,:), handles.z_axis_flip,...
            handles.max_prof_drift_ind, handles.prof_axis_dc);
    end
handles.y_tomo_prof_dc = mean(handles.avg_y_proj_dc,1);
handles.max_y_tomo_prof_dc = max(handles.y_tomo_prof_dc);
handles.y_tomo_spectra_dc = mean(handles.avg_y_proj_dc,2);
[handles.max_y_tomo_spectra_dc, handles.y_tomo_spectra_center_ind_dc] = max(handles.y_tomo_spectra_dc,[],1);
handles.y_spectra_center_value_tomo_dc = (handles.camera2.energy_axis(handles.y_tomo_spectra_center_ind_dc));
[junk11, handles.syag_center_val_ind_y_dc] = min(abs(handles.syag.energy_axis-handles.y_spectra_center_value_tomo_dc));
handles.y_spectra_center_value_syag_dc = handles.syag.energy_axis(handles.syag_center_val_ind_y_dc);
handles.y_syag_prof_center_before_dc = center_vec(handles.syag_profs_avg_before, handles.syag.energy_axis,...
    handles.syag_center_ind_before, handles.y_spectra_center_value_syag_dc);
handles.y_syag_prof_center_after_dc = center_vec(handles.syag_profs_avg_after, handles.syag.energy_axis,...
    handles.syag_center_ind_after, handles.y_spectra_center_value_syag_dc);
    
% Profile charge/current normalization ========================================================
speed_light = 2.998E11;
delta_z = abs(handles.z_axis(1) - handles.z_axis(2));
delta_x = abs(handles.x_axis_camera2_roi(1) - handles.x_axis_camera2_roi(2));
y_tomo_prof_charge_norm = (1E-3*(handles.toro_charge*handles.y_tomo_prof))/sum(handles.y_tomo_prof);
y_tomo_prof_charge_norm_dc = (1E-3*(handles.toro_charge*handles.y_tomo_prof_dc))/sum(handles.y_tomo_prof_dc);
handles.x_tomo_prof_charge_norm = ((1E9)*handles.toro_charge*handles.x_tomo_prof)/sum(handles.x_tomo_prof*delta_x);
y_raw_prof_avg_before_charge_norm = (1E-3*(handles.toro_charge*handles.y_raw_full_prof_avg_before))/sum(handles.y_raw_full_prof_avg_before);
y_raw_prof_avg_after_charge_norm = (1E-3*(handles.toro_charge*handles.y_raw_full_prof_avg_after))/sum(handles.y_raw_full_prof_avg_after);
handles.x_raw_prof_avg_before_charge_norm = ((1E9)*handles.toro_charge*handles.x_raw_full_prof_avg_before)/sum(handles.x_raw_full_prof_avg_before*delta_x);
handles.x_raw_prof_avg_after_charge_norm = ((1E9)*handles.toro_charge*handles.x_raw_full_prof_avg_after)/sum(handles.x_raw_full_prof_avg_after*delta_x);
handles.y_tomo_prof_current_norm = (y_tomo_prof_charge_norm*speed_light)/delta_z;
handles.y_tomo_prof_current_norm_dc = (y_tomo_prof_charge_norm_dc*speed_light)/delta_z;
handles.y_raw_prof_avg_before_current_norm = (y_raw_prof_avg_before_charge_norm*speed_light)/delta_z;
handles.y_raw_prof_avg_after_current_norm = (y_raw_prof_avg_after_charge_norm*speed_light)/delta_z;

% Correct the camera2 energy axis for fit =======================================
handles.y_tomo_spectra_centroid_bad = sum(handles.y_tomo_spectra'.*handles.camera2.energy_axis)/sum(handles.y_tomo_spectra);
handles.y_tomo_spectra_dc_centroid_bad = sum(handles.y_tomo_spectra_dc'.*handles.camera2.energy_axis)/sum(handles.y_tomo_spectra_dc);
handles.x_tomo_spectra_centroid_bad = sum(handles.x_tomo_spectra'.*handles.camera2.energy_axis)/sum(handles.x_tomo_spectra);
[junk12, handles.y_tomo_spectra_centroid_ind] = min(abs(handles.camera2.energy_axis-handles.y_tomo_spectra_centroid_bad));
[junk13, handles.y_tomo_spectra_dc_centroid_ind] = min(abs(handles.camera2.energy_axis-handles.y_tomo_spectra_dc_centroid_bad));
[junk14, handles.x_tomo_spectra_centroid_ind] = min(abs(handles.camera2.energy_axis-handles.x_tomo_spectra_centroid_bad));
handles.y_tomo_spectra_centroid = handles.camera2.energy_axis(handles.y_tomo_spectra_centroid_ind);
handles.y_tomo_spectra_dc_centroid = handles.camera2.energy_axis(handles.y_tomo_spectra_dc_centroid_ind);
handles.x_tomo_spectra_centroid = handles.camera2.energy_axis(handles.x_tomo_spectra_centroid_ind);
handles.camera2.energy_axis_shift_y = handles.camera2.energy_axis - handles.y_tomo_spectra_centroid;
handles.camera2.energy_axis_shift_y_dc = handles.camera2.energy_axis - handles.y_tomo_spectra_dc_centroid;
handles.camera2.energy_axis_shift_x = handles.camera2.energy_axis - handles.x_tomo_spectra_centroid;

% Calculate 2nd degree polynomial fits ========================================
handles.y_centroid = zeros(1, handles.slit_nstep_val);
handles.y_centroid_dc = zeros(1, handles.slit_nstep_val);
handles.x_centroid = zeros(1, handles.slit_nstep_val);
for iv = 1:handles.slit_nstep_val
    handles.y_centroid(iv) = (sum(handles.avg_y_proj(iv,:).*handles.z_axis_flip))/sum(handles.avg_y_proj(iv,:));
    handles.y_centroid_dc(iv) = (sum(handles.avg_y_proj_dc(iv,:).*handles.z_axis_flip))/sum(handles.avg_y_proj_dc(iv,:));
    handles.x_centroid(iv) = (sum(handles.avg_x_proj(iv,:).*handles.x_axis_camera2_roi))/sum(handles.avg_x_proj(iv,:));
end
handles.y_fit_coeff = polyfit(handles.camera2.energy_axis_shift_y, handles.y_centroid, 2);
handles.y_fit_coeff_dc = polyfit(handles.camera2.energy_axis_shift_y, handles.y_centroid_dc, 2);
handles.x_fit_coeff = polyfit(handles.camera2.energy_axis_shift_x, handles.x_centroid, 2);
handles.y_fit = handles.y_fit_coeff(1)*(handles.camera2.energy_axis_shift_y.^2) + handles.y_fit_coeff(2)*(handles.camera2.energy_axis_shift_y) +...
    handles.y_fit_coeff(3);
handles.y_fit_dc = handles.y_fit_coeff_dc(1)*(handles.camera2.energy_axis_shift_y_dc.^2) + handles.y_fit_coeff_dc(2)*(handles.camera2.energy_axis_shift_y_dc) +...
    handles.y_fit_coeff_dc(3);
handles.x_fit = handles.x_fit_coeff(1)*(handles.camera2.energy_axis_shift_x.^2) + handles.x_fit_coeff(2)*(handles.camera2.energy_axis_shift_x) +...
    handles.x_fit_coeff(3);

% Fit Gaussian to slices 
handles.x_slit_gauss_param = zeros(handles.slit_nstep_val,3);
h = 0.15;
for iu = 1:handles.slit_nstep_val
    x_vec = [];
    y_vec = [];
    handles.max_x_proj = max(handles.avg_x_proj(iu,:));
    for ir = 1:numel(handles.x_axis_camera2_roi)
        if handles.avg_x_proj(iu,ir)>handles.max_x_proj*h
            y_vec = [y_vec,handles.avg_x_proj(iu,ir)];
            x_vec = [x_vec,handles.x_axis_camera2_roi(ir)];
        end
    end
    ylog = log(y_vec);
    p = polyfit(x_vec,ylog,2);
    A2 = p(1);
    A1 = p(2);
    A0 = p(3);
    sigma = sqrt(-1/(2*A2));
    mu = A1*sigma^2;
    A = exp(A0+mu^2/(2*sigma^2));
    handles.x_slit_gauss_param(iu,1) = sigma;
    handles.x_slit_gauss_param(iu,2) = mu;
    handles.x_slit_gauss_param(iu,3) = A;
end
handles.x_prof_gauss_param = zeros(1,3);
x_vec = [];
y_vec =[];
for iq = 1:numel(handles.x_axis_camera2_roi)
    if handles.x_tomo_prof(iq)>handles.max_x_tomo_prof*h
        y_vec = [y_vec,handles.x_tomo_prof(iq)];
        x_vec = [x_vec,handles.x_axis_camera2_roi(iq)];
    end
end
ylog = log(y_vec);
p = polyfit(x_vec,ylog,2);
A2 = p(1);
A1 = p(2);
A0 = p(3);
sigma = sqrt(-1/(2*A2));
mu = A1*sigma^2;
A = exp(A0+mu^2/(2*sigma^2));
handles.x_prof_gauss_param(1,1) = sigma;
handles.x_prof_gauss_param(1,2) = mu;
handles.x_prof_gauss_param(1,3) = A;
sigma_ind = [];
for ip = 1:handles.slit_nstep_val
    if handles.x_slit_gauss_param(ip,1)<min(handles.x_slit_gauss_param(:,1)*2)
        sigma_ind = [sigma_ind, ip];
    end
end
handles.x_slit_sigma_cut = handles.x_slit_gauss_param(sigma_ind);
handles.avg_x_slit_sigma = mean(handles.x_slit_sigma_cut);
handles.delta_zero_index = find(handles.camera2.energy_axis_shift_x == 0);
handles.x_val_at_delta_zero = handles.x_centroid(handles.delta_zero_index);
handles.upper_x_val = zeros(1,handles.slit_nstep_val);
handles.lower_x_val = zeros(1,handles.slit_nstep_val);
handles.upper_x_val(1,:) = handles.x_val_at_delta_zero + 0.2*handles.avg_x_slit_sigma;
handles.lower_x_val(1,:) = handles.x_val_at_delta_zero - 0.2*handles.avg_x_slit_sigma;
handles.x_sigma_ratio = handles.x_prof_gauss_param(1,1)/handles.avg_x_slit_sigma;
handles.max_min_x_difference = max(handles.x_centroid) - min(handles.x_centroid);
handles.max_delta_x_to_sigma_slit_ratio = handles.max_min_x_difference/handles.avg_x_slit_sigma;

% Plot =========================================
ax_4 = handles.tomo_axes;
axes(ax_4);
cla;
switch handles.plot
    case 1
        plot_waterfall_raw(handles);
    case 2
        plot_waterfall_interp(handles);
    case 3
        plot_tomo_prof(handles);
    case 4
        plot_spectra(handles);
    case 5
        plot_fit(handles);
end

% Rest of saved data ===================================================
handles.data.raw.camera2_before = handles.raw_camera2_before;
handles.data.raw.syag_before = handles.raw_syag_before;
handles.data.raw.camera2_scan = handles.raw_camera2_scan;
handles.data.raw.syag_scan = handles.raw_syag_scan;
handles.data.raw.camera2_after = handles.raw_camera2_after;
handles.data.raw.syag_after = handles.raw_syag_after;
handles.data.inputs.n_samples = handles.slit_nsample_val;
handles.data.inputs.n_steps = handles.slit_nstep_val;
handles.data.inputs.toro_3163_charge = handles.toro_charge;
handles.data.inputs.toro_read_zero_or_good = handles.toro_good_bad;
handles.data.axes.z_axis = handles.z_axis_flip;
handles.data.axes.x_axis = handles.x_axis_camera2_roi;
handles.data.axes.syag_energy_axis = handles.syag.energy_axis;
handles.data.axes.camera2_energy_axis = handles.camera2.energy_axis;
handles.data.axes.camera2_energy_axis_shift_x = handles.camera2.energy_axis_shift_x;
handles.data.axes.camera2_energy_axis_shift_y = handles.camera2.energy_axis_shift_y;
handles.data.axes.camera2_energy_axis_shift_y_dc = handles.camera2.energy_axis_shift_y_dc;
handles.data.tomography.drift_correction_val = handles.drift_correction_val;
handles.data.tomography.camera2_y_proj_per_sample = handles.y_camera2_proj;
handles.data.tomography.camera2_x_proj_per_sample = handles.x_camera2_proj;
handles.data.tomography.camera2_y_proj_per_sample_centered = handles.y_camera2_proj_centered;
handles.data.tomography.camera2_x_proj_per_sample_centered = handles.x_camera2_proj_centered;
handles.data.tomography.z_tomography_matrix = handles.avg_y_proj;
handles.data.tomography.z_tomography_matrix_dc = handles.avg_y_proj_dc;
handles.data.tomography.x_tomography_matrix = handles.avg_x_proj;
handles.data.spectra.syag_proj_per_sample = handles.syag_proj;
handles.data.profiles.tomo_z_prof = handles.y_tomo_prof;
handles.data.profiles.tomo_z_prof_dc = handles.y_tomo_prof_dc;
handles.data.profiles.tomo_x_prof = handles.x_tomo_prof;
handles.data.profiles.tomo_z_prof_current_norm = handles.y_tomo_prof_current_norm;
handles.data.profiles.tomo_z_prof_current_norm_dc = handles.y_tomo_prof_current_norm_dc;
handles.data.profiles.tomo_x_prof_charge_norm = handles.x_tomo_prof_charge_norm;
handles.data.spectra.tomo_z_spectra = handles.y_tomo_spectra;
handles.data.spectra.tomo_z_spectra_dc = handles.y_tomo_spectra_dc;
handles.data.spectra.tomo_x_spectra = handles.x_tomo_spectra;
handles.data.profiles.raw_z_prof_before_scan = handles.y_full_profs_tcav_before;
handles.data.profiles.raw_z_prof_after_scan = handles.y_full_profs_tcav_after;
handles.data.profiles.raw_x_prof_before_scan = handles.x_full_profs_tcav_before;
handles.data.profiles.raw_x_prof_after_scan = handles.x_full_profs_tcav_after;
handles.data.profiles.centered_z_prof_avg_before_scan = handles.y_raw_full_prof_avg_before;
handles.data.profiles.centered_z_prof_avg_after_scan = handles.y_raw_full_prof_avg_after;
handles.data.profiles.centered_x_prof_avg_before_scan = handles.x_raw_full_prof_avg_before;
handles.data.profiles.centered_x_prof_avg_after_scan = handles.x_raw_full_prof_avg_after;
handles.data.profiles.centered_z_prof_avg_before_scan_current_norm = handles.y_raw_prof_avg_before_current_norm;
handles.data.profiles.centered_z_prof_avg_after_scan_current_norm = handles.y_raw_prof_avg_after_current_norm;
handles.data.profiles.centered_x_prof_avg_before_scan_charge_norm = handles.x_raw_prof_avg_before_charge_norm;
handles.data.profiles.centered_x_prof_avg_after_scan_charge_norm = handles.x_raw_prof_avg_after_charge_norm;
handles.data.spectra.syag_prof_avg_before_scan = handles.syag_profs_avg_before;
handles.data.spectra.syag_prof_avg_after_scan = handles.syag_profs_avg_after;
handles.data.spectra.centered_z_syag_prof_avg_before_scan = handles.y_syag_prof_center_before;
handles.data.spectra.centered_z_syag_prof_avg_after_scan = handles.y_syag_prof_center_after;
handles.data.spectra.centered_z_syag_prof_avg_before_scan_dc = handles.y_syag_prof_center_before_dc;
handles.data.spectra.centered_z_syag_prof_avg_after_scan_dc = handles.y_syag_prof_center_after_dc;
handles.data.spectra.centered_x_syag_prof_avg_before_scan = handles.x_syag_prof_center_before;
handles.data.spectra.centered_x_syag_prof_avg_after_scan = handles.x_syag_prof_center_after;
handles.data.fits.y_centroids = handles.y_centroid;
handles.data.fits.x_centroids = handles.x_centroid;
handles.data.fits.y_fit_coeff = handles.y_fit_coeff;
handles.data.fits.x_fit_coeff = handles.x_fit_coeff;
handles.data.fits.y_fit = handles.y_fit;
handles.data.fits.x_fit = handles.x_fit;
handles.data.fits.x_slit_gauss_param = handles.x_slit_gauss_param;
handles.data.fits.x_slit_sigma_cut = handles.x_slit_sigma_cut;
handles.data.fits.x_tomo_prof_gauss_param = handles.x_prof_gauss_param;
handles.data.fits.twenty_percent_sigma_upper = handles.upper_x_val;
handles.data.fits.twenty_percent_sigma_lower = handles.lower_x_val;
handles.data.fits.x_sigma_proj_to_slice_ratio = handles.x_sigma_ratio;
handles.data.fits.max_delta_x_to_sigma_ratio = handles.max_delta_x_to_sigma_slit_ratio;

function plot_waterfall_raw(handles)
% handles.waterfall_raw = imagesc(handles.z_axis_flip, handles.camera2.energy_axis, handles.avg_y_proj);
switch handles.proj_xz
    case 1
        if handles.drift_check_on == 1
            handles.waterfall_raw = pcolor(handles.z_axis_flip, handles.camera2.energy_axis_shift_y_dc, handles.avg_y_proj_dc);
        else
            handles.waterfall_raw = pcolor(handles.z_axis_flip, handles.camera2.energy_axis_shift_y, handles.avg_y_proj);
        end
        shading flat;
        xlabel('z [mm]');
        ylabel('\delta');
        title(strcat({'Tomography(z) '},handles.plot_str));
    case 2
        handles.waterfall_raw = pcolor(handles.x_axis_camera2_roi, handles.camera2.energy_axis_shift_x, handles.avg_x_proj);
        shading flat;
        xlabel('x [mm]');
        ylabel('\delta');
        title(strcat({'Tomography(x) '},handles.plot_str));
end

function plot_waterfall_interp(handles)
% handles.waterfall_interp = imagesc(handles.z_axis_flip, handles.camera2.energy_axis, handles.avg_y_proj);
switch handles.proj_xz
    case 1
        if handles.drift_check_on == 1
            handles.waterfall_interp = pcolor(handles.z_axis_flip, handles.camera2.energy_axis_shift_y_dc, handles.avg_y_proj_dc);
        else
            handles.waterfall_interp = pcolor(handles.z_axis_flip, handles.camera2.energy_axis_shift_y, handles.avg_y_proj);
        end
        shading interp;
        xlabel('z [mm]');
        ylabel('\delta');
        title(strcat({'Tomography(z) '},handles.plot_str));
    case 2
        handles.waterfall_raw = pcolor(handles.x_axis_camera2_roi, handles.camera2.energy_axis_shift_x, handles.avg_x_proj);
        shading interp;
        xlabel('x [mm]');
        ylabel('\delta');
        title(strcat({'Tomography(x) '},handles.plot_str));
end

function plot_tomo_prof(handles)
switch handles.proj_xz
    case 1
        if handles.drift_check_on == 1
            plot(handles.z_axis_flip, handles.y_tomo_prof_current_norm_dc,'b');
        else
            plot(handles.z_axis_flip, handles.y_tomo_prof_current_norm,'b');
        end
        hold on;
        plot(handles.z_axis_flip, handles.y_raw_prof_avg_before_current_norm,'r');
        plot(handles.z_axis_flip, handles.y_raw_prof_avg_after_current_norm,'g');
        max_y_tomo = max(handles.y_tomo_prof_current_norm);
        max_y_tomo_dc = max(handles.y_tomo_prof_current_norm_dc);
        max_y_before = max(handles.y_raw_prof_avg_before_current_norm);
        max_y_after = max(handles.y_raw_prof_avg_after_current_norm);
        if handles.drift_check_on == 1
            y_axis_max = max(max_y_tomo_dc, max(max_y_before, max_y_after));
        else
            y_axis_max = max(max_y_tomo, max(max_y_before, max_y_after));
        end
        axis([min(handles.z_axis_flip(1), handles.z_axis_flip(end))...
            max(handles.z_axis_flip(1), handles.z_axis_flip(end)) 0 1.5*y_axis_max]);
        legend('Tomography(z)','Before scan','After scan','location','northeast');
        xlabel('z [mm]');
        ylabel('Current [kA]');
        title(strcat({'Tomography(z) '},handles.plot_str,' Profile Projection vs.',' Raw'));
        hold off;
    case 2
        plot(handles.x_axis_camera2_roi, handles.x_tomo_prof_charge_norm,'b');
        hold on;
        plot(handles.x_axis_camera2_roi, handles.x_raw_prof_avg_before_charge_norm,'r');
        plot(handles.x_axis_camera2_roi, handles.x_raw_prof_avg_after_charge_norm,'g');
        max_x_tomo = max(handles.x_tomo_prof_charge_norm);
        max_x_before = max(handles.x_raw_prof_avg_before_charge_norm);
        max_x_after = max(handles.x_raw_prof_avg_after_charge_norm);
        y_axis_max = max(max_x_tomo, max(max_x_before, max_x_after));
        axis([min(handles.x_axis_camera2_roi(1), handles.x_axis_camera2_roi(end))...
            max(handles.x_axis_camera2_roi(1), handles.x_axis_camera2_roi(end)) 0 1.5*y_axis_max]);
        legend('Tomography','Before scan','After scan','location','northeast');
        xlabel('x [mm]');
        ylabel('Charge [nC/mm]');
        title(strcat({'Tomography(x) '},handles.plot_str,' Profile Projection vs.',' Raw'));
        hold off;
end


function plot_spectra(handles)
switch handles.proj_xz
    case 1
        handles.camera2_delta_e = abs(handles.camera2.energy_axis(2)-handles.camera2.energy_axis(1));
        handles.syag_delta_e = abs(handles.syag.energy_axis(2)-handles.syag.energy_axis(1));
        handles.y_tomo_spectra_norm = ((1E9)*handles.toro_charge*handles.y_tomo_spectra)/sum(handles.y_tomo_spectra*handles.camera2_delta_e);
        % handles.y_tomo_spectra_norm = handles.y_tomo_spectra/sum(handles.y_tomo_spectra);
        handles.y_tomo_spectra_norm_dc = ((1E9)*handles.toro_charge*handles.y_tomo_spectra_dc)/sum(handles.y_tomo_spectra_dc*handles.camera2_delta_e);
        if handles.drift_check_on == 1
            plot(handles.camera2.energy_axis,handles.y_tomo_spectra_norm_dc,'b');
            y_tomo_max_dc = max(handles.y_tomo_spectra_norm_dc);
        else
            plot(handles.camera2.energy_axis, handles.y_tomo_spectra_norm, 'b');
             y_tomo_max = max(handles.y_tomo_spectra_norm);
        end
        hold on;
        if handles.drift_check_on == 1
            handles.syag_profs_norm_before_dc = ((1E9)*handles.toro_charge*handles.y_syag_prof_center_before_dc)/sum(handles.y_syag_prof_center_before_dc*handles.syag_delta_e);
            handles.syag_profs_norm_after_dc = ((1E9)*handles.toro_charge*handles.y_syag_prof_center_after_dc)/sum(handles.y_syag_prof_center_after_dc*handles.syag_delta_e);
            plot(handles.syag.energy_axis, handles.syag_profs_norm_before_dc, 'r');
            plot(handles.syag.energy_axis, handles.syag_profs_norm_after_dc, 'g');
            y_max_before_dc = max(handles.syag_profs_norm_before_dc);
            y_max_after_dc = max(handles.syag_profs_norm_after_dc);
        else
            handles.syag_profs_norm_before = ((1E9)*handles.toro_charge*handles.y_syag_prof_center_before)/sum(handles.y_syag_prof_center_before*handles.syag_delta_e);
            handles.syag_profs_norm_after = ((1E9)*handles.toro_charge*handles.y_syag_prof_center_after)/sum(handles.y_syag_prof_center_after*handles.syag_delta_e);
            plot(handles.syag.energy_axis, handles.syag_profs_norm_before, 'r');
            plot(handles.syag.energy_axis, handles.syag_profs_norm_after, 'g');
            y_max_before = max(handles.syag_profs_norm_before);
            y_max_after = max(handles.syag_profs_norm_after);
        end
        if handles.drift_check_on == 1
            y_axis_max = max(y_tomo_max_dc, max(y_max_before_dc, y_max_after_dc));
        else
            y_axis_max = max(y_tomo_max, max(y_max_before, y_max_after));
        end
        axis([min(handles.camera2.energy_axis(1), handles.syag.energy_axis(1))...
            max(handles.camera2.energy_axis(end), handles.syag.energy_axis(end))...
            0 1.5*y_axis_max]);
        legend('Tomography(z)','SYAG before','SYAG after','location','northeast');
        xlabel('\delta');
        ylabel('Charge [nC/\delta]');
        title(strcat({'Tomography(z) '}, handles.plot_str,' Spectra vs.',' sYAG Energy Spectra'));
        hold off;
    case 2
        handles.camera2_delta_e = abs(handles.camera2.energy_axis(2)-handles.camera2.energy_axis(1));
        handles.syag_delta_e = abs(handles.syag.energy_axis(2)-handles.syag.energy_axis(1));
        handles.x_tomo_spectra_norm = ((1E9)*handles.toro_charge*handles.x_tomo_spectra)/sum(handles.x_tomo_spectra*handles.camera2_delta_e);
        % handles.x_tomo_spectra_norm = handles.y_tomo_spectra/sum(handles.y_tomo_spectra);
        plot(handles.camera2.energy_axis, handles.x_tomo_spectra_norm, 'b');
        hold on;
        handles.syag_profs_norm_before = ((1E9)*handles.toro_charge*handles.x_syag_prof_center_before)/sum(handles.x_syag_prof_center_before*handles.syag_delta_e);
        handles.syag_profs_norm_after = ((1E9)*handles.toro_charge*handles.x_syag_prof_center_after)/sum(handles.x_syag_prof_center_after*handles.syag_delta_e);
        plot(handles.syag.energy_axis, handles.syag_profs_norm_before, 'r');
        plot(handles.syag.energy_axis, handles.syag_profs_norm_after, 'g');
        x_tomo_max = max(handles.x_tomo_spectra_norm);
        x_max_before = max(handles.syag_profs_norm_before);
        x_max_after = max(handles.syag_profs_norm_after);
        y_axis_max = max(x_tomo_max, max(x_max_before,x_max_after));
        axis([min(handles.camera2.energy_axis(1), handles.syag.energy_axis(1))...
            max(handles.camera2.energy_axis(end), handles.syag.energy_axis(end))...
            0 1.5*y_axis_max]);
        legend('Tomography(x)','SYAG before','SYAG after','location','northeast');
        xlabel('\delta');
        ylabel('Charge [nC/\delta]');
        title(strcat({'Tomography(x) '}, handles.plot_str,' Spectra vs.',' sYAG Energy Spectra'));
        hold off;
end

function plot_fit(handles)
switch handles.proj_xz
    case 1
        if handles.drift_check_on == 1
            plot(handles.camera2.energy_axis_shift_y_dc, handles.y_centroid_dc, '*b');
            hold on;
            plot(handles.camera2.energy_axis_shift_y_dc, handles.y_fit_dc, '--b');
            legend('Tomography(z) Centroid', ['Fit = ' num2str(handles.y_fit_coeff_dc(1),'%.2f') '*{\delta}^{2} + ' ...
                num2str(handles.y_fit_coeff_dc(2), '%.2f') '*\delta + ' num2str(handles.y_fit_coeff_dc(3),'%.2f')]);
            y_axis_min = min(min(handles.y_fit_dc, handles.y_centroid_dc));
            y_axis_max = max(max(handles.y_fit, handles.y_centroid_dc));
            y_axis_min = y_axis_min - 0.1*(y_axis_max - y_axis_min);
            y_axis_max = 0.5*(y_axis_max - y_axis_min) + y_axis_max;
            x_axis_min = min(handles.camera2.energy_axis_shift_y_dc) - (handles.scan_slit_width_val/2)/handles.dispersion_value;
            x_axis_max = max(handles.camera2.energy_axis_shift_y_dc) + (handles.scan_slit_width_val/2)/handles.dispersion_value;
            axis([x_axis_min x_axis_max y_axis_min y_axis_max]);
        else
            plot(handles.camera2.energy_axis_shift_y, handles.y_centroid, '*b');
            hold on;
            plot(handles.camera2.energy_axis_shift_y, handles.y_fit, '--b');
            legend('Tomography(z) Centroid', ['Fit = ' num2str(handles.y_fit_coeff(1),'%.2f') '*{\delta}^{2} + ' ...
                num2str(handles.y_fit_coeff(2), '%.2f') '*\delta + ' num2str(handles.y_fit_coeff(3),'%.2f')]);
            y_axis_min = min(min(handles.y_fit, handles.y_centroid));
            y_axis_max = max(max(handles.y_fit, handles.y_centroid));
            y_axis_min = y_axis_min - 0.1*(y_axis_max - y_axis_min);
            y_axis_max = 0.5*(y_axis_max - y_axis_min) + y_axis_max;
            x_axis_min = min(handles.camera2.energy_axis_shift_y) - (handles.scan_slit_width_val/2)/handles.dispersion_value;
            x_axis_max = max(handles.camera2.energy_axis_shift_y) + (handles.scan_slit_width_val/2)/handles.dispersion_value;
            axis([x_axis_min x_axis_max y_axis_min y_axis_max]);
        end
        xlabel('\delta');
        ylabel('z [mm]');
        title(strcat({'Tomography(z) Centroid Fit '},handles.plot_str));
        hold off;
    case 2
        plot(handles.camera2.energy_axis_shift_x, handles.x_centroid, '*b');
        hold on;
        plot(handles.camera2.energy_axis_shift_x, handles.x_fit, '--b');
        plot(handles.camera2.energy_axis_shift_x, handles.upper_x_val, '-.r');
        plot(handles.camera2.energy_axis_shift_x, handles.lower_x_val, '-.r');
        legend('Tomography(x) Centroid', ['Fit = ' num2str(handles.x_fit_coeff(1),'%.2f') '*{\delta}^{2} + ' ...
            num2str(handles.x_fit_coeff(2), '%.2f') '*\delta + ' num2str(handles.x_fit_coeff(3),'%.2f')],...
            '+/- 0.2*\sigma_{slice avg}');
        y_axis_min = min(min(handles.lower_x_val,min(handles.x_fit, handles.x_centroid)));
        y_axis_max = max(max(handles.upper_x_val,max(handles.x_fit, handles.x_centroid)));
        y_axis_min = y_axis_min - 0.75*(y_axis_max - y_axis_min);
        y_axis_max = 0.75*(y_axis_max - y_axis_min) + y_axis_max;
        x_axis_min = min(handles.camera2.energy_axis_shift_x) - (handles.scan_slit_width_val/2)/handles.dispersion_value;
        x_axis_max = max(handles.camera2.energy_axis_shift_x) + (handles.scan_slit_width_val/2)/handles.dispersion_value;
        axis([x_axis_min x_axis_max y_axis_min y_axis_max]);
        text(x_axis_min + 0.015*(x_axis_max - x_axis_min),y_axis_min + 0.05*(y_axis_max - y_axis_min), ['(\sigma_{proj}/\sigma_{slice avg} = ' num2str(handles.x_sigma_ratio,'%.2f')...
            '; \Delta_{xmax-xmin}/\sigma_{slice avg} = ' num2str(handles.max_delta_x_to_sigma_slit_ratio,'%.2f') ')']);
        xlabel('\delta');
        ylabel('x [mm]');
        title(strcat({'Tomography(x) Centroid Fit '},handles.plot_str))
        hold off;
end

function handles = calc_nsamples(handles)
handles.slit_nstep_val = ceil((handles.slit_end_pos_val - handles.slit_start_pos_val)/...
    (handles.scan_slit_width_val) + 1);
handles.slit_nstep_str = num2str(handles.slit_nstep_val);


% --- Executes on button press in start_set_slit.
function start_set_slit_Callback(hObject, eventdata, handles)
% hObject    handle to start_set_slit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_gui(handles);
global imdata2;

if handles.do_scan == 1
    lcaPutSmart('SIOC:SYS1:ML01:AO075',handles.set_slit_width_val);
    set_slit(handles.slit_position_val);
end
imdata2 = profmon_grab(handles.camera_PV_inuse);
% set(hObject, 'String', 'Setting');
set(hObject, 'Enable', 'on');
gui_statusDisp(handles, 'Setting finished.');
pause (3);
update_syag_im(handles);
update_camera2_im(handles);
guidata(hObject, handles);
% update_syag_im(handles);
% update_camera2_im(handles);


% --- Executes on button press in start_scan_slit.
function start_scan_slit_Callback(hObject, eventdata, handles)
% hObject    handle to start_scan_slit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
handles.issaved = 0;
handles = update_gui(handles);
global imdata2;
global camera2_box;
global syag_box;

handles.data.ts = now;
handles.data.ts_date = datestr(now);
handles.data.inputs.camera_PVs_used = handles.camera_PV_inuse;
test_camera_PV_str = strmatch(handles.camera_PV_inuse{2}, handles.camera_PVList, 'exact');
if isempty(test_camera_PV_str)
    handles.camera_names_inuse = {'SYAG',handles.camera_PV_inuse{2}};
    handles.data.inputs.cameras_used = handles.camera_names_inuse;
else
    handles.data.inputs.cameras_used = handles.camera_names_inuse;
end
handles.plot_str = handles.camera_names_inuse{2};
if handles.do_scan == 1
    lcaPutSmart('SIOC:SYS1:ML01:AO075',handles.scan_slit_width_val);
end
if handles.do_scan == 1
    lcaPutSmart('COLL:LI20:2072:MOTR',3000);
    lcaPutSmart('COLL:LI20:2085:MOTR.VAL',-3);
    lcaPutSmart('COLL:LI20:2086:MOTR.VAL',3);
while abs(lcaGetSmart('COLL:LI20:2072:MOTR.RBV') - lcaGetSmart('COLL:LI20:2072:MOTR')) > 10; end;
while abs(lcaGetSmart('COLL:LI20:2085:MOTR.RBV') - lcaGetSmart('COLL:LI20:2085:MOTR')) > 0.05; end;
while abs(lcaGetSmart('COLL:LI20:2086:MOTR.RBV') - lcaGetSmart('COLL:LI20:2086:MOTR')) > 0.05; end;
end
handles.data.tomography.step_ts = zeros(handles.slit_nstep_val + 2, 1);
handles.raw_camera2_before = zeros(camera2_box(4)-camera2_box(3)+1,camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val);
handles.raw_syag_before = zeros(syag_box(4)-syag_box(3)+1,syag_box(2)-syag_box(1)+1, handles.slit_nsample_val);
handles.y_full_profs_tcav_before = zeros(camera2_box(4)-camera2_box(3)+1, handles.slit_nsample_val);
handles.x_full_profs_tcav_before = zeros(camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val);
handles.syag_profs_before = zeros(syag_box(2)-syag_box(1)+1, handles.slit_nsample_val);
electron_charge = 1.602E-19;
handles.toro_charge_raw = lcaGetSmart('GADC0:LI20:EX01:CALC:CH2');
handles.toro_good_bad = 'good';
if handles.toro_charge_raw == 0
    handles.toro_charge_raw = 2e10;
    handles.toro_good_bad = 'bad';
end
handles.toro_charge = handles.toro_charge_raw*electron_charge;
tic;
handles.data.tomography.step_ts(1) = toc;
for iz = 1:handles.slit_nsample_val
    imdata2 = profmon_grab(handles.camera_PV_inuse);
    handles.raw_camera2_before(:,:,iz) = imdata2(2).img(camera2_box(3):camera2_box(4),camera2_box(1):camera2_box(2));
    handles.raw_syag_before(:,:,iz) = imdata2(1).img(syag_box(3):syag_box(4),syag_box(1):syag_box(2));
    handles.y_full_profs_tcav_before(:,iz) = mean(handles.raw_camera2_before(:,:,iz),2);
    handles.x_full_profs_tcav_before(:,iz) = mean(handles.raw_camera2_before(:,:,iz),1);
    handles.syag_profs_before(:,iz) = mean(handles.raw_syag_before(:,:,iz),1);
    update_syag_im(handles);
    update_camera2_im(handles);
    update_tcav_raw(handles);
end
handles.scan_range = linspace(handles.slit_start_pos_val,handles.slit_end_pos_val,handles.slit_nstep_val);
handles.raw_camera2_scan = zeros(camera2_box(4)-camera2_box(3)+1, camera2_box(2)-camera2_box(1)+1, handles.slit_nstep_val*handles.slit_nsample_val);
handles.raw_syag_scan = zeros(syag_box(4)-syag_box(3)+1, syag_box(2)-syag_box(1)+1, handles.slit_nstep_val*handles.slit_nsample_val);
handles.y_camera2_proj = zeros(camera2_box(4)-camera2_box(3)+1, handles.slit_nsample_val, handles.slit_nstep_val);
handles.x_camera2_proj = zeros(camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val, handles.slit_nstep_val);
handles.syag_proj = zeros(syag_box(2)-syag_box(1)+1, handles.slit_nsample_val, handles.slit_nstep_val);
for ix = 1:handles.slit_nstep_val
    if handles.do_scan == 1
        set_slit(handles.scan_range(ix));
        pause (3);
    end
    handles.data.tomography.step_ts(ix + 1) = toc;
    for iy = 1:handles.slit_nsample_val
        imdata2 = profmon_grab(handles.camera_PV_inuse);
        handles.raw_camera2_scan(:,:,iy + handles.slit_nsample_val*(ix-1)) = ...
            imdata2(2).img(camera2_box(3):camera2_box(4), camera2_box(1):camera2_box(2));
        camera2_roi_y_proj = mean(handles.raw_camera2_scan(:,:,iy + handles.slit_nsample_val*(ix-1)),2);
        camera2_roi_x_proj = mean(handles.raw_camera2_scan(:,:,iy + handles.slit_nsample_val*(ix-1)),1);
        handles.raw_syag_scan(:,:,iy + handles.slit_nsample_val*(ix-1)) = ...
            imdata2(1).img(syag_box(3):syag_box(4), syag_box(1):syag_box(2));
        syag_roi_proj = mean(handles.raw_syag_scan(:,:,iy + handles.slit_nsample_val*(ix-1)),1);
        handles.y_camera2_proj(:,iy,ix) = camera2_roi_y_proj;
        handles.x_camera2_proj(:,iy,ix) = camera2_roi_x_proj;
        handles.syag_proj(:,iy,ix) = syag_roi_proj;
        update_syag_im(handles);
        update_camera2_im(handles);
    end
end
if handles.do_scan == 1
    lcaPutSmart('COLL:LI20:2072:MOTR',3000);
    lcaPutSmart('COLL:LI20:2085:MOTR.VAL',-3);
    lcaPutSmart('COLL:LI20:2086:MOTR.VAL',3);
while abs(lcaGetSmart('COLL:LI20:2072:MOTR.RBV') - lcaGetSmart('COLL:LI20:2072:MOTR')) > 10; end;
while abs(lcaGetSmart('COLL:LI20:2085:MOTR.RBV') - lcaGetSmart('COLL:LI20:2085:MOTR.VAL')) > 0.05; end;
while abs(lcaGetSmart('COLL:LI20:2086:MOTR.RBV') - lcaGetSmart('COLL:LI20:2086:MOTR.VAL')) > 0.05; end;
end
handles.raw_camera2_after = zeros(camera2_box(4)-camera2_box(3)+1,camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val);
handles.raw_syag_after = zeros(syag_box(4)-syag_box(3)+1,syag_box(2)-syag_box(1)+1, handles.slit_nsample_val);
handles.y_full_profs_tcav_after = zeros(camera2_box(4)-camera2_box(3)+1, handles.slit_nsample_val);
handles.x_full_profs_tcav_after = zeros(camera2_box(2)-camera2_box(1)+1, handles.slit_nsample_val);
handles.syag_profs_after = zeros(syag_box(2)-syag_box(1)+1, handles.slit_nsample_val);
handles.data.tomography.step_ts(handles.slit_nstep_val + 2) = toc;
for iw = 1:handles.slit_nsample_val
    imdata2 = profmon_grab(handles.camera_PV_inuse);
    handles.raw_camera2_after(:,:,iw) = imdata2(2).img(camera2_box(3):camera2_box(4),camera2_box(1):camera2_box(2));
    handles.raw_syag_after(:,:,iw) = imdata2(1).img(syag_box(3):syag_box(4),syag_box(1):syag_box(2));
    handles.y_full_profs_tcav_after(:,iw) = mean(handles.raw_camera2_after(:,:,iw),2);
    handles.x_full_profs_tcav_after(:,iw) = mean(handles.raw_camera2_after(:,:,iw),1);
    handles.syag_profs_after(:,iw) = mean(handles.raw_syag_after(:,:,iw),1);
    update_syag_im(handles);
    update_camera2_im(handles);
    update_tcav_raw(handles);
end
% set(hObject, 'String', 'Acquire');
set(hObject, 'Enable', 'on');
gui_statusDisp(handles, 'Acquisition finished.');
handles = analyze_data(handles);
guidata(hObject, handles);


function scan_slit_width_box_Callback(hObject, eventdata, handles)
% hObject    handle to scan_slit_width_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.scan_slit_width_str = get(hObject,'String');
handles.scan_slit_width_val= str2num(handles.scan_slit_width_str);
handles = calc_nsamples(handles);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of scan_slit_width_box as text
%        str2double(get(hObject,'String')) returns contents of scan_slit_width_box as a double


% --- Executes during object creation, after setting all properties.
function scan_slit_width_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_slit_width_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slit_start_pos_box_Callback(hObject, eventdata, handles)
% hObject    handle to slit_start_pos_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global syag_rect;
handles.slit_start_pos_str = get(hObject,'String');
handles.slit_start_pos_val= str2num(handles.slit_start_pos_str);
% syag_rect(1) = handles.slit_start_pos_val;
% update_syag_im(handles);
handles = calc_nsamples(handles);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of slit_start_pos_box as text
%        str2double(get(hObject,'String')) returns contents of slit_start_pos_box as a double


% --- Executes during object creation, after setting all properties.
function slit_start_pos_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slit_start_pos_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slit_end_pos_box_Callback(hObject, eventdata, handles)
% hObject    handle to slit_end_pos_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global syag_rect;
handles.slit_end_pos_str = get(hObject,'String');
handles.slit_end_pos_val= str2num(handles.slit_end_pos_str);
% syag_rect(3) = handles.slit_end_pos_val - handles.slit_start_pos_val;
% update_syag_im(handles);
handles = calc_nsamples(handles);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of slit_end_pos_box as text
%        str2double(get(hObject,'String')) returns contents of slit_end_pos_box as a double


% --- Executes during object creation, after setting all properties.
function slit_end_pos_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slit_end_pos_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slit_nstep_box_Callback(hObject, eventdata, handles)
% hObject    handle to slit_nstep_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.slit_nstep_str = get(hObject,'String');
handles.slit_nstep_val= str2num(handles.slit_nstep_str);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of slit_nstep_box as text
%        str2double(get(hObject,'String')) returns contents of slit_nstep_box as a double


% --- Executes during object creation, after setting all properties.
function slit_nstep_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slit_nstep_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slit_nsample_box_Callback(hObject, eventdata, handles)
% hObject    handle to slit_nsample_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.slit_nsample_str = get(hObject,'String');
handles.slit_nsample_val= str2num(handles.slit_nsample_str);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of slit_nsample_box as text
%        str2double(get(hObject,'String')) returns contents of slit_nsample_box as a double


% --- Executes during object creation, after setting all properties.
function slit_nsample_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slit_nsample_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispersion_selection.
function dispersion_selection_Callback(hObject, eventdata, handles)
% hObject    handle to dispersion_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dispersionID = get(hObject,'Value');
handles.dispersionPV = handles.dispersion_PVList{handles.dispersionID};
handles.dispersion_value = lcaGetSmart(handles.dispersionPV);
handles.dispersion_str = num2str(handles.dispersion_value);
set(handles.dispersion_box,'String',handles.dispersion_str);
if ~isempty(handles.camera2.energy_axis)
    handles = analyze_data(handles);
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of dispersion_selection

function dispersion_box_Callback(hObject, eventdata, handles)
% hObject    handle to dispersion_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dispersion_str = get(hObject,'String');
handles.dispersion_value = str2num(handles.dispersion_str);
handles = update_gui(handles);
if ~isempty(handles.camera2.energy_axis)
    handles = analyze_data(handles);
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of dispersion_box as text
%        str2double(get(hObject,'String')) returns contents of dispersion_box as a double


% --- Executes during object creation, after setting all properties.
function dispersion_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispersion_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tcav_cal_box_Callback(hObject, eventdata, handles)
% hObject    handle to tcav_cal_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.tcav_cal_str = get(hObject,'String');
handles.tcav_cal_val = str2num(handles.tcav_cal_str);
handles = update_gui(handles);
if ~isempty(handles.data.ts)
    handles = analyze_data(handles);
end
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of tcav_cal_box as text
%        str2double(get(hObject,'String')) returns contents of tcav_cal_box as a double


% --- Executes during object creation, after setting all properties.
function tcav_cal_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tcav_cal_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function syag_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to syag_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global syag_box;
global syag_rect;


if handles.syag_lineout == 0
    return
else
    hold all;
    ax_1 = handles.syag_axes;
    axes(ax_1);
    point1 = get(ax_1,'CurrentPoint');
    finalRect = rbbox;
    point2 = get(ax_1,'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    p1 = min(point1,point2);
    p2 = max(point1,point2);
    [junk1, min_x_ind] = min(abs(handles.syag.x_axis - p1(1)));
    [junk2, max_x_ind] = min(abs(handles.syag.x_axis - p2(1)));
    [junk3, min_y_ind] = min(abs(handles.syag.y_axis - p1(2)));
    [junk4, max_y_ind] = min(abs(handles.syag.y_axis - p2(2)));
    syag_box = [min_x_ind max_x_ind min_y_ind max_y_ind];
    min_x_value = handles.syag.x_axis(min_x_ind);
    max_x_value = handles.syag.x_axis(max_x_ind);
    min_y_value = handles.syag.y_axis(min_y_ind);
    max_y_value = handles.syag.y_axis(max_y_ind);
    syag_rect = [min_x_value, min_y_value, (max_x_value - min_x_value), (max_y_value - min_y_value)];
    hold off;
    update_syag_im(handles);
    handles = update_gui(handles);
end


% --- Executes on mouse press over axes background.
function camera2_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to camera2_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global camera2_box;
global camera2_rect;

if handles.camera2_lineout == 0
    return
else
    hold all;
    ax_2 = handles.camera2_axes;
    axes(ax_2);
    point1 = get(ax_2,'CurrentPoint');
    finalRect = rbbox;
    point2 = get(ax_2,'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    p1 = min(point1,point2);
    p2 = max(point1,point2);
    [junk1, min_x_ind] = min(abs(handles.camera2.x_axis - p1(1)));
    [junk2, max_x_ind] = min(abs(handles.camera2.x_axis - p2(1)));
    [junk3, min_y_ind] = min(abs(handles.camera2.y_axis_flip - p1(2)));
    [junk4, max_y_ind] = min(abs(handles.camera2.y_axis_flip - p2(2)));
    camera2_box = [min_x_ind max_x_ind max_y_ind min_y_ind];
    min_x_value = handles.camera2.x_axis(min_x_ind);
    max_x_value = handles.camera2.x_axis(max_x_ind);
    min_y_value = handles.camera2.y_axis_flip(min_y_ind);
    max_y_value = handles.camera2.y_axis_flip(max_y_ind);
    camera2_rect = [min_x_value, min_y_value, (max_x_value - min_x_value), (max_y_value - min_y_value)];
    hold off;
    update_camera2_im(handles);
    handles = update_gui(handles);
end


% --- Executes on button press in syag_ROI.
function syag_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to syag_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global syag_box;
global syag_rect;
syag_box = [];
syag_rect = [];
axes(handles.syag_axes);
update_syag_im(handles);
handles = update_gui(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of syag_ROI


% --- Executes on button press in camera2_ROI.
function camera2_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to camera2_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global camera2_box;
global camera2_rect;
camera2_box = [];
camera2_rect = [];
axes(handles.camera2_axes);
update_camera2_im(handles);
handles = update_gui(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of camera2_ROI



function set_slit_width_box_Callback(hObject, eventdata, handles)
% hObject    handle to set_slit_width_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.set_slit_width_str = get(hObject,'String');
handles.set_slit_width_val= str2num(handles.set_slit_width_str);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of set_slit_width_box as text
%        str2double(get(hObject,'String')) returns contents of set_slit_width_box as a double


% --- Executes during object creation, after setting all properties.
function set_slit_width_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to set_slit_width_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slit_position_box_Callback(hObject, eventdata, handles)
% hObject    handle to slit_position_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user dataspectra_fig = figure;
handles.slit_position_str = get(hObject,'String');
handles.slit_position_val= str2num(handles.slit_position_str);
handles = update_gui(handles);
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of slit_position_box as text
%        str2double(get(hObject,'String')) returns contents of slit_position_box as a double


% --- Executes during object creation, after setting all properties.
function slit_position_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slit_position_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in print_and_save.
function print_and_save_Callback(hObject, eventdata, handles)
% hObject    handle to print_and_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.proj_xz
    case 1
        if handles.drift_check_on == 1
            drift_str = ('TCAV Drift Correction ON');
        else
            drift_str = ('TCAV Drift Correction Off');
        end
        
        tcav_raw_fig = figure;
        plot_tcav_raw(handles);
        title([handles.plot_str ' Fully Open ' handles.data.ts_date]);
        util_printLog(tcav_raw_fig,'title',strcat(handles.plot_str,' Fully Open After Tomography Scan'));
        
        raw_fig = figure;
        map = custom_cmap();
        colormap(map.wbgyr);
        plot_waterfall_raw(handles);
        title(['Tomography(z) ' handles.plot_str handles.data.ts_date]);
        util_printLog(raw_fig,'title',strcat(handles.plot_str,' Flat Tomography(z)'),'text',drift_str);
        
        interp_fig = figure;
        map = custom_cmap();
        colormap(map.wbgyr);
        plot_waterfall_interp(handles);
        title(['Tomography(z) ' handles.plot_str handles.data.ts_date]);
        util_printLog(interp_fig,'title',strcat(handles.plot_str,' Interpolated Tomography(z)'),'text',drift_str);
        
        prof_fig = figure;
        plot_tomo_prof(handles);
        title(['Tomography(z) Profile Projection ' handles.plot_str handles.data.ts_date])
        util_printLog(prof_fig,'title',strcat({'Tomography(z) '},handles.plot_str,' Profile Projection vs.',' Raw Projection'),'text',drift_str);
        
        spectra_fig = figure;
        plot_spectra(handles);
        title(['Tomography(z) Energy Spectra ' handles.plot_str handles.data.ts_date]);
        util_printLog(spectra_fig,'title',strcat({'Tomography(z) '},handles.plot_str,' Spectra vs. sYAG Energy Spectra'),'text',drift_str);
        
        fit_fig = figure;
        plot_fit(handles);
        title(['Tomography(z) Centroid Fit ' handles.plot_str handles.data.ts_date]);
        util_printLog(fit_fig,'title',strcat({'Tomography(z) Centroid Fit '},handles.plot_str),'text',drift_str);
        
    case 2
        tcav_raw_fig = figure;
        plot_tcav_raw(handles);
        title([handles.plot_str ' Fully Open ' handles.data.ts_date]);
        util_printLog(tcav_raw_fig,'title',strcat(handles.plot_str,' Fully Open After from Tomography Scan'));
        
        raw_fig = figure;
        map = custom_cmap();
        colormap(map.wbgyr);
        plot_waterfall_raw(handles);
        title(['Tomography(x) ' handles.plot_str handles.data.ts_date]);
        util_printLog(raw_fig,'title',strcat(handles.plot_str,' Flat Tomography(x)'));
        
        interp_fig = figure;
        map = custom_cmap();
        colormap(map.wbgyr);
        plot_waterfall_interp(handles);
        title(['Tomography(x) ' handles.plot_str handles.data.ts_date]);
        util_printLog(interp_fig,'title',strcat(handles.plot_str,' Interpolated Tomography(x)'));
        
        prof_fig = figure;
        plot_tomo_prof(handles);
        title(['Tomography(x) Profile Projection ' handles.plot_str handles.data.ts_date])
        util_printLog(prof_fig,'title',strcat({'Tomography(x) '},handles.plot_str,' Profile Projection vs.',' Raw Projection'));
        
        spectra_fig = figure;
        plot_spectra(handles);
        title(['Tomography(x) Energy Spectra ' handles.plot_str handles.data.ts_date]);
        util_printLog(spectra_fig,'title',strcat({'Tomography(x) '},handles.plot_str,' Spectra vs. sYAG Energy Spectra'));
        
        fit_fig = figure;
        plot_fit(handles);
        title(['Tomography(x) Centroid Fit ' handles.plot_str handles.data.ts_date]);
        util_printLog(fit_fig,'title',strcat({'Tomography(x) Centroid Fit '},handles.plot_str));
end

guidata(hObject, handles);
if handles.do_scan == 1
    if ~handles.issaved
        [filename, pathname] = util_dataSave(handles.data, 'tomography_scan', 'set_slit', handles.data.ts);
        gui_statusDisp(handles, sprintf('Data saved to %s/%s', pathname, filename));
        handles.issaved = 1;
    end
end
guidata(hObject, handles);


% --- Executes on selection change in plot_type.
function plot_type_Callback(hObject, eventdata, handles)
% hObject    handle to plot_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_type
handles.plot=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function plot_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_go.
function plot_go_Callback(hObject, eventdata, handles)
% hObject    handle to plot_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ax_4 = handles.tomo_axes;
axes(ax_4);
cla;
switch handles.plot
    case 1
        plot_waterfall_raw(handles);
    case 2
        plot_waterfall_interp(handles);
    case 3
        plot_tomo_prof(handles);
    case 4
        plot_spectra(handles);
    case 5
        plot_fit(handles);
end


% --- Executes on button press in Reset_notch_jaw.
function Reset_notch_jaw_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_notch_jaw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imdata2;
if handles.do_scan == 1
    lcaPutSmart('COLL:LI20:2072:MOTR', handles.init_notch);
    lcaPutSmart('COLL:LI20:2085:MOTR.VAL', handles.init_jaw_left);
    lcaPutSmart('COLL:LI20:2086:MOTR.VAL', handles.init_jaw_right);
    while abs(lcaGetSmart('COLL:LI20:2072:MOTR.RBV') - lcaGetSmart('COLL:LI20:2072:MOTR')) > 10; end;
    while abs(lcaGetSmart('COLL:LI20:2085:MOTR.RBV') - lcaGetSmart('COLL:LI20:2085:MOTR.VAL')) > 0.05; end;
    while abs(lcaGetSmart('COLL:LI20:2086:MOTR.RBV') - lcaGetSmart('COLL:LI20:2086:MOTR.VAL')) > 0.05; end;
end
imdata2 = profmon_grab(handles.camera_PV_inuse);
update_syag_im(handles);
update_camera2_im(handles);


% --- Executes on button press in grab_syag_and_camera2.
function grab_syag_and_camera2_Callback(hObject, eventdata, handles)
% hObject    handle to grab_syag_and_camera2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imdata2;
imdata2 = profmon_grab(handles.camera_PV_inuse);
update_syag_im(handles);
update_camera2_im(handles);


% --- Executes on button press in drift_correction_box.
function drift_correction_box_Callback(hObject, eventdata, handles)
% hObject    handle to drift_correction_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of drift_correction_box


% --- Executes on selection change in projection_type.
function projection_type_Callback(hObject, eventdata, handles)
% hObject    handle to projection_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns projection_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from projection_type
handles.proj_xz=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function projection_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projection_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in device_select.
function device_select_Callback(hObject, eventdata, handles)
% hObject    handle to device_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns device_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from device_select
handles.camera_ID = get(hObject,'Value');
handles.camera_PV_inuse(2) = handles.camera_PVList(handles.camera_ID);
handles.camera_names_inuse = ['SYAG';handles.DevNames(handles.camera_ID)];
set(handles.camera_PV_box,'String',handles.camera_PV_inuse(2));
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function device_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to device_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function camera_PV_box_Callback(hObject, eventdata, handles)
% hObject    handle to camera_PV_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of camera_PV_box as text
%        str2double(get(hObject,'String')) returns contents of camera_PV_box as a double
handles.camera_PV_inuse(2) = get(hObject,'String');
handles = update_gui(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function camera_PV_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_PV_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
