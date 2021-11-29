function ts = imgAcq_epics_getSavedBgImgTs(camera)
%imgAcq_epics_getSavedBgImgTs Get the MATLAB timestamp of when the saved
%background image for the specified camera was saved. 
%  val = imgAcq_epics_getSavedBgImgTs() returns MATLAB timestamp of when
%  the saved background image for the camera specified by the CAMERA struct
%  was saved. 
%
%  Example:
%       ts = imgAcq_epics_getSavedBgImgTs(camera)
%
%  See also imgData_construct_camera, imgAcq_initCameraProperties, now
%
%  S. Chevtsov (chevtsov@slac.stanford.edu)

ts = -1;
if ~camera.features.screen
    return;
end
try
    ts = sqrt(-1) * lcaGet([camera.pvPrefix ':B_TOD_TSI']) +...
        lcaGet ([camera.pvPrefix ':B_TOD_TSR']);
catch
    %do nothing
end