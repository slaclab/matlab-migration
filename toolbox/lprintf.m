function [txt, metadata, datetime] = lprintf(FID, FORMAT, A, varargin)
% LPRINTF is like FPRINTF for writing error messages. Like FPRINTF it is
% called giving at least a file descriptor, and a string. The string may be
% the message itself, or a format specifier, in which case there must be
% additional arguments to be used to substitute into the format to form the
% message. The formatted message is printed to the file descriptor given.
% The message printed is prepended by a timestamp and process metadata. One
% record (aka line) is printed for each invocation of lprintf. You should
% be able to upgrade uses of fprintf to lprintf by simply replacing the
% name fprintf with lprintf. lprintf is also suitable for use with
% gui_statusDisp since its 1st return argument is the formatted text
% without the timestamp and process metadata.
%  
% The 1st column is a timestamp (in ISO 8601 format for easy comparison).
% The 2nd column is metadata about the process and matlab script issuing
% the message. The formatted message itself is printed in the 3rd column.
%
% Examples:
%   >> lprintf(1, 'The message I want printed on stdout');
%   20160609T113602 physics(greg)@opi46:102272:: The message I want printed on stdout
%
%   >> lprintf(1,'The person at fault is %s.', 'greg')
%   20160609T113136 physics(greg)@opi46:102272:lprintf.m: The person at fault is greg.
%   ans =
%   The person at fault is greg.
%
% Use of lprintf with predefined messages that themselves take arguments,
% by example:
%   >> WS_CANTOPENFILE_MSG='Can''t open file named %s';
%   >> lprintf(1, WS_CANTOPENFILE_MSG, 'datafile.dat');
%   20160609T120927 physics(greg)@opi46:102272:: Can't open file named datafile.dat
%
% INPUTS
%   FID is the so called File Id, or File Desriptor. It is an integer
%   that identifies a file i/oi stream. Simply use 1 for normal output
%   (stdout) like informational messages, and use 2 for error messages 
%   (stderr).
%   FORMAT the basis of the text to be written. See examples and
%   help for fprintf.
%   Other arguments as fprintf.

% OUTPUTS:
% 
%   TXT is the result of formatting, as printed in the 3rd column. It is 
%   the body of the message printed.
%   METADATA the process information string as printed in the 2nd column
%   DATETIME the date and time string as printed in the 1st column.
%
% ------------------------------------------------------------------------
% Auth: Greg White, 9-Jun-2016. Some stolen from disp_log.
% Mod: 
% ========================================================================

% Define some persistent variables so we don't have to look up everything
% each time we call this function
persistent hostname;
persistent username;
persistent physics_user;
persistent process_id;

DATEFMT=30;  % ISO 8601 dateformat eg 20000301T154517
INDENTICAL=1; % strcmp returns 1 for identical 

% Normalize FORMAT arg from array of strings, since [a 'dfasf' b] is 
% common in our matlab code eg as arg to gui_statusDisp.
FORMAT=cellstr(FORMAT);FORMAT=[FORMAT{:}];  

% Look up some info about where this GUI is running, what script it is being
% called from, user name etc.  Should only need to do this once.
%

%% Get name of computer on which matlab is running
if isempty(hostname)
    [stat, hostname] = system('hostname');
    if stat ~= 0 || isempty(hostname)   
        % if for some reason the system call didnt work, fake it
        hostname = 'unknown_host';
    end
    hostname = deblank(hostname); % rm CR  
end 

%% account running matlab 
if isempty(username)
    [stat, username] = system('whoami');
    if stat ~= 0 || isempty(username)
        username = 'unknown_user';
    end
    username = deblank(username);
end

%% Best guess at person running matlab
if isempty(physics_user)
    physics_user = getenv('PHYSICS_USER');
    if isempty(physics_user)
        physics_user = 'physics';
    end
end

%% Application and exact file issuing message
frame_data='';
stack = dbstack(1);       % Get call stack (excluding this
                          % function).
stackdepth=length(stack); % Get the depth of the call stack.

% If the stackdepth is >= 1, then a script has called this function,
% so get that script's name and the line number at which it called
% this function - which should indicate where the problem was detected
% from stackframe 1. Additionally, if the stackdepth is > 1 that
% script in turn was called by something, so get the head of the call
% stack. If it's a different file, then prepend that too. 
% That head script will probably be a GUI's name.
if stackdepth >= 1 
    prevfile = deblank(stack(1).file); 
    frame_data = sprintf('%s:%d',deblank(stack(1).file), ...
                         stack(1).line);
    if stackdepth > 1
        headfilei=find(~cellfun(@isempty,{stack.file}),1,'last');
        headfile=deblank(stack(headfilei).file);
        if strcmp(prevfile, headfile) ~= INDENTICAL
            frame_data = sprintf('%s..%s', ...
                deblank(headfile),frame_data);
        end
    end
end

%% Process id issuing message
if isempty(process_id)
    process_id = num2str(feature('getpid'));
    if isempty(process_id)
        process_id = 'unknown_pid';
    end
    process_id = deblank(process_id);
end

%% Construct the log messages
if strcmp(username, physics_user)
    metadata = sprintf('%s@%s:%s:%s',...
        username,hostname,process_id,frame_data);
else
    metadata = sprintf('%s(%s)@%s:%s:%s',...
        username,physics_user,hostname,process_id,frame_data);
end

%% Print above assembled data to the file descriptor given. 
datetime=datestr(now,DATEFMT);

if nargin < 3 
    txt = FORMAT;
else
    txt = sprintf(FORMAT, A, varargin{:});
end
fprintf(FID, '%s %s: %s\n', datetime, metadata, txt );

