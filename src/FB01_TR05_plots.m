% Setup
devnames = {'XCOR:BSY0:34:BCTRL';'XCOR:BSY0:60:BCTRL';'YCOR:BSY0:35:BCTRL';'YCOR:BSY0:62:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:BSY0:61:X';'BPMS:BSY0:63:X';'BPMS:BSY0:83:X';'BPMS:BSY0:85:X';'BPMS:BSY0:88:X';'BPMS:BSY0:61:Y';'BPMS:BSY0:63:Y';'BPMS:BSY0:83:Y';'BPMS:BSY0:85:Y';'BPMS:BSY0:88:Y'};
pvs = {'FBCK:FB01:TR05:A1HST';'FBCK:FB01:TR05:A2HST';'FBCK:FB01:TR05:A3HST';'FBCK:FB01:TR05:A4HST';'FBCK:FB01:TR05:S1HST';'FBCK:FB01:TR05:S1DESHST';'FBCK:FB01:TR05:S2HST';'FBCK:FB01:TR05:S2DESHST';'FBCK:FB01:TR05:S3HST';'FBCK:FB01:TR05:S3DESHST';'FBCK:FB01:TR05:S4HST';'FBCK:FB01:TR05:S4DESHST';'FBCK:FB01:TR05:M1HST';'FBCK:FB01:TR05:M2HST';'FBCK:FB01:TR05:M3HST';'FBCK:FB01:TR05:M4HST';'FBCK:FB01:TR05:M5HST';'FBCK:FB01:TR05:M6HST';'FBCK:FB01:TR05:M7HST';'FBCK:FB01:TR05:M8HST';'FBCK:FB01:TR05:M9HST';'FBCK:FB01:TR05:M10HST'};

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