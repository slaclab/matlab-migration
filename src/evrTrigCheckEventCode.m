function[rval] = evrTrigCheckEventCode(evr,trig,eventcode,unique)

% For a given EVR trigger and event code, check if that trigger is enabled
% on that event code.

%   Arguments:  evr  - EVR string name, e.g. 'EVR:IN20:RF04'
%               trig - Numerical trigger number, between 0 and 13
%               eventcode - Numerical event code that trigger should be active on
%               unique - Flag to indicate if other event codes are also
%                        allowed to be enabled, 1 if no other event codes
%                        allowed, 0 if other event codes allowed
%
%   Return:     
%               2 for failure: trigger IS enabled but so is another event
%                              event code (unique flag must be set to
%                              return this error)
%               1 for failure (trigger IS NOT enabled on event code)
%               0 for success (trigger IS enabled on event code)
%              -1 for error, i.e. lca error or illegal argument
%

rval = 0; % Initialize to success

TRIG_MIN = 0;    % Lowest  trigger number
TRIG_MAX = 13;   % Highest trigger number

if ( (trig < TRIG_MIN) || (trig > TRIG_MAX) )
    rval = logMsg(sprintf('evrTrigCheckEventCode.m: Illegal trig number %i, must be 0-13',trig));
    return;
end

if ( (unique < 0) || (unique > 1) )
    rval = logMsg(sprintf('evrTrigCheckEventCode.m: Illegal unique flag %i, must be 0 or 1',unique));
    return;
end
    
EC_MIN = 1;      % Lowest  event code instance
EC_MAX = 14;     % Highest event code instance

RULE_MAX = 10;     % Highest global rule ID
SYS      = 'SYS0'; % Global rules PV names location

% NO TCAV rule definitions
TCAVTYPE  = 2;
TCAVBC    = 1;
TCAVEXCL1 = hex2dec('80000000'); % Modifier 3 exclusion mask to match.
% All other masks should be zero.

for i = EC_MIN:EC_MAX
        
    i_s = num2str( i ) ;
    
    ec_pv   = [evr ':EVENT' i_s 'CTRL.ENM'];
    enab_pv = [evr ':EVENT' i_s 'CTRL.OUT' dec2hex( trig )];
    
    try
        ec   = lcaGet( ec_pv,   0, 'float' );
        enab = lcaGet( enab_pv, 0, 'float' );
    catch ME
        rval = logMsg(sprintf('evrTrigCheckEventCode.m: lcaGet error for %s or %s ',ec_pv, enab_pv));
        return;
    end
    
    if ( ec == eventcode )
        
        if ( enab == 0 )
%            fprintf('evrTrigCheckEventCode.m: ERROR: EVR %s trig %i not enabled on event code %i\n',evr, trig, eventcode);
            rval = 1;
            return; % Return here or no?
        end
        
    elseif ( unique == 1 )
        
        if ( enab ~= 0 )
%           fprintf('evrTrigCheckEventCode.m: ERROR: EVR %s trig %i is enabled on other event code %i\n',evr, trig, ec);
            rval = 2;
            return; % Return here or no?
        end
    end
end
end

function[rval] = logMsg(message)
rval = -1;
facility = 'MATLAB';
myErrInstance = getLogger(facility);
put2log(message);
end