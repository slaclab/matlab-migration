function varargout = spatMod_InjGui(varargin)
% SPATMOD_INJGUI MATLAB code for spatMod_InjGui.fig
%      SPATMOD_INJGUI, by itself, creates a new SPATMOD_INJGUI or raises the existing
%      singleton*.
%
%      H = SPATMOD_INJGUI returns the handle to a new SPATMOD_INJGUI or the handle to
%      the existing singleton*.
%
%      SPATMOD_INJGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPATMOD_INJGUI.M with the given input arguments.
%
%      SPATMOD_INJGUI('Property','Value',...) creates a new SPATMOD_INJGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spatMod_InjGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spatMod_InjGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spatMod_InjGui

% Last Modified by GUIDE v2.5 02-Feb-2016 17:16:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spatMod_InjGui_OpeningFcn, ...
                   'gui_OutputFcn',  @spatMod_InjGui_OutputFcn, ...
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


% --- Executes just before spatMod_InjGui is made visible.
function spatMod_InjGui_OpeningFcn(hObject, eventdata, handles, varargin)
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;

timerRunning= false;
timerRestart= false;
timerDelay= 1;      % sec
timerData.hObject= hObject;


% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spatMod_InjGui (see VARARGIN)
handles=appInit(hObject,handles);
% Choose default command line output for spatMod_InjGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spatMod_InjGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);



function handles=appInit(hObject,handles)
global timerData;

% handles.transferBit='SIOC:SYS0:ML02:AO047';
handles.cameraDataPV='DMD:IN20:1:SPAT_MOD';

handles.buttonPV={...
'DMD:IN20:1:STATUS_ALL';...
'DMD:IN20:1:STATUS_FREE';...
'DMD:IN20:1:STATUS_LOAD';...
'DMD:IN20:1:STATUS_MAP1';...
'DMD:IN20:1:STATUS_MAP2'};

lcaPut(handles.buttonPV, 0);

handles = initGUI(handles);

handles.ALP_ID=lcaGet('DMD:IN20:1:CAM_ID1');
handles.sequenceId=lcaGet('DMD:IN20:1:SEQ_ID1');

% handles.ALP_ID2=lcaGet('DMD:IN20:1:CAM_ID2');
% handles.sequenceId2=lcaGet('DMD:IN20:1:SEQ_ID2');

handles.cameraDataPV='DMD:IN20:1:SPAT_MOD'; 

handles.idPV={...
'DMD:IN20:1:CAM_ID1';... 
'DMD:IN20:1:SEQ_ID1'};
% 'DMD:IN20:1:CAM_ID2';...
% 'DMD:IN20:1:SEQ_ID2'

handles.makeShapePV={...
'DMD:IN20:1:FRAC_VERT';...
'DMD:IN20:1:FRAC_HORZ';...
'DMD:IN20:1:DMD_VERT';...
'DMD:IN20:1:DMD_HORZ';...
'DMD:IN20:1:THICK';...
'DMD:IN20:1:SHAPE'};

handles.triggerPV={...
'DMD:IN20:1:WIDTH_1';...
'DMD:IN20:1:DELAY_1';...
'DMD:IN20:1:WIDTH_2';...
'DMD:IN20:1:DELAY_2'};

handles.buttonTags={'ALL';'FREE'; 'LOAD'; 'MAP1'; 'MAP2'};

lcaSetMonitor(handles.cameraDataPV);
lcaSetMonitor(handles.buttonPV);
lcaSetMonitor(handles.idPV);


% --- Outputs from this function are returned to the command line.
function varargout = spatMod_InjGui_OutputFcn(hObject, eventdata, handles) 
global timerData;
global timerRunning;

% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB1
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
handles=RefreshGUI(handles);
if timerRunning
timerData.handles = handles;
end

% Update handles structure
guidata(hObject, handles);


function handles=RefreshGUI(handles)
global timerObj;
global timerDelay;
global timerRestart;
global timerRunning;
global timerData;
if (timerRunning)
    stop (timerObj);
end

ff=handles.output;
timerObj=timer('TimerFcn', @(obj, eventdata) timer_Callback(ff) , 'Period', timerDelay, 'ExecutionMode', 'fixedRate', 'BusyMode','drop');
timerRestart = true;
timerData.handles = handles;
start(timerObj);
timerRunning = true;

function timer_Callback (handleToGuiFigure0)
% global timerData;
% global timerRunning;
% handles    = timerData.handles;
% hObject    = timerData.hObject;
handles = guidata(handleToGuiFigure0); % added to unlock handles 
handles = updateGUIvals(handleToGuiFigure0, handles);
guidata (handleToGuiFigure0, handles );
%timerData.handles = handles;


function handles=updateGUIvals(hObject, handles)
tt=datestr(now);
set (handles.timer_txt,'String',tt);
formatOut ='ss';
lcaPut(handles.buttonPV{2},datestr(tt, formatOut))

idx = find(lcaNewMonitorValue(handles.cameraDataPV));
if ~isempty(idx)
    val=lcaGet(handles.cameraDataPV);
    for loopcnt=1:length(idx)
        set(handles.pv_txt,'String',val(loopcnt));
        microMask_btn_Callback(hObject, [], handles)
    end
end

idx = find(lcaNewMonitorValue(handles.buttonPV));
if ~isempty(idx)
    %buttonPress(hObject, handles, handles.buttonTags{idx})
    buttonPress(hObject, handles, idx)
end




function handles=initGUI(handles)

val=lcaGet(handles.cameraDataPV);
for loopcnt=1:length(val)
    set(handles.pv_txt,'String',val(loopcnt));
end
val=lcaGet(handles.buttonPV);
disp(val)
        

% --- Executes on button press in microMask_btn.
function microMask_btn_Callback(hObject, eventdata, handles)
[micromask]=grabMicroMask(handles);
% Make sure to revisit ALP_ID2/SEQ2 and loadImage%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%spatMod_loadDMDimage(str2double(handles.ALP_ID2{1}),str2double(handles.sequenceId2{1}),micromask)
spatMod_controlDMD(handles, 'loadImage', micromask) 
imagesc(micromask,'Parent', handles.axes1);


function [micro]=grabMicroMask(handles)
[mask, par]=spatMod_saveImg(handles, [], 'read');
%micro=makeMicroMask(macromask,par);
micro=logical(mask);

function [dmdL]=makeLshape(values, selectShape)
switch selectShape
    case 0 
        dmdL=spatMod_makeL(values);%change this name to dmdL
    case 1 
        dmdL=spatMod_makeLshape1(values);
    case 2
        dmdL=spatMod_makeLshape2(values);
    case 3
        dmdL=spatMod_makeLshape3(values);
end

function [camL, newVal] = fitLshape(handles, values, selectShape)
switch selectShape
    case 0
        [camL, newVal] = spatMod_fitL(handles, values);%change this name to dmdL
    case 1
        [camL, newVal] = spatMod_fitLshape1(handles, values);
    case 2
        [camL, newVal] = spatMod_fitLshape2(handles, values);
    case 3
        [camL, newVal] = dspatMod_fitLshape3(handles, values);
end

function loadimage(handles,val,img)

switch val
    case 4
        %white=imread('/usr/local/lcls/tools/matlab/toolbox/images/white','bmp');
        white=imread('C:\DMD\spatMod_04012016\white', 'bmp');
        spatMod_controlDMD(handles, 'loadImage',  white)
        
    case 5 
        spatMod_controlDMD(handles, 'loadImage', img)
         
        
end


function buttonPress(hObject, handles, num)
status = lcaGet(handles.buttonPV{1});

switch status
    
    case 0
        return
    case 1
        allocate_btn_Callback(hObject, [], handles)   
        
    case 2
        [handles.ALP_ID,handles.sequenceId, a] = spatMod_controlDMD(handles, 'allocateSequence');
        
    case 3
       haltFree_btn_Callback(hObject, [], handles)
       
   case 4 %White
        loadimage(handles,4)
        
    case 5 %L
        values=lcaGet(handles.makeShapePV);
        sel=values(6);
        values=values(1:5);
        [imgL]=makeLshape(values, sel);
        imgL=logical(imgL);
        loadimage(handles,5,imgL)  
       
    case 6 %VCC 
        values=lcaGet(handles.makeShapePV);
        sel=values(6);
        values=values(1:4);
        [img, ~]=fitLshape(handles, values, sel);
        loadimage(handles,5,img)
end

lcaPut(handles.buttonPV{1}, 0)
val =lcaGet(handles.buttonPV); % to reset the monitor
disp(val)
disp('End of Button Press')

% --- Executes on button press in offline_checkbox.
function offline_checkbox_Callback(hObject, eventdata, handles)
% 


function micromask=makeMicroMask(macromask,parameters)
%this function produces a mask of DMD dimensions based on a macromask. 
%secLength: the length of macro pixels in terms of micro pixels.

%micromask=ones(size(macromask,1)*secLength,size(macromask,2)*secLength);

secLength=parameters(1);
dmd1=parameters(2);
dmd2=parameters(3);
micromask=zeros(dmd1,dmd2);

for i=1:size(macromask,1)
    for j=1:size(macromask,2)
        leftInd=(j-1)*secLength+1;
        rightInd=j*secLength;
        topInd=(i-1)*secLength+1;
        bottomInd=i*secLength;
        pixels=secLength*secLength;%total number of pixels in this section
        pixelsOff=ceil(pixels*macromask(i,j));%number of pixels to be turned off in this section
        r = randperm(pixels, pixelsOff);
        section=ones(secLength,secLength);
        for k=1:size(r,2)
            ind=r(k);
            section(ind)=0;
        end
        micromask(topInd:bottomInd,leftInd:rightInd)=section;
    end
end
%black out the area outside beam
bw=edge(micromask);
projx=sum(bw,1);
x01=find(projx>2,1,'first');
x02=find(projx>2,1,'last');
projy=sum(bw,2);
y01=find(projy>2,1,'first');
y02=find(projy>2,1,'last');
c1=y01+round((y02-y01)/2);
c2=x01+round((x02-x01)/2);
x=-c2:size(micromask,2)-c2-1;
y=-c1:size(micromask,1)-c1-1;
[X,Y]=meshgrid(x,y);
[~,rho]=cart2pol(X,Y);
radius=round((x02-x01)/2);
micromask(rho>(radius+3))=0;




% --- Executes on button press in allocate_btn.
function allocate_btn_Callback(hObject, eventdata, handles)
[~,~, a] = spatMod_controlDMD(handles, 'allocate',[]);
disp(a)
set(handles.misc_txt,'String', a)


% --- Executes on button press in allocateSequence_btn.
function allocateSequence_btn_Callback(hObject, eventdata, handles)
[~,~, a] = spatMod_controlDMD(handles, 'allocateSequence');
set(handles.misc_txt,'String', a)

% --- Executes on button press in haltFree_btn.
function haltFree_btn_Callback(hObject, eventdata, handles)
[~,~, a] = spatMod_controlDMD(handles, 'haltFreeImage');
set(handles.misc_txt,'string',a)


% --- Executes on button press in loadWhite_btn.
function loadWhite_btn_Callback(hObject, eventdata, handles)
%white=imread('/usr/local/lcls/tools/matlab/toolbox/images/white','bmp');
white=imread('C:\DMD\spatMod_3_16_2016\dmdL','bmp');
spatMod_controlDMD(handles, 'loadImage', white)
