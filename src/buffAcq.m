function [ buffAcqData ] = buffAcq(dgrp, device_list, nrpos)
% Read FACET SLC buffered Data Orbit with Aida - Zelazny

import java.util.Vector;

persistent da;
persistent sys;
persistent accelerator;

if isempty(sys)
    [ sys , accelerator ] = getSystem();
end

if ~isequal('FACET',accelerator)
    put2log('Sorry, buffAcq() only implemented for FACET');
    return;
end

try

    aidainit;

    if isempty(da)
        import edu.stanford.slac.aida.lib.da.DaObject; 
        da = DaObject();
    end

    da.reset();

    aida_command = [ dgrp '//BUFFACQ' ];

    da.setParam(sprintf('BPMD=%d',getBPMD(dgrp)));
    da.setParam(sprintf('NRPOS=%d',nrpos));

    for i = 1:length(device_list)
        da.setParam(sprintf('BPM%d=%s',i,char(device_list(i))));
    end

    vDeviceData = da.getDaValue(aida_command);

    names = Vector(vDeviceData.get(0));
    data(1) = Vector(vDeviceData.get(1));
    data(2) = Vector(vDeviceData.get(2));
    data(3) = Vector(vDeviceData.get(3));
    data(4) = Vector(vDeviceData.get(4));
    data(5) = Vector(vDeviceData.get(5));
    data(6) = Vector(vDeviceData.get(6));

    for i = 1:names.size()
        if isequal(1,i)
            buffAcqData(i).pulse_id = data(1).elementAt(i-1);
        end
        for indx = 1:length(buffAcqData)
            if isequal(buffAcqData(indx).pulse_id, data(1).elementAt(i-1))
                break;
            end
            indx = 1 + length(buffAcqData);
        end
        buffAcqData(indx).pulse_id = data(1).elementAt(i-1);
        name = names.elementAt(i-1);
        if strcmp('BPMS',name(1:4))
            if isfield(buffAcqData(indx),'bpms')
                idev = 1 + length(buffAcqData(indx).bpms);
            else
                idev = 1;
            end
            buffAcqData(indx).bpms(idev).name = names.elementAt(i-1);
            buffAcqData(indx).bpms(idev).x = data(2).elementAt(i-1);
            buffAcqData(indx).bpms(idev).y = data(3).elementAt(i-1);
            buffAcqData(indx).bpms(idev).tmit = data(4).elementAt(i-1);
            buffAcqData(indx).bpms(idev).stat = data(5).elementAt(i-1);
            buffAcqData(indx).bpms(idev).goodmeas = data(6).elementAt(i-1);
        end
        if strcmp('TORO',name(1:4))
            if isfield(buffAcqData(indx),'toro')
                idev = 1 + length(buffAcqData(indx).toro);
            else
                idev = 1;
            end
            buffAcqData(indx).toro(idev).name = names.elementAt(i-1);
            buffAcqData(indx).toro(idev).tmit = data(4).elementAt(i-1);
            buffAcqData(indx).toro(idev).stat = data(5).elementAt(i-1);
            buffAcqData(indx).toro(idev).goodmeas = data(6).elementAt(i-1);
        end
        if strcmp('KLYS',name(1:4))
            if isfield(buffAcqData(indx),'klys')
                idev = 1 + length(buffAcqData(indx).klys);
            else
                idev = 1;
            end
            buffAcqData(indx).klys(idev).name = names.elementAt(i-1);
            buffAcqData(indx).klys(idev).phase = data(2).elementAt(i-1);
            buffAcqData(indx).klys(idev).stat = data(5).elementAt(i-1);
        end
        if strcmp('SBST',name(1:4))
            if isfield(buffAcqData(indx),'sbst')
                idev = 1 + length(buffAcqData(indx).sbst);
            else
                idev = 1;
            end
            buffAcqData(indx).sbst(idev).name = names.elementAt(i-1);
            buffAcqData(indx).sbst(idev).phase = data(2).elementAt(i-1);
            buffAcqData(indx).sbst(idev).stat = data(5).elementAt(i-1);
        end
    end

catch
    put2log(sprintf('Sorry,Unable to read %s from Aida', dgrp));
    error = lasterror;
    disp(error.message);
end
