% Setup
devnames = {'XCOR:LTU1:488:BCTRL';'XCOR:LTU1:548:BCTRL';'YCOR:LTU1:493:BCTRL';'YCOR:LTU1:593:BCTRL';'X.Pos';'X.Pos SP';'X.Ang';'X.Ang SP';'Y.Pos';'Y.Pos SP';'Y.Ang';'Y.Ang SP';'BPMS:LTU1:620:X';'BPMS:LTU1:640:X';'BPMS:LTU1:660:X';'BPMS:LTU1:680:X';'BPMS:LTU1:720:X';'BPMS:LTU1:730:X';'BPMS:LTU1:740:X';'BPMS:LTU1:750:X';'BPMS:LTU1:760:X';'BPMS:LTU1:770:X';'BPMS:LTU1:620:Y';'BPMS:LTU1:640:Y';'BPMS:LTU1:660:Y';'BPMS:LTU1:680:Y';'BPMS:LTU1:720:Y';'BPMS:LTU1:730:Y';'BPMS:LTU1:740:Y';'BPMS:LTU1:750:Y';'BPMS:LTU1:760:Y';'BPMS:LTU1:770:Y'};
pvs = {'FBCK:FB03:TR01:A1HST';'FBCK:FB03:TR01:A2HST';'FBCK:FB03:TR01:A3HST';'FBCK:FB03:TR01:A4HST';'FBCK:FB03:TR01:S1HST';'FBCK:FB03:TR01:S1DESHST';'FBCK:FB03:TR01:S2HST';'FBCK:FB03:TR01:S2DESHST';'FBCK:FB03:TR01:S3HST';'FBCK:FB03:TR01:S3DESHST';'FBCK:FB03:TR01:S4HST';'FBCK:FB03:TR01:S4DESHST';'FBCK:FB03:TR01:M1HST';'FBCK:FB03:TR01:M2HST';'FBCK:FB03:TR01:M3HST';'FBCK:FB03:TR01:M4HST';'FBCK:FB03:TR01:M5HST';'FBCK:FB03:TR01:M6HST';'FBCK:FB03:TR01:M7HST';'FBCK:FB03:TR01:M8HST';'FBCK:FB03:TR01:M9HST';'FBCK:FB03:TR01:M10HST';'FBCK:FB03:TR01:M11HST';'FBCK:FB03:TR01:M12HST';'FBCK:FB03:TR01:M13HST';'FBCK:FB03:TR01:M14HST';'FBCK:FB03:TR01:M15HST';'FBCK:FB03:TR01:M16HST';'FBCK:FB03:TR01:M17HST';'FBCK:FB03:TR01:M18HST';'FBCK:FB03:TR01:M19HST';'FBCK:FB03:TR01:M20HST'};

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