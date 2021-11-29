function varargout = ULT_TaperRestore(varargin)
% ULT_TAPERRESTORE MATLAB code for ULT_TaperRestore.fig
%      ULT_TAPERRESTORE, by itself, creates a new ULT_TAPERRESTORE or raises the existing
%      singleton*.
%
%      H = ULT_TAPERRESTORE returns the handle to a new ULT_TAPERRESTORE or the handle to
%      the existing singleton*.
%
%      ULT_TAPERRESTORE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ULT_TAPERRESTORE.M with the given input arguments.
%
%      ULT_TAPERRESTORE('Property','Value',...) creates a new ULT_TAPERRESTORE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ULT_TaperRestore_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ULT_TaperRestore_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ULT_TaperRestore

% Last Modified by GUIDE v2.5 11-Jun-2020 17:02:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ULT_TaperRestore_OpeningFcn, ...
                   'gui_OutputFcn',  @ULT_TaperRestore_OutputFcn, ...
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


% --- Executes just before ULT_TaperRestore is made visible.
function ULT_TaperRestore_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ULT_TaperRestore (see VARARGIN)

% Choose default command line output for ULT_TaperRestore
handles.output = hObject;

handles.ULID=varargin{2};
handles.UL=varargin{1};
handles.SaveDir=varargin{3};
handles.TaperSave=varargin{4};

load([handles.SaveDir,'/',handles.TaperSave],'StoredTapers');
handles.StoredTapers=StoredTapers;

NUNC=clock; Years={};

YY=NUNC(1);
MM=NUNC(2);
DD=NUNC(3);

Years=2020:NUNC(1);
Months=1:12;
Days=1:31;

set(handles.BOTH,'value',0);

Ds=cell(length(Days),1); for II=1:length(Days), Ds{II}=num2str(Days(II)); end
Ms=cell(length(Months),1); for II=1:length(Months), Ms{II}=num2str(Months(II)); end
Ys=cell(length(Years),1); for II=1:length(Years), Ys{II}=num2str(Years(II)); end

Yp=find(YY==Years);
Mp=find(MM==Months);
PosD=find(DD==Days);

set(handles.Y,'string',Ys); set(handles.Y,'value',Yp);
set(handles.M,'string',Ms); set(handles.M,'value',Mp);
set(handles.D,'string',Ds); set(handles.D,'value',PosD);

set(handles.eY,'string','0'); set(handles.eM,'string','0'); set(handles.eD,'string','1');

set(handles.Keyword,'string','');

handles.StoredLines=unique([handles.StoredTapers.ULID]);
for II=1:8
    if(II<=length(handles.StoredLines))
        set(handles.(['r',num2str(II)]),'visible','on');
        set(handles.(['r',num2str(II)]),'string',handles.UL(II).name);
        if(II==handles.ULID)
            set(handles.(['r',num2str(II)]),'value',1);
        else
            set(handles.(['r',num2str(II)]),'value',0);
        end
    else
        set(handles.(['r',num2str(II)]),'visible','off');
    end
end

handles.AllTimes=[handles.StoredTapers.time];
handles.AllStrings={handles.StoredTapers.Description};
handles.AllULID=[handles.StoredTapers.ULID];

% Update handles structure
guidata(hObject, handles);
update_search_by_date(handles);

% UIWAIT makes ULT_TaperRestore wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function update_search_by_date(handles)
cla(handles.axes1);
VHH=get(handles.Y,'value'); VHS=get(handles.Y,'string'); VH=str2num(VHS{VHH}) ; VM=get(handles.M,'value'); VD=get(handles.D,'value');
dY=str2num(get(handles.eY,'string')); dM=str2num(get(handles.eM,'string')); dD=str2num(get(handles.eD,'string'));
Time_SPAN = sign(dY)*datenum([abs(dY),0,0,0,0,0]) + sign(dM)*datenum([0,abs(dM)+1,0,0,0,0]) + sign(dD)*datenum([0,0,abs(dD),0,0,0]);
Time_Base = datenum([VH,VM,VD,0,0,0]);
ULID=getLine(handles);
BOTH=get(handles.BOTH,'value');
if(~BOTH)
    Keep=find((handles.AllTimes>= min(Time_Base + Time_SPAN, Time_Base)) & (handles.AllTimes<= max(Time_Base + Time_SPAN, Time_Base) & (handles.AllULID == ULID))  );
else
    STRING=get(handles.Keyword,'string');
    Keep=find((handles.AllTimes>= min(Time_Base + Time_SPAN, Time_Base)) & (handles.AllTimes<= max(Time_Base + Time_SPAN, Time_Base) & (handles.AllULID == ULID) & cellfun(@(x) ~isempty(x),strfind(handles.AllStrings,STRING)))  );
end
set(handles.RESTORE,'enable','off'); set(handles.testo,'string','');
if(isempty(Keep))
   set(handles.uitable1,'data',{});
   set(handles.uitable1,'userdata',[]);
else
   TAPERS=handles.StoredTapers(Keep);
   Data=cell(length(TAPERS),6);
   for II=1:length(TAPERS)
      Data{II,1}=TAPERS(II).ULID;
      Data{II,2}=TAPERS(II).Y;
      Data{II,3}=TAPERS(II).M;
      Data{II,4}=TAPERS(II).D;
      Data{II,5}=[num2str(TAPERS(II).H),':',num2str(TAPERS(II).Min),':',num2str(TAPERS(II).S)];
      Data{II,6}=TAPERS(II).Description;
   end
   set(handles.uitable1,'data',Data);
   set(handles.uitable1,'userdata',TAPERS);
end

function update_search_by_string(handles)
cla(handles.axes1);
STRING=get(handles.Keyword,'string'); ULID=getLine(handles);
BOTH=get(handles.BOTH,'value');
if(~BOTH)
    Keep= find(  cellfun(@(x) ~isempty(x),strfind(handles.AllStrings,STRING)) & (handles.AllULID == ULID)  );
else
    VHH=get(handles.Y,'value'); VHS=get(handles.Y,'string'); VH=str2num(VHS{VHH}) ; VM=get(handles.M,'value'); VD=get(handles.D,'value');
    dY=str2num(get(handles.eY,'string')); dM=str2num(get(handles.eM,'string')); dD=str2num(get(handles.eD,'string'));
    Time_SPAN = sign(dY)*datenum([abs(dY),0,0,0,0,0]) + sign(dM)*datenum([0,abs(dM)+1,0,0,0,0]) + sign(dD)*datenum([0,0,abs(dD),0,0,0]);
    Time_Base = datenum([VH,VM,VD,0,0,0]);
    Keep=find((handles.AllTimes>= min(Time_Base + Time_SPAN, Time_Base)) & (handles.AllTimes<= max(Time_Base + Time_SPAN, Time_Base) & (handles.AllULID == ULID) & cellfun(@(x) ~isempty(x),strfind(handles.AllStrings,STRING)))  );
end
set(handles.RESTORE,'enable','off'); set(handles.testo,'string','');
if(isempty(Keep))
   set(handles.uitable1,{});
   set(handles.uitable1,'userdata',[]);
else
   TAPERS=handles.StoredTapers(Keep);
   Data=cell(length(TAPERS),6);
   for II=1:length(TAPERS)
      Data{II,1}=TAPERS(II).ULID;
      Data{II,2}=TAPERS(II).Y;
      Data{II,3}=TAPERS(II).M;
      Data{II,4}=TAPERS(II).D;
      Data{II,5}=[num2str(TAPERS(II).H),'/',num2str(TAPERS(II).Min),'/',num2str(TAPERS(II).S)];
      Data{II,6}=TAPERS(II).Description;
   end
   set(handles.uitable1,'data',Data);
   set(handles.uitable1,'userdata',TAPERS);
end

function ULID=getLine(handles)
for II=1:max(handles.StoredLines)
    if(get(handles.(['r',num2str(II)]),'value'))
       ULID=II;
       return
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = ULT_TaperRestore_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Y.
function Y_Callback(hObject, eventdata, handles)
update_search_by_date(handles)

% --- Executes during object creation, after setting all properties.
function Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in M.
function M_Callback(hObject, eventdata, handles)
update_search_by_date(handles)

% --- Executes during object creation, after setting all properties.
function M_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in D.
function D_Callback(hObject, eventdata, handles)
update_search_by_date(handles)


% --- Executes during object creation, after setting all properties.
function D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SPAN_Callback(hObject, eventdata, handles)
% hObject    handle to SPAN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SPAN as text
%        str2double(get(hObject,'String')) returns contents of SPAN as a double


% --- Executes during object creation, after setting all properties.
function SPAN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SPAN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function manage_toggle_button(handles,N)
for II=1:8
   if(II==N)
      set(handles.(['r',num2str(II)]),1); 
   else
      set(handles.(['r',num2str(II)]),0); 
   end
end

% --- Executes on button press in r1.
function r1_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,1);
update_search_by_date(handles)

% --- Executes on button press in r2.
function r2_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,2);
update_search_by_date(handles)

% --- Executes on button press in r3.
function r3_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,3);
update_search_by_date(handles)

% --- Executes on button press in r4.
function r4_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,4);
update_search_by_date(handles)

% --- Executes on button press in r5.
function r5_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,5);
update_search_by_date(handles)

% --- Executes on button press in r6.
function r6_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,6);
update_search_by_date(handles)

% --- Executes on button press in r7.
function r7_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,7);
update_search_by_date(handles)

% --- Executes on button press in r8.
function r8_Callback(hObject, eventdata, handles)
manage_toggle_button(handles,8);
update_search_by_date(handles)

function Keyword_Callback(hObject, eventdata, handles)
update_search_by_string(handles)

% --- Executes during object creation, after setting all properties.
function Keyword_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Keyword (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RESTORE.
function RESTORE_Callback(hObject, eventdata, handles)
TAPER=get(handles.RESTORE,'userdata');
TargetState=TAPER.LineReadout;
ULID=TAPER.ULID; Harmonic=1; ins=0;
if(numel(handles.UL(ULID).slot)==numel(TargetState))
    for II=1:length(handles.UL(ULID).slot)
        if(handles.UL(ULID).slot(II).USEG.present)
            if(TargetState(II).K>0)    
            ins=ins+1;    
            NewDest=handles.UL(ULID).slot(II).USEG.f.Set_K_struct(handles.UL(ULID).slot(II).USEG,[TargetState(II).K,TargetState(II).Kend],Harmonic,handles.UL(ULID).Basic.Reference_lambda_u);    
            if(ins==1)
                Destination(1)=NewDest;
            else
                Destination(ins)=NewDest;
            end
            end
        end
        if(handles.UL(ULID).slot(II).PHAS.present)
            lcaPutSmart(handles.UL(ULID).slot(II).PHAS.pv.PDes,TargetState(II).PhaseDes)
        end
    end
end
handles.UL(ULID).f.UndulatorLine_K_set(handles.UL(ULID),Destination);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
close(handles.figure1)

function eY_Callback(hObject, eventdata, handles)
update_search_by_date(handles)

% --- Executes during object creation, after setting all properties.
function eY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eD_Callback(hObject, eventdata, handles)
update_search_by_date(handles)

% --- Executes during object creation, after setting all properties.
function dasda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dasda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eM_Callback(hObject, eventdata, handles)
update_search_by_date(handles)

% --- Executes during object creation, after setting all properties.
function eMwdqwdq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eMwdqwdq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
TAPERS=get(handles.uitable1,'userdata');
ID=eventdata.Indices(1);
if(ID<=length(TAPERS))
    TAPER=TAPERS(ID);
    DisplayTaper(handles,TAPER)
    set(handles.RESTORE,'userdata',TAPER);
    set(handles.RESTORE,'enable','on');
end

function DisplayTaper(handles,TAPER)
String=[num2str(TAPER.Y),'/',num2str(TAPER.M),'/',num2str(TAPER.D),'  -  ',TAPER.Description];
set(handles.testo,'string',String);
cla(handles.axes1);
plot(handles.axes1,1:length(TAPER.LineReadout),[TAPER.LineReadout.K],'*'); hold(handles.axes1,'on');
plot(handles.axes1,2:(1+length(TAPER.LineReadout)),[TAPER.LineReadout.Kend],'*');


% --- Executes on button press in BOTH.
function BOTH_Callback(hObject, eventdata, handles)
% hObject    handle to BOTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BOTH

  
% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function eD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function eM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
TAPERS=get(handles.uitable1,'userdata');
if(isempty(eventdata.Indices))
    return
end
ID=eventdata.Indices(1);
if(ID<=length(TAPERS))
    TAPER=TAPERS(ID);
    DisplayTaper(handles,TAPER)
    set(handles.RESTORE,'userdata',TAPER);
    set(handles.RESTORE,'enable','on');
end
