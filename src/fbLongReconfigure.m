function fbLongReconfigure()
%
% this function reconfigures the longitudinal feedback based on the
% loop.states.config.used vector.  It will reassign the lists of 'chosen'
% actuators, states and measurements so that when reading measurements,
% calculating states, and writing to actuators the feedback knows which
% devices/states are truly in use.  
%
% once the 'chosen' lists are complete, the fuction sets the 'USED' PVs for
% all devices/states so that they reflect the current operations, and then
% creates a 'mask' matrix (called 'recofig') for the multiplying matrix. 
% The reconfig mask will zero-out any unused rows and columns of the 6x6 matrix.
%
%get the loop data structures
loop = getappdata(0, 'Loop_structure');

%clear the current meas PV monitors
try
   if ~isempty(loop.meas.chosenmeasPVs)
      lcaClear(loop.meas.chosenmeasPVs);
   end
   
catch
   dbstack;
   fbLogMsg([loop.feedbackAcro ' reconfig could not clear monitors']);
   disp([loop.feedbackAcro ' reconfig could not clear monitors']);
end

% initialize
s = 0; a=0;
loop.meas.chosenmeasPVs = {};
loop.act.chosenactPVs = {};
loop.states.chosenstatePVs = {};
stateUsed = loop.states.config.used;

% reconfigure according to conditions && desired
for i=1:6 
   if (stateUsed(i) && i==1)                    %DL1E
      if loop.states.config.toSpectDump>0 %going to spect., 1x1 longitudinal
        s=s+1;
        a=a+1;
        loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{1,1};
        loop.act.chosenactPVs{a,1} = loop.act.allactPVs{1,1};
        loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{1,1};
        break;
      else
        s=s+1;
        a=a+1;
        loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{2,1};
        loop.act.chosenactPVs{a,1} = loop.act.allactPVs{1,1};
        loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{1,1};
        loop.states.chosenspPVs{s,1} = loop.states.allspPVs{1,1};
      end  
   end
   if stateUsed(i) && i==2                       %BC1E
      s=s+1;
      a=a+1;
      loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{3,1};
      loop.act.chosenactPVs{a,1} = loop.act.allactPVs{2,1};
      loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{2,1};
      loop.states.chosenspPVs{s,1} = loop.states.allspPVs{2,1};
   end
   if ( stateUsed(i) && i==3  )             %BC1BL
      s=s+1;
      a=a+1;
      loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{4,1};
      loop.act.chosenactPVs{a,1} = loop.act.allactPVs{3,1};
      loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{3,1};
      loop.states.chosenspPVs{s,1} = loop.states.allspPVs{3,1};
   end
   if ( stateUsed(i) && i==4 )               %BC2E
      s=s+1;
      a=a+1;
      loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{5,1};
      loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{4,1};
      loop.states.chosenspPVs{s,1} = loop.states.allspPVs{4,1};
      loop.act.chosenactPVs{a,1} = loop.act.allactPVs{4,1};
   end
   if ( stateUsed(i) && i==5 )                %BC2BL
      s=s+1;
      a=a+1;
      loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{6,1};
      loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{5,1};
      loop.states.chosenspPVs{s,1} = loop.states.allspPVs{5,1};
      loop.act.chosenactPVs{a,1} = loop.act.allactPVs{5,1};
   end
   if ( stateUsed(i) && i==6 )             %DL2E
      s=s+1;
      a=a+1;
      loop.act.chosenactPVs{a,1} = loop.act.allactPVs{6,1};
      loop.states.chosenstatePVs{s,1} = loop.states.allstatePVs{6,1};
      loop.states.chosenspPVs{s,1} = loop.states.allspPVs{6,1};
      if (loop.states.config.toBSY>0 )    %going to bsy 
        loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{7,1};
        loop.meas.chosenmeasPVs{s+1,1} = loop.meas.allmeasPVs{8,1};
        loop.meas.chosenmeasPVs{s+2,1} = loop.meas.allmeasPVs{9,1};
      elseif (loop.states.config.yesBYKIK<1 ) %bykik is active
        loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{10,1};
        loop.meas.chosenmeasPVs{s+1,1} = loop.meas.allmeasPVs{11,1};
        loop.meas.chosenmeasPVs{s+2,1} = loop.meas.allmeasPVs{12,1};
      else                               %use dl1 and dl3 bpms
        loop.meas.chosenmeasPVs{s,1} = loop.meas.allmeasPVs{12,1};
        loop.meas.chosenmeasPVs{s+1,1} = loop.meas.allmeasPVs{13,1};
      end   
  end  
  % now check the access for all chosen devices
  %if maccessChange>0
  %  for i=1:length(newmaccess)
  %    if strcmp(newmaccess(i)
  %end
  %if aaccessChange>0
  %end
end

% set in-use PVs as necessary 
% meas devices
loop.meas.PVs = ismember(loop.meas.allmeasPVs, loop.meas.chosenmeasPVs);
usedNames = fbAddToPVNames(loop.meas.allstorePVs, 'USED');
lcaPut(usedNames, double(loop.meas.PVs), 'long');
% states
loop.states.PVs = ismember(loop.states.allstatePVs, loop.states.chosenstatePVs);
usedNames = fbAddToPVNames(loop.states.allstatePVs, 'USED');
lcaPut(usedNames, double(loop.states.PVs), 'long');
loop.states.SPs = ismember(loop.states.allspPVs, loop.states.chosenspPVs);
% actuators
loop.act.PVs = ismember(loop.act.allactPVs, loop.act.chosenactPVs);
usedNames = fbAddToPVNames(loop.act.allstorePVs, 'USED');
lcaPut(usedNames, double(loop.act.PVs),'long');

% reset the measData running average structure
loop.measData.count = 0;
loop.measData.wrap = 0;
loop.measData.avg = 0;
loop.measData.max = 10; %loop.meas.maxsamples;
loop.measData.data = zeros(length(loop.meas.allmeasPVs),loop.measData.max);

% reconfig matrix. From 6 down zero columns and rows that are not needed
loop.matrix.reconfig = ones(6,6);
i = length(loop.states.allstatePVs);
while i>=1
    if loop.states.PVs(i)~=1
        loop.matrix.reconfig(:,i) = 0;
        loop.matrix.reconfig(i,:) = 0;
    end
    i=i-1;
end

% G.*F will perform element-wise multiply
loop.matrix.mult = loop.matrix.g.*loop.matrix.f;
% now mask out the rows/columns not needed
loop.matrix.mult = loop.matrix.mult.*loop.matrix.reconfig;

% set the measurement PV monitors and status PV monitors
try
  if ~isempty(loop.meas.chosenmeasPVs)
    lcaSetMonitor(loop.meas.chosenmeasPVs);
    %set FBCK pvs here too
    %fbckPVs = fbGetFbckPVs(loop.meas.chosenmeasPVs);
    %lcaPut(fbckPVs, '1');
  end
catch
  dbstack;
  fbLogMsg(['Could not monitor measurement PVs, ' config.feedbackName ' quitting']);
  rethrow(lasterror);
end

% get latests actuator values, since they may have changed
try
   actData.current = lcaGet(loop.act.allrbPVs);
   actData.original = actData.current;
catch
   dbstack;
   fbLogMsg([loop.feedbackAcro ' reconfig could not read actuators']);
   disp([loop.feedbackAcro ' reconfig could not read actuators']);
end

% reset status string
fbDispMsg(' ', loop.feedbackAcro, 0);

%save all the loop data in Loop_structure
setappdata(0, 'Loop_structure', loop);

end