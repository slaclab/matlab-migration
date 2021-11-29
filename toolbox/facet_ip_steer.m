function varargout = facet_ip_steer(varargin)
% FACET_IP_STEER MATLAB code for facet_ip_steer.fig
%      FACET_IP_STEER, by itself, creates a new FACET_IP_STEER or raises the existing
%      singleton*.
%
%      H = FACET_IP_STEER returns the handle to a new FACET_IP_STEER or the handle to
%      the existing singleton*.
%
%      FACET_IP_STEER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_IP_STEER.M with the given input arguments.
%
%      FACET_IP_STEER('Property','Value',...) creates a new FACET_IP_STEER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_ip_steer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_ip_steer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_ip_steer

% Last Modified by GUIDE v2.5 19-Feb-2016 18:31:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_ip_steer_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_ip_steer_OutputFcn, ...
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


% --- Executes just before facet_ip_steer is made visible.
function facet_ip_steer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_ip_steer (see VARARGIN)

% Choose default command line output for facet_ip_steer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes facet_ip_steer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = facet_ip_steer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

model_init('source', 'MATLAB');
gui_modelSourceControl(hObject,handles,[]);

% configuration
handles.dgrp = 'NDRFACET';

handles.corr.name = {
    'BTRM:LI20:2420'
    'XCOR:LI20:2460'
    'YCOR:LI20:3017'
    'XCOR:LI20:3026'
    'YCOR:LI20:3057'
    'XCOR:LI20:3086'
    'XCOR:LI20:3116'
    'YCOR:LI20:3147'
    'XCOR:LI20:3276'
    };

handles.bpms.name = {
    'BPMS:LI20:2445'
    'BPMS:LI20:3013'
    'BPMS:LI20:3036'
    'BPMS:LI20:3101'
    'BPMS:LI20:3120'
    'BPMS:LI20:3156'
    'BPMS:LI20:3265'
    'BPMS:LI20:3315'
};

% default values
handles.sx = 0.5;
handles.sy = 0.5;
handles.cgain = 1;
handles.tgain = 0.5;

set(handles.edit_svdx, 'String', num2str(handles.sx));
set(handles.edit_svdy, 'String', num2str(handles.sy));
set(handles.edit_cgain, 'String', num2str(handles.cgain));
set(handles.edit_tgain, 'String', num2str(handles.tgain));

set(handles.listbox_corr, 'String', handles.corr.name);
set(handles.listbox_corr, 'Value', 1:numel(handles.corr.name));
set(handles.listbox_bpms, 'String', handles.bpms.name);
set(handles.listbox_bpms, 'Value', 1:numel(handles.bpms.name));

set(handles.text_model, 'String', 'Press "Load Model" to start', ...
    'HorizontalAlignment', 'Left');

handles.corr.use = ones([1 numel(handles.corr.name)]);
handles.bpms.use = ones([1 numel(handles.bpms.name)]);

set(handles.edit_nsamp, 'String', num2str(10));
set(handles.popupmenu_refdir, 'String', ...
    {'NORMAL'; 'SCRATCH'});
set(handles.popupmenu_refdir, 'Value', 1);
set(handles.popupmenu_method, 'String', ...
    {'TRIM';  'PERTURB'});
set(handles.popupmenu_method, 'Value', 1);

% initialize to absolute steering
handles.reforbit = blank_reforbit(handles);

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles);



function ref = blank_reforbit(handles)

% generates an empty reference orbit
ref.x = zeros(size(handles.bpms.name));
ref.y = zeros(size(handles.bpms.name));
ref.tmit = zeros(size(handles.bpms.name));
ref.pid = zeros(size(handles.bpms.name));
ref.stat = zeros(size(handles.bpms.name));
ref.nsamp = 1;
ref.bpms = handles.bpms.name;
ref.dgrp = handles.dgrp;
ref.name = 'ABSOLUTE';
ref.title = '';
ref.ts = now;


function handles = get_model(handles)
% some parameters here
handles.model.source = model_init;
switch handles.model.source 
    case 'SLC'
        model_type = 'DATABASE';
    otherwise
        %model_type = 'DESIGN';
        model_type = 'EXTANT';
end

causal = 1;
decouple = 1;

handles.model.type = model_type;
handles.model.causal = causal;
handles.model.decouple = decouple;

% corr.name = handles.corr.name(handles.corr.use);
corr.name = handles.corr.name;
corr.isX = strncmpi(corr.name, 'XCOR', 4);
corr.isY = strncmpi(corr.name, 'YCOR', 4) | strncmpi(corr.name, 'BTRM', 4);
corr.z = lcaGetSmart(strcat(model_nameConvert(corr.name, 'EPICS'), ':Z'));
nc = numel(corr.name);

% bpms.name = handles.bpms.name(handles.bpms.use);
bpms.name = handles.bpms.name;
[p,m,u] = model_nameSplit(bpms.name);
bpms.z = lcaGetSmart(strcat(m,':',p,':',u,':Z'));
nb = numel(bpms.name);

for ix = 1:nc
    gui_statusDisp(handles, sprintf('Getting %s %s matrix for %s ...', ...
        handles.model.source, model_type, corr.name{ix}));
    r(ix,:,:,:) = model_rMatGet(strrep(corr.name(ix), 'BTRM', 'BNDS'), ...
        bpms.name, sprintf('TYPE=%s', model_type));
end
rmat = permute(r, [1 4 2 3]);
%rmat_raw = rmat;

% enforce causality
if causal
    bz = repmat(bpms.z', nc, 1);
    cz = repmat(corr.z, 1, nb);
    isafter = double(bz > cz);
    rmat = rmat .* repmat(isafter, [1 1 6 6]);
end

% make a corrector mask so XCORs only steer X, etc
cmask = ones(size(rmat));
xonly = [ones(2,6); zeros(4,6)];
yonly = circshift(xonly, [2 0]);
ix = find(corr.isX);  iy = find(corr.isY);
sx = permute(repmat(xonly, [1 1 nb numel(ix)]), [4 3 1 2]);
sy = permute(repmat(yonly, [1 1 nb numel(iy)]), [4 3 1 2]);
cmask(ix,:,:,:) = sx;
cmask(iy,:,:,:) = sy;

rmat = rmat .* cmask;

% enforce transverse decoupling
dmask = ones(size(rmat));
dmask(:,:,1:2,3:4) = 0;
dmask(:,:,3:4,1:2) = 0;

if decouple
    rmat = rmat .* dmask;
end

handles.model.corr = corr;
handles.model.bpms = bpms;
handles.model.rmat = rmat;
handles.model.source = model_init;

handles = invert_model(handles);

function handles = invert_model(handles)

% sx and sy are SVD cut parameters
sx = handles.sx;
sy = handles.sy;

% get the whole raw model
rmat = handles.model.rmat;
rx = rmat(:,:,1,2);
ry = rmat(:,:,3,4);

% initialize a zero response model
rx0 = zeros(size(rx));
ry0 = zeros(size(ry));
rxuse = rx0;
ryuse = ry0;

% build a matrix of flags for which entries in the real model to use
usec = double(handles.corr.use);
useb = double(handles.bpms.use);
use = usec' * useb;

% make the response matrix only for active devices
rxuse = rx0 + use .* rx;
ryuse = ry0 + use .* ry;

% do the SVD inversion
[u,s,v] = svd(rxuse);
n = numel(diag(s)); m = ceil(n * sx);
s(m:end, m:end) = 0;
disp('SVD terms (x):');
disp(diag(s)');
rx_i = (v * pinv(s) * u')';

[u,s,v] = svd(ryuse);
n = numel(diag(s)); m = ceil(n * sy);
s(m:end, m:end) = 0;
disp('SVD terms (y):');
disp(diag(s)');
ry_i = (v * pinv(s) * u')';

handles.model.rx = rx;
handles.model.ry = ry;
handles.model.rx_i = rx_i;
handles.model.ry_i = ry_i;

% --- Executes on button press in modelSource_btn.
function modelSource_btn_Callback(hObject, eventdata, handles)
% hObject    handle to modelSource_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=gui_modelSourceControl(hObject,handles,[]);
gui_modelSourceControl(hObject,handles,mod(val,3)+1);

% --- Executes on button press in pushbutton_plotmodel.
function pushbutton_plotmodel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plotmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% handles.corr.use = get(handles.listbox_corr, 'Value');
% handles.bpms.use = get(handles.listbox_bpms, 'Value');

str = get(hObject, 'String');
set(hObject, 'String', 'Loading...');
drawnow;

handles = get_model(handles);

rx = handles.model.rx;
ry = handles.model.ry;
rx_i = handles.model.rx_i;
ry_i = handles.model.ry_i;

model_type = handles.model.type;
model_source = handles.model.source;
    
clim = [-40 40];
% plot R12, R34 and inverse
subplot(2,2,1, 'Parent', handles.uipanel_plot);
cla reset;  hold all;
imagesc(rx);  caxis(clim);  axis tight;  xlabel ('BPM #');  ylabel('Corr #');
for ix = 1:size(rx, 1)
    for jx = 1:size(rx, 2)
        if rx(ix,jx) >= 0
        text(jx,ix, sprintf('%.0f', abs(rx(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'k');
        else
            text(jx,ix, sprintf('%.0f', abs(rx(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'w');
        end
    end
end
title(sprintf('R_x %s (%s)', model_type, model_source));
subplot(2,2,2, 'Parent', handles.uipanel_plot);
cla reset;  hold all;
% subplot(222);
imagesc(ry);  caxis(clim);  axis tight;  xlabel ('BPM #');
for ix = 1:size(ry, 1)
    for jx = 1:size(ry, 2)
        if ry(ix,jx) >= 0
        text(jx,ix, sprintf('%.0f', abs(ry(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'k');
        else
            text(jx,ix, sprintf('%.0f', abs(ry(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'w');
        end
    end
end
title(sprintf('R_y %s (%s)', model_type, model_source));


clim = [-1 1];
% subplot(223);
subplot(2,2,3, 'Parent', handles.uipanel_plot);
cla reset;  hold all;
imagesc(rx_i);  axis tight;  xlabel ('BPM #');  ylabel('Corr #');
for ix = 1:size(rx_i, 1)
    for jx = 1:size(rx_i, 2)
        if rx_i(ix,jx) >= 0
        text(jx,ix, sprintf('%.2f', abs(rx_i(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'k');
        else
            text(jx,ix, sprintf('%.2f', abs(rx_i(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'w');
        end
    end
end
title(sprintf('inv(R_x) cut = %.2f', handles.sx));
subplot(2,2,4, 'Parent', handles.uipanel_plot);
cla reset;  hold all;
% subplot(224);
imagesc(ry_i);  axis tight;  xlabel ('BPM #');
for ix = 1:size(ry_i, 1)
    for jx = 1:size(ry_i, 2)
        if ry_i(ix,jx) >= 0
        text(jx,ix, sprintf('%.2f', abs(ry_i(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'k');
        else
            text(jx,ix, sprintf('%.2f', abs(ry_i(ix,jx))), ...
            'FontSize', 8, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'cap', 'Color', 'w');
        end
    end
end
title(sprintf('inv(R_y) cut = %.2f', handles.sy));

modeltime = now;
xwaist = lcaGetSmart('SIOC:SYS1:ML00:SO0351');  handles.model.xwaist = xwaist;
xbeta = lcaGetSmart('SIOC:SYS1:ML00:AO352');    handles.model.xbeta = xbeta;
ywaist = lcaGetSmart('SIOC:SYS1:ML00:SO0353');  handles.model.ywaist = ywaist;
ybeta = lcaGetSmart('SIOC:SYS1:ML00:AO354');    handles.model.ybeta = ybeta;

modeltxt = sprintf('%s\nX: %s %.3f m\nY: %s %.3f m', ...
    datestr(modeltime), char(xwaist), xbeta, char(ywaist), ybeta);
set(handles.text_model, 'String', modeltxt, 'ForegroundColor', 'black');

gui_statusDisp(handles, 'Model loaded.');

set(hObject, 'String', str);
guidata(hObject, handles);


% --- Executes on selection change in listbox_corr.
function listbox_corr_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_corr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_corr
vals = get(hObject, 'Value');
ncorr = numel(get(hObject, 'String'));
handles.corr.use = ismember(1:ncorr, vals);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox_corr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_bpms.
function listbox_bpms_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_bpms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_bpms contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_bpms
vals = get(hObject, 'Value');
nbpms = numel(get(hObject, 'String'));
handles.bpms.use = ismember(1:nbpms, vals);
guidata(hObject, handles);

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

str = get(hObject, 'String');
set(hObject, 'String', 'Acquiring...');
drawnow;

nsamp = str2int(get(handles.edit_nsamp, 'String'));
dgrp = handles.dgrp;
bpms = handles.bpms.name;
corr = handles.corr.name;
ts = now;

fakedata = get(handles.checkbox_fake, 'Value');

if ~fakedata
    % block below commented out for testing
    gui_statusDisp(handles, sprintf('Acquiring %d samples...', nsamp));
    [orbit.x, orbit.y, orbit.tmit, orbit.pid, orbit.stat] = ...
        control_bpmAidaGet(bpms, nsamp, dgrp);
    gui_statusDisp(handles, 'Orbit acquisition done.');
    
    orbit.nsamp = nsamp;
    orbit.dgrp = dgrp;
    orbit.bpms = bpms;
    orbit.name = '';
    orbit.title = '';
    orbit.ts = ts;
else
    % gets fake data from a scratch orbit
    nbpms = numel(bpms);
    refd =  strcat('BPM_', dgrp);
    refnum = 3866;
    refdir = 'SCRATCH';
    
    ref = scp_loadBPMData(3866, 'SCRATCH', 'BPM_NDRFACET');
    for ix = 1:nbpms
        ibpm(ix) = find(strcmp(bpms(ix), ref.name));
    end
    orbit.x = ref.X(ibpm);
    orbit.y = ref.Y(ibpm);
    orbit.tmit = ref.TMIT(ibpm);
    orbit.pid = zeros(size(ibpm));
    orbit.stat = ref.STAT(ibpm);
    orbit.nsamp = ref.navg;
    orbit.bpms = bpms;
    orbit.dgrp = handles.dgrp;
    orbit.name = strcat(refd, ' ', refdir, ' ', num2str(refnum));
    orbit.title = '';
    orbit.ts = now;
    gui_statusDisp(handles, sprintf('Loaded %s %d from %s as live data', refdir, refnum, refd));
    % block above does pretend acquisition with a scratch saved orbit,
    % comment for live data
end

handles.orbit = orbit;

set(hObject, 'String', str);
guidata(hObject, handles);


function edit_nsamp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_nsamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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



function edit_svdx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_svdx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_svdx as text
%        str2double(get(hObject,'String')) returns contents of edit_svdx as a double


% --- Executes during object creation, after setting all properties.
function edit_svdx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_svdx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_svdy_Callback(hObject, eventdata, handles)
% hObject    handle to edit_svdy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_svdy as text
%        str2double(get(hObject,'String')) returns contents of edit_svdy as a double


% --- Executes during object creation, after setting all properties.
function edit_svdy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_svdy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_calc.
function pushbutton_calc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check model is current
xwaist = lcaGetSmart('SIOC:SYS1:ML00:SO0351');  
xbeta = lcaGetSmart('SIOC:SYS1:ML00:AO352');
ywaist = lcaGetSmart('SIOC:SYS1:ML00:SO0353');
ybeta = lcaGetSmart('SIOC:SYS1:ML00:AO354');

if (~strcmp(xwaist, handles.model.xwaist) || ...
    ~strcmp(ywaist, handles.model.ywaist) || ...
    xbeta ~= handles.model.xbeta || ...
    ybeta ~= handles.model.ybeta)
    warndlg(sprintf(['Hey dummy, it looks like the current IP waist ' ...
        'configuration\ndoes not match the model.  ' ...
        'You should probably load a fresh model']), 'Model needs updating', ...
        'modal');
    set(handles.text_model, 'ForegroundColor', 'red');
end

handles.sx = str2double(get(handles.edit_svdx, 'String'));
handles.sy = str2double(get(handles.edit_svdy, 'String'));
handles.cgain = str2double(get(handles.edit_cgain, 'String'));
cgain = handles.cgain;

% use the orbit acquired previously
orbit = handles.orbit;
reforbit = handles.reforbit;
corr = handles.model.corr;
bpms = handles.model.bpms;

% calculate difference orbit to reference
x = mean(orbit.x,2);        y = mean(orbit.y,2);
xstd = std(orbit.x,[],2);   ystd = std(orbit.y,[],2);
xref = reforbit.x;          yref = reforbit.y;
xdif = x - xref;            ydif = y - yref;

switch orbit.dgrp
    case 'NDRFACET'
        q = 1;
    case 'SDRFACET'
        q = -1;
    otherwise
        q = 0;
end

% calculate the inverted response matrix
handles = invert_model(handles);
rx_i = handles.model.rx_i;
ry_i = handles.model.ry_i;
rx = handles.model.rx;
ry = handles.model.ry;

% get kicks (angle) at the correctors
xc = (-rx_i * xdif * cgain * q);
yc = (-ry_i * ydif * cgain * q);

% calculate orbit change from the new corrector kicks
dx = (xc' * rx)';  dy = (yc' * ry)';

% convert kick angles to changes in bdes
corr.bdes = lcaGetSmart(strcat(model_nameConvert(corr.name, 'EPICS'), ':BDES'));
corr.bmax = lcaGetSmart(strcat(model_nameConvert(corr.name, 'EPICS'), ':BMAX'));
corr.emod = lcaGetSmart(strcat(model_nameConvert(corr.name, 'EPICS'), ':EMOD'));
eend = lcaGetSmart('VX00:LEMG:5:EEND');
zend = lcaGetSmart('VX00:LEMG:5:ZEND');
isLI20 = corr.z >= zend(2);
corr.emod(isLI20) = eend(2);

Bp = 1/33.356;
dbx = 1e-3 * xc .* corr.emod / Bp;
dby = 1e-3 * yc .* corr.emod / Bp;

% calculate new corrector bdes
corr.bnew = corr.bdes + dbx + dby;

% figure out x axis for plots
xr = [min([corr.z; bpms.z]) max([corr.z; bpms.z])];
xl = xr + [-.1 .1] * diff(xr);

useb = logical(handles.bpms.use);
usec = logical(handles.corr.use);
corr.use = handles.corr.use;

figure(handles.figure1);

titletxt = sprintf('Ref:  %s           Data: %s', char(reforbit.name), datestr(orbit.ts));
set(handles.text_titlebar, 'String', titletxt);
delete(findobj(0, 'type', 'axes'));

% clf(handles.uipanel_plot);
% reset;

subplot(2,2,1, 'Parent', handles.uipanel_plot);  
cla reset; hold all;
stem(bpms.z(useb), xref(useb), 'k.');
stem(bpms.z(~useb), xref(~useb), 'r.');
errorbar(bpms.z, x, xstd, 'm-');
plot(bpms.z, x+dx, 'b-');
xlim(xl);
title('x orbit [mm]');

subplot(2,2,2, 'Parent', handles.uipanel_plot);  
cla reset; hold all;
stem(bpms.z(useb), yref(useb), 'k.');
stem(bpms.z(~useb), yref(~useb), 'r.');
errorbar(bpms.z, y, ystd, 'm-');
plot(bpms.z, y+dy, 'b-');
xlim(xl);
title('y orbit [mm]');

isX = corr.isX;
isY = corr.isY;

gray = [.75 .75 .75];
subplot(2,2,3, 'Parent', handles.uipanel_plot);
cla reset; hold all;
bar(corr.z(isX), corr.bmax(isX), 'FaceColor', gray);
bar(corr.z(isX), -corr.bmax(isX), 'FaceColor', gray);
stem(corr.z(isX), corr.bdes(isX), 'm.');
stem(corr.z(isX), corr.bnew(isX), 'b.');
xlim(xl);
title('XCORs [BDES]');

subplot(2,2,4, 'Parent', handles.uipanel_plot); 
cla reset; hold all;
bar(corr.z(isY), corr.bmax(isY), 'FaceColor', gray);
bar(corr.z(isY), -corr.bmax(isY), 'FaceColor', gray);
stem(corr.z(isY), corr.bdes(isY), 'm.');
stem(corr.z(isY), corr.bnew(isY), 'b.');
xlim(xl);
title('YCORs [BDES]');
% legend(gca, [hrefx, horbx, hnewx], {sprintf('%s', 'Ref'), 'Meas', 'Calc'}, ...
%     'Location', 'NorthOutside', 'Orientation', 'horizontal');

set(handles.pushbutton_apply, 'BackgroundColor', [0 .66 0]);
set(handles.pushbutton_apply, 'ForegroundColor', 'white');



handles.corr = corr;
guidata(hObject, handles);


% --- Executes on selection change in popupmenu_refdir.
function popupmenu_refdir_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_refdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_refdir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_refdir


% --- Executes during object creation, after setting all properties.
function popupmenu_refdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_refdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_refnum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_refnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_refnum as text
%        str2double(get(hObject,'String')) returns contents of edit_refnum as a double
set(hObject, 'ForegroundColor', 'black');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_refnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_refnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_loadref.
function pushbutton_loadref_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(hObject, 'String');
set(hObject, 'String', 'Loading...');
drawnow;

% get GUI options
refnum = str2int(get(handles.edit_refnum, 'String'));
refdir_i = get(handles.popupmenu_refdir, 'Value');
refdir_l = get(handles.popupmenu_refdir, 'String');
refdir = refdir_l{refdir_i};
refd =  strcat('BPM_', handles.dgrp);
bpms = handles.bpms.name;
nbpms = numel(bpms);

% return a blank refernece if number == 0
if refnum == 0
    reforbit = blank_reforbit(handles);
    handles.reforbit = reforbit;
    gui_statusDisp(handles, 'Loaded ABSOLUTE reference orbit.');
    set(handles.edit_refnum, 'ForegroundColor', [0 .66 0]); % green
    set(hObject, 'String', str);
    guidata(hObject, handles);
    return
end

% make a local copy of the global ref orbit
reforbit = handles.reforbit;

try
    % load orbit from the SCP
    ref = scp_loadBPMData(refnum, refdir, refd);
    % find this GUIs BPMs in the reference data
    for ix = 1:nbpms
        ibpm(ix) = find(strcmp(bpms(ix), ref.name));
    end
    % extract into local struct
    reforbit.x = ref.X(ibpm);
    reforbit.y = ref.Y(ibpm);
    reforbit.tmit = ref.TMIT(ibpm);
    reforbit.pid = zeros(size(ibpm));
    reforbit.stat = ref.STAT(ibpm);
    reforbit.nsamp = ref.navg;
    reforbit.bpms = bpms;
    reforbit.dgrp = handles.dgrp;
    reforbit.name = strcat(refd, {' '}, refdir, {' '}, num2str(refnum));
    reforbit.title = ref.title;
    reforbit.ts = ref.ts;
    gui_statusDisp(handles, sprintf('Success loading orbit %s %d from %s', refdir, refnum, refd));
    ok = 1;
catch
    gui_statusDisp(handles, sprintf('Error loading orbit %s %d from %s', refdir, refnum, refd));
    ok = 0;
end

% update the global copy if success
if ok
    handles.reforbit = reforbit;
    set(handles.edit_refnum, 'ForegroundColor', [0 .66 0]); % green
else
    set(handles.edit_refnum, 'ForegroundColor', [.66 0 0]) % red
end

set(hObject, 'String', str);
guidata(hObject, handles);



function edit_cgain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cgain as text
%        str2double(get(hObject,'String')) returns contents of edit_cgain as a double


% --- Executes during object creation, after setting all properties.
function edit_cgain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mval = get(handles.popupmenu_method, 'Value');
mstr = get(handles.popupmenu_method, 'String');
method = mstr{mval};

str = get(hObject, 'String');
set(hObject, 'String', strcat(method, '-ing...'));
drawnow;

% magnet set here
corr = handles.corr;
use = logical(corr.use);
bact = control_magnetSet(corr.name(use), corr.bnew(use), 'action', method);

set(hObject, 'String', str);
set(hObject, 'ForegroundColor', 'black');
set(hObject, 'BackgroundColor', [.702 .702 .702]);
guidata(hObject, handles);


function edit_tgain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tgain as text
%        str2double(get(hObject,'String')) returns contents of edit_tgain as a double


% --- Executes during object creation, after setting all properties.
function edit_tgain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_method.
function popupmenu_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_method


% --- Executes during object creation, after setting all properties.
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_fake.
function checkbox_fake_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_fake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_fake
