function varargout = pointing_gui(varargin)
% POINTING_GUI M-file for pointing_gui.fig
%      POINTING_GUI, by itself, creates a new POINTING_GUI or raises the existing
%      singleton*.
%
%      H = POINTING_GUI returns the handle to a new POINTING_GUI or the handle to
%      the existing singleton*.
%
%      POINTING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POINTING_GUI.M with the given input arguments.
%
%      POINTING_GUI('Property','Value',...) creates a new POINTING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pointing_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pointing_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pointing_gui

% Last Modified by GUIDE v2.5 20-Oct-2011 09:02:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pointing_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pointing_gui_OutputFcn, ...
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


% --- Executes just before pointing_gui is made visible.
function pointing_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pointing_gui (see VARARGIN)

% Choose default command line output for pointing_gui
handles.output = hObject;

% set "save restore" flag
handles.save_restore = 1;

% defaults for restore
handles.restore.ract = [1; 1];
handles.restore.gatt.trans = 1;
handles.restore.gatt.flow = 'RUFF';
handles.restore.gatt.setpoint = 0;
handles.restore.gatt.pressure = 0;
handles.restore.satt.trans = 1;
handles.restore.satt.state = repmat({'OUT'}, 9, 1);
handles.restore.bykik = 1;
handles.restore.ladder = 1;
handles.restore.rate = 120;
handles.restore.filter_NFOV = 4;
handles.restore.filter_WFOV = 4;
handles.restore.illum_uv = 0;
handles.restore.illum_vis = 0;

% PVs
handles.pv.bykik        = 'IOC:BSY0:MP01:BYKIKCTL';
handles.pv.ladder       = 'TRGT:FEE1:483:SELECT';
handles.pv.rate         = 'EVNT:SYS0:1:LCLSBEAMRATE';
handles.pv.filter_NFOV  = 'STEP:FEE1:484:POSITION';
handles.pv.filter_WFOV  = 'STEP:FEE1:485:POSITION';
handles.pv.illum_uv     = 'ILMR:FEE1:481:CMD';
handles.pv.illum_vis    = 'ILMR:FEE1:482:CMD';

%load config
try
    handles.config = util_configLoad('pointing_gui', 0);
    ok = 1;
catch
    gui_statusDisp(handles, 'Error loading config!!');
    ok = 0;
end

% load targets
handles.targetpvs{1,1} = script_setupPV(337, 'NFOV X centroid target', 'um', 1, 'pointing_gui', 'SYS0', 'ML00');
handles.targetpvs{1,2} = script_setupPV(338, 'NFOV Y centroid target', 'um', 1, 'pointing_gui', 'SYS0', 'ML00');
handles.targetpvs{2,1} = script_setupPV(339, 'WFOV X centroid target', 'um', 1, 'pointing_gui', 'SYS0', 'ML00');
handles.targetpvs{2,2} = script_setupPV(340, 'WFOV Y centroid target', 'um', 1, 'pointing_gui', 'SYS0', 'ML00');

handles.target = reshape(lcaGetSmart(handles.targetpvs), 2, 2);


if ok
    handles = update_all(handles);
    gui_statusDisp(handles, 'Pointing GUI loaded and ready.');
end

handles.config.method = 1;

handles.camera_names = get(handles.popupmenu_camera, 'String');
handles.filter_names = get(handles.popupmenu_filter, 'String');
handles.filter_names = [handles.filter_names; {'HOME'; 'ERROR'; 'UNKNOWN'; 'MOVING'}];

% some hard coded parameters
handles.ladder_wait = 25;
handles.hilim = 50;
handles.lolim = 20;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pointing_gui wait for user response (see UIRESUME)
% uiwait(handles.pointing_gui);


function handles = update_all(handles)

set(handles.popupmenu_camera, 'Value', handles.config.camera);
set(handles.popupmenu_filter, 'Value', handles.config.filter);
set(handles.edit_navg, 'String', num2str(handles.config.navg));
set(handles.edit_xtarget, 'String', num2str(handles.target(handles.config.camera, 1)));
set(handles.edit_xtarget, 'TooltipString', char(handles.targetpvs(handles.config.camera, 1)));
set(handles.edit_ytarget, 'String', num2str(handles.target(handles.config.camera, 2)));
set(handles.edit_ytarget, 'TooltipString', char(handles.targetpvs(handles.config.camera, 2)));
set(handles.edit_calib_xx, 'String', num2str(handles.config.calib(1,1)));
set(handles.edit_calib_xy, 'String', num2str(handles.config.calib(1,2)));
set(handles.edit_calib_yx, 'String', num2str(handles.config.calib(2,1)));
set(handles.edit_calib_yy, 'String', num2str(handles.config.calib(2,2)));
set(handles.edit_nBG, 'String', num2str(handles.config.nBG));
set(handles.checkbox_spontBG, 'Value', handles.config.spontBG);
drawnow;

% --- Outputs from this function are returned to the command line.
function varargout = pointing_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pushbutton_1_Callback(handles.pushbutton_1, [], handles);
guidata(handles.pushbutton_1, handles);

pushbutton_2_Callback(handles.pushbutton_2, [], handles);
guidata(handles.pushbutton_2, handles);

pushbutton_3_Callback(handles.pushbutton_3, [], handles);
guidata(handles.pushbutton_3, handles);

pushbutton_4_Callback(handles.pushbutton_4, [], handles);
guidata(handles.pushbutton_4, handles);

pushbutton_6_Callback(handles.pushbutton_6, [], handles);
guidata(handles.pushbutton_6, handles);


% --- Executes on selection change in popupmenu_camera.
function popupmenu_camera_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.camera = get(hObject, 'Value');
handles = update_all(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_camera contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_camera


% --- Executes during object creation, after setting all properties.
function popupmenu_camera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_navg_Callback(hObject, eventdata, handles)
% hObject    handle to edit_navg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.navg = str2int(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_navg as text
%        str2double(get(hObject,'String')) returns contents of edit_navg as a double


% --- Executes during object creation, after setting all properties.
function edit_navg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_navg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_filter.
function popupmenu_filter_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.filter = get(hObject, 'Value');
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_filter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_filter


% --- Executes during object creation, after setting all properties.
function popupmenu_filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_1.
function pushbutton_1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button_toggle(hObject, 1);

% set 'ok' flag
handles.ok = 1;

% save machine state
if handles.save_restore
    handles.restore = lcaGetStruct(handles.pv, 0, 'double');
    handles.save_restore = 0;
end

% check beam rate = 10 Hz
if isnan(handles.restore.rate)
    gui_statusDisp(handles, 'Error getting current beam rate.');
    handles.ok = 0;
    return
else
    if handles.restore.rate > 10
        errordlg('Beam rate must be 10 Hz or less!');
        gui_statusDisp(handles, 'Beam rate too high, aborting.');
        handles.ok = 0;
        button_toggle(hObject, 0);
        return
    end
end

% fire BYKIK
gui_statusDisp(handles, 'Activating BYKIK and inserting Direct imager screen');
lcaPutSmart(handles.pv.bykik, 0);
pause(0.1);

% start moving DI ladder to position 7
lcaPutSmart(handles.pv.ladder, 7);

handles.data.camera = char(handles.camera_names(get(handles.popupmenu_camera, 'Value')));
handles.pv.filter = handles.pv.(strcat('filter_', handles.data.camera));

% move filter wheel
handles = set_filter(handles, handles.data.camera, get(handles.popupmenu_filter, 'Value'));

% turn off illuminators
gui_statusDisp(handles, 'Turning off illuminators');
lcaPutSmart(handles.pv.illum_uv, 0);
lcaPutSmart(handles.pv.illum_vis, 0);

% set attenuation

% wait for DI ladder to stop
for ix = 1:handles.ladder_wait
    pos = lcaGetSmart(handles.pv.ladder, 0, 'double');
    if ~(pos == 7)
        pause(1);
        gui_statusDisp(handles, strcat({'Waited '}, num2str(ix), {' seconds for ladder motion'}));
    else
        break
    end
end

if ix >= handles.ladder_wait
    answer = questdlg('Direct imager ladder readback never made it to position 7.  Proceed anyway?');
    if ~strcmp(answer, 'Yes')
        gui_statusDisp(handles, 'Aborted by user.');
        handles.ok = 0;
        return        
        % call restore-all function
    end
end

% stop firing BYKIK
lcaPutSmart(handles.pv.bykik, 1);
gui_statusDisp(handles, 'Disabling BYKIK, Direct Imager is inserted and ready to go.');

button_toggle(hObject, 0);
guidata(hObject, handles);

function button_toggle(h, state)
switch state
    case 1
        set(h, 'BackgroundColor', [0 0.75 0]);
%         set(h, 'ForegroundColor', 'white');
        set(h, 'Enable', 'off');

    case 0
        set(h, 'BackgroundColor', [.702 .702 .702]);
%         set(h, 'ForegroundColor', [0 0 0]);
        set(h, 'Enable', 'on');
end



function handles = set_filter(handles, cam_name, filt_select)

filter_wait = 10; % max seconds to wait

handles.pv.filter = handles.pv.(strcat('filter_', cam_name));
old_filter = lcaGetSmart(handles.pv.filter, 0, 'double') + 1;
% if old_filter < 5
    old_filt_name = handles.filter_names(old_filter);
% else
%     old_filt_name = [];
% end

new_filt_name = handles.filter_names(filt_select);
new_suffix = num2str(filt_select - 1);

gui_statusDisp(handles, strcat({'Changing '}, cam_name, ...
    {' filter wheel from '}, old_filt_name, ...
    {' to '}, new_filt_name));

% actually set the filter position
lcaPutSmart(strcat(handles.pv.filter, new_suffix), 0);  % 0 is "on".  this is dumb.
pause(0.5);

% wait for wheel to move
retry = 1;
for ix = 1:filter_wait
    pos = lcaGetSmart(handles.pv.filter, 0, 'double');
    if (pos == (filt_select - 1))
        break
    elseif ((pos == 6) && retry) % "ERROR" state, which they sometimes get stuck in
        gui_statusDisp(handles, strcat(handles.pv.filter, {' is in ERROR state, retrying...'}));
        retry = 0;
        lcaPutSmart(strcat(handles.pv.filter, new_suffix), 0);  % 0 is "on".  this is dumb.
        pause(0.5);
        ix = 1;
    else
        pause(1);
        gui_statusDisp(handles, strcat({'Waited '}, num2str(ix), {' seconds for filter motion'}));
    end
end

handles.data.filter = lcaGetSmart(handles.pv.filter, 0, 'double') + 1;

if ix >= filter_wait
    gui_statusDisp(handles, strcat({'Setting filter wheel to '}, new_filt_name, ...
        {' failed. Current position is '}, ...
        handles.filter_names(handles.data.filter), {'.'}));
    pause(1);
    handles.ok = 0;
end

% --- Executes on button press in pushbutton_1.
function pushbutton_3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_toggle(hObject, 1);

opts.nBG = handles.config.nBG * handles.config.spontBG;
opts.spontBG = 1;
opts.doPlot = 1;
opts.doProcess = 0;
opts.axes = handles.axes1;
opts.useCal = 1;
opts.cal = 1;
opts.method = 6;
%opts.bufd = 1;
opts.bits = 0; % autoscale

handles.data.camera = char(handles.camera_names(get(handles.popupmenu_camera, 'Value')));
handles.pv.filter = handles.pv.(strcat('filter_', handles.data.camera));
handles.data.filter = lcaGetSmart(handles.pv.filter, 0, 'double') + 1;
handles.data.navg = str2int(get(handles.edit_navg, 'String'));

for ix = handles.data.filter:5

    gui_statusDisp(handles, 'Checking for saturation.');

    % get a test image
    test = profmon_measure(handles.data.camera, 1, opts);

    % count how many pixels are saturated
    saturated_pixels = sum(sum(test.img >= (0.95 * intmax(class(test.img)))));
    % if too many are, 
    if saturated_pixels >= 1
        if handles.data.filter <= 4
            answer = questdlg(strcat({'Camera appears saturated.  Current filter is '}, ...
                handles.filter_names(handles.data.filter), {'.  Switch to next highest filter?'}));
            if strcmp(answer, 'Yes')
                set(handles.popupmenu_filter, 'Value', handles.data.filter + 1);
                handles = set_filter(handles, handles.data.camera, handles.data.filter + 1);
            else
                break
            end
        else
            errordlg({'Camera appears saturated.  Filter is maxed out.'});
            handles.ok = 0;
        end        
    else
        break
    end
end

gui_statusDisp(handles, strcat({'Acquiring '}, num2str(handles.data.navg), {' images...'}));
handles.data.image = profmon_measure(handles.data.camera, handles.data.navg, opts);
gui_statusDisp(handles, 'Image acquisition done.');
button_toggle(hObject, 0);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_5.
function pushbutton_5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_toggle(hObject, 1);

gui_statusDisp(handles, sprintf('repointUndulatorLine(0, 0, %.1f, %.1f)', handles.data.repoint(1), handles.data.repoint(2)));
try
    ok = 1;
%     [fn, pn] = util_dataSave(handles.data, 'pointing_gui', handles.data.camera, now);
%     if ischar(fn)
%         gui_statusDisp(handles, strcat({'Data saved to '}, fn));
%     end
    repointUndulatorLine(0, 0, handles.data.repoint(1), handles.data.repoint(2));
catch
    ok = 0;
end

if ok
    gui_statusDisp(handles, 'Undulator repointing completed successfully');
else
    gui_statusDisp(handles, 'Undulator repointing completed with errors');
end
button_toggle(hObject, 0);

    

% --- Executes on button press in pushbutton_5.
function pushbutton_6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_toggle(hObject, 1);
if isfield(handles, 'restore')

    % fire BYKIK
    gui_statusDisp(handles, 'Activating BYKIK and retracting DI screen');
    lcaPutSmart(handles.pv.bykik, 0);
    pause(0.1);

    % move ladder to restore pos
    lcaPutSmart(handles.pv.ladder, handles.restore.ladder);
    
    % set attenuation back to restore val
    gui_statusDisp(handles, sprintf('Restoring FEE transmission to %.3f * %.3f...', handles.restore.ract(1), handles.restore.ract(2)));
    control_feeAttenSet(handles.restore.ract(1), handles.restore.ract(2));

    % wait for DI ladder to stop
    for ix = 1:handles.ladder_wait
        pos = lcaGetSmart(handles.pv.ladder, 0, 'double');
        if ~(pos == handles.restore.ladder)
            pause(1);
            gui_statusDisp(handles, strcat({'Waited '}, num2str(ix), {' seconds for ladder motion'}));
        else
            break
        end
    end
    if ix >= handles.ladder_wait
        answer = errordlg('Direct imager ladder never made it all the way out.  You should check on it.');
    end
    
    % stop firing BYKIK
    lcaPutSmart(handles.pv.bykik, handles.restore.bykik);

    gui_statusDisp(handles, 'State restored.');

else
    gui_statusDisp(handles, 'No restore state found in memory.  Doing nothing.');
end

button_toggle(hObject, 0);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_calib.
function pushbutton_calib_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn, pn] = util_dataSave(handles.data, 'pointing_gui', handles.data.camera, now);
if ischar(fn)
    gui_statusDisp(handles, strcat({'Data saved to '}, fn));
end


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[data, fn, pn] = util_dataLoad();
if ischar(fn)
    gui_statusDisp(handles, strcat({'Data loaded from '}, fn));
    handles.data = data;
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton_configSave.
function pushbutton_configSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_configSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    util_configSave('pointing_gui', handles.config, 0);
    ok = 1;
catch
    gui_statusDisp(handles, 'Error saving config!!');
    ok = 0;
end

if ok
    gui_statusDisp(handles, 'Config saved.');
    guidata(hObject, handles);
end


function edit_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xmeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.config.target(1) = str2double(get(hObject, 'String'));
% guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_xmeas as text
%        str2double(get(hObject,'String')) returns contents of edit_xmeas as a double


% --- Executes during object creation, after setting all properties.
function edit_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xmeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ymeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.config.target(2) = str2double(get(hObject, 'String'));
% guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_ymeas as text
%        str2double(get(hObject,'String')) returns contents of edit_ymeas as a double


% --- Executes during object creation, after setting all properties.
function edit_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ymeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_print.
function pushbutton_print_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exp_fig = figure;   exp_ax = axes;
plot_fit_img(handles, exp_ax, handles.data.avg, handles.data.avg.stats(handles.config.method, :), ...
    handles.data.repoint, handles.data.navg);
[fn, pn] = util_dataSave(handles.data, 'pointing_gui', handles.data.camera, now);
if ischar(fn)
    gui_statusDisp(handles, strcat({'Data saved to '}, fn));
end
util_appPrintLog(exp_fig, '', '', now);


% --- Executes on button press in pushbutton_configLoad.
function pushbutton_configLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_configLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles.config = util_configLoad('pointing_gui', 1);
    ok = 1;
catch
    gui_statusDisp(handles, 'Error loading config!!');
    ok = 0;
end

if ok
    gui_statusDisp(handles, 'Config loaded.');
    handles = update_all(handles);
    guidata(hObject, handles);
end


function edit_calib_xx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calib_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.calib(1,1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_calib_xx as text
%        str2double(get(hObject,'String')) returns contents of edit_calib_xx as a double


% --- Executes during object creation, after setting all properties.
function edit_calib_xx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_calib_xx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_calib_xy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calib_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.calib(1,2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_calib_xy as text
%        str2double(get(hObject,'String')) returns contents of edit_calib_xy as a double


% --- Executes during object creation, after setting all properties.
function edit_calib_xy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_calib_xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_calib_yx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calib_yx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.calib(2,1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_calib_yx as text
%        str2double(get(hObject,'String')) returns contents of edit_calib_yx as a double


% --- Executes during object creation, after setting all properties.
function edit_calib_yx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_calib_yx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_calib_yy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calib_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.calib(2,2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_calib_yy as text
%        str2double(get(hObject,'String')) returns contents of edit_calib_yy as a double


% --- Executes during object creation, after setting all properties.
function edit_calib_yy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_calib_yy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xmeas_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xmeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xmeas as text
%        str2double(get(hObject,'String')) returns contents of edit_xmeas as a double
handles.data.meas(1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_xmeas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xmeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ymeas_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ymeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ymeas as text
%        str2double(get(hObject,'String')) returns contents of edit_ymeas as a double
handles.data.meas(2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_ymeas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ymeas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_2.
function pushbutton_2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rdes = 0.1;

button_toggle(hObject, 1);
gui_statusDisp(handles, 'Saving FEE attenuator state');
[handles.restore.ract, handles.restore.gatt, handles.restore.satt] = control_feeAttenGet();
pause(1);
gui_statusDisp(handles, sprintf('Setting FEE transmission to %f', rdes));
ract = control_feeAttenSet(rdes);

gatt_wait = 120;
ramp_wait = 30;

for ix = 1:gatt_wait
    [ract, g, s] = control_feeAttenGet();
    err = (ract - rdes) / rdes;
    if ~(strcmp(g.flow, 'OFF') || strcmp(g.flow, 'FLOW'))
        gui_statusDisp(handles, sprintf('Waiting %d/%d seconds for gas attenuator switching', ix, gatt_wait));
        pause(1);
    else
        ract = control_feeAttenSet(rdes);
        for jx = 1:ramp_wait
            [ract, g, s] = control_feeAttenGet();
            err = (ract - rdes) / rdes;
            if err > 0.1
                gui_statusDisp(handles, sprintf('Waiting %d/%d seconds for gas attenuator ramping', jx, ramp_wait));
                pause(1);
            else
                gui_statusDisp(handles, sprintf('Gas attenuator pressure = %f', g.pressure));
                break
            end
        end
        gui_statusDisp(handles, sprintf('FEE transmission = %.4f * %.4f = %.4f', ract(1), ract(2), ract(1) * ract(2)));
        break;
    end
end
button_toggle(hObject, 0);
guidata(hObject, handles);


function plot_fit_img(handles, ax, image, stats, solution, navg)

if nargin < 6
    navg = [];
end
if nargin < 5
    solution = [];
end

axes(ax);
cla(ax, 'reset');
hold(ax, 'all');

opts.doPlot = 1;
opts.axes = ax;
opts.useCal = 1;
opts.cal = 1;
opts.bits = 0; % autoscale
opts.method = handles.config.method;
opts.title = char(strcat({'Pointing GUI '}, datestr(image.ts)));

profmon_imgPlot(image, opts);
% image.beam(method).stats(1:2) = [xm, ym];
% image.beam(method).stats(3:4) = [xs, ys];
[ell,cross]=beamAnalysis_getEllipse(stats, 2);
plot(ax, real(ell(1,:))/1e3,real(ell(2,:))/1e3,'y',real(cross(1,:))/1e3,real(cross(2,:))/1e3,'k', 'LineWidth', 1);

xg = handles.target(handles.config.camera, 1) / 1e3;
yg = handles.target(handles.config.camera, 2) / 1e3;
xl = get(ax, 'XLim'); dx = (xl(1) - xl(2)) / -20;
yl = get(ax, 'YLim'); dy = (yl(1) - yl(2)) / -20;

target_x = [xg + dx,xg, xg, xg, xg, xg, xg - dx];
target_y = [yg, yg, yg + dy, yg, yg - dy, yg, yg];
plot(ax, target_x, target_y, 'g-', 'LineWidth', 2);
if ~isempty(solution)
    text(0.05, 0.95, sprintf('repointUndulatorLine(0, 0, %.1f, %.1f)', solution(1), solution(2)), ...
        'Units', 'normalized', 'Color', 'green', 'FontSize', 14);
end

if ~isempty(navg)
    text(0.05, 0.05, sprintf('# Avg = %d', navg), ...
        'Units', 'normalized', 'Color', 'green', 'FontSize', 14);
end
    


% --- Executes on button press in pushbutton_4.
function pushbutton_4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button_toggle(hObject, 1);

opts.nBG = 0;
opts.spontaneousBG = 1;
opts.doPlot = 1;
opts.axes = handles.axes1;
opts.useCal = 1;
opts.cal = 1;
opts.bits = 0; % autoscale

meth = handles.config.method;
nsample = numel(handles.data.image);

if nsample < 1
    return
end

for ix = 1:nsample
    images(:,:,ix) = handles.data.image(ix).img;    
end

handles.data.avg = handles.data.image(1);
handles.data.avg.img = mean(images, 3);

for ix = 1:nsample
    handles.data.image(ix).beam = profmon_process(handles.data.image(ix), opts);
    for jx = 1:7
        handles.data.stats(ix, jx, :) = handles.data.image(ix).beam(jx).stats;
    end
    gui_statusDisp(handles, sprintf('Processing %d/%d images...', ix, nsample));
end

handles.data.avg.stats = squeeze(mean(handles.data.stats, 1));
handles.data.meas = handles.data.avg.stats(meth, 1:2);
set(handles.edit_xmeas, 'String', sprintf('%.1f', handles.data.meas(1)));
set(handles.edit_ymeas, 'String', sprintf('%.1f', handles.data.meas(2)));

handles = calc_all(handles);

plot_fit_img(handles, handles.axes1, handles.data.avg, handles.data.avg.stats(meth, :), handles.data.repoint, nsample);
gui_statusDisp(handles, sprintf('Processing done.'));

% pushbutton_print_Callback(handles.pushbutton_print, [], handles);

button_toggle(hObject, 0);
guidata(hObject, handles);

function handles = calc_all(handles)

if ~isempty(cell2mat(strfind(fieldnames(handles), 'data')))
    if ~isempty(cell2mat(strfind(fieldnames(handles.data), 'meas')))
        handles.data.delta = handles.target(handles.config.camera, :) - handles.data.meas;
        set(handles.edit_xdelta, 'String', sprintf('%.1f', handles.data.delta(1)));
        set(handles.edit_ydelta, 'String', sprintf('%.1f', handles.data.delta(2)));

        if abs(handles.data.delta(1)) > handles.hilim
            set(handles.edit_xdelta, 'BackgroundColor', 'red');
        elseif (abs(handles.data.delta(1)) <= handles.hilim) && ...
                (abs(handles.data.delta(1)) >  handles.lolim)
            set(handles.edit_xdelta, 'BackgroundColor', 'yellow');
        elseif (abs(handles.data.delta(1)) <= handles.lolim)
            set(handles.edit_xdelta, 'BackgroundColor', 'green');
        end

        if abs(handles.data.delta(2)) > handles.hilim
            set(handles.edit_ydelta, 'BackgroundColor', 'red');
        elseif (abs(handles.data.delta(2)) <= handles.hilim) && ...
                (abs(handles.data.delta(2)) >  handles.lolim)
            set(handles.edit_ydelta, 'BackgroundColor', 'yellow');
        elseif (abs(handles.data.delta(2)) <= handles.lolim)
            set(handles.edit_ydelta, 'BackgroundColor', 'green');
        end

        handles.data.repoint = handles.data.delta * handles.config.calib;
        set(handles.edit_xrepoint, 'String', sprintf('%.1f', handles.data.repoint(1)));
        set(handles.edit_yrepoint, 'String', sprintf('%.1f', handles.data.repoint(2)));
    end
end


% --- Executes on button press in checkbox_spontBG.
function checkbox_spontBG_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_spontBG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.spontBG = get(hObject, 'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_spontBG


% --- Executes on slider movement.
function slider_fit_Callback(hObject, eventdata, handles)
% hObject    handle to slider_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_fit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_xrepoint_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xrepoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xrepoint as text
%        str2double(get(hObject,'String')) returns contents of edit_xrepoint as a double
handles.data.repoint(1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_xrepoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xrepoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_yrepoint_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yrepoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yrepoint as text
%        str2double(get(hObject,'String')) returns contents of edit_yrepoint as a double
handles.data.repoint(2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_yrepoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yrepoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xdelta_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xdelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xdelta as text
%        str2double(get(hObject,'String')) returns contents of edit_xdelta as a double
handles.data.delta(1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_xdelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xdelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ydelta_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ydelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ydelta as text
%        str2double(get(hObject,'String')) returns contents of edit_ydelta as a double
handles.data.delta(2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_ydelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ydelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xtarget_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xtarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xtarget as text
%        str2double(get(hObject,'String')) returns contents of edit_xtarget as a double
handles.target(handles.config.camera, 1) = str2double(get(hObject, 'String'));
handles = calc_all(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_xtarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xtarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_ytarget_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ytarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ytarget as text
%        str2double(get(hObject,'String')) returns contents of edit_ytarget as a double
handles.target(handles.config.camera, 2) = str2double(get(hObject, 'String'));
handles = calc_all(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_ytarget_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ytarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nBG_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nBG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.nBG = str2int(get(hObject, 'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_nBG as text
%        str2double(get(hObject,'String')) returns contents of edit_nBG as a double


% --- Executes during object creation, after setting all properties.
function edit_nBG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nBG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close pointing_gui.
function pointing_gui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to pointing_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
util_appClose(hObject);
% exit;


% --- Executes on button press in pushbutton_zoom.
function pushbutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on;


% --- Executes on button press in pushbutton_saveTarget.
function pushbutton_saveTarget_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveTarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lcaPutSmart(reshape(handles.targetpvs(handles.config.camera, :), [], 1), ...
            reshape(handles.target(handles.config.camera, :), [], 1));
        
gui_statusDisp(handles, 'Pointing targets saved.');



