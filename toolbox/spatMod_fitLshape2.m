function [cameraL,outputs]=spatMod_fitLshape2(handles, parameters)
%This function uses the L image taken by the camera to extract mapping
%parameters.
% OUTPUTS:
% handedness: if handedness=1, it means handedness has not flipped; if
% handedness =0, it menas handedness has been flipped;
% deg: rotational angle. If deg is negative, it means the camera image
% neeeds to be rotated ccw by abs(deg) to get back to the DMD plane;
% rCenter1: DMD center on camera image in vertical dimension, in camera
% pixels;
% rCenter2: DMD center on camera image in horizontal dimension, in camera
% pixels;
% ratio1: after rotation, ratio1=length of shorter line of L in camera
% pixels/that in DMD pixels;
% ratio2: after rotation, ratio1=length of longer line of L in camera
% pixels/that in DMD pixels;
% INPUTS:
% cameraL: camera image of the L mask. Currently it's provided by a
% simulated camera image "cameraL.bmp". Type the following for now:
% cameraL=imread('/usr/local/lcls/tools/matlab/toolbox/images/cameraL','bmp');
% cameraL=double(cameraL(:,:,1));
% dmd1: DMD dimension in vertical direction;
% dmd2: DMD dimension in horizontal direction;
% frac1=DMD vertical dimension/length of longer line in L (suggested value:
% 8);
% frac2=DMD horizontal dimension/length of shorter line in L (suggested

%file needs to be edited to take VCC images...

cameraL=handles.data.map;
%cameraL=cameraL(:,:,1);
cameraL=double(cameraL);


frac1=parameters(1);
frac2=parameters(2); 
dmd1=parameters(3);
dmd2=parameters(4); 

[left,right,top,bottom]=spatMod_edgeDetectL(cameraL);
%left=831;right=1163;top=359;bottom=603;
col=cameraL(:,left);
p(1,:)=[round(mean(find(col==max(col)))),left];
col=cameraL(:,right);
p(2,:)=[round(mean(find(col==max(col)))),right];
row=cameraL(top,:);
p(3,:)=[top,round(mean(find(row==max(row))))];
row=cameraL(bottom,:);
p(4,:)=[bottom,round(mean(find(row==max(row))))];

%-------------------------------------------------------------------------------------
%find out the two points that overlap and eliminate one of them
d(1,:)=[1,2,p(1,1)-p(2,1)];
d(2,:)=[1,3,p(1,1)-p(3,1)];
d(3,:)=[1,4,p(1,1)-p(4,1)];
d(4,:)=[2,3,p(2,1)-p(3,1)];
d(5,:)=[2,4,p(2,1)-p(4,1)];
d(6,:)=[3,4,p(3,1)-p(4,1)];

rowmin=find(abs(d(:,3))==min(abs(d(:,3))));
x=round((p(d(rowmin,1),1)+p(d(rowmin,2),1))/2);
y=round((p(d(rowmin,1),2)+p(d(rowmin,2),2))/2);
p(min(d(rowmin,1),d(rowmin,2)),:)=[x,y];
pp=p([1:max(d(rowmin,1),d(rowmin,2))-1,max(d(rowmin,1),d(rowmin,2))+1:end],:);

%-------------------------------------------------------------------------------------
%find out the longer line and the shorter line
dd(1,:)=[1,2,sqrt((pp(1,1)-pp(2,1))^2+(pp(1,2)-pp(2,2))^2)];
dd(2,:)=[1,3,sqrt((pp(1,1)-pp(3,1))^2+(pp(1,2)-pp(3,2))^2)];
dd(3,:)=[2,3,sqrt((pp(2,1)-pp(3,1))^2+(pp(2,2)-pp(3,2))^2)];

rowmax=find(dd(:,3)==max(dd(:,3)));
dd=dd([1:rowmax-1,rowmax+1:end],:);
dd=sortrows(dd,3);
index=[dd(1,1) dd(1,2) dd(2,1) dd(2,2)];
com=mode(index);
%the common point
scom_h=pp(com,2);
scom_v=pp(com,1);
%the point on the shorter line
s1_h=pp(dd(1,find(dd(1,1:2)~=com)),2);
s1_v=pp(dd(1,find(dd(1,1:2)~=com)),1);
%the point on the longer line
s2_h=pp(dd(2,find(dd(2,1:2)~=com)),2);
s2_v=pp(dd(2,find(dd(2,1:2)~=com)),1);

%---------------------------------------------------------------------------------
%determine the DMD center on camera image

rCenter2=round((s1_h+s2_h)/2);
rCenter1=round((s1_v+s2_v)/2);
%-------------------------------------------------------------------------------------
%determine the ratio
long=sqrt((s2_h-scom_h)^2+(s2_v-scom_v)^2);
short=sqrt((s1_h-scom_h)^2+(s1_v-scom_v)^2);
ratio1=short/(dmd1/frac1);
ratio2=long/(dmd2/frac2);
%-------------------------------------------------------------------------------------
%determine handedness
%handedness=1 means it doens't have to flip to get back to the DMD mask.
%handedness=0 measn it has to flip to get back to the DMD mask.
%find handedness by taking the cross product of the long vector with the
%short vector
longv=[s2_h-scom_h s2_v-scom_v];
shortv=[s1_h-scom_h s1_v-scom_v];
cross=longv(1)*shortv(2)-longv(2)*shortv(1);
if cross>0
    handedness=1;
elseif cross<0
    handedness=0;
end
%-------------------------------------------------------------------------------------
%determine rotational degree
%if the handedness is flipped, first flip the image then find the angle
if handedness==0
    cameraL=spatMod_flipLeftRight(cameraL);
    s1_h=size(cameraL,2)-s1_h+1;
    s2_h=size(cameraL,2)-s2_h+1;
    scom_h=size(cameraL,2)-scom_h+1;
    %figure(3);imagesc(cameraL);
end
%fit the lines to get the angle
%the shorter line
line1=[];
seg=cameraL(min(s1_v,scom_v):max(s1_v,scom_v),min(s1_h,scom_h):max(s1_h,scom_h));
ind=find(seg>max(cameraL(:))/10);
[y,x]=ind2sub(size(seg),ind);
line1=[x,y];

pfit1=polyfit(line1(:,1),line1(:,2),1);
ang1=atand(pfit1(1));
%the longer line
line2=[];
seg=cameraL(min(s2_v,scom_v):max(s2_v,scom_v),min(s2_h,scom_h):max(s2_h,scom_h));
ind=find(seg>max(cameraL(:))/3);
[y,x]=ind2sub(size(seg),ind);
line2=[x,y];
pfit2=polyfit(line2(:,1),line2(:,2),1);
ang2=atand(pfit2(1));

if scom_v<s2_v
    if ang2<0 && ang1>0
        deg=180+(abs(ang1)+abs(ang2))/2;
    elseif ang2>0 && ang1<0
        deg=-(abs(ang1)+abs(ang2))/2;
    end
elseif scom_v>s2_v
    if ang2<0 && ang1>0
        deg=(abs(ang1)+abs(ang2))/2;
    elseif ang2>0 && ang1<0
        deg=90+(abs(ang1)+abs(ang2))/2;
    end
end


fileID=fopen('par1.txt','a');
par1=[deg,ratio1,ratio2,rCenter1,rCenter2,dmd1,dmd2,handedness];
time=clock;
fprintf(fileID,'\n%g %g %g %g %g',time(1:5));
fprintf(fileID,'\n%g %g %g %g %g %g %g %g',par1);
fclose(fileID);

outputs=[handedness,deg,rCenter1,rCenter2,ratio1,ratio2];
end


