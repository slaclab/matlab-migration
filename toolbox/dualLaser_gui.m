function varargout = dualLaser_gui(varargin)
% DUALLASER_GUI MATLAB code for dualLaser_gui.fig
%      DUALLASER_GUI, by itself, creates a new DUALLASER_GUI or raises the existing
%      singleton*.
%
%      H = DUALLASER_GUI returns the handle to a new DUALLASER_GUI or the handle to
%      the existing singleton*.
%
%      DUALLASER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DUALLASER_GUI.M with the given input arguments.
%
%      DUALLASER_GUI('Property','Value',...) creates a new DUALLASER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dualLaser_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dualLaser_gui_OpeningFcn via varargin.
%epi
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dualLaser_gui

% Last Modified by GUIDE v2.5 02-Sep-2016 14:57:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dualLaser_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dualLaser_gui_OutputFcn, ...
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


%functions used:

% --- Executes just before dualLaser_gui is made visible.
function dualLaser_gui_OpeningFcn(hObject, eventdata, handles, varargin)
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

% --- Outputs from this function are returned to the command line.
function varargout = dualLaser_gui_OutputFcn(hObject, eventdata, handles) 
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

handles.BG=[];
handles.laserStatusPV='SIOC:SYS0:ML02:AO279';
handles.shutStatePV =  {'SHTR:LR20:100:UV_STS',... % coh 1 shutter
    'SHTR:LR20:90:UV_STS',...% coh2 shutter
    'MOTR:LR20:20:FLIPPER'};% LCLS-II flipper

handles.initiate =[];

handles.orig_str={...
    'text55';... 
    'text88';...
    'text56';...
    'text59';...
    'text60';...
    'text90';...
    'text61';...
    'text68';...
    'text71';...
    'text95';...
    'text97';...
    };

handles.orig_num={...
    'text64';...
    };

handles.current_str={...
    'text79';...
    'text89';...
    'text80';...
    'text81';...
    'text82';...
    'text92';...
    'text83';...
    'text86';...
    'text87';...
    'text96';...
    'text98';...
    };

handles.current_num={...
    'text84';...
    };

handles.statPV_str={...
    'SHTR:LR20:100:UV_STS';... % coh 1 shutter
    'SHTR:LR20:90:UV_STS';...% coh2 shutter
    'MOTR:LR20:20:FLIPPER';...% LCLS-II flipper
    'LASR:IN20:160:POS_FDBK';...% VCC feedback
    'OSC:LR20:10:FS_ENABLE_BUCKET_FIX';... % Bucket jump detect, backup laser
    'OSC:LR20:20:FS_ENABLE_BUCKET_FIX';... % Bucket jump detect, backup laser
    'EVR:LR20:LS02:EVENT9CTRL.OUT0';...% Add trigger to Pockels cell, Ch0
    'EVR:LR20:LS02:EVENT2CTRL.OUT';... % Take away backup laser event code 40
    'EVR:LR20:LS02:EVENT9CTRL.OUT' ;...% Add backup laser event code 50
    'SHTR:LR20:90:UV_SHUTTER';...% backup laser shutter
    'SHTR:LR20:100:UV_SHUTTER';...% backup laser shutter
    };

handles.statPV_num={...
    'EVR:LR20:LS02:EVENT9CTRL.ENM';... % Create LS02 TS2,5 trigger (50)
    };

handles.plot=[];

handles = initGUI(handles);
if ~ispc
    lcaSetMonitor(handles.laserStatusPV);
end


function handles=initGUI(handles)
str=lcaGetSmart(handles.laserStatusPV);
set(handles.status_txt, 'String', str)


function updateGUIvals(hObject,handles)
str=lcaGetSmart(handles.laserStatusPV);
set(handles.status_txt, 'String', str)
laserStatus(handles, 'current')




function laserStatus(handles, tag)
str=strcat(tag, '_str');
num=strcat(tag, '_num');

val=lcaGetSmart(handles.statPV_num);
for i =1:length(val)
    set(handles.(handles.(num){i}),'String',val(i));   
end

val=lcaGetSmart(handles.statPV_str);
for i =1:length(val)
    set(handles.(handles.(str){i}),'String',val(i));   
end      



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





% --- Executes on button press in loadGauss_btn.
function loadGauss_btn_Callback(hObject, eventdata, handles)
[radialDist, ratios_gh, thetaDist, balance ]= dualLaser_radialDist(handles.data.img,10, handles.plot);

% [ratios, bal, x, y, z, w, mw]= profmon_gaussRatio(handles.data, 'doPlot', 1); 
len=length(handles.vccImg);

 [handles.gaussBeam, handles.sigma]=dualLaser_createGaussBeam(handles, 'dIdeal',2, ...
    'dIris',2, 'mode', '','nPix', len);

set(handles.xRatio_txt, 'String', num2str(ratios_gh));
set(handles.bal_txt, 'String', num2str(balance/100))
handles.gaussBeamData=handles.data;

[beam_lenX,beam_lenY]=size(handles.data.img);
[gaus_lenX, gaus_lenY]=size(handles.gaussBeam);
padZerosX=beam_lenX-gaus_lenX;
padZerosY=beam_lenY-gaus_lenY;
handles.gaussBeamData.centerY=round(beam_lenY/2);
handles.gaussBeamData.centerX=round(beam_lenX/2);
handles.gaussBeamData.roiYN=beam_lenY;
handles.gaussBeamData.roiYN=beam_lenX;
handles.gaussBeam=padarray(handles.gaussBeam, [round(padZerosX/2) round(padZerosY/2) ]);
handles.gaussBeamData.img=handles.gaussBeam;
% [ratiosG, balG, xG, yG, zG, wG, mwG]= profmon_gaussRatioNoCut(handles.gaussBeamData, 'doPlot', 1); 
[radialDist2, ratio2, thetaDist2]= dualLaser_radialDist(handles.gaussBeam,1, handles.plot);
handles.gaussBeam=util_cropImage(handles.gaussBeam);
guidata(hObject, handles)
err=util_immse(handles.vccImg, handles.gaussBeam);
set(handles.err_txt, 'String', num2str(err));
handles.diff= handles.vccImg-handles.gaussBeam;
%handles.diff= handles.gaussBeam-handles.vccImg;
%shift=min(handles.diff(:));
%g=handles.diff-shift;
%imagesc(handles.diff, 'Parent', handles.axes4); colorbar('peer',handles.axes4); shading interp; 
imagesc(handles.diff, 'Parent', handles.axes4); colorbar('peer',handles.axes4); shading interp;
caxis(handles.axes4, [-100 100])
title(handles.axes4,'VCC - Ideal ')
guidata(hObject, handles)

% --- Executes on button press in loadvcc_btn.
function loadvcc_btn_Callback(hObject, eventdata, handles)
if get(handles.offline_box,'Value')
    load /home/physics/dbohler/lasCam/ZernikeAnalysis/ProfMon-CAMR_IN20_186-2015-01-09-033440.mat
else
    data=profmon_measure('VCC',1,'nBG',0,'doPlot',0,'saves',1);
end
handles.data=data;
handles = processVCC(handles, data);
handles.vccImg=util_cropImage(data.img);
imagesc(handles.vccImg, 'Parent', handles.axes1); shading interp;  colorbar('peer',handles.axes1);
colorbar('peer', handles.axes1)
title(handles.axes1,['Profile Monitor' 'CAMR:IN20:186' datestr(now)])
%caxis(handles.axes1, [-100 200]);
%colormap(handles.axes4, 'default')
[handles, beam] = processVCC(handles, data);
handles.beam=beam;
guidata(hObject, handles)


function [handles, beam] = processVCC(handles, data)
beam=profmon_process(data,'doPlot',0);
stats=beam(1).stats.*[1 1 1 1 1/prod(beam(1).stats(3:4)) 1]; % Data in [um um um um 1 cts]
handles.x=stats(1); handles.y=stats(2);
handles.xrms=stats(3); handles.yrms=stats(4);
set(handles.y_txt, 'String', [num2str(handles.y, '%5.2f') ' um'])
set(handles.x_txt, 'String', [num2str(handles.x, '%5.2f') ' um'])
set(handles.yrms_txt, 'String', [num2str(handles.yrms, '%5.2f') ' um'])
set(handles.xrms_txt, 'String', [num2str(handles.xrms, '%5.2f') ' um'])

% --- Executes on button press in offline_box.
function offline_box_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in log_btn.
function log_btn_Callback(hObject, eventdata, handles)
if ~isfield(handles,'data'), return, end
strlogbook = handles.data.name;
%util_printLog(handles.figure1,'Dual Laser GUI');
util_printLog(handles.figure1,'logType','elog_mcc');
dataSave(handles.output, handles,'DualLaser');


function handles = dataSave(hObject, handles, title)
if ~isfield(handles,'data'), return, end
name=handles.data.name;
data=handles.data;
if isfield(handles,'diff')
    data.diff=handles.diff;
end
if isfield(handles, 'primary')
    data.primary=handles.primary;
end
if isfield(handles, 'secondary')
  data.secondary=handles.secondary;  
end
fileName=util_dataSave(data,title,name,data.ts);
if ~ischar(fileName), return, end
handles.fileName=fileName;
guidata(hObject,handles);







% --- Executes on selection change in camSource_menu.
function camSource_menu_Callback(hObject, eventdata, handles)
% 


% --- Executes during object creation, after setting all properties.
function camSource_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lasSource_menu.
function lasSource_menu_Callback(hObject, eventdata, handles)
val=get(handles.lasSource_menu, 'Value');
if val==1 
    set(handles.backup_menu, 'Value',2)
else
    set(handles.backup_menu, 'Value', 1)
end

% --- Executes during object creation, after setting all properties.
function lasSource_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in backup_menu.
function backup_menu_Callback(hObject, eventdata, handles)
val=get(handles.backup_menu, 'Value');
if val==1 
    set(handles.lasSource_menu, 'Value',2)
else
    set(handles.lasSource_menu, 'Value', 1)
end

% --- Executes during object creation, after setting all properties.
function backup_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in subtract_menu.
function subtract_menu_Callback(hObject, eventdata, handles)
% 

% --- Executes during object creation, after setting all properties.
function subtract_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mode_menu.
function mode_menu_Callback(hObject, eventdata, handles)
val=get(handles.mode_menu, 'Value');
if val == 1
    set(handles.loadvcc_btn, 'Visible', 'On')
    set(handles.loadGauss_btn, 'Visible', 'On')
    set(handles.initiateRestore_btn, 'Visible', 'Off')
    set(handles.acquireStart_btn, 'Visible', 'Off')
    set(handles.BG_btn, 'Visible', 'Off')
    set(handles.subtract_menu  , 'Visible', 'Off')
    set(handles.text49 , 'Visible', 'Off')  
    
else
    set(handles.loadvcc_btn, 'Visible', 'Off')
    set(handles.loadGauss_btn, 'Visible', 'Off')
    set(handles.initiateRestore_btn, 'Visible', 'On')
    set(handles.acquireStart_btn, 'Visible', 'On')
    %set(handles.BG_btn, 'Visible', 'On')
    set(handles.subtract_menu , 'Visible', 'On')
    set(handles.text49 , 'Visible', 'On')
    
    
    
    
end

% --- Executes during object creation, after setting all properties.
function mode_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)
tags={'Start' 'Stop'};
cols=[.502 1 .502;1 .502 .502];
style=strcmp(get(hObject,'Type'),'uicontrol');
state=gui_acquireStatusGet(hObject,handles);
if style, set(hObject,'String',tags{state+1},'BackgroundColor',cols(state+1,:));end
while gui_acquireStatusGet(hObject,handles)
    handles.initiate=0;
    [img]=grabImage(hObject,handles);
    pause(0.01);
    
    handles=guidata(hObject);
    if isfield(handles.data, 'back')
        imagesc(handles.data.back, 'Parent', handles.axes4); colorbar('peer',handles.axes4); shading interp; 
        title('Background Img')
    end
    if isfield(handles, 'primary')
        printAxes(handles)
    end
    drawnow
end





% --- Executes on button press in initiateRestore_btn.
function initiateRestore_btn_Callback(hObject, eventdata, handles)
if get(handles.initiateRestore_btn, 'Value')
    set(handles.initiateRestore_btn, 'String', 'Restore')
    if epicsSimul_status
        laserStatus(handles,'orig')
        load ~/dbohler/lasCam/ZernikeAnalysis/sampleData/Coh1Only.mat
        data.back=[];
        handles.primary = data.img;
        handles.dualLaserInit.primary=1;
        handles.dualLaserInit.secondary=2;
        printAxes(handles)
        handles.data=data;
    else
        laserStatus(handles,'orig')
        [handles.primary] = grabImage(hObject, handles);
        handles.dualLaserInit = dualLaser_init;
        printAxes(handles)
    end
else
    set(handles.initiateRestore_btn, 'String', 'Initiate')
    if epicsSimul_status 
    else 
       handles.restore=dualLaser_restore(handles.dualLaserInit);
    end
end

guidata(hObject,handles);



% --- Executes on button press in BG_btn.
function BG_btn_Callback(hObject, eventdata, handles)
[~, laspv]=stateCheck(handles);
val = get(handles.camSource_menu, 'Value');

switch val 
    
    case 1
        handles.PV = 'CAMR:IN20:186';
        handles.PVId = 6;
        
    case 2
        handles.PV = 'CAMR:LR20:119';
        handles.PVId = 4;
end

lcaPut(['SHTR:' laspv ':UV_SHUTTER'],1)
% Could be opposite logic or incorrect especially from initial conditions
handles.data=profmon_grab(handles.PV,0,1);
bg=profmon_grabBG(handles.PV,5,'bufd',1);
handles.bg{handles.PVId}=mean(cat(4,bg.img),4);
handles.data.back=handles.bg{handles.PVId};
figure; imagesc(handles.data.back);
lcaPut(['SHTR:' laspv ':UV_SHUTTER'],0)
handles.BG=1;
set(handles.bg_box,'Value',1)
guidata(hObject,handles);

function [state, laserpv]=stateCheck(handles)
state.primary=handles.dualLaserInit.primary;
state.secondary=handles.dualLaserInit.secondary;
laserpv=[];




function [img] = grabImage(hObject, handles)
camSource = get(handles.camSource_menu, 'Value');

switch camSource
    
    case 1
        handles.PV = 'CAMR:IN20:186';
        handles.PVId = 6;
        sname = 'VCC';
        
    case 2
        handles.PV = 'CAMR:LR20:119';
        handles.PVId = 4;
        sname = 'C_IRIS';
end


if epicsSimul_status
    data=handles.data;
    [sx, sy]=size(handles.data.img);
    ra=10*rand(sx,sy);
    rb=10*rand(sx,sy);
    data.img=int16(data.img)+int16(ra)-int16(rb);
else
    data=profmon_grab(handles.PV,0,1);
end

handles = processVCC(handles, data);
guidata(hObject, handles)

if handles.BG
    data.back=handles.data.back;
    data.img=int16(data.img)-int16(data.back);
end
mode = get(handles.mode_menu, 'Value');

backupSource =get(handles.subtract_menu, 'Value');
if backupSource == 2
    ideal = 1;
else
    ideal = 0;
end

if mode ==2
    if isfield(handles, 'primary') && ideal
        
        %img = util_cropImage(data.img);
        img = util_circleFinder(data.img);
        len = length(data.img);
        [handles.gaussBeam, handles.sigma]=dualLaser_createGaussBeam(handles, 'dIdeal',2, ...
            'dIris',2, 'mode', '','nPix', len);
        
        handles.secondary=int16(img)-int16(handles.gaussBeam);
        img=handles.secondary;
    elseif isfield(handles, 'primary') 

        handles.secondary=int16(data.img)-int16(handles.primary);
        img=handles.secondary;
    else
        handles.primary = data.img;
        img=handles.primary;
    end
end

handles.data=data;
guidata(hObject, handles)


% --- Executes on button press in bg_box.
function bg_box_Callback(hObject, eventdata, handles)
val=get(handles.bg_box, 'Value');
if val ==1 
    handles.BG=1;
else
    handles.BG=[];
end
guidata(hObject, handles);

function [] = printAxes(handles)
crop = get(handles.crops_box, 'Value');
if crop
    %croppedPrimary = util_cropImage(handles.primary);
    %croppedSecondary = util_cropImage(handles.secondary);

    croppedPrimary = util_circleFinder(handles.primary);
    croppedSecondary = util_circleFinder(handles.secondary);
else
    croppedPrimary = handles.primary;
    if isfield(handles, 'secondary')
        croppedSecondary = handles.secondary;
    end
end

imagesc(croppedPrimary, 'Parent', handles.axes4); colorbar('peer',handles.axes4); shading interp;
caxis(handles.axes4, [0, 250])
if isfield(handles, 'secondary')
    imagesc(croppedSecondary, 'Parent', handles.axes1); colorbar('peer',handles.axes1); shading interp;
    caxis(handles.axes1, [0, 250])
end
[state, laspv]=stateCheck(handles);
disp(laspv)

title(handles.axes4, ['Primary Source Coherent ' num2str(state.primary)])
title(handles.axes1, ['Secondary Source Coherent ' num2str(state.secondary)])


% --- Executes on button press in plot_box.
function plot_box_Callback(hObject, eventdata, handles)
handles.plot = get(handles.plot_box, 'Value');
guidata(hObject, handles)


% --- Executes on button press in crops_box.
function crops_box_Callback(hObject, eventdata, handles)
crop = get(handles.crops_box, 'Value');
disp(crop)
