function asset_elec(state)
% asset_elec(1) enables ASSET electrons for E-208
% asset_elec(0) disables ASSET electrons for E-208
% auth. nate 11/26/14

aidainit;
import edu.stanford.slac.aida.lib.da.DaObject;
da = DaObject();
da.setParam('BGRP', 'FACET_POSI');
da.setParam('VARNAME', 'ASSET_ON');

switch state
    case 0
        disp_log('Setting ASSET_ON to N in BGRP FACET_POSI');
        r = da.setDaValue('BGRP//VAL', DaValue(java.lang.String('N')));
        rstr = r.getString();
        if ~strcmpi(rstr, 'N')
            disp_log(sprintf('WARNING:  AIDA returned %s!', rstr))
        end
    case 1
        disp_log('Setting ASSET_ON to Y in BGRP FACET_POSI');
        r = da.setDaValue('BGRP//VAL', DaValue(java.lang.String('Y')));
        rstr = r.getString();
        if ~strcmpi(rstr, 'Y')
            disp_log(sprintf('WARNING:  AIDA returned %s!', rstr))
        end
    otherwise
        disp_log('Input must be 0 or 1, exiting');       
end