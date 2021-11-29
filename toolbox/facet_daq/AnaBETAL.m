function output = AnaBETAL(output)

mask_lower_left = [-23, 5]; % position in mm
mask_upper_right = [18, 15]; % position in mm

output.gamma_yield = sum(output.img(:));
[X, Y] = meshgrid(output.xx, output.yy);
new_img = fliplr(output.img);
new_img((X-0.).^2 + (Y-7.).^2 > 30^2) = 0;
new_img(X>mask_lower_left(1) & X<mask_upper_right(1) & ...
    Y>mask_lower_left(2) & Y<mask_upper_right(2)) = 0;
output.gamma_yield = sum(new_img(:));
filt_img = filter2(ones(5)/5^2, new_img);
output.gamma_max = max(filt_img(:));
% output.img = filt_img;

end











