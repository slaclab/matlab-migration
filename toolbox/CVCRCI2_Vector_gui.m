function varargout = CVCRCI2_Vector_gui(varargin)
% CVCRCI2_VECTOR_GUI MATLAB code for CVCRCI2_Vector_gui.fig
%      CVCRCI2_VECTOR_GUI, by itself, creates a new CVCRCI2_VECTOR_GUI or raises the existing
%      singleton*.
%
%      H = CVCRCI2_VECTOR_GUI returns the handle to a new CVCRCI2_VECTOR_GUI or the handle to
%      the existing singleton*.
%
%      CVCRCI2_VECTOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI2_VECTOR_GUI.M with the given input arguments.
%
%      CVCRCI2_VECTOR_GUI('Property','Value',...) creates a new CVCRCI2_VECTOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI2_Vector_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI2_Vector_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI2_Vector_gui

% Last Modified by GUIDE v2.5 23-Apr-2015 16:05:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI2_Vector_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI2_Vector_gui_OutputFcn, ...
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


% --- Executes just before CVCRCI2_Vector_gui is made visible.
function CVCRCI2_Vector_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI2_Vector_gui (see VARARGIN)

% Choose default command line output for CVCRCI2_Vector_gui
handles.output = hObject;
handles.ColorON=[0,1,0];
handles.ColorIdle=[.7,.7,.7];
handles.ColorWait=[1,1,0];
set(handles.b_autoX,'backgroundcolor',handles.ColorON);
set(handles.b_autoY,'backgroundcolor',handles.ColorON);
petizione.lim_x1=NaN;
petizione.lim_x2=NaN;
petizione.lim_y1=NaN;
petizione.lim_y2=NaN;
handles.BLANKRT={};
for II=1:5
    for JJ=1:2
        handles.BLANKRT{II,JJ}=[];
    end
end
handles.BLANKS={};
for II=1:3
    for JJ=1:3
        handles.BLANKS{II,JJ}=[];
    end
end
petizione.calib=[];
petizione.center=[];
petizione.MomentsON=0;
petizione.FWHMON=0;
petizione.PEAKON=0;
petizione.ShowAVGON=0;
petizione.ShowAVGLASTON=0;
petizione.ShowLASTON=1;
petizione.HMAVG=100;
petizione.HMSingles=1;
petizione.plot1style='-k';
petizione.plot2style='-r';
petizione.plot3style='-b';
petizione.plot1lw=1;
petizione.plot2lw=1;
petizione.plot3lw=1;
petizione.UseCalibration=0;
petizione.S1=0;
petizione.S2=0;
petizione.S3=0;
petizione.S1MASK=[1,1024];
petizione.S2MASK=[1,1024];
petizione.S3MASK=[1,1024];
set(handles.S3MASK,'string',['[',num2str(petizione.S3MASK(1)) ,',',num2str(petizione.S3MASK(2)) ,']']);
set(handles.S2MASK,'string',['[',num2str(petizione.S2MASK(1)) ,',',num2str(petizione.S2MASK(2)) ,']']);
set(handles.S1MASK,'string',['[',num2str(petizione.S1MASK(1)) ,',',num2str(petizione.S1MASK(2)) ,']']);
    

petizione.V_SEL=[0,0,0];
petizione.Filtri=[0,0];
petizione.b_autoX=1;
petizione.b_autoY=1;

petizione.logbook_and_save=0;
petizione.logbook_only=0;
set(handles.IdatiStanQua,'userdata',petizione);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVCRCI2_Vector_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI2_Vector_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function e_binsy_Callback(hObject, eventdata, handles)
binsy=str2double(get(handles.e_binsy,'string'));
petizione=get(handles.IdatiStanQua,'Userdata');
if(isnan(binsy) || isinf(binsy) || (binsy>500) || (binsy<3))
    binsy=10; set(handles.e_binsy,'string','10'); 
else
    binsy=round(binsy);
end
petizione.binsy=binsy;
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
if(sum(current==handles.ColorON)==3)
    set(handles.b_autoY,'backgroundcolor',handles.ColorIdle);
    petizione.b_autoY=0;
else
    set(handles.b_autoY,'backgroundcolor',handles.ColorON); 
    petizione.b_autoY=1;
end
set(handles.IdatiStanQua,'Userdata',petizione);


function e_y1_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.e_y1,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(petizione.lim_y2))
    if(newval==petizione.lim_y2)
        newval=newval-10^-16; petizione.lim_y2=petizione.lim_y2+10^-16;
    elseif(newval>petizione.lim_y2)
        TEMP=petizione.lim_y2;
        petizione.lim_y2=newval;
        newval=TEMP;
        set(handles.e_y2,'string',num2str(petizione.lim_y2));
        set(handles.e_y1,'string',num2str(newval));
    end 
end
petizione.lim_y1=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.e_y2,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(petizione.lim_y1))
    if(newval==petizione.lim_y1)
        newval=newval+10^-16; petizione.lim_y1=petizione.lim_y1-10^-16;
    elseif(newval<petizione.lim_y1)
        TEMP=petizione.lim_y1;
        petizione.lim_y1=newval;
        newval=TEMP;
        set(handles.e_y1,'string',num2str(petizione.lim_y1));
        set(handles.e_y2,'string',num2str(newval));
    end 
end
petizione.lim_y2=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

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


% --- Executes on selection change in V_SEL.
function V_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StrutturaDatiAttuale,'userdata');
VAL=get(handles.V_SEL,'value');
petizione=get(handles.IdatiStanQua,'Userdata');
if(VAL==1)
   petizione.V_SEL=[0,0];
else
   petizione.V_SEL=[VAL-1,SDA.Position_of_vectors_in_Profiles(VAL-1)];
end
set(handles.IdatiStanQua,'userdata',petizione);

% --- Executes during object creation, after setting all properties.
function V_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to V_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_x1_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.e_x1,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(petizione.lim_x2))
    if(newval==petizione.lim_x2)
        newval=newval-10^-16; petizione.lim_x2=petizione.lim_x2+10^-16;
    elseif(newval>petizione.lim_x2)
        TEMP=petizione.lim_x2;
        petizione.lim_x2=newval;
        newval=TEMP;
        set(handles.e_x2,'string',num2str(petizione.lim_x2));
        set(handles.e_x1,'string',num2str(newval));
    end 
end
petizione.lim_x1=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.e_x2,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(petizione.lim_x1))
    if(newval==petizione.lim_x1)
        newval=newval+10^-16; petizione.lim_x1=petizione.lim_x1-10^-16;
    elseif(newval<petizione.lim_x1)
        TEMP=petizione.lim_x1;
        petizione.lim_x1=newval;
        newval=TEMP;
        set(handles.e_x1,'string',num2str(petizione.lim_x1));
        set(handles.e_x2,'string',num2str(newval));
    end 
end
petizione.lim_x2=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
if(sum(current==handles.ColorON)==3)
    set(handles.b_autoX,'backgroundcolor',handles.ColorIdle);
    petizione.b_autoX=0;
else
    set(handles.b_autoX,'backgroundcolor',handles.ColorON); 
    petizione.b_autoX=1;
end
set(handles.IdatiStanQua,'Userdata',petizione);

function e_binsx_Callback(hObject, eventdata, handles)
binsx=str2double(get(handles.e_binsx,'string'));
petizione=get(handles.IdatiStanQua,'Userdata');
if(isnan(binsx) || isinf(binsx) || (binsx>500) || (binsx<3))
    binsx=10; set(handles.e_binsx,'string','10'); 
else
    binsx=round(binsx);
end
petizione.binsx=binsx;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function e_binsx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_binsx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in t_logbookandsave.
function t_logbookandsave_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.logbook_and_save=1;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes on button press in t_LogbookLite.
function t_LogbookLite_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.logbook_only=1;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes on button press in TOM.
function TOM_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.MomentsON=get(handles.TOM,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes on button press in SMP.
function SMP_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.MomentsON=get(handles.SMP,'value');
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes on selection change in TypeOfPlot.
function TypeOfPlot_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.TypeOfPlot=get(handles.TypeOfPlot,'value');
if(petizione.TypeOfPlot==1)
   CBP=get(handles.text7,'userdata');
   if(ishandle(CBP))
        set(handles.text7,'userdata',NaN);
        colorbar(CBP,'delete')
   end   
else
   COLORBAR= colorbar('peer',handles.axes1);
   set(handles.text7,'userdata',COLORBAR);
end
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.QuickFit=get(handles.QuickFit,'value');
set(handles.IdatiStanQua,'Userdata',petizione);

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
SDA=get(handles.StrutturaDatiAttuale,'userdata');
petizione=get(handles.IdatiStanQua,'userdata');
TAB=get(handles.TabellaY,'data');

for II=1:handles.NumberOfAllowedY
   PF1 = find(strcmp(TAB{II,1},SDA.FilterNames));
   if(isempty(PF1))
       petizione.Filtri(II,1)=0;
   else
       petizione.Filtri(II,1)=PF1;
   end
   PF2 = find(strcmp(TAB{II,2},SDA.FilterNames));
   if(isempty(PF2))
       petizione.Filtri(II,2)=0;
   else
       petizione.Filtri(II,2)=PF2;
   end
   QTY = find(strcmp(TAB{II,3},SDA.ScalarNames));
   if(isempty(QTY))
       petizione.Y_SEL(II,:)=[0,0,0];
   else
       petizione.Y_SEL(II,:)=SDA.ScalarWhereToBeFound(QTY,:);
   end
   petizione.Styl{II}=TAB{II,4}; 
end
set(handles.IdatiStanQua,'userdata',petizione);


% --- Executes on button press in STOP_UPDATING.
function STOP_UPDATING_Callback(hObject, eventdata, handles)
cd=get(handles.IdatiStanQua,'Userdata')
cd.Y_SEL
cd.Filtri


% --- Executes on selection change in Y_SEL.
function Y_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StrutturaDatiAttuale,'userdata');
VAL=get(handles.Y_SEL,'value');
petizione=get(handles.IdatiStanQua,'Userdata');
if(VAL==1)
   petizione.Y_SEL=[0,0,0];
else
   petizione.Y_SEL=SDA.ScalarWhereToBeFound(VAL-1,:);
end
set(handles.IdatiStanQua,'userdata',petizione);

% --- Executes during object creation, after setting all properties.
function Y_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_SEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Z_SEL.
function Z_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StrutturaDatiAttuale,'userdata');
VAL=get(handles.Z_SEL,'value');
petizione=get(handles.IdatiStanQua,'Userdata');
if(VAL==1)
   petizione.Z_SEL=[0,0,0];
else
   petizione.Z_SEL=SDA.ScalarWhereToBeFound(VAL-1,:);
end
set(handles.IdatiStanQua,'userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
if(sum(current==handles.ColorON)==3)
    set(handles.b_autoZ,'backgroundcolor',handles.ColorIdle);
    petizione.b_autoZ=0;
else
    set(handles.b_autoZ,'backgroundcolor',handles.ColorON); 
    petizione.b_autoZ=1;
end
set(handles.IdatiStanQua,'Userdata',petizione);



function e_z1_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.e_z1,'string'));
if(isinf(newval)), newval=NaN; end
if(~isnan(newval) && ~isnan(petizione.lim_z2))
    if(newval==petizione.lim_z2)
        newval=newval-10^-16; petizione.lim_z2=petizione.lim_z2+10^-16;
    elseif(newval>petizione.lim_z2)
        TEMP=petizione.lim_z2;
        petizione.lim_z2=newval;
        newval=TEMP;
        set(handles.e_z2,'string',num2str(petizione.lim_z2));
        set(handles.e_z1,'string',num2str(newval));
    end 
end
petizione.lim_z1=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.e_z2,'string'));
if(isinf(newval)), newval=NaN; , end
if(~isnan(newval) && ~isnan(petizione.lim_z1))
    if(newval==petizione.lim_z1)
        newval=newval+10^-16; petizione.lim_z1=petizione.lim_z1-10^-16;
    elseif(newval<petizione.lim_z1)
        TEMP=petizione.lim_z1;
        petizione.lim_z1=newval;
        newval=TEMP;
        set(handles.e_z1,'string',num2str(petizione.lim_z1));
        set(handles.e_z2,'string',num2str(newval));
    end 
end
petizione.lim_z2=newval;
set(handles.IdatiStanQua,'Userdata',petizione);



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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Filtri(1)=VAL-1;
set(handles.IdatiStanQua,'userdata',petizione);





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


% --- Executes on selection change in Filter2.
function Filter2_Callback(hObject, eventdata, handles)
VAL=get(handles.Filter2,'value');
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Filtri(2)=VAL-1;
set(handles.IdatiStanQua,'userdata',petizione);

% --- Executes during object creation, after setting all properties.
function Filter2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowAverageON.
function ShowAverageON_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ShowAVGLASTON=get(handles.ShowAverageON,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
set(handles.RT,'data',handles.BLANKRT);



function plot2style_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=(get(handles.plot2style,'string'));
try 
    plot(handles.axes2,1,1,newval);
    petizione.plot2style=newval;
    set(handles.axes2,'visible','off');
catch 
    set(handles.plot2style,'string',petizione.plot2style);
end
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ShowLASTON=get(handles.ShowSingles,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
set(handles.RT,'data',handles.BLANKRT);



function plot3style_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=(get(handles.plot3style,'string'));
try 
    plot(handles.axes2,1,1,newval);
    petizione.plot3style=newval;
    set(handles.axes2,'visible','off');
catch 
    set(handles.plot3style,'string',petizione.plot3style);
end
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.plot2lw,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
if(newval<1), newval=1; set(handles.plot2lw,'string',num2str(newval));end
petizione.plot2lw=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.plot3lw,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
if(newval<1), newval=1; set(handles.plot3lw,'string',num2str(newval));end
petizione.plot3lw=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.FWHMON=get(handles.TOFWHM,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes on button press in TOPEAK.
function TOPEAK_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.PEAKON=get(handles.TOPEAK,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


function HMAVG_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.HMAVG,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
newval=round(newval);
if(newval<1), newval=1; set(handles.HMAVG,'string',num2str(newval));end
petizione.HMAVG=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ShowAVGON=get(handles.Show_AVG,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
set(handles.RT,'data',handles.BLANKRT);


function HMSingles_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.HMSingles,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
newval=round(newval);
if(newval<1), newval=1; set(handles.HMSingles,'string',num2str(newval));end
petizione.HMSingles=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=(get(handles.plot1style,'string'));
try 
    plot(handles.axes2,1,1,newval);
    set(handles.axes2,'visible','off');
    petizione.plot1style=newval;
catch 
    set(handles.plot1style,'string',petizione.plot1style);
end
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.plot1lw,'string'));
if(isinf(newval)), newval=1; end
if(isnan(newval)), newval=1; end
if(newval<1), newval=1; set(handles.plot1lw,'string',num2str(newval));end
petizione.plot1lw=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.CalibLinear,'string'));
if(isinf(newval)), newval=[]; set(handles.CalibLinear,'string',''); end
if(isnan(newval)), newval=[]; set(handles.CalibLinear,'string','');end
if(newval==0), newval=[]; set(handles.CalibLinear,'string',''); end
petizione.calib=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.CalibCenter,'string'));
if(isinf(newval)), newval=[]; set(handles.CalibCenter,'string',''); end
if(isnan(newval)), newval=[]; set(handles.CalibCenter,'string','');end
petizione.center=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.UseCalibration=get(handles.UseCalibration,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


function S1MASK_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2num(get(handles.S1MASK,'string'));
if(numel(newval)~=2)
   set(handles.S1MASK,'string',['[',num2str(petizione.S1MASK(1)) ,',',num2str(petizione.S1MASK(2)) ,']']);
   return
end
newval=round(newval);
if(any(isinf(newval)) || any(isnan(newval)) || (newval(2)<newval(1)) || newval(1)<1 )
   set(handles.S1MASK,'string',['[',num2str(petizione.S1MASK(1)) ,',',num2str(petizione.S1MASK(2)) ,']']);
   return
end
petizione.S1MASK=newval;
set(handles.S1MASK,'string',['[',num2str(petizione.S1MASK(1)) ,',',num2str(petizione.S1MASK(2)) ,']']);
set(handles.IdatiStanQua,'Userdata',petizione);

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
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.S1=get(handles.S1,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
set(handles.STABLE,'data',handles.BLANKS);


% --- Executes on button press in S2.
function S2_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.S2=get(handles.S2,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
set(handles.STABLE,'data',handles.BLANKS);

% --- Executes on button press in S3.
function S3_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.S3=get(handles.S3,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
set(handles.STABLE,'data',handles.BLANKS);

function S2MASK_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2num(get(handles.S2MASK,'string'));
if(numel(newval)~=2)
   set(handles.S2MASK,'string',['[',num2str(petizione.S2MASK(1)) ,',',num2str(petizione.S2MASK(2)) ,']']);
   return
end
newval=round(newval);
if(any(isinf(newval)) || any(isnan(newval)) || (newval(2)<newval(1)) || newval(1)<1 )
   set(handles.S2MASK,'string',['[',num2str(petizione.S2MASK(1)) ,',',num2str(petizione.S2MASK(2)) ,']']);
   return
end
petizione.S2MASK=newval;
set(handles.S2MASK,'string',['[',num2str(petizione.S2MASK(1)) ,',',num2str(petizione.S2MASK(2)) ,']']);
set(handles.IdatiStanQua,'Userdata',petizione);


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
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2num(get(handles.S3MASK,'string'));
if(numel(newval)~=2)
   set(handles.S3MASK,'string',['[',num2str(petizione.S3MASK(1)) ,',',num2str(petizione.S3MASK(2)) ,']']);
   return
end
newval=round(newval);
if(any(isinf(newval)) || any(isnan(newval)) || (newval(2)<newval(1)) || newval(1)<1 )
   set(handles.S3MASK,'string',['[',num2str(petizione.S3MASK(1)) ,',',num2str(petizione.S3MASK(2)) ,']']);
   return
end
petizione.S3MASK=newval;
set(handles.S3MASK,'string',['[',num2str(petizione.S3MASK(1)) ,',',num2str(petizione.S3MASK(2)) ,']']);
set(handles.IdatiStanQua,'Userdata',petizione);

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


% --- Executes on button press in AutoCalib.
function AutoCalib_Callback(hObject, eventdata, handles)
% hObject    handle to AutoCalib (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in WritePVs.
function WritePVs_Callback(hObject, eventdata, handles)
% hObject    handle to WritePVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of WritePVs
