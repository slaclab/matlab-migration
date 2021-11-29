function varargout = profmon_multi_gui(varargin)
% PROFMON_MULTI_GUI M-file for profmon_multi_gui.fig
%      PROFMON_MULTI_GUI, by itself, creates a new PROFMON_MULTI_GUI or raises the existing
%      singleton*.
%
%      H = PROFMON_MULTI_GUI returns the handle to a new PROFMON_MULTI_GUI or the handle to
%      the existing singleton*.
%
%      PROFMON_MULTI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROFMON_MULTI_GUI.M with the given input arguments.
%
%      PROFMON_MULTI_GUI('Property','Value',...) creates a new PROFMON_MULTI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before profmon_multi_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to profmon_multi_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help profmon_multi_gui

% Last Modified by GUIDE v2.5 18-Nov-2008 10:26:57

% -----------------------------------------------------------------
% Mod: 
%       5-Apr-2017, Sonya Hoobler, permanently removed PR55 and
%                   PR45 (were previously just commented out)
%       9/9/16 Greg White: Removed Pr45 PR55 from BSY in preparation 
%                         for LCLS-2.
% =================================================================

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @profmon_multi_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @profmon_multi_gui_OutputFcn, ...
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


% --- Executes just before profmon_multi_gui is made visible.
function profmon_multi_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to profmon_multi_gui (see VARARGIN)

% Choose default command line output for profmon_multi_gui
handles.output = hObject;

util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);

[sys,accelerator]=getSystem;
handles.accelerator=accelerator;
if strcmp(accelerator,'NLCTA')
    handles.PVList=strcat({ ...
        '13PS10' '13PS4' '13PS2' '13PS9' '13PS5' '13PS11' '13PS12' ...
        '13PS1' '13PS8' '13PS7' '13PS6' ... %NLCTA
        },':cam1');
    handles.PVId=[1 1 1];
elseif strcmp(accelerator,'XTA')
    handles.PVList={ ...
        'YAGS:XT01:150' ...
        'OTR:XT01:250' ...
        'OTR:XT01:350' ...
        'YAGS:XT01:550' ...
        'YAGS:XT01:950' ...
        'ILL:XT01:1' ...
        'VIS:XT01:10' ...
        'VIS:XT01:26' ...
        'VCC:XT01:49' ...
        };
    handles.PVId=[1 1 1];
elseif strcmp(accelerator,'ASTA')
    handles.PVList={ ...
        'VCC:AS01:186' ...
        'VIS:AS01:2' ...
        'YAGS:AS01:3' ...
        };
    handles.PVId=[1 1 1];
elseif strcmp(accelerator,'FACET')
    handles.PVList={ ...
        'CAMR:LT10:200' ... % 
        'CAMR:LT10:380' ... % 
        'CAMR:LT10:450' ... % 
        'CAMR:LT10:500' ...
        'CAMR:LT10:600' ...
        'CAMR:LT10:700' ...
        'CAMR:LT10:800' ...
        'CAMR:LT10:900' ... % 
        'CTHD:IN10:111' ... %
        'PROF:IN10:241' ... %
        'PROF:LI11:335' ... %
        'PROF:LI11:375' ... %
        'PROF:LI14:803' ... %
        'PROF:LI15:944' ... %
        'CAMR:LI20:100' ...
        'CAMR:LI20:101' ...
        'CAMR:LI20:102' ...
        'CAMR:LI20:103' ...
        'CAMR:LI20:104' ...
        'CAMR:LI20:105' ...
        'CAMR:LI20:106' ...
        'CAMR:LI20:107' ...
        'CAMR:LI20:108' ...
        'PROF:LI20:10' ...
        'PROF:LI20:12' ...
        'PROF:LI20:B100' ...
        'PROF:LI20:B101' ...
        'PROF:LI20:B102' ...
        'PROF:LI20:B103' ...
        'PROF:LI20:B104' ...
        'PROF:LI20:B200' ...
        'PROF:LI20:B201' ...
        'PROF:LI20:B202' ...
        'PROF:LI20:B203' ...
        'PROF:LI20:B204' ...        
        'CMOS:LI20:3490' ...
        'CMOS:LI20:3491' ...
        'CMOS:LI20:3492' ...
        'CMOS:LI20:3493' ...
        'CMOS:LI20:3494' ...
        };
    handles.PVId=[1 1 1];
elseif strcmp(accelerator,'SPEAR')
    handles.PVList={ ...
        'LTB-B1-CAM' ...
        };
    handles.PVId=[1 1 1];
else
    handles.PVList={ ...
        'CAMR:LR20:90'   'CAMR:LR20:100'  'CAMR:LR20:135'  'CAMR:IN20:186' ...
        'CAMR:LR20:285'  'CAMR:LR20:287'  'CAMR:LR20:295'  'CAMR:LR20:297' ...  
        'CAMR:LR20:320'  'CAMR:IN20:423'  'CAMR:IN20:461'  'CAMR:IN20:469' ...
        'CTHD:IN20:206'  'YAGS:IN20:211'  'YAGS:IN20:841'  'YAGS:IN20:241' ...
        'YAGS:IN20:351'  'OTRS:IN20:465'  'OTRS:IN20:471'  'OTRS:IN20:541' ...
        'OTRS:IN20:571'  'OTRS:IN20:621'  'OTRS:IN20:711'  'YAGS:IN20:921' ...
        'YAGS:IN20:995'  'OTRS:LI21:237'  'OTRS:LI21:291'  'OTRS:LI24:807' ...
        'OTRS:LI25:342'  'OTRS:LI25:920'  ...
        'PROF:BSYA:1800' ...
        'OTRS:LTU1:449'  'YAGS:LTU1:743'  ...
        'PROF:UND1:960'  'YAGS:UND1:1005' 'YAGS:UND1:1305' 'YAGS:UND1:1650' ...
        'PROF:DMP1:731'  'YAGS:DMP1:498'  'YAGS:DMP1:500'  'OTRS:DMP1:695'  ...
        'CAMR:FEE1:441'  'CAMR:FEE1:441:IMAGE_CMPX' ...
        'CAMR:FEE1:455'  'DIAG:FEE1:481'  'DIAG:FEE1:482' ...
        'CAMR:FEE1:852'  'CAMR:FEE1:913'  'CAMR:FEE1:1561' 'CAMR:FEE1:1692' ...
        'CAMR:FEE1:1953' 'CAMR:FEE1:2953' ...
        'CAMR:NEH1:124'  'CAMR:NEH1:195'  'CAMR:NEH1:1124' 'CAMR:NEH1:2124' ...
        'HXX:UM6:CVP:01' ...
        'AMO:SAS:CVV:01' 'AMO:DIA:CVV:02' 'SXR:YAG:CVV:01' 'HXX:UM6:CVV:01' ...
        'HXX:HXM:CVV:01' 'HFX:DG2:CVV:01' 'HFX:DG3:CVV:01' 'XCS:DG3:CVV:02' ...
        'MEC:HXM:CVV:01' ...
        'SXR:EXS:CVV:01' 'SXR:EXS:CVV:01:IMAGE_CMPX' ...
        'XPP:OPAL1K:1'   'XPP:OPAL1K:1:IMAGE_CMPX' ...
        'MEC:OPAL1K:1'   'MEC:OPAL1K:1:IMAGE_CMPX' ...
        'CXI:EXS'        'CAMR:B34:100' ...
        };
    handles.PVId=[3 4 12];
end

handles.PV=handles.PVList(handles.PVId);
handles.nPV=numel(handles.PVId);
for j=1:handles.nPV
    str=num2str(j);if j == 1, str='';end
    handles=bitsControl(hObject,handles,8,j);
    set(handles.(['device' str '_pmu']),'String', ...
        [{'none'} model_nameConvert(handles.PVList,'MAD')],'Value',handles.PVId(j)+1);
end
handles.zoom=0;
handles.bufd=1;
handles.posOld=get(hObject,'Position');

set(hObject,'Color','k');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes profmon_multi_gui wait for user response (see UIRESUME)
% uiwait(handles.profmon_multi_gui);


% --- Outputs from this function are returned to the command line.
function varargout = profmon_multi_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close profmon_multi_gui.
function profmon_multi_gui_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% --- Executes on selection change in device_pmu.
function device_pmu_Callback(hObject, eventdata, handles, val)

handles.PVId(val)=get(hObject,'Value')-1;
if handles.PVId(val), handles.PV{val}=handles.PVList{handles.PVId(val)};end
guidata(hObject,handles);
if handles.PVId(val), profmon_evrSet(handles.PV{val});end


% -----------------------------------------------------------
function handles = plot_image(hObject, handles)

if ~isfield(handles,'data'), return, end
for j=1:handles.nPV
    str='';if j > 1, str=num2str(j);end
    ax=handles.(['axes' str]);
    if ~handles.PVId(j) || numel(handles.data) < j || isempty(handles.data{j}.name), cla(ax,'reset');set(ax,'Box','on');continue, end

    data=handles.data{j};
    profmon_imgPlot(data,'axes',ax,'cal',1,'aspect',1, ...
        'scale',~handles.zoom,'tag',1-.5*(now-data.ts > 1e-4), ...
        'title',['%s ' datestr(data.ts)],'bits',handles.bits.jVal(j));
end


% -----------------------------------------------------------
function handles = grab_image(hObject, handles)

[d,is]=profmon_names(handles.PV);

nImg=[];
for j=1:handles.nPV
    if ~handles.PVId(j), continue, end

    % Return if FACET camera is in data acquisition mode.
    if is.FACET(j) && ~is.AreaDet(j) && lcaGetSmart(strcat(handles.PV(j),':TRIGGER_DAQ'),0,'double'), continue, end

    if handles.bufd && is.Bufd(j)
        nImg=0;
        lcaPutSmart([handles.PV{j} ':SAVE_IMG'],1);
    end
    try
        handles.data{j}=profmon_grab(handles.PV{j},0,nImg);
    catch
    end
end
guidata(hObject,handles);
plot_image(hObject,handles);


% ------------------------------------------------------------------------
function handles = bitsControl(hObject, handles, val, num)

handles=gui_sliderControl(hObject,handles,'bits',val,16,1,num);
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

bitsControl(hObject,handles,round(get(hObject,'Value')),num);


% --- Executes on button press in zoom_box.
function zoom_box_Callback(hObject, eventdata, handles)

zoomControl(hObject,handles,get(hObject,'Value'));


% --- Executes when profmon_multi_gui is resized.
function profmon_multi_gui_ResizeFcn(hObject, eventdata, handles)

if isempty(handles), return, end
pos=get(hObject,'Position');
nRow=max(1,round((pos(4)-4)/26));
nCol=max(1,round((pos(3)-6)/66));
pos0=[6 4]+[nCol*66 nRow*26];
set(hObject,'Position',[pos(1:2)+[0 pos(4)-pos0(2)] pos0]);
handles.posOld=get(hObject,'Position');
guidata(hObject,handles);
handles=newObjects(hObject,handles,nRow*nCol);
placeObjects(hObject,handles,nRow);


function placeObjects(hObject, handles, nRow)

for j=1:handles.nPV
    iRow=mod(j-1,nRow)+1;
    iCol=floor((j-1)/nRow)+1;
    str='';if j > 1, str=num2str(j);end
    hh=[handles.(['axes' str]) handles.(['bits' str '_sl']) handles.(['bits' str '_txt']) ...
        handles.(['bits' str 'Label_txt']) handles.(['device' str '_pmu'])];
%    hh=[handles.(['axes' str]) handles.(['bits' str '_sl']) ...
%        handles.(['device' str '_pmu'])];
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
