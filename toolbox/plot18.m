
hF=gcf;   hA=gca;
hA=get(hF,'currentaxes');
hT=get(hA,'title' );
%hT1=get(h1 );
%hT2=get(h2 );
%hT3=get(h3 );
%hT4=get(h4 );
hX=get(hA,'xlabel' );
hY=get(hA,'ylabel' );
set(gcf,'PaperOrientation','landscape')
set(gcf,'PaperPosition',[.25 2.5 8 6])
set(hT,'fontname','helvetica','fontsize',18)
%set(h1,'fontname','times','fontsize',8)
%set(h2,'fontname','times','fontsize',8)
%set(h3,'fontname','times','fontsize',8)
%set(h4,'fontname','times','fontsize',8)
set(hX,'fontname','helvetica','fontsize',18)
set(hY,'fontname','helvetica','fontsize',18)
set(gca,'fontname','helvetica','fontsize',18)
%print
