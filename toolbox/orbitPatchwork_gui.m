function varargout = orbitPatchwork_gui(varargin)
% ORBITPATCHWORK_GUI MATLAB code for orbitPatchwork_gui.fig
%      ORBITPATCHWORK_GUI, by itself, creates a new ORBITPATCHWORK_GUI or raises the existing
%      singleton*.
%
%      H = ORBITPATCHWORK_GUI returns the handle to a new ORBITPATCHWORK_GUI or the handle to
%      the existing singleton*.
%
%      ORBITPATCHWORK_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORBITPATCHWORK_GUI.M with the given input arguments.
%
%      ORBITPATCHWORK_GUI('Property','Value',...) creates a new ORBITPATCHWORK_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before orbitPatchwork_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to orbitPatchwork_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help orbitPatchwork_gui

% Last Modified by GUIDE v2.5 10-Jun-2021 01:03:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @orbitPatchwork_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @orbitPatchwork_gui_OutputFcn, ...
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


% --- Executes just before orbitPatchwork_gui is made visible.
function orbitPatchwork_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to orbitPatchwork_gui (see VARARGIN)

% Choose default command line output for orbitPatchwork_gui
handles.output = hObject;

%Old InitScript
use_sort_Z=1;
handles.NumberOfPresets=8;
clear staticS
clear staticH
clear static
offlinemode=0;
VAL=1;
if(offlinemode)
    
else
    staticS=bba2_init('sector',{'LTUS','UNDS','DMPS'},'devList',{'BEND' 'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'PHAS' 'XEFC' 'YEFC'},'beampath','CU_SXR','sortZ',use_sort_Z);
    staticH=bba2_init('sector',{'LTUH','UNDH','DMPH'},'devList',{'BEND' 'BPMS' 'QUAD' 'XCOR' 'YCOR' 'USEG' 'PHAS' 'XEFC' 'YEFC'},'beampath','CU_HXR','sortZ',use_sort_Z);
end

Lines={'Hard Line - H','Soft Line - S'};
static(1)=staticH; static(2)=staticS;

for SS=1:handles.NumberOfPresets
    if(SS<=length(Lines))
        set(handles.(['A',num2str(SS)]),'visible','on');
        set(handles.(['A',num2str(SS)]),'string',Lines{SS});
    else
        set(handles.(['A',num2str(SS)]),'visible','off');
    end
end

for HH=1:length(static)
    BPMNAMES=static(HH).bpmList_e;
    CORRNAMES=static(HH).corrList_e;
    
    READBUFFER={};
    BPMX=strcat(BPMNAMES,':X'); BPMY=strcat(BPMNAMES,':Y'); BPMT=strcat(BPMNAMES,':TMIT');
    
    for II=1:length(BPMX)
        READBUFFER{end+1}=[BPMX{II},'HSTBR'];
    end
    for II=1:length(BPMY)
        READBUFFER{end+1}=[BPMY{II},'HSTBR'];
    end
    for II=1:length(BPMT)
        READBUFFER{end+1}=[BPMT{II},'HSTBR'];
    end
    READBUFFER{end+1}='PATT:SYS0:1:PULSEIDHSTBR';
    READBUFFER{end+1}='PATT:SYS0:1:SECHSTBR';
    READBUFFER{end+1}='PATT:SYS0:1:NSECHSTBR';
    
    BPM.LIST=static(HH).bpmList;
    BPM.FullNames=BPMNAMES;
    BPM.z=static(HH).zBPM.';
    BPM.Fullnamex=strcat(BPM.FullNames,':X');
    BPM.Fullnamey=strcat(BPM.FullNames,':Y');
    BPM.LTU=[];BPM.UND=[];BPM.DMP=[];
    
    for II=1:numel(BPM.FullNames)
        if(strfind(BPM.FullNames{II},'LTU'))
            BPM.LTU(end+1)=II;
        elseif(strfind(BPM.FullNames{II},'UND'))
            BPM.UND(end+1)=II;
        elseif(strfind(BPM.FullNames{II},'DMP'))
            BPM.DMP(end+1)=II;
        end
    end
    
    XCOR.LIST={};YCOR.LIST={};XCOR.Fullname={};YCOR.Fullname={};XCOR.z=[];YCOR.z=[];
    XCOR.LTU=[]; XCOR.UND=[]; XCOR.DMP=[];
    YCOR.LTU=[]; YCOR.UND=[]; YCOR.DMP=[];
    
    for II=1:numel(static(HH).corrList)
       if(static(HH).corrList{II}(1)=='X')
           XCOR.LIST{end+1}=static(HH).corrList{II};
           XCOR.Fullname{end+1}=CORRNAMES{II};
           XCOR.z(end+1)=static(HH).zCorr(II);
           if(strfind(CORRNAMES{II},'LTU'))
                XCOR.LTU(end+1)=length(XCOR.LIST);
           elseif(strfind(CORRNAMES{II},'UND'))
                XCOR.UND(end+1)=length(XCOR.LIST);
           elseif(strfind(CORRNAMES{II},'DMP'))
                XCOR.DMP(end+1)=length(XCOR.LIST);
           end 
       else
           YCOR.LIST{end+1}=static(HH).corrList{II};
           YCOR.Fullname{end+1}=CORRNAMES{II};
           YCOR.z(end+1)=static(HH).zCorr(II);
           if(strfind(CORRNAMES{II},'LTU'))
                YCOR.LTU(end+1)=length(YCOR.LIST);
           elseif(strfind(CORRNAMES{II},'UND'))
                YCOR.UND(end+1)=length(YCOR.LIST);
           elseif(strfind(CORRNAMES{II},'DMP'))
                YCOR.DMP(end+1)=length(YCOR.LIST);
           end 
       end
    end
    
    static(HH).BPM=BPM;
    static(HH).XCOR=XCOR;
    static(HH).YCOR=YCOR;
    static(HH).READBUFFER=READBUFFER;
end

%End of Old InitScript

handles.static=static;
handles.SaveDir='/u1/lcls/matlab/orbitPatchwork_saves';
handles.SaveDir_UL='/u1/lcls/matlab/ULT_GuiData';
AVCONF=10;
handles.ColumnEditable=true(1,AVCONF+2); handles.ColumnEditable(1)=false;

handles.TimingBPM_CuLinac='BPMS:IN20:511:X';
handles.TimingBPM_ScLinac='NO:STA:TAZAR:0000';
set(handles.TIMING,'string',handles.TimingBPM_CuLinac);

handles.ColorIdle=get(handles.GUIDUMP,'backgroundcolor');
handles.ColorRed=[1,0,0];
handles.ColorGreen=[0,1,0];
handles.ColorYellow=[1,1,0];
handles.AVCONF=10;

try
    load([handles.SaveDir_UL,'/UL.mat'],'UL');
catch
    load([pwd,'/UL.mat'],'UL');
end
handles.ULall=UL;
handles.sf=Steering_Functions;


set(handles.AREA,'string',Lines)
handles=AREA_Callback(hObject,[], handles);

guidata(hObject, handles);
% UIWAIT makes orbitPatchwork_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = orbitPatchwork_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in SVD.
% L'ALGORITMO CHE FA LO STEERING E' QUESTO...
function SVD_Callback(hObject, eventdata, handles)
[~,options.startTime]=lcaGetSmart(handles.TimingBPM_CuLinac);
options.BSA_HB=get(handles.radiobutton3,'value');
set(handles.READBPM,'backgroundcolor',handles.ColorYellow);
drawnow
SteerX=get(handles.SteerX,'value');
SteerY=get(handles.SteerY,'value');
if(~options.BSA_HB)
    options.BSA=~(get(handles.WithOrWithout,'value')-1);
    if(~options.BSA)
        options.CAGET=1;
    end
    options.Samples=str2double(get(handles.SN,'string'));
else
    options.AcquisitionTime=str2double(get(handles.RO,'string'));
end

options.fitSVDRatio=str2num(get(handles.edit69,'string'));

SVDC=get(handles.SVDC,'value');
WRITE=get(handles.WRITE,'value');
XC=get(handles.XC,'data');YC=get(handles.YC,'data');XB=get(handles.XB,'data');YB=get(handles.YB,'data');
TrueXC=[XC{:,2}];TrueYC=[YC{:,2}];TrueXB=[XB{:,2}];TrueYB=[YB{:,2}];
target(:,1)=[XB{:,2+SVDC}];target(:,2)=[YB{:,2+SVDC}];
options.useBPMx=false(length(handles.s.bpmList),1);
options.useBPMy=false(length(handles.s.bpmList),1);
options.useCorr=false(length(handles.s.corrList),1);
options.useBPMx(handles.BPM.TableToStatic(TrueXB))=true;
options.useBPMy(handles.BPM.TableToStatic(TrueYB))=true;
options.useCorr(handles.XCOR.TableToStatic(TrueXC))=true;
options.useCorr(handles.YCOR.TableToStatic(TrueYC))=true;
options.tmitMin=(10^-12)*str2double(get(handles.edit68,'string'))/(1.60217662*10^-19);

if(get(handles.SMAC_OPN,'value'))
    MODEL_DATA=load('/u1/lcls/matlab/SMAC_Data/orbitPatchwork_ModelData/LatestFit');
    options.rMat=MODEL_DATA.MODEL_OP.rMat;
    options.energy=ones(1,size(MODEL_DATA.MODEL_OP.rMat,3))*MODEL_DATA.MODEL_OP.energy;
end

Solution=handles.sf.steer(handles.s, options, target);

if(get(handles.ARFIX,'value'))
    orbitPatchwork_fix(Solution, handles.s, options, target);
    return
end

if(WRITE)
    if(~Solution.FAILED)
        set(handles.Restore,'enable','on');
        set(handles.Restore,'userdata',Solution);
        if(SteerX && SteerY)
            lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr);
        elseif(SteerX)
            lcaPutSmart(strcat(Solution.X.UsedCorr_e,':BCTRL'),Solution.X.NewCorr);  
        elseif(SteerY)
            lcaPutSmart(strcat(Solution.Y.UsedCorr_e,':BCTRL'),Solution.Y.NewCorr);
        else
            disp('Neither X nor Y was selected for steering!')
        end
    else
       if((SteerX) && (~SteerY) && (~Solution.X.FAILED))
           lcaPutSmart(strcat(Solution.X.UsedCorr_e,':BCTRL'),Solution.X.NewCorr);
       elseif((~SteerX) && (SteerY) && (~Solution.Y.FAILED))
           lcaPutSmart(strcat(Solution.Y.UsedCorr_e,':BCTRL'),Solution.Y.NewCorr);
       else
           orbitPatchwork_fix(Solution, handles.s, options, target);
           disp('Solution failed, running orbitPatchwork_Fix');
       end
    end
end

set(handles.READBPM,'backgroundcolor',handles.ColorIdle);


% --- Executes on button press in READBPM.
function READBPM_Callback(hObject, eventdata, handles)
[~,options.startTime]=lcaGetSmart(handles.TimingBPM_CuLinac);tic
options.BSA_HB=get(handles.radiobutton3,'value');
options.tmitMin=(10^-12)*str2double(get(handles.edit68,'string'))/(1.60217662*10^-19);
set(handles.READBPM,'backgroundcolor',handles.ColorYellow);
drawnow
if(~options.BSA_HB)
    options.BSA=~(get(handles.WithOrWithout,'value')-1);
    if(~options.BSA)
        options.CAGET=1;
    else
        options.CAGET=0;
    end 
    options.Samples=str2double(get(handles.SN,'string'));
else
    options.AcquisitionTime=str2double(get(handles.READBPME,'string'));
end

POS=get(handles.ReadCO,'val');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
%LastValidTime=real(ats)+imag(ats)/10^9 - 631152000;

if(options.BSA_HB)
    b=toc;
    while(b<options.AcquisitionTime)
        pause(0.025);
        b=toc;
    end
    BPMRawData=handles.sf.getBPMData_HB_timing(handles.s.bpmList_e, 1, options.startTime);
elseif(options.CAGET)
    BPMRawData=handles.sf.getBPMData_caget(handles.s.bpmList_e, options.Samples, 1);
else
    BPMRawData=handles.sf.getBPMData_reserveBSA(handles.s.bpmList_e, options.Samples, 1,[],options.tmitMin,'',1,handles.BEAMCODE);
end

BPMDataFiltered=zeros(length(handles.s.bpmList),2);
disp(['Collected ',num2str(size(BPMRawData,2)),' shots']);

Pos.nBPM=length(handles.s.bpmList);
if(isempty(BPMRawData))
   set(hObject,'backgroundcolor',handles.ColorRed); drawnow;
   disp('No new shots were collected; beam off?')
   pause(1); 
   set(hObject,'backgroundcolor',handles.ColorIdle); drawnow;
   return
end
for II=1:Pos.nBPM %further exclude BPMs if they give NaNs (?)
    TempData=[BPMRawData(II,:);BPMRawData(II+Pos.nBPM,:);BPMRawData(II+2*Pos.nBPM,:)];
    TempData(:,any(isnan(TempData)))=[]; %Excludes NaN readings first
    if(isempty(TempData(3,:)>options.tmitMin))
        BPMDataFiltered(II,1)=NaN;
        BPMDataFiltered(II,2)=NaN;
    else
        TDX=mean(TempData(1,TempData(3,:)>options.tmitMin));
        if(isempty(TDX))
            BPMDataFiltered(II,1)=NaN;
        else
            BPMDataFiltered(II,1)=TDX;
        end
        TDY=mean(TempData(2,TempData(3,:)>options.tmitMin));
        if(isempty(TDX))
            BPMDataFiltered(II,2)=NaN;
        else
            BPMDataFiltered(II,2)=TDY;
        end
    end
end


    for II=1:numel(handles.BPM.Fullnamex)
        XB{II,POS+2}=BPMDataFiltered(II,1);
    end
    for II=1:numel(handles.BPM.Fullnamey)
        YB{II,POS+2}=BPMDataFiltered(II,2);
    end

%    disp('THIS IS ALL WRONG !!!')
%    set(handles.READBPM,'backgroundcolor',handles.ColorRed);
%    drawnow
%    pause(2)

set(handles.XB,'data',XB);
set(handles.YB,'data',YB);
set(handles.READBPM,'backgroundcolor',handles.ColorIdle);

% while(b<timewait)
%     pause(.1)
%     b=toc;
%     set(handles.ReadingTime,'string',[num2str(b),' / ',timewaits]);
%     drawnow
% end
% try
%     the_matrix=lcaGetSmart(handles.READBUFFER);
%     TemporaryTimeStampsREAL=the_matrix(end-1,:)+the_matrix(end,:)/10^9;
%     ValidTimesPos=find(TemporaryTimeStampsREAL>=LastValidTime);
%     BPMDATA=the_matrix(1:(end-3),ValidTimesPos);
%     [SSA,SSB]=size(BPMDATA);
%     %save TEMP
%     myorbitx=mean(BPMDATA(1:(SSA/3),:),2)/1000;
%     myorbity=mean(BPMDATA((SSA/3+1):(SSA/3*2),:),2)/1000;
%     mytmit=mean(BPMDATA((SSA/3*2+1):end,:),2);
%     for II=1:numel(handles.BPM.Fullnamex)
%         XB{II,POS+2}=myorbitx(II); 
%     end
%     for II=1:numel(handles.BPM.Fullnamey)
%         YB{II,POS+2}=myorbity(II); 
%     end
% catch
%     disp('THIS IS ALL WRONG !!!')
%     set(handles.READBPM,'backgroundcolor',handles.ColorRed);
%     drawnow
%     pause(2)
% end
% set(handles.XB,'data',XB);
% set(handles.YB,'data',YB);
% set(handles.READBPM,'backgroundcolor',handles.ColorIdle);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in STORE.
function handles=STORE_Callback(hObject, eventdata, handles, name)
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in READCOR.
function READCOR_Callback(hObject, eventdata, handles)
conf=get(handles.READCORL,'val');
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
for II=1:numel(handles.XCOR.SET)
    XC{II,conf+2}=lcaGetSmart(handles.XCOR.SET{II});
end
for II=1:numel(handles.YCOR.SET)
    YC{II,conf+2}=lcaGetSmart(handles.YCOR.SET{II});
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function STOREE_Callback(hObject, eventdata, handles)
% hObject    handle to STOREE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of STOREE as text
%        str2double(get(hObject,'String')) returns contents of STOREE as a double


% --- Executes during object creation, after setting all properties.
function STOREE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STOREE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SETCORR.
function SETCORR_Callback(hObject, eventdata, handles)
POS=get(handles.SETCORRC,'val');
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
TrueX=[XC{:,2}];
TrueY=[YC{:,2}];
WRITE=get(handles.WRITE,'value');
for II=1:length(TrueX)
    if(TrueX(II))
        if(~isnan(XC{II,2+POS}))
            if(WRITE)
                lcaPutSmart(handles.XCOR.SET{II},XC{II,2+POS});
            else
                disp(['set ',handles.XCOR.SET{II},' to ',num2str(XC{II,2+POS})])
            end
        end
    end
    if(TrueY(II))
        if(~isnan(YC{II,2+POS}))
            if(WRITE)
                lcaPutSmart(handles.YCOR.SET{II},YC{II,2+POS});
            else
                disp(['set ',handles.YCOR.SET{II},' to ',num2str(YC{II,2+POS})])
            end
        end
    end
end



% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in READFROMDISK.
function READFROMDISK_Callback(hObject, eventdata, handles)
%OK=readtable(get(handles.FromDiskE,'string')); TO BE FIXED !!
filename=[pwd,'/../StoreOrbits/',get(handles.FromDiskE,'string')];
fid=fopen(filename);
OK={};
headerlength=1;
for II=1:headerlength
    fgetl(fid);
end
while(~feof(fid))
    OK{end+1}=fgetl(fid);
end

PVAL=get(handles.READ_TO,'val');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');

for II=1:numel(OK)
    POS=strfind(OK{II},' ');
    POSD=diff(POS);
    NAMESTART=find(POSD>1,1,'first');
    LINE=OK{II}((NAMESTART+1):end);
    POS=strfind(LINE,' ');
    BPMNAME=LINE(1:(POS(1)-1));
    TROV=find(strcmp(handles.BPM.LIST,BPMNAME));
    if(isempty(TROV))
        BPMNAME 
    else
        VAL=str2num(LINE(POS(1):end));
        XB{TROV,2+PVAL}=VAL(1);
        YB{TROV,2+PVAL}=VAL(2);
    end
end

set(handles.XB,'data',XB);
set(handles.YB,'data',YB);



% --- Executes on button press in GUIDUMP.
function GUIDUMP_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
BPM=handles.BPM;
XCOR=handles.XCOR;
YCOR=handles.YCOR;
READBUFFER=handles.READBUFFER;
Timetag=datestr(now); Colons=find(Timetag,':');
Timetag(Colons(1))='h'; Timetag(Colons(2))='m'; Timetag(end+1)='s';
Filename=['orbitPatchwork_save_',Timetag];
save([handles.SaveDir,'/LastConfFile'],'XC','YC','XB','YB','BPM','XCOR','YCOR','READBUFFER');
save([handles.SaveDir,'/',Filename],'XC','YC','XB','YB','BPM','XCOR','YCOR','READBUFFER');
    




function READFROMDISKE_Callback(hObject, eventdata, handles)
% hObject    handle to READFROMDISKE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of READFROMDISKE as text
%        str2double(get(hObject,'String')) returns contents of READFROMDISKE as a double


% --- Executes during object creation, after setting all properties.
function READFROMDISKE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to READFROMDISKE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FormulaE_Callback(hObject, eventdata, handles)
% hObject    handle to FormulaE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FormulaE as text
%        str2double(get(hObject,'String')) returns contents of FormulaE as a double


% --- Executes during object creation, after setting all properties.
function FormulaE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FormulaE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RUN.
function RUN_Callback(hObject, eventdata, handles)
Formula=get(handles.FormulaE,'string');
Pos=strfind(Formula,'=');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
[SA,SB]=size(XB);
if(strfind(Formula(1:(Pos-1)),'C1'))
    AssignTo=1;
elseif(strfind(Formula(1:(Pos-1)),'C2'))
    AssignTo=2;
elseif(strfind(Formula(1:(Pos-1)),'C3'))
    AssignTo=3;
    elseif(strfind(Formula(1:(Pos-1)),'C4'))
    AssignTo=4;
    elseif(strfind(Formula(1:(Pos-1)),'C5'))
    AssignTo=5;
    elseif(strfind(Formula(1:(Pos-1)),'C6'))
    AssignTo=6;
    elseif(strfind(Formula(1:(Pos-1)),'C7'))
    AssignTo=7;
    elseif(strfind(Formula(1:(Pos-1)),'C8'))
    AssignTo=8;
    elseif(strfind(Formula(1:(Pos-1)),'C9'))
    AssignTo=9;
    elseif(strfind(Formula(1:(Pos-1)),'C10'))
    AssignTo=10;
    
else   
    return
end

TrueX=[XB{:,2}].';
TrueY=[YB{:,2}].';
if(~any(TrueX|TrueY))
    return
end
FirstZ=find(TrueX|TrueY,1,'first');
z0=handles.BPM.z(FirstZ);
Formula1=regexprep(['OUT = ',Formula((Pos+1):end),';'],'z','(z-z0)');
for II=FirstZ:SA
   if(TrueX(II))
       C1=XB{II,3};
       C2=XB{II,4};
       C3=XB{II,5};
       C4=XB{II,6};
       C5=XB{II,7};
       C6=XB{II,8};
       C7=XB{II,9};
       C8=XB{II,10};
       C9=XB{II,11};
       C10=XB{II,12};
       z=handles.BPM.z(II);
       eval(Formula1);
       XB{II,2+AssignTo}=OUT;
   end
   if(TrueY(II))
       C1=YB{II,3};
       C2=YB{II,4};
       C3=YB{II,5};
       C4=YB{II,6};
       C5=YB{II,7};
       C6=YB{II,8};
       C7=YB{II,9};
       C8=YB{II,10};
       C9=YB{II,11};
       C10=YB{II,12};
       z=handles.BPM.z(II);
       eval(Formula1);
       YB{II,2+AssignTo}=OUT;
   end
end
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);




% --- Executes on selection change in STOREC.
function STOREC_Callback(hObject, eventdata, handles)
% hObject    handle to STOREC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns STOREC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from STOREC


% --- Executes during object creation, after setting all properties.
function STOREC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STOREC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RESTORE.
function RESTORE_Callback(hObject, eventdata, handles)
ConfID=get(handles.RESTOREC,'val');
Quale=get(handles.RESTORECC,'val');
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');

[SA,~]=size(XC);
for II=1:SA
   XC{II,2+ConfID} = handles.Configurations{Quale}.CVX(II);   
end
[SA,~]=size(YC);
for II=1:SA
   YC{II,2+ConfID} = handles.Configurations{Quale}.CVY(II);  
end
[SA,~]=size(XB);
for II=1:SA
   XB{II,2+ConfID} = handles.Configurations{Quale}.BVX(II); 
end
[SA,~]=size(YB);
for II=1:SA
   YB{II,2+ConfID} = handles.Configurations{Quale}.BVY(II);   
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);


% --- Executes on selection change in RESTOREC.
function RESTOREC_Callback(hObject, eventdata, handles)
% hObject    handle to RESTOREC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RESTOREC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RESTOREC


% --- Executes during object creation, after setting all properties.
function RESTOREC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RESTOREC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RESTORECC.
function RESTORECC_Callback(hObject, eventdata, handles)
% hObject    handle to RESTORECC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RESTORECC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RESTORECC


% --- Executes during object creation, after setting all properties.
function RESTORECC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RESTORECC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function READBPME_Callback(hObject, eventdata, handles)
% hObject    handle to READBPME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of READBPME as text
%        str2double(get(hObject,'String')) returns contents of READBPME as a double


% --- Executes during object creation, after setting all properties.
function READBPME_CreateFcn(hObject, eventdata, handles)
% hObject    handle to READBPME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SVDC.
function SVDC_Callback(hObject, eventdata, handles)
% hObject    handle to SVDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SVDC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SVDC


% --- Executes during object creation, after setting all properties.
function SVDC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SVDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SETCORRC.
function SETCORRC_Callback(hObject, eventdata, handles)
% hObject    handle to SETCORRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SETCORRC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SETCORRC


% --- Executes during object creation, after setting all properties.
function SETCORRC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SETCORRC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ReadCO.
function ReadCO_Callback(hObject, eventdata, handles)
% hObject    handle to ReadCO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ReadCO contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ReadCO


% --- Executes during object creation, after setting all properties.
function ReadCO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReadCO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in READCORL.
function READCORL_Callback(hObject, eventdata, handles)
% hObject    handle to READCORL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns READCORL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from READCORL


% --- Executes during object creation, after setting all properties.
function READCORL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to READCORL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function RESTORE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RESTORE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in RestoreDump.
function RestoreDump_Callback(hObject, eventdata, handles)
load([handles.SaveDir,'/LastConfFile'],'XC','YC','XB','YB','BPM','XCOR','YCOR','READBUFFER');
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

handles.BPM=BPM;
handles.XCOR=XCOR;
handles.YCOR=YCOR;
handles.READBUFFER=READBUFFER;

guidata(hObject, handles);



function RO_Callback(hObject, eventdata, handles)
% hObject    handle to RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RO as text
%        str2double(get(hObject,'String')) returns contents of RO as a double


% --- Executes during object creation, after setting all properties.
function RO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in READ_TO.
function READ_TO_Callback(hObject, eventdata, handles)
% hObject    handle to READ_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns READ_TO contents as cell array
%        contents{get(hObject,'Value')} returns selected item from READ_TO


% --- Executes during object creation, after setting all properties.
function READ_TO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to READ_TO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FromDiskE_Callback(hObject, eventdata, handles)
% hObject    handle to FromDiskE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FromDiskE as text
%        str2double(get(hObject,'String')) returns contents of FromDiskE as a double


% --- Executes during object creation, after setting all properties.
function FromDiskE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FromDiskE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E1_Callback(hObject, eventdata, handles)
% hObject    handle to E1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E1 as text
%        str2double(get(hObject,'String')) returns contents of E1 as a double


% --- Executes during object creation, after setting all properties.
function E1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E2_Callback(hObject, eventdata, handles)
% hObject    handle to E2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E2 as text
%        str2double(get(hObject,'String')) returns contents of E2 as a double


% --- Executes during object creation, after setting all properties.
function E2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function E3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function E4_Callback(hObject, eventdata, handles)
% hObject    handle to E4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E4 as text
%        str2double(get(hObject,'String')) returns contents of E4 as a double


% --- Executes during object creation, after setting all properties.
function E4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
E1=get(handles.E1,'string');
E2=get(handles.E2,'string');
E3=get(handles.E3,'string');
E3end=get(handles.E3end,'string');
E4=get(handles.E4,'string');

XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');

INTXC=ones(size(handles.XCOR.z));
INTYC=ones(size(handles.YCOR.z));
INTXB=ones(size(handles.BPM.z)).';
INTYB=ones(size(handles.BPM.z)).';

if(~isempty(E1))
    INTXC=INTXC & strcmpi(handles.XCOR.N1,E1);
    INTYC=INTYC & strcmpi(handles.YCOR.N1,E1);
    INTXB=INTXB & strcmpi(handles.BPM.XN1,E1);
    INTYB=INTYB & strcmpi(handles.BPM.YN1,E1);
end

if(~isempty(E2))
    INTXC=INTXC & strcmpi(handles.XCOR.N2,E2);
    INTYC=INTYC & strcmpi(handles.YCOR.N2,E2);
    INTXB=INTXB & strcmpi(handles.BPM.XN2,E2);
    INTYB=INTYB & strcmpi(handles.BPM.YN2,E2);
end

E3n=str2num(E3); E3en=str2num(E3end);
if(isempty(E3n))
    E3n=E3en;
end
if(isempty(E3en))
    E3en=E3n;
end
%save TEMP
if(~isempty(E3n) &&  ~isempty(E3en) ) 
    INTXC=INTXC & ((handles.XCOR.N3n>=E3n) & (handles.XCOR.N3n<=E3en) );%  strcmpi(handles.XCOR.N3,E3);
    INTYC=INTYC & ((handles.YCOR.N3n>=E3n) & (handles.YCOR.N3n<=E3en) );%  strcmpi(handles.YCOR.N3,E3);
    INTXB=INTXB & ((handles.BPM.XN3n>=E3n) & (handles.BPM.XN3n<=E3en) );%  strcmpi(handles.BPM.XN3,E3);
    INTYB=INTYB & ((handles.BPM.YN3n>=E3n) & (handles.BPM.YN3n<=E3en) );%  strcmpi(handles.BPM.YN3,E3);
end

if(~isempty(E4))
    INTXC=INTXC & strcmpi(handles.XCOR.N4,E4);
    INTYC=INTYC & strcmpi(handles.YCOR.N4,E4);
    INTXB=INTXB & strcmpi(handles.BPM.XN4,E4);
    INTYB=INTYB & strcmpi(handles.BPM.YN4,E4);
end

if(any(INTXC))
   for II=1:length(INTXC)
      if(INTXC(II))
           XC{II,2}=true;         
      end       
   end
end
if(any(INTYC))
   for II=1:length(INTYC)
      if(INTYC(II))
           YC{II,2}=true;         
      end       
   end
end
if(any(INTXB))
   for II=1:length(INTXB)
      if(INTXB(II))
           XB{II,2}=true;         
      end       
   end
end
if(any(INTYB))
   for II=1:length(INTYB)
      if(INTYB(II))
           YB{II,2}=true;         
      end       
   end
end

set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
E1=get(handles.E1,'string');
E2=get(handles.E2,'string');
E3=get(handles.E3,'string');
E3end=get(handles.E3end,'string');
E4=get(handles.E4,'string');

XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');

INTXC=ones(size(handles.XCOR.z));
INTYC=ones(size(handles.YCOR.z));
INTXB=ones(size(handles.BPM.z)).';
INTYB=ones(size(handles.BPM.z)).';

if(~isempty(E1))
    INTXC=INTXC & strcmpi(handles.XCOR.N1,E1);
    INTYC=INTYC & strcmpi(handles.YCOR.N1,E1);
    INTXB=INTXB & strcmpi(handles.BPM.XN1,E1);
    INTYB=INTYB & strcmpi(handles.BPM.YN1,E1);
end

if(~isempty(E2))
    INTXC=INTXC & strcmpi(handles.XCOR.N2,E2);
    INTYC=INTYC & strcmpi(handles.YCOR.N2,E2);
    INTXB=INTXB & strcmpi(handles.BPM.XN2,E2);
    INTYB=INTYB & strcmpi(handles.BPM.YN2,E2);
end

E3n=str2num(E3); E3en=str2num(E3end);
if(isempty(E3n))
    E3n=E3en;
end
if(isempty(E3en))
    E3en=E3n;
end

if(~isempty(E3n) &&  ~isempty(E3en) ) 
    INTXC=INTXC & ((handles.XCOR.N3n>=E3n) & (handles.XCOR.N3n<=E3en) );%  strcmpi(handles.XCOR.N3,E3);
    INTYC=INTYC & ((handles.YCOR.N3n>=E3n) & (handles.YCOR.N3n<=E3en) );%  strcmpi(handles.YCOR.N3,E3);
    INTXB=INTXB & ((handles.BPM.XN3n>=E3n) & (handles.BPM.XN3n<=E3en) );%  strcmpi(handles.BPM.XN3,E3);
    INTYB=INTYB & ((handles.BPM.YN3n>=E3n) & (handles.BPM.YN3n<=E3en) );%  strcmpi(handles.BPM.YN3,E3);
end

if(~isempty(E4))
    INTXC=INTXC & strcmpi(handles.XCOR.N4,E4);
    INTYC=INTYC & strcmpi(handles.YCOR.N4,E4);
    INTXB=INTXB & strcmpi(handles.BPM.XN4,E4);
    INTYB=INTYB & strcmpi(handles.BPM.YN4,E4);
end

if(any(INTXC))
   for II=1:length(INTXC)
      if(INTXC(II))
           XC{II,2}=false;         
      end       
   end
end
if(any(INTYC))
   for II=1:length(INTYC)
      if(INTYC(II))
           YC{II,2}=false;         
      end       
   end
end
if(any(INTXB))
   for II=1:length(INTXB)
      if(INTXB(II))
           XB{II,2}=false;         
      end       
   end
end
if(any(INTYB))
   for II=1:length(INTYB)
      if(INTYB(II))
           YB{II,2}=false;         
      end       
   end
end

set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

% --- Executes during object creation, after setting all properties.
function pushbutton29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
name=get(handles.edit14,'string');
ConfID=get(handles.popupmenu11,'val');
BVX=[XB{:,2+ConfID}].';
BVY=[YB{:,2+ConfID}].';
MyBPMs=handles.BPM;
MyBPMs.Xorbit=BVX;
MyBPMs.Yorbit=BVY;
try
    save([pwd,'/../StoreOrbits/',name],'MyBPMs');
end
save([handles.SaveDir,'/',name],'MyBPMs');


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11


% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fitOrbitGain_Callback(hObject, eventdata, handles)
% hObject    handle to fitOrbitGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fitOrbitGain as text
%        str2double(get(hObject,'String')) returns contents of fitOrbitGain as a double


% --- Executes during object creation, after setting all properties.
function fitOrbitGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitOrbitGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in STARTFB.
function STARTFB_Callback(hObject, eventdata, handles)
set(handles.STARTFB,'enable','off');
set(handles.STARTFB,'string','Feedback Running');

%     SVDC=get(handles.SVDC,'value');
%     WRITE=get(handles.WRITE,'value');
%     XC=get(handles.XC,'data');
%     YC=get(handles.YC,'data');
%     XB=get(handles.XB,'data');
%     YB=get(handles.YB,'data');
%     TrueXC=[XC{:,2}];
%     TrueYC=[YC{:,2}];
%     TrueXB=[XB{:,2}];
%     TrueYB=[YB{:,2}];
%     TargetX=[XB{:,2+SVDC}];
%     TargetY=[YB{:,2+SVDC}];
%     TrueB=TrueXB|TrueYB;
%     REGXC={handles.XCOR.Fullname{TrueXC}};
%     region={};
%     for II=1:numel(REGXC)
%         region{end+1}=REGXC{II}(6:end);
%     end
%     REGYC={handles.YCOR.Fullname{TrueYC}};
%     for II=1:numel(REGYC)
%         region{end+1}=REGYC{II}(6:end);
%     end
%     REGB={handles.BPM.FullNames{TrueB}};
%     for II=1:numel(REGB)
%         region{end+1}=REGB{II}(6:end);
%     end
%     timewait=str2num(get(handles.RO,'string'));
    
while(1)
    tic
    disp('feedback running')
    COLOR=get(handles.STOPFB,'backgroundcolor');
    if(sum(COLOR==handles.ColorYellow)==3)
        set(handles.STARTFB,'enable','on');
        set(handles.STOPFB,'backgroundcolor',handles.ColorIdle);
        set(handles.STARTFB,'string','Steer as Feedback');
        return
    end
    
    handles.static=bba_simulInit('sector',region);
    [handles.data.R,handles.data.en]=bba_responseMatGet(handles.static,1);

    

    % MyxMeas(1,:,:)=BPMDATA(1:(SSA/3),:)/1000;
    % MyxMeas(2,:,:)=BPMDATA((SSA/3+1):(SSA/3*2),:)/1000;

    [gdet,ats]=lcaGetSmart('GDET:FEE1:241:ENRC');
    LastValidTime=real(ats)+imag(ats)/10^9- 631152000;
    opts.useInit=0;
    opts.use=struct('init',opts.useInit,'quad',0,'BPM',0,'corr',1);
    opts.fitSVDRatio=1e-6;
    FSIZE=(numel(handles.READBUFFER)-3)/3;
    SSIZE=sum(double(TrueB));
    READBUFFER={handles.READBUFFER{[TrueB,TrueB,TrueB,true,true,true]}};
    b=toc;
    while(b<timewait)
        pause(.1)
        b=toc;
    end

    the_matrix=lcaGetSmart(READBUFFER);
    TemporaryTimeStampsREAL=the_matrix(end-1,:)+the_matrix(end,:)/10^9;
    ValidTimesPos=find(TemporaryTimeStampsREAL>=LastValidTime);
    disp('Read Samples',length(ValidTimesPos));
    BPMDATA=the_matrix(1:(end-3),ValidTimesPos);
    MyxMeas(1,:,:)=BPMDATA(1:(SSIZE),:)/1000;
    MyxMeas(2,:,:)=BPMDATA((SSIZE+1):(SSIZE*2),:)/1000;
    tmits=BPMDATA((SSIZE*2+1):(SSIZE*3),:);
    [SIZEA,SIZEB]=size(tmits);
    if(SIZEB<60)
       disp('Less than 60 samples collected, not moving')
       
    end
    lowtmits=any(tmits<5*10^7);
    if(sum(lowtmits)/length(tmits)>0.9)
        disp('More than 10% tmits are low, not moving')
        
    end
    MyxMeas=MyxMeas(:,:,~lowtmits);
    MyxMeasStd=std(MyxMeas,0,3)/sqrt(size(MyxMeas,3));
    MyxMeas=mean(MyxMeas,3);
    %save TEMP
    MyxMeas(1,:)=MyxMeas(1,:)-TargetX(TrueB);
    MyxMeas(2,:)=MyxMeas(2,:)-TargetY(TrueB);
    handles.data.ts=now;
    Myf=bba_my_fitOrbit(handles.static,handles.data.R,MyxMeas,MyxMeasStd,opts);
    handles.Mydata.xMeasF=MyxMeas-Myf.xMeasF;
    opts.figure=4;opts.axes={2 2 2;2 2 4};
    bba_plotCorr(handles.static,-Myf.corrOff,1,opts);
    opts.title=['BBA Scan Orbit ' datestr(handles.data.ts)];
    opts.figure=4;opts.axes={2 2 1;2 2 3};

    opts.gain=str2num(get(handles.fitOrbitGain,'string'));

    bba_plotOrbit(handles.static,MyxMeas,MyxMeasStd,handles.Mydata.xMeasF,handles.data.en,opts);
    disp('....')
    %THIS APPLIES THE CORRECTION !!!!
     bDes=bba_corrGet(handles.static,1);
         disp([datestr(now) ' Corrector changes:']);
         disp((bDes-Myf.corrOff*opts.gain)*1e3);
         if(WRITE)
            bba_corrSet(handles.static,-Myf.corrOff*opts.gain,1,'wait',0);
         end

end




function feedbackstate_Callback(hObject, eventdata, handles)
% hObject    handle to feedbackstate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of feedbackstate as text
%        str2double(get(hObject,'String')) returns contents of feedbackstate as a double


% --- Executes during object creation, after setting all properties.
function text14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function feedbackstate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to feedbackstate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in WRITE.
function WRITE_Callback(hObject, eventdata, handles)
% hObject    handle to WRITE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('write mode enabled')
% Hint: get(hObject,'Value') returns toggle state of WRITE



function E3end_Callback(hObject, eventdata, handles)
% hObject    handle to E3end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of E3end as text
%        str2double(get(hObject,'String')) returns contents of E3end as a double


% --- Executes during object creation, after setting all properties.
function E3end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to E3end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in STOPFB.
function STOPFB_Callback(hObject, eventdata, handles)
set(handles.STOPFB,'backgroundcolor',handles.ColorYellow);
drawnow


% --- Executes on button press in pushbutton34.
function pushbutton34_Callback(hObject, eventdata, handles)
set(handles.STARTFB,'enable','on');
set(handles.STOPFB,'backgroundcolor',handles.ColorIdle);
set(handles.READBPM,'backgroundcolor',handles.ColorIdle);
set(handles.STARTFB,'string','Steer as Feedback');
% load('/u1/lcls/matlab/data/2016/2016-06/2016-06-15/UDisp--2016-06-15-050423.mat')
% XB=get(handles.XB,'data');
% YB=get(handles.YB,'data');
% size(XB)
% size(YB)
% for TT=33:(33+32)
%     TT
%     XB{TT,3}=data.data(3).x(TT-33+1)/1000*0;
%     YB{TT,3}=data.data(3).y(TT-33+1)/1000;
% end
% set(handles.XB,'data',XB);
% set(handles.YB,'data',YB);


% --- Executes on button press in STFB.
function STFB_Callback(hObject, eventdata, handles)
% tic
% set(handles.READBPM,'backgroundcolor',handles.ColorYellow);
% drawnow
SVDC=get(handles.SVDC,'value');
WRITE=get(handles.WRITE,'value');
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
TrueXC=[XC{:,2}];
TrueYC=[YC{:,2}];
TrueXB=[XB{:,2}];
TrueYB=[YB{:,2}];
TargetX=[XB{:,2+SVDC}];
TargetY=[YB{:,2+SVDC}];
TrueB=TrueXB|TrueYB;
REGXC={handles.XCOR.Fullname{TrueXC}};
region={};
for II=1:numel(REGXC)
    region{end+1}=REGXC{II}(6:end);
end
REGYC={handles.YCOR.Fullname{TrueYC}};
for II=1:numel(REGYC)
    region{end+1}=REGYC{II}(6:end);
end
REGB={handles.BPM.FullNames{TrueB}};
for II=1:numel(REGB)
    region{end+1}=REGB{II}(6:end);
end
handles.static=bba_simulInit('sector',region);
[handles.data.R,handles.data.en]=bba_responseMatGet(handles.static,1);

STATIC=handles.static;
DATA=handles.data;

timewait=str2num(get(handles.RO,'string'));

% MyxMeas(1,:,:)=BPMDATA(1:(SSA/3),:)/1000;
% MyxMeas(2,:,:)=BPMDATA((SSA/3+1):(SSA/3*2),:)/1000;

[gdet,ats]=lcaGetSmart('GDET:FEE1:241:ENRC');
LastValidTime=real(ats)+imag(ats)/10^9- 631152000;
opts.useInit=0;
opts.use=struct('init',opts.useInit,'quad',0,'BPM',0,'corr',1);
opts.fitSVDRatio=1e-6;
FSIZE=(numel(handles.READBUFFER)-3)/3;
SSIZE=sum(double(TrueB));
READBUFFER={handles.READBUFFER{[TrueB,TrueB,TrueB,true,true,true]}};
b=toc;

while(b<timewait)
    pause(.1)
    b=toc;
end

% the_matrix=lcaGetSmart(READBUFFER);
% TemporaryTimeStampsREAL=the_matrix(end-1,:)+the_matrix(end,:)/10^9;
% ValidTimesPos=find(TemporaryTimeStampsREAL>=LastValidTime);
length(ValidTimesPos)
% BPMDATA=the_matrix(1:(end-3),ValidTimesPos);
% MyxMeas(1,:,:)=BPMDATA(1:(SSIZE),:)/1000;
% MyxMeas(2,:,:)=BPMDATA((SSIZE+1):(SSIZE*2),:)/1000;
% MyxMeasStd=std(MyxMeas,0,3)/sqrt(size(MyxMeas,3));
% MyxMeas=mean(MyxMeas,3);
%save TEMP
% MyxMeas(1,:)=MyxMeas(1,:)-TargetX(TrueB);
% MyxMeas(2,:)=MyxMeas(2,:)-TargetY(TrueB);
handles.data.ts=now
% Myf=bba_my_fitOrbit(handles.static,handles.data.R,MyxMeas,MyxMeasStd,opts);
% handles.Mydata.xMeasF=MyxMeas-Myf.xMeasF;
opts.figure=4;opts.axes={2 2 2;2 2 4};
bba_plotCorr(handles.static,-Myf.corrOff,1,opts);
opts.title=['BBA Scan Orbit ' datestr(handles.data.ts)];
opts.figure=4;opts.axes={2 2 1;2 2 3};

opts.gain=str2num(get(handles.fitOrbitGain,'string'));
OPTS=opts;
FILENAME=['Feedback-',regexprep(regexprep(datestr(now),' ','_'),':','-')];

save([pwd,'/../Feedbacks/',FILENAME],'OPTS','FSIZE','SSIZE','READBUFFER','DATA','STATIC','TargetX','TargetY','TrueB');

% bba_plotOrbit(handles.static,MyxMeas,MyxMeasStd,handles.Mydata.xMeasF,handles.data.en,opts);
% disp('....')
% %THIS APPLIES THE CORRECTION !!!!
%  bDes=bba_corrGet(handles.static,1);
%      disp([datestr(now) ' Corrector changes:']);
%      disp((bDes-Myf.corrOff*opts.gain)*1e3);
%      if(WRITE)
%         bba_corrSet(handles.static,-Myf.corrOff*opts.gain,1,'wait',0);
%      end

%set(handles.READBPM,'backgroundcolor',handles.ColorIdle);


% --- Executes on button press in ROWDCI.
function ROWDCI_Callback(hObject, eventdata, handles)
set(handles.ReadCO,'value',1); drawnow
READBPM_Callback(hObject, eventdata, handles);pause(0.05);drawnow;
if(get(handles.OvrX,'value'))
    disp('zeroing XB')
    XB=get(handles.XB,'data');
    IND=strfind(XB(:,1),'UND');
    for II=1:numel(IND)
        if(~isempty(IND{II}))
           XB{II,3}=0; 
        else
            
        end
    end
    set(handles.XB,'data',XB);
end

if(get(handles.OvrY,'value'))
    disp('zeroing YB')
    YB=get(handles.YB,'data');
    IND=strfind(YB(:,1),'UND');
    for II=1:numel(IND)
        if(~isempty(IND{II}))
           YB{II,3}=0; 
        else
            
        end
    end
    set(handles.YB,'data',YB);
end



% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
includeDump=get(handles.checkbox7,'value');
FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

XB=get(handles.XB,'data'); YB=get(handles.YB,'data');

for II=FirstBPM:LastBPM
    XB{II,4}=-XB{II,3};
    YB{II,4}=-YB{II,3};
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,4}=XB{II,3};
        YB{II,4}=YB{II,3};
    end
else
end

set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

name='HEAD';
ConfID=1;
BVX=[XB{:,2+ConfID}].';
BVY=[YB{:,2+ConfID}].';
MyBPMs=handles.BPM;
MyBPMs.Xorbit=BVX;
MyBPMs.Yorbit=BVY;
try
    save([pwd,'/../StoreOrbits/',name],'MyBPMs');
end
save([handles.SaveDir,'/',name],'MyBPMs');

name='TAIL';
ConfID=2;
BVX=[XB{:,2+ConfID}].';
BVY=[YB{:,2+ConfID}].';
MyBPMs=handles.BPM;
MyBPMs.Xorbit=BVX;
MyBPMs.Yorbit=BVY;
try
    save([pwd,'/../StoreOrbits/',name],'MyBPMs');
end
save([handles.SaveDir,'/',name],'MyBPMs');


% --- Executes on button press in pushbutton38.
function pushbutton38_Callback(hObject, eventdata, handles)
COEFF=str2num(get(handles.XP,'string'));
includeDump=get(handles.checkbox7,'value');
FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

XB=get(handles.XB,'data'); YB=get(handles.YB,'data');

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,5}=-XB{II,3}*COEFF;
    YB{II,5}=-YB{II,3}*COEFF;
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,5}=XB{II,3};
        YB{II,5}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end

%Set desired correctors for steering
XC=get(handles.XC,'data');
YC=get(handles.YC,'data');

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC

    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end

set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',3);

function XP_Callback(hObject, eventdata, handles)
% hObject    handle to XP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XP as text
%        str2double(get(hObject,'String')) returns contents of XP as a double


% --- Executes during object creation, after setting all properties.
function XP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton39.
function pushbutton39_Callback(hObject, eventdata, handles)
COEFF1=str2num(get(handles.XP2,'string'));
COEFF2=str2num(get(handles.YP2,'string'));
includeDump=get(handles.checkbox7,'value');
Location=get(handles.Location,'value');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');XC=get(handles.XC,'data');YC=get(handles.YC,'data');

FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);
SwitchBPM=handles.BPM.SwitchPosition(Location);

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);


for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    if(II<SwitchBPM)
        XB{II,6}=-XB{II,3}*COEFF1;
        YB{II,6}=-YB{II,3}*COEFF1;
    else
        XB{II,6}=XB{II,3}*COEFF2;
        YB{II,6}=YB{II,3}*COEFF2;
    end
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,6}=XB{II,3};
        YB{II,6}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end
%Set desired correctors for steering

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',4);

function XP2_Callback(hObject, eventdata, handles)
% hObject    handle to XP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XP2 as text
%        str2double(get(hObject,'String')) returns contents of XP2 as a double


% --- Executes during object creation, after setting all properties.
function XP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YP2_Callback(hObject, eventdata, handles)
% hObject    handle to YP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YP2 as text
%        str2double(get(hObject,'String')) returns contents of YP2 as a double


% --- Executes during object creation, after setting all properties.
function YP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton42.
function pushbutton42_Callback(hObject, eventdata, handles)
set(handles.SVDC,'value',3); drawnow;
A=get(handles.AA3,'value');
%Select as chosen
DALL_Callback(hObject, eventdata, handles);
if(A)
    set(handles.E2,'string','und1');
    set(handles.E3,'string','1000');
    set(handles.E3,'string','4747');drawnow;
    pushbutton29_Callback(hObject, eventdata, handles);
else
    set(handles.E2,'string','und1');drawnow;
    pushbutton29_Callback(hObject, eventdata, handles);
    XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
    FIRSTUNDX=find(strcmp(XC(:,1),'XCOR:UND1:180'),1,'first');
    FIRSTUNDY=find(strcmp(YC(:,1),'YCOR:UND1:180'),1,'first');
    XC{FIRSTUNDX-1,2}=true; XC{FIRSTUNDX-2,2}=true;
    YC{FIRSTUNDY-1,2}=true; YC{FIRSTUNDY-2,2}=true;
    set(handles.XC,'data',XC); set(handles.YC,'data',YC); drawnow; %ALL X and Y plus two correctors in LTU are selected
end

SVD_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton44.
function pushbutton44_Callback(hObject, eventdata, handles)
set(handles.ReadCO,'value',5); drawnow
READBPM_Callback(hObject, eventdata, handles);
set(handles.SVDC,'value',5);

% --- Executes on button press in AA1.
function AA1_Callback(hObject, eventdata, handles)
% hObject    handle to AA1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AA1


% --- Executes on button press in AA2.
function AA2_Callback(hObject, eventdata, handles)
% hObject    handle to AA2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AA2


% --- Executes on button press in AA3.
function AA3_Callback(hObject, eventdata, handles)
% hObject    handle to AA3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AA3


% --- Executes on button press in AA4.
function AA4_Callback(hObject, eventdata, handles)
% hObject    handle to AA4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AA4


% --- Executes on button press in AA5.
function AA5_Callback(hObject, eventdata, handles)
% hObject    handle to AA5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AA5


% --- Executes on button press in DALL.
function DALL_Callback(hObject, eventdata, handles)
FirstBPM=1;
LastBPM=length(handles.BPM.FullNames);
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');

for II=FirstBPM:LastBPM
    XB{II,2}=false;
    YB{II,2}=false;
end

XC=get(handles.XC,'data');
YC=get(handles.YC,'data');

FirstXC=1;LastXC=length(handles.XCOR.Fullname);
FirstYC=1;LastYC=length(handles.YCOR.Fullname);

for II=FirstXC:LastXC
    XC{II,2}=false;
end
for II=FirstYC:LastYC
    YC{II,2}=false;
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);

% --- Executes when entered data in editable cell(s) in XC.
function XC_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to XC (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton53.
function pushbutton53_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,2}=true;
    YB{II,2}=true;
end

for II=(LastBPM+1):DumpBPM
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<=(LastXC))
       XC{II,2}=true;
   else
       XC{II,2}=false;
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
    elseif(II<=(LastYC))
       YC{II,2}=true;
    else
       YC{II,2}=false;
    end
end
ExcludeBPM=get(handles.ExcludeBPM,'string');
try
   EXB=str2num(ExcludeBPM);
   for SS=1:length(EXB)
       if(EXB(SS)<=size(XB,1))
           XB{EXB(SS),2}='false';
       end
       if(EXB(SS)<=size(YB,1))
           YB{EXB(SS),2}='false';
       end
   end
catch
   disp('Something wrong with exclude'); 
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);


% --- Executes on selection change in Location.
function Location_Callback(hObject, eventdata, handles)
% hObject    handle to Location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Location contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Location


% --- Executes during object creation, after setting all properties.
function Location_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in KindOf.
function KindOf_Callback(hObject, eventdata, handles)
% hObject    handle to KindOf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns KindOf contents as cell array
%        contents{get(hObject,'Value')} returns selected item from KindOf


% --- Executes during object creation, after setting all properties.
function KindOf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KindOf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in pushbutton54.
function pushbutton54_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,2}=true;
    YB{II,2}=true;
end

for II=(LastBPM+1):DumpBPM
    XB{II,2}=true;
    YB{II,2}=true;
end

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<=(LastXC))
       XC{II,2}=true;
   else
       XC{II,2}=true;
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
    elseif(II<=(LastYC))
       YC{II,2}=true;
    else
       YC{II,2}=true;
    end
end

ExcludeBPM=get(handles.ExcludeBPM,'string');
try
   EXB=str2num(ExcludeBPM);
   for SS=1:length(EXB)
       if(EXB(SS)<=size(XB,1))
           XB{EXB(SS),2}='false';
       end
       if(EXB(SS)<=size(YB,1))
           YB{EXB(SS),2}='false';
       end
   end
catch
   disp('Something wrong with exclude'); 
end

set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);


% --- Executes on button press in pushbutton55.
function pushbutton55_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
Location=get(handles.L2,'value');
PLUS=round(str2num(get(handles.Plus,'string')));

FirstBPM=handles.BPM.SwitchPosition(Location);
%DA MODIFICARE
FirstXC=handles.XCOR.SwitchPosition(Location)-PLUS;
FirstYC=handles.YCOR.SwitchPosition(Location)-PLUS;
% 
% FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

%FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

%FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,2}=true;
    YB{II,2}=true;
end

for II=(LastBPM+1):DumpBPM
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<=(LastXC))
       XC{II,2}=true;
   else
       XC{II,2}=false;
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
    elseif(II<=(LastYC))
       YC{II,2}=true;
    else
       YC{II,2}=false;
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);


% --- Executes on selection change in L2.
function L2_Callback(hObject, eventdata, handles)
% hObject    handle to L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns L2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from L2


% --- Executes during object creation, after setting all properties.
function L2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Plus_Callback(hObject, eventdata, handles)
% hObject    handle to Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Plus as text
%        str2double(get(hObject,'String')) returns contents of Plus as a double


% --- Executes during object creation, after setting all properties.
function Plus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton56.
function pushbutton56_Callback(hObject, eventdata, handles)
XC=get(handles.XC,'data'); YC=get(handles.YC,'data');XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
Location=get(handles.L2,'value');
PLUS=round(str2num(get(handles.Plus,'string')));

FirstBPM=handles.BPM.SwitchPosition(Location);
%DA MODIFICARE
FirstXC=handles.XCOR.SwitchPosition(Location)-PLUS;
FirstYC=handles.YCOR.SwitchPosition(Location)-PLUS;
% 
% FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

%FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

%FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);


for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,2}=true;
    YB{II,2}=true;
end

for II=(LastBPM+1):DumpBPM
    XB{II,2}=true;
    YB{II,2}=true;
end

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<=(LastXC))
       XC{II,2}=true;
   else
       XC{II,2}=true;
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
    elseif(II<=(LastYC))
       YC{II,2}=true;
    else
       YC{II,2}=true;
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);


% --- Executes on button press in doMathX.
function doMathX_Callback(hObject, eventdata, handles)
% hObject    handle to doMathX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doMathX


% --- Executes on button press in doMathY.
function doMathY_Callback(hObject, eventdata, handles)
% hObject    handle to doMathY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doMathY


% --- Executes on button press in pushbutton57.
function pushbutton57_Callback(hObject, eventdata, handles)
COEFF1=str2num(get(handles.edit24,'string'));
COEFF2=str2num(get(handles.edit25,'string'));
YON=get(handles.YON,'value'); XON=get(handles.XON,'value');
includeDump=get(handles.checkbox7,'value');
Location=get(handles.Location,'value');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');XC=get(handles.XC,'data');YC=get(handles.YC,'data');

FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);
SwitchBPM=handles.BPM.SwitchPosition(Location);

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    if(II<SwitchBPM)
        if(XON)
            XB{II,8}=XB{II,7}*COEFF1; 
        else
            XB{II,8}=XB{II,7}; 
        end
        if(YON)
            YB{II,8}=YB{II,7}*COEFF1;
        else
            YB{II,8}=YB{II,7};
        end
    else
        if(XON)
            XB{II,8}=XB{II,7}*COEFF2; 
        else
            XB{II,8}=XB{II,7};
        end
        if(YON)
            YB{II,8}=YB{II,7}*COEFF2;
        else
            YB{II,8}=YB{II,7};
        end
    end
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,8}=XB{II,7};
        YB{II,8}=YB{II,7};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end
%Set desired correctors for steering

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',6);

function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OvrX.
function OvrX_Callback(hObject, eventdata, handles)
% hObject    handle to OvrX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OvrX


% --- Executes on button press in SteerX.
function SteerX_Callback(hObject, eventdata, handles)
% hObject    handle to SteerX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SteerX


% --- Executes on button press in SteerY.
function SteerY_Callback(hObject, eventdata, handles)
% hObject    handle to SteerY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SteerY


% --- Executes on button press in pushbutton58.
function pushbutton58_Callback(hObject, eventdata, handles)
COEFF1=str2num(get(handles.edit26,'string'));
COEFF2=str2num(get(handles.edit27,'string'));
COEFF3=str2num(get(handles.edit28,'string'));
SWITCH=round(str2num(get(handles.edit29,'string')));
includeDump=get(handles.checkbox7,'value');
Location=get(handles.Location,'value');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');XC=get(handles.XC,'data');YC=get(handles.YC,'data');

FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);
SwitchBPM=handles.BPM.SwitchPosition(Location);

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

SWITCHPOS = SwitchBPM+ SWITCH;

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    if(II<SwitchBPM)
        XB{II,9}=XB{II,3}*COEFF1;
        YB{II,9}=YB{II,3}*COEFF1;
    elseif(II<SWITCHPOS)
        XB{II,9}=-XB{II,3}*COEFF2;
        YB{II,9}=-YB{II,3}*COEFF2;
    else
        XB{II,9}=-XB{II,3}*COEFF3;
        YB{II,9}=-YB{II,3}*COEFF3;
    end
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,9}=XB{II,3};
        YB{II,9}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end
%Set desired correctors for steering

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',7);

function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in YON.
function YON_Callback(hObject, eventdata, handles)
% hObject    handle to YON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of YON



function SHOW_Callback(hObject, eventdata, handles)
% hObject    handle to SHOW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SHOW as text
%        str2double(get(hObject,'String')) returns contents of SHOW as a double


% --- Executes during object creation, after setting all properties.
function SHOW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SHOW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmin_Callback(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmin as text
%        str2double(get(hObject,'String')) returns contents of xmin as a double


% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xmax_Callback(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xmax as text
%        str2double(get(hObject,'String')) returns contents of xmax as a double


% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin as text
%        str2double(get(hObject,'String')) returns contents of ymin as a double


% --- Executes during object creation, after setting all properties.
function ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax as text
%        str2double(get(hObject,'String')) returns contents of ymax as a double


% --- Executes during object creation, after setting all properties.
function ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton59.
function pushbutton59_Callback(hObject, eventdata, handles)
EXTF=figure;
AX1=axes('position',[0.08 0.07 0.9 0.40]);
AX2=axes('position',[0.08 0.53 0.9 0.40]);
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
TS=str2num(get(handles.SHOW,'string'));
AR=get(handles.AR,'value');

Linestyle={'k','r','b','m','c','y','g','b--','k--','r--'};
cla(AX1);cla(AX2);
hold(AX1,'on'); hold(AX2,'on')

switch AR
    case 1
        IND=handles.BPM.UND;
    case 2
        IND=[handles.BPM.UND,handles.BPM.DMP];
    case 3
        IND=[handles.BPM.LTU,handles.BPM.UND,handles.BPM.DMP];
end

hold(AX1,'on'); hold(AX2,'on');

zCend=handles.BPM.z(handles.BPM.chicane);
zCstart=handles.BPM.z(handles.BPM.chicane-1);

z=handles.BPM.z(IND)-min(handles.BPM.z(IND));
zCend=zCend-min(handles.BPM.z(IND));
zCstart=zCstart-min(handles.BPM.z(IND));

for II=1:length(TS)
   Ox= cell2mat(XB(IND,TS(II)+2));
   Oy= cell2mat(YB(IND,TS(II)+2));
   if(II==1)
       YRange=[min(Oy),max(Oy)]; XRange=[min(Ox),max(Ox)];
   else
       YRange=[min([YRange(1);Oy]),max([YRange(2);Oy])]; XRange=[min([XRange(1);Ox]),max([XRange(2);Ox])];
   end
   plot(AX1,z,Oy,Linestyle{II})
   plot(AX2,z,Ox,Linestyle{II})
end
for II=1:length(zCstart)
   plot(AX1,[zCstart(II),zCend(II)],[0,0],'k','linewidth',2); 
   plot(AX2,[zCstart(II),zCend(II)],[0,0],'k','linewidth',2);
end
XRange(1)=XRange(1) - 0.00001; XRange(2)=XRange(2) + 0.00001;
YRange(1)=YRange(1) - 0.00001; YRange(2)=YRange(2) + 0.00001;
XRange=XRange*1.05; YRange=YRange*1.05;
ylim(AX1,YRange); ylim(AX2,XRange); 

ylabel(AX2,'x - [mm]'); ylabel(AX1,'y - [mm]');

% for II=1:length(TS)
%     for KK=FirstBPM:LastBPM
%         Ox(KK+1-FirstBPM)=XB{KK,TS(II)+2};
%         Oy(KK+1-FirstBPM)=YB{KK,TS(II)+2};
%     end 
%     plot(handles.axes1,0:(length(Oy)-1),Oy,Linestyle{II})
%     plot(handles.axes2,0:(length(Oy)-1),Ox,Linestyle{II})
% end
% ylim(handles.axes1,'auto'); ylim(handles.axes2,'auto');
% SXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:890'));
% HXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:1590'));
% 
% YL=ylim(handles.axes1);
% XL=ylim(handles.axes2);
% 
% if(~isempty(ymin))
%     YL(1)=ymin;
% end
% if(~isempty(ymax))
%     YL(2)=ymax;
% end
% if(~isempty(xmin))
%     XL(1)=xmin;
% end
% if(~isempty(xmax))
%     XL(2)=xmax;
% end
% 
% 
% plot(handles.axes1,[SXRSSBPM,SXRSSBPM]-FirstBPM+1-1,YL,'k'); plot(handles.axes1,[SXRSSBPM+1,SXRSSBPM+1]-FirstBPM+1-1,YL,'k');
% plot(handles.axes2,[HXRSSBPM,HXRSSBPM]-FirstBPM+1-1,XL,'k'); plot(handles.axes2,[HXRSSBPM+1,HXRSSBPM+1]-FirstBPM+1-1,XL,'k');
% plot(handles.axes2,[SXRSSBPM,SXRSSBPM]-FirstBPM+1-1,YL,'k'); plot(handles.axes2,[SXRSSBPM+1,SXRSSBPM+1]-FirstBPM+1-1,YL,'k');
% plot(handles.axes1,[HXRSSBPM,HXRSSBPM]-FirstBPM+1-1,XL,'k'); plot(handles.axes1,[HXRSSBPM+1,HXRSSBPM+1]-FirstBPM+1-1,XL,'k');
% 
% xlim(handles.axes1,[1,LastBPM-FirstBPM+1]); xlim(handles.axes2,[1,LastBPM-FirstBPM+1]);
% ylim(handles.axes1,YL); ylim(handles.axes2,XL);


% --- Executes on button press in pushbutton60.
function pushbutton60_Callback(hObject, eventdata, handles)
Times=str2num(get(handles.TimeMeasured,'string'));
PE=str2num(get(handles.PhotonEnergy,'string'));
Flat=str2num(get(handles.FLAT,'string'));
Shift=str2num(get(handles.SHIFT,'string'));
SXRSSShift=Shift(1);
HXRSSShift=Shift(2);
WLM=str2num(get(handles.SLOPE,'string'));
FlatModules=str2num(get(handles.FixedModule,'string'));
QuickAdjust=str2num(get(handles.Adjust,'string'));  

Wavelength_femtoseconds=(1230/PE*10^-9)/(3*10^8);
Wavelength_undulator=(1230/PE*10^-9)/(3*10^8)*110;  %800as at 530
Wavelength_module=(1230/PE*10^-9)/(3*10^8)*WLM;

XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
FirstBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:100'));
BEFSXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:890'));
AFTERSXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:990'));
BEFHXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:1590'));
AFTERHXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:1690'));
LastBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:3390'));
DumpBPM=find(strcmp(handles.BPM.FullNames,'BPMS:DMP1:693'));

LasingLocation=polyfit([Times(1),Times(2),Times(3)],[Times(4),Times(5),Times(6)],2);

for II=FirstBPM:LastBPM
   BaseOrbitX(II-FirstBPM+1)=XB{II,3};
   BaseOrbitY(II-FirstBPM+1)=YB{II,3};
end

NewOrbitX=[];
NewOrbitY=[];

for II=FirstBPM:BEFSXRSSBPM
    NewOrbitX(II-FirstBPM+1)=-BaseOrbitX(II-FirstBPM+1)*Flat(1);
    NewOrbitY(II-FirstBPM+1)=-BaseOrbitY(II-FirstBPM+1)*Flat(1);
end

Inserted=0;
Time=linspace(0,max(Times(1:3)*4),7000);

PCHIP=pchip(polyval(LasingLocation,Time),Time);
A=figure;
AXA=axes;
plot(AXA,polyval(LasingLocation,Time),Time);
xlim(AXA,[-4,4])
StartingTime=ppval(PCHIP,Flat(1))
TimeShift=Wavelength_module*FlatModules*10^15*QuickAdjust

%NewTimes=StartingTime-SXRSSShift-(0:25)*TimeShift;

%NewOrbitsToPlugIN=polyval(LasingLocation,NewTimes);
CurrentTime=StartingTime-SXRSSShift*QuickAdjust
NewOrbitsToPlugIN=polyval(LasingLocation,CurrentTime)

for II=AFTERSXRSSBPM:LastBPM
    if(II~=AFTERHXRSSBPM)
        disp('REG')
        Inserted=Inserted+1;
        NewOrbitX(II-FirstBPM+1)=-BaseOrbitX(II-FirstBPM+1)*NewOrbitsToPlugIN;
        NewOrbitY(II-FirstBPM+1)=-BaseOrbitY(II-FirstBPM+1)*NewOrbitsToPlugIN;
        if(mod(Inserted,FlatModules)==0) %this should move to the next step for fresh electrons
            CurrentTime=CurrentTime-TimeShift
            NewOrbitsToPlugIN=polyval(LasingLocation,CurrentTime)
        end
    else
       disp('HXRSS')
       CurrentTime=CurrentTime-HXRSSShift*QuickAdjust
       NewOrbitsToPlugIN=polyval(LasingLocation,CurrentTime) 
       NewOrbitX(II-FirstBPM+1)=-BaseOrbitX(II-FirstBPM+1)*NewOrbitsToPlugIN;
       NewOrbitY(II-FirstBPM+1)=-BaseOrbitY(II-FirstBPM+1)*NewOrbitsToPlugIN;
    end
end

XB=get(handles.XB,'data'); YB=get(handles.YB,'data');

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,10}=NewOrbitX(II-FirstBPM+1);
    YB{II,10}=NewOrbitY(II-FirstBPM+1);
    XB{II,2}=true;
    YB{II,2}=true;
end

includeDump=get(handles.checkbox7,'value');

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,10}=XB{II,3};
        YB{II,10}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end

XC=get(handles.XC,'data');
YC=get(handles.YC,'data');

FirstXC=find(strcmp(handles.XCOR.Fullname,'XCOR:LTU1:818'));
LastXC=find(strcmp(handles.XCOR.Fullname,'XCOR:UND1:3380'));
DumpXC=find(strcmp(handles.XCOR.Fullname,'XCOR:DMP1:602'));

FirstYC=find(strcmp(handles.YCOR.Fullname,'YCOR:LTU1:837'));
LastYC=find(strcmp(handles.YCOR.Fullname,'YCOR:UND1:3380'));
DumpYC=find(strcmp(handles.YCOR.Fullname,'YCOR:DMP1:440'));

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC

    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end

set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',8);


% --- Executes on button press in pushbutton61.
function pushbutton61_Callback(hObject, eventdata, handles)
Times=str2num(get(handles.TimeMeasured,'string'));
PE=str2num(get(handles.PhotonEnergy,'string'));
Flat=str2num(get(handles.FLAT,'string'));
Shift=str2num(get(handles.SHIFT,'string'));
SXRSSShift=Shift(1);
HXRSSShift=Shift(2);
WLM=str2num(get(handles.SLOPE,'string'));
FlatModules=str2num(get(handles.FixedModule,'string'));
QuickAdjust=str2num(get(handles.Adjust,'string'));  

Wavelength_femtoseconds=(1230/PE*10^-9)/(3*10^8);
Wavelength_undulator=(1230/PE*10^-9)/(3*10^8)*110;  %800as at 530
Wavelength_module=(1230/PE*10^-9)/(3*10^8)*WLM;

XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
FirstBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:100'));
BEFSXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:890'));
AFTERSXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:990'));
BEFHXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:1590'));
AFTERHXRSSBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:1690'));
LastBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:3390'));

LasingLocation=polyfit([Times(1),Times(2),Times(3)],[Times(4),Times(5),Times(6)],2);

for II=FirstBPM:LastBPM
   BaseOrbitX(II-FirstBPM+1)=XB{II,3};
   BaseOrbitY(II-FirstBPM+1)=YB{II,3};
end

NewOrbitX=[];
NewOrbitY=[];

for II=FirstBPM:BEFSXRSSBPM
    NewOrbitX(II-FirstBPM+1)=-BaseOrbitX(II-FirstBPM+1)*Flat(1);
    NewOrbitY(II-FirstBPM+1)=-BaseOrbitY(II-FirstBPM+1)*Flat(1);
end

Inserted=0;
Time=linspace(0,max(Times(1:3)*4),7000);

PCHIP=pchip(polyval(LasingLocation,Time),Time);
A=figure;
AXA=axes;
plot(AXA,polyval(LasingLocation,Time),Time);
xlim(AXA,[-4,4])
StartingTime=ppval(PCHIP,Flat(1));
TimeShift=Wavelength_module*FlatModules*10^15*QuickAdjust;

%NewTimes=StartingTime-SXRSSShift-(0:25)*TimeShift;

%NewOrbitsToPlugIN=polyval(LasingLocation,NewTimes);
CurrentTime=StartingTime-SXRSSShift*QuickAdjust;
NewOrbitsToPlugIN=polyval(LasingLocation,CurrentTime);

for II=AFTERSXRSSBPM:LastBPM
    if(II~=AFTERHXRSSBPM)
        Inserted=Inserted+1;
        NewOrbitX(II-FirstBPM+1)=-BaseOrbitX(II-FirstBPM+1)*NewOrbitsToPlugIN;
        NewOrbitY(II-FirstBPM+1)=-BaseOrbitY(II-FirstBPM+1)*NewOrbitsToPlugIN;
        if(mod(Inserted,FlatModules)==0) %this should move to the next step for fresh electrons
            CurrentTime=CurrentTime-TimeShift;
            NewOrbitsToPlugIN=polyval(LasingLocation,CurrentTime);
        end
    else
       CurrentTime=CurrentTime-HXRSSShift*QuickAdjust;
       NewOrbitsToPlugIN=polyval(LasingLocation,CurrentTime); 
    end
end

XB=get(handles.XB,'data'); YB=get(handles.YB,'data');

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    XB{II,11}=NewOrbitX(II-FirstBPM+1);
    YB{II,11}=NewOrbitY(II-FirstBPM+1);
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,11}=XB{II,3};
        YB{II,11}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end

XC=get(handles.XC,'data');
YC=get(handles.YC,'data');

FirstXC=find(strcmp(handles.XCOR.Fullname,'XCOR:LTU1:818'));
LastXC=find(strcmp(handles.XCOR.Fullname,'XCOR:UND1:3380'));
DumpXC=find(strcmp(handles.XCOR.Fullname,'XCOR:DMP1:602'));

FirstYC=find(strcmp(handles.YCOR.Fullname,'YCOR:LTU1:837'));
LastYC=find(strcmp(handles.YCOR.Fullname,'YCOR:UND1:3380'));
DumpYC=find(strcmp(handles.YCOR.Fullname,'YCOR:DMP1:440'));

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC

    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end

set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',9);


% --- Executes on button press in pushbutton62.
function pushbutton62_Callback(hObject, eventdata, handles)
try COEFF(1)=str2num(get(handles.edit62,'string')); catch, COEFF(1)=NaN; end
try COEFF(2)=str2num(get(handles.edit63,'string')); catch, COEFF(2)=NaN; end
try COEFF(3)=str2num(get(handles.edit64,'string')); catch, COEFF(3)=NaN; end
try COEFF(4)=str2num(get(handles.edit65,'string')); catch, COEFF(4)=NaN; end
try COEFF(5)=str2num(get(handles.edit66,'string')); catch, COEFF(5)=NaN; end
SWITCH(1)=get(handles.popupmenu17,'value');
SWITCH(2)=get(handles.popupmenu18,'value');
SWITCH(3)=get(handles.popupmenu19,'value');
SWITCH(4)=get(handles.popupmenu20,'value');
SWITCH(SWITCH>length(handles.BPM.SwitchPosition))=[];
includeDump=get(handles.checkbox7,'value');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');XC=get(handles.XC,'data');YC=get(handles.YC,'data');

FirstBPM=handles.BPM.UND(1);
LastBPM=handles.BPM.UND(end);
DumpBPM=handles.BPM.DMP(end);

FirstXC=handles.XCOR.UND(1)-3;
LastXC=handles.XCOR.UND(end);
DumpXC=handles.XCOR.DMP(end);

FirstYC=handles.YCOR.UND(1)-3;
LastYC=handles.YCOR.UND(end);
DumpYC=handles.YCOR.DMP(end);

SwitchBPM=handles.BPM.SwitchPosition(SWITCH);

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    IDCOEFF=find(II<SwitchBPM,1,'first');
    if(isempty(IDCOEFF))
        IDCOEFF=length(SwitchBPM)+1;
    end
    XB{II,9}=XB{II,3}*COEFF(IDCOEFF);
    YB{II,9}=YB{II,3}*COEFF(IDCOEFF);
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,9}=XB{II,3};
        YB{II,9}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end
%Set desired correctors for steering

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',8);


% --- Executes on button press in pushbutton63.
function pushbutton63_Callback(hObject, eventdata, handles)
COEFF1=str2num(get(handles.Marinelli1,'string'));
COEFF2=str2num(get(handles.Marinelli2,'string'));
COEFF3=str2num(get(handles.Marinelli3,'string'));
SWITCH=round(str2num(get(handles.edit29,'string')));
includeDump=get(handles.checkbox7,'value');
Location=get(handles.Location,'value');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');XC=get(handles.XC,'data');YC=get(handles.YC,'data');

SwitchBPMs='BPMS:UND1:990';
SWITCHPOSs='BPMS:UND1:1690';

FirstBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:100'));
SwitchBPM=find(strcmp(handles.BPM.FullNames,SwitchBPMs));
LastBPM=find(strcmp(handles.BPM.FullNames,'BPMS:UND1:3390'));
DumpBPM=find(strcmp(handles.BPM.FullNames,'BPMS:DMP1:693'));
SWITCHPOS=find(strcmp(handles.BPM.FullNames,SWITCHPOSs));

FirstXC=find(strcmp(handles.XCOR.Fullname,'XCOR:LTU1:818'));
LastXC=find(strcmp(handles.XCOR.Fullname,'XCOR:UND1:3380'));
DumpXC=find(strcmp(handles.XCOR.Fullname,'XCOR:DMP1:602'));

FirstYC=find(strcmp(handles.YCOR.Fullname,'YCOR:LTU1:837'));
LastYC=find(strcmp(handles.YCOR.Fullname,'YCOR:UND1:3380'));
DumpYC=find(strcmp(handles.YCOR.Fullname,'YCOR:DMP1:440'));

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=FirstBPM:LastBPM
    if(II<SwitchBPM)
        XB{II,10}=XB{II,3}*COEFF1;
        YB{II,10}=YB{II,3}*COEFF1;
    elseif(II<SWITCHPOS)
        XB{II,10}=-XB{II,3}*COEFF2;
        YB{II,10}=-YB{II,3}*COEFF2;
    else
        XB{II,10}=XB{II,3}*COEFF3;
        YB{II,10}=YB{II,3}*COEFF3;
    end
    XB{II,2}=true;
    YB{II,2}=true;
end

if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,10}=XB{II,3};
        YB{II,10}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end
%Set desired correctors for steering

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end
set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',8);



function Marinelli1_Callback(hObject, eventdata, handles)
% hObject    handle to Marinelli1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Marinelli1 as text
%        str2double(get(hObject,'String')) returns contents of Marinelli1 as a double


% --- Executes during object creation, after setting all properties.
function Marinelli1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Marinelli1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Marinelli2_Callback(hObject, eventdata, handles)
% hObject    handle to Marinelli2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Marinelli2 as text
%        str2double(get(hObject,'String')) returns contents of Marinelli2 as a double


% --- Executes during object creation, after setting all properties.
function Marinelli2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Marinelli2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Marinelli3_Callback(hObject, eventdata, handles)
% hObject    handle to Marinelli3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Marinelli3 as text
%        str2double(get(hObject,'String')) returns contents of Marinelli3 as a double


% --- Executes during object creation, after setting all properties.
function Marinelli3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Marinelli3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PAR1_Callback(hObject, eventdata, handles)
% hObject    handle to PAR1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PAR1 as text
%        str2double(get(hObject,'String')) returns contents of PAR1 as a double


% --- Executes during object creation, after setting all properties.
function PAR1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PAR1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PAR2_Callback(hObject, eventdata, handles)
% hObject    handle to PAR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PAR2 as text
%        str2double(get(hObject,'String')) returns contents of PAR2 as a double


% --- Executes during object creation, after setting all properties.
function PAR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PAR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PAR3_Callback(hObject, eventdata, handles)
% hObject    handle to PAR3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PAR3 as text
%        str2double(get(hObject,'String')) returns contents of PAR3 as a double


% --- Executes during object creation, after setting all properties.
function PAR3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PAR3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PAR4_Callback(hObject, eventdata, handles)
% hObject    handle to PAR4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PAR4 as text
%        str2double(get(hObject,'String')) returns contents of PAR4 as a double


% --- Executes during object creation, after setting all properties.
function PAR4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PAR4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PAR5_Callback(hObject, eventdata, handles)
% hObject    handle to PAR5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PAR5 as text
%        str2double(get(hObject,'String')) returns contents of PAR5 as a double


% --- Executes during object creation, after setting all properties.
function PAR5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PAR5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeMeasured_Callback(hObject, eventdata, handles)
% hObject    handle to TimeMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeMeasured as text
%        str2double(get(hObject,'String')) returns contents of TimeMeasured as a double


% --- Executes during object creation, after setting all properties.
function TimeMeasured_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeMeasured (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PhotonEnergy_Callback(hObject, eventdata, handles)
% hObject    handle to PhotonEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PhotonEnergy as text
%        str2double(get(hObject,'String')) returns contents of PhotonEnergy as a double


% --- Executes during object creation, after setting all properties.
function PhotonEnergy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PhotonEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FLAT_Callback(hObject, eventdata, handles)
% hObject    handle to FLAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FLAT as text
%        str2double(get(hObject,'String')) returns contents of FLAT as a double


% --- Executes during object creation, after setting all properties.
function FLAT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FLAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SHIFT_Callback(hObject, eventdata, handles)
% hObject    handle to SHIFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SHIFT as text
%        str2double(get(hObject,'String')) returns contents of SHIFT as a double


% --- Executes during object creation, after setting all properties.
function SHIFT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SHIFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SLOPE_Callback(hObject, eventdata, handles)
% hObject    handle to SLOPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SLOPE as text
%        str2double(get(hObject,'String')) returns contents of SLOPE as a double


% --- Executes during object creation, after setting all properties.
function SLOPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SLOPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FixedModule_Callback(hObject, eventdata, handles)
% hObject    handle to FixedModule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FixedModule as text
%        str2double(get(hObject,'String')) returns contents of FixedModule as a double


% --- Executes during object creation, after setting all properties.
function FixedModule_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FixedModule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Adjust_Callback(hObject, eventdata, handles)
% hObject    handle to Adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Adjust as text
%        str2double(get(hObject,'String')) returns contents of Adjust as a double


% --- Executes during object creation, after setting all properties.
function Adjust_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Adjust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PublishOrbit.
function PublishOrbit_Callback(hObject, eventdata, handles)
TargetInformation=zeros(10000,1);
SteerX=get(handles.SteerX,'value');
SteerY=get(handles.SteerY,'value');
set(handles.READBPM,'backgroundcolor',handles.ColorYellow);
drawnow
SVDC=get(handles.SVDC,'value');
WRITE=get(handles.WRITE,'value');
XC=get(handles.XC,'data');YC=get(handles.YC,'data');XB=get(handles.XB,'data');YB=get(handles.YB,'data');
TrueXC=[XC{:,2}];TrueYC=[YC{:,2}];TrueXB=[XB{:,2}];TrueYB=[YB{:,2}];
TargetX=[XB{:,2+SVDC}];TargetY=[YB{:,2+SVDC}];
TrueB=TrueXB|TrueYB;
REGXC={handles.XCOR.Fullname{TrueXC}};
region={};
for II=1:numel(REGXC)
    region{end+1}=REGXC{II}(6:end);
end
REGYC={handles.YCOR.Fullname{TrueYC}};
for II=1:numel(REGYC)
    region{end+1}=REGYC{II}(6:end);
end
REGB={handles.BPM.FullNames{TrueB}};
for II=1:numel(REGB)
    region{end+1}=REGB{II}(6:end);
end
static=bba_simulInit('sector',region);
READBPM=handles.READBPM;
FSIZE=(numel(handles.READBUFFER)-3)/3;
SSIZE=sum(double(TrueB));
READBUFFER={handles.READBUFFER{[TrueB,TrueB,TrueB,true,true,true]}};
TargetInformation=lcaGetSmart('SIOC:SYS0:ML00:FWF73');
TargetInformation(1:length(TargetX))=TargetX;
TargetInformation(length(TargetX)+1)=-500;
TargetInformation((length(TargetX)+2):(2*length(TargetX)+1))=TrueXB;
TargetInformation(2*length(TargetX)+2)=-500;
TargetInformation((2*length(TargetX)+3):(3*length(TargetX)+2))=TargetY;
TargetInformation(3*length(TargetX)+3)=-500;
TargetInformation((3*length(TargetX)+4):(4*length(TargetX)+3))=TrueYB;
TargetInformation(4*length(TargetX)+4)=-500;
lcaPutSmart('SIOC:SYS0:ML00:FWF73',TargetInformation);
TargetY
save TEMP TargetInformation TargetY
XCOR=handles.XCOR;
YCOR=handles.YCOR;
BPM=handles.BPM;
DATA=datestr(now);
DATA=regexprep(DATA,' ','_');
DATA=regexprep(DATA,':','_');
save(['/u1/lcls/matlab/VOM_Configs/Steering_Configs/STEER_CONF_',DATA],'static','READBPM','FSIZE','SSIZE','READBUFFER','TargetInformation','XC','YC','XB','YB','XCOR','YCOR','BPM','TargetX','TargetY','TrueB','TrueXB','TrueYB','TrueXC','TrueYC','SteerX','SteerY');



function Exlude_Callback(hObject, eventdata, handles)
% hObject    handle to Exlude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Exlude as text
%        str2double(get(hObject,'String')) returns contents of Exlude as a double


% --- Executes during object creation, after setting all properties.
function Exlude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Exlude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton65.
function pushbutton65_Callback(hObject, eventdata, handles)
FILENAME='/home/physics/aal/OP_GIED/MarcOrbits/show2orbit.mat';
MUL=str2num(get(handles.Mulfactor,'string'));
data=load(FILENAME);
Y=data.Init.('$\eta_y$');
X=data.Init.('$\eta_x$');
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');
XPos=find(strcmp(XB(:,1),'BPMS:UND1:100:X'));
YPos=find(strcmp(YB(:,1),'BPMS:UND1:100:Y'));
for XX=1:length(X) % XPos:(XPos+length(data.data.data(ID).x)-1)
    XB{XPos+XX-1,3}=X(XX)/1000*MUL;
end

set(handles.XB,'data',XB);
%save TEMP
for YY=1:length(Y) % XPos:(XPos+length(data.data.data(ID).x)-1)
    YB{YPos+YY-1,3}=Y(YY)/1000*MUL;
end
set(handles.YB,'data',YB);


% --- Executes on button press in FINALEX.
function FINALEX_Callback(hObject, eventdata, handles)
REGIONS=str2num(get(handles.FreeOrbit1,'string'));
COEFFICIENTS=str2num(get(handles.FreeOrbit2,'string'));
XB=get(handles.XB,'data'); YB=get(handles.YB,'data');XC=get(handles.XC,'data');YC=get(handles.YC,'data');
Radio1=get(handles.Radio1,'value');
Radio2=get(handles.Radio2,'value');

[SA,SB]=size(REGIONS);
[SA1,SB1]=size(COEFFICIENTS);

if((SA~=SA1) || (SB~=SB1))
    disp('Wrong size of coefficients')
end

FirstBPM=find(strcmp(handles.BPM.FullNames,['BPMS:UND1:',num2str(REGIONS(1,1))]));

for II=1:(FirstBPM-1)
    XB{II,2}=false;
    YB{II,2}=false;
end

for II=1:SA
   %finds starts and end. 
   StartBPM=find(strcmp(handles.BPM.FullNames,['BPMS:UND1:',num2str(REGIONS(II,1))]))
   EndBPM=find(strcmp(handles.BPM.FullNames,['BPMS:UND1:',num2str(REGIONS(II,2))]))
   if ((II==SA) && Radio2)
       LISTACOEFFICIENTI=linspace(COEFFICIENTS(II,1),COEFFICIENTS(II,2),length(StartBPM:EndBPM));
       for JJ=StartBPM:EndBPM
           XB{JJ,10}=XB{JJ,11}*LISTACOEFFICIENTI(JJ-StartBPM+1);
           YB{JJ,10}=YB{JJ,11}*LISTACOEFFICIENTI(JJ-StartBPM+1);
           XB{JJ,2}=true;
           YB{JJ,2}=true;
       end 
   else
       LISTACOEFFICIENTI=linspace(COEFFICIENTS(II,1),COEFFICIENTS(II,2),length(StartBPM:EndBPM));
       for JJ=StartBPM:EndBPM
           XB{JJ,10}=XB{JJ,3}*LISTACOEFFICIENTI(JJ-StartBPM+1);
           YB{JJ,10}=YB{JJ,3}*LISTACOEFFICIENTI(JJ-StartBPM+1);
           XB{JJ,2}=true;
           YB{JJ,2}=true;
       end
   end
       
end

LastBPM=find(strcmp(handles.BPM.FullNames,['BPMS:UND1:',num2str(REGIONS(SA,2))]));

includeDump=get(handles.checkbox7,'value');

DumpBPM=find(strcmp(handles.BPM.FullNames,'BPMS:DMP1:693'));

FirstXC=find(strcmp(handles.XCOR.Fullname,'XCOR:LTU1:818'));
LastXC=find(strcmp(handles.XCOR.Fullname,'XCOR:UND1:3380'));
DumpXC=find(strcmp(handles.XCOR.Fullname,'XCOR:DMP1:602'));

FirstYC=find(strcmp(handles.YCOR.Fullname,'YCOR:LTU1:837'));
LastYC=find(strcmp(handles.YCOR.Fullname,'YCOR:UND1:3380'));
DumpYC=find(strcmp(handles.YCOR.Fullname,'YCOR:DMP1:440'));


if(includeDump)
    for II=(LastBPM+1):DumpBPM
        XB{II,10}=XB{II,3};
        YB{II,10}=YB{II,3};
        XB{II,2}=true;
        YB{II,2}=true;
    end
else
    for II=(LastBPM+1):DumpBPM
        XB{II,2}=false;
        YB{II,2}=false;
    end
end
%Set desired correctors for steering

for II=1:DumpXC
   if(II<FirstXC)
       XC{II,2}=false;
   elseif(II<(LastXC+1))
       XC{II,2}=true;
   else
       if(includeDump)
           XC{II,2}=true;
       else
           XC{II,2}=false;
       end 
   end
end

for II=1:DumpYC
    if(II<FirstYC)
       YC{II,2}=false;
   elseif(II<(LastYC+1))
       YC{II,2}=true;
   else
       if(includeDump)
           YC{II,2}=true;
       else
           YC{II,2}=false;
       end 
    end
end

set(handles.XC,'data',XC);set(handles.YC,'data',YC);set(handles.XB,'data',XB);set(handles.YB,'data',YB);
set(handles.SVDC,'value',8);



function FreeOrbit1_Callback(hObject, eventdata, handles)
% hObject    handle to FreeOrbit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FreeOrbit1 as text
%        str2double(get(hObject,'String')) returns contents of FreeOrbit1 as a double


% --- Executes during object creation, after setting all properties.
function FreeOrbit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FreeOrbit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FreeOrbit2_Callback(hObject, eventdata, handles)
% hObject    handle to FreeOrbit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FreeOrbit2 as text
%        str2double(get(hObject,'String')) returns contents of FreeOrbit2 as a double


% --- Executes during object creation, after setting all properties.
function FreeOrbit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FreeOrbit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Radio1.
function Radio1_Callback(hObject, eventdata, handles)
set(handles.Radio1,'value',1);
set(handles.Radio2,'value',0);


% --- Executes on button press in Radio2.
function Radio2_Callback(hObject, eventdata, handles)
set(handles.Radio1,'value',0);
set(handles.Radio2,'value',1);


% --- Executes during object creation, after setting all properties.
function Radio2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Radio2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function Mulfactor_Callback(hObject, eventdata, handles)
% hObject    handle to Mulfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Mulfactor as text
%        str2double(get(hObject,'String')) returns contents of Mulfactor as a double


% --- Executes during object creation, after setting all properties.
function Mulfactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mulfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton67.
function pushbutton67_Callback(hObject, eventdata, handles)
lcaPutSmart('SIOC:SYS0:ML02:AO393',1);



function edit57_Callback(hObject, eventdata, handles)
% hObject    handle to edit57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit57 as text
%        str2double(get(hObject,'String')) returns contents of edit57 as a double


% --- Executes during object creation, after setting all properties.
function edit57_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in pushbutton68.
function pushbutton68_Callback(hObject, eventdata, handles)
Lista=eval(get(handles.edit57,'string'));
ListaY=eval(get(handles.edit60,'string'));
XC=get(handles.XC,'data');
[SA,SB]=size(XC);
if(get(handles.checkbox16,'value'))
    for II=1:SA
        if(any(Lista==II))
            XC{II,2}=true;
        else
            XC{II,2}=false;
        end
    end
else
    for II=1:SA
        XC{II,2}=false;
    end
end
YC=get(handles.YC,'data');
[SA,SB]=size(YC);
if(get(handles.checkbox17,'value'))
    for II=1:SA
        if(any(ListaY==II))
            YC{II,2}=true;
        else
            YC{II,2}=false;
        end
    end
else
    for II=1:SA
        YC{II,2}=false;
    end
end
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);




function edit58_Callback(hObject, eventdata, handles)
% hObject    handle to edit58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit58 as text
%        str2double(get(hObject,'String')) returns contents of edit58 as a double


% --- Executes during object creation, after setting all properties.
function edit58_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on button press in pushbutton69.
function pushbutton69_Callback(hObject, eventdata, handles)
Lista=eval(get(handles.edit58,'string'));
ListaY=eval(get(handles.edit61,'string'));
XB=get(handles.XB,'data');
[SA,SB]=size(XB);
if(get(handles.checkbox18,'value'))
    for II=1:SA
        if(any(Lista==II))
            XB{II,2}=true;
        else
            XB{II,2}=false;
        end
    end
else
    for II=1:SA
        XB{II,2}=false;
    end
end

set(handles.XB,'data',XB);

YB=get(handles.YB,'data');
[SA,SB]=size(YB);
if(get(handles.checkbox19,'value'))
    for II=1:SA
        if(any(ListaY==II))
            YB{II,2}=true;
        else
            YB{II,2}=false;
        end
    end
else
    for II=1:SA
        YB{II,2}=false;
    end
end

set(handles.YB,'data',YB);


function edit59_Callback(hObject, eventdata, handles)
% hObject    handle to edit59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit59 as text
%        str2double(get(hObject,'String')) returns contents of edit59 as a double


% --- Executes during object creation, after setting all properties.
function edit59_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit59 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton70.
function pushbutton70_Callback(hObject, eventdata, handles)
XB=get(handles.XB,'data');
YB=get(handles.YB,'data');
CONFID=get(handles.AnotherBPMList,'value')+2;
MV=str2num(get(handles.edit59,'string'));
if(get(handles.ScaleX,'value'))
    [SA,SB]=size(XB);
    for II=1:SA
        if(XB{II,2})
            XB{II,CONFID}=XB{II,CONFID}*MV;
        end
    end
end
if(get(handles.ScaleY,'value'))
    [SA,SB]=size(YB);
    for II=1:SA
        if(YB{II,2})
            YB{II,CONFID}=YB{II,CONFID}*MV;
        end
    end
end
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

% --- Executes on selection change in AREA.
function handles=AREA_Callback(hObject, eventdata, handles)
AREA_ID=get(handles.AREA,'value');
handles.UL=handles.ULall(AREA_ID);
handles.AREA_ID=AREA_ID;
handles.BPM=handles.static(AREA_ID).BPM;
handles.XCOR=handles.static(AREA_ID).XCOR;
handles.YCOR=handles.static(AREA_ID).YCOR;
handles.READBUFFER=handles.static(AREA_ID).READBUFFER;

set(handles.pushbutton77,'enable','off','backgroundcolor',handles.ColorIdle);
set(handles.pushbutton78,'enable','off','backgroundcolor',handles.ColorIdle);
set(handles.pushbutton79,'enable','off','backgroundcolor',handles.ColorIdle);
set(handles.pushbutton80,'enable','off','backgroundcolor',handles.ColorIdle);
set(handles.pushbutton81,'enable','off','backgroundcolor',handles.ColorIdle);

switch AREA_ID
    case 1
        set(handles.edit57,'string','[18:54]');
        set(handles.edit60,'string','[19:55]');
        set(handles.edit58,'string','[33:67]');
        set(handles.edit61,'string','[33:67]');
        set(handles.AR,'string',{'Undulator','Undulator + Dump','Ltu + Undulator + Dump'});
        handles.BEAMCODE=1;
    case 2
        set(handles.edit57,'string','[16:45]');
        set(handles.edit60,'string','[17:46]');
        set(handles.edit58,'string','[34:61]');
        set(handles.edit61,'string','[34:61]');
        set(handles.AR,'string',{'Undulator','Undulator + Dump','Ltu + Undulator + Dump'});
        handles.BEAMCODE=2;
end

ColumnNamesCOR={'PV name','Use'};
ColumnNamesBPM={'PV name','Use'};
for II=1:handles.AVCONF
   ColumnNamesCOR{end+1}=['C-COR',num2str(II)]; 
   ColumnNamesBPM{end+1}=['C',num2str(II)]; 
end

handles.XCOR.DES=strcat(handles.XCOR.Fullname,':BDES');
handles.XCOR.SET=strcat(handles.XCOR.Fullname,':BCTRL');
handles.YCOR.DES=strcat(handles.YCOR.Fullname,':BDES');
handles.YCOR.SET=strcat(handles.YCOR.Fullname,':BCTRL');
XC={};YC={};XB={};YB={};
for II=1:numel(handles.XCOR.Fullname)
   XC{II,1}=handles.XCOR.Fullname{II};
   XC{II,2}=false;
   for TT=1:handles.AVCONF
       XC{II,2+TT}=0;
   end
end

for II=1:numel(handles.YCOR.Fullname)
   YC{II,1}=handles.YCOR.Fullname{II};
   YC{II,2}=false;
   for TT=1:handles.AVCONF
       YC{II,2+TT}=0;
   end
end

for II=1:numel(handles.BPM.Fullnamex)
   XB{II,1}=handles.BPM.Fullnamex{II};
   XB{II,2}=false;
   for TT=1:handles.AVCONF
       XB{II,2+TT}=0;
   end
end

for II=1:numel(handles.BPM.Fullnamey)
   YB{II,1}=handles.BPM.Fullnamey{II};
   YB{II,2}=false;
   for TT=1:handles.AVCONF
       YB{II,2+TT}=0;
   end
end

set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

set(handles.XC,'ColumnName',ColumnNamesCOR);
set(handles.YC,'ColumnName',ColumnNamesCOR);
set(handles.XB,'ColumnName',ColumnNamesBPM);
set(handles.YB,'ColumnName',ColumnNamesBPM);

COLXC=strfind(handles.XCOR.Fullname,':');
COLYC=strfind(handles.YCOR.Fullname,':');
COLXB=strfind(handles.BPM.Fullnamex,':');
COLYB=strfind(handles.BPM.Fullnamey,':');

for II=1:numel(COLXC)
    handles.XCOR.N1{II}=handles.XCOR.Fullname{II}(1:(COLXC{II}(1)-1));
    handles.XCOR.N2{II}=handles.XCOR.Fullname{II}((COLXC{II}(1)+1):(COLXC{II}(2)-1));
    handles.XCOR.N3{II}=handles.XCOR.Fullname{II}((COLXC{II}(2)+1):end);
    handles.XCOR.N3n(II)=str2num(handles.XCOR.Fullname{II}((COLXC{II}(2)+1):end));
    handles.XCOR.N4{II}='';
end

for II=1:numel(COLYC)
    handles.YCOR.N1{II}=handles.YCOR.Fullname{II}(1:(COLYC{II}(1)-1));
    handles.YCOR.N2{II}=handles.YCOR.Fullname{II}((COLYC{II}(1)+1):(COLYC{II}(2)-1));
    handles.YCOR.N3{II}=handles.YCOR.Fullname{II}((COLYC{II}(2)+1):end);
    handles.YCOR.N3n(II)=str2num(handles.YCOR.Fullname{II}((COLYC{II}(2)+1):end));
    handles.YCOR.N4{II}='';
end

for II=1:numel(COLXB)
    handles.BPM.XN1{II}=handles.BPM.Fullnamex{II}(1:(COLXB{II}(1)-1));
    handles.BPM.XN2{II}=handles.BPM.Fullnamex{II}((COLXB{II}(1)+1):(COLXB{II}(2)-1));
    handles.BPM.XN3{II}=handles.BPM.Fullnamex{II}((COLXB{II}(2)+1):(COLXB{II}(3)-1));
    handles.BPM.XN3n(II)=str2num(handles.BPM.Fullnamex{II}((COLXB{II}(2)+1):(COLXB{II}(3)-1)));
    handles.BPM.XN4{II}='X';
end

for II=1:numel(COLYB)
    handles.BPM.YN1{II}=handles.BPM.Fullnamex{II}(1:(COLYB{II}(1)-1));
    handles.BPM.YN2{II}=handles.BPM.Fullnamex{II}((COLYB{II}(1)+1):(COLYB{II}(2)-1));
    handles.BPM.YN3{II}=handles.BPM.Fullnamex{II}((COLYB{II}(2)+1):(COLYB{II}(3)-1));
    handles.BPM.YN3n(II)=str2num(handles.BPM.Fullnamex{II}((COLYB{II}(2)+1):(COLYB{II}(3)-1)));
    handles.BPM.YN4{II}='Y';
end

set(handles.XB,'ColumnEditable',handles.ColumnEditable);
set(handles.YB,'ColumnEditable',handles.ColumnEditable);

set(handles.READCORL,'string',ColumnNamesCOR(3:end)); set(handles.READCORL,'value',1);
set(handles.SETCORRC,'string',ColumnNamesCOR(3:end)); set(handles.SETCORRC,'value',1);
set(handles.ReadCO,'string',ColumnNamesBPM(3:end)); set(handles.ReadCO,'value',1);
set(handles.SVDC,'string',ColumnNamesBPM(3:end)); set(handles.SVDC,'value',1);
set(handles.AnotherBPMList,'string',ColumnNamesBPM(3:end)); set(handles.AnotherBPMList,'value',1);
set(handles.popupmenu11,'string',ColumnNamesBPM(3:end)); set(handles.popupmenu11,'value',1);

Names={};
handles.BPM.chicane=[];
handles.BPM.SwitchPosition=[];

switch(AREA_ID)
    case 1
        handles.BPM.chicane(1)=find(strcmp(handles.BPM.FullNames,'BPMS:UNDH:2890'));
        handles.BPM.chicane(2)=find(strcmp(handles.BPM.FullNames,'BPMS:UNDH:2190'));
        Names{1}='Second Chicane';
        Names{2}='First Chicane';
        XCORLOC=-13;
        YCORLOC=-12;
    case 2
        handles.BPM.chicane(1)=find(strcmp(handles.BPM.FullNames,'BPMS:UNDS:3590'));
        Names{1}='Chicane';
        XCORLOC=-16;
        YCORLOC=-15;
end

handles.BPM.SwitchPosition = handles.BPM.chicane;
Names=[Names,handles.BPM.XN3(handles.BPM.UND(2:end))];
handles.BPM.SwitchPosition = [handles.BPM.SwitchPosition,handles.BPM.UND(2:end)];
set(handles.Location,'string',Names); set(handles.Location,'value',1);
set(handles.L2,'string',Names); set(handles.L2,'value',1);
handles.XCOR.SwitchPosition=handles.BPM.SwitchPosition+XCORLOC;
handles.YCOR.SwitchPosition=handles.BPM.SwitchPosition+YCORLOC;

CF=Names;
CF{end+1}='Not in Use';
set(handles.popupmenu17,'string',CF); set(handles.popupmenu17,'value',round(length(CF)/3));
set(handles.popupmenu18,'string',CF); set(handles.popupmenu18,'value',round(2*length(CF)/3));
set(handles.popupmenu19,'string',CF); set(handles.popupmenu19,'value',length(CF));
set(handles.popupmenu20,'string',CF); set(handles.popupmenu20,'value',length(CF));
set(handles.edit62,'string','-1'); set(handles.edit63,'string','0'); set(handles.edit64,'string','+1');
set(handles.edit65,'string',''); set(handles.edit66,'string','');

BumpTable{1,1}='bump'; BumpTable{1,2}='[-1:4]'; BumpTable{1,3}='max'; BumpTable{1,4}='x';
BumpTable{2,1}='flat'; BumpTable{2,2}='15'; BumpTable{2,3}='max'; BumpTable{2,4}='x';
handles.s=handles.static(AREA_ID);
[~,handles.XCOR.TableToStatic,~]=intersect(handles.s.corrList,handles.XCOR.LIST,'stable');
[~,handles.YCOR.TableToStatic,~]=intersect(handles.s.corrList,handles.YCOR.LIST,'stable');
[~,handles.BPM.TableToStatic,~]=intersect(handles.s.bpmList,handles.BPM.LIST,'stable');

set(handles.CorrStartX,'string',handles.XCOR.Fullname); set(handles.CorrStartY,'string',handles.YCOR.Fullname);
set(handles.BPMCloseX,'string',handles.s.BPM.FullNames); set(handles.BPMCloseY,'string',handles.s.BPM.FullNames);
set(handles.RevBPM1X,'string',handles.s.BPM.FullNames); set(handles.RevBPM2X,'string',handles.s.BPM.FullNames);
set(handles.RevBPM1Y,'string',handles.s.BPM.FullNames); set(handles.RevBPM2Y,'string',handles.s.BPM.FullNames);

switch AREA_ID
    case 1
        set(handles.CorrStartX,'value',19)
        set(handles.CorrStartY,'value',20)
        set(handles.BPMCloseX,'value',67)
        set(handles.RevBPM1X,'value',33)
        set(handles.RevBPM2X,'value',66)
        set(handles.BPMCloseY,'value',67)
        set(handles.RevBPM1Y,'value',33)
        set(handles.RevBPM2Y,'value',66)
    case 2
        set(handles.CorrStartX,'value',18)
        set(handles.CorrStartY,'value',19)
        set(handles.BPMCloseX,'value',54)
        set(handles.RevBPM1X,'value',31)
        set(handles.RevBPM2X,'value',52)
        set(handles.BPMCloseY,'value',54)
        set(handles.RevBPM1Y,'value',31)
        set(handles.RevBPM2Y,'value',52)
end

handles.s.corrRange(:,1)=lcaGetSmart(strcat(handles.s.corrList_e,':BMIN'));
handles.s.corrRange(:,2)=lcaGetSmart(strcat(handles.s.corrList_e,':BMAX'));

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function AREA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AREA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit60_Callback(hObject, eventdata, handles)
% hObject    handle to edit60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit60 as text
%        str2double(get(hObject,'String')) returns contents of edit60 as a double


% --- Executes during object creation, after setting all properties.
function edit60_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit60 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit61_Callback(hObject, eventdata, handles)
% hObject    handle to edit61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit61 as text
%        str2double(get(hObject,'String')) returns contents of edit61 as a double


% --- Executes during object creation, after setting all properties.
function edit61_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OvrY.
function OvrY_Callback(hObject, eventdata, handles)
% hObject    handle to OvrY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OvrY


% --- Executes on button press in XON.
function XON_Callback(hObject, eventdata, handles)
% hObject    handle to XON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of XON


% --- Executes on button press in pushbutton71.
function pushbutton71_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton72.
function pushbutton72_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit62_Callback(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit62 as text
%        str2double(get(hObject,'String')) returns contents of edit62 as a double


% --- Executes during object creation, after setting all properties.
function edit62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu17.
function popupmenu17_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu17 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu17


% --- Executes during object creation, after setting all properties.
function popupmenu17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit63_Callback(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit63 as text
%        str2double(get(hObject,'String')) returns contents of edit63 as a double


% --- Executes during object creation, after setting all properties.
function edit63_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu18.
function popupmenu18_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu18 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu18


% --- Executes during object creation, after setting all properties.
function popupmenu18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit64_Callback(hObject, eventdata, handles)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit64 as text
%        str2double(get(hObject,'String')) returns contents of edit64 as a double


% --- Executes during object creation, after setting all properties.
function edit64_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu19.
function popupmenu19_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu19 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu19


% --- Executes during object creation, after setting all properties.
function popupmenu19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit65_Callback(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit65 as text
%        str2double(get(hObject,'String')) returns contents of edit65 as a double


% --- Executes during object creation, after setting all properties.
function edit65_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu20.
function popupmenu20_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu20 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu20


% --- Executes during object creation, after setting all properties.
function popupmenu20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit66_Callback(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit66 as text
%        str2double(get(hObject,'String')) returns contents of edit66 as a double


% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RestoreDumpUiGetFile.
function RestoreDumpUiGetFile_Callback(hObject, eventdata, handles)
[FILENAME, PATHNAME] = uigetfile([handles.SaveDir,'/orbitPatchwork_save_*.*']);
load([PATHNAME,'/',FILENAME],'XC','YC','XB','YB','BPM','XCOR','YCOR','READBUFFER');
set(handles.XC,'data',XC);
set(handles.YC,'data',YC);
set(handles.XB,'data',XB);
set(handles.YB,'data',YB);

handles.BPM=BPM;
handles.XCOR=XCOR;
handles.YCOR=YCOR;
handles.READBUFFER=READBUFFER;

guidata(hObject, handles);


% --- Executes on button press in ScaleX.
function ScaleX_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ScaleX


% --- Executes on button press in ScaleY.
function ScaleY_Callback(hObject, eventdata, handles)
% hObject    handle to ScaleY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ScaleY


% --- Executes on selection change in AnotherBPMList.
function AnotherBPMList_Callback(hObject, eventdata, handles)
% hObject    handle to AnotherBPMList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AnotherBPMList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AnotherBPMList


% --- Executes during object creation, after setting all properties.
function AnotherBPMList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnotherBPMList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function pushbutton62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in AR.
function AR_Callback(hObject, eventdata, handles)
% hObject    handle to AR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AR contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AR


% --- Executes during object creation, after setting all properties.
function AR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton74.
function pushbutton74_Callback(hObject, eventdata, handles)
set(handles.pushbutton74,'BackgroundColor',handles.ColorYellow); drawnow
CloseAngles=get(handles.CloseAngles,'value');
CloseBump=get(handles.CloseBump,'value');
UseX=get(handles.SX,'value');
UseY=get(handles.SY,'value');
CorrStartX=get(handles.CorrStartX,'value');
CorrStartY=get(handles.CorrStartY,'value');
BPMEndX=get(handles.BPMCloseX,'value');
BPMEndY=get(handles.BPMCloseY,'value');
R1X=get(handles.RevBPM1X,'value');
R2X=get(handles.RevBPM2X,'value');
R1Y=get(handles.RevBPM1Y,'value');
R2Y=get(handles.RevBPM2Y,'value');
amountX=str2double(get(handles.ValueBX,'string'));
amountY=str2double(get(handles.ValueBY,'string'));
MaxOrbitX=get(handles.MaxOrbitX,'value');
MaxOrbitY=get(handles.MaxOrbitY,'value');

Options.closeAngle=CloseAngles;
Options.closeBump=CloseBump;

CorrMat=cell2mat(cellfun(@(x) x(1),handles.s.corrList,'un',0));
XCorrPos=CorrMat(:,1)=='X';
XCorrPos=find(XCorrPos);
YCorrPos=CorrMat(:,1)=='Y';
YCorrPos=find(YCorrPos);

S.X=[]; S.Y=[];
SizesStringX={'x=0','x=0','x=0','x=0'};
SizesYtringY={'y=0','y=0','y=0','y=0'};
if(UseX)
    if(MaxOrbitX)
        Options.size=amountX/1000000;
    else
        Options.size=amountX; 
    end
    Options.start=find(strcmp(handles.s.corrList_e(XCorrPos),handles.XCOR.Fullname(CorrStartX)));
    Options.end=find(strcmp(handles.s.bpmList_e,handles.BPM.FullNames(BPMEndX)));
    Options.RelevantBPM=false(size(handles.s.bpmList_e));
    SRX=find(strcmp(handles.s.bpmList_e,handles.BPM.FullNames(R1X)));
    ERX=find(strcmp(handles.s.bpmList_e,handles.BPM.FullNames(R2X)));
    Options.RelevantBPM(SRX:ERX)=true;
    Options.direction='X';
    if(~MaxOrbitX)
        Options.UseMaxExcursion=1;
    end
    SolX=handles.sf.orbitBump(handles.s(1),Options);
    AllUseCorrX=[];
    for KK=1:4
       SolX(KK).UseCorr=find( SolX(KK).NewCorrectors~=SolX(KK).OldCorrectors);
       S.X.PV{KK}=SolX(KK).CorrPVs(SolX(KK).UseCorr);
       S.X.Val{KK}=SolX(KK).NewCorrectors(SolX(KK).UseCorr);
       S.X.S(KK)=SolX(KK).Success;
       AllUseCorrX=[AllUseCorrX;SolX(KK).UseCorr];
       SizesStringX{KK}=['x=',num2str(round(1000*1000*SolX(KK).MaxExcursionRelevantBPM))];
    end
    AllUseCorrX=unique(AllUseCorrX);
    RestoreXPV=SolX(1).CorrPVs(AllUseCorrX);
    RestoreXVal=SolX(1).OldCorrectors(AllUseCorrX);
    S.X.RestorePV=RestoreXPV;
    S.X.RestoreVal=RestoreXVal; 
else
   SizesStringX{1}='X = 0';
   SizesStringX{2}='X = 0';
   SizesStringX{3}='X = 0';
   SizesStringX{4}='X = 0';
end
   
if(UseY)
    if(MaxOrbitY)
        Options.size=amountY/1000000;
    else
        Options.size=amountY; 
    end
    Options.start=find(strcmp(handles.s.corrList_e(YCorrPos),handles.YCOR.Fullname(CorrStartY)));
    Options.end=find(strcmp(handles.s.bpmList_e,handles.BPM.FullNames(BPMEndY)));
    Options.RelevantBPM=false(size(handles.s.bpmList_e));
    SRY=find(strcmp(handles.s.bpmList_e,handles.BPM.FullNames(R1Y)));
    ERY=find(strcmp(handles.s.bpmList_e,handles.BPM.FullNames(R2Y)));
    Options.RelevantBPM(SRY:ERY)=true;
    Options.direction='Y';
    if(~MaxOrbitY)
        Options.UseMaxExcursion=1;
    end
    SolY=handles.sf.orbitBump(handles.s(1),Options);
    AllUseCorrY=[];
    for KK=1:4
       SolY(KK).UseCorr=find( SolY(KK).NewCorrectors~=SolY(KK).OldCorrectors);
       S.Y.PV{KK}=SolY(KK).CorrPVs(SolY(KK).UseCorr);
       S.Y.Val{KK}=SolY(KK).NewCorrectors(SolY(KK).UseCorr);
       S.Y.S(KK)=SolY(KK).Success;
       AllUseCorrY=[AllUseCorrY;SolY(KK).UseCorr];
       SizesStringY{KK}=['Y=',num2str(round(1000*1000*SolY(KK).MaxExcursionRelevantBPM))];
    end
    AllUseCorrY=unique(AllUseCorrY);
    RestoreYPV=SolY(1).CorrPVs(AllUseCorrY);
    RestoreYVal=SolY(1).OldCorrectors(AllUseCorrY);
    S.Y.RestorePV=RestoreYPV;
    S.Y.RestoreVal=RestoreYVal; 
else
   SizesStringY{1}='Y = 0';
   SizesStringY{2}='Y = 0';
   SizesStringY{3}='Y = 0';
   SizesStringY{4}='Y = 0';
end

if(isempty(S.Y) && isempty(S.X))
       set(handles.pushbutton77,'enable','off','backgroundcolor',handles.ColorIdle);
       set(handles.pushbutton78,'enable','off','backgroundcolor',handles.ColorIdle);
       set(handles.pushbutton79,'enable','off','backgroundcolor',handles.ColorIdle);
       set(handles.pushbutton80,'enable','off','backgroundcolor',handles.ColorIdle);
       set(handles.pushbutton81,'enable','off','backgroundcolor',handles.ColorIdle);
else
       set(handles.pushbutton77,'enable','on'); set(handles.pushbutton77,'string',[SizesStringX{1},' ',SizesStringY{1}]);
       set(handles.pushbutton78,'enable','on'); set(handles.pushbutton78,'string',[SizesStringX{2},' ',SizesStringY{2}]);
       set(handles.pushbutton79,'enable','on'); set(handles.pushbutton79,'string',[SizesStringX{3},' ',SizesStringY{3}]);
       set(handles.pushbutton80,'enable','on'); set(handles.pushbutton80,'string',[SizesStringX{4},' ',SizesStringY{4}]);
       set(handles.pushbutton81,'enable','on');
end


for II=1:4
   if(isempty(S.Y) && isempty(S.X))
       return
   elseif(isempty(S.X))
       if(S.Y.S(II))
          set(handles.(['pushbutton',num2str(76+II)]),'backgroundcolor',handles.ColorGreen); 
       else
          set(handles.(['pushbutton',num2str(76+II)]),'backgroundcolor',handles.ColorRed); 
       end
   elseif(isempty(S.Y))
       if(S.X.S(II))
          set(handles.(['pushbutton',num2str(76+II)]),'backgroundcolor',handles.ColorGreen); 
       else
          set(handles.(['pushbutton',num2str(76+II)]),'backgroundcolor',handles.ColorRed); 
       end
   else
       if(S.Y.S(II) && S.X.S(II))
          set(handles.(['pushbutton',num2str(76+II)]),'backgroundcolor',handles.ColorGreen); 
       else
          set(handles.(['pushbutton',num2str(76+II)]),'backgroundcolor',handles.ColorRed); 
       end
   end
end

try
    S.X.RestorePV
    S.X.RestoreVal.'
end
try
    S.Y.RestorePV
    S.Y.RestoreVal.'
end
set(handles.pushbutton81,'userdata',S);
set(handles.pushbutton74,'BackgroundColor',handles.ColorIdle);


% --- Executes on selection change in popupmenu23.
function popupmenu23_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu23 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu23


% --- Executes during object creation, after setting all properties.
function popupmenu23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
set(handles.radiobutton3,'value',1); set(handles.radiobutton4,'value',0);


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
set(handles.radiobutton4,'value',1); set(handles.radiobutton3,'value',0);

function SN_Callback(hObject, eventdata, handles)
% hObject    handle to SN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SN as text
%        str2double(get(hObject,'String')) returns contents of SN as a double


% --- Executes during object creation, after setting all properties.
function SN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in WithOrWithout.
function WithOrWithout_Callback(hObject, eventdata, handles)
% hObject    handle to WithOrWithout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WithOrWithout contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WithOrWithout


% --- Executes during object creation, after setting all properties.
function WithOrWithout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WithOrWithout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit68_Callback(hObject, eventdata, handles)
% hObject    handle to edit68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit68 as text
%        str2double(get(hObject,'String')) returns contents of edit68 as a double


% --- Executes during object creation, after setting all properties.
function edit68_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit69_Callback(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit69 as text
%        str2double(get(hObject,'String')) returns contents of edit69 as a double


% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Restore.
function Restore_Callback(hObject, eventdata, handles)
set(handles.Restore,'enable','off');
Solution=get(handles.Restore,'userdata');
lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.OldCorrReset);


% --- Executes on selection change in CorrStartX.
function CorrStartX_Callback(hObject, eventdata, handles)
% hObject    handle to CorrStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CorrStartX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CorrStartX


% --- Executes during object creation, after setting all properties.
function CorrStartX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CorrStartX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SX.
function SX_Callback(hObject, eventdata, handles)
% hObject    handle to SX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SX


% --- Executes on selection change in BPMCloseX.
function BPMCloseX_Callback(hObject, eventdata, handles)
% hObject    handle to BPMCloseX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BPMCloseX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BPMCloseX


% --- Executes during object creation, after setting all properties.
function BPMCloseX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BPMCloseX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RevBPM1X.
function RevBPM1X_Callback(hObject, eventdata, handles)
% hObject    handle to RevBPM1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RevBPM1X contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RevBPM1X


% --- Executes during object creation, after setting all properties.
function RevBPM1X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RevBPM1X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RevBPM2X.
function RevBPM2X_Callback(hObject, eventdata, handles)
% hObject    handle to RevBPM2X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RevBPM2X contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RevBPM2X


% --- Executes during object creation, after setting all properties.
function RevBPM2X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RevBPM2X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaxOrbitX.
function MaxOrbitX_Callback(hObject, eventdata, handles)
set(handles.MaxOrbitX,'value',1);
set(handles.CorrDeltaX,'value',0);


% --- Executes on button press in CorrDeltaX.
function CorrDeltaX_Callback(hObject, eventdata, handles)
set(handles.MaxOrbitX,'value',0);
set(handles.CorrDeltaX,'value',1);

function ValueBX_Callback(hObject, eventdata, handles)
% hObject    handle to ValueBX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ValueBX as text
%        str2double(get(hObject,'String')) returns contents of ValueBX as a double


% --- Executes during object creation, after setting all properties.
function ValueBX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValueBX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CloseAngles.
function CloseAngles_Callback(hObject, eventdata, handles)
% hObject    handle to CloseAngles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CloseAngles


% --- Executes on selection change in CorrStartY.
function CorrStartY_Callback(hObject, eventdata, handles)
% hObject    handle to CorrStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CorrStartY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CorrStartY


% --- Executes during object creation, after setting all properties.
function CorrStartY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CorrStartY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SY.
function SY_Callback(hObject, eventdata, handles)
% hObject    handle to SY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SY


% --- Executes on selection change in BPMCloseY.
function BPMCloseY_Callback(hObject, eventdata, handles)
% hObject    handle to BPMCloseY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BPMCloseY contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BPMCloseY


% --- Executes during object creation, after setting all properties.
function BPMCloseY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BPMCloseY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RevBPM1Y.
function RevBPM1Y_Callback(hObject, eventdata, handles)
% hObject    handle to RevBPM1Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RevBPM1Y contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RevBPM1Y


% --- Executes during object creation, after setting all properties.
function RevBPM1Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RevBPM1Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RevBPM2Y.
function RevBPM2Y_Callback(hObject, eventdata, handles)
% hObject    handle to RevBPM2Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RevBPM2Y contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RevBPM2Y


% --- Executes during object creation, after setting all properties.
function RevBPM2Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RevBPM2Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MaxOrbitY.
function MaxOrbitY_Callback(hObject, eventdata, handles)
set(handles.MaxOrbitY,'value',1);
set(handles.CorrDeltaY,'value',0);


% --- Executes on button press in CorrDeltaY.
function CorrDeltaY_Callback(hObject, eventdata, handles)
set(handles.MaxOrbitY,'value',0);
set(handles.CorrDeltaY,'value',1);


function ValueBY_Callback(hObject, eventdata, handles)
% hObject    handle to ValueBY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ValueBY as text
%        str2double(get(hObject,'String')) returns contents of ValueBY as a double


% --- Executes during object creation, after setting all properties.
function ValueBY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ValueBY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CloseBump.
function CloseBump_Callback(hObject, eventdata, handles)
% hObject    handle to CloseBump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CloseBump


% --- Executes on button press in pushbutton77.
function pushbutton77_Callback(hObject, eventdata, handles)
S=get(handles.pushbutton81,'userdata');
ammo=str2double(get(handles.ammo,'string'));
if(ammo==1)
    if(~isempty(S.X))
        lcaPutSmart(S.X.PV{1},S.X.Val{1});
    end
    if(~isempty(S.Y))
        lcaPutSmart(S.Y.PV{1},S.Y.Val{1});
    end 
else
    if(~isempty(S.X))
        [~,WS,WE]=intersect(S.X.RestorePV,S.X.PV{1});
        BaseLevel=S.X.RestoreVal(WS); MaxLevel=S.X.Val{1};
        lcaPutSmart(S.X.PV{1},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
    if(~isempty(S.Y))
        [~,WS,WE]=intersect(S.Y.RestorePV,S.Y.PV{1});
        BaseLevel=S.Y.RestoreVal(WS); MaxLevel=S.Y.Val{1};
        lcaPutSmart(S.Y.PV{1},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
end

% --- Executes on button press in pushbutton78.
function pushbutton78_Callback(hObject, eventdata, handles)
S=get(handles.pushbutton81,'userdata');
ammo=str2double(get(handles.ammo,'string'));
if(ammo==1)
    if(~isempty(S.X))
        lcaPutSmart(S.X.PV{2},S.X.Val{2});
    end
    if(~isempty(S.Y))
        lcaPutSmart(S.Y.PV{2},S.Y.Val{2});
    end 
else
    if(~isempty(S.X))
        [~,WS,WE]=intersect(S.X.RestorePV,S.X.PV{2});
        BaseLevel=S.X.RestoreVal(WS); MaxLevel=S.X.Val{2};
        lcaPutSmart(S.X.PV{2},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
    if(~isempty(S.Y))
        [~,WS,WE]=intersect(S.Y.RestorePV,S.Y.PV{2});
        BaseLevel=S.Y.RestoreVal(WS); MaxLevel=S.Y.Val{2};
        lcaPutSmart(S.Y.PV{2},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
end


% --- Executes on button press in pushbutton79.
function pushbutton79_Callback(hObject, eventdata, handles)
S=get(handles.pushbutton81,'userdata');
ammo=str2double(get(handles.ammo,'string'));
if(ammo==1)
    if(~isempty(S.X))
        lcaPutSmart(S.X.PV{3},S.X.Val{3});
    end
    if(~isempty(S.Y))
        lcaPutSmart(S.Y.PV{3},S.Y.Val{3});
    end 
else
    if(~isempty(S.X))
        [~,WS,WE]=intersect(S.X.RestorePV,S.X.PV{3});
        BaseLevel=S.X.RestoreVal(WS); MaxLevel=S.X.Val{3};
        lcaPutSmart(S.X.PV{3},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
    if(~isempty(S.Y))
        [~,WS,WE]=intersect(S.Y.RestorePV,S.Y.PV{3});
        BaseLevel=S.Y.RestoreVal(WS); MaxLevel=S.Y.Val{3};
        lcaPutSmart(S.Y.PV{3},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
end


% --- Executes on button press in pushbutton80.
function pushbutton80_Callback(hObject, eventdata, handles)
S=get(handles.pushbutton81,'userdata');
ammo=str2double(get(handles.ammo,'string'));
if(ammo==1)
if(~isempty(S.X))
    lcaPutSmart(S.X.PV{4},S.X.Val{4});
end
if(~isempty(S.Y))
    lcaPutSmart(S.Y.PV{4},S.Y.Val{4});
end 
else
    if(~isempty(S.X))
        [~,WS,WE]=intersect(S.X.RestorePV,S.X.PV{4});
        BaseLevel=S.X.RestoreVal(WS); MaxLevel=S.X.Val{4};
        lcaPutSmart(S.X.PV{4},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
    if(~isempty(S.Y))
        [~,WS,WE]=intersect(S.Y.RestorePV,S.Y.PV{4});
        BaseLevel=S.Y.RestoreVal(WS); MaxLevel=S.Y.Val{4};
        lcaPutSmart(S.Y.PV{4},BaseLevel + (MaxLevel-BaseLevel)*ammo );
    end
end
 

% --- Executes on button press in pushbutton81.
function pushbutton81_Callback(hObject, eventdata, handles)
S=get(handles.pushbutton81,'userdata');
if(~isempty(S.X))
    lcaPutSmart(S.X.RestorePV,S.X.RestoreVal);
end
if(~isempty(S.Y))
    lcaPutSmart(S.Y.RestorePV,S.Y.RestoreVal);
end 



function TIMING_Callback(hObject, eventdata, handles)
handles.TimingBPM_CuLinac=get(handles.TIMING,'string');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function TIMING_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TIMING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExcludeBPM_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExcludeBPM as text
%        str2double(get(hObject,'String')) returns contents of ExcludeBPM as a double


% --- Executes during object creation, after setting all properties.
function ExcludeBPM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExcludeBPM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Set_Preset(hObject, handles)
TAG=get(hObject,'tag');
Number=str2double(TAG(2:end));
set(handles.AREA,'value',Number);
handles=AREA_Callback(handles.AREA,[], handles);
set(handles.AREA_LEGA,'visible','off');
set(handles.MAIN,'visible','on');

% --- Executes on button press in A1.
function A1_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

% --- Executes on button press in A2.
function A2_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

function A3_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

function A4_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

function A5_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

function A6_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

function A7_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);

function A8_Callback(hObject, eventdata, handles)
Set_Preset(hObject, handles);


% --- Executes on button press in ARFIX.
function ARFIX_Callback(hObject, eventdata, handles)
% hObject    handle to ARFIX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ARFIX


% --- Executes on button press in SMAC_OPN.
function SMAC_OPN_Callback(hObject, eventdata, handles)
% hObject    handle to SMAC_OPN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SMAC_OPN



function ammo_Callback(hObject, eventdata, handles)
% hObject    handle to ammo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ammo as text
%        str2double(get(hObject,'String')) returns contents of ammo as a double


% --- Executes during object creation, after setting all properties.
function ammo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ammo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
