function [] = BPMironSingleUnit(varargin)

% BPMironSingleUnit
% Scale BPM TMIT to match other BPM or toroid
% 
% Prompt user to select reference device to match TMIT to. Options are
% first BPM, first toroid, and arbitrary device user can type in. Prompt user 
% to select BPM to iron (unless BPM name passed as argument). 
% Take data, calculate mean TMIT for both devices.
% Calculate required scale change (QSCL) needed to make BPM match reference
% device. Change scale, plot data. 
% Coming later: set BPM CHK PV to 0.
%
% % WARNING if you crtl-C out of this program you should manually free up the
% EDEF it has reserved. Go the the System event definitions panel.
%
%     Optional Argument:
%              bpm        BPM name, for example 'BPMS:LI27:201'   
%
% History:
% Auth: S. Hoobler 1July2010 but most was
% stolen/adapted from BPMironUndulator.m by SSmith
% 
%--------------------------------------------------------------------------


% Choose unique name for the EDEF
format compact
myName = 'BPM TMIT iron';
myNAVG = 1;
timeout = 30.0; % seconds
Npulses = 30;
myNRPOS = Npulses;

lcaSetTimeout(0.2); lcaSetRetryCount(4);


if ( length(varargin) == 1 )
    iron_pv = varargin{1};
    disp(['Let us iron ' iron_pv '! (Remember, you must have beam)']);
else
    fprintf('Select the BPM you would like to iron.\n');
    loca = upper(input('Enter location (for example IN20 or IN10): ','s'));
    unit = input('Enter unit number: ','s');
    iron_pv=['BPMS:' loca ':' unit];
end

% Verify PV exists
try
    lcaGet([iron_pv ':TMIT1H']);
catch
    err = lasterror;
    if strfind(err.identifier,'timedOut')
        fprintf('Cannot connect to %s:TMIT1H. Check that device name is correct and IOC is online.\n',iron_pv);
        return;
    else
        dbstack;
        rethrow(lasterror);
    end
end

% Fetch facility identifiers
[~, accelerator] = getSystem();

if ( strcmp(accelerator, 'LCLS') )
    [ref_pv, myBeamcode, err] = handleLcls(iron_pv);
    if ( err )
        return;
    end
elseif ( strcmp(accelerator, 'FACET') )
    [ref_pv, myBeamcode, err] = handleFacet();
    if ( err )
        return;
    end
else
    fprintf('Unsupported accelerator %s. Quitting\n', accelerator);
    return;
end


% Verify PV exists
try
    lcaGet([ref_pv ':TMIT1H']);
catch
    err = lasterror;
    if strfind(err.identifier,'timedOut')
        fprintf('Cannot connect to %s:TMIT1H. Check that device name is correct and IOC is online.\n',ref_pv);
        return
    else
        dbstack;
        rethrow(lasterror);
    end
end


% Verify units match
if ~strcmp(lcaGet([iron_pv ':TMIT.EGU']),lcaGet([ref_pv ':TMIT.EGU']))
    fprintf('Units do not match. Cannot use this reference device to scale BPM\n');
    return
end


% Make list of all BPMs (reference and wrinkled)
BPM_pvs={ref_pv;iron_pv}; % Later may expand script to iron multiple BPMs
nbpms=length(BPM_pvs);

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

        T(bpm,:) =  lcaGet([BPM_pvs{bpm} sprintf(':TMITHST%d',myeDefNumber)], Npulses);
        Tacq(bpm) = lcaGet([BPM_pvs{bpm} sprintf(':TMITHST%d',myeDefNumber) '.NUSE']);
        TacqOK(bpm) = Tacq(bpm) == Npulses;
        if ~TacqOK(bpm)  display(['Missing pulses for ' BPM_pvs{bpm} ' TMIT']);  end
    end

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
        
%Qualify data

figure(1);plot(T');grid; title('Beam Charge');
xlabel('Pulse Number'); ylabel('Charge (electrons)');

ref = T(1,:);
OK = find(ref>0.5*mean(ref));  % Cut pulses with charge less than 1/2 of mean charge
Nok = length(OK); nok=1:Nok;
T = T(:,OK); %only keep good pulses
avgQ = mean(T');
 
ref=T(1,:);  %last stripline BPM in LTU

meanref = mean(ref);

% Normalize BPMs 

disp(sprintf('Normalize to reference mean TMIT = %0.3g ', meanref));
oldscale=[]; newscale=[];
figure(2);close(2);
for n=2:nbpms,  % Exclude reference device
        beamOK =  find(T(n,:) > 0.5*avgQ(n)); % Did beam get here?
        avgQ(n) = mean(T(n,beamOK));  %so average over the non-zero data points
        figure(2); subplot(3,1,1);plot(nok,ref,nok,T(n,:));grid
        if n>1
            if isfinite(avgQ(n))               
                title([BPM_pvs{n} ' and ' ref_pv ' w/ existing QSCL'])
                oldscale(n) = lcaGet([BPM_pvs{n} ':QSCL']);
                newscale(n) = oldscale(n)*mean(ref(beamOK))/avgQ(n);
                disp ' '
                disp([BPM_pvs{n} sprintf(' mean(TMIT)= %0.3g  oldQSCL= %0.3g  newQSCL= %0.3g', avgQ(n), oldscale(n), newscale(n))]);
                subplot(3,1,2);plot(nok,ref,nok,T(n,:)*newscale(n)/oldscale(n));grid
                title(['Rescaled ' BPM_pvs{n} ' and ref']);

                subplot(3,1,3);plot(ref,T(n,:)*newscale(n)/oldscale(n),'r.');grid;
                title([BPM_pvs{n} ' vs.' ref_pv]);ylabel(BPM_pvs{n});xlabel([ref_pv 'TMIT']);
                if (abs((newscale(n)-oldscale(n))/oldscale(n)) > 0.2)  % If change > 20%, prompt for user approval before implementing
                    response = input('Calculated scale change of > 20%. Accept and change QSCL?(y/n) ','s');
                    if response== 'y'||response=='Y'
                        lcaPut([BPM_pvs{n} ':QSCL'], newscale(n) ); 
                        disp(sprintf([BPM_pvs{n} ' New QSCL = %0.3g'], newscale(n)));
                        calClearCheckBpm([BPM_pvs{n}],1);
                    else   
                        disp('Proposed scale change rejected')
                    end
                else
                    lcaPut([BPM_pvs{n} ':QSCL'], newscale(n) ) 
                    disp(sprintf([BPM_pvs{n} ' New QSCL = %0.3g'], newscale(n)));
                    calClearCheckBpm([BPM_pvs{n}],1);
                end
            else
                disp(['No good data' BPM_pvs{n} ])
            end
        end
end

figure(11);plot(1:nbpms,oldscale,1:nbpms,newscale,'r');grid; title('BPM QSCL (old, new)');xlabel('BPM number');ylabel('QSCL')    
figure(12);scatter(1:nbpms,newscale./oldscale);grid; title('BPM QSCL change (new/old)');xlabel('BPM number');ylabel('newQSCL/oldQSCL') 

%Summarize old/new scales
disp ' '
for n=2:nbpms,  % Exclude reference device 
    disp([BPM_pvs{n} sprintf(' mean(TMIT)= %0.3g  oldQSCL= %0.3g  newQSCL= %0.3g  new/old= %0.3g', avgQ(n), oldscale(n), newscale(n), newscale(n)/oldscale(n))]);
end
              
%Summarize new scales
scale=[];disp(' ')
for n=2:nbpms,  % Exclude reference device
    disp([BPM_pvs{n} sprintf(':QSCL = %0.3g',lcaGet([BPM_pvs{n} ':QSCL']))]);
end

message=('Single unit BPM TMIT Ironing program completed.');
calBpmLogMsg(message);
end

function[ref_pv, myBeamcode, err] = handleLcls(iron_pv)
err = 0;
refBPM_pv ='BPMS:IN20:221';
refTORO_pv ='TORO:IN20:215';
response = input('\nSelect TMIT reference:\nType b for BPM2, t for IM01, or o to select a different BPM or toroid. ','s');
if response=='b'||response=='B'; ref_pv=refBPM_pv;
elseif response=='t'||response=='T'; ref_pv=refTORO_pv;
elseif response=='o'||response=='O'
    prim = upper(input('Enter primary (BPMS or TORO): ','s'));
    loca = upper(input('Enter location (for example IN20): ','s'));
    unit = input('Enter unit number: ','s');
    ref_pv=[prim ':' loca ':' unit];
else
    fprintf('Invalid selection. Quitting.\n');
    err = 1;
    return;
end

strtok(iron_pv,':');
[~,remain]=strtok(iron_pv,':');
loca=strtok(remain,':');

hxrList={'BSYH','LTUH','UNDH','DMPH'};
sxrList={'CLTS','BSYS','LTUS','UNDS','DMPS'};

if ( ismember(loca,hxrList) )
    disp('HXR BPM, using beamcode 1 in EDEF');
    myBeamcode=1;
elseif ( ismember(loca,sxrList) )
    disp('SXR BPM, using beamcode 2 in EDEF');
    myBeamcode = 2;
else 
    disp('Common area BPM, using any beamcode in EDEF');
    myBeamcode = 0;
end
end

function[ref_pv, myBeamcode, err] = handleFacet()
err = 0;
refBPM_pv ='BPMS:IN10:221';
refTORO_pv ='TORO:IN10:362';
response = input('\nSelect TMIT reference:\nType b for BPM10221, t for IM10431, or o to select a different BPM or toroid. ','s');
if response=='b'||response=='B'; ref_pv=refBPM_pv;
elseif response=='t'||response=='T'; ref_pv=refTORO_pv;
elseif response=='o'||response=='O'
    prim = upper(input('Enter primary (BPMS or TORO): ','s'));
    loca = upper(input('Enter location (for example IN20): ','s'));
    unit = input('Enter unit number: ','s');
    ref_pv=[prim ':' loca ':' unit];
else
    fprintf('Invalid selection. Quitting.\n');
    err = 1;
    return;
end

myBeamcode = 10;

end
