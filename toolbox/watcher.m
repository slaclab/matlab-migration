 %watcher.m
function watcher()
disp('watcher.m 11/19/2008v1');
delay = .5; % loop delay time
nratio_1 = 20; % how many cycles for checks
nratio_2 = 20; % cycles for slow checks
nratio_3 = 7200; %cycles for eDef check
watcher_kill_pv = 'SIOC:SYS0:ML00:AO100';
matlab_pv_base = 'SIOC:SYS0:ML00:AO';
matlab_comment_pv_base = 'SIOC:SYS0:ML00:SO0';
error_status_pv = 'SIOC:SYS0:ML00:AO099'; % write status here
error_string_pv = 'SIOC:SYS0:ML00:CA002'; % write error message here
% define watcher pvs
num_watchers = 2;
counter_max = 10000; % main counter wraps here
watcher_ref_pv_base = cell(num_watchers,1);
watcher_ref_pv = cell(num_watchers,1);
watcher_comment_pv = cell(num_watchers,1);
watcher_ref_pv_base{1}= '090';
watcher_ref_pv_base{2} = '091';
watcher_file = '/home/physics/watcher_file.txt'; % file for output.


num_status_pvs = 9;
% initialize pvs - do not try/catch here, just bomb if can't read / write
%initialize ref_pv
startpvnum = 250;
s_pvs = cell(num_status_pvs,1);
s_pvs{1,1} = setup_pv(startpvnum+1, 'multiknob.m good', ' ', 4, 'watcher.m');
s_pvs{2,1} = setup_pv(startpvnum+2, 'BC2_energy_feedback good', ' ', 4, 'watcher.m');
s_pvs{3,1} = setup_pv(startpvnum+3, 'L23_set_phase good', ' ', 4, 'watcher.m');
s_pvs{4,1} = setup_pv(startpvnum+4, 'phase_cavity_monitor good', ' ', 4, 'watcher.m');
s_pvs{5,1} = setup_pv(startpvnum+5, 'watcher good', ' ', 4, 'watcher.m');
s_pvs{6,1} = setup_pv(startpvnum+6, 'phase_control good', ' ', 4, 'watcher.m');
s_pvs{7,1} = setup_pv(startpvnum+7, 'laser_camera good', ' ', 4, 'watcher.m');
s_pvs{8,1} = setup_pv(startpvnum+8, 'LLRF archiver', ' ', 4, 'watcher.m');
s_pvs{9,1} = setup_pv(startpvnum+9, 'Klystron Cud good', ' ', 4, 'watcher.m');
for j = 1:num_watchers % generate pv names
  watcher_ref_pv{j,1}= [matlab_pv_base, watcher_ref_pv_base{j}];
  watcher_comment_pv{j,1} =...
    [matlab_comment_pv_base, watcher_ref_pv_base{j}];
end


lcaPut([error_status_pv, '.DESC'], 'watcher error 0=OK');

% list PVs to scan
num_pvs = 50; %OK if this is too small, will increase later
pvs = cell(num_pvs,1);
name = cell(num_pvs,1);
error_level = zeros(1000,1) + 2; % default to 2 for all errors
status_pvnum = zeros(1000,1); % which status pv to display to
a = 0;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO076';
name{a} = 'L23_set_phase.m not running';
error_level(a) = 1;
status_pvnum(a) = 3;
a = a + 1;
num_bc2feedback = a;
pvs{a,1} = 'SIOC:SYS0:ML00:AO047';
name{a} ='No Energy feedback for BC2 is running';
status_pvnum(a) = 2;
a = a + 1;
pvs{a,1} = watcher_ref_pv{2,1};
name{a} = 'Only one watcher running';
error_level(a) = 1; % not a major error
status_pvnum(a) = 5;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO027';
name{a} = 'phase_cavity_monitor.m not running';
error_level(a) = 1;
status_pvnum(a) = 4;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO039';
name{a} = 'multiknob.m not running';
error_level(a) = 1;
status_pvnum(a) = 1;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO057';
name{a} = 'phase_control.m not running';
status_pvnum(a) = 6;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO068';
error_level(a) = 1;
name{a} = 'laser_camera.m not running';
status_pvnum(a) = 7;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO250';
error_level(a) = 1;
name{a} = 'LLRF Archiver not running';
status_pvnum(a) = 8;
a = a + 1;
pvs{a,1} = 'SIOC:SYS0:ML00:AO321';
error_level(a) = 1;
name{a} = 'KlystronCud.m not running';
status_pvnum(a) = 9;
num_incrementors = a;

%now look at feedback incrementors vs. status
a = a + 1;
pvs{a,1} = 'FBCK:LPS0:1:STATE';
pvs{a+1,1} = 'FBCK:LPS0:1:CNTDISP';
name{a} = 'Laser Power Set Feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
pvs{a,1} = 'FBCK:BCI0:1:STATE';
pvs{a+1,1} = 'FBCK:BCI0:1:CNTDISP';
name{a} = 'Bunch Charge feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
pvs{a,1} = 'FBCK:B5L0:1:STATE';
pvs{a+1,1} = 'FBCK:B5L0:1:CNTDISP';
name{a} = 'Gun Launch feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
pvs{a,1} = 'FBCK:INL0:1:STATE';
pvs{a+1,1} = 'FBCK:INL0:1:CNTDISP';
name{a} = 'Injector Launch (spectrometer) feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
pvs{a,1} = 'FBCK:INL1:1:STATE';
pvs{a+1,1} = 'FBCK:INL1:1:CNTDISP';
name{a} = 'Injector Launch feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
pvs{a,1} = 'FBCK:LNG0:1:STATE';
pvs{a+1,1} = 'FBCK:LNG0:1:CNTDISP';
name{a} = 'DL1 Energy (spectrometer) feedback green but not incrementing';
name{a+1} = '';
a = a + 2;

pvs{a,1} = 'FBCK:LNG1:1:STATE';
pvs{a+1,1} = 'FBCK:LNG1:1:CNTDISP';
name{a} = 'DL1 Energy feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
pvs{a,1} = 'FBCK:LNG2:1:STATE';
pvs{a+1,1} = 'FBCK:LNG2:1:CNTDISP';
name{a} = 'DL1 and BC1 energy feedback green but not incrementing';
name{a+1} = 'Stop then start DL1 and BC1 Energy feedback';
a = a + 2;
pvs{a,1} = 'FBCK:LNG3:1:STATE';
pvs{a+1,1} = 'FBCK:LNG3:1:CNTDISP';
name{a} = 'DL1, BC1 energy, BC1 bunchlength feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
num_bc2_efb1 = a;
pvs{a,1} = 'FBCK:LNG4:1:STATE';
pvs{a+1,1} = 'FBCK:LNG4:1:CNTDISP';
name{a} = 'DL1, BC1, BC2 energy feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
num_bc2_efb2 = a;
pvs{a,1} = 'FBCK:LNG5:1:STATE';
pvs{a+1,1} = 'FBCK:LNG5:1:CNTDISP';
name{a} = 'All energies + BC1 BL feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
num_bc2_efb3 = a;
pvs{a,1} = 'FBCK:LNG6:1:STATE';
pvs{a+1,1} = 'FBCK:LNG6:1:CNTDISP';
name{a} = 'All Energies and Bunchlengths feedback green but not incrementing';
name{a+1} = '';
a = a + 2;
num_feedbacks = (a-num_incrementors-1)/2;

mag_start_a = a;
magname = 'SOLN:IN20:121:';
pvs{a,1} = [magname, 'BDES'];
name{a} = [magname, 'BDES Not at config value'];
error_level(a) = 1; % medium severs
pvs{a+1,1} = [magname, 'BCON'];
a = a + 2;

magname = 'QUAD:IN20:121:';
pvs{a,1} = [magname, 'BDES'];
name{a} = [magname, 'BDES Not at config value'];
error_level(a) = 1; % medium severs
pvs{a+1,1} = [magname, 'BCON'];
a = a + 2;

magname = 'QUAD:IN20:122:';
pvs{a,1} = [magname, 'BDES'];
name{a} = [magname, 'BDES Not at config value'];
error_level(a) = 1; % medium severs
pvs{a+1,1} = [magname, 'BCON'];
a = a + 2;

magname = 'QUAD:IN20:525:';
pvs{a,1} = [magname, 'BDES'];
name{a} = [magname, 'BDES Not at config value'];
error_level(a) = 1; % medium severs
pvs{a+1,1} = [magname, 'BCON'];
a = a + 2;

magname = 'QUAD:LI21:278:';
pvs{a,1} = [magname, 'BDES'];
name{a} = [magname, 'BDES Not at config value'];
error_level(a) = 1; % medium severs
pvs{a+1,1} = [magname, 'BCON'];
a = a + 2;

num_magnets = (a - mag_start_a)/2;

bxg_pvnum = a;
pvs{a,1} = 'BEND:IN20:231:BACT';
name{a} = 'BXG and BXGtrim BACT values inconsistent';
a = a + 1;
pvs{a,1} = 'BTRM:IN20:231:BACT';
name{a} = '';

a = a+1;
bc2_feedback_gain_num = a; % feedback gain
pvs{a,1} =  'SIOC:SYS0:ML00:AO023';
name{a} = 'Multiple BC2 feedbacks turned on';

klys21_active_pvnum = zeros(4,1);
for j = 1:4
  a = a + 1;
  error_level(a) = 1;
  klys21_active_pvnum(j) = a;
  pvs{a,1} =  ['LI21:KLYS:', num2str(2+j), '1:SWRD'];
  name{a} = ['Station 21-', num2str(2+j), ' is deactivated'];
end

a = a + 1;
laser_steer_loop1_num = a;
pvs{a,1} = 'LASR:LR20:110:POS_FDBK';
error_level(a) = 2;
name{a} = 'Laser Steering Feedback Loop 1 not closed';

a = a + 1;
laser_steer_loop2_num = a;
pvs{a,1} = 'LASR:IN20:160:POS_FDBK';
error_level(a) = 2;
name{a} = 'Laser Steering Feedback Loop 2 not closed';

a = a + 1;
TD_11_status_num = a;
pvs{a,1} = 'DUMP:LI21:305:TD11_PNEU';
error_level(a) = 0;
name{a} = 'TD11_in';



% End of PV list

num_pvs = a;
disp(['Watcher checking ',num2str(a), ' PVs']);
error_level(num_pvs+1) = 0;
error_flag = zeros(num_pvs,1);
lcaPut([watcher_kill_pv, '.DESC'], '1 to kill watchers');


% Setup error output pvs
startpvnum = 340;
num_error_pvs = 60;
error_pvs = cell(num_error_pvs,1);
error_ref = zeros(num_error_pvs,1); % which pv each error references
en =0;
for j = 1:num_pvs % loop over all pvs
  if isempty(name{j}) % don't display this error
    continue
  elseif length(name{j}) > 32
    nm = name{j}(1:32);
  else
    nm = name{j};
  end
  en = en + 1;
  error_ref(en) = j; % relates error messages and names
  error_pvs{en,1} = setup_pv(startpvnum+en, nm, ' ', 0, 'watcher.m');
end
num_error_pvs = en;
error_disp = zeros(num_error_pvs,1); % will give output status
error_pvs = error_pvs(1:num_error_pvs,1);
for j = num_error_pvs:50;
  setup_pv(startpvnum+j, 'reserved for watcher', ' ', 0, 'watcher.m');
end


wstate = lcaGet(watcher_ref_pv);

disp('checking what watchers are active, takes 5 seconds');
pause(5); % wait for update
disp('done checking watchers');
wstate2 = lcaGet(watcher_ref_pv);
watcher_running = abs(wstate2 - wstate);
watcher_number = 0;
new_watcher = 0; % will set to 1 if this probgram becomes a new watcher
for j = 1:num_watchers
  if ~watcher_running(j)
    host = getenv('HOSTNAME');
    if isempty(host)
      host = 'unknown';
    end
    if ~new_watcher
      disp(['I am watcher ', num2str(j), '  running on  ', host]);
      lcaPut([watcher_ref_pv{j}, '.DESC'], ['watcher ', num2str(j)]);
      lcaPut(watcher_comment_pv{j}, host);
      new_watcher = 1;
      watcher_number = j;
    else
      disp(['No watcher ', num2str(j)]);
      lcaPut([watcher_ref_pv{j}, '.DESC'], ['no watcher ', num2str(j)]);
      lcaPut(watcher_comment_pv{j}, 'none');
    end
  end
end
counter = 0;
error_status = 0; % no errors
while 1 % loop forever
  pause(delay);
  counter = counter + 1;
  if watcher_number > 0
    try
      lcaPut(watcher_ref_pv{watcher_number}, counter); % incrementing counter
    catch
    end
    counter = mod(counter, counter_max); % loop over 100
    if mod(counter, nratio_1) == 0% do some checks
      wstate2 = wstate;
      try
        wstate = lcaGet(watcher_ref_pv); % collect all states
      catch
        disp('Unable to read watcher reference pvs, just increment for now');
        wstate = wstate + 10;
      end
      watcher_running = abs(sign(wstate2 - wstate));
      disp('checking watchers in loop');
      if ~watcher_running(watcher_number)
        disp('Cant increment my own counter I seem to be dead!');
      end
      if watcher_number ~=1 % look at previous watcher
        j = watcher_number -1;
        if ~watcher_running(j) %take its place if dead
          try
            lcaPut([watcher_ref_pv{watcher_number}, '.DESC'],...
              ['no watcher ', num2str(watcher_number)]);
            disp('Need to launch new watcher');
            lcaPut(watcher_comment_pv{watcher_number}, 'none');
            disp(['I am now watcher ', num2str(j), '  running on  ', host]);
            lcaPut([watcher_ref_pv{j}, '.DESC'], ['watcher ', num2str(j)]);
            lcaPut(watcher_comment_pv{j}, host);
            new_watcher = 1;
            watcher_number = j;
          catch
            disp('Unable to write watcher pvs, trying to recover');
          end
        end
      end

    end
  end
  if watcher_number == 1 % only first watcher does this
    if new_watcher % need to initialize
      new_watcher = 0;
      try
        pv_data = lcaGetSmart(pvs, 0, 'char'); % THIS IS WHERE DATA IS TAKEN
      catch
        disp('Error reading watcher pvs, trying single reads');
        for n = 1:num_pvs
          try
            pv_data{n,1} = lcaGet(pvs{n,1}, 0, 'char');
          catch
            pv_data{n,1} = 0;
            disp(['Cant do single reads on ', pvs{n,1}, '  check pv']);
          end
        end

      end
    else
      if mod(counter, nratio_1) == 1 % Now for the bulk of the program
        pv_data_last = pv_data; %copy into previous data
        try
          pv_data = lcaGetSmart(pvs, 0,'char');
        catch
            disp('FAILED TO GET PVS');
        end
        for n = 1:num_incrementors
          if (n == num_bc2feedback)
            num_bc2_feedbacks = 0;
            if strcmp(pv_data{num_bc2_efb1},'ON') % SPECIAL CASE
              error_flag(n) =0; % as long as the other fb is running
              num_bc2_feedbacks = num_bc2_feedbacks+1;
            end
            if strcmp(pv_data{num_bc2_efb2},'ON')
              error_flag(n) = 0;
              num_bc2_feedbacks = num_bc2_feedbacks+1;
            end
            if strcmp(pv_data{num_bc2_efb3},'ON')
              error_flag(n) = 0;
              num_bc2_feedbacks = num_bc2_feedbacks+1;
            end
            tmp = check_running(pv_data{n}, pv_data_last{n});
            tmp_gain = str2double(pv_data{bc2_feedback_gain_num,1});
            if (~tmp) && (num_bc2_feedbacks == 0) % this feedback not running
              if strcmp(pv_data(TD_11_status_num), 'OUT') % only if TD11 is out
                error_flag(n) = 1;
              end
            end
            if tmp && (tmp_gain > 0)
              num_bc2_feedbacks = num_bc2_feedbacks + 1;
            end
            if num_bc2_feedbacks > 1
              error_flag(bc2_feedback_gain_num) = 1;
            end
          else
            error_flag(n) = ~check_running(pv_data{n}, pv_data_last{n});
          end
          if error_flag(n)
            error_status = max(error_status, error_level(n));
          end
        end
        for m = 1:num_feedbacks
          n = m * 2 + num_incrementors -1;
          incr_ok = check_running(pv_data{n+1}, pv_data_last{n+1});
          green_ok = strcmp('ON', pv_data{n});
          if green_ok && (~incr_ok) % green, not incrementing
            error_flag(n) = 1;
            error_status = max(error_status, error_level(n));
          end
        end
        % now magnets
        for m = 1:num_magnets
          n = (m-1)*2 + mag_start_a;
          bdes = str2double(pv_data(n));
          bcon = str2double(pv_data(n+1));
          %if (bdes ~= bcon)
          if abs((bdes - bcon))/max(abs(bdes), abs(bcon)) > 2e-4
            error_flag(n) = 1;
            error_status = max(error_status, error_level(n));
          end
        end


        % Now do special devices
        n = bxg_pvnum;
        mag_ok = check_BXG(pv_data{n}, pv_data{n+1});
        if ~mag_ok
          error_flag(n) = 1;
          error_status = max(error_status, error_level(n));
        end

        for j = 1:4
          n = klys21_active_pvnum(j);
          tmp = pv_data{n};
          try
          if bitand(str2double(tmp),2^15) % klystron deactivated
            error_flag(n) = 1;
            error_status = max(error_status, error_level(n));
          end
          catch
            disp('mysterious bit error');
          end
        end
        n = laser_steer_loop1_num;
        str = pv_data{n};
        if ~strcmp(str, 'Close Loop') %bad status
          error_flag(n) = 1;
          error_status = max(error_status, error_level(n));
        end
        n = laser_steer_loop2_num;
        str = pv_data{n};
        if ~strcmp(str, 'Close Loop') %bad status
          error_flag(n) = 1;
          error_status = max(error_status, error_level(n));
        end

      end
      if mod(counter, nratio_2)==0
        ws = sum(watcher_running);
        if ws ~= num_watchers
          disp(['only ', num2str(ws), ' watchers out of ',...
            num2str(num_watchers),' running. Need to launch new watcher']);
          error_status = max(error_status, 1);
        end
      end
      if mod(counter, nratio_2) == 1 % summary display
        tstr = datestr(clock);
        disp(' ');
        disp(['watcher.m ', tstr]);
        generate_output_file(error_flag, name, watcher_file);
        generate_error_string(error_flag, name, error_string_pv);
        try
          lcaPut(error_status_pv, error_status);
          stat_mask = zeros(num_status_pvs,1);
          for k = 1:num_pvs % loop over all pvs
            if status_pvnum(k) ~= 0 % we have defined a status pv
              if error_flag(k) % we have an error
                stat_mask(status_pvnum(k)) = 0;  % red button
              else
                stat_mask(status_pvnum(k)) = 1; % Green button
              end
            end
          end
          lcaPut(s_pvs, stat_mask); % writes status pvs
          for m = 1:num_error_pvs
            error_disp(m) = error_flag(error_ref(m)); % get error status
          end
            lcaPut(error_pvs, error_disp);
        catch
          disp('caught');
        end
        error_status = 0;
        error_flag = zeros(num_pvs, 1);
      end
    end
    if mod(counter, nratio_3) == 0% check for old eDefs
        check_eDef();
    end
  else % we are some other watcher
    if mod(counter, nratio_2) == 1 % summary display
      fp = fopen(watcher_file,'r');
      if fp == -1
        disp(['Could not open watcher file for read', watcher_file]);
      else
        disp(['This is watcher ', num2str(watcher_number)]);
        while 1
          s = fgets(fp);
          if s == -1
            break;
          end
          disp(s);
        end
        fclose(fp);
      end
    end
  end
  try
    killx = lcaGet(watcher_kill_pv);
  catch
    killx = 0;
  end
  if killx
    disp(['All watchers killed by ', watcher_kill_pv]);
    lcaPut(error_status_pv, 2);
    lcaPut(s_pvs, zeros(num_status_pvs,1));
    break
  end
end

pause(1);

%clean up
disp(['No watcher ', num2str(watcher_number)]);
lcaPut([watcher_ref_pv{watcher_number}, '.DESC'],...
  ['no watcher ', num2str(watcher_number)]);
lcaPut(watcher_comment_pv{watcher_number}, 'none');
end



function running = check_running(new_string, old_string)
running = abs(sign(str2double(new_string)-str2double(old_string)));
end

function generate_output_file(error_flag, name, watcher_file)
fp = fopen(watcher_file, 'w+');
if fp == -1
  disp(['Could not open output file ', watcher_file]);
  return;
end
n = length(error_flag); % number of items
fprintf(fp, 'watcher output file %s \n', datestr(clock));
if sum(error_flag) == 0
  fprintf(fp, 'No Errors \n');
  disp('No Errors');
else
  for j = 1:n
    if error_flag(j)
      fprintf(fp, '%s \n', name{j});
      disp(name{j});
    end
  end
end
fclose(fp);
end

function generate_error_string(error_flag, name, error_string_pv)
% stz = 219 + zeros(1,200); % blank out with block characters
% try
%   lcaPut(error_string_pv, stz);
% catch
% end
% pause(1);
stx = ''; % null string
n = length(error_flag); % number of items
if sum(error_flag) == 0
  stx = [stx, 'No Errors  '];
else
  for j = 1:n
    if error_flag(j)
      stx = [stx, name{j}, ' | ']; %#ok<AGROW>
    end
  end
end
lnx = length(stx);
for j = 1:lnx
  sty = int8(stx);
  sty2 = double(sty); % yuck, ugly manipulation to make lcaput work
end
try
  lcaPut(error_string_pv, sty2);
catch
  disp('error on string write');
end
end





function mag_ok = check_BXG(bend_txt, btrim_txt)
bend = str2double(bend_txt);
btrim = str2double(btrim_txt);
btrim_min = -1.1;
btrim_max = -1;
if abs(bend) < 1e-3 % bend is off
  if (btrim < btrim_max) && (btrim > btrim_min)
    mag_ok = 1; % OK
  else
    mag_ok = 0;
  end
else  % Bend is ON
  if abs(btrim) < .02;
    mag_ok = 1;
  else
    mag_ok = 0;
  end
end
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


%function to find comment field name from pv
% Just a stupid function to save time since we do this a lot.
function out = pv_to_comment(pv)
str1 = pv(1:15);
str2 = 'SO0';
str3 = pv(18:20);
out = [str1, str2, str3];
return;
end

function check_eDef()
% Function to check for old eDefs that can be released
%  - J. Rzepiela, 11/8/10
basePV_EDEF=strcat({'EDEF:SYS0:'},num2str((1:15).','%g')).';
namePV_EDEF=strcat(basePV_EDEF,':NAME');
namesEDEF=lcaGet(namePV_EDEF(:));
namematch=[strmatch('BBA',namesEDEF);strmatch('CORRPLOT',namesEDEF);strmatch('WIRESCAN',namesEDEF)];
idx=0;
for tag=basePV_EDEF(namematch)
    idx=idx+1;
    status=lcaGet(strcat(tag,':CTRL'));
    activeTime=lcaGet(strcat(tag,':CTRLONTOD'));
    age=etime(clock,datevec(activeTime{:}));
    if strcmp(status,'OFF') && age>86400 % if off and more than 1 day old
        eDefRelease(namematch(idx));
    end
end
end