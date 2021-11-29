function highResDMD=spatMod_camera2DMD_method2(img,degree,ratio1,ratio2,rCenter1,rCenter2,handedness)
%this function maps the camera image to the DMD, given the rotation angle,
%and the correspondence between camera and DMD pixels

% Dimensions of the DMD (in pixels).
dmd2 = 1024;
dmd1 = 768;

if handedness==0
    img=fliplr(img);
    %dmdCenter2=size(img,2)-rCenter2+1;
end
dmdCenter2=rCenter2;
dmdCenter1=rCenter1;

%ratio should be the mean of the two
ratio=(ratio1+ratio2)/2;

%crop the DMD dimension from camera image
left=0;right=0;top=0;bottom=0;
x1=max(1,round(dmdCenter2-dmd2/2*ratio));
x2=min(size(img,2),round(dmdCenter2+dmd2/2*ratio));
y1=max(1,round(dmdCenter1-dmd1/2*ratio));
y2=min(size(img,1),round(dmdCenter1+dmd1/2*ratio));
cimg=img(y1:y2,x1:x2);
left=[];right=[];top=[];bottom=[];
if x1==1 && x1~=round(dmdCenter2-dmd2/2*ratio)
    left=abs(round(dmdCenter2-dmd2/2*ratio));
end
if x2==size(img,2) && x2~=round(dmdCenter2+dmd2/2*ratio)
   right=round(dmdCenter2+dmd2/2*ratio)-size(img,2);
end
if y1==1 && y1~=round(dmdCenter1-dmd1/2*ratio)
    top=abs(round(dmdCenter1-dmd1/2*ratio));
end
if y2==size(img,1) && y2~=round(dmdCenter1+dmd1/2*ratio)
   bottom=round(dmdCenter1+dmd1/2*ratio)-size(img,1);
end
cimg=cat(2,zeros(size(cimg,1),left),cimg);
cimg=cat(2,cimg,zeros(size(cimg,1),right));
cimg=cat(1,zeros(top,size(cimg,2)),cimg);
cimg=cat(1,cimg,zeros(bottom,size(cimg,2)));


[X, Y] = meshgrid(1:size(cimg,2), 1:size(cimg,1));
[xr2,yr2]=spatMod_rotateGrids(X,Y,round(size(cimg,1)/2),round(size(cimg,2)/2),degree);
rimg=interp2(X,Y,double(cimg),xr2,yr2);
rimg(isnan(rimg)) = 0;

highResDMD=spatMod_imageresize(rimg,dmd1/size(rimg,1),dmd2/size(rimg,2));