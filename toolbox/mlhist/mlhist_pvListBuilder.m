function varargout = mlhist_pvListBuilder(varargin)
% MLHIST_PVLISTBUILDER MATLAB code for mlhist_pvListBuilder.fig
%      MLHIST_PVLISTBUILDER, by itself, creates a new MLHIST_PVLISTBUILDER or raises the existing
%      singleton*.
%
%      H = MLHIST_PVLISTBUILDER returns the handle to a new MLHIST_PVLISTBUILDER or the handle to
%      the existing singleton*.
%
%      MLHIST_PVLISTBUILDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MLHIST_PVLISTBUILDER.M with the given input arguments.
%
%      MLHIST_PVLISTBUILDER('Property','Value',...) creates a new MLHIST_PVLISTBUILDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mlhist_pvListBuilder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mlhist_pvListBuilder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mlhist_pvListBuilder

% Last Modified by GUIDE v2.5 10-Nov-2015 10:41:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mlhist_pvListBuilder_OpeningFcn, ...
                   'gui_OutputFcn',  @mlhist_pvListBuilder_OutputFcn, ...
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


% --- Executes just before mlhist_pvListBuilder is made visible.
function mlhist_pvListBuilder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mlhist_pvListBuilder (see VARARGIN)

% Choose default command line output for mlhist_pvListBuilder
handles.output = hObject;
lcaSetSeverityWarnLevel(5);
defPVs = {...
    'SIOC:SYS0:ML00:AO470';...
    'SIOC:SYS0:ML00:CALC252';...
    'ACCL:LI21:1:L1S_PDES';...
    'FBCK:FB04:LG01:S3DES';...
    'BLEN:LI21:265:AIMAX';...
    'REFS:LI24:790:EDES';...
    'ACCL:LI22:1:PDES';...
    'FBCK:FB04:LG01:S5DES';...
    'BLEN:LI24:886:BIMAX';...
    'REFS:DMP1:400:EDES';
    'ACCL:LI25:1:PDES'};
defDesc = {...
    'Q Gun';...
    'Q LTU';...
    'L1S PDES';...
    'BC1 Curr DES';...
    'BC1 Curr ACT';...
    'BC2 EDES';...
    'L2 PDES';...
    'BC2 Curr DES';...
    'BC2 Curr ACT';...
    'L3 EDES';...
    'L3 PDES'};
defEgu = {...
    'nC';...
    'pC';...
    'degS';...
    'A';...
    'A';...
    'GeV';...
    'degS';...
    'A';...
    'A';...
    'GeV';...
    'degS'};
block = false;
if nargin > 3
    if iscellstr(varargin{1})
        if (size(varargin{1},2) == 3)
            handles.pvTable = varargin{1};
        elseif iscellstr(varargin{1}) &&...
                (size(varargin{1},2) == 1)
            [desc,egu] = getDescAndEgu(varargin{1});
            handles.pvTable = [varargin{1},desc,egu];
        elseif iscellstr(varargin{1}) &&...
                (size(varargin{1},1) == 1)
            [desc,egu] = getDescAndEgu(varargin{1}.');
            handles.pvTable = [varargin{1},desc,egu];
        end
    else
        handles.pvTable = [defPVs,defDesc,defEgu];
    end
    if isequal(lower(varargin{1}),'block');block = true;end
else
    handles.pvTable = [defPVs,defDesc,defEgu];
end
handles.waiting = false;
handles.tableSel = [];
% Update handles structure
guidata(hObject, handles);
updatePvDisplay(handles);
% UIWAIT makes mlhist_pvListBuilder wait for user response (see UIRESUME)
if nargin > 4
    if isequal(lower(varargin{2}),'block')
        block = true;
    end
end
if block
    set(handles.mainFigure,'windowstyle','modal')
    set(handles.pushOK,'visible','on')
    set(handles.pushCancel,'visible','on')
    handles.origPvTable = handles.pvTable;
    handles.waiting = true;
    guidata(hObject,handles);
    uiwait(handles.mainFigure);
end


function [desc,egu] = getDescAndEgu(pvs)
[desc,~,ispv] = lcaGetSmart(strcat(pvs,'.DESC'));
if ~iscell(desc);desc = {desc};end
whoops = strcmp(desc,'') | ~ispv;
desc(whoops) = pvs(whoops);
[egu,~,ispv] = lcaGetSmart(strcat(pvs,'.EGU'));
if ~iscell(egu);egu = {egu};end;
whoops = strcmp(egu,'') | ~ispv;
egu(whoops) = {'egu'};


function updatePvDisplay(handles)
set(handles.tablePVdisplay,'units','pixels');
pos = get(handles.tablePVdisplay,'position');
set(handles.tablePVdisplay,'units','normalized');
cwidth = num2cell([(pos(3)-110)/2,(pos(3)-110)/2,70]);
set(handles.tablePVdisplay,...
    'data',handles.pvTable,...
    'columnname',{'PVs','Desc','egu'},...
    'columneditable',[false,true,true],...
    'columnwidth',cwidth);
setappdata(handles.mainFigure,'pvTable',handles.pvTable);
guidata(handles.mainFigure,handles);



% --- Outputs from this function are returned to the command line.
function varargout = mlhist_pvListBuilder_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if handles.waiting
    delete(hObject);
end


% --- Executes when user attempts to close mainFigure.
function mainFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject,'waitstatus'),'waiting')
    handles.output = handles.pvTable;
    guidata(hObject,handles);
    uiresume(hObject);
else
    delete(hObject);
end


% --- Executes on selection change in listAidaResponse.
function listAidaResponse_Callback(hObject, eventdata, handles)
% hObject    handle to listAidaResponse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listAidaResponse contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listAidaResponse
if strcmpi(get(handles.mainFigure,'SelectionType'),'open')
    k = get(hObject,'value');
    if ~isempty(k)
        pv = get(hObject,'string');
        pv = pv{k(1)};
        addNewPv(handles,pv);
    end
end

% --- Executes during object creation, after setting all properties.
function listAidaResponse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listAidaResponse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function editAidaSearch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAidaSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushAddOne.
function pushAddOne_Callback(hObject, eventdata, handles)
% hObject    handle to pushAddOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pv = get(handles.editAidaSearch,'string');
addNewPv(handles,pv);
set(handles.editAidaSearch,'string','');


function addNewPv(handles,pv)
[~,~,ispv] = lcaGetSmart(pv);
if ispv
    if any(strcmp(handles.pvTable(:,2),pv))
        return
    end
    [desc,egu] = getDescAndEgu({pv});
    if strcmp(pv(1:5),'BPMS:')
        desc = {pv};
    end
    add = [{pv},desc,egu];
    handles.pvTable = [handles.pvTable;add];
    updatePvDisplay(handles);
end


function addNewPvs(handles,pvs)
[~,~,ispv] = lcaGetSmart(pvs);
pvs = pvs(ispv);
incl = true(size(pvs));
isbpm = false(size(pvs));
for k = 1:length(pvs)
    incl(k) = ~any(strcmp(handles.pvTable(:,2),pvs{k}));
    isbpm(k) = strcmp(pvs{k}(1:5),'BPMS:');
end
pvs = pvs(incl);
isbpm = isbpm(incl);
[desc,egu] = getDescAndEgu(pvs);
desc(isbpm) = pvs(isbpm);
add = [pvs,desc,egu];
handles.pvTable = [handles.pvTable;add];
updatePvDisplay(handles);



% --- Executes on button press in pushAidaList.
function pushAidaList_Callback(hObject, eventdata, handles)
search = get(handles.editAidaSearch,'string');
if ~isempty(search)
    resp = aidalist(search);
    set(handles.listAidaResponse,'string',resp);
end
if strcmp(search,'-h')
    set(handles.pushAddAida,'enable','off')
elseif ~isempty(search)
    set(handles.pushAddAida,'enable','on')
end


% --- Executes on button press in pushClrSel.
function pushClrSel_Callback(hObject, eventdata, handles)
% hObject    handle to pushClrSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = handles.tableSel;
handles.pvTable(ind(:,1),:) = [];
updatePvDisplay(handles);


% --- Executes on button press in pushClrAll.
function pushClrAll_Callback(hObject, eventdata, handles)
% hObject    handle to pushClrAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resp = questdlg('Clear entire list?','PV List Builder','Yes','No','No');
if strcmpi(resp,'Yes')
    handles.pvTable = {};
    updatePvDisplay(handles);
end


% --- Executes when mainFigure is resized.
function mainFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to mainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.tablePVdisplay,'units','pixels');
pos = get(handles.tablePVdisplay,'position');
set(handles.tablePVdisplay,'units','normalized');
cwidth = num2cell([(pos(3)-110)/2,(pos(3)-110)/2,70]);
set(handles.tablePVdisplay,'columnwidth',cwidth);


% --- Executes when entered data in editable cell(s) in tablePVdisplay.
function tablePVdisplay_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to tablePVdisplay (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
handles.pvTable = get(hObject,'data');
setappdata(handles.mainFigure,'pvTable',handles.pvTable);
guidata(hObject,handles);


% --- Executes on button press in pushAddAida.
function pushAddAida_Callback(hObject, eventdata, handles)
k = get(handles.listAidaResponse,'value');
if ~isempty(k)
    pv = get(handles.listAidaResponse,'string');
    pv = pv(k);
    addNewPvs(handles,pv);
end


% --- Executes when selected cell(s) is changed in tablePVdisplay.
function tablePVdisplay_CellSelectionCallback(hObject, eventdata, handles)
handles.tableSel = eventdata.Indices;
guidata(hObject,handles);


% --- Executes on key press with focus on editAidaSearch and none of its controls.
function editAidaSearch_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editAidaSearch (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(eventdata.Modifier) && ~isempty(eventdata.Key)
    if isequal(eventdata.Key,'return') && isequal(eventdata.Modifier{1},'shift')
        search = get(handles.editAidaSearch,'string');
        try
            if ~isempty(search)
                resp = aidalist(search);
                set(handles.listAidaResponse,'string',resp);
                guidata(hObject,handles);
            end
            if strcmp(search,'-h')
                set(handles.pushAddAida,'enable','off')
            elseif ~isempty(search)
                set(handles.pushAddAida,'enable','on')
            end
        catch
            set(handles.listAidaResonse,'string','');
        end
    end
end



function editAidaSearch_Callback(hObject, eventdata, handles)
% hObject    handle to editAidaSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAidaSearch as text
%        str2double(get(hObject,'String')) returns contents of editAidaSearch as a double


function pushOK_Callback(hObject, eventdata, handles)
close(handles.mainFigure);


function pushCancel_Callback(hObject, eventdata, handles)
% Only visible if in blocking mode. Restore input pv list and return.
resp = questdlg('Leave editor and discard changes?','PV List Builder',...
    'Leave and discard','Stay','Leave and discard');
if strcmp(resp,'Leave and discard')
    handles.pvTable = handles.origPvTable;
    setappdata(handles.mainFigure,'pvTable',handles.pvTable);
    guidata(hObject,handles);
    close(handles.mainFigure);
end
