function fmat = fbGetUndFmatrixForConfigApp(numMeas)
% 
% get the f matrix for the transverse Undulator Launch feedback system
%
energy = lcaGet('BEND:LTU0:125:BDES');

% get the scaling polynomial coefficients
[p11, p12, p33, p34] = fbUndPolys();
% now scale for the current energy
x=0;
p=0;
%now calc the R1s a for the chosenBPMs Xs
for i=1:(numMeas/2)
   p = p+1; % keep track of location in polynomial matrices
   %calc R1s for Xs
      x = x+1;
      % these are the values for BPM Xs
      %r11 = p11(i,1)*en^5+p11(3,2)*en^4+...+p11(3,5)*en+p11(3,6)
      R1s(x,1) = polyval(p11(p,:),energy);
      R1s(x,2) = polyval(p12(p,:),energy);
      R1s(x,3:5) = 0;
      % these are the values for BPM Ys
      R3s(x,1:2) = 0;
      R3s(x,3) = polyval(p33(p,:),energy);
      R3s(x,4) = polyval(p34(p,:),energy);
      R3s(x,5)= 0;
end

fmat = [R1s; R3s];

end
