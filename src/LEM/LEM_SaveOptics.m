function stat=LEM_SaveOptics()
%
% stat=LEM_SaveOptics();
%
% Save reference values (energy/bdes/kl) for selected MAGNETs
%
% OUTPUT:
%
%   stat = completion status

aidainit
da=DaObject;da.reset

global MAGNET

% check for old data ... provide abort option

stat=LEM_Prompt(1);
if (~stat),return,end

% get pointers to MAGNETs that are in the selected LEM region(s)/groups

id=LEM_SelectedMagnets();

% save reference values (energy/bdes/kl) and load EDES PVs for selected MAGNETs

for m=1:length(id)
  n=id(m);
  MAGNET(n).energy0=MAGNET(n).energy;
  MAGNET(n).bdes0=MAGNET(n).bdes;
  MAGNET(n).kl0=MAGNET(n).kl;
  dbname=MAGNET(n).dbname;
  if (~MAGNET(n).epics)
    ic=strfind(dbname,':');ic1=ic(1);ic2=ic(2);
    dbname=strcat(dbname(ic1+1:ic2),dbname(1:ic1),dbname(ic2+1:end)); % unmunge
  end
  Query=strcat(dbname,':EDES//VAL');
  try
    da.setDaValue(Query,DaValue(MAGNET(n).energy0));
  catch
    error('*** %s',Query)
  end
end

end