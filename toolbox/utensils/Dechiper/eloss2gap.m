function [out,err]=eloss2gap(dechirper,modeGap,gap) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculates the gap from wanted energy loss for the bunch
% 
% input:
%   dechirper:
%     fatch:         fatch factor for elaoss to gap calc
%     chirp:         eloss of the bunch for eloss to gap calc
%     mode:          mode for eloss to gap calc
%       ==1 => constant wake potential with strength of W_l=Pi/16*Z0*c0/a^2 
%       ==2 => wake Greens' fcn with GF_Wl(s)[V/pC/m]= 10^5/a^2[mm]*exp(-sqrt(10*s/a^2[mm]))
%     readPV:
%       charge:      rbv PV bunch charge
%       current:     rbv PV bunch peak current
%       bunchlength: rbv PV bunch length
%   modeGap:         switch for eloss to gap or gap to eloss
%          1 => eloss to gap
%          2 => gap to eloss
%
% output:  
%    out:     gap for given energy loss (MeV) or energy loss for given gap (mm)
%    err:     error massage
%  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  err='';
  Z0=377; % Ohms vacuum impedance
  c0=3e8; % m/s speed of light in vacuum
  lD=2;   % length of dechirper
  
  
  eloss=dechirper.chirp.val*1e6;
%   gap=dechirper.gap.val;
  modeCalc=get(dechirper.mode, 'Value');
  fatch=1;
    
  lBunchPV=dechirper.readPV.bunchlength;  % bunch length measurement PV
  iBunchPV=dechirper.readPV.current;      % bunch current measurement PV
  qBunchPV=dechirper.readPV.charge;      % bunch current measurement PV
  
  switch modeCalc
    case 1,
      charge=lcaGetSmart(qBunchPV);
      
      charge =100e-12;
      
      if modeGap == 1
        a=sqrt((pi^2/16)*(Z0*c0)/(pi*eloss)*(lD*charge));
        out=fatch*2*a*1e3; % to half gap into convert into gap in mm
      elseif modeGap == 2
        out=1e-6/fatch*(pi^2/16)*(Z0*c0)/(pi*(gap/2*1e-3)^2)*(lD*charge);
      end
    case 2
      shape=2;
      lbunch=lcaGetSmart(lBunchPV);
      ibunch=lcaGetSmart(iBunchPV);
      
      lbunch=5e-6;
      ibunch=3500;
      
      if modeGap == 1
        out=fatch*calcGapELoss(eloss,ibunch,lbunch,shape,modeGap);
      elseif modeGap == 2
        out=1e-6/fatch*calcGapELoss(gap,ibunch,lbunch,shape,modeGap);
      end
  end
end



function out=calcGapELoss(In,Ip,sx,shape,mode)
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
%    In:         energy loss in eV or gap in mm
%    Ip:         peak current in A
%    sx:         rms bunch length in m
%    shape:      gaussian == 1 or flattop == 2
%    mode:       switch for eloss2gap or gap2eloss
%           1 => eloss to gap calculation
%           2 => gap to eloss calculation
%
% output:
%    out:       gap size of the dechirper in mm or eloss in eV
%
% author: jzemella, 2015-07-28
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

  warning('off','MATLAB:polyfit:RepeatedPointsOrRescale')
  if mode == 1
     p=polyfit(eloss(2,:),eloss(1,:),10);
     yfit=polyval(p,eloss(2,:));
  elseif mode == 2
    p=polyfit(eloss(1,:),eloss(2,:),10);
    yfit=polyval(p,eloss(1,:));
  end
  
  out=polyval(p,In);

  if debugFlg ==1 
    plot(eloss(2,:),eloss(1,:))
    hold on
    plot(eloss(2,:),yfit,'r')
    hold off
  end
  
end
