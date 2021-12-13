function [ name , x, y, z, tmit, hsta, stat ] = readOrbit(dgrp, navg)
% Read FACET BPM Orbit with Aida - Zelazny
%   dgrp (optional) defaults to NDRFACET
%   navg (optional) defaults to no averaging

import java.util.Vector;

persistent da;
persistent sys;
persistent accelerator;

if isempty(sys)
    [ sys , accelerator ] = getSystem();
end

if ~isequal('FACET',accelerator)
    put2log('Sorry, readOrbit() only implemented for FACET');
    return;
end

try
    if nargin < 1
        dgrp = 'NDRFACET';
    end

    aida_command = [ dgrp ':BPMS' ];

    requestBuilder = pvaRequest(aida_command);

    requestBuilder.with('BPMD', getBPMD(dgrp));

    if nargin < 2
        requestBuilder.with('N', 1);
    else
        requestBuilder.with('N', navg);
    end

    vBPMS = requestBuilder.get();

    nBPMS = vBPMS.size;
    name = toArray(vBPMS.get('name'));
    hsta = toArray(vBPMS.get('hsta'));
    stat = toArray(vBPMS.get('stat'));
    x = toArray(vBPMS.get('x'));
    y = toArray(vBPMS.get('y'));
    z = toArray(vBPMS.get('z'));
    tmit = toArray(vBPMS.get('tmits'));

catch
    put2log(sprintf('Sorry,Unable to read %s from Aida', dgrp));
    error = lasterror;
    disp(error.message);
end
