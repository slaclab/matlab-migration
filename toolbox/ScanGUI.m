function varargout = ScanGUI(varargin)
% SCANGUI MATLAB code for ScanGUI.fig
%      SCANGUI, by itself, creates a new SCANGUI or raises the existing
%      singleton*.
%
%      H = SCANGUI returns the handle to a new SCANGUI or the handle to
%      the existing singleton*.
%
%      SCANGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCANGUI.M with the given input arguments.
%
%      SCANGUI('Property','Value',...) creates a new SCANGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ScanGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stopauto.  All inputs are passed to ScanGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ScanGUI

% Last Modified by GUIDE v2.5 25-Jul-2020 20:07:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ScanGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ScanGUI_OutputFcn, ...
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


% --- Executes just before ScanGUI is made visible.
function ScanGUI_OpeningFcn(hObject, eventdata, handles, varargin)
ULT_ScriptToLoadAllFunctions
handles.ColorWait=[1,0,0]; handles.ColorIdle=get(handles.SetupScan,'backgroundcolor'); handles.ColorGreen=[0,1,0];
handles.SelfDestruction=get(handles.SelfDestruction,'string');
lcaPutSmart(handles.SelfDestruction,0);
handles.UL=UL;
handles.static=static;
handles.sh=sh;
handles.fh=fh;
handles.PhyConsts.c=299792458;
handles.PhyConsts.mc2_e=5.109989180000000e+05;
handles.PhyConsts.echarge=1.602176530000000e-19;
handles.PhyConsts.mu_0=1.256637061435917e-06;
handles.PhyConsts.eps_0=8.854187817620391e-12;
handles.PhyConsts.r_e=2.817940318198647e-15;
handles.PhyConsts.Z_0=3.767303134617707e+02;
handles.PhyConsts.h_bar=1.054571682364455e-34; %J s
handles.PhyConsts.alpha=0.007297352554051;
handles.PhyConsts.Avogadro=6.022141500000000e+23;
handles.PhyConsts.k_Boltzmann=1.380650500000000e-23;
handles.PhyConsts.Stefan_Boltzmann=5.670401243654186e-08;
handles.PhyConsts.hplanck=4.135667516*10^-15;
handles.output = hObject;
handles=ScanType_Callback(hObject, [], handles);
% Update handles structure
Nunc=now;
set(handles.MessageList,'string',{'Interface setting up ..........','....... . ..... ....... . . ..... ....... . . ..... ....... .'})
Date_String=['AD ',datestr(Nunc,'yyyy'), datestr(Nunc, ' dddd mmmm dd  HH:MM:SS.FFF')];
AddMessage(handles.MessageList,[Date_String,' Scan GUI Started. '],50);
guidata(hObject, handles);

% UIWAIT makes ScanGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ScanGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function Timer_Update(TimerObject,Type_and_when,handles,MODE)
Nunc=clock;
Date_String=['AD ',datestr(Nunc,'yyyy'), datestr(Nunc, ' dddd mmmm dd  HH:MM:SS.FFF')];
set(handles.DateString,'string',Date_String);

switch(MODE)
    case -1
        AddMessage(handles.MessageList,[datestr(now),' Timer function Error - Needs to reset listening function. '],50);
    case 0
        AddMessage(handles.MessageList,[datestr(now),' Timer function Stopped - Not Listening anymore'],50);
    case 1 %Normal Operation
        SelfDestruction=lcaGetSmart(handles.SelfDestruction);
        if(SelfDestruction==1)
            AddMessage(handles.MessageList,[datestr(now),' Self-Destruction of Listen mode'],50);
            try
                stop(handles.TIMER);
            end
            try
                delete(handles.TIMER);
            end
            set(handles.Timer_Start,'enable','on'); set(handles.tabula,'visible','off');
        end
        SetupStructure=get(handles.GO,'userdata');
        CurrentValues=lcaGetSmart(SetupStructure.ListenPV); OldValues=get(handles.SetValue,'userdata');
        if(any(CurrentValues~=OldValues))
            TABULA=get(handles.tabula,'data');
            MOVE=1;
            for II=1:numel(SetupStructure.ListenPV)
                    TABULA{II,5}=CurrentValues(II);
  
                    if(CurrentValues(II)<TABULA{II,2})
                        MOVE=0; AddMessage(handles.MessageList,[datestr(now),' ',TABULA{II,1},' too low ;  ',num2str(CurrentValues(II)), ' < ' num2str(TABULA{II,2})],50);
                    elseif(CurrentValues(II)>TABULA{II,3})
                        MOVE=0; AddMessage(handles.MessageList,[datestr(now),' ',TABULA{II,1},' too high ;  ',num2str(CurrentValues(II)), ' > ' num2str(TABULA{II,3})],50);
                    end
            end
            set(handles.tabula,'data',TABULA); set(handles.SetValue,'userdata',CurrentValues);
            if(MOVE)
                lcaPutSmart(SetupStructure.MovePV,0); AddMessage(handles.MessageList,[datestr(now),' Moving to ',num2str(CurrentValues(:).')],50); 
                SetupStructure.MOVE(handles,SetupStructure,CurrentValues);
                for II=1:numel(SetupStructure.ListenPV)
                    TABULA{II,4}=CurrentValues(II);
                end
                set(handles.tabula,'data',TABULA);
                lcaPutSmart(SetupStructure.MovePV,1); AddMessage(handles.MessageList,[datestr(now),' Moving Done'],50); 
            end
        end
    case 2
        set(handles.tabula,'visible','on'); UD=get(handles.tabula,'userdata');
        AddMessage(handles.MessageList,[datestr(now),' Timer function Started - Actively Listening - Setting Listening PV to inf '],50);
        SetupStructure=get(handles.GO,'userdata'); lcaPutSmart(SetupStructure.ListenPV,inf); pause(0.1); OldValues=lcaGetSmart(SetupStructure.ListenPV);
        set(handles.SetValue,'userdata',OldValues);
        TABULA=get(handles.tabula,'data');
        for II=1:numel(SetupStructure.ListenPV)
            if(isempty(UD))
                TABULA{II,1}=SetupStructure.ListenPV{II}; TABULA{II,2}=0; TABULA{II,3}=0; TABULA{II,4}=inf; TABULA{II,5}=inf;
            else
                TABULA{II,1}=SetupStructure.ListenPV{II}; TABULA{II,4}=inf; TABULA{II,5}=inf;
            end
        end
        set(handles.tabula,'columneditable',[false,true,true,false,false]); set(handles.tabula,'columnname',{'PV Name','Min Allowed','Max Allowed','Current Val','Requested Val'});
        set(handles.tabula,'userdata',0);
        set(handles.tabula,'data',TABULA);
        Timer_Update(0,0,handles,1)
        
end

% --- Executes on selection change in ScanType.
function handles=ScanType_Callback(hObject, eventdata, handles)
S=get(handles.ScanType,'string');
V=get(handles.ScanType,'value');
for II=1:length(S)
    if(II==V)
        set(handles.(['P',num2str(II)]),'visible','on');
    else
        set(handles.(['P',num2str(II)]),'visible','off');
    end
end
switch(V)
    case 1
        handles.ULID=1;
        TABLE{1,1}='[1:33]';
        TABLE{1,2}='';
        set(handles.ScanSetupTable,'data',TABLE);
        set(handles.GO,'enable','off'); set(handles.tabula,'visible','off');
    case 2
        handles.ULID=2;
end
set(handles.AutoRun,'enable','off');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ScanType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScanType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetValue_Callback(hObject, eventdata, handles)
% hObject    handle to SetValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetValue as text
%        str2double(get(hObject,'String')) returns contents of SetValue as a double


% --- Executes during object creation, after setting all properties.
function SetValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Timer_Start.
function Timer_Start_Callback(hObject, eventdata, handles)
set(handles.Timer_Start,'enable','off')
try
    stop(handles.TIMER);
end
try
    delete(handles.TIMER);
end
PERIODO=0.4;
handles.TIMER=timer('StartDelay', 0, 'Period', PERIODO, 'TasksToExecute', inf, 'ExecutionMode', 'fixedSpacing','Busymode','drop');
handles.TIMER.StartFcn = {@Timer_Update,handles,2};
handles.TIMER.StopFcn = {@Timer_Update,handles,0};
handles.TIMER.TimerFcn = {@Timer_Update,handles,1};
handles.TIMER.ErrorFcn = {@Timer_Update,handles,-1};

Seconds=str2double(get(handles.TEMPO,'string'));
set(handles.TIMER,'Period',Seconds);

start(handles.TIMER); 
set(handles.tabula,'visible','on'); drawnow

guidata(hObject, handles);

function AddMessage(List,String,MaxMessages)
Messaggi=get(List,'string');
NumeroMessaggi=numel(Messaggi);
if(NumeroMessaggi>=MaxMessages)
    Messaggi(1)=[];
    Messaggi{MaxMessages}=String;
    set(List,'value',NumeroMessaggi);
    set(List,'string',Messaggi);
else
    Messaggi{NumeroMessaggi+1}=String;
    set(List,'string',Messaggi);
    set(List,'value',NumeroMessaggi+1);
end





function ListenPV_Callback(hObject, eventdata, handles)
% hObject    handle to ListenPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListenPV as text
%        str2double(get(hObject,'String')) returns contents of ListenPV as a double


% --- Executes during object creation, after setting all properties.
function ListenPV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListenPV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SetupScan.
function SetupScan_Callback(hObject, eventdata, handles)
ULID=handles.ULID; UL=handles.UL;
Table=get(handles.ScanSetupTable,'data');
UndulatorRange=str2num(Table{1,1});
Energy=lcaGetSmart(UL(ULID).Basic.EBeamEnergyPV);
LineReadout=UL(ULID).f.Read_all_K_values(UL(ULID));
Table{2,1}=num2str(Energy); Table{2,2}='GeV';
set(handles.tabula,'userdata',[]);
SetupStructure.Energy=Energy;
SetupStructure.Undulators=[];
SetupStructure.UndulatorsK_ini=[];
SetupStructure.UndulatorsK_end=[];

SetupStructure.MOVE=@MoveUndulatorEnergy;

for II=1:length(UL(ULID).slot)
    if(UL(ULID).slot(II).USEG.present)
        if(any(II==UndulatorRange))
            SetupStructure.Undulators(end+1)=II;
            SetupStructure.UndulatorsK_ini(end+1)=LineReadout(II).K;
            SetupStructure.UndulatorsK_end(end+1)=LineReadout(II).Kend;
            Table{3+II,1}=num2str(LineReadout(II).K);
            Table{3+II,2}=num2str(LineReadout(II).Kend);
        else
            Table{3+II,1}='NaN';
            Table{3+II,2}='NaN';
        end
    else
        Table{3+II,1}='NaN';
        Table{3+II,2}='NaN';
    end
end
set(handles.ScanSetupTable,'data',Table);
set(handles.GO,'enable','on');
LPV=get(handles.ListenPV,'string');
if(~any(LPV==','))
    SetupStructure.ListenPV{1}=LPV;
else
    Comma=find(LPV==','); SetupStructure.ListenPV={};
    for II=1:length(Comma)
       PVName=regexprep(LPV(1:(Comma(II)-1)),' ','');
       SetupStructure.ListenPV{end+1}=PVName;
    end
    PVName=regexprep(LPV((Comma(end)+1):end),' ','');
    SetupStructure.ListenPV{end+1}=PVName;
end
SetupStructure.ListenPV=SetupStructure.ListenPV(:);
SetupStructure.MovePV=get(handles.SetTo0,'string');
SetupStructure.SteerFlat=get(handles.SteerFlat,'value');
set(handles.GO,'userdata',SetupStructure);
lcaPutSmart(SetupStructure.ListenPV,NaN); set(handles.SetValue,'string','0');
set(handles.GO,'enable','on');
for JJ=1:numel(SetupStructure.ListenPV)
   TAB{JJ,1}=SetupStructure.ListenPV{JJ};
   TAB{JJ,2}=0;
   TAB{JJ,3}=0;
   TAB{JJ,4}=0;
end
set(handles.AutoRun,'enable','on');
set(handles.AutoScan,'data',TAB); set(handles.AutoScan,'columneditable',[false,true,true,false]);
set(handles.tabula,'userdata')

function MoveUndulatorEnergy(handles,SetupStructure,Target)
UL=handles.UL(handles.ULID);
static=handles.static(handles.ULID);
DELTA=Target;
DELTAe_Ph_number=DELTA;
PhyConsts=handles.PhyConsts;
if(isnan(DELTA)), return, end;

Destination.Cell=[]; Destination.K=[]; Destination.Kend=[];

for II=1:length(UL.slot)
            if(UL.slot(II).USEG.present)
                if(any(II==SetupStructure.Undulators))
                    e_ene_number=SetupStructure.Energy*1000;
                    ID=find(SetupStructure.Undulators==II);
                    K_number=SetupStructure.UndulatorsK_ini(ID);
                    ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio = DELTAe_Ph_number/(PhyConsts.hplanck * PhyConsts.c / (UL.Basic.Reference_lambda_u/1000/(2*(e_ene_number/(PhyConsts.mc2_e/10^6))^2)));
                    KnuovoS = sqrt(2*(1./(ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio + 1/(1+K_number^2/2)) -1));
                    Destination.K(end+1)=KnuovoS;
                    
                    K_number=SetupStructure.UndulatorsK_end(ID);
                    ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio = DELTAe_Ph_number/(PhyConsts.hplanck * PhyConsts.c / (UL.Basic.Reference_lambda_u/1000/(2*(e_ene_number/(PhyConsts.mc2_e/10^6))^2)));
                    KnuovoE = sqrt(2*(1./(ReciprocoUnoPiuKappaNuovoQuadratoMezziNuovoMenoVecchio + 1/(1+K_number^2/2)) -1));
                    Destination.Kend(end+1)=KnuovoE;
                    
                    Destination.Cell(end+1)=UL.slotcell(II);

                end
            end
end

disp('Calling Und Set Function')
UL.f.UndulatorLine_K_set(UL,Destination,0);
disp('Undulators Have been set');
pause(0.15);

if(SetupStructure.SteerFlat)
    disp('Steering to 0')
    options.BSA_HB=1; options.AcquisitionTime=1;
    [~,options.startTime]=lcaGetSmart(strcat(static.bpmList_e{1},':X'));
    options.fitSVDRatio=0.005;
    Solution=handles.sh.steer(static,options);
    if(Solution.FAILED)
        disp('Steering Failed: solution not applied');
    else
        lcaPutSmart(strcat(Solution.UsedCorr_e,':BCTRL'),Solution.NewCorr);
        disp('Steering Done');
        pause(0.2);
    end
end  


% --- Executes on button press in GO.
function GO_Callback(hObject, eventdata, handles)
SetupStructure=get(handles.GO,'userdata');
lcaPutSmart(SetupStructure.MovePV,0);

AddMessage(handles.MessageList,[datestr(now),' Moving to target. '],50);
DELTA=str2double(get(handles.SetValue,'string'));
SetupStructure.MOVE(handles,SetupStructure,DELTA);
lcaPutSmart(SetupStructure.MovePV,1);
AddMessage(handles.MessageList,[datestr(now),' Arrived at destination. '],50);




% --- Executes on button press in STOPAUTO.
function STOPAUTO_Callback(hObject, eventdata, handles)
set(handles.STOPAUTO,'backgroundcolor',handles.ColorWait); drawnow;


% --- Executes on button press in SteerFlat.
function SteerFlat_Callback(hObject, eventdata, handles)
% hObject    handle to SteerFlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SteerFlat



function TEMPO_Callback(hObject, eventdata, handles)
% hObject    handle to TEMPO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TEMPO as text
%        str2double(get(hObject,'String')) returns contents of TEMPO as a double


% --- Executes during object creation, after setting all properties.
function TEMPO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TEMPO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MessageList.
function MessageList_Callback(hObject, eventdata, handles)
% hObject    handle to MessageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MessageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MessageList


% --- Executes during object creation, after setting all properties.
function MessageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SetTo0_Callback(hObject, eventdata, handles)
% hObject    handle to SetTo0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SetTo0 as text
%        str2double(get(hObject,'String')) returns contents of SetTo0 as a double


% --- Executes during object creation, after setting all properties.
function SetTo0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetTo0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SinglePass.
function SinglePass_Callback(hObject, eventdata, handles)
% hObject    handle to SinglePass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SinglePass


% --- Executes on button press in ZigZag.
function ZigZag_Callback(hObject, eventdata, handles)
% hObject    handle to ZigZag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ZigZag


% --- Executes on button press in AutoRun.
function AutoRun_Callback(hObject, eventdata, handles)
SinglePass=get(handles.SinglePass,'value');
ZigZag=get(handles.ZigZag,'value');
STEPS=str2double(get(handles.STEPS,'string'));
Wait=str2double(get(handles.WAIT,'string'));
TAB=get(handles.AutoScan,'data');
SetupStructure=get(handles.GO,'userdata');
set(handles.STOPAUTO,'backgroundcolor',handles.ColorIdle); drawnow;
PointsTable=zeros(numel(SetupStructure.ListenPV),STEPS);
for II=1:numel(SetupStructure.ListenPV)
    PointsTable(II,:)=linspace(TAB{II,2},TAB{II,3},STEPS);
end

POSITION=1; DIREZIONE=1;

ContinueCondition=1;
set(handles.AutoRun,'backgroundcolor',handles.ColorGreen);

while(ContinueCondition)
    
    COLOR=get(handles.STOPAUTO,'backgroundcolor');
    if(all(COLOR==handles.ColorWait))
        set(handles.AutoString,'string','STOPPED');
        set(handles.STOPAUTO,'backgroundcolor',handles.ColorIdle);
        set(handles.AutoRun,'backgroundcolor',handles.ColorIdle);
        return
    end
    SelfDestruction=lcaGetSmart(handles.SelfDestruction);
    if(SelfDestruction)
        set(handles.AutoString,'string','FORCED TO STOP BY SELF-DESTRUCTION');
        set(handles.STOPAUTO,'backgroundcolor',handles.ColorIdle);
        set(handles.AutoRun,'backgroundcolor',handles.ColorIdle);
        return
    end
    lcaPutSmart(SetupStructure.MovePV,0);
    for II=1:numel(SetupStructure.ListenPV)
        TAB{II,4}=PointsTable(II,POSITION);
    end
    set(handles.AutoScan,'data',TAB);
    set(handles.AutoString,'string','... MOVING ...');
    AddMessage(handles.MessageList,[datestr(now),' Moving to target. '],50);
    drawnow
    SetupStructure.MOVE(handles,SetupStructure,PointsTable(:,POSITION));
    AddMessage(handles.MessageList,[datestr(now),' Arrived at destination. '],50);
    lcaPutSmart(SetupStructure.MovePV,1); set(handles.AutoString,'string',['WAITING ',num2str(Wait),' more seconds']); drawnow;
    COLOR=get(handles.STOPAUTO,'backgroundcolor');
    if(all(COLOR==handles.ColorWait))
        set(handles.AutoString,'string','STOPPED');
        set(handles.STOPAUTO,'backgroundcolor',handles.ColorIdle);
        set(handles.AutoRun,'backgroundcolor',handles.ColorIdle);
        return
    end
    SelfDestruction=lcaGetSmart(handles.SelfDestruction);
    if(SelfDestruction)
        set(handles.AutoString,'string','FORCED TO STOP BY SELF-DESTRUCTION');
        set(handles.STOPAUTO,'backgroundcolor',handles.ColorIdle);
        set(handles.AutoRun,'backgroundcolor',handles.ColorIdle);
        return
    end
    tic, b=toc;
    while(b<Wait)
        set(handles.AutoString,'string',['WAITING ',num2str(Wait-b),' more seconds']); drawnow;
        pause(0.25);
        b=toc;
    end
    if(DIREZIONE==1)
        POSITION=POSITION+1;
    else
        POSITION=POSITION-1;
    end
    if(POSITION>STEPS)
        if(SinglePass && ~ZigZag)
            ContinueCondition=0;
        elseif(~ZigZag)
            POSITION=1;
        else
            DIREZIONE=-1; 
            POSITION=STEPS-1;
        end
    end
    if(POSITION==0)
        if(ZigZag && SinglePass)
            ContinueCondition=0;
        end
        POSITION=2;
        DIREZIONE=1;
    end
end
set(handles.AutoString,'string','AUTOSCAN FINISHED');
set(handles.STOPAUTO,'backgroundcolor',handles.ColorIdle);
set(handles.AutoRun,'backgroundcolor',handles.ColorIdle);







function STEPS_Callback(hObject, eventdata, handles)
% hObject    handle to STEPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of STEPS as text
%        str2double(get(hObject,'String')) returns contents of STEPS as a double


% --- Executes during object creation, after setting all properties.
function STEPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to STEPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WAIT_Callback(hObject, eventdata, handles)
% hObject    handle to WAIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WAIT as text
%        str2double(get(hObject,'String')) returns contents of WAIT as a double


% --- Executes during object creation, after setting all properties.
function WAIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WAIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in STOP.
function STOP_Callback(hObject, eventdata, handles)
try
    stop(handles.TIMER);
end
try
    delete(handles.TIMER);
end
set(handles.Timer_Start,'enable','on'); set(handles.tabula,'visible','off');



function SelfDestruction_Callback(hObject, eventdata, handles)
% hObject    handle to SelfDestruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SelfDestruction as text
%        str2double(get(hObject,'String')) returns contents of SelfDestruction as a double


% --- Executes during object creation, after setting all properties.
function SelfDestruction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelfDestruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
