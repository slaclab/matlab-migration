function [szn,sdn,kn,Ipkn,dE_En,dtn,Eloss,dI_dN,dE_dN,dI_dtg,dE_dtg,sdsgn] = ...
  					LCLSopt_fun(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
 							    dphiv,lamv,s0v,av);

% [szn,sdn,kn,Ipkn,dE_En,dtn,Eloss,dI_dN,dE_dN,dI_dtg,dE_dtg,sdsgn] = ...
%  					LCLSopt_fun(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
% 							    dphiv,lamv,s0v,av);
%
%	Function to calculate sensitivities of a 2-stage compressor (see
%	LCLSopt_calc.m)
%
%       Inputs:
%           sz0:	Initial rms bunch length [mm]
%			sd0:	Initial incoh. energy spread at E0 [%]
%       	Eg:	    Beam energy after gun [GeV]
%			Ev:	    Vector of 5 post-linac energies [GeV]
%			R56v:	Vector of 5 R56 values (chicane-R56 < 0) [m]
%			T566v:	Vector of 5 T566 values (always > 0) [m]
%			phiv:	Vector of 5 linac RF phases (-30 deg puts head
%				    energy lower than tail) [degrees]
%			Lv:	    Vector of 5 linac lengths (scales wake) [m]
%			N:	    Bunch population [e.g. 6.25E9]
%			dphiv:	(Optional,DEF=[0 0 0 0]) Vector of 5 linac RF phase
%				    errors originating in that linac (<0 is
%				    early bunch arrival) [deg]
%			lamv:	RF wavelength for each linac (S=0.105m,
%				    X=0.02625m) [m]
%			s0v:	Wakefield characteristic length (S=1.322mm),
%				    X=?mm) [mm]
%			av:	    Mean iris radius
%				    (S=11.654mm,X=4.72mm) [mm]
%			
%	Outputs:
%           szn:	rms bunch length after i-th linac (i=0,1,2,3) [mm]
%			sdn:	rms rel. energy spread after i-th linac (i=0,1,2,3) [%]
%			kn:	    <Ez> correlation const. of i-th linac [1/m]
%			Ipkn:	Peak current at end of i-th linac [A]
%			dE_En:	Relative energy offset after i-th linac [%]
%			dtn:	Timing error at end of i-th linac [psec]
%			Eloss:	Energy loss per linac due to wake [GeV]
%			dI_dN:	Ipk sensitivity to dN/N [A/%]
%			dE_dN:	dE/E sensitivity to dN/N [%/%]
%			dI_dtg:	Ipk sensitivity to dtg [A/psec]
%			dE_dtg:	dE/E sensitivity to dtg [%/psec]
%			sdsgn:	Signed, correlated E-sprd (d-z slope * sigz) [%]

%===============================================================================

dphiv0 = [0 0 0 0 0];
dN_N = 2;
dtg  = 1;
[szn,sdn,kn,Ipkn,dE_En,dtn,Eloss,sdsgn] = LCLSopt_calc(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...%
				      		                           0,0,dphiv0,lamv,s0v,av);     % nominal parameters

[szp,sdp,kp,Ipkp,dE_Ep,dtp] = LCLSopt_calc(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
					                       dN_N,0,dphiv0,lamv,s0v,av);              % vary charge larger
                               
[szm,sdm,km,Ipkm,dE_Em,dtm] = LCLSopt_calc(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
					                       -dN_N,0,dphiv0,lamv,s0v,av);             % vary charge smaller

dI_dN = (Ipkp(5) - Ipkm(5))/2/dN_N;
dE_dN = (dE_Ep(5) - dE_Em(5))/2/dN_N;

[szp,sdp,kp,Ipkp,dE_Ep,dtp] = LCLSopt_calc(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
					                       0,dtg,dphiv0,lamv,s0v,av);               % vary gun dt>0

[szm,sdm,km,Ipkm,dE_Em,dtm] = LCLSopt_calc(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,...
					                       0,-dtg,dphiv0,lamv,s0v,av);              % vary gun dt<0

dI_dtg = (Ipkp(5) - Ipkm(5))/2/dtg;
dE_dtg = (dE_Ep(5) - dE_Em(5))/2/dtg;
