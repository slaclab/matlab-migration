function[id] = camacTimingFindGlobalRule

% Find the 'NO TCAV' rule among the CAMAC timing global rules
%
%   Arguments: None (for now)
%
%   Return:    id - ID number of desired global rule 
%                   (for now, this is always the 'NO TCAV' rule)
%                   Return 0 if not found
%
RULE_MIN = 1;      % Lowest  global rule ID
RULE_MAX = 10;     % Highest global rule ID
SYS      = 'SYS0'; % Global rules PV names location

% NO TCAV rule definitions
TCAVTYPE  = 2;
TCAVBC    = 1;
TCAVEXCL1 = hex2dec('80000000'); % Modifier 3 exclusion mask to match.
% All other masks should be zero.

id  = 0; % Initialize id to 0, indicating rule not found

for i = RULE_MIN:RULE_MAX
    
    i_str = num2str( i );
    try
        type  = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_TYPE'],     0, 'float' );
        bc    = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_BEAMCODE'], 0, 'float' );
        incl1 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_INCL1'],    0, 'float' );
        incl2 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_INCL2'],    0, 'float' );
        incl3 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_INCL3'],    0, 'float' );
        incl4 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_INCL4'],    0, 'float' );
        excl1 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_EXCL1'],    0, 'float' );
        excl2 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_EXCL2'],    0, 'float' );
        excl3 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_EXCL3'],    0, 'float' );
        excl4 = lcaGet( ['TRIG:' SYS ':1:RULE' i_str '_EXCL4'],    0, 'float' );
    catch ME
        logMsg('camacTimingFindGlobalRule.m: lcaGet error');
        return;
    end
    
    if ( incl1+incl2+incl3+incl4+excl2+excl3+excl4 ~= 0 )
    elseif ( (type==TCAVTYPE) && (bc==TCAVBC) && (excl1==TCAVEXCL1) )
        id = i;
        return;
    end
end
end

function[] = logMsg(message)
facility = 'MATLAB';
myErrInstance = getLogger(facility);
put2log(message);
end