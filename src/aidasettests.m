% TODO TRIG:LI31:109//TACT
% Set KLYS TACT
try
    name='KLYS:LI16:21:TACT';
    requestBuilder = pvaRequest(name);
    requestBuilder.with('BEAM', 1);
    requestBuilder.with('DGRP', 'LIN_KLYS');
    requestBuilder.returning(AIDA_STRING);
    requestBuilder.get();
catch e
    handleExceptions(e);
end

% Set KLYS KPHR to exitsing value + 0.1
try
    name='KLYS:LI16:21:TACT';
    requestBuilder = pvaRequest(name);
    requestBuilder.returning(AIDA_DOUBLE);
    requestBuilder.with('BEAM', 1);
    kphr = requestBuilder.get();
    newkphr = pvaSet(name, kphr-0.1);
catch e
    handleExceptions(e);
end

% Set KLYS PDES to exitsing value + 0.1
try
    name='KLYS:LI26:31:PDES';
    requestBuilder = pvaRequest(name);
    requestBuilder.returning(AIDA_DOUBLE);
    requestBuilder.with('BEAM', 1);
    pdes = requestBuilder.get();
    newpdes = pvaSet(name, pdes+0.1);
catch e
    handleExceptions(e);
end
