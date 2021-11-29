function stat=LEM_Display(opCode,graphic)
%
% stat=LEM_Display(opCode,graphic);
%
% Generate LEM displays (graphic or text).
%
% INPUTs:
%
%   opCode  = display selection
%   graphic = display type flag (text=0,graphic=1)
%
%   opCode  graphic  display
%   ------  -------  -----------------------------------------------------------
%      1       1     KLYS Energy
%      2       1     KLYS Phase
%      3       1     Optics Verify
%      4       1     MAGNET Energy [EACT]
%      5       1     MAGNET Energy [EREF]
%      6       1     QUAD BMAG
%      1       0     KLYS Energy
%      2       0     KLYS Phase
%      3       0     Optics Verify
%      4       0     MAGNET Energy
%      5       0     MAGNET BDES
%      6       0     PS BDES
%      7       0     QUAD BMAG
%
% OUTPUT:
%
%   stat = completion status

% ------------------------------------------------------------------------------
% 31-MAR-2009, M. Woodley
%    Use design values (computed at LEM initialization) for quadrupole Bmag
%    displays
% 09-FEB-2009, M. Woodley
%    Reference BMAG values to 1.0
% 21-JAN-2009, M. Woodley
%    Add Gun energy to KLYS Energy display and KLYS Energy values
% 16-JAN-2009, M. Woodley
%    Add "QUAD BMAG Display" and "QUAD BMAG Values"
% 07-JAN-2009, M. Woodley
%   Include ACTIVATED/DEACTIVATED status when displaying KLYS ampl's;
%   Optics Verify energy error tolerance is 0.005 relative (not absolute);
%   use "sector number" value (rather than S) for KLYS displays
% ------------------------------------------------------------------------------

global lemRegions lemGroups
global theAccelerator
global KLYS MAGNET PS
global lemDataTime
global lemEref noFudgeCalc

klysDisplay=[1,2]; % energy,phase
Etol=0.005; % Optics Verify relative energy error tolerance (1)
green=[0,0.6,0.2]; % in-tolerance color
GeV2MeV=1e3; % MeV per GeV

% KLYS displays are not available if noFudgeCalc=1

if (ismember(opCode,klysDisplay))
  if (noFudgeCalc)
    disp('*** Linac energy profile was not generated')
    stat=1;
    return
  end
end

% check for old data ... provide abort option

stat=LEM_Prompt(1);
if (~stat),return,end

% prepare data

if (ismember(opCode,klysDisplay))

% get length and S-display for Bnch elements

  allBnch=theAccelerator.getAllNodesOfType('Bnch');
  Nbnch=allBnch.size;
  bnchName=cell(Nbnch,1);
  bnchL=zeros(Nbnch,1);
  bnchSd=zeros(Nbnch,1);
  for n=1:Nbnch
    bnch=allBnch.get(n-1);
    bnchName(n)={char(bnch.getId)};
    bnchL(n)=bnch.getLength;
    bnchSd(n)=bnch.getSDisplay;
  end

% get S-display for the Gun

  node=theAccelerator.getNodeWithId('CATHODE');
  Sd0=node.getSDisplay;

% get S-display for KLYS elements

  Nklys=length(KLYS);
  Sd=zeros(Nklys,1);
  for n=1:Nklys
    id=strmatch(KLYS(n).name,bnchName);
    bnchBeg=bnchSd(id(1))-bnchL(id(1))/2;
    bnchEnd=bnchSd(id(end))+bnchL(id(end))/2;
    Sd(n)=mean([bnchBeg,bnchEnd]); % center
  end

% generate pseudo "sector number" values

  Ss0=1+Sd0/101.6;
  Ss=1+Sd/101.6;

% data values

  E0=lemEref(1); % GeV (Gun)
  egain0=GeV2MeV*E0; % MeV (Gun)
  egain=GeV2MeV*[KLYS.egain]'; % MeV
  E=(egain0+cumsum(egain))/GeV2MeV; % GeV
  phase=reshape([KLYS.phas],2,[])'; % KLYS,SBST (deg)
else

% get S-display for magnets

  Nmgnt=length(MAGNET);
  Sd=zeros(Nmgnt,1);
  for n=1:Nmgnt
    node=theAccelerator.getNodeWithId(MAGNET(n).name);
    Sd(n)=node.getSDisplay;
  end

% data values

  E0=[MAGNET.energy0]'; % GeV
  E=[MAGNET.energy]'; % GeV
  dEabs=1e3*(E-E0); % MeV
  dErel=(E-E0)./E0; % 1
  mtype=[MAGNET.type]'; % magnet types

  kl0=[MAGNET.design_kl]';
  kl=[MAGNET.kl]';
  betax0=[MAGNET.design_betax]';
  betay0=[MAGNET.design_betay]';
  BmagX=1+0.5*betax0.^2.*(kl-kl0).^2;
  BmagY=1+0.5*betay0.^2.*(kl-kl0).^2;

% get pointers to those magnets that are selected for scaling

  id1=find([MAGNET.scaleFlag]'==1); % scalable
  id2=find(ismember([MAGNET.region]',find(lemRegions))); % in selected region
  id3=find(ismember([MAGNET.scaleGroup]',find(lemGroups))); % in selected group
  idLEM=intersect(intersect(id1,id2),id3); % congratulations ... you've made the list!
end

% generate the display

if (graphic)
  figure(2) % LEM graphic always displays in Figure 2
  clf
  subplot
  switch opCode
    case 1 % KLYS Energy display
      subplot(211)
      stem([Ss0;Ss],[egain0;egain],'b.-')
      set(gca,'XLim',[20,31],'XTick',20:30,'XGrid','on')
      title('LEM KLYSTRON ENERGY [EACT]')
      ylabel('Egain (MeV)')
      subplot(212)
      stem([Ss0;Ss],[E0;E],'b.-')
      set(gca,'XLim',[20,31],'XTick',20:30,'XGrid','on')
      ht=title(['Data Collected: ',datestr(lemDataTime)]);
      set(ht,'FontSize',10,'Units','normalized')
      p=get(ht,'Position');p(2)=1;set(ht,'Position',p)
      ylabel('Sum (GeV)')
      xlabel('Sector Number')
    case 2 % KLYS Phase display
      subplot(211)
      stem(Ss,phase(:,1),'b.-')
      set(gca,'XLim',[20,31],'XTick',20:30,'XGrid','on')
      title('LEM KLYSTRON AND SUBBOOSTER PHASE (deg)')
      ylabel('KLYS')
      subplot(212)
      stem(Ss,phase(:,2),'b.-')
      set(gca,'XLim',[20,31],'XTick',20:30,'XGrid','on')
      ht=title(['Data Collected: ',datestr(lemDataTime)]);
      set(ht,'FontSize',10,'Units','normalized')
      p=get(ht,'Position');p(2)=1;set(ht,'Position',p)
      ylabel('SBST')
      xlabel('Sector Number')
    case 3 % Optics Verify display
      subplot(311)
      id=intersect(find(mtype==3),idLEM); % QUADs
      idg=intersect(find(abs(dErel)<Etol),id); % in-tolerance
      idr=intersect(find(abs(dErel)>=Etol),id); % out-of-tolerance
      if (~isempty(idg))
        stem(Sd(idg),dEabs(idg),'.-','Color',green)
        hold on
      end
      if (~isempty(idr))
        stem(Sd(idr),dEabs(idr),'r.-')
      end
      hold off
      ylabel('QUAD')
      XLim=get(gca,'XLim');
      title('LEM OPTICS VERIFY [EACT-EREF] (MeV)')
      subplot(312)
      id=intersect(find((mtype==1)|(mtype==2)|(mtype==4)),idLEM); % XBENDs,YBENDs,SOLEs
      if (isempty(id))
        plot(0,'w')
        axis([XLim,-1,1])
        set(gca,'YTick',[])
        text(mean(XLim),0,'No BENDs or SOLEs selected', ...
          'HorizontalAlignment','center','VerticalAlignment','middle')
      else
        idg=intersect(find(abs(dErel)<Etol),id); % in-tolerance
        idr=intersect(find(abs(dErel)>=Etol),id); % out-of-tolerance
        if (~isempty(idg))
          stem(Sd(idg),dEabs(idg),'.-','Color',green)
          hold on
        end
        if (~isempty(idr))
          stem(Sd(idr),dEabs(idr),'r.-')
        end
        hold off
        ylabel('BEND/SOLE')
        set(gca,'XLim',XLim);
      end
      ht=title(['Data Collected: ',datestr(lemDataTime)]);
      set(ht,'FontSize',10,'Units','normalized')
      p=get(ht,'Position');p(2)=1;set(ht,'Position',p)
      subplot(313)
      id=intersect(find((mtype==5)|(mtype==6)),idLEM); % XCORs,YCORs
      if (isempty(id))
        plot(0,'w')
        axis([XLim,-1,1])
        set(gca,'YTick',[])
        text(mean(XLim),0,'No XCORs or YCORs selected', ...
          'HorizontalAlignment','center','VerticalAlignment','middle')
      else
        idg=intersect(find(abs(dErel)<Etol),id); % in-tolerance
        idr=intersect(find(abs(dErel)>=Etol),id); % out-of-tolerance
        if (~isempty(idg))
          stem(Sd(idg),dEabs(idg),'.-','Color',green)
          hold on
        end
        if (~isempty(idr))
          stem(Sd(idr),dEabs(idr),'r.-')
        end
        hold off
        ylabel('XCOR/YCOR')
        set(gca,'XLim',XLim);
      end
      xlabel('S-Display (m)')
    case 4 % MAGNET Energy display [EACT]
      subplot(311)
      id=intersect(find(mtype==3),idLEM); % QUADs
      stem(Sd(id),E(id),'b.-')
      ylabel('QUAD')
      XLim=get(gca,'XLim');
      title('LEM MAGNET ENERGY [EACT] (GeV)')
      subplot(312)
      id=intersect(find((mtype==1)|(mtype==2)|(mtype==4)),idLEM); % XBENDs,YBENDs,SOLEs
      if (isempty(id))
        plot(0,'w')
        axis([XLim,-1,1])
        set(gca,'YTick',[])
        text(mean(XLim),0,'No BENDs or SOLEs selected', ...
          'HorizontalAlignment','center','VerticalAlignment','middle')
      else
        stem(Sd(id),E(id),'b.-')
        ylabel('BEND/SOLE')
        set(gca,'XLim',XLim);
      end
      ht=title(['Data Collected: ',datestr(lemDataTime)]);
      set(ht,'FontSize',10,'Units','normalized')
      p=get(ht,'Position');p(2)=1;set(ht,'Position',p)
      subplot(313)
      id=intersect(find((mtype==5)|(mtype==6)),idLEM); % XCORs,YCORs
      if (isempty(id))
        plot(0,'w')
        axis([XLim,-1,1])
        set(gca,'YTick',[])
        text(mean(XLim),0,'No XCORs or YCORs selected', ...
          'HorizontalAlignment','center','VerticalAlignment','middle')
      else
        stem(Sd(id),E(id),'b.-')
        ylabel('XCOR/YCOR')
        set(gca,'XLim',XLim);
      end
      xlabel('S-Display (m)')
    case 5 % MAGNET Energy display [EREF]
      subplot(311)
      id=intersect(find(mtype==3),idLEM); % QUADs
      stem(Sd(id),E0(id),'b.-')
      ylabel('QUAD')
      XLim=get(gca,'XLim');
      title('LEM MAGNET ENERGY [EREF] (GeV)')
      subplot(312)
      id=intersect(find((mtype==1)|(mtype==2)|(mtype==4)),idLEM); % XBENDs,YBENDs,SOLEs
      if (isempty(id))
        plot(0,'w')
        axis([XLim,-1,1])
        set(gca,'YTick',[])
        text(mean(XLim),0,'No BENDs or SOLEs selected', ...
          'HorizontalAlignment','center','VerticalAlignment','middle')
      else
        stem(Sd(id),E0(id),'b.-')
        ylabel('BEND/SOLE')
        set(gca,'XLim',XLim);
      end
      ht=title(['Data Collected: ',datestr(lemDataTime)]);
      set(ht,'FontSize',10,'Units','normalized')
      p=get(ht,'Position');p(2)=1;set(ht,'Position',p)
      subplot(313)
      id=intersect(find((mtype==5)|(mtype==6)),idLEM); % XCORs,YCORs
      if (isempty(id))
        plot(0,'w')
        axis([XLim,-1,1])
        set(gca,'YTick',[])
        text(mean(XLim),0,'No XCORs or YCORs selected', ...
          'HorizontalAlignment','center','VerticalAlignment','middle')
      else
        stem(Sd(id),E0(id),'b.-')
        ylabel('XCOR/YCOR')
        set(gca,'XLim',XLim);
      end
      xlabel('S-Display (m)')
    case 6 % QUAD BMAG display
      id=intersect(find(mtype==3),idLEM); % QUADs
      subplot(211)
      stem(Sd(id),BmagX(id),'b.-')
      v=get(gca,'YLim');v(1)=1;set(gca,'YLIM',v);
      hor_line(1,'k:')
      title('LEM QUAD BMAG')
      ylabel('QUAD Bmag X')
      subplot(212)
      stem(Sd(id),BmagY(id),'b.-')
      v=get(gca,'YLim');v(1)=1;set(gca,'YLIM',v);
      hor_line(1,'k:')
      ht=title(['Data Collected: ',datestr(lemDataTime)]);
      set(ht,'FontSize',10,'Units','normalized')
      p=get(ht,'Position');p(2)=1;set(ht,'Position',p)
      ylabel('QUAD Bmag Y')
      xlabel('S-Display (m)')
  end
  stat=1;
else
  txt=[{['Data Collected: ',datestr(lemDataTime)]};{''};];
  switch opCode
    case 1 % KLYS Energy values
      fmt='%-6s    %8.3f   %10.6f     %8.3f  ';
      txt=[txt; ...
        {'LEM KLYSTRON ENERGY [EACT]'}; ...
        {''}; ...
        {'name    Egain (MeV)   sum (GeV)  S-Display (m)'}; ...
        {'------  -----------  ----------  -------------'}];
        %'aaaaaa    +nnn.nnn   +nn.nnnnnn     nnnn.nnn  '
      txt=[txt;{sprintf(fmt,'Gun',egain0,E0,Sd0)}];
      for n=1:Nklys
        txt=[txt;{sprintf(fmt,KLYS(n).name,egain(n),E(n),Sd(n))}];
      end
      stat=LEM_TextDisplay(txt);
    case 2 % KLYS Phase values
      fmt='%-6s  %8.3f  %8.3f     %8.3f  ';
      txt=[txt; ...
        {'LEM KLYSTRON AND SUBBOOSTER PHASE (deg)'}; ...
        {''}; ...
        {'name      KLYS      SBST    S-Display (m)'}; ...
        {'------  --------  --------  -------------'}];
        %'aaaaaa  +nnn.nnn  +nnn.nnn     nnnn.nnn  '
      for n=1:Nklys
        txt=[txt;{sprintf(fmt,KLYS(n).name,phase(n,:),Sd(n))}];
      end
      stat=LEM_TextDisplay(txt);
    case 3 % Optics Verify values
      fmtg='%-14s  %10.3f  %9.3f     %8.3f  ';
      fmtr='%-14s  %10.3f  %9.3f     %8.3f    TOL';
      txt=[txt; ...
        {'LEM OPTICS VERIFY [EACT("E")-EREF("E0")] (MeV)'}; ...
        {''}; ...
        {'name               E-E0     (E-E0)/E0  S-Display (m)'}; ...
        {'--------------  ----------  ---------  -------------'}];
        %'aaaaaaaaaaaaaa  +nnnnn.nnn  +nnnn.nnn     nnnn.nnn  '
      for m=1:length(idLEM)
        n=idLEM(m);
        if (abs(dErel(n))<Etol)
          txt=[txt;{sprintf(fmtg,MAGNET(n).dbname,dEabs(n),dErel(n),Sd(n))}];
        else
          txt=[txt;{sprintf(fmtr,MAGNET(n).dbname,dEabs(n),dErel(n),Sd(n))}];
        end
      end
      stat=LEM_TextDisplay(txt);
    case 4 % MAGNET Energy values
      fmt='%-14s  %8.3f  %8.3f    %8.3f  ';
      txt=[txt; ...
        {'LEM MAGNET ENERGY (GeV)'}; ...
        {''}; ...
        {'name              EACT      EREF    S-Display (m)'}; ...
        {'--------------  --------  --------  -------------'}];
        %'aaaaaaaaaaaaaa  +nnn.nnn  +nnn.nnn     nnnn.nnn  '
      for m=1:length(idLEM)
        n=idLEM(m);
        txt=[txt;{sprintf(fmt,MAGNET(n).dbname,E(n),E0(n),Sd(n))}];
      end
      stat=LEM_TextDisplay(txt);
    case 5 % MAGNET BDES values
      fmt='%-14s  %10.5f  %10.5f     %8.3f  ';
      txt=[txt; ...
        {'LEM MAGNET BDES'}; ...
        {''}; ...
        {'name               BDES        BLEM     S-Display (m)'}; ...
        {'--------------  ----------  ----------  -------------'}];
        %'aaaaaaaaaaaaaa  +nnn.nnnnn  +nnn.nnnnn     nnnn.nnn  '
      for m=1:length(idLEM)
        n=idLEM(m);
        bdes=MAGNET(n).bdes;
        bnew=MAGNET(n).bnew;
        txt=[txt;{sprintf(fmt,MAGNET(n).dbname,bdes,bnew,Sd(n))}];
      end
      stat=LEM_TextDisplay(txt);
    case 6 % PS BDES values
      fmtg='%-14s  %10.5f  %10.5f';
      fmtr='%-14s  %10.5f  %10.5f  OUT-OF-RANGE';
      txt=[txt; ...
        {'LEM POWER SUPPLY BDES'}; ...
        {''}; ...
        {'name               BDES        BLEM   '}; ...
        {'--------------  ----------  ----------'}];
        %'aaaaaaaaaaaaaa  +nnn.nnnnn  +nnn.nnnnn'
      id=find([PS.setNow]==1)';
      for m=1:length(id)
        n=id(m);
        bdes=PS(n).bdes;
        bnew=PS(n).bnew;
        if (PS(n).bad)
          txt=[txt;{sprintf(fmtr,PS(n).dbname,bdes,bnew)}];
        else
          txt=[txt;{sprintf(fmtg,PS(n).dbname,bdes,bnew)}];
        end
      end
      stat=LEM_TextDisplay(txt);
    case 7 % QUAD BMAG values
      fmt='%-14s  %10.5f  %10.5f     %8.3f  ';
      txt=[txt; ...
        {'LEM QUAD BMAG'}; ...
        {''}; ...
        {'name              Bmag X      Bmag Y    S-Display (m)'}; ...
        {'--------------  ----------  ----------  -------------'}];
        %'aaaaaaaaaaaaaa  +nnn.nnnnn  +nnn.nnnnn     nnnn.nnn  '
      id=intersect(find(mtype==3),idLEM); % QUADs
      for m=1:length(id)
        n=id(m);
        txt=[txt;{sprintf(fmt,MAGNET(n).dbname,BmagX(n),BmagY(n),Sd(n))}];
      end
      stat=LEM_TextDisplay(txt);
    case 8 % QUAD Bmag Y values ... not available
      fmt='%-14s  %8.3f  %8.5f  %8.5f  %10.5f     %8.3f  ';
      txt=[txt; ...
        {'LEM QUAD Bmag Y'}; ...
        {''}; ...
        {'name             BetaY0     KL0       KL        Bmag Y    S-Display (m)'}; ...
        {'--------------  --------  --------  --------  ----------  -------------'}];
        %'aaaaaaaaaaaaaa  nnnn.nnn  +n.nnnnn  +n.nnnnn  +nnn.nnnnn     nnnn.nnn  '
      id=intersect(find(mtype==3),idLEM); % QUADs
      for m=1:length(id)
        n=id(m);
        txt=[txt;{sprintf(fmt,MAGNET(n).dbname,betay0(n),kl0(n),kl(n),BmagY(n),Sd(n))}];
      end
      stat=LEM_TextDisplay(txt);
  end
end

end