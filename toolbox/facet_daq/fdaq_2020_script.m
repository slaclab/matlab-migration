%% Information about the DAQ is stored in the structure "par"

par.experiment = 'TEST';

list_of_cameras = {'CAMR:LT10:200';... % C1F
                   'CAMR:LT10:380';... % CIRISF
                   'CAMR:LT10:500';... % OscOut
                   'CAMR:LT10:600';... % RegOut
                   'CAMR:LT10:700';... % ComprOut
                   'CAMR:LT10:800';... % MPAOut
                   'CAMR:LT10:900'};   % VCCF

list_of_trigger = {'CAMR:LT10:200:TCTL';... % C1F
                   'CAMR:LT10:450:TCTL';... % CIRISF
                   'TRIG:IN10:PM01:5:TCTL';... % OscOut
                   'TRIG:IN10:PM01:5:TCTL';... % RegOut
                   'TRIG:IN10:PM01:5:TCTL';... % ComprOut
                   'TRIG:IN10:PM01:5:TCTL';... % MPAOut
                   'CAMR:LT10:LS04:TCTL'}; % VCCF             

%cam_ind = 1:2;
%cam_ind = 7;
cam_ind = [1,2,7];
par.cams = list_of_cameras(cam_ind);
par.trig = list_of_trigger(cam_ind);
           
par.n_shot = 100;
par.num_CAM = numel(par.cams);

%% These next steps create file directories on the NAS and gather PVs
par.names = lcaGet(strcat(par.cams, ':NAME'));
par = FACET_save_path(par);
par = camera_DAQ_PVs(par);

%% Disable triggers while we set up cameras for saving

lcaPut(par.trig,0); % 0 = off

%% setup saving
lcaPut(par.DAQPVs.cam_TiffFileNumber,0);
lcaPut(par.DAQPVs.cam_TiffCallbacks,1);
lcaPut(par.DAQPVs.cam_TiffAutoSave,1);
lcaPut(par.DAQPVs.cam_TiffAutoIncrement,1);
lcaPut(par.DAQPVs.cam_ROIEnableCallbacks,1);
lcaPut(par.DAQPVs.cam_TiffSetPort,2);
lcaPut(par.DAQPVs.cam_TiffFileWriteMode,1);
lcaPut(par.DAQPVs.cam_TiffNumCapture,par.n_shot);
lcaPut(par.DAQPVs.cam_DataType,1);

%% tell the servers where to put the data

set_DAQ_filepath(par,0);

%% Ready to savce

lcaPutSmart(par.DAQPVs.cam_TiffCapture,1);


%% start triggers
lcaPut(par.trig,1); % 1 = on

%% Once we have the data, disable saving

lcaPutSmart(par.DAQPVs.cam_TiffCapture, 0);
lcaPutSmart(par.DAQPVs.cam_TiffCallbacks, 0);

%% The next steps are to check if the data is good

data = struct;
data.daq_parameters = par;

for i = 1:par.num_CAM
    
    imgs = dir([par.cam_path{i} '/*.tif']);
    n_imgs = numel(imgs);
    if n_imgs < par.n_shot
        warning([par.names{i} ' didn"t save all the shots']);
    end
    
    % Record the location of the images in the data structure
    data.images.(par.names{i}).loc = strcat([par.cam_path{i} '/'], {imgs.name}');
    
    pid_list = zeros(par.n_shot,1);
    for j = 1:par.n_shot
        tiff_header = tiff_read_header(data.images.(par.names{i}).loc{j});
        pid_list(j) = bitand(tiff_header.private_65003, hex2dec('0001FFFF'));
    end
    data.images.(par.names{i}).pid = pid_list;
end

save(['/nas/nas-li20-pm00/' par.tail_path '/' par.experiment '_' num2str(par.n_saves,'%05d') '.mat'],'data');