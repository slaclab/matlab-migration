function [egain, chirp, phase] = facet_chirp(usefudge, usePDES)

if nargin < 1, usefudge = 1; end
if nargin < 2, usePDES = 0; end

% list all klystrons + sbst
sectors = 2:10;
micros = cellstr(num2str(sectors', 'LI%02d'));
klys = model_nameRegion('KLYS', micros);
sbst = model_nameRegion('SBST', micros);

% map klys to sbst
kmap = false(numel(micros), numel(klys));
for ix = 1:numel(micros)
    kmap(ix,:) = strncmpi(micros{ix}, klys, 4);
end

% get phas and pdes
[kpact, kpdes, kaact, kades] = control_phaseGet(klys);
[spact, spdes, saact, sades] = control_phaseGet(sbst);
kz = control_deviceGet(klys, 'Z');

% get fast phase shifters
i91 = find(strcmp(klys, 'LI09:KLYS:11'));
i92 = find(strcmp(klys, 'LI09:KLYS:21'));
ifbk = [i91; i92];
phas9192 = lcaGetSmart(strcat('LI09:PHAS:', {'12'; '22'}, ':VACT'));
if any(isnan(phas9192)), phas9192 = [90; -90]; end

% get trigger act, SWRD for mod fault status, and ENLD for gain
[act, d, swrd, d, dsta, enld] = control_klysStatGet(klys, 10);
hsta = control_deviceGet(klys, 'HSTA');
eerr = control_deviceGet(klys, 'EERR');
isact = bitget(act, 1);                     % acc trig on BC 10
ismod = bitget(hsta, 1) & ~bitget(swrd, 4); % hsta online & ~mod fault

% use PDES if PACT is bad
plim = 400; % ignore readback with phase bigger than this
ptol = 400;  % ignore anything phasetol by this much?
amin = 10;  % ignore phase if AMPL less than this
amax = 100;
kbad = (abs(kpact) > plim) | ...
       (abs(kpdes - kpact) > ptol) | ...
       kaact < amin | kaact > amax;
sbad = (abs(spact) > plim) | ...
       (abs(spdes - spact) > ptol);

ison = isact & ismod & kaact > amin & kaact < amax;

kphase = kpact;
kphase(kbad) = kpdes(kbad);
sphase = spact;
sphase(sbad) = spdes(sbad);

kphasedes = zeros(size(kphase));
% add sbst phases
for ix = 1:numel(micros)
    kphase(kmap(ix,:)) = kphase(kmap(ix,:)) + sphase(ix);
    kphasedes(kmap(ix,:)) = kpdes(kmap(ix,:)) + spdes(ix);
end

% sub in fast feedback phases
kphase(ifbk) = phas9192;
kphasedes(ifbk) = phas9192;

% get LEMG reference energy
lem_eend = lcaGetSmart('VX00:LEMG:5:EEND');
start_E = 1190;
end_E   = lem_eend(1) * 1e3;

% get LEMG fudges
lem_fudg = lcaGetSmart('VX00:LEMG:5:FUDG');
fudge = lem_fudg(1);

if ~usefudge
    fudge = 1;
end

% calculate each station's contribution to energy and chirp
egains = cosd(kphase) .* ison .* enld .* eerr * fudge;
egaind = cosd(kphasedes) .* ison .* enld .* eerr * fudge;
chirps = sind(kphase) .* ison .* enld .* eerr * fudge;
chirpd = sind(kphasedes) .* ison .* enld .* eerr * fudge;
on = logical(ison);

% add up all the gains and chirps
egain = sum(egains);
chirp = sum(chirps);
if usePDES
    egain = sum(egaind);
    chirp = sum(chirpd);
end
phase = atan2(chirp, egain) * 180/pi;