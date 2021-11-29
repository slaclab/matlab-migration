% function checkEDef
% Function to check for old eDefs that can be released
%  - J. Rzepiela, 11/8/10
lcaPut('SIOC:SYS0:ML00:AO377.DESC','checkEDef counter')
msgout=sprintf('%s: Starting checkEDef\n',datestr(now)');
disp(msgout)
counter_max = 50000; %counter wraps here
counter=0; 
nratio=300; %check once per 5 min
basePV_EDEF=strcat({'EDEF:SYS0:'},num2str((1:15)','%-d'));
namePV_EDEF=strcat(basePV_EDEF,':NAME');

while(1) %infinite loop
    counter = mod(counter, counter_max);
    counter=counter+1;
    lcaPut('SIOC:SYS0:ML00:AO377',counter) %watcher heartbeat
    pause(1)
    if mod(counter, nratio) == 1 % Check initially
        status=[];activeTime=[];reservedTime=[];activeAge=[];reserveAge=[];age=[];
        disp_log('Checking EDEFs');
        namesEDEF=lcaGet(namePV_EDEF);
        namematch=find(~cellfun('isempty',regexp(namesEDEF,'BBA|CORRPLOT|WIRESCAN|ELoss|LAUNCH|TREX|BSA|VOM')));
        if ~isempty(namematch)
            status=lcaGet(strcat(basePV_EDEF(namematch),':CTRL'));
            activeTime=lcaGet(strcat(basePV_EDEF(namematch),':CTRLONTOD'));
            reservedTime=lcaGet(strcat(basePV_EDEF(namematch),':NAMETOD'));
            for idx=1:length(activeTime)
                try
                if ~isempty(activeTime{1})
                    activeAge(idx)=etime(clock,datevec(activeTime(idx)));
                    reserveAge(idx)=etime(clock,datevec(reservedTime(idx)));
                else
                    activeAge(idx)=100000; %empty last active date string -- force termination
                    reserveAge(idx)=100000; %empty last active date string -- force termination
                end
                catch
                    % CATER 132753 - check for reserved, but never active edef
                end
            end
            age=min(activeAge,reserveAge);
            age=age';
            try
                idx=find(strcmp(status,'OFF') & age > 86400);
            catch
                status
                age
                strcmp(status,'OFF')
                age > 86400
                idx=[]; 
            end
            if any(idx)
                msgout=char(strcat(datestr(now),': Releasing EDEF #',cellstr(num2str(namematch(idx))),{', '},namesEDEF(namematch(idx))));
%                msgout=sprintf('%s: Releasing EDEF #%g, %s\n',datestr(now)',namematch(idx),namesEDEF{namematch(idx)});
                disp(msgout)
                for j=idx', eDefRelease(namematch(j));end
            end
            nAvailable=lcaGet('IOC:IN20:EV01:EDEFAVAIL',0,'double');
            if nAvailable < 2 % only 1 EDEF available, release oldest inactive
                disp_log('Only 1 EDEF available. Releasing oldest inactive EDEF');
                idx=find(strcmp(status,'OFF'));
                if isempty(idx), disp_log('No inactive EDEF found to release');continue, end
                [val,indx] = max(age(idx));
                msgout=sprintf('%s: Releasing EDEF #%g, %s\n',datestr(now)',namematch(indx),namesEDEF{namematch(indx)});
                disp(msgout)
                eDefRelease(namematch(indx));
            end
        end
    end
end