function rawImg = imgData_construct_rawImg()
rawImg.customCropArea = zeros(0); %[xmin ymin width height] default spatial coordinates
rawImg.data = []; %2D
rawImg.ignore = []; %[], 0, or 1
rawImg.timestamp = -1; %lca
