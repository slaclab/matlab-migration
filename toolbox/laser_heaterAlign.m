function varargout = laser_heaterAlign(varargin)
% LASER_HEATERALIGN M-file for laser_heaterAlign.fig
%      LASER_HEATERALIGN, by itself, creates a new LASER_HEATERALIGN or raises the existing
%      singleton*.
%
%      H = LASER_HEATERALIGN returns the handle to a new LASER_HEATERALIGN or the handle to
%      the existing singleton*.
%
%      LASER_HEATERALIGN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASER_HEATERALIGN.M with the given input arguments.
%
%      LASER_HEATERALIGN('Property','Value',...) creates a new LASER_HEATERALIGN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before laser_cathodeAlign_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to laser_heaterAlign_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help laser_heaterAlign

% Last Modified by GUIDE v2.5 25-Mar-2011 14:48:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @laser_heaterAlign_OpeningFcn, ...
                   'gui_OutputFcn',  @laser_heaterAlign_OutputFcn, ...
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


% --- Executes just before laser_heaterAlign is made visible.
function laser_heaterAlign_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to laser_heaterAlign (see VARARGIN)

% Choose default command line output for laser_heaterAlign
handles.output = hObject;
handles=appInit(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes laser_heaterAlign wait for user response (see UIRESUME)
% uiwait(handles.laser_heaterAlign);


% --- Outputs from this function are returned to the command line.
function varargout = laser_heaterAlign_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close laser_heaterAlign.
function laser_heaterAlign_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% ------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of fields for config file
handles.configList={'posValNum' 'mirrRange' 'acquireSampleNum' 'respMat' ...
    'profmonNumBG'};

handles.readPVNameList=[strcat('BPMS:IN20:221:',{'X' 'Y'}'); ...
                        strcat('BPMS:IN20:235:',{'X' 'Y'}')];
handles.acquireSampleNum=3;
handles.posValNum=5;
handles.profmonNumBG=1;
handles.processSelectMethod=1;
handles.process.displayExport=0;
handles.process.showImg=1;
%[X1 Y1 X2 Y2]' = M*[M2H M2V M3H M3V]';
handles.respMat=[-46600    263  79700  12300; ...
                   4490 -36300 -12300  79000; ...
                 -91500   -259 108000  17000; ...
                   8160 -65700 -16100 107000];  % microns/mm

handles.posPVList=[strcat('MIRR:IN20:436:MH2_MOTR_',{'H' 'V'}'); ...
                   strcat('MIRR:IN20:422:MH3_MOTR_',{'H' 'V'}')];
handles.beamOffPV='IOC:BSY0:MP01:MSHUTCTL';
handles.mirrRange=[0.05 0.05];
handles.delta=zeros(4,1);
handles.measured=0;
handles.wait=~ispc*2;
handles.pvScreen={'OTRH1' 'OTRH2'};

gui_statusDisp(handles,'Ready');
set([handles.apply_btn handles.applyNL_btn],'Enable','off');

guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10);
handles=appSetup(hObject,handles);
handles=gui_appLoad(hObject,handles);
im=imread('DD.bmp');im=im(1:3:end,1:3:end,:);
set(handles.dd_btn,'CData',im,'units','pixels');
pos=get(handles.dd_btn,'Position');set(handles.dd_btn,'Position',[pos(1:2) size(im)*[1 0;0 1;0 0]],'Visible','off');


% ------------------------------------------------------------------------
function handles = appSetup(hObject, handles)

handles.dataDevice.nVal=4;
handles=acquireSampleNumControl(hObject,handles,[]);
handles=posValNumControl(hObject,handles,[]);

handles=dataPlaneControl(hObject,handles,[]);
handles=dataMethodControl(hObject,handles,[],6);
handles=mirrRangeControl(hObject,handles,[],1:2);
handles=deltaControl(hObject,handles,[],1:4);
handles=acquireReset(hObject,handles);
handles=profmonNumBGControl(hObject,handles,1);


% ------------------------------------------------------------------------
function handles = acquireReset(hObject, handles)

if isfield(handles,'data')
    handles=rmfield(handles,'data');
end
handles.data.status=zeros(handles.dataDevice.nVal,1);
handles=dataCurrentDeviceControl(hObject,handles,1,[]);
handles=acquireUpdate(hObject,handles);
guidata(hObject,handles);


% ------------------------------------------------------------------------
function handles = posValNumControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'posValNum',val,1,1,[0 2]);
%handles=acquireReset(hObject,handles);


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
function handles = posPVSet(hObject, handles, lock)

gui_statusDisp(handles,'Applying mirror offsets ...');
if lock
    set(handles.apply_btn,'String','Applying ...');

    % Retract screens
    profmon_activate(handles.pvScreen{1},0);
    profmon_activate(handles.pvScreen{2},0);

    % Enable full laser beam & disable feedback
    lshStatPV='IOC:BSY0:MP01:LHSHUT_RATE';
    lshPV='IOC:BSY0:MP01:LSHUTCTL';
    fltPV='FLTR:IN20:130:FLT1_PNEU';
    lcaPut({lshPV fltPV}',[1 0]');pause(handles.wait);

    % Wait for LH MPS shutter
    t0=now;wait=10; % Seconds
    while lcaGet(lshStatPV,0,'double') == 1 && (now-t0)*24*60*60 < wait, end
    if (now-t0)*24*60*60 >= wait
        gui_statusDisp(handles,['Timeout for MPS shutter ' char(lshStatPV) ' not opened']);
        return
    end
else
    set(handles.applyNL_btn,'String','Applying ...');
end

% Disable feedback
fbPV='LASR:IN20:400:POS_FDBK';
lcaPut(fbPV,0);pause(handles.wait);

% Back-up mirrors for hysteresis and set new values
pos0=lcaGetSmart(handles.posPVList);
lcaPutSmart(handles.posPVList,pos0-handles.pos-.1);pause(1);
lcaPutSmart(handles.posPVList,pos0-handles.pos);pause(handles.wait);
handles.pos=0;
guidata(hObject,handles);

% Disable apply button
set([handles.apply_btn handles.applyNL_btn],'Enable','off', ...
    {'String'},{'Apply';'Apply ~Lock'});
gui_statusDisp(handles,'Apply done.');

% Lock feedback.
if lock, lockFBSet(hObject,handles);end


% ------------------------------------------------------------------------
function handles = lockFBSet(hObject, handles)

% Retract screens.
profmon_activate(handles.pvScreen{1},0);
profmon_activate(handles.pvScreen{2},0);

% Enable full laser beam.
lshStatPV='IOC:BSY0:MP01:LHSHUT_RATE';
lshPV='IOC:BSY0:MP01:LSHUTCTL';
fltPV='FLTR:IN20:130:FLT1_PNEU';
lcaPut({lshPV fltPV}',[1 0]');pause(handles.wait);

% Wait for LH MPS shutter.
t0=now;wait=10; % Seconds
while lcaGet(lshStatPV,0,'double') == 1 && (now-t0)*24*60*60 < wait, end
if (now-t0)*24*60*60 >= wait
    gui_statusDisp(handles,['Timeout for MPS shutter ' char(lshStatPV) ' not opened']);
    return
end

% Lock loop at new position
camName=model_nameConvert({'CH1' 'VHC'});
lcaPut(strcat(camName',':CTRD_LOCK'),1);
pause(.5);

% Enable feedback
fbPV='LASR:IN20:400:POS_FDBK';
lcaPut(fbPV,1);
gui_statusDisp(handles,'Locking feedback done');


% ------------------------------------------------------------------------
function handles = acquireSampleNumControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'acquireSampleNum',val,1,1,[0 1]);
handles=dataCurrentSampleControl(hObject,handles,1,handles.acquireSampleNum);
handles=acquireReset(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataCurrentSampleControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataSample',iVal,nVal);


% ------------------------------------------------------------------------
function handles = mirrRangeControl(hObject, handles, val, num)

handles=gui_editControl(hObject,handles,'mirrRange',val,num);


% ------------------------------------------------------------------------
function handles = dataCurrentDeviceControl(hObject, handles, iVal, nVal)

str={'OTRH1 Electrons' 'OTRH1 Laser' 'OTRH2 Electrons' 'OTRH2 Laser'};
handles=gui_sliderControl(hObject,handles,'dataDevice',iVal,nVal,1,1,str);


% ------------------------------------------------------------------------
function handles = acquireCurrentGet(hObject, handles, state)

iVal=handles.dataDevice.iVal;
str=sprintf('Data point #%d setting %s to %6.3f',iVal,handles.ctrlPVName{1}, ...
    handles.ctrlPVValList(1,iVal));
gui_statusDisp(handles,str);
%handles=ctrlPVSet(hObject,handles);
lcaPut(handles.ctrlPVName,handles.ctrlPVValList(:,iVal));
pause(handles.wait);

% Check if LH MPS shutter open
if ~mod(iVal,2)
    lshStatPV='IOC:BSY0:MP01:LHSHUT_RATE';
    t0=now;wait=60; % Seconds
    while lcaGet(lshStatPV,0,'double') == 1 && (now-t0)*24*60*60 < wait, end
    if (now-t0)*24*60*60 >= wait, disp(['Timeout for MPS shutter ' char(lshStatPV)]);end
end
pause(handles.wait);

dataList=profmon_measure(handles.profPV{iVal},handles.acquireSampleNum,'nBG', ...
    handles.profmonNumBG,'bufd',1,'axes',handles.dataPlot_ax,'insScreen',1);
handles.data.beam(iVal,:,:)=vertcat(dataList.beam);
handles.data.dataList(iVal,:)=dataList;
handles.data.status(iVal)=1;
handles=acquireUpdate(hObject,handles);
% Check for background enabled or ROI selected.
d=dataList(1);
if d.roiXN == d.nCol && d.roiYN == d.nRow && ~handles.profmonNumBG
    uiwait(warndlg(['No background or full ROI selected.  Image processing likely to fail.  ' ...
        'Choose an ROI around the electron beam in Prof Mon GUI'],'Image Processing Problem'));
end


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end

% record start time
start_time = tic;

handles=acquireReset(hObject,handles);

% Disable feedback
fbPV='LASR:IN20:400:POS_FDBK';
lcaPut(fbPV,0);pause(handles.wait/2);

% Save present PV states
lshPV='IOC:BSY0:MP01:LSHUTCTL';
bshPV=handles.beamOffPV;
fltPV='FLTR:IN20:130:FLT1_PNEU';
pvList={lshPV bshPV fltPV}';
valOld=lcaGet(pvList,0,'double');

% Insert attenuator
lcaPut(fltPV,1);pause(handles.wait);

% Back-up mirrors for hysteresis
pos0=lcaGetSmart(handles.posPVList);
lcaPutSmart(handles.posPVList,pos0-.1);pause(1);
lcaPutSmart(handles.posPVList,pos0);

% Set scan values
handles.profPV=model_nameConvert({'OTRH1' 'OTRH1' 'OTRH2' 'OTRH2'});
handles.ctrlPVName={lshPV bshPV}';
handles.ctrlPVValList=[0 1 0 1;1 0 1 0];
guidata(hObject,handles);

% Loop through screens
for iVal=1:4
    handles=dataCurrentDeviceControl(hObject,handles,iVal,[]);
    handles=acquireCurrentGet(hObject,handles);
    if ~gui_acquireStatusGet(hObject,handles), break, end
end

% Restore PV states
lcaPut(pvList,valOld);
profmon_activate(handles.profPV{end},0);

gui_acquireStatusSet(hObject,handles,0);
handles=acquireUpdate(hObject,handles);
gui_statusDisp(handles,'Done Measurement');
set([handles.apply_btn handles.applyNL_btn],'Enable','on');

% record elapsed time
elapsed_time = toc(start_time);
old_value = lcaGetSmart('SIOC:SYS0:ML03:AO705', 0, 'double');
lcaPutSmart('SIOC:SYS0:ML03:AO705', old_value + elapsed_time);


% ------------------------------------------------------------------------
function handles = acquireCalib(hObject, handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end

% Set pause length
handles.wait=~ispc*1;

% Get mirror positions
mirr0=lcaGetSmart(handles.posPVList);

% Calc mirror positions
valList=repmat(mirr0,1,handles.posValNum)+repmat(handles.mirrRange',2,1)/2*linspace(-1,1,handles.posValNum);

% Save present PV states
lshPV='IOC:BSY0:MP01:LSHUTCTL';
bshPV=handles.beamOffPV;
fltPV='FLTR:IN20:130:FLT1_PNEU';
pvList={lshPV bshPV fltPV}';
valOld=lcaGet(pvList,0,'double');

%Insert attenuator
lcaPut(fltPV,1);pause(handles.wait);

%Block eBeam
lcaPut({lshPV bshPV}',[1 0]');pause(handles.wait);

% Loop through screens
handles.data=struct;handles.data.status=zeros(1,2);
for iVal=1:2
    profmon_activate(handles.pvScreen{iVal});
    % Loop through mirrors
    for k=1:4
        % Move to less than first val
        lcaPutSmart(handles.posPVList{k},valList(k,1)-0.01);
        % Loop through samples
        for l=1:handles.posValNum
            lcaPutSmart(handles.posPVList{k},valList(k,l));
            dataList=profmon_measure(handles.pvScreen{iVal},handles.acquireSampleNum, ...
                'nBG',handles.profmonNumBG,'bufd',1,'axes',handles.dataPlot_ax);
            handles.data.beam(iVal,k,l,:,:)=vertcat(dataList.beam);
            
%            mp=zeros(4,1);mp(k)=valList(k,l);
%            xy=handles.respMat*mp;
%            [handles.data.beam(iVal,k,l,:,1).stats]=deal(xy(2*iVal-1:2*iVal)');
            
            if ~gui_acquireStatusGet(hObject,handles), break, end
        end
        lcaPutSmart(handles.posPVList{k},mirr0(k));
        if ~gui_acquireStatusGet(hObject,handles), break, end
    end
    if ~gui_acquireStatusGet(hObject,handles), break, end
    handles.data.status(iVal)=1;
end

% Restore PV states
lcaPut(pvList,valOld);
%lcaPutSmart(handles.posPVList,mirr0);
gui_acquireStatusSet(hObject,handles,0);
gui_statusDisp(handles,'Done Calibrating');
guidata(hObject,handles);

% Do analysis
data=handles.data;
if ~all(data.status), return, end

stats=reshape(vertcat(data.beam(:,:,:,:,handles.dataMethod.jVal).stats), ...
    2,4,handles.posValNum,handles.acquireSampleNum,[]);
statsMean=squeeze(mean(stats(:,:,:,:,1:2),4));
statsMean=reshape(permute(statsMean,[3 4 1 2]),[],4,4);

par=zeros(2,4,4);
for j=1:4
    m=[valList(j,:)' ones(handles.posValNum,1)];
    par(:,:,j)=lscov(m,statsMean(:,:,j));
end
handles.respMat=round(squeeze(par(1,:,:)));
guidata(hObject,handles);

plot(kron(valList',[1 1 1 1]),reshape(statsMean,[],16),'Parent',handles.dataPlot_ax);
xlabel('Mirror Position  (mm)');
ylabel('Laser Position  (\mum)');


% ------------------------------------------------------------------------
function handles = acquireUpdate(hObject, handles)

guidata(hObject,handles);
data=handles.data;
if ~all(data.status), return, end

statsList=vertcat(data.beam(:,:,handles.dataMethod.jVal).stats);
stats=reshape(statsList,2,2,handles.acquireSampleNum,[]);
cts=median(stats(:,:,:,6),3);use=stats(:,:,:,6) > repmat(cts,[1 1 handles.acquireSampleNum])/2;
stats(repmat(~use,[1 1 1 6]))=NaN;
statsMean=util_meanNan(stats(:,:,:,1:2),3);
handles.delta=reshape(squeeze(diff(statsMean,1,1))',[],1); %[H1_x H1_y H2_x H2_y]'
handles=posUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = posUpdate(hObject, handles)

handles.pos=inv(handles.respMat)*handles.delta;
pos0=lcaGetSmart(handles.posPVList);
col={'w' 'y' 'r'};
sevr=(abs(handles.delta) > 100) + (abs(handles.delta) > 200);
for j=1:4
    set(handles.(['delta' num2str(j) '_txt']),'String',num2str(handles.delta(j),'%5.0f'), ...
        'BackgroundColor',col{sevr(j)+1});
    set(handles.(['posOld' num2str(j) '_txt']),'String',num2str(pos0(j),'%5.3f'));
    set(handles.(['posNew' num2str(j) '_txt']),'String',num2str(pos0(j)-handles.pos(j),'%5.3f'));
end
guidata(hObject,handles);
state={'on' 'off' 'off'};
set(handles.dd_btn,'Visible',state{max(sevr)+1});


% ------------------------------------------------------------------------
function plotProfile(hObject, handles)

data=handles.data;iVal=handles.dataDevice.iVal;
if ~data.status(iVal)
    cla(handles.dataPlot_ax);
    return
end

if handles.process.showImg && isfield(data,'dataList')
    imgData=data.dataList(iVal,handles.dataSample.iVal);
    stats=reshape(vertcat(data.beam(handles.dataDevice.iVal,:,handles.dataMethod.jVal).stats),handles.acquireSampleNum,[]);
    cts=median(stats(:,6));use=stats(:,6) >= cts/2;
    statsMean=mean(stats(use,1:2),1);pos.x=statsMean(1);pos.y=statsMean(2);
    pos=profmon_coordTrans(pos,imgData,'pixel');
    profmon_imgPlot(imgData,'axes',handles.dataPlot_ax,'bits',8,'target',pos,'lineOut',0,'cal',1);
    return
end

iMethod=handles.dataMethod.iVal;
opts.axes=handles.dataPlot_ax;
beam=data.beam(handles.dataDevice.iVal,handles.dataSample.iVal,iMethod);
beamAnalysis_profilePlot(beam,handles.dataPlane,opts);
set(handles.dataMethod_txt,'String',beam.method);


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
readPVVal=reshape([readPV.val],size(readPV,1),size(readPV,2),[]);

yPV=readPV;
yPVVal=readPVVal;
yPVValMean=mean(yPVVal,3);
yPVValStd=std(yPVVal,1,3);

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


% ------------------------------------------------------------------------
function handles = profmonNumBGControl(hObject, handles, val)

handles=gui_editControl(hObject,handles,'profmonNumBG',val);


% ------------------------------------------------------------------------
function handles = dataMethodControl(hObject, handles, iVal, nVal)

if isempty(iVal)
    iVal=handles.processSelectMethod;
end
handles=gui_sliderControl(hObject,handles,'dataMethod',iVal,nVal);

handles.processSelectMethod=iVal;
guidata(hObject,handles);
acquireUpdate(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataPlaneControl(hObject, handles, tag)

if isempty(tag), tag='x';end
handles=gui_radioBtnControl(hObject,handles,'dataPlane',tag);
plotProfile(hObject,handles);


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


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

gui_acquireAbortAll;


% --- Executes on button press in export_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in apply_btn.
function apply_btn_Callback(hObject, eventdata, handles)

posPVSet(hObject,handles,1);


% --- Executes on button press in applyNL_btn.
function applyNL_btn_Callback(hObject, eventdata, handles)

posPVSet(hObject,handles,0);


function solRange_txt_Callback(hObject, eventdata, handles, tag)

ctrlPVRangeControl(hObject,handles,tag,str2double(get(hObject,'String')));


% --- Executes on button press in calib_btn.
function calib_btn_Callback(hObject, eventdata, handles)

acquireCalib(hObject,handles);


function acquireSampleNum_txt_Callback(hObject, eventdata, handles)

acquireSampleNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in appSave_btn.
function appSave_btn_Callback(hObject, eventdata, handles)

gui_appSave(hObject,handles);


% --- Executes on button press in appLoad_btn.
function appLoad_btn_Callback(hObject, eventdata, handles)

gui_appLoad(hObject,handles);


function posValNum_txt_Callback(hObject, eventdata, handles)

posValNumControl(hObject,handles,round(str2double(get(hObject,'String'))));


% --- Executes on slider movement.
function dataMethod_sl_Callback(hObject, eventdata, handles)

handles=dataMethodControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);


function profmonNumBG_txt_Callback(hObject, eventdata, handles)

profmonNumBGControl(hObject,handles,str2double(get(hObject,'String')));


function mirrRange_txt_Callback(hObject, eventdata, handles, num)

mirrRangeControl(hObject,handles,str2double(get(hObject,'String')),num);


% --- Executes on button press in dd_btn.
function dd_btn_Callback(hObject, eventdata, handles)


% --- Executes on slider movement.
function dataDevice_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentDeviceControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);


% --- Executes on button press in lockFB_btn.
function lockFB_btn_Callback(hObject, eventdata, handles)

lockFBSet(hObject,handles);


function handles = deltaControl(hObject, handles, val, num)

if any(isnan(val)) || isempty(val)
    val=handles.delta(num);
end
handles.delta(num,1)=val;
handles=posUpdate(hObject,handles);


function delta1_txt_Callback(hObject, eventdata, handles)

deltaControl(hObject,handles,str2double(get(hObject,'String')),1);


function delta2_txt_Callback(hObject, eventdata, handles)

deltaControl(hObject,handles,str2double(get(hObject,'String')),2);


function delta3_txt_Callback(hObject, eventdata, handles)

deltaControl(hObject,handles,str2double(get(hObject,'String')),3);


function delta4_txt_Callback(hObject, eventdata, handles)

deltaControl(hObject,handles,str2double(get(hObject,'String')),4);


% --- Executes on button press in showImg_box.
function showImg_box_Callback(hObject, eventdata, handles)

handles.process.showImg=get(hObject,'Value');
guidata(hObject,handles);
plotProfile(hObject,handles);


% --- Executes on button press in dataPlaneX_rbn.
function dataPlane_rbn_Callback(hObject, eventdata, handles, tag)

dataPlaneControl(hObject,handles,tag);


% --- Executes on button press in acquireCurrentGet_btn.
function acquireCurrentGet_btn_Callback(hObject, eventdata, handles)

acquireCurrentGet(hObject,handles,'query');


% --- Executes on slider movement.
function dataSample_sl_Callback(hObject, eventdata, handles)

handles=dataCurrentSampleControl(hObject,handles,round(get(hObject,'Value')),[]);
plotProfile(hObject,handles);
