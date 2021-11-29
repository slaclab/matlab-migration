function varargout = gdet_realtime_statistics(varargin)
% GDET_REALTIME_STATISTICS M-file for gdet_realtime_statistics.fig
%      GDET_REALTIME_STATISTICS, by itself, creates a new GDET_REALTIME_STATISTICS or raises the existing
%      singleton*.
%
%      H = GDET_REALTIME_STATISTICS returns the handle to a new GDET_REALTIME_STATISTICS or the handle to
%      the existing singleton*.
%
%      GDET_REALTIME_STATISTICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GDET_REALTIME_STATISTICS.M with the given input arguments.
%
%      GDET_REALTIME_STATISTICS('Property','Value',...) creates a new GDET_REALTIME_STATISTICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gdet_realtime_statistics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gdet_realtime_statistics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gdet_realtime_statistics

% Last Modified by GUIDE v2.5 28-Mar-2013 13:27:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gdet_realtime_statistics_OpeningFcn, ...
                   'gui_OutputFcn',  @gdet_realtime_statistics_OutputFcn, ...
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

% --- Executes just before gdet_realtime_statistics is made visible.
function gdet_realtime_statistics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gdet_realtime_statistics (see VARARGIN)

% Choose default command line output for gdet_realtime_statistics
handles.output = hObject;

disp(get(hObject, 'Renderer'));
set(hObject,'RendererMode','manual');
set(hObject,'Renderer','Zbuffer');
disp(get(hObject, 'Renderer'));

% Update handles structure
guidata(hObject, handles);

global graphicsRate, graphicsRate = .01; % Delay between graphics loops
global programStarted, programStarted = 0;
global graphicsTimer;
graphicsTimer = timer('TimerFcn', @(h, ev) graphicsTimerCallback(h, ev, handles),'ExecutionMode','fixedSpacing','Period',graphicsRate);
global GasDetPV;
GasDetPV = 'GDET:FEE1:241:ENRCHSTBR_DSP';
%Lets get all multithreaded up in this
maxNumCompThreads('automatic')

global burstMode, burstMode = 0; %if the machine is in burst mode, this variable gets set to 1.

%reposition the start button
%Get the size info for the plot
set(handles.gasDetPlotAxes,'Units','pixels');
figureRect = get(handles.figure1, 'Position');
figureWidth = figureRect(3);
figureHeight = figureRect(4);
set(handles.startStopButton, 'Position',[figureWidth - 130, 30, 100, 40]);
%%set(handles.gasDetPlotAxes,'Position',[175,200,700,250]);

%axis(handles.gasDetPlotAxes,[-90,0,0,4]);
initializeGasDetPlots(handles);

%resize the plot
xlabel(handles.gasDetPlotAxes,'Time (s)');
ylabel(handles.histogramAxes,'X-Ray Energy (mJ)');
xlabel(handles.histogramAxes,'Counts');
histogramTightInset = get(handles.histogramAxes, 'TightInset');
gasDetTightInset = get(handles.gasDetPlotAxes, 'TightInset');
set(handles.histogramAxes, 'Position', [histogramTightInset(1), 100 + gasDetTightInset(2), figureWidth * .15, figureHeight - 100 - 15 - gasDetTightInset(2)]);
histogramRect = get(handles.histogramAxes, 'Position');

set(handles.gasDetPlotAxes, 'Position', [histogramRect(3) + histogramTightInset(1) + gasDetTightInset(1) + 10, 100 + gasDetTightInset(2), (figureWidth * .85) - (histogramTightInset(1) + gasDetTightInset(1) + 30), figureHeight - 100 - 15 - gasDetTightInset(2)]);
set(handles.averageTimeEdit,'Enable','on');


% UIWAIT makes gdet_realtime_statistics wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gdet_realtime_statistics_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function graphicsTimerCallback(hObject, eventdata, handleToGuiFigure)
    %tic
    global GasDetPV;
    global gasDetData;
    global gasDetPlot;
    global histogramPlot;
    global gasDetAvg;
    global t;
    global Fs;
    global burstMode;
    
    averagingTime = str2double(get(handleToGuiFigure.averageTimeEdit,'String'));
    if (averagingTime<0||averagingTime>(2800/Fs))
        averagingTime = 0;
    end
    
    
    
    try
        lcaNewMonitorWait(GasDetPV);
        gasDetData = lcaGet(GasDetPV);
    catch ex
        disp('Error waiting for new GDET data:')
        disp(ex.message)
        return
    end
    if (get(handleToGuiFigure.filterZeroesCheckbox,'Value')>0 && ~burstMode)
        %%Filter out times where gas det is zero
        rejectionThreshold = str2double(get(handleToGuiFigure.rejectionThresholdEdit,'String'));
        filteredT = t(gasDetData>rejectionThreshold);
        %%Filter out zero values
        gasDetData = gasDetData(gasDetData>rejectionThreshold);
    else
        filteredT = t;
    end
    
    gdetCount = numel(gasDetData);
    sampleStart = gdetCount - round(averagingTime*Fs);
    gasDetMean = mean(gasDetData(sampleStart:gdetCount));
    circshift(gasDetAvg,1);
    gasDetAvg(gdetCount) = gasDetMean;
    set(gasDetPlot,'xdata',filteredT,'ydata',gasDetData);
    gasDetStdDev = std(gasDetData(sampleStart:gdetCount));
    set(handleToGuiFigure.gasDetMeanText,'String',num2str(gasDetMean,3));
    set(handleToGuiFigure.gasDetStdDevText,'String',[num2str(gasDetStdDev,3),...
        ' (',num2str(gasDetStdDev/gasDetMean*100,3),'%)']);
    
    histRect = get(handleToGuiFigure.histogramAxes, 'Position');
    gasylimits = get(handleToGuiFigure.gasDetPlotAxes,'ylim');
    %binsize = (max(gasDetData) - min(gasDetData)) / histRect(4);
    binsize = (gasylimits(2) - gasylimits(1)) / (histRect(4)-1);
    %bins = [min(gasDetData):binsize:max(gasDetData)];
    bins = [gasylimits(1):binsize:gasylimits(2)];
    [n, xout] = histc(gasDetData, bins);
    set(histogramPlot,'ydata',n,'xdata',bins);
    histylimits = get (handleToGuiFigure.histogramAxes,'ylim');
    if all(gasylimits ~= histylimits)
        ylim(handleToGuiFigure.histogramAxes, gasylimits);
    end
    %toc
   


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global graphicsTimer;
stop(graphicsTimer);
delete(timerfind); %Clean up
fprintf('All done, timer object deleted\n');
delete(hObject);



function averageTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to averageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of averageTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of averageTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function averageTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to averageTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PVNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to PVNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PVNameEdit as text
%        str2double(get(hObject,'String')) returns contents of PVNameEdit as a double


% --- Executes during object creation, after setting all properties.
function PVNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PVNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startStopButton.
function startStopButton_Callback(hObject, eventdata, handles)
% hObject    handle to startStopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global graphicsTimer
global programStarted
if (programStarted == 0)
    start(graphicsTimer);
    programStarted = 1;
    set(handles.startStopButton,'BackgroundColor',[1,0,0],'String','Stop');
    initializeGasDetPlots(handles);
else
    stop(graphicsTimer);
    programStarted = 0;
    set(handles.startStopButton,'BackgroundColor',[0,1,0],'String','Start');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figureRect = get(handles.figure1, 'Position');
figureWidth = figureRect(3);
figureHeight = figureRect(4);

%resize the plot
histogramTightInset = get(handles.histogramAxes, 'TightInset');
gasDetTightInset = get(handles.gasDetPlotAxes, 'TightInset');
set(handles.histogramAxes, 'Position', [histogramTightInset(1), 100 + gasDetTightInset(2), figureWidth * .15, figureHeight - 100 - 15 - gasDetTightInset(2)]);
histogramRect = get(handles.histogramAxes, 'Position');

set(handles.gasDetPlotAxes, 'Position', [histogramRect(3) + histogramTightInset(1) + gasDetTightInset(1) + 10, 100 + gasDetTightInset(2), (figureWidth * .85) - (histogramTightInset(1) + gasDetTightInset(1) + 30), figureHeight - 100 - 15 - gasDetTightInset(2)]);
%set(handles.gasDetPlotAxes, 'OuterPosition', [150, 100, figureWidth - 150, figureHeight - 100 - 15]);

%reposition the start button
set(handles.startStopButton, 'Position',[figureWidth - 130, 30, 100, 40]);


% --- Executes on button press in filterZeroesCheckbox.
function filterZeroesCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to filterZeroesCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global burstMode;
global GasDetPV;
try
    lcaClear(GasDetPV);
catch
end
burstMode = 0;
GasDetPV = 'GDET:FEE1:241:ENRCHSTBR_DSP';
% Hint: get(hObject,'Value') returns toggle state of filterZeroesCheckbox
if(get(hObject,'Value')>0)
    burstModeStatus = lcaGet('IOC:BSY0:MP01:REQBYKIKBRST');
    if(strcmp(burstModeStatus,'Yes'))
        set(handles.rejectionThresholdText,'String','Using Burst EDef 12 to filter pulses.');

        burstMode = 1;
        GasDetPV = 'GDET:FEE1:241:ENRCHST12';
    else
        set(handles.rejectionThresholdText,'String','Rejection Threshold (mJ):');
        set(handles.rejectionThresholdEdit,'Visible','on');
    end
    set(handles.rejectionThresholdText,'Visible','on');
else
    set(handles.rejectionThresholdEdit,'Visible','off');
    set(handles.rejectionThresholdText,'Visible','off');
end
initializeGasDetPlots(handles);



function rejectionThresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rejectionThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rejectionThresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of rejectionThresholdEdit as a double


% --- Executes during object creation, after setting all properties.
function rejectionThresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rejectionThresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function initializeGasDetPlots(handles)
global graphicsTimer;
global programStarted;
stop(graphicsTimer);
%Get the size info for the plot
set(handles.gasDetPlotAxes,'Units','pixels');
figureRect = get(handles.figure1, 'Position');
figureWidth = figureRect(3);
figureHeight = figureRect(4);

%resize the plot
xlabel(handles.gasDetPlotAxes,'Time (s)');
ylabel(handles.histogramAxes,'X-Ray Energy (mJ)');
xlabel(handles.histogramAxes,'Counts');
histogramTightInset = get(handles.histogramAxes, 'TightInset');
gasDetTightInset = get(handles.gasDetPlotAxes, 'TightInset');
set(handles.histogramAxes, 'Position', [histogramTightInset(1), 100 + gasDetTightInset(2), figureWidth * .15, figureHeight - 100 - 15 - gasDetTightInset(2)]);
histogramRect = get(handles.histogramAxes, 'Position');

set(handles.gasDetPlotAxes, 'Position', [histogramRect(3) + histogramTightInset(1) + gasDetTightInset(1) + 10, 100 + gasDetTightInset(2), (figureWidth * .85) - (histogramTightInset(1) + gasDetTightInset(1) + 30), figureHeight - 100 - 15 - gasDetTightInset(2)]);
global Fs;
global GasDetPV;
global burstMode;
if burstMode
   Fs = lcaGet('EVNT:SYS0:1:LCLSBURSRATE');
else
   Fs = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
end

T = 1/Fs;
L = 2800; %gas detector history has 2800 points.
global t;
t = (-(L-1):0)*T; %Time vector
global gasDetData;
lcaSetMonitor(GasDetPV,2800,'double');
gasDetData = lcaGetSmart(GasDetPV);
global gasDetAvg;
gasDetAvg = zeros(1,2800);
global gasDetPlot;
gasDetPlot = plot(handles.gasDetPlotAxes, t,gasDetData);
filteredGasDetData = gasDetData(gasDetData>0.01);
ylimMax = ceil(mean(filteredGasDetData*2));
if(ylimMax<1 || isnan(ylimMax))
  ylimMax = 1;
end
ylim(handles.gasDetPlotAxes,[0,ylimMax]);
xlim(handles.gasDetPlotAxes,[t(1),t(2800)]);

binsize = (max(gasDetData) - min(gasDetData)) / histogramRect(4);
bins = [min(gasDetData):binsize:max(gasDetData)];
[n, xout] = histc(gasDetData, bins);
global histogramPlot;
histogramPlot = barh(handles.histogramAxes, bins, n);
if(programStarted)
    start(graphicsTimer)
end
