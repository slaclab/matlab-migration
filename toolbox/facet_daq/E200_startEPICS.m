% S. Corde and S. Gessner 3/9/13
function [myeDefNumber, param] = E200_startEPICS(param)

sys = 'SYS1';
nRuns_pv = [ 'SIOC:' sys ':ML02:AO500' ];
try
    % Update run count
    lcaPut(nRuns_pv, 1+lcaGet(nRuns_pv));
    nRuns = lcaGetSmart(nRuns_pv);
    if isnan(nRuns)
        put2log(sprintf('Channel access failure for %s',nRuns_pv));
        if isfield(param,'warnings')
            param.warnings(end+1) = {'Can''t increment BUFFACQ run count.'};
        else
            param.warnings = cell(0,1);
            param.warnings(end+1) = {'Can''t increment BUFFACQ run count.'};
        end
        lcaPut(status_pv,'Sorry, can''t increment run count');
        return;
    end
catch
    put2log('Had a problem trying to increment run count');
    if isfield(param,'warnings')
        param.warnings(end+1) = {'Can''t increment BUFFACQ run count.'};
    else
        param.warnings = cell(0,1);
        param.warnings(end+1) = {'Can''t increment BUFFACQ run count.'};
    end
    return;
end


myName = sprintf('BUFFACQ %d',nRuns);
% Reserve an eDef number
myeDefNumber = eDefReserve(myName);
if isequal (myeDefNumber, 0)
	put2log('Sorry, failed to get eDef');
    if isfield(param,'warnings')
        param.warnings(end+1) = {'Failed to get BUFFACQ eDef.'};
    else
        param.warnings = cell(0,1);
        param.warnings(end+1) = {'Failed to get BUFFACQ eDef.'};
    end
	return;
else
    % Get the INCM&EXCM
    if param.event_code == 213
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('NDRFACET');
    elseif param.event_code == 233
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('SDRFACET');
    elseif param.event_code == 223
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('LASER10HZ');
    elseif param.event_code == 225
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('LASER1HZ');
    elseif param.event_code == 229
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('LASER10HZposi');
    elseif param.event_code == 231
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('LASER1HZposi');
    elseif param.event_code == 53
        [incmSet, incmReset, excmSet, excmReset, beamcode] = getINCMEXCM('PAMM10HZ');
    else
        error(['No support for event code ' num2str(param.event_code)]);
    end
	% Set the number of pulses
	eDefParams (myeDefNumber, 1, 2800, incmSet, incmReset, excmSet, excmReset, beamcode);
	% press GO button
	eDefOn (myeDefNumber);
end
    

end
