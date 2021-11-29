function varargout = BasicDeltaScans_V4(varargin)
% BASICDELTASCANS_V4 MATLAB code for BasicDeltaScans_V4.fig
%      BASICDELTASCANS_V4, by itself, creates a new BASICDELTASCANS_V4 or raises the existing
%      singleton*.
%
%      H = BASICDELTASCANS_V4 returns the handle to a new BASICDELTASCANS_V4 or the handle to
%      the existing singleton*.
%
%      BASICDELTASCANS_V4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICDELTASCANS_V4.M with the given input arguments.
%
%      BASICDELTASCANS_V4('Property','Value',...) creates a new BASICDELTASCANS_V4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BasicDeltaScans_V4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BasicDeltaScans_V4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BasicDeltaScans_V4

% Last Modified by GUIDE v2.5 10-Dec-2014 15:31:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BasicDeltaScans_V4_OpeningFcn, ...
                   'gui_OutputFcn',  @BasicDeltaScans_V4_OutputFcn, ...
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


% --- Executes just before BasicDeltaScans_V4 is made visible.
function BasicDeltaScans_V4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BasicDeltaScans_V4 (see VARARGIN)

% Choose default command line output for BasicDeltaScans_V4
handles.output = hObject;
load PureModeFits PureModeFits
load FreeFitParameters2 FreeFit
handles.PureModeFits=PureModeFits;
handles.FreeFit=FreeFit;
set(handles.START,'UserData',0);
set(handles.MoveAgainSamePosition,'string','GO AGAIN!');
set(handles.MoveAgainSamePosition,'userdata',[]);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BasicDeltaScans_V4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BasicDeltaScans_V4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in C1.
function C1_Callback(hObject, eventdata, handles)
switch(get(handles.C1,'value'))
    case 1
        set(handles.text5,'string',['Additional',char(13),'Displacement']);
        set(handles.text6,'string','K Start');
        set(handles.End,'string','K End');
    case 2
        set(handles.text5,'string',['Additional',char(13),'Displacement']);
        set(handles.text6,'string','K Start');
        set(handles.End,'string','K End');
    case 3
        set(handles.text5,'string',['Additional',char(13),'Displacement']);
        set(handles.text6,'string','K Start');
        set(handles.End,'string','K End');
    case 4
        set(handles.text5,'string',['Additional',char(13),'Displacement']);
        set(handles.text6,'string','K Start');
        set(handles.End,'string','K End');
    case 5
        set(handles.text5,'string','Unused');
        set(handles.text6,'string','Unused');
        set(handles.End,'string','Unused');
    case 6
        set(handles.text5,'string','Unused');
        set(handles.text6,'string','p.s. start');
        set(handles.End,'string','p.s. end');
    case 7
        set(handles.text5,'string','K value');
        set(handles.text6,'string','Disp. start');
        set(handles.End,'string','Disp. end');
end


% --- Executes during object creation, after setting all properties.
function C1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in C2.
function C2_Callback(hObject, eventdata, handles)
% hObject    handle to C2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns C2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from C2


% --- Executes during object creation, after setting all properties.
function C2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LogBook.
function LogBook_Callback(hObject, eventdata, handles)
save TEMPORANEO
try 
    DeltaScan=handles.Output;
catch
    return
end
%CurrentTime=clock;
CurrentTime=handles.AcquisitionTime;
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentDieiString=num2str(CurrentTime(3),'%.2d');
CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
CurrentTimeString=[CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'--',CurrentTempo1String,'-',CurrentTempo2String,'-',CurrentTempo3String,'-',CurrentTempo4String];          
NewFigure=figure; 
if(isfield(DeltaScan,'PhaseShifter'))
    NewFigure=figure
    errorbar([DeltaScan.PhaseShifter],[DeltaScan.AGD1],[DeltaScan.AGD1ERR],'*b');
    hold on
    if(isfield(DeltaScan,'GDET_FEE1_242_ENRC'))
        errorbar([DeltaScan.PhaseShifter],[DeltaScan.AGD2],[DeltaScan.AGD2ERR],'*r');
    end
    if(isfield(DeltaScan,'GDET_FEE1_361_ENRC'))
        errorbar([DeltaScan.PhaseShifter],[DeltaScan.AGD3],[DeltaScan.AGD3ERR],'*k');
    end
    if(isfield(DeltaScan,'GDET_FEE1_362_ENRC'))
        errorbar([DeltaScan.PhaseShifter],[DeltaScan.AGD4],[DeltaScan.AGD4ERR],'*g');
    end
    xlim([min([DeltaScan.PhaseShifter]),max([DeltaScan.PhaseShifter])]);
    title(CurrentTimeString);
    xlabel('Delta PhaseShifter');
    ylabel('Average gas detector [mJ]');
    util_printLog(NewFigure);
    saving_string=' DeltaScan';
    eval(['save /u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'/DeltaScan-',CurrentTimeString,' ',saving_string]);
    if(get(handles.LGDET,'value'))
        NewFigure2=figure; 		
        KVALUE=[DeltaScan.PhaseShifter];
        LINPOL=[DeltaScan.AverageLinPol];
        ANGLE=[DeltaScan.AverageAngle];
        plot(KVALUE(~isnan(LINPOL)),LINPOL(~isnan(LINPOL)),'*k');
        title(CurrentTimeString);
        xlabel('Delta PhaseShifter');
        ylabel('Degree of Polarization');
        util_printLog(NewFigure2);
        NewFigure3=figure; 		
        plot(KVALUE(~isnan(ANGLE)),ANGLE(~isnan(ANGLE)),'*k');
        title(CurrentTimeString);
        xlabel('Delta PhaseShifter');
        ylabel('Polarization Angle');
        util_printLog(NewFigure3);
    end
elseif(isfield(DeltaScan,'Kexpected'))
    NewFigure=figure
    errorbar([DeltaScan.Kexpected],[DeltaScan.AGD1],[DeltaScan.AGD1ERR],'*b');
    hold on
    if(isfield(DeltaScan,'GDET_FEE1_242_ENRC'))
        errorbar([DeltaScan.Kexpected],[DeltaScan.AGD2],[DeltaScan.AGD2ERR],'*r');
    end
    if(isfield(DeltaScan,'GDET_FEE1_361_ENRC'))
        errorbar([DeltaScan.Kexpected],[DeltaScan.AGD3],[DeltaScan.AGD3ERR],'*k');
    end
    if(isfield(DeltaScan,'GDET_FEE1_362_ENRC'))
        errorbar([DeltaScan.Kexpected],[DeltaScan.AGD4],[DeltaScan.AGD4ERR],'*g');
    end
    xlim([min([DeltaScan.Kexpected]),max([DeltaScan.Kexpected])]);
    title(CurrentTimeString);
    xlabel('Delta K equivalent');
    ylabel('Average gas detector [mJ]');
    util_printLog(NewFigure);
    saving_string=' DeltaScan';
    eval(['save /u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'/DeltaScan-',CurrentTimeString,' ',saving_string]);
    if(get(handles.LGDET,'value'))
        NewFigure2=figure; 		
        KVALUE=[DeltaScan.Kexpected];
        LINPOL=[DeltaScan.AverageLinPol];
        ANGLE=[DeltaScan.AverageAngle];
        plot(KVALUE(~isnan(LINPOL)),LINPOL(~isnan(LINPOL)),'*k');
        title(CurrentTimeString);
        xlabel('Delta K equivalent');
        ylabel('Degree of Polarization');
        util_printLog(NewFigure2);
        NewFigure3=figure; 		
        plot(KVALUE(~isnan(ANGLE)),ANGLE(~isnan(ANGLE)),'*k');
        title(CurrentTimeString);
        xlabel('Delta K equivalent');
        ylabel('Polarization Angle');
        util_printLog(NewFigure3);
    end
    elseif(isfield(DeltaScan,'Displacement'))
    NewFigure=figure
    errorbar([DeltaScan.Displacement],[DeltaScan.AGD1],[DeltaScan.AGD1ERR],'*b');
    hold on
    if(isfield(DeltaScan,'GDET_FEE1_242_ENRC'))
        errorbar([DeltaScan.Displacement],[DeltaScan.AGD2],[DeltaScan.AGD2ERR],'*r');
    end
    if(isfield(DeltaScan,'GDET_FEE1_361_ENRC'))
        errorbar([DeltaScan.Displacement],[DeltaScan.AGD3],[DeltaScan.AGD3ERR],'*k');
    end
    if(isfield(DeltaScan,'GDET_FEE1_362_ENRC'))
        errorbar([DeltaScan.Displacement],[DeltaScan.AGD4],[DeltaScan.AGD4ERR],'*g');
    end
    xlim([min([DeltaScan.Displacement]),max([DeltaScan.Displacement])]);
    title(CurrentTimeString);
    xlabel('Delta K equivalent');
    ylabel('Average gas detector [mJ]');
    util_printLog(NewFigure);
    saving_string=' DeltaScan';
    eval(['save /u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'/DeltaScan-',CurrentTimeString,' ',saving_string]);
    if(get(handles.LGDET,'value'))
        NewFigure2=figure; 		
        KVALUE=[DeltaScan.Displacement];
        LINPOL=[DeltaScan.AverageLinPol];
        ANGLE=[DeltaScan.AverageAngle];
        plot(KVALUE(~isnan(LINPOL)),LINPOL(~isnan(LINPOL)),'*k');
        title(CurrentTimeString);
        xlabel('Displacement');
        ylabel('Degree of Polarization');
        util_printLog(NewFigure2);
        NewFigure3=figure; 		
        plot(KVALUE(~isnan(ANGLE)),ANGLE(~isnan(ANGLE)),'*k');
        title(CurrentTimeString);
        xlabel('Displacement');
        ylabel('Polarization Angle');
        util_printLog(NewFigure3);
    end
end



% --- Executes on button press in LGDET.
function LGDET_Callback(hObject, eventdata, handles)
% hObject    handle to LGDET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LGDET


% --- Executes on button press in gdet1.
function gdet1_Callback(hObject, eventdata, handles)
% hObject    handle to gdet1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gdet1


% --- Executes on button press in gdet2.
function gdet2_Callback(hObject, eventdata, handles)
% hObject    handle to gdet2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gdet2


% --- Executes on button press in gdet3.
function gdet3_Callback(hObject, eventdata, handles)
% hObject    handle to gdet3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gdet3


% --- Executes on button press in gdet4.
function gdet4_Callback(hObject, eventdata, handles)
% hObject    handle to gdet4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gdet4



function samples_Callback(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samples as text
%        str2double(get(hObject,'String')) returns contents of samples as a double


% --- Executes during object creation, after setting all properties.
function samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rej2_Callback(hObject, eventdata, handles)
% hObject    handle to rej2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rej2 as text
%        str2double(get(hObject,'String')) returns contents of rej2 as a double


% --- Executes during object creation, after setting all properties.
function rej2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rej2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rej1_Callback(hObject, eventdata, handles)
% hObject    handle to rej1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rej1 as text
%        str2double(get(hObject,'String')) returns contents of rej1 as a double


% --- Executes during object creation, after setting all properties.
function rej1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rej1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RatePolarizationRead_Callback(hObject, eventdata, handles)
% hObject    handle to RatePolarizationRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RatePolarizationRead as text
%        str2double(get(hObject,'String')) returns contents of RatePolarizationRead as a double


% --- Executes during object creation, after setting all properties.
function RatePolarizationRead_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RatePolarizationRead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AdditionalDisplacement_Callback(hObject, eventdata, handles)
% hObject    handle to AdditionalDisplacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AdditionalDisplacement as text
%        str2double(get(hObject,'String')) returns contents of AdditionalDisplacement as a double


% --- Executes during object creation, after setting all properties.
function AdditionalDisplacement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdditionalDisplacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ksedit_Callback(hObject, eventdata, handles)
% hObject    handle to ksedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ksedit as text
%        str2double(get(hObject,'String')) returns contents of ksedit as a double


% --- Executes during object creation, after setting all properties.
function ksedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ksedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function keedit_Callback(hObject, eventdata, handles)
% hObject    handle to keedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of keedit as text
%        str2double(get(hObject,'String')) returns contents of keedit as a double


% --- Executes during object creation, after setting all properties.
function keedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to keedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re1_Callback(hObject, eventdata, handles)
% hObject    handle to re1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re1 as text
%        str2double(get(hObject,'String')) returns contents of re1 as a double


% --- Executes during object creation, after setting all properties.
function re1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re2_Callback(hObject, eventdata, handles)
% hObject    handle to re2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re2 as text
%        str2double(get(hObject,'String')) returns contents of re2 as a double


% --- Executes during object creation, after setting all properties.
function re2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re3_Callback(hObject, eventdata, handles)
% hObject    handle to re3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re3 as text
%        str2double(get(hObject,'String')) returns contents of re3 as a double


% --- Executes during object creation, after setting all properties.
function re3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re4_Callback(hObject, eventdata, handles)
% hObject    handle to re4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re4 as text
%        str2double(get(hObject,'String')) returns contents of re4 as a double


% --- Executes during object creation, after setting all properties.
function re4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re5_Callback(hObject, eventdata, handles)
% hObject    handle to re5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re5 as text
%        str2double(get(hObject,'String')) returns contents of re5 as a double


% --- Executes during object creation, after setting all properties.
function re5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re6_Callback(hObject, eventdata, handles)
% hObject    handle to re6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re6 as text
%        str2double(get(hObject,'String')) returns contents of re6 as a double


% --- Executes during object creation, after setting all properties.
function re6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re7_Callback(hObject, eventdata, handles)
% hObject    handle to re7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re7 as text
%        str2double(get(hObject,'String')) returns contents of re7 as a double


% --- Executes during object creation, after setting all properties.
function re7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function re8_Callback(hObject, eventdata, handles)
% hObject    handle to re8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of re8 as text
%        str2double(get(hObject,'String')) returns contents of re8 as a double


% --- Executes during object creation, after setting all properties.
function re8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to re8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
set(handles.slider1,'visible','off')
if(get(handles.START,'UserData'))
    set(handles.START,'String','Start')
    set(handles.START,'UserData',0)
else
TAKEDET=~get(handles.donot2,'value');
deltaslot=1;
FINALWAIT=str2num(get(handles.LetPolarizationArrive,'string'));
Harmonic=str2num(get(handles.HARMONIC,'string'));
set(handles.START,'String','Running...')
set(handles.START,'UserData',1);
C1=get(handles.C1,'Value');
NS=str2num(get(handles.NSTEPS,'string'));
load UnifiedMode AdditionalDisplacement
if(C1~=6) 
    
switch(C1)
    case 1 %CPLMF
        PS=handles.PureModeFits.CPLMF;
    case 2 %CPRMF
        PS=handles.PureModeFits.CPLMF;
    case 3 %LPHMF
        PS=handles.PureModeFits.CPLMF;
    case 4 %LPVMF
        PS=handles.PureModeFits.CPLMF;
    case 5
        Row1Path=linspace(str2num(get(handles.re1,'string')) , str2num(get(handles.re2,'string')), NS);
        Row2Path=linspace(str2num(get(handles.re3,'string')) , str2num(get(handles.re4,'string')), NS);
        Row3Path=linspace(str2num(get(handles.re5,'string')) , str2num(get(handles.re6,'string')), NS);
        Row4Path=linspace(str2num(get(handles.re7,'string')) , str2num(get(handles.re8,'string')), NS);
    case 7
        PS=handles.PureModeFits.CPLMF;
end
if(C1<5)
    ADD=str2num(get(handles.AdditionalDisplacement,'string'));
    Correction=ppval(AdditionalDisplacement,ADD);
    KeffStart=str2num(get(handles.ksedit,'string'));
    KeffEnd=str2num(get(handles.keedit,'string'));
    KVALI=deltagui_Keff2S0(str2num(get(handles.ksedit,'string')),Harmonic,handles, deltaslot);
    KVALE=deltagui_Keff2S0(str2num(get(handles.keedit,'string')),Harmonic,handles, deltaslot);
    KValue=linspace(sqrt(KVALI) , sqrt(KVALE), NS);
    %KValue=linspace(KeffStart , KeffEnd, NS);
    Nodes=ppval(PS,PS.breaks);
    [~,Coeffs]=unmkpp(PS);
    for II=1:NS
       if(KValue(II)<Nodes(1)) %go to the off position and forget about it.
            SingleParameter(II)=8;
       else
          PolinomialPiece=find(KValue(II)>=Nodes,1,'last');
          if(PolinomialPiece==length(Nodes))
               PolinomialPiece=length(Nodes)-1;
          end 
          if(abs(PS.breaks(PolinomialPiece)-KValue(II))<10^-4)
              SingleParameter(II)=acos(PS.breaks(PolinomialPiece))*32/pi/2;
          else
            CPOL=Coeffs(PolinomialPiece,:);
            CPOL(4)=CPOL(4)-KValue(II);
            Solution=roots(CPOL);
            SingleParameter(II)=acos(PS.breaks(PolinomialPiece)+Solution(3))*32/pi/2;
            if(~isreal(SingleParameter(II)))
                SingleParameter(II)=0;
            end
          end
       end
    end
    Row1Path= Correction/2 + ADD/2 + SingleParameter;
    Row2Path= Correction/2 - ADD/2 + SingleParameter;
    Row3Path= -Correction/2 + ADD/2 - SingleParameter;
    Row4Path= -Correction/2 - ADD/2 - SingleParameter;   
end

if(C1==7)
    KVALUE=str2num(get(handles.AdditionalDisplacement,'string'));
    KVALS0=deltagui_Keff2S0(KVALUE,Harmonic,handles, deltaslot);
    KValue=sqrt(KVALS0);
    DStart=str2num(get(handles.ksedit,'string'));
    DEnd=str2num(get(handles.keedit,'string'));
    DisplacementVector=linspace(DStart , DEnd, NS);   
    Nodes=ppval(PS,PS.breaks);
    [~,Coeffs]=unmkpp(PS);
    for II=1:1
       if(KValue(II)<Nodes(1)) %go to the off position and forget about it.
            SingleParameter(II)=8;
       else
          PolinomialPiece=find(KValue(II)>=Nodes,1,'last');
          if(PolinomialPiece==length(Nodes))
               PolinomialPiece=length(Nodes)-1;
          end 
          if(abs(PS.breaks(PolinomialPiece)-KValue(II))<10^-4)
              SingleParameter(II)=acos(PS.breaks(PolinomialPiece))*32/pi/2;
          else
            CPOL=Coeffs(PolinomialPiece,:);
            CPOL(4)=CPOL(4)-KValue(II);
            Solution=roots(CPOL);
            SingleParameter(II)=acos(PS.breaks(PolinomialPiece)+Solution(3))*32/pi/2;
            if(~isreal(SingleParameter(II)))
                SingleParameter(II)=0;
            end
          end
       end
    end
    for II=1:NS
       Correction(II)=ppval(AdditionalDisplacement,DisplacementVector(II));
    end
    Row1Path= Correction/2 + DisplacementVector/2 + SingleParameter;
    Row2Path= Correction/2 - DisplacementVector/2 + SingleParameter;
    Row3Path= -Correction/2 + DisplacementVector/2 - SingleParameter;
    Row4Path= -Correction/2 - DisplacementVector/2 - SingleParameter;   
end

% save TEMP 
% return
%Expected Plots for Row Paths
if(C1<6)
    for II=1:NS
       switch(C1) 
           case 1
                KPATH(II)=ppval(PS,cos(2*pi*2*SingleParameter(II)/2/32));
           case 2
                KPATH(II)=ppval(PS,cos(2*pi*2*SingleParameter(II)/2/32));
           case 3
                KPATH(II)=ppval(PS,cos(2*pi*2*SingleParameter(II)/2/32));
           case 4
                KPATH(II)=ppval(PS,cos(2*pi*2*SingleParameter(II)/2/32));
           otherwise

       end
       rod{II}=[Row1Path(II),Row2Path(II),Row3Path(II),Row4Path(II)];
       [Deltaphi,ErrorState]=deltagui_rod2Deltaphi(rod{II},handles, deltaslot);
       S=deltagui_Deltaphi2Stokes(Deltaphi,handles, deltaslot);
       if(C1>4)
           KPATH(II)=sqrt(S(1));
       end
       KEQPATH(II)=deltagui_S0toKeff(KPATH(II)^2,Harmonic,handles, deltaslot);
       EP=deltagui_Stokes2Ellipse(S);
       ANGLE(II)=EP(2);
       DEGLINPOL(II)=EP(3);
       CHIRALITY(II)=EP(4);
    end
else
        for II=1:NS
            DisplacementPATH=DisplacementVector;
            rod{II}=[Row1Path(II),Row2Path(II),Row3Path(II),Row4Path(II)];
            [Deltaphi,ErrorState]=deltagui_rod2Deltaphi(rod{II},handles, deltaslot);
            S=deltagui_Deltaphi2Stokes(Deltaphi,handles, deltaslot);
            KEQPATH(II)=KValue;
            EP=deltagui_Stokes2Ellipse(S);
            ANGLE(II)=EP(2);
            DEGLINPOL(II)=EP(3);
            CHIRALITY(II)=EP(4);
        end
    
end
if(C1<=5)

figure(1400)
plot(Row1Path,'b*'), hold on
plot(Row2Path,'r*')
plot(Row3Path,'k*')
plot(Row4Path,'g*')
legend('row 1','row 2','row 3','row 4')
title('Rows path')
figure(1500)
plot(KPATH,'*'), hold on
plot(KEQPATH,'r*')
legend('K eff','K eq')
title('K path (expected)')
figure(1600)
plot(ANGLE,'*')
title('Angle (expected)')
figure(1600)
plot(DEGLINPOL,'*')
title('Degree Linear Polarization (expected)')
figure(1700)
plot(CHIRALITY,'*')
title('Chirality (expected)')
pause(1)
close(1400)
close(1500)
close(1600)
close(1700)
end
handles.Row1Path=Row1Path;
handles.Row2Path=Row2Path;
handles.Row3Path=Row3Path;
handles.Row4Path=Row4Path;
handles.ANGLEESTIMATE=ANGLE;
handles.DEGLINPOL=DEGLINPOL;
handles.CHIRALITY=CHIRALITY;
if(C1<=5)
    handles.KPATH=KPATH;
    handles.KEQPATH=KEQPATH;
end
if(C1==7)
    handles.DisplacementPATH=DisplacementPATH;
end

else
    Z(1)=lcaGetSmart('USEG:UND1:3350:1:MOTR.RBV');
    Z(2)=lcaGetSmart('USEG:UND1:3350:2:MOTR.RBV');
    Z(3)=lcaGetSmart('USEG:UND1:3350:3:MOTR.RBV');
    Z(4)=lcaGetSmart('USEG:UND1:3350:4:MOTR.RBV');  
    PSStart=(lcaGetSmart('PHAS:UND1:3340:ENC')/1000);
    Start=str2num(get(handles.ksedit,'string'));
    End=str2num(get(handles.keedit,'string'));
    PhaseShifterWalk=linspace(Start,End,NS);
end

Exit_Condition=1;

PVTBR(1)=get(handles.gdet2,'value');
PVTBR(2)=get(handles.gdet3,'value');
PVTBR(3)=get(handles.gdet4,'value');

Position=1;

Minimum=str2num(get(handles.rej1,'string'));
Maximum=str2num(get(handles.rej2,'string'));

Current_Index=1; Current_Index_old=1;
TakenDataWork=ones(144000,30)*NaN;
PulseIDsAll=ones(144000,1)*NaN;
if(C1~=6)
R1hist=lcaGetSmart('USEG:UND1:3350:1:MOTR.RBV')*ones(50,1);
R2hist=lcaGetSmart('USEG:UND1:3350:2:MOTR.RBV')*ones(50,1);
R3hist=lcaGetSmart('USEG:UND1:3350:3:MOTR.RBV')*ones(50,1);
R4hist=lcaGetSmart('USEG:UND1:3350:4:MOTR.RBV')*ones(50,1);
Distancehist=sqrt((R1hist-Row1Path(1)).^2 + (R2hist-Row2Path(1)).^2 + (R3hist-Row3Path(1)).^2 + (R4hist-Row4Path(1)).^2 );
else
    R1hist=PSStart*ones(50,1);
    Distancehist=abs(R1hist-PhaseShifterWalk(1));
end

if(C1~=6)
GDETAVG1=KEQPATH*0;
GDETAVG2=KEQPATH*0;
CBDELAY=str2num(get(handles.CBDELAY,'string'));
THRESHOLD=0.005;
CookieBoxPV='AMO:CB:POL';
CookieBoxSize=600;
CookieBoxWork=zeros(CookieBoxSize,28800);
CookieBoxPVDet='AMO:CB:DET';
CookieBoxSizeDet=2040;
CookieBoxWorkDet=zeros(CookieBoxSizeDet,28800);
CBI=1;
CBTS=-1;
SAMPLES=str2num(get(handles.samples,'string'));
RatePolarizationRead=str2num(get(handles.RatePolarizationRead,'string'));
GDET1=zeros(1,RatePolarizationRead); TS1= GDET1;
GDET2=zeros(1,RatePolarizationRead); TS2= GDET1;
GDET3=zeros(1,RatePolarizationRead); TS3= GDET1;
GDET4=zeros(1,RatePolarizationRead); TS4= GDET1;
else
    R1Old=-inf;
    GDETAVG1=PhaseShifterWalk*0;
    GDETAVG2=PhaseShifterWalk*0;
    CBDELAY=str2num(get(handles.CBDELAY,'string'));
    THRESHOLD=0.010;
    CookieBoxPV='AMO:CB:POL';
    CookieBoxSize=600;
    CookieBoxWork=zeros(CookieBoxSize,28800);
    CookieBoxPVDet='AMO:CB:DET';
    CookieBoxSizeDet=2040;
    CookieBoxWorkDet=zeros(CookieBoxSizeDet,28800);
    CBI=1;
    CBTS=-1;
    SAMPLES=str2num(get(handles.samples,'string'));
    RatePolarizationRead=str2num(get(handles.RatePolarizationRead,'string'));
    GDET1=zeros(1,RatePolarizationRead); TS1= GDET1;
    GDET2=zeros(1,RatePolarizationRead); TS2= GDET1;
    GDET3=zeros(1,RatePolarizationRead); TS3= GDET1;
    GDET4=zeros(1,RatePolarizationRead); TS4= GDET1;
end
TEST=0;
% 
if(~TAKEDET)
   TakenDataWork=TakenDataWork(:,1:14); 
end

while(Exit_Condition)
    
    if(~get(handles.START,'UserData'))
        set(handles.START,'string','Start');
        return
    end
    
    if(C1~=6)
        lcaPutNoWait('USEG:UND1:3350:1:MOTR',Row1Path(Position));
        lcaPutNoWait('USEG:UND1:3350:2:MOTR',Row2Path(Position));
        lcaPutNoWait('USEG:UND1:3350:3:MOTR',Row3Path(Position));
        lcaPutNoWait('USEG:UND1:3350:4:MOTR',Row4Path(Position));
        set(handles.MoveAgainSamePosition,'Userdata',[Row1Path(Position),Row2Path(Position),Row3Path(Position),Row4Path(Position)]);
    else
        lcaPutNoWait('PHAS:UND1:3340:MOTR',PhaseShifterWalk(Position));
        set(handles.MoveAgainSamePosition,'Userdata',PhaseShifterWalk(Position));
    end
    
    Exit_Condition2=1;
    while(Exit_Condition2)
        if(C1~=6)
        R1=lcaGetSmart('USEG:UND1:3350:1:MOTR.RBV');
        R2=lcaGetSmart('USEG:UND1:3350:2:MOTR.RBV');
        R3=lcaGetSmart('USEG:UND1:3350:3:MOTR.RBV');
        R4=lcaGetSmart('USEG:UND1:3350:4:MOTR.RBV');
        Distance=sqrt((R1-Row1Path(Position)).^2 + (R2-Row2Path(Position)).^2 + (R3-Row3Path(Position)).^2 + (R4-Row4Path(Position)).^2 );
        else
        R1=(lcaGetSmart('PHAS:UND1:3340:ENC')/1000);
        if(abs(R1-R1Old)<0.01)
           AskAgain=1; 
        else
           AskAgain=0; 
        end
        R1Old=R1;
        Distance=abs(R1-PhaseShifterWalk(Position));
        end
        if(~get(handles.START,'UserData'))
            set(handles.START,'string','Start');
                return
        end
        if(Distance<THRESHOLD) 
            Exit_Condition2=0;
        end
        if(C1~=6)
        R1hist=[R1hist(2:50);R1];        R2hist=[R2hist(2:50);R2];       R3hist=[R3hist(2:50);R3];        R4hist=[R4hist(2:50);R4]; Distancehist=[Distancehist(2:50);Distance];
        plot(handles.ROW1,R1hist,'*'), hold(handles.ROW1,'on'),plot(handles.ROW1,50,Row1Path(Position),'ro'); hold(handles.ROW1,'off');
        plot(handles.ROW2,R2hist,'*'), hold(handles.ROW2,'on'),plot(handles.ROW2,50,Row2Path(Position),'ro'); hold(handles.ROW2,'off');
        plot(handles.ROW3,R3hist,'*'), hold(handles.ROW3,'on'),plot(handles.ROW3,50,Row3Path(Position),'ro'); hold(handles.ROW3,'off');
        plot(handles.ROW4,R4hist,'*'), hold(handles.ROW4,'on'),plot(handles.ROW4,50,Row4Path(Position),'ro'); hold(handles.ROW4,'off');
        plot(handles.ROWALL,Distancehist,'*'),hold(handles.ROWALL,'on'), plot(handles.ROWALL,50,THRESHOLD,'ro'); hold(handles.ROWALL,'off');
        else
            R1hist=[R1hist(2:50);R1]; Distancehist=[Distancehist(2:50);Distance];
            plot(handles.ROW1,R1hist,'*'), hold(handles.ROW1,'on'),plot(handles.ROW1,50,PhaseShifterWalk(Position),'ro'); hold(handles.ROW1,'off');
            plot(handles.ROWALL,Distancehist,'*'),hold(handles.ROWALL,'on'), plot(handles.ROWALL,50,THRESHOLD,'ro'); hold(handles.ROWALL,'off');
            if(AskAgain)
                lcaPutNoWait('PHAS:UND1:3340:MOTR',PhaseShifterWalk(Position));
            end
        end
        CookieBoxWork(:,CBI)=lcaGetSmart(CookieBoxPV);
        if(TAKEDET)
            CookieBoxWorkDet(:,CBI)=lcaGetSmart(CookieBoxPVDet);
        end
        pause(0.2);
        CBI=CBI+1;
        set(handles.DIA,'string',(['residual distance :',num2str(Distance)]));
        if(TEST)
           lcaPut('USEG:UND1:3350:1:MOTR.RBV',(R1+Row1Path(Position))/2); 
           lcaPut('USEG:UND1:3350:2:MOTR.RBV',(R2+Row2Path(Position))/2);
           lcaPut('USEG:UND1:3350:3:MOTR.RBV',(R3+Row3Path(Position))/2);
           lcaPut('USEG:UND1:3350:4:MOTR.RBV',(R4+Row4Path(Position))/2);
        end
    end
    pause(0.15);
    set(handles.DIA,'string',(['Taking data']));
    Exit_Condition3=1;
    if(C1~=6)
        TakenDataWork(Current_Index,6:9)=rod{Position};
        if(C1<=5)
            TakenDataWork(Current_Index,10)=handles.KEQPATH(Position);
        elseif(C1==7)
            TakenDataWork(Current_Index,10)=handles.DisplacementPATH(Position);    
        end
    else
        TakenDataWork(Current_Index,6:9)=Z;
        TakenDataWork(Current_Index,10)=PhaseShifterWalk(Position);
    end
    while(Exit_Condition3)
        if(~get(handles.START,'UserData'))
            set(handles.START,'string','Start');
            return
        end
        for II=1:RatePolarizationRead
            [GDET1(II),TS1(II)]=lcaGetSmart('GDET:FEE1:241:ENRC');
            if(PVTBR(1))
                [GDET2(II),TS2(II)]=lcaGetSmart('GDET:FEE1:242:ENRC');
            end
            if(PVTBR(2))
                [GDET3(II),TS3(II)]=lcaGetSmart('GDET:FEE1:361:ENRC');
            end
            if(PVTBR(3))
                [GDET4(II),TS4(II)]=lcaGetSmart('GDET:FEE1:362:ENRC');
            end         
            pause(1/2000)
        end
        CookieBoxWork(:,CBI)=lcaGetSmart(CookieBoxPV);
        if(TAKEDET)
            CookieBoxWorkDet(:,CBI)=lcaGetSmart(CookieBoxPVDet);
        end
        CBI=CBI+1; 
        MasterEvents=find((GDET1>=Minimum).*(GDET1<=Maximum));
        GDET1=GDET1(MasterEvents);
        TS1=TS1(MasterEvents);
        PID1=bitand(uint32(imag(TS1)),hex2dec('1FFFF'));
        [UPID1,MasterEvents]=unique(PID1,'stable');
        GDET1=GDET1(MasterEvents);
        PID1=UPID1;
        if(~isempty(PID1))
            TakenDataWork(Current_Index:(Current_Index+length(PID1)-1),1)=PID1;
            TakenDataWork(Current_Index:(Current_Index+length(PID1)-1),2)=GDET1; 
            %pause(0.5);
        end
        if((Current_Index+length(PID1)-Current_Index_old)>=SAMPLES)
            Exit_Condition3=0;
        end
        if(PVTBR(1))
            PID2=bitand(uint32(imag(TS2)),hex2dec('1FFFF'));
            [~,W,Wx]=intersect(PID2,PID1,'stable');
            TakenDataWork(Current_Index+Wx-1,3)=GDET2(W);     
        end
        if(PVTBR(2))
            PID3=bitand(uint32(imag(TS3)),hex2dec('1FFFF'));
            [~,W,Wx]=intersect(PID3,PID1,'stable');
            TakenDataWork(Current_Index+Wx-1,4)=GDET3(W); 
        end
        if(PVTBR(3))
            PID4=bitand(uint32(imag(TS4)),hex2dec('1FFFF'));
            [~,W,Wx]=intersect(PID4,PID1,'stable');
            TakenDataWork(Current_Index + Wx-1,5)=GDET4(W); 
        end
        Current_Index=Current_Index+length(PID1);
    end
    GDETAVG1(Position)=mean(TakenDataWork(Current_Index_old:(Current_Index-1),2));
    if(PVTBR(2)) % May plot also GDET 3 if of interest...
        TempVector=TakenDataWork(Current_Index_old:(Current_Index-1),1);
        GDETAVG2(Position)=mean(TempVector(~isnan(TempVector)));
    end
    Current_Index_old=Current_Index;
    if(C1~=6)
        if(C1<6) % NORMAL
        if(~get(handles.DoNOT,'value'))
        plot(handles.GDET,KEQPATH,GDETAVG1,'*')
        if(PVTBR(2))
            hold(handles.GDET,'on')
            plot(handles.GDET,KEQPATH,GDETAVG2,'*r')
            hold(handles.GDET,'off')
        end
        xlim(handles.GDET,[min(KEQPATH),max(KEQPATH)]);
        else
            plot(handles.GDET,KEQPATH,GDETAVG2,'*r')
            xlim(handles.GDET,[min(KEQPATH),max(KEQPATH)]);
        end
        elseif(C1==7) %DEGLINPOL
            if(~get(handles.DoNOT,'value'))
            plot(handles.GDET,DisplacementPATH,GDETAVG1,'*')
            if(PVTBR(2))
                hold(handles.GDET,'on')
                plot(handles.GDET,DisplacementPATH,GDETAVG2,'*r')
                hold(handles.GDET,'off')
            end
            xlim(handles.GDET,[min(DisplacementPATH),max(DisplacementPATH)]);
            else
                plot(handles.GDET,DisplacementPATH,GDETAVG2,'*r')
                xlim(handles.GDET,[min(DisplacementPATH),max(DisplacementPATH)]);
            end
        end
    else %Phase Shifter
        if(~get(handles.DoNOT,'value'))
        plot(handles.GDET,PhaseShifterWalk,GDETAVG1,'*')
        if(PVTBR(2))
            hold(handles.GDET,'on')
            plot(handles.GDET,PhaseShifterWalk,GDETAVG2,'*r')
            hold(handles.GDET,'off')
        end
        xlim(handles.GDET,[min(PhaseShifterWalk),max(PhaseShifterWalk)]);  
        else
           plot(handles.GDET,PhaseShifterWalk,GDETAVG2,'*r')
           xlim(handles.GDET,[min(PhaseShifterWalk),max(PhaseShifterWalk)]);
        end
    end
    
    %ReachTargetPosition
    Position=Position+1;
    if(Position>NS)
        Exit_Condition=0;
    end
end
set(handles.DIA,'string',(['Wait for some more cookies']));
%let some more polarization arrive 
tic
elapsedtime=toc;
while(elapsedtime < FINALWAIT)
        elapsedtime=toc
        %FINALWAIT
        CookieBoxWork(:,CBI)=lcaGetSmart(CookieBoxPV);
        if(TAKEDET)
            CookieBoxWorkDet(:,CBI)=lcaGetSmart(CookieBoxPVDet);
        end
        pause(0.3);
        CBI=CBI+1;
end

TakenDataWork=TakenDataWork(1:(Current_Index-1),:);
AllFoundPids=TakenDataWork(:,1);
set(handles.DIA,'string',(['Processing CBPOL']));
drawnow
% CBTSDet=CBTS;
for TT=1:(CBI-1) %This sorts out the cookiebox polarization vector
    CBW=CookieBoxWork(:,TT);
%     CBWDet=CookieBoxWorkDet(:,TT);
    CBTSN=CBW(1);
%     CBTSNDet=CBW(1);
    if(CBTSN~=CBTS)
       CBTS=CBTSN;
       CBWPID=CBW(1:5:end)+CBDELAY;
       [Value,WhereInFoundPIDS,WhereInCBW]=intersect(AllFoundPids,CBWPID,'stable');
       WhereInCBW=(WhereInCBW-1)*5+1;
       TakenDataWork(WhereInFoundPIDS,11)=CBW(WhereInCBW+1);
       TakenDataWork(WhereInFoundPIDS,12)=CBW(WhereInCBW+2);
       TakenDataWork(WhereInFoundPIDS,13)=CBW(WhereInCBW+3);
       TakenDataWork(WhereInFoundPIDS,14)=CBW(WhereInCBW+4);
    end
    
%     if(CBTSNDet~=CBTSDet)
%        CBTSDet=CBTSNDet;
%        CBWPIDDet=CBW(1:17:end)+CBDELAY;
%        [ValueDet,WhereInFoundPIDSDet,WhereInCBWDet]=intersect(AllFoundPidsDet,CBWPIDDet,'stable');
%        WhereInCBW=(WhereInCBW-1)*5+1;
%        TakenDataWork(WhereInFoundPIDS,11)=CBW(WhereInCBW+1);
%        TakenDataWork(WhereInFoundPIDS,12)=CBW(WhereInCBW+2);
%        TakenDataWork(WhereInFoundPIDS,13)=CBW(WhereInCBW+3);
%        TakenDataWork(WhereInFoundPIDS,14)=CBW(WhereInCBW+4);
%     end
    
end
if(TAKEDET)
    set(handles.DIA,'string',(['Processing CBDET']));
    drawnow
    CBTS=-1;
    for TT=1:(CBI-1) %This sorts out the cookiebox single detectors
        CBW=CookieBoxWorkDet(:,TT);
        CBTSN=CBW(1);
        if(CBTSN~=CBTS)
           CBTS=CBTSN;
           CBWPID=CBW(1:17:end)+CBDELAY;
           [Value,WhereInFoundPIDS,WhereInCBW]=intersect(AllFoundPids,CBWPID,'stable');
           WhereInCBW=(WhereInCBW-1)*5+1;
           TakenDataWork(WhereInFoundPIDS,15)=CBW(WhereInCBW+1);
           TakenDataWork(WhereInFoundPIDS,16)=CBW(WhereInCBW+2);
           TakenDataWork(WhereInFoundPIDS,17)=CBW(WhereInCBW+3);
           TakenDataWork(WhereInFoundPIDS,18)=CBW(WhereInCBW+4);
           TakenDataWork(WhereInFoundPIDS,19)=CBW(WhereInCBW+5);
           TakenDataWork(WhereInFoundPIDS,20)=CBW(WhereInCBW+6);
           TakenDataWork(WhereInFoundPIDS,21)=CBW(WhereInCBW+7);
           TakenDataWork(WhereInFoundPIDS,22)=CBW(WhereInCBW+8);
           TakenDataWork(WhereInFoundPIDS,23)=CBW(WhereInCBW+9);
           TakenDataWork(WhereInFoundPIDS,24)=CBW(WhereInCBW+10);
           TakenDataWork(WhereInFoundPIDS,25)=CBW(WhereInCBW+11);
           TakenDataWork(WhereInFoundPIDS,26)=CBW(WhereInCBW+12);
           TakenDataWork(WhereInFoundPIDS,27)=CBW(WhereInCBW+13);
           TakenDataWork(WhereInFoundPIDS,28)=CBW(WhereInCBW+14);
           TakenDataWork(WhereInFoundPIDS,29)=CBW(WhereInCBW+15);
           TakenDataWork(WhereInFoundPIDS,30)=CBW(WhereInCBW+16);
        end
    end
end
%Now work-out output structure
SEPARATION=find(~isnan(TakenDataWork(:,6)));
SEPARATION(end+1)=length(TakenDataWork(:,6))+1;
for II=1:(length(SEPARATION)-1);
    Output(II).Z=TakenDataWork(SEPARATION(II),6:9);
    if(C1~=6)
        if(C1<=5)
            Output(II).Kexpected=TakenDataWork(SEPARATION(II),10);
            PlotK(II)=Output(II).Kexpected; 
        else
            Output(II).Displacement=TakenDataWork(SEPARATION(II),10);
            PlotK(II)=Output(II).Displacement; 
        end
    else
        Output(II).PhaseShifter=TakenDataWork(SEPARATION(II),10);    
        PlotK(II)=Output(II).PhaseShifter;  
    end
     
    
    Output(II).MeasuredLinearPol=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),11);
    if(any(~isnan(Output(II).MeasuredLinearPol)))
        PlotLin(II)=mean(Output(II).MeasuredLinearPol(~isnan(Output(II).MeasuredLinearPol)));
        PlotLinRMS(II)=std(Output(II).MeasuredLinearPol(~isnan(Output(II).MeasuredLinearPol)));
        Output(II).AverageLinPol=PlotLin(II);
        Output(II).AverageLinPolERR=PlotLinRMS(II)/sqrt(sum(~isnan(Output(II).MeasuredLinearPol)));
        PlotLinERR(II)=Output(II).AverageLinPolERR;
        SKIP_POL(II)=0;
    else
        SKIP_POL(II)=1;
        Output(II).AverageLinPol=NaN;
    end
    Output(II).MeasuredLinearPolError=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),12);
    
    Output(II).MeasuredAngle=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),13);
    if(any(~isnan(Output(II).MeasuredAngle)))
        PlotAng(II)=mean(Output(II).MeasuredAngle(~isnan(Output(II).MeasuredAngle)));
        PlotAngRMS(II)=std(Output(II).MeasuredAngle(~isnan(Output(II).MeasuredAngle)));
        Output(II).AverageAngle=PlotAng(II);
        Output(II).AverageAngleERR=PlotAngRMS(II)/sqrt(sum(~isnan(Output(II).MeasuredAngle)));
        PlotAngERR(II)=Output(II).AverageAngleERR;
        SKIP_ANG(II)=0;
    else
        SKIP_ANG(II)=1;
        Output(II).AverageAngle=NaN;
    end
    Output(II).MeasuredAngleError=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),14);
    Output(II).PulseID=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),1);
    Output(II).GDET_FEE1_241_ENRC=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),2);
    PlotGD1(II)=mean(TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),2));
    Output(II).AGD1=PlotGD1(II);
    PlotGD1ERR(II)=std(TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),2))/sqrt(length(TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),2)));
    Output(II).AGD1ERR=PlotGD1ERR(II);
    if(PVTBR(1))
        Output(II).GDET_FEE1_242_ENRC=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),3);
        WORKGD=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),3);
        PlotGD2(II)=mean(WORKGD(~isnan(WORKGD)));
        Output(II).AGD2=PlotGD2(II);
        PlotGD2RMS(II)=std(WORKGD(~isnan(WORKGD)));
        PlotGD2ERR(II)=PlotGD2RMS(II)/sqrt(length(WORKGD(~isnan(WORKGD))));
        Output(II).AGD2ERR=PlotGD2RMS(II)/sqrt(length(WORKGD(~isnan(WORKGD))));
    end
    if(PVTBR(2))
        Output(II).GDET_FEE1_361_ENRC=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),4);
        WORKGD=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),4);
        PlotGD3(II)=mean(WORKGD(~isnan(WORKGD)));
        Output(II).AGD3=PlotGD3(II);
        PlotGD3RMS(II)=std(WORKGD(~isnan(WORKGD)));
        PlotGD3ERR(II)=PlotGD3RMS(II)/sqrt(length(WORKGD(~isnan(WORKGD))));
        Output(II).AGD3ERR=PlotGD3RMS(II)/sqrt(length(WORKGD(~isnan(WORKGD))));
    end
    if(PVTBR(3))
        Output(II).GDET_FEE1_362_ENRC=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),5);
        WORKGD=TakenDataWork(SEPARATION(II):(SEPARATION(II+1)-1),5);
        PlotGD4(II)=mean(WORKGD(~isnan(WORKGD)));
        Output(II).AGD4=PlotGD4(II);
        PlotGD4RMS(II)=std(WORKGD(~isnan(WORKGD)));
        PlotGD4ERR(II)=PlotGD4RMS(II)/sqrt(length(WORKGD(~isnan(WORKGD))));
        Output(II).AGD4ERR=PlotGD4RMS(II)/sqrt(length(WORKGD(~isnan(WORKGD))));
    end
    handles.Output=Output;
end
hold(handles.GDET,'off');hold(handles.POL,'off');hold(handles.ANGLE,'off');
if(~get(handles.DoNOT,'value'))
    errorbar(handles.GDET,PlotK,PlotGD1,PlotGD1ERR,'*b'); hold(handles.GDET,'on');
    if(PVTBR(1)), errorbar(handles.GDET,PlotK,PlotGD2,PlotGD2ERR,'*r');, end
if(PVTBR(2)), errorbar(handles.GDET,PlotK,PlotGD3,PlotGD3ERR,'*k');, end
if(PVTBR(3)), errorbar(handles.GDET,PlotK,PlotGD4,PlotGD4ERR,'*g');, end, hold(handles.GDET,'off');
else
    if(PVTBR(2)), errorbar(handles.GDET,PlotK,PlotGD3,PlotGD3ERR,'*k');, hold(handles.GDET,'on');, end
    if(PVTBR(3)), errorbar(handles.GDET,PlotK,PlotGD4,PlotGD4ERR,'*g');, end, hold(handles.GDET,'off');
end
xlim(handles.GDET,[min(PlotK),max(PlotK)]);
if(sum(SKIP_POL)<II)
    errorbar(handles.POL,PlotK(~SKIP_POL),PlotLin(~SKIP_POL),PlotLinERR(~SKIP_POL),'*k');
end
if(sum(SKIP_ANG)<II)
    errorbar(handles.ANGLE,PlotK(~SKIP_ANG),PlotAng(~SKIP_ANG),PlotAngERR(~SKIP_ANG),'*k');
end
xlim(handles.POL,[min(PlotK),max(PlotK)]);
xlim(handles.ANGLE,[min(PlotK),max(PlotK)]);
%save LOCALSAVE
set(handles.DIA,'string',(['Finished']));
[~,MAXPOS]=max(PlotGD1);
hold(handles.GDET,'on');
handles.CurrentMarker=plot(handles.GDET,PlotK(MAXPOS),PlotGD1(MAXPOS),'ok');
hold(handles.GDET,'off');
set(handles.slider1,'Min',1);
set(handles.slider1,'Max',length(PlotK));
set(handles.slider1,'value',MAXPOS);
set(handles.slider1,'visible','on')
handles.PlotK=PlotK;
handles.PlotGD1=PlotGD1;
handles.AcquisitionTime=clock;
guidata(hObject, handles);
set(handles.START,'String','Start')
set(handles.START,'UserData',0)



end

function NSTEPS_Callback(hObject, eventdata, handles)
% hObject    handle to NSTEPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NSTEPS as text
%        str2double(get(hObject,'String')) returns contents of NSTEPS as a double


% --- Executes during object creation, after setting all properties.
function NSTEPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NSTEPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function S=deltagui_Deltaphi2Stokes(Deltaphi,handles, deltaslot)
Deltaphi(3)=-Deltaphi(3);
S=deltagui_Deltaphi2Stokes_Version1(Deltaphi,handles, deltaslot);

function [Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi(S,handles, deltaslot)
[Deltaphi,DeltaphiMatrix]=deltagui_Stokes2Deltaphi_Version1(S,handles, deltaslot);


function S=deltagui_Deltaphi2Stokes_OLD(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)=-handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));


function S=deltagui_Deltaphi2Stokes_Version1(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= -handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));


function S=deltagui_Deltaphi2Stokes_Version2(Deltaphi,handles, deltaslot)
%This one is wrong, because it has electric field changing with same rows
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
S(1)= handles.AllDeltaConstants(deltaslot).KMax^2/4*(2 + cos(Deltaphi(1)) + cos(Deltaphi(2)));
S(2)= handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*cos(Deltaphi(3));
S(3)= -handles.AllDeltaConstants(deltaslot).KMax^2/4*(cos(Deltaphi(1)) - cos(Deltaphi(2)));
S(4)= -handles.AllDeltaConstants(deltaslot).KMax^2*cos(Deltaphi(1)/2)*cos(Deltaphi(2)/2)*sin(Deltaphi(3));


function S=deltagui_Ellipse2Stokes(EP)
S(1)=EP(1);
S(2)=EP(1)*EP(3)*cos(EP(2)*2*pi/180);
S(3)=EP(1)*EP(3)*sin(EP(2)*2*pi/180);
S(4)=EP(1)*sqrt(1-EP(3)^2)*EP(4);


function S=deltagui_ExEy2Stokes(ExEyV)

S(1)=ExEyV(1);
S(2)=ExEyV(1)*(2*ExEyV(2)-1);
S(3)=2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*cos(ExEyV(3)/180*pi);
S(4)=-2*ExEyV(1)*sqrt(ExEyV(2)*(1-ExEyV(2)))*sin(ExEyV(3)/180*pi);

function S0=deltagui_Keff2S0(Keff,Harmonic,handles, deltaslot)
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
S0= -2 + (2*(handles.UndConsts.lambda_u*1000) + Keff^2*(handles.UndConsts.lambda_u*1000))/(handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic );

function Keff=deltagui_S0toKeff(S,Harmonic,handles, deltaslot)
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
Keff=sqrt( ( 2*handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic - 2*(handles.UndConsts.lambda_u*1000) + S(1)*handles.AllDeltaConstants(deltaslot).lambda_u*Harmonic  ) / (handles.UndConsts.lambda_u*1000));

function EP=deltagui_Stokes2Ellipse(S)
EP(1)=S(1);
EP(2)=angle(S(2)+1i*S(3))/2*(180/pi);
EP(3)=sqrt(S(2)^2+S(3)^2)/S(1);
EP(4)=sign(S(4));

if(S(1)==0) % for S0=1 gives the undefined state of degree of linear polarization to 0.
   EP(3)=0; 
end


function ExEyV=deltagui_Stokes2ExEy(S)
ExEyV(1)=S(1);
ExEyV(2)=(S(2)/S(1)+1)/2;
ExEyV(3)=angle(S(3)-1i*S(4))*180/pi;

function [Deltaphi,ErrorState]=deltagui_rod2Deltaphi(rod,handles, deltaslot)
handles.UndConsts.lambda_u=0.03;
handles.AllDeltaConstants(1).lambda_u=32;
handles.AllDeltaConstants(deltaslot).KMax=3.59;
ErrorState=0;
Deltaphi(1)=2*pi*(rod(1)-rod(3))/handles.AllDeltaConstants(deltaslot).lambda_u;
Deltaphi(2)=2*pi*(rod(2)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;
Deltaphi(3)=  pi*(rod(1)-rod(2)+rod(3)-rod(4))/handles.AllDeltaConstants(deltaslot).lambda_u;



function HARMONIC_Callback(hObject, eventdata, handles)
% hObject    handle to HARMONIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HARMONIC as text
%        str2double(get(hObject,'String')) returns contents of HARMONIC as a double


% --- Executes during object creation, after setting all properties.
function HARMONIC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HARMONIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBDELAY_Callback(hObject, eventdata, handles)
% hObject    handle to CBDELAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CBDELAY as text
%        str2double(get(hObject,'String')) returns contents of CBDELAY as a double


% --- Executes during object creation, after setting all properties.
function CBDELAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBDELAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in STOP.
function STOP_Callback(hObject, eventdata, handles)
set(handles.START,'UserData',0)
drawnow
disp('Stopped');



function LetPolarizationArrive_Callback(hObject, eventdata, handles)
% hObject    handle to LetPolarizationArrive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LetPolarizationArrive as text
%        str2double(get(hObject,'String')) returns contents of LetPolarizationArrive as a double


% --- Executes during object creation, after setting all properties.
function LetPolarizationArrive_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LetPolarizationArrive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function LogBook_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LogBook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
VV=round(get(handles.slider1,'value'));
try
delete(handles.CurrentMarker);
end
hold(handles.GDET,'on');
handles.CurrentMarker=plot(handles.GDET,handles.PlotK(VV),handles.PlotGD1(VV),'ok');
hold(handles.GDET,'off');
handles.Output(VV).Z
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
VV=round(get(handles.slider1,'value'));
if(isfield(handles.Output(1),'Kexpected'))
    Z=handles.Output(VV).Z;
    lcaPutNoWait('USEG:UND1:3350:1:MOTR',Z(1));
    lcaPutNoWait('USEG:UND1:3350:2:MOTR',Z(2));
    lcaPutNoWait('USEG:UND1:3350:3:MOTR',Z(3));
    lcaPutNoWait('USEG:UND1:3350:4:MOTR',Z(4));
elseif(isfield(handles.Output(1),'PhaseShifter'))
    lcaPutNoWait('PHAS:UND1:3340:MOTR',handles.Output(VV).PhaseShifter);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
CurrentTime=clock;
CurrentYearString=num2str(CurrentTime(1),'%.4d');
CurrentMonthString=num2str(CurrentTime(2),'%.2d');
CurrentDieiString=num2str(CurrentTime(3),'%.2d');
CurrentTempo1String=num2str(CurrentTime(4),'%.2d');
CurrentTempo2String=num2str(CurrentTime(5),'%.2d');
CurrentTempo3String=num2str(floor(CurrentTime(6)),'%.2d');
CurrentTempo4String=num2str(round((CurrentTime(6)-floor(CurrentTime(6)))*1000),'%.3d');
[FILENAME, PATHNAME] = uigetfile(['/u1/lcls/matlab/data/',CurrentYearString,'/',CurrentYearString,'-',CurrentMonthString,'/',CurrentYearString,'-',CurrentMonthString,'-',CurrentDieiString,'/DeltaScan*.*'], 'pick the file');
load([PATHNAME,FILENAME]);
handles.Output=DeltaScan;
guidata(hObject, handles);
set(handles.DIA,'string',(['Loaded']));
% 
% plot(handles.GDET,PlotK,PlotGD1,'*b'); hold(handles.GDET,'on');
% if(PVTBR(1)), plot(handles.GDET,PlotK,PlotGD2,'*r');, end
% if(PVTBR(2)), plot(handles.GDET,PlotK,PlotGD3,'*k');, end
% if(PVTBR(3)) ,plot(handles.GDET,PlotK,PlotGD4,'*g');, end, hold(handles.GDET,'off');
% xlim(handles.GDET,[min(KEQPATH),max(KEQPATH)]);
% if(sum(SKIP_POL)<II)
%     plot(handles.POL,PlotK(~SKIP_POL),PlotLin(~SKIP_POL),'*k');
% end
% if(sum(SKIP_ANG)<II)
%     plot(handles.ANGLE,PlotK(~SKIP_ANG),PlotAng(~SKIP_ANG),'*k');
% end
% xlim(handles.POL,[min(KEQPATH),max(KEQPATH)]);
% xlim(handles.ANGLE,[min(KEQPATH),max(KEQPATH)]);
% save LOCALSAVE





% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DoNOT.
function DoNOT_Callback(hObject, eventdata, handles)
% hObject    handle to DoNOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoNOT


% --- Executes on button press in donot2.
function donot2_Callback(hObject, eventdata, handles)
% hObject    handle to donot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of donot2


% --- Executes on button press in MoveAgainSamePosition.
function MoveAgainSamePosition_Callback(hObject, eventdata, handles)
currentdata=get(handles.MoveAgainSamePosition,'userdata');
if(~isempty(currentdata))
    if(numel(currentdata==1)) %PS      
        lcaPutNoWait('PHAS:UND1:3340:MOTR',currentdata);
    elseif(numel(currentdata==4)) %Z
        lcaPutNoWait('USEG:UND1:3350:1:MOTR',currentdata(1));
        lcaPutNoWait('USEG:UND1:3350:2:MOTR',currentdata(2));
        lcaPutNoWait('USEG:UND1:3350:3:MOTR',currentdata(3));
        lcaPutNoWait('USEG:UND1:3350:4:MOTR',currentdata(4));
    end
end
