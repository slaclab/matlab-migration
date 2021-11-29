% This program will return a structure with all relevant archive appliance
% statuses for a given pV.
% 
% This uses the parse_json function written by Francois Glineur:
% www.mathworks.com/matlabcentral/fileexchange/23393-another-json-parser
% 
% Written by David Wright

function [pvStatus connected]= getAppStatus(pV)

[sys, accelerator] = getSystem;
accelerator = lower(accelerator);

result = parse_json(urlread(['http://' accelerator '-archapp.slac.stanford.edu/mgmt/bpl/getPVStatus?pv=' pV]));
pvStatus = result{1,1};

if strcmp(pvStatus.status, 'Being archived')
    connected = true;
elseif strcmp(pvStatus.status, 'Not being archived')
    connected = false;

end