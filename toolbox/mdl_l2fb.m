% MDL_L2FB.m
% 
% This script reads the outside temperature  divides it by 6 (or something)
% and adjusts the L2 phase offset in rf panel: LLRF:IN20:RH:L2_POC
% limited to 0.01 deg change and a range from -74 to -86 deg
%
pvlist = {'ROOM:BSY0:1:OUTSIDETEMP'   ...       % CA01:ASTS:OUTSIDET' not used anymore
          'LLRF:IN20:RH:L2_POC'  ...
          'ROOM:LI22:1:LINACAIR_TEMP'};
                                          %  'LI22:ASTS:ISOPLAN0'   };
                                          %  changed 14-Nov-2011 FJD
                                          %  'TRP:LI22:313:P0_REF_TEMP'
                                          %  was removed 06-Dec-2017 MR
                                          %  temperature
                                          
gain = 1.0;                    % 0.8 means it corrects only 80% what I initally thought

W = watchdog('SIOC:SYS0:ML00:AO520',1, 'MDL_L2FB' );
if get_watchdog_error(W)
  disp('MDL_L2FB already running');
  return
end


[data]= lcaGetSmart(pvlist,0,'double'); 
temp_ave = data(3);                              % 1

while 0<1
   W = watchdog_run(W); % run watchdogcounter
   if get_watchdog_error(W) % some error
      disp(['MDL_L2FB Some sort of watchdog timer error ' datestr(now)]); % Just drop for now
      pause(1);
      continue;
   end
  
   [data]= lcaGetSmart(pvlist,0,'double'); 
   if (40 < data(3)) && (data(3) < 110)          % 1 30
      temp_ave = temp_ave*0.8 + data(3)*0.2;     % 1
   end
   
   % ffw = (60-temp_ave)/6.0 *gain - 80.0;
   %ffw = -(70-temp_ave)/6.0 *gain + 141.0;        %    160  60
   ffw = -(70-temp_ave)/6.0 *gain + 138.0;        %    160  60 70
   data(3)
   dffw=ffw-data(2)
   data(2)
   
   if     ffw > data(2) + 0.01
          ffw = data(2) + 0.01;
   elseif ffw < data(2) - 0.01
          ffw = data(2) - 0.01;
   end
   
   
  % if (-86 < ffw)  && (ffw < -74)
  % if ( 154 < ffw)  && (ffw < 166)
    if ( 134 < ffw)  && (ffw < 146)      %FJD changed 1-Feb-2016 since  Thanksgiving wrong
       lcaPutSmart('LLRF:IN20:RH:L2_POC',ffw);
   end
   pause(15)
end
