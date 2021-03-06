% example magnet control and readback
%
% Name: example_magnet.m
%
% Author: Mike Zelazny
%
% ========================================================================
%
% Connect to Message Logger.
%
Logger = getLogger('example magnet');

%
% Actual magnetic field for ALL BPMS can be read via EPICS pvs
%
pv = cell(0);
pv{end+1} = 'XCOR:IN20:381:BACT'; % EPICS controlled magnet
pv{end+1} = 'LI23:XCOR:402:BACT'; % SLC controlled magnet
try
    put2log(sprintf('Attempt to read %s and %s', char(pv{1}), char(pv{2})));
    vals = lcaGet(pv',size(pv,2));
    for each = 1:size(pv,2)
        put2log(sprintf('%s = %s (kG-m)', pv{each}, vals(each,:)));
    end
catch
    put2log('lcaGet failed for magnet BACTs');
end

%
% The same exact code works for BDES
%
pv = cell(0);
pv{end+1} = 'XCOR:IN20:381:BDES'; % EPICS controlled magnet
pv{end+1} = 'LI23:XCOR:402:BDES'; % SLC controlled magnet
try
    put2log(sprintf('Attempt to read %s and %s', char(pv{1}), char(pv{2})));
    vals = lcaGet(pv',size(pv,2));
    for each = 1:size(pv,2)
        put2log(sprintf('%s = %s (kG-m)', pv{each}, vals(each,:)));
    end
catch
    put2log('lcaGet failed for magnet BDESs');
end

%
% All of the magnets can be set TRIM'd for PERTURB'd with Aida
%
if 0
    try
        inData = AidaPvaStruct();
        magnet = cell(0);

        magnet{end+1} = 'XCOR:IM20:381';
        magnet{end+1} = 'XCOR:LI23:402';
        inData.put('names', magnet);

        bdesValue(1) = vals(1);
        bdesValue(2) = vals(2);
        inData.put('values', bdesValue);

        d = pvaRequest('MAGNETSET:BDES');
        d.with('MAGFUNC', 'TRIM');
        d.set(inData);
        put2log(sprintf('Sucessful trim of XCOR:LI23:402 %f', bdes));
    catch e
        handleExceptions(e);
        put2log('Unable to trim XCOR:LI23:402');
    end
end
