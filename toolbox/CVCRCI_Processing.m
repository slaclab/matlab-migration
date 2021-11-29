function varargout = CVCRCI_Processing(varargin)
% CVCRCI_PROCESSING MATLAB code for CVCRCI_Processing.fig
%      CVCRCI_PROCESSING, by itself, creates a new CVCRCI_PROCESSING or raises the existing
%      singleton*.
%
%      H = CVCRCI_PROCESSING returns the handle to a new CVCRCI_PROCESSING or the handle to
%      the existing singleton*.
%
%      CVCRCI_PROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI_PROCESSING.M with the given input arguments.
%
%      CVCRCI_PROCESSING('Property','Value',...) creates a new CVCRCI_PROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI_Processing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI_Processing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI_Processing

% Last Modified by GUIDE v2.5 18-Apr-2015 16:03:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI_Processing_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI_Processing_OutputFcn, ...
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


% --- Executes just before CVCRCI_Processing is made visible.
function CVCRCI_Processing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI_Processing (see VARARGIN)

% Choose default command line output for CVCRCI_Processing
handles.output = hObject;
handles.NumberOfTemporaryVariables=30;
handles.ColorWait=[1,1,0];
handles.ColorOn=[0,1,0];
handles.ColorIdle=get(handles.ADDTHISFILTER,'backgroundcolor');
handles.OutputPVNames={'SIOC:SYS0:ML02:AO314','SIOC:SYS0:ML02:AO315','SIOC:SYS0:ML02:AO316','SIOC:SYS0:ML02:AO317','SIOC:SYS0:ML02:AO318','SIOC:SYS0:ML02:AO319','SIOC:SYS0:ML02:AO320'};
for II=1:handles.NumberOfTemporaryVariables
    defaultdata{II,1}=['##',num2str(II)];
    defaultdata{II,2}=0;   
    defaultcn{II}=['@',num2str(II)];
end
set(handles.uitable4,'rowname',defaultcn);
handles.PosizioneStrutturaDati=varargin{1};
handles.PosizioneFunzioniEVariabili=varargin{2};
defaultdata{1,2}=100;
set(handles.QuickVariables,'data',defaultdata);
set(handles.CurrentCode,'string',{'CodeResult=1;'})

CVCRCI2_ProcessingOpeningFunction;

handles.QuickFilter=QuickFilter;
handles.QuickScalar=QuickScalar;
handles.QuickOutput=QuickOutput;

StrutturaCodice=get(handles.PosizioneFunzioniEVariabili,'userdata');
datifiltri={}; datifiltrihidden=[];
for II=1:StrutturaCodice.NumeroFiltri
    datifiltri{II,1}=StrutturaCodice.Filtri(1).name;
    datifiltri{II,2}=true;
    datifiltrihidden(II).type=StrutturaCodice.Filtri(1).type;
    datifiltrihidden(II).code=StrutturaCodice.Filtri(1).code;
end
set(handles.uitable3,'data',datifiltri)
set(handles.uitable3,'userdata',datifiltrihidden)
datioutput={}; datioutputhidden=[];
for II=1:StrutturaCodice.NumeroOutput
    datioutput{II,1}=StrutturaCodice.Filtri(1).Output;
    datioutput{II,2}=true;
    datioutputhidden(II).type=StrutturaCodice.Output(1).type;
    datioutputhidden(II).code=StrutturaCodice.Output(1).code;  
    set(handles.(['SO',num2str(II)]),'value',1);
end

for II=1:7
    set(handles.(['PVN',num2str(II)]),'string',handles.OutputPVNames{II});
end

set(handles.uitable4,'data',datioutput);
rn={};
    for numberofrows=1:numel(datioutputhidden);
       rn{end+1}=['##',num2str(numberofrows)];
    end
set(handles.uitable4,'RowName',rn)
set(handles.uitable4,'userdata',datioutputhidden);
datiscalari={}; datiscalariputhidden=[];
for II=1:StrutturaCodice.NumeroScalari
    datiscalari{II,1}=StrutturaCodice.Filtri(1).Scalari;
    datiscalari{II,2}=true;
    datiscalariputhidden(II).type=StrutturaCodice.Scalari(1).type;
    datiscalariputhidden(II).code=StrutturaCodice.Scalari(1).code;
end
set(handles.uitable5,'data',datiscalari)
set(handles.uitable5,'userdata',datiscalariputhidden)
N1_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);
MCE_Callback(hObject, eventdata, handles);set(handles.MCE,'Userdata',0);set(handles.MCE,'backgroundcolor',[.7,.7,.7]);
% UIWAIT makes CVCRCI_Processing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI_Processing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F1.
function F1_Callback(hObject, eventdata, handles)
% hObject    handle to F1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F2.
function F2_Callback(hObject, eventdata, handles)
% hObject    handle to F2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F3.
function F3_Callback(hObject, eventdata, handles)
% hObject    handle to F3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F4.
function F4_Callback(hObject, eventdata, handles)
% hObject    handle to F4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in N1.
function N1_Callback(hObject, eventdata, handles)
set(handles.uipanel7,'visible','off');set(handles.N2,'backgroundcolor',handles.ColorIdle);
set(handles.uipanel8,'visible','off');set(handles.N3,'backgroundcolor',handles.ColorIdle);
set(handles.uipanel6,'visible','on');set(handles.N1,'backgroundcolor',handles.ColorOn);
QuickFilterCode_Callback(hObject, eventdata, handles);

% --- Executes on button press in N2.
function N2_Callback(hObject, eventdata, handles)
set(handles.uipanel8,'visible','off');set(handles.N1,'backgroundcolor',handles.ColorIdle);
set(handles.uipanel6,'visible','off');set(handles.N3,'backgroundcolor',handles.ColorIdle);
set(handles.uipanel7,'visible','on');set(handles.N2,'backgroundcolor',handles.ColorOn);
QuickSynchScalarCode_Callback(hObject, eventdata, handles);


% --- Executes on button press in N3.
function N3_Callback(hObject, eventdata, handles)
set(handles.uipanel6,'visible','off');set(handles.N1,'backgroundcolor',handles.ColorIdle);
set(handles.uipanel7,'visible','off');set(handles.N2,'backgroundcolor',handles.ColorIdle);
set(handles.uipanel8,'visible','on');set(handles.N3,'backgroundcolor',handles.ColorOn);
QuickOutputBan_Callback(hObject, eventdata, handles);

% --- Executes on selection change in M1.
function M1_Callback(hObject, eventdata, handles)
% hObject    handle to M1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns M1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from M1


% --- Executes during object creation, after setting all properties.
function M1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox5.
function listbox5_Callback(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox5


% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F8.
function F8_Callback(hObject, eventdata, handles)
% hObject    handle to F8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F9.
function F9_Callback(hObject, eventdata, handles)
% hObject    handle to F9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F10.
function F10_Callback(hObject, eventdata, handles)
% hObject    handle to F10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F0.
function F0_Callback(hObject, eventdata, handles)
% hObject    handle to F0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F6.
function F6_Callback(hObject, eventdata, handles)
% hObject    handle to F6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F7.
function F7_Callback(hObject, eventdata, handles)
% hObject    handle to F7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in F5.
function F5_Callback(hObject, eventdata, handles)
% hObject    handle to F5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in faston1.
function faston1_Callback(hObject, eventdata, handles)
% hObject    handle to faston1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston1


% --- Executes on button press in faston2.
function faston2_Callback(hObject, eventdata, handles)
% hObject    handle to faston2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston2


% --- Executes on button press in faston3.
function faston3_Callback(hObject, eventdata, handles)
% hObject    handle to faston3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston3


% --- Executes on button press in faston4.
function faston4_Callback(hObject, eventdata, handles)
% hObject    handle to faston4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston4


% --- Executes on button press in faston5.
function faston5_Callback(hObject, eventdata, handles)
% hObject    handle to faston5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston5


% --- Executes on button press in faston6.
function faston6_Callback(hObject, eventdata, handles)
% hObject    handle to faston6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston6


% --- Executes on button press in faston7.
function faston7_Callback(hObject, eventdata, handles)
% hObject    handle to faston7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of faston7


% --- Executes on selection change in OF11.
function OF11_Callback(hObject, eventdata, handles)
% hObject    handle to OF11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF11


% --- Executes during object creation, after setting all properties.
function OF11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF21.
function OF21_Callback(hObject, eventdata, handles)
% hObject    handle to OF21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF21 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF21


% --- Executes during object creation, after setting all properties.
function OF21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF31.
function OF31_Callback(hObject, eventdata, handles)
% hObject    handle to OF31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF31 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF31


% --- Executes during object creation, after setting all properties.
function OF31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF41.
function OF41_Callback(hObject, eventdata, handles)
% hObject    handle to OF41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF41 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF41


% --- Executes during object creation, after setting all properties.
function OF41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF51.
function OF51_Callback(hObject, eventdata, handles)
% hObject    handle to OF51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF51 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF51


% --- Executes during object creation, after setting all properties.
function OF51_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF61.
function OF61_Callback(hObject, eventdata, handles)
% hObject    handle to OF61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF61 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF61


% --- Executes during object creation, after setting all properties.
function OF61_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF71.
function OF71_Callback(hObject, eventdata, handles)
% hObject    handle to OF71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF71 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF71


% --- Executes during object creation, after setting all properties.
function OF71_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF12.
function OF12_Callback(hObject, eventdata, handles)
% hObject    handle to OF12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF12


% --- Executes during object creation, after setting all properties.
function OF12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF22.
function OF22_Callback(hObject, eventdata, handles)
% hObject    handle to OF22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF22 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF22


% --- Executes during object creation, after setting all properties.
function OF22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF32.
function OF32_Callback(hObject, eventdata, handles)
% hObject    handle to OF32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF32 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF32


% --- Executes during object creation, after setting all properties.
function OF32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF42.
function OF42_Callback(hObject, eventdata, handles)
% hObject    handle to OF42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF42 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF42


% --- Executes during object creation, after setting all properties.
function OF42_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF52.
function OF52_Callback(hObject, eventdata, handles)
% hObject    handle to OF52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF52 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF52


% --- Executes during object creation, after setting all properties.
function OF52_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF62.
function OF62_Callback(hObject, eventdata, handles)
% hObject    handle to OF62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF62 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF62


% --- Executes during object creation, after setting all properties.
function OF62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OF72.
function OF72_Callback(hObject, eventdata, handles)
% hObject    handle to OF72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OF72 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OF72


% --- Executes during object creation, after setting all properties.
function OF72_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OF72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO1.
function SO1_Callback(hObject, eventdata, handles)
% hObject    handle to SO1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO1


% --- Executes during object creation, after setting all properties.
function SO1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO2.
function SO2_Callback(hObject, eventdata, handles)
% hObject    handle to SO2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO2


% --- Executes during object creation, after setting all properties.
function SO2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO3.
function SO3_Callback(hObject, eventdata, handles)
% hObject    handle to SO3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO3


% --- Executes during object creation, after setting all properties.
function SO3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO4.
function SO4_Callback(hObject, eventdata, handles)
% hObject    handle to SO4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO4


% --- Executes during object creation, after setting all properties.
function SO4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO5.
function SO5_Callback(hObject, eventdata, handles)
% hObject    handle to SO5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO5


% --- Executes during object creation, after setting all properties.
function SO5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO6.
function SO6_Callback(hObject, eventdata, handles)
% hObject    handle to SO6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO6


% --- Executes during object creation, after setting all properties.
function SO6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SO7.
function SO7_Callback(hObject, eventdata, handles)
% hObject    handle to SO7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SO7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SO7


% --- Executes during object creation, after setting all properties.
function SO7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SO7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MCE.
function MCE_Callback(hObject, eventdata, handles)
QVT=get(handles.QuickVariables,'data');
QVTUD=get(handles.QuickVariables,'userdata');

FVT=get(handles.uitable3,'data');
FVTUD=get(handles.uitable3,'userdata');

SVT=get(handles.uitable4,'data');
SVTUD=get(handles.uitable4,'userdata');

OVT=get(handles.uitable5,'data');
OVTUD=get(handles.uitable5,'userdata');
MCE_VAL=struct();
%save temp
if(isempty(FVT))
    MCE_VAL.NumeroFiltri=0;
else
   INSERTED=0;
   for TT=1:(numel(FVT)/2)
       if(FVT{TT,2})
           INSERTED=INSERTED+1;
           MCE_VAL.Filtri(INSERTED).nome = FVT{TT,1};
           MCE_VAL.Filtri(INSERTED).type = FVTUD(TT).type;
           MCE_VAL.Filtri(INSERTED).code = FVTUD(TT).code;
           MCE_VAL.Filtri(INSERTED).S = FVTUD(TT).S;
           MCE_VAL.Filtri(INSERTED).CodeLines = numel(FVTUD(TT).code);
       end
   end
   MCE_VAL.NumeroFiltri=INSERTED;
end

if(isempty(SVT))
    MCE_VAL.NumeroScalari=0;
else
   INSERTED=0;
   for TT=1:(numel(SVT)/2)
       if(SVT{TT,2})
           if(SVTUD(TT).outs>1)
               INSERTED=INSERTED+1;
               MCE_VAL.Scalari(INSERTED).nome{1} = SVT{TT,1};
               MCE_VAL.Scalari(INSERTED).type = SVTUD(TT).type;
               MCE_VAL.Scalari(INSERTED).code = SVTUD(TT).code;
               MCE_VAL.Scalari(INSERTED).CodeLines = numel(SVTUD(TT).code);
               MCE_VAL.Scalari(INSERTED).outs=SVTUD(TT).outs;
               MCE_VAL.Scalari(INSERTED).S = SVTUD(TT).S;
               for SS=2:SVTUD(TT).outs
                   SVT{TT+(SS-1),2}=false; %in questo modo non si mettono doppioni
                   MCE_VAL.Scalari(INSERTED).nome{SS}=SVT{TT+(SS-1),1};
               end
           else % a single scalar is calculated in a single call... 
               INSERTED=INSERTED+1;
               MCE_VAL.Scalari(INSERTED).nome = SVT{TT,1};
               MCE_VAL.Scalari(INSERTED).type = SVTUD(TT).type;
               MCE_VAL.Scalari(INSERTED).code = SVTUD(TT).code;
               MCE_VAL.Scalari(INSERTED).CodeLines = numel(SVTUD(TT).code);
               MCE_VAL.Scalari(INSERTED).outs=1;
               MCE_VAL.Scalari(INSERTED).S = SVTUD(TT).S;
           end
       end
   end
   MCE_VAL.NumeroScalari=INSERTED; % E' davvero il numero delle funzioni scalari da chiamare, non il numero degli scalari
end

if(isempty(OVT))
    MCE_VAL.NumeroOutput=0;
else
   INSERTED=0;
   for TT=1:(numel(OVT)/2)
       if(OVT{TT,2})
           INSERTED=INSERTED+1;
           MCE_VAL.Output(INSERTED).nome = OVT{TT,1};
           MCE_VAL.Output(INSERTED).type = OVTUD(TT).type;
           MCE_VAL.Output(INSERTED).code = OVTUD(TT).code;
           MCE_VAL.Output(INSERTED).CodeLines = numel(OVTUD(TT).code);
           MCE_VAL.Output(INSERTED).S = OVTUD(TT).S;
       end
   end
   MCE_VAL.NumeroOutput=INSERTED;
end

MCE_VAL.QuickVariables=[QVT{:,2}];

AllFilterNames={'Filter OFF'};
if(MCE_VAL.NumeroFiltri)
    for TT=1:numel(MCE_VAL.Filtri)
       AllFilterNames{end+1}= MCE_VAL.Filtri(TT).nome;
    end
end
if(MCE_VAL.NumeroOutput)
    NOUT=0;
    AllOutputNames={MCE_VAL.Output(:).nome};
else
    NOUT=1;
    AllOutputNames={'No Output'};
end

for II=1:7
    CV1=get(handles.(['OF',num2str(II),'1']),'value');
    if(CV1>numel(AllFilterNames))
        set(handles.(['OF',num2str(II),'1']),'value',1);
    end
    CV2=get(handles.(['OF',num2str(II),'2']),'value');
    if(CV2>numel(AllFilterNames))
        set(handles.(['OF',num2str(II),'2']),'value',1);
    end
    set(handles.(['OF',num2str(II),'1']),'string',AllFilterNames);
    set(handles.(['OF',num2str(II),'2']),'string',AllFilterNames);
    set(handles.(['SO',num2str(II)]),'string',AllOutputNames);
    if(NOUT)
        set(handles.(['faston',num2str(II)]),'value',0);
        set(handles.(['faston',num2str(II)]),'enable','off');
    else
        set(handles.(['faston',num2str(II)]),'enable','on');
    end
end

for II=1:7
    MCE_OUT.OutAttivi(II)=get(handles.(['faston',num2str(II)]),'value');
    MCE_OUT.OutFilter1(II) = get(handles.(['OF',num2str(II),'1']),'value');
    MCE_OUT.OutFilter2(II) = get(handles.(['OF',num2str(II),'2']),'value');
    MCE_OUT.OutFunction(II)= get(handles.(['SO',num2str(II)]),'value');
    MCE_OUT.OutString(II)= handles.(['o',num2str(II)]);
end

set(handles.MCE,'backgroundcolor',handles.ColorWait);
set(handles.MCE,'Userdata',1);
set(handles.MCE_VALS,'Userdata',MCE_VAL);
set(handles.MCE_OUT,'Userdata',MCE_OUT);

drawnow

% --- Executes on selection change in QuickSynchScalarCode.
function QuickSynchScalarCode_Callback(hObject, eventdata, handles)
CurrentType=get(handles.QuickSynchScalarCode,'value');
MyOptions=handles.QuickScalar;
if(MyOptions.VectorAvailable(CurrentType) || MyOptions.ImageAvailable(CurrentType))
   set(handles.scalarontext,'visible','on'); 
   set(handles.SCALARQUANTITY,'visible','on');
   ISFILLED=get(handles.SCALARQUANTITY,'userdata');
   if(ISFILLED)
    set(handles.ADDTHISSCALAR,'enable','on');
   else
    set(handles.ADDTHISSCALAR,'enable','off');
   end
else
   set(handles.scalarontext,'visible','off');
   set(handles.SCALARQUANTITY,'visible','off');
   set(handles.ADDTHISSCALAR,'enable','on');
end
set(handles.QuickScalarOptions,'value',1);
set(handles.QuickScalarOptions,'string', MyOptions.Subtypes(CurrentType).names);
QuickScalarOptions_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function QuickSynchScalarCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuickSynchScalarCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in QuickFilterCode.
function QuickFilterCode_Callback(hObject, eventdata, handles)
CurrentType=get(handles.QuickFilterCode,'value');
MyOptions=handles.QuickFilter;
if(MyOptions.ScalarAvailable(CurrentType))
   set(handles.filterontext,'visible','on'); 
   set(handles.FILTERQUANTITY,'visible','on');
   ISFILLED=get(handles.FILTERQUANTITY,'userdata');
   if(ISFILLED)
    set(handles.ADDTHISFILTER,'enable','on');
   else
    set(handles.ADDTHISFILTER,'enable','off');
   end
else
   set(handles.filterontext,'visible','off');
   set(handles.FILTERQUANTITY,'visible','off');
   set(handles.ADDTHISFILTER,'enable','on');
end
set(handles.QuickFilterOptions,'value',1);
set(handles.QuickFilterOptions,'string', MyOptions.Subtypes(CurrentType).names);
QuickFilterOptions_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function QuickFilterCode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuickFilterCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in M2.
function M2_Callback(hObject, eventdata, handles)
eventdata=get(handles.M2,'value');
if(~isempty(eventdata))
    if(numel(eventdata)==1)
%         save TEMP
       currentlist=get(handles.M2,'string');
%        eventdata
       Currentvalue=currentlist{eventdata};
       set(handles.FILTERQUANTITY,'string',Currentvalue);
       set(handles.FILTERQUANTITY,'userdata',1);
       set(handles.OUTPUTQUANTITY,'string',Currentvalue);
       set(handles.OUTPUTQUANTITY,'userdata',1);
       StrutturaDati=get(handles.PosizioneStrutturaDati,'userdata');
%        START=regexpi(Currentvalue,'=');
       ScalarsPositions=[StrutturaDati.Number_of_synch_pvs,StrutturaDati.Number_of_scalars_in_a_matrix];
       ScalarsPositionsCumsum=cumsum(ScalarsPositions);
       POS=find(eventdata<=ScalarsPositionsCumsum,1,'last');
       if(POS==1)
           SEL=[2,eventdata,0];
       else
           SEL=[3,POS,eventdata-ScalarsPositionsCumsum(POS-1)]; 
       end
       set(handles.FILTER_SEL,'userdata',SEL);
       set(handles.OUTPUT_SEL,'userdata',SEL);
       QuickFilterCode_Callback(hObject, eventdata, handles);
       QuickOutputBan_Callback(hObject, eventdata, handles);
       return
    end
end
set(handles.FILTERQUANTITY,'userdata',0);
set(handles.FILTERQUANTITY,'string','');
set(handles.OUTPUTQUANTITY,'userdata',0);
set(handles.OUTPUTQUANTITY,'string','');

QuickFilterCode_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function M2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in M3.
function M3_Callback(hObject, eventdata, handles)
disp('M3 CALLED')
CurrentType=get(handles.QuickSynchScalarCode,'value');
MyOptions=handles.QuickScalar
MyOptions.VectorAvailable(CurrentType)
eventdata=get(handles.M3,'value');
if(MyOptions.VectorAvailable(CurrentType))
    if(~isempty(eventdata))
        if(numel(eventdata)==1)
           currentlist=get(handles.M3,'string');
    %        eventdata
           Currentvalue=currentlist{eventdata};
           StrutturaDati=get(handles.PosizioneStrutturaDati,'userdata');
           START=regexpi(Currentvalue,'=');
           CurrentName=Currentvalue((START+2):end)
           POS=find(strcmp(StrutturaDati.Names_of_vectors,CurrentName));
           SEL=[4, StrutturaDati.Position_of_vectors_in_Profiles(POS), 1]; %4 for vector,  % true position is the useful one % used elsewhere don't touch!! 
           if(~isempty(POS))
               set(handles.SCALARQUANTITY,'string',Currentvalue);
               set(handles.SCALARQUANTITY,'userdata',1);
               set(handles.SCALAR_SEL,'userdata',SEL);
               QuickScalarOptions_Callback(hObject, eventdata, handles)
           end
        end
    end
end



% --- Executes during object creation, after setting all properties.
function M3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in M4.
function M4_Callback(hObject, eventdata, handles)
%disp('M4 CALLED')
CurrentType=get(handles.QuickSynchScalarCode,'value');
MyOptions=handles.QuickScalar
MyOptions.ImageAvailable(CurrentType)
eventdata=get(handles.M4,'value');
if(MyOptions.ImageAvailable(CurrentType))
    if(~isempty(eventdata))
        if(numel(eventdata)==1)
           currentlist=get(handles.M4,'string');
    %        eventdata
           Currentvalue=currentlist{eventdata}
           StrutturaDati=get(handles.PosizioneStrutturaDati,'userdata');
           START=regexpi(Currentvalue,'=');
           %save TEMPX
           CurrentName=Currentvalue((START+2):end)
           POS=find(strcmp(StrutturaDati.Names_of_2Darrays,CurrentName));
           SEL=[4, StrutturaDati.Position_of_2Darrays_in_Profiles(POS), 2];
           %SEL=[2, POS, StrutturaDati.Position_of_2Darrays_in_Profiles(POS)]; %2 for image, % POS for future use, % true position is the useful one
           if(~isempty(POS))
               set(handles.SCALARQUANTITY,'string',Currentvalue);
               set(handles.SCALARQUANTITY,'userdata',1);
               set(handles.SCALAR_SEL,'userdata',SEL);
               QuickScalarOptions_Callback(hObject, eventdata, handles)
           end
        end
    end
end


% --- Executes during object creation, after setting all properties.
function M4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in QuickVariables.
function QuickVariables_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to QuickVariables (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column Indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


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

% --- Executes on button press in SaveCode.
function SaveCode_Callback(hObject, eventdata, handles)
% hObject    handle to SaveCode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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


% --- Executes on button press in DimensionalTest.
function DimensionalTest_Callback(hObject, eventdata, handles)
% hObject    handle to DimensionalTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DeleteFilter.
function DeleteFilter_Callback(hObject, eventdata, handles)
ACTIVE=get(handles.DeleteFilter,'userdata');
cf=get(handles.uitable3,'data');
cfh=get(handles.uitable3,'userdata');
if(~isfield(ACTIVE,'Indices'))
    return
end
if(numel(ACTIVE.Indices)~=2)
    return
end
ACTIVEROW=ACTIVE.Indices(1);
if(~ACTIVEROW), return, end
if(numel(cfh)==1) %cancella tutto
        cf={};
        cfh=[];
    elseif(numel(cfh)==ACTIVEROW) %e' l'ultimo
        cf=cf(1:(ACTIVEROW-1),:);
        cfh=cfh(1:(end-1));
    else    
        for TT=ACTIVEROW:(numel(cfh)-1)
           cfh(TT)=cfh(TT+1);
           cf{TT,1}=cf{TT+1,1};
           cf{TT,2}=cf{TT+1,2};
        end
        
        cfh=cfh(1:(end-1));
        cf=reshape({cf{1:(end-1),:}},[numel(cfh),2]);
end
set(handles.uitable3,'data',cf);
set(handles.uitable3,'userdata',cfh);

function FV1_Callback(hObject, eventdata, handles)
% hObject    handle to FV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FV1 as text
%        str2double(get(hObject,'String')) returns contents of FV1 as a double


% --- Executes during object creation, after setting all properties.
function FV1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FV2_Callback(hObject, eventdata, handles)
% hObject    handle to FV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FV2 as text
%        str2double(get(hObject,'String')) returns contents of FV2 as a double


% --- Executes during object creation, after setting all properties.
function FV2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in QuickFilterOptions.
function QuickFilterOptions_Callback(hObject, eventdata, handles)
CurrentType=get(handles.QuickFilterCode,'value');
CurrentSubType=get(handles.QuickFilterOptions,'value');
MyOptions=handles.QuickFilter;
CurrentOptions=MyOptions.Subtypes(CurrentType).Options;
if(~isempty(CurrentOptions))
    if(get(handles.FILTERQUANTITY,'userdata'))
        set(handles.ADDTHISFILTER,'enable','on');
    end
    CurrentMenu=CurrentOptions(CurrentSubType);
    if(numel(CurrentMenu.names)==1)
        set(handles.FV1,'visible','on'); set(handles.FE1,'visible','on');
        set(handles.FE1,'string',CurrentMenu.names{1}); set(handles.FV1,'string',CurrentMenu.Default{1});
       for TT=2:6
           set(handles.(['FV',(num2str(TT))]),'visible','off'); set(handles.(['FE',(num2str(TT))]),'visible','off');
       end
    else
        for TT=1:6
            if(TT>numel(CurrentMenu.names))
                set(handles.(['FV',(num2str(TT))]),'visible','off'); set(handles.(['FE',(num2str(TT))]),'visible','off');
            else
                nome=CurrentMenu.names{TT};
                valore=CurrentMenu.Default{TT};
                set(handles.(['FE',(num2str(TT))]),'string',nome); set(handles.(['FV',(num2str(TT))]),'string',valore);
                set(handles.(['FE',(num2str(TT))]),'visible','on'); set(handles.(['FV',(num2str(TT))]),'visible','on');
            end
        end    
    end
else
    set(handles.ADDTHISFILTER,'enable','off')
    for TT=1:6  
        set(handles.(['FE',(num2str(TT))]),'visible','off'); set(handles.(['FV',(num2str(TT))]),'visible','off');
    end
end

% --- Executes during object creation, after setting all properties.
function QuickFilterOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuickFilterOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable3.
function uitable3_CellSelectionCallback(hObject, eventdata, handles)
set(handles.DeleteFilter,'userdata',eventdata);


function FV3_Callback(hObject, eventdata, handles)
% hObject    handle to FV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FV3 as text
%        str2double(get(hObject,'String')) returns contents of FV3 as a double


% --- Executes during object creation, after setting all properties.
function FV3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FV4_Callback(hObject, eventdata, handles)
% hObject    handle to FV4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FV4 as text
%        str2double(get(hObject,'String')) returns contents of FV4 as a double


% --- Executes during object creation, after setting all properties.
function FV4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FV4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FV5_Callback(hObject, eventdata, handles)
% hObject    handle to FV5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FV5 as text
%        str2double(get(hObject,'String')) returns contents of FV5 as a double


% --- Executes during object creation, after setting all properties.
function FV5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FV5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FV6_Callback(hObject, eventdata, handles)
% hObject    handle to FV6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FV6 as text
%        str2double(get(hObject,'String')) returns contents of FV6 as a double


% --- Executes during object creation, after setting all properties.
function FV6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FV6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FILTERQUANTITY_Callback(hObject, eventdata, handles)
% hObject    handle to FILTERQUANTITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FILTERQUANTITY as text
%        str2double(get(hObject,'String')) returns contents of FILTERQUANTITY as a double


% --- Executes during object creation, after setting all properties.
function FILTERQUANTITY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FILTERQUANTITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ADDTHISFILTER.
function ADDTHISFILTER_Callback(hObject, eventdata, handles)
QFT=get(handles.QuickFilterCode,'value');
QFO=get(handles.QuickFilterOptions,'value');
CurrentString=get(handles.FILTERQUANTITY,'string');
currentlist=get(handles.M2,'string');
for II=1:6
    CurrentInput=get(handles.(['FV',num2str(II)]),'string');
    Parameter{II} = CurrentInput;
end
switch(QFT)
    case 1 %LAST SHOTS
        NewFilterName=['Last_',Parameter{1}];
        if(Parameter{1}(1)=='#')
            NewFilterCode='(X)(CVCRCI2_PickLastEvents(X{1},X{2}))';
            Selettori(1,:)=[7,1,0];
            Selettori(2,:)=[5,str2double(Parameter{1}(3:end)),0];
            Type=1;
        else
            NewFilterCode=['(X)(CVCRCI2_PickLastEvents(X{1},',Parameter{1},'))'];
            Selettori=[7,1,0];
            Type=1;
        end 
    case 2 %TOP %
        NewFilterName=['Top_',Parameter{1},' % ',CurrentString(1:3)];
        %trova dove caspita sta ...
        PositionInList=find(strcmpi(currentlist, CurrentString));
        Selettori(1,:)=get(handles.FILTER_SEL,'userdata');
        if(Parameter{1}(1)=='#')
            NewFilterCode='(X)(CVCRCI2_PickTop(X{1},X{2}))';
            Selettori(2,:)=[5,str2double(Parameter{1}(3:end)),0];
            Type=1;
        else
            NewFilterCode=['(X)(CVCRCI2_PickTop(X{1},',Parameter{1},'))'];
            Type=1;
        end 
    case 3 %BOTTOM %
        NewFilterName=['Bottom_',Parameter{1},' % ',CurrentString(1:3)];
        %trova dove caspita sta ...
        PositionInList=find(strcmpi(currentlist, CurrentString));
        Selettori(1,:)=get(handles.FILTER_SEL,'userdata');
        if(Parameter{1}(1)=='#')
            NewFilterCode='(X)(CVCRCI2_PickBottom(X{1},X{2}))';
            Selettori(2,:)=[5,str2double(Parameter{1}(3:end)),0];
            Type=1;
        else
            NewFilterCode=['(X)(CVCRCI2_PickBottom(X{1},',Parameter{1},'))'];
            Type=1;
        end  
    case 4 %WHITIN RANGE
        Selettori(1,:)=get(handles.FILTER_SEL,'userdata');
        NewFilterCode='(X)(CVCRCI2_PickRange(X{1},';
        
        if(Parameter{1}(1)=='#')
            Selettori(end+1,:)=[5,str2double(Parameter{1}(3:end)),0];
            NewFilterCode=[NewFilterCode,'X{2},'];
        else
            NewFilterCode=[NewFilterCode,Parameter{1},','];
        end
        if(Parameter{2}(1)=='#')
            Selettori(end+1,:)=[5,str2double(Parameter{2}(3:end)),0];
            if(Parameter{1}(1)=='#')
                NewFilterCode=[NewFilterCode,'X{3},'];
            else
                NewFilterCode=[NewFilterCode,'X{2},'];
            end
        else
            NewFilterCode=[NewFilterCode,Parameter{2},','];
        end 
        switch(QFO)
            case 1
                NewFilterCode=[NewFilterCode,'1))'];
                NewFilterName=['C[avg] W[',Parameter{1},' sigma] ',CurrentString(1:3)];
            case 2
                NewFilterCode=[NewFilterCode,'2))'];
                NewFilterName=['C[avg] W[',Parameter{1},'] '];
            case 3
                NewFilterCode=[NewFilterCode,'3))'];
                NewFilterName=['C[',Parameter{1},'] W[',Parameter{2},'] ',CurrentString(1:3)];
            case 4
                NewFilterCode=[NewFilterCode,'4))'];
                NewFilterName=['C[',Parameter{1},'] W[',Parameter{2},'] ',CurrentString(1:3)];
            case 5
                NewFilterCode=[NewFilterCode,'5))'];
                NewFilterName=['F[',Parameter{1},'] T[',Parameter{2},'] ',CurrentString(1:3)];
        end          
end

currentfilters=get(handles.uitable3,'data');
if(~isempty(currentfilters))
    currentfilterscode=get(handles.uitable3,'userdata');
else
    currentfilterscode={};  
end
currentfilters{end+1,1}=NewFilterName;
currentfilters{end,2}=true;
currentfilterscode(end+1).type=1;
currentfilterscode(end).code=NewFilterCode;
currentfilterscode(end).S=Selettori;
set(handles.uitable3,'data',currentfilters);
set(handles.uitable3,'userdata',currentfilterscode);



% --- Executes during object creation, after setting all properties.
function uipanel7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function N2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to N2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when entered data in editable cell(s) in uitable3.
function uitable3_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable3 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column Indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

function [Funzione,Selettori]=parse_code(handles,Code,TYPE)
StrutturaDati=get(handles.PosizioneStrutturaDati,'UserData');
L1=get(handles.M1,'string');
L2=get(handles.M2,'string');
L3=get(handles.M3,'string');
L4=get(handles.M4,'string');
L5=get(handles.uitable4,'userdata');

CLM1=numel(L1);
CLM2=numel(L2);
CLM3=numel(L3);
CLM4=numel(L4);
CLM5=numel(L5)/2;

if(numel(Code)==1) %single line function
    TOTALNUMBEROFVARIABLESINSERTED= 0 ;
    Settori=[StrutturaDati.Number_of_synch_pvs,StrutturaDati.Number_of_scalars_in_a_matrix];
    Settori=cumsum(Settori);
    Selettori=[];
    
%     switch(TYPE)
%         case 1
%             strX=':'; %filter acts on the entire set, since often need to recalculate evrything.
%             funzione= 'VS_F';
%         case 2
%             strX='JustRecordedElements'; %scalars are evaluated on JustRecordedElements.
%             funzione= 'VS_S';
%         case 3
%             strX='SelectedByFilter'; % outputs are evaluated on events selected by the filter.
%             funzione= 'VS_O';
%     end
            
    for JJ=handles.NumberOfTemporaryVariables:-1:1
        if(any(strfind(Code{1},['##',num2str(JJ)])))
            TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
            Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[5,JJ,0];
            STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}'];
            Code{1}=regexprep(Code{1},['##',num2str(JJ)],STR);
        end  
    end
    
    for JJ=CLM2:-1:1
        Posizione=find(JJ<=Settori,1,'first');
        if(any(strfind(Code{1},['#',num2str(JJ)])))
            if(Posizione==1)
                TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
                Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[2,JJ,0];
                STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}'];
            else
               TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
               Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[3,num2str(JJ-Settori(Posizione-1)),num2str(Posizione-1)]; 
               STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}']; 
            end
            Code{1}=regexprep(Code{1},['#',num2str(JJ)],STR);
        end
    end 
    for JJ=CLM1:-1:1
        if(any(strfind(Code{1},['@@',num2str(JJ)])))
            TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
            Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[1,JJ,0];
            STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}'];
            Code{1}=regexprep(Code{1},['@@',num2str(JJ)],STR);
        end
    end
    for JJ=CLM4:-1:1
        if(any(strfind(Code{1},['%%',num2str(JJ)])))
            TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
            Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[4,2,StrutturaDati.Position_of_2Darrays_in_Profiles(JJ)];
            STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}'];
            Code{1}=regexprep(Code{1},['%%',num2str(JJ)],STR);
        end
    end
    for JJ=CLM3:-1:1
        if(any(strfind(Code{1},['%',num2str(JJ)])))
            TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
            Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[4,1,StrutturaDati.Position_of_vectors_in_Profiles(JJ)];
            STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}'];
            Code{1}=regexprep(Code{1},['%',num2str(JJ)],STR);
        end
    end
    for JJ=CLM5:-1:1
        if(any(strfind(Code{1},['@',num2str(JJ)])))
            TOTALNUMBEROFVARIABLESINSERTED=TOTALNUMBEROFVARIABLESINSERTED+1;
            Selettori(TOTALNUMBEROFVARIABLESINSERTED,:)=[6,JJ,0];
            STR=['X{',int2str(TOTALNUMBEROFVARIABLESINSERTED),'}'];
            Code{1}=regexprep(Code{1},['@',num2str(JJ)],STR);
        end
    end
%      VS_F(QuickVariables,NonSynch,SynchPV,NonStandardSynch,Profiles,ProcessedScalar,S)
     Funzione=['(X)(',Code{1},')'];
%     switch(TYPE)
%         case 1 %Filter, done on the entire set
%             Funzione=['(X)(',Code{1},')'];
%         case 2 %Synch Scalar, must be able to evaluate either on full set or on small set
%             Funzione=['(X)(',Code{1},')'];
%         case 3 %Output Scalar, must take into account active filters
%             Funzione=['(X)(',Code{1},')'];
%     end
    CODELEN=1;
else %MULTILINECODE %not now, not later not never
    CODELEN=numel(Code);
    Settori=[StrutturaDati.Number_of_synch_pvs,StrutturaDati.Number_of_scalars_in_a_matrix];
    Settori=cumsum(Settori);
    switch(TYPE)
        case 1
            strX=':'; %filter acts on the entire set, since often need to recalculate evrything.
        case 2
            strX='JustRecordedElements'; %scalars are evaluated on JustRecordedElements.
        case 3
            strX='SelectedByFilter'; % outputs are evaluated on events selected by the filter.
    end
    
    Funzione={};
    
    for HH=1:CODELEN
    Funzione{HH}=Code{HH};
    for JJ=handles.NumberOfTemporaryVariables:-1:1
        str=['QuickScalarVariable(',num2str(JJ),')'];
        Funzione{HH}=regexprep(Funzione{HH},['##',num2str(JJ)],str);
    end
    for JJ=CLM2:-1:1
        Posizione=find(JJ<=Settori,1,'first');
        if(Posizione==1)
           str=['SynchProfilePVs(',strX,',',num2str(JJ),')']; 
        else
           str=['ScalarBuffer{',num2str(Posizione-1),'}(',strX,',',num2str(JJ-Settori(Posizione-1)),')'];  
        end
        Funzione{HH}=regexprep(Funzione{HH},['#',num2str(JJ)],str);
    end
    for JJ=CLM1:-1:1
        str=['NotSynchProfilePVs(',strX,',',num2str(JJ),')'];
        Funzione{HH}=regexprep(Funzione{HH},['@@',num2str(JJ)],str);
    end
    for JJ=CLM4:-1:1
        str=['ProfileBuffer{',num2str(StrutturaDati.Position_of_2Darrays_in_Profiles(JJ)),'}'];
        Funzione{HH}=regexprep(Funzione{HH},['%%',num2str(JJ)],str);
    end
    for JJ=CLM3:-1:1
        str=['ProfileBuffer{',num2str(StrutturaDati.Position_of_vectors_in_Profiles(JJ)),'}'];
        Funzione{HH}=regexprep(Funzione{HH},['%',num2str(JJ)],str);
    end
    
    end
end

% --- Executes on button press in savenew.
function savenew_Callback(hObject, eventdata, handles)
TYPE = get(handles.SaveAsType,'value');
SingleLine=get(handles.SL1,'value');

if(SingleLine)
    Code=get(handles.edit12,'string');
else
    Code=get(handles.CurrentCode,'string');
end

if(iscell(Code))

else
    Code={Code};
end
[OutCode,Selettori]=parse_code(handles,Code,TYPE);

OutCode
Selettori

if(numel(OutCode)==0)
    return
end

NuovoNome=get(handles.NomeDellaVariabile,'string');
if(isempty(NuovoNome))
    return
end

switch(TYPE)
    case 1 %filter
        posizionedati=handles.uitable3; posizionecodice=handles.uitable3;
    case 2 %signal
        posizionedati=handles.uitable4; posizionecodice=handles.uitable4;
        nomeriga=get(handles.uitable4,'rowname');
    case 3 %output
        posizionedati=handles.uitable5;  posizionecodice=handles.uitable5;
end
LETTO=get(posizionedati,'data');
LETTOUD=get(posizionecodice,'userdata');

if(isempty(LETTOUD))
    clear LETTO LETTOUD
    LETTOUD(1).code=OutCode;
    LETTOUD(1).S=Selettori;
    if(SingleLine)
        LETTOUD(1).type=1;
    else
        LETTOUD(1).type=2;
    end
    if(TYPE==2)
        LETTOUD(1).outs=str2num(get(handles.ScalarsInACall,'string'));
    end
    LETTO{1,1}=[NuovoNome];
    LETTO{1,2}=true;
else
    LETTOUD(end+1).code=OutCode;
    LETTOUD(end).S=Selettori;
    if(SingleLine)
        LETTOUD(end).type=1;
    else
        LETTOUD(end).type=2;
    end
    PV=numel(LETTO)/2+1;
    if(TYPE==2)
        LETTOUD(end).outs=str2num(get(handles.ScalarsInACall,'string'));
    end
    LETTO{end+1,1}=[NuovoNome];
    LETTO{end,2}=true;
end

set(posizionedati,'data',LETTO);
set(posizionecodice,'userdata',LETTOUD);

switch(TYPE)
    case 1 %filter
    case 2 %signal
        PV=numel(LETTO)/2;
        for II=1:PV
            str{II}=['@',num2str(II)];
        end
        set(handles.uitable4,'rowname',str);
    case 3 %output
        posizionedati=handles.uitable5;  posizionecodice=handles.uitable5;
end


% --- Executes on selection change in SaveAsType.
function SaveAsType_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SaveAsType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SaveAsType


% --- Executes during object creation, after setting all properties.
function SaveAsType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SaveAsType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable4.
function uitable4_CellSelectionCallback(hObject, eventdata, handles)
set(handles.DeleteScalar,'userdata',eventdata);
table4data=get(handles.uitable4,'data');
%table4userdata=get(handles.uitable4,'userdata');
[SA,SB]=size(table4data);

if(~isempty(eventdata))
    if(numel(eventdata)==1)
        if(~isempty(eventdata.Indices))
            if(eventdata.Indices<=SA)
            table4data
            save TEMPAL
           Currentvalue=table4data{eventdata.Indices(1),1}
    %        currentlist={table4data(:,1)}
    % %        eventdata
    %        Currentvalue=currentlist{eventdata(1)};
           set(handles.FILTERQUANTITY,'string',Currentvalue);
           set(handles.FILTERQUANTITY,'userdata',1);
           set(handles.OUTPUTQUANTITY,'string',Currentvalue);
           set(handles.OUTPUTQUANTITY,'userdata',1);
    %        StrutturaDati=get(handles.PosizioneStrutturaDati,'userdata');
    % %        START=regexpi(Currentvalue,'=');
    %        ScalarsPositions=[StrutturaDati.Number_of_synch_pvs,StrutturaDati.Number_of_scalars_in_a_matrix];
    %        ScalarsPositionsCumsum=cumsum(ScalarsPositions);
    %        POS=find(eventdata<=ScalarsPositionsCumsum,1,'last');
    %        if(POS==1)
    %            SEL=[2,eventdata,0];
    %        else
    %            SEL=[3,POS,eventdata-ScalarsPositionsCumsum(POS-1)]; 
    %        end
           SEL=[6 , eventdata.Indices(1) , 0]; %6 because it is a processed scalar 0 for future use
           set(handles.FILTER_SEL,'userdata',SEL);
           set(handles.OUTPUT_SEL,'userdata',SEL);
           QuickFilterCode_Callback(hObject, eventdata, handles);
           QuickOutputBan_Callback(hObject, eventdata, handles);
           return
            end
        end
    end
end
set(handles.FILTERQUANTITY,'userdata',0);
set(handles.FILTERQUANTITY,'string','');
set(handles.OUTPUTQUANTITY,'userdata',0);
set(handles.OUTPUTQUANTITY,'string','');



% --- Executes when selected cell(s) is changed in uitable5.
function uitable5_CellSelectionCallback(hObject, eventdata, handles)
set(handles.DeleteOutput,'userdata',eventdata);


% --- Executes when entered data in editable cell(s) in uitable5.
function uitable5_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable5 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column Indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SL1.
function SL1_Callback(hObject, eventdata, handles)
% hObject    handle to SL1 (see GCBO)
set(handles.SL1,'value',1);
set(handles.SL2,'value',0);

% --- Executes on button press in SL2.
function SL2_Callback(hObject, eventdata, handles)
set(handles.SL1,'value',0);
set(handles.SL2,'value',1);

% Hint: get(hObject,'Value') returns toggle state of SL2


% --- Executes on button press in DeleteScalar.
function DeleteScalar_Callback(hObject, eventdata, handles)
ACTIVE=get(handles.DeleteScalar,'userdata')
ACTIVE.Indices
cf=get(handles.uitable4,'data')
cfh=get(handles.uitable4,'userdata')
if(~isfield(ACTIVE,'Indices'))
    return
end
if(numel(ACTIVE.Indices)~=2)
    return
end
ACTIVEROW=ACTIVE.Indices(1);
save TEMPOREXXX
if(~ACTIVEROW), return, end
if(numel(cfh)==1) %cancella tutto
        cf={};
        cfh=[];
    elseif(numel(cfh)==ACTIVEROW) %e' l'ultimo
        cf=cf(1:(ACTIVEROW-1),:);
        cfh=cfh(1:(end-1));
    else    
        for TT=ACTIVEROW:(numel(cfh)-1)
           cfh(TT)=cfh(TT+1);
           cf{TT,1}=cf{TT+1,1};
           cf{TT,2}=cf{TT+1,2};
        end
        cfh=cfh(1:(end-1));
        cf=reshape({cf{1:(end-1),:}},[numel(cfh),2]);
end

if(numel(cfh))
    for TT=1:numel(cfh)
        rownames{TT}=['@',num2str(TT)];
    end
else
    rownames={};
end

set(handles.uitable4,'RowName',rownames);
set(handles.uitable4,'data',cf);
set(handles.uitable4,'userdata',cfh);

% ACTIVE=get(handles.DeleteFilter,'userdata');
% cf=get(handles.uitable3,'data');
% cfh=get(handles.uitable3,'userdata');
% if(~isfield(ACTIVE,'Indices'))
%     return
% end
% if(numel(ACTIVE.Indices)~=2)
%     return
% end
% ACTIVEROW=ACTIVE.Indices(1);
% if(~ACTIVEROW), return, end
% if(numel(cfh)==1) %cancella tutto
%         cf={};
%         cfh=[];
%     elseif(numel(cfh)==ACTIVEROW) %e' l'ultimo
%         cf=cf(1:(ACTIVEROW-1),:);
%         cfh=cfh(1:(end-1));
%     else    
%         for TT=ACTIVEROW:(numel(cfh)-1)
%            cfh(TT)=cfh(TT+1);
%            cf{TT,1}=cf{TT+1,1};
%            cf{TT,2}=cf{TT+1,2};
%         end
%         
%         cfh=cfh(1:(end-1));
%         cf=reshape({cf{1:(end-1),:}},[numel(cfh),2]);
% end
% set(handles.uitable3,'data',cf);
% set(handles.uitable3,'userdata',cfh);


% --- Executes on button press in DeleteOutput.
function DeleteOutput_Callback(hObject, eventdata, handles)
ACTIVE=get(handles.DeleteOutput,'userdata');
cf=get(handles.uitable5,'data')
cfh=get(handles.uitable5,'userdata')
if(~isfield(ACTIVE,'Indices'))
    return
end
if(numel(ACTIVE.Indices)~=2)
    return
end
ACTIVEROW=ACTIVE.Indices(1);
if(~ACTIVEROW), return, end
if(numel(cfh)==1) %cancella tutto
        cf={};
        cfh=[];
    elseif(numel(cfh)==ACTIVEROW) %e' l'ultimo
        cf=cf(1:(ACTIVEROW-1),:);
        cfh=cfh(1:(end-1));
    else    
        for TT=ACTIVEROW:(numel(cfh)-1)
           cfh(TT)=cfh(TT+1);
           cf{TT,1}=cf{TT+1,1};
           cf{TT,2}=cf{TT+1,2};
        end
        cfh=cfh(1:(end-1));
        cf=reshape({cf{1:(end-1),:}},[numel(cfh),2]);
end
set(handles.uitable5,'data',cf);
set(handles.uitable5,'userdata',cfh);



function OUTPUTQUANTITY_Callback(hObject, eventdata, handles)
% hObject    handle to OUTPUTQUANTITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OUTPUTQUANTITY as text
%        str2double(get(hObject,'String')) returns contents of OUTPUTQUANTITY as a double


% --- Executes during object creation, after setting all properties.
function OUTPUTQUANTITY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OUTPUTQUANTITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ADDTHISOUTPUT.
function ADDTHISOUTPUT_Callback(hObject, eventdata, handles)
QFT=get(handles.QuickOutputBan,'value');
%QFO=get(handles.QuickOutputOptions,'value');
CurrentString=get(handles.OUTPUTQUANTITY,'string');
%currentlist=get(handles.M2,'string');
for II=1:6
    CurrentInput=get(handles.(['OV',num2str(II)]),'string');
    Parameter{II} = CurrentInput;
end
SELUD=get(handles.OUTPUT_SEL,'userdata');
if(isempty(SELUD))
    return
end
switch(QFT)
    case 1 %AVERAGE
        NewOutputName=['AVG_',CurrentString(6:end)];
        NewOutputCode='(X)(mean(X{1}))';
        Selettori(1,:)=get(handles.OUTPUT_SEL,'userdata');
        Type=1;
    case 2 %STD
        NewOutputName=['STD_',CurrentString(6:end)];
        NewOutputCode='(X)(std(X{1}))';
        Selettori(1,:)=get(handles.OUTPUT_SEL,'userdata');
        Type=1;
    case 3 %FLUCT
        NewOutputName=['FLUCT_',CurrentString(6:end)];
        NewOutputCode='(X)(std(X{1})./mean(X{1}))';
        Selettori(1,:)=get(handles.OUTPUT_SEL,'userdata');
        Type=1;        
end
%save TEMPXX
currentoutputs=get(handles.uitable5,'data');
if(~isempty(currentoutputs))
    currentoutputscode=get(handles.uitable5,'userdata');
else
    currentoutputscode={};  
end
currentoutputs{end+1,1}=NewOutputName;
currentoutputs{end,2}=true;
currentoutputscode(end+1).type=1;
currentoutputscode(end).code=NewOutputCode;
currentoutputscode(end).S=Selettori;
set(handles.uitable5,'data',currentoutputs);
set(handles.uitable5,'userdata',currentoutputscode);





function ScalarsInACall_Callback(hObject, eventdata, handles)
% hObject    handle to ScalarsInACall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScalarsInACall as text
%        str2double(get(hObject,'String')) returns contents of ScalarsInACall as a double


% --- Executes during object creation, after setting all properties.
function ScalarsInACall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScalarsInACall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV1_Callback(hObject, eventdata, handles)
% hObject    handle to SV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV1 as text
%        str2double(get(hObject,'String')) returns contents of SV1 as a double


% --- Executes during object creation, after setting all properties.
function SV1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV2_Callback(hObject, eventdata, handles)
% hObject    handle to SV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV2 as text
%        str2double(get(hObject,'String')) returns contents of SV2 as a double


% --- Executes during object creation, after setting all properties.
function SV2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in QuickScalarOptions.
function QuickScalarOptions_Callback(hObject, eventdata, handles)
CurrentType=get(handles.QuickSynchScalarCode,'value');
CurrentSubType=get(handles.QuickScalarOptions,'value');
MyOptions=handles.QuickScalar;
CurrentOptions=MyOptions.Subtypes(CurrentType).Options;
%disp('saved')
%save TEMP

CurrentSCALARQuantitySelection=get(handles.SCALARQUANTITY,'userdata');
if(~isempty(CurrentSCALARQuantitySelection))
    if(CurrentSCALARQuantitySelection(1))
        SelectedArray=get(handles.SCALAR_SEL,'userdata');
        %save TEMPX
        if(SelectedArray(3)==1) % a vector is selected
            if(MyOptions.VectorAvailable(CurrentType)), set(handles.ADDTHISSCALAR,'enable','on'); else, set(handles.ADDTHISSCALAR,'enable','off'); end
        elseif(SelectedArray(3)==2) %an image is selected
            if(MyOptions.ImageAvailable(CurrentType)), set(handles.ADDTHISSCALAR,'enable','on'); else, set(handles.ADDTHISSCALAR,'enable','off'); end
        end
    end
end

if(~isempty(CurrentOptions))
    CurrentMenu=CurrentOptions(CurrentSubType);
    if(numel(CurrentMenu.names)==1)
        set(handles.SV1,'visible','on'); set(handles.SE1,'visible','on');
        set(handles.SE1,'string',CurrentMenu.names{1}); set(handles.SV1,'string',CurrentMenu.Default{1});
       for TT=2:6
           set(handles.(['SV',(num2str(TT))]),'visible','off'); set(handles.(['SE',(num2str(TT))]),'visible','off');
       end
    else
        for TT=1:6
            if(TT>numel(CurrentMenu.names))
                set(handles.(['SV',(num2str(TT))]),'visible','off'); set(handles.(['SE',(num2str(TT))]),'visible','off');
            else
                nome=CurrentMenu.names{TT};
                valore=CurrentMenu.Default{TT};
                set(handles.(['SE',(num2str(TT))]),'string',nome); set(handles.(['SV',(num2str(TT))]),'string',valore);
                set(handles.(['SE',(num2str(TT))]),'visible','on'); set(handles.(['SV',(num2str(TT))]),'visible','on');
            end
        end    
    end
else
    if(~CurrentSCALARQuantitySelection(1))
        set(handles.ADDTHISSCALAR,'enable','off')
    end
    for TT=1:6  
        set(handles.(['SE',(num2str(TT))]),'visible','off'); set(handles.(['SV',(num2str(TT))]),'visible','off');
    end
end


% --- Executes during object creation, after setting all properties.
function QuickScalarOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuickScalarOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV3_Callback(hObject, eventdata, handles)
% hObject    handle to SV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV3 as text
%        str2double(get(hObject,'String')) returns contents of SV3 as a double


% --- Executes during object creation, after setting all properties.
function SV3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV4_Callback(hObject, eventdata, handles)
% hObject    handle to SV4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV4 as text
%        str2double(get(hObject,'String')) returns contents of SV4 as a double


% --- Executes during object creation, after setting all properties.
function SV4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV5_Callback(hObject, eventdata, handles)
% hObject    handle to SV5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV5 as text
%        str2double(get(hObject,'String')) returns contents of SV5 as a double


% --- Executes during object creation, after setting all properties.
function SV5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SV6_Callback(hObject, eventdata, handles)
% hObject    handle to SV6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SV6 as text
%        str2double(get(hObject,'String')) returns contents of SV6 as a double


% --- Executes during object creation, after setting all properties.
function SV6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SV6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SCALARQUANTITY_Callback(hObject, eventdata, handles)
% hObject    handle to SCALARQUANTITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SCALARQUANTITY as text
%        str2double(get(hObject,'String')) returns contents of SCALARQUANTITY as a double


% --- Executes during object creation, after setting all properties.
function SCALARQUANTITY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SCALARQUANTITY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ADDTHISSCALAR.
function ADDTHISSCALAR_Callback(hObject, eventdata, handles)
QFT=get(handles.QuickSynchScalarCode,'value');
QFO=get(handles.QuickScalarOptions,'value');
CurrentString=get(handles.SCALARQUANTITY,'string');
currentlistIMA=get(handles.M4,'string');
currentlistVEC=get(handles.M3,'string');
Selection=get(handles.SCALAR_SEL,'userdata')
for II=1:6
    CurrentInput=get(handles.(['SV',num2str(II)]),'string');
    Parameter{II} = CurrentInput;
end
switch(QFT)
    case 1 % Area On 1D Detector
        NewScalarName=['IInt_',CurrentString(1:3),'_',Parameter{1},'-',Parameter{2}];
        NewScalarCode='(X)(CVCRCI2_VectorArea(X{1},';
        Selettori(1,:)=Selection;
        Type=1; Outs=1;
        SELINS=1;
        if(Parameter{1}(1)=='#')
            SELINS=SELINS+1;
            NewScalarCode=[NewScalarCode,'X{',str2double(SELINS),'},'];
            Selettori(SELINS,:)=[5,str2double(Parameter{1}(3:end)),0];   
        else
            NewScalarCode=[NewScalarCode,Parameter{1},','];
            %NewFilterCode=['(X)(CVCRCI2_VectorArea(X{1},',Parameter{1},'))'];
        end 
        if(Parameter{2}(1)=='#')
            SELINS=SELINS+1;
            NewScalarCode=[NewScalarCode,'X{',str2double(SELINS),'}'];
            Selettori(SELINS,:)=[5,str2double(Parameter{1}(3:end)),0];   
        else
            NewScalarCode=[NewScalarCode,Parameter{2}];
            %NewFilterCode=['(X)(CVCRCI2_VectorArea(X{1},',Parameter{1},'))'];
        end 
        NewScalarCode=[NewScalarCode,'))'];
    case 2 % Area On 2D Detector
        NewScalarName=['IInt_',CurrentString(1:3),'_',Parameter{1},'-',Parameter{2},'_',Parameter{3},'-',Parameter{4}];
        NewScalarCode='(X)(CVCRCI2_ImageArea(X{1},';
        Selettori(1,:)=Selection;
        Type=1; Outs=1;
        SELINS=1;
        if(Parameter{1}(1)=='#')
            SELINS=SELINS+1;
            NewScalarCode=[NewScalarCode,'X{',str2double(SELINS),'},'];
            Selettori(SELINS,:)=[5,str2double(Parameter{1}(3:end)),0];   
        else
            NewScalarCode=[NewScalarCode,Parameter{1},','];
            %NewFilterCode=['(X)(CVCRCI2_VectorArea(X{1},',Parameter{1},'))'];
        end 
        if(Parameter{2}(1)=='#')
            SELINS=SELINS+1;
            NewScalarCode=[NewScalarCode,'X{',str2double(SELINS),'},'];
            Selettori(SELINS,:)=[5,str2double(Parameter{1}(3:end)),0];   
        else
            NewScalarCode=[NewScalarCode,Parameter{2},','];
            %NewFilterCode=['(X)(CVCRCI2_VectorArea(X{1},',Parameter{1},'))'];
        end 
        if(Parameter{3}(1)=='#')
            SELINS=SELINS+1;
            NewScalarCode=[NewScalarCode,'X{',str2double(SELINS),'},'];
            Selettori(SELINS,:)=[5,str2double(Parameter{1}(3:end)),0];   
        else
            NewScalarCode=[NewScalarCode,Parameter{3},','];
            %NewFilterCode=['(X)(CVCRCI2_VectorArea(X{1},',Parameter{1},'))'];
        end 
        if(Parameter{4}(1)=='#')
            SELINS=SELINS+1;
            NewScalarCode=[NewScalarCode,'X{',str2double(SELINS),'}'];
            Selettori(SELINS,:)=[5,str2double(Parameter{1}(3:end)),0];   
        else
            NewScalarCode=[NewScalarCode,Parameter{4}];
            %NewFilterCode=['(X)(CVCRCI2_VectorArea(X{1},',Parameter{1},'))'];
        end 
        NewScalarCode=[NewScalarCode,'))'];
    case 3 % Max position, Max value for a vector
        NewScalarName={['VectorPeak_VAL_',Parameter{1},' % ',CurrentString(1:3)],['VectorPeak_POS_',Parameter{1},' % ',CurrentString(1:3)]};
        %trova dove caspita sta ...
        Selettori(1,:)=Selection;
        Type=1; Outs=2;        
        NewScalarCode='(X)(CVCRCI2_VectorMax(X{1}))';
          
    case 4 % Max position (X and Y), Max value for a 2D image
        NewScalarName={['ImagePeak_VAL_',Parameter{1},' % ',CurrentString(1:3)],['ImagePeak_POSX_',Parameter{1},' % ',CurrentString(1:3)],['ImagePeak_POSY_',Parameter{1},' % ',CurrentString(1:3)]};
        %trova dove caspita sta ...
        Selettori(1,:)=Selection;
        Type=1; Outs=3;        
        NewScalarCode='(X)(CVCRCI2_ImageMax(X{1}))';     
end

currentscalars=get(handles.uitable4,'data');
if(~isempty(currentscalars))
    currentscalarscode=get(handles.uitable4,'userdata');
else
    currentscalarscode={};  
end
if(~iscell(NewScalarName))
    currentscalars{end+1,1}=NewScalarName;
    currentscalars{end,2}=true;
    currentscalarscode(end+1).type=1;
    currentscalarscode(end).code=NewScalarCode;
    currentscalarscode(end).outs=Outs;
    currentscalarscode(end).S=Selettori;
    set(handles.uitable4,'data',currentscalars);
    set(handles.uitable4,'userdata',currentscalarscode);
else
    for III=1:Outs
        currentscalars{end+1,1}=NewScalarName{III};
        currentscalars{end,2}=true;
        currentscalarscode(end+1).type=1;
        currentscalarscode(end).code=NewScalarCode;
        currentscalarscode(end).outs=Outs;
        currentscalarscode(end).S=Selettori;
    end
    set(handles.uitable4,'data',currentscalars);
    set(handles.uitable4,'userdata',currentscalarscode);
end


% --- Executes on selection change in QuickOutputBan.
function QuickOutputBan_Callback(hObject, eventdata, handles)
% hObject    handle to QuickOutputBan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns QuickOutputBan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from QuickOutputBan


% --- Executes during object creation, after setting all properties.
function QuickOutputBan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuickOutputBan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OV1_Callback(hObject, eventdata, handles)
% hObject    handle to OV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OV1 as text
%        str2double(get(hObject,'String')) returns contents of OV1 as a double


% --- Executes during object creation, after setting all properties.
function OV1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OV2_Callback(hObject, eventdata, handles)
% hObject    handle to OV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OV2 as text
%        str2double(get(hObject,'String')) returns contents of OV2 as a double


% --- Executes during object creation, after setting all properties.
function OV2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OV3_Callback(hObject, eventdata, handles)
% hObject    handle to OV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OV3 as text
%        str2double(get(hObject,'String')) returns contents of OV3 as a double


% --- Executes during object creation, after setting all properties.
function OV3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OV4_Callback(hObject, eventdata, handles)
% hObject    handle to OV4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OV4 as text
%        str2double(get(hObject,'String')) returns contents of OV4 as a double


% --- Executes during object creation, after setting all properties.
function OV4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OV4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OV5_Callback(hObject, eventdata, handles)
% hObject    handle to OV5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OV5 as text
%        str2double(get(hObject,'String')) returns contents of OV5 as a double


% --- Executes during object creation, after setting all properties.
function OV5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OV5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function OV6_Callback(hObject, eventdata, handles)
% hObject    handle to OV6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OV6 as text
%        str2double(get(hObject,'String')) returns contents of OV6 as a double


% --- Executes during object creation, after setting all properties.
function OV6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OV6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
