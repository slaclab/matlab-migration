function varargout = spectrometer(varargin)
% SPECTROMETER M-file for spectrometer.fig
%      SPECTROMETER, by itself, creates a new SPECTROMETER or raises the existing
%      singleton*.
%
%      H = SPECTROMETER returns the handle to a new SPECTROMETER or the handle to
%      the existing singleton*.
%
%      SPECTROMETER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTROMETER.M with the given input arguments.
%
%      SPECTROMETER('Property','Value',...) creates a new SPECTROMETER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spectrometer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spectrometer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spectrometer

% Last Modified by GUIDE v2.5 27-Feb-2014 09:06:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spectrometer_OpeningFcn, ...
                   'gui_OutputFcn',  @spectrometer_OutputFcn, ...
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


% --- Executes just before spectrometer is made visible.
function spectrometer_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for spectrometer
handles.output = hObject;

% *** Intializations ***

% Data Acquisition
handles.PVlist = {'SXR:EXS:CVV:01:IMAGE_CMPX:HPrj'
                    'XPP:OPAL1K:1:LiveImage:HPrj';
 'CAMR:FEE1:441:IMAGE2:ArrayData';
                    'CXI:EXS:HIST';
};
                    % 'CAMR:FEE1:441:IMAGE_CMPX:HPrj';
%handles.PVlist = {'SXR:EXS:HIST' 'SXR:EXS:HISTP';
%    'XPP:OPAL1K:1:LiveImage:HPrj' 'XPP:OPAL1K:1:LiveImage:HPrj';
%    'XPP:OPAL1K:1:LiveImage:HPrj' 'XPP:OPAL1K:1:LiveImage:HPrj'};
handles.nameList = {'SXR' 'XPP' 'HXSSS' 'CXI'};
set(handles.sourceSel_pmu,'String',handles.nameList);
handles.sourceSel=3;  % HXRSS defaul
set(handles.sourceSel_pmu,'Value',handles.sourceSel);

% HXSSS has two crystals,one of which as has two crystal planes
handles.calibrations = [ -.0619, -0.0326, .07509,1];% Temporary fake cal for SXR 12/20/13
%HXSeVperPixel = lcaGet('FEE:HXS.DE'); %10/30/14
HXSeVperPixel = -1;
handles.calibrations = [ -.0619, -0.0326, HXSeVperPixel,1];% Temporary fake cal for SXR 12/20/13
GeV  = lcaGet('BEND:DMPH:400:BACT');
if GeV<12 % must be the new crystal and 111 plane
    set(handles.calTextWarning,'Visible','on','String','Low energy cal' )
else
    handles.calibrations(3) = 0.1418; % old crystal with new bend angle
    set(handles.calTextWarning,'Visible','on','String','High energy cal' )
end

handles.cal = handles.calibrations(get(handles.sourceSel_pmu,'Value'));
lcaPutSmart(['SIOC:SYS0:ML00:AO73' num2str(5+handles.sourceSel)],handles.cal); % Update shared PVs
set(handles.calEditBox,'string',handles.cal);
handles.numberToAverage = 1; % single shot
set(handles.numberToAverageBox,'String',num2str(handles.numberToAverage) );
handles.nset = 0;% Data set number.
handles.background = 0; % need to get some decent default values here.

% Plot Controls
handles.waitTime=0.01; % wait time for collecting averages and free run
handles.smoothFactor = 0; % no smoothing
handles.zeroBaseline = 1;
set(handles.zeroBaselineCB,'Value',handles.zeroBaseline);
handles.spectrumNoise = 20; % noise floor for zero baseline    FJD: 10000 ---> 200
handles.displayFWHM = 1;
set(handles.fwhmCheckbox, 'Value',1)
handles.photonFWHM = 0;
handles.displayArea = 0;
handles.displayCentroid = 0; % don't display
handles.displayEdge = 0; % don't display edge
handles.displayPeak = 0;
handles.xAxisScale = 'absolute'; % display eV 
set(handles.eVDisplayCheckbox, 'Value',1)
handles.fitGaussian = 0 ; % don't fit a gaussian
handles.autoScale = 1; % default is to autoscale
handles.YLimPrevious = [0,1]; % initialize fixed scale
handles.subtractBackground = 0; % don't subtract background
handles.hDataSet = [handles.dataShotNumberText, handles.dataShotSlider, handles.dataShotTitleText, handles.dataSetNumberText, handles.dataSetSlider, handles.dataSetTitleText];
set(handles.hDataSet,'Visible','Off');
handles.PVupdate = 0; % don't update PVs unless user requested (reduces interference of multiple gui instances)
set(handles.pulseEnergyCheckbox, 'Visible', 'off');% don't allow until at least one shot has been taken
handles.pulseEnergyCalc = 0;
handles.pulseEnergySeeded = 0;
handles.pulseEnergySASE = 0;
handles.pulseEnergySeededFraction = 0;



% GUI initializations
handles.readyButtonColor = [ 0 .7 0];
set(handles.takeShotButton,'BackgroundColor', handles.readyButtonColor);
handles.runButtonColor = [1 .54 .37 ];
set(handles.freeButton,'BackgroundColor', handles.readyButtonColor);
handles.freeRun = 0;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = spectrometer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% % --- Executes when user attempts to close spectrometerFigure.
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% 
% util_appClose(hObject);

% --- Executes when user attempts to close spectrometer.
function spectrometer_CloseRequestFcn(hObject, eventdata, handles)

util_appClose(hObject);


% --- Executes on button press in takeShotButton.
function takeShotButton_Callback(hObject, eventdata, handles)
% Take data and send to processing and plotting. 
set (handles.takeShotButton, 'String', 'Reading...', 'BackgroundColor',handles.runButtonColor);
set(handles.calTextWarning,'Visible','off' )
set(handles.hDataSet , 'visible', 'off')
handles.nset = handles.nset + 1;

handles = takeShot(handles);
set(handles.pulseEnergyCheckbox, 'Visible', 'on'); % avoid error if no shot has been taken previously

% Update guidata
guidata(hObject, handles)

function handles = takeShot(handles)
% Take  data set and send to processing, Data is an average of 1 or more shots.

% Remove loaded data
handles = rmDataSet(handles);

% Get current machine conditions and store in data structure.
if ~handles.freeRun
    handles.data.config(handles.nset) = FELconfigRead();
    handles.photonEnergy = handles.data.config(handles.nset).photonEnergy;
end

% Take data set(s) and check for changes in PVupdate status
shotTotal=0;
for q=1:handles.numberToAverage
    if get(handles.sourceSel_pmu,'Value') ~=3
        [shot, handles.specTS] = lcaGet(handles.PVlist( get(handles.sourceSel_pmu,'Value')  )); % Get one shot
    else
        % special case if HXSSS when no projection is available 10/30/14
        img = profmon_grab('HXS');
        shot = sum(img.img);
        handles.specTS = img.ts;
    end
    
    handles.data.set(handles.nset).spectrumRaw(q,:) = shot;% for data saving
    handles.data.set(handles.nset).ts(q,:) = handles.specTS;
    handles.gasDetector_uJ = 1000*( lcaGet('GDET:FEE1:241:ENRCCUHBR') ); % usually not synchronous with spectrum
    handles.data.set(handles.nset).gasDetector_uJ(q,:) = handles.gasDetector_uJ;
    
    %%
    % Data structure used for saving data - saves everthing except free run
    % data.
        % handles.data.set(handles.nset).spectrumRaw(nshot,sizeOfSpectra) 
        % handles.data.config(handles.nset)
     %%
        
    shotTotal = shotTotal + shot;
    pause(handles.waitTime);
    set (handles.takeShotButton, 'String', num2str(q));

    PVupdateStatus = lcaGet('SIOC:SYS0:ML00:AO729'); % check status - stop writing if 0
    if ~PVupdateStatus
        handles.PVupdate = 0;
        set(handles.updatePVcheckbox, 0) % uncheck the box
    end
end
set (handles.takeShotButton, 'String', 'Take', 'BackgroundColor', handles.readyButtonColor);

% Calculate average 
handles.spectrumRaw = shotTotal/handles.numberToAverage;

% Send data for processing and plotting
handles = dataProcess(handles); % smooth and subtract, etc and plotting


function numberToAverageBox_Callback(hObject, eventdata, handles)
handles.numberToAverage = str2double(get(hObject,'String'));
guidata(hObject, handles);

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


% --- Executes on button press in freeButton.
function freeButton_Callback(hObject, eventdata, handles)

set(handles.hDataSet , 'visible', 'off')
tags={'Free Run' 'Stop'};
colr = {handles.readyButtonColor handles.runButtonColor};
set(hObject,'String',tags{get(hObject,'Value')+1});
set(hObject,'BackgroundColor',colr{get(hObject,'Value')+1});

if ~isfield(handles,'photonEnergy')
    config = FELconfigRead();
    handles.photonEnergy = config.photonEnergy; 
    guidata(hObject,handles);
end

% Dont allow Export while in Free run (causes misdirected labeling)
set(handles.exportButton, 'Visible','Off')

% Dont allow ELOG while in Free run (causes overwriting with old TS)
set(handles.elogButton, 'Visible','Off')

try % if something goes wrong, be sure to update guidata 
    while get(hObject,'Value')
        handles = guidata(hObject); % update changes to checkboxes
        handles.freeRun = 1;
        handles.nset=max(handles.nset,1); % Make sure nset > 0 (H.L. 12/4/2012)
        handles  = takeShot(handles); % takes a data set (one or more shots which for which the average is presented)
    end
    handles.freeRun = 0;
    set(handles.exportButton, 'Visible','On')
    set(handles.elogButton, 'Visible','On')
catch
    guidata(hObject, handles);
end

% --- Executes on button press in elogButton.
function elogButton_Callback(hObject, eventdata, handles)
% Make figure suitable for elog and save data

elogFigure = figure;
set(elogFigure, 'units','characters');
positionSave = get(handles.spectrumAxis,'Position');
set(handles.spectrumAxis,'Position', [12 5 positionSave(3:4) ]);
set(elogFigure,'Position',[1 1 95 33]);
copyobj(handles.spectrumAxis,elogFigure);
set(handles.spectrumAxis,'Position', positionSave);

%Send to elog
util_printLog(elogFigure);

%Send to save function
handles = spectralDataSave(handles);

%Update guidata
guidata(hObject, handles)

% Save all the data 
function handles = spectralDataSave(handles)
%
% Save all guidata to file

header = 'Spectra';
name = char( handles.nameList(handles.sourceSel) ); % JW 2/20/14
ts = lca2matlabTime(handles.specTS);                  % FJD 8Feb2013. 
if handles.sourceSel ==3 % special case for new HXSSS camera 10/31/14
    ts = datestr(handles.specTS);
end

[fileName, pathName] = util_dataSave(handles, header, name, ts); % saves handles as structure "data"
display(['Writing GUI data to file ' fileName pathName]);

% Reset the data field and data set counter
handles.nset = 0;
if isfield(handles,'data')
    handles = rmfield(handles, 'data');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% loads data from saved sets, displays what was in elog

[data,fileName] = util_dataLoad('Open Saved Spectrum');
if ~ischar(fileName), return, end

% Update run parameters to used saved values
list={'spectrumRaw' 'specTS' 'photonEnergy'  'sourceSel' 'numberToAverage'};
for j=list
    if isfield(data,j{:})
        handles.(j{:})=data.(j{:});
    end
end
if isfield(data, 'cal')
    if handles.cal ~= data.cal
        set(handles.calTextWarning,...
            'String',{'Saved eV/pixel = ';  num2str(data.cal) },...
            'Visible','on')
        data.cal = handles.cal;
    else
        set(handles.calTextWarning, 'Visible','off');
    end
end

% weird case of no config data in saved file
if ~isfield(data.data, 'config')
    data.data.config = FELconfigRead;% just grab current config; 
end

handles.photonEnergy = data.data.config(end).photonEnergy;

% Put saved data into handles, display elog case, and set up sliders for
% other data
if isfield(data,'data')
    handles.dataSet = data.data.set; % All saved data
    handles.dataSetconfig = data.data.config;


    % Fix up sliders for displaying last data set (shown in elog)
    % If multiple shots, display average and put shot slider at max
    [junk, nSets] = size(handles.dataSet);
    handles.nset = nSets; % show last data set

    % Shot slider setup
    [nShots,junk] = size(handles.dataSet(handles.nset).spectrumRaw) ;
    handles.numberToAverage = nShots;
    handles.nShot = nShots;
    
    if nShots ~= 1 % multiple shots, start with slider set for average
        set(handles.dataShotSlider,'Min',1, 'Max',nShots+1, 'Value', nShots+1,'SliderStep', (1/ (nShots))*[1,10], 'Visible', 'On'); % last step is for average
        handles.numberToAverage = nShots;
        set(handles.dataShotNumberText,'String', 'Ave.', 'Visible','On');
        set(handles.dataShotTitleText,'Visible','On')
        handles.spectrumRaw = mean(handles.dataSet(handles.nset).spectrumRaw) ;
    else % only one shot in set, don't display shot slider and related text
        set(handles.dataShotSlider,'Visible','Off');
        set(handles.dataShotNumberText,'Visible','Off')
        set(handles.dataShotTitleText,'Visible','Off')
        handles.nShot = 1;
        handles.spectrumRaw = handles.dataSet(handles.nset).spectrumRaw; % only one shot
    end

    % Set slider setup
    if nSets ==1 % don't display set slider
        set(handles.dataSetSlider,'Visible','Off'); % turn off set slider if there is only one set
        set(handles.dataSetNumberText,'Visible','Off');
        set(handles.dataSetTitleText,'Visible','Off');
    else
        set(handles.dataSetSlider,'Visible','On'); % turn on set slider
        set(handles.dataSetNumberText,'Visible','On');
        set(handles.dataSetTitleText,'Visible','On');
        set(handles.dataSetSlider,'Min',1,'Max',nSets,'SliderStep',  [1,10] /(nSets-1), 'Value', nSets   ) ;
        set(handles.dataSetNumberText, 'String', num2str(nSets) );
    end

end

% Send data displayed in elog for processing
handles = dataProcess(handles);

% Reset number to average
handles.numberToAverage=1; % In case Take is pushed after data is loaded
set(handles.numberToAverageBox,'String', '1');

% Update guidata
guidata(hObject, handles)


% --- Executes on selection change in sourceSel_pmu.
function sourceSel_pmu_Callback(hObject, eventdata, handles)

val=get(hObject,'Value');
handles.sourceSel=val;
handles.cal = handles.calibrations(val);
set(handles.calEditBox,'String',num2str(handles.cal));
handles.zoom = lcaGet('STEP:FEE1:445:MOTR.RBV');
% handles.ROIY=[0;0];
% if val == 2 % XPP
%     handles.ROIY=lcaGetSmart(strcat('XPP:OPAL1K:1:ROI_Y_',{'Start';'End'}));
% 
%     set([handles.ROIYStart_txt handles.ROIYEnd_txt],{'String'},cellstr(num2str(handles.ROIY)));
%     str={'off' 'on' 'off' 'off'};
% else
%     str={'off' 'off' 'off' 'off'};
% end
% set([handles.ROIYStart_txt handles.ROIYEnd_txt handles.ROIYStartLabel_txt ...
%     handles.ROIYEndLabel_txt],'Visible',str{val});
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sourceSel_pmu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourceSel_pmu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function calEditBox_Callback(hObject, eventdata, handles)

handles.cal = str2double(get(hObject,'String'));
handles.calibrations(get(handles.sourceSel_pmu,'Value')) = handles.cal; % update the default
guidata(hObject, handles);
lcaPutSmart(['SIOC:SYS0:ML00:AO73' num2str(5+handles.sourceSel)],handles.cal);
dataProcess(handles);

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
function slider1_Callback(hObject, eventdata, handles)
% update smoothing factor and text
handles.smoothFactor = get(hObject,'Value');
guidata(hObject, handles);
set(handles.smoothValueText,'String', num2str(100*handles.smoothFactor,2));
dataProcess( handles); 


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in fwhmCheckbox.
function fwhmCheckbox_Callback(hObject, eventdata, handles)
handles.displayFWHM = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in peakCheckbox.
function peakCheckbox_Callback(hObject, eventdata, handles)
handles.displayPeak = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of peakCheckbox

function handles = dataProcess(handles)
% Process data and send it to analysis and plotting

spectralData = handles.spectrumRaw; % a single shot, not an array

% Subtract backtround noise
if handles.subtractBackground
    spectralData = spectralData - handles.background;
end

% Smooth the spectrum
[x, spectralData] = scanSmooth(1:length(spectralData), spectralData, 100*handles.smoothFactor);

% Zero the baseline
if handles.zeroBaseline
    noise = handles.spectrumNoise; % CCD readout noise
    dataNoise = std(spectralData); 
    if dataNoise < handles.spectrumNoise % to avoid zero length data sets if noise is wrong
        noise = 0.1*std(spectralData);
    end
    spectralData =spectralData-min(spectralData) - noise;
    spectralData ( spectralData<0 ) = 0;
end

% Send to analysis and plotting
handles.spectrum = spectralData;
handles = shotAnalyse(handles); % update handles before return to calling function


% --- Executes on button press in centroidCheckbox.
function centroidCheckbox_Callback(hObject, eventdata, handles)
handles.displayCentroid = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in edgeCheckbox.
function edgeCheckbox_Callback(hObject, eventdata, handles)
handles.displayEdge = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);

% --- Executes on button press in gaussianCheckbox.
function gaussianCheckbox_Callback(hObject, eventdata, handles)
handles.fitGaussian =  get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in eVDisplayCheckbox.
function eVDisplayCheckbox_Callback(hObject, eventdata, handles)

if get(hObject,'Value') % if 1 plot against absolute energy loss
    handles.xAxisScale = 'absolute';
else  % plot against relative energy
    handles.xAxisScale = 'relative';
end
handles = dataProcess( handles); 
guidata(hObject,handles)


function ROIYStart_txt_Callback(hObject, eventdata, handles)
handles.ROIY(1) = str2double(get(hObject,'String'));
guidata(hObject, handles);
lcaPutSmart('XPP:OPAL1K:1:ROI_Y_Start',handles.ROIY(1));


% --- Executes during object creation, after setting all properties.
function ROIYStart_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIYStart_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = shotAnalyse(handles)
% Analyze data and set to plotting

% spectralData is an array of pixel values - need to convert to eV in plot
% routine
spectralData = handles.spectrum;
fxn = spectralData/sum(spectralData); % normalized

% RMS
x = 1:length(fxn);
handles.meanPhoton = sum( x.* fxn ); % relative to SXR settings, not absolute
handles.rms = sqrt( sum(x.*x.*fxn) - handles.meanPhoton^2);

% FWHM
handles.photonFWHM = fwhmGeneral(x, fxn);
if isnan(handles.photonFWHM)
    handles.photonFWHM = max(x) - min(x);
end

% Total spectral power, [cts^2 * pixel]
handles.totalSpectralPower = handles.cal^2*sum(spectralData.*spectralData)/length(spectralData);

% Total counts
handles.totalCounts = sum(spectralData);

% Plot the result
handles = shotPlot(handles);

function handles = shotPlot( handles)
% Plot photon spectrum

% Choose spectra and plot in eV deviation
y = handles.spectrum; 
x = 1:length(y);
x = x - floor(length(x)/2); x = x*handles.cal;

% Choose absolute or relative coordinates
xAxisLabel = 'eV'; % default is absolute
if strcmp(handles.xAxisScale, 'relative')  % plot against relative energy
    x = 1e3*x/ handles.data.config(handles.nset).photonEnergy;
    xAxisLabel =  '\Delta \omega/\omega [0.1%]';
end

% Plot spectrum
set(handles.spectrumAxis,'Parent', handles.spectrometerFigure);
plot(handles.spectrumAxis, x,y,'Parent', handles.spectrumAxis); % makes parent property of x y equal the spectrumAxis
xlabel(handles.spectrumAxis,xAxisLabel);
ylabel(handles.spectrumAxis, ['Counts [' num2str(handles.numberToAverage) ' shot average]']);
shotDate = datestr(lca2matlabTime(handles.specTS(end)));%2/16/12 
if handles.sourceSel ==3 % special case for new HXSSS camera 10/31/14
    shotDate = datestr(handles.specTS);
end
title(handles.spectrumAxis, ...
   [handles.nameList{handles.sourceSel} '  '  num2str(handles.photonEnergy, '%7.1f') 'eV, ' shotDate]);

% figure(handles.spectrometerFigure); this grabs the focus
% axes(handles.spectrumAxis); this also grabs the focus
set(0,'CurrentFigure', handles.spectrometerFigure); % make spectrometerFigure the current figure without changing its state.

% Restore saved scale if not autoscale
if ~handles.autoScale
    set(gca,'YLim', handles.YLimPrevious)
end

% Display centroid
if handles.displayCentroid
    handles.centroid = centroidCalc(x,y,handles.spectrumAxis);
end

% Display FWHM
if handles.displayFWHM
    fwhmGeneral(x,y,handles.spectrumAxis);
end

% Display edge
if handles.displayEdge
    handles.spectralEdge = edgeCalc(x,y,handles.spectrumAxis);
end

% Display peaks
if handles.displayPeak
    [handles.spectralPeakLocation handles.spectralPeakValue] = peakCalc(x,y,handles.spectrumAxis);
else % calculated but don't display
    [handles.spectralPeakLocation handles.spectralPeakValue] = peakCalc(x,y);
end

% Fit Gaussian?
if handles.fitGaussian
    gaussCalc(x,y,handles.spectrumAxis);
else
    % clean up? Need soft IOC space for these data
end

% Display area?
if handles.displayArea
    handles.area = areaCalc(x,y, handles.spectrumAxis);
else
    handles.area = areaCalc(x,y);
end

% Calculate pulse energy?
if handles.pulseEnergyCalc
    % Get gas detector energy
    handles.gasDetector_uJ = 1000*mean( lcaGet('GDET:FEE1:241:ENRCHSTBR',10) ); % not synchronous with spectrum
    
    % Get seeded fraction: sharp peaks dominate gaussian fit
    [par, yfit, bg] = util_gaussFit(x,y,1);
    amplitude = par(1);
    sigma = par(3);
    areaSeed = amplitude*sqrt(2*pi)*sigma;
    if sigma > (max(x)  - min(x)) / 50; % no sharp peak present
        areaSeed = 0;
    end
    
    % Calc SASE and seeded energy
    handles.pulseEnergySeeded = handles.gasDetector_uJ * areaSeed/handles.area;
    handles.pulseEnergySASE = handles.gasDetector_uJ * (1-areaSeed/handles.area);
    handles.pulseEnergySeededFraction =  areaSeed/handles.area;
    
    % Write to plot
    yRange = max(y)-min(y);
    xRange = max(x)-min(x);
    text(  min(x)-.05*xRange, max(yfit)-0.30*yRange,...
        ['Seeded ' num2str(handles.pulseEnergySeeded,'%5.0f [uJ]')],...
        'HorizontalAlignment','left');
    text(  min(x)-.05*xRange, max(yfit)-0.35*yRange,...
        ['SASE ' num2str(handles.pulseEnergySASE, '%5.0f [uJ')],...
        'HorizontalAlignment','left');
end

% Update soft IOCs for correlation plots
if handles.PVupdate
    lcaPut('SIOC:SYS0:ML00:AO680',  handles.spectralPeakLocation);
    lcaPut('SIOC:SYS0:ML00:AO681',  handles.spectralPeakValue);
    lcaPut('SIOC:SYS0:ML00:AO682', handles.photonFWHM *(abs(handles.cal)));
    lcaPut('SIOC:SYS0:ML00:AO683', handles.area);
    max_eV = min(handles.photonFWHM *(abs(handles.cal)),3.0);               % FJD "area" around seeded
    lcaPut('SIOC:SYS0:ML00:AO735',  handles.spectralPeakValue * max_eV);  % FJD "area" around seeded
    lcaPut('SIOC:SYS0:ML00:AO725', handles.pulseEnergySeeded);
    lcaPut('SIOC:SYS0:ML00:AO726', handles.pulseEnergySASE);
    lcaPut('SIOC:SYS0:ML00:AO727', handles.pulseEnergySeededFraction);
end

function ROIYEnd_txt_Callback(hObject, eventdata, handles)

handles.ROIY(2) = str2double(get(hObject,'String'));
guidata(hObject, handles);
lcaPutSmart('XPP:OPAL1K:1:ROI_Y_End',handles.ROIY(2));

% --- Executes during object creation, after setting all properties.
function ROIYEnd_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIYEnd_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in zeroBaselineCB.
function zeroBaselineCB_Callback(hObject, eventdata, handles)
handles.zeroBaseline = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in areaCheckbox.
function areaCheckbox_Callback(hObject, eventdata, handles)
handles.displayArea = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in standardTaperButton.
function standardTaperButton_Callback(hObject, eventdata, handles)
% Load the standard taper into the machine

qstring = 'Move undulator segments to the standard Taper?';
button = questdlg(qstring);
if strcmp(button, 'Yes')
    segmentTranslate(handles.taperStandard);
end


% --- Executes on button press in autoscaleCheckbox.
function autoscaleCheckbox_Callback(hObject, eventdata, handles)
handles.autoScale = get(hObject,'Value');
% Retain scale if not autoscale
if(~handles.autoScale)
    handles.YLimPrevious = get(gca,'YLIM');
end
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on button press in exportButton.
function exportButton_Callback(hObject, eventdata, handles)

if ishandle(handles.spectrumAxis)
    elogFigure = figure;     % Make new figure suitable for elog
    ha = axes; % Make current
    new_handle = copyobj(allchild(handles.spectrumAxis),ha); % copy objects to axes ha in elogFigure
end


% --- Executes on button press in useAsBackgroundButton.
function useAsBackgroundButton_Callback(hObject, eventdata, handles)
% Take current data as background spectrum
% 
handles.background = handles.spectrumRaw;
handles = dataProcess( handles); 
guidata(hObject, handles)

% --- Executes on button press in subtractBackgroundCheckbox.
function subtractBackgroundCheckbox_Callback(hObject, eventdata, handles)
% Subtract background from raw spectrum
handles.subtractBackground = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject, handles);


% --- Executes on slider movement.
function dataShotSlider_Callback(hObject, eventdata, handles)
% For selected data set choose individual spectra to display  shots or display average of
% all shots in set

% Get set number
handles.nset = max(handles.nset, 1); % avoid 0

%Get number of spectra in data
[nShots, junk] = size(handles.dataSet(handles.nset).spectrumRaw) ;

handles.numberToAverage  = 1;

% Multiple shot case
if nShots > 1 % multiple shots in set
    set(handles.dataShotSlider,'Visible','On')
    set(handles.dataShotNumberText, 'Visible','On')

    % Get slider position and set index
    n = round( get(hObject,'Value') ) ; % index for labeling shots 1,2,3, ...,nShots, AVE

    if n == nShots+1 % If slider is at Max display the average
        set(handles.dataShotNumberText,'String','Ave');
        handles.numberToAverage = nShots;
        handles.spectrumRaw = mean(handles.dataSet(handles.nset).spectrumRaw);
        handles.specTS = handles.dataSet(handles.nset).ts(nShots);
    else % display the shot
        set(handles.dataShotNumberText,'String',num2str(n));
        handles.spectrumRaw = handles.dataSet(handles.nset).spectrumRaw(n,:) ;
        handles.specTS = handles.dataSet(handles.nset).ts(n);
    end

else % Single shot case
    n =1;
    set(handles.dataShotSlider,'Visible','Off')
    set(handles.dataShotNumberText, 'Visible','Off')
    handles.spectrumRaw = handles.dataSet(handles.nset).spectrumRaw(n,:) ;
    handles.specTS = handles.dataSet(handles.nset).ts(n);
end

% Update handles and send to processing
handles = dataProcess( handles); % processes handles.spectrumRaw

% Reset number to average
handles.numberToAverage=1; % In case Take is pushed after data is loaded
set(handles.numberToAverageBox,'String', '1');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dataShotSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataShotSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in updatePVcheckbox.
function updatePVcheckbox_Callback(hObject, eventdata, handles)
% Start updating soft IOC PVs. Tell other GUI's to back off. 
% Unchecking box has no effect.

handles.PVupdate = get(hObject,'Value');
if  handles.PVupdate
    lcaPut('SIOC:SYS0:ML00:AO729',0 ); %tell other gui's to stop updating
    pause(1); % allow time for other gui's to see change in status
    lcaPut('SIOC:SYS0:ML00:AO729', handles.PVupdate); 
end
guidata(hObject, handles);
    

% --- Executes on button press in pulseEnergyCheckbox.
function pulseEnergyCheckbox_Callback(hObject, eventdata, handles)
% Calculate seeded and SASE contributions to the pulse energy

if ~ get(handles.useAsBackgroundButton,'Value')% if not checked use default BG
    handles = defaultBackground(handles);
end
handles.pulseEnergyCalc = get(hObject,'Value');
handles = dataProcess( handles); 
guidata(hObject,handles);


% --- Executes on button press in exportExcelButton.
function exportExcelButton_Callback(hObject, eventdata, handles)

% Send processed data to Excel file 

% Build output matrix with one spectra per row (only using last data set)
handles.spectrumRaw = handles.dataSet(end).spectrumRaw(1,:);
handles = dataProcess(handles);
M = handles.spectrum;
%ts = datestr( lca2matlabTime(handles.specTS),30 );

[nSpectra, junk] = size(handles.dataSet(end).spectrumRaw);
if nSpectra > 1
    for q=2:nSpectra
        handles.spectrumRaw = handles.dataSet(end).spectrumRaw(q,:);
        handles = dataProcess(handles);
        M = [M; handles.spectrum];
    end
end
M = M'; % excel max ncol is 256

ts = lca2matlabTime(handles.specTS);
if handles.sourceSel ==3 % special case for new HXSSS camera 10/31/14
    ts = datestr(handles.specTS);
end
dataDate=ts;
dataRoot=fullfile(getenv('MATLABDATAFILES'),'data');
dataYear=datestr(dataDate,'yyyy');
dataMon=datestr(dataDate,'yyyy-mm');
dataDay=datestr(dataDate,'yyyy-mm-dd');
pathName=fullfile(dataRoot,dataYear,dataMon,dataDay);
if ~exist(pathName,'dir'), try mkdir(pathName);catch end, end

header ='spectra';
fileName=strrep([header '-' datestr(ts,'yyyy-mm-dd-HHMMSS')],':','_');

xlswrite([pathName '/' fileName] ,M)

function handles = defaultBackground(handles)
% Loads a default background into the background data

default = open ('HXRSSdefaultBackground.mat'); % opens file and stores variables in workspace
handles.background = default.background;
handles.subtractBackground=1;
set(handles.subtractBackgroundCheckbox,'Value',1)
handles.zeroBaseline = 0;
set(handles.zeroBaselineCB,'Value',0)
handles = dataProcess(handles);


% --- Executes on slider movement.
function dataSetSlider_Callback(hObject, eventdata, handles)
% Choose which saved data set set to look at. A data set is the shots
% collected when Take Shot is pressed. Set's accumulate until elog / save
% is called

[junk, nSets] = size(handles.dataSet); % number of sets in saved data
n = round( get(hObject,'Value') ) ; % index for selecting sets 1,2,3, ...,nSets
set(handles.dataSetNumberText,'String',num2str(n));
handles.nset = n;

% Update shot slider
[nShots,junk] = size(handles.dataSet(handles.nset).spectrumRaw) ;

if nShots == 1
    set(handles.dataShotSlider,'Visible','Off')
    set(handles.dataShotNumberText, 'Visible','Off')
    set(handles.dataShotTitleText,'Visible','Off');
    handles.numberToAverage =1;
    handles.spectrumRaw =   handles.dataSet(handles.nset).spectrumRaw; 
    handles.specTS = handles.dataSet(handles.nset).ts;
else % set shot slider to display average
    set(handles.dataShotSlider, 'Visible','On','Max', nShots+1, 'Min', 1, 'Value', nShots+1, 'SliderStep', (1/ (nShots))*[1,10]); % Reset data Shot Slider to nShots + 1
    set(handles.dataShotNumberText, 'Visible','On','String', 'Ave.'); 
    set(handles.dataShotTitleText,'Visible','On');
    handles.spectrumRaw =   mean(handles.dataSet(handles.nset).spectrumRaw); 
    handles.specTS = handles.dataSet(handles.nset).ts(end);% update timestamp to display
    handles.numberToAverage =nShots;
end

handles = dataProcess(handles); % update plot

% Reset number to average
handles.numberToAverage=1; % In case Take is pushed after data is loaded
set(handles.numberToAverageBox,'String', '1');

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function dataSetSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataSetSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function handles = rmDataSet(handles)
% Remove data loaded from saved sets from handles
if isfield(handles,'dataSet')
    handles = rmfield(handles, 'dataSet');
end
if isfield(handles,'dataConfig')
    handles = rmfield(handles, 'dataConfig');
end
