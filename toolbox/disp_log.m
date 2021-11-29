function out = disp_log(message, debug)
% DISP_LOG(message) works like disp:  pass it a string, and it outputs the
% string to the Matlab terminal.  It also prepends a timestamp, useful for
% troubleshooting scripts after the fact.  The same message is also passed
% to CMLog.
%

% ------------------------------------------------------------------------
% Auth: 
% Mod: Greg White, 21-Apr-2016, Bugfix (for enery ramp GUI)
%      Ensure message is char array, not cell array of string, prior
%      to sprintf.
%      Greg White, 19-Apr-2016, Enhancement
%      Replace disp with sprintf to avoid removal of spaces  
% ========================================================================

% Debug flag defaults to false
if nargin < 2
    debug = 0;
end

% Define some persistent variables so we don't have to look up everything
% each time we call this function
persistent hostname;
persistent username;
persistent physics_user;
persistent script_name;
persistent process_id;
persistent cm;

% look up some info about where this GUI is running, what script it is being
% called from, user name etc.  should only need to do this once.

if isempty(hostname)
    [stat, hostname] = system('hostname');
    if isempty(hostname)   
        % if for some reason the system call didnt work, fake it
        hostname = 'unknown_host';
    end
    hostname = deblank(hostname);      % system() tacks on a carriage return, kill it
end

if isempty(username)
    [stat, username] = system('whoami');
    if isempty(username)
        username = 'unknown_user';
    end
    username = deblank(username);
end

if isempty(physics_user)
    physics_user = getenv('PHYSICS_USER');
    if isempty(physics_user)
        physics_user = 'physics';
    end
    %physics_user = deblank(physics_user);
end

% call dbstack every time, not just on init
[st, i] = dbstack();

if isempty(script_name)
    % script name should identify the GUI or matlab routine that is calling
    % this logger function.  GUIs launched with the "MatlabGUI" script have
    % an environment variable set:
    script_env_name = getenv('MATLAB_STARTUP_SCRIPT');
    script_name = [script_env_name '.m'];
    
    % if it's not in the environment, pull it out of the function stack
    % instead.  it should be the top (last) thing in the stack:
    if isempty(script_env_name)
        script_name = st(length(st)).file;
    end

    % if THAT didn't work, just fill it in with some nonsense:
    if isempty(script_name)
        script_name = 'unknown_file';
    end
    
    script_name = deblank(script_name);
end

if isempty(process_id)
    process_id = num2str(feature('getpid'));
    if isempty(process_id)
        process_id = 'unknown_pid';
    end
    process_id = deblank(process_id);
end

% Initialize cmlog error instance
if isempty(cm)
    try
        aidainit;
    catch
        disp('Unable to get Err instance, cannot write to CMLog');
    end
end

% Refresh Err reference
cm = getLogger([script_name ' (Matlab)']);

% Construct the log messages
if strcmp(username, physics_user)
    cmlog_message = [username '@' hostname];
else
    cmlog_message = [username '(' physics_user ')@' hostname];
end

% If there is a stack, st(2).name is the function that called disp_log
message=char(message);
if debug
    if length(st) > 1
        cmlog_message = sprintf('%s [%s] %s -> %s: %s',...
            cmlog_message, process_id, script_name, st(2).name, message);
    else
        cmlog_message = sprintf('%s [%s] %s: %s',...
            cmlog_message, process_id, script_name, message);
    end
else
        cmlog_message = sprintf('%s : %s', cmlog_message, message);
end

% Actually write the messages to the logs:
cmlog_message = cellstr(cmlog_message);
for ix = 1:length(cmlog_message)
    put2log(char(cmlog_message(ix)));
end

out=cmlog_message;
