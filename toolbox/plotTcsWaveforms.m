function varargout = plotTcsWaveforms(varargin)
% PLOTTCSWAVEFORMS M-file for plotTcsWaveforms.fig
%      PLOTTCSWAVEFORMS, by itself, creates a new PLOTTCSWAVEFORMS or raises the existing
%      singleton*.
%
%      H = PLOTTCSWAVEFORMS returns the handle to a new PLOTTCSWAVEFORMS or the handle to
%      the existing singleton*.
%
%      PLOTTCSWAVEFORMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTTCSWAVEFORMS.M with the given input arguments.
%
%      PLOTTCSWAVEFORMS('Property','Value',...) creates a new PLOTTCSWAVEFORMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotTcsWaveforms_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotTcsWaveforms_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotTcsWaveforms

% Last Modified by GUIDE v2.5 05-Aug-2009 10:30:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotTcsWaveforms_OpeningFcn, ...
                   'gui_OutputFcn',  @plotTcsWaveforms_OutputFcn, ...
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


% --- Executes just before plotTcsWaveforms is made visible.
function plotTcsWaveforms_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotTcsWaveforms (see VARARGIN)

% Choose default command line output for plotTcsWaveforms
handles.output = hObject;
handles.waveformEgu = lcaGet('TORO:DMP1:399:TRPWF.EGU');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotTcsWaveforms wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotTcsWaveforms_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function startTime_Callback(hObject, eventdata, handles)
% hObject    handle to startTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startTime as text
%        str2double(get(hObject,'String')) returns contents of startTime as
%        a double
handles.timeRangeSt = get(hObject,'String');
guidata(hObject, handles);

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
handles.timeRangeSt = [datestr(now-2/24,23) ' ' datestr(now-2/24,13)];
set(hObject,'String',handles.timeRangeSt)
guidata(hObject, handles);

function endTime_Callback(hObject, eventdata, handles)
% hObject    handle to endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.timeRangeEnd = get(hObject,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function endTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.timeRangeEnd = [datestr(now,23) ' ' datestr(now,13)];
set(hObject,'String',handles.timeRangeEnd)
guidata(hObject, handles);


% --- Executes on button press in getData.
function getData_Callback(hObject, eventdata, handles)
% hObject    handle to getData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'String','Working...')
timeRange = {handles.timeRangeSt; handles.timeRangeEnd}
try
   [handles.t1, handles.v1] = history('TORO:DMP1:399:TRPWF',timeRange);  
   [handles.t2, handles.v2] = history('TORO:DMP1:685:TRPWF',timeRange);  
   
   handles.timeString1 = datestr(handles.t1);
   handles.timeString2 = datestr(handles.t2);
catch
    set(handles.timeStamp1,'String','Failed to get data. (See command window)')
    set(hObject,'String','Get Data...')
    lastErr = lasterror;
    disp(lastErr.message)
    return
end
%check if data has same number of waveform for both PVs
if(length(handles.t1) ~= length(handles.t2))
    disp('Warning: Got different number of waveforms')
end
handles.nWaveforms = max(length(handles.t1), length(handles.t2));
[c, handles.intersectT1, handles.intersectT2] = intersect(handles.t1,handles.t2);
if(isempty(c)), errordlg('There are no timestamps in common for all waveforms'), return, end

r = 1:length(handles.v1);
plot(r,handles.v1(r,handles.intersectT1(1)),r,handles.v2(r,handles.intersectT2(1))) 
legend({'TORO:DMP1:399:TRPWF'; 'TORO:DMP1:685:TRPWF'})
set(handles.selectPlot,'Value',1)
set(handles.timeStamp1,'String',(handles.timeString1(handles.intersectT1(1),:)))
set(handles.timeStamp2,'String',(handles.timeString2(handles.intersectT2(1),:)))
set(hObject,'String','Get Data...')
set(handles.slider1,'Value',1,'Min',1,'Max',length(handles.t1))
set(handles.slider1,'SliderStep',[1/(length(handles.t1)-1) 1])
set(handles.slider2,'Value',1,'Min',1,'Max',length(handles.t2))
set(handles.slider2,'SliderStep',[1/(length(handles.t2)-1) 1])

maxTsLength = max(length(handles.t1), length(handles.t2));
set(handles.sliderBoth,'Value',1,'Min',1,'Max', maxTsLength)
set(handles.sliderBoth,'SliderStep',[1/(maxTsLength-1) 1])
handles.sliderOldVal = 1;
guidata(hObject, handles);


% --- Executes on button press in toZoom.
function toZoom_Callback(hObject, eventdata, handles)
% hObject    handle to toZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoomState = findstr('On',get(hObject,'String'));
if(~isempty(zoomState))
    zoom(handles.figure1,'Off')
    set(hObject,'String','Zoom Off')
else
    zoom(handles.figure1,'on')
    set(hObject,'String','Zoom On')
end


% --- Executes on selection change in selectPlot.
function selectPlot_Callback(hObject, eventdata, handles)
% hObject    handle to selectPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns selectPlot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectPlot

plotIt_Now(handles);


% --- Executes during object creation, after setting all properties.
function selectPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', ...
{'Plot All Data (Overlay)'; 'Plot All Data (Diff.)'; 'Plot Last 200 Pts (Diff.)'})


function plotIt_Now(handles)
indx1 = get(handles.slider1,'Value');
indx2 = get(handles.slider2,'Value');
% eCharge = 1.60217646e-19; %Coulumbs 
switch (get(handles.selectPlot,'Value'))
    case 1
        r = 1:length(handles.v1);
        plot(r,handles.v1(r,indx1),r,handles.v2(r,indx2))
        legend({'TORO:DMP1:399:TRPWF'; 'TORO:DMP1:685:TRPWF'},'Location','Best')
    case 2
        plot(handles.v2(:,indx2) - handles.v1(:,indx1))
        legend('TORO 685 - TORO 399','Location', 'Best')
    case 3
        r = (1:200) + length(handles.v1)-200;
        plot(r,handles.v2(r,indx2) - handles.v1(r,indx1))      
        legend('TORO 685 - TORO 399','Location', 'Best')
end   
ylabel(handles.waveformEgu)

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%set(hObject,'SliderStep',[1/(length(handles.t1)-1) 1])
indx = max(1,fix( get(hObject,'Value')));
set(hObject,'Value',indx);
plotIt_Now(handles) 
set(handles.timeStamp1,'String',(handles.timeString1(indx,:)))

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
indx = max(1,fix( get(hObject,'Value')));
set(hObject,'Value',indx);
plotIt_Now(handles) 
set(handles.timeStamp2,'String',(handles.timeString2(indx,:)))


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderBoth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBoth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderDelta =   ceil( get(hObject,'Value') - handles.sliderOldVal);
indx1 = max(1,fix( get(handles.slider1,'Value'))) + sliderDelta;
indx2 = max(1,fix( get(handles.slider2,'Value'))) + sliderDelta;

indx1 = min(max(1,indx1), length(handles.t1));
indx2 = min(max(1,indx2), length(handles.t2));


set(handles.slider1,'Value', indx1)
set(handles.slider2,'Value', indx2)
handles.sliderOldVal = ceil(get(hObject,'Value'));

set(handles.timeStamp1,'String',(handles.timeString1(indx1,:)))
set(handles.timeStamp2,'String',(handles.timeString2(indx2,:)))
guidata(hObject, handles);

plotIt_Now(handles)

% --- Executes during object creation, after setting all properties.
function sliderBoth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBoth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


