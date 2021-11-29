function varargout = kmInitializeNew(varargin)
% KMINITIALIZENEW M-file for kmInitializeNew.fig
%      KMINITIALIZENEW, by itself, creates a new KMINITIALIZENEW or raises
%      the existing
%      singleton*.
%
%      H = KMINITIALIZENEW returns the handle to a new KMINITIALIZENEW or the handle to
%      the existing singleton*.
%
%      KMINITIALIZENEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KMINITIALIZENEW.M with the given input arguments.
%
%      KMINITIALIZENEW('Property','Value',...) creates a new KMINITIALIZENEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kmInitializeNew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kmInitializeNew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kmInitializeNew

% Last Modified by GUIDE v2.5 17-Sep-2009 14:59:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @kmInitializeNew_OpeningFcn, ...
    'gui_OutputFcn',  @kmInitializeNew_OutputFcn, ...
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


% --- Executes just before kmInitializeNew is made visible.
function kmInitializeNew_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kmInitializeNew (see VARARGIN)

% Check to see if handle to KM_main gui is passed in
dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'kmMain'));
if (isempty(mainGuiInput)) || (length(varargin) <= mainGuiInput) || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, (and adjust our position?)
    handles.KM_main = varargin{mainGuiInput+1};% this is the handle to the main gui figure
    mainHandles = guidata(handles.KM_main);% copy all main gui handles struture

    % Set the initial text (Keep all data current in K_measurement guidata)
    numbersUpdate(handles);

    % Position to be relative to parent:
    parentPosition = getpixelposition(handles.KM_main);
    parentInitUnits = get(handles.KM_main, 'Units');
    set(handles.KM_main,'Units','pixels'); % set to pixels if not already
    set(handles.initFigure, 'Units','pixels'); % this handle was assigned by Guide
    currentPosition = get(handles.initFigure, 'Position');  % initFigure is set in guide or exists
    set(handles.KM_main,'Units',parentInitUnits); % return units
    % Set x to be to right of and share baseline with main gui, assumes units are pixels
    newX = parentPosition(1) + parentPosition(3) + 5;
    newY = parentPosition(2);
    %newY = parentPosition(2) + (parentPosition(4) - currentPosition(4));
    newW = 656; % currentPosition(3) ;
    newH = currentPosition(4);
    initFigureInitUnits = get(handles.initFigure, 'Units');
    set(handles.initFigure, 'Units','pixels','Position', [newX, newY, newW, newH]);
    set(handles.initFigure,'Units',initFigureInitUnits); % return units

    % set method radiobuttons to current choice
    switch(mainHandles.method) 
        case 'One Segment'
            set(handles.uipanel5,'SelectedObject',handles.radiobutton4);%
            set(handles.text8,'Visible','on');
            set(handles.edit8,'Visible','on');
        case 'Two Segment'
            set(handles.uipanel5,'SelectedObject',handles.radiobutton5);
%             set(handles.text8,'Visible','off');
%             set(handles.edit8,'Visible','off');
    end
    
    % set detector radio buttons to current choice
    switch(mainHandles.detector) 
        case 'Simulator'   % use kmDataSimulator for flux
            set(handles.uipanel8,'SelectedObject',handles.radiobutton6);%
            set(handles.detectorParameters,'Visible','off');
        case 'YAGXRAY TMIT'% use YAGXRAY "TMIT for flux
            set(handles.uipanel8,'SelectedObject',handles.radiobutton9);%
            set(handles.detectorParameters,...
                'Title','YAGXRAY Setup',...
                'Visible','on');
            numbersUpdate(handles);
        case 'Photodiode'   % use photodiode
            set(handles.uipanel8,'SelectedObject',handles.radiobutton10);%
            set(handles.detectorParameters,'Visible','off');
        case 'Thermal'     % use a Thermal FEL energy sensor 
            set(handles.uipanel8,'SelectedObject',handles.radiobutton7);%
            set(handles.detectorParameters,'Visible','off');
        case 'Gas Detector' % use  gas detector signal for flux
            set(handles.uipanel8,'SelectedObject',handles.radiobutton8);%
            set(handles.detectorParameters,'Visible','off');
        case 'Dog Leg' % display dog leg energy versus programmed energy
            set(handles.uipanel8,'SelectedObject',handles.radiobutton11);%
            set(handles.detectorParameters,'Visible','off');
        case 'PR55' % use PR55 and appropriate energy bpm
            set(handles.uipanel8,'SelectedObject',handles.radiobutton12);%
            set(handles.detectorParameters,...
                'Title','PR55 Setup',...
                'Visible','on');
        case 'NFOV'
            set(handles.uipanel8,'SelectedObject',handles.NFOVradiobutton);

    end

    % set beam parameters to current choice
end

panelUpdate(handles); % update the panels to current choices
mainHandles.scanButton = handles.ScanEnergyOnce; % handle to scan button
mainHandles.hInit = hObject; % handles to the intialization gui

% update or create energySetPoints
mainHandles.energySetPoints =...
    [mainHandles.GeVLow:mainHandles.energyStepMeV/1000:mainHandles.GeVHigh];

% Update handles structure
guidata(hObject, handles);

if dontOpen
    disp('-----------------------------------------------------');
    disp('Improper input arguments. Pass a property value pair')
    disp('whose name is "KM_main" and value is the handle')
    disp('to the KM_main figure, e.g:');
    disp('-----------------------------------------------------');
end


% Set up eDef for measurements
myName = 'KMEAS'; % Choose unique name
myNAVG = 1; % number of beam pulses to average per record

myNRPOS = 1200; % save  myNRPOS records per eDefAcq call
mainHandles.timeout = 10.0; % seconds

% Reserve an eDef number
set(mainHandles.messages,'String', [{'Reserving'} {'eDef...'}]);
eDefNumber = eDefReserve(myName); % Reserve an eDef number
mainHandles.eDefNumber = eDefNumber; 

% Make sure I got an eDef Number
if isequal (eDefNumber, 0)
    disp('Sorry, failed to get eDef');
else
    disp(sprintf('I am eDef number %d',eDefNumber));

    % set my number of pulses to average, etc... Optional, defaults to no
    % averaging with one pulse and DGRP INCM & EXCM.
    eDefParams (eDefNumber, myNAVG, myNRPOS, {''},{''},{''},{''});

    disp (sprintf('I am averaging %d pulses per step',myNAVG));
    disp (sprintf('I am requesting %d steps',myNRPOS));
    disp (sprintf('I am willing to wait up to %.1f seconds',mainHandles.timeout));
    eDefOff(eDefNumber); % in case it is on
end
set(mainHandles.messages,'String', 'Ready');
guidata(handles.KM_main,mainHandles);%copy to main guidata

% Check Tuneup Dump status
if ~strcmp(mainHandles.detector,'Simulator')  % then check if MPS is blocking beam
    TD11status = lcaGet('DUMP:LI21:305:TGT_STS');
    TDUNDstatus = lcaGet('DUMP:LTU1:970:TGT_STS');
    if strcmp(TD11status, 'IN') || strcmp(TDUNDstatus,'IN')
        set (mainHandles.messages, 'String', 'Tune up Dump in Beam')
        display('Tune up Dump in Beam');
    end
end

% Prepare the Choose Methods button group
set(handles.uipanel5,'SelectionChangeFcn', {@selcbk,hObject});


% Prepare the Detector Set UP button group
set(handles.uipanel8,'SelectionChangeFcn',{@detectorSelcbk,hObject});


% Prepare the TEM Channel selection button group
set(handles.TEMchannelSelectionPanel,'SelectionChangeFcn',{@TEMchannelSelcbk,hObject});
guidata(hObject, handles); 


function selcbk(source,eventdata, hObject)
% Calback executed with Measurement radio buttons are changed
handles = guidata(hObject);%copy from guidata
mainHandles = guidata(handles.KM_main);% copy all main guidata struture
mainHandles.method = get(eventdata.NewValue,'String');% update method choice

display('... in selcbk');
display(['Button selected  ' mainHandles.method])
unInitialize(handles);

HK = [handles.text15, handles.text4, handles.text5, handles.edit4, handles.edit5,...
    handles.text7, handles.text8, handles.edit7, handles.edit8];
switch mainHandles.method
    case 'One Segment'
        set(mainHandles.messages,'String',{'One segment'; 'K measurement'; 'chosen'});
        set(handles.text8,'Visible','on');
        set(handles.edit8,'Visible','on');
        set(HK,'Visible','on');
        if ishandle(mainHandles.hMeasure)
            set(mainHandles.redoRefHandle,'Visible','on');
            set(mainHandles.redoTestHandle,'Visible', 'on');
        end
        mainHandles.fitMethod = 'midpoint';

    case 'Two Segment'
        set(mainHandles.messages,'String',{'Two segment'; 'K measurement'; 'chosen'});
        set(HK,'Visible','on');
        if ishandle(mainHandles.hMeasure)
            set(mainHandles.redoRefHandle,'Visible','off');
            set(mainHandles.redoTestHandle,'Visible', 'off');
        end
        mainHandles.fitMethod = 'inflection';

    case 'Energy Calibration'
        display('Energy calibration requested')
        set(mainHandles.messages,'String',{'Set up for'; 'Energy'; 'Calibration'});
        set(HK,'Visible','off');
end

guidata(handles.KM_main,mainHandles); % update the main gui guidata
guidata(hObject,handles);%copy to guidata


function detectorSelcbk(source,eventdata, hObject)
handles = guidata(hObject);%get local copy of guidata
mainHandles = guidata(handles.KM_main);% get main gui guidata struture
mainHandles.detector = get(eventdata.NewValue,'String');% update method choice
guidata(handles.KM_main, mainHandles); % update the main guidata
handles.detector = mainHandles.detector;% record to local guidata 
unInitialize(handles);
handles.detectorPanels = [...
    handles.detectorParameters;...
    handles.photodiodePanel];% array of handles for pop-up panels

switch mainHandles.detector
    case 'Photodiode'   % use photodiode
        display('Photodiode selected');
        mainHandles = photodiodeSetup(mainHandles);
    case 'Thermal'     % use a Thermal FEL energy sensor
        display('Thermal energy senosor selected')
        set(handles.TEMsensorNumber,...
            'String',num2str(lcaGetSmart('TEM:FEE1:REQUEST_POSITION.VAL')));

    case 'Gas Detector' % use  gas detector signal for flux
        display('Gas detector signal selected');

    case 'YAGXRAY TMIT'% use YAGXRAY "TMIT for flux
        display('YAGXRAY TMIT selected');
        % get an image to discover the current ROI
        data = profmon_grab('YAGS:DMP1:500');
        mainHandles.ROIxminYAG = data.roiX;
        mainHandles.ROIyminYAG = data.roiY;
        mainHandles.ROIxmaxYAG = data.roiX +data.roiXN;
        mainHandles.ROIymaxYAG = data.roiY + data.roiYN;
        mainHandles.ROIxmin = mainHandles.ROIxminYAG;
        mainHandles.ROIxmax = mainHandles.ROIxmaxYAG;
        mainHandles.ROIymin = mainHandles.ROIyminYAG;
        mainHandles.ROIymax = mainHandles.ROIymaxYAG;
        guidata(handles.KM_main,mainHandles); % update the main gui guidata
        numbersUpdate(handles);
        set(handles.detectorParameters,...
            'Title','YAGXRAY Setup',...
            'Visible','on');
    case 'Simulator'   % use kmDataSimulator for flux
        display('Simulation selected');
    case 'Dog Leg' % display dog leg energy versus programmed energy
        display('Dog Leg  beam diagnostics seleted')
        set(handles.detectorParameters,'Visible','off');
    case 'PR55' % use PR55 and appropriate energy bpm
        display('PR55 selected for detector');
        mainHandles.ROIxmin = mainHandles.ROIxminPR55;
        mainHandles.ROIxmax = mainHandles.ROIxmaxPR55;
        mainHandles.ROIymin = mainHandles.ROIyminPR55;
        mainHandles.ROIymax = mainHandles.ROIymaxPR55;
        set(handles.detectorParameters,...
            'Title','PR55 Setup',...
            'Visible','on');
    case 'NFOV'
        display('NFOV camera selected');
end

panelUpdate(handles); % update visibility of display of detector parameters
guidata(handles.KM_main,mainHandles); % update the main gui guidata
guidata(hObject,handles);%update  guidata

function TEMchannelSelcbk(source,eventdata, hObject)
handles = guidata(hObject);%get local copy of guidata
mainHandles = guidata(handles.KM_main);% get main gui guidata struture
mainHandles.TEMchannelSelected = get(eventdata.NewValue,'String');% update method choice
guidata(handles.KM_main, mainHandles); % update the main guidata
handles.TEMchannelSelectionPanel = mainHandles.TEMchannelSelected;% record to local guidata 
switch handles.TEMchannelSelectionPanel
    case 'Channel A'
        mainHandles.TEMdataPV = 'ELEC:FEE1:452:DATA';
        display('Channel A data selected');
    case 'Channel B'
        mainHandles.TEMdataPV = 'ELEC:FEE1:453:DATA';
        display('Channel B data selected');
end
panelUpdate(handles); % update visibility of display of detector parameters
guidata(handles.KM_main,mainHandles); % update the main gui guidata
guidata(hObject,handles);%update  guidata


% --- Outputs from this function are returned to the command line.
function varargout = kmInitializeNew_OutputFcn(hObject, eventdata, handles)



% --- Executes on "Scan Energy" button press in Initialize.
function ScanEnergyOnce(hObject, eventdata, handles)
% Make one scan of the selected energy range, collect flux data, update
% plots and store data in main gui guidata

mainHandles = guidata(handles.KM_main);% get main gui guidata struture

% scan energy and collect data
set (handles.ScanEnergyOnce,'String','Scanning...');
[F,  correctedEnergy, mainHandles]= kmEnergyScan(mainHandles); % this changes guidata
[Etrim, Ftrim] = kmSlopeTrim(correctedEnergy, F);
[mainHandles.edgeGeV, edgeSlopeF, dFdGeV, Eplot, Fplot] =...
     kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);
 
cla(mainHandles.scanAxis);
hold(mainHandles.scanAxis,'on');
plot(mainHandles.scanAxis, Eplot, Fplot,'r',   correctedEnergy, F,'+');
title(mainHandles.scanAxis, ['Spectral edge point at ' num2str(mainHandles.edgeGeV) ' [GeV]' ]);
ylabel(mainHandles.scanAxis,'Signal [arb]');
switch mainHandles.detector
    case 'Dog Leg'
        sigmaEnergy = std( mainHandles.correctedEnergyNS );
        title(mainHandles.scanAxis, ['Std dev ' num2str(sigmaEnergy) ' [GeV]' ]);
end

% put results in a structure for saving and reloading
mainHandles.results.Escan(mainHandles.scanCount) = struct(...
    'correctedEnergy', correctedEnergy,...
    'F', F,...
    'Etrim', Etrim,...
    'Ftrim', Ftrim,...
    'edgeGeV', mainHandles.edgeGeV,...
    'edgeSlopeF', edgeSlopeF,...
    'method', mainHandles.method,...
    'translation', mainHandles.translation);

mainHandles.scanCount = mainHandles.scanCount +1; % update the scan counter for data storage

kmSegmentPlot(mainHandles); % in case they have moved
set (handles.ScanEnergyOnce,'String','Scan Energy');
guidata(handles.KM_main, mainHandles);% update main guidata

% --- Executes on button press in Initialize.
function Initialize_Callback(hObject, eventdata, handles)
% Prepare the machine and diagnostics for K measurements.

% copy all main gui handles struture
mainHandles = guidata(handles.KM_main);

% update displays and button labels
unInitialize(handles); 
set(mainHandles.messages,'String','Initializing');
set(hObject,'String','Initializing');
kmSegmentPlot(mainHandles);

% Turn off beam
kmBeamOff(mainHandles);

% Set up translations
switch mainHandles.method
    case 'One Segment'
        mainHandles.translation(1:33) = mainHandles.translationOut;%prepare for moveout
        mainHandles.translation(mainHandles.refSegment) = 0;
        mainHandles.translation(mainHandles.testSegment) = mainHandles.translationOut ;
        mainHandles.chosenSegment = mainHandles.refSegment; % for simulator
        kmSegmentTranslate(mainHandles);% Move'em! Returns when complete (if debug=1, it will do 0)

    case 'Two Segment'
        mainHandles.translation(1:33) = mainHandles.translationOut;%prepare for moveout
        mainHandles.translation(mainHandles.refSegment) = 0;
        mainHandles.translation(mainHandles.testSegment) = 0;
        mainHandles.chosenSegment = mainHandles.testSegment; % for simulator
        kmSegmentTranslate(mainHandles);% Move'em! Returns when complete (if debug=1, it will do 0)
    case 'Energy Calibration'
        mainHandles = segmentLoad(mainHandles); % Set the peak current
        if ~mainHandles.debug         % Set the charge
            lcaPut(mainHandles.chargePV, mainHandles.energyCalibrationCharge)
        end
end

% Insert Kmono xtal (wait for segments to finish)
if mainHandles.debug~=1
    lcaPut('XTAL:FEE1:422:SELECT',2);
end

% Insert Photodiode  (wait for segments to finish)
if (mainHandles.debug~=1)&&strcmp(mainHandles.detector,'Photodiode')
    lcaPut('DIOD:FEE1:426:SELECT',2);
end

pause(2)
panelUpdate(handles);

% Turn beam on    
if mainHandles.debug~=1
    kmBeamOn(mainHandles);
end

% Set the bunch current
if ~mainHandles.debug % change peak current
    lcaPut('SIOC:SYS0:ML00:AO044',mainHandles.peakCurrent);
end


% Finish up
mainHandles.initStatus = 'Initialization Complete';
set(hObject,'String', 'Ready');
mainHandles.initButton = hObject; % pass the initialization button back to main gui
pause(1);
set(hObject,'BackgroundColor',[.5 .5 .5]);
set(mainHandles.Perform,'ForegroundColor',[0 0 0 ]);
set(mainHandles.messages,'String','Ready')

guidata(handles.KM_main,mainHandles);%copy to main guidata

function unInitialize(handles)
%handles = guidata(hObject); % get current handles
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.initStatus = 'Initialization Incomplete';
set(handles.Initialize,...
    'String','Intialize',...
    'BackgroundColor','g')

guidata(handles.KM_main,mainHandles);%copy to main guidata


% excutes when change to Lower Energy edit box
function edit1_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.GeVLow = str2double(get(hObject,'String'));
% Prepare the energy scan points
mainHandles.energySetPoints =...
    [mainHandles.GeVLow:mainHandles.energyStepMeV/1000:mainHandles.GeVHigh];
guidata(handles.KM_main,mainHandles); % update the main gui guidata




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


% executes when change to Upper Energy edit box
function edit2_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.GeVHigh = str2double(get(hObject,'String'));
% Prepare the energy scan points
mainHandles.energySetPoints =...
    [mainHandles.GeVLow:mainHandles.energyStepMeV/1000:mainHandles.GeVHigh];

guidata(handles.KM_main,mainHandles); % update the main gui guidata

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.energyStepMeV = str2double(get(hObject,'String'));
% Prepare the energy scan points
mainHandles.energySetPoints =...
    [mainHandles.GeVLow:mainHandles.energyStepMeV/1000:mainHandles.GeVHigh];
guidata(handles.KM_main,mainHandles); % update the main gui guidata


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



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
response = str2double(get(hObject,'String'));
response = abs(response);
display(['Range of scanning motion ' num2str(response) ]);
if response > 5
    response = 5;
    display('Maximum range for scan is +/- 5 mm')
    set(hObject,'String','5');
end
mainHandles.scanRange = response;
mainHandles.deltaPosition = 2*mainHandles.scanRange/...
        (mainHandles.noScanPts -1 );
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.noScanPts = str2double(get(hObject,'String'));
mainHandles.deltaPosition = 2*mainHandles.scanRange/...
        (mainHandles.noScanPts -1 );
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Visibility to zero 7/20/09
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.startSegment = str2double(get(hObject,'String'));

unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.testSegment = str2double(get(hObject,'String'));

unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.refSegment = str2double(get(hObject,'String'));

unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.nImages = str2double(get(hObject,'String'));
unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.ROIxmin = str2double(get(hObject,'String')); % update current values
switch mainHandles.detector % update detector specific values
    case 'YAGXRAY TMIT'
        mainHandles.ROIxminYAG = mainHandles.ROIxmin;
    case 'PR55'
        mainHandles.ROIxminPR55 = mainHandles.ROIxmin;
end

unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.ROIxmax = str2double(get(hObject,'String'));
switch mainHandles.detector % update detector specific values
    case 'YAGXRAY TMIT'
        mainHandles.ROIxmaxYAG = mainHandles.ROIxmax;
    case 'PR55'
        mainHandles.ROIxmaxPR55 = mainHandles.ROIxmax;
end
unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.ROIymin = str2double(get(hObject,'String'));
switch mainHandles.detector % update detector specific values
    case 'YAGXRAY TMIT'
        mainHandles.ROIyminYAG = mainHandles.ROIymin;
    case 'PR55'
        mainHandles.ROIyminPR55 = mainHandles.ROIymin;
end
unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
mainHandles.ROIymax = str2double(get(hObject,'String'));
switch mainHandles.detector % update detector specific values
    case 'YAGXRAY TMIT'
        mainHandles.ROIymaxYAG = mainHandles.ROIymax;
    case 'PR55'
        mainHandles.ROIymaxPR55 = mainHandles.ROIymax;
end
unInitialize(handles);
guidata(handles.KM_main,mainHandles); % update the main gui guidata


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
%
% Get an image of YAGXRAY or PR55 screen and display it so the ROI
% can be adjusted
%
mainHandles = guidata(handles.KM_main);
switch mainHandles.detector
    case 'YAGXRAY TMIT'
        imageGrab = profmon_measure('YAGS:DMP1:500',mainHandles.nImages,'doPlot',1, 'nBG',0,'doProcess',0);
    case 'PR55'
        imageGrab = profmon_measure('LOLA:LI30:555',mainHandles.nImages,'doPlot',1, 'nBG',0,'doProcess',0);
end
numbersUpdate(handles);

function numbersUpdate(handles)
% update the text boxes in the initialize window to the current values and
% update main Guidata.

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture

data = profmon_grab('YAGS:DMP1:500');
mainHandles.ROIxminYAG = data.roiX;
mainHandles.ROIyminYAG = data.roiY;
mainHandles.ROIxmaxYAG = data.roiX +data.roiXN;
mainHandles.ROIymaxYAG = data.roiY + data.roiYN;
mainHandles.ROIxmin = mainHandles.ROIxminYAG;
mainHandles.ROIxmax = mainHandles.ROIxmaxYAG;
mainHandles.ROIymin = mainHandles.ROIyminYAG;
mainHandles.ROIymax = mainHandles.ROIymaxYAG;

% update filter and Foil status
pvF1 = 'YAGS:DMP1:500:FLT1_PNEU';
pvF2 = 'YAGS:DMP1:500:FLT2_PNEU';
pvBe = 'YAGS:DMP1:500:FOIL1_PNEU';
pvNi = 'YAGS:DMP1:500:FOIL2_PNEU';
[ffStatus, ts] = lcaGet([{pvF1}; {pvF2}; {pvBe}; {pvNi}] );
mainHandles.ffStatus = ffStatus; 
    
set(handles.edit1,'String', mainHandles.GeVLow);
set(handles.edit2,'String', mainHandles.GeVHigh);
set(handles.edit3,'String', mainHandles.energyStepMeV);
set(handles.peakBunchCurrent,'String', mainHandles.peakCurrent);

set(handles.edit4,'String', mainHandles.scanRange);
set(handles.edit5,'String', mainHandles.noScanPts);
%set(handles.edit6,'String', mainHandles.startSegment);
set(handles.edit7,'String', mainHandles.testSegment);
set(handles.edit8,'String', mainHandles.refSegment);
set(handles.edit9,'String', mainHandles.nImages);
set(handles.edit10,'String', mainHandles.ROIymin);
set(handles.edit12,'String', mainHandles.ROIymax);
set(handles.edit13,'String', mainHandles.ROIxmin);
set(handles.edit14,'String', mainHandles.ROIxmax);


% attenuators
if strcmp( ffStatus{1}, 'IN');
    f1_att = 0.1;
else
    f1_att = 1.0;
end
if strcmp( ffStatus{2}, 'IN');
    f2_att = 0.01;
else
    f2_att = 1.0;
end
fNet_att = f1_att*f2_att;
set(handles.attenuation, 'String', num2str(fNet_att));

set(handles.BeFoil,'String', mainHandles.ffStatus{3});
set(handles.NiFoil,'String', mainHandles.ffStatus{4});

handles.gasAttenuationFactor =1;
handles.gasAttenuationFactor = lcaGetSmart('GDSA:FEE1:TATT:R_ACT');

guidata(handles.KM_main,mainHandles); % update the main gui guidata
    
function panelUpdate(handles)
%
% update the display of panels in this gui to reflect current choices
%
%
mainHandles = guidata(handles.KM_main);

% Blank all panels, then turn on the selected on
allDetectors = [handles.detectorParameters, ...
    handles.photodiodePanel,...
    handles.thermalSensor,...
    handles.gasDetectorPanel];

position = get(handles.detectorParameters,'Position');
set(allDetectors, 'Visible', 'off', 'Position',  position);

switch(mainHandles.detector)
    case 'YAGXRAY TMIT'
        set(handles.detectorParameters,'Visible','on');

    case 'Photodiode'
        set(handles.photodiodePanel, 'Visible', 'on');

        mainHandles.diodeMode = char( lcaGetSmart('ELEC:FEE1:DDQA:CMD') );
        modeLabel = ['Diode mode   ' mainHandles.diodeMode ];
        set(handles.mode, 'String',modeLabel);


        switch lcaGetSmart('DIOD:FEE1:426:SELECT')
            case 1
                set(handles.diodeStatus,'String','Diode Retracted');
            case 2
                set(handles.diodeStatus,'String','Canbera');
            case 3
                set(handles.diodeStatus,'String','Quadrant');
        end

        switch  lcaGetSmart('XTAL:FEE1:422:SELECT')
            case 1
                set(handles.text33,'String','Out' );
            case 2
                set(handles.text33,'String','In');
        end
        
        % transmission
        lcaPut('SATT:FEE1:320:EDES',mainHandles.XTALenergy); % set so  calc is correct
        netAttenuation = lcaGetSmart('GATT:FEE1:310:R_ACT') * lcaGetSmart('SATT:FEE1:320:RACT');
        set(handles.gasAttenuationFactor,'String',num2str(netAttenuation,'%5.1g' ) );


        handles.photodiode1 = lcaGetSmart('KMON:FEE1:421:ENRC');
        handles.photodiode2 = lcaGetSmart('KMON:FEE1:422:ENRC');
        handles.photodiode3 = lcaGetSmart('KMON:FEE1:423:ENRC');
        handles.photodiode4 = lcaGetSmart('KMON:FEE1:424:ENRC');

        set(handles.photodiode1textString,'String', ['Diode 1  ' num2str(handles.photodiode1,'%5.1f') ' uJ']);
        set(handles.photodiode2textString,'String', ['Diode 2  ' num2str(handles.photodiode2,'%5.1f') ' uJ']);
        set(handles.photodiode3textString,'String', ['Diode 3  ' num2str(handles.photodiode3,'%5.1f') ' uJ']);
        set(handles.photodiode4textString,'String', ['Diode 4  ' num2str(handles.photodiode4,'%5.1f') ' uJ']);

        % Digitizer parameters
        set(handles.text65,'String', ['BG start   ',    num2str( lcaGet('KMON:FEE1:421:BSTR') ) ]);
        set(handles.text67,'String', ['BG stop   ',      num2str(lcaGet('KMON:FEE1:421:BSTP') ) ]);
        set(handles.text66,'String', ['Pulse start   ',  num2str(lcaGet('KMON:FEE1:421:STRT') ) ]);
        set(handles.text68,'String', ['Pulse stop   ',   num2str(lcaGet('KMON:FEE1:421:STOP') ) ]); 
        set(handles.text70,'String', ['Offset   ',       num2str(lcaGet('KMON:FEE1:421:OFFS') ) ]);
        set(handles.text69,'String', ['cal coef.   ',    num2str(lcaGet('KMON:FEE1:421:CALI') ) ]); 
        set(handles.text71,'String', ['Scale [V]   ',    num2str(lcaGet('DIAG:FEE1:202:421:CFullScale') ) ]);
        set(handles.text72,'String', ['Offset [V]   ',   num2str(lcaGet('DIAG:FEE1:202:421:COffset') ) ]); 

        % 'SLIT:FEE1:XCEN_REQ.VAL';... % X center command mm
        % 'SLIT:FEE1:XWID_REQ.VAL';... % X width command mm
        % 'SLIT:FEE1:YCEN_REQ.VAL';... % Y center command mm
        % 'SLIT:FEE1:YWID_REQ.VAL'; % Y width command mm
        % slit
        set(handles.text61,'String',num2str(lcaGetSmart('SLIT:FEE1:XTRANS.C'),'%2.2f') ); % center
        set(handles.text59,'String',num2str(lcaGetSmart('SLIT:FEE1:XTRANS.D'),'%2.2f') ); % width
        set(handles.text62,'String',num2str(lcaGetSmart('SLIT:FEE1:YTRANS.C'),'%2.2f') );
        set(handles.text60,'String',num2str(lcaGetSmart('SLIT:FEE1:YTRANS.D'),'%2.2f') );

    case 'Thermal'
        set(handles.thermalSensor,'Visible', 'on');

    case 'Gas Detector'
        set(handles.gasDetectorPanel','Visible','on')

end
guidata(handles.initFigure,handles);%update  guidata


% --- Executes on button press in TEMgetData.
function TEMgetData_Callback(hObject, eventdata, handles)
% hObject    handle to TEMgetData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.TEMchannelA = lcaGetSmart('ELEC:FEE1:452:DATA')*1e6; %convert to uJ
handles.TEMchannelB = lcaGetSmart('ELEC:FEE1:453:DATA')*1e6; %convert to uJ
set(handles.TEMchannelAstring,'String', ['Channel A [uJ]  ' num2str(handles.TEMchannelA) ]);
set(handles.TEMchannelBstring,'String', ['Channel B [uJ]  ' num2str(handles.TEMchannelB) ]);
panelUpdate(handles);

% --- Executes on button press in gasDetectorGetData.
function gasDetectorGetData_Callback(hObject, eventdata, handles)
% hObject    handle to gasDetectorGetData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get current data
handles.gasDetector1PMT1 = lcaGetSmart('GDET:FEE1:241:ENRC'); % mJ
handles.gasDetector1PMT2 = lcaGetSmart('GDET:FEE1:242:ENRC'); % mJ
handles.gasDetector2PMT1 = lcaGetSmart('GDET:FEE1:361:ENRC'); % mJ
handles.gasDetector2PMT2 = lcaGetSmart('GDET:FEE1:362:ENRC'); % mJ

% update strings
set(handles.gasdet1pmt1String,'String', ['Det.1 PMT1  ' num2str(1e3*handles.gasDetector1PMT1,'%5.1f') ' uJ']);
set(handles.gasdet1pmt2String,'String', ['Det.1 PMT2  ' num2str(1e3*handles.gasDetector1PMT2,'%5.1f') ' uJ']);
set(handles.gasdet2pmt1String,'String', ['Det.2 PMT1  ' num2str(1e3*handles.gasDetector2PMT1,'%5.1f') ' uJ']);
set(handles.gasdet2pmt2String,'String', ['Det.2 PMT2  ' num2str(1e3*handles.gasDetector2PMT2,'%5.1f') ' uJ']);
panelUpdate(handles);


% --- Executes on button press in photodiodeGetData.
function photodiodeGetData_Callback(hObject, eventdata, handles)
% hObject    handle to photodiodeGetData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get current data
panelUpdate(handles);


function photodiodeNumber_Callback(hObject, eventdata, handles)
% hObject    handle to photodiodeNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of photodiodeNumber as text
%        str2double(get(hObject,'String')) returns contents of photodiodeNumber as a double


% --- Executes during object creation, after setting all properties.
function photodiodeNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to photodiodeNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function peakBunchCurrent_Callback(hObject, eventdata, handles)
% Set bunch current feedback

handles.peakCurrent = str2double(get(hObject, 'String') );
display(['Desired bunch current is set to ' num2str(handles.peakCurrent) ' A']);

mainHandles = guidata(handles.KM_main);% get main GUI guidata
mainHandles.peakCurrent = handles.peakCurrent;
guidata(handles.KM_main, mainHandles); % update main Guidata
% 
% if ~mainHandles.debug % change peak current
%     lcaPut('SIOC:SYS0:ML00:AO044',mainHandles.peakCurrent);
% end

guidata(handles.initFigure,handles);% update local guidata


% --- Executes during object creation, after setting all properties.
function peakBunchCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakBunchCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calibrateEnergy.
function calibrateEnergy_Callback(hObject, eventdata, handles)
% hObject    handle to calibrateEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%beamEnergyCalibrate('kmMain',handles.KM_main);% pass the main figure handle

function mainHandles = photodiodeSetup(mainHandles)
 % set up the photodiode in a standard way

        % defaults for Qamp
        mainHandles.BGstart = 1;
        mainHandles.BGstop = 150;
        mainHandles.pulseStart = 300;
        mainHandles.pulseStop = 499;
        mainHandles.cal = 1;
        mainHandles.offset = 0;
        mainHandles.AcqirisScale = 2;
        mainHandles.AcqirisOffset = -0.25;
        % Direct mode
        if ~strcmp(mainHandles.diodeMode, 'QAMP') % direct
            mainHandles.BGstart = 1;
            mainHandles.BGstop = 130;
            mainHandles.pulseStart = 130;
            mainHandles.pulseStop = 240;
            mainHandles.cal = -1;
            mainHandles.offset = 0;
            mainHandles.AcqirisScale = 0.5;
            mainHandles.AcqirisOffset = 0.05;
        end

        if ~mainHandles.debug
            %display('Setting  digitizer parameters');
            lcaPut('KMON:FEE1:421:BSTR', mainHandles.BGstart);
            lcaPut('KMON:FEE1:421:BSTP', mainHandles.BGstop);
            lcaPut('KMON:FEE1:421:STRT', mainHandles.pulseStart);
            lcaPut('KMON:FEE1:421:STOP', mainHandles.pulseStop);
            lcaPut('KMON:FEE1:421:CALI', mainHandles.cal);
            lcaPut('KMON:FEE1:421:OFFS', mainHandles.offset);
            lcaPut('DIAG:FEE1:202:421:CFullScale',mainHandles.AcqirisScale);
            lcaPut('DIAG:FEE1:202:421:COffset',   mainHandles.AcqirisOffset);
        end
        
function [oldStat, newStat] = xoutcorstatCheck()
% Check and possibly correct the XCOUTCORSTAT bit
%
% If all segments are online and all correctors are zero then
% XOUTCORSTAT should be 'OFF' = 0.

% Get present segment translations
taper = segmentTranslate();
offline = abs(taper)>10; % if more tha 10mm from axis, consider it off line
if any(offline)

end

% Get present corrector status
for q=1:33
    xcorPVs(q,1) = {sprintf( 'XCOR:UND1:%d80:BCTRL',q)};
    ycorPVs(q,1) = {sprintf( 'YCOR:UND1:%d80:BCTRL',q)};
    xcorstatPVs(q,1) = {sprintf('USEG:UND1:%d50:XOUTCORSTAT',q)};
end
xcors = lcaGet(xcorPVs);
ycors = lcaGet(ycorPVs);
xcorstats = lcaGet(xcorstatPVs); oldStat=xcorstats;
if any(xcors==0)&&any(ycors==0)&&(~any(offline))
    display('All correctors at zero and segments are online')
    display('Setting XOUTCORSTAT to OFF');
    xcorstats(33) = 'OFF'; newStat = xcorstats;
    lcaPut(xcorstatPVs, xcorstats);
else
        display('Some segments are offline. XOUTCORSTAT NOT VERIFIED');
        newStat = oldStat;
end
        
% --- Executes on button press in scanAngles.
function scanAngles_Callback(hObject, eventdata, handles)
% Scan X and Y angles in Test segment using angle bumps. Finds angles for
% maximum signal. Uses kmEnergyScan to the bulk of the work.

% Intialize
mainHandles = guidata(handles.KM_main);% get the main gui guidata

% Set up the flat energy profile, one energy point per angle to set
if ~isfield(mainHandles, 'edgeGeV')
    mainHandles.edgeGeV = mainHandles.bendEnergyGeV;
end
initEnergySetPoints = mainHandles.energySetPoints; % save for after angle scan
mainHandles.energySetPoints =...
    ones(mainHandles.nAnglePts,1)*mainHandles.edgeGeV;% set to last scan value

% Scan angles, collect data, update plots, and save data
mainHandles.angleBumpOn = 1; % turn on the angle bump flag

    % x angle scan
mainHandles.angleRange = mainHandles.angleRangeX;

mainHandles.angleDeltaX = ( max(mainHandles.angleRangeX)-...
    min(mainHandles.angleRangeX) )/(mainHandles.nAnglePts-1);

mainHandles.angleSetX = min(mainHandles.angleRangeX):...
    mainHandles.angleDeltaX:max(mainHandles.angleRangeX);

mainHandles.angleSetY = 0*mainHandles.angleSetX; 

[F, correctedEnergy, mainHandles] = kmEnergyScan( mainHandles);
angleSetXinit = mainHandles.angleSetX;
mainHandles.angleSetX(:) = 0; % turn off X scanning
mainHandles.angleFX = F; % save x angle data

    % y angle scan 
mainHandles.angleDeltaY = ( max(mainHandles.angleRangeY)-...
    min(mainHandles.angleRangeY) )/(mainHandles.nAnglePts-1);

mainHandles.angleSetY = min(mainHandles.angleRangeY):...
    mainHandles.angleDeltaY:max(mainHandles.angleRangeY);

[F, correctedEnergy, mainHandles] = kmEnergyScan ( mainHandles);
mainHandles.angleFY = F; % save x angle data

    % turn off angle scanning
mainHandles.angleBumpOn = 0; 

    % restore original energy and angle set points.
mainHandles.energySetPoints = initEnergySetPoints;
mainHandles.angleSetX = angleSetXinit;

% plot the combined x and y angle scans
cla(mainHandles.scanAxis);
plot(mainHandles.scanAxis,...
    mainHandles.angleSetX, mainHandles.angleFX,'+b',...
    mainHandles.angleFitX, mainHandles.signalFitX, '-b',...
    mainHandles.angleSetY, mainHandles.angleFY,'+g',...
    mainHandles.angleFitY, mainHandles.signalFitY, '-g')
text(.12, 0.3, ['XangleMax = ' num2str(mainHandles.angleBestX) ],'Units','inches');
text(.12, 0.1, ['YangleMax = ' num2str(mainHandles.angleBestY) ], 'Units','inches');
ylabel(mainHandles.scanAxis, 'Photodiode signal [arb]');
xlabel(mainHandles.scanAxis, 'Beam angle at center of segment [urad]');
title(mainHandles.scanAxis, ['Angle scan, segment: ' num2str(mainHandles.testSegment)]);

% Put data into results stucture for Analysis
% put results in a structure for saving and reloading
mainHandles.results.Ascan(mainHandles.angleScanCount) = struct(...
'angleSetX',    mainHandles.angleSetX,...
'angleFX',      mainHandles.angleFX,...
'angleFitX',    mainHandles.angleFitX,...
'angleBestX',   mainHandles.angleBestX,...
'angleSetY',    mainHandles.angleSetY,...
'angleFY',      mainHandles.angleFY,...
'angleFitY',    mainHandles.angleFitY,...
'angleBestY',   mainHandles.angleBestY,...
'testSegment',  mainHandles.testSegment...
);

mainHandles.angleScanCount = mainHandles.angleScanCount +1; % update the scan counter for data storage

 % update main gui guidata
guidata(handles.KM_main,mainHandles);

% 
% function wakeLossPerSegment = wakefield(peakCurrent)
% % return the wake field induced energy loss per electron per segment
% % Assume proportion to peak current.
% wakeLossPerSegment = 0.15 * peakCurrent/500; % MeV/segment, from Juhao 8/09
% display([ 'Wake loss/segment ' num2str(wakeLossPerSegment) ' MeV']);

function wakeLossPerSegment = wakefield(peakCurrent, chargepC)
% return the wake field induced energy loss per electron per segment

% Use Nuhn/Ding calculation
segmentLength = mean(diff(segmentCenters));
compressState = chargepC>25; % assume undercompressed for more than 25 pC, else overcompressed
wakeLossPerSegment = segmentLength * 0.001 *...
    util_UndulatorWakeAmplitude(abs(peakCurrent)/1000, chargepC, compressState);
display([ 'Wake loss/segment ' num2str(wakeLossPerSegment,2) ' MeV']);


function SRlossPerSegment = SRloss( electronEnergy)
% returns energy loss per segment [MeV] from spontaneous radiation in MeV
SRlossPerSegment = 0.63 * (electronEnergy/13.64)^2;
display(['SR loss/segment ', num2str(SRlossPerSegment) ' MeV']);

function mainHandles = segmentLoad( mainHandles)
% Move segments so that K values correspond to constant xray energy taking
% into account the spontaneous and wakefield energy loss.

% Save the present translations, to  be restored after calibrate
mainHandles.initTranslation = segmentTranslate;
for q=1:33
    pvKDES{q,1} = sprintf('USEG:UND1:%d50:KDES',q);
    pvXDES{q,1} = sprintf('USEG:UND1:%d50:XDES',q);
end

% Define index of special set of segments to use. Others will be extracted
mainHandles.segmentCalibration = 1:9;

% Get total energy loss in each segment. Extracted segments have only wake
% loss
energyLossPerSegment(1:33) = wakefield(mainHandles.peakCurrent,...
    1000*mainHandles.energyCalibrationCharge); % MeV loss per segment
energyLossPerSegment(mainHandles.segmentCalibration) = ...
    energyLossPerSegment(mainHandles.segmentCalibration) +...
        SRloss( mainHandles.bendEnergyGeV);

% Get energy profile [GeV]
mainHandles.energyProfile(1:33) = mainHandles.bendEnergyGeV; % initialize
for q=1:33 % energyProfile represents average energy in each segment.
    mainHandles.energyProfile(q) = mainHandles.energyProfile(q)...
        - 0.001*sum(energyLossPerSegment(1:q)) - 0.0005*energyLossPerSegment(q);
end

% Calculate the desired K profile K=0 for extracted segments)
deltaEnergy = mainHandles.energyProfile(1) - mainHandles.energyProfile;
mainHandles.Kprofile = zeros(1,33);
mainHandles.Kprofile(mainHandles.segmentCalibration) = mainHandles.KNominal -...
    ( (1+0.5*mainHandles.KNominal^2)/mainHandles.KNominal ) *...
    deltaEnergy(mainHandles.segmentCalibration)/mainHandles.bendEnergyGeV ;

% Obtain the desired XDES from KDES
calTranslation(1:33) = mainHandles.translationOut; % default
if mainHandles.debug~=1 % write a new KDES
    lcaPut( pvKDES(mainHandles.segmentCalibration ),...
        mainHandles.Kprofile(mainHandles.segmentCalibration) );
else
    pause(0.1)
    calTranslation(mainHandles.segmentCalibration) =...
        lcaGet( pvXDES(mainHandles.segmentCalibration) ); % Retrieve calculated XDES's
end
mainHandles.translation = calTranslation; % load values for kmSegmentTranslate

% Move segments to desired positions
kmSegmentTranslate(mainHandles)

% Reset the translations to pre calibration but don't move them
mainHandles.translation = mainHandles.initTranslation;



