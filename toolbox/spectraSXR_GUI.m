function varargout = spectraSXR_GUI(varargin)
% SPECTRASXR_GUI M-file for spectraSXR_GUI.fig
%      SPECTRASXR_GUI, by itself, creates a new SPECTRASXR_GUI or raises the existing
%      singleton*.
%
%      H = SPECTRASXR_GUI returns the handle to a new SPECTRASXR_GUI or the handle to
%      the existing singleton*.
%
%      SPECTRASXR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTRASXR_GUI.M with the given input arguments.
%
%      SPECTRASXR_GUI('Property','Value',...) creates a new SPECTRASXR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spectraSXR_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spectraSXR_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spectraSXR_GUI

% Last Modified by GUIDE v2.5 23-Mar-2012 14:23:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spectraSXR_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @spectraSXR_GUI_OutputFcn, ...
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


% --- Executes just before spectraSXR_GUI is made visible.
function spectraSXR_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spectraSXR_GUI (see VARARGIN)

% Choose default command line output for spectraSXR_GUI
handles.output = hObject;

% Intializations
handles.PVlist = {'SXR:EXS:HISTP' 'XPP:OPAL1K:1:LiveImage:HPrj'};
handles.nameList = {'SXR' 'XPP'};
set(handles.sourceSel_pmu,'String',handles.nameList);
handles.PVsingleShot = 'SXR:EXS:HISTP';
handles.PV1secondAve = 'SXR:EXS:HIST'; % Not used
set(handles.sourceSel_pmu,'Value',2); % XPP default
handles.PVsingleShot = handles.PVlist{get(handles.sourceSel_pmu,'Value')}; % set detector
handles.calibrations = [ -.0619, -0.185];% SXR, XPP  sign not certain, Xpp normal resolution
handles.calibrations = [ -.0619, -0.0326];% SXR, XPP  sign not certain, Xpp high resolution for Projection data
handles.cal = handles.calibrations(get(handles.sourceSel_pmu,'Value')); 

handles.numberToAverage =1; 
set(handles.numberToAverageBox,'String',num2str(handles.numberToAverage) );
handles.waitTime=.1; % wait time for collecting averages
handles.averageSpectrum=0;
handles.smoothFactor = 0;
handles.peakWidthSliderValue=.20; % default minimum spike width
handles.xGathered=0; %number of plots that are gathered
handles.gather=0;
handles.plotGathered=0;
handles.displayElectronSpectrum = 1;
handles.zeroBaseline = 1;
handles.displayFWHM = 1;
handles.ElossFWHM = 0;
handles.photonFWHM = 0;

handles.jitterCorrection=0; % shift spectrum for constant centroid

set(handles.calEditBox,'string',handles.cal);
handles.peakHeightSliderValue = .1; % range 0 to 1
handles.displayCentroid = 0; % don't display
handles.eLossNoise = 500; % noise floor for eLoss scan
handles.spectrumNoise = 10000; % noise floor for spectrum scan
handles.displayEdge = 0; % don't display edge
handles.displayPeak = 0;
handles.nGathered = 0; % number of spectra  for simultaneous plotting
handles.gatherPlot = 0; % don't gather
handles.displayAverage = 1; %  always display average
handles.spectraSelector = [handles.selectSpectrumText,...
    handles.selectSpectrumSlider, handles.selectSpectrumCountText];
% Get a shot to start
%singleShotButton_Callback(hObject, eventdata, handles);
handles.xAxisScale = 'absolute'; 
handles.displaySpikes = 0; % don't display spikes
handles.invertSpectrum = 0; % don't invert the spectrum
handles.fitGaussian = 0 ; % don't fit a gaussian
handles.dataSetNumber = 1; % keep track of data sets, 1 set per average spectra
handles.selectSpectrumNumber = 1; % default

% Data selection slider initialization
set(handles.selectSpectrumSlider,'Min', 1,'Max', 2,...
    'Value',1,...
    'SliderStep',1 *[1 1], ...
    'Visible', 'off');
    %'SliderStep',(1/(length(fL)-1) )*[1 1], ...
    
set(handles.selectShotSlider,'Min', 1,'Max', 2,...
    'Value',1,...
    'SliderStep',1 *[1 1], ...
    'Visible', 'off');
    %'SliderStep',(1/(length(fL)-1) )*[1 1], ...

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spectraSXR_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spectraSXR_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in singleShotButton.
function handles = singleShotButton_Callback(hObject, eventdata, handles)
% Get a new single shot scan. Analyse and display on plot.

% No longer in use

guidata(hObject, handles);

% --- Executes on button press in takeAverageButton.
function takeAverageButton_Callback(hObject, eventdata, handles)
% Take a bunch of shots and save as Average

% % Turn off free run if it is on.
% set(handles.freeRunToggle,'Value',get(handles.freeRunToggle,'Min') ) ;
% set(handles.freeRunToggle, 'String','Free run');

% Get machine conditions
% [handles.spectrumRaw, handles.specTS] = lcaGet(handles.PVsingleShot);
[handles.delta, handles.eLossFluxRaw, handles.ts_eLoss] = dumpEnergySpectrum();
handles.beamEnergy = lcaGet('BEND:DMP1:400:BDES');
handles.BC2peakCurrentSetpoint = lcaGet('SIOC:SYS0:ML00:AO044');
handles.BC1peakCurrentSetpoint = lcaGet('SIOC:SYS0:ML00:AO016');
handles.taper = segmentTranslate(); % present taper
handles.photonEnergy = photonEnergyeV();
handles.vernier = lcaGet('SIOC:SYS0:ML00:AO289'); % present vernier setting

% Take shots
shotTotal=0;
shotTotalElectron=0;
set (handles.takeAverageButton, 'String', 'Reading...');

% Get one shot
[shot, handles.specTS] = lcaGet(handles.PVsingleShot);
[delta, eFlux, ts] = dumpEnergySpectrum();
shotTotal = shot;
shotTotalElectron = eFlux;
handles.shotNumber = 1; % initialize

% Update sliders
if (handles.dataSetNumber > 1)
set(handles.selectSpectrumSlider,'Max', handles.dataSetNumber,...
    'Value',handles.dataSetNumber,...
    'SliderStep',1/(handles.dataSetNumber-1) *[1 1], ...
    'Visible', 'off');
set(handles.selectSpectrumCountText, 'Visible', 'off',...
    'String', num2str(handles.dataSetNumber,2) );
end

% Store shot in dataSet structure array
handles.RawDataSet(handles.dataSetNumber).shot = shot;
handles.RawDataSet(handles.dataSetNumber).ts = ts;
handles.RawDataSet(handles.dataSetNumber).eFlux = eFlux;
handles.RawDataSet(handles.selectSpectrumNumber).photonEnergy = photonEnergyeV();

% Get more shots for averaging
if (handles.numberToAverage > 1)
    handles.shotNumber = 2;
    for q=2:handles.numberToAverage
        [shot, handles.specTS] = lcaGet(handles.PVsingleShot);
        %[delta, eFlux, ts] = dumpEnergySpectrum(); % Comment this out for
        %faster averages on spectrum
        handles.electronTS = ts;

        % Append individual shots for post processing or slider selection
        handles.RawDataSet(handles.dataSetNumber).shot =...
            [handles.RawDataSet(handles.dataSetNumber).shot ; shot];
        handles.RawDataSet(handles.dataSetNumber).eFlux=...
            [handles.RawDataSet(handles.dataSetNumber).eFlux ; eFlux];

        % Update slider for shots
        if (handles.shotNumber > 1)
            set(handles.selectShotSlider,'Max', handles.shotNumber,...
                'Value',handles.shotNumber,...
                'SliderStep',1/(handles.shotNumber-1) *[1 1], ...
                'Visible', 'off');
            set(handles.selectShotCountText, 'Visible', 'off',...
                'String', num2str(handles.shotNumber,2) );
        end

        % Add data shots to total
        shotTotal = shotTotal + shot;
        shotTotalElectron = shotTotalElectron + eFlux;
        handles.shotNumber = handles.shotNumber+1;
        pause(handles.waitTime);
        set (handles.takeAverageButton, 'String', num2str(q));
    end
end

% Calculate averages
handles.spectrumRaw = shotTotal/handles.numberToAverage;
handles.eLossFluxRaw = shotTotalElectron/handles.numberToAverage;

% Save averages in handles and dataSet structures (don't save if Free run)
if ~get(handles.freeRunToggle, 'Value')
    handles.RawDataSet(handles.dataSetNumber).spectraAverage = handles.spectrumRaw;
    handles.RawDataSet(handles.dataSetNumber).eFluxAverage = handles.eLossFluxRaw;
end

% Send data for processing
handles = dataProcess(handles); % smooth and subtract, etc
set (handles.takeAverageButton, 'String', 'Take Shots');

% Increment data set number
if ~get(handles.freeRunToggle, 'Value')
    handles.dataSetNumber = handles.dataSetNumber + 1;
end

% Update guidata
guidata(hObject, handles);

function numberToAverageBox_Callback(hObject, eventdata, handles)
% hObject    handle to numberToAverageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberToAverageBox as text
%        str2double(get(hObject,'String')) returns contents of numberToAverageBox as a double
handles.numberToAverage = str2num(get(hObject,'String'));
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function numberToAverageBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberToAverageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = shotAnalyse(handles)
% Update shot analysis. Display new results. 

% spectralData is an array of pixel values - need to convert to eV in plot
% routine
spectralData = handles.spectrum;

% Invert spectrum if requested
if handles.invertSpectrum
    spectralData = -spectralData;
end
fxn = spectralData/sum(spectralData); % normalized

% RMS
x = 1:length(fxn);
handles.meanPhoton = sum( x.* fxn ); % relative to SXR settings, not absolute
handles.rms = sqrt( sum(x.*x.*fxn) - handles.meanPhoton^2);
set (handles.rmsValueText, 'String', num2str(handles.rms*(abs(handles.cal)),3));

% FWHM
handles.photonFWHM = fwhmGeneral(x, fxn);
if isnan(handles.photonFWHM)
    handles.photonFWHM = max(x) - min(x);
end
set(handles.fwhmValueText,'String', num2str(-1*handles.photonFWHM*handles.cal, 3));

% Number of spikes
try % if no spikes avoid error
    [handles.spikeValues, handles.spikeLocs] =...
        findpeaks(spectralData, 'minpeakdistance',floor(100*handles.peakWidthSliderValue),...
        'minpeakheight', (max(spectralData) - min(spectralData))*handles.peakHeightSliderValue );
    handles.numberOfSpikes = length(handles.spikeValues);
catch
    handles.numberOfSpikes = 0;
    handles.spikeValues = 0;
    handles.spikeLocs = 1;
end
set(handles.numberOfSpikesValueText, 'String',num2str(handles.numberOfSpikes) );

% Total spectral power, [cts^2 * pixel]
handles.totalSpectralPower = handles.cal^2*sum(spectralData.*spectralData)/length(spectralData);
set(handles.totalSpectralPowerValueText,'String', num2str(handles.totalSpectralPower,'%7.2e'));

% Photon energy
centerPixel = floor(length(x)/2);
set(handles.photonEnergyValueText, 'String', num2str((handles.meanPhoton-centerPixel)*handles.cal,'%7.1f'));

% Total counts
handles.totalCounts = sum(spectralData);
set(handles.totalCountsValueText, 'String',num2str(handles.totalCounts,'%9.0f') );

% Plot the result
handles = shotPlot(handles);

function handles = shotPlot( handles)
% Plot photon spectrum and energy energy distribution

% Choose spectra and plot in eV deviation
y = handles.spectrum; 
x = 1:length(y);
x = x - floor(length(x)/2); x = x*handles.cal;

% Flip plot if requested
if handles.invertSpectrum
    y = -y;
end

% Choose absolute or relative coordinates
xAxisLabel = 'eV'; % default is absolute
if strcmp(handles.xAxisScale, 'relative')  % plot against relative energy
    x = 1e3*x/handles.photonEnergy;
    xAxisLabel =  '\Delta \omega/\omega [0.1%]';
end

% Display spikes
spikeLocs = (handles.spikeLocs-floor(length(x)/2)) *handles.cal;

% Plot spectrum
if handles.displaySpikes
    h = plot(handles.spectrumAxis, x,y,... % display only spectrometer data
        spikeLocs, handles.spikeValues,'r+'); % h is handle is to plotted objects
else % don't display spikes
    h = plot(handles.spectrumAxis, x,y);
end
xlabel(handles.spectrumAxis,xAxisLabel);
ylabel(handles.spectrumAxis, 'Counts');
% shotDate = datestr(epics2matlabTime(handles.specTS));2/16/12
shotDate = datestr(lca2matlabTime(handles.specTS));%2/16/12 
title(handles.spectrumAxis, ['    '  num2str(handles.photonEnergy, '%7.1f') 'eV, ' shotDate]);

% Display centroid
if handles.displayCentroid
    %hold(handles.spectrumAxis);
    handles.centroid = centroidCalc(x,y,handles.spectrumAxis);
    %hold(handles.spectrumAxis,'off')
end

% Display FWHM
if handles.displayFWHM
    fwhmGeneral(x,y,handles.spectrumAxis);
end

% Display edge
if handles.displayEdge
    hold(handles.spectrumAxis);
    handles.spectralEdge = edgeCalc(x,y,handles.spectrumAxis);
    hold(handles.spectrumAxis,'off')  
end

% Display peaks
if handles.displayPeak
    [handles.spectralPeakLocation handles.spectralPeakValue] = peakCalc(x,y,handles.spectrumAxis);
end

% Fit Gaussian?
if handles.fitGaussian
    gaussCalc(x,y,handles.spectrumAxis)
else
    % clean up?
end

% Energy Spectrum Plotting...

% Display electron energy spectrum
y = handles.eLossFlux;
x = handles.delta*1000*handles.beamEnergy; % MeV

% Decide if relative or absolute energy loss to display
if strcmp(handles.xAxisScale,'relative')
    x = handles.delta*1000;
    xAxisLabel='Relative electron energy deviation [0.1%]';
else
    xAxisLabel = 'Electron energy deviation [MeV]';
end
    
hElectron = plot(handles.altSpectrumAxis,x,y);
xlabel(handles.altSpectrumAxis, xAxisLabel);
ylabel(handles.altSpectrumAxis,'Counts');
title(handles.altSpectrumAxis,['Electron energy spectrum @' num2str(handles.beamEnergy,4) 'GeV'] );

% Display centroid
if handles.displayCentroid
    hold(handles.altSpectrumAxis);
    handles.ElossCentroid = centroidCalc(x,y,handles.altSpectrumAxis);
    hold(handles.altSpectrumAxis,'off')
end

% Display FWHM
handles.ElossFWHM =  fwhmGeneral(x,y,handles.altSpectrumAxis);

% Display edge?
if handles.displayEdge
    hold(handles.altSpectrumAxis,'on');
    handles.eLossEdge = edgeCalc(x,y,...
        handles.altSpectrumAxis);
    hold(handles.altSpectrumAxis,'off')  
end
% Display peak?
if handles.displayPeak
    handles.spectralPeakLocation = peakCalc(x,y,...
        handles.altSpectrumAxis);
end

% Gather plot?
if handles.gather
    handles.gather = 0;
    lineColors = 'rgbcmk';
    nextColor = circshift(lineColors', handles.nGathered);
    set(h,'color', nextColor(1));
    set(hElectron ,'color', nextColor(1));
    copyobj(h, handles.gatherAxisPhoton);
    copyobj(hElectron, handles.gatherAxisElectron);
end

% Plot Gathered plots only if requested
if handles.plotGathered
    cla;
    hold on
    nplots = length(handles.xGatheredPhoton);
    lineColors = 'rgbcmk';
    for iplot = 1:nplots
        color = circshift(lineColors',-iplot);
        plot(handles.xGatheredPhoton{iplot}, handles.yGatheredPhoton{iplot}, ['-' color(1)]);
    end
    handles.plotGathered = 0;
end

% Update soft pvs
try
lcaPut('SIOC:SYS0:ML00:AO680',handles.ElossFWHM/(2.36*handles.beamEnergy)); % for correlation plots
lcaPut('SIOC:SYS0:ML00:AO681', handles.numberOfSpikes);
lcaPut('SIOC:SYS0:ML00:AO682', handles.photonFWHM*(abs(handles.cal)));
lcaPut('SIOC:SYS0:ML00:AO683', handles.rms*(abs(handles.cal)));
catch
    display(handles.ElossFWHM/(2.36*handles.beamEnergy));
    display(handles.numberOfSpikes);
end



% --- Executes on slider movement.
function smoothingSlider_Callback(hObject, eventdata, handles)
% update smoothing factor and text

handles.smoothFactor = get(hObject,'Value');
guidata(hObject, handles);
set(handles.smoothValueText,'String', num2str(100*handles.smoothFactor,2));
dataProcess( handles); 


% --- Executes during object creation, after setting all properties.
function smoothingSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothingSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in subtractAverageBox.
function subtractAverageBox_Callback(hObject, eventdata, handles)
% hObject    handle to subtractAverageBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of subtractAverageBox
smoothingSlider_Callback(handles.smoothingSlider, eventdata, handles);

% --- Executes on button press in displayPeakMarksBox.
function displayPeakMarksBox_Callback(hObject, eventdata, handles)
% hObject    handle to displayPeakMarksBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayPeakMarksBox


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in gatherPlotButton.
function gatherPlotButton_Callback(hObject, eventdata, handles)
% Adds current single shot plot to a collection that is plotted
% together
handles.gather  = 1;
handles.nGathered = handles.nGathered + 1;
if ~isfield(handles,'gatherFigurePhoton') % create one if not there
    handles.gatherFigurePhoton = figure;
    handles.figpos = get(handles.gatherFigurePhoton,'Position');
end
if  ~isfield(handles, 'gatherFigureElectron') % create one if not there
    handles.gatherFigureElectron = figure;
    set(handles.gatherFigureElectron,'Position',...
        handles.figpos + [10 -(100+handles.figpos(4)) 0 0]);
end
figure(handles.gatherFigurePhoton)
handles.gatherAxisPhoton = gca;
figure(handles.gatherFigureElectron)
handles.gatherAxisElectron = gca;
dataProcess( handles);
handles.gather = 0;
guidata(hObject,handles);


% --- Executes on button press in plotGatheredButton.
function plotGatheredButton_Callback(hObject, eventdata, handles)
% Plots the gathered plots

handles.plotGathered  = 1;
dataProcess( handles);
guidata(hObject,handles); 

function handles = dataProcess(handles)
% Subtract average and smooth data before analyzing and plotting
spectralData = handles.spectrumRaw;
eLossFlux = handles.eLossFluxRaw;
delta = handles.delta;

% Subtract average spectrum
if get(handles.subtractAverageBox,'Value')
    spectralData = handles.spectrumRaw - handles.averageSpectrum;
end

% Smooth the spectrum only
[x, spectralData] = scanSmooth(1:length(spectralData), spectralData, 100*handles.smoothFactor);

% Zero the baseline, both spectrum and eLoss flux
if handles.zeroBaseline
    noise = handles.spectrumNoise;
    dataNoise = std(spectralData);
    if dataNoise < handles.spectrumNoise % to avoid zero length data sets if noise is wrong
        noise = 0.1*std(spectralData);
    end
    spectralData =spectralData-min(spectralData) - noise;
    spectralData ( spectralData<0 ) = 0;
    eLossFlux = eLossFlux - min(eLossFlux) - handles.eLossNoise;
    eLossFlux( eLossFlux<0) = 0;
end

% Shift data to approximately center on centroid
centroid= centroidCalc(1:length(spectralData), spectralData);
if handles.jitterCorrection
    shiftsize = floor( 1+ length(spectralData)/2 - centroid);
    spectralData =circshift(spectralData, [1 shiftsize]);
end
 
% Send to analysis and plotting
handles.spectrum = spectralData;
handles.eLossFlux = eLossFlux;
handles.delta = delta;
handles.centroid = centroid;
handles = shotAnalyse(handles);


%guidata(handles.figure1, handles)


% --- Executes on button press in displayAverageBox.
function displayAverageBox_Callback(hObject, eventdata, handles)
if (get(hObject,'Value') == get(hObject,'Max') )
    handles.displayAverage = 1;
else
    handles.displayAverage = 0;
end
guidata(hObject, handles);
dataProcess( handles);

% --- Executes on button press in displaySingleBox.
function displaySingleBox_Callback(hObject, eventdata, handles)
% hObject    handle to displaySingleBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displaySingleBox


% --- Executes on slider movement.
function peakWidthSlider_Callback(hObject, eventdata, handles)
% hObject    handle to peakWidthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.peakWidthSliderValue = get(hObject,'Value');
guidata(hObject, handles);
set(handles.peakWidthValueText,'String', num2str(100*handles.peakWidthSliderValue,2));
handles = dataProcess( handles); 


% --- Executes during object creation, after setting all properties.
function peakWidthSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakWidthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in elogSaveButton.
function elogSaveButton_Callback(hObject, eventdata, handles)
% Make figure suitable for elog

elogFigure = figure;
set(elogFigure, 'units','characters');
positionSave = get(handles.spectrumAxis,'Position');
set(handles.spectrumAxis,'Position', [12 5 positionSave(3:4) ]);
set(elogFigure,'Position',[1 1 90 33]);
% copyobj(handles.altSpectrumAxis,elogFigure);
copyobj(handles.spectrumAxis,elogFigure);
set(handles.spectrumAxis,'Position', positionSave);
% copyobj(handles.resultsPanel,elogFigure);
% copyobj(handles.plotControlPanel,elogFigure);
% copyobj(handles.acquireDataPanel,elogFigure);

%Send to elog
util_printLog(elogFigure);
%util_printLog(handles.output);
%util_printLog(handles.figure1);
spectralDataSave(handles);

% Save all the data 
function spectralDataSave(handles)
%
% Save all guidata to file

header = 'SXR';
name = [num2str(photonEnergyeV, '%5.0f') 'eV'];
ts = now;
[fileName, pathName] = util_dataSave(handles, header, name, ts); % saved as structure "data"
display(['All gui data written to file ' fileName pathName]);


% --- Executes on button press in electronSpectrumBox.
function electronSpectrumBox_Callback(hObject, eventdata, handles)
% hObject    handle to electronSpectrumBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of electronSpectrumBox
handles.displayElectronSpectrum = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in zeroBaslineBox.
function zeroBaslineBox_Callback(hObject, eventdata, handles)
% hObject    handle to zeroBaslineBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zeroBaslineBox
handles.zeroBaseline = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in fwhmBox.
function fwhmBox_Callback(hObject, eventdata, handles)
% hObject    handle to fwhmBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fwhmBox

handles.displayFWHM = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in freeRunToggle.
function freeRunToggle_Callback(hObject, eventdata, handles)
% hObject    handle to freeRunToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_state = get(hObject,'Value');
while (button_state == get(hObject,'Max'))
    handles = guidata(hObject); % update changes to checkboxes 
    takeAverageButton_Callback(hObject, eventdata, handles)
    set(hObject, 'String','Running...');
    button_state = get(hObject,'Value');
    pause(1);
    drawnow;
    set(handles.figure1,'CurrentAxes',handles.spectrumAxis);
end
set(hObject, 'String','Free run');


% --- Executes on button press in jitterCorrectionBox.
function jitterCorrectionBox_Callback(hObject, eventdata, handles)
% hObject    handle to jitterCorrectionBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.jitterCorrection = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% Load data from saved file into guidata for analysis fig.

%[filename, pathName] = uigetfile('/u1/lcls/matlab/data/2010/2010-09/2010-09-14/SXR/*.mat');
%[filename, pathName] = uigetfile('/u1/lcls/matlab/data/2012/2012-01/2012-01-07/SXR/*.mat');
[filename, pathName] = uigetfile('/u1/lcls/matlab/data/2012/2012-03/2012-03-20/SXR/*.mat');
if ~ischar(filename)
    return
end
load([pathName filename] ) % load saved structure called "data"

% Clean up data
data = dataCleanUp(data);

% Extract relavent data
handlesData = dataExtract(data, handles); 

% Process old data with current settings
handles.dataFilename = filename;% for labeling
handles.spectrumRaw = handlesData.spectrumRaw;
handles.eLossFluxRaw = handlesData.eLossFluxRaw;
handles.delta = handlesData.delta;
handles.specTS = handlesData.specTS;
handles.photonEnergy = handlesData.photonEnergy;
handles.beamEnergy = handlesData.beamEnergy;
handles.RawDataSet = handlesData.RawDataSet;


handles = dataProcess( handles);

% Turn off the spectrum slider if it is on
set(handles. spectraSelector, 'Visible', 'off')
guidata(hObject, handles);



function calEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to calEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calEditBox as text
%        str2double(get(hObject,'String')) returns contents of calEditBox as a double
handles.cal = str2num(get(hObject,'String'));
handles = dataProcess( handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function calEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% Set the minimum peak height for peakfinder
handles.peakHeightSliderValue = get(hObject,'Value');
guidata(hObject, handles);
set(handles.peakHeightValueText,'String', [num2str(100*handles.peakHeightSliderValue,2) ' %']);
dataProcess( handles); 

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in plotExportButton.
function plotExportButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotExportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Make figure most suitable for elog
exportFigure = figure;
figPos = get(exportFigure,'Position');% axis position is way off default figure, need to fix
%figUnits = get(exportFigure,'Unit');
figPos(4) = figPos(4)*1.8;
set(exportFigure,'Position', figPos);
new_handle = copyobj([handles.spectrumAxis, handles.altSpectrumAxis],exportFigure); % copy spectrum Axis to elogFigure
set(new_handle(1),'Units', 'pixels', 'Position',[69 60 0.8*figPos(3) 0.35*figPos(4)]);
set(new_handle(2),'Units', 'pixels', 'Position',[69 0.55*figPos(4) 0.8*figPos(3) 0.35*figPos(4)]);
%spectralDataSave(handles);

% --- Executes on button press in centroidCheckBox.
function centroidCheckBox_Callback(hObject, eventdata, handles)
handles.displayCentroid = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in displayEdgeCheckbox.
function displayEdgeCheckbox_Callback(hObject, eventdata, handles)
handles.displayEdge = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in displayPeakBox.
function displayPeakBox_Callback(hObject, eventdata, handles)
handles.displayPeak = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in loadBatchButton.
function loadBatchButton_Callback(hObject, eventdata, handles)
% Load data from all files in a directory. Analyzes them with current
% settings. Save results in file batchData in current directory.

dirName = uigetdir('/u1/lcls/matlab/data/2010/2010-09/2010-09-14/SXR');
if ~ischar(dirName)
    return
end
dirlist = ls('-t', dirName);
fileList = textscan(dirlist, '%s'); %cell array of filenames
fL = fileList{1};
fL = flipud(fL); % put in ascending chronological order

if isfield(handles, 'batch') % clear current batch data
    handles = rmfield(handles, 'batch');
end

% Extract the data from each file, process it and save relavent data in
% batch  stucture.
for sNum=1:length(fL)
    filename=fL{sNum};
    
    % load the saved guidata structure "data"
    load([dirName '/' filename] ) 
    
    % clean up data
    data = dataCleanUp(data);

    % Extract relavent data (not object handles etc.)
    handlesData = dataExtract(data, handles);

    % Gather batch data
    handles.batch(sNum).filename = fL{sNum};
    handles.batch(sNum).spectrumRaw = handlesData.spectrumRaw; 
    handles.batch(sNum).eLossFluxRaw = handlesData.eLossFluxRaw;
    handles.batch(sNum).delta = handlesData.delta;

    handles.batch(sNum).BC1peakCurrentSetpoint = handlesData.BC1peakCurrentSetpoint;
    handles.batch(sNum).BC2peakCurrentSetpoint = handlesData.BC2peakCurrentSetpoint;
    handles.batch(sNum).vernier = handlesData.vernier;
    handles.batch(sNum).specTS = handlesData.specTS;
    handles.batch(sNum).photonEnergy = handlesData.photonEnergy;
    handles.batch(sNum).beamEnergy = handlesData.beamEnergy;

    % Process average data with current settings
    % turn on bells and whistles
    handles.displayPeak = 1;
    handles.displayEdge = 1;
    handles.displayFWHM = 1;
    handles.displayCentroid = 1;
    handles.spectrumRaw = handles.batch(sNum).spectrumRaw; 
    handles.eLossFluxRaw = handles.batch(sNum).eLossFluxRaw;
    handles.delta = handles.batch(sNum).delta;
    handles.specTS = handles.batch(sNum).specTS;
    handles.photonEnergy = handles.batch(sNum).photonEnergy;
    handles.beamEnergy = handlesData.beamEnergy;
    handles = dataProcess( handles); 
    
    % Update the batch values for calculated quantities
    handles.batch(sNum).spectralEdge = handles.spectralEdge;
    handles.batch(sNum).centroid = handles.centroid;
    handles.batch(sNum).photonFWHM = handles.photonFWHM;
    handles.batch(sNum).spectralPeakLocation = handles.spectralPeakLocation;
    handles.batch(sNum).spectalPeakVal = handles.spectralPeakValue;
    handles.batch(sNum).eLossEdge = handles.eLossEdge;
    handles.batch(sNum).ElossCentroid = handles.ElossCentroid;
    handles.batch(sNum).ElossFWHM = handles.ElossFWHM;

end

% Save extracted data to file in current directory
batch = handles.batch;
save 'batchData' batch;

% Activate slider selection
set(handles.selectSpectrumSlider,'Min', 1,'Max', length(fL),...
    'Value',1,...
    'SliderStep',(1/(length(fL)-1) )*[1 1], ...
    'Visible', 'on');
set(handles.selectSpectrumText, 'Visible', 'on');
set(handles.selectSpectrumCountText, 'Visible', 'on');
handles.selectSpectrumCount = 1;
selectSpectrumSlider_Callback(handles.selectSpectrumSlider, eventdata, handles)

guidata(hObject, handles);

% --- Executes on button press in clearGatheredButton.
function clearGatheredButton_Callback(hObject, eventdata, handles)
cla(handles.gatherAxisPhoton);
cla(handles.gatherAxisElectron);
handles.nGathered = 0;
guidata(hObject,handles); 

function handles = dataExtract(data, handles)
% extract relavent data from saved files to evaluate
handles.spectrumRaw = data.spectrumRaw;
handles.averageSpectrum = data.averageSpectrum;
handles.eLossFluxRaw = data.eLossFluxRaw;
handles.delta = data.delta;
handles.photonEnergy = data.photonEnergy;
handles.specTS = data.specTS;
handles.beamEnergy = data.beamEnergy;
handles.BC2peakCurrentSetpoint = data.BC2peakCurrentSetpoint;
handles.BC1peakCurrentSetpoint = data.BC1peakCurrentSetpoint;
handles.vernier = data.vernier;


% --- Executes on slider movement.
function selectSpectrumSlider_Callback(hObject, eventdata, handles)
% Choose which data set to look at and display average

handles.selectSpectrumNumber = round(get(hObject,'Value'));
set(handles.selectSpectrumCountText,'String', num2str(handles.selectSpectrumNumber,2));

% Reset selected shot slider
handles.selectShotNumber= 1;


% Commented text is for Batch Processing
% handles.spectrumRaw = handles.batch(handles.selectSpectrumNumber).spectrumRaw;
% handles.eLossFluxRaw = handles.batch(handles.selectSpectrumNumber).eLossFluxRaw;
% handles.specTS = handles.batch(handles.selectSpectrumNumber).specTS;
% handles.photonEnergy = handles.batch(handles.selectSpectrumNumber).photonEnergy;

handles.spectrumRaw = handles.RawDataSet(handles.selectSpectrumNumber).spectraAverage;
handles.eLossFluxRaw = handles.RawDataSet(handles.selectSpectrumNumber).eFluxAverage;
handles.specTS = handles.RawDataSet(handles.selectSpectrumNumber).ts;
handles.photonEnergy = handles.RawDataSet(handles.selectSpectrumNumber).photonEnergy;


dataProcess( handles); % send data for processing and plotting

% --- Executes during object creation, after setting all properties.
function selectSpectrumSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectSpectrumSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function cleanData = dataCleanUp(data)
% clean up data files, especially older version before processing

cleanData = data;

if isfield(data,'averageSpectrum') % for older files which had separate average and one-shot spectra
    if data.averageSpectrum == 0;
        cleanData.spectrumRaw = data.spectrumRaw; % use the single shot
    else
        cleanData.spectrumRaw = data.averageSpectrum; % use the average
    end
    cleanData.averageSpectrum = cleanData.spectrumRaw; 
end
if isfield(data,'eLossRel')
    cleanData.delta =  -data.eLossRel;
end
if ~isfield(data,'vernier')
    cleanData.vernier = 0; % for older files
end


% --- Executes on button press in relativeAbsoluteButton.
function relativeAbsoluteButton_Callback(hObject, eventdata, handles)
% toggle display relative or absolute energy deviation

if get(hObject,'Value') % if 1 plot against absolute energy loss
    handles.xAxisScale = 'absolute';
else  % plot against relative energy
    handles.xAxisScale = 'relative';
end
handles = dataProcess( handles); 
guidata(hObject,handles)


% --- Executes on button press in displaySpikesCheckbox.
function displaySpikesCheckbox_Callback(hObject, eventdata, handles)
handles.displaySpikes = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in invertSpectrumCheckbox.
function invertSpectrumCheckbox_Callback(hObject, eventdata, handles)
handles.invertSpectrum =  get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on selection change in sourceSel_pmu.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to sourceSel_pmu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sourceSel_pmu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sourceSel_pmu

% --- Executes on selection change in sourceSel_pmu.
function sourceSel_pmu_Callback(hObject, eventdata, handles)

handles.PVsingleShot=handles.PVlist{get(hObject,'Value')};
handles.cal = handles.calibrations(get(hObject,'Value'));
set(handles.calEditBox,'String', handles.cal);
guidata(hObject,handles);


% --- Executes on button press in fitGaussianCheckbox.
function fitGaussianCheckbox_Callback(hObject, eventdata, handles)
handles.fitGaussian =  get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on slider movement.
function selectShotSlider_Callback(hObject, eventdata, handles)
% hObject    handle to selectShotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.selectShotNumber = round(get(hObject,'Value'));
set(handles.selectShotCountText,'String', num2str(handles.selectShotNumber,2));

% Commented text is for Batch Processing
% handles.spectrumRaw = handles.batch(handles.selectSpectrumNumber).spectrumRaw;
% handles.eLossFluxRaw = handles.batch(handles.selectSpectrumNumber).eLossFluxRaw;
% handles.specTS = handles.batch(handles.selectSpectrumNumber).specTS;
% handles.photonEnergy = handles.batch(handles.selectSpectrumNumber).photonEnergy;

handles.spectrumRaw = handles.RawDataSet(handles.selectSpectrumNumber).shot(handles.selectShotNumber, :) ;
handles.eLossFluxRaw = handles.RawDataSet(handles.selectSpectrumNumber).eFluxAverage;
handles.specTS = handles.RawDataSet(handles.selectSpectrumNumber).ts;
handles.photonEnergy = handles.RawDataSet(handles.selectSpectrumNumber).photonEnergy;


dataProcess( handles); % send data for processing and plotting

% --- Executes during object creation, after setting all properties.
function selectShotSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectShotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


