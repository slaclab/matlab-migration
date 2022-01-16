function varargout = dither(varargin)
% DITHER M-file for dither.fig
%      DITHER, by itself, creates a new DITHER or raises the existing
%      singleton*.
%
%      H = DITHER returns the handle to a new DITHER or the handle to
%      the existing singleton*.
%
%      DITHER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DITHER.M with the given input arguments.
%
%      DITHER('Property','Value',...) creates a new DITHER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dither_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dither_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dither

% Last Modified by GUIDE v2.5 23-Jul-2012 12:33:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dither_OpeningFcn, ...
                   'gui_OutputFcn',  @dither_OutputFcn, ...
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


% --- Executes just before dither is made visible.
function dither_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dither (see VARARGIN)

% Choose default command line output for dither
handles.output = hObject;

handles.controls = {
    'EPICS PV'
    'SLC Multiknob'
%     'SLC Magnet'
%     'SLC Klystron'
%     'SLC Device'
    };

handles.signals = {
    'EPICS PV'
    'SLC Buffered BPM-like Device'
    };

handles.modes = {
    'Maximize signal'
    'Minimize signal'
    };

handles.dgrps = {
    'NDRFACET'
    'ELECEP01'
    'SCAVSPPS'
    };

handles.bpmds = {
    '57'
    '8'
    '19'
    };

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dither wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dither_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.status_txt, 'String', 'Loading GUI...');
drawnow;
gui_statusDisp(handles, 'Loading GUI...');

% Fill control/signal/mode dropdowns
set(handles.popupmenu_control_type, 'String', handles.controls);
set(handles.popupmenu_signal_type, 'String', handles.signals);
set(handles.popupmenu_mode, 'String', handles.modes);
set(handles.popupmenu_dgrp, 'String', handles.dgrps);

% Load list of presets
if 0
    handles.presets = util_configLoad('dither');
else
    presets(1).name = 'Nate Example - EPICS PVs';
    presets(1).control.type = 1;
    presets(1).control.name = 'SIOC:SYS1:ML00:AO901';
    presets(1).control.step = 1;
    presets(1).control.settle = 0.1;
    presets(1).control.min = -5;
    presets(1).control.max = 5;
    presets(1).signal.type = 1;
    presets(1).signal.name = 'SIOC:SYS1:ML00:CALC998';
    presets(1).signal.samples = 10;
    presets(1).signal.min = -15;
    presets(1).signal.max = 15;
    presets(1).signal.dgrp = 1;
    presets(1).dither.gain = 0.8;
    presets(1).dither.wait = 1;
    presets(1).dither.mode = 1;
    presets(1).dither.ringsize = 100;
    presets(1).dither.constrain = 1;

    presets(2).name = 'FACET phase ramp dither';
    presets(2).control.type = 2;
    presets(2).control.name = 'PHSRMP.MKB';
    presets(2).control.step = 0.05;
    presets(2).control.settle = 0.2;
    presets(2).control.min = -1;
    presets(2).control.max = 1;
    presets(2).signal.type = 1;
    presets(2).signal.name = 'BLEN:LI20:3158:BRAW';
    presets(2).signal.samples = 10;
    presets(2).signal.min = 10000;
    presets(2).signal.max = 200000;
    presets(2).signal.dgrp = 3;
    presets(2).dither.gain = 0.3;
    presets(2).dither.wait = 0.1;
    presets(2).dither.mode = 1;
    presets(2).dither.ringsize = 500;
    presets(2).dither.constrain = 1;

    handles.presets = presets;
end

% setup preset dropdown
handles = init_presets(handles, 1);
handles = set_preset(handles);

% Get default command line output from handles structure
varargout{1} = handles.output;

guidata(hObject, handles);

function handles = init_presets(handles, sel)

% this function initializes the dropdown box of available presets

preset_list = cell(numel(handles.presets), 1);
[preset_list{:}] = deal(handles.presets(:).name);
set(handles.popupmenu_preset, 'String', preset_list);
set(handles.popupmenu_preset, 'Value', sel);

function handles = set_preset(handles)

% this function shoves the currently selected preset into the GUI fields

sel     = get(handles.popupmenu_preset, 'Value');
preset  = handles.presets(sel);

ctrl    = preset.control.type;
signl   = preset.signal.type;
dmode   = preset.dither.mode;
dgrp    = preset.signal.dgrp;

switch signl
    case 2 % SLC BPM Data
        set(handles.text_dgrp,      'Visible', 'on');
        set(handles.popupmenu_dgrp, 'Visible', 'on');
    otherwise % EPICS PV
        set(handles.text_dgrp,      'Visible', 'off');
        set(handles.popupmenu_dgrp, 'Visible', 'off');
end

set(handles.popupmenu_control_type, 'Value', ctrl);
set(handles.popupmenu_signal_type,  'Value', signl);
set(handles.popupmenu_mode,         'Value', dmode);
set(handles.popupmenu_dgrp,         'Value', dgrp);

set(handles.edit_control_name,  	'String', preset.control.name);
set(handles.edit_signal_name,       'String', preset.signal.name);

set(handles.edit_control_step,      'String', num2str(preset.control.step));
set(handles.edit_control_settle,    'String', num2str(preset.control.settle));
set(handles.edit_control_max,       'String', num2str(preset.control.max));
set(handles.edit_control_min,       'String', num2str(preset.control.min));

set(handles.edit_signal_samples,    'String', num2str(preset.signal.samples));
set(handles.edit_signal_max,       'String', num2str(preset.signal.max));
set(handles.edit_signal_min,       'String', num2str(preset.signal.min));

set(handles.edit_gain,              'String', num2str(preset.dither.gain));
set(handles.edit_wait,              'String', num2str(preset.dither.wait));
set(handles.edit_ringsize,          'String', num2str(preset.dither.ringsize));
set(handles.checkbox_constrain,     'Value',  preset.dither.constrain);

gui_statusDisp(handles, sprintf('Loaded preset: %s', preset.name));
drawnow;

function handles = get_config(handles)

% this function stores the live configuration from the GUI controls

handles.config.control.type = get(handles.popupmenu_control_type, 'Value');
handles.config.signal.type  = get(handles.popupmenu_signal_type, 'Value');
handles.config.signal.dgrp  = get(handles.popupmenu_dgrp, 'Value');
handles.config.dither.mode  = get(handles.popupmenu_mode, 'Value');

handles.config.control.name = get(handles.edit_control_name, 'String');
handles.config.signal.name  = get(handles.edit_signal_name, 'String');

handles.config.control.step     = str2double(get(handles.edit_control_step, 'String'));
handles.config.control.settle   = str2double(get(handles.edit_control_settle, 'String'));
handles.config.control.max      = str2double(get(handles.edit_control_max, 'String'));
handles.config.control.min      = str2double(get(handles.edit_control_min, 'String'));

handles.config.signal.samples   = str2int(get(handles.edit_signal_samples, 'String'));
handles.config.signal.max       = str2double(get(handles.edit_signal_max, 'String'));
handles.config.signal.min       = str2double(get(handles.edit_signal_min, 'String'));

handles.config.dither.gain      = str2double(get(handles.edit_gain, 'String'));
handles.config.dither.wait      = str2double(get(handles.edit_wait, 'String'));
handles.config.dither.ringsize  = str2double(get(handles.edit_ringsize, 'String'));
handles.config.dither.constrain = get(handles.checkbox_constrain, 'Value');

% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% AIDA-PVA imports
global pvaRequest;

oldstr = get(hObject, 'String');
set(hObject, 'String', 'Dithering...');
set(hObject, 'Enable', 'off');
abort = false;

% get GUI stuff
handles = get_config(handles);
conf = handles.config;
gui_statusDisp(handles, 'Initializing dither...');

% disable GUI elements
handles = gui_enable(handles, 'off');

switch conf.control.type
    case 1 % EPICS PV
        % nothing to do here
    case 2 % SLC Multiknob
        dc = pvaRequest('MKB:VAL');
        dc.with('MKB', sprintf('mkb:%s', lower(conf.control.name)));
    otherwise
        gui_statusDisp(handles, sprintf('Oops, control type = %d not defined!  Aborting.', conf.control.type));
        abort = true;
end

% set up AIDA objects for signal device
switch conf.signal.type
    case 1 % EPICS PV
        lcaSetMonitor(conf.signal.name);
%         lcaSetTimeout(1e6);
        lcaSetSeverityWarnLevel(5);
    case 2 % SLC BPM
        bpmd = handles.bpmds{conf.signal.dgrp};
        dgrp = handles.dgrps{conf.signal.dgrp};
        [p,m,u,s] = model_nameSplit(conf.signal.name);
        bpmroot = sprintf('%s:%s:%s', char(p), char(m), char(u));

        ds = pvaRequest([ dgrp ':BUFFACQ' ]);
        ds.with('NRPOS', conf.signal.samples);
        ds.with('BPMD', bpmd);
        ds.with('DEVS', { bpmroot });

        % map columns from aida buffacq data to devices
        % http://www.slac.stanford.edu/grp/cd/soft/aida/slcBuffDpGuide.html
        %
        % BPMS = x, y, tmit in columns 3, 4 and 5 respectively
        % TORO = tmit in column 5
        % KLYS = phase in column 3
        % SBST = phase in column 3
        % GAPM = data, in column 3.
        % For all, name and pulse id are in column 1 and 2, and stat and goodmeas are in columns 6 and 7:
        if strcmp(p, 'BPMS')
            if strcmp(s, 'X')
                dscol = 3;
            elseif strcmp(s, 'Y')
                dscol = 4;
            elseif stcmp(s, 'TMIT')
                dscol = 5;
            else
                dscol = 0;
            end
        elseif strcmp(p, 'TORO')
            dscol = 5;
        elseif any(strcmp(p, {'KLYS' 'SBST' 'GAPM'}))
            dscol = 3;
        else
            dscol = 0;
        end

        if ~dscol
            gui_statusDisp(handles, sprintf('Buffered device %s unknown.  Can be called BPMS, TORO, KLYS, SBST, or GAPM.  Aborting.', conf.control.type));
            abort = true;
        end
    otherwise
        gui_statusDisp(handles, sprintf('Oops, signal type = %d not defined!  Aborting.', conf.control.type));
        abort = true;
end

abort = abort | logical(get(handles.pushbutton_abort, 'Value'));

% get ctrl device starting value
switch conf.control.type
    case 1 % EPICS PVs are absolute
        control.start = lcaGetSmart(conf.control.name);
    case 2 % SLC multiknobs are relative
        control.start = 0;
    otherwise
        control.start = 0;
end

control.current = 0;

% create ring buffers
ringsize = conf.dither.ringsize;
[bufcval, bufcts, bufsval, bufsts] = deal(zeros(ringsize,1));
count = 0;

% set plot labels
set(handles.text_control_title, 'String', sprintf('%s vs Time', conf.control.name));
set(handles.text_signal_title,  'String', sprintf('%s vs Time', conf.signal.name));

gui_statusDisp(handles, 'Dither running.  Press stop to change parameters.');
% main loop
while ~abort

    % variables to store response - 3 values (-, 0, +)
    control.range = zeros(3, 1);
    data = zeros(3, conf.signal.samples);
    ts = zeros(1, conf.signal.samples);

    % construct dither range
    control.range = control.start + control.current + conf.control.step * [0 -1 1];
    control.deltas = [0 diff(control.range)];
    toohigh = control.range > conf.control.max;
    toolow  = control.range < conf.control.min;
    control.range(toohigh) = conf.control.max;
    control.range(toolow) = conf.control.min;

    % dither here
    for ix = 1:numel(control.range)
        % increment ring buffer counter
        count = mod(count, ringsize);
        count = count + 1;

        % set control device
        switch conf.control.type
            case 1 % EPICS PV
                ok = lcaPutSmart(conf.control.name, control.range(ix));
            case 2 % SLC multiknob
                try
                    ok = 1;
                    dc.set(control.deltas(ix));
                catch
                    ok = 0;
                end
            otherwise
                gui_statusDisp(handles, sprintf('Oops, signal type = %d not defined!  Aborting.', conf.control.type));
                abort = true;
                % this should never happen
        end

        % save data into circular buffer
        if ~ok
            set(handles.status_txt, 'ForegroundColor', 'r');
            gui_statusDisp(handles, sprintf('Error setting %s!!', conf.control.name));
            pause(1);
            set(handles.status_txt, 'ForegroundColor', 'b');
        else
            bufcval(count) = control.range(ix);
            bufcts(count) = now;
        end

        % plot control val circular buffer
        filled = sum(bufcts ~= 0);
        time_since = (bufcts(bufcts ~= 0) - now) * 24 * 3600;
        time_sorted = circshift(time_since, [-count 1]);
        vals = circshift(bufcval(bufcts ~= 0), [-count 1]);

        plot(handles.axes_control, time_sorted, vals, 'm');

        % settle
        pause(conf.control.settle);

        % get data
        %gui_statusDisp(handles, strcat({'Acquiring '}, num2str(conf.signal.samples), {' points'}));
        switch conf.signal.type
            case 1 % EPICS PV
                for jx = 1:conf.signal.samples
                    lcaNewMonitorWait(conf.signal.name);
                    [data(ix, jx), ts(ix)] = lcaGetSmart(conf.signal.name);
                end

            case 2 % SLC BPM
                dsdata = pvaGetM(sprintf('%s:BUFFACQ', dgrp));
                switch n
                    case 3
                        data(ix, :) = reshape(cell2mat(cell(dsdata.values.x)),[],1);
                    case 4
                        data(ix, :) = reshape(cell2mat(cell(dsdata.values.y)),[],1);
                    case 5
                        data(ix, :) = reshape(cell2mat(cell(dsdata.values.tmit)),[],1);
                end
            otherwise
        end

        bufsval(count) = mean(data(ix, :));
        bufsts(count) = now;

        % plot signal val circular buffer
        filled = sum(bufsts ~= 0);
        time_since = (bufsts(bufsts ~= 0) - now) * 24 * 3600;
        time_sorted = circshift(time_since, [-count 1]);
        vals = circshift(bufsval(bufsts ~= 0), [-count 1]);
        plot(handles.axes_signal, time_sorted, vals, 'b');

    end

    % average over samples
    yavg = mean(data, 2);
    ystd = std(data, 0, 2);

    % fit to parabola
    x = control.range;
    xfit = linspace(min(x), max(x), 100);
    [par, yfit, parstd, yfitstd] = util_parabFit(x, yavg, ystd, xfit);
    if conf.dither.mode == 1
        [ypeak, index] = max(yfit);
        xpeak = xfit(index);
    elseif conf.dither.mode == 2
        [ypeak, index] = min(yfit);
        xpeak = xfit(index);
    end
%     xpeak = par(2);
%     ypeak = par(3);

    % constrain peak value to scan range
    if conf.dither.constrain
        if xpeak < min(x)
            xpeak = min(x);
            ypeak = yfit(1);
        end
        if xpeak > max(x)
            xpeak = max(x);
            ypeak = yfit(100);
        end
    end

    % flag out-of-range data
    if any(any(data > conf.signal.max)) || ...
        any(any(data < conf.signal.min))
        signalok = 0;
    else
        signalok = 1;
    end

%     % flag upside-down fit
%     if  ((conf.dither.mode == 1) && (par(1) < 0)) || ...
%         ((conf.dither.mode == 2) && (par(1) > 0))
        fitok = 1;
%     else
%         fitok = 0;
%     end
%
    % calculate new control value
    xnew = control.range(1) + ((xpeak - control.range(1)) * conf.dither.gain);

    % plot data
    cla(handles.axes_plot, 'reset');
    hold(handles.axes_plot, 'all');
    for ix = 1:numel(x)
        plot(handles.axes_plot, x(ix), data(ix, :), 'b*');
    end

    % plot fit
    if fitok
        plot(handles.axes_plot, xfit, yfit, 'b-');
    else
        plot(handles.axes_plot, xfit, yfit, 'r-');
    end

    % plot peak and line at new value
    plot(handles.axes_plot, xpeak, ypeak, 'ks', 'MarkerSize', 6, 'LineWidth', 3);
    lims = ylim(handles.axes_plot);
    plot(handles.axes_plot, repmat(xnew, [1 10]), linspace(min(lims), max(lims), 10), 'm--');

    % move to new peak
    if fitok && signalok
        switch conf.control.type
            case 1 % EPICS PV
                ok = lcaPutSmart(conf.control.name, xnew);
                if ~ok
                    set(handles.status_txt, 'ForegroundColor', 'r');
                    gui_statusDisp(handles, sprintf('Error setting %s!!', conf.control.name));
                    pause(1);
                    set(handles.status_txt, 'ForegroundColor', 'b');
                end

            case 2 % SLC multiknobs are relative
                try
                    ok = 1;
                    dc.set(xnew - control.range(end));
                catch
                    ok = 0;
                end
            otherwise
        end
        control.current = xnew - control.start;
    end

    abort = abort | logical(get(handles.pushbutton_abort, 'Value'));
    if abort, break; end

    pause(conf.dither.wait);

    abort = abort | logical(get(handles.pushbutton_abort, 'Value'));
end

if abort
    set(handles.pushbutton_abort, 'Value', 0);
    gui_statusDisp(handles, 'Dither stopped.');
end

% disable GUI elements
handles = gui_enable(handles, 'on');

set(hObject, 'String', oldstr);
set(hObject, 'Enable', 'on');
guidata(hObject, handles);

function handles = gui_enable(handles, enable)
% utility function to enable/disable GUI elements during running

set([handles.popupmenu_preset; ...
     handles.popupmenu_control_type; ...
     handles.popupmenu_signal_type; ...
     handles.popupmenu_mode; ...
     handles.popupmenu_dgrp; ...
     handles.edit_control_name; ...
     handles.edit_control_step; ...
     handles.edit_control_settle; ...
     handles.edit_control_max; ...
     handles.edit_control_min; ...
     handles.edit_signal_name; ...
     handles.edit_signal_samples; ...
     handles.edit_gain; ...
     handles.edit_wait; ...
     handles.checkbox_constrain; ...
    ], 'Enable', enable);

function edit_control_step_Callback(hObject, eventdata, handles)
% hObject    handle to edit_control_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_control_step as text
%        str2double(get(hObject,'String')) returns contents of edit_control_step as a double


% --- Executes during object creation, after setting all properties.
function edit_control_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_control_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_constrain.
function checkbox_constrain_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_constrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_constrain



function edit_knob_Callback(hObject, eventdata, handles)
% hObject    handle to edit_knob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_knob as text
%        str2double(get(hObject,'String')) returns contents of edit_knob as a double


% --- Executes during object creation, after setting all properties.
function edit_knob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_knob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_diagname_Callback(hObject, eventdata, handles)
% hObject    handle to edit_diagname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_diagname as text
%        str2double(get(hObject,'String')) returns contents of edit_diagname as a double


% --- Executes during object creation, after setting all properties.
function edit_diagname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_diagname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_samples_Callback(hObject, eventdata, handles)
% hObject    handle to edit_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_samples as text
%        str2double(get(hObject,'String')) returns contents of edit_samples as a double


% --- Executes during object creation, after setting all properties.
function edit_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_wait_Callback(hObject, eventdata, handles)
% hObject    handle to edit_wait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_wait as text
%        str2double(get(hObject,'String')) returns contents of edit_wait as a double


% --- Executes during object creation, after setting all properties.
function edit_wait_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_wait (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gain as text
%        str2double(get(hObject,'String')) returns contents of edit_gain as a double


% --- Executes during object creation, after setting all properties.
function edit_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_control_settle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_control_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_control_settle as text
%        str2double(get(hObject,'String')) returns contents of edit_control_settle as a double


% --- Executes during object creation, after setting all properties.
function edit_control_settle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_control_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_preset_Callback(hObject, eventdata, handles)
handles = set_preset(handles);
guidata(hObject, handles);

function popupmenu_preset_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_abort_Callback(hObject, eventdata, handles)


function popupmenu_signal_type_Callback(hObject, eventdata, handles)
switch get(hObject, 'Value')
    case 2
        set(handles.text_dgrp,      'Visible', 'on');
        set(handles.popupmenu_dgrp, 'Visible', 'on');
    otherwise
        set(handles.text_dgrp,      'Visible', 'off');
        set(handles.popupmenu_dgrp, 'Visible', 'off');
end

function popupmenu_signal_type_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_signal_name_Callback(hObject, eventdata, handles)


function edit_signal_name_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_signal_samples_Callback(hObject, eventdata, handles)


function edit_signal_samples_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_control_type_Callback(hObject, eventdata, handles)


function popupmenu_control_type_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_control_name_Callback(hObject, eventdata, handles)


function edit_control_name_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_mode_Callback(hObject, eventdata, handles)


function popupmenu_mode_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_dgrp_Callback(hObject, eventdata, handles)


function popupmenu_dgrp_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_save_new_Callback(hObject, eventdata, handles)


function pushbutton_save_Callback(hObject, eventdata, handles)


function pushbutton_delete_Callback(hObject, eventdata, handles)


function edit_control_min_Callback(hObject, eventdata, handles)


function edit_control_min_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_control_max_Callback(hObject, eventdata, handles)


function edit_control_max_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_ringsize_Callback(hObject, eventdata, handles)


function edit_ringsize_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_signal_min_Callback(hObject, eventdata, handles)


function edit_signal_min_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_signal_max_Callback(hObject, eventdata, handles)


function edit_signal_max_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function figure1_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


