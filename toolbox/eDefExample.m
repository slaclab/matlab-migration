% eDefExample

[ sys , accelerator ] = getSystem();

% Choose unique name
myName = 'example Matlab eDef';
myNAVG = 1;
myNRPOS = 30;
timeout = 30.0; % seconds

if isequal('LCLS',accelerator)
    bsa_pv = 'BPMS:IN20:221:X';
end

if isequal('FACET',accelerator)
    bsa_pv = 'BLEN:LI20:3158:ARAW';
end

try

    % Labels all cmLog messages withi this name
    Logger = getLogger(myName);
    
    % Reserve an eDef number
    myeDefNumber = eDefReserve(myName);

    % Make sure I got an eDef Number
    if isequal (myeDefNumber, 0)
        disp('Sorry, failed to get eDef');
    else
        disp(sprintf('I am eDef number %d',myeDefNumber));

        % set my number of pulses to average, etc... Optional, defaults to no
        % averaging with one pulse and DGRP INCM & EXCM.
        eDefParams (myeDefNumber, myNAVG, myNRPOS, {''},{''},{''},{''});

        disp (sprintf('I am averaging %d pulses per step',myNAVG));
        disp (sprintf('I am requesting %d steps',myNRPOS));
        disp (sprintf('I am willing to wait up to %.1f seconds',timeout));

        acqTime = eDefAcq(myeDefNumber, timeout);
        if (acqTime < timeout)
            disp (sprintf ('Data collection complete, took %.1f seconds', acqTime));
        else
            disp (sprintf ('Data collection timed out.  Data available for %.1f seconds', acqTime));
        end

        % read data, note that data stays until you give up your eDef
        dataVec = lcaGet(sprintf('%sHST%d',bsa_pv,myeDefNumber));
        pidVec = lcaGet(sprintf('PATT:%s:1:PULSEIDHST%d',sys,myeDefNumber));
        seconds = lcaGet(sprintf('PATT:%s:1:SECHST%d',sys,myeDefNumber));
        nanoseconds = lcaGet(sprintf('PATT:%s:1:NSECHST%d',sys,myeDefNumber));

        % Last value is in BPMS:IN20:221:X%d, rms of last value is in
        % BPMS:IN20:221:X%d.H.  This is VERY handy for NRPOS==1!  The number of
        % measurements done is in say BPMS:IN20:221:XHST%d.NUSE

        disp (sprintf ('Event definition (EVG) claimed to have requested %d steps', eDefCount(myeDefNumber)));

        numCollected = lcaGet(sprintf('%sHST%d.NUSE',bsa_pv,myeDefNumber));
        disp (sprintf ('%s (EVR) claimed to have collected %d steps', bsa_pv, numCollected));

        % Give up eDef
        eDefRelease(myeDefNumber);

        % display data
        for eachPoint = 1:numCollected
            ts = datestr(epics2matlabTime(complex(seconds(eachPoint),nanoseconds(eachPoint))), 'mm-dd-yyyy HH:MM:SS.FFF');
            disp (sprintf('step=%d puid=%d ts=%s %s=%f',eachPoint,pidVec(eachPoint),ts,bsa_pv,dataVec(eachPoint)));
        end

    end

catch
    disp('eDefExample.m error. Please contact Mike Zelazny x3673 for assistance');
end
