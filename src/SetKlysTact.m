function [status, summary] = SetKlysTact(query, beam, dgrp, value)

% Author: Bob Hall, Greg White
%
% Usage example:
%   [status] = SetKlysTact('KLYS:LI31:31//TACT', '1', 'LIN_KLYS', 1);
%
% Aida Klystron Set function.  This deactivates
% or reactivates a specified klystron on a specified beam code.
% It also returns a status code indicating the resulting status
% after the operation (the bit interpretation of the status code
% can be found in the VMS file slctxt:linklysta.txt).
%
% INPUTS:
%
% query - string consisting of a Aida instance name (e.g.,
% primary:micro:unit), double slashes, and the Aida attribute
% name TACT.
%
% beam - string containing a beam code number, eg '1' for normal LCLS.
%
% dgrp - string containing a display group name to which the
% specified klystron belongs.  For development simulated klystrons,
% this display group is DEV_DGRP.  For production klystrons, this
% display group can be LIN_KLYS.
%
% value - integer flag indicating whether the specified klystron
% is to be deactivated or reactivated on the specified beam code
% (0 => deactivate, 1 => reactivate).
%
% OUTPUT:
%
% status - returned integer status code of the klystron given in the
% query, at the time of exit of this procedure.  This code is simply the
% status code returned from VMS. See the VMS file [1]
% slctxt:linklysta.txt for the bit interpretation of this
% code. Note that this may include the SLEDED and SLED_TUNED bits
% being 1 in LCLS operation.
%
% summary - returned string summary of the status of the klystron
% given in the query argument, at the time of exit of this procedure.
% summary =
%      'ACCEL' if the klystron is in ACCELerate at exit of this script.
%      'STANDBY' if the klystron is in STANDBY at exit of this script.
%      'BAD' if the klystron is in maintenance, offline, check
%      phase (CKP), To Be Replaced (TBR), or Awaiting Run Up (ARU).
%
% Mod: 1-Dec-2008, Greg White (greg)
%      Removed use of Err.log and Err.logl because when used from
%      Phase_Scan.m the log and logl methods can't be found!!!
%      20-Nov-08, Greg White (greg)
%      Significant update to add condition handling.
%

status = 0;
summary = 'INVALID';
activateAllowed = false;
deactivateAllowed = false;
ACTIVATE = 1;
DEACTIVATE = 0;
CANTACTIVATE = '; Cannot activate';
CANTDEACTIVATE = '; Cannot deactivate';

% The relevant LINKLYSTA bits are only the following. Its assumed
% that SLED_TUNED and SLEDED are irrelevant w.r.t. KLYS
% activation/deactivation for LCLS.
%
LINKLYSTA_ACCEL =        uint16(hex2dec('0001'));
LINKLYSTA_STANDBY =      uint16(hex2dec('0002'));
LINKLYSTA_BAD =          uint16(hex2dec('0004'));

% The relevant DSTA and STAT bits (not already encapsulated in LINKLYSTA)
DSTA_MKSUTRIGGERFAULT =  uint32(hex2dec('10000000'));
DSTA_MODULATORON      =  uint32(hex2dec('20000000'));
STAT_BADCAMAC         =  uint16(hex2dec('0010'));

if (value == ACTIVATE)
    valuestring = 'reactivate';
elseif (value == DEACTIVATE)
    valuestring = 'deactivate';
else
    disp(['Invalid Klys activate/deactivate argument to ' ...
              'SetKlysTact']);
end

% Extract the device name from the query (ie minus :TACT).
device = getInstance(query);

% Get Klystron Status. Are we assuming all Klystrons are SLC?
[linklysta,stat,swrd, hdsc, dstaback] = control_klysStatGet(device);
status = linklysta;
dsta = dstaback(1);

% Check for device being in STAT = MAINT or STAT = OFFLINE, or any
% of the conditions rolled up into LINKLYSTA [1] (CheckPhase (CKP),
% TBR, ARV, OFFLINE, MAINT).
%
if bitand(linklysta, LINKLYSTA_BAD)
    disp([ device ' is in MAINT, OFFLINE, CKP, TBR or ARU.']);
    summary = 'BAD';
    return
end

% If Activate was requested, see if that's allowed.
%
if value == ACTIVATE
    % Have to be in STANDBY to activate
    if bitand(linklysta,LINKLYSTA_STANDBY)
        % ... and there must not be an MKSU Trigger fault
        if bitand(dsta,DSTA_MKSUTRIGGERFAULT) == false
            % the modulator really should be be on
            if bitand(dsta, DSTA_MODULATORON)
                % ... and there must not be a CAMAC fault
                if bitand(stat, STAT_BADCAMAC) == false
                    activateAllowed = true;
                else
                    disp([ device ' has STAT Bad Camac' CANTACTIVATE]);
                end
            else
                disp([ device ' modulator not available' CANTACTIVATE]);
            end
        else
            disp([ device ' trigger enable fault' CANTACTIVATE]);
        end
    else
        disp([ device ' is in accelerate' CANTACTIVATE]);
    end
end

% If Deactivate was requested, see if that's allowed, and if
% allowed also check for warning conditions.
%
if value == DEACTIVATE

    % Have to be in ACCELerate to deactivate
    if bitand(linklysta,LINKLYSTA_ACCEL)
         % ... and there must not be a CAMAC fault
         if bitand(stat, STAT_BADCAMAC) == false
             deactivateAllowed = true;
         else
             disp([ device ' has STAT Bad Camac' CANTDEACTIVATE]);
         end
    else
        disp([ device ' is in not in accelerate' CANTDEACTIVATE]);
    end

    % Having checked for show stoppers, and being allowed to
    % proceed, now check for warning conditions.
    if deactivateAllowed
        % Warn if the modulator is not ON already
        if bitand(dsta, DSTA_MODULATORON) == false
            disp([ 'Deactivate proceeding, although ' device ...
                       ' modulator is not ON']);
        % Warn if MKSU Trigger fault
        elseif bitand(dsta,DSTA_MKSUTRIGGERFAULT)
            disp([ 'Deactivate proceeding, although ' device ...
                       ' had an MKSU Trigger fault']);
        end
    end

end


% The action is permitted, so go ahead and implement the state change.
%
if activateAllowed || deactivateAllowed

    try
        % initialize aida
        requestBuilder = pvaRequest(query);
        requestBuilder.with('BEAM', beam);
        requestBuilder.with('DGRP', dgrp);
        % Actually do the activate or deactivate
        status = requestBuilder.set(value);
    catch e
        handleExceptions(e, ['Error occurred during ' valuestring ' of ' device '.']);
    end
end

% Return the present status
[linklysta, stat, swrd, hdsc, dsta] = ...
    control_klysStatGet(device);
status = linklysta;
if bitand(linklysta, LINKLYSTA_BAD )
    summary = 'BAD';
elseif bitand( linklysta, LINKLYSTA_STANDBY )
    summary = 'STANDBY';
elseif bitand( linklysta, LINKLYSTA_ACCEL )
    summary = 'ACCEL';
else
    summary = 'INVALID';
end
disp([ device ' is in ' summary ' state as SetKlysTact exits.' ]);

return;
