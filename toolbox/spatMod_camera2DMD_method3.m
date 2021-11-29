function highResDMD=spatMod_camera2DMD_method3(img,degree,ratio1,ratio2,rCenter1,rCenter2,handedness)
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

% Image is the full laser beam image on the camera.
%img=spatMod_flipLeftRight(img);
[size1, size2] = size(img);

%create a meshgrid of the camera image. Rotate it ccw by -degree around the
%point where the DMD center is on the camera
[X, Y] = meshgrid(1:size2, 1:size1);
[xr2,yr2]=spatMod_rotateGrids(X,Y,dmdCenter1,dmdCenter2,degree);
highResImg=interp2(X,Y,double(img),xr2,yr2);
highResImg(isnan(highResImg)) = 0;

%map the camera image back on to the DMD map

x1=rCenter2-round(dmd2*ratio/2);
x2=rCenter2+round(dmd2*ratio/2);
y1=rCenter1-round(dmd1*ratio/2);
y2=rCenter1+round(dmd1*ratio/2);

cimg=highResImg(max(1,y1):min(size1,y2),max(1,x1):min(size2,x2));
if x1<1
    cimg=cat(2,zeros(size(cimg,1),abs(x1)+1),cimg);
end
if x2>size2
    cimg=cat(2,cimg,zeros(size(cimg,1),x2-size2));
end
if y1<1
   cimg=cat(1,zeros(abs(y1)+1,size(cimg,2)),cimg); 
end
if y2>size1
   cimg=cat(1,cimg,zeros(y2-size1,size(cimg,2))); 
end

highResDMD=spatMod_imageresize(cimg,dmd1/size(cimg,1),dmd2/size(cimg,2));
