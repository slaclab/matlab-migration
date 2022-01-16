function asset_elec(state)
% asset_elec(1) enables ASSET electrons for E-208
% asset_elec(0) disables ASSET electrons for E-208
% auth. nate 11/26/14

% AIDA-PVA imports
global pvaRequest;

requestBuilder = pvaRequest('BGRP:VAL');
requestBuilder.with('BGRP', 'FACET_POSI');
requestBuilder.with('VARNAME', 'ASSET_ON');

switch state
    case 0
        disp_log('Setting ASSET_ON to N in BGRP FACET_POSI');
        requestBuilder.set('N');
    case 1
        disp_log('Setting ASSET_ON to Y in BGRP FACET_POSI');
        requestBuilder.set('Y');
    otherwise
        disp_log('Input must be 0 or 1, exiting');
end
