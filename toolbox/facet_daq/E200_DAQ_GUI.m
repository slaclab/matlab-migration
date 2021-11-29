function varargout = E200_DAQ_GUI(varargin)
% E200_DAQ_GUI M-file for E200_DAQ_GUI.fig
%      E200_DAQ_GUI, by itself, creates a new E200_DAQ_GUI or raises the existing
%      singleton*.
%
%      H = E200_DAQ_GUI returns the handle to a new E200_DAQ_GUI or the handle to
%      the existing singleton*.
%
%      E200_DAQ_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in E200_DAQ_GUI.M with the given input arguments.
%
%      E200_DAQ_GUI('Property','Value',...) creates a new E200_DAQ_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before E200_DAQ_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to E200_DAQ_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help E200_DAQ_GUI

% Last Modified by GUIDE v2.5 25-Mar-2016 06:07:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @E200_DAQ_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @E200_DAQ_GUI_OutputFcn, ...
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


% --- Executes just before E200_DAQ_GUI is made visible.
function E200_DAQ_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to E200_DAQ_GUI (see VARARGIN)

% Choose default command line output for E200_DAQ_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%addpath('/usr/local/facet/tools/matlab/toolbox/facet_daq/E200_DAQ_GUI_path/');
% addpath('/home/fphysics/joelfred/matlab_mv/toolbox/facet_daq');
handles=scanDefaults(hObject,handles,1);
handles=scanDefaults(hObject,handles,2);

% guidata(hObject,handles);

camlist = cam_list();
handles.camlist=camlist;
% str = [strcat(num2str(cell2mat(camlist(:,4))), ' - ', 	camlist(:,1))];
set(handles.Cameralist,'String',camlist.AD_CAMS.NAMES);
% display(get(handles.Cameralist,'Value'));
% camind = find(cell2mat(camlist(:,3)));
% set(handles.Cameralist,'Value',camind');

camdisplay(handles);
guidata(hObject,handles);
global hl;
hl=handles;

% UIWAIT makes E200_DAQ_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = E200_DAQ_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ExperimentStr_Callback(hObject, eventdata, handles)
% hObject    handle to ExperimentStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExperimentStr as text
%        str2double(get(hObject,'String')) returns contents of ExperimentStr as a double


% --- Executes during object creation, after setting all properties.
function ExperimentStr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExperimentStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cameralist.
function Cameralist_Callback(hObject, eventdata, handles)
% hObject    handle to Cameralist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Cameralist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Cameralist

% display(get(hObject,'Value'))
camdisplay(handles)


% --- Executes during object creation, after setting all properties.
function Cameralist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cameralist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Rundaq.
function Rundaq_Callback(hObject, eventdata, handles)
% hObject    handle to Rundaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rundaq(handles);

function Commentstring_Callback(hObject, eventdata, handles)
% hObject    handle to Commentstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Commentstring as text
%        str2double(get(hObject,'String')) returns contents of Commentstring as a double


% --- Executes during object creation, after setting all properties.
function Commentstring_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Commentstring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Savefacet.
function Savefacet_Callback(hObject, eventdata, handles)
% hObject    handle to Savefacet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Savefacet


% --- Executes on button press in SaveE200.
function SaveE200_Callback(hObject, eventdata, handles)
% hObject    handle to SaveE200 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveE200


% --- Executes on button press in Savebackground.
function Savebackground_Callback(hObject, eventdata, handles)
% hObject    handle to Savebackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Savebackground



function Numberofshots_Callback(hObject, eventdata, handles)
% hObject    handle to Numberofshots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Numberofshots as text
%        str2double(get(hObject,'String')) returns contents of Numberofshots as a double


% --- Executes during object creation, after setting all properties.
function Numberofshots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Numberofshots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Print2elog.
function Print2elog_Callback(hObject, eventdata, handles)
% hObject    handle to Print2elog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Print2elog


% --- Executes on button press in AIDAdaq.
function AIDAdaq_Callback(hObject, eventdata, handles)
% hObject    handle to AIDAdaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AIDAdaq


% --- Executes on button press in Daqscan.
function Daqscan_Callback(hObject, eventdata, handles)
% hObject    handle to Daqscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Daqscan

% Enable scan controls
handles = enableDAQ(handles);




% --- Executes on selection change in Scanfunction.
function Scanfunction_Callback(hObject, eventdata, handles)
% hObject    handle to Scanfunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Scanfunction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Scanfunction

handles=scanDefaults(hObject,handles,1);

set(handles.Setfunctionval,'Enable','on');
set(handles.Setfunction,'Enable','on');

        
        


% --- Executes during object creation, after setting all properties.
function Scanfunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanfunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanstartval_Callback(hObject, eventdata, handles)
% hObject    handle to Scanstartval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanstartval as text
%        str2double(get(hObject,'String')) returns contents of Scanstartval as a double

Setscanval(handles,1);


% --- Executes during object creation, after setting all properties.
function Scanstartval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanstartval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanendval_Callback(hObject, eventdata, handles)
% hObject    handle to Scanendval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanendval as text
%        str2double(get(hObject,'String')) returns contents of Scanendval as a double

Setscanval(handles,1);


% --- Executes during object creation, after setting all properties.
function Scanendval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanendval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanstepsval_Callback(hObject, eventdata, handles)
% hObject    handle to Scanstepsval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanstepsval as text
%        str2double(get(hObject,'String')) returns contents of Scanstepsval as a double

Setscanval(handles,1);


% --- Executes during object creation, after setting all properties.
function Scanstepsval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanstepsval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanvaluesstr_Callback(hObject, eventdata, handles)
% hObject    handle to Scanvaluesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanvaluesstr as text
%        str2double(get(hObject,'String')) returns contents of Scanvaluesstr as a double


% --- Executes during object creation, after setting all properties.
function Scanvaluesstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanvaluesstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Setfunctionval_Callback(hObject, eventdata, handles)
% hObject    handle to Setfunctionval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Setfunctionval as text
%        str2double(get(hObject,'String')) returns contents of Setfunctionval as a double


% --- Executes during object creation, after setting all properties.
function Setfunctionval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Setfunctionval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Setfunction.
function Setfunction_Callback(hObject, eventdata, handles)
% hObject    handle to Setfunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.func(str2num(get(handles.Setfunctionval,'String')));


% --- Executes on button press in UseCMOS.
% function UseCMOS_Callback(hObject, eventdata, handles)
% % hObject    handle to UseCMOS (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of UseCMOS
% if get(hObject,'Value')
%     cameras = get(handles.Cameralist,'String');
%     cameras = [cameras; 'CMOS'];
%     set(handles.Cameralist,'String',cameras);
% else
%     cameras = get(handles.Cameralist,'String');
%     cm_ind = strcmp('CMOS',cameras);
%     cameras = cameras(~cm_ind);
%     set(handles.Cameralist,'String',cameras);
% end



function camDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to camDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of camDisplay as text
%        str2double(get(hObject,'String')) returns contents of camDisplay as a double


% --- Executes during object creation, after setting all properties.
function camDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in eventcode213.
function eventcode213_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode213 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode213
set(handles.eventcode233,'Value',0);
set(handles.eventcode223,'Value',0);
set(handles.eventcode225,'Value',0);
set(handles.eventcode53,'Value',0);
set(handles.eventcode229,'Value',0);
set(handles.eventcode231,'Value',0);


% --- Executes on button press in eventcode233.
function eventcode233_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode233 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode233
set(handles.eventcode213,'Value',0);
set(handles.eventcode223,'Value',0);
set(handles.eventcode225,'Value',0);
set(handles.eventcode53,'Value',0);
set(handles.eventcode229,'Value',0);
set(handles.eventcode231,'Value',0);


% --- Executes on selection change in Scanfunction2.
function Scanfunction2_Callback(hObject, eventdata, handles)
% hObject    handle to Scanfunction2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Scanfunction2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Scanfunction2

handles=scanDefaults(hObject,handles,2);

set(handles.Setfunctionval2,'Enable','on');
set(handles.Setfunction2,'Enable','on');

% --- Executes during object creation, after setting all properties.
function Scanfunction2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanfunction2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanstartval2_Callback(hObject, eventdata, handles)
% hObject    handle to Scanstartval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanstartval2 as text
%        str2double(get(hObject,'String')) returns contents of Scanstartval2 as a double

Setscanval(handles,2);

% --- Executes during object creation, after setting all properties.
function Scanstartval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanstartval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanendval2_Callback(hObject, eventdata, handles)
% hObject    handle to Scanendval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanendval2 as text
%        str2double(get(hObject,'String')) returns contents of Scanendval2 as a double

Setscanval(handles,2);

% --- Executes during object creation, after setting all properties.
function Scanendval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanendval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanstepsval2_Callback(hObject, eventdata, handles)
% hObject    handle to Scanstepsval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanstepsval2 as text
%        str2double(get(hObject,'String')) returns contents of Scanstepsval2 as a double

Setscanval(handles,2);

% --- Executes during object creation, after setting all properties.
function Scanstepsval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanstepsval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Scanvaluesstr2_Callback(hObject, eventdata, handles)
% hObject    handle to Scanvaluesstr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Scanvaluesstr2 as text
%        str2double(get(hObject,'String')) returns contents of Scanvaluesstr2 as a double


% --- Executes during object creation, after setting all properties.
function Scanvaluesstr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scanvaluesstr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Scan2d.
function Scan2d_Callback(hObject, eventdata, handles)
% hObject    handle to Scan2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Scan2d
handles = enableDAQ_2D(handles);


function Setfunctionval2_Callback(hObject, eventdata, handles)
% hObject    handle to Setfunctionval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Setfunctionval2 as text
%        str2double(get(hObject,'String')) returns contents of Setfunctionval2 as a double


% --- Executes during object creation, after setting all properties.
function Setfunctionval2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Setfunctionval2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Setfunction2.
function Setfunction2_Callback(hObject, eventdata, handles)
% hObject    handle to Setfunction2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.func2(str2num(get(handles.Setfunctionval2,'String')));


% --- Executes on button press in attenuate_laser.
function attenuate_laser_Callback(hObject, eventdata, handles)
% hObject    handle to attenuate_laser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_laser_alignment_attenuation();

% --- Executes on button press in full_power_laser.
function full_power_laser_Callback(hObject, eventdata, handles)
% hObject    handle to full_power_laser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_laser_full_power();


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Rundaq.
function Rundaq_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Rundaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This is the abort button used to stop a scan when in progress.  When the
% button it pressed the value of a specific PV is changed from 0 to 1. 

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Attempting to abort!')
% update the PV
lcaPut('SIOC:SYS1:ML01:AO548',1);


% --- Executes on button press in eventcode223.
function eventcode223_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode223 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode223
set(handles.eventcode213,'Value',0);
set(handles.eventcode233,'Value',0);
set(handles.eventcode225,'Value',0);
set(handles.eventcode53,'Value',0);
set(handles.eventcode229,'Value',0);
set(handles.eventcode231,'Value',0);

% --- Executes on button press in eventcode225.
function eventcode225_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode225 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode225
set(handles.eventcode213,'Value',0);
set(handles.eventcode233,'Value',0);
set(handles.eventcode223,'Value',0);
set(handles.eventcode53,'Value',0);
set(handles.eventcode229,'Value',0);
set(handles.eventcode231,'Value',0);

% --- Executes on button press in eventcode53.
function eventcode53_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode53
set(handles.eventcode213,'Value',0);
set(handles.eventcode233,'Value',0);
set(handles.eventcode223,'Value',0);
set(handles.eventcode225,'Value',0);
set(handles.eventcode229,'Value',0);
set(handles.eventcode231,'Value',0);


% --- Executes on button press in set_QS_trim.
function set_QS_trim_Callback(hObject, eventdata, handles)
% hObject    handle to set_QS_trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_QS_trim()



function QS_z_ob_Callback(hObject, eventdata, handles)
% hObject    handle to QS_z_ob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QS_z_ob as text
%        str2double(get(hObject,'String')) returns contents of QS_z_ob as a double

z_ob = str2double(get(hObject, 'String'));
lcaPutSmart('SIOC:SYS1:ML03:AO001', z_ob);


% --- Executes during object creation, after setting all properties.
function QS_z_ob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QS_z_ob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QS_z_im_Callback(hObject, eventdata, handles)
% hObject    handle to QS_z_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QS_z_im as text
%        str2double(get(hObject,'String')) returns contents of QS_z_im as a double

z_im = str2double(get(hObject, 'String'));
lcaPutSmart('SIOC:SYS1:ML03:AO002', z_im);

% --- Executes during object creation, after setting all properties.
function QS_z_im_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QS_z_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function QS_energy_setpoint_Callback(hObject, eventdata, handles)
% hObject    handle to QS_energy_setpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QS_energy_setpoint as text
%        str2double(get(hObject,'String')) returns contents of QS_energy_setpoint as a double
QS = str2double(get(hObject, 'String'));
lcaPutSmart('SIOC:SYS1:ML03:AO003', QS);


% --- Executes during object creation, after setting all properties.
function QS_energy_setpoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QS_energy_setpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over QS_z_im.
function QS_z_im_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to QS_z_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PENTRANCE.
function PENTRANCE_Callback(hObject, eventdata, handles)
% hObject    handle to PENTRANCE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML03:AO001', 1993.45);
set(handles.('QS_z_ob'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO001'));


% --- Executes on button press in PCENTER.
function PCENTER_Callback(hObject, eventdata, handles)
% hObject    handle to PCENTER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML03:AO001', 1994.15);
set(handles.('QS_z_ob'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO001'));


% --- Executes on button press in PEXT.
function PEXT_Callback(hObject, eventdata, handles)
% hObject    handle to PEXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML03:AO001', 1994.85);
set(handles.('QS_z_ob'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO001'));


% --- Executes on button press in elan.
function elan_Callback(hObject, eventdata, handles)
% hObject    handle to elan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML03:AO002', 2015.22);
set(handles.('QS_z_im'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO002'));



% --- Executes on button press in wlan.
function wlan_Callback(hObject, eventdata, handles)
% hObject    handle to wlan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lcaPutSmart('SIOC:SYS1:ML03:AO002', 2015.61);
set(handles.('QS_z_im'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO002'));


% --- Executes on button press in update_QS_PVs.
function update_QS_PVs_Callback(hObject, eventdata, handles)
% hObject    handle to update_QS_PVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.('QS_z_ob'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO001'));
set(handles.('QS_z_im'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO002'));
set(handles.('QS_energy_setpoint'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO003'));


% --- Executes on button press in ChangeAngleButton.
function ChangeAngleButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeAngleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pivotAngle(lcaGetSmart('SIOC:SYS1:ML03:AO044'),lcaGetSmart('SIOC:SYS1:ML03:AO045'));



function AngleXWindow_Callback(hObject, eventdata, handles)
% hObject    handle to AngleXWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AngleX = str2double(get(hObject, 'String'));
lcaPutSmart('SIOC:SYS1:ML03:AO044', AngleX);


% Hints: get(hObject,'String') returns contents of AngleXWindow as text
%        str2double(get(hObject,'String')) returns contents of AngleXWindow as a double


% --- Executes during object creation, after setting all properties.
function AngleXWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleXWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AngleYWindow_Callback(hObject, eventdata, handles)
% hObject    handle to AngleYWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AngleY = str2double(get(hObject, 'String'));
lcaPutSmart('SIOC:SYS1:ML03:AO045', AngleY);


% Hints: get(hObject,'String') returns contents of AngleYWindow as text
%        str2double(get(hObject,'String')) returns contents of AngleYWindow as a double


% --- Executes during object creation, after setting all properties.
function AngleYWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AngleYWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitable1.

% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Update.
function Update_Callback(hObject, eventdata, handles)
% hObject    handle to Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.('AngleXWindow'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO044'));
set(handles.('AngleYWindow'), 'String', lcaGetSmart('SIOC:SYS1:ML03:AO045'));


% --- Executes on button press in eventcode229.
function eventcode229_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode229 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode229
set(handles.eventcode213,'Value',0);
set(handles.eventcode233,'Value',0);
set(handles.eventcode223,'Value',0);
set(handles.eventcode225,'Value',0);
set(handles.eventcode53,'Value',0);
set(handles.eventcode231,'Value',0);

% --- Executes on button press in eventcode231.
function eventcode231_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode231 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eventcode231
set(handles.eventcode213,'Value',0);
set(handles.eventcode233,'Value',0);
set(handles.eventcode223,'Value',0);
set(handles.eventcode225,'Value',0);
set(handles.eventcode229,'Value',0);
set(handles.eventcode53,'Value',0);


% --- Executes on button press in updateAx1BM.
function updateAx1BM_Callback(hObject, eventdata, handles)
% hObject    handle to updateAx1BM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateBM_AxImg1();


% --- Executes on button press in updateAx2BM.
function updateAx2BM_Callback(hObject, eventdata, handles)
% hObject    handle to updateAx2BM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateBM_AxImg2();


% --- Executes on button press in autoalign.
function autoalign_Callback(hObject, eventdata, handles)
% hObject    handle to autoalign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

autoalign2AxImgBM();


% --- Executes on button press in Move_ELAN.
function Move_ELAN_Callback(hObject, eventdata, handles)
% hObject    handle to Move_ELAN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = get(hObject,'Value');
lcaPutSmart('SIOC:SYS1:ML03:AO004',state);

% Hint: get(hObject,'Value') returns toggle state of Move_ELAN


% --- Executes on button press in updateAx3BM.
function updateAx3BM_Callback(hObject, eventdata, handles)
% hObject    handle to updateAx3BM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateBM_AxImg3();
