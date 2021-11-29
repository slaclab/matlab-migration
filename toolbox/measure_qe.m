%measure_qe.m


laser_energy_pv = 'LASR:IN20:196:PWR'; % in microjoules
electron_charge_pv = 'BPMS:IN20:221:TMIT'; % in electrons

delay = 1; 
averages = 5;
shortpause = 0.1;

electron_charge = 1.602e-19;
laser_ratio = 1e-6*25; % Laser joules per measurement
laser_ev = 4; % ev per photon

refpv = 'SIOC:SYS0:ML00:AO943';
output_pv = 'SIOC:SYS0:ML00:AO929';

lcaPut([output_pv, '.DESC'], 'QE');
lcaPut([output_pv, '.EGU'], 'ppb');
lcaPut([output_pv, '.PREC'], 0);


% check to be sure another copy isn't running
startnum = lcaGet(refpv);
pause(5);
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end

lcaPut([refpv, '.DESC'], 'measure_qe_running');
lcaPut ([refpv, '.EGU'], ' ');

pvs{1,1} = laser_energy_pv;
pvs{2,1} = electron_charge_pv;
j = 0;
while 1
    j = j + 1;
    if j > 999
        j = 1;
    end
    lcaPut(refpv, num2str(j));
    pause(delay);
    charge_sum = 0;
    energy_sum = 0;
    en = 0;
    ch = 0;
    for k = 1:averages
      dat = lcaGet(pvs);
      pause(shortpause);
      energy_sum = energy_sum + dat(1);
      charge_sum = charge_sum + dat(2); 
    end
    energy_joules = energy_sum * laser_ratio / averages;
    charge_electrons = charge_sum / averages;
    energy_photons = energy_joules / (laser_ev * electron_charge);
    qe = charge_electrons / energy_photons;
    lcaPut([output_pv, '.VAL'], qe * 1e9);
    pause(1);
end




