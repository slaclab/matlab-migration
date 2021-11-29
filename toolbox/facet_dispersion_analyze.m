function result=facet_dispersion_analyze(data,model0,model,parm)
%
% result=facet_dispersion_analyze(data,model0,parm)
%
% INPUTs
%
% data    = dispersion measurement data structure
% model0  = design model structure (see FACET18_getModel0)
% model   = model structure (see FACET18_getModel)
% parm    = (optional) parameters structure
% .nord         : order of polynomial fits (default=1)
% .normFit      : normalize linear fits to unit chisquare
% .plotRaw      : plot raw data
% .plotFit      : plot fits
% .plotLI19     : plot LI19 oscillation fit (incoming dispersion)
% .plotFF       : plot FF oscillation fit (leakage dispersion)
% .plotFF2      : plot FF oscillation fit (leakage dispersion) ... subplots
% .propLI19     : plot propagation of LI19 oscillation fit
% .propFF       : plot propagation of FF oscillation fit
% .propLI19diff : plot propagation of LI19 oscillation fit minus model
% .propFFdiff   : plot propagation of FF oscillation fit minus model
% .showVal      : print table of PROF/WIRE/IP dispersion values
%
% OUTPUT
%
% result   = results structure
%   .mname = cell array of BPM names
%   .pname = cell array of PROF/WIRE/IP names
%   .Dm    = [DX,DY] at BPMs (m)
%   .dDm   = [DX,DY] errors (m)
%   .D1    = [DX,DPX,DY,DPY] at chicane begin (m,rad)
%   .dD1   = [DX,DPX,DY,DPY] errors (m,rad)
%   .D2    = [DX,DPX,DY,DPY] at chicane end (m,rad)
%   .dD2   = [DX,DPX,DY,DPY] errors (m,rad)
%   .Dp    = [DX,DPX,DY,DPY] at PROFs/WIREs/IPs (m,rad)
%   .Dcn   = [DX,DPX,DY,DPY] at notch collimator (m,rad)
%   .Dsy   = [DX,DPX,DY,DPY] at sYAG (m,rad)

% ------------------------------------------------------------------------------
% 03-MAR-2015, M. Woodley
%   Add propLI19diff and propFFdiff plots
% 11-APR-2014, M. Woodley
%   Deal with BPMs that are in facet_dispersion data but not in the model
% ------------------------------------------------------------------------------

if (nargin==3)
  nord=1;
  normFit=false;
  plotRaw=false;
  plotFit=false;
  plotLI19=false;
  plotFF=false;
  plotFF2=false;
  propLI19=false;
  propFF=false;
  showVal=false;
else
  if (isfield(parm,'nord'))
    nord=parm.nord;
  else
    nord=1;
  end
  if (isfield(parm,'normFit'))
    normFit=parm.normFit;
  else
    normFit=false;
  end
  if (isfield(parm,'plotRaw'))
    plotRaw=parm.plotRaw;
  else
    plotRaw=false;
  end
  if (isfield(parm,'plotFit'))
    plotFit=parm.plotFit;
  else
    plotFit=false;
  end
  if (isfield(parm,'plotLI19'))
    plotLI19=parm.plotLI19;
  else
    plotLI19=false;
  end
  if (isfield(parm,'plotFF'))
    plotFF=parm.plotFF;
  else
    plotFF=false;
  end
  if (isfield(parm,'plotFF2'))
    plotFF2=parm.plotFF2;
  else
    plotFF2=false;
  end
  if (isfield(parm,'propLI19'))
    propLI19=parm.propLI19;
  else
    propLI19=false;
  end
  if (isfield(parm,'propFF'))
    propFF=parm.propFF;
  else
    propFF=false;
  end
  if (isfield(parm,'propLI19diff'))
    propLI19diff=parm.propLI19diff;
  else
    propLI19diff=false;
  end
  if (isfield(parm,'propFFdiff'))
    propFFdiff=parm.propFFdiff;
  else
    propFFdiff=false;
  end
  if (isfield(parm,'showVal'))
    showVal=parm.showVal;
  else
    showVal=false;
  end
end
  
K=model.K;                     % keyword
N=model.N;                     % name
L=model.L;                     % length (m)
P=model.P;                     % parameters
T=model.T;                     % MAD names
E=model.E;                     % energy (GeV)
Z=model.coor(:,3);             % linac Z (m)
rmat=model.rmat;               % R-matrices
Ne=length(Z);                  % number of elements in model
ip=strmatch(model0.config.IPcname,T); % pointer to waist location
if (isempty(ip))
  ip=strmatch(model0.config.IPname,N);
end

% general setup
mname=model_nameRegion('BPMS',{'LI19','LI20'}); % facet_dispersion BPMs
mname=model_nameConvert(mname,'SLC'); % want prim:micr:unit
Nbpm=length(mname);
idm=zeros(Nbpm,1);
for n=1:Nbpm
  C=textscan(mname{n},'%s%s%d','Delimiter',':');
  name=sprintf('M%02d%04dT',micr2bitid(C{2}),C{3});
  id=strmatch(name,N);
  if (~isempty(id))
    idm(n)=strmatch(name,N);
  end
end
idprof=strmatch('PROF',K);
idwire=strmatch('WIRE',K);
idinst=strmatch('INST',K);
idpm=sort([idprof;idwire;idinst]);
Npm=length(idpm);
pname=cell(Npm,1);
for n=1:Npm
  if (ismember(idpm(n),idinst))
    pname{n}=deblank(T(idpm(n),:));
    continue
  end
  name=deblank(N(idpm(n),:));
  if (ismember(idpm(n),idwire))
    prim='WIRE';
    bitid=str2num(name(2:3));
    micr=bitid2micr(bitid);
    unit=str2num(name(4:7));
  else
    if (strcmp(name(1:2),'PD'))
      bitid=str2num(name(3:4));
      unit=str2num(name(5:8));
    else
      bitid=str2num(name(2:3));
      unit=str2num(name(4:7));
    end
    micr=bitid2micr(bitid);
    prim='PROF';
    if (strcmp(micr,'LI20'))
      switch unit
        case {3185,3485}
          prim='PROF';
        case {3202,3230}
          prim='MIRR';
        otherwise
          prim='OTRS';
      end
    end
  end
  pname{n}=sprintf('%s:%s:%d',prim,micr,unit);
end
id19=strmatch('LI19BEG',N);
id20=strmatch('FBEG',N);
idc=[id20;strmatch('CB1RE',N)]; % chicane begin,end
idp=(id19:length(Z))';
energy=E(id20);
Zm=zeros(size(idm));Zm(idm~=0)=Z(idm(idm~=0));
Zp=Z(idp);
nfig=0;

result.mname=mname;
result.pname=pname;

% set up data arrays
[Nbpm,Nave,Nstep]=size(data.energy);
dE=zeros(Nstep,1);
X=zeros(Nstep,Nbpm);dX=zeros(Nstep,Nbpm);
Y=zeros(Nstep,Nbpm);dY=zeros(Nstep,Nbpm);
Tmit=zeros(Nstep,Nbpm);dTmit=zeros(Nstep,Nbpm);
for n=1:Nstep
  dE(n)=data.energy(1,1,n); % MeV
  for m=1:Nbpm
    id=find(data.stat(m,:,n)==1);
    if (~isempty(id))
      X(n,m)=mean(data.x(m,id,n));dX(n,m)=std(data.x(m,id,n)); % mm
      Y(n,m)=mean(data.y(m,id,n));dY(n,m)=std(data.y(m,id,n)); % mm
      Tmit(n,m)=mean(data.tmit(m,id,n));dTmit(n,m)=std(data.tmit(m,id,n)); % 1
    end
  end
end
dp=dE/energy; % pm
if (plotRaw)
  d=max(dp)-min(dp);
  dp1=min(dp)-0.05*d;
  dp2=max(dp)+0.05*d;
end

% do slope fits
DX=zeros(1,Nbpm);dDX=zeros(1,Nbpm);
DY=zeros(1,Nbpm);dDY=zeros(1,Nbpm);
np=0;
idbad=[];
for n=1:Nbpm
  % find good data and bad BPMs
  idx=find(dX(:,n)>0); % good X measurement steps
  idy=find(dY(:,n)>0); % good Y measurement steps
  if ((length(idx)<3)||(length(idy)<3))
    fprintf('%s is bad\n',mname{n});
    idbad=[idbad,n]; % require at least 3 points for each linear fit
    continue
  end
  % dX/dp fit
  [qx,dqx,chi2x]=noplot_polyfit(dp(idx),X(idx,n),dX(idx,n),nord);
  if (normFit)
    [qx,dqx,chi2x]=noplot_polyfit(dp(idx),X(idx,n),dX(idx,n)*sqrt(chi2x),nord);
  end
  DX(n)=qx(2);
  dDX(n)=dqx(2);
  % dY/dp fit
  [qy,dqy,chi2y]=noplot_polyfit(dp(idy),Y(idy,n),dY(idy,n),nord);
  if (normFit)
    [qy,dqy,chi2y]=noplot_polyfit(dp(idy),Y(idy,n),dY(idy,n)*sqrt(chi2y),nord);
  end
  DY(n)=qy(2);
  dDY(n)=dqy(2);
  if (~plotRaw),continue,end
  % plot raw data
  np=np+1;
  if ((nfig==0)||(np==5))
    nfig=nfig+1;
    figure(nfig),clf,subplot
    set(nfig,'Name',sprintf('BPM dX/dP and dYdP Fits (%d)',nfig))
    np=1;
  end
  subplot(2,2,np)
  plot_barsc(dp(idx),X(idx,n),dX(idx,n),'b','o')
  hold on
  plot_barsc(dp(idy),Y(idy,n),dY(idy,n),'g','o')
  plot(dp(idx),polyval(fliplr(qx),dp(idx)),'b--')
  plot(dp(idy),polyval(fliplr(qy),dp(idy)),'g--')
  hold off
  title(deblank(N(idm(n),:)))
  ylabel('Position (mm)')
  xlabel('dP/P (pm)')
end

result.Dm=[DX(:),DY(:)];
result.dDm=[dDX(:),dDY(:)];

% remove bad BPMs (including BPMs that are not in the model)
idgood=(1:Nbpm);
if (~isempty(idbad))
  idgood(idbad)=[];
  Nbpm=length(idgood);
  idm(idbad)=[];
  Zm(idbad)=[];
  DX(idbad)=[];dDX(idbad)=[];
  DY(idbad)=[];dDY(idbad)=[];
  result.Dm(idbad,:)=NaN;
  result.dDm(idbad,:)=NaN;
end

if (plotFit)

  % plot fitted horizontal dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Zm,1e3*DX(:),1e3*dDX(:),'b','o--')
  hold on
  plot(Zp,1e3*model0.twss(idp,4),'g-')
  plot(Zm,1e3*(DX(:)-model0.twss(idm,4)),'r-')
  hold off
  set(gca,'XLim',[Zp(1),Zp(end)])
  hor_line(0,'k:'),ver_line(Z(idc),'k:')
  title('FACET Dispersion Measurement')
  ylabel('Horizontal Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Zp,L(idp),P(idp,:),1);
  set(nfig,'Name','Measured dX/dP')

  % plot fitted vertical dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Zm,1e3*DY(:),1e3*dDY(:),'b','o--')
  hold on
  plot(Zp,1e3*model0.twss(idp,9),'g-')
  hold off
  set(gca,'XLim',[Zp(1),Zp(end)])
  hor_line(0,'k:'),ver_line(Z(idc),'k:')
  title('FACET Dispersion Measurement')
  ylabel('Vertical Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Zp,L(idp),P(idp,:),1);
  set(nfig,'Name','Measured dY/dP')
end

% fit incoming dispersion to a betatron oscillation
% (assumes no dispersion sources)
id1=strmatch('LI19BEG',N);
id2=strmatch('FBEG',N);
jdd=find((Zm>Z(id1))&(Zm<Z(id2))); % BPM data pointers
jdm=idm(jdd); % BPM model pointers
Nf=length(jdm);
u=[DX(jdd),DY(jdd)]';
du=[dDX(jdd),dDY(jdd)]';
A=zeros(2*Nf,4);
R0=rmat(6*id2-5:6*id2,:);
for n=1:Nf
  R=rmat(6*jdm(n)-5:6*jdm(n),:);
  Rp=R/R0;
  A(n,:)=Rp(1,1:4);
  A(Nf+n,:)=Rp(3,1:4);
end
[uf,duf,u0,du0,chi2u,Tu]=fit(A,u,du);
if (normFit)
  [uf,duf,u0,du0,chi2u,Tu]=fit(A,u,du*sqrt(chi2u));
end

result.D1=u0';
result.dD1=du0';

% propagate incoming dispersion forward to the notch collimator
ida=idc(1);Ra=rmat(6*ida-5:6*ida,:);
idb=strmatch('C202069T',N);Rb=rmat(6*idb-5:6*idb,:);
Rab=Rb/Ra;
u=Rab(1:4,1:4)*u0+Rab(1:4,6);
result.Dcn=u';

if (plotLI19)

  % propagate incoming dispersion fit results
  idp=(id1:id2)';
  Np=length(idp);
  xp=zeros(Np,1);yp=zeros(Np,1);
  for n=1:Np
    R=rmat(6*idp(n)-5:6*idp(n),:);
    Rp=R/R0;
    u=Rp(1:4,1:4)*u0;
    [xp(n),yp(n)]=deal(u(1),u(3));
  end

  % horizontal incoming dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DX(jdd)',1e3*dDX(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*xp,'b--', ...
       Z(id2),1e3*xp(end),'r*')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DX/DPX = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane begin',1e3*[u0(1),du0(1),u0(2),du0(2)]);
  title(ttxt)
  ylabel('Horizontal Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Fitted Horizontal Incoming Dispersion')
  
  % vertical incoming dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DY(jdd)',1e3*dDY(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*yp,'b--', ...
       Z(id2),1e3*yp(end),'r*')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DY/DPY = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane begin',1e3*[u0(3),du0(3),u0(4),du0(4)]);
  title(ttxt)
  ylabel('Vertical Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Fitted Vertical Incoming Dispersion')
end

if (propLI19)
  id1=strmatch('LI19BEG',N);
  id2=Ne;
  idp=(id1:id2)';
  jdd=find((Zm>Z(id1))&(Zm<Z(id2))); % BPM data pointers
  jdm=idm(jdd); % BPM model pointers

  % forward-propagate incoming dispersion fit results
  id0=strmatch('FBEG',N);
  R0=rmat(6*id0-5:6*id0,:);
  xp=zeros(Ne,1);yp=zeros(Ne,1);
  for n=1:Ne
    R=rmat(6*n-5:6*n,:);
    Rp=R/R0;
    u=Rp(1:4,1:4)*u0+Rp(1:4,6);
    [xp(n),yp(n)]=deal(u(1),u(3));
  end

  % forward-propagated horizontal incoming dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DX(jdd)',1e3*dDX(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*xp(idp),'b--', ...
       Z(id0),1e3*u0(1),'r*', ...
       Z(jdm),1e3*(xp(jdm)-DX(jdd)'),'r-')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DX/DPX = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane begin',1e3*[u0(1),du0(1),u0(2),du0(2)]);
  title(ttxt)
  ylabel('Horizontal Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Forward-Propagated Horizontal Incoming Dispersion')

  % forward-propagated vertical incoming dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DY(jdd)',1e3*dDY(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*yp(idp),'b--', ...
       Z(id0),1e3*u0(3),'r*', ...
       Z(jdm),1e3*(yp(jdm)-DY(jdd)'),'r-')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DY/DPY = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane begin',1e3*[u0(3),du0(3),u0(4),du0(4)]);
  title(ttxt)
  ylabel('Vertical Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Forward-Propagated Vertical Incoming Dispersion')
end

if (propLI19diff)
  id1=strmatch('LI19BEG',N);
  id2=Ne;
  idp=(id1:id2)';
  jdd=find((Zm>Z(id1))&(Zm<Z(id2))); % BPM data pointers
  jdm=idm(jdd); % BPM model pointers
  Nm=length(jdm);

  % forward-propagate incoming dispersion fit results
  id0=strmatch('FBEG',N);
  R0=rmat(6*id0-5:6*id0,:);
  xp=zeros(Nm,1);yp=zeros(Nm,1);
  for m=1:Nm
    n=jdm(m);
    R=rmat(6*n-5:6*n,:);
    Rp=R/R0;
    u=Rp(1:4,1:4)*u0+Rp(1:4,6);
    [xp(m),yp(m)]=deal(u(1),u(3));
  end

  % forward-propagated horizontal incoming dispersion difference
  nfig=nfig+1;
  result.fig.propLI19diff=figure(nfig); % return figure handle for printing
  clf,subplot
  subplot(211)
  py1=1e3*(DX(jdd)'-model.twss(jdm,4));dpy1=1e3*dDX(jdd)';
  py2=1e3*(xp-model.twss(jdm,4));
  plot_barsc(Z(jdm),py1,dpy1,'b','o')
  hold on
  plot(Z(jdm),py1,'b--',Z(id0),1e3*u0(1),'r*',Z(jdm),py2,'r+-')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)],'XTickLabel',[])
  hor_line(0,'k:')
  ylabel('\DeltaDx (mm)')
  ttxt=sprintf('Forward-Propagated Incoming Dispersion Difference (%s)', ...
    datestr(data.ts));
  title(ttxt)

  % forward-propagated vertical incoming dispersion
  subplot(212)
  py1=1e3*(DY(jdd)'-model.twss(jdm,9));dpy1=1e3*dDY(jdd)';
  py2=1e3*(yp-model.twss(jdm,9));
  plot_barsc(Z(jdm),py1,dpy1,'b','o')
  hold on
  plot(Z(jdm),py1,'b--',Z(id0),1e3*u0(3),'r*',Z(jdm),py2,'r+-')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ylabel('\DeltaDy (mm)')
  xlabel('Z (m)')
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  linkaxes([h0;h1],'x')
  ht=get(h1,'Title');
  set(ht,'FontSize',12)
  
  % show the fit-point location
  axes(h0(1)),ver_line(Z(id0),'r--')
  axes(h0(2)),ver_line(Z(id0),'r--')
  axes(h1),hold on,plot(Z(id0),0,'r*'),hold off

  % output fitted incoming dispersion values
  ttxt=[ ...
    sprintf('DX = %.1f \\pm %.1f mm',1e3*[u0(1),du0(1)]), ...
    sprintf(', DPX = %.1f \\pm %.1f mm',1e3*[u0(2),du0(2)]), ...
    sprintf(', DY = %.1f \\pm %.1f mm',1e3*[u0(3),du0(3)]), ...
    sprintf(', DPY = %.1f \\pm %.1f mm',1e3*[u0(4),du0(4)])];
  title(h0(1),ttxt,'FontSize',9,'VerticalAlignment','middle')

  set(nfig,'Name','Forward-Propagated Incoming Dispersion Difference')
end

% fit leakage dispersion to a betatron oscillation
% (assumes no dispersion sources)
id1=idc(2); % chicane exit
id2=strmatch('B2033301',N)-1; % entrance to spectrometer bend
jdd=find((Zm>Z(id1))&(Zm<Z(id2))); % data pointers
jdm=idm(jdd); % model pointers
Nf=length(jdd);
u=[DX(jdd),DY(jdd)]';
du=[dDX(jdd),dDY(jdd)]';
A=zeros(2*Nf,4);
R0=rmat(6*id1-5:6*id1,:);
for n=1:Nf
  R=rmat(6*jdm(n)-5:6*jdm(n),:);
  Rp=R/R0;
  A(n,:)=Rp(1,1:4);
  A(Nf+n,:)=Rp(3,1:4);
end
[uf,duf,u0,du0,chi2u,Tu]=fit(A,u,du);
if (normFit)
  [uf,duf,u0,du0,chi2u,Tu]=fit(A,u,du*sqrt(chi2u));
end

result.D2=u0';
result.dD2=du0';

% propagate leakage dispersion backward to sYAG
ida=strmatch('P202432T',N);Ra=rmat(6*ida-5:6*ida,:);
idb=idc(2);Rb=rmat(6*idb-5:6*idb,:);
Rab=Rb/Ra;
u=Rab(1:4,1:4)\(u0-Rab(1:4,6));
result.Dsy=u';

if (plotFF)

  % leakage dispersion fit results
  idp=(id1:id2)';
  Np=length(idp);
  xp=zeros(Np,1);yp=zeros(Np,1);
  for n=1:Np
    R=rmat(6*idp(n)-5:6*idp(n),:);
    Rp=R/R0;
    u=Rp(1:4,1:4)*u0;
    [xp(n),yp(n)]=deal(u(1),u(3));
  end

  % horizontal leakage dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DX(jdd)',1e3*dDX(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*xp,'b--', ...
       Z(id1),1e3*xp(1),'r*')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DX/DPX = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane end',1e3*[u0(1),du0(1),u0(2),du0(2)]);
  title(ttxt)
  ylabel('Horizontal Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Fitted Horizontal Leakage Dispersion')

  % vertical leakage dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DY(jdd)',1e3*dDY(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*yp,'b--', ...
       Z(id1),1e3*yp(1),'r*')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DY/DPY = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane end',1e3*[u0(3),du0(3),u0(4),du0(4)]);
  title(ttxt)
  ylabel('Vertical Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Fitted Vertical Leakage Dispersion')
end

if (plotFF2)

  % leakage dispersion fit results (subplots)
  idp=(id1:id2)';
  Np=length(idp);
  xp=zeros(Np,1);yp=zeros(Np,1);
  for n=1:Np
    R=rmat(6*idp(n)-5:6*idp(n),:);
    Rp=R/R0;
    u=Rp(1:4,1:4)*u0;
    [xp(n),yp(n)]=deal(u(1),u(3));
  end
  result.fig.plotFF2 = figure; % return figure handle for printing
  clf,subplot % try not to overwrite any other figures

  % horizontal leakage dispersion
  subplot(211)
  plot_barsc(Z(jdm),1e3*DX(jdd)',1e3*dDX(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*xp,'b--', ...
       Z(id1),1e3*xp(1),'r*')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)],'XTicklabel',[])
  hor_line(0,'k:') %,ver_line(Z(ip),'m--')
  ylabel('Dx (mm)')
  ttxt=sprintf('Fitted LI20 Leakage Dispersion (%s)',datestr(data.ts));
  title(ttxt)

  % vertical leakage dispersion
  subplot(212)
  plot_barsc(Z(jdm),1e3*DY(jdd)',1e3*dDY(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*yp,'b--', ...
       Z(id1),1e3*yp(1),'r*')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:') %,ver_line(Z(ip),'m--')
  ylabel('Dy (mm)')
  xlabel('Z (m)')
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  
  
  
  % show the waist location
  axes(h0(1)),ver_line(Z(ip),'m--')
  axes(h0(2)),ver_line(Z(ip),'m--')
  axes(h1),hold on,plot(Z(ip),0,'m*'),hold off
  
  % output fitted leakage dispersion values
  ttxt=[ ...
    sprintf('DX = %.1f \\pm %.1f mm',1e3*[u0(1),du0(1)]), ...
    sprintf(', DPX = %.1f \\pm %.1f mm',1e3*[u0(2),du0(2)]), ...
    sprintf(', DY = %.1f \\pm %.1f mm',1e3*[u0(3),du0(3)]), ...
    sprintf(', DPY = %.1f \\pm %.1f mm',1e3*[u0(4),du0(4)])];
  title(h0(1),ttxt,'FontSize',9,'VerticalAlignment','middle')
end

if (propFF)
  id1=strmatch('LI19BEG',N);
  id2=Ne;
  idp=(id1:id2)';
  jdd=find((Zm>Z(id1))&(Zm<Z(id2))); % BPM data pointers
  jdm=idm(jdd); % BPM model pointers

  % back-propagate leakage dispersion fit results
  id0=strmatch('CB1RE',N);
  R0=rmat(6*id0-5:6*id0,:);
  xp=zeros(Ne,1);yp=zeros(Ne,1);
  for n=1:Ne
    R=rmat(6*n-5:6*n,:);
    Rp=R/R0;
    u=Rp(1:4,1:4)*u0+Rp(1:4,6);
    [xp(n),yp(n)]=deal(u(1),u(3));
  end

  % back-propagated horizontal leakage dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DX(jdd)',1e3*dDX(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*xp(idp),'b--', ...
       Z(id0),1e3*u0(1),'r*', ...
       Z(jdm),1e3*(xp(jdm)-DX(jdd)'),'r-')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DX/DPX = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane end',1e3*[u0(1),du0(1),u0(2),du0(2)]);
  title(ttxt)
  ylabel('Horizontal Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Back-Propagated Horizontal Leakage Dispersion')

  % back-propagated vertical leakage dispersion
  nfig=nfig+1;
  figure(nfig),clf,subplot
  plot_barsc(Z(jdm),1e3*DY(jdd)',1e3*dDY(jdd)','b','o')
  hold on
  plot(Z(idp),1e3*yp(idp),'b--', ...
       Z(id0),1e3*u0(3),'r*', ...
       Z(jdm),1e3*(yp(jdm)-DY(jdd)'),'r-')
  hold off
  set(gca,'XLim',[Z(id1),Z(id2)])
  hor_line(0,'k:')
  ttxt=sprintf('%s: DY/DPY = %5.1f +- %4.1f mm / %5.1f +- %4.1f mrad', ...
    'Chicane end',1e3*[u0(3),du0(3),u0(4),du0(4)]);
  title(ttxt)
  ylabel('Vertical Dispersion (mm)')
  xlabel({'Z (m)';datestr(data.ts)})
  [h0,h1]=plot_magnets(K(idp,:),Z(idp),L(idp),P(idp,:),1,T(idp,:));
  set(nfig,'Name','Back-Propagated Vertical Leakage Dispersion')
end

% propagate leakage dispersion to PROFs/WIREs/IPs
Dp=zeros(Npm,4);
for n=1:Npm
  R=rmat(6*idpm(n)-5:6*idpm(n),:);
  Rp=R/R0;
  Dp(n,:)=[Rp(1:4,1:4)*u0+Rp(1:4,6)]';
end

result.Dp=Dp;

if (showVal)
  s = sprintf('\n');
  s = [s sprintf(' name      DXmm DPXmr  DYmm DPYmr\n')];
  s = [s sprintf(' --------------------------------\n')];
  for n=1:Npm
    s = [s sprintf(' %-8s %5.1f %5.1f %5.1f %5.1f\n', ...
      deblank(T(idpm(n),:)),1e3*Dp(n,:))]; %#ok<AGROW>
  end
  s = [s sprintf('\n')];
  result.table = s;
  fprintf(s);
end

end
