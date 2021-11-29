%% run single acquisition

param = E200_Param;
param.experiment = 'E210';
param.camera_config = 49; %EOS
param.n_shot = 10;

% extra data (not needed)
param.save_facet = 0;
param.save_E200 = 0;

% save background
param.save_back = 0;

% comment
param.comt_str = 'Testing for E210';

% run DAQ
[epics_data, aida_data, facet_state, E200_state, filenames, param, cam_back] = E200_DAQ_2013(param);

%% run scan
param = E200_Param;
param.experiment = 'E210';
param.camera_config = 49; %EOS
param.n_shot = 10;

% scan parameters
param.function = @set_dummy; % use this one for testing
%param.function = @set_laser_phase; % use this one to change laser timing

laser_timing_pv = 'OSC:LA20:10:FS_TGT_TIME';
laser_timing_inital_value = lcaGet(laser_timing_pv);

param.start = 531.75;
param.end = 541.75;
param.steps = 3;

% extra data (not needed)
param.save_facet = 0;
param.save_E200 = 0;

% save background
param.save_back = 0;

% comment
param.comt_str = 'Scan test for E210';

% run Scan
E200_gen_scan(param.function, param.start, param.end, param.steps, param);

%% analyze single step data

data_path = '/nas/nas-li20-pm01/E210/2014/20140320/E210_12091/';
matlab_file_name = 'E210_12091_2014-03-20-14-04-16';
image_file_name = 'E210_12091_EOS-03-20-2014-14-04-16';

MATLAB_DATA = load([data_path matlab_file_name]);


%background_struct = MATLAB_DATA.cam_back;
%background_image = background_struct.img; 

[image_data, cam_name, pulse_id] = E200_readImages([data_path image_file_name]);

for i = 1:param.n_shot
    
    imagesc(image_data(:,:,i));
    title(num2str(i));
    pause(0.2);
    
end

%% analyze scan data

data_path = '/nas/nas-li20-pm01/E210/2014/20140320/E210_12092/';
matlab_file_name = 'E210_12091_2014-03-20-14-04-16';
scan_info_file_name = 'E210_12092_scan_info.mat';

load([data_path scan_info_file_name]);

for i=1:length(scan_info);
    image_file_name = scan_info.EOS;

    [image_data, cam_name, pulse_id] = E200_readImages(image_file_name);
    

    for j = 1:param.n_shot
        %image = image_data(:,:,j) - background_image;
        
        imagesc(image_data(:,:,j));
        title(['Step ' num2str(i) ' Shot ' num2str(j)]);
        pause(0.2);

    end

end

%% example background struct
background_struct = profmon_grab('OTRS:LI20:3175');
background_image = background_struct.img;

if background_struct.orientX
    
    background_image = fliplr(background_image);
    
end

if background_struct.orientY
    
    background_image = flipud(background_image);
    
end

    
