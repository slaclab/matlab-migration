function FACETklystronCud
% Function FACETklystronCud(accelerator)
% Control script for FACET klystron CUD edm display.
% Accelerator is FACET.

% W. Colocho Nov. 2008
% Taken over by B. Ripman in 2012.

persistent sys
persistent accelerator
if isempty(sys)
    [sys, accelerator] = getSystem();
end
if ~strcmpi(accelerator, 'FACET')
   exit 
end
aidainit;
nLogLines = 24;
toggleLogFile = 1;
logStringHead = 'begin\nnumCols 3\nheaderAlign "ccclc"\nalign "ccclc"\nseparators "|"\ncomment "#"\nend\n';
logStringList(1:nLogLines) = {''};
err = getLogger(['klystronCud_', accelerator]);  
fprintf('\nStarting Klystron Cud %s\n\n',datestr(now)')
format long
statusStr = {'OK '; 'ACC'; 'OFF'; 'MNT'; 'TBR'; 'ARU';  'CKP'};
statusColor =[ 50,    55,    85,    85,      85     85      85];
beamCodes = [10];
pTolSbsts = 1; % SBST phase tolerances
pTolMean = [1;0.5];
sbst = {'LI10', 'LI11', 'LI12', 'LI13', 'LI14', 'LI15', 'LI16', 'LI17', 'LI18', 'LI19', 'LI20'};
handles.sbstN = (10:20)'; % 21 is a fake sector used to index oddball stations.
removeList = {'10-1'; '10-6'; '10-7'; '10-8'; '11-3'; '14-7'; '15-2'; ...
              '19-7'; '19-8'; '20-1'; '20-2'; '20-3'; '20-5'; '20-6'; ...
              '20-7';'20-8'};
handles.sbstS = strrep(strcat(cellstr(num2str(handles.sbstN)),'-S'),' ', '0');
handles.klysN = (1:8)';
for j = handles.klysN'
    handles.klysS(j,:)=strrep(strcat(cellstr(num2str(handles.sbstN)),'-',num2str(j))',' ','0');
end
% Remove klystrons that are on the remove list
[c, ia, ib] = intersect(handles.klysS,removeList);
ia_stn = mod(ia,8);
ia_stn(ia_stn==0) = 8;
for ii = 1:length(ia)
    handles.klysS(ia_stn(ii),fix((ia(ii)-1)/8)+1) = {' '};
end
klysNumel = numel(handles.klysS);
sbstNumel = numel(handles.sbstN);
blankMat = cell(8,sbstNumel);
[blankMat{:}] = deal(' ');
% Prepare the arrays that will hold PV names.
statPvs = blankMat;
strPvs =  blankMat;
adesPvs = blankMat;
pActPvs = cell(sbstNumel,1);
pLimHihiPvs = pActPvs;
pLimLoloPvs = pActPvs;
pstrPvs = pActPvs;
for bcIndex = 1:numel(beamCodes)
    isAccPvs{bcIndex} = blankMat;
    pisAccPvs{bcIndex} = pActPvs;
end
% Now populate these arrays with the correct PV names.
for bcIndex = 1:numel(beamCodes)
    for sb = 1:sbstNumel
        % First define PVs for sub-boosters
        pActPvs{sb} = sprintf('FCUDSBST:%s:1:STATUS', sbst{sb} );
        pLimHihiPvs{sb} = sprintf('FCUDSBST:%s:1:STATUS.HIHI', sbst{sb} );
        pLimLoloPvs{sb} =  sprintf('FCUDSBST:%s:1:STATUS.LOLO', sbst{sb} );
        pstrPvs{sb} = sprintf('FCUDSBST:%s:1:STATUS.DESC', sbst{sb} );
        pisAccPvs{bcIndex}{sb} = sprintf('FCUDSBST:%s:1:ONBEAM%i', sbst{sb}, beamCodes(bcIndex) );
        % Next, define PVs for klystrons
        for stn = 1:8
            thisStation = sprintf('%s-%i',sbst{sb}(3:4),stn); % e.g. '15-1'
            if strmatch(thisStation, removeList), continue, end
            if(sb==21) % Special stations: 'KLYS:LI20:93';  'KLYS:LI20:94'; 'KLYS:LI20:41' - needs some cleaning up
                switch stn,
                    case 5,
                        isAccPvs{bcIndex}{stn,sb} =  sprintf('FCUDKLYS:LI20:93:ONBEAM%i', beamCodes(bcIndex) );
                        statPvs{stn,sb} = sprintf('FCUDKLYS:LI20:93:STATUS');
                        strPvs{stn,sb} = sprintf('FCUDKLYS:LI20:93:STATUS.DESC');
                        adesPvs{stn,sb} = sprintf('LI20:KLYS:93:ADES');
                    case 6
                        isAccPvs{bcIndex}{stn,sb} =  sprintf('FCUDKLYS:LI20:94:ONBEAM%i', beamCodes(bcIndex) );
                        statPvs{stn,sb} = sprintf('FCUDKLYS:LI20:94:STATUS');
                        strPvs{stn,sb} = sprintf('FCUDKLYS:LI20:94:STATUS.DESC');
                        adesPvs{stn,sb} = sprintf('LI20:KLYS:94:ADES');
                    case 7
                        isAccPvs{bcIndex}{stn,sb} =  sprintf('FCUDKLYS:LI20:4:ONBEAM%i', beamCodes(bcIndex) );
                        statPvs{stn,sb} = sprintf('FCUDKLYS:LI20:4:STATUS');
                        strPvs{stn,sb} = sprintf('FCUDKLYS:LI20:4:STATUS.DESC');
                        adesPvs{stn,sb} = sprintf('LI20:KLYS:41:ADES');
                end
            else % Conventional stations in LI00 - LI19
                isAccPvs{bcIndex}{stn,sb} =  sprintf('FCUDKLYS:%s:%i:ONBEAM%i', sbst{sb}, stn, beamCodes(bcIndex) );
                statPvs{stn,sb} = sprintf('FCUDKLYS:%s:%i:STATUS', sbst{sb}, stn );
                strPvs{stn,sb} = sprintf('FCUDKLYS:%s:%i:STATUS.DESC', sbst{sb}, stn );
                adesPvs{stn,sb} = sprintf('%s:KLYS:%i1:ADES', sbst{sb}, stn );
            end
        end
    end
end
% Create yet more arrays to hold PVs - these ones contain status messages
% of differing verbosities.
strPvsS = strrep(strPvs,'FCUDKLYS','KLYS');
strPvsS = strrep(strPvsS,':STATUS.DESC', '1:SSTATSTR');
% A little more hard-coding for weird stations
strPvsS{5,11} = sprintf('KLYS:LI20:93:SSTATSTR');
strPvsS{6,11} = sprintf('KLYS:LI20:94:SSTATSTR');
strPvsS{7,11} = sprintf('KLYS:LI20:41:SSTATSTR');
strPvsM = strrep(strPvsS,'SSTATSTR', 'MSTATSTR');
strPvsL = strrep(strPvsS,'SSTATSTR', 'LSTATSTR');
strPvsXL = strrep(strPvsS,'SSTATSTR', 'XLSTATSTR');
% Remove SBST 20 - those stations are covered elsewhere
pstrPvs = pstrPvs(1:end-1);
for bcIndex = 1:numel(beamCodes)
    pisAccPvs{bcIndex} = pisAccPvs{bcIndex}(1:end-1);
end
% Modify adesPvs & create an array to hold amplitude PVs - needed for
% manual correction of status color for low-amplitude stations
adesPvs(1:8,1) = deal({'LI00:KLYS:1:ADES'; 'LI00:KLYS:2:ADES'; ...
    'LI00:KLYS:11:ADES'; 'LI00:KLYS:12:ADES';  'LI00:KLYS:13:ADES'; ...
    'LI00:KLYS:97:ADES';  'LI00:KLYS:98:ADES';  'LI00:KLYS:99:ADES'});
amplPvs = strrep(adesPvs,'ADES','AMPL');
amplVals = ones(size(adesPvs));
adesVals = amplVals;
% Initialize just a few more things and we're good to go!
pDes = zeros(sbstNumel,1);
hdelay = zeros(size(strPvs)); % Heater delay times
for bcIndex = 1:numel(beamCodes)
     % Will store currently active stations on all beam codes - needed when
     % determining status string colors in main loop. Initialize at 1.
    activeStations{bcIndex} = hdelay + 1;
end
offOrMNTOrTBR = hdelay;
% Initialization complete, begin main loop now
counter = 1;
while(1)
    tic
    pause(0.1)
    bcIndex = mod(counter, numel(beamCodes)) + 1;
    beamCode = beamCodes(bcIndex);
    % First get info on all klystrons...
    [isACC,stat,swrd, hdsc,dsta1,dsta2]=deal(zeros(size(handles.klysS)));
    [colEdge,colBack,colText,strN,sizText]=deal(cell(size(handles.klysS)));
    useIndx = 1:numel(handles.klysS); % Station indices
    nulIndx = strmatch(' ' , handles.klysS);    
    offOrMNTOrTBR(nulIndx) = '';
    useIndx(nulIndx) = ''; % Remove unused station indices
    if mod(counter, 10)
        % Only check stations that are OFF or in MNT or TBR every 10 iterations
        useIndx(find(offOrMNTOrTBR)') = '';
    end
    try % Get all of the relevant info using a slightly modified version of klysStatGet
        [isACC(useIndx),stat(useIndx),swrd(useIndx), hdsc(useIndx), dsta1(useIndx),dsta2(useIndx)] = ...
            klysCud_klysStatGet(handles.klysS(useIndx),beamCode);
    catch
      fprintf(['Failed on call to control_klysStatGet(handles.klysS) ' ...
               '%s\n'],datestr(now) )
    end
    activeStations{bcIndex} = isACC;
    dsta = zeros([size(handles.klysS), 2]);
    dsta(:,:,1) = dsta1;
    dsta(:,:,2) = dsta2;
    isStat=bitget(stat,1) == 1; % Indices for stations with "OK" status
    try
        isPO15=bitand(swrd,bin2dec('11111')) ~= 0; % POI5 1 - 5 error
    catch
        fprintf(['Failed while defining isP015 %s\n'],datestr(now) )
    end
    strN(:) = cellstr(num2str(repmat(handles.klysN,length(handles.sbstN),1))); % Show klys number
    % Get status strings from status bits and output the ones that have changed
    try
        [strS, strM, strL, strXL] = klysCudString(stat,swrd,hdsc,dsta,handles);
    catch
        put2log(sprintf('Failed on STAT or HDSC to string conversion: sum(STATs)=%i, sum(HDSC)= %i', ...
            sum(sum(stat)), sum(sum(hdsc)) ));
        dbstack
        continue
    end  
    % Handle heater delays
    strS_size = size(strS);
    for jj = 1:strS_size(2)
        for kk = 1:strS_size(1)
            if strcmp(strS(kk,jj),'KHD')
                if hdelay(kk,jj) > 0  % If this is an ongoing KHD
                    tStart = uint64(hdelay(kk,jj)); % Find time elapsed
                    tElapsed = toc(tStart);
                    tForm = (tElapsed/60);
                    tCheck = mod(tForm*10,10);
                    if tCheck > 2   % First 12 secs will display 'KHD'
                        tForm = tForm - 0.5;
                        tForm = sprintf('%.0f', tForm);
                        timeR = [num2str(tForm) 'min']; % Put into strS
                        strS(kk,jj) = {timeR};
                    else
                        strS(kk,jj) = {'KHD'};
                    end
                else % First appearance of this KHD
                    hdelay(kk,jj) = tic;
                end
            elseif hdelay(kk,jj) > 0 % KHD is over, reset timer
                hdelay(kk,jj) = 0;
            end
        end
    end
    % Color of status string is based on status value (see $EDMFILES colors.list)
    statWarn = ones(size(isStat)) * 80;
    activeStationsSum = zeros(size(strPvs));
    for i = 1:numel(beamCodes)
        % Find all stations that are active on any beam code
        activeStationsSum = activeStationsSum | activeStations{i};
    end
    % Stations that are active on any beam code get red alarm text
    statAlarm = double(isPO15 & activeStationsSum) * 110;
    for i = 1:length(statusStr)
        statWarn(strmatch(statusStr{i},strS) ) = statusColor(i);
    end
    indx0 = strmatch('OK ', strS) ;
    strS(indx0) = strN( indx0 ); % Klystrons w/'OK' status just display the station number
    statVal = max(statWarn, statAlarm);
    % Fix AMM status color for stations with very low amplitude (kludge)
    ratios = ones(strS_size(1),strS_size(2));
    for col=1:strS_size(2)
        for row=1:strS_size(1)
            if ~strcmpi(adesPvs(row,col), ' ')
                if mod(counter, 100) == 1
                    adesVals(row,col) = lcaGet(adesPvs(row,col));
                end
                amplVals(row,col) = lcaGet(amplPvs(row,col));
                ratios(row,col) = amplVals(row,col)/adesVals(row,col);
                if (ratios(row,col) < 0) || isnan(ratios(row,col)), continue, end
                if (ratios(row,col) < 0.8) && strcmpi(strS(row,col), 'AMM')
                    statVal(row,col) = 110;
                end
            end
        end
    end
    % Find indices of stations that are OFF or in MNT or TBR - used to
    % increase loop efficiency by checking those less often.
    offOrMNTOrTBR = strncmp('OFF', strS, 3) | strncmp('MNT', strS, 3) | strncmp('TBR', strS, 3);
    offOrMNTOrTBR = offOrMNTOrTBR(:)';
    try % Update all the klystron PVs with the data we just retrieved
        for i = 1:length(useIndx)
            index = useIndx(i);
            lcaPut(statPvs(index), statVal(index))
            lcaPut(isAccPvs{bcIndex}(index), double(isACC(index)))
            lcaPut(strPvs(index), strS(index));
% Various PVs don't exist for FACET, hence the commented out stuff here
% (but I also don't think these PVs served a purpose previously)
%            lcaPut(strPvsS(index)', strS(index)');
%            lcaPut(strPvsM(index)', strM(index));
%            lcaPut(strPvsL(index), strL(index));
%            lcaPut(strPvsXL(index), strXL(index));
        end
%        if beamCode == 10
%            % BenNote - I'm not sure what this next PV is used for. Not knowing
%            % the dependencies, I'm leaving William's code in place for now.
%            linacKlysComp =  isACC(:,3:20); % LI02 to LI19
%            lcaPut('FCUDKLYS:MCC1:ONBC10SUMY', double(linacKlysComp(:))');
%        end
    catch fprintf(['Failed on lcaPut - statPVs or isAccPvs or strPvs ' ...
            '%s\n'],datestr(now));
    end
    % Next, get info on all sub-boosters...
    oldDes = pDes;
    try [pAct,pDes]=control_phaseGet(handles.sbstS(1:end)); % Returns actual and desired phase in deg
    catch fprintf(['Failed on [pAct,pDes]=control_phaseGet(handles.sbstS) ' ...
            '%s\n'],datestr(now));
    end
    if (sum(isnan(pDes))),
        fprintf('Warning control_phaseGet return NAN for pDes %s\n',datestr(now));
        pDes = oldDes;
    end
    try lcaPut(pActPvs,pAct);
    catch fprintf('Failed on lcaPut(pActPvs,pAct) %s\n',datestr(now))
    end
    if( sum(oldDes-pDes) || counter == 2 )
        try
            lcaPut(pLimHihiPvs, pDes + pTolSbsts);
            lcaPut(pLimLoloPvs, pDes - pTolSbsts);
        catch  fprintf('Failed on lcaPut pLimHihiPvs or Lolo %s\n',datestr(now)),
        end
    end
    % SBST green bars
    sbstSize = size(isACC);
    sbstSize = sbstSize(2);
    pisACC = zeros(sbstSize,1);
    for i = 1:sbstSize
        % For each SBST - does it have any stations on accelerate on this BC?
        pisACC(i,1) = max(isACC(:,i));
    end
    % SBST string PVs
    sbstSize = size(handles.sbstS);
    sbstSize(1) = sbstSize(1) - 1;
    [isACC,stat,swrd,hdsc,dsta1,dsta2]=deal(zeros(sbstSize));
    useIndx = 1:sbstSize(1);
    nulIndx = strmatch(' ' , handles.sbstS);
    useIndx(nulIndx) = ''; % Removes unused station indices
    try 
         [isACC,stat,swrd,hdsc,dsta1,dsta2]=deal(zeros(sbstSize));
         % 10/11/11 W. Colocho - Need to fix SBST string and isACC. control_klysStatGet.m does not
         % support SBST and status bits don't really translate.
    catch
      fprintf(['Failed on call to control_klysStatGet(handles.sbstS) ' ...
               '%s\n'],datestr(now) )
    end
    dsta = zeros([sbstSize, 2]);
    dsta(:,:,1) = dsta1;
    dsta(:,:,2) = dsta2;
    % Get string from status bits and output the ones that have changed.
    try
        [strS, strM, strL, strXL] = klysCudString(stat,swrd,hdsc,dsta, handles, 'SBST');
    catch
        put2log(sprintf('Failed on STAT or HDSC to string conversion: sum(STATs)=%i, sum(HDSC)= %i', sum(sum(stat)), sum(sum(hdsc)) )) ;
        dbstack
        continue
    end
    try  % Update the SBST PVs with the data we just retrieved
        lcaPut(pisAccPvs{bcIndex}(useIndx), double(pisACC(useIndx)));
        lcaPut(pstrPvs(useIndx), strS(useIndx));
    catch
        fprintf('Failed on lcaPut(sbstPvs,pAct) %s\n',datestr(now))
    end
    counter = counter + 1;
    if (counter > 50000), counter = 2; end
    lcaPut(['SIOC:' sys ':ML00:AO001'],counter) % Update FACET watcher counter
    toc
end % End of main loop
end

function [strS strM strL strXL] = klysCudString(stat,swrd,hdsc,dsta, handles, type) 
% info from REF_:[KLYSUTIL]KLYS_STRING.FOR
% Input: act, stat, swrd, hdsc, dsta, handles
% Output: strS - 3 leter character for CUD.
%             strM -
%             strL  - Used on other displays.
%            strXL - Long translation of status bit.
%format:
%     INformational HS=HSTA, ST=STAT, SW=SWRD, DS=DSTA, BA=BADB,
%     |             HD=HDSC
%     | PRIOrity.  note, okok = 999, so higher numbers are not
%     V |             visible on the single line display
%       V    Normal bit.  if specified bit <> shown, return string
%            | Secondary colors
%            V |Type: None, sTatus, Hardware, Software, Modulator,
%              V|          Phase and amplitude
%               V MINI,SHORT,MED..,Long strings
%                 |
%                 V
%
%   #'.         Priorities start at 0
%   #'  1000 _______________________________________________________
%   #'  1000 Stat_okok is at 999.  Single item searches stop here
%
% <counters>   1         2         3         4         5         6
%     123456789012345678901234567890123456789012345678901234567890123
%

%   NOTE: the values in these arrays MUST be ordered exactly
%         as the bits are defined in the database.
persistent sys
if isempty(sys)
    sys = getSystem();
end
persistent HSinfo STinfo SWinfo DSinfo BAinfo HDinfo; 
HSinfo = { ...   
'HS', 2000, 'Gh', 'ON ', 'ONLIN', 'Hsta online ', 'Hsta online';...
'HS',   10, 'Sh', 'MNT', 'MAINS', 'Maintenance ', 'Hsta maintenance mode';...
'HS',    1, 'Sh', 'OFF', 'OFFL ', 'OFFLINE     ', 'Hsta offline';...
'HS', 2000, ' N', 'ski', 'skip ', 'skip        ', ' None';...
'HS', 2001, 'Gh', 'ski', 'skip ', 'skip        ', 'Timing Fixup Disabled';...
'HS', 2001, 'Gh', 'ski', 'skip ', 'skip        ', 'Sled Tune Request';...
'HS', 2002, 'Gh', 'ski', 'skip ', 'skip        ', 'Pulsed Drive Attenuator';...
'HS', 2002, 'Gh', 'ski', 'skip ', 'skip        ', 'Pulsed Phase Shifter';...
'HS', 2003, 'Gh', 'ski', 'skip ', 'skip        ', 'equipped with PAD';...
'HS', 1020, 'WS', 'ski', 'skip ', 'skip        ', 'Single Beam Database Mode';...
'HS', 2003, 'Gh', 'ski', 'skip ', 'skip        ', 'equipped with MKSU';...
'HS', 2001, 'Gh', 'ski', 'skip ', 'skip        ', 'Process Mode Enabled';...
'HS', 2000, 'Gh', 'ski', 'skip ', 'skip        ', 'Sled cavity present';...
'HS', 2001, 'Gh', 'ski', 'skip ', 'skip        ', 'Electro-magnet klystron';...
'HS', 2001, 'Gh', 'ski', 'skip ', 'skip        ', 'Solid-State Subbooster';...
'HS', 2001, 'Gh', 'ski', 'skip ', 'skip        ', 'Auto-Saturate Disabled'};

STinfo = { ...
'ST',  999, 'Ss', 'OK ', '-----', '            ', 'STAT_okok';...
'ST',   10, 'Ss', 'MNT', 'MAINS', 'Maintenance ', 'Stat_Maintenance MODE';...
'ST',    1, 'Ss', 'OFF', 'OFFL ', 'OFFLINE     ', 'Stat_Unit Offline';...
'ST',  100, 'Ss', 'TOL', 'TOLS ', 'Out of Toler', 'Stat_Out of Tolerance';...
'ST',   40, 'Ss', 'CAM', 'CAMAC', 'BAD CAMAC   ', 'Stat_Bad Camac';...
'ST', 9990, 'SN', 'SWD', 'SWRD ', 'SWRD ERROR  ', 'Stat_SWRD Error';...
'ST',   50, 'Ss', 'DMT', 'DMTO ', 'DEAD MAN T/O', 'Stat_Dead Man TimeOut';...
'ST',   57, 'Rs', 'FOX', 'FOX_P', 'BAD FOX PHAS', 'Stat_Fox Phase Home Error';...
'ST', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'ST',   75, 'Ss', 'PHM', 'PHMEA', 'PHASE Mean  ', 'Stat_Phase Mean out_of_tol';...
'ST', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'ST', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'ST',   20, 'SH', 'IPL', 'IPL  ', 'IPL Required', 'Stat_IPL Required';...
'ST', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'ST',   30, 'Ss', 'UPD', 'UPDAT', 'UPDATE Req  ', 'Stat_Update Req ';...
'ST', 9999, 'SN', 'ski', 'skip ', 'skip        ', ''};
    
SWinfo = {... 
'SW',   55, 'SH', 'CBL', 'Cable', 'Bad Cable   ', 'BAD CABLE Status';...
'SW',   80, 'SH', 'MKS', 'MKSU ', 'MKSU Protect', 'MKSU Protect';...
'SW',   68, 'SH', 'TRG', 'TRIG ', 'NO Triggers ', 'NO Triggers';...
'SW',   67, 'SH', 'MOD', 'MOD F', 'MOD Fault   ', 'MODulator Fault';...
'SW', 2003, 'Ss', 'ski', 'skip ', 'skip        ', 'skip';... % lost acc. trigger;...
'SW',   80, 'SP', 'LRF', 'LOWRF', 'LOW RF Power', 'LOW RF Power';...
'SW',   70, 'SP', 'AMM', 'AMMEA', 'AMPL Mean   ', 'AMPL Mean';...
'SW',   75, 'SP', 'AMJ', 'AMJIT', 'AMPL Jitter ', 'AMPL Jitter';...
'SW',   90, 'SP', 'LST', 'LOST ', 'LOST Phase  ', 'LOST Phase';...
'SW', 9999, 'SN', 'PHM', 'PHMEA', 'PHASE Mean  ', 'PHASE Mean',% replaced by STA;... %wsc May 2009. from 70 to 9999
'SW',   75, 'SP', 'PHJ', 'PHJIT', 'PHASE Jitter', 'PHASE Jitter';...
'SW',   30, 'SN', 'S11', 'SWR11', 'SWRD BIT 11 ', 'skip';...
'SW',   30, 'SN', 'S12', 'SWR12', 'SWRD BIT 12 ', 'skip';...
'SW',   30, 'SN', 'S13', 'SWR13', 'SWRD BIT 13 ', 'skip';...
'SW',   69, 'Ws', 'SAM', 'NoSam', 'No Samp Rate', 'NO Sample Rate';...
'SW',  990, 'Ws', 'ACC', 'NoAcc', 'No Accelerat', 'NO Accelerate Rate'};

DSinfo = { ...
'DS', 1000, 'GH', 'SCT', 'SLED ', 'SLED Cavity ', 'SLED Cavity Tuned';...
'DS', 1000, 'GH', 'SCD', 'SLED ', 'SLED Cavity ', 'SLED Cavity Detuned';...
'DS',   65, 'RH', 'SML', 'SLED ', 'SLED Motor  ', 'SLED Motor not at limit';...
'DS',   65, 'RH', 'SUN', 'SLED ', 'SLED Upper  ', 'SLED Upper Needle Fault';...
'DS',   65, 'RH', 'SLN', 'SLED ', 'SLED Lower  ', 'SLED Lower Needle Fault';...
'DS',   65, 'RH', 'EMC', 'KLYS ', 'Electro-Magn', 'Electro-Magnet Current Tols';...
'DS',   65, 'RH', 'KLT', 'KLYS ', 'Klys Temp   ', 'Klystron Temperature';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS',   65, 'RS', 'RE ', 'RE   ', 'Klystron RE ', 'Klystron Reflected Energy';...
'DS',   65, 'RS', 'OV ', 'OVolt', 'Klystron OV ', 'Klystron Over-Voltage';...
'DS',   65, 'RS', 'OC ', 'OCurr', 'Klystron OC ', 'Klystron Over-Current';...
'DS',   67, 'YS', 'YY ', 'PPYY ', 'PPYY resync ', 'PPYY resync fault';...
'DS',   50, 'RS', 'ADC', 'ADC  ', 'ADC Read Err', 'ADC Read Error';...
'DS',   72, 'RS', 'AOT', 'AOT  ', 'ADC Out Tol ', 'ADC Out of Tolerance';...
'DS', 1000, 'YS', 'DPC', 'DPC  ', 'Phase Change', 'Desired Phase Change';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS',   61, 'RH', 'WSF', 'Water', 'WaterSummary', 'Water Summary Fault';...
'DS',   60, 'RH', 'WA1', 'Water', 'Water Acc1  ', 'Water Accelerator #1';...
'DS',   60, 'RH', 'WA2', 'Water', 'Water Acc2  ', 'Water Accelerator #2';...
'DS',   60, 'RH', 'WG1', 'Water', 'Water WG 1  ', 'Water Waveguide #1';...
'DS',   60, 'RH', 'WG2', 'Water', 'Water WG 2  ', 'Water Waveguide #2';...
'DS',   60, 'RH', 'WKL', 'Water', 'Water Klys  ', 'Water Klystron';...
'DS',   60, 'RH', '24V', '24V  ', '24V Battery ', '24 Volt Battery Fault';...
'DS',   60, 'RH', 'WGV', 'W-Vac', 'WG Vac      ', 'Waveguide Vacuum Fault';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS',   60, 'RH', 'KLV', 'K-Vac', 'Klys Vac    ', 'Klystron Vacuum Fault';...
'DS',   60, 'RH', 'KMC', 'K-Mag', 'KLYS MgntCur', 'Electro-Magnet Current';...
'DS',   60, 'RH', 'KMB', 'K-Mag', 'KLYS MgntBre', 'Electro-Magnet Breaker';...
'DS',   60, 'RS', 'MKT', 'MKSU ', 'MKSU TrigEna', 'MKSU Trigger Enable Fault';...
'DS', 1000, 'GM', 'AVL', 'Avail', 'Mod Availabl', '"MOD Available"';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', 'does not exist!';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', 'does not exist!';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', 'does not exist!';...
'DS',  600, 'CM', 'LCL', 'skip ', 'skip        ', '--->MODULATOR IN LOCAL <---';...
'DS', 9999, 'RM', 'ski', 'skip ', 'skip        ', 'Mod Bit 4';...
'DS',   65, 'RM', 'EVO', 'M-EVO', 'Modulatr Flt', 'Mod EVOC Fault';...
'DS',   65, 'RM', 'EVC', 'M-ELC', 'Modulatr Flt', 'Mod EOLC Fault';...
'DS',   65, 'RM', 'TOC', 'M-TOC', 'Modulatr Flt', 'Mod Trigger Overcurrent';...
'DS', 1001, 'GM', 'ski', 'skip ', 'skip        ', 'Mod HV ON';...
'DS',   65, 'RM', 'MOD', 'Modul', 'Modulatr Flt', 'Mod "EXTERNAL" Fault';...
'DS',   65, 'RM', 'FLK', 'M-FLK', 'Fault Lockou', 'Mod FAULT Lockout';...
'DS',   65, 'CM', 'HVR', 'HvRdy', 'HV Ready    ', 'Mod HV Ready';...
'DS', 1000, 'YM', 'MOK', 'ModOK', 'Mod Itlks OK', 'Mod Interlocks Complete';...
'DS',   65, 'RM', 'KHD', 'M-Htr', 'ModHeatDelay', 'Mod KLYS Heater Delay (1HR)';...
'DS',   65, 'RM', 'VVS', 'M-VVS', 'Mod VVS Flt ', 'Mod VVS Voltage Fault';...
'DS',   65, 'RM', 'MOD', 'Modul', 'Modulatr Flt', 'Mod CONTROL Power Fault';...
'DS', 1999, 'RS', 'VET', 'Veto ', 'Veto Assert ', 'Veto Asserted on Accelerate';...
'DS', 1998, 'RS', 'VED', 'V-Dis', 'Veto Disable', 'Veto Assertion Disabled';...
'DS', 1001, 'YS', 'T V', 'V-Tes', 'Veto Testing', 'Veto Test in Progress';...
'DS', 1010, 'GS', 'ski', 'skip ', 'skip        ', 'Mod Triggering';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None';...
'DS', 9999, 'SN', 'ski', 'skip ', 'skip        ', ' None'};

BAinfo = {...
'BA',  995, 'YB', 'ski', 'time ', 'poor time   ', 'poor Timing results';...
'BA',  995, 'RB', 'ski', 'time ', 'Bad time    ', 'Bad Timing results';...
'BA',  995, 'YB', 'ski', 'enld ', 'poor Enld   ', 'poor Enoload results';...
'BA',  995, 'RB', 'ski', 'enld ', 'Bad Enld    ', 'Bad Enoload results';...
'BA',  995, 'YB', 'ski', 'Stime', 'poorStbyTime', 'poor STBY Timing results';...
'BA',  995, 'RB', 'ski', 'Stime', 'Bad StbyTime', 'Bad STBY Timing results';...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None',;...
'BA',  995, ' N', 'ski', 'skip ', 'skip        ', ' None'};

HDinfo = {...
'HD', 3000, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %Phase trim disable;...
'HD',   10, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %duplicate of HSTA maint mod;...
'HD',    5, 'Sh', 'TBR', 'TBRpl', 'To Be Replcd', 'To Be Replaced';...
'HD',    5, 'Sh', 'ARU', 'RunUp', 'Await.Run Up', 'Awaiting Run Up';...
'HD', 3000, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %addtn phase contro;...
'HD', 3000, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %no touch up;...
'HD',    5, 'Sh', 'CKP', 'ChkPh', 'Check Phase ', 'Check Phase';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 3000, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %14:1 winding rati0
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 3000, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %designated spare
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 3000, 'GD', 'ski', 'skip ', 'skip        ', 'skip';... %solid state phase shifter
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None';...
'HD', 9999, 'GN', 'ski', 'skip ', 'skip        ', ' None' };

%     INformational HS=HSTA, ST=STAT, SW=SWRD, DS=DSTA, BA=BADB,
%     |             HD=HDSC

%trap for negative numbers on status bits
debugFlag = lcaGet(['SIOC:' sys ':ML00:AO324']);

msg1 = [datestr(now) ' Warning: Found word with negative bits. '];
warn=0;
if min(min(stat)) < 0 
    if debugFlag, disp(msg1), disp(handles.klysS(stat<0)), end
    stat(stat<0) = 0; warn = 1; 
end
if min(min(swrd)) < 0, 
    if(debugFlag), disp(msg1), disp(handles.klysS(swrd<0)), end
    swrd(swrd<0) = 0; warn = 2;
end
if min(min(hdsc)) < 0, 
    if(debugFlag), disp(msg1), disp(handles.klysS(hdsc<0)), end
    hdsc(hdsc<0) = 0; warn = 3;
end
if min(min(dsta(:,:,1))) < 0, 
    if(debugFlag), disp(msg1), disp(handles.klysS(dsta(:,:,1)<0)), end
    d1 = dsta(:,:,1); d1(d1<0) = 0;
    dsta(:,:,1) = d1; warn = 4;  %dsta(dsta(:,:,1)<0) = 0;    
end
if min(min(dsta(:,:,2))) < 0, 
    if(debugFlag), disp(msg1),  disp(handles.klysS(dsta(:,:,2)<0)), end
    d2 = dsta(:,:,2); d2(d2<0) = 0;
    dsta(:,:,2) = d2; warn = 5; %dsta(dsta(:,:,2)<0) = 0;  
end
strS = cell(size(stat)); %initialize string matrix
strM = strS;
strL = strS;
strXL = strS; 
if(debugFlag)
    warnStr = {'stat', 'swrd', 'hdsc', 'dsta1','dsta2'};
    if(warn)
      disp([datestr(now), ' Warning: at least one status bit is negative. warn code ', warnStr{warn}]);
      %keyboard
    end
end
try
    for i=1:16,
        ST(:,:,i) = bitget(stat,i) * STinfo{i,2};
        SW(:,:,i) = bitget(swrd,i) * SWinfo{i,2};
    end
    for i=1:32, HD(:,:,i) = bitget(hdsc,i) * HDinfo{i,2}; end
    for i=1:32, DS(:,:,i) = bitget(dsta(:,:,1),i) * DSinfo{i,2}; end
    for i=33:64, DS(:,:,i) = bitget(dsta(:,:,2),i-32) * DSinfo{i,2}; end
catch
    keyboard %unknown error
end
ST( (ST==0) ) = 9999;
SW( (SW==0) ) = 9999;
HD( (HD==0) ) = 9999;
DS( (DS==0) ) = 9999;
priority = min ( min ( min(ST,[],3),  min(SW,[],3) ) , ...
               ( min ( min(HD,[],3),  min(DS,[],3) ) ) ) ;
tt = [STinfo{:,2},  SWinfo{:,2}, DSinfo{:,2}, BAinfo{:,2}, HDinfo{:,2}];
tTag = {STinfo{:,1},  SWinfo{:,1}, DSinfo{:,1}, ...
        BAinfo{:,1}, HDinfo{:,1} };
if nargin < 6
    type = '';
end
if ~strcmp(type,'SBST')
    for ss = 1:length(handles.sbstN)
      for kk = 1:length(handles.klysN)
        prio = priority(kk,ss);
        word = tTag( (tt==prio) );
        s='';
        for ww = 1:length(word)
            s =  eval ([word{ww} 'info( ' word{ww},'(kk,ss,:)==prio ,4)']);
            sM = eval ([word{ww} 'info( ' word{ww},'(kk,ss,:)==prio ,5)']);
            sL = eval ([word{ww} 'info( ' word{ww},'(kk,ss,:)==prio ,6)']);
            sLong = eval ([word{ww} 'info( ' word{ww},'(kk,ss,:)==prio ,7)']);
            if(~isempty(s)), break, end
        end %for ww
        strS(kk,ss) = s(1);
        strM(kk,ss) = sM(1);
        strL(kk,ss) = sL(1);
        strXL(kk,ss) = sLong(1);
      end %for kk
    end %for ss
    %disp('in function'), keyboard
else %do sbst's
    for ss = 1:length(handles.sbstN)-1
      for kk = 1:1
        prio = priority(ss,kk);
        word = tTag( (tt==prio) );
        s='';
        for ww = 1:length(word)
            s =  eval ([word{ww} 'info( ' word{ww},'(ss,kk,:)==prio ,4)']);
            sM = eval ([word{ww} 'info( ' word{ww},'(ss,kk,:)==prio ,5)']);
            sL = eval ([word{ww} 'info( ' word{ww},'(ss,kk,:)==prio ,6)']);
            sLong = eval ([word{ww} 'info( ' word{ww},'(ss,kk,:)==prio ,7)']);
            if(~isempty(s)), break, end
        end %for ww
        strS(ss,kk) = s(1);
        strM(ss,kk) = sM(1);
        strL(ss,kk) = sL(1);
        strXL(ss,kk) = sLong(1);
      end %for kk
    end %for ss
end
end

function [isACC, stat, swrd, hdsc, dsta1, dsta2] = klysCud_klysStatGet(name,bc)
[act, stat, swrd, hdsc, dsta] = control_klysStatGet(name,bc);
dsta1 = dsta(:,1);
dsta2 = dsta(:,2);
isACC=false(size(stat)); % Create an array of logical zeros
isACC=isACC | bitand(act,1); % and then initialize it with logical ones for the klystrons on ACCEL on the specified beamcode
end