function fCameraArray = imgUtil_filterCameras(cameraArray, isProd)
fCameraArray = {};
for i=1:size(cameraArray, 2)
    if isequal(isProd, cameraArray{i}.isProd)
        fCameraArray{end+1} = cameraArray{i};
    end
end
