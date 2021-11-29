% Setup
devnames = {'XCOR:IN20:381:BCTRL';'XCOR:IN20:521:BCTRL';'YCOR:IN20:382:BCTRL';'YCOR:IN20:522:BCTRL';'XPos';'XPos SP';'XAng';'XAng SP';'YPos';'YPos SP';'YAng';'YAng SP';'BPMS:IN20:525:X';'BPMS:IN20:581:X';'BPMS:IN20:631:X';'BPMS:IN20:651:X';'BPMS:IN20:771:X';'BPMS:IN20:781:X';'BPMS:IN20:925:X';'BPMS:IN20:945:X';'BPMS:IN20:981:X';'BPMS:IN20:525:Y';'BPMS:IN20:581:Y';'BPMS:IN20:631:Y';'BPMS:IN20:651:Y';'BPMS:IN20:771:Y';'BPMS:IN20:781:Y';'BPMS:IN20:925:Y';'BPMS:IN20:945:Y';'BPMS:IN20:981:Y'};
pvs = {'FBCK:FB04:TR02:A1HST';'FBCK:FB04:TR02:A2HST';'FBCK:FB04:TR02:A3HST';'FBCK:FB04:TR02:A4HST';'FBCK:FB04:TR02:S1HST';'FBCK:FB04:TR02:S1DESHST';'FBCK:FB04:TR02:S2HST';'FBCK:FB04:TR02:S2DESHST';'FBCK:FB04:TR02:S3HST';'FBCK:FB04:TR02:S3DESHST';'FBCK:FB04:TR02:S4HST';'FBCK:FB04:TR02:S4DESHST';'FBCK:FB04:TR02:M1HST';'FBCK:FB04:TR02:M2HST';'FBCK:FB04:TR02:M3HST';'FBCK:FB04:TR02:M4HST';'FBCK:FB04:TR02:M5HST';'FBCK:FB04:TR02:M6HST';'FBCK:FB04:TR02:M7HST';'FBCK:FB04:TR02:M8HST';'FBCK:FB04:TR02:M9HST';'FBCK:FB04:TR02:M10HST';'FBCK:FB04:TR02:M11HST';'FBCK:FB04:TR02:M12HST';'FBCK:FB04:TR02:M13HST';'FBCK:FB04:TR02:M14HST';'FBCK:FB04:TR02:M15HST';'FBCK:FB04:TR02:M16HST';'FBCK:FB04:TR02:M17HST';'FBCK:FB04:TR02:M18HST'};

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