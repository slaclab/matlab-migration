function varargout = HXRSS_CrystalGui(varargin)
% HXRSS_CRYSTALGUI MATLAB code for HXRSS_CrystalGui.fig
%      HXRSS_CRYSTALGUI, by itself, creates a new HXRSS_CRYSTALGUI or raises the existing
%      singleton*.
%
%      H = HXRSS_CRYSTALGUI returns the handle to a new HXRSS_CRYSTALGUI or the handle to
%      the existing singleton*.
%
%      HXRSS_CRYSTALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HXRSS_CRYSTALGUI.M with the given input arguments.
%
%      HXRSS_CRYSTALGUI('Property','Value',...) creates a new HXRSS_CRYSTALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HXRSS_CrystalGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HXRSS_CrystalGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HXRSS_CrystalGui

% Last Modified by GUIDE v2.5 07-May-2021 16:50:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HXRSS_CrystalGui_OpeningFcn, ...
                   'gui_OutputFcn',  @HXRSS_CrystalGui_OutputFcn, ...
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


% --- Executes just before HXRSS_CrystalGui is made visible.
function HXRSS_CrystalGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HXRSS_CrystalGui (see VARARGIN)

% Choose default command line output for HXRSS_CrystalGui
handles.output = hObject;
handles.CD=CDO_Class;
handles.mh=HXRSS_Motion_functions();
handles.Attenuator=AttenuatorCascade_Class;
handles.Attenuator.LoadAttenuators();
handles.SaveFileFolder='/u1/lcls/matlab/data/CrystalGUI_StoredData';
handles.StoredMachinesFile='HXRSS_StoredCrystals.mat';
handles.LockMachine=1;
handles.ChangeMachineEnable=0;
handles.M=1;
handles.PitchSteps=180;
handles.MaxNormReflection=150;
handles.MaxAbsReflection=9;
handles.YawSteps=30;
handles.UpdateDelay=0.95;

handles.ColorOn=[0,1,0];
handles.ColorOff=[1,0.2,0.2];
handles.ColorWait=[1,1,0];
handles.ColorLogBook=[0.4,0.4,1];
handles.ColorIdle=get(handles.Timer_Reset,'backgroundcolor');
try
    load([handles.SaveFileFolder,'/',handles.StoredMachinesFile],'Machine')
    handles.AMGP=Machine;
catch
    disp(['Setup file not found in ',handles.SaveFileFolder,'/',handles.StoredMachinesFile]);
    disp('Running Gui with a (0,0,4) 100 thick diamond with all 0 initial orientation.')
    handles.AMGP.name='LCLS';
    handles.AMGP.CD(1)=handles.CD.get_crystal();
end
%view(handles.a4,[-90.4,-15.6])
% handles.ColorCrystalDefault=handles.CGDefaultFileOutput.Options.ColorsDefault;
% handles.ColorCrystalDefaultLength=size(handles.ColorCrystalDefault,1);

handles.MachinesList={handles.AMGP.name};

handles.CD.findAllReflections(handles.MaxAbsReflection,handles.MaxNormReflection);
set(handles.text47,'string',['Found: ',num2str(length(handles.CD.AllReflectionsAbsMax))]);

set(handles.UnlockMachine,'value',handles.LockMachine);
set(handles.PPS,'string',num2str(handles.PitchSteps));
set(handles.YPS,'string',num2str(handles.YawSteps));
set(handles.MNR,'string',num2str(handles.MaxNormReflection));
set(handles.MaxAbs,'string',num2str(handles.MaxAbsReflection));
set(handles.Timer_s,'string',num2str(handles.UpdateDelay));
set(handles.Machine,'string',handles.MachinesList);
set(handles.Machine,'value',handles.M);

if(~handles.ChangeMachineEnable), set(handles.Machine,'enable','off'); else, set(handles.Machine,'enable','on'); end
set(handles.Crystal,'string',{handles.AMGP(handles.M).CD.name});set(handles.Crystal,'value',1);

DATA{1,1}=[];DATA{1,2}=[];DATA{1,3}=[];DATA{1,4}=[];
DATA{2,1}=[];DATA{2,2}=[];DATA{2,3}=[];DATA{2,4}=[];
set(handles.uitable2,'data',DATA);
DATA2={};
set(handles.uitable5,'data',DATA2);
set(handles.text43,'string',''); set(handles.SET_TO_MACHINE,'enable','off');
set(handles.MainPanel,'visible','on');set(handles.uipanel7,'visible','off');set(handles.CSP,'visible','off');
set(handles.Energies,'ColumnFormat',{'logical','numeric','numeric','numeric','bank','numeric','numeric'});
handles=Machine_Callback(hObject, eventdata, handles);
handles=Crystal_Callback(hObject, eventdata, handles);
%Update_PitchYawPlots(handles);
%[handles.Vertex, handles.Faces, handles.ColQuad] = functionPARALLELEPIPEDO([-1,-0.05],[1,0.05],2);
%handles.Vertex(:,1)=handles.Vertex(:,1)-mean(handles.Vertex(:,1));
%handles.Vertex(:,2)=handles.Vertex(:,2)-mean(handles.Vertex(:,2));
%handles.Vertex(:,3)=handles.Vertex(:,3)-mean(handles.Vertex(:,3));
%update_crystalplot(handles);
handles=Timer_Reset_Callback(hObject, [], handles);
handles=Timer_Start_Callback(hObject, [], handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HXRSS_CrystalGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HXRSS_CrystalGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in Machine.
function handles=Machine_Callback(hObject, eventdata, handles)
handles.M=get(handles.Machine,'value');
CrystalNames={handles.AMGP(handles.M).CD.name};
set(handles.Crystal,'string',CrystalNames);set(handles.Crystal,'value',1);
handles.PitchSet=handles.mh.(handles.AMGP(handles.M).SetPitch);
handles.YawSet=handles.mh.(handles.AMGP(handles.M).SetYaw);
handles.PitchGet=handles.mh.(handles.AMGP(handles.M).GetPitch);
handles.YawGet=handles.mh.(handles.AMGP(handles.M).GetYaw);
handles.StatusGet=handles.mh.(handles.AMGP(handles.M).GetStatus);
handles.InOutSet=handles.mh.(handles.AMGP(handles.M).SetInOut);
handles.PVsGet=handles.mh.(handles.AMGP(handles.M).GetPVs);
PGR=get(handles.FreeMode,'value');
for II=1:3 
    if(II<=numel(CrystalNames))
        set(handles.(['INSERT',num2str(II)]),'string',['Insert ',CrystalNames{II}]);
        set(handles.(['INSERT',num2str(II)]),'UserData',CrystalNames{II});
        set(handles.(['INSERT',num2str(II)]),'visible','on');
        set(handles.(['S',num2str(II)]),'visible','on');
    else
        set(handles.(['INSERT',num2str(II)]),'visible','off');
        set(handles.(['S',num2str(II)]),'visible','off');
    end
end
guidata(hObject, handles);
Crystal_Callback(hObject, eventdata, handles);

function Machines=CopyInitFromFile(handles,StoredConfig)
Machines=handles.Machines;
for II=1:numel(StoredConfig.Machines)
    for JJ=1:numel(StoredConfig.Machines(II).Crystal)
        FIELDS=fieldnames(StoredConfig.Machines(II).Crystal(JJ).CD);
        for TT=1:numel(FIELDS)
            Machines(II).Crystal(JJ).CD.(FIELDS{TT})=StoredConfig.Machines(II).Crystal(JJ).CD.(FIELDS{TT});
        end        
    end
end

% --- Executes during object creation, after setting all properties.
function Machine_CreateFcn(hObject, eventdata, handles)


% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Crystal.
function handles=Crystal_Callback(hObject, eventdata, handles)
M=get(handles.Machine,'value');
C=get(handles.Crystal,'value');
handles.CD.set_crystal(handles.AMGP(M).CD(C));
set(handles.Pmin,'string',num2str(handles.CD.PitchRange(1)));
set(handles.Pmax,'string',num2str(handles.CD.PitchRange(2)));
set(handles.Ymin,'string',num2str(handles.CD.YawRange(1)));
set(handles.Ymax,'string',num2str(handles.CD.YawRange(2)));
set(handles.Emin,'string',num2str(handles.CD.EnergyRange(1)));
set(handles.Emax,'string',num2str(handles.CD.EnergyRange(2)));
guidata(hObject, handles);
Update_PitchYawPlots(handles);

% --- Executes during object creation, after setting all properties.
function Crystal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Crystal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function P_Callback(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of P as text
%        str2double(get(hObject,'String')) returns contents of P as a double


% --- Executes during object creation, after setting all properties.
function P_CreateFcn(hObject, eventdata, handles)
% hObject    handle to P (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_Callback(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y as text
%        str2double(get(hObject,'String')) returns contents of Y as a double


% --- Executes during object creation, after setting all properties.
function Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CrystalSetup.
function CrystalSetup_Callback(hObject, eventdata, handles)
CDVAR=handles.CD.get_crystal();
set(handles.MainPanel,'visible','off');set(handles.uipanel7,'visible','off');set(handles.CSP,'visible','on');
Variables=fieldnames(CDVAR); 
for II=1:numel(Variables)
    TABLE{II,1}=Variables{II};
   if(ischar(CDVAR.(Variables{II})))
       TABLE{II,2}=CDVAR.(Variables{II});
   elseif(isscalar(CDVAR.(Variables{II})))
       TABLE{II,2}=CDVAR.(Variables{II});
   elseif(isvector(CDVAR.(Variables{II})))
       for JJ=1:length(CDVAR.(Variables{II}))
           TABLE{II,JJ+1}=CDVAR.(Variables{II})(JJ);
       end
   end
end
set(handles.CRYSTAL_CONF,'data',TABLE);

% --- Executes on button press in SMA.
function SMA_Callback(hObject, eventdata, handles)
Angles(1)=str2double(get(handles.P,'string')); Angles(2)=str2double(get(handles.Y,'string'));
if(~isnan(Angles(1)))
    handles.PitchSet(handles.CD.name,Angles(1));
end
if(~isnan(Angles(2)))
    handles.YawSet(handles.CD.name,Angles(2));
end
Update_PitchYawPlots(handles);
%update_crystalplot(handles);
Timer_Update([],[],handles,1);


% --- Executes on button press in Use1.
function Use1_Callback(hObject, eventdata, handles)
set(handles.Use1,'value',1);set(handles.Use2,'value',0);set(handles.Use12,'value',0);

% --- Executes on button press in Use2.
function Use2_Callback(hObject, eventdata, handles)
set(handles.Use1,'value',0);set(handles.Use2,'value',1);set(handles.Use12,'value',0);

% --- Executes on button press in Use12.
function Use12_Callback(hObject, eventdata, handles)
set(handles.Use1,'value',0);set(handles.Use2,'value',0);set(handles.Use12,'value',1);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
Request=get(handles.uitable2,'data'); R1=[];R2=[];
set(handles.text43,'string','');set(handles.SET_TO_MACHINE,'enable','off');
StartPitch=str2double(get(handles.edit33,'string'));
StartYaw=str2double(get(handles.edit34,'string'));
[SA,SB]=size(Request);
if(SB~=4), return, end
R1=[Request{1,1},Request{1,2},Request{1,3}].';
R2=[Request{2,1},Request{2,2},Request{2,3}].';
E1=Request{1,4};
E2=Request{2,4};
%Crystal=get(handles.Crystal,'userdata');
set(handles.SET_TO_MACHINE,'userdata',[]);
Use=[get(handles.Use1,'value'),get(handles.Use2,'value'),get(handles.Use12,'value')];
Reflections=handles.CD.AllReflections;
if(length(R1)~=3)
    R1=[];
else
    ID=find((Reflections(:,1)==R1(1)) & (Reflections(:,2)==R1(2)) & (Reflections(:,3)==R1(3)));
    if(isempty(ID))
        R1=[];
    end
end
if(length(R2)~=3)
    R2=[];
else
    ID=find((Reflections(:,1)==R2(1)) & (Reflections(:,2)==R2(2)) & (Reflections(:,3)==R2(3)));
    if(isempty(ID))
        R2=[];
    end
end
if(~isempty(R1) && ~isempty(R2))
    if(~isempty(E1) && ~isempty(E2))
        [Angles,Ene]=handles.CD.FindAnglesTwoColor([StartPitch,StartYaw], [R1,R2], [E1,E2]);
    elseif(~isempty(E1))
        [Angles,Ene]=handles.CD.FindAnglesTwoColor([StartPitch,StartYaw], [R1,R2], [E1,E1]);
    elseif(~isempty(E2))
        [Angles,Ene]=handles.CD.FindAnglesTwoColor([StartPitch,StartYaw], [R1,R2], [E2,E2]);
    else %give up
        return
    end
    TABLE2{1,1}=Angles(1);TABLE2{2,1}=Angles(1);
    TABLE2{1,2}=Angles(2);TABLE2{2,2}=Angles(2);
    TABLE2{1,3}=R1(1);TABLE2{2,3}=R2(1);
    TABLE2{1,4}=R1(2);TABLE2{2,4}=R2(2);
    TABLE2{1,5}=R1(3);TABLE2{2,5}=R2(3);
    TABLE2{1,6}=Ene(1);TABLE2{2,6}=Ene(2);
    set(handles.SET_TO_MACHINE,'userdata',Angles);
    set(handles.uitable5,'data',TABLE2);
    FreeMode=get(handles.FreeMode,'value');
        if(~FreeMode)
        set(handles.SET_TO_MACHINE,'enable','on');
        end
elseif(~isempty(R1)) %use R1 for single search
    if(~isempty(E1))
        if(Use(1))
            [Angles,Ene]=handles.CD.FindAnglesOneColor([StartPitch,StartYaw], R1, 1,E1);
        elseif(Use(2))
            [Angles,Ene]=handles.CD.FindAnglesOneColor([StartPitch,StartYaw], R1, 0,E1);
        else
            [Angles,Ene]=handles.CD.FindAnglesTwoColor([StartPitch,StartYaw], [R1,R1], [E1,E1]);
        end
        TABLE2{1,1}=Angles(1);
        TABLE2{1,2}=Angles(2);
        TABLE2{1,3}=R1(1);
        TABLE2{1,4}=R1(2);
        TABLE2{1,5}=R1(3);
        TABLE2{1,6}=Ene(1);
        set(handles.SET_TO_MACHINE,'userdata',Angles);
        set(handles.uitable5,'data',TABLE2);
        FreeMode=get(handles.FreeMode,'value');
        if(~FreeMode)
        set(handles.SET_TO_MACHINE,'enable','on');
        end
    else %give up
        return
    end
elseif(~isempty(R2)) %use R2 for single search
    if(~isempty(E2))
        
        if(Use(1))
            [Angles,Ene]=handles.CD.FindAnglesOneColor([StartPitch,StartYaw], R2, 1,E2);
        elseif(Use(2))
            [Angles,Ene]=handles.CD.FindAnglesOneColor([StartPitch,StartYaw], R2, 0,E2);
        else
            [Angles,Ene]=handles.CD.FindAnglesTwoColor([StartPitch,StartYaw], [R2,R2], [E2,E2]);
        end
        TABLE2{1,1}=Angles(1);
        TABLE2{1,2}=Angles(2);
        TABLE2{1,3}=R2(1);
        TABLE2{1,4}=R2(2);
        TABLE2{1,5}=R2(3);
        TABLE2{1,6}=Ene(1);
        set(handles.SET_TO_MACHINE,'userdata',Angles);
        set(handles.uitable5,'data',TABLE2);
        FreeMode=get(handles.FreeMode,'value');
        if(~FreeMode)
            set(handles.SET_TO_MACHINE,'enable','on');
        end
    else %give up
        return
    end
else % give up.
    return
end
if((prod(Angles(1)-handles.CD.PitchRange)<0) && (prod(Angles(2)-handles.CD.YawRange)<0))
    set(handles.text43,'string','Angles in allowed range');set(handles.text43,'foregroundcolor',handles.ColorOn);
else
    set(handles.text43,'string','Angles OUT OF allowed range');set(handles.text43,'foregroundcolor',handles.ColorOff);
end



% --- Executes on button press in SET_TO_MACHINE.
function SET_TO_MACHINE_Callback(hObject, eventdata, handles)
Angles=get(handles.SET_TO_MACHINE,'userdata');
if(~isnan(Angles(1)))
    handles.PitchSet(handles.CD.name,Angles(1));
end
if(~isnan(Angles(2)))
    handles.YawSet(handles.CD.name,Angles(2));
end
Update_PitchYawPlots(handles);
%update_crystalplot(handles);
Timer_Update([],[],handles,1);


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
set(handles.MainPanel,'visible','off');set(handles.uipanel7,'visible','on');set(handles.CSP,'visible','off');



% --- Executes on button press in GetAngles.
function GetAngles_Callback(hObject, eventdata, handles)
Angles=Read_Machine_Angles(handles);
set(handles.ACT_P,'string',num2str(Angles(1)));
set(handles.ACT_Y,'string',num2str(Angles(2)));
if(~isnan(Angles(1)))
    set(handles.P,'string',num2str(Angles(1)));
end
if(~isnan(Angles(2)))
    set(handles.Y,'string',num2str(Angles(2)));
end
Update_PitchYawPlots(handles);
%update_crystalplot(handles)

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
set(handles.MainPanel,'visible','on');set(handles.uipanel7,'visible','off');set(handles.CSP,'visible','off');



% --- Executes on button press in UnlockMachine.
function UnlockMachine_Callback(hObject, eventdata, handles)
VAL=get(handles.UnlockMachine,'value');
if(VAL), set(handles.Machine,'enable','off'); else, set(handles.Machine,'enable','on'); end


function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
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



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PPS_Callback(hObject, eventdata, handles)
Update_PitchYawPlots(handles)


% --- Executes during object creation, after setting all properties.
function PPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YPS_Callback(hObject, eventdata, handles)
Update_PitchYawPlots(handles)


% --- Executes during object creation, after setting all properties.
function YPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UpdateDelay_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of UpdateDelay as text
%        str2double(get(hObject,'String')) returns contents of UpdateDelay as a double


% --- Executes during object creation, after setting all properties.
function UpdateDelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UpdateDelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StopUpdate.
function StopUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to StopUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CrystalSet.
function CrystalSet_Callback(hObject, eventdata, handles)
CDVAR=handles.CD.get_crystal();
Variables=fieldnames(CDVAR); 
for II=1:numel(Variables)
   if(ischar(CDVAR.(Variables{II})))
       CDVAR.(Variables{II})=TABLE{II,2};
   elseif(isscalar(CDVAR.(Variables{II})))
       CDVAR.(Variables{II})=TABLE{II,2};
   elseif(isvector(CDVAR.(Variables{II})))
       for JJ=1:length(CDVAR.(Variables{II}))
           CDVAR.(Variables{II})(JJ)=TABLE{II,JJ+1};
       end
   end
end
handles.CD.set_crystal(CDVAR);
MachineID=get(handles.Machine,'value');
CrystalID=get(handles.Crystal,'value');
CDNEW=handles.CD.get_crystal();

handles.AMGP(MachineID).CD(CrystalID)=CDNEW;
guidata(hObject, handles);
Machine=handles.AMGP;
save([handles.SaveFileFolder,'/',handles.StoredMachinesFile],'Machine')

Update_PitchYawPlots(handles)
set(handles.MainPanel,'visible','off');set(handles.uipanel7,'visible','off');set(handles.CSP,'visible','on');

% --- Executes on button press in CrystalSetOnce.
function CrystalSetOnce_Callback(hObject, eventdata, handles)
CDVAR=handles.CD.get_crystal();
Variables=fieldnames(CDVAR); 
TABLE=get(handles.CRYSTAL_CONF,'data');
for II=1:numel(Variables)
   if(ischar(CDVAR.(Variables{II})))
       CDVAR.(Variables{II})=TABLE{II,2};
   elseif(isscalar(CDVAR.(Variables{II})))
       CDVAR.(Variables{II})=TABLE{II,2};
   elseif(isvector(CDVAR.(Variables{II})))
       for JJ=1:length(CDVAR.(Variables{II}))
           CDVAR.(Variables{II})(JJ)=TABLE{II,JJ+1};
       end
   end
end
handles.CD.set_crystal(CDVAR);
Update_PitchYawPlots(handles)
set(handles.MainPanel,'visible','off');set(handles.uipanel7,'visible','off');set(handles.CSP,'visible','on');

% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
set(handles.MainPanel,'visible','on');set(handles.uipanel7,'visible','off');set(handles.CSP,'visible','off');
Update_PitchYawPlots(handles)

function Timer_Update(TimerObject,Type_and_when,handles,MODE)
Nunc=clock; NuncString=datestr(Nunc,'yyyy, ddd dd mmmm, HH:MM:SS');
Date_String=['AD ',NuncString,'.',num2str(floor(100*(Nunc(6) - fix(Nunc(6)))))];
switch(MODE)
    case -1
        disp('Timer Function Crashed');
    case 0
        disp('Timer Function Stopped');
    case 1
        set(handles.StatusString,'string',['HXR Self-Seeding Control - ',Date_String]);
        FreeMode=get(handles.FreeMode,'value');
        if(FreeMode)
            set(handles.XACT,'string','-----');set(handles.XDES,'string','-----');
            set(handles.YACT,'string','-----');set(handles.YDES,'string','-----');
            set(handles.ACT_P,'string','-----');set(handles.DES_P,'string','-----');
            set(handles.ACT_Y,'string','-----');set(handles.DES_Y,'string','-----');
            set(handles.S1,'string','-----');
            set(handles.S2,'string','-----');
            set(handles.S3,'string','-----');
        else
            Crystalls=get(handles.Crystal,'string');
            Status=handles.StatusGet(Crystalls);
            for II=1:numel(Status)
                if(Status(II).IN)
                    set(handles.(['S',num2str(II)]),'string','IN');
                    NEWID=II;
                elseif(Status(II).OUT)
                    set(handles.(['S',num2str(II)]),'string','OUT');
                    NEWID=-1;
                else
                    set(handles.(['S',num2str(II)]),'string','???');
                    NEWID=-1;
                end
                ID=get(handles.Crystal,'value');
                if(II==ID)
                    set(handles.XACT,'string',num2str(Status(ID).X));
                    set(handles.YACT,'string',num2str(Status(ID).Y));
                    set(handles.XDES,'string',num2str(Status(ID).X_des));
                    set(handles.YDES,'string',num2str(Status(ID).Y_des));
                    set(handles.ACT_P,'string',num2str(Status(ID).Pitch));
                    set(handles.ACT_Y,'string',num2str(Status(ID).Yaw));
                    set(handles.DES_P,'string',num2str(Status(ID).Pitch_des));
                    set(handles.DES_Y,'string',num2str(Status(ID).Yaw_des));
                end
            end
        end
        
    case 2
        disp('Timer Function Started');
        Timer_Update(0,0,handles,1)
end


% --- Executes on button press in Timer_Start.
function handles=Timer_Start_Callback(hObject, eventdata, handles)
Seconds=str2num(get(handles.Timer_s,'string'));
set(handles.TIMER,'Period',Seconds);
guidata(hObject, handles);
start(handles.TIMER);
set(handles.Timer_Start,'backgroundcolor',handles.ColorOn);
set(handles.Timer_Start,'enable','off')
set(handles.Timer_Stop,'enable','on');

% --- Executes on button press in Timer_Stop.
function Timer_Stop_Callback(hObject, eventdata, handles)
stop(handles.TIMER);
set(handles.Timer_Start,'backgroundcolor',handles.ColorIdle);
set(handles.Timer_Start,'enable','on')


% --- Executes on button press in Timer_Reset.
function handles=Timer_Reset_Callback(hObject, eventdata, handles)
try
    stop(handles.TIMER);
end
try
    delete(handles.TIMER);
end
PERIODO=str2double(get(handles.Timer_s,'string'));
handles.TIMER=timer('StartDelay', 0, 'Period', PERIODO, 'TasksToExecute', inf, 'ExecutionMode', 'fixedSpacing','Busymode','drop');
handles.TIMER.StartFcn = {@Timer_Update,handles,2};
handles.TIMER.StopFcn = {@Timer_Update,handles,0};
handles.TIMER.TimerFcn = {@Timer_Update,handles,1};
handles.TIMER.ErrorFcn = {@Timer_Update,handles,-1};
guidata(hObject, handles);
set(handles.Timer_Start,'enable','on');
set(handles.Timer_Start,'backgroundcolor',handles.ColorIdle);
set(handles.Timer_Stop,'enable','off');



function Timer_s_Callback(hObject, eventdata, handles)
% hObject    handle to Timer_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Timer_s as text
%        str2double(get(hObject,'String')) returns contents of Timer_s as a double


% --- Executes during object creation, after setting all properties.
function Timer_s_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Timer_s (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MNR_Callback(hObject, eventdata, handles)
Update_PitchYawPlots(handles)

% --- Executes during object creation, after setting all properties.
function MNR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Angles=Read_Machine_Angles(handles)
CrystalNameList=get(handles.Crystal,'string');
Value=get(handles.Crystal,'value');
handles.PitchGet(CrystalNameList{Value});
handles.YawGet(CrystalNameList{Value});
Angles(1)=handles.PitchGet(CrystalNameList{Value}); Angles(2)=handles.YawGet(CrystalNameList{Value});



function Emin_Callback(hObject, eventdata, handles)
% hObject    handle to Emin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Emin as text
%        str2double(get(hObject,'String')) returns contents of Emin as a double


% --- Executes during object creation, after setting all properties.
function Emin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Emin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Emax_Callback(hObject, eventdata, handles)
% hObject    handle to Emax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Emax as text
%        str2double(get(hObject,'String')) returns contents of Emax as a double


% --- Executes during object creation, after setting all properties.
function Emax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Emax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pmin_Callback(hObject, eventdata, handles)
% hObject    handle to Pmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pmin as text
%        str2double(get(hObject,'String')) returns contents of Pmin as a double


% --- Executes during object creation, after setting all properties.
function Pmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pmax_Callback(hObject, eventdata, handles)
% hObject    handle to Pmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pmax as text
%        str2double(get(hObject,'String')) returns contents of Pmax as a double


% --- Executes during object creation, after setting all properties.
function Pmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymin_Callback(hObject, eventdata, handles)
% hObject    handle to Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymin as text
%        str2double(get(hObject,'String')) returns contents of Ymin as a double


% --- Executes during object creation, after setting all properties.
function Ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ymax_Callback(hObject, eventdata, handles)
% hObject    handle to Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ymax as text
%        str2double(get(hObject,'String')) returns contents of Ymax as a double


% --- Executes during object creation, after setting all properties.
function Ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tmin_Callback(hObject, eventdata, handles)
% hObject    handle to Tmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tmin as text
%        str2double(get(hObject,'String')) returns contents of Tmin as a double


% --- Executes during object creation, after setting all properties.
function Tmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tmax_Callback(hObject, eventdata, handles)
% hObject    handle to Tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tmax as text
%        str2double(get(hObject,'String')) returns contents of Tmax as a double


% --- Executes during object creation, after setting all properties.
function Tmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Update_PitchYawPlots(handles)
Pmin=str2double(get(handles.Pmin,'string'));Pmax=str2double(get(handles.Pmax,'string'));
Ymin=str2double(get(handles.Ymin,'string'));Ymax=str2double(get(handles.Ymax,'string'));
Emin=str2double(get(handles.Emin,'string'));Emax=str2double(get(handles.Emax,'string'));
Pitch_string=get(handles.P,'string'); Yaw_string=get(handles.Y,'string');
Pitch=str2double(Pitch_string); Yaw=str2double(Yaw_string);
set(handles.edit33,'string',num2str(Pitch_string)); set(handles.edit34,'string',num2str(Yaw_string));
if(Pmin>Pmax)
   TEMP=Pmax; Pmax=Pmin; Pmin=TEMP;
   set(handles.Pmin,'string',num2str(Pmax)); set(handles.Pmax,'string',num2str(Pmin));
elseif(Pmin==Pmax), Pmax=Pmin+10^-6; 
end
if(Ymin>Ymax)
   TEMP=Ymax; Ymax=Ymin; Ymin=TEMP;
   set(handles.Ymin,'string',num2str(Ymax)); set(handles.Ymax,'string',num2str(Ymin));
elseif(Ymin==Ymax), Ymax=Ymin+10^-6; 
end
if(Emin>Emax)
   TEMP=Emax; Emax=Emin; Emin=TEMP;
   set(handles.Emin,'string',num2str(Emax)); set(handles.Emax,'string',num2str(Emin));
elseif(Emin==Emax), Emax=Emin+10^-6; 
end
Reflections=handles.CD.AllReflections.';
PPS=str2double(get(handles.PPS,'string'));YPS=str2double(get(handles.PPS,'string'));
PV=linspace(Pmin,Pmax,PPS); YV=linspace(Ymin,Ymax,YPS);
[EnergyMap,PitchDerMap,YawDerMap]=handles.CD.PhotonEnergy_all_formula(Pitch,Yaw,Reflections);
PitchMap=handles.CD.PhotonEnergy_fast_formula(PV,Yaw,Reflections);
YawMap=handles.CD.PhotonEnergy_fast_formula(Pitch,YV,Reflections);
cla(handles.a1);cla(handles.a2);hold(handles.a1,'on');hold(handles.a2,'on');
incremental_line=0;
for II=1:size(Reflections,2)
    [COLORE, STILE, SPESSORE]=LineType(Reflections(:,II));
    incremental_line=incremental_line+1;
    handles.Pointers.UL(incremental_line)=plot(handles.a1,PV,PitchMap(:,II),'Color',COLORE,'Linestyle',STILE,'linewidth',SPESSORE);
    set(handles.Pointers.UL(incremental_line),'UserData',Reflections(:,II));
    handles.Pointers.UR(incremental_line)=plot(handles.a2,YV,YawMap(:,II),'Color',COLORE,'Linestyle',STILE,'linewidth',SPESSORE);
    set(handles.Pointers.UR(incremental_line),'UserData',Reflections(:,II));
end
% TBSE1=get(handles.a1,'parent');
% TBSE2=get(handles.a2,'parent');
USERDATA{1}=handles.Energies;USERDATA{2}=handles.Messaggi;USERDATA{3}=@update_energy_table;USERDATA{4}=handles;
% set(TBSE1,'UserData',USERDATA);
% set(TBSE2,'UserData',USERDATA);
hcmenu = uicontextmenu;
uimenu(hcmenu, 'Label', 'Select Reflection', 'Callback', @SelectLineInteraction,'UserData',USERDATA);
uimenu(hcmenu, 'Label', 'Retrieve [h,k,l]', 'Callback', @RetrieveLabelInteraction,'UserData',USERDATA);
uimenu(hcmenu, 'Label', 'Send to Searchbox', 'Callback', @SendToSearchbox,'UserData',USERDATA);

hlines = findall(handles.a1,'Type','line');
for line = 1:length(hlines)
    set(hlines(line),'uicontextmenu',hcmenu)
end
hlines = findall(handles.a2,'Type','line');
for line = 1:length(hlines)
    set(hlines(line),'uicontextmenu',hcmenu)
end

xlim(handles.a1,[Pmin,Pmax]); ylim(handles.a1,[Emin,Emax]);
xlim(handles.a2,[Ymin,Ymax]); ylim(handles.a2,[Emin,Emax]);

hold(handles.a1,'off')
hold(handles.a2,'off')

Data.PitchMap=PitchMap;
Data.YawMap=YawMap;
Data.EnergyMap=EnergyMap;
Data.PitchDerMap=PitchDerMap;
Data.YawDerMap=YawDerMap;
Data.Reflections=Reflections;
Data.Pitch=Pitch;
Data.Yaw=Yaw;
set(handles.SortingOrder,'userdata',Data);
update_energy_table(PitchMap,YawMap,EnergyMap,PitchDerMap,YawDerMap,Reflections,handles)
set(handles.Messaggio3,'string',['At Pitch = ',num2str(Pitch),' deg     Yaw = ',num2str(Yaw),' deg'])

function SendToSearchbox(SLGC,OES)
Pointers=get(SLGC,'UserData');
data=get(gco,'userdata');
RequestAngle=get(Pointers{4}.uitable2,'data');
RequestAngle{1,1}=data(1); RequestAngle{1,2}=data(2);  RequestAngle{1,3}=data(3); 
set(Pointers{4}.uitable2,'data',RequestAngle);

function RetrieveLabelInteraction(SLGC,OES)
Pointers=get(SLGC,'UserData');
data=get(gco,'userdata');
stringa=['(',num2str(data.'),')'];
set(Pointers{2},'string',['Thou hast chosen the ',stringa,' reflection.']);

function SelectLineInteraction(SLGC,OES)
Pointers=get(SLGC,'UserData');
TABLE=get(Pointers{1},'data');
data=get(gco,'userdata');
H=cell2mat(TABLE(:,2));
K=cell2mat(TABLE(:,3));
L=cell2mat(TABLE(:,4));
ID=find((H==data(1)) & (K==data(2)) & L==data(3));
if(~isempty(ID))
    TABLE{ID,1}=true;
end
AbsoluteID=find((Pointers{4}.CD.AllReflections(:,1)==data(1)) & (Pointers{4}.CD.AllReflections(:,2)==data(2)) & (Pointers{4}.CD.AllReflections(:,3)==data(3)));
Pointers{4}.Pointers.UL(AbsoluteID).LineWidth=3;
Pointers{4}.Pointers.UL(AbsoluteID).LineWidth=3;
set(Pointers{1},'data',TABLE);
Data=get(Pointers{4}.SortingOrder,'userdata');
Pointers{3}(Data.PitchMap,Data.YawMap,Data.EnergyMap,Data.PitchDerMap,Data.YawDerMap,Data.Reflections,Pointers{4});

function update_energy_table(PitchMap,YawMap,EnergyMap,PitchDerMap,YawDerMap,Reflections,handles)
RPE=str2double(get(handles.RPE,'string'));
SO=get(handles.SortingOrder,'value');
CurrentTable=get(handles.Energies,'data');
ReflectionTrueID=get(handles.Energies,'userdata');
if(isempty(ReflectionTrueID))
    disp('making a new table'); CurrentSelections=[];
else
    CurrentSelections=ReflectionTrueID(logical(cell2mat(CurrentTable(:,1))));
end
DATA=zeros(size(Reflections,2),7);
CSE=length(CurrentSelections);
SortingOrder=zeros(size(Reflections,2),1);
SortingOrder(1:CSE)=CurrentSelections;
switch SO
    case 1
        DISTANCE=abs(EnergyMap-RPE);
        DISTANCE(CurrentSelections)=-1;
        [~,SO]=sort(DISTANCE,'ascend');
        
        SortingOrder((CSE+1):end)=SO((CSE+1):end);
        set(handles.Energies,'userdata',SortingOrder);
        DATA(:,2)=Reflections(1,SortingOrder); DATA(:,3)=Reflections(2,SortingOrder); DATA(:,4)=Reflections(3,SortingOrder);
        DATA(:,5)=EnergyMap(SortingOrder); DATA(:,6)=PitchDerMap(SortingOrder); DATA(:,7)=YawDerMap(SortingOrder);
    case 2
        DISTANCE=min(abs(PitchMap-RPE));
        DISTANCE(CurrentSelections)=-1;
        [~,SO]=sort(DISTANCE,'ascend');

        SortingOrder((CSE+1):end)=SO((CSE+1):end);
        set(handles.Energies,'userdata',SortingOrder);
        DATA(:,2)=Reflections(1,SortingOrder); DATA(:,3)=Reflections(2,SortingOrder); DATA(:,4)=Reflections(3,SortingOrder);
        DATA(:,5)=EnergyMap(SortingOrder); DATA(:,6)=PitchDerMap(SortingOrder); DATA(:,7)=YawDerMap(SortingOrder);
end

DATA=num2cell(DATA);
for TT=1:size(Reflections,2)
    if(TT<=length(CurrentSelections))
        DATA{TT,1}=true;
    else
        DATA{TT,1}=false;
    end
end
set(handles.Energies,'data',DATA);

function [COLORE, STILE, SPESSORE]=LineType(Piano)

C1=Piano(1)^2+Piano(2)^2+Piano(3)^2;
C2=sum(abs(Piano));
C3=max(abs(Piano));

COLORE=[abs(Piano(1)/31),abs(Piano(2))/31,1-abs(Piano(3))/31];

switch(C1)
    case 3
        COLORE=[1,0,0];
    case 8
        COLORE=[0,1,0];
    case 11
        COLORE=[0,0,0];
    case 16
        COLORE=[0,0,1];
    case 19
        COLORE=[1,0,1];
    case 24
        COLORE=[1,0.6,0];
    case 27
        switch(C2)
            case 7
                COLORE=[1,1,0];
            case 9
                COLORE=[0,0.2,0.4];
        end
    case 32
        COLORE=[0,0,0.8];
    case 35
        COLORE=[0.8,0.8,0];
    case 40
        COLORE=[0.2,0,0.8];
    case 43
        COLORE=[0.7,0.7,0];
    case 48
        COLORE=[0.4,0,0.7];
    case 51
        switch(C2)
            case 9
                COLORE=[0.7,0.5,0];
            case 11
                COLORE=[0.7,0.7,0];
        end
    case 56
        COLORE=[0.3,0,0.8];
    case 59
        switch(C2)
            case 11
                COLORE=[0.5,0.3,0.0];
            case 13
                COLORE=[0.5,0.4,0];
        end
    case 64
        COLORE=[0,0.7,0];
    case 67
        COLORE=[0.4,0.4,0];
    case 72 
        switch(C3)
            case 8
                COLORE=[0.5,0,0.7];
            case 6
                COLORE=[0.5,0,0.6];
        end
    case 75
        switch(C2)
            case 13
                COLORE=[0.4,0.3,0.0];
            case 15
                COLORE=[0.4,0.4,0.0];
        end
    case 80
        COLORE=[0.5,1,0.7];
    case 83
        switch(C2)
            case 11
                COLORE=[0.3,0.3,0.0];
            case 15
                COLORE=[0.3,0.4,0.0];
        end
    case 88
        COLORE=[0.5,0.8,0.7];
    case 91
        COLORE=[0.2,0.5,0.0];
    case 96
        COLORE=[0.5,0.6,0.7];
    case 99
        switch(C2)
            case 15
                COLORE=[0.2,0.6,0.0];
            case 17
                COLORE=[0.2,0.7,0.0];
        end
    case 104
        switch(C3)
            case 10
                COLORE=[0.5,0.4,0.7];
            case 8
                COLORE=[0.5,0.2,0.7];
        end
    case 107
        switch(C2)
            case 15
                COLORE=[0.2,0.5,0.1];
            case 17
                COLORE=[0.2,0.4,0.1];
        end
    case 115
        COLORE=[0.3,0.6,0.2];
    case 120
        COLORE=[0.75,0.9,0.7];
    case 123
        switch(C2)
            case 13
                COLORE=[0.3,0.6,0.3];
            case 19
                COLORE=[0.3,0.6,0.4];
        end
    case 128
        COLORE=[0.3,0.4,1];
    otherwise
    COLORE=[abs(Piano(1)/31),abs(Piano(2))/31,1-abs(Piano(3))/31];
end

STILE = '-';
if Piano(1) == Piano(2) && sign(Piano(1)) == ~sign(Piano(3))
      STILE = '--';
   elseif Piano(1) ~= Piano(2)
      STILE = '-.';
end
if(Piano(1) == 0) &&(0==Piano(2))
    STILE='-';
end

SPESSORE=1.5;
% if (sum(Piano==[0,0,4])==3)
%     SPESSORE=2;
% end
% if (sum(Piano==[2,2,0])==3)
%     SPESSORE=2;
% end
if(C1>56)
    SPESSORE=1;
end


% --- Executes on button press in UpdatePlots.
function UpdatePlots_Callback(hObject, eventdata, handles)
Update_PitchYawPlots(handles)



function RPE_Callback(hObject, eventdata, handles)
SortingOrder_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SortingOrder.
function SortingOrder_Callback(hObject, eventdata, handles)
Data=get(handles.SortingOrder,'userdata');
if(~isempty(Data))
    update_energy_table(Data.PitchMap,Data.YawMap,Data.EnergyMap,Data.PitchDerMap,Data.YawDerMap,Data.Reflections,handles)
end

% --- Executes during object creation, after setting all properties.
function SortingOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SortingOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CopyFromTable.
function CopyFromTable_Callback(hObject, eventdata, handles)
DATA{1,1}=[];DATA{1,2}=[];DATA{1,3}=[];DATA{1,4}=[];
DATA{2,1}=[];DATA{2,2}=[];DATA{2,3}=[];DATA{2,4}=[];
data=get(handles.Energies,'data');
SEL=0;
SA=size(data,1);
for II=1:SA
    if(data{II,1})
        SEL=SEL+1;
        DATA{SEL,1}=data{II,2};
        DATA{SEL,2}=data{II,3};
        DATA{SEL,3}=data{II,4};
        DATA{SEL,4}=data{II,5};
    end
    if(SEL==2)
        break
    end
end
if(SEL==2)
    set(handles.Use1,'value',0);set(handles.Use2,'value',0);set(handles.Use12,'value',1);
else
    set(handles.Use1,'value',1);set(handles.Use2,'value',0);set(handles.Use12,'value',0);
end
set(handles.uitable2,'data',DATA);
     
function update_crystalplot(handles)
Crystal=get(handles.Crystal,'userdata');
CD=Crystal.CD;
BeamPropagationDirection=[0;0;1];
CrystalInHolder=handles.fh.CrystalInHolder_CD(CD);
P=str2double(get(handles.P,'string')); Y=str2double(get(handles.Y,'string'));
FullRotationMatrix=handles.fh.FullRot_StructVer_CD_rad(P,Y,CD);
RotationStageMatrix=handles.fh.RotationStages_CD_rad(P,Y,CD);
cla(handles.a4); hold(handles.a4,'on');
EnergiesTable=get(handles.Energies,'data');
Selected=cell2mat(EnergiesTable(:,1));

ReflectionPlanes=[CD.MainCut.',CD.SecondaryCut.',(cell2mat(EnergiesTable(Selected,2:4))).'];
Energies=cell2mat(EnergiesTable(Selected,5)).';

RotatedReflections=FullRotationMatrix*ReflectionPlanes;
RotatedReflectionsDirections=RotatedReflections*diag(1./sqrt(sum(ReflectionPlanes.^2)));
Wireframe=(RotationStageMatrix*CrystalInHolder*handles.Vertex.').';

WakeInput.RotatedReflections=RotatedReflections(:,3:end);
WakeInput.RotatedReflectionsDirections=RotatedReflectionsDirections(:,3:end);
WakeInput.BeamPropagationDirection=BeamPropagationDirection;

ExitDirections=[];

for II=3:size(RotatedReflectionsDirections,2)
    ExitDirections(II-2,:)=handles.fh.Arb_Rot(pi,RotatedReflectionsDirections(:,II))*(-BeamPropagationDirection);
end
ExitDirections=ExitDirections.';

WakeInput.MainCutFaceNormal=RotatedReflections(:,1);
WakeInput.SecondaryCutFaceNormal=RotatedReflections(:,2);
WakeInput.ExitDirections=ExitDirections(:,3:end);
WakeInput.Reflections=ReflectionPlanes(:,3:end);
WakeInput.PhotonEnergies=Energies;

RxMat=handles.fh.Rx(pi/2);
Wireframe=(RxMat*Wireframe.').';
BPD=RxMat*BeamPropagationDirection;
MC=RxMat*RotatedReflectionsDirections(:,1);
SC=RxMat*RotatedReflectionsDirections(:,2);

patch('Vertices', Wireframe, 'Faces', handles.Faces, 'FaceColor', 'flat','FaceVertexCData',handles.ColQuad,'edgecolor','k','FaceAlpha',0.1,'parent',handles.a4);
plot3(handles.a4,[-BPD(1),BPD(1)],[-BPD(2),BPD(2)],[-BPD(3),BPD(3)],'k','linewidth',3);
plot3(handles.a4,[-MC(1),MC(1)]/2,[-MC(2),MC(2)]/2,[-MC(3),MC(3)]/2,'k','linewidth',2);
plot3(handles.a4,[-SC(1),SC(1)]/2,[-SC(2),SC(2)]/2,[-SC(3),SC(3)]/2,'linewidth',2,'color',[0.3,0.3,0.3]);

for II=3:size(RotatedReflectionsDirections,2)
    RBDPLOTx=RxMat*RotatedReflectionsDirections(:,II);
    plot3(handles.a4,[-RBDPLOTx(1),RBDPLOTx(1)]*2/3,[-RBDPLOTx(2),RBDPLOTx(2)]*2/3,[-RBDPLOTx(3),RBDPLOTx(3)]*2/3,'--','linewidth',2,'color',handles.ColorCrystalDefault(1+mod(II-3,handles.ColorCrystalDefaultLength),:));
    RBDPLOT=RxMat*ExitDirections(:,II-2); %exit direction
    plot3(handles.a4,[0,RBDPLOT(1)],[0,RBDPLOT(2)],[0,RBDPLOT(3)],'-','linewidth',2,'color',handles.ColorCrystalDefault(1+mod(II-3,handles.ColorCrystalDefaultLength),:));
end

PropagationDirectionEquation=handles.fh.DirectionEquation(BeamPropagationDirection);
DirectRotation = RotationStageMatrix*CrystalInHolder;
InverseRotation = inv(DirectRotation);
Intersection1=[InverseRotation(2,:);PropagationDirectionEquation]\[CD.Thickness/2;0;0];
Intersection2=[InverseRotation(2,:);PropagationDirectionEquation]\[-CD.Thickness/2;0;0];

WakeInput.EffectiveThickness=norm(Intersection2-Intersection1);

xticks(handles.a4,[]); yticks(handles.a4,[]); zticks(handles.a4,[]);
Update_Wake_Plot(handles,WakeInput,CD)

% --- Executes on button press in UpdateWakePlot.
function UpdateWakePlot_Callback(hObject, eventdata, handles)
Energies=get(handles.Energies,'data');
RequiredIndex=find(cell2mat(Energies(:,1)));
cla(handles.a3);
if(~isempty(RequiredIndex))
    Reflections=cell2mat(Energies(RequiredIndex,2:4));
    Maps=get(handles.SortingOrder,'userdata');
    Tmin=str2double(get(handles.Tmin,'string')); Tmax=str2double(get(handles.Tmax,'string'));
    if(isnan(Tmin) || isnan(Tmax))
        [TimeDomain,ReflectionsInfo]=handles.CD.Wake(Maps.Pitch,Maps.Yaw,Reflections.');
    else
        TimeVector=(Tmin:0.25:Tmax)/10^15;
        [TimeDomain,ReflectionsInfo]=handles.CD.Wake(Maps.Pitch,Maps.Yaw,Reflections.',TimeVector);
    end
    Legenda={}; Tavola={};
    for JJ=1:numel(TimeDomain)
        Legendastring=['(',num2str(Reflections(JJ,1)),',',num2str(Reflections(JJ,2)),',',num2str(Reflections(JJ,3)),')'];
        [COLORE,STILE,SPESSORE]=LineType(Reflections(JJ,:));
        hold(handles.a3,'on')
        plot(handles.a3,TimeDomain(JJ).Time*10^15,abs(TimeDomain(JJ).Wake).^2,STILE,'color',COLORE,'linewidth',SPESSORE);
        Legenda{end+1}=Legendastring;
        TVS=[Legendastring,': '];
        if(ReflectionsInfo.Bragg(JJ))
          TVS=[TVS,'Bragg.  ']; 
        end
        if(ReflectionsInfo.Laue(JJ))
           TVS=[TVS,'Laue.  '];  
        end
        TVS=[TVS,'YuriAngle= ',num2str(abs(ReflectionsInfo.Theta(JJ)*180/pi)),' deg. Energy= ',num2str(ReflectionsInfo.Energies(JJ)),' eV. Tau_0 = ',num2str(10^15*ReflectionsInfo.tau_0(JJ)),' fs',' eV. Tau_d = ',num2str(10^15*ReflectionsInfo.tau_d(JJ)),' fs',' b = ',num2str(ReflectionsInfo.b(JJ)),'  ',' |K0|/|KH| = ',num2str(ReflectionsInfo.NormK0(JJ)/ReflectionsInfo.NormKH(JJ),'%5.2f')];
        %TVS=[TVS,'YS Angle= ',num2str(abs(ReflectionsInfo.Theta(JJ)*180/pi)),' deg. Energy= ',num2str(ReflectionsInfo.Energies(JJ)),' eV'];
        Tavola{end+1}=TVS;
    end
    set(handles.a3,'YScale','log');
    lowpower=str2double(get(handles.edit35,'string')); highpower=str2double(get(handles.edit36,'string'));
    if(~isnan(lowpower)), minimo=10^(-lowpower); else, minimo=-inf; end
    if(~isnan(highpower)), massimo=10^(-highpower); else, massimo=+inf; end
    ylim(handles.a3,[minimo, massimo]);
    legend(handles.a3,Legenda);
    set(handles.WakeInfo,'string',Tavola);
end
%update_crystalplot(handles)

function [Vertex, Faces, ColQuad] = functionPARALLELEPIPEDO(Corner1,Corner2,Height)

Vertex(1,:)=[Corner1(1)-Corner1(1),Corner1(2)-Corner1(2) ,0];
Vertex(2,:)=[Corner1(1)-Corner1(1), Corner2(2)-Corner1(2) ,0];
Vertex(3,:)=[Corner2(1)-Corner1(1), Corner2(2)-Corner1(2),0];
Vertex(4,:)=[Corner2(1)-Corner1(1), Corner1(2)-Corner1(2),0];

Vertex(5,:)=[Corner1(1)-Corner1(1),Corner1(2)-Corner1(2) ,Height];
Vertex(6,:)=[Corner1(1)-Corner1(1), Corner2(2)-Corner1(2) ,Height];
Vertex(7,:)=[Corner2(1)-Corner1(1), Corner2(2)-Corner1(2),Height];
Vertex(8,:)=[Corner2(1)-Corner1(1), Corner1(2)-Corner1(2),Height];

Faces(1,:)=[1,2,3,4]; CF(1)=1;
Faces(2,:)=[1,2,6,5]; CF(2)=2;
Faces(3,:)=[2,3,7,6]; CF(3)=3;
Faces(4,:)=[3,4,8,7]; CF(4)=4;
Faces(5,:)=[4,1,5,8]; CF(5)=5;
Faces(6,:)=[5,6,7,8]; CF(6)=6;

for II=1:6
    switch(CF(II))
        
        case 1
            ColQuad(II,:)=[1,1,1];
        case 2
            ColQuad(II,:)=[0.9,0.9,0.9];
        case 3
            ColQuad(II,:)=[0.8,0.8,0.8];
        case 4
            ColQuad(II,:)=[0.7,0.7,0.7];
        case 5
            ColQuad(II,:)=[0.6,0.6,0.6];
        case 6
            ColQuad(II,:)=[0.5,0.5,0.5];
    end
    
end

function Update_Wake_Plot(handles,WakeInput,CD)
CD
plot(handles.a3,rand(10));
WakeInput


% --- Executes on button press in ManualSelect.
function ManualSelect_Callback(hObject, eventdata, handles)
CurrentTable=get(handles.Energies,'data');
H=str2num(get(handles.MillerH,'string'));
K=str2num(get(handles.MillerK,'string'));
L=str2num(get(handles.MillerL,'string'));
Reflections=handles.CD.AllReflections;
ID=find((Reflections(:,1)==H) & (Reflections(:,2)==K) & (Reflections(:,3)==L) );
if(~isempty(ID))
    FinderH=cell2mat(CurrentTable(:,2)); FinderK=cell2mat(CurrentTable(:,3)); FinderL=cell2mat(CurrentTable(:,4));
    ID2=find((FinderH==H) & (FinderK==K) & (FinderL==L) );
    if(isempty(ID2))
       CurrentTable{end,1}=true;
       CurrentTable{end,2}=H;
       CurrentTable{end,3}=K;
       CurrentTable{end,4}=L;
       Update_PitchYawPlots(handles);
    else
       CurrentTable{ID2,1}=true; 
    end
else
    
end
set(handles.Energies,'data',CurrentTable);
Data=get(handles.SortingOrder,'userdata');
if(~isempty(Data))
    update_energy_table(Data.PitchMap,Data.YawMap,Data.EnergyMap,Data.PitchDerMap,Data.YawDerMap,Data.Reflections,handles)
end
manageLineWidth(handles,get(handles.Energies,'data'));


function MillerH_Callback(hObject, eventdata, handles)
% hObject    handle to MillerH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MillerH as text
%        str2double(get(hObject,'String')) returns contents of MillerH as a double


% --- Executes during object creation, after setting all properties.
function MillerH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MillerH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MillerK_Callback(hObject, eventdata, handles)
% hObject    handle to MillerK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MillerK as text
%        str2double(get(hObject,'String')) returns contents of MillerK as a double


% --- Executes during object creation, after setting all properties.
function MillerK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MillerK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MillerL_Callback(hObject, eventdata, handles)
% hObject    handle to MillerL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MillerL as text
%        str2double(get(hObject,'String')) returns contents of MillerL as a double


% --- Executes during object creation, after setting all properties.
function MillerL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MillerL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function manageLineWidth(handles,Data)
Linee=get(handles.a1,'children');
Linee2=get(handles.a2,'children');
MatriceLinee=[Linee.UserData];
Marked=find(cell2mat(Data(:,1)));
C1=sum(MatriceLinee.^2);
Width=1*(C1<=56)+0.5;
Gross=cell2mat(Data(Marked,2:4));
for II=1:length(Marked)
   Width((MatriceLinee(1,:)==Gross(II,1)) & (MatriceLinee(2,:)==Gross(II,2)) & MatriceLinee(3,:)==Gross(II,3))=3; 
end
for II=1:length(Width)
   if(Linee(II).LineWidth~=Width(II))
       Linee(II).LineWidth=Width(II);
       Linee2(II).LineWidth=Width(II);
   end
end


% --- Executes when entered data in editable cell(s) in Energies.
function Energies_CellEditCallback(hObject, eventdata, handles)
Data=get(handles.Energies,'data');
manageLineWidth(handles,Data);


function MaxAbs_Callback(hObject, eventdata, handles)
% hObject    handle to MaxAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxAbs as text
%        str2double(get(hObject,'String')) returns contents of MaxAbs as a double


% --- Executes during object creation, after setting all properties.
function MaxAbs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Recalculate.
function Recalculate_Callback(hObject, eventdata, handles)
MNR=str2double(get(handles.MNR,'string'));
AbsMax=str2double(get(handles.MaxAbs,'string'));
handles.CD.findAllReflections(AbsMax,MNR);
set(handles.text47,'string',['Found: ',num2str(length(handles.CD.AllReflectionsAbsMax))]);


% --- Executes on button press in FreeMode.
function FreeMode_Callback(hObject, eventdata, handles)
VAL=get(handles.FreeMode,'value');
if(VAL)
   set(handles.SMA,'enable','off'); 
   set(handles.GetAngles,'enable','off'); 
   set(handles.SET_TO_MACHINE,'enable','off');
   set(handles.EXTRACTALL,'enable','off');
   set(handles.INSERT1,'enable','off');
   set(handles.INSERT2,'enable','off');
   set(handles.INSERT3,'enable','off');
else
   set(handles.SMA,'enable','on'); 
   set(handles.GetAngles,'enable','on'); 
   set(handles.SET_TO_MACHINE,'enable','on');
   set(handles.EXTRACTALL,'enable','on');
   set(handles.INSERT1,'enable','on');
   set(handles.INSERT2,'enable','on');
   set(handles.INSERT3,'enable','on');
end


% --- Executes on button press in EXTRACTALL.
function EXTRACTALL_Callback(hObject, eventdata, handles)
handles.InOutSet('pull_all_out','OUT');

% --- Executes on button press in INSERT1.
function INSERT1_Callback(hObject, eventdata, handles)
Nome=get(handles.INSERT1,'userdata');
handles.InOutSet(Nome,'IN');

% --- Executes on button press in INSERT2.
function INSERT2_Callback(hObject, eventdata, handles)
Nome=get(handles.INSERT2,'userdata');
handles.InOutSet(Nome,'IN');

% --- Executes on button press in INSERT3.
function INSERT3_Callback(hObject, eventdata, handles)
Nome=get(handles.INSERT2,'userdata');
handles.InOutSet(Nome,'IN');


% --- Executes on button press in UTFO.
function UTFO_Callback(hObject, eventdata, handles)
Timer_Update([],[],handles,1);



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in WakeInfo.
function WakeInfo_Callback(hObject, eventdata, handles)
% hObject    handle to WakeInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WakeInfo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WakeInfo


% --- Executes during object creation, after setting all properties.
function WakeInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WakeInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
