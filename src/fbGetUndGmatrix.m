function gmat = fbGetUndGmatrix()
% 
% get the f matrix for the transverse feedback system
%
config = getappdata(0,'Config_structure');
%[BPM_Xs, BPM_Ys] = fbGetBPMNames_SLC(config);
[BPM_Xs, BPM_Ys] = fbGetBPMNames(config);
%get the first BPM along the beamline
dev0 = 'BPMS:UND1:100'; 
%[XCORs, YCORs] = fbGetCORNames_SLC(config);
[XCORs, YCORs] = fbGetCORNames(config);
% calculate G matrix
gmat = fbGet_G_matrix(dev0, XCORs, YCORs);	

