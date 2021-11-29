%	This file calls the LCLS_BCC GUI and establishes the directory names where LCLS_BCC
%	and its subfolders have been placed. Please modify only the text string below named: "dir_str".
%
%=================================================================================================

%dir_str = 'C:\Matlab\work'; % change this disk/directory string to the location where you want to keep the LCLS_BCC stuff

%LCLS_BCC('dir',[dir_str '\LCLS_BCC\SaveFiles']); % do not change this line

LCLS_BCC('dir',fullfile(getenv('MATLABDATAFILES'),'LCLS_Simulator'));
