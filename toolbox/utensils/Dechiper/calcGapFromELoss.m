function gapOut=calcGapFromELoss(elossIn,Ip,sx,shape)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calc the gap of the dechirper for a given elenrgy loss peak current and
% bunch length. Assumption is a Greens function from A. Novokhatski:
%
% GF_Wl(s)[V/pC/m]= 10^5/a^2[mm]*exp(-sqrt(10*s/a^2[mm])) ,
%
% a=full gap of decgirper 
%
%
% input: 
%    elossIn:    energy loss in eV
%    Ip:         peak current in A
%    sx:         rms bunch length in m
%    shape:      gaussian == 1 or flattop == 2
%
% output:
%    gap:       gap size of the dechirper in mm
%
% author: jzemella, 2015-07-21
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  debugFlg=0;

  %elossIn=8e6;
  % temporal bunch profile 
  %Ip=3500; % peak current in A
  %sx=2.5e-6; % rms bunch length in m
  s1=-5*sx:1e-7:5*sx;
  if shape == 1
    tProfB=Ip*exp(-(s1/3e8).^2/2/(sx/3e8)^2);
  elseif shape == 2
    tProfB=zeros(1,length(s1));
    inds=abs(s1)<sx;
    tProfB(inds)=Ip;
  end
  
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
    eloss(:,i)=[a lD*mean(tmp)]; % mean energy loss of dechriper (4 m length)
  end

  p=polyfit(eloss(2,:),eloss(1,:),10);
  yfit=polyval(p,eloss(2,:));

  gapOut=polyval(p,elossIn);

  if debugFlg ==1 
    plot(eloss(2,:),eloss(1,:))
    hold on
    plot(eloss(2,:),yfit,'r')
    hold off
  end
  
end



