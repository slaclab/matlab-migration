%taper_control.m


function out = taper_control()
disp('taper control version 1.0 5/17/09');
delay = 1;
n = 0;
n = n + 1;
pv{n,1}= setup_pv(571, 'taper limit', 'mm', 1, 'taper_control');
pvmax_taper_n = n;
n = n + 1;
pv{n,1}= setup_pv(572, 'first undulator to taper', 'n', 1, 'taper_control');
pvfirst_n = n;
n = n + 1;
pv{n,1} = setup_pv(573, 'taper of first undulator', 'mm', 1, 'taper_control');
pvfirst_taper_n = n;
n = n + 1;
pv{n,1} = setup_pv(574, 'start power taper', 'n', 1, 'taper_control');
pvstart_power_n = n;
n = n + 1;
pv{n,1} = setup_pv(575, 'gain taper mm/section', 'mm/n', 4, 'taper_control');
pvgain_angle_n = n;
n = n + 1;
pv{n,1} = setup_pv(576, 'power taper mm/section', 'mm/n', 4, 'taper_control');
pvpower_angle_n = n;
n = n + 1;
pv{n,1} = setup_pv(577, 'quadratic taper mm/section2', 'mm/n*n', 5, 'taper_control');
pvpower_quad_n = n;
n = n + 1;
pv{n,1} = setup_pv(578, 'exponential taper / section', '1/n', 5, 'taper_control');
pvexponential_n = n;
n = n + 1;
pv{n,1} = setup_pv(579, 'enable taper motion', 'on/off', 1, 'taper_control');
pvenable_n = n;

old_taper_pv = 'SIOC:SYS0:ML00:FWF18';
new_taper_pv = 'SIOC:SYS0:ML00:FWF19';
current_taper_pv = 'SIOC:SYS0:ML00:FWF20';

lcaPut([old_taper_pv, '.DESC'], 'Original Taper');
lcaPut([new_taper_pv, '.DESC'], 'New Taper');
lcaPut([current_taper_pv, '.DESC'], 'Current Taper');


W = watchdog('SIOC:SYS0:ML00:AO568',ceil(1/delay), 'taper_control' );
if get_watchdog_error(W)
  disp('another copy of taper_control is running, exiting');
  return
end
lcaSetSeverityWarnLevel(5);  % disables unwanted warnings.
lcaSetMonitor(pv); % set up monitors
taper.max_taper = 15; % maximum allowed taper
taper.first = 6; % first undulator to control
taper.first_taper = -3; % position of first used undulator
taper.start_power = 17; % Start of power taper
taper.gain_angle = .1;  % mm per sector
taper.power_angle = .1; % additional mm per sector
taper.power_quad = .01; % mm per sector^2
taper.exponential = 0;
taper.enable = 0; 
undpvs = cell(33,1);
for n = 1:33
  undpvs{n,1} = ['USEG:UND1:', num2str(n), '50:TMXPOSC'];
end
data = lcaGet(pv);
while 1
  try
  update_motors = 0;
  pause(delay);
  W = watchdog_run(W); % run watchdogcounter
  if get_watchdog_error(W) % some error
    disp('Some sort of watchdog timer error'); % Just drop for now
    break; % exit program
  end
  flags = lcaNewMonitorValue(pv);
  if sum(flags)
    data = lcaGet(pv);
    if data(pvenable_n) ~= -1
      update_motors = 1;
    end
  end
  current_taper = lcaGet(undpvs); % gets existing taper
  lcaPut(current_taper_pv, [80 current_taper']);
  taper.first = data(pvfirst_n);
  taper.first_taper = data(pvfirst_taper_n);
  taper.start_power = data(pvstart_power_n);
  taper.gain_angle = data(pvgain_angle_n);
  taper.power_angle = data(pvpower_angle_n);
  taper.power_quad = data(pvpower_quad_n);
  taper.exponential = data(pvexponential_n);
  taper.enable = data(pvenable_n);
  taper.max_taper = data(pvmax_taper_n);  
  initial_vals = lcaGet(undpvs); %read initial pvs values directly
  taper_val = zeros(33,1);
  for j = taper.first : 33
    taper_val(j) = taper.first_taper + (j - taper.first) * taper.gain_angle;
    if j > taper.start_power
      taper_val(j) = taper_val(j) + (j-taper.start_power) * taper.power_angle + ...
        (j -taper.start_power)^2 * taper.power_quad;
      taper_val(j) = taper_val(j) + (exp((j-taper.start_power)*taper.exponential)-1);
    end
    if taper_val(j) > taper.max_taper
      taper_val(j) = taper.max_taper; % limit taper
    end
  end
  for j = 1:33
    if initial_vals(j) > 20 % undulator exracted
      taper_val(j) = initial_vals(j);
    end
  end
  lcaPut(new_taper_pv, [80 taper_val']);
  if (taper.enable == 1) && update_motors
     disp('moving motors');
    for j = taper.first:33
      lcaPut(undpvs, taper_val);
    end
  end
  if taper.enable == -1 % save as reference
    lcaPut(old_taper_pv, [80 current_taper']);
  end
  catch
  pause(1);
  disp('Some error caught, try again');
  end
end
lcaClear(pv); % clear monitors
out = taper;
end



function pvname = setup_pv(num, text, egu, prec, comment)
numtxt = num2str(round(num));
numlen = length(numtxt);
if numlen == 1
  numstr = ['00', numtxt];
elseif numlen == 2
  numstr = ['0', numtxt];
else
  numstr = numtxt;
end
pvname = ['SIOC:SYS0:ML00:AO', numstr];
lcaPut([pvname, '.DESC'], text);
lcaPut([pvname, '.EGU'], egu);
lcaPut([pvname, '.PREC'], prec);
lcaPut(pv_to_comment(pvname), comment);
end

function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end
