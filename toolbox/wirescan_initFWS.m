function wirescan_initFWS( wireScanner_dn )
% INITFWS checks the status of a fast wire scanner prior to scan, and if
% necessary reinitializes it. 
%
% Argument: WIRESCANNER_DN is the device name of a fast wire scanner, eg WIRE:LTU1:715
% The wire scanner must match the API defined in wsAPI.xsls
%
% INITFWS checks both the present state of the wire scanner - as indicated by a 
% number of "disposition" PVs. Eg whether it is enabled, homed, not in motion,
% and not in error. It also checks the EPICS PV severity of those PVs and of
% the position PVs. If any are at unexpeced value, it tries a MOTR_INIT to 
% reinitialize.
%
% A number of attempts are made to reinitialize. If none are succussful, INITFWS
% issues messages to the log, and throws WS:UNABLETOINITIALIZE.
% 
% Returns; no return arguments.
% Throws: WS:UNABLETOINITIALIZE if unable to check status of wire (eg PVs offline),
% or successive reinits fail to result in disposition PVs values which are good 
% for a scan.
%
% -----------------------------------------------------------------------------
% Auth: Greg White, 21-Mar-2018
% Mod: 
% =============================================================================

wirescan_const;       % Error messages and constants.
POLL_PAUSEPERIOD=1.0; % Wait 1 sec between rechecks for motor status. Expected period is 3 secs      
POLL_N=10;            % check PV vals 10 times before giving up check on whether motor_init was successful
NINITTRIES=3;         % Try to rinint motor 3 times before giving up and reporting failure

% Disposition PVs - WS Attributes that describe the scanner's present operational state, and whether
% it is ok to proceed with initialization a scan.  
% Mod: 15-Mar-18, Greg, per Namrata, see her email 14-Mar. 
% Removed ':MOTR_MOTION_ACT_STS',,':MOTR_ERROR_STS'}' until IOC is fixed;
DISPOSITION_PVAS={':MOTR_ENABLED_STS', ...
                    ':MOTR_HOMED_STS'}'; 
ENABLED_OFF=0; % Not enabled
ENABLED_ON=1;  % Is enabled
MOTION_STILL=0;
MOTION_INMOTION=1;
HOMED_OFF=0;
HOMED_HOMED=1;
ERROR_OK=0;
ERROR_ERROR=1;
DISPOSITION_PVMAXSEVERITIES=[NO_ALARM, NO_ALARM ]; % re-add NO_ALARMs when IOC db fixed
DISPOSITION_PVMINVALS=[ENABLED_ON, HOMED_HOMED];   % re-add MOTION_STILL and ERROR_OK when IOC fixed

% Position PVs - Describe the wire scanner position - the distance from the home position to the
% harp 
POSN_PVAS={':MOTR', ... % Impertive position pv
           ':POSN'};   % Readback position pv
POSN_PVMAXSEVERITIES=[MINOR_ALARM, NO_ALARM];  % Worse severity than this is bad


BADPOSN_SEVR=['Preflight check of wire %s found that one of the ' ...
              'position PVs of the wire is in bad severity status. Check control ' ...
              'screens.'];
BADSEVRWARN=['Preflight checks of wire %s found that one or more ' ...
              'PVs used for motor status check are in bad EPICS alarm ' ...
              'severity. Check control screens for wire motor Enabled, '...
              'Motion is Activated, homeed, and no error. '];

isGoodSevr=false; % Whether the Motor control PV SEVRities are good. 
isGoodDisp=false; % Whether the Motor control status PVs say motor is in good operational disposition.

% Construct PV names
%
% wireScanner_dn=handles.scanWireName;
reinit_pvn=strcat(wireScanner_dn,':MOTR_INIT');
posn_pvns=strcat(wireScanner_dn,POSN_PVAS)';              % Construct impertative and readback PV names of motor position
disposition_pvns=strcat(wireScanner_dn,DISPOSITION_PVAS); % PV names giving present operational state of wire motor
severity_pvns=[posn_pvns; disposition_pvns];              % FQNs of PV names of severities of PVs above 
% Max severities required; .SEVR values above which trigger a re-init attempt.
maxOkSeverity=[ POSN_PVMAXSEVERITIES DISPOSITION_PVMAXSEVERITIES ]; 

% Query dispostion and position Pvs, plus their EPICS severities (SEVR), in try/catch in case of 
% network error. 
try
    % Check present status of the wire scanner's motor controls to see if
    % motor should be reinitialized (which takes a bit of time). 
    %
    [isGoodSevr, ~]=pollPVSeverity(severity_pvns, maxOkSeverity, 1, 0 );  % One iteration for initial check
    [isGoodDisp, ~]=pollPV(disposition_pvns, DISPOSITION_PVMINVALS, 1, 0 ); 

    % If above checks indicate bad PV status or motor disposition, do a
    % reinit and check again. Loop the init and check up to NINITTRIES times.
    %
    iInitTries=0;
    while ~(isGoodDisp && isGoodSevr) && iInitTries < NINITTRIES
        iInitTries=iInitTries+1;    
        lprintf(STDERR, ['Wire scanner %s found disabled or in a state inconsistent with scanning. ' ... 
            'Attempting motor control reinititialization. Try #%d.'], wireScanner_dn, iInitTries);
        lcaPut( reinit_pvn, WIREMOTORINIT, 'short'); 
        [isGoodDisp, badDispes, dispPVvals]=pollPV(disposition_pvns, DISPOSITION_PVMINVALS, POLL_N, POLL_PAUSEPERIOD );
        [isGoodSevr, badSevris]=pollPVSeverity(severity_pvns, maxOkSeverity, 1, 0 );  % One iteration
        if isGoodDisp && isGoodSevr
            lprintf(STDERR, 'Motor control reinitialization successful.');
        end
    end
    
    % If either a disposition PV is still bad, or a severity is still
    % bad, construct a comma delimted string saying so.
    %
    if ~isGoodDisp
        ibad=1;
        ebad=badDispes(ibad);
        badDispPVsmsg_s=sprintf(['One or more wire control PVs indicating process disposition are at ' ...
                            'value inconsistent with successful wire scans: %s is %d, but should be %d'], ...
                                char(disposition_pvns(ebad)), dispPVvals(ebad),...
                                DISPOSITION_PVMINVALS(ebad));
        % Append any other PV names whose value was also found to be inconsistent with good scan 
        while ibad<length(badDispes)
            ibad=ibad+1;
            badDispPVsmsg_s=sprintf('%s, %s is %d but should be %d',badDispPVsmsg_s,...
                                char(disposition_pvns(badDispes(ibad))),dispPVvals(badDispes(ibad)),... 
                                DISPOSITION_PVMINVALS(badDispes(ibad)));
        end
        error(lprintf(STDERR, badDispPVsmsg_s));  % Issue the error message to log, and throw
                                                  % exception to abort.
    end
    if ~isGoodSevr
        ibad=1;
        badSevrPVsmsg_s=sprintf('One or more wire control PV severities are above threshold: %s is SEVR %d',...
                                char(severity_pvns(badSevris(ibad))), badSevris(ibad));
        % Append any other PV names also in bad severity
        while ibad<length(badSevris)
            ibad=ibad+1;
            badSevrPVsmsg_s=sprintf('%s, %s is at SEVR %d',badSevrPVsmsg_s,char(severity_pvns(badSevris(ibad))),...
                                    badSevris(ibad));
        end
        lprintf(STDERR, badSevrPVsmsg_s);  % Issue the error message to log, but don't throw exception
    end

catch ex
    % Throw exception for either case of 
    error('WS:UNABLETOINITIALIZE', ...
          lprintf(STDERR, 'Unable to initialize wire %s for scan. %s', wireScanner_dn, ex.message));
end

