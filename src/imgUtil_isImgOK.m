function ok = imgUtil_isImgOK(rawImg, ipOutput)
ok = 0;
try
    if ~isfield(ipOutput, 'beamlist') 
        return;
    end
    if isempty(ipOutput.beamlist)
        return;
    end
    if isempty(rawImg.ignore)
        ok = ipOutput.isValid;
        return;
    end
    ok = ~rawImg.ignore;
catch
    %swallow
end