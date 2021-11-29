% Setup
devnames = {'XCOR:LI25:202:BCTRL';'XCOR:LI25:602:BCTRL';'YCOR:LI24:900:BCTRL';'YCOR:LI25:503:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:LI25:701:X';'BPMS:LI25:801:X';'BPMS:LI25:901:X';'BPMS:LI26:201:X';'BPMS:LI26:301:X';'BPMS:LI26:401:X';'BPMS:LI26:501:X';'BPMS:LI26:601:X';'BPMS:LI26:701:X';'BPMS:LI26:801:X';'BPMS:LI26:901:X';'BPMS:LI27:301:X';'BPMS:LI27:401:X';'BPMS:LI27:701:X';'BPMS:LI27:801:X';'BPMS:LI25:701:Y';'BPMS:LI25:801:Y';'BPMS:LI25:901:Y';'BPMS:LI26:201:Y';'BPMS:LI26:301:Y';'BPMS:LI26:401:Y';'BPMS:LI26:501:Y';'BPMS:LI26:601:Y';'BPMS:LI26:701:Y';'BPMS:LI26:801:Y';'BPMS:LI26:901:Y';'BPMS:LI27:301:Y';'BPMS:LI27:401:Y';'BPMS:LI27:701:Y';'BPMS:LI27:801:Y'};
pvs = {'FBCK:FB02:TR01:A1HST';'FBCK:FB02:TR01:A2HST';'FBCK:FB02:TR01:A3HST';'FBCK:FB02:TR01:A4HST';'FBCK:FB02:TR01:S1HST';'FBCK:FB02:TR01:S1DESHST';'FBCK:FB02:TR01:S2HST';'FBCK:FB02:TR01:S2DESHST';'FBCK:FB02:TR01:S3HST';'FBCK:FB02:TR01:S3DESHST';'FBCK:FB02:TR01:S4HST';'FBCK:FB02:TR01:S4DESHST';'FBCK:FB02:TR01:M1HST';'FBCK:FB02:TR01:M2HST';'FBCK:FB02:TR01:M3HST';'FBCK:FB02:TR01:M4HST';'FBCK:FB02:TR01:M5HST';'FBCK:FB02:TR01:M6HST';'FBCK:FB02:TR01:M7HST';'FBCK:FB02:TR01:M8HST';'FBCK:FB02:TR01:M9HST';'FBCK:FB02:TR01:M10HST';'FBCK:FB02:TR01:M11HST';'FBCK:FB02:TR01:M12HST';'FBCK:FB02:TR01:M13HST';'FBCK:FB02:TR01:M14HST';'FBCK:FB02:TR01:M15HST';'FBCK:FB02:TR01:M16HST';'FBCK:FB02:TR01:M17HST';'FBCK:FB02:TR01:M18HST';'FBCK:FB02:TR01:M19HST';'FBCK:FB02:TR01:M20HST';'FBCK:FB02:TR01:M21HST';'FBCK:FB02:TR01:M22HST';'FBCK:FB02:TR01:M23HST';'FBCK:FB02:TR01:M24HST';'FBCK:FB02:TR01:M25HST';'FBCK:FB02:TR01:M26HST';'FBCK:FB02:TR01:M27HST';'FBCK:FB02:TR01:M28HST';'FBCK:FB02:TR01:M29HST';'FBCK:FB02:TR01:M30HST'};

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