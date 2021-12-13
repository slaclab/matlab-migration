
function state = asset_getMachine(nsamp)

if nargin < 1, nsamp = 1; end

persistent klys;
persistent sbst;
persistent wire;

persistent emags;
persistent pmags;
persistent ebpms;
persistent pbpms;
persistent etoro;
persistent ptoro;

% add timestamp
state.timestamp.start = now;

if isempty(emags)
    % enumerate electron magnets
    disp('Building e- magnet list...');
    [dr13mags.name, dr13mags.Z] = get_by_z13({'XCOR' 'YCOR'});
    [li02mags.name, li02mags.Z] = get_by_z({'XCOR' 'YCOR'});
%     [dr13mags.name, dr13mags.z] = get_by_z13({'BEND' 'BTRM' 'BNDS' 'KICK' 'QUAD' 'QTRM' 'QUAS' 'XCOR' 'YCOR' 'SEXT' 'SXTS'});
%     [li02mags.name, li02mags.Z] = get_by_z({'BEND' 'BTRM' 'BNDS' 'KICK' 'QUAD' 'QTRM' 'QUAS' 'XCOR' 'YCOR' 'SEXT' 'SXTS'});
    emags.name = [dr13mags.name; li02mags.name];
    emags.Z = [dr13mags.Z; li02mags.Z];
    emags.LEFF = control_deviceGet(emags.name, 'LEFF');
end

if isempty(pmags)
    % enumerate positron magnets
    disp('Building e+ magnet list...');
    dr03mags.name = {...
        'YCOR:DR03:35';...
        'XCOR:DR03:61';...
        'YCOR:DR03:75';...
        'XCOR:DR03:81';...
        'XCOR:DR03:145';...
        'XCOR:DR03:151';...
        'YCOR:DR03:161';...
        'XCOR:DR03:165';...
        'XCOR:DR03:191';...
        'XCOR:DR03:201';...
        'YCOR:DR03:211';...
        'XCOR:DR03:205';...
        'YCOR:DR03:235';...
        'XCOR:DR03:251';...
        'XCOR:DR03:281';...
        'YCOR:DR03:285';...
        'XCOR:DR03:325';...
        'YCOR:DR03:331';...
        'XCOR:DR03:355';...
        'YCOR:DR03:351';...
        'XCOR:DR03:581';...
        'XCOR:DR03:411';...
        'YCOR:DR03:415';...
        'XCOR:DR03:441';...
        'YCOR:DR03:445';...
        'YCOR:DR03:465';...
        'XCOR:DR03:471';...
        'YCOR:DR03:491';...
        'XCOR:DR03:511';...
        'YCOR:DR03:551';...
        'XCOR:DR03:521';...
        'YCOR:DR03:571';...
        'XCOR:DR03:641';...
        'XCOR:DR03:681';...
        'XCOR:DR03:711';...
        'YCOR:DR03:721';...
        'XCOR:DR03:755';...
        'YCOR:DR03:791';...
        'XCOR:DR03:811';...
        'YCOR:DR03:821';...
        'XCOR:DR03:851';...
        'YCOR:DR03:871';...
        'XCOR:DR03:951';};
    [li02mags.name, li02mags.Z] = get_by_z({'XCOR' 'YCOR'});
    pmags.name = [dr03mags.name; li02mags.name];
    [p,m,u] = model_nameSplit(pmags.name);
    pmags.Z = control_deviceGet(strcat(m,':',p,':',u), 'Z');
    pmags.LEFF = control_deviceGet(strcat(m,':',p,':',u), 'LEFF');
end

if isempty(ebpms)
    % enumerate e- bpms
    disp('Building e- BPM list...');
    ebpms.name = model_nameRegion('BPMS', {'DR13' 'LI02'});
    ebpms.Z = control_deviceGet(ebpms.name, 'Z');
end

if isempty(pbpms)
    disp('Building e+ BPM list...');
    dr03BPMS = {...
    'BPMS:DR03:51'
    'BPMS:DR03:95'
    'BPMS:DR03:115'
    'BPMS:DR03:125'
    'BPMS:DR03:155'
    'BPMS:DR03:165'
    'BPMS:DR03:225'
    'BPMS:DR03:245'
    'BPMS:DR03:275'
    'BPMS:DR03:315'
    'BPMS:DR03:345'
    'BPMS:DR03:385'
    'BPMS:DR03:405'
    'BPMS:DR03:435'
    'BPMS:DR03:465'
    'BPMS:DR03:545'
    'BPMS:DR03:601'
    'BPMS:DR03:665'
    'BPMS:DR03:745'
    'BPMS:DR03:775'
    'BPMS:DR03:845'
    'BPMS:DR03:881'
    };
    pbpms.name = [dr03BPMS; model_nameRegion('BPMS', 'LI02');];
    [p,m,u] = model_nameSplit(pbpms.name);
    pbpms.Z = control_deviceGet(strcat(m,':',p,':',u), 'Z');
end

if isempty(etoro)
    % enumerate TORO
    etoro.name = model_nameRegion('TORO', {'DR13' 'LI02'});
    etoro.Z = control_deviceGet(etoro.name, 'Z');
end

if isempty(ptoro)
    % enumerate TORO
    ptoro.name = [...
        {'TORO:DR03:71'; ...
        'TORO:DR03:873';}; ...
        model_nameRegion('TORO', {'LI02'})];
    ptoro.Z = control_deviceGet(ptoro.name, 'Z');
end

if isempty(klys)
    % enumerate all magnets
    disp('Building klystron list...');
    [klys.name, klys.Z] = get_by_z('KLYS');
    klys.LEFF = control_deviceGet(klys.name, 'L');
end

if isempty(sbst)
    % enumerate all SBST
    disp('Building SBST list...');
    [sbst.name, sbst.Z] = get_by_z('SBST');
end

if isempty(wire)
    % enumerate all WIREs
    disp('Building WIRE list...');
    [wire.name, wire.Z] = get_by_z('WIRE');
end

% get rate state
state.rate = lcaGetSmart({'EVNT:SYS1:1:SCAVRATE'; 'EVNT:SYS1:1:BEAMRATE'});

% get LEM stuff
lemg = 'VX00:LEMG:5';
eini = lcaGetSmart(strcat(lemg, ':EINI'));
zini = lcaGetSmart(strcat(lemg, ':ZINI'));
eend = lcaGetSmart(strcat(lemg, ':EEND'));
zend = lcaGetSmart(strcat(lemg, ':ZEND'));
fudg = lcaGetSmart(strcat(lemg, ':FUDG'));
state.lem.energy = [eini; eend(eend > 0)'];
state.lem.Z      = [zini; zend(zend > 0)'];
state.lem.fudge  = fudg(fudg > 0)';

% get magnet stuff
disp('Getting live magnet values...');
state.emags = emags;
[state.emags.BDES, state.emags.BACT state.emags.BMAX state.emags.EMOD] = deal(zeros(size(state.emags.name)));
[state.emags.BACT state.emags.BDES state.emags.BMAX state.emags.EMOD] = ...
    control_magnetGet(state.emags.name);

state.pmags = pmags;

[p,m,u] = model_nameSplit(pmags.name);
[state.pmags.BDES, state.pmags.BACT state.pmags.BMAX state.pmags.EMOD] = deal(zeros(size(state.pmags.name)));
[state.pmags.BACT state.pmags.BDES state.pmags.BMAX state.pmags.EMOD] = ...
    control_magnetGet(strcat(m,':',p,':',u));
state.pmags.EMOD(strcmpi(m, 'DR03')) = 1.19;

% get phase and ampl values
disp('Getting live klystron phases...');
state.klys = klys;
[state.klys.PHAS, state.klys.PDES, ...
 state.klys.AMPL, state.klys.ADES, ...
 state.klys.KPHR, state.klys.GOLD] = control_phaseGet(state.klys.name);

% get state
disp('Getting live klystron status...');
[state.klys.TACT, state.klys.STAT, ...
 state.klys.SWRD, state.klys.HDSC, ...
 state.klys.DSTA, state.klys.ENLD] = control_klysStatGet(state.klys.name);

state.klys.HSTA = lcaGetSmart(strcat(model_nameConvert(state.klys.name, 'EPICS'), ':HSTA'));

% calculate 'ISON' status (modulator not off, HSTA online, trigger active)
trig_on =  bitget(state.klys.TACT, 1);  % TACT bit 1 is "ACCEL"
hsta_on =  bitget(state.klys.HSTA, 1);  % HSTA bit 1 is online
mod_ok  = ~bitget(state.klys.SWRD, 4);  % SWRD bit 4 is some mod fault
state.klys.ISON = trig_on & hsta_on & mod_ok;

% get phase and ampl values
disp('Getting live SBST phases...');
state.sbst = sbst;
[state.sbst.PHAS, state.sbst.PDES, ...
 state.sbst.AMPL, state.sbst.ADES, ...
 state.sbst.KPHR, state.sbst.GOLD] = control_phaseGet(state.sbst.name);

% get state
disp('Getting live SBST status...');
[state.sbst.TACT, state.sbst.STAT, ...
 state.sbst.SWRD, state.sbst.HDSC, ...
 state.sbst.DSTA, state.sbst.ENLD] = control_klysStatGet(state.sbst.name);

state.klys.PACT = zeros(size(state.klys.PHAS));

for ix = 1:numel(state.sbst.name)
    [p, m, s] = model_nameSplit(state.sbst.name(ix));
    sector_klys = strmatch(strcat('KLYS:', m), state.klys.name);
    state.klys.PACT(sector_klys) = state.klys.PHAS(sector_klys) + state.sbst.PHAS(ix);
end


% get emittance data
disp('Getting emittance...');
state.wire = wire;
[twiss, twissStd] = control_emitGet(state.wire.name);
state.wire.emit = squeeze(permute(twiss(1,:,:), [3 2 1]));
state.wire.beta = squeeze(permute(twiss(2,:,:), [3 2 1]));
state.wire.alpha = squeeze(permute(twiss(3,:,:), [3 2 1]));
state.wire.bmag = squeeze(permute(twiss(4,:,:), [3 2 1]));

% get BPM data
disp('Getting live BPM data...');
state.ebpms = ebpms;
state.pbpms = pbpms;
state.etoro = etoro;
state.ptoro = ptoro;

ebpmd = 'NDRFACET';
pbpmd = 'SDRFACET';

% get electron orbit
[x,y,t,p,s] = control_bpmAidaGet([ebpms.name; etoro.name], nsamp, ebpmd);
nb = numel(ebpms.name);
nt = numel(etoro.name);
state.ebpms.X       = x(1:nb, :);
state.ebpms.Y       = y(1:nb, :);
state.ebpms.TMIT    = t(1:nb, :);
state.ebpms.pulseid = p(1:nb, :);
state.ebpms.STAT    = s(1:nb, :);
state.etoro.TMIT     = t(end-nt+1:end,:);

% get positron orbit
[x,y,t,p,s] = control_bpmAidaGet([pbpms.name; ptoro.name], nsamp, pbpmd);
nb = numel(pbpms.name);
nt = numel(ptoro.name);
state.pbpms.X       = x(1:nb, :);
state.pbpms.Y       = y(1:nb, :);
state.pbpms.TMIT    = t(1:nb, :);
state.pbpms.pulseid = p(1:nb, :);
state.pbpms.STAT    = s(1:nb, :);
state.ptoro.TMIT    = t(end-nt+1:end,:);


state.timestamp.done = now;
disp('Finished!');


function [list, z] = get_by_z(prim)

devs = model_nameConvert(model_nameRegion(prim, 'LI02'), 'EPICS');
z0 = lcaGetSmart(strcat(devs, ':Z'));
% z0 = model_rMatGet(devs, [], {'TYPE=DESIGN' 'MODE=1'}, 'Z');
[z, ix] = sort(z0);
list = model_nameConvert(devs(ix'), 'SLC');



function [list, z] = get_by_z13(prim)

devs = model_nameConvert(model_nameRegion(prim, 'DR13'), 'EPICS');
z0 = lcaGetSmart(strcat(devs, ':Z'));
% z0 = model_rMatGet(devs, [], {'TYPE=DESIGN' 'MODE=1'}, 'Z');
[z, ix] = sort(z0);
list = model_nameConvert(devs(ix'), 'SLC');



