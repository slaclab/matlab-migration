function rawImg = imgAcq_epics_getBufferedImg(camera, imgBufIndex)
%imgAcq_epics_getBufferedImg Retrieve an image from the camera buffer. 
%  rawImg = imgAcq_epics_getBufferedImg(camera, imgBufIndex) returns a
%  RAWIMG struct for the image at the position IMGBUFINDEX from the buffer 
%  of the camera specified by the CAMERA structure. 
%
%  Example:
%       rawImg = imgAcq_epics_getBufferedImg(camera, -1);
%
%  See also imgData_construct_camera, imgData_construct_rawImg,
%  imgAcq_initCameraProperties

%  S. Chevtsov (chevtsov@slac.stanford.edu)

pvPrefix = camera.pvPrefix;

lcaPut ([pvPrefix ':IMG_BUF_IDX'], imgBufIndex);
pause(0.05); % give IOC time to load BUFD_IMG

try
    [epicsWf, ts] = lcaGet([pvPrefix ':BUFD_IMG']);
catch
    epicsWf = [];
    ts = -1;
end
rawImg = imgAcq_epicsWf2rawImg(camera, epicsWf, ts);