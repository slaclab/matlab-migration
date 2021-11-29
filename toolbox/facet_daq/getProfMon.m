function output = getProfMon(CAM_PV)

img = lcaGetSmart(strcat(CAM_PV, ':IMAGE'));
output.ROI_X = lcaGetSmart(strcat(CAM_PV, ':ROI_X'));
output.ROI_Y = lcaGetSmart(strcat(CAM_PV, ':ROI_Y'));
output.ROI_XNP = lcaGetSmart(strcat(CAM_PV, ':ROI_XNP'));
output.ROI_YNP = lcaGetSmart(strcat(CAM_PV, ':ROI_YNP'));
output.RESOLUTION = lcaGetSmart(strcat(CAM_PV, ':RESOLUTION'));
output.X_RTCL_CTR = lcaGetSmart(strcat(CAM_PV, ':X_RTCL_CTR'));
output.Y_RTCL_CTR = lcaGetSmart(strcat(CAM_PV, ':Y_RTCL_CTR'));
output.X_ORIENT = lcaGetSmart(strcat(CAM_PV, ':X_ORIENT'));
output.Y_ORIENT = lcaGetSmart(strcat(CAM_PV, ':Y_ORIENT'));


if size(img,2)>1
	output.img = reshape(img(1, 1:(output.ROI_XNP*output.ROI_YNP)), output.ROI_XNP, output.ROI_YNP)';
else
	output.img = 0;
	disp('Image not taken.');
end


end







