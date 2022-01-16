function fbLoadBLDPVs()
%
%
% AIDA-PVA imports
global AIDA_DOUBLE_ARRAY;

%
% set up the BLD PV names
dispersionPVs = {'BLD:SYS0:500:DSPR1'; 'BLD:SYS0:500:DSPR2'}; %ai records
fmatrixPV = {'BLD:SYS0:500:FMTRX'}; % waveform record

% Get the matrix for calculating the XPos,XAng, YPos, YAng at LTU
BPMs = {'BPMS:LTU1:720';'BPMS:LTU1:730';'BPMS:LTU1:740';'BPMS:LTU1:750'};
%get the first BPM
dev0 = BPMs{1,1};
% get the R1s and R3s for these BPMs
[R1s,R3s] = fbGet_BPM_Rmats(dev0, BPMs, BPMs);
% format the f matrix
rmatrix = [R1s; R3s];
% get the inverse of this matrix
fmatrix = pinv(rmatrix);
% make this a single row

% write to FMTRX PV
%lcaPut(fmatrixPV, fmat);
%
% now get dispersion values
dspr_BPMs = {'BPMS:LTU1:250'; 'BPMS:LTU1:450' };
for i=1:2
  tws = pvaGetM([dspr_BPMs{i,1}, ':twiss'], AIDA_DOUBLE_ARRAY); % get value from aida Model
  dspr(i) = cell2mat(tws(5))*1000;
end
%lcaPut(dispersionPVs, dspr);



