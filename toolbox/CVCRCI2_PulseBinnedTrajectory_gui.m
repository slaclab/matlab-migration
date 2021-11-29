function varargout = CVCRCI2_PulseBinnedTrajectory_gui(varargin)
% CVCRCI2_PULSEBINNEDTRAJECTORY_GUI MATLAB code for CVCRCI2_PulseBinnedTrajectory_gui.fig
%      CVCRCI2_PULSEBINNEDTRAJECTORY_GUI, by itself, creates a new CVCRCI2_PULSEBINNEDTRAJECTORY_GUI or raises the existing
%      singleton*.
%
%      H = CVCRCI2_PULSEBINNEDTRAJECTORY_GUI returns the handle to a new CVCRCI2_PULSEBINNEDTRAJECTORY_GUI or the handle to
%      the existing singleton*.
%
%      CVCRCI2_PULSEBINNEDTRAJECTORY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVCRCI2_PULSEBINNEDTRAJECTORY_GUI.M with the given input arguments.
%
%      CVCRCI2_PULSEBINNEDTRAJECTORY_GUI('Property','Value',...) creates a new CVCRCI2_PULSEBINNEDTRAJECTORY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVCRCI2_PulseBinnedTrajectory_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVCRCI2_PulseBinnedTrajectory_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVCRCI2_PulseBinnedTrajectory_gui

% Last Modified by GUIDE v2.5 14-Apr-2015 14:46:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVCRCI2_PulseBinnedTrajectory_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @CVCRCI2_PulseBinnedTrajectory_gui_OutputFcn, ...
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


% --- Executes just before CVCRCI2_PulseBinnedTrajectory_gui is made visible.
function CVCRCI2_PulseBinnedTrajectory_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVCRCI2_PulseBinnedTrajectory_gui (see VARARGIN)

% Choose default command line output for CVCRCI2_PulseBinnedTrajectory_gui
handles.output = hObject;
handles.ColorON=[0,1,0];
handles.ColorIdle=[.7,.7,.7];
handles.ColorWait=[1,1,0];
%set(handles.b_autoY,'backgroundcolor',handles.ColorON);
set(handles.b_autoX,'backgroundcolor',handles.ColorON);
%set(handles.b_autoZ,'backgroundcolor',handles.ColorON);
%petizione.lim_y1=1;
petizione.lim_x1=0.05;
%petizione.lim_y2=1024;
petizione.lim_x2=7;
% petizione.lim_z1=1;
% petizione.lim_z2=1024;
petizione.Pulses=[1,2,23];
petizione.OUTPVS=0;
petizione.RELORBIT=1;
set(handles.TORELORBIT,'value',petizione.RELORBIT);
petizione.binsy=960;
petizione.binsx=0;
petizione.ErrorBars=0;
petizione.ErrorBarsOnAvg=0;
petizione.ShowTraj=0;
petizione.Frequency=2;
set(handles.Frequency,'value',2);
%petizione.binsz=50;
%petizione.TypeOfPlot=1;
petizione.X_SEL=[0,0,0];
% petizione.Y_SEL=[0,0,0];
% petizione.Z_SEL=[0,0,0];
%petizione.Filtri=[0,0];
petizione.b_autoX=1;
% petizione.b_autoY=1;
% petizione.b_autoZ=1;
petizione.logbook_and_save=0;
petizione.logbook_only=0;
petizione.FormulaErr=3;
set(handles.FormulaErr,'value',3);
petizione.TOLX=0.001;
petizione.TOLY=0.001;
petizione.TOL=0.001;
petizione.RejectLow=0.005;
set(handles.RejectLow,'string',num2str(petizione.RejectLow));
set(handles.eT1,'string',num2str(petizione.TOLX));
set(handles.eT2,'string',num2str(petizione.TOLY));
set(handles.eT3,'string',num2str(petizione.TOL));
% petizione.X_PID_DELAY=0;
% petizione.Y_PID_DELAY=0;
% petizione.Z_PID_DELAY=0;
set(handles.IdatiStanQua,'userdata',petizione);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVCRCI2_PulseBinnedTrajectory_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVCRCI2_PulseBinnedTrajectory_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function e_binsy_Callback(hObject, eventdata, handles)
binsy=str2double(get(handles.e_binsy,'string'));
petizione=get(handles.IdatiStanQua,'Userdata');
if(isnan(binsy) || isinf(binsy) || (binsy>500000) || (binsy<240))
    binsy=960; 
else
    binsy=round(binsy);
end

FREQ=get(handles.Frequency,'value');
%Pulses(Pulses<1)=[];
switch FREQ
    case 1 %1Hz
        MUL=120;
    case 2 %5Hz
        MUL=24;
    case 3 %10Hz
        MUL=12;
    case 4 %30Hz
        MUL=4;
    case 5 %60Hz
        MUL=2;
end
if(mod(binsy,MUL))
    binsy=binsy-mod(binsy,MUL);
end
set(handles.e_binsy,'string',num2str(binsy)); 
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
if(isnan(binsx) || isinf(binsx) || (binsx>500000) || (binsx<-500000))
    binsx=0;
else
    binsx=round(binsx);
end
FREQVAL=get(handles.Frequency,'value');
MAXPID=3*(120/FREQVAL);
binsx=mod(binsx,MAXPID+1);
if(mod(MAXPID,3)~=0)
   binsx=0;
end
binsx=mod(binsx,3);
set(handles.e_binsx,'string',num2str(binsx)); 
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
petizione.OUTPVS=get(handles.TOM,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes on button press in SMP.
function SMP_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.OUTPVS=get(handles.SMP,'value');
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
   COLORBAR= colorbar('peer',handles.axesX);
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


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
cd=get(handles.IdatiStanQua,'Userdata')


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



function Z_PID_DELAY_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.Z_PID_DELAY,'string'));
if(isinf(newval)), newval=0; end
if(isnan(newval)), newval=0; end
petizione.Z_PID_DELAY=round(newval);
set(handles.Z_PID_DELAY,'string',int2str(petizione.Z_PID_DELAY));
set(handles.IdatiStanQua,'Userdata',petizione);



% --- Executes during object creation, after setting all properties.
function Z_PID_DELAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z_PID_DELAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_PID_DELAY_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.Y_PID_DELAY,'string'));
if(isinf(newval)), newval=0; end
if(isnan(newval)), newval=0; end
petizione.Y_PID_DELAY=round(newval);
set(handles.Y_PID_DELAY,'string',int2str(petizione.Y_PID_DELAY));
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function Y_PID_DELAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_PID_DELAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ShowPulses_Callback(hObject, eventdata, handles)
Pulses=str2num(get(handles.ShowPulses,'string'));
petizione=get(handles.IdatiStanQua,'Userdata');
Pulses=round(Pulses)
Pulses=unique(Pulses,'stable')
FREQ=get(handles.Frequency,'value')
Pulses(Pulses<0)=[]
switch FREQ
    case 1 %1Hz
        MAXPULSE=119;
    case 2 %5Hz
        MAXPULSE=23;
    case 3 %10Hz
        MAXPULSE=11;
    case 4 %30Hz
        MAXPULSE=3;
    case 5 %60Hz
        MAXPULSE=1;
end
Pulses(Pulses>MAXPULSE)=[]
petizione.Pulses=Pulses
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function ShowPulses_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ShowPulses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TOME.
function TOME_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ErrorBars=get(handles.TOME,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes on button press in TOMEA.
function TOMEA_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ErrorBarsOnAvg=get(handles.TOMEA,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes on selection change in FormulaErr.
function FormulaErr_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.FormulaErr=get(handles.FormulaErr,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function FormulaErr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FormulaErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT1_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.eT1,'string'));
if(isinf(newval)), newval=inf; end
if(newval<0), newval=inf; end
if(isnan(newval)), newval=inf; end
set(handles.eT1,'string',num2str(newval));
petizione.TOLX=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function eT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT2_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.eT2,'string'));
if(isinf(newval)), newval=inf; end
if(newval<0), newval=inf; end
if(isnan(newval)), newval=inf; end
set(handles.eT2,'string',num2str(newval));
petizione.TOLY=newval;
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function eT2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eT3_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.eT3,'string'));
if(isinf(newval)), newval=inf; end
if(newval<0), newval=inf; end
if(isnan(newval)), newval=inf; end
set(handles.eT3,'string',num2str(newval));
petizione.TOL=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function eT3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eT3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TOMT.
function TOMT_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ShowTraj=get(handles.TOMT,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes on selection change in Frequency.
function Frequency_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Frequency=get(handles.Frequency,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function Frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function TOM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function RejectLow_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
newval=str2double(get(handles.RejectLow,'string'));
if(isinf(newval)), newval=inf; end
if(newval<0), newval=inf; end
if(isnan(newval)), newval=inf; end
set(handles.RejectLow,'string',num2str(newval));
petizione.RejectLow=newval;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function RejectLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RejectLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TORELORBIT.
function TORELORBIT_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.RELORBIT=get(handles.TORELORBIT,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
