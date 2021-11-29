function Omat = fbMatrixElementFull()
%
%
params = getappdata(0,'tempParams');

% configurable inputs, from the config structure
N      = params.N;		                % bunch population [ppb]
sz0    = params.Sz0;	                    % initial rms bunch length at gun exit (uniform dist.) [mm]
sd0    = params.Sd0;	                    % initial uncorrelated rms rel. E-sprd. at gun exit [%]
Eg     = params.Eg;	                    % energy at gun exit [GeV]
Ev     = params.Ev;       	            % linac final energies [GeV]
R56v   = params.R56v;             	    % R56 values (<0 compresses with phi1<0) [m]
T566v  = params.T566v;                	% T566 values (<0 compresses with phi1<0) [m]
phiv   = params.phiv;         	        % linac RF phase (phi<0 compresses, with head lower E than tail) [deg]

% 
f0       = 120;                                         % rep rate [Hz]
n_pulses = 300;
lamS   = 2.99792458E8/2856E6;			                % S-band RF wavelength [m]
lamv   = [lamS lamS lamS/4 lamS lamS];			        % rf wavelength [m]
s0v    = [1.32 1.32 0.77 1.32 1.32];			        % characteristic wakefield-length [mm]
av     = [11.6 11.6 4.72 11.6 11.6];			        % mean iris radius [mm]
Lv     = [6.1 8.8 0.6 329 553];				            % active length of each linac (scales wake) [m]
nstage = 5;

% Let us find the matrix first. We will use fbDoubleCompress to get it
% numerically.

eps = 1e-08;
%isig = 5;
%ires = 5;
iv = 1;

dN_N0  = 0.;
dtg0   = 0.;
dphiv0 = [0. 0. 0. 0. 0.];
dV_Vv0 = [0. 0. 0. 0. 0.];
dN_Nj  = 0.;
dtgj   = 0.;
dphivj = [0. 0. 0. 0. 0.];
dV_Vvj = [0. 0. 0. 0. 0.];

[sz00,sd00,k00,Ipk00,dE_E00,dt00,Eloss00,sdsgn00] = ...
  fbDoubleCompress(sz0,sd0,Eg,Ev,R56v,T566v,phiv,Lv,N,dN_N0,dtg0,dphiv0,dV_Vv0,lamv,s0v,av);
sz=zeros(5);sd=zeros(5);k=zeros(5);Ipk=zeros(5);dE_E=zeros(5);dt=zeros(5);Eloss=zeros(5);sdsgn=zeros(5);

Mmat = zeros(2*nstage,2*nstage);

double(Mmat);

for isig = 1:nstage
    for ires = isig:nstage
        for iv = 1:2
            dV_Vvj = [0 0 0 0 0];
            dphivj = [0 0 0 0 0];
            if ( iv == 1)
                dV_Vvj(isig) = eps;
                [sz,sd,k,Ipk,dE_E,dt,Eloss,sdsgn] = ...
                    fbDoubleCompress(sz0,sd0,Eg,Ev,R56v,T566v,...
                    phiv,Lv,N,dN_Nj,dtgj,dphivj,dV_Vvj,lamv,s0v,av);
                dI_I = Ipk(ires)/Ipk00(ires) - 1;
    
                Mmat(2*ires-1,2*isig-1) = dE_E(ires)/dV_Vvj(isig)/100;
                Mmat(2*ires,2*isig-1)   = dI_I/dV_Vvj(isig);

            else
                dphivj(isig) = eps;
                [sz,sd,k,Ipk,dE_E,dt,Eloss,sdsgn] = ...
                    fbDoubleCompress(sz0,sd0,Eg,Ev,R56v,T566v,...
                    phiv,Lv,N,dN_Nj,dtgj,dphivj,dV_Vvj,lamv,s0v,av);
                dI_I = Ipk(ires)/Ipk00(ires) - 1;

                Mmat(2*ires-1,2*isig) = dE_E(ires)/dphivj(isig)/100;
                Mmat(2*ires,2*isig)   = dI_I/dphivj(isig);
            end
            iv = iv + 1;
        end
    end
end

format long e
Mmat;
%transpose(M)
Nmat = [Mmat(1,:);Mmat(5,:);Mmat(6,:);Mmat(7,:);Mmat(8,:);Mmat(9,:)];
Omat = [Nmat(:,1),Nmat(:,3),Nmat(:,4),Nmat(:,7),Nmat(:,8),Nmat(:,10)];
%Omat = Omatp*[1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 -1 0 0 0;...
%        0 0 0 1 0 0; 0 0 0 0 -1 0; 0 0 0 0 0 -1];

double(Mmat);
double(Nmat);
double(Omat);

%Omat