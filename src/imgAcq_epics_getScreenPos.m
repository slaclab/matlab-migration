function val = imgAcq_epics_getScreenPos(camera)
%imgAcq_epics_getScreenPos Get the position of the screen of the specified
%camera.
%  val = imgAcq_epics_getScreenPos(camera) returns the position of the
%  screen of the cmaera specified by the CAMERA struct.
%
%  Example:
%       val = imgAcq_epics_getScreenPos(camera)
%
% See also imgData_construct_camera, imgAcq_initCameraProperties
%
%  S. Chevtsov (chevtsov@slac.stanford.edu)

val = 'N/A';
if ~camera.features.screen
    return;
end
try
    val = lcaGet([camera.pvPrefix ':POSITION']);
    val = val{1};
catch
    %do nothing
end