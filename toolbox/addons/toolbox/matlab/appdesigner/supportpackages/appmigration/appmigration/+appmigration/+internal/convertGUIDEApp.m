function convertGUIDEApp(varargin)
%CONVERTGUIDEAPP Launches the GUIDE to App Designer Migration Tool

%   Copyright 2017-2018 The MathWorks, Inc.

% Create a persistent variable to ensure only one instance of the front end app is
% created
persistent appMigrationAppInstance;

% Check if an existing app is open
if isempty(appMigrationAppInstance) || ~isvalid(appMigrationAppInstance)
    % No existing app, create a new one
    appMigrationAppInstance = appmigration.internal.GUIDEAppMigrationTool(varargin{:});
else
    % Bring existing app to front
    figure(appMigrationAppInstance.UIFigure);
end
% put a lock on the instance so this instance cannot be cleared by a
% "clear all".  If not "clear all" will lose handle to already open app
% causing to launch a new app
mlock;
end