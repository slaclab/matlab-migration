function set_phase_ramp_tcav(phase)

curr_phase_ramp = lcaGet('DR12:PHAS:61:VACT');

% delta_phase = phase - curr_phase_ramp;

try
    SET_VDES('PHAS','DR12',61,phase,'TRIM');
catch
    display('Unable to set phase ramp');
end

disp('Current phase ramp readback (DR12:PHAS:61:VACT)');
lcaGet('DR12:PHAS:61:VACT')
new_phase_ramp = lcaGet('DR12:PHAS:61:VACT');

delta_phase = new_phase_ramp - curr_phase_ramp;

curr_tcav_phase = lcaGet('TCAV:LI20:2400:0:POC');
lcaPut('TCAV:LI20:2400:0:POC',curr_tcav_phase-4*delta_phase);

disp('Current TCAV phase off (TCAV:LI20:2400:0:POC)');
lcaGet('TCAV:LI20:2400:0:POC');

