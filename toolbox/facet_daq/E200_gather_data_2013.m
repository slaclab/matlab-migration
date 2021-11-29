function data=E200_gather_data_2013(pathstr,varargin)
% E200_gather_data_2013 Gathers data from saved .mat files into one structure in memory
%   DATA = E200_gather_data_2013(PATHSTR) gathers data from PATHSTR.
%   DATA = E200_gather_data_2013(PATHSTR,SCAN) gathers data from PATHSTR and assigns it a scan number of SCAN.
%
% Inputs:
%	PATHSTR:	Absolute path to the file to be loaded.  Must be *scan_info.mat or *filenames.mat.
%
% Outputs:
%	DATA:		E200 data structure

	if nargin>1
		options=varargin{1};
	else
		options.scan_step=1;
		options.path_prefix='';
	end

	% ================================================
	% Get path and filename
	% ================================================
	[dir_beg,dir_mid,Filename]=get_valid_filename(pathstr);
	% Path to file
	Pathname=fullfile(dir_beg,dir_mid)
	% rootpath=get_rootpath(Pathname);
	rootpath = get_remoteprefix();

	% ================================================
	% Determine which file type is being used.
	% ================================================
	settype='none';
	searchlist = {{'scan_info.mat','scan'},{'filenames.mat','daq'}};
	% searchlist = {{'scan_info.mat','scan'}};
	if (Filename~=0)
		for searchstr=searchlist
			if ~isempty(strfind(Filename,searchstr{1}{1}))
				settype=searchstr{1}{2};
			end
		end
	else
		error('File not valid.');
	end

	% ================================================
	% Get param so I can get experiment so I can initialize paths
	% Also, load files needed later
	% ================================================
	switch settype
	case 'scan'
		% Load scan_info file
		load(pathstr);

		% Find one step file
		stepfiles=dir(fullfile(Pathname,'*_filenames.mat'))
		steppath=fullfile(Pathname,stepfiles(1).name);

		% Load one step file
		load([steppath(1:end-14) '.mat']);

	case 'daq'
		% Load file
		load(fullfile(Pathname,[Filename(1:end-14) '.mat']));
		load(pathstr);
	end
	% param now exists!
	experimentstr=param.experiment;

	% ================================================
	% Strip experiment from filename
	% ================================================
	str=Filename(size(experimentstr,2)+1:end);
	% Find underscores
	underscore_ind=strfind(str,'_');
	% Extract number between underscores
	datasetstr=str(underscore_ind(1)+1:underscore_ind(2)-1);
	basedataset=[experimentstr '_' datasetstr];
	
	pathstr=fullfile(Pathname,[basedataset '_files']);
	create_file_tree(pathstr);

	% ================================================
	% Initialize data structure
	% ================================================
	data         = struct();
	data.VersionInfo = struct('Version',0.2);

	data.raw          = struct();
	data.raw.images   = struct();
	data.raw.scalars  = struct();
	data.raw.vectors  = struct();
	data.raw.arrays   = struct();
	data.raw.metadata = struct();

	data.processed   = data.raw;

	data.user=struct();

	% ================================================
	% Type-specific Initialization
	% ================================================
	switch settype
	case 'scan'
		% If cmos_bg_struct exists, pass it along.
		if isfield(param,'cmos_bg_struct')
			options.cmos_bg_struct = param.cmos_bg_struct;
		end
	
		n_steps=size(scan_info,2);

		% Load first step
		options.scan_step=1;
		loadthis = fullfile(Pathname,stepfiles(1).name)
		data=E200_gather_data_2013(loadthis,options);
		scan_info(1)
		data=add_scan_info(data,scan_info(1));

		% Load subsequent steps
		for i=2:n_steps
			steppath=fullfile(Pathname,stepfiles(i).name);
			options.scan_step=i;
			data_append=E200_gather_data_2013(steppath,options);
			data_append=add_scan_info(data_append,scan_info(i));
			
			data=E200_concat(data,data_append);
		end
		data.raw.metadata.n_steps = n_steps;

	case 'daq'

		% ================================================
		% Convert epics_data to a list
		% ================================================
		n_e_shots	  = size(epics_data,2);
		epics_data_mat = cell2mat(squeeze(struct2cell(epics_data)));

		% ================================================
		% Assume image list will be as long as requested
		% ================================================
		n_i_shots=param.n_shot;
		% Check that number of shots saved is equal to requested.  Adjust if necessary.
		[temp,i_PID]=readImagesHeader([rootpath filenames.(param.cams{1,1}) '.header']);
		n_i_shots_saved=length(i_PID);
		if n_i_shots~=n_i_shots_saved
			h=warndlg(['Shots requested: ' num2str(n_i_shots) ' Shots saved: ' num2str(n_i_shots_saved) ]);
			uiwait(h);
			n_i_shots=n_i_shots_saved;
		end
		i_scan_step=ones(1,n_i_shots)*options.scan_step;

		% ================================================
		% Generate epics-type UID
		% ================================================
		bool        = strcmp('PATT_SYS1_1_PULSEID',fieldnames(epics_data));
		e_PID       = epics_data_mat(bool,:);
		e_scan_step = ones(1,n_e_shots)*options.scan_step;
		% setstr     = str2num(param.save_name(1:10));
		dataset     = str2num(datasetstr);
		e_dataset   = dataset * ones(1,n_e_shots);
		UIDs        = assign_UID(e_PID,e_scan_step,e_dataset);
		e_UID       = UIDs.epics_UID;

		% ================================================
		% Put in epics_data
		% ================================================
		names=fieldnames(epics_data);
		for i=1:size(names,1)
			data.raw.scalars.(names{i})=add_raw(epics_data_mat(i,:),e_UID,'EPICS');
		end

		% ================================================
		% Save these things to the struct
		% ================================================
		data.raw.scalars.step_num	   = add_raw(e_scan_step,e_UID,'EPICS');
		data.raw.scalars.set_num = add_raw(e_dataset, e_UID, 'EPICS');

		% ================================================
		% add AIDA data
		% ================================================
		if param.aida_daq
		    data = add_aida(data,aida_data,options);
		end
        
		% ================================================
		% Extract and save backgrounds 
		% if they exist(consistency)
		% ================================================
		if isstruct(cam_back)
			% Save backgrounds to file
			camstr=fieldnames(cam_back);
			for i=1:size(camstr,1)
				[filestr,structstr]=cams2filenames(camstr{i},param.timestamp);
				bgpathstr=bgpath(experimentstr,structstr,dataset,options.scan_step,Pathname);
				% Save if backgrounds don't exist
				if ~( exist(bgpathstr)==2 )
					display('Saving background file...');
					img=cam_back.(structstr).img;
					[bgpathdir,temp,temp]=fileparts(bgpathstr);
					mkdir(bgpathdir)
					save(bgpathstr,'img');
				end
				cam_back.(camstr{i})=rmfield(cam_back.(camstr{i}),'img');
			end
		end

		% ================================================
		% Extract E200_state and facet_state if 
		% they exist(consistency)
		% ================================================
		if isstruct(E200_state)
			data.raw.metadata.E200_state=add_raw(cell_construct(E200_state,1,n_e_shots), e_UID,'EPICS');
			fields=fieldnames(E200_state);
			for i=1:length(fields)
				curfield=fields{i};
				data.raw.scalars.(curfield)=add_raw(cell_construct(E200_state.(curfield),1,n_e_shots), e_UID,'EPICS');
			end
		end
		if isstruct(facet_state)
		    data.raw.metadata.facet_state=add_raw(cell_construct(facet_state,1,n_e_shots), e_UID,'EPICS');
		end

		% ================================================
		% Initialize data.raw.images.(name)
		% ================================================
		% If param.cam_UNIQ exists, use it.
		if isfield(param,'cam_UNIQ')
			camnames = param.cam_UNIQ;
		else
			camnames = param.cams;
		end

		format=cell_construct('bin',1,n_i_shots);
		for i=1:size(camnames,1)
			str=camnames{i,1};
			[filestr,structstr]=cams2filenames(str,param.timestamp);
			% Load image headers and get UIDs
			[temp,i_PID]=readImagesHeader([rootpath filenames.(filestr) '.header']);
			option.IMAGE_PID=i_PID';
			option.IMAGE_SCANSTEP=i_scan_step;
			UIDs		= assign_UID(e_PID,e_scan_step,e_dataset,option);
			i_UID = UIDs.image_UID;

			data.raw.images.(structstr)=struct();
			data.raw.images.(structstr)=replace_field(data.raw.images.(structstr),...
							'dat'			, cell_construct(filenames.(filestr),1,n_i_shots),...
							'format'		, format, ...
							'isfile'		, ones(1,n_i_shots), ...
							'bin_index'		, [1:n_i_shots], ...
							'UID'			, i_UID, ...
                            				'PID'                   , i_PID',...
							'IDtype'		, 'Image');
			% ================================================
			% Add the remaining info from cam_back
			% ================================================
			if isstruct(cam_back)
				data.raw.images.(structstr)=replace_field(data.raw.images.(structstr),...
							'background_dat'	, cell_construct(...
												bgpath(experimentstr,structstr,datasetstr,options.scan_step,dir_mid),...
												1,n_i_shots),...
							'background_format'	, cell_construct('mat',1,n_i_shots));
				names=fieldnames(cam_back.(str));
				for j=1:size(names,1)
					toadd=cam_back.(str).(names{j});
					if iscell(toadd)
						data.raw.images.(structstr).(names{j})=cell_construct(toadd,1,n_i_shots);
					else
						data.raw.images.(structstr).(names{j})=ones(1,n_i_shots)*toadd;
					end
				end
			end
		end

		% ================================================
		% Add CMOS data
		% ================================================
		data = add_CMOS(data,param,e_PID,e_scan_step,e_dataset,options);

		% ================================================
		% Add metadata
		% ================================================
		data.raw.metadata.param=add_raw(cell_construct(param,1,n_e_shots), e_UID,'EPICS');
		
	case 'none'
		error('Filetype not understood.');
	end
	
	% ================================================
	% All file initializations
	% ================================================
	if ~strcmp(settype,'none')
		% Change to correct settype.
		data.raw.metadata.settype=settype;
	end
end

function out=bgpath(experiment,imgname,set,step,basepath)
	display(['Basepath: ' basepath])
	out=['Background_' imgname '_set' num2str(set) '_step' num2str(step) '.mat'];
	out=fullfile(basepath,[experiment '_' num2str(set) '_files'],'raw','images',imgname,'backgrounds',out);
	% [outpath,name,ext]=fileparts(out);
	% [stat,msg,msgid]=mkdir(outpath);
end

function data=add_scan_info(data,scan_info)
	UID=data.raw.scalars.step_num.UID;
	size_UID = size(UID,2);
	if iscell(scan_info(1).Control_PV_name)
		Control_PV_name = scan_info(1).Control_PV_name;
	else
		Control_PV_name = {scan_info(1).Control_PV_name};
	end
	data=add_step_info(data,Control_PV_name,scan_info.Control_PV);
	data.raw.metadata.scan_info=add_raw(cell_construct(scan_info(1),1,size_UID),UID,'EPICS');
end
