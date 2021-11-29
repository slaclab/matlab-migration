function [background, param] = E200_takeBackground(param)

cams = param.cam_UNIQ;

set_2_9(1);
lcaPut('DO:LA20:10:Bo1',1);
pause(3);

img = lcaGetSmart(strcat(cams(:,2), ':IMAGE'));
ROI_X = lcaGetSmart(strcat(cams(:,2), ':ROI_X'));
ROI_Y = lcaGetSmart(strcat(cams(:,2), ':ROI_Y'));
ROI_XNP = lcaGetSmart(strcat(cams(:,2), ':ROI_XNP'));
ROI_YNP = lcaGetSmart(strcat(cams(:,2), ':ROI_YNP'));
RESOLUTION = lcaGetSmart(strcat(cams(:,2), ':RESOLUTION'));
X_ORIENT = lcaGetSmart(strcat(cams(:,2), ':X_ORIENT'));
Y_ORIENT = lcaGetSmart(strcat(cams(:,2), ':Y_ORIENT'));

if param.run_cmos; param = E200_cmosBackground(param); end

for i=1:size(img,1)
    if size(img,2)>1
        background.(char(cams(i,1))).img = reshape(img(i, 1:ROI_XNP(i)*ROI_YNP(i)), ROI_XNP(i), ROI_YNP(i))';
    else
        background.(char(cams(i,1))).img = 0;
        disp('Background not taken.');
    end
    background.(char(cams(i,1))).ROI_X = ROI_X(i);
    background.(char(cams(i,1))).ROI_Y = ROI_Y(i);
    background.(char(cams(i,1))).ROI_XNP = ROI_XNP(i);
    background.(char(cams(i,1))).ROI_YNP = ROI_YNP(i);
    background.(char(cams(i,1))).RESOLUTION = RESOLUTION(i);
    background.(char(cams(i,1))).X_ORIENT = X_ORIENT(i);
    background.(char(cams(i,1))).Y_ORIENT = Y_ORIENT(i);
end

set_2_9(0);
lcaPut('DO:LA20:10:Bo1',0);
end
