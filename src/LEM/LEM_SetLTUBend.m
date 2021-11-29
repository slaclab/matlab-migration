function stat=LEM_SetLTUBend()

global da
da.reset

global controlFlags
useBDES=controlFlags(1); % use BDES values ... otherwise use BACT
if (useBDES)
  secn='BDES';
else
  secn='BACT';
end

global MAGNET PS

mname='BYD1'; % the master
idm=find([MAGNET.scaleType]'==3);
id=strmatch(mname,char(MAGNET(idm).name));
energy=MAGNET(idm(id)).energy;

% use Paul Emma's script to compute setpoints

[BDES,Imain,Itrim,pBYD]=LEM_BYD_BX3_BDES(energy);

% main power supply

id=strmatch(mname,char(PS.name),'exact');
PS(id).bnew=energy;
PS(id).setNow=1;
PS(id).bad=((energy<PS(id).bmin)|(energy>PS(id).bmax));

% get present main power supply setpoint

Query=strcat(PS(id).dbname,':',secn,'//VAL');
try
  Bps=da.get(Query,4);
catch
  error('*** %s',Query)
end
PS(id).bdes=Bps;

% BX3 trims

id=strmatch('BX3',char(MAGNET(idm).name));
for m=1:4
  n=idm(id(m));
  tname=strcat(MAGNET(n).name,'_BTRM');
  idt=strmatch(tname,char(PS.name),'exact');
  PS(idt).bnew=BDES(m);
  PS(idt).setNow=1;
  PS(idt).bad=((BDES(m)<PS(idt).bmin)|(BDES(m)>PS(idt).bmax));

% get present trim setpoint

  Query=strcat(PS(idt).dbname,':',secn,'//VAL');
  try
    Bt=da.get(Query,4);
  catch
    error('*** %s',Query)
  end
  PS(idt).bdes=Bt;
end

stat=1;

end