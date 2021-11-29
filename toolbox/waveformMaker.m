function varargout = waveformMaker(varargin)
% WAVEFORMMAKER MATLAB code for waveformMaker.fig
%      WAVEFORMMAKER, by itself, creates a new WAVEFORMMAKER or raises the existing
%      singleton*.
%
%      H = WAVEFORMMAKER returns the handle to a new WAVEFORMMAKER or the handle to
%      the existing singleton*.
%
%      WAVEFORMMAKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WAVEFORMMAKER.M with the given input arguments.
%
%      WAVEFORMMAKER('Property','Value',...) creates a new WAVEFORMMAKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before waveformMaker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to waveformMaker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help waveformMaker

% Last Modified by GUIDE v2.5 02-Jul-2014 11:40:16

%TODO: Use phase and amplitude as well as I and Q.
%TODO: ADD FACET TCAV and ASTA GUN.
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @waveformMaker_OpeningFcn, ...
                   'gui_OutputFcn',  @waveformMaker_OutputFcn, ...
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

% --- Executes just before waveformMaker is made visible.
function waveformMaker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to waveformMaker (see VARARGIN)

% Choose default command line output for waveformMaker
handles.output = hObject;
handles.b = 0;
handles.slope =  0;
handles.pt1 = 0;
handles.pt2 = 1000;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using waveformMaker.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes waveformMaker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = waveformMaker_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in load_pushbutton.
function load_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
fid  = fopen([handles.dir, handles.fileQ],'r');
w = textscan(fid, '%s'); w = w{:}; w= cellfun(@str2num,w);
fclose(fid);
handles.wf0 = w;
handles.wf1 = w;
t = (0:2048-1)/102e6*1e9; %time in ns
handles.t = t;
handles.pltH = plot(t,w,t,w,'-o');
figure, plot(t,w,'.-'); xlabel('Time (ns)'), title([handles.dir, handles.fileI])
handles.pt1 = [t(1) w(1)]; handles.pt2 = [t(2) w(2)];
set(handles.pt1_edit,'String',sprintf('[%.0f, %.0f]', handles.pt1));
set(handles.pt2_edit,'String',sprintf('[%.0f, %.0f]', handles.pt2));
stepI = find(diff(w) ~= 0);
stepI(abs(diff(stepI)) ==1) = [];
disp('Large Steps found at')
for ii = 1:length(stepI)
    fprintf('[%.0f %.0f] to [%.0f %.0f]\n', ...
    handles.t(stepI(ii)), w(stepI(ii)), handles.t(stepI(ii)+1), w(stepI(ii)+1))
end

guidata(hObject,handles);



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


function slope_edit_Callback(hObject, eventdata, handles)
slope = str2double(get(hObject,'String'));
handles.slope = slope;
guidata(hObject,handles)
updateWaveform(hObject,'slope', slope, handles);

function intercept_edit_Callback(hObject, eventdata, handles)
b = str2double(get(hObject,'String'));
handles.intercept = b;
guidata(hObject,handles)
updateWaveform(hObject,'b',b,handles);

function pt1_edit_Callback(hObject, eventdata, handles)
pt1 = eval(get(hObject,'String'));
handles.pt1 = pt1;
guidata(hObject,handles)
updateWaveform(hObject,'pt1',pt1,handles);

function pt2_edit_Callback(hObject, eventdata, handles)
pt2 = eval(get(hObject,'String'));
handles.pt2 = pt2;
guidata(hObject,handles)
updateWaveform(hObject,'pt2',pt2,handles);

function updateWaveform(hObject, choice, value, handles)
m = handles.slope; b = handles.b; pt1 = handles.pt1; pt2 = handles.pt2;

switch choice
    case 'slope', m = value; b = -m*pt1(1) + pt1(2);
    case 'b', b = value; m = (pt1(2) - b)/pt1(1);
    case 'pt1', pt1 = value;
    case 'pt2', pt2 = value;
end
range = find(handles.t >= pt1(1) & handles.t <= pt2(1));
if length(range) <=1 || isempty(range), 
    disp('Time is zero or negative. Nothing Done...'); 
    return
end

if strncmp( 'pt',choice,2)
    m = (pt2(2) - pt1(2)) / (pt2(1) - pt1(1));
    b = -m*pt1(1) + pt1(2);
end
y = m*handles.t(range) + b;
handles.pt1 = [handles.t(range(1)) y(1)];
handles.pt2 = [handles.t(range(end)) y(end)];
handles.slope = m;
handles.intercept = b;
handles.wf1(range) =  y;
set(handles.pt1_edit,'String', sprintf('[%.1f, %.1f]', handles.pt1))
set(handles.pt2_edit,'String', sprintf('[%.1f, %.1f]', handles.pt2))
set(handles.slope_edit, 'String', sprintf('%.2f',m));
set(handles.intercept_edit, 'String', sprintf('%.2f',b));
set(handles.pltH(2), 'YData', handles.wf1)




guidata(hObject,handles)





% --- Executes on selection change in waveForm_popupmenu.
function waveForm_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to waveForm_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
%         returns selected item from selectStation_popupmenu

selected  = contents{get(hObject,'Value')};
switch selected
    case 'CecileN85'
        handles.fileI = 'CecileN85I.dat'; 
        handles.fileQ =  'CecileN85Q.dat';  
        fileI_out = 'CecileN85I.dat'; 
        fileQ_out =  'CecileN85Q.dat';  
    case 'Sample2'
        handles.fileI = 'Sample2I.dat'; 
        handles.fileQ =  'Sample2Q.dat';  
        fileI_out = 'CecileN85I.dat'; 
        fileQ_out =  'CecileN85Q.dat';  % To be safe, even if loading sample 2, set save to Cecile
end
handles.fileI_out = fileI_out;
handles.fileQ_out = fileQ_out;
set(handles.file_I_text,'String', handles.fileI)
set(handles.file_Q_text,'String', handles.fileQ)
set(handles.fileI_out_edit,'String', fileI_out)
set(handles.fileQ_out_edit,'String', fileQ_out)
guidata(hObject,handles)





% --- Executes during object creation, after setting all properties.
function waveForm_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waveForm_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fidOut = fopen([handles.dir, handles.fileI_out], 'w');
for ii  =1:length(handles.wf1)
fprintf(fidOut,'%s\n',num2str(fix(handles.wf1(ii))));
end
fclose(fidOut);
fidOut = fopen([handles.dir, handles.fileQ_out], 'w');
for ii  =1:length(handles.wf1)
fprintf(fidOut,'%s\n',num2str(fix(handles.wf1(ii))));
end
fclose(fidOut);
disp(['Saved files in ' handles.dir])
dir([handles.dir, handles.fileI_out])
dir([handles.dir, handles.fileQ_out])


% --- Executes on button press in copyPt_pushbutton.
function copyPt_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to copyPt_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pt1 = handles.pt2;
set(handles.pt1_edit, 'String', sprintf('[%.1f, %.1f]', handles.pt1))
guidata(hObject, handles)

% --- Executes on selection change in selectStation_popupmenu.
function selectStation_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to selectStation_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
%         returns selected item from selectStation_popupmenu

selected  = contents{get(hObject,'Value')};
switch selected
    case 'L1S'
        handles.dir =  '/u1/lcls/epics/ioc/data/eioc-in20-rc11/iocInfo/';
        handles.fileI = 'CecileN85I.dat'; 
        handles.fileQ =  'CecileN85Q.dat';  
end
set(handles.dirTxt,'String', handles.dir)
set(handles.file_I_text,'String', handles.fileI)
set(handles.file_Q_text,'String', handles.fileQ)
guidata(hObject,handles)

    


% --- Executes during object creation, after setting all properties.
function selectStation_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectStation_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pt2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pt2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pt1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pt1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function intercept_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intercept_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end 

% --- Executes during object creation, after setting all properties.
function slope_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slope_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fileI_out_edit_Callback(hObject, eventdata, handles)
handles.fileI_out = get(hObject,'String') ;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function fileI_out_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fileQ_out_edit_Callback(hObject, eventdata, handles)
handles.fileQ_out = get(hObject,'String') ;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function fileQ_out_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileQ_out_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
value = get(hObject,'String');
handles.fileQ = value;
guidata(hObject,handles);



function file_I_text_Callback(hObject, eventdata, handles)
% hObject    handle to file_I_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_I_text as text
%        str2double(get(hObject,'String')) returns contents of file_I_text as a double
value = get(hObject,'String');
handles.fileI = value;
guidata(hObject,handles);

function [ampl phas] = iq2ap(I, Q)
I_Q_complex = I + j*Q;
ampl = abs(I_Q_complex);
phas = 180*unwrap(angle(I_Q_complex))/pi;
phas = mod(phas,360);

 
 
