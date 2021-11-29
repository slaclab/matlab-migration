% Setup
devnames = {'NULL';'NULL';'NULL';'NULL';'NULL';'NULL SP';'NULL';'NULL SP';'NULL';'NULL SP';'NULL';'NULL SP';'NULL';'NULL';'NULL';'NULL'};
pvs = {'FBCK:FB05:TR04:A1HST';'FBCK:FB05:TR04:A2HST';'FBCK:FB05:TR04:A3HST';'FBCK:FB05:TR04:A4HST';'FBCK:FB05:TR04:S1HST';'FBCK:FB05:TR04:S1DESHST';'FBCK:FB05:TR04:S2HST';'FBCK:FB05:TR04:S2DESHST';'FBCK:FB05:TR04:S3HST';'FBCK:FB05:TR04:S3DESHST';'FBCK:FB05:TR04:S4HST';'FBCK:FB05:TR04:S4DESHST';'FBCK:FB05:TR04:M1HST';'FBCK:FB05:TR04:M2HST';'FBCK:FB05:TR04:M3HST';'FBCK:FB05:TR04:M4HST'};

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