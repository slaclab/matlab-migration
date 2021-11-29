function util_configSave(appName, config, showDlg)
%CONFIGSAVE
%  CONFIGSAVE(APPNAME, CONFIG, SHOWDLG) saves configuration in struct
%  CONFIG for application APPNAME.

% Features: Saves the config data in the $LCDATA/matlab/config directory
% as file APPNAME_CONFIG.MAT

% Input arguments:
%    APPNAME: Name of application
%    CONFIG: Struct of configuration data to be saved
%    SHOWDLG: Displays dialog to select file name

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
if nargin < 3, showDlg=0;end

pathName=fullfile(getenv('MATLABDATAFILES'),'config');
if isempty(pathName), pathName='.';end
fileName=[appName '_config.mat'];
if showDlg
    [fileName,pathName]=uiputfile(fullfile(pathName,fileName),'Save as');
    if ~ischar(fileName), return, end
end
save(fullfile(pathName,fileName),'config');
