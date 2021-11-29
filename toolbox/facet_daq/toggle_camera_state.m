function toggle_camera_state(param,state_string,index_cam)

if nargin < 3
    index_cam = true(param.num_CAM,1);
end

if strcmp(state_string,'disable_triggers')
    lcaPut(param.EVR.evr_Event1CtrlOut0, 'Disabled');
    lcaPut(param.EVR.evr_Event1CtrlOut1, 'Disabled');
    lcaPut(param.EVR.evr_Event1CtrlOut2, 'Disabled');
end

if strcmp(state_string,'enable_triggers')
    lcaPut(param.EVR.evr_Event1CtrlOut0, 'Enabled');
    lcaPut(param.EVR.evr_Event1CtrlOut1, 'Enabled');
    lcaPut(param.EVR.evr_Event1CtrlOut2, 'Enabled');
end

if strcmp(state_string,'idle_camera')
    lcaPutNoWait(param.DAQPVs.cam_Acq(index_cam), 'Idle');
end

if strcmp(state_string,'enable_camera')
    lcaPutNoWait(param.DAQPVs.cam_Acq(index_cam), 'Acquire');
end

if strcmp(state_string,'enable_saving')
    lcaPut(param.DAQPVs.cam_TiffFileNumber(index_cam),'0');
    lcaPut(param.DAQPVs.cam_TiffCallbacks(index_cam), 'Enable');
    lcaPut(param.DAQPVs.cam_TiffAutoSave(index_cam), 'Yes');
    lcaPut(param.DAQPVs.cam_TiffAutoIncrement(index_cam), 'Yes');
    lcaPut(param.DAQPVs.cam_ROIEnableCallbacks(index_cam), '1');
    lcaPut(param.DAQPVs.cam_TiffSetPort(index_cam), '2');
    lcaPut(param.DAQPVs.cam_TiffFileWriteMode(index_cam), '1');
    lcaPut(param.DAQPVs.cam_TiffNumCapture(index_cam), param.n_shot);
    lcaPut(param.DAQPVs.cam_DataType(index_cam), '1');
end

if strcmp(state_string,'start_capture')
    lcaPutNoWait(param.DAQPVs.cam_TiffCapture, '1');
end

if strcmp(state_string,'stop_capture')
    lcaPutNoWait(param.DAQPVs.cam_TiffCapture, '0');
end

if strcmp(state_string,'disable_saving')
    lcaPut(param.DAQPVs.cam_TiffCallbacks(index_cam), 'Disable');
end

if strcmp(state_string,'set_multiple')
    lcaPut(param.DAQPVs.cam_ImageMode(index_cam), 'Multiple');
    lcaPut(param.DAQPVs.cam_NumImages(index_cam), param.n_shot);
end

if strcmp(state_string,'set_continuous')
    lcaPut(param.DAQPVs.cam_ImageMode(index_cam), 'Continuous');
end
    
