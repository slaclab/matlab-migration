% Setup
devnames = {'XCOR:LTU1:738:BCTRL';'XCOR:LTU1:818:BCTRL';'XCOR:LTU1:878:BCTRL';'YCOR:LTU1:747:BCTRL';'YCOR:LTU1:837:BCTRL';'YCOR:LTU1:857:BCTRL';'X Position';'X Position SP';'X Angle';'X Angle SP';'Y Position';'Y Position SP';'Y Angle';'Y Angle SP';'BPMS:UND1:100:X';'BPMS:UND1:190:X';'BPMS:UND1:290:X';'BPMS:UND1:390:X';'BPMS:UND1:490:X';'BPMS:UND1:590:X';'BPMS:UND1:690:X';'BPMS:UND1:790:X';'BPMS:UND1:890:X';'BPMS:UND1:990:X';'BPMS:UND1:1090:X';'BPMS:UND1:100:Y';'BPMS:UND1:190:Y';'BPMS:UND1:290:Y';'BPMS:UND1:390:Y';'BPMS:UND1:490:Y';'BPMS:UND1:590:Y';'BPMS:UND1:690:Y';'BPMS:UND1:790:Y';'BPMS:UND1:890:Y';'BPMS:UND1:990:Y';'BPMS:UND1:1090:Y'};
pvs = {'FBCK:FB02:TR04:A1HST';'FBCK:FB02:TR04:A2HST';'FBCK:FB02:TR04:A3HST';'FBCK:FB02:TR04:A4HST';'FBCK:FB02:TR04:A5HST';'FBCK:FB02:TR04:A6HST';'FBCK:FB02:TR04:S1HST';'FBCK:FB02:TR04:S1DESHST';'FBCK:FB02:TR04:S2HST';'FBCK:FB02:TR04:S2DESHST';'FBCK:FB02:TR04:S3HST';'FBCK:FB02:TR04:S3DESHST';'FBCK:FB02:TR04:S4HST';'FBCK:FB02:TR04:S4DESHST';'FBCK:FB02:TR04:M1HST';'FBCK:FB02:TR04:M2HST';'FBCK:FB02:TR04:M3HST';'FBCK:FB02:TR04:M4HST';'FBCK:FB02:TR04:M5HST';'FBCK:FB02:TR04:M6HST';'FBCK:FB02:TR04:M7HST';'FBCK:FB02:TR04:M8HST';'FBCK:FB02:TR04:M9HST';'FBCK:FB02:TR04:M10HST';'FBCK:FB02:TR04:M11HST';'FBCK:FB02:TR04:M12HST';'FBCK:FB02:TR04:M13HST';'FBCK:FB02:TR04:M14HST';'FBCK:FB02:TR04:M15HST';'FBCK:FB02:TR04:M16HST';'FBCK:FB02:TR04:M17HST';'FBCK:FB02:TR04:M18HST';'FBCK:FB02:TR04:M19HST';'FBCK:FB02:TR04:M20HST';'FBCK:FB02:TR04:M21HST';'FBCK:FB02:TR04:M22HST'};

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