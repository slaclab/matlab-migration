function model = madmodel( request )
%% MADMODEL runs MAD on the LCLS lattice definition

% REQUEST is an optionally supplied structure that may be used to override
% configuration parameters of the run. 
%
% Usage:
% memecommon                      - Define constants TYPE_DESIGN & EXTANT
% runconfig.type=TYPE_DESIGN;
% model=madmodel(runconfig);      - Run MAD on the design optics
% modelplot(model,{2,7});         - Plot betx and bety of design.
%
% runconfig.type=TYPE_EXTANT
% model2=madmodel(runconfig)     - Run MAD with device settings as
%                                  they are in the existing accelerator.
% modelplot(model,{2,7},model2)  - Plot design and extant.
%
% 
% TODO:
% Convert from copying the mad8 and xsifs to a working dir and then
% publishing to an output dir, to just using one working dir for source and
% output.
% --------------------------------------------------------------------------
%% Includes
memecommon;

%% Utility annonymous functions
% Indexes of quads in 2d char array of element types such as K array returned by
% xtff file reading functions.
quadis=@(modelK) find(strcmp('QUAD',modelK));
% Stemplot quad K1s of data from xtff file reading functions. Eg 
stemplotK1s=@(S,P,K) stem(S(quadis(K)),P(quadis(K),2));


%% Initialization
persistent reinit;
persistent sessiondir;
persistent nominal;

% Construct MAD source filenames.
[madcmdfile_path,madcmdfile_body,madcmdfile_ext]=fileparts(MADCMDFILE_URL);
madcmdfile_fname=strcat(madcmdfile_body,madcmdfile_ext);
madcmdfile_fname_wpatch=strcat(madcmdfile_body,MADCMSFILE_WITHPATCHFILE_SUFFIX,madcmdfile_ext);

% Default model tracking. These may be overridden by 'request' input.
beamlineId=BEAMLINE_LCLS;  % Formal line id
type=TYPE_DESIGN;
rundescription=BEAMLINE_DESCRIPTIONS{beamlineId};

% Set defaults
clean=false;
reinit=true;
retrack=false;
ics=[];
cmdfile=MADCMDFILE_URL;
xsiffiles=MADXSIFFILE_URLS;
tapefiles=NOMINALTWISSTAPE_URLS;
if ( nargin==1 )
    if ( isfield(request,'reinit') && isfield(request,'retrack') && ...
            and( request.reinit, request.retrack))
        error( cantreinitandretrack, cantreinitandretrackmsg);
    end
    if ( isfield(request,'reinit') )
        if ( request.reinit == false ) 
            if (isempty(sessiondir)) 
                warning(mustreinit, mustreinitmsg); % If theres no session dir must reinit
                reinit=true;
                retrack=false; % Must override any retrack request since must reinit.
            else
                reinit=false;
            end
        end
    end
    if ( isfield(request,'retrack') )
        if ( request.retrack == true && isempty(request.trackdir) )
            warning(cantretrack, cantretrackmsg); % rinit is true by default at this point
        else
            retrack=request.retrack;    
        end
        
        if ( retrack ) 
            reinit = false;
            trackdir = request.trackdir;
            cd(trackdir);
        end
    end
    
    % Initalial conditions, array [ALFX, ALFY, BETX, BETY].
    if ( isfield(request,'ics') )
        ics=request.ics;
    end
    if (isfield(request,'energy'))
        energy=request.energy;
    end
    if (isfield(request,'type'))
        type=request.type;
    end
    if (isfield(request,'beamline'))
        beamlineId=request.beamline;
    end
    if (isfield(request,'description'))
        rundescription=request.description;
    end
    % Does user want to override default commandfile
    if (isfield(request,'commandfile'))
       cmdfile=request.commandfile;
    end
    % Does user want to override default datafiles
    if (isfield(request,'xsiffiles'))
       xsiffiles=request.xsiffiles;
    end
     if (isfield(request,'tapefiles'))
       tapefiles=request.tapefiles;
    end
    % if (isfield(request,'tnum'))
    %   tnum=request.tnum;
    % end
%     if (isfield(request,'tempDir'))
%         tempdir=request.tempDir;
%         if (exist(tempdir)==7)
%             mkdir=false;
%             rmdir=false;
%         end
%     end
%     if (isfield(request,'clean'))
%         clean=request.clean;
%     end
    if (isfield(request,'model0'))
        model0=request.model0;
    end
    % if (isfield(request,'getDB'))
    %   getDB=request.getDB;
    % end
end
beamlineName=BEAMLINE_NAMES{beamlineId};
getSystem('LCLS');

% If we're not going to retrack files now in the tracking directory,
% then reinitialize the session dir if necessary and reacquire the data.
if ( ~retrack )
    
    if (reinit)
        fprintf('%s\nInitializing MEME modelling\n%s\n',outputseparator,outputseparator);
        sessiondir=sprintf('%s/%s_%s',TEMPROOT,getenv('USER'),datestr(now,ISO8601DATEFMT));
        fprintf('\nCreating session directory ''%s''',sessiondir);
        [status]=system(['mkdir -p ',sessiondir]);
        if ( status > 0 )
            error(unabletocreatedir, unabletocreatedirmsg, tempdir);
        end
        
        fprintf('\nAcquiring MAD files ...\n');
        inputfiles=[cmdfile xsiffiles tapefiles];
        for i=1:length(inputfiles)
            if strncmp( inputfiles{i}, 'http', 4 ) == 1
                cmd=sprintf('wget -P %s %s',sessiondir,inputfiles{i});
            else
                cmd=sprintf('rsync %s %s',inputfiles{i}, sessiondir);
            end
            [status]=system(cmd);
            if ( status > 0)
                error(couldnotinit,couldnotinitmsg,MADWORKDIR);
            end
        end
        
        fprintf('\nPreparing Deck for extant machine processing....\n');
        cmd=sprintf('cd %s; awk -v patchfilename=%s -f %s/%s %s > %s',...
            sessiondir,PATCH_FNAME,ETCROOT,COMMENTINPATCH_AWK_FNAME,...
            madcmdfile_fname,madcmdfile_fname_wpatch);
        [status]=system(cmd);
        if ( status > 0)
            error(couldnotinit,couldnotinitmsg,cmd);
        end
        reinit=false;
        MEME_REINITWD=false;
        
    end
    
    %% Create temporary directory for a single tracking operation.
    % Create the dir and make symlinks to the nominal data files.
    trackdir=sprintf('%s/%s',sessiondir,datestr(now,ISO8601DATEFMT));
    fprintf('\nCreating tracking temporary directory, ''%s'' ....\n',trackdir);
    [status]=system(['mkdir -p ',trackdir]);
    if ( status > 0 )
        error(unabletocreatedir, unabletocreatedirmsg, trackdir);
    end
  
    % Make symlinks from the tracking dir to the session dir, so we can get the
    % input files once, but track any number of times. We need to get the
    % command and data files in one local dir because that's what MAD requires.
    inputfls=[];
    for i=1:numel(INPUTFILETYPES)
        inputfls=[inputfls;dir(fullfile(sessiondir,INPUTFILETYPES{i}))];
    end
    % inputfls=[inputfls dir(fullfile(sessiondir,INPUTFILETYPES{1}))]
    % sessionfns=dir(fullfile(sessiondir,'*'));
    %for i=1:numel(sessionfns)
    %    ffntapes{i}=fullfile(trackdir,fntapes(i).name);
    %end
    %model.urls=strcat('file://',ffntapes');
    for i=1:numel(inputfls)
        % [~,fnbody,fnext]=fileparts(inputfls(i).name);
        % fname=[fnbody fnext];
        fname=inputfls(i).name;
        cmd=sprintf('ln -s %s/%s %s/%s',sessiondir, fname, trackdir, fname);
        [status]=system(cmd);
        if ( status > 0 )
            error(unabletocreatedir, unabletocreatedirmsg, trackdir);
        end
    end
    
    % Pop internal web browser to view tracking results
    % web(['file://' trackdir]);
    cd(trackdir);
    
    % Read Nominal Model
    nominal=readxtfft(sessiondir, beamlineName, TYPE_NOMINAL, 'Nominal', []);
    
    %
    % Processing
    %
    
    %% Prepare input element values with which to model accelerator
    %
    if ( type == TYPE_EXTANT )
                
        % Create patch file
        patch_fullfname=fullfile(trackdir,PATCH_FNAME);
        fid=fopen(patch_fullfname,'w');
        
        % Put in the initial conditions. TODO calculate these from
        % backprop, right now taken as input:
        if ( ~isempty(ics) )
            TWSSC=['SET, CALFX, %f\n',...
                 'SET, CALFY, %f\n',...
                 'SET, CBETX, %f\n',...
                 'SET, CBETY, %f\n'];
            fprintf(fid,TWSSC,ics);
        end
        
        % Insert energy reference points:
        %
        erefs = energyreferencevalues();
        for ierefs=1:length(erefs)
            fprintf(fid,'SET, %s, %f\n',EREFNAMES{ierefs},erefs(ierefs));
        end
        
        % LCLS_lines contains only those elements which have a corresponding
        % control system device. Formally, it is only those elements listed in
        % elementdevices.dat when the model was run.
        %
        S=urlread(LINEDATAFILE_URLS{beamlineId});
        elems=textscan(S,'%s%s %*[^\n]');

        % Find quads
        quadind=find(strncmp(elems{DEVNAMEE},'QUAD',4));
        quadi=ind2sub(size(elems{DEVNAMEE}),quadind);
        % Construct congruent array of device names and element names of quads
        qname={ elems{DEVNAMEE}(quadi) elems{ELEMNAMEE}(quadi) };
        Nq=length(quadind); % Number of quadrupoles
        
        % Find quad effective lengths from nominal model.
        Leff=zeros(Nq,1);
        for iq=1:Nq
            Leff(iq) = sum(nominal.L(strcmp(nominal.N,qname{ELEMNAMEE}(iq))));
        end
        
        % Get quad K1 values, either from extant pv values or archive.
        [K1,~,~]=quadvalues(qname,Leff);
 
        % Write quad settings to patch file.
        for iq=1:length(qname{ELEMNAMEE});
            elemname=char(qname{ELEMNAMEE}(iq));
            if ( ~isempty(elemname) && K1(iq) ~= 0)
                kvarname=['K' char(qname{ELEMNAMEE}(iq))];
                fprintf(fid,'SET, %s, %s\n',kvarname,madvalue(K1(iq)));
            end
        end
        fprintf(fid,'RETURN\n');
        fclose(fid);
       
        
    % Model accelerator from Archived Process variable values
    elseif ( type == TYPE_HISTORY )
        
        % Get time for which user wants to reproduce optics.
        tdesired={request.histtime;request.histtime};
        
        % Create patch file
        patch_fullfname=fullfile(trackdir,PATCH_FNAME);
        fid=fopen(patch_fullfname,'w');
        
        % Put in the initial conditions. TODO calculate these from
        % backprop, right now taken as input:
        if ( ~isempty(ics) )
            TWSSC=['SET, CALFX, %f\n',...
                 'SET, CALFY, %f\n',...
                 'SET, CBETX, %f\n',...
                 'SET, CBETY, %f\n'];
            fprintf(fid,TWSSC,ics);
        end
        
        % Insert energy reference points:
        %
        erefs = energyreferencevalues(tdesired);
        for ierefs=1:length(erefs)
            fprintf(fid,'SET, %s, %f\n',EREFNAMES{ierefs},erefs(ierefs));
        end
        
        % LCLS_lines contains only those elements which have a corresponding
        % control system device. Formally, it is only those elements listed in
        % elementdevices.dat when the model was run.
        %
        S=urlread(LINEDATAFILE_URLS{beamlineId});
        elems=textscan(S,'%s%s %*[^\n]');

        % Find quads
        quadind=find(strncmp(elems{DEVNAMEE},'QUAD',4));
        quadi=ind2sub(size(elems{DEVNAMEE}),quadind);
        % Construct congruent array of device names and element names of quads
        qname={ elems{DEVNAMEE}(quadi) elems{ELEMNAMEE}(quadi) };
        Nq=length(quadind); % Number of quadrupoles
        
        % Read Nominal Model
        % The nominal model is used by TYPE_HISTORY computation to calculate K from
        % archived B given the sum of nominal effective lengths (nominal.L) of
        % all "slices" of the quad. 
        % TODO: Do this only on reinit.
        twissfln=strcat(beamlineName,'_twiss.tape');
        [nominal.tt,nominal.K,elemNamesTemp,nominal.L,nominal.P,...
            nominal.A,nominal.T,nominal.E,nominal.FDN,nominal.twss,...
            nominal.orbt,nominal.S]=xtfft2mat(fullfile(sessiondir,twissfln));
        nominal.N=cellstr(elemNamesTemp);
        Leff=zeros(Nq,1);
        for iq=1:Nq
            Leff(iq) = sum(nominal.L(strcmp(nominal.N,qname{ELEMNAMEE}(iq))));
        end
        
        % Get quad values, either from extant pv values or archive.
        [K1,~,~]=quadvalues(qname,Leff,tdesired);
 
        % Write quad settings to patch file.
        for iq=1:length(qname{ELEMNAMEE});
            elemname=char(qname{ELEMNAMEE}(iq));
            if ( ~isempty(elemname) && K1(iq) ~= 0)
                kvarname=['K' char(qname{ELEMNAMEE}(iq))];
                fprintf(fid,'SET, %s, %s\n',kvarname,madvalue(K1(iq)));
            end
        end
        fprintf(fid,'RETURN\n');
        fclose(fid);
        
    end

end % not re-tracking past acquired data.

% Prepare mad command to track data. 
%
%  For EXTANT and HISTORY, use mad command file with CALL to patch file;
%  otherwise (DESIGN) use siply the unmodified command file.
if ( type == TYPE_EXTANT || type == TYPE_HISTORY)
   cmd=sprintf('(cd %s;%s ../%s)',trackdir,MADCOMMAND,madcmdfile_fname_wpatch);   
else 
   cmd=sprintf('(cd %s;%s ../%s)',trackdir,MADCOMMAND,madcmdfile_fname); 
end

%% Execute MAD
try
    
    [status,stdout]=system(cmd);
    if ( status > 0 )
        error(madmakeerror, madmakeerrormsg, stdout);
    else
        
        %% Show MAD output
        % Display echo file. Then run awk filter to read output and display
        % errors and warnings.
        cd(trackdir);
        web(sprintf('%s/LCLS.echo',trackdir));
        web(sprintf('%s/LCLSI.print',trackdir));
        cmd=sprintf('awk -f %s/filtermadmessages.awk %s/LCLS.echo',ETCROOT,trackdir);
        [status,stdout]=system(cmd);
        if ( status == MADERRORFLAG )
            error(maderror, maderrormsg, stdout);
        elseif ( status == MADWARNINGFLAG )
            warning( madwarning, madwarningmsg, stdout);
        end
        
        %% Retrieve MAD's computed optics
        model=readxtfft(trackdir, beamlineName, type, rundescription, ics);

        % [tt,K,N,L,P,A,T,E,FDN,chrom,orbt,S]=xtffw2mat('chrom.tape');
        %   tt   : Run title, eg 'LCLS: LCLS24OCT13 design'
        %   K    : element keyword (QUAD, SOLE etc)
        %   N    : element name (QA01, SOL3, L0AWAKE) etc)
        %   L    : element length
        %   P    : element parameter
        %   A    : aperture
        %   T    : engineering type (null, QSOL, class-S, DUALFEED, ETA, YAG etc)
        %   E    : energy
        %   FDN  : Formal Device Name (blank for LCLS)
        %   twss :
        %   coor : survey coordinates (X,Y,Z,yaw,pitch,roll)
        %   S    : suml
        % [tt,K,N,L,P,A,T,E,FDN,{coor,rmat,twiss}[,orbt],S]=xtffs2mat(fullfile(MAD_OUTPUTDIR,SURVEY_FILENAME));
        %
        % [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat(fullfile(trackdir,[beamlineName '_twiss.tape']));
        [tt,K,N,L,P,A,T,E,FDN,rmat,S]=xtffr2mat(fullfile(trackdir,[beamlineName '_rmat.tape']));
        [tt,K,N,L,P,A,T,E,FDN,coor,S]=xtffs2mat(fullfile(trackdir,[beamlineName '_survey.tape']));
        model.rmat=rmat;
        model.coor=coor;   % survey coordinates (X,Y,Z,yaw,pitch,roll)
        
%         %% Costruct model description structure - all information about a model run
%         % Record model run metadata:
%         model.tt=tt;
%         model.beamlineName=beamlineName;
%         model.ts=now;
%         if type==TYPE_HISTORY
%             model.type=sprintf('%s %s',TYPE_NAMES{TYPE_HISTORY},request.histtime);
%         else
%             model.type=TYPE_NAMES{type};
%         end
%         model.st=rundescription;
%         % Record output files:
%         model.trackdir=trackdir;
%         fntapes=dir(fullfile(trackdir,'*.tape'));
%         for i=1:numel(fntapes)
%             ffntapes{i}=fullfile(trackdir,fntapes(i).name);
%         end
%         model.urls=strcat('file://',ffntapes');
%         % Record optics:
%         model.ics=ics;     % Initial conditions. If [] then nominal in MAD deck was used.
%         model.K=cellstr(K);         % Keyword (QUAD, SOLE etc)
%         model.N=cellstr(N);         % Element name (QA01, SOL3, L0AWAKE) etc). 16 chars.
%         model.L=L;         % Element length
%         model.P=P;         % Element parameters (different for different element types)
%         model.A=A;         % Dynamic aperture
%         model.T=cellstr(T);         % engineering type (null, QSOL, class-S, DUALFEED, ETA, YAG etc)
%         model.E=E;         % Energy
%         model.FDN=FDN;     % Formal Device Name (not used)
%         model.S=S;         % S coordinate (suml)
% 
%         model.orbt=orbt;   %
%         model.twss=twss;   % Curant-Synder parameters. In order MUX=1;BETAX=2;ALPHAX=3;DX=4;DPX=5
%                            %   MUY=6;BETAY=7;ALPHAY=8;DY=9;DPY=10
 
 
        % model.chrom=chrom;
    end

 catch ME
    error(modelcomputationfailed, modelcomputationfailedmsg);
 end

%% Termination
% If requested, clean up. Set reinit to true for next go around.
if (clean)
    cmd=sprintf('rm -fr %s',sessiondir);
    [status,stdout]=system(cmd);
    if ( status > 0 )
        error(stdout);
    else
        reinit=1;
    end
end

end

function [K1,B,E] = quadvalues(qnames,Leff,varargin)
   
    memecommon;
    NREQARGS = 2;      % 2 requried arguments, for getting extant quad values.
    TDESIRED_ARGI = 1; % The time of archived quad data desired, if given.
    
    % Get B and Energy values at given time. If getting the
    % historical value fails for a given quad the K will not be overriden
    % in the patch file and so the nominal value will stand.
    qBdespvname=strcat(qnames{DEVNAMEE},':BDES');
    qEactpvname=strcat(qnames{DEVNAMEE},':EACT');
    Nq=length(qnames{DEVNAMEE});
    B=zeros(Nq,1);
    E=zeros(Nq,1);
    
    if ( nargin == NREQARGS )    
        for iq=1:Nq
            B(iq)= eget(qBdespvname(iq));
            E(iq)= eget(qEactpvname(iq));
        end
    else
        tdesired=varargin{TDESIRED_ARGI};
        for iq=1:Nq
            [~,tempval] = history(qBdespvname(iq),tdesired);
            if ~isempty(tempval)
                B(iq)= tempval(1);
            end
            [~,tempval] = history(qEactpvname(iq),tdesired);
            if ~isempty(tempval)
                E(iq)= tempval(1);
            end
        end
    end
    
    Bp = Cb*E;
    K1 = B./(Bp.*Leff);      % [1 KG/m^2]
    
    K1(E==0)=0;              % Take care of 0 divisiors and set to 0
    K1(Leff==0)=0;
    fprintf('%s \t%s \t%s \t%s \t%s \t%s\n',...
        'Device name','Element','B [KG]','Energy [GeV]','Eff. Length [m]','K1 [1/m^2]');
    
    for iq=1:Nq
        fprintf('%s \t%s \t%f \t%f \t%f \t%f\n',...
            qnames{DEVNAMEE}{iq},qnames{ELEMNAMEE}{iq},B(iq),E(iq),Leff(iq),K1(iq));
    end
    if ( any(E(:)==0) || any(Leff(:)==0) )
        warning(somekcoeffsarezeromsg);
    end
    
end

function [erefs] = energyreferencevalues(varargin)
    
    memecommon;
    NREQARGS = 0;      % 2 requried arguments, for getting extant quad values.
    TDESIRED_ARGI = 1; % The time of archived quad data desired, if given.
 
    Nerefs=length(EREFPVNAMES);   % Number of reference energy points
    erefs=zeros(Nerefs,1);        % Preallocate for speed
    
    % If no desired time given, get extant pv values, otherwise get
    % historical value:
    if (nargin == NREQARGS)       
        for ieref=1:Nerefs;
            erefs(ieref)=eget(EREFPVNAMES(ieref));
        end
    else
        tdesired=varargin{TDESIRED_ARGI};
        for ieref=1:length(EREFPVNAMES);
            [~,tempval]=history(EREFPVNAMES(ieref),tdesired);
            if ~isempty(tempval)
                erefs(ieref)=tempval(1);
            else
                warning(unabletogetinputdata,unabletogetinputdatamsg,...
                    ['Reference energy ',EREFNAMES(ieref),' (',EREFPVNAMES(ieref),') '],...
                    ['Proceeding with default reference energy' EREFDEFVALUES(ieref)]);  
            end
        end
    end
           
end

function model = readxtfft(directory,beamlinename, type, rundescription, initialconditions)

    memecommon;
    model.trackdir=directory;
    twissfln=strcat(beamlinename,'_twiss.tape');

    [tt,K,N,L,P,A,T,E,FDN,twss,orbt,S]=xtfft2mat(fullfile(directory,twissfln));
    nominal.N=cellstr(N);

    % Record model run metadata:
    model.tt=tt;
    model.beamlineName=beamlinename;
    model.ts=now;
    if type==TYPE_HISTORY
        model.type=sprintf('%s %s',TYPE_NAMES{TYPE_HISTORY},request.histtime);
    else
        model.type=TYPE_NAMES{type};
    end
    
    model.st=rundescription;

    % Record output files:
    fntapes=dir(fullfile(directory,'*.tape'));
    for i=1:numel(fntapes)
        ffntapes{i}=fullfile(model.trackdir,fntapes(i).name);
    end
    model.urls=strcat('file://',ffntapes');
 
    % Asserted Initial conditions. If empty [] then no initial conditions were SET.
    model.ics=initialconditions;
    
    % Record optics:    
    model.K=cellstr(K);         % Keyword (QUAD, SOLE etc)
    model.N=cellstr(N);         % Element name (QA01, SOL3, L0AWAKE) etc). 16 chars.
    model.L=L;         % Element length
    model.P=P;         % Element parameters (different for different element types)
    model.A=A;         % Dynamic aperture
    model.T=cellstr(T);         % Engineering type (null, QSOL, class-S, DUALFEED, ETA, YAG etc)
    model.E=E;         % Energy
    model.FDN=FDN;     % Formal Device Name (not used)
    model.S=S;         % S coordinate (suml)
    model.orbt=orbt;   % Orbit [x,px,y,py,t,pt]
    model.twss=twss;   % Curant-Synder parameters [mux,betx,alfx,dx,dpx,muy,bety,alfy,dy,dpy]
    % model.coor=coor;   % survey coordinates [X,Y,Z,yaw,pitch,roll]
    % model.rmat=rmat;
    % model.chrom=chrom;
        
end

