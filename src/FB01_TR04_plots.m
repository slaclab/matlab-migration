% Setup
devnames = {'XCOR:LI21:275:BCTRL';'XCOR:LI21:302:BCTRL';'YCOR:LI21:276:BCTRL';'YCOR:LI21:303:BCTRL';'X.Position';'X.Position SP';'X.Angle';'X.Angle SP';'Y.Position';'Y.Position SP';'Y.Angle';'Y.Angle SP';'BPMS:LI21:301:X';'BPMS:LI21:401:X';'BPMS:LI21:501:X';'BPMS:LI21:601:X';'BPMS:LI21:701:X';'BPMS:LI21:801:X';'BPMS:LI21:901:X';'BPMS:LI21:301:Y';'BPMS:LI21:401:Y';'BPMS:LI21:501:Y';'BPMS:LI21:601:Y';'BPMS:LI21:701:Y';'BPMS:LI21:801:Y';'BPMS:LI21:901:Y'};
pvs = {'FBCK:FB01:TR04:A1HST';'FBCK:FB01:TR04:A2HST';'FBCK:FB01:TR04:A3HST';'FBCK:FB01:TR04:A4HST';'FBCK:FB01:TR04:S1HST';'FBCK:FB01:TR04:S1DESHST';'FBCK:FB01:TR04:S2HST';'FBCK:FB01:TR04:S2DESHST';'FBCK:FB01:TR04:S3HST';'FBCK:FB01:TR04:S3DESHST';'FBCK:FB01:TR04:S4HST';'FBCK:FB01:TR04:S4DESHST';'FBCK:FB01:TR04:M1HST';'FBCK:FB01:TR04:M2HST';'FBCK:FB01:TR04:M3HST';'FBCK:FB01:TR04:M4HST';'FBCK:FB01:TR04:M5HST';'FBCK:FB01:TR04:M6HST';'FBCK:FB01:TR04:M7HST';'FBCK:FB01:TR04:M8HST';'FBCK:FB01:TR04:M9HST';'FBCK:FB01:TR04:M10HST';'FBCK:FB01:TR04:M11HST';'FBCK:FB01:TR04:M12HST';'FBCK:FB01:TR04:M13HST';'FBCK:FB01:TR04:M14HST'};

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