    function varargout = CVS_CVCRCI(varargin)
% CVS_CVCRCI MATLAB code for CVS_CVCRCI.fig
%      CVS_CVCRCI, by itself, creates a new CVS_CVCRCI or raises the existing
%      singleton*.
%
%      H = CVS_CVCRCI returns the handle to a new CVS_CVCRCI or the handle to
%      the existing singleton*.
%
%      CVS_CVCRCI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVS_CVCRCI.M with the given input arguments.
%
%      CVS_CVCRCI('Property','Value',...) creates a new CVS_CVCRCI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVS_CVCRCI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVS_CVCRCI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVS_CVCRCI

% Last Modified by GUIDE v2.5 01-Oct-2014 11:37:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVS_CVCRCI_OpeningFcn, ...
                   'gui_OutputFcn',  @CVS_CVCRCI_OutputFcn, ...
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


% --- Executes just before CVS_CVCRCI is made visible.
function CVS_CVCRCI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVS_CVCRCI (see VARARGIN)

% Choose default command line output for CVS_CVCRCI
handles.output = hObject;
set(handles.ReleaseeDefs,'Userdata',[]);
set(handles.uipanel1,'visible','on');
set(handles.CodeVariablesPanel,'visible','off');
handles.ColorON=[0,1,0];
handles.ColorIdle=get(handles.EditPvLists,'backgroundcolor');
handles.ColorWait=[1,1,0];
handles.ConfigurationsPath=[pwd,'/MGConfigurations'];

% CustomAnalysis=dir([pwd,'/CustomAnalysis/*.m']); Does NOT copy custom
% analysis from custom analysis folder
handles.CustomAnalysisList{1}='This is not the full version, no custom analysis!';
% handles.CustomAnalysisList{1}='No more processing.. it''s already slow enough';
% handles.FunctionAnalysisListHandles={};
% for II=1:numel(CustomAnalysis)
%     COPIA=1;
%     if(length(CustomAnalysis(II).name)>6)
%         if(strcmpi(CustomAnalysis(II).name(1:6),'CVCRCI'))
%             COPIA=0;
%         end
%     end
%     if(COPIA)        
%         handles.CustomAnalysisList{end+1}=CustomAnalysis(II).name;
%         copyfile([pwd,'/CustomAnalysis/',CustomAnalysis(II).name], pwd,'f')
%         handles.FunctionAnalysisListHandles{end+1}=eval(['@',CustomAnalysis(II).name(1:(end-2))]);
%     end
% end

handles.OutVariablesNumber=7;
handles.ProfileProcessNumber=4;
handles.NumberOfAvailableFilters=3;
handles.NumberOfAvailableSignals=3;
handles.NumberOfOnTheFlyVariables=6;
handles.TSandPulseIds=2;
handles.FiguresList=[];
handles.ChildrenSorting=[];
handles.extGui=0;
handles.pauseSXRSS=[];

set(handles.Start3,'Backgroundcolor',handles.ColorON);
set(handles.Stop3,'Backgroundcolor',handles.ColorIdle);
set(handles.Stop3,'Enable','off');

handles.BufferCounterName{1}='SIOC:SYS0:ML02:AO312';
handles.BufferCounterName{2}='SIOC:SYS0:ML02:AO313';

handles.PV(1).name='SIOC:SYS0:ML02:AO314';
handles.PV(2).name='SIOC:SYS0:ML02:AO315';
handles.PV(3).name='SIOC:SYS0:ML02:AO316';
handles.PV(4).name='SIOC:SYS0:ML02:AO317';
handles.PV(5).name='SIOC:SYS0:ML02:AO318';
handles.PV(6).name='SIOC:SYS0:ML02:AO319';
handles.PV(7).name='SIOC:SYS0:ML02:AO320';

handles.PV(1).what='description - ';
handles.PV(2).what='description - ';
handles.PV(3).what='description - ';
handles.PV(4).what='description - ';
handles.PV(5).what='description - ';
handles.PV(6).what='description - ';
handles.PV(7).what='description - ';

handles.FilterNames{1}='Filter 1'; handles.FilterNames{2}='Filter 2'; handles.FilterNames{3}='Filter 3';
handles.SignalNames{1}='Signal 1'; handles.SignalNames{2}='Signal 2'; handles.SignalNames{3}='Signal 3';

handles.PVlist{1}='GDET:FEE1:241:ENRC';
%handles.PVlist{2}='BPMS:LTU1:250:X';
%handles.PVlist{1}='';
%handles.PVlist{2}='';

handles.NotSynchPV{1}='SXR:MON:MMS:05.RBV';

ProfList{2}='SXR Spectrometer Projections'; ProfList{3}='SXR Spectrometer Sliced Image';
ProfList{4}='SXR Spectrometer Spatial Profile'; ProfList{1}='DISABLE';
ProfList{5}='FEE HXR Projections'; ProfList{6}='FEE HXR Sliced Image';
ProfList{7}='MEC Spectrometer Projection'; ProfList{8}='CXI Spectrometer Projection';
ProfList{9}='Direct Imager WFOV';

set(handles.ProfileMonitorMenu,'String',ProfList)

for II=1:handles.OutVariablesNumber
   eval(['set(handles.w',char(48+II),',''string'',[handles.PV(II).what,handles.PV(II).name])']) 
end

handles.Signal(1).Code{1}='CodeOutput=sum(FirstProfile(%1:%2,:));';
handles.Signal(2).Code{1}='CodeOutput=sum(FirstProfile(%3:%4,:));';
handles.Signal(3).Code{1}='CodeOutput=sum(FirstProfile(%5:%6,:));';

handles.Out(1).Code{1}='CodeOutput=0;';
handles.Out(2).Code{1}='CodeOutput=0;';
handles.Out(3).Code{1}='CodeOutput=0;';
handles.Out(4).Code{1}='CodeOutput=0;';
handles.Out(5).Code{1}='CodeOutput=0;';
handles.Out(6).Code{1}='CodeOutput=0;';
handles.Out(7).Code{1}='CodeOutput=0;';

handles.Filter(1).Code{1}='!1=length(#12);';
handles.Filter(1).Code{2}='CodeOutput=1:!1;';
handles.Filter(2).Code{1}='!1=length(#12);';
handles.Filter(2).Code{2}='CodeOutput=1:!1;';
handles.Filter(3).Code{1}='!1=length(#12);';
handles.Filter(3).Code{2}='CodeOutput=1:!1;';

handles.FullPVList=JimTurnerOpeningFunctionBSA_gui(handles);
[handles.FullPVList.fp,handles.FullPVList.sp,handles.FullPVList.tp,handles.FullPVList.qp]=read_pv_names(handles.FullPVList.root_name)

handles=NaClO_Callback(hObject, eventdata, handles);
% 
% set(handles.dialogotrasordi,'string','el. stored');
% set(handles.dia_text_rec,'string','0');
set(handles.CominciaModalitaSchiavo,'UserData',0);
set(handles.Update_Figures_Cont,'UserData',0);
set(handles.NaClOBackground,'enable','off')
set(handles.PvSyncList,'String',handles.PVlist);
set(handles.PvNotSyncList,'String',handles.NotSynchPV);
handles.BaseLineX{1}='OFF';
handles.BaseLineY{1}='OFF';
handles.FiltersList{1}='Filter Off';
handles.FiguresList=[];
handles.ChildrenSorting=[];
handles.BackgroundBlock=[];
set(handles.PvlistPanel,'visible','off')
set(handles.CVCRCIISSA,'UserData',{handles.BaseLineX,handles.BaseLineY,handles.FiltersList,handles.FiguresList,handles.ChildrenSorting});
guidata(hObject, handles);
ProfileMonitorMenu_Callback(hObject, eventdata, handles)
update_figure_list(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVS_CVCRCI wait for user response (see UIRESUME)
% uiwait(handles.CVS_CVCRCI);


% --- Outputs from this function are returned to the command line.
function varargout = CVS_CVCRCI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function [fp,sp,tp,qp]=read_pv_names(ROOTNAME)
fp={};
sp={};
tp={};
qp={};
NPV=numel(ROOTNAME);
for II=1:NPV
   breaks=find(ROOTNAME{II}==':'); 
   p1=ROOTNAME{II}(1:(breaks(1)-1)); 
   p2=ROOTNAME{II}((breaks(1)+1):(breaks(2)-1)); 
   p3=ROOTNAME{II}((breaks(2)+1):(breaks(3)-1)); 
   p4=ROOTNAME{II}((breaks(3)+1):end); 
%    if(~any(strcmpi(p1,fp)))
        fp{end+1}=p1;
%    end
%    if(~any(strcmpi(p2,sp)))
        sp{end+1}=p2;
%    end
%    if(~any(strcmpi(p3,tp)))
        tp{end+1}=p3;
%    end
%    if(~any(strcmpi(p4,qp)))
        qp{end+1}=p4;
%    end
   
end

function FullPVList=JimTurnerOpeningFunctionBSA_gui(handles)

handles.new_model = 1;
handles.TOOT_NAME={'PATT:SYS0:1:NSEC',...
'PATT:SYS0:1:SEC',...
'PATT:SYS0:1:PULSEID',...
'IOC:IN20:MC01:LCLSBEAMRATE',...
'IOC:IN20:BP01:QANN',...
'LASR:IN20:196:PWR',...             %Laser
'LASR:IN20:475:PWR',...             %Laser Heater
'LASR:IN20:1:P',...
'LASR:IN20:1:A',...
'GUN:IN20:1:P',...                  %Gun
'GUN:IN20:1:A',...
'FARC:IN20:212:CHRG',...
'FARC:IN20:898:CHRG',...            %Gun Spectrometer
'TORO:IN20:215:TMIT',...
'BPMS:IN20:821:X',...
'BPMS:IN20:821:Y',...
'BPMS:IN20:821:TMIT',...
'BPMS:IN20:221:X',...
'BPMS:IN20:221:Y',...
'BPMS:IN20:221:TMIT',...
'BPMS:IN20:235:X',...
'BPMS:IN20:235:Y',...
'BPMS:IN20:235:TMIT',...
'ACCL:IN20:300:L0A_P',...           %L0A RF
'ACCL:IN20:300:L0A_A',...
'PCAV:IN20:365:P',...               %Phase Monitor
'PCAV:IN20:365:A',...
'BPMS:IN20:371:X',...
'BPMS:IN20:371:Y',...
'BPMS:IN20:371:TMIT',...
'ACCL:IN20:400:L0B_P',...           %L0B RF
'ACCL:IN20:400:L0B_A',...
'BPMS:IN20:425:X',...
'BPMS:IN20:425:Y',...
'BPMS:IN20:425:TMIT',...
'TORO:IN20:431:TMIT',...
'TCAV:IN20:490:P',...               %TCAV0
'TCAV:IN20:490:A',...
'BPMS:IN20:511:X',...
'BPMS:IN20:511:Y',...
'BPMS:IN20:511:TMIT',...
'BPMS:IN20:525:X',...
'BPMS:IN20:525:Y',...
'BPMS:IN20:525:TMIT',...
'WIRE:IN20:531:POSN',...            %WS01
'WIRE:IN20:531:MASK',...
'WIRE:IN20:561:POSN',...            %WS02
'WIRE:IN20:561:MASK',...
'BPMS:IN20:581:X',...
'BPMS:IN20:581:Y',...
'BPMS:IN20:581:TMIT',...
'WIRE:IN20:611:POSN',...            %WS03
'WIRE:IN20:611:MASK',...
'BPMS:IN20:631:X',...
'BPMS:IN20:631:Y',...
'BPMS:IN20:631:TMIT',...
'BPMS:IN20:651:X',...
'BPMS:IN20:651:Y',...
'BPMS:IN20:651:TMIT',...
'PMT:IN20:622:QDCRAW',...           %PMT
'BPMS:IN20:731:X',...               %DL1 Energy
'BPMS:IN20:731:Y',...
'BPMS:IN20:731:TMIT',...
'WIRE:IN20:741:POSN',...            %WS04
'WIRE:IN20:741:MASK',...
'PMT:IN20:511:QDCRAW',...           %PMTs
'PMT:IN20:512:QDCRAW',...
'PMT:IN20:621:QDCRAW',...
'PMT:IN20:761:QDCRAW',...
'PMT:IN20:762:QDCRAW',...
'BPMS:IN20:771:X',...
'BPMS:IN20:771:Y',...
'BPMS:IN20:771:TMIT',...
'BPMS:IN20:781:X',...
'BPMS:IN20:781:Y',...
'BPMS:IN20:781:TMIT',...
'TORO:IN20:791:TMIT',...
'BPMS:IN20:925:X',...         % SAB ................
'BPMS:IN20:925:Y',...
'BPMS:IN20:925:TMIT',...
'BPMS:IN20:945:X',...
'BPMS:IN20:945:Y',...
'BPMS:IN20:945:TMIT',...
'TORO:IN20:971:TMIT',...
'BPMS:IN20:981:X',...
'BPMS:IN20:981:Y',...
'BPMS:IN20:981:TMIT',...      % END SAB ..........
'ACCL:LI21:1:L1S_P',...             %L1S RF
'ACCL:LI21:1:L1S_A',...
'BPMS:LI21:131:X',...
'BPMS:LI21:131:Y',...
'BPMS:LI21:131:TMIT',...
'BPMS:LI21:161:X',...
'BPMS:LI21:161:Y',...
'BPMS:LI21:161:TMIT',...
'ACCL:LI21:180:L1X_P',...           %L1X RF
'ACCL:LI21:180:L1X_A',...
'BPMS:LI21:201:X',...
'BPMS:LI21:201:Y',...
'BPMS:LI21:201:TMIT',...
'TORO:LI21:205:TMIT',...
'BPMS:LI21:233:X',...               %Energy BC1
'BPMS:LI21:233:Y',...
'BPMS:LI21:233:TMIT',...
'BLEN:LI21:265:ARAW',...            %BLEN
'BLEN:LI21:265:AIMAX',...
'BLEN:LI21:265:BRAW',...
'BLEN:LI21:265:BIMAX',...
'TORO:LI21:277:TMIT',...
'BPMS:LI21:278:X',...
'BPMS:LI21:278:Y',...
'BPMS:LI21:278:TMIT',...
'BLEN:LI21:280:ARAW',...            %BLEN
'BLEN:LI21:280:AIMAX',...
'BLEN:LI21:280:BRAW',...
'BLEN:LI21:280:BIMAX',...
'BLEN:LI21:280:CRAW',...
'BLEN:LI21:280:CIMAX',...
'BLEN:LI21:280:DRAW',...
'BLEN:LI21:280:DIMAX',...
'BLEN:LI21:280:ERAW',...
'BLEN:LI21:280:EIMAX',...
'WIRE:LI21:285:POSN',...            %WS11
'WIRE:LI21:285:MASK',...
'PMT:LI21:285:QDCRAW',...
'WIRE:LI21:293:POSN',...            %WS12
'WIRE:LI21:293:MASK',...
'PMT:LI21:293:QDCRAW',...           %PMT
'PCAV:LI21:300:P',...               %Phase monitor
'PCAV:LI21:300:A',...
'WIRE:LI21:301:POSN',...            %WS13
'WIRE:LI21:301:MASK',...
'PMT:LI21:301:QDCRAW',...           %PMT
'BPMS:LI21:301:X',...
'BPMS:LI21:301:Y',...
'BPMS:LI21:301:TMIT',...
'PMT:LI21:401:QDCRAW',...           %PMTs
'PMT:LI21:402:QDCRAW',...
'BPMS:LI21:315:X',...
'BPMS:LI21:315:Y',...
'BPMS:LI21:315:TMIT',...
'BPMS:LI21:401:X',...
'BPMS:LI21:401:Y',...
'BPMS:LI21:401:TMIT',...
'BPMS:LI21:501:X',...
'BPMS:LI21:501:Y',...
'BPMS:LI21:501:TMIT',...
'BPMS:LI21:601:X',...
'BPMS:LI21:601:Y',...
'BPMS:LI21:601:TMIT',...
'BPMS:LI21:701:X',...
'BPMS:LI21:701:Y',...
'BPMS:LI21:701:TMIT',...
'BPMS:LI21:801:X',...
'BPMS:LI21:801:Y',...
'BPMS:LI21:801:TMIT',...
'BPMS:LI21:901:X',...
'BPMS:LI21:901:Y',...
'BPMS:LI21:901:TMIT',...
'TORO:LI24:707:TMIT',...
'BPMS:LI24:801:X',...               %Energy BC2
'BPMS:LI24:801:Y',...
'BPMS:LI24:801:TMIT',...
'BLEN:LI24:886:ARAW',...            $BLEN
'BLEN:LI24:886:AIMAX',...
'BLEN:LI24:886:BRAW',...
'BLEN:LI24:886:BIMAX',...
'BPMS:LI25:201:X',...
'BPMS:LI25:201:Y',...
'BPMS:LI25:201:TMIT',...
'TORO:LI25:235:TMIT',...
'TCAV:LI24:800:P',...               %TCAV03
'TCAV:LI24:800:A',...
'PCAV:LI25:300:P',...               %Phase Monitor
'PCAV:LI25:300:A',...
'BPMS:LI25:601:X',...
'BPMS:LI25:601:Y',...
'BPMS:LI25:601:TMIT',...
'BLEN:LI25:883:ARAW',...           %BLEN
'BLEN:LI25:883:AIMAX',...
'BLEN:LI25:883:BRAW',...
'BLEN:LI25:883:BIMAX',...
'BLEN:LI25:883:CRAW',...
'BLEN:LI25:883:CIMAX',...
'BLEN:LI25:883:DRAW',...
'BLEN:LI25:883:DIMAX',...
'BLEN:LI25:883:ERAW',...
'BLEN:LI25:883:EIMAX',...
'BPMS:LI27:301:X',...
'BPMS:LI27:301:Y',...
'BPMS:LI27:301:TMIT',...
'BPMS:LI27:401:X',...
'BPMS:LI27:401:Y',...
'BPMS:LI27:401:TMIT',...
'WIRE:LI27:644:POSN',...           %WS644
'WIRE:LI27:644:MASK',...
'PMT:LI27:644:QDCRAW',...          %PMT
'BPMS:LI27:701:X',...
'BPMS:LI27:701:Y',...
'BPMS:LI27:701:TMIT',...
'BPMS:LI27:801:X',...
'BPMS:LI27:801:Y',...
'BPMS:LI27:801:TMIT',...
'WIRE:LI28:144:POSN',...           %WS144
'WIRE:LI28:144:MASK',...
'PMT:LI28:144:QDCRAW',...          %PMT
'PMT:LI28:150:QDCRAW',...          %PMT Fiber
'BPMS:LI28:301:X',...
'BPMS:LI28:301:Y',...
'BPMS:LI28:301:TMIT',...
'BPMS:LI28:401:X',...
'BPMS:LI28:401:Y',...
'BPMS:LI28:401:TMIT',...
'WIRE:LI28:444:POSN',...           %WS444
'WIRE:LI28:444:MASK',...
'PMT:LI28:444:QDCRAW',...          %PMT
'BPMS:LI28:701:X',...
'BPMS:LI28:701:Y',...
'BPMS:LI28:701:TMIT',...
'WIRE:LI28:744:POSN',...           %WS744
'WIRE:LI28:744:MASK',...
'PMT:LI28:744:QDCRAW',...          %PMT
'BPMS:LI28:801:TMIT',...
'BPMS:LI28:801:X',...
'BPMS:LI28:801:Y',...
'PMT:LI28:750:QDCRAW',...          %PMT Fiber
'PCAV:LI29:100:P',...             %Phase Monitor (end of S28)
'PCAV:LI29:100:A',...
'BPMS:CLTH:140:X',...
'BPMS:CLTH:140:Y',...
'BPMS:CLTH:140:TMIT',...
'BPMS:CLTH:170:X',...
'BPMS:CLTH:170:Y',...
'BPMS:CLTH:170:TMIT',...
'BPMS:BSYH:445:X',...             
'BPMS:BSYH:445:Y',...
'BPMS:BSYH:445:TMIT',...
'BPMS:BSYH:465:X',...
'BPMS:BSYH:465:Y',...
'BPMS:BSYH:465:TMIT',...
'BPMS:BSYH:640:X',...
'BPMS:BSYH:640:Y',...
'BPMS:BSYH:640:TMIT',...
'BPMS:BSYH:735:X',...
'BPMS:BSYH:735:Y',...
'BPMS:BSYH:735:TMIT',...
'BPMS:BSYH:910:X',...
'BPMS:BSYH:910:Y',...
'BPMS:BSYH:910:TMIT',...
'BPMS:LTU0:110:X',...
'BPMS:LTU0:110:Y',...
'BPMS:LTU0:110:TMIT',...
'BPMS:LTU0:120:X',...
'BPMS:LTU0:120:Y',...
'BPMS:LTU0:120:TMIT',...
'BPMS:LTU0:130:X',...
'BPMS:LTU0:130:Y',...
'BPMS:LTU0:130:TMIT',...
'BPMS:LTU0:150:X',...
'BPMS:LTU0:150:Y',...
'BPMS:LTU0:150:TMIT',...
'BPMS:LTU0:170:X',...
'BPMS:LTU0:170:Y',...
'BPMS:LTU0:170:TMIT',...
'BPMS:LTU0:180:X',...
'BPMS:LTU0:180:Y',...
'BPMS:LTU0:180:TMIT',...
'BPMS:LTU0:190:X',...
'BPMS:LTU0:190:Y',...
'BPMS:LTU0:190:TMIT',...
'TORO:LTU0:195:TMIT',...
'BPMS:LTU1:250:X',...              %Energy DL1
'BPMS:LTU1:250:Y',...
'BPMS:LTU1:250:TMIT',...
'BPMS:LTU1:290:X',...
'BPMS:LTU1:290:Y',...
'BPMS:LTU1:290:TMIT',...
'BPMS:LTU1:350:X',...
'BPMS:LTU1:350:Y',...
'BPMS:LTU1:350:TMIT',...
'BPMS:LTU1:390:X',...
'BPMS:LTU1:390:Y',...
'BPMS:LTU1:390:TMIT',...
'BPMS:LTU1:450:X',...              %Energy DL3
'BPMS:LTU1:450:Y',...
'BPMS:LTU1:450:TMIT',...
'BPMS:LTU1:490:X',...
'BPMS:LTU1:490:Y',...
'BPMS:LTU1:490:TMIT',...
'BPMS:LTU1:550:X',...
'BPMS:LTU1:550:Y',...
'BPMS:LTU1:550:TMIT',...
'BPMS:LTU1:590:X',...
'BPMS:LTU1:590:Y',...
'BPMS:LTU1:590:TMIT',...
'TORO:LTU1:605:TMIT',...
'BPMS:LTU1:620:X',...
'BPMS:LTU1:620:Y',...
'BPMS:LTU1:620:TMIT',...
'BPMS:LTU1:640:X',...
'BPMS:LTU1:640:Y',...
'BPMS:LTU1:640:TMIT',...
'BPMS:LTU1:660:X',...
'BPMS:LTU1:660:Y',...
'BPMS:LTU1:660:TMIT',...
'BPMS:LTU1:680:X',...
'BPMS:LTU1:680:Y',...
'BPMS:LTU1:680:TMIT',...
'WIRE:LTU1:715:POSN',...           %WS31
'WIRE:LTU1:715:MASK',...
'BPMS:LTU1:720:X',...
'BPMS:LTU1:720:Y',...
'BPMS:LTU1:720:TMIT',...
'BPMS:LTU1:730:X',...
'BPMS:LTU1:730:Y',...
'BPMS:LTU1:730:TMIT',...
'WIRE:LTU1:735:POSN',...           %WS32
'WIRE:LTU1:735:MASK',...
'BPMS:LTU1:740:X',...
'BPMS:LTU1:740:Y',...
'BPMS:LTU1:740:TMIT',...
'BPMS:LTU1:750:X',...
'BPMS:LTU1:750:Y',...
'BPMS:LTU1:750:TMIT',...
'WIRE:LTU1:755:POSN',...           %WS33
'WIRE:LTU1:755:MASK',...
'BPMS:LTU1:760:X',...
'BPMS:LTU1:760:Y',...
'BPMS:LTU1:760:TMIT',...
'BPMS:LTU1:770:X',...
'BPMS:LTU1:770:Y',...
'BPMS:LTU1:770:TMIT',...
'WIRE:LTU1:775:POSN',...           %WS34
'WIRE:LTU1:775:MASK',...
'BPMS:LTU1:820:X',...
'BPMS:LTU1:820:Y',...
'BPMS:LTU1:820:TMIT',...
'BPMS:LTU1:840:X',...
'BPMS:LTU1:840:Y',...
'BPMS:LTU1:840:TMIT',...
'BPMS:LTU1:860:X',...
'BPMS:LTU1:860:Y',...
'BPMS:LTU1:860:TMIT',...
'BPMS:LTU1:880:X',...
'BPMS:LTU1:880:Y',...
'BPMS:LTU1:880:TMIT',...
'PMT:LTU1:715:QDCRAW',...          %PMT Fiber
'PMT:LTU1:755:QDCRAW',...          %PMT Fiber
'PMT:LTU1:970:QDCRAW',...          %PMT Fiber
'PMT:LTU1:820:QDCRAW',...          %PMT Fiber
'PMT:LTU1:971:QDCRAW',...          %PMT Fiber
'BPMS:LTU1:910:X',...
'BPMS:LTU1:910:Y',...
'BPMS:LTU1:910:TMIT',...
'BPMS:LTU1:910:REFR',...
'BPMS:LTU1:910:URER',...
'BPMS:LTU1:910:UIMR',...
'BPMS:LTU1:910:VRER',...
'BPMS:LTU1:910:VIMR',...
'TORO:LTU1:920:TMIT',...
'BPMS:LTU1:960:X',...%
'BPMS:LTU1:960:Y',...
'BPMS:LTU1:960:TMIT',...
'BPMS:LTU1:960:REFR',...
'BPMS:LTU1:960:URER',...
'BPMS:LTU1:960:UIMR',...
'BPMS:LTU1:960:VRER',...
'BPMS:LTU1:960:VIMR',...
'UBLF:UND1:500:ARAW',...           %BLF
'UBLF:UND1:500:AIMAX',...
'UBLF:UND1:500:BRAW',...
'UBLF:UND1:500:BIMAX',...
'UBLF:UND1:500:CRAW',...
'UBLF:UND1:500:CIMAX',...
'UBLF:UND1:500:DRAW',...
'UBLF:UND1:500:DIMAX',...
'PMT:UND1:1690:QDCRAW',...         %PMT Fiber?
'BPMS:UND1:100:X',...
'BPMS:UND1:100:Y',...
'BPMS:UND1:100:TMIT',...
'BPMS:UND1:100:REFR',...
'BPMS:UND1:100:URER',...
'BPMS:UND1:100:UIMR',...
'BPMS:UND1:100:VRER',...
'BPMS:UND1:100:VIMR',...
'BPMS:UND1:190:X',...
'BPMS:UND1:190:Y',...
'BPMS:UND1:190:TMIT',...
'BPMS:UND1:190:REFR',...
'BPMS:UND1:190:UIMR',...
'BPMS:UND1:190:URER',...
'BPMS:UND1:190:VRER',...
'BPMS:UND1:190:VIMR',...
'BPMS:UND1:290:X',...
'BPMS:UND1:290:Y',...
'BPMS:UND1:290:TMIT',...
'BPMS:UND1:290:REFR',...
'BPMS:UND1:290:URER',...
'BPMS:UND1:290:UIMR',...
'BPMS:UND1:290:VRER',...
'BPMS:UND1:290:VIMR',...
'BPMS:UND1:390:X',...
'BPMS:UND1:390:Y',...
'BPMS:UND1:390:TMIT',...
'BPMS:UND1:390:REFR',...
'BPMS:UND1:390:URER',...
'BPMS:UND1:390:UIMR',...
'BPMS:UND1:390:VRER',...
'BPMS:UND1:390:VIMR',...
'BPMS:UND1:490:X',...
'BPMS:UND1:490:Y',...
'BPMS:UND1:490:TMIT',...
'BPMS:UND1:490:REFR',...
'BPMS:UND1:490:URER',...
'BPMS:UND1:490:UIMR',...
'BPMS:UND1:490:VRER',...
'BPMS:UND1:490:VIMR',...
'BPMS:UND1:590:X',...
'BPMS:UND1:590:Y',...
'BPMS:UND1:590:TMIT',...
'BPMS:UND1:590:REFR',...
'BPMS:UND1:590:URER',...
'BPMS:UND1:590:UIMR',...
'BPMS:UND1:590:VRER',...
'BPMS:UND1:590:VIMR',...
'BPMS:UND1:690:X',...
'BPMS:UND1:690:Y',...
'BPMS:UND1:690:TMIT',...
'BPMS:UND1:690:REFR',...
'BPMS:UND1:690:URER',...
'BPMS:UND1:690:UIMR',...
'BPMS:UND1:690:VRER',...
'BPMS:UND1:690:VIMR',...
'BPMS:UND1:790:X',...
'BPMS:UND1:790:Y',...
'BPMS:UND1:790:TMIT',...
'BPMS:UND1:790:REFR',...
'BPMS:UND1:790:URER',...
'BPMS:UND1:790:UIMR',...
'BPMS:UND1:790:VRER',...
'BPMS:UND1:790:VIMR',...
'BPMS:UND1:890:X',...
'BPMS:UND1:890:Y',...
'BPMS:UND1:890:TMIT',...
'BPMS:UND1:890:REFR',...
'BPMS:UND1:890:URER',...
'BPMS:UND1:890:UIMR',...
'BPMS:UND1:890:VRER',...
'BPMS:UND1:890:VIMR',...
'BPMS:UND1:990:X',...
'BPMS:UND1:990:Y',...
'BPMS:UND1:990:TMIT',...
'BPMS:UND1:990:REFR',...
'BPMS:UND1:990:URER',...
'BPMS:UND1:990:UIMR',...
'BPMS:UND1:990:VRER',...
'BPMS:UND1:990:VIMR',...
'BPMS:UND1:1090:X',...
'BPMS:UND1:1090:Y',...
'BPMS:UND1:1090:TMIT',...
'BPMS:UND1:1090:REFR',...
'BPMS:UND1:1090:URER',...
'BPMS:UND1:1090:UIMR',...
'BPMS:UND1:1090:VRER',...
'BPMS:UND1:1090:VIMR',...
'BPMS:UND1:1190:X',...
'BPMS:UND1:1190:Y',...
'BPMS:UND1:1190:TMIT',...
'BPMS:UND1:1190:REFR',...
'BPMS:UND1:1190:URER',...
'BPMS:UND1:1190:UIMR',...
'BPMS:UND1:1190:VRER',...
'BPMS:UND1:1190:VIMR',...
'BPMS:UND1:1290:X',...
'BPMS:UND1:1290:Y',...
'BPMS:UND1:1290:TMIT',...
'BPMS:UND1:1290:REFR',...
'BPMS:UND1:1290:URER',...
'BPMS:UND1:1290:UIMR',...
'BPMS:UND1:1290:VRER',...
'BPMS:UND1:1290:VIMR',...
'BPMS:UND1:1390:X',...
'BPMS:UND1:1390:Y',...
'BPMS:UND1:1390:TMIT',...
'BPMS:UND1:1390:REFR',...
'BPMS:UND1:1390:URER',...
'BPMS:UND1:1390:UIMR',...
'BPMS:UND1:1390:VRER',...
'BPMS:UND1:1390:VIMR',...
'BPMS:UND1:1490:X',...
'BPMS:UND1:1490:Y',...
'BPMS:UND1:1490:TMIT',...
'BPMS:UND1:1490:REFR',...
'BPMS:UND1:1490:URER',...
'BPMS:UND1:1490:UIMR',...
'BPMS:UND1:1490:VRER',...
'BPMS:UND1:1490:VIMR',...
'BPMS:UND1:1590:X',...
'BPMS:UND1:1590:Y',...
'BPMS:UND1:1590:TMIT',...
'BPMS:UND1:1590:REFR',...
'BPMS:UND1:1590:URER',...
'BPMS:UND1:1590:UIMR',...
'BPMS:UND1:1590:VRER',...
'BPMS:UND1:1590:VIMR',...
'BPMS:UND1:1690:X',...
'BPMS:UND1:1690:Y',...
'BPMS:UND1:1690:TMIT',...
'BPMS:UND1:1690:REFR',...
'BPMS:UND1:1690:URER',...
'BPMS:UND1:1690:UIMR',...
'BPMS:UND1:1690:VRER',...
'BPMS:UND1:1690:VIMR',...
'BPMS:UND1:1790:X',...
'BPMS:UND1:1790:Y',...
'BPMS:UND1:1790:TMIT',...
'BPMS:UND1:1790:REFR',...
'BPMS:UND1:1790:URER',...
'BPMS:UND1:1790:UIMR',...
'BPMS:UND1:1790:VRER',...
'BPMS:UND1:1790:VIMR',...
'BPMS:UND1:1890:X',...
'BPMS:UND1:1890:Y',...
'BPMS:UND1:1890:TMIT',...
'BPMS:UND1:1890:REFR',...
'BPMS:UND1:1890:URER',...
'BPMS:UND1:1890:UIMR',...
'BPMS:UND1:1890:VRER',...
'BPMS:UND1:1890:VIMR',...
'BPMS:UND1:1990:X',...
'BPMS:UND1:1990:Y',...
'BPMS:UND1:1990:TMIT',...
'BPMS:UND1:1990:REFR',...
'BPMS:UND1:1990:URER',...
'BPMS:UND1:1990:UIMR',...
'BPMS:UND1:1990:VRER',...
'BPMS:UND1:1990:VIMR',...
'BPMS:UND1:2090:X',...
'BPMS:UND1:2090:Y',...
'BPMS:UND1:2090:TMIT',...
'BPMS:UND1:2090:REFR',...
'BPMS:UND1:2090:URER',...
'BPMS:UND1:2090:UIMR',...
'BPMS:UND1:2090:VRER',...
'BPMS:UND1:2090:VIMR',...
'BPMS:UND1:2190:X',...
'BPMS:UND1:2190:Y',...
'BPMS:UND1:2190:TMIT',...
'BPMS:UND1:2190:REFR',...
'BPMS:UND1:2190:URER',...
'BPMS:UND1:2190:UIMR',...
'BPMS:UND1:2190:VRER',...
'BPMS:UND1:2190:VIMR',...
'BPMS:UND1:2290:X',...
'BPMS:UND1:2290:Y',...
'BPMS:UND1:2290:TMIT',...
'BPMS:UND1:2290:REFR',...
'BPMS:UND1:2290:URER',...
'BPMS:UND1:2290:UIMR',...
'BPMS:UND1:2290:VRER',...
'BPMS:UND1:2290:VIMR',...
'BPMS:UND1:2390:X',...
'BPMS:UND1:2390:Y',...
'BPMS:UND1:2390:TMIT',...
'BPMS:UND1:2390:REFR',...
'BPMS:UND1:2390:URER',...
'BPMS:UND1:2390:UIMR',...
'BPMS:UND1:2390:VRER',...
'BPMS:UND1:2390:VIMR',...
'BPMS:UND1:2490:X',...
'BPMS:UND1:2490:Y',...
'BPMS:UND1:2490:TMIT',...
'BPMS:UND1:2490:REFR',...
'BPMS:UND1:2490:URER',...
'BPMS:UND1:2490:UIMR',...
'BPMS:UND1:2490:VRER',...
'BPMS:UND1:2490:VIMR',...
'BPMS:UND1:2590:X',...
'BPMS:UND1:2590:Y',...
'BPMS:UND1:2590:TMIT',...
'BPMS:UND1:2590:REFR',...
'BPMS:UND1:2590:URER',...
'BPMS:UND1:2590:UIMR',...
'BPMS:UND1:2590:VRER',...
'BPMS:UND1:2590:VIMR',...
'BPMS:UND1:2690:X',...
'BPMS:UND1:2690:Y',...
'BPMS:UND1:2690:TMIT',...
'BPMS:UND1:2690:REFR',...
'BPMS:UND1:2690:URER',...
'BPMS:UND1:2690:UIMR',...
'BPMS:UND1:2690:VRER',...
'BPMS:UND1:2690:VIMR',...
'BPMS:UND1:2790:X',...
'BPMS:UND1:2790:Y',...
'BPMS:UND1:2790:TMIT',...
'BPMS:UND1:2790:REFR',...
'BPMS:UND1:2790:URER',...
'BPMS:UND1:2790:UIMR',...
'BPMS:UND1:2790:VRER',...
'BPMS:UND1:2790:VIMR',...
'BPMS:UND1:2890:X',...
'BPMS:UND1:2890:Y',...
'BPMS:UND1:2890:TMIT',...
'BPMS:UND1:2890:REFR',...
'BPMS:UND1:2890:URER',...
'BPMS:UND1:2890:UIMR',...
'BPMS:UND1:2890:VRER',...
'BPMS:UND1:2890:VIMR',...
'BPMS:UND1:2990:X',...
'BPMS:UND1:2990:Y',...
'BPMS:UND1:2990:TMIT',...
'BPMS:UND1:2990:REFR',...
'BPMS:UND1:2990:URER',...
'BPMS:UND1:2990:UIMR',...
'BPMS:UND1:2990:VRER',...
'BPMS:UND1:2990:VIMR',...
'BPMS:UND1:3090:X',...
'BPMS:UND1:3090:Y',...
'BPMS:UND1:3090:TMIT',...
'BPMS:UND1:3090:REFR',...
'BPMS:UND1:3090:URER',...
'BPMS:UND1:3090:UIMR',...
'BPMS:UND1:3090:VRER',...
'BPMS:UND1:3090:VIMR',...
'BPMS:UND1:3190:X',...
'BPMS:UND1:3190:Y',...
'BPMS:UND1:3190:TMIT',...
'BPMS:UND1:3190:REFR',...
'BPMS:UND1:3190:URER',...
'BPMS:UND1:3190:UIMR',...
'BPMS:UND1:3190:VRER',...
'BPMS:UND1:3190:VIMR',...
'BPMS:UND1:3290:X',...
'BPMS:UND1:3290:Y',...
'BPMS:UND1:3290:TMIT',...
'BPMS:UND1:3290:REFR',...
'BPMS:UND1:3290:URER',...
'BPMS:UND1:3290:UIMR',...
'BPMS:UND1:3290:VRER',...
'BPMS:UND1:3290:VIMR',...
'BPMS:UND1:3390:X',...
'BPMS:UND1:3390:Y',...
'BPMS:UND1:3390:TMIT',...
'BPMS:UND1:3390:REFR',...
'BPMS:UND1:3390:URER',...
'BPMS:UND1:3390:UIMR',...
'BPMS:UND1:3390:VRER',...
'BPMS:UND1:3390:VIMR',...
'TORO:DMP1:198:TMIT',...
'BPMS:DMP1:199:X',...
'BPMS:DMP1:199:Y',...
'BPMS:DMP1:199:TMIT',...
'BPMS:DMP1:301:X',...
'BPMS:DMP1:301:Y',...
'BPMS:DMP1:301:TMIT',...
'BPMS:DMP1:398:X',...
'BPMS:DMP1:398:Y',...
'BPMS:DMP1:398:TMIT',...
'TORO:DMP1:399:TMIT',...
'TORO:DMP1:424:TMIT',...
'BPMS:DMP1:502:X',...
'BPMS:DMP1:502:Y',...
'BPMS:DMP1:502:TMIT',...
'TORO:DMP1:685:TMIT',...
'BPMS:DMP1:693:X',...
'BPMS:DMP1:693:Y',...
'BPMS:DMP1:693:TMIT',...
'PMT:DMP1:430:QDCRAW',...
'PMT:DMP1:431:QDCRAW',...
'SIOC:SYS0:ML00:AO596.NAME',...
'TORO:DMP1:999:TMIT'};

try
% Connect to Aida
aidainit;
import edu.stanford.slac.aida.lib.da.DaObject; 
da = DaObject();

% Get the BSA Names.
v = da.getDaValue('LCLS//BSA.elements.byZ'); 

% Extract the number of BSA element names returned (the number of rows)
Mrows = v.get(0).size(); 

% Extract just the element names and Z positions.
root_name = (char(v.get(4).getStrings()));

z_pos = (v.get(3).getStrings()); 

for i=1:Mrows
    z_positions(i) = str2double(z_pos(i,:));
end

%Eliminate SLC database stuff and other unnecessary variables

%id_bsa_1 = find( (((root_name(:,1)=='L')&(root_name(:,2)=='I'))...
%    |((root_name(:,1)=='L')&(root_name(:,2)=='M')))~=1);

%id_bsa_1 = find( (((root_name(:,1)=='L')&(root_name(:,2)=='I'))...
%    |((root_name(:,1)=='L')&(root_name(:,2)=='M'))...
%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='3')&(root_name(:,9)=='0'))...
%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='2')&(root_name(:,9)=='9'))...
%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='2')&(root_name(:,9)=='4')&(root_name(:,11)~='8'))...
%    |((root_name(:,6)=='B')&(root_name(:,7)=='S')...
%    &(root_name(:,8)=='Y')&(root_name(:,9)=='0')&(root_name(:,11)=='1'))...
%    )~=1);


id_bsa_1 = find( (((root_name(:,1)=='L')&(root_name(:,2)=='I'))...
    |((root_name(:,1)=='L')&(root_name(:,2)=='M'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='8')&(root_name(:,12)=='2')...
    &(root_name(:,13)=='1'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='4')...
    &(root_name(:,13)=='5'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='2')...
    &(root_name(:,13)=='5'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='4')...
    &(root_name(:,13)=='5'))...
    |((root_name(:,6)=='I')&(root_name(:,7)=='N')...
    &(root_name(:,11)=='9')&(root_name(:,12)=='8')...
    &(root_name(:,13)=='1'))...      
    |((root_name(:,1)=='I')&(root_name(:,2)=='O')...
    &(root_name(:,3)=='C'))...      
    |((root_name(:,14)=='S')&(root_name(:,15)=='E')...
    &(root_name(:,16)=='C'))...      
    |((root_name(:,13)=='S')&(root_name(:,14)=='E')...
    &(root_name(:,15)=='C'))...      
    )~=1);

%    &(root_name(:,15)=='C'))...      
%    |((root_name(:,1)=='F')&(root_name(:,2)=='A')...
%    &(root_name(:,3)=='R')&(root_name(:,4)=='C'))...      
%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='2')&(root_name(:,9)=='4')&(root_name(:,11)~='8'))...



%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='3')&(root_name(:,9)=='0')...
%    &(root_name(:,11)=='6'))...
%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='3')&(root_name(:,9)=='0')...
%    &(root_name(:,11)=='7'))...
%    |((root_name(:,6)=='L')&(root_name(:,7)=='I')...
%    &(root_name(:,8)=='3')&(root_name(:,9)=='0')...
%    &(root_name(:,11)=='8'))...
%    |((root_name(:,6)=='B')&(root_name(:,7)=='S')...
%    &(root_name(:,8)=='Y')&(root_name(:,9)=='0')&(root_name(:,11)=='1'))...

% id_bsa_1 = find(((root_name(:,1)=='L')&(root_name(:,2)=='I'))~=1);

for j=1:length(id_bsa_1)
    [id_refr(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'REFR'));
    [id_vrer(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'VRER'));
    [id_urer(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'URER'));
    [id_uimr(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'UIMR'));
    [id_vimr(j)]=isempty(strfind(root_name(id_bsa_1(j),:),'VIMR'));
end
id_bsa_2 = find((id_refr==1)&...
    (id_vrer==1)&...
    (id_urer==1)&...
    (id_uimr==1)&...
    (id_vimr==1));

%handles.ROOT_NAME=cellstr(root_name(id_bsa_1,:))';
%handles.z_positions = z_positions(id_bsa_1)';

handles.ROOT_NAME=cellstr(root_name(id_bsa_1(id_bsa_2),:))';
handles.z_positions = z_positions(id_bsa_1(id_bsa_2))';

%handles.ROOT_NAME=cellstr(root_name)';
%handles.z_positions = z_positions';



handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:241:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:242:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:13:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:361:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:362:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='GDET:FEE1:23:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:421:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:422:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:423:ENRC';
handles.ROOT_NAME{1+length(handles.ROOT_NAME)}='KMON:FEE1:424:ENRC';


[handles.z_positions(1+length(handles.z_positions))] = 50 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 5 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));
[handles.z_positions(1+length(handles.z_positions))] = 1 + handles.z_positions(length(handles.z_positions));

%handles.ROOT_NAME = root_name;
%handles.z_positions = z_positions;

handles.zLCLS=2014.7019;

FullPVList.z_positions=handles.z_positions;
FullPVList.root_name=handles.ROOT_NAME;
FullPVList.new_model=handles.new_model;
FullPVList.toot_name=handles.TOOT_NAME;
FullPVList.zLCLS=handles.zLCLS;

catch ME %you are likely offline, just load an old file
    disp('fetching BSA Pv list did not work, loading an old file')
    load JimTurnerOpeningResult zLCLS z_positions ROOT_NAME TOOT_NAME new_model
    FullPVList.z_positions=z_positions;
    FullPVList.root_name=ROOT_NAME;
    FullPVList.new_model=new_model;
    FullPVList.toot_name=TOOT_NAME;
    FullPVList.zLCLS=zLCLS;
end

function update_figure_list(handles)
set(handles.Vis_List,'Value',1)
UD=get(handles.CVCRCIISSA,'UserData');
FiguresList=UD{4};
if(isempty(FiguresList))
    Lista{1}='NONE';
else
    for II=1:numel(FiguresList)
       Lista{II}=num2str(FiguresList(II));
    end 
end
set(handles.Vis_List,'String',Lista)

function Init_Vars=Initialize_Recording(handles,Mode_of_Init)
Init_Vars.INIT_FAILED=0;
Init_Vars.Image2D=0;
Init_Vars.usebsa=get(handles.c_BSA,'value');
Init_Vars.profile=get(handles.ProfileMonitorName,'String');
Init_Vars.listofprofiles=get(handles.ProfileMonitorMenu,'string');
Init_Vars.UsedProfileValue=get(handles.ProfileMonitorMenu,'value');
Init_Vars.UpdateMode=get(handles.c_update,'value');
Init_Vars.DoubleBufferCycle=str2double(get(handles.dbcycle,'string'));
if(any(isnan(Init_Vars.DoubleBufferCycle)) || any(isinf(Init_Vars.DoubleBufferCycle)))
    if(Init_Vars.DoubleBufferCycle<2) || (Init_Vars.DoubleBufferCycle>5)
        PrevColor=get(handles.dbcycle,'backgroundcolor');
        Init_Vars.INIT_FAILED=1;
        set(handles.handles.dbcycle,'backgroundcolor',[1,0,0]); pause(0.5);
        set(handles.handles.dbcycle,'backgroundcolor',PrevColor); 
    end
end
Init_Vars.PulseIDProfileDelay=str2double(get(handles.PulseID_delay,'string'));
if(any(isnan(Init_Vars.PulseIDProfileDelay)) || any(isinf(Init_Vars.PulseIDProfileDelay)))
    PrevColor=get(handles.PulseID_delay,'backgroundcolor');
    Init_Vars.INIT_FAILED=1;
    set(handles.PulseID_delay,'backgroundcolor',[1,0,0]); pause(0.5);
    set(handles.PulseID_delay,'backgroundcolor',PrevColor); 
end
Init_Vars.PulseIDProfileDelay=round(Init_Vars.PulseIDProfileDelay);
Init_Vars.BothProfiles=0;
if(strcmp(Init_Vars.listofprofiles(Init_Vars.UsedProfileValue),'DISABLE'))
    Init_Vars.ReadProfile=0;
else
    Init_Vars.ReadProfile=1;
end
Init_Vars.ROIx(1)=str2num(get(handles.e_roix1,'String'));
Init_Vars.ROIx(2)=str2num(get(handles.e_roix2,'String'));
Init_Vars.ROIy(1)=str2num(get(handles.e_roiy1,'String'));
Init_Vars.ROIy(2)=str2num(get(handles.e_roiy2,'String'));
Init_Vars.Pvlist=get(handles.PvSyncList,'String');
Init_Vars.PvNumber=numel(Init_Vars.Pvlist);
Init_Vars.PvNotSync=get(handles.PvNotSyncList,'String');
Init_Vars.PvNotSyncNumber=numel(Init_Vars.PvNotSync);
Init_Vars.keepsize=str2num(get(handles.e_keeplast,'String'));
Init_Vars.pausetime=str2num(get(handles.e_pause,'String'));
Init_Vars.blocksize=str2num(get(handles.e_block,'String'));
Init_Vars.ProjectionDirection=get(handles.ProjectionXY,'value');
Init_Vars.SubtractiveConstant=str2num(get(handles.e_background,'String'));

for II=1:handles.NumberOfAvailableSignals
    %['Init_Vars.SignalON(',num2str(II),')=get(handles.Sig',num2str(II),',''Value'');']
    eval(['Init_Vars.SignalON(',num2str(II),')=get(handles.Sig',num2str(II),',''Value'');']);
    %Init_Vars.SignalON(1)=get(handles.Sig1,'value');Init_Vars.SignalON(2)=get(handles.Sig2,'value');Init_Vars.SignalON(3)=get(handles.Sig3,'value');
end
for II=1:handles.NumberOfAvailableFilters
    %['Init_Vars.FilterON(',num2str(II),')=get(handles.c_Filter',num2str(II),',''Value'');']
    eval(['Init_Vars.FilterON(',num2str(II),')=get(handles.c_Filter',num2str(II),',''Value'');']);
    %Init_Vars.FilterON(1)=get(handles.c_Filter1,'value');Init_Vars.FilterON(2)=get(handles.c_Filter2,'value');Init_Vars.FilterON(3)=get(handles.c_Filter3,'value');
end
for II=1:handles.NumberOfOnTheFlyVariables
    %['Init_Vars.SingleValuePvs(',num2str(II),')=str2num(get(handles.e_sig',num2str(round((II+eps)/2)),num2str(mod(II+1,2)+1),',''String''));']
   eval(['Init_Vars.SingleValuePvs(',num2str(II),')=str2num(get(handles.e_sig',num2str(round((II+eps)/2)),num2str(mod(II+1,2)+1),',''String''));']);
end
% Init_Vars.SingleValuePvs(1)=str2num(get(handles.e_sig11,'String'));Init_Vars.SingleValuePvs(2)=str2num(get(handles.e_sig12,'String'));
% Init_Vars.SingleValuePvs(3)=str2num(get(handles.e_sig21,'String'));Init_Vars.SingleValuePvs(4)=str2num(get(handles.e_sig22,'String'));
% Init_Vars.SingleValuePvs(5)=str2num(get(handles.e_sig31,'String'));Init_Vars.SingleValuePvs(6)=str2num(get(handles.e_sig32,'String'));

Init_Vars.FiltersList{1}='Filter Off'; Init_Vars.FilterResorting=[];
for II=1:handles.NumberOfAvailableFilters
    if(Init_Vars.FilterON(II))
        Init_Vars.FilterResorting(end+1)=II; Init_Vars.FiltersList{end+1}=handles.FilterNames{II};
    end
end
for II=1:handles.ProfileProcessNumber
   Init_Vars.BasicProcessing(II)=eval(['get(','handles.c_opt',char(48+II),',''value'');']);
end
if(Init_Vars.ReadProfile)
    Init_Vars.CameraSize=get(handles.ProfileMonitorName,'UserData');
    if(Init_Vars.CameraSize.Rows==1 || Init_Vars.CameraSize.Columns==1)
        Init_Vars.Image2D=0;
    else
        Init_Vars.Image2D=1;
        if (get(handles.ProjectionXY,'value')==3)
            Init_Vars.BothProfiles=1;
        end
    end
else
   Init_Vars.CameraSize.Rows=1;
   Init_Vars.CameraSize.Columns=1;
end
%Define Option Strings and Resorting Order
Init_Vars.BaseLineX{1}='OFF';
Init_Vars.ResortingX(1,1)=0;Init_Vars.ResortingX(1,2)=0;
Init_Vars.ShotToShotScalarsResorting=[];
Init_Vars.number_of_basic_processings=0;
Init_Vars.ProfQuantResorting=[];
if(Init_Vars.ReadProfile)
    if(Init_Vars.BothProfiles)
        Init_Vars.BaseLineX{2}='First Profile';
        Init_Vars.ResortingX(2,1)=1;Init_Vars.ResortingX(2,2)=1;
        Init_Vars.BaseLineX{3}='Second Profile';
        Init_Vars.ResortingX(3,1)=1;Init_Vars.ResortingX(3,2)=2;
        TEMPVAR=numel(Init_Vars.BaseLineX);
        if(Init_Vars.BasicProcessing(1))
            Init_Vars.ProfQuantResorting(end+1)=1;
            Init_Vars.BaseLineX{TEMPVAR+1}='First Profile Sum';
            Init_Vars.BaseLineX{TEMPVAR+1+sum(Init_Vars.BasicProcessing)+Init_Vars.BasicProcessing(2)}='Second Profile Sum';
            TEMPVAR=TEMPVAR+1;
            Init_Vars.ShotToShotScalarsResorting(end+1)=1;Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+2;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
        end 
        if(Init_Vars.BasicProcessing(2))
            Init_Vars.ProfQuantResorting(end+1)=2; Init_Vars.ProfQuantResorting(end+1)=3;
            Init_Vars.BaseLineX{TEMPVAR+1}='First Profile Peak';
            Init_Vars.BaseLineX{TEMPVAR+1+sum(Init_Vars.BasicProcessing)+Init_Vars.BasicProcessing(2)}='Second Profile Peak'; TEMPVAR=TEMPVAR+1;
            Init_Vars.BaseLineX{TEMPVAR+1}='First Prof. Peak Location';
            Init_Vars.BaseLineX{TEMPVAR+1+sum(Init_Vars.BasicProcessing)+Init_Vars.BasicProcessing(2)}='Second Prof. Peak Location';TEMPVAR=TEMPVAR+1;
            Init_Vars.ShotToShotScalarsResorting(end+1)=2;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
            Init_Vars.ShotToShotScalarsResorting(end+1)=3;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
            Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+4;
        end
        if(Init_Vars.BasicProcessing(3))
            Init_Vars.ProfQuantResorting(end+1)=3;
            Init_Vars.BaseLineX{TEMPVAR+1}='First Profile First Moment';
            Init_Vars.BaseLineX{TEMPVAR+1+sum(Init_Vars.BasicProcessing)+Init_Vars.BasicProcessing(2)}='Second Profile First Moment'; TEMPVAR=TEMPVAR+1;
            Init_Vars.ShotToShotScalarsResorting(end+1)=4;Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+2;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
        end
        if(Init_Vars.BasicProcessing(4))
            Init_Vars.ProfQuantResorting(end+1)=4;
            Init_Vars.BaseLineX{TEMPVAR+1}='First Profile FWHM';
            Init_Vars.BaseLineX{TEMPVAR+1+sum(Init_Vars.BasicProcessing)+Init_Vars.BasicProcessing(2)}='Second Profile FWHM'; TEMPVAR=TEMPVAR+1;
            Init_Vars.ShotToShotScalarsResorting(end+1)=5;Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+2;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
        end
    else
        Init_Vars.BaseLineX{2}='First Profile';
        Init_Vars.ResortingX(2,1)=1;Init_Vars.ResortingX(2,2)=1;
        if(Init_Vars.BasicProcessing(1))
            Init_Vars.BaseLineX{end+1}='First Profile Sum';
            Init_Vars.ShotToShotScalarsResorting(end+1)=1;Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+1;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
        end
        if(Init_Vars.BasicProcessing(2))
            Init_Vars.BaseLineX{end+1}='First Profile Peak';
            Init_Vars.BaseLineX{end+1}='First Prof. Peak Location';
            Init_Vars.ShotToShotScalarsResorting(end+1)=2;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
            Init_Vars.ShotToShotScalarsResorting(end+1)=3;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
            Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+2;
        end
        if(Init_Vars.BasicProcessing(3))
            Init_Vars.BaseLineX{end+1}='First Profile First Moment';
            Init_Vars.ShotToShotScalarsResorting(end+1)=4;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
            Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+1;
        end
        if(Init_Vars.BasicProcessing(4))
            Init_Vars.BaseLineX{end+1}='First Profile FWHM';
            Init_Vars.ShotToShotScalarsResorting(end+1)=5;
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
            Init_Vars.number_of_basic_processings=Init_Vars.number_of_basic_processings+1;
        end
    end
    if(Init_Vars.BothProfiles)
        for KK=1:length(Init_Vars.ShotToShotScalarsResorting)
            Init_Vars.ShotToShotScalarsResorting(end+1)=Init_Vars.ShotToShotScalarsResorting(KK)+sum(Init_Vars.BasicProcessing)+Init_Vars.BasicProcessing(2);
            Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
        end
    end
end

Init_Vars.SignalsResorting=[];
Init_Vars.SynchPvResorting=[];
Init_Vars.BaseLineX{end+1}='TimeStamp';
Init_Vars.BaseLineX{end+1}='PulseID';
Init_Vars.ShotToShotScalarsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+1;
Init_Vars.SynchPvResorting(end+1)=2*(handles.ProfileProcessNumber+1)+1;
Init_Vars.ResortingX(end+1,1)=3;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
Init_Vars.ShotToShotScalarsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+2;
Init_Vars.SynchPvResorting(end+1)=2*(handles.ProfileProcessNumber+1)+2;
Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
if(Init_Vars.SignalON(1))
    Init_Vars.SignalsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+3;
    Init_Vars.BaseLineX{end+1}=handles.SignalNames{1};
    Init_Vars.ShotToShotScalarsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+3;
    Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
end
if(Init_Vars.SignalON(2))
    Init_Vars.SignalsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+4;
    Init_Vars.BaseLineX{end+1}=handles.SignalNames{2};
    Init_Vars.ShotToShotScalarsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+4;
    Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
end
if(Init_Vars.SignalON(3))
    Init_Vars.SignalsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+5;
    Init_Vars.BaseLineX{end+1}=handles.SignalNames{3};
    Init_Vars.ShotToShotScalarsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+5;
    Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
end

for II=1:Init_Vars.PvNumber
    Init_Vars.SynchPvResorting(end+1)=2*(handles.ProfileProcessNumber+1)+5+II;
    Init_Vars.BaseLineX{end+1}=Init_Vars.Pvlist{II};
    Init_Vars.ShotToShotScalarsResorting(end+1)=2*(handles.ProfileProcessNumber+1)+5+II;
    Init_Vars.ResortingX(end+1,1)=2;Init_Vars.ResortingX(end,2)=length(Init_Vars.ShotToShotScalarsResorting);
end

Init_Vars.BaseLineY{1}=Init_Vars.BaseLineX{1};
for II=2:numel(Init_Vars.BaseLineX)
            if(Init_Vars.ReadProfile && (II==2))
                continue
            end
            if(Init_Vars.BothProfiles && (II==3))
                continue
            end
            Init_Vars.BaseLineY{end+1}=Init_Vars.BaseLineX{II};
end

if(Init_Vars.BothProfiles)
    Init_Vars.ResortingY=[Init_Vars.ResortingX(1,:);Init_Vars.ResortingX(4:end,:)];
elseif(Init_Vars.ReadProfile)
    Init_Vars.ResortingY=[Init_Vars.ResortingX(1,:);Init_Vars.ResortingX(3:end,:)];
else
    Init_Vars.ResortingY=Init_Vars.ResortingX;
end
Init_Vars.ScalarsResorting=1:(numel(Init_Vars.PvNotSync)+handles.NumberOfOnTheFlyVariables);
if(Mode_of_Init==1)
    for II=1:handles.NumberOfAvailableFilters
            Init_Vars.CodiceFiltro(II).Code=TranslateCode(handles.Filter(II).Code,Init_Vars.ShotToShotScalarsResorting,2*(handles.ProfileProcessNumber+1)+Init_Vars.PvNumber+handles.TSandPulseIds+handles.NumberOfAvailableSignals,length(Init_Vars.ScalarsResorting),1);
    end 
    for II=1:handles.OutVariablesNumber
            Init_Vars.CodiceOut(II).Code=TranslateCode(handles.Out(II).Code,Init_Vars.ShotToShotScalarsResorting,2*(handles.ProfileProcessNumber+1)+Init_Vars.PvNumber+handles.TSandPulseIds+handles.NumberOfAvailableSignals,length(Init_Vars.ScalarsResorting),2);
    end
    for II=1:handles.NumberOfAvailableSignals
            Init_Vars.CodiceSig(II).Code=TranslateCode(handles.Signal(II).Code,Init_Vars.ShotToShotScalarsResorting,2*(handles.ProfileProcessNumber+1)+Init_Vars.PvNumber+handles.TSandPulseIds+handles.NumberOfAvailableSignals,length(Init_Vars.ScalarsResorting),0);
    end
elseif(Mode_of_Init==2)
    for II=1:handles.NumberOfAvailableFilters
            Init_Vars.CodiceFiltro(II).Code=TranslateCode_NotOnlineVER(handles.Filter(II).Code,handles,Init_Vars.SignalsResorting,Init_Vars.SynchPvResorting,Init_Vars.ProfQuantResorting,Init_Vars.PvNumber,Init_Vars.PvNotSyncNumber,1);
    end 
    for II=1:handles.NumberOfAvailableSignals
            Init_Vars.CodiceSig(II).Code=TranslateCode_NotOnlineVER(handles.Signal(II).Code,handles,Init_Vars.SignalsResorting,Init_Vars.SynchPvResorting,Init_Vars.ProfQuantResorting,Init_Vars.PvNumber,Init_Vars.PvNotSyncNumber,0);
    end
elseif(Mode_of_Init==3)
    for II=1:handles.NumberOfAvailableFilters
            Init_Vars.CodiceFiltro(II).Code=TranslateCode_NotOnlineVER(handles.Filter(II).Code,handles,Init_Vars.SignalsResorting,Init_Vars.SynchPvResorting,Init_Vars.ProfQuantResorting,Init_Vars.PvNumber,Init_Vars.PvNotSyncNumber,1);
    end 
    for II=1:handles.NumberOfAvailableSignals
            Init_Vars.CodiceSig(II).Code=TranslateCode_NotOnlineVER(handles.Signal(II).Code,handles,Init_Vars.SignalsResorting,Init_Vars.SynchPvResorting,Init_Vars.ProfQuantResorting,Init_Vars.PvNumber,Init_Vars.PvNotSyncNumber,4);
    end
end

function [myeDefNumber,new_name1,new_name2]=Initialize_Double_Buffer(handles,Init_Vars)
    new_name1='';
    new_name2='';
    myeDefNumber(1,2)=NaN;
try
    % Update run count
    lcaPut(handles.BufferCounterName{1}, 1+lcaGet(handles.BufferCounterName{1}));
    nRuns1 = lcaGetSmart(handles.BufferCounterName{1});
    lcaPut(handles.BufferCounterName{2}, 1+lcaGet(handles.BufferCounterName{2}));
    nRuns2 = lcaGetSmart(handles.BufferCounterName{2});
    if isnan(nRuns1) || isnan(nRuns2)
        disp(sprintf('Channel access failure for %s',handles.BufferCounterName{1}));
        disp(sprintf('Channel access failure for %s',handles.BufferCounterName{2}));
        return;
    end
catch MEIdentifiers
    disp('Had a problem trying to increment run count');
    return;
end
BufferName{1} = sprintf('OnlineMonitor_buffer_1_%d',nRuns1);
myeDefNumber(1) = eDefReserve(BufferName{1});
if isequal (myeDefNumber(1), 0)
    disp('Sorry, failed to get eDef for Buffer 1');
    myeDefNumber(1)=NaN;
    return;
end
BufferName{2} = sprintf('OnlineMonitor_buffer_2_%d',nRuns2);
myeDefNumber(2) = eDefReserve(BufferName{2});
if isequal (myeDefNumber(2), 0)
    disp('Sorry, failed to get eDef for Buffer 2');
    eDefRelease(myeDefNumber(1));
    myeDefNumber(2)=NaN;
    return;
end
sys='SYS0';
eDefParams (myeDefNumber(1), 1, 2800);
eDefParams (myeDefNumber(2), 1, 2800);
eDefOff(myeDefNumber(1));
eDefOff(myeDefNumber(2));

%Checks if more where already reserved and releases those
OldeDefs=get(handles.ReleaseeDefs,'Userdata');
if ~isempty(OldeDefs)
   for II=1:length(OldeDefs)
       eDefRelease(OldeDefs(1));
   end
end
new_name1 = strcat(Init_Vars.Pvlist, {'HST'}, {num2str(myeDefNumber(1))});
new_name2 = strcat(Init_Vars.Pvlist, {'HST'}, {num2str(myeDefNumber(2))});
set(handles.ReleaseeDefs,'Userdata',myeDefNumber);
set(handles.ReleaseeDefs,'backgroundcolor',handles.ColorON);
set(handles.ReleaseeDefs,'enable','on');

function [ONLINE,prof]=CheckOnlineMode(Init_Vars,handles)
try
    if(Init_Vars.ReadProfile)
        [prof,ts_old]=lcaGetSmart(Init_Vars.profile);
        ONLINE=1;
    else
        [prof,ts_old]=lcaGetSmart(Init_Vars.Pvlist{1});
        ONLINE=1;
    end
catch ME
    if(Init_Vars.ReadProfile)
        [prof,ts_old]=lcaGetDonk(Init_Vars.profile,1);
        ONLINE=0;
    else
        [prof,ts_old]=lcaGetDonk(Init_Vars.Pvlist{1},1);
        ONLINE=0;
    end
    set(handles.TextDIA,'String','FAKE OFFLINE MODE')
end

function delete_or_update_figures(handles)
UD=get(handles.CVCRCIISSA,'UserData');
FiguresList=UD{4};
ChildrenSorting=UD{5};
if(~isempty(FiguresList))
    for ScreenID=1:numel(FiguresList)
            try
                findobj(FiguresList(ScreenID));
                FigureStillOpen=1;
            catch ME
                FigureStillOpen=0;    
            end
            if(FigureStillOpen) %check for consitency, if ok... just keep it AS it is. Otherwise... reset what necessary, but keep it open
                X_SEL=get(ChildrenSorting(ScreenID,2),'string');
                set(ChildrenSorting(ScreenID,2),'Userdata',1);
                if(numel(UD{1})==numel(X_SEL))
                    if(sum(strcmp(UD{1}.',X_SEL))<numel(X_SEL))
                        set(ChildrenSorting(ScreenID,2),'value',1); set(ChildrenSorting(ScreenID,2),'string',UD{1});
                        petizione=get(ChildrenSorting(ScreenID,23),'Userdata');
                        petizione.X_SEL=1;
                        set(ChildrenSorting(ScreenID,23),'Userdata',petizione);
                    end
                else
                    set(ChildrenSorting(ScreenID,2),'value',1); set(ChildrenSorting(ScreenID,2),'string',UD{1});
                    petizione=get(ChildrenSorting(ScreenID,23),'Userdata'); petizione.X_SEL=1; set(ChildrenSorting(ScreenID,23),'Userdata',petizione);
                end
                Y_SEL1=get(ChildrenSorting(ScreenID,3),'string');
                if(numel(UD{2})==numel(Y_SEL1))
                    if(sum(strcmp(UD{2}.',Y_SEL1))<numel(Y_SEL1))
                        set(ChildrenSorting(ScreenID,3),'value',1); set(ChildrenSorting(ScreenID,3),'string',UD{2});
                        set(ChildrenSorting(ScreenID,4),'value',1); set(ChildrenSorting(ScreenID,4),'string',UD{2});
                        set(ChildrenSorting(ScreenID,5),'value',1); set(ChildrenSorting(ScreenID,5),'string',UD{2});
                        petizione=get(ChildrenSorting(ScreenID,23),'Userdata');
                        petizione.Y_SEL1=1; petizione.Y_SEL2=1; petizione.Y_SEL3=1;
                        set(ChildrenSorting(ScreenID,23),'Userdata',petizione);
                    end
                else
                    set(ChildrenSorting(ScreenID,3),'value',1); set(ChildrenSorting(ScreenID,3),'string',UD{2});
                    set(ChildrenSorting(ScreenID,4),'value',1); 
                    set(ChildrenSorting(ScreenID,4),'string',UD{2});
                    set(ChildrenSorting(ScreenID,5),'value',1); set(ChildrenSorting(ScreenID,5),'string',UD{2});
                    petizione=get(ChildrenSorting(ScreenID,23),'Userdata');
                    petizione.Y_SEL1=1; petizione.Y_SEL2=1; petizione.Y_SEL3=1;
                    set(ChildrenSorting(ScreenID,23),'Userdata',petizione);
                end
                Filtri=get(ChildrenSorting(ScreenID,12),'string');
                if(numel(UD{3})==numel(Filtri))
                    if(sum(strcmp(UD{3}.',Filtri))<numel(Filtri))
                        set(ChildrenSorting(ScreenID,12),'value',1); set(ChildrenSorting(ScreenID,12),'string',UD{3});
                        set(ChildrenSorting(ScreenID,13),'value',1); set(ChildrenSorting(ScreenID,13),'string',UD{3});
                        set(ChildrenSorting(ScreenID,14),'value',1); set(ChildrenSorting(ScreenID,14),'string',UD{3});
                        petizione=get(ChildrenSorting(ScreenID,23),'Userdata');
                        Petizione.Filt1=0; Petizione.Filt2=0; Petizione.Filt3=0;
                        set(ChildrenSorting(ScreenID,23),'Userdata',petizione);
                    end
                else
                    set(ChildrenSorting(ScreenID,12),'value',1); set(ChildrenSorting(ScreenID,12),'string',UD{3});
                    set(ChildrenSorting(ScreenID,13),'value',1); set(ChildrenSorting(ScreenID,13),'string',UD{3});
                    set(ChildrenSorting(ScreenID,14),'value',1); set(ChildrenSorting(ScreenID,14),'string',UD{3});
                    petizione=get(ChildrenSorting(ScreenID,23),'Userdata');
                    Petizione.Filt1=0; Petizione.Filt2=0; Petizione.Filt3=0;
                    set(ChildrenSorting(ScreenID,23),'Userdata',petizione);
                end
            else % Delete it from the list !
                if ((ScreenID==1) && (numel(FiguresList)==1) )
                    FiguresList=[];
                    ChildrenSorting=[];
                elseif((ScreenID==numel(FiguresList)))
                    FiguresList=FiguresList(1:(end-1));
                    ChildrenSorting=ChildrenSorting(1:(end-1),:);
                elseif(ScreenID==1)
                    FiguresList=FiguresList(2:end);
                    ChildrenSorting=ChildrenSorting(2:end,:);
                else
                    FiguresList=[FiguresList(1:(ScreenID-1)),FiguresList((ScreenID+1):end)];
                    ChildrenSorting=[ChildrenSorting(1:(ScreenID-1),:);ChildrenSorting((ScreenID+1),:)];
                end
                UD{4}=FiguresList;
                UD{5}=ChildrenSorting;
                set(handles.CVCRCIISSA,'UserData',UD);
                update_figure_list(handles);
            end
    end
end


% --- Executes on button press in Start3.
function Start3_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles);
KEEP_Pr=[];KEEP_Pr2=[];
guidata(hObject, handles);pause(10^-5);
set(handles.Stop3,'Enable','on');
set(handles.Stop3,'BackgroundColor',handles.ColorON);
set(handles.Start3,'Enable','off');
set(handles.Start3,'BackgroundColor',handles.ColorWait);
set(handles.Update_Figures_Cont,'enable','off');
set(handles.AppenOneBlockMore,'enable','off');
set(handles.CominciaModalitaSchiavo,'enable','off');
set(handles.NaClO,'enable','off');
Init_Vars=Initialize_Recording(handles,1);
if(Init_Vars.INIT_FAILED)
    return
end
ScreenToBeUpdated=Init_Vars.UpdateMode;
for II=1:handles.OutVariablesNumber
    eval(['set(',['handles.f',char(48+II)],',''String'',','Init_Vars.FiltersList)']);
    eval(['set(',['handles.f',char(48+II)],',''Value'',1)']);
end
[ONLINE,prof]=CheckOnlineMode(Init_Vars,handles);
lcaGetDonkCalls=ONLINE;

if(Init_Vars.usebsa)
    if(~Init_Vars.PvNumber)
        Init_Vars.usebsa=0;
        set(handles.c_BSA,'value',0);
    else 
        [myeDefNumber,new_name1,new_name2]=Initialize_Double_Buffer(handles,Init_Vars);
        PlusOne=get(handles.CV_PlusOne,'value');
        if(PlusOne)
            PlusOneName=new_name1{1}(1:end-4);
        end
        if(any(isnan(myeDefNumber)) || (any(myeDefNumber==0)))
            disp('eDef Initialization failed, going to non BSA mode')
            Init_Vars.usebsa=0;
            set(handles.c_BSA,'value',0);
        end
    end
end
set(handles.dialogotrasordi,'string','Buffer new el.')
if(Init_Vars.ReadProfile) % Get the size of the profile and decides if transpose the vector
[SA,SB]=size(prof);
    if(Init_Vars.Image2D)
        if(Init_Vars.ProjectionDirection==3)
            prof=reshape(prof,Init_Vars.CameraSize.Rows,Init_Vars.CameraSize.Columns);
            prof=prof(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
            proj1=mean(double(prof),1);
            proj2=mean(double(prof),2);
            if(~isempty(handles.BackgroundBlock))
               backg1=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
               backg2=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
               backg1=mean(double(backg1),1);
               backg2=mean(double(backg2),2);
            else
               backg1=0*proj1.'; backg2=0*proj2; 
            end
        else
            prof=reshape(prof,Init_Vars.CameraSize.Rows,Init_Vars.CameraSize.Columns);
            prof=prof(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
            proj=mean(double(prof),Init_Vars.ProjectionDirection);
            if(~isempty(handles.BackgroundBlock))
               backg=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
               backg=mean(double(backg),Init_Vars.ProjectionDirection);
            else
               backg=0*proj;
            end
            if Init_Vars.ProjectionDirection==1
                TRANSPOSE=1;
            else
                TRANSPOSE=0;
            end
        end
    else
        proj=prof(Init_Vars.ROIx(1):Init_Vars.ROIx(2));
        if(~isempty(handles.BackgroundBlock))
            backg=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2));
        else
            backg=0*proj;
        end
        if(SB==1)
            TRANSPOSE=1;
        else
            TRANSPOSE=0;
        end
    end
end
MAXPulseID=131040;
if(~Init_Vars.usebsa) %it is not a bsa acquisition, set up buffers
    if(Init_Vars.PvNumber)
        ReadCuePVs=zeros(Init_Vars.PvNumber,Init_Vars.blocksize);
        ReadCuePvsTS=zeros(Init_Vars.PvNumber,Init_Vars.blocksize);
    end
    if(Init_Vars.ReadProfile)
        if(Init_Vars.BothProfiles)
            ReadCueProf1=zeros(Init_Vars.blocksize,length(proj1));
            ReadCueProf2=zeros(Init_Vars.blocksize,length(proj2));
            KEEP_Pr=zeros(length(proj1),Init_Vars.keepsize);
            KEEP_Pr2=zeros(length(proj2),Init_Vars.keepsize);
        else 
            ReadCueProf=zeros(Init_Vars.blocksize,length(proj));
            KEEP_Pr=zeros(length(proj),Init_Vars.keepsize);
        end
        ReadCueProfTS=zeros(1,Init_Vars.blocksize);
    end
    ReadCueValid=1;
else %it is a bsa acquisition, set up buffers
    Buffer2_TS=zeros(2800,1);
    Buffer1_TS=zeros(2800,1);
    eDef_BASEDELAYTIMING=Init_Vars.DoubleBufferCycle; %seconds for one/other buffer
    Phase_Cycle=0;
    if(Init_Vars.ReadProfile)
        ReadCueProfTS=zeros(1,2800*2);
        PlusOne=1;
        if(PlusOne)
            ValuePlusOne=ReadCueProfTS;
            ReadCueProfTS_PlusOne=ReadCueProfTS;
        end
        if(~Init_Vars.BothProfiles)
            ReadCueProf=zeros(2800*2,length(proj));
            KEEP_Pr=zeros(length(proj),Init_Vars.keepsize);
        else
            ReadCueProf1=zeros(2800*2,length(proj1));
            ReadCueProf2=zeros(2800*2,length(proj2));
            KEEP_Pr=zeros(length(proj1),Init_Vars.keepsize);
            KEEP_Pr2=zeros(length(proj2),Init_Vars.keepsize);
        end
    else
       LastValidTime=1; 
    end
    ReadCueValid=1;
    Just_Started=1;
end

KEEP_PV=zeros(Init_Vars.PvNumber+Init_Vars.ReadProfile*(1+Init_Vars.BothProfiles)*(Init_Vars.BasicProcessing(2)+sum(Init_Vars.BasicProcessing))+2+sum(Init_Vars.SignalON),Init_Vars.keepsize);
%save TEMP
ValidDataPointer=1; FILLING=1;
UD=get(handles.CVCRCIISSA,'UserData');
UD{1}=Init_Vars.BaseLineX;UD{2}=Init_Vars.BaseLineY;UD{3}=Init_Vars.FiltersList;
set(handles.CVCRCIISSA,'UserData',UD);
delete_or_update_figures(handles)

ReadProfile=Init_Vars.ReadProfile; BothProfiles=Init_Vars.BothProfiles; Image2D=Init_Vars.Image2D; PvNumber=Init_Vars.PvNumber; blocksize=Init_Vars.blocksize; keepsize=Init_Vars.keepsize;
ROIx=Init_Vars.ROIx; ROIy=Init_Vars.ROIy; profile=Init_Vars.profile; Pvlist=Init_Vars.Pvlist; ProjectionDirection=Init_Vars.ProjectionDirection; CameraSize=Init_Vars.CameraSize;
BasicProcessing=Init_Vars.BasicProcessing; FilterON=Init_Vars.FilterON; SignalON=Init_Vars.SignalON; usebsa=Init_Vars.usebsa; PulseIDProfileDelay=Init_Vars.PulseIDProfileDelay;
CodiceFiltro=Init_Vars.CodiceFiltro; CodiceOut=Init_Vars.CodiceOut; CodiceSig=Init_Vars.CodiceSig; SingleValuePvs=Init_Vars.SingleValuePvs; SubtractiveConstant= Init_Vars.SubtractiveConstant;
ResortingX=Init_Vars.ResortingX; ResortingY=Init_Vars.ResortingY;FilterResorting=Init_Vars.FilterResorting;
%Read the single-valued variables
if(ONLINE)
   for II=1:numel(Init_Vars.PvNotSync)
       SingleValuePvs(end+1)=lcaGetSmart(Init_Vars.PvNotSync{II});
   end
else
   for II=1:numel(Init_Vars.PvNotSync)
       lcaGetDonkCalls=1;
       SingleValuePvs(end+1)=lcaGetDonk(Init_Vars.PvNotSync{II},lcaGetDonkCalls);
   end
end
% save TEMP

% M1A={};
% M2A={};
% M1TS={};
% M2TS={};
% SPTS={};
% GDA={};
% GDTS={};

% return
while(1) %Readout cycle
    handles = guidata(handles.output); 
    colore=get(handles.Stop3,'Backgroundcolor'); %Checks if read-out has been stopped
    if(sum(colore==handles.ColorWait)==3) %check for stop reading
        if(usebsa)
              eDefRelease(myeDefNumber(1));
              eDefRelease(myeDefNumber(2));
        end
      set(handles.Stop3,'Backgroundcolor',handles.ColorIdle);
      set(handles.Start3,'Backgroundcolor',handles.ColorON);
      set(handles.Stop3,'Enable','off');
      set(handles.Start3,'Enable','on');
      set(handles.Update_Figures_Cont,'enable','on');
      set(handles.AppenOneBlockMore,'enable','on');
      set(handles.CominciaModalitaSchiavo,'enable','on');
      set(handles.NaClO,'enable','on');
      handles=NaClO_Callback(hObject, eventdata, handles);
      guidata(hObject, handles);
      drawnow;
      return
    end
    if(usebsa) %bsa cycle for getting data synchronously
        ValidDataArray_PV=[];ValidPulseIDs=[];ValidTimeStamps=[];
                
        switch(Phase_Cycle)
            case 0
                if(Just_Started)
                eDefOn(myeDefNumber(1))
                end
            case 1
            case 2
            case 3    
        end
        tic
        % get Pvs if has to get Pvs
        while(toc < eDef_BASEDELAYTIMING) %just get profile monitor while you can
            if(ReadProfile)
                [Image,ReadCueProfTS(1,ReadCueValid)]=lcaGetSmart(profile); 
                if(PlusOne)
                    [ValuePlusOne(ReadCueValid),ReadCueProfTS_PlusOne(ReadCueValid)]=lcaGetSmart(PlusOneName);
                end
                    if(Image2D)
                        prof=reshape(Image,CameraSize.Rows,CameraSize.Columns);
                        prof=prof(ROIx(1):ROIx(2),ROIy(1):ROIy(2));
                        if(BothProfiles)
                            proj1=mean(double(prof),1)-backg1;
                            proj2=transpose(mean(double(prof),2))-backg2;
                        else
                            proj=mean(double(prof),ProjectionDirection)-backg;
                        end    
                    else
                        proj=double(Image(ROIx(1):ROIx(2)))-backg;
                    end
                    if(BothProfiles)
                        ReadCueProf1(ReadCueValid,:)=proj1;
                        ReadCueProf2(ReadCueValid,:)=proj2;
                    else
                        if(TRANSPOSE)
                            ReadCueProf(ReadCueValid,:)=transpose(proj);
                        else
                            ReadCueProf(ReadCueValid,:)=proj;
                        end  
                    end
             ReadCueValid=ReadCueValid+1; %Processing should take the time 
             %pause(eDef_BASEDELAYTIMING/2800*2); %Not sure if it is needed, puts a safeguard agains buffer filling
            else %only BSA acquisition, wait the posted time and do nothing
                pause(0.05);
            end
        end
        Phase_Cycle
        switch(Phase_Cycle)
            case 0
                if(Just_Started)
                eDefOn(myeDefNumber(2))
                end
                GrabTurn=0; 
            case 1
                eDefOff(myeDefNumber(1))
                %retrieve buffer 1
                [the_matrix1,TSY1] = lcaGetSmart(new_name1, 2800 );
                pulseID_Buffer1_TS = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',myeDefNumber(1)));
                pulseID_Buffer1_s = lcaGetSmart(sprintf('PATT:%s:1:SECHST%d','SYS0',myeDefNumber(1)));
                pulseID_Buffer1_ns = lcaGetSmart(sprintf('PATT:%s:1:NSECHST%d','SYS0',myeDefNumber(1)));
                eDefOn(myeDefNumber(1))
                if(Just_Started)
                  the_matrix2=the_matrix1;TSY2=TSY1;pulseID_Buffer2_TS=pulseID_Buffer1_TS;
                  pulseID_Buffer2_TS=pulseID_Buffer1_TS;
                  pulseID_Buffer2_s=pulseID_Buffer1_s;
                  pulseID_Buffer2_ns=pulseID_Buffer1_ns;
                  Just_Started=0;
                end
                %eDefOn(myeDefNumber(1));              
                GrabTurn=1;
            case 2
                if(Just_Started)
                eDefOn(myeDefNumber(1));
                end
                GrabTurn=0; 
            case 3
                eDefOff(myeDefNumber(2))
                [the_matrix2,TSY2] = lcaGetSmart(new_name2, 2800 );
                pulseID_Buffer2_TS = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',myeDefNumber(2)));
                pulseID_Buffer2_s = lcaGetSmart(sprintf('PATT:%s:1:SECHST%d','SYS0',myeDefNumber(2)));
                pulseID_Buffer2_ns = lcaGetSmart(sprintf('PATT:%s:1:NSECHST%d','SYS0',myeDefNumber(2)));
                eDefOn(myeDefNumber(2))
                %Buffer2_used = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d.NUSE','SYS0',myeDefNumber(2)));
                %[a,b,c]=util_readPVHst(new_name2, myeDefNumber(2));
                %save TEMP2
                GrabTurn=1;
                %eDefOn(myeDefNumber(2));
              
        end
        
        Phase_Cycle=mod((Phase_Cycle+1),4);   
        
        %Does the timestamps matching for BSA case
        if(ReadProfile) %Must Have also Pvs, altrimenti va in non bsa mode automaticamente, e' il piu' comprensibile su cosa deve fare
            %trova semplicemente i pvs che hanno lo stesso timestamps
                   
            if(GrabTurn)
            disp(['Grab Turn, read values ',num2str(ReadCueValid-1)])    
%             M1A{end+1}=the_matrix1;
%             M2A{end+1}=the_matrix2;
%             M1TS{end+1}=pulseID_Buffer1_TS;
%             M2TS{end+1}=pulseID_Buffer2_TS;
%             SPTS{end+1}=bitand(uint32(imag(ReadCueProfTS(1:(ReadCueValid-1)))),hex2dec('1FFFF'));
%             GDA{end+1}=ValuePlusOne(1:(ReadCueValid-1));
%             GDTS{end+1}=bitand(uint32(imag(ReadCueProfTS_PlusOne(1:(ReadCueValid-1)))),hex2dec('1FFFF'));          
%             save TEMP
            
            PulseIDPlusOne=bitand(uint32(imag(ReadCueProfTS_PlusOne(1:(ReadCueValid-1)))),hex2dec('1FFFF'));
            [~,Loc1,Loc2]=intersect(the_matrix1(1,:),ValuePlusOne(1:(ReadCueValid-1)),'stable');
            PIDM1=pulseID_Buffer1_TS(Loc1);
            PIDG1=PulseIDPlusOne(Loc2);
            DeltaPulseID1=double(PIDG1-uint32(PIDM1));
                                
            if(~isempty(Loc1))
                Delta1=mode(DeltaPulseID1);
                if(max(DeltaPulseID1)~=min(DeltaPulseID1))
                    disp(['Caution, Synch Jumping around on Buffer 1, ratio in synch = ',num2str(sum(DeltaPulseID1==Delta1)/length(DeltaPulseID1))]);
                end
            else
                disp('Caution, No Matches on buffer 1');
                Delta1=1;
            end
        
            [~,Loc3,Loc4]=intersect(the_matrix2(1,:),ValuePlusOne(1:(ReadCueValid-1)),'stable');
            PIDM2=pulseID_Buffer2_TS(Loc3);
            PIDG2=PulseIDPlusOne(Loc4);
            DeltaPulseID2=double(PIDG2-uint32(PIDM2));
            
            if(~isempty(Loc3))
                Delta2=mode(DeltaPulseID2);
                if(max(DeltaPulseID2)~=min(DeltaPulseID2))
                    disp(['Caution, Synch Jumping around on Buffer 2, ratio in synch = ',num2str(sum(DeltaPulseID2==Delta2)/length(DeltaPulseID2))]);
                end
            else
                disp('Caution, No Matches on buffer 2');
                Delta2=1;
            end
            
            PID1Rescaled=mod(pulseID_Buffer1_TS+Delta1,MAXPulseID);
            PID2Rescaled=mod(pulseID_Buffer2_TS+Delta2,MAXPulseID);
            
            pulseID_Profile=bitand(uint32(imag(ReadCueProfTS)),hex2dec('1FFFF'));
            FullMatrixTemporary=[the_matrix1,the_matrix2];
            Full_Temporary_PulseIds=[PID1Rescaled,PID2Rescaled];
            [uniquePulseID_Profile,uniquePulseID_Profile_Location]=unique(pulseID_Profile);
            disp(['Unique Profile read ',num2str(length(uniquePulseID_Profile_Location))])
            [SortedPulseIDUseless,DoveNellaMatrice,DoveNeiProfili]=intersect(Full_Temporary_PulseIds,uniquePulseID_Profile);
            
  %           pulseID_Buffer1_TS=bitand(uint32(imag(Buffer1_TS)),hex2dec('1FFFF'));
  %           pulseID_Buffer2_TS=bitand(uint32(imag(Buffer2_TS)),hex2dec('1FFFF'));
%               if(PlusOne)
%                     pulseID_PlusOne=bitand(uint32(imag(ReadCueProfTS_PlusOne(1:(ReadCueValid-1)))),hex2dec('1FFFF'));
%                     [IntersezioneInutile,DoveUtilePrimo,DoveUtileSecondo]=intersect(ValuePlusOne(1:(ReadCueValid-1)),the_matrix1(1,:));
%                     pulseID_Buffer1_TS=pulseID_PlusOne(DoveUtilePrimo);
%                     Empty1=the_matrix1;
%                     Empty2=the_matrix2;
%                     the_matrix1=the_matrix1(:,DoveUtileSecondo);
%                                         
%                     [length(unique(pulseID_PlusOne)), length(DoveUtileSecondo) ,length(pulseID_Buffer1_TS)]
%                     
%                     [IntersezioneInutile,DoveUtilePrimo,DoveUtileSecondo]=intersect(ValuePlusOne(1:(ReadCueValid-1)),the_matrix2(1,:));
%                     pulseID_Buffer2_TS=pulseID_PlusOne(DoveUtilePrimo);
%                     the_matrix2=the_matrix2(:,DoveUtileSecondo);
%                     
%                     [length(pulseID_PlusOne), length(DoveUtileSecondo), length(pulseID_Buffer2_TS) ]
% 
%               end  
%               
%               
%               
%               FullMatrixTemporary=[the_matrix1,the_matrix2];
%               Full_Temporary_PulseIds=[pulseID_Buffer1_TS,pulseID_Buffer2_TS];
%               pulseID_Profile=bitand(uint32(imag(ReadCueProfTS(1:(ReadCueValid-1)))),hex2dec('1FFFF'));
%               [uniquePulseID_Profile,uniquePulseID_Profile_Location]=unique(pulseID_Profile);
%               %ok
%               [SortedPulseIDUseless,DoveNellaMatrice,DoveNeiProfili]=intersect(Full_Temporary_PulseIds,uniquePulseID_Profile);
%               length(SortedPulseIDUseless)
%               [IInutileA,IInutile2,IInutile3]=intersect(pulseID_Buffer1_TS,uniquePulseID_Profile);
%               disp(['Contatore Letti', num2str(ReadCueValid)])
%               disp(['Profili Letti ', num2str(length(pulseID_Profile))])
%               disp(['Profili Unici ', num2str(length(uniquePulseID_Profile))])
%               [length(pulseID_Profile) length(uniquePulseID_Profile), length(IInutileA)]
%               [IInutileB,IInutile2,IInutile3]=intersect(pulseID_Buffer2_TS,uniquePulseID_Profile);
%               [length(pulseID_Profile) length(uniquePulseID_Profile), length(IInutileB)]
%               
%               [length(intersect(pulseID_PlusOne,uniquePulseID_Profile)),length(intersect(IInutileA,IInutileB))]
%               
%               the_matrix1=Empty1;
%               the_matrix2=Empty2;
%               
%               [FullBufferTimeStamps,LocationFullBuffer1,LocationFullBuffer2]=union(pulseID_Buffer1_TS,pulseID_Buffer2_TS);
%               [ValidPulseIDs,LocationFullBuffer,LocationInUniquePulseId_Profile]=intersect(FullBufferTimeStamps,uniquePulseID_Profile);
% 
%             
%             [uniquevalues_pr,uniquelocations_pr]=unique(pulseID_Profile);
%             ValidDataArray_PV=[];
%             if(~BothProfiles)
%                 ValidDataArray_Pr=ReadCueProf(uniquelocations_pr,:).'-SubtractiveConstant;
%             else
%                 ValidDataArray_Pr1=ReadCueProf1(uniquelocations_pr,:).'-SubtractiveConstant;
%                 ValidDataArray_Pr2=ReadCueProf2(uniquelocations_pr,:).'-SubtractiveConstant;
%             end
%             ValidPulseIDs=uniquevalues_pr;
%             ValidTimeStamps=ReadCueProfTS(uniquelocations_pr);


              if(~BothProfiles)
                  ValidDataArray_Pr=ReadCueProf(uniquePulseID_Profile_Location(DoveNeiProfili),:).'-SubtractiveConstant;
              else
                  ValidDataArray_Pr1=ReadCueProf1(uniquePulseID_Profile_Location(DoveNeiProfili),:).'-SubtractiveConstant;
                  ValidDataArray_Pr2=ReadCueProf2(uniquePulseID_Profile_Location(DoveNeiProfili),:).'-SubtractiveConstant;
              end
              ValidTimeStamps=ReadCueProfTS(uniquePulseID_Profile_Location(DoveNeiProfili));
              if(~isempty(SortedPulseIDUseless))
%                   [dontcare1,WhereTheywillGo,WhereIwillFoundthem]=intersect(FullBufferTimeStamps(LocationFullBuffer),pulseID_Buffer1_TS(LocationFullBuffer1));
                  ValidDataArray_PV=FullMatrixTemporary(:,DoveNellaMatrice);
                  ValidPulseIDs=Full_Temporary_PulseIds(DoveNellaMatrice);
              end
%               if(~isempty(LocationFullBuffer2))
%                   [dontcare1,WhereTheywillGo,WhereIwillFoundthem]=intersect(FullBufferTimeStamps(LocationFullBuffer),pulseID_Buffer2_TS(LocationFullBuffer2));
%                   ValidDataArray_PV(:,WhereTheywillGo)=the_matrix2(:,WhereIwillFoundthem);
%               end
              
              ReadCueValid=1; %After Grabbing, resets readcue ...
              
              size(ValidDataArray_PV)
              size(ValidPulseIDs)
              size(ValidTimeStamps)
              
              
              else
              ValidDataArray_PV=[];
              ValidPulseIDs=[];
              ValidTimeStamps=[]; 
               
            end
        else %Only Pvs, come fa a sapere da dove? (absolute time will do the trick, FILLING and Pointer =1 means just started)
          if(GrabTurn) 
            %save TEMP
%            pulseID_Buffer1_TS=bitand(uint32(imag(Buffer1_TS)),hex2dec('1FFFF'));
%            pulseID_Buffer2_TS=bitand(uint32(imag(Buffer2_TS)),hex2dec('1FFFF'));
           [FullBufferTimeStamps,LocationFullBuffer1,LocationFullBuffer2]=union(pulseID_Buffer1_TS,pulseID_Buffer2_TS);
           FullPulseIDs=[pulseID_Buffer1_TS(LocationFullBuffer1),pulseID_Buffer2_TS(LocationFullBuffer2)];
           TemporaryTimeStampsREAL=[pulseID_Buffer1_s(LocationFullBuffer1)+pulseID_Buffer1_ns(LocationFullBuffer1)/10^9,pulseID_Buffer2_s(LocationFullBuffer2)+pulseID_Buffer2_ns(LocationFullBuffer2)/10^9];
           FullMatrixTemporary=[the_matrix1(:,LocationFullBuffer1),the_matrix2(:,LocationFullBuffer2)];
           [SortedTimeStampsTemporary, SortedTimeStampsTemporaryOrder ]= sort(TemporaryTimeStampsREAL);
           firstgoodthisset=find(SortedTimeStampsTemporary>LastValidTime,1,'first');
           if(isempty(firstgoodthisset) && sum(any(~isnan(FullMatrixTemporary))))
               ValidDataArray_PV=[];
               ValidPulseIDs=[];
               ValidTimeStamps=[]; 
           else
               LastValidTime=max(SortedTimeStampsTemporary);
               ValidDataArray_PV=FullMatrixTemporary(:,SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
               ValidTimeStamps=TemporaryTimeStampsREAL(SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
               ValidPulseIDs=FullPulseIDs(SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
           end
          else
            ValidDataArray_PV=[];
            ValidPulseIDs=[];
            ValidTimeStamps=[]; 
          end
        end    
    else % not bsa data, just read and order in best effort mode
        if(ReadProfile)
            if(ONLINE)
                for ReadID=1:blocksize %read cycle
                    [Image,ReadCueProfTS(1,ReadID)]=lcaGetSmart(profile);
                    for PvID=1:PvNumber
                        [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID)]=lcaGetSmart(Pvlist{PvID});
                    end
                    if(Image2D)
                        prof=reshape(Image,CameraSize.Rows,CameraSize.Columns);
                        prof=prof(ROIx(1):ROIx(2),ROIy(1):ROIy(2));
                        if(BothProfiles)
                            proj1=mean(double(prof),1)-backg1;
                            proj2=transpose(mean(double(prof),2)-backg2);
                        else
                            proj=mean(double(prof),ProjectionDirection)-backg;
                        end    
                    else
                        proj=double(Image(ROIx(1):ROIx(2)))-backg;
                    end
                    if(BothProfiles)
                        ReadCueProf1(ReadID,:)=proj1;
                        ReadCueProf2(ReadID,:)=proj2;
                    else
                        if(TRANSPOSE)
                            ReadCueProf(ReadID,:)=transpose(proj);
                        else
                            ReadCueProf(ReadID,:)=proj;
                        end  
                    end
                end
            else % This else if for test (works only in offline mode to try viewer features or re-play data)
                for ReadID=1:blocksize %read cycle
                    [Image,ReadCueProfTS(1,ReadID),lcaGetDonkCalls]=lcaGetDonk(profile,lcaGetDonkCalls);
                    for PvID=1:PvNumber
                        [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID),lcaGetDonkCalls]=lcaGetDonk(Pvlist{PvID},lcaGetDonkCalls);
                    end
                    if(Image2D)
                        prof=reshape(Image,CameraSize.Rows,CameraSize.Columns);
                        prof=prof(ROIx(1):ROIx(2),ROIy(1):ROIy(2));
                        if(BothProfiles)
                            proj1=mean(double(prof),1)-backg1;
                            proj2=transpose(mean(double(prof),2)-backg2);
                        else
                            proj=mean(double(prof),ProjectionDirection)-backg;
                        end    
                    else
                        proj=double(Image(ROIx(1):ROIx(2)))-backg;
                    end
                    if(BothProfiles)
                        ReadCueProf1(ReadID,:)=proj1;
                        ReadCueProf2(ReadID,:)=proj2;
                    else
                        if(TRANSPOSE)
                            ReadCueProf(ReadID,:)=transpose(proj);
                        else
                            ReadCueProf(ReadID,:)=proj;
                        end  
                    end
                end  
            end % End of test else
        else
            if(ONLINE)
                for ReadID=1:blocksize
                    for PvID=1:PvNumber
                        [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID)]=lcaGetSmart(Pvlist{PvID});
                    end
                end
            else
                for ReadID=1:blocksize
                    for PvID=1:PvNumber
                        [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID),lcaGetDonkCalls]=lcaGetDonk(Pvlist{PvID},lcaGetDonkCalls);
                    end
                end
            end
        end
        
        % MatchTimeStamps
        
        if(ReadProfile && PvNumber) %Match all of them THIS PART OF CODE WORKS ONLY FOR NON-BSA MODE
            pulseID_Profile=bitand(uint32(imag(ReadCueProfTS)),hex2dec('1FFFF'))+PulseIDProfileDelay;
            ValidDataArray_PV=[];
            pulseID_Pvs=bitand(uint32(imag(ReadCuePvsTS)),hex2dec('1FFFF'));
            [UniqueProfilePulseIDs,UniqueLocations_Profile]=unique(pulseID_Profile);
            uniqueintersect=UniqueProfilePulseIDs;
            for PvID=1:PvNumber
                [UniquePvPulseID{PvID},UniquePvPulseID_Locations{PvID}]=unique(pulseID_Pvs(PvID,:));
                uniqueintersect=intersect(uniqueintersect,UniquePvPulseID{PvID});
            end
            [dontcare_isintersectback, Ordine, dontcare2_orderINuniqueintersect]=intersect(UniqueProfilePulseIDs,uniqueintersect);
            if(~BothProfiles)
                ValidDataArray_Pr=ReadCueProf(UniqueLocations_Profile(Ordine),:).'-SubtractiveConstant;
            else
                ValidDataArray_Pr1=ReadCueProf1(UniqueLocations_Profile(Ordine),:).'-SubtractiveConstant;
                ValidDataArray_Pr2=ReadCueProf2(UniqueLocations_Profile(Ordine),:).'-SubtractiveConstant;
            end
            ValidPulseIDs=dontcare_isintersectback;
            ValidTimeStamps=ReadCueProfTS(UniqueLocations_Profile(Ordine));
            for PvID=1:PvNumber
                [dontcare, IR, dontcare2]=intersect(UniquePvPulseID{PvID},uniqueintersect);
                ValidDataArray_PV(PvID,:)=ReadCuePVs(PvID,UniquePvPulseID_Locations{PvID}(IR));
            end 
        elseif(ReadProfile) %Only profile all good, just remove duplicates
            pulseID_Profile=bitand(uint32(imag(ReadCueProfTS)),hex2dec('1FFFF'));
            [uniquevalues_pr,uniquelocations_pr]=unique(pulseID_Profile);
            ValidDataArray_PV=[];
            if(~BothProfiles)
                ValidDataArray_Pr=ReadCueProf(uniquelocations_pr,:).'-SubtractiveConstant;
            else
                ValidDataArray_Pr1=ReadCueProf1(uniquelocations_pr,:).'-SubtractiveConstant;
                ValidDataArray_Pr2=ReadCueProf2(uniquelocations_pr,:).'-SubtractiveConstant;
            end
            ValidPulseIDs=uniquevalues_pr;
            ValidTimeStamps=ReadCueProfTS(uniquelocations_pr);
        else % Match Pvs
            ValidDataArray_PV=[];
            pulseID_Pvs=bitand(uint32(imag(ReadCuePvsTS)),hex2dec('1FFFF'));
            [uniquevalues{1},uniquelocations{1}]=unique(pulseID_Pvs(1,:));
            uniqueintersect=uniquevalues{1};
            for PvID=2:PvNumber
                [uniquevalues{PvID},uniquelocations{PvID}]=unique(pulseID_Pvs(PvID,:));
                uniqueintersect=intersect(uniqueintersect,uniquevalues{PvID});
            end
            for PvID=1:PvNumber
                [dontcare, IR, dontcare2]=intersect(uniquevalues{PvID},uniqueintersect);
                ValidDataArray_PV(PvID,:)=ReadCuePVs(PvID,uniquelocations{PvID}(IR));
            end
            ValidPulseIDs=uniqueintersect;
            ValidTimeStamps=ReadCuePvsTS(PvID,uniquelocations{PvID}(IR));
        end     
    end
    %save TEMP1 
    % ... Time Stamps ARE MATCHED here...  my variables are
    % ValidDataArray_PV, ValidPulseIDs, ValidTimeStamps, ValidDataArray_Pr,
    % ValidDataArray_Pr1, ValidDataArray_Pr2 Not all of them are always
    % defined.
    
    % If nothing was acquired this round, just leave a message that
    % something is going wrong (avoid updating cue with nothing, and updating display that doesn't change)
    if(isempty(ValidPulseIDs))
    disp(handles.extGui)
    disp('nothing acquired that has timestamp matched')
    pause(0.1);
    
    else
    % Evaluate Shot by Shot quantities (TOTAL INT, FWHM, PEAK VAL, PEAK POS, MEAN) and appends to the pvs list 
    EvaluatedProfileQuantities=[];
    if(ReadProfile)
        %save TEMP
        if(BothProfiles)
            [Prof1length1,NumberofShots]=size(ValidDataArray_Pr1); %SA=1024, SB number of data
            [Prof1length2,NumberofShots]=size(ValidDataArray_Pr2);
        else
            [Prof1length,NumberofShots]=size(ValidDataArray_Pr);
        end
        for ProcessCounter=1:handles.ProfileProcessNumber
            if(BasicProcessing(ProcessCounter))
                switch(ProcessCounter)
                    case 1 %Signal Sum
                        if(BothProfiles)
                            TotalArea1=sum(ValidDataArray_Pr1);
                            TotalArea2=sum(ValidDataArray_Pr2);
                            EvaluatedProfileQuantities(1,:)=TotalArea1;
                        else
                            TotalArea=sum(ValidDataArray_Pr);
                            EvaluatedProfileQuantities(1,:)=TotalArea;
                        end
                    case 2 %Peak and Peak Location
                        if(BothProfiles)
                            [PeakValue1,PeakPosition1]=max(ValidDataArray_Pr1);
                            [PeakValue2,PeakPosition2]=max(ValidDataArray_Pr2);
                            EvaluatedProfileQuantities(end+1,:)=PeakValue1;
                            EvaluatedProfileQuantities(end+1,:)=PeakPosition1;
                        else
                            [PeakValue,PeakPosition]=max(ValidDataArray_Pr);
                            EvaluatedProfileQuantities(end+1,:)=PeakValue;
                            EvaluatedProfileQuantities(end+1,:)=PeakPosition;
                        end
                    case 3 %First Moment
                        if(BothProfiles)
                            if(BasicProcessing(1))
                                FirstMoment1=(1:Prof1length1)*ValidDataArray_Pr1./TotalArea1;
                                FirstMoment2=(1:Prof1length2)*ValidDataArray_Pr2./TotalArea2;
                                EvaluatedProfileQuantities(end+1,:)=FirstMoment1;
                            else
                                FirstMoment1=(1:Prof1length1)*ValidDataArray_Pr1./sum(ValidDataArray_Pr1);
                                FirstMoment2=(1:Prof1length2)*ValidDataArray_Pr2./sum(ValidDataArray_Pr2);
                                EvaluatedProfileQuantities(end+1,:)=FirstMoment1;
                            end
                        else
                            if(BasicProcessing(1))
                                FirstMoment=(1:Prof1length)*ValidDataArray_Pr./TotalArea;
                                EvaluatedProfileQuantities(end+1,:)=FirstMoment;
                            else
                                FirstMoment=(1:Prof1length)*ValidDataArray_Pr./sum(ValidDataArray_Pr);
                                EvaluatedProfileQuantities(end+1,:)=FirstMoment;
                            end
                        end
                    case 4 %FWHM
                        if(BothProfiles)
                            if(~BasicProcessing(2))
                                [PeakValue1,PeakPosition1]=max(ValidDataArray_Pr1);
                                [PeakValue2,PeakPosition2]=max(ValidDataArray_Pr2);
                            end
                            FWHM1=zeros(1,length(ValidPulseIDs));FWHM2=zeros(1,length(ValidPulseIDs));
                            for II=1:NumberofShots
                                mv1=find(ValidDataArray_Pr1(:,II)>(PeakValue1(II)/2),1,'first');
                                MV1=find(ValidDataArray_Pr1(:,II)>(PeakValue1(II)/2),1,'last');
                                mv2=find(ValidDataArray_Pr2(:,II)>(PeakValue2(II)/2),1,'first');
                                MV2=find(ValidDataArray_Pr2(:,II)>(PeakValue2(II)/2),1,'last');
                                if(isempty(mv1) || isempty(MV1))
                                    FWHM1(II)=NaN;
                                else
                                    FWHM1(II)=MV1-mv1+1;
                                end
                                if(isempty(mv2) || isempty(MV2))
                                    FWHM2(II)=NaN;
                                else
                                    FWHM2(II)=MV2-mv2+1;
                                end
                            end   
                            EvaluatedProfileQuantities(end+1,:)=FWHM1;
                        else
                            if(~BasicProcessing(2))
                                [PeakValue,PeakPosition]=max(ValidDataArray_Pr);
                            end
                            FWHM=zeros(1,length(ValidPulseIDs));
                            for II=1:NumberofShots
                                mv=find(ValidDataArray_Pr(:,II)>(PeakValue(II)/2),1,'first');
                                MV=find(ValidDataArray_Pr(:,II)>(PeakValue(II)/2),1,'last');
                                if(isempty(mv) || isempty(MV))
                                    FWHM(II)=NaN;
                                else
                                    FWHM(II)=MV-mv+1;
                                end
                            end
                            EvaluatedProfileQuantities(end+1,:)=FWHM;
                        end
                end
            end
        end
        if(BothProfiles)
            for ProcessCounter=1:handles.ProfileProcessNumber
                if(BasicProcessing(ProcessCounter))
                    switch(ProcessCounter)
                        case 1 %Signal Sum
                            EvaluatedProfileQuantities(end+1,:)=TotalArea2;
                        case 2 %Peak and Peak Location
                            EvaluatedProfileQuantities(end+1,:)=PeakValue2;
                            EvaluatedProfileQuantities(end+1,:)=PeakPosition2;
                        case 3 %First Moment
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment2;
                        case 4 %FWHM
                            EvaluatedProfileQuantities(end+1,:)=FWHM2;
                    end
                end
            end
        end
    end
    %save TEMP2
    % Fills Current Structure to execute code
    ValidDataArray_PV=[EvaluatedProfileQuantities; real(ValidTimeStamps)+imag(ValidTimeStamps)/10^9 ;double(ValidPulseIDs); zeros(sum(SignalON),length(ValidPulseIDs)) ;  ValidDataArray_PV];
    if(BothProfiles && ReadProfile)
            ValidDataArray_Pr=ValidDataArray_Pr1;
    end
    %ValidDataArray_PV
    %ValidDataArray_Prhandles.NumberOfAvailableFilters=3;
    %handles.NumberOfAvailableSignals=3;
    %ValidDataArray_Pr2
    SignalEvaluated=1;
    for II=1:handles.NumberOfAvailableSignals
       if(SignalON(II))
           for III=1:numel(CodiceSig(II).Code)
                eval(CodiceSig(II).Code{III})
           end 
           ValidDataArray_PV(end-PvNumber-sum(SignalON)+SignalEvaluated,:)=CodeOutput;
           SignalEvaluated=SignalEvaluated+1;
       end
    end
    
    [SA,SB]=size(ValidDataArray_PV);
    % Update The Stack DA RICONTROLLARE ACCURATAMENTE
    if((ValidDataPointer+SB)>keepsize)
        ToTheEnd=keepsize-ValidDataPointer+1;
        KEEP_PV(:,ValidDataPointer:keepsize)=ValidDataArray_PV(:,1:ToTheEnd);
        ValidDataPointerNEW=1+mod(ValidDataPointer+SB,keepsize+1); %ValidDataPointerNEW=SB-(keepsize-ValidDataPointer+1)+1;
        if(ValidDataPointerNEW>1)
            KEEP_PV(:,1:(ValidDataPointerNEW-1))=ValidDataArray_PV(:,(ToTheEnd+1):end);
        end
        if(ReadProfile)
            KEEP_Pr(:,ValidDataPointer:keepsize)=ValidDataArray_Pr(:,1:ToTheEnd);
            if(ValidDataPointerNEW>1)
                KEEP_Pr(:,1:(ValidDataPointerNEW-1))=ValidDataArray_Pr(:,(ToTheEnd+1):end);
            end
            if(BothProfiles)
                KEEP_Pr2(:,ValidDataPointer:keepsize)=ValidDataArray_Pr2(:,1:ToTheEnd);
                if(ValidDataPointerNEW>1)
                    KEEP_Pr2(:,1:(ValidDataPointerNEW-1))=ValidDataArray_Pr2(:,(ToTheEnd+1):end);
                end
            end
        end
        ValidDataPointer=ValidDataPointerNEW;
        FILLING=0;
    else
        KEEP_PV(:,ValidDataPointer+(1:SB)-1)=ValidDataArray_PV;
        if(ReadProfile)
            KEEP_Pr(:,ValidDataPointer+(1:SB)-1)=ValidDataArray_Pr;
            if(BothProfiles)
                KEEP_Pr2(:,ValidDataPointer+(1:SB)-1)=ValidDataArray_Pr2;
            end
        end
        ValidDataPointer=ValidDataPointer+SB;
    end
    
    set(handles.dia_text_rec,'string',num2str(ValidDataPointer));
    
    if(FILLING)
        LastValidData=ValidDataPointer-1;
    else
        LastValidData=keepsize;
    end
%     save TEMP
%     return
    for II=1:3
       if(FilterON(II))
          for III=1:numel(CodiceFiltro(II).Code)
                eval(CodiceFiltro(II).Code{III})
          end
          Rimasti{II}=CodeOutput;
       end
    end
%  save TEMP
%  return
    %Computes Output Variables (if selected)
    for II=1:handles.OutVariablesNumber
        if(eval(['get(handles.q',char(48+II),',''value'')']))
            eval(['FilterType=-1+get(handles.f',char(48+II),',''value'');']);
            if(~FilterType)
               SHOTS_RIMASTI=1:LastValidData; 
            else
               SHOTS_RIMASTI=Rimasti{FilterResorting(FilterType)};
            end
            for III=1:numel(CodiceOut(II).Code)
                eval(CodiceOut(II).Code{III});
            end
            eval(['set(handles.v',char(48+II),',''string'',',num2str(CodeOutput),');']);
            if(ONLINE)
                lcaPutSmart(handles.PV(II).name,CodeOutput);
            end
        end
    end
    
    %save TEMP 
    %Update Screens
    drawnow
    pause(0.0001)
    %pause(0.000001) %DB Changed 10/09/14 bc stop3_callback wasn't working
    
    UD=get(handles.CVCRCIISSA,'UserData');
    FiguresList=UD{4};
    ChildrenSorting=UD{5};
    %if(0)
    
    if(~isempty(FiguresList))
        if(get(handles.c_update,'value'))
            ScreenToBeUpdated=ScreenToBeUpdated+1;
            if(ScreenToBeUpdated>numel(FiguresList))
                ScreenToBeUpdated=1;
            end
            LastScreen=ScreenToBeUpdated;
        else
            ScreenToBeUpdated=1;LastScreen=numel(FiguresList);
        end
        %[ScreenToBeUpdated:LastScreen]
        for ScreenID=ScreenToBeUpdated:LastScreen
            try
                Petizione=get(ChildrenSorting(ScreenID,23),'userdata');
                FigureStillOpen=1;
            catch ME
                FigureStillOpen=0;    
            end
            
%           save TEMP
            %FiguresList
            %Petizione
            %[ScreenID, FigureStillOpen]
            if(FigureStillOpen)
                cla(ChildrenSorting(ScreenID,1),'reset');
                hold(ChildrenSorting(ScreenID,1),'on');
            if(Petizione.SpecializedDisplay)
                handles.FunctionAnalysisListHandles{Petizione.SpecializedDisplay}(KEEP_PV,KEEP_Pr,KEEP_Pr2,SingleValuePvs(1:handles.NumberOfOnTheFlyVariables),SingleValuePvs((handles.NumberOfOnTheFlyVariables+1):end), LastValidData, ValidDataPointer,ChildrenSorting(ScreenID,:), UD{1}, Init_Vars.PvNotSync , profile, Petizione)
            else
%                 save TEMP
                switch(ResortingX(Petizione.X_SEL,1))
                    case 0 %SEL_X is off
                            if(ResortingY(Petizione.Y_SEL1,1))
                                if(Petizione.Filt1)
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),Rimasti{FilterResorting(Petizione.Filt1)});
                                else
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                                end
                                plot(ChildrenSorting(ScreenID,1),DataY1,'.k')
                            end
                            if(ResortingY(Petizione.Y_SEL2,1)) %something is selected on first
                                if(Petizione.Filt2)
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),Rimasti{FilterResorting(Petizione.Filt2)});
                                else
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                                end
                                plot(ChildrenSorting(ScreenID,1),DataY2,'.r')
                            end
                            if(ResortingY(Petizione.Y_SEL3,1)) %something is selected on first
                                if(Petizione.Filt3)
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),Rimasti{FilterResorting(Petizione.Filt3)});
                                else
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),1:LastValidData); 
                                end
                                plot(ChildrenSorting(ScreenID,1),DataY3,'.b')
                            end
                            if(Petizione.MostraMedie)
                                Legenda={};
                                if(ResortingY(Petizione.Y_SEL1,1))
                                    Legenda{end+1}=['mean= ',num2str(mean(DataY1)),'std= ',num2str(std(DataY1))];
                                end
                                if(ResortingY(Petizione.Y_SEL2,1))
                                    Legenda{end+1}=['mean= ',num2str(mean(DataY1)),'std= ',num2str(std(DataY2))];
                                end
                                if(ResortingY(Petizione.Y_SEL3,1))
                                    Legenda{end+1}=['mean= ',num2str(mean(DataY1)),'std= ',num2str(std(DataY3))];
                                end
                                legend(Legenda);
                            end
                            if(~Petizione.b_autoX)
                                CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                xlim(ChildrenSorting(ScreenID,1),CurrLim);
                            end
                            if(~Petizione.b_autoY)
                                CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                ylim(ChildrenSorting(ScreenID,1),CurrLim);
                            end
                    case 1 %SEL_X is a profile
                        %disp('SEL_X is a profile')
                        if((~ResortingY(Petizione.Y_SEL1,1)) && (~(ResortingY(Petizione.Y_SEL2,1)))) %No funny partitions, go ahead and plot the profile
                                  if(Petizione.Filt1)
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=KEEP_Pr(:,Rimasti{FilterResorting(Petizione.Filt1)});
                                      else
                                          DATAY1=KEEP_Pr2(:,Rimasti{FilterResorting(Petizione.Filt1)});
                                      end
                                  else
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=KEEP_Pr(:,1:LastValidData);
                                      else
                                          DATAY1=KEEP_Pr2(:,1:LastValidData);
                                      end
                                  end
                                  [s_temp1,s_temp2]=size(DATAY1);
                                  if(~isnan(Petizione.Calibration))
                                      if(length(Petizione.Calibration)==2)
                                          Xaxis=Petizione.Calibration(1)*(1:s_temp1);
                                          Xaxis=Xaxis-mean(Xaxis)+Petizione.Calibration(2);
                                      else
                                          Xaxis=Petizione.Calibration(1)*(1:s_temp1);
                                          Xaxis=Xaxis-mean(Xaxis);
                                      end
                                  else
                                      Xaxis=1:s_temp1;
                                  end
                                  if(s_temp2)
                                      if(Petizione.ShowAverage)
                                          plot(ChildrenSorting(ScreenID,1),Xaxis,mean(DATAY1,2),'k','LineWidth',1)
                                      end
                                      if(Petizione.ShowOne)
                                          plot(ChildrenSorting(ScreenID,1),Xaxis,DATAY1(:,mod(round(rand(1)*10^7),s_temp2)+1),'k','LineWidth',2)
                                      end
                                  end
                                  
                                  if(Petizione.Filt2)
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=KEEP_Pr(:,Rimasti{FilterResorting(Petizione.Filt2)});
                                      else
                                          DATAY1=KEEP_Pr2(:,Rimasti{FilterResorting(Petizione.Filt2)});
                                      end
                                      [s_temp1,s_temp2]=size(DATAY1);
                                      if(s_temp2)
                                          if(Petizione.ShowAverage)
                                            plot(ChildrenSorting(ScreenID,1),Xaxis,mean(DATAY1,2),'r','LineWidth',1)
                                          end
                                          if(Petizione.ShowOne)
                                              plot(ChildrenSorting(ScreenID,1),Xaxis,DATAY1(:,mod(round(rand(1)*10^7),s_temp2)+1),'r','LineWidth',2)
                                          end
                                      end
                                  end
                                  
                                  if(Petizione.Filt3)
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=KEEP_Pr(:,Rimasti{FilterResorting(Petizione.Filt3)});
                                      else
                                          DATAY1=KEEP_Pr2(:,Rimasti{FilterResorting(Petizione.Filt3)});
                                      end
                                      [s_temp1,s_temp2]=size(DATAY1);
                                      if(s_temp2)
                                          if(Petizione.ShowAverage)
                                            plot(ChildrenSorting(ScreenID,1),Xaxis,mean(DATAY1,2),'b','LineWidth',1)
                                          end
                                          if(Petizione.ShowOne)
                                              plot(ChildrenSorting(ScreenID,1),Xaxis,DATAY1(:,mod(round(rand(1)*10^7),s_temp2)+1),'b','LineWidth',2)
                                          end
                                      end
                                  end
                                  
                                  
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                        end
                        if(ResortingY(Petizione.Y_SEL1,1)) %A-Plot
                            if(Petizione.Filt1)
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=KEEP_Pr(:,Rimasti{FilterResorting(Petizione.Filt1)});
                                      else
                                          DATAX1=KEEP_Pr2(:,Rimasti{FilterResorting(Petizione.Filt1)});
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),Rimasti{FilterResorting(Petizione.Filt1)});
                            else
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=KEEP_Pr(:,1:LastValidData);
                                      else
                                          DATAX1=KEEP_Pr2(:,1:LastValidData);
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                            end
                            
                            if(Petizione.b_autoY)
                                MapYMin=min(DataY1);
                                MapYMax=max(DataY1);
                            else
                                MapYMin=Petizione.lim_y1;
                                MapYMax=Petizione.lim_y2;
                            end
                            [temp_size1,temp_size2]=size(DATAX1);
                            if(~isnan(Petizione.Calibration))
                                      if(length(Petizione.Calibration)==2)
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis)+Petizione.Calibration(2);
                                      else
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis);
                                      end
                            else
                                      XAxis=1:temp_size1;
                            end
%                             save TEMP
                            BinTheyFitInto=round((DataY1-MapYMin)/(MapYMax-MapYMin)*Petizione.binsy)+1;
                            MatrixToPlot=zeros(temp_size1,Petizione.binsy);
                            for BinsID=1:Petizione.binsy
                                if(any(BinTheyFitInto==BinsID))
                                    MatrixToPlot(:,BinsID)=mean(DATAX1(:,find(BinTheyFitInto==BinsID)),2);
                                end
                            end
                            imagesc(XAxis,linspace(MapYMin,MapYMax,Petizione.binsy),transpose(MatrixToPlot),'parent',ChildrenSorting(ScreenID,1));
                            xlim(ChildrenSorting(ScreenID,1),[min(XAxis),max(XAxis)]);
                            ylim(ChildrenSorting(ScreenID,1),[MapYMin,MapYMax]);
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                        end
                        if(~ResortingY(Petizione.Y_SEL1,1) && (ResortingY(Petizione.Y_SEL2,1))) %PartitionPlot
                            if(Petizione.Filt2)
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=KEEP_Pr(:,Rimasti{FilterResorting(Petizione.Filt2)});
                                      else
                                          DATAX1=KEEP_Pr2(:,Rimasti{FilterResorting(Petizione.Filt2)});
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),Rimasti{FilterResorting(Petizione.Filt2)});
                            else
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=KEEP_Pr(:,1:LastValidData);
                                      else
                                          DATAX1=KEEP_Pr2(:,1:LastValidData);
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                            end
                            if(Petizione.b_autoY)
                                MapYMin=min(DataY1);
                                MapYMax=max(DataY1);
                            else
                                MapYMin=Petizione.lim_y1
                                MapYMax=Petizione.lim_y2
                            end
                            [temp_size1,temp_size2]=size(DATAX1);
                            if(~isnan(Petizione.Calibration))
                                      if(length(Petizione.Calibration)==2)
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis)+Petizione.Calibration(2);
                                      else
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis);
                                      end
                            else
                                      XAxis=1:temp_size1;
                            end
                            BinTheyFitInto=round((DataY1-MapYMin)/(MapYMax-MapYMin)*Petizione.binsy)+1;
                            MatrixToPlot=zeros(temp_size1,Petizione.binsy);
                            for BinsID=1:Petizione.binsy
                                if(any(BinTheyFitInto==BinsID))
                                    MatrixToPlot(:,BinsID)=mean(DATAX1(:,find(BinTheyFitInto==BinsID)),2);
                                end
                            end
                             
                            PointersOfThisPlot=plot(ChildrenSorting(ScreenID,1),XAxis,MatrixToPlot);
                            if(length(PointersOfThisPlot)<=10)
                                if(exist('Legend','var')), clear Legend, end
                                Partitions=linspace(MapYMin,MapYMax,10);
                                for II=1:length(PointersOfThisPlot)
                                   Legend{II}=num2str(Partitions(II));
                                end
                                legend(ChildrenSorting(ScreenID,1),Legend);
                            end
                            xlim(ChildrenSorting(ScreenID,1),[min(XAxis),max(XAxis)]);
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                        end
                    case 2 %SEL_X is a shot to shot value
                         
                        DATAX1TEMP=KEEP_PV(ResortingX(Petizione.X_SEL,2),1:LastValidData);
                        if(~ResortingY(Petizione.Y_SEL1,1) && ~ResortingY(Petizione.Y_SEL2,1) && ~ResortingY(Petizione.Y_SEL3,1)) %Resort the buffer and plot
                                if(~FILLING)
                                   DataX1=DATAX1TEMP([ValidDataPointer:keepsize,1:(ValidDataPointer-1)]); 
                                else
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,'.k');
                        else    
                            if(ResortingY(Petizione.Y_SEL1,1)) %something is selected on first
                                if(Petizione.Filt1)
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),Rimasti{FilterResorting(Petizione.Filt1)});
                                   DataX1=DATAX1TEMP(:,Rimasti{FilterResorting(Petizione.Filt1)});
                                else
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,DataY1,'.k');
                            end
                            if(ResortingY(Petizione.Y_SEL2,1)) %something is selected on first
                                if(Petizione.Filt2)
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),Rimasti{FilterResorting(Petizione.Filt2)});
                                   DataX1=DATAX1TEMP(:,Rimasti{FilterResorting(Petizione.Filt2)});
                                else
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,DataY2,'.r');
                            end
                            if(ResortingY(Petizione.Y_SEL3,1)) %something is selected on first
                                if(Petizione.Filt3)
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),Rimasti{FilterResorting(Petizione.Filt3)});
                                   DataX1=DATAX1TEMP(:,Rimasti{FilterResorting(Petizione.Filt3)});
                                else
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),1:LastValidData); 
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,DataY3,'.b');
                            end
                        end
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                    case 3 %SEL_X is timestamp
                        DATAX1TEMP=KEEP_PV(ResortingX(Petizione.X_SEL,2),1:LastValidData);
                        DATAX1TEMP=DATAX1TEMP-min(DATAX1TEMP);
                        if(~ResortingY(Petizione.Y_SEL1,1) && ~ResortingY(Petizione.Y_SEL2,1) && ~ResortingY(Petizione.Y_SEL3,1)) %Resort the buffer and plot
                                if(~FILLING)
                                   DataX1=DATAX1TEMP([ValidDataPointer:keepsize,1:(ValidDataPointer-1)]); 
                                else
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,'.k');
                        else    
                            if(Petizione.TrasformaFourier)                                    
                                    FrequencyVectorDefined=0;
                            end
                            if(ResortingY(Petizione.Y_SEL1,1)) %something is selected on first
                                if(Petizione.Filt1)
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),Rimasti{FilterResorting(Petizione.Filt1)});
                                   DataX1=DATAX1TEMP(:,Rimasti{FilterResorting(Filt1)});
                                else
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                if(Petizione.TrasformaFourier)                                    
                                    FrequencyEstimate=round(1/median(diff(DataX1))); % da lavorare
                                    if(FrequencyEstimate>120), FrequencyEstimate=120;, end
                                    FrequencyVector=linspace(0,round(FrequencyEstimate/2),round(length(DataX1)/2));
                                    FrequencyVectorDefined=1;
                                    [SortTime,TimeOrder]=sort(DataX1);
                                    TrasformatadiFourier=fft(DataY1(TimeOrder)-mean(DataY1));
                                    %DataY1=abs(exp(1i*2*pi*FrequencyVector.'*SortTime )*transpose((DataY1(TimeOrder)-mean(DataY1))))/length(SortTime);
                                    plot(ChildrenSorting(ScreenID,1),FrequencyVector,abs(TrasformatadiFourier(1:round(length(DataX1)/2))),'.k');
                                else
                                    plot(ChildrenSorting(ScreenID,1),DataX1,DataY1,'.k');
                                end
                            end
                            if(ResortingY(Petizione.Y_SEL2,1)) %something is selected on first
                                if(Petizione.Filt2)
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),Rimasti{FilterResorting(Petizione.Filt2)});
                                   DataX1=DATAX1TEMP(:,Rimasti{FilterResorting(Petizione.Filt2)});
                                else
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                if(Petizione.TrasformaFourier)
                                    FrequencyEstimate=round(1/median(diff(DataX1))); % da lavorare
                                    if(~FrequencyVectorDefined), FrequencyVector=linspace(0,round(FrequencyEstimate/2),round(length(DataX1)/2));, FrequencyVectorDefined=1;, end
                                    [SortTime,TimeOrder]=sort(DataX1);
                                    TrasformatadiFourier=fft(DataY2(TimeOrder)-mean(DataY2));
                                    %DataY2=abs(exp(1i*2*pi*FrequencyVector.'*SortTime )*transpose((DataY2(TimeOrder)-mean(DataY2))))/length(SortTime);
                                    plot(ChildrenSorting(ScreenID,1),FrequencyVector,abs(TrasformatadiFourier(1:round(length(DataX1)/2))),'.r');
                                    %plot(ChildrenSorting(ScreenID,1),FrequencyVector,DataY2,'.r');
                                else
                                    plot(ChildrenSorting(ScreenID,1),DataX1,DataY2,'.r');
                                end
                            end
                            if(ResortingY(Petizione.Y_SEL3,1)) %something is selected on first
                                if(Petizione.Filt3)
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),Rimasti{FilterResorting(Petizione.Filt3)});
                                   DataX1=DATAX1TEMP(:,Rimasti{FilterResorting(Petizione.Filt3)});
                                else
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),1:LastValidData); 
                                   DataX1=DATAX1TEMP;
                                end
                                if(Petizione.TrasformaFourier)
                                    FrequencyEstimate=round(1/median(diff(DataX1))); % da lavorare
                                    if(~FrequencyVectorDefined), FrequencyVector=linspace(0,round(FrequencyEstimate/2),round(length(DataX1)/2));, FrequencyVectorDefined=1;, end
                                    [SortTime,TimeOrder]=sort(DataX1);
                                    TrasformatadiFourier=fft(DataY3(TimeOrder)-mean(DataY3));
                                    %DataY3=abs(exp(1i*2*pi*FrequencyVector.'*SortTime )*transpose((DataY3(TimeOrder)-mean(DataY3))))/length(SortTime);
                                    plot(ChildrenSorting(ScreenID,1),FrequencyVector,abs(TrasformatadiFourier(1:round(length(DataX1)/2))),'.b');
                                    %plot(ChildrenSorting(ScreenID,1),FrequencyVector,DataY3,'.b');
                                else
                                    plot(ChildrenSorting(ScreenID,1),DataX1,DataY3,'.b');
                                end
                            end  
                        end
                        if(~Petizione.b_autoX)
                            CurrLim=xlim(ChildrenSorting(ScreenID,1));
                            if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                            if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                            xlim(ChildrenSorting(ScreenID,1),CurrLim);
                        end
                        if(~Petizione.b_autoY)
                            CurrLim=ylim(ChildrenSorting(ScreenID,1));
                            if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                            if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                            ylim(ChildrenSorting(ScreenID,1),CurrLim);
                        end
                    
                end
            end %*%
            %insert function to copy figures
            if handles.extGui
                handles =  sendImage(hObject, handles);
            end
            
            if(Petizione.LogBookAndSave || Petizione.LogBookOnlyFigure)
                CurrentTime=clock;
%                 CurrentYearString=num2str(CurrentTime(1));
%                 CurrentMonthString=num2str(CurrentTime(2));
%                 
                %timestamp=clock;
                CurrentYearString=num2str(CurrentTime(1),'%.4d');
                CurrentMonthString=num2str(CurrentTime(2),'%.2d');
                CurrentDieiString=num2str(CurrentTime(3),'%.2d');
                CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
                CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
                CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
                CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
                CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];          
                for II=1:Petizione.LogBookAndSave
                    NewFigure=figure; 			% Create a new figure
                    %NewAxes=axes;		% Create an axes object in the figure
                    Newhandle = copyobj(ChildrenSorting(ScreenID,1),NewFigure);
                    title(CurrentTimeString);
                    Petizione.LogBookAndSave=0;
                    set(ChildrenSorting(ScreenID,23),'userdata',Petizione);
                    saving_string=' ';
                    %util_eLogEntry(fig, datenum(CurrentTime), logBook, varargin)
                    util_printLog(NewFigure);
                    AllowedXAxisNames=UD{1};
                    if(exist('KEEP_PV','var'))
                       saving_string=[saving_string,'KEEP_PV',' ']; 
                    end
                    if(exist('KEEP_Pr','var'))
                       saving_string=[saving_string,'KEEP_Pr',' ']; 
                       if(ReadProfile)
                            saving_string=[saving_string,'profile',' ']; %it has at least a profile 
                       end
                    end
                    if(exist('KEEP_Pr2','var'))
                       saving_string=[saving_string,'KEEP_Pr2',' ']; 
                    end
                    if(exist('SingleValuePvs','var'))
                       saving_string=[saving_string,'SingleValuePvs',' ']; 
                    end
                    saving_string=[saving_string,'AllowedXAxisNames',' ']; 
                    eval(['save /u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'/MonitorGui-',CurrentTimeString,' ',saving_string]);     
                end
                for II=1:Petizione.LogBookOnlyFigure
                    NewFigure=figure; 			% Create a new figure
                    %NewAxes=axes;		% Create an axes object in the figure
                    Newhandle = copyobj(ChildrenSorting(ScreenID,1),NewFigure);
                    title(['Not Saved - ',CurrentTimeString]);
                    Petizione.LogBookOnlyFigure=0;
                    set(ChildrenSorting(ScreenID,23),'userdata',Petizione);
                    util_printLog(NewFigure);
                    %util_eLogEntry(fig, datenum(CurrentTime), logBook, varargin)
                end
            end      
            else %Delete it from list
                if ((ScreenID==1) && (numel(FiguresList)==1) )
                    FiguresList=[];
                    ChildrenSorting=[];
                elseif((ScreenID==numel(FiguresList)))
                    FiguresList=FiguresList(1:(end-1));
                    ChildrenSorting=ChildrenSorting(1:(end-1),:);
                elseif(ScreenID==1)
                    FiguresList=FiguresList(2:end);
                    ChildrenSorting=ChildrenSorting(2:end,:);
                else
                    FiguresList=[FiguresList(1:(ScreenID-1)),FiguresList((ScreenID+1):end)];
                    ChildrenSorting=[ChildrenSorting(1:(ScreenID-1),:);ChildrenSorting((ScreenID+1),:)];
                end
                UD{4}=FiguresList;
                UD{5}=ChildrenSorting;
                set(handles.CVCRCIISSA,'UserData',UD);
                update_figure_list(handles);
            end
        end
    end
    %end
    end
    if handles.pauseSXRSS
% %             AddVisPan_Callback(hObject,[], handles);
% %             [ho3, h3]=util_appFind('CVS_CVCRCI_visualization_gui')
% %             Stop3_Callback(hObject, [], handles)
% %             set(h3.Y_SEL1,'Value',4)
% %             handles.pauseSXRSS = 0;
% %             guidata(hObject, handles);
% %             SXRSS_gui('startRead_btn_Callback',hObject, [], handles.h1);
% %             Start3_Callback(hObject, [], handles);
       Stop3_Callback(hObject, [], handles)
       set(handles.h3.Y_SEL1,'Value',4)
       CVS_CVCRCI_visualization_gui('Y_SEL1_Callback', handles.ho3, [], handles.h3)
       handles.pauseSXRSS = 0;
       guidata(hObject, handles);
       SXRSS_gui('startRead_btn_Callback',hObject, [], handles.h1)
       Start3_Callback(hObject, [], handles)
    end
end

function OutCode=TranslateCode(Code,ShotToShotScalarsResorting,CL2,CL1,FLAG)

%ValidDataArray_PV
%ValidDataArray_Pr
%ValidDataArray_Pr2
%SingleValuePvs

%KEEP_Pr, KEEP_Pr2 already defined...TranslateCode

if(FLAG==1)
    str1='KEEP_PV';
    str2='KEEP_Pr(:,1:LastValidData)';
    str3='KEEP_Pr2(:,1:LastValidData)';
elseif(FLAG==2)
    str1='KEEP_PV';
    str2='KEEP_Pr(:,1:SHOTS_RIMASTI)';
    str3='KEEP_Pr2(:,1:SHOTS_RIMASTI)';
else
    str1='ValidDataArray_PV';
    str2='ValidDataArray_Pr';
    str3='ValidDataArray_Pr2';
end

%replace variables
for II=1:numel(Code)
   for JJ=CL1:-1:1
       Code{II}=regexprep(Code{II},['%',num2str(JJ)],['SingleValuePvs(',num2str(JJ),')']);
   end
   for JJ=CL2:-1:1
       Resort=find(ShotToShotScalarsResorting==JJ);
       if(FLAG==1)
           Code{II}=regexprep(Code{II},['#',num2str(JJ)],[str1,'(',num2str(Resort),',1:LastValidData)']);
       elseif(FLAG==2)
           Code{II}=regexprep(Code{II},['#',num2str(JJ)],[str1,'(',num2str(Resort),',SHOTS_RIMASTI)']);
       else   
           Code{II}=regexprep(Code{II},['#',num2str(JJ)],[str1,'(',num2str(Resort),',:)']);
       end
   end
   Code{II}=regexprep(Code{II},'!','TemporaryVariable');
   Code{II}=regexprep(Code{II},'FirstProfile',str2);
   Code{II}=regexprep(Code{II},'SecondProfile',str3);
end
% for II=1:numel(Code)
%     disp(Code{II})
% end
OutCode=Code;
% for II=1:numel(CurrentCode)
%    eval(CurrentCode{II}); 
% end



% --- Executes on button press in Stop3.
function Stop3_Callback(hObject, eventdata, handles)
set(handles.Stop3,'Backgroundcolor',handles.ColorWait);
drawnow
pause(0.1)


function e_background_Callback(hObject, eventdata, handles)
% hObject    handle to e_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_background as text
%        str2double(get(hObject,'String')) returns contents of e_background as a double


% --- Executes during object creation, after setting all properties.
function e_background_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_roiy1_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles); guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_roiy1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_roiy1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_roiy2_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles); guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_roiy2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_roiy2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_pause_Callback(hObject, eventdata, handles)
% hObject    handle to e_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_pause as text
%        str2double(get(hObject,'String')) returns contents of e_pause as a double


% --- Executes during object creation, after setting all properties.
function e_pause_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PvSyncList.
function PvSyncList_Callback(hObject, eventdata, handles)
% hObject    handle to PvSyncList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PvSyncList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PvSyncList


% --- Executes during object creation, after setting all properties.
function PvSyncList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PvSyncList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ProfileMonitorName_Callback(hObject, eventdata, handles)
% hObject    handle to ProfileMonitorName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ProfileMonitorName as text
%        str2double(get(hObject,'String')) returns contents of ProfileMonitorName as a double


% --- Executes during object creation, after setting all properties.
function ProfileMonitorName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProfileMonitorName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ProfileMonitorMenu.
function ProfileMonitorMenu_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles); guidata(hObject, handles);

switch(get(handles.ProfileMonitorMenu,'value'))
    case 1
        set(handles.ProfileMonitorName,'String','');
        CameraSize.Rows=NaN;
        CameraSize.Columns=NaN;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1);
        set(handles.e_roix1,'enable','off');set(handles.e_roix2,'enable','off');
        set(handles.e_roiy1,'enable','off');set(handles.e_roiy2,'enable','off');
        set(handles.ProfileMonitorName,'UserData',CameraSize);
    case 2
        set(handles.ProfileMonitorName,'String','SXR:EXS:CVV:01:IMAGE_CMPX:HPrj');
        try
            CameraSize.Rows=lcaGetSmart('SXR:EXS:CVV:01:ROI_YNP_SET');
        catch ME
            disp('unable to read image size')
            CameraSize.Rows=1024;
        end
        
        CameraSize.Columns=1;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','off');set(handles.e_roiy2,'enable','off');
        set(handles.ProfileMonitorName,'UserData',CameraSize);
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','-3');
        end
    case 3
        set(handles.ProfileMonitorName,'String','SXR:EXS:CVV:01:LIVE_IMAGE_FAST');
        CameraSize.Rows=1024;
        CameraSize.Columns=256;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',256);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','on');set(handles.e_roiy2,'enable','on');
        set(handles.ProfileMonitorName,'UserData',CameraSize);
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','-3');
        end
    case 4
        set(handles.ProfileMonitorName,'String','SXR:EXS:CVV:01:IMAGE_CMPX:VPrj');
        CameraSize.Rows=1;
        try
            CameraSize.Rows=lcaGetSmart('SXR:EXS:CVV:01:ROI_XNP_SET');
        catch ME
            disp('unable to read image size')
            CameraSize.Columns=256;
        end
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',256);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','off');set(handles.e_roiy2,'enable','off');
        set(handles.ProfileMonitorName,'UserData',CameraSize);
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','-3');
        end
    case 5
      disp('5')
        set(handles.ProfileMonitorName,'String','CAMR:FEE1:441:IMAGE_CMPX:HPrj');
        CameraSize.Rows=1;
        CameraSize.Columns=1024;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','off');set(handles.e_roiy2,'enable','off');
        set(handles.ProfileMonitorName,'UserData',CameraSize);
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','+3');
        end
    case 6
        set(handles.ProfileMonitorName,'String','CAMR:FEE1:441:IMAGE_CMPX');
        CameraSize.Rows=1024;
        CameraSize.Columns=256;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',256);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','on');set(handles.e_roiy2,'enable','on');
        set(handles.ProfileMonitorName,'UserData',CameraSize);    
        set(handles.ProjectionXY,'value',2)
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','+3');
        end
    case 7
        set(handles.ProfileMonitorName,'String','MEC:OPAL1K:1:IMAGE_CMPX:HPrj');
        CameraSize.Rows=1;
        CameraSize.Columns=1024;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','on');set(handles.e_roiy2,'enable','on');
        set(handles.ProfileMonitorName,'UserData',CameraSize);    
        set(handles.ProjectionXY,'value',2)
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','0');
        end
    case 8
        set(handles.ProfileMonitorName,'String','CXI:EXS:HISTP');
        CameraSize.Rows=1;
        CameraSize.Columns=1024;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','on');set(handles.e_roiy2,'enable','on');
        set(handles.ProfileMonitorName,'UserData',CameraSize);    
        set(handles.ProjectionXY,'value',2)
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','0');
        end
    case 9
        set(handles.ProfileMonitorName,'String','DIAG:FEE1:482:LIVE_IMAGE_FAST');
        CameraSize.Rows=1024;
        CameraSize.Columns=1024;
        set(handles.e_roix1,'String',1);set(handles.e_roix2,'String',1024);
        set(handles.e_roiy1,'String',1);set(handles.e_roiy2,'String',1024);
        set(handles.e_roix1,'enable','on');set(handles.e_roix2,'enable','on');
        set(handles.e_roiy1,'enable','on');set(handles.e_roiy2,'enable','on');
        set(handles.ProfileMonitorName,'UserData',CameraSize);    
        set(handles.ProjectionXY,'value',3)
        if(get(handles.c_BSA,'value'))
            set(handles.PulseID_delay,'string','0');
        else
            set(handles.PulseID_delay,'string','0');
        end  
    otherwise
        set(handles.ProfileMonitorName,'String','');
        CameraSize.Rows=NaN;
        CameraSize.Columns=NaN;
        set(handles.ProfileMonitorName,'UserData',CameraSize);
end



% --- Executes during object creation, after setting all properties.
function ProfileMonitorMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProfileMonitorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_keeplast_Callback(hObject, eventdata, handles)
% hObject    handle to e_keeplast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_keeplast as text
%        str2double(get(hObject,'String')) returns contents of e_keeplast as a double


% --- Executes during object creation, after setting all properties.
function e_keeplast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_keeplast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_roix1_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles); guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_roix1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_roix1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_roix2_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles); guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_roix2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_roix2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in ProjectionXY.
function ProjectionXY_Callback(hObject, eventdata, handles)
handles=NaClO_Callback(hObject, eventdata, handles); guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ProjectionXY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProjectionXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in c_BSA.
function c_BSA_Callback(hObject, eventdata, handles)
ProfileMonitorMenu_Callback(hObject, eventdata, handles)

function e_block_Callback(hObject, eventdata, handles)
% hObject    handle to e_block (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_block as text
%        str2double(get(hObject,'String')) returns contents of e_block as a double


% --- Executes during object creation, after setting all properties.
function e_block_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_block (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in c_Filter1.
function c_Filter1_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


function handles=ReEvaluateBuffer(handles)
Init_Vars=Initialize_Recording(handles,3);
ReadProfile=Init_Vars.ReadProfile; BothProfiles=Init_Vars.BothProfiles;
BasicProcessing=Init_Vars.BasicProcessing; FilterON=Init_Vars.FilterON; SignalON=Init_Vars.SignalON;
CodiceFiltro=Init_Vars.CodiceFiltro; CodiceSig=Init_Vars.CodiceSig; handles.SingleValuePvs=Init_Vars.SingleValuePvs;
EvaluatedProfileQuantities2=[];
EvaluatedProfileQuantities=[];
if(ReadProfile)
    if(BothProfiles)  
        [Prof1length1,NumberofShots]=size(handles.Buffer.Prof); %SA=1024, SB number of data
        [Prof1length2,NumberofShots]=size(handles.Buffer.Prof2);
    else
        [Prof1length,NumberofShots]=size(handles.Buffer.Prof);
    end    
    for ProcessCounter=1:handles.ProfileProcessNumber
        if(BasicProcessing(ProcessCounter))
            switch(ProcessCounter)
                case 1 %Signal Sum
                    if(BothProfiles)
                        TotalArea1=sum(handles.Buffer.Prof);
                        TotalArea2=sum(handles.Buffer.Prof2);
                        EvaluatedProfileQuantities(1,:)=TotalArea1;
                        EvaluatedProfileQuantities2(1,:)=TotalArea2;
                    else
                        TotalArea=sum(handles.Buffer.Prof);
                        EvaluatedProfileQuantities(1,:)=TotalArea;
                    end
                case 2 %Peak and Peak Location
                    if(BothProfiles)
                        [PeakValue1,PeakPosition1]=max(handles.Buffer.Prof);
                        [PeakValue2,PeakPosition2]=max(handles.Buffer.Prof2);
                        EvaluatedProfileQuantities(end+1,:)=PeakValue1;
                        EvaluatedProfileQuantities(end+1,:)=PeakPosition1;
                        EvaluatedProfileQuantities2(end+1,:)=PeakValue2;
                        EvaluatedProfileQuantities2(end+1,:)=PeakPosition2;
                    else
                        [PeakValue,PeakPosition]=max(handles.Buffer.Prof);
                        EvaluatedProfileQuantities(end+1,:)=PeakValue;
                        EvaluatedProfileQuantities(end+1,:)=PeakPosition;
                    end
                case 3 %First Moment
                    if(BothProfiles)
                        if(BasicProcessing(1))
                            FirstMoment1=(1:Prof1length1)*handles.Buffer.Prof./TotalArea1;
                            FirstMoment2=(1:Prof1length2)*handles.Buffer.Prof2./TotalArea2;
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment1;
                            EvaluatedProfileQuantities2(end+1,:)=FirstMoment2;
                        else
                            FirstMoment1=(1:Prof1length1)*handles.Buffer.Prof./sum(handles.Buffer.Prof);
                            FirstMoment2=(1:Prof1length2)*handles.Buffer.Prof2./sum(handles.Buffer.Prof2);
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment1;
                            EvaluatedProfileQuantities2(end+1,:)=FirstMoment2;
                        end
                    else
                        if(BasicProcessing(1))
                            FirstMoment=(1:Prof1length)*handles.Buffer.Prof./TotalArea;
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment;
                        else
                            FirstMoment=(1:Prof1length)*handles.Buffer.Prof./sum(handles.Buffer.Prof);
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment;
                        end
                    end
                case 4 %FWHM
                    if(BothProfiles)
                        if(~BasicProcessing(2))
                            [PeakValue1,PeakPosition1]=max(handles.Buffer.Prof);
                            [PeakValue2,PeakPosition2]=max(handles.Buffer.Prof2);
                        end
                        FWHM1=zeros(1,NumberofShots);FWHM2=zeros(1,NumberofShots);
                        for II=1:NumberofShots
                            mv1=find(handles.Buffer.Prof(:,II)>(PeakValue1(II)/2),1,'first');
                            MV1=find(handles.Buffer.Prof(:,II)>(PeakValue1(II)/2),1,'last');
                            mv2=find(handles.Buffer.Prof2(:,II)>(PeakValue2(II)/2),1,'first');
                            MV2=find(handles.Buffer.Prof2(:,II)>(PeakValue2(II)/2),1,'last');
                            if(isempty(mv1) || isempty(MV1))
                                FWHM1(II)=NaN;
                            else
                                FWHM1(II)=MV1-mv1+1;
                            end
                            if(isempty(mv2) || isempty(MV2))
                                FWHM2(II)=NaN;
                            else
                                FWHM2(II)=MV2-mv2+1;
                            end
                        end   
                        EvaluatedProfileQuantities(end+1,:)=FWHM1;
                        EvaluatedProfileQuantities2(end+1,:)=FWHM2;
                    else
                        if(~BasicProcessing(2))
                            [PeakValue,PeakPosition]=max(handles.Buffer.Prof);
                        end
                        FWHM=zeros(1,NumberofShots);
                        for II=1:NumberofShots
                            mv=find(handles.Buffer.Prof(:,II)>(PeakValue(II)/2),1,'first');
                            MV=find(handles.Buffer.Prof(:,II)>(PeakValue(II)/2),1,'last');
                            if(isempty(mv) || isempty(MV))
                                FWHM(II)=NaN;
                            else
                                FWHM(II)=MV-mv+1;
                            end
                        end
                        EvaluatedProfileQuantities(end+1,:)=FWHM;
                    end
            end
        end
    end  
end
handles.Buffer.ProfQuant=EvaluatedProfileQuantities;
handles.Buffer.ProfQuant2=EvaluatedProfileQuantities2;
NewSignals=[];
SignalEvaluated=1;
for II=1:handles.NumberOfAvailableSignals
       if(SignalON(II))
           for III=1:numel(CodiceSig(II).Code)
                eval(CodiceSig(II).Code{III})
           end 
           NewSignals(SignalEvaluated,:)=CodeOutput;
           SignalEvaluated=SignalEvaluated+1;
       end
end
handles.Buffer.SignalEvaluated=NewSignals;
for II=1:handles.NumberOfAvailableSignals
   if(FilterON(II))
      for III=1:numel(CodiceFiltro(II).Code)
           eval(CodiceFiltro(II).Code{III})
      end
      Rimasti{II}=CodeOutput;
   end
end
if(any(FilterON))
    handles.Buffer.FilterEvaluated=Rimasti;
end
set(handles.dia_text_rec,'Userdata',handles.Buffer);
UD=get(handles.CVCRCIISSA,'UserData');
UD{1}=Init_Vars.BaseLineX;UD{2}=Init_Vars.BaseLineY;UD{3}=Init_Vars.FiltersList;
set(handles.CVCRCIISSA,'UserData',UD);
delete_or_update_figures(handles)

% --- Executes on button press in c_Filter2.
function c_Filter2_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in c_Filter3.
function c_Filter3_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in Sig1.
function Sig1_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end



function e_sig11_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function e_sig11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_sig11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_sig12_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function e_sig12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_sig12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sig2.
function Sig2_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in Sig3.
function Sig3_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in LoadConf.
function LoadConf_Callback(hObject, eventdata, handles)
Configuration.PvSyncList=get(handles.PvSyncList,'String');
Configuration.PvNotSyncList=get(handles.PvNotSyncList,'String');
Configuration.Variables{1,1}=get(handles.e_sig11,'String');
Configuration.Variables{1,2}=get(handles.e_sig12,'String');
Configuration.Variables{2,1}=get(handles.e_sig21,'String');
Configuration.Variables{2,2}=get(handles.e_sig22,'String');
Configuration.Variables{3,1}=get(handles.e_sig31,'String');
Configuration.Variables{3,2}=get(handles.e_sig32,'String');
Configuration.ProfileMonitorMenu_S=get(handles.ProfileMonitorMenu,'String');
Configuration.ProfileMonitorMenu_V=get(handles.ProfileMonitorMenu,'Value');
Configuration.ProfileMonitorName=get(handles.ProfileMonitorName,'String');
Configuration.e_roiy{1}=get(handles.e_roiy1,'String');
Configuration.e_roiy{2}=get(handles.e_roiy2,'String');
Configuration.e_roix{1}=get(handles.e_roix1,'String');
Configuration.e_roix{2}=get(handles.e_roix2,'String');
Configuration.ProjectionXY_S=get(handles.ProjectionXY,'String');
Configuration.ProjectionXY_V=get(handles.ProjectionXY,'Value');
Configuration.e_background=get(handles.e_background,'String');
Configuration.dbcycle=get(handles.dbcycle,'String');
Configuration.e_keeplast=get(handles.e_keeplast,'String');
Configuration.e_block=get(handles.e_block,'String');
Configuration.e_keeplast=get(handles.e_keeplast,'String');
Configuration.e_pause=get(handles.e_pause,'String');
Configuration.PulseID_delay=get(handles.PulseID_delay,'String');
Configuration.ShowOneAcquiredProfile=get(handles.ShowOneAcquiredProfile,'String');
Configuration.PvToListen=get(handles.PvToListen,'String');
for II=1:handles.OutVariablesNumber
    eval(['Configuration.filt_string{II}=get(',['handles.f',char(48+II)],',''String'');']);
    eval(['Configuration.filt_value{II}=get(',['handles.f',char(48+II)],',''Value'');']);
    eval(['Configuration.Out_value{II}=get(',['handles.q',char(48+II)],',''Value'');']);
end
Configuration.c_BSA=get(handles.c_BSA,'Value');
for II=1:handles.NumberOfAvailableSignals
    eval(['Configuration.SignalON(',num2str(II),')=get(handles.Sig',num2str(II),',''Value'');']);
end
for II=1:handles.NumberOfAvailableFilters
    eval(['Configuration.FilterON(',num2str(II),')=get(handles.c_Filter',num2str(II),',''Value'');']);
end
for II=1:handles.ProfileProcessNumber
   Configuration.BasicProcessing(II)=eval(['get(','handles.c_opt',char(48+II),',''value'');']);
end
Configuration.CameraSize=get(handles.ProfileMonitorName,'UserData'); 
Configuration.Signale=handles.Signal;
Configuration.Out=handles.Out;
Configuration.Filter=handles.Filter;
Configuration.OutPVNames=handles.PV;
Configuration.FilterNames=handles.FilterNames;
Configuration.SignalNames=handles.SignalNames;
Configuration.BackgroundBlock=handles.BackgroundBlock;
[fname,fpath]=uiputfile(handles.ConfigurationsPath,'*.mat');
save([fpath,fname],'Configuration');

% --- Executes on button press in SaveConf.
function SaveConf_Callback(hObject, eventdata, handles)
[fname,fpath]=uigetfile(handles.ConfigurationsPath,'*.mat');
load([fpath,fname],'Configuration');
set(handles.PvSyncList,'String',Configuration.PvSyncList);
Configuration.PvNotSyncList=get(handles.PvNotSyncList,'String');
VNum=size(Configuration.Variables);
for II=VNum(1) %(3)
    for JJ=1:VNum(2) %2
        eval(['set(handles.e_sig',char(48+II),char(48+JJ),',''String'',Configuration.Variables{II,JJ})']);
    end
end
set(handles.ProfileMonitorMenu,'String',Configuration.ProfileMonitorMenu_S);
set(handles.ProfileMonitorMenu,'Value',Configuration.ProfileMonitorMenu_V);
set(handles.ProfileMonitorName,'String',Configuration.ProfileMonitorName);
set(handles.e_roiy1,'String',Configuration.e_roiy{1});
set(handles.e_roiy2,'String',Configuration.e_roiy{2});
set(handles.e_roix1,'String',Configuration.e_roix{1});
set(handles.e_roix2,'String',Configuration.e_roix{2});
set(handles.ProjectionXY,'String',Configuration.ProjectionXY_S);
set(handles.ProjectionXY,'Value',Configuration.ProjectionXY_V);
set(handles.e_background,'String',Configuration.e_background);
set(handles.dbcycle,'String',Configuration.dbcycle);
set(handles.e_keeplast,'String',Configuration.e_keeplast);
set(handles.e_block,'String',Configuration.e_block);
set(handles.e_keeplast,'String',Configuration.e_keeplast);
set(handles.e_pause,'String',Configuration.e_pause);
set(handles.PulseID_delay,'String',Configuration.PulseID_delay);
set(handles.ShowOneAcquiredProfile,'String',Configuration.ShowOneAcquiredProfile);
set(handles.PvToListen,'String',Configuration.PvToListen);
for II=1:numel(Configuration.filt_string)
%     save TEMP
%     eval(['set(handles.f',char(48+II),',''String'',''',char(Configuration.filt_string{II}),''');']);
%     eval(['set(handles.f',char(48+II),',''Value'',Configuration.filt_value{II})']);
%     eval(['set(handles.q',char(48+II),',''Value'',Configuration.Out_value{II})']);
end
set(handles.c_BSA,'Value',Configuration.c_BSA);
for II=1:numel(Configuration.SignalON)
    eval(['set(handles.Sig',num2str(II),',''Value'',Configuration.SignalON(II));']);
end
for II=1:numel(Configuration.FilterON)
    eval(['set(handles.c_Filter',num2str(II),',''Value'',Configuration.FilterON(II));']);
end
for II=1:numel(Configuration.BasicProcessing)
   eval(['set(','handles.c_opt',char(48+II),',''value'',Configuration.BasicProcessing(II));']);
end
set(handles.ProfileMonitorName,'UserData',Configuration.CameraSize); 
handles.Signal=Configuration.Signale;
handles.Out=Configuration.Out;
handles.Filter=Configuration.Filter;
handles.PV=Configuration.OutPVNames;
handles.FilterNames=Configuration.FilterNames;
handles.SignalNames=Configuration.SignalNames;
if(isempty(Configuration.BackgroundBlock))
    set(handles.NaClOBackground,'enable','off');
else
    set(handles.NaClOBackground,'enable','on');
end
handles.BackgroundBlock=Configuration.BackgroundBlock;
guidata(hObject, handles);


% --- Executes on button press in CodeVariablesSignalsFilters.
function CodeVariablesSignalsFilters_Callback(hObject, eventdata, handles)
Pvlist=get(handles.PvSyncList,'String');
PvNotSync=get(handles.PvNotSyncList,'String');
for II=1:handles.NumberOfOnTheFlyVariables
    ScalarsList{II}=['%',num2str(II),' =Variable ',num2str(II)];
end
%ScalarsList={'%1 =Variable 1','%2 =Variable 2','%3 =Variable 3','%4 =Variable 4','%5 =Variable 5','%6 =Variable 6'};
ShotToShotList={'FirstProfile sum','FirstProfile peak','FirstProfile peak position','FirstProfile first moment','FirstProfile FWHM','SecondProfile sum','SecondProfile peak','SecondProfile peak position','SecondProfile first moment','SecondProfile FWHM','TimeStamp','PulseID','Signal 1','Signal 2','Signal 3'};
ProfilesList={'FirstProfile','SecondProfile'};
for JJ=1:numel(ShotToShotList)
    ShotToShotList{JJ}=['#',num2str(JJ),' =',ShotToShotList{JJ}];
end
for II=1:numel(Pvlist)
    ShotToShotList{end+1}=['#',num2str(JJ+II),' =',Pvlist{II}];
end
for II=1:numel(PvNotSync)
    ScalarsList{end+1}=['%',num2str(handles.NumberOfOnTheFlyVariables+II),' =',PvNotSync{II}];
end
set(handles.Code_List1,'String',ScalarsList);
set(handles.Code_List2,'String',ShotToShotList);
set(handles.Code_List3,'String',ProfilesList);
set(handles.CodificaCosa,'Value',1);
CodificaCosa_Callback(hObject, eventdata, handles);
set(handles.QualePrendi,'Value',1);
tempstring=get(handles.CodificaCosa,'String');
set(handles.SalvaCosa,'String',tempstring);
tempstring=get(handles.QualePrendi,'String');
set(handles.QualeSalvi,'String',tempstring);
set(handles.uipanel1,'visible','off');
set(handles.CodeVariablesPanel,'visible','on');
set(handles.QuickCodePanel,'visible','off')


% --- Executes on button press in Try3.
function Try3_Callback(hObject, eventdata, handles)
% hObject    handle to Try3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddVisPan.
function AddVisPan_Callback(hObject, eventdata, handles)
UD=get(handles.CVCRCIISSA,'UserData');
FiguresList=UD{4};ChildrenSorting=UD{5};
if(isempty(FiguresList)) %add the first
    FiguresList(1)=CVS_CVCRCI_visualization_gui;
    ChildrenSorting(1,:)=children_sorting(FiguresList(1));
else %add a new one
    FiguresList(end+1)=CVS_CVCRCI_visualization_gui;
    ChildrenSorting(end+1,:)=children_sorting(FiguresList(end));
end
UD{4}=FiguresList;
UD{5}=ChildrenSorting;
set(handles.CVCRCIISSA,'UserData',UD);
guidata(hObject, handles);
Initialize_Figure(FiguresList(end),ChildrenSorting(end,:),handles,0);
update_figure_list(handles)
    
function Initialize_Figure(PointerToFigure,PointerToFigureObjArray,handles,EXISTING)
RESET=0;
UD=get(handles.CVCRCIISSA,'UserData');
handles.BaseLineX=UD{1};
handles.BaseLineY=UD{2};
handles.FiltersList=UD{3};

if(EXISTING)
    set(PointerToFigureObjArray(2),'Userdata',1);
    X=get(PointerToFigureObjArray(2),'string');
    Y=get(PointerToFigureObjArray(3),'string');
    if((numel(X)~=numel(handles.BaseLineX)) || (numel(Y)~=numel(handles.BaseLineY)) )
        RESET=1;
    end
    if(~RESET)
        for IND=1:numel(X)
            if(~strcmp(X{IND},handles.BaseLineX{IND}))
                RESET=1; break
            end
        end
        if(~RESET)
            for IND=1:numel(Y)
                if(~strcmp(Y{IND},handles.BaseLineY{IND}))
                    RESET=1; break
                end
            end
        end
    end
else
    RESET=1;
end
if(RESET)
    set(PointerToFigureObjArray(2),'value',1);
    set(PointerToFigureObjArray(2),'string',handles.BaseLineX);
    set(PointerToFigureObjArray(2),'Userdata',1);
    set(PointerToFigureObjArray(3),'value',1);
    set(PointerToFigureObjArray(3),'string',handles.BaseLineY);
    set(PointerToFigureObjArray(4),'value',1);
    set(PointerToFigureObjArray(4),'string',handles.BaseLineY);
    set(PointerToFigureObjArray(5),'value',1);
    set(PointerToFigureObjArray(5),'string',handles.BaseLineY);
    set(PointerToFigureObjArray(6),'string','');
    set(PointerToFigureObjArray(7),'string','');
    set(PointerToFigureObjArray(8),'string','');
    set(PointerToFigureObjArray(9),'string','');
    set(PointerToFigureObjArray(10),'string','50');
    set(PointerToFigureObjArray(11),'string','50');
    set(PointerToFigureObjArray(12),'value',1);
    set(PointerToFigureObjArray(12),'string',handles.FiltersList);
    set(PointerToFigureObjArray(13),'value',1);
    set(PointerToFigureObjArray(13),'string',handles.FiltersList);
    set(PointerToFigureObjArray(14),'value',1);
    set(PointerToFigureObjArray(14),'string',handles.FiltersList);
    set(PointerToFigureObjArray(15),'backgroundcolor',handles.ColorON);
    set(PointerToFigureObjArray(16),'backgroundcolor',handles.ColorON);
    set(PointerToFigureObjArray(17),'value',1);
    set(PointerToFigureObjArray(18),'value',0);
    set(PointerToFigureObjArray(19),'string','');
    set(PointerToFigureObjArray(20),'value',0);
    set(PointerToFigureObjArray(21),'string','');
    set(PointerToFigureObjArray(22),'value',1);
    set(PointerToFigureObjArray(24),'visible','off');
    set(PointerToFigureObjArray(25),'visible','off');
    set(PointerToFigureObjArray(26),'visible','off');
    set(PointerToFigureObjArray(27),'visible','off');
    set(PointerToFigureObjArray(28),'visible','off');
    set(PointerToFigureObjArray(29),'visible','off');
    set(PointerToFigureObjArray(30),'visible','off');
    set(PointerToFigureObjArray(31),'visible','off');
    figureinputstructure=figureinputstructure_builder(PointerToFigureObjArray,handles);
    set(PointerToFigureObjArray(23),'userdata',figureinputstructure);
    set(PointerToFigureObjArray(22),'string',handles.CustomAnalysisList);
end

function outS=figureinputstructure_builder(PointerToFigureObjArray,handles)
    outS.X_SEL=get(PointerToFigureObjArray(2),'value');
    outS.Y_SEL1=get(PointerToFigureObjArray(3),'value');
    outS.Y_SEL2=get(PointerToFigureObjArray(4),'value');
    outS.Y_SEL3=get(PointerToFigureObjArray(5),'value');
    outS.lim_x1=str2double(get(PointerToFigureObjArray(6),'string'));
    outS.lim_x2=str2double(get(PointerToFigureObjArray(7),'string'));
    outS.lim_y1=str2double(get(PointerToFigureObjArray(8),'string'));
    outS.lim_y2=str2double(get(PointerToFigureObjArray(9),'string'));
    outS.binsx=str2double(get(PointerToFigureObjArray(10),'string'));
    outS.binsy=str2double(get(PointerToFigureObjArray(11),'string'));
    if(isnan(outS.binsy) || isinf(outS.binsy) || (outS.binsy>500) || (outS.binsy<3))
        outS.binsy=10; set(PointerToFigureObjArray(11),'string','10'); 
    else
        outS.binsy=round(outS.binsy);
    end
    if(isnan(outS.binsy) || isinf(outS.binsy) || (outS.binsx>500) || (outS.binsx<3))
        outS.binsx=10; set(PointerToFigureObjArray(10),'string','10'); 
    else
        outS.binsx=round(outS.binsx);
    end
    if(isinf(outS.lim_x1)), outS.lim_x1=NaN; , end
    if(isinf(outS.lim_x2)), outS.lim_x2=NaN; , end
    if(isinf(outS.lim_y1)), outS.lim_y1=NaN; , end
    if(isinf(outS.lim_y2)), outS.lim_y2=NaN; , end

    if(~isnan(outS.lim_x1) && ~isnan(outS.lim_x2))
        if(outS.lim_x1==outS.lim_x2)
            outS.lim_x1=outS.lim_x1-10^-16; outS.lim_x2=outS.lim_x2+10^-16;
        elseif(outS.lim_x1>outS.lim_x2)
            TEMP=outS.lim_x2;
            outS.lim_x2=outS.lim_x1;
            outS.lim_x1=TEMP;
        end 
    end

    if(~isnan(outS.lim_y1) && ~isnan(outS.lim_y2))
        if(outS.lim_y1==outS.lim_y2)
            outS.lim_y1=outS.lim_y1-10^-16; outS.lim_y2=outS.lim_y2+10^-16;
        elseif(outS.lim_y1>outS.lim_y2)
            TEMP=outS.lim_y2;
            outS.lim_y2=outS.lim_y1;
            outS.lim_y1=TEMP;
        end 
    end

    outS.Filt1=get(PointerToFigureObjArray(12),'value')-1;
    outS.Filt2=get(PointerToFigureObjArray(13),'value')-1;
    outS.Filt3=get(PointerToFigureObjArray(14),'value')-1;
    outS.b_autoX=(sum(get(PointerToFigureObjArray(15),'backgroundcolor')==handles.ColorON)==3);
    outS.b_autoY=(sum(get(PointerToFigureObjArray(16),'backgroundcolor')==handles.ColorON)==3);
    outS.ShowOne=get(PointerToFigureObjArray(17),'value');
    outS.ShowAverage=get(PointerToFigureObjArray(18),'value');
    outS.OnScreen=get(PointerToFigureObjArray(19),'value');
    outS.TrasformaFourier=get(PointerToFigureObjArray(20),'value');
    outS.Calibration=str2num(get(PointerToFigureObjArray(21),'string'));
    if(any(isnan(outS.Calibration)))
       outS.Calibration=NaN;
    elseif(length(outS.Calibration)>2)
        outS.Calibration=NaN;
    elseif(isempty(outS.Calibration))
        outS.Calibration=NaN;
    elseif(outS.Calibration==0)
        outS.Calibration=NaN;
    end
    outS.SpecializedDisplay=get(PointerToFigureObjArray(22),'value')-1;
    outS.MostraMedie=0;
    outS.gammafit=0;
    outS.LogBookAndSave=0;
    outS.LogBookOnlyFigure=0;


% --- Executes on button press in t_LogbookLite.
function t_LogbookLite_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.LogBookOnlyFigure=1;

function OUT=children_sorting(visualization_gui)
DiscendentePrimo=get(visualization_gui,'children');
ListaDiscendenti=get(DiscendentePrimo,'children');
length(ListaDiscendenti)
for II=1:length(ListaDiscendenti)
   ThisTag=get(ListaDiscendenti(II),'tag');
   if(ThisTag(1)~='t')
       if(strcmp(ThisTag,'axes1'))
           OUT(1)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'X_SEL'))
           OUT(2)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'Y_SEL1'))
           OUT(3)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'Y_SEL2'))
           OUT(4)=ListaDiscendenti(II);   
       elseif(strcmp(ThisTag,'Y_SEL3'))
           OUT(5)=ListaDiscendenti(II);     
       elseif(strcmp(ThisTag,'e_x1'))
           OUT(6)=ListaDiscendenti(II);   
       elseif(strcmp(ThisTag,'e_x2'))
           OUT(7)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'e_y1'))
           OUT(8)=ListaDiscendenti(II);   
       elseif(strcmp(ThisTag,'e_y2'))
           OUT(9)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'e_binsx'))
           OUT(10)=ListaDiscendenti(II);   
       elseif(strcmp(ThisTag,'e_binsy'))
           OUT(11)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'popf1'))
           OUT(12)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'popf2'))
           OUT(13)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'popf3'))
           OUT(14)=ListaDiscendenti(II); 
       elseif(strcmp(ThisTag,'b_autoX'))
           OUT(15)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'b_autoY'))
           OUT(16)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'c_ShowOne'))
           OUT(17)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'c_ShowAverage'))
           OUT(18)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'OnScreen'))
           OUT(19)=ListaDiscendenti(II);  
       elseif(strcmp(ThisTag,'c_Fourier'))
           OUT(20)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'Calibration'))
           OUT(21)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'MoreProcessing'))
           OUT(22)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'IdatiStanQua'))
           OUT(23)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XE1'))
           OUT(24)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XE2'))
           OUT(25)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XE3'))
           OUT(26)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XE4'))
           OUT(27)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XT1'))
           OUT(28)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XT2'))
           OUT(29)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XT3'))
           OUT(30)=ListaDiscendenti(II);
       elseif(strcmp(ThisTag,'XT4'))
           OUT(31)=ListaDiscendenti(II);
       else
        
           
           disp([ThisTag, ' ?this sounds strange ...'])
       end
   end
end

% --- Executes on button press in CloseVisPan.
function CloseVisPan_Callback(hObject, eventdata, handles)
UD=get(handles.CVCRCIISSA,'UserData');
FiguresList=UD{4};
ChildrenSorting=UD{5};
if(isempty(FiguresList)) %no figure to close
    return
else
    CurrVal=get(handles.Vis_List,'value');
    try
        close(FiguresList(CurrVal));
        catch ME
    end
    if ((CurrVal==1) && (length(FiguresList)==1) )
        FiguresList=[];
        ChildrenSorting=[];
    elseif((CurrVal==length(FiguresList)))
        FiguresList=FiguresList(1:(end-1));
        ChildrenSorting=ChildrenSorting(1:(end-1),:);
    elseif(CurrVal==1)
        FiguresList=FiguresList(2:end);
        ChildrenSorting=ChildrenSorting(2:end,:);
    else
        FiguresList=[FiguresList(1:(CurrVal-1)),FiguresList((CurrVal+1):end)];
        ChildrenSorting=[ChildrenSorting(1:(CurrVal-1),:);ChildrenSorting((CurrVal+1),:)];
    end
    UD{4}=FiguresList;
    UD{5}=ChildrenSorting;
    set(handles.CVCRCIISSA,'UserData',UD);
    update_figure_list(handles);
end


% --- Executes on button press in CloseAllPan.
function CloseAllPan_Callback(hObject, eventdata, handles)
UD=get(handles.CVCRCIISSA,'UserData');
FiguresList=UD{4};
if(isempty(FiguresList)) % no figures to close
    return
else %add a new one
    for II=1:length(FiguresList)
        try
            close(FiguresList(II));
        catch ME
        end
    end
    FiguresList=[];
    ChildrenSorting=[];
    UD{4}=FiguresList;
    UD{5}=ChildrenSorting;
    set(handles.CVCRCIISSA,'UserData',UD);
    update_figure_list(handles)
end


% --- Executes on selection change in Vis_List.
function Vis_List_Callback(hObject, eventdata, handles)
% hObject    handle to Vis_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Vis_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Vis_List


% --- Executes during object creation, after setting all properties.
function Vis_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vis_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in q1.
function q1_Callback(hObject, eventdata, handles)
% hObject    handle to q1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q1


% --- Executes on button press in q2.
function q2_Callback(hObject, eventdata, handles)
% hObject    handle to q2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q2


% --- Executes on button press in q3.
function q3_Callback(hObject, eventdata, handles)
% hObject    handle to q3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q3


% --- Executes on button press in q4.
function q4_Callback(hObject, eventdata, handles)
% hObject    handle to q4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q4


% --- Executes on button press in q5.
function q5_Callback(hObject, eventdata, handles)
% hObject    handle to q5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q5


% --- Executes on button press in q6.
function q6_Callback(hObject, eventdata, handles)
% hObject    handle to q6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q6


% --- Executes on button press in q7.
function q7_Callback(hObject, eventdata, handles)
% hObject    handle to q7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q7


% --- Executes on selection change in f1.
function f1_Callback(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f1


% --- Executes during object creation, after setting all properties.
function f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f2.
function f2_Callback(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f2


% --- Executes during object creation, after setting all properties.
function f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f3.
function f3_Callback(hObject, eventdata, handles)
% hObject    handle to f3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f3


% --- Executes during object creation, after setting all properties.
function f3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f4.
function f4_Callback(hObject, eventdata, handles)
% hObject    handle to f4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f4


% --- Executes during object creation, after setting all properties.
function f4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f5.
function f5_Callback(hObject, eventdata, handles)
% hObject    handle to f5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f5


% --- Executes during object creation, after setting all properties.
function f5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f6.
function f6_Callback(hObject, eventdata, handles)
% hObject    handle to f6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f6


% --- Executes during object creation, after setting all properties.
function f6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in f7.
function f7_Callback(hObject, eventdata, handles)
% hObject    handle to f7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns f7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from f7


% --- Executes during object creation, after setting all properties.
function f7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in c_opt1.
function c_opt1_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in c_opt2.
function c_opt2_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in c_opt3.
function c_opt3_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes on button press in c_opt4.
function c_opt4_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end

% --- Executes on button press in DEBUG.
function DEBUG_Callback(hObject, eventdata, handles)
clc
Val=mod(round(rand(1)*10^7),10);
set(handles.Start3,'enable','on')
set(handles.Update_Figures_Cont,'enable','on')
set(handles.AppenOneBlockMore,'enable','on')
set(handles.CominciaModalitaSchiavo,'enable','on')
set(handles.NaClO,'enable','on')
UD=get(handles.CVCRCIISSA,'UserData');
size(handles.BackgroundBlock)


% --- Executes on button press in c_update.
function c_update_Callback(hObject, eventdata, handles)
% hObject    handle to c_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c_update


% --- Executes on selection change in Code_List1.
function Code_List1_Callback(hObject, eventdata, handles)
% hObject    handle to Code_List1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Code_List1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Code_List1


% --- Executes during object creation, after setting all properties.
function Code_List1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_List1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Code_List2.
function Code_List2_Callback(hObject, eventdata, handles)
% hObject    handle to Code_List2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Code_List2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Code_List2


% --- Executes during object creation, after setting all properties.
function Code_List2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_List2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Code_List3.
function Code_List3_Callback(hObject, eventdata, handles)
% hObject    handle to Code_List3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Code_List3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Code_List3


% --- Executes during object creation, after setting all properties.
function Code_List3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_List3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CodificaCosa.
function CodificaCosa_Callback(hObject, eventdata, handles)
Current=get(handles.CodificaCosa,'value');
set(handles.QuickCodePanel,'visible','off')
if(Current==1)
    cherobamenu={'From - To','Around average/value ; +/- N*rms','Around average/value ; +/- average*N','Last N shots'};
    set(handles.QualePrendi,'value',1);
    set(handles.QualePrendi,'String',{'Filter 1','Filter 2','Filter 3'});
    set(handles.CodeSimple,'visible','on');
    set(handles.Cosaxe,'String','code condition')
    set(handles.cheroba,'String',cherobamenu);
    set(handles.C_FC,'visible','on')
    set(handles.C_FC,'value',1)
elseif(Current==2)
    set(handles.QualePrendi,'value',1);
    set(handles.QualePrendi,'String',{'Signal 1','Signal 2','Signal 3'});
    set(handles.CodeSimple,'visible','off');
    set(handles.Cosaxe,'String','code shot to shot scalar')
    set(handles.C_FC,'visible','off')
elseif(Current==3)
    cherobamenu={'average','standard deviation','fluctuations'};
    set(handles.QualePrendi,'value',1);
    set(handles.QualePrendi,'String',{'Out 1','Out 2','Out 3','Out 4','Out 5','Out 6','Out 7'});
    set(handles.CodeSimple,'visible','on');
    set(handles.Cosaxe,'String','code output scalar')
    set(handles.cheroba,'String',cherobamenu);
    set(handles.C_FC,'visible','off')
end
QualePrendi_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CodificaCosa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CodificaCosa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in QualePrendi.
function QualePrendi_Callback(hObject, eventdata, handles)
type=get(handles.CodificaCosa,'value');
current=get(handles.QualePrendi,'Value');
if(type==1)
    set(handles.CurrentCode,'String',handles.Filter(current).Code);
    nomeattuale=handles.FilterNames{current};
elseif(type==2)
    set(handles.CurrentCode,'String',handles.Signal(current).Code);
    nomeattuale=handles.SignalNames{current};
else
    set(handles.CurrentCode,'String',handles.Out(current).Code);
    nomeattuale=handles.PV(current).what(1:(end-3));
end
tempstring=get(handles.CodificaCosa,'String');
set(handles.SalvaCosa,'string',tempstring);
tempstring=get(handles.QualePrendi,'String');
set(handles.QualeSalvi,'string',tempstring);
tempvalue=get(handles.CodificaCosa,'value');
set(handles.SalvaCosa,'value',tempvalue);
tempvalue=get(handles.QualePrendi,'value');
set(handles.QualeSalvi,'value',tempvalue);
set(handles.NomeDellaVariabile,'String',nomeattuale)

% --- Executes during object creation, after setting all properties.
function QualePrendi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QualePrendi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Code_List4.
function Code_List4_Callback(hObject, eventdata, handles)
% hObject    handle to Code_List4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Code_List4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Code_List4


% --- Executes during object creation, after setting all properties.
function Code_List4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_List4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CurrentCode.
function CurrentCode_Callback(hObject, eventdata, handles)
CL=get(handles.CurrentCode,'value');
CS=get(handles.CurrentCode,'string');
set(handles.edit12,'String',CS{CL});


% --- Executes during object creation, after setting all properties.
function CurrentCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CodeManual.
function CodeManual_Callback(hObject, eventdata, handles)
% hObject    handle to CodeManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CodeSimple.
function CodeSimple_Callback(hObject, eventdata, handles)
set(handles.QuickCodePanel,'visible','on')
cheroba_Callback(hObject, eventdata, handles)

function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CodeAddLine.
function CodeAddLine_Callback(hObject, eventdata, handles)
CS=get(handles.edit12,'String');
CL=get(handles.CurrentCode,'String');
LINES=numel(CL);
if(LINES==1)
    if(isempty(CL{1}))
        if(iscell(CS))
            FirstNewLine{1}=CS{1};
        else
            FirstNewLine{1}=CS;
        end
        set(handles.CurrentCode,'String',FirstNewLine);
        return
    end
end
if(iscell(CS))
      CL{LINES+1}=CS{1};
    else
      CL{LINES+1}=CS;
end
set(handles.CurrentCode,'String',CL);

% --- Executes on button press in CodeDeleteLine.
function CodeDeleteLine_Callback(hObject, eventdata, handles)
CL=get(handles.CurrentCode,'String');
CV=get(handles.CurrentCode,'value');
LINES=numel(CL);
if(LINES==1)
    NL{1}='';
    set(handles.CurrentCode,'value',1)
    set(handles.CurrentCode,'String',NL);
    return
end
if(LINES>1)
   if(CV==1) %cancella il primo 
       for II=2:LINES
           NL{II-1}=CL{II};
       end
       set(handles.CurrentCode,'String',NL);
       return
   end
   if(CV==LINES) %cancella il primo 
       for II=1:(LINES-1)
           NL{II}=CL{II};
       end
       set(handles.CurrentCode,'String',NL);
       set(handles.CurrentCode,'value',LINES-1);
       return
   end 
   for II=1:(CV-1)
           NL{II}=CL{II};
   end 
   for II=(CV+1):LINES
       NL{end+1}=CL{II};
   end
   set(handles.CurrentCode,'String',NL);
end



% --- Executes on button press in CodeMoveUp.
function CodeMoveUp_Callback(hObject, eventdata, handles)
CL=get(handles.CurrentCode,'String');
CV=get(handles.CurrentCode,'value');
LINES=numel(CL);
if(CV==1)
    return
end
NL=CL;
TEMP=NL{CV-1};
NL{CV-1}=NL{CV};
NL{CV}=TEMP;
set(handles.CurrentCode,'value',CV-1);
set(handles.CurrentCode,'String',NL);

% --- Executes on button press in CodeMoveDown.
function CodeMoveDown_Callback(hObject, eventdata, handles)
CL=get(handles.CurrentCode,'String');
CV=get(handles.CurrentCode,'value');
LINES=numel(CL);
if(CV==LINES)
    return
end
NL=CL;
TEMP=NL{CV+1};
NL{CV+1}=NL{CV};
NL{CV}=TEMP;
set(handles.CurrentCode,'value',CV+1);
set(handles.CurrentCode,'String',NL);


% --- Executes on button press in CodeTEST.
function CodeTEST_Callback(hObject, eventdata, handles)
%save TEMP
CurrentCode=get(handles.CurrentCode,'String')
CL1=get(handles.Code_List1,'String');
CL2=get(handles.Code_List2,'String');
CL3=get(handles.Code_List3,'String');
SA=300;
SB=299;
SC=numel(CL2)+1;
FakeScalars=rand(size(1,numel(CL1)));
FakeShotToShot=rand(SC,numel(CL2));
FirstProfile=abs(rand(SA,SC));
SecondProfile=abs(rand(SB,SC));
FakeScalars(1)=1;
FakeScalars(2)=2;

%replace variables
for II=1:numel(CurrentCode)
   for JJ=1:numel(CL1)
       CurrentCode{II}=regexprep(CurrentCode{II},['%',num2str(JJ)],['FakeScalars(',num2str(JJ),')']);
   end
   for JJ=1:numel(CL2)
       CurrentCode{II}=regexprep(CurrentCode{II},['#',num2str(JJ)],['FakeShotToShot(:,',num2str(JJ),')']);
   end
   CurrentCode{II}=regexprep(CurrentCode{II},'!','TemporaryVariable');
end
CurrentCode
for II=1:numel(CurrentCode)
   eval(CurrentCode{II}); 
end

size(CodeOutput)




% --- Executes on selection change in PvNotSyncList.
function PvNotSyncList_Callback(hObject, eventdata, handles)
% hObject    handle to PvNotSyncList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PvNotSyncList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PvNotSyncList


% --- Executes during object creation, after setting all properties.
function PvNotSyncList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PvNotSyncList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CodeExitPlease.
function CodeExitPlease_Callback(hObject, eventdata, handles)
for II=1:handles.OutVariablesNumber
   eval(['set(handles.w',char(48+II),',''string'',[handles.PV(II).what,handles.PV(II).name])']) 
end
set(handles.uipanel1,'visible','on');
set(handles.CodeVariablesPanel,'visible','off');


function e_sig21_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function e_sig21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_sig21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_sig22_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function e_sig22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_sig22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_sig31_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function e_sig31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_sig31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_sig32_Callback(hObject, eventdata, handles)
if(~isempty(handles.Buffer.PV) || ~isempty(handles.Buffer.Prof))
   handles=ReEvaluateBuffer(handles);
   guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function e_sig32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_sig32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ReleaseeDefs.
function ReleaseeDefs_Callback(hObject, eventdata, handles)
OldeDefs=get(handles.ReleaseeDefs,'Userdata');
        if ~isempty(OldeDefs)
           for II=1:length(OldeDefs)
               try
                    eDefRelease(OldeDefs(II));
               catch ME
                   %maybe somebody cleaned the thing before you did!
               end
           end
        end
set(handles.ReleaseeDefs,'Userdata',[]);
set(handles.ReleaseeDefs,'backgroundcolor',handles.ColorIdle);
set(handles.ReleaseeDefs,'enable','off');
        


% --- Executes on button press in TakeOneProfile.
function TakeOneProfile_Callback(hObject, eventdata, handles)
profile=get(handles.ProfileMonitorName,'String'); ReadProfile=1;
try
    if(ReadProfile)
        [prof,ts_old]=lcaGetSmart(profile);
        ONLINE=1;
    else
        [prof,ts_old]=lcaGetSmart(Pvlist{1});
        ONLINE=1;
    end
catch ME
    if(ReadProfile)
        [prof,ts_old]=lcaGetDonk(profile,1);
        ONLINE=0;
    else
        [prof,ts_old]=lcaGetDonk(Pvlist{1},1);
        ONLINE=0;
    end
end

CameraSize=get(handles.ProfileMonitorName,'UserData')
A=figure(1000);
if(CameraSize.Rows==1 || CameraSize.Columns==1)
    plot(prof)
else
    imagesc(reshape(prof,CameraSize.Rows,CameraSize.Columns));
end


% --- Executes on selection change in SalvaCosa.
function SalvaCosa_Callback(hObject, eventdata, handles)
Current=get(handles.SalvaCosa,'value');
if(Current==1)
    set(handles.QualeSalvi,'value',1);
    set(handles.QualeSalvi,'String',{'Filter 1','Filter 2','Filter 3'});
elseif(Current==2)
    set(handles.QualeSalvi,'value',1);
    set(handles.QualeSalvi,'String',{'Signal 1','Signal 2','Signal 3'});
else
    set(handles.QualeSalvi,'value',1);
    set(handles.QualeSalvi,'String',{'Out 1','Out 2','Out 3','Out 4','Out 5','Out 6','Out 7'});
end


% --- Executes during object creation, after setting all properties.
function SalvaCosa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SalvaCosa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in QualeSalvi.
function QualeSalvi_Callback(hObject, eventdata, handles)
% hObject    handle to QualeSalvi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns QualeSalvi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from QualeSalvi


% --- Executes during object creation, after setting all properties.
function QualeSalvi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QualeSalvi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveCode.
function SaveCode_Callback(hObject, eventdata, handles)
Current=get(handles.SalvaCosa,'value');
Quale=get(handles.QualeSalvi,'value');
CODE=get(handles.CurrentCode,'String');
nomeattuale=get(handles.NomeDellaVariabile,'String');
if(Current==1)
    handles.Filter(Quale).Code=CODE;
    handles.FilterNames{Quale}=nomeattuale;
elseif(Current==2)
    handles.Signal(Quale).Code=CODE;
    handles.SignalNames{Quale}=nomeattuale;
else
    handles.Out(Quale).Code=CODE;
    handles.PV(Quale).what=[nomeattuale,' - '];
end
guidata(hObject, handles);

% --- Executes on selection change in cheroba.
function cheroba_Callback(hObject, eventdata, handles)
switch(get(handles.CodificaCosa,'value'))
    case 1 %filter
        VAL=get(handles.cheroba,'value');
        switch(VAL)
            case 1
                for II=1:2
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''on'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''on'');']) 
                end
                set(handles.Code_Parametro1_text,'string','From');
                set(handles.Code_Parametro2_text,'string','To');
                set(handles.Code_Parametro1_edit,'string','0');
                set(handles.Code_Parametro2_edit,'string','1');
                for II=3:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
            case 2
                for II=1:2
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''on'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''on'');']) 
                end
                set(handles.Code_Parametro1_text,'string','Center');
                set(handles.Code_Parametro2_text,'string','Width (rms)');
                set(handles.Code_Parametro1_edit,'string','Average');
                set(handles.Code_Parametro2_edit,'string','3');
                for II=3:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
            case 3
                for II=1:2
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''on'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''on'');']) 
                end
                set(handles.Code_Parametro1_text,'string','Center');
                set(handles.Code_Parametro2_text,'string','Width (1=avg)');
                set(handles.Code_Parametro1_edit,'string','Average');
                set(handles.Code_Parametro2_edit,'string','1/50');
                for II=3:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
            case 4
                eval(['set(handles.Code_Parametro',char(48+1),'_text,''visible'',''on'');']) 
                set(handles.Code_Parametro1_text,'string','N of shots');
                set(handles.Code_Parametro1_edit,'string','30');
                for II=2:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
        end
    case 2 %signal
    case 3 %output
        VAL=get(handles.cheroba,'value');
        switch(VAL)
            case 1
                for II=1:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
            case 2
                for II=1:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
            case 3
                for II=1:4
                   eval(['set(handles.Code_Parametro',char(48+II),'_text,''visible'',''off'');']) 
                   eval(['set(handles.Code_Parametro',char(48+II),'_edit,''visible'',''off'');']) 
                end
        end
end


% --- Executes during object creation, after setting all properties.
function cheroba_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cheroba (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in C_ADD_THIS.
function C_ADD_THIS_Callback(hObject, eventdata, handles)
TF=get(handles.CodificaCosa,'value');
switch(TF)
    case 1 %filter
        Quantity=get(handles.Code_List2,'value');
        Tipo=get(handles.cheroba,'value');
        FirstCondition=get(handles.C_FC,'value');
        if(FirstCondition)
            switch(Tipo)
                case 1
                    P1=get(handles.Code_Parametro1_edit,'string');
                    P2=get(handles.Code_Parametro2_edit,'string');
                    Line{1}=['CodeOutput=find( (#',num2str(Quantity),'>=',P1,').*(#',num2str(Quantity),'<=',P2,') );'];
                case 2
                    P1=get(handles.Code_Parametro1_edit,'string');
                    P2=get(handles.Code_Parametro2_edit,'string');
                    
                    if(any(strcmp(upper(P1),{'MEDIA','AVG','MEDIA','AVERAGE'})))
                        Line{1}=['!1=mean(#',num2str(Quantity),');'];
                    else
                        Line{1}=['!1=',P1,';'];
                    end
                        Line{2}=['!2=',P2,';'];
                        Line{3}=['!3=std(#',num2str(Quantity),');'];
                        Line{4}=['!4=!1 - abs(!3*!2);'];
                        Line{5}=['!5=!1 + abs(!3*!2);'];
                        Line{6}=['CodeOutput=find( (#',num2str(Quantity),'>=!4).*(#',num2str(Quantity),'<=!5) );'];
                case 3
                    P1=get(handles.Code_Parametro1_edit,'string');
                    P2=get(handles.Code_Parametro2_edit,'string');
                    if(any(strcmp(upper(P1),{'MEDIA','AVG','MEDIA','AVERAGE'})))
                        Line{1}=['!1=mean(#',num2str(Quantity),');'];
                        Line{2}=['!2=',P2,';'];
                        Line{3}=['!4=!1 - abs(!1*!2);'];
                        Line{4}=['!5=!1 + abs(!1*!2);'];
                        Line{5}=['CodeOutput=find( (#',num2str(Quantity),'>=!4).*(#',num2str(Quantity),'<=!5) );'];
                    else
                        Line{1}=['!1=mean(#',num2str(Quantity),');'];
                        Line{2}=['!2=',P2,';'];
                        Line{3}=['!4=',P1,' - abs(!1*!2);'];
                        Line{4}=['!5=',P1,' + abs(!1*!2);'];
                        Line{5}=['CodeOutput=find( (#',num2str(Quantity),'>=!4).*(#',num2str(Quantity),'<=!5) );'];
                       
                    end
                case 4
                    P1=get(handles.Code_Parametro1_edit,'string');
                    Line{1}=['[!1,!2]=sort(#',num2str(1+2*(handles.ProfileProcessNumber+1)),');'];
                    Line{2}=['!3=length(!2);'];
                    Line{3}=['CodeOutput=!2(max(1,!3-',P1,'):!3) ;'];
            end
            set(handles.CurrentCode,'value',1);
            set(handles.CurrentCode,'String',Line);
        else
            
            
        end
        
        switch(Tipo)
            case 1
                P1=get(handles.Code_Parametro1_edit,'string');
                P2=get(handles.Code_Parametro2_edit,'string');
            case 2
                P1=get(handles.Code_Parametro1_edit,'string');
                P2=get(handles.Code_Parametro2_edit,'string');
            case 3
                P1=get(handles.Code_Parametro1_edit,'string');
                P2=get(handles.Code_Parametro2_edit,'string');
        end
    case 2 %signal
    case 3 %output
        Quantity=get(handles.Code_List2,'value');
        Tipo=get(handles.cheroba,'value');
        switch(Tipo)
            case 1
                Line{1}=['CodeOutput=mean(#',num2str(Quantity),');'];
            case 2
                Line{1}=['CodeOutput=std(#',num2str(Quantity),');'];
            case 3
                Line{1}=['CodeOutput=std(#',num2str(Quantity),')/mean(#',num2str(Quantity),');'];
        end
        set(handles.CurrentCode,'value',1);
        set(handles.CurrentCode,'String',Line);
        
end



function Code_Parametro1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Code_Parametro1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Code_Parametro1_edit as text
%        str2double(get(hObject,'String')) returns contents of Code_Parametro1_edit as a double


% --- Executes during object creation, after setting all properties.
function Code_Parametro1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_Parametro1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Code_Parametro2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Code_Parametro2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Code_Parametro2_edit as text
%        str2double(get(hObject,'String')) returns contents of Code_Parametro2_edit as a double


% --- Executes during object creation, after setting all properties.
function Code_Parametro2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_Parametro2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Code_Parametro3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Code_Parametro3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Code_Parametro3_edit as text
%        str2double(get(hObject,'String')) returns contents of Code_Parametro3_edit as a double


% --- Executes during object creation, after setting all properties.
function Code_Parametro3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_Parametro3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Code_Parametro4_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Code_Parametro4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Code_Parametro4_edit as text
%        str2double(get(hObject,'String')) returns contents of Code_Parametro4_edit as a double


% --- Executes during object creation, after setting all properties.
function Code_Parametro4_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Code_Parametro4_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in C_FC.
function C_FC_Callback(hObject, eventdata, handles)
set(handles.C_FC,'value',1);


% --- Executes on button press in GUI_DUMP.
function GUI_DUMP_Callback(hObject, eventdata, handles)
set(handles.Stop3,'UserData',0);
set(handles.GUI_DUMP,'backgroundcolor',handles.ColorON);


% --- Executes on button press in TakeBackground.
function TakeBackground_Callback(hObject, eventdata, handles)
profile=get(handles.ProfileMonitorName,'String'); ReadProfile=1;
NumberOfBackgrounds=str2num(get(handles.e_block,'String'))
try
    if(ReadProfile)
        [prof,ts_old]=lcaGetSmart(profile);
        ONLINE=1;
    else
        [prof,ts_old]=lcaGetSmart(Pvlist{1});
        ONLINE=1;
    end
catch ME
    if(ReadProfile)
        [prof,ts_old]=lcaGetDonk(profile,1);
        ONLINE=0;
    else
        [prof,ts_old]=lcaGetDonk(Pvlist{1},1);
        ONLINE=0;
    end
end
CameraSize=get(handles.ProfileMonitorName,'UserData')

if(CameraSize.Rows*CameraSize.Columns>1)
    nova=1;
    BackgroundBlock=double(prof)/NumberOfBackgrounds;
    if(nova<NumberOfBackgrounds)
      if(ONLINE)
          for II=1:120*NumberOfBackgrounds
              [profnew,ts_new]=lcaGetSmart(profile);
              if(norm(profnew-prof))
                  BackgroundBlock=BackgroundBlock+double(profnew)/NumberOfBackgrounds;
                  pause(1/120);
                  nova=nova+1;
                  prof=profnew;
              end
              if(nova>=NumberOfBackgrounds)
                  break
              end
          end
      else
          for II=1:120*NumberOfBackgrounds
              [profnew,ts_new]=lcaGetDonk(profile);
              if(norm(profnew-prof))
                  BackgroundBlock=BackgroundBlock+double(profnew)/NumberOfBackgrounds;
                  nova=nova+1;
                  prof=profnew;
              end
              if(nova>=NumberOfBackgrounds)
                  break
              end
          end  
      end
    end
    A=figure(1000);
    if(CameraSize.Rows==1 || CameraSize.Columns==1)
        plot(BackgroundBlock)
        handles.BackgroundBlock=BackgroundBlock;
        if((nova)<NumberOfBackgrounds)
            title(['Acquisition Rate too low ',num2str(nova),' / ',num2str(NumberOfBackgrounds)],'Color',[1,0,0])
            handles.BackgroundBlock=handles.BackgroundBlock*NumberOfBackgrounds/nova;
            hold on, plot(handles.BackgroundBlock,'r');
        else
            title(['Acquired',num2str(nova),' / ',num2str(NumberOfBackgrounds)],'Color',[0,1,0]) 
        end
    else
        imagesc(reshape(BackgroundBlock,CameraSize.Rows,CameraSize.Columns));
        handles.BackgroundBlock=reshape(BackgroundBlock,CameraSize.Rows,CameraSize.Columns);
        if((nova)<NumberOfBackgrounds)
            title(['Acquisition Rate too low ',num2str(nova),' / ',num2str(NumberOfBackgrounds)],'Color',[1,0,0])
            handles.BackgroundBlock=handles.BackgroundBlock*NumberOfBackgrounds/nova;
            hold on, plot(handles.BackgroundBlock,'r');
        else
            title(['Acquired',num2str(nova),' / ',num2str(NumberOfBackgrounds)],'Color',[0,1,0]) 
        end
    end
    BackgroundSaved=handles.BackgroundBlock;
    %save LastSavedBackground BackgroundSaved
    guidata(hObject, handles);
    set(handles.NaClOBackground,'enable','on')
end

% --- Executes on button press in AppenOneBlockMore.
function AppenOneBlockMore_Callback(hObject, eventdata, handles)
Init_Vars=Initialize_Recording(handles,2);
set(handles.IlTestoNumero50,'Userdata',Init_Vars);
if(Init_Vars.INIT_FAILED)
    return
end
ScreenToBeUpdated=Init_Vars.UpdateMode;
[ONLINE,prof]=CheckOnlineMode(Init_Vars,handles);
lcaGetDonkCalls=ONLINE;
if(Init_Vars.usebsa)
    if(~Init_Vars.PvNumber)
        Init_Vars.usebsa=0;
        set(handles.c_BSA,'value',0);
    else 
        [myeDefNumber,new_name1,new_name2]=Initialize_Double_Buffer(handles,Init_Vars);
        if(any(isnan(myeDefNumber)) || (any(myeDefNumber==0)))
            disp('eDef Initialization failed, going to non BSA mode')
            Init_Vars.usebsa=0;
            set(handles.c_BSA,'value',0);
        end
    end
end

% [SPVA,SPVB]=size(handles.Buffer.PV);
% [SPr1VA,SPr1VB]=size(handles.Buffer.Prof);
% [SPr2VA,SPr2VB]=size(handles.Buffer.Prof2);
% set(handles.dialogotrasordi,'string','el. stored');
% set(handles.dia_text_rec,'string',num2str(max([SPVB,SPr1VB,SPr2VB,SPSignB,SPFiltB])));

if(Init_Vars.ReadProfile) % Get the size of the profile and decides if transpose the vector
[SA,SB]=size(prof);
    if(Init_Vars.Image2D)
        if(Init_Vars.ProjectionDirection==3)
            prof=reshape(prof,Init_Vars.CameraSize.Rows,Init_Vars.CameraSize.Columns);
            prof=prof(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
            proj1=mean(double(prof),1);
            proj2=mean(double(prof),2);
            if(~isempty(handles.BackgroundBlock))
               backg1=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
               backg2=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
               backg1=mean(double(backg1),1);
               backg2=mean(double(backg2),2);
            else
               backg1=0*proj1; backg2=0*proj2; 
            end
        else
            prof=reshape(prof,Init_Vars.CameraSize.Rows,Init_Vars.CameraSize.Columns);
            prof=prof(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
            proj=mean(double(prof),Init_Vars.ProjectionDirection);
            if(~isempty(handles.BackgroundBlock))
               backg=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2),Init_Vars.ROIy(1):Init_Vars.ROIy(2));
               backg=mean(double(backg),Init_Vars.ProjectionDirection);
            else
               backg=0*proj;
            end
            if Init_Vars.ProjectionDirection==1
                TRANSPOSE=1;
            else
                TRANSPOSE=0;
            end
        end
    else
        proj=prof(Init_Vars.ROIx(1):Init_Vars.ROIx(2));
        if(~isempty(handles.BackgroundBlock))
            backg=handles.BackgroundBlock(Init_Vars.ROIx(1):Init_Vars.ROIx(2));
        else
            backg=0*proj;
        end
        if(SB==1)
            TRANSPOSE=1;
        else
            TRANSPOSE=0;
        end
    end
end

if(~Init_Vars.usebsa) %it is not a bsa acquisition, set up buffers
    if(Init_Vars.PvNumber)
        ReadCuePVs=zeros(Init_Vars.PvNumber,Init_Vars.blocksize);
        ReadCuePvsTS=zeros(Init_Vars.PvNumber,Init_Vars.blocksize);
    end
    if(Init_Vars.ReadProfile)
        if(Init_Vars.BothProfiles)
            ReadCueProf1=zeros(Init_Vars.blocksize,length(proj1));
            ReadCueProf2=zeros(Init_Vars.blocksize,length(proj2));
        else 
            ReadCueProf=zeros(Init_Vars.blocksize,length(proj));
        end
        ReadCueProfTS=zeros(1,Init_Vars.blocksize);
    end
    ReadCueValid=1;
else %it is a bsa acquisition, set up buffers
    Buffer2_TS=zeros(2800,1);
    Buffer1_TS=zeros(2800,1);
    eDef_BASEDELAYTIMING=Init_Vars.DoubleBufferCycle; %seconds for one/other buffer
    Phase_Cycle=0;
    if(Init_Vars.ReadProfile)
        ReadCueProfTS=zeros(1,2800*2);
        if(~Init_Vars.BothProfiles)
            ReadCueProf=zeros(2800*2,length(proj));
        else
            ReadCueProf1=zeros(2800*2,length(proj1));
            ReadCueProf2=zeros(2800*2,length(proj2));
        end
    else
       LastValidTime=-inf; 
    end
    ReadCueValid=1;
    Just_Started=1;
end

ValidDataPointer=1;
UD=get(handles.CVCRCIISSA,'UserData');
for II=1:Init_Vars.PvNotSyncNumber
    Init_Vars.BaseLineX{end+1}=Init_Vars.PvNotSync{II};
    Init_Vars.BaseLineY{end+1}=Init_Vars.PvNotSync{II};
end
UD{1}=Init_Vars.BaseLineX;UD{2}=Init_Vars.BaseLineY;UD{3}=Init_Vars.FiltersList;
set(handles.CVCRCIISSA,'UserData',UD);
%delete_or_update_figures(handles) - nobody is updating figures during a
%single caputre (?)

ReadProfile=Init_Vars.ReadProfile; BothProfiles=Init_Vars.BothProfiles; Image2D=Init_Vars.Image2D; PvNumber=Init_Vars.PvNumber; blocksize=Init_Vars.blocksize; keepsize=Init_Vars.keepsize;
ROIx=Init_Vars.ROIx; ROIy=Init_Vars.ROIy; profile=Init_Vars.profile; Pvlist=Init_Vars.Pvlist; ProjectionDirection=Init_Vars.ProjectionDirection; CameraSize=Init_Vars.CameraSize;
BasicProcessing=Init_Vars.BasicProcessing; FilterON=Init_Vars.FilterON; SignalON=Init_Vars.SignalON; usebsa=Init_Vars.usebsa; PulseIDProfileDelay=Init_Vars.PulseIDProfileDelay;
CodiceFiltro=Init_Vars.CodiceFiltro; CodiceSig=Init_Vars.CodiceSig; SingleValuePvs=Init_Vars.SingleValuePvs; SubtractiveConstant= Init_Vars.SubtractiveConstant;
ResortingX=Init_Vars.ResortingX; ResortingY=Init_Vars.ResortingY;FilterResorting=Init_Vars.FilterResorting;
%Read the single-valued variables
if(ONLINE)
   for II=1:numel(Init_Vars.PvNotSyncNumber)
       TrueSingleValuePvs(II)=lcaGetSmart(Init_Vars.PvNotSync{II});
   end
else
   for II=1:numel(Init_Vars.PvNotSyncNumber)
       lcaGetDonkCalls=1;
       TrueSingleValuePvs(II)=lcaGetDonk(Init_Vars.PvNotSync{II},lcaGetDonkCalls);
   end
end

handles.SingleValuePvs=SingleValuePvs;
%Reading cycle

if(usebsa) %bsa cycle for getting data synchronously
        ValidDataArray_PV=[];ValidPulseIDs=[];ValidTimeStamps=[];
        ValidDataArray_Pr1=[]; ValidDataArray_Pr2=[];  ValidDataArray_Pr=[];
                
        switch(Phase_Cycle)
            case 0
                eDefOn(myeDefNumber(1))
            case 1
            case 2
            case 3    
        end
        tic
        % get Pvs if has to get Pvs
    while(toc < eDef_BASEDELAYTIMING) %just get profile monitor while you can
        if(ReadProfile)
            [Image,ReadCueProfTS(1,ReadCueValid)]=lcaGetSmart(profile); 
                if(Image2D)
                    prof=reshape(Image,CameraSize.Rows,CameraSize.Columns);
                    prof=prof(ROIx(1):ROIx(2),ROIy(1):ROIy(2));
                    if(BothProfiles)
                        proj1=mean(double(prof),1)-backg1;
                        proj2=transpose(mean(double(prof),2))-backg2;
                    else
                        proj=mean(double(prof),ProjectionDirection)-backg;
                    end    
                else
                    proj=double(Image(ROIx(1):ROIx(2)))-backg;
                end
                if(BothProfiles)
                    ReadCueProf1(ReadCueValid,:)=proj1;
                    ReadCueProf2(ReadCueValid,:)=proj2;
                else
                    if(TRANSPOSE)
                        ReadCueProf(ReadCueValid,:)=transpose(proj);
                    else
                        ReadCueProf(ReadCueValid,:)=proj;
                    end  
                end
         ReadCueValid=ReadCueValid+1; %Processing should take the time 
         pause(eDef_BASEDELAYTIMING/2800*2); %Not sure if it is needed, puts a safeguard agains buffer filling
        else %only BSA acquisition, wait the posted time and do nothing
            pause(0.05);
        end
    end
    Phase_Cycle
    switch(Phase_Cycle)
        case 0
            eDefOn(myeDefNumber(2))
            GrabTurn=0; 
        case 1
            eDefOff(myeDefNumber(1))
            %retrieve buffer 1
            [the_matrix1,TSY1] = lcaGet(new_name1, 2800 );
            pulseID_Buffer1_TS = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',myeDefNumber(1)));
            if(Just_Started)
              the_matrix2=the_matrix1;TSY2=TSY1;pulseID_Buffer2_TS=pulseID_Buffer1_TS;
              Just_Started=0;
            end
            GrabTurn=1;
        case 2
             %if(Just_Started)
               eDefOn(myeDefNumber(1));
            GrabTurn=0;   
             %end
        case 3
            eDefOff(myeDefNumber(2))
            [the_matrix2,TSY2] = lcaGet(new_name2, 2800 );
            pulseID_Buffer2_TS = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d','SYS0',myeDefNumber(2)));
            %Buffer2_used = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d.NUSE','SYS0',myeDefNumber(2)));
            %[a,b,c]=util_readPVHst(new_name2, myeDefNumber(2));
            %save TEMP2
            GrabTurn=1;

    end

    Phase_Cycle=mod((Phase_Cycle+1),4);   

    %Does the timestamps matching for BSA case
    if(ReadProfile) %Must Have also Pvs, altrimenti va in non bsa mode automaticamente, e' il piu' comprensibile su cosa deve fare
        %trova semplicemente i pvs che hanno lo stesso timestamps
        if(GrabTurn)
%           pulseID_Buffer1_TS=bitand(uint32(imag(Buffer1_TS)),hex2dec('1FFFF'));
%           pulseID_Buffer2_TS=bitand(uint32(imag(Buffer2_TS)),hex2dec('1FFFF'));
          pulseID_Profile=bitand(uint32(imag(ReadCueProfTS(1:(ReadCueValid-1)))),hex2dec('1FFFF'));
          [uniquePulseID_Profile,uniquePulseID_Profile_Location]=unique(pulseID_Profile);
          [FullBufferTimeStamps,LocationFullBuffer1,LocationFullBuffer2]=union(pulseID_Buffer1_TS,pulseID_Buffer2_TS);
          [ValidPulseIDs,LocationFullBuffer,LocationInUniquePulseId_Profile]=intersect(FullBufferTimeStamps,uniquePulseID_Profile);

          if(~BothProfiles)
              ValidDataArray_Pr=ReadCueProf(uniquePulseID_Profile_Location(LocationInUniquePulseId_Profile),:).'-SubtractiveConstant;
          else
              ValidDataArray_Pr1=ReadCueProf1(uniquePulseID_Profile_Location(LocationInUniquePulseId_Profile),:).'-SubtractiveConstant;
              ValidDataArray_Pr2=ReadCueProf2(uniquePulseID_Profile_Location(LocationInUniquePulseId_Profile),:).'-SubtractiveConstant;
          end
          ValidTimeStamps=ReadCueProfTS(uniquePulseID_Profile_Location(LocationInUniquePulseId_Profile));
          if(~isempty(LocationFullBuffer1))
              [dontcare1,WhereTheywillGo,WhereIwillFoundthem]=intersect(FullBufferTimeStamps(LocationFullBuffer),pulseID_Buffer1_TS(LocationFullBuffer1));
              ValidDataArray_PV(:,WhereTheywillGo)=the_matrix1(:,WhereIwillFoundthem);
          end
          if(~isempty(LocationFullBuffer2))
              [dontcare1,WhereTheywillGo,WhereIwillFoundthem]=intersect(FullBufferTimeStamps(LocationFullBuffer),pulseID_Buffer2_TS(LocationFullBuffer2));
              ValidDataArray_PV(:,WhereTheywillGo)=the_matrix2(:,WhereIwillFoundthem);
          end
          else
          ValidDataArray_PV=[];
          ValidPulseIDs=[];
          ValidTimeStamps=[]; 
          ReadCueValid=1; %After Grabbing, resets readcue ...
        end
    else %Only Pvs, come fa a sapere da dove? (absolute time will do the trick, FILLING and Pointer =1 means just started)
      if(GrabTurn) 
        %save TEMP
%            pulseID_Buffer1_TS=bitand(uint32(imag(Buffer1_TS)),hex2dec('1FFFF'));
%            pulseID_Buffer2_TS=bitand(uint32(imag(Buffer2_TS)),hex2dec('1FFFF'));
       [FullBufferTimeStamps,LocationFullBuffer1,LocationFullBuffer2]=union(pulseID_Buffer1_TS,pulseID_Buffer2_TS);
       FullPulseIDs=[pulseID_Buffer1_TS(LocationFullBuffer1),pulseID_Buffer2_TS(LocationFullBuffer2)];
       TemporaryTimeStampsREAL=FullPulseIDs/360+real(TSY1(1))+imag(TSY1(1))/10^9;
       FullMatrixTemporary=[the_matrix1(:,LocationFullBuffer1),the_matrix2(:,LocationFullBuffer2)];
       [SortedTimeStampsTemporary, SortedTimeStampsTemporaryOrder ]= sort(TemporaryTimeStampsREAL);
       firstgoodthisset=find(SortedTimeStampsTemporary>LastValidTime,1,'first');
       if(isempty(firstgoodthisset) && sum(any(~isnan(FullMatrixTemporary))))
           ValidDataArray_PV=[];
           ValidPulseIDs=[];
           ValidTimeStamps=[]; 
       else
           LastValidTime=max(SortedTimeStampsTemporary);
           ValidDataArray_PV=FullMatrixTemporary(:,SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
           ValidTimeStamps=TemporaryTimeStampsREAL(SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
           ValidPulseIDs=FullPulseIDs(SortedTimeStampsTemporaryOrder(firstgoodthisset:end));
       end
      else
        ValidDataArray_PV=[];
        ValidPulseIDs=[];
        ValidTimeStamps=[]; 
      end
    end    
else % not bsa data, just read and order in best effort mode
    ValidDataArray_Pr1=[];
    ValidDataArray_Pr2=[];
    ValidDataArray_Pr=[];
    if(ReadProfile)
        if(ONLINE)
            for ReadID=1:blocksize %read cycle
                [Image,ReadCueProfTS(1,ReadID)]=lcaGetSmart(profile);
                for PvID=1:PvNumber
                    [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID)]=lcaGetSmart(Pvlist{PvID});
                end
                if(Image2D)
                    prof=reshape(Image,CameraSize.Rows,CameraSize.Columns);
                    prof=prof(ROIx(1):ROIx(2),ROIy(1):ROIy(2));
                    if(BothProfiles)
                        proj1=mean(double(prof),1)-backg1;
                        proj2=transpose(mean(double(prof),2))-backg2;
                    else
                        proj=mean(double(prof),ProjectionDirection)-backg;
                    end    
                else
                    proj=double(Image(ROIx(1):ROIx(2)))-backg;
                end
                if(BothProfiles)
                    ReadCueProf1(ReadID,:)=proj1;
                    ReadCueProf2(ReadID,:)=proj2;
                else
                    if(TRANSPOSE)
                        ReadCueProf(ReadID,:)=transpose(proj);
                    else
                        ReadCueProf(ReadID,:)=proj;
                    end  
                end
            end
        else % This else if for test (works only in offline mode to try viewer features or re-play data)
            for ReadID=1:blocksize %read cycle
                [Image,ReadCueProfTS(1,ReadID),lcaGetDonkCalls]=lcaGetDonk(profile,lcaGetDonkCalls);
                for PvID=1:PvNumber
                    [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID),lcaGetDonkCalls]=lcaGetDonk(Pvlist{PvID},lcaGetDonkCalls);
                end
                if(Image2D)
                    prof=reshape(Image,CameraSize.Rows,CameraSize.Columns);
                    prof=prof(ROIx(1):ROIx(2),ROIy(1):ROIy(2));
                    if(BothProfiles)
                        proj1=mean(double(prof),1)-backg1;
                        proj2=transpose(mean(double(prof),2))-backg2;
                    else
                        proj=mean(double(prof),ProjectionDirection)-backg;
                    end    
                else
                    proj=double(Image(ROIx(1):ROIx(2)))-backg;
                end
                if(BothProfiles)
                    ReadCueProf1(ReadID,:)=proj1;
                    ReadCueProf2(ReadID,:)=proj2;
                else
                    if(TRANSPOSE)
                        ReadCueProf(ReadID,:)=transpose(proj);
                    else
                        ReadCueProf(ReadID,:)=proj;
                    end  
                end
            end  
        end % End of test else
    else
        if(ONLINE)
            for ReadID=1:blocksize
                for PvID=1:PvNumber
                    [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID)]=lcaGetSmart(Pvlist{PvID});
                end
            end
        else
            for ReadID=1:blocksize
                for PvID=1:PvNumber
                    [ReadCuePVs(PvID,ReadID),ReadCuePvsTS(PvID,ReadID),lcaGetDonkCalls]=lcaGetDonk(Pvlist{PvID},lcaGetDonkCalls);
                end
            end
        end
    end

    % MatchTimeStamps

    if(ReadProfile && PvNumber) %Match all of them THIS PART OF CODE WORKS ONLY FOR NON-BSA MODE
        pulseID_Profile=bitand(uint32(imag(ReadCueProfTS)),hex2dec('1FFFF'))+PulseIDProfileDelay;
        ValidDataArray_PV=[];
        pulseID_Pvs=bitand(uint32(imag(ReadCuePvsTS)),hex2dec('1FFFF'));
        [UniqueProfilePulseIDs,UniqueLocations_Profile]=unique(pulseID_Profile);
        uniqueintersect=UniqueProfilePulseIDs;
        for PvID=1:PvNumber
            [UniquePvPulseID{PvID},UniquePvPulseID_Locations{PvID}]=unique(pulseID_Pvs(PvID,:));
            uniqueintersect=intersect(uniqueintersect,UniquePvPulseID{PvID});
        end
        [dontcare_isintersectback, Ordine, dontcare2_orderINuniqueintersect]=intersect(UniqueProfilePulseIDs,uniqueintersect);
        if(~BothProfiles)
            ValidDataArray_Pr=ReadCueProf(UniqueLocations_Profile(Ordine),:).'-SubtractiveConstant;
        else
            ValidDataArray_Pr1=ReadCueProf1(UniqueLocations_Profile(Ordine),:).'-SubtractiveConstant;
            ValidDataArray_Pr2=ReadCueProf2(UniqueLocations_Profile(Ordine),:).'-SubtractiveConstant;
        end
        ValidPulseIDs=dontcare_isintersectback;
        ValidTimeStamps=ReadCueProfTS(UniqueLocations_Profile(Ordine));
        for PvID=1:PvNumber
            [dontcare, IR, dontcare2]=intersect(UniquePvPulseID{PvID},uniqueintersect);
            ValidDataArray_PV(PvID,:)=ReadCuePVs(PvID,UniquePvPulseID_Locations{PvID}(IR));
        end 
    elseif(ReadProfile) %Only profile all good, just remove duplicates
        pulseID_Profile=bitand(uint32(imag(ReadCueProfTS)),hex2dec('1FFFF'));
        [uniquevalues_pr,uniquelocations_pr]=unique(pulseID_Profile);
        ValidDataArray_PV=[];
        if(~BothProfiles)
            ValidDataArray_Pr=ReadCueProf(uniquelocations_pr,:).'-SubtractiveConstant;
        else
            ValidDataArray_Pr1=ReadCueProf1(uniquelocations_pr,:).'-SubtractiveConstant;
            ValidDataArray_Pr2=ReadCueProf2(uniquelocations_pr,:).'-SubtractiveConstant;
        end
        ValidPulseIDs=uniquevalues_pr;
        ValidTimeStamps=ReadCueProfTS(uniquelocations_pr);
    else % Match Pvs
        ValidDataArray_PV=[];
        pulseID_Pvs=bitand(uint32(imag(ReadCuePvsTS)),hex2dec('1FFFF'));
        [uniquevalues{1},uniquelocations{1}]=unique(pulseID_Pvs(1,:));
        uniqueintersect=uniquevalues{1};
        for PvID=2:PvNumber
            [uniquevalues{PvID},uniquelocations{PvID}]=unique(pulseID_Pvs(PvID,:));
            uniqueintersect=intersect(uniqueintersect,uniquevalues{PvID});
        end
        for PvID=1:PvNumber
            [dontcare, IR, dontcare2]=intersect(uniquevalues{PvID},uniqueintersect);
            ValidDataArray_PV(PvID,:)=ReadCuePVs(PvID,uniquelocations{PvID}(IR));
        end
        ValidPulseIDs=uniqueintersect;
        ValidTimeStamps=ReadCuePvsTS(PvID,uniquelocations{PvID}(IR));
    end     
end
% we have ValidPulseIDs, ValidTimeStamps, ValidDataArray_PV,
% ValidDataArray_Pr, ValidDataArray_Pr1, ValidDataArray_Pr2,
% SingleValuePvs, TrueSingleValuePvs.
% those are organized differently than in the cont. scan, this because one
% can easily add more processing without necessary deleting the buffer

ValidDataArray_PV=[real(ValidTimeStamps)+imag(ValidTimeStamps)/10^9;double(ValidPulseIDs);ValidDataArray_PV];
for II=1:length(TrueSingleValuePvs)
    ValidDataArray_PV(end+1,:)=TrueSingleValuePvs(II);
end
if(~isempty(ValidDataArray_PV))
    handles.Buffer.PV=[handles.Buffer.PV,ValidDataArray_PV];
end
if(~isempty(ValidDataArray_Pr1))
    handles.Buffer.Prof=[handles.Buffer.Prof,ValidDataArray_Pr1];
    handles.Buffer.Prof2=[handles.Buffer.Prof2,ValidDataArray_Pr2];
end
if(~isempty(ValidDataArray_Pr))
    handles.Buffer.Prof=[handles.Buffer.Prof,ValidDataArray_Pr];
end

% Evaluate Extra Signals
EvaluatedProfileQuantities2=[];
EvaluatedProfileQuantities=[];

if(ReadProfile)
    
    if(BothProfiles)
        
        [Prof1length1,NumberofShots]=size(ValidDataArray_Pr1); %SA=1024, SB number of data
        [Prof1length2,NumberofShots]=size(ValidDataArray_Pr2);
    else
        [Prof1length,NumberofShots]=size(ValidDataArray_Pr);
    end    
    for ProcessCounter=1:handles.ProfileProcessNumber
        if(BasicProcessing(ProcessCounter))
            switch(ProcessCounter)
                case 1 %Signal Sum
                    if(BothProfiles)
                        TotalArea1=sum(ValidDataArray_Pr1);
                        TotalArea2=sum(ValidDataArray_Pr2);
                        EvaluatedProfileQuantities(1,:)=TotalArea1;
                        EvaluatedProfileQuantities2(1,:)=TotalArea2;
                    else
                        TotalArea=sum(ValidDataArray_Pr);
                        EvaluatedProfileQuantities(1,:)=TotalArea;
                    end
                case 2 %Peak and Peak Location
                    if(BothProfiles)
                        [PeakValue1,PeakPosition1]=max(ValidDataArray_Pr1);
                        [PeakValue2,PeakPosition2]=max(ValidDataArray_Pr2);
                        EvaluatedProfileQuantities(end+1,:)=PeakValue1;
                        EvaluatedProfileQuantities(end+1,:)=PeakPosition1;
                        EvaluatedProfileQuantities2(end+1,:)=PeakValue2;
                        EvaluatedProfileQuantities2(end+1,:)=PeakPosition2;
                    else
                        [PeakValue,PeakPosition]=max(ValidDataArray_Pr);
                        EvaluatedProfileQuantities(end+1,:)=PeakValue;
                        EvaluatedProfileQuantities(end+1,:)=PeakPosition;
                    end
                case 3 %First Moment
                    if(BothProfiles)
                        if(BasicProcessing(1))
                            FirstMoment1=(1:Prof1length1)*ValidDataArray_Pr1./TotalArea1;
                            FirstMoment2=(1:Prof1length2)*ValidDataArray_Pr2./TotalArea2;
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment1;
                            EvaluatedProfileQuantities2(end+1,:)=FirstMoment2;
                        else
                            FirstMoment1=(1:Prof1length1)*ValidDataArray_Pr1./sum(ValidDataArray_Pr1);
                            FirstMoment2=(1:Prof1length2)*ValidDataArray_Pr2./sum(ValidDataArray_Pr2);
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment1;
                            EvaluatedProfileQuantities2(end+1,:)=FirstMoment2;
                        end
                    else
                        if(BasicProcessing(1))
                            FirstMoment=(1:Prof1length)*ValidDataArray_Pr./TotalArea;
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment;
                        else
                            FirstMoment=(1:Prof1length)*ValidDataArray_Pr./sum(ValidDataArray_Pr);
                            EvaluatedProfileQuantities(end+1,:)=FirstMoment;
                        end
                    end
                case 4 %FWHM
                    if(BothProfiles)
                        if(~BasicProcessing(2))
                            [PeakValue1,PeakPosition1]=max(ValidDataArray_Pr1);
                            [PeakValue2,PeakPosition2]=max(ValidDataArray_Pr2);
                        end
                        FWHM1=zeros(1,length(ValidPulseIDs));FWHM2=zeros(1,length(ValidPulseIDs));
                        for II=1:NumberofShots
                            mv1=find(ValidDataArray_Pr1(:,II)>(PeakValue1(II)/2),1,'first');
                            MV1=find(ValidDataArray_Pr1(:,II)>(PeakValue1(II)/2),1,'last');
                            mv2=find(ValidDataArray_Pr2(:,II)>(PeakValue2(II)/2),1,'first');
                            MV2=find(ValidDataArray_Pr2(:,II)>(PeakValue2(II)/2),1,'last');
                            if(isempty(mv1) || isempty(MV1))
                                FWHM1(II)=NaN;
                            else
                                FWHM1(II)=MV1-mv1+1;
                            end
                            if(isempty(mv2) || isempty(MV2))
                                FWHM2(II)=NaN;
                            else
                                FWHM2(II)=MV2-mv2+1;
                            end
                        end   
                        EvaluatedProfileQuantities(end+1,:)=FWHM1;
                        EvaluatedProfileQuantities2(end+1,:)=FWHM2;
                    else
                        if(~BasicProcessing(2))
                            [PeakValue,PeakPosition]=max(ValidDataArray_Pr);
                        end
                        FWHM=zeros(1,length(ValidPulseIDs));
                        for II=1:NumberofShots
                            mv=find(ValidDataArray_Pr(:,II)>(PeakValue(II)/2),1,'first');
                            MV=find(ValidDataArray_Pr(:,II)>(PeakValue(II)/2),1,'last');
                            if(isempty(mv) || isempty(MV))
                                FWHM(II)=NaN;
                            else
                                FWHM(II)=MV-mv+1;
                            end
                        end
                        EvaluatedProfileQuantities(end+1,:)=FWHM;
                    end
            end
        end
    end  
end

if(~isempty(EvaluatedProfileQuantities))
    handles.Buffer.ProfQuant=[handles.Buffer.ProfQuant,EvaluatedProfileQuantities];
end
if(~isempty(EvaluatedProfileQuantities2))
    handles.Buffer.ProfQuant2=[handles.Buffer.ProfQuant2,EvaluatedProfileQuantities2];
end

NewSignals=[];
SignalEvaluated=1;
for II=1:handles.NumberOfAvailableSignals
       if(SignalON(II))
           for III=1:numel(CodiceSig(II).Code)
                eval(CodiceSig(II).Code{III})
           end 
           NewSignals(SignalEvaluated,:)=CodeOutput;
           SignalEvaluated=SignalEvaluated+1;
       end
end

if(~isempty(NewSignals))
    handles.Buffer.SignalEvaluated=[handles.Buffer.SignalEvaluated,NewSignals];
end

[SPVA,SPVB]=size(handles.Buffer.PV);
% [SPSignA,SPSignB]=size(handles.Buffer.Signal);
% [SPFiltA,SPFiltB]=size(handles.Buffer.Filter);
[SPr1VA,SPr1VB]=size(handles.Buffer.Prof);
[SPr2VA,SPr2VB]=size(handles.Buffer.Prof2);
set(handles.dialogotrasordi,'string','el. stored');
set(handles.dia_text_rec,'string',num2str(max([SPVB,SPr1VB,SPr2VB])));

set(handles.dia_text_rec,'Userdata',handles.Buffer);

for II=1:handles.NumberOfAvailableSignals
   if(FilterON(II))
      for III=1:numel(CodiceFiltro(II).Code)
           eval(CodiceFiltro(II).Code{III})
      end
      Rimasti{II}=CodeOutput;
   end
end

if(any(FilterON))
    handles.Buffer.FilterEvaluated=Rimasti;
end

guidata(hObject, handles);



% % handles.Buffer.Signal=[];
% % handles.Buffer.Filter=[];
% handles.Buffer.Prof=[];
% handles.Buffer.Prof2=[];


%Evaluates Signals and Filters pay attention to right coding...
%Stored as: PVs, Profile1, Profile2, Signals, Filters. up to FIVE different
%structures for the buffer (time is not so important AND we want to recalculate signal without retaking the data, eventually.)

%Stores in the buffer

function OutCode=TranslateCode_NotOnlineVER(Code, handles, SignalsResorting, SynchPvResorting, ProfQuantResorting ,PvNumber,PvNotSyncNumber,FLAG)

%replace variables
% handles.SingleValuePvs read right away, do no really matter...
% handles.Buffer.SignalEvaluated
% handles.Buffer.FilterEvaluated (Never Used, no outputs...)
% handles.Buffer.ProfQuant
% handles.Buffer.ProfQuant2
% handles.Buffer.PV [non static and static, n shots]
% handles.Buffer.prof [size, events]
% handles.Buffer.prof2 [size, events]
%

% handles.ProfileProcessNumber=4;
% handles.NumberOfAvailableFilters=3;
% handles.NumberOfAvailableSignals=3;
% handles.NumberOfOnTheFlyVariables=6;
% handles.TSandPulseIds=2;

for II=1:numel(Code)
   for JJ=(handles.NumberOfOnTheFlyVariables + PvNotSyncNumber):-1:1
      if(JJ<=handles.NumberOfOnTheFlyVariables)
          Code{II}=regexprep(Code{II},['%',num2str(JJ)],['handles.SingleValuePvs(',num2str(JJ),')']);
      else
          if(FLAG==0)
              Code{II}=regexprep(Code{II},['%',num2str(JJ)],['ValidDataArray_PV(',num2str(PvNumber+2+JJ-handles.NumberOfOnTheFlyVariables),',:)']);
          else
              Code{II}=regexprep(Code{II},['%',num2str(JJ)],['handles.Buffer.PV(',num2str(PvNumber+2+JJ-handles.NumberOfOnTheFlyVariables),',:)']);
          end
      end 
   end
   for JJ=(PvNotSyncNumber+handles.TSandPulseIds+2*handles.ProfileProcessNumber+handles.NumberOfAvailableSignals):-1:1 % Only Single Value Pvs are the "Six Variables"
       if(JJ>2*handles.ProfileProcessNumber) %Pv or signals
           Dove=find(JJ==SynchPvResorting);
           if(~isempty(Dove))
                if(FLAG==0)
                      Code{II}=regexprep(Code{II},['#',num2str(JJ)],['ValidDataArray_PV(',num2str(Dove),',:)']);
                else
                      Code{II}=regexprep(Code{II},['#',num2str(JJ)],['handles.Buffer.PV(',num2str(Dove),',:)']);
                end
           end
           Dove=find(JJ==SignalsResorting);
           if(~isempty(Dove))
              Code{II}=regexprep(Code{II},['#',num2str(JJ)],['handles.Buffer.SignalEvaluated(',num2str(Dove),',:)']); 
           end
       end
        if((JJ<=2*handles.ProfileProcessNumber) && (JJ > handles.ProfileProcessNumber)) %proc 2
            Dove=find(JJ==ProfQuantResorting);
            Code{II}=regexprep(Code{II},['#',num2str(JJ)],['handles.Buffer.ProfQuant(',num2str(Dove),',:)']); 
        end
        if(JJ<=handles.ProfileProcessNumber) %proc 1
            Dove=find(JJ==ProfQuantResorting);
            Code{II}=regexprep(Code{II},['#',num2str(JJ)],['handles.Buffer.ProfQuant2(',num2str(Dove),',:)']); 
        end
   end
   Code{II}=regexprep(Code{II},'!','TemporaryVariable');
   if(FLAG==0)
       Code{II}=regexprep(Code{II},'FirstProfile','ValidDataArray_Pr');
       Code{II}=regexprep(Code{II},'SecondProfile','ValidDataArray_Pr2');
   else
       Code{II}=regexprep(Code{II},'FirstProfile','handles.Buffer.Prof');
       Code{II}=regexprep(Code{II},'SecondProfile','handles.Buffer.Prof2');
   end
   
end
for II=1:numel(Code)
    disp(Code{II})
end
OutCode=Code;

% --- Executes on button press in NaClO.
function handles=NaClO_Callback(hObject, eventdata, handles)
handles.Buffer.SignalEvaluated=[];
handles.Buffer.FilterEvaluated=[];
handles.Buffer.ProfQuant=[];
handles.Buffer.ProfQuant2=[];
handles.Buffer.PV=[];
handles.Buffer.Prof=[];
handles.Buffer.Prof2=[];
set(handles.dialogotrasordi,'string','el. stored');
set(handles.dia_text_rec,'string','0');
set(handles.dia_text_rec,'Userdata',handles.Buffer);
guidata(hObject, handles);



% --- Executes on button press in CominciaModalitaSchiavo.
function CominciaModalitaSchiavo_Callback(hObject, eventdata, handles)
CurrentValue=get(handles.CominciaModalitaSchiavo,'UserData');
if(CurrentValue)
    set(handles.CominciaModalitaSchiavo,'UserData',0)
    set(handles.CominciaModalitaSchiavo,'string','Start Listening Mode to PV:');
    set(handles.CominciaModalitaSchiavo,'BackgroundColor',handles.ColorIdle);
    set(handles.Stop3,'BackgroundColor',handles.ColorIdle);
    set(handles.Stop3,'enable','off');
    set(handles.Start3,'Enable','on');
    set(handles.Start3,'BackgroundColor',handles.ColorON);
    set(handles.Update_Figures_Cont,'enable','on');
    set(handles.AppenOneBlockMore,'enable','on');
    set(handles.CominciaModalitaSchiavo,'enable','on');
    set(handles.NaClO,'enable','on');
	return
else
    PvtoListen=get(handles.PvToListen,'string');
    try
        LastListenedValue=lcaGet(PvtoListen);
        set(handles.LPV,'string',num2str(LastListenedValue));
        ONLINE=1;
    catch ME
        previouscolor=get(handles.PvToListen,'backgroundcolor');
        set(handles.PvToListen,'backgroundcolor',[1,0,0]);
        pause(0.5)
        set(handles.PvToListen,'backgroundcolor',previouscolor);
        %return
        LastListenedValue=lcaGetDonk(PvtoListen);
        set(handles.LPV,'string',num2str(LastListenedValue));
        ONLINE=0;
    end
    set(handles.CominciaModalitaSchiavo,'UserData',1)
    set(handles.CominciaModalitaSchiavo,'string','Listening mode active. Press to stop.');
    set(handles.CominciaModalitaSchiavo,'BackgroundColor',handles.ColorON);
    set(handles.Start3,'Enable','off')
    set(handles.Start3,'BackgroundColor',handles.ColorIdle);
    set(handles.Update_Figures_Cont,'enable','off');
    set(handles.NaClO,'enable','on');
    while(1)
        pause(0.5)
        CurrentValue=get(handles.CominciaModalitaSchiavo,'UserData');
        if(~CurrentValue)
            break
        end
        if(ONLINE)
            LastListenedValue=lcaGet(PvtoListen);
            set(handles.LPV,'string',num2str(LastListenedValue));
        else
            LastListenedValue=lcaGetDonk(PvtoListen);
            set(handles.LPV,'string',num2str(LastListenedValue));
        end
        disp('Listening to PV figures')
    end
end


% --- Executes on button press in NaClOBackground.
function NaClOBackground_Callback(hObject, eventdata, handles)
handles.BackgroundBlock=[];
guidata(hObject, handles);
set(handles.NaClOBackground,'enable','off')


% --- Executes on button press in EditPvLists.
function EditPvLists_Callback(hObject, eventdata, handles)
set(handles.epv_FullList,'String',handles.FullPVList.root_name);
current_pv_synch=get(handles.PvSyncList,'String');
current_PvNotSyncList=get(handles.PvNotSyncList,'String');
set(handles.epv_MylistNotSync,'string',current_PvNotSyncList);
set(handles.epv_MylistSync,'string',current_pv_synch);
set(handles.epv_MylistNotSync,'value',1);
set(handles.epv_MylistSync,'value',1);
set(handles.epv_1,'String','');
set(handles.epv_2,'String','');
set(handles.epv_3,'String','');
set(handles.epv_4,'String','');
set(handles.PvlistPanel,'visible','on')
set(handles.uipanel1,'visible','off');
set(handles.CodeVariablesPanel,'visible','off');

function update_pv_tobeadded_list(handles)
C1=get(handles.epv_1,'String');
C2=get(handles.epv_2,'String');
C3=get(handles.epv_3,'String');
C4=get(handles.epv_4,'String');
Conditions=zeros(4,numel(handles.FullPVList.root_name));
if(isempty(C1))
    Conditions(1,:)=1;
else
    Conditions(1,:)=double(strcmpi(C1,handles.FullPVList.fp));
end
if(isempty(C2))
    Conditions(2,:)=1;
else
    Conditions(2,:)=double(strcmpi(C2,handles.FullPVList.sp));
end
if(isempty(C3))
    Conditions(3,:)=1;
else
    Conditions(3,:)=double(strcmpi(C3,handles.FullPVList.tp));
end
if(isempty(C4))
    Conditions(4,:)=1;
else
    Conditions(4,:)=double(strcmpi(C4,handles.FullPVList.qp));
end
Kept=find(prod(Conditions));
set(handles.epv_FullList,'String',{handles.FullPVList.root_name{Kept}});

% --- Executes on button press in ShowOneAcquiredProfile.
function ShowOneAcquiredProfile_Callback(hObject, eventdata, handles)
% hObject    handle to ShowOneAcquiredProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowOneAcquiredProfile



function PvToListen_Callback(hObject, eventdata, handles)
% hObject    handle to PvToListen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PvToListen as text
%        str2double(get(hObject,'String')) returns contents of PvToListen as a double


% --- Executes during object creation, after setting all properties.
function PvToListen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PvToListen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PulseID_delay_Callback(hObject, eventdata, handles)
% hObject    handle to PulseID_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PulseID_delay as text
%        str2double(get(hObject,'String')) returns contents of PulseID_delay as a double


% --- Executes during object creation, after setting all properties.
function PulseID_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PulseID_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dbcycle_Callback(hObject, eventdata, handles)
% hObject    handle to dbcycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dbcycle as text
%        str2double(get(hObject,'String')) returns contents of dbcycle as a double


% --- Executes during object creation, after setting all properties.
function dbcycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dbcycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Update_Figures_Cont.
function Update_Figures_Cont_Callback(hObject, eventdata, handles)
CurrentValue=get(handles.Update_Figures_Cont,'UserData');
if(CurrentValue)
    set(handles.Update_Figures_Cont,'UserData',0)
    set(handles.Update_Figures_Cont,'string','Update Figures Cycle');
    set(handles.Update_Figures_Cont,'BackgroundColor',handles.ColorIdle);
    set(handles.Stop3,'BackgroundColor',handles.ColorIdle);
    set(handles.Stop3,'enable','off');
    set(handles.Start3,'Enable','on');
    set(handles.Start3,'BackgroundColor',handles.ColorON);
    set(handles.Update_Figures_Cont,'enable','on');
    set(handles.AppenOneBlockMore,'enable','on');
    set(handles.CominciaModalitaSchiavo,'enable','on');
    set(handles.NaClO,'enable','on');
	return
else
    set(handles.Update_Figures_Cont,'UserData',1)
    set(handles.Update_Figures_Cont,'string','Updating figures.. press again to stop');
    set(handles.Update_Figures_Cont,'BackgroundColor',handles.ColorON);
    set(handles.Start3,'Enable','off')
    set(handles.Start3,'BackgroundColor',handles.ColorIdle);
    set(handles.CominciaModalitaSchiavo,'enable','off');
    set(handles.NaClO,'enable','on');
    while(1)
        pause(0.5)
        CurrentValue=get(handles.Update_Figures_Cont,'UserData');
        if(~CurrentValue)
            break
        end
        %disp('updating figures')
        Buffer=get(handles.dia_text_rec,'Userdata');
%         Buffer
        if(isempty(Buffer.PV) && isempty(Buffer.Prof))
            %disp('nothing in buffer, continuing')
            continue
        end
        Init_Vars=get(handles.IlTestoNumero50,'Userdata');
        delete_or_update_figures(handles);
        UD=get(handles.CVCRCIISSA,'UserData');
        FiguresList=UD{4};
        ChildrenSorting=UD{5};
%         save TEMP
        %ReadProfile=Init_Vars.ReadProfile; BothProfiles=Init_Vars.BothProfiles; Image2D=Init_Vars.Image2D; PvNumber=Init_Vars.PvNumber; blocksize=Init_Vars.blocksize; keepsize=Init_Vars.keepsize;
        %ROIx=Init_Vars.ROIx; ROIy=Init_Vars.ROIy; profile=Init_Vars.profile; Pvlist=Init_Vars.Pvlist; ProjectionDirection=Init_Vars.ProjectionDirection; CameraSize=Init_Vars.CameraSize;
        %BasicProcessing=Init_Vars.BasicProcessing; FilterON=Init_Vars.FilterON; SignalON=Init_Vars.SignalON;
        ResortingX=Init_Vars.ResortingX; ResortingY=Init_Vars.ResortingY;FilterResorting=Init_Vars.FilterResorting;
    
%        ValidDataArray_PV=[EvaluatedProfileQuantities; real(ValidTimeStamps)+imag(ValidTimeStamps)/10^9 ;double(ValidPulseIDs); zeros(sum(SignalON),length(ValidPulseIDs)) ;  ValidDataArray_PV];
        [SA,SB]=size(Buffer.PV); LastValidData=SB;  FILLING=1;
        if(SA>2)
            KEEP_PV=[Buffer.ProfQuant;Buffer.ProfQuant2;Buffer.PV(1:2,:);Buffer.SignalEvaluated;Buffer.PV(3:end,:)];
        else
            KEEP_PV=[Buffer.ProfQuant;Buffer.ProfQuant2;Buffer.PV(1:2,:);Buffer.SignalEvaluated;];
        end
%         [SC,SD]=size(KEEP_PV);
         [SE,SF]=size(ResortingY);
        for II=1:Init_Vars.PvNotSyncNumber
           ResortingY(end+1,1)=2;
           ResortingY(end,2)=SE-1+II;
           ResortingX(end+1,1)=2;
           ResortingX(end,2)=SE-1+II; 
        end
    if(~isempty(FiguresList))
        ScreenToBeUpdated=1;LastScreen=numel(FiguresList);
        %[ScreenToBeUpdated:LastScreen]
        for ScreenID=ScreenToBeUpdated:LastScreen
            try
                Petizione=get(ChildrenSorting(ScreenID,23),'userdata');
                FigureStillOpen=1;
            catch ME
                FigureStillOpen=0;    
            end
            %FiguresList
            %Petizione
            %[ScreenID, FigureStillOpen]
            if(FigureStillOpen)
                cla(ChildrenSorting(ScreenID,1),'reset');
                hold(ChildrenSorting(ScreenID,1),'on');
                
                if(Petizione.SpecializedDisplay)
                %save TEMPX
                handles.FunctionAnalysisListHandles{Petizione.SpecializedDisplay}(Buffer.PV,Buffer.Prof,Buffer.Prof2,Init_Vars.SingleValuePvs(1:handles.NumberOfOnTheFlyVariables),[], LastValidData, [], ChildrenSorting(ScreenID,:), UD{1}, Init_Vars.PvNotSync , [], Petizione)
                else
                
%                 save TEMP
                switch(ResortingX(Petizione.X_SEL,1))
                    case 0 %SEL_X is off
                            if(ResortingY(Petizione.Y_SEL1,1))
                                if(Petizione.Filt1)
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                else
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                                end
                                plot(ChildrenSorting(ScreenID,1),DataY1,'.k')
                            end
                            if(ResortingY(Petizione.Y_SEL2,1)) %something is selected on first
                                if(Petizione.Filt2)
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                else
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                                end
                                plot(ChildrenSorting(ScreenID,1),DataY2,'.r')
                            end
                            if(ResortingY(Petizione.Y_SEL3,1)) %something is selected on first
                                if(Petizione.Filt3)
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                else
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),1:LastValidData); 
                                end
                                plot(ChildrenSorting(ScreenID,1),DataY3,'.b')
                            end
                            if(Petizione.MostraMedie)
                                Legenda={};
                                if(ResortingY(Petizione.Y_SEL1,1))
                                    Legenda{end+1}=['mean= ',num2str(mean(DataY1)),'std= ',num2str(std(DataY1))];
                                end
                                if(ResortingY(Petizione.Y_SEL2,1))
                                    Legenda{end+1}=['mean= ',num2str(mean(DataY1)),'std= ',num2str(std(DataY2))];
                                end
                                if(ResortingY(Petizione.Y_SEL3,1))
                                    Legenda{end+1}=['mean= ',num2str(mean(DataY1)),'std= ',num2str(std(DataY3))];
                                end
                                legend(Legenda);
                            end
                            if(~Petizione.b_autoX)
                                CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                xlim(ChildrenSorting(ScreenID,1),CurrLim);
                            end
                            if(~Petizione.b_autoY)
                                CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                ylim(ChildrenSorting(ScreenID,1),CurrLim);
                            end
                    case 1 %SEL_X is a profile
                        %disp('SEL_X is a profile')
                        if((~ResortingY(Petizione.Y_SEL1,1)) && (~(ResortingY(Petizione.Y_SEL2,1)))) %No funny partitions, go ahead and plot the profile
                                  if(Petizione.Filt1)
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=Buffer.Prof(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                      else
                                          DATAY1=Buffer.Prof2(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                      end
                                  else
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=Buffer.Prof(:,1:LastValidData);
                                      else
                                          DATAY1=Buffer.Prof2(:,1:LastValidData);
                                      end
                                  end
                                  [s_temp1,s_temp2]=size(DATAY1);
                                  if(~isnan(Petizione.Calibration))
                                      if(length(Petizione.Calibration)==2)
                                          Xaxis=Petizione.Calibration(1)*(1:s_temp1);
                                          Xaxis=Xaxis-mean(Xaxis)+Calibration(2);
                                      else
                                          Xaxis=Petizione.Calibration(1)*(1:s_temp1);
                                          Xaxis=Xaxis-mean(Xaxis);
                                      end
                                  else
                                      Xaxis=1:s_temp1;
                                  end
                                  if(s_temp2)
                                      if(Petizione.ShowAverage)
                                          plot(ChildrenSorting(ScreenID,1),Xaxis,mean(DATAY1,2),'k','LineWidth',1)
                                      end
                                      if(Petizione.ShowOne)
                                          plot(ChildrenSorting(ScreenID,1),Xaxis,DATAY1(:,mod(round(rand(1)*10^7),s_temp2)+1),'k','LineWidth',2)
                                      end
                                  end
                                  
                                  if(Petizione.Filt2)
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=Buffer.Prof(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                      else
                                          DATAY1=Buffer.Prof2(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                      end
                                      [s_temp1,s_temp2]=size(DATAY1);
                                      if(s_temp2)
                                          if(Petizione.ShowAverage)
                                            plot(ChildrenSorting(ScreenID,1),Xaxis,mean(DATAY1,2),'r','LineWidth',1)
                                          end
                                          if(Petizione.ShowOne)
                                              plot(ChildrenSorting(ScreenID,1),Xaxis,DATAY1(:,mod(round(rand(1)*10^7),s_temp2)+1),'r','LineWidth',2)
                                          end
                                      end
                                  end
                                  
                                  if(Petizione.Filt3)
                                      if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAY1=Buffer.Prof(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                      else
                                          DATAY1=Buffer.Prof2(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                      end
                                      [s_temp1,s_temp2]=size(DATAY1);
                                      if(s_temp2)
                                          if(Petizione.ShowAverage)
                                            plot(ChildrenSorting(ScreenID,1),Xaxis,mean(DATAY1,2),'b','LineWidth',1)
                                          end
                                          if(Petizione.ShowOne)
                                              plot(ChildrenSorting(ScreenID,1),Xaxis,DATAY1(:,mod(round(rand(1)*10^7),s_temp2)+1),'b','LineWidth',2)
                                          end
                                      end
                                  end
                                  
                                  
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                        end
                        if(ResortingY(Petizione.Y_SEL1,1)) %A-Plot
                            if(Petizione.Filt1)
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=Buffer.Prof(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                      else
                                          DATAX1=Buffer.Prof2(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                            else
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=Buffer.Prof(:,1:LastValidData);
                                      else
                                          DATAX1=Buffer.Prof2(:,1:LastValidData);
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                            end
                            
                            if(Petizione.b_autoY)
                                MapYMin=min(DataY1);
                                MapYMax=max(DataY1);
                            else
                                MapYMin=Petizione.lim_y1;
                                MapYMax=Petizione.lim_y2;
                            end
                            [temp_size1,temp_size2]=size(DATAX1);
                            if(~isnan(Petizione.Calibration))
                                      if(length(Petizione.Calibration)==2)
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis)+Petizione.Calibration(2);
                                      else
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis);
                                      end
                            else
                                      XAxis=1:temp_size1;
                            end
%                             save TEMP
                            BinTheyFitInto=round((DataY1-MapYMin)/(MapYMax-MapYMin)*Petizione.binsy)+1;
                            MatrixToPlot=zeros(temp_size1,Petizione.binsy);
                            for BinsID=1:Petizione.binsy
                                if(any(BinTheyFitInto==BinsID))
                                    MatrixToPlot(:,BinsID)=mean(DATAX1(:,find(BinTheyFitInto==BinsID)),2);
                                end
                            end
                            imagesc(XAxis,linspace(MapYMin,MapYMax,Petizione.binsy),transpose(MatrixToPlot),'parent',ChildrenSorting(ScreenID,1));
                            xlim(ChildrenSorting(ScreenID,1),[min(XAxis),max(XAxis)]);
                            ylim(ChildrenSorting(ScreenID,1),[MapYMin,MapYMax]);
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                        end
                        if(~ResortingY(Petizione.Y_SEL1,1) && (ResortingY(Petizione.Y_SEL2,1))) %PartitionPlot
                            if(Petizione.Filt2)
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=Buffer.Prof(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                      else
                                          DATAX1=Buffer.Prof2(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                            else
                                if(ResortingX(Petizione.X_SEL,2)==1)
                                          DATAX1=Buffer.Prof(:,1:LastValidData);
                                      else
                                          DATAX1=Buffer.Prof2(:,1:LastValidData);
                                end
                                DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                            end
                            if(Petizione.b_autoY)
                                MapYMin=min(DataY1);
                                MapYMax=max(DataY1);
                            else
                                MapYMin=Petizione.lim_y1
                                MapYMax=Petizione.lim_y2
                            end
                            [temp_size1,temp_size2]=size(DATAX1);
                            if(~isnan(Petizione.Calibration))
                                      if(length(Petizione.Calibration)==2)
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis)+Petizione.Calibration(2);
                                      else
                                          XAxis=Petizione.Calibration(1)*(1:temp_size1);
                                          XAxis=XAxis-mean(XAxis);
                                      end
                            else
                                      XAxis=1:temp_size1;
                            end
                            BinTheyFitInto=round((DataY1-MapYMin)/(MapYMax-MapYMin)*Petizione.binsy)+1;
                            MatrixToPlot=zeros(temp_size1,Petizione.binsy);
                            for BinsID=1:Petizione.binsy
                                if(any(BinTheyFitInto==BinsID))
                                    MatrixToPlot(:,BinsID)=mean(DATAX1(:,find(BinTheyFitInto==BinsID)),2);
                                end
                            end
                             
                            PointersOfThisPlot=plot(ChildrenSorting(ScreenID,1),XAxis,MatrixToPlot);
                            if(length(PointersOfThisPlot)<=10)
                                if(exist('Legend','var')), clear Legend, end
                                Partitions=linspace(MapYMin,MapYMax,10);
                                for II=1:length(PointersOfThisPlot)
                                   Legend{II}=num2str(Partitions(II));
                                end
                                legend(ChildrenSorting(ScreenID,1),Legend);
                            end
                            xlim(ChildrenSorting(ScreenID,1),[min(XAxis),max(XAxis)]);
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                        end
                    case 2 %SEL_X is a shot to shot value
                         
                        DATAX1TEMP=KEEP_PV(ResortingX(Petizione.X_SEL,2),1:LastValidData);
                        if(~ResortingY(Petizione.Y_SEL1,1) && ~ResortingY(Petizione.Y_SEL2,1) && ~ResortingY(Petizione.Y_SEL3,1)) %Resort the buffer and plot
                                if(~FILLING)
                                   DataX1=DATAX1TEMP([ValidDataPointer:keepsize,1:(ValidDataPointer-1)]); 
                                else
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,'.k');
                        else    
                            if(ResortingY(Petizione.Y_SEL1,1)) %something is selected on first
                                if(Petizione.Filt1)
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                   DataX1=DATAX1TEMP(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                else
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,DataY1,'.k');
                            end
                            if(ResortingY(Petizione.Y_SEL2,1)) %something is selected on first
                                if(Petizione.Filt2)
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                   DataX1=DATAX1TEMP(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                else
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,DataY2,'.r');
                            end
                            if(ResortingY(Petizione.Y_SEL3,1)) %something is selected on first
                                if(Petizione.Filt3)
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                   DataX1=DATAX1TEMP(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                else
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),1:LastValidData); 
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,DataY3,'.b');
                            end
                        end
                                    if(~Petizione.b_autoX)
                                        CurrLim=xlim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                                        if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                                        xlim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                                    if(~Petizione.b_autoY)
                                        CurrLim=ylim(ChildrenSorting(ScreenID,1));
                                        if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                                        if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                                        ylim(ChildrenSorting(ScreenID,1),CurrLim);
                                    end
                    case 3 %SEL_X is timestamp
                        DATAX1TEMP=KEEP_PV(ResortingX(Petizione.X_SEL,2),1:LastValidData);
                        DATAX1TEMP=DATAX1TEMP-min(DATAX1TEMP);
                        if(~ResortingY(Petizione.Y_SEL1,1) && ~ResortingY(Petizione.Y_SEL2,1) && ~ResortingY(Petizione.Y_SEL3,1)) %Resort the buffer and plot
                                if(~FILLING)
                                   DataX1=DATAX1TEMP([ValidDataPointer:keepsize,1:(ValidDataPointer-1)]); 
                                else
                                   DataX1=DATAX1TEMP;
                                end
                                plot(ChildrenSorting(ScreenID,1),DataX1,'.k');
                        else    
                            if(Petizione.TrasformaFourier)                                    
                                    FrequencyVectorDefined=0;
                            end
                            if(ResortingY(Petizione.Y_SEL1,1)) %something is selected on first
                                if(Petizione.Filt1)
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt1)});
                                   DataX1=DATAX1TEMP(:,handles.Buffer.FilterEvaluated{FilterResorting(Filt1)});
                                else
                                   DataY1=KEEP_PV(ResortingY(Petizione.Y_SEL1,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                if(Petizione.TrasformaFourier)                                    
                                    FrequencyEstimate=round(1/min(diff(DataX1))); % da lavorare
                                    if(FrequencyEstimate>120), FrequencyEstimate=120;, end
                                    FrequencyVector=linspace(0,round(FrequencyEstimate/2),Petizione.binsx);
                                    FrequencyVectorDefined=1;
                                    [SortTime,TimeOrder]=sort(DataX1);
                                    DataY1=abs(exp(1i*2*pi*FrequencyVector.'*SortTime )*transpose((DataY1(TimeOrder)-mean(DataY1))))/length(SortTime);
                                    plot(ChildrenSorting(ScreenID,1),FrequencyVector,DataY1,'.k');
                                else
                                    plot(ChildrenSorting(ScreenID,1),DataX1,DataY1,'.k');
                                end
                            end
                            if(ResortingY(Petizione.Y_SEL2,1)) %something is selected on first
                                if(Petizione.Filt2)
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                   DataX1=DATAX1TEMP(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt2)});
                                else
                                   DataY2=KEEP_PV(ResortingY(Petizione.Y_SEL2,2),1:LastValidData);
                                   DataX1=DATAX1TEMP;
                                end
                                if(Petizione.TrasformaFourier)
                                    if(~FrequencyVectorDefined), FrequencyVector=linspace(0,round(FrequencyEstimate/2),Petizione.binsx);, FrequencyVectorDefined=1;, end
                                    [SortTime,TimeOrder]=sort(DataX1);
                                    DataY2=abs(exp(1i*2*pi*FrequencyVector.'*SortTime )*transpose((DataY2(TimeOrder)-mean(DataY2))))/length(SortTime);
                                    plot(ChildrenSorting(ScreenID,1),FrequencyVector,DataY2,'.r');
                                else
                                    plot(ChildrenSorting(ScreenID,1),DataX1,DataY2,'.r');
                                end
                            end
                            if(ResortingY(Petizione.Y_SEL3,1)) %something is selected on first
                                if(Petizione.Filt3)
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                   DataX1=DATAX1TEMP(:,handles.Buffer.FilterEvaluated{FilterResorting(Petizione.Filt3)});
                                else
                                   DataY3=KEEP_PV(ResortingY(Petizione.Y_SEL3,2),1:LastValidData); 
                                   DataX1=DATAX1TEMP;
                                end
                                if(Petizione.TrasformaFourier)
                                    if(~FrequencyVectorDefined), FrequencyVector=linspace(0,round(FrequencyEstimate/2),Petizione.binsx);, FrequencyVectorDefined=1;, end
                                    [SortTime,TimeOrder]=sort(DataX1);
                                    DataY3=abs(exp(1i*2*pi*FrequencyVector.'*SortTime )*transpose((DataY3(TimeOrder)-mean(DataY3))))/length(SortTime);
                                    plot(ChildrenSorting(ScreenID,1),FrequencyVector,DataY3,'.b');
                                else
                                    plot(ChildrenSorting(ScreenID,1),DataX1,DataY3,'.b');
                                end
                            end  
                        end
                        if(~Petizione.b_autoX)
                            CurrLim=xlim(ChildrenSorting(ScreenID,1));
                            if(~isnan(Petizione.lim_x1)), CurrLim(1)=Petizione.lim_x1;, end
                            if(~isnan(Petizione.lim_x2)), CurrLim(2)=Petizione.lim_x2;, end
                            xlim(ChildrenSorting(ScreenID,1),CurrLim);
                        end
                        if(~Petizione.b_autoY)
                            CurrLim=ylim(ChildrenSorting(ScreenID,1));
                            if(~isnan(Petizione.lim_y1)), CurrLim(1)=Petizione.lim_y1;, end
                            if(~isnan(Petizione.lim_y2)), CurrLim(2)=Petizione.lim_y2;, end
                            ylim(ChildrenSorting(ScreenID,1),CurrLim);
                        end
                    
                end
            
                end    
            
                
            if(Petizione.LogBookAndSave || Petizione.LogBookOnlyFigure)
                CurrentTime=clock;
                CurrentYearString=num2str(CurrentTime(1),'%.4d');
                CurrentMonthString=num2str(CurrentTime(2),'%.2d');
                CurrentDieiString=num2str(CurrentTime(3),'%.2d');
                CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
                CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
                CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
                CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
                CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String]; 
                for II=1:Petizione.LogBookAndSave
                    NewFigure=figure; 			% Create a new figure
                    %NewAxes=axes;		% Create an axes object in the figure
                    Newhandle = copyobj(ChildrenSorting(ScreenID,1),NewFigure);
                    title(CurrentTimeString);
                    Petizione.LogBookAndSave=0;
                    set(ChildrenSorting(ScreenID,23),'userdata',Petizione);
                    eval(['save MonitorGui-',CurrentTimeString,' Buffer']);
                end
                for II=1:Petizione.LogBookOnlyFigure
                    NewFigure=figure; 			% Create a new figure
                    %NewAxes=axes;		% Create an axes object in the figure
                    Newhandle = copyobj(ChildrenSorting(ScreenID,1),NewFigure);
                    title(CurrentTimeString);
                    Petizione.LogBookOnlyFigure=0;
                    set(ChildrenSorting(ScreenID,23),'userdata',Petizione);
                end
            end      
            else %Delete it from list
                if ((ScreenID==1) && (numel(FiguresList)==1) )
                    FiguresList=[];
                    ChildrenSorting=[];
                elseif((ScreenID==numel(FiguresList)))
                    FiguresList=FiguresList(1:(end-1));
                    ChildrenSorting=ChildrenSorting(1:(end-1),:);
                elseif(ScreenID==1)
                    FiguresList=FiguresList(2:end);
                    ChildrenSorting=ChildrenSorting(2:end,:);
                else
                    FiguresList=[FiguresList(1:(ScreenID-1)),FiguresList((ScreenID+1):end)];
                    ChildrenSorting=[ChildrenSorting(1:(ScreenID-1),:);ChildrenSorting((ScreenID+1),:)];
                end
                UD{4}=FiguresList;
                UD{5}=ChildrenSorting;
                set(handles.CVCRCIISSA,'UserData',UD);
                update_figure_list(handles);
            end
        end
    end
        
        
        
    end
end


% --- Executes on selection change in epv_FullList.
function epv_FullList_Callback(hObject, eventdata, handles)
% hObject    handle to epv_FullList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epv_FullList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epv_FullList


% --- Executes during object creation, after setting all properties.
function epv_FullList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_FullList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in epv_AddList.
function epv_AddList_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistSync,'string');
new_list=get(handles.epv_FullList,'string');
[ismem,memloc]=ismember(new_list,current_list);
size(current_list)
size({new_list{~ismem}})
current_list=[current_list;transpose({new_list{~ismem}})];
set(handles.epv_MylistSync,'string',current_list);

% --- Executes on button press in epv_AddOne.
function epv_AddOne_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistSync,'string');
new_list=get(handles.epv_FullList,'string');
new_val=get(handles.epv_FullList,'value');
new_list=new_list{new_val};
tba{1}=new_list;
[ismem,memloc]=ismember(tba,current_list);
current_list=[current_list;transpose({tba{~ismem}})];
set(handles.epv_MylistSync,'string',current_list);

function epv_editsynch_Callback(hObject, eventdata, handles)
% hObject    handle to epv_editsynch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epv_editsynch as text
%        str2double(get(hObject,'String')) returns contents of epv_editsynch as a double


% --- Executes during object creation, after setting all properties.
function epv_editsynch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_editsynch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in epv_AddSingle.
function epv_AddSingle_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistSync,'string');
new_list=get(handles.epv_editsynch,'string');
if(~isempty(new_list))
    tba{1}=new_list;
    [ismem,memloc]=ismember(tba,current_list);
    current_list=[current_list;transpose({tba{~ismem}})];
    set(handles.epv_MylistSync,'string',current_list);
end

% --- Executes on button press in epv_RemList.
function epv_RemList_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistSync,'string');
new_list=get(handles.epv_FullList,'string');
if(~iscell(new_list))
    tbr{1}=new_list;
else
    tbr=new_list;
end
[ismem,memloc]=ismember(current_list,tbr);
if(~isempty(find(~ismem)))
    current_list={current_list{find(~ismem)}};
    set(handles.epv_MylistSync,'value',1);
else
    current_list={};
    set(handles.epv_MylistSync,'value',1);
end
set(handles.epv_MylistSync,'string',current_list);

% --- Executes on button press in epv_RemOne.
function epv_RemOne_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistSync,'string');
new_list=get(handles.epv_FullList,'string');
current_val=get(handles.epv_FullList,'value');
tbr{1}=new_list{current_val};
[ismem,memloc]=ismember(current_list,tbr);
current_list={current_list{~ismem}};
if(current_val>numel(current_list))
    set(handles.epv_MylistSync,'value',1)
end
if(isempty(current_list))
    set(handles.epv_MylistSync,'string',current_list);
    set(handles.epv_MylistSync,'value',1)
else
    set(handles.epv_MylistSync,'string',current_list);
end


% --- Executes on button press in epv_RemSingle.
function epv_RemSingle_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistSync,'string');
current_val=get(handles.epv_MylistSync,'value');
tbr{1}=current_list{current_val};
[ismem,memloc]=ismember(current_list,tbr);
current_list={current_list{~ismem}};
if(current_val>numel(current_list))
    set(handles.epv_MylistSync,'value',1)
end
if(isempty(current_list))
    set(handles.epv_MylistSync,'string',current_list);
    set(handles.epv_MylistSync,'value',1)
else
    set(handles.epv_MylistSync,'string',current_list);
end




function epv_1_Callback(hObject, eventdata, handles)
set(handles.epv_MylistSync,'value',1);set(handles.epv_FullList,'value',1);
update_pv_tobeadded_list(handles)
% --- Executes during object creation, after setting all properties.
function epv_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epv_2_Callback(hObject, eventdata, handles)
set(handles.epv_MylistSync,'value',1);set(handles.epv_FullList,'value',1);
update_pv_tobeadded_list(handles)

% --- Executes during object creation, after setting all properties.
function epv_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epv_3_Callback(hObject, eventdata, handles)
set(handles.epv_MylistSync,'value',1);set(handles.epv_FullList,'value',1);
update_pv_tobeadded_list(handles)

% --- Executes during object creation, after setting all properties.
function epv_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epv_4_Callback(hObject, eventdata, handles)
set(handles.epv_MylistSync,'value',1);set(handles.epv_FullList,'value',1);
update_pv_tobeadded_list(handles)

% --- Executes during object creation, after setting all properties.
function epv_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in epv_MylistSync.
function epv_MylistSync_Callback(hObject, eventdata, handles)
% hObject    handle to epv_MylistSync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epv_MylistSync contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epv_MylistSync


% --- Executes during object creation, after setting all properties.
function epv_MylistSync_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_MylistSync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in epv_MylistNotSync.
function epv_MylistNotSync_Callback(hObject, eventdata, handles)
% hObject    handle to epv_MylistNotSync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epv_MylistNotSync contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epv_MylistNotSync


% --- Executes during object creation, after setting all properties.
function epv_MylistNotSync_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_MylistNotSync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epv_editnotsynch_Callback(hObject, eventdata, handles)
% hObject    handle to epv_editnotsynch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epv_editnotsynch as text
%        str2double(get(hObject,'String')) returns contents of epv_editnotsynch as a double


% --- Executes during object creation, after setting all properties.
function epv_editnotsynch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epv_editnotsynch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in epv_AddSingleUN.
function epv_AddSingleUN_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistNotSync,'string');
new_list=get(handles.epv_editnotsynch,'string');
if(~isempty(new_list))
    tba{1}=new_list;
    [ismem,memloc]=ismember(tba,current_list);
    current_list=[current_list;transpose({tba{~ismem}})];
    set(handles.epv_MylistNotSync,'string',current_list);
end


% --- Executes on button press in epv_RemoveSingleUN.
function epv_RemoveSingleUN_Callback(hObject, eventdata, handles)
current_list=get(handles.epv_MylistNotSync,'string');
current_val=get(handles.epv_MylistNotSync,'value');
tbr{1}=current_list{current_val};
[ismem,memloc]=ismember(current_list,tbr);
current_list={current_list{~ismem}};
if(current_val>numel(current_list))
    set(handles.epv_MylistNotSync,'value',1)
end
if(isempty(current_list))
    set(handles.epv_MylistNotSync,'string',current_list);
    set(handles.epv_MylistNotSync,'value',1)
else
    set(handles.epv_MylistNotSync,'string',current_list);
end

% --- Executes on button press in EnableMultiScreen.
function EnableMultiScreen_Callback(hObject, eventdata, handles)
% hObject    handle to EnableMultiScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in epv_ClosePanel.
function epv_ClosePanel_Callback(hObject, eventdata, handles)
current_list1=get(handles.epv_MylistSync,'string');
current_list2=get(handles.epv_MylistNotSync,'string');
set(handles.PvSyncList,'string',current_list1);
set(handles.PvNotSyncList,'string',current_list2);
set(handles.uipanel1,'visible','on');
set(handles.CodeVariablesPanel,'visible','off');
set(handles.PvlistPanel,'visible','off');


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, handles)
% load LastSavedBackground BackgroundSaved
% handles.BackgroundBlock=BackgroundSaved;
% guidata(hObject, handles);



function NomeDellaVariabile_Callback(hObject, eventdata, handles)
% hObject    handle to NomeDellaVariabile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NomeDellaVariabile as text
%        str2double(get(hObject,'String')) returns contents of NomeDellaVariabile as a double


% --- Executes during object creation, after setting all properties.
function NomeDellaVariabile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NomeDellaVariabile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CV_PlusOne.
function CV_PlusOne_Callback(hObject, eventdata, handles)
% load ProjBackground
% handles.BackgroundBlock=MYB.';
% guidata(hObject, handles);


    function grabExtPlot(hObject, handles)
        Stop3_Callback(hObject, [], handles)
        handles.extGui = 1;
        guidata(hObject, handles);
        Start3_Callback(hObject, [], handles)
        
        
        function handles =  sendImage(hObject, handles)
            [ho1, h1]=util_appFind('SXRSS_gui');
            SXRSS_gui('cpyImg', ho1, h1);
            handles=guidata(handles.output);