function [config, ts] = util_configLoad(appName, showDlg)
%CONFIGLOAD
%  CONFIG = CONFIGLOAD(APPNAME, SHOWDLG) loads configuration in struct CONFIG for
%  application APPNAME.

% Features: Returns the config data in the $LCDATA/matlab/config directory
% from file APPNAME_CONFIG.MAT

% Input arguments:
%    APPNAME: Name of application
%    SHOWDLG: Displays dialog to select file name

% Output arguments:
%    CONFIG: Struct of configuration data loaded from file

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC

% --------------------------------------------------------------------
if nargin < 2, showDlg=0;end
if nargin < 1, appName='*';showDlg=1;end

config=[];ts='';
pathName=fullfile(getenv('MATLABDATAFILES'),'config');
if isempty(pathName), pathName='.';end
fileName=[appName '_config.mat'];
if ischar(showDlg)
    fileName=showDlg;
    if ~strcmp(fileName(end-3:end),'.mat'), fileName=[fileName '.mat'];end
elseif showDlg
    [fileName,pathName]=uigetfile(fullfile(pathName,fileName),'Load config file');
    if ~ischar(fileName), return, end
end

file=fullfile(pathName,fileName);
if exist(file,'file')
    load(file);
    f=dir(file);ts=f.datenum;
end
