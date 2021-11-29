function [bg, bgs, area] = util_bgLevel(prof, varargin)
% Get background and background noise

% Set default options.
optsdef=struct( ...
    'debug',0 ...
    );

% Use default options if OPTS undefined.
opts=util_parseOptions(varargin{:},optsdef);

% Test for integer values.
y=prof(min(2,end),:);
if ~any(y-round(y)) && max(y) < 2^16
    x=min(y):4:max(y)+4;
else
    x=linspace(min(y),max(y),min(100,size(y,2)*2));
end
if isempty(x), x=1:100;end

[a,b]=hist(y,x);
a(ceil(end/2+1):end)=0;
b=[min(b)-(max(b)-min(b))/(length(b)-1) b];a=[0*min(a) a];
%b1=linspace(min(b),max(b),2*length(b)-1);a=interp1(b,a,b1,'linear');b=b1;
if ~diff(b(1:2)), b(1)=b(1)-realmin-abs(b(1))*eps;end
bf=linspace(min(b),max(b),10000);
[par,yf]=util_gaussFit(b,a,0,0,[],bf);

if 0
[a,b]=hist(y,par(2)+5*par(3)*linspace(-1,1,100));a([1 end])=0;
%[a,b]=hist(prof(2,:),(max(prof(2,:))-min(prof(2,:)))/par(3)*2);
%a1=a;b1=b;[am,id]=max(a);a1(id)=NaN;%b1(id)=[];
%a1(max(1,ceil(end/2)):end)=0;
bf=linspace(min(b),max(b),10000);
[par,yf]=util_gaussFit(b,a,0,0,[],bf);
end

bg=par(2);bgs=par(3);
area=sum((a-interp1(bf,yf,b,'linear')).*(b-bg));

%prof(2,:)=prof(2,:)-bg;

if opts.debug
    yf=par(1)*exp(-((bf-par(2))/par(3)).^2/2);
    %semilogy(b,a,'.',bf,yf);%set(gca,'YLim',[.9 1.5*max(a)]);
    plot(b,a,'.',bf,yf);%set(gca,'YLim',[.9 1.5*max(a)]);
%    set(gca,'YLim',[.9 Inf]);
end
