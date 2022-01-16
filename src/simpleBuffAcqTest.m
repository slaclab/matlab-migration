global pvaRequest;
try
    requestBuilder = pvaRequest('INJ_ELEC:BUFFACQ');
    requestBuilder.with('NRPOS', 10);
    requestBuilder.with('BPMD', 1);
    requestBuilder.with('BPMS', { 'BPMS:LI00:415' } );
    requestBuilder.get();
    'INJ_ELEC OK'
catch
    'INJ_ELEC Failed'
end

try
    requestBuilder = pvaRequest('ELECEP01:BUFFACQ');
    requestBuilder.with('NRPOS', 10);
    requestBuilder.with('BPMD', 8);
    requestBuilder.with('BPMS', { 'BPMS:EP01:185' } );
    requestBuilder.get();
    'ELECEP01 OK'
catch
    'ELECEP01 Failed'
end

try
    requestBuilder = pvaRequest('NDRFACET:BUFFACQ');
    requestBuilder.with('NRPOS', 10);
    requestBuilder.with('BPMD', 57);
    requestBuilder.with('BPMS', { 'BPMS:LI02:201' } );
    requestBuilder.get();
    'NDRFACET OK'
catch
    'NDRFACET Failed'
end
