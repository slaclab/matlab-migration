function facet_dispersion_magplot( ...
  h,model,xlim,cmag,nmag,fontsize,fontname)
%
% facet_dispersion_magnet_plot(h,model,xlim,cmag,nmag,fontsize,fontname);
%
% Add magnet schematic to facet_dispersion GUI
%
% INPUTs:
%
%   h         = figure window handle
%   model     = MAD model
%   xlim      = horizontal plot limits
%   cmag      = display magnets in color (OPTIONAL) [default=1]
%   nmag      = display magnet names (OPTIONAL) [default=1]
%   fontsize  = fontsize for names (OPTIONAL) [default=6]
%   fontname  = fontname for names (OPTIONAL) [default='helvetica'];

if (nargin<4)
  cmag=1;
  nmag=0;
elseif (nargin<5)
  nmag=0;
end
if (nmag)
  if (nargin<7),fontname='helvetica';end
  if (nargin<6),fontsize=6;end
end

ha=0.5;   % half-height of RF rectangle
hb=1;     % full height of bend rectangle
hq=4;     % full height of quadrupole rectangle
hs=3;     % full height of sextupole rectangle
ho=2;     % full height of octupole rectangle
hr=1;     % half-height of solenoid rectangle
tol=1e-6; % used to unsplit devices

id1=strmatch('LI19BEG',model.N);
id2=length(model.S);
id=(id1:id2)';
K=model.K(id,:);
L=model.L(id);
P=model.P(id,:);
N=model.T(id,:); % use MAD names
Z=model.coor(id,3);

% RF

ida=strmatch('LCAV',K);
if (~isempty(ida))
  if (ida(1)==1),ida(1)=[];end
end
if (isempty(ida))
  Na=0;
else
  xa=zeros(size(ida));
  wa=zeros(size(ida));
  ya=zeros(size(ida));
  n=ida(1);
  Na=1;
  xa(Na)=Z(n);
  wa(Na)=L(n);
  ya(Na)=ha;
  if (nmag),na=N(n,:);end
  for m=2:length(ida)
    n=ida(m);
    if (abs(Z(n-1)-xa(Na))<tol)
      xa(Na)=Z(n);
      wa(Na)=wa(Na)+L(n);
    else
      Na=Na+1;
      xa(Na)=Z(n);
      wa(Na)=L(n);
      ya(Na)=ha;
      if (nmag),na=[na;N(n,:)];end
    end
  end
  xa(Na+1:end)=[];
  wa(Na+1:end)=[];
  ya(Na+1:end)=[];
  xa=xa-wa/2;
end

% bends

idb=strmatch('SBEN',K);
if (~isempty(idb))
  if (idb(1)==1),idb(1)=[];end
end
if (isempty(idb))
  Nb=0;
else
  xb=zeros(size(idb));
  wb=zeros(size(idb));
  yb=zeros(size(idb));
  n=idb(1);
  Nb=1;
  xb(Nb)=Z(n);
  wb(Nb)=L(n);
  if (P(n,4)==0)
    yb(Nb)=hb;
  else
    yb(Nb)=-hb;
  end
  if (nmag),nb=N(n,:);end
  for m=2:length(idb)
    n=idb(m);
    if (abs(Z(n-1)-xb(Nb))<tol)
      xb(Nb)=Z(n);
      wb(Nb)=wb(Nb)+L(n);
    else
      Nb=Nb+1;
      xb(Nb)=Z(n);
      wb(Nb)=L(n);
      if (P(n,4)==0)
        yb(Nb)=hb;
      else
        yb(Nb)=-hb;
      end
      if (nmag),nb=[nb;N(n,:)];end
    end
  end
  xb(Nb+1:end)=[];
  wb(Nb+1:end)=[];
  yb(Nb+1:end)=[];
  xb=xb-wb/2;
end

% quads

idq=strmatch('QUAD',K);
if (~isempty(idq))
  if (idq(1)==1),idq(1)=[];end
end
if (isempty(idq))
  Nq=0;
else
  xq=zeros(size(idq));
  wq=zeros(size(idq));
  yq=zeros(size(idq));
  n=idq(1);
  Nq=1;
  xq(Nq)=Z(n);
  wq(Nq)=L(n);
  if (P(n,2)<0)
    yq(Nq)=-hq;
  else
    yq(Nq)=hq;
  end
  if (nmag),nq=N(n,:);end
  for m=2:length(idq)
    n=idq(m);
    if (abs(Z(n-1)-xq(Nq))<tol)
      xq(Nq)=Z(n);
      wq(Nq)=wq(Nq)+L(n);
    else
      Nq=Nq+1;
      xq(Nq)=Z(n);
      wq(Nq)=L(n);
      if (P(n,2)<0)
        yq(Nq)=-hq;
      else
        yq(Nq)=hq;
      end
      if (nmag),nq=[nq;N(n,:)];end
    end
  end
  xq(Nq+1:end)=[];
  wq(Nq+1:end)=[];
  yq(Nq+1:end)=[];
  xq=xq-wq/2;
end

% sexts

ids=strmatch('SEXT',K);
if (~isempty(ids))
  if (ids(1)==1),ids(1)=[];end
end
if (isempty(ids))
  Ns=0;
else
  xs=zeros(size(ids));
  ws=zeros(size(ids));
  ys=zeros(size(ids));
  n=ids(1);
  Ns=1;
  xs(Ns)=Z(n);
  ws(Ns)=L(n);
  if (P(n,3)<0)
    ys(Ns)=-hs;
  else
    ys(Ns)=hs;
  end
  if (nmag),ns=N(n,:);end
  for m=2:length(ids)
    n=ids(m);
    if (abs(Z(n-1)-xs(Ns))<tol)
      xs(Ns)=Z(n);
      ws(Ns)=ws(Ns)+L(n);
    else
      Ns=Ns+1;
      xs(Ns)=Z(n);
      ws(Ns)=L(n);
      if (P(n,3)<0)
        ys(Ns)=-hs;
      else
        ys(Ns)=hs;
      end
      if (nmag),ns=[ns;N(n,:)];end
    end
  end
  xs(Ns+1:end)=[];
  ws(Ns+1:end)=[];
  ys(Ns+1:end)=[];
  xs=xs-ws/2;
end

% octs

ido=strmatch('OCTU',K);
if (~isempty(ido))
  if (ido(1)==1),ido(1)=[];end
end
if (isempty(ido))
  No=0;
else
  xo=zeros(size(ido));
  wo=zeros(size(ido));
  yo=zeros(size(ido));
  n=ido(1);
  No=1;
  xo(No)=Z(n);
  wo(No)=L(n);
  if (P(n,5)<0)
    yo(No)=-ho;
  else
    yo(No)=ho;
  end
  if (nmag),no=N(n,:);end
  for m=2:length(ido)
    n=ido(m);
    if (abs(Z(n-1)-xo(No))<tol)
      xo(No)=Z(n);
      wo(No)=wo(No)+L(n);
    else
      No=No+1;
      xo(No)=Z(n);
      wo(No)=L(n);
      if (P(n,5)<0)
        yo(No)=-ho;
      else
        yo(No)=ho;
      end
      if (nmag),no=[no;N(n,:)];end
    end
  end
  xo(No+1:end)=[];
  wo(No+1:end)=[];
  yo(No+1:end)=[];
  xo=xo-wo/2;
end

% solenoids

idr=strmatch('SOLE',K);
if (~isempty(idr))
  if (idr(1)==1),idr(1)=[];end
end
if (isempty(idr))
  Nr=0;
else
  xr=zeros(size(idr));
  wr=zeros(size(idr));
  yr=zeros(size(idr));
  n=idr(1);
  Nr=1;
  xr(Nr)=Z(n);
  wr(Nr)=L(n);
  yr(Nr)=hr;
  if (nmag),nr=N(n,:);end
  for m=2:length(idr)
    n=idr(m);
    if (abs(Z(n-1)-xr(Nr))<tol)
      xr(Nr)=Z(n);
      wr(Nr)=wr(Nr)+L(n);
    else
      Nr=Nr+1;
      xr(Nr)=Z(n);
      wr(Nr)=L(n);
      yr(Nr)=hr;
      if (nmag),nr=[nr;N(n,:)];end
    end
  end
  xr(Nr+1:end)=[];
  wr(Nr+1:end)=[];
  yr(Nr+1:end)=[];
  xr=xr-wr/2;
end

if ((Na+Nb+Nq+Ns+No+Nr)==0)
  return % no magnets to plot
end

% prepare axes for magnet schematic

axes(h)
plot([Z(1),Z(end)],[0,0],'k-')
set(gca,'XLim',xlim)
hold on
set(h,'Visible','on','Box','off','XTick',[],'YTick',[]);

% make the magnet schematic (use the "rectangle" command);
% add names if requested
% (NOTE: ignore zero-length elements)

if (Na>0)
  for n=1:Na
    x=xa(n)-wa(n)/2;
    w=wa(n);
    if (w>0)
      y=-ya(n);
      h=2*ya(n);
      h=rectangle('Position',[x,y,w,h],'FaceColor','none');
      if (cmag),set(h,'FaceColor','y'),end
      if (nmag)
        text(xa(n),5,literal(na(n,:)),'Rotation',90, ...
          'FontSize',fontsize,'FontName',fontname, ...
          'HorizontalAlignment','left','VerticalAlignment','middle')
      end
    end
  end
end
if (Nb>0)
  for n=1:Nb
    x=xb(n)-wb(n)/2;
    w=wb(n);
    if (w>0)
      if (yb(n)<0)
        y=yb(n);
        h=abs(yb(n));
      else
        y=0;
        h=yb(n);
      end
      h=rectangle('Position',[x,y,w,h],'FaceColor','none');
      if (cmag),set(h,'FaceColor','b'),end
      if (nmag)

%       shave off last character in name

        nc=length(deblank(nb(n,:)))-1;
        text(xb(n),5,literal(nb(n,1:nc)),'Rotation',90, ...
          'FontSize',fontsize,'FontName',fontname, ...
          'HorizontalAlignment','left','VerticalAlignment','middle')
      end
    end
  end
end
if (Nq>0)
  for n=1:Nq
    x=xq(n)-wq(n)/2;
    w=wq(n);
    if (w>0)
      if (yq(n)<0)
        y=yq(n);
        h=abs(yq(n));
      else
        y=0;
        h=yq(n);
      end
      h=rectangle('Position',[x,y,w,h],'FaceColor','none');
      if (cmag),set(h,'FaceColor','r'),end
      if (nmag)
        text(xq(n),5,literal(nq(n,:)),'Rotation',90, ...
          'FontSize',fontsize,'FontName',fontname, ...
          'HorizontalAlignment','left','VerticalAlignment','middle')
      end
    end
  end
end
if (Ns>0)
  for n=1:Ns
    x=xs(n)-ws(n)/2;
    w=ws(n);
    if (w>0)
      if (ys(n)<0)
        y=ys(n);
        h=abs(ys(n));
      else
        y=0;
        h=ys(n);
      end
      h=rectangle('Position',[x,y,w,h],'FaceColor','none');
      if (cmag),set(h,'FaceColor','g'),end
      if (nmag)
        text(xs(n),5,literal(ns(n,:)),'Rotation',90, ...
          'FontSize',fontsize,'FontName',fontname, ...
          'HorizontalAlignment','left','VerticalAlignment','middle')
      end
    end
  end
end
if (No>0)
  for n=1:No
    x=xo(n)-wo(n)/2;
    w=wo(n);
    if (w>0)
      if (yo(n)<0)
        y=yo(n);
        h=abs(yo(n));
      else
        y=0;
        h=yo(n);
      end
      h=rectangle('Position',[x,y,w,h],'FaceColor','none');
      if (cmag),set(h,'FaceColor','c'),end
      if (nmag)
        text(xo(n),5,literal(no(n,:)),'Rotation',90, ...
          'FontSize',fontsize,'FontName',fontname, ...
          'HorizontalAlignment','left','VerticalAlignment','middle')
      end
    end
  end
end
if (Nr>0)
  for n=1:Nr
    x=xr(n)-wr(n)/2;
    w=wr(n);
    if (w>0)
      y=-yr(n);
      h=2*yr(n);
      h=rectangle('Position',[x,y,w,h],'FaceColor','none');
      if (cmag),set(h,'FaceColor','m'),end
      if (nmag)
        text(xr(n),5,literal(nr(n,:)),'Rotation',90, ...
          'FontSize',fontsize,'FontName',fontname, ...
          'HorizontalAlignment','left','VerticalAlignment','middle')
      end
    end
  end
end

hold off

end
