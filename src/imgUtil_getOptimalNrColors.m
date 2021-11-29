function nrColors = imgUtil_getOptimalNrColors(rawImgArray)
if ~iscell(rawImgArray)
    rawImgArray = {rawImgArray};
end
nrColors = -1;
for i=1:size(rawImgArray, 2)
    if rawImgArray{i}.ignore
        continue;
    end
    maxVal = max(max(rawImgArray{i}.data));
    bpp = ceil(log2(maxVal));
    nrColors = max(nrColors, 2^bpp);
end