function highResDMD=camera2DMD(img,degree,ratio1,ratio2,rCenter1,rCenter2,handedness)
%this function maps the camera image to the DMD, given the rotation angle,
%and the correspondence between camera and DMD pixels

% Dimensions of the DMD (in pixels).
dmd2 = 1024;
dmd1 = 768;

if handedness==0
    img=spatMod_flipLeftRight(img);
    %dmdCenter2=size(img,2)-rCenter2+1;
end
dmdCenter2=rCenter2;
dmdCenter1=rCenter1;

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
highResDMD=zeros(dmd1,dmd2);
%first quadrant
for j=1:dmd1/2
    for i=1:dmd2/2
        cind2=dmdCenter2-(dmd2/2-(i-1))*ratio2;
        cind1=dmdCenter1-(dmd1/2-(j-1))*ratio1;
        if round(cind2)>0 && round(cind2)<size2 && round(cind1)>0 && round(cind1)<size1
            highResDMD(j,i)=highResImg(round(cind1),round(cind2));
        end
    end
end
%second quadrant
for j=1:dmd1/2
    for i=1+dmd2/2:dmd2
        cind2=dmdCenter2+(i-dmd2/2)*ratio2;
        cind1=dmdCenter1-(dmd1/2-(j-1))*ratio1;
        if round(cind2)>0 && round(cind2)<size2 && round(cind1)>0 && round(cind1)<size1
            highResDMD(j,i)=highResImg(round(cind1),round(cind2));
        end
    end
end
%third quadrant
for j=1+dmd1/2:dmd1
    for i=1:dmd2/2
        cind2=dmdCenter2-(dmd2/2-(i-1))*ratio2;
        cind1=dmdCenter1+(j-dmd1/2)*ratio1;
        if round(cind2)>0 && round(cind2)<size2 && round(cind1)>0 && round(cind1)<size1
            highResDMD(j,i)=highResImg(round(cind1),round(cind2));
        end
    end
end
%fourth quadrant
for j=1+dmd1/2:dmd1
    for i=1+dmd2/2:dmd2
        cind2=dmdCenter2+(i-dmd2/2)*ratio2;
        cind1=dmdCenter1+(j-dmd1/2)*ratio1;
        if round(cind2)>0 && round(cind2)<size2 && round(cind1)>0 && round(cind1)<size1
            highResDMD(j,i)=highResImg(round(cind1),round(cind2));
        end
    end
end
%figure(99);imagesc(highResDMD);


end