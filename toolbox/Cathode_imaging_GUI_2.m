function varargout = Cathode_imaging_GUI_3(varargin)
% CATHODE_IMAGING_GUI_3 M-file for Cathode_imaging_GUI_3.fig
%      CATHODE_IMAGING_GUI_3, by itself, creates a new CATHODE_IMAGING_GUI_3 or raises the existing
%      singleton*.
%
%      H = CATHODE_IMAGING_GUI_3 returns the handle to a new CATHODE_IMAGING_GUI_3 or the handle to
%      the existing singleton*.
%
%      CATHODE_IMAGING_GUI_3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CATHODE_IMAGING_GUI_3.M with the given input arguments.
%
%      CATHODE_IMAGING_GUI_3('Property','Value',...) creates a new CATHODE_IMAGING_GUI_3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cathode_imaging_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cathode_imaging_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cathode_imaging_GUI

% Last Modified by GUIDE v2.5 26-Nov-2008 15:14:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cathode_imaging_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Cathode_imaging_GUI_OutputFcn, ...
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


% --- Executes just before Cathode_imaging_GUI is made visible.
function Cathode_imaging_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cathode_imaging_GUI (see VARARGIN)

% Choose default command line output for Cathode_imaging_GUI
handles.output = hObject;
handles.exportFig = 2; %HL

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Cathode_imaging_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Cathode_imaging_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_take_image.
function pushbutton_take_image_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_take_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

c ='Good morning ... latest change to this GUI was 02/18/09. Relax and enjoy the show.';
     set(handles.message_out_text,'String',c);
     pause(2);


% checking the trigger rate and MPS Shutter

rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');

%MPS_Shutter=lcaGet('MPS:IN20:1:SHUTTERTRIG');
MPS_Shutter=lcaGet('IOC:BSY0:MP01:MS_RATE');
%a=struct;
%a.state = MPS_Shutter{1,:};
%a=a.state(1);
a=MPS_Shutter{1}(1);

%if (rate < 10) || (a == 'D')
if (rate < 10) || (a == '0')
    if rate < 10
     c ='insufficient beam rate, rate less than 10Hz, fix it and restart';
     set(handles.message_out_text,'String',c);
     pause(2);
     end 
%    if a == 'D'
    if a == '0'
     c='MPS Shutter is in, fix it and restart';
     set(handles.message_out_text,'String',c);
     pause(2);
    end
else

  
% Enabling the lamp

lcaPut('PFMC:IN20:GP02:G_LAMP_ENA', 1);
c='enabling lamp';
set(handles.message_out_text,'String',c);  
pause(2);

% turn on trigger
profmon_evrSet('CTHD:IN20:206');

% set lamp control to Cathode lamp
lcaPut('PFMC:IN20:GP02:LAMP_CH', 'Cathode');
c='set lamp control to cathode G-lamp';
set(handles.message_out_text,'String',c);
pause(2);

% set camera frame width to 20000
lcaPut('EVR:IN20:PM03:CTRL.DG0W', 30000);
c='set camera frame width to 30000';
set(handles.message_out_text,'String',c);
pause(2);

% grabbing image from camera

data=profmon_grab('CTHD:IN20:206');
c='aquiring image';
set(handles.message_out_text,'String',c);
pause(2);

figure(1)
ax=axes;
profmon_imgPlot(data,'axes',ax,'cal',1,'bits',12,'colormap','gray')
set(gcf,'colormap',gray(4096))
l = max(data.img(:));


%Turning up lamp
lcaPut('PFMC:IN20:GP02:G_LAMP_DOWN',0); %make sure 'dimmer' button is not pressed
f=0.01;
while l < 3000
  c=['turning lamp up ' num2str(f) ' % done'];
  set(handles.message_out_text,'String',c);
  lcaPut('PFMC:IN20:GP02:G_LAMP_UP',1);
  pause(0.5);
  lcaPut('PFMC:IN20:GP02:G_LAMP_UP',0);
  pause(0.1);
  data=profmon_grab('CTHD:IN20:206');
  profmon_imgPlot(data,'axes',ax,'cal',1,'bits',12,'colormap','gray')
  l = double(max(data.img(:)));
  f = 100*l/3000;
  
end

figure(1)
profmon_imgPlot(data,'axes',ax,'cal',1,'bits',12,'colormap','gray')
set(gcf,'colormap',gray(4096))

figure(2)
data.img=data.img(:,500:800); %ROI y1, y2
data.img=data.img(250:550,:); %ROI x1, x2
image(data.img)
colormap(gray(4096))
axis equal

%turning lamp down

while l > 300
c='turning lamp down, wait until GUI says it is done before closing GUI';
  set(handles.message_out_text,'String',c);
  lcaPut('PFMC:IN20:GP02:G_LAMP_DOWN',1);
  pause(0.5);
  
  data=profmon_grab('CTHD:IN20:206');
  profmon_imgPlot(data,'axes',ax,'cal',1,'bits',12,'colormap','gray')
  l = max(data.img(:));
end

lcaPut('PFMC:IN20:GP02:G_LAMP_DOWN',0);

lamp_on_off=get(handles.lamp_on_checkbox,'Value');

  if lamp_on_off == 0
  c='Done now, turning lamp OFF, please hit the LOGBOOK button.';
  set(handles.message_out_text,'String',c);
  lcaPut('PFMC:IN20:GP02:G_LAMP_ENA', 0);
  else
  c='Done now, leaving lamp ON, please hit the LOGBOOK button.';
  set(handles.message_out_text,'String',c); 
  end
  
end

guidata(hObject, handles);

% --- Executes on button press in pushtoLog.
function pushtoLog_Callback(hObject, eventdata, handles)
% hObject    handle to pushtoLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~any(ishandle(handles.exportFig)), return, end
util_printLog(handles.exportFig);

% --- Executes on button press in lamp_on_checkbox.
function lamp_on_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to lamp_on_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lamp_on_checkbox
lamp_on_off=get(hObject,'Value');
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
util_appClose(hObject);


