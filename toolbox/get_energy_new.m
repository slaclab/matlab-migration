function out = get_energy_new(get_quick)

% get_energy() is a thing coming soon


% if get_quick isn't specified, assume it is false.  this provides
% backwards compatibility with the old get_energy().

if nargin < 1
    get_quick = 0;
end

%% initialization

persistent static

% declare some data structures and set them to something empty

sectors = 21:30;
stations = 1:8;

[sb.names   sb.pdespv   sb.phaspv] = deal(cell(30, 1));
[sb.names{:} sb.pdespv{:} sb.phaspv{:}] = deal('');
kl.names = deal(cell(240, 1));
[kl.names{:}] = deal('');

[kl.egain   kl.energy   kl.ampl     kl.phase    kl.gainf    kl.ampf ...
    kl.phasef  kl.is.L0    kl.is.L1    kl.is.L2    kl.is.L3    kl.energyf ...
    kl.statI   kl.statQ    kl.station_on ...
    kl.act     kl.stat     kl.swrd     kl.hdsc     kl.enld] = deal(zeros(240, 1));

[sb.phas sb.pdes sb.ampl sb.ades sb.kphr sb.gold] = deal(zeros(30, 1));

out = struct;

%% fetch the list of klystron names
if isempty(static)
    % get all klys names if this is the first run
    static = model_energyProfile([], 1 , 0);

    % tack on the gun, which is not returned by model_energyProfile
    static.klys.name = ['20-6'; static.klys.name];
end

%% fetch the list of subbooster names

% TODO make this not hard-coded
sb.names(sectors) = { '21-S' '22-S' '23-S' '24-S' '25-S' '26-S' '27-S' '28-S' '29-S' '30-S'};


%% fetch ampl & phase data 

try
    % actually get the energy profile and ampl/phase data
    % phases returned by this call include everything
    [data.ampl, data.phase, data.is] = model_energyKlys(static.klys.name, 0, 0);
catch
    disp_log('Error getting klystron data');
    out = [];
    return
end

try
   out.L2_phase = control_phaseGet('L2');
   out.L3_phase = control_phaseGet('L3');
   out.S29_phase = control_phaseGet('29-0');
   out.S30_phase = control_phaseGet('30-0');

catch
    disp_log('Error getting phase PVs');
    out = [];
    return
end

try
    % fetch the fudges
    [data.gainf, data.fudgeact, data.ampf, data.phasef] = model_energyFudge(data.ampl, data.phase, data.is);

    % model_energyFudge returns the fudged energy gain for each tube (data.gainf)
    % in GeV.  need to convert to MeV:
    data.gainf = 1000 * data.gainf;
catch
    disp_log('Error getting fudge factors');
    out = [];
    return
end

try
    % get subbooster phases too
    % control_phaseGet() is too slow for this

    % construct list of PV names for subboosters
    % need to do this to use lcaGet instead of aida
    sb.pdespv(sectors) = strcat(model_nameConvert(sb.names(sectors), 'SLC'), ':PDES');
    sb.phaspv(sectors) = strcat(model_nameConvert(sb.names(sectors), 'SLC'), ':PHAS');

    sb.pdes(sectors, 1) = lcaGet(sb.pdespv(sectors));
    sb.phas(sectors, 1) = lcaGet(sb.phaspv(sectors));
catch
    disp_log('Error getting SBST phases');
    out = [];
    return
end

if ~get_quick
    try
        % get SLC status bits if get_quick is false
        [data.act, data.stat, data.swrd, data.hdsc, dummy, data.enld] = ...
            control_klysStatGet(static.klys.name, 1);
    catch
        disp_log('Error getting SLC status');
        out = [];
        return
    end
end

%% calculate the energy gain and chirp foreach station

% "egain" defined by joe is the same as "ampl" defined by henrik
%data.gain = data.ampl;

% calculate energy gain and chirp (I and Q) of each station

data.statI = data.ampl .* cosd(data.phase);
data.statQ = data.ampl .* sind(data.phase);

% calculate the energy down the machine

data.energy = cumsum(data.statI);
data.energyf = cumsum(data.gainf);      % gainf is like statI, but fudged by henrik

% flag for whether station is on 

data.station_on = (data.ampl > 0);

%% map all klystron status to 30x8 matrices

kl.names    = map_it(static.klys.name, kl.names);       % MAD names
kl.ampl     = map_it(data.ampl, kl.ampl);               % ampl (MeV) (0 if off/maint/deact)
kl.phase    = map_it(data.phase, kl.phase);             % phases (including SBSTs)
kl.egain    = kl.ampl;                                  % same as ampl
kl.energy   = map_it(data.energy, kl.energy);           % cumulative beam energy after each station
kl.energyf  = map_it(data.energyf, kl.energyf);         % same as energy, but fudged to LEM energies
kl.gainf    = map_it(data.gainf, kl.gainf);             % fudged statI's
kl.ampf     = map_it(data.ampf, kl.ampf);               % fudged ampls
kl.phasef   = map_it(data.phasef, kl.phasef);           % fudged phases
kl.is.L0    = map_it(data.is.L0, kl.is.L0);             % flag - true if in L0
kl.is.L1    = map_it(data.is.L1, kl.is.L1);             % flag - true if in L1
kl.is.L2    = map_it(data.is.L2, kl.is.L2);             % flag - true if in L2
kl.is.L3    = map_it(data.is.L3, kl.is.L3);             % flag - true if in L3
kl.statI    = map_it(data.statI, kl.statI);             % ampl * cos(phase)
kl.statQ    = map_it(data.statQ, kl.statQ);             % ampl * sin(phase)
kl.station_on = map_it(data.station_on, kl.station_on); % flag - true if station is on

if ~get_quick
    kl.act  = map_it(data.act, kl.act);
    kl.stat = map_it(data.stat, kl.stat);
    kl.swrd = map_it(data.swrd, kl.swrd);
    kl.hdsc = map_it(data.hdsc, kl.hdsc);
    kl.enld = map_it(data.enld, kl.enld);
end

% kludge to fill in the gaps at 24-7 and 24-8
% TODO make this better

kl.energy(24, 7:8) = deal(kl.energy(24, 6));
kl.energyf(24, 7:8) = deal(kl.energyf(24, 6));

%% sanity checks

if  ~any(kl.station_on(find(kl.is.L2))) || ...
    ~any(kl.station_on(find(kl.is.L3)))
        disp_log('No stations appear on in L2 or L3');
        out = [];
        return
end

%% get machine LEM reference energies

out.energy_setpoints = model_energySetPoints() * 1000;

% TODO add smarts for BC2 motion?

out.beam_energy_bc2 = out.energy_setpoints(4);
out.beam_energy_bsy = out.energy_setpoints(5);
out.beam_energy_PR55 = out.energy_setpoints(5);
out.beam_energy_LTU  = out.energy_setpoints(5);  % TODO fix this? I think?


%% calculate all the different permutations of beam energy to be output

% best guess at beam energy from L0, L1, L2, L3 including phases

out.L0_energy   = sum(sum(kl.statI .* kl.is.L0)) + kl.statI(20, 6);
out.L1_energy   = sum(sum(kl.statI .* kl.is.L1));
out.L2_energy   = sum(sum(kl.statI .* kl.is.L2));
out.L3_energy   = sum(sum(kl.statI .* kl.is.L3));

% best guess at total chirp (in MeV)

out.L0_chirp  = sum(sum(kl.statQ .* kl.is.L0));
out.L1_chirp  = sum(sum(kl.statQ .* kl.is.L1));
out.L2_chirp  = sum(sum(kl.statQ .* kl.is.L2));
out.L3_chirp  = sum(sum(kl.statQ .* kl.is.L3));

% phase of vector sum of stations

out.L0_effective_phase = rad2deg(atan2(out.L0_chirp, out.L0_energy));
out.L1_effective_phase = rad2deg(atan2(out.L1_chirp, out.L1_energy));
out.L2_effective_phase = rad2deg(atan2(out.L2_chirp, out.L2_energy));
out.L3_effective_phase = rad2deg(atan2(out.L3_chirp, out.L3_energy));

% amplitude of vector sum of stations

out.L0_total_energy = sqrt(out.L0_energy^2 + out.L0_chirp^2);
out.L1_total_energy = sqrt(out.L1_energy^2 + out.L1_chirp^2);
out.L2_total_energy = sqrt(out.L2_energy^2 + out.L2_chirp^2);
out.L3_total_energy = sqrt(out.L3_energy^2 + out.L3_chirp^2);

% BC2 and final energies

out.DL1_energy    = kl.energy(20, 8);
out.BC1_energy    = kl.energy(21, 2);
out.BC2_energy    = kl.energy(24, 7);
out.final_energy  = kl.energy(30, 8);

% fudge factors

out.L0_fudge = data.fudgeact(1);
out.L1_fudge = data.fudgeact(2);
out.L2_fudge = data.fudgeact(3);
out.L3_fudge = data.fudgeact(4);

% calculate energy gain and chirp from feedback stations

out.L2fb_energy     = sum(sum(kl.statI(24, 1:3)));
out.L2fb_chirp      = sum(sum(kl.statQ(24, 1:3)));
out.L3fb_energy     = sum(sum(kl.statI(29:30, :)));
out.L3fb_chirp      = sum(sum(kl.statQ(29:30, :)));

% "no feedback" energies and chirps subtract the feedback stations

out.L2_nofb_energy = out.L2_energy - out.L2fb_energy;
out.L3_nofb_energy = out.L3_energy - out.L3fb_energy;

out.L2_nofb_chirp = out.L2_chirp - out.L2fb_chirp;
out.L3_nofb_chirp = out.L3_chirp - out.L3fb_chirp;

% this is different from Joe's calculation, should be more consistent now
% "total" energies don't know about phase
% old calc didn't subtract the fb stations in L2

out.L2_nofb_total_energy = sum(sum(kl.ampl .* kl.is.L2)) - sum(sum(kl.ampl(24, 1:3)));
out.L2_nofb_total_energy = sum(sum(kl.ampl .* kl.is.L3)) - sum(sum(kl.ampl(29:30, :)));

% "flat" energies don't include station phases - only the "global" phase shifts

out.L2_nofb_flat_energy = (sum(sum(kl.ampl .* kl.is.L2)) - sum(sum(kl.ampl(24, 1:3)))) * cosd(out.L2_phase);
out.L2_nofb_flat_chirp  = (sum(sum(kl.ampl .* kl.is.L2)) - sum(sum(kl.ampl(24, 1:3)))) * sind(out.L2_phase);
out.L3_nofb_flat_energy = (sum(sum(kl.ampl .* kl.is.L3)) - sum(sum(kl.ampl(29:30, :)))) * cosd(out.L3_phase);
out.L3_nofb_flat_chirp  = (sum(sum(kl.ampl .* kl.is.L3)) - sum(sum(kl.ampl(29:30, :)))) * sind(out.L3_phase);

out.L2_flat_energy = out.L2_nofb_flat_energy + out.L2fb_energy;
out.L3_flat_energy = out.L3_nofb_flat_energy + out.L3fb_energy;
out.L2_flat_chirp = out.L2_nofb_flat_chirp + out.L2fb_chirp;
out.L3_flat_chirp = out.L3_nofb_flat_chirp + out.L3fb_chirp;

% these calculations are not consistent with the definition of "flat"
% above, but whatever - leave them in for consistency

out.L2_nofb_flat_total_energy = sum(sum(kl.ampl .* kl.is.L2)) - sum(sum(kl.ampl(24, 1:3)));
out.L3_nofb_flat_total_energy = sum(sum(kl.ampl .* kl.is.L3)) - sum(sum(kl.ampl(29:30, :)));

out.S29_flat_energy = sum(sum(kl.ampl(29, :)));
out.S30_flat_energy = sum(sum(kl.ampl(30, :)));

% "flat" fudge calculations - not sure if this is correct either, but there it is

out.L2_flat_fudge = (out.beam_energy_bc2 - out.L0_energy - out.L1_energy) / out.L2_flat_energy;
out.L3_flat_fudge = (out.beam_energy_bsy - out.beam_energy_bc2) / out.L3_flat_energy;

% number of klystrons in L2 and L3

out.num_klystrons.L2 = sum(sum(kl.station_on .* kl.is.L2));
out.num_klystrons.L3 = sum(sum(kl.station_on .* kl.is.L3));

% calculate feedback percentages - -1 to +1 of full (energy) range

S24_fb_phase = 0;
station_count = 1;
for jx = 1:3
    if kl.ampl(24, jx) > 1  % TODO find a better condition to check for feedbackness
        % e.g. look at Kukhee's feedback station selector PV?
        S24_fb_phase(station_count) = kl.phase(24, jx) - out.L2_phase;
        station_count = station_count + 1;
    end
end

out.L2_feedback_strength = cosd(mean(abs(S24_fb_phase)));

out.L3_feedback_strength = cosd(mean([out.S29_phase -out.S30_phase]));

%% return everything

out.klystrons = kl;
out.sbst = sb;


%% useful functions

function out = map_it(in, out)
% distribute N x 1 vector results from model_* function calls to 30 x 8 matrices
% i have to break this up into two parts, because 24-7 and 24-8 don't
% exist in the inputs.
%
% 20-6 is the 158th klystron; 25-1 is the 193rd.
%
% TODO make this more robust - figure out the mapping dynamically, rather
% than hard coding index positions

[out(158:190) out(193:240)] = deal(in(1:33), in(34:81));
out = reshape(out, 8, 30)';

function degs = rad2deg(rads)
% simple function to convert radians to degrees

degs = 180/pi * rads;

function rads = deg2rad(degs)
% simple function to convert degrees to radians

rads = pi/180 * degs;




