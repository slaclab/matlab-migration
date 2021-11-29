function enoloadcheck()
% function to get current e-no-load and compare it to the value used by
% LEM.  This function might also be expanded to move EACTS to ENLD possibly
% with an averaging condition thrown in. 
%
%It also runs klysJitterReport() to generate sorted list of jitter
%stations.

%strtPV = strcat('KLYS:LI',num2str(sector),':',num2str(station),'1'):
%
%To convert this program to one that loads an enoload use lcaPut(strcat(strtPV,
%':ENLD'),av(n)) 
%use this procedure to get the HSTA or STAT that matches the codes:
%hsta = lcaGet('KLYS:LI26:11:HSTA')
%sprintf('HSTA=%4.4X',hsta)
%
%  Andy Hammond, William Colocho 
% Mod: T. Maxwell, 14-May-2017, aidalist -> meme, temp remove 28-2

% 

%   

%check if there is another instance running:
isRunning = lcaGetSmart('ALRM:SYS0:E_GAIN:ALHBERR');
if strcmp(isRunning, 'RUNNING'),
    fprintf('%s Not starting: There is another instance running, please check Matlab watcher.\n',datestr(now))
    return
end

fprintf('%s: starting enoloadcheck.m\n', datestr(now) ) ;
eactPV = meme_names('name','KLYS:LI%:EACT').';
% Temporarily ignore 28-2, LLRF MR station
eactPV = setdiff(eactPV,'KLYS:LI28:21:EACT');
enldPV = strrep(eactPV, 'EACT', 'ENLD');
strtPV = strrep(eactPV, 'EACT', 'AMEVFTPN1PROC');
piopPV = strrep(eactPV, 'EACT', 'AMEVFTPN1PS');
bVoltJitPV = strrep(eactPV, 'EACT', 'MKBVFTPJAPROC');%Beam Volts FTP
bCurrJitPV = strrep(eactPV, 'EACT', 'MKBCFTPJAPROC');%Beam Current FTP
phasFTPPV = strrep(eactPV, 'EACT',  'PHASFTPJAPROC');
amplFTPPV = strrep(eactPV, 'EACT', 'AMPLFTPJAPROC');
waveFormPV = {strrep(eactPV, 'EACT', 'PHASFTPJA');  strrep(eactPV, 'EACT', 'AMPLFTPJA'), 
                          strrep(eactPV, 'EACT', 'MKBVFTPJA')};
divrPv = strrep(eactPV, 'EACT', 'DIVR');
mkbvRawScale = 10/(2^12) * 5.0 * lcaGetSmart(divrPv);   
%request inition raw MKV FPT to initialize rawWf
lcaPutSmart(strrep(eactPV, 'EACT', 'MKBVFTPNAPROC'), 1); pause(3)
rawWf = lcaGetSmart(strrep(eactPV,'EACT','FTP21NARAW'));

 counter=0;
 diff(1:1:76) = 0;

enldv = lcaGetSmart(enldPV,0,'float');
for fn = 1:length(eactPV)
    for gn = 1:3
        valueEA(fn,gn) = enldv(fn);
    end
end

makeJitterReport(eactPV);
nPause = 0;

while 1
    beamVolts = lcaGetSmart(strrep(eactPV, 'EACT', 'BVLT'));
      %   rawFTP('BASE', eactPV, rawWf, mkbvRawScale, beamVolts), pause(10)

    enabled = lcaGetSmart('SIOC:SYS0:ML01:AO635');
    nPause = lcaGetSmart('SIOC:SYS0:ML01:AO623');

    beamRate = lcaGetSmart('EVNT:SYS0:1:LCLSBEAMRATE');
    if counter > 50000, counter = 0; else counter = counter+1; end
    lcaPut('SIOC:SYS0:ML01:AO624',counter) % watcher heartbeat
    

    if beamRate == 0 || ~enabled, continue, end
    tic;
    lcaPutSmart(strtPV,1);        pause(3)
    lcaPutSmart(bVoltJitPV,1); pause(3) %MKBV FTP
    lcaPutSmart(bCurrJitPV,1);  pause(3) %MKBC FTP
    lcaPutSmart(phasFTPPV,1);  pause(3)
    lcaPutSmart(amplFTPPV,1);  pause(3)
    
    elapsedTime = toc;
    pause(abs(nPause-elapsedTime));

    
    rawFTP('TOP', eactPV, rawWf, mkbvRawScale, beamVolts), pause(3)
    rawFTP('BS', eactPV, rawWf, mkbvRawScale, beamVolts), pause(3)
    rawFTP('TRIG', eactPV, rawWf, mkbvRawScale, beamVolts), pause(3)
    rawFTP('BASE', eactPV, rawWf, mkbvRawScale, beamVolts), pause(3)
    rawFTP('PFN', eactPV, rawWf, mkbvRawScale, beamVolts), pause(3)

%    PFNMATCHPERCENT  then A-B/C-B 
%    %where A = PFN match voltage, B = Base Line voltage, C = Beam Voltage at
%    %beam time.
     baseLine = lcaGetSmart( strrep(eactPV, 'EACT', 'MKBVBASELINE')) ;
     beamVolts = lcaGetSmart(strrep(eactPV, 'EACT', 'BVLT'));
     pfnVolts = lcaGetSmart(strrep(eactPV, 'EACT', 'MKBVPFNMATCH'));
     pfnMatchPercent = 100* (pfnVolts - baseLine) ./   (beamVolts - baseLine);
     lcaPutSmart(strrep(eactPV, 'EACT', 'PFNMATCHPERCENT'),pfnMatchPercent );
    
    makeJitterReport(eactPV)
    timeSlotReducedHistory(waveFormPV, beamVolts); %Calculates TS reduced jitter for PHAS AMPL and MKBV
    
    piops = lcaGetSmart(piopPV,0, 'float');
    enldv = lcaGetSmart(enldPV,0,'float');
    for dn = 1:length(piops)
        if piops(dn) == 1
            valueEA(dn,3) = valueEA(dn,2);
            valueEA(dn,2) = valueEA(dn,1);
            valueEA(dn,1) = lcaGet(eactPV(dn));
            
            EAmin = min(valueEA(dn,1:1:3));
            EAmax = max(valueEA(dn,1:1:3));
            if EAmin ~= EAmax
                av(dn) = mean(valueEA(dn,1:1:3));
                diff(dn) = abs(enldv(dn) - av(dn));
            end
        end
    end
    Arre(1) = sum(diff(1:1:6));
    Arre(2) = sum(diff(7:1:14));
    Arre(3) = sum(diff(15:1:22));
    Arre(4) = sum(diff(23:1:28));
    Arre(5) = sum(diff(29:1:36));
    Arre(6) = sum(diff(37:1:44));
    Arre(7) = sum(diff(45:1:52));
    Arre(8) = sum(diff(53:1:60));
    Arre(9) = sum(diff(61:1:68));
    Arre(10) = sum(diff(69:1:76));
    
    lcaPut('SIOC:SYS0:ML01:AO625', Arre(1))
    lcaPut('SIOC:SYS0:ML01:AO626', Arre(2))
    lcaPut('SIOC:SYS0:ML01:AO627', Arre(3))
    lcaPut('SIOC:SYS0:ML01:AO628', Arre(4))
    lcaPut('SIOC:SYS0:ML01:AO629', Arre(5))
    lcaPut('SIOC:SYS0:ML01:AO630', Arre(6))
    lcaPut('SIOC:SYS0:ML01:AO631', Arre(7))
    lcaPut('SIOC:SYS0:ML01:AO632', Arre(8))
    lcaPut('SIOC:SYS0:ML01:AO633', Arre(9))
    lcaPut('SIOC:SYS0:ML01:AO634', Arre(10))
    
end
end

function rawFTP(type, eactPV, rawWf, mkbvRawScale, beamVolts)
switch type

    case 'TRIG', % Mean or jitter of pulses near -4 us crt TREF (70% of the top amplitude)
        startStr = 'MKBVTRIGFTPSTARTTIME'; 
        outStr = 'MKBVTRIGJITT'; 
        meanOut = 'MKBVTRIG';
        reScale = 2.2; %ns/kV
        ftpStep = 0; 

    case 'TOP', % Mean or jitter of pulses at "Top" amplitude, -3.5 uS wrt TREF
        startStr = 'MKBVTOPFTPSTARTTIME'; 
        outStr = 'MKBVTOPJITT';         
        meanOut = 'MKBVTOP';
        reScale = 1; 
        ftpStep = 0; 

    case 'BS', % Mean or Jitter of pulses at backswing
        startStr = 'MKBVBSFTPSTARTTIME'; 
        outStr = 'MKBVTHYBACKSWING';         
        meanOut = 'MKBVBACKSWING';
        reScale = 1; 
        ftpStep = 0; 

    case 'BASE', % Mean or Jitter of pulses at -6 uS wrt TREF
        startStr = 'MKVBBASEFTPSTARTTIME'; 
        outStr = 'MKBVBASELINEJITT';         
        meanOut = 'MKBVBASELINE';
        reScale = 1;
        ftpStep = 0; 

    case 'PFN',  %mean of pulses between 3.5 and 3.8 uS wrt TREF
        startStr = 'MKVBPFNFTPSTARTTIME'; 
        outStr = 'MKBVPFNMATCHJITT';         
        meanOut = 'MKBVPFNMATCH';
        reScale = 1; 
        ftpStep = 4; 
  
end
startPVs = strrep(eactPV, 'EACT', startStr);
rawPVs = strrep(eactPV, 'EACT', 'FTP21NARAW');
outPVs = { strrep(eactPV, 'EACT', outStr)  strrep(eactPV,'EACT', meanOut)};

ftpStart = lcaGetSmart(startPVs);
rawWf(:,2) = ftpStart;
rawWf(:,3) = ftpStep;
lcaPutSmart(rawPVs, rawWf); %This triggers FTP
pause(2)
rawWf = lcaGetSmart(rawPVs);
for ii = 1:length(mkbvRawScale), value(ii,:) = rawWf(ii,17:end) .* mkbvRawScale(ii); end
[newVal, meanStep] = tsReduced(value,0);

switch type
    case 'BS' % Calculate % BACKSWINGPERCENT % Percent number of good pulses at backswing.
        nPts = size(newVal,2);
        goodPulsePercent = 100* sum(newVal <0,2)/nPts;
        lcaPutSmart(strrep(eactPV, 'EACT', 'BACKSWINGPERCENT'), goodPulsePercent);
        ppm = partsPerMillion(newVal, beamVolts) * reScale;

    case 'TRIG',
        ppm = std(newVal,[],2) * reScale; %Not really ppm but ns
    otherwise
        ppm = partsPerMillion(newVal, beamVolts) * reScale;
end
meanVal = mean(newVal,2);
lcaPutSmart(outPVs{1}, ppm);
lcaPutSmart(outPVs{2}, meanVal);

end





function makeJitterReport(pvs)
%makes sorted list of worse offenders for edm display
secondary = {'PJTN', 'AJTN', 'MKBVFTPJASIGMA'};
outPVr = strrep( 'SIOC:SYS0:ML00:CA0XX','XX', {'37', '38', '39'} ); %normalized
outPVn = strrep( 'SIOC:SYS0:ML00:CA0XX','XX', { '40','41','42'} ); %raw values
isActive = lcaGetSmart(strrep(pvs, 'EACT', 'BEAMCODE1_TSTAT'));
isActive = strrep(isActive,'Activated', 'Accelerate');
isActive = strrep(isActive,'Deactivated', 'Stand By');
normalize = [1 2 3];% Index to limit list 0 to not normalize
for ii = 1:length(secondary)
    jitterVals = lcaGetSmart(strrep(pvs,'EACT',secondary{ii}));
    writeSorted(jitterVals, outPVn{ii}, isActive,pvs, normalize(ii));
    writeSorted(jitterVals, outPVr{ii}, isActive,pvs, 0);

end
end

function timeSlotReducedHistory(waveFormPV, beamVolts)

for ii = 1:3
    startPVs = waveFormPV{ii,:};
    tsReducePVs = strrep(startPVs, 'FTPJA', 'TSREDUCED');
    tsDeltaPVs = strrep(startPVs, 'FTPJA', 'TSDELTA');
    waveForms = lcaGetSmart(startPVs);
    isBeamVolts = strcmp(startPVs{1}(14:17), 'MKBV');

    [waveFormsReduce meanStep] =  tsReduced(waveForms, isBeamVolts, beamVolts);
    
    
    if isBeamVolts,
        tsReduceJitter = partsPerMillion(waveFormsReduce, beamVolts);
    else
        tsReduceJitter = std(waveFormsReduce,[],2);
    end
    lcaPutSmart(tsReducePVs, tsReduceJitter);
    %lcaPutSmart(tsDeltaPVs, meanStep ./ beamVolts);
    lcaPutSmart(tsDeltaPVs, meanStep);
end

end
function ppm= partsPerMillion(wf, beamVolts)
sigma = std(wf,[],2); 
%m = mean(wf,2); 
ppm= 1e6*sigma./beamVolts;
end

function [newVal, meanStep] = tsReduced(val, isBeamVolts, beamVolts)
    timeSlotA = val(:,2:2:end); %even indexed pts
    timeSlotB = val(:,1:2:end); %odd indexed pts
    
    meanA = util_meanNan(timeSlotA,2);
    meanB = util_meanNan(timeSlotB,2);
    meanStep = abs(meanA - meanB);
    for jj = 1:length(meanStep)
        if meanA(jj) > meanB(jj) %meanA > meanB
            newA(jj,:) = timeSlotA(jj,:) - meanStep(jj)/2;
            newB(jj,:) = timeSlotB(jj,:) + meanStep(jj)/2;
        else
            newA(jj,:) = timeSlotA(jj,:) + meanStep(jj,:)/2;
            newB(jj,:) = timeSlotB(jj,:) - meanStep(jj,:)/2;
        end
    end
    
    newVal = val;
    newVal(:,2:2:end) = newA;
    newVal(:,1:2:end) = newB;
    if isBeamVolts
        meanStep = meanA./ beamVolts - meanB ./beamVolts;
    else
        meanStep = meanA - meanB;
    end
    
end

function writeSorted(jitterVals, outPV, isActive, pvs, normalize)
limitPV = {'PJTT', 'AJTT', 'BVJT'};
jitterVals(isnan(jitterVals)) = -1;
fromatStr = '%s  %.2f   %s  ';
if normalize
    limits = lcaGetSmart(strrep(pvs,'EACT',limitPV{normalize}));
    jitterVals = 100* jitterVals ./ limits ;
    fromatStr = '%s  %3.0f   %s  ';

end
[~, sortIndx] = sort(jitterVals,'descend');
txtStr = '';
for kk = 1:12,
    stationI = sortIndx(kk);
    txtStr = [txtStr sprintf(fromatStr, pvs{stationI}(6:12), jitterVals(stationI), isActive{stationI} )];
    %fprintf('%s %.2f %s\n', pvs{stationI}(6:12), jitterVals(stationI),  isActive{stationI} );
end
lcaPutSmart(outPV, double(int8(txtStr)));

end

