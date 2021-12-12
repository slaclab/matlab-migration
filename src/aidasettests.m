% TODO TRIG:LI31:109//TACT

% Set KLYS TACT
name='KLYS:LI16:21:TACT'
requestBuilder = pvaRequest(name)
requestBuilder = requestBuilder.with('BEAM', 1)
requestBuilder = requestBuilder.with('DGRP', 'LIN_KLYS')
requestBuilder = requestBuilder.returning(AIDA_STRING)
requestBuilder.get()

% Set KLYS KPHR to exitsing value + 0.1
name='KLYS:LI16:21:TACT'
requestBuilder = pvaRequest(name)
requestBuilder = requestBuilder.returning(AIDA_DOUBLE)
requestBuilder = requestBuilder.with('BEAM', 1)
kphr = requestBuilder.get()

requestBuilder = pvaRequest(name)
newkphr = requestBuilder.set(kphr-0.1)

% Set KLYS PDES to exitsing value + 0.1
% STATUS: 16-Mar-2010: Tested. SLC says "Completed with ERRORS"
name='KLYS:LI26:31:PDES'
requestBuilder = pvaRequest(name)
requestBuilder = requestBuilder.returning(AIDA_DOUBLE)
requestBuilder = requestBuilder.with('BEAM', 1)
pdes = requestBuilder.get()

requestBuilder = pvaRequest(name)
newpdes = requestBuilder.set(pdes+0.1)

% BGRP
