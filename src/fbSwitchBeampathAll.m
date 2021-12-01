function fbSwitchBeampathAll(beamto)
% Function for switching the names of EPICS-based feedbacks between
% BSA-filtered values as specified in their MxDEVNAME properties. Also
% changes the POI for the chosen feedback. Executes fbSwitchBeampath for
% ALL LCLS feedbacks from Gun thru LI28. Prompts for HXR or SXR beampath 
% but will automatically STOP/START all feedbacks as it goes!

% BEAMTO (optional), 'HXR' or 'SXR'. Default: prompt user.


fbs = {... % feedbacks allowed for configuration:
    'FBCK:FB01:TR01';... % gun
    'FBCK:FB02:TR05';... % inj1
    'FBCK:FB04:TR04';... % inj2
    'FBCK:FB03:TR03';... % inj3
    'FBCK:FB01:TR03';... % xcav
    'FBCK:FB01:TR04';... % l2
    'FBCK:FB02:TR01';... % l3
    'FBCK:FB02:TR02';... % li28
    };
fbnames = 'GUN, INJ1, INJ2, INJ3, XCAV, L2, L3, LI28';

if (nargin<1) || ~ismember(beamto,{'HXR','SXR'});
    beamto = questdlg({['This will switch timing for the transverse feedbacks ' fbnames '.'];'';...
        'Switch to which line?'}, ...
     'Feedback Path Switcher', ...
     'HXR', 'SXR', 'Cancel','Cancel');
    disp(beamto);
    if strcmp(beamto,'Cancel')
        disp('Okay, thanks for coming!')
        if usejava('desktop')
            return
        else
            exit
        end
    end
end
restart = 1;
for k = 1:numel(fbs)
    disp_log(['Switching ' fbs{k} ' to ' beamto ' rate...']);
    try
        fbSwitchBeampath(fbs{k},beamto,restart);
    catch ex
        disp([fbs{k} ' switch FAILED with message:'])
        disp(ex.message)
    end
end
disp('Done!')
if usejava('desktop')
    return
else
    pause(10)
    exit
end