function varargout = jitter_gui(varargin)
% JITTER_GUI M-file for jitter_gui.fig
%      JITTER_GUI, by itself, creates a new JITTER_GUI or raises the existing
%      singleton*.
%
%      H = JITTER_GUI returns the handle to a new JITTER_GUI or the handle to
%      the existing singleton*.
%
%      JITTER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JITTER_GUI.M with the given input arguments.
%
%      JITTER_GUI('Property','Value',...) creates a new JITTER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jitter_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jitter_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jitter_gui

% Last Modified by GUIDE v2.5 31-Mar-2016 12:47:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jitter_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @jitter_gui_OutputFcn, ...
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


% --- Executes just before jitter_gui is made visible.
function jitter_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jitter_gui (see VARARGIN)

% Choose default command line output for jitter_gui
handles.output = hObject;

set(hObject, 'Toolbar', 'figure');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jitter_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jitter_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

handles.regions = {
    'NDRFACET'
    'SDRFACET'
    'SCAVSPPS'
    'INJ_ELEC'
    'LCLS'
};

handles.plottypes = {
    ' vs Time';
    ' vs pulseId';
    ' Histogram'
    ' PSD'
};

handles.fittypes = {
    ' No Fit';
    ' Polynomial';
    ' Parabola';
    ' Gaussian';
    ' Bimodal';
    ' Cosine';
    ' Erf';
};

set(handles.popupmenu_region, 'String', handles.regions);
set(handles.popupmenu_plot_a, 'String', handles.plottypes);
set(handles.popupmenu_fit,    'String', handles.fittypes);

gui_statusDisp(handles, 'Loading config...');
drawnow;

handles.config = util_configLoad('jitter_gui');

% if isempty(handles.config)
    gui_statusDisp(handles, 'Generating default config...');
    handles.config = make_config();
    %util_configSave('jitter_gui', handles.config);  % uncomment this eventually
% end

set(handles.popupmenu_region, 'Value', 1);
handles = popupmenu_region_Callback(handles.popupmenu_region, [], handles);



function config = make_config()

%%%%%%%%%%%%%%%%% % make FACET configs

% generate all DPSLCBUFF devices
bpms = model_nameConvert(model_nameRegion('BPMS', 'FACET'), 'SLC');
toro = model_nameConvert(model_nameRegion('TORO', 'FACET'), 'SLC');
gapm = model_nameConvert(model_nameRegion('GAPM', 'FACET'), 'SLC');
klys = model_nameConvert(model_nameRegion('KLYS', 'FACET'), 'SLC');
sbst = model_nameConvert(model_nameRegion('SBST', 'FACET'), 'SLC');

% concatenate all and get Z locations
root = [bpms; toro; gapm; klys; sbst];
[p,m,u] = model_nameSplit(root);

% config.NDRFACET.aida = strcat(m,':',p,':',u);
config.NDRFACET.aida = root;

% generate list of EPICS PVs
config.NDRFACET.epics = {...
    'PATT:SYS1:1:PULSEID'; 'PATT:SYS1:1:SEC'; 'PATT:SYS1:1:NSEC';
    'BLEN:LI20:3014:ARAW'; 'BLEN:LI20:3014:AIMAX';
    'BLEN:LI20:3014:BRAW'; 'BLEN:LI20:3014:BIMAX';
    'THZR:LI20:3075:CRAW'; 'THZR:LI20:3075:CIMAX';
    'THZR:LI20:3075:DRAW'; 'THZR:LI20:3075:DIMAX';
    'BPMS:LI20:2445:X'; 'BPMS:LI20:2445:Y'; 'BPMS:LI20:2445:TMIT';
    'BPMS:LI20:3156:X'; 'BPMS:LI20:3156:Y'; 'BPMS:LI20:3156:TMIT';
    'BPMS:LI20:3265:X'; 'BPMS:LI20:3265:Y'; 'BPMS:LI20:3265:TMIT';
    'BPMS:LI20:3315:X'; 'BPMS:LI20:3315:Y'; 'BPMS:LI20:3315:TMIT';
    'GADC0:LI20:EX01:CALC:CH0:';    'GADC0:LI20:EX01:CALC:CH1:';
    'GADC0:LI20:EX01:CALC:CH2:';    'GADC0:LI20:EX01:CALC:CH3:';
    'GADC0:LI20:EX01:CALC:CH4:';    'GADC0:LI20:EX01:CALC:CH5:';
    'GADC0:LI20:EX01:CALC:CH6:';    'GADC0:LI20:EX01:CALC:CH7:';
    'GADC0:LI20:EX01:CALC:CH8:';    'GADC0:LI20:EX01:CALC:CH9:';
    'GADC0:LI20:EX01:CALC:CH10:';   'GADC0:LI20:EX01:CALC:CH11:';
    'GADC0:LI20:EX01:CALC:CH12:';   'GADC0:LI20:EX01:CALC:CH13:';
    'GADC0:LI20:EX01:CALC:CH14:';   'GADC0:LI20:EX01:CALC:CH15:';    
    'PMT:LI20:3060:QDCRAW';
    'PMT:LI20:3070:QDCRAW';
    'PMT:LI20:3179:QDCRAW';
    'PMT:LI20:3350:QDCRAW';
    'PMT:LI20:3360:QDCRAW';
    'PMTR:LA20:10:PWR';
    'TCAV:LI20:2400:P'; 'TCAV:LI20:2400:A'
};

config.NDRFACET.dgrp = 'NDRFACET';
config.NDRFACET.bc = 10;
config.NDRFACET.rate = 'EVNT:SYS1:1:BEAMRATE';
config.NDRFACET.mask = {{'TS5' 'FFTB_ext'} {} {'DUMP_2_9' 'NO_EXT_ELEC'} {'FFTB_ext'}};

% config.NDRFACET.aida = strcat(m,':',p,':',u);
config.NDRFACET.aida = root;

% generate list of EPICS PVs
config.NDRFACET.epics = {...
    'PATT:SYS1:1:PULSEID'; 'PATT:SYS1:1:SEC'; 'PATT:SYS1:1:NSEC';
    'BLEN:LI20:3014:ARAW'; 'BLEN:LI20:3014:AIMAX';
    'BLEN:LI20:3014:BRAW'; 'BLEN:LI20:3014:BIMAX';
    'THZR:LI20:3075:CRAW'; 'THZR:LI20:3075:CIMAX';
    'THZR:LI20:3075:DRAW'; 'THZR:LI20:3075:DIMAX';
    'BPMS:LI20:2445:X'; 'BPMS:LI20:2445:Y'; 'BPMS:LI20:2445:TMIT';
    'BPMS:LI20:3156:X'; 'BPMS:LI20:3156:Y'; 'BPMS:LI20:3156:TMIT';
    'BPMS:LI20:3265:X'; 'BPMS:LI20:3265:Y'; 'BPMS:LI20:3265:TMIT';
    'BPMS:LI20:3315:X'; 'BPMS:LI20:3315:Y'; 'BPMS:LI20:3315:TMIT';
    'GADC0:LI20:EX01:CALC:CH0:';    'GADC0:LI20:EX01:CALC:CH1:';
    'GADC0:LI20:EX01:CALC:CH2:';    'GADC0:LI20:EX01:CALC:CH3:';
    'GADC0:LI20:EX01:CALC:CH4:';    'GADC0:LI20:EX01:CALC:CH5:';
    'GADC0:LI20:EX01:CALC:CH6:';    'GADC0:LI20:EX01:CALC:CH7:';
    'GADC0:LI20:EX01:CALC:CH8:';    'GADC0:LI20:EX01:CALC:CH9:';
    'GADC0:LI20:EX01:CALC:CH10:';   'GADC0:LI20:EX01:CALC:CH11:';
    'GADC0:LI20:EX01:CALC:CH12:';   'GADC0:LI20:EX01:CALC:CH13:';
    'GADC0:LI20:EX01:CALC:CH14:';   'GADC0:LI20:EX01:CALC:CH15:';    
    'PMT:LI20:3060:QDCRAW';
    'PMT:LI20:3070:QDCRAW';
    'PMT:LI20:3179:QDCRAW';
    'PMT:LI20:3350:QDCRAW';
    'PMT:LI20:3360:QDCRAW';
    'PMTR:LA20:10:PWR';
    'TCAV:LI20:2400:P'; 'TCAV:LI20:2400:A'
};

%%%%%%%%%%%%%%%%% % make SDRFACET configs

% copy NDRFACET
config.SDRFACET = config.NDRFACET;

% strip DR13
[p,m,u] = model_nameSplit(config.SDRFACET.aida);
isDR13 = strcmpi(m, 'DR13');
config.SDRFACET.aida(isDR13) = [];
dr03BPMS = {...
    'BPMS:DR03:51'
    'BPMS:DR03:95'
    'BPMS:DR03:115'
    'BPMS:DR03:125'
    'BPMS:DR03:155'
    'BPMS:DR03:165'
    'BPMS:DR03:225'
    'BPMS:DR03:245'
    'BPMS:DR03:275'
    'BPMS:DR03:315'
    'BPMS:DR03:345'
    'BPMS:DR03:385'
    'BPMS:DR03:405'
    'BPMS:DR03:435'
    'BPMS:DR03:465'
    'BPMS:DR03:545'
    'BPMS:DR03:601'
    'BPMS:DR03:665'
    'BPMS:DR03:745'
    'BPMS:DR03:775'
    'BPMS:DR03:845'
    'BPMS:DR03:881'
    };    
config.SDRFACET.aida = [dr03BPMS; config.SDRFACET.aida];

% add DR03 compressor
firstkly = find(strcmp(config.SDRFACET.aida, 'KLYS:LI02:11'));
config.SDRFACET.aida = [config.SDRFACET.aida(1:firstkly-1); {'KLYS:DR03:1'}; config.SDRFACET.aida(firstkly:end)];
    

% change LI10 BPM to 2448
config.SDRFACET.aida = strrep(config.SDRFACET.aida, '3448', '2448');

config.SDRFACET.dgrp = 'SDRFACET';
config.SDRFACET.bc = 6;
config.SDRFACET.rate = 'EVNT:SYS1:1:POSITRONRATE';
config.SDRFACET.mask = {{'TS5'} {} {'DUMP_2_9'} {}};

%%%%%%%%%%%%%%%%%%%% make SCAVSPPS config

% add EP01 BPMS - multiplexed so can only add a subset
ep01 = {
%     'BPMS:EP01:170'
%     'BPMS:EP01:175'
    'BPMS:EP01:185'
%     'BPMS:EP01:190'
%     'BPMS:EP01:204'
%     'BPMS:EP01:210'
%     'BPMS:EP01:220'
%     'BPMS:EP01:230'
%     'BPMS:EP01:240'
%     'BPMS:EP01:250'
%     'BPMS:EP01:260'
%     'BPMS:EP01:270'
%     'BPMS:EP01:280'
%     'BPMS:EP01:383'
};

% concatenate all and get Z locations
root = [bpms; ep01; toro; gapm; klys; sbst];
[p,m,u] = model_nameSplit(root);

root(strcmpi(m, 'LI20')) = [];

% strip out LI19 stuff after the Lambertson
rmDev = {
    'BPMS:LI19:801'
    'BPMS:LI19:901'
    'KLYS:LI19:81'
    'KLYS:LI19:97'
    };
for dev = rmDev'
    rmindex = strcmpi(dev, root);
    root(rmindex) = [];
end

config.SCAVSPPS.aida = root;
config.SCAVSPPS.epics   = {
        'PATT:SYS1:1:PULSEID'; 'PATT:SYS1:1:SEC'; 'PATT:SYS1:1:NSEC';
};

config.SCAVSPPS.dgrp = 'SCAVSPPS';
config.SCAVSPPS.bc = 10;
config.SCAVSPPS.rate = 'EVNT:SYS1:1:SCAVRATE';
config.SCAVSPPS.mask = {{'TS5'} {'FFTB_ext'} {'DUMP_2_9' 'NO_EXT_ELEC' 'FFTB_ext'} {}};

%%%%%%%%%%%%%%%%%%%%% make INJ_ELEC config
config.INJ_ELEC.dgrp    = 'INJ_ELEC';
config.INJ_ELEC.rate    = 'EVNT:SYS1:1:INJECTRATE';
config.INJ_ELEC.aida    = {};
config.INJ_ELEC.epics   = {};

%%%%%%%%%%%%%%%%%%%%%% make LCLS config
config.LCLS.dgrp    = {};
config.LCLS.aida    = {};
config.LCLS.epics   = {};

function handles = do_plot(handles, ax)

if nargin < 2, ax = handles.axes_a; end
if ~isfield(handles, 'data'), return; end

linespec = get(handles.edit_linespec, 'String');

a_str = get(handles.listbox_a, 'String');
a_sel = get(handles.listbox_a, 'Value');
a = a_str(a_sel);
for ix = 1:numel(a)   
    ai(ix) = find(strcmpi(handles.data.name, a(ix)), 1, 'first');
end

b_str = get(handles.listbox_b, 'String');
b_sel = get(handles.listbox_b, 'Value');
b = b_str(b_sel);
for ix = 1:numel(b)
    bi(ix) = find(strcmpi(handles.data.name, b(ix)), 1, 'first');
end

plot_a = get(handles.checkbox_a, 'Value');
plot_ab = get(handles.checkbox_ab, 'Value');

a_type = get(handles.popupmenu_plot_a, 'Value');
f_type = get(handles.popupmenu_fit, 'Value');
f_ord  = str2int(get(handles.edit_polyorder, 'String'));

% assign x and y vectors
data_a = handles.data.val(ai,:);
data_b = handles.data.val(bi,:);

% assign axes labels
l_a = handles.data.name(ai);
l_b = handles.data.name(bi);

axes(ax);  cla reset;  hold on;
cmap = colormap('lines');

if plot_a
    switch a_type
        case 1 % vs Time
            time = 24 * 3600 * (handles.data.time - handles.data.time(1));
            plot(time, data_a, linespec); axis tight;
            xlabel('Time [s]');
        case 2 % vs PulseId
            pulseid = handles.data.pulseid;
            plot(pulseid, data_a, linespec); axis tight;
            ylabel(char(l_a));  xlabel('PulseID');
        case 3 % histogram
            [n, xout] = hist(data_a, ceil(sqrt(handles.data.nsamp)));
            bar(xout, n);
        case 4 % PSD
            p=psdint(data_a',handles.data.rate,numel(data_a),'s',0,0);
            plot(p(2:end,1), p(2:end,2), linespec);  axis tight;
            ylabel(strcat({'PSD of '}, char(l_a)));  xlabel('Frequency');
    end
elseif plot_ab

    switch f_type
        case 2  % polynomial fit
            for ix = 1:size(data_a,1)
                xFit = linspace(min(data_b), max(data_b), 100);
                [par(ix,:), yFit(ix,:), parstd(ix,:), yFitStd(ix,:)] = ...
                    util_polyFit(data_b, data_a(ix,:), f_ord, [], xFit);
                util_errorBand(xFit, yFit(ix,:), yFitStd(ix,:), '-', 'Color', cmap(ix,:));
            end



        otherwise
    end
    plot(data_b, data_a, linespec);
    xlabel(char(l_b));
    axis tight;



end
children = get(ax, 'Children');
lines = findobj(ax, 'Type', 'line');
patches = findobj(ax, 'Type', 'patch');
colors = [get(lines, 'Color')];
if iscell(colors) && ~isempty(colors)
    colors = cell2mat(colors);
else
    colors = repmat([0 0 0], size(data_a, 2), 1);
end
label = '';
for ix = 1:numel(l_a)
    label = [label, sprintf('\\color[rgb]{%.4f %.4f %.4f}%s\n', ...
        colors(ix,:), l_a{ix})];
end
ylabel(deblank(label), 'Interpreter', 'tex');

title(sprintf('%s %s', handles.data.region, datestr(handles.data.ts)));

function handles = popupmenu_region_Callback(hObject, eventdata, handles)

% get region name from dropdown
sel = get(hObject, 'Value');
str = get(hObject, 'String');
region = char(str(sel));

% only reset GUI if new region selected
if isfield(handles, 'region') && strcmp(region, handles.region),return; end
    
% reset GUI
handles.region = region;
alldevices = [handles.config.(region).aida; handles.config.(region).epics];
set(handles.listbox_a, 'String', alldevices);
set(handles.listbox_b, 'String', {''});
set(handles.text_a, 'String', strcat(handles.region, {' Device List'}));
set(handles.text_b, 'Visible', 'off');
set(handles.listbox_b, 'Visible', 'off');
set(handles.edit_search_a, 'Visible', 'off');
set(handles.edit_search_b, 'Visible', 'off');

gui_statusDisp(handles, strcat(handles.region, {' ready to acquire data.'}));

guidata(hObject, handles);

function popupmenu_region_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function listbox_a_Callback(hObject, eventdata, handles)
handles = do_plot(handles);
guidata(hObject, handles);

function listbox_a_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function listbox_b_Callback(hObject, eventdata, handles)
handles = do_plot(handles);
guidata(hObject, handles);

function listbox_b_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_search_a_Callback(hObject, eventdata, handles)

searchstr = deblank(upper(get(hObject, 'String')));
if isempty(searchstr)
    matches = true(size(handles.data.name));
else
    matches = ~cellfun(@isempty, strfind(handles.data.name, searchstr));
end
matchstr = handles.data.name(matches);
set(handles.listbox_a, 'String', matchstr, 'Value', 1);
guidata(hObject, handles);


function edit_search_a_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_search_b_Callback(hObject, eventdata, handles)

searchstr = deblank(upper(get(hObject, 'String')));
if isempty(searchstr)
    matches = true(size(handles.data.name));
else
    matches = ~cellfun(@isempty, strfind(handles.data.name, searchstr));
end
matchstr = handles.data.name(matches);
set(handles.listbox_b, 'String', matchstr, 'Value', 1);
guidata(hObject, handles);

function edit_search_b_CreateFcn(hObject, eventdata, handles)

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


function pushbutton_add_Callback(hObject, eventdata, handles)


function pushbutton_saveconfig_Callback(hObject, eventdata, handles)

try
    ok = 1;
    util_configSave('jitter_gui', handles.config);
catch
    ok = 0;
    gui_statusDisp(handles, 'Problem saving config, config NOT saved.');
end

if ok
   gui_statusDisp(handles, 'Config saved.');
end

function handles = gui_update(handles)

if ~handles.data.acq, return, end;

set(handles.listbox_a, 'String', handles.data.name);
set(handles.listbox_b, 'String', handles.data.name);

if isempty(get(handles.listbox_a, 'Value'))
    set(handles.listbox_a, 'Value', 1);
end

set(handles.edit_search_a, 'String', 'Type to filter...');
set(handles.edit_search_b, 'String', 'Type to filter...');

set(handles.text_a, 'String', 'Device A');
set(handles.text_b, 'Visible', 'on');
set(handles.listbox_b, 'Visible', 'on');
set(handles.edit_search_a, 'Visible', 'on');
set(handles.edit_search_b, 'Visible', 'on');

handles = do_plot(handles);


function pushbutton_acquire_Callback(hObject, eventdata, handles)

set(hObject, 'Enable', 'off');
set(hObject, 'String', 'Acquiring...');

handles.data.saved = 0;
handles.data.region = handles.region;
nsamp = str2int(get(handles.edit_nsamp, 'String'));
handles.data.nsamp = nsamp;


% set up an edef
system = getSystem();
handles.data.system = system;
masks = handles.config.(handles.data.region).mask;
rate = lcaGetSmart(handles.config.(handles.data.region).rate);
bc = handles.config.(handles.data.region).bc;

edef = eDefReserve(mfilename);
% eDefParams(edef, 1, -1, {}, masks{2}, {}, masks{4});
% pause(1);
% eDefParams(edef, 1, -1, masks{1}, {}, masks{3}, {});
eDefParams(edef, 1, -1, masks{1}, masks{2}, masks{3}, masks{4}, bc);

handles.data.rate = rate;
handles.data.ts = now;
tic;

gui_statusDisp(handles, sprintf('Acquiring %d samples at %d Hz, est time %.2f sec', ...
    nsamp, rate, nsamp/rate));
% start edef
eDefOn(edef);

% start AIDA acquisition
aidadevs = handles.config.(handles.region).aida;
dgrp = handles.config.(handles.region).dgrp;

[x, y, t, pid, stat] = control_bpmAidaGet(aidadevs, nsamp, dgrp);

% stop edef and get data
eDefOff(edef);

gui_statusDisp(handles, sprintf('Acquisition finished, elapsed time %.2f sec.', ...
    toc()));

epicsdevs = handles.config.(handles.region).epics;
epicspvs = strcat(epicsdevs, 'HST', num2str(edef));
pidpv = strcat('PATT:', system, ':1:PULSEIDHST', num2str(edef));

epicsdata   = lcaGetSmart(epicspvs);
epicspids   = lcaGetSmart(pidpv);

% release edef
eDefRelease(edef);

% match up EPICS and AIDA pulseIds
[ispid, loc] = ismember(pid(1,:), epicspids);
if ~all(ispid)
    gui_statusDisp(handles,'WARNING: PulseID mismatch, acquisition failed.');
    set(hObject, 'Enable', 'on');
    set(hObject, 'String', 'Acquire');
    return;
end

% flag AIDA devices by type to assign AIDA output
isBPMS = strncmpi('BPMS', aidadevs, 4);
isKLYS = strncmpi('KLYS', aidadevs, 4);
isTORO = strncmpi('TORO', aidadevs, 4);
isSBST = strncmpi('SBST', aidadevs, 4);
isGAPM = strncmpi('GAPM', aidadevs, 4);

aidapvs = {};
aidadata = [];

for ix = 1:numel(aidadevs)
    if isBPMS(ix)
        aidapvs = [aidapvs; strcat(aidadevs{ix}, {':X'; ':Y'; ':TMIT';})];
        aidadata = [aidadata; x(ix,:); y(ix,:); t(ix,:); ];
    elseif isKLYS(ix)
        aidapvs = [aidapvs; strcat(aidadevs{ix}, ':PHAS')];
        aidadata = [aidadata; x(ix,:)];
    elseif isTORO(ix)
        aidapvs = [aidapvs; strcat(aidadevs{ix}, ':DATA')];
        aidadata = [aidadata; t(ix,:)];
    elseif isSBST(ix)
        aidapvs = [aidapvs; strcat(aidadevs{ix}, ':PHAS')];
        aidadata = [aidadata; x(ix,:)];
    elseif isGAPM(ix)
        aidapvs = [aidapvs; strcat(aidadevs{ix}, ':DATA')];
        aidadata = [aidadata; x(ix,:)];
    end
end

% concatenate AIDA and EPICS data, save into data struct
handles.data.name   = [aidapvs; epicsdevs];
handles.data.val    = [aidadata; epicsdata(:,loc)];

% extract timestamps and pulseIDs from EVG data
time_val = lca2matlabTime(epicsdata(2,loc));
nsec_val = 1e-9 * epicsdata(3,loc);

handles.data.time   = time_val + (nsec_val / 24 / 3600);
handles.data.pulseid = epicsdata(1,loc);
handles.data.acq = 1;

set(hObject, 'Enable', 'on');
set(hObject, 'String', 'Acquire');
    
handles = gui_update(handles);
guidata(hObject, handles);


function pushbutton_save_Callback(hObject, eventdata, handles)

if ~handles.data.acq, return; end
if handles.data.saved, return; end

try
    ok = 1;
    handles.data.saved = 1;
    [f,p] = util_dataSave(handles.data, 'jitter_gui', ...
        handles.data.region, handles.data.ts, 0);
catch
    ok = 0;
    gui_statusDisp(handles, 'Error when saving, data is NOT saved!');
end

if ok
    gui_statusDisp(handles, sprintf('Data saved to %s %s', p, f));
end

guidata(hObject, handles);


function pushbutton_load_Callback(hObject, eventdata, handles)

[handles.data, f, p] = util_dataLoad();
gui_statusDisp(handles, sprintf('Data loaded from %s', f));
handles = gui_update(handles);
guidata(hObject, handles);


function popupmenu_plot_a_Callback(hObject, eventdata, handles)

handles = do_plot(handles);
guidata(hObject, handles);

function popupmenu_plot_a_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_plot_b_Callback(hObject, eventdata, handles)


function popupmenu_plot_b_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_fit_Callback(hObject, eventdata, handles)


function popupmenu_fit_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_search_a_ButtonDownFcn(hObject, eventdata, handles)
set(hObject, 'String', '');
drawnow;
guidata(hObject, handles);


function edit_search_a_KeyPressFcn(hObject, eventdata, handles)


function edit_search_b_ButtonDownFcn(hObject, eventdata, handles)
set(hObject, 'String', '');
drawnow;
guidata(hObject, handles);


function checkbox_a_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkbox_ab, 'Value', 0);
end
handles = do_plot(handles);
guidata(hObject, handles);

% function checkbox_b_Callback(hObject, eventdata, handles)
% if get(hObject, 'Value')
%     set(handles.checkbox_ab, 'Value', 0);
% end
% handles = do_plot(handles);
% guidata(hObject, handles);

function checkbox_ab_Callback(hObject, eventdata, handles)
if get(hObject, 'Value')
    set(handles.checkbox_a, 'Value', 0);
%     set(handles.checkbox_b, 'Value', 0);
end
handles = do_plot(handles);
guidata(hObject, handles);


function edit_linespec_Callback(hObject, eventdata, handles)
handles = do_plot(handles);
guidata(hObject, handles);

function edit_linespec_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_linespec_Callback(hObject, eventdata, handles)
help_text = { ...
'    Various line types, plot symbols and colors may be obtained with'; ...
'    PLOT(X,Y,S) where S is a character string made from one element'; ...
'    from any or all the following 3 columns:'; ...
' '; ...
'           b     blue          .     point              -     solid'; ...
'           g     green         o     circle             :     dotted'; ...
'           r     red           x     x-mark             -.    dashdot '; ...
'           c     cyan          +     plus               --    dashed   '; ...
'           m     magenta       *     star             (none)  no line'; ...
'           y     yellow        s     square'; ...
'           k     black         d     diamond'; ...
'           w     white         v     triangle (down)'; ...
'                               ^     triangle (up)'; ...
'                               <     triangle (left)'; ...
'                               >     triangle (right)'; ...
'                               p     pentagram'; ...
'                               h     hexagram'; ...
};
helpfig = helpdlg(help_text, 'Linespec Info');


function pushbutton_print_Callback(hObject, eventdata, handles)

if ~handles.data.acq, return, end

% save data if not saved
pushbutton_save_Callback(handles.pushbutton_save, [], handles);

f = figure; a = axes;
handles = do_plot(handles, a);

util_printLog(f, struct('author', 'Jitter GUI'));


function edit_polyorder_Callback(hObject, eventdata, handles)


function edit_polyorder_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
util_appClose(hObject);