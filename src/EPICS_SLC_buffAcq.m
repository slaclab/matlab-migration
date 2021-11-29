function [ buffAcqData , rawEPICSData ] = EPICS_SLC_buffAcq(region, epics_pv_list, SLC_device_list, pulses)
% buffAcqData is the merged data set - always contains all SLC Data
% rawEPICSData *optional* contains ALL EPICS data only

persistent sys;
persistent accelerator;

buffAcqData = 0;

if isempty(sys)
    [ sys , accelerator ] = getSystem();
end

if ~isequal('FACET',accelerator)
    put2log('Sorry, EPICS_SLC_buffAcq only implemented for FACET');
    return;
end

nRuns_pv = [ 'SIOC:' sys ':ML02:AO500' ];

try
    % Update run count
    lcaPut(nRuns_pv, 1+lcaGet(nRuns_pv));
    nRuns = lcaGetSmart(nRuns_pv);
    if isnan(nRuns)
        put2log(sprintf('Channel access failure for %s',nRuns_pv));
        lcaPut(status_pv,'Sorry, can''t increment run count');
        return;
    end
catch
    put2log('Had a problem trying to increment run count');
    return;
end

if isempty(epics_pv_list) && isempty(SLC_device_list)
    put2log('Sorry, no devices specified.');
    return;
end

if ~isempty(epics_pv_list)
    myName = sprintf('BUFFACQ %d',nRuns);
    % Reserve an eDef number
    myeDefNumber = eDefReserve(myName);
    if isequal (myeDefNumber, 0)
        put2log('Sorry, failed to get eDef');
        return;
    else
        % Get the INCM&EXCM
        [incmSet, incmReset, excmSet, excmReset] = getINCMEXCM(region);
        % Set the number of pulses
        if isempty(SLC_device_list)
            eDefParams (myeDefNumber, 1, pulses, incmSet, incmReset, excmSet, excmReset);
        else
            eDefParams (myeDefNumber, 1, 2800, incmSet, incmReset, excmSet, excmReset);
        end
        % press GO button
        if isempty(SLC_device_list)
            eDefAcq(myeDefNumber, 1.1*pulses);
        else
            eDefOn (myeDefNumber);
        end
    end
end

if ~isempty(SLC_device_list)
    buffAcqData  = buffAcq(region, SLC_device_list, pulses);
end

if isempty(epics_pv_list)
    return;
else
    eDefOff(myeDefNumber);
    EPICSData.pidVec = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d',sys,myeDefNumber));
    EPICSData.pulses = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d.NUSE',sys,myeDefNumber));
    EPICSData.pv = cell(0);
    for i = 1:length(epics_pv_list)
        EPICSData.pv{end+1}.name = epics_pv_list{i};
        EPICSData.pv{end}.data = lcaGetSmart(sprintf('%sHST%d',char(EPICSData.pv{end}.name),myeDefNumber));
        EPICSData.pv{end}.pulses = lcaGetSmart(sprintf('%sHST%d.NUSE',char(EPICSData.pv{end}.name),myeDefNumber));
    end
    eDefRelease(myeDefNumber);
    if (nargout > 1)
        rawEPICSData = EPICSData;
    end
end

if isempty(SLC_device_list)
    % merged data contains EPICS only, return first "pulses" pulses
    for indx = 1:min(pulses,EPICSData.pulses)
        buffAcqData(indx).pulse_id = EPICSData.pidVec(indx);
    end
end

% Merge in the EPICS data
for indx = 1:length(buffAcqData)
    for i = 1:EPICSData.pulses
        if isequal(buffAcqData(indx).pulse_id, EPICSData.pidVec(i))
            for j = 1:length(EPICSData.pv)
                if isfield(buffAcqData(indx),'epics')
                    idev = 1 + length(buffAcqData(indx).epics);
                else
                    idev = 1;
                end
                if i <= EPICSData.pv{j}.pulses
                    buffAcqData(indx).epics(idev).name = EPICSData.pv{j}.name;
                    buffAcqData(indx).epics(idev).data = EPICSData.pv{j}.data(i);
                end
            end
        end
    end
end
