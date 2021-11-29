function [avgImgData, firstImgIndex] = imgUtil_averageDsImgs(ds, startIndex, endIndex)

if nargin < 2
    startIndex = 1;
end
if nargin < 3
    endIndex = size(ds.rawImg, 2);
end
avgImgData = [];
firstImgIndex = [];
try
    averageDsImgs();
catch
    %do nothing
end

%%%%%%%%%%%%
    function averageDsImgs()
        nrValidImgs = 0;
        sumImgData = 0;
        for i=startIndex:endIndex
            rawImg = ds.rawImg{i};
            if rawImg.ignore == 1
                continue;
            end
            if isempty(firstImgIndex)
                firstImgIndex = i;
            end
            sumImgData = sumImgData + rawImg.data;
            nrValidImgs = nrValidImgs + 1;
        end
        if nrValidImgs > 0
            avgImgData = double(round(sumImgData / nrValidImgs));
        end
    end
end
