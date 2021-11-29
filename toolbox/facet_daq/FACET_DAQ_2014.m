%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FACET DAQ for 2014                                                      %
%                                                                         %
%                                                                         %
% S. Corde, S. Gessner, J. Frederico, Z. Oven                             %
% 3/13/14                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = FACET_DAQ_2014(arg_param)
    % =========================================
    % Initialize the Abort code to 0
    % =========================================
    % Make sure the E200/FACET abort PV is set to 0 ( so it doesn't abort)
    lcaPut('SIOC:SYS1:ML01:AO548',0);


    % =========================================
    % Test that we are on the right machine
    % =========================================
    [id,hostname] = system('hostname');
    if ~strncmp(char(hostname),'facet-srv20', 11)
        error('FACET DAQ must be run from facet-srv20. You are on %s', hostname);
    end

    % =========================================
    % Load DAQ parameters -- You MUST supply
    % arg_param
    % =========================================
    param = arg_param;

    % =========================================
    % Test and initialize scan or single DAQ
    % =========================================
    param = FACET_Scan(param);
    
    % =========================================
    % Check camera status
    % =========================================
    disp(['Checking camera status ' datestr(clock,'HH:MM:SS')]);
    param = FACET_cameras(param);
    param = Check_Cam_Status(param);
    param = FACET_EVRs(param);
    param = FACET_ROIs(param);
    daq_status(param.cams,1);
    
    % =========================================
    % Create Data Path on NAS drive 
    % =========================================
    disp(['Creating directory structure ' datestr(clock,'HH:MM:SS')]);
    param = FACET_save_path(param);

    % =========================================
    % Acquire non-BSA data 
    % =========================================
    disp(['Getting non-BSA data ' datestr(clock,'HH:MM:SS')]);
    [E200_state, param] = FACET_getE200(param);
    
    % =========================================
    % Acquire camera background
    % We always acquire background. But if 
    % save_back = 0, we don't stop beam.
    % =========================================    
    disp(['Getting camera backgrounds ' datestr(clock,'HH:MM:SS')]);
    [cam_back, param] = FACET_takeBackground(param);

    % =========================================
    % Start DAQ Loop 
    % =========================================
    
    % Initialize array for steps
    epics_data=cell(1,param.n_step);
    lcaPut('SIOC:SYS1:ML01:AO549',param.n_step);
    for i=1:param.n_step
        lcaPut('SIOC:SYS1:ML01:AO550',i);
        if param.scanbool
            % 2D scan code
            if param.scan2D_bool
                disp(['Changing scan function ' char(param.fcnHandle) ' to: ' num2str(param.PV_scan_list1(param.PV_scan_ind1(i))) ]);
                param.fcnHandle(param.PV_scan_list1(param.PV_scan_ind1(i)));
                disp(['Finished changing scan function ' char(param.fcnHandle)]);
                
                disp(['Changing scan function ' char(param.fcnHandle2) ' to: ' num2str(param.PV_scan_list2(param.PV_scan_ind2(i))) ]);
                param.fcnHandle2(param.PV_scan_list2(param.PV_scan_ind2(i)));
                disp(['Finished changing scan function ' char(param.fcnHandle2)]);
                
            % 1D scan code    
            else
                disp(['Changing scan function to: ' num2str(param.PV_scan_list(i)) ]);
                param.fcnHandle(param.PV_scan_list(i));
                disp('Finished changing scan function.');
            end
        end

        disp(['Starting EPICS acquistion ' datestr(clock,'HH:MM:SS')]);
        [myeDefNumber, param] = E200_startEPICS(param);

        disp(['Starting Image acquistion ' datestr(clock,'HH:MM:SS')]);
        param = AD_startImage(param,i);

        disp(['Finished Image acquistion ' datestr(clock,'HH:MM:SS')]);
        [epics_data{i}, param] = E200_getEPICS(myeDefNumber,param);
        
        % Abort code
        abort_bool = lcaGet('SIOC:SYS1:ML01:AO548');
        if abort_bool == 1
            disp('Executing User Abort...');
            if isfield(param,'warnings')
                param.warnings(end+1) = {'User abort in main DAQ loop.'};
            else
                param.warnings = cell(0,1);
                param.warnings(end+1) = {'User abort in main DAQ loop.'};
            end
            param.fail = true;
        end
        
        
        if isfield(param,'fail')
            warning(['DAQ failed during image acquisition on step ' num2str(i) '. Saving data before quitting.']);
            if isfield(param,'warnings')
                param.warnings(end+1) = {['DAQ failed during image acquisition on step ' num2str(i) '.']};
            else
                param.warnings = cell(0,1);
                param.warnings(end+1) = {['DAQ failed during image acquisition on step ' num2str(i) '.']};
            end
            param.n_step = i;
            break;
        end
        

    end
    
    % Reset the abort code to 0, so you don't have to restart the DAQ.
    lcaPut('SIOC:SYS1:ML01:AO548',0);
    
    % =========================================
    % Quality Control: Check Saved Images 
    % =========================================
    daq_status(param.cams,4);
    disp(['Performing data quality check ' datestr(clock,'HH:MM:SS')]);
    [QC_INFO, param] = FACET_DAQ_QC(param,epics_data);
    
    % =========================================
    % Save Matlab Data File to NAS
    % =========================================
    disp(['Saving data ' datestr(clock,'HH:MM:SS')]);
    [data,savepath] = FACET_Save(param,QC_INFO,epics_data,E200_state,cam_back);
    
    % =========================================
    % Write Data Summary Comment to eLog 
    % =========================================
    FACET_Comment(param,savepath);
    daq_status(param.cams,0);
    lcaPut('SIOC:SYS1:ML01:AO550',0);
end
