hF=gcf;   hA=gca;
hA=get(hF,'currentaxes');
hT=get(hA,'title' );
%hT1=get(h1 );
%hT2=get(h2 );
%hT3=get(h3 );
%hT4=get(h4 );
hX=get(hA,'xlabel' );
hY=get(hA,'ylabel' );
set(gcf,'PaperOrientation','portrait')
set(gcf,'PaperPosition',[.25 2.5 8 6])
set(hT,'fontname','times','fontsize',16,'fontweight', 'normal')
%set(h1,'fontname','times','fontsize',8)
%set(h2,'fontname','times','fontsize',8)
%set(h3,'fontname','times','fontsize',8)
%set(h4,'fontname','times','fontsize',8)
set(hX,'fontname','times','fontsize',16)
set(hY,'fontname','times','fontsize',16)
set(gca,'fontname','times','fontsize',16)
%print
