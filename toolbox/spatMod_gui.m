function varargout = SpatMod(varargin)
% SPATMOD MATLAB code for SpatMod.fig
%      SPATMOD, by itself, creates a new SPATMOD or raises the existing
%      singleton*.
%
%      H = SPATMOD returns the handle to a new SPATMOD or the handle to
%      the existing singleton*.
%
%      SPATMOD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPATMOD.M with the given input arguments.
%
%      SPATMOD('Property','Value',...) creates a new SPATMOD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpatMod_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpatMod_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpatMod

% Last Modified by GUIDE v2.5 04-Jun-2015 13:03:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpatMod_OpeningFcn, ...
                   'gui_OutputFcn',  @SpatMod_OutputFcn, ...
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


% --- Executes just before SpatMod is made visible.
function SpatMod_OpeningFcn(hObject, eventdata, handles, varargin)

handles.bufd=1;

handles.pvs={'SIOC:SYS0:ML02:AO073','SIOC:SYS0:ML02:AO074','SIOC:SYS0:ML02:AO075',...
'SIOC:SYS0:ML02:AO076', 'SIOC:SYS0:ML02:AO077', 'SIOC:SYS0:ML02:AO078'};

% Choose default command line output for SpatMod
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = SpatMod_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on selection change in profSel_listbox.
function profSel_listbox_Callback(hObject, eventdata, handles)
% 

% --- Executes on selection change in shotMode_listbox.
function shotMode_listbox_Callback(hObject, eventdata, handles)
shotMode(handles);


function handles = shotMode(handles)
val = get(handles.shotMode_listbox, 'Value');
switch val
    
    case 1
        handles.shotMode = 1;
        
    case 2
        handles.shotMode = 2;
        
    case 3
        handles.shotMode = 3;
end


% --- Executes on button press in start_btn.
function start_btn_Callback(hObject, eventdata, handles)
startBtnCtrl(hObject, handles, 0);
val = get(handles.start_btn, 'Value');

if val == 0
    set(handles.shotNum_txt, 'String', 'Data Acquisition Stopped')
    return
end

val=get(handles.shotMode_listbox, 'Value');
switch val
    case 1
        j=1;
    case 2
        j=str2double(get(handles.shotNumber_editTxt,'String'));
    case 3
        j= 100;
end

for i = 1:j
    startBtnStatus = get(handles.start_btn, 'Value');
    set(handles.shotNum_txt, 'String', ['Loop Count: ' num2str(i)])
    zerr=str2double(get(handles.rmsError_txt, 'String'));
    if val ==3 && i > 1 && zerr < 10 || startBtnStatus == 0
        set(handles.shotNum_txt, 'String', 'Data Acquisition Stopped')
        return
    end
    
    acquireData(hObject, handles);
    
    if i==j 
        startBtnCtrl(hObject, handles, 1);
    end
    
end

function startBtnCtrl(hObject, handles, reset)
if reset
        set(handles.start_btn, 'Value',0);
        set(handles.start_btn, 'String', 'Start')
        set(handles.start_btn, 'BackGroundColor', 'g')
        set(handles.shotNum_txt, 'String', 'Data Acquisition Completed')
        return
end

val = get(handles.start_btn, 'Value');

switch val 
    case 0 
        set(handles.start_btn, 'String', 'Start')
        set(handles.start_btn, 'BackGroundColor', 'g')
        
        
    case 1
        set(handles.start_btn, 'String', 'Stop')
        set(handles.start_btn, 'BackGroundColor', 'r')
        
end



function acquireData(hObject, handles)
gh=get(handles.ghRatio_checkbox, 'Value');
if gh == 1 
    ghRatio = str2double(get(handles.ghRatio_editTxt));
else 
    ghRatio = 0;
end

eff = str2double(get(handles.efficiency_editTxt));
xOffset = str2double(get(handles.offsetX_editTxt, 'String'));
yOffset = str2double(get(handles.offsetY_editTxt, 'String')); 
shape_choice = get(handles.fit_listbox,'Value');
handles = grab_image(hObject, handles);
spatMod_runshaping(handles.data.img, ghRatio, str2double(get(handles.ghRatio_editTxt, 'String')), eff , xOffset, yOffset, handles, shape_choice)


% --- Executes on selection change in fit_listbox.
function fit_listbox_Callback(hObject, eventdata, handles)
val = get(handles.fit_listbox, 'Value');
switch val
    
    case 1
        str='Cut-Gaussian';
        qstr=questdlg('Opt: Update g/h Ratio');
        if strcmp(qstr, 'Yes')
            set(handles.ghRatio_checkbox, 'Value', 1)
            handles.ghHold=1;
        elseif strcmp(qstr, 'No') || strcmp(qstr, 'Cancel')
            set(handles.ghRatio_checkbox, 'Value', 0)
            handles.ghHold=0;
        end
 
                
    case 2
        str = 'Parabolic';
        set(handles.ghRatio_checkbox, 'Value', 0)
        handles.ghHold=0;
        
    case 3
        str ='Flat-Top';
        set(handles.ghRatio_checkbox, 'Value', 0)
        handles.ghHold=0;
        
    case 4
        str ='Load New';
        set(handles.ghRatio_checkbox, 'Value', 0)
        handles.ghHold=0;
end
guidata(hObject, handles)


% --- Executes on button press in apply_btn.
function apply_btn_Callback(hObject, eventdata, handles)
% 


function handles = grab_image(hObject, handles)
guidata(hObject,handles);
val = get(handles.profSel_listbox, 'Value');
switch val 
    
    case 1
        handles.PV = 'CAMR:IN20:186';
        
    case 2
        handles.PV = 'YAGS:IN20:241';
        
    case 3
        handles.PV = 'CAMR:IN20:469';
     
    case 4
        handles.PV = 'YAGS:IN20:995';
end

if isempty(handles.PV)
    disp('Select Profile') 
    return
else 
   
end

[d,is]=profmon_names(handles.PV);
nImg=[];
if handles.bufd && is.Bufd
    nImg=0;
    lcaPutSmart([handles.PV ':SAVE_IMG'],1);
end
handles.data=profmon_grab(handles.PV,0,nImg);

profmon_imgPlot(handles.data,'axes',handles.prof_axes);
guidata(hObject,handles);


function parameter_Callback(hObject, eventdata , handles, tag)
disp(tag)



function ghRatio_editTxt_Callback(hObject, eventdata, handles)
%


% --- Executes on button press in ghRatio_checkbox.
function ghRatio_checkbox_Callback(hObject, eventdata, handles)
%

function yCenter_editTxt_Callback(hObject, eventdata, handles)
% 

function xCenter_editTxt_Callback(hObject, eventdata, handles)
% 
