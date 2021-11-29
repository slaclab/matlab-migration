%bc2_energy_feedback.m
disp('starting energy feedback version April 1 2008 ');
refpv = 'SIOC:SYS0:ML00:AO047';


%bpmpv = 'LI24:BPMS:801:X';
bpmpv = 'BPMS:LI24:801:X'; % updated for new bpm

gain_pv = 'SIOC:SYS0:ML00:AO023';
energy_pv = 'SIOC:SYS0:ML00:AO048';
compression_pv = 'SIOC:SYS0:ML00:AO022';
pmdl_pv = 'SIOC:SYS0:ML00:AO049';
range_pv = 'SIOC:SYS0:ML00:AO050';
pmdl_offset_pv = 'SIOC:SYS0:ML00:AO024';
pmdl_gain_pv = 'SIOC:SYS0:ML00:AO025';

station_energy = 235; % in MeV
bc2_offset = 362; % in mm;
bc2_energy = 4300; % in MeV
bc2_disp = bc2_energy / bc2_offset; % MeV/mm

delay = .1; % limits loop speed, updated from 3
bpmmax = 18; % maximum allowed reading


klys1_pv = 'ACCL:LI24:100:KLY_PDES';
klys2_pv = 'ACCL:LI24:200:KLY_PDES';

% pause(2);
% aidainit;
% pause(2);
% import java.util.Vector;
% da = DaObject();
% da.setParam('BEAM', '1');
% da.setParam('DGRP', 'LIN_KLYS');
%
%
% pmdl_phase_raw = da.get('SBST:LI24:1//PMDL',4);
phasecorrection = 0;
pmdl_phase_raw = lcaGet('LI24:SBST:1:PMDL');
lcaPut(pmdl_pv, pmdl_phase_raw);

tmp = lcaGet({klys1_pv; klys2_pv});
ph1 = tmp(1);
ph2 = tmp(2);

Estart = station_energy * (cos(pi/180 * ph1) + cos(pi/180 * ph2)); % starting energy
Bstart = station_energy * (sin(pi/180 * ph1) + sin(pi/180 * ph2)); % starting deltae

startnum = lcaGet(refpv);
pause(5);
endnum = lcaGet(refpv);
if startnum ~= endnum
    disp('Another copy of this program seems to be running, Exiting');
    return;
end
lcaPut([refpv, '.DESC'], 'bc2_energy_fb_run');
lcaPut([refpv, '.EGU'], ' ');

lcaPut([compression_pv, '.DESC'], 'BC2 compression');
lcaPut([compression_pv, '.EGU'], 'MeV');
lcaPut([compression_pv, '.PREC'], 3);

lcaPut([gain_pv, '.DESC'], 'BC2 fb gain');
lcaPut([gain_pv, '.EGU'], ' ');
lcaPut([gain_pv, '.PREC'], 3);

lcaPut([energy_pv, '.DESC'], 'BC2 fb energy');
lcaPut([energy_pv, '.EGU'], 'MeV');
lcaPut([energy_pv, '.PREC'], 3);

lcaPut([pmdl_pv, '.DESC'], 'Sec24 PMDL');
lcaPut([pmdl_pv, '.EGU'], 'deg');
lcaPut([pmdl_pv, '.PREC'], 3);

lcaPut([range_pv, '.DESC'], 'FB limit 0-1');
lcaPut([range_pv, '.EGU'], 'arb');
lcaPut([range_pv, '.PREC'], 3);

lcaPut([pmdl_offset_pv, '.DESC'], 'Sec 24 PMDL offset');
lcaPut([pmdl_offset_pv, '.EGU'], 'deg');
lcaPut([pmdl_offset_pv, '.PREC'], 3);

lcaPut([pmdl_gain_pv, '.DESC'], 'Sec 24 PMDL gain');
lcaPut([pmdl_gain_pv, '.EGU'], 'egu');
lcaPut([pmdl_gain_pv, '.PREC'], 3);




m = 0; % counter for locking loop
E = Estart;
compression = 0;
bpmlast = 0;
refcnt = 0; % reference counter
while 1
    pause(delay);
    refcnt = refcnt + 1;
    if refcnt > 1000
        refcnt = 0;
    end
    m = m + 1;
    if m > 30
        m = 1;
        try
            % pmdl_phase_raw = da.get('SBST:LI24:1//PMDL',4);
            pmdl_phase_raw = lcaGet('LI24:SBST:1:PMDL');
            disp(' ');
    disp('bc2_energy_feedback.m');
            lcaPut(pmdl_pv, pmdl_phase_raw);
            disp(['Energy = ', num2str(E), 'MV  Compression = ',...
                num2str(compression), 'MV']);
            disp(['Set klys phase  ph1 = ', num2str(phput1),...
                '  ph2 = ', num2str(phput2)]);
        catch
        end
    end
    try
        lcaPut(refpv, num2str(refcnt)); % locking loop
        tmp = lcaGet({gain_pv; compression_pv; bpmpv; pmdl_offset_pv; ...
            pmdl_gain_pv});
    catch
    end
    gain = tmp(1);
    if gain < 0 % for negative gain do not write anything
        enable = 0;
    else
        enable = 1;
    end
    gain = min(gain,1); % limit gain to 1
    gain = max(gain, 0); % zero is minimum gain
    compression = tmp(2);
    bpmnew = tmp(3);
    pmdl_offset = tmp(4);
    pmdl_gain = tmp(5);
    bad = 0;
    
    if bpmnew == bpmlast
        disp('Old bpm data');
        bad = 1;
    end
    if bpmnew == 0;
        disp('zero bpm data');
        bad = 1;
    end
    if abs(bpmnew) > bpmmax
        disp('bpm reading too large');
        bad = 1;
    end
    bpmlast = bpmnew;
    if gain == 0
        bad = 1; % control only
        tmp = LcaGet({energy_pv; compression_pv}); % read in controls
        E = tmp(1);
        compression = tmp(2);
        tmp = IQ_to_p1p2(E/station_energy,compression/station_energy);
        phput1 = tmp(1) + phasecorrection;
        phput2 = tmp(2) + phasecorrection;

        R = sqrt(E*E+compression*compression)/(2*station_energy);
        try
            if enable
                lcaPut({klys1_pv; klys2_pv; energy_pv; range_pv}, [phput1; phput2; E; R]);
            end
        catch
            disp('lcaPut ERROR - re-trying');
        end
    else
        if ~bad
            E = E + gain * bpmnew * bc2_disp;
            if abs(E) > 2 * station_energy
                E = station_energy * 2 * sign(E); % limit energh
            end
            phasecorrection = pmdl_gain * (pmdl_phase_raw - pmdl_offset);
            tmp = IQ_to_p1p2(E/station_energy,compression/station_energy);
            phput1 = tmp(1) + phasecorrection;
            phput2 = tmp(2) + phasecorrection;
            R = sqrt(E*E+compression*compression)/(2*station_energy);
            if gain ~= 0
                try
                    if enable
                        lcaPut({klys1_pv; klys2_pv; energy_pv; range_pv}, [phput1; phput2; E; R]);
                    else
                        disp('Gain is negative, feedback disabled');
                    end
                catch
                    disp('lcaPut ERROR - re-trying');
                end
            else

            end
        else
            disp('Bad bpms, do not change actuators');
            pause(1);
        end
    end
end



