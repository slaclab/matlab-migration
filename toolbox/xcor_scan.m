function varargout = xcor_scan(varargin)
% XCOR_SCAN M-file for xcor_scan.fig
%      XCOR_SCAN, by itself, creates a new XCOR_SCAN or raises the existing
%      singleton*.
%
%      H = XCOR_SCAN returns the handle to a new XCOR_SCAN or the handle to
%      the existing singleton*.
%
%      XCOR_SCAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in XCOR_SCAN.M with the given input arguments.
%
%      XCOR_SCAN('Property','Value',...) creates a new XCOR_SCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before xcor_scan_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to xcor_scan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xcor_scan

% Last Modified by GUIDE v2.5 03-Mar-2010 08:52:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xcor_scan_OpeningFcn, ...
                   'gui_OutputFcn',  @xcor_scan_OutputFcn, ...
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


% --- Executes just before xcor_scan is made visible.
function xcor_scan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to xcor_scan (see VARARGIN)

% Choose default command line output for xcor_scan
handles.output = hObject;
handles=appInit(hObject,handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes xcor_scan wait for user response (see UIRESUME)
% uiwait(handles.xcor_scan);


% --- Outputs from this function are returned to the command line.
function varargout = xcor_scan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close xcor_scan.
function xcor_scan_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function data = appRemote(hObject)

[hObject,handles]=util_appFind('xcor_scan');
%handles.process.saved=1;
%handles=acquireStart(hObject,handles);
scanStart_btn_Callback(hObject,[],handles);
handles=guidata(hObject);
for tag={'posList' 'ampList' 'ampstdList' 'ts'}
    data.(tag{:})=handles.(tag{:});
end
%data=handles.data;
%handles.process.saved=1;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function data = appQuery(hObject)

[hObject,handles]=util_appFind('xcor_scan');
for tag={'posList' 'ampList' 'ampstdList' 'ts'}
    data.(tag{:})=handles.(tag{:});
end
%data=handles.data;


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of index names
handles.indexList={'LCLS' {'LR20'}; ...
%    'FACET' {'LI10' 'LI19'}; ...
    'FACET' {'LT10'}; ...
    'NLCTA' {}; ...
    'ASTA' {'AS01'}; ...
    'LCLSII' {'LR10'}; ...
    };

% List of sector names
%handles.sector.nameList={'DL1' 'BC1' 'BC2' 'DL2'};
%handles.sector.nameList={'BC1' 'DL1' 'BC2' 'DL2' 'BC22' 'DL22'};
%handles.sector.nameList=[handles.sector.indexList{:,2}];

% Device names by sector
handles.sector.LR20.motorPV={'MIRR:LR20:40:XCDL_MOTR' 'MIRR:LR20:30:XCDL_MOTR'};
handles.sector.LT10.motorPV={'MIRR:LT10:130:XCDL_MOTR'};
handles.sector.AS01.motorPV={'MIRR:AS01:40:XCWP'};

handles.sector.LR20.laser={'Coherent1' 'Coherent2'};
handles.sector.LT10.laser={'Coherent1'};
handles.sector.AS01.laser={'ASTA'};

handles.sector.LR20.powerPV={'PMTR:LR20:40:PWR' 'PMTR:LR20:30:PWR'};
handles.sector.LT10.powerPV={'PMTR:LT10:130:PWR'};
handles.sector.AS01.powerPV={'PMTR:AS01:2:PWR_RAW'};

handles.sector.LR20.shuttPV={'SHTR:LR20:40:XCOR_SHUTTER' 'SHTR:LR20:30:XCOR_SHUTTER'};
handles.sector.LT10.shuttPV={''};
handles.sector.AS01.shuttPV={''};

% Initialize GUI control values.
handles.posRbck=6000;
handles.posRange=2500;

% Devices to use and data initialization for each device by sector
for tag=fieldnames(handles.sector)'
    sector=handles.sector.(tag{:});
    if ~isstruct(sector), continue, end
    devList=sector.motorPV;
    num=numel(devList);
    sector.posStart(1:num)=max(0,handles.posRbck-handles.posRange/2);
    sector.posStop(1:num)=min(handles.posRbck+handles.posRange/2,12500);
    sector.posStep(1:num)=50;
    handles.sector.(tag{:})=sector;
end

% Initialize GUI control values.
%handles.posStart=max(0,handles.posRbck-handles.posRange/2);
%handles.posStop=min(handles.posRbck+handles.posRange/2,12500);
%handles.posStep=50;
handles.posAverage=5;
handles.isacquire=0;
handles.unitsLabList={'Position  (\mum)' 'Delay  (\mum)' 'Time  (ps)'; ...
                      'Position  (mm)' 'Delay  (mm)' 'Time  (fs)'};
handles.unitsCalList=[1 2 2/300;1e-3 2e-3 2/.3];
handles.unitsId=1;
handles.centerPlot=0;
handles.device=1;

handles.configList={'posAverage' 'unitsId' 'centerPlot'};
%handles.configList={'posStart' 'posStop' 'posStep' 'posAverage' 'unitsId' 'centerPlot'};
handles.sector.configList={'posStart' 'posStop' 'posStep'};
%handles.sector.configList={};

% Initialize indices (a.k.a. facilities).
handles=gui_indexInit(hObject,handles,'UV X-Correlator');

% Finish initialization.
guidata(hObject,handles);

handles=unitsInit(hObject, handles);
handles=initPlot(hObject, handles);

handles=appSetup(hObject,handles);
handles=gui_appLoad(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=gui_indexControl(hObject,handles,[]);
%handles=deviceControl(hObject,handles,[]);
handles=unitsControl(hObject, handles, []);
handles=centerPlotControl(hObject, handles, []);


% ------------------------------------------------------------------------
function handles = unitsInit(hObject, handles)

handles.unitsCal=handles.unitsCalList(handles.unitsId);
handles.unitsLab=handles.unitsLabList(handles.unitsId);


% ------------------------------------------------------------------------
function handles = unitsControl(hObject, handles, val)

if isempty(val)
    val=handles.unitsId;
end
handles.unitsId=val;
handles=unitsInit(hObject,handles);
set(handles.units_pmu,'Value',val);
scanFit(hObject,handles);


% ------------------------------------------------------------------------
function handles = sectorControl(hObject, handles, name)

[handles,cancd,name]=gui_dataRemove(hObject,handles,name);
handles=gui_radioBtnControl(hObject,handles,'sectorSel',name, ...
    numel(handles.sector.nameList) > 0,'_btn');
if cancd, return, end
handles=deviceControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = deviceControl(hObject, handles, val)

sector=handles.sector.(handles.sectorSel);
handles=gui_popupMenuControl(hObject,handles,'device',val, ...
    sector.motorPV,sector.laser);
[handles.motorPV,handles.name]=deal(handles.device);
handles.deviceId=find(strcmp(sector.motorPV,handles.device));
handles.powerPV=sector.powerPV{handles.deviceId};
handles.shuttPV=sector.shuttPV{handles.deviceId};
if epicsSimul_status, handles.motorPV='';handles.shuttPV='';handles.powerPV='';end

handles.posHome=motorRbck(hObject,handles);
%handles.posStart=max(0,handles.posHome-handles.posRange/2);
%handles.posStop=min(handles.posHome+handles.posRange/2,12500);
handles=scanInit(hObject, handles);


% ------------------------------------------------------------------------
function handles = centerPlotControl(hObject, handles, val)

if isempty(val)
    val=handles.centerPlot;
end
handles.centerPlot=val;
set(handles.center_box,'Value',val);
scanFit(hObject,handles);


% ------------------------------------------------------------------------
function handles = initPlot(hObject, handles)

h=get(handles.scan_ax,'Children');
delete(h);

handles.lineScanData=line(NaN,NaN,'Color','b','Parent',handles.scan_ax,'Marker','.');
handles.lineScanErr=line(NaN,NaN,'Color','b','Parent',handles.scan_ax);
handles.lineScanFit=line(NaN,NaN,'Color','r','Parent',handles.scan_ax);

handles.scanXlab=xlabel(handles.scan_ax,handles.unitsLab);
ylabel(handles.scan_ax,'Signal   (mV)');
set(handles.units_pmu,'String',strrep(handles.unitsLabList,'\mu','u'));

guidata(hObject,handles);


% ------------------------------------------------------------------------
function posRbck = motorRbck(hObject, handles)

posRbck=handles.posRbck;
if ~isempty(handles.motorPV), posRbck=lcaGet([handles.motorPV '.RBV'])*1e3;end
set(handles.posRbck_txt,'String',num2str(posRbck,'%5.0f'));
handles.posRbck=posRbck;


% ------------------------------------------------------------------------
function handles = motorMove(hObject, handles, pos)

if ~isempty(handles.motorPV)
    lcaPutNoWait(handles.motorPV,pos*1e-3); % pos is in um, the PV is in mm.
    lcaGet([handles.motorPV '.MOVN']);pause(.01);
    while lcaGet([handles.motorPV '.MOVN'])
        pos=motorRbck(hObject,handles);pause(.01);
    end
end
handles.posRbck=pos;
motorRbck(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function pwr = powerRead(hObject, eventdata, handles)

pos=str2double(get(handles.posRbck_txt,'String'));
pwr=exp(-(pos-handles.posHome).^2/200^2/2)*(.3+.05*randn);
pwr=pwr+.005*randn+.01;

if ~isempty(handles.powerPV)
%    if lcaNewMonitorValue(handles.powerPV) == -1
%        lcaSetMonitor(handles.powerPV);
%    end
    try lcaNewMonitorValue(handles.powerPV);
    catch
        lcaSetMonitor(handles.powerPV);
    end
    while lcaNewMonitorValue(handles.powerPV) ~= 1, end
    pwr=lcaGet(handles.powerPV);
end


% ------------------------------------------------------------------------
function handles = scanParamsInit(hObject, handles)

sector=handles.sector.(handles.sectorSel);
handles.posStart=sector.posStart(handles.deviceId);
handles.posStop=sector.posStop(handles.deviceId);
if strcmp(get(hObject,'Tag'),'posNstep_txt')
    sector.posStep(handles.deviceId)=(handles.posStop-handles.posStart)/(handles.posNstep-1);
    handles.sector.(handles.sectorSel)=sector;
end
handles.posStep=sector.posStep(handles.deviceId);
handles.posNewList=(handles.posStart:handles.posStep:handles.posStop)';
handles.posNstep=length(handles.posNewList);
handles.posRange=handles.posStop-handles.posStart;
tags=strcat('pos',{'Home' 'Start' 'Stop' 'Step' 'Nstep' 'Average'});
for j=tags
    set(handles.([j{:} '_txt']),'String',num2str(handles.(j{:}),'%5.0f'));
end
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = scanInit(hObject, handles)

handles=scanParamsInit(hObject,handles);
handles.posList=handles.posNewList;
handles.ampList=nan(handles.posNstep,1);
handles.ampstdList=handles.ampList;
handles.fileName='';
handles.ts=now;
handles.saved=0;
guidata(hObject,handles);
scanPlot(hObject,handles);


% ------------------------------------------------------------------------
function scanPlot(hObject, handles)

pos=(handles.posList-mean(handles.posList)*handles.centerPlot)*handles.unitsCal;
set(handles.lineScanFit,'XData',NaN,'YData',NaN);
set(handles.lineScanData,'XData',pos,'YData',handles.ampList*1e3);
xval=[1 1 NaN]'*pos(:)';
yval=[1 1 NaN]'*handles.ampList(:)'+[1 -1 NaN]'*handles.ampstdList(:)';
set(handles.lineScanErr,'XData',xval(:),'YData',yval(:)*1e3);
set(handles.scanXlab,'String',handles.unitsLab);
str={'*' ''};
set(handles.output,'Name',['Scanning X-Corr Control - [' handles.fileName ']' str{handles.saved+1}]);


% ------------------------------------------------------------------------
function handles = scanFit(hObject, handles)

scanPlot(hObject,handles);guidata(hObject,handles);
if any(isnan(handles.ampList)), return, end

[a,b]=hist(handles.ampList,numel(handles.ampList)*2);a(ceil(end/2):end)=0;
[par,yf]=util_gaussFit(b,a,0,0);
if par(2) < min(b)
    [d,idx]=max(a);
    par(2)=b(idx);
end
if par(2) > max(b)
    par(2)=b(1);
end
bg=par(2);
xFit=linspace(handles.posList(1),handles.posList(end),10*length(handles.posList));
[par,yFit]=util_gaussFit(handles.posList,handles.ampList-bg,0,2,[],xFit);
yFit=yFit+bg;
amp=max(handles.ampList)-bg;
yval=interp1(handles.posList,handles.ampList,xFit);
ix=find(yval > amp/2+bg);

handles.dataFWHM=(xFit(max(ix))-xFit(min(ix)));
handles.dataStd=abs(par(3));
handles.dataCenter=par(2);
guidata(hObject,handles);

data=[handles.dataStd handles.dataFWHM handles.dataCenter]*handles.unitsCalList(5);
xFit=(xFit-mean(handles.posList)*handles.centerPlot)*handles.unitsCal;
set(handles.lineScanFit,'XData',xFit,'YData',yFit*1e3);
set(handles.dataStd_txt,'String',sprintf('%5.2f ps',data(1)));
set(handles.dataFWHM_txt,'String',sprintf('%5.2f ps',data(2)));
%set(handles.dataCenter_txt,'String',sprintf('%5.2f ps',data(3)));
set(handles.dataCenter_txt,'String',sprintf('%5.0f um',handles.dataCenter));

if handles.saved, return, end
pv=strcat('SIOC:SYS0:ML00:AO',{'020';'021';'081'});
lcaPut(pv,data(1:3)');
lcaPut(strcat(pv,'.PREC'),2);
lcaPut(strcat(pv,'.EGU'),'ps');
lcaPut(strcat(pv,'.DESC'),strcat({'UV Pulse '},{'Length RMS';'Length FWHM';'Center ABS'}));


% ------------------------------------------------------------------------
function handles = start(hObject, handles)

handles.isacquire=1;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [handles, flag] = checkStop(hObject, handles, wait)

pause(wait);
handles=guidata(hObject);
flag=~handles.isacquire;


% ------------------------------------------------------------------------
function txt_Callback(hObject, eventdata, handles, tag)

val=str2double(get(hObject,'String'));
if ~isnan(val)
    handles.(tag)=val;
    handles.sector.(handles.sectorSel).(tag)(handles.deviceId)=handles.(tag);
end
scanParamsInit(hObject,handles);


% ------------------------------------------------------------------------
function progressBarSet(handles, tag, ratio)

pos=get(handles.([tag '_bck']),'Position');
pos(3)=max(.1,pos(3)*ratio);
set(handles.([tag '_txt']),'Position',pos);


% --- Executes on button press in scanStart_btn.
function scanStart_btn_Callback(hObject, eventdata, handles)

handles=scanInit(hObject,handles);
scanPlot(hObject,handles);
handles=start(hObject,handles);
if ~isempty(handles.shuttPV), lcaPut(handles.shuttPV,1);end

for k=1:handles.posNstep
    handles=motorMove(hObject,handles,handles.posList(k));
    progressBarSet(handles,'posIAverage',0);
    pause(.1);
    handles=guidata(hObject);
    if ~handles.isacquire, break, end
    amp=zeros(1,handles.posAverage);
    for l=1:handles.posAverage
        amp(l)=powerRead(hObject,eventdata,handles);
        progressBarSet(handles,'posIAverage',l/handles.posAverage);
        [handles,flag]=checkStop(hObject,handles,0.01);
        if flag, break, end
    end
    if flag, break, end
    handles.ampList(k)=mean(amp);
    handles.ampstdList(k)=std(amp,1);
    handles.ts=now;
    guidata(hObject,handles);
    scanPlot(hObject,handles);
end
if ~isempty(handles.shuttPV), lcaPut(handles.shuttPV,0);end
handles=motorMove(hObject,handles,handles.posHome);
progressBarSet(handles,'posIAverage',0);
scanFit(hObject,handles);


% --- Executes on button press in scanStop_btn.
function scanStop_btn_Callback(hObject, eventdata, handles)

handles.isacquire=0;
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

if any(isnan(handles.ampList)), return, end

handles.exportFig=figure;
axes;box on
copyobj(get(handles.scan_ax,'Children'),gca);
xlabel(handles.unitsLab);
ylabel('Signal   (mV)');
str=sprintf('\\tau_{STD} = %5.2f ps\n\\tau_{FWHM} = %5.2f ps', ...
            [handles.dataStd handles.dataFWHM]*handles.unitsCalList(5));
text(.15,.8,str,'Units','normalized');
name=handles.sector.(handles.sectorSel).laser{strcmp(handles.sector.(handles.sectorSel).motorPV,handles.device)};
title(['X-Corr Scan ' strrep(name,'_','\_') ' ' datestr(handles.ts)]);
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
if val
    util_appPrintLog(handles.exportFig,'XCorScan',name,handles.ts);
%    util_printLog(handles.exportFig);
    dataSave(hObject,handles,0);
end


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

if any(isnan(handles.ampList)), return, end

for tag={'posList' 'ampList' 'ampstdList' 'ts' 'name'}
    data.(tag{:})=handles.(tag{:});
end
fileName=util_dataSave(data,'XCorScan',data.name,data.ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.saved=1;
guidata(hObject,handles);
scanFit(hObject,handles);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles, val)

[data,fileName,pathName]=util_dataLoad('Open XCor scan');
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.saved=1;

% Put data in handles.
if ~isfield(data,'ts')
    data.ts=datenum(handles.fileName(11:end-4),'yyyy-mm-dd-HHMMSS');
end
for tag=fieldnames(data)'
    handles.(tag{:})=data.(tag{:});
end
handles=scanFit(hObject,handles);
guidata(hObject,handles);
return

[fileName, pathname]=uigetfile('*.txt','Load scan');
if ~ischar(fileName), return, end
handles.fileName=fileName;
data=num2cell(load(fullfile(pathname,fileName)),1);
[handles.posList handles.ampList handles.ampstdList]=deal(data{:});
scanFit(hObject,handles);


% --- Executes on button press in scanAuto_btn.
function scanAuto_btn_Callback(hObject, eventdata, handles)

if any(isnan(handles.ampList)), return, end
sector=handles.sector.(handles.sectorSel);
handles.posHome=round(handles.dataCenter/100)*100;
sector.posStart(handles.deviceId)=round((handles.dataCenter-1.2*handles.dataFWHM)/100)*100;
sector.posStop(handles.deviceId)=round((handles.dataCenter+1.2*handles.dataFWHM)/100)*100;
handles.sector.(handles.sectorSel)=sector;

scanParamsInit(hObject,handles);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in dataSave_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in scanHome_btn.
function scanHome_btn_Callback(hObject, eventdata, handles)

motorMove(hObject, handles, handles.posHome);


% --- Executes on selection change in units_pmu.
function units_pmu_Callback(hObject, eventdata, handles)

unitsControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in center_box.
function center_box_Callback(hObject, eventdata, handles)

centerPlotControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in configLoad_btn.
function configLoad_btn_Callback(hObject, eventdata, handles)

gui_appLoad(hObject,handles);


% --- Executes on button press in configSave_btn.
function configSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);


% --- Executes on selection change in device_pmu.
function device_pmu_Callback(hObject, eventdata, handles)

deviceControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in sectorSel_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag)

sectorControl(hObject,handles,tag);
