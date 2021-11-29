function SetBgrpVariable(bgrp, variableName, value)

% Author: Bob Hall
%
% Usage example:
%   SetBgrpVariable('LCLS', 'T_CAV', 'Y');
%
% BGRP set variable value function.  This function
% sets the specified variable of the specified BGRP name to a 
% specified value ('N' or 'Y').
%
% bgrp - string containing the BGRP name (e.g. 'LCLS').
%
% variableName - string containing a variable name for the BGRP
% (e.g., 'T_CAV').
%
% value - string ('N' or 'Y') containing the new value for the
% specified variable of the specified BGRP. 
%

aidainit;
import java.util.Vector;

err = getLogger('SetBgrpVariable');
import edu.stanford.slac.aida.lib.da.DaObject; 
da = DaObject();

da.setParam('BGRP', bgrp);

da.setParam('VARNAME', variableName);

inData = DaValue(java.lang.String(value));

da.setDaValue('BGRP//VAL', inData);

da.reset();

return;

