function varargout = or_meas(varargin)
% OR_MEAS M-file for or_meas.fig
%      OR_MEAS, by itself, creates a new OR_MEAS or raises the existing
%      singleton*.
%
%      H = OR_MEAS returns the handle to a new OR_MEAS or the handle to
%      the existing singleton*.
%
%      OR_MEAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OR_MEAS.M with the given input arguments.
%
%      OR_MEAS('Property','Value',...) creates a new OR_MEAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before or_meas_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to or_meas_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help or_meas

% Last Modified by GUIDE v2.5 21-Nov-2007 15:23:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @or_meas_OpeningFcn, ...
                   'gui_OutputFcn',  @or_meas_OutputFcn, ...
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


% --- Executes just before or_meas is made visible.
function or_meas_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to or_meas (see VARARGIN)

% Choose default command line output for or_meas
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes or_meas wait for user response (see UIRESUME)
% uiwait(handles.orbit_response_measurement);


% --- Outputs from this function are returned to the command line.
function varargout = or_meas_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in do_meas.
function do_meas_Callback(hObject, eventdata, handles)
do_or_meas(hObject, eventdata, handles)
% hObject    handle to do_meas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function orbit_response_measurement_CreateFcn(hObject, eventdata, handles)
clear global;

% AIDA-PVA imports
aidapva;

global all_corrx all_corry all_bpm corrx_names corry_names all_bpm
global all_bpm_SLC all_bpm_EPICS all_corrx_EPICS all_corry_EPICS corrx_EPICS corry_EPICS bpm_ind
global corrx_pos corry_pos bpm_pos corrx_ind corry_ind en_corrx en_corry
all_corrx = {'XC02','XC03','XC04','XC05','XC06','XC07','XC08','XC09','XC10','XC11','XCA11','XCA12','XCM11','XCM13'};
all_corry = {'YC02','YC03','YC04','YC05','YC06','YC07','YC08','YC09','YC10','YC11','YCA11','YCA12','YCM11','YCM12'};
all_bpm = {'BPM5','BPM6','BPM8','BPM9','BPM10','BPM11','BPM12','BPM13','BPM14','BPM15','BPMA11','BPMA12','BPM21201','BPMS11','BPMM12','BPM21301'};

corrx_ind = ([1:1:1]);
corry_ind = ([1:1:1]);
corrx_names = all_corrx(corrx_ind);
corry_names = all_corry(corry_ind);

[all_bpm_SLC, stat] = model_nameConvert(all_bpm, 'SLC');
[all_bpm_EPICS, stat] = model_nameConvert(all_bpm, 'EPICS');
[all_corrx_EPICS, stat] = model_nameConvert(all_corrx, 'EPICS');
[all_corry_EPICS, stat] = model_nameConvert(all_corry, 'EPICS');
[corrx_EPICS, stat] = model_nameConvert(corrx_names, 'EPICS');
[corry_EPICS, stat] = model_nameConvert(corry_names, 'EPICS');
[all_corrx_SLC, stat] = model_nameConvert(all_corrx, 'SLC');
[all_corry_SLC, stat] = model_nameConvert(all_corry, 'SLC');
bpm_ind=1;

global RespMatH RespMatV
%get the orbit response and z positions from aida
for j = 1:length(all_bpm)
    bpm_pos(j)    = pvaGet([all_bpm_SLC{j} ':Z'])-2015;
end

for j = 1:length(all_corrx)
    corrx_pos(j)    = pvaGet([all_corrx_SLC{j} ':Z'])-2015;
    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<corrx_pos(j)
            RespMatH(i,j)=0;
        else
            requestBuilder = pvaRequest({[all_corrx_SLC{j} ':R']});
            requestBuilder.returning(AIDA_DOUBLE_ARRAY);
            requestBuilder.with('B',all_bpm_SLC{i});
            R        = ML(requestBuilder.get());
            Rm       = reshape(R,6,6);
            Rm = cell2mat(Rm)';
            RespMatH(i,j)=Rm(1,2);
        end
    end
end

for j = 1:length(all_corry)
    corry_pos(j)    = pvaGet([all_corry_SLC{j} ':Z'])-2015;
    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<corry_pos(j)
            RespMatH(i,j)=0;
        else
            requestBuilder = pvaRequest({[all_corry_SLC{j} ':R']});
            requestBuilder.returning(AIDA_DOUBLE_ARRAY);
            requestBuilder.with('B',all_bpm_SLC{i});
            R        = ML(requestBuilder.get());
            Rm       = reshape(R,6,6);
            Rm = cell2mat(Rm)';
            RespMatV(i,j)=Rm(3,4);
        end
    end
end

for i=1:length(all_corrx_SLC)
    twiss = cell2mat(pvaGetM([all_corrx_SLC{i} ':twiss'], AIDA_DOUBLE_ARRAY));
    en_corrx(i)=twiss(1)*1000;
end
for i=1:length(all_corry_SLC)
    twiss = cell2mat(pvaGetM([all_corry_SLC{i} ':twiss'],AIDA_DOUBLE_ARRAY));
    en_corry(i)=twiss(1)*1000;
end

global dim
dim='hor';

%default number of BPM readings
global Nsamples
Nsamples=50;

%reading initial steerer strenghts and limits
global ini_currx ini_curry lim_corrx lim_corry
for j = 1:length(all_corrx_EPICS)
    pvlist_corrx{j} = [all_corrx_EPICS{j} ':BACT'];
    pvlist_lim_corrx{j} = [all_corrx_EPICS{j} ':BACT.HOPR'];
end
for j = 1:length(all_corry_EPICS)
    pvlist_corry{j} = [all_corry_EPICS{j} ':BACT'];
    pvlist_lim_corry{j} = [all_corry_EPICS{j} ':BACT.HOPR'];
end
ini_currx = lcaGet(pvlist_corrx(:), 0, 'double')';
ini_curry = lcaGet(pvlist_corry(:), 0, 'double')';
lim_corrx = lcaGet(pvlist_lim_corrx(:), 0, 'double')';
lim_corry = lcaGet(pvlist_lim_corry(:), 0, 'double')';

%repetition rate
global rep
[sys,accelerator]=getSystem();
pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
rep = lcaGet(pv, 0, 'double');

%maximum bpm difference in mm
global max_bpm_diff
max_bpm_diff=1;

%number of steps per corrector
global nsteps
nsteps=5;

% hObject    handle to orbit_response_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%plot difference between model and measurement?
global plot_diff
plot_diff=0;


function samples_Callback(hObject, eventdata, handles)
global Nsamples
Nsamples = str2double(get(hObject,'String'));
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samples as text
%        str2double(get(hObject,'String')) returns contents of samples as a double


% --- Executes during object creation, after setting all properties.
function samples_CreateFcn(hObject, eventdata, handles)
global Nsamples
set(hObject,'String',Nsamples);
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in x_corr.
function x_corr_Callback(hObject, eventdata, handles)
global corrx_names corrx_ind corrx_EPICS
contents = get(hObject,'String');
corrx_ind = get(hObject,'Value');
corrx_names={contents{get(hObject,'Value')}};
[corrx_EPICS, stat] = model_nameConvert(corrx_names, 'EPICS');
% hObject    handle to x_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns x_corr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from x_corr


% --- Executes during object creation, after setting all properties.
function x_corr_CreateFcn(hObject, eventdata, handles)
global corrx_ind all_corrx
set(hObject,'String',all_corrx)
set(hObject,'Value',corrx_ind)
handles.corrx_sel=hObject;
guidata(hObject,handles)
% hObject    handle to x_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in y_corr.
function y_corr_Callback(hObject, eventdata, handles)
global corry_names corry_ind corry_EPICS
contents = get(hObject,'String');
corry_ind = get(hObject,'Value');
corry_names={contents{get(hObject,'Value')}};
[corry_EPICS, stat] = model_nameConvert(corry_names, 'EPICS');
% hObject    handle to y_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns y_corr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from y_corr


% --- Executes during object creation, after setting all properties.
function y_corr_CreateFcn(hObject, eventdata, handles)
global corry_ind corry_names all_corry
set(hObject,'String',all_corry)
set(hObject,'Value',corry_ind)
handles.corry_sel=hObject;
guidata(hObject,handles)
% hObject    handle to y_corr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function or_axes_CreateFcn(hObject, eventdata, handles)
handles.axes_orm=hObject;
guidata(hObject,handles)

% hObject    handle to or_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate or_axes





function max_BPM_Callback(hObject, eventdata, handles)
global max_bpm_diff
max_bpm_diff=str2double(get(hObject,'String'));
% hObject    handle to max_BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_BPM as text
%        str2double(get(hObject,'String')) returns contents of max_BPM as a double


% --- Executes during object creation, after setting all properties.
function max_BPM_CreateFcn(hObject, eventdata, handles)
global max_bpm_diff

set(hObject,'String',max_bpm_diff);
handles.max_bpm_diff=hObject;
guidata(hObject,handles);

% hObject    handle to max_BPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function corr_steps_Callback(hObject, eventdata, handles)
global nsteps
nsteps = str2double(get(hObject,'String'));
% hObject    handle to corr_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of corr_steps as text
%        str2double(get(hObject,'String')) returns contents of corr_steps as a double


% --- Executes during object creation, after setting all properties.
function corr_steps_CreateFcn(hObject, eventdata, handles)
global nsteps
set(hObject,'String',nsteps)
handles.nsteps=hObject;
guidata(hObject,handles)
% hObject    handle to corr_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in print_or.
function print_or_Callback(hObject, eventdata, handles)
global h actual hc plot_diff
figure;
axes
hold on
grid on
if plot_diff==0
    copyobj(sort(h,'descend'),gca)
    legend('measurement','model','Location','Best')
    title(sprintf('Orbit Response for %s',actual))
else
    copyobj(h,gca)
    title(sprintf('Orbit response difference between measurement and model for %s',actual))
end
ylabel('orbit response [mm/mrad]')
xlabel('s [m]')

figure;
axes
hold on
grid on
if plot_diff==0
    copyobj(sort(hc,'descend'),gca)
    legend('measurement','model','Location','Best')
    title(sprintf('Coupled Orbit Response for %s',actual))
else
    copyobj(hc,gca)
    title(sprintf('Coupled orbit response difference between measurement and model for %s',actual))
end
ylabel('orbit response [mm/mrad]')
xlabel('s [m]')



% hObject    handle to print_or (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
clear global
close
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function or_coupled_axes_CreateFcn(hObject, eventdata, handles)
handles.axes_coupled_orm=hObject;
guidata(hObject,handles)
% hObject    handle to or_coupled_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate or_coupled_axes




% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
global ORBITX ORBITY SIGMAX SIGMAY ORX ORY SIGMA_ORX SIGMA_ORY CORR_NAMES OR_T KICKS FIELDS en_corrx en_corry
ini = [datestr(now,30) 'orbit_response_measurement'];
path_name=([getenv('MATLABDATAFILES') '/orbit_response_measurement_GUI']);
temp = inputdlg({'write a name for the file'},'file name',1,{ini});
if ~isempty(temp)
    filename = temp{1};
    save(fullfile(path_name,filename),'ORBITX', 'ORBITY', 'SIGMAX', 'SIGMAY', 'ORX', 'ORY', 'SIGMA_ORX', 'SIGMA_ORY', 'CORR_NAMES', 'OR_T','KICKS','FIELDS','en_corrx','en_corry');
end
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function bpm_axes_CreateFcn(hObject, eventdata, handles)
handles.axes_bpm=hObject;
guidata(hObject,handles)
% hObject    handle to bpm_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate bpm_axes




% --- Executes on selection change in dimension.
function dimension_Callback(hObject, eventdata, handles)
global dim

if get(hObject,'Value')==1
    dim = 'hor';
    set(handles.corrx_sel,'Enable','on')
    set(handles.corry_sel,'Enable','off')
else
    dim = 'ver';
    set(handles.corrx_sel,'Enable','off')
    set(handles.corry_sel,'Enable','on')
end
% hObject    handle to dimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dimension contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dimension


% --- Executes during object creation, after setting all properties.
function dimension_CreateFcn(hObject, eventdata, handles)
global dim
if dim=='hor'
    set(hObject,'Value',1)
else
    set(hObject,'Value',2)
end
% hObject    handle to dimension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in bpm_selection.
function bpm_selection_Callback(hObject, eventdata, handles)
global bpm_ind ORBITX ORBITY SIGMAX SIGMAY dim kicks all_bpm h_bpm
global corr_names plot_ind KICKS p

if isempty(plot_ind)
    plot_ind=1;
end
orbitx=ORBITX{plot_ind};
orbity=ORBITY{plot_ind};
sigmax=SIGMAX{plot_ind};
sigmay=SIGMAY{plot_ind};
kicks=KICKS{plot_ind};
bpm_ind = get(hObject,'Value');

axes(handles.axes_bpm)
if dim=='hor'
    h_bpm(1) = errorbar(1000*kicks', 1000*orbitx(:,bpm_ind),sigmax(:,bpm_ind),'o-b');
    hold on
    grid on
    p = polyfit(1000*kicks', 1000*orbitx(:,bpm_ind),1);
else
    h_bpm(1) = errorbar(1000*kicks', 1000*orbity(:,bpm_ind),sigmay(:,bpm_ind),'o-b');
    hold on
    grid on
    p = polyfit(1000*kicks', 1000*orbity(:,bpm_ind),1);
end
h_bpm(2) = plot(1000*kicks',polyval(p,1000*kicks'),'-k');
hold off
legend('data points',sprintf('linear fit, slope=%g',p(1)),'Location','Best')
xlabel('corrector kick [mrad]')
ylabel('orbit [mm]')
title(sprintf('Orbit at %s as a function of %s strength',all_bpm{bpm_ind},corr_names{plot_ind}))
% hObject    handle to bpm_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns bpm_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bpm_selection


% --- Executes during object creation, after setting all properties.
function bpm_selection_CreateFcn(hObject, eventdata, handles)
global all_bpm bpm_ind
set(hObject,'String',all_bpm)
set(hObject,'Value',bpm_ind)
% hObject    handle to bpm_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function info_text_CreateFcn(hObject, eventdata, handles)
handles.info_text=hObject;
guidata(hObject,handles)

% hObject    handle to info_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function do_or_meas(hObject,eventdata,handles)

clear global ort orx ory sigma_orx sigma_ory orbitx orbity sigmax sigmay...
    ind corr_names plot_ind kicks

global max_kick nsteps dim corrx_names corry_names corr_names
global curr0 KICKS kicks ini_curr ind
global orbitx orbity sigmax sigmay
global RespMatH RespMatV
global orx ory sigma_orx sigma_ory or_t
global corrx_ind corry_ind max_bpm_diff
global ini_currx ini_curry max_field actual lim_corrx lim_corry
global corrx_EPICS corry_EPICS en_corrx en_corry
global ORBITX ORBITY SIGMAX SIGMAY ORX ORY SIGMA_ORX SIGMA_ORY CORR_NAMES OR_T
global FIELDS KICKS corrx_pos

set(handles.save,'Visible','off')
drawnow
set(handles.plotting,'Visible','off')
set(get(handles.plotting,'Children'),'Visible','off')
set(handles.bpm_info,'Visible','off')
set(get(handles.bpm_info,'Children'),'Visible','off')

if dim=='hor'
    corr_names=corrx_names;
    curr0=ini_currx(corrx_ind);
    lim=lim_corrx;
    ind=corrx_ind;
else
    corr_names=corry_names;
    curr0=ini_curry(corry_ind);
    lim=lim_corry;
    ind=corry_ind;
end


for i=1:length(corr_names)
    actual=corr_names{i};
    set(handles.info_text,'String',sprintf('measuring orbit response for %s ...',actual));
    drawnow
    ini_curr = curr0(i);
    max_kick=get_corrector_field(max_bpm_diff,dim,ind(i));
    if dim=='hor'
        max_field = max_kick*10*3.3356*en_corrx(corrx_ind(i))/1000;
    else
        max_field = max_kick*10*3.3356*en_corrx(corry_ind(i))/1000;
    end
    %check limits
    if (ini_curr+max_field)>=lim(ind(i))
        if (ini_curr-max_field)<=(-lim(ind(i)))
            uiwait(msgbox('not possible to generate such an orbit change','warning message!','warn'))
            if abs(lim(ind(i))-ini_curr)>=abs(-lim(ind(i))-ini_curr)
                max_field=lim(ind(i))-ini_curr;
            else
                max_field=-lim(ind(i))-ini_curr;
            end
        else
            max_field=-max_field;
        end
    end
    %kick added for each step
    field=max_field/nsteps;
    fields = ([ini_curr:field:(ini_curr+max_field)]);
    if dim=='hor'
        for m=1:length(fields)
            kicks(m) = 1000*fields(m)/(10*3.3356*en_corrx(corrx_ind(i)));
        end
    else
        for m=1:length(fields)
            kicks(m) = 1000*fields(m)/(10*3.3356*en_corry(corry_ind(i)));
        end
    end
    KICKS{i}=kicks;
    pvlist={};
    for j=1:(nsteps+1)
        %adding current to the steerer
        if j~1
            if dim=='hor'
                lcaPut([corrx_EPICS{i} ':BCTRL'],fields(j))
            else
                lcaPut([corry_EPICS{i} ':BCTRL'],fields(j))
            end
            status=1;
            if dim=='hor'
                while status
                    status=lcaGet([corrx_EPICS{i} ':RAMPSTATE'],0,'double');
                end
            else
                while status
                    status=lcaGet([corry_EPICS{i} ':RAMPSTATE'],0,'double');
                end
            end
        end
        [orbitx(j,:),sigmax(j,:),orbity(j,:),sigmay(j,:)]=get_orbit(hObject,eventdata,handles);
    end

    %going back to the initial current value
    if dim=='hor'
        lcaPut([corrx_EPICS{i} ':BCTRL'],ini_curr)
        status=1;
        while status
            status=lcaGet([corrx_EPICS{i} ':RAMPSTATE'],0,'double');
        end
    else
        lcaPut([corry_EPICS{i} ':BCTRL'],ini_curr)
        status=1;
        while status
            status=lcaGet([corry_EPICS{i} ':RAMPSTATE'],0,'double');
        end
    end

    %response from the model
    if dim=='hor'
        or_t=RespMatH(:,corrx_ind(i))';
    elseif dim=='ver'
        or_t=RespMatV(:,corry_ind(i))';
    end
    %getting the measured orbit response
    [orx,sigma_orx,ory,sigma_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks);

    %store data
    ORBITX{i}=orbitx;
    ORBITY{i}=orbity;
    SIGMAX{i} = sigmax;
    SIGMAY{i} = sigmay;
    ORX{i}=orx;
    ORY{i}=ory;
    SIGMA_ORX{i} = sigma_orx;
    SIGMA_ORY{i} = sigma_ory;
    CORR_NAMES{i} = actual;
    KICKS{i} = kicks;
    FIELDS{i} = fields;
    OR_T{i} = or_t;
end
set(handles.info_text,'String','Ready');
drawnow
set(handles.save,'Visible','on')
set(handles.plotting,'Visible','on')
set(handles.bpm_info,'Visible','on')
set(get(handles.bpm_info,'Children'),'Visible','on')
set(get(handles.plotting,'Children'),'Visible','on')
set(handles.corr_plot_selection,'String',corr_names)
set(handles.corr_plot_selection,'Value',1)
g=get(handles.axes_orm,'Children');
delete(g)
g2=get(handles.axes_coupled_orm,'Children');
delete(g2)
g3=get(handles.axes_bpm,'Children');
delete(g3)
legend(handles.axes_orm,'off')
legend(handles.axes_coupled_orm,'off')
legend(handles.axes_bpm,'off')
delete(get(handles.axes_orm,'Title'))
delete(get(handles.axes_coupled_orm,'Title'))
delete(get(handles.axes_bpm,'Title'))

%plot energy_profile
axes(handles.energy_axes)
plot(corrx_pos,en_corrx,'-b')
grid on
xlabel('s [m]')
ylabel('energy [MeV]')
title('Beam Energy Profile')
% hObject    handle to energy_profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate energy_profile

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,sigma_x,y,sigma_y]=get_orbit(hObject,eventdata,handles)
global all_bpm_EPICS Nsamples rep
pvlist = {};
statuslist = {};
for j = 1:length(all_bpm_EPICS)
    statuslist{j,1} = [all_bpm_EPICS{j} ':STA'];
    pvlist{3*j-2,1} = [all_bpm_EPICS{j} ':X'];
    pvlist{3*j-1,1} = [all_bpm_EPICS{j} ':Y'];
    pvlist{3*j  ,1} = [all_bpm_EPICS{j} ':TMIT'];
end
for k = 1:Nsamples
    tic
    stats = lcaGet(statuslist);
    data  = lcaGet(pvlist, 0, 'double');
    for j = 1:length(all_bpm_EPICS)
        Xs(k,j) = data(3*j-2);
        Ys(k,j) = data(3*j-1);
        Ts(k,j) = data(3*j)*1.602E-10;
    end
    if rep~=0
        pause(1/rep-toc);
    end
end
for j = 1:length(all_bpm_EPICS)
    x(j) = mean(Xs(:,j))/1e3;
    y(j) = mean(Ys(:,j))/1e3;
    sigma_x(j) = std(Ys(:,j))/1e3;
    sigma_y(j) = std(Ys(:,j))/1e3;
    I(j) = mean(Ts(:,j));
    sigma_I(j) = std(Ts(:,j));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function    [orx,sigma_orx,ory,sigma_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks)

global all_bpm_EPICS

for j=1:length(all_bpm_EPICS)
    px(j,:) = polyfit(kicks(:), orbitx(:,j),1);
    py(j,:) = polyfit(kicks(:), orbity(:,j),1);
    for i=1:length(kicks)
        Sc(i)=1/(sigmax(i,j)^2);
        Sxc(i)=kicks(i)/(sigmax(i,j)^2);
        Syc(i)=orbitx(i)/(sigmax(i,j)^2);
        Sxxc(i)=kicks(i)^2/(sigmax(i,j)^2);
        Sxyc(i)=kicks(i)*orbitx(i,j)/(sigmax(i,j)^2);
    end
    S(j)=sum(Sc);
    Sx(j)=sum(Sxc);
    Sy(j)=sum(Syc);
    Sxx(j)=sum(Sxxc);
    Sxy(j)=sum(Sxyc);
    deno(j)=S(j)*Sxx(j)-Sx(j)*Sx(j);
    sigma_a2x(j)=Sxx(j)/deno(j);
    sigma_b2x(j)=S(j)/deno(j);
    %the same in y
    for i=1:length(kicks)
        Sc(i)=1/(sigmay(i,j)^2);
        Sxc(i)=kicks(i)/(sigmay(i,j)^2);
        Syc(i)=orbity(i)/(sigmay(i,j)^2);
        Sxxc(i)=kicks(i)^2/(sigmay(i,j)^2);
        Sxyc(i)=kicks(i)*orbity(i,j)/(sigmay(i,j)^2);
    end
    Sy(j)=sum(Syc);
    Sxy(j)=sum(Sxyc);
    sigma_a2y(j)=Sxx(j)/deno(j);
    sigma_b2y(j)=S(j)/deno(j);
end

orx=px(:,1)';
ory=py(:,1)';
sigma_orx=sigma_b2x;
sigma_ory=sigma_b2y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function max_kick=get_corrector_field(max_bpm_diff,dim,index)
global RespMatH RespMatV all_bpm

if dim=='hor'
    matrix=RespMatH;
else
    matrix=RespMatV;
end

for i=1:length(all_bpm)
    temp=matrix(i,index);
    if temp==0
        kick(i)=9e99;
    else
        kick(i) = abs(max_bpm_diff*1e-3/matrix(i,index));
    end
end
max_kick = abs(min(kick));


% --- Executes on button press in print_BPM_info.
function print_BPM_info_Callback(hObject, eventdata, handles)
global h_bpm bpm_ind plot_ind corr_names all_bpm p
figure;
axes
hold on
grid on
copyobj(h_bpm,gca)
xlabel('corrector kick [mrad]')
ylabel('orbit [mm]')
title(sprintf('Orbit at %s as a function of %s strength',all_bpm{bpm_ind},corr_names{plot_ind}))
legend('data points',sprintf('linear fit, slope=%g',p(1)))

% hObject    handle to print_BPM_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function bpm_info_panel_CreateFcn(hObject, eventdata, handles)
handles.bpm_info=hObject;
guidata(hObject,handles)

% hObject    handle to bpm_info_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function save_data_CreateFcn(hObject, eventdata, handles)
handles.save=hObject;
guidata(hObject,handles)
% hObject    handle to save_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function print_or_CreateFcn(hObject, eventdata, handles)
handles.print=hObject;
guidata(hObject,handles)
% hObject    handle to print_or (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on selection change in corr_selection.
function corr_selection_Callback(hObject, eventdata, handles)
global plot_ind
plot_ind = get(hObject,'Value');
plot_or(hObject,eventdata,handles)
% hObject    handle to corr_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns corr_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from corr_selection


% --- Executes during object creation, after setting all properties.
function corr_selection_CreateFcn(hObject, eventdata, handles)
handles.corr_plot_selection=hObject;
guidata(hObject,handles)
% hObject    handle to corr_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function plots_panel_CreateFcn(hObject, eventdata, handles)
handles.plotting=hObject;
guidata(hObject,handles)
% hObject    handle to plots_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function show_difference_CreateFcn(hObject, eventdata, handles)
global plot_diff
if plot_diff==1
    set(hObject,'Value',1)
else
    set(hObject,'Value',0)
end

% --- Executes on button press in show_difference.
function show_difference_Callback(hObject, eventdata, handles)
global plot_diff
if (get(hObject,'Value')==1)
    plot_diff=1;
else
    plot_diff=0;
end
plot_or(hObject,eventdata,handles)
% hObject    handle to show_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_difference


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_or(hObject,eventdata,handles)

clear global h hc

global bpm_pos ORX ORY SIGMA_ORX SIGMA_ORY plot_ind h hc OR_T corr_names dim plot_diff

if plot_diff==1 %plot difference between measurement and the model
    axes(handles.axes_orm)
    if dim=='hor'
        h(1)=errorbar(bpm_pos,ORX{plot_ind}-OR_T{plot_ind},SIGMA_ORX{plot_ind},'-or');
    else
        h(1)=errorbar(bpm_pos,ORY{plot_ind}-OR_T{plot_ind},SIGMA_ORY{plot_ind},'-or');
    end
    grid on
    ylabel('orbit response [mm/mrad]')
    xlabel('s [m]')
    title(sprintf('Orbit response difference between measurement and model for %s',corr_names{plot_ind}))

    axes(handles.axes_coupled_orm)
    if dim=='ver'
        hc(1)=errorbar(bpm_pos,ORX{plot_ind},SIGMA_ORX{plot_ind},'-or');
    else
        hc(1)=errorbar(bpm_pos,ORY{plot_ind},SIGMA_ORY{plot_ind},'-or');
    end
    grid on
    ylabel('orbit response [mm/mrad]')
    xlabel('s [m]')
    title(sprintf('Coupled orbit response difference between measurement and model for %s',corr_names{plot_ind}))
else
    %plotting orbit response
    axes(handles.axes_orm)
    if dim=='hor'
        h(1)=errorbar(bpm_pos,ORX{plot_ind},SIGMA_ORX{plot_ind},'-ob');
    else
        h(1)=errorbar(bpm_pos,ORY{plot_ind},SIGMA_ORY{plot_ind},'-ob');
    end
    hold on
    grid on
    h(2)=plot(bpm_pos,OR_T{plot_ind},'-om');
    hold off
    ylabel('orbit response [mm/mrad]')
    xlabel('s [m]')
    title(sprintf('Orbit Response for %s',corr_names{plot_ind}))
    legend('measurement','model','Location','Best')

    axes(handles.axes_coupled_orm)
    if dim=='ver'
        hc(1)=errorbar(bpm_pos,ORX{plot_ind},SIGMA_ORX{plot_ind},'-ob');
    else
        hc(1)=errorbar(bpm_pos,ORY{plot_ind},SIGMA_ORY{plot_ind},'-ob');
    end
    hold on
    grid on
    hc(2)=plot(bpm_pos,zeros(1,length(bpm_pos)),'-om');
    hold off
    ylabel('coupled response [mm/mrad]')
    xlabel('s [m]')
    title(sprintf('Coupled Orbit Response for %s',corr_names{plot_ind}))
    legend('measurement','model','Location','Best')
end



% hObject    handle to show_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function energy_ax_CreateFcn(hObject, eventdata, handles)
handles.energy_axes=hObject;
guidata(hObject,handles)
% hObject    handle to energy_ax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate energy_ax




% --- Executes when user attempts to close orbit_response_measurement.
function orbit_response_measurement_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to orbit_response_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/toolbox/or_meas.m', which('or_meas'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end

