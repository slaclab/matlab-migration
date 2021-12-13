function klystronCud
% Function klystronCud(accelerator)
% Control script for klystron CUD edm display.
% Accelerator is LCLS or FACET.

% W. Colocho Nov. 2008
% Taken over by B. Ripman in 2012.

persistent sys
persistent accelerator
if isempty(sys)
    [sys, accelerator] = getSystem();
end
nLogLines = 24;
toggleLogFile = 1;
logStringHead = 'begin\nnumCols 3\nheaderAlign "ccclc"\nalign "ccclc"\nseparators "|"\ncomment "#"\nend\n';
logStringList(1:nLogLines) = {''};

err=getLogger(['klystronCud_', accelerator]);
fprintf('\nStarting Klystron Cud %s\n\n',datestr(now)')
format long
statusStr = {'OK '; 'ACC'; 'OFF'; 'MNT'; 'TBR'; 'ARU';  'CKP'};
statusColor=[ 50,    55,    85,    85,      85     85      85];
switch accelerator
    case 'LCLS'
        sbst = {'LI20', 'LI21', 'LI22', 'LI23', 'LI24', 'LI25', 'LI26', 'LI27', 'LI28', 'LI29', 'LI30'};
        handles.sbstN=(20:30)';
        removeList = {'20-1';'20-2';'20-3';'20-4';'24-7' };
        oneOrTwo = 2; % Used for SBST indexing
    case 'FACET'
        sbst = {'LI00', 'LI01', 'LI02', 'LI03', 'LI04', 'LI05', 'LI06', 'LI07', 'LI08', 'LI09', 'LI10', ...
        'LI11', 'LI12', 'LI13', 'LI14', 'LI15', 'LI16', 'LI17', 'LI18', 'LI19', 'LI20'};
        handles.sbstN=(00:20)'; % 21 does not refer to sector but extra index for Damping Ring stations.
        removeList = {'01-1';'01-7';'01-8';'10-8';'11-3';'19-7'; '20-1'; '20-8'};
        oneOrTwo = 1;
end

handles.sbstS= strrep(strcat(cellstr(num2str(handles.sbstN)),'-S'),' ', '0');
handles.klysN=(1:8)';
for j=handles.klysN'
    handles.klysS(j,:)=strrep(strcat(cellstr(num2str(handles.sbstN)),'-',num2str(j))',' ','0');
end
% Add and remove special stations
switch accelerator
    case 'LCLS',
        handles.klysS{8,handles.sbstN == 24} = 'TCAV3';
    case 'FACET'
        handles.klysS(2:7,21) = deal({'KLYS:DR01:1'; 'KLYS:DR03:1'; 'KLYS:DR13:1'; 'KLYS:LI20:93';  'KLYS:LI20:94'; 'KLYS:LI20:41'});
end

% Removes items from remove list
[c, ia, ib] = intersect(handles.klysS,removeList);
ia_stn = mod(ia,8); ia_stn(ia_stn==0) = 8;
for ii = 1:length(ia), handles.klysS(ia_stn(ii),fix((ia(ii)-1)/8)+1) = {' '};  end

klysNumel = numel(handles.klysS); %- length(removeList);
sbstNumel = numel(handles.sbstN);
blankMat = cell(8,sbstNumel);
[blankMat{:}] = deal(' ');
isAccPvs = blankMat;
statPvs = blankMat;
strPvs =  blankMat;
pActPvs = cell(sbstNumel,1);
pLimHihiPvs = pActPvs;
pLimLoloPvs = pActPvs;
pstrPvs = pActPvs;
pisAccPvs = pActPvs;
jj = 0;
for ii = 1:sbstNumel
    % First define PVs for sub-boosters
    switch accelerator
        case 'LCLS' ,
            pActPvs{ii} = sprintf('CUDSBST:%s:1:STATUS', sbst{ii} );
            pLimHihiPvs{ii} = sprintf('CUDSBST:%s:1:STATUS.HIHI', sbst{ii} );
            pLimLoloPvs{ii} =  sprintf('CUDSBST:%s:1:STATUS.LOLO', sbst{ii} );
            pstrPvs{ii} = sprintf('CUDSBST:%s:1:STATUS.DESC', sbst{ii} );
            pisAccPvs{ii} = sprintf('CUDSBST:%s:1:ONBEAM1', sbst{ii} );
        case 'FACET'
            pActPvs{ii} = sprintf('FCUDSBST:%s:1:STATUS', sbst{ii} );
            pLimHihiPvs{ii} = sprintf('FCUDSBST:%s:1:STATUS.HIHI', sbst{ii} );
            pLimLoloPvs{ii} =  sprintf('FCUDSBST:%s:1:STATUS.LOLO', sbst{ii} );
            pstrPvs{ii} = sprintf('FCUDSBST:%s:1:STATUS.DESC', sbst{ii} );
            if(ii==1 | ii==2)
                pisAccPvs{ii} = sprintf('FCUDSBST:%s:1:ONBEAM11', sbst{ii} );
            else
                pisAccPvs{ii} = sprintf('FCUDSBST:%s:1:ONBEAM10', sbst{ii} );
            end
    end

    % Next, define PVs for klystrons
    for stn = 1:8
        thisStation = sprintf('%s-%i',sbst{ii}(3:4),stn);
        if strmatch(thisStation, removeList), continue, end
        switch accelerator
            case 'LCLS', % LCLS stations are all on the same beamcode, so this is simple
                isAccPvs{stn,ii} =  sprintf('CUDKLYS:%s:%i:ONBEAM1', sbst{ii}, stn);
                statPvs{stn,ii} = sprintf('CUDKLYS:%s:%i:STATUS', sbst{ii}, stn );
                strPvs{stn,ii} = sprintf('CUDKLYS:%s:%i:STATUS.DESC', sbst{ii}, stn );
            case 'FACET'
                if(ii==1 | ii==2) % Stations in LI00 - LI01
                    isAccPvs{stn,ii} =  sprintf('FCUDKLYS:%s:%i:ONBEAM11', sbst{ii}, stn);
                    statPvs{stn,ii} = sprintf('FCUDKLYS:%s:%i:STATUS', sbst{ii}, stn );
                    strPvs{stn,ii} = sprintf('FCUDKLYS:%s:%i:STATUS.DESC', sbst{ii}, stn );
                elseif(ii==21) % Special stations: 'KLYS:DR01:1'; 'KLYS:DR03:1'; 'KLYS:DR13:1'; 'KLYS:LI20:93';  'KLYS:LI20:94'; 'KLYS:LI20:41'
                    switch stn,
                        case 2,
                            isAccPvs{stn,ii} =  sprintf('FCUDKLYS:DR01:1:ONBEAM11');
                            statPvs{stn,ii} = sprintf('FCUDKLYS:DR01:1:STATUS');
                            strPvs{stn,ii} = sprintf('FCUDKLYS:DR01:1:STATUS.DESC');
                        case 3,
                            isAccPvs{stn,ii} =  sprintf('FCUDKLYS:DR03:1:ONBEAM10');
                            statPvs{stn,ii} = sprintf('FCUDKLYS:DR03:1:STATUS');
                            strPvs{stn,ii} = sprintf('FCUDKLYS:DR03:1:STATUS.DESC');
                        case 4,
                            isAccPvs{stn,ii} =  sprintf('FCUDKLYS:DR13:1:ONBEAM10');
                            statPvs{stn,ii} = sprintf('FCUDKLYS:DR13:1:STATUS');
                            strPvs{stn,ii} = sprintf('FCUDKLYS:DR13:1:STATUS.DESC');
                        case 5,
                            isAccPvs{stn,ii} =  sprintf('FCUDKLYS:LI20:93:ONBEAM10');
                            statPvs{stn,ii} = sprintf('FCUDKLYS:LI20:93:STATUS');
                            strPvs{stn,ii} = sprintf('FCUDKLYS:LI20:93:STATUS.DESC');
                        case 6
                            isAccPvs{stn,ii} =  sprintf('FCUDKLYS:LI20:94:ONBEAM10');
                            statPvs{stn,ii} = sprintf('FCUDKLYS:LI20:94:STATUS');
                            strPvs{stn,ii} = sprintf('FCUDKLYS:LI20:94:STATUS.DESC');
                        case 7
                            isAccPvs{stn,ii} =  sprintf('FCUDKLYS:LI20:4:ONBEAM10');
                            statPvs{stn,ii} = sprintf('FCUDKLYS:LI20:4:STATUS');
                            strPvs{stn,ii} = sprintf('FCUDKLYS:LI20:4:STATUS.DESC');
                    end
                else % Conventional stations in LI02 - LI18
                    isAccPvs{stn,ii} =  sprintf('FCUDKLYS:%s:%i:ONBEAM10', sbst{ii}, stn);
                    statPvs{stn,ii} = sprintf('FCUDKLYS:%s:%i:STATUS', sbst{ii}, stn );
                    strPvs{stn,ii} = sprintf('FCUDKLYS:%s:%i:STATUS.DESC', sbst{ii}, stn );
                end

        end

    end
end

 switch accelerator
     case 'LCLS' ,
        strPvsS = strrep(strPvs,'CUDKLYS','KLYS');
     case 'FACET'
         strPvsS = strrep(strPvs,'FCUDKLYS','KLYS');
 end
 strPvsS = strrep(strPvsS,':STATUS.DESC', '1:SSTATSTR');
 if(strcmp(accelerator,'FACET'))
     strPvsS{5,21} = sprintf('KLYS:LI20:93:SSTATSTR');
     strPvsS{6,21} = sprintf('KLYS:LI20:94:SSTATSTR');
     strPvsS{7,21} = sprintf('KLYS:LI20:41:SSTATSTR');
 end
 strPvsM = strrep(strPvsS,'SSTATSTR', 'MSTATSTR');
 strPvsL = strrep(strPvsS,'SSTATSTR', 'LSTATSTR');
 strPvsXL = strrep(strPvsS,'SSTATSTR', 'XLSTATSTR');
% Remove SBST 20 if LCLS
pActPvs = pActPvs(oneOrTwo:end); pLimHihiPvs = pLimHihiPvs(oneOrTwo:end); pLimLoloPvs = pLimLoloPvs(oneOrTwo:end);
if(strcmp(accelerator, 'LCLS'))
    pstrPvs = pstrPvs(oneOrTwo:end);
    pisAccPvs = pisAccPvs(oneOrTwo:end);
else
    pstrPvs = pstrPvs(oneOrTwo:end-1);
    pisAccPvs = pisAccPvs(oneOrTwo:end-1);
end
% Define PVs for L2 & L3 phases
if(strcmp(accelerator, 'LCLS'))
    pActMeanPvs = { 'CUDSBST:L2:PHASE:MEAN' ; 'CUDSBST:L3:PHASE:MEAN' } ;
    pLimMeanPvs = { 'CUDSBST:L2:PHASE:MEAN.LOLO' ; 'CUDSBST:L3:PHASE:MEAN.LOLO'; ...
                    'CUDSBST:L2:PHASE:MEAN.HIHI' ; 'CUDSBST:L3:PHASE:MEAN.HIHI'};
end
pDes = zeros(sbstNumel+1-oneOrTwo,1); % SBST indexing to remove LI20 for LCLS
oldStr1 = '';
hdelay = zeros(size(strPvs)); % Heater delay time
counter = 1;


while(1) % Beginning of main loop
pause(1)

% First do klystrons...
    [isACC,stat,swrd, hdsc,dsta1,dsta2]=deal(zeros(size(handles.klysS)));

    [colEdge,colBack,colText,strN,sizText]=deal(cell(size(handles.klysS)));

    useIndx = 1:numel(handles.klysS);
    %nulIndx = strmatch(' ' , statPvs);
    nulIndx = strmatch(' ' , handles.klysS);
    useIndx(nulIndx) = ''; % Removes unused station indices (is a vector of removed station indices)

    try % Try getting all of the relevant info using a modified version of klysStatGet
        [isACC(useIndx),stat(useIndx),swrd(useIndx), hdsc(useIndx), dsta1(useIndx),dsta2(useIndx)]=klysCud_klysStatGet(handles.klysS(useIndx),accelerator);
    catch
      fprintf(['Failed on call to control_klysStatGet(handles.klysS) ' ...
               '%s\n'],datestr(now) )
      %rethrow(lasterror)
    end
    dsta = zeros([size(handles.klysS), 2]);
    dsta(:,:,1) = dsta1;
    dsta(:,:,2) = dsta2;

    %act=bitand(act,7); % Use only bits 1, 2, 3

    %Ignore bits for special stations. isS21==21 true for sector 21
    % ['isS', ss{:}, '=handles.sbstN', '==', ss{:},';']  translates to  isS24=handles.sbstN==24;
    if strcmp(accelerator,'LCLS')
     for ss = {'20', '21', '24'},
       eval(['isS', ss{:}, '=handles.sbstN', '==', ss{:},';']);
     end

     for bits = [6 8:11] %Allow for bit 7 (Amplitude Mean bit to be set)
       swrd(1:8,isS20) = bitset(swrd([1:8],isS20),bits,0);
       swrd(1:2,isS21) = bitset(swrd(1:2,isS21),bits,0); % 21-1 LRF,
       swrd([1:3 8],isS24) = bitset(swrd([1:3 8],isS24),bits,0);
     end

     stat(1:8,isS20) = bitset(stat(1:8,isS20),1,1);
     stat(1:2,isS21) = bitset(stat(1:2,isS21),1,1); %
     stat([1:3 8],isS24) = bitset(stat([1:3 8],isS24),1,1); %

     for bits = [4, 10],
       stat(1:8,isS20) = bitset(stat(1:8,isS20),bits,0); %
       stat(1:2,isS21) = bitset(stat(1:2,isS21),bits,0); %
       stat([1:3 8],isS24) = bitset(stat([1:3 8],isS24),bits,0); %
     end
    end

%     % Set logical status arrays
%     isACC=bitget(act,1) == 1; % Klys on ACCEL
     isStat=bitget(stat,1) == 1; % Status OK
     try
        isPO15=bitand(swrd,bin2dec('11111')) ~= 0; % POIP 1 - 5 error
     catch
         %keyboard
     end
     strN(:)=cellstr(num2str(repmat(handles.klysN,length(handles.sbstN),1))); % Show Klys number

%    Get string from status bits and output the ones that have changed.
     try
     [strS strM strL  strXL] = klysCudString(stat,swrd,hdsc,dsta, handles); %string Short, Medium, Large, XLarge
     catch
         put2log(sprintf('Failed on STAT or HDSC to string conversion: sum(STATs)=%i, sum(HDSC)= %i',sum(sum(stat)), sum(sum(hdsc)) )) ;
         dbstack
         continue
     end

     oldStr1 = strS;

     % Heater DelayklysCudStri
     strS_size = size(strS);
     for jj = 1:strS_size(2)
        for kk = 1:strS_size(1)
            if strcmp(strS(kk,jj),'KHD')
                if hdelay(kk,jj) > 0  %ongoing KHD
                    tStart = uint64(hdelay(kk,jj)); %find time elapsed
                    tElapsed = toc(tStart);
                    tForm = (tElapsed/60);
                    tCheck = mod(tForm*10,10);
                    if tCheck > 2   %first 12secs will display 'KHD'
                        tForm = tForm - 0.5;
                        tForm = sprintf('%.0f', tForm);
                        timeR = [num2str(tForm) 'min']; %put into strS
                        strS(kk,jj) = {timeR};
                    else
                        strS(kk,jj) = {'KHD'};
                    end
                else %initial KHD
                    hdelay(kk,jj) = tic;
                end
            elseif hdelay(kk,jj) > 0
                hdelay(kk,jj) = 0;
            end
        end
     end

%    Color of String is based on Status value  (see $EDMFILES colors.list)
     statWarn = ones(size(isStat)) * 80;
     statAlarm = double(isPO15 & isACC) * 110;

     for ii = 1:length(statusStr),
       statWarn(strmatch(statusStr{ii},strS) ) = statusColor(ii);
     end
     indx0 = strmatch('OK ', strS) ;
     strS(indx0) = strN( indx0 ); %'OK' gets station number.

     statVal = max(statWarn, statAlarm);

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Added on 11/16/12 by bripman to fix AMM status color for stations
     % with very low amplitude.
     switch accelerator
         case 'LCLS'

             amplPvs = strrep(statPvs,'CUDKLYS','KLYS');
             amplPvs = strrep(amplPvs,':STATUS','1:AMPL');
             adesPvs = strrep(statPvs,'CUDKLYS','KLYS');
             adesPvs = strrep(adesPvs,':STATUS','1:ADES');
             amplVals = ones(8,11);
             adesVals = ones(8,11);
             ratios = ones(8,11);

             for col=1:11
                 for row=1:8
                    if ~strcmpi(amplPvs(row,col), ' ')
                       amplVals(row,col) = lcaGet(amplPvs(row,col));
                       adesVals(row,col) = lcaGet(adesPvs(row,col));
                       ratios(row,col) = amplVals(row,col)/adesVals(row,col);
                       if (ratios(row,col) < 0) || (ratios(row,col) == NaN), continue, end
                       if (ratios(row,col) < 0.8) && strcmpi(strS(row,col), 'AMM')
                           statVal(row,col) = 110;
                       end
                    end
                 end
             end

         case 'FACET'
             % Finish this when FACET starts up again
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     try
     lcaPut(statPvs(useIndx)', statVal(useIndx)')
     lcaPut(isAccPvs(useIndx)', double(isACC(useIndx))')
     lcaPut(strPvs(useIndx)', strS(useIndx)');
     lcaPut(strPvsS(useIndx)', strS(useIndx)'); %Do only LCLS for EPICS long string status
     lcaPut(strPvsM(useIndx)', strM(useIndx)');
     lcaPut(strPvsL(useIndx)', strL(useIndx)');
     lcaPut(strPvsXL(useIndx)', strXL(useIndx)');

     % Why are the next three lines even here? They're redundant with the
     % switch statement that follows. Should take these out when I have a
     % stable version running.
     if strcmp(accelerator,'LCLS')
         lcaPut('CUDKLYS:MCC0:ONBC1SUMY',double(isACC(:))' )
     end

     switch accelerator
         case 'LCLS', lcaPut('CUDKLYS:MCC0:ONBC1SUMY',double(isACC(:))' );
         case 'FACET',
             linacKlysComp =  isACC(:,3:20); %LI02 to LI19
             lcaPut('FCUDKLYS:MCC1:ONBC10SUMY',double(linacKlysComp(:))' );
         otherwise, disp('Error: Accelerator not LCLS or FACET (?)')
     end
     catch fprintf(['Failed on lcaPut - statPVs or isAccPvs or strPvs ' ...
                    '%s\n'],datestr(now));
     end

   % Now do sub-boosters...
    pTolSbsts=1;
    pTolMean=[1;0.5];
    oldDes = pDes;
    try [pAct,pDes]=control_phaseGet(handles.sbstS(oneOrTwo:end)); % Returns actual and desired phase in deg
    catch fprintf(['Failed on [pAct,pDes]=control_phaseGet(handles.sbstS) ' ...
                   '%s\n'],datestr(now));
    end
    if (sum(isnan(pDes))),
        fprintf('Warning control_phaseGet return NAN for pDes %s\n',datestr(now));
        pDes = oldDes;
    end
    try lcaPut(pActPvs,pAct);
    catch fprintf('Failed on lcaPut(pActPvs,pAct) %s\n',datestr(now)), end


    if( sum(oldDes-pDes) || counter ==2 )
        try
          lcaPut(pLimHihiPvs, pDes + pTolSbsts);
          lcaPut(pLimLoloPvs, pDes - pTolSbsts);
        catch  fprintf('Failed on lcaPut pLimHihiPvs or Lolo %s\n',datestr(now)),
        end
        pDesMean=[mean(pDes(1:4));mean(pDes(5:10))];
        if(strcmp(accelerator, 'LCLS'))
           lcaPut(pLimMeanPvs, [pDesMean - pTolMean; pDesMean + pTolMean]);
        end
    end


    if(strcmp(accelerator, 'LCLS'))
        pActMean=[mean(pAct(1:4));mean(pAct(5:10))];
        try lcaPut(pActMeanPvs, pActMean);
        catch  fprintf('Failed on lcaPut pACtMeanPvs %s\n',datestr(now)), end
    end

    counter = counter + 1;
    if (counter > 50000), counter = 2; end


    %sbst green bars
    sbstSize = size(isACC);
    sbstSize = sbstSize(2);
    pisACC = zeros(sbstSize,1);
    switch accelerator
     case 'LCLS' ,
        lcaPut(['SIOC:' sys ':ML00:AO321'],counter) % Update watcher incrementor
        % don't include LI20
        for kk = 1:sbstSize-1
            pisACC(kk,1) = max(isACC(:,kk+1));
        end
     case 'FACET'
        lcaPut(['SIOC:' sys ':ML00:AO001'],counter) % Update watcher incrementor SIOC:SYS0:ML00:AO953
        for kk = 1:sbstSize
            pisACC(kk,1) = max(isACC(:,kk));
        end
    end

   % sub-booster string pv's
    sbstSize = size(handles.sbstS);
    sbstSize(1) = sbstSize(1) - 1;
    [isACC,stat,swrd,hdsc,dsta1,dsta2]=deal(zeros(sbstSize));

    useIndx = 1:sbstSize(1);
    nulIndx = strmatch(' ' , handles.sbstS);
    useIndx(nulIndx) = ''; %Removes unused station indices (is a vector of removed station indices)

    try
         [isACC,stat,swrd,hdsc,dsta1,dsta2]=deal(zeros(sbstSize));
         % 10/11/11 W. Colocho :Need to fix SBST string and isACC. control_klysStatGet.m does not
         % support SBST and status bits don't really translate.
    catch
      fprintf(['Failed on call to control_klysStatGet(handles.sbstS) ' ...
               '%s\n'],datestr(now) )
      %rethrow(lasterror)
    end
    dsta = zeros([sbstSize, 2]);
    dsta(:,:,1) = dsta1;
    dsta(:,:,2) = dsta2;

%    Get string from status bits and output the ones that have changed.
     try
     [strS strM strL  strXL] = klysCudString(stat,swrd,hdsc,dsta, handles, 'SBST'); %string Short, Medium, Large, XLarge
     catch
         put2log(sprintf('Failed on STAT or HDSC to string conversion: sum(STATs)=%i, sum(HDSC)= %i',sum(sum(stat)), sum(sum(hdsc)) )) ;
         dbstack
         continue
     end

    try
        lcaPut(pisAccPvs(useIndx), double(pisACC(useIndx)));
        lcaPut(pstrPvs(useIndx), strS(useIndx));
    catch
        fprintf('Failed on lcaPut(sbstPvs,pAct) %s\n',datestr(now))
    end
    %fprintf('test')
end % End of main loop


end

% function [strS strM strL strXL] = klysCudString(stat,swrd,hdsc,dsta, handles)
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

function [isACC, stat, swrd, hdsc, dsta1, dsta2] = klysCud_klysStatGet(name,accelerator)

% for LCLS
if(strcmp(accelerator, 'LCLS'))
    [act,stat,swrd,hdsc,dsta]=control_klysStatGet(name);
end

% for FACET
if(strcmp(accelerator, 'FACET'))
    bc11Indx = [strmatch('00',name); strmatch('01',name); strmatch('KLYS:DR01',name)]; % Index of pv's with beamcode 11
    % bc10Indx = setdiff(1:length(name),bc11Indx ); %index of pv's with beamcode 10
    k = 1;
    for jj = 1:length(name)
        if(jj==bc11Indx(k)) % Call with BC11 as an argument
            [act(jj,:),stat(jj,:),swrd(jj,:),hdsc(jj,:),dsta(jj,:)]=control_klysStatGet(name(jj),11);
            if(k<length(bc11Indx))
                k = k+1;
            end
        else % Call with BC10 as an argument
            [act(jj,:),stat(jj,:),swrd(jj,:),hdsc(jj,:),dsta(jj,:)]=control_klysStatGet(name(jj),10);
        end
    end
end

dsta1 = dsta(:,1);
dsta2 = dsta(:,2);
isACC=false(size(stat)); % Create an array of logical zeros
isACC=isACC | bitand(act,1); % and then initialize it with logical ones for the klystrons on ACCEL on the specified beamcode
end


% Work in progress - fixing this to get info on all beamcodes for all FACET
% stations.
%
% function [isACC, stat, swrd, hdsc, dsta1, dsta2] = klysCud_klysStatGet(name,accelerator)
%
% % LCLS
% if(strcmp(accelerator, 'LCLS'))
%     [act,stat,swrd,hdsc,dsta]=control_klysStatGet(name);
% end
%
% % FACET
% if(strcmp(accelerator, 'FACET'))
%   [act6,stat6,swrd6,hdsc6,dsta6]=control_klysStatGet(name,6);
%   [act10,stat10,swrd10,hdsc10,dsta10]=control_klysStatGet(name,10);
%   [act11,stat11,swrd11,hdsc11,dsta11]=control_klysStatGet(name,11);
% end
%
% dsta1 = dsta(:,1);
% dsta2 = dsta(:,2);
% isACC=false(size(stat)); % Create an array of logical zeros
% isACC=isACC | bitand(act,1); % and then initialize it with logical ones for the klystrons on ACCEL on the specified beamcode
% end
