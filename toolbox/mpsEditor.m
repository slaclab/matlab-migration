function varargout = mpsEditor(varargin)
% MPSEDITOR M-file for mpsEditor.fig
%      MPSEDITOR, by itself, creates a new MPSEDITOR or raises the existing
%      singleton*.
%
%      H = MPSEDITOR returns the handle to a new MPSEDITOR or the handle to
%      the existing singleton*.
%
%      MPSEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MPSEDITOR.M with the given input arguments.
%
%      MPSEDITOR('Property','Value',...) creates a new MPSEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mpsEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mpsEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mpsEditor

% Last Modified by GUIDE v2.5 09-Feb-2009 09:28:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mpsEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @mpsEditor_OutputFcn, ...
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


% --- Executes just before mpsEditor is made visible.
function mpsEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mpsEditor (see VARARGIN)

% Choose default command line output for mpsEditor
handles.output = hObject;
%get device list from file (Optional)
dirInfo = dir('deviceInfo.mat');
if isempty(dirInfo), 
    fprintf('No deviceInfo.mat file found in %s\n creating one\n',pwd), 
    handles.device.name = '';
else
    load deviceInfo.mat
    handles.device = device;
end

set(handles.deviceList,'String',{handles.device.name})
set(handles.mpsEditorFig,'Name',['mpsEdit - Directory:  ', pwd, '  File: deviceInfo.mat'])

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes mpsEditor wait for user response (see UIRESUME)
% uiwait(handles.mpsEditorFig);

% --- Outputs from this function are returned to the command line.
function varargout = mpsEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in InputsList.
function InputsList_Callback(hObject, eventdata, handles)
% hObject    handle to InputsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns InputsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from InputsList


% --- Executes during object creation, after setting all properties.
function InputsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Read file that is active (for now).
algDbVer = lcaGet('IOC:BSY0:MP01:ALGRMPSDBVERS');
linkNodeFile = ['/usr/local/lcls/epics/iocTop/MachineProtection/mpsConfiguration/database/', ...
                algDbVer{:}, '/csv/LinkNodeChannel.csv'];

fid = fopen(linkNodeFile);
textscan(fid,'%s',1); %read out '#'
formatStr = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s ';
head = textscan(fid,formatStr,1,'delimiter', ',');
data = textscan(fid,formatStr,'delimiter', ',');
fclose(fid);

head = [head{:}];
data = [data{:}]; %removes one layer of cell array.
mpsDeviceNames = data(:,strmatch('device_name',head));
if (strcmp(get(hObject,'Tag'), 'InputsList')), set(hObject,'String',mpsDeviceNames); end


% --- Executes on button press in inputToDevice.
function inputToDevice_Callback(hObject, eventdata, handles)
% hObject    handle to inputToDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputVal = get(handles.InputsList, 'Value');
inputStr = get(handles.InputsList, 'String');
devIndx = get(handles.deviceList, 'Value');
device = handles.device(devIndx);
%device.inputs(end+1) = inputStr(inputVal);
if strcmp('',device.inputs{1})
    device.inputs = inputStr(inputVal);
else
    device.inputs = [device.inputs; inputStr(inputVal)];
end

numInputs = length(device.inputs);
numStates = 2^numInputs;
newStIndx = size(device.rate,2) + 1;
for ii = 1:device.tableCnt
    device.rate(ii, newStIndx: numStates) = {deal('0')};
    device.message(ii, newStIndx: numStates) = {deal('no Message')};
    %device.states(ii, newStIndx: numStates) = {deal('new State')};
    for jj = 1:numStates
        device.states(ii,jj) = {sprintf('%s %s',dec2bin(jj-1,numInputs),'state')  };
    end
end

% update states table and show table 1 on the terminal
set(handles.stateList,'String',device.states(1,:) );

for ii = 1:size(device.inputs,1),
    fprintf('%s  / ',device.inputs{ii})
end
fprintf('\nMask    Rate   Message\n');
for ii = 1:numStates,  
    fprintf('%s%s%s%s  %s\n',blanks(5),device.states{ii},blanks(5),...
        device.rate{ii}, device.message{ii});
end

% %These grow with table number move to add table...
% device.rate(1:numStates) = {deal('0')};
% device.message(1:numStates) = {deal('none')};
% device.destinationMask = [device.destinationMask; uint8([1 1 1 1 1 1 1 1])]; 
% device.rateMask = [device.rateMask; uint8([1 1 1 1 1 1 1 1 1 1])]; 
%  
handles.device(devIndx) = device;
save safeDeviceInfo handles

set(handles.deviceInputs,'String',{ handles.device(devIndx).inputs{:}} )
guidata(hObject, handles);

% --- Executes on selection change in deviceList.
function deviceList_Callback(hObject, eventdata, handles)
% hObject    handle to deviceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns deviceList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from deviceList
devIndx = get(hObject,'Value');
set(handles.deviceInputs,'String',handles.device(devIndx).inputs)
for ii = 1:handles.device(devIndx).tableCnt
    tableStr(ii) = {sprintf('Table %i',ii)};
end
set(handles.tableList,'Value',1);
set(handles.tableList,'String',tableStr)
set(handles.stateList,'Value',1);
set(handles.stateList,'String',handles.device(devIndx).states(1,1:end))
device = handles.device;
save deviceInfo device
showMask(hObject, eventdata, handles);
showRateAndMsg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function deviceList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deviceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in deviceInputs.
function deviceInputs_Callback(hObject, eventdata, handles)
% hObject    handle to deviceInputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns deviceInputs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from deviceInputs


% --- Executes during object creation, after setting all properties.
function deviceInputs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deviceInputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tableList.
function tableList_Callback(hObject, eventdata, handles)
% hObject    handle to tableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns tableList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tableList

tabNum = get(hObject,'Value');
devIndx = get(handles.deviceList, 'Value');
set(handles.stateList,'String', handles.device(devIndx).states(tabNum,1:end) );
showMask(hObject, eventdata, handles);
showRateAndMsg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function tableList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tableList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rate1.
function rate1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
setMask(hObject,eventdata, handles);

% --- Executes on button press in rate2.
function rate2_Callback(hObject, eventdata, handles)
% hObject    handle to rate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate2
setMask(hObject,eventdata, handles);

% --- Executes on button press in rate3.
function rate3_Callback(hObject, eventdata, handles)
% hObject    handle to rate2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate2
setMask(hObject,eventdata, handles);


% --- Executes on button press in rate4.
function rate4_Callback(hObject, eventdata, handles)
% hObject    handle to rate4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate4
setMask(hObject,eventdata, handles);


% --- Executes on button press in rate5.
function rate5_Callback(hObject, eventdata, handles)
% hObject    handle to rate5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate5
setMask(hObject,eventdata, handles);


% --- Executes on button press in rate6.
function rate6_Callback(hObject, eventdata, handles)
% hObject    handle to rate6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate6
setMask(hObject,eventdata, handles);


% --- Executes on button press in rate7.
function rate7_Callback(hObject, eventdata, handles)
% hObject    handle to rate7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate7
setMask(hObject,eventdata, handles);


% --- Executes on button press in rate8.
function rate8_Callback(hObject, eventdata, handles)
% hObject    handle to rate8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate8
setMask(hObject,eventdata, handles);

% --- Executes on button press in rate9.
function rate9_Callback(hObject, eventdata, handles)
% hObject    handle to rate9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate9
setMask(hObject,eventdata, handles);


% --- Executes on button press in rate10.
function rate10_Callback(hObject, eventdata, handles)
% hObject    handle to rate10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rate10
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest1.
function dest1_Callback(hObject, eventdata, handles)
% hObject    handle to dest1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest1
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest2.
function dest2_Callback(hObject, eventdata, handles)
% hObject    handle to dest2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest2
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest3.
function dest3_Callback(hObject, eventdata, handles)
% hObject    handle to dest3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest3
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest4.
function dest4_Callback(hObject, eventdata, handles)
% hObject    handle to dest4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest4
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest5.
function dest5_Callback(hObject, eventdata, handles)
% hObject    handle to dest5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest5
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest6.
function dest6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton17
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest7.
function dest7_Callback(hObject, eventdata, handles)
% hObject    handle to dest7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest7
setMask(hObject,eventdata, handles);


% --- Executes on button press in dest8.
function dest8_Callback(hObject, eventdata, handles)
% hObject    handle to dest8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dest8
setMask(hObject,eventdata, handles);


% --- Executes on button press in addTable.
function addTable_Callback(hObject, eventdata, handles)
% hObject    handle to addTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
devIndx = get(handles.deviceList, 'Value');
tableIndx = get(handles.tableList,'Value');
device = handles.device(devIndx);
device.rate = [device.rate; device.rate(tableIndx,:)];
device.message = [device.message; device.message(tableIndx,:)];
device.destinationMask = [device.destinationMask; device.destinationMask(tableIndx,:)];
device.rateMask = [device.rateMask; device.rateMask(tableIndx,:)];
device.states = [device.states; device.states(tableIndx,:)];
device.tableCnt = device.tableCnt + 1;
for ii = 1:device(devIndx).tableCnt
    tableStr(ii) = {sprintf('Table %i',ii)};
end
set(handles.tableList,'Value',device.tableCnt);
set(handles.tableList,'String',tableStr)

handles.device(devIndx) = device;
guidata(hObject, handles);

% --- Executes on selection change in stateList.
function stateList_Callback(hObject, eventdata, handles)
% hObject    handle to stateList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns stateList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stateList
staIndx = get(hObject,'Value');
devIndx = get(handles.deviceList,'Value');
tableIndx = get(handles.tableList,'Value');
set(handles.stateMessage,'String',handles.device(devIndx).message(tableIndx,staIndx));
set(handles.stateRate,'String', handles.device(devIndx).rate(tableIndx,staIndx));
showRateAndMsg(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function stateList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stateList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rateSelect.
function rateSelect_Callback(hObject, eventdata, handles)
% hObject    handle to rateSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns rateSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rateSelect


% --- Executes during object creation, after setting all properties.
function rateSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rateSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stateMessage_Callback(hObject, eventdata, handles)
% hObject    handle to stateMessage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stateMessage as text
%        str2double(get(hObject,'String')) returns contents of stateMessage
%        as a double

staIndx = get(handles.stateList,'Value');
devIndx = get(handles.deviceList,'Value');
tableIndx = get(handles.tableList,'Value');

handles.device(devIndx).message(tableIndx,staIndx) = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stateMessage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stateMessage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addDevice.
function addDevice_Callback(hObject, eventdata, handles)
% hObject    handle to addDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inpIndx = get(handles.InputsList,'Value');
inpList = get(handles.InputsList,'String');
defAns = inpList(inpIndx);
deviceList = get( handles.deviceList ,'String');
answer = inputdlg('Device Name:','New Device',1,defAns,'on');
if isempty(answer), return, end

%check that device is not on device list and add it to list
if ( strmatch(answer, deviceList, 'exact') ),
    errordlg('Entered device is already in device list. Please select existing one.','Error','modal')
else
    newList = strcmp('',deviceList(1)); %Only true if device list is empty.
    deviceList(end+1-newList) = answer;
    nDev = length(deviceList);
    handles.device(nDev).name = answer{:};
    handles.device(nDev).inputs = {''};
    handles.device(nDev).rate = {'0' '0'};
    handles.device(nDev).message = {'None' 'None'};
    handles.device(nDev).destinationMask = uint8([1 1 1 1 1 1 1 1]);
    handles.device(nDev).rateMask = uint8([1 1 1 1 1 1 1 1 1 1]);
    handles.device(nDev).tableCnt = 1;
    handles.device(nDev).states = {' '};
    set( handles.deviceList, 'String', {handles.device.name})
    set( handles.stateList, 'String', handles.device(nDev).states(1,1:end) )
    set( handles.deviceList,'Value',nDev);
    set( handles.deviceInputs,'String', handles.device(nDev).inputs)
    set( handles.tableList, 'String', 'Table 1')
    showRateAndMsg(hObject, eventdata, handles);
    showMask(hObject,eventdata,handles)
end

guidata(hObject, handles);



function stateRate_Callback(hObject, eventdata, handles)
% hObject    handle to stateRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stateRate as text
%        str2double(get(hObject,'String')) returns contents of stateRate as a double
staIndx = get(handles.stateList,'Value');
devIndx = get(handles.deviceList,'Value');
tableIndx = get(handles.tableList,'Value');

handles.device(devIndx).rate(tableIndx,staIndx) = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stateRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stateRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in editStates.
function editStates_Callback(hObject, eventdata, handles)
% hObject    handle to editStates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

devIndx = get(handles.deviceList, 'Value');
tblIndx = get(handles.tableList, 'Value');
device = handles.device(devIndx);
defAns = device.states(tblIndx,:);

nBits = length(device.inputs);

for ii = 1:length(defAns), defAns{ii} = defAns{ii}(nBits+1:end); end
answer = inputdlg(device.states(tblIndx,:),device.name,1, defAns);
if(isempty(answer)), return, end
for ii = 1:size(device.states,2)
    txt = device.states{tblIndx,ii};
    devTxt = [txt(1:nBits+1), answer{ii}];
    device.states(tblIndx,ii) = {devTxt};
end
handles.device(devIndx) = device;
set(handles.stateList,'String',device.states(tblIndx,:) )
guidata(hObject, handles);


function setMask(hObject,eventdata,handles);
%For all buttons, update given device maks when user presses maks bit (rate or dest).
devIndx = get(handles.deviceList,'Value');
tableIndx = get(handles.tableList,'Value');
bitVal = get(hObject, 'Value');
bitName = get(hObject,'Tag');
bitIndx = str2num(bitName(5:end));

switch bitName(1:4)
    case 'rate'
        handles.device(devIndx).rateMask(tableIndx,bitIndx) = bitVal;
    case 'dest'
        handles.device(devIndx).destinationMask(tableIndx,bitIndx) = bitVal;
end

guidata(hObject, handles);

function showMask(hObject,eventdata,handles)
%Update Gui values from device (called when user selects a different device
%or table.

devIndx = get(handles.deviceList,'Value');
tableIndx = get(handles.tableList,'Value');

rateMask = handles.device(devIndx).rateMask(tableIndx,:);
destMask = handles.device(devIndx).destinationMask(tableIndx,:);

for ii = 1:length(rateMask)
    handleName = ['handles.rate', num2str(ii)];
    set(eval(handleName),'Value',rateMask(ii));
end

for ii = 1:length(destMask)
    handleName = ['handles.dest', num2str(ii)];
    set(eval(handleName),'Value',destMask(ii));
end

function showRateAndMsg(hObject, eventdata, handles);
%Update gui when user selects new device, table or state
staIndx = get(handles.stateList,'Value');
devIndx = get(handles.deviceList,'Value');
tableIndx = get(handles.tableList,'Value');

set(handles.stateRate,'String', handles.device(devIndx).rate(tableIndx,staIndx));
set(handles.stateMessage,'String', handles.device(devIndx).message(tableIndx,staIndx));


% --- Executes on button press in saveDevList.
function saveDevList_Callback(hObject, eventdata, handles)
% hObject    handle to saveDevList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
device = handles.device;
save deviceInfo device
fprintf('\n%s/%s saved with %i Devices\n',pwd,'deviceInfo',length(device))


% --- Executes on button press in deleteOneDev.
function deleteOneDev_Callback(hObject, eventdata, handles)
% hObject    handle to deleteOneDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
devIndx = get(handles.deviceList, 'Value');
device = handles.device;
device(devIndx) = [];
handles.device = device;
guidata(hObject, handles);

set(handles.deviceList, 'Value', min(devIndx, length(device)))
set(handles.deviceList, 'String', {device.name})
deviceList_Callback(handles.deviceList, eventdata, handles);