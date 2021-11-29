function wirescan_termFWS( wireScanner_dn )
% WIRESCAN_TERMFWS terminates a Fast Wire Scan. That is, it executes the 
% control PV functions necessary to retract the Fast Wire, and verifies 
% successful completion. 
%
% Argument: WIRESCANNER_DN is the device name of a fast wire scanner, eg WIRE:LTU1:715
% The wire scanner must match the API defined in wsAPI.xsls
%
% A number of attempts are made to retract and verify. If none are succussful, TERMFWS
% issues messages to the log, and throws WS:UNABLETOTERMINATE.
% 
% Returns; no return arguments.
% Throws: WS:UNABLETOTERMINATE if unable to check status of wire (eg PVs offline),
% or successive retracts fail to result in disposition PVs values which are good 
% for a scan.
%
% -----------------------------------------------------------------------------
% Auth: Greg White, 29-Mar-2018
% Mod: 
% =============================================================================

wirescan_const;        % Error messages and constants.
POLL_PAUSEPERIOD=0.8; % Wait .6 sec between rechecks for motor status. Expected process period is .5 s      
POLL_N=5;              % check PV vals this many times on each check
NTRIES=5;              % Try to retract motor 3 times before giving up and reporting failure

% Disposition PVs - WS Attributes that describe the scanner's present 
% operational state, and as such the PVs used to verify successful
% termination.
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
% Expected disposition PV values on successful terminaton (ie good retract)  
DISPOSITION_PVMAXSEVERITIES=[MAJOR_ALARM, NO_ALARM ]; % re-add NO_ALARMs when IOC db fixed
DISPOSITION_PVMINVALS=[ENABLED_OFF, HOMED_HOMED];   % re-add MOTION_STILL and ERROR_OK when IOC fixed


% Position PVs - Describe the wire scanner position - the distance from the home position to the
% harp 
POSN_PVAS={':MOTR', ... % Impertive position pv
           ':POSN'};   % Readback position pv
POSN_PVMAXSEVERITIES=[MINOR_ALARM, NO_ALARM];  % Worse severity than this is bad


BADPOSN_SEVR=['Wire flight termination check of wire %s found that one of the ' ...
              'position PVs of the wire is in bad severity status. Check control ' ...
              'screens.'];
BADSEVRWARN=['Wire flight termination checks of wire %s found that one or more ' ...
              'PVs giving motor status check are in bad EPICS alarm ' ...
              'severity. Check control screens for wire motor NOT Enabled, '...
              'NOT Activated, IS homeed, and no error. '];

isGoodSevr=false; % Whether the Motor control PV SEVRities are good. 
isGoodDisp=false; % Whether the Motor control status PVs say motor is in good operational disposition.

% Construct PV names and value 
%
retract_pvn=strcat(wireScanner_dn,':MOTR_RETRACT');       % The termination imperative PV
WIREMOTORRETRACT=1; % Imperative value of retract PV to do retract
posn_pvns=strcat(wireScanner_dn,POSN_PVAS)';              % Construct impertative and readback PV names of motor position
disposition_pvns=strcat(wireScanner_dn,DISPOSITION_PVAS); % PV names giving present operational state of wire motor
severity_pvns=[posn_pvns; disposition_pvns];              % FQNs of PV names of severities of PVs above 
% Max severities required; .SEVR values above which trigger a re-init attempt.
maxOkSeverity=[ POSN_PVMAXSEVERITIES DISPOSITION_PVMAXSEVERITIES ]; 

% Query dispostion and position Pvs, plus their EPICS severities (SEVR), in try/catch in case of 
% network error. 
try

    % Execute motor retract, then check disposition and status severity, 
    % until disposition and their severity are good, up to ntries times.
    %
    iTermTries=0;
    while true 
        iTermTries=iTermTries+1;    
        lcaPut( retract_pvn, WIREMOTORRETRACT, 'short'); 
        [isGoodDisp, badDispis, dispPVvals]=pollPV(disposition_pvns, DISPOSITION_PVMINVALS, POLL_N, POLL_PAUSEPERIOD );
        [isGoodSevr, badSevris]=pollPVSeverity(severity_pvns, maxOkSeverity, 1, 0 );  % One iteration
        if isGoodDisp && isGoodSevr
            lprintf(STDERR, 'Motor control retract and termination successful.');
            break;
        else
            if iTermTries < NTRIES 
                lprintf(STDERR, ['Wire scanner %s not successfully retracted. ' ... 
                'Attempting retract and check again. Try #%d.'], wireScanner_dn, iTermTries);
            else
                break;
            end
        end
    end
    
    % If either a disposition PV is still bad, or a severity is still
    % bad, construct a comma delimted string saying so.
    %
    if ~isGoodDisp
        ebad=1;
        badDispPVsmsg_s=sprintf(['One or more wire control PVs indicating wire scan process disposition are at ' ...
                            'value inconsistent with successful wire scans termination: %s is %d, should be %d'], ...
                                char(disposition_pvns(badDispis(ebad))), dispPVvals(badDispis(ebad)), ...
                                DISPOSITION_PVMINVALS(badDispis(ebad)));
        % Append any other PV names whose value was also found to be inconsistent with good scan 
        while ebad<length(badDispis)
            ebad=ebad+1;
            badDispPVsmsg_s=sprintf('%s, %s is %d, should be %d',badDispPVsmsg_s,...
                char(disposition_pvns(badDispis(ebad))), dispPVvals(badDispis(ebad)), ...
                DISPOSITION_PVMINVALS(badDispis(ebad)));
        end
        error(lprintf(STDERR, badDispPVsmsg_s));  % Issue the error message to log, and throw
                                                  % exception to abort.
    end
    if ~isGoodSevr
        ebad=1;
        badSevrPVsmsg_s=sprintf('One or more wire control PV severities are above threshold: %s is SEVR %d',...
                                char(severity_pvns(badSevris(ebad))), badSevris(ebad));
        % Append any other PV names also in bad severity
        while ebad<length(badSevris)
            ebad=ebad+1;
            badSevrPVsmsg_s=sprintf('%s, %s is at SEVR %d', badSevrPVsmsg_s,...
                char(severity_pvns(badSevris(ebad))), badSevris(ebad));
        end
        lprintf(STDERR, badSevrPVsmsg_s);  % Issue the error message to log, but don't throw exception
    end

catch ex
    % Throw exception for either case of 
    error('WS:UNABLETOTERMINATE', ...
          lprintf(STDERR, 'Unable to retract and verifiably terminate wire %s scan. %s', ...
          wireScanner_dn, ex.message));
end

