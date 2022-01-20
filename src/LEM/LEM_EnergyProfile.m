function [oldFudge,newFudge]=LEM_EnergyProfile()
%
% [oldFudge,newFudge]=LEM_EnergyProfile();
%
% global KLYS (structure):
%
%   KLYS(n).name  = XAL root name
%   KLYS(n).stat  = trigger status for beam code 1 (0=OFF,1=ON)
%   KLYS(n).ampl  = on-crest no-load energy gain (MeV) ... DB value times kEerr
%   KLYS(n).phas  = RF phase values [KLYS,SBST,"other"] (degrees)
%   KLYS(n).eerr  = static multiplicative fudge factor
%   KLYS(n).fudge = LEM fudge factor
%   KLYS(n).egain = energy gain (GeV)
%   KLYS(n).power = power factors for [a,b,c,d] sections (E ~ sqrt(P))
%
% OUTPUTs:
%
%   oldFudge = current fudge factors
%   newFudge = ideal fudge factors

% ------------------------------------------------------------------------------
% 21-JAN-2009, M. Woodley
%    Solve quadratic equation for fudge factor explicitly ... add more checks
%    for "unphysical" fudge factor values ... default to 1.0 if a real positive
%    value isn't found; move reference energy values from return argument list
%    to global array
% 14-JAN-2009, M. Woodley
%    All subbooster phases from EPICS; remove old SLC LI27/LI28 fast energy
%    feedback phases; KLYS phase from SLC for globally phased units is optional;
%    use static (hardwired) kEerr values to adjust database amplitude values
%    when computing kAmpl (i.e. kAmpl = kAmpl_from_DB * kEerr)
% ------------------------------------------------------------------------------

global controlFlags
useIdeal=controlFlags(2); % use "ideal" fudge factors
twoPhase=controlFlags(5); % include SLC KLYS PDES for units with "global" phase control

global debugFlags
useDesign=debugFlags(3); % use design energy profile

global lemPVs lemGlobalPhasePVs
global KLYS
global lemEref lemFudge noFudgeCalc

% AIDA-PVA imports
aidapva;

% hard-wired for LCLS

BEAM='1';            % LCLS beam code
DGRP='LIN_KLYS';     % for KLYS status
idref=[0;2;4;32;80]; % locations of reference points in klysList
MeV2GeV=1e-3;        % energy units conversion
deg2rad=pi/180;      % phase units conversion

% get reference energy values
% (NOTE: echo GUN and BX0 setpoints to their respective LEM softIOC PVs)

lemEref=zeros(5,1);
try
  Query='GUN:IN20:1:GN1_ADES:VAL';
  lemEref(1) = MeV2GeV * pvaGet(Query, AIDA_DOUBLE); % L0 begin

  Query=strcat(lemPVs(5),':VAL');
  pvaSet(Query, lemEref(1));

  Query='BEND:IN20:751:BDES:VAL';
  lemEref(2) = pvaGet(Query, AIDA_DOUBLE);         % L1 begin

  Query = strcat(lemPVs(6), ':VAL');
  pvaSet(Query, lemEref(2));

  Query=strcat(lemPVs(7),':VAL');
  lemEref(3)=pvaGet(Query, AIDA_DOUBLE);         % L2 begin

  Query=strcat(lemPVs(8),':VAL');
  lemEref(4)=pvaGet(Query, AIDA_DOUBLE);         % L3 begin

  Query=strcat(lemPVs(9),':VAL');
  lemEref(5)=pvaGet(Query, AIDA_DOUBLE);         % L3 end
catch e
    handleExceptions(e, 'Failed to get reference energy values');
end

% if no selected LEM regions contain acceleration, we're done

if (noFudgeCalc)
  oldFudge=ones(4,1);
  newFudge=ones(4,1);
  return
end

% get current fudge factors

oldFudge=ones(4,1);
for n=1:4
  Query=strcat(lemPVs(n),':VAL');
  try
    oldFudge(n)=pvaGet(Query, AIDA_DOUBLE);
  catch e
    handleExceptions(e, 'Failed to get current fudge factors');
  end
end

% get global phases

sphas=zeros(4,1);
for n=1:4
  Query=strcat(lemGlobalPhasePVs(n),':VAL');
  try
    sphas(n)=pvaGet(Query, AIDA_DOUBLE);
  catch e
    handleExceptions(e);
  end
end

% get raw klystron data

kList=LEMKlysInfo();
kCount=length(kList);
kStat=zeros(kCount,1);
kAmpl=zeros(kCount,1);
kPhas=zeros(kCount,2);
kEerr=[kList.Eerr]';

for n=1:kCount
  name=kList(n).xalNameRoot;
  ctrl=kList(n).ctrlFlags;

% construct KLYS status query

  switch n
    case 1
      statQuery='KLYS:LI20:71:TACT'; % L0A
    case 2
      statQuery='KLYS:LI20:81:TACT'; % L0B
    case 4
      statQuery='KLYS:LI21:21:TACT'; % L1X
    otherwise
      statQuery=sprintf('KLYS:LI%s:%s1:TACT',name(2:3),name(5));
  end

% construct KLYS amplitude query

  s=kList(n).dbAName;
  if (ctrl(1)==0) % SLC
    ic=strfind(s,':');ic=ic(3);
    s=strcat(s(1:ic-1),':',s(ic+1:end));
  else % EPICS
    s=strcat(s,':VAL');
  end
  amplQuery=s;

% construct KLYS phase query

  s=kList(n).dbPName;
  if (ctrl(2)==0) % SLC
    if (twoPhase)
      ic=strfind(s,':');ic=ic(3);
      s=strcat(s(1:ic-1),':',s(ic+1:end));
    else
      s=[];
    end
  else % EPICS
    s=strcat(s,':VAL');
  end
  phasQuery=s;

% get the data

  if (useDesign)
    if (n==1),load /home/physics/mdw/LEM/DesignEnergyProfile,end
    kStat(n)=1;
    kAmpl(n)=designAmpl(n); % MeV
    kPhas(n,:)=[designPhas(n),0]; % degrees
  else
    try
        requestBuilder = pvaRequest(statQuery);
        requestBuilder.with('BEAM', BEAM);
        requestBuilder.with('DGRP', DGRP);
        requestBuilder.returning(AIDA_STRING);
        stat = ML(requestBuilder.get());
        ampl = pvaGet(amplQuery, AIDA_DOUBLE);

      if (isempty(phasQuery))
        phas=0;
      else
        phas = pvaGet(phasQuery, AIDA_DOUBLE);
      end
    catch
      disp(sprintf('Failed to get DB data for %s',name))
    end

    kStat(n)=strcmp(stat,'activated');
    kAmpl(n)=ampl*kEerr(n);
    kPhas(n,1)=phas;
    if (ctrl(3)~=0)
      kPhas(n,2)=sphas(ctrl(3));
    end
  end
end

% compute ideal fudge factors

Phas=deg2rad*(kPhas(:,1)+kPhas(:,2)); % aggregate phase (rad)
kdE=MeV2GeV*(kStat.*kAmpl.*cos(Phas)); % energy contribution (GeV)

newFudge=ones(4,1);
for n=1:4
  id1=idref(n)+1; % first KLYS
  id2=idref(n+1); % last KLYS
  kdEn=kdE(id1:id2);
  ida=logical(kdEn>=0); % accelerating
  idd=logical(kdEn<0); % decelerating
  dEacc=sum(kdEn(ida));
  dEdec=sum(kdEn(idd));
  dEref=lemEref(n+1)-lemEref(n);

% solve quadratic equation for the fudge factor value

  a=dEacc;     % quadratic coefficient
  b=-dEref;    % linear coefficient
  c=dEdec;     % constant coefficient
  D=b^2-4*a*c; % discriminant
  if (D>=0) % one or two real roots
    r=[(-b-sqrt(D))/(2*a),(-b+sqrt(D))/(2*a)];
    id=find(r>0);
    if (isempty(id)) % no positive roots
      disp(sprintf('*** No positive fudge found for L%d ... use 1.0',n-1))
    elseif (length(id)==1) % one positive root
      newFudge(n)=r(id);
    else % two positive roots
      [d,id]=min(abs(r-1)); % select the value closest to 1
      newFudge(n)=r(id(1));
    end
  else % no real roots
    disp(sprintf('*** No real fudge found for L%d ... use 1.0',n-1))
  end
end

% prepare outputs

if (useIdeal)
  lemFudge=newFudge;
else
  lemFudge=oldFudge;
end

for n=1:kCount
  KLYS(n).name=kList(n).xalNameRoot;
  KLYS(n).stat=kStat(n);
  KLYS(n).ampl=kAmpl(n);
  KLYS(n).phas=kPhas(n,:);
  KLYS(n).eerr=kEerr(n);
  m=length(find(n>idref));
  KLYS(n).fudge=lemFudge(m);
  egain=MeV2GeV*(KLYS(n).stat*KLYS(n).ampl*cos(Phas(n))); % GeV
  if (egain<0)
    KLYS(n).egain=egain/KLYS(n).fudge;
  else
    KLYS(n).egain=egain*KLYS(n).fudge;
  end
  KLYS(n).power=kList(n).powerFact;
end

end

function Klys=LEMKlysInfo()

% ctrlFlags(1)=0 : get KLYS amplitude from SLC
% ctrlFlags(1)=1 : get KLYS amplitude from EPICS
% ctrlFlags(2)=0 : get KLYS phase from SLC optionally (if twoPhase=1)
% ctrlFlags(2)=1 : get KLYS phase from EPICS
% ctrlFlags(3)=0 : no SBST phase
% ctrlFlags(3)=1 : get SBST phase from EPICS SIOC:SYS0:ML00:AO061 (L2 global phase)
% ctrlFlags(3)=2 : get SBST phase from EPICS SIOC:SYS0:ML00:AO064 (L3 global phase)
% ctrlFlags(3)=3 : get SBST phase from EPICS ACCL:LI29:0:KLY_PDES (LI29 energy feedback phase)
% ctrlFlags(3)=4 : get SBST phase from EPICS ACCL:LI30:0:KLY_PDES (LI30 energy feedback phase)

% ------------------------------------------------------------------------------
% 14-JAN-2009, M. Woodley
%    All subbooster phases from EPICS; remove old SLC LI27/LI28 fast energy
%    feedback phases; KLYS phases from SLC for globally phased units is optional
% 18-DEC-2008, M. Woodley
%    Per J. Frisch, use SLC subbooster phase values for L2 KLYS units
% ------------------------------------------------------------------------------

% L0A/L0B/L1S/L1X

Klys( 1)=struct('xalNameRoot','L0A___','powerFact',[1,0,0,0],'dbAName','ACCL:IN20:300:L0A_ADES','dbPName','ACCL:IN20:300:L0A_PDES','ctrlFlags',[1,1,0],'Eerr',1.0);
Klys( 2)=struct('xalNameRoot','L0B___','powerFact',[1,0,0,0],'dbAName','ACCL:IN20:400:L0B_ADES','dbPName','ACCL:IN20:400:L0B_PDES','ctrlFlags',[1,1,0],'Eerr',1.0);
Klys( 3)=struct('xalNameRoot','K21_1' ,'powerFact',[0,2,1,1],'dbAName','ACCL:LI21:1:L1S_ADES'  ,'dbPName','ACCL:LI21:1:L1S_PDES'  ,'ctrlFlags',[1,1,0],'Eerr',1.0);
Klys( 4)=struct('xalNameRoot','L1X___','powerFact',[1,0,0,0],'dbAName','ACCL:LI21:180:L1X_ADES','dbPName','ACCL:LI21:180:L1X_PDES','ctrlFlags',[1,1,0],'Eerr',1.0);

% L2

Klys( 5)=struct('xalNameRoot','K21_3' ,'powerFact',[0,2,1,1],'dbAName','KLYS:LI21:31:ENLD'     ,'dbPName','KLYS:LI21:31:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys( 6)=struct('xalNameRoot','K21_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI21:41:ENLD'     ,'dbPName','KLYS:LI21:41:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys( 7)=struct('xalNameRoot','K21_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI21:51:ENLD'     ,'dbPName','KLYS:LI21:51:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys( 8)=struct('xalNameRoot','K21_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI21:61:ENLD'     ,'dbPName','KLYS:LI21:61:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys( 9)=struct('xalNameRoot','K21_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI21:71:ENLD'     ,'dbPName','KLYS:LI21:71:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(10)=struct('xalNameRoot','K21_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI21:81:ENLD'     ,'dbPName','KLYS:LI21:81:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);

Klys(11)=struct('xalNameRoot','K22_1' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:11:ENLD'     ,'dbPName','KLYS:LI22:11:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(12)=struct('xalNameRoot','K22_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:21:ENLD'     ,'dbPName','KLYS:LI22:21:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(13)=struct('xalNameRoot','K22_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:31:ENLD'     ,'dbPName','KLYS:LI22:31:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(14)=struct('xalNameRoot','K22_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:41:ENLD'     ,'dbPName','KLYS:LI22:41:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(15)=struct('xalNameRoot','K22_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:51:ENLD'     ,'dbPName','KLYS:LI22:51:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(16)=struct('xalNameRoot','K22_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:61:ENLD'     ,'dbPName','KLYS:LI22:61:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(17)=struct('xalNameRoot','K22_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:71:ENLD'     ,'dbPName','KLYS:LI22:71:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(18)=struct('xalNameRoot','K22_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI22:81:ENLD'     ,'dbPName','KLYS:LI22:81:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);

Klys(19)=struct('xalNameRoot','K23_1' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:11:ENLD'     ,'dbPName','KLYS:LI23:11:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(20)=struct('xalNameRoot','K23_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:21:ENLD'     ,'dbPName','KLYS:LI23:21:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(21)=struct('xalNameRoot','K23_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:31:ENLD'     ,'dbPName','KLYS:LI23:31:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(22)=struct('xalNameRoot','K23_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:41:ENLD'     ,'dbPName','KLYS:LI23:41:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(23)=struct('xalNameRoot','K23_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:51:ENLD'     ,'dbPName','KLYS:LI23:51:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(24)=struct('xalNameRoot','K23_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:61:ENLD'     ,'dbPName','KLYS:LI23:61:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(25)=struct('xalNameRoot','K23_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:71:ENLD'     ,'dbPName','KLYS:LI23:71:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(26)=struct('xalNameRoot','K23_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI23:81:ENLD'     ,'dbPName','KLYS:LI23:81:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);

Klys(27)=struct('xalNameRoot','K24_1' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI24:11:ENLD'     ,'dbPName','ACCL:LI24:100:KLY_PDES','ctrlFlags',[0,1,0],'Eerr',1.0);
Klys(28)=struct('xalNameRoot','K24_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI24:21:ENLD'     ,'dbPName','ACCL:LI24:200:KLY_PDES','ctrlFlags',[0,1,0],'Eerr',1.0);
Klys(29)=struct('xalNameRoot','K24_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI24:31:ENLD'     ,'dbPName','ACCL:LI24:300:KLY_PDES','ctrlFlags',[0,1,0],'Eerr',1.0);
Klys(30)=struct('xalNameRoot','K24_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI24:41:ENLD'     ,'dbPName','KLYS:LI24:41:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(31)=struct('xalNameRoot','K24_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI24:51:ENLD'     ,'dbPName','KLYS:LI24:51:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);
Klys(32)=struct('xalNameRoot','K24_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI24:61:ENLD'     ,'dbPName','KLYS:LI24:61:PDES'     ,'ctrlFlags',[0,0,1],'Eerr',1.0);

% L3

Klys(33)=struct('xalNameRoot','K25_1' ,'powerFact',[1,1,0,2],'dbAName','KLYS:LI25:11:ENLD'     ,'dbPName','KLYS:LI25:11:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(34)=struct('xalNameRoot','K25_2' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI25:21:ENLD'     ,'dbPName','KLYS:LI25:21:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(35)=struct('xalNameRoot','K25_3' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI25:31:ENLD'     ,'dbPName','KLYS:LI25:31:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(36)=struct('xalNameRoot','K25_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI25:41:ENLD'     ,'dbPName','KLYS:LI25:41:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(37)=struct('xalNameRoot','K25_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI25:51:ENLD'     ,'dbPName','KLYS:LI25:51:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(38)=struct('xalNameRoot','K25_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI25:61:ENLD'     ,'dbPName','KLYS:LI25:61:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(39)=struct('xalNameRoot','K25_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI25:71:ENLD'     ,'dbPName','KLYS:LI25:71:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(40)=struct('xalNameRoot','K25_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI25:81:ENLD'     ,'dbPName','KLYS:LI25:81:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);

Klys(41)=struct('xalNameRoot','K26_1' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:11:ENLD'     ,'dbPName','KLYS:LI26:11:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(42)=struct('xalNameRoot','K26_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:21:ENLD'     ,'dbPName','KLYS:LI26:21:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(43)=struct('xalNameRoot','K26_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:31:ENLD'     ,'dbPName','KLYS:LI26:31:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(44)=struct('xalNameRoot','K26_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:41:ENLD'     ,'dbPName','KLYS:LI26:41:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(45)=struct('xalNameRoot','K26_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:51:ENLD'     ,'dbPName','KLYS:LI26:51:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(46)=struct('xalNameRoot','K26_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:61:ENLD'     ,'dbPName','KLYS:LI26:61:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(47)=struct('xalNameRoot','K26_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:71:ENLD'     ,'dbPName','KLYS:LI26:71:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(48)=struct('xalNameRoot','K26_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI26:81:ENLD'     ,'dbPName','KLYS:LI26:81:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);

Klys(49)=struct('xalNameRoot','K27_1' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:11:ENLD'     ,'dbPName','KLYS:LI27:11:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(50)=struct('xalNameRoot','K27_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:21:ENLD'     ,'dbPName','KLYS:LI27:21:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(51)=struct('xalNameRoot','K27_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:31:ENLD'     ,'dbPName','KLYS:LI27:31:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(52)=struct('xalNameRoot','K27_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:41:ENLD'     ,'dbPName','KLYS:LI27:41:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(53)=struct('xalNameRoot','K27_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:51:ENLD'     ,'dbPName','KLYS:LI27:51:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(54)=struct('xalNameRoot','K27_6' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI27:61:ENLD'     ,'dbPName','KLYS:LI27:61:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(55)=struct('xalNameRoot','K27_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:71:ENLD'     ,'dbPName','KLYS:LI27:71:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(56)=struct('xalNameRoot','K27_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI27:81:ENLD'     ,'dbPName','KLYS:LI27:81:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);

Klys(57)=struct('xalNameRoot','K28_1' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI28:11:ENLD'     ,'dbPName','KLYS:LI28:11:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(58)=struct('xalNameRoot','K28_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI28:21:ENLD'     ,'dbPName','KLYS:LI28:21:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(59)=struct('xalNameRoot','K28_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI28:31:ENLD'     ,'dbPName','KLYS:LI28:31:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(60)=struct('xalNameRoot','K28_4' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI28:41:ENLD'     ,'dbPName','KLYS:LI28:41:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(61)=struct('xalNameRoot','K28_5' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI28:51:ENLD'     ,'dbPName','KLYS:LI28:51:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(62)=struct('xalNameRoot','K28_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI28:61:ENLD'     ,'dbPName','KLYS:LI28:61:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(63)=struct('xalNameRoot','K28_7' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI28:71:ENLD'     ,'dbPName','KLYS:LI28:71:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);
Klys(64)=struct('xalNameRoot','K28_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI28:81:ENLD'     ,'dbPName','KLYS:LI28:81:PDES'     ,'ctrlFlags',[0,0,2],'Eerr',1.0);

Klys(65)=struct('xalNameRoot','K29_1' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI29:11:ENLD'     ,'dbPName','KLYS:LI29:11:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(66)=struct('xalNameRoot','K29_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI29:21:ENLD'     ,'dbPName','KLYS:LI29:21:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(67)=struct('xalNameRoot','K29_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI29:31:ENLD'     ,'dbPName','KLYS:LI29:31:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(68)=struct('xalNameRoot','K29_4' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI29:41:ENLD'     ,'dbPName','KLYS:LI29:41:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(69)=struct('xalNameRoot','K29_5' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI29:51:ENLD'     ,'dbPName','KLYS:LI29:51:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(70)=struct('xalNameRoot','K29_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI29:61:ENLD'     ,'dbPName','KLYS:LI29:61:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(71)=struct('xalNameRoot','K29_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI29:71:ENLD'     ,'dbPName','KLYS:LI29:71:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);
Klys(72)=struct('xalNameRoot','K29_8' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI29:81:ENLD'     ,'dbPName','KLYS:LI29:81:PDES'     ,'ctrlFlags',[0,0,3],'Eerr',1.0);

Klys(73)=struct('xalNameRoot','K30_1' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:11:ENLD'     ,'dbPName','KLYS:LI30:11:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(74)=struct('xalNameRoot','K30_2' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:21:ENLD'     ,'dbPName','KLYS:LI30:21:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(75)=struct('xalNameRoot','K30_3' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:31:ENLD'     ,'dbPName','KLYS:LI30:31:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(76)=struct('xalNameRoot','K30_4' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:41:ENLD'     ,'dbPName','KLYS:LI30:41:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(77)=struct('xalNameRoot','K30_5' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:51:ENLD'     ,'dbPName','KLYS:LI30:51:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(78)=struct('xalNameRoot','K30_6' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:61:ENLD'     ,'dbPName','KLYS:LI30:61:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(79)=struct('xalNameRoot','K30_7' ,'powerFact',[1,1,1,1],'dbAName','KLYS:LI30:71:ENLD'     ,'dbPName','KLYS:LI30:71:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);
Klys(80)=struct('xalNameRoot','K30_8' ,'powerFact',[1,1,2,0],'dbAName','KLYS:LI30:81:ENLD'     ,'dbPName','KLYS:LI30:81:PDES'     ,'ctrlFlags',[0,0,4],'Eerr',1.0);

end
