function [xCoords, yCoords] = imgAcq_epics_getGoldenOrbitCentroid(camera)
%imgAcq_epics_getGoldenOrbitCentroid Retrieve the coordinates of the golden 
%orbit centroid of the specified camera (in pixels).
%  [xCoords, yCoords] = imgAcq_epics_getGoldenOrbitCentroid(camera) returns
%  two arrays of golden orbit centroid coordinates (one pair of coordinates
%  per algorithm used to calculate them) in pixels.
%
%  Example:
%       [xCoords, yCoords] = imgAcq_epics_getGoldenOrbitCentroid(camera);
%
%  See also imgData_construct_camera, imgAcq_initCameraProperties

%  S. Chevtsov (chevtsov@slac.stanford.edu)

xCoords = [];
yCoords = [];
if ~camera.features.centroid.goldenOrbit
    return;
end
try
    xCoords = lcaGet([camera.pvPrefix ':CENT_GO_X']);
    %convert from um to pix
    xCoords = round(xCoords / camera.img.resolution);
    
    yCoords = lcaGet([camera.pvPrefix ':CENT_GO_Y']);
    %convert from um to pix
    yCoords = round(yCoords / camera.img.resolution);
catch
    %do nothing
end