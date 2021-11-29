function fmat = fbGetTransFmatrix()
% 
% get the f matrix for the transverse feedback system
%
config = getappdata(0,'Config_structure');

%[BPM_Xs, BPM_Ys] = fbGetBPMNames_SLC(config);
[BPM_Xs, BPM_Ys] = fbGetBPMNames(config);

%get the first BPM along the beamline
dev0 = BPM_Xs{1,1}; 
% calculate the f (Q) matrix
[R1s,R3s] = fbGet_BPM_Rmats(dev0, BPM_Xs, BPM_Ys); 

fmat = [R1s; R3s];
