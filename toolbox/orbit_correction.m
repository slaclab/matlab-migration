function varargout = orbit_correction(varargin)
% ORBIT_CORRECTION M-file for orbit_correction.fig
%      ORBIT_CORRECTION, by itself, creates a new ORBIT_CORRECTION or raises the existing
%      singleton*.
%
%      H = ORBIT_CORRECTION returns the handle to a new ORBIT_CORRECTION or the handle to
%      the existing singleton*.
%
%      ORBIT_CORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORBIT_CORRECTION.M with the given input arguments.
%
%      ORBIT_CORRECTION('Property','Value',...) creates a new ORBIT_CORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before orbit_correction_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to orbit_correction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help orbit_correction

% Last Modified by GUIDE v2.5 17-Mar-2016 05:54:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @orbit_correction_OpeningFcn, ...
    'gui_OutputFcn',  @orbit_correction_OutputFcn, ...
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


% --- Executes just before orbit_correction is made visible.
function orbit_correction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to orbit_correction (see VARARGIN)

% Choose default command line output for orbit_correction
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes orbit_correction wait for user response (see UIRESUME)
% uiwait(handles.orbit_correction);


% --- Outputs from this function are returned to the command line.
function varargout = orbit_correction_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function orbit_correction_CreateFcn(hObject, eventdata, handles)

initialization(hObject, eventdata, handles)  %%TODO: Need to refine this so that we don't calculate RMATS at init.



function edit_correction_percentage_Callback(hObject, eventdata, handles)
global per
usert = get(hObject,'String');
if isempty(str2num(char(usert)))|(str2num(usert) < -50) | (str2num(usert) > 150)
    set(hObject,'String',per)
    uiwait(msgbox('invalid percentage, select a number between -50 and 150','warning','warn'))
end

per = str2double(get(hObject,'String'))/100;


% --- Executes during object creation, after setting all properties.
function edit_correction_percentage_CreateFcn(hObject, eventdata, handles)
handles.corrper = hObject;
guidata(hObject,handles)
global per
set(hObject,'String',per*100);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
clear global
close


% --- Executes on button press in calculate_correction.
function calculate_correction_Callback(hObject, eventdata, handles)
global corrx_names corry_names bpm_names dim orbx_gold orby_gold orb_in
global cor_out cor_outGx cor_outGy lim_corrx lim_corry
global all_corrx all_corry corr_totGx corr_totGy

if dim=='hor'
    [orb_out, cor_out, err]= my_orbit_correction(corrx_names, bpm_names, dim, orbx_gold, orb_in, hObject, eventdata, handles);
    set(handles.axes_corry,'Visible','off')
    set(get(handles.axes_corry,'Children'),'Visible','off')
    set(handles.axes_corrx,'Visible','on')
    set(get(handles.axes_corrx,'Children'),'Visible','on')
else
    [orb_out, cor_out, err]= my_orbit_correction(corry_names, bpm_names, dim, orby_gold, orb_in, hObject, eventdata, handles);
    set(handles.axes_corrx,'Visible','off')
    set(get(handles.axes_corrx,'Children'),'Visible','off')
    set(handles.axes_corry,'Visible','on')
    set(get(handles.axes_corry,'Children'),'Visible','on')
end

%warn the user if required plus actual fields would exceed the limit
for i=1:length(all_corrx)
    if abs(corr_totGx(i)+cor_outGx(i))>=lim_corrx(i)
        msgbox('required change (100%) would exceed corrector limits','Warning!','warn')
        break
    end
end
for i=1:length(all_corry)
    if abs(corr_totGy(i)+cor_outGy(i))>=lim_corry(i)
        msgbox('required change (100%) would exceed corrector limits','Warning!','warn')
        break
    end
end

set(handles.do_corr,'Visible','on')
set(handles.corrper,'Visible','on')
set(handles.text_per,'Visible','on')



% --- Executes on button press in apply_correction.
function apply_correction_Callback(hObject, eventdata, handles)
global index
index = index+1;
orb_meas(hObject, eventdata, handles);
set(handles.restore,'Visible','on')
% hObject    handle to apply_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in restore_initial_currents.
function restore_initial_currents_Callback(hObject, eventdata, handles)
global ini_corrx ini_corry all_corrx_EPICS all_corry_EPICS

statuslist = {};
statuslist2 = {};
for j = 1:length(all_corrx_EPICS)
    statuslist{j,1} = [all_corrx_EPICS{j} ':BCTRL'];
    statuslist2{j,1} = [all_corrx_EPICS{j} ':RAMPSTATE'];
end
lcaPut(statuslist,ini_corrx');
status=1;
while status
    temp=lcaGet(statuslist2,0,'double');
    temp2=find(temp==1);
    if isempty(temp2)
        status=0;
    end
end

statuslist = {};
statuslist2 = {};
for j = 1:length(all_corry_EPICS)
    statuslist{j,1} = [all_corry_EPICS{j} ':BCTRL'];
    statuslist2{j,1} = [all_corry_EPICS{j} ':RAMPSTATE'];
end
lcaPut(statuslist,ini_corry');
status=1;
while status
    temp=lcaGet(statuslist2,0,'double');
    temp2=find(temp==1);
    if isempty(temp2)
        status=0;
    end
end

set(handles.calc_corr,'Visible','off')
set(handles.do_corr,'Visible','off')
set(handles.restore,'Visible','off')
set(handles.corrper,'Visible','off')
set(handles.text_per,'Visible','off')
set(handles.all2constant,'Visible','off')
set(handles.orbx,'String',{})
set(handles.orby,'String',{})
delete(get(handles.axes_orbitx,'Children'))
delete(get(handles.axes_orbity,'Children'))
delete(get(handles.axes_corr_totx,'Children'))
delete(get(handles.axes_corr_toty,'Children'))
delete(get(handles.axes_corrx,'Children'))
delete(get(handles.axes_corry,'Children'))
delete(get(handles.axes_corr_totx,'Title'))
delete(get(handles.axes_corr_toty,'Title'))
set(handles.axes_corrx,'Visible','off')
set(handles.axes_corry,'Visible','off')
legend(handles.axes_orbitx,'off')
legend(handles.axes_orbity,'off')
set(handles.save_orbit,'Visible','off')
set(handles.print,'Visible','off')

% --- Executes on button press in do_1st_measurement.
function do_1st_measurement_Callback(hObject, eventdata, handles)
global index all_corrx_EPICS all_corry_EPICS
index = 1;
%reading initial steerer strenghts and limits
global corr_totGx corr_totGy lim_corrx lim_corry ini_corrx ini_corry
for j = 1:length(all_corrx_EPICS)
    pvlist_corrx{j} = [all_corrx_EPICS{j} ':BACT'];
    pvlist_lim_corrx{j} = [all_corrx_EPICS{j} ':BACT.HOPR'];
end
for j = 1:length(all_corry_EPICS)
    pvlist_corry{j} = [all_corry_EPICS{j} ':BACT'];
    pvlist_lim_corry{j} = [all_corry_EPICS{j} ':BACT.HOPR'];
end
corr_totGx = lcaGet(pvlist_corrx(:), 0, 'double')';
corr_totGy = lcaGet(pvlist_corry(:), 0, 'double')';
lim_corrx = lcaGet(pvlist_lim_corrx(:), 0, 'double')';
lim_corry = lcaGet(pvlist_lim_corry(:), 0, 'double')';
ini_corrx = corr_totGx;
ini_corry = corr_totGy;

orb_meas(hObject, eventdata, handles);

set(handles.calc_corr,'Visible','on')
set(handles.do_corr,'Visible','off')
set(handles.restore,'Visible','off')
set(handles.corrper,'Visible','off')
set(handles.text_per,'Visible','off')
set(handles.axes_corry,'Visible','off')
set(get(handles.axes_corry,'Children'),'Visible','off')
set(handles.axes_corrx,'Visible','off')
set(get(handles.axes_corrx,'Children'),'Visible','off')

% hObject    handle to do_1st_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function orbitx_CreateFcn(hObject, eventdata, handles)
handles.axes_orbitx=hObject;
guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function orbity_CreateFcn(hObject, eventdata, handles)
handles.axes_orbity = hObject;
guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function corrx_CreateFcn(hObject, eventdata, handles)
handles.axes_corrx=hObject;
guidata(hObject,handles)



% --- Executes on selection change in plane_selection.
function plane_selection_Callback(hObject, eventdata, handles)
global dim
contents = get(hObject,'String');
if contents{get(hObject,'Value')}(1)=='h'
    dim = 'hor';
else
    dim = 'ver';
end

set(handles.axes_corry,'Visible','off')
set(get(handles.axes_corry,'Children'),'Visible','off')
set(handles.axes_corrx,'Visible','off')
set(get(handles.axes_corrx,'Children'),'Visible','off')

set(handles.do_corr,'Visible','off')

% --- Executes during object creation, after setting all properties.
function plane_selection_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in BPM_selection.
function BPM_selection_Callback(hObject, eventdata, handles)
global bpm_names bpm_ind
contents = get(hObject,'String');
bpm_ind = get(hObject,'Value');
bpm_names={contents{get(hObject,'Value')}};


% --- Executes during object creation, after setting all properties.
function BPM_selection_CreateFcn(hObject, eventdata, handles)
global bpm_ind bpm_names all_bpm
set(hObject,'String',all_bpm)
set(hObject,'Value',bpm_ind)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in corrx_selection.
function corrx_selection_Callback(hObject, eventdata, handles)
global corrx_names corrx_ind corrx_EPICS
contents = get(hObject,'String');
corrx_ind = get(hObject,'Value');
corrx_names={contents{get(hObject,'Value')}};
[corrx_EPICS, stat] = model_nameConvert(corrx_names, 'EPICS');



% --- Executes during object creation, after setting all properties.
function corrx_selection_CreateFcn(hObject, eventdata, handles)
global corrx_ind corrx_names all_corrx
set(hObject,'String',all_corrx)
set(hObject,'Value',corrx_ind)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in corry_selection.
function corry_selection_Callback(hObject, eventdata, handles)
global corry_names corry_ind corry_EPICS
contents = get(hObject,'String');
corry_ind = get(hObject,'Value');
corry_names={contents{get(hObject,'Value')}};
[corry_EPICS, stat] = model_nameConvert(corry_names, 'EPICS');




% --- Executes during object creation, after setting all properties.
function corry_selection_CreateFcn(hObject, eventdata, handles)
global corry_ind all_corry
set(hObject,'String',all_corry)
set(hObject,'Value',corry_ind)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function tot_corrx_CreateFcn(hObject, eventdata, handles)
handles.axes_corr_totx=hObject;
guidata(hObject,handles)



function select_SVD_Callback(hObject, eventdata, handles)
global SVD_tol
SVD_tol = str2double(get(hObject,'String'))/100;


% --- Executes during object creation, after setting all properties.
function select_SVD_CreateFcn(hObject, eventdata, handles)
global SVD_tol
set(hObject,'String',SVD_tol*100);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_goldenx_Callback(hObject, eventdata, handles)
global orbx_gold
orbx_gold = (str2double(get(hObject,'String'))*1e-3)';



% --- Executes during object creation, after setting all properties.
function edit_goldenx_CreateFcn(hObject, eventdata, handles)
global orbx_gold
set(hObject,'String',cellstr(num2str(orbx_gold(:)))')
handles.orbx_gold=hObject;
guidata(hObject,handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_BPM1_CreateFcn(hObject, eventdata, handles)
global all_bpm
set(hObject,'String',all_bpm)
% hObject    handle to text_BPM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in load_orbit.
function load_orbit_Callback(hObject, eventdata, handles)
global orbx_gold orby_gold all_bpm
path_name=([getenv('MATLABDATAFILES') '/orbit_correction_GUI']);
actual_dir=pwd;
cd(path_name)
[filename,path,filter]= uigetfile('*.mat',path_name);
if filename~=0
    load (filename)
    for i=1:length(orb_x)
        temp=find(strcmp(all_bpm,bpms(i)));
        if ~isempty(temp)
            orbx_gold(temp) = orb_x(i);
            orby_gold(temp) = orb_y(i);
        end
    end
    set(handles.orbx_gold,'String',cellstr(num2str(orbx_gold(:)*1000,'%6.3f'))')
    set(handles.orby_gold,'String',cellstr(num2str(orby_gold(:)*1000,'%6.3f'))')
end
cd(actual_dir)
% hObject    handle to load_orbit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in all_to_constant.
function all_to_constant_Callback(hObject, eventdata, handles)
global orbx_gold orby_gold x y
orbx_gold = x;
orby_gold = y;
set(handles.orbx_gold,'String',cellstr(num2str(orbx_gold(:)*1000,'%6.3f'))')
set(handles.orby_gold,'String',cellstr(num2str(orby_gold(:)*1000,'%6.3f'))')

% hObject    handle to all_to_constant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in all_to_zero.
function all_to_zero_Callback(hObject, eventdata, handles)
global orbx_gold orby_gold all_bpm

orbx_gold = zeros(1,length(all_bpm));
set(handles.orbx_gold,'String',cellstr(num2str(orbx_gold(:)*1000,'%6.2f'))')
orby_gold = zeros(1,length(all_bpm));
set(handles.orby_gold,'String',cellstr(num2str(orby_gold(:)*1000,'%6.2f'))')



% hObject    handle to all_to_zero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit_goldeny_Callback(hObject, eventdata, handles)
global orby_gold
orby_gold = (str2double(get(hObject,'String'))*1e-3)';

% --- Executes during object creation, after setting all properties.
function edit_goldeny_CreateFcn(hObject, eventdata, handles)
global orby_gold
set(hObject,'String',cellstr(num2str(orby_gold(:)))')
handles.orby_gold=hObject;
guidata(hObject,handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_orbitx_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function text_orbitx_CreateFcn(hObject, eventdata, handles)
handles.orbx=hObject;
guidata(hObject,handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_orbity_Callback(hObject, eventdata, handles)
% hObject    handle to text_orbity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_orbity as text
%        str2double(get(hObject,'String')) returns contents of text_orbity as a double


% --- Executes during object creation, after setting all properties.
function text_orbity_CreateFcn(hObject, eventdata, handles)
handles.orby=hObject;
guidata(hObject,handles)
% hObject    handle to text_orbity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function corry_CreateFcn(hObject, eventdata, handles)
handles.axes_corry=hObject;
guidata(hObject,handles)
% hObject    handle to corry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate corry




% --- Executes during object creation, after setting all properties.
function tot_corry_CreateFcn(hObject, eventdata, handles)
handles.axes_corr_toty=hObject;
guidata(hObject,handles)
% hObject    handle to tot_corry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate tot_corry





function select_nsamples_Callback(hObject, eventdata, handles)
global Nsamples
Nsamples = str2double(get(hObject,'String'));
% hObject    handle to select_nsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of select_nsamples as text
%        str2double(get(hObject,'String')) returns contents of select_nsamples as a double


% --- Executes during object creation, after setting all properties.
function select_nsamples_CreateFcn(hObject, eventdata, handles)
global Nsamples
set(hObject,'String',Nsamples);
% hObject    handle to select_nsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in save_orbit.
function save_orbit_Callback(hObject, eventdata, handles)
global x y all_bpm
path_name=([getenv('MATLABDATAFILES') '/orbit_correction_GUI']);
ini = [datestr(now,30) '_orbit'];
temp = inputdlg({'write a name for the file'},'file name',1,{ini});
if ~isempty(temp)
    filename = temp{1};
    orb_x = x;
    orb_y = y;
    bpms=all_bpm;
    save(fullfile(path_name,filename),'orb_x','orb_y','bpms');
end
% hObject    handle to save_orbit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in print.
function print_Callback(hObject, eventdata, handles)
global h_orbx h_orby h1x h1y leg_orbx leg_orby index

figure;
axes
hold on
grid on
if index<=4
    copyobj(sort(h_orbx,'descend'),gca)
    copyobj(h1x,gca)
    legend([leg_orbx 'predicted'],'Location','Best')
else
    copyobj(sort(h_orbx([1 (index-2):end]),'descend'),gca)
    copyobj(h1x,gca)
    legend([leg_orbx([1 (index-2):end]) 'predicted'],'Location','Best')
end

ylabel('x[mm]')
xlabel('s[m]')
title('horizontal orbit')


figure
axes
hold on
grid on
if index<=4
    copyobj(sort(h_orby,'descend'),gca)
    copyobj(h1y,gca)
    legend([leg_orby 'predicted'],'Location','Best')
else
    copyobj(sort(h_orby([1 (index-2):end]),'descend'),gca)
    copyobj(h1y,gca)
    legend([leg_orby([1 (index-2):end]) 'predicted'],'Location','Best')
end
ylabel('y[mm]')
xlabel('s[m]')
title('vertical orbit')



% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orb_meas(hObject, eventdata, handles)

global index
global x y sigma_x sigma_y
global orb_in
global dim all_bpm_EPICS
global corr_totGx corr_totGy
global I sigma_I Nsamples rep all_corrx all_corry
global cor_outGx cor_outGy corrx_EPICS corry_EPICS
global corrx_ind corry_ind per lim_corrx lim_corry


set(handles.status_text,'String','measuring the initial orbit...')
drawnow

if index>1 %set new correctors settings
    %check if exceeding correctors limits
    set(handles.status_text,'String','measuring the new orbit...')
    drawnow
    if dim=='hor'
        for i=1:length(all_corrx)
            if abs(corr_totGx(i)+cor_outGx(i)*per)>=lim_corrx(i)
                Ican(i)=0;
            else
                Ican(i)=1;
            end
        end
        temp=find(Ican==0);
    else
        for i=1:length(all_corry)
            if abs(corr_totGy(i)+cor_outGy(i)*per)>=lim_corry(i)
                Ican(i)=0;
            else
                Ican(i)=1;
            end
        end
        temp=find(Ican==0);
    end
    if ~isempty(temp)
        for i=1:length(temp)
            names{2*i-1} = all_corrx{temp(i)};
            names{2*i} = [' '];
        end
        eval(sprintf('msgbox(''correctors %s were going to exceed their limits. Reduce the correction percentage or redo the calculation removing those steerers.'',''Warning!'',''warn'')',cell2mat(names)))
        return
    end
    corr_totGx = corr_totGx+cor_outGx*per;
    corr_totGy = corr_totGy+cor_outGy*per;
    pvlist={};
    if dim=='hor'
        BDES = corr_totGx(corrx_ind);
    else
        BDES = corr_totGy(corry_ind);
    end
    statuslist = {};
    statuslist2 = {};
    if dim=='hor'
        for j = 1:length(corrx_EPICS)
            statuslist{j,1} = [corrx_EPICS{j} ':BCTRL'];
            statuslist2{j,1} = [corrx_EPICS{j} ':RAMPSTATE'];
        end
    else
        for j = 1:length(corry_EPICS)
            statuslist{j,1} = [corry_EPICS{j} ':BCTRL'];
            statuslist2{j,1} = [corry_EPICS{j} ':RAMPSTATE'];
        end
    end
    lcaPut(statuslist,BDES');
    status=1;
    while status
        temp=lcaGet(statuslist2,0,'double');
        temp2=find(temp==1);
        if isempty(temp2)
            status=0;
        end
    end
end

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



%prepare orbit and dispersion to go into correction algorithm
orb_in=struct('X',x,'Y',y);

%plotting
plot_me(hObject, eventdata, handles,handles.axes_orbitx,handles.axes_orbity,handles.axes_corr_totx,handles.axes_corr_toty)

%copying values to the gui
set(handles.orbx,'String',cellstr(num2str(x(:)*1000,'%6.3f'))');
set(handles.orby,'String',cellstr(num2str(y(:)*1000,'%6.3f'))');


%store orbit and everything you want
global X Y SIGMA_X SIGMA_Y
X{index}=x;
Y{index}=y;
SIGMA_X{index}=sigma_x;
SIGMA_Y{index}=sigma_y;

set(handles.status_text,'String','Ready')
set(handles.all2constant,'Visible','on')
set(handles.save_orbit,'Visible','on')
set(handles.print,'Visible','on')

set(handles.axes_corry,'Visible','off')
set(get(handles.axes_corry,'Children'),'Visible','off')
set(handles.axes_corrx,'Visible','off')
set(get(handles.axes_corrx,'Children'),'Visible','off')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_me(hObject, eventdata, handles,handles1,handles2,handles3,handles4)
global index
global x y sigma_x sigma_y
global bpm_pos bpm_ind dim
global corrx_pos corry_pos corr_totGx corr_totGy
global lim_corrx lim_corry
global h1x h2x h1y h2y h_orbx h_orby leg_orbx leg_orby

if index==1 %clear some variables
    clear global h1x h2x h1y h2y h_orbx h_orby leg_orbx leg_orby
    global h1x h2x h1y h2y h_orbx h_orby leg_orbx leg_orby
end

color = ([0 0 1; 0 0 0; 1 0.8 0;0 1 0;0 1 1;1 0 1;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand;rand rand rand]);
axes(handles1)
if index==1
    hold off
end
h_orbx(index)=errorbar(bpm_pos,x*1000,sigma_x*1000,'-x','Color',color(index,:));
hold on
grid on
plot(bpm_pos(bpm_ind),x(bpm_ind)*1000,'or')
ylabel('x [mm]')
xlabel('s[m]')
title('Horizontal Orbit','Color','k','FontSize',11)

if index==1
    leg_orbx{index}='initial';
    legend(h_orbx,leg_orbx,'Location','Best')
else
    leg_orbx{index}=sprintf('iteration%g(%s)',index-1,dim);
    if index<=4
        legend([h_orbx h1x],[leg_orbx 'predicted'],'Location','Best')
    else
        delete(h_orbx(index-3))
        legend([h_orbx([1 (index-2):end]) h1x],[leg_orbx([1 (index-2):end]) 'predicted'],'Location','Best')
    end
end


axes(handles2)
if index==1
    hold off
else
    hold on
end
h_orby(index)=errorbar(bpm_pos,y*1000,sigma_y*1000,'-x','Color',color(index,:));
hold on
grid on
plot(bpm_pos(bpm_ind),y(bpm_ind)*1000,'or')
ylabel('y [mm]')
xlabel('s[m]')
title('Vertical Orbit','Color','k','FontSize',11)
if index==1
    leg_orby{index}='initial';
    legend(h_orby,leg_orby,'Location','Best')
else
    leg_orby{index}=sprintf('iteration%g(%s)',index-1,dim);
    if index<=4
        legend([h_orby h1y],[leg_orby 'predicted'],'Location','Best')
    else
        delete(h_orby(index-3))
        legend([h_orby([1 (index-2):end]) h1y],[leg_orby([1 (index-2):end]) 'predicted'],'Location','Best')
    end
end

axes(handles3)
plot(corrx_pos,lim_corrx,'.r')
hold on
temp=get(handles.axes_orbitx,'xlim');
ylim([-max(lim_corrx) max(lim_corrx)])
xlim([temp(1) temp(2)])
plot(corrx_pos,-lim_corrx,'.r')
h5totx = bar(corrx_pos,corr_totGx,'b');
hold off
set(h5totx,'LineStyle','none')
eval(sprintf('title(''Absolute corrector fields | mean=%4.4fKGm | rms=%4.4fKGm'',''Color'',''k'',''FontSize'',11)',mean(corr_totGx)*1000,std(corr_totGx)*1000));
ylabel('Bl [KG-m]')
xlabel('s[m]')
grid on

axes(handles4)
plot(corry_pos,lim_corry,'.r')
hold on
temp=get(handles.axes_orbity,'xlim');
ylim([-max(lim_corry) max(lim_corry)])
xlim([temp(1) temp(2)])
plot(corry_pos,-lim_corry,'.r')
h5toty = bar(corry_pos,corr_totGy,'b');
hold off
set(h5toty,'LineStyle','none')
eval(sprintf('title(''Absolute corrector fields | mean=%4.4fKGm | rms=%4.4fKGm'',''Color'',''k'',''FontSize'',11)',mean(corr_totGy)*1000,std(corr_totGy)*1000));
ylabel('Bl [KG-m]')
xlabel('s[m]')
grid on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [orb_out, cor_out, err]= my_orbit_correction(corr_names2, bpm_names, dim, orb_gold, orb_in,hObject, eventdata, handles)

global RespMatH RespMatV
global cor_out cor_outx cor_outy
global SVD_tol
global bpm_ind index
global all_corrx all_corry all_bpm corrx_ind corry_ind
global corrx_pos corry_pos bpm_pos
global h1x h1y h2x h2y h_orbx h_orby leg_orbx leg_orby
global en_corrx en_corry cor_outGx cor_outGy lim_corrx lim_corry

orbitX = orb_in.X;
orbitY = orb_in.Y;
goldenX = orb_gold;
goldenY = orb_gold;
nBPM = length(all_bpm);


bpm_used = bpm_ind;

if dim == 'hor'
    orbmat = RespMatH;
    orbmat_now = RespMatH;
    cor_flag = zeros(size(all_corrx));
    corr_used = corrx_ind;
else
    orbmat = RespMatV;
    orbmat_now = RespMatV;
    cor_flag = zeros(size(all_corry));
    corr_used = corry_ind;
end

orbitValid = zeros(length(all_bpm),1);
orbitValid(bpm_used) = 1;

cor_flag(corr_used) = 1;

orbit1.X = orb_in.X;
orbit1.Y = orb_in.Y;
golden1.X = orb_gold;
golden1.Y = orb_gold;

orbitValid;
orbit1.Valid = orbitValid;

[orb_out, cor_out, err] = orbcor(dim, orbit1, cor_flag, golden1, SVD_tol, orbmat);

if dim=='hor'
    cor_outx = cor_out;
    cor_outy = zeros(1,length(all_corry));
else
    cor_outx = zeros(1,length(all_corrx));
    cor_outy = cor_out;
end

if dim =='hor'
    orb_out.x = [orbit1.X]' + orbmat_now*cor_out;
    orb_out.y = [orbit1.Y]';
else
    orb_out.x = [orbit1.X]';
    orb_out.y = [orbit1.Y]' + orbmat_now*cor_out;
end

axes(handles.axes_orbitx)
if ~isempty(h1x)
    delete(h1x)
end
if ~isempty(h2x)
    delete(h2x)
end
h1x=plot(bpm_pos,orb_out.x(1:nBPM)*1000,'Color',[1 0 0] );
hold on
h2x=plot(bpm_pos(bpm_used),orb_out.x(bpm_used)*1000,'o','Color',[1 0 0]);

if index<=4
    legend([h_orbx h1x],[leg_orbx 'predicted'],'Location','Best')
else
    legend([h_orbx([1 (index-2):end]) h1x],[leg_orbx([1 (index-2):end]) 'predicted'],'Location','Best')
end


axes(handles.axes_orbity)
if ~isempty(h1y)
    delete(h1y)
end
if ~isempty(h2y)
    delete(h2y)
end
h1y=plot(bpm_pos,orb_out.y(1:nBPM)*1000,'r');
hold on
h2y=plot(bpm_pos(bpm_used),orb_out.y(bpm_used)*1000,'o','Color',[1 0 0]);

if index<=4
    legend([h_orby h1y],[leg_orby 'predicted'],'Location','Best')
else
    legend([h_orby([1 (index-2):end]) h1y],[leg_orby([1 (index-2):end]) 'predicted'],'Location','Best')
end

%convert from rad to kgauss-m
for i=1:length(cor_outx)
    cor_outGx(i) = 10*cor_outx(i)*3.3356*en_corrx(i)/1000;
end
for i=1:length(cor_outy)
    cor_outGy(i) = 10*cor_outy(i)*3.3356*en_corry(i)/1000;
end

if dim=='hor'
    axes(handles.axes_corrx)
    plot(corrx_pos,lim_corrx,'.r')
    hold on
    temp=get(handles.axes_orbitx,'xlim');
    ylim([-max(lim_corrx) max(lim_corrx)])
    xlim([temp(1) temp(2)])
    plot(corrx_pos,-lim_corrx,'.r')
    h5x=bar(corrx_pos,cor_outGx,'k');
    hold off
    set(h5x,'LineStyle','none')
    set(h5x,'Visible','on')
    grid on
    ylabel('Bl [KG-m]')
    eval(sprintf('title(''Required correctors changes | mean=%4.4fKGm | rms=%4.4fKGm'',''Color'',''k'',''FontSize'',11)',mean(cor_outGx),std(cor_outGx)));
else
    axes(handles.axes_corry)
    plot(corry_pos,lim_corry,'.r')
    hold on
    temp=get(handles.axes_orbity,'xlim');
    ylim([-max(lim_corry) max(lim_corry)])
    xlim([temp(1) temp(2)])
    plot(corry_pos,-lim_corry,'.r')
    h5y = bar(corry_pos,cor_outGy,'k');
    hold off
    set(h5y,'LineStyle','none')
    %set(h5y,'Visible','on')
    grid on
    ylabel('Bl [KG-m]')
    eval(sprintf('title(''Required correctors changes | mean=%4.4fKGm | rms=%4.4fKGm'',''Color'',''k'',''FontSize'',11)',mean(cor_outGy),std(cor_outGy)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [orb_out,cor_out, err] = orbcor(dim, orb_in, cor_flag, goal_in, svdtol, orbmat)

clear cor_out

silent = 0;


if dim == 'hor'
    BPMvec = find([orb_in.Valid] == 1);
    orb1=[orb_in.X];
    orb = orb1(BPMvec);
    orbgoal1=[goal_in.X];
    orbgoal = orbgoal1(BPMvec);
elseif dim == 'ver'
    BPMvec = find([orb_in.Valid] == 1);
    orb1=[orb_in.Y];
    orb = orb1(BPMvec);
    orbgoal1=[goal_in.Y];
    orbgoal = orbgoal1(BPMvec);
end

CMvec = find(cor_flag == 1);

orberr = orbgoal - orb;

A = orbmat(BPMvec, CMvec);
[U, S, V] = svd(A,0);
S = diag(S);
oorbmat = orbmat;

%nofsvd et dona els valors de la matriu diagonal S tals que S/Smax son mes grans que svdtol
%nofsvd  gives you the values ​​of the diagonal matrix S such that S / Smax outweigh svdtol
nofsvd = max(1,length(find(S/max(S) > svdtol)));


if (nofsvd > length(CMvec))
    nofsvd = length(CMvec);
elseif isempty(nofsvd)
    nofsvd = max(1,length(CMvec)-10);
end
fprintf('Using %d singular values.\n', nofsvd);

ivec = 1:nofsvd;

% SVD correction
Aa = A*V(:,ivec);
b = Aa\(orberr');
Bb = V(:,ivec)*b;      % corrector strengths

if (std(orberr-(A*Bb)') > 0.1e-3)
    err = 1;
else
    err = 0;
end

crad = zeros(size(cor_flag));

crad(CMvec) = Bb;

cor_out = crad;

if dim == 'hor'
    orbnew = [orb_in.X]' + oorbmat*crad;
    orb_out.x = orbnew';
    orb_out.xrms = std(orbnew);
    orb_out.xavg = mean(orbnew);
    orb_out.y = [orb_in.Y]';
else
    orbnew = [orb_in.Y]' + oorbmat*crad;
    orb_out.y = orbnew';
    orb_out.yrms = std(orbnew);
    orb_out.yavg = mean(orbnew);
    orb_out.x = [orb_in.X]';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initialization(hObject, eventdata, handles)

clear global
debug = 0

global all_corrx all_corry all_bpm corrx_names corry_names bpm_names
global corrx_pos corry_pos bpm_pos bpm_ind corrx_ind corry_ind en_corrx en_corry
isNewRegion = strcmp( get(hObject,'Tag') , 'pushbuttonSelectRegion');
if isNewRegion
    all_corrx = {}; all_corry = {}; all_bpm = {};
    for ii = 1:length(handles.regions)
        all_corrx = [all_corrx; model_nameRegion('XCOR', strtok(handles.regions{ii}))];
        all_corry = [all_corry; model_nameRegion('YCOR', strtok(handles.regions{ii}))];
        all_bpm = [all_bpm; model_nameRegion('BPMS',strtok(handles.regions{ii}))];
        all_bpm = model_nameConvert(all_bpm, 'MAD');
        all_corrx = model_nameConvert(all_corrx, 'MAD');
        all_corry = model_nameConvert(all_corry, 'MAD');
    end
    if debug
        all_corrx = all_corrx(1:2);
        all_corry = all_corry(1:2);
        all_bpm = all_bpm(1:2);
    end
%     switch handles.regions{:}
%         case 'L0',
%         case 'L1',
%         case 'L2',
%         case 'L3',
%         case 'LTU',
%         case 'Undulator',
%         case 'Dump',
%
% %        case 'L3 fbck On',
% %             all_corrx =all_corrx(7:24);
% %             all_corry = all_corry(6:24);
% %             all_bpm = all_bpm(17:32);
% %             useCorrX = 2:2:length(all_corrx);
% %             useCorrY = 2:2:length(all_corry);
%     end
%

    bpm_ind = 1:length(all_bpm);
    corrx_ind = 1:length(all_corrx);
    corry_ind = 1:length(all_corry);

 else
    % all_corrx = {'XC01','XC02','XC03','XC04','XC05','XC06','XC07','XC08','XC09','XC10','XC11','XCA11','XCA12','XCM11','XCM13'};
    % all_corry = {'YC01','YC02','YC03','YC04','YC05','YC06','YC07','YC08','YC09','YC10','YC11','YCA11','YCA12','YCM11','YCM12'};
    % all_bpm = {'BPM3','BPM5','BPM6','BPM8','BPM9','BPM10','BPM11','BPM12','BPM13','BPM14','BPM15','BPMA11','BPMA12','BPM21201','BPMS11','BPMM12','BPM21301'};
    % bpm_ind = ([1:8 10:14 16:17]);
     all_corrx = {'XC01','XC02','XC03'};
     all_corry = {'YC01','YC02','YC03'};
     all_bpm = {'BPM3','BPM5','BPM6','BPM8'};
     bpm_ind = ([1:4]);

     corrx_ind = (([1:1:length(all_corrx)]));
     corry_ind = (([1:1:length(all_corry)]));
end
bpm_names = all_bpm(bpm_ind);
corrx_names = all_corrx(corrx_ind);
corry_names = all_corry(corry_ind);
useCorrX = 1:length(all_corrx);
useCorrY = 1:length(all_corry);

global all_bpm_SLC all_bpm_EPICS all_corrx_EPICS all_corry_EPICS corrx_EPICS corry_EPICS
[all_bpm_SLC, stat] = model_nameConvert(all_bpm, 'SLC');
[all_bpm_EPICS, stat] = model_nameConvert(all_bpm, 'EPICS');
[all_corrx_EPICS, stat] = model_nameConvert(all_corrx, 'EPICS');
[all_corry_EPICS, stat] = model_nameConvert(all_corry, 'EPICS');
[corrx_EPICS, stat] = model_nameConvert(corrx_names, 'EPICS');
[corry_EPICS, stat] = model_nameConvert(corry_names, 'EPICS');
[all_corrx_SLC, stat] = model_nameConvert(all_corrx, 'SLC');
[all_corry_SLC, stat] = model_nameConvert(all_corry, 'SLC');

global RespMatH RespMatV
%get the orbit response and z positions from aida
for j = 1:length(all_bpm)
    %bpm_pos(j)    = aidaget([all_bpm_SLC{j} '//Z'])-2015;
    bpm_pos(j)    = model_rMatGet(all_bpm_SLC{j},{},{},'Z' );

end
tic, disp('Generating Horizontal Response Matrix')
for j = 1:length(all_corrx)
    %corrx_pos(j)    = aidaget([all_corrx_SLC{j} '//Z'])-2015;
    corrx_pos(j)  = model_rMatGet(all_corrx_SLC{j}, {}, {}, 'Z') ;
    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<corrx_pos(j)
            RespMatH(i,j)=0;
        else
            %R        = aidaget({[all_corrx_SLC{j} '//R']},'doublea',{['B=' all_bpm_SLC{i}]});
            %Rm       = reshape(R,6,6);
            %Rm = cell2mat(Rm)';
            %RespMatH(i,j)=Rm(1,2);

            R = model_rMatGet(all_corrx_SLC{j},all_bpm_SLC{i});
            RespMatH(i,j) = R(1,2);
        end
    end
end
toc, tic, disp('Generating Vertical Response Matrix')

for j = 1:length(all_corry)
    corry_pos(j)   = model_rMatGet(all_corry_SLC{j},{},{}, 'Z');

    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<corry_pos(j)
            RespMatV(i,j)=0;
        else
%             R        = aidaget({[all_corry_SLC{j} '//R']},'doublea',{['B=' all_bpm_SLC{i}]});
%             Rm       = reshape(R,6,6);
%             Rm = cell2mat(Rm)';
%             RespMatV(i,j)=Rm(3,4);
                R = model_rMatGet(all_corry_SLC{j},all_bpm_SLC{i});
                RespMatV(i,j) = R(3,4);
        end
    end
end
toc, tic, disp('Getting Model Energy')
for i=1:length(all_corrx)
    %twiss = cell2mat(aidaget([all_corrx_SLC{i} '//twiss'],'doublea'));
    en_corrx(i) = model_rMatGet(all_corrx{i}, {}, {}, 'EN') * 1000;
    %en_corrx(i)=twiss(1)*1000;
end
for i=1:length(all_corry)
    %twiss = cell2mat(aidaget([all_corry_SLC{i} '//twiss'],'doublea'));
    %en_corry(i)=twiss(1)*1000;
    en_corry(i) = model_rMatGet(all_corry{i}, {}, {}, 'EN') * 1000;
end

global dim
dim='hor';

%default golden orbit
global orbx_gold orby_gold
orbx_gold = zeros(1,length(all_bpm));
orby_gold = zeros(1,length(all_bpm));

%default correction percentage
global per
per=0.75;

%default SVD tolerance
global SVD_tol
SVD_tol = 5e-2;

%default number of BPM readings
global Nsamples
Nsamples=50;

%repetition rate
global rep
[sys,accelerator]=getSystem();
pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
rep = lcaGet(pv, 0, 'double');
if isNewRegion
    set(handles.BPM_selection, 'String', all_bpm, 'Value', 1:length(all_bpm));
    set(handles.corrx_selection, 'String', all_corrx, 'Value',useCorrX);
    set(handles.corry_selection,'String', all_corry, 'Value', useCorrY);
    set(handles.text_BPM1, 'String', all_bpm)
    set(handles.text_BPM2, 'String', all_bpm)
    %set(handles.text_BPM1, 'String', all_bpm)



end
disp('Done with initialization')



function text_BPM2_Callback(hObject, eventdata, handles)
% hObject    handle to text_BPM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_BPM2 as text
%        str2double(get(hObject,'String')) returns contents of text_BPM2 as a double


% --- Executes during object creation, after setting all properties.
function text_BPM2_CreateFcn(hObject, eventdata, handles)
global all_bpm
set(hObject,'String',all_bpm)
% hObject    handle to text_BPM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function calculate_correction_CreateFcn(hObject, eventdata, handles)
handles.calc_corr=hObject;
guidata(hObject,handles)
% hObject    handle to calculate_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function apply_correction_CreateFcn(hObject, eventdata, handles)
handles.do_corr=hObject;
guidata(hObject,handles)
% hObject    handle to apply_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function restore_initial_currents_CreateFcn(hObject, eventdata, handles)
handles.restore=hObject;
guidata(hObject,handles)
% hObject    handle to restore_initial_currents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function text_percentage_CreateFcn(hObject, eventdata, handles)
handles.text_per=hObject;
guidata(hObject,handles)
% hObject    handle to text_percentage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function status_text_CreateFcn(hObject, eventdata, handles)
handles.status_text=hObject;
guidata(hObject,handles)
% hObject    handle to status_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function all_to_constant_CreateFcn(hObject, eventdata, handles)
handles.all2constant=hObject;
guidata(hObject,handles)
% hObject    handle to all_to_constant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function save_orbit_CreateFcn(hObject, eventdata, handles)
handles.save_orbit=hObject;
guidata(hObject,handles)
% hObject    handle to save_orbit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function print_CreateFcn(hObject, eventdata, handles)
handles.print=hObject;
guidata(hObject,handles)
% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes when user attempts to close orbit_correction.
function orbit_correction_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to orbit_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/toolbox/orbit_correction.m', which('orbit_correction'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end



% --- Executes on button press in pushbuttonSelectRegion.
function pushbuttonSelectRegion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regionList = {'L0', 'L1', 'L2', 'L3', 'LTU', 'Undulator', 'Dump'};
regI = listdlg('PromptString','Select Regions(s)', 'SelectionMode', 'Multiple', ...
                                     'listString', regionList);
handles.regions = regionList(regI);

initialization(hObject, eventdata, handles)




% --- Executes on button press in feedbacksOnOff.
function feedbacksOnOff_Callback(hObject, eventdata, handles)
global all_corrx all_corry all_bpm

feedbackOn= get(hObject,'Value');

if feedbackOn,
     set(hObject,'String', 'Feedbacks On');
     [bpmIndx xcorIndx ycorIndx] = isUsedInFeedback(all_bpm, all_corrx, all_corry);

    set(handles.BPM_selection, 'Value', find(~bpmIndx));
    set(handles.corrx_selection, 'Value', find(~xcorIndx));
    set(handles.corry_selection, 'Value', find(~ycorIndx));
else
     %  [bpmIndx, xcorIndx, ycorIndx ] = selectElements(hObject, eventdata, handles);
    set(hObject, 'String', 'Feedbacks Off');
    set(handles.BPM_selection, 'Value', 1:length(all_bpm));
    set(handles.corrx_selection, 'Value', 1:length(all_corrx));
    set(handles.corry_selection, 'Value', 1:length(all_corry));



end

function [bpmIndx, xcorIndx, ycorIndx ] = selectElements(hObject, eventdata, handles)
global all_corrx all_corry all_bpm




function [bpmIndx xcorIndx ycorIndx] = isUsedInFeedback(all_bpm, all_corrx, all_corry)
% Figure out devices used by feedbacks

devList = {'BPMS', 'XCOR', 'YCOR'};
devNamePV = aidalist('FBCK:FB%:TR%:%DEVNAME');
devNamePV = devNamePV(~cellfun('isempty',devNamePV));

devName = lcaGet(devNamePV');
devNamePV = devNamePV(~cellfun('isempty',devName));
devName = devName(~cellfun('isempty',devName));


for ii = 1:length(devList)
    thisName = devList{ii};
    indx = strmatch(thisName, devName);
    name = devName(indx);

    devUsedPv = strrep(devNamePV(indx), 'DEVNAME','USED');
    devUsed = lcaGet(devUsedPv');
    usedIndx = strmatch('YES', devUsed);

    inFeedback = name(usedIndx);
    inFeedback = strrep(inFeedback,':X', '');
    inFeedback = strrep(inFeedback,':Y', '');
    inFeedback = strrep(inFeedback,':BCTRL', '');
    inFeedback = unique(inFeedback)
    inFeedback = model_nameConvert(inFeedback,'MAD');
    switch thisName
        case 'BPMS',
            bpmIndx = zeros(size(all_bpm));
            [~,~,bpmIndxFound ] = intersect(inFeedback, all_bpm);
            bpmIndx(bpmIndxFound) = 1;
        case 'XCOR',
            xcorIndx = zeros(size(all_corrx));
            [~,~,xcorIndxFound] = intersect(inFeedback, all_corrx);
            xcorIndx(xcorIndxFound) = 1;
        case 'YCOR',
            ycorIndx = zeros(size(all_corry));
            [~,~,ycorIndxFound] = intersect(inFeedback, all_corry);
            ycorIndx(ycorIndxFound) = 1;
    end


end



% --- Executes on button press in includeEplusToggle.
function includeEplusToggle_Callback(hObject, eventdata, handles)
% hObject    handle to includeEplusToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of includeEplusToggle
val =  get(hObject,'Value');
if val,
    set(hObject,'String','Exclude e+');
else
    set(hObject, 'String', 'Exclude e+');
end

selectedXcor = get(handles.corrx_selection,'String');
selectedYcor = get(handles.corry_selection,'String');
selectedXcorIndx = zeros(size(selectedXcor));
selectedYcorIndx = zeros(size(selectedYcor));

selectedXcorIndx(get(handles.corrx_selection,'Value')) = 1;
selectedYcorIndx(get(handles.corry_selection,'Value')) = 1; %1 if selected 0 if not

xcorEplusSectors = strrep('XCOR:LISS:N02','SS', {'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'});
xcorEplusList ={};
for s =  {'3' '5' '7'}, xcorEplusList = [xcorEplusList strrep(xcorEplusSectors, 'N', s)]; end
xcorEplusList = [xcorEplusList strrep(xcorEplusSectors, 'N02', '900')];


ycorEplusSectors = strrep('YCOR:LISS:N03','SS', {'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'});
ycorEplusList ={};
for s =  {'2' '4' '6' '8'}, ycorEplusList = [ycorEplusList strrep(ycorEplusSectors, 'N', s)]; end



xcorEplusList = model_nameConvert(xcorEplusList, 'MAD'); ycorEplusList = model_nameConvert(ycorEplusList, 'MAD');
[~,  xI, ~]  = intersect( selectedXcor, xcorEplusList); [~, yI,~]  = intersect( selectedYcor, ycorEplusList);
xcorEplusIndx = zeros(size(selectedXcor));  ycorEplusIndx = zeros(size(selectedYcor));
xcorEplusIndx(xI) = 1; ycorEplusIndx(yI) = 1;




xcorRemoveIndx = selectedXcorIndx & ~xcorEplusIndx;
ycorRemoveIndx = selectedYcorIndx & ~ycorEplusIndx;

set(handles.corrx_selection,'Value',find(xcorRemoveIndx) );
set(handles.corry_selection,'Value',find(ycorRemoveIndx) );








