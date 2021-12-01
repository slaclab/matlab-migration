function dataslice=fetch_bsa_slice(timeRange, PVs, varargin)
% Get all data for specified PVs in the time window
% NOTE: As of 9/9/2021, this script only functions on development servers where /nfs/slac/g/bsd
% is mounted. Script does not function on production.
%
% Inputs:
%  'timeRange': cell array of windowstart and windowend
%       -'windowstart': start time of window in format 'YYYY-mm-DD HH:MM:SS' in
%       Pacific time
%       -'windowend': end time of window in format 'YYYY-mm-DD HH:MM:SS' in
%       Pacific time
%  'PVs': Cell array of full PV names or any starting portion of PV names
%  (i.e. {BPMS} will collect data from all BPMS).
%
%
% OPTIONAL ARGUMENTS:
%  'savefile': file to which to save the data, this will save in the same
%  directory in which the script is run unless otherwise specified
%       -Note that the output files will be quite large, and could fail to save if
%       there is insufficient disk sapce
%  'sparseFactor': defaulted to 1, if higher, will lower the frequency of data
%  (i.e. sparsity of 2 will take every other data point, sparsity of 3
%  every third, etc.)
%  'beamline': which beamline from which to pull data. 'CUH' for hard line,
%  'CUS' for soft line. Default will look at all PVs and all files.
%  'batch': default to 0, 1 will run data pull function with batch processing
%  'verbose': default to 0, set to 1 to show progress messages (will not
%  suppress memory estimate or number of files)
%
% OUTPUTS:
%  'dataslice': a struct with fields:
%    -'ROOT_NAMES': giving the PVs read
%    -'the_matrix': a ROOT_NAMES x total points matrix of the extracted data.
%    -'isPV': a ROOT_NAMES x number of files logical matrix describing
%    which files contained data for which PVs
%
% Example:
% data=fetch_bsa_slice({'2021-06-05 00:00:00','2021-06-05 12:00:00'},{'BPMS'},'beamline','CUH','batch',1)
%  -Returns data for all BPMS on the HXR line from June 5th 2021 at
%  midnight to June 5th 2021 at noon using batch processing.

    %default options
    optsdef=struct( ...
        'savefile','None', ...
        'sparseFactor',1, ...
        'beamline',[], ...
        'batch', 0, ...
        'verbose',0 ...
        );

    %parse optional arguments
    opts=util_parseOptions(varargin{:},optsdef);

    %Some testing info
    %timenow=datestr(now,'mm/DD/YYYY HH:MM:SS');

    %Get the list of files in the time window
    datadir="/nfs/slac/g/bsd/BSAService/data/";
    windowstart=timeRange{1};
    windowend=timeRange{2};
    [files,posixstart,posixend,estdata,hsratio]=get_files(windowstart,windowend,datadir,opts.beamline);   
    files=string(files);
    numfiles=length(files);
    if opts.verbose, fprintf('Number of files: %d \n',numfiles);end

    %Get the list of PVs to look for by loading an example file
    if isempty(opts.beamline)
        rootnameref='LCLS.BSA.rootnames';
    else
        rootnameref=['LCLS.',char(opts.beamline),'.BSA.rootnames'];
    end
    rootnames=meme_names('tag',[rootnameref],'sort','z');
    PVnames=strrep(rootnames,':','_');
    PVs=strrep(string(PVs),':','_');
    if contains(PVs,'all')
        PVlist=PVnames;
    else
        PVlist=PVnames(contains(PVnames,PVs));
    end
    numPVs=length(PVlist);
    PVlist=[{'Time'};PVlist];

    %Project amount of data to be imported and how much time it will take
    %This approximated by the averaged data/second during testing times the
    %amount of time being sampled
    projectedGbytes=get_projecteddata(estdata,posixstart,posixend,numPVs+1,hsratio,numfiles)/(opts.sparseFactor*10^9);
    if opts.verbose, fprintf('Estimated total data: %.2f GB \n',projectedGbytes);end
    
    
    %Initialize variables for processing
    numpoints=zeros(1,numfiles);
    isPV=cell(1,numfiles);
    numbytes=0;
    timingdata=zeros(numfiles,3);   
    dataholder=cell(1,numfiles);

    function linear_processing()
        %Iterate through files to pull out PV data
        for file_idx=1:length(files)
            vals=cell(1,length(PVlist));
            datastruct=cell2struct(vals,PVlist,2);
            isPVfile=false(numPVs+1,1);
            file=get_path(files(file_idx),datadir);
            if opts.verbose==2, fprintf('Loading file: %s \n', file); end
            try
                secondsPastEpoch=h5read(file,'/secondsPastEpoch');
                isPVfile(1)=true;
            catch
                if opts.verbose==2, disp('File Empty'); end
                isPV{file_idx}=isPVfile;
                continue
            end
            nanoseconds=h5read(file,'/nanoseconds');
            time=double(secondsPastEpoch)+double(nanoseconds)*10^-9;
            start_idx=1;
            end_idx=length(time);
            %Capture correct time window for edge files
            if file_idx==1 && length(files)~=1
                start_idx=end_idx-sum(time>(posixstart+3600))+1;
            elseif file_idx==1 && length(files)==1
                start_idx=end_idx-sum(time>(posixstart+3600))+1;
                end_idx=sum(time<(posixend));        
            elseif file_idx==length(files)
                end_idx=sum(time<(posixend));
            end
            indices=[start_idx:opts.sparseFactor:end_idx];
            if opts.verbose==2, disp('starting PV load'); end
            datastruct.Time=time(indices);
            readPVs=0;
            PVt=tic;
            for PV_idx=2:length(PVlist)
                PV=PVlist{PV_idx};
                try
                    PV_val=h5read(file,['/',PV]);
                    datastruct.(PV)=PV_val(indices);
                    isPVfile(PV_idx)=true;
                    readPVs=readPVs+1;
                catch
                    PV_val=ones(1,length(indices))*NaN;
                    datastruct.(PV)=PV_val;
                    if opts.verbose==2, fprintf("PV: %s not in file. Setting value to NaN \n",PV); end
                    continue
                end
            end
            PVtime=toc(PVt);
            dataholder{file_idx}=datastruct;
            isPV{file_idx}=isPVfile;
            numpoints(file_idx)=length(indices);
            amtdata=length(datastruct.Time);
            if opts.verbose==2, fprintf('%.4f seconds, %d data points \n',PVtime,amtdata); end
            numbytes=amtdata*(numPVs+1)*8;
            if opts.verbose==2, disp('File Processed'); end
            timingdata(file_idx,:)=[PVtime,amtdata,readPVs];
        end
    end
    
    function batch_processing()
        parfor (file_idx=1:length(files),min(numfiles,12))
            filet=tic;
            vals=cell(1,length(PVlist));
            datastruct=cell2struct(vals,PVlist,2);
            isPVfile=false(numPVs+1,1);
            file=get_path(files(file_idx),datadir);
            if opts.verbose==2, fprintf('Loading file: %s \n', file); end
            try
                secondsPastEpoch=h5read(file,'/secondsPastEpoch');
                
                isPVfile(1)=true;
            catch
                if opts.verbose==2, disp('File Empty'); end
                isPV{file_idx}=isPVfile;
                continue
            end
            nanoseconds=h5read(file,'/nanoseconds');
            time=double(secondsPastEpoch)+double(nanoseconds)*10^-9;
            start_idx=1;
            end_idx=length(time);
            %Capture correct time window for edge files
            if file_idx==1 && length(files)~=1
                start_idx=end_idx-sum(time>(posixstart+3600))+1;
            elseif file_idx==1 && length(files)==1
                start_idx=end_idx-sum(time>(posixstart+3600))+1;
                end_idx=sum(time<(posixend));        
            elseif file_idx==length(files)
                end_idx=sum(time<(posixend));
            end
            indices=[start_idx:opts.sparseFactor:end_idx];
            datastruct.Time=time(indices);
            readPVs=0;
            PVt=tic;
            for PV_idx=2:length(PVlist)
                PV=PVlist{PV_idx};
                try
                    singlepv=tic;
                    PV_val=h5read(file,['/',PV]);
                    pvread=toc(singlepv)
                    datastruct.(PV)=PV_val(indices);
                    isPVfile(PV_idx)=true;
                    readPVs=readPVs+1;
                catch
                    PV_val=ones(1,length(indices))*NaN;
                    datastruct.(PV)=PV_val;
                    if opts.verbose==2, fprintf("PV: %s not in file. Setting value to NaN \n",PV); end
                    continue
                end
            end
            dataholder{file_idx}=datastruct;
            isPV{file_idx}=isPVfile;
            numpoints(file_idx)=length(indices);
            PVtime=toc(PVt);
            amtdata=length(datastruct.Time);
            numbytes=amtdata*(numPVs+1)*8;
            %disp('File Processed')
            filetime=toc(filet);
            if opts.verbose==2, fprintf('Read file %d in %.2f seconds, %d datapoints \n',file_idx,filetime,amtdata); end
            timingdata(file_idx,:)=[PVtime,amtdata,readPVs];
        end
    end


    if opts.batch
        batch_processing();
    else
        linear_processing();
    end
    
    %convert cell array of data structs to data matrix
    dataholder=dataholder(~cellfun('isempty',dataholder));
    numfilesread=length(dataholder);
    if numfilesread==0
        disp('No files found in time range')
        dataslice=[];
    else
        the_matrix=cell2mat(reshape(struct2cell(cell2mat(dataholder)),numPVs+1,numfilesread));
        the_matrix=reshape(the_matrix,length(PVlist),sum(numpoints));
        clear datastruct;
        data.ROOT_NAME=[{'Time'};rootnames(contains(strrep(rootnames,':','_'),PVlist))];
        data.the_matrix=the_matrix;
        data.isPV=cell2mat(isPV);
        clear the_matrix;
        numbytes=sum(numpoints)*(numPVs+1)*8;
        dataslice=data;
    end

    %Try to save the data. If there's an error, catch it and continue on to
    %save test data
    if ~strcmp(opts.savefile,'None')
        saved='Yes';
        try
            save(opts.savefile,'data','-v7.3');
        catch ME
            disp('Error Message:')
            disp(ME.message)
            disp(ME.cause)
            disp(ME.Correction)
            saved='No';
        end
        fprintf('Saved? %s \n',saved)
    end
    if opts.verbose, disp('Done'); end
end                      
    
    
function [files,posixstart,posixend,estdata,hsratio]=get_files(windowstart,windowend,datadir,beamline)
%Get file list by walking through appropriate year, month, and date
%directories
    windowstart=strrep(windowstart,'/','-');
    windowend=strrep(windowend,'/','-');
    [start_year, start_month, start_date, start_time]=get_timeinfo(windowstart);
    [end_year, end_month, end_date, end_time]=get_timeinfo(windowend);


    tzdelstart=8*3600;
    tzdelend=8*3600;
    try
        if isdst(datetime(windowstart,'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','America/Los_Angeles'))
            tzdelstart=7*3600;
        end
    catch
        tzdelstart=7*3600;
    end
    try
        if isdst(datetime(windowend,'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','America/Los_Angeles'))
            tzdelend=7*3600;
        end
    catch
        tzdelend=7*3600;
    end
    posixend=get_posix(end_year, end_month, end_date, end_time,1+tzdelend);
    posixstart=get_posix(start_year,start_month,start_date,start_time,-3600+tzdelstart);
    
    files=[];
    estdata=0; %Keep track of estimated uncompressed data per file
    hxrfiles=0;
    sxrfiles=0;
    posixlast=posixtime(datetime(datestr(now,'mm/DD/YYYY HH:MM:SS'),'InputFormat','MM/dd/yyyy HH:mm:ss'));
    for year=str2double(start_year):str2double(end_year)
        year_dir=fullfile(datadir,string(year));
        month_dirs=dir(year_dir);
        try
            month_dirs=extractfield(month_dirs,'name');
        catch
            break
        end
        month_dirs=month_dirs(3:end);
        if (isempty(files)) && (year==str2double(start_year))
            which_months=str2double(month_dirs)>=str2double(start_month);
            month_dirs=month_dirs(which_months);
        end
        for month_idx=1:length(month_dirs)
            month=month_dirs{month_idx};
            posix_time=get_posix(string(year),month,'01','00:00:00',0);
            if posix_time<posixend
                month_dir=fullfile(year_dir,month);
                date_dirs=dir(month_dir);
                try
                    date_dirs=extractfield(date_dirs,'name');
                catch
                    break
                end
                date_dirs=date_dirs(3:end);
                if (isempty(files)) && (year==str2double(start_year)) && (str2double(month)==str2double(start_month))
                    which_dates=str2double(date_dirs)>=str2double(start_date);
                    date_dirs=date_dirs(which_dates);
                end
                for date_idx=1:length(date_dirs)
                    date=date_dirs{date_idx};
                    posix_time=get_posix(string(year),month,date,'00:00:00',0);
                    if posix_time<posixend
                        date_dir=fullfile(month_dir,date);
                        filelist=dir(date_dir+'/*.h5');
                        try
                            filelist=extractfield(filelist,'name');
                        catch
                            break
                        end
                        for file_idx=1:length(filelist)
                            file=filelist{file_idx};
                            time=strcat(file(17:18),':',file(19:20),':',file(21:22));
                            posix_time=get_posix(string(year),month,date,time,0);
                            posixdel=max(3600,posix_time-posixlast);
                            posixlast=posix_time;
                            posix_time=posix_time-posixdel;
                            if (posix_time<=posixend) && (posix_time>=posixstart)
                                if isempty(beamline) || beamline(end)==file(4)
                                    if strcmp(file(4),'H'), hxrfiles=hxrfiles+1; end
                                    if strcmp(file(4),'S'), sxrfiles=sxrfiles+1; end
                                    files=vertcat(files,file);
                                    if posix_time>1613109600 && posix_time<1614689384
                                        estdata=estdata+1000000;
                                    else
                                        estdata=estdata+432000;
                                    end
                                end
                            end
                            %Add up data points based on amount data
                            %per file before and after different
                            %capture rates
                            
                        end
                    end
                end
            end
        end
    end
    hsratio=min(hxrfiles,sxrfiles)/max(hxrfiles,sxrfiles);
end

function [year,month,date,time]=get_timeinfo(time_in)
%Extract timing info from user input
    year=time_in(1:4);
    month=time_in(6:7);
    date=time_in(9:10);
    time=time_in(12:end);
end

function posix_time=get_posix(year,month,date,time,offset)
%Convert user input to posixtime
    timestring=strcat(year,'-',month,'-',date,'T',time);
    posix_time=offset+posixtime(datetime(timestring,'InputFormat','yyyy-MM-dd''T''HH:mm:ss'));
end


function path=get_path(filename,rootdir)
%Get full file path from file name
    path_year=extractBetween(filename,8,11);
    path_month=extractBetween(filename,12,13);
    path_date=extractBetween(filename,14,15);
    posix_time=get_posix(path_year,path_month,path_date,'00:00:00',0);
    %Need to figure out which rootdir it's in. The branch is at 03/11/2021
%     if posix_time>1615420900  
%         rootdir=datadirs(2);
%     else
%         rootdir=datadirs(1);
%     end
    path=fullfile(rootdir,path_year,path_month,path_date,filename);
end


function numbytes=get_projecteddata(estdata,posix_start,posix_end,numPVs,hsratio,numfiles)
%Get projected number of bytes based on estimated capture rates
%Projection is the lesser of estimates based on number of files, and size
%of time window
    fileproj=estdata*8*numPVs;
    highratestart=1613109600;
    highrateend=1614689384;
    if posix_end<highratestart || posix_start>highrateend
        timeproj=(posix_end-posix_start+3600)*120*8*numPVs;
    elseif posix_start>highratestart && posix_end<highrateend
        timeproj=(posix_end-posix_start+3600)*280*8*numPVs;
    elseif posix_start>highratestart && posix_end>highrateend
        thighfreq=highrateend-posix_start+3600; %posixtime of end of low capture data run
        tlowfreq=posix_end-highrateend;
        timeproj=(tlowfreq*120+thighfreq*280)*8*numPVs;
    else
        tlowfreq=highratestart-posix_start+3600; %posixtime of end of low capture data run
        thighfreq=posix_end-highratestart;
        timeproj=(tlowfreq*120+thighfreq*280)*8*numPVs;
    end
    if mod(numfiles,2)==1 && hsratio~=0
        numbytes=fileproj;
    else
        numbytes=min(fileproj,timeproj*(1+hsratio));
    end
end
    