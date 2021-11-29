function varargout = spatMod(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spatMod_MainGui_OpeningFcn, ...
                   'gui_OutputFcn',  @spatMod_MainGui_OutputFcn, ...
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


% --- Executes just before spatMod_MainGui is made visible.
function spatMod_MainGui_OpeningFcn(hObject, eventdata, handles, varargin)
global timerRunning;
global timerRestart;
global timerDelay;
global timerData;

timerRunning= false;
timerRestart= false;
timerDelay= 1;      % sec
timerData.hObject= hObject;

handles=appInit(hObject, handles);
% Choose default command line output for spatMod_MainGui
handles.output=hObject;
guidata(hObject, handles);



function handles=appInit(hObject, handles)
handles.bufd=1;
handles.pvs={'SIOC:SYS0:ML02:AO074','SIOC:SYS0:ML02:AO075',...
'SIOC:SYS0:ML02:AO076', 'SIOC:SYS0:ML02:AO077', 'SIOC:SYS0:ML02:AO078'};

handles.tags={'degrees_Txt', 'rCenter1_Txt', ...
    'rCenter2_Txt', 'ratio1_Txt', 'ratio2_Txt'};

handles.cameraDataPV='DMD:IN20:1:SPAT_MOD'; 
handles.camPV1='DMD:IN20:1:CAM_ID1'; 
handles.camPV2='DMD:IN20:1:CAM_ID2'; 
handles.seqPV1='DMD:IN20:1:SEQ_ID1'; 
handles.seqPV2='DMD:IN20:1:SEQ_ID2'; 

handles.shutterPV='TRIG:LR20:LS01:TCTL';

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

handles.buttonPV={...
'DMD:IN20:1:STATUS_ALL';...
'DMD:IN20:1:STATUS_FREE';...
'DMD:IN20:1:STATUS_LOAD';...
'DMD:IN20:1:STATUS_MAP1';...
'DMD:IN20:1:STATUS_MAP2'};

handles.buttonPVreadbacks={...
'loadImage_txt';...
'counter_txt';...
'shutter_txt';...
'makeL_txt';...
'fitL_txt'};

handles.idPV={...
'DMD:IN20:1:CAM_ID1';... 
'DMD:IN20:1:SEQ_ID1';...
'DMD:IN20:1:CAM_ID2';...
'DMD:IN20:1:SEQ_ID2'};

handles.idPVreadbacks={...
    'alpId_txt';...
    'seqId_txt';...
    'cmd_txt';...
    'seqId2_txt'};


handles.handedness=[];
handles.degrees=[];
handles.rCenter1=[];
handles.rCenter2=[];
handles.ratio1=[];
handles.ratio2=[];
handles.dmd1=[];
handles.dmd2=[];
handles.data.img2=[];
handles.sim=[];
handles.useBG=[];

handles.log.axes1=[];
handles.log.axes2=[];
handles.log.axes3=[];
handles.log.mask=[];
handles.data.back=[];


%Make sure this is supposed to execute here?
lcaPutSmart(handles.buttonPV{1}, 1)  %replaces allocate2DMD - white 
lcaPutSmart(handles.buttonPV{3}, 10) %replaces spatMod_loadDMDimage - white (& line below)
% lcaPutSmart(handles.buttonPV{3}, 30)

handles = initGUI(handles);


lcaSetMonitor(handles.buttonPV);
lcaSetMonitor(handles.idPV);

% Update handles structure
guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = spatMod_MainGui_OutputFcn(hObject, eventdata, handles) 
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


function handles=updateGUIvals(hObject, handles)
active = 0;

set (handles.timer_txt,'String',datestr(now));

idx = find(lcaNewMonitorValue(handles.idPV));
if ~isempty(idx)
    val=lcaGetSmart(handles.idPV(idx));
    for loopcnt=1:length(idx)
        set(handles.(handles.idPVreadbacks{idx(loopcnt)}),'String',val(loopcnt));
    end
end

idx = find(lcaNewMonitorValue(handles.buttonPV));
if idx == 3
   if active
       stat=lcaGetSmart(handles.buttonPV{3});
       disp('changed shutter stat')
       lcaPutSmart(handles.shutterPV, stat)
   end
end
if ~isempty(idx)
 val=lcaGetSmart(handles.buttonPV(idx));
    for loopcnt=1:length(idx)
        set(handles.(handles.buttonPVreadbacks{idx(loopcnt)}),'String',val(loopcnt));
    end
end



function handles=initGUI(handles)
val=lcaGet(handles.buttonPV);
for loopcnt=1:length(val)
    set(handles.(handles.buttonPVreadbacks{(loopcnt)}),'String',val(loopcnt));
end

val=lcaGetSmart(handles.idPV);
for loopcnt=1:length(val)
set(handles.(handles.idPVreadbacks{(loopcnt)}),'String',val(loopcnt));
end



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
% updateReadbacks(handles);
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
    zgoal=str2double(get(handles.goalRms_editTxt, 'String'));
    if val ==3 && i > 1 && zerr < zgoal || startBtnStatus == 0
        set(handles.shotNum_txt, 'String', 'Data Acquisition Stopped')
        if zerr < zgoal
            set(handles.shotNum_txt, 'String', 'Data Acquisition Stopped -Error Reached Goal')
        end
        return
    end
    handles = acquireData(hObject, handles);
    pause(0.3)
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
        handles.data.img2=[];
        guidata(hObject, handles);
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



function handles = acquireData(hObject, handles)
gh=get(handles.ghRatio_checkbox, 'Value');
if gh == 1 
    ghRatio = str2double(get(handles.ghRatio_editTxt,'String'));
else 
    ghRatio = 0;
end

eff = str2double(get(handles.efficiency_editTxt, 'String'));
xOffset = str2double(get(handles.offsetX_editTxt, 'String'));
yOffset = str2double(get(handles.offsetY_editTxt, 'String')); 
shape_choice = get(handles.fit_listbox,'Value');
[handles, original,original_cropped] = spatMod_grabImage(hObject, handles);
imagesc(original_cropped, 'Parent', handles.axes1);
colorbar('peer',handles.axes1)
handles.log.axes1=original;
guidata(hObject, handles);
lcaPut(handles.buttonPV{3} , 10) %20 => 1-1st DMD, 0 white image
%This replaces the line below because there is only 1DMD Now
%lcaPut(handles.buttonPV{3} , 20) %20 => 2-2nd DMD, 0 white image


%somtimes img and raw are same image change logic
pause(1)
[img,raw,handles]=spatMod_runshaping(handles, handles.data.img, ... 
    str2double(get(handles.ghRatio_editTxt, 'String')), gh,...
    eff , xOffset, yOffset, shape_choice);

handles.data.img2=img;
handles.data.img3=raw;
handles.sim=1;
guidata(hObject, handles);

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


% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
val=get(handles.imgSelect_listbox, 'Value');
switch val
    case 1
        lcaPutSmart(handles.buttonPV{1}, 4) %white
    case 2
        lcaPutSmart(handles.buttonPV{1}, 5) %L
    case 3
        lcaPutSmart(handles.buttonPV{1}, 6) %VCC
end



function parameter_Callback(hObject, eventdata , handles, tag)
disp(tag)



% --- Executes on button press in ghRatio_checkbox.
function ghRatio_checkbox_Callback(hObject, eventdata, handles)
% if get(handles.ghRatio_checkbox, 'Value')
%     set(handles.ghRatio_editTxt, 'String', '1')
% else
%     set(handles.ghRatio_editTxt, 'String', '0')
% end



function updateReadbacks(handles)
newValues=lcaGet(handles.pvs);
s=length(handles.pvs);
for i = 1:s
    lcaPutSmart(handles.pvs{i}, newValues(i));
    if i ==1 || i==4 || i== 5
        set(handles.(handles.tags{i}), 'String', num2str( newValues(i), '%4.2f'));
    else
        set(handles.(handles.tags{i}), 'String', num2str( newValues(i)));
    end
end


% --- Executes on button press in simulation_checkbox.
function simulation_checkbox_Callback(hObject, eventdata, handles, tag)
if strcmp(tag, 'shape')
   v=1; 
elseif strcmp(tag, 'map')
   v=2;
end

val=get(handles.simulation_checkbox(v), 'Value');
if val==1
    set(handles.simulation_checkbox(:), 'Value',1);
else 
    set(handles.simulation_checkbox(:), 'Value',0);
end

% 


function textBox(handles, tag)
pv =get(handles.(tag), 'TooltipString');
oldValue=num2str(lcaGet(pv));
newValue=str2double(get(handles.(tag), 'String'));

if isnan(newValue)
    set(handles.(tag), 'String', oldValue)
else
    lcaPutSmart(pv, newValue);
end


function editBoxes_Callback(hObject, evendata, handles, tag)
textBox(handles,tag)

function ZoomF_Callback(hObject, eventdata, handles)
%zoom

function zoom_Callback(hObject, eventdata, handles)
%

function goalRms_editTxt_Callback(hObject, eventdata, handles)
% 

function handedness_Txt_Callback(hObject, eventdata, handles)
% 

% --- Executes on button press in input_checkbox.
function input_checkbox_Callback(hObject, eventdata, handles)
val=get(handles.input_checkbox, 'Value');
if val ==1
    set(handles.input_panel', 'visible', 'on')
else
     set(handles.input_panel', 'visible', 'off')
end


function dmd1_Txt_Callback(hObject, eventdata, handles)
% 


function dmd2_Txt_Callback(hObject, eventdata, handles)
% 





function frac1_editTxt_Callback(hObject, eventdata, handles)
% 



function frac2_editTxt_Callback(hObject, eventdata, handles)
% 
% --- Executes during object creation, after setting all properties.


function dmd1_editTxt_Callback(hObject, eventdata, handles)
% 



function dmd2_editTxt_Callback(hObject, eventdata, handles)
% 


function thick_editTxt_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in mapstart1_btn.
function mapstart1_btn_Callback(hObject, eventdata, handles)
frac1=str2double(get(handles.frac1_editTxt, 'String'));
frac2=str2double(get(handles.frac2_editTxt, 'String'));
dmd1=str2double(get(handles.dmd1_editTxt, 'String'));
dmd2=str2double(get(handles.dmd2_editTxt, 'String'));
thick=str2double(get(handles.thick_editTxt, 'String'));
shape=str2double(get(handles.shape_editTxt, 'String'));
values=[frac1, frac2, dmd1, dmd2, thick, shape];
lcaPut(handles.makeShapePV(:), values')

switch shape
    case 0 
        %produces L mask sent to DMD for mapping
        dmdL=spatMod_makeL(values); 
    case 1 
        dmdL=spatMod_makeLshape1(values);
    case 2
        dmdL=spatMod_makeLshape2(values);
    case 3
        dmdL=spatMod_makeLshape3(values);
end

dmdL=logical(dmdL); 
imagesc(dmdL, 'Parent', handles.axes1);
handles.log.axes1=dmdL;
guidata(hObject, handles);
set(handles.imgSelect_listbox, 'Value', 2)
load_btn_Callback(hObject, [], handles)





% --- Executes on button press in mapstart2_btn.
function mapstart2_btn_Callback(hObject, eventdata, handles)
mapValues=lcaGet(handles.makeShapePV(:));
shape = mapValues(6);
[handles, ~,~] = spatMod_grabImage(hObject, handles);
guidata(hObject, handles)
switch shape
    case 0 
        [cameraL ,newValues]=spatMod_fitL(handles, mapValues);

    case 1
        [cameraL ,newValues]=spatMod_fitLshape1(handles,mapValues);
        
    case 2
        [cameraL ,newValues]=spatMod_fitLshape2(handles,mapValues);
        
    case 3
        [cameraL ,newValues]=spatMod_fitLshape3(handhles,mapValues);
end

imagesc(cameraL, 'Parent', handles.axes2);
title(handles.axes2,[handles.data.name ':' datestr(handles.data.ts)])

handles.log.axes2=cameraL;
guidata(hObject, handles);
set(handles.hand_editTxt,'String', num2str(newValues(1)));
set(handles.deg_editTxt,'String', num2str(newValues(2)));
set(handles.degrees_Txt,'String', num2str(newValues(2)));
set(handles.rCenter1_editTxt,'String', num2str(newValues(3)));
set(handles.rCenter1_Txt,'String', num2str(newValues(3)));
set(handles.rCenter2_editTxt,'String', num2str(newValues(4)));
set(handles.rCenter2_Txt,'String', num2str(newValues(4)));
set(handles.ratio1_editTxt,'String', num2str(newValues(5)));
set(handles.ratio1_Txt,'String', num2str(newValues(5)));
set(handles.ratio2_editTxt,'String', num2str(newValues(6)));
set(handles.ratio2_Txt,'String', num2str(newValues(6)));
set(handles.imgSelect_listbox, 'Value', 3)
%load_btn_Callback(hObject, [], handles)
% lcaPutSmart(handles.buttonPV{5}, 10)
%lcaPut(handles.buttonPV{5}, 20) %20 is white image 21 would be cameraL(replaced spatMod_loadDMDimage(handles.ALP_ID2,handles.sequenceId2,white)


% --- Executes on selection change in testLoc_listbox.
function testLoc_listbox_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in allocate_btn.
function allocate_btn_Callback(hObject, eventdata, handles)
val=get(handles.testLoc_listbox,'Value');
if val == 1
    [handles.ALP_ID,handles.sequenceId, a] = spatMod_controlDMD('allocate', get(handles.offline_checkbox)); %replaced allocate2DMD
    white=imread('/usr/local/lcls/tools/matlab/toolbox/images/white','bmp');
    spatMod_loadDMDimage(handles.ALP_ID,handles.sequenceId,white)
    guidata(hObject, handles)
    
elseif val == 2
    lcaPut(handles.buttonPV{1}, 1)  %replaces allocate2DMD
    %[handles.ALP_ID1,handles.ALP_ID2,handles.sequenceId1,handles.sequenceId2]=allocate2DMD(width1,delay1,width2,delay2);
    %then writes values returned to pvs...
    
    lcaPut(handles.buttonPV{3}, 10) 
    %lcaPut(handles.buttonPV{3}, 30) %replaces spatMod_loadDMDimage - white

end


% --- Executes on button press in free_btn.
function free_btn_Callback(hObject, eventdata, handles)
val=get(handles.testLoc_listbox,'Value');
if val ==1
    spatMod_free2DMD(handles.ALP_ID1,handles.sequenceId1);
elseif val==2
    lcaPut(handles.buttonPV{1}, 3) %replaces spatMod_free2DMD
    % spatMod_free2DMD(handles.ALP_ID1,handles.ALP_ID2,handles.sequenceId1,handles.sequenceId2);
end



function shape_editTxt_Callback(hObject, eventdata, handles)
% 

function width1_editTxt_Callback(hObject, eventdata, handles)
% 

function width2_editTxt_Callback(hObject, eventdata, handles)
% 

function delay1_editTxt_Callback(hObject, eventdata, handles)
% 

function delay2_editTxt_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in offline_checkbox.
function offline_checkbox_Callback(hObject, eventdata, handles,tag)
if strcmp(tag, 'shape')
   v=1; 
elseif strcmp(tag, 'map')
   v=2;
end
boxStatus=get(handles.offline_checkbox(v), 'Value');
set(handles.offline_checkbox(:), 'Value', boxStatus)





% --- Executes on button press in showmask_checkbox.
function showmask_checkbox_Callback(hObject, eventdata, handles)
%


% --- Executes on selection change in imgSelect_listbox.
function imgSelect_listbox_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function imgSelect_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shutter_btn.
function shutter_btn_Callback(hObject, eventdata, handles)
offline = get(handles.offline_checkbox, 'Value');
if ~offline{1}   
    val=get(handles.shutter_btn, 'Value');
    
    if val == 1
        set(handles.shutter_btn, 'String', 'Shutter Enabled', 'BackgroundColor', [1 0 0])
        lcaPut(handles.buttonPV{3},1)
    elseif  val == 0
        set(handles.shutter_btn, 'String', 'Shutter Disabled', 'BackgroundColor', [0 1 0])

    end
    set(handles.shotNum_txt,'String', ' ')
    
else
    set(handles.shotNum_txt,'String', 'Uncheck VCC Offline to enable shutter')
end


% --- Executes on button press in allocateSequence_btn.
function allocateSequence_btn_Callback(hObject, eventdata, handles)
lcaPut(handles.buttonPV{1}, 2)  


% --- Executes on button press in reset_btn.
function reset_btn_Callback(hObject, eventdata, handles)
lcaPut(handles.buttonPV, 0);

% --- Executes on selection change in panel_listbox.
function panel_listbox_Callback(hObject, eventdata, handles)
val=get(handles.panel_listbox, 'Value');
switch val
    case 2 %mapping panel
        set(handles.map_panel, 'visible', 'on')
        set(handles.shape_panel, 'visible', 'off')
        set(handles.read_panel, 'visible', 'off')
        set(handles.axes3, 'visible', 'off')
        
    case 3 % shaping panel
        set(handles.map_panel, 'visible', 'off')
        set(handles.shape_panel, 'visible', 'on')
        set(handles.read_panel, 'visible', 'off')
        set(handles.axes3, 'visible', 'on')
        
    case 4 % readback panel
        set(handles.map_panel, 'visible', 'off')
        set(handles.shape_panel, 'visible', 'off')
        set(handles.read_panel, 'visible', 'on')
    
end
removeTicks(handles, {'axes1','axes2','axes3'})


% --- Executes during object creation, after setting all properties.
function panel_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function removeTicks(handles, hdl)
for i=1:length(hdl)
        set(handles.(hdl{i}), 'XTick', [])
        set(handles.(hdl{i}), 'YTick', [])
end




% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)
if ~isfield(handles,'data'), return, end
strlogbook = handles.data.name;
dataExport(handles.output, handles, strlogbook);
dataSave(handles.output, handles,'SpatMod');




function handles = dataExport(hObject, handles, title)
handles.exportFig=figure;
str='axes1';
util_copyAxes(handles.(str));
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14, 'title','TEST' );
util_printLog(handles.exportFig,'title', [title ' ' 'Laser Shaping GUI']);
if isfield(handles, 'exportFig')
    cla(handles.exportFig);
    close(handles.exportFig);
end

function handles = dataSave(hObject, handles, title)
if ~isfield(handles,'data'), return, end
handles.data.log=handles.log;
name=handles.data.name;
data=handles.data;
fileName=util_dataSave(data,title,name,data.ts);
if ~ischar(fileName), return, end
handles.fileName=fileName;
guidata(hObject,handles);


% --- Executes on button press in useBG_box.
function useBG_box_Callback(hObject, eventdata, handles)
if get(handles.useBG_box, 'Value')  && ~isempty(handles.data.back)
    choice = questdlg('Take New BG image?', ...
        'User decision','Yes','No','Cancel','Cancel');
    if strcmp(choice,'Yes')
        val = get(handles.profSel_listbox, 'Value');
        switch val
            
            case 1
                sname='VCC';
                
            case 2
                sname='YAGO1';
                
            case 3
                sname='VHC';
            case 4
                sname='YAGO2';
                
            case 5
                sname='C_IRIS';
        end
        
        handles.data=profmon_measure(sname,1,'nBG',5,'doPlot',0,'saves',0,'keepBack',1); %grab newBG
        guidata(hObject, handles)
    else
        return
    end
end
