% Check BSA SCORE region against BSA AIDA query
% Mike Zelazny x3673

Logger = getLogger('CheckBSASCOREPVs.m');

arg.region = 'BSA';
[data,comment,ts] = FromSCORE(arg);
put2log(sprintf('Found %d names in SCORE config',length(data)));

AidaBSAnames = getBSAnames();
put2log(sprintf('Found %d names in Aida query',length(AidaBSAnames)));

missing = 0;
for i = 1:length(data)
    found = 0;
    for j = 1:length(AidaBSAnames)
        if strcmp(deblank(data{i}.readbackName),deblank(AidaBSAnames(j,:)))
            found = 1;
        end
    end
    if found
        % Great!
    else
        missing = missing + 1;
        put2log(sprintf('%d: Found %s in SCORE BSA region, but it was not in the Aida query', missing, data{i}.readbackName));
    end
end
if missing
    % Missing Pvs reported
else
    put2log(sprintf('All %d PVs in SCORE BSA region are in the Aida query', length(data)));
end

missing = 0;
for i = 1:length(AidaBSAnames)
    found = 0;
    for j = 1:length(data)
        if strcmp(deblank(data{j}.readbackName),deblank(AidaBSAnames(i,:)))
            found = 1;
        end
    end
    if found
        % Great!
    else
        missing = missing + 1;
        %put2log(sprintf('%d: Found %s in SAida query, but it was not in the SCORE region', missing, deblank(AidaBSAnames(i,:))));
        disp(AidaBSAnames(i,:));
    end
end
if missing
    % Missing Pvs reported
else
    put2log(sprintf('All %d PVs in Aida query are in the SCORE BSA region', length(AidaBSAnames)));
end
