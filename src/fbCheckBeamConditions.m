function statesUsed = fbCheckBeamConditions(statesConfig, loop)
%
% This function checks all beam conditions that may effect the longitudinal
% feedback.  it reads the TMIT of BPMs near the dispersion BPMs to see if
% there is beam at each BPM (the dispersion BPMs may read TMIT even when
% there is not enough beam for good feedback). If the TMIT is low then the
% state is not used
%
%input vars
% loop - global loop data structure
% isUsed - a vector of 1/0 1=state is USED
%
%check TMIT values
chkVals = 0;
isUsed = statesConfig.used;
pvs = loop.check.chkPVs;

%check TMITs to be sure beam is on for this pulse
if (~isempty(loop.check.chkPVs))
   try
      if (statesConfig.toBSY<1)
         % remove BSY PV so we dont get an lca warning...
         pvs(4)=[];         
         if (statesConfig.toBSY>0) || (statesConfig.used(6)<1)
            % remove PV after D2 if going to SL52
            pvs(4)=[]; 
         end
      else
         if (statesConfig.toBSY>0) || (statesConfig.used(6)<1)
            % remove PV after D2 if going to SL52
            pvs(5)=[]; 
         end
      end
      chkVals = lcaGet(pvs);
   catch
      message = 'No change to RF, TMIT PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      %update the loop structure and store it
      setappdata(0,'Loop_structure',loop);
      return;
   end
end
%if TMIT of BPM221 is too low, the beam is off, just stop now
if (chkVals(end) < loop.check.low) || (isnan(chkVals(end)) )
   fbDispMsg('No change to RF,TMITs too low', loop.feedbackAcro, 2);
   isUsed = zeros(length(isUsed),1);
   % read the measurement PVs just to clear out data so that we don't get
   % sent through more loops when checking the newMonitorValue in the timer
   % function fbLongTimerFcn.m
   dummy = lcaGet(loop.meas.chosenmeasPVs);
else
   if (chkVals(1)<loop.check.low)
      isUsed(1)=0;
   end
   if (chkVals(2)<loop.check.low)
      isUsed(2)=0;
      isUsed(3)=0;
   end
   if (chkVals(3)<loop.check.low)
      isUsed(4)=0;
      isUsed(5)=0;
   end
   if (chkVals(4)<loop.check.low) 
      isUsed(6)=0;
   end
end
statesUsed = isUsed;

end


