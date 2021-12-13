function stat=LEM_MagnetInfo()
%
% set up LEM's MAGNET structure

% ------------------------------------------------------------------------------
% 31-MAR-2009, M. Woodley
%    Retain design values (computed at LEM initialization) for quadrupole Bmag
%    displays
% 30-JAN-2009, M. Woodley
%    50Q1-3 now under EPICS control (50Q2 is master, others are slaves)
% 16-JAN-2009, M. Woodley
%    Add design beta-function values for Bmag display
% ------------------------------------------------------------------------------

global theAccelerator
global seqName
global MAGNET

% get static MAGNET data from XAL

mType=[{'XBEND'};{'YBEND'};{'QUAD'};{'SOLE'};{'XCOR'};{'YCOR'}];
L2end='Q24901B'; % last magnet of L2 (LEM region 3)
L2L3region=3;

allEmag=theAccelerator.getAllNodesOfType('emag');
N=0;
for n=1:allEmag.size
  Emag=allEmag.get(n-1);
  type=strmatch(char(Emag.getType),mType);
  if (isempty(type)),continue,end
  name=char(Emag.getId);
  dbname=char(Emag.getEId);
  seqid=strmatch(char(Emag.getParent),seqName);
  if (seqid<4)
    region=1;
  elseif (seqid==4)
    region=2;
  elseif (seqid==5)
    region=L2L3region;
  elseif (seqid==6)
    region=4;
  elseif (seqid<11)
    region=5;
  elseif (seqid==11)
    region=6;
  elseif (seqid==12)
    region=7;
  elseif (seqid==13)
    region=8;
  else
    error('unrecognized seqid')
  end
  epics=LEM_IsEPICS(type,dbname);
  [bmin,bmax]=LEM_MagnetLimits(epics,dbname);
  N=N+1;
  MAGNET(N).type=type;
  MAGNET(N).name=name;
  MAGNET(N).dbname=dbname;
  MAGNET(N).region=region;
  MAGNET(N).epics=epics;
  MAGNET(N).bmin=bmin;
  MAGNET(N).bmax=bmax;
  MAGNET(N).ivbType=1; % integrated strength vs current
  MAGNET(N).scaleFlag=1; % scale always
  MAGNET(N).scaleType=1; % PS = MAGNET
  MAGNET(N).scaleGroup=1; % non-optional magnets
  MAGNET(N).scaleNow=0; % OK to scale
% reference values
  MAGNET(N).energy0=0;
  MAGNET(N).bdes0=0;
  MAGNET(N).kl0=0;
% extant values
  MAGNET(N).energy=0;
  MAGNET(N).bdes=0;
  MAGNET(N).kl=0;
  MAGNET(N).bnew=0;
% design values ... for quadrupole Bmag display
  MAGNET(N).design_energy=0;
  MAGNET(N).design_bdes=0;
  MAGNET(N).design_kl=0;
  MAGNET(N).design_betax=0;
  MAGNET(N).design_betay=0;
  if (strcmp(name,L2end))
    L2L3region=4;
  end
end
MAGNET=MAGNET';

% set up flags for special MAGNET handling

mName=char(MAGNET.name);
mType=char(MAGNET.type);

LEM_MagnetIvbType(mName)
LEM_MagnetScaleFlag(mName)
LEM_MagnetScaleType(mName)
LEM_MagnetScaleGroup(mType,mName)

stat=1;

end

function ctrl=LEM_IsEPICS(type,dbname)

switch type
  case {1,2}
    ctrl=(strcmp('BEND',dbname(1:4))|strcmp('KICK',dbname(1:4)));
  case 3
    ctrl=(strcmp('QUAD',dbname(1:4))|strcmp('QUAS',dbname(1:4)));
  case 4
    ctrl=strcmp('SOLN',dbname(1:4));
  case 5
    ctrl=strcmp('XCOR',dbname(1:4));
  case 6
    ctrl=strcmp('YCOR',dbname(1:4));
  otherwise
    ctrl=-1;
end

end

function LEM_MagnetIvbType(mName)

global MAGNET

% energy polynomials

id=[];
id=[id;strmatch('BXG',mName)];
id=[id;strmatch('BXS',mName)];
id=[id;strmatch('BX0',mName)];
id=[id;strmatch('BY1',mName)];
id=[id;strmatch('BY2',mName)];
id=[id;strmatch('BX3',mName)];
id=[id;strmatch('BYD',mName)];
for n=1:length(id)
  MAGNET(id(n)).ivbType=2;
end

end

function LEM_MagnetScaleFlag(mName)

global MAGNET

% never scale

id=[];
id=[id;strmatch('BXH',mName)];
id=[id;strmatch('BX0',mName)];
id=[id;strmatch('BX1',mName)];
id=[id;strmatch('BX2',mName)];
for n=1:length(id)
  MAGNET(id(n)).scaleFlag=0;
end

end

function LEM_MagnetScaleType(mName)

global MAGNET

% linac LGPS/booster groups

id=[];
id=[id;strmatch('Q25',mName)];
id=[id;strmatch('Q26',mName)];
id=[id;strmatch('Q27',mName)];
id=[id;strmatch('Q28',mName)];
id=[id;strmatch('Q29',mName)];
for n=1:length(id)
  sect=str2double(mName(id(n),2:3));
  MAGNET(id(n)).scaleType=sect;
end

% LI30 QUAD/QTRM pairs

id=strmatch('Q30',mName);
for n=1:length(id)
  MAGNET(id(n)).scaleType=2;
end

% LTU BENDs

id=[];
id=[id;strmatch('BX3',mName)];
id=[id;strmatch('BYD',mName)];
for n=1:length(id)
  MAGNET(id(n)).scaleType=3;
end

end

function LEM_MagnetScaleGroup(mType,mName)

global MAGNET

% undulator correctors

idu=[];
idu=[idu;strmatch('XCU0',mName)];
idu=[idu;strmatch('XCU1',mName)];
idu=[idu;strmatch('XCU2',mName)];
idu=[idu;strmatch('XCU3',mName)];
idu=[idu;strmatch('YCU0',mName)];
idu=[idu;strmatch('YCU1',mName)];
idu=[idu;strmatch('YCU2',mName)];
idu=[idu;strmatch('YCU3',mName)];
for n=1:length(idu)
  MAGNET(idu(n)).scaleGroup=4;
end

% non-undulator correctors

id=[];
id=[id;find(mType==5)];
id=[id;find(mType==6)];
id=id(~ismember(id,idu));
for n=1:length(id)
  MAGNET(id(n)).scaleGroup=2;
end

% undulator quadrupoles

id=[];
id=[id;strmatch('QU0',mName)];
id=[id;strmatch('QU1',mName)];
id=[id;strmatch('QU2',mName)];
id=[id;strmatch('QU3',mName)];
for n=1:length(id)
  MAGNET(id(n)).scaleGroup=3;
end

end

function [bmin,bmax]=LEM_MagnetLimits(epics,dbname)

global da
da.reset

if (epics)
  Query=strcat(dbname,':BMIN:VAL');
  try
    bmin=pvaGet(Query, AIDA_DOUBLE);
  catch
    error('*** %s',Query)
  end
  Query=strcat(dbname,':BMAX:VAL');
  try
    bmax=pvaGet(Query,AIDA_DOUBLE);
  catch
    error('*** %s',Query)
  end
else
  munge=strcat(dbname(6:10),dbname(1:5),dbname(11:end));
  Query=strcat(munge,':IMMO');
  try
    d=pvaGet(Query);
  catch
    error('*** %s',Query)
  end
  immo=toArray(d);
  bipolar=(prod(immo)<0);
  Query=strcat(munge,':BMAX');
  try
    d=pvaGet(Query,AIDA_DOUBLE);
  catch
    error('*** %s',Query)
  end
  if (bipolar)
    bmin=min(-d,d);
    bmax=max(-d,d);
  else
    bmin=min(d,0);
    bmax=max(d,0);
  end

% special super-kluge for QUAD LI21 201 ... if the "magnet uses IVBD" HSTA bit
% is set then the magnet is running in (manually) reversed polarity ... change
% the sign of BMAX and flip the limits

  if (strcmp(munge,'QUAD:LI21:201'))
    Query=strcat(munge,':HSTA');
    try
      hsta=pvaGet(Query,AIDA_LONG);
    catch
      error('*** %s',Query)
    end
    useIVBD=8192; % '2000'x
    if (bitand(useIVBD,hsta)==useIVBD)
      bmin=-bmax;
      bmax=0;
    end
  end
end

end
