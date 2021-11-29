%to keep with matlab's style, the first element slice is 1 (not zero)
function [startIndex, endIndex] = imgUtil_getArraySliceBounds(arrayLength, sliceIndex, nrSlices)
% both inclusive
% currently, produces disjoint slices
sliceSize = arrayLength/nrSlices; %might be non-integer
%Matlab arrays start with index 1
startIndex = round(sliceSize * (sliceIndex - 1)) + 1;
%endIndex >= startIndex
endIndex = max(startIndex, round(sliceSize * sliceIndex));