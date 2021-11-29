function param = camera_DAQ_PVs(param)

camPVs = param.cams;
num_cam = numel(camPVs);

param.DAQPVs.cam_Acq                = cell(num_cam,1);
param.DAQPVs.cam_ArrayCounterRBV    = cell(num_cam,1);
param.DAQPVs.cam_Connection         = cell(num_cam,1);
param.DAQPVs.cam_DetectorState      = cell(num_cam,1);
param.DAQPVs.cam_ImCountRBV         = cell(num_cam,1);
param.DAQPVs.cam_ImageMode          = cell(num_cam,1);
param.DAQPVs.cam_ImageModeRBV       = cell(num_cam,1);
param.DAQPVs.cam_NumImages          = cell(num_cam,1);
param.DAQPVs.cam_NumImagesRBV       = cell(num_cam,1);
param.DAQPVs.cam_TSS_SETEC          = cell(num_cam,1);
param.DAQPVs.cam_TiffAutoIncrement  = cell(num_cam,1);
param.DAQPVs.cam_TiffAutoSave       = cell(num_cam,1);
param.DAQPVs.cam_TiffCallbacks      = cell(num_cam,1);
param.DAQPVs.cam_TiffFileFormat     = cell(num_cam,1);
param.DAQPVs.cam_TiffFileName       = cell(num_cam,1);
param.DAQPVs.cam_TiffFileNumber     = cell(num_cam,1);
param.DAQPVs.cam_TiffFileNumberRBV  = cell(num_cam,1);
param.DAQPVs.cam_TiffFilePath       = cell(num_cam,1);
param.DAQPVs.cam_TiffFilePathExists = cell(num_cam,1);
param.DAQPVs.cam_DataType           = cell(num_cam,1);

for i=1:num_cam
    param.DAQPVs.cam_Acq{i,1}                = [char(camPVs(i)), ':Acquisition'];
    param.DAQPVs.cam_ArrayCounterRBV{i,1}    = [char(camPVs(i)), ':ArrayCounter_RBV'];
    param.DAQPVs.cam_ArrayCounter{i,1}       = [char(camPVs(i)), ':ArrayCounter'];
    param.DAQPVs.cam_Connection{i,1}         = [char(camPVs(i)), ':AsynIO.CNCT'];
    param.DAQPVs.cam_DetectorState{i,1}      = [char(camPVs(i)), ':DetectorState_RBV'];
    param.DAQPVs.cam_ImCountRBV{i,1}         = [char(camPVs(i)), ':NumImagesCounter_RBV'];
    param.DAQPVs.cam_ImageModeRBV{i,1}       = [char(camPVs(i)), ':ImageMode_RBV'];
    param.DAQPVs.cam_ImageMode{i,1}          = [char(camPVs(i)), ':ImageMode'];
    param.DAQPVs.cam_NumImagesRBV{i,1}       = [char(camPVs(i)), ':NumImages_RBV'];
    param.DAQPVs.cam_NumImages{i,1}          = [char(camPVs(i)), ':NumImages'];
    param.DAQPVs.cam_ROIEnableCallbacks{i,1} = [char(camPVs(i)), ':ROI:EnableCallbacks'];
    param.DAQPVs.cam_TSS_SETEC{i,1}          = [char(camPVs(i)), ':TSS_SETEC'];
    param.DAQPVs.cam_TiffAutoIncrement{i,1}  = [char(camPVs(i)), ':TIFF:AutoIncrement'];
    param.DAQPVs.cam_TiffAutoSave{i,1}       = [char(camPVs(i)), ':TIFF:AutoSave'];
    param.DAQPVs.cam_TiffCallbacks{i,1}      = [char(camPVs(i)), ':TIFF:EnableCallbacks'];
    param.DAQPVs.cam_TiffCapture{i,1}        = [char(camPVs(i)), ':TIFF:Capture'];
    param.DAQPVs.cam_TiffFileFormat{i,1}     = [char(camPVs(i)), ':TIFF:FileTemplate'];
    param.DAQPVs.cam_TiffFileName{i,1}       = [char(camPVs(i)), ':TIFF:FileName'];
    param.DAQPVs.cam_TiffFileNumberRBV{i,1}  = [char(camPVs(i)), ':TIFF:FileNumber_RBV'];
    param.DAQPVs.cam_TiffFileNumber{i,1}     = [char(camPVs(i)), ':TIFF:FileNumber'];
    param.DAQPVs.cam_TiffFilePathExists{i,1} = [char(camPVs(i)), ':TIFF:FilePathExists_RBV'];
    param.DAQPVs.cam_TiffFilePath{i,1}       = [char(camPVs(i)), ':TIFF:FilePath'];
    param.DAQPVs.cam_TiffFileWriteMode{i,1}  = [char(camPVs(i)), ':TIFF:FileWriteMode']; 
    param.DAQPVs.cam_TiffNumCapturedRBV{i,1} = [char(camPVs(i)), ':TIFF:NumCaptured_RBV']; 
    param.DAQPVs.cam_TiffNumCapture{i,1}     = [char(camPVs(i)), ':TIFF:NumCapture']; 
    param.DAQPVs.cam_TiffSetPort{i,1}        = [char(camPVs(i)), ':TIFF:SetPort'];
    param.DAQPVs.cam_DataType{i,1}           = [char(camPVs(i)), ':DataType'];
end   
