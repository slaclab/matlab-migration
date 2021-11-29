function varargout = ULT_PSControl(varargin)
% ULT_PSCONTROL MATLAB code for ULT_PSControl.fig
%      ULT_PSCONTROL, by itself, creates a new ULT_PSCONTROL or raises the existing
%      singleton*.
%
%      H = ULT_PSCONTROL returns the handle to a new ULT_PSCONTROL or the handle to
%      the existing singleton*.
%
%      ULT_PSCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT_PSCONTROL.M with the given input arguments.
%
%      ULT_PSCONTROL('Property','Value',...) creates a new ULT_PSCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_PSControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_PSControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT_PSControl

% Last Modified by GUIDE v2.5 18-Sep-2020 13:44:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ULT_PSControl_OpeningFcn, ...
                   'gui_OutputFcn',  @ULT_PSControl_OutputFcn, ...
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


% --- Executes just before ULT_PSControl is made visible.
function ULT_PSControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT_PSControl (see VARARGIN)

% Choose default command line output for ULT_PSControl
handles.output = hObject;
handles.ColorIdle=get(handles.Timer_Reset,'backgroundcolor'); ColorOn=[0,1,0]; ColorOff=[1,0.3,0]; ColorWait=[1,1,0]; ColorErr=[0.8,0,0];
handles.ColorOn=ColorOn; handles.ColorOff=ColorOff; handles.ColorWait=ColorWait; handles.ColorLogBook=[0.4,0.4,1]; handles.ColorErr=ColorErr;

set(handles.S,'ColumnName','S');
handles.UL=varargin{1};
handles.Beamline=varargin{2};
%handles.MostRecentKData=varargin{3};
set(handles.S,'data',false(handles.UL.slotlength,1));
TABLE={};handles.PSPlace=[];handles.GapAct={};handles.GapDes={};handles.PDes={};
for II=1:handles.UL.slotlength
    if(handles.UL.slot(II).PHAS.present)
       TABLE{II,1}= handles.UL.slot(II).PHAS.PV;
       TABLE{II,2}= handles.UL.slot(II).PHAS.Cell_Number;
       TABLE{II,3}=II;
       TABLE{II,4}=NaN;
       TABLE{II,5}=NaN;
       TABLE{II,6}=NaN;
       TABLE{II,7}=NaN;
       handles.PSPlace(end+1)=II;
       handles.GapAct{end+1}=handles.UL.slot(II).PHAS.pv.GapAct;
       handles.GapDes{end+1}=handles.UL.slot(II).PHAS.pv.GapDes;
       handles.PDes{end+1}=handles.UL.slot(II).PHAS.pv.PDes;
    else
       TABLE{II,1}= '****************';  
    end
end
set(handles.TABULA,'data',TABLE);
% Update handles structure
handles=Timer_Reset_Callback(hObject, eventdata, handles);
handles=Timer_Start_Callback(hObject, eventdata, handles);
guidata(hObject, handles);


% UIWAIT makes ULT_PSControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ULT_PSControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function Timer_Update(TimerObject,Type_and_when,handles,MODE)
switch(MODE)
    case -1
        disp('Timer function called in error mode')
        set(handles.Timer_Start,'backgroundcolor',handles.ColorErr)
    case 0
        disp('Timer function called in stop mode')
    case 1
        set(handles.DataAMonfalconeAddi,'string',datestr(now));
        GapAct=lcaGetSmart(handles.GapAct);
        GapDes=lcaGetSmart(handles.GapDes);
        PDes=lcaGetSmart(handles.PDes);
        TABLE=get(handles.TABULA,'data');
        UF=get(handles.UAC,'value');
        if(UF)
            RAL=handles.UL.f.ReadAllLine(handles.UL,1);
        end
        for II=1:length(handles.PSPlace)
           TABLE{handles.PSPlace(II),4}=GapAct(II);
           TABLE{handles.PSPlace(II),5}=GapDes(II);
           TABLE{handles.PSPlace(II),7}=PDes(II);
           if(UF)
                TABLE{handles.PSPlace(II),6}=RAL(handles.PSPlace(II)).Phase;
           end
        end
        set(handles.TABULA,'data',TABLE);
    case 2
        disp('Timer function called in start mode')
end

function SS_edit_Callback(hObject, eventdata, handles)
% hObject    handle to SS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SS_edit as text
%        str2double(get(hObject,'String')) returns contents of SS_edit as a double


% --- Executes during object creation, after setting all properties.
function SS_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SS_Expression.
function SS_Expression_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
SS=str2num(get(handles.SS_edit,'string'));
S=false(size(S));%set=0;
TABULA=get(handles.TABULA,'data');
for II=1:length(SS)
    S(SS(II))=true;
    %set=TABULA{II,7};
end
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
%set(handles.Target,'string',num2str(set));



% --- Executes on button press in SS_Alternate.
function SS_Alternate_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
TABULA_NEW=get(handles.TABULA_NEW,'data');
SS=str2num(get(handles.SS_edit,'string'));
S=false(size(S));
INS=0;SET=true;
II=1;
while(II<=length(S))
    while(INS<SS)
        if(~isempty(TABULA_NEW{II,2}))
            S(II)=SET;
            INS=INS+1;
        end
    II=II+1;
    if(II>length(S))
        break
    end
    end
    SET=~SET;
INS=0;
end
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
set(handles.S,'data',S);


% --- Executes on button press in SS_All.
function SS_All_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
S=true(size(S));
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
set(handles.S,'data',S);


% --- Executes on button press in SS_Complement.
function SS_Complement_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
for II=1:length(S)
    S(II)=~S(II);
end
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
set(handles.S,'data',S);


% --- Executes on button press in SS_None.
function SS_None_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
S=false(size(S));
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
set(handles.S,'data',S);


function Target_Callback(hObject, eventdata, handles)
% hObject    handle to Target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Target as text
%        str2double(get(hObject,'String')) returns contents of Target as a double


% --- Executes during object creation, after setting all properties.
function Target_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Relative_Movement(handles,Delta)
S=get(handles.S,'data'); T=get(handles.TABULA,'data');
Target=Delta;
CV=[];TV=[];SV=[];
for II=1:numel(S)
   if(S(II))
       if(~isempty(T{II,2}))
           CV(end+1)=T{II,2};
           SV(end+1)=T{II,3};
           TV(end+1)=Target;
       end
   end
end
disp('Setting Phaseshifters');
switch(handles.UL.name(1))
    case 'H'
        line='HXR';
    case 'S'
        line='SXR';
end

PSgap = DeltaPhase2PSgap (line,CV,TV).';
PSGapSet(line, CV, PSgap);

% --- Executes on button press in GO.
function GO_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');T=get(handles.TABULA,'data');
NewVal=str2num(get(handles.Target,'string'));
for II=1:length(S)
    if(S(II))
        if(handles.UL.slot(II).PHAS.present)
            handles.UL.slot(II).PHAS.f.Set_Phase(handles.UL.slot(II).PHAS,NewVal);
        end
    end
end
handles.UL.f.Set_phase_shifters(handles.UL); % Reads destination and re-calculates phase shifters.






% --- Executes on button press in M3.
function M3_Callback(hObject, eventdata, handles)
Delta=str2double(get(handles.eM3,'string'));
Relative_Movement(handles,Delta)

function eM3_Callback(hObject, eventdata, handles)
% hObject    handle to eM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eM3 as text
%        str2double(get(hObject,'String')) returns contents of eM3 as a double


% --- Executes during object creation, after setting all properties.
function eM3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eM3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in M2.
function M2_Callback(hObject, eventdata, handles)
Delta=str2double(get(handles.eM2,'string'));
Relative_Movement(handles,Delta)

% --- Executes on button press in M1.
function M1_Callback(hObject, eventdata, handles)
Delta=str2double(get(handles.eM1,'string'));
Relative_Movement(handles,Delta)



function eM2_Callback(hObject, eventdata, handles)
% hObject    handle to eM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eM2 as text
%        str2double(get(hObject,'String')) returns contents of eM2 as a double


% --- Executes during object creation, after setting all properties.
function eM2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eM1_Callback(hObject, eventdata, handles)
% hObject    handle to eM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eM1 as text
%        str2double(get(hObject,'String')) returns contents of eM1 as a double


% --- Executes during object creation, after setting all properties.
function eM1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eM1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in L1.
function L1_Callback(hObject, eventdata, handles)
Delta=str2double(get(handles.eL1,'string'));
Relative_Movement(handles,-Delta)


function eL1_Callback(hObject, eventdata, handles)
% hObject    handle to eL1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eL1 as text
%        str2double(get(hObject,'String')) returns contents of eL1 as a double


% --- Executes during object creation, after setting all properties.
function eL1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eL1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in L2.
function L2_Callback(hObject, eventdata, handles)
Delta=str2double(get(handles.eL2,'string'));
Relative_Movement(handles,-Delta)

% --- Executes on button press in L3.
function L3_Callback(hObject, eventdata, handles)
Delta=str2double(get(handles.eL3,'string'));
Relative_Movement(handles,-Delta)

function eL2_Callback(hObject, eventdata, handles)
% hObject    handle to eL2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eL2 as text
%        str2double(get(hObject,'String')) returns contents of eL2 as a double


% --- Executes during object creation, after setting all properties.
function eL2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eL2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eL3_Callback(hObject, eventdata, handles)
% hObject    handle to eL3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eL3 as text
%        str2double(get(hObject,'String')) returns contents of eL3 as a double


% --- Executes during object creation, after setting all properties.
function eL3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eL3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
PERIODO=0.4;
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


% --- Executes on button press in SetAll.
function SetAll_Callback(hObject, eventdata, handles)
% hObject    handle to SetAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    stop(handles.TIMER);
end
try
    delete(handles.TIMER);
end
try
    delete(hObject);
end


% --- Executes on button press in UAC.
function UAC_Callback(hObject, eventdata, handles)
% hObject    handle to UAC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of UAC


% --- Executes on button press in ACTtoDES.
function ACTtoDES_Callback(hObject, eventdata, handles)
RAL=handles.UL.f.ReadAllLine(handles.UL,1);
Vals=round([RAL(handles.PSPlace).Phase]);
lcaPutSmart(handles.PDes(:),Vals(:));


% --- Executes when selected cell(s) is changed in S.
function S_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to S (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in S.
function S_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to S (see GCBO)
% eventdata  structure with the  following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Manual.
function Manual_Callback(hObject, eventdata, handles)
Timer_Update([],[],handles,1)
