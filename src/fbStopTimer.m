function fbStopTimer(obj, event)
% timer callback function to stop the timer and clean up PVs
%----------------------- -------------------
%

%get the loop data structures
loop = getappdata(0, 'Loop_structure');

% set the loop state to off
loop.state = 0;

% set ctrl pvs to OFF, fbck PVs to OFF
try
   if ~isempty(loop.ctrl.allctrlPVs)
      lcaPut(loop.ctrl.allctrlPVs, '0');
   end
catch
   dbstack;
end

%turn the feedback state to OFF, ind. state OFF
try
   lcaPut(loop.states.statePV, '0');
   lcaPut(loop.indStatePV, '0');
   lcaPut(loop.statusPV, 'Off');
   %turn the feedback enable pv to ON
   lcaPut(loop.enablePV, '1');
   %set counter pv to 0
   lcaPut(loop.cntPV, 0);
   % set display string = 'Off'
   fbDispMsg('Off', loop.feedbackAcro, 0);
catch
   fbLogMsg([loop.feedbackAcro ' StopTimer:FB00 soft IOC is not responding - may require reboot.']);
   disp([loop.feedbackAcro ' StopTimer:FB00 soft IOC is not responding - may require reboot.']);
   dbstack;
end

%clear the PV monitors
try
   if ~isempty(loop.meas.chosenmeasPVs)
      lcaClear(loop.meas.chosenmeasPVs);
      % set the measurement FBCK pvs
      fbckPVs = fbGetFbckPVs(loop.meas.chosenmeasPVs);
      lcaPut(fbckPVs, '0');% not used in feedback anymore
   end
   if (isfield(loop, 'eDefNumber'))
      eDefRelease(loop.eDefNumber);
   end
catch
   dbstack;
end


try
   rmappdata(0,'Loop_structure');
   rmappdata(0,'Config_structure');
   exit;
catch
   dbstack;
   fbLogMsg([loop.feedbackAcro ' StopTimer could not remove app data']);
   disp([loop.feedbackAcro ' StopTimer could not remove app data']);
   rmappdata(0,'Loop_structure');
   rmappdata(0,'Config_structure');
   exit;
end
