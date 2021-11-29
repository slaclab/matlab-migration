function output = small_ROI(output, images, img_size)

ROI_XNP = floor( min(size(images,2), img_size/output.cal) );
ROI_YNP = floor( min(size(images,1), img_size/output.cal) );

% images = rm_bkg(images);

avg_img = uint16(sum(images,3)/size(images,3));
filt_img = filter2(ones(10), avg_img);

[v, ind] = max(filt_img(:));
[mean_y, mean_x] = ind2sub(size(filt_img), ind);

ROI_X = floor( max(1, mean_x-ROI_XNP/2) );
ROI_X = floor( min(size(images,2)-ROI_XNP, ROI_X) );
ROI_Y = floor( max(1, mean_y-ROI_YNP/2) );
ROI_Y = floor( min(size(images,1)-ROI_YNP, ROI_Y) );

output.images(:,:,:) = images(ROI_Y:ROI_Y+ROI_YNP, ROI_X:ROI_X+ROI_XNP, :);
output.avg_image = avg_img(ROI_Y:ROI_Y+ROI_YNP, ROI_X:ROI_X+ROI_XNP);

end




