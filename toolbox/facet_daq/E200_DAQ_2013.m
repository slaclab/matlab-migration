%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E200 DAQ for FY2013                                                     %
%                                                                         %
%                                                                         %
% S. Corde, S. Gessner                                                    %
% 3/08/13                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [epics_data, aida_data, facet_state, E200_state, filenames, param, cam_back] = E200_DAQ_2013(arg_param)

% Test that we are on the right machine
[id,hostname] = system('hostname');
if ~strncmp(char(hostname),'facet-srv20', 11)
    error('E200 DAQ must be run from facet-srv20. You are on %s', hostname);
end

% Load DAQ parameters
if nargin>0; param = arg_param; else param = E200_Param(); end;

% Test to make sure there will not be an AIDA timeout
facet_beamrate = lcaGetSmart('EVNT:SYS1:1:BEAMRATE');
if facet_beamrate == 0
    warning('No beam to FACET dump');
elseif facet_beamrate == 1 && param.aida_daq == 1 && param.n_shot > 20
    error('Too many shots per sample. AIDA will timeout.');
end

% Load profile monitors
param = E200_Cam_Configs(param);

% Set Path
param = E200_path_diary(param);

if(param.save_facet); facet_state = facet_getMachine(); else facet_state = 0; end;

if(param.save_E200); 
    try
        E200_state = E200_getMachine(); 
    catch
        disp('Failed to get non BSA EPICS PVs. Check list for bad PVs.');
        E200_state = 0;
    end
    
else
    E200_state = 0;
end

if(param.save_back); [cam_back, param] = E200_takeBackground(param); else cam_back = 0; end;

if(param.run_cmos)
    disp(['Prepping CMOS ' datestr(clock,'HH:MM:SS')]);
    param = prep_cmos(param);
end

disp(['Starting EPICS acquistion ' datestr(clock,'HH:MM:SS')]);
myeDefNumber = E200_startEPICS();

disp(['Starting Image acquistion ' datestr(clock,'HH:MM:SS')]);
param = E200_startImage(param);
if(param.run_cmos); start_cmos(param); end;
tic;
if param.aida_daq
    disp(['Starting AIDA acquistion ' datestr(clock,'HH:MM:SS')]);
    E200_AIDA_list;
    aida_data = E200_getAIDA(param.bpmd, AIDA_list, param.n_shot);
    disp(['AIDA acquistion finished at ' datestr(clock,'HH:MM:SS')]);
else
    aida_data = 0;
end
toc;
% Check DAQ Status
stat_list = strcat(param.cam_UNIQ(:,2),':STATUS_DAQ');
if toc < 1
    while size(stat_list,1)>1; stat_list(lcaGetSmart(stat_list) == 2) = []; end;
    while lcaGetSmart(stat_list) ~= 2; end;
else
    while size(stat_list,1)>1; stat_list(lcaGetSmart(stat_list) == 2 | lcaGetSmart(stat_list) == 0) = []; end;
    while lcaGetSmart(stat_list) == 1; end;
end
if(param.run_cmos); disable_cmos(param); end;
disp(['Image acquistion complete ' datestr(clock,'HH:MM:SS')]);

% Add the correct timestamp to the save_name
param.timestamp = clock;
param.year = num2str(param.timestamp(1), '%.4d');
param.month = num2str(param.timestamp(2), '%.2d');
param.day = num2str(param.timestamp(3), '%.2d');
param.hour = num2str(param.timestamp(4), '%.2d');
param.minute = num2str(param.timestamp(5), '%.2d');
param.second = num2str(floor(param.timestamp(6)), '%.2d');
param.save_name = [param.experiment '_' num2str(lcaGetSmart('SIOC:SYS1:ML02:AO001')) '_' param.year '-' param.month '-' param.day '-' param.hour '-' param.minute '-' param.second];

% Get EPICS Data
epics_data = E200_getEPICS(myeDefNumber);
disp(['EPICS acquistion complete ' datestr(clock,'HH:MM:SS')]);

% Defining Comment
samp_str = sprintf([num2str(param.n_sample) ' samples of ' num2str(param.n_shot) ' shots.\n']);
cams_str = sprintf('\nCamera config #%d.\n', param.camera_config);
for i = 1:param.num_NAS; data_str{i} = sprintf(['Data folder is\n' param.save_path{i} '.\n']); end;
data_str2 = sprintf(['File name is ' param.save_name '.\n']);
Comment  = [samp_str, sprintf(param.comt_str), cams_str];
for i = 1:param.num_NAS; Comment = [Comment, data_str{i}]; end;
Comment = [Comment, data_str2];

% Save EPICS data, the state of the facet machine and the E200 state
save([param.save_path{1} '/' param.save_name], 'Comment', 'param', 'epics_data', 'aida_data', 'facet_state', 'E200_state', 'cam_back');

fprintf(Comment);
if param.set_print2elog; E200_print2elog(Comment); end;

if param.wait
    % Check Save Status
    while sum(lcaGetSmart(strcat(param.cam_UNIQ(:,2),':STATUS_DAQ'))) ~= 0; end;
    disp(['Image saving complete ' datestr(clock,'HH:MM:SS')]);

    % Disable DAQ when finished
    lcaPut(strcat(param.cam_UNIQ(:,2),':ENABLE_DAQ'),0);
    
    % Get filenames for image files
    filenames = E200_getFilenames(param);
else
    filenames = 0;
end

save([param.save_path{1} '/' param.save_name '_filenames'], 'filenames');

diary off; 

end
