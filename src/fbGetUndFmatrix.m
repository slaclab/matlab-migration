function fmat = fbGetUndFmatrix()
% 
% get the f matrix for the transverse feedback system
%
config = getappdata(0,'Config_structure');

BY1_energy = lcaGet('BEND:LTU0:125:BDES');

% get the scaling polynomial coefficients
[p11, p12, p33, p34] = fbUndPolys();
config.matrix.p11 = p11;
config.matrix.p12 = p12;
config.matrix.p33 = p33;
config.matrix.p34 = p34;
setappdata(0, 'Config_structure', config);
% change to the $MATLABDATAFILES path to write the file
file = sprintf ('%s/Feedback/%s', getenv('MATLABDATAFILES'), 'UndPolys.mat');
temp.matrix = config.matrix;
save(file, '-struct', 'temp');
% now scale for the current energy
fmat = fbCalcUndMatrix(config.meas,  BY1_energy);

