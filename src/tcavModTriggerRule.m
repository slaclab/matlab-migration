function[rval,set] = tcavModTriggerRule(mode)

% Add/remove 'NO TCAV' global rule to/from TCAV modulator trigger rules
% 
%   Argument:   mode: 
%                       1 = add the rule 
%                       2 = remove the rule
%                       3 = check if rule is set
%
%   Return:     rval: 
%                      -1 = error
%                       0 = success
%
%               set: (value is only valid when mode == 3)
%                       0 = rule is not set
%                       1 = rule is set
%               
%               

ADD   = 1;
REM   = 2;
CHECK = 3;

TCAVMODTRIG = 'TRIG:LI20:302'; % TCAV modulator trigger
RULE_MIN = 0;  % Lowest  local trigger rule number
RULE_MAX = 7;  % Highest local trigger rule number

noTcavRule = camacTimingFindGlobalRule();

rval = 0; % Initialize to success
set  = 0; % Initialize to rule not found

if ( noTcavRule == 0 )
    rval = logMsg('tcavModTrigger.m: camacTimingFindGlobalRule failed to find NO TCAV rule');
    return;
end

% For remove, clear any NO TCAV rules for this trigger
if ( mode == REM )
    
    for i = RULE_MIN:RULE_MAX
        i_str = num2str(i);
        try
            id = lcaGet( [TCAVMODTRIG ':RULE' i_str '_ID'], 0, 'float');
            if ( id == noTcavRule )
                lcaPut( [TCAVMODTRIG ':RULE' i_str '_ID'], 0 );
            end
        catch ME
            rval = logMsg('tcavModTrigger.m: lcaPut/Get error while removing rule');
            return;
        end
    end
    
% Set lowest unused rule to NO TCAV (don't worry about 
% duplicates because trig software does not allow them)
elseif ( mode == ADD )
        for i = RULE_MIN:RULE_MAX
            i_str = num2str(i);
            try
                id = lcaGet( [TCAVMODTRIG ':RULE' i_str '_ID'], 0, 'float');
                if ( id == 0 )
                    % Set ID to 0, then to noTcavRule
                    lcaPut( [TCAVMODTRIG ':RULE' i_str '_ID'], 0 );
                    lcaPut( [TCAVMODTRIG ':RULE' i_str '_ID'], noTcavRule );
                    % Set Requested Action to Deactivate
                    lcaPut( [TCAVMODTRIG ':RULE' i_str '_TCTL'], 0 );
                    return;
                end
            catch ME
                rval = logMsg('tcavModTrigger.m: lcaPut/Get error while adding rule');
                return;
            end
        end
        % If we get here, there were no available rules
        rval = logMsg('tcavModTrigger.m: No available trigger rules, all in use');
        return;
        
% Check if 'NO TCAV' rule is present
elseif ( mode == CHECK )
    
    for i = RULE_MIN:RULE_MAX
        i_str = num2str(i);
        try
            id = lcaGet( [TCAVMODTRIG ':RULE' i_str '_ID'], 0, 'float');
            if ( id == noTcavRule )
                set = 1;
                break;
            end
        catch ME
            rval = logMsg('tcavModTrigger.m: lcaPut/Get error while reading rule');
            return;
        end
    end
    
else
    rval = logMsg(sprintf('tcavModTrigger.m: Illegal mode argument %i',mode));
    return;
end

end

function[rval] = logMsg(message)
rval = -1;
facility = 'MATLAB';
myErrInstance = getLogger(facility);
put2log(message);
end
