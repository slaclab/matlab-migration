% Save Bunch Length Measurement dataset to a file without images!
% Mike Zelazny - zelazny@stanford.edu

function BunchLengthSaveSmall (fileName)

global gBunchLength;

% save data to soft IOC
BunchLengthSaveCal_pvs;
BunchLengthSaveOpts_pvs;
BunchLengthSaveMeas_pvs;

% issue working messages
BunchLengthLogMsg ('Stripping images from dataset');

% temp copy of global;
temp = gBunchLength;

% strip off images
if isfield(gBunchLength,'cal')
    if isfield(gBunchLength.cal,'gIMG_MAN_DATA')
        if isfield(gBunchLength.cal.gIMG_MAN_DATA,'dataset')
            for i = 1:length(gBunchLength.cal.gIMG_MAN_DATA.dataset)
                if isfield(gBunchLength.cal.gIMG_MAN_DATA.dataset{i},'rawImg')
                    for j = 1:length(gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg)
                        if isfield(gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{j},'data')
                            gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.rawImg{j}.data=0;
                        end
                    end
                end
                if isfield(gBunchLength.cal.gIMG_MAN_DATA.dataset{i},'ipOutput')
                    for j = 1:length(gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput)
                        if isfield(gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{j},'procImg')
                            gBunchLength.cal.gIMG_MAN_DATA.dataset{i}.ipOutput{j}.procImg=0;
                        end
                    end
                end
            end
        end
    end
end

if isfield(gBunchLength,'meas')
    if isfield(gBunchLength.meas,'gIMG_MAN_DATA')
        if isfield(gBunchLength.meas.gIMG_MAN_DATA,'dataset')
            for i = 1:length(gBunchLength.meas.gIMG_MAN_DATA.dataset)
                if isfield(gBunchLength.meas.gIMG_MAN_DATA.dataset{i},'rawImg')
                    for j = 1:length(gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.rawImg)
                        if isfield(gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.rawImg{j},'data')
                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.rawImg{j}.data=0;
                        end
                    end
                end
                if isfield(gBunchLength.meas.gIMG_MAN_DATA.dataset{i},'ipOutput')
                    for j = 1:length(gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput)
                        if isfield(gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{j},'procImg')
                            gBunchLength.meas.gIMG_MAN_DATA.dataset{i}.ipOutput{j}.procImg=0;
                        end
                    end
                end
            end
        end
    end
end

gBunchLength.noImageAnalysis = 1;

% issue working messages
BunchLengthLogMsg (sprintf ('Trying to save %s Please be patient...', fileName));

% save the global, note that the name is significant for restore purposes.
save (fileName, 'gBunchLength');

% put enerything back the way it was in global land.
gBunchLength = temp;

% issue message indicating data saved
BunchLengthLogMsg (sprintf ('Bunch Length Measurement saved to %s', ...
    fileName));
