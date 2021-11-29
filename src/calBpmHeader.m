function[c,scanpvs] = calBpmHeader(cal_prefix)

    % Define some static constants
    
    c.NSAMPLES = 50; % Number of data samples at each position
    c.NPULSESABORT = 1000; % Number of errors before prompted for optional exit
    
    c.NRETRIES = 3; % Number of times to try to get good data for each BPM
    
    % BPM categories 
    % Would like to deprecate but still used in predicted data BPM list
    c.BPM_GRDR = 0;        % Normal undulator girder BPM 
    c.BPM_UPSTRM = 1;       % BPM upstream of undulators (no mover)
    c.BPM_DWNSTRM = 2;      % BPM downstream of undulators (no mover)
    
    % Indices into data arrays
    c.URER = 1;
    c.UIMR = 2;
    c.VRER = 3;
    c.VIMR = 4;
    c.X    = 5;
    c.Y    = 6;
    c.NSIGNALS = c.Y;
    
    % Coordinate planes to scan
    c.XPLANE = 1;
    c.YPLANE = 2;
    
    c.PROG_NOTSCAN  = 0; % Default value, assume not all BPMs will be scanned
    c.PROG_SCAN     = 1;
    c.PROG_SCANDONE = 2;
    
    % Error codes
    c.ERR_SKIP    = bitshift(1,0); % Skipped BPM
    c.ERR_BADFIT  = bitor( c.ERR_SKIP, bitshift(1,1) ); % Failed to get good data/fit
    c.ERR_OFFLINE = bitor( c.ERR_SKIP, bitshift(1,2) ); % BPM is not in 'Running' mode
    c.ERR_INSUFF  = bitor( c.ERR_SKIP, bitshift(1,3) ); % Insufficient neighboring BPMs
    c.ERR_GIRDER  = bitor( c.ERR_SKIP, bitshift(1,4) ); % Error during girder move
    c.ERR_CALCX   = bitor( c.ERR_SKIP, bitshift(1,5) ); % Error during X calculations
    c.ERR_CALCY   = bitor( c.ERR_SKIP, bitshift(1,6) ); % Error during Y calculations
    c.ERR_MODEL   = bitor( c.ERR_SKIP, bitshift(1,7) ); % Problem with model data
    c.ERR_CONFIG  = bitor( c.ERR_SKIP, bitshift(1,8) ); % Problem with model data
    
    c.ERR_WRITE   = bitshift(1,9); % Error implementing new parameters. 
                                   % Does not include bit 0 because not considered 'skipped'.

    % Return codes (used by calBpmWriteParms and others)
    c.RVAL_SUCC   =  0; % Success    
    c.RVAL_ERR    =  1; % Completed but with errors
    c.RVAL_FAIL   =  2; % Failed
    
    % Restore mask (used by calBpmRestore)
    c.RESTORE_PV   = bitshift(1,0);
    c.RESTORE_COR  = bitshift(1,1); % Not currently used
    c.RESTORE_GRDR = bitshift(1,2);
    c.RESTORE_FB   = bitshift(1,3);
    c.RESTORE_QUIT = bitshift(1,4); % Abort requested
    c.RESTORE_DONE = bitshift(1,5); % Program completed normally
    
    c.PLOT_OFF = 0;
    c.PLOT_SINGLE = 1; % One BPM's plots at a time (avoid system overload)
    c.PLOT_ALL = 2; % Plot all (expert option)
    
    % Number of BPMs to use in position prediction  
    c.NPREDBPMS = 10;   

    % Calibration methods
    c.CAL_GRDR = 1; % Girder position 
    c.CAL_PRED  = 2; % Neighboring BPMs
    c.CAL_COR   = 3; % Corrector range

    scanpvs.msg = [ cal_prefix ':CALMSG'];
    scanpvs.cal   = [ cal_prefix ':PRODCAL'];
    scanpvs.abort = [ cal_prefix ':CALABORT'];
    
    c.C = 33.35640952; % Cb, Magnetic rigidity, for calculating deflection
    
    c.fitrsq = 0.98; % Standard fit quality  threshold, see calBpm.m
    
end