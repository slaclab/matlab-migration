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

    aidainit;

    if isempty(da)
        import edu.stanford.slac.aida.lib.da.DaObject; 
        da = DaObject();
    end

    da.reset();
    
    if nargin < 1
        dgrp = 'NDRFACET';
    end

    aida_command = [ dgrp '//BPMS' ];

    da.setParam(sprintf('BPMD=%d',getBPMD(dgrp)));

    if nargin < 2
        da.setParam('N=1');
    else
        da.setParam(sprintf('N=%d',navg));
    end

    vBPMS = da.getDaValue(aida_command);


    names = Vector(vBPMS.get(0));
    xvals = Vector(vBPMS.get(1));
    yvals = Vector(vBPMS.get(2));
    zvals = Vector(vBPMS.get(3));
    tmits = Vector(vBPMS.get(4));
    hstas = Vector(vBPMS.get(5));
    stats = Vector(vBPMS.get(6));
    nBPMS = names.size();
    for i = 1:nBPMS
        name(i) = {names.elementAt(i-1)};
        hsta(i) = hstas.elementAt(i-1);
        stat(i) = stats.elementAt(i-1);
        x(i) = xvals.elementAt(i-1);
        y(i) = yvals.elementAt(i-1);
        z(i) = zvals.elementAt(i-1);
        tmit(i) = tmits.elementAt(i-1);
    end

catch
    put2log(sprintf('Sorry,Unable to read %s from Aida', dgrp));
    error = lasterror;
    disp(error.message);
end
