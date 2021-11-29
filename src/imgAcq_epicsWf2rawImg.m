function rawImg = imgAcq_epicsWf2rawImg(camera, epicsWf, ts)
height = camera.img.height;
width = camera.img.width;
imgSize = height * width;

try
    epicsWf = epicsWf(1:imgSize);
catch
    %fill up with 0
    wfSize = size(epicsWf,2);
    zeroArray = zeros(1, imgSize - wfSize);
    epicsWf = [epicsWf zeroArray];
end
%create 2D
rawImgData = reshape(epicsWf, width, height)';

% See if we need to flip in the X and/or Y direction
if camera.img.flip.x
    rawImgData = flipdim(rawImgData, 2);
end
if camera.img.flip.y
    rawImgData = flipdim(rawImgData, 1);
end

rawImg = imgData_construct_rawImg();
rawImg.data = rawImgData;
rawImg.timestamp = ts;