function fbPwrSetTimerFcn(obj, event)
% timer callback function for feedback monitors
%----------------------- -------------------
%
%
% --------- function ----------------------------------------------
% --- the timer function for the feedback monitors
%
calcFeedback;

function calcFeedback
%  function for feedback calculations
%-----------------------START of FEEDBACK CODE -------------------
%
%
% --------- function ----------------------------------------------
% --- this is the function that will execute one feedback calculation
%
% The functions in this module are specific to the Bunch Charge feedback
% where a softIOC PV LASR:IN20:1:PCTRL is the actuator
%get the loop data structures
loop = getappdata(0, 'Loop_structure');
try
   loop.enable = lcaGet(loop.enablePV);

   % check the state PVs, if Off then stop the feedback
   indState = lcaGet(loop.indStatePV);
   state = lcaGet(loop.states.statePV);
   if (strcmp(indState, 'OFF')>0) || (strcmp(state, 'OFF')>0) 
      stop(loop.fbckTimer);
      return;
   end

   % increment the loop counter, and check the enable PV.
   % the enable PV is used to allow users/programs to temporarily disable the
   % feedback.  The user or program is responsible for enabling feedback again
   % via this PV, when done.
   loop.lCnt = loop.lCnt + 1;
   lcaPut(loop.cntPV, loop.lCnt);
   if loop.lCnt >= 99999
      loop.lCnt = 1;
   end
catch
   dbstack;
   % if monitor fails, then the softIOC is dead, stop the feedback.
   message = 'FB00 soft IOC is not responding';
   fbLogMsg(message);
   fbDispMsg(message, loop.feedbackAcro, 2);
   disp(message);
   stop(loop.fbckTimer);
   return;
end

try
   laser_flag = lcaNewMonitorValue(loop.laser_pwr_pv);
   camera_flag = lcaNewMonitorValue(loop.camera_pwr_pv);
   if laser_flag < 0 % error
      disp([loop.laser_pwr_pv, ' error ', flag]);
   end
   if camera_flag < 0 % error
      disp([loop.camera_pwr_pv', ' error ', flag]);
   end
   
   if  (laser_flag == 1) || (camera_flag == 1)  %new setting
      percent_pwr = lcaGet(loop.laser_pwr_pv);
      if percent_pwr == 0
         percent_camera = 100;
      else
         percent_camera = 100*lcaGet(loop.camera_pwr_pv) / percent_pwr;
      end
      percent_pwr = min(100, percent_pwr);
      percent_pwr = max(0, percent_pwr);
      percent_camera = min(100, percent_camera);
      percent_camera = max(0, percent_camera);

      old_power_wp = lcaGet(loop.wp_pv);
      old_camera_wp = lcaGet(loop.camera_pv);
      old_power = 100*(cos((pi/90)*(old_power_wp - loop.power_max_angle))^2);
      old_camera = 100*(cos((pi/90)*(old_power_wp - loop.power_max_angle))^2);

      disp(['old pwr = ', num2str(round(old_power)), '%  new pwr = ', ...
         num2str(percent_pwr), '%  old cam = ', num2str(round(old_camera)), ...
         '%  new cam = ', num2str(percent_camera), '%']);
   
      % USE NEW CALCS HERE
      %new_pwr_anglex = polyval(loop.P2, percent_pwr / 100) + loop.angle_offset;
      %new_cam_anglex = loop.camera_max_angle -(90/pi)*acos(sqrt(percent_camera / 100));
      new_pwr_anglex = loop.power_max_angle - (90/pi)*acos(sqrt(percent_pwr/100));
      new_cam_anglex = loop.camera_max_angle - (90/pi)*acos(sqrt(percent_camera/100));

      new_pwr_angle = round(new_pwr_anglex * 10000)/10000; % limit resolution
      new_cam_angle = round(new_cam_anglex * 10000)/10000;
      disp(['old_power_angle = ', num2str(old_power_wp), ' new =  ', num2str(new_pwr_angle),...
         '  old_camera_angle = ', num2str(old_camera_wp), ' new = ', num2str(new_cam_angle)]);

      if percent_pwr > old_power % move camera first
         lcaPutNoWait(loop.camera_pv, new_cam_angle); % move camera attenuator
         for jx =  1:40 % loop
            pause(loop.delay);
            rb = lcaGet(loop.camera_rb);
            diff = abs(rb - new_cam_angle); % check difference
            disp(['camera rb = ', num2str(rb), '  n = ', num2str(jx)]);
            if diff < 1
               break;
            end
         end
         lcaPutNoWait(loop.wp_pv, new_pwr_angle);
         %fbDispMsg(' ', loop.feedbackAcro, 0);
         for jx =  1:40 % loop
            pause(loop.delay);
            rb = lcaGet(loop.wp_readback);
            diff = abs(rb - new_pwr_angle); % check difference
            disp(['power rb = ', num2str(rb), '  n = ', num2str(jx)]);
            if diff < 1
               disp('done');
               break;
            end
         end
      else % move laser attenuator first
         lcaPutNoWait(loop.wp_pv, new_pwr_angle);
         for jx = 1:40 % loop
            pause(loop.delay);
            rb = lcaGet(loop.wp_readback);
            diff = abs(rb - new_pwr_angle); % check difference
            disp(['power rb = ', num2str(rb), '  n = ', num2str(jx)]);
            if diff < 1
               break;
            end
         end
         lcaPutNoWait(loop.camera_pv, new_cam_angle); % move camera attenuator
         %fbDispMsg(' ', loop.feedbackAcro, 0);
         for jx = 1:40 % loop
            pause(loop.delay);
            rb = lcaGet(loop.camera_rb);
            diff = abs(rb - new_cam_angle); % check difference
            disp(['new_cam_angle = ', num2str(new_cam_angle),...
                  'camera rb = ', num2str(rb), '  n = ', num2str(jx)]);
            if diff < 1
               disp('done');
               break;
            end
         end
      end
   end
catch
   disp('Caught error in lca - ignore and continue');
end

%update the loop structure and store it
setappdata(0,'Loop_structure',loop);

