function outvar = deckerPhase_lowE(phaseIN)

% Sets phases and CUD warnings for low energy Decker phasing (-15 degree
% jitter suppression).
%
% This only impacts klystrons from LI25-LI28
%
% This version of the script does NOT change the klystron complement
%
% Input arguments:
%   phaseIN - takes string values of 'on' or 'off'.  If 'on', sets up
%   Decker phasing; if 'off', removes Decker phasing setup.
%
% LEA 8 May 2014


% Setting up warnings and phase configurations
if strcmp(phaseIN, 'on')
    m15 = -15;  m165 = -165; % when setting Decker phase
    lcaPut('SIOC:SYS0:ML01:AO248', 1) % Puts a warning on the LCLS Map CUD
    display('Setting Decker phases in LI25-LI28; setting CUD warnings')
    outvar = true;
elseif strcmp(phaseIN, 'off')
    m15 = 0;   m165 = 0;    % when setting back to zero
    lcaPut('SIOC:SYS0:ML01:AO248', 0) % Disables a warning on the LCLS Map CUD
    display('Returning LI25-LI28 phases to 0; removing CUD warnings')
    outvar = false;
else
    display('Invalid argument')
    return
end


% Setting phases
name=model_nameRegion('KLYS',{'LI25','LI26','LI27','LI28'});
control_phaseSet(name(1:2:end), m15);
control_phaseSet(name(2:2:end), m165);

