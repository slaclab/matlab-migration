function[s, restore_mask, cor, corpairstruct, wstat, dataSet, dataSetTs, bpm, bpmpvs, bpmsigpvs, jdata, bpmparms] = calBpmInitStruct(bpmsim, scanpvs, c, nbpms, bpms, corscanrange, pvsuff)

s = c.RVAL_SUCC;

try
    if ( ~bpmsim )
        msg = 'Initializing';
    else
        msg = 'Simulation mode';
    end
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
        lcaPut( scanpvs.cal, 1 ); % On user display indicates calibration is running
    else
        disp( msg );
    end
    calBpmLogMsg( msg );
    
    format short;
    lcaSetSeverityWarnLevel( 4 );
    lcaSetRetryCount( 100 ); % Default is 150

    restore_mask = 0; % initialize restore mask to default (see calBpmHeader or calBpmRestore)
    
    wstat = c.RVAL_SUCC; % Initalize cal write to success
    
    % For corrector, use at least 4 steps and hard-code large scan range;
    % fit is better and is not much slower.
    if ( c.NSTEPS < 4 )
        cor.nsteps = 4;
    else
        cor.nsteps = c.NSTEPS;
    end
    cor.npoints = cor.nsteps*c.NSAMPLES;
    cor.scanrange = corscanrange;
    
    % Define corrector structure elements
    f1 =  'name';     val1 = []; % Corrector name, eg 'XCOR:LTUH:818'
    f2 =  'setpv';    val2 = []; % Corrector setting PV name, eg 'XCOR:LTUH:818:BCTRL'
    f3 =  'readpv';   val3 = []; % Corrector setting PV name, eg 'XCOR:LTUH:818:BACT'
    f4 =  'hlimpv';   val4 = []; % Corrector upper limit PV name, eg 'XCOR:LTUH:818:BCTRL.DRVH'
    f5 =  'llimpv';   val5 = []; % Corrector lower limit PV name, eg 'XCOR:LTUH:818:BCTRL.DRVL'
    f6 =  'hlim';     val6 = []; % Corrector upper limit'
    f7 =  'llim';     val7 = []; % Corrector lower limit'
    f8 =  'init';     val8 = 0;  % Initial setting of PV
    f9 =  'start';    val9 = 0;  % Corrector scan first setting
    f10 =  'stop';     val10 = 0;  % Corrector scan last setting
    f11 =  'stepsize'; val11 = 0;  % Corrector scan step size
    f12 =  'steps';    val12 = zeros(cor.nsteps); % Corrector scan steps
    f13 =  'range';    val13 = 0;
    
    corstruct = struct( f1, val1, f2, val2, f3, val3, f4, val4, f5, val5, ...
        f6, val6, f7, val7, f8, val8, f9, val9, f10, val10, f11, val11, ...
        f12, val12, f13, val13);
    
    f1 = 'x';  val1 = corstruct;
    f2 = 'y';  val2 = corstruct;
    
    corpairstruct = struct( f1, val1, f2, val2 );
        
    dataSet=zeros(   nbpms, c.NSIGNALS, c.NPOINTS );
    dataSetTs=zeros( nbpms, c.NSIGNALS, c.NPOINTS );
    
    % Create PV arrays, in vector format for lcaGet
    bpmpvs.gain   = strcat( bpms, ':RCVR_GAIN.RVAL')'; % BPM receiver gain; write to different calibration PVs depending on gain (not yet implemented)
    bpmpvs.uscl   = strcat( bpms, ':USCL')'; % BPM scale
    bpmpvs.vscl   = strcat( bpms, ':VSCL')'; % BPM scale
    bpmpvs.uphas  = strcat( bpms, ':UPHAS')'; % BPM phase
    bpmpvs.vphas  = strcat( bpms, ':VPHAS')'; % BPM phase
    bpmpvs.phi    = strcat( bpms, ':PHI')'; % BPM coupling compensation
    bpmpvs.psi    = strcat( bpms, ':PSI')'; % BPM coupling compensation
    bpmpvs.sel    = strcat( bpms, ':CALSEL')';  % BPM selected to scan
    bpmpvs.wsel   = strcat( bpms, ':CALWRTSEL.RVAL')'; % BPM selected to calibrate
    bpmpvs.acc    = strcat( bpms, ':ACCESS')'; % BPM online status
    bpmpvs.err    = strcat( bpms, ':CALERR')'; % Cal error mask
    bpmpvs.prog   = strcat( bpms, ':CALPROG')'; % Cal progress
    
    bpmpvs.urer   = strcat( bpms, ':URER')';
    bpmpvs.uimr   = strcat( bpms, ':UIMR')';
    bpmpvs.vrer   = strcat( bpms, ':VRER')';
    bpmpvs.vimr   = strcat( bpms, ':VIMR')';
    bpmpvs.x      = strcat( bpms, [':X' pvsuff])';
    bpmpvs.y      = strcat( bpms, [':Y' pvsuff])';

    % Define BPM structure elements; each BPM has the following associated data
    f1 =  'dataX';    val1 = zeros( 2, c.NPOINTS ); % BPM U and V data for all steps of x scan
    f2 =  'dataY';    val2 = zeros( 2, c.NPOINTS ); % BPM U and V data for all steps of y scan
    f3 =  'bpmVecX';  val3 = zeros( 4, c.NPOINTS ); % Calculated x, x', y, y' vectors at BPM
    f4 =  'bpmVecY';  val4 = zeros( 4, c.NPOINTS ); % calculated x, x', y, y' vectors at BPM
    f5 =  'xydataX';  val5 = zeros( 2*nbpms, c.NPOINTS ); % X,Y data during X scan (used in jitter correction)
    f6 =  'xydataY';  val6 = zeros( 2*nbpms, c.NPOINTS ); % X,Y data during Y scan (used in jitter correction)
    f7 =  'UdjX';     val7 = zeros( c.NPOINTS, 1 ); % De-jittered X data from X scan
    f8 =  'VdjX';     val8 = zeros( c.NPOINTS, 1 ); % De-jittered Y data from X scan
    f9 =  'UdjY';     val9 = zeros( c.NPOINTS, 1 ); % De-jittered X data from Y scan
    f10 = 'VdjY';     val10= zeros( c.NPOINTS, 1 ); % De-jittered Y data from Y scan
    f11 = 'rMat';     val11 = zeros( 6, 6 ); % R-matrix between upstream pivot point and BPM (HXR) or between upstream quad and BPM (SXR)
    f12 = 'L';        val12 = zeros( 6, 6 ); % Distance between upstream pivot point and BPM (HXR only; unused in SXR)
    f13 = 'nX';       val13 = 0; % Number of data points taken during X scan (also used later by calPlot)
    f14 = 'nY';       val14 = 0; % Number of data points taken during Y scan (also used later by calPlot)
    f15 = 'predDataX'; val15 = zeros( 2*c.NPREDBPMS, c.NPOINTS );
    f16 = 'predDataY'; val16 = zeros( 2*c.NPREDBPMS, c.NPOINTS ); % BPM data used to predict position at RFB07/RFB08
    f17 = 'p1';       val17 = 0;
    f18 = 'p2';       val18 = 0; % Indicates which 2 upstream BPMS to use for jitter correction
    f19 = 'r13';      val19 = zeros( 2*nbpms, 4); % Used by first 2 BPMs, R-matrix elements for predicting position
    f20 = 'insuff';   val20 = 0; % Can't calibrate due to insufficient nearby BPMs (used for jitter correction or position prediction)
    f21 = 'girder';   val21 = 0; % Girder number associated with BPM (0 for BPMs not on girders)
    f22 = 'cudj';     val22 = zeros( 1, 5 );
    f23 = 'cvdj';     val23 = val22;
    f24 = 'xrsquared';val24 = zeros( 3, 1 ); % R^2 fit assessment; try up to 3 times to get good data
    f25 = 'yrsquared';val25 = val24;
    f26 = 'ntriesX';  val26 = 0;
    f27 = 'ntriesY';  val27 = 0;
    f28 = 'type';     val28 = 0; % Type values defined in calBpmHeader
    f29 = 'special';  val29 = 0; % For special handling
    f30 = 'predBPMs'; val30 = zeros( 1, c.NPREDBPMS );
    f31 = 'dj';       val31 = 0;
    f32 = 'method';   val32 = 0;
    f33 = 'corpair';  val33 = corpairstruct; % Corrector pair data structure
    f34 = 'rxcor';    val34 = []; % R-matrix between X corrector and BPM
    f35 = 'rycor';    val35 = []; % R-matrix between Y corrector and BPM 
    f36 = 'kc';       val36 = 0; % Flag to correct for kick through undulator and quad, used for girder BPMs
    f37 = 'kcx';      val37 = 0; % Amount to scale BPM move to compensate for kick, X plane
    f38 = 'kcy';      val38 = 0; % Amount to scale BPM move to compensate for kick, Y plane
    f39 = 'quad';     val39 = ''; % MAD name of upstream quad; only used if kc is 1; else is empty string
    f40 = 'rMatq2b';  val40 = zeros(6); % R-matrix between quad and BPM; only used if kc is 1; else is array of zeros
    f41 = 'zq';       val41 = 0; % quad z, only used in HXR and if kc is 1
    f42 = 'rMatq2q';  val42 = zeros(6); % R-matrix between quad beginning and end; only used in SXR and if kc is 1; else is array of zeros
   
    bpmstruct = struct( f1, val1, f2, val2, f3, val3, f4, val4, f5, val5, f6, val6, f7, val7, f8, val8, f9, val9, f10, val10, ...
        f11, val11, f12, val12, f13, val13, f14, val14, f15, val15, f16, val16, f17, val17, f18, val18, f19, val19, f20, val20, ...
        f21, val21, f22, val22, f23, val23, f24, val24, f25, val25, f26, val26, f27, val27, f28, val28, f29, val29, f30, val30, ...
        f31, val31, f32, val32, f33, val33, f34, val34, f35, val35, f36, val36, f37, val37, f38, val38, f39, val39, f40, val40, ...
        f41, val41, f42, val42);
    
    bpm(1:nbpms) = bpmstruct;
    
    jdata = zeros( nbpms, c.NSIGNALS, c.NPOINTS ); % Jitter data
    
    bpmparms.uscl  = zeros( nbpms, 1 ); % X scale, X phase, X result (1 if calculation completed)
    bpmparms.uphas = bpmparms.uscl; 
    bpmparms.ur    = bpmparms.uscl; 
    bpmparms.vscl  = bpmparms.uscl;  % Y scale, Y phase, Y result (1 if calculation completed) 
    bpmparms.vphas = bpmparms.uscl; 
    bpmparms.vr    = bpmparms.uscl; 
    bpmparms.err   = bpmparms.uscl;  % Error bit masks
    bpmparms.uv    = bpmparms.uscl;  bpmparms.vu  = bpmparms.uscl; % Ratios of scale factors
    bpmparms.phi   = bpmparms.uscl;  bpmparms.psi = bpmparms.uscl;
    
    if ( ~bpmsim )
        lcaPut( bpmpvs.err,  zeros(nbpms,1) ); % Clear all errors
        lcaPut( bpmpvs.prog, zeros(nbpms,1) ); % Clear progress status
    end
    
    % BPM parameters
    bpmparms.sel     = lcaGet(bpmpvs.sel, 1, 'float');  % BPMs selected
    bpmparms.gain    = lcaGet(bpmpvs.gain);     % BPM gain settings
    bpmparms.uscl_i  = lcaGet(bpmpvs.uscl);     % Current X scaling factor
    bpmparms.vscl_i  = lcaGet(bpmpvs.vscl);     % Current Y scaling factor
    bpmparms.uphas_i = lcaGet(bpmpvs.uphas);    % Current X detector phase
    bpmparms.vphas_i = lcaGet(bpmpvs.vphas);    % Current Y detector phase
    bpmparms.phi_i   = lcaGet(bpmpvs.phi);      % Current coupling angles:
    bpmparms.psi_i   = lcaGet(bpmpvs.psi);      % phi is rotation; psi is angle between axes
    bpmparms.acc     = lcaGet(bpmpvs.acc, 0, 'float');  % BPMs online, maintenance, etc.
    
    % Initialize calculated values to initial values
    bpmparms.uscl  = bpmparms.uscl_i;
    bpmparms.vscl  = bpmparms.vscl_i;
    bpmparms.uphas = bpmparms.uphas_i;
    bpmparms.vphas = bpmparms.vphas_i;
    bpmparms.phi   = bpmparms.phi_i;
    bpmparms.psi   = bpmparms.psi_i;
    
    % Abort if no BPMs online
    if ( all( bpmparms.acc ) )
        s = c.RVAL_ERR;
        msg = 'No BPMs online. Quitting';
        bpmsigpvs = []; % Define to prevent unassigned outputs error
        if ( ~bpmsim )
            lcaPut( scanpvs.msg, msg );
            lcaPut( scanpvs.cal, 0 );
        else
            disp( msg );
        end
        return;
    end
    
    for j = 1:nbpms
        if ( bpmparms.acc(j) )
            bpmparms.err(j) = bitor( bpmparms.err(j), c.ERR_OFFLINE);
        end
    end   
        
    % BPM data PVs for data acquisition
    bpmsigpvs.all  = [bpmpvs.urer;bpmpvs.uimr;bpmpvs.vrer;bpmpvs.vimr;bpmpvs.x;bpmpvs.y];
    
    % Only monitor BPMs that are online but 'get' all PVs so that we don't
    % have to worry about modifying our indexing
    monsel = not( bpmparms.acc );
    bpmsigpvs.mon = [bpmpvs.urer(monsel);bpmpvs.uimr(monsel);bpmpvs.vrer(monsel);bpmpvs.vimr(monsel);bpmpvs.x(monsel);bpmpvs.y(monsel)];
    lcaSetMonitor( bpmsigpvs.mon );
    
    % Abort if no BPMs chosen
    if ( (max( bpmparms.sel ) == 0) );
        s = c.RVAL_ERR;
        msg = 'No BPMs selected. Quitting';
        if ( ~bpmsim ) 
            lcaPut( scanpvs.msg, msg );
            lcaPut( scanpvs.cal, 0 );
        else
            disp( msg );
        end
        return;
    end
    
    msg = 'Fetching data from model';
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
       disp ( msg ); 
    end
    
catch ME
    msg = 'Error during init';
    if ( ~bpmsim )
        lcaPut( scanpvs.msg, msg );
    else
        disp( msg )
    end
    s = c.RVAL_FAIL; % Error
end
end