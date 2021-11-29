function imgAcq_epics_putGoldenOrbitCentroid(camera, xCoords, yCoords)
if ~camera.features.centroid.goldenOrbit
    return;
end
try
    %convert from pix to um
    xCoords = round(xCoords * camera.img.resolution);
    lcaPut([camera.pvPrefix ':CENT_GO_X'], xCoords);
    
    %convert from pix to um
    yCoords = round(yCoords * camera.img.resolution);
    lcaPut([camera.pvPrefix ':CENT_GO_Y'], yCoords);
catch
    %do nothing
end