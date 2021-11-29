%lfbk.m


%  longitudinal feedback

delay = .25;
gain_energy = 1;
gain_bl = 0.2;

min_tmit = 5e8;


min_L0B = 60;
max_L0B = 75;
min_L1S = 80;
max_L1S = 160;
%initialize variables
phpred = 0;
phsig = 0;
ph_pred = 0;

%P = [2.3670, 37.4838];
P = [2.4618, 37.8953];
%siglimit = 0.25; CL Jun2907
siglimit = 2;
tmit_set = 2e9;

bl_setpoint_pv = 'SIOC:SYS0:ML00:AO919';
lcaPut([bl_setpoint_pv, '.DESC'], 'lfbk Phase offset setpoint');

overall_gain_pv = 'SIOC:SYS0:ML00:AO920';
lcaPut([overall_gain_pv, '.DESC'], 'lfbk feedback gain');
lcaPut([overall_gain_pv, '.PREC'], 3);

offset_pv = 'SIOC:SYS0:ML00:AO945';
lcaPut([offset_pv, '.DESC'], 'lfbk bpm offset');
lcaPut([offset_pv, '.PREC'], 3);
lcaPut([offset_pv, '.EGU'], 'mm');


refpv = 'SIOC:SYS0:ML00:AO939';
startnum = lcaGet(refpv);
disp('starting - please wait');
pause(10); %
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end


disp('running');
lcaPut([refpv, '.DESC'], 'lfbk_running');
lcaPut ([refpv, '.EGU'], ' ');
lcaPut([refpv, '.PREC'], 0);

DL1_energy_pv = 'BPMS:IN20:731:X';
BC1_energy_pv = 'BPMS:LI21:233:X';
SPEC_energy_pv = 'BPMS:IN20:945:X';  

L0B_amp_pv = 'ACCL:IN20:400:L0B_ADES';
L1S_amp_pv = 'ACCL:LI21:1:L1S_ADES';
L1S_phase_pv = 'ACCL:LI21:1:L1S_PDES';

bl1_pv = 'BLEN:LI21:280:BL12C_S_SUM';
bl2_pv = 'BLEN:LI21:280:BL12D_S_SUM';
tmit_pv = 'BPMS:LI21:278:TMIT';
tmit_s_pv = 'BPMS:IN20:945:TMIT'; % spectrometer tmit

dl1_dispersion = -263;
bc1_dispersion = -128;
spec_dispersion = -200; % GUESS

dl1_e0 = 135;
bc1_e0 = 250;
spec_e0 = 135;

dl1_ecalib = dl1_e0/dl1_dispersion; % mev/mm
bc1_ecalib = bc1_e0/bc1_dispersion;
spec_ecalib = spec_e0 / spec_dispersion;

timeout = 10;
samples = 1;
averages = 10;
% Define e-def
eDefNumber = eDefReserve('lfbk');
eDefParams(eDefNumber, averages, samples,...
    {''}, {''}, {''}, {''});

j = 0;
while 1
    j = j + 1;
    if j > 999
        j = 1;
    end
    overall_gain = lcaGet(overall_gain_pv);
    overall_gain = max(0, overall_gain); %limit to >=0
    bpm_offset = lcaGet(offset_pv); % get offset value
    lcaPut(refpv, num2str(j));
    bl_sp = lcaGet(bl_setpoint_pv); % phase set point
    result.acqTime = eDefAcq(eDefNumber, timeout);
    tmp = lcaGet({[DL1_energy_pv, num2str(eDefNumber)];...
        [BC1_energy_pv, num2str(eDefNumber)]; L0B_amp_pv; L1S_amp_pv;...
        bl1_pv; bl2_pv; [tmit_pv, num2str(eDefNumber)]; [tmit_s_pv, num2str(eDefNumber)];...
        [SPEC_energy_pv, num2str(eDefNumber)]});
    dl1_energy = tmp(1)*dl1_ecalib;
    bc1_energy = (tmp(2)-bpm_offset)*bc1_ecalib;

    L0B_e = tmp(3);
    L1S_e = tmp(4);

    L0B_new = L0B_e - dl1_energy * gain_energy * overall_gain;
    L1S_new = L1S_e + (L1S_e/(bc1_e0-dl1_e0))*(dl1_energy - bc1_energy)*gain_energy *...
        overall_gain;

    disp(['DL1 = ', num2str(dl1_energy), ' BC1 = ', num2str(bc1_energy),...
        ' L0B ', num2str(L0B_e), ' > ' num2str(L0B_new), '  L1S ', num2str(L1S_e), ...
        ' > ', num2str(L1S_new)]);
    blm_90 = tmp(5);
    blm_300 = tmp(6);
    tmit = tmp(7);
    spec_e = tmp(9);
    spec_tmit = tmp(8);
    if spec_tmit > tmit
        if spec_tmit > min_tmit % use spectrometer
            spec_energy = spec_e * spec_ecalib;
            L0B_new = L0B_e - spec_energy * gain_energy * overall_gain;
            disp(['spec mode, L0B ', num2str(L0B_e), ' -> ' , num2str(L0B_new)]);
            L0B_new = min(max(L0B_new, min_L0B), max_L0B);
            lcaPut(L0B_amp_pv, L0B_new);
        else
            disp('tmit too low');
            L0B_new = L0B_e;
            tmit_bad = 1;
        end
    else
        tmit_err = (tmit - tmit_set) / tmit_set;
        if tmit_err < 0.3
            phsig = -log((blm_90.*blm_300/1e15)./((tmit/1e9).^4))^2;
            phpred = polyval(P, phsig);

            ph_err = phpred - bl_sp; % error
            tmit_bad = 0;
            if (phpred > 35) || (phpred < -10)
                disp('phase out of range');
                ph_err = 0;
            end
        else
            ph_err = 0;
            disp('tmit too low');
            tmit_bad = 1;
        end
        L0B_new = min(max(L0B_new, min_L0B), max_L0B);
        L1S_new = min(max(L1S_new, min_L1S), max_L1S);
        ph_old = lcaGet(L1S_phase_pv);
        ph_new = ph_old - ph_err * gain_bl * overall_gain;
        if bl_sp <= 0
            ph_new = ph_old;
            disp('phase setpoint <zero, do not change phase');
        end
        if tmit > min_tmit
            disp(['calculated_phase = ', num2str(phpred), '  setting phase ', num2str(ph_new)]);
            lcaPut({L0B_amp_pv; L1S_amp_pv; L1S_phase_pv}, [L0B_new; L1S_new; ph_new]);
        else
            disp(['tmit too low', num2str(tmit)]);
        end
    end
    pause(delay);
    rsig(j) = phsig;
    rph(j) =  phpred;
end

eDefRelease(eDefNumber);
