function rawImg = imgAcq_epics_getLiveImg(camera)
%imgAcq_epics_getLiveImg Get a RAWIMG struct for the live image from the
%specified camera.
%  rawImg = imgAcq_epics_getLiveImg(camera) returns a RAWIMG struct for the
%  live image from the camera specified by the CAMERA struct.
%
%  Example:
%       rawImg = imgAcq_epics_getLiveImg(camera)
%
%  See also imgData_construct_camera, imgData_construct_rawImg,
%  imgAcq_initCameraProperties, imgAcq_epicsWf2rawImg
%
%  S. Chevtsov (chevtsov@slac.stanford.edu)

try
    [epicsWf, ts] = lcaGet([camera.pvPrefix ':IMAGE'], camera.img.width * camera.img.height);
catch
    epicsWf = [];
    ts = -1;
end

rawImg  = imgAcq_epicsWf2rawImg(camera, epicsWf, ts);
