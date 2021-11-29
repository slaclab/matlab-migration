function BSAChecker (  argPV1, argPV2, argPV3, argPV4, argPV5, argPV6, argPV7, argPV8, argPV9 )
% Check BSA functionality for given PV, default == ALL* BSA PVs

% Example:
%   BSAChecker
%       - checks all BSA PVs resturned by LCLS//BSA.rootnames Aida query
%   BSAChecker('BPMS:UND1:100:TMIT')
%       - checks BPMS:UND1:100:TMIT for BSA functionality
%   BSAChecker('BPMS:LI21:301:X','BPMS:LI21:301:Y','BPMS:LI21:301:TMIT')
%       - check 3 BPM PVs for BSA functionality

%
% Connect to message log
%
Logger = getLogger('BSAChecker.m');
put2log('BSAChecker.m started');

who = unix('whoami');
where = unix('hostname');
[ system, accelerator ] = getSystem;

%
% Assign pv names
%
date_pv = [ 'SIOC:' system ':ML00:AO441.DESC' ];
nRuns_pv = [ 'SIOC:' system ':ML00:AO442' ];
status_pv = [ 'SIOC:' system ':ML00:AO443.DESC' ];
progress_pv = [ 'SIOC:' system ':ML00:AO443' ];
nBSApvs_pv = [ 'SIOC:' system ':ML00:AO444' ];
nGood_pv = [ 'SIOC:' system ':ML00:AO445' ];
pGood_pv = [ 'SIOC:' system ':ML00:AO446' ];
nBad_pv = [ 'SIOC:' system ':ML00:AO447' ];
pBad_pv = [ 'SIOC:' system ':ML00:AO448' ];
beam_rate_pv = [ 'EVNT:' system ':1:' accelerator 'BEAMRATE' ];
if isequal('FACET',accelerator)
    beam_rate_pv = [ 'EVNT:' system ':1:BEAMRATE' ];
end
br_pv = [ 'SIOC:' system ':ML00:AO449' ]; % Beam Rate when this script was run

%
% Update time stamp
%
try
    lcaPut(date_pv, datestr(now));
    ok = 1;
catch
    put2log(sprintf('Sorry, unable to find %s',date_pv));
    ok = 0;
end

%
% Update run count
%
if (ok)
    try
        lcaPut(status_pv,'Incrementing run count');
        lcaPut(nRuns_pv, 1+lcaGet(nRuns_pv));
        nRuns = lcaGetSmart(nRuns_pv);
        if isnan(nRuns)
            put2log(sprintf('Channel access failure for %s',nRuns_pv));
            lcaPut(status_pv,'Sorry, can''t increment run count');
            ok = 0;
        end
    catch
        put2log('Had a problem trying to increment run count');
        lcaPut(status_pv,'Error incrementing run count');
        ok = 0;
    end
end

%
% Check EPICS_CA_MAX_ARRAY_BYTES
%
ECAMAB = str2double(getenv('EPICS_CA_MAX_ARRAY_BYTES'));
if (ECAMAB > 500000)
    put2log(sprintf('EPICS_CA_MAX_ARRAY_BYTES of %d is too big for BSA, try "export EPICS_CA_MAX_ARRAY_BYTES=32000".', ECAMAB));
    ok = 0;
end

%
% Check for beam rate
%
if (ok)
    try
        lcaPut(status_pv,'Checking beam rate');
        beam_rate = lcaGetSmart(beam_rate_pv);
        if isnan(beam_rate)
            put2log(sprintf('Channel access failure for %s',beam_rate_pv));
            lcaPut(status_pv,'Sorry, can''t read beam rate pv');
            ok = 0;
        else
            put2log(sprintf('Beam rate is %d Hz', beam_rate));
            lcaPut(br_pv, beam_rate);
        end
    catch
        put2log('Had a problem trying to read beam rate');
        lcaPut(status_pv,'Error reading beam rate');
        ok = 0;
    end
end

if (ok)
    if (beam_rate > 0)
        ok = 1;
    else
        message = 'Sorry, no rate on beam code 1';
        put2log(message);
        try
            lcaPut(status_pv,message);
        catch
        end
        ok = 0;
    end
end

%
% Get an eDef
%
if (ok)
    try
        myName = sprintf('BSA Checker %d',nRuns);
        lcaPut(status_pv,sprintf('eDef Reserve %s',myName));
        myeDefNumber = eDefReserve(myName);
        if isequal(myeDefNumber,0)
            put2log(sprintf('Sorry, eDef Reserve failed for %s',myName));
            lcaPut(status_pv,'Sorry, eDefReserve failed.');
            ok = 0;
        end
    catch
        put2log('Had a problem trying to reserve an event definition');
        lcaPut(status_pv,'eDefReserve code error.');
        ok = 0;
    end
end

%
% Set up eDef options
%
if (ok)
    try
        myNAVG = 1;
        rand('twister',sum(100*clock));
        myNRPOS = 800+ceil(2000.*rand(1)); % random number in [800,2800]
        lcaPut(status_pv,sprintf('eDef Reserve %s',myName));
        eDefParams (myeDefNumber, myNAVG, myNRPOS, {''},{''},{''},{''});
    catch
        put2log('Had a problem trying to set eDef Parameters');
        lcaPut(status_pv,'eDefReserve code error.');
        ok = 0;
    end
end
    
%
% Collect BSA Data
%
if (ok)
    try
        expectedMinutes = 0;
        expectedSeconds = (myNAVG * myNRPOS) / beam_rate;
        while (expectedSeconds > 59)
            expectedMinutes = expectedMinutes + 1;
            expectedSeconds = expectedSeconds - 60;
        end
        put2log(sprintf('Acquisition should take approximately %d minutes & %d seconds.', expectedMinutes, ceil(expectedSeconds)));
        lcaPut(status_pv,sprintf('eDef Acq %s',myName));
        eDefTime = eDefAcq (myeDefNumber, 2 * myNAVG * myNRPOS / beam_rate);
        count = eDefCount (myeDefNumber);
        put2log(sprintf('event definition claimed to have collected %d points',count));
        if isequal(count,0)
            lcaPut(status_pv,'Sorry, eDefCount was 0');
            ok = 0;
        end
    catch
        put2log('Had a problem trying to start eDef');
        lcaPut(status_pv,'eDefAcq code error.');
        ok = 0;
    end
end

%
% Get a list of BSA Devices 
%
if (ok)
    try
        BSApvs = cell(0);
        if nargin > 0
            for i = 1:nargin
                if eval(sprintf('argPV%d',i))
                    BSApvs{i} = eval(sprintf('argPV%d',i));
                end
            end
        end
        nBSApvs = length(BSApvs);
        if isequal(0,nBSApvs)
            requestedBSAnames.epics = 1; % only check EPICS PVs
            BSApvs = cellstr(getBSAnames(requestedBSAnames));
            nBSApvs = length(BSApvs);
        end
    catch
        put2log('Had a problem trying to get BSA list');
        lcaPut(status_pv,'Aida error.');
        ok = 0;
    end
end

%
% Update Number of BSA pvs pv 
%
if (ok)
    try
        lcaPut(status_pv,sprintf('# BSA pvs %d',nBSApvs));
        put2log(sprintf('Found %d BSA pvs',nBSApvs));
        lcaPut(nBSApvs_pv,nBSApvs);
    catch
        put2log(sprintf('Had a problem trying to write # of BSA pvs to %s',nBSApvs_pv));
        lcaPut(status_pv,'CA error # BSA pvs');
        ok = 0;
    end
end

%
% Get Pulse Id time stamp from EVG
%
if (ok)

    try
        ok = 0;
        pv = sprintf('PATT:%s:1:PULSEIDHST%d', system, myeDefNumber);
        [pulseids,pulseids_ts]=lcaGet(pv);
        put2log(sprintf('EVG Time = %s', imgUtil_matlabTime2String(lca2matlabTime(pulseids_ts))));
        put2log(sprintf('EVG Pulse Id = %d', lcaTs2PulseId(pulseids_ts)));
        ok = 1;

    catch
        put2log('Sorry, error trying to find EVG time and pulse id!');
    end

end

%
% Count good vs bad BSA pvs
%
if (ok)
    nGood = 0;
    nBad = 0;
    for i=1:nBSApvs
        try
            pv = char(BSApvs(i));
            if isequal('IOC:IN20:BP01:QANN',pv)
                nGood = nGood + 1;
            else
                if isequal('IOC:IN20:MC01:LCLSBEAMRATE',pv)
                    nGood = nGood + 1;
                else
                    pv = sprintf('%sHST%d', pv, myeDefNumber);
                    put2log(sprintf('%d/%d checking %s',i, nBSApvs, pv));
                    lcaPut(status_pv,sprintf('%s ck',pv));
                    lcaPut(progress_pv,i);
                    [nFound,ts]=lcaGet(sprintf('%s.NUSE',pv));
                    if isequal(nFound,count)
                        if isequal(ts,pulseids_ts)
                            % try to get the data to check IOC's
                            % EPICS_CA_MAX_ARRAY_BYTES
                            try
                                [v,ts]=lcaGet(pv);
                                nGood = nGood + 1;
                            catch
                                nBad = nBad + 1;
                                put2log(sprintf('***** %s failed BSA check, unable to get value from IOC. Is the IOC EPICS_CA_MAX_ARRAY_BYTES OK?', pv));
                            end
                        else
                            put2log(sprintf('***** %s failed BSA check, Pulse Id mismatch with EVG. Got Pulse Id=%d time=%s, expected Pulse Id=%d time=%s', ...
                                pv, lcaTs2PulseId(ts), imgUtil_matlabTime2String(lca2matlabTime(ts)), ...
                                lcaTs2PulseId(pulseids_ts), imgUtil_matlabTime2String(lca2matlabTime(pulseids_ts))));
                            nBad = nBad + 1;
                        end
                    else
                        put2log(sprintf('***** %s failed BSA check. Got %d points, expected %d.', pv, nFound, count));
                        nBad = nBad + 1;
                    end
                    lcaPut(nGood_pv,nGood);
                    lcaPut(pGood_pv, 100 * nGood / i);
                    lcaPut(nBad_pv,nBad);
                    lcaPut(pBad_pv, 100 * nBad / i);
                end
            end
        catch
            message = sprintf('***** Failed to lcaGet(%s)', pv);
            put2log(message);
            nBad = nBad + 1;
        end
    end
else
    put2log('Sorry, cannot find EVG time or pulse id!');
end


%
% Release event definition
%
if exist('myeDefNumber','var')
    if myeDefNumber > 0
        try
            eDefRelease(myeDefNumber);
        catch
            put2log(sprintf('Had a problem releasing eDef(%d) for %s', myeDefNumber, myName));
        end
    end
end

%
% Update Number of good BSA pvs pv 
%
if (ok)
    try
        lcaPut(status_pv,sprintf('# Good BSA pvs %d',nGood));
        put2log(sprintf('Found %d Good BSA pvs',nGood));
        lcaPut(nGood_pv,nGood);
    catch
        put2log(sprintf('Had a problem trying to write # of Good BSA pvs to %s',nGood_pv));
        lcaPut(status_pv,'CA error # Good BSA pvs');
        ok = 0;
    end
end

%
% Update Percentage of good BSA pvs pv 
%
if (ok)
    try
        p = 100 * nGood / nBSApvs;
        lcaPut(status_pv,sprintf('%s Good BSA pvs %f','%',p));
        put2log(sprintf('Percentage Good BSA pvs = %f',p));
        lcaPut(pGood_pv,p);
    catch
        put2log(sprintf('Had a problem trying to write Percentage of Good BSA pvs to %s',pGood_pv));
        lcaPut(status_pv,'CA error % Good BSA pvs');
        ok = 0;
    end
end

%
% Update Number of bad BSA pvs pv 
%
if (ok)
    try
        lcaPut(status_pv,sprintf('# Bad BSA pvs %d',nBad));
        put2log(sprintf('Found %d Bad BSA pvs',nBad));
        lcaPut(nBad_pv,nBad);
    catch
        put2log(sprintf('Had a problem trying to write # of Bad BSA pvs to %s',nBad_pv));
        lcaPut(status_pv,'CA error # Bad BSA pvs');
        ok = 0;
    end
end

%
% Update Percentage of bad BSA pvs pv 
%
if (ok)
    try
        p = 100 * nBad / nBSApvs;
        lcaPut(status_pv,sprintf('%s Bad BSA pvs %f','%',p));
        put2log(sprintf('Percentage Bad BSA pvs = %f',p));
        lcaPut(pBad_pv,p);
    catch
        put2log(sprintf('Had a problem trying to write Percentage of Bad BSA pvs to %s',pBad_pv));
        lcaPut(status_pv,'CA error % Bad BSA pvs');
        ok = 0;
    end
end  

%
% exit from Matlab when not running the desktop
%
try
    put2log('BSAChecker.m done');
    if (ok)
        lcaPut(status_pv,'Check complete');
    end
catch
end

if usejava('desktop')
    % don't exit from Matlab
else
    exit
end
