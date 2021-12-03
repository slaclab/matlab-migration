function varargout = facet_phase_scans(varargin)
% FACET_PHASE_SCANS M-file for facet_phase_scans.fig
%      FACET_PHASE_SCANS, by itself, creates a new FACET_PHASE_SCANS or raises the existing
%      singleton*.
%
%      H = FACET_PHASE_SCANS returns the handle to a new FACET_PHASE_SCANS or the handle to
%      the existing singleton*.
%
%      FACET_PHASE_SCANS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_PHASE_SCANS.M with the given input arguments.
%
%      FACET_PHASE_SCANS('Property','Value',...) creates a new FACET_PHASE_SCANS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_phase_scans_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_phase_scans_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_phase_scans

% Original version by N. Lipkowitz 2012
% Update to include L2: S. Gessner March 2021
% Update to include L3: S. Gessner June 2021
% Update to include BPM 2147: S. Gessner July 2021

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_phase_scans_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_phase_scans_OutputFcn, ...
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


% --- Executes just before facet_phase_scans is made visible.
function facet_phase_scans_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_phase_scans (see VARARGIN)

% Choose default command line output for facet_phase_scans
handles.output = hObject;
handles.appName = 'facet_phase_scans';

model_init;
global modelSource;
modelSource = 'SLC';

% define available klystrons and sectors
handles.sectors = cellstr(num2str((10:19)', '%02d'));
handles.klystrons = ['S'; cellstr(num2str((1:8)'))];
handles.ns = numel(handles.sectors);
handles.nk = numel(handles.klystrons);

% define some regions
%handles.regions     = { 'LI00-DR11' 'DR13-LI10' 'LI11-LI20'}';
handles.regions     = { 'L0' 'L1' 'L2' 'L3'}';
% L0 is IN10:       10-2 (GUN), 10-3, 10-4, 10-5 (TCAV)
% L1 is LI11:       11-1, 11-2
% L2 is LI11-LI14:  11-4, 11-5 . . 14-6, 14-7 (e+), 14-8 (TCAV)
% L3 is LI15-LI19:  15-1, 15-2, . . . 19-5, 19-6
handles.nr = numel(handles.regions);

% map klystrons to regions
handles.kmap = zeros(handles.ns,handles.nk);
handles.kmap(1,4:5) = 1; % 10-3, 10-4 -> BPMS:IN10:731:X
handles.kmap(2,2:3) = 2; % 11-1, 11-2 -> BPMS:LI11:333:X
handles.kmap(2,5:9) = 3; % 11-4, ..., 11-8 -> BPMS:LI14:801:X
handles.kmap(3:4,:) = 3; % 12-1, ..., 13-8 -> BPMS:LI14:801:X
handles.kmap(5,1:7) = 3; % 14-1, ..., 14-6 -> BPMS:LI14:801:X
%handles.kmap(6:10,:) = 4; % 15-1, ..., 19-8 -> BPMS:LI20:2050:X
handles.kmap(6:10,:) = 4; % 15-1, ..., 19-8 -> BPMS:LI20:2147:X



%handles.kmap(1,   :)  = 1 * ones(1, handles.nk);
%handles.kmap(2,   :)  = 2 * ones
%handles.kmap(3:11,  :)  = 2 * ones(9, handles.nk);
%%handles.kmap(12:20, :)  = 3 * ones(9, handles.nk);

% define available bpm parameters
%handles.bpms        = {'BPMS:DR11:854:X'    'BPMS:LI10:3448:X'  'BPMS:LI10:3448:X'  'BPMS:EP01:185:X'   'BPMS:LI20:2050:X'}';
%handles.bpms        = {'BPMS:IN10:731:X' 'BPMS:LI11:333:X' 'BPMS:LI14:801:X' 'BPMS:LI20:2147:X' 'BPMS:LI20:2050:X'  'BPMS:EP01:185:X'}';
handles.bpms        = {'BPMS:IN10:731:X' 'BPMS:LI11:333:X' 'BPMS:LI14:801:X' 'BPMS:LI20:2050:X' 'BPMS:LI20:2147:X'  'BPMS:EP01:185:X'}';

handles.measdefs    = {''  ''  ''  'FACET-II'  'FACET-II'  'ELECEP01'}';
%handles.measdefs    = {''           ''          ''           'NDRFACET'    'ELECEP01'}';
handles.bpmds       = {'' '' '' '57' '57' '8'}';
handles.feedbacks   = {'LI01:FBCK:5:HSTA';  'LI09:FBCK:201:HSTA'; 'LI09:FBCK:201:HSTA'; 'SIOC:SYS1:ML00:AO060'; 'SIOC:SYS1:ML00:AO084'};
handles.buffAcqs    = [false, false, false, true, true, true];

% put these things in the defaults thingy
set(handles.popupmenu_region, 'String', handles.regions);
set(handles.popupmenu_defaults, 'String', strcat(handles.bpmds, {'  '}, handles.measdefs, {'  '}, handles.bpms));
set(handles.popupmenu_region, 'Value', 2);

% define some feedback names for the regions
% handles.feedbacks = {'LI01:FBCK:5:HSTA'; 'LI09:FBCK:201:HSTA'; 'SIOC:SYS1:ML00:AO060'};

% create UNDO array
handles.undo = nan([handles.ns, handles.nk, 4]);   % phas pdes gold kphr for each station

% pick a station to start with
handles.s =3;
handles.k = 2;
handles.r = handles.kmap(handles.s, handles.k);
%disp(handles.r);
handles.sector = handles.sectors(handles.s);
handles.klystron = handles.klystrons(handles.k);
handles.klys = strcat(handles.sector, '-', handles.klystron);

% generate a default config
%handles.config.rmap         = [1 2 4];  % map regions to bpm parameters
handles.config.rmap         = [1 2 3 4];  % map regions to bpm parameters
%disp(handles.config.rmap(handles.r));
handles.config.fphase       = 0;        % gold phase
handles.config.nsteps       = 9;        % number of scan steps
handles.config.nsamp        = 30;       % number of bpm samples per step
handles.config.range        = 60;       % scan range +/- around current phase
handles.config.sbstrange    = 15;       % scan range for subboosters
handles.config.buffacq      = 1;        % flag: use SLC buffered acquisition
handles.config.zigzag       = 1;        % flag: do zig-zag scan
handles.config.plotavg      = 1;        % flag: plot error bars instead of all points
handles.config.bpm          = handles.bpms(handles.config.rmap(handles.r));
handles.config.bpmd         = handles.bpmds(handles.config.rmap(handles.r));
handles.config.measdef      = handles.measdefs(handles.config.rmap(handles.r));
handles.defaults = handles.config;

%load the config
try
    handles.config = util_configLoad(handles.appName, 0);
catch
    gui_statusDisp(handles, 'Error loading config.  Using defaults.');
    handles.config = handles.defaults;
end

% set the 'fake data' flag
handles.fakedata = get(handles.checkbox_fakedata, 'Value');
handles.custom_bpm = 0;

handles = update_gui(handles);
handles = update_klys(handles);
handles = update_phases(handles);
handles = update_status(handles);

util_appFonts(gcf, 'lineWidth', 2, 'markerSize', 4);

gui_statusDisp(handles, 'FACET phase scans loaded.');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes facet_phase_scans wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = update_phases(handles)
% gets current phas, pdes, kphr and gold for selected station and populates
% GUI with them.

[handles.phas, handles.pdes, z, z, handles.kphr, handles.gold] = control_phaseGet(handles.klys);
set(handles.text_PDES, 'String', sprintf('%.1f', handles.pdes));
set(handles.text_PHAS, 'String', sprintf('%.1f', handles.phas));
set(handles.text_KPHR, 'String', sprintf('%.1f', handles.kphr));
set(handles.text_GOLD, 'String', sprintf('%.1f', handles.gold));
drawnow;

function handles = update_new_phases(handles)
% gets NEW phas, pdes, kphr and gold for selected station and populates
% GUI with them.
% get new phase values
[handles.new.phas, handles.new.pdes, z, z, handles.new.kphr, handles.new.gold] = control_phaseGet(handles.klys);

set(handles.edit_PDES_new, 'String', sprintf('%.1f', handles.new.pdes));
set(handles.edit_PHAS_new, 'String', sprintf('%.1f', handles.new.phas));
set(handles.edit_KPHR_new, 'String', sprintf('%.1f', handles.new.kphr));
set(handles.edit_GOLD_new, 'String', sprintf('%.1f', handles.new.gold));
drawnow;

function handles=clear_new_phase(handles)
% Clears the GUI fields of New phas, pdes, kphr and gold
set(handles.edit_PDES_new, 'String', '');
set(handles.edit_PHAS_new, 'String', '');
set(handles.edit_KPHR_new, 'String', '');
set(handles.edit_GOLD_new, 'String', '');
drawnow;

function handles = update_klys(handles)

handles.s = get(handles.popupmenu_sector, 'Value');
handles.k = get(handles.popupmenu_station, 'Value');
handles.r = handles.kmap(handles.s, handles.k);
handles.sector = handles.sectors(handles.s);
handles.klystron = handles.klystrons(handles.k);
handles.klys = strcat(handles.sector, '-', handles.klystron);

% save undo state
[undo.phas, undo.pdes, z, z, undo.kphr, undo.gold] = control_phaseGet(handles.klys);

handles.undo(handles.s, handles.k, 1) = undo.phas;
handles.undo(handles.s, handles.k, 2) = undo.pdes;
handles.undo(handles.s, handles.k, 3) = undo.kphr;
handles.undo(handles.s, handles.k, 4) = undo.gold;


function handles = update_status(handles)

if any(strmatch(handles.sector, {'00' '01'}))
    bc = 11;
else
    bc = 10;
end

[handles.act, handles.stat, handles.swrd, z, z, handles.enld] = control_klysStatGet(handles.klys, bc);

if any(isnan([handles.act, handles.stat, handles.swrd, handles.enld]))
    set(handles.pushbutton_active, 'String', '????');
    set(handles.pushbutton_active, 'ForegroundColor', 'red');
    return
end

if bitget(handles.act, 1) || strcmpi(handles.klystron, 'S')
    set(handles.pushbutton_active, 'String', 'ACTIVE');
    set(handles.pushbutton_active, 'Value', 1);
    set(handles.pushbutton_active, 'Enable', 'on');
elseif bitget(handles.act, 2)
    set(handles.pushbutton_active, 'String', 'DEACT');
    set(handles.pushbutton_active, 'Value', 0);
    set(handles.pushbutton_active, 'Enable', 'on');
elseif bitget(handles.act, 3)
    set(handles.pushbutton_active, 'String', 'OFF/MNT');
    set(handles.pushbutton_active, 'Value', 0);
    %set(handles.pushbutton_active, 'Enable', 'off');
end

if ~bitget(handles.swrd, 4) || strcmpi(handles.klystron, 'S')
    set(handles.pushbutton_active, 'ForegroundColor', 'green');
else
    set(handles.pushbutton_active, 'ForegroundColor', 'red');
end
if  bitget(handles.act, 3)
    set(handles.pushbutton_active, 'ForegroundColor', 'cyan');
end


function handles = update_gui(handles)
% updates GUI with values from config

set(handles.popupmenu_defaults, 'Value', handles.config.rmap(get(handles.popupmenu_region, 'Value')));

set(handles.popupmenu_region, 'String', handles.regions);
set(handles.popupmenu_region, 'Value', handles.r);

set(handles.popupmenu_sector, 'String', handles.sectors);
set(handles.popupmenu_sector, 'Value', handles.s);

set(handles.popupmenu_station, 'String', handles.klystrons);
set(handles.popupmenu_station, 'Value', handles.k);

handles.fphase = handles.config.fphase;
set(handles.edit_finalphase, 'String', num2str(handles.fphase));

handles.nsteps = handles.config.nsteps;
set(handles.edit_nsteps, 'String', num2str(handles.nsteps));

handles.nsamp = handles.config.nsamp;
set(handles.edit_nsamp, 'String', num2str(handles.nsamp));

if handles.k == 1
    handles.range = handles.config.sbstrange;
else
    handles.range = handles.config.range;
end
set(handles.edit_range, 'String', num2str(handles.range));

%handles.buffacq = handles.config.buffacq;
handles.buffacq = handles.buffAcqs(handles.r);
set(handles.checkbox_buffacq, 'Value', handles.buffacq);

handles.zigzag = handles.config.zigzag;
set(handles.checkbox_zigzag, 'Value', handles.zigzag);

handles.plotavg = handles.config.plotavg;
set(handles.checkbox_plotavg, 'Value', handles.plotavg);

if ~handles.custom_bpm
    handles.bpm = handles.bpms(handles.config.rmap(handles.r));
    set(handles.edit_bpm, 'String', handles.bpm);

    handles.bpmd = handles.bpmds(handles.config.rmap(handles.r));
    set(handles.edit_bpmd, 'String', handles.bpmd);

    handles.measdef = handles.measdefs(handles.config.rmap(handles.r));
    set(handles.edit_measdef, 'String', handles.measdef);

    handles.pv = strcat(handles.bpm, handles.bpmd);
end


drawnow;


% --- Outputs from this function are returned to the command line.
function varargout = facet_phase_scans_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_scan.
function pushbutton_scan_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tic;
set(hObject, 'String', 'Scanning...');
set(hObject, 'Enable', 'off');
handles.fakedata = get(handles.checkbox_fakedata,'Value');

% % check/switch off feedbacks
% fboff   = 1;
% fbpv    = handles.feedbacks(handles.config.rmap(handles.r));
% fbstate = lcaGetSmart(fbpv);
%
% if ~isnan(fbstate)
%     switch char(fbpv)
%         case 'LI01:FBCK:5:HSTA'
%             fboff = (fbstate == 402821537) || (fbstate == 402788612);  % hsta for 'off' or 'compute'
%         case 'LI09:FBCK:201:HSTA'
%             fboff = (fbstate == 268435460) || (fbstate == 268468385);
%         case 'LI09:FBCK:200:HSTA'
%             fboff = (fbstate == 268435460) || (fbstate == 268468385);
%         case 'SIOC:SYS1:ML00:AO060'
%             % if after sector 20, disable EP01 feedback
%             if fbstate
%                 gui_statusDisp(handles, 'Disabling EP01 feedback...');
%                 fboff = lcaPutSmart(handles.feedbacks(handles.r), 0);
%             end
%         case 'SIOC:SYS1:ML00:AO084'
%             % if after sector 20, disable LI20 feedback
%             if fbstate
%                 gui_statusDisp(handles, 'Disabling LI20 feedback...');
%                 fboff = lcaPutSmart(handles.feedbacks(handles.r), 0);
%             end
%         otherwise
%             fboff = 1;
%     end
% end
%
% if ~fboff
%     response = questdlg(sprintf('Energy feedback %s is still on.  Proceed?', char(fbpv)));
%     if ~strcmp(response, 'Yes')
%         gui_statusDisp(handles, 'Scan Aborted.');
%         set(hObject, 'String', 'Scan');
%         set(hObject, 'Enable', 'on');
%         return;
%     end
% end

% get phase offset : sbst
handles.poff = 0;
% if handles.k >= 2
%     sbst_offs = control_phaseGet(strcat(handles.sector, '-S'));
%     handles.poff = handles.poff + sbst_offs;
%
%     % check for sane values
%     if sbst_offs == -10000 || isnan(sbst_offs)
%         response = questdlg(sprintf('SBST %d phase readback = %f.  Phase offset will be wrong.  Proceed?', ...
%             handles.s - 1, sbst_offs));
%         if ~strcmp(response, 'Yes')
%             gui_statusDisp(handles, 'Scan Aborted.');
%             set(hObject, 'String', 'Scan');
%             set(hObject, 'Enable', 'on');
%             return;
%         end
%     end
% end

% force 9-1 and 9-2 SBST phase offset to 0
if strcmp(handles.klys, '09-1') || strcmp(handles.klys, '09-2')
    handles.poff = 0;
end

% get fast phase shifter phases
fps_names = {'PHAS:LI09:12' 'PHAS:LI09:22' 'AMPL:EP01:171' 'AMPL:EP01:181'};
fps = control_phaseGet(fps_names);
bad = (fps == -10000) | isnan(fps);
bad_names = sprintf('%s %s %s %s', fps_names{bad});

if any(bad)
    response = questdlg(sprintf('Fast phase shifter %s read error.  Phase offset may be wrong.  Proceed?', bad_names));
    if ~strcmp(response, 'Yes')
        gui_statusDisp(handles, 'Scan Aborted.');
        set(hObject, 'String', 'Scan');
        set(hObject, 'Enable', 'on');
        return;
    end
end

% add phase offset: fast phase shifter sector 9
if strcmp(handles.klys, '09-1')
    handles.poff = handles.poff + fps(1);
end
if strcmp(handles.klys, '09-2')
    handles.poff = handles.poff + fps(2);
end

% add phase offset: fast phase shifter sectors 17/18
if handles.s == 18  % sector 17
    handles.poff = handles.poff + fps(3);
end
if handles.s == 19  % sector 18
    handles.poff = handles.poff + fps(4);
end

% update display for selected station
handles = pushbutton_update_Callback(handles.pushbutton_update, [], handles);

% do the scan
handles = scan(handles);
toc;

% check for valid scan
ok = check_scan(handles);

% build history PV names
if handles.k == 1
    pvroot = sprintf('SBST:LI%s:1', handles.sectors{handles.s});
else
    pvroot = sprintf('KLYS:LI%s:%s1', handles.sectors{handles.s}, handles.klystrons{handles.k});
end
pv_phase0   = strcat(pvroot, ':PHASSCANERR');
pv_phasets  = strcat(pvroot, ':PHASSCANTS');
pv_ampl     = strcat(pvroot, ':EMEASURED');


% write phase, timestamp and ampl scan results to pvs
if ok
    lcaPutSmart(pv_phase0, handles.data.fit.phase0);
    epics_t0 = datenum('Jan 1 1990 00:00:00');
    lcaPutSmart(pv_phasets, (handles.data.ts - epics_t0) * 24 * 60 * 60);
    lcaPutSmart(pv_ampl, handles.data.fit.ampl);
end

% ask user to continue with golding
if ~ok
    response = questdlg('Bad scan, do you really want to change this station?');
    if strcmp(response, 'Yes')
        ok = 1;
    end
end


if ok && any(handles.data.ok()) && ~handles.fakedata
    if abs(handles.data.fit.phase0 - handles.data.curr.pdes) > 20
        response = questdlg('Large phase change (>20 deg) - set phase to peak?');
        if ~strcmp(response, 'Yes')
            gui_statusDisp(handles, 'Scan completed, no change made.');
            ok = 0;
        end
    end
end

if ok

    % set station phase to measured zero phase and trim
    [d, handles.new.ok] = control_phaseSet(handles.data.name, handles.data.fit.phase0, ~handles.fakedata);
    gui_statusDisp(handles, sprintf('Set %s to peak phase of %.1f.  Press GOLD to accept!', char(handles.data.name), handles.data.fit.phase0));

    pvnum = (handles.s * 10) + handles.k + 100;
    pvstr = strcat('SIOC:SYS1:ML02:AO', num2str(pvnum));
    script_setupPV(pvstr, strcat(handles.klys, {' delta phase'}), 'degS', 1, handles.appName);
    lcaPutSmart(strcat('SIOC:SYS1:ML02:AO', num2str(pvnum)), handles.data.fit.phase0 - handles.data.curr.pdes);

    % gold station
    % control_phaseGold(handles.data.name, handles.data.fphase);

end

% update new values box in GUI
handles = update_new_phases(handles);
set(hObject, 'String', 'Scan');
set(hObject, 'Enable', 'on');

if get(handles.togglebutton_abort, 'Value')
    gui_statusDisp(handles, 'Scan Aborted');
    togglebutton_abort_Callback(handles.togglebutton_abort, [], handles);
end

guidata(hObject, handles);
toc;


function handles = scan(handles)

%clear the New pdes, phas, gold and kphr values so there is no risk
%reassigning them
clear_new_phase(handles);


% construct name string
handles.data.name = handles.klys;

% get phase names
[name, is, handles.data.name_pact, handles.data.name_pdes] = control_phaseNames(handles.data.name);

% save timestamp and useful stuff in data struct
handles.data.ts = now;
handles.data.bpm = handles.bpm;
handles.data.fphase = handles.fphase;
handles.data.curr.kphr = handles.kphr;
handles.data.curr.gold = handles.gold;
handles.data.curr.pdes = handles.pdes;
handles.data.curr.phas = handles.phas;
handles.data.poff = handles.poff;

% get dispersion at BPM
[p, m, u, s] = model_nameSplit(handles.data.bpm);
try
    twiss = model_rMatGet(strcat(p, ':', m, ':', u), [], {'TYPE=DESIGN', 'MODE=1'}, 'twiss');
    handles.data.eta = [twiss(5), twiss(10)];
    handles.data.energy = twiss(1);
catch
    gui_statusDisp(handles, sprintf('Error getting twiss for %s', handles.data.bpm));
    handles.data.eta = 1;
    handles.data.energy = 1;
end
handles.data.plane = s;

% save fake data flag
handles.data.fakedata = handles.fakedata;

% construct scan range
if handles.zigzag
    handles.data.pdes = linspace((handles.pdes - handles.range), (handles.pdes + handles.range), handles.nsteps)';
    odds = find(bitget(1:numel(handles.data.pdes), 1));
    evens = find(~bitget(1:numel(handles.data.pdes), 1));
    midpt = round(numel(odds)/2);
    s1 = odds(1:midpt);
    s3 = odds(midpt+1:end);
    s2 = flipdim(evens, 2);
    scan_pts = ([s3 s2 s1])';
    handles.data.pdes = handles.data.pdes(scan_pts);
else
    handles.data.pdes = linspace((handles.pdes - handles.range), (handles.pdes + handles.range), handles.nsteps)';
end

% scan around offset point
handles.data.pdes = handles.data.pdes - handles.data.poff;

% clear out old scan data
handles.data.bpmdata =[];
handles.data.pact = [];
handles.data.ok = [];
handles.data.p_ok = [];
handles.data.b_ok = [];
handles.data.tmit = [];
handles.data.goodmeas = [];

% generate fake data
if handles.fakedata
    phase_offset = randn(1) * 20;
    dispersion = handles.data.eta(find(strcmp(handles.data.plane, {'X' 'Y'})));
    bpmdata = 0.02 * randn([handles.nsteps, handles.nsamp]) + ...
        repmat(1e3 * dispersion * (cosd(handles.data.pdes + phase_offset) * 0.25 / handles.data.energy), 1, handles.nsamp);
    pact = handles.data.pdes;
    ok = ones(size(handles.data.pdes));
end

if get(handles.togglebutton_abort, 'Value'), return; end

% main scan code goes here
for ix = 1:numel(handles.data.pdes)

    gui_statusDisp(handles, sprintf('Scanning %s from %.1f to %.1f, step %d / %d ...', ...
    char(handles.data.name), min(handles.data.pdes), max(handles.data.pdes), ix, handles.nsteps));

    % collect data
    if handles.fakedata
        handles.data.bpmdata(ix, :) = bpmdata(ix, :);
        handles.data.pact(ix) = pact(ix);
        handles.data.ok(ix) = ok(ix);
        pause(2);
    else
        % set PDES and trim (trim flag 3rd argument)
        %[handles.data.pact(ix), handles.data.ok(ix)] = control_phaseSet(name, handles.data.pdes(ix), 1, 1);
        [handles.data.pact(ix), handles.data.p_ok(ix)] = control_phaseSet(name, handles.data.pdes(ix), 1, 1);

        if handles.buffacq
            try
                handles.data.b_ok(ix) = 1;
                if ~handles.fakedata
                    buffdata = ((AidaTable)(request(strcat(handles.measdef, ':BUFFACQ')).with('BPMD', handles.bpmd).with('NRPOS', handles.nsamp).with('BPMS', char(strcat('["', p, ':', m, ':', u, '"]'))).get())).getValues();
                else
                    buffdata = ((AidaTable)(request(strcat(handles.measdef, ':BUFFACQ')).get())).getValues();
                end
            catch
                handles.data.b_ok(ix) = 0;
            end

            if handles.data.b_ok(ix)
                handles.data.tmit(ix, :) = buffdata.get('tmit');
                handles.data.goodmeas(ix,:) = buffdata.get('goodmeas');
                switch char(handles.data.plane)
                    case 'X'
                        handles.data.bpmdata(ix,:) = buffdata.get('x');
                    case 'Y'
                        handles.data.bpmdata(ix,:) = buffdata.get('y');
                    otherwise
                        handles.data.bpmdata(ix,:) = zeros(1,handles.nsamp);
                end
            else
                handles.data.bpmdata(ix,:) = zeros(1,handles.nsamp);
                handles.data.tmit(ix,:) = zeros(1, handles.nsamp);
                handles.data.goodmeas(ix,:) = zeros(1, handles.nsamp);
            end
        else % use EPICS acquisition
            lcaSetMonitor(handles.pv);
            for jx = 1:handles.nsamp
                lcaNewMonitorWait(handles.pv)
                handles.data.bpmdata(ix, jx) = lcaGetSmart(handles.pv);
                handles.data.tmit(ix, jx) = lcaGetSmart(strrep(handles.pv,'X','TMIT'));
                bpm_stat = lcaGetSmart(strrep(handles.pv,'X','STA'));
                if bpm_stat ==0
                    handles.data.goodmeas(ix,jx) = 1;
                else
                    handles.data.goodmeas(ix,jx) = 0;
                end

            end % end sample loop
            handles.data.b_ok(ix) = 1;
        end
    end

    if get(handles.togglebutton_abort, 'Value'), return; end

    handles = fit_and_plot(handles, 1, handles.axes1);
end % end steps loop

gui_statusDisp(handles, sprintf('Restoring %s PDES to %.1f', char(handles.data.name), handles.data.curr.pdes));

% restore PDES to initial setting
control_phaseSet(name, handles.data.curr.pdes, 1, 2);


function handles = fit_and_plot(handles, doPlot, ax)

if nargin < 2, doPlot = 0; end
if nargin < 3, ax = handles.axes1; end

dispersion = handles.data.eta(find(strcmp(handles.data.plane, {'X' 'Y'})));

%handles.data.ok = handles.data.p_ok & handles.data.b_ok;
handles.data.ok = handles.data.b_ok;

% flag good data
if ~handles.fakedata
    use = (handles.data.tmit > 5e8)     & (handles.data.tmit < 5e10)    & ...
      (handles.data.bpmdata < 20)   & (handles.data.bpmdata > -20)  & ...
      (handles.data.goodmeas == 1);
else
    use=ones(numel(handles.data.ok),numel(handles.data.bpmdata));
end
% fit to cosine
dataStd = zeros(size(handles.data.ok));
data    = zeros(size(handles.data.ok));
fit_use = false(size(handles.data.ok));

for ix = 1:numel(handles.data.ok)
    rowuse = use(ix,:);
    if any(rowuse) && handles.data.ok(ix)
        dataStd(ix) = std(handles.data.bpmdata(ix, rowuse), 0, 2);
        data(ix)    = mean(handles.data.bpmdata(ix, rowuse), 2);
        fit_use(ix) = handles.data.ok(ix) & 1;
    else
        dataStd(ix) = 0;
        data(ix)    = 0;
        fit_use(ix) = 0;
    end
end

phase = handles.data.pact + handles.data.poff;

% do the fitting if there are any valid points
if any(fit_use)
    [par, parCov, parStd, fphase, fdata, fdataStd, mse] = beamAnalysis_phaseFit(phase(fit_use), sign(dispersion) * data(fit_use), dataStd(fit_use));

    % store fits
    handles.data.fit.ampl = par(1) * handles.data.energy / abs(dispersion);
    handles.data.fit.amplstd = parStd(1) * handles.data.energy / abs(dispersion);
    handles.data.fit.phase0 = par(2);
    handles.data.fit.phase0std = parStd(2);
    handles.data.fit.offset = par(3);
    handles.data.fit.offsetstd = parStd(3);

end

% do the plotting
if ~doPlot
    return
end

reset(ax); cla(ax, 'reset');
hold(ax);

% plot raw data
if handles.config.plotavg
    plot_bars(ax, phase(fit_use), data(fit_use), dataStd(fit_use), 'rd'); drawnow; %%% updatesd to now pass in axes handles
    if any(~fit_use)
        plot_bars(ax, phase(~fit_use), data(~fit_use), dataStd(~fit_use), 'kd'); drawnow;
    end
else
    % this breaks.  disable and hide the control for now.
    plot(ax, phase(any(use, 2)), handles.data.bpmdata(use), 'r*'); drawnow;
    if any(any(~use))
        plot(ax, phase(any(~use, 2)), handles.data.bpmdata(~use), 'k*'); drawnow;
    end
end

% bail out if the fit hasnt happened yet
if ~any(fit_use)
    return
end

% plot fit
plot(ax, fphase, sign(dispersion) * fdata, 'b-');

% plot vertical line at zero phase
%xlim('manual');
ylim('manual');
ver_line(ax, handles.data.fit.phase0, '--');    % dashed line at measured phase
ver_line(ax, handles.data.fphase, ':');         % dotted line at desired final phase

% annotate with ampl and phase
table = {
    sprintf('AMPL = %.2f \\pm %.2f', handles.data.fit.ampl, handles.data.fit.amplstd); ...
    sprintf('PHAS_0 = %.2f \\pm %.2f', handles.data.fit.phase0, handles.data.fit.phase0std); ...
    sprintf('POFF = %.2f', handles.data.poff); ...
    };

text(0.05, 0.95, table, 'Units', 'Normalized', 'VerticalAlignment', 'Top', 'interpreter', 'tex', 'FontSize', 12);


% add label and title
xlabel(ax, sprintf('%s + POFF', char(handles.data.name_pact)));
ylabel(ax, handles.data.bpm);
title(ax, strcat(datestr(handles.data.ts), {'; '}, handles.data.name, {' \phi_{set} = '}, num2str(handles.data.fphase), ...
    {'\circ, \phi_{meas} = '}, sprintf('%.2f', handles.data.fit.phase0), {'\circ'}), 'interpreter', 'tex');
drawnow;

function ok = check_scan(handles)

num_bad = sum(double(~handles.data.ok));

if ((num_bad / numel(handles.data.ok)) > 0.3)
    ok = 0;
else
    ok = 1;
end


% --- Executes on selection change in popupmenu_sector.
function popupmenu_sector_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.custom_bpm = 0;
handles = update_klys(handles);
handles = update_status(handles);
handles = update_phases(handles);
handles = update_gui(handles);
clear_new_phase(handles);
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns popupmenu_sector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sector


% --- Executes during object creation, after setting all properties.
function popupmenu_sector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_station.
function popupmenu_station_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_station (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.custom_bpm = 0;
set(handles.pushbutton_scan, 'Enable', 'off');
handles = update_klys(handles);  drawnow;
handles = update_status(handles);  drawnow;
handles = update_phases(handles);  drawnow;
handles = update_gui(handles);  drawnow;
set(handles.pushbutton_scan, 'Enable', 'on');
clear_new_phase(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_station contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_station


% --- Executes during object creation, after setting all properties.
function popupmenu_station_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_station (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_update.
function handles = pushbutton_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', 'Updating...');
set(hObject, 'Enable', 'off');
drawnow;
handles = update_phases(handles);

set(hObject, 'String', 'Update');
set(hObject, 'Enable', 'on');
guidata(hObject, handles);



function edit_finalphase_Callback(hObject, eventdata, handles)
% hObject    handle to edit_finalphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.fphase = str2double(get(hObject, 'String'));
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_finalphase as text
%        str2double(get(hObject,'String')) returns contents of edit_finalphase as a double


% --- Executes during object creation, after setting all properties.
function edit_finalphase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_finalphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_nsteps_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.nsteps = str2int(get(hObject, 'String'));
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_nsteps as text
%        str2double(get(hObject,'String')) returns contents of edit_nsteps as a double


% --- Executes during object creation, after setting all properties.
function edit_nsteps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nsteps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_range_Callback(hObject, eventdata, handles)
% hObject    handle to edit_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.range = str2double(get(hObject, 'String'));
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



function edit_nsamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nsamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.nsamp = str2int(get(hObject, 'String'));
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


% --- Executes on button press in pushbutton_configSave.
function pushbutton_configSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_configSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    ok = 1;
    util_configSave(handles.appName, handles.config, 0);
catch
    ok = 0;
    gui_statusDisp(handles, 'Error saving config.');
end

if ok
    gui_statusDisp(handles, 'Config saved.');
end



% --- Executes on button press in pushbutton_gold.
function pushbutton_gold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_gold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

response = questdlg(sprintf('This will GOLD %s to %.1f deg.  Proceed?', char(handles.klys), handles.fphase));
if ~strcmp(response, 'Yes'), return; end

set(hObject, 'Enable', 'off');
set(hObject, 'String', 'Golding...');
set(handles.pushbutton_scan, 'Enable', 'off')
gui_statusDisp(handles, sprintf('Golding %s to PDES = %.1f', char(handles.klys), handles.fphase));

% gold stataion
control_phaseGold(handles.klys, handles.fphase);

pause(3);

handles = update_new_phases(handles);
% build history PV names
if handles.k == 0
    pvroot = sprintf('SBST:LI%s:1', handles.sectors{handles.s});
else
    pvroot = sprintf('KLYS:LI%s:%s1', handles.sectors{handles.s}, handles.klystrons{handles.k});
end
pv_gold   = strcat(pvroot, ':GOLDCHG');
pv_goldts  = strcat(pvroot, ':GOLDCHGTS');

lcaPutSmart(pv_gold, (handles.gold - handles.new.gold));
epics_t0 = datenum('Jan 1 1990 00:00:00');
lcaPutSmart(pv_goldts, (now - epics_t0) * 24 * 60 * 60);

gui_statusDisp(handles, sprintf('%s golded.', char(handles.klys)));

set(hObject, 'Enable', 'on');
set(hObject, 'String', 'Gold');
set(handles.pushbutton_scan, 'Enable', 'on')

guidata(hObject, handles);

% --- Executes on button press in pushbutton_undo.
function pushbutton_undo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aidainit;
dundo = DaObject();

if any(isnan(handles.undo(handles.s, handles.k, :)))
    gui_statusDisp(handles, 'Error:  no undo data saved for %s', char(handles.klys));
else
    undo.pact = handles.undo(handles.s, handles.k, 1);
    undo.pdes = handles.undo(handles.s, handles.k, 2);
    undo.kphr = handles.undo(handles.s, handles.k, 3);
    undo.gold = handles.undo(handles.s, handles.k, 4);
    response = questdlg(sprintf('This will set %s back to:\nPDES = %.1f\nGOLD = %.1f\nKPHR = %.1f\nProceed?', ...
        char(handles.klys), undo.pdes, undo.gold, undo.kphr));
    if strcmp(response, 'Yes')
        set(hObject, 'String', sprintf('Undoing %s ...', char(handles.klys)));
        %set(hObject, 'Enable', 'off');

%         % get current phase setup
%         [pAct, pDes, aAct, aDes, kPhr, gold] = control_phaseGet(handles.klys);

        % put GOLD back
        ugold = control_phaseSet(handles.klys, undo.gold, 0, 0, 'GOLD');
        % put PDES back
        updes = control_phaseSet(handles.klys, undo.pdes, 0, 0, 'PDES');
        % put KPHR back and trim
        ukphr = control_phaseSet(handles.klys, undo.kphr, 0, 0, 'KPHR');

%         % calculate undo move
%         delta = undo.kphr - kPhr;
%
%         % move by delta
%         control_phaseSet(handles.klys, pDes + delta, 1, 60);
%
%         % re-gold now back at its old value
%         [new_pact, new_pdes, new_gold] = control_phaseGold(handles.klys, undo.pdes);

        pause(3);

        % get current phase setup
        [pAct, pDes, aAct, aDes, kPhr, gold] = control_phaseGet(handles.klys);

        if ((pDes - undo.pdes) < 1) && ((gold - undo.gold) < 1)
            gui_statusDisp(handles, sprintf('%s reverted to PDES = %.1f, GOLD = %.1f.', char(handles.klys), pDes, gold));
        else
            errordlg(sprintf('Uh oh, error undo''ing setup for %s.  Check phase histories!', char(handles.klys)));
        end
    end
end

handles = update_new_phases(handles);
set(hObject, 'String', 'Undo');
set(hObject, 'Enable', 'on');


function edit_bpm_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bpm = get(hObject, 'String');
handles.custom_bpm = 1;
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_bpm as text
%        str2double(get(hObject,'String')) returns contents of edit_bpm as a double


% --- Executes during object creation, after setting all properties.
function edit_bpm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_buffacq.
function checkbox_buffacq_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_buffacq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.buffacq = get(hObject, 'Value');
handles = update_gui(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_buffacq



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_configLoad.
function pushbutton_configLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_configLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    ok = 1;
    handles.config = util_configLoad(handles.appName, 1);
catch
    ok = 0;
    gui_statusDisp(handles, 'Error loading config.');
end

if ok && ~isempty(handles.config)
    gui_statusDisp(handles, 'Config loaded.');
end


function edit_PDES_new_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PDES_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PDES_new as text
%        str2double(get(hObject,'String')) returns contents of edit_PDES_new as a double


% --- Executes during object creation, after setting all properties.
function edit_PDES_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PDES_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_GOLD_new_Callback(hObject, eventdata, handles)
% hObject    handle to edit_GOLD_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_GOLD_new as text
%        str2double(get(hObject,'String')) returns contents of edit_GOLD_new as a double


% --- Executes during object creation, after setting all properties.
function edit_GOLD_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_GOLD_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_KPHR_new_Callback(hObject, eventdata, handles)
% hObject    handle to edit_KPHR_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_KPHR_new as text
%        str2double(get(hObject,'String')) returns contents of edit_KPHR_new as a double


% --- Executes during object creation, after setting all properties.
function edit_KPHR_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_KPHR_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_PHAS_new_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PHAS_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PHAS_new as text
%        str2double(get(hObject,'String')) returns contents of edit_PHAS_new as a double


% --- Executes during object creation, after setting all properties.
function edit_PHAS_new_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PHAS_new (see GCBO)
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
handles.config.zigzag = get(hObject, 'Value');
handles = update_gui(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_zigzag


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

printFig = figure;
printAxes = axes;
util_appFonts(printFig, 'lineWidth', 2, 'markerSize', 4, 'fontName', 'times', 'fontSize', 14);
handles = fit_and_plot(handles, 1, printAxes);

% annotate with old & new phase values
table = {sprintf('%5s %5s %5s', '', 'Old', 'New'); ...
    sprintf('%5s %5.1f %5.1f', 'PDES', handles.data.curr.pdes, handles.new.pdes); ...
    sprintf('%5s %5.1f %5.1f', 'PHAS', handles.data.curr.phas, handles.new.phas); ...
    sprintf('%5s %5.1f %5.1f', 'GOLD', handles.data.curr.gold, handles.new.gold); ...
    sprintf('%5s %5.1f %5.1f', 'KPHR', handles.data.curr.kphr, handles.new.kphr); ...
    };

text(0.99, 1, table, 'Units', 'Normalized', 'HorizontalAlignment', 'Right', ...
     'VerticalAlignment', 'Top', 'FontName', 'FixedWidth', 'FontSize', 10, 'EdgeColor', [0 0 0]);

opts.title = 'FACET Phase Scans';
opts.author = 'MATLAB';
opts.text = char(handles.data.name_pact);
util_printLog(printFig,opts);

guidata(hObject, handles);




function edit_active_Callback(hObject, eventdata, handles)
% hObject    handle to edit_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_active as text
%        str2double(get(hObject,'String')) returns contents of edit_active as a double


% --- Executes during object creation, after setting all properties.
function edit_active_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_active_Callback(hObject, eventdata, handles)
% hObject    handle to text_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_active as text
%        str2double(get(hObject,'String')) returns contents of text_active as a double


% --- Executes during object creation, after setting all properties.
function text_active_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
response = questdlg('This will restore all parameters to defaults.  Proceed?');
if strcmp(response, 'Yes')
    handles.config = handles.defaults;
    handles = update_gui(handles);
    gui_statusDisp(handles, 'Defaults restored - press Save Config to make it stick.');
end
guidata(hObject, handles);



function edit_bpmd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bpmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.bpmd = get(hObject, 'String');
handles.custom_bpm = 1;
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_bpmd as text
%        str2double(get(hObject,'String')) returns contents of edit_bpmd as a double


% --- Executes during object creation, after setting all properties.
function edit_bpmd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bpmd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_fakedata.
function checkbox_fakedata_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_fakedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_fakedata

handles.fakedata = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function pushbutton_scan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox_plotavg.
function checkbox_plotavg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotavg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.plotavg = get(hObject, 'Value');
handles = update_gui(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_plotavg


% --- Executes on selection change in popupmenu_defaults.
function popupmenu_defaults_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_defaults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.rmap(handles.r) = get(hObject, 'Value');

gui_statusDisp(handles, 'Re-select klys to apply changes.  Save config to make it stick.');
%handles = update_gui(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_defaults contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_defaults


% --- Executes during object creation, after setting all properties.
function popupmenu_defaults_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_defaults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_region.
function popupmenu_region_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.r = get(hObject, 'Value');
set(handles.popupmenu_defaults, 'Value', handles.config.rmap(handles.r));
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_region contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_region


% --- Executes during object creation, after setting all properties.
function popupmenu_region_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_measdef_Callback(hObject, eventdata, handles)
% hObject    handle to edit_measdef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.measdef = get(hObject, 'String');
handles.custom_bpm = 1;
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_measdef as text
%        str2double(get(hObject,'String')) returns contents of edit_measdef as a double


% --- Executes during object creation, after setting all properties.
function edit_measdef_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_measdef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_active.
function pushbutton_active_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_active (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton_active

if bitget(handles.act, 1) && ~bitget(handles.act, 3)
    response = questdlg(sprintf('This will DEACT %s.  Proceed?', char(handles.klys)));
    if strcmp(response, 'Yes')
        control_klysStatSet(handles.klys, 0);
    end
elseif bitget(handles.act, 2) && ~bitget(handles.act, 3)
    response = questdlg(sprintf('This will ACTIVATE %s.  Proceed?', char(handles.klys)));
    if strcmp(response, 'Yes')
        control_klysStatSet(handles.klys, 1);
    end
end

handles = update_status(handles);
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);
%util_appClose(hObject);
% Hint: delete(hObject) closes the figure


function togglebutton_abort_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(hObject, 'String', 'Aborting...');
else
    set(hObject, 'String', 'Abort Scan');
end
guidata(hObject, handles);


%---overriding some of the plotting functions in the facet toolbox so that
%gca is not used but instead the current handle
function plot_bars(axes, x, y, dy, mrk, bar_color)
%               plot_bars(x,y,dy[,mrk,bar_color])
%
%               Function to plot vertical error bars of y +/- dy.
%
%     INPUTS:   x:     		The horizontal axis data vector (column or row)
%               y:      	The vertical axis data vector (column or row)
%               dy:     	The half length of the error bar on "y" (column, row,
%                       	or scalar)
%               mrk:   		(Optional,DEF=none) The plot character at the point (x,y)
%                       	(see plot)
%				bar_color:	(Otional,DEF='k') Color of error bar (e.g. 'r')

%=============================================================================
x  = x(:);
y  = y(:);
dy = dy(:);

[rx,cx] = size(x);
[ry,cy] = size(y);
[rdy,cdy] = size(dy);

if (cx~=1) | (cy~=1) | (cdy~=1)
  error('*** PLOT_BARS only plots vectors ***')
end

n = rx;

if rdy==1
  dy = dy*ones(size(y));
end

tee = (max(x) - min(x))/100;

x_barv = [x x x-tee x+tee x-tee x+tee];
y_barv = [y+dy y-dy y-dy y-dy y+dy y+dy];

if ~exist('bar_color')
  bar_color = 'k';
end
if ~exist('mrk')
  plot(axes, x_barv(:,1:4)',y_barv(:,1:4)',['-' bar_color(1)]);
else
  plot(axes, x_barv(:,1:4)',y_barv(:,1:4)',['-' bar_color(1)],x,y,mrk);
end

hold_state = get(axes,'NextPlot');
hold on;
plot(axes, x_barv(:,5:6)',y_barv(:,5:6)',['-' bar_color(1)]);
set(axes,'NextPlot',hold_state);


%overriding the ver_line function that is in the matlab toolbox to pass the
%axes handle
function ver_line(axes,x,mrk)
%VER_LINE       ver_line([x,mrk]);
%
%               Draws a vertical dotted line along "x" on current plot
%               and leaves plot in "hold" state it was in
%
%     INPUTS:   x:      (Optional, DEF=0) The value of the horizontal axis to draw a
%                       vertical line.
%		mrk:	(Optional, DEF=':') The line type used.
%
%     OUTPUTS:          Plots line on current plot
%
%Emma     5/26/88: original
%Woodley  6/16/95: Matlab 4.1
%
%===========================================================================

if exist('x')==0,
  x = 0;                           % default to line at 0 if not given
end
if exist('mrk')==0,
  mrk = ':';                       % default to ':'
end

hold_state = get(axes,'NextPlot');  % get axes hold state
YLim = get(axes,'YLim');            % get axes axis limits
hold on                            % hold current plot
plot(axes, x*ones(size(YLim)),YLim,mrk)  % draw line
hold off                           % remove hold

set(axes,'NextPlot',hold_state);    % restore original hold state
