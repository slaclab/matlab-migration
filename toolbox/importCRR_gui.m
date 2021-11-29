function varargout = importCRR_gui(varargin)
% IMPORTCRR_GUI M-file for importCRR_gui.fig
%      IMPORTCRR_GUI, by itself, creates a new IMPORTCRR_GUI or raises the existing
%      singleton*.
%
%      H = IMPORTCRR_GUI returns the handle to a new IMPORTCRR_GUI or the handle to
%      the existing singleton*.
%
%      IMPORTCRR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTCRR_GUI.M with the given input arguments.
%
%      IMPORTCRR_GUI('Property','Value',...) creates a new IMPORTCRR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before importCRR_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to importCRR_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help importCRR_gui

% Last Modified by GUIDE v2.5 02-Apr-2012 14:14:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importCRR_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @importCRR_gui_OutputFcn, ...
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


% --- Executes just before importCRR_gui is made visible.
function importCRR_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to importCRR_gui (see VARARGIN)

% Choose default command line output for importCRR_gui
handles.output = hObject;

handles.importok = 0;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes importCRR_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = importCRR_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% java hackery to enable horizontal scrollbars
jScrollPane = findjobj(handles.edit_table);
jScrollPane.setHorizontalScrollBarPolicy(30);  % or: jScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED
jViewPort = jScrollPane.getViewport;
jEditbox = jViewPort.getComponent(0);
jEditbox.setWrapping(false);  % do *NOT* use set(...)!!!

handles = gui_update(handles);
guidata(hObject, handles);

% 
% % construct corrPlot_gui type struct
% 
% % construct config struct
% data.config.ctrlPVNum = dims;
% data.config.ctrlPVName = reshape(device, [], 1);
% data.config.ctrlMKBName = '';
% data.config.ctrlPVValNum = steps;
% data.config.ctrlPVRange = cell(dims, 2);
% for ix = 1:dims
%     data.config.ctrlPVRange(ix, :) = range.(strcat('var', num2str(ix)));
% end
% data.config.ctrlPVWait = [1 1];
% data.config.ctrlPVWaitInit = 1;
% data.config.readPVNameList = reshape(names(~empty), [], 1);
% data.config.plotHeader = char(filename);
% data.config.acquireSampleNum = 1;
% data.config.showFit = 0;
% data.config.showFitOrder = 1;
% data.config.showAverage = 0;
% data.config.showSmoothing = 0;
% data.config.showWindowSize.jVal = 5;
% data.config.showWindowSize.nVal = 50;
% data.config.showWindowSize.iVal = 5;
% data.config.profmonId = 0;
% data.config.wireId = 0;
% data.config.plotXAxisId = 1;
% data.config.plotYAxisId = 1;
% data.config.plotUAxisId = 0;
% data.config.acquireBSA = 0;
% data.config.profmonNumBG = 1;
% data.config.emitId = 0;
% data.config.show2D = 0;
% data.config.acquireSampleDelay = 0.1;
% data.config.acquireRandomOrder = 0;
% data.config.acquireSpiralOrder = 0;
% data.config.acquireZigzagOrder = 0;
% data.config.calcPVNameList = cell(0);
% data.config.blenId = 0;
% data.config.profmonName = '';
% data.config.wireName = '';
% data.config.emitName = '';
% data.config.blenName = '';
% 
% for ix = 1:dims    
%     for jx = 1:n
%         data.ctrlPV(ix, jx).name = device(ix);
% %        data.ctrlPV(ix, jx).val = ctrlVal(jx, :);
% 
%     end
% end
% % construct corrPlot_gui type data struct
% 
% % construct flat table
% 
% 
% 
% 
% % construct output tables
% ctrl.step = reshape(dataID(:,:,1), [], 1);
% 
% 
% ctrl.id  = squeeze(dataID(:,:,1));
% 
% ctrl.val = squeeze(ctrlVal(:,:,1));
% 
% samp.data = data;
% 
% % construct output struct
% scan.ctrlNum = squeeze(dataID(:,:,1));
% scan.ctrlVal = squeeze(ctrlVal(:,:,1));
% scan.data = data;
% scan.dataStd = dataStd;
% scan.range = range;
% scan.device = device;
% scan.desc = desc;
% scan.names = column_names;
% scan.empty = empty;

function edit_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton_import, 'String', 'Import');
handles = gui_update(handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit_file as text
%        str2double(get(hObject,'String')) returns contents of edit_file as a double


% --- Executes during object creation, after setting all properties.
function edit_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = gui_update(handles)

handles.stripempty = get(handles.checkbox_stripempty, 'Value');

handles.comma = get(handles.checkbox_comma, 'Value');
handles.tab = get(handles.checkbox_tab, 'Value');
handles.headers = get(handles.checkbox_headers, 'Value');
handles.rows = get(handles.checkbox_rows, 'Value');
handles.sort = get(handles.popupmenu_sort, 'Value');

filestring = get(handles.edit_file, 'String');
tokens = textscan(filestring, '%s', 'delimiter', '/'); tokens = tokens{1};
if isempty(cell2mat(strfind(tokens(end), '.DAT')))
    handles.pathname = filestring;
    handles.filename = '';
    handles = update_browser(handles);
else
    handles.pathname = filestring(1:(strfind(filestring, char(tokens(end))) - 1));
    handles.filename = char(tokens(end));
end




% --- Executes on button press in pushbutton_import.
function pushbutton_import_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = gui_update(handles);
gui_statusDisp(handles, 'Importing...');
drawnow;

handles.importfilename = strcat(handles.pathname, handles.filename);

try
    handles.data = scp_loadCRRData(char(handles.importfilename), 1, handles.stripempty);
catch
    gui_statusDisp(handles, strcat({'Import failed: '}, handles.importfilename));
    errordlg('Data import failed!  Check filename.');
    return
end

handles.importok = 1;

isCtrl = squeeze(handles.data.isCtrl(1,1,:));
sortmenu = strcat(squeeze(handles.data.name(1,1,isCtrl)), ...
    {' ('}, squeeze(handles.data.desc(1,1,isCtrl)), {')'});
handles.sort = size(sortmenu, 1);
set(handles.popupmenu_sort, 'Value', handles.sort);
set(handles.popupmenu_sort, 'String', flipdim(sortmenu, 1));

handles = text_print(handles);

gui_statusDisp(handles, sprintf('Imported data: %d x %d x %d', ...
    size(handles.data.val, 1), size(handles.data.val, 2), size(handles.data.val, 3)));

drawnow;
guidata(hObject, handles);

function handles = text_print(handles)



if ~handles.importok, return; end

dims = size(handles.data.name);
cols = dims(3);
rows = (dims(2) * dims(1));

if handles.sort == 2
    map = reshape(1:rows, dims(2), dims(1));
else
    map = reshape(1:rows, dims(1), dims(2));
    map = map';
end

map = reshape(map, [], 1);

vals = reshape(handles.data.val, [rows cols]);
ids = reshape(handles.data.id, [rows cols]);

if handles.comma && handles.tab
    delim = ',\t';
elseif handles.comma && ~handles.tab
    delim = ',';
elseif ~handles.comma && handles.tab
    delim = '\t';
else
    delim = ' ';
end

header = cell([2 cols]);
header(1, :) = reshape(handles.data.name(1,1,:), 1, []);
header(2, :) = reshape(handles.data.desc(1,1,:), 1, []);
if handles.rows
    header = [{'Sample'; 'num'}, header];
end
headerstr = cell(2, 1);
for ix = 1:2
    for jx = 1:size(header, 2)
    headerstr{ix} = [headerstr{ix} sprintf(['%s' delim], header{ix, jx})];
    end
end
 


table = cell([rows 1]);

for ix = 1:rows
    if handles.rows
        table{ix} = sprintf(['%d' delim], ids(map(ix), 1));
    end
    for jx = 1:cols
        table{ix} = [table{ix} sprintf(['%g' delim], vals(map(ix), jx))];
    end
end

if handles.headers
    table = [headerstr; table];
end

set(handles.edit_table, 'String', table);
drawnow;

% java hackery to go to top left
jhEdit = findjobj(handles.edit_table);
jEdit = jhEdit.getComponent(0).getComponent(0);
jEdit.setCaretPosition(0);


% --- Executes on button press in checkbox_stripempty.
function checkbox_stripempty_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_stripempty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_stripempty


% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_email.
function pushbutton_email_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_email (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
address = get(handles.edit_address, 'String');
[user, domain] = strtok(address, '@');
if ~strcmp(domain, '@slac.stanford.edu')
    errdlg('Cannot send email to non-SLAC addresses!')
    return
end
addr = strcat(user, '@slac.stanford.edu');
text = get(handles.edit_table, 'String');
textfile = '/tmp/crrtable.txt';
fid = fopen(textfile, 'w');
for ix = 1:numel(text)
    fprintf(fid, '%s\n', text{ix});
end
fclose(fid);
cmd = sprintf('mail -s "%s" %s < %s', ...
    char(handles.importfilename), addr, textfile);
try
    sendok = 1;
    system(cmd);
catch
    sendok = 0;
    errordlg('Error sending email!');
end
if sendok
    warndlg(sprintf('Mail sent to %s!', address));
end
guidata(hObject, handles);




function edit_table_Callback(hObject, eventdata, handles)
% hObject    handle to edit_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_table as text
%        str2double(get(hObject,'String')) returns contents of edit_table as a double


% --- Executes during object creation, after setting all properties.
function edit_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_comma.
function checkbox_comma_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_comma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = gui_update(handles);
handles = text_print(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_comma


% --- Executes on button press in checkbox_tab.
function checkbox_tab_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = gui_update(handles);
handles = text_print(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_tab


% --- Executes on button press in checkbox_headers.
function checkbox_headers_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_headers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = gui_update(handles);
handles = text_print(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_headers


% --- Executes on button press in checkbox_rows.
function checkbox_rows_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = gui_update(handles);
handles = text_print(handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox_rows


% --- Executes on selection change in popupmenu_sort.
function popupmenu_sort_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = gui_update(handles);
handles = text_print(handles);
guidata(hObject, handles);
% Hints: contents = get(hObject,'String') returns popupmenu_sort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sort


% --- Executes during object creation, after setting all properties.
function popupmenu_sort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_address_Callback(hObject, eventdata, handles)
% hObject    handle to edit_address (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_address as text
%        str2double(get(hObject,'String')) returns contents of edit_address as a double


% --- Executes during object creation, after setting all properties.
function edit_address_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_address (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.importok, return; end
[filename, pathname] = util_dataSave(handles.data, 'CRR', char(handles.data.name(1,1,1)), now, 1, '/home/fphysics/')
guidata(hObject, handles);

% --- Executes on button press in pushbutton_copy.
function pushbutton_copy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tablestr = get(handles.edit_table, 'String');
copystr = char(0);
for ix = 1:numel(tablestr)
    copystr = [copystr sprintf('%s\n', tablestr{ix})];
end
clipboard('copy', copystr);
guidata(hObject, handles);


% --- Executes on selection change in listbox_browser.
function listbox_browser_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject, 'String');
selection = contents(get(hObject, 'Value'));
if get(hObject, 'Value') == 1
    tokens = textscan(handles.pathname, '%s', 'delimiter', '/'); tokens = tokens{1};
    newpath = '';
    for ix = 1:numel(tokens)-1
        newpath = [newpath char(tokens(ix)) '/'];
    end
    handles.pathname = newpath;
    handles.filename = '';
elseif handles.browser.isDir(get(hObject, 'Value'));
    handles.pathname = char(strcat(handles.pathname, selection));
    handles.filename = '';
else
    handles.filename = char(selection);
end
set(handles.edit_file, 'String', strcat(handles.pathname, handles.filename));
drawnow;
handles = gui_update(handles);
guidata(hObject, handles);

% Hints: contents = get(hObject,'String') returns listbox_browser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_browser


% --- Executes during object creation, after setting all properties.
function listbox_browser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_browser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_browser(handles);

function handles = update_browser(handles)
filepath = handles.pathname;
gui_statusDisp(handles, strcat({'Listing directory '}, filepath));
dirfile = 'directory.txt';
cmd = strcat({'curl -G http://134.79.176.15/'}, filepath, {' -o '}, dirfile);
result = '';
try
    [status, result] = system(char(cmd));
catch
    disp('Error downloading file!');
    disp(result);
    return
end
fid = fopen(char(dirfile), 'r');
lines = cell(0);
handles.browser.links = cell(0);
ix = 0;
while ~feof(fid)
    line = fgetl(fid);
    match = findstr('<A HREF="', line);
    if ~isempty(match)
        ix = ix+1;
        lines = [lines; line(match:end)];
        link = textscan(lines{ix}, '<A HREF="%s">%*s', 'delimiter', '<>"');
        handles.browser.links(ix,1) = link{1};
    end
end
fclose(fid);

handles.browser.isDir = ~cellfun(@isempty, strfind(handles.browser.links, '/'));
handles.browser.isDat = ~cellfun(@isempty, strfind(handles.browser.links, '.DAT'));
handles.browser.isMat = ~cellfun(@isempty, strfind(handles.browser.links, '.MAT'));

set(handles.listbox_browser, 'String', ...
    [{'..'}; handles.browser.links(handles.browser.isDir); ...
     handles.browser.links(handles.browser.isDat)], 'Value', 1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
% delete(hObject);

util_appClose(hObject);
