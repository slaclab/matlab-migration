function varargout = EOS_online_gui(varargin)
% EOS_online_gui MATLAB code for EOS_online_gui.fig
%      EOS_online_gui, by itself, creates a new EOS_online_gui or raises the existing
%      singleton*.
%
%      H = EOS_online_gui returns the handle to a new EOS_online_gui or the handle to
%      the existing singleton*.
%
%      EOS_online_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EOS_online_gui.M with the given input arguments.
%
%      EOS_online_gui('Property','Value',...) creates a new EOS_online_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EOS_online_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EOS_online_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EOS_online_gui

% Last Modified by GUIDE v2.5 28-Mar-2016 13:29:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EOS_online_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @EOS_online_gui_OutputFcn, ...
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


% --- Executes just before EOS_online_gui is made visible.
function EOS_online_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EOS_online_gui (see VARARGIN)

% Choose default command line output for EOS_online_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EOS_online_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EOS_online_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Plot function
function plot_image(handles,image,print)

im_size = size(image.img(:,image.plotrange));

if print == 0
ax_1 = handles.image_axes;
axes(ax_1);
cla;
hold all;
axis([1 im_size(2) 1 im_size(1)]);
imagesc(image.img(:,image.plotrange));
xlabel('px');
ylabel('px');
title('EOS Image');
hold off;

ax_2 = handles.plot_axes;
axes(ax_2);
cla;
hold all;
plot(image.z_axis(image.plotrange),image.proj(image.plotrange),'b');
plot(image.z_axis(image.plotrange),image.drv_fit,'r');
plot(image.z_axis(image.plotrange),image.wit_fit,'g');
plot([image.drv_pk_z,image.wit_pk_z],[image.drv_pk_val,image.wit_pk_val],'r*');
hold off;
xlabel('z (um)');
ylabel('projected counts');
title('EOS Profile');
xlim([image.z_axis(image.plotrange(1)),image.z_axis(image.plotrange(end))]);
ylim([0,1.1*max(image.proj(image.plotrange))]);

results = text(image.z_axis(image.plotrange(2)),0.95*max(image.proj(image.plotrange)),...
    sprintf('Drv \\sigma_z= %.2f \\mum\nWit \\sigma_z= %.2f \\mum\n\\Delta_z= %.2f \\mum',...
    image.drv_sig,image.wit_sig,image.delta_z),'FontSize',12);
%     set(results,'HorizontalAlignment','Center',...
%     'FontSize',24);
elseif print == 1
    cla;
    hold all;
    subplot(1,2,1);
    axis([1 im_size(2) 1 im_size(1)]);
    imagesc(image.img(:,image.plotrange));
    xlabel('px');
    ylabel('px');
    title('EOS Image');
    hold off;
    
    subplot(1,2,2);
    hold all;
    plot(image.z_axis(image.plotrange),image.proj(image.plotrange),'b');
    plot(image.z_axis(image.plotrange),image.drv_fit,'r');
    plot(image.z_axis(image.plotrange),image.wit_fit,'g');
    plot([image.drv_pk_z,image.wit_pk_z],[image.drv_pk_val,image.wit_pk_val],'r*');
    hold off;
    xlabel('z (um)');
    ylabel('projected counts');
    title('EOS Profile');
    xlim([image.z_axis(image.plotrange(1)),image.z_axis(image.plotrange(end))]);
    ylim([0,1.1*max(image.proj(image.plotrange))]);
    
    results = text(image.z_axis(image.plotrange(2)),0.95*max(image.proj(image.plotrange)),...
        sprintf('Drv \\sigma_z= %.2f \\mum\nWit \\sigma_z= %.2f \\mum\n\\Delta_z= %.2f \\mum',...
        image.drv_sig,image.wit_sig,image.delta_z),'FontSize',12);
end

% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML00:AO891',1);
if get(handles.use_bg,'Value') == get(handles.use_bg,'Max')
    handles.bg_check = 1;
else
    handles.bg_check = 0;
end

while lcaGetSmart('SIOC:SYS1:ML00:AO891')==1
    data = profmon_grab('PROF:LI20:B100');
    image = eos_gui_anal(data,handles);
    plot_image(handles,image,0);
    pause(1);
end


% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML00:AO891',0);


% --- Executes on button press in print.
function print_Callback(hObject, eventdata, handles)
% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if lcaGetSmart('SIOC:SYS1:ML00:AO891') == 1
    Stop_Callback(hObject, eventdata, handles);
    data = profmon_grab('PROF:LI20:B100');
    image = eos_gui_anal(data,handles);
    img_fig = figure(1);
    set(img_fig,'Position',[250 250 1000 500]);
    plot_image(handles,image,1);
    util_printLog(img_fig,'title','EOS Online Analysis GUI');
    Start_Callback(hObject, eventdata, handles);
else
    data = profmon_grab('PROF:LI20:B100');
    image = eos_gui_anal(data,handles);
    img_fig = figure(1);
    set(img_fig,'Position',[250 250 1000 500]);
    plot_image(handles,image,1);
    util_printLog(img_fig,'title','EOS Online Analysis GUI');
end

% --- Executes on button press in get_bg.
function get_bg_Callback(hObject, eventdata, handles)
% hObject    handle to get_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_2_9(1,6);
while get_2_9(6) == 0
    pause(1);
end
pause(5);
if lcaGetSmart('SIOC:SYS1:ML00:AO891') == 1
    Stop_Callback(hObject, eventdata, handles);
    bg = profmon_grab('PROF:LI20:B100');
    handles.bg = bg.img;
    guidata(hObject,handles);
    set_2_9(0,6);
    while get_2_9(6) == 1
        pause(1);
    end
    Start_Callback(hObject, eventdata, handles);
else
    bg = profmon_grab('PROF:LI20:B100');
    handles.bg = bg.img;
    guidata(hObject,handles);
    set_2_9(0,6);
    while get_2_9(6) == 1
        pause(1);
    end   
end

% --- Executes on button press in use_bg.
function use_bg_Callback(hObject, eventdata, handles)
% hObject    handle to use_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_bg
if lcaGetSmart('SIOC:SYS1:ML00:AO891') == 1
    Stop_Callback(hObject, eventdata, handles);
    if get(handles.use_bg,'Value') == get(handles.use_bg,'Max')
        handles.bg_check = 1;
    else
        handles.bg_check = 0;
    end
    guidata(hObject,handles);
    Start_Callback(hObject, eventdata, handles);
else
    if get(handles.use_bg,'Value') == get(handles.use_bg,'Max')
        handles.bg_check = 1;
    else
        handles.bg_check = 0;
    end
    guidata(hObject,handles);
    data = profmon_grab('PROF:LI20:B100');
    image = eos_gui_anal(data,handles);
    plot_image(handles,image,0);
end