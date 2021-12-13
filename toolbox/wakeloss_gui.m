function varargout = wakeloss_gui(varargin)
% WAKELOSS_GUI M-file for wakeloss_gui.fig
%      WAKELOSS_GUI, by itself, creates a new WAKELOSS_GUI or raises the existing
%      singleton*.
%
%      H = WAKELOSS_GUI returns the handle to a new WAKELOSS_GUI or the handle to
%      the existing singleton*.
%
%      WAKELOSS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAKELOSS_GUI.M with the given input arguments.
%
%      WAKELOSS_GUI('Property','Value',...) creates a new WAKELOSS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wakeloss_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wakeloss_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wakeloss_gui

% Last Modified by GUIDE v2.5 12-Apr-2012 13:08:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wakeloss_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @wakeloss_gui_OutputFcn, ...
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


% --- Executes just before wakeloss_gui is made visible.
function wakeloss_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wakeloss_gui (see VARARGIN)

% Choose default command line output for wakeloss_gui
handles.output = hObject;
handles.appName = 'wakeloss_gui';
%
% set(hObject, 'Toolbar', 'figure');

set(handles.axes2, 'Position', get(handles.axes1, 'Position'));
set(handles.axes2, 'YAxisLocation', 'right');

handles.setup.name = {'PHAS:DR12:61:VDES' 'BNS0206.MKB' 'STAGGERED_CHIRP.MKB'};
handles.setup.isSLC = [1 0 0];
handles.setup.isMKB = [0 1 1];

set(handles.popupmenu_setup, 'String', handles.setup.name);
set(handles.popupmenu_setup, 'Value', 3);

handles.rates = {'EVNT:SYS1:1:BEAMRATE' 'EVNT:SYS1:1:SCAVRATE'};
handles.beams = {'FACET' 'SCAV'};
handles.bpmds = {'57' '8'};
handles.dgrps = {'NDRFACET' 'ELECEP01'};

handles.bpms = {'BPMS:LI10:3448'  'BPMS:LI02:201'
                'BPMS:LI20:2050'  'BPMS:EP01:170'
                'BPMS:LI20:2147'  'BPMS:EP01:185'
                'BPMS:LI20:2160'  'BPMS:EP01:190'
                'BPMS:LI20:2223'  'BPMS:LI02:201'
                };

handles.wakeloss.name = {'BPMS:LI20:2147:X'     'BPMS:EP01:185:X';
                         'SIOC:SYS1:ML00:AO058' 'SIOC:SYS1:ML00:AO067'};
handles.wakeloss.fbpv = {'LI09:FBCK:200:HSTA'   'LI09:FBCK:200:HSTA';
                         'SIOC:SYS1:ML00:AO084' 'SIOC:SYS1:ML00:AO060'};
handles.wakeloss.isFbck = [0 0; 1 1];
handles.wakeloss.isBPM = [1 1; 0 0];

handles.rate = lcaGetSmart(handles.rates);
[d, handles.beam] = max(handles.rate);

set(handles.popupmenu_beam, 'String', handles.beams);
set(handles.popupmenu_beam, 'Value', handles.beam);

set(handles.popupmenu_wakeloss, 'String', handles.wakeloss.name(:,handles.beam));
set(handles.popupmenu_wakeloss, 'Value', 1);

handles = update_gui(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wakeloss_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = update_gui(handles)

handles.config.rates = lcaGetSmart(handles.rates);
handles.config.beam = get(handles.popupmenu_beam, 'Value');
handles.config.bpmd = handles.bpmds{handles.config.beam};
handles.config.dgrp = handles.dgrps{handles.config.beam};
set(handles.text_rate, 'String', sprintf('%d Hz', handles.config.rates(handles.config.beam)));

handles.config.setup = get(handles.popupmenu_setup, 'Value');
handles.config.setup_name = handles.setup.name{handles.config.setup};
handles.config.isMKB = handles.setup.isMKB(handles.config.setup);
handles.config.isSLC = handles.setup.isSLC(handles.config.setup);

set(handles.popupmenu_wakeloss, 'String', handles.wakeloss.name(:,handles.config.beam));
handles.config.wakeloss = get(handles.popupmenu_wakeloss, 'Value');
handles.config.wakeloss_name = handles.wakeloss.name{handles.config.wakeloss, handles.config.beam};
handles.config.bpms = handles.bpms(:,handles.config.beam);
handles.config.isFbck = handles.wakeloss.isFbck(handles.config.wakeloss, handles.config.beam);
handles.config.isBPM = handles.wakeloss.isBPM(handles.config.wakeloss, handles.config.beam);

handles.config.nstep = str2int(get(handles.edit_nstep, 'String'));
handles.config.nsamp = str2int(get(handles.edit_nsamp, 'String'));
handles.config.range = str2double(get(handles.edit_range, 'String'));
handles.config.settle = str2double(get(handles.edit_settle, 'String'));
handles.config.zigzag = get(handles.checkbox_zigzag, 'Value');

handles.config.blen = get(handles.edit_blen, 'String');
handles.config.plot.wakeloss = get(handles.checkbox_plot_wakeloss, 'Value');
handles.config.plot.blen = get(handles.checkbox_plot_blen, 'Value');
handles.config.plot.avg = get(handles.checkbox_plotavg, 'Value');
handles.config.plot.fit = get(handles.checkbox_plotfit, 'Value');

% --- Outputs from this function are returned to the command line.
function varargout = wakeloss_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_setup.
function popupmenu_setup_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_setup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_setup


% --- Executes during object creation, after setting all properties.
function popupmenu_setup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_blen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_blen as text
%        str2double(get(hObject,'String')) returns contents of edit_blen as a double


% --- Executes during object creation, after setting all properties.
function edit_blen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nstep_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_nstep as text
%        str2double(get(hObject,'String')) returns contents of edit_nstep as a double


% --- Executes during object creation, after setting all properties.
function edit_nstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nsamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nsamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_nsamp as text
%        str2double(get(hObject,'String')) returns contents of edit_nsamp as a double


% --- Executes during object creation, after setting all properties.
function edit_nsamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nsamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_zigzag.
function checkbox_zigzag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_zigzag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_zigzag



function edit_range_Callback(hObject, eventdata, handles)
% hObject    handle to edit_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_range as text
%        str2double(get(hObject,'String')) returns contents of edit_range as a double


% --- Executes during object creation, after setting all properties.
function edit_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_settle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_settle as text
%        str2double(get(hObject,'String')) returns contents of edit_settle as a double


% --- Executes during object creation, after setting all properties.
function edit_settle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_settle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_acquire.
function pushbutton_acquire_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_acquire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', 'Acquiring...');
tic;
% clear out data
handles.data = [];
handles.data.config = handles.config;

% generate a scan range
phases = linspace(-handles.config.range, handles.config.range, handles.config.nstep)';

% zigzag it if necessary
if handles.config.zigzag
    odds = find(bitget(1:numel(phases), 1));
    evens = find(~bitget(1:numel(phases), 1));
    midpt = round(numel(odds)/2);
    s1 = odds(1:midpt);
    s3 = odds(midpt+1:end);
    s2 = flipdim(evens, 2);
    scan_pts = ([s3 s2 s1])';
    phases = phases(scan_pts);
end

% save scan range
if handles.config.isMKB
    handles.data.pdes = phases;
    handles.data.deltas = diff([0; handles.data.pdes; 0]);
elseif handles.config.isSLC
    [p, m, u, s] = model_nameSplit(handles.config.setup_name);
    epics_name = sprintf('%s:%s:%s:%s', char(m), char(p), char(u), char(s));
    pdes0 = lcaGetSmart(epics_name);
    handles.data.pdes = phases + pdes0;
end

gui_statusDisp(handles, 'Setting up AIDA...');

% create aida control object
requestBuilder = pvaRequest('MKB:VAL');
if handles.config.isMKB
    requestBuilder.with('MKB', strcat('mkb:', handles.config.setup_name));
elseif handles.config.isSLC
    requestBuilder.with('TRIM', 'YES');
end

gui_statusDisp(handles, 'Setting up BSA...');

% reserve eDef
eDef = eDefReserve(handles.appName);
if ~eDef
    gui_statusDisp(handles, 'Could not reserve an eDef.  Aborting.');
    set(hObject, 'String', 'Acquire');
    return
else
    handles.eDef = eDef;
    eDefParams(eDef, 1, -1);  % turn on eDef for extra long
    gui_statusDisp(handles, sprintf('Reserved eDef # %d', eDef));
end

% get BPM dispersion
if handles.config.isBPM
    [p, m, u, s] = model_nameSplit(handles.config.wakeloss_name);
    bpmroot = sprintf('%s:%s:%s', char(p), char(m), char(u));
    handles.data.bpm.plane = char(s);
    twiss = model_rMatGet(bpmroot, [], 'TYPE=DESIGN', 'twiss');
    if strcmp(upper(s), 'X')
        handles.data.bpm.eta = twiss(5);
    elseif strcmp(upper(s), 'Y')
        handles.data.bpm.eta = twiss(10);
    end
    bpmidx = strmatch(bpmroot, handles.config.bpms);
end

% check feedbacks
fbstate = lcaGetSmart(handles.wakeloss.fbpv);
% flag LI10 feedback here
if handles.config.isBPM
    % turn off downstream feedbacks if using bpm
    lcaPutSmart(handles.wakeloss.fbpv([2 4])', 0);
end

% save timestamp
handles.data.ts = now;

% keep track of total knob changes
pchange = 0;
abort = 0;

% main scan loop
for ix = 1:handles.config.nstep

    if get(handles.pushbutton_abort, 'Value')
        gui_statusDisp(handles, 'Aborting...');
        abort = 1;
        break
    end

    handles.scanstep = ix;

    gui_statusDisp(handles, sprintf('Setting %s to %.1f (step %d/%d)', ...
        handles.config.setup_name, handles.data.pdes(ix), ix, handles.config.nstep));

    % set phase
    if handles.config.isMKB
       pact = requestBuilder.set(handles.data.deltas(ix));
       handles.data.pact(ix) = handles.data.pdes(ix);
    elseif handles.config.isSLC
       daslc = pvaRequest(sprintf('%s:%s:%s:%s', char(m), char(p), char(u), char(s)));
       pact = daslc.set(pdes0); %% Original code has a bug in it so this is just a guess
       handles.data.pact(ix) = double(java.lang.Float(pact));
    end

    pchange = pchange + handles.data.deltas(ix);

    % wait for settle time
    pause(handles.config.settle);

    gui_statusDisp(handles, sprintf('Acquiring %d pulses at %d Hz...', ...
        handles.config.nsamp, handles.config.rates(handles.config.beam)));

    % turn on eDef
    eDefOn(eDef);

    if handles.config.isBPM

        % start buffered acquisition
        [x, y, tmit, pulseid, stat] = control_bpmAidaGet(...
            handles.config.bpms, handles.config.nsamp, handles.config.bpmd);

        % store data
        handles.data.bpm.x(ix,:) = x(bpmidx,:);
        handles.data.bpm.y(ix,:) = y(bpmidx,:);
        handles.data.bpm.tmit(ix,:) = tmit(bpmidx,:);
        handles.data.bpm.pulseid(ix,:) = pulseid(bpmidx,:);
        handles.data.bpm.stat(ix,:) = stat(bpmidx,:);

    elseif handles.config.isFbck

        % do sequential lcaGets

        for jx = 1:handles.config.nsamp

            % get sector 10 bpm
            handles.data.x0(ix, jx) = lcaGetSmart('BPMS:LI10:2050:X57');

            % get the energy
            [handles.data.fbck.e(ix,jx) handles.data.fbck.ts(ix,jx)] = lcaGetSmart(handles.config.wakeloss_name);
            pause(1/handles.config.rates(handles.beam));

            % convert timestamp to pulseid
            handles.data.fbck.pulseid(ix,jx) = lcaTs2PulseId(handles.data.ts(ix,jx));
        end


    end

    % turn off eDef
    eDefOff(eDef);

    % wait for eDEF thingy to process
    pause(1);

    % get BSA pulseid and data
    BSA_count = lcaGetSmart(sprintf('EDEF:SYS1:%d:CNT', eDef));
    BSA_pulseid = lcaGetSmart(strcat('PATT:SYS1:1:PULSEIDHST', num2str(eDef)), BSA_count);
    BSA_data = lcaGetSmart(strcat(handles.config.blen, 'HST', num2str(eDef)), BSA_count);

    % match BSA samples to BPM data
    for jx = 1:handles.config.nsamp
        index = find(BSA_pulseid == handles.data.bpm.pulseid(ix, jx));
        if isempty(index)
            handles.data.blen.pulseid(ix,jx) = NaN;
            handles.data.blen.val(ix,jx) = NaN;
            handles.data.blen.stat(ix,jx) = 0;
        else
            handles.data.blen.pulseid(ix,jx) = BSA_pulseid(index);
            handles.data.blen.val(ix,jx) = BSA_data(index);
            handles.data.blen.stat(ix,jx) = 1;
        end
    end

    handles = fit_and_plot(handles);

end

if abort
    % restore phase knob
    if handles.config.isMKB
        requestBuilder.set(DaValue(-1 * pchange));
    elseif handles.config.isSLC
        daslc = pvaRequest(sprintf('%s:%s:%s:%s', char(m), char(p), char(u), char(s)));
        pact = daslc.set(pdes0);
    end

    gui_statusDisp(handles, 'Acquisition aborted.');

    set(handles.pushbutton_abort, 'Value', 0);
    set(handles.pushbutton_abort, 'String', 'Abort');

else

    % restore phase knob
    if handles.config.isMKB
        requestBuilder.set(handles.data.deltas(end));
    elseif handles.config.isSLC
        daslc = pvaRequest(sprintf('%s:%s:%s:%s', char(m), char(p), char(u), char(s)));
        pact = daslc.set(pdes0);
    end

    gui_statusDisp(handles, 'Acquisition finished.');
end

% turn feedbacks back on
lcaPutSmart(handles.wakeloss.fbpv([2 4])', fbstate([2 4]));


set(hObject, 'String', 'Acquire');
toc;
guidata(hObject, handles);

function handles = fit_and_plot(handles, export)

if nargin < 2, export = 0; end

handles.data.fit.phase = reshape(handles.data.pact, [], 1);

% if numel(handles.data.pact) > 3
%     dofit = 1;
% else
%     dofit = 0;
% end

% flip blen signal since it is negative :(
handles.data.fit.blen = abs(handles.data.blen.val);

if handles.config.isBPM
    eend = lcaGetSmart('VX00:LEMG:5:EEND');
    e0   = eend(2);
    if strcmp(handles.data.bpm.plane, 'X')
        handles.data.fit.energy = sign(handles.data.bpm.eta) * handles.data.bpm.x * e0 / handles.data.bpm.eta;
    elseif strcmp(handles.data.bpm.plane, 'Y')
        handles.data.fit.energy = sign(handles.data.bpm.eta) * handles.data.bpm.y * e0 / handles.data.bpm.eta;
    end
end

if handles.config.isFbck
    handles.data.fit.energy = handles.data.fbck.e;
end

% fit to gaussian
xFit = linspace(min(handles.data.fit.phase), max(handles.data.fit.phase), 100);

eMean = mean(handles.data.fit.energy, 2);
eStd = std(handles.data.fit.energy, [], 2);

bMean = mean(handles.data.fit.blen, 2);
bStd = std(handles.data.fit.blen, [], 2);

[par, yFit, parstd, yFitStd, mse, pcov, rfe] = ...
    util_gaussFit(handles.data.fit.phase, eMean, 1, 0, eStd, xFit);

if ~export
    ax(1) = handles.axes1;
    ax(2) = handles.axes2;
else
    handles.printfig = figure;
    ax(1) = axes;
    ax(2) = axes('YAxisLocation', 'right');
end


cla(ax(1)); hold(ax(1), 'all');
cla(ax(2)); hold(ax(2), 'all');

if handles.config.plot.wakeloss && handles.config.plot.blen
    set(ax(1), 'Visible', 'on', 'Color', [1 1 1]);
    set(ax(2), 'Visible', 'on', 'Color', 'none');
    doplot = [1 1];
elseif ~handles.config.plot.wakeloss && handles.config.plot.blen
    set(ax(1), 'Visible', 'off', 'Color', 'none');
    set(ax(2), 'Visible', 'on', 'Color', [1 1 1]);
    doplot = [0 1];
elseif handles.config.plot.wakeloss && ~handles.config.plot.blen
    set(ax(1), 'Visible', 'on', 'Color', [1 1 1]);
    set(ax(2), 'Visible', 'off', 'Color', 'none');
    doplot = [1 0];
else
    set(ax(1), 'Visible', 'on', 'Color', [1 1 1]);
    set(ax(2), 'Visible', 'off', 'Color', 'none');
    doplot = [0 0];
end

if handles.config.plot.wakeloss

    set(get(ax(1), 'YLabel'), 'String', strcat(handles.data.config.wakeloss_name, {' E Loss [MeV]'}));
    if handles.config.plot.avg
        errorbar(ax(1), handles.data.fit.phase, eMean, eStd, 'ks', 'Parent', ax(1), 'LineWidth', 2);
    else
        plot(ax(1), handles.data.fit.phase, handles.data.fit.energy, 'k*');
    end
    if handles.config.plot.fit
        plot(ax(1), xFit, yFit, 'b-', 'LineWidth', 2);
    end
end

if handles.config.plot.blen
    set(get(ax(2), 'YLabel'), 'String', handles.data.config.blen);
    if handles.config.plot.avg
        errorbar(ax(2), handles.data.fit.phase, bMean, bStd, 'ms', 'Parent', ax(2), 'LineWidth', 2);
    else
        plot(ax(2), handles.data.fit.phase, handles.data.fit.blen, 'm*');
    end
end

label_ax = ax(find(doplot, 1, 'first'));
if ~isempty(label_ax);
    title(label_ax, char(sprintf('Wakeloss %.1f MeV %s', par(1), datestr(handles.data.ts))));
    set(get(label_ax, 'XLabel'), 'String', strcat(handles.data.config.setup_name), 'Interpreter', 'none');
end


% --- Executes on button press in pushbutton_abort.
function pushbutton_abort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', 'Aborting...');
guidata(hObject, handles);

% --- Executes on button press in checkbox_plot_wakeloss.
function checkbox_plot_wakeloss_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_wakeloss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
handles = fit_and_plot(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_wakeloss


% --- Executes on button press in checkbox_plot_blen.
function checkbox_plot_blen_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plot_blen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
handles = fit_and_plot(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_plot_blen


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = util_dataSave(handles.data, 'wakeloss', handles.data.config.setup_name, now);
gui_statusDisp(handles, sprintf('Data saved to %s/%s', pathname, filename));

guidata(hObject, handles);



% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data = util_dataLoad();
% handles.config = handles.data.config;
handles = fit_and_plot(handles);
guidata(hObject, handles);

% --- Executes on button press in pushbutton_print.
function pushbutton_print_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
handles = fit_and_plot(handles, 1);
util_appFonts(handles.printfig, 'fontName', 'times', 'fontSize', 14);
util_printLog(handles.printfig);
guidata(hObject, handles);

% --- Executes on selection change in popupmenu_wakeloss.
function popupmenu_wakeloss_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_wakeloss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_wakeloss contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_wakeloss


% --- Executes during object creation, after setting all properties.
function popupmenu_wakeloss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_wakeloss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_facet.
function radiobutton_facet_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_facet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_facet


% --- Executes on button press in radiobutton_scav.
function radiobutton_scav_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_scav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_scav


% --- Executes on selection change in popupmenu_beam.
function popupmenu_beam_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_beam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_beam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_beam


% --- Executes during object creation, after setting all properties.
function popupmenu_beam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_beam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_plotavg.
function checkbox_plotavg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotavg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
handles = fit_and_plot(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_plotavg


% --- Executes on button press in checkbox_plotfit.
function checkbox_plotfit_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
handles = fit_and_plot(handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_plotfit


