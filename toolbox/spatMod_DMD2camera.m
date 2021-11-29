function [Cimg,cc1,cc2]=DMD2camera(DMDsmallimg,par1,original)
%this function takes in a small (it has to be a square) DMD image (where the beam is)
%and outputs the center of the camera image and the converted beam on
%camera plane

ratio1=par1(end,2);ratio2=par1(end,3);deg=par1(end,1);handedness=par1(end,8);
%apply ratio
ratio=mean([ratio1,ratio2]);
Cgoal1=spatMod_imageresize(DMDsmallimg,ratio,ratio);%should be a square
c1=floor((size(Cgoal1,1))/2);
c2=floor((size(Cgoal1,2))/2);

%apply rotation
[X, Y] = meshgrid(1:size(Cgoal1,2), 1:size(Cgoal1,1));
[xr2,yr2]=spatMod_rotateGrids(X,Y,c1,c2,-deg);
Cgoal2=interp2(X,Y,double(Cgoal1),xr2,yr2);
Cgoal2(isnan(Cgoal2)) = 0;
if handedness==0
   Cgoal2=spatMod_flipLeftRight(Cgoal2); 
end
pix0=Cgoal2<0;
Cgoal2(pix0)=0;%Cgoal2 should be a square too

%find beam center on camera
% px=sum(original,1);
% py=sum(original,2)';
% usex=find(px > max(px)/4);
% parx=polyfit(usex,px(usex),2);
% cc2=round(-parx(2)/2/parx(1));%beam center on camera
% x01=round((-parx(2)+sqrt(parx(2)^2-4*parx(1)*parx(3)))/(2*parx(1)));%find left edge
% x02=round((-parx(2)-sqrt(parx(2)^2-4*parx(1)*parx(3)))/(2*parx(1)));%find right edge
% usey=find(py > max(py)/3);
% pary=polyfit(usey,py(usey),2);
% cc1=round(-pary(2)/2/pary(1));%beam center on camera

[x01,x02,y01,y02]=spatMod_beamEdge(original,3);

% projx=sum(original,1);
% [x01,x02]=spatMod_edgeDetect1d(projx);
% projy=sum(original,2)';
% [y01,y02]=spatMod_edgeDetect1d(projy);
cc1=round((y01+y02)/2);
cc2=round((x01+x02)/2);

% %kludge
% [nrow, ~]=size(Cgoal2);
% [~, index]=size(cc1-c1:cc1+c1);
% n=index-nrow;

Cimg=zeros(size(original,1),size(original,2));

if mod(size(Cgoal2,1),2)==0 %dimension of Cgoal2 is even
    Cimg(cc1-c1:cc1+c1-1,cc2-c2:cc2+c2-1)=Cgoal2;
else %dimension of Cgoal2 is odd
    Cimg(cc1-c1:cc1+c1,cc2-c2:cc2+c2)=Cgoal2;
end
