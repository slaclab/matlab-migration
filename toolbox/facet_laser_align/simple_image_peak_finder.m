% this file takes in an image, performs the projections and returns the
% peaks as the center points.  It for fitting very clear signals only.


function [x_out, y_out] = simple_image_peak_finder(image_in)


x_proj = sum(image_in,1);
y_proj = sum(image_in,2);

[~,x_out] = max(x_proj);
[~,y_out] = max(y_proj);