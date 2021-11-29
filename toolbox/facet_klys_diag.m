function varargout = facet_klys_diag(varargin)
% FACET_KLYS_DIAG MATLAB code for facet_klys_diag.fig
%      FACET_KLYS_DIAG, by itself, creates a new FACET_KLYS_DIAG or raises the existing
%      singleton*.
%
%      H = FACET_KLYS_DIAG returns the handle to a new FACET_KLYS_DIAG or the handle to
%      the existing singleton*.
%
%      FACET_KLYS_DIAG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_KLYS_DIAG.M with the given input arguments.
%
%      FACET_KLYS_DIAG('Property','Value',...) creates a new FACET_KLYS_DIAG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_klys_diag_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_klys_diag_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_klys_diag

% Last Modified by GUIDE v2.5 27-Oct-2014 17:41:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_klys_diag_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_klys_diag_OutputFcn, ...
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


% --- Executes just before facet_klys_diag is made visible.
function facet_klys_diag_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_klys_diag (see VARARGIN)

% Choose default command line output for facet_klys_diag
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes facet_klys_diag wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = facet_klys_diag_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% load GUI and set defaults
gui_statusDisp(handles, 'Loading...');  drawnow;
handles.modelsource = model_init();
gui_modelSourceControl(handles.modelSource_btn, handles, handles.modelsource);

% default scan ranges
set(handles.edit_min,   'String', sprintf('%d', -175));
set(handles.edit_max,   'String', sprintf('%d', +175));
set(handles.edit_nstep, 'String', sprintf('%d', 31));
set(handles.edit_nsamp, 'String', sprintf('%d', 20));

% setup klys list
gui_statusDisp(handles, 'Building KLYS list...'); drawnow;
handles.config.sectors = 2:19;
handles.config.micros = cellstr(strcat('LI', num2str(handles.config.sectors', '%02d')));
handles.config.klys.name = model_nameRegion('KLYS', handles.config.micros);
handles.config.klys.z = control_deviceGet(handles.config.klys.name, 'Z');
set(handles.popupmenu_klys, 'String', handles.config.klys.name);
drawnow;

% setup bpm list
gui_statusDisp(handles, 'Building BPMS list...'); drawnow;
linacbpms = model_nameRegion('BPMS', handles.config.micros);
idelete = strcmpi(linacbpms, 'LI19:BPMS:801') | strcmpi(linacbpms, 'LI19:BPMS:901');
linacbpms(idelete) = [];
handles.config.bpms.name = [linacbpms; 'EP01:BPMS:185'];
handles.config.bpms.z = control_deviceGet(handles.config.bpms.name, 'Z');
handles.config.bpms.isE = ...
    strcmpi(handles.config.bpms.name, 'LI10:BPMS:3448') | ...
    strcmpi(handles.config.bpms.name, 'EP01:BPMS:185');
handles.config.bpmd.name = {'SCAVSPPS'};
handles.config.bpmd.ratepv = {'EVNT:SYS1:1:SCAVRATE'};
handles.config.bpmd.bc = 10;
set(handles.popupmenu_bpmd, 'String', handles.config.bpmd.name);
drawnow;

% map klys to energy BPM - hard code for now
handles.config.klys.iE = zeros(size(handles.config.klys.name));
handles.config.klys.iE(1:72) = find(strcmpi('LI10:BPMS:3448', handles.config.bpms.name));
handles.config.klys.iE(73:145) = find(strcmpi('EP01:BPMS:185', handles.config.bpms.name));

gui_statusDisp(handles, 'Getting status...'); drawnow;
handles = update_gui(handles);

guidata(hObject, handles);

function handles = klys_status(handles)
% updates GUI KLYS status box
sel = get(handles.popupmenu_klys, 'Value');
str = get(handles.popupmenu_klys, 'String');
klys = str{sel};
handles.klys = klys;

[act, stat, swrd] = control_klysStatGet(klys, handles.bc);

if any(isnan([act, stat, swrd]))
    set(handles.pushbutton_status, 'String', '????');
    set(handles.pushbutton_status, 'ForegroundColor', 'red');
    return
end

if bitget(act, 1)
    set(handles.pushbutton_status, 'String', 'ACTIVE');
    set(handles.pushbutton_status, 'ForegroundColor', 'green');
    set(handles.pushbutton_status, 'Value', 1);
    set(handles.pushbutton_status, 'Enable', 'on');
elseif bitget(act, 2)
    set(handles.pushbutton_status, 'String', 'DEACT');
    set(handles.pushbutton_status, 'Value', 0);
    set(handles.pushbutton_status, 'ForegroundColor', 'red');
    set(handles.pushbutton_status, 'Enable', 'on');
elseif bitget(act, 3)
    set(handles.pushbutton_status, 'String', 'OFF/MNT');
    set(handles.pushbutton_status, 'Value', 0);
    set(handles.pushbutton_status, 'ForegroundColor', 'cyan');
    %set(handles.pushbutton_status, 'Enable', 'off');
end
drawnow;

function handles = bpmd_rate(handles)
sel = get(handles.popupmenu_bpmd, 'Value');
str = get(handles.popupmenu_bpmd, 'String');
bpmd = str{sel};
handles.bpmd = bpmd;

ratepv = handles.config.bpmd.ratepv(sel);
handles.rate = lcaGetSmart(ratepv);
set(handles.text_rate, 'String', sprintf('%d Hz', handles.rate));
handles.bc = handles.config.bpmd.bc(sel);
drawnow;


function handles = update_gui(handles)
handles = bpmd_rate(handles);
handles = klys_status(handles);

handles.min = str2double(get(handles.edit_min, 'String'));
handles.max = str2double(get(handles.edit_max, 'String'));
handles.nstep = str2int(get(handles.edit_nstep, 'String'));
handles.nsamp = str2int(get(handles.edit_nsamp, 'String'));

gui_statusDisp(handles, sprintf(...
    'Selected: %s on %s, %+.0f to %+.0f in %d steps, %d pulses/step', ...
    handles.klys, handles.bpmd, handles.min, handles.max, handles.nstep, handles.nsamp));
drawnow;


function popupmenu_klys_Callback(hObject, eventdata, handles)
handles = update_gui(handles);
guidata(hObject, handles);

function popupmenu_klys_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_bpmd_Callback(hObject, eventdata, handles)
handles = update_gui(handles);
guidata(hObject, handles);

function popupmenu_bpmd_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_start_Callback(hObject, eventdata, handles)

handles.data = [];

% store GUI scan information
handles.data.tstart = now;  tic;
handles.data.config = handles.config;
handles.data.modelsource = handles.modelsource;

handles.data.klys = handles.klys;
handles.data.bpmd = handles.bpmd;
handles.data.min = handles.min;
handles.data.max = handles.max;
handles.data.nstep = handles.nstep;
handles.data.nsamp = handles.nsamp;
handles.data.bc = handles.bc;
handles.data.rate = handles.rate;

if get(handles.togglebutton_abort, 'Value')
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
    return;
end

% get KLYS database stuff and store
klys = handles.data.klys;
gui_statusDisp(handles, sprintf('Getting database for %s...', klys));

[act, stat, swrd, hdsc, dsta, enld] = control_klysStatGet(klys, handles.data.bc);
handles.data.act = act;
handles.data.stat = stat;
handles.data.swrd = swrd;
handles.data.hdsc = hdsc;
handles.data.dsta = dsta;
handles.data.enld = enld;

[pact, pdes, aact, ades, kphr, gold] = control_phaseGet(klys);
handles.data.pact = pact;
handles.data.pdes = pdes;
handles.data.aact = aact;
handles.data.ades = ades;
handles.data.kphr = kphr;
handles.data.gold = gold;

handles.data.leff = control_deviceGet(klys, 'L');
handles.data.ecvt = control_deviceGet(klys, 'ECVT');
handles.data.pcvt = control_deviceGet(klys, 'PCVT');

% find klys list
ik = find(strcmpi(klys, handles.config.klys.name));
kz = handles.config.klys.z(ik);
handles.data.ik = ik;
handles.data.kz = kz;

% find nearest BPMS in list
bpms = handles.config.bpms.name;
handles.data.bpms.name = bpms;
[~, ikb] = min(abs(repmat(kz, [numel(bpms) 1]) - handles.config.bpms.z));
kbpms = bpms(ikb);
handles.data.ikb = ikb;
handles.data.kbpms = kbpms;

% save energy BPMS TODO fix this
handles.data.iEb = handles.config.klys.iE(ik);
iEb = handles.data.iEb;

if get(handles.togglebutton_abort, 'Value')
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
    return;
end

% get BPMS RMATs
gui_statusDisp(handles, 'Getting model for BPMS...');
switch model_init
    case 'MATLAB'
        flag = {'TYPE=DESIGN'};
    case 'SCP'
        flag = {'TYPE=DATABASE'};
    otherwise
        flag= '';
end

handles.data.bpms.twiss = model_rMatGet(bpms, [], flag, 'twiss');
handles.data.bpms.rmat = model_rMatGet(kbpms, bpms, flag);

% setup scan range
handles.data.range = linspace(handles.data.min, handles.data.max, handles.nstep);
range = handles.data.range;
nstep = handles.data.nstep;
nsamp = handles.data.nsamp;
bpmd = handles.data.bpmd;

gui_statusDisp(handles, sprintf('Scan setup took %.2f seconds.', toc));

if get(handles.togglebutton_abort, 'Value')
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
    return;
end

% check feedback state

fbroots = {...
    'LI03:FBCK:20';
    'LI04:FBCK:22';
    'LI06:FBCK:24';
    'LI09:FBCK:201';
    };

hsta_f = [...
   293832865;
   327846049;
   277055649;
   268470433;
   ];

fbhsta = control_deviceGet(fbroots, 'HSTA');

if any(fbhsta == hsta_f)
    response = questdlg('WARNING:  Some linac feedbacks are on.  Continue anyway?');
    if ~strcmpi(response, 'Yes')
        gui_statusDisp(handles, 'Scan aborted');
        return
    end
end


% get a reference orbit
gui_statusDisp(handles, sprintf('Acquiring ref orbit %d samples on %s...', ...
        nsamp, bpmd));
[x, y, tmit, pid, s] = control_bpmAidaGet(bpms, nsamp, handles.data.bpmd);
handles.data.ref.x = x;
handles.data.ref.y = y;
handles.data.ref.tmit = tmit;
handles.data.ref.pid = pid;
handles.data.ref.s = s;

handles.data.ref.xmean = mean(handles.data.ref.x, 2);
handles.data.ref.ymean = mean(handles.data.ref.y, 2);
handles.data.ref.xstd = std(handles.data.ref.x, [], 2);
handles.data.ref.ystd = std(handles.data.ref.y, [], 2);

handles = plot_orbit(handles, 0);

if get(handles.togglebutton_abort, 'Value')
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
    return;
end

% main scan loop
gui_statusDisp(handles, sprintf('Starting scan of %s...', klys));
for ix = 1:nstep
    
    if get(handles.togglebutton_abort, 'Value')
        togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
        break;
    end
    
    % set klys phase
    gui_statusDisp(handles, sprintf('[%d / %d] Setting %s PDES to %+.0f', ...
        ix, nstep, klys, range(ix)));
    pause(2);
    %handles.data.pact(ix) = range(ix);
    handles.data.phase(ix) = control_phaseSet(klys, range(ix));
    
    if get(handles.togglebutton_abort, 'Value')
        togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
        break;
    end
    
    % read BPM data
    gui_statusDisp(handles, sprintf('[%d / %d] Acquiring %d samples on %s...', ...
        ix, nstep, nsamp, bpmd));
    [x, y, tmit, pid, s] = control_bpmAidaGet(bpms, nsamp, handles.data.bpmd);
    
    % store BPM data
    handles.data.x(ix,:,:) = x;
    handles.data.y(ix,:,:) = y;
    handles.data.tmit(ix,:,:) = tmit;
    handles.data.pid(ix,:,:) = pid;
    handles.data.s(ix,:,:) = s;
    
    handles.data.xmean(ix,:) = mean(x,2);
    handles.data.ymean(ix,:) = mean(y,2);
    handles.data.xstd(ix,:) = std(x,[],2);
    handles.data.ystd(ix,:) = std(y,[],2);    
    
    % plot BPM data
    handles = plot_orbit(handles, ix);
    handles = orbit_fit(handles, ix);
    handles = plot_energy(handles);
    handles = plot_rfkick(handles);
    
end

% restore phase shifter
gui_statusDisp(handles, sprintf('Restoring %s to initial phase of %+.2f', ...
    klys, handles.data.pdes));
pact_end = control_phaseSet(klys, handles.data.pdes);

if abs(handles.data.pact - pact_end) > 5
    warndlg(sprintf('Warning:  PHAS at start was %+.2f, after restore is %+.2f', ...
        handles.data.pact, pact_end));
end


if get(handles.togglebutton_abort, 'Value')
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
    gui_statusDisp(handles, 'Scan Aborted.');
    return;
else
    gui_statusDisp(handles, sprintf('Scan of %s complete, elapsed time %.2f.', klys, toc));
    [fileName, pathName] = util_dataSave(handles.data, ...
        'facet_klys_diag', klys, handles.data.tstart);
    gui_statusDisp(handles, sprintf('Data saved to %s %s', pathName, fileName));
    
    guidata(hObject, handles);
end

function handles = plot_orbit(handles, ix)

bpmz = handles.data.config.bpms.z;
kz = handles.data.kz;
ez = bpmz(handles.data.iEb);

axes(handles.axes_orbit);
cla;  hold all;

xref = mean(handles.data.ref.x, 2);
yref = mean(handles.data.ref.y, 2 );
xrefStd = std(handles.data.ref.y, [], 2 );
yrefStd = std(handles.data.ref.y, [], 2 );

if ix == 0 % plot ref orbit
    x = handles.data.ref.x;
    y = handles.data.ref.y;
    stem(bpmz, xref, 'b.');
    stem(bpmz, yref, 'k.'); 
    title('Reference Orbit');
else % plot diff to ref
    xdiff = mean(squeeze(handles.data.x(ix,:,:)), 2) - xref;    
    ydiff = mean(squeeze(handles.data.y(ix,:,:)), 2) - yref;
    xdiffStd = std(squeeze(handles.data.y(ix,:,:)), [], 2) ;
    ydiffStd = std(squeeze(handles.data.y(ix,:,:)), [], 2);
    stem(bpmz, xdiff, 'b.');
    stem(bpmz, ydiff, 'k.'); 
    title(sprintf('Difference orbit for scan step %d', ix));
end

ylim([-1 1]);
%axis tight;
xlim([min(bpmz) max(bpmz)]);
ver_line(kz, 'g-');
ver_line(ez, 'm-');
kbpm = handles.data.config.bpms.name{handles.data.ikb};
ebpm = handles.data.config.bpms.name{handles.data.iEb};
text(kz, 0.95, strcat({' '}, kbpm), 'VerticalAlignment', 'top');
text(ez, -0.95, strcat({' '}, ebpm), 'VerticalAlignment', 'bottom');

% title(sprintf('Difference orbit for scan step %d', ix)); 
drawnow;

function handles = orbit_fit(handles, ix)
% setup RMATs
iEb = handles.data.iEb;
ikb = handles.data.ikb;
i_fit = ikb:1:iEb;

rmat = handles.data.bpms.rmat(:,:,i_fit);
R1s = squeeze(rmat(1, [1 2 3 4 6], :))';
R3s = squeeze(rmat(3, [1 2 3 4 6], :))';

Xs = handles.data.xmean(ix,i_fit);
Ys = handles.data.ymean(ix,i_fit);
dXs = handles.data.xstd(ix,i_fit);
dYs = handles.data.ystd(ix,i_fit);
Xs0 = handles.data.ref.xmean(i_fit)';
Ys0 = handles.data.ref.ymean(i_fit)';

% prevent singular matrix errors from bad bpms
dXs(dXs == 0) = inf;
dYs(dYs == 0) = inf;

[Xsf,Ysf,p,dp] = xy_traj_fit(Xs,dXs,Ys,dYs,Xs0,Ys0,R1s,R3s);

handles.data.efit.x(ix,:) = Xsf;
handles.data.efit.y(ix,:) = Ysf;
handles.data.efit.p(ix,:) = p;
handles.data.efit.dp(ix,:) = dp;

bpmz = handles.data.config.bpms.z;
axes(handles.axes_orbit);
plot(bpmz(i_fit), Xsf, 'b-');
plot(bpmz(i_fit), Ysf, 'k-');




function handles = plot_energy(handles, ax)

if nargin < 2, ax = handles.axes_energy; end

axes(ax);  
cla;  hold all;

phase = handles.data.phase;
Efrac = handles.data.efit.p(:,5);
dEfrac = handles.data.efit.dp(:,5);
iEb = handles.data.iEb;
Eref = handles.data.bpms.twiss(1,iEb);
Eerr = Efrac * Eref;
dEerr = dEfrac * Eref;

[par, parCov, parStd, fphase, fdata, fdataStd] = ...
    beamAnalysis_phaseFit(phase, Eerr, dEerr);

util_errorBand(fphase, fdata, fdataStd, 'm-');
errorbar(phase, Eerr, dEerr, 'ms');
handles.data.energy.par = par;
handles.data.energy.parStd = parStd;
ylabel('Energy from Fit [MeV]');
text(0.05, 0.95, sprintf('Energy = %.2f \\pm %.2f MeV\nENLD = %.2f MeV\nError = %.4f', ...
    par(1), parStd(1), handles.data.enld, par(1)/handles.data.enld), 'Units', 'normalized', 'VerticalAlignment', 'top');
title(sprintf('%s Energy = %.2f \\pm %.2f MeV',handles.data.klys, par(1), parStd(1)));

function handles = plot_rfkick(handles, ax_x, ax_y)

if nargin < 2
    ax_x = handles.axes_x;
    ax_y = handles.axes_y;
end


phase = handles.data.phase;
x = handles.data.efit.p(:,1);  xp = handles.data.efit.p(:,2);
y = handles.data.efit.p(:,3);  yp = handles.data.efit.p(:,4);
dx = handles.data.efit.dp(:,1);  dxp = handles.data.efit.dp(:,2);
dy = handles.data.efit.dp(:,3);  dyp = handles.data.efit.dp(:,4);

axes(ax_x);  
cla;  hold all;

[xpar, xparCov, xparStd, xfphase, xfdata, xfdataStd] = ...
    beamAnalysis_phaseFit(phase, x, dx);
util_errorBand(xfphase, xfdata, xfdataStd, 'c-');
hx = errorbar(phase, x, dx, 'c*');

[xppar, xpparCov, xpparStd, xpfphase, xpfdata, xpfdataStd] = ...
    beamAnalysis_phaseFit(phase, xp, dxp);
util_errorBand(xpfphase, xpfdata, xpfdataStd, 'b-');
hxp = errorbar(phase, xp, dxp, 'b*');

title(sprintf('X RF kick max = %.3f \\pm %.3f', xppar(1), xpparStd(1)));
legend([hx hxp], {'X pos' 'X ang'}, 'Orientation', 'Horizontal', ...
    'Location', 'Best');


axes(ax_y);  
cla;  hold all;

[ypar, yparCov, yparStd, yfphase, yfdata, yfdataStd] = ...
    beamAnalysis_phaseFit(phase, y, dy);
util_errorBand(yfphase, yfdata, yfdataStd, 'g-');
hy = errorbar(phase, y, dy, 'g*');

[yppar, ypparCov, ypparStd, ypfphase, ypfdata, ypfdataStd] = ...
    beamAnalysis_phaseFit(phase, yp, dyp);
util_errorBand(ypfphase, ypfdata, ypfdataStd, 'k-');
hyp = errorbar(phase, yp, dyp, 'k*');

title(sprintf('Y RF kick max = %.3f \\pm %.3f', yppar(1), ypparStd(1)));
legend([hy hyp], {'Y pos' 'Y ang'}, 'Orientation', 'Horizontal', ...
    'Location', 'Best');


function togglebutton_abort_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(hObject, 'String', 'Aborting...');
else
    set(hObject, 'String', 'Abort Scan');
end

function pushbutton_status_Callback(hObject, eventdata, handles)


function edit_min_Callback(hObject, eventdata, handles)
handles = update_gui(handles);
guidata(hObject, handles);

function edit_min_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_max_Callback(hObject, eventdata, handles)
handles = update_gui(handles);
guidata(hObject, handles);

function edit_max_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_nstep_Callback(hObject, eventdata, handles)
handles = update_gui(handles);
guidata(hObject, handles);

function edit_nstep_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_print_Callback(hObject, eventdata, handles)
if isfield(handles, 'data')
    f = figure;
    a_e = subplot(2,2,[1 3]);
    plot_energy(handles, a_e);
    a_x = subplot(2,2,2);
    a_y = subplot(2,2,4);
    plot_rfkick(handles, a_x, a_y);
end
util_printLog(f, 'author', 'facet_klys_diag.m');
guidata(hObject, handles);


function edit_nsamp_Callback(hObject, eventdata, handles)
handles = update_gui(handles);
guidata(hObject, handles);

function edit_nsamp_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function modelSource_btn_Callback(hObject, eventdata, handles)

val=gui_modelSourceControl(hObject,handles,[]);
gui_modelSourceControl(hObject,handles,mod(val,3)+1);


function pushbutton_load_Callback(hObject, eventdata, handles)
handles.data = util_dataLoad();
handles = plot_orbit(handles, 0);
% handles = orbit_fit(handles, ix);
handles = plot_energy(handles);
handles = plot_rfkick(handles);
guidata(hObject, handles);