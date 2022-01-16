function stat=LEM_SetPowerSupplies()
%
% Set new BDES values for selected power supplies and trim; save extant BDES
% values so that we can unLEM

global debugFlags
debug=debugFlags(4);

global PS unLEM

% AIDA-PVA imports
global pvaRequest pvaSet AidaPvaStruct;
global AIDA_DOUBLE AIDA_STRING;

% extract lists of pointers to SLC and EPICS magnets to be set

idSLC=intersect(find([PS.epics]==0),find([PS.setNow]))';
nSLC=length(idSLC);
idEPICS=intersect(find([PS.epics]==1),find([PS.setNow]))';
nEPICS=length(idEPICS);

% give the user one final abort opportunity

stat=LEM_Prompt(3,nSLC,nEPICS);
if (~stat),return,end

% connect to the error log

if (~debug)
  errorLog=edu.stanford.slac.err.Err.getInstance('LEM');
end

% prepare unLEM.PS structure

unLEM.PS.idSLC=idSLC;
unLEM.PS.bdesSLC=zeros(size(idSLC));
unLEM.PS.idEPICS=idEPICS;
unLEM.PS.bdesEPICS=zeros(size(idEPICS));

% SLC magnets

if (~isempty(idSLC))

% get the extant BDES values (for unLEM)

  for m=1:nSLC
    n=idSLC(m);
    dbname=PS(n).dbname;
    bdesQuery=strcat(dbname,':BDES');
    try
      bsave=pvaGet(bdesQuery, AIDA_DOUBLE);
      unLEM.PS.bdesSLC(m)=bsave;
    catch e
        handleExceptions(e);
    end
  end

% set up properly formatted lists of dbnames and BDES values

  magnet=cellstr(char(PS(idSLC).dbname));
  bdes=[PS(idSLC).bnew];
  value = AidaPvaStruct();
  value.put('names', { magnet });
  value.put('values', { bdes });

% put the BDES values and trim all
  if (debug)
    disp('*** debugLEM: no SLC BDES values set')
  else
    try
      requestBuilder = pvaRequest('MAGNETSET:BDES');
      requestBuilder.with('MAGFUNC', 'TRIM');
      result = requestBuilder.set(value);

      errorLog.log('LEM: SLC magnet TRIM successful');
      disp('*** SLC TRIM successful')
    catch e
        handleExceptions(e, '*** one or more SLC magnets failed TRIM');
    end
  end
end

% EPICS magnets

if (~isempty(idEPICS))

% first loop ... get extant BDES value (for unLEM), set new BDES, set CTRL to
% TRIM

  for m=1:nEPICS
    n=idEPICS(m);
    dbname=PS(n).dbname;
    bdesQuery=strcat(dbname,':BDES:VAL');
    try
      bsave=pvaGet(bdesQuery, AIDA_DOUBLE);
    catch e
        handleExceptions(e, '');
    end
    unLEM.PS.bdesEPICS(m)=bsave;
    if (~debug)
      bdes=PS(n).bnew;
      pvaSet(bdesQuery, bdes);
      ctrlQuery=strcat(dbname, ':CTRL:VAL');
      pvaSet(ctrlQuery, 'TRIM');
    end
  end

  if (debug)
    disp('*** debugLEM: no EPICS BDES values set')
  else

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
        ctrlStateQuery=strcat(dbname,':CTRLSTATE:VAL');
        try
          state=pvaGet(ctrlStateQuery, AIDA_STRING);
          notDone(m)=~strcmp(state,'Done');
        catch e
            handleExceptions(e, '*** %s',ctrlStateQuery)
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

stat=1;

end
