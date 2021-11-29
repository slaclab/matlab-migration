
elossIn=8e6;

% temporal bunch profile 
Ip=3500; % peak current in A
sx=2.5e-6; % rms bunch length in m
s1=-5*sx:1e-7:5*sx;
tProfB=Ip*exp(-(s1/3e8).^2/2/(sx/3e8)^2);

lD=4;
amin=1;amax=4;da=0.1;
eloss=zeros(2,floor((amax-amin)/da));
i=0;
for a=amin:da:amax
  i=i+1;
  % wake Green's function calculation a la Novo
  % a=1; % full gap in mm
  s=0:1e-7:5*sx; % longitudinal vector in m
  wakeGFNovo=1e12*10^5/a^2*exp(-sqrt(10*s/a^2)); %  wake in [V/C/m]

  tmp=conv(tProfB*(s1(2)-s1(1))/3e8,wakeGFNovo); 
  %eloss=mean(tmp(1:length(s1)))
  eloss(:,i)=[a lD*mean(tmp)]; % mean energy loss of dechriper (4 m length)

end

p=polyfit(eloss(2,:),eloss(1,:),10);
yfit=polyval(p,eloss(2,:));

gapOut=polyval(p,elossIn)



plot(eloss(2,:),eloss(1,:))
hold on
plot(eloss(2,:),yfit,'r')
hold off



