function set_phase_ramp_positron(phase)

try
    SET_VDES('PHAS','DR02',62,phase,'TRIM');
catch
    display('Unable to set phase ramp');
end

disp('Current phase ramp readback for positron (DR02:PHAS:62:VACT)');
lcaGet('DR02:PHAS:62:VACT')
