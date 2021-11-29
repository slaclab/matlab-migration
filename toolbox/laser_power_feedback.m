%laser_power_feedback
% sets laser power by reading the laser power meter
% controls the input to the laser power set matlab function


refpv = 'SIOC:SYS0:ML00:AO944'; %used to check if loop is running
output_pv = 'SIOC:SYS0:ML00:AO915'; % Laser power control
control_pv = 'SIOC:SYS0:ML00:AO917'; %Laser energy set point
charge_set_pv = 'SIOC:SYS0:ML00:AO918'; %Charge set point
laser_energy_pv_base= 'LASR:IN20:196:PWR'; % in microjoules
laser_energy_pv = laser_energy_pv_base;
charge_pv_base = 'BPMS:IN20:221:TMIT'; % used for charge measurement
laser_phase_pv = 'SIOC:SYS0:ML00:AO901'; % phase control


gain = .25;
charge_gain = 10; % degrees for full scale.

mine = 1;
maxe = 20;
minq = .1;
maxq = 5;



lcaPut([control_pv, '.DESC'], 'Laser Energy');
lcaPut([control_pv, '.EGU'], 'uJ');
lcaPut([control_pv, '.PREC'], 2);

lcaPut([charge_set_pv, '.DESC'], 'Charge Setpoint');
lcaPut([charge_set_pv, '.EGU', ], '1e9');
lcaPut([charge_set_pv, '.PREC'],2);


delay = 1;
averages = 1;
samples = 10;
timeout = 20;

% check to be sure another copy isn't running
startnum = lcaGet(refpv);
disp('starting - please wait');
pause(10); %
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end


disp('running');
lcaPut([refpv, '.DESC'], 'laser_power_feeback_running');
lcaPut ([refpv, '.EGU'], ' ');


pvs{1,1} = laser_energy_pv;

% Define e-def
eDefNumber = eDefReserve('laser_power_feedback');
eDefParams(eDefNumber, averages   , samples,...
    {''}, {''}, {''}, {''});

laser_energy_pv = [laser_energy_pv_base, 'HST',num2str(eDefNumber)];
charge_pv = [charge_pv_base, 'HST', num2str(eDefNumber)];

last_charge_sp = 0; % initialize

j = 1;
while 1
    j = j + 1;
    if j > 999
        j = 1;
    end
    lcaPut(refpv, num2str(j));
    pause(delay);
    qsp = lcaGet(control_pv); % energy set point
    charge_sp = lcaGet(charge_set_pv);
    last_phase = lcaGet(laser_phase_pv);
    last_output = lcaGet(output_pv);
    if qsp < 0 % exit on negative energy set point
        break;
    end
    energy_uj = 0;
    charge_e9 = 0;
    bad = 0;
    result.acqTime = eDefAcq(eDefNumber, timeout);
    dat = lcaGet({laser_energy_pv; charge_pv});
    lcnt = 0;
    ccnt = 0;
    for k = 1:samples
        en = dat(1,k);
        ch = dat(2,k)/1e9;
        if (en > mine) && ( en < maxe) % good energy reading
            energy_uj = energy_uj + en;
            lcnt = lcnt + 1;
        end
        if (ch > minq) && ( ch < maxq) % good charge reading
            charge_e9 = charge_e9 + ch;
            ccnt = ccnt + 1;
        end
    end
    if lcnt > 0
        energy_uj = energy_uj / lcnt;
        laser_good = 1;
    else
        energy_uj = 0;
        laser_good = 0;
    end
    if ccnt > 0
        charge_e9 = charge_e9/ ccnt;
        charge_good = 1;
    else
        charge_e9 = 0;
        charge_good = 0;
    end
    disp([' energy = ', num2str(energy_uj), '  charge = ',...
        num2str(charge_e9), '  good_samples_p = ', num2str(lcnt), ...
        '  good_samples_q = ', num2str(ccnt)]);
    if bad
        disp('bad readings');
        continue;
    end
    er = (energy_uj-qsp) / qsp;
    charge_er = (charge_e9 - charge_sp)/charge_sp;
    if ~laser_good % error too large
        disp('bad laser signal');
        continue;
    else
        new_output = last_output - gain * er * 100;
        if qsp == 0 % disable
            disp('energy setpoint =0, no feedback');
            continue
        end
        if new_output > 100
            new_output = 100;
        elseif new_output < 5
            new_output = 5;
        else % laser power is OK
            if charge_sp == -1
                lcaPut(charge_set_pv, last_charge_sp);
                disp(['setting charge to ', num2str(last_charge_sp)]);
            elseif (charge_sp ~= 0) && charge_good
                new_phase = last_phase + charge_er * charge_gain;
                disp(['setting phase ', num2str(last_phase), ' to ', num2str(new_phase)]);
                lcaPut(laser_phase_pv, new_phase);
                last_charge_sp = charge_sp;
            else
                disp('charge bad');
            end
        end
        disp(['energy = ', num2str(energy_uj), '  last_output = ',...
            num2str(last_output), '  err = ', num2str(er), ...
            '  new_output = ', num2str(new_output)]);
        lcaPut(output_pv, new_output);
    end
end
eDefRelease(eDefNumber);

