%=======================================================
%
% Name:     startMATPRE.m
%
% Desc:     Find and monitor a PV while waiting for the
%           user to pass a script
%
% Usage:    used by MatlabGUI.prelaunch
%
% Authored: 05-Dec-2016, Thomas Kurty (tkurty)
%
% Revised:  dd-mmm-yyyy, Author (user)
%
%=======================================================


% Reserve and monitor a PV, then run its script

global matlabPrelaunchStatusPV;
global matlabPrelaunchScriptPV;
global OPI_SYSTEM_AREA;
global OPI_SYSTEM_NUMBER;
global matlabPrelaunchBusyStatus;

% Get hostname
[status,HOSTNAME] = system('hostname');
% Remove trailing newline
if (HOSTNAME(end) == sprintf('\n'))
    HOSTNAME=HOSTNAME(1:end-1);
end

% Uncomment for testing on DEV, use opi2 instead of lcls-dev2
%if strcmp(HOSTNAME, 'lcls-dev2')
%    HOSTNAME='opi2';
%end

% Uncomment for testing on DEV, use opi3 instead of lcls-dev3
%if strcmp(HOSTNAME, 'lcls-dev3')
%    HOSTNAME='opi3';
%end

% Get OPI_SYSTEM_NUMBER from hostname
OPI_SYSTEM_NUMBER='0';
for a=1:50
    if strcmp(HOSTNAME,sprintf('opi%i',a))
        OPI_SYSTEM_NUMBER=sprintf('%i',a);
        OPI_SYSTEM_AREA='ACR0';
    end
end

% Exit if hostname doesn't have OPI format
if strcmp(OPI_SYSTEM_NUMBER,'0')
    disp('Not running on a valid OPI, exiting...');
    pause(5);
    exit
end

% Get PID
pid=feature('getpid');
fprintf('Prelaunching on %s with PID %i\n', HOSTNAME, pid);

statusCheck= sprintf('opi%s.%i', OPI_SYSTEM_NUMBER, pid);
matlabReserve = sprintf('OPI:%s:%s:MATLAB_RESERVE', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER);

% Declare status variables
allStatusPVs=cell(50,1);

for i=1:50
    allStatusPVs{i}=sprintf('OPI:%s:%s:MATLAB%i_STATUS', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER, i);
end

% Try reservation twice before giving up
for reserveAttempt=1:2

    % Place reservation with IOC
    try
        lcaPut(matlabReserve, statusCheck);
    catch
        fprintf('Could not find OPI:%s:%s:MATLAB PVs, exiting...', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER);
        pause(5);
        exit
    end

    % Find reservation in status PVs

    allStatuses=lcaGet(allStatusPVs);

    matlabPrelaunchStatusPV='';
    a=1;
    while a<=50
        if strcmp(allStatuses(a),statusCheck)
            matlabPrelaunchStatusPV=allStatusPVs{a};
            matlabPrelaunchStatusMsg = sprintf('Waiting for opi%s', OPI_SYSTEM_NUMBER);
            % PV stores "Waiting for opi$OPI_SYSTEM_NUMBER"
            lcaPut(matlabPrelaunchStatusPV,matlabPrelaunchStatusMsg);
            matlabSessionCount = sprintf('OPI:%s:%s:MATLAB_NEWSESSION', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER);
            lcaPut(matlabSessionCount, '1');
            matlabPrelaunchBusyStatus=0;
            break;
        end
        a=a+1;
    end

    if a~=51
        break;
    end
end

if(length(matlabPrelaunchStatusPV)==0)
    disp(sprintf('Reservation failed after %i attempts, exiting...', reserveAttempt));
    pause(5);
    exit;
end

% Clear and monitor script PV, get user script
matlabPrelaunchScriptPV= sprintf('OPI:%s:%s:MATLAB%i_SCRIPT', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER, a);
[~,~] = system(sprintf('caput %s ''''', matlabPrelaunchScriptPV));
lcaSetMonitor(matlabPrelaunchScriptPV);
lcaNewMonitorValue(matlabPrelaunchScriptPV);
lcaGet(matlabPrelaunchScriptPV);

system(sprintf('echo -ne "\033]0;MatlabGUI.prelaunch %i - DO NOT PRESS [X]\007"',a));
fprintf('Monitoring %s for a matlab script.\n',matlabPrelaunchScriptPV);
disp('To close this session, DO NOT press the X on this window.');
disp('Instead, press Ctrl-C in this terminal and type "exit" at the prompt.');

try
    while 1
        if(lcaNewMonitorValue(matlabPrelaunchScriptPV));
            userScript=lcaGet(matlabPrelaunchScriptPV);
            if(length(char(userScript))>0)
                break;
            end
        end
        pause(0.1);
    end
catch
    disp('Aborting PV monitor...');
    exit
end

if(strcmp(userScript,'exit'))
    disp('Failed to acquire script from PV');
    exit
end

% Prepare to launch script, update status messages

disp( [ 'Running ' char(userScript) '...' ] );
system(sprintf('echo -ne "\033]0;%s.m - DO NOT PRESS [X]\007"', char(userScript)));
matlabPrelaunchStatusMsg = sprintf('Running %s', char(userScript));
lcaPut(matlabPrelaunchStatusPV, matlabPrelaunchStatusMsg);
matlabBusyCount = sprintf('OPI:%s:%s:MATLAB_NEWSCRIPT', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER);
lcaPut(matlabBusyCount, '1');
matlabPrelaunchBusyStatus=1;

% Launch user script
try
    % Uncomment for testing, save original directory that has custom finish.m
    %matlabPrelaunchOriginalDir=cd;

    % Backup global variables in case script tries to clear them
    StatusPV_backup=matlabPrelaunchStatusPV;
    ScriptPV_backup=matlabPrelaunchScriptPV;
    AREA_backup=OPI_SYSTEM_AREA;
    NUMBER_backup=OPI_SYSTEM_NUMBER;
    BusyStatus_backup=matlabPrelaunchBusyStatus;

    % Run the script
    run(char(userScript));

    % Restore global variables
    matlabPrelaunchStatusPV=StatusPV_backup;
    matlabPrelaunchScriptPV=ScriptPV_backup;
    OPI_SYSTEM_AREA=AREA_backup;
    OPI_SYSTEM_NUMBER=NUMBER_backup;
    matlabPrelaunchBusyStatus=BusyStatus_backup;

    % Uncomment for testing, restore original directory that has custom finish.m
    %cd(matlabPrelaunchOriginalDir);

catch
    disp( [ char(userScript) ' appears to have failed.' char(10) 'Type "exit" to close this Matlab session'  ] );
    return
end

return
