function par = E200_cmosBackground(par)

CMOS_PVs = par.cam_CMOS(:,2);

% Make sure acquisition is off
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),0);
pause(0.5);

% The following is how you name file path
for i = 1:par.num_CMOS
    fp = zeros(1,256);
    %par.cmos_path{i} = '/tmp/cmos_tests/Dec10/test1/';
    pathascii = double(par.cmos_path{i});
    n_el = length(pathascii);
    fp(1:n_el) = pathascii;
    lcaPutSmart([CMOS_PVs{i} ':TIFF:FilePath'],fp);
end

% Check to make sure file path is valid
ext = lcaGetSmart(strcat(CMOS_PVs,':TIFF:FilePathExists_RBV'));
for i = 1:par.num_CMOS
    if ~strcmp(ext(i),'Yes')
        error(['File path: ' par.cmos_path{i} ' does not exist. NAS might not be mounted.']);
    end
end

% The following is how you name files:
fn = zeros(1,256);
filename = 'data_background';
fileascii = double(filename);
n_el = length(fileascii);
fn(1:n_el) = fileascii;
for i = 1:par.num_CMOS
    lcaPutSmart([CMOS_PVs{i} ':TIFF:FileName'],fn);
end

% Set acquistion mode to 'single'
lcaPutSmart(strcat(CMOS_PVs,':ImageMode'),0);
lcaPutSmart(strcat(CMOS_PVs,':NumImages'),1);

% Set trigger mode to 'auto'
lcaPutSmart(strcat(CMOS_PVs,':TriggerMode'),0);

% This turns the image saving plugin on and off
lcaPutSmart(strcat(CMOS_PVs,':TIFF:EnableCallbacks'),1); % zero off, one on

% Take one shot
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),1);
pause(1);
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),0);
pause(0.5);

% This turns the image saving plugin on and off
lcaPutSmart(strcat(CMOS_PVs,':TIFF:EnableCallbacks'),0); % zero off, one on

% Set trigger mode to 'external'
lcaPutSmart(strcat(CMOS_PVs,':TriggerMode'),2);

% Set acquistion mode to 'continuous'
lcaPutSmart(strcat(CMOS_PVs,':ImageMode'),2);

% Store background file info
for i = 1:par.num_CMOS
    file_double = lcaGetSmart([CMOS_PVs{i} ':TIFF:FullFileName_RBV']);
    inds = find(file_double);
    par.cmos_bg_files{i} = char(file_double(inds));
    
    CMOS_NAME = par.cam_CMOS{i,1};
    
    par.cmos_bg_struct.(CMOS_NAME).ROI_X = lcaGetSmart([CMOS_PVs{i} ':ROI:MinX_RBV']);
    par.cmos_bg_struct.(CMOS_NAME).ROI_Y = lcaGetSmart([CMOS_PVs{i} ':ROI:MinY_RBV']);
    par.cmos_bg_struct.(CMOS_NAME).ROI_XNP = lcaGetSmart([CMOS_PVs{i} ':ROI:ArraySizeX_RBV']);
    par.cmos_bg_struct.(CMOS_NAME).ROI_YNP = lcaGetSmart([CMOS_PVs{i} ':ROI:ArraySizeY_RBV']);
    par.cmos_bg_struct.(CMOS_NAME).BIN_X = lcaGetSmart([CMOS_PVs{i} ':ROI:BinX_RBV']);
    par.cmos_bg_struct.(CMOS_NAME).BIN_Y = lcaGetSmart([CMOS_PVs{i} ':ROI:BinX_RBV']);
    par.cmos_bg_struct.(CMOS_NAME).RESOLUTION = lcaGetSmart([CMOS_PVs{i} ':RESOLUTION']);
    par.cmos_bg_struct.(CMOS_NAME).X_ORIENT = lcaGetSmart([CMOS_PVs{i} ':X_ORIENT']);
    par.cmos_bg_struct.(CMOS_NAME).Y_ORIENT = lcaGetSmart([CMOS_PVs{i} ':Y_ORIENT']);
    
end

% Resume acquistion
lcaPutNoWait(strcat(CMOS_PVs,':Acquisition'),0);
pause(0.5);