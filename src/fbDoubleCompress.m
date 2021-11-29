function [sz,sd,k,Ipk,dE_E,dt,Eloss,sdsgn] = fbDoubleCompress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
                                                              dN_N,dtg,dphiv,dV_Vv,lamv,s0v,av)

% [sz,sd,k,Ipk,dE_E,dt,Eloss,sdsgn] = fbDoubleCompress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
%                                                     dN_N,dtg,dphiv,dV_Vv,lamv,s0v,av);
%
%	Function to calculate bunch length and energy spread after a five-stage
%	compressor system (just like LCLS) where the E-z correlations are generated
%	by five linacs at off crest rf phases (not zero crossing).  The wakefield is
%	included in linear form assuming rectangular z-distributions.  The rms
%	bunch lengths and energy spreads calculated here are linear in that they
%	do not directly include the T566, or rf curvatur non-linearities along the
%	bunch.  The calculation does, however, include the E-z correlation dependence
%	on incoming timing jitter (due to rf curvature) and charge jitter, and the
%	T566 effect on R56 for mean-off-energy beams.  The bunch head is at z<0
%	(same as LiTrack), so a chicane compressor has both R56 < 0 and phi < 0.
%
%       Inputs:		sz0:	Initial rms bunch length [mm]
%			        sd0:	Initial incoh. energy spread at Eg [%]
%       		    Eg:	    Gun exit energy [GeV]
%       		    Ev:	    Vector of 5 post-linac energies [GeV]
%			        R56v:	Vector of 5 R56 values (chicane-R56 < 0) [m]
%			        T566v:	Vector of 5 T566 values (always > 0) [m]
%			        phiv:	Vector of 5 linac RF phases (-30 deg accelerates
%                           and puts head energy lower than tail) [degrees]
%			        Lv:	    Vector of 5 linac lengths (scales wake) [m]
%			        N:	    Bunch population [e.g. 6.25E9]
%			        dN_N:	Relative bunch population
%				            error [%] (e.g. -2 => 2%-low in bunch charge)
%			        dtg:	Timing error of gun
%				            wrt RF (<0 is an early bunch) [psec]
%			        dphiv:	Vector of 5 linac RF phase
%				            errors originating in that linac (<0 is
%				            early bunch arrival) [deg]
%			        dV_Vv:	Vector of 5 linac RF rel. voltage errors [ ]
%			        lamv:	RF wavelength for each linac (Sband=0.105m,
%				            Xband=0.02625m) [m]
%			        s0v:	Wakefield characteristic length (Sband=1.322mm),
%				            Xband=0.77mm) [mm]
%			        av:	    Mean iris radius
%				            (Sband=11.654mm,Xband=4.72mm) [mm]
%			
%	Outputs:	    sz:	    rms bunch length after i-th linac [mm]
%			        sd:	    rms rel. energy spread after i-th linac [%]
%			        k:	    <Ez> correlation const. of i-th linac [1/m]
%			        Ipk:	Peak current at end of i-th linac [A]
%			        dE_E:	Relative energy offset after i-th linac [%]
%			        dt:	    Timing error at end of i-th linac [psec]
%			        Eloss:	Energy loss per linac due to wake [GeV]
%			        sdsgn:	Signed, correlated E-sprd per linac
%                           (dE_E-z slope * sigz) [%]

%===============================================================================

Nv = length(Ev);		% qualify inputs...

e         = 1.602177E-19;	                % constants and conversions...
c         = 2.99792458E8;
Z0        = 120*pi;
dN_Nf     = dN_N*1e-2;		                % percent -> unitless
s0m       = s0v*1E-3;
am        = av*1E-3;
deg_2_rad = pi/180;
lambar    = lamv/2/pi;
sz0m      = sz0*1E-3;
sd0f      = sd0*1E-2;
sqrt12    = sqrt(12);
Nec       = 2*N*e*s0m*Z0*c/pi./am.^2/1E9;

phivr     = phiv*deg_2_rad;
dphivr    = dphiv*deg_2_rad;
C         = cos(phivr);
sz1       = [sz0m zeros(1,Nv)];				% bunch length 6-vector (includes gun value)
sd1       = [sd0f zeros(1,Nv)];				% energy spread 6-vector (includes gun value)
cor1      = [0 zeros(1,Nv)];				% E-z correlation 6-vector (includes gun value = 0)
dE_E1     = [0 zeros(1,Nv)];				% make 6-vector with 1st dE/E=0
dt1       = [dtg*1E-12 zeros(1,Nv)];		% make 6-vector for timing errors [sec]
Ev1       = [Eg Ev(:)'];				    % make 6-vector of energies (so all user inputs are 5-vectors)
sz        = zeros(1,5);
sd        = zeros(1,5);
k         = zeros(1,5);
Ipk       = zeros(1,5);
dE_E      = zeros(1,5);
dt        = zeros(1,5);
Eloss     = zeros(1,5);
wfac      = [1 1 1 1 1];				    % use to scale wake for quick tests (otherwise set all=1 !!!)
for j = 1:Nv						        % loop over all linac-compressor segments
  Er(j)       = Ev1(j)/Ev1(j+1);			% energy ratio [ ]
  ds          = sz1(j)*sqrt12;				% FW bunch length for uniform dist. [m]
  dphi        = dt1(j)*c/lambar(j) + dphivr(j);		% total local phase error (gun, prev-R56 + local-rf) [rad]
  kw          = -(1+dN_Nf)*(Nec(j)*wfac(j)*Lv(j)/(ds^2*Ev(j)))*...
                (1-(1+sqrt(ds/s0m(j)))*exp(-sqrt(ds/s0m(j))));% wake's effect on linear correlation factor (<0) [1/m]
  kn          = (Er(j)-1)*(1+dV_Vv(j))*sin(phivr(j) + dphi)/... 
                (lambar(j)*C(j));			% rf phase induced linear correlation factor [1/m]
  k(j)        = kw + kn;				    % total linear correlation factor [1/m]
  dE_E(j)     = dE_E1(j)*Er(j) + ...
                (1-Er(j)-kw/(1+dN_Nf)*ds/2)*... 
                ((1+dV_Vv(j))*cos(phivr(j) + dphi)/C(j) - 1) + ... 
                kw*dN_Nf/(1+dN_Nf)*ds/2;	% relative energy error due to dphase, dV/V, and dN/N errors[ ]          
  R56         = R56v(j) + 2*dE_E(j)*T566v(j);	% R56 value changed by T566*dE/E [m] 
  Eloss(j)    = -Ev(j)*kw*ds/2;				% approximate energy loss due to wake (>0) [GeV]
  kR561       = 1+k(j)*R56;				    % save computation time
  sd2         = sd1(j)^2;				    % save computation time
  sz2         = sz1(j)^2;				    % save computation time
  sz(j)       = sqrt(kR561^2*sz2 + ...
                     (R56*Er(j)*sd1(j))^2 + ...
                     2*Er(j)*R56*kR561*cor1(j));	% rms bunch length after linac and R56 #(j-1) [m]
  sd(j)       = sqrt(k(j)^2*sz2 + ...
                     Er(j)^2*sd2 + ...
                     2*Er(j)*k(j)*cor1(j));	    % rms energy spread after linac and R56 #(j-1) [ ]
  cor1(j+1)   = k(j)*kR561*sz2 + ...
                Er(j)^2*R56*sd2 + ...
                Er(j)*(1+2*k(j)*R56)*cor1(j);	% save new E-z correlation [m]
  sdsgn(j)    = cor1(j+1)/sz(j);			    % signed-correlated energy spread (slope*sigz) [ ]
  dE_E1(j+1)  = dE_E(j);				        % save dE_E [ ]
  sz1(j+1)    = sz(j);					        % save new rms bunch length [m]
  sd1(j+1)    = sd(j);					        % save new total rms energy spread [ ]
  dt1(j+1)    = dt1(j) + dE_E(j)*R56/c;			% timing error after R56 [sec]
  dt(j)       = 1E12*dt1(j+1);				    % save timing error to this point [psec]
end

Ipk   = (1+dN_Nf)*N*e*c/sqrt12./sz;			    % calculate peak current over uniform bunch dist. [A]
sz    = sz*1E3;						            % m -> mm
sd    = sd*1E2;						            % [ ] -> %
sdsgn = sdsgn*1E2;					            % [ ] -> % (dE/E-z slope times sigz)
dE_E  = dE_E*1E2;					            % [ ] -> %
