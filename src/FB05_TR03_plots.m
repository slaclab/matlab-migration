% Setup
devnames = {'XCOR:LI21:101:BCTRL';'YCOR:LI21:136:BCTRL';'';' SP';'Y Position';'Y Position SP';'BPMS:LI21:201:X';'BPMS:LI21:201:Y'};
pvs = {'FBCK:FB05:TR03:A1HST';'FBCK:FB05:TR03:A2HST';'FBCK:FB05:TR03:S1HST';'FBCK:FB05:TR03:S1DESHST';'FBCK:FB05:TR03:S2HST';'FBCK:FB05:TR03:S2DESHST';'FBCK:FB05:TR03:M1HST';'FBCK:FB05:TR03:M2HST'};

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