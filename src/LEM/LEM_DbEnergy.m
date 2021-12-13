function stat=LEM_DbEnergy(opCode,Esecn)
%
% stat=LEM_DbEnergy(opCode,Esecn);
%
% Read/write LEM MAGNET energy values from/to EPICS PVs
%
% INPUTs:
%
%   opCode = operation (0=read,1=write)
%   Esecn  = PV identifier ('ACT','DES','CON')
%
% OUTPUT:
%
%   stat = completion status

global lemRegions lemGroups
global MAGNET
global theAccelerator

% get pointers to MAGNETs that are in the selected LEM region(s)/groups

idr=find(ismember([MAGNET.region]',find(lemRegions))); % in selected region(s)
idg=find(ismember([MAGNET.scaleGroup]',find(lemGroups))); % in selected group
id=intersect(idr,idg); % these are the ones

for m=1:length(id)
  n=id(m);
  dbname=MAGNET(n).dbname;
  if (~MAGNET(n).epics)
    dbname=strcat(dbname(6:10),dbname(1:5),dbname(11:end)); % unmunge
  end
  Query=strcat(dbname,':E',Esecn,':VAL');
  if (opCode==1)
    energy=MAGNET(n).energy;
    try
      pvaSet(Query,energy);
    catch e
      handleExceptions(e);
      error('*** Write %s',Query)
    end
  else
    try
      energy=pvaGet(Query, AIDA_DOUBLE);
      MAGNET(n).energy0=energy;
    catch
      error('*** Read %s',Query)
    end
  end
  name=MAGNET(n).name;
  node=
end

stat=1;

end
