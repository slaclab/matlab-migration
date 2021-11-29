function rawImg = imgAcq_epics_getSavedBgImg(camera)
%imgAcq_epics_getSavedBgImg Get a RAWIMG struct for the saved background
%image from the specified camera.
%  rawImg = imgAcq_epics_getSavedBgImg(camera) returns a RAWIMG struct for
%  the saved background image from the camera specified by the CAMERA
%  struct.
%
%  Example:
%       rawImg = imgAcq_epics_getSavedBgImg(camera)
%
%  See also imgData_construct_camera, imgData_construct_rawImg,
%  imgAcq_initCameraProperties
%
%  S. Chevtsov (chevtsov@slac.stanford.edu)


rawImg = imgData_construct_rawImg();
if ~camera.features.screen
    return;
end
try
    width = lcaGet ([camera.pvPrefix ':B_ROI_XNP']);
    height = lcaGet ([camera.pvPrefix ':B_ROI_YNP']);
    epicsWf = lcaGet ([camera.pvPrefix ':B_IMAGE'], height*width);
    offsetX = lcaGet ([camera.pvPrefix ':B_ROI_X']);
    offsetY = lcaGet ([camera.pvPrefix ':B_ROI_Y']);
    
    bgImgData = reshape(epicsWf, width, height)';
    % BG image may be of different size/at different offset 
    % than images from camera
    bgImgData = fitToCamera(bgImgData, offsetX, offsetY, camera);
catch
    bgImgData = [];
end

rawImg.data = bgImgData;
rawImg.ignore = 0;
rawImg.timestamp = imgAcq_epics_getSavedBgImgTs(camera);

%%%%%%%%%%%%%%%%%%
function bgImgData = fitToCamera(bgImgData, offsetX, offsetY, camera)
try
%   ALGORITHM =>
%   1. Create a huge hypothetical image <OVERLAP> with offset (0,0) that overlaps
%   both, BG and camera images.
%   2. Copy data from BG image into <OVERLAP>.
%   3. Extract from <OVERLAP> the piece that fits the camera image.
%
    maxBgX = offsetX + size(bgImgData, 2);
    maxBgY = offsetY + size(bgImgData, 1);
    maxCamX = camera.img.offset.x + camera.img.width;
    maxCamY = camera.img.offset.y + camera.img.height;
%1. Create <OVERLAP>
    maxOverlapX = max(maxBgX, maxCamX);
    maxOverlapY = max(maxBgY, maxCamY);
    overlap = zeros(maxOverlapY, maxOverlapX);
    
%2. Copy data from BG image into <OVERLAP>.
    overlap(offsetY + 1: maxBgY, offsetX + 1 : maxBgX) = bgImgData;

%3. Extract from <OVERLAP> the piece that fits the camera image.
    bgImgData = overlap(camera.img.offset.y + 1 : maxCamY,...
        camera.img.offset.x + 1 : maxCamX);
catch
    return;
end