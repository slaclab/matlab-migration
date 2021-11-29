function varargout = IRISsteerstart(varargin)
% IRISSTEERSTART M-file for IRISsteerstart.fig
%      IRISSTEERSTART, by itself, creates ai new IRISSTEERSTART or raises the existing
%      singleton*.
%
%      H = IRISSTEERSTART returns the handle to ai new IRISSTEERSTART or the handle to
%      the existing singleton*.
%
%      IRISSTEERSTART('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IRISSTEERSTART.M with the given input arguments.
%
%      IRISSTEERSTART('Property','Value',...) creates ai new IRISSTEERSTART or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IRISsteerstart_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IRISsteerstart_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IRISsteerstart

% Last Modified by GUIDE v2.5 27-Feb-2015 03:17:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IRISsteerstart_OpeningFcn, ...
                   'gui_OutputFcn',  @IRISsteerstart_OutputFcn, ...
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



% --- Executes just before IRISsteerstart is made visible.
function IRISsteerstart_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in ai future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IRISsteerstart (see VARARGIN)

% Choose default command line output for IRISsteerstart
handles.output = hObject;

util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles.PVList={ ...
    'CAMR:LR20:113'  'CAMR:LR20:114'  'CAMR:LR20:119'  'CAMR:IN20:186' ...
    'CAMR:IN20:461'  'CAMR:IN20:469' ...
    'CTHD:IN20:206'  'YAGS:IN20:211'  'YAGS:IN20:841'  'YAGS:IN20:241' ...
    'YAGS:IN20:351'  'OTRS:IN20:465'  'OTRS:IN20:471'  'OTRS:IN20:541' ...
    'OTRS:IN20:571'  'OTRS:IN20:621'  'OTRS:IN20:711'  'YAGS:IN20:921' ...
    'YAGS:IN20:995'  'OTRS:LI21:237'  'OTRS:LI21:291'  'OTRS:LI24:807' ...
    'OTRS:LI25:342'  'OTRS:LI25:920'  'PROF:BSY0:45'   'PROF:BSY0:55'  ...
    'PROF:BSYA:1800' ...
    'OTRS:LTU1:449'  'OTRS:LTU1:745'  'YAGS:UND1:1650' 'YAGS:DMP1:498' ...
    'YAGS:DMP1:500'  'OTRS:DMP1:695'  ...
    'CAMR:FEE1:455'  'DIAG:FEE1:481'  'DIAG:FEE1:482' ...
    'CAMR:FEE1:852'  'CAMR:FEE1:913'  'CAMR:FEE1:1561' 'CAMR:FEE1:1692' ...
    'CAMR:FEE1:1953' 'CAMR:FEE1:2953' ...
    'CAMR:NEH1:124'  'CAMR:NEH1:195'  'CAMR:NEH1:1124' 'CAMR:NEH1:2124' ...
    'HXX:UM6:CVP:01' ...
    'AMO:DIA-CVV-02' ...
    };

handles.PVId=[4 3];
[sys,accel]=getSystem;
if strcmp(accel,'FACET')
    handles.PVList={ ...
        'YAGS:LI20:2432' ...
        'OTRS:LI20:3070' ...
        'OTRS:LI20:3158' ...
        'OTRS:LI20:3175' ...
        'OTRS:LI20:3180' ...
        'OTRS:LI20:3206' ...
        'MIRR:LI20:3202' ...
        'EXPT:LI20:3208' ...
        'OTRS:LI20:3208' ...
        'MIRR:LI20:3230' ...
        'PROF:LI20:3483' ...
        'PROF:LI20:3485' ...
        };
    handles.PVId=[1 1];
end

%feedback loop status
lockfb = lcaGet('LASR:LR20:110:POS_FDBK');
TF = strcmp('Close Loop',lockfb);
if TF == 1
    zz = 'Loop Closed';
else
    zz = 'Loop Open';
end
fb = findobj(gcf,'Tag','zz');
set(fb,'String',zz);

handles.stepSizeval = 0.001;
stepSizeval = 0.001;
step = findobj(gcf,'Tag','stepSizeval');
set(step,'String',num2str(stepSizeval));

%set initial mirror positions
global ai ci ei gi
ai = lcaGet({'MIRR:LR20:113:M18_MOTR_H.RBV'});
ci = lcaGet({'MIRR:LR20:113:M18_MOTR_V.RBV'});
ei = lcaGet({'MIRR:LR20:117:IRIS_MOTR_H.RBV'});
gi = lcaGet({'MIRR:LR20:117:IRIS_MOTR_V.RBV'});
Units = ' mm';
M18Hi = findobj(gcf,'Tag','ai');
set(M18Hi,'String',[num2str(ai) Units]);
M18Vi = findobj(gcf,'Tag','ci');
set(M18Vi,'String',[num2str(ci) Units]);
M17Hi = findobj(gcf,'Tag','ei');
set(M17Hi,'String',[num2str(ei) Units]);
M17Vi = findobj(gcf,'Tag','gi');
set(M17Vi,'String',[num2str(gi) Units]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.bitvcc = 7;
handles.bitciris = 6;
handles.PV=handles.PVList(handles.PVId);
handles.nPV=numel(handles.PVId);
for j=1:handles.nPV
    str=num2str(j);if j == 1, str='';end
    if j==1; %added
        handles=bitsControl(hObject,handles,handles.bitvcc,j);
    else %added
        handles=bitsControl(hObject,handles,handles.bitciris,j); %added
    end %added
    set(handles.(['device' str '_pmu']),'String', ...
        [{'none'} model_nameConvert(handles.PVList,'MAD')],'Value',handles.PVId(j)+1);
end
handles.zoom=0;
handles.bufd=1;
handles.posOld=get(hObject,'Position');
handles.useBG=0;
handles.show.bg=0;

for j=1:2%length(handles.PVList)
    handles.bg{j}=0;
end
handles.ytv = 280;
handles.ybv = 150;
handles.xrv = 420;
handles.xlv = 260;

handles.ytc = 235;
handles.ybc = 125;
handles.xrc = 500;
handles.xlc = 380;

handles.steer = 0;
set(hObject,'Color','k');

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = IRISsteerstart_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes when user attempts to close IRISsteerstart.
function profmon_multi_gui_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);

% -----------------------------------------------------------
function handles = plot_image(hObject, handles)
global backIRIS backVCC
if ~isfield(handles,'data'), return, end
for j=1:2
    str='';if j > 1, str=num2str(j);end
    ax=handles.(['axes' str]);
    if ~handles.PVId(j), cla(ax,'reset');set(ax,'Box','on');continue, end
    if handles.useBG == 0;
        if j ==1;
            data1=handles.data(1);
            data = profmon_imgCrop(data1, [handles.xlv handles.xrv handles.ybv handles.ytv]);
        else 
            data2 = handles.data(2);       
            data = profmon_imgCrop(data2, [handles.xlc handles.xrc handles.ybc handles.ytc]);
        end
    else
        if j ==1;
            data1=handles.data(1);
            data1.img = data1.img - backVCC.img;
            data = profmon_imgCrop(data1, [handles.xlv handles.xrv handles.ybv handles.ytv]);
        else 
            data2 = handles.data(2);    
            data2.img = data2.img - backIRIS.img;
            data = profmon_imgCrop(data2, [handles.xlc handles.xrc handles.ybc handles.ytc]);
        end
    end
    profmon_imgPlot(data,'axes',ax,'cal',1,'aspect',1, ...
        'scale',~handles.zoom,'tag',1-.5*(now-data.ts > 1e-4), ...
        'title',['%s ' datestr(data.ts)],'bits',handles.bits.jVal(j));
end

%-----------------------------------------------------------
function handles = grab_image(hObject, handles)

nImg=[];
for j=1:handles.nPV
    if ~handles.PVId(j), continue, end
%     if handles.bufd && ~strncmp(handles.PV{j},'DIAG',4) && ~strncmp(handles.PV{j},'SXR',3) && ~strncmp(handles.PV{j},'13PS',4) 
%         nImg=0;
%         lcaPutSmart([handles.PV{j} ':SAVE_IMG'],1);
%     end
    try
        handles.data(j)=profmon_grab(handles.PV{j},0,nImg);
    catch
    end
end
guidata(hObject,handles);
plot_image(hObject,handles);

% ------------------------------------------------------------------------
function handles = bitsControl(hObject, handles, val, num)

handles=gui_sliderControl(hObject,handles,'bits',val,12,1,num);
if ~gui_acquireStatusGet(hObject,handles)
    plot_image(hObject,handles);
end

% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)
tags={'Start' 'Stop'};
cols=[.502 1 .502;1 .502 .502];
style=strcmp(get(hObject,'Type'),'uicontrol');
state=gui_acquireStatusGet(hObject,handles);
if style, set(hObject,'String',tags{state+1},'BackgroundColor',cols(state+1,:));end
if state, for j=1:handles.nPV, if handles.PVId(j), profmon_evrSet(handles.PV{j});end, end, end
while gui_acquireStatusGet(hObject,handles)
    grab_image(hObject,handles);
    pause(.01);
    handles=guidata(hObject);
end

% -----------------------------------------------------------
function zoomControl(hObject, handles, val)
if isempty(val)
    val=handles.zoom;
end
handles.zoom=val;
set(handles.zoom_box,'Value',val);
state={'off' 'on'};
zoom(gcbf,state{handles.zoom+1});
if ~handles.zoom
    plot_image(hObject,handles);
end
guidata(hObject,handles);


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

acquireStart(hObject,handles);


% --- Executes on slider movement.
function bits_sl_Callback(hObject, eventdata, handles, num)
a = get(hObject, 'Value');
fb = get(gco, 'Tag');
if strcmp(fb, 'bits_sl')
    handles.bitvcc = a;
else
    handles.bitciris = a;
end
guidata(hObject, handles)
bitsControl(hObject,handles,round(get(hObject,'Value')),num);

% --- Executes on button press in zoom_box.
function zoom_box_Callback(hObject, eventdata, handles)

zoomControl(hObject,handles,get(hObject,'Value'));

% --- Executes when IRISsteerstart is resized.
function profmon_multi_gui_ResizeFcn(hObject, eventdata, handles)

if isempty(handles), return, end
pos=get(hObject,'Position');
nRow=1;
nCol=2;
pos0=[6 4]+[nCol*66 nRow*26];
handles.posOld=get(hObject,'Position');
guidata(hObject,handles);
handles=newObjects(hObject,handles,nRow*nCol);
placeObjects(hObject,handles,nRow);


function placeObjects(hObject, handles, nRow)

for j=1:handles.nPV
    iRow=mod(j-1,nRow)+0.1;
    iCol=floor((j-1)/nRow)+1;
    str='';if j > 1, str=num2str(j);end
    hh=[handles.(['axes' str]) handles.(['bits' str '_sl']) handles.(['bits' str '_txt']) ...
        handles.(['bits' str 'Label_txt']) handles.(['device' str '_pmu'])];
    if j == 1, hh(6:7)=[handles.zoom_box handles.acquireStart_btn];end
    pp=cell2mat(get(hh,'Position'));
    pn=[pp(:,1)-min(pp(:,1))+8.8+66*(iCol-1) ...
        pp(:,2)-min(pp(:,2))+4.538+66*5/13*(nRow-iRow)];
    set(hh,{'Position'},num2cell([pn pp(:,3:4)],2));
    set(hh(2:min(end,6)),'ForegroundColor','w');
    set(hh(2:min(end,6)),'BackgroundColor','k');
    set(hh(1),{'XColor' 'YColor' 'Color'},{'w' 'w' 'k'});
    set(get(hh(1),'Title'),'Color','w');
end


function handles = newObjects(hObject, handles, num)

% Remove obsolete entries
for j=num+1:handles.nPV
    str='';if j > 1, str=num2str(j);end
    hh=[handles.(['axes' str]) handles.(['bits' str '_sl']) handles.(['bits' str '_txt']) ...
        handles.(['bits' str 'Label_txt']) handles.(['device' str '_pmu'])];
    delete(hh);
end

% Create new entries
for j=handles.nPV+1:num
    handles.PVId(j)=0;
    hh0=[handles.axes handles.bits_sl handles.bits_txt handles.bitsLabel_txt handles.device_pmu];
    hh=num2cell(copyobj(hh0,handles.output));
    str='';if j > 1, str=num2str(j);end
    [handles.(['axes' str]) handles.(['bits' str '_sl'])  handles.(['bits' str '_txt']) ...
        handles.(['bits' str 'Label_txt']) handles.(['device' str '_pmu'])]=deal(hh{:});
    set(hh{2},'CallBack',['profmon_multi_gui(''bits_sl_Callback'',gcbo,[],guidata(gcbo),' str ')']);
    set(hh{5},'CallBack',['profmon_multi_gui(''device_pmu_Callback'',gcbo,[],guidata(gcbo),' str ')']);

    handles=bitsControl(hObject,handles,8,j);
    set(handles.(['device' str '_pmu']),'String', ...
        [{'none'} model_nameConvert(handles.PVList,'MAD')],'Value',handles.PVId(j)+1);
end
handles.nPV=num;
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
%M18H increment button
function pushbutton3_Callback(hObject, eventdata, handles)
tic
a = lcaGet({'MIRR:LR20:113:M18_MOTR_H'});
b = a + 0.001;
lcaPut('MIRR:LR20:113:M18_MOTR_H', b);
Units = ' mm';
M18H = findobj(gcf,'Tag','b');
set(M18H,'String',[num2str(b) Units]);
toc
% --- Executes on button press in pushbutton4.
%M18H decrement button
function pushbutton4_Callback(hObject, eventdata, handles)
tic
a = lcaGet({'MIRR:LR20:113:M18_MOTR_H'});
b = a - 0.001;
lcaPut('MIRR:LR20:113:M18_MOTR_H', b);
Units = ' mm';
M18H = findobj(gcf,'Tag','b');
set(M18H,'String',[num2str(b) Units]);
toc

% --- Executes on button press in pushbutton5.
%M18V decrement button
function pushbutton5_Callback(hObject, eventdata, handles)
tic
c = lcaGet({'MIRR:LR20:113:M18_MOTR_V'});
d = c - 0.001;
lcaPut('MIRR:LR20:113:M18_MOTR_V', d);
Units = ' mm';
M18V = findobj(gcf,'Tag','d');
set(M18V,'String',[num2str(d) Units]);
toc

% --- Executes on button press in pushbutton6.
%M18V increment button
function pushbutton6_Callback(hObject, eventdata, handles)
tic
c = lcaGet({'MIRR:LR20:113:M18_MOTR_V'});
d = c + 0.001;
lcaPut('MIRR:LR20:113:M18_MOTR_V', d);
Units = ' mm';
M18V = findobj(gcf,'Tag','d');
set(M18V,'String',[num2str(d) Units]);
toc

% --- Executes on button press in pushbutton19.
%M17H increment
function pushbutton19_Callback(hObject, eventdata, handles)
tic
e = lcaGet({'MIRR:LR20:117:IRIS_MOTR_H'});
f = e - handles.stepSizeval;
lcaPut('MIRR:LR20:117:IRIS_MOTR_H', f);
Units = ' mm';
M17H = findobj(gcf,'Tag','f');
set(M17H,'String',[num2str(f) Units]);
toc

% --- Executes on button press in pushbutton20.
%M17H decrement
function pushbutton20_Callback(hObject, eventdata, handles)
tic
e = lcaGet({'MIRR:LR20:117:IRIS_MOTR_H'});
f = e + handles.stepSizeval;
lcaPut('MIRR:LR20:117:IRIS_MOTR_H', f);
Units = ' mm';
M17H = findobj(gcf,'Tag','f');
set(M17H,'String',[num2str(f) Units]);
toc


% --- Executes on button press in pushbutton21.
%M17V decrement
function pushbutton21_Callback(hObject, eventdata, handles)
tic
g = lcaGet({'MIRR:LR20:117:IRIS_MOTR_V'});
h = g + handles.stepSizeval;
lcaPut('MIRR:LR20:117:IRIS_MOTR_V', h);
Units = ' mm';
M17V = findobj(gcf,'Tag','h');
set(M17V,'String',[num2str(h) Units]);
toc


% --- Executes on button press in pushbutton22.
%M17V increment
function pushbutton22_Callback(hObject, eventdata, handles)
tic
g = lcaGet({'MIRR:LR20:117:IRIS_MOTR_V'});
h = g - handles.stepSizeval;
lcaPut('MIRR:LR20:117:IRIS_MOTR_V', h);
Units = ' mm';
M17V = findobj(gcf,'Tag','h');
set(M17V,'String',[num2str(h) Units]);
toc
% --- Executes on button press in pushbutton24.
%restores initial mirror positions
function pushbutton24_Callback(hObject, eventdata, handles)
global ei gi
tic
lcaPut('MIRR:LR20:117:IRIS_MOTR_H',ei);
lcaPut('MIRR:LR20:117:IRIS_MOTR_V',gi);
toc

% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
global data1 data2
data1=profmon_grab('CAMR:LR20:119');
data2= profmon_imgCrop(data1, [handles.xlc handles.xrc handles.ybc handles.ytc]);
profmon_imgPlot(data2, 'bits', handles.bitciris);
util_appPrintLog(2,'Iris Steer',data2.name,data2.ts);
util_dataSave(data2,'ProfMon',data2.name,data2.ts);

% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
global data3 data4
data3=profmon_grab('CAMR:IN20:186');
data4 = profmon_imgCrop(data3, [handles.xlv handles.xrv handles.ybv handles.ytv]);
profmon_imgPlot(data4, 'figure', 3, 'bits', handles.bitvcc);
util_printLog(3,'title','Iris Steer CAMR:IN20:186');
util_appPrintLog(3,'Iris Steer',data4.name,data4.ts);
util_dataSave(data4,'ProfMon',data4.name,data4.ts);


% --- Executes on button press in pushbutton27. Opens FB loop
function pushbutton27_Callback(hObject, eventdata, handles)
lcaPut('LASR:LR20:110:POS_FDBK',0);
lockfb = lcaGet('LASR:LR20:110:POS_FDBK');
TF = strcmp('Close Loop',lockfb);
if TF == 1
    zz = 'Loop Closed';
else
    zz = 'Loop Open';
end
fb = findobj(gcf,'Tag','zz');
set(fb,'String',zz);

% --- Executes on button press in pushbutton28. Closes FB loop
function pushbutton28_Callback(hObject, eventdata, handles)
lcaPut('LASR:LR20:110:POS_FDBK',1);
lockfb = lcaGet('LASR:LR20:110:POS_FDBK');
TF = strcmp('Close Loop',lockfb);
if TF == 1
    zz = 'Loop Closed';
else
    zz = 'Loop Open';
end
fb = findobj(gcf,'Tag','zz');
set(fb,'String',zz);


% --- Executes on button press in pushbutton29. %locks C1
function pushbutton29_Callback(hObject, eventdata, handles)
lcaput LASR:LR20:110:SET_REF 1



% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
global backIRIS backVCC
backIRIS = profmon_grab('CAMR:LR20:119');
backVCC = profmon_grab('CAMR:IN20:186');



% --- Executes on button press in checkbox5.

function checkbox5_Callback(hObject, eventdata, handles)
handles.useBG=get(hObject,'Value');
guidata(hObject,handles);
%plot_image(hObject,handles);


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
global data1 data2
data1=profmon_grab('CAMR:LR20:119');
data2= profmon_imgCrop(data1, [handles.xlc handles.xrc handles.ybc handles.ytc]);
profmon_imgPlot(data2, 'bits', handles.bitciris);
util_appPrintLog(2,'Iris Steer',data2.name,data2.ts,2);
util_dataSave(data2,'ProfMon',data2.name,data2.ts);
% hObject    handle to pushbutton34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton34.
function pushbutton35_Callback(hObject, eventdata, handles)
global data3 data4
data3=profmon_grab('CAMR:IN20:186');
data4 = profmon_imgCrop(data3, [handles.xlv handles.xrv handles.ybv handles.ytv]);
profmon_imgPlot(data4, 'figure', 3, 'bits', handles.bitvcc);
util_appPrintLog(3,'Iris Steer',data4.name,data4.ts,2);
util_dataSave(data4,'ProfMon',data4.name,data4.ts);


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
handles.steer = get(hObject, 'Value');
guidata(hObject,handles)

% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
if handles.steer == 0
    handles.xlv = handles.xlv +10;
    handles.xrv = handles.xrv +10;
else
    handles.xlc = handles.xlc +10;
    handles.xrc = handles.xrc +10;
end
guidata(hObject,handles)

% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
if handles.steer == 0
    handles.xlv = handles.xlv -10;
    handles.xrv = handles.xrv -10;
else
    handles.xlc = handles.xlc -10;
    handles.xrc = handles.xrc -10; 
end
guidata(hObject,handles)

% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
if handles.steer == 0
    handles.ytv = handles.ytv +10;
    handles.ybv = handles.ybv +10;
else
    handles.ytc = handles.ytc +10;
    handles.ybc = handles.ybc +10; 
end
guidata(hObject,handles);


% --- Executes on button press in pushbutton40.
function pushbutton40_Callback(hObject, eventdata, handles)
if handles.steer == 0
    handles.ytv = handles.ytv -10;
    handles.ybv = handles.ybv -10;
else
    handles.ytc = handles.ytc -10;
    handles.ybc = handles.ybc -10; 
end
guidata(hObject,handles)



function stepSizeval_Callback(hObject, eventdata, handles)
handles.stepSizeval = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function stepSizeval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
