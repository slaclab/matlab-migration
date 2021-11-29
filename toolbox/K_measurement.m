function varargout = K_measurement(varargin)
% K_MEASUREMENT M-file for K_measurement.fig
%      K_MEASUREMENT, by itself, creates a new K_MEASUREMENT or raises the existing
%      singleton*.
%
%      H = K_MEASUREMENT returns the handle to a new K_MEASUREMENT or the handle to
%      the existing singleton*.
%
%      K_MEASUREMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in K_MEASUREMENT.M with the given input arguments.
%
%      K_MEASUREMENT('Property','Value',...) creates a new K_MEASUREMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before K_measurement_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to K_measurement_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help K_measurement

% Last Modified by GUIDE v2.5 09-Jan-2009 14:57:58

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @K_measurement_OpeningFcn, ...
        'gui_OutputFcn',  @K_measurement_OutputFcn, ...
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


% --- Executes just before K_measurement is made visible.
function K_measurement_OpeningFcn(hObject, eventdata, handles, varargin)
    
    % Set initial GUI defaults
    
        % graphics defaults
    handles.output = hObject;
    handles.KM_main = gcf;% handle to main K measurement window

    handles.hMeasure = 'void'; % initialize for ishandle test

    % debug mode
    handles.debug=1; % If debug =1 don't move anything
    
        % energy defaults
    bendEnergyGeV = lcaGetSmart('BEND:DMP1:400:BDES'); %use dump bend power supply
    handles.bendEnergyGeV = bendEnergyGeV;
    handles.GeVLow = 0.99*bendEnergyGeV; % default
    handles.GeVHigh = 1.01*bendEnergyGeV;
    handles.energyStepMeV = 2; % MeV
    handles.correctedEnergy =... 
        handles.GeVLow: .001*handles.energyStepMeV :handles.GeVHigh;
    handles.energySetPoints = handles.correctedEnergy; % default
    handles.Fns=[];
        % Feedback settings
    handles.initPeakCurrent = lcaGet('SIOC:SYS0:ML00:AO044');
    handles.peakCurrent = 500; % initially set to 500 for measurements to reduce wakefield noise
    handles.energyCalibrationCharge = 0.25;% nC setpoint for energy calibration
    [d,handles.chargePV] = control_chargeName;
    handles.initCharge = lcaGet(handles.chargePV);
    
        % segments and methods 
    handles.testSegment = 32;
    handles.refSegment = 33;
    handles.chosenSegment = 32;
    handles.scanRange = 2;%  + / - [mm]
    for q=1:33
        pvKACT0{q,1} = sprintf('USEG:UND1:%d50:POLYKACT.A',q);
        pvKACTB{q,1} = sprintf('USEG:UND1:%d50:POLYKACT.B',q);
    end
    handles.kact0 = lcaGetSmart(pvKACT0); % K at x=0 for ref temp, MMF
    handles.dkdx0 =  -lcaGetSmart(pvKACTB); % dK/dx at x = 0, MMF

    handles.noScanPts = 5;
    handles.method = 'One Segment';% either 'One Segment' or 'Two Segment'
    handles.detector = 'Photodiode'; % default detector
    handles.chooseText = 'First choose a method';
    handles.initStatus = 'Initialization Incomplete';
    %set(handles.Perform,'ForegroundColor',[.5 .5 .5]);
    handles.measureRefRepeats = 5; % number of REF measurements to average

        % Undulator parameters
    handles.Fref(length(handles.correctedEnergy)) = 0;
    handles.KNominal=3.4927;
    handles.KTaper = -2.7e-3; %delta K per mm of position change (dE/E = 0.86 dK/K),

        % girder and translation positions
    handles.translationIn(33) = 0; % [mm] reference IN position from config
    handles.translationOut = 80; % translation position when segment is offline [mm]
                        % 80 is normal, 25 for testing is faster
    handles.deltaPosition = 2*handles.scanRange/...
        (handles.noScanPts -1 );
    handles.translation(1:33)= 0; % set points of horizontal postion of segments [mm]
    handles.translationActual = segmentTranslate;%  current segment positions 
    handles.initialTaper = handles.translationActual;% optionally restore to this taper on closing
    kmSegmentPlot(handles); %plot current segment translations
    
        % YAGXRAY and PR55 parameters
    handles.nImages = 1; % number of images to average
    handles.ROIxmin = 1;
    handles.ROIxmax = 1392;
    handles.ROIymin = 1;
    handles.ROIymax = 1040;

        %yI = profmon_measure('YAGS:DMP1:500',1,'doPlot',0, 'nBG',0,'doProcess',0);
    handles.ROIxminYAG = 1;
    handles.ROIxmaxYAG = 1392;
    handles.ROIyminYAG = 1;
    handles.ROIymaxYAG = 1040;
    
    handles.ROIxminPR55 = 1;
    handles.ROIxmaxPR55 = 852;
    handles.ROIyminPR55 = 1;
    handles.ROIymaxPR55 = 830;        
    
    handles.TEMdataPV = 'ELEC:FEE1:452:DATA'; % default TEM data channel A
    handles.gasDetectorChosen = 'GDET:FEE1:241:ENRC'; % default gas detector Det1 PMT 1
    handles.photodiodeChosen = 'KMON:FEE1:421:ENRC'; % default Kmono photodiode
    handles.diodeMode = char( lcaGetSmart('ELEC:FEE1:DDQA:CMD') ); %  either QAMP or DIODE
    handles.XTALenergy = 8192; % transmission energy of the K mono crystal in eV

        % Solid attentuators
    for q=1:9
        handles.PVatt(q,1) = {sprintf('SATT:FEE1:32%d:STATE',q)};
    end
    handles.attenuators = lcaGet(handles.PVatt);

        % Numbers for keeping tracking of measurements in structures
    handles.measurementNo = 1; % increments for each K measurement
    handles.scanCount=1; % energy scan counter for one-off energy scans
    handles.angleScanCount = 1; %angle scan counter
    handles.deltaK = 0;
    handles.xMatch = 0;
    handles.Kref = handles.KNominal;
    
    handles.abort = 0; % default is not to abort, 1=abort
    
    % energy calibration
    handles.calMethod = 'Resonance'; % other choices are 'Donut' and 'Edge'
    handles.calEdgeCount = 1; % for multiple energy edge calibrations
    handles.calCentroidCount = 1; % for multiple energy centroid calibrations
    handles.calCentroid = 0; % initialize
    handles.calSpectralEdge = 0; % initialize
    handles.calMeanCount = 1;%initialize
    handles.calMean = 0;%initialize
    
    % analysis
    handles.fitMethod = 'midpoint'; % default
    
    % angle bumping
    handles.angleBumpOn = 0; % default is no angle bump
    handles.angleRangeX = [-15, 15]; % min urads, max urads
    handles.angleRangeY = [-15, 15]; % min urads, max urads
    handles.nAnglePts = 41; % number of different angle settings
    
    % update  handles structure
    guidata(hObject, handles); 
    
    % for closing
    set(gcf,'CloseRequestFcn',{@my_closereq,handles}); % checkout time

% --- Outputs from this function are returned to the command line.
function varargout = K_measurement_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)


function Initialize_Callback(hObject, eventdata, handles)
% Called when Set Up button is pressed.
%
% Initializes everything needed before any actual measurement starts
% Use main figure guidata to save a structure that has all sorts of
% common data and is available to all components of the figure
% Settings are for those variables that can be controlled

display('This is the Initialize Measurement Callback starting')
handles.initStatus = 'Initialization Incomplete';
kmInitializeNew('kmMain',handles.KM_main); % pass the main figure handle
 

function Perform_Callback(hObject, eventdata, handles)
% Called when Measure button is pressed.
% Move segments, record data, calculate Delta K and correction
%
% Brings up Start button. Allows remeasurement of Ref and Test and rescan
% of Test at various positions.
%
% Use main figure guidata to save a structure that has all sorts of
% common data and is available to all components of the figure

display('Measurement button has been pressed')
kmMeasure('kmMain',handles.KM_main);% pass the main figure handle

%guidata(hObject,handles);%copy to guidata

 %end Perform Measurement Callback


function Analyze_Callback(hObject, eventdata, handles)
% Analyze current measurement, or select previous measurements to analyze.

display('This is the Analyze Callback starting');

kmAnalyze('kmMain',handles.KM_main); % pass the main figure handle

guidata(hObject,handles);%copy to guidata



% --- Executes on button press in Finish.
function Finish_Callback(hObject, eventdata, handles)
% hObject    handle to Finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('This is the Finish  Callback starting')

% Restore charge
if ~handles.debug         % Set the charge
    lcaPut(handles.chargePV, handles.initCharge)
end
% Restore bunch current feedback
display('Setting bunch current to original current');
lcaPut('SIOC:SYS0:ML00:AO044',handles.initPeakCurrent);

% Clean up eDef
if isfield(handles, 'eDefNumber')
    display('Now releasing eDef number');
    eDefRelease(handles.eDefNumber);
end

% Clean up windows
if isfield(handles, 'hInit')
    if ishandle(handles.hInit)
        close(handles.hInit); % don't try to close it if it is not there
    end
end

% Retract Kmono xtal
if handles.debug~=1
    lcaPut('XTAL:FEE1:422:SELECT',1);
end

% Retract Photodiode
if (handles.debug~=1)&&strcmp(handles.detector,'Photodiode')
    lcaPut('DIOD:FEE1:426:SELECT',1);
end

% Put attenuators back
display('-------------')
display('Be sure to put solid attenuators back to...')
display(handles.attenuators);

% Optionally restore translations
my_closereq(hObject, eventdata, handles);

% Kill the window
closereq;

% --- Executes on button press in debug.
function debug_Callback(hObject, eventdata, handles)
% Turn debug bunch current feedback state on or off.

handles.debug = get(hObject, 'Value'); % if 1 then debugging on
if handles.debug == 1 % don't change machine state if debug is on
    set(hObject,'String','Debug is On',...
        'BackgroundColor',[.702 .702 .502]);
    display('handles.debug =1');
else
    set(hObject,'String', 'Debug is Off',...
        'BackgroundColor',[1 1 0]);
    display('handles.debug ~=1');
    display('You may need to (re)Initialize the measurement');
end
guidata(hObject, handles); %copy to guidata


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
%
% Send to elog and save the data
util_printLog(handles.KM_main); % print main window to elog

% Save all the data 
kmSaveData(handles)

% Reset counters
handles.scanCount = 1;

guidata(hObject, handles);


% Executes on push of Message button
function ClearMessageCallback(hObject, eventdata, handles)
set(handles.messages,'String','') % clear text if pushed


function my_closereq(src,evnt,handles)
% User-defined close request function
% to display a question dialog box
selection = questdlg('Restore segments to pre-measurement state?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes'
        handles.translation = handles.initialTaper;
        display('Returning segments to pre-measurement state')
        kmSegmentTranslate(handles);
        delete(gcf)
    case 'No'
        display('Exiting program leaving segments as is');
        delete(gcf)
end

