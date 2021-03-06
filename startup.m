DIREXCLUSIONPATTERN=':?(\w|\/|\.)*((\.((\w)*))|(CVS)|(dev))';


% some useful startup default
set(0,'DefaultAxesFontsize', 14)
lcainitstat=0;

%% Set the production environment.
%
% This section sets the environment for applications running on the
% production network.
%
if ~ispc  % Assume ~ispc is equivalent to establishing we're on prod.

    % Add LCLS Production matlab scripts & functions to head of path.
    %
    PRODMATLABPATHROOT=getenv('MAT');
    addpath(regexprep(genpath(fullfile(PRODMATLABPATHROOT,'LiTrack')),...
                  DIREXCLUSIONPATTERN,''));
    addpath(regexprep(genpath(fullfile(PRODMATLABPATHROOT,'acclegr')),...
                  DIREXCLUSIONPATTERN,''));
    addpath(regexprep(genpath(fullfile(PRODMATLABPATHROOT,'toolbox')),...
                  DIREXCLUSIONPATTERN,''));
    addpath(regexprep(genpath(fullfile(PRODMATLABPATHROOT,'src')),...
                  DIREXCLUSIONPATTERN,''));
    if strcmp(version('-release'),'2020a')
      my_2020a_dir = genpath(fullfile(PRODMATLABPATHROOT,'2020a'));
      my_2020a_dirs = regexp(my_2020a_dir,':','split');
      for my_dir = 1:length(my_2020a_dirs)
          if strfind(my_2020a_dirs{my_dir},'git') > 0
              % do nothing
          else
              addpath(my_2020a_dirs{my_dir});
          end
      end
    end

    % Echo environment to matlab output
    [ sys, accelerator ] = getSystem;
    [ whoami_status, whoami_results ] = unix('whoami');
    [ hostname_status, hostname_results ] = unix('hostname');
    % (-1 removes trailing CR)
    disp( [ 'System=' sys ...
        ' Accelerator=' accelerator ...
        ' Account=' whoami_results(1:length(whoami_results)-1) ...
        ' Host=' hostname_results(1:length(hostname_results)-1) ...
        ] ) ;
    disp('**************************************************************');

    % Work around bug in 2007b there bug in file chooser dialog box.
    % We work around it using a deprecated feature.
    try
        if strcmp(version('-release'),'2007b')
            % Setup to use non-java dialogs. - Greg White
            % NOTE: This uses an undocumented feature (feature) to
            % force use of a deprecated feature. So, erm, not forward
            % compatible.
            disp('Setting deprecated feature - use UseOldFileDialogs');
            warning('OFF','MATLAB:uigetfile:DeprecatedFunction');
            feature('UseOldFileDialogs',1)
        end
    catch ex
        % Not fatal if non-java dialog setup fails
        disp('Failed to Set deprecated feature - use UseOldFileDialogs');
    end

    % Set up machine dependent environment
    %
    if isempty(accelerator), return, end % for lcls-dev1
    if isempty(sys), return, end % for testfac-srv01

    if strcmp(accelerator,'NLCTA')
        disp('Executing Matlab specialization for NLCTA');
        startupNLCTA;
    elseif strcmp( accelerator,'FACET')  % LCLS or FACET
        disp('Executing Matlab specialization for FACET');
        startupFACET;
    end


    % Initialize labCa, the EPICS V3 channel access - matlab interface
    %
    try
        lcaInit;
        lcainitstat=1;
    catch ex
        fprintf('%s Failed to initialize labCa\n',datestr(now));
    end

    % Count Matlab startups
    %
    if lcainitstat == 1  % lca successfully initialized, so can use it
        try
            pv = [ 'SIOC:' sys ':ML02:AO000' ];
            lcaPut(pv, 1+lcaGet(pv));
            fprintf('%s Successfully updated counter %s=%d\n',...
                    datestr(now),pv,lcaGet(pv));
        catch ex
            fprintf('%s Failed to update Matlab startup counter %s',...
                    datestr(now),pv);
        end
        try
            me = char(getenv('MATLAB_STARTUP_SCRIPT'));
            if isempty(me)
                me = '<empty>';
            end
            if length(me) > 28
                me = me(1:28);
            end
            pvs = cell(0);
            for i = 501:999
                pvs{end+1} = sprintf('SIOC:%s:ML02:AO%d.DESC',sys,i);
            end
            descs = lcaGet(pvs');
            for i = 1:length(pvs)
                pv = strtok(char(pvs{i}),'.');
                desc = char(descs(i));
                if isequal(desc,'RESERVED')
                    lcaPut(sprintf('%s.DESC',pv),me);
                    desc = char(lcaGet(sprintf('%s.DESC',pv)));
                end
                if isequal(desc,me)
                    lcaPut(pv,1+lcaGet(pv));
                    fprintf('%s %s run count (%s) = %d\n', ...
                            datestr(now), me, pv, lcaGet(pv));
                    break;
                end
            end
        catch ex
            fprintf('Sorry, failed to update %s run counter.\n', me);
        end
    end % successful lca init
end % ~ispc - that is, assume we're definitely on production.


%% Set up environment used whether on production or not.
%

% first see if we are starting from a matlab directory.  If so use that as the USERPATHROOT
% if it has not already been overridden
if ~exist('USERPATHROOT','var')
    toolboxpath=[getenv('PWD') '/toolbox'];
    if isdir(toolboxpath)
        USERPATHROOT=getenv('PWD');
    end
end


% If USERPATHROOT (users's development dir) is not explicitly
% defined above, see if PHYSICS_USER/matlab/ exists, and if it
% does, set the USERPATHROOT to that dir.
if ~exist('USERPATHROOT','var')
    physicsuser=getenv('PHYSICS_USER');
    if ~isempty(physicsuser)
        defaultuserpathroot=[getenv('HOME') physicsuser '/matlab'];
        if isdir(defaultuserpathroot)
            USERPATHROOT=defaultuserpathroot;
        end
    end
end

% If a user's development directory root dir has been defined above (either
% explicitly, or by probing to see if there exists the classic default one
% in ~physics/<physics_user>/matlab/) then add it (recurrsively including
% all its subdirectories), to the head of the path.
%
if exist('USERPATHROOT','var') && isdir(USERPATHROOT)
    addpath(regexprep(genpath(fullfile(USERPATHROOT,'LiTrack')),...
                      DIREXCLUSIONPATTERN,''));
    addpath(regexprep(genpath(fullfile(USERPATHROOT,'acclegr')),...
                      DIREXCLUSIONPATTERN,''));
    addpath(regexprep(genpath(fullfile(USERPATHROOT,'toolbox')), ...
                      DIREXCLUSIONPATTERN,''));
    addpath(regexprep(genpath(fullfile(USERPATHROOT,'src')),...
                      DIREXCLUSIONPATTERN,''));
end

aidapvainit
aidainit

return;


