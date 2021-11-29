function [Xsf,Ysf,p,dp,chisq,Q] = fbXYTrajFit1(Xs,dXs,Ys,dYs,Xs0,Ys0,R1s,R3s)

%   [Xsf,Ysf,p,dp,chisq,Q] = fbXYTrajFit1(Xs,dXs,Ys,dYs,Xs0,Ys0,R1s,R3s)
%
%     Coupled or uncoupled trajectory fitter producing initial pos. and ang.
%
%     INPUTS:   Xs:     Vector or Matrix of X-BPM absolute readbacks
%                       in mm (Matrix is ncols XBPMS by nrows trajectories)
%               dXs:    Vector or Matrix of meas error on X-BPM readbacks
%                       in mm (if dXs=1 then no errors are used)
%               Ys:     Vector or Matrix of Y-BPM absolute readbacks
%                       in mm (Matrix is ncols Y-BPMS by nrows trajectories)
%               dYs:    Vector or Matrix of meas error on Y-BPM readbacks
%                       in mm (if dYs=1 then no errors are used)
%				Xs0:    Vector of X-reference trajectory values in mm
%				Ys0:    Vector of Y-reference trajectory values in mm
%				R1s:	Array of R11s, 12s, 13s, 14s, and 16s (dimensionless or meters)
%						N-XBPMs rows by 5 columns, where each row looks like:
%						[R11, R12, R13, R14, R16], per BPM
%				R3s:	Array of R31s, 32s, 33s, 34s, and 36s (dimensionless or meters)
%						N-YBPMs rows by 5 columns, where each row looks like:
%						[R31, R32, R33, R34, R36], per BPM
%
%     OUTPUTS:  Xsf:    Fitted X trajectory(s) in mm (=Xs if chisq=0)
%               Ysf:    Fitted Y trajectory(s) in mm (=Ys if chisq=0)
%               p:      4 or 5 column vector (or matrix) of initial conditions
%                       per jth trajectory (p(j,1)=xpos0(j) in mm, p(j,2)=xang0(j)
%                       in mrad, p(j,3)=ypos0(j) in mm, p(j,4)=yang0(j)
%                       in mrad, p(j,5)=dE/E(j) in parts per 1000, only
%                       if any |R16| or |R36| > 10 mm in fit area, else "p" is
%                       only 4 columns wide)
%               dp:     Fitted error on "p" (same length and units)
%               chisq:  Chisq(s) per degree of freedom (if dXs and dYs = 1,
%                       "dp" is rescaled such that "chisq" = 1).
%               Q:      Fit matrix to propagate errors if needed (=[R1s; R3s]).

%===============================================================================

[nsampx,nXs] = size(Xs);
[nsampy,nYs] = size(Ys);
[nsampdx,ndXs] = size(dXs);
[nsampdy,ndYs] = size(dYs);
if (nsampdx~=1) || (nsampdy~=1)
  error('dXs and dYs errors must have one row only - quitting.')
end


% check if x-weighting provided or not (if dXs=1, no weighting)
noerrors = 0;				% default to weighting provided
if ndXs==1					% if dXs is only 1-by-1
  if dXs == 1				% ...and if its equal to 1
    noerrors = 1;			% errors (weighting) is not used
  else
    error('"dXs" must have same number of BPMs as "Xs" or just be equal to 1 -  - quitting.')
  end
end

% check if y-weighting provided or not (if dYs=1, no weighting)
if ndYs==1					% if dYs is only 1-by-1
  if dYs == 1				% ...and if its equal to 1
    noerrors = 1;			% errors (weighting) is not used
  else
    error('"dYs" must have same number of BPMs as "Ys" or just be equal to 1 -  - quitting.')
  end
end

nsamp = 1;		% total number of trajectories to fit (usually 1)

Xs  = Xs(:)';		% force into a column-vector (i.e., one column and N-BPM rows)
Ys  = Ys(:)';		% ...
dXs = dXs(:)';		% force into a column-vector (i.e., one column and N-BPM rows)
dYs = dYs(:)';		% ...
Xs0 = Xs0(:)';		% ...
Ys0 = Ys0(:)';		% ...

Xsf   = zeros(nsamp,nXs);	% size output arrays and initialize to zero
Ysf   = zeros(nsamp,nYs);	% ...
chisq = zeros(nsamp,1);		% ...

% also fit energy change (5th variable) if x- or y-dispersion is > 10 mm anywhere in beamline section
if any(abs(R1s(:,5))>0.010) || any(abs(R3s(:,5))>0.010)
  Q  = [R1s; R3s];
  p  = zeros(nsamp,5);
  dp = zeros(nsamp,5);
else	% otherwise only fit 4 corrector angles
  Q  = [R1s(:,1:4); R3s(:,1:4)];
  p   = zeros(nsamp,4);
  dp  = zeros(nsamp,4);
end

% This version also calculates the error bars, dp, but runs fairly slow:
% =====================================================================
%for j = 1:nsamp								% loop through all measured trajectories
%  Ss  = [Xs(j,:)-Xs0 Ys(j,:)-Ys0]';			% subtract reference trajectories (same for all measured trajectories)
%  dSs = [dXs(j,:) dYs(j,:)]';					% build weighting array
%  if noerrors									% if no weighting provided...
%    [Ssf,dSsf,p1,dp1,chisq1] = fit(Q,Ss);		% fit without weighting
%  else
%    [Ssf,dSsf,p1,dp1,chisq1] = fit(Q,Ss,dSs);	% fit with weighting
%  end
%  p(j,:)   = p1(:)';							% each row of p is the initial conditions for a new trajectory
%  dp(j,:)  = dp1(:)';							% error on p
%  Xsf(j,:) = Ssf(1:nXs)';						% predicted X-difference trajectory (~same as Xs-Xs0)
%  Ysf(j,:) = Ssf((nXs+1):(nXs+nYs))';			% predicted Y-difference trajectory (~same as Ys-Ys0)
%  chisq(j) = chisq1;							% chi-squared per measured trajectory (all=1 of no weighting provided)
%end

% This version does not calculate the error bars, but runs much faster:
% ====================================================================
for j = 1:nsamp									% loop through all measured trajectories
  Ss  = [Xs(j,:)-Xs0 Ys(j,:)-Ys0]';				% subtract reference trajectories (same for all measured trajectories)
  p1 = Q\Ss;                                    % very fast fit without errors, etc
  chisq1  = sum((Q*p1-Ss).^2);                  % chi-squared per measured trajectory
  Ssf     = Q*p1;                               % predicted X and Y-difference trajectories
  p(j,:)  = p1(:)';         					% each row of p is the initial conditions for a new trajectory
  dp(j,:) = 0*p1(:)';							% error on p not calculated in this fast version
  Xsf(j,:) = Ssf(1:nXs)';						% predicted X-difference trajectory (~same as Xs-Xs0)
  Ysf(j,:) = Ssf((nXs+1):(nXs+nYs))';			% predicted Y-difference trajectory (~same as Ys-Ys0)
  chisq(j) = chisq1;							% chi-squared per measured trajectory (all=1 of no weighting provided)
end