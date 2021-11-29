function imgAcq_epics_putLaserBeamCentroid(camera, xCoords, yCoords)
if ~camera.features.centroid.laserBeam
    return;
end
try
    %convert from pix to um
    xCoords = round(xCoords * camera.img.resolution);
    lcaPut([camera.pvPrefix ':CENT_LB_X'], xCoords);
    
    %convert from pix to um
    yCoords = round(yCoords * camera.img.resolution);
    lcaPut([camera.pvPrefix ':CENT_LB_Y'], yCoords);
catch
    %do nothing
end