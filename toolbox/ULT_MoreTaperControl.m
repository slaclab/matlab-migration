function varargout = ULT_MoreTaperControl(varargin)
% ULT_MORETAPERCONTROL MATLAB code for ULT_MoreTaperControl.fig
%      ULT_MORETAPERCONTROL, by itself, creates a new ULT_MORETAPERCONTROL or raises the existing
%      singleton*.
%
%      H = ULT_MORETAPERCONTROL returns the handle to a new ULT_MORETAPERCONTROL or the handle to
%      the existing singleton*.
%
%      ULT_MORETAPERCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT_MORETAPERCONTROL.M with the given input arguments.
%
%      ULT_MORETAPERCONTROL('Property','Value',...) creates a new ULT_MORETAPERCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_MoreTaperControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_MoreTaperControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT_MoreTaperControl

% Last Modified by GUIDE v2.5 14-Jul-2021 13:31:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ULT_MoreTaperControl_OpeningFcn, ...
                   'gui_OutputFcn',  @ULT_MoreTaperControl_OutputFcn, ...
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


% --- Executes just before ULT_MoreTaperControl is made visible.
function ULT_MoreTaperControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT_MoreTaperControl (see VARARGIN)

% Choose default command line output for ULT_MoreTaperControl
handles.output = hObject;

ColorOn=[0,1,0]; ColorWait=[1,1,0]; ColorOff=[1,0,0]; Color_CU_SXR=[230/255,184/255,179/255]; Color_CU_HXR=[202/255,214/255,230/255]; Color_FACET=[230,184,179]; Color_Unknown=[0.7,0.7,0.7];
handles.Color_CU_HXR=Color_CU_HXR; handles.Color_CU_SXR=Color_CU_SXR; handles.Color_FACET=Color_FACET; handles.Color_Unknown=Color_Unknown;
handles.ColorOn=ColorOn; handles.ColorOff=ColorOff; handles.ColorWait=ColorWait; handles.ColorLogBook=[0.4,0.4,1];

set(handles.S,'ColumnName','S');
set(handles.StoreSelectionsList,'userdata',[]);
set(handles.StoreTaperList,'userdata',[]);
handles.StoreFolder='/u1/lcls/matlab/ULT_GuiData';
if(~isdir(handles.StoreFolder))
    mkdir(handles.StoreFolder)
end

petizione1.Init=1;
petizione1.UpdateReadout=0;
petizione1.PlotNow=0;

set(handles.Petizione1,'userdata',petizione1);

petizione2.K=[];
petizione2.Kend=[];
petizione2.S=[];
petizione2.H=[];
petizione2.D=[];
petizione2.PS=[];
petizione2.sty1='b*';set(handles.Style1,'string',petizione2.sty1);
petizione2.sty2='b.';set(handles.Style2,'string',petizione2.sty2);
set(handles.Petizione2,'userdata',petizione2);
handles.UL=varargin{1};
handles.Beamline=varargin{2};
handles.MostRecentKData=varargin{3};
handles.MainAxis=varargin{4};
handles.OtherAxis=varargin{5};
handles.MainAxisMarkers=varargin{6};
handles.MyUniqueIdentifier=hObject;
set(handles.S,'data',false(handles.UL.slotlength,1));

switch(handles.Beamline)
    case 1
        set_gui_color(handles,handles.Color_CU_HXR)
    case 2
        set_gui_color(handles,handles.Color_CU_SXR)
    otherwise
        set_gui_color(handles,handles.Color_CU_HXR)
end

% Update handles structure
guidata(hObject, handles);
UpdateReadBacks(handles,1,1);
UpdatePlots(handles);

% UIWAIT makes ULT_MoreTaperControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ULT_MoreTaperControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function set_gui_color(handles,COLOR)
set(handles.figure1,'color',COLOR);
set(handles.text12,'backgroundcolor',COLOR);
set(handles.text13,'backgroundcolor',COLOR);
set(handles.fwefwe,'backgroundcolor',COLOR);
set(handles.text15,'backgroundcolor',COLOR);

function PlotIntoPlots(handles)

if(~isempty(ADD))
    for LL=1:ADD.nummerOfDetails
        if(PlotData.ULID==ADD.Beamline(LL))
            if(ishandle(ADD.DetailTags(LL).tags.TABULA_NEW))
                % Read stuff here !
                petizione2=get(ADD.DetailTags(LL).tags.Petizione2,'userdata');
                for II=1:length(handles.UL(PlotData.ULID).slot)
                    if(handles.UL(PlotData.ULID).slot(II).undulator.isInstalled && ~ handles.UL(PlotData.ULID).slot(II).undulator.isMaintenance) %if is installed and not in maintenance get K and plot segment & undulator name
                        if(petizione2.S(II))
                            PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,(PlotData.z_in_end(II,1)+PlotData.z_in_end(II,2))/2,petizione2.K(II),petizione2.sty1,'markersize',10);
                        else
                            PlotData.toBeDeleted(end+1)=plot(handles.MainPlotAxis,(PlotData.z_in_end(II,1)+PlotData.z_in_end(II,2))/2,petizione2.K(II),petizione2.sty2);
                        end
                    end
                end
            else
                ADDtoBeDeleted(end+1)=LL;
            end
        end
    end
end

% --- Executes on button press in Duplicate_Controls.
function Duplicate_Controls_Callback(hObject, eventdata, handles)
% hObject    handle to Duplicate_Controls (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MoveSelectedToBlueStars.
function MoveSelectedToBlueStars_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
TN=get(handles.TABULA_NEW,'data');
LineReadout=handles.UL.f.ReadAllLine(handles.UL);
set(handles.undoLastMovement,'userdata',LineReadout);
ins=0;
for II=1:length(S)
    if(handles.UL.UsegPresent(II))
        if(S(II))
            ins=ins+1;    
            NewDest=handles.UL.slot(II).USEG.f.Set_K_struct(handles.UL.slot(II).USEG,[TN{II,1},TN{II,2}],TN{II,3},handles.UL.Basic.Reference_lambda_u); 
            if(ins==1)
                Destination(1)=NewDest;
            else
                Destination(ins)=NewDest;
            end
        end
    end
end
handles.UL.f.UndulatorLine_K_set(handles.UL,Destination);

% function K_harm=eval_harmonic_K(K, harm)
% K_harm=sqrt(2.*harm-2+K(1).^2.*harm);

% --- Executes on button press in undoLastMovement.
function undoLastMovement_Callback(hObject, eventdata, handles)
OLD_CONF=get(handles.undoLastMovement,'userdata'); ins=0;
S=get(handles.S,'data');
if(~isempty(OLD_CONF))
    for II=1:length(S)
        if(handles.UL.slot(II).USEG.present)
            if(S(II))
                ins=ins+1;
                NewDest=handles.UL.slot(II).USEG.f.Set_K_struct(handles.UL.slot(II).USEG,[OLD_CONF(II).K,OLD_CONF(II).Kend],1,handles.UL.Basic.Reference_lambda_u);

                if(ins==1)
                    Destination(1)=NewDest;
                else
                    Destination(end+1)=NewDest;
                end             
            else
            end
        end
    end
end
handles.UL.f.UndulatorLine_K_set(handles.UL,Destination);
UpdatePlots(handles);
% 
% 
% TN=get(handles.TABULA_NEW,'data');
% LineReadout=handles.UL.f.ReadAllLine(handles.UL);
% set(handles.undoLastMovement,'userdata',LineReadout);
% ins=0;
% for II=1:length(S)
%     if(handles.UL.UsegPresent(II))
%         if(S(II))
%             ins=ins+1;    
%             NewDest=handles.UL(ULID).slot(II).USEG.f.Set_K_struct(handles.UL(ULID).slot(II).USEG,[TN{II,1},TN{II,2}],TN{II,3},handles.UL(ULID).Basic.Reference_lambda_u); 
%             if(ins==1)
%                 Destination(1)=NewDest;
%             else
%                 Destination(ins)=NewDest;
%             end
%         end
%     end
% end
% handles.UL(ULID).f.UndulatorLine_K_set(handles.UL(ULID),Destination);



function TS_TaperShape0_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShape0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShape0 as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShape0 as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShape0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShape0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShape1_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShape1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShape1 as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShape1 as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShape1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShape1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShapeS_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShapeS as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShapeS as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShapeS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShape3_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShape3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShape3 as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShape3 as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShape3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShape3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TS_Apply.
function TS_Apply_Callback(hObject, eventdata, handles)
TABULA_NEW=get(handles.TABULA_NEW,'data');
S=get(handles.S,'data');
petizione2=get(handles.Petizione2,'userdata');
CT=get(handles.TS_ContTaper,'value');
C(1)=str2num(get(handles.TS_TaperShape0,'string')); 
C(2)=str2num(get(handles.TS_TaperShape1,'string'));
C(3)=str2num(get(handles.TS_TaperShape3,'string'));
D(1)=str2num(get(handles.TS_TaperShapep,'string'));
E(1)=str2num(get(handles.TS_TaperShapeS,'string'));

Parameters(1)=C(1); %Start K
Parameters(2)=C(2); %Linear 
Parameters(3)=C(3); %Power Term
Parameters(5)=D(1); %Power Coefficient;
Parameters(4)=E(1); %Power start location;
Parameters(6)=CT(1); %1 for Continuous taper;

K = EvalTaperShaping(handles, S, Parameters);
SA=size(TABULA_NEW,1);

for II=1:SA
    if(S(II))
        if(TABULA_NEW{II,3}) % se ha harmonic number
            petizione2.K(II) = K(II,1);
            petizione2.Kend(II) = K(II,2);
            TABULA_NEW{II,1} = K(II,1);
            TABULA_NEW{II,2} = K(II,2);
        end
    end
end

set(handles.Petizione2,'userdata',petizione2);
set(handles.TABULA_NEW,'data',TABULA_NEW);
petizione1=get(handles.Petizione1,'userdata');
petizione1.PlotNow=1;
set(handles.Petizione1,'userdata',petizione1);
UpdatePlots(handles)


function BD_Difference0_Callback(hObject, eventdata, handles)
% hObject    handle to BD_Difference0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BD_Difference0 as text
%        str2double(get(hObject,'String')) returns contents of BD_Difference0 as a double


% --- Executes during object creation, after setting all properties.
function BD_Difference0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BD_Difference0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BD_Difference1_Callback(hObject, eventdata, handles)
% hObject    handle to BD_Difference1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BD_Difference1 as text
%        str2double(get(hObject,'String')) returns contents of BD_Difference1 as a double


% --- Executes during object creation, after setting all properties.
function BD_Difference1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BD_Difference1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BD_Difference2_Callback(hObject, eventdata, handles)
% hObject    handle to BD_Difference2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BD_Difference2 as text
%        str2double(get(hObject,'String')) returns contents of BD_Difference2 as a double


% --- Executes during object creation, after setting all properties.
function BD_Difference2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BD_Difference2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BD_ApplyDifference.
function BD_ApplyDifference_Callback(hObject, eventdata, handles)
TABULA_NEW=get(handles.TABULA_NEW,'data');
S=get(handles.S,'data');
petizione2=get(handles.Petizione2,'userdata');
C(1)=str2num(get(handles.BD_Difference0,'string'));
C(2)=str2num(get(handles.BD_Difference1,'string'));
C(3)=str2num(get(handles.BD_Difference2,'string'));
D(1)=str2num(get(handles.BD_Differencep,'string'));
[SA,SB]=size(TABULA_NEW); inserted=0;
for II=1:SA
    if(TABULA_NEW{II,1})
        if(S(II))
            petizione2.K(II) = TABULA_NEW{II,1} + C(1) + C(2)*inserted + C(3)*inserted^D(1);
            petizione2.Kend(II) = TABULA_NEW{II,2} + C(1) + C(2)*inserted + C(3)*inserted^D(1);
            TABULA_NEW{II,1} = petizione2.K(II);
            TABULA_NEW{II,2} = petizione2.Kend(II);
            inserted=inserted+1;
        end
    end
end
set(handles.Petizione2,'userdata',petizione2);
set(handles.TABULA_NEW,'data',TABULA_NEW);
petizione1=get(handles.Petizione1,'userdata');
petizione1.PlotNow=1;
set(handles.Petizione1,'userdata',petizione1);
UpdatePlots(handles)


% --- Executes on button press in BD_DifferenceSetTo0.
function BD_DifferenceSetTo0_Callback(hObject, eventdata, handles)
set(handles.BD_Difference0,'string','0');set(handles.BD_Difference1,'string','0');set(handles.BD_Difference2,'string','0'); set(handles.BD_Differencep,'string','2');
TABULA=get(handles.TABULA,'data');
set(handles.TABULA_NEW,'data',TABULA);
petizione1=get(handles.Petizione1,'userdata');
petizione1.PlotNow=1;
set(handles.Petizione1,'userdata',petizione1);


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
S=false(size(S));
for II=1:length(SS)
    S(SS(II))=true;
end
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
UpdatePlots(handles)



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
UpdatePlots(handles)


% --- Executes on button press in SS_All.
function SS_All_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
S=true(size(S));
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
set(handles.S,'data',S);
UpdatePlots(handles)


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
UpdatePlots(handles)

% --- Executes on button press in SS_None.
function SS_None_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
S=false(size(S));
petizione2=get(handles.Petizione2,'userdata');
petizione2.S=S;
set(handles.S,'data',S);
set(handles.Petizione2,'userdata',petizione2);
set(handles.S,'data',S);
UpdatePlots(handles)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Style1_Callback(hObject, eventdata, handles)
petizione2=get(handles.Petizione2,'userdata');
petizione2.sty1=get(hObject,'string');
set(handles.Petizione2,'userdata',petizione2);
UpdatePlots(handles);


% --- Executes during object creation, after setting all properties.
function Style1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Style1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Style2_Callback(hObject, eventdata, handles)
petizione2=get(handles.Petizione2,'userdata');
petizione2.sty2=get(hObject,'string');
set(handles.Petizione2,'userdata',petizione2);
UpdatePlots(handles);


% --- Executes during object creation, after setting all properties.
function Style2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Style2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BD_Differencep_Callback(hObject, eventdata, handles)
% hObject    handle to BD_Differencep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BD_Differencep as text
%        str2double(get(hObject,'String')) returns contents of BD_Differencep as a double


% --- Executes during object creation, after setting all properties.
function BD_Differencep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BD_Differencep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShapep_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShapep as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShapep as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShapep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StoreTaper.
function StoreTaper_Callback(hObject, eventdata, handles)
Name=get(handles.StoreTaperEdit,'string');
List=get(handles.StoreTaperList,'string');
READINGS=get(handles.TABULA,'data');
OldSelections=get(handles.StoreTaperList,'userdata');
if(isempty(OldSelections))
   OldSelections=READINGS;
   List{1}=Name;
else
   OldSelections(end+1)=READINGS; 
   List{end+1}=Name;
end
set(handles.StoreTaperList,'userdata',OldSelections);
set(handles.StoreTaperList,'string',List);
set(handles.StoreTaperList,'value',numel(List));

% --- Executes on button press in StoreSelections.
function StoreSelections_Callback(hObject, eventdata, handles)
Name=get(handles.StoreSelectionsEdit,'string');
List=get(handles.StoreSelectionsList,'string');
OldSelections=get(handles.StoreSelectionsList,'userdata');
RestoreData.TableS=get(handles.S,'data');
RestoreData.SS_edit=get(handles.SS_edit,'string');
RestoreData.BD_Difference0=get(handles.BD_Difference0,'string');
RestoreData.BD_Difference1=get(handles.BD_Difference1,'string');
RestoreData.BD_Difference2=get(handles.BD_Difference2,'string');
RestoreData.BD_Differencep=get(handles.BD_Differencep,'string');
RestoreData.HarmonicNumberEdit=get(handles.HarmonicNumberEdit,'string');
RestoreData.Chicane_Delay=get(handles.Chicane_Delay,'string'); 
RestoreData.PS_1=get(handles.PS_1,'string');
RestoreData.TS_TaperShape0=get(handles.TS_TaperShape0,'string');
RestoreData.TS_TaperShape1=get(handles.TS_TaperShape1,'string');
RestoreData.TS_TaperShapeS=get(handles.TS_TaperShapeS,'string');
RestoreData.TS_TaperShape3=get(handles.TS_TaperShape3,'string');
RestoreData.TS_TaperShapep=get(handles.TS_TaperShapep,'string');
RestoreData.TS_TaperShapeSinAmp=get(handles.TS_TaperShapeSinAmp,'string');
RestoreData.TS_TaperShapeSinPhase=get(handles.TS_TaperShapeSinPhase,'string');
RestoreData.TS_TaperShapeSinPeriod=get(handles.TS_TaperShapeSinPeriod,'string');
%RestoreData.TS_TaperShapeSinCosf=get(handles.TS_TaperShapeSinCosf,'string');
if(isempty(OldSelections))
    OldSelections=RestoreData;
    List{1}=Name;
else
    OldSelections(end+1)=RestoreData;
    List{end+1}=Name;
end
set(handles.StoreSelectionsList,'userdata',OldSelections);
set(handles.StoreSelectionsList,'string',List);
set(handles.StoreSelectionsList,'value',numel(List));


% --- Executes on selection change in StoreSelectionsList.
function StoreSelectionsList_Callback(hObject, eventdata, handles)
% hObject    handle to StoreSelectionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StoreSelectionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StoreSelectionsList


% --- Executes during object creation, after setting all properties.
function StoreSelectionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StoreSelectionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in StoreTaperList.
function StoreTaperList_Callback(hObject, eventdata, handles)
% hObject    handle to StoreTaperList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StoreTaperList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StoreTaperList


% --- Executes during object creation, after setting all properties.
function StoreTaperList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StoreTaperList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StoreTaperEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StoreTaperEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StoreTaperEdit as text
%        str2double(get(hObject,'String')) returns contents of StoreTaperEdit as a double


% --- Executes during object creation, after setting all properties.
function StoreTaperEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StoreTaperEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StoreSelectionsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to StoreSelectionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StoreSelectionsEdit as text
%        str2double(get(hObject,'String')) returns contents of StoreSelectionsEdit as a double


% --- Executes during object creation, after setting all properties.
function StoreSelectionsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StoreSelectionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RestoreTaper.
function RestoreTaper_Callback(hObject, eventdata, handles)
Val=get(handles.StoreTaperList,'value');
OldSelections=get(handles.StoreTaperList,'userdata');
if(~isempty(Val))
   if(Val && (Val<=numel(OldSelections))) 
      set(handles.TABULA_NEW,'data',OldSelections(Val));
   end
   S=get(handles.S,'data');
   S=true(size(S));
   set(handles.S,'data',S);
end


% --- Executes on button press in RestoreSelections.
function RestoreSelections_Callback(hObject, eventdata, handles)
RestoreData=get(handles.StoreSelectionsList,'userdata');
if(~isempty(RestoreData))
   Val=get(handles.StoreSelectionsList,'value');
   if(~isempty(Val))
       if((Val(1)) && (Val(1)<=numel(RestoreData)))
            set(handles.S,'data',RestoreData(Val).TableS);
            set(handles.SS_edit,'string',RestoreData(Val).SS_edit);
            set(handles.BD_Difference0,'string',RestoreData(Val).BD_Difference0);
            set(handles.BD_Difference1,'string',RestoreData(Val).BD_Difference1);
            set(handles.BD_Difference2,'string',RestoreData(Val).BD_Difference2);
            set(handles.BD_Differencep,'string',RestoreData(Val).BD_Differencep);
            set(handles.HarmonicNumberEdit,'string',RestoreData(Val).HarmonicNumberEdit);
            set(handles.Chicane_Delay,'string',RestoreData(Val).Chicane_Delay); 
            set(handles.PS_1,'string',RestoreData(Val).PS_1);
            set(handles.TS_TaperShape0,'string',RestoreData(Val).TS_TaperShape0);
            set(handles.TS_TaperShape1,'string',RestoreData(Val).TS_TaperShape1);
            set(handles.TS_TaperShapeS,'string',RestoreData(Val).TS_TaperShapeS);
            set(handles.TS_TaperShape3,'string',RestoreData(Val).TS_TaperShape3);
            set(handles.TS_TaperShapep,'string',RestoreData(Val).TS_TaperShapep);
            set(handles.TS_TaperShapeSinAmp,'string',RestoreData(Val).TS_TaperShapeSinAmp);
            set(handles.TS_TaperShapeSinPhase,'string',RestoreData(Val).TS_TaperShapeSinPhase);
            set(handles.TS_TaperShapeSinPeriod,'string',RestoreData(Val).TS_TaperShapeSinPeriod);
%            set(handles.TS_TaperShapeSinCosf,'string',RestoreData(Val).TS_TaperShapeSinCosf);
       end
   end
end

% --- Executes on button press in DUMPSTATE.
function DUMPSTATE_Callback(hObject, eventdata, handles)
ON_DISK.TaperList=get(handles.StoreTaperList,'string');
ON_DISK.TaperData=get(handles.StoreTaperList,'userdata');
ON_DISK.SelectionsList=get(handles.StoreSelectionsList,'string');
ON_DISK.SelectionsData=get(handles.StoreSelectionsList,'userdata');
CurrentTime=clock; 
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentDieiString=num2str(CurrentTime(3),'%.2d');
CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];
filename=['UUT_TaperData_',CurrentTimeString];
save([handles.StoreFolder,'/',filename],'ON_DISK','-v7.3');

% --- Executes on button press in RESTOREDUMP.
function RESTOREDUMP_Callback(hObject, eventdata, handles)
[FILENAME,FILEPATH]=uigetfile([handles.StoreFolder,'/UUT_TaperData*.*']);
load([FILEPATH,FILENAME],'ON_DISK');
set(handles.StoreTaperList,'string',ON_DISK.TaperList);
set(handles.StoreTaperList,'userdata',ON_DISK.TaperData);
set(handles.StoreSelectionsList,'string',ON_DISK.SelectionsList);
set(handles.StoreSelectionsList,'userdata',ON_DISK.SelectionsData);
set(handles.StoreTaperList,'value',1); set(handles.StoreSelectionsList,'value',1);

function Chicane_Delay_Callback(hObject, eventdata, handles)
% hObject    handle to Chicane_Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Chicane_Delay as text
%        str2double(get(hObject,'String')) returns contents of Chicane_Delay as a double


% --- Executes during object creation, after setting all properties.
function Chicane_Delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Chicane_Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PS_1_Callback(hObject, eventdata, handles)
% hObject    handle to PS_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PS_1 as text
%        str2double(get(hObject,'String')) returns contents of PS_1 as a double


% --- Executes during object creation, after setting all properties.
function PS_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PS_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShapeSinAmp_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinAmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShapeSinAmp as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShapeSinAmp as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShapeSinAmp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinAmp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShapeSinPhase_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShapeSinPhase as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShapeSinPhase as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShapeSinPhase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShapeSinPeriod_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShapeSinPeriod as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShapeSinPeriod as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShapeSinPeriod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinPeriod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TS_TaperShapeSinCosf_Callback(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinCosf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TS_TaperShapeSinCosf as text
%        str2double(get(hObject,'String')) returns contents of TS_TaperShapeSinCosf as a double


% --- Executes during object creation, after setting all properties.
function TS_TaperShapeSinCosf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TS_TaperShapeSinCosf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HarmonicNumberEdit_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function HarmonicNumberEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HarmonicNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Err=ErrEvalTaperShaping(handles, S, Parameters,READINGS,USE,Parameters0)
P=Parameters0;
P(USE)=Parameters;
K=EvalTaperShaping(handles, S, P); IDs=~isnan(K(:,1));
Kt(:,1)=cell2mat(READINGS(IDs,1));
Kt(:,2)=cell2mat(READINGS(IDs,2));
Err=sum(sum((K(~isnan(K))-Kt(:)).^2));


function K = EvalTaperShaping(handles, S, Parameters)
C(1)=Parameters(1); %Start K
C(2)=Parameters(2); %Linear 
C(3)=Parameters(3); %Power Term
D(1)=Parameters(5); %Power Coefficient;
E(1)=Parameters(4); %Power start location;
CT(1)=Parameters(6); %1 for Continuous taper;

K=NaN*zeros(handles.UL.slotlength,2);

II=0; SETTING=0; Linears=0; Powers=0; First=1; Second=2; SLOPE=[];
while(II<handles.UL.slotlength)
    II=II+1;
    if(S(II))
        SETTING=1;
        if(handles.UL.slot(II).USEG.present) %there is an undulator
            K(II,1)=C(1)+Linears*C(2)+C(3)*Powers.^D(1);
            if(CT)
                if(~First)
                    K(LASTID,2) = K(II,1);
                    SLOPE(end+1)=K(LASTID,2) - K(LASTID,1);
                end
            else
                K(II,2)=K(II,1); 
            end
            LASTID=II;
            First=0; Second=Second-1;
            if(II>=E(1))
                Powers=Powers+1;
                Linears=Linears+1;
            else
                Linears=Linears+1;
            end
        else
            Linears=Linears+1;
        end
    else
        if(SETTING)
            Linears=Linears+1;
        else
            continue
        end
    end
end

if(CT)
      if(~First)
                 if(Second==1) %There is only one, copy & paste
                     K(LASTID,2)=K(LASTID,1);
                 elseif(Second<1)
                     K(LASTID,2)=K(LASTID,1)+SLOPE(end);
                 end
      else %there was none!
          
      end
end

% --- Executes on button press in TS_FitSelected.
function TS_FitSelected_Callback(hObject, eventdata, handles)
READINGS=get(handles.TABULA,'data');
S=get(handles.S,'data');
StartPos=find(S & handles.UL.UsegPresent,1,'first');
if(~isempty(StartPos))
   Parameters0(1)=READINGS{StartPos,1};
else
   Parameters0(1)=rand(1);
end
Parameters0(6)=get(handles.TS_ContTaper,'value'); %do not fit on 6 ! Just use what marked by user
Parameters0(5)=2;
Parameters0(4)=find(S & handles.UL.UsegPresent,1,'last');
%Parameters0(2)=1;
USE=logical([1,1,0,0,0,0]);
E0=ErrEvalTaperShaping(handles, S, Parameters0(USE),READINGS,USE,Parameters0);
[Parameters1,E1]=fminsearch(@(X) ErrEvalTaperShaping(handles, S, X,READINGS,USE,Parameters0),Parameters0(USE));
Parameters2=Parameters0; Parameters2(USE)=Parameters1;
if(E1>10^-6) % Needs a quadratic, but don't play on the continuos taper yet.
    %cycle on quadratic start but do not fit. It is hard for fminsearch to
    %search on discrete variables.
    AllQuadStarts=find(S & handles.UL.UsegPresent);
    USE=logical([1,1,1,0,1,0]); E3min=inf;
    for KK=1:length(AllQuadStarts)
        Parameters2(4)=AllQuadStarts(KK);
        [Parameters3,E3]=fminsearch(@(X) ErrEvalTaperShaping(handles, S, X,READINGS,USE,Parameters2),Parameters2(USE));
        %[E3, E3min]
        if(E3<E3min)
            Parameters4=Parameters2; Parameters4(USE)=Parameters3;
            E3min=E3;
        end
    end
    Parameters6=Parameters4; %use quadratic power term
else %Linear and constant are enough
    Parameters6=Parameters2;
end

%remove too low numbers:
if(abs(Parameters6(2))<10^-6)
    Parameters6(2)=0;
end
if(abs(Parameters6(3))<10^-6)
   Parameters6(3)=0; Parameters6(4)=1; Parameters6(5)=2; 
end

set(handles.TS_ContTaper,'value',Parameters0(6));
set(handles.TS_TaperShape0,'string',num2str(Parameters6(1)));
set(handles.TS_TaperShape1,'string',num2str(Parameters6(2)));
set(handles.TS_TaperShape3,'string',num2str(Parameters6(3)));
set(handles.TS_TaperShapeS,'string',num2str(Parameters6(4)));
set(handles.TS_TaperShapep,'string',num2str(Parameters6(5)));


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
DATA=get(handles.TABULA,'data');
[SA,~]=size(DATA); inserted=0;
petizione2=get(handles.Petizione2,'userdata');
for II=1:SA
    if(DATA{II,2})
        %if(S(II))
            petizione2.K(II) = DATA{II,1}; % K iniziale
            petizione2.Kend(II) = DATA{II,2}; % K finale
            petizione2.H(II) = DATA{II,3}; % Harmonica
            DATA{II,2} = petizione2.K(II);
            inserted=inserted+1;
        %end
    end
end
set(handles.Petizione2,'userdata',petizione2);
set(handles.TABULA_NEW,'data',DATA);
petizione1=get(handles.Petizione1,'userdata');
petizione1.PlotNow=1;
set(handles.Petizione1,'userdata',petizione1);
UpdatePlots(handles)

% --- Executes on button press in Harmonic_Apply.
function Harmonic_Apply_Callback(hObject, eventdata, handles)
TABULA_NEW=get(handles.TABULA_NEW,'data');
petizione2=get(handles.Petizione2,'userdata');
S=get(handles.S,'data');
NewVal=str2num(get(handles.HarmonicNumberEdit,'string'));
[SA,SB]=size(TABULA_NEW);
for II=1:SA
    if(~isempty(TABULA_NEW{II,3}))
        if(S(II))
            petizione2.H(II)=NewVal;
            TABULA_NEW{II,3} = NewVal;
        end
    end
end
set(handles.Petizione2,'userdata',petizione2);
set(handles.TABULA_NEW,'data',TABULA_NEW);
UpdatePlots(handles)

% --- Executes on button press in Chicane_Apply.
function Chicane_Apply_Callback(hObject, eventdata, handles)
TABULA_NEW=get(handles.TABULA_NEW,'data');
S=get(handles.S,'data');
petizione2=get(handles.Petizione2,'userdata');
NewVal=str2num(get(handles.Chicane_Delay,'string'));
for II=1:length(S)
    if(handles.UL.slot(II).BEND.present)
        if(S(II))
            petizione2.D(II)=NewVal;
            Relative=get(handles.RelTrims,'value');
            handles.UL.slot(II).BEND.f.set_Delay(handles.UL.slot(II).BEND,handles.UL,NewVal,Relative);
            TABULA_NEW{II,5} = NewVal;
        end
    end
end
set(handles.Petizione2,'userdata',petizione2);
set(handles.TABULA_NEW,'data',TABULA_NEW);
UpdatePlots(handles)

% --- Executes on button press in PhaseShiter_Apply.
function PhaseShiter_Apply_Callback(hObject, eventdata, handles)
TABULA_NEW=get(handles.TABULA_NEW,'data');
S=get(handles.S,'data');
NewVal=str2num(get(handles.PS_1,'string'));
for II=1:length(S)
    if(S(II))
        if(handles.UL.slot(II).PHAS.present)
            handles.UL.slot(II).PHAS.f.Set_Phase(handles.UL.slot(II).PHAS,NewVal);
            TABULA_NEW{II,4}=NewVal;
        end
    end
end
set(handles.TABULA_NEW,'data',TABULA_NEW);
handles.UL.f.Set_phase_shifters(handles.UL); % Reads destination and re-calculates phase shifters.

petizione1=get(handles.Petizione1,'userdata');
petizione1.UpdateReadout=1;
set(handles.Petizione1,'userdata',petizione1);
UpdateReadBacks(handles,0,0);


%Call update phase shifter functions, a whole line function.

%Set_Phase(PHAS,phase)
% TABULA_NEW=get(handles.TABULA_NEW,'data');
% petizione2=get(handles.Petizione2,'userdata');
% %TABULA=get(handles.TABULA,'data');
% S=get(handles.S,'data');
% NewVal=str2num(get(handles.PS_1,'string'));
% [SA,SB]=size(TABULA_NEW);
% for II=1:SA
%     if(~isempty(TABULA_NEW{II,1}))
%         if(S(II))
%             petizione2.PS(II)=NewVal;
%             TABULA_NEW{II,1} = NewVal;
%         end
%     end
% end
% set(handles.Petizione2,'userdata',petizione2);
% set(handles.TABULA_NEW,'data',TABULA_NEW);
% UpdatePlots(handles)


% --- Executes on slider movement.
function UpdateSlider_Callback(hObject, eventdata, handles)
VAL=get(handles.UpdateSlider,'value');
VAL=round(VAL*10);
petizione1=get(handles.Petizione1,'userdata');
switch VAL
    case 0
        set(handles.text25,'string','Update speed: Never')
        petizione1.UpdateReadOutSpeed=13051917;
    case 1 
        set(handles.text25,'string','Update speed: 1/4 x')
        petizione1.UpdateReadOutSpeed=120;
    case 2
        set(handles.text25,'string','Update speed: 1/2 x')
        petizione1.UpdateReadOutSpeed=60;
    case 3
        set(handles.text25,'string','Update speed: 3/5 x')
        petizione1.UpdateReadOutSpeed=50;
    case 4
        set(handles.text25,'string','Update speed: 3/4 x')
        petizione1.UpdateReadOutSpeed=40;
    case 5
        set(handles.text25,'string','Update speed: Normal')
        petizione1.UpdateReadOutSpeed=30;
    case 6
        set(handles.text25,'string','Update speed: 3/2 x')
        petizione1.UpdateReadOutSpeed=20;
    case 7
        set(handles.text25,'string','Update speed: 2 x')
        petizione1.UpdateReadOutSpeed=20;
    case 8
        set(handles.text25,'string','Update speed: 3 x')
        petizione1.UpdateReadOutSpeed=10;
    case 9
        set(handles.text25,'string','Update speed: 30/7 x')
        petizione1.UpdateReadOutSpeed=7;
    case 10
        set(handles.text25,'string','Update speed: 6x')
        petizione1.UpdateReadOutSpeed=5;
end
set(handles.Petizione1,'userdata',petizione1);

% --- Executes during object creation, after setting all properties.
function UpdateSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UpdateSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function UpdatePlots(handles)
MainAxisMarkers=get(handles.MainAxisMarkers,'userdata');
Plot=get(handles.MainAxis,'userdata');
petizione2=get(handles.Petizione2,'userdata');
if(Plot.ULID == handles.Beamline)
    if(isempty(MainAxisMarkers))
        MainAxisMarkers.FunctionList(1)=handles.MyUniqueIdentifier;
        MainAxisMarkers.ToBeDeleted{1}=[];
        set(handles.MainAxisMarkers,'userdata',MainAxisMarkers);
        ID=1;
    else
       ID=find(MainAxisMarkers.FunctionList==handles.MyUniqueIdentifier,1,'first'); 
       if(isempty(ID))
           ID = length(MainAxisMarkers.FunctionList) + 1 ;
           MainAxisMarkers.FunctionList(ID)=handles.MyUniqueIdentifier;
           MainAxisMarkers.ToBeDeleted{ID}=[];
           set(handles.MainAxisMarkers,'userdata',MainAxisMarkers);
       else

       end
    end
    if(~isempty(MainAxisMarkers.ToBeDeleted{ID}))
        try
            delete(MainAxisMarkers.ToBeDeleted{ID});
        end
        MainAxisMarkers.ToBeDeleted{ID}=[];
    end
    
    %for TT=1:length(handles.UL(handles.Beamline).slot)
    for TT=1:length(handles.UL.slot)
        if(petizione2.S(TT))
            MainAxisMarkers.ToBeDeleted{ID}(end+1) = plot(handles.MainAxis,[Plot.z_in_end(TT,1),Plot.z_in_end(TT,2)],[petizione2.K(TT),petizione2.Kend(TT)],petizione2.sty1,'markersize',10);
        else
            MainAxisMarkers.ToBeDeleted{ID}(end+1) = plot(handles.MainAxis,[Plot.z_in_end(TT,1),Plot.z_in_end(TT,2)],[petizione2.K(TT),petizione2.Kend(TT)],petizione2.sty2);
        end
    end
    set(handles.MainAxisMarkers,'userdata',MainAxisMarkers);
end

ADP=get(handles.OtherAxis,'userdata');
if(~isempty(ADP))
    for II=1:numel(ADP.Plots)
        if(ishandle(ADP.Plots(II)))
            MyPlotData=get(ADP.PlotTags(II).tags.MainPlotAxis,'userdata');
            if(MyPlotData.ULID == handles.Beamline)
                ThisAxisMarkers = get(ADP.PlotTags(II).tags.ADD_Markers,'userdata');
                if(isempty(ThisAxisMarkers))
                    ThisAxisMarkers.FunctionList(1)=handles.MyUniqueIdentifier;
                    ThisAxisMarkers.ToBeDeleted{1}=[];
                    set(ADP.PlotTags(II).tags.ADD_Markers,'userdata',ThisAxisMarkers);
                    ID=1;
                else
                    ID=find(ThisAxisMarkers.FunctionList==handles.MyUniqueIdentifier,1,'first');
                    if(isempty(ID))
                        ID = length(ThisAxisMarkers.FunctionList) + 1 ;
                        ThisAxisMarkers.FunctionList(ID)=handles.MyUniqueIdentifier;
                        ThisAxisMarkers.ToBeDeleted{ID}=[];
                        set(ADP.PlotTags(II).tags.ADD_Markers,'userdata',ThisAxisMarkers);
                    else
                        
                    end
                end
                if(~isempty(ThisAxisMarkers.ToBeDeleted{ID}))
                    try
                        delete(ThisAxisMarkers.ToBeDeleted{ID});
                    end
                    ThisAxisMarkers.ToBeDeleted{ID}=[];
                end

                %for TT=1:length(handles.UL(handles.Beamline).slot)
                for TT=1:length(handles.UL.slot)
                    if(petizione2.S(TT))
                        ThisAxisMarkers.ToBeDeleted{ID}(end+1) = plot(ADP.PlotTags(II).tags.MainPlotAxis,[Plot.z_in_end(TT,1),Plot.z_in_end(TT,2)],[petizione2.K(TT),petizione2.Kend(TT)],petizione2.sty1,'markersize',10);
                    else
                        ThisAxisMarkers.ToBeDeleted{ID}(end+1) = plot(ADP.PlotTags(II).tags.MainPlotAxis,[Plot.z_in_end(TT,1),Plot.z_in_end(TT,2)],[petizione2.K(TT),petizione2.Kend(TT)],petizione2.sty2);
                    end
                end
                set(ADP.PlotTags(II).tags.ADD_Markers,'userdata',ThisAxisMarkers);
            end
        end
    end
end


function UpdateReadBacks(handles,AndCopy,AndInit)
ULData=get(handles.MostRecentKData,'userdata');

if(AndInit)
    TABLE{handles.UL.slotlength,6}=[];
    petizione2=get(handles.Petizione2,'userdata');
    petizione2.S=false(handles.UL.slotlength,1);
    petizione2.K=zeros(handles.UL.slotlength,1);
    petizione2.Kend=zeros(handles.UL.slotlength,1);
    petizione2.H=ones(handles.UL.slotlength,1);
    petizione2.D=zeros(handles.UL.slotlength,1);
    petizione2.PS=zeros(handles.UL.slotlength,1);
else
    TABLE=get(handles.TABULA,'data');
end
for AK=1:handles.UL.slotlength
    if(handles.UL.slot(AK).PHAS.present)
        TABLE{AK,4} = ULData(AK).Phase;
        if(AndInit)
            petizione2.PS(AK) = ULData(AK).Phase;
        end
    end
    if(handles.UL.slot(AK).USEG.present)
        if(AndInit)
            TABLE{AK,3}=petizione2.H(AK);
        end
        Harm=TABLE{AK,3};
        if(numel(ULData(AK).K) <= Harm) %Harmonic is low enough to find a K 
            TABLE{AK,1} = ULData(AK).K(Harm);
            TABLE{AK,2} = ULData(AK).Kend(Harm);
            TABLE{AK,3} = 1;
            if(AndInit)
                petizione2.K(AK) = ULData(AK).K(Harm);
                petizione2.Kend(AK) = ULData(AK).Kend(Harm);
                petizione2.H(AK) = ULData(AK).Kend(Harm);
            end
        else %Harmonic set not good. what do we do? Set it back to 1?
            TABLE{AK,1} = ULData(AK).K(1);
            TABLE{AK,2} = ULData(AK).Kend(1);
            TABLE{AK,3} = 1;
            if(AndInit)
                petizione2.K(AK) = ULData(AK).K(1);
                petizione2.Kend(AK) = ULData(AK).Kend(1);
                petizione2.H(AK) = 1;
            end
        end
        TABLE{AK,6} = ULData(AK).StateString;
    end
    if(handles.UL.slot(AK).BEND.present)
        TABLE{AK,5} = ULData(AK).Delay;
        if(AndInit)
                petizione2.D(AK) = ULData(AK).Delay;
        end
    end
    
end
set(handles.TABULA,'data',TABLE);
if(AndCopy)
    set(handles.TABULA_NEW,'data',TABLE);
end
if(AndInit)
   set(handles.Petizione2,'userdata',petizione2);
end

% --- Executes on button press in ForceUpdate.
function ForceUpdate_Callback(hObject, eventdata, handles)
petizione1=get(handles.Petizione1,'userdata');
petizione1.UpdateReadout=1;
set(handles.Petizione1,'userdata',petizione1);
UpdateReadBacks(handles,0,0);


% --- Executes when entered data in editable cell(s) in S.
function S_CellEditCallback(hObject, eventdata, handles)
petizione2=get(handles.Petizione2,'userdata');
if(eventdata.NewData)
    petizione2.S(eventdata.Indices(1))=true;
else
    petizione2.S(eventdata.Indices(1))=false;
end
set(handles.Petizione2,'userdata',petizione2);
UpdatePlots(handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
MainAxisMarkers=get(handles.MainAxisMarkers,'userdata');
Plot=get(handles.MainAxis,'userdata');
if(Plot.ULID == handles.Beamline)
    if(isempty(MainAxisMarkers))
        MainAxisMarkers.FunctionList(1)=handles.MyUniqueIdentifier;
        MainAxisMarkers.ToBeDeleted{1}=[];
        set(handles.MainAxisMarkers,'userdata',MainAxisMarkers);
        ID=1;
    else
       ID=find(MainAxisMarkers.FunctionList==handles.MyUniqueIdentifier,1,'first'); 
       if(isempty(ID))
           ID = length(MainAxisMarkers.FunctionList) + 1 ;
           MainAxisMarkers.FunctionList(ID)=handles.MyUniqueIdentifier;
           MainAxisMarkers.ToBeDeleted{ID}=[];
           set(handles.MainAxisMarkers,'userdata',MainAxisMarkers);
       else

       end
    end
    if(~isempty(MainAxisMarkers.ToBeDeleted{ID}))
        delete(MainAxisMarkers.ToBeDeleted{ID});
        MainAxisMarkers.ToBeDeleted{ID}=[];
    end
    set(handles.MainAxisMarkers,'userdata',MainAxisMarkers);
end
end
try
ADP=get(handles.OtherAxis,'userdata');
if(~isempty(ADP))
    for II=1:numel(ADP.Plots)
        if(ishandle(ADP.Plots(II)))
            MyPlotData=get(ADP.PlotTags(II).tags.MainPlotAxis,'userdata');
            if(MyPlotData.ULID == handles.Beamline)
                ThisAxisMarkers = get(ADP.PlotTags(II).tags.ADD_Markers,'userdata');
                if(isempty(ThisAxisMarkers))
                    ThisAxisMarkers.FunctionList(1)=handles.MyUniqueIdentifier;
                    ThisAxisMarkers.ToBeDeleted{1}=[];
                    set(ADP.PlotTags(II).tags.ADD_Markers,'userdata',ThisAxisMarkers);
                    ID=1;
                else
                    ID=find(ThisAxisMarkers.FunctionList==handles.MyUniqueIdentifier,1,'first');
                    if(isempty(ID))
                        ID = length(ThisAxisMarkers.FunctionList) + 1 ;
                        ThisAxisMarkers.FunctionList(ID)=handles.MyUniqueIdentifier;
                        ThisAxisMarkers.ToBeDeleted{ID}=[];
                        set(ADP.PlotTags(II).tags.ADD_Markers,'userdata',ThisAxisMarkers);
                    else
                        
                    end
                end
                if(~isempty(ThisAxisMarkers.ToBeDeleted{ID}))
                    delete(ThisAxisMarkers.ToBeDeleted{ID});
                    ThisAxisMarkers.ToBeDeleted{ID}=[];
                end
                set(ADP.PlotTags(II).tags.ADD_Markers,'userdata',ThisAxisMarkers);
            end
        end
    end
end
end
delete(hObject);


% --- Executes on button press in TS_ContTaper.
function TS_ContTaper_Callback(hObject, eventdata, handles)
% hObject    handle to TS_ContTaper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TS_ContTaper


% --- Executes on button press in MoveIN.
function MoveIN_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
RAW=get(handles.RGS,'value');
handles.UL.f.MoveInSegments(handles.UL, find(S),RAW);


% --- Executes on button press in MoveOUT.
function MoveOUT_Callback(hObject, eventdata, handles)
S=get(handles.S,'data');
RAW=get(handles.RGS,'value');
handles.UL.f.MoveOutSegments(handles.UL, find(S),RAW);


% --------------------------------------------------------------------
function TABULA_NEW_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to TABULA_NEW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function MTC_NUM_Callback(hObject, eventdata, handles)
% hObject    handle to MTC_NUM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MTC_NUM as text
%        str2double(get(hObject,'String')) returns contents of MTC_NUM as a double


% --- Executes during object creation, after setting all properties.
function MTC_NUM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MTC_NUM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MTC_KScramble.
function MTC_KScramble_Callback(hObject, eventdata, handles)
UD=get(handles.MTC_UD,'value');
ND=get(handles.MTC_ND,'value');
AM=str2num(get(handles.MTC_NUM,'string'));

TABULA_NEW=get(handles.TABULA_NEW,'data');
S=get(handles.S,'data');
petizione2=get(handles.Petizione2,'userdata');

SA=size(TABULA_NEW,1);

for II=1:SA
    if(S(II))
        if(TABULA_NEW{II,3}) % se ha harmonic number
            Scramble=0;
            if(UD)
                Scramble=Scramble+(rand(1)-0.5)*2*AM;
            end
            if(ND)
                Scramble=Scramble+(randn(1))*AM;
            end
            
            NewValueStart = TABULA_NEW{II,1} + Scramble;
            GapStart=handles.UL.slot(II).USEG.f.K_to_gap(handles.UL.slot(II).USEG,NewValueStart);
            if(GapStart<(handles.UL.slot(II).USEG.GapMin+0.1))
                NewValueStart = TABULA_NEW{II,1} - Scramble;
                GapStart=handles.UL.slot(II).USEG.f.K_to_gap(handles.UL.slot(II).USEG,NewValueStart);
                if(GapStart<(handles.UL.slot(II).USEG.GapMin+0.1))
                    GapStart=handles.UL.slot(II).USEG.GapMin+0.1+rand(1)*2;
                    NewValueStart=handles.UL.slot(II).USEG.f.gap_to_K(handles.UL.slot(II).USEG,GapStart);
                end
            end
            TABULA_NEW{II,1}=NewValueStart;
            DeltaGap=0.175+rand(1)*0.075;
            
            Signum=sign(rand(1)-0.5);
            
            GapEnd=GapStart+Signum*DeltaGap;
            if(GapEnd<(handles.UL.slot(II).USEG.GapMin+0.1))
                GapEnd=GapStart-Signum*DeltaGap;
            end
            NewValueEnd=handles.UL.slot(II).USEG.f.gap_to_K(handles.UL.slot(II).USEG,GapEnd);
            TABULA_NEW{II,2} = NewValueEnd;
            
            petizione2.K(II) = TABULA_NEW{II,1};
            petizione2.Kend(II) =TABULA_NEW{II,2};

        end
    end
end

set(handles.Petizione2,'userdata',petizione2);
set(handles.TABULA_NEW,'data',TABULA_NEW);
petizione1=get(handles.Petizione1,'userdata');
petizione1.PlotNow=1;
set(handles.Petizione1,'userdata',petizione1);
UpdatePlots(handles)




% --- Executes on button press in MTC_UD.
function MTC_UD_Callback(hObject, eventdata, handles)
% hObject    handle to MTC_UD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MTC_UD


% --- Executes on button press in MTC_ND.
function MTC_ND_Callback(hObject, eventdata, handles)
% hObject    handle to MTC_ND (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MTC_ND


% --- Executes on button press in RGS.
function RGS_Callback(hObject, eventdata, handles)
% hObject    handle to RGS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RGS


% --- Executes on button press in RelTrims.
function RelTrims_Callback(hObject, eventdata, handles)
% hObject    handle to RelTrims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RelTrims
