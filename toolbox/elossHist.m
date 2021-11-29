clear
fullYear = 0; % Set to one for full year data. May overwrite file for current year.
lastDataFileName = '/home/physics/colocho/matlab/elossHistory/lastDataTime.mat';
load(lastDataFileName);

if fullYear
    timeRange = {['01-Jan-' datestr(now,'yyyy') ' 00:00:00']; datestr(now)};
    
else
    timeRange = {datestr(lastDataTime); datestr(now)};
end
lastDataTime = now;
save(lastDataFileName,'lastDataTime')     

fileName = sprintf('LCLSPulseIntensity_%s',datestr(now,'yyyy'));
outDir = '/u1/lcls/physics/colocho/elossHistoryFigs/';

tRange =  datevec(timeRange);
cnt = 1;
years(cnt) = tRange(1,1);
months(cnt) = tRange(1,2);
while sum(abs(diff(tRange(:,1:2)))) ~= 0;
    if tRange(1,2) < 12
        tRange(1,2) = tRange(1,2) +1;
    else
        tRange(1,1:2) = [tRange(1,1) + 1 , 1];
    end
    cnt = cnt+1;
    years(cnt) = tRange(1,1);
    months(cnt) = tRange(1,2);
end
       
        
for ii =1:length(months), 
    theDir(ii) = {sprintf('/u1/lcls/matlab/data/%d/%d-%02d',years(ii), years(ii), months(ii) ) }; 
end

 
titleStr = 'Energy Loss Scan History'; %09/10 to 11/10 ';
disp('Finding files...')
fileNames = [];
for ii = 1:length(theDir)
    try
    [status, result] = unix(['find ', theDir{ii}, ' -name "E_loss*"']);
    if status, continue, end
    n =  findstr('/u1',result);
    fprintf('%i ', length(n));
    for jj = 1:length(n)
        fileNames = [fileNames; result(n(jj):n(jj)+74)];
    end
%     nFiles = length(result)/75; fprintf('%i ', nFiles);
%     fileNames = [fileNames; reshape(result,75,nFiles)'];
    catch
        keyboard
    end
end

fileNames = fileNames(:,1:end-1); %Removes '\n' character from end of name.

%Only keep filenames with times inside timeRange
fileDateTime = fileNames(:,54:70);
fileDateTimeDN = datenum(fileDateTime,'yyyy-mm-dd-HHMMSS');
timeRangeDN = datenum(timeRange);
keepIndx = find(fileDateTimeDN > timeRangeDN(1) & fileDateTimeDN < timeRangeDN(2) );
fileNames = fileNames(keepIndx,:);


%remove known bad fits:
badFiles = {'/u1/lcls/matlab/data/2011/2011-06/2011-06-13/E_loss--2011-06-13-004031.mat'};
badI = strmatch(badFiles,fileNames);
fileNames(badI,:) = [];

[nFiles, cols] = size(fileNames); 

fprintf('Found %i files\n', nFiles)

list={'BDES' 'dE' 'ddE' 'Ipk' 'GD' 'dGD' 'dE_Gauss' 'GD_Eloss' ...
      'dGD_Eloss' 'charge', 'E0'};
  
%loopRange = useDateI;  % Special coherent tuning dates
loopRange = 1:nFiles;  %1st file to start
for ii = 1:length(loopRange)
    clear handles, 
    clear data;
    load(fileNames(loopRange(ii),:));
    if (~isfield(data,'BDES')), continue, end
    for j=list
        handles.(j{:})=data.(j{:});
    end
    handles.time=datestr(data.ts);


    iOK = find(handles.dE);
    badSet=0;
    if length(iOK) > 4
        if any(handles.ddE(iOK)==0)
            %[q,dq,xf,yf] = gauss_plot(handles.BDES(iOK),handles.dE(iOK));                   % fit Gaussian without error bars (some are zero)
            [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_gaussFit(handles.BDES(iOK), handles.dE(iOK), 1, 0, handles.ddE(iOK), 0);
        else
            %[q,dq,xf,yf] = gauss_plot(handles.BDES(iOK),handles.dE(iOK),handles.ddE(iOK));  % fit Gaussian with error bars
            [par, yFit, parstd, yFitStd, mse, pcov, rfe] = util_gaussFit(handles.BDES(iOK), handles.dE(iOK), 1, 0);
        end
        if length(par) < 4, 
            badSet=1;
        else
       
        q = circshift(par, [1 1])';
        dq = circshift(parstd, [1 1])';
        xf = linspace(min(handles.BDES(iOK)), max(handles.BDES(iOK)));
        yf = par(1) .* exp(-(xf-par(2)).^2./2./par(3).^2) + par(4);
        handles.offs = q(1);
        end
    else
        badSet = 1;
    end
    
    if badSet
        q  = [0 0 0 0];   % no good fit yet
        dq = [0 0 0 0];
        xf = 0;
        yf = 0;
        handles.offs = mean(handles.dE(iOK));
    end

    
    
    handles.Eloss  =  q(2); %MeV
    handles.dEloss = dq(2);
    handles.xray_energy = q(2)*handles.charge; %mJ
    handles.mean_Ipk = mean(handles.Ipk((handles.Ipk~=0))) ;
       
    ElossE0(ii) = handles.E0; %GeV

    ElossEloss(ii) = q(2); %MeV
    ElossXOffset(ii) = q(3);
    ElossSigma(ii) = q(4);
    if handles.xray_energy > 25,  
        ElossXrayEnergy(ii) = nan; 
    else
        ElossXrayEnergy(ii) = handles.xray_energy;
    end
    ElossIpk(ii) = handles.mean_Ipk; %Amps
    ElossCharge(ii) = handles.charge;
    timeStamp{ii} = handles.time;
    ElossE0Photon(ii) = electron2PhotonEnergy(ElossE0(ii) );
    ElossBunchLength(ii) =((ElossCharge(ii)*10^-9)/ElossIpk(ii))*10^15;
    Ephoton = 4.13566733E-15*2.99792458E8/(0.03/2/(handles.E0/511E-6)^2*(1 + (3.5^2)/2));
    ElossNPhotons(ii) = handles.Eloss*handles.charge*1E-3/1.602E-19/Ephoton; 
    fprintf('%i ',ii); if ~mod(ii,50), disp(' '); end
end
%%

close all
if isempty(fileNames), disp('No new files found, ending'); return, end
% Print table 
if fullYear
    fid1 = fopen([outDir fileName '.csv'],'w');
    fprintf(fid1,'Energy (eV),     Ipk (A),    e- bl (fs),   E-loss (mJ),  Charge (nC), Time Stamp\n')    ;    
else
    fid1 = fopen([outDir fileName '.csv'],'a');
end
%Table

fprintf('\nEnergy    Ipk   e- bl   E-loss   Charge\n')
fprintf('   GeV       A      fs       mJ      nC\n')
chargeIndx = {1:length(ElossCharge)};
jj = 1:length(chargeIndx);
II = chargeIndx{jj};
N = length(ElossE0(II));
badDate = '01-Jan-2000 00:00:00';
timeStamp(ElossCharge == 0) = {badDate};
for ll = 1:length(timeStamp), dateN(ll) = datenum(timeStamp(ll)); end
dateN = dateN((II));
[theSort, sortIndx] = sort(dateN);
    for kk = 1:N
        ii = II(sortIndx(kk ));
        if(strcmp(badDate, timeStamp{ii})), continue, end
        fprintf('%6.3f  %6.0f  %6.0f   %6.3f  %6.3f   %s\n', ElossE0(ii), ElossIpk(ii),ElossBunchLength(ii),  ElossXrayEnergy(ii), ElossCharge(ii), timeStamp{ii})
        fprintf(fid1,'%6.3f,  %6.0f,  %6.0f,   %6.3f,  %6.3f,   %s\n', ElossE0Photon(ii), ElossIpk(ii),ElossBunchLength(ii),  ElossXrayEnergy(ii), ElossCharge(ii), timeStamp{ii});
    end
  
fclose(fid1);
if fullYear
    save(['/home/physics/colocho/matlab/elossHistory/' fileName])
else
    save(['/home/physics/colocho/matlab/elossHistory/' fileName '_OneDay']) 
end 

fprintf('\n%s\nSaved files named %s%s [.csv] and %s [.mat]\n', datestr(now), outDir,fileName, pwd)


%sendToEpics;
