%rf_ref_feedback.m
% updated April 30, 2008, Major change - runs open loop now
%THIS IS A HORRIBLE PILE OF...er, JUNK. PLEASE REPLACE SOON. 
%WHAT IDIOT WROTE THIS ANYWAY?????/


disp('rf_ref_feedback.m updated May 2, 2008');
disp('DO NOT USE FOR NORMAL OPERATION');
tmp = 0;
tmp = input('Enter 1 if you know what you are doing and want to run anyway, otherwise enter 0');
if tmp ~= 1
  return
end


phase_measurement_pv = 'LLRF:IN20:RH:REF_1_S_PA';
amplitude_measurement_pv = 'LLRF:IN20:RH:REF_1_S_AA';
I_control_pv = 'LLRF:IN20:RH:MDL_I_ADJUST';
Q_control_pv = 'LLRF:IN20:RH:MDL_Q_ADJUST';

gain_pv = 'SIOC:SYS0:ML00:AO001';
setpoint_pv = 'SIOC:SYS0:ML00:AO002';
refpv = 'SIOC:SYS0:ML00:AO026'; % used to prevent 2 copies from running


drive_amplitude = 32000;
phase_scale_factor = 6; % MDL phase ratio. % was -6
max_phase_change = 1;
% maximum change in phase from last reading for good output
minimum_amplitude = 10000;
phase_zero = -612.6939-120.1; % offsets phase
delay =1.5; % delay time between loops


% check to be sure another copy isn't running
startnum = lcaGet(refpv);
pause(5);
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end

lcaPut([refpv, '.DESC'], 'rf_ref_feedback_run');
lcaPut([refpv, '.EGU'], ' ');
lcaPut([gain_pv, '.DESC'], 'rf_ref_gain');
lcaPut([gain_pv, '.EGU'], ' ');
lcaPut([gain_pv, '.PREC'], 3);
lcaPut([setpoint_pv, '.DESC'], 'rf_ref_setpoint');
lcaPut([setpoint_pv, '.EGU'], 'degS');


%Read initial pmdl phase

m = 0;
amplitude_last = 0;
phase_last = 0;
while 1
    try
    tmp = lcaGet({phase_measurement_pv; amplitude_measurement_pv;I_control_pv;...
        Q_control_pv; setpoint_pv; gain_pv});
    phase = tmp(1);
    amplitude = tmp(2);
    Ilast = tmp(3);
    Qlast = tmp(4);
    %tmp = lcaGet({setpoint_pv; gain_pv});
    setpoint = tmp(5);
    gain = tmp(6);
    %phase_error = phase - setpoint;
    present_phase = atan2(Ilast, Qlast)*180/pi*phase_scale_factor - phase_zero;
    
    %%%%%% NEW CLUDGE CODE
    phase = present_phase;
    %%%%%%%%
    
    catch
        pause(1);
        continue
    end
    m = m + 1;
    if m > 999  %
        m = 1;
    end
    try
    lcaPut(refpv, num2str(m));
    catch
    end
    disp(' '); % gap to make display readable
    disp('rf_ref_feedback.m');
    disp(['phase = ', num2str(phase), '  amp = ', num2str(amplitude),...
        '  setpoint = ', num2str(setpoint), '  gain = ', num2str(gain)]);
    disp(['Ilast = ', num2str(Ilast), '  Qlast = ', num2str(Qlast)]);
    bad = 0; % will set to 1 if any problems with measurement
    if amplitude == amplitude_last % not updated
        disp('old data, no feedback');
        bad = 1;
    end
    amplitude_last = amplitude;
    if abs(phase - phase_last) > max_phase_change
        disp('Phase noisy - no feedback');
        bad = 1;
    end
    phase_last = phase;
    if amplitude < minimum_amplitude
        disp('amplitude too low no feedback');
        bad = 1;
    end
    if gain <= 0
        disp(' Gain <= 0, no feedback');
        bad = 1;
    end
    % calculate error by rotating vector
    phrad = (pi/180)*phase;
    I_meas = cos(phrad);
    Q_meas = sin(phrad);
    sprad = (pi/180)*setpoint;
    I_err = I_meas * cos(sprad) + Q_meas * sin(sprad);
    Q_err= -I_meas*sin(sprad) + Q_meas * cos(sprad);
    phaseerror = (180/pi)*atan2(Q_err, I_err);
    old_drive_phase = (180/pi)*atan2(Qlast, Ilast);
    phase_change = phaseerror / phase_scale_factor * gain;
    if abs(phase_change) > max_phase_change %limit change
        phase_change = max_phase_change * sign(phase_change);
    end
    
    newphase = old_drive_phase + phase_change;
    disp(['S-phase err = ', num2str(phaseerror), '  476 phs chng = ',...
        num2str(phase_change)]);
    disp(['old drive phase = ', num2str(old_drive_phase),...
        ' new drive phase = ', num2str(newphase)]);
    drive_i = drive_amplitude * cos((pi/180)*newphase);
    drive_q = drive_amplitude * sin((pi/180)*newphase);
    if ~bad
        try
       lcaPut({I_control_pv; Q_control_pv}, [drive_i; drive_q]);
        catch
        end
    end
    pause(delay);
end
