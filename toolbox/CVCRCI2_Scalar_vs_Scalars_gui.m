function varargout = CVCRCI2_Scalar_vs_Scalars_gui(varargin)
% CVCRCI2_SCALAR_VS_SCALARS_GUI MATLAB code for CVCRCI2_Scalar_vs_Scalars_gui.fig
%      CVCRCI2_SCALAR_VS_SCALARS_GUI, by itself, creates a new CVCRCI2_SCALAR_VS_SCALARS_GUI or raises the existing
%      singleton*.
%
%      H = CVCRCI2_SCALAR_VS_SCALARS_GUI returns the handle to a new CVCRCI2_SCALAR_VS_SCALARS_GUI or the handle to
%      the existing singleton*.
%
%      CVCRCI2_SCALAR_VS_SCALARS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI2_SCALAR_VS_SCALARS_GUI.M with the given input arguments.
%
%      CVCRCI2_SCALAR_VS_SCALARS_GUI('Property','Value',...) creates a new CVCRCI2_SCALAR_VS_SCALARS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI2_Scalar_vs_Scalars_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI2_Scalar_vs_Scalars_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI2_Scalar_vs_Scalars_gui

% Last Modified by GUIDE v2.5 20-Mar-2015 19:50:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI2_Scalar_vs_Scalars_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI2_Scalar_vs_Scalars_gui_OutputFcn, ...
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


% --- Executes just before CVCRCI2_Scalar_vs_Scalars_gui is made visible.
function CVCRCI2_Scalar_vs_Scalars_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI2_Scalar_vs_Scalars_gui (see VARARGIN)

% Choose default command line output for CVCRCI2_Scalar_vs_Scalars_gui
handles.output = hObject;
handles.NumberOfAllowedY=3;
handles.ColorAndStyle={'.k','.r','.b','.m','.c','.g','.y'};
TABY=cell(handles.NumberOfAllowedY,6);
for II=1:handles.NumberOfAllowedY
    TABY{II,1}='No Filter';
    TABY{II,2}='No Filter';
    TABY{II,3}='PV1';
    TABY{II,4}=handles.ColorAndStyle{II};
    TABY{II,5}=zeros(1,0);
    TABY{II,6}=zeros(1,0);
end
set(handles.TabellaY,'data',TABY);
handles.ColorON=[0,1,0];
handles.ColorIdle=get(handles.b_autoY,'backgroundcolor');
handles.ColorWait=[1,1,0];
set(handles.b_autoY,'backgroundcolor',handles.ColorON);
set(handles.b_autoX,'backgroundcolor',handles.ColorON);
petizione.lim_y1=1;
petizione.lim_x1=1;
petizione.lim_y2=1024;
petizione.lim_x2=1024;
petizione.MomentsON=0;
petizione.ShowMoments=0;
petizione.binsy=50;
petizione.binsx=50;
petizione.TypeOfPlot=1;
petizione.QuickFit=1;
petizione.X_SEL=[0,0,0];
petizione.Y_SEL=zeros(handles.NumberOfAllowedY,3);
petizione.Filtri=zeros(handles.NumberOfAllowedY,2);
petizione.Styl=handles.ColorAndStyle(1:handles.NumberOfAllowedY);
petizione.b_autoX=1;
petizione.b_autoY=1;
petizione.logbook_and_save=0;
petizione.logbook_only=0;
petizione.X_PID_DELAY=0;
set(handles.IdatiStanQua,'userdata',petizione);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVCRCI2_Scalar_vs_Scalars_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI2_Scalar_vs_Scalars_gui_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in X_SEL.
function X_SEL_Callback(hObject, eventdata, handles)
SDA=get(handles.StrutturaDatiAttuale,'userdata');
VAL=get(handles.X_SEL,'value');
petizione=get(handles.IdatiStanQua,'Userdata');
if(VAL==1)
   petizione.X_SEL=[0,0,0];
else
   petizione.X_SEL=SDA.ScalarWhereToBeFound(VAL-1,:);
end
set(handles.IdatiStanQua,'userdata',petizione);

% --- Executes during object creation, after setting all properties.
function X_SEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_SEL (see GCBO)
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
if((petizione.TypeOfPlot==1) || (petizione.TypeOfPlot==3) || (petizione.TypeOfPlot==4))
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
       petizione.Y_SEL(II,:)=SDA.ScalarWhereToBeFound(QTY(1),:);
   end
   petizione.Styl{II}=TAB{II,4}; 
end
set(handles.IdatiStanQua,'userdata',petizione);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
cd=get(handles.IdatiStanQua,'Userdata')
cd.Y_SEL
cd.Filtri



function X_PID_DELAY_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.X_PID_DELAY,'string'));
if(isinf(newval)), newval=0; end
if(isnan(newval)), newval=0; end
petizione.X_PID_DELAY=round(newval);
set(handles.X_PID_DELAY,'string',int2str(petizione.X_PID_DELAY));
set(handles.IdatiStanQua,'Userdata',petizione);


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
