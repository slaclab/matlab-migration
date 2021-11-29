function fel_jitterStat(data, n, varargin)

% --------------------------------------------------------------------
% Set default options.
optsdef=struct( ...
    'nBin',16, ...
    'nDeg',0, ...
    'xMax',1.7, ...
    'figure',1 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

if nargin < 2, n=1;end
if isfield(data,'beamPV')
    beam=vertcat(data(n,:).beam);
    stats=vertcat(beam(:,1).stats);
    time=[data(n,:).ts];time=(time-time(1))*24*60*60;
    name=data(1).name;ts=data(1).ts;
else
    stats=vertcat(data.beam(n,:,1).stats);
    time=[data.profPV(6,n,:).ts];time=(time-time(1))*24*60*60;
    name=data.profPV(6,n,1).name;ts=data.profPV(6,n,1).ts;
end
ener=stats(:,6)';
parP=polyfit(time,ener,opts.nDeg);
enerF=polyval(parP,time);

enerm=mean(ener);
enerstd=std(ener-enerF,1);
m=(enerstd/enerm)^(-2);
ener=ener/enerm;

xm=opts.xMax;
x=linspace(0,xm,xm*opts.nBin+1);
dx=x(2)-x(1);
x=x+dx/2;

p=hist(ener,x);
p=p/sum(p)/dx;

fx=linspace(0,xm,300);
fener=fx*enerm;
pf=m^m/gamma(m)*(fx).^(m-1).*exp(-m*fx);
pg=1/sqrt(2*pi)*sqrt(m)*exp(-m*(fx-1).^2/2);

[par,yf]=util_gaussFit(x,p);

% Generate Plot
figure(opts.figure);

%util_marginSet(fig,[.075 .05],[.075 .025]);
subplot(2,1,1);
h=plot(time,ener,'o',time,enerF/enerm,'r--','MarkerSize',5);
%par=polyfit(time,ener,n);
%plot(time,polyval(par,time));
%pos=get(gca,'Position');pos(3)=.5-pos(1);
set(gca,'XLim',max(time)*[-.1 1.1],'YLim',[0 xm]);%,'Position',pos+.05*[0 1 0 -1],...
%set(gca,    'YTick',0:.5:2);
xlabel('Time (s)');
ylabel('Normalized Fluctuations  \itE/<E>');
title(['Fluctuations on ' name ' ' datestr(ts)]);

subplot(2,1,2);
%h=barh(x,p,1,'w');
h=bar(x,p,1,'w');
set(h,'FaceColor',.9*[1 1 1],'EdgeColor','b');
%plot(pf,fx,'k--');
hold on;plot(fx,pf,'r--');hold off
%set(gca,'XLim',[0 xm],'YLim',[0 4.8],'Position',[.13 .15 .775 .775],...
%    'XTick',0:.5:2,'YTick',0:4);
%pos=get(gca,'Position');pos([1 3])=[.5 pos(3)+(pos(1)-.5)];
set(gca,'YLim',max(p)*[0 1.2],'XLim',[0 xm]);%,...
%    'YTick',0:5,'XTick',0:.5:2);%,'YTickLabel','','Position',pos+.05*[0 1 0 -1]);
ylabel('Probability  {\itp}({\itE})');
xlabel('Normalized Fluctuations  \itE/<E>');
text(.05,.7,sprintf('M = %2.0f\n\\sigma = %3.1f%%',m,100/sqrt(m)),'Units','normalized');
text(.48,.8,'{\itp}({\itE}) = {\itM}^{\itM}/\Gamma({\itM}) {\itE}^{{\itM}-1} e^{-{\itM E}}','Units','normalized');

util_appFonts(opts.figure,'fontSize',13,'fontName','Arial','markerSize',2,'lineWidth',2);

return

% AVI movie
for j=1:100,data=d.data.dataList(j);data.img=data.img(:,1:144);ts=data.ts;ds=[datestr(ts) '.' num2str(fix(rem(ts*24*60*60,1)*10))];profmon_imgPlot(data,'cal',1,'title',ds);text(.1,.9,[data.name ' ' ds],'units','normalized','Color','w','fontsize',14);f(j)=getframe;end
movie2avi(f,'c:\loos\lasingLCLS.avi','FPS',10);

% Animated GIF
imwrite(uint8(cat(4,d.data.dataList.img)/12.5),jet(256),'c:\loos\slac\lasingLCLS.gif','gif','delaytime',.1);
