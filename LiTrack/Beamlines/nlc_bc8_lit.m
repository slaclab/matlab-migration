% 'G'=gausian, 'U'=uniform, string.zd=name of file with z(mm) and dE/E(%) (see e.g. "atf1.zd"):
% ============================================================================================
%inp = 'lcls_145.zd';	% name of file with 2-columns [Z/mm dE/E/%] (sigz and sigd not used in this case)
inp = 'G';		% gaussian Z and dE/E (see sigz0 =..., sigd0 =...)
%inp = 'U';		% uniform  Z and dE/E (see sigz0 =..., sigd0 =...[note: FW = sig*sqrt(12)]

% The folowing items only used when "inp" = 'G' or 'U' (i.e. used when no particle coordinate file is read)
% ========================================================================================================
sigz0 = 5.000E-3;	% rms bunch length used when inp=G or U above [m]
sigd0 = 0.100E-2;	% rms relative energy spread used when inp=G or U above [ ]
Nesim = 40000;		% number of particles to generate for simulation when inp=G or U (reasonable: ~1000 to ~100000)
% ========================================================================================================

E0     = 1.98;		% initial electron energy [GeV]
Ne     = 0.75E10;	% number of particles initially in bunch
z0_bar = 0.000E-3;	% axial offset of bunch [m] (used also with file input - mean of file removed first)
d0_bar = 0.000E-2;	% relative energy offset of bunch [ ]  (used also with file input - mean of file removed first)
Nbin   = 100;		% number of bins for z-coordinate (and dE/E for plots)
gzfit   = 0;		% if ==1: fit Z-distribution to gaussian (defaults to no-fit if 'gzfit' not provided)
gdfit   = 0;		% if ==1: fit dE/E-distribution to gaussian (defaults to no-fit if 'gdfit' not provided)

comment = 'NLC Bunch Compressor System (3/10/99)';	% text comment which appears at bottom of plots

% CODES:       |
%	       |	1		2		3		4		5		6
%==============|==============================================================================================
% compressor   |    code= 6           R56/m          T566/m          E_nom/GeV          -               -
% acceleration |    code=11     dEacc(phi=0)/GeV    phase/deg        lambda/m   wake(ON=1,2**/OFF=0)  Length/m
% E-spread add |    code=22          rms_dE/E           -               -               -               -
% E-window cut |    code=25         dE/E_window         -               -               -               -
% E-cut limits |    code=26          dE/E_min        dE/E_max           -               -               -
% Z-cut limits |    code=36            Z_min           Z_max           	-               -               -
% STOP	       |    code=99             -               -               -               -               -
%=============================================================================================================
beamline = [
		     	11	      	0.00000      	-90.000		0.2100		0	   	0.01
		     	11	      	0.13900      	-90.000		0.2100		0	   	16.0
		      	6        	-0.4800		0.72000       	1.9800    	0           	0
                        11	      	6.07080      	-4.5000		0.1050		1	   	354
		      	6        	+0.3100        	0.5890        	8.0000		0           	0
		     	22	      	4.10E-5		0	       	0		0		0
		     	11	      	0.50000	    	-100.60	     	0.0262		2	   	10.0
		     	26	      	-0.0400 	0.04000	      	0		0		0
		     	6         	-0.0550        	0.0825       	7.9155     	0     		0
		     	22	      	1.10E-5		0	        0		0		0
		     	11	      	527.100	    	-20.000	      	0.0262		2	   	10400.
		     	-25	      	0.02000 	0		0		0		0
    			99		0		0		0		0		0
                                                                                                                  ];
% Sign conventions used:
% =====================
%
% phase = 0 is beam on accelerating peak of RF (crest)
% phase < 0 is beam ahead of crest (i.e. bunch-head sees lower RF voltage than tail)
% The bunch head is at smaller values of z than the tail (i.e. head toward z<0)
% With these conventions, the R56 of a chicane is < 0 (and R56>0 for a FODO-arc) - note T566>0 for both
% 
% * = Note, the Energy-window cut (25-code) floats the center of the given FW window in order center it
%     on the most dense region (i.e. maximum number of particles).
% **  1:=1st wake file (e.g. S-band) is used, 2:=2nd wake file (e.g. X-band)