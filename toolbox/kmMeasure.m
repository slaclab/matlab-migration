function varargout = kmMeasure(varargin)
% KMMEASURE M-file for kmMeasure.fig
%      KMMEASURE, by itself, creates a new KMMEASURE or raises the existing
%      singleton*.
%
%      H = KMMEASURE returns the handle to a new KMMEASURE or the handle to
%      the existing singleton*.
%
%      KMMEASURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KMMEASURE.M with the given input arguments.
%
%      KMMEASURE('Property','Value',...) creates a new KMMEASURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kmMeasure_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kmMeasure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kmMeasure

% Last Modified by GUIDE v2.5 06-Oct-2009 10:28:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kmMeasure_OpeningFcn, ...
                   'gui_OutputFcn',  @kmMeasure_OutputFcn, ...
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


% --- Executes just before kmMeasure is made visible.
function kmMeasure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kmMeasure (see VARARGIN)

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

    % Position to be relative to parent:
    parentPosition = getpixelposition(handles.KM_main);
    set(handles.KM_main,'Units','pixels'); % set to pixels if not already
    set(handles.measureFigure, 'Units','pixels');
    currentPosition = get(handles.measureFigure, 'Position');  % measureFigure is set in guide or exists
    % Set x to be to right of and share baseline with main gui, assumes units are pixels
    newX = parentPosition(1) + parentPosition(3) + 5;
    newY = parentPosition(2);
    %newY = parentPosition(2) + (parentPosition(4) - currentPosition(4));
    newW = 700; % currentPosition(3) ;
    newH = currentPosition(4);
    initFigureInitUnits = get(handles.measureFigure, 'Units');
    set(handles.measureFigure, 'Units','pixels','Position', [newX, newY, newW, newH]);
    set(handles.measureFigure,'Units',initFigureInitUnits); % return units
end
mainHandles.measureFigure = handles.measureFigure;
mainHandles.hMeasure = hObject; % handle to the measurement gui
mainHandles.outputAxis = handles.outputAxis; % axis in measurement gui
if mainHandles.measurementNo == 1
    set(handles.redoRef,'Visible','off');
    set(handles.redoTest,'Visible', 'off');
else
    set(handles.redoRef,'Visible','on');
    set(handles.redoTest,'Visible', 'on');
end
mainHandles.redoRefHandle = handles.redoRef;
mainHandles.redoTestHandle = handles.redoTest;

% set calibration method radiobuttons to current choice
set(handles.calMethodPanel,'SelectionChangeFcn',{@calMethodSelcbk,hObject});

switch(mainHandles.calMethod)
    case 'Resonance'
        set(handles.calMethodPanel,'SelectedObject',handles.calResonance);%
    case 'Mean'
        set(handles.calMethodPanel,'SelectedObject',handles.calMean);
    case 'Edge'
        set(handles.calMethodPanel,'SelectedObject',handles.calEdge);
end
guidata(handles.KM_main, mainHandles); % update the guidata for the main gui

% Choose default command line output for kmMeasure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = kmMeasure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startMeasurement.
function startMeasurement_Callback(hObject, eventdata, handles)
% 'Measure K' button: Perform the measurement. Hands off

mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
performMeasurement(hObject,mainHandles);

% --- Executes on button press in redoRef.
function redoRef_Callback(hObject, eventdata, handles)
% Remeasure the Ref segment and recalculate and replot the Delta K result

% Move segments for REF measurement
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
if (strcmp(mainHandles.method,'One Segment') )
    cla(mainHandles.outputAxis);
    mainHandles = measureRef(mainHandles);
else
    return;
end


% Recalculate and Replot Delta K
mainHandles = kmPlotResults(mainHandles);
guidata(handles.KM_main, mainHandles); % update the main gui guidata

% --- Executes on button press in redoTest.
function redoTest_Callback(hObject, eventdata, handles)
% Remeasure the TEST segment and recalculate and replot the Delta K result.

% Measure and plot the TEST segment
mainHandles = guidata(handles.KM_main);% copy all main gui handles struture
if (strcmp(mainHandles.method,'One Segment') )
    cla(mainHandles.outputAxis);
    mainHandles = measureTest(mainHandles);
else
    return;
end

% Recalculate and Replot Delta K
mainHandles = kmPlotResults(mainHandles);
guidata(handles.KM_main, mainHandles); % update the main gui guidata


% --- Executes on button press in abort.
function abort_Callback(hObject, eventdata, handles)
% hObject    handle to abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abort
abort = 1;
display('Aborting measurement')



function performMeasurement(hObject,mainHandles)
%
%  performMeasurement(hObject,mainHandles)
%
% Measure Delta K of selected pair of segments and update
% displays. Results are returned in main figure guidata.

% if initialization is incomplete, stop, otherwise continue
if (~strcmp(mainHandles.initStatus,'Initialization Complete'))
    display(mainHandles.initStatus)
    display('No measurement was performed')
    return
end
message = ['Measure segments ' ...
    num2str(mainHandles.testSegment) ' - ' ...
    num2str(mainHandles.refSegment)];
disp(message);
set(mainHandles.messages,'String',message);

%Definitions
ref_seg = mainHandles.refSegment;
mainHandles.kscanStart = -mainHandles.scanRange; % start translation position of horizontal scan [mm]
mainHandles.kscanStop = mainHandles.scanRange; % stop translation position of horizontal scan [mm]
method = mainHandles.method;
energySetPoints = mainHandles.energySetPoints;
%mainHandles.energySetPointsStart = mainHandles.energySetPoints;

% prepare output plot in main gui
set(mainHandles.KM_main,'CurrentAxes', mainHandles.scanAxis); % set to current so attention isn't grabbed.
cla(mainHandles.outputAxis);
xlim(mainHandles.outputAxis,[(min(energySetPoints)-.01) (max(energySetPoints)+.04)]);
xlabel(mainHandles.outputAxis,'Electron Energy [Gev]');
ylabel(mainHandles.outputAxis,'Signal');
hold(mainHandles.outputAxis,'on');

% One Segment Method
if (strcmp(method,'One Segment') )
    display('Starting One Segment Measurement')

    % Measure and plot the REF segment
    mainHandles = measureRef(mainHandles);

    % set ref seg to move out
    mainHandles.translation(mainHandles.refSegment)=mainHandles.translationOut;

    % Measure and plot the TEST segment
    mainHandles = measureTest(mainHandles);

    % Plot results
    mainHandles = kmPlotResults(mainHandles);

    %end of One Segment Method


    %Two Segment Method
elseif (strcmp(method, 'Two Segment') )
    display('Starting Two Segment Measurement')

    mainHandles.chosenSegment = mainHandles.testSegment;
    ipts = 1;                                %for plotting
    mainHandles.maxSlope(mainHandles.noScanPts) = 0;    %initialize

    % Measure and plot the TEST segment
    mainHandles = measureTest(mainHandles);

    % Plot results
    mainHandles = kmPlotResults(mainHandles);

else %end of two segment method
    display('Please select a K measurement method and Initialize')
    set(mainHandles.messages,'String',{'Not Set Up'; 'for'; 'K Measurement'});
end

kmSegmentPlot(mainHandles); % in case there is movement from another source
mainHandles.measurementNo = mainHandles.measurementNo + 1; % 
set(mainHandles.redoRefHandle,'Visible','on'); % Now allow redo of Test and Ref
set(mainHandles.redoTestHandle,'Visible', 'on');
guidata(mainHandles.KM_main, mainHandles); % update the guidata with results

function mainHandles = plotResults(mainHandles)
%
% Plot each segment results in a new results figure
%

DLL = [25 -25 0 0 ];% offset applied to new figure from previous [pixels]
figureOrigUnits = get(gcf,'Units');
set(gcf,'Units','pixels'); %make current figure units pixels
oldFigPosition = get(gcf,'Position');
set(gcf,'Units',figureOrigUnits);%put units back
newFigPosition = oldFigPosition + DLL;
ResultsFig = figure('Visible', 'off',...
    'Position',newFigPosition,...
    'Color', [.76,.87,.78],...
    'Name','Results',...
    'Units','pixels',...
    'Visible','on');% create new figure for Results plots
mainHandles.ResultsFig = ResultsFig;

mainHandles.Kref = lcaGet( sprintf('USEG:UND1:%d50:KACT',mainHandles.refSegment) );

% create the results plots
if strcmp(mainHandles.method, 'One Segment')

    % calculate delta K result
    [p,S] = polyfit(mainHandles.positionArray,mainHandles.edgeGeVArray,2);%fit data
    disc = sqrt(p(2)^2 - 4*p(1)*(p(3)-mainHandles.edgeGeVRef));
    if (p(1) == 0)
        xMatch = (mainHandles.edgeGeVRef-p(3))/p(2);
    else
        xMatch = (-p(2) - disc)/(2*p(1));% sign of disc chosen to get proper branch of parabola
    end
    deltaK = -xMatch * mainHandles.KTaper;% minus sign!

    %prepare delta K results in ResultsFig
    pdata.p = p;
    pdata.deltaK = deltaK;
    pdata.mainHandles.testSegment = mainHandles.testSegment;
    pdata.ref_seg = mainHandles.refSegment;
    pdata.mainHandles.edgeGeVArray = mainHandles.edgeGeVArray;
    pdata.mainHandles.positionArray = mainHandles.positionArray;
    pdata.mainHandles.edgeGeVRef = mainHandles.edgeGeVRef;
    pdata.xMatch = xMatch;

    xx = (pdata.mainHandles.positionArray(1):.05:pdata.mainHandles.positionArray(length(pdata.mainHandles.positionArray)));
    f = polyval(pdata.p,xx);
    plot(pdata.mainHandles.positionArray,pdata.mainHandles.edgeGeVArray,'--o',xx,f,'-');
    hold on;
    xx = [min(pdata.mainHandles.positionArray) max(pdata.mainHandles.positionArray)];
    yy = [pdata.mainHandles.edgeGeVRef pdata.mainHandles.edgeGeVRef];
    plot(xx,yy,'Color','r','LineWidth',3);
    xlabel('Segment position [mm]');
    ylabel('Spectrum edge energy [GeV]');
    text(.2,3.5,...
        ['Segment ' num2str(pdata.mainHandles.testSegment) ],...
        'Units','inches');
    text(.2,3.3,...
        ['Position for Match [mm]  ' num2str(pdata.xMatch,3) ],...
        'Units','inches');
    text(.2,3.1,...
        ['(Ktest - Kref)/K \times 10^{4} =  ' num2str(1e4*pdata.deltaK/mainHandles.KNominal,2) ],...
        'Units','inches');
    refLabel = ['Reference Segment ' num2str(mainHandles.refSegment) ];
    refLabel = [refLabel ', ' num2str(mainHandles.edgeGeVRef) ' +/- ' ];
    refLabel = [refLabel num2str(mainHandles.edgeGeVRefSTD,1)];
    text(-.2,pdata.mainHandles.edgeGeVRef+.002,...
        refLabel,...
        'Units','data');

    % update data to save
    mainHandles.deltaK = pdata.deltaK;
    mainHandles.xMatch = pdata.xMatch;
    
    % prepare measurement data for saving
    mainHandles.results.deltaK = struct(    'testSegment', mainHandles.testSegment,...
    'refSegment', mainHandles.refSegment,...
    'positionArray', mainHandles.positionArray,...
    'edgeGeVArray', mainHandles.edgeGeVArray,...
    'xMatch',  pdata.xMatch,...
    'deltaK', deltaK,...
    'Kref', mainHandles.Kref);
    
end

if strcmp(mainHandles.method,'Two Segment')

    pdata.mainHandles.testSegment = mainHandles.testSegment;
    pdata.ref_seg = mainHandles.refSegment;
    pdata.mainHandles.positionArray = mainHandles.positionArray;
    pdata.maxSlope = mainHandles.maxSlope;

    [p,S] = polyfit(pdata.mainHandles.positionArray,pdata.maxSlope,2);
    extremum = -0.5*p(2)/p(1); % mm
    deltaK = -extremum * mainHandles.KTaper ;%minus sign!
    pdata.xMatch = extremum;
    xx = (pdata.mainHandles.positionArray(1):.05:pdata.mainHandles.positionArray(length(pdata.mainHandles.positionArray)));
    f = polyval(p,xx);
    plot(pdata.mainHandles.positionArray,pdata.maxSlope,'--o',xx,f,'-');
    xlabel('Segment position [mm]');
    ylabel('Max slope of response curve [arb]');
    text(.2,1,...
        ['matched K for segment ' num2str(pdata.mainHandles.testSegment) ' at ' num2str(extremum,2) ' mm'],...
        'Units','inches');
    text(.2,.8,...
        ['(Ktest - Kref)/K \times 10^{4} =  ' num2str(1e4*deltaK/mainHandles.KNominal,2) ],...
        'Units','inches');
    %['\Delta K/K  [10^{4}]  = ' num2str(1e4*deltaK/mainHandles.KNominal,1) ],...
    text(.2,.6,...
        ['segments ' num2str(pdata.mainHandles.testSegment) ', ' num2str(pdata.ref_seg) ],...
        'Units','inches');
    
    % prepare measurement data for saving
    mainHandles.results.deltaK = struct(    'testSegment', mainHandles.testSegment,...
    'refSegment', mainHandles.refSegment,...
    'positionArray', mainHandles.positionArray,...
    'maxSlope', pdata.maxSlope,...
    'xMatch',  pdata.xMatch,...
    'deltaK', deltaK,...
    'Kref', mainHandles.Kref);
end

guidata(mainHandles.KM_main, mainHandles); % update the guidata with results



function mainHandles = measureRef(mainHandles)
% Moves, measures, updates plots and stores data for REF
global abort


% Initialize data arrays
mainHandles.edgeGeVRefn = [];

% move ref seg to IN position and all other segments OUT
mainHandles.chosenSegment = mainHandles.refSegment; % for simulator
mainHandles.translation(1:33) = mainHandles.translationOut;
mainHandles.translation(mainHandles.refSegment)=mainHandles.translationIn(mainHandles.refSegment);
kmBeamOff(mainHandles);
kmSegmentTranslate(mainHandles);% returns wnen motion is done
kmBeamOn(mainHandles);

% Measure and plot REF segment results
for nref = 1:mainHandles.measureRefRepeats
    [Fref, CorrectedEnergyRef] = kmEnergyScan(mainHandles); % updates plot with standard fit
    %GeVMidSlopeRef = KMGeVMidSlope(CorrectedEnergyRef, Fref); % for one segment method
    [Etrim, Ftrim] = kmSlopeTrim(CorrectedEnergyRef, Fref);
%     [edgeSlopeFRef, mainHandles.edgeGeVRefn(nref), dFdEref, mainHandles.FplotRef,mainHandles.EplotRef]...
%         = inflectionPoint3( Ftrim, Etrim);
    mainHandles.fitMethod = 'midpoint';
    [mainHandles.edgeGeVRefn(nref), edgeSlopeFRef, dFdEref, mainHandles.EplotRef, mainHandles.FplotRef]...
        = kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);
    scan(nref) =  struct(...
        'correctedEnergyRef', CorrectedEnergyRef,...
        'Fref',Fref,...
        'EplotRef', mainHandles.EplotRef,...
        'FplotRef', mainHandles.FplotRef); % for data saving
    if abort == 1;
        abort = 0;
        return
    end
end
mainHandles.correctedEnergyRef = CorrectedEnergyRef;
mainHandles.edgeGeVRef = mean(mainHandles.edgeGeVRefn);% average multiple ref measurements
mainHandles.edgeGeVRefSTD = std(mainHandles.edgeGeVRefn);

plot(mainHandles.outputAxis, mainHandles.EplotRef,mainHandles.FplotRef,...
    'Color','r','LineWidth',3); % Plot REF with bold colors
hold(mainHandles.outputAxis, 'on');
plot(mainHandles.outputAxis,CorrectedEnergyRef, Fref,'mo');
xlabel(mainHandles.outputAxis,'E Beam Energy [GeV]')
ylabel(mainHandles.outputAxis, 'Photon flux [arb]')
title(mainHandles.outputAxis,...
    ['U' num2str(mainHandles.refSegment) ' REF edge energy  ' num2str(mainHandles.edgeGeVRef) '  [GeV]' ]);

% Copy Ref measurement data to mainHandles.results for saving
mainHandles.results.Ref = struct(...
    'edgeGeVRef', mainHandles.edgeGeVRef,...
    'edgeGeVRefSTD', mainHandles.edgeGeVRefSTD,...
    'scan', scan);
           

function mainHandles = measureTest(mainHandles)
% Moves, meaures, updates plots and stores data for TEST
% Handles both one-segment and two-segment methods. In two segment method
% TEST is the first of the pair of segments.
global abort

% Initialize data arrays
mainHandles.edgeGeVArray = [];
mainHandles.positionArray = [];
mainHandles.chosenSegment = mainHandles.testSegment;

% K Scan the test segment
if strcmp(mainHandles.method, 'One Segment')
    mainHandles.translation(mainHandles.refSegment)=mainHandles.translationOut; % set Ref to move out
    kmBeamOff(mainHandles); % turn off beam for ref to be removed.
end
ipts = 1;
mainHandles.energySetPointsStart = mainHandles.energySetPoints;
for position = mainHandles.kscanStart:mainHandles.deltaPosition:mainHandles.kscanStop % measure a segment
    mainHandles.translation(mainHandles.testSegment)= position;
    kmSegmentTranslate(mainHandles); % moves test in (and ref  out). Return when motion is complete
    kmBeamOn(mainHandles);

    %measure test segment spectrum at position
    Kn = mainHandles.KNominal; 
    mainHandles.energySetPoints =... % shift range with positon for constant lambda
        mainHandles.energySetPointsStart + (2*Kn / (2+Kn^2) )*mainHandles.bendEnergyGeV*position*mainHandles.KTaper;
    [F,CorrectedEnergy, mainHandles] =  kmEnergyScan(mainHandles); % get and plot data
    [Etrim, Ftrim] = kmSlopeTrim(CorrectedEnergy, F);
    
    %     [ edgeSlopeF, edgeGeV(ipts), dFdE(ipts), Fplot(ipts,:), Eplot(ipts,:)]...
    %         = inflectionPoint3( Ftrim, Etrim);
    switch mainHandles.method
        case 'One Segment'
            mainHandles.fitMethod = 'midpoint';
            [edgeGeV(ipts), edgeSlopeF, dFdE(ipts), Eplot(ipts,:), Fplot(ipts,:) ]...
                = kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);

        case 'Two Segment'
            mainHandles.fitMethod = 'inflection';
            %         [ edgeSlopeF, mainHandles.edgeGeVArray(ipts), maxSlopeInv(ipts), Fplot(ipts,:), Eplot(ipts,:)]...
            %             = inflectionPoint3( Ftrim, Etrim);
            [edgeGeV(ipts), edgeSlopeF, maxSlopeInv(ipts), Eplot(ipts,:), Fplot(ipts,:) ]...
                = kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);
            mainHandles.maxSlope = 1./maxSlopeInv; % maxSlope is dF/dE at inflection point.
    end

    mainHandles.edgeGeVArray(ipts) = edgeGeV(ipts);

    hold(mainHandles.outputAxis,'on');
    if strcmp(mainHandles.method,'One Segment')
        plot(mainHandles.outputAxis, mainHandles.EplotRef,mainHandles.FplotRef,...
            'Color','r','LineWidth',3); %Highlight output from mainHandles.refSegment
    end
    xlabel(mainHandles.outputAxis,'E Beam Energy [GeV]')
    ylabel(mainHandles.outputAxis, 'Photon flux [arb]')
    title(mainHandles.outputAxis,['TEST: ' num2str(mainHandles.testSegment) ',  REF: ' num2str(mainHandles.refSegment) ]);
    

    for np=1:ipts
        plot(mainHandles.outputAxis,Eplot(np,:),Fplot(np,:),'g')
    end

    mainHandles.positionArray(ipts) = position;%for results plotting
    
    if strcmp(mainHandles.method, 'Two Segment')
        axes(mainHandles.outputAxis);
        xlim([(min(mainHandles.energySetPoints)-.01) (max(mainHandles.energySetPoints)+.04)]);
        xlabel('Electron Energy [Gev]');
        ylabel('Photons per shot');
        [peakSignal,peakIndex] = max(F);
        energyAtPeak = CorrectedEnergy(peakIndex);

%         text(.2,2,...
%             ['Energy at mid-slope' num2str(mainHandles.edgeGeV) ],...
%             'Units','inches');
%         text(.2,1.8,...
%             ['fwhm ' num2str(fwhm(CorrectedEnergy,F))],...
%             'Units','inches');

        if strcmp(mainHandles.method, 'One Segment')
            text(.2,1.6,...
                ['segment ' num2str(mainHandles.testSegment)],...
                'Units','inches');
            text(.2,1.4,...
                ['average energy' num2str(mainHandles.edgeGeV)],...
                'Units','inches');
        else
            text(.2,1.6,...
                ['segments ' num2str(mainHandles.testSegment) ',' num2str(mainHandles.refSegment)],...
                'Units','inches');
        end
        hold off;
    end

    scan(ipts) =  struct(... % for data saving
        'position', position,...
        'energySetPoints', mainHandles.energySetPoints,...
        'F', F,...
        'correctedEnergy', CorrectedEnergy,...
        'edgeSlopeF', edgeSlopeF,...
        'edgeGeV', edgeGeV(ipts),...
        'Fplot',Fplot(ipts,:),...
        'Eplot',Eplot(ipts,:) ); % for data saving
    ipts = ipts+1;
    
    % Handle ABORT command
    pause(.25); %for event queue processing
    if abort == 1;
        abort = 0;
        return
    end

end % end of K Scan of test segment

% Copy Test measurement data to mainHandles.results
mainHandles.results.Test = struct(...
    'scan', scan);

mainHandles.energySetPoints = mainHandles.energySetPointsStart;


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% elog/save
mainHandles = guidata(handles.KM_main);% get main gui guidata

% Send to elog whatever is open
if isfield(mainHandles, 'ResultsFig')
  if ishandle(mainHandles.ResultsFig)
    util_printLog(mainHandles.ResultsFig); % print results window to elog
  end
end
if isfield(mainHandles, 'measureFigure')
  if ishandle(mainHandles.measureFigure)
    util_printLog(mainHandles.measureFigure); % print measurement output axis
  end
end

% Save all the data 
kmSaveData(handles)


% --- Executes on button press in calibrateEnergy.
function calibrateEnergy_Callback(hObject, eventdata, handles)
% Calibrate the bend magnet energy against the K monochromator passband
% energy using the "special K" configuration of the undulators.

mainHandles = guidata(handles.KM_main);% copy all main gui guidata struture
if ~strcmp(mainHandles.method,'Energy Calibration')
    display('Please select a Energy Calibration and Initialize')
    set(mainHandles.messages,'String',{'Not Set Up'; 'for Energy'; 'Calibration'});
    return;
end
                         
switch mainHandles.calMethod   % measures using one of three methods
    case 'Resonance'
        mainHandles = calResonance(mainHandles);
        mainHandles.results.calCentroid(mainHandles.calCentroidCount) = mainHandles.calCentroid;
        mainHandles.calCentroidCount = mainHandles.calCentroidCount + 1;
    case 'Mean'
        %mainHandles = calDonut(mainHandles);
        mainHandles = calMean(mainHandles);
        mainHandles.calMeanCount = mainHandles.calMeanCount + 1;
    case 'Edge'
        mainHandles = calSpectralEdge(mainHandles);
        mainHandles.results.calSpectralEdge(mainHandles.calEdgeCount) = mainHandles.calSpectralEdge;
        mainHandles.calEdgeCount = mainHandles.calEdgeCount + 1;
end

% Display and save results
guidata(mainHandles.KM_main, mainHandles); % update the guidata with results


function mainHandles = calResonance(mainHandles)
% calibrate bend energy using a pinhole slit 

% adjust slits
slitCalWidth = 1; % width = height  [mm]
if ~mainHandles.debug
    lcaPut('SLIT:FEE1:XWID_REQ.VAL', slitCalWidth);
    lcaPut('SLIT:FEE1:YWID_REQ.VAL', slitCalWidth);
end
% scan energy
[F, correctedEnergy, mainHandles] = kmEnergyScan ( mainHandles);
% extract centroid
calCentroid = sum(F.*correctedEnergy)/sum(F);

% plot result in Measurement window
centroidLineX = [calCentroid, calCentroid];
centroidLineY = [min(F), max(F)];

cla(mainHandles.outputAxis);
axis(mainHandles.outputAxis, 'auto');
plot(mainHandles.outputAxis, correctedEnergy, F,'+', centroidLineX, centroidLineY, '-.r')
title(mainHandles.outputAxis,['Energy centroid at ' num2str(calCentroid,'%8.4f') ]);
xlabel(mainHandles.outputAxis,'Corrected Energy [GeV]');
ylabel(mainHandles.outputAxis,'Flux Signal [arb]');

pause(3);
button = questdlg('Accept latest centroid measurement?');
switch button
    case 'Yes'
        if isfield(mainHandles, 'calCentroid')
            display(['Old centroid measurement: ', num2str(mainHandles.calCentroid, 8) 'GeV']);
        end
        mainHandles.calCentroid = calCentroid;
        display(['New centroid measurement ' num2str(mainHandles.calCentroid, 8) 'GeV']);
    case 'No'
        if isfield(mainHandles, 'calCentroid')
            display(['Keeping previous centroid '  num2str(mainHandles.calCentroid, 8)  'GeV'] );
        else
            display('No centroid measurement has been accepted yet');
        end
    case 'Cancel'
        if isfield(mainHandles, 'calCentroid')
            display(['Keeping previous centroid '  num2str(mainHandles.calCentroid, 8)  'GeV'] );
        else
            display('No centroid measurement has been accepted yet');
        end
end

function mainHandles = calDonut(mainHandles)
% Donut: use DI to image spot, adjust energy until donut goes away wait for
% user to come up with answer, then read beam energy fromdialogue box

function mainHandles = calMean(mainHandles)
% Just use the mean corrected energy, no weighting
[F, correctedEnergy, mainHandles] = kmEnergyScan ( mainHandles);
calMean = mean(correctedEnergy);
Eplot = [calMean calMean];
Fplot = [min(F) max(F)];

cla(mainHandles.outputAxis);
plot(mainHandles.outputAxis, correctedEnergy, F,'+', Eplot, Fplot, '-r');
title(['Mean electron energy ' num2str(calMean,'%8.4f') ]);
xlabel('Measured Energy [GeV]');
ylabel('Flux Signal [arb]');

button = questdlg('Accept latest edge measurement?');
switch button
    case 'Yes'
        if isfield(mainHandles,'calMean')
            display(['Old mean measurement: ', num2str(mainHandles.calMean, 6) ' GeV']);
        end
        mainHandles.calMean = calMean;
        display(['New mean measurement: ' num2str(mainHandles.calMean, 6) ' GeV']);
    case 'No'
        if isfield(mainHandles, 'calSpectralEdge')
            display(['Keeping previous edge '  num2str(mainHandles.calSpectralEdge, 6)  ' GeV'] );
        else
            display('No edge measurement has been accepted yet');
        end
    case 'Cancel'
        if isfield(mainHandles, 'calSpectralEdge')
            display(['Keeping previous edge '  num2str(mainHandles.calSpectralEdge, 6)  ' GeV'] );
        else
            display('No edge measurement has been accepted yet');
        end
end

function mainHandles = calSpectralEdge(mainHandles)
% Spectral edge:  find rising edge

% scan energy and collect data
[F, correctedEnergy, mainHandles] = kmEnergyScan ( mainHandles);
[Etrim, Ftrim] = kmSlopeTrim(correctedEnergy, F);
mainHandles.fitMethod = 'midpoint';
[mainHandles.edgeGeV, edgeSlopeF, dFdGeV, Eplot, Fplot ]...
    = kmEdgeFind(Etrim,Ftrim, mainHandles.fitMethod);
calSpectralEdge = mainHandles.edgeGeV;

cla(mainHandles.outputAxis);
plot(mainHandles.outputAxis, correctedEnergy, F,'+', Eplot, Fplot, '-r')
title(['Spectral edge point at ' num2str(calSpectralEdge,'%8.4f') ]);
xlabel('Measured Energy [GeV]');
ylabel('Flux Signal [arb]');

button = questdlg('Accept latest edge measurement?');
switch button
    case 'Yes'
        if isfield(mainHandles,'calSpectralEdge')
            display(['Old edge measurement: ', num2str(mainHandles.calSpectralEdge, 6) ' GeV']);
        end
        mainHandles.calSpectralEdge = calSpectralEdge;
        display(['New edge measurement: ' num2str(mainHandles.calSpectralEdge, 6) ' GeV']);
    case 'No'
        if isfield(mainHandles, 'calSpectralEdge')
            display(['Keeping previous edge '  num2str(mainHandles.calSpectralEdge, 6)  ' GeV'] );
        else
            display('No edge measurement has been accepted yet');
        end
    case 'Cancel'
        if isfield(mainHandles, 'calSpectralEdge')
            display(['Keeping previous edge '  num2str(mainHandles.calSpectralEdge, 6)  ' GeV'] );
        else
            display('No edge measurement has been accepted yet');
        end
end
    
function calMethodSelcbk(source, eventdata, hObject)
handles = guidata(hObject);%get local copy of guidata
mainHandles = guidata(handles.KM_main);% get main gui guidata struture
mainHandles.calMethod = get(eventdata.NewValue,'String');% update method choice
guidata(handles.KM_main, mainHandles); % update the main guidata
handles.calMethodPanel = mainHandles.calMethod;% record to local guidata
guidata(hObject, handles); % update local guidata
