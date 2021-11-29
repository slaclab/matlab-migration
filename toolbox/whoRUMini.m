function varargout = whoRUMini(varargin)
% WHORUMINI is a GUI for plotting pulse-synchronous KLYS phase and
% related data to see by eye which klytsron might be causing FEL
% jitter.
%

% -----------------------------------------------------------
% Auth. I think Lauren originally. 
% Mod: Greg White, 1-Sep-2017. Many parts re-written to avoid
% errors from hard coded indexes that become invalid, convert from 
% AIDA to MEME, out of memory errors, etc. Still much could be 
% improved but now works.
% ===========================================================
 
% Last Modified by GUIDE v2.5 05-Sep-2017 16:00:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @whoRUMini_OpeningFcn, ...
                   'gui_OutputFcn',  @whoRUMini_OutputFcn, ...
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


function whoRUMini_OpeningFcn(hObject, eventdata, handles, varargin)

global klysNames
global klysPhase_pvns

whoRU_const;
warning backtrace off;  % Don't give files and function names of warnings

handles.output = hObject;

lcaSetTimeout(0.1);
lcaSetRetryCount(200);
lcaSetSeverityWarnLevel(14);

% Set colors used used for plots and dock axes into one figure
set(0,'DefaultAxesColorOrder',[1 0 0;1 0.566 0;1 0.914 0.038;0.694 1 0.126;...
0.273 0.588 0.342;0.323 0.786 0.868;0.756 0.628 1;0.050 0.395 0.930]) ;
set(0,'DefaultFigureColor','white')

% String array of all the klystron names. 1st 2 chars, eg 21
% defines sector.
klysNames = { '20-5 (TCAV0)' '20-6 (Gun)' '20-7 (L0-A)' '20-8 (L0-B)' ...
    '21-1 (L1-S)' '21-2 (L1-X)' '21-3' '21-4' '21-5' '21-6' '21-7' '21-8' ...
    '22-1' '22-2' '22-3' '22-4' '22-5' '22-6' '22-7' '22-8' ...
    '23-1' '23-2' '23-3' '23-4' '23-5' '23-6' '23-7' '23-8' ...
    '24-1' '24-2' '24-3' '24-4' '24-5' '24-6'        '24-8 (TCAV3)' ...
    '25-1' '25-2' '25-3' '25-4' '25-5' '25-6' '25-7' '25-8' ...
    '26-1' '26-2' '26-3' '26-4' '26-5' '26-6' '26-7' '26-8' ...
    '27-1' '27-2' '27-3' '27-4' '27-5' '27-6' '27-7' '27-8' ...
    '28-1'        '28-3' '28-4' '28-5' '28-6' '28-7' '28-8' ...
    '29-1' '29-2' '29-3' '29-4' '29-5' '29-6' '29-7' '29-8' ...
    '30-1' '30-2' '30-3' '30-4' '30-5' '30-6' '30-7' '30-8' } ;        

% Ask MEME DS for the names of Beam Rate BSA phase PVs of KLYStrons
% in LCLS-I (CU_HXR).
klysPhase_pvns = meme_names('name','KLYS:%:%:PHAS_FASTHSTBR','lname','CU_HXR')';
% Override the first 6 names:
klysPhase_pvns(1) = {'TCAV:IN20:490:PHSTBR'} ;
klysPhase_pvns(2) = {'GUN:IN20:1:PHSTBR'} ;
klysPhase_pvns(3) = {'ACCL:IN20:300:L0A_PHSTBR'} ;
klysPhase_pvns(4) = {'ACCL:IN20:400:L0B_PHSTBR'} ;
klysPhase_pvns(5) = {'ACCL:LI21:1:L1S_PHSTBR'} ;
klysPhase_pvns(6) = {'ACCL:LI21:180:L1X_PHSTBR'} ;

% Set boolean saying whether there is acquired data.
handles.dataAcquired=false;

try
    % Application constants initialization
    % handles=appInit(hObject,handles);
    
    % Add Menu Bar
    %
    % The follow adds File and Controls menu bar operations to the GUI
    %
    set(gcf,'MenuBar','None');
    
    % Add Files menubar menu
    %
    handles.menuFile=uimenu('Label','File');
    
    % File->View Log
    handles.menuFile_itemViewLog=...
        uimenu(handles.menuFile,'Label','Execution Log...');
    set(handles.menuFile_itemViewLog,'Callback',...
        {@viewLog_Callback,handles});

    % File->Screenshot
    handles.menuFile_itemScreenShot=...
        uimenu(handles.menuFile,'Label','Screen Shot to Physics Log');
    set(handles.menuFile_itemScreenShot,'Callback',...
        {@screenShot_Callback,handles});

    % File->Quit
    handles.menuFile_itemQuit=...
        uimenu(handles.menuFile,'Label','Quit WhoRU');
    set(handles.menuFile_itemQuit,'Callback',...
        {@quit_Callback,handles});

    % Add Help menubar item
    %
    handles.menuHelp=uimenu('Label','Help');
    
    % Help->Ad-ops Wiki entry [of wirescans]
    handles.menuHelp_itemWiki=...
        uimenu(handles.menuHelp,'Label','Ad-ops wiki entry...');
    set(handles.menuHelp_itemWiki,'Callback',...
        {@help_Callback,handles});
   
    % Log successful application launch. 
    lprintf(STDOUT,'Instance of WhoRU GUI launched successfully');

catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,3)  
       lprintf(STDERR, '%s', ex.getReport());
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Could not complete GUI initialization. %s', ...
            ex.message)));
end

% Update handles structure
guidata(hObject, handles); 

function varargout = whoRUMini_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


function edit1_Callback(hObject, eventdata, handles)


function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function CollectDataButton_Callback(hObject, eventdata, handles)

whoRU_const;

% Recalling global variables:
global klysPhas
global klysBeamVolts
global DL1EnergyBPM
global BC1EnergyBPM
global BC2EnergyBPM
global DL2EnergyBPM
global GDET1
global GDET2
global axesRange
global klysPhase_pvns
global comp
global range
global timeStamp

set(handles.CollectDataButton, 'String', 'Getting it...') ;

pause(.1) ;

% Getting a time stamp.
timeStamp = now ;

GDET1_pvn='GDET:FEE1:241:ENRCHSTBR';
GDET2_pvn='GDET:FEE1:361:ENRCHSTBR';

% Energy BPM BSA at Beam Rate PV names
DL1EnergyBPM_pvn='BPMS:IN20:731:XHSTBR';
BC1EnergyBPM_pvn='BPMS:LI21:233:XHSTBR';
BC2EnergyBPM_pvn='BPMS:LI24:801:XHSTBR';
DL2EnergyBPM_pvn='BPMS:LTU1:250:XHSTBR';
% 
% Klystron Beam Voltage BSA at Beam Rate PV names
klysBeamVolt_pvns= {'KLYS:LI20:K5:VOLTHSTBR' 'KLYS:LI20:K6:VOLTHSTBR' ...
    'KLYS:LI20:K7:VOLTHSTBR' 'KLYS:LI20:K8:VOLTHSTBR' ...
    'KLYS:LI21:K1:VOLTHSTBR' 'KLYS:LI21:K2:VOLTHSTBR' } ;

% % Collecting klystron data. Each klystron is one row of data (e.g.
% % klysPhas(4,1:2800) is klystron 21-8's buffered BSA data).
%
try
    % Assemble a matrix of PV names:
    %
    % First the Beam Voltage PV names - so they appear at the top of
    % the Plot Station menu.  
    matrixOfNames=klysBeamVolt_pvns;
    M_klysBeamVolt=length(klysBeamVolt_pvns);
    % Add Klys Phases
    matrixOfNames=[matrixOfNames klysPhase_pvns];
    M_klysPhase=length(klysPhase_pvns);
    % Add FEL Gas Detector PVs
    m=M_klysBeamVolt+M_klysPhase;
    m=m+1; GDET1e=m; matrixOfNames(GDET1e)={GDET1_pvn};
    m=m+1; GDET2e=m; matrixOfNames(GDET2e)={GDET2_pvn};
    % Add Energy BPM PVs
    m=m+1; DL1EBPMe=m; matrixOfNames(DL1EBPMe)={DL1EnergyBPM_pvn};
    m=m+1; BC1EBPMe=m; matrixOfNames(BC1EBPMe)={BC1EnergyBPM_pvn};
    m=m+1; BC2EBPMe=m; matrixOfNames(BC2EBPMe)={BC2EnergyBPM_pvn};
    m=m+1; DL2EBPMe=m; matrixOfNames(DL2EBPMe)={DL2EnergyBPM_pvn};

    % Collecting all the values, all on same 2800 pulses (at least in theory)
    matrixOfValues = lcaGetSmart(matrixOfNames) ;

    % Define blocks of the matrix of values as the specific aspects of
    % the machine corresponding to the PV names defined above.
    % 
    klysBeamVolts = matrixOfValues(1:M_klysBeamVolt,1:2800) ;
    klysPhas = matrixOfValues((M_klysBeamVolt+1):(M_klysBeamVolt+M_klysPhase),1:2800) ;
    GDET1 = matrixOfValues(GDET1e,1:2800) ;
    GDET2 = matrixOfValues(GDET2e,1:2800) ;
    DL1EnergyBPM = matrixOfValues(DL1EBPMe,1:2800) ;
    BC1EnergyBPM = matrixOfValues(BC1EBPMe,1:2800) ;
    BC2EnergyBPM = matrixOfValues(BC2EBPMe,1:2800) ;
    DL2EnergyBPM = matrixOfValues(DL2EBPMe,1:2800) ;


    % All this is just going to make scaling my axes in plots easier later on.
    beamRate = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE') ; 
    timePerPulse = 1/beamRate ;

    % Here I reverse the axes so they'll plot from -~23 seconds in the past to
    % current 0 seconds. 
    axesRange = (-(2800-1):0)*timePerPulse ;

    % This is the range of points I want to plot. It's 2800 because that is the
    % number of points in the BSA buffered data.
    range = 1:2800 ;


    % Getting the current klystron compliment (help with graphing later). I
    % alter the dimensions of this matrix to make it consistent with the
    % klystron phase matrices etc. AKA, comp(1) is 20-5's activation status.
    comp = lcaGetSmart( 'CUDKLYS:MCC0:ONBC1SUMY' ) ;
    comp([1,2,3,4,39,89,90]) = [ ] ;

    set(handles.CollectDataButton, 'String', 'Got it!') ;
    pause(.3)
    set(handles.CollectDataButton, 'String', 'Get Data') ;

    % Save lengths of block matrices for later.
    handles.M_klysBeamVolt = M_klysBeamVolt;
    handles.M_klysPhase = M_klysPhase;

    % Record that we have successfully acquired data.
    handles.dataAcquired=true;

catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,4)  
        fprintf(1, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(1, 'Problem getting BSA data. %s', ex.message)));
end

guidata(hObject, handles);

% Plots the Energy BPM's selected with the checkboxes below the button.
function BPMPlotButton_Callback(hObject, eventdata, handles)

whoRU_const;

global DL1EnergyBPM
global BC1EnergyBPM
global BC2EnergyBPM
global DL2EnergyBPM
global axesRange
global range
global timeStamp

% These variables are just going to make my awkward series of "if"
% statements later seem a little less awkward.
DL1Logic = 0 ;
BC1Logic = 0 ;
BC2Logic = 0 ;
DL2Logic = 0 ;
namesStringArray = { 'DL1 Energy BPM' 'BC1 Energy BPM' 'BC2 Energy BPM' 'DL2 Energy BPM' } ;

try
    if ( ~handles.dataAcquired )
        error('WRU:NODATA', lprintf( STDERR, NOACQMSG));
    end

    % This sets the logic values to 1 if the check boxes are selected.
    if (get(handles.DL1EnergyPlotSelect, 'Value') == ...
        get(handles.DL1EnergyPlotSelect, 'Max'))
        DL1Logic = 1;
    end

    if (get(handles.BC1EnergyPlotSelect, 'Value') == ...
        get(handles.BC1EnergyPlotSelect, 'Max'))
        BC1Logic = 1;
    end

    if (get(handles.BC2EnergyPlotSelect, 'Value') == ...
        get(handles.BC2EnergyPlotSelect, 'Max'))
        BC2Logic = 1; 
    end

    if (get(handles.DL2EnergyPlotSelect, 'Value') == ...
        get(handles.DL2EnergyPlotSelect, 'Max'))
        DL2Logic = 1;
    end

    % Make a tab in the plotting figure with an axis and plot all BPM's selected.
    figure;
    xlabel('Time (s)');
    ylabel('Energy BPM Reading') ;
    title(['Energy BPM vs Time' ' (' datestr(timeStamp) ')']) ;
    if (DL1Logic == 0 && BC1Logic == 0 && BC2Logic == 0 && DL2Logic == 0)
        text(0.3,0.5,'No BPM selected!','FontSize', 18, 'Color', 'r')
    else
        hold on
        if DL1Logic == 1
            plot(axesRange, DL1EnergyBPM(1,range), 'r')
        end

        if BC1Logic == 1
            plot(axesRange, BC1EnergyBPM(1,range), 'm')
        end

         if BC2Logic == 1
            plot(axesRange, BC2EnergyBPM(1,range), 'g')
        end

        if DL2Logic == 1
            plot(axesRange, DL2EnergyBPM(1,range), 'c')
        end
        hold off
        logicArray = [DL1Logic; BC1Logic; BC2Logic; DL2Logic] ;
        list = namesStringArray(find(logicArray)) ;
        legend(list) ;
    end
catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,4)  
        fprintf(1, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(1, 'Problem plotting Energy BPMS. %s', ex.message)));
end

guidata(hObject,handles);


function DL1EnergyPlotSelect_Callback(hObject, eventdata, handles)
% Selects DL1 Energy BPM to be plotted when "Plot BPM's" is pressed



function BC1EnergyPlotSelect_Callback(hObject, eventdata, handles)
% Selects BC1 Energy BPM to be plotted when "Plot BPM's" is pressed




function BC2EnergyPlotSelect_Callback(hObject, eventdata, handles)
% Selects BC2 Energy BPM to be plotted when "Plot BPM's" is pressed




function DL2EnergyPlotSelect_Callback(hObject, eventdata, handles)
% Selects DL2 Energy BPM to be plotted when "Plot BPM's" is pressed



% Plots GDET signals.
function FELPlotButton_Callback(hObject, eventdata, handles)

whoRU_const;

global GDET1
global GDET2
global axesRange
global range
global timeStamp

try

    % Check data has been successfully acquired before proceeding
    if ( ~handles.dataAcquired )
        error('WRU:NODATA', lprintf( STDERR, NOACQMSG));
    end

    % Make plotting axis in plotting figure window tab. Create tab if necessary.
    figure;

    % Plot the FEL data into the axis tab.
    hold on
    plot(axesRange,GDET1(1,range), 'Color', [.1 1 .7]) ;
    plot(axesRange,GDET2(1,range), 'Color', [0 .590 1]) ;
    legend('GDET1','GDET2') ;
    xlabel('Time (s)') ;
    ylabel('Power (mJ)') ;
    title(['FEL Power vs. Time' ' (' datestr(timeStamp) ')']) ;
    hold off

catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,4)  
        fprintf(1, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(1, 'Problem plotting FEL intensity data. %s', ex.message)));
end

guidata(hObject,handles);


% Plots all stations in a given sector that are active on the beam.
function SectorPlotButton_Callback(hObject, eventdata, handles)

whoRU_const;

global klysPhas
global axesRange
global range
global klysNames
global comp
global timeStamp

try
    % Check data has been successfully acquired before proceeding
    if ( ~handles.dataAcquired )
        error('WRU:NODATA', lprintf( STDERR, NOACQMSG));
    end

    % Retrieve sector id from button pushed UserData
    bObj=get(gcbo);
    sector=num2str(bObj.UserData,'%2d');              % sector in UserData

    % Get the subset of klystrons in this sector
    klysNames_e =  find(strncmp(sector,klysNames,2)); % indexes of sector klyss
    N_klys=length(klysNames_e);                       % num klsys in sector
    N_onBeam=sum(comp(klysNames_e)==1);               % num klsys on beamcode
    locusLabels=cell(1,N_klys);

    % If none of the klystrons are on beam, say so. Otherwise, for each
    % klystron, if it's on beam (in the klystron compliment), and its 
    % data is good, plot it.
    %
    figure;
    if (N_onBeam==0)
        text(0.1,0.5, ...
             sprintf('No stations in sector %s on the beam!',sector), ...
             'FontSize', 18, 'Color', 'r') ;
    else

        hold all
        for i=1:N_klys
            j = klysNames_e(i);
            stationLegend = klysNames(j);
            if comp(j) == 1  % is in klystron compliment
                if any(isnan(klysPhas(j,range)))  % is all bad data
                    stationLegend=strcat(stationLegend,' (NaNs)');
                end
                plot(axesRange,klysPhas(j,range) ) ;
            else
                plot(axesRange,0);
                stationLegend=strcat(stationLegend,' Not on Beam');
            end
            locusLabels(i)=stationLegend;
        end
        legend(locusLabels,'Location','Best') ;
        title(['Sector ' sector ' Stations vs. Time'  ' (' datestr(timeStamp) ')' ] ) ;
        xlabel('Time (s)') ;
        ylabel('Station phase (deg)') ;
        hold off
    end

catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,4)  
        fprintf(1, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(1, 'Problem plotting sector klystron data. %s', ex.message)));
end

guidata(hObject,handles);


% Plots the station selected in the list box below.
function plotStationButton_Callback(hObject, eventdata, handles)

whoRU_const;

global klysPhas
global klysBeamVolts
global axesRange
global klysNames
global range
global timeStamp

try

    % Check data has been successfully acquired before proceeding
    if ( ~handles.dataAcquired )
        error('WRU:NODATA', lprintf( STDERR, NOACQMSG));
    end

    % Plot station data. The head of the list from the gui are Klys 
    % beam Voltage PVs, the remindr are Klys Phase.
    %
    figure;

    % Which station does user what to see.
    s=get(handles.klysListBox, 'Value');  
    if ( s < 0 || s > handles.M_klysBeamVolt+handles.M_klysPhase )
        error('WRU:INTERNALERROR', lprintf( STDERR, ...
        ['Internal Error Detected, Plot station list index chosen ' ...
         'outside range of number of klystrons meansured. Check ' ...
         'Guide config compared to number of names in list']));
    end

    % Plot klys phase or voltage as indicated by index of Plot
    % Station pick list.
    %
    if s <= handles.M_klysBeamVolt
        if any(isnan(klysBeamVolts(s,range)))  % is all bad data
            error('WRU:NOGOODDATA', ...
              lprintf(1, NOGOODBSADATAMSG, klysBeamVoltNames{s}));
        else
            % h=figure;
            plot( axesRange,klysBeamVolts(s,range),'Color', [.5 0 1]) ;
            xlabel( 'Time (s)') ;
            ylabel( [KLYSBEAMVOLTNAMES{s} ' (V)' ]);
            title( [KLYSBEAMVOLTNAMES{s} ' (' datestr(timeStamp) ')']) ;
        end
    else
        s=s-handles.M_klysBeamVolt;
        if any(isnan(klysPhas(s,range)))  % is all bad data
            error('WRU:NOGOODDATA', ...
              lprintf(1, NOGOODBSADATAMSG ,klysNames{s}));
        else
            % h=figure
            plot( axesRange,klysPhas(s,range),'Color', [.5 0 1]) ;
            xlabel('Time (s)');
            ylabel([klysNames{s} ' phase (degrees)']);
            title([klysNames{s} ...
                   ' vs. Time'  ' (' datestr(timeStamp) ')']);
        end
    end

catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,4)  
        fprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR, 'Problem plotting station. %s', ex.message)));
end

guidata(hObject,handles);



function klysListBox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function viewLog_Callback(hObject, eventdata, handles)
% ViewLog_Callback is called when View Log menu item is selected.
% A.t.t.o.w. Viewlog is under teh file menu.
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% vewLog_Callback finds and spawn a viewer of this application execution 
% instance specific log file.

whoRU_const;                  % Application constants

try
    % Spawn command (defined by VIEWLOGCMD) to view log file. 
    logfile=getenv('MATLAB_LOG_FILE_NAME');
    if (~isempty(logfile))
        pid=feature('getpid');   % Pass pid to tail, to terminate tail 
                                 % when app process completes.
        [s,res]=system(sprintf(VIEWLOGCMD,logfile,logfile,pid));
        if s~=0
            uiwait(errordlg(sprintf('%s %s. Can not complete command %s',...
                LOGFILEERR_MSG, res, VIEWLOGCMD)));
        end
    else
        uiwait(errordlg(sprintf('%s %s',LOGFILEERR_MSG, UNDEFLOGENV)));
    end
catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(....
        lprintf(STDERR,'Problem viewing log file. %s', ex.message)));
end


% -----------------------------------------------------------------------
function screenShot_Callback(hObject, eventdata, handles)
% screenShot_Callback is called when File->Screen Shot to Log menubar 
% item is selected. This function prints a screen shot of the GUI 
% to the Physics Log.
%
% hObject    handle to ScreenShot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find and spawn a viewer of the log file
whoRU_const;

% This function just sets a timer to execute screenShot_toLog in 1 second,
% since if the screenshot is actually done synchronously then the image
% would include the pulldown in action.
try
    screenShotTimer=timer;
    screenShotTimer.Name='ScreenShotTimer';
    screenShotTimer.StartDelay=1.0;
    screenShotTimer.ExecutionMode='singleShot';
    screenShotTimer.BusyMode='drop';
    screenShotTimer.TimerFcn=@(~,thisEvent)screenShot_toLog(handles);
    start(screenShotTimer);
catch ex
    delete(screenShotTimer);
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem putting screen shot in physics log. %s', ...
        ex.message)));
end

% ----------------------------------------------------------------------
function screenShot_toLog(handles)
% screenShot_toLog takes a screenshot of the GUI window and puts a png
% of it in the Physics logbook.

wirescan_const;
windowTitleText='whoRUMini'; 
persistent SUCCESS;
SUCCESS=0;

% Find GUI screen id
getWindowIdCmd=...
    sprintf('wmctrl -l | awk ''/%s/ {print $1}''',windowTitleText);
[iss,winId_hextxt]=system(getWindowIdCmd);
if ~isequal(iss,SUCCESS) 
    error(lprintf(STDERR,...
        'Could not get GUI window id for window %s',windowTitleText));
end;

% Make screen capture of GUI screen
pngfn=sprintf('%s.png',tempname);
screencapture_cmd=sprintf('import -window "%s" %s',winId_hextxt,pngfn);
[iss,msg]=system(screencapture_cmd);
if ~isequal(iss,SUCCESS) 
    error(lprintf(STDERR,...
        'Could not screen capture GUI window. %s',char(msg)));
end;

% Post screen capture to logbook
loggerCmd='physicselog'; % Must be in PYTHONPATH. Note named as if module.
logBookPostCmd=...
    sprintf('python -m %s lcls "Screenshot" %s "GUI Screenshot"',...
    loggerCmd, pngfn);
[iss,msg]=system(logBookPostCmd);
if ~isequal(iss,SUCCESS) 
    error(lprintf(STDERR,...
        'Could not post screencapture png to log book. %s',char(msg))); 
end;

function quit_Callback(hObject, eventdata, handles)
% quit_Callback is called when the File-Exit menu item is selected to 
% exit the GUI. 
%
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close all includes closing the application figure window and hence
% calls wirescan_gui_CloseRequestFcn above. 
delete(findall(0,'type','figure'))



function help_Callback(hObject, eventdata, handles)
% help_Callback is called when Help menubar item is selected. This
% function presents the online user guide documententation.
%
% hObject    handle to ViewLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find and spawn a viewer of the log file
whoRU_const;
try
    web(WRUHELP_URL, '-browser');
catch ex
    if ~strncmp(ex.identifier,WRU_EXID_PREFIX,3)  
        lprintf(STDERR, '%s\n', getReport(ex,'extended'));
    end
    uiwait(errordlg(...
        lprintf(STDERR,'Problem viewing help. %s', ex.message)));
end

function SectorPlotButton_CreateFcn(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function BPMPlotButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BPMPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function DL1EnergyPlotSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DL1EnergyPlotSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function BC1EnergyPlotSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BC1EnergyPlotSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function BC2EnergyPlotSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BC2EnergyPlotSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function DL2EnergyPlotSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DL2EnergyPlotSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function FELPlotButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FELPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function CollectDataButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CollectDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes during object creation, after setting all properties.
function plotStationButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotStationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in klysListBox.
function klysListBox_Callback(hObject, eventdata, handles)


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

