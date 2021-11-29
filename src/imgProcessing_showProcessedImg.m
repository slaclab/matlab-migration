function imgProcessing_showProcessedImg(imgAxes, ipParam, ipOutput, camera)

if nargin < 4
    camera = [];
end

cla(imgAxes);
imgUtil_showPixelImgOnAxes(ipOutput.procImg, imgAxes, ipOutput.offset.x, ipOutput.offset.y);

pos = get(imgAxes, 'position');
lineWidth = min(pos(3), pos(4))*ipParam.lineWidthFactor;
lineWidth = max(0.5, lineWidth);
lineWidth = min(4, lineWidth);

imgProcessing_annotation_showSlice(imgAxes, ipParam.slice, lineWidth);
imgProcessing_annotation_handleCentroids(imgAxes, ipParam, ipOutput, lineWidth);

if ~isempty(camera) && strcmpi(ipParam.beamSizeUnits, 'um')
    imgProcessing_pixel2Micron(imgAxes, camera);
end

if strcmpi(get(imgAxes, 'visible'), 'on')
    imgProcessing_annotation_showAxesLabel(imgAxes, ipParam);
end