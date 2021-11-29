function imgAcq_epics_putAvgBgImg(camera, dsIndex)

if ~camera.features.screen
    %do nothing
    return;
end

global gIMG_MAN_DATA;
ds = gIMG_MAN_DATA.dataset{dsIndex};
[avgBgImg, firstImgIndex] = imgUtil_averageDsImgs(ds, 1,  ds.nrBgImgs);
if isempty(avgBgImg)
    avgBgImg = 0;
end
%
if isempty(firstImgIndex)
    firstImgIndex = 1;    
end
[height, width] = size(avgBgImg);
wf = double(reshape(avgBgImg', 1, height * width));

firstRawImg = ds.rawImg{firstImgIndex};

pvPrefix = camera.pvPrefix;

try
    lcaPut([pvPrefix ':B_IMAGE'], wf);
catch
    %do nothing
end

try
    lcaPut([pvPrefix ':B_N_OF_BITS'], ds.camera.img.colorDepth);
catch
    %do nothing
end

try
    lcaPut([pvPrefix ':RESOLUTION'], ds.camera.img.resolution);
catch
    %do nothing
end

try
    lcaPut([pvPrefix ':B_ROI_Y'], camera.img.offset.y);
catch
    %do nothing
end
try
    lcaPut([pvPrefix ':B_ROI_X'], camera.img.offset.x);
catch
    %do nothing
end

try
    lcaPut([pvPrefix ':B_ROI_YNP'], height);
catch
    %do nothing
end
try
    lcaPut([pvPrefix ':B_ROI_XNP'], width);
catch
    %do nothing
end

%timestamp as string of when BG image was taken (for verification)
try
    lcaPut([pvPrefix ':B_TOD'], imgUtil_matlabTime2String(lca2matlabTime(firstRawImg.timestamp)));
catch
    %do nothing
end

%imaginary part of the lca timestamp
try
    lcaPut([pvPrefix ':B_TOD_TSI'], imag(firstRawImg.timestamp));
catch
    %do nothing
end

%real part of the lca timestamp
try
    lcaPut([pvPrefix ':B_TOD_TSR'], real(firstRawImg.timestamp));
catch
    %do nothing
end