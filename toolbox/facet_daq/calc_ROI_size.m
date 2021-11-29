%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calc_ROI_size : Function to calculate
%                 size of ROI for a collection
%                 of images.
%
% ROI_size(1)   : ROI size for x
% ROI_size(2)   : ROI size for y
%
% NOTE: ROI for x is applied to dim. 2 of image
%       and ROI for y is applied to dim. 1.
%
% M.Litos
% Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ROI_size ROI_centr] = calc_ROI_size(images)

% create avg of all images
avg_img = uint16(round(sum(images,3)/size(images,3)));

% remove background of avg image
avg_img = rm_bkg(avg_img);

% get image size
nx = size(avg_img,2);
ny = size(avg_img,1);

% make array of pixel positions
px_x = [1:nx];
px_y = [1:ny];

% create normalized projections along axes
proj_x = sum(avg_img,1)/ny;
proj_y = sum(avg_img,2)'/nx;

% calc. RMS_5%
[rms5_x mean_x] = calc_rms(proj_x,px_x,0.05);
[rms5_y mean_y] = calc_rms(proj_y,px_y,0.05);

% set ROI center for avg image
ROI_centr = [mean_x mean_y];

% set ROI size to 6 times RMS_5%
ROI_size = [round(6*rms5_x) round(6*rms5_y)];

% correct ROI size if too large
if ROI_size(1) > size(avg_img,2)
    ROI_size(1) = size(avg_img,2);
end
if ROI_size(2) > size(avg_img,1)
    ROI_size(2) = size(avg_img,1);
end

end%function