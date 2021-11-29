function statesConfig = fbCheckMachineConditions(loop)
%
% This function checks all machine conditions that can effect the
% Longitudinal Feedback.  It will report which states can be measured,
% depending on the settings of chicanes, mirrors, TD11, D2, TDUND 
% It checks on BX01/02 magnet to see if beam is going to spect. dump.
% it checks BSY and BYKIK magnets to indicate which BPMs to use for DL2E.
%
%NOTE:  BYKIK is checked here, but in Fast Feedback it should be checked
% in the fbCheckBeamConditions routine, which checks conditions
% pulse-to-pulse. eventually BYKIK can act pulse-to-pulse
%
% input vars
% loop         - loop structure passed into this routine
%
% output vars
% statesConfig - structure that indicates which state is to be calc.ed
%                also records beam destination based on magnets

dsprVals = 0;
mirrorVals = 0;
dumpVals = 0;
mgntVals=0;

% get the values from magnet PVs
if (~isempty(loop.check.mgntPVs))
   try
      mgntVals = lcaGet(loop.check.mgntPVs, 0, 'char');
   catch
      message = 'No change to RF, mgnt PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
   end
end
% get all the values from dump PVs
if (~isempty(loop.check.dumpPVs))
   try
      dumpVals = lcaGet(loop.check.dumpPVs);
   catch
      message = 'No change to RF, Dump. PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
   end
end
% get all the values from dispersion PVs
if (~isempty(loop.check.dsprPVs))
   try
      dsprVals = lcaGet(loop.check.dsprPVs);
   catch
      message = 'No change to RF, Dspr. PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
   end
end
% get all the values from mirror PVs
if (~isempty(loop.check.mirrorPVs))
   try
      mirrorVals = lcaGet(loop.check.mirrorPVs);
   catch
      message = 'No change to RF,mirror PVs invalid';
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
   end
end
if (~isempty(loop.states.alldesPVs))
   try
      loop.states.desStates= lcaGet(loop.states.alldesPVs);
   catch
      message = 'Cannot get desired states PVs, quitting.'; 
      fbLogMsg(message);
      fbDispMsg(message, loop.feedbackAcro, 2);
      setappdata(0,'Loop_structure',loop);
      stop(loop.fbckTimer);
      return;
   end
end

statesConfig.toBSY = 0;
statesConfig.toSpectDump = 0;
statesConfig.yesBYKIK = str2num(mgntVals{3});

%Check for Spect Dump
if ( str2num(mgntVals{1}) < 0.01) % BX01/2 is off, going to Spect. Dump
   isUsed = zeros(6,1);
   statesConfig.toSpectDump=1;
   if (loop.states.desStates(1)>=1)
      isUsed(1) = 1;
   end
else
   isUsed = ones(6,1);
   % Check for DL1E
   if (loop.states.desStates(1)<1)
      isUsed(1) = 0;
   end
   % Check for BC1E
   if (loop.states.desStates(2)>0)
      if (dsprVals(1)<100)
         fbDispMsg('Dispersion in BC1 is too low', loop.feedbackAcro, 2);
         isUsed(2)=0;
      end
   else
      isUsed(2) = 0;
   end
   % Check for BC1BL
   if (loop.states.desStates(3)>0)
      if (dsprVals(1)<100)
         fbDispMsg('Dispersion in BC1 is too low', loop.feedbackAcro, 2);
         isUsed(3)=0;
      elseif (mirrorVals(1)<1)
         fbDispMsg('BL11 Mirror in LI21 is OUT', loop.feedbackAcro, 2);
         isUsed(3)=0;
      end
   else
      isUsed(3) = 0;
   end
   % Check for BC2E
   if (loop.states.desStates(4)>0)
      if (dumpVals(1)>0)  
         fbDispMsg('TD11 is IN', loop.feedbackAcro, 2);
         isUsed(4) = 0;
      elseif (dsprVals(2)<100)
         fbDispMsg('Dispersion in BC2 is too low', loop.feedbackAcro, 2);
         isUsed(4)=0;
      end
   else
      isUsed(4) = 0;
   end
   % Check for BC2BL
   if (loop.states.desStates(5)>0)
      if (dumpVals(1)>0)  
         fbDispMsg('TD11 is IN', loop.feedbackAcro, 2);
         isUsed(5) = 0;
      elseif (dsprVals(2)<100)
         fbDispMsg('Dispersion in BC2 is too low', loop.feedbackAcro, 2);
         isUsed(5)=0;
      elseif (mirrorVals(2)<1)
         fbDispMsg('BL21 Mirror in LI24 is OUT', loop.feedbackAcro, 2);
         isUsed(5)=0;
      end
   else
      isUsed(5) = 0;
   end
   % Check for DL2E
   statesConfig.toBSY = 0;
   if (loop.states.desStates(6)>0)
      if (dumpVals(1)>0)  
         fbDispMsg('TD11 is IN', loop.feedbackAcro, 2);
         isUsed(6) = 0;
      elseif (dumpVals(2)>0)
         fbDispMsg('D2 is IN', loop.feedbackAcro, 2);
         isUsed(6) = 0;
      elseif (strcmp(mgntVals{2}, 'TURNEDOFF')<1) %52B1 is not OFF
         statesConfig.toBSY = 1; % going to BSY 
      end
   else
      isUsed(6) = 0;
   end
end
statesConfig.used = isUsed;
end
