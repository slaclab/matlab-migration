function ipOutputCellArray = imgProcessing_processDataset(ds, ipParam, progHandles)
%IMGPROCESSING_PROCESSDATASET returns a column cell array of image processing output structures.
%   DS is a dataset of images
%   IPPARAM contains image processing parameters
%   PROGHANDLES is an optional parameter that contains a handles structure of a 
%   progress figure (see GUIHANDLES)
%
%   IPOUTPUTCELLARRAY = IMGPROCESSING_PROCESSDATASET returns a column cell
%   array of image processing output structures.
%
% See also IMGDATA_CONSTRUCT_DATASET, IMGDATA_CONSTRUCT_IPPARAM,
% IMGPROCESSING_PROCESSRAWIMG

if nargin < 3
    progHandles = [];
end

bgImg = [];
if ipParam.subtractBg.acquired
    bgImg = imgUtil_averageDsImgs(ds, 1, ds.nrBgImgs);
end

nrImgs = size(ds.rawImg, 2);

progData = progress_panel_update(progHandles, [], 'start');

ipOutputCellArray = cell(nrImgs);
for i=1:nrImgs
    progData.message = sprintf('Processing image #%d...', i);
    progData.value = (i-0.5)/nrImgs;
    progress_panel_update(progHandles, progData);

    if i <= ds.nrBgImgs
        %no processing of BG images
        ipOutputCellArray{i} = imgUtil_rawImg2ipOutput(ds.rawImg{i}, ds.camera);
    else
        ipOutputCellArray{i} = imgProcessing_processRawImg(...
            ds.rawImg{i}, ds.camera, ipParam, bgImg);
    end
end
progress_panel_update(progHandles, [], 'stop');