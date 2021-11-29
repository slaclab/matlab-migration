function[rval] = tcav0ModeTriggerControl(mode)

% Add/remove 'NO TCAV' global rule to/from TCAV modulator trigger rules
% 
%   Argument:   mode: 
%                   0 = Bunch Length Measurement Standby
%                   1 = Bunch Length Measurement Accelerate
%                   2 = Dark Current Suppression Standby
%                   3 = Dark Current Suppression Accelerate
%
%   Return:     0 for success, -1 for error

BLM_STANDBY    = 0;
BLM_ACCELERATE = 1;
DCS_STANDBY    = 2;
DCS_ACCELERATE = 3;

MOD_RULE_ADD = 1;
MOD_RULE_REM = 2;

TCAVMODTRIG = 'TRIG:LI20:302'; % TCAV modulator trigger
RULE_MIN = 0;  % Lowest  local trigger rule number
RULE_MAX = 7;  % Highest local trigger rule number

padpacmode_pv = 'TCAV:IN20:490:TC0_TRIGSEL';

desrate_pv = 'IOC:IN20:EV01:RG01_DESRATE';
FULL_RATE = 6;

tcav0_bit_byp_pv = 'IOC:IN20:EV01:RG01_I5_BYPS';
TCAV0_BIT_NOT_BYP = 0;
TCAV0_BIT_BYP_ASSRT = 2;

modtctl_pv = 'KLYS:LI20:51:BEAMCODE1_TCTL';
pactctl_pv = 'TCAV:IN20:490:TC0_C_1_TCTL';

rval = 0; % Initialize to success

% Dark Current Supression modes
if ( (mode == DCS_STANDBY) || (mode == DCS_ACCELERATE) )
    
    try
        lcaPut( padpacmode_pv, mode );
        lcaPut( desrate_pv, FULL_RATE );
        lcaPut( tcav0_bit_byp_pv, TCAV0_BIT_NOT_BYP );
        
        % In Standby mode, deactivate Accl PAC and modulator triggers    
        if ( mode == DCS_STANDBY )
            lcaPut( modtctl_pv, 0 );
            lcaPut( pactctl_pv, 0 );
        end
    catch ME
        rval = logMsg('tcavTriggerControl.m: lcaPut/Get error while removing rule or setting EVG params');
        return;
    end
        
    % Clear any NO TCAV rules for the modulator trigger
    if ( tcavModTriggerRule( MOD_RULE_REM ) )
        logMsg('tcavTriggerControl.m: tcavModTriggerRule failed to remove TCAV0 mod trigger rule');
    end

    
% Bunch Length Measurement modes
elseif ( (mode == BLM_STANDBY) || (mode == BLM_ACCELERATE) )
    
    try
        lcaPut( padpacmode_pv, mode );

    catch ME
        rval = logMsg('tcavTriggerControl.m: lcaPut/Get error while removing rule');
        return;
    end
    
    try
        if ( mode == BLM_ACCELERATE )
            bitval = TCAV0_BIT_BYP_ASSRT;
        else
            bitval = TCAV0_BIT_NOT_BYP;
        end
        lcaPut( tcav0_bit_byp_pv, bitval );
    catch ME
        rval = logMsg('tcavTriggerControl.m: lcaPut error while setting EVG TCAV0 bit');
        return;
    end
    
    % Add a NO TCAV for the modulator trigger
    if ( tcavModTriggerRule( MOD_RULE_ADD ) )
        logMsg('tcavTriggerControl.m: tcavModTriggerRule failed to add TCAV0 mod trigger rule');
    end
    
else
    rval = logMsg(sprintf('tcavModTrigger.m: Illegal mode argument %i',mode));
    return;
end

quit;

end

function[rval] = logMsg(message)
rval = -1;
facility = 'MATLAB';
myErrInstance = getLogger(facility);
put2log(message);
end
