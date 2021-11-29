function [datan] = GDET_wf(ij,prt);
%function [datan] = GDET_wf(ij,prt);
%
% GDET_wf gets the GDET raw waveform readings and makes a display
% 
% ij = number of samples OR 120 when empty
% anything as prt will save and print figure(10) e.g. ... (600,'p')
%
% e.g.:   [data] = GDET_wf(600);

prtt = 1;
if ~exist('prt','var')
  prtt = 0;
else
  prtt = prt;
end

if ~exist('ij','var')
  ij = 120;
prtt = 1;
if ~exist('prt','var')
  prtt = 0;
else
  prtt = prt;
end

if ~exist('ij','var')
  ij = 100;
end

0;
end


SXR_NOTE ='MEC:QADC:01:OUT';
 
 pvGDET={'DIAG:FEE1:202:241:Data'
     'DIAG:FEE1:202:242:Data'
     %SXR_NOTE
     };
  pvGDET ={'DIAG:FEE1:202:241:Data'
     'DIAG:FEE1:202:242:Data'
     'DIAG:FEE1:202:361:Data'
     'DIAG:FEE1:202:362:Data'
  %   'DIAG:FEE1:202:363:Data'
  %   'DIAG:FEE1:202:364:Data'
     };
path(path,'/home/physics/decker/matlab/toolbox')

Eph=round(lcaGet('SIOC:SYS0:ML00:AO627'));
% pvGDET={'DIAG:FEE1:202:241:Data'}; 
gg = 1;

[gg,t,dt,n,nk] = get_wf(pvGDET,ij);
[i1 i2 i3]=size(gg);
i30=i3;
i512=i2;  
i280=i2;
gg1=reshape(gg(1,:,:),i512,i30);
%[gdetect,ng]=find(min(gg1(200,:))<28500);
gdetect=min(gg1(200,:));
gd0=(28800-1264)/28800*0.8;

%for ik=1:100
%    [gg,t,dt,n,nk] = get_wf(pvGDET,60);
%    gg1=reshape(gg(1,:,:),i512,i30);
%    gdetect=min(gg1(200,:));
%    gd(ik)=(28800-gdetect)/28800*0.8;
%    
%    plot(gd)
%    pause(0.2)
%end
myclock=clock;
t_stamp =datestr(myclock);

figure(10)
plot(gg1)
grid
%axis([150 350 -3.3E4  3E4])
plotfj18 
ming = min(min(gg1));
mingg= floor(ming/1000)*1000;
axis([150 350 mingg  3E4])
xlabel('Time [ns]')
ylabel('Intensity')
title(['GDET Waveform E = ' num2str(Eph) ' eV'])
text('FontSize',12,'Position', [350 mingg-(30000-mingg)*0.12],'HorizontalAlignment','right', 'String', t_stamp);

datan.gg = gg ;
datan.t = t ;
datan.dt = dt ;
datan.n = n ;
datan.nk = nk ;
datan.Eph = Eph;
datan.t_stamp = t_stamp;
if prtt == 1
     util_printLog(10,'author', 'Decker (from matlab)','title',['GDET Waveform at ' num2str(Eph) ' eV'])
     fileName=util_dataSave(datan,'GDET','1',myclock);
end

% To look at data after save:
% load /u1/lcls/matlab/data/2021/2021-02/2021-02-19/GDET-1-2021-02-19-060937.mat;
% gg = data.gg;
% t_stamp = data.t_stamp
% Eph = data.Eph;
% get_wf_an14
% and then copy paste the block after figure(10) above 
