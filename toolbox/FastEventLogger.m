function varargout = FastEventLogger(varargin)
% FastEventLogger looks for fast events like vacuum bursts. It records a
% list of beam-synchronous PVs at 120 Hz from fast digitizers connected to
% selected vacuum signals. These PVs are listed in a file,
% FastEventPVs.txt. Every 5 seconds, it polls 10-Hz data from every PV
% that has a threshold provided in the list. An "event" occurs if any PV
% has gone over (or optionally under) its threshold. Then the full BSA
% buffer (up to 2800 points) is downloaded, written to a file, and plotted.
%
% Alan Fisher   2010 July 12

% FASTEVENTLOGGER M-file for FastEventLogger.fig
%      FASTEVENTLOGGER, by itself, creates a new FASTEVENTLOGGER or raises the existing
%      singleton*.
%
%      H = FASTEVENTLOGGER returns the handle to a new FASTEVENTLOGGER or the handle to
%      the existing singleton*.
%
%      FASTEVENTLOGGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FASTEVENTLOGGER.M with the given input arguments.
%
%      FASTEVENTLOGGER('Property','Value',...) creates a new FASTEVENTLOGGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FastEventLogger_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FastEventLogger_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FastEventLogger

% Last Modified by GUIDE v2.5 18-Mar-2013 10:50:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FastEventLogger_OpeningFcn, ...
                   'gui_OutputFcn',  @FastEventLogger_OutputFcn, ...
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
end



% --- Executes just before FastEventLogger is made visible.
function FastEventLogger_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FastEventLogger (see VARARGIN)

% Choose default command line output for FastEventLogger
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FastEventLogger wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global eDefNumber stop busy halt path
eDefNumber = 0;
busy = 0;
stop = 0;
halt = 0;
path = '/u1/lcls/matlab/FastEvents';
set(handles.ToText,'String','Resave as Text File')
end



% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PVs eDefNumber start manual stop busy halt

start = 0;
manual = 0;
busy = 0;
stop = 0;
halt = 0;
repeat = 5;     % Check for triggers every <repeat> seconds.
pts = 2800;     % Points in a BSA buffer (oldest first)
eDefNumber = 0;
eDefCounterPV = 'SIOC:SYS0:ML00:AO604';
heartbeatPV   = 'SIOC:SYS0:ML00:AO605';
PVFilename    = 'FastEventPVs.txt';
set(handles.Start,'String','Starting')
set(handles.Stop, 'String','STOP')
pause on

try
    %---------------------
    % Read the file with the PV list.
    catchMsg =...
        'Error in FastEventLogger while reading file of PV names:';
    disp(['Reading the list of PV names from ',PVFilename])
    PVFile = fopen(PVFilename);
    start = 1;
    PVs.N = 0;  % Number of PVs. 2nd optional element = first beam-rate PV.
    BR = 0;
    PVs.name = cell(0);
    PVs.unit = cell(0);
    PVs.log = zeros(0);
    nPlots = 0.1;
    traces = 0;
    nTrigs = 0;
    triggers = cell(0);
    compare = zeros(0);
    threshold = zeros(0);
    triggerPlotNum = zeros(0);
    moreToRead = 1;

    while moreToRead
        pv = fgetl(PVFile);
        if feof(PVFile)
            moreToRead = 0;
        end
        comment = strfind(pv,'%');  % Ignore comments
        if ~isempty(comment)
            if comment(1) > 1
                pv = strtrim(pv(1:comment(1)-1));
            else
                pv = '';
            end
        end
        if isempty(pv)              % Blank lines indicate new plot
            nPlots = floor(nPlots) + 0.1;
            traces = 0;
        elseif strcmpi(pv,'LOG')    % Semilog plot for this group
            nPlots = floor(nPlots) + 0.1;
            traces = 0;
            PVs.log(ceil(nPlots),1) = 1;
        elseif strcmpi(pv,'BR')     % All subsequent PVs are read at beam
            nPlots = floor(nPlots) + 0.1;   % rate, rather than at the
            traces = 0;                     % 120-Hz rate of the Fast-
            BR = 1;                         % Event eDef.
            if length(PVs.N) == 1
                PVs.N(2) = PVs.N(1) + 1;
            end
        else

            % Each line has a PV name plus up to 3 optional fields,
            % separated by commas:
            % - Conversion factor and unit. If missing, use a factor of
            %   1 and the unit from the EPICS EGU
            % - Trigger threshold, preceeded by '>' or '<'.                
            OK = 1;
            commas = [0, strfind(pv,','), length(pv)+1];
            nCommas = length(commas);
            if nCommas > 5
                commas = commas(1:5);
                nCommas = 5;
            end
            nTokens = min(nCommas-1,4);
            token = cell(nTokens,1);
            for n = 1:nTokens
                token{n,1} = strtrim(pv(commas(n)+1:commas(n+1)-1));
            end
            % The first token is always the PV name.
            name = token{1,1}; 
            if isempty(name) || sum(strfind(name,' ')) ||...
                    ~sum(strfind(name,':'))
                OK = 0;
            end
            % If there are more than two tokens, then tokens
            % 2 and 3 give the conversion factor and unit.
            if OK
                if nTokens > 2
                    if isempty(token{2,1})
                        OK = 0;
                    else
                        conv = str2double(token{2,1});
                        unit = token{3,1};
                        if isnan(conv)
                            OK = 0;
                        end
                    end
                else
                    conv = 1;
                    unit = lcaGet([name,'HSTTH.EGU']);
                    unit = unit{1};
                end
            end
            % The last token (number 2 of 2 or number 4 of 4) gives the
            % threshold for triggering an acquisition record with this
            % PV. The value must be preceeded by either '<' or '>'.
            if OK
                if nTokens == 2 || nTokens == 4
                    lToken = length(token{nTokens});
                    if lToken > 1
                        gtlt = token{nTokens,1}(1);
                        if strcmp(gtlt,'>') || strcpm(gtlt,'<')
                            comp = 2*strcmp(gtlt,'>')-1;
                            thresh =...
                                str2double(token{nTokens,1}(2:lToken));
                            if isnan(thresh)
                                OK = 0;
                            else
                                nTrigs = nTrigs + 1;
                                triggers{nTrigs,1} = [name,'HSTTH'];
                                compare(nTrigs) = comp;
                                threshold(nTrigs) = thresh;
                                triggerPlotNum(nTrigs) = ceil(nPlots);
                            end
                        else
                            OK = 0;
                        end
                    else
                        OK = 0;
                    end
                else
                    comp = 0;
                    thresh = 0;
                end
            end
            if OK
                PVs.N(1) = PVs.N(1) + 1;
                nPlots = ceil(nPlots);
                PVs.plot(PVs.N(1),1) = nPlots;
                traces = traces + 1;
                PVs.traces(nPlots,1) = traces;
                if length(PVs.log) < nPlots
                    PVs.log(nPlots,1) = 0;
                end
                PVs.name{PVs.N(1),1}      = name;
                PVs.convert(PVs.N(1),1)   = conv;
                PVs.unit{PVs.N(1),1}      = unit;
                PVs.compare(PVs.N(1),1)   = comp;
                PVs.threshold(PVs.N(1),1) = thresh;
            else
                disp(['Error in input line: "',pv,'"'])
            end
        end
    end
    fclose(PVFile);
    if BR && PVs.N(2) > PVs.N(1)
        PVs.N = PVs.N(1);
        BR = 0;
    end
    triggers{nTrigs+1,1} = 'PATT:SYS0:1:SECHSTTH';
    triggers{nTrigs+2,1} = 'PATT:SYS0:1:NSECHSTTH';
    
    %---------------------
    % Is the Logger already running elsewhere? If not, then start here.
    catchMsg = 'Error in FastEventLogger while checking heartbeat PV:';
    disp('Is FastEventLogger running somewhere else?')
    oldBeatCount = lcaGet(heartbeatPV);
    newBeatCount = 0;
    tic
    while toc < 15 && newBeatCount >= 0
        pause(2)
        newBeatCount = lcaGet(heartbeatPV);
        if newBeatCount > oldBeatCount
            oldBeatCount = newBeatCount; % Alive elsewhere. Don't start here.
            newBeatCount = -1;
        end
    end
    if newBeatCount < 0
        set(handles.Start,'String','On Elsewhere','FontWeight','normal')
        set(handles.Stop, 'String','Stopped Here','FontWeight','normal')
        disp('Logging is running in the background or at another terminal.')
        pause(5)
        set(handles.Start,'String','START',  'FontWeight','bold')
        set(handles.Stop, 'String','Stopped','FontWeight','bold')
    else
        disp('FastEventLogger is not running somewhere else.')
        
        %---------------------
        % Create an event definition for BSA.
        catchMsg = 'Error during eDef setup for Fast Event Logger:';
        disp('Reserving an event definition.')
        % Is an event definition already open?
        n = 0;
        while ~eDefNumber && n < 15
            n = n + 1;
            eDefName = lcaGet(['EDEF:SYS0:',num2str(n),':NAME']);
            eDefName = eDefName{1};
            if ~isempty(findstr(eDefName,'Fast Event Logger'))
                eDefNumber = n; 
            end
        end
        % Reuse old eDef or open a new one.
        if eDefNumber
            eDefString = num2str(eDefNumber);
            disp(['Reusing eDef ',eDefString,' with name ',eDefName])
        else
            lcaPut(eDefCounterPV, 1+lcaGet(eDefCounterPV))
            eDefCounter = lcaGet(eDefCounterPV);
            eDefName = sprintf('Fast Event Logger %d',eDefCounter);
            eDefNumber = eDefReserve(eDefName);
            eDefString = num2str(eDefNumber);
            eDefNAVG = 1;
            eDefNRPOS = -1;
            disp(['Opening eDef ',eDefString,' with name ',eDefName])
            eDefParams (eDefNumber, eDefNAVG, eDefNRPOS, {''},...
                {'pockcel_perm'},{'TS2';'TS3';'TS5';'TS6'},{''})
                % Text entries for inclusion/exclusion masks:
                % add/delete from inclusion, add/delete from exclusion.
            lcaPut(['EDEF:SYS0:',eDefString,':BEAMCODE'],0);
        end
        lcaPut(['EDEF:SYS0:',eDefString,':CTRL'],'ON') % Start buffer
        lcaPut(heartbeatPV,newBeatCount+1) % Increment, so that counter > 0
        
        %---------------------
        % Create list of PV names with the appropriate BSA suffix: either
        % 'HSTx' (where x = the event number, 0 to 15) or 'HSTBR' for
        % beam-rate PVs.
        PVList = cell(PVs.N(1)+2*(BR+1),1);
        for n = 1:PVs.N(1)
            if BR && n >= PVs.N(2)
                PVList{n} = [PVs.name{n},'HSTBR'];
            else
                PVList{n} = [PVs.name{n},'HST',eDefString];
            end
        end
        % Add the time stamps to this acquisition list:
        PVList{PVs.N(1)+1} = ['PATT:SYS0:1:SECHST' ,eDefString];
        PVList{PVs.N(1)+2} = ['PATT:SYS0:1:NSECHST',eDefString];
        if BR
            PVList{PVs.N(1)+3} = 'PATT:SYS0:1:SECHSTBR';
            PVList{PVs.N(1)+4} = 'PATT:SYS0:1:NSECHSTBR';
        end
        
        %---------------------
        % Look for a triggering event every <repeat> seconds by polling
        % channels for which thresholds are specified in the file. Poll by
        % examining 10-Hz BSA data with some overlap.
        catchMsg = 'Error in FastEventLogger during data acquisition:';
        set(handles.Start,'String','Logging')
        disp('Event logging is running.')
        oldEventTime = zeros(nTrigs,1);
        while ~stop && ~halt && lcaGetSmart(heartbeatPV)
            tic
            try
                lcaPut(heartbeatPV,lcaGetSmart(heartbeatPV)+1)
                % Look for a triggering event.
                if manual
                    manual = 0;
                    event = 1;
                    PVs.triggerTime = now;
                    PVs.triggeredBy = 'Manual';
                else
                    recent = lcaGetSmart(triggers,pts);
                    event = 0;
                    m = pts-floor(repeat*20);
                    while m < pts && ~event
                        m = m+1;
                        n = 0;
                        while n < nTrigs && ~event
                            n = n + 1;
                            if  (compare(n)  > 0 &&...
                                 recent(n,m) > threshold(n)) ||...
                                (compare(n)  < 0 &&...
                                 recent(n,m) < threshold(n))
                                trTime = epics2matlabTime(complex...
                                    (recent(nTrigs+1,m),recent(nTrigs+2,m)));
                                % Don't retrigger on same PV within 15 min
                                if (trTime-oldEventTime(n))*24*60 >= 15
                                    event = m;
                                    PVs.triggerTime = trTime;
                                    oldEventTime(n) = trTime;
                                    PVs.triggeredBy =...
                                        [triggers{n}(1:length(triggers{n})-5),...
                                        ' (Fig ',num2str(triggerPlotNum(n)),')'];
                                end
                            end
                        end
                    end
                end

                % When an event has been found, acquire the full BSA
                % buffers for all listed PVs and for their time stamps.
                if event
                    busy = 1;
                    dateVector = datevec(PVs.triggerTime);
                    disp(['Event occured at time ',datestr(dateVector,31)])
                    disp(['Event triggered by ',PVs.triggeredBy])
                    disp(['Threshold is ',num2str(threshold(n))])
                    disp(['Signal was   ',num2str(recent(n,m))])
                    set(handles.TriggerWhoWhen,'String',...
                        [PVs.triggeredBy,'  ',datestr(dateVector,31)])

                    % Wait 12 s after trigger. Stop BSA to record data.
                    pause(12-(now-PVs.triggerTime)*24*3600)
                    lcaPut(['EDEF:SYS0:',eDefString,':CTRL'],'OFF') % Stop
                    got = lcaGetSmart(PVList,pts);  % Acquire all PVs
                    sec  = got(PVs.N(1)+1,:);
                    nsec = got(PVs.N(1)+2,:);
                    if BR
                        secBR  = got(PVs.N(1)+3,:);
                        nsecBR = got(PVs.N(1)+4,:);
                    end
                    lcaPut(['EDEF:SYS0:',eDefString,':CTRL'],'ON') % Resume
                    
                    % Fix the time stamps. Ignore zeros that may be at the
                    % end of the array. There may be zeros in the middle
                    % too (dealt with next), and so don't cut too much.
                    nonzero = sum(sec > 0);
                    if nonzero > 100
                        n = nonzero+1;
                        while n <= pts
                            if sum(sec(n:pts))
                                nonzero = n;
                                n = n+1;
                            else
                                nonzero = n-1;
                                n = pts+1;
                            end
                        end
                        sec  =  sec(1:nonzero);
                        nsec = nsec(1:nonzero);
                        tStamp = sec + nsec*1e-9;

                        % If sample n is taken a bit late, its time stamp
                        % is spaced by two steps, dt. Then sample n+1 gets
                        % a time stamp of 0. Sometimes sample n-1 is
                        % slightly late too. We iron out these bumps.
                        % (This seems to happen only at 120 Hz, when we're
                        % pushing the speed of BSA.)
                        % First, find the usual interval dt.
                        n = 1;
                        while n <= nonzero-2
                            if sum(sec(n:n+2) <= 0)
                                n = n+3;
                            else
                                n1 = n;
                                n = nonzero;
                            end
                        end
                        n = nonzero;
                        while n > 0
                            if sec(n) <= 0
                                n = n-3;
                            else
                                n2 = n;
                                n = 0;
                            end
                        end
                        dt = (tStamp(n2)-tStamp(n1))/(n2-n1);
                        if sec(nonzero) <= 0 && tStamp(nonzero)-tStamp(1) < 100
                            tStamp(nonzero) = tStamp(nonzero-3) + 3*dt;
                            sec(nonzero) = floor(tStamp(nonzero));
                            nsec(nonzero) =...
                                (tStamp(nonzero)-sec(nonzero))*1e9;
                        end
                        for m = nonzero-1:-1:1
                            if sec(m) <= 0 && tStamp(nonzero)-tStamp(1) < 100
                                n = 0;
                                while n < 3 && m-n > 0
                                    tStamp(m-n) = tStamp(m+1) - (n+1)*dt;
                                    sec(m-n)  = floor(tStamp(m-n));
                                    nsec(m-n) = (tStamp(m-n)-sec(m-n))*1e9;
                                    n = n+1;
                                end
                            end
                        end
                        
                        % Keep only BR points within time interval of
                        % points acquired at 120 Hz.
                        if BR
                            tStampBR = secBR + nsecBR*1e-9;
                            n1 = 0;
                            n2  = 0;
                            n = 1;
                            while n <= pts
                                if tStampBR(n) >= tStamp(1) &&...
                                        tStampBR(n) > 0
                                    n1 = n;
                                    n = pts+1;
                                else
                                    n = n+1;
                                end
                            end
                            n = pts;
                            while n >= n1
                                if tStampBR(n) <= tStamp(nonzero) &&...
                                        tStampBR(n) > 0
                                    n2 = n;
                                    n = 0;
                                else
                                    n = n-1;
                                end
                            end
                            secBR    =  secBR(n1:n2);
                            nsecBR   = nsecBR(n1:n2);
                            tStampBR =  secBR + nsecBR*1e-9;
                            nBR = min(n2-n1+1,nonzero);
                        end
                        
                        % BR may be 120 Hz or slower, and it may pause or
                        % change during the acquisition. So there is no
                        % constant interval dt. We just interpolate any
                        % zero values.
                        if nBR >= 3
                            for n = nBR-1:-1:2
                                if secBR(n) <= 0
                                    tStampBR(n) =...
                                        (tStampBR(n+1)+tStampBR(n-1))/2;
                                    secBR(n)  = floor(tStampBR(n));
                                    nsecBR(n) = (tStampBR(n)-secBR(n))*1e9;
                                end
                            end
                        end
                        
                        % Initialize
                        PVs.time = (0+1i*0)*(zeros(BR+1,nonzero));
                        PVs.hist = zeros(PVs.N(1),nonzero);
                        
                        % Convert from EPICS to Matlab date/time format.
                        % Fill time and history arrays in PVs structure.
                        for n = 1:nonzero
                            PVs.time(1,n) =epics2matlabTime(...
                                complex(sec(n),nsec(n)));
                        end
                        if BR
                            for n = 1:nBR
                                PVs.time(2,n) =epics2matlabTime(...
                                    complex(secBR(n),nsecBR(n)));
                            end
                            PVs.hist(1:PVs.N(2)-1,     :) =...
                                 got(1:PVs.N(2)-1,     1:nonzero);
                            PVs.hist(PVs.N(2):PVs.N(1),1:nBR) =...
                                 got(PVs.N(2):PVs.N(1),n1+(0:nBR-1));
                        else
                            PVs.hist = got(1:PVs.N,1:nonzero);
                        end
                        
                        % Set up path for saving data
                        filePath = sprintf(...
                            '/u1/lcls/matlab/FastEvents/%d/%d-%02d/%d-%02d-%02d/',...
                            dateVector(1),dateVector(1),dateVector(2),...
                            dateVector(1),dateVector(2),dateVector(3));
                        fileName = sprintf('Event-%d%02d%02d-%02d%02d%02d.mat',...
                            dateVector(1),dateVector(2),dateVector(3),...
                            dateVector(4),dateVector(5),round(dateVector(6)));
                        file = [filePath,fileName];
                        set(handles.Filename,'String',file,...
                            'HorizontalAlignment','left')
                        try
                            mkdir(filePath)
                        catch
                        end
                        save(file,'PVs')     % Save data in file
                        FastEventPlots(PVs)  % Plot data
                    end
                    busy = 0;
                end
            catch ME
                busy = 0;
                disp(catchMsg)
                disp(ME)
                pause(2)
            end
            pause(repeat-toc) % Wait a total of <repeat> seconds.
        end
        stop = 0;
        
    end
    if eDefNumber > 0
        eDefRelease(eDefNumber)
    end
    set(handles.Start,'String','START')
    set(handles.Stop, 'String','Stopped')
    
catch ME
    start = 0;
    manual = 0;
    busy = 0;
    stop = 0;
    disp(catchMsg)
    disp(ME)
    if eDefNumber > 0
        FastEventLogger_CloseRequestFcn(hObject, eventdata, handles)
        eDefRelease(eDefNumber)
    end
    Stop_Callback(handles.Stop,eventdata,handles)
end
end



% --- Executes on button press in TriggerNow.
function TriggerNow_Callback(hObject, eventdata, handles)
% hObject    handle to TriggerNow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global start manual stop

if ~stop
    manual = 1;
    if ~start
        Start_Callback(handles.Start,eventdata,handles)
    end
end
end



% --- Executes when user attempts to close FastEventLogger.
function FastEventLogger_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to FastEvnetLogger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global eDefNumber

try
    if eDefNumber
        eDefRelease(eDefNumber)
    end
catch
end
util_appClose (hObject)
lcaClear()
end



% --- Outputs from this function are returned to the command line.
function varargout = FastEventLogger_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PVs path file
pathBefore = pwd;
try
    cd(path)
    [filename,userPath,index] = uigetfile('*.mat','Select the file of a fast event:');
    file = [userPath,filename];
    if ~isequal(file,[0 0])
        path = userPath;
        set(handles.Filename,'String',file,'HorizontalAlignment','left')
        load(file)
        set(handles.TriggerWhoWhen,'String',...
            [PVs.triggeredBy,'   ',datestr(PVs.triggerTime,31)])
        FastEventPlots(PVs)
    end
catch
    disp('Error in FastEventLogger opening file for plotting:')
    err = lasterror;
    disp(err.message)
    disp(err.identifier)
end
cd(pathBefore)
end



% --- Executes on button press in ToText.
function ToText_Callback(hObject, eventdata, handles)
% hObject    handle to ToText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PVs path file

set(handles.ToText,'String','Resave as Text File')
if isempty(path) || isempty(file)
    set(handles.Filename,'String',...
        'First plot the file you want converted to text format.')    
elseif ~strcmp(file(length(file)-3:length(file)),'.mat')
    set(handles.Filename,'String',...
        'The file you want to convert must be in .mat format.')   
else
    set(handles.ToText,'String','Saving Text File')
    pause(1)
    filename = [file(1:length(file)-3),'txt'];
    fid = fopen(filename,'w');
    blanks = '                        ';
    colWidth = 25;
    
    nHpts = length(PVs.time(1,:));
    if length(PVs.N) == 1
        nHPVs = PVs.N(1);
        nBPVs = 0;
    else
        nBpts = length(PVs.time(2,:));
        nHPVs = PVs.N(2)-1;
        nBPVs = PVs.N(1)-nHPVs;
    end
    
    fprintf(fid,['Time',blanks(1:colWidth-4)]);
    for m = 1:nHPVs
        s = [PVs.name{m},blanks];
        s = s(1:colWidth);
        fprintf(fid,'%s',s);
    end
    fprintf(fid,'\n');
    for n = 1:nHpts
        fprintf(fid,['%15e',blanks(1:colWidth-15)],...
            (PVs.time(1,n)-PVs.triggerTime)*24*3600);
        for m = 1:nHPVs
            fprintf(fid,['%15e',blanks(1:colWidth-15)],PVs.hist(m,n));
        end
        fprintf(fid,'\n');
    end
    
    if nBPVs > 0
        fprintf(fid,['Time',blanks(1:colWidth-4)]);
        for m = nHPVs+(1:nBPVs)
            s = [PVs.name{m},blanks];
            s = s(1:colWidth);
            fprintf(fid,'%s',s);
        end
        fprintf(fid,'\n');
        for n = 1:nBpts
            fprintf(fid,['%15e',blanks(1:colWidth-15)],...
                (PVs.time(2,n)-PVs.triggerTime)*24*3600);
            for m = nHPVs+(1:nBPVs)
                fprintf(fid,['%15e',blanks(1:colWidth-15)],PVs.hist(m,n));
            end
            fprintf(fid,'\n');
        end
    end
    fclose(fid);
    set(handles.ToText,'String','File Saved')
    pause(1)
    set(handles.ToText,'String','Resave as Text File')
end
end



% --- Executes on button press in PVList.
function PVList_Callback(hObject, eventdata, handles)
% hObject    handle to PVList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PVs
if isstruct(PVs)
    msgbox(PVs.name,'List of PVs')
else
    s = 'Logger must be started once before PV names become available.';
    disp(s)
    set(handles.Filename,'String',s)
end
end



function TriggerWhoWhen_Callback(hObject, eventdata, handles)
% hObject    handle to TriggerWhoWhen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TriggerWhoWhen as text
%        str2double(get(hObject,'String')) returns contents of TriggerWhoWhen as a double
end


% --- Executes during object creation, after setting all properties.
function TriggerWhoWhen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TriggerWhoWhen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function Filename_Callback(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Filename as text
%        str2double(get(hObject,'String')) returns contents of Filename as a double
end


% --- Executes during object creation, after setting all properties.
function Filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Stop

global start stop busy

set(handles.Stop, 'String','Stopping')
set(handles.Start,'String','START')
stop  = 1;
start = 0;
tic
while busy && toc < 10
end
set(handles.Stop, 'String','Stopped')
disp('Event logging stopped.')
end



% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global eDefNumber busy halt

halt = 1;
tic
while busy && toc < 10
end
try
    if eDefNumber
        eDefRelease(eDefNumber)
    end
catch
end
exit
end
