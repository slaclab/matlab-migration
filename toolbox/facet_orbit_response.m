function varargout = facet_orbit_response(varargin)
% FACET_ORBIT_RESPONSE M-file for facet_orbit_response.fig
%      FACET_ORBIT_RESPONSE, by itself, creates a new FACET_ORBIT_RESPONSE or raises the existing
%      singleton*.
%
%      H = FACET_ORBIT_RESPONSE returns the handle to a new FACET_ORBIT_RESPONSE or the handle to
%      the existing singleton*.
%
%      FACET_ORBIT_RESPONSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_ORBIT_RESPONSE.M with the given input arguments.
%
%      FACET_ORBIT_RESPONSE('Property','Value',...) creates a new FACET_ORBIT_RESPONSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_orbit_response_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_orbit_response_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_orbit_response

% Last Modified by GUIDE v2.5 02-May-2012 20:21:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_orbit_response_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_orbit_response_OutputFcn, ...
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


% --- Executes just before facet_orbit_response is made visible.
function facet_orbit_response_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_orbit_response (see VARARGIN)

% Choose default command line output for facet_orbit_response
handles.output = hObject;
handles.appName = 'facet_orbit_response';
set(hObject, 'Toolbar', 'figure');
handles.saved = 0;

handles.ratepv = {'EVNT:SYS1:1:SCAVRATE' 'EVNT:SYS1:1:BEAMRATE'};
handles.bpmds  = {'8' '57'};
handles.dgrps  = {'ELECEP01' 'NDRFACET'};
handles.beams  = {'SCAV' 'FACET'};

handles.plots = {'x response' 'y response' 'x diff' 'y diff' 'tmit diff' 'x ref' 'y ref' 'tmit ref'};
handles.plot = 3;
set(handles.popupmenu_plot, 'String', handles.plots);
set(handles.popupmenu_plot, 'Value', handles.plot);

handles.regions = { 'LI05-LI06';
                    'LI19-LI20'};
handles.micros  = {{'LI04' 'LI05' 'LI06'};
                   {'LI18' 'LI19' 'LI20'}};
handles.allcors = { model_nameRegion({'XCOR' 'YCOR'}, {'LI05' 'LI06'});
                    model_nameRegion({'XCOR' 'YCOR'}, {'LI19' 'LI20'})};
handles.allbpms = { model_nameRegion('BPMS', handles.micros{1});
                    model_nameRegion('BPMS', handles.micros{2})};
maglist = {'BEND' 'BTRM' 'BNDS' 'KICK' 'QUAD' 'QTRM' 'QUAS' 'XCOR' 'YCOR' 'SEXT' 'SXTS'};
handles.allmags = { model_nameRegion(maglist, handles.micros{1})
                    model_nameRegion(maglist, handles.micros{2})};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes facet_orbit_response wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function handles = update_config(handles)

set(handles.popupmenu_region, 'Value', handles.config.region);
handles = update_region(handles);
set(handles.popupmenu_corselect, 'Value', handles.config.corselect);
% set(handles.listbox_bpms, 'Value', handles.config.bpmselect);
set(handles.popupmenu_beam, 'Value', handles.config.beam);
set(handles.checkbox_autorange, 'Value', handles.config.autorange);
set(handles.edit_automax, 'String', sprintf('%f', handles.config.automax));
set(handles.edit_minbdes, 'String', sprintf('%f', handles.config.minbdes));
set(handles.edit_maxbdes, 'String', sprintf('%f', handles.config.maxbdes));
set(handles.edit_nstep, 'String', sprintf('%d', handles.config.nstep));
set(handles.edit_nsamp, 'String', sprintf('%d', handles.config.nsamp));

function handles = update_region(handles)

set(handles.popupmenu_region, 'String', handles.regions);
set(handles.popupmenu_region, 'Value', handles.config.region);
[handles.mags.name, handles.mags.z] = get_by_z(handles.allmags{handles.config.region});

corrlist = handles.allcors{handles.config.region};
bpmslist = handles.allbpms{handles.config.region};
set(handles.popupmenu_corselect, 'String', corrlist);
set(handles.listbox_bpms, 'String', bpmslist);
set(handles.popupmenu_corselect, 'Value', 1);
set(handles.listbox_bpms, 'Value', 1:numel(bpmslist));


function [list, z] = get_by_z(devs)

z0 = lcaGetSmart(strcat(devs, ':Z'));
% z0 = model_rMatGet(devs, [], {'TYPE=DESIGN' 'MODE=1'}, 'Z');
[z, ix] = sort(z0);
list = model_nameConvert(devs(ix'), 'SLC');


function handles = update_gui(handles)

corrlist = handles.allcors{handles.config.region};
bpmslist = handles.allbpms{handles.config.region};

% get bpm and corrector selection
handles.config.corselect = get(handles.popupmenu_corselect, 'Value');
handles.config.bpmselect = get(handles.listbox_bpms, 'Value');
handles.corr.name = char(corrlist(get(handles.popupmenu_corselect, 'Value')));
handles.bpms.name = bpmslist(get(handles.listbox_bpms, 'Value'));
handles.bpms.use = handles.config.bpmselect';

switch char(model_nameSplit(model_nameConvert(handles.corr.name, 'SLC')))
    case 'XCOR'
        handles.config.plane = 'x';
    case 'YCOR'
        handles.config.plane = 'y';
end

% get bpm and corrector locations
handles.corr.z = control_deviceGet(handles.corr.name, 'Z');
handles.bpms.z = control_deviceGet(handles.bpms.name, 'Z');

% get rates
set(handles.popupmenu_beam, 'String', handles.beams);
handles.rates = lcaGetSmart(handles.ratepv);
% [handles.rate, handles.beam] = max(handles.rate);
handles.config.beam = get(handles.popupmenu_beam, 'Value');
handles.config.rate = handles.rates(handles.config.beam);
handles.config.bpmd = handles.bpmds{handles.config.beam};
set(handles.edit_rate, 'String', sprintf('%d Hz', handles.config.rate));

% get options
handles.config.autorange    = get(handles.checkbox_autorange, 'Value');
handles.config.automax      = str2double(get(handles.edit_automax, 'String'));
handles.config.minbdes      = str2double(get(handles.edit_minbdes, 'String'));
handles.config.maxbdes      = str2double(get(handles.edit_maxbdes, 'String'));
handles.config.nstep        = str2int(get(handles.edit_nstep, 'String'));
handles.config.nsamp        = str2int(get(handles.edit_nsamp, 'String'));

% do auto-ranging if selected
if handles.config.autorange
    [handles.config.minbdes, handles.config.maxbdes, orbits] = auto_bdes(handles);
    set(handles.edit_minbdes, 'String', sprintf('%.3f', handles.config.minbdes), 'Enable', 'off');
    set(handles.edit_maxbdes, 'String', sprintf('%.3f', handles.config.maxbdes), 'Enable', 'off');
    cla(handles.axes1, 'reset');    
    hold(handles.axes1, 'all');
    plot(handles.axes1, handles.bpms.z, zeros(size(handles.bpms.z)), 'b-');
    plot(handles.axes1, handles.bpms.z, orbits);
    xlabel('Z (m)');
    ylabel(sprintf('%s Orbit (mm)', upper(handles.config.plane)));
    title('Expected DIFF orbits using auto-range');
    axis(handles.axes1, 'tight');
else
    set(handles.edit_minbdes, 'Enable', 'on');
    set(handles.edit_maxbdes, 'Enable', 'on');
end


function [minbdes, maxbdes, orbits] = auto_bdes(handles)
% brackets corrector BDES for +/- maximum orbit in bpmlist

global modelSource;
modelSource = 'SLC';
modelparam = {'MODE=1' 'TYPE=DATABASE'};

% get model
leff = model_rMatGet(handles.corr.name, [], modelparam, 'LEFF');
rmat = model_rMatGet(handles.corr.name, handles.bpms.name, modelparam, 'R');
engy = model_rMatGet(handles.corr.name, [], modelparam, 'EN');
Bp = 33.356 * engy;

% find which corrector plane is selected
planes = {'x' 'xp' 'y' 'yp' 's' 'E'}';
row = strmatch(handles.config.plane, planes, 'exact');

% extract RMAT columns for that plane
response = squeeze(rmat(row,:,:));
isbefore = (handles.bpms.z <= handles.corr.z)';
response = response .* ~repmat(isbefore, [6 1]);  % enforce causality

% predicted orbit is just r12 (or r34) - normalized so e.g. mm per mrad
orbit = response(row + 1,:);

% rescale that orbit to user request
rescale = handles.config.automax / max(abs(orbit));
scale = linspace(-rescale, rescale, handles.config.nstep)';

% calculate corrector kicks to achieve the rescaled orbit
thetas = 1e-3 * scale;
dbdes = thetas * Bp;

% calculate a new set of rescaled orbits
orbits = scale * orbit;

% calculate new corrector values
bdes0 = control_deviceGet(handles.corr.name, 'BDES');
bmax  = control_deviceGet(handles.corr.name, 'BMAX');
bdes = bdes0 + dbdes;

% output corrector min/max
minbdes = min(bdes);
maxbdes = max(bdes);


% --- Outputs from this function are returned to the command line.
function varargout = facet_orbit_response_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



gui_statusDisp(handles, 'Loading...');

handles.config = util_configLoad(handles.appName);
handles = update_config(handles);
handles = update_gui(handles);
% 
% set(handles.popupmenu_corselect, 'Value', handles.config.corselect);
% set(handles.listbox_bpms, 'Value', handles.config.bpmselect);
% set(handles.popupmenu_beam, 'Value', handles.config.beam);
% set(handles.edit_minbdes, 'String', sprintf('%f', handles.config.minbdes));
% set(handles.edit_minbdes, 'String', sprintf('%f', handles.config.maxbdes));
% set(handles.edit_nstep, 'String', sprintf('%d', handles.config.nstep));
% set(handles.edit_nsamp, 'String', sprintf('%d', handles.config.nsamp));
% set(handles.checkbox_autorange, 'Value', handles.config.autorange);
% set(handles.edit_automax, 'String', sprintf('%f', handles.config.automax));
% 
% handles = update_gui(handles);
gui_statusDisp(handles, 'GUI Loaded.  Select a corrector to scan.');
guidata(hObject, handles);

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_bpms.
function listbox_bpms_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_bpms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns listbox_bpms contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_bpms


% --- Executes during object creation, after setting all properties.
function listbox_bpms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_bpms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_acquire.
function pushbutton_acquire_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_acquire (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'String', 'Acquiring...', 'Enable', 'off');
set(handles.pushbutton_abort, 'Enable', 'on');
abort = 0;

% clear saved flag
handles.saved = 0;

% get lattice
[handles.mags.BDES, handles.mags.BACT, handles.mags.BMAX, handles.mags.EMOD] = ...
    control_magnetGet(handles.mags.name);

% save config into data struct and construct scan range
handles.data.config = handles.config;
handles.data.mags = handles.mags;
handles.data.corr = handles.corr;
handles.data.bpms = handles.bpms;
handles.data.bdes = linspace(handles.config.minbdes, handles.config.maxbdes, handles.config.nstep);

handles.data.mags

% save timestamp
handles.data.ts = now;

gui_statusDisp(handles, sprintf('Scanning %s from %f to %f ...', ...
    handles.data.corr.name, handles.data.config.minbdes, handles.data.config.maxbdes));

% get reference orbit
gui_statusDisp(handles, sprintf('Acquiring reference orbit on BPMD %s, %d samples ...', ...
        handles.data.config.bpmd, handles.data.config.nsamp)); 
[x, y, tmit, pulseid, stat] = control_bpmAidaGet(handles.data.bpms.name, ...
    handles.data.config.nsamp, handles.data.config.bpmd);

% save reference orbit
handles.data.ref.x = x;
handles.data.ref.y = y;
handles.data.ref.tmit = tmit;
handles.data.ref.pulseid = pulseid;
handles.data.ref.stat = stat;

% save corrector start value

handles.data.binit = control_magnetGet(handles.data.corr.name);
    
% main scan loop 
for ix = 1:handles.data.config.nstep

    % abort if abort button pressed
    if get(handles.pushbutton_abort, 'Value')
        abort = 1;
        gui_statusDisp(handles, 'Aborting...');
        break;
    end

    % set corrector
    gui_statusDisp(handles, sprintf('Setting %s to %f...', handles.data.corr.name, handles.data.bdes(ix)));    
    control_magnetSet(handles.data.corr.name, handles.data.bdes(ix), 'action', 'TRIM', 'wait', 1); 
    
    % get BPM data
    gui_statusDisp(handles, sprintf('Acquiring BPMD %s data %d samples (step %d/%d)', ...
        handles.data.config.bpmd, handles.data.config.nsamp, ix, handles.data.config.nstep)); 
    
    [x, y, tmit, pulseid, stat] = control_bpmAidaGet(handles.data.bpms.name, ...
        handles.data.config.nsamp, handles.data.config.bpmd);

    % save reference orbit
    handles.data.orbit(ix).x = x;
    handles.data.orbit(ix).y = y;
    handles.data.orbit(ix).tmit = tmit;
    handles.data.orbit(ix).pulseid = pulseid;
    handles.data.orbit(ix).stat = stat;
    
    % plot results
    handles = fit_and_plot(handles);

end

gui_statusDisp(handles, sprintf('Resetting %s to initial BDES = %f...', handles.data.corr.name, handles.data.binit));    
control_magnetSet(handles.data.corr.name, handles.data.binit, 'action', 'TRIM', 'wait', 1); 

if abort
    gui_statusDisp(handles, 'Acquisition aborted.');
    set(handles.pushbutton_abort, 'String', 'Abort', 'Value', 0);
else
    gui_statusDisp(handles, 'Acquisition finished.');
end

set(hObject, 'String', 'Acquire', 'Enable', 'on');
set(handles.pushbutton_abort, 'Enable', 'off');

guidata(hObject, handles);


function handles = fit_and_plot(handles, export)

if nargin < 2, export = 0; end

if export
    figure(export);
    ax = axes;
else
    ax = handles.axes1;
end

if ~isfield(handles, 'data'), return; end

if any(handles.plot == [1 2]), plottype = 'response'; end
if any(handles.plot == [3 4 5]), plottype = 'diff'; end
if any(handles.plot == [6 7 8]), plottype = 'ref'; end

if any(handles.plot == [1 3 6]), plane = 'x'; end
if any(handles.plot == [2 4 7]), plane = 'y'; end
if any(handles.plot == [5 8]), plane = 'tmit'; end

cla(ax, 'reset');
hold(ax, 'all');
plotdata = [];

switch plottype
    case 'response'
    case 'diff'
        refavg = mean(handles.data.ref.(plane), 2);
        refstd = std(handles.data.ref.(plane), [], 2);
        titlestr = sprintf('DIFF Orbits %s', datestr(handles.data.ts));
        xstr = 'Z [m]';
        for ix = 1:numel(handles.data.orbit)
            dataavg = mean(handles.data.orbit(ix).(plane), 2);
            datastd = std(handles.data.orbit(ix).(plane), [], 2);
            if strcmp(plane, 'tmit')
                plotdata = [plotdata (dataavg ./ refavg)];
                %                 plotstd = [plotstd (datastd ./ refstd)];
                ystr = 'TMIT/TREF';
            else
                plotdata = [plotdata (dataavg - refavg)];
                ystr = sprintf('%s DIFF Orbits [mm]', upper(plane));
            end
        end
    case 'ref'
        titlestr = sprintf('Orbit REF %s', datestr(handles.data.ts));
        xstr = 'Z [m]';
        ystr = sprintf('%s REF Orbits [mm]', upper(plane));
        plotdata = refavg;
    otherwise
        gui_statusDisp(handles, 'Unsupported plot type selected!');
        return;
end

% pdata = reshape(plotdata, numel(handles.data.bpms.name), numel(handles.data.orbit), []);
% plotavg = mean(pdata, 3);
% plotstd = std(pdata, [], 3);

if ~isempty(plotdata)
    plot(ax, repmat(handles.data.bpms.z, 1, numel(handles.data.orbit)), plotdata,'-');
    title(ax, titlestr);
    xlabel(ax, xstr);
    ylabel(ax, ystr);
    axis(ax, 'tight');
end

if export
    enhance_plot();
end
    
    


% --- Executes on selection change in popupmenu_corselect.
function popupmenu_corselect_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_corselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns popupmenu_corselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_corselect


% --- Executes during object creation, after setting all properties.
function popupmenu_corselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_corselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_minbdes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_minbdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit_minbdes as text
%        str2double(get(hObject,'String')) returns contents of edit_minbdes as a double


% --- Executes during object creation, after setting all properties.
function edit_minbdes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_minbdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_maxbdes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maxbdes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit_maxbdes as text
%        str2double(get(hObject,'String')) returns contents of edit_maxbdes as a double


% --- Executes during object creation, after setting all properties.
function edit_maxbdes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maxbdes (see GCBO)
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


% --- Executes on button press in checkbox_autorange.
function checkbox_autorange_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_autorange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox_autorange


% --- Executes on button press in pushbutton_abort.
function pushbutton_abort_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'String', 'Aborting...');
guidata(hObject, handles);

% --- Executes on button press in pushbutton_print.
function pushbutton_print_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.saved
    pushbutton_save_Callback(hObject, [], handles);
end
exportfig = figure;
handles = fit_and_plot(handles, exportfig);
util_printLog(exportfig);



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


% --- Executes on button press in pushbutton_configSave.
function pushbutton_configSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_configSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    ok = 1;
    util_configSave(handles.appName, handles.config, 0);
catch
    gui_statusDisp(handles, 'Config save failed!');
    ok = 0;
end

if ok
    gui_statusDisp(handles, 'Config saved.');
end


% --- Executes on selection change in popupmenu_region.
function popupmenu_region_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.config.region = get(handles.popupmenu_region, 'Value');
handles = update_region(handles);
handles = update_gui(handles);
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



function edit_rate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rate as text
%        str2double(get(hObject,'String')) returns contents of edit_rate as a double


% --- Executes during object creation, after setting all properties.
function edit_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_automax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_automax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_gui(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_automax as text
%        str2double(get(hObject,'String')) returns contents of edit_automax as a double


% --- Executes during object creation, after setting all properties.
function edit_automax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_automax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_selectall.
function pushbutton_selectall_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selectall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.listbox_bpms, 'Value', 1:numel(get(handles.listbox_bpms, 'String')));
handles = update_gui(handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'data') && ~handles.saved
    try
        ok = 1;
        [filename, pathname] = util_dataSave(handles.data, handles.appName, handles.data.corr.name, handles.data.ts);
    catch
        ok = 0;
        gui_statusDisp(handles, 'Error saving data!');
    end
    
    if ok
        gui_statusDisp(handles, sprintf('Data saved to %s/%s', pathname, filename));
    end
end 

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data = util_dataLoad();
handles.config = handles.data.config;
handles = update_config(handles);
gui_statusDisp(handles, 'Data loaded.');
handles = fit_and_plot(handles);
guidata(hObject, handles);

% --- Executes on selection change in popupmenu_plot.
function popupmenu_plot_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plot = get(hObject, 'Value');
handles.plot
handles = fit_and_plot(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_plot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_plot


% --- Executes during object creation, after setting all properties.
function popupmenu_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


