function algNames = imgUtil_getAlgNames(ipOutputArray)
algNames = {};
for i=1:size(ipOutputArray, 2)
    ipOutput = ipOutputArray{i};
    if isempty(ipOutput)
        continue;
    end
    if getAlgNames(ipOutput)
        return;
    end
end
    %%%%%%%%%%
    function done = getAlgNames(ipOutput)
        done = 0;
        if isempty(ipOutput.beamlist)
            return;
        end
        try
            beamlist = ipOutput.beamlist;
            nrAlgs = size(beamlist, 2);
            for j=1:nrAlgs
                algNames{j} = beamlist(j).method;
            end
            done = 1;
        catch
            %do nothing
        end
    end
end