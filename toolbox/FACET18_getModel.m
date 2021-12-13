function model=FACET18_getModel(request)
%
% model=FACET18_getModel(request);
%
% Get FACET LI18-LI20 model
%
% INPUT
%
%   request   = structure of input parameters
%    .energy  : beam energy at FACET (GeV) [default=20.35]
%               (NOTE: if energy=[] you will be prompted)
%    .tnum    : date number for getting historic data [default=now]
%    .tempDir : folder for MAD input/output files
%               [default=/tmp/MADmodel_<user>_<time>]
%    .clean   : delete MAD input/output files; remove tempDir [default=1]
%    .model0  : design model structure
%    .getDB   : get magnet strengths and energy profile from DB [default=1]
%
% OUTPUT
%
%   model : see help for xtfft2mat, xtffr2mat, xtffs2mat, and xtffw2mat

LEMG=5; % LEM_FCET
Cb=1e10/2.99792458e8;

% defaults
energy=20.35;
tnum=0;
tempDir=['/tmp/MADmodel_',getenv('PHYSICS_USER'),'_',datestr(now,30)];
mkDir=true;
rmDir=true;
clean=true;
model0=[];
getDB=true;

% user requests
if (nargin==1)
  if (isfield(request,'energy'))
    energy=request.energy;
  end
  if (isfield(request,'tnum'))
    tnum=request.tnum;
  end
  if (isfield(request,'tempDir'))
    tempDir=request.tempDir;
    if (exist(tempDir)==7)
      mkDir=false;
      rmDir=false;
    end
  end
  if (isfield(request,'clean'))
    clean=request.clean;
  end
  if (isfield(request,'model0'))
    model0=request.model0;
  end
  if (isfield(request,'getDB'))
    getDB=request.getDB;
  end
end
brho=Cb*energy;
rmDir=(rmDir&clean);
hstb=(tnum~=0);

% dbData.mat will be in caller's working directory
wd=pwd;
dbFile=fullfile(wd,'dbData.mat');

% if requested, create temporary folder and cd to it
if (~strcmp(tempDir,pwd))
  if (mkDir)
    [s,r]=system(['mkdir ',tempDir]);
  end
  cd(tempDir)
end

% quadrupoles
qname={ ...
  'LI18:QUAD:201';  ... %  1=Q18201
  'LI18:QUAD:301';  ... %  2=Q18301
  'LI18:QUAD:401';  ... %  3=Q18401
  'LI18:QUAD:501';  ... %  4=Q18501
  'LI18:QUAD:601';  ... %  5=Q18601
  'LI18:QUAD:701';  ... %  6=Q18701
  'LI18:QUAD:801';  ... %  7=Q18801
  'LI18:QUAD:901';  ... %  8=Q18901
  'LI19:QUAD:201';  ... %  9=Q19201
  'LI19:QUAD:301';  ... % 10=Q19301
  'LI19:QUAD:401';  ... % 11=Q19401
  'LI19:QUAD:501';  ... % 12=Q19501
  'LI19:QUAD:601';  ... % 13=Q19601
  'LI19:QUAD:701';  ... % 14=Q19701
  'LI19:QUAD:801';  ... % 15=Q19801
  'LI19:QUAD:901';  ... % 16=Q19901
  'LI20:QUAS:2061'; ... % 17=Q1EL
  'LI20:QUAD:2086'; ... % 18=SQ1
  'LI20:QUAS:2131'; ... % 19=Q2EL
  'LI20:QUAS:2151'; ... % 20=Q3EL_1
  'LI20:QUAS:2161'; ... % 21=Q3EL_2
  'LI20:QUAS:2201'; ... % 22=Q4EL_1
  'LI20:QUAS:2211'; ... % 23=Q4EL_2
  'LI20:QUAS:2221'; ... % 24=Q4EL_3
  'LI20:QUAS:2231'; ... % 25=Q5EL
  'LI20:QUAS:2251'; ... % 26=Q6E
  'LI20:QUAS:2262'; ... % 27=Q5ER
  'LI20:QUAS:2281'; ... % 28=Q4ER_1
  'LI20:QUAS:2291'; ... % 29=Q4ER_2
  'LI20:QUAS:2301'; ... % 30=Q4ER_3
  'LI20:QUAS:2341'; ... % 31=Q3ER_1
  'LI20:QUAS:2351'; ... % 32=Q3ER_2
  'LI20:QUAS:2371'; ... % 33=Q2ER
  'LI20:QUAS:2441'; ... % 34=Q1ER
  'LI20:QUAS:3011'; ... % 35=QFF1
  'LI20:QUAD:3015'; ... % 36=SQ2
  'LI20:QUAS:3031'; ... % 37=QFF2
  'LI20:QUAS:3041'; ... % 38=QFF2
  'LI20:QUAS:3051'; ... % 39=QFF2
  'LI20:QUAS:3091'; ... % 40=QFF4
  'LI20:QUAS:3111'; ... % 41=QFF4
  'LI20:QUAS:3141'; ... % 42=QFF5
  'LI20:QUAS:3151'; ... % 43=QFF6
  'LI20:QUAS:3204'; ... % 44=QS0
  'LI20:QUAS:3261'; ... % 45=QS1
  'LI20:QUAS:3311'; ... % 46=QS2
};
qpsid=[ ...
   1, 2, 3, 4, 5, 6, 7, 8, ...
   9,10,11,12,13,14,15,16, ...
  17,19,20,22,22,24,24,24,26,28, ...
  26,24,24,24,22,22,20,17,34,35, ...
  36,36,36,37,37,38,39,40,41,42; ...
   0, 0, 0, 0, 0, 0, 0, 0, ...
   0, 0, 0, 0, 0, 0, 0, 0, ...
  18, 0,21,23,23,25,25,25,27, 0, ...
  29,30,30,30,31,31,32,33, 0, 0, ...
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
];
Nq=length(qname);

% sextupoles
sname={ ...
  'LI20:SXTS:2145'; ... % 1=S1EL
  'LI20:SXTS:2165'; ... % 2=S2EL
  'LI20:SXTS:2195'; ... % 3=S3EL_1
  'LI20:SXTS:2225'; ... % 4=S3EL_2
  'LI20:SXTS:2275'; ... % 5=S3ER_1
  'LI20:SXTS:2305'; ... % 6=S3ER_2
  'LI20:SXTS:2335'; ... % 7=S2ER
  'LI20:SXTS:2365'; ... % 8=S1ER
};
spsid=[43,44,45,45,46,46,47,48];
Ns=length(sname);

% power supplies (EPICS-style PVs)
pslist={ ...
  'LI18:QUAD:201'; ...  %  1=Q18201
  'LI18:QUAD:301'; ...  %  2=Q18301
  'LI18:QUAD:401'; ...  %  3=Q18401
  'LI18:QUAD:501'; ...  %  4=Q18501
  'LI18:QUAD:601'; ...  %  5=Q18601
  'LI18:QUAD:701'; ...  %  6=Q18701
  'LI18:QUAD:801'; ...  %  7=Q18801
  'LI18:QUAD:901'; ...  %  8=Q18901
  'LI19:QUAD:201'; ...  %  9=Q19201
  'LI19:QUAD:301'; ...  % 10=Q19301
  'LI19:QUAD:401'; ...  % 11=Q19401
  'LI19:QUAD:501'; ...  % 12=Q19501
  'LI19:QUAD:601'; ...  % 13=Q19601
  'LI19:QUAD:701'; ...  % 14=Q19701
  'LI19:QUAD:801'; ...  % 15=Q19801
  'LI19:QUAD:901'; ...  % 16=Q19901
  'LI20:LGPS:2060'; ... % 17=Q1E
  'LI20:LGPS:2061'; ... % 18=Q1EL
  'LI20:QUAD:2086'; ... % 19=SQ1
  'LI20:LGPS:2130'; ... % 20=Q2E
  'LI20:LGPS:2131'; ... % 21=Q2EL
  'LI20:LGPS:2150'; ... % 22=Q3E
  'LI20:LGPS:2151'; ... % 23=Q3EL
  'LI20:LGPS:2200'; ... % 24=Q4E
  'LI20:LGPS:2201'; ... % 25=Q4EL
  'LI20:LGPS:2230'; ... % 26=Q5E
  'LI20:LGPS:2231'; ... % 27=Q5EL
  'LI20:LGPS:2251'; ... % 28=Q6E
  'LI20:LGPS:2262'; ... % 29=Q5ER
  'LI20:LGPS:2281'; ... % 30=Q4ER
  'LI20:LGPS:2341'; ... % 31=Q3ER
  'LI20:LGPS:2371'; ... % 32=Q2ER
  'LI20:LGPS:2441'; ... % 33=Q1ER
  'LI20:LGPS:3011'; ... % 34=QFF1
  'LI20:QUAD:3015'; ... % 35=SQ2
  'LI20:LGPS:3031'; ... % 36=QFF2
  'LI20:LGPS:3091'; ... % 37=QFF4
  'LI20:LGPS:3141'; ... % 38=QFF5
  'LI20:LGPS:3151'; ... % 39=QFF6
  'LI20:LGPS:3204'; ... % 40=QS0
  'LI20:LGPS:3261'; ... % 41=QS1
  'LI20:LGPS:3311'; ... % 42=QS2
  'LI20:LGPS:2145'; ... % 43=S1E-L
  'LI20:LGPS:2165'; ... % 44=S2E-L
  'LI20:LGPS:2195'; ... % 45=S3E-L
  'LI20:LGPS:2275'; ... % 46=S3E-R
  'LI20:LGPS:2335'; ... % 47=S2E-R
  'LI20:LGPS:2365'; ... % 48=S1E-R
};
Nps=length(pslist);

% get power supply setpoints and currents
if (~getDB&&~exist(dbFile,'file'))
  warning('File dbData.mat does not exist ... will get data from DB')
  getDB=false;
end
if (getDB)
  if (hstb)
    Bps=zeros(Nps,1);
    Ips=zeros(Nps,1);
    for n=1:Nps
      Bps(n)=dbGetHist(pslist{n},tnum);
      query=strcat(SLCname(pslist{n}),':IVBU');
      d=num2cell(toArray(pvaGet(query, AIDA_DOUBLE_ARRAY)));
      ivb=fliplr([d{:}]);
      Ips(n)=polyval(ivb,Bps(n));
    end
  else
    [Bps,Ips]=dbGetFast(pslist);
  end
  save(dbFile,'Bps','Ips')
else
  load(dbFile,'Bps','Ips')
end

% linac energy profile (convert arrays to column vectors)
if (getDB)
  [kname,kstat,kenld,kphas,kfudg,kgain]=FACET_getEnergyProfile(LEMG,tnum);
  kname=reshape(kname',[],1);
  kstat=reshape(kstat',[],1);
  kenld=reshape(kenld',[],1);
  kphas=reshape(kphas',[],1);
  kfudg=reshape(kfudg',[],1);
  kgain=reshape(kgain',[],1);
  save(dbFile,'kname','kstat','kenld','kphas','kfudg','kgain','-append')
else
  load(dbFile,'kname','kstat','kenld','kphas','kfudg','kgain')
end

% transfer energy profile to copies of model0 parameter and energy arrays
K0=model0.K;
N0=model0.N;
L0=model0.L;
P0=model0.P;P=P0;
E0=model0.E;E=E0;
id=(1:strmatch('FBEG',N0))';
ida=intersect(strmatch('LCAV',K0),id);
name=unique(N0(ida,1:7),'rows');
[nrow,ncol]=size(name);
for n=1:nrow
  micr=strcat('LI',name(n,2:3));
  unit=str2num(name(n,4:7));
  pvname=sprintf('%s:KLYS:%d',micr,unit);
  idpv=strmatch(pvname,kname);
  id=strmatch(name(n,:),N0);
  dE0=sum(P0(id,6));
  if (dE0~=0)
    f=P0(id,6)/dE0;
  else
    dL0=sum(L0(id));
    f=L0(id)/dL0;
  end
  P(id,6)=kstat(idpv)*kfudg(idpv)*kenld(idpv)*f; % MeV
  P(id,7)=kphas(idpv)/360; % rad/2pi
end

% set up energy profile
ida=strmatch('LCAV',K0);
dEtot=1e-3*sum(P(ida,6).*cosd(P(ida,7)*360)); % GeV
Etot=energy-dEtot; % initial energy
for n=1:length(E)
  if (strcmp(K0(n,:),'LCAV')) %#ok<COLND>
    Etot=Etot+1e-3*P(n,6)*cosd(P(n,7)*360);
  end
  E(n)=Etot;
end

% quadrupole K1s
k1=zeros(Nq,1);
for n=1:Nq
  [micr,r]=strtok(qname{n},':');
  [prim,r]=strtok(r,':');
  [unit,r]=strtok(r,':');unit=str2num(unit);
  name=sprintf('Q%02d%04dT',micr2bitid(micr),unit);
  id=strmatch(name,N0);
  brho=Cb*E(id(1));
  m1=qpsid(1,n); % bulk
  m2=qpsid(2,n); % boost
  B=Bps(m1);
  I=Ips(m1);
  if (m2~=0)
    B=B+Bps(m2);
    I=I+Ips(m2);
  end
  if ((B==0)&&(I==0))
    k1(n)=0;
  else
    query=strcat(qname{n},':IVBU');
    ivb=fliplr(lcaGetSmart(query));
    p=ivb;p(end)=p(end)-I;r=roots(p);r=r(imag(r)==0);
    [dummy,id]=min(abs(r-B));
    B=r(id);
    query=strcat(qname{n},':LEFF');
    leff=lcaGetSmart(query);
    k1(n)=B/(brho*leff);
  end
end

% sextupole K2s
k2=zeros(Ns,1);
for n=1:Ns
  [micr,r]=strtok(sname{n},':');
  [prim,r]=strtok(r,':');
  [unit,r]=strtok(r,':');unit=str2num(unit);
  name=sprintf('S%02d%04dT',micr2bitid(micr),unit);
  id=strmatch(name,N0);
  brho=Cb*E(id(1));
  m=spsid(n);
  B=Bps(m);
  I=Ips(m);
  if ((B==0)&&(I==0))
    k2(n)=0;
  else
    query=strcat(sname{n},':IVBU');
    ivb=fliplr(lcaGetSmart(query));
    p=ivb;p(end)=p(end)-I;r=roots(p);r=r(imag(r)==0);
    [dummy,id]=min(abs(r-B));
    B=r(id);
    query=strcat(sname{n},':LEFF');
    leff=lcaGetSmart(query);
    k2(n)=B/(brho*leff);
  end
end

% write MAD patch file
fid=fopen('patch.mad8','w');
fprintf(fid,'TITLE "FACET: LI18 to dump (v35)"\n');
fprintf(fid,'! %s\n',datestr(now));
fprintf(fid,'BEAM, ENERGY=E0\n');
fprintf(fid,'USE, FACET\n');
fprintf(fid,'SAVEBETA, TWSS18, LI18BEG\n');
fprintf(fid,'TWISS, BETA0=TWSS0\n');
fprintf(fid,'\n');
id0=strmatch('DBMARK13',N0);
id=(1:strmatch('FBEG',N0))';
id=intersect(strmatch('LCAV',K0),id);
noff=max(find(id<id0));
for n=1:length(id)
  if (id(n)<id0)
    pid(1)=12;
    pid(2)=n+346; % KLUGE!
  else
    pid(1)=28;
    pid(2)=n-noff;
  end
  pval=[P(id(n),6),P(id(n),7)]; % MeV,rad
  fprintf(fid,'SET, AP%02d%03d, %s\n',pid(1),pid(2),madval(pval(1)));
  fprintf(fid,'SET, PP%02d%03d, %s\n',pid(1),pid(2),madval(pval(2)));
end
id=strmatch('QUAD',K0);id=id(1:2:end);
noff=max(find(id<id0));
for n=1:Nq
  if (id(n)<id0)
    pid(1)=12;
    pid(2)=n+64; % KLUGE!
  else
    pid(1)=28;
    pid(2)=n-noff;
  end
  fprintf(fid,'SET, QP%02d%03d, %s\n',pid(1),pid(2),madval(k1(n)));
end
for n=1:Ns
  fprintf(fid,'SET, SP28%03d, %s\n',n,madval(k2(n)));
end
fprintf(fid,'\n');
fprintf(fid,'BEAM, ENERGY=%s\n',madval(E(1)));
fprintf(fid,'USE, (MODL12B,MODL28)\n');
fprintf(fid,'PRINT, FULL\n');
fprintf(fid,'TWISS, COUPLE, &\n');
fprintf(fid,'  BETX=TWSS18[BETX], ALFX=TWSS18[ALFX], &\n');
fprintf(fid,'  BETY=TWSS18[BETY], ALFY=TWSS18[ALFY], &\n');
fprintf(fid,'  TAPE="twiss.tape", &\n');
fprintf(fid,'  RTAPE="rmat.tape"\n');
fprintf(fid,'BEAM, ENERGY=%s\n',madval(E(1)));
fprintf(fid,'USE, (MODL12B,MODL28)\n');
fprintf(fid,'PRINT, FULL\n');
fprintf(fid,'TWISS, CHROM, &\n');
fprintf(fid,'  BETX=TWSS18[BETX], ALFX=TWSS18[ALFX], &\n');
fprintf(fid,'  BETY=TWSS18[BETY], ALFY=TWSS18[ALFY], &\n');
fprintf(fid,'  TAPE="chrom.tape"\n');
fprintf(fid,'BEAM, ENERGY=%s\n',madval(E(1)));
fprintf(fid,'USE, (MODL12B,MODL28)\n');
fprintf(fid,'PRINT, FULL\n');
fprintf(fid,'SURVEY, Z0=1727.2, TAPE="survey.tape"\n');
fprintf(fid,'STOP\n');
fclose(fid);

% run MAD ... get model
madbin='/home/physics/mdw/mad8/mad';
madin='/home/fphysics/mdw/FACET_MAD_model/FACET.mad8';
cmd=[madbin,' ',madin];
[iss,r]=system(cmd);
[tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat('twiss.tape');
[~,~,~,~,~,~,~,~,~,rmat,~]=xtffr2mat('rmat.tape');
[~,~,~,~,~,~,~,~,~,chrom,~,~]=xtffw2mat('chrom.tape');
% iss=fixSurveyTapeFile('survey.tape',E);
[~,~,~,~,~,~,~,~,~,coor,~]=xtffs2mat('survey.tape');

% populate model structure
if (tnum==0)
  model.tnum=now;
else
  model.tnum=tnum;
end
model.tt=tt;
model.K=K;
model.N=N;
model.L=L;
model.P=P;
model.A=A;
model.T=T;
model.E=E;
model.FDN=FDN;
model.S=S;
model.coor=coor;
model.orbt=orbt;
model.twss=twss;
model.rmat=rmat;
model.chrom=chrom;

% if requested, clean up
if (clean)
  delete(strcat(tempDir,'/*'))
  if (rmDir)
    [s,r]=system(['rmdir ',tempDir]);
  end
end

% go back to original working folder
if (~strcmp(pwd,wd))
  cd(wd)
end

end
