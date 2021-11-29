function[] = BPMironUndulator(area)

% BPMironUndulator
% Scale BPM TMITs to match last LTU stripline BPM

% % WARNING if you crtl-C out of this program you should manually free up the
% EDEF it has reserved. Go the the System event definitions panel.

% History:
% Written SSmith
% Modified SHoobler 3/23/2020 to add SXR line
%   
% Choose unique name for the EDEF
format compact
myName = 'BPM TMIT Iron';
myNAVG = 1;
timeout = 30.0; % seconds
Npulses = 30
myNRPOS = Npulses;

lcaSetTimeout(0.2); lcaSetRetryCount(4);

if ( strcmp(area, 'UNDH') )
    myBeamcode=1;
    BPM_pvs = {
        'BPMS:LTUH:880'
        'BPMS:LTUH:910'
        'BPMS:LTUH:960'
        'BPMS:UNDH:1305'
        'BPMS:UNDH:1390'
        'BPMS:UNDH:1490'
        'BPMS:UNDH:1590'
        'BPMS:UNDH:1690'
        'BPMS:UNDH:1790'
        'BPMS:UNDH:1890'
        'BPMS:UNDH:1990'
        'BPMS:UNDH:2090'
        'BPMS:UNDH:2190'
        'BPMS:UNDH:2290'
        'BPMS:UNDH:2390'
        'BPMS:UNDH:2490'
        'BPMS:UNDH:2590'
        'BPMS:UNDH:2690'
        'BPMS:UNDH:2790'
        'BPMS:UNDH:2890'
        'BPMS:UNDH:2990'
        'BPMS:UNDH:3090'
        'BPMS:UNDH:3190'
        'BPMS:UNDH:3290'
        'BPMS:UNDH:3390'
        'BPMS:UNDH:3490'
        'BPMS:UNDH:3590'
        'BPMS:UNDH:3690'
        'BPMS:UNDH:3790'
        'BPMS:UNDH:3890'
        'BPMS:UNDH:3990'
        'BPMS:UNDH:4090'
        'BPMS:UNDH:4190'
        'BPMS:UNDH:4290'
        'BPMS:UNDH:4390'
        'BPMS:UNDH:4490'
        'BPMS:UNDH:4590'
        'BPMS:UNDH:4690'
        'BPMS:UNDH:5190'
        };
elseif ( strcmp(area, 'UNDS') )
    myBeamcode=2;
    BPM_pvs = {
        'BPMS:LTUS:880'
        'BPMS:UNDS:1690'
        'BPMS:UNDS:1990'
        'BPMS:UNDS:2190'
        'BPMS:UNDS:2490'
        'BPMS:UNDS:2590'
        'BPMS:UNDS:2690'
        'BPMS:UNDS:2790'
        'BPMS:UNDS:2890'
        'BPMS:UNDS:2990'
        'BPMS:UNDS:3090'
        'BPMS:UNDS:3190'
        'BPMS:UNDS:3290'
        'BPMS:UNDS:3390'
        'BPMS:UNDS:3490'
        'BPMS:UNDS:3590'
        'BPMS:UNDS:3690'
        'BPMS:UNDS:3790'
        'BPMS:UNDS:3890'
        'BPMS:UNDS:3990'
        'BPMS:UNDS:4090'
        'BPMS:UNDS:4190'
        'BPMS:UNDS:4290'
        'BPMS:UNDS:4390'
        'BPMS:UNDS:4490'
        'BPMS:UNDS:4590'
        'BPMS:UNDS:4690'
        'BPMS:UNDS:4790'
        'BPMS:UNDS:5190'
        };
    else
        disp('Illegal area argument; must be UNDH or UNDS. Quitting.')
end

nbpms = length(BPM_pvs(:,1));

for bpm=2:nbpms
HiGain(bpm) = strcmp(lcaGet([BPM_pvs{bpm} ':RCVR_GAIN']),'High');
disp([BPM_pvs{bpm} '   ' int2str(HiGain(bpm))]);
end
% Reserve an eDef number
myeDefNumber = eDefReserve(myName);

% Make sure I got an eDef Number
if isequal (myeDefNumber, 0)
    disp ('Sorry, failed to get eDef');
else
    disp (sprintf('%s Reserved eDef number %d',datestr(now),myeDefNumber));
    
    % set my number of pulses to average, etc... Optional, defaults to no
    % averaging with one pulse and DGRP INCM & EXCM.
    eDefParams (myeDefNumber, myNAVG, myNRPOS,{'pockcel_perm'},{''},{''},{''},myBeamcode);
end 

try
    % Now do an actual acquisition and check for timeout
    tic
    acqTime = eDefAcq(myeDefNumber, timeout);
    toc
    if (acqTime < timeout)
    %         disp (sprintf ('%s Data collection complete, took %.1f seconds', datestr(now), acqTime));
    else
        disp (sprintf ('%s Data collection timed out.  Data available for %.1f seconds', datestr(now), acqTime));
        ME = MException('BPMiron:BSATimeout',['BSA acq timed out. Rate on beamcode ' int2str(myBeamcode) '?']);
        throw(ME);
    end

    X = zeros(nbpms, Npulses);
    Y = X; T = X; Xs = X;  Ys = Xs;  Ts = Xs;

    for bpm=1:nbpms
        
        X(bpm,:) =  lcaGet([BPM_pvs{bpm} sprintf(':XHST%d',myeDefNumber)], Npulses); 
        Xacq(bpm) = lcaGet([BPM_pvs{bpm} sprintf(':XHST%d',myeDefNumber) '.NUSE']);
        XacqOK(bpm) = Xacq(bpm)==Npulses;
        if ~XacqOK(bpm)   display(['Missing pulses for ' BPM_pvs{bpm} ' X']);  end

        Y(bpm,:) =  lcaGet([BPM_pvs{bpm} sprintf(':YHST%d',myeDefNumber)], Npulses);
        Yacq(bpm) = lcaGet([BPM_pvs{bpm} sprintf(':YHST%d',myeDefNumber) '.NUSE']);
        YacqOK(bpm) = Yacq(bpm)==Npulses;
        if ~YacqOK(bpm)   display(['Missing pulses for ' BPM_pvs{bpm} ' Y']);  end

        T(bpm,:) =  lcaGet([BPM_pvs{bpm} sprintf(':TMITHST%d',myeDefNumber)], Npulses);
        Tacq(bpm) = lcaGet([BPM_pvs{bpm} sprintf(':TMITHST%d',myeDefNumber) '.NUSE']);
        TacqOK(bpm) = Tacq(bpm) == Npulses; 
        if ~TacqOK(bpm)  display(['Missing pulses for ' BPM_pvs{bpm} ' TMIT']);  end
    end
    BSAOK = ~(sum(~XacqOK) + ~sum(~YacqOK) + ~ sum(~TacqOK));
    
catch ME % clean up after failure
    % Free up the eDef
    eDefRelease(myeDefNumber);
    display('Quitting on error')
    if strfind(ME.identifier,'timedOut')
        fprintf('Failed to connect to BSA PV(s). Quitting.\n');
        return
    elseif strfind(ME.identifier,'BSATimeout')
        disp(ME.message);
        return
    else
        dbstack;
        rethrow(ME);
    end
end

% Free up the eDef
    eDefRelease(myeDefNumber);
    
%break %__________________________________________________ QUIT HERE FOR NOW  
    
%Qualify data

for bpm=2:nbpms
    GainChange(bpm) = (strcmp(lcaGet([BPM_pvs{bpm} ':RCVR_GAIN']),'High') ~= HiGain(bpm));
    if GainChange(bpm)
        disp([BPM_pvs{bpm} '   changed gain during acquisition' ]);
    end
end

figure(1);plot(T');grid; title('Beam Charge');
xlabel('Pulse Number'); ylabel('Charge (electrons)');

BPM2 = T(1,:);
OK = find(BPM2>0.5*mean(BPM2));  % Cut pulses with charge less than 1/2 of mean charge
Nok = length(OK); nok=1:Nok;
T = T(:,OK); %only keep good pulses
avgQ = mean(T');
 
BPM2=T(1,:);  %last stripline BPM in LTU

meanBPM2 = mean(BPM2);

% Normalize BPMs 

disp(sprintf('Normalize to last LTU BPM mean TMIT = %0.3g ', meanBPM2));
oldscale=[]; newscale=[];
figure(2);close(2);
for n=1:nbpms,
    if ~GainChange(n)
        if HiGain(n)
            AB = 'A';
        else
            AB = 'B';
        end
        beamOK =  find(T(n,:) > 0.5*avgQ(n)); % Did beam get here?
        avgQ(n) = mean(T(n,beamOK));  %so average over the non-zero data points
        figure(2); subplot(3,1,1);plot(nok,BPM2,nok,T(n,:));grid
        if n>1
            if isfinite(avgQ(n))
                
                title([BPM_pvs{n} ' and BPM860 w/ existing QSCL'])
                oldscale(n) = lcaGet([BPM_pvs{n} ':QSCL_SEL.' AB]);
                newscale(n) = oldscale(n)*mean(BPM2(beamOK))/avgQ(n);
                disp ' '
                disp([BPM_pvs{n} sprintf(' mean(TMIT)= %0.3g  oldQSCL= %0.3g  newQSCL= %0.3g', avgQ(n), oldscale(n), newscale(n))]);
                subplot(3,1,2);plot(nok,BPM2,nok,T(n,:)*newscale(n)/oldscale(n));grid
                title(['Rescaled ' BPM_pvs{n} ' and BPM860']);

                subplot(3,1,3);plot(BPM2,T(n,:)*newscale(n)/oldscale(n),'r.');grid;
                title([BPM_pvs{n} ' vs. BPM860']);ylabel(BPM_pvs{n});xlabel('BPM860 TMIT');
                if (abs((newscale(n)-oldscale(n))/oldscale(n)) > 0.2)  % If change > 20%, prompt for user approval before implementing
                    response = input(['Calculated scale change of > 20%. Accept and change QSCL_SEL.' AB '? y/n [y] '],'s');
                    if ( isempty( response ) || (response == 'y') || (response=='Y') )
                        display(AB)
                        lcaPut([BPM_pvs{n} ':QSCL_SEL.' AB], newscale(n) ) 
                        disp(sprintf([BPM_pvs{n} 'New QSCL = %0.3g'], newscale(n)));
                        calClearCheckBpm([BPM_pvs{n}],1);
                    else
                        disp('Proposed scale change rejected')
                    end
                else
                    display(AB)
                    lcaPut([BPM_pvs{n} ':QSCL_SEL.' AB], newscale(n) ) 
                    disp(sprintf([BPM_pvs{n} 'New QSCL = %0.3g'], newscale(n)));
                    calClearCheckBpm([BPM_pvs{n}],1);
                end
            else
                disp(['No good data' BPM_pvs{n} ])
            end
        end
    else
        display([BPM_pvs{bpm} ' changed gain during acqusition, not ironed'])
    end
end

figure(11);plot(1:nbpms,oldscale,1:nbpms,newscale,'r');grid; title('BPM QSCL (old, new)');xlabel('BPM number');ylabel('QSCL')    
figure(12);scatter(1:nbpms,newscale./oldscale);grid; title('BPM QSCL change (new/old)');xlabel('BPM number');ylabel('newQSCL/oldQSCL') 

%Summarize old/new scales
disp ' '
for n=2:nbpms,
    disp([BPM_pvs{n} sprintf(' mean(TMIT)= %0.3g  oldQSCL= %0.3g  newQSCL= %0.3g  new/old= %0.3g', avgQ(n), oldscale(n), newscale(n), newscale(n)/oldscale(n))]);
end
              
%Summarize new scales
scale=[];disp(' ')
for n=1:nbpms,
    disp([BPM_pvs{n} sprintf(':QSCL = %0.3g',lcaGet([BPM_pvs{n} ':QSCL']))]);
end

message=('Undulator BPM TMIT Ironing program completed.');
calBpmLogMsg(message);
