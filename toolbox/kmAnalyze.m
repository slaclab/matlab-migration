function varargout = kmAnalyze(varargin)
% KMANALYZE M-file for kmAnalyze.fig
%      KMANALYZE, by itself, creates a new KMANALYZE or raises the existing
%      singleton*.
%
%      H = KMANALYZE returns the handle to a new KMANALYZE or the handle to
%      the existing singleton*.
%
%      KMANALYZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KMANALYZE.M with the given input arguments.
%
%      KMANALYZE('Property','Value',...) creates a new KMANALYZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kmAnalyze_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kmAnalyze_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kmAnalyze

% Last Modified by GUIDE v2.5 15-Sep-2009 17:42:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kmAnalyze_OpeningFcn, ...
                   'gui_OutputFcn',  @kmAnalyze_OutputFcn, ...
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


% --- Executes just before kmAnalyze is made visible.
function kmAnalyze_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kmAnalyze (see VARARGIN)

% Choose default command line output for kmAnalyze
handles.output = hObject;

% Get data from main gui
% Check to see if handle to KM_main gui is passed in
dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'kmMain'));
if (isempty(mainGuiInput)) || (length(varargin) <= mainGuiInput) || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, (and adjust our position?)
    handles.KM_main = varargin{mainGuiInput+1};% this is the handle to the main gui figure

    % Set the initial text (Keep all data current in K_measurement guidata)
    mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
  
    % Position to be relative to parent:
    parentPosition = getpixelposition(handles.KM_main);
    currentPosition = get(hObject, 'Position');  % assumes units are pixels
    % Set x to be to right of and share baseline with main gui
    newX = parentPosition(1) + parentPosition(3) + 5;
    newY = parentPosition(2);
    %newY = parentPosition(2) + (parentPosition(4) - currentPosition(4));
    newW = currentPosition(3);
    newH = currentPosition(4);

    set(hObject, 'Position', [newX, newY, newW, newH]);
end


if dontOpen
    disp('-----------------------------------------------------');
    disp('Improper input arguments. Pass a property value pair')
    disp('whose name is "KM_main" and value is the handle')
    disp('to the KM_main figure, e.g:');
    disp('-----------------------------------------------------');
end

mainHandles.hAnalyze = hObject; % handles to the analyze gui
set(handles.fitPanel,'SelectionChangeFcn',{@fitMethodSelcbk,hObject});
handles.fitMethod = mainHandles.fitMethod; % default
handles.scanCount = 1; % default
handles.scanDisplayNumber=1; % default scan number to display

% Update handles structure
guidata(hObject, handles);
guidata(handles.KM_main,mainHandles);

% UIWAIT makes kmAnalyze wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = kmAnalyze_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PlotKProfile.
function PlotKProfile_Callback(hObject, eventdata, handles)
% hObject    handle to PlotKProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
set(handles.bikePictures,'Visible','off');
set(handles.analysisPlot, 'Visible', 'on');
plot(handles.analysisPlot, [1:33], sin([1:33]/4));
title(handles.analysisPlot,'K profile')
xlabel('Segment Number')
ylabel('K value')


% --- Executes on button press in SaveData.
function SaveData_Callback(hObject, eventdata, handles)
% Saves the energy scan data (bpms, energies)

% copy all main gui handles struture
% mainHandles = guidata(handles.KM_main);

% save to data file
% path_name=([getenv('MATLABDATAFILES') '/undulator/km/K']);
% filename = datestr(now,30);
% filename = [path_name '/K' filename];
% save(filename, 'mainHandles');
% display(['All gui data written to file ' filename]);
% 
% %display(mainHandles);

% Save all the data 
kmSaveData(handles)

% --- Executes on button press in bikePictures.
function bikePictures_Callback(hObject, eventdata, handles)
% Toggle background
saveDir = cd;
cd /home/physics/welch/pics/BikePics
dList = dir; % get struct array of file names
dList(1:2) = []; % rid of . and ..
nfiles = length(dList);
rnum = round(nfiles* rand);
picName = dList(rnum).name;
BG = imread(picName); % this is the array plotting in the background of the button
cd(saveDir);

set(hObject,'CData', BG);


% --- Executes on button press in LoadData.
function LoadData_Callback(hObject, eventdata, handles)
[filename, pathName] = uigetfile('/u1/lcls/matlab/undulator/km/K/*.mat');
load([pathName filename] ) ;
handles.data = mainHandles;
if isfield(mainHandles, 'results')
    kmPlotResults(mainHandles); % look at results
end
if isfield(mainHandles,'scans')
    plotEnergy_Callback(hObject, eventdata, handles)
end

% update slider with new range
if isfield(mainHandles, 'scanCount')
    if (mainHandles.scanCount>1)
        set(handles.hSlider, 'Max',mainHandles.scanCount,'Min',1,...
            'Value', 1, 'SliderStep',...
            [ 1/(mainHandles.scanCount-1) 1/(mainHandles.scanCount-1) ] );
    end
end

guidata(hObject,handles); % update guidata

% --- Executes on button press in plotEnergy.
function plotEnergy_Callback(hObject, eventdata, handles)
% Called Plot Scan on the button

mainHandles = handles.data; %this is the data from the file

refScans = mainHandles.results.Ref.scan;
if isfield(mainHandles,'fitMethod');
    method = mainHandles.fitMethod;
else
    method = 'midpoint';
end
%method = handles.fitMethod;

[Etrim, Ftrim] = kmSlopeTrim(refScans(handles.scanDisplayNumber).correctedEnergyRef, refScans(handles.scanDisplayNumber).Fref);

%[Etrim, Ftrim] = kmSlopeTrim(refScans(1).correctedEnergyRef, refScans(1).Fref);

[GeVedge, Fedge, dFdGeVedge, GeVplot, Fplot] = kmEdgeFind(Etrim,Ftrim, method);
cla(handles.analysisPlot);

plot(refScans(handles.scanDisplayNumber).correctedEnergyRef,refScans(handles.scanDisplayNumber).Fref,'+',...
    GeVplot,Fplot,'-r');
titleString = ['U' num2str(mainHandles.testSegment) ' - U' num2str(mainHandles.refSegment)];
titleString = [titleString ' Edge at ', num2str(GeVedge,7),' GeV'];
title(titleString);


% --- Executes on button press in refitScan.
function refitScan_Callback(hObject, eventdata, handles)
% Refit and replot the scan with current method
mainHandles = guidata(handles.KM_main);


switch mainHandles.fitMethod
    case 'midpoint'
    case'inflection'
    case 'erf'
end

function fitMethodSelcbk(source, eventdata, hObject)
% Set choice of fitting method to use when analyzing the data
handles = guidata(hObject);
mainHandles = guidata(handles.KM_main);
handles.fitMethod = get(eventdata.NewValue,'String');% update method choice
guidata(handles.KM_main, mainHandles); % update the main guidata
handles.fitMethodPanel = mainHandles.fitMethod;% record to local guidata
plotEnergy_Callback(hObject, eventdata, handles); % update the plot
guidata(hObject, handles); % update local guidata


% --- Executes on button press in recalculateK.
function recalculateK_Callback(hObject, eventdata, handles)
% Recalculate and replot Delta K with current choice of fit

% Get the data
mainHandles = handles.data; %this is the data from the file
refScans = mainHandles.results.Ref.scan;
testScans = mainHandles.results.Test.scan;
method = handles.fitMethod;

% Calculate the Ref edge 
for nRef=1:length(refScans)
[Etrim, Ftrim] = kmSlopeTrim(refScans(nRef).correctedEnergyRef, refScans(nRef).Fref);
[edgeGeVRefn(nRef), Fedge, dFdGeVedge, GeVplot, Fplot] = kmEdgeFind(Etrim,Ftrim, method);
end
edgeGeVRef = mean(edgeGeVRefn);


% Calculate the Test edge point array
for nTest =1:length(testScans)
[Etrim, Ftrim] = kmSlopeTrim(testScans(nTest).correctedEnergy, testScans(nTest).F); 
[edgeGeVArray(nTest), Fedge, dFdGeVedge, GeVplot, Fplot] = kmEdgeFind(Etrim,Ftrim, method);
end

% Update the mainHandles structure
mHmod = mainHandles;
mHmod.edgeGeVRef = edgeGeVRef;
mHmod.edgeGeVArray = edgeGeVArray;
mHmod.fitMethod = method;

% Plot results
kmPlotResults(mHmod); 

% --- Executes on slider movement.
function scanSlider_Callback(hObject, eventdata, handles)
% hObject    handle to scanSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.scanDisplayNumber = round(get(hObject,'Value'));
plotEnergy_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function scanSlider_CreateFcn(hObject, eventdata, handles)
% Get the scan number to plot

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
handles.hSlider = hObject; % handle to slider
%set(hObject, 'Max',handles.scanCount,'Min',1);

guidata(hObject, handles);

