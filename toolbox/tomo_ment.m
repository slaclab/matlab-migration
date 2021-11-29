function rho = tomo_ment(x,y,profs,yf,r,tmat,varargin)
%TOMO_MENT
%  TOMO_MENT(X,Y,PROFS,YF,R,TMAT,...)
%  Implementation of the Maximum Entropy (MENT) tomographic reconstruction
%  algorithm. The iterated profiles are not calculated by exact summation
%  over all polygons, but by calculating the reconstruction on a fixed
%  grid.
%
% Features:

% Input arguments:
%    X:     x coordinates of reconstruction domain
%    Y:     y coordinates of reconstruction domain
%    PROFS: Array of M measured profiles [N M] with N points in each
%    YF:    Coordinates of measured profiles, assumed to be on y axis of
%           phase space
%    R:     Transport matrices [2 2 M]
%    TMAT:  2nd order transport matrix, use [] when not used
%
% Output arguments:
%    RHO: Reconstructed density function

% Compatibility: Version 7 and higher
% Called functions: tomo_sart_plot

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------

rotation=0;
ip=1;

% Get projection angles.
nproj=size(profs,2);
nsamp=length(y);
phi=reshape(atan2(-r(2,1,:),r(2,2,:)),[],1);

% Rescale projections.
if size(yf,2) == 1, yf=yf';end
delta0=repmat(yf,size(r,3)/size(yf,1),1);
dd0=delta0(:,2)-delta0(:,1);
dx=x(2)-x(1);
dy=y(2)-y(1);
% t0 is located at bin centers. Bin start position is t0-dd0/2.
if rotation
    t0=repmat(cos(phi)./reshape(r(2,2,:),[],1),1,size(delta0,2))*delta0;
else
    t0=repmat((cos(phi)*0+1),1,size(delta0,2)).*delta0;
%    t0=(cos(phi)./reshape(r(2,2,:),[],1))*delta0;
end
m0=profs'.*repmat(dd0,1,size(t0,2));
%m0(m0 < 1e-3*max(m0(:)))=0;
f_av=mean(sum(m0,2))/(x(end)-x(1)+dx)/(y(end)-y(1)+dy);

psi=reshape(phi,1,1,[]);
%mat=[cos(psi) sin(psi);-sin(psi) cos(psi)];
mat={r tmat};

sf=1; % Factor to increase grid points for reconstruction domain
dsf=(1-1/sf)/2;
xloc=linspace(min(x)-dsf*dx,max(x)+dsf*dx,length(x)*sf);
yloc=linspace(min(y)-dsf*dy,max(y)+dsf*dy,length(y)*sf);
f=f_av*ones(length(yloc),length(xloc));

niter=4;%figure(1);
lambda=1*(m0 ~= 0);
[jj,uu]=synth_getInd(mat,t0,xloc,yloc);
morder=mod(floor(((1:nproj)-1)*(nproj+1)/2)+1,nproj)+1;
%morder=1:nproj;
for n=1:niter
    % Gauss-Seidel procedure
    for i=morder
        if n==3 && i==11
            disp(i);
        end
        if rotation
            f=synth(lambda,phi,t0,xloc,yloc,f_av);
        else
            fnoi=synth_r_use(lambda,jj,uu,f_av,find(1:nproj ~= i),ip);
            f=synth_r_use(lambda,jj,uu,fnoi,i,ip);
        end
        tomo_sart_plot(xloc,yloc,f,varargin{:});
        if rotation
            m=anath(f,phi,t0,xloc,yloc,m0,lambda,f_av,i);
        else
            m=anath_r(fnoi,mat,t0,xloc,yloc,m0,lambda,f_av,i,i);
%            m=anath_r(f,mat,t0,xloc,yloc,m0,lambda,f_av,i);
%            m=anath_r_u(f,mat,t0,xloc,yloc,m0,lambda,f_av,i);
%            m=anath_r_use(f,jj,uu,m0,i);
        end
        mOff=mean(m0(i,:))*1e-2;
        l=lambda(i,:);
        use=m0(i,:) > 0 & m ~= 0;
        lambda(i,use)=lambda(i,use).*m0(i,use)./(m(use)+mOff);
        lambda(i,~use)=0;
        if 0
            subplot(2,1,1);
            semilogy(t0(i,:),max(m0(i,:),0),t0(i,:),m,'--',t0(i,:),m+mOff,':');set(gca,'YLim',[1e-10 1]);
            subplot(2,1,2);
            semilogy(t0(i,:),l,t0(i,:),lambda(i,:),':');set(gca,'YLim',[1e-8 1e2]);
            drawnow;
        end
        disp(['. ' num2str(n) ' ' num2str(i)]);
    end
    if rotation
        f=synth(lambda,phi,t0,xloc,yloc,f_av);
    else
        f=synth_r_use(lambda,jj,uu,f_av,0,ip);
    end
    tomo_sart_plot(xloc,yloc,f,varargin{:});
%    imagesc((lambda));drawnow
    disp('..');
end

if rotation
    rho=synth(lambda,phi,t0,x,y,f_av);
else
    [jj,uu]=synth_getInd(mat,t0,x,y);
    rho=synth_r_use(lambda,jj,uu,f_av,0,ip);
end

%return
xtest=linspace(min(x),max(x),length(x)*3);
ytest=linspace(min(y),max(y),length(y)*3);
[jj,uu]=synth_getInd(mat,t0,xtest,ytest);
f=synth_r_use(lambda,jj,uu,f_av,0,ip);
tomo_sart_plot(xtest,ytest,f,varargin{:});


% --------------------------------------------------------------------
function [jj, uu] = synth_getInd(m, t0, x, y)

t=[];if iscell(m), [m,t]=deal(m{:});end

if min(size(x)) == 1, [x,y]=meshgrid(x,y);end
dt=t0(:,2)-t0(:,1);
nP=size(m,3); % # of projections
jj=zeros([nP size(x)]);
uu=false(numel(x),nP);
for i=1:nP
%    t2=-x*sin(phi(i))+y*cos(phi(i)); % Original inverse of detector rotation.
    t2=x*m(2,1,i)+y*m(2,2,i); % Generalized to forward transformation of f.
    if ~isempty(t)
        t2=t2+x.^2*t(2,1,i)+y.^2*t(2,2,i);
    end
    % Rational bin index j0, integer bin index j is floor(j0 + .5)
    j0=(t2-t0(i,1))/dt(i)+1; % Equals 1 at t2 == t0
    use=j0 >= 1/2 & j0 < size(t0,2)+1/2;
    jj(i,:,:)=j0;uu(:,i)=use(:);
end


% --------------------------------------------------------------------
function f = synth(lambda,phi,t0,x,y,f0)

if nargin < 6, f0=1;end
if min(size(x)) == 1, [x,y]=meshgrid(x,y);end
f=x*0+f0;
dt=t0(:,2)-t0(:,1);
for i=1:length(phi)
    t2=-x*sin(phi(i))+y*cos(phi(i)); % Original inverse of detector rotation. Equals phase space forward transformation.
    j0=(t2-(t0(i,1)-dt(i)/2))/dt(i);
    j=floor(j0)+1;
    l1=interp(1:size(lambda,2),lambda(i,:),j0+1,'linear',0);
    f=f.*l1;
    use=j > 0 & j <= size(t0,2);
    f(use)=f(use).*lambda(i,j(use))';
    f(~use)=0;
end


% --------------------------------------------------------------------
function f = synth_r_use(lambda,j0,use,f,ii,ip)

[nP,nY,nX]=size(j0);
if nargin < 5, ii=0;end
if nargin < 6, ip=0;end
if ~all(ii), ii=1:nP;end
df=zeros(nY,nX);
for i=ii
    if ip
        df(:)=interp1(1:size(lambda,2),lambda(i,:),j0(i,:),'linear',0);
    else
        j=floor(j0(i,:)+.5);u=use(:,i);
        df(u)=lambda(i,j(u))';df(~u)=0;
    end
    f=f.*df;
end


% --------------------------------------------------------------------
function ms = anath(f,phi,t0,x,y,m0,lambda,f0,ii)

[x2,y2]=meshgrid(x,y);
dt=t0(:,2)-t0(:,1);
dx=x(2)-x(1);
dy=y(2)-y(1);
xn=[fliplr(min(x)-dx:-dx:min(x)*sqrt(2))];nx=length(xn);
yn=[fliplr(min(y)-dy:-dy:min(y)*sqrt(2))];ny=length(yn);
xn=[xn x max(x)+dx:dx:max(x)*sqrt(2)];
yn=[yn y max(y)+dy:dy:max(y)*sqrt(2)];
[xn2,yn2]=meshgrid(xn,yn);

if nargin < 9, ii=1:length(phi);end
for k=1:length(ii)
    i=ii(k);
    s2=xn2*cos(phi(i))-yn2*sin(phi(i));
    t2=xn2*sin(phi(i))+yn2*cos(phi(i));
%    ff=synth(lambda,phi,t0,s2,t2,f0);
    ff=interp2(x2,y2,f,s2,t2);ff(isnan(ff))=0;
    fint=sum(ff,2)*dx*dt(i);
    ms(k,:)=interp1(yn,fint,t0(i,:)+0*dt(i)/2,'linear',0);
    v={};if nargin >= 6,v={t0(i,:) m0(i,:) 'x'};end
%    plot(yn-dt(i)/2,fint,t0(i,:),ms(k,:),'.',v{:});
%    set(gca,'XLim',[min(yn) max(yn)]*1.1);
%    drawnow;
end


% --------------------------------------------------------------------
function ms = anath_r(f,m,t0,x,y,m0,lambda,f0,ii,j)

t=[];if iscell(m), [m,t]=deal(m{:});end

[x2,y2]=meshgrid(x,y);
dt=t0(:,2)-t0(:,1);
dx=x(2)-x(1);
dy=y(2)-y(1);
ext=[min(x) max(x) min(x) max(x);min(y) max(y) max(y) min(y)];

if nargin < 9, ii=1:length(phi);end
ms=zeros(length(ii),size(t0,2));
for k=1:length(ii)
    i=ii(k);
    extn=m(:,:,i)*ext;extn=[min(extn,[],2) max(extn,[],2)];
    dn=sqrt(diag(m(:,:,i)*diag([dx dy].^2)*m(:,:,i)'));
    xn=extn(1,1):dn(1):extn(1,2);yn=extn(2,1):dn(2):extn(2,2);
    [xn2,yn2]=meshgrid(xn,yn);s2=xn2;t2=yn2;

    mi=inv(m(:,:,i));
%    s2=xn2*cos(phi(i))-yn2*sin(phi(i)); %Original forward detector rotation.
%    t2=xn2*sin(phi(i))+yn2*cos(phi(i));
    s2(:)=[xn2(:) yn2(:)]*mi(1,:)'; %Generalized to inverse tranformation of f.
    t2(:)=[xn2(:) yn2(:)]*mi(2,:)';
    if ~isempty(t)
        t2=t2-t(2,1,i)*xn2.^2;
    end
%    ff=synth_r(lambda,m,t0,s2,t2,f0);
    ff=interp2(x2,y2,f,s2,t2);ff(isnan(ff))=0;
    fint=sum(ff,2)'*dn(1)*dt(i); % Changed from *dx to *dn(1)
    ms(k,:)=interp1(yn,fint,t0(i,:)+0*dt(i)/2,'linear',0);
    if nargin == 10
        ms(k,:)=ms(k,:).*lambda(j,:);
        fint=fint.*interp1(t0(i,:)+0*dt(i)/2,lambda(j,:),yn,'linear',0);
    end
    if 0
        v={};if nargin >= 6,v={t0(i,:) m0(i,:) 'x'};end
        plot(yn-dt(i)/2,fint,t0(i,:),ms(k,:),'.',v{:});
        text(.1,.9,{['m_0 = ' num2str(sum(m0(i,:)*dt(i)))] ['m = ' num2str(sum(fint*dn(2)))]},'units','normalized');
        set(gca,'XLim',[min(yn) max(yn)]*1.1);
        drawnow;
    end
end


% --------------------------------------------------------------------
function ms = anath_r2(f,m,t0,x,y,m0,lambda,f0,ii)

t=[];if iscell(m), [m,t]=deal(m{:});end

[x2,y2]=meshgrid(x,y);
dt=t0(:,2)-t0(:,1);
dx=x(2)-x(1);
dy=y(2)-y(1);

if nargin < 9, ii=1:length(phi);end
for k=1:length(ii)
    i=ii(k);
    t2=y2;
    t2(:)=[x2(:) y2(:)]*m(2,:,i)'; %Generalized to forward tranformation of stripe.
    if ~isempty(t)
        t2(:)=t2(:)+[x2(:) y2(:)].^2*t(2,:,i)';
    end
    j=floor((t2-(t0(i,1)-dt(i)/2))/dt(i))+1;
    use=j > 0 & j <= size(t0,2);
    ff=f(use);
    sp=sparse(j(use),1:length(ff),ff,size(t0,2),length(ff));
    ms(k,:)=full(sum(sp,2))'*dx*dt(i);
    v={};if nargin >= 6,v={t0(i,:) m0(i,:) 'x'};end
%    plot(t0(i,:),ms(k,:),'.',v{:});drawnow;
end


% --------------------------------------------------------------------
function ms = anath_r_use(f,j,use,m0,ii)

for n=1:length(ii)
    i=ii(n);nt=size(m0,2);
    ms(n,:)=full(sparse(j(use(:,i),i),1,f(use(:,i)),nt,1));

    v={};if nargin >= 6,v={1:nt m0(i,:) 'x'};end
    plot(1:nt,ms(n,:),'.',v{:});
%    set(gca,'XLim',[min(yn) max(yn)]*1.1);
    drawnow;
end


% --------------------------------------------------------------------
function ms = anath_r_u(f,m,t0,x,y,m0,lambda,f0,ii)

%if nargin < 6, f0=1;end
t=[];if iscell(m), [m,t]=deal(m{:});end

if min(size(x)) == 1, [x,y]=meshgrid(x,y);end
dt=t0(:,2)-t0(:,1);dx=x(1,2)-x(1,1);dy=y(2,1)-y(1,1);

for n=1:length(ii)
    i=ii(n);
%    ti2=-x*sin(phi(i))+y*cos(phi(i)); % Original inverse of detector rotation.
    t2=x*m(2,1,i)+y*m(2,2,i); % Generalized to forward transformation of f.
    if ~isempty(t)
        t2=t2+x.^2*t(2,1,i)+y.^2*t(2,2,i);
    end
    j=floor((t2-(t0(i,1)-dt(i)))/dt(i))+1;
    dt2=sqrt([dx dy].^2*m(2,:,i)'.^2); % Geometric norm.
    ddj=round((dt2/dt(i)-1)/2);dj=ddj*2+1;jj=repmat(j(:),1,dj);
    jj=jj+ones(size(jj,1),1)*(-ddj:ddj);
%    use=j > 0 & j <= size(t0,2);
    use=jj > 0 & jj <= size(t0,2);
%    ms(n,:)=full(sparse(j(use),1,f(use),size(t0,2),1));
    ms(n,:)=full(sparse(jj(use),1,f(mod(find(use)-1,size(jj,1))+1),size(t0,2),1))/dj;

    v={};if nargin >= 6,v={t0(i,:) m0(i,:) 'x'};end
    plot(t0(i,:),ms(n,:),'.',v{:});
%    set(gca,'XLim',[min(yn) max(yn)]*1.1);
    drawnow;
end
