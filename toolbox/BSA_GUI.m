function varargout = BSA_GUI(varargin)
% BSA_GUI M-file for BSA_GUI.fig
%  
%
%       J. Turner 20 May 2009 - Who is responsible now that Jim has retiured?
%
%       For inspection, correlation, and PSD of BSA capable variables.
%       Enter the number of points, then Get Data will reserve an EDEF and
%       get data from the IOCs
%
%       Change Selected EDEF to "Fault File" for what is in the IOCs now.
%       This is equivalent to an updating fault file. Then Get Data.
%
%       Save Data writes to the same directory as Henrik specifies.
%       Save As Data opens a window dialog.
%
%       Load Data will open a dialog window to restore previously saved
%       data for re-plotting.
%
%       Searching through variables requires all caps (I can't seem to fix
%       this)
%
%       Plots A vs Time is what it says. Check out the pull down menu on
%       the figures. It calls "plot_menus_BSA". 
%
%       Plot A vs B is for correlation.
%
%       Plots PSD will give a power spectral density, an integrated power
%       spectral density, and an integrated square root of power spectral
%       density. If there is a rate change or time discontinuity, the
%       biggest block of the highest rate will be selected for analysis.
%
%
%
%
%
%      BSA_GUI, by itself, creates a new BSA_GUI or raises the existing
%      singleton*.
%
%      H = BSA_GUI returns the handle to a new BSA_GUI or the handle to
%      the existing singleton*.
%
%      BSA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BSA_GUI.M with the given input arguments.
%
%      BSA_GUI('Property','Value',...) creates a new BSA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BSA_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BSA_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BSA_GUI

% Last Modified by GUIDE v2.5 14-Aug-2020 08:01:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BSA_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BSA_GUI_OutputFcn, ...
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


% --- Executes just before BSA_GUI is made visible.
function BSA_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BSA_GUI (see VARARGIN)

% Choose default command line output for BSA_GUI

handles.output = hObject;
handles.new_model = 1;
handles.haveEDef = 0;

updateRootName(hObject,handles);


function handles = updateRootName(hObject,handles)
str = get(handles.edef_menu,'String');
val = get(handles.edef_menu,'Value');
isSxr = strncmp(str{val},'CUS',3);
if isSxr, HS = 'S'; else HS =  'H'; end
handles.isSxr= isSxr;

if strcmp('physics',getenv('USER'))  || strncmp('lcls',getenv('HOSTNAME'),4)
    root_name = meme_names('tag',['LCLS.CU' HS '.BSA.rootnames'], 'sort','z');
    if ~ismember('GDET:FEE1:241:ENRC',root_name)
        root_name = [root_name ;{'GDET:FEE1:241:ENRC'; 'GDET:FEE1:242:ENRC'; 'GDET:FEE1:361:ENRC'; 'GDET:FEE1:362:ENRC'}];
    end   
else
    root_name = load('root_name');
end

[prim,micro,unit] = model_nameSplit(root_name);
n = strcat(prim,':', micro, ':', unit);
z = model_rMatGet(n,[],{'TYPE=DESIGN',['BEAMPATH=CU_' HS 'XR']},'Z');
[z I] = sort(z);
root_name = root_name(I);
z_positions =z;
 
handles.ROOT_NAME = root_name;
handles.z_positions = z_positions;
handles.zLCLS=2014.7019;

% Initiate variable1 and 2
handles.figure_handles = guihandles(hObject);
set( handles.variable1, 'String', handles.ROOT_NAME );
set( handles.variable2, 'String', handles.ROOT_NAME );
handles.foundVar1Indx = 1:1:length(handles.ROOT_NAME);
handles.foundVar2Indx = 1:1:length(handles.ROOT_NAME);

% Update handles structure
guidata(handles.BSAFigure, handles);

% --- Outputs from this function are returned to the command line.
function varargout = BSA_GUI_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

try
   x=0.049;
   y=0.013;
   w=0.93;
   h=0.121;
   messageInit(x,y,w,h);
catch
   % Do nothing
end

disp('BSA GUI Init Complete.');

% --- Executes when user attempts to close BSAFigure.
function BSAFigure_CloseRequestFcn(hObject, eventdata, handles)

% Hint: delete(hObject) closes the figure
if  isfield(handles,'eDefNumber'),
    eDefRelease(handles.eDefNumber);
end
util_appClose(hObject);




% --- Executes on selection change in variable1.
function variable1_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns variable1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variable1

% --- Executes during object creation, after setting all properties.
function variable1_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function search_string1_Callback(hObject, eventdata, handles)
% always search ROOT_NAME
%
myStr = get( handles.search_string1, 'String' );
[inList] =   regexpi(handles.ROOT_NAME,myStr);

foundVar1Indx = find( cellfun( @isempty,inList ) == false );
var1List = handles.ROOT_NAME(foundVar1Indx)';
set( handles.variable1, 'Value', 1 );
set( handles.variable1, 'String', var1List );
handles.foundVar1Indx = foundVar1Indx;

guidata(handles.output, handles);

% Hints: get(hObject,'String') returns contents of search_string1 as text
%        str2double(get(hObject,'String')) returns contents of search_string1 as a double


% --- Executes during object creation, after setting all properties.
function search_string1_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset1.
function reset1_Callback(hObject, eventdata, handles)
set( handles.search_string1, 'String', '' );
set( handles.variable1, 'String', handles.ROOT_NAME );
handles.foundVar1Indx = 1:1:length(handles.ROOT_NAME);


guidata(handles.output, handles);



% --- Executes on key press with focus on variable1 and none of its controls.
function variable1_KeyPressFcn(hObject, eventdata, handles)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed


% --- Executes on selection change in variable2.
function variable2_Callback(hObject, eventdata, handles)
%indx2 = get( handles.figure_handles.variable2, 'Value' )

% Hints: contents = get(hObject,'String') returns variable2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variable2


% --- Executes during object creation, after setting all properties.
function variable2_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function search_string2_Callback(hObject, eventdata, handles)
myStr = get( handles.search_string2, 'String' );
inList =   regexpi(handles.ROOT_NAME,myStr);
foundVar2Indx = find( cellfun( @isempty,inList ) == false );
var2List = handles.ROOT_NAME(foundVar2Indx)';
set( handles.variable2, 'Value', 1 );
set( handles.variable2, 'String', var2List );
handles.foundVar2Indx = foundVar2Indx;
guidata(handles.output, handles);

% Hints: get(hObject,'String') returns contents of search_string2 as text
%        str2double(get(hObject,'String')) returns contents of search_string2 as a double


% --- Executes during object creation, after setting all properties.
function search_string2_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset2.
function reset2_Callback(hObject, eventdata, handles)
set( handles.search_string2, 'String', '' );
set( handles.variable2, 'String', handles.ROOT_NAME );
handles.foundVar2Indx = 1:1:length(handles.ROOT_NAME);
guidata(handles.output, handles);



function num_points_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of num_points as text
%        str2double(get(hObject,'String')) returns contents of num_points as a double


% --- Executes during object creation, after setting all properties.
function num_points_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '2800');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psd_start_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of psd_start as text
%        str2double(get(hObject,'String')) returns contents of psd_start as a double


% --- Executes during object creation, after setting all properties.
function psd_start_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '58');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psd_end_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of psd_end as text
%        str2double(get(hObject,'String')) returns contents of psd_end as a double


% --- Executes during object creation, after setting all properties.
function psd_end_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', '60');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Fault_File.
function Fault_File_Callback(hObject, eventdata, handles)
disp('Fault File button pressed.');


%[sys,accelerator]=getSystem();
set( handles.select_EDEF_text, 'String', 'Getting Data...' );
drawnow
eDefList =  get(handles.edef_menu,'String');
eDefStr = eDefList{get(handles.edef_menu,'Value')};
set(handles.select_EDEF_text, 'String', ['Fault file data: ' eDefStr])
nPts = str2double(get(handles.num_points,'String')); 
[the_matrix, t_stamp, isPV] = lcaGetSyncHST(handles.ROOT_NAME, nPts,eDefStr);

matlabTS = lca2matlabTime(t_stamp(end));
n = numel(t_stamp);
if mod(n,4) && n > 3 % for Decker and other timeslot analyzers...
    t_stamp = t_stamp(3:end);
    the_matrix = the_matrix(:,3:end);
end

handles.eDefStr=eDefStr;
handles.nPoints = numel(t_stamp);
handles.the_matrix = the_matrix;
handles.t_stamp = datestr(matlabTS);
handles.isPV = isPV;
disp(['Retrieved ' num2str(numel(t_stamp)) ' synchronous points'])
if (~isfield(handles,'bpms'))
    handles = setup_BSA_BPMS(handles);
end

% Update handles structure
guidata(handles.output, handles);

set( hObject, 'Value', 0 );
set( hObject, 'String', 'Done' );
drawnow
pause(1);
set( hObject, 'String', 'Get Data...' );
try
    set(handles.nActual_txt,'string',num2str(size(the_matrix,2)));
catch
    set(handles.nActual_txt,'string','...?');
end
disp('Fault File request complete.');


% --- Executes on button press in get_data_button.
function get_data_button_Callback(hObject, eventdata, handles)

disp('Acquire Data button pressed.');
% uniqueNumberPV = 'SIOC:SYS0:ML00:AO900';
% try
%     lcaPutSmart(uniqueNumberPV, 1+lcaGetSmart(uniqueNumberPV));
% catch
%     % Not much I can do if this fails
% end
% uniqueNumber = lcaGetSmart(uniqueNumberPV);
% 
% %figure out beamcode
% str = get(handles.edef_menu,'String');
% val = get(handles.edef_menu,'Value');
% isCUS = strncmp('CUS',str{val},3);
% if isCUS, beamCode = 2; else beamCode=1; end
% if ~isfield(handles,'eDefNumber'),
%     [event_num] = eDefReserve(sprintf('BSA_GUI %d',uniqueNumber));
%     handles.eDefNumber = event_num;
% else
%     event_num = handles.eDefNumber
% end
% handles.nPoints= str2double(get(handles.num_points,'String'));
% num_points = handles.nPoints;
% eDefParams(event_num,1,num_points);
% lcaPut(['EDEF:SYS0:' num2str(event_num) ':BEAMCODE'],beamCode);
set( handles.select_EDEF_text, 'String', 'Getting Data...' );

eDefAcq(handles.eDefNumber, handles.nPoints);
new_name = strcat(handles.ROOT_NAME, {'HST'}, {num2str(handles.eDefNumber)});
set(handles.select_EDEF_text, 'String', ['New Data: HST' num2str(handles.eDefNumber)])
handles.eDefStr = ['HST' num2str(handles.eDefNumber)];                                

%
tic
done = false;
while ~done
    done = eDefDone(handles.eDefNumber);
    pause(0.1)
end
toc
[the_matrix, t_stamp, isPV] = lcaGetSmart( new_name, handles.nPoints );
k=0;
indx_time = strmatch('PATT:SYS0:1:PULSEID',handles.ROOT_NAME);
matlabTS = lca2matlabTime(t_stamp(indx_time));
%handles.nPoints = num_points;
handles.the_matrix = the_matrix;
handles.time_stamps = t_stamp;
handles.t_stamp = datestr(matlabTS);
handles.isPV = isPV;

%
if (~isfield(handles,'bpms'))
    handles = setup_BSA_BPMS(handles);
end

% Update handles structure
guidata(handles.output, handles);


try
    set(handles.nActual_txt,'string',num2str(size(the_matrix,2)));
catch
    set(handles.nActual_txt,'string','...?');
end
%

disp('Get Data request complete.');

% --- Executes on button press in save_data_button.
function save_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Saving Data...');
set( hObject, 'String', 'Saving Data...' );

data = getData(handles);

[fileName, pathName]=util_dataSave(data,'BSA',['data-' handles.eDefStr] ,handles.t_stamp,0);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
str={'*' ''};
set(handles.output,'Name',['BSA GUI - [' handles.fileName ']' str{handles.process.saved+1}]);
guidata(hObject,handles);

set( hObject, 'Value', 0 );
set( hObject, 'String', '...Done' );
pause(1);
set( hObject, 'String', 'Save Data' );

fprintf('Data saved to %s',fileName);

% Attempt to save filename to PV
fullFileName = [ pathName '/' fileName ];
lcaPutSmart('SIOC:SYS0:ML00:CA700', double(uint8(fullFileName)));

function data = getData(handles)
handlesFields = fieldnames(handles);
for ii = 1:length(handlesFields)
    h = handlesFields{ii};
    if ~ishandle(handles.(h)) 
        if strcmp(h,'figure_handles'), continue, end
        data.(h) = handles.(h);
    end
end
data.the_matrix= handles.the_matrix; %Force this one as ~ishandles fails


% --- Executes on button press in save_as_data_button.
function save_as_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_as_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Saving Data...');
set( hObject, 'String', 'Saving Data...' );

data = getData(handles);

fileName=util_dataSave(data,'BSA',['data-' handles.eDefStr],handles.t_stamp,1);
if ~ischar(fileName), return, end
handles.fileName=fileName;
handles.process.saved=1;
str={'*' ''};
set(handles.output,'Name',['BSA GUI - [' handles.fileName ']' str{handles.process.saved+1}]);
guidata(hObject,handles);

set( hObject, 'Value', 0 );
set( hObject, 'String', '...Done' );
pause(1);
set( hObject, 'String', 'Save Data As' );

fprintf('Data saved to %s',fileName);

% --- Executes on button press in load_data_button.
function load_data_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Loading Data...');
set( hObject, 'String', 'Loading Data...' );
pause(1);
%load BSA-data-2009-04-21-132434
[data, fileName, pathName] = util_dataLoad('File to load',0,'BSA-data*.mat');
%
%
if ~isfield(data,'nActual_txt')
    data.nActual_txt = handles.nActual_txt;
    %really should not be saving the entire GUI state this way...
end
%handles = data;
dataFields = fieldnames(data);
for ii = 1:length(dataFields)
    try
        if ~ishandle(handles.(dataFields{ii})),
            handles.(dataFields{ii}) = data.(dataFields{ii});
        end
    catch
        handles.(dataFields{ii}) = data.(dataFields{ii});
    end
end
handles.the_matrix = data.the_matrix;



set( handles.variable1, 'String', handles.ROOT_NAME );
set( handles.variable2, 'String', handles.ROOT_NAME );
if isfield(data, 'num_points'), nPoints = data.num_points; end
if isfield(data, 'nPoints'), nPoints = data.nPoints; end
set( handles.num_points, 'String', nPoints );

% Initialize BPMs if needed
if ~isfield(handles,'bpms')
    handles = setup_BSA_BPMS(handles);
end

reset1_Callback(hObject, eventdata, handles)
reset1_Callback(hObject, eventdata, handles)

% Update handles structure
guidata(handles.output, handles);
%
set( hObject, 'Value', 0 );
set( hObject, 'String', '...Done' );
pause(1);
set( hObject, 'String', 'Load Data' );
try
    set(handles.nActual_txt,'string',num2str(size(handles.the_matrix,2)));
catch ex
    set(handles.nActual_txt,'string','...?');
    rethrow(ex)
end
disp(sprintf('Data loaded from %s', fileName));



% --- Executes on button press in A_vs_Time.
function A_vs_Time_Callback(hObject, eventdata, handles)
% hObject    handle to A_vs_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Sorts out pulseid into time
%
% A vs time
%   std/mean mean std
%   hist with asym gauss fit
%

disp('A vs Time button pressed');
indx2 = strmatch(sprintf('PATT:SYS0:1:PULSEID'),handles.ROOT_NAME);

indx1 = get( handles.variable1, 'Value' );
xdata = handles.the_matrix((indx2),:);
ydata = handles.the_matrix(handles.foundVar1Indx(indx1),:);


max_pulseid = 131040;
stepsIndx = find(diff(xdata) < 0 );
%pidNorm = xdata;
for ii = 1:length(stepsIndx)
    pidNorm = [xdata(1:stepsIndx(ii)) xdata(stepsIndx(ii)+1:end) + max_pulseid];
    xdata = pidNorm;
    disp('pulseid wraparound!   fixing....')
end

xdata = xdata - xdata(1);
xdata = xdata / 360;

xtext = 'TIME [s]';
ytext = handles.ROOT_NAME(handles.foundVar1Indx(indx1));

figure;
plot_menus_BSA


plot(xdata, ydata, '-', xdata, ydata, '*');
set(gca,'FontUnits','normalized', 'FontSize',0.035);
xlabel(xtext,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(ytext,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

std_y=util_stdNan(ydata);

std_mean_y = sprintf('%5.3g',std_y/util_meanNan(ydata));

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[-0.1 -0.07],...
	'HorizontalAlignment','left',...
    'String',...
	['std = ' sprintf('%5.3g',std_y )]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[-0.1 -0.11],...
	'HorizontalAlignment','left',...
    'String',...
	['std/mean = ' std_mean_y]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);

disp(sprintf('Done plotting %s vs %s', char(ytext), char(xtext)));



% --- Executes on button press in plot_yvsx.
function plot_yvsx_Callback(hObject, eventdata, handles)
% hObject    handle to plot_yvsx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%
%
%

disp('A vs B button pressed...');

indx2 = get( handles.variable2, 'Value' );
indx1 = get( handles.variable1, 'Value' );
xdata = handles.the_matrix(handles.foundVar2Indx(indx2),:);
ydata = handles.the_matrix(handles.foundVar1Indx(indx1),:);
xtext = handles.ROOT_NAME(handles.foundVar2Indx(indx2));
ytext = handles.ROOT_NAME(handles.foundVar1Indx(indx1));

figure;
plot_menus_BSA
[p,Y,dp] = util_polyFit(xdata, ydata, 1 );
%Y = p(1)*xdata + p(2);
plot(xdata, ydata, '*', xdata, Y, '-');
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(xtext,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(ytext,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

corf = corcoef(xdata, ydata);
cf=sprintf('%4.2f',corf);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.9 1.02],...
	'HorizontalAlignment','right',...
    'String',...
	['corr coef = ' cf]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.95],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('Y = MX + B')]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.91],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('M = %7.3g ', p(1))]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);

disp(sprintf('Done plotting %s vs %s', char(ytext), char(xtext)));

%
% plots 
%
% get EGU (engineering units)
%
% line on/off in correlation
% add polyfit on/off to correlation
%
% A vs B
% PSD(A)
% Sqrt(Int(PSD(A)))
%
% to do:  
%         make correlated sigma by taking out beta
% %        power in a user specified band vs Z????????????
%         energy correlation vs Z (with final energy fluctuations) (FJD Z)
%         remove betatron osc from energy - maybe mia svd?
%         in time button, histogram and fit with asym gauss
%         rms vs Z
%         


% --- Executes on button press in A_PSD.
function A_PSD_Callback(hObject, eventdata, handles)
% hObject    handle to A_PSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('A PSD button pressed...');

indx2 = strmatch('PATT:SYS0:1:PULSEID',handles.ROOT_NAME);
indx1 = get( handles.variable1, 'Value' );
xdata = handles.the_matrix((indx2),:);
ydata = handles.the_matrix(handles.foundVar1Indx(indx1),:);

max_pulseid = 131040;
stepsIndx = find(diff(xdata) < 0 );
pidNorm = xdata;
for ii = 1:length(stepsIndx)
    pidNorm = [xdata(1:stepsIndx(ii)) xdata(stepsIndx(ii)+1:end) + max_pulseid];
    xdata = pidNorm;
    disp('pulseid wraparound!   fixing....')
end

xdata = xdata - xdata(1);

seconds = xdata / 360;

% test for rate change
dt = diff(seconds);
[beamrate_vector] = 1./dt;

secs = seconds(1:length(seconds)-1);

figure
plot_menus_BSA
plot(secs,beamrate_vector,'.-')
            ylabel('Beamrate',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.040]);

max_rate = max(beamrate_vector);
diff_xdata = (diff(xdata));
diff_xdata = diff_xdata - diff_xdata(1);
diff_xdata_sum = sum(abs(diff_xdata));

if diff_xdata_sum~=0
    disp('rate varied during data!   Taking largest block of highest rate')
    disp(' this is still... under construction!')
    
    dx = diff(xdata);
    ddx = (diff(dx));
    id_pblm = find(ddx~=0);
    
    figure
    plot_menus_BSA
    datalen = (1:length(ddx));
    plot(datalen,ddx,'.-',datalen(id_pblm),ddx(id_pblm),'s')
                ylabel('Beamrate Derivative Discontinuities',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.040]);
    
    %at_max_rate = find(beamrate_vector == max_rate);
    [block_boundaries] = [1 id_pblm length(xdata)];
    blocks = diff(block_boundaries);
    [blocksize,iblock] = sort(blocks,'descend');
    select = 0;
    for jj = 1:length(blocks)
        if ((round(beamrate_vector(block_boundaries(iblock(jj))+1)) >= round(max_rate)) & select==0)
            select = 1;
            block_index = [block_boundaries(iblock(jj)) block_boundaries(iblock(jj)+1)];
            disp('getting indices of highest beamrate data block to be used')
            [ydata] = ydata(block_index(1)+2:block_index(2)-2);
            figure
            plot_menus_BSA
            plot(seconds(block_index(1)+2:block_index(2)-2),ydata,'.-')
            set(gca,'FontUnits','normalized',...
                'FontSize',[0.035]);
            ylabel('data selected for use',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035]);
            xlabel('TIME [s]',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035]);

            text('Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035],...
                'Position',[0.1 1.02],...
                'HorizontalAlignment','left',...
                'String',...
                [handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
            text('Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035],...
                'Position',[1.0 -0.07],...
                'HorizontalAlignment','right',...
                'String',...
                [handles.t_stamp]);

        end
    end
    
end

figure;
plot_menus_BSA
beamrate = max_rate;

[ p ] = psdint(ydata',beamrate, length(ydata'),'s',0,0);
freq   = p(2:length(p),1);
psd_mm = p(2:length(p),2);
plot(freq,psd_mm);
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel('Power Spectral Density',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel('Frequency [Hz]',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);

mm_sq = freq(1)*(cumsum(psd_mm(length(psd_mm):-1:1)));
mm_squared = flipud(mm_sq);
mm = sqrt(mm_squared);


figure;
plot_menus_BSA
plot(freq, mm_squared, '-', freq, mm_squared, '*');
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
p1text = sprintf('%7.3g', (mm(1)));
ylabel(['Integrated PSD * df'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel('Frequency [Hz]',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.9 1.02],...
	'HorizontalAlignment','right',...
    'String',...
	['std of raw data = ' sprintf('%6.4g',std(ydata))]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);

disp(sprintf('Done Plotting %s PSD',char([handles.ROOT_NAME(handles.foundVar1Indx(indx1))])));




% --- Executes on button press in a_vs_z.
function a_vs_z_Callback(hObject, eventdata, handles)
% hObject    handle to a_vs_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('All Z vs A button pressed...');

indx1 = get( handles.variable1, 'Value' );
xdata2 = handles.the_matrix(handles.foundVar1Indx(indx1),:);
xtext = handles.ROOT_NAME(handles.foundVar1Indx(indx1));
ydata2 = handles.the_matrix(handles.foundVar2Indx,:);
ytext = handles.ROOT_NAME(handles.foundVar2Indx);
myStr = get( handles.search_string2, 'String' );
[N,l] = size(ydata2);

z_found = handles.z_positions(handles.foundVar2Indx);
%z_found = z_found-handles.zLCLS;
if length(z_found) ~= N
    z_found = 1:N;
end
corf=[];
for j=1:N
    [corf(j)] = corcoef(xdata2,ydata2(j,:));
end


%handles.bpms.etax_id
for j=1:length(handles.bpms.etax_id)
    [etax_corf(j)] = corcoef(xdata2,handles.the_matrix(handles.bpms.etax_id(j),:));
end
for j=1:length(handles.bpms.etay_id)
    [etay_corf(j)] = corcoef(xdata2,handles.the_matrix(handles.bpms.etay_id(j),:));
end

% bpm 250 in LTUH data or LTUS 235 

bpm250x = handles.the_matrix(handles.bpms.etax_id(4),:);
bpm450x = handles.the_matrix(handles.bpms.etax_id(5),:);

useX = ~isnan(bpm250x) & ~isnan(bpm450x);


handles.bpms.x_id;

for j=1:length(handles.bpms.x_id)
     useY = ~isnan(handles.the_matrix(handles.bpms.x_id(j),:));
     use = useX & useY;
     try   
        [x_bpm_corf(j)] = corcoef(xdata2,handles.the_matrix(handles.bpms.x_id(j),:));
        [x_bpm_rms(j)] = util_stdNan(handles.the_matrix(handles.bpms.x_id(j),:));
        [etaxcorf(j)] = corcoef(bpm250x,handles.the_matrix(handles.bpms.x_id(j),:));
        a = util_polyFit(bpm250x(use),handles.the_matrix(handles.bpms.x_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end;
        if a < -2, a = -2; end;
        b = util_polyFit(bpm450x(use),handles.the_matrix(handles.bpms.x_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2; end;
        if b < -2, b = -2; end;
        [parx250(j)] = a;
        [parx450(j)] = b;
     catch
        x_bpm_corf(j) = NaN;
        x_bpm_rms(j) = NaN;
        etaxcorf(j) = NaN;
        parx250(j) = NaN;
        parx450(j) = NaN;
    end
end
handles.bpms.y_id;
for j=1:length(handles.bpms.y_id)
    useY = ~isnan(handles.the_matrix(handles.bpms.y_id(j),:));
    use = useX & useY;
    %if ~any(isnan(handles.the_matrix(handles.bpms.y_id(j),:)))
    try
        [y_bpm_corf(j)] = corcoef(xdata2,handles.the_matrix(handles.bpms.y_id(j),:));
        [y_bpm_rms(j)] = util_stdNan(handles.the_matrix(handles.bpms.y_id(j),:));
        [etaycorf(j)] = corcoef(bpm250x,handles.the_matrix(handles.bpms.y_id(j),:));
        a = util_polyFit(bpm250x(use),handles.the_matrix(handles.bpms.y_id(j),use),1);
        [a]=a(1,:);
        if a > 2, a = 2; end;
        if a < -2, a = -2; end;
        b = util_polyFit(bpm450x(use),handles.the_matrix(handles.bpms.y_id(j),use),1);
        [b]=b(1,:);
        if b > 2, b = 2;, end;
        if b < -2, b = -2;, end;
        [pary250(j)] = a;
        [pary450(j)] = b;
    catch
        y_bpm_corf(j) = NaN;
        y_bpm_rms(j) = NaN;
        etaycorf(j) = NaN;
        pary250(j) = NaN;
        pary450(j) = NaN;
    end
end



z = handles.z_positions;
z_etay_bpm = handles.z_positions(handles.bpms.etay_id) - handles.zLCLS;
z_etax_bpm = handles.z_positions(handles.bpms.etax_id) - handles.zLCLS;
z_y_bpm = handles.z_positions(handles.bpms.y_id) - handles.zLCLS;
z_x_bpm = handles.z_positions(handles.bpms.x_id) - handles.zLCLS;

if (~isfield(handles.bpms,'betax'))||(handles.new_model==1)
    % example:   aidaget('BPMS:DMP1:693//twiss','floata')
    % 15 floats: Kinetic Energy (GeV),   psix,   betax (m),   alphax,   etax (m),
    %                           etax',   psiy,   betay (m),   alphay,   etay (m), 
    % etay',  Z (m), Effective Length (m), Slice Effective Length (m), Ordinal position in beamline (as a float)

    %
    set( hObject, 'String', 'Get Model...' );
    %
    % WAIT FUNCTION?
    %
    
    % pause(1);
    
    set( hObject, 'Value', 0 );
    %
    %
    handles.bpms.name = strrep(handles.bpms.x, ':X', '');
    if handles.isSxr, beamPath = 'CU_SXR'; else beamPath = 'CU_HXR'; end
    model_init('source','MATLAB'); % yeah I did. --TJM
    [rMat, zPos, lEff, twiss, energy] = model_rMatGet(handles.bpms.name,[],{['BEAMPATH=' beamPath]});
    betax_bpm = twiss(3,:);
    betay_bpm = twiss(8,:);
    etax_bpm  = twiss(5,:);
    etay_bpm  = twiss(10,:);
    %energy    = twiss(1,:);
    %zPos      = twiss(12,:);
    
    %%%%


    handles.bpms.betax = betax_bpm;
    handles.bpms.betay = betay_bpm;
    handles.bpms.etax = etax_bpm;
    handles.bpms.etay = etay_bpm;
    handles.bpms.energy = energy;
    handles.bpms.z = zPos;
end

set( hObject, 'String', 'Done' );
pause(1);
set( hObject, 'String', 'All Z vs A' );


% dispersion as determined by 
% slope with BPM 250 in LTU in mm * dispersion_at_250 + same at 450 and
% divide by two
if handles.isSxr    
    etaxIndx1 = strcmp(handles.bpms.name,'BPMS:LTUS:235');
    etaxIndx2 = strcmp(handles.bpms.name,'BPMS:LTUS:370');  
else
    etaxIndx1 = strcmp(handles.bpms.name,'BPMS:LTUH:250');
    etaxIndx2 = strcmp(handles.bpms.name,'BPMS:LTUH:450'); 
end
handles.bpms.x_dispersion = (1e3 * parx250 * handles.bpms.etax(etaxIndx1) + 1e3 * parx450 * handles.bpms.etax(etaxIndx2))/2 ;
handles.bpms.y_dispersion = (1e3 * pary250 * handles.bpms.etax(etaxIndx1) + 1e3 * pary450 * handles.bpms.etax(etaxIndx2))/2 ;


% Motion with dispersion taken out
handles.bpms.x_nodisp = handles.bpms.x_dispersion + handles.bpms.etax;



% emittance at 0.5 um, then (in meters and GeV)
emit_n = 0.5e-6;
gamma = 1 + ( handles.bpms.energy / 0.000511);
beta = ( sqrt ((gamma.*gamma) - 1))./gamma;
beta_gamma = gamma.*beta;
emit = emit_n ./ beta_gamma;
handles.bpms.sigmax = 1e6 * sqrt(handles.bpms.betax .* emit); % back to microns for the result
handles.bpms.sigmay = 1e6 * sqrt(handles.bpms.betay .* emit); % back to microns for the result
%
%
x_bpm_rms_n = x_bpm_rms ./ (handles.bpms.sigmax/1e3); %adjust to mm for normalization
y_bpm_rms_n = y_bpm_rms ./ (handles.bpms.sigmay/1e3); %adjust to mm for normalization
%
% For non-dispersive bpms:
x_noeta_bpm_rms = x_bpm_rms;
y_noeta_bpm_rms = y_bpm_rms;
x_noeta_bpm_rms(handles.bpms.etax_sub_id) = [];
y_noeta_bpm_rms(handles.bpms.etay_sub_id) = [];


x_noeta_bpm = handles.bpms.x;
x_noeta_bpm(handles.bpms.etax_sub_id) = [];

x_noeta_bpm_rms_n = x_bpm_rms_n;
x_noeta_bpm_rms_n(handles.bpms.etax_sub_id) = [];
z_noeta_x_bpm = handles.bpms.z;
z_noeta_x_bpm(handles.bpms.etax_sub_id) = [];
y_noeta_bpm_rms_n = y_bpm_rms_n;
y_noeta_bpm_rms_n(handles.bpms.etay_sub_id) = [];
z_noeta_y_bpm = handles.bpms.z;
z_noeta_y_bpm(handles.bpms.etay_sub_id) = [];


z_etay_bpm = handles.bpms.z(handles.bpms.etay_sub_id);
z_etax_bpm = handles.bpms.z(handles.bpms.etax_sub_id);
z_y_bpm = handles.bpms.z;
z_x_bpm = handles.bpms.z;

guidata(handles.output, handles);



if isempty(myStr)
    xStr = sprintf('All BSA units');
    tStr = sprintf('correlation with all BSA units');
else
    xStr = sprintf('Z position of all units containing "%s"',myStr); 
    tStr = sprintf('correlation with all units containing "%s"',myStr);
end

figure;
plot_menus_BSA
plot(z_found, corf, '-', z_found, corf, '*');
A = axis;
axis([0 A(2) A(3) A(4)]);
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['correlation with ', xtext],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(xStr,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.4 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[tStr]);

%
figure;
plot_menus_BSA
plot(handles.bpms.z, x_bpm_corf, 'b-', handles.bpms.z, x_bpm_corf, 'b+', z_etax_bpm, etax_corf,'m*');
A = axis;
axis([0 A(2) A(3) A(4)]);
xStr = sprintf('X BPM Z positions');

set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['correlation with ', xtext],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(xStr,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.4 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	['correlation with X BPM positions']);


figure;
plot_menus_BSA
plot(z_y_bpm, y_bpm_corf, 'b-', z_y_bpm, y_bpm_corf, 'b+', z_etay_bpm, etay_corf,'m*');
A = axis;
axis([0 A(2) A(3) A(4)]);
xStr = sprintf('Y BPM Z positions');

set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['correlation with ', xtext],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(xStr,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.4 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	['correlation with Y BPM positions']);

%
%
%
%
% Experimental display for coupling diagnosis
%

handles.bpms.x_id;
for j=1:length(handles.bpms.x_id)
    [xy_bpm_corf(j)] = corcoef(handles.the_matrix(handles.bpms.x_id(j),:),handles.the_matrix(handles.bpms.y_id(j),:));
end



figure;
plot_menus_BSA
plot(handles.bpms.z, xy_bpm_corf, 'b-', handles.bpms.z, xy_bpm_corf, 'b+');
%    z_etax_bpm, etaxy_corf,'m*', z_etay_bpm, etayx_corf,'m*');
A = axis;
axis([0 A(2) A(3) A(4)]);
xStr = sprintf('BPM Z positions');

set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['XY factor'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(xStr,...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.4 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	['XY coupling with BPM positions']);



%%%%
%
% dispersion at each bpm 
figure;
plot_menus_BSA;
font_size=0.08;
subplot(2,1,1)
%plot(handles.bpms.z,handles.bpms.x_dispersion,'b-',handles.bpms.z,handles.bpms.y_dispersion,'m-')
plot(handles.bpms.z,handles.bpms.x_dispersion,'b-')
set(gca,'FontUnits','normalized',...
    'FontSize',font_size);
ylabel(['horizontal dispersion (mm)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',font_size);
A = axis;
axis([0 A(2) -50 50]);


subplot(2,1,2)
plot(handles.bpms.z,handles.bpms.y_dispersion,'b-')
set(gca,'FontUnits','normalized',...
    'FontSize',font_size);
ylabel(['vertical dispersion (mm)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',font_size);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',font_size);
axis([0 A(2) -50 50]);


%
% dispersion at each bpm 
figure;
plot_menus_BSA;
font_size=0.035;
%subplot(2,1,1)
plot(handles.bpms.z,handles.bpms.x_nodisp,'b-')
set(gca,'FontUnits','normalized',...
    'FontSize',font_size);
ylabel(['horizontal dispersion (mm)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',font_size);
A = axis;

%%%%



%
%
figure;
plot_menus_BSA;
plot(z_noeta_x_bpm,x_noeta_bpm_rms_n,'b-',z_noeta_x_bpm,x_noeta_bpm_rms_n,'b+')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['normalized horizontal rms motion (sigma) '],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
figure;
plot_menus_BSA;
plot(z_noeta_y_bpm,y_noeta_bpm_rms_n,'b-',z_noeta_y_bpm,y_noeta_bpm_rms_n,'b+')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['normalized vertical rms motion (sigma) '],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);



figure;
plot_menus_BSA;
plot(z_noeta_x_bpm,x_noeta_bpm_rms,'b-',z_noeta_x_bpm,x_noeta_bpm_rms,'b+')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['horizontal rms motion (mm) '],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
figure;
plot_menus_BSA;
plot(z_noeta_y_bpm,y_noeta_bpm_rms,'b-',z_noeta_y_bpm,y_noeta_bpm_rms,'b+')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['vertical rms motion (mm) '],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);






figure;
plot_menus_BSA;
plot(z_x_bpm,handles.bpms.sigmax,'g-',handles.bpms.z,handles.bpms.sigmay,'b-',z_x_bpm,handles.bpms.sigmax,'g+',handles.bpms.z,handles.bpms.sigmay,'b+')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['model beam sigma (in microns)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.01 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	['Model beam size at BSA BPMs from beta not dispersion, x=green y=blue']);
figure;
plot_menus_BSA;
plot(z_x_bpm,handles.bpms.energy,'b-',z_x_bpm,handles.bpms.energy,'b+')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
ylabel(['model beam energy '],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel(['Z position (meters)'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);

disp('All Z vs A button done...');

function corf=corcoef(xdata,ydata)
% calculates correlation coefficient from xdata and ydata
% returns it in 'corf'
N=length(xdata);
useX = ~isnan(xdata);
useY = ~isnan(ydata);
use = useX & useY;
xdata = xdata(use);
ydata = ydata(use);
corf=(N*sum(xdata.*ydata)-sum(xdata)*sum(ydata))/...
	sqrt((N*sum(xdata.*xdata)-(sum(xdata))*(sum(xdata)))*...
	(N*sum(ydata.*ydata)-(sum(ydata))*(sum(ydata))));


% --- Executes on button press in new_model.
function new_model_Callback(hObject, eventdata, handles)
% hObject    handle to new_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.new_model = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of new_model
% Update handles structure
guidata(handles.output, handles);


% --- Executes during object creation, after setting all properties.
function new_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to new_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1);




function handles = setup_BSA_BPMS(handles)
isHXR = ~handles.isSxr;
% set-up ids for bpms with horizontal dispersion
j=1;

handles.bpms.etax{j,:} = sprintf('BPMS:IN20:731:X'); j = j + 1;
handles.bpms.etax{j,:} = sprintf('BPMS:LI21:233:X'); j = j + 1;
handles.bpms.etax{j,:} = sprintf('BPMS:LI24:801:X'); j = j + 1;

if isHXR
    handles.bpms.etax{j,:} = sprintf('BPMS:LTUH:250:X'); j = j + 1;
    handles.bpms.etax{j,:} = sprintf('BPMS:LTUH:450:X'); j = j + 1;
else
    handles.bpms.etax{j,:} = sprintf('BPMS:LTUS:235:X'); j = j + 1;
    handles.bpms.etax{j,:} = sprintf('BPMS:LTUS:370:X'); j = j + 1;
    handles.bpms.etax{j,:} = sprintf('BPMS:CLTS:420:X'); j = j + 1;
    handles.bpms.etax{j,:} = sprintf('BPMS:CLTS:620:X'); j = j + 1;   
end

j=0;
for j = 1:length(handles.bpms.etax)
    try
    [handles.bpms.etax_id(j)] = strmatch(handles.bpms.etax(j,:),handles.ROOT_NAME);
    catch
    end
end

% set-up ids for bpms with vertical dispersion
j=1;

if isHXR
    handles.bpms.etay{j,:} = sprintf('BPMS:LTUH:130:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:LTUH:150:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:LTUH:170:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:DMPH:502:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:DMPH:693:Y'); j = j + 1;
    
else
    handles.bpms.etay{j,:} = sprintf('BPMS:CLTS:450:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:CLTS:590:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:DMPS:502:Y'); j = j + 1;
    handles.bpms.etay{j,:} = sprintf('BPMS:DMPS:693:Y'); j = j + 1;
    
end
    
j=0;
for j = 1:length(handles.bpms.etay)
    try
    [handles.bpms.etay_id(j)] = strmatch(handles.bpms.etay(j,:),handles.ROOT_NAME);
    catch
    end
end


%bpms = model_nameRegion('BPMS','LCLS');
%bpms = setdiff(bpms,'BPMS:UND1:3395','stable');

[prim,micro,unit,secn] = model_nameSplit(handles.ROOT_NAME);

% use = strcmp(prim,'BPMS');
% inroot = strcat(prim(use),':',micro(use),':',unit(use));
% bpms = unique(inroot);
% 
% handles.bpms.x = strcat(bpms,':X');
% handles.bpms.y = strcat(bpms,':Y');
% handles.bpms.y_id = zeros(1,length(handles.bpms.y));
% handles.bpms.x_id = zeros(1,length(handles.bpms.x));
% 
% for j = 1:length(handles.bpms.y)
%     [handles.bpms.y_id(j)] = strmatch(handles.bpms.y(j,:),handles.ROOT_NAME);
% end
% for j = 1:length(handles.bpms.x)
%     [handles.bpms.x_id(j)] = strmatch(handles.bpms.x(j,:),handles.ROOT_NAME);
% end

isBpm = strcmp(prim,'BPMS');
isX = strcmp(secn,'X');
isY = strcmp(secn,'Y');
handles.bpms.x = handles.ROOT_NAME(isBpm & isX);
handles.bpms.y = handles.ROOT_NAME(isBpm & isY);
handles.bpms.x_id = find(isBpm & isX);
handles.bpms.y_id = find(isBpm & isY);


for j = 1:length(handles.bpms.etay)
    [handles.bpms.etay_id(j)] = strmatch(handles.bpms.etay(j,:),handles.ROOT_NAME);
    [handles.bpms.etay_sub_id(j)] = strmatch(handles.bpms.etay(j,:),handles.bpms.y);
end

handles.y_noeta_bpm_id = handles.bpms.y_id;
handles.y_noeta_bpm_id(handles.bpms.etay_sub_id) = [];

handles.y_noeta_bpm = handles.bpms.y;
handles.y_noeta_bpm(handles.bpms.etay_sub_id) = [];

for j = 1:length(handles.bpms.etax)
    [handles.bpms.etax_id(j)] = strmatch(handles.bpms.etax(j,:),handles.ROOT_NAME);
    [handles.bpms.etax_sub_id(j)] = strmatch(handles.bpms.etax(j,:),handles.bpms.x); 
end
handles.x_noeta_bpm_id = handles.bpms.x_id;
handles.x_noeta_bpm_id(handles.bpms.etax_sub_id) = [];

handles.x_noeta_bpm = handles.bpms.x;
handles.x_noeta_bpm(handles.bpms.etax_sub_id) = [];



% --- Executes on button press in all_z_psd.
function all_z_psd_Callback(hObject, eventdata, handles)
% hObject    handle to all_z_psd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('All Z PSD button pressed...');
[sys,accelerator]=getSystem();

if ~isfield(handles,'bpms')
    handles = setup_BSA_BPMS(handles);
end
psd_start = str2double(get( handles.psd_start, 'String' ));
psd_end = str2double(get( handles.psd_end, 'String' ));

indx2 = strmatch('PATT:SYS0:1:PULSEID',handles.ROOT_NAME);
xdata2 = handles.the_matrix((indx2),:);
indx1 = get( handles.variable1, 'Value' );
ydata2 = handles.the_matrix(handles.foundVar2Indx,:);
ytext = handles.ROOT_NAME(handles.foundVar2Indx);
myStr = get( handles.search_string2, 'String' );
[N,l] = size(ydata2);

z_found = handles.z_positions(handles.foundVar2Indx);
%z_found = z_found-handles.zLCLS;
if length(z_found) ~= N
    z_found = 1:N;
end


max_pulseid = 131040;
stepsIndx = find(diff(xdata2) < 0 );
pidNorm = xdata2;
for ii = 1:length(stepsIndx)
    pidNorm = [xdata2(1:stepsIndx(ii)) xdata2(stepsIndx(ii)+1:end) + max_pulseid];
    xdata2 = pidNorm;
    disp('pulseid wraparound!   fixing....')
end

xdata2 = xdata2 - xdata2(1);

seconds = xdata2 / 360;

% test for rate change
dt = diff(seconds);
[beamrate_vector] = 1./dt;

secs = seconds(1:length(seconds)-1);

figure
plot_menus_BSA
plot(secs,beamrate_vector,'.-')
            ylabel('Beamrate',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.040]);

max_rate = max(beamrate_vector);
diff_xdata = (diff(xdata2));
diff_xdata = diff_xdata - diff_xdata(1);
diff_xdata_sum = sum(abs(diff_xdata));

if diff_xdata_sum~=0
    disp('rate varied during data!   Taking largest block of highest rate')
    disp(' this is still... under construction!')
    
    dx = diff(xdata2);
    ddx = (diff(dx));
    id_pblm = find(ddx~=0);
    
    figure
    plot_menus_BSA
    datalen = (1:length(ddx));
    plot(datalen,ddx,'.-',datalen(id_pblm),ddx(id_pblm),'s')
                ylabel('Beamrate Derivative Discontinuities',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.040]);
    
    %at_max_rate = find(beamrate_vector == max_rate);
    [block_boundaries] = [1 id_pblm length(xdata2)];
    blocks = diff(block_boundaries);
    [blocksize,iblock] = sort(blocks,'descend');
    select = 0;
    for jj = 1:length(blocks)
        if ((round(beamrate_vector(block_boundaries(iblock(jj))+1)) >= round(max_rate)) & select==0)
            select = 1;
            block_index = [block_boundaries(iblock(jj)) block_boundaries(iblock(jj)+1)];
            disp('getting indices of highest beamrate data block to be used')
            [ydata2] = ydata2(:,block_index(1)+2:block_index(2)-2);
            figure
            plot_menus_BSA
            plot(seconds(block_index(1)+2:block_index(2)-2),ydata2(handles.foundVar1Indx(indx1),:),'.-')
            set(gca,'FontUnits','normalized',...
                'FontSize',[0.035]);
            ylabel('data selected for use',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035]);
            xlabel('TIME [s]',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035]);

            text('Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035],...
                'Position',[0.1 1.02],...
                'HorizontalAlignment','left',...
                'String',...
                [handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
            text('Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035],...
                'Position',[1.0 -0.07],...
                'HorizontalAlignment','right',...
                'String',...
                [handles.t_stamp]);

        end
    end
    
end




beamrate = max_rate;

for jj=1:N
    [ p ] = psdint(ydata2(jj,:)',beamrate, length(ydata2(jj,:)'),'s',0,0);
    p_norm(jj) = sum(p(2:length(p),2));
    m_psd(jj,:) = p(2:length(p),2);
end

freq   = p(2:length(p),1);

indx_z = find(z_found>0);
z_indxd = z_found(indx_z);

p_norm_factor = p_norm(indx_z);

indx_slice=find(freq>=psd_start&freq<=psd_end);
freq_slice = freq(indx_slice);
psd_slice = m_psd(indx_z,indx_slice);

psd_slice_sum = ( sum( psd_slice,2 ) ) ./ ( p_norm_factor' );

figure;
plot_menus_BSA
plot(z_indxd, psd_slice_sum, '-');
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
p1text = sprintf('Power from %5.1f Hz to %5.1f Hz', psd_start, psd_end);
ylabel(['Integrated Normalized PSD'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel('Z Position (m)',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.85 1.02],...
	'HorizontalAlignment','right',...
    'String',...
	[p1text '  All Devices which have Z']);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);


handles.bpms.x_id;

try
for j=1:length(handles.bpms.x_id)
    [ p ] = psdint(handles.the_matrix(handles.bpms.x_id(j),:)',beamrate, ...
        length(handles.the_matrix(handles.bpms.x_id(j),:)'),'s',0,0);
    px_norm(j) = sum(p(2:length(p),2));
    mx_psd(j,:) = p(2:length(p),2);
end

catch
    keyboard
end
handles.bpms.y_id;
for j=1:length(handles.bpms.y_id)
    [ p ] = psdint(handles.the_matrix(handles.bpms.y_id(j),:)',beamrate, ...
        length(handles.the_matrix(handles.bpms.y_id(j),:)'),'s',0,0);
    py_norm(j) = sum(p(2:length(p),2));
    my_psd(j,:) = p(2:length(p),2);
end

psdx_slice = mx_psd(:,indx_slice);
psdx_slice_sum = ( sum( psdx_slice,2 ) ) ./ ( px_norm' );
psdy_slice = my_psd(:,indx_slice);
psdy_slice_sum = ( sum( psdy_slice,2 ) ) ./ ( py_norm' );

z_y_bpm = handles.z_positions(handles.bpms.y_id);%  handles.zLCLS;
z_x_bpm = handles.z_positions(handles.bpms.x_id);% - handles.zLCLS;

figure;
plot_menus_BSA
plot(z_y_bpm, psdy_slice_sum, 'b+-', z_y_bpm,psdy_slice_sum, 'b+',...
    z_y_bpm(handles.bpms.etay_sub_id), psdy_slice_sum(handles.bpms.etay_sub_id),'m*');
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
p1text = sprintf('Power from %5.1f Hz to %5.1f Hz', psd_start, psd_end);
ylabel(['Integrated Normalized PSD'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel('Z Position (m)',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.85 1.02],...
	'HorizontalAlignment','right',...
    'String',...
	[p1text '  All Y BPMs']);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);


figure;
plot_menus_BSA
plot(z_x_bpm, psdx_slice_sum, 'b+-', z_x_bpm,psdx_slice_sum, 'b+',...
    z_x_bpm(handles.bpms.etax_sub_id), psdx_slice_sum(handles.bpms.etax_sub_id),'m*');
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
p1text = sprintf('Power from %5.1f Hz to %5.1f Hz', psd_start, psd_end);
ylabel(['Integrated Normalized PSD'],...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
xlabel('Z Position (m)',...
    'Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.85 1.02],...
	'HorizontalAlignment','right',...
    'String',...
	[p1text '  All X BPMs']);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);




disp(sprintf('Done Plotting All PSD'))


% --- Executes on button press in histogramApushbutton.
function histogramApushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to histogramApushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[sys,accelerator]=getSystem();
indx2 = strmatch(sprintf('PATT:%s:1:PULSEID',sys),handles.ROOT_NAME);
indx1 = get( handles.variable1, 'Value' );

%xdata = handles.the_matrix((indx2),:);
ydata = handles.the_matrix(handles.foundVar1Indx(indx1),:);
std_y=sprintf('%5.3g',std(ydata));
std_mean_y = sprintf('%5.3g',std(ydata)/mean(ydata));
ytext = handles.ROOT_NAME(handles.foundVar1Indx(indx1));


figure
plot_menus_BSA

N = floor((length(ydata))/10);
if N<10 N=10; end
if N>100 N=100; end
[counts,barnum]=hist(ydata, N);
[yfit,p,dp,chisq]=gauss_fit(barnum, counts);
yyf = p(1)*ones(size(barnum)) + p(2)*sqrt(2*pi)*p(4)*gauss(barnum,p(3),p(4)); 
hist(ydata, N); 
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);
hold on; 
A=axis; 
plot(barnum,yfit,'b');
h = findobj(gca,'Type','patch');
set(h,'FaceColor','r','EdgeColor','w')
set(gca,'FontUnits','normalized',...
    'FontSize',[0.035]);

text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.6 1.03],...
	'HorizontalAlignment','center',...
    'String',...
	['A + B*exp( -(X-C)^2/2*D^2 )']);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.1 1.02],...
	'HorizontalAlignment','left',...
    'String',...
	[handles.ROOT_NAME(handles.foundVar1Indx(indx1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[1.0 -0.07],...
	'HorizontalAlignment','right',...
    'String',...
	[handles.t_stamp]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[-0.1 -0.07],...
	'HorizontalAlignment','left',...
    'String',...
	['std = ' std_y]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[-0.1 -0.11],...
	'HorizontalAlignment','left',...
    'String',...
	['std/mean = ' std_mean_y]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.95],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('A = %7.3g +- %7.3g',p(1),dp(1))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.91],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('B = %7.3g +- %7.3g',p(2),dp(2))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.87],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('C = %7.3g +- %7.3g',p(3),dp(3))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.83],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('D = %7.3g +- %7.3g',p(4),dp(4))]);
text('Units','normalized',...
    'FontUnits','normalized',...
    'FontSize',[0.035],...
	'Position',[0.02 0.79],...
	'HorizontalAlignment','left',...
    'String',...
	[sprintf('CHISQ/NDF = %8.3g',chisq)]);

disp(sprintf('Done plotting histogram of %s', char(ytext)));


% --- Executes on button press in cuhxr_radiobutton.
function cuhxr_radiobutton_Callback(hObject, eventdata, handles)
isSxr = get(handles.cusxr_radiobutton,'Val');
set( handles.cusxr_radiobutton,'Val', ~isSxr);


% --- Executes on button press in cusxr_radiobutton.
function cusxr_radiobutton_Callback(hObject, eventdata, handles)
isHxr = get(handles.cuhxr_radiobutton,'Val');
set( handles.cuhxr_radiobutton,'Val', ~isHxr);

% --- Executes on button press in hstbr_radiobutton.
function hstbr_radiobutton_Callback(hObject, eventdata, handles)
isEdef = get(handles.edef_radiobutton,'Val');
set(handles.edef_radiobutton, 'Val', ~isEdef);


% --- Executes on button press in edef_radiobutton.
function edef_radiobutton_Callback(hObject, eventdata, handles)
isBR = get(handles.hstbr_radiobutton,'Val');
set(handles.hstbr_radiobutton, 'Val', ~isBR);


% --- Executes on button press in newData_pushbutton.
function newData_pushbutton_Callback(hObject, eventdata, handles)
str = get(handles.edef_menu,'String');
val = get(handles.edef_menu,'Value');
isPrivate = any(findstr('Private', str{val}));

handles = updateRootName(handles.output, handles);
if ~handles.haveEDef && isPrivate, warndlg('Please use eDef Setup before Aquire New Data for Private eDefs'); return; end

if ~isPrivate
     Fault_File_Callback(hObject, eventdata, handles)
else
    get_data_button_Callback(hObject, eventdata, handles)
end
set(handles.select_EDEF_text, 'String', 'Done')


% --- Executes on selection change in edef_menu.
function edef_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edef_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%remove "bpms" field since we are changing eDEF
if isfield(handles,'bpms')
    handles = rmfield(handles, 'bpms');
end
% Update handles structure
guidata(hObject, handles);

contents = get(hObject, 'String');
[beamPath private] = strtok(contents{get(hObject,'Value')});

if isempty(private)
    set(handles.eDef_pushbutton,'Visible', 'off')
else
    set(handles.eDef_pushbutton,'Visible', 'on')
end
updateRootName(hObject, handles) 



% --- Executes during object creation, after setting all properties.
function edef_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edef_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'Value', 9) %BR


% --- Executes on button press in eDef_pushbutton.
function eDef_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to eDef_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.edef_menu,'String');
val = get(handles.edef_menu,'Value');

if ~handles.haveEDef
    uniqueNumberPV = 'SIOC:SYS0:ML00:AO900';
    lcaPutSmart(uniqueNumberPV, 1+lcaGetSmart(uniqueNumberPV));
    uniqueNumber = lcaGetSmart(uniqueNumberPV);
    
    %figure out beamcode

    isCUS = strncmp('CUS',str{val},3);
    if isCUS, beamCode = 2; else beamCode=1; end
    if ~isfield(handles,'eDefNumber'),
        event_num = eDefReserve(sprintf('BSA_GUI %d',uniqueNumber));
        handles.eDefNumber = event_num;
    end
    handles.nPoints= str2double(get(handles.num_points,'String'));
    num_points = handles.nPoints;
    eDefParams(event_num,1,num_points);
    lcaPutSmart(['EDEF:SYS0:' num2str(handles.eDefNumber) ':BEAMCODE'],beamCode);
    handles.beamCode = beamCode;
    handles.haveEDef =1;
end


prompt={'Beam Code ','Number of points '};
name='Private EDEF:';
numlines=1;
defaultanswer={num2str(handles.beamCode), num2str(handles.nPoints)};
answer=inputdlg(prompt,name,numlines,defaultanswer);

if ~isempty(answer)
    handles.beamCode = str2double(answer{1});
    handles.nPoints = str2double(answer{2});
    lcaPutSmart(['EDEF:SYS0:' num2str(handles.eDefNumber) ':BEAMCODE'],handles.beamCode);
    lcaPutSmart(['EDEF:SYS0:' num2str(handles.eDefNumber) ':MEASCNT'],handles.nPoints);
    set(handles.num_points,'String', answer{2});
    str{val} = [str{val} ' ' num2str(handles.eDefNumber)];
    set(handles.edef_menu, 'String', str);
end



% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function eDef_pushbutton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eDef_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Visible','off')
