function kmBeamOn(mainHandles)
% Turn electron beam back on using BYKICK

display('Attempting to turn electron beam back ON');
if mainHandles.debug~=1;
    lcaPut('IOC:BSY0:MP01:BYKIKCTL',1); % let the beam thorugh
    pause(2); % a little time for feedback
end
