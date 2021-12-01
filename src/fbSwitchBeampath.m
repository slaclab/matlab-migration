function fbSwitchBeampath(name,beamto,restart)
% Function for switching the names of EPICS-based feedbacks between
% BSA-filtered values as specified in their MxDEVNAME properties. Also
% changes the POI for the chosen feedback.

% NAME is root name of transverse feedback (e.g., FBCK:FB02:TR02)
% BEAMTO (optional), 'HXR' or 'SXR'. Default: prompt user.
% RESTART (optional), Stop/Start the feedback after switching, value = 0 or 1
%     Default: Prompt user.

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
if (nargin<3) || ~ismember(restart,[0,1]);
    restart = [];
end
if ~ismember(name,fbs)
    disp(['Sorry, this isn''t allowed for feedback ' name '...'])
    if usejava('desktop') || ~isempty(restart)
        return
    else
        pause(10)
        exit
    end
end
if (nargin<2) || ~ismember(beamto,{'HXR','SXR'});
    beamto = questdlg(['Switch ' name ' to which line?'], ...
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

try
    nums = lcaGetSmart(strcat(name,':MEASNUM'));
    if any(isnan(nums))
        CORs='';BPMs='';error('Bad PVs in acutator number');end
    [pvs,~,ispv] = lcaGetSmart(strcat(name,':M',strtrim(cellstr(num2str((1:nums).'))),'DEVNAME'));
    if any(~ispv)
        CORs='';BPMs='';error('Bad PVs in measurement device names');end
    [pvsP,~,ispvP] = lcaGetSmart(strcat(name,':M',strtrim(cellstr(num2str((1:nums).'))),['DEVNAME' beamto]));
    if any(~ispvP)
        CORs='';BPMs='';error('Bad PVs in measurement device per beam path names');end
    if numel(pvs)==numel(pvsP) %this check could be more robust to check length of PVS for something sensible
        lcaPutSmart(strcat(name,':M',strtrim(cellstr(num2str((1:nums).'))),'DEVNAME'),pvsP);
    else
        error('Number of available PVs mismatched, check FB config with expert')
    end
    POI = lcaGetSmart(strcat(name,':POI1',beamto));
    if numel(POI)>1
        lcaPutSmart(strcat(name,':POI1'),POI);
    else
        disp('Not changing POI! Suspicious config saved for this beam path.')
    end
   if lcaGetSmart([name ':STATE'],1,'double')
       if isempty(restart)
           button = questdlg([name ' is currently running, but needs to be stop/started for the new measurements to take effect. Would you like me to do this now?'],...
               [name ' Switch'],'Yes','No','No');
       else
           if restart == 1
               button='Yes';
           else
               button='No';
           end
       end
       if strcmp(button,'Yes')
           disp_log(['Stop/Starting ' name]);
           lcaPutSmart([name ':STATE'],0);
           pause(2); % doing this too fast means it doesn't catch, esp if faulted? 0.5 s was too fast.
           lcaPutSmart([name ':STATE'],1);
       end
   end
catch ex
    disp(ex.message)
end
if usejava('desktop') || ~isempty(restart)
    return
else
    pause(10)
    exit
end