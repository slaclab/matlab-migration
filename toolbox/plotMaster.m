
function varargout = plotMaster(varargin)
% PLOTMASTER M-file for plotMaster.fig
%      PLOTMASTER, by itself, creates a new PLOTMASTER or raises the existing
%      singleton*.
%
%      H = PLOTMASTER returns the handle to a new PLOTMASTER or the handle to
%      the existing singleton*.
%
%      PLOTMASTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTMASTER.M with the given input arguments.
%
%      PLOTMASTER('Property','Value',...) creates a new PLOTMASTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotMaster_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotMaster_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotMaster

% Last Modified by GUIDE v2.5 20-Aug-2014 11:11:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotMaster_OpeningFcn, ...
                   'gui_OutputFcn',  @plotMaster_OutputFcn, ...
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


% --- Executes just before plotMaster is made visible.
function plotMaster_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotMaster (see VARARGIN)

% Choose default command line output for plotMaster
handles.output = hObject;

handles.varNames = [];
handles.figureList.h = '0';
handles.timeRange = [now-2/24 now];
handles.varCount = 0;
handles.useAppliance = 1;

[sys, accelerator] = getSystem();
handles.accelerator = lower(accelerator);
handles.applianceOpts = {'Operator','', 'Bin', '60', 'Std', '3', 'OldBin', '60'};
handles.configList.a={ 'varNames'  'timeRange'  'useAppliance'  'varCount'};
handles.configList.b = {'time', 'value', 'statsStr'}; %remove before saving.
handles.isOpi = any(strmatch('lcls-opi', getenv('HOSTNAME')));



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotMaster wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotMaster_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in pvNameListbox.
function pvNameListbox_Callback(hObject, eventdata, handles)
% hObject    handle to pvNameListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pvNameListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pvNameListbox



% --- Executes during object creation, after setting all properties.
function pvNameListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pvNameListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in MedianFilterPushbutton.
function MedianFilterPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MedianFilterPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figV = get(handles.figureControlPopupmenu, 'Value');
figS = get(handles.figureControlPopupmenu, 'String');
fig = figS{figV};
figIndx = strmatch( fig, {handles.figureList.h}); %index in handles of figure in question.
lineIndx = get(handles.lineListbox, 'Value');
for ii = lineIndx
    y = get( handles.figureList(figIndx).singleAxes.pltH(ii), 'YData');
    y = medfilt1(y,10); %TODO better medfilter for multiple filters applications
    y(1) = y(2);
    set(handles.figureList(figIndx).singleAxes.pltH(ii), 'YData', y);
end

%TODO update legend so that stats are correct after medfilt



% --- Executes on button press in IgnoreFlyerPushbutton.
function IgnoreFlyerPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to IgnoreFlyerPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figV = get(handles.figureControlPopupmenu, 'Value');
figS = get(handles.figureControlPopupmenu, 'String');
fig = figS{figV};
figIndx = strmatch(fig, {handles.figureList.h}); %index in handles of figure in question.
lineIndx = get(handles.lineListbox, 'Value');

for ii = lineIndx
    x = get( handles.figureList(figIndx).singleAxes.pltH(ii), 'XData');
    y = get( handles.figureList(figIndx).singleAxes.pltH(ii), 'YData');

    removeIndx = [find(( y > mean(y) + 3 * std(y))), ...
                find(( y < mean(y) - 3 * std(y)))];
    x(removeIndx) = [];
    y(removeIndx) = [];
    set(handles.figureList(figIndx).singleAxes.pltH(ii), 'XData', x , 'YData', y);
   % set(handles.figureList(figIndx).singleAxes.pltH(ii), 'YData', y);
end

%TODO update legend so that stats are correct after ignore flyer.


% --- Executes on button press in normalizeCheckbox.
function normalizeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to normalizeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of normalizeCheckbox


% --- Executes on button press in VisibleCheckbox.
function VisibleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to VisibleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in limitStyleCheckbox.
function limitStyleCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to limitStyleCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in destinationFigurePopupmenu.
function destinationFigurePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to destinationFigurePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function destinationFigurePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destinationFigurePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function markerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to markerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function markerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lineWidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lineWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function lineWidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sendBackPushbutton.
function sendBackPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sendBackPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rmsFilterCheckbox.
function rmsFilterCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to rmsFilterCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rmsFilterCheckbox


% --- Executes on selection change in makerPopupmenu.
function makerPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to makerPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns makerPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from makerPopupmenu


% --- Executes during object creation, after setting all properties.
function makerPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to makerPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in figureControlPopupmenu.
function figureControlPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to figureControlPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns figureControlPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from figureControlPopupmenu
contents = get(hObject,'String');
selectedFigure = contents{get(hObject,'Value')} ;
hIndx = strmatch(selectedFigure, {handles.figureList.h});
set(handles.lineListbox,'String', handles.figureList(hIndx).singleLineStr, 'Value', 1);

% --- Executes during object creation, after setting all properties.
function figureControlPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figureControlPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in xAxisPopupmenu.
function xAxisPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to xAxisPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns xAxisPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xAxisPopupmenu


% --- Executes during object creation, after setting all properties.
function xAxisPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xAxisPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in striptoolTogglebutton.
function striptoolTogglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to striptoolTogglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of striptoolTogglebutton


% --- Executes on button press in physicsLogPushbutton.
function physicsLogPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to physicsLogPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in opsLogPushbutton.
function opsLogPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to opsLogPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in addTxtcheckbox.
function addTxtcheckbox_Callback(hObject, eventdata, handles)


% Hint: get(hObject,'Value') returns toggle state of addTxtcheckbox



function startRelativeEdit_Callback(hObject, eventdata, handles)


% Hints: get(hObject,'String') returns contents of startRelativeEdit as text
%        str2double(get(hObject,'String')) returns contents of startRelativeEdit as a double
%TODO any callback to time controls needs to set getNewData to 1 for
%all.(and  update formulas)

value = get(hObject,'String');
s1 = regexpi(value, '[hmdy]');
if isempty(s1),
    warndlg('Relative string needs to be one of [hmdy] (hours, months, days, years)');
    return
end
deltaT = str2double(value(1:s1-1))
switch upper(value(s1))
    case 'H', timeFactor = 1/24;
    case 'D', timeFactor = 1;
    case 'M', timeFactor = 30; %TODO step in correct months step
    case 'Y', timeFactor = 365; %TODO step in correct year steps
end
handles.timeRange(1) = handles.timeRange(2) + deltaT*timeFactor;
handles = updateTimeRange(hObject,eventdata,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function startRelativeEdit_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startAbsoluteEdit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of startAbsoluteEdit as text
%        str2double(get(hObject,'String')) returns contents of startAbsoluteEdit as a double
set(handles.startRelativeEdit, 'String', '');
value = get(hObject, 'String');
valueNum = datenum(value);
handles.timeRange(1) = valueNum;
updateTimeRange(hObject,eventdata,handles);

% --- Executes during object creation, after setting all properties.

function startAbsoluteEdit_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', datestr(now-2/24,'mm/dd/yyyy HH:MM:SS'));


function endRelativeEdit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of endRelativeEdit as text
%        str2double(get(hObject,'String')) returns contents of endRelativeEdit as a double
%TODO other useful keywords for time.
switch get(handles.endRelativeEdit, 'String')
    case {'now', '->'}
        handles.timeRange(2) = now;
        set(hObject,'String', 'now')
    otherwise
end
updateTimeRange(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function endRelativeEdit_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endAbsoluteEdit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of endAbsoluteEdit as text
%        str2double(get(hObject,'String')) returns contents of endAbsoluteEdit as a double
value = get(hObject, 'String');
endTime = datenum(value);
set(hObject, 'String', datestr(endTime,'mm/dd/yyyy HH:MM:SS'))
handles.timeRange(2) = endTime;
updateTimeRange(hObject,eventdata,handles);


% --- Executes during object creation, after setting all properties.
function endAbsoluteEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', datestr(now,'mm/dd/yyyy HH:MM:SS'));


% --- Executes on slider movement.
function startSlider_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject,'Value');
oldRelativeDeltaT = diff(handles.timeRange);
handles.timeRange(1) = val;
relativeDeltaT = diff(handles.timeRange);
if oldRelativeDeltaT <= 0

    handles.timeRange(2) = handles.timeRange(1) + 23/24;
elseif relativeDeltaT <= 1/24 && oldRelativeDeltaT > 0

    handles.timeRange(2) = handles.timeRange(1) + oldRelativeDeltaT;
end
set(handles.endSlider,'Max', max(now,handles.timeRange(2) +1/24));
updateTimeRange(hObject,eventdata,handles);



% --- Executes during object creation, after setting all properties.
function startSlider_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
tRange = 3*365.25;
set(hObject,{'Min', 'Max', 'Value', 'SliderStep'}, ...
    {now - tRange, now, now-2/24, [1/tRange 7/tRange]})

% --- Executes on slider movement.
function endSlider_Callback(hObject, eventdata, handles)
% hObject    handle to endSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = get(hObject,'Value');
vec=datestr(val);
oldRelativeDeltaT = diff(handles.timeRange);
handles.timeRange(2) = val;
relativeDeltaT = diff(handles.timeRange);

%{
if relativeDeltaT >= 0
    handles.timeRange(2) = handles.timeRange(2)-23/24;

elseif relativeDeltaT < 0
    handles.timeRange(2) = handles.timeRange(2) +23/24;

end
%}


if oldRelativeDeltaT <= 0
    handles.timeRange(1) = handles.timeRange(2)-2/24;

elseif relativeDeltaT <= 1/24 && oldRelativeDeltaT > 0
    %handles.timeRange(1) = handles.timeRange(2) - oldRelativeDeltaT;
    handles.timeRange(1) = handles.timeRange(2) - oldRelativeDeltaT;

end

updateTimeRange(hObject,eventdata,handles);




% --- Executes during object creation, after setting all properties.
function endSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
tRange = 3*365.25;
set(hObject,{'Min', 'Max', 'Value', 'SliderStep'}, ...
    {now - tRange, now, now-1/(24*60*60), [1/tRange 7/tRange]})


function handles = updateTimeRange(hObject, eventdata, handles)
% update all controls that have to do with time.


startTagList = {'startRelativeEdit', 'startAbsoluteEdit', 'startSlider', 'startCalendarButton'};
endTagList = {'endRelativeEdit', 'endAbsoluteEdit', 'endSlider', 'endCalendarButton'};
tagList = {'startRelativeEdit', 'startAbsoluteEdit', 'startSlider', 'startCalendarButton', 'endRelativeEdit', 'endAbsoluteEdit', 'endSlider', 'endCalendarButton'};


caller = get(hObject,'Tag');
value = get(hObject,'String');
isStart = any(strmatch('start',caller));
isEnd = any(strmatch('end',caller));
isEndRelativeEdit = strcmp( 'endRelativeEdit', caller);

relativeDeltaT = diff(handles.timeRange);

for ii = 1:length(tagList)

    if strcmp(tagList{ii}, caller), continue, end %Don't update the caller date

    if isEnd && ~isEndRelativeEdit, set(handles.endRelativeEdit, 'String', '->'), end

    switch tagList{ii}
        case 'endRelativeEdit'

        case 'endAbsoluteEdit',
            set(handles.endAbsoluteEdit,'String', datestr(handles.timeRange(2),'mm/dd/yyyy HH:MM:SS'));

        case 'endSlider'

        case 'startRelativeEdit',
            if relativeDeltaT >365.25, stRelStr = sprintf('-%.1fY', relativeDeltaT/365.25);
            elseif relativeDeltaT > 31, stRelStr = sprintf('-%.1fM',relativeDeltaT/31);
            elseif relativeDeltaT > 1, stRelStr = sprintf('-%.1fD',relativeDeltaT);
            else stRelStr = sprintf('-%.1fH', relativeDeltaT*24);
            end
            set(handles.startRelativeEdit', 'String', stRelStr)
        case 'startAbsoluteEdit'
            set(handles.startAbsoluteEdit,'String', datestr(handles.timeRange(1),'mm/dd/yyyy HH:MM:SS'));

        case 'startSlider'

        case 'startCalendarButton'
            if relativeDeltaT <= 0
                handles.timeRange(1) = handles.timeRange(2)-2/24;
                set(handles.startAbsoluteEdit,'String', datestr(handles.timeRange(1),'mm/dd/yyyy HH:MM:SS'));
                set(handles.startRelativeEdit,'String', '-2.0H');
              end

        case 'endCalendarButton'
            if relativeDeltaT <= 0
                handles.timeRange(2) = handles.timeRange(1)+2/24;
                set(handles.endAbsoluteEdit,'String', datestr(handles.timeRange(2),'mm/dd/yyyy HH:MM:SS'));
                set(handles.startRelativeEdit,'String', '-2.0H');
            end
    end
end

%Sliders can grow if user requires it.
tRange = 3*365.25;
set(handles.startSlider,'Max', now)
set(handles.endSlider,'Max', max(now,handles.timeRange(2) +1/24));
set(handles.startSlider,'Min', min(now-tRange, handles.timeRange(1)-1/24))
%set(handles.endSlider,'Min', tRange);
set(handles.startSlider, 'Value', handles.timeRange(1))
set(handles.endSlider, 'Value', handles.timeRange(2))
[handles.varNames(:).getNewData] = deal(1);
guidata(hObject, handles);


function v = randVec(nPts)
%Don't use just old borring random numbers.

m = magic(nPts);
a = fix(rand*10000); if a>9900, a = a-nPts; end
ii = linspace(a,a+nPts-1);
ii = ii + (fix(rand(1,nPts)*20) + 1);
v = m(ii)/(rand*200);


function handles = updateHistoryValues(handles)
%Updates history for archive PVs and formula calculations.
normalize = get(handles.normalizeCheckbox,'Value');
%Get History if required

for I = 1:length(handles.varNames)%handles.varCount
    if handles.varNames(I).getNewData
        switch handles.varNames(I).dataSource
            case 'Appliance'
                try
                    if isempty(handles.varNames(I).requestStr)

                        [t v requestStr] = getHistory(handles.varNames(I).name, handles.timeRange, handles.applianceOpts{:});
                        handles.varNames(I).requestStr = requestStr;
                    else
                        [t v] = getHistory(handles.varNames(I).requestStr, handles.timeRange);
                    end
                catch
                    set(handles.ticTocText,'String',sprintf('Failed to get history for %s',handles.varNames(I).name{:}));
                    return
                end
            case 'Archive'
                [t v] = aidaGetHistory( [handles.varNames(I).name{:} ':HIST.' handles.accelerator], ...
                    {datestr(handles.timeRange(1),  'mm/dd/yyyy HH:MM:SS'), datestr(handles.timeRange(2), 'mm/dd/yyyy HH:MM:SS')});
                handles.varNames(I).requestStr = handles.varNames(I).name;
            case 'isFormula',  %Fill all other values, so do nothing here.
            case 'isFakeData',
                t = linspace(handles.timeRange(1), handles.timeRange(2));
                v=randVec(100);
                handles.varNames(I).requestStr = handles.varNames(I).name{:}(2:end);

        end %switch dataSource
    else
        if ~handles.varNames(I).isFormula
            t = handles.varNames(I).time{:};
            v = handles.varNames(I).value{:};
        end
    end

    if normalize, %After we normalize, get new data so that removing the normalize check works.
        handles.varNames(I).getNewData = 1;
    else
        handles.varNames(I).getNewData = 0;
    end
    handles.varNames(I).time = {t};
    handles.varNames(I).value ={v};

end
if isempty(handles.varNames(I).requestStr), handles.varNames(I).requestStr = handles.varNames(I).name{:}(2:end); end

% Now calculate formula TODO can a formula reference a formula?

anyFormula = sum([handles.varNames(:).isFormula]);
if anyFormula
    handles = makeAllSameLength(handles, anyFormula);
    for I = 1:handles.varCount
        evalStr = sprintf('%s = handles.varNames(I).value{:};', handles.varNames(I).variable{:}); %A = value
        if I ~= handles.varCount, eval(evalStr); end %skip new formula but calculate all other formulas.
    end
    for I = 1:handles.varCount
        if  handles.varNames(I).isFormula
            formula = sprintf('v %s;', handles.varNames(I).name{:} );
            eval(formula); % v = <input formula>
            if normalize,
                v = normalizeVector(v);
            end
            t = handles.varNames(1).time{:}; %All time vectors are the same since we used makeAllSameLength()
            handles.varNames(I).time = {t};
            handles.varNames(I).value ={v};
            handles.varNames(I).getNewData = 0;
        end

    end
end
if normalize, handles = normalizeVectors(handles); end


function handles = normalizeVectors(handles)
    valOffsetSum = 0;
for I = 1:handles.varCount
    v = handles.varNames(I).value{:};
    valOffset = (max(v) - min(v))/util_meanNan(v);
    valOffsetSum = valOffsetSum + valOffset;
    v = valOffsetSum + v / util_meanNan(v);

    handles.varNames(I).value = {v};
end


function handles = makeAllSameLength(handles, isFormula)
%interpolate to get vectors of the same length
varCount = handles.varCount;
if isFormula,  varCount =  varCount-1; end %Don't interpolate a formula we have not calculated.
for ii = 1:varCount;
    timeVecLength(ii) = length(handles.varNames(ii).time{:});
end
nPts = fix(mean(timeVecLength));
timeInterp =  linspace(handles.timeRange(1), handles.timeRange(2), nPts);
try
for ii = 1:varCount; %TODO only interpolate the ones we need.

    t = handles.varNames(ii).time{:};
    v = handles.varNames(ii).value{:};
    [t m n] = unique(t);
    v = v(m);
    isNan = find(isnan(v));
    t(isNan) = []; v(isNan) = [];
    interpV = interp1(t,v,timeInterp,'nearest'); %#ok<NASGU>
    handles.varNames(ii).value = {interpV};
     handles.varNames(ii).time = {timeInterp};
    %eval( sprintf('%s = interpV;', handles.varNames(ii).variable{:}) ); %A=iterpV

end
catch
    keyboard
end

% --- Executes on button press in

function plotPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plotPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%TODO  Support waveforms.

disp([handles.varNames.name]')
tic
normalize = get(handles.normalizeCheckbox,'Value');
%valOffset = 0;
handles = updateHistoryValues(handles);
figCnt = length(handles.figureList);
lostFigI =  strmatch('0',{handles.figureList.h});
newFigure = get(handles.newFigureCheckbox,'Value');
if any(lostFigI),
    figIndx = lostFigI(1);
    newFigure = 1;
else
    figIndx = figCnt + 1;
end
if newFigure,
    figH = figure;
    handles.figureList(figIndx).h = num2str(figH);
    handles.figureList(figIndx).axesH(1:handles.varCount) = 0.1;
    for jj =1:length( [handles.figureList.h]),
        figListStr(jj) = {handles.figureList(jj).h} ;
    end
    set(handles.figureControlPopupmenu, 'String', figListStr)
    set(handles.figureControlPopupmenu, 'Value', figIndx)
else
    figIndx = get(handles.figureControlPopupmenu,'Value');
    figCtrlStr = get(handles.figureControlPopupmenu,'String');
    figH = str2num(figCtrlStr{figIndx});
end
if get(handles.singleAxesTogglebutton,'Value'),
    handles.figureList(figIndx).isMultiAxes = 0;
else
    handles.figureList(figIndx).isMultiAxes = 1;
end
figure(figH); %Raise or create figH
if handles.isOpi,
    figPos =  [5 1305  1192  516];
else
    figPos = [1600 200 860 420];
end
set(figH,'Position', figPos)
figX = get(handles.xAxisPopupmenu,'Value')
if figX==1,
    xIsTime = 1;
else
    xIsTime = 0;
end
if xIsTime,
    x = [handles.varNames.time];
else
    x = handles.varNames(figX-1).value;
end
y = [handles.varNames.value];
m = [handles.varNames.marker];

%TODO check that x,y are the same length before plotting, if not
%interpolate (nearest for now, to the left when available).

handles = updateStatsStr(handles);
figHandles = num2cell([handles.figureList.h]);
figIndx = strmatch(num2str(figH),figHandles);
if any(figIndx),
    figIndx = figIndx(1);
else
a = 1;
end
dcm_obj = datacursormode(figH);
set(dcm_obj, 'UpdateFcn',@dataCursorShowTime)

if handles.figureList(figIndx).isMultiAxes %Multiple axes
    clf(figH)
    handles.figureList(figIndx).singleAxes = [];
    %Plot it one per .EGU axes TODO pvs with same EGU don't add an axes.
    colorList =  [      0         0    1.0000; 0    0.5000         0; 1.0000         0         0;  0    0.7500    0.7500; ...
        0.7500         0    0.7500; 0.7500    0.7500         0; 0.2500    0.2500    0.2500];
    %TODO add more colors to color list
    colorI = 0;
    for I = 1:handles.varCount
        if 1 %normalize
            if ~ishandle(handles.figureList(figIndx).axesH(I))
               handles.figureList(figIndx).axesH(I) = axes;
            end
            linesLegH(I) = plot(handles.figureList(figIndx).axesH(I), x{I}, y{I}, 'Color',colorList(I,:));
            datetick
            hold on
        end
    end
    axesList = handles.figureList(figIndx).axesH(:);
    legend(linesLegH,[handles.varNames.name],'Location','NorthOutside','Interpreter','none', ...
        'Fontsize', 10)
    axesPos =[.1500 .1182 .7750 .7068];
    yWidth = .05;
    xLimit = xlim();
    xOffset = -yWidth*diff(xLimit)/axesPos(3);
    for ii = 1:I,
        set(axesList(ii),'Position', axesPos);
        axes(axesList(ii));
        datetick(axesList(ii))
        if ii == 1
            set(axesList(ii),'Visible','on',...
                'Color', 'w', 'YColor', 'b')
        else
            num=ii-1;
            set(axesList(ii),'Visible','on', 'Position', axesPos+yWidth.*[-1 0 1 0],...
                'Color', 'none', 'YColor', colorList(ii,:) ,'XLim', xLimit+[num*xOffset 0], 'XTick',[],'XTickLabel',[],'XColor', 'k')
            yWidth = yWidth + .05;
        end
    end
    xlabel(axesList(1), datestr(handles.timeRange))
    n=get(gca,'ytick');
    set(gca,'yticklabel',sprintf('%.5f|',n'));
    %TODO fix zoom for multiple axes
    %TODO fix legend location for multiple axes
    handles.figureList(figIndx).linesLegH = linesLegH;
else %plot in single axes
    clf(figH)
    figH = str2num(handles.figureList(figIndx).h);
    figure(figH)
    %Plot it all in one axes
    pltStr{1} = 'pltH = plot(';
    z=[];
    for ii = 1:handles.varCount
        if xIsTime,
            xIndx = ii;
        else xIndx = 1;
        end %time plots use their own time vector, xIsTime=0 uses x{1} as x axis.
        pltStr{ii+1} = sprintf('x{%i},y{%i},''%s'' ', xIndx,ii,m{ii});
        if ii < handles.varCount,
            pltStr{ii+1} = [pltStr{ii+1}, ', '];
        end
    end
    pltStr{end+1} = ');';
    eval([pltStr{:}])
    n=get(gca,'ytick');
    set(gca,'yticklabel',sprintf('%.5f|',n'));
    xlabel(datestr(handles.timeRange));
    handles.figureList(figIndx).singleAxes.pltH = pltH;
    handles.figureList(figIndx).singleAxes.legH = legend([handles.varNames.name],'Location','NorthOutside','Interpreter', 'none', 'FontSize', 10);
    %TODO better datetick options or pass them to user via GUI?
    if xIsTime, datetick, end
end
%
singleLineStr =  {handles.varNames.requestStr};
set(handles.lineListbox, 'String', singleLineStr)
handles.figureList(figIndx).singleLineStr = singleLineStr;
guidata(hObject, handles);
set(handles.ticTocText,'String', sprintf('%.3f sec.', toc))



% --- Executes on button press in filterByValue.
function filterByValue_Callback(hObject, eventdata, handles)
% hObject    handle to filterByValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp([handles.varNames.name]')
tic
normalize = get(handles.normalizeCheckbox,'Value');
%valOffset = 0;
handles = updateHistoryValues(handles);
figCnt = length(handles.figureList);
lostFigI =  strmatch('0',{handles.figureList.h});
newFigure = get(handles.newFigureCheckbox,'Value');

if any(lostFigI),
    figIndx = lostFigI(1);
    newFigure = 1;
else
    figIndx = figCnt + 1;
end
if newFigure,
    figH = figure;
    handles.figureList(figIndx).h = num2str(figH);
    handles.figureList(figIndx).axesH(1:handles.varCount) = 0.1;
    for jj =1:length( [handles.figureList.h]),
        figListStr(jj) = {handles.figureList(jj).h} ;
    end
    set(handles.figureControlPopupmenu, 'String', figListStr)
    set(handles.figureControlPopupmenu, 'Value', figIndx)
else
    figIndx = get(handles.figureControlPopupmenu,'Value');
    figCtrlStr = get(handles.figureControlPopupmenu,'String');
    figH = str2num(figCtrlStr{figIndx});
end
if get(handles.singleAxesTogglebutton,'Value'),
    handles.figureList(figIndx).isMultiAxes = 0;
else
    handles.figureList(figIndx).isMultiAxes = 1;
end
figure(figH); %Raise or create figH
if handles.isOpi,
    figPos =  [5 1305  1192  516];
else
    figPos = [1600 200 860 420];
end
set(figH,'Position', figPos)
figX = get(handles.xAxisPopupmenu,'Value');
if figX==1,
    xIsTime = 1;
else
    xIsTime = 0;
end
if xIsTime,
    x = [handles.varNames.time];
else
    x = handles.varNames(figX-1).value;
end
y = [handles.varNames.value];
m = [handles.varNames.marker]

%TODO check that x,y are the same length before plotting, if not
%interpolate (nearest for now, to the left when available).

handles = updateStatsStr(handles);
figHandles = num2cell([handles.figureList.h]);
figIndx = strmatch(num2str(figH),figHandles);
if any(figIndx),
    figIndx = figIndx(1);
else
    a = 1;
end
dcm_obj = datacursormode(figH);
set(dcm_obj, 'UpdateFcn',@dataCursorShowTime)

if handles.figureList(figIndx).isMultiAxes %Multiple axes
    clf(figH)
    handles.figureList(figIndx).singleAxes = [];
    %Plot it one per .EGU axes TODO pvs with same EGU don't add an axes.
    colorList =  [      0         0    1.0000; 0    0.5000         0; 1.0000         0         0;  0    0.7500    0.7500; ...
        0.7500         0    0.7500; 0.7500    0.7500         0; 0.2500    0.2500    0.2500];
    %TODO add more colors to color list
    colorI = 0;
    noIndx = get(handles.lineListbox, 'Value'); %Returns which PV is selected
    %z=[]; %Empty array
    for I = 1:handles.varCount
        if 1 %normalize
            if ~ishandle(handles.figureList(figIndx).axesH(I))
               handles.figureList(figIndx).axesH(I) = axes;
            end
            if xIsTime,
                xIndx = I;
            else xIndx = 1;
            end %time plots use their own time vector, xIsTime=0 uses x{1} as x axis.
            if noIndx == I %Checks if selected PV is matched with current loop
                upperLimit = handles.upperLimit; %User defined upper limit value
                lowerLimit = handles.lowerLimit; %User defined lower limit value
                z=y{I}'; %Transpose y array
                g=size(y{I}); %Returns size of y{I} array
                w=x{I}; %Time values stored in w array
                for ii=1:g %Iterates through each value in g
                    if z(ii) > upperLimit || z(ii) < lowerLimit  %If the value of z(iii), will change value of z(ii) to NaN (will no longer plot)
                        z(ii)=NaN;
                    end
                end
                linesLegH(I)=plot(w,z, 'Color',colorList(I,:));
            else
                w=x{I};
                z=y{I}';
                linesLegH(I)=plot(w,z, 'Color',colorList(I,:));

            end
            hold on
        end
    end
    if xIsTime, datetick, end
    legend(linesLegH,[handles.varNames.name],'Location','NorthOutside','Interpreter','none', ...
        'Fontsize', 10)
    axesList = handles.figureList(figIndx).axesH(:);
    axesPos =[.1500 .1182 .7750 .7068];
    yWidth = .05;
    xLimit = xlim();
    xOffset = -yWidth*diff(xLimit)/axesPos(3);
    for iii = 1:I,
        set(axesList(iii),'Position', axesPos);
        axes(axesList(iii));
        datetick(axesList(iii))
        if iii == 1
            set(axesList(iii),'Visible','on',...
                'Color', 'w', 'YColor', 'b')
        else
            num=iii-1;
            set(axesList(iii),'Visible','on', 'Position', axesPos+yWidth.*[-1 0 1 0],...
                'Color', 'none', 'YColor', colorList(iii,:) ,'XLim', xLimit+[num*xOffset 0], 'XTick',[],'XTickLabel',[],'XColor', 'k')
            yWidth = yWidth + .05;
        end
    end
    xlabel(axesList(1), datestr(handles.timeRange))
    n=get(gca,'ytick');
    set(gca,'yticklabel',sprintf('%.5f|',n'));
else %plot in single axes

    clf(figH)
    colorList =  [      0         0    1.0000; 0    0.5000         0; 1.0000         0         0;  0    0.7500    0.7500; ...
        0.7500         0    0.7500; 0.7500    0.7500         0; 0.2500    0.2500    0.2500];
    figH = str2num(handles.figureList(figIndx).h);
    figure(figH)
    %Plot it all in one axes
    pltStr{1} = 'pltH = plot(';
    for ii = 1:handles.varCount
        if xIsTime,
            xIndx = ii;
        else xIndx = 1;
        end %time plots use their own time vector, xIsTime=0 uses x{1} as x axis.
        upperLimit = handles.upperLimit; %User defined upper limit value
        lowerLimit = handles.lowerLimit; %User defined lower limit value
        if upperLimit <= lowerLimit
            h = msgbox('Check that the upper limit is larger than the lower limit', 'Error', 'error');
        else

            z=y{ii}'; %Transpose y array
            g=size(y{ii}); %Returns size of y{I} array
            w=x{ii}; %Time values stored in w array
            for iii=1:g %Iterates through each value in g
                    if z(iii) > upperLimit || z(iii) < lowerLimit  %If the value of z(iii), will change value of z(ii) to NaN (will no longer plot)
                        z(iii)=NaN;
                    end
            end
            plot(w,z, 'Color',colorList(ii,:))
            hold on
            end
    end
    xlabel(datestr(handles.timeRange));
    n=get(gca,'ytick');
    set(gca,'yticklabel',sprintf('%.5f|',n'));
    handles.figureList(figIndx).singleAxes.legH = legend([handles.varNames.name],'Location','NorthOutside','Interpreter', 'none', 'FontSize', 10);
    if xIsTime, datetick, end
end
singleLineStr =  {handles.varNames.requestStr};
set(handles.lineListbox, 'String', singleLineStr)
handles.figureList(figIndx).singleLineStr = singleLineStr;
guidata(hObject, handles);
set(handles.ticTocText,'String', sprintf('%.3f sec.', toc))


function enterPvEdit_Callback(hObject, eventdata, handles)

%TODO: remove pv clean up needed so that removing a variable does not break
%setup.
%TODO: Make calls to getHistory.m as different threads.
%TODO: Gather stattitics on most popular time searches to make as default.
%(To PV).
varPV = {get(hObject, 'String')};
if isempty(varPV), return, end
I = length(handles.varNames) + 1;
%handles.varNames(I).name = {varPV};
handles = appInit(hObject, handles,varPV );
handles = updateHistoryValues(handles);
plot([handles.varNames(I).time{:}], [handles.varNames(I).value{:}])
set(handles.quickAxes, 'Visible', 'Off'), axis tight
%get EGU
tic
%if handles.varNames(I).isFormula, egu = getFormulaEgu(handles); else egu =  lcaGetSmart( strcat(varPV,'.EGU')); end
switch handles.varNames(I).dataSource
    case { 'Appliance'  'Archive'}, egu =  lcaGetSmart( strcat(varPV,'.EGU'));
    case 'isFormula', egu = getFormulaEgu(handles);
    case 'isFakeData', egu = {'apples', 'oranges', 'tomatoes','grapes'}; egu= egu( mod(fix(rand*10),4)+1);
end
tToc = toc;
if ~iscell(egu), if isnan(egu), egu = {'NAN'}; end; end
if tToc > 2,
    str = sprintf('Took %.3f seconds to get .EGU for %s\n',tToc, varPV{:}) ;
    set(handles.ticTocText,'String', str);
end

handles.varNames(I).egu =egu;
handles.varNames(I).marker = {'-'};
handles = updateStatsStr(handles);
%set(handles.pvNameListbox,'String', [handles.varNames.statsStr]);
set(handles.pvNameListbox,'String', [handles.varNames.name]);
set(handles.xAxisPopupmenu,'String', ['Time',  [handles.varNames.name]]);
guidata(hObject, handles);

set(hObject,'String','')


function handles = appInit(hObject, handles, varPV)
if nargin < 3, isLoad = 1; varPV = handles.varNames.name; else isLoad = 0; end
 handles.varCount = length(handles.varNames) +1;
 handles.varCount
%for I =  handles.varCount:handles.varCount+length(varPV)
    I =  handles.varCount
    isFakeData = 0; isFormula = 0;
    switch varPV{1}(1)
        case '#', dataSource = 'isFakeData'; isFakeData = 1;
        case '=', dataSource = 'isFormula'; isFormula = 1;
        otherwise,  dataSource = 'Appliance';
    end
    handles.varNames(I).name = varPV;
    handles.varNames(I).dataSource = dataSource;
    handles.varNames(I).variable = {char(64+I)};
    handles.varNames(I).isFormula = isFormula;
    handles.varNames(I).isFakeData = isFakeData;
    handles.varNames(I).requestStr = ''; %TODO request string gets asigned here ??
    handles.varNames(I).isMedianFilter = 0;
    if isFormula,
        handles.varNames(I).getNewData = 0;
    else
        handles.varNames(I).getNewData = 1;
    end


function egu = getFormulaEgu(handles)
%TODO use handles.egu and formula to calculate formula egu.
egu = {':('};


function handles = updateStatsStr(handles)
   % A_letter VAL .EGU mean rms rms/mean min max delta
for I = 1:length(handles.varNames)
    varTag = handles.varNames(I).variable{:};
    varPV = handles.varNames(I).requestStr;
    pvName = handles.varNames(I).name;
    value = handles.varNames(I).value{:};
    egu = handles.varNames(I).egu;
    s = [util_meanNan(value) util_stdNan(value) min(value) max(value)];
    if handles.varNames(I).isFormula || handles.varNames(I).isFakeData
        stats = [calcFormulaNow(handles), s(1), s(2), s(2)/s(1), s(3), s(4), s(4)-s(3)];
    else
        stats = [lcaGetSmart(pvName), s(1), s(2), s(2)/s(1), s(3), s(4), s(4)-s(3)];
    end
    statsStr{:}= sprintf('%s) %s %.2f %s %.2f  %.2f %.2f%%, %.2f - %.2f = %.2f', ...
        varTag, varPV, stats(1), egu{:}, stats(2:end) ) ;
end
handles.varNames(I).statsStr = statsStr;


function v = calcFormulaNow(handles)
v = 0.0; %TODO calc formula now from handles.

% --- Executes during object creation, after setting all properties.
function enterPvEdit_CreateFcn(hObject, eventdata, handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in newFigureCheckbox.
function newFigureCheckbox_Callback(hObject, eventdata, handles)


% --- Executes on selection change in lineListbox.
function lineListbox_Callback(hObject, eventdata, handles)

figureList = findobj('Type','Figure');
figureList(figureList==handles.figure1) = [];
if isempty(figureList), return, end
figureList = cellfun(@num2str, num2cell(fix(figureList)), 'UniformOutput' , false);
knownFigures = {handles.figureList.h};
figureList = sort(intersect(figureList, knownFigures));

selectedFigureI = get(handles.figureControlPopupmenu, 'Value');
selectedFigure = get(handles.figureControlPopupmenu, 'String');
selectedFigure = selectedFigure(selectedFigureI);
figI = strmatch(selectedFigure,figureList);
if any(figI)
set(handles.figureControlPopupmenu,'String', figureList, 'Value', figI);
else
    figureToUse = length(figureList);
    set(handles.figureControlPopupmenu,'String', {num2str(sort(figureList))}, 'Value', figureToUse);
    figI = find(figureToUse==[handles.figureList.h]);
    set(hObject, 'String', handles.figureList(figI).singleLineStr)
end


% --- Executes during object creation, after setting all properties.
function lineListbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in singleAxesTogglebutton.
function singleAxesTogglebutton_Callback(hObject, eventdata, handles)

buttonState = get(hObject,'Value');
if buttonState == get(hObject,'Max')
 for jj = 1:length(handles.figureList), handles.figureList(jj).singleAxes.yesNo = 1; end %yes
 set(hObject,'String', 'Single Axes');
elseif buttonState == get(hObject,'Min')
 for jj = 1:length(handles.figureList), handles.figureList(jj).singleAxes.yesNo = 0; end %yes
   set(hObject,'String', 'Multiple Axes');
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function singleAxesTogglebutton_CreateFcn(hObject, eventdata, handles)


set(hObject,'Value',1)


% --- Executes during object creation, after setting all properties.
function quickAxes_CreateFcn(hObject, eventdata, handles)


% --- Executes on selection change in visiblePopupmenu.
function visiblePopupmenu_Callback(hObject, eventdata, handles)
figCtrlVal = get(handles.figureControlPopupmenu, 'Value');
yesIndx = get(handles.lineListbox, 'Value');

if handles.figureList(figCtrlVal).isMultiAxes
    allIndx = 1:length(get(handles.lineListbox, 'String'));
    axesList = [handles.figureList(figCtrlVal).axesH];
    linesHlist = [handles.figureList(figCtrlVal).linesLegH];
    oldYesI = strmatch('on', get(linesHlist, 'Visible'));
    set(axesList,'Visible','off')
    yesIndx = union(oldYesI, yesIndx);
    noIndx = setdiff(allIndx,yesIndx);
    if any(yesIndx),
        set(axesList(yesIndx(end)), 'Visible', 'on');
        axesList(yesIndx(end)) = [];
    end

    for jj = axesList, axes(jj); end
    set(handles.figureList(figCtrlVal).linesLegH, 'Visible', 'off')
    set(handles.figureList(figCtrlVal).linesLegH(yesIndx), 'Visible', 'on')
    set(handles.figureList(figCtrlVal).linesLegH(noIndx), 'Visible', 'off')

else
    legIndx = get(handles.figureList(figCtrlVal).singleAxes.legH ,'UserData');
    set(legIndx.handles(yesIndx),'Visible','on')
end

figure(handles.figure1)
set(hObject,'Value',1);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function visiblePopupmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on pvNameListbox and no controls selected.
function pvNameListbox_KeyPressFcn(hObject, eventdata, handles)

%TODO any key press will remove selected items from list.

% --- Executes on button press in removePushbutton.
function removePushbutton_Callback(hObject, eventdata, handles)

plotList = get(handles.pvNameListbox, 'String');
removeIndx = get(handles.pvNameListbox, 'Value');

plotList(removeIndx) = [];
if isempty(plotList), plotList = ' '; end
set(handles.pvNameListbox,'Value', 1);
set(handles.pvNameListbox, 'String', plotList);

handles.varNames(removeIndx) = [];
handles.varCount = length(handles.varNames);
guidata(hObject, handles);


% --- Executes on selection change in appliancePopupmenu.
function appliancePopupmenu_Callback(hObject, eventdata, handles)

v = get(hObject,'Value');
bin = handles.applianceOpts{4};
std = handles.applianceOpts{6};
if isempty(std), std = '3'; end
oldBin = handles.applianceOpts{8};
if v == 1, visible = 'off'; handles.applianceOpts{4} = '0';
else visible  = 'on'; handles.applianceOpts{4} = oldBin;
end
helpStr = {'Raw Data'  ['First Sample of each ' oldBin  ' sec. bin']  ...
    'Mean =  <X>'  'std = sqrt(<X^2> - <X>^2)' ...
    'RMS = sqrt(<X^2>)' 'jitter = RMS/Mean' ['Ignore Flyers in ' bin 'sec. bin with sigma ' std] };
operatorStr =   {'', 'firstSample', 'mean', 'sigma', 'rms', 'jitter',  'ignoreflyers'};
set(hObject, 'TooltipString', helpStr{v} )


handles.applianceOpts{2} = operatorStr{v};
if strcmp(handles.applianceOpts{2},  'ignoreflyers')
    binStr = sprintf('%s,%s', oldBin, std);
else
    binStr = sprintf('%s', oldBin);
end

set(handles.binEdit,'Visible',visible, 'String', binStr)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function appliancePopupmenu_CreateFcn(hObject, eventdata, handles)

%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function binEdit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of binEdit as text
%        str2double(get(hObject,'String')) returns contents of binEdit as a double
val = get(hObject,'String');
[bin std] = strtok(val, ',');
if any(std), std= std(2:end); end
handles.applianceOpts = {'Operator',handles.applianceOpts{2}, 'Bin', bin, 'Std', std, 'oldBin', bin };
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function binEdit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in notVisiblePushbutton.
function notVisiblePushbutton_Callback(hObject, eventdata, handles)
figCtrlVal = get(handles.figureControlPopupmenu, 'Value');
noIndx = get(handles.lineListbox, 'Value');

if handles.figureList(figCtrlVal).isMultiAxes
    axesList = [handles.figureList(figCtrlVal).axesH];
     linesHlist = [handles.figureList(figCtrlVal).linesLegH];
    yesIndx = strmatch('on', get(linesHlist, 'Visible'));
    %yesIndx = strmatch('on', get(axesList, 'Visible'));
    set(axesList,'Visible','off')


    if any(yesIndx),
        set(axesList(yesIndx(end)), 'Visible', 'on');
        axesList(yesIndx(end)) = [];
    end

    for jj = axesList, axes(jj); end
    set(handles.figureList(figCtrlVal).linesLegH, 'Visible', 'off')
    set(handles.figureList(figCtrlVal).linesLegH(yesIndx), 'Visible', 'on')
    set(handles.figureList(figCtrlVal).linesLegH(noIndx), 'Visible', 'off')

else
    legIndx = get(handles.figureList(figCtrlVal).singleAxes.legH ,'UserData');
    set(legIndx.handles(noIndx),'Visible','off')
end

figure(handles.figure1)
set(hObject,'Value',1);
guidata(hObject, handles);



function appSave(hObject, handles)
if isempty(handles.varNames), return, end
tempStruct = handles.varNames;
%tempStruct = rmfield(tempStruct, handles.configList.b);
[tempStruct.getNewData] = deal(1);
handles.varNames = tempStruct;
for taga=handles.configList.a
    config.(taga{:}) = handles.(taga{:});
end
util_configSave('plotMaster',config,1);



function data = appRemote(hObject, configName, doSave)

% Find (or launch) application.
[hObject,handles]=util_appFind('corrPlot_gui');

% Load config file.
handles.process.saved=1;
handles=appLoad(hObject,handles,configName);

% Start acquisition.
handles=acquireStart(hObject,handles);
data=handles.data;
handles.process.saved=1;
guidata(hObject,handles);

% Save if requested.
if nargin > 2 && doSave
    dataSave(hObject,handles,0);
end



function handles = appLoad(hObject, handles, config)

if nargin < 3, config=1;end
if ~isstruct(config)
    config=util_configLoad('plotMaster',config);
end
if isempty(config), return, end
for taga=handles.configList.a
        handles.(taga{:}) = config.(taga{:});
end


% --- Executes on button press in loadPushbutton.
function loadPushbutton_Callback(hObject, eventdata, handles)
handles = appLoad(hObject, handles);
for I =  1:length(handles.varNames)
    statsStr(I,:) = {sprintf('%s) %s', handles.varNames(I).variable{:} , handles.varNames(I).requestStr)};
end
set(handles.pvNameListbox,'String', statsStr);
%handles = appInit(hObject, handles);
%handles = updateHistoryValues(handles);
guidata(hObject,handles);


% --- Executes on button press in savePushbutton.
function savePushbutton_Callback(hObject, eventdata, handles)
appSave(hObject, handles)


% --- Executes on button press in startCalendarButton.
function startCalendarButton_Callback(hObject, eventdata, handles)
% hObject    handle to startCalendarButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

position = getpixelposition(plotMaster());
x = position(1) + 720;
y = position(2) + 587;
position = [x , y];
value = calendar_pop(now, position);
valueNum = datenum(value);
handles.timeRange(1) = valueNum;
updateTimeRange(hObject,eventdata,handles);



% --- Executes on button press in endCalendarButton.
function endCalendarButton_Callback(hObject, eventdata, handles)
% hObject    handle to endCalendarButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

position = getpixelposition(plotMaster());
x = position(1) + 720;
y = position(2) + 535;
position = [x , y];
value = calendar_pop(now, position);
valueNum = datenum(value);
handles.timeRange(2) = valueNum;
updateTimeRange(hObject,eventdata,handles);

function upperLimit_Callback(hObject, eventdata, handles)
% hObject    handle to upperLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperLimit as text
%        str2double(get(hObject,'String')) returns contents of upperLimit as a double
handles.upperLimit = str2double(get(hObject,'String'));
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function upperLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowerLimit_Callback(hObject, eventdata, handles)
% hObject    handle to lowerLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerLimit as text
%        str2double(get(hObject,'String')) returns contents of lowerLimit as a double

handles.lowerLimit = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lowerLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
