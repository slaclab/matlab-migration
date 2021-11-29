function [x, y, tmit, bpms, pulseid, good] = scp_buffAcq(bpms, dgrp, num)
% [X, Y, TMIT, BPMS, PULSEID, GOOD] = SCP_BUFFACQ(BPMS, DGRP, NUM) collects
% buffered BPM data using the AIDA buffered acquisition tool thingy.
% Returns NaN values if buffered acquisition failes.
%
% Input Arguments:
%   BPMS: String or cell array of strings of BPM names (e.g. 'BPMS:LI02:201'). 
%   DGRP: Name of DGRP to acquire buffered data from, e.g. 'NDRFACET' or 'ELECEP01'. 
%   NUM:  Number of samples to acquire.
%
% Output arguments:
%       X, Y, TMIT: M X NUM array of orbit data where M is the number of BPMS passed in.
%       BPMS:       M x 1 array of BPM names.
%       STAT:       M x NUM array of pulse IDs.
%       GOOD:       M x NUM array of "good measurement" flags.
%
%  
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

% add more DGRPs here if desired
switch char(dgrp)
    case 'NDRFACET'
        bpmd = 57;
    case 'ELECEP01'
        bpmd = 8;
    otherwise
        return
end

bpms = reshape(cellstr(bpms), 1, []);

% set up aida query
aidainit;
import edu.stanford.slac.aida.lib.da.DaObject;
da = DaObject();
da.setParam('BPMD', num2str(bpmd));
da.setParam('NRPOS', num2str(num));
for ix = 1:numel(bpms)
    da.setParam(strcat('BPM', num2str(ix)), char(model_nameConvert(bpms(ix), 'SLC')));
end


% call AIDA
try
    buffdata = da.getDaValue(strcat(char(dgrp), '//BUFFACQ'));
catch
    [x, y, tmit, pulseid] = deal(nan(num, numel(bpms)));
    good = zeros(num, numel(bpms));
    return;
end

% extract java stuff to matlab and reformat arrays
pulseid = flipdim(reshape(buffdata.get(1).getAsDoubles(), num, numel(bpms)), 2);
x = flipdim(reshape(buffdata.get(2).getAsDoubles(), num, numel(bpms)), 2);
y = flipdim(reshape(buffdata.get(3).getAsDoubles(), num, numel(bpms)), 2);
tmit = flipdim(reshape(buffdata.get(4).getAsDoubles(), num, numel(bpms)), 2);
good = flipdim(reshape(buffdata.get(6).getAsDoubles(), num, numel(bpms)), 2);
