function gmat = fbCalcUndGMatrix(energy)
%
%  scale the Undulator Launch G matrix with the 5th order poly
%  function provided by Henrik Loos. This is called whenever the energy in
%  the undulator region is changed. This function is called whenever the 
%  feedback is started or enabled.
%
%  matrix - matrix structure of global data
%  energy - energy value at BYD1
%  fmat - structure with new F and G matrix for Undulator Launch feedback
%
% NOTE: this assumes that the BPMs always are a matched list of BPMX and
% BPMY ie, X and Y from the same BPMs, and the BPMs are RFBU00 thru RFBU010
file = sprintf ('%s/Feedback/%s', getenv('MATLABDATAFILES'), 'UndPolys.mat');
%m= matrix;
load(file);

% 
% get the g matrix for the transverse feedback system
%
config = getappdata(0,'Config_structure');
%[BPM_Xs, BPM_Ys] = fbGetBPMNames_SLC(config);
%[BPM_Xs, BPM_Ys] = fbGetBPMNames(config);
%get the first BPM along the beamline
dev0 = 'BPMS:UND1:100'; 
%[XCORs, YCORs] = fbGetCORNames_SLC(config);
[XCORs, YCORs] = fbGetCORNames(config);
% calculate G matrix
%gmat = fbGet_G_matrix(dev0, XCORs, YCORs);	

%
%
r=length(XCORs);

%now calc the R2s a for the chosen xcors and ycors

for j = 1:r		% get Rmats from both XCOR's to dev0
  G(1,j) = polyval(matrix.p12c(j,:),energy);
  G(2,j) = polyval(matrix.p22c(j,:),energy);
  G(3,j) = 0;
  G(4,j) = 0;
end
for j=1:r      % get Rmats from both XCOR's to dev0 
  G(1,j+r) = 0;
  G(2,j+r) = 0;
  G(3,j+r) = polyval(matrix.p34c(j,:),energy);
  G(4,j+r) = polyval(matrix.p44c(j,:),energy);
end
   
gmat = G;
end