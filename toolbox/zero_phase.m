function iok = zero_phase(handles,fdbk_pv,disable_pv,pdes_pv,phase_pvs,offset_pvs,MATLAB_pv,name,navg,wait,new_pdes)

pdes_str = inputdlg(sprintf(['This will "GOLD" the ' name ' phase so that it will then read %5.1f deg, while not actually changing any real phase settings.  You can continue or change the final phase reading?'],new_pdes),'CAUTION',1,{num2str(new_pdes)});
if isempty(pdes_str)
  iok = 0;
  return
end
new_pdes = str2double(pdes_str);

pdes0 = lcaGet(pdes_pv);                        % read current phase setpoint

set(handles.([name 'ZERO']),'BackgroundColor','white');
%cmnd = ['set(handles.' name 'ZERO,''BackgroundColor'',''white'')'];
%eval(cmnd)
drawnow

fdbk_on_off = lcaGet(fdbk_pv,0,'double');       % check if phase feedback on or off
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
phase = zeros(length(phase_pvs),navg);
for j = 1:navg                                  % average some phase readings
  str = sprintf('step:%3.0f...',j);
  set(handles.([name 'ZERO']),'String',str);
%  cmnd = ['set(handles.' name 'ZERO,''String'',' str ');'];
%  eval(cmnd)
  drawnow
  pact = lcaGet(phase_pvs);
  phase(:,j) = mod(pact + 180 - pdes0, 360) - 180 + pdes0;
  pause(wait);
end
phase_bar = mean(phase')';
current_offsets = lcaGet(offset_pvs);               % get current phase offsets
lcaPut(fdbk_pv,0,'double');                         % turn OFF feedback temporarily
lcaPut(disable_pv,1,'double');                      % disable feedback temporarily
disp(sprintf(['Original ' name ' PDES = %8.3f deg'],pdes0)) % show current phase setpoint in case needed
for j = 1:length(current_offsets)                   % show current phase offsets in case needed
  str = sprintf(['Original ' name ' phase offset-%1.0f = %8.3f deg'],j,current_offsets(j));
  disp(str)
end
if strcmp(name,'L1X')                               % X-band offsets work differently (Feb. 2, 2008 - PE)
%  new_offsets = current_offsets - (new_pdes - phase_bar);  
  new_offsets = -(current_offsets + (new_pdes - phase_bar));    % X-band offsets work differently AGAIN! (July 31, 2008 - PE)
else
  new_offsets = current_offsets + (new_pdes - phase_bar);
end
new_offsets = mod(new_offsets + 180, 360) - 180;
lcaPutSmart(offset_pvs,new_offsets,'double');            % set new phase offsets
lcaPut(pdes_pv,new_pdes,'double');                  % set new phase setpoint
lcaPut(disable_pv,0,'double');                      % re-enable feedback
lcaPut(fdbk_pv,1,'double');                         % switch ON feedback
crest_phase = 0;                                    % nom crest phase for L0A, L0B, L1S (deg)
if strcmp(name,'TCAV')
  crest_phase = 90;                                 % nom crest phase for TCAV (deg)
end
if strcmp(name,'L1X')
  crest_phase = -180;                               % nom crest phase for L1X (deg)
end
lcaPut(MATLAB_pv,crest_phase,'double');             % record latest phase setting
for j = 1:length(new_offsets)                       % show new phase offsets
  str = sprintf(['New ' name ' phase offset-%1.0f =      %8.3f deg'],j,new_offsets(j));
  disp(str)
end

set(handles.([name 'ZERO']),'BackgroundColor','default');
%cmnd = ['set(handles.' name 'ZERO,''BackgroundColor'',[0.701960784313725 0.701960784313725 0.701960784313725])'];
%eval(cmnd)
set(handles.([name 'ZERO']),'String','zero phase');
%cmnd = ['set(handles.' name 'ZERO,''String'',''zero phase'');'];
%eval(cmnd)
drawnow

iok = 1;                                                    % meaningless for now