function [Lg,L1d,Psat,rho,Lr,Ipk,sigx,lamr,Nphot,Ephot] = sase_fel(E0,K,Q,sigZ,emitN,beta,esprd,lamu);

%	[Lg,L1d,Psat,rho,Lr,Ipk,sigx,lamr,Nphot,Ephot] = sase_fel(E0,K,Q,sigZ,emitN,beta,esprd,lamu);
%
%	SASE FEL Ming Xie formula to approximate the 3D gain length of a SASE FEL.
%
%    INPUTS:	E0:	    The electron beam energy [GeV]
%		        K:	    The undulator parameter [ ]
%		        Q:	    The bunch charge [C]
%		        sigZ:	The rms e- bunch length (uniform dist. assumed) [m]
%		        emitN:	The rms normalized transverse emittance (ex=ey) [m]
%		        beta:	The mean beta function in the undulator (assumed ~constant) [m]
%		        esprd:	The rms relative energy spread [unitless, e.g. 1E-4]
%		        lamu:	The undulator perdiod [m]
%
%    OUTPUTS:	Lg:	    The 3D gain length [m]
%		        L1d:	The 1D gain length (Lg >= L1d) [m]
%		        Psat:	Estimated saturation power [GW]
%		        rho:	FEL parameter [ ]
%		        Lr:	    Rayleigh range [m]
%		        Ipk:	Peak current of e- beam for uniform z-dist. [A]
%		        sigx:	rms transverse beam size (x=sy, assumed ~constant) [m]
%		        lamr:	Radiation wavelength [m]
%				Nphot:	Number of photons at saturation with "lamr" wavelength [ ]
%				Ephot:	Photon energy [eV]

%======================================================================================

c    = 2.99792458E8;	    % m/s
re   = 2.81794092e-15;	    % m
e    = 1.60217733E-19;	    % C
mc2  = 510.99906E-6;	    % GeV
h    = 4.13566733E-15;      % eV-s

IA   = e*c/re;		        % Amps
Ipk  = Q*c/sqrt(12)/sigZ;	% Amps
gam0 = E0/mc2;
emit = emitN/gam0;
sigx = sqrt(beta*emit);
lamr = lamu*(1 + K^2/2)/2/gam0^2;
aw   = K/sqrt(2);
zeta = aw^2/2/(1+aw^2);
J0   = besselj(0,zeta);
J1   = besselj(1,zeta);
Aw   = aw*(J0 - J1);
rho  = (Ipk/IA*(lamu*Aw/2/pi/sigx)^2*(1/2/gam0)^3)^(1/3);
L1d  = lamu/4/pi/sqrt(3)/rho;
Lr   = 4*pi*sigx^2/lamr;
etad = L1d/Lr;
etae = (L1d/beta)*(4*pi*emit/lamr);
etag = 4*pi*(L1d/lamu)*esprd;

a    = [0.45 0.57 0.55 1.6 3.0 2.0 0.35 2.9 2.4 51. 0.95 3.0 5.4 0.7 1.9 1140 2.2 2.9 3.2];
eta  = a(1)*etad^a(2) + a(3)*etae^a(4) + a(5)*etag^a(6) + ...
       a(7)*etae^a(8)*etag^a(9) + a(10)*etad^a(11)*etag^a(12) + a(13)*etad^a(14)*etae^a(15) + ...
       a(16)*etad^a(17)*etae^a(18)*etag^a(19);

Lg    = L1d*(1+eta);                % m
Pbeam = E0*Ipk;					    % GW
Psat  = 1.6*rho*(L1d/Lg)^2*Pbeam;	% GW
Ephot = h*c/lamr;                   % eV
Nphot = Psat*1E9*sigZ*sqrt(12)/c/Ephot/e;
