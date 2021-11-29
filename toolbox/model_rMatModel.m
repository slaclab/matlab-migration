function [rMat,zPos,lEff,en,reg]=model_rMatModel(name,nameTo,rOpts,varargin)

% NOTE: 3 "import" calls had to be commented out below ...
%       waiting for AIDA integration with Matlab 2019a

% History:
%   12-Feb-2020, M. Woodley
%    * merge with T. Maxwell's updated script; remove non-production debug code
%   15-Jan-2020, M. Woodley
%    * use new model_rMatModelBL function to select beam path / beam line
%   05-Jun-2019, M. Woodley
%    * introduce AD_ACCEL paths
%    * allow MULTIPOLE elements (K0L or K1L only)
%    * model_beamLineUpdate needs to be modified for MULTIPOLEs
%   20-Mar-2018, M. Woodley
%    * introduce LCLS1, LCLS2 (sc and cu), and FACET2
%   10-May-2017, M. Woodley (OPTICS=LCLS05JUN17)
%    * update "start z" for Aline

% Note for syntax:
%   rOpts for the string 'TYPE=[DESIGN/EXTANT]', TYPE is not retrieved from
%   MODEL_INIT globals.
%   varargin can be structure of options or parameter/value pairs
%   Requesting only Z, LEFF, E, etc in options but with multiple output
%   values replaces the first output parameter with the one requested (as
%   always). Requesting only one output parameter will return only that
%   parameter.

if (nargin<3),rOpts={};end
if (nargin<2),nameTo={};end
if (isempty(rOpts)),rOpts={};end
if (isempty(nameTo)),nameTo={};end

% ------------------------------------------------------------------------------

name=cellstr(name);
if (~strcmp(name,'*'))
  name=model_nameConvert(name,'MAD');
end
nameTo=cellstr(nameTo);
nameTo=model_nameConvert(nameTo,'MAD');
rOpts=cellstr(rOpts);
UseOldSelPosFunction=1;
IdSelPosUse=find(cellfun(@(x) strncmpi(x,'SelPosUse=',10),rOpts));
if(~isempty(IdSelPosUse))
   if(strcmpi(rOpts{IdSelPosUse(1)}(10:end),'=BBA')), UseOldSelPosFunction=0; end
end
rOpts(IdSelPosUse)=[];
%nList=max([numel(name),numel(nameTo),size(rOpts,1)])*(numel(name)>0);
nList=max([numel(name),numel(nameTo)])*(numel(name)>0); 
rMat=zeros(6,6,nList);
[zPos,lEff,en,reg,k]=deal(zeros(1,nList));

% generate bLine and initial conditions
[bLine,startZ,startE,idE0,idTW0]=model_rMatModelBL(name,rOpts);
bl={'generator',startZ,startE,idE0,idTW0}; % bl{1} is not used

% define available options with defaults
optsdef=struct( ...
  'Z',0, ...
  'LEFF',0, ...
  'EN',0, ...
  'K',0, ...
  'design',0, ...
  'init',0 ...
  );

% use default options if OPTS is undefined
opts=util_parseOptions(varargin{:},optsdef);

% determine if DESIGN
if (~isempty(rOpts))
  isType=find(cellfun(@(x) strncmpi(x,'TYPE=',5),rOpts),1,'last');
  %isType=find(strncmpi(rOpts(1,:),'TYPE=',5),1,'last');
  if (~isempty(isType)&&strcmpi(rOpts{isType}(6:end),'DESIGN'))
    opts.design=1;
  end
end

% get LEM energy setpoints if necessary
if (((~opts.Z)&&(~opts.LEFF)||(opts.EN))&& ...
    ((~opts.init)&&(~opts.design)))
  beamPathIndx = find(cellfun(@(x) strncmpi(x,'BEAMPATH=',9),rOpts),1,'last');
  beamPath = strrep(rOpts{beamPathIndx}, 'BEAMPATH=', '');
  energyDef=model_energySetPoints([],[],beamPath);
end

% ------------------------------------------------------------------------------

resList=0;
bName=fieldnames(bLine);
bLine=struct2cell(bLine)';
for m=1:numel(bLine)
  isBl=(strcmp(name,'*')|strcmp(name,bName{m}));
  beamLine=bLine{m};
  beamLine=model_beamLineKlysNameChange(beamLine);
  if (isBl)
    nBl=size(beamLine,1);
    res=true(nBl,1);
    [id,idZ]=deal((1:nBl)');
    idTo=zeros(nBl,1);
  else
    myOpts=rOpts(cellfun(@(x) strncmpi(x,'POS=',4),rOpts)| ...
                 cellfun(@(x) strncmpi(x,'POSB=',5),rOpts))'; % row vector!
    myOpts=myOpts(:);
    [res,id,idTo,idZ]=parseBeamLine(beamLine,name,nameTo,myOpts,UseOldSelPosFunction);
   %[res,id,idTo,idZ]=parseBeamLine(beamLine,name,nameTo,rOpts);
  end
  res=(res&(~resList));
  
  if (any(res))
    resList=(resList|res);
    enDef=bl{3}(min(m,end));
    beamLine=model_beamLineZAppend(beamLine,bl{2}(min(m,end)));
    beamLine=model_beamLineLAppend(beamLine);
    beamLine=model_beamLineEAppend(beamLine,enDef);
    if (((~opts.Z)&&(~opts.LEFF)||opts.EN)&&((~opts.init)&&(~opts.design)))&&~isempty(bl{4})
      enDef=energyDef(abs(bl{4}(min(m,end))))*sign(bl{4}(min(m,end)));
      beamLine=model_beamLineAmpPhUpdate(beamLine,id,idTo,sign(enDef));
      beamLine=model_beamLineEAppend(beamLine,enDef,energyDef(end));
      
    end
    if ((nargout>1)||opts.Z)
        if(UseOldSelPosFunction), zPos(res)=[beamLine{idZ(res),5}]; else, zPos(res)=[beamLine{idTo(res),5}]; end       
    end
    if ((nargout>2)||opts.LEFF)
        if(UseOldSelPosFunction), lEff(res)=[beamLine{idZ(res),7}]; else, lEff(res)=[beamLine{idTo(res),7}]; end
    end
    if ((nargout>3)||opts.EN)
      if(UseOldSelPosFunction), en(res)=[beamLine{idZ(res),6}]; else, en(res)=[beamLine{idTo(res),6}]; end
      reg(res)=bl{5}(min(m,end));
    end
    if ((nargout>5)||opts.K)
      isQ=res;
      isQ(res)=strcmp(beamLine(idZ(res),1),'qu');
      par=vertcat(beamLine{idZ(res&isQ),4});
      par=reshape(par,[],max(1,size(par,2)));
      k(res&isQ)=par(:,1);
    end
    if ((~opts.Z)&&(~opts.LEFF)&&(~opts.EN)&&(~opts.K))
      idOff=0;
      if (~opts.init)
        idAdd=0;
        beamLine=beamLine(1:min(end,max([id(res);idTo(res)]+idAdd)),:);
        if (~any(res&(~idTo)))
          idOff=max(0,min([id(res);idTo(res)]-1-idAdd));
          beamLine=beamLine(idOff+1:end,:);
        end
      end
      beamLine=model_beamLineUpdate(beamLine,opts);
      rList=getRMat(beamLine);
      rMat(:,:,res&(~idTo))=rList(:,:,id(res&(~idTo)));
      for j=find(res&idTo)'
        rMat(:,:,j)=rList(:,:,idTo(j)-idOff)*inv(rList(:,:,id(j)-idOff));
      end
    end
  end
  if (all(resList))
      break,
  end
end

if (opts.Z),rMat=zPos;end
if (opts.LEFF),rMat=lEff;end
if (opts.EN),rMat=en;end
if (opts.K),rMat=k;end
if isBl
  isName=~strcmp(beamLine(:,2),'');
  isLen=[beamLine{:,7}]' > 0 & isName;
  idLen=find(isLen);
  [d,idU]=unique(beamLine(end:-1:1,2)); % Unique last elements of reversed list
  % Use 'legacy' to enforce same behavior in future version of UNIQUE. See
  % 2012a documentation. Ironically the pending change would have addressed
  % the issue addressed here by flipping the array passed to unique.
  idU=size(beamLine,1)+1-idU; % Get indices of unique first elements
  idLen=idU(isLen(idU)); % Only use indices of elements with length
  [id,idSort]=sort([find(isName);idLen-1]);
  id2=[find(isName);idLen];id2=id2(idSort);
  if (ndims(rMat)==3)
    rMat={rMat(:,:,id),beamLine(id2,2)};
  else
    rMat={rMat(id),beamLine(id2,2)};
  end
  if (numel(zPos)>1),zPos=zPos(id);end
  if (numel(lEff)>1),lEff=lEff(id2);end
  if (numel(en)>1),en=en(id);end
  if (numel(reg)>1),reg=reg(id2);end
end

function [res,id,idTo,idZ]=parseBeamLine(beamLine,name,nameTo,opts,UseOldSelPosFunction)

% initialize names
nList=max([numel(name),numel(nameTo),size(opts,1)])*(numel(name)>0);
if (numel(name)==1),name(end+1:nList)=name;end
[res,idB,idZ,idE]=findId(beamLine,name);

if (isempty(nameTo)) % default position is 'END'
    if(UseOldSelPosFunction), id=selPos(opts,'POS=',idE,[idB,idZ,idE]); else, id=selPos2(opts,'POS=',idE,[idB,idZ,idE]); end
        
  idTo=zeros(nList,1);
else % default position is 'MID'
  [idToB,idToM,idToE]=deal(zeros(nList,1));
  [resTo,idToB(:),idToM(:),idToE(:)]=findId(beamLine,nameTo);
  if(UseOldSelPosFunction), id=selPos(opts,'POS=',idZ,[idB,idZ,idE]); else, id=selPos2(opts,'POS=',idZ,[idB,idZ,idE]); end
  if(UseOldSelPosFunction), idTo=selPos(opts,'POSB=',idToM,[idToB,idToM,idToE]); else, idTo=selPos2(opts,'POSB=',idToM,[idToB,idToM,idToE]); end
  res=(res&resTo);
end


function [res,idB,idM,idE]=findId(beamLine,name)

[name,d,idU]=unique(name);
[isName,idName]=ismember(beamLine(:,2),name);
num=find(isName);idName=idName(isName);
idB=accumarray(idName,num,[numel(name),1],@min)-1;
idE=accumarray(idName,num,[numel(name),1],@max);
idM=accumarray(idName,num,[numel(name),1],@(x) subsref(sort(x),struct('type','()','subs',{{ceil(numel(x)/2)}})));
idB=idB(idU,1);idM=idM(idU,1);idE=idE(idU,1);
res=(idE>0);


function pos=selPos(opts,tag,pos,posList)

if (isempty(opts)),return,end
opts = opts(:)';   
is=strncmpi(opts,tag,length(tag));
use=any(is,2);
id=max(is(use,:)*diag(1:size(opts,2)),[],2); 

tags={'BEG','MID','END'};
for j=1:numel(tags)
  isTag=use;
  isTag(use)=strcmpi(opts(reshape(find(use),[],1)+(id-1)*numel(use)),[tag,tags{j}]);
  if ((numel(use)==1)&&any(isTag)),isTag=':';end
  pos(isTag)=posList(isTag,j);
end

function pos=selPos2(opts,tag,pos,posList)
if (isempty(opts)),return,end
tags={'BEG','MID','END'};
for II=1:length(tags)
        substRule=find(cellfun(@(x) any(strfind(x,tag)) & any(strfind(x,tags{II})),opts));
        pos(substRule)=posList(substRule,II);
end

function beamLine=model_beamLineZAppend(beamLine,z0)

z=reshape(cumsum([beamLine{:,3}]),[],1);
beamLine(:,5)=reshape(num2cell(z0+z),[],1);


%{
function [v,vp]=model_beamLineSAppend(beamLine,v0,vp0)

n=size(beamLine,1);
[th,ph]=deal(zeros(n,1));
isB=strcmp(beamLine(:,1),'be');
item4List=reshape(vertcat(beamLine{isB,4}),[],7)*[eye(7,1),[zeros(6,1);1]];
th(isB)=-item4List(:,1).*cos(item4List(:,2));
ph(isB)=-item4List(:,1).*sin(item4List(:,2));

cth=vp0(1)+cumsum(th);
cph=vp0(2)+cumsum(ph);
cth2=cth-th/2;
cph2=cph-ph/2;
lEff=reshape([beamLine{:,4}],[],1);
lEff(isB)=lEff(isB).*util_sinc(item4List(:,1)/2);
vp=lEff(:,[1 1 1]).*[sin(cth2),sin(cph2),cos(cth2).*cos(cph2)];
v=repmat(v0,n,1)+cumsum(vp);
vp=[cth,cph];
%}


function beamLine=model_beamLineLAppend(beamLine)

[a,d,idU]=unique(beamLine(:,2));
lEff=accumarray(idU(:),reshape([beamLine{:,3}],[],1));
beamLine(:,7)=reshape(num2cell(lEff(idU,1)),[],1);


function beamLine=model_beamLineEAppend(beamLine,e0,eEnd)

isACC=strcmp(beamLine(:,1),'lc');
gain=zeros(size(beamLine,1),1);
ampPh=reshape(vertcat(beamLine{isACC,4}),[],3);
gain(isACC)=ampPh(:,2).*cos(ampPh(:,3))*1e-3; % GeV
if (e0<0) % e0 is energy at end of beamLine
  e0=-e0-sum(gain);
end
%lastACC = find(strcmp(beamLine(:,1),'lc'), 1, 'last' );
endCLTH_1 = find(strcmp(beamLine(:,2),'ENDCLTH_1'), 1, 'last' );
energy = e0+cumsum(gain);

if nargin < 3, eEnd = max(energy); end

energy(endCLTH_1:end) = eEnd;
beamLine(:,6)=reshape(num2cell(energy),[],1);


function [beamLine,nameAcc,isAcc]=model_beamLineKlysNameChange(beamLine)
% change the names of certain accelerating structures in beamLine

[sys,accelerator]=getSystem();

% change MAD deck accelerating structure names to Matlab names
isAcc=strcmp(beamLine(:,1),'lc');
nameAcc=beamLine(isAcc,2);
nameAcc=regexprep(nameAcc,'K21_1\w','L1S');
if (~any(strcmp(nameAcc,'K11_1B1')))
  nameAcc=regexprep(nameAcc,'K11_1\w','L1SB');
end
if (~ismember({'NLCTA'},accelerator))
  nameAcc=regexprep(nameAcc,'K(\d\d)(_|00)(\d)\w+','$1-$3');
end
beamLine(isAcc,2)=nameAcc;


function beamLine=model_beamLineAmpPhUpdate(beamLine,id,idTo,back)

% find unique names of accelerating structures in beamLine
[beamLine,nameAcc,isAcc]=model_beamLineKlysNameChange(beamLine);
[nameAcc,d,idAcc]=unique(nameAcc);
idAcc=reshape(idAcc,[],1);

% find device request range
is=model_energyKlys(nameAcc,1);
is0=cell2mat(struct2cell(is)');
id=[id;idTo];
range=[min(id(id>0)),max(id(id>0))];
if (~any(idTo)),range(1)=1;end
idK=is0(idAcc,:).*repmat(find(isAcc),1,size(is0,2));
idK((idK<range(1))|(idK>range(2)))=0;
use=any(idK);
is0(:,~use)=0;
isU=any(is0,2);

% get design energy profile
ampPh=reshape(vertcat(beamLine{isAcc,4}),[],3);
ampU=accumarray(idAcc,ampPh(:,2));
phU=accumarray(idAcc,ampPh(:,3),[],@max)*180/pi;
powFac=ampPh(:,2)./ampU(idAcc,1);
lenD=reshape(vertcat(beamLine{isAcc,3}),[],1);
len=reshape(vertcat(beamLine{isAcc,7}),[],1);
powFac(isnan(powFac))=lenD(isnan(powFac))./len(isnan(powFac));

% get amplitude & phase (default from beamLine)
aDes(~isU,1)=ampU(~isU);
pDes(~isU,1)=phU(~isU);

switch beamLine{end,2}
    case 'ENDDMPH_2', opts.region='CU_HXR';
    case 'ENDDMPS_2', opts.region='CU_SXR';
    case 'ENDSPECT20', opts.region='F2_ELEC';
    otherwise, opts.region='CU_HXR';
end
[aDes(isU,1),pDes(isU,1)]=model_energyKlys(nameAcc(isU), 0, opts);

% fudge amplitude & phase if forward energy summation
if (back>0)
  [d,d,aDes,pDes]=model_energyFudge(aDes,pDes,is,2,opts.region);
end

% update amp and phase in beamLine
ampPh(:,2)=aDes(idAcc).*powFac; % in MeV
ampPh(:,3)=pDes(idAcc)*pi/180; % in radians
beamLine(isAcc,4)=reshape(num2cell(ampPh,2),[],1);


function beamLine=model_beamLineUpdate(beamLine,opts)

[d,d,modelSimul,modelUseBDES]=model_init;
name=beamLine(:,2);

% find energy
energyList=reshape([beamLine{:,6}],[],1);

% find lengths
lenList=reshape([beamLine{:,7}],[],1);

% find element types
isQ=strcmp(beamLine(:,1),'qu'); % quadrupole
isB=strcmp(beamLine(:,1),'be'); % bend
isM=strcmp(beamLine(:,1),'mu'); % multipole (also used for zero-length elements; K0L or K1L only)
isU=strcmp(beamLine(:,1),'un'); % undulator
isL=strcmp(beamLine(:,1),'lc'); % linear accelerating cavity
isT=strcmp(beamLine(:,1),'tc'); % transverse deflecting cavity
isS=strcmp(beamLine(:,1),'so'); % solenoid

% keep original params for non-undulator magnets
isQBnU=(ismember(beamLine(:,1),{'qu','be','so'})& ...
  ~ismember(name,strcat('QHXH',num2str((13:46)','%02d')))& ... % HXR undulator quadrupoles
  ~ismember(name,strcat('QSXH',num2str((26:47)','%02d')))& ... % SXR undulator quadrupoles
  ~strncmp(name,'BCXXL',5)& ... % XLEAP-II self-seeding chicane
  ~strncmp(name,'BCXSS',5)& ... % SXRSS self-seeding chicane
  ~strncmp(name,'BCXHS',5)); % HXRSS self-seeding chicane
bl=beamLine(isQBnU,4);

Cb=1e10/2.99792458e8; % rigidity constant (kG-m/GeV)

% quadrupoles
item4List=vertcat(beamLine{isQ,4});
if (size(item4List,2)<2)
  item4List=reshape(item4List,[],1);
end
if (opts.init)
  bpList=Cb*energyList(isQ,1); % "brho" or rigidity (kG-m)
  control_magnetSet(name(isQ),item4List(:,1).*bpList.*lenList(isQ,1),'action','SAVE_BDES');
elseif (~opts.design)
  k1=model_k1Get(name(isQ),lenList(isQ)',energyList(isQ)');
  if (true) % ***mdwKLUGE*** MAD and EPICS polarites for QUE1 and QUE2 are opposite
    isQUE=strcmp('QUE1',name(isQ));
    k1(isQUE)=abs(k1(isQUE)); % should be > 0 (QF)
    isQUE=strcmp('QUE2',name(isQ));
    k1(isQUE)=-abs(k1(isQUE)); % should be < 0 (QD)
  end
  use=~isnan(k1);
  item4List(use,1)=k1(use);
  beamLine(isQ,4)=reshape(num2cell(item4List,2),[],1);
end

% solenoids
item4List=vertcat(beamLine{isS,4});
if (size(item4List,2)<2)
  item4List=reshape(item4List,[],1);
end
if (opts.init)
  bpList=Cb*energyList(isS,1); % "brho" or rigidity (kG-m)
  control_magnetSet(name(isS),item4List(:,1).*bpList.*lenList(isS,1),'action','SAVE_BDES');
elseif (~opts.design)
  k1=model_k1Get(name(isS),lenList(isS)',energyList(isS)');
  use=~isnan(k1);
  item4List(use,1)=k1(use);
  beamLine(isS,4)=reshape(num2cell(item4List,2),[],1);
end

% multipoles
item4List=vertcat(beamLine{isM,4});
if (size(item4List,2)<2)
  item4List=reshape(item4List,[],1);
end
if (opts.init)
  bpList=Cb*energyList(isM,1); % "brho" or rigidity (kG-m)
  control_magnetSet(name(isM),item4List(:,1).*bpList.*lenList(isM,1),'action','SAVE_BDES');
elseif (~opts.design)
  k1=model_k1Get(name(isM),lenList(isM)',energyList(isM)');
  use=~isnan(k1);
  item4List(use,1)=k1(use);
  beamLine(isM,4)=reshape(num2cell(item4List,2),[],1);
end

% bend
itemB=beamLine(isB,:);
item4List=reshape(vertcat(itemB{:,4}),[],7);
lenB=lenList(isB,1);
energyB=energyList(isB,1);
isKIK=(strncmp(itemB(:,2),'BXKIK',5)|strncmp(itemB(:,2),'BYKIK',5));
isGeV=model_magnetIsGeV(itemB(:,2));
if (opts.init)
  val(isGeV)=energyB(isGeV);
  bpList=Cb*energyB(~isGeV,1); % "brho" or rigidity (kG-m)
  val(~isGeV)=abs(item4List(~isGeV,1))./reshape([itemB{~isGeV,3}],[],1).*bpList.*lenB(~isGeV,1);
  control_magnetSet(name(isB),val,'action','SAVE_BDES');
elseif (~opts.design)
  [k1,bAct]=model_k1Get(name(isB),lenB',energyB');
  % fix FACET wiggler
  isW1=ismember(name(isB),{'WIGE1','WIGE3'});k1(isW1)=k1(isW1)/4;
  isW2=strcmp(name(isB),'WIGE2');k1(isW2)=k1(isW2)/2;

  k1(isKIK)=0;
  bad=reshape(isnan(k1),[],1);
  use=(~isGeV&~bad);
  tmp=k1(1,use)'.*reshape([itemB{use,3}],[],1); % present bend angles
  tmp0=abs(item4List(use,1)); % abs(design bend angles)
  tmp0(tmp0==0)=1; % prevent divide by 0 for bends with zero design bend angle
  item4List(use,3:4)=item4List(use,3:4).*repmat(tmp./tmp0,1,2); % scale edge angles when bend angle changes
  item4List(use,1)=sign(item4List(use,1)).*tmp;
  beamLine(isB,4)=reshape(num2cell(item4List,2),[],1);
end

% restore original params for non-undulator magnets in model simulation
if (modelSimul),beamLine(isQBnU,4)=bl;end

% undulator
% the number per row in the next line (3) should really be selected from
% the size of the arrays stored in the fourth column of unds in the
% beamline. this bit was added for the LCLS2 beamline release.
try
  item4List=reshape(vertcat(beamLine{isU,4}),[],3);
catch %#ok<CTCH>
  item4List=reshape(vertcat(beamLine{isU,4}),[],sum(isU)); % there are only 2 elements in IN10
end
lamuList=item4List(:,2);
c=2.99792458e8; % speed of light (m/s)
mc2=510.99906e-6; % electron rest mass (GeV)
gam=energyList(isU,1)/mc2; % Lorentz factor (1)
if (opts.init)
  Kund=sqrt(item4List(:,1))/2/pi.*lamuList*sqrt(2).*gam;
  if (any(isU))
    lcaPutSmart(strcat(model_nameConvert(name(isU)),':KACT'),Kund); % *** this won't work!
  end
elseif (~opts.design)
  [Kact,Kdes]=control_undGet(name(isU));
  if (modelUseBDES)
    Kund=Kdes;
  else
    Kund=Kact;
  end
  if (modelSimul)
    Kund=Kund.*lcaGet('SIOC:SYS0:ML00:AO877'); % ???
  end
  if any(isU)
      id=find(isU);
      
      % Special values for phase shifters:
      isPS=(strncmp(name(id),'PSHX',4)|strncmp(name(id),'PSSX',4)); % phase shifters
      
      % convert phase integral to undulator K
      Kund(isPS)=1e-9*c/mc2*sqrt(2e-9*Kund(isPS)./lamuList(isPS)); 
      kqund=(2*pi*Kund(:)./lamuList(:)/sqrt(2)./gam(:)).^2;
      
      %FACET II heater chicane undulator
      isF2HeaterUnd = strcmp(name(id),'UM10466');
      kqund(isF2HeaterUnd) = 0;
      
      % Special values for XLEAP wigglers 1-4:
      % (note, isXleapWig could also check item4List(:,3) == 2 instead now)
      isXleapWig=(strncmp(name(id),'UMXL',4)); % |strncmp(name(id),'WIGX',4)); %XLEAP Wigglers
      kqund(isXleapWig) = 0; % 3-4 not currently installed
      lineEnergy = lcaGetSmart('REFS:DMPS:400:EDES');
      isXleapWig=(strncmp(name(id),'UMXL2',5));
      kqund(isXleapWig) = (0.072./lineEnergy.^2 - 0.013./lineEnergy).*logical(Kund(isXleapWig));% from magnetic measurement fit
      isXleapWig=(strncmp(name(id),'UMXL1',5)); 
      kqund(isXleapWig) = (-0.004./lineEnergy.^2 + 0.04./lineEnergy).*logical(Kund(isXleapWig));% from magnetic measurement fit
      
      item4List(:,1)=kqund;
      beamLine(isU,4)=reshape(num2cell(item4List,2),[],1);
  end
end

% acceleration
itemL=beamLine(isL,:);
item4List=reshape(vertcat(itemL{:,4}),[],3);
item4List(:,4)=energyList(isL,1)*1e3-item4List(:,2).*cos(item4List(:,3)); % MeV, initial energy
beamLine(isL,4)=reshape(num2cell(item4List,2),[],1);

% tranverse deflector
if any(isT)
    item4List=reshape(vertcat(beamLine{isT,4}),sum(isT),[]);
    if (opts.init)
     %bp=Cb*model_energy(name(isT)); % kG-m
     %control_magnetSet(name(isT),item{5}*bp*2*item{4});
    elseif (~opts.design)
      if (true) % ***mdwKLUGE*** model TCAV's as OFF
        aAct=zeros(size(find(isT)));
        pAct=zeros(size(find(isT)));
        act=ones(size(find(isT)));
      else
        act=bitand(control_klysStatGet(name(isT)),1);
        [pAct,aAct]=control_phaseGet(name(isT),{'PHAS','AMPL'});
      end
      item4List(:,2)=reshape(aAct,[],1).*act;
      item4List(:,3)=reshape(pAct,[],1)*pi/180;
    end
    item4List(:,5)=energyList(isT,1)*1e3;
    beamLine(isT,4)=reshape(num2cell(item4List,2),[],1);
end


function rList=getRMat(beamLine)

r=eye(6);
nElem=size(beamLine,1);
rList=repmat(r,[1,1,nElem]);

if (0)
  r0=rList;
  for j=1:nElem
    r0(:,:,j)=model_rMatElement(beamLine{j,[1,3,4]});
  end
else
  r0=model_rMatElements(beamLine(:,1),beamLine(:,3),beamLine(:,4));
end

r0(5,6,:)=r0(5,6,:)+reshape([beamLine{:,3}]./([beamLine{:,6}]/510.99906e-6).^2,1,1,[]);
for j=1:nElem
  r=r0(:,:,j)*r;
  rList(:,:,j)=r;
end

return

