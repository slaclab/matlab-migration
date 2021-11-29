function iok = calib_voltage(handles,fdbk_pv,disable_pv,ades_pv,amp_pvs,scale_pvs,name,navg,wait,low_lim,high_lim)

ades0 = lcaGet(ades_pv);
ades_str = inputdlg(['This will re-calibrate the ' name ' voltage, while not actually changing any real voltage settings.  You should enter the pre-determined actual voltage now, or cancel?'],'ENTER NEW VOLTAGE',1,{num2str(ades0)});
if isempty(ades_str)
  iok = 0;
  return
end
new_ades = str2double(ades_str);
if (new_ades < low_lim) || (new_ades > high_lim)
  iok = 0;
  warndlg(sprintf('This is out of range: %4.1f MV < V < %4.1f MV',low_lim,high_lim),'ERROR')
  return
end

cmnd = ['set(handles.' name 'CAL,''BackgroundColor'',''white'')'];
eval(cmnd)
drawnow

fdbk_on_off = lcaGet(fdbk_pv,0,'double');       % check if voltage feedback on or off
disabled    = lcaGet(disable_pv,0,'double');    % check if feedback output disabled
if fdbk_on_off==0                               % quit if feedback OFF
  warndlg([name ' RF feedback is OFF - quitting.'],[name ' FDBK OFF'])
  iok = 0;
  return
end
if disabled                                     % quit if feedback disabled
  warndlg([name ' RF feedback is DISABLED - quitting.'],[name ' FDBK DISABLED'])
  iok = 0;
  return
end
volts = zeros(length(amp_pvs),navg);
for j = 1:navg                                  % average some voltage readings
  str = 'sprintf(''step:%3.0f...'',j)';
  cmnd = ['set(handles.' name 'CAL,''String'',' str ');'];
  eval(cmnd)
  drawnow
  vact = lcaGet(amp_pvs);
  volts(:,j) = vact;
  pause(wait);
end
volts_bar = mean(volts')';
current_scalars = lcaGet(scale_pvs);                % get current scalar values
lcaPut(fdbk_pv,0,'double');                         % turn OFF feedback temporarily
lcaPut(disable_pv,1,'double');                      % disable feedback temporarily
disp(sprintf(['Original ' name ' ADES = %8.3f MV'],ades0)) % show current voltage setting in case needed
for j = 1:length(current_scalars)                   % show current phase offsets in case needed
  str = sprintf(['Original ' name ' voltage scale factor-%1.0f = %8.6f'],j,current_scalars(j));
  disp(str)
end
new_scalars = new_ades./volts_bar.*current_scalars;

lcaPut(scale_pvs,new_scalars,'double');             % set new voltage scale factors
lcaPut(ades_pv,new_ades,'double');                  % set new voltage setpoint
lcaPut(disable_pv,0,'double');                      % re-enable feedback
lcaPut(fdbk_pv,1,'double');                         % switch ON feedback
for j = 1:length(new_scalars)                       % show new voltage scale factors
  str = sprintf(['New ' name ' voltage scale factor-%1.0f =      %8.6f'],j,new_scalars(j));
  disp(str)
end

cmnd = ['set(handles.' name 'CAL,''BackgroundColor'',[0.701960784313725 0.701960784313725 0.701960784313725])'];
eval(cmnd)
if strcmp(name,'GUN')
  cmnd = ['set(handles.' name 'CAL,''String'',''gun calib'');'];
else
  cmnd = ['set(handles.' name 'CAL,''String'',''calib. volts'');'];
end
eval(cmnd)
drawnow

iok = 1;                                                    % meaningless for now