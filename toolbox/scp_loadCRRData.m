function data = scp_loadCRRData(file, getLABL, stripempty)
% DATA = SCP_LOADCRRDATA(FILE, GETLABL, STRIPEMPTY) loads data from .DAT
% files acquired and saved with the SCP correlation plot utility.  
%
% Input Arguments:
%   FILE:       The complete path and file name in the VMS filesystem.  For FACET
%               correlation plot data, this will typically take the form:
%               'physics5_data/facet/DDMMMYY/FILENAME.DAT'.
%   GETLABL:    [Opt] Flag to return the LABL secondary in the .desc field,
%               if it exists.  Defaults to true.
%   STRIPEMPTY: [Opt] Flag to strip out unused entries in the correlation 
%               plot table, those entries that are labeled 'ZERO' or
%               'SAMP'.  If false all 160 entries are returned. Defaults to true. 
%
% Output arguments:
%   DATA (struct):  I x J x N arrays where I = number of secondary variable
%   steps, J = number of primary variable steps, N = total number of step
%   and sample variables.  
%       NAME:   Step variable names may be SLC database variables, 'KNOB'
%               or 'TIME'.  Sample variable names may be SLC database
%               variables, EPICS PVs or, if STRIPEMPTY is 0, 'SAMP' or
%               'ZERO'.
%       ISCTRL: Flag (1 or 0) indicating whether this member of the array
%               is a primary or secondary step variable.
%       DESC:   Descriptive text for the device in NAME.  For 'KNOB'
%               variables, this is the name of the .MKB file.
%       VAL:    Data values.
%       VALSTD: Std deviation of data values, where they exist (e.g. with
%               BPM averaging turned on)
%       ID:     "Coordinate ID" in the correlation plot data.  Ordinate of
%               data acquisition sequence.
%
% Compatibility: Version 7 and higher
%
% Author: Nate Lipkowitz, SLAC

if nargin < 2, getLABL = 0; end
if nargin < 3, stripempty = 1; end

dirs = textscan(file, '%s', 'delimiter', '/'); dirs = dirs{1};
filename = dirs(end);
tfilename = strcat('/tmp/', filename);
cmd = strcat({'curl -G http://134.79.176.15/'}, file, {' -o '}, tfilename);
result = '';
try
    [status, result] = system(char(cmd));
catch
    disp('Error downloading file!');
    disp(result);
    return
end

% open the file
fid = fopen(char(tfilename), 'r');
header = cell(1);

% figure out the header format - look for the first data block
found = 0; ix = 0;
while ~found
    ix = ix + 1;
    header(ix) = cellstr(fgetl(fid));
    found = ~isempty(strfind(header{ix}, 'CO-ORD I.D.'));
end
header_size = ix - 2;

% decide if this is 1d or 2d
if header_size == 5
    dims = 2;
elseif header_size == 3
    dims = 1;
else
    disp(sprintf('Header parse error - header is %d lines.', header_size))
    return
end

% flag for knob variables and get sizes
isknob  = false(1, dims);
istime  = false(1, dims);
strt    = zeros(1, dims);
steps   = ones(1, dims);
ssize   = zeros(1, dims);
device  = cell(1, dims);
desc    = cell(1, dims);
%range = struct('var1', [], 'var2', []);

for ix = 1:dims
    % extract the appropriate header line into ws-delimited words
    words = textscan(char(header(2*ix)), '%s'); words = words{1};
    % if 1st word is KNOB, this is a knob
    switch char(words(1))
        case 'KNOB'
            % handles KNOB variables
            isknob(ix) = 1;
            device(ix) = words(1);
            desc(ix) = words(2);
            if ix == 2 && ~isknob(1) && ~istime(1)
                % secondary step variable knobs are moronic
                words_old = textscan(char(header(2)), '%s'); words_old = words_old{1};
                knob_idx = strfind(words_old, 'MKB');
                desc_idx = find(~cellfun(@isempty, knob_idx));
                desc(ix) = words_old(desc_idx);
            end
        case 'STEP'
            % handles TIME variables
            istime(ix) = 1;
            device(ix) = words(4);
        otherwise
            % normal devices prim:micr:unit:secn
            device(ix) = strcat(words(1), ':', words(2), ':', words(3), ':', words(4));
            if getLABL
                % get the device LABL
                labl = lcaGetSmart(strcat(words(2), ':', words(1), ':', words(3), ':LABL'));
                if iscell(labl)
                    charlabl = char(labl);
                    commas = charlabl == ',';  % LABL has a comma at the beginning, strip it
                    desc(ix) = cellstr(charlabl(~commas));
                end
            end
            
    end 
    

    if istime(ix)
        % set start time = 0
        strt(ix) = 0;

        % find steps
        steps_word = strmatch('STEPS=', words);
        steps(ix) = sscanf(char(words(steps_word)), 'STEPS=%d');

        % find stepsize (delay)
        ssize_word = strmatch('DELAY=', words);
        ssize_cell = textscan(char(words(ssize_word)), 'DELAY=%n');
        if ~isempty(ssize_cell{1}), ssize(ix) = ssize_cell{1}; end
    else
        % find start
        strt_word = strmatch('STRT=', words);
        strt(ix) = sscanf(char(words(strt_word)), 'STRT=%f');

        % find steps
        steps_word = strmatch('STEPS=', words);
        steps(ix) = sscanf(char(words(steps_word + 1)), '%d');

        % find stepsize
        ssize_word = strmatch('SIZE=', words);
        ssize_cell = textscan(char(words(ssize_word)), 'SIZE=%n');
        if ~isempty(ssize_cell{1}), ssize(ix) = ssize_cell{1}; end
    end

    % retro-generate the scan ranges
    range.(strcat('var', num2str(ix))) = linspace(strt(ix), strt(ix)+(ssize(ix)*(steps(ix)-1)), steps(ix));
end

% n is the total number of scan points size(primary) * size(secondary)
n = prod(steps);

% go back to start of file
fseek(fid, 0, 'bof');
% read the 'v2.1' shit
d = fgetl(fid);

% start reading data blocks
filedata = zeros(1, n, 4);
names = cell(1);
ix = 0;
offset = 42;   % the "sampled device" string starts at character 42
while ~feof(fid)  
    ix = ix + 1;
    data_name = textscan(fid, '%s', 1, 'delimiter', '\n', 'HeaderLines', 2*dims);
    char_name = char(data_name{1}(1));
    names(ix,1) = cellstr(char_name(offset:end));
    filedata(ix,:,:) = cell2mat(textscan(fid, '%n %n %n %n', 'HeaderLines', 2, 'Whitespace', ' *\b\t'));
end
m = ix;
fclose(fid);

% parse the sampled device names
column_names = cell(size(names));
column_desc = cell(size(names));
empty = ones(size(names));

for ix = 1:numel(names)
    words = textscan(char(names(ix)), '%s');  words = words{1};
    if numel(words) > 1
        descstr = char(words(end));
        namestr = sprintf('%s ', words{1:end-1});
    else
        descstr = char(words(1));
        namestr = char(words(1));
    end
    column_names(ix) = cellstr(deblank(namestr));
    column_desc(ix) = cellstr(deblank(descstr));
end

empty = strcmp(column_names, 'ZERO') | strcmp(column_names, 'SAMP');

% filedata is now m x n x 4, where:
% m = number of sample variables (should be 160)
% n = total number of scan points (secn settings x primary settings)
% 4 = (coordinate ID) (primary variable setpoint) (sample variable data) (std dev of sample variable)

dataID  = shiftdim(reshape(filedata(:,:,1), m, [], steps(1)), 1);
ctrlVal  = shiftdim(reshape(filedata(:,:,2), m, [], steps(1)), 1);
scandata  = shiftdim(reshape(filedata(:,:,3), m, [], steps(1)), 1);
scandataStd  = shiftdim(reshape(filedata(:,:,4), m, [], steps(1)), 1);

% replace NaNs in dataStd with zeros
scandataStd(isnan(scandataStd)) = 0;

% special case to deal with stupid primary ranges with secondary knobs -
% extract from ctrlVal (should all be the same, use 1,1)
if dims == 2 && isknob(2)
    range.var1 = ctrlVal(1,:,1);
end

% clear "empty" flags if stripempty is not specified
if ~stripempty
    empty = zeros(size(empty));
end

% strip MKB name nonsense out of knobs
for ix = 1:dims
    if isknob(ix)
        knob_name = textscan(char(desc(ix)), '(COMMON$ROOT:[MKB]%s', 'delimiter', '.');
        if isempty(char(knob_name{1}))
            knob_name = textscan(char(desc(ix)), '([MKB]%s', 'delimiter', '.');
        end
        desc(ix) = cellstr(sprintf('%s.MKB', char(knob_name{1})));
    end
end

% shuffle things around to get them in the right format for output
% this is a really dumb way to do it.

ctrl_vals(:,:,1:dims) = ctrlVal(:,:,1:dims);
if dims == 2
    ctrl_vals(:,:,2) = repmat(range.var2', [1 steps(1)]);
end

if dims == 1
    steps = [steps 1];
end
steps = circshift(steps, [1 1]);

samplenames = column_names(~empty);
sampledesc = column_desc(~empty);
samp_val(:,:,:) = scandata(:,:,~empty);
samp_valStd(:,:,:) = scandataStd(:,:,~empty);
samp_id(:,:,:) = dataID(:,:,~empty);

data.name =     cell([steps (dims+numel(samplenames))]);
data.desc =     cell(size(data.name));
data.val =      zeros(size(data.name));
data.valStd =   zeros(size(data.name));
data.id =       zeros(size(data.name));
data.isCtrl =   false(size(data.name));

for ix = 1:steps(1)
    for jx = 1:steps(2)
        for kx = 1:(dims + numel(column_names(~empty)))
            if kx <= dims
                data.name(ix, jx, kx) = device(kx);
                data.desc(ix, jx, kx) = desc(kx);
                data.val(ix, jx, kx) = ctrl_vals(ix, jx, kx);
                data.id(ix, jx, kx) = samp_id(ix, jx, kx);
                data.isCtrl(ix, jx, kx) = 1;
            else
                data.name(ix, jx, kx) = samplenames(kx-dims);
                data.desc(ix, jx, kx) = sampledesc(kx-dims);
                data.val(ix, jx, kx) = samp_val(ix, jx, kx-dims);
                data.valStd(ix, jx, kx) = samp_valStd(ix, jx, kx-dims);
                data.id(ix, jx, kx) = samp_id(ix, jx, kx-dims);
            end
        end
    end
end
