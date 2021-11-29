function param = are_we_there_yet(param)
% This function checks to see if the camera actually got the commands
% before we start the DAQ

% Set 'multiple' to this number of shots
n_shots = param.n_shot;

% Earlier, we tried setting the camera to multiple, the number of shots to
% n_shots, and the state to acquire. Now lets check
IM_stat = lcaGet(param.DAQPVs.cam_ImageModeRBV);
NI_stat = lcaGet(param.DAQPVs.cam_NumImagesRBV);
DS_stat = lcaGet(param.DAQPVs.cam_DetectorState);

% These cameras are bad
im_bad = ~strcmp('Multiple',IM_stat);
ni_bad = ~(NI_stat == n_shots);
ds_bad = ~strcmp('Acquire',DS_stat);

% Try to force camera into correct state
% crap out after 50 tries
count = 0;
while sum(im_bad) || sum(ni_bad)
    toggle_camera_state(param,'set_multiple',im_bad | ni_bad);
    pause(0.05);
    IM_stat = lcaGet(param.DAQPVs.cam_ImageModeRBV);
    NI_stat = lcaGet(param.DAQPVs.cam_NumImagesRBV);
    im_bad = ~strcmp('Multiple',IM_stat);
    ni_bad = ~(NI_stat == n_shots);
    
    count = count + 1;
    if count > 50
        toggle_camera_state(param,'idle_camera');
        toggle_camera_state(param,'disable_saving');
        toggle_camera_state(param,'set_continuous');
        toggle_camera_state(param,'enable_camera');
        toggle_camera_state(param,'enable_triggers');
        warning(['Could not set camera ' param.names{im_bad} ' to DAQ ready state.']);
        param.fail = true;
        return;
    end        
end

% Try to force camera into correct state
% crap out after 50 tries
count = 0;
while sum(ds_bad)
    toggle_camera_state(param,'enable_camera',ds_bad)
    pause(0.05);
    DS_stat = lcaGet(param.DAQPVs.cam_DetectorState);
    ds_bad = ~strcmp('Acquire',DS_stat);
    count = count + 1;
    if count > 50
        toggle_camera_state(param,'idle_camera');
        toggle_camera_state(param,'disable_saving');
        toggle_camera_state(param,'set_continuous');
        toggle_camera_state(param,'enable_camera');
        toggle_camera_state(param,'enable_triggers');
        warning(['Could not set camera ' param.names{ds_bad} 'to DAQ ready state.']);
        param.fail = true;
        return;
    end
end