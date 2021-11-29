function camera = imgAcq_epics_getCameraParam(camera)
%imgAcq_epics_getCameraParam Retrieve camera parameters. 
%  camera = imgAcq_epics_getCameraParam(camera) fills out the fields of the
%  specified CAMERA struct with values from the IOC.
%
%  Example:
%       camera = imgAcq_epics_getCameraParam(camera)
%
%  See also imgData_construct_camera, imgAcq_initCameraProperties

%  S. Chevtsov (chevtsov@slac.stanford.edu)

pvPrefix = camera.pvPrefix;

try
    camera.bufferSize = abs(lcaGet([pvPrefix ':IMG_BUF_IDX.LOPR']));
catch
    %do nothing
end
try
    camera.img.colorDepth = lcaGet([pvPrefix ':N_OF_BITS']);
catch
    %do nothing
end
try
    camera.img.resolution = lcaGet([pvPrefix ':RESOLUTION']);
catch
    %do nothing
end
%optional features
if camera.features.img.roi
    try
        camera.img.offset.x = lcaGet([pvPrefix ':ROI_X']);%for testing
    catch
        %do nothing
    end
    try
        camera.img.offset.y = lcaGet([pvPrefix ':ROI_Y']);
    catch
        %do nothing
    end
    try
        camera.img.width = lcaGet([pvPrefix ':ROI_XNP']);
    catch
        %do nothing
    end
    try
        camera.img.height = lcaGet([pvPrefix ':ROI_YNP']);
    catch
        %do nothing
    end
else
    try
        camera.img.height = lcaGet([pvPrefix ':N_OF_ROW']); 
    catch
        %do nothing
    end
    try   
        camera.img.width = lcaGet([pvPrefix ':N_OF_COL']); 
    catch
        %do nothing
    end  
end
if camera.features.img.orient
    try
        camera.img.flip.x = strcmpi(lcaGet([pvPrefix, ':X_ORIENT']), 'negative');
    catch
        %do nothing
    end
    try
	%matlab y-axes for image goes from top to bottom
        camera.img.flip.y = ~strcmpi(lcaGet([pvPrefix, ':Y_ORIENT']), 'negative');
    catch
        %do nothing
    end
end
if camera.features.img.origin
    %needs flip parameters
    try
        xOrigin = lcaGet([pvPrefix ':X_RTCL_CTR']); %pix
        if ~camera.img.flip.x
            %see Matlab coordinate system for images
            xOrigin = camera.img.width - (xOrigin - camera.img.offset.x);
        end
        camera.img.origin.x = xOrigin;
    catch
        %do nothing
    end
    try
        yOrigin = lcaGet([pvPrefix ':Y_RTCL_CTR']); %pix
        if camera.img.flip.y 
        end
        camera.img.origin.y = camera.img.height - (yOrigin - camera.img.offset.y);
    catch
        %do nothing
    end
end

