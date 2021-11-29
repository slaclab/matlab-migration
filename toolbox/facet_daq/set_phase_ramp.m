function set_phase_ramp(phase)

try
    SET_VDES('PHAS','DR12',61,phase,'TRIM');
catch
    display('Unable to set phase ramp');
end

disp('Current phase ramp readback (DR12:PHAS:61:VACT)');
lcaGet('DR12:PHAS:61:VACT')
