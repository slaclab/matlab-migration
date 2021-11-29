function param = AD_startImage(param,stepnum)

% Number of cameras
num_cam = param.num_CAM;

% Number of shots to acquire
n_shots = param.n_shot;

% These are the PVs we will us to control the camera
param = camera_DAQ_PVs(param);

% Disable EVR triggering
toggle_camera_state(param,'disable_triggers');

% Set camera saving information
set_DAQ_filepath(param,stepnum);

% Enable saving 
toggle_camera_state(param,'enable_saving');

% Enable PID tagging
lcaPut(param.EVR.evr_Event1CtrlIRQ, 'Enabled');

% Camera ready to take images
toggle_camera_state(param,'start_capture');

% Enable triggers and get the zero point for number of acquired images
toggle_camera_state(param,'enable_triggers');
daq_status(param.cams,2);
pause(0.5);


%==================================================
% Wait for images to be done saving or reach errors;
%==================================================
% Find trigger rate
trig_count = 0;
if param.event_code == 233
    trig_PV = 'EVNT:SYS1:1:POSITRONRATE';
    trig_rate = lcaGet(trig_PV);
elseif param.event_code == 213
    trig_PV = 'EVNT:SYS1:1:PROFRATE';
    trig_rate = lcaGet(trig_PV);
elseif param.event_code == 223
    trig_PV = 'EVNT:SYS1:1:TS5_TE_RATE';
    trig_rate = lcaGet(trig_PV);
elseif param.event_code == 225
    trig_PV = 'EVNT:SYS1:1:TS5_ON_RATE';
    trig_rate = lcaGet(trig_PV);
elseif param.event_code == 229
    trig_PV = 'EVNT:SYS1:1:POSTS5_TE_RATE';
    trig_rate = lcaGet(trig_PV);
elseif param.event_code == 231
    trig_PV = 'EVNT:SYS1:1:POSTS5_ON_RATE';
    trig_rate = lcaGet(trig_PV);
elseif param.event_code == 53
    trig_PV = 'EVNT:SYS1:1:TS5_10_RATE';
    trig_rate = lcaGet(trig_PV);
end

% Loop through each camera
for i=1:num_cam
    % Check # of acquired images vs. # of shots
    n_img_acq = lcaGet(param.DAQPVs.cam_TiffNumCapturedRBV(i));
    n_img_saved = lcaGet(param.DAQPVs.cam_TiffFileNumberRBV(i));
    if n_img_saved == n_shots; continue; end;    
    prev_n_img_acq = -1;
    while n_img_acq < n_shots
        % Check for camera errors or if camera is finished
        c_var = lcaGet(param.DAQPVs.cam_Connection(i));
        t_var = lcaGet(param.DAQPVs.cam_DetectorState(i));
        if (strcmp(t_var{1},'Error') || strcmp(c_var{1},'Disconnect'))
            toggle_camera_state(param,'stop_capture');
            toggle_camera_state(param,'disable_saving');
            toggle_camera_state(param,'enable_triggers');
            warning(['Camera ' param.names{i} ' is down.']);
            if isfield(param,'warnings')
                param.warnings(end+1) = {['Camera ' param.names{i} ' is down.']};
            else
                param.warnings = cell(0,1);
                param.warnings(end+1) = {['Camera ' param.names{i} ' is down.']};
            end
            param.fail = true;
            return;
        end
        % Check to see if there is beam rate
        trig_rate = lcaGet(trig_PV);
        while trig_rate == 0
            choice = questdlg(['The beam rate is zero Hz. '...
                'Would you like to wait until the beam comes back '...
                'and continue or cancel the DAQ?'],...
                'Error: No Beam Rate',...
                'Wait','Terminate','Wait');
            if strcmp(choice,'Wait')
                uiwait(msgbox('Press OK when the beam is ready'));
                trig_rate = lcaGet(trig_PV);
            else
                toggle_camera_state(param,'stop_capture');
                toggle_camera_state(param,'disable_saving');
                toggle_camera_state(param,'enable_triggers');
                warning('User has terminated DAQ due to lack of beam.');
                if isfield(param,'warnings')
                    param.warnings(end+1) = {'User has terminated DAQ due to lack of beam.'};
                else
                    param.warnings = cell(0,1);
                    param.warnings(end+1) = {'User has terminated DAQ due to lack of beam.'};
                end
                param.fail = true;
                return;
            end
        end
        % Check to see if still acquiring
        if n_img_acq == prev_n_img_acq
            warning(['Camera ' param.names{i} ' acquisition timeout.']);
            break;
        end
        prev_n_img_acq = n_img_acq;
        pause(2/trig_rate);
        n_img_acq = lcaGet(param.DAQPVs.cam_TiffNumCapturedRBV(i));
	if n_img_acq < prev_n_img_acq
           break;
        end
        
        % Abort code
        abort_bool = lcaGet('SIOC:SYS1:ML01:AO548');
        if abort_bool == 1
            toggle_camera_state(param,'stop_capture');
            toggle_camera_state(param,'disable_saving');
            toggle_camera_state(param,'enable_triggers');
            param.fail = true;
            warning('User abort inside image acquisition (AD_startImage)');
            if isfield(param,'warnings')
                param.warnings(end+1) = {'User abort inside image acquisition (AD_startImage)'};
            else
                param.warnings = cell(0,1);
                param.warnings(end+1) = {'User abort inside image acquisition (AD_startImage)'};
            end
            return;
        end
    end
    
    % Check # of saved images vs. # of shots
    n_img_saved = lcaGet(param.DAQPVs.cam_TiffFileNumberRBV(i));
    prev_n_img_saved = -1;
    while n_img_saved < n_img_acq
        daq_status(param.cams,3);
        if n_img_saved == prev_n_img_saved
            warning(['Camera ' param.names{i} ' save timeout.']);
            break;
        end
        prev_n_img_saved = n_img_saved;
        pause(0.5);
        n_img_saved = lcaGet(param.DAQPVs.cam_TiffFileNumberRBV(i));
        
        % Abort code
        abort_bool = lcaGet('SIOC:SYS1:ML01:AO548');
        if abort_bool == 1
            toggle_camera_state(param,'stop_capture');
            toggle_camera_state(param,'disable_saving');
            toggle_camera_state(param,'enable_triggers');
            param.fail = true;
            warning('User abort inside image save (AD_startImage)');
            if isfield(param,'warnings')
                param.warnings(end+1) = {'User abort inside image acquisition (AD_startImage)'};
            else
                param.warnings = cell(0,1);
                param.warnings(end+1) = {'User abort inside image acquisition (AD_startImage)'};
            end
            return;
        end
    end
end

toggle_camera_state(param,'stop_capture');
toggle_camera_state(param,'disable_saving');
toggle_camera_state(param,'enable_triggers');
