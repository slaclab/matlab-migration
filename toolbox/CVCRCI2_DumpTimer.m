function varargout = CVCRCI2_DumpTimer(varargin)
% CVCRCI2_DUMPTIMER MATLAB code for CVCRCI2_DumpTimer.fig
%      CVCRCI2_DUMPTIMER, by itself, creates a new CVCRCI2_DUMPTIMER or raises the existing
%      singleton*.
%
%      H = CVCRCI2_DUMPTIMER returns the handle to a new CVCRCI2_DUMPTIMER or the handle to
%      the existing singleton*.
%
%      CVCRCI2_DUMPTIMER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI2_DUMPTIMER.M with the given input arguments.
%
%      CVCRCI2_DUMPTIMER('Property','Value',...) creates a new CVCRCI2_DUMPTIMER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI2_DumpTimer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI2_DumpTimer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI2_DumpTimer

% Last Modified by GUIDE v2.5 25-Apr-2015 20:04:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI2_DumpTimer_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI2_DumpTimer_OutputFcn, ...
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


% --- Executes just before CVCRCI2_DumpTimer is made visible.
function CVCRCI2_DumpTimer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI2_DumpTimer (see VARARGIN)

% Choose default command line output for CVCRCI2_DumpTimer
handles.output = hObject;
handles.ColorON=[0,1,0];
handles.ColorIdle=[.7,.7,.7];
handles.ColorWait=[1,1,0];
set(handles.TurnON,'backgroundcolor',handles.ColorIdle);
set(handles.TurnOFF,'backgroundcolor',handles.ColorIdle);
set(handles.ForceSaving,'backgroundcolor',handles.ColorIdle);
set(handles.Status,'backgroundcolor',handles.ColorWait);
set(handles.Status,'String','OFF');
UserSelections.ON=NaN;
UserSelections.TimeTurnedOn=NaN;
UserSelections.Status=0;
UserSelections.OneSecond=1.158024727677306e-05;
UserSelections.ForceSaving=0;
UserSelections.FN=get(handles.FN,'string');
UserSelections.TimeOut=str2num(get(handles.TimeOut,'string'));
set(handles.Requested,'userdata',UserSelections);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVCRCI2_DumpTimer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI2_DumpTimer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function e_binsy_Callback(hObject, eventdata, handles)
binsy=str2double(get(handles.e_binsy,'string'));
UserSelections=get(handles.Requested,'Userdata');
if(isnan(binsy) || isinf(binsy) || (binsy>500) || (binsy<3))
    binsy=10; set(handles.e_binsy,'string','10'); 
else
    binsy=round(binsy);
end
UserSelections.binsy=binsy;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_binsy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_binsy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_autoY.
function b_autoY_Callback(hObject, eventdata, handles)
current=get(handles.b_autoY,'backgroundcolor');
UserSelections=get(handles.Requested,'Userdata');
if(sum(current==handles.ColorON)==3)
    set(handles.b_autoY,'backgroundcolor',handles.ColorIdle);
    UserSelections.b_autoY=0;
else
    set(handles.b_autoY,'backgroundcolor',handles.ColorON); 
    UserSelections.b_autoY=1;
end
set(handles.Requested,'Userdata',UserSelections);


function e_y1_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.e_y1,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(UserSelections.lim_y2))
    if(newval==UserSelections.lim_y2)
        newval=newval-10^-16; UserSelections.lim_y2=UserSelections.lim_y2+10^-16;
    elseif(newval>UserSelections.lim_y2)
        TEMP=UserSelections.lim_y2;
        UserSelections.lim_y2=newval;
        newval=TEMP;
        set(handles.e_y2,'string',num2str(UserSelections.lim_y2));
        set(handles.e_y1,'string',num2str(newval));
    end 
end
UserSelections.lim_y1=newval;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_y1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_y2_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.e_y2,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(UserSelections.lim_y1))
    if(newval==UserSelections.lim_y1)
        newval=newval+10^-16; UserSelections.lim_y1=UserSelections.lim_y1-10^-16;
    elseif(newval<UserSelections.lim_y1)
        TEMP=UserSelections.lim_y1;
        UserSelections.lim_y1=newval;
        newval=TEMP;
        set(handles.e_y1,'string',num2str(UserSelections.lim_y1));
        set(handles.e_y2,'string',num2str(newval));
    end 
end
UserSelections.lim_y2=newval;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_y2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_y2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in VECTOR_SEL.
function VECTOR_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StoredDataStructure,'userdata');
VAL=get(handles.VECTOR_SEL,'value');
UserSelections=get(handles.Requested,'Userdata');
if(VAL==1)
   UserSelections.VECTOR_SEL=[0,0];
else
   UserSelections.VECTOR_SEL=[VAL-1,SDA.Position_of_vectors_in_Profiles(VAL-1)];
end
set(handles.Requested,'userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function VECTOR_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VECTOR_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_x1_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.e_x1,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(UserSelections.lim_x2))
    if(newval==UserSelections.lim_x2)
        newval=newval-10^-16; UserSelections.lim_x2=UserSelections.lim_x2+10^-16;
    elseif(newval>UserSelections.lim_x2)
        TEMP=UserSelections.lim_x2;
        UserSelections.lim_x2=newval;
        newval=TEMP;
        set(handles.e_x2,'string',num2str(UserSelections.lim_x2));
        set(handles.e_x1,'string',num2str(newval));
    end 
end
UserSelections.lim_x1=newval;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_x1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_x2_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.e_x2,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(UserSelections.lim_x1))
    if(newval==UserSelections.lim_x1)
        newval=newval+10^-16; UserSelections.lim_x1=UserSelections.lim_x1-10^-16;
    elseif(newval<UserSelections.lim_x1)
        TEMP=UserSelections.lim_x1;
        UserSelections.lim_x1=newval;
        newval=TEMP;
        set(handles.e_x1,'string',num2str(UserSelections.lim_x1));
        set(handles.e_x2,'string',num2str(newval));
    end 
end
UserSelections.lim_x2=newval;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_x2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_x2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_autoX.
function b_autoX_Callback(hObject, eventdata, handles)
current=get(handles.b_autoX,'backgroundcolor');
UserSelections=get(handles.Requested,'Userdata');
if(sum(current==handles.ColorON)==3)
    set(handles.b_autoX,'backgroundcolor',handles.ColorIdle);
    UserSelections.b_autoX=0;
else
    set(handles.b_autoX,'backgroundcolor',handles.ColorON); 
    UserSelections.b_autoX=1;
end
set(handles.Requested,'Userdata',UserSelections);

function e_binsx_Callback(hObject, eventdata, handles)
binsx=str2double(get(handles.e_binsy,'string'));
UserSelections=get(handles.Requested,'Userdata');
if(isnan(binsx) || isinf(binsx) || (binsx>500) || (binsx<3))
    binsx=10; set(handles.e_binsy,'string','10'); 
else
    binsx=round(binsx);
end
UserSelections.binsx=binsx;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_binsx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_binsy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_logbookandsave.
function t_logbookandsave_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.logbook_and_save=1;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes on button press in t_LogbookLite.
function t_LogbookLite_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.logbook_only=1;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes on button press in TOM.
function TOM_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.MomentsON=get(handles.TOM,'value');
set(handles.Requested,'Userdata',UserSelections);


% --- Executes on button press in SMP.
function SMP_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.MomentsON=get(handles.SMP,'value');
set(handles.Requested,'Userdata',UserSelections);

% --- Executes on selection change in TypeOfPlot.
function TypeOfPlot_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.TypeOfPlot=get(handles.TypeOfPlot,'value');
if(UserSelections.TypeOfPlot==1)
   COLORBAR= colorbar('peer',handles.axes1);
   set(handles.text46,'userdata',COLORBAR);
   set(handles.axes4,'visible','on')
   set(handles.InfoData,'visible','off')
   set(handles.e_Partition,'visible','off');
   set(handles.e_PartitionWidth,'visible','off');
else
   CBP=get(handles.text46,'userdata');
   if(ishandle(CBP))
        set(handles.text46,'userdata',NaN);
        colorbar(CBP,'delete')
   end
   set(handles.axes4,'visible','off')
   set(handles.InfoData,'visible','on')
   set(handles.e_Partition,'visible','on');
   set(handles.e_PartitionWidth,'visible','on');
end
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function TypeOfPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypeOfPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in QuickFit.
function QuickFit_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.QuickFit=get(handles.QuickFit,'value');
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function QuickFit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QuickFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when entered data in editable cell(s) in TabellaY.
function TabellaY_CellEditCallback(hObject, eventdata, handles)
SDA=get(handles.StoredDataStructure,'userdata');
UserSelections=get(handles.Requested,'userdata');
TAB=get(handles.TabellaY,'data');

for II=1:handles.NumberOfAllowedY
   PF1 = find(strcmp(TAB{II,1},SDA.FilterNames));
   if(isempty(PF1))
       UserSelections.FILTERS(II,1)=0;
   else
       UserSelections.FILTERS(II,1)=PF1;
   end
   PF2 = find(strcmp(TAB{II,2},SDA.FilterNames));
   if(isempty(PF2))
       UserSelections.FILTERS(II,2)=0;
   else
       UserSelections.FILTERS(II,2)=PF2;
   end
   QTY = find(strcmp(TAB{II,3},SDA.ScalarNames));
   if(isempty(QTY))
       UserSelections.Y_SEL(II,:)=[0,0,0];
   else
       UserSelections.Y_SEL(II,:)=SDA.ScalarWhereToBeFound(QTY,:);
   end
   UserSelections.Styl{II}=TAB{II,4}; 
end
set(handles.Requested,'userdata',UserSelections);


% --- Executes on button press in SHOW.
function SHOW_Callback(hObject, eventdata, handles)
cd=get(handles.Requested,'Userdata')


% --- Executes on selection change in SCALAR_SEL.
function SCALAR_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StoredDataStructure,'userdata');
VAL=get(handles.SCALAR_SEL,'value');
UserSelections=get(handles.Requested,'Userdata');
if(VAL==1)
   UserSelections.SCALAR_SEL=[0,0,0];
else
   UserSelections.SCALAR_SEL=SDA.ScalarWhereToBeFound(VAL-1,:);
end
set(handles.Requested,'userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function SCALAR_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SCALAR_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Z_SEL.
function Z_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StoredDataStructure,'userdata');
VAL=get(handles.Z_SEL,'value');
UserSelections=get(handles.Requested,'Userdata');
if(VAL==1)
   UserSelections.Z_SEL=[0,0,0];
else
   UserSelections.Z_SEL=SDA.ScalarWhereToBeFound(VAL-1,:);
end
set(handles.Requested,'userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function Z_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_autoZ.
function b_autoZ_Callback(hObject, eventdata, handles)
current=get(handles.b_autoZ,'backgroundcolor');
UserSelections=get(handles.Requested,'Userdata');
if(sum(current==handles.ColorON)==3)
    set(handles.b_autoZ,'backgroundcolor',handles.ColorIdle);
    UserSelections.b_autoZ=0;
else
    set(handles.b_autoZ,'backgroundcolor',handles.ColorON); 
    UserSelections.b_autoZ=1;
end
set(handles.Requested,'Userdata',UserSelections);



function e_z1_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.e_z1,'string'));
if(isinf(newval)), newval=NaN; end
if(~isnan(newval) && ~isnan(UserSelections.lim_z2))
    if(newval==UserSelections.lim_z2)
        newval=newval-10^-16; UserSelections.lim_z2=UserSelections.lim_z2+10^-16;
    elseif(newval>UserSelections.lim_z2)
        TEMP=UserSelections.lim_z2;
        UserSelections.lim_z2=newval;
        newval=TEMP;
        set(handles.e_z2,'string',num2str(UserSelections.lim_z2));
        set(handles.e_z1,'string',num2str(newval));
    end 
end
UserSelections.lim_z1=newval;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function e_z1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_z1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_z2_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.e_z2,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(UserSelections.lim_z1))
    if(newval==UserSelections.lim_z1)
        newval=newval+10^-16; UserSelections.lim_z1=UserSelections.lim_z1-10^-16;
    elseif(newval<UserSelections.lim_z1)
        TEMP=UserSelections.lim_z1;
        UserSelections.lim_z1=newval;
        newval=TEMP;
        set(handles.e_z1,'string',num2str(UserSelections.lim_z1));
        set(handles.e_z2,'string',num2str(newval));
    end 
end
UserSelections.lim_z2=newval;
set(handles.Requested,'Userdata',UserSelections);



% --- Executes during object creation, after setting all properties.
function e_z2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_z2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Filter1.
function Filter1_Callback(hObject, eventdata, handles)
VAL=get(handles.Filter1,'value');
UserSelections=get(handles.Requested,'Userdata');
UserSelections.FILTERS(1)=VAL-1;
set(handles.Requested,'userdata',UserSelections);





% --- Executes during object creation, after setting all properties.
function Filter1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Filter.
function Filter_Callback(hObject, eventdata, handles)
VAL=get(handles.Filter,'value');
UserSelections=get(handles.Requested,'Userdata');
UserSelections.FILTERS=VAL-1;
set(handles.Requested,'userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function Filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowAverageON.
function ShowAverageON_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.ShowAVGLASTON=get(handles.ShowAverageON,'value');
set(handles.Requested,'Userdata',UserSelections);
%set(handles.RT,'data',handles.BLANKRT);



function plot2style_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=(get(handles.plot2style,'string'));
try 
    plot(handles.axes2,1,1,newval);
    UserSelections.plot2style=newval;
    set(handles.axes2,'visible','off');
catch 
    set(handles.plot2style,'string',UserSelections.plot2style);
end
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function plot2style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot2style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowSingles.
function ShowSingles_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.ShowLASTON=get(handles.ShowSingles,'value');
set(handles.Requested,'Userdata',UserSelections);
set(handles.RT,'data',handles.BLANKRT);



function plot3style_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=(get(handles.plot3style,'string'));
try 
    plot(handles.axes2,1,1,newval);
    UserSelections.plot3style=newval;
    set(handles.axes2,'visible','off');
catch 
    set(handles.plot3style,'string',UserSelections.plot3style);
end
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function plot3style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot3style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plot2lw_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.plot2lw,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
if(newval<1), newval=1; set(handles.plot2lw,'string',num2str(newval));end
UserSelections.plot2lw=newval;
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function plot2lw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot2lw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plot3lw_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.plot3lw,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
if(newval<1), newval=1; set(handles.plot3lw,'string',num2str(newval));end
UserSelections.plot3lw=newval;
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function plot3lw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot3lw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TOFWHM.
function TOFWHM_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.FWHMON=get(handles.TOFWHM,'value');
set(handles.Requested,'Userdata',UserSelections);


% --- Executes on button press in TOPEAK.
function TOPEAK_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.PEAKON=get(handles.TOPEAK,'value');
set(handles.Requested,'Userdata',UserSelections);


function HMAVG_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.HMAVG,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
newval=round(newval);
if(newval<1), newval=1; set(handles.HMAVG,'string',num2str(newval));end
UserSelections.HMAVG=newval;
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function HMAVG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HMAVG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Show_AVG.
function Show_AVG_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.ShowAVGON=get(handles.Show_AVG,'value');
set(handles.Requested,'Userdata',UserSelections);
set(handles.RT,'data',handles.BLANKRT);


function HMSingles_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.HMSingles,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
newval=round(newval);
if(newval<1), newval=1; set(handles.HMSingles,'string',num2str(newval));end
UserSelections.HMSingles=newval;
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function HMSingles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HMSingles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plot1style_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=(get(handles.plot1style,'string'));
try 
    plot(handles.axes2,1,1,newval);
    set(handles.axes2,'visible','off');
    UserSelections.plot1style=newval;
catch 
    set(handles.plot1style,'string',UserSelections.plot1style);
end
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function plot1style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot1style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function plot1lw_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.plot1lw,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
if(newval<1), newval=1; set(handles.plot1lw,'string',num2str(newval));end
UserSelections.plot1lw=newval;
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function plot1lw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot1lw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CalibLinear_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.CalibLinear,'string'));
if(isinf(newval)), newval=[]; set(handles.CalibLinear,'string',''); end
if(isnan(newval)), newval=[]; set(handles.CalibLinear,'string','');end
if(newval==0), newval=[]; set(handles.CalibLinear,'string',''); end
UserSelections.calib=newval;
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function CalibLinear_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalibLinear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CalibCenter_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.CalibCenter,'string'));
if(isinf(newval)), newval=[]; set(handles.CalibCenter,'string',''); end
if(isnan(newval)), newval=[]; set(handles.CalibCenter,'string','');end
UserSelections.center=newval;
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function CalibCenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CalibCenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UseCalibration.
function UseCalibration_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.UseCalibration=get(handles.UseCalibration,'value');
set(handles.Requested,'Userdata',UserSelections);


function S1MASK_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2num(get(handles.S1MASK,'string'));
if(numel(newval)~=2)
   set(handles.S1MASK,'string',['[',num2str(UserSelections.S1MASK(1)) ,',',num2str(UserSelections.S1MASK(2)) ,']']);
   return
end
newval=round(newval);
if(any(isinf(newval)) || any(isnan(newval)) || (newval(2)<newval(1)) || newval(1)<1 )
   set(handles.S1MASK,'string',['[',num2str(UserSelections.S1MASK(1)) ,',',num2str(UserSelections.S1MASK(2)) ,']']);
   return
end
UserSelections.S1MASK=newval;
set(handles.S1MASK,'string',['[',num2str(UserSelections.S1MASK(1)) ,',',num2str(UserSelections.S1MASK(2)) ,']']);
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function S1MASK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to S1MASK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in S1.
function S1_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.S1=get(handles.S1,'value');
set(handles.Requested,'Userdata',UserSelections);
set(handles.STABLE,'data',handles.BLANKS);


% --- Executes on button press in S2.
function S2_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.S2=get(handles.S2,'value');
set(handles.Requested,'Userdata',UserSelections);
set(handles.STABLE,'data',handles.BLANKS);

% --- Executes on button press in S3.
function S3_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.S3=get(handles.S3,'value');
set(handles.Requested,'Userdata',UserSelections);
set(handles.STABLE,'data',handles.BLANKS);

function S2MASK_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2num(get(handles.S2MASK,'string'));
if(numel(newval)~=2)
   set(handles.S2MASK,'string',['[',num2str(UserSelections.S2MASK(1)) ,',',num2str(UserSelections.S2MASK(2)) ,']']);
   return
end
newval=round(newval);
if(any(isinf(newval)) || any(isnan(newval)) || (newval(2)<newval(1)) || newval(1)<1 )
   set(handles.S2MASK,'string',['[',num2str(UserSelections.S2MASK(1)) ,',',num2str(UserSelections.S2MASK(2)) ,']']);
   return
end
UserSelections.S2MASK=newval;
set(handles.S2MASK,'string',['[',num2str(UserSelections.S2MASK(1)) ,',',num2str(UserSelections.S2MASK(2)) ,']']);
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function S2MASK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to S2MASK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function S3MASK_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2num(get(handles.S3MASK,'string'));
if(numel(newval)~=2)
   set(handles.S3MASK,'string',['[',num2str(UserSelections.S3MASK(1)) ,',',num2str(UserSelections.S3MASK(2)) ,']']);
   return
end
newval=round(newval);
if(any(isinf(newval)) || any(isnan(newval)) || (newval(2)<newval(1)) || newval(1)<1 )
   set(handles.S3MASK,'string',['[',num2str(UserSelections.S3MASK(1)) ,',',num2str(UserSelections.S3MASK(2)) ,']']);
   return
end
UserSelections.S3MASK=newval;
set(handles.S3MASK,'string',['[',num2str(UserSelections.S3MASK(1)) ,',',num2str(UserSelections.S3MASK(2)) ,']']);
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function S3MASK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to S3MASK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PlotType.
function PlotType_Callback(hObject, eventdata, handles)
% hObject    handle to PlotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlotType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlotType


% --- Executes during object creation, after setting all properties.
function PlotType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in InfoData.
function InfoData_Callback(hObject, eventdata, handles)
% hObject    handle to InfoData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns InfoData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InfoData


% --- Executes during object creation, after setting all properties.
function InfoData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_Partition_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2num(get(handles.e_Partition,'string'));
if(any(isinf(newval))), newval=NaN; end
if(~any(isnan(newval)))
    UserSelections.PartitionPos=newval;
end
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function e_Partition_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_Partition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_PartitionWidth_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2num(get(handles.e_PartitionWidth,'string'));
if(any(isinf(newval))), newval=NaN; end
if(~any(isnan(newval)))
    UserSelections.PartitionWidth=newval;
end
set(handles.Requested,'Userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function e_PartitionWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_PartitionWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function X_PID_DELAY_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
newval=str2double(get(handles.X_PID_DELAY,'string'));
if(isinf(newval)), newval=0; end
if(isnan(newval)), newval=0; end
UserSelections.X_PID_DELAY=round(newval);
set(handles.X_PID_DELAY,'string',int2str(UserSelections.X_PID_DELAY));
set(handles.Requested,'Userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function X_PID_DELAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_PID_DELAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IMAGE_SEL.
function IMAGE_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StoredDataStructure,'userdata');
VAL=get(handles.IMAGE_SEL,'value');
UserSelections=get(handles.Requested,'Userdata');
if(VAL==1)
   UserSelections.IMAGE_SEL=[0,0];
else
   UserSelections.IMAGE_SEL=[VAL-1,SDA.Position_of_2Darrays_in_Profiles(VAL-1)];
end
set(handles.Requested,'userdata',UserSelections);

% --- Executes during object creation, after setting all properties.
function IMAGE_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IMAGE_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.SaveOnLocalFolder=1;
set(handles.Requested,'userdata',UserSelections);


% --- Executes on button press in TurnON.
function TurnON_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.ON=1;
set(handles.TurnON,'backgroundcolor',handles.ColorON);
set(handles.Requested,'userdata',UserSelections);

% --- Executes on button press in TurnOFF.
function TurnOFF_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.ON=0;
set(handles.TurnOFF,'backgroundcolor',handles.ColorON)
set(handles.Requested,'userdata',UserSelections);



function FN_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.FN=get(handles.FN,'string');
set(handles.Requested,'userdata',UserSelections);


% --- Executes during object creation, after setting all properties.
function FN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeOut_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.TimeOut=str2num(get(handles.TimeOut,'string'));
if(UserSelections.TimeOut<5)
   set(handles.TimeOut,'string','5');
   UserSelections.TimeOut=5;
end
set(handles.Requested,'userdata',UserSelections);



% --- Executes during object creation, after setting all properties.
function TimeOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ForceSaving.
function ForceSaving_Callback(hObject, eventdata, handles)
UserSelections=get(handles.Requested,'Userdata');
UserSelections.ForceSaving=1;
set(handles.ForceSaving,'backgroundcolor',handles.ColorON)
set(handles.Requested,'userdata',UserSelections);
