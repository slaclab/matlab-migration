% GUI to Restore saved Bunch Length Measurment from a file
% Author: Mike Zelazny (zelazny@stanford.edu)

global gBunchLength;

% save fileName in case user presses cancel
fileName = gBunchLength.fileName;

% issue working message
BunchLengthLogMsg('Waiting for Matlab to pop up list of available files to restore, please be patient...');

[gBunchLength.fileName,gBunchLength.pathName] = uigetfile({'*.mat'},...
    'Select Bunch Length dataset to load');

if isequal(gBunchLength.fileName,0)
    % user pressed cancel
    gBunchLength.fileName = fileName;
else
    % restore whatever is necessary
    BunchLengthRestore(fullfile(gBunchLength.pathName, gBunchLength.fileName));
end
