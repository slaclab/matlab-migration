function [R1s,R3s] = fbGet_BPM_Rmats(dev0, BPM_Xs, BPM_Ys);

%	[R1s,R3s] = get_bpm_Rmats(dev0,BPM_Xs,BPM_Ys);
%
%	INPUTS:		
%           dev0:	Initial condition defined at this device (e.g., 'BPMS' or 'XCOR')
%				BPM_Xs:	Micros of all x-BPMs in the chosen series
%				BPM_Ys:	Micros of all y-BPMs in the chosen series
%
%	OUTPUTS:	R1s:		Array of R11s, 12s, 13s, 14s, and 16s (dimensionless or meters)
%							N-XBPMs rows by 5 columns, where each row looks like:
%							[R11, R12, R13, R14, R16], per BPM
%				R3s:		Array of R31s, 32s, 33s, 34s, and 36s (dimensionless or meters)
%							N-YBPMs rows by 5 columns, where each row looks like:
%							[R31, R32, R33, R34, R36], per BPM

%===============================================================================

nXs = length(BPM_Xs);
nYs = length(BPM_Ys);

R1s = zeros(nXs,5);
R3s = zeros(nYs,5);

for j = 1:nXs	% get all Rmats from dev0 to all x-BPMs
  R = reshape(cell2mat(aidaget([ dev0 '//R'], 'doublea',{['B=' BPM_Xs{j,1}]})),6,6)';
  R1s(j,:) = [R(1,1) R(1,2) R(1,3) R(1,4) R(1,6)];
end

for j = 1:nYs	% get all Rmats from dev0 to all y-BPMs
  R = reshape(cell2mat(aidaget([ dev0 '//R'], 'doublea',{['B=' BPM_Ys{j,1}]})),6,6)';
  R3s(j,:) = [R(3,1) R(3,2) R(3,3) R(3,4) R(3,6)];
end
