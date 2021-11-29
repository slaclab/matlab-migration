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
    addpath(genpath('/afs/slac/u/ad/sonya/toolbox/'))
    addpath(genpath('/afs/slac/u/ad/sonya/cams'))
end

% During commissioning, disable coupling correction
coupling_flag = 1; % disable coupling calculation during initial commissioning

% Is-initialized flag
init = 0;

cal_prefix = 'BPMS:UNDS:1';

[c,scanpvs] = calBpmHeader(cal_prefix);
fb = [];
fb1_pv = 'FBCK:FB04:TR02:MODE'; % EPICS undulator launch
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
    bpms = {'BPMS:UNDS:1690', 'BPMS:UNDS:1990', 'BPMS:UNDS:2190', 'BPMS:UNDS:2490', ...
        'BPMS:UNDS:2590','BPMS:UNDS:2690','BPMS:UNDS:2790','BPMS:UNDS:2890','BPMS:UNDS:2990', ...
        'BPMS:UNDS:3090','BPMS:UNDS:3190','BPMS:UNDS:3290','BPMS:UNDS:3390','BPMS:UNDS:3490', ...
        'BPMS:UNDS:3590','BPMS:UNDS:3690','BPMS:UNDS:3790','BPMS:UNDS:3890','BPMS:UNDS:3990', ...
        'BPMS:UNDS:4090','BPMS:UNDS:4190','BPMS:UNDS:4290','BPMS:UNDS:4390','BPMS:UNDS:4490', ...
        'BPMS:UNDS:4590','BPMS:UNDS:4690','BPMS:UNDS:4790', 'BPMS:UNDS:5190'
        };
    nbpms = length( bpms ); % Number of BPMs to calibrate

    model_init( 'source', 'MATLAB' );
    beampath = 'CU_SXR';
    beampathstr = ['BEAMPATH=' beampath];
    E = model_rMatGet( bpms{1}, [], {beampathstr,'TYPE=EXTANT'},'EN' ); % Get energy at first BPM
    c.E = E(1);
    
    % At minimum, inuse needs to be defined even if not using
    % Define these before calBpmInitStruct
    launchstruct.inuse = 1;
    % NOTE: In current implementation, pvs cannot overlap with other PVs
    % being monitored; this duplication results in CA error
    launchstruct.pvs = {'BPMS:LTUS:235:XCUSBR';'BPMS:LTUS:370:XCUSBR';'BPMS:LTUS:680:XCUSBR';'BPMS:LTUS:660:XCUSBR';'BPMS:LTUS:740:YCUSBR';'BPMS:LTUS:750:YCUSBR'};
    % NOTE: launchstruct.x/ydata needs to be defined as empty data set 
    % before each data set (for which it is being used), for example, 
    % between BPM for non-batch acquisitions & before a batch acquisition.
    launchstruct.nsamples = 5 * c.NSAMPLES; % Can try more samples when higher rate
    % Will likely need to revisit threshold adjustments in future,
    % especially if substantial dispersion changes
    launchstruct.xadj = [ 0.5; 0.5; 0.2; 0.2; 0.3; 1.0];
    launchstruct.yadj = [ 0.3; 0.3; 1.0; 1.0; 0.3; 0.3];
    lcaSetMonitor( launchstruct.pvs ); 
    launchstruct.debug = 1;
    launchstruct.plotf = 0;
    
    [s, restore_mask, cor, corpairstruct, wstat, dataSet, dataSetTs, bpm, bpmpvs, bpmsigpvs, jdata, bpmparms] = ...
    calBpmInitStruct(bpmsim, scanpvs, c, nbpms, bpms, corscanrange, 'CUSBR');

    if ( s ~= c.RVAL_SUCC )
        return;
    end

    % Disable undulator launch feedbacks
    % If fbck was on before scan, turn it back on after
    for i = 1:length( fb.pvs )
        fb.vals(i) = lcaGet( fb.pvs{i}, 0, 'float' );
        if ( ~bpmsim )
            lcaPut( fb.pvs{i}, 0 );
        end
        restore_mask = bitor( restore_mask, c.RESTORE_FB );
    end

    write=0; % Don't write PVs during calibration but add hooks to implement this eventually

    commoncorpair = corpairstruct;
    commoncorpair.x.name = 'XCOR:LTUS:826';
    commoncorpair.y.name = 'YCOR:LTUS:839';
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
        RFBSX16 = 1;
        RFBSX19 = 2;
        RFBSX21 = 3;
        RFBSX24 = 4;
        RFBSX25 = 5;
        RFBSX51 = 28;

        c.FIRST_BPM_GRDR = RFBSX25;
        c.LAST_BPM_GRDR = RFBSX51 - 1;

        nonGirderBPMs = [];
        nonGirderBatchBPMs = [];
        girderBPMs = [];

        for j = 1:nbpms

            if (j < RFBSX25)
                bpm(j).girder = 0;
                bpm(j).type = c.BPM_UPSTRM;
                nonGirderBatchBPMs = [nonGirderBatchBPMs, j];
                bpm(j).method = c.CAL_PRED;
                bpm(j).corpair.x.name = 'XCOR:LTUS:826';
                bpm(j).corpair.y.name = 'YCOR:LTUS:839';

            % Set BPM type and associated girder number
            % for non girder BPMs look at RFBHX12
          elseif ( j == RFBSX51 )
                bpm(j).girder = 0;
                bpm(j).type = c.BPM_DWNSTRM;
                nonGirderBPMs = [nonGirderBPMs, j];
                bpm(j).method = c.CAL_COR;
                bpm(j).corpair.x.name = 'XCOR:UNDS:4680';
                bpm(j).corpair.y.name = 'YCOR:UNDS:4680';

            else
                bpm(j).girder = j+20;
                bpm(j).type = c.BPM_GRDR;
                bpm(j).method = c.CAL_GRDR;
                bpm(j).kc = 1;
                girderBPMs = [girderBPMs, j];
                % Compensate for kick due to beam offset in quadrupole
                % magnet. Segment 25 does not have a quad
                if ( j ~= RFBSX25 )
                    % Only get model data if BPM selected (time-consuming)
                    if ( bpmparms.sel(j) )
                        bpm(j).kc = 1;
                        quadname = sprintf('QSXH%02d',bpm(j).girder);
                        rq = model_rMatGet(quadname,quadname,{'POS=BEG' 'POSB=END' 'TYPE=EXTANT',beampathstr});
                        rb = model_rMatGet(quadname,bpms{j},{'POS=END' 'TYPE=EXTANT',beampathstr});
                        rq = rq(1:4,1:4); rb = rb(1:4,1:4); % Reduce to 4x4 elements
                        rq(:,[2 4]) = 0; % Remove elements related to beam trajectory angle; only position is used
                        
                        rMat = rb*rq;
                        bpm(j).kcx = rMat(1,1);
                        bpm(j).kcy = rMat(3,3);
                    end
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
                    bpm(j).xyDataX = zeros( 2*nbpms, cor.npoints ); bpm(j).xyDataY = bpm(j).xyDataX;
                    bpm(j).UdjX    = zeros( cor.npoints, 1); bpm(j).VdjX = bpm(j).UdjX;
                    bpm(j).UdjY    = bpm(j).UdjX; bpm(j).VdjY = bpm(j).UdjX;
                    bpm(j).predDataX = zeros( 2*c.NPREDBPMS, cor.npoints ); bpm(j).predDataY = bpm(j).predDataX;
                    bpm(j).xydataX = zeros( 2*nbpms, cor.npoints ); bpm(j).xydataY = bpm(j).xydataX;
                end
            end
        end

        % Configure jitter correction settings for each BPM:
        % if it is used and if so, which BPMs are used
        for j = RFBSX25:nbpms
            if ( bpmparms.sel(j) && ~bitand( bpmparms.err(j), c.ERR_SKIP ) )

                if ( j == RFBSX51 )
                    djstart = j - 3; % Use corrector pair 4680 to calibrate this BPM,
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

        % Get initial girder settings
        und.str = beamline;
        und.list = bpm(c.FIRST_BPM_GRDR).girder:bpm(c.LAST_BPM_GRDR).girder;
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
