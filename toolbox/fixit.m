function varargout = fixit(varargin)
% FIXIT MATLAB code for fixit.fig
%      FIXIT, by itself, creates a new FIXIT or raises the existing
%      singleton*.
%
%      H = FIXIT returns the handle to a new FIXIT or the handle to
%      the existing singleton*.
%
%      FIXIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIXIT.M with the given input arguments.
%
%      FIXIT('Property','Value',...) creates a new FIXIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fixit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fixit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fixit

% Last Modified by GUIDE v2.5 16-Apr-2015 12:21:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fixit_OpeningFcn, ...
                   'gui_OutputFcn',  @fixit_OutputFcn, ...
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


% --- Executes just before fixit is made visible.
function fixit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fixit (see VARARGIN)

% Choose default command line output for fixit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fixit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fixit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in currPVs.
function currPVs_Callback(hObject, eventdata, handles)
% hObject    handle to currPVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns currPVs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from currPVs



% --- Executes during object creation, after setting all properties.
function currPVs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currPVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function readPVList_Callback(hObject, eventdata, handles)
% hObject    handle to readPVList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of readPVList as text
%        str2double(get(hObject,'String')) returns contents of readPVList as a double


% --- Executes during object creation, after setting all properties.
function readPVList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readPVList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getCurrent.
function getCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to getCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pvs = get(handles.readPVList,'String');
npvs = size(pvs,1);

pvGUIout = cell(1, npvs); % Printed text for "Get current" heading
currVal = cell(1, npvs);

 for i = 1:npvs
     pv = strtrim(pvs(i,:));
     val = lcaGet(pv);
     if iscell(val)
         val_str = char(val);
     else
         val_str = num2str(val);
     end
     
     pvis = [pv ' is ' val_str];
     pvGUIout{1,i} = pvis;
     
     currVal{1,i} = val_str;
 end

set(handles.currPVs, 'String', pvGUIout);
handles.currPVlist = pvs;
handles.currVal = currVal;
guidata(hObject, handles)

% Make a fancy string to show when the displayed data was retrieved
timeLabel = ['from ' datestr(clock, 'mm/dd/yy HH:MM:SS') ' '];
set(handles.currValsTime, 'String', timeLabel,'Visible','on');

% Enable the button that actually lcaPuts
set(handles.setPVcurr,'Enable','on');


% --- Executes on selection change in pastPVs.
function pastPVs_Callback(hObject, eventdata, handles)
% hObject    handle to pastPVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pastPVs contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pastPVs


% --- Executes during object creation, after setting all properties.
function pastPVs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pastPVs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getPast.
function getPast_Callback(hObject, eventdata, handles)
% hObject    handle to getPast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get input strings
pastDate = get(handles.pastDate, 'String');
pastTime = get(handles.pastTime, 'String');


% Fancy time formatting
timeInput = [pastDate ' ' pastTime];
timeDes = datevec(timeInput, 'mm/dd/yyyy HH:MM');

deltaT = [ 0 0 0 0 0 30]; % Create a 30-second time window on either side

t_lo = timeDes - deltaT;
t_hi = timeDes + deltaT;

t_lo_str = datestr(t_lo, 'mm/dd/yy HH:MM:SS');
t_hi_str = datestr(t_hi, 'mm/dd/yy HH:MM:SS');

timeRange = {t_lo_str; t_hi_str};


% Get yo data!!
pvs = get(handles.readPVList,'String');
npvs = size(pvs,1);
pvGUIout = cell(1, npvs); % Printed text for "Get from" heading
pastVal = cell(1, npvs);

 for i = 1:npvs
     pv = strtrim(pvs(i,:));
     [t, getHistVal] = getHistory(pv, timeRange);
     val = median(getHistVal);
     val_str = num2str(val);
     
     pvwas = [pv ' was ' val_str];
     pvGUIout{1,i} = pvwas;
     
     pastVal{1,i} = val_str;
 end

set(handles.pastPVs, 'String', pvGUIout);
handles.pastPVlist = pvs;
handles.pastVal = pastVal;
guidata(hObject, handles)

% Make a fancy string to show when the displayed data was retrieved
timeLabel = ['from ' timeInput ' '];
set(handles.pastValsTime, 'String', timeLabel,'Visible','on');

% Enable the button that actually lcaPuts
set(handles.setPVpast,'Enable','on');



% --- Executes on button press in setPVcurr.
function setPVcurr_Callback(hObject, eventdata, handles)
% hObject    handle to setPVcurr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

npvs = size(handles.currPVlist,1);
for i= 1:npvs
    pv = strtrim(handles.currPVlist(i,:));
    val = handles.currVal{1,i};
    lcaPut(pv,val)
    disp(['Set ' pv 'to ' val])
end


% --- Executes on button press in setPVpast.
function setPVpast_Callback(hObject, eventdata, handles)
% hObject    handle to setPVpast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

npvs = size(handles.pastPVlist,1);
for i= 1:npvs
    pv = strtrim(handles.pastPVlist(i,:));
    val = handles.pastVal{1,i};
    lcaPut(pv,val)
    disp(['Set ' pv ' to ' val])
end


% --- Executes on button press in loadPVlist.
function loadPVlist_Callback(hObject, eventdata, handles)
% hObject    handle to loadPVlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Fancy load dialog
fileName = 'mycrap.mat';

[sys, accelerator] = getSystem();

if isequal(accelerator, 'FACET')
    pathName = '/u1/facet/matlab/config/fixit_configs';
else
    pathName = '/u1/lcls/matlab/config/fixit_configs';
end

[fileName, pathName]=uigetfile(fullfile(pathName, fileName),'Load config file');

load(fullfile(pathName, fileName))

set(handles.readPVList, 'String', savedPVs);

% --- Executes on button press in savePVlist.
function savePVlist_Callback(hObject, eventdata, handles)
% hObject    handle to savePVlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

savedPVs = get(handles.readPVList,'String');

% Fancy save dialog
fileName = 'mycrap.mat';

[sys, accelerator] = getSystem();

if isequal(accelerator, 'FACET')
    pathName = '/u1/facet/matlab/config/fixit_configs';
else
    pathName = '/u1/lcls/matlab/config/fixit_configs';
end
[fileName, pathName]=uiputfile(fullfile(pathName, fileName),'Save as');

save(fullfile(pathName, fileName), 'savedPVs')



function pastDate_Callback(hObject, eventdata, handles)
% hObject    handle to pastDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pastDate as text
%        str2double(get(hObject,'String')) returns contents of pastDate as a double


% --- Executes during object creation, after setting all properties.
function pastDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pastDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pastTime_Callback(hObject, eventdata, handles)
% hObject    handle to pastTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pastTime as text
%        str2double(get(hObject,'String')) returns contents of pastTime as a double


% --- Executes during object creation, after setting all properties.
function pastTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pastTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

% Exit from Matlab when not running the desktop 
if usejava('desktop') 
   % Don't exit from
   disp('Goodbye!')
else
   exit 
end

