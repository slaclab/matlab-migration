function varargout = fbMatrixGui(varargin)
% FBMATRIXGUI M-file for fbMatrixGui.fig
%      FBMATRIXGUI, by itself, creates a new FBMATRIXGUI or raises the existing
%      singleton*.
%
%      H = FBMATRIXGUI returns the handle to a new FBMATRIXGUI or the handle to
%      the existing singleton*.
%
%      FBMATRIXGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FBMATRIXGUI.M with the given input arguments.
%
%      FBMATRIXGUI('Property','Value',...) creates a new FBMATRIXGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fbMatrixGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fbMatrixGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text30 to modify the response to help fbMatrixGui

% Last Modified by GUIDE v2.5 26-Aug-2009 13:19:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fbMatrixGui_OpeningFcn, ...
                   'gui_OutputFcn',  @fbMatrixGui_OutputFcn, ...
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


% --- Executes just before fbMatrixGui is made visible.
function fbMatrixGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fbMatrixGui (see VARARGIN)

% Choose default command line output for fbMatrixGui
handles.output = hObject;

config = getappdata(0,'Config_structure');

handles.fFcnName = config.matrix.fFcnName;
if strcmp(handles.fFcnName,'0')
   set(handles.calcFBtn, 'Enable', 'off');
end;
handles.gFcnName = config.matrix.gFcnName;
if strcmp(handles.gFcnName,'0')
   set(handles.calcGBtn, 'Enable', 'off');
end;

handles.f = config.matrix.f;
handles.g = config.matrix.g;
handles.params = config.matrix.params;

fdata = num2cell(handles.f);

% init the F columns
fcols = length(fdata(1,:));
set(handles.fcolsEdit, 'String', fcols);

% init the F matrix table 
for i=1:length(handles.f(1,:))
 fcolumninfo.titles{1,i}=['F' num2str(i)];
 fcolumninfo.formats{1,i} = '%4.6g';
 fcolumninfo.weight(1,i) = 1;
 fcolumninfo.multipliers(1,i) = 1;
 fcolumninfo.isEditable(1,i) = 1;
 fcolumninfo.isNumeric(1,i) = 1;
end
fcolumninfo.withCheck = false; % optional to put checkboxes along left side
fcolumninfo.chkLabel = 'Use'; % optional col header for checkboxes
frowHeight = 16;
fgFont.size=9;
fgFont.name='Helvetica';
% 
handles.fcolumninfo = fcolumninfo;
handles.frowHeight = frowHeight;
handles.fgFont = fgFont;
 
%draw the table 
fbmltable(gcf, handles.fTable, 'CreateTable', fcolumninfo, frowHeight, fdata, fgFont);

% make table editing end when click on somewhere else in the figure
%endfcn = sprintf('fbmltable(%14.13f, %14.13f, "setCellValue");',hObject, handles.fTable);
%set(hObject, 'buttondownfcn',endfcn);

gdata = num2cell(handles.g);
% init the G columns
gcols = length(gdata(1,:));
set(handles.gcolsEdit, 'String', gcols);

% init the G matrix table 
for i=1:length(handles.g(1,:))
 gcolumninfo.titles{1,i}=['G' num2str(i)];
 gcolumninfo.formats{1,i} = '%4.6g';
 gcolumninfo.weight(1,i) = 1;
 gcolumninfo.multipliers(1,i) = 1;
 gcolumninfo.isEditable(1,i) = 1;
 gcolumninfo.isNumeric(1,i) = 1;
end
gcolumninfo.withCheck = false; % optional to put checkboxes along left side
gcolumninfo.chkLabel = 'Use'; % optional col header for checkboxes
growHeight = 16;
ggFont.size=9;
ggFont.name='Helvetica';
% 
handles.gcolumninfo = gcolumninfo;
handles.growHeight = growHeight;
handles.ggFont = ggFont;
 
%draw the table 
fbmltable(gcf, handles.gTable, 'CreateTable', gcolumninfo, growHeight, gdata, ggFont);

% make table editing end when click somewhere else in the figure
%endfcn = sprintf('fbmltable(%14.13f, %14.13f, "setCellValue"); fbmltable(%14.13f, %14.13f, "setCellValue");',...
%    hObject, handles.fTable, hObject, handles.gTable);
%set(hObject, 'buttondownfcn',endfcn);

%keep track of changes
handles.configchanged = config.configchanged;

if strcmpi(handles.params.visible,'on')
    % show the current parameters in the parameters box
    displayParams(handles);
    set(handles.bpmCoeffsBtn, 'visible', 'on');
    set(handles.bpmCoeffstxt, 'visible', 'on');
else
    set(handles.paramPanel, 'visible', 'off');
    set(handles.bpmCoeffsBtn, 'visible', 'off');
    set(handles.bpmCoeffstxt, 'visible', 'off');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fbMatrixGui wait for user response (see UIRESUME)
uiwait(handles.matrixFig);


% --- Outputs from this function are returned to the command line.
function varargout = fbMatrixGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.matrixFig);

function displayParams(handles)
% display the parameters in the Matrix parameters box
params = handles.params;
set(handles.editN, 'String', num2str(params.N, 6));
set(handles.editSz0, 'String', num2str(params.Sz0, 6));
set(handles.editSd0, 'String', num2str(params.Sd0, 6));
set(handles.editEg, 'String', num2str(params.Eg, 6));

set(handles.editEv, 'String', mat2str(params.Ev, 6));
set(handles.editR, 'String', mat2str(params.R56v, 6));
set(handles.editT, 'String', mat2str(params.T566v, 6));
set(handles.editP, 'String', mat2str(params.phiv, 6));


function fcolsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fcolsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fcolsEdit as text30
%        str2double(get(hObject,'String')) returns contents of fcolsEdit as a double

info = get(handles.fTable, 'userdata');
fdata = info.data;
cols = str2num(get(hObject, 'String'));
rows = length(fdata);

handles = rmfield(handles, 'fcolumninfo');
for i=1:cols
 handles.fcolumninfo.titles{1,i}=['F' num2str(i)];
 handles.fcolumninfo.formats{1,i} = '%4.6g';
 handles.fcolumninfo.weight(1,i) = 1;
 handles.fcolumninfo.multipliers(1,i) = 1;
 handles.fcolumninfo.isEditable(1,i) = 1;
 handles.fcolumninfo.isNumeric(1,i) = 1;
end
fbmltable(gcf, handles.fTable,'DestroyTable');

%create the new data array
oldcols = length(fdata(1,:));
if cols < oldcols
    for i=cols+1:oldcols
        fdata(:,cols+1) = [];
    end
else
    fdata{rows, cols} ='';
end

%draw the new table 
fbmltable(gcf, handles.fTable, 'CreateTable', handles.fcolumninfo, handles.frowHeight, fdata, handles.fgFont);

handles.configchanged = 1;
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function fcolsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fcolsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gcolsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to gcolsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gcolsEdit as text30
%        str2double(get(hObject,'String')) returns contents of gcolsEdit as a double

info = get(handles.gTable, 'userdata');
gdata = info.data;
cols = str2num(get(hObject, 'String'));
rows = length(gdata);

handles = rmfield(handles, 'gcolumninfo');
for i=1:cols
 handles.gcolumninfo.titles{1,i}=['G' num2str(i)];
 handles.gcolumninfo.formats{1,i} = '%4.6g';
 handles.gcolumninfo.weight(1,i) = 1;
 handles.gcolumninfo.multipliers(1,i) = 1;
 handles.gcolumninfo.isEditable(1,i) = 1;
 handles.gcolumninfo.isNumeric(1,i) = 1;
end
fbmltable(gcf, handles.gTable,'DestroyTable');

%create the new data array
oldcols = length(gdata(1,:));
if cols < oldcols
    for i=cols+1:oldcols
        gdata(:,cols+1) = [];
    end
else
    gdata{rows, cols} ='';
end

%draw the new table 
fbmltable(gcf, handles.gTable, 'CreateTable', handles.gcolumninfo, handles.growHeight, gdata, handles.ggFont);

handles.configchanged = 1;
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function gcolsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gcolsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in calcFBtn.
function calcFBtn_Callback(hObject, eventdata, handles)
% hObject    handle to calcFBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% store the current matrix parameters if necessary to calculate the new
% matrix values
if strcmpi(handles.params.visible, 'on')
    setappdata(0, 'tempParams', handles.params );
end
% now calculate the matrix
calcFmatrix = str2func(handles.fFcnName);
handles.f = calcFmatrix();

fdata = num2cell(handles.f);

% destroy the old table
fbmltable(gcf, handles.fTable,'DestroyTable');

% init the F columns
fcols = length(fdata(1,:));
set(handles.fcolsEdit, 'String', fcols);

% init the F matrix table 
for i=1:length(handles.f(1,:))
 fcolumninfo.titles{1,i}=['F' num2str(i)];
 fcolumninfo.formats{1,i} = '%4.6g';
 fcolumninfo.weight(1,i) = 1;
 fcolumninfo.multipliers(1,i) = 1;
 fcolumninfo.isEditable(1,i) = 1;
 fcolumninfo.isNumeric(1,i) = 1;
end
fcolumninfo.withCheck = false; % optional to put checkboxes along left side
fcolumninfo.chkLabel = 'Use'; % optional col header for checkboxes
frowHeight = 16;
fgFont.size=9;
fgFont.name='Helvetica';
% 
handles.fcolumninfo = fcolumninfo;
handles.frowHeight = frowHeight;
handles.fgFont = fgFont;
 
%draw the new table 
fbmltable(gcf, handles.fTable, 'CreateTable', fcolumninfo, frowHeight, fdata, fgFont);

handles.configchanged = 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in calcGBtn.
function calcGBtn_Callback(hObject, eventdata, handles)
% hObject    handle to calcGBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% store the current matrix parameters if necessary to calculate the new
% matrix values
if strcmpi(handles.params.visible, 'on')
    setappdata(0, 'tempParams', handles.params );
end
calcGmatrix = str2func(handles.gFcnName);
handles.g = calcGmatrix();

gdata = num2cell(handles.g);

% destroy the old table
fbmltable(gcf, handles.gTable,'DestroyTable');

% init the G columns
gcols = length(gdata(1,:));
set(handles.gcolsEdit, 'String', gcols);

% init the G matrix table 
for i=1:length(handles.g(1,:))
 gcolumninfo.titles{1,i}=['G' num2str(i)];
 gcolumninfo.formats{1,i} = '%4.6g';
 gcolumninfo.weight(1,i) = 1;
 gcolumninfo.multipliers(1,i) = 1;
 gcolumninfo.isEditable(1,i) = 1;
 gcolumninfo.isNumeric(1,i) = 1;
end
gcolumninfo.withCheck = false; % optional to put checkboxes along left side
gcolumninfo.chkLabel = 'Use'; % optional col header for checkboxes
growHeight = 16;
ggFont.size=9;
ggFont.name='Helvetica';
% 
handles.gcolumninfo = gcolumninfo;
handles.growHeight = growHeight;
handles.ggFont = ggFont;
 
%draw the table 
fbmltable(gcf, handles.gTable, 'CreateTable', gcolumninfo, growHeight, gdata, ggFont);

handles.configchanged = 1;
% Update handles structure
guidata(hObject, handles);


function editN_Callback(hObject, eventdata, handles)
% hObject    handle to editN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editN as text
handles.params.N = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSz0_Callback(hObject, eventdata, handles)
% hObject    handle to editSz0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSz0 as text
%        str2double(get(hObject,'String')) returns contents of editSz0 as a double
handles.params.Sz0 = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSz0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSz0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSd0_Callback(hObject, eventdata, handles)
% hObject    handle to editSd0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSd0 as text
%        str2double(get(hObject,'String')) returns contents of editSd0 as a double
handles.params.Sd0 = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editSd0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSd0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEg_Callback(hObject, eventdata, handles)
% hObject    handle to editEg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEg as text
%        str2double(get(hObject,'String')) returns contents of editEg as a double
handles.params.Eg = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editEg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEv_Callback(hObject, eventdata, handles)
% hObject    handle to editEv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEv as text
%        str2double(get(hObject,'String')) returns contents of editEv as a double
handles.params.Ev = eval(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editEv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editR_Callback(hObject, eventdata, handles)
% hObject    handle to editR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editR as text
%        str2double(get(hObject,'String')) returns contents of editR as a double
handles.params.R56v = eval(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editT_Callback(hObject, eventdata, handles)
% hObject    handle to editT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editT as text
%        str2double(get(hObject,'String')) returns contents of editT as a double
handles.params.T566v = eval(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editP_Callback(hObject, eventdata, handles)
% hObject    handle to editP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editP as text
%        str2double(get(hObject,'String')) returns contents of editP as a double
handles.params.phiv = eval(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% we're done with this window, store data changes
% (we just assume there were changes)

config = getappdata(0, 'Config_structure');

%get the matrix data
info = get(handles.fTable, 'userdata');
data = info.data;
config.matrix.f = cell2mat(data);
%
info = get(handles.gTable, 'userdata');
data = info.data;
config.matrix.g = cell2mat(data);

% now the parameters
config.matrix.params = handles.params;

config.configchanged = 1;
setappdata(0,'Config_structure',config);

uiresume(handles.matrixFig);


% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get the figure and call it's close function

%just close without saving changes.
uiresume(handles.matrixFig);

% --- Executes on button press in bpmCoeffsBtn.
function bpmCoeffsBtn_Callback(hObject, eventdata, handles)
% hObject    handle to bpmCoeffsBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%just close without saving changes.
fbStoreL3BPMCoeffs();
uiresume(handles.matrixFig);

% --- Executes when user attempts to close matrixFig.
function matrixFig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to matrixFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%just close without saving changes.
if isequal(get(handles.matrixFig, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
   uiresume(handles.matrixFig);
else
   % The GUI is no longer waiting, just close it
   delete(handles.matrixFig);
end




