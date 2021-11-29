function varargout = profmon_gui(varargin)
% PROFMON_GUI M-file for profmon_gui.fig
%      PROFMON_GUI, by itself, creates a new PROFMON_GUI or raises the existing
%      singleton*.
%
%      H = PROFMON_GUI returns the handle to a new PROFMON_GUI or the handle to
%      the existing singleton*.
%
%      PROFMON_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROFMON_GUI.M with the given input arguments.
%
%      PROFMON_GUI('Property','Value',...) creates a new PROFMON_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before profmon_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to profmon_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help profmon_gui

% Last Modified by GUIDE v2.5 02-Aug-2013 10:59:04

% --------------------------------------------------------------
% Auth: Henrik Loos, Greg White
% Mod:  31-Jan-2018, T. Maxwell, remove OTR22 (to XLEAP) & OTR_TCAV (old)
%       8-Sep-2016, greg White, remove ref to PR55 in BSY removed
%       in prep for LCLS-2.
%       5-Apr-2017, Sonya Hoobler, permanently removed PR55 and
%       PR45 (were previously just commented out)
% ==============================================================

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @profmon_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @profmon_gui_OutputFcn, ...
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


% --- Executes just before profmon_gui is made visible.
function profmon_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to profmon_gui (see VARARGIN)

% Choose default command line output for profmon_gui
handles.output = hObject;
if 0
    hList=findobj(hObject,'Type','uicontrol');
    colDef=get(hObject,'DefaultUIControlBackgroundColor');
    colList=get(hList,'BackgroundColor');
    use=cellfun(@isequal,colList,repmat({colDef},size(colList)));
    set(hList(use),'BackgroundColor',[.9255 .9137 .8471]);
    set(hObject,'Color',[.9255 .9137 .8471]);
end
[sys, accelerator] = getSystem;
handles.accelerator=accelerator;
if strcmp(accelerator,'NLCTA')
    handles.PVList=strcat({ ...
        '13PS10' '13PS4' '13PS2' '13PS9' '13PS5' '13PS11' '13PS12' ...
        '13PS1' '13PS8' '13PS7' '13PS6' ... %NLCTA
        },':cam1');
    handles.PVId=1;
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
    handles.PVId=1;
elseif strcmp(accelerator,'ASTA')
    handles.PVList={ ...
        'VCC:AS01:186' ...
        'VIS:AS01:2' ...
        'YAGS:AS01:3' ...
        };
    handles.PVId=1;
elseif strcmp(accelerator,'FACET')
    handles.PVList={ ...
        'CAMR:LT10:200' ...
        'CAMR:LT10:380' ...
        'CAMR:LT10:450' ...
        'CAMR:LT10:500' ...
        'CAMR:LT10:600' ...
        'CAMR:LT10:700' ...
        'CAMR:LT10:800' ...
        'CAMR:LT10:900' ...
        'CTHD:IN10:111' ...
        'PROF:IN10:241' ...
        'PROF:IN10:571' ...
        'PROF:IN10:711' ...
        'PROF:IN10:770' ...
        'PROF:IN10:921' ...
        'PROF:LI11:335' ...
        'PROF:LI11:375' ...
        'PROF:LI14:803' ...
        'PROF:LI15:944' ...
        'PROF:LI20:45' ...
        'CAMR:LI20:100' ...
        'CAMR:LI20:101' ...
        'CAMR:LI20:102' ...
        'CAMR:LI20:103' ...
        'CAMR:LI20:104' ...
        'CAMR:LI20:105' ...
        'CAMR:LI20:106' ...
        'CAMR:LI20:107' ...
        'CAMR:LI20:108' ...
        'CAMR:LI20:200' ...
        'CAMR:LI20:201' ...
        'CAMR:LI20:202' ...
        'CAMR:LI20:203' ...
        'CAMR:LI20:204' ...
        'CAMR:LI20:205' ...
        'CAMR:LI20:206' ...
        'CAMR:LI20:207' ...
        'CAMR:LI20:208' ...
        'CAMR:LI20:300' ...
        'CAMR:LI20:301' ...
        'CAMR:LI20:302' ...
        'CAMR:LI20:303' ...
        'CAMR:LI20:304' ...
        'CAMR:LI20:305' ...
        'CAMR:LI20:306' ...
        'CAMR:LI20:307' ...
        'CAMR:LI20:308' ...
        'CAMR:LT20:0001' ...
        'CAMR:LT20:0002' ...
        'CAMR:LT20:0003' ...
        'CAMR:LT20:0004' ...
        'CAMR:LT20:0005' ...
        'CAMR:LT20:0006' ...
        'CAMR:LT20:0007' ...
        'CAMR:LT20:0008' ...
        'CAMR:LT20:0009' ...
        'CAMR:LT20:0010' ...
        'CAMR:LT20:0011' ...
        'CAMR:LT20:0012' ...
        'CAMR:LT20:0013' ...
        'CAMR:LT20:0014' ...
        'CAMR:LT20:0101' ...
        'CAMR:LT20:0102' ...
        'CAMR:LT20:0103' ...
        'CAMR:LT20:0104' ...
        'CAMR:LT20:0105' ...
        'CAMR:LT20:0106' ...
        'CAMR:LT20:0107' ...
        'CMOS:LI20:3490' ...
        'CMOS:LI20:3491' ...
        'CMOS:LI20:3492' ...
        };
   
    handles.PVId=4;
elseif strcmp(accelerator,'SPEAR')
    handles.PVList={ ...
        'LTB-B1-CAM' ...
        };
    handles.PVId=1;
else
    handles.PVList={ ...
        'CAMR:LGUN:210' 'CAMR:LGUN:390' ...
        'CAMR:LGUN:400' 'CAMR:LGUN:430' 'CAMR:LGUN:460' ...
        'CAMR:LGUN:490' 'CAMR:LGUN:750' ...
        'CAMR:LGUN:850' 'CAMR:LGUN:950' ...
        'CAMR:LHTR:250'  'CAMR:LHTR:350'  'CAMR:LHTR:400' 'CAMR:LHTR:490' ...
        'CAMR:LHTR:750'  'CAMR:LHTR:850'  'CAMR:LHTR:950' ...
        'YAGS:GUNB:753' ...
        'CAMR:LR20:100'  'CAMR:LR20:90'...
        'CAMR:LR20:135'  'CAMR:IN20:186'  'CAMR:LR20:285' ...
        'CAMR:LR20:295'  'CAMR:LR20:287'  'CAMR:LR20:297'  'CAMR:LR20:320' ...
        'CAMR:IN20:423'  'CAMR:IN20:461'  'CAMR:IN20:469' ...
        'CTHD:IN20:206'  'YAGS:IN20:211'  'YAGS:IN20:841'  'YAGS:IN20:241' ...
        'YAGS:IN20:351'  'OTRS:IN20:465'  'OTRS:IN20:471'  'OTRS:IN20:541' ...
        'OTRS:IN20:571'  'OTRS:IN20:621'  'OTRS:IN20:711'  'YAGS:IN20:921' ...
        'YAGS:IN20:995'  'OTRS:LI21:237'  'OTRS:LI21:291'  'OTRS:LI24:807' ...
...%    'OTRS:LI25:342'  'OTRS:LI25:920' ... Removed 31-Jan-17, TJM
        'PROF:BSYA:1800' ...
        'OTRS:LTUH:449'  'YAGS:LTUH:743'  ...
        'PROF:UNDH:2850' 'YAGS:UNDS:3575' 'YAGS:UNDS:3795'  ...
        'SLIT:UNDS:3555' ...
        'PROF:DMP1:731'  'YAGS:DMP1:498'  'YAGS:DMP1:500'  'OTRS:DMPH:695'  ...
        'OTRS:DMPS:695' 'CAMR:FEE1:441'  'CAMR:FEE1:441:BLD1' ...
        'CAMR:FEE1:455'  'DIAG:FEE1:481'  'DIAG:FEE1:482' ...
        'IM1K0' 'IM1K4' 'IM2K0' 'IM1L0' 'IM2L0' 'IM3L0' 'IM4L0'...
        'HXX:UM6:CVP:01' ...
        'AMO:SAS:CVV:01' 'AMO:DIA:CVV:02' 'SXR:YAG:CVV:01' 'HXX:UM6:CVV:01' ...
        'HXX:HXM:CVV:01' 'HFX:DG2:CVV:01' 'HFX:DG3:CVV:01' 'XCS:DG3:CVV:02' ...
        'MEC:HXM:CVV:01' ...
        'SXR:EXS:CVV:01' 'SXR:EXS:CVV:01:IMAGE_CMPX' ...
        'XPP:OPAL1K:1'   'XPP:OPAL1K:1:IMAGE_CMPX' ...
        'MEC:OPAL1K:1'   'MEC:OPAL1K:1:IMAGE_CMPX' ...
        'CXI:EXS'        'CAMR:B34:100' ...
        };
    handles.PVId=21;
end

handles.PV=handles.PVList{handles.PVId};
handles=bitsControl(hObject,handles,8,16);
handles=dataMethodControl(hObject,handles,1,6);
handles.bufd=1;
handles.useBG=0;
handles.zoom=0;
handles.nAverage=1;
handles.zoomStats=0;
%handles.lampSel=0;
handles.dataStream=0;
handles.show.cal=1;
handles.show.stats=0;
handles.show.hist=0;
handles.show.rawImg=0;
handles.show.tcav=0;
handles.show.ener=0;
handles.show.lineOut=0;
handles.show.target.x=320;
handles.show.target.y=240;
handles.show.colorbar=0; 
handles.show.bg=0;
handles.show.bmCross=0;
handles.displayExport=0;
handles.calibrate=0;
handles.cal.rad=8000;
handles.cal.nFit=4;
handles.fileName='';
handles.process.saved=0;
handles.gain=0;
handles.exposureTime=0.05;
handles.xPixelBin=1;
handles.yPixelBin=1;
handles.profmonXSig=4.6;
handles.profmonYSig=4.6;
handles.getFull=0;
handles.slice.Dir = 'y';
handles=numSlices_txt_Callback(hObject,[],handles);

%if strcmp(accelerator,'ASTA'),gui_printLogInit(hObject,handles);end

enableNLCTA(handles,0);
% if strcmp(handles.accelerator,'NLCTA'), enableNLCTA(handles,1); end
%handles=exportSetup(hObject,handles,struct);
%util_appMenu(hObject,struct('toolbar',1));
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',12);
handles.cal.hList=[handles.calRadLabel_txt handles.calRad_txt ...
    handles.calData_txt handles.calRadUnits_txt handles.calIsVertical_box ...
    handles.calApply_btn handles.calIsEllipse_box handles.calReset_btn ...
    handles.calHelp_btn handles.calNFitLabel_txt handles.calNFit_txt ...
%    handles.lampSel_btn handles.lampOn_btn handles.lampOff_btn ...
    ];
set(handles.image_ax,'PlotBoxAspectRatio',[1392 1040 1]);
set(handles.cal.hList,'Visible','off');
set(handles.pvList_pmu,'String',model_nameConvert(handles.PVList,'MAD'),'Value',handles.PVId);
set(handles.pv_txt,'String',handles.PV);
handles.calib_circ=line(NaN,NaN,'Parent',handles.image_ax,'Color','y', ...
    'LineStyle',':','HitTest','off');
handles.calib_line=line(NaN,NaN,'Parent',handles.image_ax,'Color','r', ...
    'Marker','x','MarkerSize',10,'LineStyle','none','HitTest','off');
for j=1:length(handles.PVList)
    handles.bg{j}=0;
end

% Resize if necessary.
gui_resize(hObject);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes profmon_gui wait for user response (see UIRESUME)
% uiwait(handles.profmon_gui);


% --- Outputs from this function are returned to the command line.
function varargout = profmon_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close profmon_gui.
function profmon_gui_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% -----------------------------------------------------------
function handles = plot_image(hObject, handles, update)
if ~isfield(handles,'data'), return, end
data=handles.data;
if ~data.img(end), data.img(end)=max([min(data.img(1:end-1)) 0]);end

ax=handles.image_ax;
if handles.displayExport
    handles.exportFig=figure;
    guidata(hObject,handles);
    ax=subplot(1,1,1,'Box','on');
end

if handles.show.lineOut
    target=handles.show.target;
else target=[];
end
if handles.show.bmCross
    crossV=lcaGetSmart(strcat(data.name,{':X';':Y'},'_BM_CTR'));
    [cross.x,cross.y,cross.units,cross.isRaw]=deal(crossV(1),crossV(2),'mm',0);
else cross=[];
end
if handles.useBG, data.img=int16(data.img)-int16(data.back);end
if numel(data.back) > 1 && handles.show.bg, data.img=data.back;end
bits=handles.bits.iVal;
profmon_imgPlot(data,'axes',ax,'useBG',0,'rawImg',handles.show.rawImg, ...
    'cal',handles.show.cal,'aspect',~handles.displayExport,'scale',~handles.zoom, ...
    'title',['Profile Monitor %s ' datestr(data.ts,'dd-mmm-yyyy HH:MM:SS')],'target',target, ...
    'bits',bits*(bits > 4),'tcav',handles.show.tcav,'cross',cross,'ener',handles.show.ener);
handles=guidata(hObject);

if handles.displayExport
    xLim=get(handles.image_ax,'XLim');
    yLim=get(handles.image_ax,'YLim');
    set(ax,'XLim',xLim,'YLim',yLim);
    return
end

if handles.zoomStats
    data=imgCrop(hObject,handles);
    if handles.useBG, data.img=int16(data.img)-int16(data.back);end
end

if handles.show.hist
    profmon_imgHist(data,'figure',2);
end

if handles.show.stats
    beam=profmon_process(data,'useCal',handles.show.cal,'back',0,'useTime',handles.show.tcav, ...
        'useEner',handles.show.ener,'usemethod',handles.dataMethod.iVal, ...
        'xsig',handles.profmonXSig,'ysig',handles.profmonYSig);
    if ~ismember(data.name(6:min(9,end)),{'M6:C' 'XS:C' 'PAL1' 'G2:C'}) && nargin == 3 && update
        control_profDataSet(data.name,beam);
    end
    set(handles.dataMethod_txt,'String',beam.method);
end

str={'*' ''};
set(handles.output,'Name',['Profile Monitor GUI - [' handles.fileName ']' str{handles.process.saved+1}]);

handles=guidata(hObject);
if handles.calibrate
    handles=calUpdate(hObject,handles);
end

if handles.slice.active == 1
    handles = update_slice(hObject, handles);
end


% -----------------------------------------------------------
function handles = grab_image(hObject, handles)

guidata(hObject,handles);
[d,is]=profmon_names(handles.PV);

if is.Gain
    set(handles.gain_txt,'Visible', 'on')
    set(handles.gainLabel_txt, 'Visible', 'on')
else
    set(handles.gain_txt,'Visible', 'off')
    set(handles.gainLabel_txt, 'Visible', 'off')
end

% Return if FACET camera is in data acquisition mode.
if is.FACET && ~is.AreaDet && lcaGetSmart(strcat(handles.PV,':TRIGGER_DAQ'),0,'double')
    cla(handles.image_ax);
    text(0,0,['Profile Monitor ' handles.PV ' DAQ Trigger Enabled'], ...
        'Parent',handles.image_ax,'HorizontalAlignment','center', ...
        'Color',rand(1,3),'FontSize',20);
    pause(0.1);
    return
 end

nImg=[];
if handles.bufd && is.Bufd
    nImg=0;
    lcaPutSmart([handles.PV ':SAVE_IMG'],1);
end
%data=profmon_grabSeries(handles.PV,handles.nAverage,0,'bufd',handles.bufd);
ts=-Inf;if isfield(handles,'data'), ts=handles.data.ts;end
for j=1:handles.nAverage
    set(handles.text10,'String',num2str(j,'%d /'));drawnow;
    ts0=ts;
    while ts <= ts0
        data(j)=profmon_grab(handles.PV,0,nImg,'getFull',handles.getFull);ts=data(j).ts;
        if handles.nAverage < 2, ts=Inf;end
    end
end
set(handles.text10,'String','# Av.');drawnow;
handles=guidata(hObject);
if handles.dataStream
    for j=1:handles.nAverage
        handles.data=data(j);
        handles.data.name=[handles.data.name '-' num2str(j)];
        handles.data.back=handles.bg{handles.PVId};
        dataSave(hObject,handles,0);
    end
end
handles.data=data(1);

if numel(data) > 1
    handles.data.img=feval(class(data(1).img),mean(cat(4,data.img),4));
end
handles.data.back=handles.bg{handles.PVId};
handles.process.saved=0;
handles=bitsControl(hObject,handles,[],handles.data.bitdepth);
handles=plot_image(hObject,handles,1);


% ------------------------------------------------------------------------
function handles = acquireStart(hObject, handles)

if handles.dataStream
    button = questdlg({'Stream Images is selected','','(A large number of images may be saved to disk)',...
        '','Stream Images to disk?'},'Stream Images to disk?','Yes','No','No');
    handles.dataStream=strcmp(button,'Yes');
    set(handles.dataStream_box,'Value',handles.dataStream);
end
tags={'Start' 'Stop'};
cols=[.502 1 .502;1 .502 .502];
style=strcmp(get(hObject,'Type'),'uicontrol');
state=gui_acquireStatusGet(hObject,handles);
if style, set(hObject,'String',tags{state+1},'BackgroundColor',cols(state+1,:));end
if state, profmon_evrSet(handles.PV);end
while gui_acquireStatusGet(hObject,handles)
    grab_image(hObject,handles);
    pause(0.01);
    handles=guidata(hObject);
end


% --- Executes on button press in single_btn.
function single_btn_Callback(hObject, eventdata, handles)

handles.slice.plotSlice = 1;
profmon_evrSet(handles.PV);
grab_image(hObject,handles);


% --- Executes on selection change in colmap_lbx.
function colmap_lbx_Callback(hObject, eventdata, handles)

colmaps=get(hObject,'String');
if get(hObject,'Value') < 4
    colmap=feval(colmaps{get(hObject,'Value')},256);
elseif get(hObject,'Value') == 4
    cmap = custom_cmap;
    colmap = cmap.wbgyr;
elseif get(hObject,'Value') == 5
    cmap = custom_cmap;
    colmap = cmap.mjet;
end
set(gcbf,'Colormap',colmap);


% -----------------------------------------------------------
function pv_txt_Callback(hObject, eventdata, handles)

handles.PV=get(hObject,'String');
guidata(hObject,handles);
profmon_evrSet(handles.PV);



% -----------------------------------------------------------
function handles = bitsControl(hObject, handles, val, nVal)

handles=gui_sliderControl(hObject,handles,'bits',val,max(5,nVal));
str=num2str(handles.bits.iVal);if handles.bits.iVal == 4, str='Auto';end
set(handles.bits_txt,'String',str);
handles=plot_image(hObject,handles);


% ------------------------------------------------------------------------
function handles = dataMethodControl(hObject, handles, iVal, nVal)

handles=gui_sliderControl(hObject,handles,'dataMethod',iVal,nVal);
handles.slice.plotSlice = 1;
handles=plot_image(hObject,handles);


% --- Executes on slider movement.
function bits_sl_Callback(hObject, eventdata, handles)

bitsControl(hObject,handles,round(get(hObject,'Value')),[]);


% --- Executes on slider movement.
function dataMethod_sl_Callback(hObject, eventdata, handles)

dataMethodControl(hObject,handles,round(get(hObject,'Value')),[]);


function handles = exportSetup(hObject, handles, opts)

optsdef=struct( ...
    'fontName','Times', ...
    'fontSize',12, ...
    'lineWidth',1.5);
if ~isfield(handles,'export'), handles.export.opts=optsdef;end
handles.export.opts=util_parseOptions(opts,handles.export.opts);
guidata(hObject,handles);


% -----------------------------------------------------------
function handles = dataSave(hObject, handles, val)

if ~isfield(handles,'data'), return, end
data=handles.data;
fileName=util_dataSave(data,'ProfMon',data.name,data.ts,val);

if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
guidata(hObject,handles);
plot_image(hObject,handles);


% -----------------------------------------------------------
function handles = dataOpen(hObject, handles, val)

if nargin == 4, fileName=val;
    load(fileName,'data');
else
    [data,fileName]=util_dataLoad('Open image file');
end
if ~ischar(fileName), return, end
handles.fileName=fileName;

% Put data in handles.
nameList={'name' 'img' 'ts' 'pulseId' 'nCol' 'nRow' 'bitdepth' 'res' 'roiX' ...
    'roiY' 'roiXN' 'roiYN' 'orientX' 'orientY' 'centerX' 'centerY' 'isRaw' 'back'};
names=fieldnames(data);
mis=setdiff(nameList,names);
obs=setdiff(names,nameList);
if ~isempty(mis) || ~isempty(obs)
    disp(fileName);
    disp(['Missing : ' mis{:}]);
    disp(['Obsolete : ' obs{:}]);
end    
%handles.data=orderfields(data,nameList(ismember(nameList,fieldnames(data))));
handles.data=data;
handles.process.saved=1;

handles=bitsControl(hObject,handles,[],handles.data.bitdepth);
guidata(hObject,handles);
plot_image(hObject,handles);%pause(.01);
%save_btn_Callback(hObject,[],guidata(hObject),0);


% -----------------------------------------------------------
function handles = dataExport(hObject, handles, val)

if ~isfield(handles,'data'), return, end
handles.displayExport=1;
handles=plot_image(hObject,handles);
handles.displayExport=0;
guidata(hObject,handles);
%util_appFonts(handles.exportFig,handles.export.opts);
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',16);
set(handles.exportFig,'Colormap',get(handles.output,'Colormap'));
if handles.show.colorbar, colorbar;end

if val
    % Adding orientation and resolution value to logbook entry
    % too much confusion from flipped cameras at FACET - S.G. 4/15/14
    if strcmp(handles.accelerator,'FACET')
        name = lcaGet([handles.data.name ':NAME']);
        str={'Positive' 'Negative'};
        opts.text = sprintf('NAME %s, X_ORIENT %s, Y_ORIENT %s, RESOLUTION %g', ...
            name{:},str{[handles.data.orientX handles.data.orientY]+1},handles.data.res);
        opts.title=['ProfMon ' handles.data.name];
        util_printLog(handles.exportFig,opts);
    else
        util_appPrintLog(handles.exportFig,'ProfMon',handles.data.name,handles.data.ts,val);
    end
    dataSave(hObject,handles,0);
end


% --- Executes on selection change in pvlist_pmu.
function pvList_pmu_Callback(hObject, eventdata, handles)

handles.PVId=get(hObject,'Value');
handles.PV=handles.PVList{handles.PVId};
set(handles.pv_txt,'String',handles.PV);

% if strcmp(handles.accelerator,'NLCTA') %if NLCTA
%     handles=enableNLCTA(handles,1);
% else
%     handles=enableNLCTA(handles,0);
% end

if strcmp(handles.accelerator,'FACET')
    if strncmp(handles.PV,'CAMR:LT20',9) % if FACET laser camera, turn on colorbar and turn off calibration
        
        handles.show.colorbar=1;
        set(handles.showColorbar_box,'Value',1);
        showColorbar_box_Callback(handles.showColorbar_box,[],handles);
        
        handles.show.cal=0;
        set(handles.calib_box,'Value',0);
        calib_box_Callback(handles.calib_box,[],handles);
        
    end
end
        
guidata(hObject,handles);
profmon_evrSet(handles.PV);
profmon_optSet(handles)

% --- Executes on button press in calib_box.
function calib_box_Callback(hObject, eventdata, handles)

pos=getZoomCoords(hObject,handles);
handles.show.cal=get(hObject,'Value');
guidata(hObject,handles);
setZoomCoords(hObject,handles,pos);
handles.slice.plotSlice = 1;
plot_image(hObject,handles);
%zoomControl(hObject,handles,0);


% --- Executes on button press in rawImg_box.
function rawImg_box_Callback(hObject, eventdata, handles)

pos=getZoomCoords(hObject,handles);
handles.show.rawImg=get(hObject,'Value');
guidata(hObject,handles);
setZoomCoords(hObject,handles,pos);
plot_image(hObject,handles);


% --- Executes on button press in bg_btn.
function bg_btn_Callback(hObject, eventdata, handles)

bg=profmon_grabBG(handles.PV,handles.nAverage,'bufd',1);
handles.bg{handles.PVId}=mean(cat(4,bg.img),4);
handles.data.back=handles.bg{handles.PVId};
guidata(hObject,handles);


% --- Executes on button press in makeBG_btn.
function makeBG_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles,'data'), return, end
handles.bg{handles.PVId}=handles.data.img;
handles.data.back=handles.bg{handles.PVId};
guidata(hObject,handles);


% --- Executes on button press in useBG_box.
function useBG_box_Callback(hObject, eventdata, handles)

handles.useBG=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in showStats_box.
function showStats_box_Callback(hObject, eventdata, handles)

if handles.slice.active == 1
    set(hObject, 'value',0);
    set(handles.slice_sl,'value',1);
    handles = update_slice(hObject, handles);
    guidata(hObject,handles);
    return
end
handles.show.stats=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in showHist_box.
function showHist_box_Callback(hObject, eventdata, handles)

handles.show.hist=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in tcav_box.
function tcav_box_Callback(hObject, eventdata, handles)

handles.show.tcav=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in spec_box.
function spec_box_Callback(hObject, eventdata, handles)

handles.show.ener=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in getFull_box.
function getFull_box_Callback(hObject, eventdata, handles)

handles.getFull=get(hObject,'Value');
guidata(hObject,handles);


% -----------------------------------------------------------
function zoomControl(hObject, handles, val)

if isempty(val)
    val=handles.zoom;
end
handles.zoom=val;
set(handles.calZoom_box,'Value',val);

state={'off' 'on'};
zoom(gcbf,state{handles.zoom+1});
if ~handles.zoom
%    set(handles.image_ax,'ButtonDownFcn', ...
%        'profmon_gui(''image_ax_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    if ~handles.calibrate
        plot_image(hObject,handles);
    end
end
guidata(hObject,handles);


% -----------------------------------------------------------
function pos = getZoomCoords(hObject, handles)

pos=[];if ~isfield(handles,'data'), return, end

pos.x=get(handles.image_ax,'XLim');
pos.y=get(handles.image_ax,'YLim');
pos.isRaw=handles.show.rawImg;
pos.units='mm';
if ~handles.show.cal, pos.units='pixel';end
pos=profmon_coordTrans(pos,handles.data,'pixel');
pos.x=round(sort(pos.x));
pos.y=round(sort(pos.y));


% -----------------------------------------------------------
function setZoomCoords(hObject, handles, pos)

if ~isfield(handles,'data'), return, end
data=handles.data;data.img=[];

if pos.isRaw ~= handles.show.rawImg;
    data=profmon_imgFlip(data);
end
units='mm';
if ~handles.show.cal, units='pixel';end
pos=profmon_coordTrans(pos,data,units);

set(handles.image_ax,'XLim',sort(pos.x));
set(handles.image_ax,'YLim',sort(pos.y));


% -----------------------------------------------------------
function data = imgCrop(hObject, handles)

if ~isfield(handles,'data'), return, end
data=profmon_imgCrop(handles.data,getZoomCoords(hObject,handles));


% -----------------------------------------------------------
function setROIControl(hObject, handles, val)

if ~isfield(handles,'data'), return, end
data=handles.data;
[name,is]=profmon_names(data.name);

if val == 2, data=imgCrop(hObject,handles);end
data=profmon_imgFlip(data,1);
switch val
    case 0
        pos=[0 0 data.nCol data.nRow]';
        if is.FACET
	    lcaPut([data.name ':ROI:SizeX'],data.nCol);
	    lcaPut([data.name ':ROI:SizeY'],data.nRow);
	end
    case 1
        nPix=400;
        if is.Popin, nPix=1000;end
        if is.Cascade, nPix=256;end
        pos=[fix([data.centerX data.centerY]/2)*2-nPix/2 nPix nPix]';
    case 2
        pos=round([data.roiX data.roiY data.roiXN data.roiYN]'/2)*2;
end
profmon_ROISet(name,pos);

handles.bg{handles.PVId}=0;
handles=grab_image(hObject,handles);
zoomControl(hObject,handles,0);


% --- Executes on button press in plot_img.
function image_ax_ButtonDownFcn(hObject, eventdata, handles)

if handles.calibrate, calGetPos(hObject,handles);end
if handles.show.lineOut, lineOutGetTarget(hObject,handles);end


% --- Executes on button press in profmonInit_btn.
function profmonInit_btn_Callback(hObject, eventdata, handles)

[name,is]=profmon_names(handles.PV);

btn=questdlg('Do you want to run the profmon_setup script?','profmon_setup','No');
if strcmp(btn,'Yes')
    if is.NLCTA
        profmon_setupNLCTA('camera',handles.PV,'gain',handles.gain,'expTime',handles.exposureTime, ...
            'xpixelbin', handles.xPixelBin, 'ypixelbin', handles.yPixelBin);
    else
        profmon_setup;
    end
end


% --- Executes on button press in showLineOut_box.
function showLineOut_box_Callback(hObject, eventdata, handles)

handles.show.lineOut=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in showColorbar_box.
function showColorbar_box_Callback(hObject, eventdata, handles)

handles.show.colorbar=get(hObject,'Value');
if handles.show.colorbar
    handles.colorbar=colorbar('peer',handles.image_ax);
elseif isfield(handles,'colorbar') && ishandle(handles.colorbar)
    delete(handles.colorbar);
end
guidata(hObject,handles);


% --- Executes on button press in showBG_box.
function showBG_box_Callback(hObject, eventdata, handles)

handles.show.bg=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% -----------------------------------------------------------
function lineOutGetTarget(hObject, handles)

pos=get(hObject,'CurrentPoint');target.x=pos(1,1);target.y=pos(1,2);
target.isRaw=handles.show.rawImg;target.units='pixel';
if handles.show.cal, target.units='mm';end
target=profmon_coordTrans(target,handles.data,'pixel');
target.x=ceil(target.x);target.y=ceil(target.y);
handles.show.target=target;
guidata(hObject,handles);
plot_image(hObject,handles);


% -----------------------------------------------------------
function handles=calUpdate(hObject, handles)

cal=handles.cal;
th=linspace(0,2*pi,1000);
x=cal.par(1)+cal.par(3)*cos(th)*cal.xcos;
y=cal.par(2)+cal.par(end)*sin(th)*cal.ycos;
if ~all(ishandle([handles.calib_circ handles.calib_line]))
    handles.calib_circ=line(NaN,NaN,'Parent',handles.image_ax,'Color','y', ...
        'LineStyle','--','HitTest','off');
    handles.calib_line=line(NaN,NaN,'Parent',handles.image_ax,'Color','r', ...
        'Marker','x','MarkerSize',10,'LineStyle','none','HitTest','off');
    guidata(hObject,handles);
end
set(handles.calib_circ,'XData',x,'YData',y);
set(handles.calib_line,'XData',cal.xPos,'YData',cal.yPos);
set(handles.calRad_txt,'String',num2str(cal.rad));
set(handles.calNFit_txt,'String',num2str(cal.nFit));
set(handles.calData_txt,'String',sprintf('X = %4.0f, Y = %4.0f, Res = %4.2f um/pixel',cal.par(1:2),cal.rad(1)/cal.par(3)));
drawnow;%pause(.3);
handles=guidata(hObject);


% --- Executes on button press in calibrate_box.
function calibrate_box_Callback(hObject, eventdata, handles)

handles.calibrate=get(hObject,'Value');
cal=handles.cal;
if ~isfield(handles,'data')
    set(hObject,'Value',0);handles.calibrate=0;cal.show=handles.show;
end
if handles.calibrate
    cal.isEllipse=0;
    cal.isVertical=get(handles.calIsVertical_box,'Value');
    cal.is45Deg=get(handles.calIsEllipse_box,'Value');
    cal.show=handles.show;
    handles.show.rawImg=1;
    handles.show.cal=0;
    handles.show.stats=0;
    handles.show.hist=0;
    handles.show.tcav=0;
    handles.show.ener=0;
    handles.show.lineOut=0;
    handles.show.bg=0;
    guidata(hObject,handles);
    data=handles.data;
    if ~data.isRaw, data=profmon_imgFlip(data);end
    cal.par=[data.centerX data.centerY cal.rad/data.res(1)];
    handles.cal=calGetPos0(cal);
    set(cal.hList,'Visible','on');
    guidata(hObject,handles);
    plot_image(hObject,handles);
else
    handles.show=cal.show;
%    set([handles.calib_line handles.calib_circ],'XData',NaN,'YData',NaN);
    set(cal.hList,'Visible','off');
    guidata(hObject,handles);
    plot_image(hObject,handles);
end


% --- Executes on button press in calReset_btn.
function calReset_btn_Callback(hObject, eventdata, handles)

data=handles.data;
cal=handles.cal;
if ~data.isRaw, data=profmon_imgFlip(data);end
cal.par=[data.centerX data.centerY cal.rad/data.res(1)];
handles.cal=calGetPos0(cal);
guidata(hObject,handles);
plot_image(hObject,handles);


% -----------------------------------------------------------
function calGetPos(hObject, handles)

cal=handles.cal;
pos=get(hObject,'CurrentPoint');
[d,id]=min((pos(1,1)-cal.xPos).^2+(pos(1,2)-cal.yPos).^2);
cal.xPos(id)=pos(1,1);
cal.yPos(id)=pos(1,2);
cal.par=round(util_circleFit(cal.xPos/cal.xcos,cal.yPos/cal.ycos,cal.isEllipse));
cal.par(1)=cal.par(1)*cal.xcos;
cal.par(2)=cal.par(2)*cal.ycos;
handles.cal=cal;
guidata(hObject,handles);
plot_image(hObject,handles);

 
% -----------------------------------------------------------
function cal = calGetPos0(cal)

ph=2*pi*(0:cal.nFit-1)/cal.nFit;
cal.xcos=cos((cal.is45Deg & ~cal.isVertical)*pi/4);
cal.ycos=cos((cal.is45Deg & cal.isVertical)*pi/4);
cal.xPos=cal.par(1)+cal.par(3)*cos(ph)*cal.xcos;
cal.yPos=cal.par(2)+cal.par(end)*sin(ph)*cal.ycos;


% -----------------------------------------------------------
function calRad_txt_Callback(hObject, eventdata, handles)

val=round(str2double(get(hObject,'String')));
if isnan(val)
    val=handles.cal.rad(1);
end
handles.cal.rad=val;
guidata(hObject,handles);
calUpdate(hObject,handles);


% --- Executes on button press in calApply_btn.
function calApply_btn_Callback(hObject, eventdata, handles)

pv=handles.data.name;
par=handles.cal.par;
par(3)=round(handles.cal.rad/par(3)*100)/100;
lcaPut(strcat(pv,':',[strcat({'X';'Y'},'_RTCL_CTR');'RESOLUTION']),par(:));
handles.data.centerX=par(1);
handles.data.centerY=par(2);
handles.data.res=par(3)*handles.data.res/handles.data.res(1);
guidata(hObject,handles);


% --- Executes on button press in calIsEllipse_box.
function calIsEllipse_box_Callback(hObject, eventdata, handles)

cal=handles.cal;
%cal.isEllipse=get(hObject,'Value');
cal.is45Deg=get(hObject,'Value');
%cal.par=round(util_circleFit(cal.xPos,cal.yPos,cal.isEllipse));
handles.cal=calGetPos0(cal);
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in calIsVertical_box.
function calIsVertical_box_Callback(hObject, eventdata, handles)

cal=handles.cal;
cal.isVertical=get(hObject,'Value');
%cal.par=round(util_circleFit(cal.xPos,cal.yPos,cal.isEllipse));
handles.cal=calGetPos0(cal);
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in calHelp_btn.
function calHelp_btn_Callback(hObject, eventdata, handles)

msgbox({'YAG diameter: 19.0 mm' 'OTR diameter: 22 mm' ...
        'OTR TCAV dia.: 17.5 mm' 'OTR33 hor: 10 mm, vert: 6 mm (inner)' ...
        'Width: 0.254 mm, Foil-Grid: 0.508 mm' ...
        'OTRDMP diameter: 38.735 mm' ...
        'Alpha dia: 37.6 mm' 'Image dia: 7.57 mm' ...
        'SYAG width: 10 mm' 'FACET OTR dia: 24.89 mm'}, ...
        'Calibration Tips');


% -----------------------------------------------------------
function calNFit_txt_Callback(hObject, eventdata, handles)

val=round(str2double(get(hObject,'String')));
if isnan(val)
    val=handles.cal.nFit;
end
cal=handles.cal;
cal.nFit=max(val,2);
handles.cal=calGetPos0(cal);
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in calZoom_box.
function calZoom_box_Callback(hObject, eventdata, handles)

zoomControl(hObject,handles,get(hObject,'Value'));


% --- Executes on button press in fullROI_btn.
function ROI_btn_Callback(hObject, eventdata, handles, val)

setROIControl(hObject,handles,val);


% --- Executes on button press in acquirestart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

acquireStart(hObject,handles);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles, val)

dataSave(hObject,handles,val);


% --- Executes on button press in dataOpen_btn.
function dataOpen_btn_Callback(hObject, eventdata, handles)

dataOpen(hObject,handles);


% --- Executes on button press in dataExport_btn.
function dataExport_btn_Callback(hObject, eventdata, handles, val)

dataExport(hObject,handles,val);


% --- Executes on button press in profIn_btn.
function profInOut_btn_Callback(hObject, eventdata, handles, val)

profmon_activate(handles.PV,val,1);


function nAverage_txt_Callback(hObject, eventdata, handles)

gui_editControl(hObject,handles,'nAverage',str2double(get(hObject,'String')),1,1,[0 1]);


% --- Executes on button press in zoomStats_box.
function zoomStats_box_Callback(hObject, eventdata, handles)

handles=gui_checkBoxControl(hObject,handles,'zoomStats',get(hObject,'Value'));
plot_image(hObject,handles);


% --- Executes on button press in showBM_box.
function showBM_box_Callback(hObject, eventdata, handles)

handles.show.bmCross=get(hObject,'Value');
guidata(hObject,handles);
plot_image(hObject,handles);


% --- Executes on button press in updateBM_btn.
function updateBM_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles,'data'), return, end
data=handles.data;
if handles.zoomStats
    data=imgCrop(hObject,handles);
end
beam=profmon_process(data,'useCal',1,'back',0,'method',1,'usemethod',handles.dataMethod.iVal,'doPlot',0);
lcaPutSmart(strcat(handles.data.name,{':X';':Y'},'_BM_CTR'),beam.stats(1:2)'*1e-3);
plot_image(hObject,handles);


% --- Executes on button press in filtSel_btn.
function filtSel_btn_Callback(hObject, eventdata, handles)

str={'F1' 'F2'};
val=get(handles.filtSel_btn,'Value');
set(handles.filtSel_btn,'String',str{val+1});


% --- Executes on button press in filtIn_btn.
function filtInOut_btn_Callback(hObject, eventdata, handles, val)

filtNum=get(handles.filtSel_btn,'Value')+1;
lcaPut([handles.PV ':FLT' num2str(filtNum) '_PNEU'],val);


% --- Executes on button press in lampSel_btn.
function lampSel_btn_Callback(hObject, eventdata, handles)

str=get(handles.lampSel_btn,'String');
val=get(handles.lampSel_btn,'Value');
strList={'T' 'G'};
if ~val, set(handles.lampSel_btn,'String',setdiff(strList,str));end
btnList={'On' 'Up';'Off' 'Dn'};
set([handles.lampOn_btn handles.lampOff_btn],{'String'},btnList(:,val+1));


% --- Executes on button press in lampOn_btn.
function lampOnOff_btn_Callback(hObject, eventdata, handles, val)

lampSel=strcmp(get(handles.lampSel_btn,'String'),'G');
lampFcn=get(handles.lampSel_btn,'Value');
val=val+lampFcn*(2*val-1);
profmon_lampSet(handles.PV,val,lampSel);


function profmonXSig_txt_Callback(hObject, eventdata, handles)

handles.profmonXSig=str2num(get(hObject,'String'));
handles.slice.plotSlice = 1;
guidata(hObject,handles);
plot_image(hObject,handles);


function profmonYSig_txt_Callback(hObject, eventdata, handles)

handles.profmonYSig=str2num(get(hObject,'String'));
handles.slice.plotSlice = 1;
guidata(hObject,handles);
plot_image(hObject,handles);


function handles=exposureTime_txt_Callback(hObject, eventdata, handles)

handles.exposureTime=str2num(get(hObject,'String'));
guidata(hObject,handles);


function handles=gain_txt_Callback(hObject, eventdata, handles)
handles.gain=str2num(get(hObject,'String'));
pv= strcat(handles.PV, ':GAIN');
lcaPut(pv, handles.gain)
guidata(hObject,handles);


% -----------------------------------------------------------
function handles=enableNLCTA(handles,val)

state={'off','on'};
set(handles.exposureTimeLabel_txt,'Visible',state{val+1})
set(handles.exposureTime_txt,'Visible',state{val+1})
set(handles.gainLabel_txt,'Visible',state{val+1})
set(handles.gain_txt,'Visible',state{val+1})
set(handles.xPixelBinLabel_txt,'Visible',state{val+1})
set(handles.xPixelBin_txt,'Visible',state{val+1})
set(handles.yPixelBinLabel_txt,'Visible',state{val+1})
set(handles.yPixelBin_txt,'Visible',state{val+1})
set(handles.gain_txt,'String',num2str(handles.gain));
set(handles.exposureTime_txt,'String',num2str(handles.exposureTime));
set(handles.xPixelBin_txt,'String',num2str(handles.xPixelBin));
set(handles.yPixelBin_txt,'String',num2str(handles.yPixelBin));


function xPixelBin_txt_Callback(hObject, eventdata, handles)

handles.xPixelBin=str2num(get(hObject,'String'));
guidata(hObject,handles);


function yPixelBin_txt_Callback(hObject, eventdata, handles)

handles.yPixelBin=str2num(get(hObject,'String'));
guidata(hObject,handles);


% --- Executes on button press in dataStream_box.
function dataStream_box_Callback(hObject, eventdata, handles)

handles.dataStream=get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in stats2log_btn.
function stats2log_btn_Callback(hObject, eventdata, handles)

if ~isfield(handles,'data') || ~ishandle(1), return, end
util_appFonts(1,'fontName','Times','lineWidth',1,'fontSize',14);
util_appPrintLog(1,'ProfMon Stats',handles.data.name,handles.data.ts);

if handles.slice.active == 1;
    util_appFonts(4,'fontName','Times','lineWidth',1,'fontSize',14);
    util_appPrintLog(4,'ProfMon Slice Stats',handles.data.name,handles.data.ts);
end
dataSave(hObject,handles,0);


% -----------------------------------------------------------
function handles = dataCurrentSliceControl(hObject, handles, jVal, nVal)

handles.slice.nVal = str2num(get(handles.numSlices_txt,'string')) + 1;
handles=gui_sliderControl(hObject,handles,'slice',jVal,nVal);
str=num2str(handles.slice.iVal-1);
if handles.slice.iVal == 1, str='Projected';end
handles.slice.sliceNumStr = str;
set(handles.slice_txt,'String',str);
guidata(hObject,handles);
handles = guidata(hObject);


% -----------------------------------------------------------
function handles = update_slice(hObject, handles)

opts.sliceBox = get(handles.sliceBox_box,'value');
opts.xsig = str2num(get(handles.profmonXSig_txt,'string'));
opts.ysig = str2num(get(handles.profmonYSig_txt,'string'));
if strcmp(handles.slice.Dir,'x')
    slice.Dir = 'y';
    opts.sliceWin = opts.xsig;
elseif strcmp(handles.slice.Dir,'y')
    slice.Dir = 'x';
    opts.sliceWin = opts.ysig;
end
handles = dataCurrentSliceControl(hObject,handles,round(get(handles.slice_sl,'Value')),[]);
guidata(hObject,handles);
opts.sliceDir = handles.slice.Dir;
opts.iSlice = handles.slice.iVal-1;
opts.nSlice = str2num(get(handles.numSlices_txt,'string'));
opts.usemethod = handles.dataMethod.iVal;
opts.useCal = handles.show.cal;
dataList = profmon_process(handles.data,opts);
beamList = permute(cat(3,dataList),[3 2 1]);

% now for gausian plot, figure 3
iSlice = handles.slice.iVal;
beam = beamList(1,1,iSlice);
set(handles.dataMethod_txt,'String',beam.method);
devName = handles.PV;
[ax, hFig] = util_plotInit('figure',3);
opts.axes = ax;
if handles.show.cal
    opts.xlab = [devName ' Position  (\mum)'];
else
    opts.xlab = [devName ' Position  (Pixels)'];
end
opts.title = ['Profile ' datestr(handles.data.ts) ' for slice ' handles.slice.sliceNumStr ' ' beam.method];
opts.figure = 3;
beamAnalysis_profilePlot(beam,slice.Dir,opts);
handles=guidata(hObject);

if handles.slice.plotSlice == 1;   
    opts.iSlice = [];
    opts.doPlot = 0;
    dataList=profmon_process(handles.data,opts);
    handles=guidata(hObject);
    beamList=permute(cat(3,dataList),[3 2 1]);
    beam=squeeze(beamList(1,1,:));
    if strcmp(handles.slice.Dir,'x')
        slice.Dir = 'y';
    elseif strcmp(handles.slice.Dir,'y')
        slice.Dir = 'x';
    end 
    sliceNum = str2num(get(handles.numSlices_txt,'string'));
    needed = beam(2:end);
%    checkSlice = logical([needed(1:sliceNum).checkSlice]);
    checkSlice=false(1,sliceNum);

    if get(handles.sliceProj_box,'value')
        for n = 1:sliceNum
            if checkSlice(n) == 0 
                grabProfiles = needed(n).(['prof' slice.Dir]);
                allProfiles(:,n) = grabProfiles(2,:)';
            end
        end
        k = max(allProfiles);
        k = repmat(ceil(max(k)),size(allProfiles,2),1);
        m = repmat(cumsum([0 k(1:end-1)'])',1,size(allProfiles,1))';
        allProfiles = flipud(allProfiles+m);

        [ax, hFig] = util_plotInit('figure',7);
        plot(ax,allProfiles,1:length(allProfiles),'b')
        axis(ax,[0 max(k)*size(allProfiles,2) 0 length(allProfiles)])
        set(ax,'XTick',allProfiles(1,:)');
        set(ax,'XTickLabel',{1:sliceNum});
        set(get(ax,'Xlabel'),'String','Slice Number');
        set(get(ax,'title'),'String',[datestr(handles.data.ts) 'Slice Projections']);
        
    end
    
    if handles.show.cal == 1
        cal = [0.000001 0.0010 1.0000];
    else
        cal = [1 1 1];
    end
    
    nums = reshape([needed.([slice.Dir 'Stat'])]',5,sliceNum);
    RMSVal = nums(3,:).*cal(3);
    AreaVal = nums(1,:).*cal(1);
    meanVal = nums(2,:).*cal(2);

    numsStd = reshape([needed.([slice.Dir 'StatStd'])]',5,sliceNum);
    RMSValStd = numsStd(3,:).*cal(3);
    AreaValStd = numsStd(1,:).*cal(1);
    meanValStd = numsStd(2,:).*cal(2);
    
    scale = ((1/mean(AreaVal))*mean(RMSVal));
    AreaValStd = scale*AreaValStd;
    AreaVal = scale*AreaVal;

    checkSlice=AreaVal/max(AreaVal) < 1e-6;
    if any(checkSlice)
        AreaVal(checkSlice) = 0 ;
        RMSVal(checkSlice) = 0 ;
        AreaValStd(checkSlice) = 0 ;
        RMSValStd(checkSlice) = 0 ;
        meanVal(checkSlice) = NaN ;
        meanValStd(checkSlice) = NaN ;
    end

    [ax, hFig] = util_plotInit('figure',4);
    cla(ax,'reset')
    
    [AX,H1,H2] = plotyyZoom(ax,1:sliceNum,meanVal,1:sliceNum,[AreaVal; RMSVal],'plot');

    set(get(AX(1),'Xlabel'),'String','Slice Number');
    set(get(AX(1),'title'),'String',[datestr(handles.data.ts) '  Slice Number vs Mean, RMS and Area']);

    hold(AX(1),'on');
    hold(AX(2),'on');
    errorbar(AX(1), 1:sliceNum,meanVal,meanValStd,'.-');
    a = errorbar(AX(2), 1:sliceNum,RMSVal,RMSValStd,'.-r');    
    b = errorbar(AX(2), 1:sliceNum,AreaVal,AreaValStd,'.-g');
    hold(AX(1),'off');
    hold(AX(2),'off');    
    
    if handles.show.cal == 1    
         set(get(AX(1),'Ylabel'),'String','Mean (mm)')
         set(get(AX(2),'Ylabel'),'String','RMS (um) and Area ()')
         legend(AX(1),'Mean (mm)','Location','NorthWest')
         legend([a b],'RMS (um)','Area ()','Location','NorthEast')  
    else
         set(get(AX(1),'Ylabel'),'String','Mean (Pixel)')
         set(get(AX(2),'Ylabel'),'String','RMS (Pixel) and Area ()')
         legend(AX(1),'Mean (Pixel)','Location','NorthWest')
         legend([a b],'RMS (Pixel)','Area ()','Location','NorthEast')
    end
    legend(AX(1),'boxoff')
    legend(AX(2),'boxoff')
end

set(handles.showStats_box, 'value', 0)
handles.slice.plotSlice = 0;
handles.show.stats = 0;
guidata(hObject,handles);


% --- Executes on slider movement.
function slice_sl_Callback(hObject, eventdata, handles)

update_slice(hObject, handles);


% --- Executes on button press in xplane_rbn.
function xplane_rbn_Callback(hObject, eventdata, handles)

handles.slice.Dir = 'y';
handles.slice.plotSlice = 1;
guidata(hObject,handles);
set(handles.xplane_rbn,'Value',1)
set(handles.yplane_rbn,'Value',0)
update_slice(hObject, handles);


% --- Executes on button press in yplane_rbn.
function yplane_rbn_Callback(hObject, eventdata, handles)

handles.slice.Dir = 'x';
handles.slice.plotSlice = 1;
guidata(hObject,handles);
set(handles.yplane_rbn,'Value',1)
set(handles.xplane_rbn,'Value',0)
update_slice(hObject, handles);


% --- Executes when numSlices_txt edit box is changed.
function handles = numSlices_txt_Callback(hObject, eventdata, handles)

val=str2num(get(handles.numSlices_txt,'string')) > 0;
str={'Off' 'On'};
set([handles.sliceBox_box handles.sliceProj_box handles.xplane_rbn handles.yplane_rbn ...
    handles.slice_sl handles.slice_txt handles.sliceLabel_txt],'Visible',str{val+1});
handles.slice.active = val;
handles.slice.plotSlice = val;
guidata(hObject,handles);
if val
    handles = dataCurrentSliceControl(hObject,handles,1,[]);
    update_slice(hObject, handles);
end


% --- Executes on button press in sliceProj_box.
function sliceProj_box_Callback(hObject, eventdata, handles)

handles.slice.plotSlice = 1;
update_slice(hObject, handles);


% --- Executes on button press in sliceBox_box.
function sliceBox_box_Callback(hObject, eventdata, handles)

handles.slice.plotSlice = 1;
update_slice(hObject, handles);


function profmon_optSet(handles)
if strcmp(handles.PV, 'YAGS:GUNB:753')
    set(handles.gain_txt,'Visible', 'on')
    set(handles.gainLabel_txt, 'Visible', 'on')
else
    set(handles.gain_txt,'Visible', 'off')
    set(handles.gainLabel_txt, 'Visible', 'off')
end




