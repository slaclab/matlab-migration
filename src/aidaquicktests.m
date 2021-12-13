echo on


% Test service
pvaGet('TEST:VAL')

% XAL Model Service Twiss
pvaGet('QUAD:LI21:221:twiss',AIDA_DOUBLE_ARRAY)

% XAL Model Service Rmat
pvaGet('QUAD:LI21:221:R',AIDA_DOUBLE_ARRAY)

% XAL Model Service Rmat A->B
requestBuilder = pvaRequest('QUAD:LI21:221:R')
requestBuilder.with('B','BPMS:LI21:701')
requestBuilder.returning(AIDA_DOUBLE_ARRAY)
requestBuilder.get()

% Full model data". Isn't done with aidaget
% aidaget('modelTwiss:Extant.FullMachine')

% Symbol service"
pvaGet('QUAD:LI21:221:element.effective_length')

% BSA Elements. Not done with aidaget
% aidaget('LCLS:BSA.elements.byZ')

% SLC Db service"
pvaGet('XCOR:LI21:900:TOLF')

% SLC RF Service"
requestBuilder = pvaRequest('KLYS:LI21:41:KPHR')
requestBuilder.with('BEAM',1)
requestBuilder.returning(AIDA_DOUBLE)
requestBuilder.get()

requestBuilder = pvaRequest('KLYS:LI21:41:PHAS')
requestBuilder.with('BEAM',1)
requestBuilder.returning(AIDA_DOUBLE)
requestBuilder.get()

requestBuilder = pvaRequest('KLYS:LI21:41:TACT')
requestBuilder.with('BEAM',1)
requestBuilder.returning(AIDA_STRING)
requestBuilder.get()

% SLC History.
requestBuilder = pvaRequest('KLYS:LI29:81:EACT.HIST')
requestBuilder.with('BEAM',1)
requestBuilder.returning(AIDA_DOUBLE)
requestBuilder.get()

aidaGetHistory('KLYS:LI29:81:EACT.HIST', ...
               {'11/24/2009 00:00:00';'11/25/2009 00:00:00'})

% EPICS CA data
pvaGet('QUAD:LI21:221:Z:VAL')

% EPICS Archiver
aidaGetHistory('QUAD:LI21:221:BDES:HIST.lcls',...
               {'11/24/2009 00:00:00'; '11/25/2009 00:00:00'})
