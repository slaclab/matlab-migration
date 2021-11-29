%   calBpmHxrInit
%
%   This script does all the initialization work for HXR cavity BPM
%   calibration:
%       Initialize variables, get initial values, get model data,
%       record feedback status, turn off feedback, set Calib status PV,
%       etc.
%
%   For pieces common to other beamlines, it calls functions:
%       calBpmHeader
%       calBpmInitStruct
%       calBpmInitCor
%       calBpmInitCorModel
%       calBpmInitUnd
%
%
%   This script is called by calCavityBPMMain

% During commissioning, point to Heinz-Dieter's working areas
addpath(genpath('/home/physics/nuhn/wrk/matlab/cams'))
%addpath(genpath('/home/physics/sonya/bpmcommissioning/matlab/toolbox'))

if ( bpmsim )
    addpath(genpath('/afs/slac/u/ad/sonya/work/Bpm/matlab/toolbox/'))
    addpath(genpath('/afs/slac/u/ad/sonya/work/Bpm/matlab/src-beta/cams'))
end

% During commissioning, disable coupling correction
coupling_flag = 1; % disable coupling calculation during initial commissioning

% Is-initialized flag
init = 0;

cal_prefix = 'BPMS:UNDH:1';

[c,scanpvs] = calBpmHeader(cal_prefix);

fb=[]; % Define fb variable to satisfy call to calBpmRestore.
fb1_pv = 'FBCK:FB03:TR04:MODE'; % EPICS undulator launch
fb.pvs = {fb1_pv};

% Hardcode, not sure if ever belongs in PV:
% 0 for scan individual BPMs
% 1 for single corrector pair scan for all
calmode = 0

if ( calmode )
    corscanrange = 0.15;
    c.NSTEPS = 4; % Number of steps in position
    c.NSAMPLES = 25;
    c.NRETRIES = 1;
else
    corscanrange = 0.25;
    c.NSTEPS = lcaGet( [cal_prefix ':NSTEPS'] );
end
c.NPOINTS  = c.NSTEPS*c.NSAMPLES;
    
restore_mask = 0; % Flag to restore feedback state(s)

try  
    % Declare BPMs to calibrate
    bpms = {'BPMS:LTUH:910', 'BPMS:LTUH:960','BPMS:UNDH:1305','BPMS:UNDH:1390','BPMS:UNDH:1490', ...
        'BPMS:UNDH:1590','BPMS:UNDH:1690','BPMS:UNDH:1790','BPMS:UNDH:1890','BPMS:UNDH:1990', ...
        'BPMS:UNDH:2090','BPMS:UNDH:2190','BPMS:UNDH:2290','BPMS:UNDH:2390','BPMS:UNDH:2490', ...
        'BPMS:UNDH:2590','BPMS:UNDH:2690','BPMS:UNDH:2790','BPMS:UNDH:2890','BPMS:UNDH:2990', ...
        'BPMS:UNDH:3090','BPMS:UNDH:3190','BPMS:UNDH:3290','BPMS:UNDH:3390','BPMS:UNDH:3490', ...
        'BPMS:UNDH:3590','BPMS:UNDH:3690','BPMS:UNDH:3790','BPMS:UNDH:3890','BPMS:UNDH:3990', ...
        'BPMS:UNDH:4090','BPMS:UNDH:4190','BPMS:UNDH:4290','BPMS:UNDH:4390','BPMS:UNDH:4490', ...
        'BPMS:UNDH:4590','BPMS:UNDH:4690','BPMS:UNDH:5190'
        };
    nbpms = length( bpms ); % Number of BPMs to calibrate
    
    model_init( 'source', 'MATLAB' );
    beampath = 'CU_HXR';
    beampathstr = ['BEAMPATH=' beampath];
    E = model_rMatGet( bpms{1}, [], {beampathstr,'TYPE=EXTANT'},'EN' ); % Get energy at first BPM
    c.E = E(1);

    % At minimum, inuse needs to be defined even if not using
    % Define these before calBpmInitStruct
    launchstruct.inuse = 1;
    % NOTE: In current implementation, pvs cannot overlap with other PVs
    % being monitored; this duplication results in CA error
    launchstruct.pvs = {'BPMS:LTUH:350:XCUHBR';'BPMS:LTUH:450:XCUHBR';'BPMS:LTUH:720:XCUHBR';'BPMS:LTUH:680:XCUHBR';'BPMS:LTUH:680:YCUHBR';'BPMS:LTUH:770:YCUHBR'};
    % NOTE: launchstruct.x/ydata needs to be defined as empty data set 
    % before each data set (for which it is being used), for example, 
    % between BPM for non-batch acquisitions & before a batch acquisition.
    launchstruct.nsamples = 10*c.NSAMPLES;
    launchstruct.xadj = [0.3; 0.5; 0.3; 0.3; 0.7; 0.5];
    launchstruct.yadj = [0.5; 0.7; 0.5; 0.5; 0.3; 0.5];
    lcaSetMonitor( launchstruct.pvs );    
    launchstruct.debug = 1;
    launchstruct.plotf = 0;
    
    [s, restore_mask, cor, corpairstruct, wstat, dataSet, dataSetTs, bpm, bpmpvs, bpmsigpvs, jdata, bpmparms] = ...
    calBpmInitStruct(bpmsim, scanpvs, c, nbpms, bpms, corscanrange, 'CUHBR');
    
    if ( s ~= c.RVAL_SUCC )
        return;
    end

    % Disable undulator launch feedbacks
    % Doing this before calBpmInitCor means init corrector values
    % are correct
    % If fbck was on before scan, turn it back on after
    for i = 1:length( fb.pvs )
        fb.vals(i) = lcaGet( fb.pvs{i}, 0, 'float' );
        if ( ~bpmsim )
            lcaPut( fb.pvs{i}, 0 );
        end
        restore_mask = bitor( restore_mask, c.RESTORE_FB );
    end
    
    write=0; % Don't write PVs during calibration but add hooks to implement this eventuall
    commoncorpair = corpairstruct;
    commoncorpair.x.name = 'XCOR:LTUH:818';
    commoncorpair.y.name = 'YCOR:LTUH:837';
    [s, commoncorpair, ~, ~] = calBpmInitCor(c,cor,commoncorpair,bpms{1},beampathstr,scanpvs,bpmsim);
    if ( s ~= c.RVAL_SUCC )
        return
    end
        
    if ( calmode ) % Rough calibration using single corrector pair
        plotf = c.PLOT_OFF;

        nonGirderBatchBPMs = [];
        
        [s, rxcor, rycor] = calBpmInitCorModel(c,commoncorpair, nbpms, bpms, beampathstr, scanpvs, bpmsim);
        for j = 1:nbpms
            nonGirderBatchBPMs = [nonGirderBatchBPMs, j];
            bpm(j).method = c.CAL_COR;
            bpm(j).dj = 0;
            bpm(j).rxcor = rxcor(:,:,j);
            bpm(j).rycor = rycor(:,:,j);
            if ( s(j) ~= c.RVAL_SUCC )
                bpmparms.err(j) = bitor( bpmparms.err(j), c.ERR_MODEL ); % skip this BPM
            end
        end
        
        disp('Coarse calibration scan. Expected beam position changes at each BPM:')
        for j = 1:nbpms
            vecCor=[0;commoncorpair.x.range/(c.C*c.E);0;0];
            bpmVecX = bpm(j).rxcor*vecCor;
            vecCor=[0;0;0;commoncorpair.y.range/(c.C*c.E)];
            bpmVecY = bpm(j).rycor*vecCor;
            fprintf('%s: X %.3f mm, Y %.3f mm\n',bpms{j}, abs(1000*bpmVecX(1)), abs(1000*bpmVecY(3)));
        end

        und=[]; % Define und variable to satisfy call to calBpmRestore. Rely on restore_mask to define what actually needs to be restored;
        c.fitrsq = 0.3; % Relax fit goodness of fit requirements for rough calibration
        
    else % Standard calibration using girders and correctors
        plotf = c.PLOT_SINGLE;
        
        % Indices for some special BPMs
        RFB07  = 1;
        RFB08  = 2;
        RFBHX12 = 3;
        RFBHX13 = 4;
        RFBHX51 = 38;
        
        c.FIRST_BPM_GRDR = RFBHX12;
        c.LAST_BPM_GRDR = RFBHX51 - 1;
        
        nonGirderBPMs = [];
        nonGirderBatchBPMs = [];
        girderBPMs = [];
        
        [~,bpmzs,~,~,~]  = model_rMatGet( bpms, [] , {beampathstr,'TYPE=EXTANT'});
        
        for j = 1:nbpms     
            
            % Set BPM type and associated girder number
            if ( j < RFBHX12 )
                bpm(j).girder = 0;
                bpm(j).type = c.BPM_UPSTRM;
                nonGirderBatchBPMs = [nonGirderBatchBPMs, j];
                bpm(j).method = c.CAL_PRED;
                bpm(j).corpair.x.name = 'XCOR:LTUH:818';
                bpm(j).corpair.y.name = 'YCOR:LTUH:837';
            elseif ( j == RFBHX12 )
                bpm(j).girder = j+9;
                bpm(j).type = c.BPM_GRDR;
                bpm(j).method = c.CAL_GRDR;
                girderBPMs = [girderBPMs, j];
            elseif ( j == RFBHX51 )
                bpm(j).girder = 0;
                bpm(j).type = c.BPM_DWNSTRM;
                nonGirderBPMs = [nonGirderBPMs, j];
                bpm(j).method = c.CAL_COR;
                bpm(j).corpair.x.name = 'XCOR:UNDH:4680';
                bpm(j).corpair.y.name = 'YCOR:UNDH:4680';
            else
                bpm(j).girder = j+9;
                bpm(j).type = c.BPM_GRDR;
                bpm(j).method = c.CAL_GRDR;
                bpm(j).kc = 1;
                girderBPMs = [girderBPMs, j];
                % Only get model data if BPM selected (time-consuming)
                if ( bpmparms.sel(j) )
                    % For BPMs RFBHX13 through RFBHX46,
                    % get R-matrices between upstream pivot point and BPM
                    % Used to correct for kick from quad
                    bpmz = bpmzs(j);
                    if ( j == RFBHX13 )
                        % RFBHX13 moves pivot about point 4.142767 m upstream
                        % Create r-matrix between that point and BPM,
                        % combining r-matrix beween RFBHX12 and RFBHX13
                        % and drift space between pivot point and RFBHX12
                        [~,rfbhx12z,~,~,~]  = model_rMatGet( 'RFBHX12', [] , {beampathstr,'TYPE=EXTANT'});
                        deltaz = 4.142767 - (bpmz - rfbhx12z);
                        drift = [ 1 deltaz 0 0; 0 1 0 0; 0 0 1 deltaz; 0 0 0 1 ];
                        rMat = model_rMatGet( 'RFBHX12', bpms{j}, {beampathstr,'TYPE=EXTANT'} );
                        rMat = rMat(1:4,1:4); % Only elements  in rows/columns 1-4 are used
                        rMat = rMat*drift;
                        bpm(j).rMat = rMat;
                        bpm(j).L = 4.142767;
                    else
                        bpm(j).rMat = model_rMatGet( sprintf('QHXH%02d',bpm(j).girder-1), bpms{j}, {beampathstr,'TYPE=EXTANT'} );
                        [~,pivotz,~,~,~] = model_rMatGet( sprintf('QHXH%02d', bpm(j).girder-1), [] , {beampathstr,'TYPE=EXTANT'});
                        bpm(j).L = bpmz - pivotz;
                    end
                    bpm(j).kcx = (bpm(j).rMat(1,2))/bpm(j).L;
                    bpm(j).kcy = (bpm(j).rMat(3,4))/bpm(j).L;
                end
            end
            if ( (bpm(j).method == c.CAL_COR) || (bpm(j).method == c.CAL_PRED) )
                [s, bpm(j).corpair, bpm(j).rxcor, bpm(j).rycor] = calBpmInitCor(c,cor,bpm(j).corpair,bpms{j},beampathstr,scanpvs, bpmsim);
                if ( s ~= c.RVAL_SUCC )
                    return
                end
                % If corrector scan uses more steps than girder scan,
                % update array sizes
                if (cor.nsteps > c.NSTEPS)
                    bpm(j).dataX   = zeros( 2, cor.npoints ); bpm(j).dataY = bpm(j).dataX;
                    bpm(j).bpmVecX = zeros( 4, cor.npoints ); bpm(j).bpmVecY = bpm(j).bpmVecX;
                    bpm(j).UdjX    = zeros( cor.npoints, 1); bpm(j).VdjX = bpm(j).UdjX;
                    bpm(j).UdjY    = bpm(j).UdjX; bpm(j).VdjY = bpm(j).UdjX;
                    bpm(j).predDataX = zeros( 2*c.NPREDBPMS, cor.npoints ); bpm(j).predDataY = bpm(j).predDataX;
                    bpm(j).xydataX = zeros( 2*nbpms, cor.npoints ); bpm(j).xydataY = bpm(j).xydataX;
                end
            end
        end
        
        % Configure jitter correction settings for each BPM:
        % if it is used and if so, which BPMs are used
        for j = RFBHX12:nbpms
            if ( bpmparms.sel(j) && ~bitand( bpmparms.err(j), c.ERR_SKIP ) )
                if ( j == RFBHX13 )                  % Special case: upstream BPM on same girder and only 2 cavity BPMs
                    if ( bpmparms.acc(j-2) || bpmparms.acc(j-3) )      % upstream of that. If either upstream BPM not online, do not calibrate
                        bpmparms.err(j) = bitor( bpmparms.err(j), c.ERR_INSUFF);
                    else
                        bpm(j).p1 = j - 2 ;
                        bpm(j).p2 = j - 3 ;
                        bpm(j).dj = 1;
                    end
                else
                    if ( j == RFBHX51 )
                        djstart = j - 2; % Use corrector pair 4680 to calibrate this BPM,
                                         % so choose de-jitter BPMs upstream of that
                    else
                        djstart = j - 1; % Otherwise use BPMs immediately upstream
                    end
                    for k=djstart:-1:1
                        if ( ~bpm(j).p1 )
                            if ( ~bpmparms.acc(k) )
                                bpm(j).p1 = k;
                            end
                        elseif ( ~bpm(j).p2 )
                            if ( ~bpmparms.acc(k) )
                                bpm(j).p2 = k;
                            end
                        end
                    end
                    if ( ~bpm(j).p1 || ~bpm(j).p2 )
                        bpmparms.err(j) = bitor( bpmparms.err(j), c.ERR_INSUFF);
                    else
                        bpm(j).dj = 1;
                    end
                end
            end
        end
        
        % Get initial girder settings
        und.str = beamline;
        und.list = bpm(RFBHX13).girder:bpm(c.LAST_BPM_GRDR).girder;
        [mov, und] = calBpmInitUnd( und, cal_prefix, c );
    end

    init = 1; % Init successfully completed
    
catch ME
    try
        if ( ~bpmsim )
            lcaPut( scanpvs.cal, 0 );
        end
        if ( bitand( restore_mask, c.RESTORE_FB ) )
            for i = 1:length( fb.pvs )
                if ( ~bpmsim )
                    lcaPut( fb.pvs{i}, fb.vals(i) );
                end
            end
        end
    catch ME
        msg = 'lcaPut error while aborting calibration';
        dbstack;
        calBpmLogMsg( msg );
        disp( msg );
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
        end
    end
    if ( strfind( ME.identifier, 'timedOut' ) )
        msg = 'Error during lcaPut or lcaGet.';
        dbstack;
        calBpmLogMsg( msg );
        disp( msg);
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
        end
    else
        msg = 'Error during init.';
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
        end
        dbstack;
    end
end


