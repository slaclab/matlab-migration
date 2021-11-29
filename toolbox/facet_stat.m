function varargout = facet_stat(varargin)
% FACET_STAT M-file for facet_stat.fig
%      FACET_STAT, by itself, creates a new FACET_STAT or raises the existing
%      singleton*.
%
%      H = FACET_STAT returns the handle to a new FACET_STAT or the handle to
%      the existing singleton*.
%
%      FACET_STAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACET_STAT.M with the given input arguments.
%
%      FACET_STAT('Property','Value',...) creates a new FACET_STAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before facet_stat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to facet_stat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help facet_stat

% Last Modified by GUIDE v2.5 18-Mar-2013 16:07:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @facet_stat_OpeningFcn, ...
                   'gui_OutputFcn',  @facet_stat_OutputFcn, ...
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

function facet_stat_OpeningFcn(hObject, eventdata, handles, varargin)
% --- Executes just before facet_stat is made visible.
%
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to facet_stat (see VARARGIN)
% UIWAIT makes facet_stat wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Choose default command line output for facet_stat
handles.output = hObject;

calendar_icon = importdata(fullfile(fileparts(get(hObject,'FileName')),'images','calendar.jpg'));
set([handles.calStart,handles.calEnd],'CDATA',calendar_icon);

set(handles.startTime,'String', datestr(now-1, 'mm/dd/yyyy HH:MM:SS'))
set(handles.endTime,'String', datestr(now, 'mm/dd/yyyy HH:MM:SS'))

% Update handles structure
guidata(hObject, handles);


function facet_stat_CloseRequestFcn(hObject, eventdata, handles)
% --- Executes when user attempts to close test_btplot.

% Hint: delete(hObject) closes the figure 
delete(gcf); 

% exit from Matlab when not running the desktop 
if usejava('desktop') 
  % don't exit from Matlab
else
  exit 
end


function varargout = facet_stat_OutputFcn(hObject, eventdata, handles)
% --- Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function getData_Callback(hObject, eventdata, handles)
% --- Executes on button press in getData.
% hObject    handle to getData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

timerange = {get(handles.startTime,'String'); get(handles.endTime,'String')};

[arch_times,arch_data] = getHistoryWfm('FCUDKLYS:MCC1:ONBC10SUMY',timerange);

num_points = length(arch_times);

klys_counts = reshape(sum(arch_data,1), 8,18); % Total counts for each klystron active on Beam Code 10
klys_percent = (klys_counts./num_points).*100 % Percent of time for each klystron active on Beam Code 10

handles.heat_map = plotData(klys_percent, timerange);
klys_counts

guidata(hObject, handles);


function heat_map = plotData(klys_percent, timerange)
% Make new array with zeros for edge cases to plot properly
plot_percent = klys_percent;
plot_percent(:,19) = 0;
plot_percent(9,:) = 0;

% Plot statistics
pos = get(gcf,'Position');
heat_map = figure('Name','Facet Klystron Usage', 'Position', pos+[100, 100, 700, 400]);

surf(plot_percent);
set(gca, 'Color', [0.8, 0.8, 0.8])
title(['FACET Klystron Usage from ', timerange{1}, ' to ', timerange{2}])
xlabel('Sector')
ylabel('Klystron Unit')
%zlabel('Percent active on BC 10 (%)')
set(gca, 'XTick', 1.5:18.5, 'XTickLabel', 2:19);
set(gca, 'YTick', 1.5:8.5, 'YTickLabel', 1:8);
view(0,-90) % Set view to overhead (Z) looking down

% Add colorbar and set range from 0 to 100%
colorbar
caxis([0,100])


function printToLogbook_Callback(hObject, eventdata, handles)
% --- Executes on button press in printToLogbook.
% hObject    handle to printToLogbook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opts.title = 'FACET Klystron Usage Statistics';
opts.author = 'MATLAB';
opts.text = 'Colorbar represents percentage of time active on Beam Code 10';

util_printLog(handles.heat_map, opts)


function startTime_Callback(hObject, eventdata, handles)
% hObject    handle to startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of startTime as text
%        str2double(get(hObject,'String')) returns contents of startTime as a double

str = get(handles.startTime,'String');
if isempty(str)
    str = datenum(get(handles.endTime,'String'))-1;
end

try
    str = datestr(str,'mm/dd/yyyy HH:MM:SS');
catch
    disp('Non-recognizable date input, reverting to default!')
    str = datestr(now-1,'mm/dd/yyyy HH:MM:SS');   
end

if datenum(str) < datenum('09/16/2011 20:40:00')
    disp('Cannot display data from before 09/16/2011 20:40:00, please enter a new date!')
    str = '09/16/2011 20:40:00';  %Creation date of complement waveform PV
end
set(handles.startTime,'String',str);

guidata(hObject,handles);


function endTime_Callback(hObject, eventdata, handles)
% hObject    handle to endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of endTime as text
%        str2double(get(hObject,'String')) returns contents of endTime as a double

str = get(handles.endTime,'String');
if isempty(str)
    str = datenum(get(handles.startTime,'String'))-1;
end

try
    str = datestr(str,'mm/dd/yyyy HH:MM:SS');
catch
    disp('Non-recognizable date input, reverting to default!')
    str = datestr(now-1,'mm/dd/yyyy HH:MM:SS');   
end

if datenum(str) < datenum('09/16/2011 20:40:00')
    disp('Cannot display data from before 09/16/2011 20:40:00, please enter a new date!')
    str = '09/16/2011 20:40:00';  %Creation date of complement waveform PV
end
set(handles.endTime,'String',str);

guidata(hObject,handles);


function calStart_Callback(hObject, eventdata, handles)
% --- Executes on button press in calStart.
set(gcf,'Units','pixels')
pos = get(gcf,'Position');
set(gcf,'Units','characters')
pos = pos + [ 190 80 0 0 ];

date_pick = calendar_pop(now-1,pos);
if ~isempty(date_pick)
   set(handles.startTime,'String',date_pick)
end
startTime_Callback(hObject,eventdata,handles)


function calEnd_Callback(hObject, eventdata, handles)
% --- Executes on button press in calEnd.
set(gcf,'Units','pixels')
pos = get(gcf,'Position');
set(gcf,'Units','characters')
pos = pos + [ 190 80 0 0 ];

date_pick = calendar_pop(now,pos);
if ~isempty(date_pick)
   set(handles.endTime,'String',date_pick)
end
endTime_Callback(hObject,eventdata,handles)


% --- Executes during object creation, after setting all properties.
function startTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function endTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
