function kmBeamOff(mainHandles)
% Turn electron beam off using BYKICK

display('Turning electron beam off using BYKICK');
if mainHandles.debug~=1;
    lcaPut('IOC:BSY0:MP01:BYKIKCTL',0); % stop the beam
end