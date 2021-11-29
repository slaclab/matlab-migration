function fbDispMsg(message, acro, alarmLevel)
%display the message string on the Feedback Global page, thru the
%STATUSDESC pv, and give it an alarm color via the STATUSALARM pv
%
%if this is a msg for Laser Power set, display it with the BCI string
% cut message size down to 39 for string PV
msg = message;
if(length(message)>39)
   msg = message(1:39);
end
if strcmp(acro,'LPS')>0 
   acro = 'BCI';
end
strPV = ['FBCK:' acro ':1:STATUSDESC'];
alarmPV = ['FBCK:' acro ':1:STATUSALARM'];
lcaPut(strPV, msg);
lcaPut(alarmPV, alarmLevel);
%now display it in the log file
%disp(message);

