function model0=FACET18_getModel0(request,request2)
%
% model0=FACET18_getModel0(request,request2);
%
% Generate a design model using ipConfig watchdog data
%
% INPUT
%
%   request   = structure of input parameters
%    .energy  : beam energy at FACET (GeV) [default=20.35]
%    .WIGon   : wiggler ON/OFF flag (1=ON,0=OFF) [default=true]
%    .useAsym : use asymmetric chicane optics [default=false]
%    .tnum    : date number for getting historic Waist Locator values
%               [default=now]
%    .tempDir : folder for MAD input/output files
%               [default=/tmp/MADmodel_<user>_<time>]
%    .clean   : delete MAD input/output files; remove tempDir [default=true]
%    .info    : optics info dialog box ON/OFF [default=true]
%
%   request2  = structure of debug input parameters
%    .R56     : chicane R56 value
%    .wname   : name of x/y waist location
%    .wbetx   : BetaX at waist
%    .wbety   : BetaY at waist
%
% OUTPUT
%
%   model0 = model structure (see help for xtfft2mat, xtffr2mat,
%            xtffw2mat, and xtffs2mat)

% design SURVEY coordinates
mdir='/usr/local/facet/tools/matlab/toolbox/'; % CVS
[tt,K,N,L,P,A,T,E,FDN,coor,S]=xtffs2mat(fullfile(mdir,'FACET_survey.tape'));
idbeg=strmatch('EXPTBEG',T);zbeg=coor(idbeg,3);
idqs0=strmatch('QS0',T);idqs0=idqs0(1);zqs0=coor(idqs0,3);
idend=strmatch('EXPTEND',T);zend=coor(idend,3);

% list of pointers to possible waist locations
prof=strmatch('PROF',K);
wire=strmatch('WIRE',K);
inst=strmatch('INST',K);
ipList=sort([prof;wire;inst]);
ipList=ipList(ipList>idbeg&ipList<idend);

% defaults
energy=20.35;
WIGon=1;
useAsym=false;
tnum=0;
tempDir=['/tmp/MADmodel_',getenv('PHYSICS_USER'),'_',datestr(now,30)];
mkDir=true;
rmDir=true;
clean=true;
opticsInfo=true;
debug=false;

% user requests
if (nargin>0)
  if (isfield(request,'energy'))
    energy=request.energy;
  end
  if (isfield(request,'WIGon'))
    WIGon=request.WIGon;
  end
  if (isfield(request,'useAsym'))
    useAsym=request.useAsym;
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
  if (isfield(request,'info'))
    opticsInfo=request.info;
  end
end
rmDir=(rmDir&clean);

if (nargin>1&&~isempty(request2))
  debug=true;
  R56=round(request2.R56);
  if (~ismember(R56,[5,7,10]))
    error('Unknown R56 config: %d mm?',R56)
  end
  FFloc=request2.wname;
  wbetx=request2.wbetx;
  wbety=request2.wbety;
  id=strmatch(FFloc,N);
  if (isempty(id))
    id=strmatch(FFloc,T);
    if (isempty(id))
      error('Bad waist name (%s)',FFloc)
    end
    FFloc=deblank(N(id,:));
  end
  FFname=deblank(T(id,:));
  wz=coor(id,3);
end

% set up Channel Archiver time range
hstb=(tnum~=0);
if (hstb)
  dt=datenum('00:01')-datenum('00:00'); % 1 minute
  t1=datestr(tnum-dt,'mm/dd/yyyy HH:MM:SS');
  t2=datestr(tnum+dt,'mm/dd/yyyy HH:MM:SS');
  trange={t1;t2};
else
  tnum=now;
end

% get IP Configurator data
if (debug)
  if (useAsym)
    R56sub=sprintf('R56_%dmm_a',R56);
  else
    R56sub=sprintf('R56_%dmm_s',R56);
  end
else
  if (hstb)
    [t,d]=getHistory('SIOC:SYS1:ML00:AO351',trange);
    [dummy,id]=min(abs(t-tnum));
    wzx=d(id(1));
    [t,d]=getHistory('SIOC:SYS1:ML00:AO352',trange);
    [dummy,id]=min(abs(t-tnum));
    wbetx=d(id(1));
    [t,d]=getHistory('SIOC:SYS1:ML00:AO353',trange);
    [dummy,id]=min(abs(t-tnum));
    wzy=d(id(1));
    [t,d]=getHistory('SIOC:SYS1:ML00:AO354',trange);
    [dummy,id]=min(abs(t-tnum));
    wbety=d(id(1));
    [t,d]=getHistory('SIOC:SYS1:ML00:AO357',trange);
    [dummy,id]=min(abs(t-tnum));
    R56=d(id(1));
  elseif (~debug)
    wzx=lcaGetSmart('SIOC:SYS1:ML00:AO351');
    wbetx=lcaGetSmart('SIOC:SYS1:ML00:AO352');
    wzy=lcaGetSmart('SIOC:SYS1:ML00:AO353');
    wbety=lcaGetSmart('SIOC:SYS1:ML00:AO354');
    R56=lcaGetSmart('SIOC:SYS1:ML00:AO357');
  end
  if ((wzx~=wzy)||((wzx<zbeg)||(wzx>zend)))
    error('Unknown waist location(s)')
  else
    wz=wzx;
  end
  R56=round(R56);
  if (~ismember(R56,[5,7,10]))
    error('Unknown R56 config: %d mm?',R56)
  else
    if (useAsym)
      R56sub=sprintf('R56_%dmm_a',R56);
    else
      R56sub=sprintf('R56_%dmm_s',R56);
    end
  end

  % find waist location ... get its name
  z0=round(coor(ipList,3)*100)/100; % rounded to nearest cm
  [dummy,id]=min(abs(round(wzx*100)/100-z0));
  FFloc=deblank(N(ipList(id),:));
  FFname=deblank(T(ipList(id),:));
end

% get QFF2 and QFF4 currents
if (hstb)
  [t,d]=getHistory('LI20:LGPS:3031:BDES',trange);
  [dummy,id]=min(abs(t-tnum));
  BQFF2=d(id(1));
  [t,d]=getHistory('LI20:LGPS:3091:BDES',trange);
  [dummy,id]=min(abs(t-tnum));
  BQFF4=d(id(1));
else
  BQFF2=lcaGetSmart('LI20:LGPS:3031:BDES');
  BQFF4=lcaGetSmart('LI20:LGPS:3091:BDES');
end
ivbu=fliplr(lcaGetSmart('LI20:LGPS:3031:IVBU'));
IQFF2=polyval(ivbu,BQFF2);
ivbu=fliplr(lcaGetSmart('LI20:LGPS:3091:IVBU'));
IQFF4=polyval(ivbu,BQFF4);

if (opticsInfo)
  if (hstb)
    s={datestr(tnum)};
  else
    s=cell(0);
  end
  s=[s;{ ...
    sprintf('Waists @ %s',FFname); ...
    sprintf('BetaX = %.3f m',wbetx); ...
    sprintf('BetaY = %.3f m',wbety); ...
    sprintf('R56 = %.1f mm',-R56); ...
  }];
  helpdlg(s,'MAD design model')
end

% if requested, create temporary folder and cd to it
wd=pwd;
if (~strcmp(tempDir,pwd))
  if (mkDir)
    [s,r]=system(['mkdir ',tempDir]);
  end
  cd(tempDir)
end

% write MAD patch file
PatchFile(R56sub,WIGon,wbetx,wbety,IQFF2,IQFF4,wz,zqs0,FFloc,energy)

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

% populate model0 structure
model0.config.R56=R56;
model0.config.useAsym=useAsym;
model0.config.IPname=FFloc;
model0.config.IPcname=FFname;
model0.config.IPbetx=wbetx;
model0.config.IPbety=wbety;
model0.tt=tt;
model0.K=K;
model0.N=N;
model0.L=L;
model0.P=P;
model0.A=A;
model0.T=T;
model0.E=E;
model0.FDN=FDN;
model0.S=S;
model0.coor=coor;
model0.orbt=orbt;
model0.twss=twss;
model0.rmat=rmat;
model0.chrom=chrom;

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
function PatchFile(R56sub,WIGon,wbetx,wbety,IQFF2,IQFF4,wz,zqs0,FFloc,energy)
% write MAD patch file
fid=fopen('patch.mad8','w');
fprintf(fid,'TITLE "FACET: LI18 to dump (v35)"\n');
fprintf(fid,'! %s\n',datestr(now));
fprintf(fid,'%s\n',R56sub);
if (~WIGon),fprintf(fid,'SET, BP28001, 0\n');end
fprintf(fid,'SET, BXip, %.4f\n',wbetx);
fprintf(fid,'SET, AXip, 0\n');
fprintf(fid,'SET, BYip, %.4f\n',wbety);
fprintf(fid,'SET, AYip, 0\n');
fprintf(fid,'SET, IQFF2, %s\n',madval(IQFF2));
fprintf(fid,'SET, IQFF4, %s\n',madval(IQFF4));
if (wz>=zqs0)
  fprintf(fid,'SET, BXd, 500\n');
  fprintf(fid,'SET, BYd, 500\n');
end
fprintf(fid,'Q203031T, K1=(-0.206010023686E-2)+(-0.680977812426E-2)*IQFF2\n');
fprintf(fid,'Q203041T, K1=(-0.240603186637E-2)+(-0.677223254254E-2)*IQFF2\n');
fprintf(fid,'Q203051T, K1=(-0.228802964532E-2)+(-0.675148387849E-2)*IQFF2\n');
fprintf(fid,'Q203091T, K1=( 0.16690440902E-2 )+( 0.27449054048E-2 )*IQFF4\n');
fprintf(fid,'Q203111T, K1=( 0.130320694128E-2)+( 0.275300986525E-2)*IQFF4\n');
fprintf(fid,'BEAM, ENERGY=E20\n');
fprintf(fid,'USE, (LI20m,LI20)\n');
fprintf(fid,'MATCH, BETX=BX20, ALFX=-AX20, BETY=BY20, ALFY=-AY20\n');
fprintf(fid,'  VARY, QP28021, STEP=1.E-5, LOWER=KLOQFF1, UPPER=KUPQFF1\n');
fprintf(fid,'  VARY, IQFF2,   STEP=1.E-5, LOWER=ILOQFF2, UPPER=IUPQFF2\n');
fprintf(fid,'  VARY, IQFF4,   STEP=1.E-5, LOWER=ILOQFF4, UPPER=IUPQFF4\n');
fprintf(fid,'  VARY, QP28028, STEP=1.E-5, LOWER=KLOQFF5, UPPER=KUPQFF5\n');
fprintf(fid,'  VARY, QP28029, STEP=1.E-5, LOWER=KLOQFF6, UPPER=KUPQFF6\n');
fprintf(fid,'  CONSTR, %s, BETX=BXip, ALFX=AXip, BETY=BYip, ALFY=AYip, X=0\n',FFloc);
fprintf(fid,'  LMDIF, TOL=1.E-20, CALLS=10000\n');
fprintf(fid,'  MIGRAD, TOL=1.E-20, CALLS=10000\n');
fprintf(fid,'ENDMATCH\n');
fprintf(fid,'VALUE, IQFF2,IQFF4\n');
fprintf(fid,'VALUE, QP28021,Q203031T[K1],Q203041T[K1],Q203051T[K1],Q203091T[K1], &\n');
fprintf(fid,'       Q203111T[K1],QP28028,QP28029\n');
fprintf(fid,'MATCH, BETX=BX20, ALFX=-AX20, BETY=BY20, ALFY=-AY20\n');
fprintf(fid,' !VARY, QP28030, STEP=1.E-5, LOWER=KLOQS0, UPPER=KUPQS0\n');
fprintf(fid,'  VARY, QP28031, STEP=1.E-5, LOWER=KLOQS1, UPPER=KUPQS1\n');
fprintf(fid,'  VARY, QP28032, STEP=1.E-5, LOWER=KLOQS2, UPPER=KUPQS2\n');
if (wz<=zqs0)
  fprintf(fid,'  RMATRIX, %s/AEROGEL, RM(1,2)=0, RM(3,4)=0\n',FFloc);
else
  fprintf(fid,'  CONSTR, #E, BETX<BXd, BETY<BYd\n');
end
fprintf(fid,'  LMDIF, TOL=1.E-20\n');
fprintf(fid,'  MIGRAD, TOL=1.E-20\n');
fprintf(fid,'ENDMATCH\n');
fprintf(fid,'VALUE, QP28030,QP28031,QP28032\n');
fprintf(fid,'BEAM, ENERGY=E0\n');
fprintf(fid,'USE, FACET\n');
fprintf(fid,'SAVEBETA, TWSS18, LI17END\n');
fprintf(fid,'SAVEBETA, TWSS20, FBEG\n');
fprintf(fid,'TWISS, BETA0=TWSS0\n');
fprintf(fid,'E18 := TWSS18[ENERGY]-TWSS20[ENERGY]+%s\n',madval(energy));
fprintf(fid,'BEAM, ENERGY=E18\n');
fprintf(fid,'USE, (MODL12B,MODL28)\n');
fprintf(fid,'PRINT, FULL\n');
fprintf(fid,'TWISS, COUPLE, &\n');
fprintf(fid,'  BETX=TWSS18[BETX], ALFX=TWSS18[ALFX], &\n');
fprintf(fid,'  BETY=TWSS18[BETY], ALFY=TWSS18[ALFY], &\n');
fprintf(fid,'  TAPE="twiss.tape", &\n');
fprintf(fid,'  RTAPE="rmat.tape"\n');
fprintf(fid,'BEAM, ENERGY=E18\n');
fprintf(fid,'USE, (MODL12B,MODL28)\n');
fprintf(fid,'PRINT, FULL\n');
fprintf(fid,'TWISS, CHROM, &\n');
fprintf(fid,'  BETX=TWSS18[BETX], ALFX=TWSS18[ALFX], &\n');
fprintf(fid,'  BETY=TWSS18[BETY], ALFY=TWSS18[ALFY], &\n');
fprintf(fid,'  TAPE="chrom.tape"\n');
fprintf(fid,'BEAM, ENERGY=E18\n');
fprintf(fid,'USE, (MODL12B,MODL28)\n');
fprintf(fid,'PRINT, FULL\n');
fprintf(fid,'SURVEY, Z0=1727.2, TAPE="survey.tape"\n');
fprintf(fid,'STOP\n');
fclose(fid);
end