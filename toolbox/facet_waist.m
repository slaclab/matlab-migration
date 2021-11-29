function varargout = facet_waist(varargin)
% FACET_WAIST M-file for facet_waist.fig
%      FACET_WAIST, by itself, creates a new FACET_WAIST or raises the existing
%      singleton*.
%
%      H = FACET_WAIST returns the handle to a new FACET_WAIST or the handle to
%      the existing singleton*.
%
%      FACET_WAIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_WAIST.M with the given input arguments.
%
%      FACET_WAIST('Property','Value',...) creates a new FACET_WAIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_waist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_waist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_waist

% Last Modified by GUIDE v2.5 18-Jun-2013 15:04:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_waist_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_waist_OutputFcn, ...
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


% --- Executes just before facet_waist is made visible.
function facet_waist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_waist (see VARARGIN)

% Choose default command line output for facet_waist
handles.output = hObject;

gui_statusDisp(handles, 'Loading...');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes facet_waist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = facet_waist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% handles.names = model_nameConvert(model_nameRegion(...
%     {'OTRS' 'PROF' 'MIRR' 'EXPT' 'WIRE'}, 'LI20'), 'MAD');

set(handles.uipanel1, 'SelectionChangeFcn', @selcbk);

model_init('source', 'MATLAB');
handles.names = {...
%     'USTHZ' 'DSTHZ' ...
    'USOTR' 'WSIP1' ...
    'IPOTR1' 'DSOTR' 'WSIP2' 'IP2A' ...
    'WSIP3' 'IP2B'};
handles.pvroots = model_nameConvert(handles.names, 'EPICS');

%%%%% these z locations differ from SLC model!!! %%%%%
%handles.z = model_rMatGet(handles.names, [], {'MODE=1' 'POS=MID'}, 'Z');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.z = [
    1990.92, ... % USOTR
    1991.56, ... % WSIP1
    1993.05, ... % IPOTR1
    1996.26, ... % DSOTR
    1996.39, ... % WSIP2
    1996.68, ... % IP2A
    1997.76, ... % WSIP3
    1997.88, ... % IP2B
];

handles.count = zeros(size(handles.names));
fits = {'Gaussian' 'Asymmetric' 'Super' 'RMS' 'RMS cut peak' 'RMS cut area' 'RMS floor'};
set(handles.popupmenu_fit, 'String', fits);
set(handles.popupmenu_fit, 'Value', 2);

energies = model_energySetPoints;
set(handles.edit_energy, 'String', num2str(energies(end)));

gui_statusDisp(handles, 'Ready.  Add some data to the list.');

% Get default command line output from handles structure
guidata(hObject, handles);
varargout{1} = handles.output;

function handles = update_gui(handles)

% clear handles.xUse handles.yUse;
% clear handles.x handles.y;
% clear handles.xStd handles.yStd;
% clear handles.type handles.valz;
% clear handles.ts handles.mname handles.lookup;
% clear handles.mname handles.filenames handles.listnames;

[handles.x, handles.y, handles.xStd, handles.yStd] = deal([]);
[handles.xUse, handles.yUse] = deal([]);
[handles.type, handles.valz, handles.ts, handles.lookup] = deal([]);
[handles.mname, handles.filenames, handles.listnames] = deal({});

psel = get(handles.popupmenu_plane, 'Value');
pstr = get(handles.popupmenu_plane, 'String');
handles.plane = char(pstr(psel));
switch handles.plane
    case 'x'
        statidx = 3;
    case 'y'
        statidx = 4;
end
method = get(handles.popupmenu_fit, 'Value');

% construct a list of all data loaded so far

if ~isfield(handles, 'dev'), return, end
count = 0;
for ix = 1:numel(handles.dev)

    if isempty(handles.dev(ix).data), continue, end
    for jx = 1:numel(handles.dev(ix).data)

        data = handles.dev(ix).data(jx);
        count = count + 1;

        switch data.name(1:4)
            case {'PROF' 'MIRR' 'OTRS' 'EXPT' 'MIRR'}
                handles.type(count) = 1; % profile monitors are type 1
                plane = 'xy';
                handles.xUse(count) = 1;
                handles.yUse(count) = 1;
            case {'WIRE'}
                handles.type(count) = 2; % wire scanners are type 2
                if data.wireDir.x
                    plane = 'x';
                    handles.xUse(count) = 1; 
                    handles.yUse(count) = 0;
                elseif data.wireDir.y
                    plane = 'y';
                    handles.xUse(count) = 0;
                    handles.yUse(count) = 1;
                elseif data.wireDir.u                    
                    plane = 'u';
                    handles.xUse(count) = 0;
                    handels.yUse(count) = 0;
                else 
                    plane = '';
                    handles.xUse(count) = 0;
                    handels.yUse(count) = 0;
                end
            otherwise
                plane = '';
                handles.xUse(count) = 0;
                handels.yUse(count) = 0;
        end
        
        handles.x(count) = data.beam(method).stats(3);
        handles.y(count) = data.beam(method).stats(4);                
        handles.xStd(count) = data.beam(method).statsStd(3);
        handles.yStd(count) = data.beam(method).statsStd(4);        
        handles.valz(count) = handles.z(ix);
        handles.ts(count) = data.ts;
        handles.mname(count) = {model_nameConvert(data.name, 'MAD')};
        handles.lookup(count,:) = [ix;jx];
        handles.filenames(count) = handles.dev(ix).filename(jx);
        handles.listnames(count) = cellstr(sprintf('%s [%s] -%.2fh', ...
            handles.mname{count}, plane, (now-data.ts)*24));

    end
end

if ~(count >= 1), return, end

set(handles.listbox_data, 'String', handles.listnames);
if count == 1,
    set(handles.listbox_data, 'Value', 1);
end

listbox_data_Callback(handles.listbox_data, [], handles);


function listbox_data_Callback(hObject, eventdata, handles)

% get the data block selected by the listbox
sel = get(hObject, 'Value');
data = handles.dev(handles.lookup(sel,1)).data(handles.lookup(sel,2));
method = get(handles.popupmenu_fit, 'Value');

% only plot wire data if it's for the selected plane
axes(handles.axes_prof);
plane = '';
if strncmpi(data.name, 'WIRE', 4)
    if data.wireDir.x, plane = 'x'; end
    if data.wireDir.u, plane = 'u'; end
    if data.wireDir.y, plane = 'y'; end
    if ~strcmp(plane, handles.plane)
        cla(handles.axes_prof, 'reset');
        title(sprintf('No %s data available in this file', handles.plane));
        guidata(hObject, handles);
        return;
    end
end

beamAnalysis_profilePlot(data.beam(method), handles.plane, ...
    'axes', handles.axes_prof);
title(handles.axes_prof, handles.filenames(sel), 'interpreter', 'none');
axis tight;

guidata(hObject, handles);


function listbox_data_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = add_data(handles, data, fn)

% check that it's either profmon or wirescan data
if ~(strncmpi(fn, 'ProfMon', 7) || strncmpi(fn, 'WireScan', 8))
    gui_statusDisp(handles, 'Profmon or Wirescan data only');
    return
end

% check that it's one of the WS or PROF we know about
iname = find(strcmp(handles.pvroots, data.name)); %#ok<EFIND>
if isempty(iname)
    gui_statusDisp(handles, sprintf('%s is unknown', data.name));
    return
end

% add beam stats to profile monitor images (wires already have this data)
if strncmpi(fn, 'Profmon', 7)
    data.beam = profmon_process(data, 'doPlot', 0);
end

% if all good, store the data
idx = handles.count(iname) + 1;
handles.dev(iname).data(idx) = data;
handles.dev(iname).filename(idx) = cellstr(fn);
handles.count(iname) = idx;
gui_statusDisp(handles, sprintf('Loaded %s', char(fn)));

% update the GUI
handles = update_gui(handles);


function pushbutton_load_Callback(hObject, eventdata, handles)


% propmt user to load data
[data, fn, pn] = util_dataLoad();
if isempty(data), return, end

% add it to the GUI
handles = add_data(handles, data, fn);

guidata(hObject, handles);

function pushbutton_delete_Callback(hObject, eventdata, handles)

sel = get(handles.listbox_data, 'Value');
lookup = handles.lookup(sel,:);
handles.dev(lookup(1)).data(lookup(2)) = [];
handles.dev(lookup(1)).filename(lookup(2)) = [];
handles.count(lookup(1)) = handles.count(lookup(1)) - 1;
if ~(sel == 1)
set(handles.listbox_data, 'Value', sel-1);
end
handles = update_gui(handles);
guidata(hObject, handles);


function popupmenu_fit_Callback(hObject, eventdata, handles)
handles = update_gui(handles);

function popupmenu_fit_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_plot_Callback(hObject, eventdata, handles)

ax = handles.axes_plot;
handles = fit_and_plot(handles, ax);
guidata(hObject, handles);


function handles = fit_and_plot(handles, ax)

%update the GUI right quick
handles = update_gui(handles);

plane = handles.plane;
switch plane
    case {'x'}
        use = find(handles.xUse);
        rawdata = handles.x(use);
        rawdataStd = handles.xStd(use);
    case {'y'}
        use = find(handles.yUse);
        rawdata = handles.y(use);
        rawdataStd = handles.yStd(use);
end

z = handles.valz(use);
type = handles.type(use);
isProf = (type == 1);
isWire = (type == 2);

do_eta = get(handles.checkbox_eta, 'Value');
dE = str2double(get(handles.edit_eta, 'String')) / 100;
do_size = get(handles.checkbox_wiresize, 'Value');
diam = str2double(get(handles.edit_wiresize, 'String'));

data = rawdata;
dataStd = rawdataStd;

[eta, etats, deta, detats] = deal(zeros(numel(use), 1));

for ix = 1:numel(use)
    
    if do_size && isWire(ix)
        corr_size = real(sqrt(data(ix)^2 - (diam/4)^2));
        data(ix) = corr_size;
    end
    
    if do_eta

        % get the timestamp of this dataset
        ts = handles.ts(use(ix));
        name = handles.mname{use(ix)};
        gui_statusDisp(handles, sprintf(...
            'Retrieving dispersion measurement for %s at %s', ...
            name, datestr(ts)));

        % get the archived eta, deta at that time
        pvs = strcat(model_nameConvert(name, 'EPICS)'), ...
            {':ETA_'; ':DETA_'}, upper(plane));
        
        ts1 = ts - 1/(24*60); % bracket 1 minute before
        
        [hist_ts, hist_val] = getHistory(pvs{1}, ...
            {datestr(ts1, 'mm/dd/yyyy HH:MM:SS') ...
             datestr(ts, 'mm/dd/yyyy HH:MM:SS')});
         eta(ix) = hist_val(end);
         etats(ix) = hist_ts(end);

        [hist_ts, hist_val] = getHistory(pvs{2}, ...
            {datestr(ts1, 'mm/dd/yyyy HH:MM:SS') ...
             datestr(ts, 'mm/dd/yyyy HH:MM:SS')});
         deta(ix) = hist_val(end);
         detats(ix) = hist_ts(end);
% 
%          etime(datevec(ts), datevec(etats))
%          etime(datevec(ts), datevec(detats))
        
        % calculate the dispersive spot size contribution
        sig_E(ix) = eta(ix) * 1000 * dE; % eta is in mm, dE/E is in %
        dsig_E(ix) = deta(ix) * 1000 * dE;
        
        etacorr(ix) = real(sqrt(data(ix)^2 - sig_E(ix)^2));
        etacorrStd(ix) = dataStd(ix);  % fix this

        data(ix) = etacorr(ix);
        dataStd(ix) = etacorrStd(ix);
    end
        
end

% fit the beam size data squared to a parabola
zFit = linspace(min(handles.z), max(handles.z), 200);

[par, dFit, parStd, dFitStd, mse, pcov, rfe] = ...
    util_parabFit(z, data .^ 2, 2 * data .* dataStd, zFit);

% plot the fit
axes(ax);
cla(ax, 'reset');  hold all;
util_errorBand(zFit, real(sqrt(dFit)), 0.5 * dFitStd ./ real(sqrt(dFit)), ...
    'Color', [0 0.5 0]); % ?

% plot the raw data
errorbar(z, rawdata, rawdataStd, '.', 'Color', [0.5 0.5 0.5]);
h = errorbar(z, data, dataStd, 'k.');

plot(z(isWire), data(isWire), 'bo', 'MarkerFaceColor', 'b');
plot(z(isProf), data(isProf), 'ro', 'MarkerFaceColor', 'r');

% % errorbar(z(isWire), data(isWire), dataStd(isWire), 'bo');
% % errorbar(z(isProf), data(isProf), dataStd(isProf), 'ro');
% plot_bars(z(isWire), data(isWire), dataStd(isWire), 'bo', 'b');
% plot_bars(z(isProf), data(isProf), dataStd(isProf), 'ro', 'r');
% 

xlabel('Z position [m]');
ylabel(sprintf('\\sigma_%s [\\mum]', handles.plane), ...
    'Interpreter', 'tex');
% axis tight;

% label the raw data
if get(handles.checkbox_annotate, 'Value')
    for ix = 1:numel(use)
        lims = ylim(handles.axes_plot);
        if isWire(ix), color = 'b'; elseif isProf(ix), color = 'r'; end
        if do_eta
        h = text(z(ix), data(ix), sprintf('  %s\n  %s\n  %s\n  \\eta = %.2f', ...
            handles.mname{use(ix)}, datestr(handles.ts(use(ix)), 'mm/dd'), ...
            datestr(handles.ts(use(ix)), 'HH:MM'), eta(ix)), ...
                'FontSize', 10,  ...
                'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
                'Color', color);
        else
        h = text(z(ix), data(ix), sprintf('  %s\n  %s\n  %s', ...
            handles.mname{use(ix)}, datestr(handles.ts(use(ix)), 'mm/dd'), ...
            datestr(handles.ts(use(ix)), 'HH:MM')), ...
                'FontSize', 10,  ...
                'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
                'Color', color);
        end
    end
end
axis tight;

% plot the waist location
waist = par(2);
waistStd = parStd(2);
w0 = waist;
wh = waist+waistStd;
wl = waist-waistStd;
lim = xlim(handles.axes_plot);
ver_line(waist, 'm-');
if (wh >= lim(1)) && (wh <= lim(2)), ver_line(wh, 'm--'); end
if (wl >= lim(1)) && (wl <= lim(2)), ver_line(wl, 'm--'); end
text(0.95, 0.97, sprintf('%s waist @ %.4f \\pm %.4f', upper(plane), waist, waistStd),...
    'Interpreter', 'tex', 'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', 'Units', 'normalized', 'FontSize', 12);

% calculate the emittance
m_e = 0.511; % MeV
E_end = str2double(get(handles.edit_energy, 'String'));
A = par(1); B = par(2); C = par(3);
Astd = parStd(1); Bstd = parStd(2); Cstd = parStd(3);
emit = sqrt(A) * sqrt(C) * E_end * 1e3 / m_e * 1e-6;
S1 = sqrt(A) * 0.5 * Astd / A; S2 = sqrt(C) * 0.5 * Cstd / C;
emitStd = emit * sqrt( (S1/sqrt(A))^2 + (S2/sqrt(C))^2);
text(0.05, 0.95, ...
    sprintf(['\\epsilon_%s = %.2f \\pm %.2f cm-mrad\n' ...
             '\\sigma_%s = %.2f \\pm %.2f \\mum'], ...
    plane, emit/10, emitStd/10, plane, sqrt(C), S2 ),...
    'Interpreter', 'tex', 'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', 'Units', 'normalized', 'FontSize', 12);

% make a title
if do_eta, etastr = sprintf('| \\DeltaE/E = %.4f', dE); else etastr = ''; end
if do_size, wirestr = sprintf('| D_{wire} = %.1f \\mum', diam); else wirestr = ''; end
title(sprintf('FACET %s Waist %s %s', upper(plane), etastr, wirestr), 'Interpreter', 'tex');


function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
h = get(hObject, 'SelectedObject');


function popupmenu_plane_Callback(hObject, eventdata, handles)
sel = get(hObject, 'Value');
str = get(hObject, 'String');
handles.plane = char(str(sel));
handles = update_gui(handles);
guidata(hObject, handles);

function popupmenu_plane_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_latest_Callback(hObject, eventdata, handles)

% get XRMS and YRMS data and timestamps from PVs
xpvs = strcat(handles.pvroots, ':XRMS');
ypvs = strcat(handles.pvroots, ':YRMS');

[xrms, xts] = lcaGetSmart(xpvs);
[yrms, yts] = lcaGetSmart(ypvs);

% convert the PV timestamps to some numerical and string formats
xtime = datevec(lca2matlabTime(xts));
ytime = datevec(lca2matlabTime(yts));

[xdate, xhms] = deal(cell(size(xtime,1), 1));
xsec = zeros(size(xtime,1), 1);
for ix = 1:size(xtime,1)
    xdate(ix) = cellstr(sprintf('%d-%02d-%02d', ...
        xtime(ix,1), xtime(ix,2), xtime(ix,3)));
    xhms(ix) = cellstr(sprintf('%02d%02d%02d', ...
        xtime(ix,4), xtime(ix,5), floor(xtime(ix,6))));
    xsec(ix) = 3600*xtime(ix,4) + 60*xtime(ix,5) + xtime(ix,6);
end

[ydate, yhms] = deal(cell(size(ytime,1), 1));
ysec = zeros(size(ytime,1), 1);
for ix = 1:size(ytime,1)
    ydate(ix) = cellstr(sprintf('%d-%02d-%02d', ...
        ytime(ix,1), ytime(ix,2), ytime(ix,3)));
    yhms(ix) = cellstr(sprintf('%02d%02d%02d', ...
        ytime(ix,4), ytime(ix,5), floor(ytime(ix,6))));
    ysec(ix) = 3600*ytime(ix,4) + 60*ytime(ix,5) + ytime(ix,6);
end

% find the unique days and list all files from those days
dates = unique([xdate; ydate]);
[years, rem] = strtok(dates, '-');
[months, rem] = strtok(rem, '-');
days = strtok(rem, '-');

%pathroot = getenv('$MATLABDATAFILES');  % this is broken
paths = strcat('/u1/facet/matlab/data', ...
                '/', years, ...
                '/', years, '-', months, ...
                '/', years, '-', months, '-', days, '/');

filenames = {}; filepaths = {};
for ix = 1:numel(paths)
    [status, fn] = unix(sprintf('ls %s', paths{ix}));
    fn = textscan(fn, '%s');
    fn = fn{:};
    filenames = [filenames; fn];
    filepaths = [filepaths; strcat(paths(ix), fn)];
end

% parse the file names and extract timestamps
[ftype,rem] = strtok(filenames, '-');
ok = find(strcmpi(ftype, 'Wirescan') | strcmpi(ftype, 'Profmon'));

[fpvu,rem] = strtok(rem, '-');  fpv = strrep(fpvu, '_', ':');
[fyear,rem] = strtok(rem, '-');
[fmonth,rem] = strtok(rem, '-');
[fday,rem] = strtok(rem, '-');
[fhms,rem] = strtok(rem, '-');

for ix = 1:numel(ok)
    fvec(ix, 1) = str2int(fyear{ok(ix)});
    fvec(ix, 2) = str2int(fmonth{ok(ix)});
    fvec(ix, 3) = str2int(fday{ok(ix)});
    fvec(ix, 4:6) = sscanf(fhms{ok(ix)}, '%2d%2d%2d.mat');
end

ftime = datenum(fvec);
% for ix = 1:numel(ftime)
%     fprintf(1, '%s %s\n', datestr(ftime(ix)), filenames{ok(ix)});
% end

% now find the file nearest each PV's timestamp

xt = datenum(xtime);
yt = datenum(ytime);

for ix = 1:numel(xpvs)
    thispv = strcmpi(fpv(ok), handles.pvroots(ix));
    dtime = xt(ix) - ftime;
    dtime(~thispv) = Inf;
    [d, index] = min(abs(dtime));
    xfilenames(ix) = filenames(ok(index));
    xfilepaths(ix) = filepaths(ok(index));
    
end

for ix = 1:numel(ypvs)
    thispv = strcmpi(fpv(ok), handles.pvroots(ix));
    dtime = yt(ix) - ftime;
    dtime(~thispv) = Inf;
    [d, index] = min(abs(dtime));
    yfilenames(ix) = filenames(ok(index));
    yfilepaths(ix) = filepaths(ok(index));
end

% for ix = 1:numel(yt)
%     fprintf(1, '%s %s\n', datestr(yt(ix)), yfiles{ix});
% end

% now load all the identified files!

allpaths = [xfilepaths'; yfilepaths'];
allfiles = [xfilenames'; yfilenames'];
[d, order] = unique(allfiles);

allfilenames = allfiles(order);
allfilepaths = allpaths(order);

for ix = 1:numel(allfilepaths)
    clear d;
    d = load(allfilepaths{ix});
    handles = add_data(handles, d.data, allfilenames{ix});
end

guidata(hObject, handles);


function checkbox_annotate_Callback(hObject, eventdata, handles)


function checkbox_eta_Callback(hObject, eventdata, handles)


function edit_energy_Callback(hObject, eventdata, handles)


function edit_energy_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_print_Callback(hObject, eventdata, handles)

f = figure();
ax = axes();
handles = fit_and_plot(handles, ax);
util_printLog(f);
guidata(hObject, handles);

function edit_eta_Callback(hObject, eventdata, handles)


function edit_eta_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_wiresize_Callback(hObject, eventdata, handles)


function edit_wiresize_Callback(hObject, eventdata, handles)


function edit_wiresize_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


