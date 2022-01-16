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

% AIDA-PVA imports
global pvaRequest;

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

requestBuilder = pvaRequest(strcat(char(dgrp), ':BUFFACQ'));
requestBuilder.with('BPMD', bpmd);
requestBuilder.with('NRPOS', num);
convertedBpms
for ix = 1:numel(bpms)
    convertedBpms(ix) = model_nameConvert(bpms(ix), 'SLC');
end
requestBuilder.with('BPMD', convertedBpms);

% call AIDA
try
    buffdata = ML(requestBuilder.get());
catch e
    handleExceptions(e);
    [x, y, tmit, pulseid] = deal(nan(num, numel(bpms)));
    good = zeros(num, numel(bpms));
    return;
end

% extract java stuff to matlab and reformat arrays
pulseid = flipdim(reshape(buffdata.values.pulsId, num, numel(bpms)), 2);
x = flipdim(reshape(buffdata.values.x, num, numel(bpms)), 2);
y = flipdim(reshape(buffdata.values.y, num, numel(bpms)), 2);
tmit = flipdim(reshape(buffdata.values.tmit, num, numel(bpms)), 2);
good = flipdim(reshape(buffdata.values.goodmeas, num, numel(bpms)), 2);
