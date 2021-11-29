function [xCoords, yCoords] = imgAcq_epics_getLaserBeamCentroid(camera)
%imgAcq_epics_getLaserBeamCentroid Retrieve the coordinates of the laser
%beam centroid of the specified camera (in pixels).
%  [xCoords, yCoords] = imgAcq_epics_getLaserBeamCentroid(camera) returns
%  two arrays of laser beam centroid coordinates (one pair of coordinates
%  per algorithm used to calculate them) in pixels.
%
%  Example:
%       [xCoords, yCoords] = imgAcq_epics_getLaserBeamCentroid(camera);
%
%  See also imgData_construct_camera, imgAcq_initCameraProperties

%  S. Chevtsov (chevtsov@slac.stanford.edu)

xCoords = [];
yCoords = [];
if ~camera.features.centroid.laserBeam
    return;
end
try
    xCoords = lcaGet([camera.pvPrefix ':CENT_LB_X']);
    %convert from um to pix
    xCoords = round(xCoords / camera.img.resolution);
    
    yCoords = lcaGet([camera.pvPrefix ':CENT_LB_Y']);
    %convert from um to pix
    yCoords = round(yCoords / camera.img.resolution);
catch
    %do nothing
end