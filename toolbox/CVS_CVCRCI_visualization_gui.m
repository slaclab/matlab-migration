function varargout = CVS_CVCRCI_visualization_gui(varargin)
% CVS_CVCRCI_VISUALIZATION_GUI MATLAB code for CVS_CVCRCI_visualization_gui.fig
%      CVS_CVCRCI_VISUALIZATION_GUI, by itself, creates a new CVS_CVCRCI_VISUALIZATION_GUI or raises the existing
%      singleton*.
%
%      H = CVS_CVCRCI_VISUALIZATION_GUI returns the handle to a new CVS_CVCRCI_VISUALIZATION_GUI or the handle to
%      the existing singleton*.
%
%      CVS_CVCRCI_VISUALIZATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CVS_CVCRCI_VISUALIZATION_GUI.M with the given input arguments.
%
%      CVS_CVCRCI_VISUALIZATION_GUI('Property','Value',...) creates a new CVS_CVCRCI_VISUALIZATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CVS_CVCRCI_visualization_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CVS_CVCRCI_visualization_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CVS_CVCRCI_visualization_gui

% Last Modified by GUIDE v2.5 30-Sep-2014 15:54:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CVS_CVCRCI_visualization_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @CVS_CVCRCI_visualization_gui_OutputFcn, ...
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


% --- Executes just before CVS_CVCRCI_visualization_gui is made visible.
function CVS_CVCRCI_visualization_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CVS_CVCRCI_visualization_gui (see VARARGIN)

% Choose default command line output for CVS_CVCRCI_visualization_gui
handles.output = hObject;

handles.ColorON=[0,1,0];
handles.ColorIdle=get(handles.b_autoY,'backgroundcolor');
handles.ColorWait=[1,1,0];
set(handles.b_autoY,'backgroundcolor',handles.ColorON);
set(handles.b_autoX,'backgroundcolor',handles.ColorON);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CVS_CVCRCI_visualization_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CVS_CVCRCI_visualization_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Y_SEL1.
function Y_SEL1_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Y_SEL1=get(handles.Y_SEL1,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function Y_SEL1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_SEL1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes on selection change in Y_SEL3.
function Y_SEL3_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Y_SEL3=get(handles.Y_SEL3,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function Y_SEL3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_SEL3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Y_SEL2.
function Y_SEL2_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Y_SEL2=get(handles.Y_SEL2,'value');
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function Y_SEL2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_SEL2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Filter1_menu.
function Filter1_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Filter1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filter1_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filter1_menu


% --- Executes during object creation, after setting all properties.
function Filter1_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Filter3_menu.
function Filter3_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Filter3_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filter3_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filter3_menu


% --- Executes during object creation, after setting all properties.
function Filter3_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter3_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Filter2_menu.
function Filter2_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Filter2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Filter2_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filter2_menu


% --- Executes during object creation, after setting all properties.
function Filter2_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filter2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in X_SEL.
function X_SEL_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.X_SEL=get(handles.X_SEL,'value');
set(handles.IdatiStanQua,'Userdata',petizione);


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


% --- Executes on button press in c_ShowAverage.
function c_ShowAverage_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ShowAverage=get(handles.c_ShowAverage,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
% outS.ShowOne=get(PointerToFigureObjArray(17),'value');
%     outS.ShowAverage=get(PointerToFigureObjArray(18),'value');
%     outS.OnScreen=get(PointerToFigureObjArray(19),'value');
%     outS.TrasformaFourier=get(PointerToFigureObjArray(20),'value');
%     outS.Calibration=str2num(get(PointerToFigureObjArray(21),'string'));


% --- Executes on button press in c_ShowOne.
function c_ShowOne_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.ShowOne=get(handles.c_ShowOne,'value');
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes on selection change in popf1.
function popf1_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Filt1=get(handles.popf1,'value')-1;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function popf1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popf1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popf3.
function popf3_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Filt3=get(handles.popf3,'value')-1;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function popf3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popf3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popf2.
function popf2_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.Filt2=get(handles.popf2,'value')-1;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function popf2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popf2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in c_Fourier.
function c_Fourier_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.TrasformaFourier=get(handles.c_Fourier,'value');
set(handles.IdatiStanQua,'Userdata',petizione);
% outS.ShowOne=get(PointerToFigureObjArray(17),'value');
%     outS.ShowAverage=get(PointerToFigureObjArray(18),'value');
%     outS.OnScreen=get(PointerToFigureObjArray(19),'value');
%     outS.TrasformaFourier=get(PointerToFigureObjArray(20),'value');
%     outS.Calibration=str2num(get(PointerToFigureObjArray(21),'string'));



function Calibration_Callback(hObject, eventdata, handles)
Cal=str2num(get(handles.Calibration,'string'));
petizione=get(handles.IdatiStanQua,'Userdata');
if(any(isinf(Cal)))
    Cal=NaN;
elseif(any(isnan(Cal)))
    Cal=NaN;
elseif(length(Cal)>2)
    Cal=NaN;
elseif(isempty(Cal))
    Cal=NaN;
elseif(Cal==0)
    Cal=NaN;
end
petizione.Calibration=Cal
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes during object creation, after setting all properties.
function Calibration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MoreProcessing.
function MoreProcessing_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
QuestoValore=get(handles.MoreProcessing,'value')-1;
if(~QuestoValore)
   set(handles.XT1,'visible','off'); set(handles.XT2,'visible','off'); set(handles.XT3,'visible','off'); set(handles.XT4,'visible','off'); 
   set(handles.XE1,'visible','off'); set(handles.XE2,'visible','off'); set(handles.XE3,'visible','off'); set(handles.XE4,'visible','off');  
end
petizione.SpecializedDisplay=QuestoValore;
set(handles.IdatiStanQua,'Userdata',petizione);


% --- Executes during object creation, after setting all properties.
function MoreProcessing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MoreProcessing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over IdatiStanQua.
function IdatiStanQua_ButtonDownFcn(hObject, eventdata, handles)

% --- Executes on button press in t_logbookandsave.
function t_logbookandsave_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.LogBookAndSave=1;
set(handles.IdatiStanQua,'Userdata',petizione);

% --- Executes on button press in t_LogbookLite.
function t_LogbookLite_Callback(hObject, eventdata, handles)
petizione=get(handles.IdatiStanQua,'Userdata');
petizione.LogBookOnlyFigure=1;
set(handles.IdatiStanQua,'Userdata',petizione);



function XE1_Callback(hObject, eventdata, handles)
% hObject    handle to XE1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XE1 as text
%        str2double(get(hObject,'String')) returns contents of XE1 as a double


% --- Executes during object creation, after setting all properties.
function XE1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XE1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XE2_Callback(hObject, eventdata, handles)
% hObject    handle to XE2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XE2 as text
%        str2double(get(hObject,'String')) returns contents of XE2 as a double


% --- Executes during object creation, after setting all properties.
function XE2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XE2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XE3_Callback(hObject, eventdata, handles)
% hObject    handle to XE3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XE3 as text
%        str2double(get(hObject,'String')) returns contents of XE3 as a double


% --- Executes during object creation, after setting all properties.
function XE3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XE3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XE4_Callback(hObject, eventdata, handles)
% hObject    handle to XE4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XE4 as text
%        str2double(get(hObject,'String')) returns contents of XE4 as a double


% --- Executes during object creation, after setting all properties.
function XE4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XE4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
