function varargout = zernike_gui(varargin)
% ZERNIKE_GUI MATLAB code for zernike_gui.fig
%      ZERNIKE_GUI, by itself, creates a new ZERNIKE_GUI or raises the existing
%      singleton*.
%
%      H = ZERNIKE_GUI returns the handle to a new ZERNIKE_GUI or the handle to
%      the existing singleton*.
%
%      ZERNIKE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ZERNIKE_GUI.M with the given input arguments.
%
%      ZERNIKE_GUI('Property','Value',...) creates a new ZERNIKE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before zernike_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to zernike_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help zernike_gui

% Last Modified by GUIDE v2.5 16-Jul-2014 13:56:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @zernike_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @zernike_gui_OutputFcn, ...
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


% --- Executes just before zernike_gui is made visible.
function zernike_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;


timerRunning= false;
timerRestart= false;
timerDelay= 1;      % sec
timerData.hObject= hObject;

handles=appInit(hObject,handles);

% Choose default command line output for zernike_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes zernike_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = zernike_gui_OutputFcn(hObject, eventdata, handles) 
global timerData;
global timerRunning;
% Get default command line output from handles structure
varargout{1} = handles.output;

handles=RefreshGUI(handles);
if timerRunning
timerData.handles = handles;
end



function handles=appInit(hObject,handles)
global timerData;

%integer
handles.axes.tag.arrray={...
    'axes1';...
    'axes2';...
    'axes3';...
    };

handles.readback.readPV.array={...
    'CAMR:IN20:186:ZERNIKE_COEFF';...
    'CAMR:IN20:186:ZERNIKE_COEFF_GOLD';...
    'CAMR:IN20:186:ZERNIKE_COEFF_IDEAL';...
    };

%'CATH:IN20:111:QE';
%'GDET:FEE1:241:ENRC1H';
%'GDET:FEE1:241:ENRCBR';
%'GDET:FEE1:241:ENRCHSTBR';


handles.graphPV='CAMR:IN20:186:ZERNIKE_COEFF';

handles = initGUI(handles);

if ~ispc
    lcaSetMonitor(handles.readback.readPV.array);

end


function handles=initGUI(handles)
val=lcaGetSmart(handles.readback.readPV.array(:));
for loopcnt=1:length(val)
    p=val(1,2:end);
    plot(handles.axes1, p);
    set(handles.axes1,'XLim', [2 45],'XMinorGrid','off','XMinorTick','off')
end

function updateGUIvals(hObject,handles)
set (handles.datestr_txt,'String',datestr(now));
No_btn_Callback(hObject, handles);



function handles=RefreshGUI(handles)
global timerObj;
global timerDelay;
global timerRestart;
global timerRunning;
global timerData;
if (timerRunning)
    stop (timerObj);
end


timerObj=timer('TimerFcn', {@timer_Callback, handles}, 'Period', timerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop');
timerRestart = true;
timerData.handles = handles;
start (timerObj);
timerRunning = true;


function timer_Callback (obj, event, handles)
global timerData;
global timerRunning;
handles = guidata (handles.figure1);
updateGUIvals(handles.figure1,handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ideal_btn.
function ideal_btn_Callback(hObject, eventdata, handles)
val=lcaGetSmart('CAMR:IN20:186:ZERNIKE_COEFF');
lcaPutSmart('CAMR:IN20:186:ZERNIKE_COEFF_IDEAL',val);
p=val(1,2:end);
plot(handles.axes2, p);
set(handles.axes2,'XLim', [2 45],'XMinorGrid','off',...
    'ButtonDownFcn', {@axes2_ButtonDownFcn, handles})


% --- Executes on button press in gold_btn.
function gold_btn_Callback(hObject, eventdata, handles)
val=lcaGetSmart('CAMR:IN20:186:ZERNIKE_COEFF');
lcaPutSmart('CAMR:IN20:186:ZERNIKE_COEFF_GOLD',val);
p=val(1,2:end);
plot(handles.axes3, p);
set(handles.axes3,'XLim', [2 45])


function firstTime_txt_Callback(hObject, eventdata, handles)
% 
%

% --- Executes during object creation, after setting all properties.
function firstTime_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function secondTime_txt_Callback(hObject, eventdata, handles)
% 
%


% --- Executes during object creation, after setting all properties.
function secondTime_txt_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global timerRunning;
global timerObj;
stop (timerObj);
pause (2);
if ~ispc
    util_appClose(hObject);
    pause(2.5);
end
if ispc
    delete (hObject);
end
lcaClear


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
handles.graphPV='CAMR:IN20:186:ZERNIKE_COEFF';
guidata(handles.output, handles);
handles = vccImage(handles);

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
handles.graphPV='CAMR:IN20:186:ZERNIKE_COEFF_IDEAL';
guidata(handles.output, handles);
handles = vccImage(handles);

% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
handles.graphPV='CAMR:IN20:186:ZERNIKE_COEFF_GOLD';
guidata(handles.output, handles);
handles = vccImage(handles);

function handles =  vccImage(handles)
if isempty(handles.graphPV)
    coef=handles.coef;
else
coef=lcaGetSmart(handles.graphPV);
end

img=zeros(140,140);
nCoeff=45;
j=1:nCoeff;
nList=ceil(-.5+sqrt(2*j+1/4)-1);
mList=(j-1)*2-nList.*(nList+2);
c=zeros(1,nCoeff);
imgc=zeros(size(img));
for k=j
    z=zernike2D(nList(k),mList(k),size(img,1));
    c=coef;
    imgc=imgc+c(k)*z;
end
pcolor(handles.axes5, flipud(imgc)); 
shading(handles.axes5,'interp');


% --- Executes on button press in No_btn.
function No_btn_Callback(hObject, handles)
val=lcaGetSmart('CAMR:IN20:186:ZERNIKE_COEFF');
p=val(1,2:end);
plot(handles.axes1, p);
set(handles.axes1,'Visible','On','XLim', [2 45],'XMinorGrid','off',...
    'ButtonDownFcn', {@axes1_ButtonDownFcn, handles})
set(handles.axes2,'XLim', [2 45],'XMinorGrid','off',...
    'ButtonDownFcn', {@axes2_ButtonDownFcn, handles})
set(handles.axes3,'XLim', [2 45],'XMinorGrid','off',...
    'ButtonDownFcn', {@axes3_ButtonDownFcn, handles})
handles = vccImage(handles);


% --- Executes on button press in getHistory_btn.
function getHistory_btn_Callback(hObject, eventdata, handles)
set(handles.msg_txt, 'Visible', 'On')
pause(0.1);

firstTime  = get(handles.firstTime_txt,'String');
secondTime = get(handles.secondTime_txt,'String');
timeRange ={firstTime;secondTime};

pvCoef = 'CAMR:IN20:186:ZERNIKE_COEFF';
pvGdet = 'GDET:FEE1:241:ENRC';
pvQe   = 'CATH:IN20:111:QE';


if isempty(secondTime)
    secondTime=firstTime;
end

[~, ~, tCoef, vCoef]=history(pvCoef,{firstTime;secondTime});
[~, ~, t1, v1]=history({pvGdet,pvQe},{firstTime;firstTime});
[~, ~, t2, v2]=history({pvGdet,pvQe},{secondTime;secondTime});

tCoef=[tCoef(1):tCoef(end)];
vCoef=[vCoef(:,1),vCoef(:,end)];

d_Coef=vCoef(:,1)-vCoef(:,2);
plot(handles.axes4, d_Coef);
set(handles.axes4,'Visible','On','XLim', [2 45],'XMinorGrid','on')

set(handles.energy_readback1_txt, 'String',  sprintf('%3.3f',v1(1)));
set(handles.QE_readback1_txt, 'String', sprintf('%0.4g',v1(2)));
set(handles.energy_readback2_txt, 'String', sprintf('%3.3f',v2(1)));
set(handles.QE_readback2_txt, 'String', sprintf('%0.4g',v2(2)));
set(handles.msg_txt, 'Visible', 'Off')

coef= vCoef(:,1);
pcoef=coef(2:end,1);
plot(handles.axes2, pcoef);
set(handles.axes2,'Visible','On','XLim', [2 45],'XMinorGrid','off')

handles.graphPV = [];
handles.coef=coef;
guidata(hObject, handles)

img=zeros(140,140);
nCoeff=45;
j=1:nCoeff;
nList=ceil(-.5+sqrt(2*j+1/4)-1);
mList=(j-1)*2-nList.*(nList+2);
c=zeros(1,nCoeff);
imgc=zeros(size(img));
for k=j
    z=zernike2D(nList(k),mList(k),size(img,1));
    c=coef;
    imgc=imgc+c(k)*z;
end
pcolor(handles.axes5, flipud(imgc));
shading(handles.axes5,'interp');


function [z, r, th] = zernike2D(n, m, num)

x0=linspace(-1+1/num,1-1/num,num);
[x,y]=meshgrid(x0,x0);
[th,r]=cart2pol(x,y);
[p,l]=zernike(n,m,r);
z=sqrt((2*n+2)/pi/(1+(m == 0)))*l.*(cos(m*th)*(m >= 0)+sin(m*th)*(m < 0)).*(r < 1);

