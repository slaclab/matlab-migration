% Setup
devnames = {'XCOR:LI28:202:BCTRL';'XCOR:LI28:602:BCTRL';'YCOR:LI27:900:BCTRL';'YCOR:LI28:503:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:LI28:601:X';'BPMS:LI28:701:X';'BPMS:LI28:801:X';'BPMS:LI28:901:X';'BPMS:LI29:201:X';'BPMS:LI29:301:X';'BPMS:LI29:401:X';'BPMS:LI29:501:X';'BPMS:LI28:601:Y';'BPMS:LI28:701:Y';'BPMS:LI28:801:Y';'BPMS:LI28:901:Y';'BPMS:LI29:201:Y';'BPMS:LI29:301:Y';'BPMS:LI29:401:Y';'BPMS:LI29:501:Y'};
pvs = {'FBCK:FB02:TR02:A1HST';'FBCK:FB02:TR02:A2HST';'FBCK:FB02:TR02:A3HST';'FBCK:FB02:TR02:A4HST';'FBCK:FB02:TR02:S1HST';'FBCK:FB02:TR02:S1DESHST';'FBCK:FB02:TR02:S2HST';'FBCK:FB02:TR02:S2DESHST';'FBCK:FB02:TR02:S3HST';'FBCK:FB02:TR02:S3DESHST';'FBCK:FB02:TR02:S4HST';'FBCK:FB02:TR02:S4DESHST';'FBCK:FB02:TR02:M1HST';'FBCK:FB02:TR02:M2HST';'FBCK:FB02:TR02:M3HST';'FBCK:FB02:TR02:M4HST';'FBCK:FB02:TR02:M5HST';'FBCK:FB02:TR02:M6HST';'FBCK:FB02:TR02:M7HST';'FBCK:FB02:TR02:M8HST';'FBCK:FB02:TR02:M9HST';'FBCK:FB02:TR02:M10HST';'FBCK:FB02:TR02:M11HST';'FBCK:FB02:TR02:M12HST';'FBCK:FB02:TR02:M13HST';'FBCK:FB02:TR02:M14HST';'FBCK:FB02:TR02:M15HST';'FBCK:FB02:TR02:M16HST'};

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