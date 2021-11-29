function FACET_Comment(param,savepath)

	comt_str = sprintf([param.comt_str '\n']);
	cam_str  = '';
	for i = 1:numel(param.names)
		if i == numel(param.names)
			cam_str = [cam_str param.names{i}];
		else
			cam_str = [cam_str param.names{i} ', '];
		end
	end

	cam_str  = sprintf([cam_str '\n']);
	DAQ_str  = sprintf(['FACET DAQ ' num2str(param.n_saves) ' for ' param.experiment '.\n']);
	Data_str = sprintf([num2str(param.n_shot) ' shots per step and ' num2str(param.n_step) ' steps.\n']);

	if param.scan2D_bool
		Func_str = sprintf(['2D scan:\n'...
			'\tFirst dimension, of ' char(param.fcnHandle) ' from '...
			num2str(param.Control_PV_start) ' to ' num2str(param.Control_PV_end) ...
			' with ' num2str(param.n_step1) ' steps.\n'...
			'\tSecond dimension, of ' char(param.fcnHandle2) ' from '...
			num2str(param.Control_PV_start2) ' to ' num2str(param.Control_PV_end2) ...
			' with ' num2str(param.n_step2) ' steps.\n']);
	elseif isfield(param,'fcnHandle')
		Func_str = sprintf(['Scan of ' char(param.fcnHandle) ' from ' num2str(param.Control_PV_start)...
			' to ' num2str(param.Control_PV_end) '\n']);
	else
		Func_str = sprintf(['Simple DAQ' '\n']);
	end

	Path_str = sprintf(['Path: ' savepath '\n' '\n']);
    
    info_str = sprintf(['| NAME | SAVE | REQ | UID ' '\n']);
    for i = 1:numel(param.names)
        mat_line   = sprintf(['| ' param.names{i} ' | ' num2str(param.cam_info(i,1)) ' | ' num2str(param.cam_info(i,2)) ' | ' num2str(param.cam_info(i,3)) ' ' '\n']);
        info_str = [info_str mat_line];
    end
    info_str = sprintf([info_str '\n' '\n']);
    
    
    if isfield(param,'warnings')
        warn_str = sprintf(['Warnings:' '\n']);
        for i = 1:numel(param.warnings)
            warn_str = [warn_str sprintf(param.warnings{i}) '\n'];
        end
        warn_str = sprintf([warn_str '\n']);
    else
        warn_str = sprintf(['GREAT SUCCESS!' '\n']);
    end
    
	Comment  = [comt_str cam_str DAQ_str Data_str Func_str Path_str info_str warn_str];

	fprintf(Comment);

	if param.set_print2elog; FACET_DAQ2LOG(Comment,param); end;
end
