function xtcav_get_und_entrance(inputFile)
%remove the undulator chamber resistive wall wake loss
% the input file is the TREX-SAMPLE images 
% get the current profile to calculate the wake loss
% convert to pixels and do circshift
% plot the after and before images


%%

% Prompt into this month’s data folder if no filename:
if nargin < 1
    t = now;
    baseDir = ['/u1/lcls/matlab/data/' datestr(t,'yyyy') '/' datestr(t,'yyyy-mm') '/'];
    [filen baseDir] = uigetfile([baseDir 'TREX-Sample*.mat'],'Load Sample file');
    if ~filen
        return
    end
    inputFile = [baseDir filen];
end
%

%% get current profile and calculate the wake loss in real units
load(inputFile); %('TREX-Sample-2014-12-16-132556.mat');
%data=trex.bslData(1);
% get the current profile with real unit, bunch head on the left (smaller side)

if data.streak < 0
   data.img = fliplr(data.img);
   data.streak = -1* data.streak;
end
imageSize = size(data.img);
s_px = [1:imageSize(2)]; %current profile s axis in px
px2fs = data.px2um ./data.streak; % px to fs (data.streak is um/f)
s_m = s_px * px2fs * 0.3 * 1e-6; % current profile s axis in meter  (data.streak is um/fs)
current = sum(data.img) * data.charge / (abs(px2fs) * 1e-15) /sum(sum(data.img));  % Eloss per meter in MeV/m

Eloss_per_m = und_rw_wake_forTREX(s_m,current',0)/1e6; % unit: MeV/m

% figure(200)
% plot((s_m-mean(s_m))*1e6,Eloss_per_m)
% xlabel('s (um)'); ylabel('Eloss (MeV_m)')
% figure(201)
% plot((s_m-mean(s_m))*1e6,current)
% xlabel('s (um)'); ylabel('current (A)')
%return

%% convert eloss from MeV to px, apply the shift


Eloss_per_m_in_px =  Eloss_per_m ./ data.mean_erg * data.dispersion ./ data.px2um ; % convert the Eloss to px

und_length = 130; % 130m
Eloss_undL = round( Eloss_per_m_in_px * und_length ); % total loss in undulator length, in px

% circshift the image
new_image = zeros(imageSize);
for ss = 1:imageSize(2)
    new_image(:,ss) = circshift(data.img(:,ss),Eloss_undL(ss));
end

axis_fs = (s_m - mean(s_m)) ./ 0.3e-6; % time dimension in fs
axis_erg = -1*([1:imageSize(1)] - mean([1:imageSize(1)])) .*data.px2um ./ data.dispersion * data.mean_erg;

figure
subplot(2,2,1)
imagesc(axis_fs,axis_erg,data.img)
% colormap(trex_colorMap)
titname = ['Measured at OTRDMP:' inputFile(length(inputFile)-20:end-4)]
 title(titname)
 xlabel('time (fs)'); ylabel('energy deviation (MeV)')
 enhance_plot()
 set(gca,'YDir','normal')
 
subplot(2,2,2)
imagesc(axis_fs,axis_erg,new_image)
% colormap(trex_colorMap)
titnamer = ['at und entrance:' inputFile(length(inputFile)-20:end-4)]
 title(titnamer)
  xlabel('time (fs)'); ylabel('energy deviation (MeV)')
 enhance_plot()
 set(gca,'YDir','normal')

 subplot(2,2,4)
 plot(axis_fs,current)
 xlim([min(axis_fs) max(axis_fs)])
 xlabel('time (fs)'); ylabel('current (A)')
 grid on
  enhance_plot()
 subplot(2,2,3)
 plot(axis_fs,Eloss_per_m*und_length)
  xlim([min(axis_fs) max(axis_fs)])
  xlabel('time (fs)'); ylabel('wake loss (MeV))') 
   enhance_plot()
   grid on

%% the und_rw_wake_forTREX() function

function Ez = und_rw_wake_forTREX(zs,Ipk,shiftDC)
%	to calculate rw_wake for LCLS undulator chamber, Al, rectangle, 5mm gap
%	are hardcoded. 
%   a current profile [z(m) current (A)] will be read, with bunch head on the left (from originally elegant2current used for Genwake by Sven).
%   output will be saved in outputFile.
% shiftDC=1 means to remove the offset, which could be tapered on the real
% machine.
% genesis_rw_wake('undcur.dat','LCLSwake.dat',1/0)

sig  = 3.5e7;  % Al: 'Conductivity (ohm-1*m-1)'
tau  = 8e-15;      % Al: relaxation time
rf   =  1;              % rf=1: rectangle chamber: rf=0: round chamber    
r    =2.5;             % mm, chamber radius 

c  = 2.99792458E8;
Z0 = 120*pi;

%[zs Ipk] = textread(currentFile,'%f %f','delimiter',' ');
Q=integrate(zs/c,Ipk);
r  = r*1E-3;
s0 = (2*r^2/(Z0*sig))^(1/3);

f = Ipk/integrate(zs,Ipk);

s = zs - zs(1);
w = rw_wakefield(s,r,s0,tau,rf);

n = length(s);
E = zeros(n,n);
for j = 1:n
  for i = 1:n
    if i==j
      break
    else
      E(i,j) = w(j-i)*f(i);
    end
  end
end

dz = mean(diff(zs));
Ez = Q*sum(E)*dz; % eV/m/

Ez_mean = integrate(zs,f'.*Ez);
Ez_rms  = sqrt(integrate(zs,f'.*(Ez-Ez_mean).^2));
%Ez_rmsg = 100*rw_esprd(E0/1E9,Ne/1E10,L,r,sigz*1E6,sig);

%zs=max(zs)-zs;
%zs=flipud(zs);
%Ez=flipud(Ez');
%Ipk=flipud(Ipk);

if (shiftDC==1)
    Ez = Ez-Ez_mean;
end


%tstr = ['AC Resistive-Wall Wake ({\it\tau} = ' sprintf('%4.1f',tau*1E15) ' fs, {\it\sigma_c} = ' sprintf('%4.2f',sig/1E7) '\times10^7' ...
%         ' /\Omega/m, {\itr} = ' sprintf('%4.1f',r*1E3) ' mm'];


% figure(11)
% plot(zs*1E6,Ez)
% xlabel('{\itz} (\mum)'); ylabel('Eloss (eV/m)')
% figure(12)
% plot(zs*1E6,Ipk/1E3)
% xlabel('\mum'); ylabel('kA');
% 
% if (shiftDC==1)
% figure(13)
% plot(zs*1E6,Ez+Ez_mean)
% xlabel('{\itz} (\mum)'); ylabel('Eloss (eV/m)')
% figure(12)
% plot(zs*1E6,Ipk/1E3)
% xlabel('\mum'); ylabel('kA');
% end


function s = integrate(x,y,x1,x2)

%       s = integrate(x,y[,x1,x2]);
%
%       Approximate the integral of the function y(x) over x from x1 to 
%       x2.  The limits of integration are given by the optional inputs
%       x1 and x2.  If they are not given the integration will range from
%       x(1) to x(length(x)) (i.e. the whole range of the vector x).
%
%     INPUTS:   x:      The variable to integrate over (row or column
%                       vector of sequential data points)
%               y:      The function to integrate (row or column vector)
%               x1:     (Optional,DEF=x(1)) The integration starting point
%               x2:     (Optional,DEF=x(n)) The integration ending point

%===============================================================================

if any(diff(x)<0);
  error('x must be sequentially ordered data')
end
  
x = x(:);
y = y(:);

[ny,cy] = size(y);
[nx,cx] = size(x);

if (cx > 1) | (cy > 1)
  error('INTEGRATE only works for vectors')
end
if nx ~= ny
  error('Vectors must be the same length')
end

if ~exist('x2')
  i2 = nx;
  if ~exist('x1')
    i1 = 1;
  else
    [dum,i1] = min(abs(x-x1));
  end
else
  [dum,i1] = min(abs(x-x1));
  [dum,i2] = min(abs(x-x2));
end

dx = diff(x(i1:i2));
s = sum(dx.*y(i1:(i2-1)));



