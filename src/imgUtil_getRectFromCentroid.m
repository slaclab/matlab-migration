function rect = imgUtil_getRectFromCentroid(centroidCoords, width, height)
% This function returns a regular Matlab rectangle from the specified
% centroid coordinates, width, and height

x = floor(centroidCoords(1) - width/2);
y = floor(centroidCoords(2) - height/2);

rect = [x y width height];
