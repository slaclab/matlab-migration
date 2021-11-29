function [Xsf,Ysf,p,dp,chisq,Q,Vs] = xy_traj_fit_kick(Xs,dXs,Ys,dYs,Xs0,Ys0,R1s,R3s,Zs,Z0,fitI)

%   [Xsf,Ysf,p,dp,chisq,Q,Vs] = xy_traj_fit_kick(Xs,dXs,Ys,dYs,Xs0,Ys0,R1s,R3s,Zs,Z0[,fitI])
%
%     Coupled or uncoupled trajectory fitter producing initial pos, ang, and dp/p
%     (if dispersion present).
%
%     INPUTS:   Xs:     Vector or Matrix of X-BPM absolute readbacks
%                       in mm (Matrix is ncols XBPMS by nrows mesaured trajectories)
%               dXs:    Vector or Matrix of meas error on X-BPM readbacks
%                       in mm (if dXs=1 then no errors are used)
%               Ys:     Vector or Matrix of Y-BPM absolute readbacks
%                       in mm (Matrix is ncols Y-BPMS by nrows mesaured trajectories)
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
%               Zs:     Z-location of Xs & Ys readings (m)
%               Z0:     Z-location of initial fit point (m)
%               fitI:   [Optional,DEF=[1 1 1 1 1 1 1]] 1=XPOS, 2=XANG,
%                       3=YPOS, 4=YANG, 5=dE/E (if |eta|>10 mm), 6=Xkick,
%                       7=Ykick
%
%     OUTPUTS:  Xsf:    Fitted X trajectory(s) in mm (=Xs if chisq=0)
%               Ysf:    Fitted Y trajectory(s) in mm (=Ys if chisq=0)
%               p:      4-7 column vector (or matrix) of initial conditions
%                       per jth trajectory (p(j,1)=xpos0(j) in mm, p(j,2)=xang0(j)
%                       in mrad, p(j,3)=ypos0(j) in mm, p(j,4)=yang0(j)
%                       in mrad, p(j,5)=dE/E(j) in parts per 1000, only
%                       if any |R16| or |R36| > 10 mm in fit area, else "p" is
%                       only 4 columns wide), p(j,6)=xkick(j) in mrad,
%                       p(j,7)=ykick(j) in mrad.
%               dp:     Fitted error on "p" (same length and units)
%               chisq:  Chisq(s) per degree of freedom (if dXs and dYs = 1,
%                       "dp" is rescaled such that "chisq" = 1).
%               Q:      Fit matrix if needed (=[R1s; R3s]).
%               V:      Covariance matrix to propagate errors if needed (dp=sqrt(diag(V))).

%===============================================================================

if ~exist('fitI','var')
  fitI = [1 1 1 1 1 1 1];
end
% qualify trajectory data:
[nsampx,nXs] = size(Xs);
[nsampy,nYs] = size(Ys);
if nsampx ~= nsampy
  error('Number of rows (trajectories sampled) must be same for Xs and Ys data - quitting.')
end
[nsampx0,nXs0] = size(Xs0);
[nsampy0,nYs0] = size(Ys0);
if (nsampx0~=1) || (nsampy0~=1)
  error('Reference trajectories must have one row only - quitting.')
end
if (nXs~=nXs0) || (nYs~=nYs0)
  error('Reference trajectories must have same number of x-BPMs and y-BPMs as measured Xs and Ys data - quitting.')
end
[nsampdx,ndXs] = size(dXs);
[nsampdy,ndYs] = size(dYs);

% qualify model data:
[rR,cR] = size(R1s);
if cR ~= 5
  error('Number of R1s columns must be 5 - quitting.')
end
if rR ~= nXs
  error('Number of R1s columns must be same as X-BPMs - quitting.')
end
[rR,cR] = size(R3s);
if cR ~= 5
  error('Number of R3s columns must be 5 - quitting.')
end
if rR ~= nYs
  error('Number of R3s columns must be same as Y-BPMs - quitting.')
end

% check if x-weighting provided or not (if dXs=1, no weighting)
noerrors = 0;				% default to weighting provided
if ndXs==1 && ndXs~=nXs     % if dXs is only 1-by-1 & not the same length as Xs
  if dXs == 1				% ...and if its equal to 1
    noerrors = 1;			% errors (weighting) is not used
  else
    error('"dXs" must have same number of BPMs as "Xs" or just be equal to 1 -  - quitting.')
  end
elseif ndXs~=nXs
  error('"dXs" must have same number of BPMs as "Xs" or just be equal to 1 -  - quitting.')
end

% check if y-weighting provided or not (if dYs=1, no weighting)
if ndYs==1 && ndYs~=nYs		% if dYs is only 1-by-1 & not the same length as Ys
  if dYs == 1				% ...and if its equal to 1
    noerrors = 1;			% errors (weighting) is not used
  else
    error('"dYs" must have same number of BPMs as "Ys" or just be equal to 1 -  - quitting.')
  end
elseif ndYs~=nYs
  error('"dYs" must have same number of BPMs as "Ys" or just be equal to 1 -  - quitting.')
end

nsamp = nsampx;		% total number of trajectories to fit (usually 1?)

if nsamp == 1		% if only one trajectories, vector orientation is uncertain, so...
  Xs  = Xs(:)';		% force into a column-vector (i.e., one column and N-BPM rows)
  Ys  = Ys(:)';		% ...
end
Xs0 = Xs0(:)';		% ...
Ys0 = Ys0(:)';		% ...

Xsf   = zeros(nsamp,nXs);	% size output arrays and initialize to zero
Ysf   = zeros(nsamp,nYs);	% ...
chisq = zeros(nsamp,1);		% ...

%  R1s(j,:) = [Rm{1,1} Rm{1,2} Rm{1,3} Rm{1,4} Rm{1,6}];
%  R3s(j,:) = [Rm{3,1} Rm{3,2} Rm{3,3} Rm{3,4} Rm{3,6}];

% only fit energy change (5th variable) if x- or y-dispersion is > 10 mm anywhere in beamline section
if fitI(5)
  if any(abs(R1s(:,5))>0.010) || any(abs(R3s(:,5))>0.010)
  else
    disp('Not enough dipersion to fit energy... fitting without dE/E.');
    fitI(5) = 0;
  end
end

I = find(fitI);
if isempty(I)
  return
end

R1sk = R1s;
R3sk = R3s;
R1sk(Zs<=Z0,:) = 0;
R3sk(Zs<=Z0,:) = 0;
R1s = [R1s R1sk(:,2) R1sk(:,4)];                % add X-kick function starting at Z0
R3s = [R3s R3sk(:,2) R3sk(:,4)];                % add Y-kick function starting at Z0

Q = [R1s(:,I); R3s(:,I)];
p  = zeros(nsamp,length(I));
dp = zeros(nsamp,length(I));

for j = 1:nsamp									% loop through all measured trajectories
  Ss  = [Xs(j,:)-Xs0 Ys(j,:)-Ys0]';				% subtract reference trajectories (same for all measured trajectories)
  dSs = [dXs(j,:) dYs(j,:)]';					% build weighting array
  if noerrors									% if no weighting provided...
    [Ssf,dSsf,p1,dp1,chisq1,V] = fit(Q,Ss);		% fit without weighting
  else
    [Ssf,dSsf,p1,dp1,chisq1,V] = fit(Q,Ss,dSs);	% fit with weighting
  end
  [nr,nc] = size(V);
  p(j,:)   = p1(:)';                            % each row of p is the initial conditions for a new trajectory
  dp(j,:)  = dp1(:)';							% error on p
  Xsf(j,:) = Ssf(1:nXs)';						% predicted X-difference trajectory (~same as Xs-Xs0)
  Ysf(j,:) = Ssf((nXs+1):(nXs+nYs))';			% predicted Y-difference trajectory (~same as Ys-Ys0)
  chisq(j) = chisq1;							% chi-squared per measured trajectory (all=1 of no weighting provided)
  Vs(j,:) = reshape(V,1,nr*nc);
end