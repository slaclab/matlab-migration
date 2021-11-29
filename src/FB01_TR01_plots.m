% Setup
devnames = {'XCOR:IN20:221:BCTRL';'YCOR:IN20:222:BCTRL';'XCOR:IN20:311:BCTRL';'YCOR:IN20:312:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:IN20:371:X';'BPMS:IN20:425:X';'BPMS:IN20:511:X';'BPMS:IN20:525:X';'BPMS:IN20:581:X';'BPMS:IN20:631:X';'BPMS:IN20:651:X';'BPMS:IN20:371:Y';'BPMS:IN20:425:Y';'BPMS:IN20:511:Y';'BPMS:IN20:525:Y';'BPMS:IN20:581:Y';'BPMS:IN20:631:Y';'BPMS:IN20:651:Y'};
pvs = {'FBCK:FB01:TR01:A1HST';'FBCK:FB01:TR01:A2HST';'FBCK:FB01:TR01:A3HST';'FBCK:FB01:TR01:A4HST';'FBCK:FB01:TR01:S1HST';'FBCK:FB01:TR01:S1DESHST';'FBCK:FB01:TR01:S2HST';'FBCK:FB01:TR01:S2DESHST';'FBCK:FB01:TR01:S3HST';'FBCK:FB01:TR01:S3DESHST';'FBCK:FB01:TR01:S4HST';'FBCK:FB01:TR01:S4DESHST';'FBCK:FB01:TR01:M1HST';'FBCK:FB01:TR01:M2HST';'FBCK:FB01:TR01:M3HST';'FBCK:FB01:TR01:M4HST';'FBCK:FB01:TR01:M5HST';'FBCK:FB01:TR01:M6HST';'FBCK:FB01:TR01:M7HST';'FBCK:FB01:TR01:M8HST';'FBCK:FB01:TR01:M9HST';'FBCK:FB01:TR01:M10HST';'FBCK:FB01:TR01:M11HST';'FBCK:FB01:TR01:M12HST';'FBCK:FB01:TR01:M13HST';'FBCK:FB01:TR01:M14HST'};

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