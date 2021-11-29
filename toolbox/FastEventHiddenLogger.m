function [] = FastEventHiddenLogger()
% FastEventHiddenLogger does the basic logging job of FastEventLogger, but
% it runs in the background under Matlab Watcher and generates no plots.
% This program looks for fast events like vacuum bursts. If one is found, a
% list of beam-synchronous PVs is recorded at 120 Hz from fast digitizers
% connected to selected vacuum signals. These PVs are listed in a file,
% FastEventPVs.txt. Every 5 seconds, the program polls 10-Hz data from
% every PV that has a threshold provided in the list. An "event" occurs if
% any PV has gone over (or optionally under) its threshold. Then the full
% BSA buffer (up to 2800 points) is downloaded and written to a file.
%
% Alan Fisher   2010 July 12

eDefCounterPV = 'SIOC:SYS0:ML00:AO604';
heartbeatPV   = 'SIOC:SYS0:ML00:AO605';
PVFilename    = 'FastEventPVs.txt';
PVs.N = 0;      % Number of PVs. 2nd optional element = first beam-rate PV.
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
repeat = 5;     % Check for triggers every <repeat> seconds.
pts = 2800;     % Points in a BSA buffer (oldest first)
pause on

try
    
    %--------------------- 
    % Read the file with the PV list.
    catchMsg = 'Error in FastEventHiddenLogger while reading file of PV names:';
    disp(['Reading the list of PV names from ',PVFilename])
    PVFile = fopen(PVFilename);
    
    while moreToRead
        pv = fgetl(PVFile);
        if feof(PVFile)
            moreToRead = 0;
        end
        comment = strfind(pv,'%');
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
                        if strcmp(gtlt,'>') || strcmp(gtlt,'<')
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
    % Is the Logger already running elsewhere? If not, then start here. If so,
    % then keep checking in case it is stopped there.
    % If it's not running anywhere, start it here and loop. But quit if
    % the Matlab Watcher resets the heartbeat counter to zero.
    catchMsg = 'Error in FastEventHiddenLogger while checking heartbeat PV:';
    disp('Is FastEventLogger running somewhere else?')
    oldBeatCount = lcaGet(heartbeatPV);
    tic
    while toc < 15
        pause(2)
        newBeatCount = lcaGet(heartbeatPV);
        if newBeatCount > oldBeatCount
            oldBeatCount = newBeatCount; % Alive elsewhere. Wait for it to die.
            disp('Running elsewhere. Will start here once it stops there.')
            tic
        end
    end
    disp('FastEventLogger is not running somewhere else.')
    lcaPut(heartbeatPV,newBeatCount+1)   % Increment, so that counter > 0

    %---------------------
    % Create an event definition for BSA.
    catchMsg = 'Error during eDef setup for Fast Event Logger:';
    disp('Reserving an event definition.')
	% Is an event definition already open?
    eDefNumber = 0;
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
    % channels for which thresholds are specified in the file.
    % Poll by examining 10-Hz BSA data with some overlap.
    catchMsg = 'Error in FastEventHiddenLogger during data acquisition:';
    disp('Event logging is running.')
    oldEventTime = zeros(nTrigs,1);
    while lcaGetSmart(heartbeatPV) > 0
        try
            lcaPut(heartbeatPV,lcaGetSmart(heartbeatPV)+1)  % Increment counter
            tic
            % Look for a triggering event.
            recent = lcaGetSmart(triggers,pts);
            event = 0;
            m = pts-floor(repeat*20);
            while m < pts && ~event
                m = m+1;
                n = 0;
                while n < nTrigs && ~event
                    n = n + 1;
                    if  (compare(n) > 0 && recent(n,m) > threshold(n)) ||...
                        (compare(n) < 0 && recent(n,m) < threshold(n))
                        trTime = epics2matlabTime(complex...
                            (recent(nTrigs+1,m),recent(nTrigs+2,m)));
                        % Don't retrigger on same PV within 15 minutes
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

            % When an event has been found, acquire the full BSA buffers for
            % all listed PVs and for their time stamps.
            if event
                dateVector = datevec(PVs.triggerTime);
                disp(['Event occured at time ',datestr(dateVector,31)])
                disp(['Event triggered by ',PVs.triggeredBy])
                disp(['Threshold is ',num2str(threshold(n))])
                disp(['Signal was   ',num2str(recent(n,m))])

                % Wait a few more seconds, and then stop to record the data.
                pause(12-(now-PVs.triggerTime)*24*3600)
                got = lcaGetSmart(PVList,pts);  % Acquire all PVs
                sec  = got(PVs.N(1)+1,:);
                nsec = got(PVs.N(1)+2,:);
                if BR
                    secBR  = got(PVs.N(1)+3,:);
                    nsecBR = got(PVs.N(1)+4,:);
                end
                lcaPut(['EDEF:SYS0:',eDefString,':CTRL'],'ON') % Resume
                
                % Fix the time stamps. Ignore zeros that may be at the end
                % of the array. There may be zeros in the middle too (dealt
                % with next), and so don't cut too much.
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
                    % If sample n is taken a bit late, its time stamp is
                    % spaced by two steps, dt. Then sample n+1 gets a time
                    % stamp of 0. Sometimes sample n-1 is slightly late
                    % too. We iron out these bumps. (This seems to happen
                    % only at 120 Hz, when we're pushing the speed of BSA.)
                    % First, find the usual interval dt.
                    % Rarely, the time stamps have a huge jump in the
                    % middle. Then do not change them, to aid in diagnosis.
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
                        nsec(nonzero) = (tStamp(nonzero)-sec(nonzero))*1e9;
                    end
                    for m = nonzero-1:-1:1
                        if sec(m) <= 0 && tStamp(nonzero)-tStamp(1) < 100
                            n = 0;
                            while n < 3 && m-n > 0
                                tStamp(m-n) = tStamp(m+1) - (n+1)*dt;
                                sec(m-n) = floor(tStamp(m-n));
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
                    try
                        mkdir(filePath)
                    catch
                    end
                    save(file,'PVs') % Save data in file
                end
            end
        catch ME
            disp(catchMsg)
            disp(ME)
            disp(ME.message)
            disp(ME.stack)
            pause(2)
        end
        pause(repeat-toc)  % Wait for a total of <repeat> seconds.
    end

catch ME
    disp(catchMsg)
    disp(ME)
end

if eDefNumber > 0
    eDefRelease(eDefNumber)
    lcaClear
end
end

