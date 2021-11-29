% Save Bunch Length Measurement dataset to a file
% Mike Zelazny - zelazny@stanford.edu

function BunchLengthSave (fileName)

global gBunchLength;

% save data to soft IOC
BunchLengthSaveCal_pvs;
BunchLengthSaveOpts_pvs;
BunchLengthSaveMeas_pvs;

% issue working messages
BunchLengthLogMsg (sprintf ('Trying to save %s Please be patient...', fileName));

% save the global
save (fileName, 'gBunchLength');
    
% issue message indicating data saved
BunchLengthLogMsg (sprintf ('Bunch Length Measurement saved to %s', ...
    fileName));
