function varargout = CVCRCI2(varargin)
% CVCRCI2 MATLAB code for CVCRCI2.fig
%      CVCRCI2, by itself, creates a new CVCRCI2 or raises the existing
%      singleton*.
%
%      H = CVCRCI2 returns the handle to a new CVCRCI2 or the handle to
%      the existing singleton*.
%
%      CVCRCI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI2.M with the given input arguments.
%
%      CVCRCI2('Property','Value',...) creates a new CVCRCI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI2_OpeningFcFn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI2

% Last Modified by GUIDE v2.5 23-Apr-2015 15:50:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI2_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI2_OutputFcn, ...
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


% --- Executes just before CVCRCI2 is made visible.
function CVCRCI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI2 (see VARARGIN)

% Choose default command line output for CVCRCI2
handles.output = hObject;
handles.ConfigurationDirectory='/u1/lcls/matlab/VOM_Configs';
handles.BackgroundsDirectory='/u1/lcls/matlab/VOM_Configs';%'/u1/lcls/matlab/VOM_Configs';
handles.ConfigAndBackgroundsDirectory='/u1/lcls/matlab/VOM_Configs';%'/u1/lcls/matlab/VOM_Configs';
load('CVCRCI2_MAIN_CONFIGURATION_FILE');
handles.NumberOfAllowedProfiles=7;
handles.ProfileListROIPvs=CAMERA.ProfileListROIPvs;
handles.ProfileSelectionListNames=CAMERA.ProfileSelectionListNames;
handles.ProfileSelectionListPVs=CAMERA.ProfileSelectionListPVs;
handles.ProfileAdditionalPVNames=CAMERA.ProfileAdditionalPVNames;
handles.PostProcessingDefault=CAMERA.PostProcessingDefault;
handles.DefaultSavingOption=CAMERA.DefaultSavingOption;
handles.DefaultSavingOptionEnable=CAMERA.DefaultSavingOptionEnable;
handles.DefaultPulseID_Delay=CAMERA.DefaultPulseID_Delay;
handles.CameraCropEnable=CAMERA.CameraCropEnable;
handles.DataType=CAMERA.DataType;
handles.AsynchronousBufferSizeRatio=CAMERA.AsynchronousBufferSizeRatio;
for TEMP_I=1:handles.NumberOfAllowedProfiles
    handles.ProfileListNames{TEMP_I}=['Recorded Profile ', num2str(TEMP_I)];
end
guidata(hObject, handles);
CurrentDisplays(1).NumberOfDisplays=0;
CurrentDisplays(1).CallingFunction=@Do_Nothing;
CurrentDisplays(1).Displayhandle=NaN;
CurrentDisplays(1).Name='';
CurrentDisplays(1).NeedsInit=0;
CurrentDisplays(1).ALLTAGS.void=NaN;
set(handles.Displays,'userdata',CurrentDisplays);
update_current_displays(handles)
handles.MAX_Pulse_ID=131040;
handles.MAX_Displays=[10,10];
handles.OutputPVNames={'SIOC:SYS0:ML02:AO314','SIOC:SYS0:ML02:AO315','SIOC:SYS0:ML02:AO316','SIOC:SYS0:ML02:AO317','SIOC:SYS0:ML02:AO318','SIOC:SYS0:ML02:AO319','SIOC:SYS0:ML02:AO320'};
handles.MAX_AUTO_PROFILE_FULL_RATE_SIZE=2500;
handles.BufferCounterName{1}='SIOC:SYS0:ML02:AO312';handles.BufferCounterName{2}='SIOC:SYS0:ML02:AO313';
handles.ColorOn=[0,1,0];handles.ColorOff=[1,0,0];handles.ColorWait=[0.7,0.7,0];handles.ColorIdle=get(handles.START,'BackgroundColor');
guidata(hObject, handles); 
handles.FullPVList=CVCRCI2_JimTurnerOpeningFunctionBSA_gui();
handles.MultiScanPVName='SIOC...';
handles.BackgroundsFileName='CVCRCI2_StoredBackgroundsFile';
[handles.FullPVList.fp,handles.FullPVList.sp,handles.FullPVList.tp,handles.FullPVList.qp]=read_pv_names(handles.FullPVList.root_name);
set(handles.PvlistPanel,'visible','off'); set(handles.MainPanel,'visible','off'); set(handles.Launcher,'visible','on');
%DisplayConfiguration_list
handles.DisplayConfiguration = Displays;
handles.MyProcessingPanel=[];
handles.MyScanPanel=[];
guidata(hObject, handles);
setup_ConfButtons(handles)
handles=Profile_Monitor_Panel_Init_Function(hObject,handles);
handles.CurrentDisplays{1}='';
handles.NumberOfDisplays=0;
set(handles.Displays,'string',handles.CurrentDisplays{1});
StrutturaCodice.NumeroFiltri=0;
StrutturaCodice.NumeroOutput=0;
StrutturaCodice.NumeroScalari=0;
StrutturaCodice.QuickVariables=0;
set(handles.Profile5,'userdata',StrutturaCodice);

set(handles.PvSyncList,'string',{'GDET:FEE1:241:ENRC','BPMS:LTU1:250:X'});
set(handles.PvNotSyncList,'string',{'SXR:MON:MMS:05.RBV'});

Unfreeze_Callback(hObject, eventdata, handles);
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);
for TEMP_I=1:numel(CONF)
    set(handles.(['L',num2str(TEMP_I)]),'userdata',CONF(TEMP_I));
end
% Update handles structure

% UIWAIT makes CVCRCI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function update_current_displays(handles)
CurrentDisplays=get(handles.Displays,'Userdata');
if(~CurrentDisplays(1).NumberOfDisplays)
    set(handles.Displays,'value',1);
    set(handles.Displays,'string','');
    return
else
    CS={};
    for II=1:CurrentDisplays(1).NumberOfDisplays
        CS{II}=[CurrentDisplays(II).Name,' ',num2str(CurrentDisplays(II).Displayhandle)];
    end
    set(handles.Displays,'value',1);
    set(handles.Displays,'string',CS);
end

function setup_ConfButtons(handles)
handles.DisplayConfiguration.Number
for II=1:handles.MAX_Displays(1)
    if(II<=handles.DisplayConfiguration.Number(1))
        set(handles.(['D',num2str(II)]),'visible','on');
        set(handles.(['D',num2str(II)]),'userdata',handles.DisplayConfiguration.Basic(II));
        set(handles.(['D',num2str(II)]),'string',handles.DisplayConfiguration.Basic(II).name);
    else
        set(handles.(['D',num2str(II)]),'visible','off');
    end
end
for II=1:handles.MAX_Displays(2)
    if(II<=handles.DisplayConfiguration.Number(2))
        set(handles.(['C',num2str(II)]),'visible','on');
        set(handles.(['C',num2str(II)]),'userdata',handles.DisplayConfiguration.Custom(II));
        set(handles.(['C',num2str(II)]),'string',handles.DisplayConfiguration.Custom(II).name);
    else
        set(handles.(['C',num2str(II)]),'visible','off');
    end
end
    
function handles=Profile_Monitor_Panel_Init_Function(hObject,handles)
set(handles.ReleaseeDefs,'Userdata','');set(handles.ReleaseeDefs,'enable','off');set(handles.ReleaseeDefs,'Backgroundcolor',handles.ColorIdle);
%Camera_List_Script;
%handles.StoredInformationDirectory=pwd;
set(handles.ProfileNumber,'String',handles.ProfileListNames);
set(handles.ProfileSelection,'String',handles.ProfileSelectionListNames);
handles.TimeStampPointer=handles.TimeStamps;
handles.SynchPVsPointer=handles.SynchPVs;
handles.NonSynchPvsPointer=handles.NonSynchPvs;
for II=1:numel(handles.ProfileListNames)
    handles.Profili(II).Pointer=handles.(['Profile',char(48+II)]);
    handles.Profili(II).SelectedProfile=1;
    handles.Profili(II).BackgroundStored=0;
    handles.Profili(II).BackgroundData=0; 
    handles.Profili(II).ROIX=[1,1]; 
    handles.Profili(II).ROIY=[1,1]; 
    handles.Profili(II).ProfileName='';
    handles.Profili(II).DataToBeKept=[0,0,0];
    handles.Profili(II).PulseIDDealy=0;
    handles.Profili(II).PostProcessingFunctionsList={'Do_Nothing'};
    handles.Profili(II).PostProcessing_CalledFunction=@Do_Nothing;
    handles.Profili(II).PostProcessingFunctionsValue=1;
    handles.Profili(II).CameraSize.X=[1,1];
    handles.Profili(II).CameraSize.Y=[1,1];
    handles.Profili(II).Type='double';
    handles.Profili(II).AsynchBufferSizeRatio=1;
end
set(handles.KeepPartialEvents,'value',0);
set(handles.UpdateNonSynch,'value',0);  
ProfileNumber_Callback(hObject,0, handles);

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
BufferName{1} = sprintf('VOM_buffer_1_%d',nRuns1);
myeDefNumber(1) = eDefReserve(BufferName{1});
if isequal (myeDefNumber(1), 0)
    disp('Sorry, failed to get eDef for Buffer 1');
    myeDefNumber(1)=NaN;
    return;
end
BufferName{2} = sprintf('VOM_buffer_2_%d',nRuns2);
myeDefNumber(2) = eDefReserve(BufferName{2});
if isequal (myeDefNumber(2), 0)
    disp('Sorry, failed to get eDef for Buffer 2');
    eDefRelease(myeDefNumber(1));
    myeDefNumber(2)=NaN;
    return;
end
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
new_name1 = strcat(Init_Vars.PvSyncList, {'HST'}, {num2str(myeDefNumber(1))});
new_name2 = strcat(Init_Vars.PvSyncList, {'HST'}, {num2str(myeDefNumber(2))});
set(handles.ReleaseeDefs,'Userdata',myeDefNumber);
set(handles.ReleaseeDefs,'backgroundcolor',handles.ColorOn);
set(handles.ReleaseeDefs,'enable','on');

% --- Executes on selection change in ProfileSelection.
function ProfileSelection_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
PS=get(handles.ProfileSelection,'value');
RESET=1;
if(handles.Profili(PN).SelectedProfile==PS)
    RESET=0;
end
handles.Profili(PN).SelectedProfile=PS;

if(RESET)
    handles.Profili(PN).PostProcessingFunctionsList=handles.PostProcessingDefault{PS};
    handles.Profili(PN).PostProcessing_CalledFunction=eval(['@',handles.PostProcessingDefault{PS}{1}]);
    handles.Profili(PN).PostProcessingFunctionsValue=1;
    handles.Profili(PN).BackgroundStored=0;
    handles.Profili(PN).BackgroundData=0;
    handles=ProfileReadSize_Callback(hObject, eventdata, handles);
    handles.Profili(PN).ProfileName=handles.ProfileSelectionListPVs{PS};
    handles.Profili(PN).PulseIDDealy=handles.DefaultPulseID_Delay{PS};
    handles.Profili(PN).DataToBeKept=handles.DefaultSavingOption{PS};
    handles.Profili(PN).Type=handles.DataType{PS};
    handles.Profili(PN).ROIX(1)=1; handles.Profili(PN).ROIY(1)=1;
    handles.Profili(PN).ROIX(2)=handles.Profili(PN).CameraSize.X(2); handles.Profili(PN).ROIY(2)=handles.Profili(PN).CameraSize.Y(2);
    handles.Profili(PN).AsynchBufferSizeRatio=handles.AsynchronousBufferSizeRatio{PN};
end

set(handles.KeepFullImage,'enable',CVCRCI2_OnToOneConversion(handles.DefaultSavingOptionEnable{PS}(1)));
set(handles.XProjection,'enable',CVCRCI2_OnToOneConversion(handles.DefaultSavingOptionEnable{PS}(2)));
set(handles.YProjection,'enable',CVCRCI2_OnToOneConversion(handles.DefaultSavingOptionEnable{PS}(3)));
set(handles.KeepFullImage,'value',handles.Profili(PN).DataToBeKept(1));
set(handles.XProjection,'value',handles.Profili(PN).DataToBeKept(2));
set(handles.YProjection,'value',handles.Profili(PN).DataToBeKept(3));
set(handles.AsynchBufferSizeRatio,'string',num2str(handles.Profili(PN).AsynchBufferSizeRatio));
set(handles.PostAcquisitionFunction,'String',handles.Profili(PN).PostProcessingFunctionsList);
set(handles.PostAcquisitionFunction,'value',handles.Profili(PN).PostProcessingFunctionsValue);

set(handles.ProfilePVName,'string',handles.Profili(PN).ProfileName)
set(handles.PulseIDDelayValue,'string',num2str(handles.Profili(PN).PulseIDDealy));

set(handles.CropX1,'string',num2str(handles.Profili(PN).ROIX(1)));set(handles.CropX2,'string',num2str(handles.Profili(PN).ROIX(2)));
set(handles.CropY1,'string',num2str(handles.Profili(PN).ROIY(1)));set(handles.CropY2,'string',num2str(handles.Profili(PN).ROIY(2)));
if(handles.CameraCropEnable{PS}(1))
    set(handles.CropX1,'enable','on'); set(handles.CropX2,'enable','on');
else
    set(handles.CropX1,'enable','off'); set(handles.CropX2,'enable','off');
end
if(handles.CameraCropEnable{PS}(2))
    set(handles.CropY1,'enable','on'); set(handles.CropY2,'enable','on');
else
    set(handles.CropY1,'enable','off'); set(handles.CropY2,'enable','off');
end

if(handles.Profili(PN).BackgroundStored)
    set(handles.BackgroundTaken,'String','Already Taken');
else
    set(handles.BackgroundTaken,'String','Not Taken Yet'); 
end
    
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);


function Do_Nothing()

function DisableButtons(hObject,handles)
set(handles.OpenLauncher,'enable','off');
set(handles.ProfileSelection,'enable','off');
set(handles.TakeBackground,'enable','off');
set(handles.ClearBackground,'enable','off');
set(handles.LoadBackground,'enable','off');
set(handles.ProfileReadSize,'enable','off');
set(handles.CropX1,'enable','off');
set(handles.CropX2,'enable','off');
set(handles.CropY1,'enable','off');
set(handles.CropY2,'enable','off');
set(handles.KeepFullImage,'enable','off');
set(handles.XProjection,'enable','off');
set(handles.YProjection,'enable','off');
set(handles.ProfileNumber,'enable','off');
set(handles.PulseIDDelayValue,'enable','off');
set(handles.PostAcquisitionFunction,'enable','off');
set(handles.KeepFullImage,'enable','off');
set(handles.EditPvList,'enable','off');
set(handles.SaveConfiguration,'enable','off');
set(handles.LoadConfiguration,'enable','off');


function EnableButtons(hObject,handles)
set(handles.ProfileNumber,'enable','on');
set(handles.ProfileSelection,'enable','on');
set(handles.TakeBackground,'enable','on');
set(handles.ClearBackground,'enable','on');
set(handles.LoadBackground,'enable','on');
set(handles.ProfileReadSize,'enable','on');
set(handles.CropX1,'enable','on');
set(handles.CropX2,'enable','on');
set(handles.CropY1,'enable','on');
set(handles.CropY2,'enable','on');
set(handles.KeepFullImage,'enable','on');
set(handles.XProjection,'enable','on');
set(handles.YProjection,'enable','on');
set(handles.PulseIDDelayValue,'enable','on');
set(handles.PostAcquisitionFunction,'enable','on');
set(handles.KeepFullImage,'enable','on');
set(handles.EditPvList,'enable','on');
set(handles.SaveConfiguration,'enable','on');
set(handles.LoadConfiguration,'enable','on');
set(handles.OpenLauncher,'enable','on');
ProfileSelection_Callback(hObject, 0, handles)

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

function [Init_Vars,CycleVars]=Initialize_Variables(handles)
Init_Vars.PvSyncList=get(handles.PvSyncList,'string');
Init_Vars.PvNotSyncList=get(handles.PvNotSyncList,'string');
Init_Vars.Plus=str2num(get(handles.PluseOneBox,'string'));
Init_Vars.PlusOneDelay=str2num(get(handles.PlusOneDelay,'string'));
Init_Vars.PlusNumberOfVariables=str2num(get(handles.synchfirst,'string'));
Init_Vars.BufferSize=str2num(get(handles.BufferSize,'string'));
Init_Vars.DBCycle=str2num(get(handles.DBCycle,'string'));
Init_Vars.BlockSize=str2num(get(handles.BlockSize,'string'));
Init_Vars.KeepPartialEvents=get(handles.KeepPartialEvents,'value');
Init_Vars.UpdateNonSynch=get(handles.UpdateNonSynch,'value');
Init_Vars.AdjustToFrequency=get(handles.AdjustToFrequency,'value');
Init_Vars.Profili=handles.Profili;
Inserted_Profiles=0;
CycleVars=[];

if(Init_Vars.KeepPartialEvents)
   Init_Vars.VBS=get(handles.ProfVarBuf,'value');
else
   Init_Vars.VBS=0; 
end

if(isempty(Init_Vars.PvSyncList))
  Init_Vars.PlusNumberOfVariables=0;
  Init_Vars.PlusOneDelay=0;
  Init_Vars.Plus=0;
elseif(isnan(Init_Vars.PlusNumberOfVariables) || isempty(Init_Vars.PlusNumberOfVariables) || ( Init_Vars.PlusNumberOfVariables >numel(Init_Vars.PvSyncList)   ) || isinf(Init_Vars.PlusNumberOfVariables))
  Init_Vars.PlusNumberOfVariables=numel(Init_Vars.PvSyncList);
end

for II=1:7
    if(handles.Profili(II).SelectedProfile>1)
        Inserted_Profiles=Inserted_Profiles+1;
        switch(Init_Vars.AdjustToFrequency)
            case 1
                CycleVars(Inserted_Profiles).PulseIDDealy=Init_Vars.Profili(II).PulseIDDealy*1;
            case 2
                CycleVars(Inserted_Profiles).PulseIDDealy=Init_Vars.Profili(II).PulseIDDealy*2;
            case 3
                CycleVars(Inserted_Profiles).PulseIDDealy=Init_Vars.Profili(II).PulseIDDealy*4;
            case 4
                CycleVars(Inserted_Profiles).PulseIDDealy=Init_Vars.Profili(II).PulseIDDealy*12;
            case 5
                CycleVars(Inserted_Profiles).PulseIDDealy=Init_Vars.Profili(II).PulseIDDealy*24;
            case 6
                CycleVars(Inserted_Profiles).PulseIDDealy=Init_Vars.Profili(II).PulseIDDealy*120;
        end
        if(Init_Vars.VBS)
            CycleVars(Inserted_Profiles).SpecificBufferSize=ceil(Init_Vars.BufferSize*handles.Profili(II).AsynchBufferSizeRatio);
        else
            CycleVars(Inserted_Profiles).SpecificBufferSize=Init_Vars.BufferSize;
        end
        CycleVars(Inserted_Profiles).ProfileName=handles.Profili(II).ProfileName;
        CycleVars(Inserted_Profiles).LcaGetSize=prod(handles.Profili(II).CameraSize.X)*prod(handles.Profili(II).CameraSize.Y);
        CycleVars(Inserted_Profiles).ROIX=handles.Profili(II).ROIX;
        CycleVars(Inserted_Profiles).ROIY=handles.Profili(II).ROIY;
        CycleVars(Inserted_Profiles).FullData = handles.Profili(II).DataToBeKept(1);
        CycleVars(Inserted_Profiles).ProjectionX = handles.Profili(II).DataToBeKept(2);
        CycleVars(Inserted_Profiles).ProjectionY = handles.Profili(II).DataToBeKept(3);  
        CycleVars(Inserted_Profiles).ProcessingFunction = handles.Profili(II).PostProcessing_CalledFunction;
        CycleVars(Inserted_Profiles).BackGroundStored = handles.Profili(II).BackgroundStored; 
        CycleVars(Inserted_Profiles).FullCameraReshapeSize = [prod(handles.Profili(II).CameraSize.X) , prod(handles.Profili(II).CameraSize.Y)];
        CycleVars(Inserted_Profiles).ROIReshapeSize = [diff(handles.Profili(II).ROIX) + 1 , diff(handles.Profili(II).ROIY)+1];
        TemporaryZerosCameraSize = zeros(CycleVars(Inserted_Profiles).FullCameraReshapeSize(1),CycleVars(Inserted_Profiles).FullCameraReshapeSize(2));
        TemporaryZerosCameraSize(handles.Profili(II).ROIX(1):handles.Profili(II).ROIX(2),handles.Profili(II).ROIY(1):handles.Profili(II).ROIY(2))=1;
        CycleVars(Inserted_Profiles).ROI_Elements_Position = find(TemporaryZerosCameraSize(:));
        if(CycleVars(Inserted_Profiles).BackGroundStored)
            CycleVars(Inserted_Profiles).Background = handles.Profili(II).BackgroundData(CycleVars(Inserted_Profiles).ROI_Elements_Position);
        else
            CycleVars(Inserted_Profiles).Background=0;
        end
        if(numel(CycleVars(Inserted_Profiles).ROI_Elements_Position)==CycleVars(Inserted_Profiles).LcaGetSize)
            CycleVars(Inserted_Profiles).Do_ROI=0;
        else
            CycleVars(Inserted_Profiles).Do_ROI=1;
        end
        if (strcmpi((handles.Profili(II).PostProcessingFunctionsList(handles.Profili(II).PostProcessingFunctionsValue)),'Do_Nothing'))
            CycleVars(Inserted_Profiles).Run_Post_Processing=0;
        else
            CycleVars(Inserted_Profiles).Run_Post_Processing=1;
        end
    end
Init_Vars.NumberOfProfiles=Inserted_Profiles;
Init_Vars.NumberOfSynchPVs=numel(Init_Vars.PvSyncList);
Init_Vars.NumberOfNoNSynchPVs=numel(Init_Vars.PvNotSyncList);
if(Init_Vars.NumberOfProfiles)
  Init_Vars.ReadProfile=true;
else
  Init_Vars.ReadProfile=false;
end
end

%Calculate BackgroundsToBeStored
function Struttura_Dati = Get_All_Dimensions_And_Names(handles)
[Init_Vars,CycleVars]=Initialize_Variables(handles);
Struttura_Dati.Number_of_synch_pvs = Init_Vars.NumberOfSynchPVs;
Struttura_Dati.Names_of_synch_pvs = Init_Vars.PvSyncList;
Struttura_Dati.Number_of_unsynch_pvs = Init_Vars.NumberOfNoNSynchPVs;
Struttura_Dati.Names_of_unsynch_pvs = Init_Vars.PvNotSyncList;
Struttura_Dati.Number_of_scalar_matrices=0;
Struttura_Dati.Number_of_scalars_in_a_matrix=[];
Struttura_Dati.Names_of_scalar_inside_matrices={};
Struttura_Dati.Number_of_vectors=0;
Struttura_Dati.Size_of_vectors=[];
Struttura_Dati.Position_of_vectors_in_Profiles=[];
Struttura_Dati.Names_of_vectors={};
Struttura_Dati.Number_of_2Darrays=0;
Struttura_Dati.Size_of_2Darrays=[];
Struttura_Dati.Position_of_2Darrays_in_Profiles=[];
Struttura_Dati.Names_of_2Darrays={};
Struttura_Dati.FromWhichProfileTheScalarMatrixComesFrom=[];

ProfileBufferInserted=0;

for II=1:Init_Vars.NumberOfProfiles %for every used profile
    if(CycleVars(II).Run_Post_Processing) % It is a special profile that needs its own processing function
        Data=CycleVars(II).ProcessingFunction([],1);
        CycleVars(II).Data=Data;
        for KK=1:Data.NumberOfVectors
            ProfileBufferInserted=ProfileBufferInserted+1;
            Struttura_Dati.Number_of_vectors=Struttura_Dati.Number_of_vectors+1;
            Struttura_Dati.Names_of_vectors{Struttura_Dati.Number_of_vectors}=Data.VectorNames{KK};
            Struttura_Dati.Size_of_vectors(Struttura_Dati.Number_of_vectors) = Data.VectorSizes(KK);
            Struttura_Dati.Position_of_vectors_in_Profiles(Struttura_Dati.Number_of_vectors)=ProfileBufferInserted;
        end
        for KK=1:Data.NumberOfArray2D
            ProfileBufferInserted=ProfileBufferInserted+1;
            Struttura_Dati.Number_of_2Darrays=Struttura_Dati.Number_of_2Darrays+1;
            Struttura_Dati.Names_of_2Darrays{Struttura_Dati.Number_of_2Darrays}=Data.Array2DNames{KK};
            Struttura_Dati.Size_of_2Darrays(Struttura_Dati.Number_of_2Darrays,:) = [Data.Array2DSizes(1,KK),Data.Array2DSizes(2,KK)];
            Struttura_Dati.Position_of_2Darrays_in_Profiles(Struttura_Dati.Number_of_2Darrays)=ProfileBufferInserted;
        end
        if(Data.NumberOfPulseID)
           CycleVars(II).Processing_Comes_With_PID=1;
        else
           CycleVars(II).Processing_Comes_With_PID=0;
        end
        if(Data.NumberOfTimeStamps)
           CycleVars(II).Processing_Comes_With_TimeStamps=1;
        else
           CycleVars(II).Processing_Comes_With_TimeStamps=0;
        end
        if(Data.NumberOfScalars)      
            Struttura_Dati.Number_of_scalar_matrices=Struttura_Dati.Number_of_scalar_matrices+1;     
            Struttura_Dati.Number_of_scalars_in_a_matrix(Struttura_Dati.Number_of_scalar_matrices)=Data.NumberOfScalars;
            for JJ=1:Data.NumberOfScalars
                Struttura_Dati.Names_of_scalar_inside_matrices{Struttura_Dati.Number_of_scalar_matrices,JJ}=Data.ScalarNames{JJ};
            end
            Struttura_Dati.FromWhichProfileTheScalarMatrixComesFrom(Struttura_Dati.Number_of_scalar_matrices)=II;
        end
    else %it is treated as a standard 1D or 2D array
        CycleVars(II).ReadOnceIn = 1;
        DatiAcquisiti=ones(1,CycleVars(II).LcaGetSize);
        TempSizeDatiAcquisiti=size(DatiAcquisiti);
        if(CycleVars(II).Do_ROI)
            try
                DatiAcquisiti = DatiAcquisiti(CycleVars(II).ROI_Elements_Position); 
            catch ME
                disp(['ROI Size is wrong for ', CycleVars(II).ProfileName,' profile size = ',num2str(TempSizeDatiAcquisiti),' Fix this before proceeding'])
            end
        else
            
        end
        if(CycleVars(II).BackGroundStored)
            try
                DatiAcquisiti = DatiAcquisiti - CycleVars(II).Background; 
            catch ME
                disp(['Background subtraction does not work for  ', CycleVars(II).ProfileName,' Fix this before proceeding'])
            end
        else
            
        end       
        TempSizeDatiAcquisiti=size(DatiAcquisiti);       
        if(TempSizeDatiAcquisiti(1)>1) % raw data is a column, must do transpose while acquiring 
            CycleVars(II).TransposeFastBuffer=1;
        else
            CycleVars(II).TransposeFastBuffer=0;
        end
        %Now try the three things to save data on actual data...
        
        if((CycleVars(II).ROIReshapeSize(1)==1) || (CycleVars(II).ROIReshapeSize(2)==1))
            CycleVars(II).DoReshape=0;
        else
            CycleVars(II).DoReshape=1;
        end
        
        if(CycleVars(II).DoReshape) %No reshape is needed
             DatiAcquisiti=reshape(DatiAcquisiti,CycleVars(II).ROIReshapeSize);
        end
        
        %Adesso sei con quello che avrai quando dovrai schiaffarlo nel
        %buffer ...
        if(CycleVars(II).FullData)
            if(iscolumn(DatiAcquisiti))
                CycleVars(II).FullTranspose=1;
                DatiAcquisitiF=transpose(DatiAcquisiti);
            else
                CycleVars(II).FullTranspose=0;
                DatiAcquisitiF=DatiAcquisiti;
            end
            if(isrow(DatiAcquisitiF))
                CycleVars(II).FullTrueImage=0;
            else
                CycleVars(II).FullTrueImage=1;
            end
            if(CycleVars(II).FullTrueImage) 
                ProfileBufferInserted=ProfileBufferInserted+1;
                Struttura_Dati.Number_of_2Darrays=Struttura_Dati.Number_of_2Darrays+1;
                Struttura_Dati.Names_of_2Darrays{Struttura_Dati.Number_of_2Darrays}=[CycleVars(II).ProfileName,' [Full]'];
                Struttura_Dati.Size_of_2Darrays(Struttura_Dati.Number_of_2Darrays,:) = size(DatiAcquisitiF);
                Struttura_Dati.Position_of_2Darrays_in_Profiles(Struttura_Dati.Number_of_2Darrays)=ProfileBufferInserted;
            else
                ProfileBufferInserted=ProfileBufferInserted+1;
                Struttura_Dati.Number_of_vectors=Struttura_Dati.Number_of_vectors+1;
                Struttura_Dati.Names_of_vectors{Struttura_Dati.Number_of_vectors}=[CycleVars(II).ProfileName,' [Full]'];
                Struttura_Dati.Size_of_vectors(Struttura_Dati.Number_of_vectors) = length(DatiAcquisitiF);
                Struttura_Dati.Position_of_vectors_in_Profiles(Struttura_Dati.Number_of_vectors)=ProfileBufferInserted;
            end
        end
        
        if(CycleVars(II).ProjectionX)
            DatiAcquisitiX=sum(DatiAcquisiti,1);
            if(isrow(DatiAcquisitiX))
                CycleVars(II).XTranspose=0;
            else
                DatiAcquisitiX=transpose(DatiAcquisitiX);
                CycleVars(II).XTranspose=1;
            end
            XDataSize=length(DatiAcquisitiX);
            ProfileBufferInserted=ProfileBufferInserted+1;
            Struttura_Dati.Number_of_vectors=Struttura_Dati.Number_of_vectors+1;
            Struttura_Dati.Names_of_vectors{Struttura_Dati.Number_of_vectors}=[CycleVars(II).ProfileName,' [ProjectionX]'];
            Struttura_Dati.Size_of_vectors(Struttura_Dati.Number_of_vectors) = XDataSize;
            Struttura_Dati.Position_of_vectors_in_Profiles(Struttura_Dati.Number_of_vectors)=ProfileBufferInserted;
        end
        
        if(CycleVars(II).ProjectionY)
            DatiAcquisitiY=sum(DatiAcquisiti,2);
            if(isrow(DatiAcquisitiY))
                CycleVars(II).YTranspose=0;
            else
                DatiAcquisitiY=transpose(DatiAcquisitiY);
                CycleVars(II).YTranspose=1;
            end
            YDataSize=length(DatiAcquisitiY);
            ProfileBufferInserted=ProfileBufferInserted+1;
            Struttura_Dati.Number_of_vectors=Struttura_Dati.Number_of_vectors+1;
            Struttura_Dati.Names_of_vectors{Struttura_Dati.Number_of_vectors}=[CycleVars(II).ProfileName,' [ProjectionY]'];
            Struttura_Dati.Size_of_vectors(Struttura_Dati.Number_of_vectors) = YDataSize;
            Struttura_Dati.Position_of_vectors_in_Profiles(Struttura_Dati.Number_of_vectors)=ProfileBufferInserted;
        end
    end
end
% ScanSetting.ScanBufferLength=0;
handles.Struttura_Dati=Struttura_Dati;
set(handles.ProfileMonitorPanel,'userdata',Struttura_Dati);
FillProcessingWindows(handles);
% CVCRCI2_FullDataStructureScript

% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
set(handles.START,'enable','off'); set(handles.PAUSE,'enable','on'); set(handles.STOP,'enable','on');
set(handles.START,'string','Start'); set(handles.PAUSE,'string','Pause'); set(handles.STOP,'string','Stop');
set(handles.START,'backgroundcolor',handles.ColorOn); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle);drawnow
set(handles.StartScan,'enable','on'); set(handles.StartScan,'Userdata',0);
DisableButtons(hObject,handles)
BSA=0;ABSACQ=0;

ScanSetting.ScanBufferNames={};
ScanSetting.ScanBufferLength=0;


ModeOfOperation=get(handles.TypeOfStart,'value');
if(ModeOfOperation==1)
    disp('Continuous Mode of recording Started')
end
BSAMode=get(handles.BSAMode,'value');

[Init_Vars,CycleVars]=Initialize_Variables(handles);
ReadProfile=Init_Vars.ReadProfile;
ScanBuffer=zeros(Init_Vars.BufferSize,ScanSetting.ScanBufferLength);
Just_Started=1;

if(Init_Vars.NumberOfSynchPVs<1) %never use BSA buffers when no synch pv is required
    BSAMode=0;
end

if(BSAMode>1) %some BSA Mode !
    BSA=1;
    if(BSAMode==2)
        [myeDefNumber,new_name1,new_name2]=Initialize_Double_Buffer(handles,Init_Vars);
    end
    if(BSAMode==3) %this has to be changed!
        [myeDefNumber,new_name1,new_name2]=Initialize_Double_Buffer(handles,Init_Vars);
    end
    Phase_Cycle=0;
    DaLeggere=1;
    ABSACQ=0;
    Line=0;
    LastValidTime=-inf;
end

%Set up variable buffers... This must build buffers for all the recorded
%variables

AcquisitionProfileNames={};
AdditionalScalarNames={};
ProfileBuffer={};
ScalarBuffer={};
FullPulseIDMatrix={};
FullPulseIDProfiles={};
AbsoluteEventCounterProfiles={};
AbsoluteEventCounterMatrix={};
set(handles.EventsNumber,'string','0')
Init_Vars.NumberOfAdditionalScalarsMatrices=0;
Init_Vars.TrueBufSize=[];
for II=1:Init_Vars.NumberOfProfiles %for every used profile
  
    if(CycleVars(II).Run_Post_Processing) % It is a special profile that needs its own processing function
        Data=CycleVars(II).ProcessingFunction([],1);
        CycleVars(II).Data=Data;
        for KK=1:Data.NumberOfVectors
            AcquisitionProfileNames{end+1}=Data.VectorNames{KK};
            if(Init_Vars.VBS)
                ProfileBuffer{end+1}(:,:) = zeros(CycleVars(II).SpecificBufferSize,Data.VectorSizes(KK));
                Init_Vars.TrueBufSize(end+1)=CycleVars(II).SpecificBufferSize;
            else
                ProfileBuffer{end+1}(:,:) = zeros(Init_Vars.BufferSize,Data.VectorSizes(KK));
                Init_Vars.TrueBufSize(end+1)=Init_Vars.BufferSize;
            end
        end
        for KK=1:Data.NumberOfArray2D
            AcquisitionProfileNames{end+1}=Data.Array2DNames{KK};
            if(Init_Vars.VBS)
                Init_Vars.TrueBufSize(end+1)=CycleVars(II).SpecificBufferSize;
                ProfileBuffer{end+1}(:,:,:) = zeros(Data.Array2DSizes(1,KK),Data.Array2DSizes(2,KK),Init_Vars.TrueBufSize(end));
            else
                ProfileBuffer{end+1}(:,:,:) = zeros(Data.Array2DSizes(1,KK),Data.Array2DSizes(2,KK),Init_Vars.BufferSize);
                Init_Vars.TrueBufSize(end+1)=Init_Vars.BufferSize;
            end
        end
        CycleVars(II).ReadOnceIn = Data.ReadOnceIn;
        if(Data.NumberOfPulseID)
           CycleVars(II).Processing_Comes_With_PID=1;
        else
           CycleVars(II).Processing_Comes_With_PID=0;
        end
        if(Data.NumberOfTimeStamps)
           CycleVars(II).Processing_Comes_With_TimeStamps=1;
        else
           CycleVars(II).Processing_Comes_With_TimeStamps=0;
        end
        if(Data.NumberOfScalars)
             Init_Vars.NumberOfAdditionalScalarsMatrices=Init_Vars.NumberOfAdditionalScalarsMatrices+1;
             for JJ=1:Data.NumberOfScalars
                 AdditionalScalarNames{Init_Vars.NumberOfAdditionalScalarsMatrices,end+1}=Data.ScalarNames{JJ};
             end
             ScalarBuffer{Init_Vars.NumberOfAdditionalScalarsMatrices}=zeros(Init_Vars.BufferSize,Data.NumberOfScalars); 
        end


    else %it is treated as a standard 1D or 2D array
        CycleVars(II).ReadOnceIn = 1;
        try
            DatiAcquisiti = lcaGetSmart(CycleVars(II).ProfileName,CycleVars(II).LcaGetSize);
        catch ME
            disp(['Cannot read ', CycleVars(II).ProfileName])
        end
        TempSizeDatiAcquisiti=size(DatiAcquisiti);
        if(CycleVars(II).Do_ROI)
            try
                DatiAcquisiti = DatiAcquisiti(CycleVars(II).ROI_Elements_Position); 
            catch ME
                disp(['ROI Size is wrong for ', CycleVars(II).ProfileName,' profile size = ',num2str(TempSizeDatiAcquisiti)])
            end
        else
            
        end
        if(CycleVars(II).BackGroundStored)
            try
                DatiAcquisiti = DatiAcquisiti - CycleVars(II).Background; 
            catch ME
                disp(['Background subtraction does not work for  ', CycleVars(II).ProfileName])
            end
        else
            
        end       
        TempSizeDatiAcquisiti=size(DatiAcquisiti);       
        if(TempSizeDatiAcquisiti(1)>1) % raw data is a column, must do transpose while acquiring 
            CycleVars(II).TransposeFastBuffer=1;
        else
            CycleVars(II).TransposeFastBuffer=0;
        end
        %Now try the three things to save data on actual data...
        
        if((CycleVars(II).ROIReshapeSize(1)==1) || (CycleVars(II).ROIReshapeSize(2)==1))
            CycleVars(II).DoReshape=0;
        else
            CycleVars(II).DoReshape=1;
        end
        
        if(CycleVars(II).DoReshape) %No reshape is needed
             DatiAcquisiti=reshape(DatiAcquisiti,CycleVars(II).ROIReshapeSize);
        end
        
        %Adesso sei con quello che avrai quando dovrai schiaffarlo nel
        %buffer ...
        size(DatiAcquisiti)
        if(CycleVars(II).FullData)
            if(iscolumn(DatiAcquisiti))
                CycleVars(II).FullTranspose=1;
                DatiAcquisitiF=transpose(DatiAcquisiti);
            else
                CycleVars(II).FullTranspose=0;
                DatiAcquisitiF=DatiAcquisiti;
            end
            if(isrow(DatiAcquisitiF))
                CycleVars(II).FullTrueImage=0;
            else
                CycleVars(II).FullTrueImage=1;
            end
            if(CycleVars(II).FullTrueImage)
                AcquisitionProfileNames{end+1}=[CycleVars(II).ProfileName,' [Full]'];
                
                if(Init_Vars.VBS) 
                    Init_Vars.TrueBufSize(end+1)=CycleVars(II).SpecificBufferSize;
                else
                    Init_Vars.TrueBufSize(end+1)=Init_Vars.BufferSize;
                end
                
                DimensioniProfilo=[size(DatiAcquisitiF),Init_Vars.TrueBufSize(end)];
                ProfileBuffer{end+1} = zeros(DimensioniProfilo);
            else
                AcquisitionProfileNames{end+1}=[CycleVars(II).ProfileName,' [Full]'];
                
                if(Init_Vars.VBS) 
                    Init_Vars.TrueBufSize(end+1)=CycleVars(II).SpecificBufferSize;
                else
                    Init_Vars.TrueBufSize(end+1)=Init_Vars.BufferSize;
                end
                
                DimensioniProfilo=[Init_Vars.TrueBufSize(end),length(DatiAcquisitiF)];
                ProfileBuffer{end+1} = zeros(DimensioniProfilo);
            end

        end
        
        if(CycleVars(II).ProjectionX)
            DatiAcquisitiX=sum(DatiAcquisiti,1);
            if(isrow(DatiAcquisitiX))
                CycleVars(II).XTranspose=0;
            else
                DatiAcquisitiX=transpose(DatiAcquisitiX);
                CycleVars(II).XTranspose=1;
            end
            XDataSize=length(DatiAcquisitiX);
            AcquisitionProfileNames{end+1}=[CycleVars(II).ProfileName,' [ProjectionX]'];
            
            if(Init_Vars.VBS) 
                    Init_Vars.TrueBufSize(end+1)=CycleVars(II).SpecificBufferSize;
            else
                    Init_Vars.TrueBufSize(end+1)=Init_Vars.BufferSize;
            end
            
            ProfileBuffer{end+1} = zeros([Init_Vars.TrueBufSize(end),XDataSize]);
        end
        
        if(CycleVars(II).ProjectionY)
            DatiAcquisitiY=sum(DatiAcquisiti,2);
            if(isrow(DatiAcquisitiY))
                CycleVars(II).YTranspose=0;
            else
                DatiAcquisitiY=transpose(DatiAcquisitiY);
                CycleVars(II).YTranspose=1;
            end
            YDataSize=length(DatiAcquisitiY);
            AcquisitionProfileNames{end+1}=[CycleVars(II).ProfileName,' [ProjectionY]'];
            if(Init_Vars.VBS) 
                    Init_Vars.TrueBufSize(end+1)=CycleVars(II).SpecificBufferSize;
            else
                    Init_Vars.TrueBufSize(end+1)=Init_Vars.BufferSize;
            end
            ProfileBuffer{end+1} = zeros([Init_Vars.TrueBufSize(end),YDataSize]);
        end
    end

end

%Now you should know how to make profiles, if there is only a single
%profile, must know (will go on a special loop). if there is only
%standardpv must know, if there are no pvs at all must know.

TrueNumberOfProfiles=numel(ProfileBuffer);
AdditionalNonStandardPVsMatrices=Init_Vars.NumberOfAdditionalScalarsMatrices;

%Sets-up fast acquisition buffer. Durtion must be different for BSA or not
%BSA settings. Be careful with memory usage.

if(BSA)
    FastBufferLength=Init_Vars.DBCycle*8*120;
    if(~isnan(Init_Vars.PlusOneDelay*Init_Vars.Plus))
      P1Cue=zeros(1,FastBufferLength*round(Init_Vars.Plus/Init_Vars.PlusOneDelay));
      P1Cue_TS=zeros(1,FastBufferLength*round(Init_Vars.Plus/Init_Vars.PlusOneDelay));
    else
      P1Cue=zeros(1,FastBufferLength);
      P1Cue_TS=zeros(1,FastBufferLength);
    end
else
    FastBufferLength=Init_Vars.BlockSize;
end

for counter=1:Init_Vars.NumberOfProfiles
    ProfileCue{counter}=NaN*ones(FastBufferLength,CycleVars(counter).LcaGetSize);
end
ProfileCue_TS=ones(Init_Vars.NumberOfProfiles,FastBufferLength)*NaN;
PvsCue=zeros(Init_Vars.NumberOfSynchPVs,FastBufferLength);
PvsCue_TS=NaN*ones(Init_Vars.NumberOfSynchPVs,FastBufferLength);

NotSynchProfilePVsReadVariables=zeros(Init_Vars.NumberOfNoNSynchPVs,1);

SynchProfilePVsNames=Init_Vars.PvSyncList;
NotSynchProfileNames=Init_Vars.PvNotSyncList;

SynchProfilePVs=zeros(Init_Vars.BufferSize,Init_Vars.NumberOfSynchPVs);
NotSynchProfilePVs=zeros(Init_Vars.BufferSize,Init_Vars.NumberOfNoNSynchPVs);

if(Init_Vars.KeepPartialEvents)
    StrutturaCodice.NumeroFiltri=0;
    StrutturaCodice.NumeroOutput=0;
    StrutturaCodice.NumeroScalari=0;
    StrutturaCodice.QuickVariables=0;
    set(handles.Profile5,'userdata',StrutturaCodice);
    NewOuts.OutAttivi=0;
    CodeAndOutputState = get(handles.Profile5,'userdata');
    [FiltersBuffer,FiltersNames,FiltersNumber,SingleLineFilters,MultiLineFilters,FilterTypes,FilterS] = Inizializza_Filtri(CodeAndOutputState,Init_Vars);
    [ScalarsBuffer,ScalarsNames,ScalarsNumber,SingleLineScalars,MultiLineScalars,ScalarsTypes,ScalarsS,ScalarsPositionThisCall] = Inizializza_Scalari(CodeAndOutputState,Init_Vars);
    [OutputBuffer,OutputNames,OutputNumber,SingleLineOutput,MultiLineOutput,OutputTypes,OutputS] = Inizializza_Output(CodeAndOutputState);
    QuickVariables=0;
    
else
    
    if(~isempty(handles.MyProcessingPanel) && ishandle( handles.MyProcessingPanel ) )
        if(get(handles.MyProcessingTags.MCE,'userdata'))
            NewCodeAndOutputState = get(handles.MyProcessingTags.MCE_VALS,'userdata');
            NewOuts=  get(handles.MyProcessingTags.MCE_OUT,'userdata');
            [FiltersBuffer,FiltersNames,FiltersNumber,SingleLineFilters,MultiLineFilters,FilterTypes,FilterS] = Inizializza_Filtri(NewCodeAndOutputState,Init_Vars);
            [ScalarsBuffer,ScalarsNames,ScalarsNumber,SingleLineScalars,MultiLineScalars,ScalarsTypes,ScalarsS,ScalarsPositionThisCall] = Inizializza_Scalari(NewCodeAndOutputState,Init_Vars);
            [OutputBuffer,OutputNames,OutputNumber,SingleLineOutput,MultiLineOutput,OutputTypes,OutputS] = Inizializza_Output(NewCodeAndOutputState);
            QuickVariables=NewCodeAndOutputState.QuickVariables;
            set(handles.Profile5,'userdata',NewCodeAndOutputState);
            set(handles.MyProcessingTags.MCE,'userdata',0);
            set(handles.MyProcessingTags.MCE,'backgroundcolor',handles.ColorIdle);
        else
            NewOuts=  get(handles.MyProcessingTags.MCE_OUT,'userdata');
            CodeAndOutputState = get(handles.Profile5,'userdata');
            [FiltersBuffer,FiltersNames,FiltersNumber,SingleLineFilters,MultiLineFilters,FilterTypes,FilterS] = Inizializza_Filtri(CodeAndOutputState,Init_Vars);
            [ScalarsBuffer,ScalarsNames,ScalarsNumber,SingleLineScalars,MultiLineScalars,ScalarsTypes,ScalarsS,ScalarsPositionThisCall] = Inizializza_Scalari(CodeAndOutputState,Init_Vars);
            [OutputBuffer,OutputNames,OutputNumber,SingleLineOutput,MultiLineOutput,OutputTypes,OutputS] = Inizializza_Output(CodeAndOutputState);
            QuickVariables=CodeAndOutputState.QuickVariables;
            %save TEMP -v7.3
        end
    else
        NewOuts.OutAttivi=0;
        CodeAndOutputState = get(handles.Profile5,'userdata');
        [FiltersBuffer,FiltersNames,FiltersNumber,SingleLineFilters,MultiLineFilters,FilterTypes,FilterS] = Inizializza_Filtri(CodeAndOutputState,Init_Vars);
        [ScalarsBuffer,ScalarsNames,ScalarsNumber,SingleLineScalars,MultiLineScalars,ScalarsTypes,ScalarsS,ScalarsPositionThisCall] = Inizializza_Scalari(CodeAndOutputState,Init_Vars);
        [OutputBuffer,OutputNames,OutputNumber,SingleLineOutput,MultiLineOutput,OutputTypes,OutputS] = Inizializza_Output(CodeAndOutputState);
        QuickVariables=0;
        %save TEMP -v7.3
    end   
end

CVCRCI2_SetupRecordVariablesScript

SizeOfInitBuffer=1:Init_Vars.BufferSize;

%BSA_Setup=Initializa_BSA(handles);
%ClearAllBuffers(handles);

if(~Init_Vars.UpdateNonSynch) %Read non synch PVs once
    for II=1:Init_Vars.NumberOfNoNSynchPVs
        NotSynchProfilePVsReadVariables(:,II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
    end
%     save TEMP
%     NotSynchProfilePVs=repmat(NotSynchProfilePVsReadVariables,[1,Init_Vars.BufferSize]);
end

disp('Entering While Cycle')
%save TEMPSSS2
CVCRCI2_FullDataStructureScript
set(handles.Profile2,'userdata',FullDataStructure);
%Initialize All Screens?

CVCRCI2_Initialize_All_Graphics

if(get(handles.Profile3,'userdata'))
   SPT=get(handles.StartProcessingTool,'userdata');
   handles.MyProcessingTags=SPT.ProcTags;
   handles.MyProcessingPanel=SPT.MainTag;
   set(handles.Profile3,'userdata',0);
end

if(get(handles.Profile7,'userdata'))
   SPT=get(handles.StartMultiScanTool,'userdata');
   %save TEMP
   handles.MyScanTags=SPT.ScanTags;
   handles.MyScanPanel=SPT.MainTag;
   set(handles.Profile7,'userdata',0);
end
ReadCueValid=1;

if(~Init_Vars.KeepPartialEvents) % THIS WORKS IN THE FULLY SYNCHRONOUS MODE ... THE EASY ONE...

while(1)
    drawnow
    PAUSE=get(handles.PAUSE,'backgroundcolor');STOP=get(handles.STOP,'backgroundcolor');CLEAR=get(handles.ClearBufferButton,'backgroundcolor');
    if(PAUSE(1)==handles.ColorOn(1))
        while(1)

        drawnow, PAUSE=get(handles.PAUSE,'backgroundcolor'); STOP=get(handles.STOP,'backgroundcolor'); CLEAR=get(handles.ClearBufferButton,'backgroundcolor');
            if(PAUSE(1)==handles.ColorWait(1))
                set(handles.PAUSE,'backgroundcolor',handles.ColorIdle);
                break
            else
                pause(0.25);
                drawnow
            end
            if(STOP(1)==handles.ColorOn(1))
                Unfreeze_Callback(hObject, eventdata, handles);
                if(BSA)
                    ReleaseeDefs_Callback(hObject, eventdata, handles)
                end
                return
            end
            if(CLEAR(1)==handles.ColorOn(1))
                set(handles.ClearBufferButton,'backgroundcolor',handles.ColorIdle);drawnow;
                CVCRCI2_ClearAllBuffer_Script
            end
        end
    end
    if(STOP(1)==handles.ColorOn(1))
            Unfreeze_Callback(hObject, eventdata, handles);
            if(BSA)
                    ReleaseeDefs_Callback(hObject, eventdata, handles)
            end
            return
    end
    if(CLEAR(1)==handles.ColorOn(1))
            set(handles.ClearBufferButton,'backgroundcolor',handles.ColorIdle);drawnow;
            CVCRCI2_ClearAllBuffer_Script
    end
    
    %Check if any changes in the processed variables, if YES, re-initializa
    %the displays
    if(get(handles.Profile3,'userdata'))
       SPT=get(handles.StartProcessingTool,'userdata');
       handles.MyProcessingTags=SPT.ProcTags;
       handles.MyProcessingPanel=SPT.MainTag;
       set(handles.Profile3,'userdata',0);
    end
    
    if(~isempty(handles.MyProcessingPanel)) % Processing panel is at least saved
        if(ishandle( handles.MyProcessingPanel )) %processing Panel is VALID.
            if(get(handles.MyProcessingTags.MCE,'userdata')) %User requested some changes in the configuration
                NewCodeAndOutputState = get(handles.MyProcessingTags.MCE_VALS,'userdata');
                NewOuts=  get(handles.MyProcessingTags.MCE_OUT,'userdata');
                TemporaryFilterBuffer1=FiltersBuffer{1};
                [FiltersBuffer,FiltersNames,FiltersNumber,SingleLineFilters,MultiLineFilters,FilterTypes,FilterS] = Inizializza_Filtri(NewCodeAndOutputState,Init_Vars);
                FiltersBuffer{1}=TemporaryFilterBuffer1;
                [ScalarsBuffer,ScalarsNames,ScalarsNumber,SingleLineScalars,MultiLineScalars,ScalarsTypes,ScalarsS,ScalarsPositionThisCall] = Inizializza_Scalari(NewCodeAndOutputState,Init_Vars);
                [OutputBuffer,OutputNames,OutputNumber,SingleLineOutput,MultiLineOutput,OutputTypes,OutputS] = Inizializza_Output(NewCodeAndOutputState);
                QuickVariables=NewCodeAndOutputState.QuickVariables;
                set(handles.Profile5,'userdata',NewCodeAndOutputState);
                %Re evaluate all scalars with the new parameters
                
                %disp('Evaluating Synch Scalars')
                
                for XT=1:ScalarsNumber
                   if(AcquisitionBufferCycle>0)
                       TempDestination=1:Init_Vars.BufferSize;
                   else
                       TempDestination=1:AcquisitionBufferLastWrittenElement;
                   end
                   if(ScalarsTypes(XT))
                       ScalarsBuffer(:,XT) = SingleLineScalars{XT}(VS_S(ScalarsS{XT},TempDestination));
                   else
                       NCL=numel(MultiLineScalars);
                       for IT=1:NCL
                           eval(MultiLineScalars{XT}{IT});
                       end
                       ScalarsBuffer(:,XT) = CodeOutput;
                   end  
                end
                
                CVCRCI2_FullDataStructureScript
                set(handles.Profile2,'userdata',FullDataStructure);
                
                %Re initialize all graphics
                CVCRCI2_Initialize_All_Graphics
                set(handles.MyProcessingTags.MCE,'userdata',0);
                set(handles.MyProcessingTags.MCE,'backgroundcolor',handles.ColorIdle);
            end
        end
    else
        %Do nothing... there is no processing panel
    end
    
    
    %disp('Getting Data')
    if(BSA)
        CVCRCI2_BSA_Acquisition_Script
    else %Not BSA
      if(Init_Vars.UpdateNonSynch)
          for II=1:Init_Vars.NumberOfNoNSynchPVs
              NotSynchProfilePVsReadVariables(II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
          end
      end

      for II=1:Init_Vars.BlockSize
          for JJ=1:Init_Vars.NumberOfSynchPVs
              [PvsCue(JJ,II),PvsCue_TS(JJ,II)] = lcaGetSmart(Init_Vars.PvSyncList{JJ});
          end
          for JJ=1:Init_Vars.NumberOfProfiles
              if(mod(II-1,CycleVars(JJ).ReadOnceIn)==0);
                  [ProfileCue{JJ}(II,:),ProfileCue_TS(JJ,II)] = lcaGetSmart(CycleVars(JJ).ProfileName,CycleVars(JJ).LcaGetSize);
              end
          end
      end

      LastValidCueElement = II; 
      
      
      
    end
    %disp('Done')
    
    if(Init_Vars.NumberOfProfiles)
        if(any([CycleVars.Run_Post_Processing]))
            for II=1:Init_Vars.NumberOfProfiles
                if(CycleVars(II).Run_Post_Processing)
                    ProcessedData(II)=CycleVars(II).ProcessingFunction(ProfileCue{II},0,ProfileCue_TS(II,:));
                    if(CycleVars(II).Processing_Comes_With_PID)
                        ProcessedData(II).PulseID=mod(ProcessedData(II).PulseID + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                    elseif(CycleVars(1).Processing_Comes_With_TimeStamps)
                        ProcessedData(II).PulseID=bitand(uint32(imag(ProcessedData(II).TimeStamp)),hex2dec('1FFFF'));
                        ProcessedData(II).PulseID=mod(ProcessedData(II).PulseID + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                    else %timestamps are the one of the readout.
                        ProcessedData(II).PulseID=mod(ProfileCue_TS(II,1:LastValidCueElement) + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                    end
                end
            end
        end
    end

    %disp('starting synchronization')
    
    if(BSA)
        CVCRCI2_SynchronizeEventsBSA  
    else
        CVCRCI2_SynchronizeEvents_nonBSA
    end
    if(~isempty(Destination))
        set(handles.EventsNumber,'string',num2str(AcquisitionBufferLastWrittenElement))
    end
    %disp('Synchronization Done')
    if(~AcquisitionBufferCycle)
        FiltersBuffer{1}(Destination)=true;
    elseif(AcquisitionBufferCycle==1)
        FiltersBuffer{1}(:)=true;
    end
    %disp('Evaluating Synch Scalars')

    CVCRCI2_EvaluatingSynchScalars
    CVCRCI2_EvaluatingFilters
    CVCRCI2_EvaluatingOuts
    
    %Finally Call Display "GUIs"...
    DisplayGuis=get(handles.Displays,'Userdata'); 
    for II=1:DisplayGuis(1).NumberOfDisplays
        ToBeDeleted=0;
        if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
            DisplayGuis(II).CallingFunction(0,1,DisplayGuis(II).ALLTAGS,FullDataStructure,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,ScalarBuffer,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement);
        else %figure does not exist anymore, remember to close it soon
            ToBeDeleted=1;
        end
        if(ToBeDeleted)
            check_open_displays(handles);
            update_current_displays(handles);
        end
    end
    
    if(get(handles.Profile7,'userdata'))
       SPT=get(handles.StartMultiScanTool,'userdata');
       handles.MyScanTags=SPT.ScanTags;
       handles.MyScanPanel=SPT.MainTag;
       set(handles.Profile7,'userdata',0);
    end
    
    %Check if entering in a SCAN...
    if(get(handles.StartScan,'userdata'))
        if(ishandle(handles.MyScanPanel))
            ScanSetting=get(handles.MyScanTags.Ready,'userdata');
        else
            ScanSetting=[];
            set(handles.StartScan,'backgroundcolor',handles.ColorOff);
            pause(0.1);drawnow;set(handles.StartScan,'backgroundcolor',handles.ColorIdle);
            set(handles.StartScan,'userdata',0);
        end
        if(isstruct(ScanSetting))
           %set up buffers for the scan
           PositionGuaranteedPV=find(strcmp(FullDataStructure.ScalarNames,ScanSetting.GuaranteedPV));
           if(~isempty(PositionGuaranteedPV))
               S_Guaranteed=FullDataStructure.ScalarWhereToBeFound(PositionGuaranteedPV,:);
           else
               S_Guaranteed=[0,0,0];
           end
           CurrentCondition=0;
           ScanBuffer=zeros(Init_Vars.BufferSize,ScanSetting.ScanBufferLength);
           CVCRCI2_FullDataStructureScript
           set(handles.Profile2,'userdata',FullDataStructure);
           %set(handles.Profile2,'userdata');
           CVCRCI2_Initialize_All_Graphics
           CVCRCI2_ClearAllBuffer_Script
           
           if(ScanSetting.RestoreStarting)
            for SCPV=1:ScanSetting.NumberOfScanPVs
                RESTORE(SCPV)=lcaGetSmart(ScanSetting.SCANPVLIST{SCPV});
            end
            set(handles.ResumeFreeRun,'userdata',RESTORE);
           end
           drawnow
          
           ScanSetting.Functions{2}();

           set(handles.StopScan,'enable','on');
           
           if(~Init_Vars.UpdateNonSynch) %read them at least once before starting...
              for II=1:Init_Vars.NumberOfNoNSynchPVs
                  NotSynchProfilePVsReadVariables(:,II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
              end
              %you can fill the entire buffer here and forget about it
           end
           
           while(1) %entering scan cycle...
            CurrentCondition=CurrentCondition+1;   
            if(CurrentCondition>ScanSetting.TotalNumberOfConditions)
                break
            end
            
            CurrentScanBufferValues=ScanSetting.ScanBufferValues(CurrentCondition,:);
            
            for SCPV=1:ScanSetting.NumberOfScanPVs
                lcaPutNoWait(ScanSetting.SCANPVLIST{SCPV},ScanSetting.ScanValuesMatrix(CurrentCondition,SCPV));
            end
            %disp('Moving Rows =')
            Destination=ScanSetting.ScanValuesMatrix(CurrentCondition,:);
            DestinationWithDistance=Destination(ScanSetting.WaitUntilArrivedPosition);
            tic
            ExitCondition=1;
            TRYS=0;
            CurrentValue=zeros(size(ScanSetting.WaitUntilArrived));
            AcquiredSamples=0;
            while(ExitCondition) %checks until you are arrived
                TRYS=TRYS+1;
                if(any(DestinationWithDistance))
                    for CheckPV=1:numel(ScanSetting.READOUTPVLIST)   
                        CurrentValue(CheckPV)=lcaGetSmart(ScanSetting.READOUTPVLIST{CheckPV});
                    end
                    
                    Distance=abs(CurrentValue-DestinationWithDistance);
                    
                    if(all(Distance<=(ScanSetting.ToleranceVector+10^-15)) && (toc>ScanSetting.Pause(CurrentCondition)))
                        ExitCondition=0;
                        
                    else
                        pause(0.1);
                        if(mod(TRYS,50)==49)
                            for SCPV=1:ScanSetting.NumberOfScanPVs
                              disp('Reissuing command, distance =')
                              disp(Distance)
                                lcaPutNoWait(ScanSetting.SCANPVLIST{SCPV},ScanSetting.ScanValuesMatrix(CurrentCondition,SCPV));
                            end 
                        end
                        drawnow
                    end
                else
                    if(toc>ScanSetting.Pause(CurrentCondition))
                        ExitCondition=0;
                    else
                        pause(0.1);
                        drawnow
                        if(mod(TRYS,50)==49)
                            for SCPV=1:ScanSetting.NumberOfScanPVs
                                lcaPutNoWait(ScanSetting.SCANPVLIST{SCPV},ScanSetting.ScanValuesMatrix(CurrentCondition,SCPV));
                            end
                        end
                    end
                end
            end
            
            ScanSetting.Functions{3}(); %After each setting;
            
            
            %Arrivati leggi il timestamp attuale se lavora in BSA
            if(BSA)
              
              [~,ats]=lcaGetSmart(Init_Vars.PvSyncList{1});
              LastValidTime=real(ats)+imag(ats)/10^9- 631152000;
              while(isnan(LastValidTime))
                [~,ats]=lcaGetSmart(Init_Vars.PvSyncList{1});
                LastValidTime=real(ats)+imag(ats)/10^9 - 631152000;
              end
              % LastValidTime
               LastValidPulseID = bitand(uint32(imag(ats)),hex2dec('1FFFF'));
            end

            ExitCondition=1;
            while(ExitCondition)
                
                drawnow
                % RECORDING !!
                if(BSA)
                    CVCRCI2_BSA_Acquisition_Script
                else %Not BSA
                    CVCRCI2_Non_BSA_Acquisition_Script
                end
                %disp('Done')

                if(Init_Vars.NumberOfProfiles)
                    if(any([CycleVars.Run_Post_Processing]))
                        for II=1:Init_Vars.NumberOfProfiles
                            if(CycleVars(II).Run_Post_Processing)
                                ProcessedData(II)=CycleVars(II).ProcessingFunction(ProfileCue{II},0,ProfileCue_TS(II,:));
                                if(CycleVars(II).Processing_Comes_With_PID)
                                    ProcessedData(II).PulseID=mod(ProcessedData(II).PulseID + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                                elseif(CycleVars(1).Processing_Comes_With_TimeStamps)
                                    ProcessedData(II).PulseID=bitand(uint32(imag(ProcessedData(II).TimeStamp)),hex2dec('1FFFF'));
                                    ProcessedData(II).PulseID=mod(ProcessedData(II).PulseID + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                                else %timestamps are the one of the readout.
                                    ProcessedData(II).PulseID=mod(ProfileCue_TS(II,1:LastValidCueElement) + CycleVars(1).PulseIDDealy,handles.MAX_Pulse_ID);
                                end
                            end
                        end
                    end
                end
                
                if(BSA)
                    if(~isempty(ValidDataArray_PV))
                      CVCRCI2_SynchronizeEvents_with_guaranteed_BSA
                    end
                else %Not BSA
                      CVCRCI2_SynchronizeEvents_with_guaranteed
                end
                %if(~isempty(Destination) && ~isempty(NewDataFoundLength)
                %&& (length(Destination) == NewDataFoundLength))
                if(~BSA)
                  if(~isempty(Destination) && (length(Destination)==NewDataFoundLength ))% && ~isempty(NewDataFoundLength) && (length(Destination) == NewDataFoundLength))
                    AcquiredSamples=AcquiredSamples+NewDataFoundLength;
                    %CurrentScanBufferValues
                    ScanBuffer(Destination,:)= repmat(CurrentScanBufferValues,NewDataFoundLength,1);
                    if(~isempty(NotSynchProfilePVsReadVariables))
                        NotSynchProfilePVs(Destination,:)= repmat(NotSynchProfilePVsReadVariables,NewDataFoundLength,1);
                    end
                    set(handles.EventsNumber,'string',[num2str(AcquisitionBufferLastWrittenElement),'/',num2str(AcquiredSamples)]);

                    %disp('Synchronization Done')
                    if(~AcquisitionBufferCycle)
                        FiltersBuffer{1}(Destination)=true;
                    end

                    CVCRCI2_EvaluatingSynchScalars
                    CVCRCI2_EvaluatingFilters
                    CVCRCI2_EvaluatingOuts
                  end
                
                else
                  if(~isempty(Destination) && GrabTurn && (length(Destination)==NewDataFoundLength ))% && ~isempty(NewDataFoundLength) && (length(Destination) == NewDataFoundLength))
                    AcquiredSamples=AcquiredSamples+NewDataFoundLength;

                    ScanBuffer(Destination,:)= repmat(CurrentScanBufferValues,NewDataFoundLength,1);
%                     if(~isempty(NotSynchProfilePVsReadVariables))
%                         NotSynchProfilePVs(Destination,:)= repmat(NotSynchProfilePVsReadVariables,NewDataFoundLength,1);
%                     end
                    set(handles.EventsNumber,'string',[num2str(AcquisitionBufferLastWrittenElement),'/',num2str(AcquiredSamples)]);

                    %disp('Synchronization Done')
                    if(~AcquisitionBufferCycle)
                        FiltersBuffer{1}(Destination)=true;
                    end

                    CVCRCI2_EvaluatingSynchScalars
                    CVCRCI2_EvaluatingFilters
                    CVCRCI2_EvaluatingOuts
                  end
                  
                end
                
                %disp(['Getting Data ',num2str(AcquiredSamples)])
                DisplayGuis=get(handles.Displays,'Userdata'); 
                for II=1:DisplayGuis(1).NumberOfDisplays
                    ToBeDeleted=0;
                    if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
                        DisplayGuis(II).CallingFunction(0,1,DisplayGuis(II).ALLTAGS,FullDataStructure,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,ScalarBuffer,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement);
                    else %figure does not exist anymore, remember to close it soon
                        ToBeDeleted=1;
                    end
                    if(ToBeDeleted)
                        check_open_displays(handles);
                        update_current_displays(handles);
                    end
                end
                
                COLORESTOP=get(handles.StopScan,'backgroundcolor');
                if(~any(COLORESTOP-handles.ColorWait))
                    break
                end    
                if(AcquiredSamples>=ScanSetting.NumberOfEvents)
                    ExitCondition=0;
                end
            end
            if(~any(COLORESTOP-handles.ColorWait))
                    break
            end
            %going to the next sample...
            
           end %lo scan viene effettivamente fatto
           %Lo scan e' finito puoi continuare a vedere i dati e eventualmente salvarli
           ScanSetting.Functions{4}();
           set(handles.StartScan,'backgroundcolor',handles.ColorIdle);set(handles.StartScan,'enable','off');
           set(handles.StopScan,'backgroundcolor',handles.ColorIdle);set(handles.StopScan,'enable','off');
           set(handles.ResumeFreeRun,'backgroundcolor',handles.ColorOn);set(handles.ResumeFreeRun,'enable','on');
           set(handles.StartScan,'Userdata',0);set(handles.StopScan,'Userdata',0);set(handles.ResumeFreeRun,'Userdata',0);
           drawnow
           while(1)
              COLORERESUME=get(handles.ResumeFreeRun,'backgroundcolor');
              if(~any(COLORERESUME-handles.ColorWait))
                    ScanSetting.ScanBufferNames={};
                    ScanSetting.ScanBufferLength=0;
                    CVCRCI2_FullDataStructureScript
                    CVCRCI2_ClearAllBuffer_Script
                    CVCRCI2_Initialize_All_Graphics
                    set(handles.START,'enable','off'); set(handles.PAUSE,'enable','on'); set(handles.STOP,'enable','on');
                    set(handles.START,'string','Start'); set(handles.PAUSE,'string','Pause'); set(handles.STOP,'string','Stop');
                    set(handles.START,'backgroundcolor',handles.ColorOn); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle);drawnow
                    set(handles.StartScan,'enable','on'); set(handles.StartScan,'Userdata',0);
                    set(handles.ResumeFreeRun,'enable','off'); set(handles.ResumeFreeRun,'Userdata',0); set(handles.ResumeFreeRun,'backgroundcolor',handles.ColorIdle);
                    break
              end
              DisplayGuis=get(handles.Displays,'Userdata'); 
                for II=1:DisplayGuis(1).NumberOfDisplays
                    ToBeDeleted=0;
                    if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
                        DisplayGuis(II).CallingFunction(0,1,DisplayGuis(II).ALLTAGS,FullDataStructure,PulseIDMatrix,TimeStampsMatrix,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,ScalarBuffer,FiltersBuffer,ScalarsBuffer,ScanBuffer,AcquisitionBufferCycle,AcquisitionTotalSynchronousEvents,AcquisitionBufferNextWrittenElement,AcquisitionBufferLastWrittenElement);
                    else %figure does not exist anymore, remember to close it soon
                        ToBeDeleted=1;
                    end
                    if(ToBeDeleted)
                        check_open_displays(handles);
                        update_current_displays(handles);
                    end
                end
                pause(0.2);
           end
           
           %chiamerei la cancella buffer...
           CVCRCI2_ClearAllBuffer_Script
           %restore previous buffers
           
        end %scan setting e' struttura e quindi, forse si puo' fare
        
    end
end
else %THIS WORKS IN THE FULLY ASYNCHRONOUS MODE
    
    while(1) %Questo e' il ciclo dell'asincrono
        
    drawnow
    PAUSE=get(handles.PAUSE,'backgroundcolor');STOP=get(handles.STOP,'backgroundcolor');CLEAR=get(handles.ClearBufferButton,'backgroundcolor');
    if(PAUSE(1)==handles.ColorOn(1))
        while(1)

        drawnow, PAUSE=get(handles.PAUSE,'backgroundcolor'); STOP=get(handles.STOP,'backgroundcolor'); CLEAR=get(handles.ClearBufferButton,'backgroundcolor');
            if(PAUSE(1)==handles.ColorWait(1))
                set(handles.PAUSE,'backgroundcolor',handles.ColorIdle);
                break
            else
                pause(0.25);
                drawnow
            end
            if(STOP(1)==handles.ColorOn(1))
                Unfreeze_Callback(hObject, eventdata, handles);
                return
            end
            if(CLEAR(1)==handles.ColorOn(1))
                set(handles.ClearBufferButton,'backgroundcolor',handles.ColorIdle);drawnow;
                %ClearAllBuffers(handles);
            end
        end
    end
    if(STOP(1)==handles.ColorOn(1))
            Unfreeze_Callback(hObject, eventdata, handles);
            %save STOPPING -v7.3
            return
    end
    if(CLEAR(1)==handles.ColorOn(1))
            set(handles.ClearBufferButton,'backgroundcolor',handles.ColorIdle);drawnow;
            CVCRCI2_ClearAllBuffer_Script
    end
    
    if(BSA)
        CVCRCI2_BSA_Acquisition_Script
    else %Not BSA
        
      if(Init_Vars.UpdateNonSynch)
          for II=1:Init_Vars.NumberOfNoNSynchPVs
              NotSynchProfilePVsReadVariables(II)=lcaGetSmart(Init_Vars.PvNotSyncList{II});
          end
      end

      for II=1:Init_Vars.BlockSize
          for JJ=1:Init_Vars.NumberOfSynchPVs
              [PvsCue(JJ,II),PvsCue_TS(JJ,II)] = lcaGetSmart(Init_Vars.PvSyncList{JJ});
          end
          for JJ=1:Init_Vars.NumberOfProfiles
              if(mod(II-1,CycleVars(JJ).ReadOnceIn)==0);
                  [ProfileCue{JJ}(II,:),ProfileCue_TS(JJ,II)] = lcaGetSmart(CycleVars(JJ).ProfileName,CycleVars(JJ).LcaGetSize);
              end
          end
      end

      LastValidCueElement = II; 
 
    end
    %disp('Done')
    
    if(Init_Vars.NumberOfProfiles)
        if(any([CycleVars.Run_Post_Processing]))
            for II=1:Init_Vars.NumberOfProfiles
                if(CycleVars(II).Run_Post_Processing)
                    ProcessedData(II)=CycleVars(II).ProcessingFunction(ProfileCue{II},0,ProfileCue_TS(II,:));
                    if(CycleVars(II).Processing_Comes_With_PID)
                        
                    elseif(CycleVars(1).Processing_Comes_With_TimeStamps)
                        ProcessedData(II).PulseID=bitand(uint32(imag(ProcessedData(II).TimeStamp)),hex2dec('1FFFF'));
                        
                    else %timestamps are the one of the readout.
                        ProcessedData(II).PulseID=ProfileCue_TS(II,1:LastValidCueElement);
                    end
                end
            end
        end
    end
  
    if(BSA)
        if(GrabTurn)
            CVCRCI2_Partial_Synch_BSA_script 
        end
    else
            CVCRCI2_Partial_Synch_non_BSA_script
    end
    
    set(handles.EventsNumber,'string',num2str(MAXEVENTS))

    %disp('Synchronization Done')
    
%     if(~AcquisitionBufferCycle)
%         FiltersBuffer{1}(Destination)=true;
%     elseif(AcquisitionBufferCycle==1)
%         FiltersBuffer{1}(:)=true;
%     end

    %disp('Evaluating Synch Scalars')
    
    %Finally Call Display "GUIs"...
%    AbsoluteEventCounterMatrix <-AcquisitionTotalSynchronousEvents
%         AbsoluteEventCounterProfiles <-AcquisitionBufferCycle
%         FullPulseIDMatrix <- PulseIDMatrix
%         FullPulseIDProfiles <- TimeStampsMatrix
%         BSA <- ScalarsBuffer
    DisplayGuis=get(handles.Displays,'Userdata'); 
    for II=1:DisplayGuis(1).NumberOfDisplays
        ToBeDeleted=0;
        if(ishandle(DisplayGuis(II).Displayhandle)) %figure exists, update it
            DisplayGuis(II).CallingFunction(0,0,DisplayGuis(II).ALLTAGS,FullDataStructure,FullPulseIDMatrix,FullPulseIDProfiles,AbsoluteEventCounterMatrix,ProfileBuffer,SynchProfilePVs,NotSynchProfilePVs,ScalarBuffer,FiltersBuffer,BSA,ScanBuffer,AbsoluteEventCounterProfiles,AcquisitionTotalSynchronousEvents,FullAcquisitionBufferNextWrittenElement,FullAcquisitionBufferLastWrittenElement);
        else %figure does not exist anymore, remember to close it soon
            ToBeDeleted=1;
        end
        if(ToBeDeleted)
            check_open_displays(handles);
            update_current_displays(handles);
        end
    end
    
    if(get(handles.Profile7,'userdata'))
       SPT=get(handles.StartMultiScanTool,'userdata');
       handles.MyScanTags=SPT.ScanTags;
       handles.MyScanPanel=SPT.MainTag;
       set(handles.Profile7,'userdata',0);
    end
    
    % FAI GIRARE LO SCAN ...
    
    CVCRCI2_PartialScanScript
    
    %disp('finito il ciclo')
    end
end


function [FiltersBuffer,FiltersNames,FiltersNumber,SingleLineFilters,MultiLineFilters,FilterTypes,FilterS]=Inizializza_Filtri(CodeAndOutputState,Init_Vars)
FiltersBuffer{1}=false(Init_Vars.BufferSize,1);
FiltersNames={};
FiltersNumber=0;
SingleLineFilters={};
MultiLineFilters={};
FilterTypes=[];
FilterS={};
if(CodeAndOutputState.NumeroFiltri > 0)
    for TT=1:CodeAndOutputState.NumeroFiltri
        FiltersBuffer{TT+1}=false(Init_Vars.BufferSize,1);
        FiltersNames{TT}=CodeAndOutputState.Filtri(TT).nome;
        if(CodeAndOutputState.Filtri(TT).type<2)
            ['@',CodeAndOutputState.Filtri(TT).code]
            SingleLineFilters{TT}=eval(['@',CodeAndOutputState.Filtri(TT).code]);
            FilterTypes(TT)=1;
            FilterS{TT}=CodeAndOutputState.Filtri(TT).S;
        else
            MultiLineFilters{TT}=CodeAndOutputState.Filtri(TT).code;
            FilterTypes(TT)=0;
        end
    end
    FiltersNumber=CodeAndOutputState.NumeroFiltri;
else
    
end

function [ScalarsBuffer,ScalarsNames,ScalarsNumber,SingleLineScalars,MultiLineScalars,ScalarsTypes,ScalarsS,ScalarsPositionThisCall]=Inizializza_Scalari(CodeAndOutputState,Init_Vars)
ScalarsBuffer={};
ScalarsNames={};
ScalarsNumber=0;
SingleLineScalars=[];
MultiLineScalars=[];
ScalarsTypes=[];
ScalarsS=[];
ScalarsPositionThisCall=[];
VariabiliScalari=0;
%save TEMPSSS
if(CodeAndOutputState.NumeroScalari > 0)
    for TT=1:CodeAndOutputState.NumeroScalari
        VariabiliScalari=VariabiliScalari+1;
        if(iscell(CodeAndOutputState.Scalari(TT).nome))
            for SS=1:numel(CodeAndOutputState.Scalari(TT).nome)
                ScalarsNames{end+1}=CodeAndOutputState.Scalari(TT).nome{SS};
            end
        else
            ScalarsNames{end+1}=CodeAndOutputState.Scalari(TT).nome;
        end
        
        if(CodeAndOutputState.Scalari(TT).type<2)
            SingleLineScalars{TT}=eval(['@',CodeAndOutputState.Scalari(TT).code]);
            ScalarsTypes(TT)=1;
            ScalarsS{TT}=CodeAndOutputState.Scalari(TT).S;
        else
            MultiLineScalars{TT}=CodeAndOutputState.Scalari(TT).code;
            ScalarsTypes(TT)=0;
        end
        ScalarsPositionThisCall(TT,:)=[VariabiliScalari,(VariabiliScalari+CodeAndOutputState.Scalari(TT).outs-1)];
        VariabiliScalari=ScalarsPositionThisCall(TT,2);
    end
    ScalarsNumber=CodeAndOutputState.NumeroScalari;
    ScalarsBuffer=zeros(Init_Vars.BufferSize,VariabiliScalari);
else
    
end

function [OutputBuffer,OutputNames,OutputNumber,SingleLineOutput,MultiLineOutput,OutputTypes,OutputS]=Inizializza_Output(CodeAndOutputState)
OutputBuffer=[];
OutputNames={};
OutputNumber=0;
SingleLineOutput=[];
MultiLineOutput=[];
OutputTypes=[];
OutputS=[];
if(CodeAndOutputState.NumeroOutput > 0)
    OutputBuffer=zeros(7,1);
    for TT=1:CodeAndOutputState.NumeroOutput
        OutputNames{TT}=CodeAndOutputState.Output(TT).nome;
        if(CodeAndOutputState.Output(TT).type<2)
            SingleLineOutput{TT}=eval(['@',CodeAndOutputState.Output(TT).code]);
            OutputTypes(TT)=1;
            OutputS{TT}=CodeAndOutputState.Output(TT).S;
        else
            MultiLineOutput{TT}=CodeAndOutputState.Output(TT).code;
            OutputTypes(TT)=0;
        end
    end
    OutputNumber=CodeAndOutputState.NumeroOutput;
else
    
end

% --- Executes on button press in ClearBufferButton.
function ClearBufferButton_Callback(hObject, eventdata, handles)
set(handles.ClearBufferButton,'backgroundcolor',handles.ColorOn);
drawnow


% --- Executes on selection change in TypeOfStart.
function TypeOfStart_Callback(hObject, eventdata, handles)
% hObject    handle to TypeOfStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TypeOfStart contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypeOfStart


% --- Executes during object creation, after setting all properties.
function TypeOfStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypeOfStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in BSAMode.
function BSAMode_Callback(hObject, eventdata, handles)
% hObject    handle to BSAMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BSAMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BSAMode


% --- Executes during object creation, after setting all properties.
function BSAMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BSAMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PluseOneBox_Callback(hObject, eventdata, handles)
% hObject    handle to PluseOneBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PluseOneBox as text
%        str2double(get(hObject,'String')) returns contents of PluseOneBox as a double


% --- Executes during object creation, after setting all properties.
function PluseOneBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PluseOneBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PlusOneDelay_Callback(hObject, eventdata, handles)
% hObject    handle to PlusOneDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PlusOneDelay as text
%        str2double(get(hObject,'String')) returns contents of PlusOneDelay as a double


% --- Executes during object creation, after setting all properties.
function PlusOneDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlusOneDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BufferSize_Callback(hObject, eventdata, handles)
% hObject    handle to BufferSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BufferSize as text
%        str2double(get(hObject,'String')) returns contents of BufferSize as a double


% --- Executes during object creation, after setting all properties.
function BufferSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BufferSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DBCycle_Callback(hObject, eventdata, handles)
% hObject    handle to DBCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DBCycle as text
%        str2double(get(hObject,'String')) returns contents of DBCycle as a double


% --- Executes during object creation, after setting all properties.
function DBCycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DBCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BlockSize_Callback(hObject, eventdata, handles)
% hObject    handle to BlockSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BlockSize as text
%        str2double(get(hObject,'String')) returns contents of BlockSize as a double


% --- Executes during object creation, after setting all properties.
function BlockSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlockSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UpdateMultiScanTool.
function UpdateMultiScanTool_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateMultiScanTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UpdateMultiScanTool

% --- Executes during object creation, after setting all properties.
function ProfileSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProfileSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ProfilePVName_Callback(hObject, eventdata, handles)
% hObject    handle to ProfilePVName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ProfilePVName as text
%        str2double(get(hObject,'String')) returns contents of ProfilePVName as a double


% --- Executes during object creation, after setting all properties.
function ProfilePVName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProfilePVName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TakeOne.
function TakeOne_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
profile=handles.Profili(PN).ProfileName;
SizeX=prod(handles.Profili(PN).CameraSize.X);
SizeY=prod(handles.Profili(PN).CameraSize.Y);
if((SizeX ==1 ) || (SizeY == 1 ) )
    [prof,ts_old]=lcaGetSmart(profile,SizeX*SizeY,handles.Profili(PN).Type);
    A=figure(1000);
    plot(prof)
else
    [prof,ts_old]=lcaGetSmart(profile,SizeX*SizeY,handles.Profili(PN).Type);
    A=figure(1000);
    imagesc(reshape(prof,[SizeX,SizeY]));
end
% % [prof,ts_old]=lcaGetSmart(profile,);
% A=figure(1000);
% save TEMP
% if((prod(handles.Profili(PN).CameraSize.X) ==1 ) || (prod(handles.Profili(PN).CameraSize.Y) == 1 ) )
%     plot(prof)
% else
%     imagesc(reshape(prof,prod(handles.Profili(PN).CameraSize.X),prod(handles.Profili(PN).CameraSize.Y)));
% end

% --- Executes on button press in TakeBackground.
function TakeBackground_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
TimeOutTime=15;
profile=handles.Profili(PN).ProfileName;
SizeX=prod(handles.Profili(PN).CameraSize.X);
SizeY=prod(handles.Profili(PN).CameraSize.Y);
BackgroundImagesNumber=round(str2num(get(handles.BlockSize,'string')));
Pid_Old=-1;
tic,Time=toc;
Inserite=0;
while ( (Inserite < BackgroundImagesNumber) && (Time<TimeOutTime) )
    [prof,ts]=lcaGetSmart(profile,SizeX*SizeY,handles.Profili(PN).Type);
    PID=bitand(uint32(imag(ts)),hex2dec('1FFFF'));
    PID
    if(PID~=Pid_Old)
        if(Inserite==0)
            BackgroundImagesVector=zeros([size(prof),BackgroundImagesNumber]);
        end
        Inserite=Inserite+1;
        BackgroundImagesVector(:,:,Inserite)=prof;
        Time=toc;
        Pid_Old=PID;
    end
end
BackgroundImagesVector=BackgroundImagesVector(:,:,1:Inserite);
BackgroundAverage=mean(BackgroundImagesVector,3);
handles.Profili(PN).BackgroundStored=1;
handles.Profili(PN).BackgroundData=BackgroundAverage;
if(exist([handles.ConfigAndBackgroundsDirectory,'/','StoredBackgroundsFile'],'file'))
    load([handles.ConfigAndBackgroundsDirectory,'/','StoredBackgroundsFile'],'Backgrounds');
    ProfileNames={Backgrounds(:).profilename};
    IND=find(strcmpi(profile,ProfileNames));
    if(~isempty(IND))
        Backgrounds(IND).profilename=profile;
        Backgrounds(IND).Value=BackgroundAverage;
        Backgrounds(IND).Size=length(BackgroundAverage);
    else
        Backgrounds(end+1).profilename=profile;
        Backgrounds(end).Value=BackgroundAverage;
        Backgrounds(end).Size=length(BackgroundAverage);
    end
else
    Backgrounds(1).profilename=profile;
    Backgrounds(1).Value=BackgroundAverage;
    Backgrounds(1).Size=length(BackgroundAverage);
end
save([handles.ConfigAndBackgroundsDirectory,'/','StoredBackgroundsFile'],'Backgrounds');
guidata(hObject, handles);
ProfileSelection_Callback(hObject, eventdata, handles);


% --- Executes on button press in ClearBackground.
function ClearBackground_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).BackgroundStored=0;
handles.Profili(PN).BackgroundData=0;
guidata(hObject, handles);
ProfileSelection_Callback(hObject, eventdata, handles);


function CropY1_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).ROIY(1)=str2num(get(handles.CropY1,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CropY1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CropY1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CropY2_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).ROIY(2)=str2num(get(handles.CropY2,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CropY2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CropY2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CropX1_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).ROIX(1)=str2num(get(handles.CropX1,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CropX1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CropX1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CropX2_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).ROIX(2)=str2num(get(handles.CropX2,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CropX2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CropX2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PulseIDDelayValue_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).PulseIDDealy=str2num(get(handles.PulseIDDelayValue,'string'));
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);

% --- Executes during object creation, after setting all properties.
function PulseIDDelayValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PulseIDDelayValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ProfileNumber.
function ProfileNumber_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
set(handles.ProfileSelection,'value',handles.Profili(PN).SelectedProfile);
ProfileSelection_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function ProfileNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProfileNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FullData.
function FullData_Callback(hObject, eventdata, handles)
% hObject    handle to FullData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FullData


% --- Executes on button press in KeepFullImage.
function KeepFullImage_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).DataToBeKept(1)=get(hObject,'value');
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);


% --- Executes on button press in XProjection.
function XProjection_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).DataToBeKept(2)=get(hObject,'value');
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);


% --- Executes on button press in YProjection.
function YProjection_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).DataToBeKept(3)=get(hObject,'value');
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);

function RepetitionRate_Callback(hObject, eventdata, handles)
% hObject    handle to RepetitionRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepetitionRate as text
%        str2double(get(hObject,'String')) returns contents of RepetitionRate as a double


% --- Executes during object creation, after setting all properties.
function RepetitionRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepetitionRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EditPvList.
function EditPvList_Callback(hObject, eventdata, handles)
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
set(handles.MainPanel,'visible','off');
set(handles.Launcher,'visible','off');
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);

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


% --- Executes on selection change in AdjustToFrequency.
function AdjustToFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to AdjustToFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AdjustToFrequency contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AdjustToFrequency


% --- Executes during object creation, after setting all properties.
function AdjustToFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdjustToFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in KeepPartialEvents.
function KeepPartialEvents_Callback(hObject, eventdata, handles)
% hObject    handle to KeepPartialEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KeepPartialEvents


% --- Executes on button press in StartProcessingTool.
function StartProcessingTool_Callback(hObject, eventdata, handles)
if(isempty(handles.MyProcessingPanel))
    handles.MyProcessingPanel=CVCRCI_Processing(handles.ProfileMonitorPanel,handles.Profile5);
    child_handles = allchild(handles.MyProcessingPanel);
        for TT=1:numel(child_handles)
           handles.MyProcessingTags.(get(child_handles(TT),'tag'))=child_handles(TT); 
        end
    ProcPanel.ProcTags=handles.MyProcessingTags;
    ProcPanel.MainTag=handles.MyProcessingPanel;
    set(handles.StartProcessingTool,'userdata',ProcPanel);
    set(handles.Profile3,'userdata',1);
    guidata(hObject, handles);
    Get_All_Dimensions_And_Names(handles);
else
    if(ishandle(handles.MyProcessingPanel))
        figure(handles.MyProcessingPanel)
    else
        handles.MyProcessingPanel=CVCRCI_Processing(handles.ProfileMonitorPanel,handles.Profile5);
        child_handles = allchild(handles.MyProcessingPanel);
        for TT=1:numel(child_handles)
           handles.MyProcessingTags.(get(child_handles(TT),'tag'))=child_handles(TT); 
        end
        ProcPanel.ProcTags=handles.MyProcessingTags;
        ProcPanel.MainTag=handles.MyProcessingPanel;
        set(handles.StartProcessingTool,'userdata',ProcPanel);
        set(handles.Profile3,'userdata',1);
        guidata(hObject, handles);
        Get_All_Dimensions_And_Names(handles);
    end
end

function FillProcessingWindows(handles)
if(~isempty(handles.MyProcessingPanel))
    if(ishandle(handles.MyProcessingPanel))
        StrutturaDati=get(handles.ProfileMonitorPanel,'userdata');
        Stringa1={};
        for TT=1:StrutturaDati.Number_of_unsynch_pvs
            Stringa1{end+1}=['@@',num2str(TT),' = ',StrutturaDati.Names_of_unsynch_pvs{TT}];
        end
        set(handles.MyProcessingTags.M1,'string',Stringa1);
        if(~isempty(Stringa1))
            set(handles.MyProcessingTags.M1,'value',1);
        else
            set(handles.MyProcessingTags.M1,'value',0);
        end
        Stringa2={};
        ls=0;
        for TT=1:StrutturaDati.Number_of_synch_pvs
            ls=ls+1;
            Stringa2{end+1}=['#',num2str(ls),' = ',StrutturaDati.Names_of_synch_pvs{TT}];
        end
        for TT=1:StrutturaDati.Number_of_scalar_matrices
           for JJ=1: StrutturaDati.Number_of_scalars_in_a_matrix(TT);
             ls=ls+1;
             Stringa2{end+1}=['#',num2str(ls),' = ',StrutturaDati.Names_of_scalar_inside_matrices{TT,JJ}];
           end
        end
        set(handles.MyProcessingTags.M2,'string',Stringa2);
        if(~isempty(Stringa2))
            set(handles.MyProcessingTags.M2,'value',1);
        else
            set(handles.MyProcessingTags.M2,'value',0);
        end
        Stringa3={};
        ls=0;
        for TT=1:StrutturaDati.Number_of_vectors
            ls=ls+1;
            Stringa3{end+1}=['%',num2str(ls),' = ',StrutturaDati.Names_of_vectors{TT}];
        end
        set(handles.MyProcessingTags.M3,'string',Stringa3);
        if(~isempty(Stringa3))
            set(handles.MyProcessingTags.M3,'value',1);
        else
            set(handles.MyProcessingTags.M3,'value',0);
        end
        Stringa4={};
        ls=0;
        for TT=1:StrutturaDati.Number_of_2Darrays
            ls=ls+1;
            Stringa4{end+1}=['%%',num2str(ls),' = ',StrutturaDati.Names_of_2Darrays{TT}];
        end
        set(handles.MyProcessingTags.M4,'string',Stringa4);
        if(~isempty(Stringa4))
            set(handles.MyProcessingTags.M4,'value',1);
        else
            set(handles.MyProcessingTags.M4,'value',0);
        end
    end
end

% --- Executes on button press in SaveCurrentBuffer.
function SaveCurrentBuffer_Callback(hObject, eventdata, handles)
set(handles.SaveCurrentBuffer,'backgroundColor',handles.ColorOn);
drawnow

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


% --- Executes on button press in Unfreeze.
function Unfreeze_Callback(hObject, eventdata, handles)
set(handles.START,'enable','on'); set(handles.PAUSE,'enable','off'); set(handles.STOP,'enable','off');
set(handles.START,'backgroundcolor',handles.ColorIdle); set(handles.PAUSE,'backgroundcolor',handles.ColorIdle); set(handles.STOP,'backgroundcolor',handles.ColorIdle);
set(handles.StartScan,'enable','off'); set(handles.StopScan,'enable','off'); set(handles.ResumeFreeRun,'enable','off');
set(handles.StartScan,'backgroundcolor',handles.ColorIdle); set(handles.StopScan,'backgroundcolor',handles.ColorIdle); set(handles.ResumeFreeRun,'backgroundcolor',handles.ColorIdle);

EnableButtons(hObject,handles)


% --- Executes on button press in Debug.
function Debug_Callback(hObject, eventdata, handles)
FillProcessingWindows(handles);
% try
% CODICI = get(handles.MyProcessingTags.MCE_VALS,'userdata');
% catch ME
%     CODICI=[];
% end
% CD = get(handles.Displays,'userdata');
try 
    lcaGet('SIOC:SYS0:ML02:AO001')
    save(handles.ConfigurationDirectory,'VOM_DUMPFILE_GUIDATA','-v7.3');
catch ME
    disp('dumping to local disk')
    save VOM_DUMPFILE_GUIDATA -v7.3
end


%get(handles.ProfileMonitorPanel,'userdata')
% save GUISTATE -v7.3

% --- Executes on button press in UpdateNonSynch.
function UpdateNonSynch_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateNonSynch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UpdateNonSynch


% --- Executes on button press in StartMultiScanTool.
function StartMultiScanTool_Callback(hObject, eventdata, handles)
if(isempty(handles.MyScanPanel))
    handles.MyScanPanel=CVCRCI2_Scan_gui();
    child_handles = allchild(handles.MyScanPanel);
        for TT=1:numel(child_handles)
           handles.MyScanTags.(get(child_handles(TT),'tag'))=child_handles(TT); 
        end
        ScanPanel.ScanTags=handles.MyScanTags;
        ScanPanel.MainTag=handles.MyScanPanel;
        set(handles.StartMultiScanTool,'userdata',ScanPanel);
        set(handles.Profile7,'userdata',1);
    guidata(hObject, handles);
else
    if(ishandle(handles.MyScanPanel))
        figure(handles.MyScanPanel)
    else
        handles.MyScanPanel=CVCRCI2_Scan_gui();
        child_handles = allchild(handles.MyScanPanel);
        for TT=1:numel(child_handles)
           handles.MyScanTags.(get(child_handles(TT),'tag'))=child_handles(TT); 
        end
        ScanPanel.ScanTags=handles.MyScanTags;
        ScanPanel.MainTag=handles.MyScanPanel;
        set(handles.StartMultiScanTool,'userdata',ScanPanel);
        set(handles.Profile7,'userdata',1);
        guidata(hObject, handles);
    end
end

% --- Executes on selection change in PostAcquisitionFunction.
function PostAcquisitionFunction_Callback(hObject, eventdata, handles)
FUNVAL=get(handles.PostAcquisitionFunction,'value');
PN=get(handles.ProfileNumber,'value');
PS=get(handles.ProfileSelection,'value');
handles.Profili(PN).PostProcessingFunctionsList=handles.PostProcessingDefault{PS};
%['@',handles.PostProcessingDefault{PS}{FUNVAL}]
handles.Profili(PN).PostProcessing_CalledFunction=eval(['@',handles.PostProcessingDefault{PS}{FUNVAL}]);
handles.Profili(PN).PostProcessingFunctionsValue=FUNVAL;
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);

% --- Executes during object creation, after setting all properties.
function PostAcquisitionFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PostAcquisitionFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveConfiguration.
function SaveConfiguration_Callback(hObject, eventdata, handles)
CONFIGURATION.CONTMODE=get(handles.TypeOfStart,'value');
CONFIGURATION.BSAMODE=get(handles.BSAMode,'value');
CONFIGURATION.BSACORRECTION{1}=get(handles.PluseOneBox,'string');
CONFIGURATION.BSACORRECTION{2}=get(handles.PlusOneDelay,'string');
CONFIGURATION.BSACORRECTION{3}=get(handles.synchfirst,'string');
CONFIGURATION.BUFFERSIZE=get(handles.BufferSize,'string');
CONFIGURATION.DBOneFourthOfCycle=get(handles.DBCycle,'string');
CONFIGURATION.BlockSize=get(handles.BlockSize,'string');
CONFIGURATION.KeepPartialEvents=get(handles.KeepPartialEvents,'value');
CONFIGURATION.VarBufSize=get(handles.ProfVarBuf,'value');
CONFIGURATION.UpdateNonSynch=get(handles.UpdateNonSynch,'value');
CONFIGURATION.AdjustTo=get(handles.AdjustToFrequency,'value');
CONFIGURATION.Profili=handles.Profili;
CONFIGURATION.SynchPVs=get(handles.PvSyncList,'string');
CONFIGURATION.PvNotSyncList=get(handles.PvNotSyncList,'string');
[FileName,Path]=uiputfile([handles.ConfigurationDirectory,'/*.mat'], 'Pick a file name for the configuration');
FileName=['VOM_CONF_',FileName];
if(isnumeric(FileName) || isnumeric(Path))
    set(handles.SaveConfiguration,'backgroundcolor',handles.ColorOff);
    drawnow, pause(1)
    set(handles.SaveConfiguration,'backgroundcolor',handles.ColorIdle);
else
    save([handles.ConfigurationDirectory,'/',FileName],'CONFIGURATION');
end

% --- Executes on button press in LoadConfiguration.
function LoadConfiguration_Callback(hObject, eventdata, handles)
[FileName,Path]=uigetfile([handles.ConfigurationDirectory,'/VOM_CONF_*.mat'], 'Select Configuration to be loaded');
if(isnumeric(FileName) || isnumeric(Path))
    set(handles.LoadConfiguration,'backgroundcolor',handles.ColorOff);
    drawnow, pause(1)
    set(handles.LoadConfiguration,'backgroundcolor',handles.ColorIdle);
    return
else
    load([handles.ConfigurationDirectory,'/',FileName],'CONFIGURATION');
end
set(handles.TypeOfStart,'value',CONFIGURATION.CONTMODE);
set(handles.BSAMode,'value',CONFIGURATION.BSAMODE);
set(handles.PluseOneBox,'string',CONFIGURATION.BSACORRECTION{1});
set(handles.PlusOneDelay,'string',CONFIGURATION.BSACORRECTION{2});
set(handles.synchfirst,'string',CONFIGURATION.BSACORRECTION{3});
set(handles.BufferSize,'string',CONFIGURATION.BUFFERSIZE);
set(handles.DBCycle,'string',CONFIGURATION.DBOneFourthOfCycle);
set(handles.BlockSize,'string',CONFIGURATION.BlockSize);
set(handles.KeepPartialEvents,'value',CONFIGURATION.KeepPartialEvents);
set(handles.ProfVarBuf,'value',CONFIGURATION.VarBufSize);
set(handles.UpdateNonSynch,'value',CONFIGURATION.UpdateNonSynch);
set(handles.AdjustToFrequency,'value',CONFIGURATION.AdjustTo);
handles.Profili=CONFIGURATION.Profili;
set(handles.PvSyncList,'string',CONFIGURATION.SynchPVs);
set(handles.PvNotSyncList,'string',CONFIGURATION.PvNotSyncList);
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);

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

% --- Executes on button press in epv_ClosePanel.
function epv_ClosePanel_Callback(hObject, eventdata, handles)
current_list1=get(handles.epv_MylistSync,'string');
current_list2=get(handles.epv_MylistNotSync,'string');
set(handles.PvSyncList,'string',current_list1);
set(handles.PvNotSyncList,'string',current_list2);
set(handles.MainPanel,'visible','on');
set(handles.PvlistPanel,'visible','off');
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);


% --- Executes on button press in LoadBackground.
function LoadBackground_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
profile=handles.Profili(PN).ProfileName;
SizeX=prod(handles.Profili(PN).CameraSize.X);
SizeY=prod(handles.Profili(PN).CameraSize.Y);
%save temp
if(exist([handles.ConfigAndBackgroundsDirectory,'/','StoredBackgroundsFile','.mat'],'file'))
    load([handles.ConfigAndBackgroundsDirectory,'/','StoredBackgroundsFile'],'Backgrounds');
    ProfileNames={Backgrounds(:).profilename};
    IND=find(strcmpi(profile,ProfileNames));
    if(~isempty(IND))
        if(Backgrounds(IND).Size == (SizeX*SizeY))
            handles.Profili(PN).BackgroundStored=1;
            handles.Profili(PN).BackgroundData=Backgrounds(IND).Value;
            ProfileSelection_Callback(hObject, eventdata, handles);
        else

        end
    else

    end
else

end
guidata(hObject, handles);

% --- Executes on button press in ProfileReadSize.
function handles=ProfileReadSize_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
PS=get(handles.ProfileSelection,'value');
if(ischar(handles.ProfileListROIPvs{PS,1}))
    try
        CameraSizeX=lcaGetSmart(handles.ProfileListROIPvs{PS,1});
    catch ME
        CameraSizeX=NaN;
    end
else
    CameraSizeX=handles.ProfileListROIPvs{PS,1};
end
if(ischar(handles.ProfileListROIPvs{PS,2}))
    try
        CameraSizeY=lcaGetSmart(handles.ProfileListROIPvs{PS,2});
    catch ME
        CameraSizeY=NaN;
    end
else
    CameraSizeY=handles.ProfileListROIPvs{PS,2};
end
if(isnan(CameraSizeX))
    CameraSizeX=handles.ProfileListROIPvs{PS,3};
end
if(isnan(CameraSizeY))
    CameraSizeY=handles.ProfileListROIPvs{PS,4};
end
%save TEMP
if(ischar(handles.ProfileListROIPvs{PS,5}) && ischar(handles.ProfileListROIPvs{PS,6}) ) %XSTART, XEND DEFINITION
    CameraSizeX=lcaGetSmart(handles.ProfileListROIPvs{PS,6}) - lcaGetSmart(handles.ProfileListROIPvs{PS,5}) +1;
end
if(ischar(handles.ProfileListROIPvs{PS,7}) && ischar(handles.ProfileListROIPvs{PS,8}) ) %XSTART, XEND DEFINITION
    CameraSizeY=lcaGetSmart(handles.ProfileListROIPvs{PS,8}) - lcaGetSmart(handles.ProfileListROIPvs{PS,7}) +1;
end

handles.Profili(PN).ROIX=[1,CameraSizeX]; handles.Profili(PN).ROIY=[1,CameraSizeY]; 
handles.Profili(PN).CameraSize.X=handles.Profili(PN).ROIX; handles.Profili(PN).CameraSize.Y=handles.Profili(PN).ROIY;
set(handles.CropX1,'string',num2str(handles.Profili(PN).ROIX(1)));set(handles.CropX2,'string',num2str(handles.Profili(PN).ROIX(2)));
set(handles.CropY1,'string',num2str(handles.Profili(PN).ROIY(1)));set(handles.CropY2,'string',num2str(handles.Profili(PN).ROIY(2)));
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);

% --- Executes on button press in PAUSE.
function PAUSE_Callback(hObject, eventdata, handles)
PAUSE=get(handles.PAUSE,'backgroundColor');
if(PAUSE(1)==handles.ColorOn(1))
    set(handles.PAUSE,'backgroundColor',handles.ColorWait);
end
if(PAUSE(1)==handles.ColorIdle(1))
    set(handles.PAUSE,'backgroundColor',handles.ColorOn);
end
drawnow


% --- Executes on button press in STOP.
function STOP_Callback(hObject, eventdata, handles)
set(handles.STOP,'backgroundColor',handles.ColorOn);
drawnow


% --- Executes during object creation, after setting all properties.
function STOP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in OffLineAnalysisTool.
function OffLineAnalysisTool_Callback(hObject, eventdata, handles)
% hObject    handle to OffLineAnalysisTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CUS1.
function CUS1_Callback(hObject, eventdata, handles)
% hObject    handle to CUS1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CUS2.
function CUS2_Callback(hObject, eventdata, handles)
% hObject    handle to CUS2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CUS3.
function CUS3_Callback(hObject, eventdata, handles)
% hObject    handle to CUS3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TES.
function TES_Callback(hObject, eventdata, handles)
% hObject    handle to TES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AD1.
function AD1_Callback(hObject, eventdata, handles)
% hObject    handle to AD1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AD2.
function AD2_Callback(hObject, eventdata, handles)
% hObject    handle to AD2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in D1.
function D1_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D1,handles);

function check_open_displays(handles)
CD=get(handles.Displays,'Userdata');
if((~CD(1).NumberOfDisplays) && (numel(CD)>1))
    %inconsistency, wipe it out, anyway!! Better Safe than sorry
    keep_only_some_displays_from_list([],handles);
    return
end
if(~CD(1).NumberOfDisplays)
    keep_only_some_displays_from_list([],handles);
    return
else
   OUT=[];
   IN=[];
   for II=1:numel(CD)
       if(ishandle(CD(II).Displayhandle))
         IN(end+1)=II;
       else
         OUT(end+1)=II;  
       end
   end
end

if(~isempty(OUT))
   keep_only_some_displays_from_list(IN,handles); 
end

function keep_only_some_displays_from_list(DisplayIDToKeep,handles)
if(isempty(DisplayIDToKeep))
    %disp('per di qua')
    CurrentDisplays(1).NumberOfDisplays=0;
    CurrentDisplays(1).CallingFunction=@Do_Nothing;
    CurrentDisplays(1).Displayhandle=NaN;
    CurrentDisplays(1).Name='';
    CurrentDisplays(1).NeedsInit=0;
    CurrentDisplays(1).ALLTAGS.void=NaN;
    set(handles.Displays,'userdata',CurrentDisplays);
else
    CD=get(handles.Displays,'Userdata');
    CD=CD(DisplayIDToKeep);
    CD(1).NumberOfDisplays=length(DisplayIDToKeep);
    for TT=1:numel(CD)
        CD(TT).NumberOfDisplays=CD(1).NumberOfDisplays;
    end
    set(handles.Displays,'Userdata',CD);
end
update_current_displays(handles);

function OpenDisplayMyButton(hObject,handles)
check_open_displays(handles);
CD=get(handles.Displays,'Userdata');
THISBUTTON=get(hObject,'userdata');
if((CD(1).NumberOfDisplays==0) || (isnan(CD(1).Displayhandle))) %add the first
    CurrentDisplays(1).NumberOfDisplays=1;
    CurrentDisplays(1).CallingFunction=THISBUTTON.UpdateFunction;
    CurrentDisplays(1).Displayhandle=THISBUTTON.FigureFunction();
    CurrentDisplays(1).Name=THISBUTTON.name;
    CurrentDisplays(1).NeedsInit=1;
    set(handles.Displays,'userdata',CurrentDisplays);
    child_handles = allchild(CurrentDisplays(1).Displayhandle);
    for TT=1:numel(child_handles)
        CurrentDisplays(1).ALLTAGS.(get(child_handles(TT),'tag'))=child_handles(TT); 
    end
    CurrentDataStructure=get(handles.Profile2,'userdata');
    if(isstruct(CurrentDataStructure))
        CurrentDisplays(1).CallingFunction(1,~get(handles.KeepPartialEvents,'value'),CurrentDisplays(1).ALLTAGS,CurrentDataStructure);
    end
    CurrentDataStructure=get(handles.Profile2,'userdata');
    if(isstruct(CurrentDataStructure))
         CurrentDisplays(1).CallingFunction(1,~get(handles.KeepPartialEvents,'value'),CurrentDisplays(1).ALLTAGS,CurrentDataStructure);
    end
    set(handles.Displays,'userdata',CurrentDisplays);
   
else
    if((CD(1).NumberOfDisplays==0) || (isnan(CD(1).Displayhandle)))
        CD(1).CallingFunction=THISBUTTON.UpdateFunction;
    else
        CD(end+1).CallingFunction=THISBUTTON.UpdateFunction;
    end
    CD(end).Displayhandle=THISBUTTON.FigureFunction();
    CD(end).Name=THISBUTTON.name;
    CD(end).NeedsInit=1;
    child_handles = allchild(CD(end).Displayhandle);
    for TT=1:numel(child_handles)
        CD(end).ALLTAGS.(get(child_handles(TT),'tag'))=child_handles(TT); 
    end
    for IK=1:numel(CD)
        CD(IK).NumberOfDisplays=numel(CD);
    end
    CurrentDataStructure=get(handles.Profile2,'userdata');
    if(isstruct(CurrentDataStructure))
        CD(end).CallingFunction(1,1,CD(end).ALLTAGS,CurrentDataStructure);
    end  
    set(handles.Displays,'userdata',CD);
end
update_current_displays(handles);

% --- Executes on button press in D2.
function D2_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D2,handles);

% --- Executes on button press in D3.
function D3_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D3,handles);


% --- Executes on button press in D4.
function D4_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D4,handles);

% --- Executes on button press in D5.
function D5_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D5,handles);


% --- Executes on selection change in Displays.
function Displays_Callback(hObject, eventdata, handles)
% hObject    handle to Displays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Displays contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Displays


% --- Executes during object creation, after setting all properties.
function Displays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Displays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CloseVB.
function CloseVB_Callback(hObject, eventdata, handles)
CD = get(handles.Displays,'userdata');
VAL=get(handles.Displays,'value');
try
    close(CD(VAL).Displayhandle)
catch ME

end
check_open_displays(handles);
update_current_displays(handles);

% --- Executes on button press in CloseAll.
function CloseAll_Callback(hObject, eventdata, handles)
CD = get(handles.Displays,'userdata');
for II=1:numel(CD)
try
    close(CD(II).Displayhandle)
catch ME

end
end
check_open_displays(handles);
update_current_displays(handles);


% --- Executes on button press in StartScan.
function StartScan_Callback(hObject, eventdata, handles)
set(handles.StartScan,'Userdata',1)
set(handles.StartScan,'backgroundcolor',handles.ColorWait)


% --- Executes on button press in StopScan.
function StopScan_Callback(hObject, eventdata, handles)
set(handles.StopScan,'Userdata',0)
set(handles.StopScan,'backgroundcolor',handles.ColorWait);drawnow


% --- Executes on button press in ResumeFreeRun.
function ResumeFreeRun_Callback(hObject, eventdata, handles)
set(handles.ResumeFreeRun,'Userdata',0)
set(handles.ResumeFreeRun,'backgroundcolor',handles.ColorWait);drawnow


% --- Executes on button press in C1.
function C1_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C1,handles);


% --- Executes on button press in C2.
function C2_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C2,handles);


% --- Executes on button press in C3.
function C3_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C3,handles);


% --- Executes on button press in C4.
function C4_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C4,handles);

% --- Executes on button press in C5.
function C5_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C5,handles);


% --- Executes on button press in C6.
function C6_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C6,handles);


% --- Executes on button press in C7.
function C7_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C7,handles);


% --- Executes on button press in C8.
function C8_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C8,handles);


% --- Executes on button press in C9.
function C9_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C9,handles);


% --- Executes on button press in C10.
function C10_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.C10,handles);


% --- Executes on button press in D6.
function D6_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D6,handles);


% --- Executes on button press in D7.
function D7_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D7,handles);

% --- Executes on button press in D8.
function D8_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D8,handles);


% --- Executes on button press in D9.
function D9_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D9,handles);


% --- Executes on button press in D10.
function D10_Callback(hObject, eventdata, handles)
OpenDisplayMyButton(handles.D10,handles);



function synchfirst_Callback(hObject, eventdata, handles)
% hObject    handle to synchfirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of synchfirst as text
%        str2double(get(hObject,'String')) returns contents of synchfirst as a double


% --- Executes during object creation, after setting all properties.
function synchfirst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to synchfirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ProfVarBuf.
function ProfVarBuf_Callback(hObject, eventdata, handles)
% hObject    handle to ProfVarBuf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ProfVarBuf

function setall(CONFIGURATION,handles)
set(handles.TypeOfStart,'value',CONFIGURATION.CONTMODE);
set(handles.BSAMode,'value',CONFIGURATION.BSAMODE);
set(handles.PluseOneBox,'string',CONFIGURATION.BSACORRECTION{1});
set(handles.PlusOneDelay,'string',CONFIGURATION.BSACORRECTION{2});
set(handles.synchfirst,'string',CONFIGURATION.BSACORRECTION{3});
set(handles.BufferSize,'string',CONFIGURATION.BUFFERSIZE);
set(handles.DBCycle,'string',CONFIGURATION.DBOneFourthOfCycle);
set(handles.BlockSize,'string',CONFIGURATION.BlockSize);
set(handles.KeepPartialEvents,'value',CONFIGURATION.KeepPartialEvents);
set(handles.ProfVarBuf,'value',CONFIGURATION.VarBufSize);
set(handles.UpdateNonSynch,'value',CONFIGURATION.UpdateNonSynch);
set(handles.AdjustToFrequency,'value',CONFIGURATION.AdjustTo);
set(handles.PvSyncList,'string',CONFIGURATION.SynchPVs);
set(handles.PvNotSyncList,'string',CONFIGURATION.PvNotSyncList);

% --- Executes on button press in L1.
function L1_Callback(hObject, eventdata, handles) % GENERAL
CONFIGURATION=get(handles.L1,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles)

% --- Executes on button press in L2.
function L2_Callback(hObject, eventdata, handles) % SXR
CONFIGURATION=get(handles.L2,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles);
C1_Callback(hObject, eventdata, handles);
START_Callback(hObject, eventdata, handles);


% --- Executes on button press in L3.
function L3_Callback(hObject, eventdata, handles) % HXR
CONFIGURATION=get(handles.L3,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles);
C1_Callback(hObject, eventdata, handles);
START_Callback(hObject, eventdata, handles);


% --- Executes on button press in L4.
function L4_Callback(hObject, eventdata, handles) 
CONFIGURATION=get(handles.L4,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles)

% --- Executes on button press in L5.
function L5_Callback(hObject, eventdata, handles)
CONFIGURATION=get(handles.L5,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles)

% --- Executes on button press in L6.
function L6_Callback(hObject, eventdata, handles)
CONFIGURATION=get(handles.L6,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles)

% --- Executes on button press in OpenLauncher.
function OpenLauncher_Callback(hObject, eventdata, handles)
set(handles.PvlistPanel,'visible','off'); set(handles.MainPanel,'visible','off'); set(handles.Launcher,'visible','on');


% --- Executes on button press in CLOSELAUNCHER.
function CLOSELAUNCHER_Callback(hObject, eventdata, handles)
set(handles.Launcher,'visible','off');set(handles.MainPanel,'visible','on')



function AsynchBufferSizeRatio_Callback(hObject, eventdata, handles)
PN=get(handles.ProfileNumber,'value');
handles.Profili(PN).AsynchBufferSizeRatio=str2double(get(handles.AsynchBufferSizeRatio,'string'));
guidata(hObject, handles);
Get_All_Dimensions_And_Names(handles);

% --- Executes during object creation, after setting all properties.
function AsynchBufferSizeRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AsynchBufferSizeRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in L9.
function L9_Callback(hObject, eventdata, handles)
CONFIGURATION=get(handles.L9,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles);
C5_Callback(hObject, eventdata, handles);
START_Callback(hObject, eventdata, handles);


% --- Executes on button press in L7.
function L7_Callback(hObject, eventdata, handles)
CONFIGURATION=get(handles.L7,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles);
EditPvList_Callback(hObject, eventdata, handles);
epv_AddList_Callback(hObject, eventdata, handles);
epv_ClosePanel_Callback(hObject, eventdata, handles);


% --- Executes on button press in L8.
function L8_Callback(hObject, eventdata, handles)
CONFIGURATION=get(handles.L4,'userdata');
setall(CONFIGURATION,handles);
handles.Profili=CONFIGURATION.Profili;
guidata(hObject, handles);
ProfileNumber_Callback(hObject, eventdata, handles);
CLOSELAUNCHER_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function L6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
