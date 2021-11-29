function varargout = laser_cathodeAlign(varargin)
% LASER_CATHODEALIGN M-file for laser_cathodeAlign.fig
%      LASER_CATHODEALIGN, by itself, creates a new LASER_CATHODEALIGN or raises the existing
%      singleton*.
%
%      H = LASER_CATHODEALIGN returns the handle to a new LASER_CATHODEALIGN or the handle to
%      the existing singleton*.
%
%      LASER_CATHODEALIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASER_CATHODEALIGN.M with the given input arguments.
%
%      LASER_CATHODEALIGN('Property','Value',...) creates a new LASER_CATHODEALIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before laser_cathodeAlign_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to laser_cathodeAlign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help laser_cathodeAlign

% Last Modified by GUIDE v2.5 24-Nov-2008 09:53:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @laser_cathodeAlign_OpeningFcn, ...
                   'gui_OutputFcn',  @laser_cathodeAlign_OutputFcn, ...
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


% --- Executes just before laser_cathodeAlign is made visible.
function laser_cathodeAlign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to laser_cathodeAlign (see VARARGIN)

% Choose default command line output for laser_cathodeAlign
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes laser_cathodeAlign wait for user response (see UIRESUME)
% uiwait(handles.laser_cathodeAlign);


% --- Outputs from this function are returned to the command line.
function varargout = laser_cathodeAlign_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close laser_cathodeAlign.
function laser_cathodeAlign_CloseRequestFcn(hObject, eventdata, handles)

gui_BSAControl(hObject,handles,0);
util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of fields for config file
handles.configList={'ctrlPVValNum' 'ctrlPVRange' 'acquireSampleNum' 'respMat'};

handles.ctrlPVName='SOLN:IN20:121:BACT';
handles.solName='SOLN:IN20:121';
handles.ctrlPVRange={0.39 0.46};
handles.ctrlPVValNum=7;
handles.readPVNameList=[strcat('BPMS:IN20:221:',{'X' 'Y'}'); ...
                        strcat('BPMS:IN20:235:',{'X' 'Y'}')];
handles.acquireBSA=0;
handles.acquireSampleNum=5;
handles.process.displayExport=0;
handles.respMat=[7.1 -17.8;18.6 3.6];
%handles.posPVList=strcat('CAMR:IN20:186:CTRD_',{'H' 'V'}','_BOOK');
handles.posPVList=strcat('VCTD:IN20:186:VCC_POS_',{'X' 'Y'}');
handles.slope=NaN(size(handles.readPVNameList));
handles.calRange={-2 2;-2 2};
handles.measured=0;
%handles.laserOffset=[0 0]';
handles.laserOffsetPVList=strcat('SIOC:SYS0:ML00:AO',{'328' '329'}');
set([handles.offsetXPV_txt handles.offsetYPV_txt],{'String'},handles.laserOffsetPVList);
set(handles.status_txt,'String','');

guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=appSetup(hObject,handles);
handles=gui_appLoad(hObject,handles);


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles=ctrlPVControl(hObject,handles);
handles=acquireSampleNumControl(hObject,handles,[]);
handles=gui_BSAControl(hObject,handles,[]);
handles.posPV=util_readPV(handles.posPVList,1);
handles=posPVControl(hObject,handles);
handles=laserOffsetControl(hObject,handles,1:2,[]);
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireReset(hObject, handles)

if isfield(handles,'data')
    handles=rmfield(handles,'data');
end
handles.data.status=zeros(handles.acquireCurrent.nVal,1);
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = ctrlPVControl(hObject, handles)

handles.ctrlPV=util_readPV(handles.ctrlPVName,1);
handles=ctrlPVRangeControl(hObject,handles,1:2,[]);
set([handles.solVal_txt handles.solInit_txt],'String',num2str(handles.ctrlPV.val,'%5.5g'));
set(handles.solRangeEgu_txt,'String',handles.ctrlPV.egu);
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = ctrlPVValNumControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'ctrlPVValNum',val,1,1,[0 1]);
handles.ctrlPVValList=linspace(handles.ctrlPVRange{:}, ...
    handles.ctrlPVValNum);
handles.acquireCurrent.nVal=handles.ctrlPVValNum;
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = ctrlPVRangeControl(hObject, handles, tag, val)

handles=gui_rangeControl(hObject,handles,'ctrlPVRange',tag,val);
handles=ctrlPVValNumControl(hObject,handles,[]);


% ------------------------------------------------------------------------
function handles = posPVControl(hObject, handles)

% Calculate new paser position.
handles.posPV=util_readPV(handles.posPVList,1);
posD=lscov(handles.respMat,handles.slope(1:size(handles.respMat,1)));
if ~handles.measured, posD=0;end
handles.posNew=[handles.posPV.val]'-posD;
guidata(hObject,handles);

% Update values and display.
set(handles.laserXInit_txt,'String',sprintf('%6.3f',handles.posPV(1).val));
set(handles.laserYInit_txt,'String',sprintf('%6.3f',handles.posPV(2).val));
set(handles.laserX_txt,'String',sprintf('%6.3f',handles.posNew(1)));
set(handles.laserY_txt,'String',sprintf('%6.3f',handles.posNew(2)));
set(handles.xSlope_txt,'String',sprintf('%6.3f %6.3f',handles.slope([1 3])));
set(handles.ySlope_txt,'String',sprintf('%6.3f %6.3f',handles.slope([2 4])));
set([handles.laserXInitEgu_txt handles.laserXEgu_txt handles.laserXOffsetEgu_txt],'String',handles.posPV(1).egu);
set([handles.laserYInitEgu_txt handles.laserYEgu_txt handles.laserYOffsetEgu_txt],'String',handles.posPV(2).egu);


% ------------------------------------------------------------------------
function handles = posPVSet(hObject, handles, val)

if isempty(val)
    val=handles.posNew;
end

if ~any(isnan(val)) && handles.measured
    lcaPutSmart(handles.posPVList,val(:));
end
handles.measured=0;
guidata(hObject,handles);
handles=posPVControl(hObject,handles);
handles=laserOffsetControl(hObject,handles,1:2,[]);


% ------------------------------------------------------------------------
function handles = laserOffsetControl(hObject, handles, tag, val)

isMove=~isempty(val);
if isempty(val)
    val=lcaGetSmart(handles.laserOffsetPVList);
    handles.laserPos0=[handles.posPV.val]'-val;
else
    btn=questdlg('Do you want to move the laser to a new position on the cathode?','Change Laser Position');
    if strcmp(btn,'Cancel'), val=[];end
end
handles=gui_editControl(hObject,handles,'laserOffset',val,tag);
lcaPutSmart(handles.laserOffsetPVList,handles.laserOffset(:));
if isMove
    handles.measured=strcmp(btn,'Yes');
    handles=posPVSet(hObject,handles,handles.laserPos0+handles.laserOffset(:));
end


% ------------------------------------------------------------------------
function handles = acquireSampleNumControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'acquireSampleNum',val,1,1,[0 1]);
handles.acquireSample.nVal=handles.acquireSampleNum;
%handles=acquireCurrentSampleControl(hObject,handles,1);
guidata(hObject,handles);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireCurrentValControl(hObject, handles, val)

if isempty(val)
    val=handles.acquireCurrent.iVal;
end
handles.acquireCurrent.iVal=val;
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = ctrlPVSet(hObject, handles)

guidata(hObject,handles);
pv=handles.solName;
val=handles.ctrlPVValList(handles.acquireCurrent.iVal);
val=control_magnetSet(pv,val);
set(handles.solVal_txt,'String',num2str(val,'%5.5g'));
handles=guidata(hObject);


% ------------------------------------------------------------------------
function handles = ctrlPVReset(hObject, handles)

guidata(hObject,handles);
pv=handles.solName;
val=handles.ctrlPV.val;
val=control_magnetSet(pv,val);
set(handles.solVal_txt,'String',num2str(val,'%5.5g'));
handles=guidata(hObject);


% ------------------------------------------------------------------------
function handles = acquireCurrentGet(hObject, handles)

iVal=handles.acquireCurrent.iVal;
str=sprintf('Data point #%d setting %s to %6.3f %s',iVal,handles.solName, ...
    handles.ctrlPVValList(iVal),handles.ctrlPV.egu);
gui_statusDisp(handles,str);
handles=ctrlPVSet(hObject,handles);

handles.data.ctrlPV(iVal)=util_readPV(handles.ctrlPVName,1);

% Do beam synchronous acquisition
if handles.acquireBSA
    if ~ispc
        eDefParams(handles.eDefNumber,1,handles.acquireSample.nVal);
        eDefOn(handles.eDefNumber);
        gui_statusDisp(handles,'Waiting for eDef completion');
        drawnow;
        while ~eDefDone(handles.eDefNumber), end
        gui_statusDisp(handles,'eDef completed');
        drawnow;
    end
    gui_statusDisp(handles,'Getting Synchronous Data');
    drawnow;
    [readPV,pulseId]=util_readPVHst(handles.readPVNameList,handles.eDefNumber,1);
    gui_statusDisp(handles,'Done Data Acquisition');
    handles.data.readPV(:,iVal,:)=repmat(readPV,1,handles.acquireSample.nVal);
%    valList=num2cell(vertcat(readPV.val));
%    [handles.data.readPV(:,iVal,:).val]=deal(valList{:});
    for j=1:handles.acquireSample.nVal
        for k=1:size(handles.data.readPV,1)
            handles.data.readPV(k,iVal,j).val=readPV(k).val(min(j,end));
        end
    end
else
    for l=1:handles.acquireSample.nVal
        gui_statusDisp(handles,sprintf('Getting Sample #%d',l));
        handles.data.readPV(:,iVal,l)=util_readPV(handles.readPVNameList,1);
        guidata(hObject,handles);
        pause(.1);
        handles=guidata(hObject);
    end
end
gui_statusDisp(handles,'Done Data Acquisition');
handles.data.status(iVal)=1;
handles=acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Test if laser position feedback is running.
if ~lcaGet('LASR:IN20:160:POS_FDBK',0,'double')
    warndlg({'The laser position feedback (FdBk Loop2)' 'needs to be turned on'},'Laser Position FB');
    return
end

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end

% Select 10 Hz.
oldRate = lcaGet('IOC:IN20:EV01:RG02_DESRATE');
lcaPut('IOC:IN20:EV01:RG02_DESRATE','HXR 10 / SXR 00');
handles=ctrlPVControl(hObject,handles);
handles=gui_BSAControl(hObject,handles,1);
savePV=[strcat({'YAGS:IN20:211' 'YAGS:IN20:241'}',':PNEUMATIC'); ...
    strcat({'XCOR:IN20:121' 'YCOR:IN20:122'}',':BCTRL')];
target=lcaGet(savePV,0,'double');
lcaPut(savePV,[0 1 0 0]');
saveLaser=lcaGet(handles.posPVList);
lcaPutSmart(handles.posPVList,saveLaser-handles.laserOffset(:));
pause(7.);
handles.measured=1;
for j=1:handles.acquireCurrent.nVal
    handles=acquireCurrentValControl(hObject,handles,j);
    handles=acquireCurrentGet(hObject,handles);
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
handles=ctrlPVReset(hObject,handles);

% Restore full beam rate.
lcaPut('IOC:IN20:EV01:RG02_DESRATE', oldRate);

lcaPutSmart(handles.posPVList,saveLaser);
pause(5.);
lcaPut(savePV,target);
handles=gui_BSAControl(hObject,handles,0);
gui_acquireStatusSet(hObject,handles,0);
handles=acquireUpdate(hObject,handles);
gui_statusDisp(handles,'Done Measurement');


% ------------------------------------------------------------------------
function handles = acquireCalib(hObject, handles)

target=lcaGet(strcat({'YAGS:IN20:211' 'YAGS:IN20:241'}',':PNEUMATIC'));
lcaPut(strcat({'YAGS:IN20:211' 'YAGS:IN20:241'}',':PNEUMATIC'),[0 1]');
pause(1.);
posListX=linspace(handles.calRange{1,:},3)+handles.posPV(1).val;
posListY=linspace(handles.calRange{2,:},3)+handles.posPV(2).val;
posList=[posListX([2 1 3 2 2]);posListY([2 2 2 1 3])];
for j=1:size(posList,2)
    gui_statusDisp(handles,sprintf('Calibrating ... setting position #%d',j));
    posPVSet(hObject,handles,posList(:,j));
    pause(2.);
    handles=guidata(hObject);
    handles=acquireStart(hObject,handles);
    slope(:,j)=handles.slope;
    slopeD(:,j)=slope(:,j)-slope(:,1);
    posListD(:,j)=posList(:,j)-posList(:,1);
    if ~gui_acquireStatusGet(hObject,handles), break, end
end
handles.respMat=lscov(posListD',slopeD')';
guidata(hObject,handles);
posPVSet(hObject,handles,posList(:,1));
lcaPut(strcat({'YAGS:IN20:211' 'YAGS:IN20:241'}',':PNEUMATIC'),target);
disp(handles.respMat);
gui_acquireStatusSet(hObject,handles,0);
gui_statusDisp(handles,'Done Calibrating');


% ------------------------------------------------------------------------
function handles = acquireUpdate(hObject, handles)

guidata(hObject,handles);
data=handles.data;
if ~all(data.status), handles=acquirePlot(hObject,handles);return, end
if handles.process.displayExport
    handles.exportFig=figure;
end
handles=acquirePlot(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = acquirePlot(hObject, handles)

if ~any(handles.data.status)
    return
end

ax=handles.plot_ax;
if handles.process.displayExport
    ax=gca;
end

% Generate PV list.
readPV=handles.data.readPV;

% Get mean and std from data after filtering NaNs.
meanVals = []
stdVals = []
for i=1:size(readPV, 1)
    for j=1:size(readPV, 2)
        samples = [readPV(i,j,:).val]
        samples = samples(~isnan(samples))
        meanVals(i,j) = mean(samples)
        stdVals(i,j) = std(samples, 1)
    end
end


readPVVal=reshape([readPV.val],size(readPV,1),size(readPV,2),[]);

yPV=readPV;
yPVVal=readPVVal;
yPVValMean=meanVals;
yPVValStd=stdVals;
% Generate x PV.
xPV=handles.data.ctrlPV;
xPVValMean=[handles.data.ctrlPV.val];

% Fit functions.
xFit=linspace(min(xPVValMean),max(xPVValMean),100);
for j=1:size(yPV,1)
    par=polyfit(xPVValMean,yPVValMean(j,:),min(1,length(xPVValMean)-1));
    handles.slope(j,1)=par(1);
    yFit(j,:)=polyval(par,xFit);
%    ex=length(par)-1:-1:0;
%    strFit=['y = ' sprintf('%+g x^%d ',[par;ex])];
end

% Display new laser position.
handles=posPVControl(hObject,handles);

% Plot results.
errorbar(repmat(xPVValMean,size(yPV,1),1)',yPVValMean',yPVValStd','*','Parent',ax);
hold(ax,'on');
plot(xFit,yFit,'Parent',ax);
hold(ax,'off');

xlabel(ax,[strrep(xPV(1).name,'_','\_') ' ' xPV(1).desc ' (' xPV(1).egu ')']);
ylabel(ax,[strrep(yPV(1).name,'_','\_') ' ' yPV(1).desc ' (' yPV(1).egu ')']);
title(ax,strrep(['Solenoid Scan ' datestr(yPV(1).ts)],'_','\_'));
legend(ax,strrep({yPV(:,1).name},'_','\_'));
legend(ax,'boxoff');

if handles.process.displayExport
    strFit={'             BPM2  BPM3' ...
            sprintf('x Slope: %6.3f %6.3f',handles.slope([1 3])) ...
            sprintf('y Slope: %6.3f %6.3f',handles.slope([2 4]))};
    text(.15,.8,strFit,'VerticalAlignment','top','units','normalized');
end


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

if ~val
    handles.process.displayExport=1;
    handles=acquireUpdate(hObject,handles);
    handles.process.displayExport=0;
    guidata(hObject,handles);
end
if val
%    util_printLog(handles.exportFig);
    set(handles.output,'InvertHardcopy','off');
    util_printLog(handles.output);
end


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

data=handles.data;
if ~all(data.status), return, end
fileName=util_dataSave(data,'LaserAlign','',now,val);
if ~ischar(fileName), return, end


% --- Executes on button press in export_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in apply_btn.
function apply_btn_Callback(hObject, eventdata, handles)

posPVSet(hObject,handles,[]);


function ctrlPVRange_txt_Callback(hObject, eventdata, handles, tag)

ctrlPVRangeControl(hObject,handles,tag,str2double(get(hObject,'String')));


% --- Executes on button press in calib_btn.
function calib_btn_Callback(hObject, eventdata, handles)

acquireCalib(hObject,handles);


function ctrlPVValNum_txt_Callback(hObject, eventdata, handles)

ctrlPVValNumControl(hObject,handles,str2double(get(hObject,'String')));


function acquireSampleNum_txt_Callback(hObject, eventdata, handles)

acquireSampleNumControl(hObject,handles,str2double(get(hObject,'String')));


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);


% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

gui_appLoad(hObject,handles);


function laserOffset_txt_Callback(hObject, eventdata, handles, tag)

laserOffsetControl(hObject,handles,tag,str2double(get(hObject,'String')));
