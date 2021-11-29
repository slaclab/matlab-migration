% Setup
devnames = {'FILE:/data/TR02/XCOR:IN20:381:BCTRL';'FILE:/data/TR02/XCOR:IN20:521:BCTRL';'FILE:/data/TR02/YCOR:IN20:382:BCTRL';'FILE:/data/TR02/YCOR:IN20:522:BCTRL';'FILE:/data/TR02/XPos';'FILE:/data/TR02/XPos SP';'FILE:/data/TR02/XAng';'FILE:/data/TR02/XAng SP';'FILE:/data/TR02/YPos';'FILE:/data/TR02/YPos SP';'FILE:/data/TR02/YAng';'FILE:/data/TR02/YAng SP';'FILE:/data/TR02/BPMS:IN20:525:X';'FILE:/data/TR02/BPMS:IN20:581:X';'FILE:/data/TR02/BPMS:IN20:631:X';'FILE:/data/TR02/BPMS:IN20:651:X';'FILE:/data/TR02/BPMS:IN20:771:X';'FILE:/data/TR02/BPMS:IN20:781:X';'FILE:/data/TR02/BPMS:IN20:925:X';'FILE:/data/TR02/BPMS:IN20:525:Y';'FILE:/data/TR02/BPMS:IN20:581:Y';'FILE:/data/TR02/BPMS:IN20:631:Y';'FILE:/data/TR02/BPMS:IN20:651:Y';'FILE:/data/TR02/BPMS:IN20:771:Y';'FILE:/data/TR02/BPMS:IN20:781:Y';'FILE:/data/TR02/BPMS:IN20:925:Y'};
pvs = {'FBCK:FB05:TR02:A1HST';'FBCK:FB05:TR02:A2HST';'FBCK:FB05:TR02:A3HST';'FBCK:FB05:TR02:A4HST';'FBCK:FB05:TR02:S1HST';'FBCK:FB05:TR02:S1DESHST';'FBCK:FB05:TR02:S2HST';'FBCK:FB05:TR02:S2DESHST';'FBCK:FB05:TR02:S3HST';'FBCK:FB05:TR02:S3DESHST';'FBCK:FB05:TR02:S4HST';'FBCK:FB05:TR02:S4DESHST';'FBCK:FB05:TR02:M1HST';'FBCK:FB05:TR02:M2HST';'FBCK:FB05:TR02:M3HST';'FBCK:FB05:TR02:M4HST';'FBCK:FB05:TR02:M5HST';'FBCK:FB05:TR02:M6HST';'FBCK:FB05:TR02:M7HST';'FBCK:FB05:TR02:M8HST';'FBCK:FB05:TR02:M9HST';'FBCK:FB05:TR02:M10HST';'FBCK:FB05:TR02:M11HST';'FBCK:FB05:TR02:M12HST';'FBCK:FB05:TR02:M13HST';'FBCK:FB05:TR02:M14HST'};

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