function util_appClose(hObject)
%APPCLOSE
%  APPCLOSE(HOBJECT) is called from a GUI close request function to delete
%  the figure object and to exit matlab if the GUI is run in the production
%  environment and no other GUIs are running in the same matlab process.

% Features: 

% Input arguments:
%    HOBJECT: Handle of the figure

% Output arguments: none

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
% Get file name of GUI program instance.
if ishandle(hObject)
    file=get(hObject,'FileName');
    [~,file]=fileparts(file);
    % Delete GUI.
    delete(hObject);
else
    file=dbstack; % Find caller
    file=file(end).name;
end

if 0
% exit from Matlab when not running the desktop
if usejava('desktop') || strcmp(getenv('USER'),'loos') || strcmp(getenv('PHYSICS_USER'),'loos')
    % don't exit from Matlab
else
    exit
end

elseif isempty(util_appFind)
%if strcmp(['/usr/local/lcls/tools/matlab/toolbox/' file '.m'], which(file))
[~,filePath] = system(['readlink -fn ' fileparts(which(file))]); % Remove symlinks
filePath = strrep(filePath,'beta','toolbox');
[~,startupPath] = system(['readlink -fn ' fileparts(which('startup'))]); % Remove symlinks
startupPath = strrep(startupPath,'beta','toolbox');
if ~isempty(strfind(filePath,startupPath)) && ~epicsSimul_status
    lcaClear; % Disconnect from Channel Access
    exit
else
    % don't exit from matlab
end

end
