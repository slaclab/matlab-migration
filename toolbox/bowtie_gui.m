function varargout = bowtie_gui(varargin)
% BOWTIE_GUI M-file for bowtie_gui.fig
%      BOWTIE_GUI, by itself, creates a new BOWTIE_GUI or raises the existing
%      singleton*.
%
%      H = BOWTIE_GUI returns the handle to a new BOWTIE_GUI or the handle to
%      the existing singleton*.
%
%      BOWTIE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOWTIE_GUI.M with the given input arguments.
%
%      BOWTIE_GUI('Property','Value',...) creates a new BOWTIE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bowtie_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bowtie_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bowtie_gui

% Last Modified by GUIDE v2.5 08-Nov-2019 09:28:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bowtie_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bowtie_gui_OutputFcn, ...
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


% --- Executes just before bowtie_gui is made visible.
function bowtie_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bowtie_gui (see VARARGIN)

% Choose default command line output for bowtie_gui
handles.output = hObject;

gui_statusDisp(handles, 'Loading..');

% Update handles structure
guidata(hObject, handles);


function handles = auto_setup(handles)

set(handles.pushbutton_start, 'Enable', 'off');
set(handles.togglebutton_abort, 'Enable', 'off');
drawnow;

handles = auto_quad_sel(handles);
handles = auto_quad_range(handles);
handles = auto_corr_sel(handles);
handles = auto_corr_range(handles);


set(handles.pushbutton_start, 'Enable', 'on');
set(handles.togglebutton_abort, 'Enable', 'on');
drawnow;

function handles = auto_quad_sel(handles)

% automatic choose the quad for bowtie
if get(handles.checkbox_auto_quad, 'Value')

    % set the GUI string
    gui_statusDisp(handles, 'Finding best QUAD...');
    oldtxt = get(handles.text_sel_quad, 'String');
    set(handles.text_sel_quad, 'String', 'Finding...', 'ForegroundColor', 'red');  drawnow;
    set(handles.popupmenu_quad, 'Enable', 'off');

    % find the nearest QUAD
    bpm_sel = get(handles.popupmenu_bpms, 'Value');
    bpm_name = handles.bpms.name{bpm_sel};
    bpm_z = handles.bpms.z(bpm_sel);
    d = handles.quad.z - bpm_z;
    [min_d, min_i] = min(abs(d));

    % change the dropdown box to this quad
    set(handles.popupmenu_quad, 'Value', min_i);
    gui_statusDisp(handles, sprintf('%s selected, %.2f mm to %s', ...
        handles.quad.name{min_i}, min_d * 1e3, bpm_name));
    set(handles.popupmenu_quad, 'Enable', 'on');
    handles = popupmenu_quad_Callback(handles.popupmenu_quad, [], handles);

    % reset the GUI string
    set(handles.text_sel_quad, 'String', oldtxt, 'ForegroundColor', 'black');
    drawnow;


end

function handles = auto_quad_range(handles)

if get(handles.checkbox_auto_qrange, 'Value')

    set(handles.checkbox_auto_qrange, 'String', 'Finding...', 'ForegroundColor', 'red');
    drawnow;

    frac = 0.01 * str2num(get(handles.edit_quad_frac, 'String'));

    % get the LGPS if controlled by one
    name = get(handles.text_quad_lgps, 'String');

    % get the current state
    [bact, bdes] = control_magnetGet(name);

    % find the range of allowable values
    maxb = control_magnetGet(name, 'BMAX');
    bmax = maxb;
    brange = [0 bmax];

    if strcmp(handles.accelerator, 'LCLS')
        % LCLS database handles BMAX different from SLC
        minb = control_magnetGet(name, 'BMIN');
        brange = [minb maxb];
        [d, ibmax] = max(abs(brange));
        bmax = brange(ibmax);
    end

    % calculate how much to change BDES
    s = sign(bmax);
    delta = abs(frac * bdes);
    blo = bdes - delta;
    bhi = bdes + delta;

    % constrain BDES to within PS range
    blow = max([blo, brange(1)]) * 0.98;
    bhigh = min([bhi, brange(2)]) * 0.98;

    if strcmp(handles.accelerator, 'FACET')

        % special code for handling linac bulk-boosts
        hsta = control_deviceGet(name, 'HSTA');
        pscp = control_deviceGet(name, 'PSCP');

        if bitget(hsta, 15) && pscp == 1 % bit 15 ('4000') flags LGPS

            %%%%% this is not done %%%%%
            micros = textscan(num2str(2:19, 'LI%02d\n'), '%s'); micros = micros{:};
            [m, p, u] = model_nameSplit(name);

            ivb = control_magnetIVBGet(name);
            immo = control_deviceGet(name, 'IMMO');
            brange = linspace(0, bmax, 200);
            irange = polyval(ivb, brange);
            bvi = polyfit(irange, brange, numel(ivb));

            lgps = strcat(m, ':LGPS:', num2str(pscp));
            lgps_bact = control_deviceGet(lgps, 'BACT');

            immrange = immo(2) - immo(1);

            imin = lgps_bact + 0.1 * sign(immo(2)) * (immo(2) - immo(1));
            imax = lgps_bact + 0.9 * sign(immo(2)) * (immo(2) - immo(1));

            blow = polyval(bvi, imin);
            bhigh = polyval(bvi, imax);

        end
    end

    set(handles.edit_quad_low, 'String', num2str(blow));
    set(handles.edit_quad_high, 'String', num2str(bhigh));

    set(handles.checkbox_auto_qrange, 'String','Auto Range:', 'ForegroundColor', 'black');
    drawnow;
end

function handles = auto_corr_sel(handles)

if get(handles.checkbox_auto_corr, 'Value')

    % set the GUI string
    oldtxt = get(handles.text_sel_corr, 'String');
    set(handles.text_sel_corr, 'String', 'Finding...', 'ForegroundColor', 'red');  drawnow;
    set(handles.popupmenu_corr, 'Enable', 'off');
    drawnow;

    % find the N nearest upstream corrs
    N = 10;
    bpm_sel = get(handles.popupmenu_bpms, 'Value');
    bpm_name = handles.bpms.name{bpm_sel};
    bpm_z = handles.bpms.z(bpm_sel);
    switch handles.plane
        case 'x'
            upstream = handles.xcor.name(handles.xcor.z < bpm_z);
            n = numel(upstream);
            if n > N
                upstream = upstream(n-N:end);
            end
            rmat = model_rMatGet(upstream, bpm_name, {'TYPE=DESIGN', ['BEAMPATH=' handles.beamPath]}, 'RMAT');
            kick = squeeze(rmat(1,2,:));
        case 'y'
            upstream = handles.ycor.name(handles.ycor.z < bpm_z);
            n = numel(upstream);
            if n > N
                upstream = upstream(n-N:end);
            end
            rmat = model_rMatGet(upstream, bpm_name, {'TYPE=DESIGN', ['BEAMPATH=' handles.beamPath]}, 'RMAT');
            kick = squeeze(rmat(3,4,:));
    end

    [max_k, max_i] = max(abs(kick));
    max_name = upstream{max_i};
    cor_names = get(handles.popupmenu_corr, 'String');
    cor_i = find(strcmpi(cor_names, max_name));

    % change the dropdown box to this corr
    set(handles.popupmenu_corr, 'Value', cor_i);
    gui_statusDisp(handles, sprintf('%s selected, R12 = %.2f to %s', ...
        max_name, max_k, bpm_name));

%     handles.rmat = rmat(:,:,cor_i);

    set(handles.popupmenu_corr, 'Enable', 'on');
    handles = popupmenu_corr_Callback(handles.popupmenu_corr, [], handles);

    set(handles.text_sel_corr, 'String', oldtxt, 'ForegroundColor', 'black');
    drawnow;
end

function handles = auto_corr_range(handles)

if get(handles.checkbox_auto_crange, 'Value')

    set(handles.checkbox_auto_crange, 'String', 'Finding...', 'ForegroundColor', 'red');  drawnow;

    % get amplitude of scan (beam movement in quad)
    ampl = str2num(get(handles.edit_corr_ampl, 'String'));

    corr_sel = get(handles.popupmenu_corr, 'Value');
    corr_str = get(handles.popupmenu_corr, 'String');
    corr = corr_str{corr_sel};

    quad_sel = get(handles.popupmenu_quad, 'Value');
    quad_str = get(handles.popupmenu_quad, 'String');
    quad = quad_str{quad_sel};

    rmat = model_rMatGet(corr, quad, {'TYPE=DESIGN', 'BEAMPATH=' handles.beamPath}, 'RMAT');

    [bact, bdes, bmax, edes] = control_magnetGet(corr);

    if edes == 0
        if strncmpi(corr, 'DR13', 4), edes = 1.19;end
    end

    switch handles.plane
        case 'x'
            r = rmat(1,2);
        case 'y'
            r = rmat(3,4);
    end

    dbdes = ampl * 1e-3 * 33.356 * edes / r;

    bhigh = bdes + dbdes;
    blow = bdes - dbdes;

    % check for bmax and truncate range
    if abs(bhigh) > abs(bmax)
        bhigh = bmax * sign(bhigh) *.98;
    end

    if abs(blow) > abs(bmax)
        blow = bmax * sign(blow) * .98;
    end

    set(handles.edit_corr_low, 'String', num2str(blow));
    set(handles.edit_corr_high, 'String', num2str(bhigh));

    set(handles.checkbox_auto_crange, 'String', 'Auto Range:', 'ForegroundColor', 'black');
    drawnow;

end


% UIWAIT makes bowtie_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bowtie_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.system = getSystem();
switch handles.system
    case 'SYS0'
        handles.accelerator = 'LCLS';
        handles.dgrp = '';
        ms = model_init();
        gui_modelSourceControl(handles.modelSource_btn, handles, ms);

    case 'SYS1'
        handles.accelerator = 'FACET';
        handles.dgrp = 'NDRFACET';
        ms = model_init('source', 'SLC');
        gui_modelSourceControl(handles.modelSource_btn, handles, ms);

    otherwise
    handles.accelerator = '';
    handles.dgrp = '';
    ms = model_init();
    gui_modelSourceControl(handles.modelSource_btn, handles, ms);
end
if strcmp(handles.accelerator, 'LCLS')
    handles.beamPath = get(handles.beamPath_btn, 'String');
end

% generate z-sorted list of BPMS, QUAD/QUAS, and correctors
if strcmp(handles.accelerator, 'LCLS')
    bpms.name = model_nameRegion('BPMS', handles.beamPath);
else
    bpms.name = model_nameRegion('BPMS', handles.accelerator);
end


if strcmp(handles.accelerator, 'FACET')
    isEpics = strncmpi(bpms.name, 'BPMS', 4);
    [p,m,u] = model_nameSplit(bpms.name(isEpics));
    bpms.name(isEpics) = strcat(m, ':', p, ':', u);
end
bpms.z = model_rMatGet(bpms.name, [], {'TYPE=DESIGN',['BEAMPATH=' handles.beamPath]}, 'Z');
[bpmsort, bpmorder] = sort(bpms.z);
handles.bpms.name = bpms.name(bpmorder);
handles.bpms.z = bpms.z(bpmorder);
isLI20 = strncmpi(handles.bpms.name, 'LI20', 4);
% handles.bpms.name(isLI20) = [];
% handles.bpms.z(isLI20) = [];
% handles.bpms.name(end-2:end) = [];
% handles.bpms.z(end-2:end) = [];
if strcmp(handles.accelerator, 'LCLS')
    xcor.name = model_nameRegion('XCOR', handles.beamPath);
else
    xcor.name = model_nameRegion('XCOR', handles.accelerator);
end
xcor.name(find(strcmpi(xcor.name, 'LI02:XCOR:15'))) = [];  % some dumb leftover
%xcor.z = control_deviceGet(xcor.name, 'Z');
xcor.z = model_rMatGet(xcor.name, [], {'TYPE=DESIGN',['BEAMPATH=' handles.beamPath]}, 'Z');
[xcorsort, xcororder] = sort(xcor.z);
handles.xcor.name = xcor.name(xcororder);
handles.xcor.z = xcor.z(xcororder);

if strcmp(handles.accelerator, 'LCLS')
    ycor.name = model_nameRegion('YCOR', handles.beamPath);
else
    ycor.name = model_nameRegion('YCOR', handles.accelerator);
end


ycor.name(find(strcmpi(ycor.name, 'LI02:YCOR:11'))) = [];  % more dumb leftovers
ycor.name(find(strcmpi(ycor.name, 'LI02:YCOR:31'))) = [];
%ycor.z = control_deviceGet(ycor.name, 'Z');
ycor.z = model_rMatGet(ycor.name, [], {'TYPE=DESIGN',['BEAMPATH=' handles.beamPath]}, 'Z');
[ycorsort, ycororder] = sort(ycor.z);
handles.ycor.name = ycor.name(ycororder);
handles.ycor.z = ycor.z(ycororder);

if strcmp(handles.accelerator, 'LCLS')
    quad.name = model_nameRegion({'QUAD' 'QUAS'}, handles.beamPath);
else
    quad.name = model_nameRegion({'QUAD' 'QUAS'}, handles.accelerator);
end
quad.z = model_rMatGet(quad.name, [], {'TYPE=DESIGN',['BEAMPATH=' handles.beamPath]}, 'Z');
%quad.z = control_deviceGet(quad.name, 'Z');
[quadsort, quadorder] = sort(quad.z);
handles.quad.name = quad.name(quadorder);
handles.quad.z = quad.z(quadorder);

set(handles.popupmenu_bpms, 'String', handles.bpms.name, 'Value', 27);
set(handles.listbox_bpms, 'String', handles.bpms.name, 'Value', []);
set(handles.popupmenu_quad, 'String', handles.quad.name, 'Value', 1);
set(handles.popupmenu_corr, 'String', handles.xcor.name, 'Value', 1);
set(handles.edit_quad_frac, 'String', num2str(10));
set(handles.edit_corr_ampl, 'String', num2str(1));
set(handles.edit_corr_nstep, 'String', num2str(5));
set(handles.edit_quad_nstep, 'String', num2str(2));
set(handles.edit_nsamp, 'String', num2str(10));

handles = gui_plane(handles);
handles = popupmenu_bpms_Callback(handles.popupmenu_bpms, [], handles);

% Get default command line output from handles structure
varargout{1} = handles.output;

guidata(hObject, handles);


function pushbutton_start_Callback(hObject, eventdata, handles)

if isfield(handles, 'data') && ~handles.data.saved
    button = questdlg('Existing data not saved.  Proceed with scan?', ...
        'Not Saved', 'Yes', 'No', 'No');
    if ~strcmp(button, 'Yes')
        return;
    end
end

buttontext = get(hObject, 'String');
set(hObject, 'String', 'Scanning...');
set(hObject, 'Enable', 'off');

handles.data = [];
handles.data.saved = 0;

handles.data.fitok = 0;

% save some data in the data struct
handles.data.ts = now;

% get scan parameters from the GUI
handles.data.plane = handles.plane;
handles.data.bpms = handles.bpms;
handles.data.bpm.nsamp = str2double(get(handles.edit_nsamp, 'String'));
handles.data.bpm.index = get(handles.popupmenu_bpms, 'Value');
handles.data.bpm.name = handles.bpms.name{get(handles.popupmenu_bpms, 'Value')};
if strcmp(handles.accelerator, 'LCLS')
    handles.data.bpm.offset(1) = control_deviceGet(handles.data.bpm.name, 'XAOFF');
    handles.data.bpm.offset(2) = control_deviceGet(handles.data.bpm.name, 'YAOFF');
elseif strcmp(handles.accelerator, 'FACET')
    handles.data.bpm.offset = control_deviceGet(handles.data.bpm.name, 'OFFS');
end

% get quad scan parameters from the GUI
handles.data.quad.name = handles.quad.name(get(handles.popupmenu_quad, 'Value'));
handles.data.quad.z    = handles.quad.z(get(handles.popupmenu_quad, 'Value'));
handles.data.quad.nstep= str2double(get(handles.edit_quad_nstep, 'String'));
handles.data.quad.min  = str2double(get(handles.edit_quad_low, 'String'));
handles.data.quad.max  = str2double(get(handles.edit_quad_high, 'String'));
handles.data.quad.lgps = get(handles.text_quad_lgps, 'String');
handles.data.quad.range= linspace(handles.data.quad.min, handles.data.quad.max, handles.data.quad.nstep);

% get corrector scan parameters from the GUI
switch handles.plane
    case 'x'
        corrs = handles.xcor;
    case 'y'
        corrs = handles.ycor;
end
handles.data.corr.name = corrs.name(get(handles.popupmenu_corr, 'Value'));
handles.data.corr.z    = corrs.z(get(handles.popupmenu_corr, 'Value'));
handles.data.corr.nstep= str2double(get(handles.edit_corr_nstep, 'String'));
handles.data.corr.min  = str2double(get(handles.edit_corr_low, 'String'));
handles.data.corr.max  = str2double(get(handles.edit_corr_high, 'String'));

% construct an optimized corrector range - fix this
range = linspace(handles.data.corr.min, handles.data.corr.max, handles.data.corr.nstep);
handles.data.corr.range = range;

% get starting BDES/BACT values
[handles.data.quad.bact0, handles.data.quad.bdes0] = control_magnetGet(handles.data.quad.lgps);
[handles.data.corr.bact0, handles.data.corr.bdes0] = control_magnetGet(handles.data.corr.name);

% make some empty data arrays
ii = handles.data.quad.nstep;
jj = handles.data.corr.nstep;
kk = numel(handles.data.bpms.name);
ll = handles.data.bpm.nsamp;

handles.data.corr.bact      = nan(ii, jj);
handles.data.quad.bact      = nan(ii, jj);
handles.data.bpms.x         = nan(ii, jj, kk, ll);
handles.data.bpms.y         = nan(ii, jj, kk, ll);
handles.data.bpms.tmit      = nan(ii, jj, kk, ll);
handles.data.bpms.pulseid   = nan(ii, jj, kk, ll);
handles.data.bpms.stat      = nan(ii, jj, kk, ll);

% scan starts here
quad = handles.data.quad;
corr = handles.data.corr;

ix = 1; jx = 1;
abort = 0;

names = handles.bpms.name;
edef = 0;

switch handles.accelerator
    case 'LCLS'
        rate = lcaGetSmart('EVNT:SYS0:1:LCLSBEAMRATE');
        try
            % setup an EDEF
            edef = eDefReserve('bowtie_gui');
            eDefParams(edef, 1, handles.data.bpm.nsamp, {''},{''},{''},{''});
        catch
            abort = 1;
            gui_statusDisp(handles, 'Failed to reserve EDEF, aborting');
        end
    case 'FACET'
        rate = lcaGetSmart('EVNT:SYS1:1:BEAMRATE');
        [m, p, u] = model_nameSplit(handles.bpms.name);
        names = strcat(p,':',m,':',u);
    otherwise
        rate = 1;
end

if ~abort
    nsamp = handles.data.bpm.nsamp;
    for ix = 1:numel(quad.range)

        if get(handles.togglebutton_abort, 'Value'), abort = 1; break; end
        % set quad
        gui_statusDisp(handles, sprintf('Setting %s to %.6f', char(quad.name), quad.range(ix)));
        setQuad(handles, quad.name, quad.range(ix));

        for jx = 1:numel(corr.range)

            if get(handles.togglebutton_abort, 'Value'), abort = 1; break; end

            % set corrector
            gui_statusDisp(handles, sprintf('Setting %s to %.6f', char(corr.name), corr.range(jx)));
            b = corr.range(jx);
            setCorr(handles, char(corr.name), b, 'action', 'PERTURB');
            handles.data.corr.bact(ix, jx) = control_magnetGet(corr.name);
            handles.data.quad.bact(ix, jx) = control_magnetGet(quad.name);

            % get BPM data
            if strcmp(handles.accelerator, 'FACET')
                gui_statusDisp(handles, sprintf('Acquiring %d samples on %s', handles.data.bpm.nsamp, char(handles.dgrp)));
                [handles.data.bpms.x(ix, jx, :, :), ...
                    handles.data.bpms.y(ix, jx, :, :), ...
                    handles.data.bpms.tmit(ix, jx, :, :), ...
                    handles.data.bpms.pulseid(ix, jx, :, :), ...
                    handles.data.bpms.stat(ix, jx, :, :)] = ...
                    control_bpmAidaGet(names, handles.data.bpm.nsamp, handles.dgrp);
            else
                gui_statusDisp(handles, sprintf('Acquiring %d samples', nsamp));
                timeout = 5 * nsamp / rate;
                eDefAcq(edef, timeout);
                pvlist=[strcat(names,':X') strcat(names,':Y') strcat(names,':TMIT')]';
                pvlist = reshape(pvlist, [], 1);
                pvlist = strcat(pvlist, {'HST'}, int2str(edef));
                pvdata = lcaGetSmart(pvlist,nsamp,'double');
                pvdata=reshape(pvdata,3,[],nsamp);
                handles.data.bpms.x(ix,jx,:,:) = squeeze(pvdata(1,:,:));
                handles.data.bpms.y(ix,jx,:,:) = squeeze(pvdata(2,:,:));
                handles.data.bpms.tmit(ix,jx,:,:) = squeeze(pvdata(3,:,:));

            end

            % % fake data for debug with no rate
            %             [handles.data.bpms.x(ix, jx, :, :), ...
            %             handles.data.bpms.y(ix, jx, :, :), ...
            %             handles.data.bpms.tmit(ix, jx, :, :), ...
            %             handles.data.bpms.pulseid(ix, jx, :, :), ...
            %             handles.data.bpms.stat(ix, jx, :, :)] = ...
            %             deal(randn(numel(names), handles.data.bpm.nsamp));

            handles.data.points = (ix-1) * numel(quad.range) + jx;
            % plot data as scan runs
            handles = fit_and_plot(handles);
        end
        if get(handles.togglebutton_abort, 'Value'), abort = 1; break; end
    end
    gui_statusDisp(handles, 'Restoring initial magnets...');
    setCorr(handles, char(corr.name),corr.bdes0, 'action', 'TRIM');
    setQuad(handles, quad.name, quad.bdes0);
    handles.data.tsend = now;

    eDefRelease(edef);

    if abort
        gui_statusDisp(handles, 'Scan aborted.');
    else
        gui_statusDisp(handles, 'Scan complete.');
        if handles.data.fitok
            set(handles.pushbutton_apply, 'Color', 'green');
        end
    end

end

if abort
    set(handles.togglebutton_abort, 'Value', 0);
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
end

set(hObject, 'String', buttontext);
set(hObject, 'Enable', 'on');

guidata(hObject, handles);

function handles = fit_and_plot2(handles)

quad = handles.data.quad;
corr = handles.data.corr;
bpms = handles.data.bpms;
plane = handles.data.plane;

itar = handles.data.bpm.index;
ibpm = get(handles.listbox_bpms, 'Value');

rmat = model_rMatGet(quad.name, bpms.name(ibpm), {'TYPE=DESIGN', 'BEAMPATH=' handles.beamPath}, 'RMAT');

figure;  hold all;

for ix=1:size(quad.bact,1)
    for jx = 1:size(corr.bact, 2)
        stem(bpms.z(ibpm), squeeze(bpms.x(1,1,ibpm,:)));
    end
end


function handles = fit_and_plot(handles, do_print)

if nargin < 2, do_print = 0; end

% make a new figure for printing output, otherwise print in GUI
if do_print
    handles.export = figure;
    ax = axes;
else
    ax = handles.axes1;
end
axes(ax);

quad = handles.data.quad;
corr = handles.data.corr;
bpms = handles.data.bpms;
plane = handles.data.plane;

itar = handles.data.bpm.index;
ibpm = get(handles.listbox_bpms, 'Value');

sym = {'*' 's'};
lin = {'-' '--'};
cmap = colormap('Lines');

% fit each quad step to a line for every BPM
for ix = 1:numel(ibpm)
    for jx = 1:size(quad.bact, 1)
        tfit = squeeze(bpms.(plane)(jx, :, itar, :));
        pfit = squeeze(bpms.(plane)(jx, :, ibpm(ix), :));
        xFits(ix,jx,:) = linspace(min(min(tfit)), max(max(tfit)), 100);
        if all(all(isnan(tfit))) || all(all(isnan(pfit)))
            [yFits(ix,jx,:) yFitStds(ix,jx,:)] = deal(nan(size(xFits(ix,jx,:))));
            [pars(ix,jx,:) parstds(ix,jx,:)] = deal(nan([1 2]));
        else
        [pars(ix,jx,:), yFits(ix,jx,:), parstds(ix,jx,:), yFitStds(ix,jx,:)] = ...
            util_polyFit(tfit, pfit, 1, [], xFits(ix,jx,:));
        end
    end
end

% find the line intersections for every BPM
for ix = 1:numel(ibpm)
    a = pars(ix,1,2)- pars(ix,2,2);
    b = pars(ix,2,1)- pars(ix,1,1);
    astd = sqrt(parstds(ix,1,2)^2 + parstds(ix,2,2)^2);
    bstd = sqrt(parstds(ix,2,1)^2 + parstds(ix,1,1)^2);
    offset(ix) = a / b;
    yoffset(ix) = pars(ix,1,1) * offset(ix) + pars(ix,1,2);
    offsetstd(ix) = offset(ix) * sqrt((astd/a)^2 + (bstd/b)^2);
end

if ax == handles.axes1
    if ~(gca == handles.axes1), axes(handles.axes1); end
    cla reset;  hold all;

    for ix = 1:numel(ibpm)
        for jx = 1:size(quad.bact, 1)
            for kx = 1:size(corr.bact, 2)
                tdata = squeeze(bpms.(plane)(jx, kx, itar, :));
                pdata = squeeze(bpms.(plane)(jx,kx,ibpm(ix),:));
                plot(tdata, pdata, sym{jx}, 'Color', cmap(ix,:));
            end
            plot(squeeze(xFits(ix,jx,:)), ...
                squeeze(yFits(ix,jx,:)), lin{jx}, 'Color', cmap(ix,:));
        end
    end
    xlabel(handles.data.bpm.name);
    title(sprintf('BBA offset %s %s', upper(plane), datestr(handles.data.ts)));
    %legend(bpms.name(ibpm), 'Location', 'NorthOutside', 'Orientation', 'horizontal');
    for ix = 1:numel(ibpm)
            vl(offset(ix), '-', 'Color', cmap(ix,:));
            %     vl(offset(ix)+offsetstd(ix), '--', 'Color', cmap(ix,:));
            %     vl(offset(ix)-offsetstd(ix), '--', 'Color', cmap(ix,:));
    end
else

    subplot(2,1,1);
    cla reset; hold all;
    for ix = 1:numel(ibpm)
        for jx = 1:size(quad.bact, 1)
            for kx = 1:size(corr.bact, 2)
                tdata = squeeze(bpms.(plane)(jx, kx, itar, :));
                pdata = squeeze(bpms.(plane)(jx,kx,ibpm(ix),:));
                plot(tdata, pdata - yoffset(ix), sym{jx}, 'Color', cmap(ix,:));
            end
            plot(squeeze(xFits(ix,jx,:)), ...
                squeeze(yFits(ix,jx,:))-yoffset(ix), lin{jx}, 'Color', cmap(ix,:));
        end
    end
    axis tight;
    title(sprintf('BBA offset %s %s', upper(plane), datestr(handles.data.ts)));
    xlabel(handles.data.bpm.name);

    if numel(offset) < 1, return; end

    [par, yFit, parstd, yFitStd] = ...
        util_polyFit(1:numel(offset), offset, 0, offsetstd, linspace(1,numel(offset), 100));
    vl(par, '-', 'Color', 'black');
    vl(par+parstd, '--', 'Color', 'black');
    vl(par-parstd, '--', 'Color', 'black');
    switch plane
        case 'x'
            offsi = 1;
        case 'y'
            offsi = 2;
    end

    subplot(2,1,2);
    cla reset; hold all;
    for ix = 1:numel(offset)
        h = errorbar(ix, offset(ix), offsetstd(ix), 'o');
        set(h, 'Color', cmap(ix,:));
    end
    hor_line(par, 'k-');
    hor_line(par+parstd, 'k--');
    hor_line(par-parstd, 'k--');
    axis tight;

    handles.data.offset = offset;
    handles.data.offsetstd = offsetstd;
    offs = handles.data.bpm.offset(offsi);
    handles.data.meas = par;
    handles.data.measstd = parstd;
    handles.data.oldoffs = offs;
    if(strcmp(handles.accelerator, 'LCLS'))
        handles.data.newoffs = offs - par;
        title(sprintf('OFFS old %.4f, new %.4f, delta %.4f \\pm %.4f', offs, offs - par, par, parstd));
    else
        handles.data.newoffs = offs + par;
        title(sprintf('OFFS old %.4f, new %.4f, delta %.4f \\pm %.4f', offs, offs + par, par, parstd));
    end
    xlabel('BPM Number');
    ylabel(sprintf('%s Offset [mm]', upper(plane)));

    handles.data.fitok = ~isnan(handles.data.newoffs);

end





function vl(x, varargin)

hold_state = get(gca,'NextPlot');  % get present hold state
YLim = get(gca,'YLim');            % get present axis limits
hold on                            % hold current plot
plot(x*ones(size(YLim)),YLim,varargin{:})  % draw line
hold off                           % remove hold
set(gca,'NextPlot',hold_state);    % restore original hold state


function bact = setQuad(handles, name, bdes)

% LCLS stuff just works
if strcmp(handles.accelerator, 'LCLS')
% DEBUG
    bact = control_magnetSet(name, bdes);
return; end

% LI20 LGPS stuff works (I think)
[m, p, u] = model_nameSplit(name);
if strcmp(m, 'LI20')
% DEBUG
    bact = control_magnetSet(name, bdes);
return; end

% FACET linac bulk-boost quads need the whole sector trimmed
sectorquads = model_nameRegion(p, m);
qindex = strcmpi(name, sectorquads);
[sbact, sbdes] = control_magnetGet(sectorquads);
sbdes(qindex) = bdes;
% DEBUG
%sbact = control_magnetSet(sectorquads, sbdes, 'wait', 0.1);
if any(((sbact - sbdes)./sbdes) > 0.01)
    gui_statusDisp(handles, 'Warning:  some quads are OUT-RANGE!');
end
bact = sbact(qindex);




function bact = setCorr(handles, name, bdes, varargin)

% LCLS stuff just works
if strcmp(handles.accelerator, 'LCLS')
% DEBUG
         %bact = control_magnetSet(name, bdes, varargin);
         bact = control_magnetSet(name, bdes);

return; end

% If not LCLS use AIDA perturb
global corRequestBuilder;
if isempty(corRequestBuilder),
    corRequestBuilder = pvaRequest('MAGNETSET:BDES');
end
name = model_nameConvert(name, 'SLC');

inData = AidaPvaStruct();
inData.put("names", { name });
inData.put("values", { bdes });

corRequestBuilder.with('MAGFUNC', 'PTRB');
corRequestBuilder.with('LIMITCHECK','SOME');

% DEBUG
%outData = corRequestBuilder.set(inData);


function togglebutton_abort_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(hObject, 'String', 'Aborting...');
else
    set(hObject, 'String', 'Abort');
end
guidata(hObject, handles);


function handles = pushbutton_save_Callback(hObject, eventdata, handles)
if handles.data.saved, return; end
[f, p] = util_dataSave(handles.data, 'bowtie_gui', handles.data.bpm.name, handles.data.ts);
gui_statusDisp(handles, sprintf('Data saved to %s %s', p, f));
handles.data.saved = 1;
guidata(hObject, handles);


function pushbutton_load_Callback(hObject, eventdata, handles)
[handles.data, f, p] = util_dataLoad();
gui_statusDisp(handles, sprintf('Data loaded from %s', f));
guidata(hObject, handles);


function pushbutton_configsave_Callback(hObject, eventdata, handles)


function pushbutton_configload_Callback(hObject, eventdata, handles)


function handles = popupmenu_bpms_Callback(hObject, eventdata, handles)

% populate analysis listbox with downstream BPMS
N = 12;

sel = get(hObject, 'Value');
str = get(hObject, 'String');
n = numel(str);
dsidx = sel+1:1:sel+N+1;
listidx = intersect(dsidx, 1:n);

set(handles.listbox_bpms, 'Value', listidx);
set(handles.listbox_bpms, 'ListboxTop', listidx(1)-1);

handles = auto_setup(handles);
guidata(hObject, handles);


function popupmenu_bpms_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = popupmenu_quad_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');
sel = get(hObject, 'Value');
selstr = str{sel};

lgps = control_magnetNameLGPS(selstr);
if isempty(lgps)
    name = selstr;
else
    name = lgps;
end
set(handles.text_quad_lgps, 'String', name);

[bact, bdes, bmax, edes] = control_magnetGet(name);
stat = control_deviceGet(name, 'STAT');

green = bitget(stat, 1);
red = bitget(stat, 4);

if red && ~green
    set(handles.text_quad_bact, 'ForegroundColor', [1 0 0]);
else
    set(handles.text_quad_bact, 'ForegroundColor', [0 0.7 0]);
end

set(handles.text_quad_bdes, 'String', sprintf('%0.4f', bdes));
set(handles.text_quad_bact, 'String', sprintf('%0.4f', bact));

% auto range the selected quad
handles = auto_quad_range(handles);

guidata(hObject, handles);


function popupmenu_quad_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = popupmenu_corr_Callback(hObject, eventdata, handles)

str = get(hObject, 'String');
sel = get(hObject, 'Value');
selstr = str{sel};

[bact, bdes, bmax, edes] = control_magnetGet(selstr);
stat = control_deviceGet(selstr, 'STAT');

green = bitget(stat, 1);
red = bitget(stat, 4);

if red && ~green
    set(handles.text_corr_bact, 'ForegroundColor', [1 0 0]);
else
    set(handles.text_corr_bact, 'ForegroundColor', [0 0.7 0]);
end

set(handles.text_corr_bdes, 'String', sprintf('%0.6f', bdes));
set(handles.text_corr_bact, 'String', sprintf('%0.6f', bact));

% auto range the selected corr
handles = auto_corr_range(handles);

guidata(hObject, handles);

function popupmenu_corr_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = gui_plane(handles)
rx = get(handles.radiobutton_x, 'Value');
ry = get(handles.radiobutton_y, 'Value');

if rx && ~ry
    handles.plane = 'x';
    set(handles.text_sel_corr, 'String', 'Select XCOR:');
    set(handles.popupmenu_corr, 'String', handles.xcor.name);
elseif ry && ~rx
    handles.plane = 'y';
    set(handles.text_sel_corr, 'String', 'Select YCOR:');
    set(handles.popupmenu_corr, 'String', handles.ycor.name);
else
    handles.plane = '';
end
drawnow;
% handles = auto_setup(handles);

function radiobutton_x_Callback(hObject, eventdata, handles)
set(hObject, 'Value', 1);
set(handles.radiobutton_y, 'Value', 0);
handles = gui_plane(handles);
handles = auto_setup(handles);
guidata(hObject, handles);

function radiobutton_y_Callback(hObject, eventdata, handles)
set(hObject, 'Value', 1);
set(handles.radiobutton_x, 'Value', 0);
handles = gui_plane(handles);
handles = auto_setup(handles);
guidata(hObject, handles);


function checkbox_auto_quad_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles = auto_quad_sel(handles);
    if get(handles.checkbox_auto_qrange, 'Value')
        handles = auto_quad_range(handles);
    end
end
guidata(hObject, handles);

function checkbox_auto_corr_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles = auto_corr_sel(handles);
    if get(handles.checkbox_auto_crange, 'Value')
        handles = auto_corr_range(handles);
    end
end
guidata(hObject, handles);


function edit_quad_nstep_Callback(hObject, eventdata, handles)


function edit_quad_nstep_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_quad_low_Callback(hObject, eventdata, handles)


function edit_quad_low_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_quad_high_Callback(hObject, eventdata, handles)


function edit_quad_high_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_auto_qrange_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles = auto_quad_range(handles);
end
guidata(hObject, handles);

function edit_corr_nstep_Callback(hObject, eventdata, handles)


function edit_corr_nstep_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_corr_low_Callback(hObject, eventdata, handles)


function edit_corr_low_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_corr_high_Callback(hObject, eventdata, handles)


function edit_corr_high_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_auto_crange_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    handles = auto_corr_range(handles);
end
guidata(hObject, handles);

function listbox_bpms_Callback(hObject, eventdata, handles)
if ~isfield(handles, 'data'), return, end
handles = fit_and_plot(handles);
guidata(hObject, handles);


function listbox_bpms_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_quad_frac_Callback(hObject, eventdata, handles)
if get(handles.checkbox_auto_qrange, 'Value')
    handles = auto_quad_range(handles);
end
guidata(hObject, handles);

function edit_quad_frac_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_corr_ampl_Callback(hObject, eventdata, handles)
if get(handles.checkbox_auto_crange, 'Value')
    handles = auto_corr_range(handles);
end
guidata(hObject, handles);

function edit_corr_ampl_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_nsamp_Callback(hObject, eventdata, handles)


function edit_nsamp_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = pushbutton_print_Callback(hObject, eventdata, handles)

handles = fit_and_plot(handles, 1);
switch handles.data.plane
    case 'x'
        offsi = 1;
    case 'y'
        offsi = 2;
end
elapsed = etime(datevec(handles.data.tsend), datevec(handles.data.ts));
quadstr = sprintf('Quad scanned: %s BDES = [%.6f %.6f]\n', ...
    char(handles.data.quad.name), handles.data.quad.range(1), handles.data.quad.range(end));
corstr = sprintf('Corrector scanned: %s BDES = [%.6f %.6f]\n', ...
    char(handles.data.corr.name), handles.data.corr.range(1,1), handles.data.corr.range(1,end));
timestr = sprintf('Elapsed time: %.2f minutes\n', elapsed / 60);
offstr = sprintf('Measured offset: %.4f +/- %.4f mm\n', handles.data.meas, handles.data.measstd);
dbstr = sprintf('OFFS (old): %.4f, OFFS (new): %.4f', ...
    handles.data.bpm.offset(offsi), handles.data.bpm.offset(offsi) + handles.data.meas);
textstr = [timestr corstr quadstr offstr dbstr];
util_printLog(handles.export, 'author', 'bowtie_gui', 'text', textstr, 'title', sprintf('Bowtie BBA %s %s', ...
   char(handles.data.bpm.name), upper(char(handles.data.plane))));
handles = pushbutton_save_Callback(handles.pushbutton_save, [], handles);
guidata(hObject, handles);


function modelSource_btn_Callback(hObject, eventdata, handles)

val=gui_modelSourceControl(hObject,handles,[]);
gui_modelSourceControl(hObject,handles,mod(val,3)+1);


% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.accelerator, 'FACET')
    gui_statusDisp(handles, 'Offset correction for SLC BPMs requires a DBEDIT!  Sorry...');
    return;
end

if ~handles.data.fitok
    gui_statusDisp(handles, 'No valid offset fit found!  Exiting...');
    return;
else
    switch handles.data.plane
        case 'x'
            offsi = 1;
        case 'y'
            offsi = 2;
    end

    offspv = strcat(handles.data.bpm.name, ':', upper(handles.data.plane), 'AOFF');

    qans = questdlg(sprintf('This will change %s from %.3f to %.3f.  Are you sure?', ...
        offspv, handles.data.oldoffs, handles.data.newoffs));
    if strcmp(qans, 'Yes')

        lcaPutSmart(offspv, handles.data.newoffs);

        gui_statusDisp(handles, sprintf('Changed %s from %.3f to %.3f.', ...
        offspv, handles.data.oldoffs, handles.data.newoffs));

        handles = pushbutton_print_Callback(handles.pushbutton_save, [], handles);
    end
end

guidata(hObject, handles);
function modelSource_btn_CreateFcn(hObject, eventdata, handles)
a = 1;


% --- Executes on button press in beamPath_btn.
function beamPath_btn_Callback(hObject, eventdata, handles)
% hObject    handle to beamPath_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=gui_beamPathControl(hObject,handles,[]);
gui_beamPathControl(hObject,handles,mod(val,2)+1);
bowtie_gui_OutputFcn(hObject, eventdata, handles) ;
