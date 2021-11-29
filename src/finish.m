% When Matlab exits finish.m is run automatically.

% Matlab Prelaunch vairables
global matlabPrelaunchStatusPV;
global matlabPrelaunchScriptPV;
global OPI_SYSTEM_AREA;
global OPI_SYSTEM_NUMBER;
global matlabPrelaunchBusyStatus;

% clear Prelaunch status/script PVs
try
    lcaGet(matlabPrelaunchStatusPV);
    [~,~] = system(sprintf('caput %s ''''', matlabPrelaunchStatusPV));
    matlabPrelaunchStatusPV='';

    matlabSessionCount = sprintf('OPI:%s:%s:MATLAB_NEWSESSION', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER);
    lcaPut(matlabSessionCount, '-1');

    [~,~] = system(sprintf('caput %s ''''', matlabPrelaunchScriptPV));
    matlabPrelaunchScriptPV='';

    % Only clear script PV if it was used
    if (matlabPrelaunchBusyStatus)
        matlabBusyCount = sprintf('OPI:%s:%s:MATLAB_NEWSCRIPT', OPI_SYSTEM_AREA, OPI_SYSTEM_NUMBER);
        lcaPut(matlabBusyCount, '-1');
        matlabPrelaunchBusyStatus=0;
    end
catch
end

try
    disp('finish.m about to lcaClear');
    lcaClear; % just in case
catch
end
