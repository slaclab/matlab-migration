function [thet,gam] = load_bucket(n,gbar,delg,iopt,Ns)

%c       Load thet & gam (longitudinal phase space)
%c       iopt = 4  = > uniform in theta, Fawley beamlet for seeded
%c       iopt = 5  = > Shot noise start (Penman algorithm, Fawley beamlet)

nmax = 10000;
if(n>nmax)
  error('increase nmax, subr load')
end
if(iopt==4)
  M=4;  % number of particles in each beamlet
  nb= round(n/M); % number of beamlet via Fawley between 64 to 256 (x16=1024 to 4096)
  if(M*nb~=n)
	error('n must be a multiple of 4')
  end
  for i=1:nb
    gamma=delg*randn(1)+gbar;
      for j=1:M
         gam((i-1)*M+j)=gamma;
         thet((i-1)*M+j)=2*pi*j/M;
      end
  end
%  tag = 'uniform in theta, gaussian in gamma';
elseif(iopt==5)
  M=4;  % number of particles in each beamlet
  nb= round(n/M); % number of beamlet via Fawley between 64 to 256 (x16=1024 to 4096)
  if(M*nb~=n)
	error('n must be a multiple of 4')
  end
  effnoise = sqrt(3*M/(Ns/nb));	% Penman algorithm for Ns/nb >> M
  for i=1:nb
    gamma=delg*randn(1)+gbar;
      for j=1:M
         gam((i-1)*M+j)=gamma;
         thet((i-1)*M+j)=2*pi*j/M+2*rand(1)*effnoise;
      end
  end
%  for j = 1:n
%	gam(j) = gbar+delg*randn(1);
%	thet(j) = 2*pi*j/n + 2*rand(1)*effnoise;
%  end
%  tag = 'Shot Noise in theta, gaussian in gamma';
end
