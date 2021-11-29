function [z,power_z,s,power_s,rho,gainLength,resWavelength] = sase1d(inp_struc);

%[z,power_z,s,power_s,rho,gainLength,resWavelength] = sase1d(inp_struc);
%
%     One-dimensional sase program using Leap-frog algorithm. (Z. Huang, ~2004. Converted to Matlab: P. Emma, Dec. 2004)
%        further updated by Z. Huang, 2006
%	INPUTS:								% Input Structure:
%		inp_struc.npart					% n-macro-particles per bucket (e.g. 256)
%		inp_struc.s_steps				% n-sample points along bunch length (e.g. 1000)
%		inp_struc.z_steps				% n-sample points along unulator (e.g. 100)
%		inp_struc.energy				% electron energy [MeV]
%		inp_struc.eSpread				% relative rms electron energy spread [ ]
%		inp_struc.emitN					% normalized transverse emittance [mm-mrad]
%		inp_struc.currentMax			% peak current [Ampere]
%		inp_struc.beta					% mean beta [meter]
%		inp_struc.unduPeriod			% undulator period [meter]
%		inp_struc.unduK					% undulator parameter, K [ ]
%		inp_struc.unduL					% length of undulator [meter]
%		inp_struc.radWavelength			% seed wavelength? [meter], used only in single-freuqency runs
%		inp_struc.Eloss					% wake energy loss in units of rho per gain length=lambda_u/(4*ph*rho)
%		inp_struc.P0					% small input power P0 [W]
%
%	OUTPUTS:
%		z								% undulator length coordinate [m]
%		power_z							% average power over bunch at each point along undulator [GW]
%		s								% bunch length coordinate [microns]
%		power_s							% peak power at each point along bunch length [GW]
%       rho:                            % FEL parameter [ ]
%       gainLength:                     % gain length [m]
%       resWavelength:                  % resonant radiation wavelength [m]

%=============================================================================================================

npart			= inp_struc.npart;
s_steps			= inp_struc.s_steps;
z_steps			= inp_struc.z_steps;
energy			= inp_struc.energy;
eSpread			= inp_struc.eSpread;
emitN			= inp_struc.emitN;
currentMax		= inp_struc.currentMax;
beta			= inp_struc.beta;
unduPeriod		= inp_struc.unduPeriod;
unduK			= inp_struc.unduK;
unduL			= inp_struc.unduL;
radWavelength	= inp_struc.radWavelength;
dEdz			= inp_struc.dEdz;
iopt			= inp_struc.iopt;
P0				= inp_struc.P0;
constseed		= inp_struc.constseed;

if constseed==1
  rand('state',0);								% hold constant random seed if requested
  randn('state',0);                             % hold constant random seed if requested
end

alfvenCurrent = 17045.0;
mc2 = 510.99906E-3;
c   = 2.99792458E8;
e   = 1.60217733E-19;

unduJJ  = besselj(0,unduK^2/(4+2*unduK^2))-besselj(1,unduK^2/(4+2*unduK^2));
gamma0  = energy/mc2;							% mean gamma
sigmaX2 = emitN*beta/gamma0;					% sigmaX square
rho     = (0.5/gamma0)*((currentMax/alfvenCurrent)*(unduPeriod*unduK*unduJJ/(2*pi))^2/(2*sigmaX2))^(1/3);
resWavelength = unduPeriod*(1+unduK^2/2.0)/(2*gamma0^2);  % resonant wavelength
rhoPbeam   = rho*energy*currentMax/1000.0;		% rho times beam power [GW]
coopLength = resWavelength/(4*pi*rho);			% cooperation length 
gainLength = unduPeriod/(4*pi*rho);				% rough gain length
%cs0  = bunchLength/coopLength					% bunch length in units of cooperation length     
z0    = unduL/gainLength;						% wiggler length in units of gain length
delt  = z0/z_steps;								% integration step in z0 ~ 0.1 gain length
dels  = delt;									% integration step in s0 must be same as in z0 
a02   = P0*1E-9/rhoPbeam;                     % scaled input power
gbar  = (resWavelength-radWavelength)/(radWavelength*rho);		% scaled detune parameter
delg  = eSpread/rho;							% Gaussian energy spread in units of rho
Ns    = currentMax*unduL/unduPeriod/z_steps*resWavelength/c/e;	% N eelectrons per s-slice [ ]
Eloss = -dEdz*1E-3/energy/rho*gainLength;        % convert dEdz to alpha parameter
s = (1:s_steps)*dels*coopLength*1.0e6; 
z = (1:z_steps)*delt*gainLength;

if(iopt==5)     % sase mode is chosen
%c
%c               go over all slices of the bunch starting from the tail k=1
%c
    for k = 1:s_steps
    ar(k,1) = sqrt(a02);									% input seed signal
    ai(k,1) = 0.0;
    [thet0,gam0] = load_bucket(npart,gbar,delg,iopt,Ns);	% load each bucket
    gam(:,1) = gam0';							% gamma at j=1
    thethalf(:,1) = thet0'-gam(:,1)*delt/2;     % half back
    for j = 1:z_steps                           % evolve e and gamma in s and t by leap-frog
        thet = thethalf(:,j)+gam(:,j)*delt/2;
        sumsin = sum(sin(thet));
        sumcos = sum(cos(thet));
        sinavg = sumsin/npart;
        cosavg = sumcos/npart;
        arhalf = ar(k,j)+cosavg*dels/2;
        aihalf = ai(k,j)-sinavg*dels/2;
        thethalf(:,j+1) = thethalf(:,j)+gam(:,j)*delt;
        gam(:,j+1) = gam(:,j)-2*arhalf*cos(thethalf(:,j+1))*delt...
                    +2*aihalf*sin(thethalf(:,j+1))*delt-Eloss*delt;
        sumsin = sum(sin(thethalf(:,j+1)));
        sumcos = sum(cos(thethalf(:,j+1)));
        sinavg = sumsin/npart;
        cosavg = sumcos/npart;
         ar(k+1,j+1) = ar(k,j)+cosavg*dels;	% apply slippage condition
         ai(k+1,j+1) = ai(k,j)-sinavg*dels;
%         ar(k,j+1) = ar(k,j)+cosavg*dels;	% no slippage
%         ai(k,j+1) = ai(k,j)-sinavg*dels;
    end
end

%for j = 2:z_steps							% time-average power and fluctuations
%c  suma2 = 0.0
%c  sumP2 = 0.0
%c  for k = 1:kinterval:s_steps				% uncorrelated average
%c    suma2 = suma2+(ar(k+1,j)^2+ai(k+1,j)^2)
%c    sumP2 = sumP2+(ar(k+1,j)^2+ai(k+1,j)^2)^2
%c  end
%c  time = s_steps/kinterval;
%c  a2avg(j) = suma2/time
%c  a2sigma(j) = sqrt(sumP2/time-a2avg(j)^2)/a2avg(j)
%  suma2 = 0.0;
%  for k = 1:s_steps
%    suma2 = suma2+(ar(k+1,j)^2+ai(k+1,j)^2);
%  end
%  a2avg(j) = suma2/s_steps;
% end
	
for j = 1:z_steps
    for k = 1:s_steps
%        phase(j,k) = atan2(ai(k+1,j),ar(k+1,j));	% phase between -pi to pi
%        if (k>1)									% unwrap the real phase +-2*n*pi
%    	  while 1
%    		if (abs(phase(j,k)-phase(j,k-1))<pi)
%    		  break
%    		end
%    		if (phase(j,k)>phase(j,k-1))
%    		  phase(j,k) = phase(j,k) - 2*pi;
%    		else
%    		  phase(j,k) = phase(j,k) + 2*pi;
%    		end
%    	  end
%    	end
        power_s(j,k) = (ar(k+1,j)^2+ai(k+1,j)^2)*rhoPbeam;
    end
    power_z(j) = sum(ar(:,j).^2+ai(:,j).^2)/s_steps*rhoPbeam;
    gamavg(j) = sum(gam(:,j+1))/npart;
end
 
else            % seeded mode then
    delth=delt/2.0;
    [thet,gam] = load_bucket(npart,gbar,delg,iopt,Ns);
    ar=sqrt(a02);      % initial seed signal
    ai=0.0;
 
    for j=1:z_steps
    %            first RK step 
        thet1=thet+gam*delth;
        gam1=gam-2*ar*cos(thet)*delth+2*ai*sin(thet)*delth-Eloss*delth;
        sinavg=sum(sin(thet))/npart;
        cosavg=sum(cos(thet))/npart;
        ar1=ar+cosavg*delth;
        ai1=ai-sinavg*delth;
    %            second RK step
        thet2=thet+gam1*delth;
        gam2=gam-2*ar1*cos(thet1)*delth+2*ai1*sin(thet1)*delth-Eloss*delth;
        sinavg=sum(sin(thet1))/npart;
        cosavg=sum(cos(thet1))/npart;
        ar2=ar+cosavg*delth;
        ai2=ai-sinavg*delth;
    %            third RK step
        thet3=thet+gam2*delt;
        gam3=gam-2*ar2*cos(thet2)*delt+2*ai2*sin(thet2)*delt-Eloss*delt;
        sinavg=sum(sin(thet2))/npart;
        cosavg=sum(cos(thet2))/npart;
        ar3=ar+cosavg*delt;
        ai3=ai-sinavg*delt;
    %            fourth RK stfigure(3)
        thet4=thet+gam3*delth;
        gam4=gam-2*ar3*cos(thet3)*delth+2*ai3*sin(thet3)*delth-Eloss*delth;
        sinavg=sum(sin(thet3))/npart;
        cosavg=sum(cos(thet3))/npart;
        ar4=ar+cosavg*delth;
        ai4=ai-sinavg*delth;
    %c            add them up
        thet=thet1/3+thet2*2/3+thet3/3+thet4/3-thet*2/3;    
        gam=gam1/3+gam2*2/3+gam3/3+gam4/3-gam*2/3;
        ar=ar1/3+ar2*2/3+ar3/3+ar4/3-ar*2/3;   %-2/3*ar because already added 5/3*ar
        ai=ai1/3+ai2*2/3+ai3/3+ai4/3-ai*2/3;
    % thet_out and gam_out can be use for longitudinal phase space display 
    %    thet_out(:,j)=thet';
    %    gam_out(:,j)=gam';
    %c           output
        power_z(j)=(ar^2+ai^2)*rhoPbeam;
        power_s(j,:) = power_z(j);
        gamavg(j) = sum(gam)/npart;         % beam power loss
    end
end
   