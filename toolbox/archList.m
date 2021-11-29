% This program will return an array of all PVS in the archiver that match the given pattern
% 
% This uses the parse_json function written by Francois Glineur:
% www.mathworks.com/matlabcentral/fileexchange/23393-another-json-parser
% 
% Based on getAppStatus by David Wright
% Written by Murali Shankar
% pvs = archList('VPIO:IN20:111:*');

function [pvs]= archList(pvGlob)

[sys, accelerator] = getSystem;
accelerator = lower(accelerator);

pvs = parse_json(urlread(['http://' accelerator '-archapp.slac.stanford.edu/mgmt/bpl/getAllPVs?pv=' pvGlob]));
[a b] = size(pvs); if b ~=1, pvs = pvs'; end

end
