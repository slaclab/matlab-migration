function varargout = orbit_response_full(varargin)
% ORBIT_RESPONSE_FULL M-file for orbit_response_full.fig
%      ORBIT_RESPONSE_FULL, by itself, creates a new ORBIT_RESPONSE_FULL or raises the existing
%      singleton*.
%
%      H = ORBIT_RESPONSE_FULL returns the handle to a new ORBIT_RESPONSE_FULL or the handle to
%      the existing singleton*.
%
%      ORBIT_RESPONSE_FULL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORBIT_RESPONSE_FULL.M with the given input arguments.
%
%      ORBIT_RESPONSE_FULL('Property','Value',...) creates a new ORBIT_RESPONSE_FULL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before orbit_response_full_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to orbit_response_full_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help orbit_response_full

% Last Modified by GUIDE v2.5 04-May-2011 10:58:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @orbit_response_full_OpeningFcn, ...
                   'gui_OutputFcn',  @orbit_response_full_OutputFcn, ...
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


% --- Executes just before orbit_response_full is made visible.
function orbit_response_full_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to orbit_response_full (see VARARGIN)

% Choose default command line output for orbit_response_full
handles.output = hObject;
handles=appInit(hObject,handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes orbit_response_full wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Executes when user attempts to close orbit_response_full_gui.
function orbit_response_full_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = orbit_response_full_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% -------------------------------------------------------------------------
function handles = appInit(hObject, handles)

% List of sector names
handles.sector.nameList={'IN20' 'LI21' 'LI22' 'LI23' 'LI24' 'LI25'... 
    'LI26' 'LI27' 'LI28' 'LI29' 'LI30' 'BSY0' 'LTU1' 'UND1' 'DMP1'};

regionList={'IN20:0:800' 'LI21' 'LI22' 'LI23' 'LI24' 'LI25' 'LI26' ...
    'LI27' 'LI28' 'LI29' 'LI30' 'BSY' {'LTU0' 'LTU1'} 'UND1:0:3390' 'DMP1'};

% BPM MAD names by sector
tagP='';
s=handles.sector;
for tag=[handles.sector.nameList;regionList]
    [names,id]=model_nameRegion({'BPMS' 'XCOR' 'YCOR'},tag{2},'type','MAD');
    s.(tag{1}).BPMMADList=names(id == 1)';
    s.(tag{1}).XCorMADList=names(id == 2)';
    s.(tag{1}).YCorMADList=names(id == 3)';
    if ~isempty(tagP)
        s.(tagP).BPMMADList=[s.(tagP).BPMMADList s.(tag{1}).BPMMADList];
    end
    tagP=tag{1};
end
handles.sector=s;

%{
handles.sector.IN20.BPMMADList={ ...
    'BPM2' 'BPM3' 'BPM5' 'BPM6' ...
    'BPM8' 'BPM9' 'BPM10' 'BPM11' 'BPM12' ...
    'BPM13' 'BPM14' 'BPM15'};% 'BPMG1' 'BPMS1' 'BPMS2' 'BPMS3'};
handles.sector.LI21.BPMMADList={ ...
    'BPMA11' 'BPMA12' 'BPM21201' 'BPMS11' 'BPMM12' 'BPM21301' 'BPMM14' ...
    'BPM21401' 'BPM21501' 'BPM21601' 'BPM21701' 'BPM21801' 'BPM21901'};
handles.sector.LI22.BPMMADList={ ...
    'BPM22201' 'BPM22301' 'BPM22401' 'BPM22501' ...
    'BPM22601' 'BPM22701' 'BPM22801' 'BPM22901'};
handles.sector.LI23.BPMMADList={ ...
    'BPM23201' 'BPM23301' 'BPM23401' 'BPM23501' ...
    'BPM23601' 'BPM23701' 'BPM23801' 'BPM23901'};
handles.sector.LI24.BPMMADList={ ...
    'BPM24201' 'BPM24301' 'BPM24401' 'BPM24501' ...
    'BPM24601' 'BPM24701' 'BPMS21' 'BPM24901'};
handles.sector.LI25.BPMMADList={ ...
    'BPM25201' 'BPM25601' 'BPM25701' 'BPM25801' 'BPM25901'};
handles.sector.LI26.BPMMADList={ ...
    'BPM26201' 'BPM26301' 'BPM26401' 'BPM26501' 'BPM26601' 'BPM26701'...
    'BPM26801' 'BPM26901'};
handles.sector.LI27.BPMMADList={ ...
    'BPM27301' 'BPM27401' 'BPM27701' 'BPM27801'};
handles.sector.LI28.BPMMADList={ ...
    'BPM28301' 'BPM28401' 'BPM28601' 'BPM28701' 'BPM28801' 'BPM28901'};
handles.sector.LI29.BPMMADList={ ...
    'BPM29201' 'BPM29301' 'BPM29401' 'BPM29501' 'BPM29601' 'BPM29701'...
    'BPM29801' 'BPM29901'};
handles.sector.LI30.BPMMADList={ ...
    'BPM30201' 'BPM30301' 'BPM30401' 'BPM30501' 'BPM30601' 'BPM30701'...
    'BPM30801'};
handles.sector.BSY0.BPMMADList={ ...
    'BPMBSY1' 'BPMBSY29' 'BPMBSY39' 'BPMBSY61' 'BPMBSY63' 'BPMBSY83'...
    'BPMBSY85' 'BPMBSY88' 'BPMBSY92'};
handles.sector.LTU1.BPMMADList={ ...
    'BPMVM1' 'BPMVM2' 'BPMVB1' 'BPMVB2' 'BPMVB3' ...
    'BPMVM3' 'BPMVM4' 'BPMDL1' 'BPMT12' 'BPMDL2'...
    'BPMT22'  'BPMDL3' 'BPMT32' 'BPMDL4' 'BPMT42' ...
    'BPMEM1' 'BPMEM2' 'BPMEM3' 'BPMEM4' ...
    'BPME31' 'BPME32' 'BPME33' 'BPME34' 'BPME35' 'BPME36'...
    'BPMUM1' 'BPMUM2' 'BPMUM3' 'BPMUM4' 'RFB07' 'RFB08'};
handles.sector.UND1.BPMMADList= ...
    strcat({'RFBU'},num2str((1:33)','%02d'))';
handles.sector.DMP1.BPMMADList={ ...
    'BPMUE1' 'BPMUE2' 'BPMUE3' 'BPMQD' 'BPMDD'};
handles.sector.IN20.BPMMADList=[handles.sector.IN20.BPMMADList handles.sector.LI21.BPMMADList];
handles.sector.LI21.BPMMADList=[handles.sector.LI21.BPMMADList handles.sector.LI22.BPMMADList];
handles.sector.LI22.BPMMADList=[handles.sector.LI22.BPMMADList handles.sector.LI23.BPMMADList];
handles.sector.LI23.BPMMADList=[handles.sector.LI23.BPMMADList handles.sector.LI24.BPMMADList];
handles.sector.LI24.BPMMADList=[handles.sector.LI24.BPMMADList handles.sector.LI25.BPMMADList];
handles.sector.LI25.BPMMADList=[handles.sector.LI25.BPMMADList handles.sector.LI26.BPMMADList];
handles.sector.LI26.BPMMADList=[handles.sector.LI26.BPMMADList handles.sector.LI27.BPMMADList];
handles.sector.LI27.BPMMADList=[handles.sector.LI27.BPMMADList handles.sector.LI28.BPMMADList];
handles.sector.LI28.BPMMADList=[handles.sector.LI28.BPMMADList handles.sector.LI29.BPMMADList];
handles.sector.LI29.BPMMADList=[handles.sector.LI29.BPMMADList handles.sector.LI30.BPMMADList];
handles.sector.LI30.BPMMADList=[handles.sector.LI30.BPMMADList handles.sector.BSY0.BPMMADList];
handles.sector.BSY0.BPMMADList=[handles.sector.BSY0.BPMMADList handles.sector.LTU1.BPMMADList];
handles.sector.LTU1.BPMMADList=[handles.sector.LTU1.BPMMADList handles.sector.UND1.BPMMADList];

% XCor MAD names by sector
handles.sector.IN20.XCorMADList={ ...
    'XC00' 'XC01' 'XC02' 'XC03' 'XC04' 'XC05' 'XC06' 'XC07' ...
    'XC08' 'XC09' 'XC10'};% 'XCS1' 'XCS2' 'XCG1' 'XCG2'};
handles.sector.LI21.XCorMADList={ ...
    'XC11' 'XCA11' 'XCA12' 'XCM11' 'XCM13' 'XC21302' 'XCM14' };
handles.sector.LI22.XCorMADList={ ...
    'XC22202' 'XC22302' 'XC22402' 'XC22502' 'XC22602' 'XC22702' ...
    'XC22802' 'XC22900'};
handles.sector.LI23.XCorMADList={ ...
    'XC23202' 'XC23302' 'XC23402' 'XC23502' 'XC23602' 'XC23702' ...
    'XC23802' 'XC23900'};
handles.sector.LI24.XCorMADList={ ...
    'XC24202' 'XC24302' 'XC24402' 'XC24502' 'XC24602' 'XC24702' ...
    'XC24900'};
handles.sector.LI25.XCorMADList={ ...
    'XC25202' 'XC25302' 'XC25402' 'XC25502' 'XC25602' 'XC25702' ...
    'XC25802' 'XC25900'};
handles.sector.LI26.XCorMADList={ ...
    'XC26202' 'XC26302' 'XC26402' 'XC26502' 'XC26602' 'XC26702' ...
    'XC26802' 'XC26900'};
handles.sector.LI27.XCorMADList={ ...
    'XC27202' 'XC27302' 'XC27402' 'XC27502' 'XC27602' 'XC27702' ...
    'XC27802' 'XC27900'};
handles.sector.LI28.XCorMADList={ ...
    'XC28202' 'XC28302' 'XC28402' 'XC28502' 'XC28602' 'XC28702' ...
    'XC28802' 'XC28900'};
handles.sector.LI29.XCorMADList={ ...
    'XC29202' 'XC29302' 'XC29402' 'XC29502' 'XC29602' 'XC29702' ...
    'XC29802' 'XC29900'};
handles.sector.LI30.XCorMADList={ ...
    'XC30202' 'XC30302' 'XC30402' 'XC30502' 'XC30602' 'XC30702' ...
    'XC30802' 'XC30900'};
handles.sector.BSY0.XCorMADList={ ...
    'XCBSY09' 'XCBSY26' 'XCBSY34' 'XCBSY36' 'XCBSY60' 'XCBSY81' ...
    'XC6' 'XCA0'};
handles.sector.LTU1.XCorMADList={ ...
    'XCVM2' 'XCVM3' 'XCDL1' 'XCQT12' 'XCDL2' ...
    'XCQT22' 'XCDL3' 'XCQT32' 'XCDL4' 'XCQT42' 'XCEM2' ...
    'XCEM4' 'XCE31' 'XCE33' 'XCE35'};% 'XCCUM1' 'XCCUM4'};
handles.sector.UND1.XCorMADList= ...
    strcat({'XCU'},num2str((1:33)','%02d'))';
handles.sector.DMP1.XCorMADList={ ...
    'XCUE1' 'XCD3' 'XCDD'};

% YCor MAD names by sector
handles.sector.IN20.YCorMADList={ ...
    'YC00' 'YC01' 'YC02' 'YC03' 'YC04' 'YC05' 'YC06' 'YC07' ...
    'YC08' 'YC09' 'YC10'};% 'YCS1' 'YCS2' 'YCG1' 'YCG2'};
handles.sector.LI21.YCorMADList={ ...
    'YC11' 'YCA11' 'YCA12' 'YCM11' 'YCM12'  'YC21303' 'YCM15'};
handles.sector.LI22.YCorMADList={ ...
    'YC22203' 'YC22303' 'YC22403' 'YC22503' 'YC22603' 'YC22703' ...
    'YC22803' 'YC22900'};
handles.sector.LI23.YCorMADList={ ...
    'YC23203' 'YC23303' 'YC23403' 'YC23503' 'YC23603' 'YC23703' ...
    'YC23803' 'YC23900'};
handles.sector.LI24.YCorMADList={ ...
    'YC24203' 'YC24303' 'YC24403' 'YC24503' 'YC24603' 'YC24703' ...
    'YC24900'};
handles.sector.LI25.YCorMADList={ ...
    'YC25203' 'YC25303' 'YC25403' 'YC25503' 'YC25603' 'YC25703' ...
    'YC25803' 'YC25900'};
handles.sector.LI26.YCorMADList={ ...
    'YC26203' 'YC26303' 'YC26403' 'YC26503' 'YC26603' 'YC26703' ...
    'YC26803' 'YC26900'};
handles.sector.LI27.YCorMADList={ ...
    'YC27203' 'YC27303' 'YC27403' 'YC27503' 'YC27603' 'YC27703' ...
    'YC27803' 'YC27900'};
handles.sector.LI28.YCorMADList={ ...
    'YC28203' 'YC28303' 'YC28403' 'YC28503' 'YC28603' 'YC28703' ...
    'YC28803' 'YC28900'};
handles.sector.LI29.YCorMADList={ ...
    'YC29203' 'YC29303' 'YC29403' 'YC29503' 'YC29603' 'YC29703' ...
    'YC29803' 'YC29900'};
handles.sector.LI30.YCorMADList={ ...
    'YC30203' 'YC30303' 'YC30403' 'YC30503' 'YC30603' 'YC30703' ...
    'YC30803' 'YC30900'};
handles.sector.BSY0.YCorMADList={ ...
    'YCBSY10' 'YCBSY27' 'YCBSY35' 'YCBSY37' 'YCBSY62' 'YCBSY82' ...
    'YC5' 'YCA0'};
handles.sector.LTU1.YCorMADList={ ...
    'YCVM1' 'YCVB1' 'YCVB3' 'YCVM4' 'YCDL1' 'YCQT12' 'YCDL2' ...
    'YCQT22' 'YCDL3' 'YCQT32' 'YCDL4' 'YCQT42' 'YCEM1' ...
    'YCEM3' 'YCE32' 'YCE34' 'YCE36'};% 'YCCUM2' 'YCCUM3'};
handles.sector.UND1.YCorMADList= ...
    strcat({'YCU'},num2str((1:33)','%02d'))';
handles.sector.DMP1.YCorMADList={ ...
    'YCUE2' 'YCD3' 'YCDD'};
%}

% Devices to use and data initialization for each sector
 for tag=handles.sector.nameList
     sector=handles.sector.(tag{:});
     sector.BPMDevList=model_nameConvert(sector.BPMMADList,'EPICS');
     sector.XCorDevList=model_nameConvert(sector.XCorMADList,'EPICS');
     sector.YCorDevList=model_nameConvert(sector.YCorMADList,'EPICS');
     num=length(sector.XCorDevList);
     [sector.data(1:num,1:2).status]=deal(false);
     [sector.ref(1:num,1:2).status]=deal(false);
     handles.sector.(tag{:})=sector;
 end
handles.pathname=0;
handles.sectorSel='LTU1';
handles.corrSel='YCVM1';
handles.scaleFactor=1.0;
handles.fdBacks=control_fbNames;
set(handles.Plot_lbx,'Value',3);
set(handles.YCorr_lbx,'Value',1);
h_wait_ax=handles.waitbar_axes;set(h_wait_ax,'Visible','Off');
h_wait_txt=handles.waitbar_txt;set(h_wait_txt,'String','Ready ...');
set(handles.scanMax_txt,'String','0.5');
set(handles.scanSteps_txt,'String','9');
set(handles.scanShots_txt,'String','100');
set(handles.scanDelay_txt,'String','0.1');
guidata(hObject,handles);
util_appFonts(hObject,'fontName','Helvetica','lineWidth',1,'fontSize',10,'markerSize',13);
handles=sectorInit(hObject,handles,[]);


% --- Executes on button press in printLog_btn.
function printLog_btn_Callback(hObject, eventdata, handles)

sector=handles.sector.(handles.sectorSel);corr=handles.corrSel;
XCOR=~isempty(strfind(corr, 'XCOR'));
if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
else
    corr_idx=get(handles.YCorr_lbx,'Value');
end
handles.exportFig=figure;
axes;box on
ax=handles.plotRaw_ax;
% axes(ax);
copyobj(get(ax,'Children'),gca);
tag={'XLabel' 'YLabel' 'Title'};
h=copyobj(cell2mat(get(ax,tag)),gca);set(gca,tag,num2cell(h'));
if (isfield(sector.data(corr_idx,~XCOR+1),'text_strings')) && ~isempty(sector.data(corr_idx,~XCOR+1).text_strings)
    legend(sector.data(corr_idx,~XCOR+1).text_strings, 'Location','Best');
end
util_appFonts(handles.exportFig,'fontName','Times','lineWidth',1,'fontSize',14);
if ~epicsSimul_status
    util_printLog(handles.exportFig,'title',['Orbit Response ' handles.sectorSel]);
    dataSave(hObject,handles,0);
end


% --- Executes on selection change in XCorr_lbx.
function XCorr_lbx_Callback(hObject, eventdata, handles)

corrList=get(hObject,'String');
handles.corrSel=corrList{get(hObject,'Value')};
guidata(hObject,handles);
plotUpdate(hObject, handles);


% --- Executes on selection change in YCorr_lbx.
function YCorr_lbx_Callback(hObject, eventdata, handles)

corrList=get(hObject,'String');
handles.corrSel=corrList{get(hObject,'Value')};
guidata(hObject,handles);
plotUpdate(hObject, handles);


% --- Executes on selection change in Plot_lbx.
function Plot_lbx_Callback(hObject, eventdata, handles)

plotUpdate(hObject, handles);


% --- Executes on selection change in BPM_lbx.
function BPM_lbx_Callback(hObject, eventdata, handles)

dir=get(handles.dir_pmu,'Value');
sector=handles.sector.(handles.sectorSel);

bpm2plotind=get(handles.BPM_lbx,'Value');
corr=handles.corrSel;
XCOR=~isempty(strfind(corr, 'XCOR'));
if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
else
    corr_idx=get(handles.YCorr_lbx,'Value');
end

if ~any(sector.data(corr_idx,~XCOR+1).status) return, end;
orbitx=sector.data(corr_idx,~XCOR+1).orbitx;
orbity=sector.data(corr_idx,~XCOR+1).orbity;
sigmax=sector.data(corr_idx,~XCOR+1).sigmax;
sigmay=sector.data(corr_idx,~XCOR+1).sigmay;
kicks=sector.data(corr_idx,~XCOR+1).kicks;
corr=sector.data(corr_idx,~XCOR+1).corrname;
bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
corrZ=sector.data(corr_idx,~XCOR+1).corrZ;
ind=find(bpmZpos>corrZ,1,'first');
bpmList=get(handles.BPM_lbx,'String');
ax=handles.plotRaw_ax;
axes(ax);
if bpm2plotind<ind
    cla
    return
end
if dir == 1

    if XCOR
        h_bpm(1) = errorbar(ax,1000*kicks', 1000*orbitx(:,bpm2plotind)  ,sigmax(:,bpm2plotind),'.-b','Parent',ax);
        hold on
        grid on
        p = polyfit(1000*kicks', 1000*orbitx(:,bpm2plotind),1);
        cc=corrcoef(polyval(p,1000*kicks'),1000*orbitx(:,bpm2plotind));
        RSquared=cc(2).^2;
        ylabel(ax,'horz. orbit [mm]');
    else
        h_bpm(1) = errorbar(ax,1000*kicks', 1000*orbity(:,bpm2plotind),sigmay(:,bpm2plotind),'.-b');
        hold on
        grid on
        p = polyfit(1000*kicks', 1000*orbity(:,bpm2plotind),1);
        cc=corrcoef(polyval(p,1000*kicks'),1000*orbity(:,bpm2plotind));
        RSquared=cc(2).^2;
        ylabel(ax,'vert. orbit [mm]');
    end
    h_bpm(2) = plot(ax,1000*kicks',polyval(p,1000*kicks'),'-k','Parent',ax);
    hold off
    [legend_h,object_h,plot_h,sector.data(corr_idx,~XCOR+1).text_strings]=...
        legend(ax,'data points',sprintf('linear fit, slope=%g\n R^2=%g',p(1),RSquared),'Location','Best');
    xlabel(ax,'corrector kick [mrad]')
    corrector_label = corr;
    title(ax,sprintf('Orbit at %s as a function of %s strength',bpmList{bpm2plotind},corrector_label) )
else
        
    if ~XCOR
        h_bpm(1) = errorbar(ax,1000*kicks', 1000*orbitx(:,bpm2plotind)  ,sigmax(:,bpm2plotind),'.-b','Parent',ax);
        hold on
        grid on
        p = polyfit(1000*kicks', 1000*orbitx(:,bpm2plotind),1);
        cc=corrcoef(polyval(p,1000*kicks'),1000*orbitx(:,bpm2plotind));
        RSquared=cc(2).^2;
        ylabel(ax,'horz. orbit [mm]');
    else
        h_bpm(1) = errorbar(ax,1000*kicks', 1000*orbity(:,bpm2plotind),sigmay(:,bpm2plotind),'.-b');
        hold on
        grid on
        p = polyfit(1000*kicks', 1000*orbity(:,bpm2plotind),1);
        cc=corrcoef(polyval(p,1000*kicks'),1000*orbity(:,bpm2plotind));
        RSquared=cc(2).^2;
        ylabel(ax,'vert. orbit [mm]');
    end
    h_bpm(2) = plot(ax,1000*kicks',polyval(p,1000*kicks'),'-k','Parent',ax);
    hold off
    [legend_h,object_h,plot_h,sector.data(corr_idx,~XCOR+1).text_strings]= ...
        legend(ax,'data points',sprintf('linear fit, slope=%g\n R^2=%g',p(1),RSquared),'Location','Best');
    xlabel(ax,'corrector kick [mrad]')
    corrector_label = corr;
    title(ax,sprintf('Orbit at %s as a function of %s strength',bpmList{bpm2plotind},corrector_label) )
end
1000*kicks';
handles.sector.(handles.sectorSel)=sector;     
guidata(hObject,handles);


% --- Executes on selection change in dir_pmu.
function dir_pmu_Callback(hObject, eventdata, handles)

plotUpdate(hObject, handles);


% --- Executes on button press in dataSave_btn.
function dataSave_btn_Callback(hObject, eventdata, handles)

dataSave(hObject,handles,1)


% ------------------------------------------------------------------------
function dataSave(hObject, handles, val)

ts=now;
sector=handles.sector.(handles.sectorSel);
data=sector.data;
if ~any([data.status]), return, end
fileName=util_dataSave(data,'OrbitResponse_data_',handles.sectorSel,ts,val);
if ~ischar(fileName), return, end
handles.fileName=fileName;
guidata(hObject,handles);


% --- Executes on button press in dataLoad_btn.
function dataLoad_btn_Callback(hObject, eventdata, handles)

[data, fileName, pathName]=util_dataLoad('Open orbit response data file',handles.pathname);
handles.pathname=pathName;
if ~ischar(fileName), return, end
handles.fileName=fileName;
sector=handles.sector.(handles.sectorSel);
% Put data in handles.

for tag=fieldnames(data)'
    idx=find([data.status]);
%     [sector.data.(tag{:})]=deal(data.(tag{:}));
        [sector.data(idx).(tag{:})]=deal(data(idx).(tag{:}));
end
handles.sector.(handles.sectorSel)=sector;
plotUpdate(hObject, handles);
guidata(hObject,handles);


% --- Executes on button press in refSave_btn.
function refSave_btn_Callback(hObject, eventdata, handles)

ts=now;
sector=handles.sector.(handles.sectorSel);
ref=sector.data;
sector.ref=ref;
if ~any([ref.status]), return, end
fileName=util_dataSave(ref,'OrbitResponse_ref_',handles.sectorSel,ts,1);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.sector.(handles.sectorSel).ref=ref;
guidata(hObject,handles);


% --- Executes on button press in refLoad_btn.
function refLoad_btn_Callback(hObject, eventdata, handles)

[data, fileName, pathName]=util_dataLoad('Open orbit response reference file',handles.pathname);
handles.pathname=pathName;
if ~ischar(fileName), return, end
handles.fileName=fileName;
sector=handles.sector.(handles.sectorSel);
% Put reference in handles.
sector.ref=data;
sector.status=true;
handles.sector.(handles.sectorSel)=sector;
plotUpdate(hObject, handles);
guidata(hObject,handles);


%-------------------------------------------------------------------------
function handles=acquireStart(hObject,handles)

% Set running or return if already running.
if gui_acquireStatusSet(hObject,handles,1);return, end
sector=handles.sector.(handles.sectorSel);
% turn off all feedbacks
handles.origFdbkState=lcaGetSmart(handles.fdBacks,0,'double');
lcaPutSmart(handles.fdBacks,0);
%READ initial corrector strengths and limits
pvlist_corrx=strcat(sector.XCorDevList',':BACT');
pvlist_lim_corrx=strcat(sector.XCorDevList',':BACT.HOPR');
pvlist_corry=strcat(sector.YCorDevList',':BACT');
pvlist_lim_corry=strcat(sector.YCorDevList',':BACT.HOPR');
ini_currx = lcaGet(pvlist_corrx)';
ini_curry = lcaGet(pvlist_corry)';

lim_corrx = lcaGet(pvlist_lim_corrx)';
lim_corry = lcaGet(pvlist_lim_corry)';

%Read repetition rate
[sys,accelerator]=getSystem();
pv = ['EVNT:' sys ':1:' accelerator 'BEAMRATE'];
rep = lcaGet(pv, 0, 'double');
% 
       
%Change corrector strengths and record the data
set(gcbo, 'BackgroundColor','y');
pause(.1);
corr=handles.corrSel;
bpmList=get(handles.BPM_lbx,'String');
XCOR=~isempty(strfind(corr, 'XCOR'));
en_corr=model_rMatGet(corr,[],[],'EN');
%Calculate maximum kick for the currently chosen corrector  
[max_kick, bpmZpos, corrZ]=get_corrector_field(handles);

max_field = max_kick*10*3.3356*en_corr;

if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
    curr0=ini_currx(corr_idx);
    lim=lim_corrx;
else
    corr_idx=get(handles.YCorr_lbx,'Value');
    curr0=ini_curry(corr_idx);
    lim=lim_corry;
end
handles.initCurr = curr0;
guidata(hObject,handles);
ini_curr=handles.initCurr;
sector.data(corr_idx,~XCOR+1).corrname=corr;
sector.data(corr_idx,~XCOR+1).corr_idx=corr_idx;
sector.data(corr_idx,~XCOR+1).status=true;
sector.data(corr_idx,~XCOR+1).bpmList=bpmList;
sector.data(corr_idx,~XCOR+1).bpmZpos=bpmZpos;
sector.data(corr_idx,~XCOR+1).corrZ=corrZ;

%response from the model
rMat=model_rMatGet(corr,bpmList);
if XCOR
    or_t=rMat(1,2,:);
    or_t=or_t(:);
else
    or_t=rMat(3,4,:);
    or_t=or_t(:);
end
sector.data(corr_idx,~XCOR+1).ort=or_t./1000;

% %check limits
if (ini_curr+max_field)>=lim(corr_idx)
    if (ini_curr-max_field)<=(-lim(corr_idx))
%         uiwait(msgbox('Not possible to generate such an orbit change','Warning message!','Warn'))
        if abs(lim(end)-ini_curr)>=abs(-lim(corr_idx)-ini_curr)
            max_field=lim(corr_idx)-ini_curr;
        else
            max_field=-lim(corr_idx)-ini_curr;
        end
    else
        max_field=-max_field;
    end
end
% kick calculated  for each step
nsteps=str2double(get(handles.scanSteps_txt,'String'));
nSamps=str2double(get(handles.scanShots_txt,'String'));
samp_delay=str2double(get(handles.scanDelay_txt,'String'));
field=max_field/nsteps;
fields = ini_curr:field:(ini_curr+max_field);
scale=handles.scaleFactor;
kicks=1000*fields*scale/(10*3.3356*en_corr);
sector.data(corr_idx,~XCOR+1).kicks=kicks;

% Apply kicks to correctors and measure response
for j=1:(nsteps+1)
    if ~gui_acquireStatusGet(hObject,handles), break, end
    if j > 1
        %adding current to the steerer
        str=sprintf('Changing Corrector Strength: %7.4f',fields(j));
        disp(str)
        update_waitbar(handles,j/(nsteps+1),str)
        if ~epicsSimul_status
            setCorr(handles,fields(j));
        end
    end

    % Now using my measure_orbit function to get orbit data
    if epicsSimul_status && 0
        data = corrscan_simulScan(sector.data(corr_idx,~XCOR+1),kicks(j),scale);
        orbitx(j,:)=data.bpmXData';
        sigmax(j,:)=data.bpmXSigma';
        orbity(j,:)=data.bpmYData';
        sigmay(j,:)=data.bpmYSigma';
    else
        [orbitx(j,:),sigmax(j,:),orbity(j,:),sigmay(j,:)]...
            = measure_orbit(bpmList,nSamps,samp_delay);
    end

end %Done with changing corrector and measuring orbit.

% Going back to the initial current value
if ~epicsSimul_status
    setCorr(handles,handles.initCurr);
end
restored_val=lcaGet([corr ':BACT'],0,'double')
str='Restored Corrector Strength';
display(str);
update_waitbar(handles,0,str)
lcaPutSmart(handles.fdBacks,handles.origFdbkState); % restore feedbacks

if gui_acquireStatusGet(hObject,handles)
    [orx,sigma_orx,rsq_orx,ory,sigma_ory,rsq_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks,bpmList);

    sector.data(corr_idx,~XCOR+1).orbitx=orbitx;
    sector.data(corr_idx,~XCOR+1).orbity=orbity;
    sector.data(corr_idx,~XCOR+1).sigmax=sigmax;
    sector.data(corr_idx,~XCOR+1).sigmay=sigmay;
    sector.data(corr_idx,~XCOR+1).orx=orx;
    sector.data(corr_idx,~XCOR+1).ory=ory;
    sector.data(corr_idx,~XCOR+1).sigma_orx=sigma_orx;
    sector.data(corr_idx,~XCOR+1).sigma_ory=sigma_ory;
    sector.data(corr_idx,~XCOR+1).rsq_orx=rsq_orx;
    sector.data(corr_idx,~XCOR+1).rsq_ory=rsq_ory;
    handles.sector.(handles.sectorSel)=sector;
    guidata(hObject,handles);
end

% Finish up
display('Done with measurement')   
set(gcbo, 'BackgroundColor','g');
gui_acquireStatusSet(hObject,handles,0);
plotUpdate(hObject, handles);


% --- Executes on button press in energyProf_btn.
function energyProf_btn_Callback(hObject, eventdata, handles)

corrList=handles.sector.(handles.sectorSel).XCorDevList;
[rMat, zPos, lEff, twiss, energy]=model_rMatGet(corrList);
ax=handles.plotRaw_ax;
axes(ax);
plot(ax,zPos,energy,'Parent',ax);
grid on
title(ax,'Beam Energy Profile');
xlabel(ax,'s [m]');
ylabel(ax,'Energy [GeV]');


% --- Executes on button press in sectorSel<name>_btn.
function sectorSel_btn_Callback(hObject, eventdata, handles, tag, modifier)

% if strcmp(modifier,'control') | strcmp(modifier,'shift')
%     tag=[handles.sectorSel;tag]
% end
sectorInit(hObject,handles,tag);


% ------------------------------------------------------------------------
function handles = sectorInit(hObject, handles, name)

handles=gui_radioBtnControl(hObject,handles,'sectorSel',name,1,'_btn');
sector=handles.sector.(handles.sectorSel);
set(handles.BPM_lbx,'String',sector.BPMDevList,'Value',1);
set(handles.XCorr_lbx,'String',sector.XCorDevList,'Value',1);
set(handles.YCorr_lbx,'String',sector.YCorDevList,'Value',1);
handles.corrSel=sector.YCorDevList{1};
guidata(hObject,handles);


% Calculates max allowable kick ------------------------------------------
function [max_kick,bpmZPos,corrZ]=get_corrector_field(handles)

max_bpm_diff=str2double(get(handles.scanMax_txt,'String'));
bpmList=get(handles.BPM_lbx,'String');
corr=handles.corrSel;
bpmZPos=model_rMatGet(bpmList,corr,[],'Z');
[rMat, corrZPos]=model_rMatGet(corr,bpmList);
kick=ones(1,length(bpmList))*9e99;
corrZ=corrZPos(1);
ind=find(bpmZPos>corrZ);
if strfind(corr, 'XCOR')
    kick(ind)=abs(max_bpm_diff*1e-3/rMat(1,2,ind));
else
    kick(ind)=abs(max_bpm_diff*1e-3/rMat(3,4,ind));
end
max_kick = abs(min(kick));


% ------------------------------------------------------------------------
function handles = plotUpdate(hObject, handles, hold_on)

if nargin<3, hold_on=0; end
ax=handles.plotRaw_ax;
axes(ax);
if (~hold_on)
cla;
end
if get(handles.plotLabels_box,'Value')==1;
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','on','Enable','on');
    set(dcm_obj, 'Update', @(obj, event_obj) myupdatefcn(handles, event_obj));
end
if get(handles.plotZoom_box,'Value')==1;
    zoom on
end
sector=handles.sector.(handles.sectorSel);
corr=handles.corrSel;
XCOR=~isempty(strfind(corr, 'XCOR'));
if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
else
    corr_idx=get(handles.YCorr_lbx,'Value');
end

if ~any(sector.data(corr_idx,~XCOR+1).status) && ...
        ~any(sector.ref(corr_idx,~XCOR+1).status), return, end;

if any(sector.data(corr_idx,~XCOR+1).status);
    bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
    corrZ=sector.data(corr_idx,~XCOR+1).corrZ;
else
    bpmZpos=sector.ref(corr_idx,~XCOR+1).bpmZpos;
    corrZ=sector.ref(corr_idx,~XCOR+1).corrZ;
end
dir=get(handles.dir_pmu,'Value');
orx=[];ory=[];

%***********
bpmList=sector.data(corr_idx,~XCOR+1).bpmList;
orbitx=sector.data(corr_idx,~XCOR+1).orbitx;
orbity=sector.data(corr_idx,~XCOR+1).orbity;
sigmax=sector.data(corr_idx,~XCOR+1).sigmax;
sigmay=sector.data(corr_idx,~XCOR+1).sigmay;
kicks=sector.data(corr_idx,~XCOR+1).kicks;
% [orx_c, ory_c]= bpm_corr(orbitx,sigmax,orbity,sigmay,kicks,bpmList);
%response from the model
% param=get_start; % commented out jjw 4/13/16
% param=no_rotscale;
% rMat=model_rMatGet_jr(corr,bpmList,{},'',param);
rMat=model_rMatGet(corr,bpmList);
% rMat=model_rMatGet_fit(corr,bpmList,get_start);
if XCOR
    or_t=rMat(1,2,:);
    or_t=or_t(:);
    ort_c=or_t./1000;
else
    or_t=rMat(3,4,:);
    or_t=or_t(:);
    ort_c=or_t./1000;
end
%****************
% ort=sector.data(corr_idx,~XCOR+1).ort;
% gx=0.7074;
% angle=0;

% datac = corrscan_simulScan_fit(sector.data(corr_idx,~XCOR+1), ort, kicks, gx, angle, param);
% orbitxc=datac.bpmXData';
% sigmaxc=datac.bpmXSigma';
% orbityc=datac.bpmYData';
% sigmayc=datac.bpmYSigma';
% [orxc,sigma_orxc,rsq_orxc,oryc,sigma_oryc,rsq_oryc]=get_orm(orbitxc,sigmaxc,orbityc,sigmayc,kicks,bpmList);
                
if any(sector.data(corr_idx,~XCOR+1).status);
    orx=sector.data(corr_idx,~XCOR+1).orx;
    ory=sector.data(corr_idx,~XCOR+1).ory;
    if (dir-1)
        ort=zeros(size(ory));
%         ort_c=ort;
    else
        ort=sector.data(corr_idx,~XCOR+1).ort';
    end
end
orx_ref=[];ory_ref=[];
if any(sector.ref(corr_idx,~XCOR+1).status);
    orx_ref=sector.ref(corr_idx,~XCOR+1).orx;
    ory_ref=sector.ref(corr_idx,~XCOR+1).ory;
end
% factors=get_start;
orx_c=orx;
ory_c=ory;

if dir-1 == 0
    if XCOR
        orm =orx;
%          ort_c =ort.*factors(corr_idx,2);
%          ort_c =orx;
        orm_c=orx_c;
        orm_ref=orx_ref;
    else
        orm= ory;
%          ort_c= ort.*factors(17+corr_idx,3);
%          ort_c= ory;
        orm_c=ory_c;
        orm_ref=ory_ref;
    end
else
    if XCOR
        orm = ory;
%         ort_c= ory_c;
%         ort_c= ory;
        orm_c=ory_c;
        orm_ref=ory_ref;
    else
        orm = orx;
%         ort_c =orx_c;
%         ort_c =orx;
        orm_c=orx_c;
        orm_ref=orx_ref;
    end
end
plot_type=get(handles.Plot_lbx,'Value');

ind=find(bpmZpos>corrZ);
switch plot_type
    case 1 %plot measurement
        if isempty(orm) return; end;
        plot(ax,bpmZpos(ind),1000*orm(ind),'-r*','MarkerSize',4,'Parent',ax)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Orbit response to ' corr ' (normal)'];
        else
            plot_title = ...
                ['Orbit response to ' corr ' (skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        sector.data(corr_idx,~XCOR+1).text_strings='Measured';
    case 2 %plot model
        if isempty(ort) return; end;
        plot(ax,bpmZpos(ind),1000*ort(ind),'-bs','MarkerSize',4,'Parent',ax)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Orbit response to ' corr ' (normal)'];
        else
            plot_title = ...
                ['Orbit response to ' corr ' (skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        sector.data(corr_idx,~XCOR+1).text_strings='Model';
    case 3 %plot measurement and model
        if isempty(orm) return; end;
        plot(ax,bpmZpos(ind),1000*orm(ind),'-r*','MarkerSize',4,'Parent',ax)
        hold on
        plot(ax,bpmZpos(ind),1000*ort(ind),'-bs','MarkerSize',4,'Parent',ax)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Orbit response to ' corr ' (normal)'];
        else
            plot_title = ...
                ['Orbit response to ' corr ' (skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        [legend_h,object_h,plot_h,sector.data(corr_idx,~XCOR+1).text_strings]=legend(ax,'Measured','Model', 'Location','Best');
        hold off
    case 4 % plot Measurement - Model
        if isempty(ort) return; end;
        if isempty(orm) return; end;
        if hold_on
            hold on
        end
        plot(ax,bpmZpos(ind),1000*(orm(ind) - ort(ind)),'*g','MarkerSize',4)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Measured - Model response to ' corr '(normal)'];
        else
            plot_title = ...
                ['Measured - Model response to ' corr '(skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        sector.data(corr_idx,~XCOR+1).text_strings='';
        
%         hold off
    case 5 % plot Measurement - Reference
        if isempty(orm_ref) return; end;
        if isempty(orm) return; end;
        plot(ax,bpmZpos(ind),1000*(orm(ind) - orm_ref(ind)),'-ko','MarkerSize',4)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Measured - Reference response to ' corr '(normal)'];
        else
            plot_title = ...
                ['Measured - Reference response to ' corr '(skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        sector.data(corr_idx,~XCOR+1).text_strings='';
    case 6 % plot Reference response
        if isempty(orm_ref) return; end;
        plot(ax,bpmZpos(ind),1000*orm_ref(ind),'-ko','MarkerSize',4)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Reference response to ' corr '(normal)'];
        else
            plot_title = ...
                ['Reference response to ' corr '(skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        sector.data(corr_idx,~XCOR+1).text_strings='';
    case 7 %plot measurement, corrected measurement, and model
        if isempty(orm) return; end;
        plot(ax,bpmZpos(ind),1000*orm_c(ind),'-r*','MarkerSize',4,'Parent',ax)
        hold on
        plot(ax,bpmZpos(ind),1000*ort_c(ind),'-g*','MarkerSize',4,'Parent',ax)
        plot(ax,bpmZpos(ind),1000*ort(ind),'-bs','MarkerSize',4,'Parent',ax)
        grid on;
        xlabel(ax,'s [m]')
        ylabel(ax,'Orbit Response [mm/mrad]')
        if dir-1 == 0
            plot_title = ...
                ['Orbit response to ' corr ' (normal)'];
        else
            plot_title = ...
                ['Orbit response to ' corr ' (skew)'];
        end
        title(ax,plot_title)
        set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
        [legend_h,object_h,plot_h,sector.data(corr_idx,~XCOR+1).text_strings]=legend(ax,'Measured', 'Model (corr)','Model (orig)', 'Location','Best');
        hold off
        old_err=sum((orm_c(ind)-ort(ind)).^2)
        new_err=sum((orm_c(ind)-ort_c(ind)').^2)
end
handles.sector.(handles.sectorSel)=sector;     
guidata(hObject,handles);


% ------------------------------------------------------------------------
function [orx,sigma_orx,rsq_orx,ory,sigma_ory,rsq_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks,all_bpm_EPICS )

for j=1:length(all_bpm_EPICS)
    px(j,:) = polyfit(kicks(:), orbitx(:,j),1);
    ccx=corrcoef(polyval(px(j,:),kicks(:)),orbitx(:,j));
    rsq_orx(j)=ccx(2).^2;
    py(j,:) = polyfit(kicks(:), orbity(:,j),1);
    ccy=corrcoef(polyval(py(j,:),kicks(:)),orbity(:,j));
    rsq_ory(j)=ccy(2).^2;
    for i=1:length(kicks)
        Sc(i)=1/(sigmax(i,j)^2);
        Sxc(i)=kicks(i)/(sigmax(i,j)^2);
        Syc(i)=orbitx(i)/(sigmax(i,j)^2);
        Sxxc(i)=kicks(i)^2/(sigmax(i,j)^2);
        Sxyc(i)=kicks(i)*orbitx(i,j)/(sigmax(i,j)^2);
    end
    S(j)=sum(Sc);
    Sx(j)=sum(Sxc);
    Sy(j)=sum(Syc);
    Sxx(j)=sum(Sxxc);
    Sxy(j)=sum(Sxyc);
    deno(j)=S(j)*Sxx(j)-Sx(j)*Sx(j);
    sigma_a2x(j)=Sxx(j)/deno(j);
    sigma_b2x(j)=S(j)/deno(j);
    %the same in y
    for i=1:length(kicks)
        Sc(i)=1/(sigmay(i,j)^2);
        Sxc(i)=kicks(i)/(sigmay(i,j)^2);
        Syc(i)=orbity(i)/(sigmay(i,j)^2);
        Sxxc(i)=kicks(i)^2/(sigmay(i,j)^2);
        Sxyc(i)=kicks(i)*orbity(i,j)/(sigmay(i,j)^2);
    end
    Sy(j)=sum(Syc);
    Sxy(j)=sum(Sxyc);
    sigma_a2y(j)=Sxx(j)/deno(j);
    sigma_b2y(j)=S(j)/deno(j);
end

orx=px(:,1)';
ory=py(:,1)';
sigma_orx=sigma_b2x;
sigma_ory=sigma_b2y;


% -----------------------------------------------------------------------
function update_waitbar(handles,value,string)

h_wait_txt=handles.waitbar_txt;set(h_wait_txt,'String',string);
h_wait_ax=handles.waitbar_axes;set(h_wait_ax,'Visible','On');
axes(h_wait_ax);cla;h_wait_ax=patch([0,value,value,0],[0,0,1,1],'r');
axis([0,1,0,1]);axis off;drawnow;


% --- Executes on button press in GOF_cbx.
function GOF_cbx_Callback(hObject, eventdata, handles)

ax=handles.plotRaw_ax;
axes(ax);
cla;
zoom on
sector=handles.sector.(handles.sectorSel);
corr=handles.corrSel;
XCOR=~isempty(strfind(corr, 'XCOR'));
if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
else
    corr_idx=get(handles.YCorr_lbx,'Value');
end

if any(sector.data(corr_idx,~XCOR+1).status);
    bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
    corrZ=sector.data(corr_idx,~XCOR+1).corrZ;
end
dir=get(handles.dir_pmu,'Value');
if ~isfield(sector.data(corr_idx,~XCOR+1),'rsq_orx');
    orbitx=sector.data(corr_idx,~XCOR+1).orbitx;
    orbity=sector.data(corr_idx,~XCOR+1).orbity;
    sigmax=sector.data(corr_idx,~XCOR+1).sigmax;
    sigmay=sector.data(corr_idx,~XCOR+1).sigmay;
    kicks=sector.data(corr_idx,~XCOR+1).kicks;
    corr=sector.data(corr_idx,~XCOR+1).corrname;
    bpmList=sector.data(corr_idx,~XCOR+1).bpmList;
    bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
    [orx,sigma_orx,rsq_orx,ory,sigma_ory,rsq_ory]=get_orm(orbitx,sigmax,orbity,sigmay,kicks,bpmList);
else
    if any(sector.data(corr_idx,~XCOR+1).status);
        rsq_orx=sector.data(corr_idx,~XCOR+1).rsq_orx;
        rsq_ory=sector.data(corr_idx,~XCOR+1).rsq_ory;
    end
end
if dir-1 == 0
    if XCOR
        rsq =rsq_orx;
    else
        rsq= rsq_ory;
    end
else
    if XCOR
        rsq = rsq_ory;
    else
        rsq = rsq_orx;
    end
end

ind=find(bpmZpos>corrZ);

if isempty(rsq), return; end;
plot(ax,bpmZpos(ind),rsq(ind),'-r*','MarkerSize',4,'Parent',ax)
grid on;
xlabel(ax,'s [m]')
ylabel(ax,'R squared')
if dir-1 == 0
    plot_title = ...
        'BPM Fit R Squared (normal)';
else
    plot_title = ...
        'BPM Fit R Squared (skew)';
end
title(ax,plot_title)
set(ax,'XLim',[bpmZpos(1) bpmZpos(end)])
sector.data(corr_idx,~XCOR+1).text_strings='R squared';


% --- Executes on button press in scatter_btn.
function scatter_btn_Callback(hObject, eventdata, handles)

set(handles.Plot_lbx,'Value',4);
sector=handles.sector.(handles.sectorSel);
for idx=1:length(sector.XCorDevList)
    handles.corrSel=sector.XCorDevList{idx};
    set(handles.XCorr_lbx,'Value',idx);
    guidata(hObject, handles);
    plotUpdate(hObject, handles, 1);
%     k = waitforbuttonpress;
end
for idx=1:length(sector.YCorDevList)
    handles.corrSel=sector.YCorDevList{idx};
    set(handles.YCorr_lbx,'Value',idx);
    guidata(hObject, handles);
    plotUpdate(hObject, handles, 1);
%     k = waitforbuttonpress;
end


% --- Executes on button press in bpmskew_btn.
function bpmskew_btn_Callback(hObject, eventdata, handles)

dir=get(handles.dir_pmu,'Value');
sector=handles.sector.(handles.sectorSel);

bpm2plotind=get(handles.BPM_lbx,'Value');
corr=handles.corrSel;
XCOR=~isempty(strfind(corr, 'XCOR'));
if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
else
    corr_idx=get(handles.YCorr_lbx,'Value');
end

if ~any(sector.data(corr_idx,~XCOR+1).status) return, end;
orbitx=sector.data(corr_idx,~XCOR+1).orbitx;
orbity=sector.data(corr_idx,~XCOR+1).orbity;
bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
corrZ=sector.data(corr_idx,~XCOR+1).corrZ;
ind=find(bpmZpos>corrZ,1,'first');
bpmList=get(handles.BPM_lbx,'String');
ax=handles.plotRaw_ax;
axes(ax);
if bpm2plotind<ind
    cla
    return
end
idx=bpm2plotind;
% for idx=1:length(bpmList)
        plot(ax,1000*orbity(:,idx),1000*orbitx(:,idx),'*b','Parent',ax);
        hold on
        grid on
        p = polyfit(1000*orbity(:,idx),1000*orbitx(:,idx),1);
        cc=corrcoef(polyval(p,1000*orbity(:,idx)),1000*orbitx(:,idx));
        RSquared=cc(2).^2;
        ylabel(ax,'horz. orbit [mm]');
        plot(ax,1000*orbity(:,idx),polyval(p,1000*orbity(:,idx)),'-k','Parent',ax);
    hold off
%     [legend_h,object_h,plot_h,sector.data(corr_idx,~XCOR+1).text_strings]=...
        legend(ax,'data points',sprintf('linear fit, slope=%g\n R^2=%g',p(1),RSquared),'Location','Best');
%         disp(sprintf('%s\t%g\t%g',bpmList{idx,:},p(1),RSquared))
        disp(sprintf('%g\t%g\t',1000*orbitx(:,idx),1000*orbity(:,idx)))
        pause(1)
%     xlabel(ax,'corrector kick [mrad]')
%     corrector_label = corr;
%     title(ax,sprintf('Orbit at %s as a function of %s strength',bpmList{bpm2plotind},corrector_label) )
%  k = waitforbuttonpress;
% end
handles.sector.(handles.sectorSel)=sector;     
guidata(hObject,handles);


% --- Executes on button press in fitModel_btn.
function fitModel_btn_Callback(hObject, eventdata, handles)

sector=handles.sector.(handles.sectorSel);
yorb=[];xorb=[];
for idx=1:length(sector.XCorDevList)
% for idx=1:1
    handles.corrSel=sector.XCorDevList{idx};
    set(handles.XCorr_lbx,'Value',idx);
    corr=handles.corrSel;
    XCOR=~isempty(strfind(corr, 'XCOR'));
    corr_idx=get(handles.XCorr_lbx,'Value');
    bpmList=get(handles.BPM_lbx,'String');
%     rMat=model_rMatGet(corr,bpmList);
%     or_t=rMat;
% %     or_t=or_t(:);
%     sector.data(corr_idx,~XCOR+1).ort=or_t;
    for bpm_idx=1:length(sector.BPMDevList)
        set(handles.BPM_lbx,'Value',bpm_idx);
        bpm_ind=get(handles.BPM_lbx,'Value');
        bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
        corrZ=sector.data(corr_idx,~XCOR+1).corrZ;
        if (idx==2)||(idx==4)||(idx==6)||(bpmZpos(bpm_ind)<corrZ)
%         if (bpmZpos(bpm_ind)<corrZ)
        else
            xorb=[xorb;sector.data(corr_idx,~XCOR+1).orbitx(:,bpm_ind)];
            yorb=[yorb;sector.data(corr_idx,~XCOR+1).orbity(:,bpm_ind)];
            ort=sector.data(corr_idx,~XCOR+1).ort;
            kicks=sector.data(corr_idx,~XCOR+1).kicks;
        end
    end
end
for idx=1:length(sector.YCorDevList)
% %  for idx=1:8
    handles.corrSel=sector.YCorDevList{idx};
    set(handles.YCorr_lbx,'Value',idx);
    corr=handles.corrSel;
    XCOR=~isempty(strfind(corr, 'XCOR'));
    corr_idx=get(handles.YCorr_lbx,'Value');
    bpmList=get(handles.BPM_lbx,'String');
%     rMat=model_rMatGet(corr,bpmList);
%     or_t=rMat;
% %     or_t=or_t(:);
%     sector.data(corr_idx,~XCOR+1).ort=or_t;
    for bpm_idx=1:length(sector.BPMDevList)
        set(handles.BPM_lbx,'Value',bpm_idx);
        bpm_ind=get(handles.BPM_lbx,'Value');
        bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
        corrZ=sector.data(corr_idx,~XCOR+1).corrZ;
        if (idx==2)||(idx==4)||(idx==6)||(bpmZpos(bpm_ind)<corrZ)
        else
            xorb=[xorb;sector.data(corr_idx,~XCOR+1).orbitx(:,bpm_ind)];
            yorb=[yorb;sector.data(corr_idx,~XCOR+1).orbity(:,bpm_ind)];
            ort=sector.data(corr_idx,~XCOR+1).ort;
            kicks=sector.data(corr_idx,~XCOR+1).kicks;
        end
    end
end
[estimates, model] = fitfullmodel(xorb, yorb, sector)


%{
function [orx_c, ory_c]= bpm_corr(orbitx,sigmax,orbity,sigmay,kicks,bpmList)

bpm_corr_vals=[5.72E-09	1	1
2.47E-08	1	1
1.65E-07	1.00002	1
3.10E-07	1.00003	1
3.37E-07	0.999959	1
2.20E-07	0.999952	1
1.20E-07	1.00034	1
-4.91E-01	1	1
3.10E-06	0.999905	1.00002
-9.18E-07	0.999915	1.00001
-5.23E-06	0.999819	1.00003
4.91E-01	0.867	0.867
8.21E-06	1.00022	1.00002
1.19E-06	1.00022	0.999984
-5.36E-06	0.999755	0.999924
-6.17E-06	0.999772	0.999896
-2.32E-06	0.999716	1
7.58E-06	0.999714	0.999381
9.59E-06	1.00225	0.999771
2.42E-06	1.00218	0.999859
-5.01E-07	0.997205	0.999736
1.46E-05	0.997221	0.999945
3.55E-05	1.00204	1.00002
5.40E-05	1.00209	1.00004
5.32E-05	1.00021	1.00002
4.05E-05	1.00022	0.999954
-1.45E-05	0.993741	0.999816
-1.12E-05	0.993886	0.999895
-1.77E-05	1.00835	0.999969
-2.55E-05	1.00842	0.99995
-1.84E-05	0.993379	0.999956
0   1   1
0   1   1
0   1   1
0   1   1
0   1   1
0   1   1
];
[orbitxc,orbityc] = rot_scale(orbitx,orbity,bpm_corr_vals);
[orx_c,sigma_orx,rsq_orx,ory_c,sigma_ory,rsq_ory]=get_orm(orbitxc,sigmax,orbityc,sigmay,kicks,bpmList);
%}


%{
function [xc,yc] = rot_scale(x,y,param)

gx=param(:,2);
gy=param(:,3);
angle=param(:,1);
for bpm_idx=1:length(x);
    for k_idx=1:10
        val=[cos(angle(bpm_idx)) -sin(angle(bpm_idx));sin(angle(bpm_idx)) cos(angle(bpm_idx))]*[gx(bpm_idx).*x(k_idx,(bpm_idx));gy(bpm_idx).*y(k_idx,(bpm_idx))];
        xc(k_idx,bpm_idx)=val(1);
        yc(k_idx,bpm_idx)=val(2);
    end
end
%}


% -------------------------------------------------------------------------
function txt = myupdatefcn(handles,event_obj)

pos = get(event_obj,'Position');
sector=handles.sector.(handles.sectorSel);
corr=handles.corrSel;
XCOR=~isempty(strfind(corr, 'XCOR'));
if XCOR
    corr_idx=get(handles.XCorr_lbx,'Value');
else
    corr_idx=get(handles.YCorr_lbx,'Value');
end
bpmList=sector.data(corr_idx,~XCOR+1).bpmList;
bpmZpos=sector.data(corr_idx,~XCOR+1).bpmZpos;
idx=find(bpmZpos==pos(1));
txt = {['Z: ',num2str(pos(1))],...
	[bpmList{idx}]};


% --- Executes on button press in plotZoom_box.
function plotZoom_box_Callback(hObject, eventdata, handles)

set(handles.plotLabels_box,'Value',0);
ax=handles.plotRaw_ax;
axes(ax);
if get(handles.plotZoom_box,'Value')==1;
    zoom on
else
    zoom off
end


% --- Executes on button press in plotLabels_box.
function plotLabels_box_Callback(hObject, eventdata, handles)

set(handles.plotZoom_box,'Value',0);
ax=handles.plotRaw_ax;
axes(ax);
if get(handles.plotLabels_box,'Value')==1;
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','on','Enable','on');
    set(dcm_obj, 'Update', @(obj, event_obj) myupdatefcn(handles, event_obj));
else
    datacursormode off;
end


% --- Executes on button press in dataFitAll_box.
function dataFitAll_box_Callback(hObject, eventdata, handles)


% --- Executes on button press in dataFitCorr_box.
function dataFitCorr_box_Callback(hObject, eventdata, handles)


% --- Executes on button press in scanScaled_box.
function scanScaled_box_Callback(hObject, eventdata, handles)


% --- Executes on button press in acquireStart_btn.
function acquireStart_btn_Callback(hObject, eventdata, handles)

set(hObject,'Value',~get(hObject,'Value'));
acquireStart(hObject,handles);


% --- Executes on button press in acquireAbort_btn.
function acquireAbort_btn_Callback(hObject, eventdata, handles)

acquireAbort(hObject,handles);


% -------------------------------------------------------------------------
function handles = acquireAbort(hObject, handles)

gui_acquireAbortAll;


% -------------------------------------------------------------------------
function handles= setCorr(handles,val)

corr=handles.corrSel;
lcaPut([corr ':BCTRL'],val);
pause (.5);
status=2; loop_ctr=0;
while status >1 && loop_ctr<5
    lcaPut([corr ':BCTRL'],val);
    pause (.1);
    status=lcaGet([corr ':BACT.SEVR'],0,'double');
    loop_ctr=loop_ctr+1;
end
     

function scaleFactor_Callback(hObject, eventdata, handles)

handles.scaleFactor=str2double(get(hObject,'String'));
guidata(hObject,handles);


%{
% -------------------------------------------------------------------------
function output= get_start

output=[0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
0	1	1
];
%}
