function varargout = BSA_Data_Analyzer(varargin)
% BSA_DATA_ANALYZER MATLAB code for BSA_Data_Analyzer.fig
%      BSA_DATA_ANALYZER, by itself, creates a new BSA_DATA_ANALYZER or raises the existing
%      singleton*.
%
%      H = BSA_DATA_ANALYZER returns the handle to a new BSA_DATA_ANALYZER or the handle to
%      the existing singleton*.
%
%      BSA_DATA_ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BSA_DATA_ANALYZER.M with the given input arguments.
%
%      BSA_DATA_ANALYZER('Property','Value',...) creates a new BSA_DATA_ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BSA_Data_Analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BSA_Data_Analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BSA_Data_Analyzer

% Last Modified by GUIDE v2.5 03-Jun-2015 13:28:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BSA_Data_Analyzer_OpeningFcn, ...
                   'gui_OutputFcn',  @BSA_Data_Analyzer_OutputFcn, ...
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


% --- Executes just before BSA_Data_Analyzer is made visible.
function BSA_Data_Analyzer_OpeningFcn(hObject, eventdata, handles, varargin) 
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BSA_Data_Analyzer (see VARARGIN)

% Choose default command line output for BSA_Data_Analyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BSA_Data_Analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BSA_Data_Analyzer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






function MONTH_Callback(hObject, eventdata, handles)
% hObject    handle to MONTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MONTH as text
%        str2double(get(hObject,'String')) returns contents of MONTH as a double
Month_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function MONTH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MONTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YEAR_Callback(hObject, eventdata, handles)
% hObject    handle to YEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YEAR as text
%        str2double(get(hObject,'String')) returns contents of YEAR as a double
Year_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function YEAR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YEAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DAY_Callback(hObject, eventdata, handles)
% hObject    handle to DAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DAY as text
%        str2double(get(hObject,'String')) returns contents of DAY as a double
Day_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function DAY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TIME_Callback(hObject, eventdata, handles)
% hObject    handle to TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TIME as text
%        str2double(get(hObject,'String')) returns contents of TIME as a double
Time_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function TIME_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BeamEnergy_Callback(hObject, eventdata, handles)
% hObject    handle to BeamEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BeamEnergy as text
%        str2double(get(hObject,'String')) returns contents of BeamEnergy as a double
BeamEnergy_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function BeamEnergy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BeamEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PM1_BACT_Callback(hObject, eventdata, handles)
% hObject    handle to PM1_BACT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PM1_BACT as text
%        str2double(get(hObject,'String')) returns contents of PM1_BACT as a double
PM1_BACT_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function PM1_BACT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PM1_BACT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BSC_Callback(hObject, eventdata, handles)
% hObject    handle to BSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BSC as text
%        str2double(get(hObject,'String')) returns contents of BSC as a double
BSC_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function BSC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XCOR71_Callback(hObject, eventdata, handles)
% hObject    handle to XCOR71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XCOR71 as text
%        str2double(get(hObject,'String')) returns contents of XCOR71 as a double
XCOR071_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function XCOR71_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XCOR71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YCOR72_Callback(hObject, eventdata, handles)
% hObject    handle to YCOR72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YCOR72 as text
%        str2double(get(hObject,'String')) returns contents of YCOR72 as a double
YCOR72_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function YCOR72_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YCOR72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in JANICE_FIT.
function JANICE_FIT_Callback(hObject, eventdata, handles)
% hObject    handle to JANICE_FIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BSANUM={get(handles.YEAR,'String'), get(handles.MONTH,'String'), get(handles.DAY,'String'), get(handles.TIME,'String')};
fileName=strcat('/u1/lcls/matlab/data/',BSANUM(1),'/',BSANUM(1),'-',BSANUM(2),...
'/',BSANUM(1),'-',BSANUM(2),'-',BSANUM(3),'/BSA-data-',BSANUM(1),'-',BSANUM(2),'-',BSANUM(3),'-',BSANUM(4));
load(char(fileName));
Ebeam=str2num(get(handles.BeamEnergy,'String'));
BSC=str2num(get(handles.BSC,'String'));
bsanum=[str2num(char(BSANUM(2))) str2num(char(BSANUM(3))) str2num(char(BSANUM(4)))];
figure;
JANICE_UND_LAUNCH;


% --- Executes on button press in Und_Traj.
function Und_Traj_Callback(hObject, eventdata, handles)
% hObject    handle to Und_Traj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get(handles.YEAR,'String')
BSANUM={get(handles.YEAR,'String'),get(handles.MONTH,'String'), get(handles.DAY,'String'), get(handles.TIME,'String')};
fileName=strcat('/u1/lcls/matlab/data/',BSANUM(1),'/',BSANUM(1),'-',BSANUM(2),...
    '/',BSANUM(1),'-',BSANUM(2),'-',BSANUM(3),'/BSA-data-',BSANUM(1),'-',BSANUM(2),'-',BSANUM(3),'-',BSANUM(4));
load(char(fileName));
Ebeam=str2num(get(handles.BeamEnergy,'String'));
PM1=str2num(get(handles.PM1_BACT,'String'));
BSC=str2num(get(handles.BSC,'String'));
XC71=str2num(get(handles.XCOR71,'String'));
YC72=str2num(get(handles.YCOR72,'String'));
bsanum=[str2num(char(BSANUM(2))) str2num(char(BSANUM(3))) str2num(char(BSANUM(4)))];
RunNum=[str2num(get(handles.RUNnumA,'String')) str2num(get(handles.RUNnumB,'String'))];
figure;
BS_finder;



function RUNnumA_Callback(hObject, eventdata, handles)
% hObject    handle to RUNnumA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RUNnumA as text
%        str2double(get(hObject,'String')) returns contents of RUNnumA as a double
RUNNUMA_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function RUNnumA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RUNnumA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RUNnumB_Callback(hObject, eventdata, handles)
% hObject    handle to RUNnumB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RUNnumB as text
%        str2double(get(hObject,'String')) returns contents of RUNnumB as a double
RUNNUMB_StrVal = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function RUNnumB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RUNnumB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
