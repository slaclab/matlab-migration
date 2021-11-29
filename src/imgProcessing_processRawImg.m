% note to self:
% if bgImg is not empty, it is subtracted from rawImg.data; 
% otherwise, depending on the value of ipParam.subtractBg.calculated 
% a calculated background noise may be subtracted (or no bg subtraction
% happens at all)
function ipOutput = imgProcessing_processRawImg(rawImg, camera, ipParam, bgImg) 
ipOutput = imgData_construct_ipOutput();

if nargin < 4
    bgImg = [];
end

customCropArea = rawImg.customCropArea;
origImg = rawImg.data;

if isempty(origImg)
    % do nothing
    return;
end

try
    [procImg, isImgValid, xData, yData, opts, bgs] = ...
        imgProc(origImg, bgImg, camera.img.colorDepth, ipParam);

    %to be sure
    if ipParam.crop.custom && ~ipParam.crop.auto
        [procImg, xData, yData] = doCustomCropping(procImg, customCropArea);
    end
    
    ipOutput.isValid = isImgValid;
    ipOutput.procImg = procImg;
 
    xData = xData + camera.img.offset.x;
    yData = yData + camera.img.offset.y;    
    ipOutput.offset.x = xData(1) - 1;
    ipOutput.offset.y = yData(1) - 1;
    
    beamlist = getBeamParamsFromSlice(procImg, ipParam.slice, xData, yData, bgs, opts);

    ipOutput.beamlist = beamlist;

catch
    imgUtil_notifyLastError();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img, isValid, xData, yData, opts, bgs] = imgProc(img, bgImg, colorDepth, ipParam)
fullImgSize = size(img);

%Henrik's algorithm
opts.back =  ipParam.subtractBg.acquired || ipParam.subtractBg.calculated;
opts.crop = ipParam.crop.auto;
opts.debug = 0;
opts.floor = ipParam.filter.floor;
opts.median = ipParam.filter.median;

if opts.back && ~isempty(bgImg)
    bgImgSize = size(bgImg);
    if ~isequal(fullImgSize, bgImgSize)
    %if bg image isn't of the same size
        bgImg = [];
    end
end

data.back = bgImg;
data.bitdepth = colorDepth;
data.full = img;

[img, xsub, ysub, flag, bgs] = beamAnalysis_imgProc(data, opts);

if ~opts.crop
    %Henrik's algorithm returns xsub, ysub for cropped region even if the
    %image is actually not cropped
    xData = 1:fullImgSize(2);
    yData = 1:fullImgSize(1);
else
    xData = xsub;
    yData = ysub;
end
isValid = ~flag;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img, xData, yData] = doCustomCropping(img, cropArea)
imgSize = size(img);
if isempty(cropArea)
    xData = 1:imgSize(2);
    yData = 1:imgSize(1);
else
    [xData, yData] = imgProcessing_getSubPixelRegion(img, cropArea);
    %rows, cols
    img = img(yData, xData);
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beamlist = getBeamParamsFromSlice(img, sliceParam, xData, yData, bgs, opts)
if sliceParam.total > 1
    isSlicePlaneX = strcmpi(sliceParam.plane, 'x');
    if isSlicePlaneX
        %recalculate yData
        [startIndex, endIndex] = imgUtil_getArraySliceBounds(size(yData, 2), ...
            sliceParam.index, sliceParam.total);
        yDataMin = yData(1) + startIndex - 1;
        yDataMax = yData(1) + endIndex - 1;            
        yData = yDataMin:yDataMax;
    else
        %recalculate xData
        [startIndex, endIndex] = imgUtil_getArraySliceBounds(size(xData, 2), ...
            sliceParam.index, sliceParam.total);
        xDataMin = xData(1) + startIndex - 1;
        xDataMax = xData(1) + endIndex - 1;   
        xData = xDataMin:xDataMax;
    end
    %get slice data
    img = imgProcessing_extractSlice(img, sliceParam);
end

%Henrik's algorithm
beamlist = beamAnalysis_beamParams(img, xData, yData, bgs, opts);


