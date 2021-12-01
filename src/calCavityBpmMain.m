function[] = calCavityBpmMain(beamline, bpmsim)
%   calCavityBpmMain.m
%
%   This script is used to acquire calibration data (and optionally implement a new
%    calibration) for the LCLS cavity BPMs located in undulator hall and at
%    the end of the LTU.
%   Calibration parameters consist of X and Y position scaling factors (USCL and VSCL),
%    X and Y signal detector phases (UPHAS and VPHAS), and two angles used to parametrize
%    the coupling between the X and Y planes (PHI and PSI).
%
%   This script is launched by an edm display shell command from bpm_cal_data_acq.edl.
%
%   Use bpm_cal_data_acq.edl to select which BPMs in which planes to calibrate.
%   From that display you can also select a 'short' (2 steps, 100 um) or
%   'standard' (4 steps, 200 um) scan type.
%
%   The first two BPMs are not on movers, so LTU correctors are used to calibrate these.
%   The remaining BPMs are calibrated by moving the girders using the BPMMove
%   matlab function. The exception to this is the first BPM in the undulator; it is
%   located on the upstream end of the girder and girderBFWMove is used to move it.
%
%   For the girder BPMs, jitter is compensated for by using upstream BPMs.
%
%

tic;

% optional argument to execute program without invasive actions.
% If using this, beamline variable must also be specified.
% Mode still expects all PVs to be online.
% Default to normal execution
if ( exist('bpmsim', 'var') ~= 1 )
    bpmsim = 0;
elseif ( (bpmsim ~= 0) && (bpmsim ~= 1) )
    bpmsim = 0;
elseif (bpmsim == 1)
    disp('SIMULATION MODE');
end

% Default to UNDH for backward-compatibility
if ( exist('beamline', 'var') ~= 1 )
    beamline = 'HXR';
    calBpmHxrInit();
elseif ( strcmp(beamline, 'HXR') )
    calBpmHxrInit();
elseif ( strcmp(beamline, 'SXR') )
    calBpmSxrInit();
else
    disp( ['Invalid beamline argument ' beamline 'must be HXR or SXR'] ); 
end

if ( ~init )
    return;
end

dj = 0;
for k = 1:nbpms
    if ( bpm(k).dj )
        dj = 1;
        break
    end
end

if ( dj ) 
% Acquire jitter correction data
try
    msg = 'Acquiring jitter correction data';
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end
    e = 0; n = 1;
        
    jdata = zeros( nbpms, c.NSIGNALS, c.NSAMPLES );
    while n <= c.NSAMPLES
        newdata = 1;
        try lcaNewMonitorWait( bpmsigpvs.mon )
        catch ME
            disp( 'Timeout waiting for new data' );
            e = e + 1;
            newdata = 0;
        end
        
        if newdata
            [dataSet, e, skipPoint, ~, ~] = calGetData( bpmsigpvs, nbpms, bpmparms.acc, e, c );
            if ( ~skipPoint )                
                jdata(:,:,n) = dataSet;
                n = n + 1;
            end                        
        else
            if ( calCheckRate ) % PVs did not update; check beam rate
                restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
            end
        end
        
        if ( e > c.NPULSESABORT )
            promptstr = 'No beam or bad status.';
            if calPromptContinue( 0, promptstr )
                restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
            end
            e = 0;
        end
    end
    
    % Quit if abort requested
    if ( lcaGet( scanpvs.abort, 0, 'float' ) )
        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    end
    
    % Calculate and store de-jitter parameters
    for j = 1:nbpms
        if ( bpmparms.sel(j) && ~bitand( bpmparms.err(j), c.ERR_SKIP ) )
            if ( bpm(j).dj && ~bitand( bpmparms.err(j), c.ERR_INSUFF) )
                if ( bpm(j).p1 && bpm(j).p2 )
                    djdata = squeeze([jdata(bpm(j).p1,c.X,:); jdata(bpm(j).p2,c.X,:); ...
                        jdata(bpm(j).p1,c.Y,:); jdata(bpm(j).p2,c.Y,:)]);
                elseif ( bpm.p1 )
                    djdata = squeeze([jdata(bpm(j).p1,c.X,:);jdata(bpm(j).p1,c.Y,:)]);
                elseif ( bpm.p2 )
                    djdata = squeeze([jdata(bpm(j).p2,c.X,:);jdata(bpm(j).p2,c.Y,:)]);
                else
                    disp( [name ': cannot perform jitter correction, no BPM(s) selected'] );
                    continue;
                end
                prevXY = squeeze(djdata);
                % Find fit coefficients to predict this BPM from upstream BPMs
                [~, bpm(j).cudj] = calBpmLinearPredictor( jdata(j,c.URER,:) + jdata(j,c.UIMR,:)*1i, prevXY );
                [~, bpm(j).cvdj] = calBpmLinearPredictor( jdata(j,c.VRER,:) + jdata(j,c.VIMR,:)*1i, prevXY );
            end
        end
    end
    if (~bpmsim )
        lcaPut( bpmpvs.err, bpmparms.err ); %#ok<*USENS>
    end
    
    if ( lcaGet( scanpvs.abort, 0, 'float' ) )
        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    end
    
catch ME
    dbstack();
    msg = 'Error during jitter acq. Quitting.';
    disp( msg );
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end
    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    return;
end
end 

% Calibrate girder BPMs

selGirderBPMs = getSelNotSkippedNotDone( c, girderBPMs, bpmparms );
               
if ( any(selGirderBPMs) )
   try
        % Set flags for first BPM/plane to indicate that
        % there is no previous girder move to restore
        prevBpm   = 0;
        prevPlane = 0;
        prevGirder = 0;
        restore_mask = bitor( restore_mask, c.RESTORE_GRDR );
        
        for l = 1:length( selGirderBPMs )
            j = selGirderBPMs(l);
            
            % Scan both planes
            a = 1; b = 2;
            
            fprintf('scan bpm %i\n', j);
            
            % Scan until BPM done, too many failed attempts, or other error
            done = 0;
            while ( ~done )
                [bpm(j),prevBpm,prevPlane,prevGirder] = calScanGirder( a, b, bpm(j), j, ...
                    mov, prevBpm, prevPlane, prevGirder, bpmsigpvs, nbpms, bpmparms.acc, bpmpvs, c, restore_mask, bpmparms.err, beamline, scanpvs, bpmsim, fb );
                
                % Calculate calibration parameters and assess success
                if ( ~thisBpmSkipped( bpmparms.err, j, c ) )
                    
                    [bpmparms.uscl(j),bpmparms.vscl(j),bpmparms.uv(j),bpmparms.vu(j),bpmparms.uphas(j),bpmparms.vphas(j),bpmparms.ur(j),bpmparms.vr(j),bpm(j),xbaddata,ybaddata] = ...
                        calBpmCookData( j, bpm(j), bpms{j}, plotf, bpmparms.uscl_i(j), bpmparms.vscl_i(j), bpmparms.ur(j), bpmparms.vr(j), ...
                        bpmparms.uscl(j), bpmparms.vscl(j), bpmparms.uphas(j), bpmparms.vphas(j), bpmparms.uv(j), bpmparms.vu(j), c );
                    
                    bpmparms.err(j) = getScanError( xbaddata,  ybaddata, bpm(j), bpmparms.err(j), bpmparms.ur(j), bpmparms.vr(j), c );
                    if ( ~bpmsim )
                        lcaPut( bpmpvs.err{j}, bpmparms.err(j) );
                    end
                    
                    % Determine if need to scan again and if so, which planes
                    done = (bpmparms.ur(j) && bpmparms.vr(j)) || thisBpmSkipped( bpmparms.err, j, c );
                    if (~done)
                        [~,a,b] = selPlanes( ~bpmparms.ur(j), ~bpmparms.vr(j), c );
                    end
                end
            end
            if ( coupling_flag )
                [bpmparms.phi(j),bpmparms.psi(j)] = calBpmCouplingWrapper( bpmparms.ur(j), bpmparms.vr(j), bpmparms.uv(j), bpmparms.vu(j), bpmparms.phi(j), bpmparms.psi(j) );
            end

            if ( ~bpmsim )
                lcaPut( bpmpvs.prog{j}, c.PROG_SCANDONE ); % move this to better place
            end
            % Temporary safety save until this version fully tested
            try
                path_name=(['/u1/lcls/physics/cavityBPM/calibration/data/backup/' beamline '/']);
                date=datestr(now,31);
                str = ['BPMCalib',beamline,'_',date(1:10),'_',date(12:13),'_',date(15:16),'_bpm',int2str(j)] ;
                save(fullfile(path_name,str))
                fprintf('All variables saved to %s%s.mat\n\n',path_name,str);
            catch ME
            end
        end

        disp('restoring girder moves');
        % Restore the final move (if any girders were moved)
        if ( prevPlane )
            msg = 'Restoring girder moves';
            if ( ~bpmsim )
                lcaPut( scanpvs.msg, msg );
            else
                disp( msg )
            end
            
            if ( prevPlane == c.XPLANE )
                xmovLast = mov.restore;
                ymovLast = 0;
            else
                xmovLast = 0;
                ymovLast = mov.restore;
            end
            if ( ~bpmsim )
                status =  BPMMove( beamline, prevGirder, xmovLast, ymovLast );
                pause(2); % Wait for mover to settle
            else
                status = 1;
            end
            if ( ~status )
                bpmparms.err(prevBpm) = bitor( bpmparms.err(prevBpm), c.ERR_GIRDER );
                if (~bpmsim )
                    lcaPut( bpmpvs.err{prevBpm}, bpmparms.err(prevBpm) );
                end
            end
        end
    catch ME
       msg = 'Error: see Matlab console for details';
       if (~bpmsim )
           lcaPut( scanpvs.msg, msg );
       else
           disp( msg );
       end
       dbstack();
       calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
       return;
    end
end

if ( lcaGet( scanpvs.abort, 0, 'float' ) )
    restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
end

% Temporary safety save until this version fully tested
try
path_name=(['/u1/lcls/physics/cavityBPM/calibration/data/backup/' beamline '/']);
date=datestr(now,31);
str = ['BPMCalib',beamline,'_',date(1:10),'_',date(12:13),'_',date(15:16)] ;
save(fullfile(path_name,str))
fprintf('All variables saved to %s%s.mat\n\n',path_name,str); 
catch ME
end

% Write calibration parameters to girder BPMs
% Do this now because these BPMs'
% readings are used to calibrate the next batch
wsel = zeros( nbpms, 1 );
% Use full list of girder BPMs in case selGirderBPMs further
% reduced, for example to remove completed BPMs
for l = 1:length( girderBPMs )
    j = girderBPMs(l);
    wsel(j) = bpmparms.sel(j);
end
if ( any( wsel ) )
    [tmp,bpmparms] = calPromptWriteParms(bpms, bpmpvs, bpmparms, wsel, restore_mask, scanpvs, bpmsim, c);
    wstat = max( tmp, wstat ); %#ok<*NODEF>
end
 
% Calibrate non-girder BPMs
try        
    selNonGirderBPMs = getSelNotSkippedNotDone( c, nonGirderBPMs, bpmparms );
    
    % Only scan if some BPMs selected and not skipped and not done
    if ( any(selNonGirderBPMs)  )
        
        setuppred = 0;
        for l = 1:length( selNonGirderBPMs )
            k = selNonGirderBPMs(l);
            if ( bpm(k).method == c.CAL_PRED )
                setuppred = 1;
                break;
            end
        end
        
        if ( setuppred )
            [bpm, bpmparms.err] = calNonGirderBpmSetupPred( bpms, bpm, ...
                bpmparms.acc, bpmparms.sel, bpmpvs, selNonGirderBPMs, bpmparms.err, c, bpmsim, beampathstr );
            
            % Update list, in case any had errors during calNonGirderBpmSetupPred
            selNonGirderBPMs = getSelNotSkippedNotDone( c, selNonGirderBPMs, bpmparms );
        end
    end
    
    if ( any(selNonGirderBPMs) )
        
        for l = 1:length( selNonGirderBPMs )
            j = selNonGirderBPMs(l);
            
            % Scan both planes
            a = 1; b = 2;
            
            fprintf('scan bpm %i\n', j);
            
            % Scan until BPM done, too many failed attempts, or othererror
            done = 0;
            while ( ~done )
                [bpm, bpmparms.err, ~] = calScanNonGirder( a, b, cor, bpm(j).corpair, bpmsigpvs, nbpms, ...
                    bpmparms.acc, j, bpm, restore_mask, scanpvs, bpmsim, c, bpmparms.err, und, fb, launchstruct, c.NSAMPLES ); % Acquire data
                
                % Calculate calibration parameters and assess success
                if ( ~thisBpmSkipped( bpmparms.err, j, c ) )
                    
                    [bpmparms.uscl(j),bpmparms.vscl(j),bpmparms.uv(j),bpmparms.vu(j),bpmparms.uphas(j),bpmparms.vphas(j),bpmparms.ur(j),bpmparms.vr(j),bpm(j), xbaddata, ybaddata] = ...
                        calBpmCookData( j, bpm(j), bpms{j}, plotf, bpmparms.uscl_i(j), bpmparms.vscl_i(j), bpmparms.ur(j), bpmparms.vr(j), ...
                        bpmparms.uscl(j), bpmparms.vscl(j), bpmparms.uphas(j), bpmparms.vphas(j), bpmparms.uv(j), bpmparms.vu(j), c );
                    
                    bpmparms.err(j) = getScanError( xbaddata,  ybaddata, bpm(j), bpmparms.err(j), bpmparms.ur(j), bpmparms.vr(j), c );
                    if ( ~bpmsim )
                        lcaPut( bpmpvs.err{j}, bpmparms.err(j) );
                    end
                    
                    % Determine if need to scan again and if so, which planes
                    done = (bpmparms.ur(j) && bpmparms.vr(j)) || thisBpmSkipped( bpmparms.err, j, c );
                    if (~done)
                        [~,a,b] = selPlanes( ~bpmparms.ur(j), ~bpmparms.vr(j), c );
                    end
                end
            end
            if ( coupling_flag )
                [bpmparms.phi(j),bpmparms.psi(j)] = calBpmCouplingWrapper( bpmparms.ur(j), bpmparms.vr(j), bpmparms.uv(j), bpmparms.vu(j), bpmparms.phi(j), bpmparms.psi(j) );
            end
            if ( ~bpmsim )
                lcaPut( bpmpvs.prog{j}, c.PROG_SCANDONE ); % move this to better place
            end
        end

        if ( lcaGet( scanpvs.abort, 0, 'float' ))
            restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
            calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
        end
        if ( ~bpmsim )
            lcaPut( bpmpvs.err, bpmparms.err );
        end
    end
    
catch ME
    dbstack;
    msg = 'Error, see matlab console';
    if ~( bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end
    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    return;    
end
% Temporary safety save until this version fully tested
try
path_name=(['/u1/lcls/physics/cavityBPM/calibration/data/backup/' beamline '/']);
date=datestr(now,31);
str = ['BPMCalib',beamline,'_',date(1:10),'_',date(12:13),'_',date(15:16), '_afternongirder'] ;
save(fullfile(path_name,str))
fprintf('All variables saved to %s%s.mat\n\n',path_name,str); 
catch ME
end

% Batch calibration, many BPMs with one corrector pair
try
    selNonGirderBatchBPMs = getSelNotSkippedNotDone( c, nonGirderBatchBPMs, bpmparms );  
    
    if ( any(selNonGirderBatchBPMs) )
        
        setuppred = 0;
        for l = 1:length( selNonGirderBatchBPMs )
            k = selNonGirderBatchBPMs(l);
            if ( bpm(k).method == c.CAL_PRED )
                setuppred = 1;
                break;
            end
        end
        
        if ( setuppred )
            [bpm, bpmparms.err] = calNonGirderBpmSetupPred( bpms, bpm, ...
                bpmparms.acc, bpmparms.sel, bpmpvs, selNonGirderBatchBPMs, bpmparms.err, c, bpmsim, beampathstr );
            
            % Update list, in case any had errors during calNonGirderBpmSetupPred
            selNonGirderBatchBPMs = getSelNotSkippedNotDone( c, selNonGirderBatchBPMs, bpmparms );
        end
        
        % Scan both planes
        a = 1; b = 2;        
        
        if ( launchstruct.inuse )
            nsamples = launchstruct.nsamples;
            nsig = length( launchstruct.pvs );
        else
            nsamples = c.NSAMPLES;
        end

        % Scan until all BPMs done, too many failed attempts, or other error
        done = 0;
        while ( ~done )
            
            tic
            [bpm, bpmparms.err, launchstruct] = calScanNonGirder( a, b, cor, commoncorpair, bpmsigpvs, nbpms, ...
                bpmparms.acc, selNonGirderBatchBPMs, bpm, restore_mask, scanpvs, bpmsim, c, bpmparms.err, und, fb, launchstruct, nsamples ); % Acquire data
            toc
            
            if ( launchstruct.inuse )
                launchstruct = launchFilterData( launchstruct );
            end

            % Calculate calibration parameters and assess success
            for l = 1:length( selNonGirderBatchBPMs )
                j = selNonGirderBatchBPMs(l);
                if ( ~thisBpmSkipped( bpmparms.err, j, c ) ) 
                    if ( launchstruct.inuse )
                        if ( launchstruct.debug )
                            for z = 1:nsig
                                launchstruct.rsq.xscanx(z) = fitCheck( launchstruct.xdata(z,:), real(bpm(j).dataX(1,:)), j, z, 'X', 'X', launchstruct.plotf );                                
                                launchstruct.rsq.yscanx(z) = fitCheck( launchstruct.ydata(z,:), real(bpm(j).dataY(1,:)), j, z, 'Y', 'X', launchstruct.plotf );
                                disp(' ');
                                launchstruct.rsq.xscany(z) = fitCheck( launchstruct.xdata(z,:), real(bpm(j).dataX(2,:)), j, z, 'X', 'Y', launchstruct.plotf ); 
                                launchstruct.rsq.yscany(z) = fitCheck( launchstruct.ydata(z,:), real(bpm(j).dataY(2,:)), j, z, 'Y', 'Y', launchstruct.plotf );
                                disp(' ');
                            end
                        end
                        bpm(j) = launchSelData( bpm(j), launchstruct );
                    end
                    [bpmparms.uscl(j),bpmparms.vscl(j),bpmparms.uv(j),bpmparms.vu(j),bpmparms.uphas(j),bpmparms.vphas(j),bpmparms.ur(j),bpmparms.vr(j),bpm(j), xbaddata, ybaddata] = ...
                        calBpmCookData( j, bpm(j), bpms{j}, plotf, bpmparms.uscl_i(j), bpmparms.vscl_i(j), bpmparms.ur(j), bpmparms.vr(j), ...
                        bpmparms.uscl(j), bpmparms.vscl(j), bpmparms.uphas(j), bpmparms.vphas(j), bpmparms.uv(j), bpmparms.vu(j), c );
                    if ( plotf == c.PLOT_SINGLE )
                        pause( 5 ); % Give user time to see the data
                    end
                    bpmparms.err(j) = getScanError( xbaddata,  ybaddata, bpm(j), bpmparms.err(j), bpmparms.ur(j), bpmparms.vr(j), c );
                end
            end
            
            % Update list
            selNonGirderBatchBPMs = getSelNotSkippedNotDone( c, selNonGirderBatchBPMs, bpmparms );
            % Determine if need to scan again and if so, which BPMs and which planes
            [done,a,b] = nonGirderPlanScan(bpmparms.ur,bpmparms.vr,selNonGirderBatchBPMs,c);
            
            if ( lcaGet( scanpvs.abort, 0, 'float' ))
                restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
            end
        end
        if ( ~bpmsim )
            lcaPut( bpmpvs.err, bpmparms.err );
        end
        
        for l = 1:length( nonGirderBatchBPMs )
            j = nonGirderBatchBPMs(l);
            if ( bpmparms.sel(j) )
                if ( coupling_flag )
                    [bpmparms.phi(j),bpmparms.psi(j)] = calBpmCouplingWrapper( bpmparms.ur(j), bpmparms.vr(j), bpmparms.uv(j), bpmparms.vu(j), bpmparms.phi(j), bpmparms.psi(j) );
                end
                if ( ~bpmsim )
                    lcaPut( bpmpvs.prog{j}, c.PROG_SCANDONE );
                end
            end
        end
    end
    
catch ME
    dbstack;
    msg = 'Error, see matlab console';
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end
    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    return;
end

% Temporary safety save until this version fully tested
try
path_name=(['/u1/lcls/physics/cavityBPM/calibration/data/backup/' beamline '/']);
date=datestr(now,31);
str = ['BPMCalib',beamline,'_',date(1:10),'_',date(12:13),'_',date(15:16), '_afternongirderbatch'] ;
save(fullfile(path_name,str))
fprintf('All variables saved to %s%s.mat\n\n',path_name,str); 
catch ME
end

try
    if ( lcaGet( scanpvs.abort, 0,'float' ) )
        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    end

    elapsed = toc; %#ok<*NASGU>
    
    % Write calibration parameters to non-girder BPMs
    wsel = zeros( nbpms, 1 );
    % Use full list of non-girder BPMs in case nonGirderBPMs further
    % reduced, for example to remove completed BPMs
    nonGirderBPMs = [ nonGirderBPMs , nonGirderBatchBPMs ];
    for l = 1:length( nonGirderBPMs )
        j = nonGirderBPMs(l);
        wsel(j) = bpmparms.sel(j);
    end
    if ( any( wsel ) )
        [tmp,bpmparms] = calPromptWriteParms(bpms, bpmpvs, bpmparms, wsel, restore_mask, scanpvs, bpmsim, c);
        wstat = max( tmp, wstat ); %#ok<*NODEF>
    end
           
    calBpmLogMsg( 'Cavity BPM calibration complete' );
    calBpmPlotScale( bpmparms, nbpms, bpmparms.sel ) ;
    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    calBpmSaveFile;
    msg = 'Calibration complete';
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    end
    disp( msg );
    endmsg = calLogSum( wstat );
    choice=questdlg(endmsg,'Cavity BPM Calibration complete. Exit Matlab?',...
        'Close all windows and exit','Stay open','Close all windows and exit');
    switch choice
        case 'Close all windows and exit'
            quit;
        case 'Stay open'
    end
        
catch ME
    msg = 'Error: see Matlab console for details';
    disp( msg );
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    end
    dbstack();
    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    return;
end
end


%----End of calCavityBpmMain; begin supporting functions----%

function[rsq] = fitCheck(x, y, j, z, scanstr, planestr, plotf)

cf = polyfit( x, y, 1 );
y_est = polyval( cf, x );

if ( plotf )
figure(1);
plot( x, y );
hold on
plot(x,y_est,'r--','LineWidth',2)
hold off
pause(1); 
end

yresid = (y - y_est);
SSresid = sum( yresid.^2 );
SStotal = (length(y) - 1) * var(y);
rsq = 1 - SSresid/SStotal;
fprintf('BPM %i %s scan %s data launch sig %i fit rsq %f\n', j, scanstr, planestr, z, rsq);

end

function[sublist] = getSelNotSkippedNotDone(c, list, bpmparms)
%
% Create sub-list of selected non-skipped non-done BPM indices
%
    sublist = [];
    for l = 1:length(list)
        index = list(l);
        if ( bpmparms.sel(index) && ~thisBpmSkipped( bpmparms.err, index, c ) && ~(bpmparms.ur(index) && bpmparms.vr(index)) )
            sublist = [sublist, index];
        end
    end
end

function[err] = setErr( err, newerr)
%
%   Or new error bit(s) into bpmparms.error mask for jth BPM
%
err = bitor( err, newerr );
end

function[rval] = thisBpmSkipped(err, j , c)
%
%   Return 1 if this BPM has 'skip' bit set in error mask
%   Else return 0
%
rval = bitand( err(j), c.ERR_SKIP );
end

function[rval, bpmparms] = calPromptWriteParms(bpms, bpmpvs, bpmparms, wsel, restore_mask, scanpvs, bpmsim, c)
%
%
%
nbpms = length( bpms );

% If BPM cal failed, set the bpmparms.select bit to 0 
% so that calBpmPlotScale does not plot it
tmpwsel = wsel;
for j=1:nbpms
    if ( tmpwsel(j) )
        if ( thisBpmSkipped( bpmparms.err, j, c ) )
            tmpwsel(j) = 0;
        end
    end
end
calBpmPlotScale( bpmparms, nbpms, tmpwsel );

if ( ~bpmsim )
    lcaPut( scanpvs.msg, 'Awaiting user input' );
end

choice = questdlg( 'Would you like to implement these changes?', ...
    'Implement Calibration?', 'Yes', 'Partial', 'No', 'Yes' );

switch choice
    case 'Yes'
        [rval,bpmparms] = calBpmWriteParms(bpms, bpmpvs, bpmparms, wsel, bpmsim, scanpvs, c);

    case 'Partial'
        reply = questdlg( 'Select the BPMs you would like to calibrate from the Plotting and Implementing Calibration Display and then hit Go', ...
            'Implement Partial Calibration?', 'Go', 'Cancel', 'Go' );
        switch reply
            case 'Go'
                [rval,bpmparms] = calBpmWriteParms(bpms, bpmpvs, bpmparms, wsel, bpmsim, scanpvs, c);             
            case 'Cancel'                
        end
    case 'No'
        rval = c.RVAL_SUCC;

end

end

function[endmsg] = calLogSum(rval)
%
%    Based on rval, determine final message and print to logbook
%
if ( rval == 0 )
    endmsg = 'Implemented calibration and printed plot of scale changes to logbook';
    util_printLog_wComments( 1000, 'BPMCAL', 'Cavity BPM Calibration Scale Changes ', ' ', [1100 650] );
elseif ( rval > 0 )
    endmsg = 'Calibration completed with errors (see EDM screens).';
    util_printLog_wComments (1000, 'BPMCAL', 'Cavity BPM Scale Changes ', ' ', [1100 650] );
else
    endmsg = 'Failed to implement calibration';
end

end

function[calquit] = calCheckRate
%
%   Check the beam rate. If the rate is zero, it calls 
%   calBeamRateWait; else it waits for the next beam pulse.
%
%   This script is called by calCavityBPMMain 

calquit = 0; 
rate = lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
if rate==0
    calquit = calBeamRateWait(rate);
else
    pause(1/rate)
end

end

function[calquit] = calPromptContinue(abort, promptstr)
%
%   Called when calCavityBPMMain identifies an error.
%   It prompts the user to continue. If the user chooses not to continue
%   set calquit to 1 and return
%
%   To do: make prompstr optional

calquit=0;

if abort
    choice = 'No';
else
    choice=questdlg([promptstr ' Do you want to continue?'],'Continue BPM Calibration?','Yes','No','Yes');
end

switch choice
    case 'No'
        calquit=1;
    case 'Yes'
end

end

function[calquit] = calBeamRateWait(rate)
%
%   Called when calCavityBPMMain identifies zero beam rate.
%   It waits 30 seconds for the rate to return. If it does not, it calls
%   calPromptContinue to prompt the user to choose to continue or exit.
%

g=1; 
calquit = 0;

while (rate==0 &&  g<30)
    pause(1);g=g+1;rate=lcaGet('EVNT:SYS0:1:LCLSBEAMRATE');
end

if g>=30
    promptstr = 'Timeout due to zero beam rate.';
    calquit = calPromptContinue(0, promptstr);
end

end

function[phi,psi] = calBpmCouplingWrapper(ur,vr,uv,vu,phi,psi)
%       calBpmCouplingWrapper
%
%       If both planes were selected and calibrated, call calBpmCoupling
%       to calculate coupling between planes. If not, leave phi/psi at
%       initial values. 
%
%       Arguments:
%                   for uv/vu see calBpmCoupling
%                   ur  - 1 if BPM calibrated in X
%                   vr  - 1 if BPM calibrated in Y
%                   phi - initial phi value
%                   psi - initial psi value
%
%       Return:
%                   phi - new phi value
%                   psi - new psi value
%                           
    
% Calculate coupling if both x and y planes have been calibrated
if ( ur && vr) 
    [phi,psi] = calBpmCoupling( uv, vu );
end
end

function[phi,psi] = calBpmCoupling(uv,vu)
% 
%       calBpmCoupling
%
%       Calculate coupling for single BPM
%
%       Return two angles which parametrize the coupling:
%           phi = angle BPM axes are rotated from true x/y
%           psi = angle between BPM axes
%       If there is no coupling, phi=45 deg, psi=90 deg.
%
%       Arguments:
%                   uv - uvscl/uscl
%                   vu - vuscl/vscl where:
%
%           uscl = x scale factor
%           vscl = y scale factor
%           uvscl = measured y change for x beam position move
%           vuscl = measured x change for y beam position move
%
%           phi = -asin-1(vu)
%           theta = -asin-1(uv)
%           psi = pi/2 + phi + theta
%

phi = (-asin(vu))*(180/pi);
theta = (-asin(uv))*(180/pi);
psi = 90 + phi + theta;

end

function[sel,a,b] = selPlanes(xsel, ysel, c)
%
%       selPlanes
%       
%       Determine whether this BPM selected and in which planes
%       
%       Arguments:
%                   xsel - flag indicating whether selected in X plane
%                   ysel - flag indicating whether selected in Y plane
%       Return:
%                   sel  - flag indicating whether selected in either plane
%                   a    - Starting value in X/Y loop, c.XPLANE if X is selected,
%                          c.YPLANE if only Y is selected, 0 if neither selected
%                   b    - Ending value in X/Y loop, c.XPLANE if only X is selected,
%                          c.YPLANE if Y is selected, 0 if neither selected

a = xsel;
b = ysel;
sel = (a || b );

if ( sel )
    if ( a && b )
        a = c.XPLANE;
        b = c.YPLANE;
    elseif ( a )
        a = c.XPLANE;
        b = c.XPLANE;
    else
        a = c.YPLANE;
        b = c.YPLANE;
    end
else
    a = 0;
    b = 0;
end

end

function[rData] = calSelOrderXYData(data, c, varargin)
%
%       calSelOrderXYData
%
%       Given 2-D data set and optional vector specifying which rows to 
%       use, select rows from data and create 1-D vector of X and Y signals,  
%       in the following order:
%
%       rowa X
%       rowa Y
%       rowb X
%       rowb Y
%       .
%       .
%       .
%
%       Argument:
%                   data      2-D data set (rows are BPMS, cols are signals)
%                   c         Constants struct
%
%   	Optional Argument:
%                   varargin  Vector whose element values are which rows of data
%                             to include
%
%       Return:
%                   rData     Selected, ordered X Y data vector
%

if (length(varargin) == 1)
    vec = varargin{1};
    selData = data( vec, : );
else
    selData = data;
end
    
[r,~] = size( selData );

rData = zeros( 2*r, 1 );

for j = 1:r
    rData(j*2 - 1) = selData(j,c.X);
    rData(j*2)     = selData(j,c.Y);
end

end

function[e, skipPoint] = calDataErrors(rerr, e, nan, tdiff )
%       calChkData
%
%       Check data set for consistent timestamps and to make sure
%       no data points are not-a-number. Update error count, and 
%       determine if point should be skipped.
%
%       Argument:
%                   rerr      return val from data get, 0 if success
%                   e         error count
%                   nan       Non-zero if any values are not-a-number
%                   tdiff     Non-zero if any timestamps differ
%
%       Return:
%                   e         updated error count
%                   skipPoint flag to skip data point

skipPoint = 1;

if ( rerr )
    e = e + 1;
else
    if ( tdiff ) % Timestamps don't match
    elseif ( nan ) % Invalid data or error during get
        e = e + 1;
    else
        skipPoint = 0;
    end
end

end

function[nan, tdiff] = calChkData(dataSet, dataSetTs, acc)
%
%       calChkData
%
%       Check data set for consistent timestamps and to make sure
%       no data points are not-a-number. Call calDataErrors to 
%       update pulse count, error count, and determine if point should be
%       skipped.
%
%       Argument:
%                   dataSet   data
%                   dataSetTs timestamps from data
%                   acc       vector of which rows to use for data
%                             integrity checks
%
%       Return:
%                   nan       Non-zero if any values are not-a-number
%                   tdiff     Non-zero if any timestamps differ
%
select  = not(acc);
selData = dataSet(select,:); % Select only data for online BPMs
selTs   = dataSetTs(select,:);

time = mod(real(selTs),60) + imag(selTs)/1e9;

tdiff = (max(max(time)) ~= min(min(time)));

nan = max(max( isnan( selData ) ));

end
function[dataSet, e, skipPoint, launchstruct, ld] = calGetData(bpmsigpvs, nbpms, acc, e, c, varargin)
%
%   Acquire data from bpmsigpvs.all and  and convert
%   timestamps to seconds and fraction
%
%                   bpmsignpvs BPM signal PVs to lcaGet
%                   nbpms     total number of BPMs            
%                   acc       vector of which rows to use for data
%                             integrity checks
%                   e         error count
%                   c         constants struct
%       Optional:
%                   launchstruct  Data structure used for filtering data
%                             based on incoming orbit  
%
%       Return:
%                   dataSet   data
%                   e         updated error count
%                   skipPoint flag to skip data point
%                   ld         empty if unused
%

ld = [];
if (length(varargin) == 1)
    launchstruct = varargin{1};
    launchcheck = launchstruct.inuse; 
else
    launchcheck = 0;
    launchstruct = 0;
end

try
    if ( launchcheck && (isempty(launchstruct.pvs)) )
        launchcheck = 0;
        disp('WARNING: calGetData: launchpvs must be defined to use launchcheck. Skipping data filtering');
    end
catch ME
    launchcheck = 0;
    
    disp('WARNING: calGetData: launchpvs must be defined to use launchcheck. Skipping data filtering');
end

rerr = 0;

try
    [d ts]=lcaGet( bpmsigpvs.all );
catch ME
    rerr = 1;
    dataSet = 0;
    dataSetTs = 0;
    return;
end

dataSet(:,c.URER)   =  d(1+nbpms*(c.URER-1):nbpms*c.URER);
dataSetTs(:,c.URER) = ts(1+nbpms*(c.URER-1):nbpms*c.URER);

dataSet(:,c.UIMR)   =  d(1+nbpms*(c.UIMR-1):nbpms*c.UIMR);
dataSetTs(:,c.UIMR) = ts(1+nbpms*(c.UIMR-1):nbpms*c.UIMR);

dataSet(:,c.VRER)   =  d(1+nbpms*(c.VRER-1):nbpms*c.VRER);
dataSetTs(:,c.VRER) = ts(1+nbpms*(c.VRER-1):nbpms*c.VRER);

dataSet(:,c.VIMR)   =  d(1+nbpms*(c.VIMR-1):nbpms*c.VIMR);
dataSetTs(:,c.VIMR) = ts(1+nbpms*(c.VIMR-1):nbpms*c.VIMR);

dataSet(:,c.X)      =  d(1+nbpms*(c.X-1):nbpms*c.X);
dataSetTs(:,c.X)    = ts(1+nbpms*(c.X-1):nbpms*c.X);

dataSet(:,c.Y)      =  d(1+nbpms*(c.Y-1):nbpms*c.Y);
dataSetTs(:,c.Y)    = ts(1+nbpms*(c.Y-1):nbpms*c.Y);

if ( launchcheck )
    try
        [ld ts]=lcaGet( launchstruct.pvs );
    catch ME
        rerr = 1;
        dataSet = 0;
        dataSetTs = 0;
        return;
    end        
        
    for k = 1:length( launchstruct.pvs )
        dataSet(:,c.Y + k)  = ld(k);
        dataSetTs(:,c.Y + k) = ts(k);        
    end
end

[nan, tdiff] = calChkData( dataSet, dataSetTs, acc );

[e, skipPoint] = calDataErrors(rerr, e, nan, tdiff );

end
                
function[st] = launchFilterData(st)
%
%       Assess launch data. Compare each pulse's data to mean of
%       all pulses. Pulse is 'good' if its readings within tolerance of
%       mean. 
%       Generate launchstruct.good, which is vector whose elements
%       are the indices of good pulses in the acquired data
%

% means and standard deviations during X and Y scans
st.xmeans = mean(st.xdata' )';
st.xstds  = std( st.xdata' )';
st.ymeans = mean(st.ydata' )';
st.ystds  = std( st.ydata' )';

[~,xn] = size( st.xdata );
[~,yn] = size( st.ydata );

for k = 1:xn
    st.xgoodall(:,k) = abs(st.xmeans - st.xdata(:,k)) <= st.xstds.*st.xadj;   
end

for k = 1:yn
    st.ygoodall(:,k) = abs(st.ymeans - st.ydata(:,k)) <= st.ystds.*st.yadj;
end

st.xgood = find( all(st.xgoodall) );
nnz(st.xgood)
st.ygood = find( all(st.ygoodall) );
nnz(st.ygood)

end

function[bpm] = launchSelData(bpm, launchstruct)
%
%
selx = launchstruct.xgood;
sely = launchstruct.ygood;

bpm.dataX   = bpm.dataX(:,selx);
bpm.bpmVecX = bpm.bpmVecX(:,selx);
bpm.xydataX = bpm.xydataX(:,selx);
    
bpm.dataY   = bpm.dataY(:,sely);
bpm.bpmVecY = bpm.bpmVecY(:,sely);
bpm.xydataY = bpm.xydataY(:,sely);

end

function[ok, predBPMs, predBPMNames] = calNonGirderBpmSelectPred(bpms, bpm, acc, start, stop, incr, c)

nbpms = length( bpms );
predBPMs = zeros( 1, c.NPREDBPMS ); % Predictive BPMs for those upstream of girders
predBPMsAvail = ones( 1, nbpms ); % BPMs to consider for predictive list 
                                    
for j=1:c.NPREDBPMS
    fprintf('calNonGirderBpmSelectPred: find %ith predictive BPM\n', j);
    if ( ~predBPMs(j) )
        %TODO: instead of beginning again at start on each iteration, start
        %after last selected predictive BPM
        for k=start:incr:stop;
            fprintf('calNonGirderBpmSelectPred: test %s for %ith predictive BPM\n', bpms{k}, j);
            if ( ~acc(k) && predBPMsAvail(k) && (bpm(k).type == c.BPM_GRDR))
                predBPMs(j) = k;
                predBPMsAvail(k) = 0;
                fprintf('calNonGirderBpmSelectPred: including BPM %s\n', bpms{k});
                break;
            end
        end
    end
end

ok = all(  predBPMs );
if ( ok )
    for k=1:c.NPREDBPMS
        predBPMNames{k} = bpms{predBPMs(k)};
    end
else
    predBPMNames = {};
end

end

function[bpm, err] = calNonGirderBpmSetupPred(bpms, bpm, acc, sel, bpmpvs, nonGirderBPMs, err, c, bpmsim, beampathstr)
%
%   For calibration of non-girder BPMs choose which BPMs to use for 
%   position prediction. Call calNonGirderBpmGetRmat to get
%   R-matrices between BPMs. Set progress PV to indicate calibration 
%   in progress.

% For best results, choose predictive BPMs nearest to BPMs being calibrated.
% So, for BPMs upstream of girders, start at upstream end and move downstream.
% For BPMs downstream of girders, start at downstream end and move
% upstream.
[upOk, predBPMsUp, predBPMsUpNames] = calNonGirderBpmSelectPred( bpms, bpm, acc, c.FIRST_BPM_GRDR, c.LAST_BPM_GRDR, 1, c );
[dwnOk, predBPMsDwn, predBPMsDwnNames] = calNonGirderBpmSelectPred( bpms, bpm, acc, c.LAST_BPM_GRDR, c.FIRST_BPM_GRDR, -1, c );

% From Henrik: use downstream BPM data and R-matrices between those
% and RFB07/RFB08 to predict position at RFB07/08
for l=1:length(nonGirderBPMs)
    index = nonGirderBPMs(l);
    if ( ~sel(index) )
        continue;
    end
    if ( bpm(index).type == c.BPM_UPSTRM )
        if ( upOk )
            r = model_rMatGet( bpms{index}, predBPMsUpNames, beampathstr, 'TYPE=EXTANT' );
            bpm(index).predBPMs = predBPMsUp;
        else
            err(index) = bitor( err(index), c.ERR_INSUFF );
        end       
    elseif ( bpm(index).type == c.BPM_DWNSTRM )
        if ( dwnOk )
            r = model_rMatGet( bpms{index}, predBPMsDwnNames, beampathstr, 'TYPE=EXTANT' );  
            bpm(index).predBPMs = predBPMsDwn;
        else
            err(index) = bitor( err(index), c.ERR_INSUFF );
        end
    else
        fprintf('calNonGirderBpmSetupPred: %s %i wrong BPM type %i\n', bpms{index}, index, bpm(index).type);
        err(index) = bitor( err(index), c.ERR_INSUFF );
        continue;
    end
    
    if ( ~bitand( err(index), c.ERR_INSUFF ) )
        bpm(index).r13 = reshape( permute( r([1 3],1:4,:) ,[1 3 2] ), [], 4 );      
        if ( ~bpmsim )
            lcaPut( bpmpvs.prog{index}, c.PROG_SCAN );
        end
    end
end
end

function[err] = getScanError(xbaddata, ybaddata, bpm, err, xdone, ydone, c)
%
%   Set error flags, based on scan results
%

if ( xbaddata )                % If x failed because of bad data fit
    if ( bpm.ntriesX >= c.NRETRIES ) % If we've already tried x NRETRIES times, skip this BPM
        err = setErr( err, c.ERR_BADFIT );
    end
elseif ( ybaddata )            % If y failed because of bad data fit
    if ( bpm.ntriesY >= c.NRETRIES )  % If we've already tried y NRETRIES times, skip this BPM
        err = setErr( err, c.ERR_BADFIT );
    end
elseif ( ~xdone ) % If x failed because of other reason, skip this BPM
    err = setErr( err, c.ERR_CALCX );    
elseif ( ~ydone ) % If y failed because of other reason, skip this BPM
    err = setErr( err, c.ERR_CALCY );
end

end

function[done,a,b] = nonGirderPlanScan(ur,vr,selNonGirderBPMs,c)
%
%   For non-girder BPMs, use recent scan results to determine
%   if need to do another and if so, in which planes
%

udone = 1;
vdone = udone;

for l = 1:length(selNonGirderBPMs)
    j = selNonGirderBPMs(l); % index into bpm arrays
    udone = min( udone, ur(j) );
    vdone = min( vdone, vr(j) );
end

if ( udone && vdone )
    a = 1; % Set to default values so function call succeeds, but
    b = 2; % these values will not be used because these BPMs are done
    done = 1;
else
    [~,a,b] = selPlanes( ~udone, ~vdone, c );
    done = 0;
end

end
   
function[bpm] = storeData(bpm,p,dataSet,j,m,c)

if ( m == c.XPLANE )
    bpm.dataX(c.XPLANE,p) = dataSet(j,c.URER) + 1i*dataSet(j,c.UIMR);
    bpm.dataX(c.YPLANE,p) = dataSet(j,c.VRER) + 1i*dataSet(j,c.VIMR);
elseif ( m == c.YPLANE)
    bpm.dataY(c.XPLANE,p) = dataSet(j,c.URER) + 1i*dataSet(j,c.UIMR);
    bpm.dataY(c.YPLANE,p) = dataSet(j,c.VRER) + 1i*dataSet(j,c.VIMR);
end
end

function[segmentList,xmovList,ymovList] = planGirderMoves(j,segmentList,m,mov,k,prevBpm,prevPlane,prevGirder,c)
% For next move, create list of girders and their move planes/sizes
% If previous BPM was special case RFBHX12, restore it to original
% segmentList is girders to wait for later; this list is augmented if
% we are also restoring the previous girder

if ( m == c.XPLANE )
    xmov  = mov.steps(k);
    ymov  = 0;
elseif ( m == c.YPLANE )
    xmov  = 0;
    ymov  = mov.steps(k);
end

% Girder moves to make later; this list is augmented if
% we are also restoring the previous girder
xmovList = xmov;
ymovList = ymov;

% If this is NOT our first BPM and first plane and it IS the first
% step, determine what needs to be restored from the last move
if ( (k == 1) && (prevBpm ~= 0) )
    if ( prevPlane == c.XPLANE )
        xmovLast = mov.restore;
        ymovLast = 0;
    elseif ( prevPlane == c.YPLANE )
        xmovLast = 0;
        ymovLast = mov.restore;
    end
    if ( j == prevBpm )
        xmovList = xmov + xmovLast;
        ymovList = ymov + ymovLast;
    else
        % TODO: remove this comment if no longer true
        % When moving girder 1 with others,
        % girder 1 must be first in the list
        segmentList = [prevGirder, segmentList];
        xmovList    = [xmovLast; xmov];
        ymovList    = [ymovLast; ymov];
    end
end
end

function[bpm,prevBpm,prevPlane,prevGirder] = calScanGirder(a,b,bpm,j,mov,prevBpm,prevPlane,prevGirder,bpmsigpvs,nbpms,acc,bpmpvs,c,restore_mask,err,beamline,scanpvs,bpmsim,fb)

for m=a:b
    if ( lcaGet( scanpvs.abort, 0, 'float' ) )
        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    end
    if ( ~bpmsim )
        lcaPut( bpmpvs.prog{j}, c.PROG_SCAN );
    end
    tstatus = 1; % Initialize girder move status to success
    msg = ['Moving girder '  num2str( bpm.girder )];
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end
    
    for k = 1:c.NSTEPS

        [segmentList,xmovList,ymovList] = planGirderMoves( j, bpm.girder, m, mov, k, prevBpm, prevPlane, prevGirder, c );
        
        e = 0; % Initialize error count
        n = 1; % Initialize sample number
        
        if ( ~bpmsim )
            status = BPMMove ( beamline, segmentList, xmovList, ymovList );
            pause(2); % Wait for mover to settle
        else
            status = 1;
        end
        
        tstatus = min( tstatus, status); % Capture any girder move errors
        
        while n <= c.NSAMPLES
            newdata = 1;
            try lcaNewMonitorWait( bpmsigpvs.mon )
            catch ME
                disp( 'Timeout waiting for new data' );
                e = e + 1;
                newdata = 0;
            end
            if ( newdata )
                [dataSet, e, skipPoint, ~, ~] = calGetData( bpmsigpvs, nbpms, acc, e, c );
                if ( ~skipPoint )
                    
                    xydata = calSelOrderXYData( dataSet, c );

                    p = c.NSAMPLES*(k-1) + n; % Point number
                    % Copy data and calculate x, x', y, y' vector at BPM
                    % bpm.dataX/Y: | urer +iuimr, ... |  bpm.bpmVecX/Y:   | x |
                    %              | vrer +ivimr, ... |                   | x'|
                    %                                                     | y |
                    %                                                     | y'|
                    %          data points -...
                    if ( m == c.XPLANE )
                        bpm = storeData( bpm, p, dataSet, j, m, c );
                        bpm.xydataX(:,p) = xydata;
                        % fix found sign error
                        bpm.bpmVecX(:,p) = -[mov.offsets(k)/1000;0;0;0]; % [m]
                    elseif ( m == c.YPLANE )
                        bpm = storeData( bpm, p, dataSet, j, m, c );
                        bpm.xydataY(:,p) = xydata;
                        bpm.bpmVecY(:,p) = -[0;0;mov.offsets(k)/1000;0]; % [m]
                    end
                    n = n + 1;
                end
            else
                if ( calCheckRate || (lcaGet(scanpvs.abort,0,'float')) )
                    restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
                end
            end
            if ( e > c.NPULSESABORT )
                promptstr = 'Timeout or no beam present.';
                if (calPromptContinue( 0, promptstr ) )
                    restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                    calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
                end
                e = 0; % If user chooses to continue, zero err and continue scan
            end
        end
    end
    if ( tstatus ~= 1 )
        err(j) = bitor( err(j), c.ERR_GIRDER );
    end
    prevPlane = m; prevBpm = j; prevGirder = bpm.girder; % For use in restoring girders
end

end

function[bpm, err, launchstruct] = calScanNonGirder(a,b,cor,corpair,bpmsigpvs,nbpms,acc,selNonGirderBPMs,bpm,restore_mask,scanpvs,bpmsim,c,err,und,fb,launchstruct,nsamples)

for m = a:b
    if ( m == c.XPLANE )
        msg = 'Scanning X corrector';
        xycor = corpair.x;
    else
        msg = 'Scanning Y corrector';
        xycor = corpair.y;
    end
   
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg );
    end   
    
    if ( lcaGet( scanpvs.abort, 0, 'float' ) )
        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
    end
    
    if ( launchstruct.inuse )
        launchstruct.data = [];
    end
    
    try
        for k = 1:cor.nsteps
            corset = xycor.steps(k);
            if ( ~bpmsim )
                lcaPut( xycor.setpv, corset );
                pause(5); % Wait for corrector to settle
            end
            e = 0; % Error count for bad data
            n = 1; % Data sample count
            while n <= nsamples
                newdata = 1;
                try
                    if ( ~launchstruct.inuse )
                        lcaNewMonitorWait( bpmsigpvs.mon )
                    else
                        lcaNewMonitorWait( [bpmsigpvs.mon; launchstruct.pvs] );
                    end
                catch ME
                    disp( 'Timeout waiting for new data' );
                    e = e+1;
                    newdata = 0;
                end
                
                if ( newdata )
                    [dataSet, e, skipPoint, launchstruct, ld] = calGetData( bpmsigpvs, nbpms, acc, e ,c, launchstruct );
                    if ( ~skipPoint )
                        xydata = calSelOrderXYData( dataSet, c );
                        p = nsamples*(k-1) + n; % Point number
                        if ( launchstruct.inuse )
                            if ( m == c.XPLANE )
                                launchstruct.xdata(:,p) = ld;
                            else
                                launchstruct.ydata(:,p) = ld;
                            end
                        end
                        
                        for l = 1:length(selNonGirderBPMs)
                            j = selNonGirderBPMs(l);
                            if ( bpm(j).method == c.CAL_PRED )
                                predData = calSelOrderXYData( dataSet, c, bpm(j).predBPMs );
                            elseif ( bpm(j).method == c.CAL_COR )
                                % Only these 2 methods allowed
                            else
                                err(j) = bitor( err(j), c.ERR_CONFIG );
                                disp(['BPM ' int2str(j) ' illegal method ' int2str(bpm(j).method)]);
                                continue;
                            end
                            % Copy data and calculate x, x', y, y' vector at BPM
                            % bpm.dataX/Y: | urer +iuimr, ... |  bpm.bpmVecX/Y:   | x |
                            %              | vrer +ivimr, ... |                   | x'|
                            %                                                     | y |
                            %                                                     | y'|
                            %          data points -...
                            bpm(j) = storeData( bpm(j), p, dataSet, j, m, c );
                            if (  bpm(j).method == c.CAL_PRED )
                                if ( m == c.XPLANE )
                                    bpm(j).xydataX(:,p) = xydata; % not currently used for CAL_PRED method; only for jitter correction
                                    bpm(j).predDataX(:,p) = predData; % X and Y data for BPMs to predict BPM j positions
                                    if ( p == cor.nsteps*nsamples ) % If all data collected
                                        bpm(j).bpmVecX  = bpm(j).r13\(bpm(j).predDataX/1000);
                                    end
                                else
                                    bpm(j).xydataY(:,p) = xydata; % not currently used for CAL_PRED method; only for jitter correction
                                    bpm(j).predDataY(:,p) = predData; % X and Y data for BPMs to predict BPM j positions
                                    if ( p == cor.nsteps*nsamples ) % If all data collected
                                        bpm(j).bpmVecY  = bpm(j).r13\(bpm(j).predDataY/1000);
                                    end
                                end
                            else
                                if ( m == c.XPLANE )
                                    bpm(j).xydataX(:,p) = xydata;
                                    vecCor=[0;corset/(c.C*c.E);0;0];
                                    bpm(j).bpmVecX(:,p) = bpm(j).rxcor*vecCor;
                                else
                                    bpm(j).xydataY(:,p) = xydata;
                                    vecCor=[0;0;0;corset/(c.C*c.E)];
                                    bpm(j).bpmVecY(:,p) = bpm(j).rycor*vecCor;
                                end
                            end
                        end
                        n = n + 1;
                    end
                else
                    if ( calCheckRate || (lcaGet( scanpvs.abort, 0, 'float')) )
                        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
                    end
                end
                if ( e > c.NPULSESABORT )
                    promptstr = 'Timeout or no beam present.';
                    if calPromptContinue( 0, promptstr )
                        restore_mask = bitor( restore_mask, c.RESTORE_QUIT );
                        calBpmRestore(restore_mask, c, scanpvs, und, fb, bpmsim);
                    end
                    e = 0; % If user chooses to continue, zero err and continue scan
                end
            end
        end
        if ( ~bpmsim )
            lcaPut( xycor.setpv, xycor.init );
            pause(5); % Wait for corrector to settle
        end
    catch ME
        % In case of error, restore corrector here instead of in
        % calBpmRestore. Now that potentially many correctors in scan,
        % this is simpler.
        if ( ~bpmsim )
            lcaPut( xycor.setpv, xycor.init );
        end
        rethrow( ME );
    end
end

end

