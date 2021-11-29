% Setup
devnames = {'ACCL:IN20:400:L0B_ADES';'ACCL:LI21:1:L1S_ADES';'ACCL:LI21:1:L1S_PDES';'ACCL:LI22:1:ADES';'ACCL:LI22:1:PDES';'ACCL:LI25:1:ADES';'DL1.Energy';'BC1.Energy';'BC1.Current';'BC2.Energy';'BC2.Current';'DL2.Energy';'BPMS:IN20:731:X';'BPMS:IN20:981:X';'BPMS:LI21:233:X';'BLEN:LI21:265:AIMAXF2';'BPMS:LI24:801:X';'BLEN:LI24:886:BIMAXF2';'BPMS:BSY0:52:X';'BPMS:LTU1:250:X';'BPMS:LTU1:450:X';'BPMS:LTU0:170:Y'};
pvs = {'FBCK:FB04:LG01:A1P4HST';'FBCK:FB04:LG01:A2P4HST';'FBCK:FB04:LG01:A3P4HST';'FBCK:FB04:LG01:A4P4HST';'FBCK:FB04:LG01:A5P4HST';'FBCK:FB04:LG01:A6P4HST';'FBCK:FB04:LG01:S1P4HST';'FBCK:FB04:LG01:S2P4HST';'FBCK:FB04:LG01:S3P4HST';'FBCK:FB04:LG01:S4P4HST';'FBCK:FB04:LG01:S5P4HST';'FBCK:FB04:LG01:S6P4HST';'FBCK:FB04:LG01:M1P4HST';'FBCK:FB04:LG01:M2P4HST';'FBCK:FB04:LG01:M3P4HST';'FBCK:FB04:LG01:M4P4HST';'FBCK:FB04:LG01:M5P4HST';'FBCK:FB04:LG01:M6P4HST';'FBCK:FB04:LG01:M7P4HST';'FBCK:FB04:LG01:M8P4HST';'FBCK:FB04:LG01:M9P4HST';'FBCK:FB04:LG01:M10P4HST'};

% Get FBCK data
fbckdata = cell(size(pvs));
for i=1:size(pvs)
    fbckdata{i}.pvname = pvs{i};
    fbckdata{i}.devname = devnames{i};
    [val, ts] = lcaGet(pvs{i});
    fbckdata{i}.waveform = val;
    if exist('epics2matlabTime')
        ts = epics2matlabTime(ts);
    end
    fbckdata{i}.timestamp = ts;
end

varname = 'fbckdata';

% Print FBCK data
celldisp(fbckdata);
whos(varname);

% Print help
path = sprintf('/u1/lcls/matlab/Feedback/fbckdata_%f', now());
path = regexprep(path, '\.', '_');
help = sprintf('Type e.g. ''save %s %s'' to save %s to %s.mat.', path, varname, varname, path);
disp('--------------------------------------------------------------------------------------');
disp(help);