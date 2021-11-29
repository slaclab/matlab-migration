function varargout = energyChange_gui(varargin)
% ENERGYCHANGE_GUI M-file for energyChange_gui.fig
%      ENERGYCHANGE_GUI, by itself, creates a new ENERGYCHANGE_GUI or raises the existing
%      singleton*.
%
%      H = ENERGYCHANGE_GUI returns the handle to a new ENERGYCHANGE_GUI or the handle to
%      the existing singleton*.
%
%      ENERGYCHANGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENERGYCHANGE_GUI.M with the given input arguments.
%
%      ENERGYCHANGE_GUI('Property','Value',...) creates a new ENERGYCHANGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before energyChange_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to energyChange_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help energyChange_gui

% Last Modified by GUIDE v2.5 01-Apr-2013 15:20:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @energyChange_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @energyChange_gui_OutputFcn, ...
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


% --- Executes just before energyChange_gui is made visible.
function energyChange_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to energyChange_gui (see VARARGIN)

% Choose default command line output for energyChange_gui
handles.output = hObject;

% [Always auto, wait time, task text]
handles.taskList={ ...
    1 1. 'Insert TD11/TDUND'; ...
    1 .1 'Activate Klystron complement'; ...
    1 .1 'Set energies for LEM & Joe'; ...
    0 .1 'Get magnet config'; ...
    0 .1 'Activate & trim magnets'; ...
    0 .1 'Standardize magnets'; ...
    1 1. 'Retracting TD11, beam to BYKIK'; ...
    1 1. 'Activate feedback'; ...
    1 1. 'Disable BYKIK'; ...
    1 .1 'Fix BSY-LTU orbit'; ...
    1 .1 'Fix UND launch orbit'; ...
    1 1. 'Retract TDUND, set 1Hz in UND'; ...
    1 .1 'Enable UND launch FB'; ...
    1 .1 'Finish'};
handles.sectorSel='L2-L3-BSY';
handles.appMode=2;
handles.appString={'Score' 'Matlab' 'LEM' 'QuickLEM'};
handles.appAuto=[0 1 0 1];
handles.appAutoString={'Do yourself' 'Auto'};
handles.appAutoColor={'green' 'red'};
handles.appFunctionStr={ ...
    'Load' 'Load' 'Collect' 'Collect'; ...
    'magnet config' 'magnet config' 'data' 'data';
    'Activate' 'Activate' 'Scale' 'Scale'};
handles.state=1;
handles.energy=13.64;
handles.useDesign=1;
handles.useDesignAll=0;
handles.isUndMatch=0;
handles.isDmpMatch=0;
handles.isKlysPDES=0;
handles.sectorList={'LI25' 'LI26' 'LI27' 'LI28' 'LI29' 'LI30' 'CLTH' 'BSYH' 'LTU0' 'LTU1' 'DMP1'};
handles.configList={'deviceList'};
handles.beamOffPV='IOC:BSY0:MP01:PCELLCTL';
handles.static=[];
handles.new6x6=1;
handles.useUndBBA=0;
[d,handles.acc]=getSystem;
if strcmp(handles.acc,'FACET'), handles.sectorSel='FACET';end

handles=abort_btn_Callback(hObject,[],handles);
handles=sectorControl(hObject,handles,[]);
handles=appModeControl(hObject,handles,[]);
handles=getKlys(hObject,handles);
handles=energyControl(hObject,handles,[]);
gui_statusDisp(handles,'Ready');
handles=initLEM(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes energyChange_gui wait for user response (see UIRESUME)
% uiwait(handles.energyChange_gui);


% --- Outputs from this function are returned to the command line.
function varargout = energyChange_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close energyChange_gui.
function energyChange_gui_CloseRequestFcn(hObject, eventdata, handles)

gui_BSAControl(hObject,handles,0);
util_appClose(hObject);


% ------------------------------------------------------------------------
function appSave(hObject, handles)

for tag=handles.configList
    config.(tag{:})=handles.(tag{:});
end
util_configSave(sprintf('energyChange_gui_%d',round(handles.energy*1e3)),config);


% ------------------------------------------------------------------------
function [handles, res] = appLoad(hObject, handles, name)

if nargin < 3, name=1;end
[config,ts]=util_configLoad('energyChange_gui',[name '_config.mat']);
if isempty(config)
    gui_statusDisp(handles,'No config found.');
    set(handles.config_txt,'String','');
    res=0;handles=rmfield(handles,handles.configList);
    handles=getKlys(hObject,handles);
    return
end

for tag=handles.configList
    if isfield(config,tag{:})
        handles.(tag{:})=config.(tag{:});
    end
end
guidata(hObject,handles);
set(handles.config_txt,'String',['Config ' datestr(ts,31)]);
gui_statusDisp(handles,'Config found.');
res=1;
%handles=appSetup(hObject,handles);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, val)

%[handles,cancd,val]=gui_dataRemove(hObject,handles,val);
str={'LCLS' 'L0' 'L1' 'L2' 'L3' 'LTU' 'L3-BSY' 'L2-L3-BSY'};
if strcmp(handles.acc,'FACET'), str={'FACET' 'LI02_LI10' 'LI11_LI20'};end
handles=gui_popupMenuControl(hObject,handles,'sectorSel',val,str,str);
handles.region=handles.sectorSel;
if strcmp(handles.sectorSel,'L0-L1-L2-L3-LTU'), handles.region={'L0' 'L1' 'L2' 'L3' 'LTU'};end
if strcmp(handles.sectorSel,'L2-L3-BSY'), handles.region={'L2' 'L3' 'LTU'};end
handles.static=model_energyMagProfile(handles.static,handles.region,'init',1);
%if cancd, return, end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = appModeControl(hObject, handles, val)

appModeLabel={'Use Score' 'Matlab Config' 'Use LEM' 'Use QuickLEM'};
handles=gui_popupMenuControl(hObject,handles,'appMode',val, ...
    appModeLabel,appModeLabel);
handles.appMode=find(strcmp(handles.appMode,appModeLabel));
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = energyControl(hObject, handles, val)

flag=val;
if isempty(val)
    [d,val]=control_magnetGet('BYD1');
end
handles=gui_editControl(hObject,handles,'energy',val,1,1,3);

if ~isempty(flag) && handles.appMode == 2
    handles=dataOpen_btn_Callback(hObject,[],handles);
end


% --- Executes on button press in appMode_pmu.
function appMode_pmu_Callback(hObject, eventdata, handles)

appModeControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in start_btn.
function start_btn_Callback(hObject, eventdata, handles)

set(hObject,'String',num2str(handles.state,'Step %d ...'),'Enable','off');
    auto=handles.appAuto(handles.appMode);
autoStr={' yourself ...' ' in progress ...'};
str=handles.appFunctionStr(:,handles.appMode);
str2=handles.appString{handles.appMode};

handles.taskList{4,3}=[str{1} ' ' str2 ' ' str{2}];
handles.taskList{5,3}=[str{3} ' ' str2 ' magnet config'];
auto2=(auto | handles.taskList{handles.state,1})+1;
gui_statusDisp(handles,[handles.taskList{handles.state,3} autoStr{auto2}]);
switch handles.state
    case 1 % Insert TD11/TDUND
        switch handles.appMode
            case {1 3 4}
                handles=makeEnergy_btn_Callback(hObject,[],handles);
                handles=getMagnets([],handles);
                handles.gainL3New=calcEnergy(handles);
            case 2
                handles=dataOpen_btn_Callback(hObject,[],handles);
                if ~handles.state
                    abort_btn_Callback(hObject,[],handles);
                    return
                end
                handles.gainL3New=handles.deviceList.misc.val(1);
        end
        handles.new6x6=lcaGet('FBCK:FB04:LG01:MODE',0,'double'); % Save new 6x6 feedback
        handles.oldDL2=lcaGet('SIOC:SYS0:ML00:AO296',0,'double'); % Save old BSY/LTU energy feedback
        lcaPut(handles.beamOffPV,0); % optional, block with pockels cell
        lcaPut('DUMP:LI21:305:TD11_PNEU',0);
        lcaPut('DUMP:LTU1:970:TDUND_PNEU',0);
        lcaPut('IOC:BSY0:MP01:BYKIKCTL',0);
        lcaPut('FBCK:FB02:TR01:MODE',0);
        lcaPut('FBCK:L3L0:1:ENABLE',0);
        lcaPut('FBCK:FB02:TR02:MODE',0);
        lcaPut('FBCK:L280:1:ENABLE',0);
        lcaPut('FBCK:FB01:TR05:MODE',0);
        lcaPut('FBCK:BSY0:1:ENABLE',0);
        lcaPut('FBCK:DL20:1:ENABLE',0);
        lcaPut('FBCK:LTU0:1:ENABLE',0);
        lcaPut('FBCK:FB03:TR01:MODE',0);
        lcaPut('FBCK:LTL0:1:ENABLE',0);
        lcaPut('FBCK:FB03:TR04:MODE',0);
        lcaPut('FBCK:UND0:1:ENABLE',0);
        lcaPut('SIOC:SYS0:ML00:AO296',0); % BSY/LTU energy feedback
        lcaPut('FBCK:FB04:LG01:MODE',0); % New 6x6 feedback
    case 2 % Activate Klystron complement
        setKlys(handles);
    case 3 % Set energies for LEM & Joe
        model_energySetPoints(handles.energy,5);
        control_ampSet('L3',handles.gainL3New);
    case 4 % Get magnet config
        switch handles.appMode
            case 3
                if auto, handles=initLEM(handles);handles=collectLEM(handles);end
            case 4
                handles=sectorControl(hObject,handles,'L3-BSY');
                handles.static=model_energyMagProfile(handles.static,handles.region,'doPlot',1);
        end
    case 5 % Activate & trim magnets
        switch handles.appMode
            case 2
                dataOpen_btn_Callback(hObject,[],handles,2);
            case 3
                if auto, scaleLEM(handles);end
            case 4
                handles=energyScale_btn_Callback(hObject,[],handles);
        end
        names=handles.deviceList.magnets.name;
        isTrim=~bitand(max(0,min(ceil(control_magnetGet(names,'HSTA')),2^16-1)),bin2dec('10000010100'));
        names=names(isTrim);
        stat=lcaGetStatus(strcat(model_nameConvert(names),':BACT')) > 1;
        if any(stat)
            disp('Not all magnets trimmed');disp(names(stat));
            if strcmp('Yes',questdlg('Do you want to trim magnets again','Trim Magnets'))
                control_magnetSet(names(stat),[],'action','TRIM');
            end
        end
    case 6 % Standardize magnets
        names=handles.deviceList.magnets.name;
        isTrim=~bitand(max(0,min(ceil(control_magnetGet(names,'HSTA')),2^16-1)),bin2dec('10000010100'));
        control_magnetSet(names(isTrim),[],'action','STDZ');
    case 7 % Retracting TD11, beam to BYKIK
        lcaPut('IOC:BSY0:MP01:UNLATCHALL',1);pause(.5);
        lcaPut('DUMP:LI21:305:TD11_PNEU',1);
        lcaPut(handles.beamOffPV,1); % optional, block with pockels cell
        pau_sync;
    case 8 % Activate feedback
        lcaPut('SIOC:SYS0:ML00:AO296',handles.oldDL2);  % Old BSY/LTU energy feedback
        lcaPut('FBCK:FB04:LG01:MODE',handles.new6x6); % New 6x6 feedback
        lcaPut('FBCK:FB02:TR01:MODE',1);
        lcaPut('FBCK:L3L0:1:ENABLE',1);
        lcaPut('FBCK:FB02:TR02:MODE',1);
        lcaPut('FBCK:L280:1:ENABLE',1);
        lcaPut('FBCK:FB01:TR05:MODE',1);
        lcaPut('FBCK:BSY0:1:ENABLE',1);
        lcaPut('FBCK:DL20:1:ENABLE',1);
    case 9 % Disable BYKIK
%        fixOrbitLoop(hObject,handles,{'BSY' 'LTU0' 'LTU1'},2,0.5,0.01);
        handles=sectorControl(hObject,handles,'L3-BSY');
        handles=showMagnets_btn_Callback(hObject,[],handles);
        lcaPut('IOC:BSY0:MP01:BYKIKCTL',1);
        lcaPut('FBCK:LTU0:1:ENABLE',1);
        lcaPut('FBCK:LTL0:1:ENABLE',1);
        lcaPut('FBCK:FB03:TR01:MODE',1);
    case 10 % Fix BSY-LTU orbit
        handles=fixOrbitLoop(hObject,handles,{'BSY' 'LTU0' 'LTU1'},2,0.5,0.01);
    case 11 % Fix UND launch orbit
        handles=fixOrbitLoop(hObject,handles,'UND_Launch',2,0.5,0);
    case 12 % Retract TDUND, set 1Hz in UND
        lcaPut('IOC:BSY0:MP01:REQBYKIK1HZ',1);
        lcaPut('DUMP:LTU1:970:TDUND_PNEU',1);
    case 13 % Finish
        model_fbUndSetup;
        lcaPut('IOC:BSY0:MP01:REQBYKIK1HZ',0);
        lcaPut('FBCK:UND0:1:ENABLE',1);
        lcaPut('FBCK:FB03:TR04:MODE',1);
end
pause(handles.taskList{handles.state,2});
gui_statusDisp(handles,[handles.taskList{handles.state,3} ' done.']);
skip_btn_Callback(hObject,[],handles);


% --- Executes on button press in skip_btn.
function skip_btn_Callback(hObject, eventdata, handles)

auto=handles.appAuto(handles.appMode);
handles.state=handles.state+1;
if handles.state > size(handles.taskList,1)
    abort_btn_Callback(hObject,[],handles);
else
    set(handles.start_btn,'String',num2str(handles.state,'Step %d'),'Enable','on');
    set(handles.task_txt,'String',handles.taskList{handles.state,3});
    auto2=(auto | handles.taskList{handles.state,1})+1;
    set(handles.user_txt,'String',handles.appAutoString{auto2}, ...
        'BackgroundColor',handles.appAutoColor{auto2});
    guidata(hObject,handles);
end


% --- Executes on button press in abort_btn.
function handles = abort_btn_Callback(hObject, eventdata, handles)

handles.state=1;
set(handles.start_btn,'String','Start','Enable','on');
set(handles.task_txt,'String',handles.taskList{handles.state,3});
set(handles.user_txt,'String','Auto','BackgroundColor','red');
guidata(hObject,handles);


function energy_txt_Callback(hObject, eventdata, handles)

energyControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

handles=energyControl(hObject,handles,[]);
gui_statusDisp(handles,sprintf('Save config for %5.2f GeV ...',handles.energy));

% Klystrons
handles=getKlys(hObject,handles);

% Magnets
handles=getMagnets([],handles);
[d,bDes,d,eDes]=control_magnetGet(handles.deviceList.magnets.name);
if any(isnan(bDes))
    gui_statusDisp(handles,'Error getting all magnet BDES. Config not saved.');
    return
end
handles.deviceList.magnets.bDes=bDes;
handles.deviceList.magnets.eDes=eDes;

% Collimators
names=model_nameConvert({'COLL'},'MAD',{'LTU1'});
%namesL3=model_nameConvert({'COLL'},'MAD',{'LI28' 'LI29' 'LI30'});
%names=[namesL3;strrep(model_nameConvert(namesL3),'6','8');names];
gap=control_magnetGet(names,'GETGAP');
if any(isnan(gap))
    gui_statusDisp(handles,'Error getting all collimator settings. Config not saved.');
    return
end
handles.deviceList.coll.name=names;
handles.deviceList.coll.gap=gap;

% Misc
names={'ACCL:LI25:1:ADES'}; % Use new abstraction layer PV to read L3 amplitude
val=lcaGet(names(:));
handles.deviceList.misc.name=names;
handles.deviceList.misc.val=val;

appSave(hObject,handles);
gui_statusDisp(handles,sprintf('Config for %5.2f GeV saved.',handles.energy));


% --- Executes on button press in dataOpen_btn.
function handles = dataOpen_btn_Callback(hObject, eventdata, handles, val)

if nargin < 4, val =[];end

if isempty(val)
    name=sprintf('energyChange_gui_%d',handles.energy*1e3);
    [handles,res]=appLoad(hObject,handles,name);
    plotKlys(handles);
    if ~res, handles.state=0;end
    return
end

switch val
    case 1 % Klystrons
%        plotKlys(handles);
%        setKlys(handles);
    case 2 % Magnets
        d=handles.deviceList;
        model_energyMagTrim(d.magnets);
%        [name,is,isSLC]=model_nameConvert(d.coll.name);
        try
%            lcaPut(strcat(name(~isSLC),':SETGAP'),d.coll.gap(~isSLC));
%            control_magnetSet(name(isSLC),d.coll.gap(isSLC));
        catch
        end
    case 3 % Misc
%        lcaPut(handles.deviceList.misc.name(:),handles.deviceList.misc.val);
end


% ------------------------------------------------------------------------
function handles = getMagnets(hObject, handles)

% Magnets
names=model_nameConvert({'BEND' 'BTRM' 'KICK' 'QUAD' 'QTRM' 'XCOR' 'YCOR'},'MAD',handles.sectorList);
names(ismember(names,{'B50B1' 'B52AGF' 'XCBSY71' 'YCBSY72'}))=[];
handles.deviceList.magnets.name=names;
if isempty(hObject), return, end


% ------------------------------------------------------------------------
function handles = getKlys(hObject, handles)

names=model_nameConvert({'KLYS'},'MAD',setdiff(handles.sectorList,'DMP1'));
[act,d,d,d,d,enld]=control_klysStatGet(names);
handles.deviceList.klys.name=names;
handles.deviceList.klys.act=act;
handles.deviceList.klys.enld=enld;
if isempty(hObject), return, end
plotKlys(handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function setKlys(handles)

klys=handles.deviceList.klys;
h=getKlys([],handles);
klysPresent=h.deviceList.klys;
use=~bitand(klysPresent.act,4);
if any(bitand(klys.act(~use),1))
    questdlg('Some klystrons used in config are offline now! ','Problem Activating Klystrons');
end
control_klysStatSet(klys.name(use),bitand(klys.act(use),1));


% ------------------------------------------------------------------------
function plotKlys(handles, act)

if nargin < 2
    act=handles.deviceList.klys.act;
end
img=zeros(8*6,3);
bad=bitand(act(:),4) > 0;
on=bitand(act(:),1) > 0;
off=bitand(act(:),2) > 0;
img(bad,1:2)=1;
img(on,2)=1;
img(off,1:3)=1;
img=reshape(img,8,6,3);
image(25:30,1:8,img,'Parent',handles.axes1);
xlabel(handles.axes1,'Sector');
ylabel(handles.axes1,'Klystron #');
title(handles.axes1,'Klystron Complement');
[a,b]=meshgrid(24.5:30.5,.5:8.5);
line(a,b,'Color','k','Parent',handles.axes1);
line(a',b','Color','k','Parent',handles.axes1);
axis(handles.axes1,'equal','tight');
set(handles.axes1,'XTick',25:30,'YTick',1:8,'TickLength',[0 0]);


% --- Executes on button press in makeEnergy_btn.
function handles = makeEnergy_btn_Callback(hObject, eventdata, handles)

% Get present klystron complement
handles=getKlys(hObject,handles);
act=reshape(handles.deviceList.klys.act,8,[]);
%act([4 6],5)=4;act([3],6)=4;act(4,2)=4;

% Useable klystrons in 29,30
good=bitand(act,4) == 0;
use29_30=min(sum(good(:,5:6)));

% Get energy
en=handles.energy;
%dKlys=0.220*ones(size(act));
dKlys=reshape(handles.deviceList.klys.enld*1e-3,8,[]);
dE=en-4.3;
if en < 4.3 || en > 14
    gui_statusDisp(handles,'Energy out of range');
    return
end

% Needed klystrons in 29,30
%use29_30=min(round(interp1([4.3 13.64],[2 8],en,'linear',7)),use29_30);
use29_30=min(7,use29_30);
use2=cumsum(good(:,5:6)) <= use29_30;
%phi=45;
phi=interp1([4.3 13.64],[145 45],en,'linear',45);
dE29_30=sum(sum(use2.*dKlys(:,5:6)))*cosd(phi);

% Needed klyystrons in 25-28
dE25_28=dE-dE29_30;
%use25_28=round(dE25_28/dKlys);

% Set klystrons in 25-28
use1=reshape(cumsum(reshape(good(:,1:4).*dKlys(:,1:4),[],1)) <= dE25_28,8,[]);
%use1=reshape(cumsum(reshape(good(:,1:4),[],1)) <= use25_28,8,[]);
act([use1 use2] & good)=1;act(~[use1 use2] & good)=2;

handles.deviceList.klys.act=act(:);
guidata(hObject,handles);
plotKlys(handles,act);


% --- Executes on button press in activateEnergy_btn.
function activateEnergy_btn_Callback(hObject, eventdata, handles)

setKlys(handles);


% --- Executes on button press in showKlys_btn.
function showKlys_btn_Callback(hObject, eventdata, handles)

getKlys(hObject,handles);
energyControl(hObject,handles,[]);


% --- Executes on button press in activateNewEnergy_btn.
function activateNewEnergy_btn_Callback(hObject, eventdata, handles)

gainL3New=calcEnergy(handles);
control_ampSet('L3',gainL3New);
model_energySetPoints(handles.energy,5);


% ------------------------------------------------------------------------
function gainL3New = calcEnergy(handles)

% Collect LEM data, make sure everything is OK

% Set new LTU energy in LEM PV (done)

% Turn beam off
% Set new klystron complement, set energy in Joe's FB (turn off L3 energy FB)
% (new energy - present energy)/.92+present L3 gain, (done)

% Collect LEM data, scale magnets.

% Turn beam on
% Turn L3 energy FB on

% Collect LEM data, fine tune magnets (scale magnets)

%lcaPut('SIOC:SYS0:ML00:AO296',0);

%[d,presentEn]=control_magnetGet('BYD1');
%gainL3=lcaGet('ACCL:LI25:1:ADES');
%gainL3New=gainL3+(handles.energy-presentEn)/.92*1e3;

energyList=model_energySetPoints;
gainL3New=(handles.energy-energyList(4)-0.1)*1.027*1e3;


% --- Executes on button press in useDesignModel_box.
function useDesignModel_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.useDesign=val;
guidata(hObject,handles);


% --- Executes on button press in useDesignAll_box.
function useDesignAll_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.useDesignAll=val;
guidata(hObject,handles);


% --- Executes on button press in useUndMatch_box.
function useUndMatch_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.isUndMatch=val;
guidata(hObject,handles);


% --- Executes on button press in useKlysPDES_box.
function useKlysPDES_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.isKlysPDES=val;
guidata(hObject,handles);


% --- Executes on button press in useUndBBA_box.
function useUndBBA_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.useUndBBA=val;
guidata(hObject,handles);


% --- Executes on button press in useDmpMatch_box.
function useDmpMatch_box_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.isDmpMatch=val;
guidata(hObject,handles);


% --- Executes on button press in showMagnets_btn.
function handles = showMagnets_btn_Callback(hObject, eventdata, handles)

handles.static=model_energyMagProfile(handles.static,handles.region, ...
    'doPlot',1,'getSCP',handles.isKlysPDES);
guidata(hObject,handles);


% --- Executes on selection change in sectorSel_pmu.
function sectorSel_pmu_Callback(hObject, eventdata, handles)

sectorControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in energyScale_btn.
function handles = energyScale_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles.static.magnet,'bDes'), return, end
handles.staticOld=handles.static;
m=model_energyMagScale(handles.staticOld,[],'undMatch',handles.isUndMatch, ...
    'design',handles.useDesign,'designAll',handles.useDesignAll,'display',1, ...
    'undBBA',handles.useUndBBA,'dmpMatch',handles.isDmpMatch);

if ~strcmp('Yes',questdlg('Do you want to scale magnets','Scale Magnets')), return, end
gui_statusDisp(handles,'Scaling magnets ...');
iok=model_energyMagTrim(m);
if iok
    gui_statusDisp(handles,'Scaling magnets done.');
else
    gui_statusDisp(handles,'Scaling magnets failed.');
end
guidata(hObject,handles);


% --- Executes on button press in energyUndo_btn.
function energyUndo_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles,'staticOld'), return, end
if ~strcmp('Yes',questdlg('Do you want to undo scale magnets','Undo Scale Magnets')), return, end;
gui_statusDisp(handles,'Undo scaling magnets ...');
model_energyMagTrim(handles.staticOld);
gui_statusDisp(handles,'Undo scaling magnets done.');
handles=rmfield(handles,'staticOld');
guidata(hObject,handles);


% --- Executes on button press in energyRun_btn.
function energyRun_btn_Callback(hObject, eventdata, handles)

col='k';if strcmp(handles.acc,'FACET'), col='f';end
while get(hObject,'Value')
    try
        handles.static=model_energyMagProfile(handles.static,handles.region, ...
            'doPlot',1,'color',col,'figure',2,'update',0,'getSCP',handles.isKlysPDES);
    catch
    end
    guidata(hObject,handles);
    pause(.1);
end


% ------------------------------------------------------------------------
function handles = initLEM(handles)

if isempty(getenv('LD_ASSUME_KERNEL')), return, end

handles.appAuto(3)=1;

% include LEM API in the path
%javaclasspath /home/softegr/pchu/workspace/LEM/jar/lemapi_zplot.jar;

% import necessary classes
import javax.swing.JFrame;
import java.util.ArrayList;
import edu.stanford.lcls.xal.tools.lem.*;
import edu.stanford.slac.lem.display.*;

% create a Java JFrame
handles.myFrame=JFrame();


% ------------------------------------------------------------------------
function handles = collectLEM(handles)

if isempty(getenv('LD_ASSUME_KERNEL')), return, end

% import necessary classes
import javax.swing.JFrame;
import java.util.ArrayList;
import edu.stanford.lcls.xal.tools.lem.*;
import edu.stanford.slac.lem.display.*;

% create a LEM display panel
dd=DataDisplay();

% put the LEM display panel into the Java frame
handles.myFrame.add(dd.getDisplay());
handles.myFrame.pack();
handles.myFrame.setVisible(true);

% initialize LEM 
lem=LEM.getInstance('/usr/local/lcls/physics/config/model/main.xal');

% Select regions and magnet groups.  If not specified, default is
% LEM._QM15_TO_BC2 & LEM._BC2_TO_50B1
%
% available regions:
% 'L0' -- GUN_TO_BX02
% 'L1' -- BX02_TO_QM15
% 'L2' -- QM15_TO_BC2
% 'L3' -- BC2_TO_50B1
% 'LTU' -- 50B1_TO_DUMP
% 'GSPEC' -- GUN_SPECT
% 'LSPEC' -- 135_MEV_SPECT
% '52LINE' -- 52_LINE
regions = ArrayList();
regions.add('L3');
regions.add('LTU');
lem.setSelectedRegions(regions);

% Select magnet groups
% available magnet groups:
% LEM.NON_OPT_MAGS
% LEM.XYCORS
% LEM.UND_XYCORS
% LEM.UND_QUADS
magGroups = ArrayList();
magGroups.add(LEM.NON_OPT_MAGS);
magGroups.add(LEM.XYCORS);
lem.setMagnetGroups(magGroups);

% run LEM 'Lite' to get RF/klystron energy profile
lem.init();

% collect LEM data, false means not to write to EACT PVs
lem.collectData(false);

% update the LEM display panel
dd.updateLem(lem);

% refresh the plot
handles.myFrame.repaint();
handles.lem=lem;


% ------------------------------------------------------------------------
function scaleLEM(handles)

if isempty(getenv('LD_ASSUME_KERNEL')), return, end

% scale the magnets
% Note, this will update EDES and BDES PVs.
if ~strcmp('Yes',questdlg('Do you want to scale magnets','Scale Magnets')), return, end;
handles.lem.applyScaleMagnets();

% undo LEM
%handles.lem.undoLEM

handles.myFrame.setVisible(false);


% ------------------------------------------------------------------------
function handles = fixOrbitLoop(hObject, handles, sector, num, gain, svdPar)

global quadOff undOff bpmOff corrB xInit girdPos strayB
glSave={quadOff undOff bpmOff corrB xInit girdPos strayB};

if nargin < 4, num=2;end
if nargin < 5, gain=.5;end
if nargin < 5, svdPar=0.01;end
handles=fixOrbitInit(hObject,handles,sector);
for j=1:num
    [handles,res]=fixOrbit(hObject,handles,gain,svdPar);
    if ~res, break, end
end
[quadOff undOff bpmOff corrB xInit girdPos strayB]=deal(glSave{:});


% ------------------------------------------------------------------------
function handles = fixOrbitInit(hObject, handles, sector)

handles=gui_BSAControl(hObject,handles,1);
handles.simul.sector=sector;
handles.staticBBA=bba_simulInit(handles.simul);
handles.dataSample.nVal=5;

handles.data.R=bba_responseMatGet(handles.staticBBA,1);

handles.bykik=lcaGet('IOC:BSY0:MP01:BYKIKCTL',0,'double');
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [handles, res] = fixOrbit(hObject, handles, gain, svdPar)

if ~epicsSimul_status && ~handles.eDefNumber, res=0;return, end
handles.data.xMeas=bba_bpmDataGet(handles.staticBBA,handles.data.R,1,handles);
handles.data.ts=now;

xMeas=handles.data.xMeas;
xMeasStd=std(xMeas,0,3)/sqrt(size(xMeas,3));
xMeas=mean(xMeas,3);

opts.use=struct('init',0,'quad',0,'BPM',0,'corr',1);
opts.fitSVDRatio=svdPar;
if ~handles.bykik
    isBYK=strcmp(handles.staticBBA.bpmList,'BPMDL2');
    xMeas(:,find(isBYK,1):end)=NaN;
end
f=bba_fitOrbit(handles.staticBBA,handles.data.R,xMeas,xMeasStd,opts);
handles.data.xMeasF=xMeas-f.xMeasF;

opts.figure=3;opts.axes={2 2 2;2 2 4};
bba_plotCorr(handles.staticBBA,-f.corrOff,1,opts);

% Plot results.
opts.title=['BBA Scan Orbit ' datestr(handles.data.ts)];
opts.figure=3;opts.axes={2 2 1;2 2 3};
bba_plotOrbit(handles.staticBBA,xMeas,xMeasStd,handles.data.xMeasF,handles.energy,opts);
guidata(hObject,handles);res=0;

if ~strcmp('Yes',questdlg('Do you want to apply correction?','Scale Magnets')), return, end;
bba_corrSet(handles.staticBBA,-f.corrOff*gain,.75);%pause(1.);

guidata(hObject,handles);res=1;


% --- Executes on button press in snaptable_btn.
function snaptable_btn_Callback(hObject, eventdata, handles)

% Added by S. Alverson
% Calls snaptable.m which dynamically creates a table of snapshot configs
% for the user to select from.  Upon selection, that snapshot will be
% loaded into energyChange_gui.m.

% Get position to create table at
set(gcf,'Units','pixels')
pos = get(gcf,'Position');
set(gcf,'Units','characters')
pos = pos + [ 220 200 0 0 ];

% Open snapshot table and return selected energy value
energy = snaptable(pos);

% If energy value returned, show in energy text field and call
% energyControl function to load snapshot
if ~isempty(energy)
   energyControl(hObject,handles,energy/1000);
end
