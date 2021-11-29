function param = FACET_ROIs(param)
% This function sets the ROI for each camera to save

CAMS = param.cams;

for i=1:param.num_CAM
    
    lcaPut([CAMS{i} ':ROI:EnableCallbacks'],1);
    
    if strncmp(CAMS{i},'CMOS',4)
        x_size = lcaGet([CAMS{i} ':ROI:SizeX_RBV']);
        y_size = lcaGet([CAMS{i} ':ROI:SizeY_RBV']);
        if x_size < 2
            x_size = lcaGet([CAMS{i} ':MaxSizeX_RBV']);
            lcaPut([CAMS{i} ':ROI:SizeX'],x_size);
        end
        if y_size < 2
            y_size = lcaGet([CAMS{i} ':MaxSizeY_RBV']);
            lcaPut([CAMS{i} ':ROI:SizeY'],y_size);
        end
        
    else
        x_size = lcaGet([CAMS{i} ':SizeX_RBV']);
        y_size = lcaGet([CAMS{i} ':SizeY_RBV']);
    
        lcaPut([CAMS{i} ':ROI:SizeX'],x_size);
        lcaPut([CAMS{i} ':ROI:SizeY'],y_size);
    end
    
end
