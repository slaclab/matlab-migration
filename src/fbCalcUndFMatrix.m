function fmat = fbCalcUndFMatrix(meas, energy)
%
%  scale the Undulator Launch F and G matrices with the 5th order poly
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

%initialize bpmX counters
x=0;
p=0;
%now calc the R1s a for the chosenBPMs Xs
for i=1:(length(meas.PVs)/2)
   p = p+1; % keep track of location in polynomial matrices
   %calc R1s for Xs
   if (meas.PVs(i)>0) && (~isempty(cell2mat(strfind(meas.allmeasPVs(i),'X'))) )
      x = x+1;
      % these are the values for BPM Xs
      %r11 = p11(i,1)*en^5+p11(3,2)*en^4+...+p11(3,5)*en+p11(3,6)
      R1s(x,1) = polyval(matrix.p11(p,:),energy);
      R1s(x,2) = polyval(matrix.p12(p,:),energy);
      R1s(x,3:5) = 0;
      % these are the values for BPM Ys
      R3s(x,1:2) = 0;
      R3s(x,3) = polyval(matrix.p33(p,:),energy);
      R3s(x,4) = polyval(matrix.p34(p,:),energy);
      R3s(x,5)= 0;
   end
end

fmat = [R1s; R3s];

end