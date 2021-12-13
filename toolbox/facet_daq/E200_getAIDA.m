function buffAcqData = E200_getAIDA(dgrp, device_list, nrpos)
% Read FACET SLC buffered Data Orbit with Aida - Zelazny

try

    disp(['I NEED A PITA! ' datestr(clock,'HH:MM:SS')]);

    aida_command = [ dgrp ':BUFFACQ' ];

    da = pvaRequest(aida_command);
    da.with('BPMD', getBPMD(dgrp));
    da.with('NRPOS', nrpos);
    da.with('BPMS', device_list);

    vDeviceData = da.get();
    disp(['FINITA! ' datestr(clock,'HH:MM:SS')]);

    names = vDeviceData.get('name');
    id = vDeviceData.get('id');
    x = vDeviceData.get('x');
    y = vDeviceData.get('y');
    tmits = vDeviceData.get('tmits');
    stat = vDeviceData.get('stat');
    goodmeas = vDeviceData.get('goodmeas');

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
        name = names(i);
        if strcmp('BPMS',name(1:4))
            if isfield(buffAcqData(indx),'bpms')
                idev = 1 + length(buffAcqData(indx).bpms);
            else
                idev = 1;
            end
            buffAcqData(indx).bpms(idev).name = names(i);
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
            buffAcqData(indx).klys(idev).name = names.(i);
            buffAcqData(indx).klys(idev).phase = x(i);
            buffAcqData(indx).klys(idev).stat = stat(i);
        end
        if strcmp('SBST',name(1:4))
            if isfield(buffAcqData(indx),'sbst')
                idev = 1 + length(buffAcqData(indx).sbst);
            else
                idev = 1;
            end
            buffAcqData(indx).sbst(idev).name = names(i);
            buffAcqData(indx).sbst(idev).phase = x(i);
            buffAcqData(indx).sbst(idev).stat = stat(i);
        end
    end

catch
    put2log(sprintf('Sorry,Unable to read %s from Aida', dgrp));
    error = lasterror;
    disp(error.message);
end
