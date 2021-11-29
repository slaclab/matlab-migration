function[] = tcav0ModeStatus

% Check that TCAV0 trigger setup matches desired TCAV0 mode

LOOP_PERIOD = 2; % seconds

BLMSTBY = 1; % Bunch Length Measurement Standby
BLMACCL = 2; % Bunch Length Measurement Accelerate
DCSSTBY = 3; % Dark Current Suppression Standby
DCSACCL = 4; % Dark Current Suppression Accelerate

mode{BLMSTBY} = 'BunchLength Stby';
mode{BLMACCL} = 'BunchLength Accl';
mode{DCSSTBY} = 'DarkCurrSuppress Stby';
mode{DCSACCL} = 'DarkCurrSuppress Accl';

tcav_device = 'TCAV:IN20:490';

N_MODES = 4;

PADFBCK = 1;
PADDIAG = 2;
PACACCL = 3;
PACSTBY = 4;

N_DEVS = 4; % Number of LLRF devices/triggers (PAD/PAD) in system

dev     = cell(  N_DEVS, 1 );           % LLRF device strings
evr     = cell(  N_DEVS, 1 );           % LLRF EVR name strings
trig    = zeros( N_DEVS, 1 );           % LLRF trigger numbers
ec_mode = zeros( N_DEVS, N_MODES );     % LLRF mode-specific event codes
tdes_pv = cell(  N_DEVS, 1 );           % LLRF TDES PVs
tdes_mode_pv = cell( N_DEVS, N_MODES ); % LLRF mode-specific TDES PVs

% Feedback PAD aka L0Tcav PAD (20-5)
dev{PADFBCK}  = 'Fbck PAD';
evr{PADFBCK}  = 'EVR:IN20:RF02';
trig(PADFBCK) = 1;
ec_mode(PADFBCK,BLMSTBY) = 153;
ec_mode(PADFBCK,BLMACCL) = 149;
ec_mode(PADFBCK,DCSSTBY) = 152;
ec_mode(PADFBCK,DCSACCL) = 151;
tdes_mode_pv{PADFBCK,BLMSTBY} = [tcav_device ':FBPAD_BLMSTBY'];
tdes_mode_pv{PADFBCK,BLMACCL} = [tcav_device ':FBPAD_BLMACCL'];
tdes_mode_pv{PADFBCK,DCSSTBY} = [tcav_device ':FBPAD_DCSSTBY'];
tdes_mode_pv{PADFBCK,DCSACCL} = [tcav_device ':FBPAD_DCSACCL'];
tdes_pv{PADFBCK} = [tcav_device ':TC0_D_TDES'];

% Diagnostic PAD aka 20-5 PAD (ext)
dev{PADDIAG}  = 'Diag PAD';
evr{PADDIAG} = 'EVR:IN20:RF05';
trig(PADDIAG) = 1;
ec_mode(PADDIAG,BLMSTBY) = 153;
ec_mode(PADDIAG,BLMACCL) = 149;
ec_mode(PADDIAG,DCSSTBY) = 152;
ec_mode(PADDIAG,DCSACCL) = 151;
tdes_mode_pv{PADDIAG,BLMSTBY} = [tcav_device ':DIAGPAD_BLMSTBY'];
tdes_mode_pv{PADDIAG,BLMACCL} = [tcav_device ':DIAGPAD_BLMACCL'];
tdes_mode_pv{PADDIAG,DCSSTBY} = [tcav_device ':DIAGPAD_DCSSTBY'];
tdes_mode_pv{PADDIAG,DCSACCL} = [tcav_device ':DIAGPAD_DCSACCL'];
tdes_pv{PADDIAG} = 'TRIG:IN20:DGN_SPARE5:TDES';

% PAC accelerate trigger aka L0TcavPAC(20-5)Acc
dev{PACACCL}  = 'PAC Acc';
evr{PACACCL}  = 'EVR:IN20:RF03';
trig(PACACCL) = 0;
ec_mode(PACACCL,BLMSTBY) = 149;
ec_mode(PACACCL,BLMACCL) = 149;
ec_mode(PACACCL,DCSSTBY) = 151;
ec_mode(PACACCL,DCSACCL) = 151;
tdes_mode_pv{PACACCL,BLMSTBY} = [tcav_device ':ACCLPAC_BLMSTBY'];
tdes_mode_pv{PACACCL,BLMACCL} = [tcav_device ':ACCLPAC_BLMACCL'];
tdes_mode_pv{PACACCL,DCSSTBY} = [tcav_device ':ACCLPAC_DCSSTBY'];
tdes_mode_pv{PACACCL,DCSACCL} = [tcav_device ':ACCLPAC_DCSACCL'];
tdes_pv{PACACCL} = [tcav_device ':TC0_C_1_TDES'];

% PAC standby trigger aka L0TcavPAC(20-5)SB
dev{PACSTBY}  = 'PAC Stby';
evr{PACSTBY}  = 'EVR:IN20:RF03';
trig(PACSTBY) = 1;
ec_mode(PACSTBY,BLMSTBY) = 153;
ec_mode(PACSTBY,BLMACCL) = 153;
ec_mode(PACSTBY,DCSSTBY) = 152;
ec_mode(PACSTBY,DCSACCL) = 152;
tdes_mode_pv{PACSTBY,BLMSTBY} = [tcav_device ':STBYPAC_BLMSTBY'];
tdes_mode_pv{PACSTBY,BLMACCL} = [tcav_device ':STBYPAC_BLMACCL'];
tdes_mode_pv{PACSTBY,DCSSTBY} = [tcav_device ':STBYPAC_DCSSTBY'];
tdes_mode_pv{PACSTBY,DCSACCL} = [tcav_device ':STBYPAC_DCSACCL'];
tdes_pv{PACSTBY} = [tcav_device ':TC0_C_2_TDES'];

% PAC PDES and waveform PVs, independent of standby/accelerate triggers
pac_pdes_pv = [tcav_device ':TC0_PDES'];
pac_pdes_mode_pv{BLMSTBY} = [tcav_device ':PACPDES_STBY']; 
pac_pdes_mode_pv{BLMACCL} = [tcav_device ':PACPDES_STBY']; 
pac_pdes_mode_pv{DCSSTBY} = [tcav_device ':PACPDES_ACCL']; 
pac_pdes_mode_pv{DCSACCL} = [tcav_device ':PACPDES_ACCL']; 
pac_wf_pv = [tcav_device ':TC0_WF'];
pac_wf_mode_pv{BLMSTBY} = [tcav_device ':PACWF_STBY']; 
pac_wf_mode_pv{BLMACCL} = [tcav_device ':PACWF_STBY']; 
pac_wf_mode_pv{DCSSTBY} = [tcav_device ':PACWF_ACCL']; 
pac_wf_mode_pv{DCSACCL} = [tcav_device ':PACWF_ACCL']; 

% Used in building PAC waveform PV names. 
% Note that we assume that the mbbi bit value maches its name: e.g. ZRVL has a value of 0
MBBI_STR = { 'ZR' , 'ON' , 'TW' , 'TH' , 'FR' , 'FV' , 'SX' , 'SV' ,  ...
             'EI' ,'NI' , 'TN' , 'EL' , 'TV' , 'TT' , 'FT' , 'FF' };

tcav_mode_ctrl_pv = [tcav_device ':TC0_TRIGSEL'];

UNIQUE_FLAG = 1; % Only one event code allowed to be enabled for each LLRF trigger

% Accl PAC and modulator trigger activation status
modtstat_pv = 'KLYS:LI20:51:BEAMCODE1_TSTAT';
pactstat_pv = 'TCAV:IN20:490:TC0_C_1_TCTL';

% Modulator trigger, per mode flag if 'NO TCAV' rule should be present or not; 
% 1 = should be present; 0 = should not be present
modtrigruleset_mode = zeros( N_MODES );     
modtrigruleset_mode(BLMSTBY) = 1;
modtrigruleset_mode(BLMACCL) = 1;
modtrigruleset_mode(DCSSTBY) = 0;
modtrigruleset_mode(DCSACCL) = 0;

desrate_pv = 'IOC:IN20:EV01:RG01_DESRATE';
tcav0_bit_bypass_pv = 'IOC:IN20:EV01:RG01_I5_BYPS';
TCAV0_BIT_NOT_BYP = 0;
TCAV0_BIT_BYP_ASSRT = 2;

tcav0_event_rate_pv = 'EVNT:SYS0:1:LCLSTCAVRATE';

statmsg_pv = 'TCAV:IN20:490:MODESTATMSG';
stat_pv    = 'TCAV:IN20:490:MODESTAT';
date_pv    = 'TCAV:IN20:490:MODESTATTS';

STAT_OK      = 0;
STAT_WARNING = 1;
STAT_ALARM   = 2;

% For matlab watcher
counter_pv = 'SIOC:SYS0:ML00:AO991';
c = 0;
lcaPut( counter_pv, c );
COUNTER_MAX = 1e10;

firsttime = 1;

while (1)
    
    if ( firsttime )
        firsttime = 0;
    else  
        pause(LOOP_PERIOD);
        if ( c > COUNTER_MAX )
            c = 0;
        else
            c = c + 1;
        end
        try
            lcaPut( counter_pv, c );
        catch ME
            fprintf('tcav0ModeStatus.m: error duing lcaPut of %s\n', counter_pv);
        end            
    end
    
    stat = STAT_OK; % Initialize to OK
    
    try
        % LLRF PV mode starts at 0 but matlab does not allow index of 0
        % so add 1 in order to use our indexing
        mode_ctrl = 1+lcaGet( tcav_mode_ctrl_pv, 0, 'float' );
        
        % Initialize alarm/message to OK. If we detect fault later,
        % overwrite these
        stat = STAT_OK;
        msg = sprintf('In %s mode', mode{mode_ctrl});
    catch ME
        msg = ['tcav0ModeStatus.m: error duing lcaGet of ' tcav_mode_ctrl_pv];
        stat = STAT_ALARM;
    end
    
    % If no errors yet, check mode value
    if ( stat == STAT_OK )
        if ( (mode_ctrl < 1) || (mode_ctrl > N_MODES ) )
            msg = sprintf('tcav0ModeStatus.m: Read illegal mode %i from %s', mode_ctrl, tcav_mode_ctrl_pv);
            stat = STAT_ALARM;
        end
    end
    
    % If no errors yet, check LLRF trigger setup and PAC PDES and waveform
    if ( stat == STAT_OK )
        
        for i=1:N_DEVS
            
            % Check trigger event code
            llrfrval = evrTrigCheckEventCode( evr{i}, trig(i), ec_mode(i,mode_ctrl), UNIQUE_FLAG );
            
            if ( llrfrval < 0 )
                fprintf('Error: %i returned from evrTrigCheckEventCode.\n', llrfrval);
                fprintf('                   mode %i EVR %s trig %i mode %i', mode_ctrl, evr{i}, trig(i), ec_mode(i,mode_ctrl));
                msg = 'evrTrigCheckEventCode error; unable to verify mode state';
                stat = STAT_ALARM;
                break;
            elseif ( llrfrval == 1 )
                msg = sprintf('Error: In %s mode but %s not enabled on event code %i', mode{mode_ctrl}, dev{i}, ec_mode(i,mode_ctrl));
                stat = STAT_ALARM;
                break;
            elseif ( llrfrval == 2 )
                msg = sprintf('Error: In %s mode but %s is enabled on event code other than %i', mode{mode_ctrl}, dev{i}, ec_mode(i,mode_ctrl));
                stat = STAT_ALARM;
                break;
            end
            
            % Check trigger TDES
            try
                tdes_mode = lcaGet( tdes_mode_pv{i,mode_ctrl}, 0, 'float' );
                tdes      = lcaGet( tdes_pv{i}, 0, 'float' );
            catch ME
                msg = ['Error during lcaGet of ' tdes_mode_pv{i,mode_ctrl} ' or ' tdes_pv{i} '; unable to verify mode TDES'];
                stat = STAT_ALARM;
                break;
            end
            
            if ( tdes ~= tdes_mode )
                msg = sprintf('Error: In %s mode but %s current TDES %.0f does not match its mode TDES %.0f', mode {mode_ctrl}, dev{i}, tdes, tdes_mode);
                stat = STAT_ALARM;
                break;
            end
            
            % Check PAC PDES
            try
                pac_pdes_mode = lcaGet( pac_pdes_mode_pv{mode_ctrl} );
                pac_pdes      = lcaGet( pac_pdes_pv, 0, 'double' );
            catch ME
                msg = ['Error during lcaGet of ' pac_pdes_mode_pv{mode_ctrl} ' or ' pac_pdes_pv '; unable to verify PAC PDES'];
                stat = STAT_ALARM;
                break;
            end
            
            if ( pac_pdes ~= pac_pdes_mode )
                msg = sprintf('Error: In %s mode; PAC PDES is %.0f but should be %.0f', mode {mode_ctrl}, pac_pdes, pac_pdes_mode);
                stat = STAT_ALARM;
                break;
            end
            
            % Check PAC waveform
            try
                pac_wf_mode = lcaGet( pac_wf_mode_pv{mode_ctrl} );
                pac_wf_mode_str = char(lcaGet( [pac_wf_pv '.' MBBI_STR{pac_wf_mode+1} 'ST'] )); % Add 1 because PV indexing starts at 0; matlab at 1
                pac_wf_str  = char(lcaGet( pac_wf_pv ));
            catch ME
                msg = ['Error during lcaGet of ' pac_wf_mode_pv{mode_ctrl} ' or ' pac_wf_pv '; unable to verify PAC waveform'];
                stat = STAT_ALARM;
                break;
            end
            
            if ( ~strcmp( pac_wf_str, pac_wf_mode_str ) )
                msg = sprintf('Error: In %s mode; PAC waveform is %s but should be %s', mode{mode_ctrl}, pac_wf_str, pac_wf_mode_str);
                stat = STAT_ALARM;
                break;
            end
            
        end
    end
    
    % If no errors yet, check modulator trigger rule, EVG rate setup,
    % PAC/modulator trigger enable status
    if ( stat == STAT_OK )
        
        [modrval,set] = tcavModTriggerRule( 3 );
        
        try
            tcav0_bit_bypass = lcaGet( tcav0_bit_bypass_pv, 0, 'float' );
            tcav0_event_rate = lcaGet( tcav0_event_rate_pv, 0, 'float' );
        catch ME
            msg = 'evrTrigCheckEventCode error; unable to read EVG PV(s)';
        end
        
        if ( modrval < 0 ) 
            fprintf('Error: %i returned from tcavModTriggerRule.\n', modrval);
            msg = 'evrTrigCheckEventCode error; unable to verify mode state';
            stat = STAT_ALARM;
        elseif ( set ~= modtrigruleset_mode(mode_ctrl) )
            if ( modtrigruleset_mode(mode_ctrl) == 0 )
                msg = sprintf('Error: In %s mode but TCAV0 mod trigger "NO TCAV" rule IS set', mode{mode_ctrl});
                stat = STAT_ALARM;
            else
                msg = sprintf('Error: In %s mode but TCAV0 mod trigger "NO TCAV" rule IS NOT set', mode{mode_ctrl});
                stat = STAT_ALARM;
            end
        elseif ( mode_ctrl == BLMACCL )
            if ( tcav0_bit_bypass ~= TCAV0_BIT_BYP_ASSRT )
                msg = sprintf('Warning: In %s mode but EVG TCAV0 bit bypass state is not BYPASSED_ASSRT', mode{mode_ctrl});
                stat = STAT_WARNING;
            elseif ( tcav0_event_rate == 0 )
                msg = sprintf('Warning: In %s mode but TCAV0 event rate is  0 ', mode{mode_ctrl});
                stat = STAT_WARNING;
            end
        elseif ( mode_ctrl == BLMSTBY )
            if ( tcav0_bit_bypass ~= TCAV0_BIT_NOT_BYP )
                msg = sprintf('Warning: In %s mode but EVG TCAV0 bit bypass state is not NOT_BYPASSED', mode{mode_ctrl});
                stat = STAT_WARNING;
            elseif ( tcav0_event_rate > 0 )
                msg = sprintf('Warning: In %s mode but TCAV0 event rate is greater than 0 ', mode{mode_ctrl});
                stat = STAT_WARNING;
            end
        elseif ( (mode_ctrl == DCSSTBY) || (mode_ctrl == DCSACCL) )
            try
                desrate = lcaGet( desrate_pv, 0, 'float' );
                modtstat = lcaGet( modtstat_pv, 0, 'float' );
                pactstat = lcaGet( pactstat_pv, 0, 'float' );     
            catch ME
                msg = 'evrTrigCheckEventCode error; unable to read EVG PV(s)';
            end
            if ( tcav0_bit_bypass ~= TCAV0_BIT_NOT_BYP )
                msg = sprintf('Warning: In %s mode but EVG TCAV0 bit bypass state is not NOT_BYPASSED', mode{mode_ctrl});
                stat = STAT_WARNING;
            elseif ( tcav0_event_rate > 0 )
                msg = sprintf('Warning: In %s mode but TCAV0 event rate is greater than 0 ', mode{mode_ctrl});
                stat = STAT_WARNING;
            end
            if ( desrate ~= 6 )
                msg = sprintf('Warning: In %s mode but EVG Beam Rate Control is not at full rate', mode{mode_ctrl});
                stat = STAT_WARNING;
            elseif ( mode_ctrl == DCSSTBY )
                if ( modtstat ~= 0 )
                    msg = sprintf('Warning: In %s mode but TCAV0 mod trigger is active on BC 1', mode{mode_ctrl});
                    stat = STAT_WARNING;
                elseif ( pactstat ~= 0 )
                    msg = sprintf('Warning: In %s mode but TCAV0 Accl PAC trigger is enabled', mode{mode_ctrl});
                    stat = STAT_WARNING;
                end
            end
        end
    end
    date = datestr(now,0);
    try
        lcaPut( statmsg_pv, double(int8(msg))  );
        lcaPut( stat_pv,    stat );
        lcaPut( date_pv,    double(int8(date)) );
    catch ME
        fprintf('tcav0ModeStatus.m: error duing lcaPut of %s or %s\n', statmsg_pv, stat_pv);
    end
    
end

end

