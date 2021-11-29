function [data, epics, image] = Acq_epics_pv_image(pv_list, prof_list, pulses)
% S. Corde and S. Gessner 6/2/12

pause on;

%pv_list = vertcat(pv_list, strcat(prof_list,':ROI_X'), strcat(prof_list,':ROI_Y'), ...
%    strcat(prof_list,':ROI_XNP'), strcat(prof_list,':ROI_YNP'));
% pv_list{1, end+1} = strcat(prof_list,':ROI_Y');
% pv_list{1, end+1} = strcat(prof_list,':ROI_XNP');
% pv_list{1, end+1} = strcat(prof_list,':ROI_YNP');


% Test for bufferable epics data
[A,B,ISPV] = lcaGetSmart(strcat(pv_list,'HST1'));

no_bsa_list  = pv_list(~ISPV);  % Not BSA, not bufferable PV list
bsa_list = pv_list(ISPV);  % BSA and bufferable PV list

% Test for existence
[A,B,ISPV] = lcaGetSmart(no_bsa_list);
for i=1:length(ISPV)
    if(~ISPV(i))
        error('You fucked up! PV %s does not exist or is not connected.',no_bsa_list{i});
    end
end

sys = 'SYS1';
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

if ~isempty(pv_list)
    myName = sprintf('BUFFACQ %d',nRuns);
    % Reserve an eDef number
    myeDefNumber = eDefReserve(myName);
    if isequal (myeDefNumber, 0)
        put2log('Sorry, failed to get eDef');
        return;
    else
        % Get the INCM&EXCM
        [incmSet, incmReset, excmSet, excmReset] = getINCMEXCM('NDRFACET');
        % Set the number of pulses
        eDefParams (myeDefNumber, 1, 2800, incmSet, incmReset, excmSet, excmReset);
        % press GO button
        eDefOn (myeDefNumber);
    end
end
pause(1.5);
[image, nonBSA] = Acq_Image(prof_list, pulses, no_bsa_list);

eDefOff(myeDefNumber);
epics.pidVec = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d',sys,myeDefNumber));
epics.pulses = lcaGetSmart(sprintf('PATT:%s:1:PULSEIDHST%d.NUSE',sys,myeDefNumber));
epics.pv = cell(0);
for i = 1:length(bsa_list)
    epics.pv{end+1}.name = bsa_list{i};
    epics.pv{end}.data = lcaGetSmart(sprintf('%sHST%d',char(epics.pv{end}.name),myeDefNumber));
    epics.pv{end}.pulses = lcaGetSmart(sprintf('%sHST%d.NUSE',char(epics.pv{end}.name),myeDefNumber));
end
eDefRelease(myeDefNumber);


% Get PulseID list from Profile Monitors
pid_list = unique([image.prof_pid]);

% Merge EPICS PVs and images in data
for indx = 1:length(pid_list)
    data(indx).PulseID = pid_list(indx);
    for j = 1:length(prof_list)
        name = regexprep(image(1,j).name, ':', '_');
        found_pid = 0;
        for i = 1:pulses
            if isequal(pid_list(indx), image(i, j).prof_pid)
                data(indx).(char(name)).prof_ts    = image(i, j).prof_ts;
                data(indx).(char(name)).prof_pid   = image(i, j).prof_pid;
                data(indx).(char(name)).prof_roiX  = image(i, j).init_roiX;
                data(indx).(char(name)).prof_roiY  = image(i, j).init_roiY;
                data(indx).(char(name)).prof_roiXN = image(i, j).init_roiXN;
                data(indx).(char(name)).prof_roiYN = image(i, j).init_roiYN;
                data(indx).(char(name)).img = reshape(image(i, j).img(1:image(i, j).init_roiXN*...
                    image(i, j).init_roiYN), image(i, j).init_roiXN, image(i, j).init_roiYN);
                found_pid = 1;
                if j==length(prof_list)
                    for k = 1:length(no_bsa_list)
                        name = regexprep(nonBSA(1,k).name, ':', '_');
                        data(indx).(char(name)).val = nonBSA(i, k).val;
                        data(indx).(char(name)).BSA = 0;
                    end                   
                end
            end
        end
        if found_pid == 0;
            data(indx).(char(name)).prof_ts    = [];
            data(indx).(char(name)).prof_pid   = [];
            data(indx).(char(name)).prof_roiX  = [];
            data(indx).(char(name)).prof_roiY  = [];
            data(indx).(char(name)).prof_roiXN = [];
            data(indx).(char(name)).prof_roiYN = [];
            data(indx).(char(name)).img = [];
            if j==length(prof_list)
            	for k = 1:length(no_bsa_list)
                	name = regexprep(nonBSA(1,k).name, ':', '_');
                	data(indx).(char(name)).val = [];
                    data(indx).(char(name)).BSA = [];
                end
            end
        end     
    end
    for i = 1:epics.pulses
        if isequal(pid_list(indx), epics.pidVec(i))
            for j = 1:length(bsa_list)
                name = regexprep(epics.pv{j}.name, ':', '_');
                data(indx).(name).val = epics.pv{j}.data(i);
                data(indx).(name).BSA = 1;
            end

        end
    end
end
                
                
     