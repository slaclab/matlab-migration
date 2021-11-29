function stat=LEM_Undo()
%
% Restore BDES values from most recent Scale Magnets, and trim

% ------------------------------------------------------------------------------
% 21-FEB-2009, M. Woodley
%    Restore EPICS magnet EDES PVs values, too
% ------------------------------------------------------------------------------

aidainit
da=DaObject;da.reset
dav=DaValue;dav.reset

global debugFlags
debug=debugFlags(4);

global lemPVs
global MAGNET PS unLEM

if (isempty(unLEM))
  disp('*** Nothing to unLEM')
  stat=1;
  return
end

% extract lists of pointers to SLC and EPICS magnets to be set

idSLC=unLEM.PS.idSLC;
nSLC=length(idSLC);
idEPICS=unLEM.PS.idEPICS;
nEPICS=length(idEPICS);

% give the user one final abort opportunity

stat=LEM_Prompt(4,nSLC,nEPICS);
if (~stat),return,end

% connect to the error log

if (~debug)
  errorLog=edu.stanford.slac.err.Err.getInstance('LEM');
end

% SLC magnets

if (~isempty(idSLC))

% set up properly formatted lists of dbnames and BDES values

  magnet=cellstr(char(PS(idSLC).dbname));
  bdes=unLEM.PS.bdesSLC;
  dav.type=0; % DaValue.Type.STRUCT;
  dav.addElement(DaValue(magnet));
  dav.addElement(DaValue(bdes));

% put the BDES values and trim all

  if (debug)
    disp('*** debugLEM: no SLC BDES values reset')
  else
    da.setParam('MAGFUNC=TRIM');
    try
      result=da.setDaValue('MAGNETSET//BDES',dav); % (0)=status, (1)=BACT
      errorLog.log('LEM: SLC magnet TRIM successful');
      disp('*** SLC TRIM successful')
    catch
      errorLog.log('LEM: SLC magnet TRIM returned with errors, please see Message Log');
      disp('*** one or more SLC magnets failed TRIM')
    end
  end
end

% EPICS magnets

if (~isempty(idEPICS))
  if (debug)
    disp('*** debugLEM: no EPICS BDES values reset')
  else

  % first loop ... restore BDES, set CTRL to TRIM

    da.reset
    for m=1:nEPICS
      n=idEPICS(m);
      dbname=PS(n).dbname;
      bdesQuery=strcat(dbname,':BDES//VAL');
      bdes=unLEM.PS.bdesEPICS(m);
      da.setDaValue(bdesQuery,DaValue(bdes));
      ctrlQuery=strcat(dbname,':CTRL//VAL');
      da.setDaValue(ctrlQuery,DaValue('TRIM'));
    end

  % second loop ... check that TRIM completed

    notDone=ones(size(idEPICS)); % guilty until proven innocent
    maxTry=10; % maximum number of times to check
    nTry=1;
    while ((nTry<=maxTry)&&(~isempty(find(notDone,1))))
      pause(1) % wait a bit
      id=find(notDone);
      for m=1:length(id)
        n=idEPICS(id(m));
        dbname=PS(n).dbname;
        ctrlStateQuery=strcat(dbname,':CTRLSTATE//VAL');
        try
          state=da.get(ctrlStateQuery,10);
          notDone(m)=~strcmp(state,'Done');
        catch
          error('*** %s',ctrlStateQuery)
        end
      end
      nTry=nTry+1;
    end
    if (~isempty(find(notDone,1)))
      errorLog.log('LEM: EPICS magnet TRIM successful');
      disp('*** EPICS TRIM successful')
    else
      errorLog.log('LEM: EPICS magnet TRIM returned with errors, please see Message Log');
      disp('*** one or more EPICS magnets failed TRIM')
    end
  end
end

% reset values in MAGNET structure; reset magnet EDES PV values

for m=1:length(unLEM.MAGNET.id)
  n=unLEM.MAGNET.id(m);
  MAGNET(n).bdes=unLEM.MAGNET.bdes(m);
  MAGNET(n).energy0=unLEM.MAGNET.energy0(m);
  MAGNET(n).bdes0=unLEM.MAGNET.bdes0(m);
  MAGNET(n).kl0=unLEM.MAGNET.kl0(m);
  if (~debug)
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
if (debug)
  disp('*** debugLEM: no magnet BDES PV values reset')
end

% if necessary, restore softIOC fudge factor values

if (isfield(unLEM,'Fudge'))
  if (debug)
    disp('*** debugLEM: no softIOC fudge factor PV values reset')
  else
    try
      for n=1:4
        Query=strcat(lemPVs(n),'//VAL');
        da.setDaValue(Query,DaValue(unLEM.Fudge(n)));
      end
    catch
      error('Failed to reset fudge factor softIOC values')
    end
  end
end

stat=1;

end
