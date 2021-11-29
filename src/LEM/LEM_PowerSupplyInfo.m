function stat=LEM_PowerSupplyInfo()
%
% set up LEM's PS structure

% ------------------------------------------------------------------------------
% 30-JAN-2009, M. Woodley
%    50Q1-3 now under EPICS control (50Q2 is master, others are slaves)
% ------------------------------------------------------------------------------

global da
da.reset

global MAGNET PS

N=0;
scaleType=[MAGNET.scaleType]';

% "regular" magnets

id=find(scaleType~=3);
for n=1:length(id)
  m=id(n);
  N=N+1;
  PS(N).name=MAGNET(m).name;
  if (MAGNET(m).epics)
    PS(N).dbname=MAGNET(m).dbname;
  else
    PS(N).dbname=unMunge(MAGNET(m).dbname);
  end
  PS(N).epics=MAGNET(m).epics;
  PS(N).bmin=MAGNET(m).bmin;
  PS(N).bmax=MAGNET(m).bmax;
  PS(N).bdes=0;
  PS(N).bnew=0;
  PS(N).setNow=0;
  PS(N).bad=0;
end

% LI30 QTRMs

id=find(scaleType==2);
for n=1:length(id)
  m=id(n);
  N=N+1;
  PS(N).name=strcat(MAGNET(m).name,'_QTRM');
  dbname=unMunge(MAGNET(m).dbname);
  dbname=strrep(dbname,'QUAD','QTRM');
  PS(N).dbname=dbname;
  PS(N).epics=0;
  Query=strcat(dbname,'//BMAX');
  try
    d=da.get(Query,4);
  catch
    error('*** %s',Query)
  end
  PS(N).bmin=min(d,0);
  PS(N).bmax=max(d,0);
  PS(N).bdes=0;
  PS(N).bnew=0;
  PS(N).setNow=0;
  PS(N).bad=0;
end

% LTU BX3/BYD bends

id=find(scaleType==3);
for n=1:length(id)
  m=id(n);
  if (strcmp(MAGNET(m).name,'BYD1'))
    N=N+1;
    PS(N).name=MAGNET(m).name;
    PS(N).dbname=MAGNET(m).dbname;
    PS(N).epics=1;
    PS(N).bmin=MAGNET(m).bmin;
    PS(N).bmax=MAGNET(m).bmax;
    PS(N).bdes=0;
    PS(N).bnew=0;
    PS(N).setNow=0;
    PS(N).bad=0;
  end
  if (strcmp(MAGNET(m).name(1:2),'BX'))
    N=N+1;
    PS(N).name=strcat(MAGNET(m).name,'_BTRM');
    dbname=MAGNET(m).dbname;
    dbname=strrep(dbname,'BEND','BTRM');
    PS(N).dbname=dbname;
    PS(N).epics=1;
    Query=strcat(dbname,':BMIN//VAL');
    try
      PS(N).bmin=da.get(Query,4);
    catch
      error('*** %s',Query)
    end
    Query=strcat(dbname,':BMAX//VAL');
    try
      PS(N).bmax=da.get(Query,4);
    catch
      error('*** %s',Query)
    end
    PS(N).bdes=0;
    PS(N).bnew=0;
    PS(N).setNow=0;
    PS(N).bad=0;
  end
end

% finally, remove PS entries for "slaves"

stat=removeSlaves();

end

function name=unMunge(mname)

ic=strfind(mname,':');
name=mname([ic(1)+1:ic(2),1:ic(1),ic(2)+1:end]);

end

function stat=removeSlaves()

global PS

slave=[ ...
  {'BY2'}; ... % controlled by BY1
  {'BYKIK2'}; ... % controlled by BYKIK1
  {'Q24701B'}; ... % controlled by Q24701A
  {'Q24901B'}; ... % controlled by Q24901A
  {'Q50Q1'};{'Q50Q3'}; ... % controlled by Q50Q2
  {'QVB2'};{'QVB3'}; ... % controlled by QVB1
  {'QDL32'};{'QDL33'};{'QDL34'}; ... % controlled by QDL31
  {'QT13'};{'QT21'};{'QT23'};{'QT31'};{'QT33'};{'QT41'};{'QT43'}; ... % controlled by QT11
  {'QT22'};{'QT32'};{'QT42'}; ... % controlled by QT12
  {'QE32'};{'QE33'};{'QE34'};{'QE35'};{'QE36'}; ... % controlled by QE31
  {'QDMP2'}; ... % controlled by QDMP1
];
Nslave=length(slave);

id=zeros(Nslave,1);
for n=1:Nslave
  id(n)=strmatch(slave(n),char(PS.name),'exact');
end

PS(id)=[];

stat=1;

end