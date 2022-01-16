function varargout = SYAG_dispersion_gui(varargin)
% SYAG_DISPERSION_GUI M-file for SYAG_dispersion_gui.fig
%      SYAG_DISPERSION_GUI, by itself, creates a new SYAG_DISPERSION_GUI or raises the existing
%      singleton*.
%
%      H = SYAG_DISPERSION_GUI returns the handle to a new SYAG_DISPERSION_GUI or the handle to
%      the existing singleton*.
%
%      SYAG_DISPERSION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYAG_DISPERSION_GUI.M with the given input arguments.
%
%      SYAG_DISPERSION_GUI('Property','Value',...) creates a new SYAG_DISPERSION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SYAG_dispersion_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SYAG_dispersion_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SYAG_dispersion_gui

% Last Modified by GUIDE v2.5 11-Dec-2014 02:45:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SYAG_dispersion_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @SYAG_dispersion_gui_OutputFcn, ...
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


% --- Executes just before SYAG_dispersion_gui is made visible.
function SYAG_dispersion_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SYAG_dispersion_gui (see VARARGIN)

% Choose default command line output for SYAG_dispersion_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SYAG_dispersion_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SYAG_dispersion_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global imdata;
global select_box; % pixel locations of region of interest (ROI) [xmin xmax ymin ymax]
global select_box_rect; % ROI values for rectangle function [xmin ymin width height] in axes units
global data_analyzed; % boolean that says whether or not data has been analyzed

data_analyzed = false;
handles.PVList={'PROF:LI20:2432'; 'PROF:LI20:3301'; 'PROF:LI20:3302'; 'CMOS:LI20:3490'; 'CMOS:LI20:3492';};
handles.DevNames = {'SYAG';'IP2A';'IP2B';'CMOS_NEAR';'CMOS_FAR';};
set(handles.device_pum,'String',handles.DevNames);

lcaPutSmart(strcat(handles.PVList,':BinX.PROC'),1);
lcaPutSmart(strcat(handles.PVList,':BinY.PROC'),1);

handles.PVId = get(handles.device_pum,'Value');
handles.PV = handles.PVList{handles.PVId};
set(handles.text10,'String',['Current ' handles.DevNames{handles.PVId} ' dispersion:']);

handles.sioc_pvs = get_sioc_pvs(handles);
set(handles.text12,'String',['mm (' handles.sioc_pvs{5} ')']);

imdata = profmon_grab(handles.PV);
handles.data.resolution = imdata.res;
handles.data.pix_x = imdata.roiXN;
handles.data.pix_y = imdata.roiYN;
x_axis = (handles.data.resolution*(1:handles.data.pix_x))/1000;
handles.data.x_axis = x_axis - mean(x_axis);
y_axis = (handles.data.resolution*(1:handles.data.pix_y))/1000;
handles.data.y_axis = y_axis - mean(y_axis);

% Default Region of Interest=======
select_box = [ceil(handles.data.pix_x*0.12) floor(handles.data.pix_x*0.86)...
    floor(handles.data.pix_y*0.15) ceil(handles.data.pix_y*0.25)];
select_box_rect = [handles.data.x_axis(select_box(1)),...
    handles.data.y_axis(select_box(3)),...
    (handles.data.x_axis(select_box(2))-handles.data.x_axis(select_box(1))),...
    (handles.data.y_axis(select_box(4))-handles.data.y_axis(select_box(3)))];
% =================================

% update current dispersion display
current_dispersion = lcaGet(handles.sioc_pvs{5});
set(handles.current_dispersion_value,'String',num2str(current_dispersion));

handles = update_gui(handles);
update_image(handles);

% Set handles.do_scan ~=1 when troubleshooting. Set =1 to actually perform dispersion scan.
handles.do_scan = 1;
guidata(hObject, handles);



% Updates Gui State
function handles = update_gui(handles)
handles.data.nsamp = str2int(get(handles.samples, 'String'));
handles.data.nstep = str2int(get(handles.steps, 'String'));
handles.data.knob  = get(handles.scan_function, 'String');
handles.data.knobv = get(handles.scan_function, 'Value');
handles.data.range = str2double(get(handles.range, 'String'));
handles.PVId = get(handles.device_pum,'Value');
handles.PV = handles.PVList{handles.PVId};
handles.sioc_pvs = get_sioc_pvs(handles);

set(handles.PV_box,'String',handles.PV);
handles.Plot = get(handles.plot_pum,'Value');
handles.Dispersion = get(handles.dispersion_selection,'Value');
handles.sYAG_lineout = get(handles.select_ROI,'Value');



% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% AIDA-PVA imports
global pvaRequest;

handles.issaved = 0;
handles = update_gui(handles);

global imdata;
global select_box;

if isempty(select_box)
    display('Select a region of interest.');
    return;
end

imdata = profmon_grab(handles.PV);
%switch handles.data.knob
if strcmp('SCAVENGY.MKB',handles.data.knob(handles.data.knobv))
        fast.name = {'EP01:AMPL:171:VDES' 'EP01:AMPL:181:VDES';
                    'EP01:AMPL:171:VACT' 'EP01:AMPL:181:VACT'};
else
        fast.name = {'EP01:AMPL:172:VDES' 'EP01:AMPL:182:VDES';
                    'EP01:AMPL:172:VACT' 'EP01:AMPL:182:VACT'};
end
%fast.name = {'EP01:AMPL:171:VDES' 'EP01:AMPL:181:VDES';
%             'EP01:AMPL:171:VACT' 'EP01:AMPL:181:VACT'};
klys.name = reshape(model_nameRegion('KLYS', {'LI17' 'LI18'}), 8, 2);
sbst.name = reshape(model_nameRegion('SBST', {'LI17' 'LI18'}), 1, 2);
klys.phas = reshape(control_phaseGet(klys.name), 8, 2);
sbst.phas = reshape(control_phaseGet(sbst.name), 1, 2);
fast.pdes = reshape(lcaGetSmart(fast.name(2,:)), 1, 2);
fast.phas = reshape(lcaGetSmart(fast.name(1,:)), 1, 2);
[act, d, d, d, d, enld] = control_klysStatGet(klys.name);
klys.enld = reshape(enld, 8, 2);
klys.act  = reshape(bitget(act, 1), 8, 2);
emax = zeros(size(klys.phas));
klys.pact = klys.phas + repmat(sbst.phas, 8, 1) + repmat(fast.phas, 8, 1);
klys.pmax = klys.phas + repmat(sbst.phas, 8, 1);
klys.ampl = klys.act .* klys.enld .* cosd(klys.pact);
egain = sum(sum(klys.ampl));
emax  = sum(sum(klys.enld .* klys.act .* cosd(klys.pmax)));
erange = [egain - handles.data.range, egain + handles.data.range];
prange = -acosd(erange / emax);

% check that phases are reasonable
if ~all(isreal(prange)) || any(isnan(prange)) || any(abs(prange) <= 5)
    errstring = sprintf('Range bad, fast phase shifters = [%.1f %.1f])', prange(1), prange(2));
    gui_statusDisp(handles, errstring);
    errordlg(errstring);
    return;
end

% store timestamp
handles.data.ts = now;

% store scan range
handles.data.range = linspace(-diff(prange)/2, diff(prange)/2, handles.data.nstep);
rangestr = '';
for ix = 1:handles.data.nstep
    rangestr = [rangestr sprintf('%.1f ', handles.data.range(ix))];
end
gui_statusDisp(handles, sprintf('Calculated knob steps: [%s]', rangestr));

phase_deltas = diff([0 handles.data.range 0]);

% set up AIDA for knob control
if handles.do_scan == 1
   requestBuilder = pvaRequest('MKB:VAL');
   requestBuilder.with('MKB', strcat('mkb:', handles.data.knob(handles.data.knobv)));
end

set(hObject, 'String', 'Acquiring...');
set(hObject, 'Enable', 'off');

% turn off energy feedbacks
if handles.do_scan == 1
    fbpv = {'SIOC:SYS1:ML00:AO060'; 'SIOC:SYS1:ML00:AO084'};
    fbstate = lcaGetSmart(fbpv);
    lcaPutSmart(fbpv, zeros(size(fbpv)));
end

handles.data.projections = zeros(handles.data.pix_x,handles.data.nsamp,handles.data.nstep);
handles.data.bpm = zeros(handles.data.nsamp,handles.data.nstep);
ax_1 = handles.image_axes;
axes(ax_1);
cla;
% fill in handles.data.projections with SYAG projection profiles
for ix = 1:handles.data.nstep

    % set energy hereaxis
    if handles.do_scan == 1
        gui_statusDisp(handles, sprintf('Setting %s to %.1f', handles.data.knob{handles.data.knobv}, handles.data.range(ix)));
    end
    if handles.do_scan == 1
       requestBuilder.set(phase_deltas(ix));
    end

    % calculate energy from phase readback here
    phase(ix, :) = reshape(lcaGetSmart(fast.name), 1, []);  %phase(:, [1:3]) is VDES
    pact = klys.phas + repmat(sbst.phas, 8, 1) + repmat(phase(ix, [1 3]), 8, 1);
    energy(ix) = sum(sum(klys.act .* klys.enld .* cosd(pact))) - egain;
    if handles.do_scan == 1
        gui_statusDisp(handles, sprintf('Setting %s to %.5f', 'Energy', energy(ix)));
    end
    % grab syag when new image occurs
    lcaSetMonitor([handles.PV ':Image:ArrayData']);
    imdata = profmon_grab(handles.PV);
    for iy = 1:handles.data.nsamp
        while 1
            if (lcaNewMonitorValue([handles.PV ':Image:ArrayData']))
                imdata = profmon_grab(handles.PV);
                bpm = lcaGet('BPMS:LI20:2445:X');
                break;
            end
        end
%         roi = imdata.img;
%         roi_proj = mean(roi);
%         handles.data.projections(:,iy,ix) = roi_proj;
        im_raw = imdata.img;
        im_roi_y = im_raw(select_box(3):select_box(4),:);
        roi_y_proj = mean(im_roi_y);
        handles.data.projections(:,iy,ix) = roi_y_proj;
        handles.data.bpm(iy,ix) = bpm;
        update_image(handles);
    end
end

handles.data.energy = energy;
handles.data.phase = phase;

% restore energy multiknob
if handles.do_scan == 1
   requestBuilder.set(phase_deltas(end));
end

%turn feedbacks back on
if handles.do_scan == 1
   lcaPutSmart(fbpv,fbstate);
end
set(hObject, 'String', 'Acquire');
set(hObject, 'Enable', 'on');
gui_statusDisp(handles, 'Acquisition finished.');
handles = analyze_data(handles);
guidata(hObject, handles);
update_image(handles);


% function analyze_data() calculates values needed for the plot functions
function handles = analyze_data(handles)
global select_box;
global data_analyzed;
handles.data.projections_ROI = handles.data.projections(select_box(1):select_box(2),:,:);
handles.data.centroid = zeros(handles.data.nsamp, handles.data.nstep);
handles.data.max_pos = zeros(handles.data.nsamp, handles.data.nstep);
handles.data.fwhm_L = zeros(handles.data.nsamp, handles.data.nstep);
handles.data.fwhm_R = zeros(handles.data.nsamp, handles.data.nstep);
handles.data.profiles = zeros(select_box(2)-select_box(1)+1, handles.data.nstep);
x_axis = handles.data.x_axis(select_box(1):select_box(2))';
for iw = 1:handles.data.nstep
    handles.data.profiles(:,iw) = mean(handles.data.projections_ROI(:,:,iw),2);
    for iz = 1:handles.data.nsamp
        norm = sum(handles.data.projections_ROI(:,iz,iw));
        centroid = sum(handles.data.projections_ROI(:,iz,iw).*x_axis)/norm;
        [max_val, max_ind] = max(handles.data.projections_ROI(:,iz,iw));
        [fwhm_val,fwhm_L,fwhm_R] = FWHM(x_axis,handles.data.projections_ROI(:,iz,iw));
        handles.data.max_pos(iz,iw) = x_axis(max_ind);
        handles.data.centroid(iz,iw) = centroid;
        handles.data.fwhm_L(iz,iw) = x_axis(fwhm_L);
        handles.data.fwhm_R(iz,iw) = x_axis(fwhm_R);
    end
end

energy = repmat(handles.data.energy,handles.data.nsamp,1)/20.35E3;
energy2 = handles.data.energy/20.35E3;
C = polyfit(energy(:),handles.data.centroid(:),2);
M = polyfit(energy(:),handles.data.max_pos(:),2);
L = polyfit(energy(:),handles.data.fwhm_L(:),2);
R = polyfit(energy(:),handles.data.fwhm_R(:),2);
B = polyfit(energy(:),handles.data.bpm(:),2);
handles.data.centroid_fit = C;
handles.data.max_pos_fit = M;
handles.data.fwhm_L_fit = L;
handles.data.fwhm_R_fit = R;
handles.data.bpm_fit = B;
if handles.do_scan == 1
    lcaPutSmart(handles.sioc_pvs{1}, handles.data.centroid_fit(2));
    lcaPutSmart(handles.sioc_pvs{2}, handles.data.max_pos_fit(2));
    lcaPutSmart(handles.sioc_pvs{3}, handles.data.fwhm_L_fit(2));
    lcaPutSmart(handles.sioc_pvs{4}, handles.data.fwhm_R_fit(2));
    lcaPutSmart(handles.sioc_pvs{6}, handles.data.bpm_fit(2));
    data_analyzed = true;
end

ax_2 = handles.data_analysis;
axes(ax_2);
cla;
switch handles.Plot
    case 1
        plot_fits(handles);
    case 2
        plot_profiles(handles);
    case 3
        plot_spectrum(handles);
end

function plot_fits(handles)
energy = repmat(handles.data.energy,handles.data.nsamp,1)/20.35E3;
energy2 = handles.data.energy/20.35E3;
plot(energy(:), handles.data.centroid(:),'r*',energy(:), handles.data.max_pos(:),'b*',energy(:), handles.data.fwhm_L(:),'g*',energy(:),handles.data.fwhm_R(:),'m*',energy(:),handles.data.bpm(:),'k*');
xlabel('\delta');
ylabel('X [mm]');
title('SYAG Energy vs. X Dispersion Scan');
hold on;
plot(energy2,handles.data.centroid_fit(1)*energy2.^2+handles.data.centroid_fit(2)*energy2+handles.data.centroid_fit(3),'r-',...
    energy2,handles.data.max_pos_fit(1)*energy2.^2+handles.data.max_pos_fit(2)*energy2+handles.data.max_pos_fit(3),'b-',...
    energy2,handles.data.fwhm_L_fit(1)*energy2.^2+handles.data.fwhm_L_fit(2)*energy2+handles.data.fwhm_L_fit(3),'g-',...
    energy2,handles.data.fwhm_R_fit(1)*energy2.^2+handles.data.fwhm_R_fit(2)*energy2+handles.data.fwhm_R_fit(3),'m-',...
    energy2,handles.data.bpm_fit(1)*energy2.^2+handles.data.bpm_fit(2)*energy2+handles.data.bpm_fit(3),'k-');
l = legend(['Centroid = ' num2str(handles.data.centroid_fit(2),'%.2f') ' mm'],['Max = ' num2str(handles.data.max_pos_fit(2),'%.2f') ' mm'],...
    ['FWHM_{Left} =' num2str(handles.data.fwhm_L_fit(2),'%.2f') ' mm'],['FWHM_{Right} =' num2str(handles.data.fwhm_R_fit(2),'%.2f') ' mm'],...
    ['BPM =' num2str(handles.data.bpm_fit(2),'%.2f') ' mm'],...
    'location','northwest');
set(l,'fontsize',10);
set(l,'box','off');
hold off;

function plot_profiles(handles)
colors = hsv(handles.data.nstep);
global select_box;

x_axis = handles.data.x_axis(select_box(1):select_box(2));
energy3 = handles.data.energy;
for iv = 1:handles.data.nstep
    plot(x_axis,handles.data.profiles(:,iv),'color',colors(iv,:));
    legend_str(iv) = {[num2str(energy3(iv),'%.2f') ' MeV']};
    hold on;
end
l = legend(legend_str,'location','northwest');
set(l,'fontsize',10);
set(l,'box','off');
axis([x_axis(1) x_axis(end) min(handles.data.profiles(:)) max(handles.data.profiles(:))+20]);
xlabel('X [mm]');
title('Average of SYAG Profiles');
hold off;

function plot_spectrum(handles)
switch handles.Dispersion
    case 1
        Dispersion = handles.data.centroid_fit(2);
    case 2
        Dispersion = handles.data.max_pos_fit(2);
    case 3
        Dispersion = handles.data.fwhm_L_fit(2);
    case 4
        Dispersion = handles.data.fwhm_R_fit(2);
end
global select_box;
x_axis = handles.data.x_axis(select_box(1):select_box(2));
energy_axis = x_axis/Dispersion;
energy_axis = energy_axis - mean(energy_axis);
spectrum = handles.data.profiles(:,ceil(handles.data.nstep/2));
spectrum = spectrum/sum(spectrum);
offset = sum(energy_axis.*spectrum');
energy_axis = energy_axis - offset;
fwhm = FWHM(energy_axis,spectrum);
cent = sum(energy_axis.*spectrum');
rms = sqrt(sum(spectrum.*(energy_axis' - cent).^2));
plot(energy_axis, spectrum, '-k');
axis tight;
ax = axis;
text(ax(1)+(ax(2)-ax(1))/10,ax(4)-(ax(4)-ax(3))/10,['FWHM = ' num2str(100*fwhm,'%.2f') '%']);
text(ax(1)+(ax(2)-ax(1))/10,ax(4)-2*(ax(4)-ax(3))/10,['RMS = ' num2str(100*rms,'%.2f') '%']);

xlabel('\delta');
title('Energy Spectrum');

%--------------------------------------------------------------------------

function update_image(handles)

global imdata;
global select_box_rect;

% Plot image and lineout region
handles.data.resolution = imdata.res;
handles.data.pix_x = imdata.roiXN;
handles.data.pix_y = imdata.roiYN;
x_axis = (handles.data.resolution*(1:handles.data.pix_x))/1000;
handles.data.x_axis = x_axis - mean(x_axis);
y_axis = (handles.data.resolution*(1:handles.data.pix_y))/1000;
handles.data.y_axis = y_axis - mean(y_axis);
ax_1 = handles.image_axes;
axes(ax_1);
cla;
hold all;
axis([min(handles.data.x_axis) max(handles.data.x_axis) min(handles.data.y_axis) max(handles.data.y_axis)]);
axis ij;
imagesc(handles.data.x_axis,handles.data.y_axis,imdata.img,'HitTest','Off');
caxis([0 512]);
xlabel('X [mm]');
ylabel('Y [mm]');
if ~isempty(select_box_rect)
    if select_box_rect(3) <= 0 || select_box_rect(4) <= 0
        clear global select_box;
        clear global select_box_rect;
        display('Region of interest width and/or height are less than or equal to zero.');
        return;
    else
        rectangle('Position',select_box_rect,'edgecolor','r','linewidth',2,'linestyle','--');
    end
end
hold off;

%--------------------------------------------------------------------------

function samples_Callback(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of samples as text
%        str2double(get(hObject,'String')) returns contents of samples as a double


% --- Executes during object creation, after setting all properties.
function samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function steps_Callback(hObject, eventdata, handles)
% hObject    handle to steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of steps as text
%        str2double(get(hObject,'String')) returns contents of steps as a double


% --- Executes during object creation, after setting all properties.
function steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scan_function.
function scan_function_Callback(hObject, eventdata, handles)
% hObject    handle to scan_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns scan_function contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scan_function


% --- Executes during object creation, after setting all properties.
function scan_function_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function range_Callback(hObject, eventdata, handles)
% hObject    handle to range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of range as text
%        str2double(get(hObject,'String')) returns contents of range as a double


% --- Executes during object creation, after setting all properties.
function range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in device_pum.
function device_pum_Callback(hObject, eventdata, handles)
% hObject    handle to device_pum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns device_pum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from device_pum
global imdata;

handles.PVId=get(hObject,'Value');
handles.PV=handles.PVList{handles.PVId};
handles.sioc_pvs = get_sioc_pvs(handles);
set(handles.text10,'String',['Current ' handles.DevNames{handles.PVId} ' dispersion:']);
set(handles.text12,'String',['mm (' handles.sioc_pvs{5} ')']);
set(handles.PV_box,'String',handles.PV);
imdata = profmon_grab(handles.PV);
update_image(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function device_pum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to device_pum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PV_box_Callback(hObject, eventdata, handles)
% hObject    handle to PV_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PV_box as text
%        str2double(get(hObject,'String')) returns contents of PV_box as a double
handles.PV=get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function PV_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PV_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plot_pum.
function plot_pum_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_pum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_pum
handles.Plot=get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function plot_pum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_pum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in go_plot.
function go_plot_Callback(hObject, eventdata, handles)
% hObject    handle to go_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ax_2 = handles.data_analysis;
axes(ax_2);
switch handles.Plot
    case 1
        plot_fits(handles);
    case 2
        plot_profiles(handles);
    case 3
        plot_spectrum(handles);
end


% --- Executes on selection change in dispersion_selection.
function dispersion_selection_Callback(hObject, eventdata, handles)
% hObject    handle to dispersion_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_analyzed;

handles.Dispersion=get(hObject,'Value');
if data_analyzed
    switch handles.Dispersion
        case 1
            Dispersion = handles.data.centroid_fit(2);
        case 2
            Dispersion = handles.data.max_pos_fit(2);
        case 3
            Dispersion = handles.data.fwhm_L_fit(2);
        case 4
            Dispersion = handles.data.fwhm_R_fit(2);
    end
    lcaPutSmart(handles.sioc_pvs{5},Dispersion);
    set(handles.current_dispersion_value,'String',num2str(Dispersion));
end
guidata(hObject,handles);
% Hints: contents = get(hObject,'String') returns dispersion_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dispersion_selection


% --- Executes on button press in print_and_save.
function print_and_save_Callback(hObject, eventdata, handles)
% hObject    handle to print_and_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fitfig = figure;
plot_fits(handles);
util_printLog(fitfig);

proffig = figure;
plot_profiles(handles);
util_printLog(proffig);

specfig = figure;
plot_spectrum(handles);
util_printLog(specfig);

guidata(hObject, handles);

if ~handles.issaved
    [filename, pathname] = util_dataSave(handles.data, 'syag_dispersion', handles.data.knob(handles.data.knobv), handles.data.ts);
    gui_statusDisp(handles, sprintf('Data saved to %s/%s', pathname, filename));
    handles.issaved = 1;
end
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
delete(gcf)
if ~usejava('desktop')
    exit
end


% --- Executes on mouse press over axes background.
function image_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to image_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global select_box;
global select_box_rect;

if handles.sYAG_lineout == 0
    return
else
    hold all;
    ax_1 = handles.image_axes;
    axes(ax_1);
    point1 = get(ax_1,'CurrentPoint');
    finalRect = rbbox;
    point2 = get(ax_1,'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    p1 = min(point1,point2);
    p2 = max(point1,point2);
    [junk1, min_x_ind] = min(abs(handles.data.x_axis - p1(1)));
    [junk2, max_x_ind] = min(abs(handles.data.x_axis - p2(1)));
    [junk3, min_y_ind] = min(abs(handles.data.y_axis - p1(2)));
    [junk4, max_y_ind] = min(abs(handles.data.y_axis - p2(2)));
    select_box = [min_x_ind max_x_ind min_y_ind max_y_ind];
    min_x_value = handles.data.x_axis(min_x_ind);
    max_x_value = handles.data.x_axis(max_x_ind);
    min_y_value = handles.data.y_axis(min_y_ind);
    max_y_value = handles.data.y_axis(max_y_ind);
    select_box_rect = [min_x_value, min_y_value, (max_x_value - min_x_value), (max_y_value - min_y_value)];
    hold off;
    update_image(handles);
    handles = update_gui(handles);
end


% --- Executes on button press in select_ROI.
function select_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to select_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global select_box;
global select_box_rect;
select_box = [];
select_box_rect = [];
axes(handles.image_axes);
update_image(handles);
handles = update_gui(handles);
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of select_ROI

% --- List of SIOC PVs
function sioc_pvs = get_sioc_pvs(handles)

sioc_pv_list = {'SIOC:SYS1:ML00:AO305';
                'SIOC:SYS1:ML00:AO306';
                'SIOC:SYS1:ML00:AO307';
                'SIOC:SYS1:ML00:AO308';
                'SIOC:SYS1:ML00:AO309';
                'SIOC:SYS1:ML00:AO310';
                'SIOC:SYS1:ML00:AO311';
                'SIOC:SYS1:ML00:AO312';
                'SIOC:SYS1:ML00:AO313';
                'SIOC:SYS1:ML00:AO314';
                'SIOC:SYS1:ML00:AO315';
                'SIOC:SYS1:ML00:AO316';
                'SIOC:SYS1:ML00:AO317';
                'SIOC:SYS1:ML00:AO318';
                'SIOC:SYS1:ML00:AO319';
                'SIOC:SYS1:ML00:AO325';
                'SIOC:SYS1:ML00:AO326';
                'SIOC:SYS1:ML00:AO327';
                'SIOC:SYS1:ML00:AO328';
                'SIOC:SYS1:ML00:AO329';
                'SIOC:SYS1:ML00:AO341';
                'SIOC:SYS1:ML00:AO342';
                'SIOC:SYS1:ML00:AO343';
                'SIOC:SYS1:ML00:AO344';
                'SIOC:SYS1:ML00:AO345';
                'SIOC:SYS1:ML00:AO350';
                };

ind_start = 5*(handles.PVId - 1)+1;
ind_end = 5*handles.PVId;
list_end = numel(sioc_pv_list);
sioc_pvs = sioc_pv_list([ind_start:ind_end list_end]);
