function [xx, yy] = CalculateAxes(im_dat)

% Convert pixels to mm
if numel(im_dat.res) == 2
    xx = im_dat.res(1)/1000*((1:im_dat.roiXN)-im_dat.centerX+im_dat.roiX);
    yy = -im_dat.res(2)/1000*((1:im_dat.roiYN)-im_dat.centerY+im_dat.roiY);
else
    xx = im_dat.res/1000*((1:im_dat.roiXN)-im_dat.centerX+im_dat.roiX);
    yy = -im_dat.res/1000*((1:im_dat.roiYN)-im_dat.centerY+im_dat.roiY);
end