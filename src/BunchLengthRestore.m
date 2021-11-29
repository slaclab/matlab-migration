% Restores saved Bunch Length Measurment from a file
% Mike Zelazny - zelazny@stanford.edu

function BunchLengthRestore (fileName)

global gBunchLength;

% issue working message
BunchLengthLogMsg(sprintf('Trying to load %s', fileName));

% load the file from disk
load(fileName);
    
% issue message indicating data loaded
BunchLengthLogMsg(sprintf ('Bunch Length Measurement restored from %s', ...
    fileName));
