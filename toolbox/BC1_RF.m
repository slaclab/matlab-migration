function varargout = BC1_RF(varargin)
% BC1_RF MATLAB code for BC1_RF.fig
%      BC1_RF, by itself, creates a new BC1_RF or raises the existing
%      singleton*.
%
%      H = BC1_RF returns the handle to a new BC1_RF or the handle to
%      the existing singleton*.
%
%      BC1_RF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BC1_RF.M with the given input arguments.
%
%      BC1_RF('Property','Value',...) creates a new BC1_RF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BC1_RF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BC1_RF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BC1_RF

% Last Modified by GUIDE v2.5 29-Jul-2015 07:08:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BC1_RF_OpeningFcn, ...
                   'gui_OutputFcn',  @BC1_RF_OutputFcn, ...
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


% --- Executes just before BC1_RF is made visible.
function BC1_RF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BC1_RF (see VARARGIN)

% Choose default command line output for BC1_RF
handles.output = hObject;

f = 2856E6;
c = 2.99792458E8;
lam = c/f;
k = 2*pi/lam;
n = 4;
handles.M0 = [ 1       0       1       0
               0      -k       0      -n*k
              -k^2     0     -(n*k)^2  0
               0       k^3     0      (n*k)^3];
handles.invM0 = inv(handles.M0);

sz0 = 0.5E-3;   % approx. rms bunch length for plot scale (m)
handles.z = sz0*sqrt(12)*(-0.5:0.05:0.5);

handles.PVs = {'ACCL:LI21:1:L1S_ADES'
               'ACCL:LI21:1:L1S_PDES'
               'ACCL:LI21:180:L1X_ADES'
               'ACCL:LI21:180:L1X_PDES'};

handles = READ_Callback(hObject, eventdata, handles);

set(handles.ES0,'Min',handles.P0(1)-abs(handles.P0(1))/2.0);
set(handles.ES0,'Max',handles.P0(1)+abs(handles.P0(1))/2.0);
set(handles.ES1,'Min',handles.P0(2)-abs(handles.P0(2))/2.0);
set(handles.ES1,'Max',handles.P0(2)+abs(handles.P0(2))/2.0);
set(handles.ES2,'Min',handles.P0(3)-abs(handles.P0(3))/1.3);
set(handles.ES2,'Max',handles.P0(3)+abs(handles.P0(3))/1.3);
set(handles.ES3,'Min',handles.P0(4)-abs(handles.P0(4))/0.5);
set(handles.ES3,'Max',handles.P0(4)+abs(handles.P0(4))/0.5);

set(handles.RS1,'Min',handles.V0(1)-abs(handles.V0(1))/2.0);
set(handles.RS1,'Max',handles.V0(1)+abs(handles.V0(1))/2.0);
set(handles.RS2,'Min',handles.V0(2)-abs(handles.V0(2))/1.0);
set(handles.RS2,'Max',handles.V0(2)+abs(handles.V0(2))/1.0);
set(handles.RS3,'Min',handles.V0(3)-abs(handles.V0(3))/2.0);
set(handles.RS3,'Max',handles.V0(3)+abs(handles.V0(3))/2.0);
set(handles.RS4,'Min',handles.V0(4)-abs(handles.V0(4))/2.0);
set(handles.RS4,'Max',handles.V0(4)+abs(handles.V0(4))/2.0);
guidata(hObject, handles);
% UIWAIT makes BC1_RF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BC1_RF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function ES0_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.P = handles.P0;
handles.P(1) = get(hObject,'Value');
handles.R = handles.invM0*handles.P;
handles.V(1) = sqrt(handles.R(1)^2 + handles.R(2)^2);
handles.V(2) = atan2(handles.R(2),handles.R(1))*180/pi;
handles.V(3) = sqrt(handles.R(3)^2 + handles.R(4)^2);
handles.V(4) = atan2(handles.R(4),handles.R(3))*180/pi;

set(handles.E0val,'String',num2str(handles.P(1)))
set(handles.R1val,'String',num2str(handles.V(1),'%6.2f'));
set(handles.R2val,'String',num2str(handles.V(2),'%6.2f'));
set(handles.R3val,'String',num2str(handles.V(3),'%7.2f'));
set(handles.R4val,'String',num2str(handles.V(4),'%5.2f'));
set(handles.RS1,'Value',handles.V(1));
set(handles.RS2,'Value',handles.V(2));
set(handles.RS3,'Value',handles.V(3));
set(handles.RS4,'Value',handles.V(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ES0_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function ES1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.P = handles.P0;
handles.P(2) = get(hObject,'Value');
handles.R = handles.invM0*handles.P;
handles.V(1) = sqrt(handles.R(1)^2 + handles.R(2)^2);
handles.V(2) = atan2(handles.R(2),handles.R(1))*180/pi;
handles.V(3) = sqrt(handles.R(3)^2 + handles.R(4)^2);
handles.V(4) = atan2(handles.R(4),handles.R(3))*180/pi;

set(handles.E1val,'String',num2str(handles.P(2)))
set(handles.R1val,'String',num2str(handles.V(1),'%6.2f'));
set(handles.R2val,'String',num2str(handles.V(2),'%6.2f'));
set(handles.R3val,'String',num2str(handles.V(3),'%7.2f'));
set(handles.R4val,'String',num2str(handles.V(4),'%5.2f'));
set(handles.RS1,'Value',handles.V(1));
set(handles.RS2,'Value',handles.V(2));
set(handles.RS3,'Value',handles.V(3));
set(handles.RS4,'Value',handles.V(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ES1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function ES2_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.P = handles.P0;
handles.P(3) = get(hObject,'Value');
handles.R = handles.invM0*handles.P;
handles.V(1) = sqrt(handles.R(1)^2 + handles.R(2)^2);
handles.V(2) = atan2(handles.R(2),handles.R(1))*180/pi;
handles.V(3) = sqrt(handles.R(3)^2 + handles.R(4)^2);
handles.V(4) = atan2(handles.R(4),handles.R(3))*180/pi;

set(handles.E2val,'String',num2str(handles.P(3)))
set(handles.R1val,'String',num2str(handles.V(1),'%6.2f'));
set(handles.R2val,'String',num2str(handles.V(2),'%6.2f'));
set(handles.R3val,'String',num2str(handles.V(3),'%7.2f'));
set(handles.R4val,'String',num2str(handles.V(4),'%5.2f'));
set(handles.RS1,'Value',handles.V(1));
set(handles.RS2,'Value',handles.V(2));
set(handles.RS3,'Value',handles.V(3));
set(handles.RS4,'Value',handles.V(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ES2_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function ES3_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.P = handles.P0;
handles.P(4) = get(hObject,'Value');
handles.R = handles.invM0*handles.P;
handles.V(1) = sqrt(handles.R(1)^2 + handles.R(2)^2);
handles.V(2) = atan2(handles.R(2),handles.R(1))*180/pi;
handles.V(3) = sqrt(handles.R(3)^2 + handles.R(4)^2);
handles.V(4) = atan2(handles.R(4),handles.R(3))*180/pi;

set(handles.E3val,'String',num2str(handles.P(4)))
set(handles.R1val,'String',num2str(handles.V(1),'%6.2f'));
set(handles.R2val,'String',num2str(handles.V(2),'%6.2f'));
set(handles.R3val,'String',num2str(handles.V(3),'%7.2f'));
set(handles.R4val,'String',num2str(handles.V(4),'%5.2f'));
set(handles.RS1,'Value',handles.V(1));
set(handles.RS2,'Value',handles.V(2));
set(handles.RS3,'Value',handles.V(3));
set(handles.RS4,'Value',handles.V(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ES3_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function RS1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.V = handles.V0;
handles.V(1) = get(hObject,'Value');
handles.R = [handles.V(1)*cosd(handles.V(2))
             handles.V(1)*sind(handles.V(2))
             handles.V(3)*cosd(handles.V(4))
             handles.V(3)*sind(handles.V(4))];
handles.P = handles.M0*handles.R;
set(handles.R1val,'String',num2str(handles.V(1)))
set(handles.E0val,'String',num2str(handles.P(1)))
set(handles.E1val,'String',num2str(handles.P(2)))
set(handles.E2val,'String',num2str(handles.P(3)))
set(handles.E3val,'String',num2str(handles.P(4)))
set(handles.ES0,'Value',handles.P(1));
set(handles.ES1,'Value',handles.P(2));
set(handles.ES2,'Value',handles.P(3));
set(handles.ES3,'Value',handles.P(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RS1_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function RS2_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.V = handles.V0;
handles.V(2) = get(hObject,'Value');
handles.R = [handles.V(1)*cosd(handles.V(2))
             handles.V(1)*sind(handles.V(2))
             handles.V(3)*cosd(handles.V(4))
             handles.V(3)*sind(handles.V(4))];
handles.P = handles.M0*handles.R;
set(handles.R2val,'String',num2str(handles.V(2)))
set(handles.E0val,'String',num2str(handles.P(1)))
set(handles.E1val,'String',num2str(handles.P(2)))
set(handles.E2val,'String',num2str(handles.P(3)))
set(handles.E3val,'String',num2str(handles.P(4)))
set(handles.ES0,'Value',handles.P(1));
set(handles.ES1,'Value',handles.P(2));
set(handles.ES2,'Value',handles.P(3));
set(handles.ES3,'Value',handles.P(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RS2_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function RS3_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.V = handles.V0;
handles.V(3) = get(hObject,'Value');
handles.R = [handles.V(1)*cosd(handles.V(2))
             handles.V(1)*sind(handles.V(2))
             handles.V(3)*cosd(handles.V(4))
             handles.V(3)*sind(handles.V(4))];
handles.P = handles.M0*handles.R;
set(handles.R3val,'String',num2str(handles.V(3)))
set(handles.E0val,'String',num2str(handles.P(1)))
set(handles.E1val,'String',num2str(handles.P(2)))
set(handles.E2val,'String',num2str(handles.P(3)))
set(handles.E3val,'String',num2str(handles.P(4)))
set(handles.ES0,'Value',handles.P(1));
set(handles.ES1,'Value',handles.P(2));
set(handles.ES2,'Value',handles.P(3));
set(handles.ES3,'Value',handles.P(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RS3_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function RS4_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.V = handles.V0;
handles.V(4) = get(hObject,'Value');
handles.R = [handles.V(1)*cosd(handles.V(2))
             handles.V(1)*sind(handles.V(2))
             handles.V(3)*cosd(handles.V(4))
             handles.V(3)*sind(handles.V(4))];
handles.P = handles.M0*handles.R;
set(handles.R4val,'String',num2str(handles.V(4)))
set(handles.E0val,'String',num2str(handles.P(1)))
set(handles.E1val,'String',num2str(handles.P(2)))
set(handles.E2val,'String',num2str(handles.P(3)))
set(handles.E3val,'String',num2str(handles.P(4)))
set(handles.ES0,'Value',handles.P(1));
set(handles.ES1,'Value',handles.P(2));
set(handles.ES2,'Value',handles.P(3));
set(handles.ES3,'Value',handles.P(4));
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function RS4_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in READ.
function handles = READ_Callback(hObject, eventdata, handles)
handles.V0 = lcaGetSmart(handles.PVs);
%handles.V0 = [148.80 -25.9 20.0 -160.0];
handles.V  = handles.V0;
handles.R0 = [handles.V0(1)*cosd(handles.V0(2))
              handles.V0(1)*sind(handles.V0(2))
              handles.V0(3)*cosd(handles.V0(4))
              handles.V0(3)*sind(handles.V0(4))];
set(handles.R1val,'String',num2str(handles.V0(1),'%6.2f'));
set(handles.R2val,'String',num2str(handles.V0(2),'%6.2f'));
set(handles.R3val,'String',num2str(handles.V0(3),'%7.2f'));
set(handles.R4val,'String',num2str(handles.V0(4),'%5.2f'));
set(handles.RS1,'Value',handles.V0(1));
set(handles.RS2,'Value',handles.V0(2));
set(handles.RS3,'Value',handles.V0(3));
set(handles.RS4,'Value',handles.V0(4));
handles.P0 = handles.M0*handles.R0;
set(handles.E0val,'String',handles.P0(1));
set(handles.E1val,'String',handles.P0(2));
set(handles.E2val,'String',handles.P0(3));
set(handles.E3val,'String',handles.P0(4));
set(handles.ES0,'Value',handles.P0(1));
set(handles.ES1,'Value',handles.P0(2));
set(handles.ES2,'Value',handles.P0(3));
set(handles.ES3,'Value',handles.P0(4));
handles.P = handles.P0;
Plot_Beam(hObject, eventdata, handles)
guidata(hObject, handles);


% --- Executes on button press in SET.
function SET_Callback(hObject, eventdata, handles)
V = handles.V'
yn = questdlg('This will change actual RF settings.  Do you want to continue?','CAUTION');
if strcmp(yn,'Yes')
  disp('RF has been changed!')
  lcaPutSmart(handles.PVs,handles.V);
else
  disp('No changes made.')    
end
guidata(hObject, handles);


function Plot_Beam(hObject, eventdata, handles)
dE0 = handles.P0(1)+135 + handles.P0(2)*handles.z + handles.P0(3)*handles.z.^2 + handles.P0(4)*handles.z.^3;
dE  = handles.P(1)+135 + handles.P(2)*handles.z + handles.P(3)*handles.z.^2 + handles.P(4)*handles.z.^3;
plot(1E3*handles.z,dE0,'r-',1E3*handles.z,dE,'b-')
xlabel('{\itz} (mm)')
ylabel('{\itE} (MeV)')
enhance_plot
%guidata(hObject, handles);
