% GUI to Save Bunch Length Measurement dataset to a file
% Mike Zelazny - zelazny@stanford.edu

global gBunchLength;

BunchLengthLogMsg('Save button pressed. Please wait for file selection menu.');

% may need to restore filename
fileName = gBunchLength.fileName;

% Get default save file name
defaultFileName = BunchLengthDefFileName();

[gBunchLength.fileName,gBunchLength.pathName] = uiputfile({'*.mat'},...
    sprintf ('Enter Bunch Length Data File Name: %s', defaultFileName), ...
    defaultFileName);

% if user pressed Cancel then fileName & pathName are set to 0.
if isequal(gBunchLength.fileName,0)
    % save operation canceled, restore fileName
    gBunchLength.fileName = fileName;
else    
    % save whatever is necessary
    BunchLengthLogMsg(sprintf('Request to save data set WITHOUT IMAGES to %s. Please wait.', gBunchLength.fileName));
    BunchLengthSaveSmall(fullfile(gBunchLength.pathName, gBunchLength.fileName));
end