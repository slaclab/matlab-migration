function state = facet_getMachine(nsamp, dgrp)
% STATE = FACET_GETMACHINE() retrieves the current state of the FACET beamline
% magnets, RF and beam orbit in a convenient struct which should encapsulate
% most of the essential beam parameters.  This is intended to facilitate online analysis
% and simulation by those not famililar with the Matlab control system toolbox.
%
% Input arguments:
%
%   NSAMP: [Optional] Number of BPM acquisitions to do.  Defaults to 1.
%
% Output arguments:
%   STATE: Struct containing Z-sorted lists of the following devices:
%       MAGS:       FACET magnets (names, Z, BDES, BACT, BMAX)
%       KLYS:       FACET klystrons (names, Z, phases, amplitude, status)
%           ENLD:   Zero-phase energy gain for this klystron (MeV)
%           PACT:   Phase readback including subbooster and fast phase shifter offsets.
%           ISON:   Boolean indicating this klystron is accelerating
%       SBST:       FACET sub-boosters (names, Z, phases, amplitude, status)
%       BPMS:       FACET BPMS (names, Z, X, Y, TMIT, status)
%       PHASE:      FACET special phase controls (9-1, 9-2, S17, S18 phase shifters)
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

if nargin < 1, nsamp = 1; end
if nargin < 2, dgrp = 'NDRFACET'; end

persistent mags;
persistent klys;
persistent sbst;
persistent wire;

persistent bpms;

% add timestamp
state.timestamp.start = now;

if isempty(mags)
    % enumerate all magnets
    disp('Building magnet list...');
    [mags.name, mags.Z] = get_by_z({'BEND' 'BTRM' 'BNDS' 'KICK' 'QUAD' 'QTRM' 'QUAS' 'XCOR' 'YCOR' 'SEXT' 'SXTS'});
    mags.madname = model_nameConvert(mags.name, 'MAD');
    mags.LEFF = control_deviceGet(mags.name, 'LEFF');
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

if isempty(bpms)
    % enumerate all BPMS
    disp('Building BPM list...');
    config = util_configLoad('facet_BPM_repeater');
    dr13bpms = strmatch('BPMS:DR13', config.roots2);
    lixxbpms = strmatch('BPMS:LI', config.roots2);
    ep01bpms = strmatch('BPMS:EP01:185', config.roots1);
    bpms.name = [config.roots2([dr13bpms; lixxbpms]); config.roots1(ep01bpms)];
    bpms.Z = control_deviceGet(bpms.name, 'Z');
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

% as of writing, these magnets have :Z = NaN and also choke control_magnetGet:
%
%     'BNDS:DR13:570'
%     'QUAD:LI10:802'
%     'XCOR:LI20:3276'
disp('Getting live magnet values...');
state.mags = mags;
[state.mags.BDES, state.mags.BACT state.mags.BMAX state.mags.EMOD] = deal(zeros(size(state.mags.name)));
[state.mags.BACT state.mags.BDES state.mags.BMAX state.mags.EMOD] = ...
    control_magnetGet(state.mags.name);

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

% get fast phase shifters
disp('Getting pulsed phases...');
state.phase.k_9_1 = pvaGet('PHAS:LI09:12:VACT');    % 9-1 pulsed phase shifter SPPS
state.phase.k_9_2 = pvaGet('PHAS:LI09:22:VACT');    % 9-2 pulsed phase shifter SPPS
state.phase.s_17 = pvaGet('AMPL:EP01:171:VACT');   % S17 pulsed phase shifter SPPS
state.phase.s_18 = pvaGet('AMPL:EP01:181:VACT');   % S18 pulsed phase shifter SPPS

% caclulate total phase (klys PHAS + sbst PHAS)
state.klys.PACT = zeros(size(state.klys.PHAS));

for ix = 1:numel(state.sbst.name)
    [p, m, s] = model_nameSplit(state.sbst.name(ix));
    sector_klys = strmatch(strcat('KLYS:', m), state.klys.name);
    state.klys.PACT(sector_klys) = state.klys.PHAS(sector_klys) + state.sbst.PHAS(ix);
end

% special cases for FBCK phase shifters - offset particular phases
i91 = strmatch('KLYS:LI09:11', state.klys.name);    % offset 9-1
i92 = strmatch('KLYS:LI09:21', state.klys.name);    % offset 9-2
i17 = strmatch('KLYS:LI17', state.klys.name);       % offset all Sec 17
i18 = strmatch('KLYS:LI18', state.klys.name);       % offset all Sec 18

state.klys.PACT(i91) = state.klys.PACT(i91) + state.phase.k_9_1;
state.klys.PACT(i92) = state.klys.PACT(i92) + state.phase.k_9_2;
state.klys.PACT(i17) = state.klys.PACT(i17) + state.phase.s_17;
state.klys.PACT(i18) = state.klys.PACT(i18) + state.phase.s_18;

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
state.bpms = bpms;
config = util_configLoad('facet_BPM_repeater');
if strcmp(dgrp, 'NDRFACET')
    bpmd = '57';
    bpmlist = config.roots2;
else
    bpmd = '8';
    bpmlist = config.roots1;
end

use = false(size(state.bpms.name));
for ix = 1:numel(state.bpms.name)
    use(ix) = any(strcmp(state.bpms.name(ix), bpmlist));
end

state.bpms.X = repmat(nan(size(state.bpms.name)), 1, nsamp);
state.bpms.Y = repmat(nan(size(state.bpms.name)), 1, nsamp);
state.bpms.TMIT = repmat(nan(size(state.bpms.name)), 1, nsamp);
state.bpms.STAT = repmat(nan(size(state.bpms.name)), 1, nsamp);
state.bpms.pulseid = repmat(nan(size(state.bpms.name)), 1, nsamp);

[state.bpms.X(use,:), state.bpms.Y(use,:), state.bpms.TMIT(use,:), ...
    state.bpms.pulseid(use,:), state.bpms.STAT(use,:)] = control_bpmAidaGet(state.bpms.name(use), nsamp, bpmd);

state.timestamp.done = now;
disp('Finished!');


function [list, z] = get_by_z(prim)

devs = model_nameConvert(model_nameRegion(prim, {'LI02' 'LI03' 'LI04' 'LI05' 'LI06' 'LI07' 'LI08' 'LI09' 'LI10' ...
                                          'LI11' 'LI12' 'LI13' 'LI14' 'LI15' 'LI16' 'LI17' 'LI18' 'LI19' 'LI20'}), 'EPICS');
z0 = lcaGetSmart(strcat(devs, ':Z'));
% z0 = model_rMatGet(devs, [], {'TYPE=DESIGN' 'MODE=1'}, 'Z');
[z, ix] = sort(z0);
list = model_nameConvert(devs(ix'), 'SLC');
