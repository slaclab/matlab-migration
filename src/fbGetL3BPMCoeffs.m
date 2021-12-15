function [coeff1, coeff2] = fbGetL3BPMCoeffs(bpm_XPVs)
%
% the coefficients for three-BPM estimate of bunch centroid energy
% sigma = x3 -
%        (R31-12/R21-11)x2 -
%        (R31-11*R21-12 - R31-12*R21-11)/R21-12)x3
% so the coefficients 1 and 2 are:
% c1 = (R31-12/R21-11), and
% c2 = (R31-11*R21-12 - R31-12*R21-11)/R21-12)
%

dev0 = bpm_XPVs{1,1};
nXs = length(bpm_XPVs);

R1s = zeros(nXs,2);

requestBuilder = pvaRequest([ dev0 ':R']);
requestBuilder.returning(AIDA_DOUBLE_ARRAY);
for j = 2:nXs	% get all Rmats from dev0 to 2nd & 3rd x-BPMs
  requestBuilder.with('B',bpm_XPVs{j,1});
  R = reshape(ML(requestBuilder.get()),6,6)';
  R1s(j,:) = [R(1,1) R(1,2)];
end

% c1 = R
coeff1 = -R(3,2)/R(2,2);
coeff2 = -(R(3,1)*R(2,2) - R(3,2)*R(2,1))/R(2,2);

end
