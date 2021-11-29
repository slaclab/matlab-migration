% Setup
devnames = {'ACCL:IN20:400:L0B_ADES';'ACCL:LI21:1:L1S_ADES';'ACCL:LI21:1:L1S_PDES';'ACCL:LI24:L2:ABSTR_ADES';'ACCL:LI24:L2:ABSTR_PDES';'ACCL:LI29:L3:ABSTR_ADES';'DL1.Energy';'DL1.Energy SP';'BC1.Energy';'BC1.Energy SP';'BC1.Current';'BC1.Current SP';'BC2.Energy';'BC2.Energy SP';'BC2.Current';'BC2.Current SP';'DL2.Energy';'DL2.Energy SP';'BPMS:IN20:731:X';'BPMS:IN20:981:X';'BPMS:LI21:233:X';'BLEN:LI21:265:AIMAXF2';'BPMS:LI24:801:X';'BLEN:LI24:886:BIMAXF2';'BPMS:BSY0:52:X';'BPMS:LTU1:250:X';'BPMS:LTU1:450:X'};
pvs = {'FBCK:FB02:LG01:A1HST';'FBCK:FB02:LG01:A2HST';'FBCK:FB02:LG01:A3HST';'FBCK:FB02:LG01:A4HST';'FBCK:FB02:LG01:A5HST';'FBCK:FB02:LG01:A6HST';'FBCK:FB02:LG01:S1HST';'FBCK:FB02:LG01:S1DESHST';'FBCK:FB02:LG01:S2HST';'FBCK:FB02:LG01:S2DESHST';'FBCK:FB02:LG01:S3HST';'FBCK:FB02:LG01:S3DESHST';'FBCK:FB02:LG01:S4HST';'FBCK:FB02:LG01:S4DESHST';'FBCK:FB02:LG01:S5HST';'FBCK:FB02:LG01:S5DESHST';'FBCK:FB02:LG01:S6HST';'FBCK:FB02:LG01:S6DESHST';'FBCK:FB02:LG01:M1HST';'FBCK:FB02:LG01:M2HST';'FBCK:FB02:LG01:M3HST';'FBCK:FB02:LG01:M4HST';'FBCK:FB02:LG01:M5HST';'FBCK:FB02:LG01:M6HST';'FBCK:FB02:LG01:M7HST';'FBCK:FB02:LG01:M8HST';'FBCK:FB02:LG01:M9HST'};

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