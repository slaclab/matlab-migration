function param = FACET_Scan(param)

	if isfield(param,'fcnHandle')
		disp('Running Scan');
		param.scanbool = true;
		
		% Convert variables to make things easier
		PV_start = param.Control_PV_start;
		PV_end   = param.Control_PV_end;
		n_step   = param.n_step;
		
		% Create list of values for function
		param.PV_scan_list = linspace(PV_start,PV_end,n_step);
		
		% The following setup is for 2D scan function
		if isfield(param,'fcnHandle2')
			param.scan2D_bool = true;
			
			PV_start1     = param.Control_PV_start;
			PV_end1       = param.Control_PV_end;
			n_step1       = param.n_step;
			param.n_step1 = n_step1;
				
			PV_start2 = param.Control_PV_start2;
			PV_end2   = param.Control_PV_end2;
			n_step2   = param.n_step2;
			
			n_step             = n_step1*n_step2;
			param.n_step       = n_step;
			param.PV_scan_list = 1:n_step;
			
			param.PV_scan_list1 = linspace(PV_start1,PV_end1,n_step1);
			param.PV_scan_list2 = linspace(PV_start2,PV_end2,n_step2);
			
			[ind1,ind2]        = ind2sub([n_step1 n_step2], 1:n_step);
			param.PV_scan_ind1 = ind1;
			param.PV_scan_ind2 = ind2;
			
			disp(['Scan values for ' char(param.fcnHandle) ' are:']);
			disp(param.PV_scan_list1);
			
			disp(['Scan values for ' char(param.fcnHandle2) ' are:']);
			disp(param.PV_scan_list2);
			
		else
			param.scan2D_bool = false;
			disp('Scan values are:');
			disp(param.PV_scan_list);
			
		end
		
	else
		disp('Running Single Step');
		param.n_step      = 1;
		param.scanbool    = false;
		param.scan2D_bool = false;
	end
end
