function imgAcq_epics_putScreenPos(camera, val)
if ~camera.features.screen
    %do nothing
    return;
end
try
    lcaPut([camera.pvPrefix ':PNEUMATIC'], val);
catch
    %do nothing
end