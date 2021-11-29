function klysJitterReport()
% klysJitterReport.m requests klystron  jitter FTPs and plots a report of
% FTP sigmas for Amplitude, Phase, Beam Volts and Bean Current.
% It also gives a list of 7 worst stations.

% William Colocho, June 2012
% Greg White, Aug 2017, Converted to using meme DS instead of
% aidalist to get pv names.

%Set up LTU energy BPM BSA
N =-63:1:0; %base vector to be offset by pulse ID
nMeas = 300;
%eDefN = eDefReserve('klysJitterReport');
%eDefS = num2str(eDefN);
%lcaPutSmart(['EDEF:SYS0:', eDefS, ':AVGCNT'], 1);
%lcaPutSmart(['EDEF:SYS0:' , eDefS, ':MEASCNT'], nMeas);
%lcaPutSmart(['EDEF:SYS0:' , eDefS, ':CNTMAX'], nMeas);
%bpmDl1PV = ['BPMS:LTU1:250:XHST', eDefS];
%sysPidPV = ['PATT:SYS0:1:PULSEIDHST', eDefS];
descStr = {'Phase Jitter', 'Amplitude Jitter',  'Beam Volts Jitter', 'Beam Current Jitter'};
forList = { 'KLYS:LI%:%:PHASFTPJ1SIGMA', 'KLYS:LI%:%:AMPLFTPJ1SIGMA', ...
                'KLYS:LI%:%:MKBVFTPJ1SIGMA' ,'KLYS:LI%:%:MKBCFTPJ1SIGMA' };
subplotStr = {'221', '222' , '223', '224'};
figH = figure('Position', [ 35 929 1126 650  ] ,'PaperPositionMode', 'auto','PaperOrientation','landscape' );
pvs = meme_names('name',forList{1}');
isActivePv = strrep(pvs, 'PHASFTPJ1SIGMA', 'BEAMCODE1_TSTAT');
isActive = lcaGetSmart(isActivePv);
amplPv = strrep(pvs, 'PHASFTPJ1SIGMA', 'AMPL');
ampl = lcaGetSmart(amplPv);
noAmplIndx = find(ampl < 5);
fprintf('Removed low amplitude stations:\n');
fprintf('%s\n', amplPv{noAmplIndx}) ;
pvs(noAmplIndx) = [];
isActive(noAmplIndx) = [];
plotEnergyJitter;
figure(figH)
for ii = 1:length(forList)
    clear value txtStr
    pvs = meme_names('name',forList{ii})';
    pvs(noAmplIndx) = [];
    requestFTP = strrep(pvs, 'J1SIGMA', 'J1PROC');
    waveFormPV = strrep(pvs, 'J1SIGMA', 'J1');
  
    % Use JA instead of J1 if pv is deactivated
    deactIndx = find(strcmp(isActive, 'Deactivated'));
    requestFTP(deactIndx) = strrep(requestFTP(deactIndx), 'J1PROC', 'JAPROC');
    waveFormPV(deactIndx) = strrep(waveFormPV(deactIndx), 'J1', 'JA');
    pvs(deactIndx) = strrep(pvs(deactIndx), 'J1SIGMA', 'JASIGMA');

    %eDefOn(eDefN);
    %pause(1)
    lcaPutSmart( requestFTP, 1);
    %while ~eDefDone(eDefN), pause(0.1); end

    %bpmDl1Val = lcaGetSmart(bpmDl1PV);
    %sysPid = lcaGetSmart(sysPidPV);

    pause(2)
    %pulseIds = ftpPulseID(waveFormPV);
    %value(ii,:) = lcaGetSmart(pvs);
    waveForms = lcaGetSmart(waveFormPV);
    %wavePids = zeros(size(waveForms) );
    %for jj = 1:length(waveFormPV), wavePids(jj,:) = N + pulseIds(jj); end
    
    %thisVal = value(ii,:);
    if ii == 1 || ii == 2
        thisVal = std(waveForms');
    else
        clear thisVal
        s = std(waveForms');
        m = mean(waveForms');
        for jj = 1:length(s)
            thisVal(jj) = 1e6 * s(jj) / m(jj);
        end
    end
    %remove NANs
    pvs(isnan(thisVal)) = [];
    
    thisVal(isnan(thisVal)) = [];
    [sortVal sortIndx] = sort(thisVal,'descend');
    
     deactVal = nan(size(thisVal)); % to plot flag for deactivated stations
     deactVal(deactIndx) = thisVal(deactIndx);
    fprintf('\n%s\n',(descStr{ii}) )
    for kk = 1:7, 
        stationI = sortIndx(kk);
        
        txtStr{kk} = sprintf('%s %.2f %s', pvs{stationI}(1:12), thisVal(stationI), isActive{stationI} ); 
        fprintf('%s %.2f %s\n', pvs{stationI}(1:12), thisVal(stationI),  isActive{stationI} ); 
    end
    figSP(ii) = subplot(subplotStr{ii});
    stem(sortVal)
    hold on
    plot(deactVal(sortIndx),'xr')
    hold off
    title(descStr{ii})
    A = axis;
    text(A(2)/3, A(4)/2, txtStr, 'FontSize', 12)
    xlim([0 length(sortVal)])
    if ii == 1 || ii == 2 , ylabel('Sigma')
    else ylabel('Parts per Million')
    end
    
    %for uData
    pvsSave(ii,:) = pvs;
    sortValSave(ii,:) = sortVal;
    sortIndxSave(ii,:) = sortIndx;
    txtStrSave(ii,:) = txtStr;
    waveFormPVSave(ii,:) = waveFormPV;
    waveFormsSave{ii} = waveForms;

end
uimenu('Label', 'MCC log', 'Callback', 'util_printMCC(gcf)');
uimenu('Label', 'LCLS log', 'Callback', 'util_printLog(gcf)');
menuH2 = uimenu('Label', 'Options', 'Tag','plotOptions');
optList = {'ftp', 'limits', 'tsreduced'};
optListLabel = {'Show FTP', 'Show Limits', 'TS Reduced'};
for i = 1:length(optList)
    uimenu(menuH2,'Label', optListLabel{i}, 'Callback', {@option,optList{i} } );
end

% Custom data cursor
dcm_obj = datacursormode(figH);
set(dcm_obj, 'UpdateFcn', @dataCursor)

% Now get BPM jitter data and correlate.
 %eDefRelease(eDefN)

%Todo

% Add callback for remove deactivated stations from plot
% add correation coeficient to plot.

if(0)
    w = waveForms(sortIndx(2),:);
    %w = fliplr(w);
    b = bpmDl1Val(1:nMeas);
    for ss = 1:length(b)-64;
        c = corrcoef(b(ss+[0:63]),w);
        C(ss) = c(2);
    end
    
    
end

uData.figH = figH;
uData.figSP = figSP;
uData.sortVal = sortValSave;
uData.sortIndx = sortIndxSave;
uData.pvs = pvsSave;
uData.isActive = isActive;
uData.subplotStr = subplotStr;
uData.descStr = descStr;
uData.txtStr = txtStrSave;
uData.limitsFlag = 0;
uData.tsFlag = 0;
uData.ftpFlag = 0;
uData.waveFormPV = waveFormPVSave;
uData.waveForms = waveFormsSave;

set(figH,'UserData',uData);

end

%% Custom Data Cursor
function output_txt = dataCursor(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
 dcm_obj = datacursormode(gcf);
 set(dcm_obj, 'SnapToDataVertex', 'on');
uData = get(gcf,'UserData');
subP = uData.figSP;
caVal = sprintf('%.3f', get(gcf,'CurrentAxes'));
% Find which subplot
for ii = 1:length(subP)
    subPVal = sprintf('%.3f', subP(ii));
    if subPVal == caVal
        subPNum = ii;
        break,
    end
end

sortIndx = uData.sortIndx(subPNum,:);
if uData.tsFlag
    tsIndx = uData.tsIndx(subPNum,:);
    sortIndx = sortIndx(tsIndx);
end
% pvName = uData.pvs(subPNum,sortIndx);
pvName = uData.waveFormPV(subPNum,sortIndx);

pos = get(event_obj,'Position');

switch uData.descStr{subPNum}
    case 'Phase Jitter'
        output_txt = { ['X: ', num2str(pos(1),4)], ...
        ['Y: ', num2str(pos(2),4)], ...
        ['PV: ', pvName{pos(1)} ] };
    case 'Amplitude Jitter'
        output_txt = { ['X: ', num2str(pos(1),4)], ...
        ['Y: ', num2str(pos(2),4)], ...
        ['PV: ', pvName{pos(1)} ] };
    case 'Beam Volts Jitter'
        output_txt = { ['X: ', num2str(pos(1),4)], ...
        ['Y: ', num2str(pos(2),4)], ...
        ['PV: ', pvName{pos(1)} ] };
    case 'Beam Current Jitter'
        output_txt = { ['X: ', num2str(pos(1),4)], ...
        ['Y: ', num2str(pos(2),4)], ...
        ['PV: ', pvName{pos(1)} ] };
    otherwise
        output_txt = { ['X: ', num2str(pos(1),4)], ...
        ['Y: ', num2str(pos(2),4)] };
end   

if uData.ftpFlag
    index = sortIndx(pos(1));
    waveFormPVName = uData.waveFormPV(subPNum,index);
    waveFormPVVal = uData.waveForms{:,subPNum}(index,:);
    descTitle = uData.descStr(subPNum);
    
    if uData.tsFlag
        waveFormPVVal = tsReduced(waveFormPVVal);
        descTitle = strcat(descTitle, ' (TS Reduced)');
    end
    
    ftp(waveFormPVName,waveFormPVVal,descTitle,subPNum);
end

end

%% option function
function option(src,evt,optStr)

uData = get(gcf,'UserData');
replotFlag = 0;

% Plot ftp waveform
if strcmp (optStr, 'ftp'),
    if strcmp(get(gcbo,'Checked'),'on'),
        set(gcbo,'Checked','off');
        uData.ftpFlag = 0;
    else set(gcbo,'Checked','on');
        uData.ftpFlag = 1;
    end
end

% Plot limits
if strcmp (optStr, 'limits'),
    if strcmp(get(gcbo,'Checked'),'on'),
        set(gcbo,'Checked','off');
        uData.limitsFlag = 0;
    else set(gcbo,'Checked','on');
        uData.limitsFlag = 1;
    end
    replotFlag = 1;
end

% Time Slot Reduced Jitter
if strcmp (optStr, 'tsreduced'),
    if strcmp(get(gcbo,'Checked'),'on'),
        set(gcbo,'Checked','off');
        uData.tsFlag = 0;
    else set(gcbo,'Checked','on');
        uData.tsFlag = 1;
    end
    replotFlag = 1;
end


if replotFlag
    for ii = 1:length(uData.descStr)
        sortVal = uData.sortVal(ii,:);
        sortIndx = uData.sortIndx(ii,:);
        subplot(uData.subplotStr{ii})
        
        if uData.tsFlag  % Time Slot Reduced Jitter
            waveFormTsReduced = tsReduced(uData.waveForms{ii});
            newVal = std(waveFormTsReduced,[],2);
            [newSortVal newSortIndx] = sort(newVal,'descend');
            uData.tsIndx(ii,:) = newSortIndx;
            %stem(newVal) %if we want to plot vs Z
            stem(newSortVal)
            xlim([0 length(newSortVal)])

            % List 7 worst stations
            sortIndx = sortIndx(newSortIndx);
            for kk = 1:7, 
                stationI = sortIndx(kk);
                txtStr{kk} = sprintf('%s %.2f %s', uData.pvs{ii,stationI}(1:12), ...
                                     newSortVal(kk), uData.isActive{stationI} ); 
            end
            A = axis;
            text(A(2)/2.5, A(4)/2, txtStr, 'FontSize', 12)

            if ii == 1 || ii == 2 , ylabel('Sigma')
            else ylabel('Parts per Million')
            end
            title([uData.descStr{ii} ' (TS Reduced)'])
        else  % Normal Plot
            stem(sortVal)
            A = axis;
            text(A(2)/3, A(4)/2, uData.txtStr(ii,:), 'FontSize', 12)
            xlim([0 length(sortVal)])
            if ii == 1 || ii == 2 , ylabel('Sigma')
            else ylabel('Parts per Million')
            end
            title(uData.descStr{ii})
        end
        
        if uData.limitsFlag  % Plot Limits
            clear rangeVal
            switch uData.descStr{ii}
                case 'Phase Jitter'
                    rangeStr = strrep(uData.pvs(ii,:), 'PHASFTPJ1SIGMA', 'PJTT');
                    rangeStr = strrep(rangeStr, 'PHASFTPJASIGMA', 'PJTT');
                    rangeVal = lcaGetSmart(rangeStr);
                case 'Amplitude Jitter'
                    rangeStr = strrep(uData.pvs(ii,:), 'AMPLFTPJ1SIGMA', 'AJTT');
                    rangeStr = strrep(rangeStr, 'AMPLFTPJASIGMA', 'AJTT');
                    rangeVal = lcaGetSmart(rangeStr);
                case 'Beam Volts Jitter'
                    rv = lcaGetSmart('SIOC:SYS0:ML01:AO096');
                    rangeVal(1,length(uData.pvs(ii,:))) = rv;
                case 'Beam Current Jitter'
                    rv = lcaGetSmart('SIOC:SYS0:ML01:AO097');
                    rangeVal(1,length(uData.pvs(ii,:))) = rv;
                otherwise
                    a = zeros(length(sortVal));
                    rangeVal = a(1:length(sortVal));
            end
            rangeVal = rangeVal(sortIndx);
            hold on
            linPlot = plot(rangeVal);
            set(linPlot, 'LineStyle','none', 'Marker','.', 'MarkerEdgeColor','red')
            hold off
        end
        
    end
end

set(uData.figH,'UserData',uData);

end

%% FTP Waveform
function ftp(pvName,pvVal,descTitle,subPNum)

    figure
    plot(pvVal)
    
    xlim([0 length(pvVal)])
    title([descTitle pvName])
    
    if subPNum == 1 || subPNum == 2
        unitPv = strcat(pvName,'.EGU');
        unitStr = lcaGetSmart(unitPv);
        ylabel(unitStr)
    else
        ylabel('Parts per Million')
    end
    
end

%% Time Slot Reduced Jitter
function newVal = tsReduced(val)
    timeSlotA = val(:,2:2:end); %even indexed pts
    timeSlotB = val(:,1:2:end); %odd indexed pts
    
    meanA = mean(timeSlotA,2);
    meanB = mean(timeSlotB,2);
    meanStep = abs(meanA - meanB);
    for jj =1:length(meanStep)
    if meanA(jj) > meanB(jj);  %meanA > meanB
        newA(jj,:) = timeSlotA(jj,:) - meanStep(jj)/2;
        newB(jj,:) = timeSlotB(jj,:) + meanStep(jj)/2;
    else
        newA(jj,:) = timeSlotA(jj,:) + meanStep(jj)/2;
        newB(jj,:) = timeSlotB(jj,:) - meanStep(jj)/2;
    end
    end
    
    newVal = val;
    newVal(:,2:2:end) = newA;
    newVal(:,1:2:end) = newB;
end

%% Plot Energy Jitter Correlation Coeficient.
function plotEnergyJitter
%return
pvs = meme_names('name','KLYS%ENLD');
%[rmat , z] = model_rMatGet(strrep(pvs,':ENLD','') );
[z] = model_rMatGet(strrep(pvs,':ENLD', ''), [],[],'Z');
vals = lcaGetSmart(pvs');
figH = figure;
uimenu('Label', 'MCC log', 'Callback', 'util_printMCC(gcf)');
uimenu('Label', 'LCLS log', 'Callback', 'util_printLog(gcf)');
% Custom data cursor
dcm_obj = datacursormode(figH);
set(dcm_obj, 'UpdateFcn', @dataCursorENGYJIT)
figDat.z = z;
figDat.pvs = pvs;
figDat.vals=vals;
set(figH, 'UserData', figDat)
stem(z,vals)
title({'Energy Jitter Power from Correlation to BPMS DL2 250'; ...
    'from bpmDisp.m'})
xlabel(' Z (m)')
ylabel('Jitter Power (%)')


end

function output_txt = dataCursorENGYJIT(obj,event_obj)
dcm_obj = datacursormode(gcf);
set(dcm_obj, 'SnapToDataVertex', 'on');
pos = get(event_obj,'Position');
figDat = get(gcf,'UserData');
pvIndx = intersect(find(pos(1)==figDat.z), find(pos(2)==figDat.vals));
output_txt = {['Z: ',sprintf('%.1f (m)', pos(1))],...
    ['Y: ',num2str(pos(2),4), ' %'], ...
    figDat.pvs{pvIndx}(1:end-12)};
end



