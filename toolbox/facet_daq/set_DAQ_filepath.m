function set_DAQ_filepath(param,stepnum)

camPVs = param.cams;
num_cam = numel(camPVs);

filePrefix = param.names;
file_format = '%s%s_%4.4d.tif';
data_string = ['_data_step' sprintf('%02d',stepnum)];

% Set filepath format
ff = zeros(1,256);
formatASCII = double(file_format);
n_el = length(formatASCII);
ff(1:n_el) = formatASCII;
lcaPut(param.DAQPVs.cam_TiffFileFormat, ff);

% Set filepath for saved data (path must already exist)
for i=1:numel(filePrefix)
    
    fp = zeros(1,256);
    path = param.cam_path{i};
    if ~exist(path,'dir')
        mkdir(path);
    end
    pathASCII = double(path);
    n_el = length(pathASCII);
    fp(1:n_el) = pathASCII;
    lcaPut(param.DAQPVs.cam_TiffFilePath{i}, fp);
end

% Check that all paths exists
for i=1:num_cam
    ext = lcaGet(param.DAQPVs.cam_TiffFilePathExists(i));
    if (~strcmp(ext,'Yes'))
      error(['File path: ' path ' does not exist.']);
    end
end

% Set name for data images
for i=1:num_cam
    fn = zeros(1,256);
    filename = [filePrefix{i}, data_string];
    fileASCII = double(filename);
    n_el = length(fileASCII);
    fn(1:n_el) = fileASCII;
    lcaPut(param.DAQPVs.cam_TiffFileName(i), fn);
    
    % set time stamp event
    if strcmp(camPVs{i},'CMOS:LI20:3490')
        lcaPut('IOC:LI20:CS01:TSS_SETEC',param.event_code);
    elseif strcmp(camPVs{i},'CMOS:LI20:3492')
        lcaPut('IOC:LI20:CS03:TSS_SETEC',param.event_code);
    else
        lcaPut(param.DAQPVs.cam_TSS_SETEC(i),param.event_code);
    end
end