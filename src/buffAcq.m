function [ buffAcqData ] = buffAcq(dgrp, device_list, nrpos)
% AIDA-PVA imports
aidapva;

% Read FACET SLC buffered Data Orbit with Aida - Zelazny

import java.util.Vector;

if isempty(sys)
    [ sys , accelerator ] = getSystem();
end

if ~isequal('FACET',accelerator)
    put2log('Sorry, buffAcq() only implemented for FACET');
    return;
end

try

    aida_command = [ dgrp ':BUFFACQ' ];
    requestBuilder = pvaRequest(aida_command);
    requestBuilder.with('BPMD', getBPMD(dgrp));
    requestBuilder.with('NRPOS', nrpos);
    requestBuilder.with('BPMS', device_list);

    vDeviceData = ML(requestBuilder.get());

    names = vDeviceData.values.name;
    id = vDeviceData.values.id;
    x = vDeviceData.values.x;
    y = vDeviceData.values.y;
    tmits = vDeviceData.values.tmits;
    stat = vDeviceData.values.stat;
    goodmeas = vDeviceData.values.goodmeas;

    for i = 1:vDeviceData.size
        if isequal(1,i)
            buffAcqData(i).pulse_id = id(i);
        end
        for indx = 1:length(buffAcqData)
            if isequal(buffAcqData(indx).pulse_id, id(i))
                break;
            end
            indx = 1 + length(buffAcqData);
        end
        buffAcqData(indx).pulse_id = id(i);
        name = names.elementAt(i-1);
        if strcmp('BPMS',name(1:4))
            if isfield(buffAcqData(indx),'bpms')
                idev = 1 + length(buffAcqData(indx).bpms);
            else
                idev = 1;
            end
            buffAcqData(indx).bpms(idev).name = names.elementAt(i-1);
            buffAcqData(indx).bpms(idev).x = x(i);
            buffAcqData(indx).bpms(idev).y = y(i);
            buffAcqData(indx).bpms(idev).tmit = tmits(i);
            buffAcqData(indx).bpms(idev).stat = stat(i);
            buffAcqData(indx).bpms(idev).goodmeas = goodmeas(i);
        end
        if strcmp('TORO',name(1:4))
            if isfield(buffAcqData(indx),'toro')
                idev = 1 + length(buffAcqData(indx).toro);
            else
                idev = 1;
            end
            buffAcqData(indx).toro(idev).name = names(i);
            buffAcqData(indx).toro(idev).tmit = tmits(i);
            buffAcqData(indx).toro(idev).stat = stat(i);
            buffAcqData(indx).toro(idev).goodmeas = goodmeas(i);
        end
        if strcmp('KLYS',name(1:4))
            if isfield(buffAcqData(indx),'klys')
                idev = 1 + length(buffAcqData(indx).klys);
            else
                idev = 1;
            end
            buffAcqData(indx).klys(idev).name = names(i);
            buffAcqData(indx).klys(idev).phase = id(i);
            buffAcqData(indx).klys(idev).stat = stat(i);
        end
        if strcmp('SBST',name(1:4))
            if isfield(buffAcqData(indx),'sbst')
                idev = 1 + length(buffAcqData(indx).sbst);
            else
                idev = 1;
            end
            buffAcqData(indx).sbst(idev).name = names(i);
            buffAcqData(indx).sbst(idev).phase = id(i);
            buffAcqData(indx).sbst(idev).stat = stat(i);
        end
    end

catch e
    put2log(sprintf('Sorry,Unable to read %s from Aida', dgrp));
    error = lasterror;
    handleExceptions(e);
end
