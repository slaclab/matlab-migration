function stat=LEM_ScaleMagnets()
%
% Scale selected magnets in selected regions to the extant energy profile

% ------------------------------------------------------------------------------
% 21-FEB-2009, M. Woodley
%    Write magnet EDES values to EPICS PVs on completion
% ------------------------------------------------------------------------------

global debugFlags
debug=debugFlags(4);

global lemPVs
global MAGNET PS unLEM
global lemFudge lemScaleTime noFudgeCalc

% check for old data ... provide abort option

stat=LEM_Prompt(1);
if (~stat),return,end

% display out-of-range power supplies ... provide abort option

stat=LEM_Prompt(2,PS);
if (~stat),return,end

% reset unLEM structure

unLEM=[];

% save the extant power supply BDES settings, then set new BDES values and trim

stat=LEM_SetPowerSupplies();
if (~stat),return,end

% copy reference values to unLEM structure

id=find([MAGNET.scaleNow]==1);
unLEM.MAGNET.id=id';
unLEM.MAGNET.bdes=[MAGNET(id).bdes]';
unLEM.MAGNET.energy0=[MAGNET(id).energy0]';
unLEM.MAGNET.bdes0=[MAGNET(id).bdes0]';
unLEM.MAGNET.kl0=[MAGNET(id).kl0]';

% set new bdes values; reset reference values; load magnet EDES PVs

for m=1:length(id)
  n=id(m);
  MAGNET(n).bdes=MAGNET(n).bnew;
  MAGNET(n).energy0=MAGNET(n).energy;
  MAGNET(n).bdes0=MAGNET(n).bdes;
  MAGNET(n).kl0=MAGNET(n).kl;
  if (~debug)
    dbname=MAGNET(n).dbname;
    if (~MAGNET(n).epics)
      ic=strfind(dbname,':');ic1=ic(1);ic2=ic(2);
      dbname=strcat(dbname(ic1+1:ic2),dbname(1:ic1),dbname(ic2+1:end)); % unmunge
    end
    Query=strcat(dbname,':EDES:VAL');
    try
        pvaSet(Query, MAGNET(n).energy0)
    catch e
        handleExceptions(e);
    end
  end
end
if (debug)
  disp('*** debugLEM: no magnet BDES PV values set')
end

% set the lemScale time

lemScaleTime=now;

% if necessary, copy extant softIOC fudge factor values to unLEM structure and
% then update the softIOC PV values

if (~noFudgeCalc)
  Fudge=zeros(4,1);
  try
    for n=1:4
      Query=strcat(lemPVs(n),':VAL');
      Fudge(n)=pvaGet(Query, AIDA_DOUBLE);
    end
  catch e
    handleExceptions(e, 'Failed to get fudge factor softIOC values');
  end
  unLEM.Fudge=Fudge;
  if (debug)
    disp('*** debugLEM: no softIOC fudge factor PV values set')
  else
    try
      for n=1:4
        Query=strcat(lemPVs(n),':VAL');
        pvaSet(Query, lemFudge(n));
      end
    catch e
        handleExceptions(e, 'Failed to set fudge factor softIOC values');
    end
  end
end

stat=1;

end
