%get_energy.m version 6/9/10v3.0 new calculation for limits
% function reads klystron phases, and enoloads, and trigger status to get



function out = get_energy()
BSY_energy_factor = 1000/.5794666;
BC2_energy_factor = 4300 * 361.6275 / 4.98009; % energy * position / field
persistent initialized
persistent P %Pv structure,
if isempty(initialized)
    P = generate_names();
    initialized = 1;
end
% now get the data;
dat = lcaGetSmart(P.pvs);
sbstpdes = zeros(30,1);
for sector = 20:30
    sbstpdes(sector) = dat(P.map.sbstpdes(sector));
end
S27_fbck_phase = dat(P.map.S27_fbck_phas); % FB31 feedback sectors
S28_fbck_phase = dat(P.map.S28_fbck_phas);
egain = zeros(30,8); % energy gain, no phase
phase = zeros(30,8);
out.klystrons.act = zeros(30,8);
for sector = 20:30
    for station = 1:8
        if (sector == 20) && (station == 1) % special BUG
            continue
        end
        out.klystrons.pdes(sector,station) = dat(P.map.pdes(sector,station));
        out.klystrons.gold(sector,station) = dat(P.map.gold(sector,station));
        out.klystrons.kphr(sector,station) = dat(P.map.kphr(sector,station));
        out.klystrons.phas(sector,station) = dat(P.map.phas(sector,station));
        out.klystrons.enld(sector,station) = dat(P.map.enld(sector,station));
    end
end
out.klystrons.enld(20,6) = 6;
out.klystrons.enld(20,7) = 57.5;
out.klystrons.enld(20,8) = 71.5;
out.klystrons.enld(21,1) = 133.8;
out.klystrons.enld(21,2) = -18.8;
out.klystrons.pdes(21,1:2) = 0;
for sector = 20:30
    for station = 1:8
        if (sector == 20) && (station == 1)
            continue;
        end
        klysname = ['KLYS:LI', num2str(sector),':', num2str(station),'1//TACT'];
        try
            out.klystrons.act(sector,station) = aidaget(klysname, 'short', {'BEAM=1' 'DGRP=LIN_KLYS'});
        catch
            disp('aidaget error');
        end
        hsta = dat(P.map.hsta(sector, station));
        stat = dat(P.map.stat(sector, station));
        swrd = dat(P.map.swrd(sector,station));
        act = out.klystrons.act(sector,station);
        egain(sector, station) = station_gain(out.klystrons.enld(sector, station), hsta, stat, swrd, act);
        % % % gain, without phas

        if ~isfinite(out.klystrons.pdes(sector,station)) || ~isfinite(sbstpdes(sector))
            phase(sector,station) = 0; % what else to do if invalid
        else
            phase(sector,station) = out.klystrons.pdes(sector,station) + sbstpdes(sector); % for normal stations
        end
    end
end
out.egain = egain;
% OK, now all the ugly special case rules

for station = 1:8
    sector = 27;
    phase(sector, station) = phase(sector, station) + S27_fbck_phase;
    sector = 28;
    phase(sector, station) = phase(sector,  station) + S28_fbck_phase;
end
sector =24;
for station = 1:3
    phase(sector, station) = dat(P.map.S24_fb_phase(station)); % just set these
end

egain(24, 8) = 0; % Special case for tcav
% end special rules
%machine end energies
if (dat(P.map.BC2_position) < 10) || (dat(P.map.BC2_magnet_bdes) < 1) % BC2 straight?
    out.beam_energy_bc2 = 4300;
else
    out.beam_energy_bc2 = dat(P.map.BC2_magnet_bdes) / dat(P.map.BC2_position) * BC2_energy_factor;
end
% Commented H. Loos 9/21/2015 as 50B1 disconnected
%out.beam_energy_PR55 = dat(P.map.BSY_magnet_bdes) * BSY_energy_factor;
out.beam_energy_PR55 = 0;
out.beam_energy_LTU = dat(P.map.DL2_magnet) * 1000; % already calibrated
out.beam_energy_bsy = max(out.beam_energy_PR55, out.beam_energy_LTU);
out.beam_energy_bsy = max(out.beam_energy_bsy, out.beam_energy_bc2); % limit to prevent silly answers
stat_I = egain .* cos(pi/180*phase);
stat_Q = egain .* sin(pi/180*phase);
L0_energy = sum(egain(20,5:8));
L1_energy = sum(egain(21,1:2));
out.L2_energy = sum(stat_I(21,3:8))+sum(sum(stat_I(22:24,:))); %Energy gain in L2 with station phases
out.L3_energy = sum(sum(stat_I(25:30,:))); % Energy gain in L3
out.L2_chirp = sum(stat_Q(21,3:8)) + sum(sum(stat_Q(22:24, :))); % energy chirp in L2
out.L3_chirp = sum(sum(stat_Q(25:30, :)));
out.L2_effective_phase = 180/pi*atan2(out.L2_chirp, out.L2_energy); % includes station phases
out.L3_effective_phase = 180/pi*atan2(out.L3_chirp, out.L3_energy); % includes station phases
out.BC2_energy = out.L2_energy + L0_energy + L1_energy; % energy from klystrons
out.final_energy = out.BC2_energy + out.L3_energy;
out.L2_fudge = (out.beam_energy_bc2 - L0_energy - L1_energy)/ out.L2_energy;
out.L3_fudge = (out.beam_energy_bsy - out.beam_energy_bc2) / out.L3_energy;
out.L2_nofb_energy = out.L2_energy - sum(stat_I(24,1:3));
out.L3_nofb_energy = sum(sum(stat_I(25:28,:)));
out.L2_nofb_chirp =  sum(stat_Q(21,3:8))+  sum(sum(stat_Q(22:23,:)))+sum(stat_Q(24,4:8));
out.L3_nofb_chirp = sum(sum(stat_Q(25:28,:)));
out.L2_total_energy = sqrt(out.L2_energy^2 + out.L2_chirp^2);
out.L3_total_energy = sqrt(out.L3_energy^2 + out.L3_chirp^2);
out.L2_nofb_flat_energy = (sum(egain(21,3:8)) + sum(sum(egain(22:23,:))) + sum(egain(24,4:8))) * cos(pi/180*dat(P.map.L2_phase));
out.L3_nofb_flat_energy = sum(sum(egain(25:28,:))) * cos(pi/180*dat(P.map.L3_phase));
out.L2_nofb_flat_chirp =  (sum(egain(21,3:8)) + sum(sum(egain(22:23,:))) + sum(egain(24,4:8)))* sin(pi/180*dat(P.map.L2_phase));
out.L3_nofb_flat_chirp =  sum(sum(egain(25:28,:))) * cos(pi/180*dat(P.map.L3_phase));


out.fb_energy = sum(egain(24,1:3)'.*cos(pi/180*dat(P.map.S24_fb_phase(1:3))));
out.L3fb_energy = sum(egain(29,:)) * cos(pi/180*dat(P.map.S29_phase)) + sum(egain(30,:))*cos(pi/180*dat(P.map.S30_phase));
out.fb_chirp =  sum(egain(24,1:3)'.*sin(pi/180*dat(P.map.S24_fb_phase(1:3))));
out.L3fb_chirp = sum(egain(29,:))*sin(pi/180*dat(P.map.S29_phase)) + sum(egain(30,:))*sin(pi/180*dat(P.map.S30_phase));


out.L2_flat_energy = out.L2_nofb_flat_energy + out.fb_energy;
out.L3_flat_energy = out.L3_nofb_flat_energy + out.L3fb_energy;
out.L2_flat_chirp = out.L2_nofb_flat_chirp + out.fb_chirp;
out.L3_flat_chirp = out.L3_nofb_flat_chirp + out.L3fb_chirp;
out.L2_flat_fudge = (out.beam_energy_bc2-L0_energy - L1_energy) / out.L2_flat_energy;
out.L3_flat_fudge = (out.beam_energy_bsy - out.beam_energy_bc2) / out.L3_flat_energy;
%out.L2_nofb_flat_total_energy = sum(sum(egain(21:23,:))) + sum(egain(24,4:8));
out.L2_nofb_flat_total_energy = sum(sum(egain(22:23,:))) + sum(egain(24,4:8))+ sum(egain(21,3:8));
out.L3_nofb_flat_total_energy = sum(sum(egain(25:28,:)));

% KLUDGE
%out.L2_nofb_flat_total_energy = 4838.0;
%out.L3_nofb_flat_total_energy = 6218.0;


out.L2_nofb_total_energy = sum(sum(stat_I(21:24,:)));
out.L3_nofb_total_energy = sum(sum(stat_I(25:28,:))); % includes phases
out.S29_flat_energy = max(sum(egain(29,:)), 10); % limit to prevent div zero
out.S30_flat_energy = max(sum(egain(30,:)), 10);

%KLUDGE
%out.S29_flat_energy = 1970;
%out.S30_flat_energy = 1970;


out.energy = zeros(30,8); % setup initial energy
out.station_on = zeros(30,8); % which stations are on
for sector = 20:30
    for station = 1:8
        if egain(sector,station) ~= 0
            out.station_on(sector,station) = 1;
        end
    end
end
out.num_klystrons.L2 = sum(sum(out.station_on(21:24,:)));
out.num_klystrons.L3 = sum(sum(out.station_on(25:30,:)));
for sector = 20:30
    if sector < 25
        fudge = out.L2_fudge;
    else
      fudge = out.L3_fudge;
    end
    out.energy(sector,1) = out.energy(sector-1,8)+stat_I(sector,1) *fudge;
    for station = 2:8
      out.energy(sector,station) = out.energy(sector,station-1) + stat_I(sector,station) * fudge;
    end
end
% Now calculate feedback percentages
out.L2_feedback_strength  = cos((pi/360)*(dat(P.map.S24_fb_phase(1)) - dat(P.map.S24_fb_phase(2))));

for jx = 1:3
  if out.egain(24,jx) > 1
    eg(jx) = cos((pi/180)*(dat(P.map.S24_fb_phase(jx)) - dat(P.map.L2_phase)));
    efull(jx) = 1;
  else
    eg(jx) = 0; % station not on
    efull(jx) = 0;
  end
end
if sum(efull) == 0
  out.L2_feedback_strength = 1; % no tubes, saturated
else
  out.L2_feedback_strength = sum(eg) / sum(efull);
end

out.L3_feedback_strength = cos((pi/360)*(dat(P.map.S29_phase) - dat(P.map.S30_phase)));

end

function out = generate_names()
usenewPVs=1;
if usenewPVs
    [name, is, PACT, PDES]=control_phaseNames({'L2' 'L3'});
    L2_phase_control_pv = PDES{1};
    L3_phase_control_pv = PDES{2};
else
    L2_phase_control_pv = 'SIOC:SYS0:ML00:AO061';
    L3_phase_control_pv = 'SIOC:SYS0:ML00:AO064';
end

S29_phase_control_pv = 'ACCL:LI29:0:KLY_PDES';
S30_phase_control_pv = 'ACCL:LI30:0:KLY_PDES';
pvs = cell(30*8+7,1); % create cell array
map = struct;
map.enld = zeros(30,8);
map.hsta = zeros(30,8);
map.stat = zeros(30,8);
map.swrd = zeros(30,8);
map.pdes = zeros(30,8);
pvnum = 0;
for sector = 20:30 % generate pv names
    for station = 1:8
        if (sector == 20) && (station == 1)
            continue
        end
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:ENLD'];
        map.enld(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:HSTA'];
        map.hsta(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:STAT'];
        map.stat(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:SWRD'];
        map.swrd(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:PDES'];
        map.pdes(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:GOLD'];
        map.gold(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:KPHR'];
        map.kphr(sector,station) = pvnum;
        pvnum = pvnum+1;
        pvs{pvnum} = ['LI', num2str(sector), ':KLYS:', num2str(station),'1:PHAS'];
        map.phas(sector,station) = pvnum;
    end
    pvnum = pvnum+1;
    pvs{pvnum} = ['LI', num2str(sector), ':SBST:1:PDES'];
    map.sbstpdes(sector) = pvnum;
    pvnum = pvnum+1;
    pvs{pvnum} = ['LI', num2str(sector), ':SBST:1:GOLD'];
    map.sbstgold(sector) = pvnum;
    pvnum = pvnum+1;
    pvs{pvnum} = ['LI', num2str(sector), ':SBST:1:KPHR'];
    map.sbstkphr(sector) = pvnum;
    pvnum = pvnum+1;
    pvs{pvnum} = ['LI', num2str(sector), ':SBST:1:PHAS'];
    map.sbstphas(sector) = pvnum;
end
pvnum = pvnum + 1;
pvs{pvnum} = L2_phase_control_pv;
map.L2_phase = pvnum;
pvnum = pvnum + 1;
pvs{pvnum} = L3_phase_control_pv;
map.L3_phase = pvnum;
for j = 1:3 % L2 feedback klystrons
    pvnum = pvnum + 1;
    pvs{pvnum} = ['ACCL:LI24:', num2str(j), '00:KLY_PDES'];
    map.S24_fb_phase(j) = pvnum;
end
pvnum = pvnum + 1;
pvs{pvnum} = S29_phase_control_pv;
map.S29_phase = pvnum;
pvnum = pvnum + 1;
pvs{pvnum} = S30_phase_control_pv;
map.S30_phase = pvnum;
pvnum = pvnum+1;
pvs{pvnum} = 'FB31:PHAS:271:VACT'; % fast phase shifter for s 27
map.S27_fbck_phas = pvnum;
pvnum = pvnum+1;
pvs{pvnum} = 'FB31:PHAS:281:VACT'; % fast phase shifter for s 27
map.S28_fbck_phas = pvnum;
out.pvs =  cell(pvnum,1);
pvnum = pvnum+ 1;
pvs{pvnum} = 'BEND:LI24:790:BDES';
map.BC2_magnet_bdes = pvnum;
pvnum = pvnum + 1;
pvs{pvnum} = 'BMLN:LI24:805:MOTR.VAL';
map.BC2_position = pvnum;
pvnum = pvnum + 1;
pvs{pvnum} = 'BEND:LTU1:220:BDES';
map.DL2_magnet = pvnum;
for j = 1:pvnum
    out.pvs{j,1} = pvs{j};
end
out.map = map;
end

% Calculate energy gain of each station
function egain = station_gain(enld, hsta, stat, swrd, act)
if ~isfinite(enld) || ~isfinite(hsta) || ~isfinite(stat) || ~isfinite(swrd)
    egain = 0;  % Assume zero gain if we can't read something
    return
end
overall_ok = 1;
online  = bitand(hsta, 1); % station online
overall_ok = overall_ok && online;
nomaint = ~bitand(stat, 2); % not maintinence mode
overall_ok = overall_ok && nomaint;
mod_ok = ~bitand(swrd, 8);
overall_ok = overall_ok && mod_ok;
cable_ok = ~bitand(swrd,1);
overall_ok = overall_ok && cable_ok;
mksu_notprotect =  ~bitand(swrd,2);
overall_ok = overall_ok && mksu_notprotect;
%acc_rate = ~bitand(swrd,32768);
acc_rate = bitget(act,1);
overall_ok = overall_ok && acc_rate;
not_bad_camac = ~bitand(swrd, 16);
overall_ok = overall_ok && not_bad_camac;
good = overall_ok;
if ~good
    egain = 0; % not on beam;
else
    egain = enld;
end
end
