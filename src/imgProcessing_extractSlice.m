function sliceImg = imgProcessing_extractSlice(img, sliceParam)

if ndims(img) > 3 || ndims(img) < 2
    disp('img must be a 2 or 3 dimensional array');
    return;
end

if sliceParam.index > sliceParam.total || sliceParam.index < 1
    disp('sliceParam index out of boundaries');
    return;
end
[nrRows, nrCols] = size(img);

isSlicePlaneX = strcmpi(sliceParam.plane, 'x');
if isSlicePlaneX
    %incl.
    [startIndex, endIndex] = ...
        imgUtil_getArraySliceBounds(nrRows, sliceParam.index, sliceParam.total);
    sliceImg = img(startIndex:endIndex, :, :);
else
    %incl.
     [startIndex, endIndex] = ...
        imgUtil_getArraySliceBounds(nrCols, sliceParam.index, sliceParam.total);
     sliceImg = img(:, startIndex:endIndex, :);
end
    