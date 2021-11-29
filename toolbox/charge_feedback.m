%charge_feedback.m
% 


refpv = 'SIOC:SYS0:ML00:AO944'; %used to check if loop is running
output_pv = 'SIOC:SYS0:ML00:AO915'; % Laser power control
charge_set_pv = 'SIOC:SYS0:ML00:AO918'; %Charge set point
laser_set_pv = 'SIOC:SYS0:ML00:AO917';
laser_energy_pv_base= 'LASR:IN20:196:PWR'; % in microjoules
laser_energy_pv = laser_energy_pv_base;
charge_pv_base = 'BPMS:IN20:221:TMIT'; % used for charge measurment
laser_phase_pv = 'SIOC:SYS0:ML00:AO901'; % phase control
charge_display_pv = 'SIOC:SYS0:ML00:AO925';

gain = .3;
charge_gain = 10; % degrees for full scale.

mine = .3;
maxe = 20;
minq = .02;
maxq = 10;



lcaPut([laser_set_pv, '.DESC'], 'Laser Energy');
lcaPut([laser_set_pv, '.EGU'], 'uJ');
lcaPut([laser_set_pv, '.PREC'], 3);

lcaPut([charge_set_pv, '.DESC'], 'Charge Setpoint');
lcaPut([charge_set_pv, '.EGU', ], '1e9');
lcaPut([charge_set_pv, '.PREC'],3);

lcaPut([charge_display_pv, '.DESC'], 'Charge');
lcaPut([charge_display_pv, '.EGU', ], 'nC');
lcaPut([charge_display_pv, '.PREC'],3);

delay = 15;
averages = 1;
samples = 30;
timeout = 30;

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
    disp('start delay');
    pause(delay);
    disp('end delay');
    qsp = lcaGet(laser_set_pv); % energy set point
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
        lcaPut(charge_display_pv, charge_e9*1e18*1.602e-19);
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
    if charge_good && laser_good
        if charge_sp > 0
            charge_er = (charge_e9 - charge_sp)/charge_sp;
            new_output = last_output*(1 - charge_er * gain);
            new_output = max(min(new_output,100),2); % limit output
            lcaPut(output_pv, new_output);
            if new_output < 20
                pause(1); % kluge for slow waveplate
            end
            lcaPut(laser_set_pv, energy_uj);
            disp(['energy = ', num2str(energy_uj), '  last_output = ',...
                num2str(last_output), ...
                '  new_output = ', num2str(new_output)]);
        end
    end

end
