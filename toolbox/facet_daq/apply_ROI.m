%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply_ROI : Function to apply ROI of given
%             size to images, centering ROI
%             uniquely on each image.
%
% NOTE: ROI for x is applied to dim. 2 of image
%       and ROI for y is applied to dim. 1.
%
% M.Litos
% Mar. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [roi_images centr ROI] = apply_ROI(images,ROI_size,ROI_centr)

nshot = size(images,3);
means = zeros(2,nshot);
ROI   = zeros(4,nshot);
roi_images = zeros(ROI_size(2),ROI_size(1),nshot,'uint16');

% loop over images
for ishot = 1 : nshot;
   
    % make a copy of this image
    img = images(:,:,ishot);
    
%     figure(4);
%     pcolor(img), shading flat, ...
%         colorbar, ...
%         daspect([1 1 1]);

    % first apply global ROI...
    % ROI(1), ROI(2) : x min., x max.
    % ROI(3), ROI(4) : y min., y max.
    roi_x = ROI_size(1);
    min_x = round(ROI_centr(1)-roi_x/2);
    max_x = min_x + roi_x - 1;
    roi_y = ROI_size(2);
    min_y = round(ROI_centr(2)-roi_y/2);
    max_y = min_y + roi_y - 1;
    iROI  = [min_x max_x min_y max_y];
    
    
    nx = size(img,2);
    ny = size(img,1);
    
    % make sure ROI is within dimensions of images
    if (iROI(1)<1 ); iROI(1) =  1; iROI(2) = iROI(1)+(roi_x-1); end%if
    if (iROI(2)>nx); iROI(2) = nx; iROI(1) = iROI(2)-(roi_x-1); end%if
    if (iROI(3)<1 ); iROI(3) =  1; iROI(4) = iROI(3)+(roi_y-1); end%if
    if (iROI(4)>ny); iROI(4) = ny; iROI(3) = iROI(4)-(roi_y-1); end%if
    
    % if ROI exceeds dimensions of image, pad with zeros
    if iROI(1) < 1
        prepad_x = 1 - iROI(1);
        img = padarray(img,[0 prepad_x],'pre');
        iROI(1) = 1;
        iROI(2) = iROI(2) + prepad_x;
    end
    if iROI(2) > nx
        postpad_x = iROI(2) - nx;
        img = padarray(img,[0 postpad_x],'post');
    end
    if iROI(3) < 1
        prepad_y = 1 - iROI(3);
        img = padarray(img,[0 prepad_y],'pre');
        iROI(3) = 1;
        iROI(4) = iROI(4) + prepad_y;
    end
    if iROI(4) > ny
        postpad_y = iROI(4) - ny;
        img = padarray(img,[0 postpad_y],'post');
    end
    
    
    
    
    % apply ROI to image
    img = img(iROI(3):iROI(4), iROI(1):iROI(2));
    
    
%     
%     figure(6);
%     pcolor(img), shading flat, ...
%         colorbar, ...
%         daspect([1 1 1]);
    
    
    % create projections along axes
    proj_x = sum(img,1);
    proj_y = sum(img,2)';

    % make array of pixel positions
    nx   = length(proj_x);
    px_x = [1:nx];
    ny   = length(proj_y);
    px_y = [1:ny];
   
    % calc. mean_5%
    [rms5_x mean5_x] = calc_rms(proj_x,px_x,0.05);
    [rms5_y mean5_y] = calc_rms(proj_y,px_y,0.05);

    % save means
    centr(1,ishot) = mean5_x + iROI(1) - 1;
    centr(2,ishot) = mean5_y + iROI(3) - 1;
    
    
%     % define the ROI
%     % ROI(1), ROI(2) : x min., x max.
%     % ROI(3), ROI(4) : y min., y max.
%     roi_x = ROI_size(1);
%     min_x = round(mean5_x-roi_x/2);
%     max_x = min_x + roi_x - 1;
%     roi_y = ROI_size(2);
%     min_y = round(mean5_y-roi_y/2);
%     max_y = min_y + roi_y - 1;
%     iROI  = [min_x max_x min_y max_y];
% 
%     % make sure ROI is within dimensions of images
%     if (iROI(1)<1 ); iROI(1) =  1; iROI(2) = iROI(1)+(roi_x-1); end%if
%     if (iROI(2)>nx); iROI(2) = nx; iROI(1) = iROI(2)-(roi_x-1); end%if
%     if (iROI(3)<1 ); iROI(3) =  1; iROI(4) = iROI(3)+(roi_y-1); end%if
%     if (iROI(4)>ny); iROI(4) = ny; iROI(3) = iROI(4)-(roi_y-1); end%if
%     
%     % if ROI exceeds dimensions of image, pad with zeros
%     if iROI(1) < 1
%         prepad_x = 1 - iROI(1);
%         img = padarray(img,[0 prepad_x],'pre');
%         iROI(1) = 1;
%         iROI(2) = iROI(2) + prepad_x;
%     end
%     if iROI(2) > nx
%         postpad_x = iROI(2) - nx;
%         img = padarray(img,[0 postpad_x],'post');
%     end
%     if iROI(3) < 1
%         prepad_y = 1 - iROI(3);
%         img = padarray(img,[0 prepad_y],'pre');
%         iROI(3) = 1;
%         iROI(4) = iROI(4) + prepad_y;
%     end
%     if iROI(4) > ny
%         postpad_y = iROI(4) - ny;
%         img = padarray(img,[0 postpad_y],'post');
%     end

    % save ROIs
    ROI(:,ishot) = iROI;
    
    
%     figure(5);
%     pcolor(img), shading flat, ...
%         colorbar, ...
%         daspect([1 1 1]);
    

    % add ROI image to array
    roi_images(:,:,ishot) = img;
    
end%for

end%function