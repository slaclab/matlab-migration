function varargout = quad_align(varargin)
% QUAD_ALIGN M-file for quad_align.fig
%      QUAD_ALIGN, by itself, creates a new QUAD_ALIGN or raises the existing
%      singleton*.
%
%      H = QUAD_ALIGN returns the handle to a new QUAD_ALIGN or the handle to
%      the existing singleton*.
%
%      QUAD_ALIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUAD_ALIGN.M with the given input arguments.
%
%      QUAD_ALIGN('Property','Value',...) creates a new QUAD_ALIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before quad_align_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to quad_align_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help quad_align

% Last Modified by GUIDE v2.5 21-Nov-2007 15:47:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @quad_align_OpeningFcn, ...
                   'gui_OutputFcn',  @quad_align_OutputFcn, ...
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


% --- Executes just before quad_align is made visible.
function quad_align_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to quad_align (see VARARGIN)

% Choose default command line output for quad_align
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes quad_align wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = quad_align_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in quad_selection.
function quad_selection_Callback(hObject, eventdata, handles)
global quad_names quad_ind quad_EPICS
contents = get(hObject,'String');
quad_ind = get(hObject,'Value');
quad_names={contents{get(hObject,'Value')}};
[quad_EPICS, stat] = model_nameConvert(quad_names, 'EPICS');
% hObject    handle to quad_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns quad_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from quad_selection


% --- Executes during object creation, after setting all properties.
function quad_selection_CreateFcn(hObject, eventdata, handles)
global quad_ind all_quad
set(hObject,'String',all_quad)
set(hObject,'Value',quad_ind)
% hObject    handle to quad_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_bpm_Callback(hObject, eventdata, handles)
global max_bpm_diff
max_bpm_diff=str2double(get(hObject,'String'));
% hObject    handle to max_bpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_bpm as text
%        str2double(get(hObject,'String')) returns contents of max_bpm as a double


% --- Executes during object creation, after setting all properties.
function max_bpm_CreateFcn(hObject, eventdata, handles)
global max_bpm_diff
set(hObject,'String',max_bpm_diff);
% hObject    handle to max_bpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function number_steps_Callback(hObject, eventdata, handles)
global nsteps
nsteps = str2double(get(hObject,'String'));
% hObject    handle to number_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number_steps as text
%        str2double(get(hObject,'String')) returns contents of number_steps as a double


% --- Executes during object creation, after setting all properties.
function number_steps_CreateFcn(hObject, eventdata, handles)
global nsteps
set(hObject,'String',nsteps)
% hObject    handle to number_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function number_samples_Callback(hObject, eventdata, handles)
global Nsamples
Nsamples = str2double(get(hObject,'String'));
% hObject    handle to number_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number_samples as text
%        str2double(get(hObject,'String')) returns contents of number_samples as a double


% --- Executes during object creation, after setting all properties.
function number_samples_CreateFcn(hObject, eventdata, handles)
global Nsamples
set(hObject,'String',Nsamples);
% hObject    handle to number_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in do_meas.
function do_meas_Callback(hObject, eventdata, handles)

clear global orx ory sigma_orx sigma_ory orbitx orbity sigma_orx sigma_ory plot_ind ...
    sigmax sigmay delta_orbitx delta_orbity delta_sigmax delta_sigmay mis_x mis_y sigma_mis_x sigma_mis_y ...
    ORBITX ORBITY SIGMAX SIGMAY QUAD_NAMES MIS_X MIS_Y SIGMA_MIS_X SIGMA_MIS_Y ...
    ORQX SIGMA_ORQX ORQY SIGMA_ORQY r12 r34 BPM_IND FIELDS KICK_X KICK_Y ...
    OFFSET_X OFFSET_Y SIGMA_OFFSETX SIGMA_OFFSETY POS_OFFSET
global nsteps quad_names quad_ind ini_field
global orbitx orbity sigmax sigmay
global RespMatH RespMatV quad_pos max_bpm_diff
global quad_EPICS en_quad max_field field fields R12 R34
global ORBITX ORBITY SIGMAX SIGMAY QUAD_NAMES
global mis_x mis_y sigma_mis_x sigma_mis_y MIS_X MIS_Y SIGMA_MIS_X SIGMA_MIS_Y
global number_bpms bpm_ind
global kick_x kick_y bpm_pos KICK_X KICK_Y
global r12 r34 BPM_IND
global ORQX SIGMA_ORQX ORQY SIGMA_ORQY FIELDS orqx orqy sigma_orqx sigma_orqy
global offset_x sigma_offsetx offset_y sigma_offsety pos_offset
global OFFSET_X OFFSET_Y SIGMA_OFFSETX SIGMA_OFFSETY POS_OFFSET
global orbitx0 sigmax0 orbity0 sigmay0 ORBITX0 ORBITY0 SIGMAX0 SIGMAY0

set(handles.global_info,'Visible','off')
set(handles.quad_info,'Visible','off')
set(handles.bpm_info,'Visible','off')
set(handles.save_data,'Visible','off')
set(handles.print_quad,'Visible','off')
set(handles.print_global,'Visible','off')
set(handles.quad_plot_selection,'Visible','off')
set(handles.bpm_plot_selection,'Visible','off')

%for plotting stuff
global plot_bpm_ind plot_quad_ind
plot_bpm_ind=1;
plot_quad_ind=1;


for i=1:length(quad_names)
    actual=quad_names{i};
    quadpos=quad_pos(quad_ind(i));
    temp = find(bpm_pos > quadpos);
    temp2=temp(1);
    bpm_ind1 = temp2:1:(temp2+number_bpms-1);
    bpm_ind2 = temp2:1:length(bpm_pos);
    if length(bpm_ind1)<length(bpm_ind2)
        bpm_ind=bpm_ind1;
    else
        bpm_ind=bpm_ind2;
    end
    set(handles.info_text,'String',sprintf('measuring %s ...',actual));
    drawnow

    %maximum kick which corresponds to the maximum BPM difference if the misalignment is 1mm
    matrix_x = RespMatH;
    matrix_y = RespMatV;
    for m=1:length(bpm_ind)
        tempx=matrix_x(bpm_ind(m),quad_ind(i));
        tempy=matrix_y(bpm_ind(m),quad_ind(i));
        %dipole kick in radians
        if abs(tempx)<=1e-5
            kick_x(m)=9e9999;
        else
            kick_x(m) = abs(max_bpm_diff*1e-3/matrix_x(bpm_ind(m),quad_ind(i)));
        end
        if abs(tempy)<=1e-5
            kick_y(m)=9e99;
        else
            kick_y(m) = abs(max_bpm_diff*1e-3/matrix_y(bpm_ind(m),quad_ind(i)));
        end
    end
    max_kick_x = abs(min(kick_x));
    max_kick_y = abs(min(kick_y));
    max_kick=min(max_kick_x,max_kick_y);
    %maximum field
    max_field=max_kick*3.3356*10*en_quad(quad_ind(i))/(1000*1e-3);
    %check limits (to be done)
    field=max_field/nsteps;
    fields = ([ini_field(quad_ind(i)):field:(ini_field(quad_ind(i))+max_field)])

    pvlist={};
    for j=1:(nsteps+1)
        %adding current to the quad
        if j~1
                        lcaPut([quad_EPICS{i} ':BCTRL'],fields(j))
                        status=1;
                        while status
                            status=lcaGet([quad_EPICS{i} ':RAMPSTATE'],0,'double');
                        end
%             if you want to trim
%             lcaPut([quad_EPICS{i} ':BDES'],fields(j))
%             lcaPut([quad_EPICS{i} ':CTRL'],'TRIM');
%             status=1;
%             while status
%                 temp=lcaGet([quad_EPICS{i} ':CTRLSTATE']);
%                 if strcmp(temp,'Done')
%                     status=0;
%                 end
%             end
        end
        [orbitx(j,:),sigmax(j,:),orbity(j,:),sigmay(j,:)]=get_orbit(hObject,eventdata,handles);
    end

    %going back to the initial current value (triming)
    lcaPut([quad_EPICS{i} ':BDES'],ini_field(quad_ind(i)))
    lcaPut([quad_EPICS{i} ':CTRL'],'TRIM');
    status=1;
    while status
        temp=lcaGet([quad_EPICS{i} ':CTRLSTATE']);
        if strcmp(temp,'Done')
            status=0;
        end
    end
    %function to get the relation orbit/integrated_quad_field for all BPMs
    %and orbit0
    [orqx,sigma_orqx,orqy,sigma_orqy,orbitx0,sigmax0,orbity0,sigmay0]=get_orbit_over_gl(orbitx,sigmax,orbity,sigmay,fields);

    %R12 and R34 from the model
    R12=RespMatH(:,quad_ind(i))';
    R34=RespMatV(:,quad_ind(i))';

    %function to get the misalignment of the quadrupole
    [mis_x,sigma_mis_x,mis_y,sigma_mis_y] = get_mis(R12,R34,orqx,sigma_orqx,orqy,sigma_orqy,en_quad,bpm_ind,quad_ind(i));

    %function to get the offset
    [offset_x,sigma_offsetx,offset_y,sigma_offsety,pos_offset] = get_offset(mis_x,sigma_mis_x,mis_y,sigma_mis_y,quad_ind(i));

    %store stuff
    ORBITX{i}=orbitx;
    ORBITY{i}=orbity;
    SIGMAX{i} = sigmax;
    SIGMAY{i} = sigmay;
    ORBITX0{i}=orbitx0;
    ORBITY0{i}=orbity0;
    SIGMAX0{i} = sigmax0;
    SIGMAY0{i} = sigmay0;
    QUAD_NAMES{i} = actual;
    MIS_X(i) = mis_x;
    MIS_Y(i) = mis_y;
    SIGMA_MIS_X(i) = sigma_mis_x;
    SIGMA_MIS_Y(i) = sigma_mis_y;
    ORQX{i}=orqx;
    SIGMA_ORQX{i}=sigma_orqx;
    ORQY{i}=orqy;
    SIGMA_ORQY{i}=sigma_orqy;
    r12{i}=R12;
    r34{i}=R34;
    BPM_IND{i}=bpm_ind;
    FIELDS{i}=fields;
    KICK_X{i}=kick_x;
    KICK_Y{i}=kick_y;
    OFFSET_X(i)=offset_x;
    OFFSET_Y(i)=offset_y;
    SIGMA_OFFSETX(i)= sigma_offsetx;
    SIGMA_OFFSETY(i)= sigma_offsety;
    POS_OFFSET(i)= pos_offset;
end


bpm_ind=BPM_IND{1};
plot_mis(hObject,eventdata,handles)
plot_quad(hObject,eventdata,handles)
plot_bpm(hObject,eventdata,handles)

set(handles.quad_plot_selection,'String',quad_names)
set(handles.quad_plot_selection,'Value',plot_quad_ind)
set(handles.bpm_plot_selection,'Value',plot_bpm_ind)
set(handles.info_text,'String','Ready');
set(handles.global_info,'Visible','on')
set(handles.quad_info,'Visible','on')
set(handles.bpm_info,'Visible','on')
set(handles.save_data,'Visible','on')
set(handles.print_quad,'Visible','on')
set(handles.print_global,'Visible','on')
set(handles.quad_plot_selection,'Visible','on')
set(handles.bpm_plot_selection,'Visible','on')

% hObject    handle to do_meas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_mis(hObject,eventdata,handles)
global bpm_pos quad_pos orbitx quad_ind
global MIS_X MIS_Y SIGMA_MIS_Y SIGMA_MIS_X
global sigmax sigmay orbity offset_x sigma_offsetx offset_y sigma_offsety pos_offset
%plot misalignment and current orbit along the machine
axes(handles.axes_misx)
errorbar(quad_pos(quad_ind),MIS_X*1000,SIGMA_MIS_X*1000,'ok');
hold on
errorbar(bpm_pos,orbitx(1,:)*1000,sigmax(1,:)*1000,'ob-')
errorbar(pos_offset,offset_x*1000,sigma_offsetx*1000,'om-')
hold off
xlabel('s[m]')
ylabel('misalignment - orbit [mm]')
legend('calculated misalignment','orbit','BPM offset','Location','Best')
title('horizontal misalignment, orbit and BPM offset')
grid on

axes(handles.axes_misy)
errorbar(quad_pos(quad_ind),MIS_Y*1000,SIGMA_MIS_Y*1000,'ok')
hold on
errorbar(bpm_pos,orbity(1,:)*1000,sigmay(1,:)*1000,'ob-')
errorbar(pos_offset,offset_y*1000,sigma_offsety*1000,'om-')
hold off
xlabel('s[m]')
ylabel('misalignment - orbit [mm]')
legend('calculated misalignment','orbit','BPM offset','Location','Best')
title('vertical misalignment, orbit and BPM offset')
grid on


% --- Executes during object creation, after setting all properties.
function quad_alignment_CreateFcn(hObject, eventdata, handles)
clear global

global all_quad all_bpm quad_names all_quad_EPICS quad_EPICS
global all_bpm_SLC all_bpm_EPICS all_quad_EPICS bpm_ind
global quad_pos bpm_pos quad_ind en_quad all_quad_SLC

all_quad={'QA01','QA02','QE01','QE02','QE03','QE04','QM01','QM02','QB','QM03','QM04','QA11','QA12','QM11','QM12','QM13'};
%all_bpm = {'BPM3','BPM5','BPM6','BPM8','BPM9','BPM10','BPM11','BPM12','BPM14','BPM15','BPMA11','BPMA12','BPM21201','BPMM12','BPM21301'};
all_bpm= {'BPM3','BPM5','BPM6','BPM8','BPM9','BPM10','BPM12','BPM14','BPM15','BPMA11','BPM21201','BPMM12','BPM21301'};
quad_ind = (1);
quad_names = all_quad(quad_ind);


[all_bpm_SLC, stat] = model_nameConvert(all_bpm, 'SLC');
[all_bpm_EPICS, stat] = model_nameConvert(all_bpm, 'EPICS');
[all_quad_EPICS, stat] = model_nameConvert(all_quad, 'EPICS');
[quad_EPICS, stat] = model_nameConvert(quad_names, 'EPICS');
[all_quad_SLC, stat] = model_nameConvert(all_quad, 'SLC');
bpm_ind=1;

global RespMatH RespMatV
%get the orbit response and z positions from aida
for j = 1:length(all_bpm)
    bpm_pos(j)    = pvaGet([all_bpm_SLC{j} ':Z'])-2015;
end

for j = 1:length(all_quad)
    quad_pos(j)    = pvaGet([all_quad_SLC{j} ':Z'])-2015;
    for i=1:length(all_bpm_SLC)
        if bpm_pos(i)<quad_pos(j)
            RespMatH(i,j)=0;
        else
            try
                requestBuilder = pvaRequest({[all_quad_SLC{j} ':R']});
                requestBuilder.returning(AIDA_DOUBLE_ARRAY);
                requestBuilder.with('B',all_bpm_SLC{i});
                R = toArray(requestBuilder.get());
            catch
                disp(sprintf('aidaget failure for %s:R', all_quad_SLC{j}));
            end
            Rm       = reshape(R,6,6);
            Rm = cell2mat(Rm)';
            RespMatH(i,j)=Rm(1,2);
            RespMatV(i,j)=Rm(3,4);
        end
    end
end


for i=1:length(all_quad_SLC)
    try
        twiss = cell2mat(aidaget([all_quad_SLC{i} ':twiss'],'doublea'));
    catch
        disp(sprintf('aidaget failure for %s:twiss', all_quad_SLC{i}));
    end
    en_quad(i)=twiss(1)*1000;
end


%default number of BPM readings
global Nsamples
Nsamples=50;

%reading initial quadrupole strenghts and limits
global ini_field lim_field
for j = 1:length(all_quad_EPICS)
    pvlist_quad{j} = [all_quad_EPICS{j} ':BACT'];
    pvlist_lim_quad{j} = [all_quad_EPICS{j} ':BACT.HOPR'];
    pvlist_trim{j}=[all_quad_EPICS{j} ':CTRL'];
    pvlist_trim_value{j}=['TRIM'];
end

ini_field = lcaGet(pvlist_quad(:), 0, 'double')';
lim_field = lcaGet(pvlist_lim_quad(:), 0, 'double')';

%trim the quads
% lcaPut(pvlist_trim',pvlist_trim_value');
% status=1;
% while status
%     for i=1:length(all_quad_EPICS)
%         temp(i)=lcaGet([all_quad_EPICS{i} ':CTRLSTATE']);
%         if strcmp(temp(i),'Done')
%             temp2(i)=0;
%         else
%             temp2(i)=1;
%         end
%     end
%     if isempty(find(temp2,1))
%         status=0;
%     end
% end



%repetition rate
global rep
[sys,accelerator]=getSystem();
pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
rep = lcaGet(pv, 0, 'double');

%maximum bpm difference in mm (assuming 1mm offset in the quad)
global max_bpm_diff
max_bpm_diff=2;

%number of number_steps per corrector
global nsteps
nsteps=3;

%number of bpms to fit the quadrupole kick
global number_bpms
number_bpms=3;

% hObject    handle to orbit_response_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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




% --- Executes on selection change in plot_quad.
function plot_quad_Callback(hObject, eventdata, handles)
global plot_quad_ind quad_pos quad_ind bpm_pos bpm_ind number_bpms
plot_quad_ind = get(hObject,'Value');

quadpos=quad_pos(quad_ind(plot_quad_ind));
temp = find(bpm_pos > quadpos);
temp2=temp(1);
bpm_ind1 = temp2:1:(temp2+number_bpms-1);
bpm_ind2 = temp2:1:length(bpm_pos);
if length(bpm_ind1)<length(bpm_ind2)
    bpm_ind=bpm_ind1;
else
    bpm_ind=bpm_ind2;
end

plot_quad(hObject,eventdata,handles)
plot_bpm(hObject,eventdata,handles)


% hObject    handle to plot_quad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_quad contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_quad


% --- Executes during object creation, after setting all properties.
function plot_quad_CreateFcn(hObject, eventdata, handles)
handles.quad_plot_selection=hObject;
guidata(hObject,handles)
% hObject    handle to plot_quad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_quad(hObject,eventdata,handles)

global hquadx hquady R12 R34 orqx orqy sigma_orqx sigma_orqy bpm_ind
global r34 r12 ORQX SIGMA_ORQX ORQY SIGMA_ORQY
global mis_x mis_y sigma_mis_x sigma_mis_y
global MIS_X MIS_Y SIGMA_MIS_X SIGMA_MIS_Y plot_quad_ind

R12=r12{plot_quad_ind};
R34=r34{plot_quad_ind};
orqx=ORQX{plot_quad_ind};
orqy=ORQY{plot_quad_ind};
sigma_orqx=SIGMA_ORQX{plot_quad_ind};
sigma_orqy=SIGMA_ORQY{plot_quad_ind};
mis_x=MIS_X(plot_quad_ind);
mis_y=MIS_Y(plot_quad_ind);
sigma_mis_x = SIGMA_MIS_X(plot_quad_ind);
sigma_mis_y = SIGMA_MIS_Y(plot_quad_ind);

axes(handles.quadx_axes)
hquadx=errorbar(R12(bpm_ind),orqx(:,bpm_ind),sigma_orqx(:,bpm_ind),'.b');
hold on
grid on
xlabel('R12 [m/rad]')
ylabel('orbit / quad field [m/KG]')
p = polyfit(R12(bpm_ind), orqx(:,bpm_ind),1);
hquadx(2) = plot(R12(bpm_ind),polyval(p,R12(bpm_ind)),'-k');
legend('data points',sprintf('linear fit, slope=%g',p(1)),'Location','Best')
hold off

axes(handles.quady_axes)
hquady=errorbar(R34(bpm_ind),orqy(:,bpm_ind),sigma_orqy(:,bpm_ind),'.b');
hold on
grid on
xlabel('R34 [m/rad]')
ylabel('orbit / quad field [m/KG]')
p = polyfit(R34(bpm_ind), orqy(:,bpm_ind),1);
hquady(2) = plot(R34(bpm_ind),polyval(p,R34(bpm_ind)),'-k');
legend('data points',sprintf('linear fit, slope=%g',p(1)),'Location','Best')
hold off


% hObject    handle to show_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function quadx_axes_CreateFcn(hObject, eventdata, handles)
handles.quadx_axes=hObject;
guidata(hObject,handles)
% hObject    handle to quadx_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate quadx_axes


% --- Executes during object creation, after setting all properties.
function quady_axes_CreateFcn(hObject, eventdata, handles)
handles.quady_axes=hObject;
guidata(hObject,handles)
% hObject    handle to quady_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate quady_axes



% --- Executes during object creation, after setting all properties.
function all_misx_CreateFcn(hObject, eventdata, handles)
handles.axes_misx=hObject;
guidata(hObject,handles)
% hObject    handle to all_misx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate all_misx


% --- Executes during object creation, after setting all properties.
function all_misy_CreateFcn(hObject, eventdata, handles)
handles.axes_misy=hObject;
guidata(hObject,handles)
% hObject    handle to all_misy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate all_misy



function number_bpms_Callback(hObject, eventdata, handles)
global number_bpms orbitx
number_bpms = str2double(get(hObject,'String'));

if ~isempty(orbitx)
    global plot_quad_ind quad_names quad_pos quad_ind bpm_pos
    global R12 R34 orqx sigma_orqx orqy sigma_orqy en_quad bpm_ind
    global mis_x sigma_mis_x mis_y sigma_mis_y
    global offset_x sigma_offsetx offset_y sigma_offsety pos_offset



    actual=quad_names{plot_quad_ind};
    quadpos=quad_pos(quad_ind(plot_quad_ind));
    temp = find(bpm_pos > quadpos);
    temp2=temp(1);
    bpm_ind1 = temp2:1:(temp2+number_bpms-1);
    bpm_ind2 = temp2:1:length(bpm_pos);
    if length(bpm_ind1)<length(bpm_ind2)
        bpm_ind=bpm_ind1;
    else
        bpm_ind=bpm_ind2;
    end

    [mis_x,sigma_mis_x,mis_y,sigma_mis_y] = get_mis(R12,R34,orqx,sigma_orqx,orqy,sigma_orqy,en_quad, bpm_ind,quad_ind(plot_quad_ind));
    [offset_x,sigma_offsetx,offset_y,sigma_offsety,pos_offset] = get_offset(mis_x,sigma_mis_x,mis_y,sigma_mis_y,quad_ind(plot_quad_ind));
    plot_mis(hObject,eventdata,handles)
    plot_quad(hObject,eventdata,handles)
end

% hObject    handle to number_bpms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of number_bpms as text
%        str2double(get(hObject,'String')) returns contents of number_bpms as a double


% --- Executes during object creation, after setting all properties.
function number_bpms_CreateFcn(hObject, eventdata, handles)
global number_bpms
set(hObject,'String',number_bpms)
% hObject    handle to number_bpms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in print_misalign.
function print_misalign_Callback(hObject, eventdata, handles)
global quad_pos quad_ind mis_x mis_y sigma_mis_x sigma_mis_y bpm_pos orbitx sigmax orbity sigmay
global bpm_pos quad_pos orbitx quad_ind mis_x mis_y sigma_mis_x sigma_mis_y
global MIS_X MIS_Y SIGMA_MIS_Y SIGMA_MIS_X
global sigmax sigmay orbity OFFSET_X OFFSET_Y SIGMA_OFFSETX SIGMA_OFFSETY POS_OFFSET
%plot misalignment and current orbit along the machine
figure()
subplot(2,1,1)
errorbar(quad_pos(quad_ind),MIS_X*1000,SIGMA_MIS_X*1000,'or');
hold on
errorbar(POS_OFFSET,OFFSET_X*1000,SIGMA_OFFSETX,'ok')
hold off
xlabel('s[m]')
ylabel('misalignment - BPM offset [mm]')
legend('calculated misalignment','BPM offset')
title('horizontal misalignment and BPM offset along the machine')
grid on

subplot(2,1,2)
errorbar(quad_pos(quad_ind),MIS_Y*1000,SIGMA_MIS_Y*1000,'or')
hold on
errorbar(POS_OFFSET,OFFSET_Y*1000,SIGMA_OFFSETY*1000,'ok')
hold off
xlabel('s[m]')
ylabel('misalignment - BPM offset [mm]')
legend('calculated misalignment','BPM offset')
title('vertical misalignment and BPM offset along the machine')
grid on
% hObject    handle to print_misalign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in print_quad.
function print_quad_Callback(hObject, eventdata, handles)
global hquadx hquady
figure;
axes
hold on
grid on
copyobj(sort(hquadx,'descend'),gca)
xlabel('R12 [m/rad]')
ylabel('orbit / quad field [m/KG]')
legend('data points','linear fit','Location','Best')

figure;
axes
hold on
grid on
copyobj(sort(hquady,'descend'),gca)
xlabel('R34 [m/rad]')
ylabel('orbit / quad field [m/KG]')
legend('data points','linear fit','Location','Best')


% hObject    handle to print_quad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BPM_IND ORBITX ORBITY SIGMAX SIGMAY QUAD_NAMES MIS_X MIS_Y SIGMA_MIS_X SIGMA_MIS_Y r12 r34 ORQX SIGMA_ORQX ORQY SIGMA_ORQY FIELDS en_quad KICKX KICKY OFFSET_X OFFSET_Y SIGMA_OFFSETX SIGMA_OFFSETY POS_OFFSET
ini = [datestr(now,30) 'quadrupole_misalignment'];
path_name=([getenv('MATLABDATAFILES') '/quad_misalignment_GUI']);
temp = inputdlg({'write a name for the file'},'file name',1,{ini});
if ~isempty(temp)
    filename = temp{1};
    save(fullfile(path_name,filename),'BPM_IND','ORBITX','ORBITY','SIGMAX','SIGMAY','QUAD_NAMES','MIS_X','MIS_Y','SIGMA_MIS_X','SIGMA_MIS_Y','r12','r34','ORQX','SIGMA_ORQX','ORQY','SIGMA_ORQY','FIELDS','en_quad','KICKX','KICKY','OFFSET_X', 'OFFSET_Y', 'SIGMA_OFFSETX', 'SIGMA_OFFSETY', 'POS_OFFSET');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [orqx,sigma_orqx,orqy,sigma_orqy,orbitx0,sigmax0,orbity0,sigmay0]=get_orbit_over_gl(orbitx,sigmax,orbity,sigmay,fields)

global all_bpm_EPICS

for j=1:length(all_bpm_EPICS)
    px(j,:) = polyfit(fields(:), orbitx(:,j),1);
    py(j,:) = polyfit(fields(:), orbity(:,j),1);
    for i=1:length(fields)
        Sc(i)=1/(sigmax(i,j)^2);
        Sxc(i)=fields(i)/(sigmax(i,j)^2);
        Syc(i)=orbitx(i)/(sigmax(i,j)^2);
        Sxxc(i)=fields(i)^2/(sigmax(i,j)^2);
        Sxyc(i)=fields(i)*orbitx(i,j)/(sigmax(i,j)^2);
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
    for i=1:length(fields)
        Sc(i)=1/(sigmay(i,j)^2);
        Sxc(i)=fields(i)/(sigmay(i,j)^2);
        Syc(i)=orbity(i)/(sigmay(i,j)^2);
        Sxxc(i)=fields(i)^2/(sigmay(i,j)^2);
        Sxyc(i)=fields(i)*orbity(i,j)/(sigmay(i,j)^2);
    end
    Sy(j)=sum(Syc);
    Sxy(j)=sum(Sxyc);
    sigma_a2y(j)=Sxx(j)/deno(j);
    sigma_b2y(j)=S(j)/deno(j);
end

%considering 1st order polinomy
orqx=px(:,1)';
orqy=py(:,1)';
sigma_orqx=sigma_b2x;
sigma_orqy=sigma_b2y;

orbitx0=px(:,2)'+fields(1).*orqx;
orbity0=py(:,2)'+fields(1).*orqy;
sigmax0=sigma_a2x;
sigmay0=sigma_a2y;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function    [mis_x,sigma_mis_x,mis_y,sigma_mis_y] = get_mis(R12,R34,orqx,sigma_orqx,orqy,sigma_orqy,en_quad,bpm_ind,quad_ind)

px=polyfit(R12(bpm_ind), orqx(:,bpm_ind),1);
py=polyfit(R34(bpm_ind), orqy(:,bpm_ind),1);
for i=1:length(bpm_ind)
    Sc(i)=1/(sigma_orqx(1,bpm_ind(i))^2);
    Sxc(i)=R12(bpm_ind(i))/(sigma_orqx(1,bpm_ind(i))^2);
    Syc(i)=orqx(bpm_ind(i))/(sigma_orqx(1,bpm_ind(i))^2);
    Sxxc(i)=R12(bpm_ind(i))^2/(sigma_orqx(1,bpm_ind(i))^2);
    Sxyc(i)=R12(bpm_ind(i))*orqx(1,bpm_ind(i))/(sigma_orqx(1,bpm_ind(i))^2);
end
S=sum(Sc);
Sx=sum(Sxc);
Sy=sum(Syc);
Sxx=sum(Sxxc);
Sxy=sum(Sxyc);
deno=S*Sxx-Sx*Sx;
sigma_a2x=Sxx/deno;
sigma_b2x=S/deno;
%the same in y
for i=1:length(bpm_ind)
    Sc(i)=1/(sigma_orqy(1,bpm_ind(i))^2);
    Sxc(i)=R34(bpm_ind(i))/(sigma_orqy(1,bpm_ind(i))^2);
    Syc(i)=orqy(bpm_ind(i))/(sigma_orqy(1,bpm_ind(i))^2);
    Sxxc(i)=R34(bpm_ind(i))^2/(sigma_orqy(1,bpm_ind(i))^2);
    Sxyc(i)=R34(bpm_ind(i))*orqy(1,bpm_ind(i))/(sigma_orqy(1,bpm_ind(i))^2);
end
Sy=sum(Syc);
Sxy=sum(Sxyc);
sigma_a2y=Sxx/deno;
sigma_b2y=S/deno;

%(orbit/gl)/R12 in SI units
temp_mis_x=10*px(:,1)';
temp_mis_y=10*py(:,1)';
temp_sigma_mis_x=10*sigma_b2x;
temp_sigma_mis_y=10*sigma_b2y;

mis_x=temp_mis_x*3.3356*en_quad(quad_ind)/1000
mis_y=temp_mis_y*3.3356*en_quad(quad_ind)/1000
sigma_mis_x=temp_sigma_mis_x*3.3356*en_quad(quad_ind)/1000;
sigma_mis_y=temp_sigma_mis_y*3.3356*en_quad(quad_ind)/1000;


% --- Executes during object creation, after setting all properties.
function status_text_CreateFcn(hObject, eventdata, handles)
handles.info_text = hObject;
guidata(hObject,handles)
% hObject    handle to status_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function bpmx_axes_CreateFcn(hObject, eventdata, handles)
handles.bpmx_axes=hObject;
guidata(hObject,handles)
% hObject    handle to bpmx_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate bpmx_axes


% --- Executes during object creation, after setting all properties.
function bpmy_axes_CreateFcn(hObject, eventdata, handles)
handles.bpmy_axes=hObject;
guidata(hObject,handles)
% hObject    handle to bpmy_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate bpmy_axes


% --- Executes on selection change in plot_bpm.
function plot_bpm_Callback(hObject, eventdata, handles)
global plot_bpm_ind
plot_bpm_ind = get(hObject,'Value');
plot_bpm(hObject,eventdata,handles)
% hObject    handle to plot_bpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_bpm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_bpm


% --- Executes during object creation, after setting all properties.
function plot_bpm_CreateFcn(hObject, eventdata, handles)
global all_bpm
set(hObject,'String',all_bpm)
handles.bpm_plot_selection=hObject;
guidata(hObject,handles)
% hObject    handle to plot_bpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_bpm(hObject,eventdata,handles)


global plot_quad_ind hbpmx hbpmy plot_bpm_ind
global ORBITX ORBITY SIGMAX SIGMAY FIELDS

orbitx=ORBITX{plot_quad_ind};
orbity=ORBITY{plot_quad_ind};
sigmax=SIGMAX{plot_quad_ind};
sigmay=SIGMAY{plot_quad_ind};
fields=FIELDS{plot_quad_ind};


axes(handles.bpmx_axes)
hbpmx=errorbar(fields,1000*orbitx(:,plot_bpm_ind),1000*sigmax(:,plot_bpm_ind),'.b');
hold on
grid on
xlabel('quad fields [KG]')
ylabel('orbit [mm]')
p = polyfit(fields', 1000*orbitx(:,plot_bpm_ind),1);
hbpmx(2) = plot(fields',polyval(p,fields'),'-k');
text(1,1,sprintf('slope=%g',p(1)),'Units','Normalized','HorizontalAlignment','Right','VerticalAlignment','Top')
title('horizontal orbit vs quad field')
hold off

axes(handles.bpmy_axes)
hbpmy=errorbar(fields,1000*orbity(:,plot_bpm_ind),1000*sigmay(:,plot_bpm_ind),'.b');
hold on
grid on
xlabel('quad fields [KG]')
ylabel('orbit [mm]')
p = polyfit(fields', 1000*orbity(:,plot_bpm_ind),1);
hbpmx(2) = plot(fields',polyval(p,fields'),'-k');
text(1,1,sprintf('slope=%g',p(1)),'Units','Normalized','HorizontalAlignment','Right','VerticalAlignment','Top')
title('vertical orbit vs quad field')
hold off


% hObject    handle to show_difference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function     [offset_x,sigma_offsetx,offset_y,sigma_offsety,pos_offset] = get_offset(mis_x,sigma_mis_x,mis_y,sigma_mis_y,quad_ind)

global bpm_pos quad_pos orbitx sigmax orbity sigmay


temp=find(bpm_pos==quad_pos(quad_ind));
if ~isempty(temp)
    offset_x=mis_x-orbitx(1,temp)
    offset_y=mis_y-orbity(1,temp)
    sigma_offsetx = sqrt(sigma_mis_x^2+sigmax(1,temp)^2);
    sigma_offsety = sqrt(sigma_mis_y^2+sigmay(1,temp)^2);
    pos_offset=bpm_pos(temp);
else
    offset_x=NaN;
    offset_y=NaN;
    sigma_offsetx = NaN;
    sigma_offsety = NaN;
    pos_offset=NaN;
end


% --- Executes during object creation, after setting all properties.
function global_panel_CreateFcn(hObject, eventdata, handles)
handles.global_info=hObject;
guidata(hObject,handles)
% hObject    handle to global_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function quad_panel_CreateFcn(hObject, eventdata, handles)
handles.quad_info=hObject;
guidata(hObject,handles)
% hObject    handle to quad_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function bpm_panel_CreateFcn(hObject, eventdata, handles)
handles.bpm_info=hObject;
guidata(hObject,handles)
% hObject    handle to bpm_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function save_CreateFcn(hObject, eventdata, handles)
handles.save_data=hObject;
guidata(hObject,handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
clear global
close
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function print_misalign_CreateFcn(hObject, eventdata, handles)
handles.print_global=hObject;
guidata(hObject,handles)
% hObject    handle to print_misalign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function print_quad_CreateFcn(hObject, eventdata, handles)
handles.print_quad=hObject;
guidata(hObject,handles)
% hObject    handle to print_quad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when user attempts to close quad_alignment.
function quad_alignment_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to quad_alignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

if strcmp('/usr/local/lcls/tools/matlab/toolbox/quad_align.m', which('quad_align'))
    lcaClear(); % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end
