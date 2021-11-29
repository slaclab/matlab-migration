function pulseMagnetKickCheck(~)
% 
%Use the 33 undulator BPMs to generate an error signal. If the error sign
%exceeds a threshold, PM1/PM2 is DISABLED and triggers to the AirCore correctors
%are withheld. ESA rate is not suppressed. Manual intervention is required to
%ENABLE extraction.
%
disp('pulseMagnetKickCheck.m 06/01/2018 v1.7');
%
% 06/01/18 - Exclude MPS_BYKIK events.
% 07/17/15 - temp remove Delta UND BPM, reset strikes if not writing NaNs
% 07/14/15 - Trip on NaNs, after two strikes
% 06/17/15 - set up Watchdog

%
global eDefQuiet %#ok % keeps the EDEF calls from chattering
lcaSetSeverityWarnLevel(5); % disables almost all warnings
watchdog_pv = 'SIOC:SYS0:ML01:AO249';
W = watchdog(watchdog_pv, 1, 'pulseMagnetKickCheck.m');
if get_watchdog_error(W)
    disp('pulseMagnetKickCheck is already running somewhere, exiting this instance')
    return
end

runCounter = 0;
fprintf('%s started\n',datestr(now));
cycle = 0;
delay = 0.5;
agedErrOld = zeros(4,1);
strikes = 0;
trip = 0;

outPVs = strcat('SIOC:SYS0:ML01:AO3',{'23','24','25','26','27','19'});
agePVs = strcat('SIOC:SYS0:ML01:AO3',{'29','30','31','32'});

PVS = aidalist('BPMS:UND1:%:XHSTBR');
PVS(strncmp(PVS,'BPMS:UND1:3395:XHSTBR',15)) = []; %remove Pohang BPM
%PVS(strncmp(PVS,'BPMS:UND1:3390:XHSTBR',15)) = []; %it's back
p = strrep(PVS, ':XHSTBR', '');

[junk1 z] = model_rMatGet(p,[],[],'z'); %#ok<*ASGLU>
[junk2 iz] = sort(z);
PVS = PVS(iz);

PVS = [PVS strrep(PVS,'X','Y') strrep(PVS,'X','TMIT')];
%[eDefN eDefS] = findEdef();

eDefN = eDefReserve('ESA PM Orbit Check');
eDefS = num2str(eDefN);
lcaPutSmart(['EDEF:SYS0:', eDefS, ':AVGCNT'], 1);
%lcaPutSmart(['EDEF:SYS0:', eDefS, ':EXCLUSION5'], 4194304); %4194304 == 0x400000 == The MPS_BYKIK mask for exclusion 5.
%nMeas  = lcaGetSmart('SIOC:SYS0:ML01:AO069');
PVS = strrep(PVS,'HSTBR', ['HST' eDefS]);
nbpms = length(PVS)/3;
tr = 2*nbpms+1:3*nbpms;  %#ok<NASGU>
%initialize the big arrays:    
    ESArate_init = lcaGetSmart('EVNT:SYS0:1:LCALKIKRATE'); %PM1 Kick rate, actually
    if ESArate_init > 1
        npts=120/ESArate_init;
        MAX=npts*10;
    else
     npts = 120;
     MAX=npts*4;
    end

bpmdata1 = zeros(nbpms*3,MAX+1);


eDefOn(eDefN);

while 1
    cycle = cycle + 1;
    pause(delay)
    W = watchdog_run(W);
    if get_watchdog_error(W)
        disp(['Some sort of watchdog error ', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        break;  % Exit program
    end
    interlockEnabled = lcaGetSmart('SIOC:SYS0:ML01:AO333');
    autoRestartEnabled = lcaGetSmart('SIOC:SYS0:ML01:AO334');
    gain = lcaGetSmart('SIOC:SYS0:ML01:AO328');
    
    ESArate = lcaGetSmart('EVNT:SYS0:1:LCALKIKRATE'); %PM1 Kick rate, actually
    if ESArate > 1
        npts=120/ESArate;
        MAX=npts*10;
    else
        npts = 120;
        MAX=npts*4;
    end
    
    %reinitialize BPM data matrix if the rate has changed
    if ESArate ~= ESArate_init
        bpmdata1 = zeros(nbpms*3,MAX+1);
    end

    %MAX=npts*10;
    lcaPutSmart(['EDEF:SYS0:' , eDefS, ':MEASCNT'], MAX);
    %avgdata = zeros(npts,);
    
    done = 0;
    while ~done , done = eDefDone(eDefN);     pause(5), end
    bpmdata = lcaGetSmart(PVS);
    pause(3);
    eDefOn(eDefN);


    offsetcheck = zeros(1,3*nbpms); 
 
   
    %
    try
        for ii = 1:nbpms
            I=ii+2*nbpms;
            maybeoffset = find(bpmdata(I,1:MAX) < 9e6);
            if isempty(maybeoffset)
                maybeoffset = 1;
            else
                mo1 = maybeoffset(find(diff(maybeoffset)==npts)); %#ok<*FNDSB>
            %try this to extract offset during Abort Every N...
                 if isempty(mo1)
                    mo2 = reshape(maybeoffset(1:6),2,3);
                    mo1 = mo2(find(diff(mo2,1,2)==npts));
                 end
                 maybeoffset = mo1(1);
            end
            offset = maybeoffset(1);
            bpmdata1(ii+2*nbpms,:) = bpmdata(ii+2*nbpms, offset:offset+MAX);
            bpmdata1(ii+nbpms,:) =  bpmdata(ii+nbpms, offset:offset+MAX);
            bpmdata1(ii,:) =  bpmdata(ii, offset:offset+MAX);
            offsetcheck(ii) = offset;
        end 
    catch %#ok
        disp(['Something failed in the bpmdata sorting ',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF') ])
        %disp(['MATLAB Error was:', err.message])
        %disp(size(offsets))
        %keyboard
    end
    bpmAlignError = offsetcheck(find(diff(offsetcheck) > 0));
    offset = offsetcheck(1);
    if ~isempty(bpmAlignError)
        disp(['Warning! BPMs not lined up!  ',datestr(now,'dd-mmm-yyyy HH:MM:SS.FFF') ])
    end 
    try
        for ii=1:npts
            avgdata(ii,:) = mean(bpmdata1(:,ii:npts:MAX),2); %#ok<AGROW>
        end
    catch 
        disp(['Failure while averaging the BPM data  ',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')])
        %keyboard
    end
    %for ii = 1:npts
    %VALs(:,ii) = 1000 * (avgdata(:,ii) - mean(avgdata(:,5:23),2));
    %    VALs(:,ii) = 1000 * (avgdata(ii,:) - mean(avgdata(5:23,:)));
    %end
    VALn1 = 1000 * (avgdata(2,:) - mean(avgdata(5:23,:)));
    VALn2 = 1000 * (avgdata(3,:) - mean(avgdata(5:23,:)));
    VALn23 = 1000 * (avgdata(17,:) - mean(avgdata(5:23,:))); 
    
    % output to epics;
    xr = 1:nbpms;
    yr = nbpms+1:2*nbpms;
    runCounter = runCounter + 1;
    outVector = [ mean(abs(VALn1(xr))); mean(abs(VALn1(yr))); mean(abs(VALn2(xr))); mean(abs(VALn2(yr))); runCounter; offset ];
    lcaPutSmart(outPVs, outVector);
    try
        lcaPutSmart('BPMS:UND1:1:ALINEJITTER', [VALn1(1,xr)  nan]);
        lcaPutSmart('BPMS:UND1:2:ALINEJITTER', [VALn1(1,yr)  nan]);
        lcaPutSmart('BPMS:UND1:3:ALINEJITTER', [VALn2(1,xr)  nan]);
        lcaPutSmart('BPMS:UND1:4:ALINEJITTER', [VALn2(1,yr)  nan]);
        lcaPutSmart('BPMS:UND1:5:ALINEJITTER', [VALn23(1,xr)  nan]);
        lcaPutSmart('BPMS:UND1:6:ALINEJITTER', [VALn23(1,yr)  nan]);
    catch  %#ok<*CTCH>
        disp(['Problem writing to ALINEJITTER arrays ', num2str(outVector)])
    end
    
    %Implement error average and ageing.
    %
    % Need to catch the NaNs to keep them from corrupting the agedErr pool
    %
    errVals =   outVector(1:4);
    if any(isnan(errVals))
        strikes = strikes + 1;
        disp(['Getting NaNs in the error values, strike ', num2str(strikes),datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        agedErr = agedErrOld;
    else
        %    agedErr =  (1 - gain) * agedErrOld +  gain  * (errVals - agedErrOld);
        % that was producing an offset in the aged values, this is better:
        agedErr =  (1 - gain) * agedErrOld +  gain  * errVals;
        agedErrOld = agedErr;
        strikes = 0;
    end
    try
        lcaPutSmart(agePVs, agedErr);
        %lcaPut(agePVs', agedErr);  %try being less Smart
    catch 
        disp(['Problem writing ', num2str(agedErr), ' to age PVs',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')])
    end
    stopThreshold = lcaGetSmart(strcat(agePVs, '.HIHI'));
    restartThreshold= lcaGetSmart(strcat(agePVs, '.HIGH'));
    if ESArate > 10
        trip = 1;
        outMessage = 'PM rate > 10 Hz is not allowed, disabling kickers. ';
    else trip = 0;
    end
    inError = sum(agedErr > stopThreshold);
    if inError
        trip = 1;
        outMessage = 'Bad Orbit! PM1 is disabled. '; 
    end
    okRestart = sum(agedErr < restartThreshold);
  
    %Trip if you've failed to update orbit errors twice
    if strikes > 2
        trip = 1;
        outMessage = 'Average Values not updating! PMs disabled. ';
    end
    % 
    
    if interlockEnabled
        if trip
            fprintf('%s Just disabled ESA pulse magents\n',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF'));
            lcaPutSmart('PS:BSY0:3:MPSENABLE', 0);  % Disable PM1/2
            lcaPutSmart('PS:BSY0:6:MPSENABLE', 0);  % Disable PM4
            lcaPutSmart('SIOC:SYS0:ML01:AO321', 1); % latching indicator of trip
            lcaPutSmart('SIOC:SYS0:ML01:AO322', 1); % this one clears if orbit is OK
%     check if really disabled... 2018 it's being slow to latch
            PM1enabled = lcaGetSmart('PS:BSY0:3:MPSENABLE', 16000, 'double');
            PM3enabled = lcaGetSmart('PS:BSY0:6:MPSENABLE', 16000, 'double');
            while PM1enabled + PM3enabled > 0
                fprintf('%s Trying again to disable PMs\n',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF'));
                lcaPutSmart('PS:BSY0:3:MPSENABLE', 0);  % Disable PM1/2
                lcaPutSmart('PS:BSY0:6:MPSENABLE', 0);  % Disable PM3/4
                PM1enabled = lcaGetSmart('PS:BSY0:3:MPSENABLE', 16000, 'double');
                PM3enabled = lcaGetSmart('PS:BSY0:6:MPSENABLE', 16000, 'double');
            end
        else
            lcaPutSmart('SIOC:SYS0:ML01:AO322', 0);
            outMessage = 'Orbit OK, PM1 allowed.';
        end
        disp([outMessage, datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF')]);
        sty = double(int8(outMessage));
        lcaPutSmart('SIOC:SYS0:ML00:CA302', sty);
        %only allow Auto-restart if Trip interlock is enabled too
        if okRestart && autoRestartEnabled
            fprintf('%s Just auto enabled ESA pulse magents\n',datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF'));
            lcaPutSmart('PS:BSY0:3:MPSENABLE', 1);
            lcaPutSmart('PS:BSY0:6:MPSENABLE', 1);
        end
    end
    
    %
    %     figure(4)
    % %    plot(bpmdata1(tr,:))
    % subplot(311), plot(xr, VALs(xr,5:23), xr, VALs(xr,1), '-^', xr, VALs(xr,2), '-*'), ylabel('X (\mum)'), title('Orbits - mean orbit (5 to 23)')
    % subplot(312), plot(yr, VALs(yr,5:23), yr, VALs(yr,1), '-^', yr, VALs(yr,2), '-*'), ylabel('Y(\mum)')
    % plot(avgdata(1:5,xr)')
    % %subplot(313), plot(tr, VALs(tr,5:23), tr, VALs(tr,1), '-^', tr, VALs(tr,2), '-*'), xlabel('Undulator BPM Ordinal')
    %
    %
    
end

end


function plotIt %#ok<*DEFNU>

%% plot results  when testing

%plot(avgdata(xr,1) -  avgdata(xr,23))

figure(4)
subplot(311), plot(xr, VALs(xr,5:23), xr, VALs(xr,1), '-^', xr, VALs(xr,2), '-*'), ylabel('X (\mum)'), title('Orbits - mean orbit (5 to 23)')
subplot(312), plot(yr, VALs(yr,5:23), yr, VALs(yr,1), '-^', yr, VALs(yr,2), '-*'), ylabel('Y(\mum)')
subplot(313), plot(tr, VALs(tr,5:23), tr, VALs(tr,1), '-^', tr, VALs(tr,2), '-*'), xlabel('Undulator BPM Ordinal')

figure(5)
subplot(311), plot(VALn1(xr), '-o'), ylabel('X (\mum)'), title('n1 - mean(n5 to n23')
subplot(312), plot(VALn1(yr), '-o'), ylabel('Y(\mum)')
subplot(313), plot(VALn1(tr), '-o'), ylabel('TMIT (nel)'), xlabel('Undulator BPM Ordinal')

figure(6)
subplot(311), plot(VALn2(xr), '-o'), ylabel('X (\mum)'),title('n2 - mean(n5 to n23)')
subplot(312), plot(VALn2(yr), '-o'), ylabel('Y (\mum)')
subplot(313), plot(VALn2(tr), '-o'), ylabel('TMIT (nel)'), xlabel('Undulator BPM Ordinal')
%%
disp('done')

end

function [edefN edefS] = findEdef()
edefPvs = aidalist('EDEF:SYS0:%:NAME');
edefNames = lcaGetSmart(edefPvs);
edefPv = edefPvs(strncmp('BPM Dispersion/RMS', edefNames, 18));
edefS = strrep(edefPv,'EDEF:SYS0:','');
edefS = strrep(edefS,':NAME', '');
edefS = edefS{:};
edefN = str2int(edefS);
end

