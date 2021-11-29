function [cameraL,outputs]=spatMod_fitLshape1(handles, parameters)
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
% frac1=DMD vertical dimension/length of shorter line in L (suggested value:
% 8);
% frac2=DMD horizontal dimension/length of longer line in L (suggested

%file needs to be edited to take VCC images...

cameraL=handles.data.img;
cameraL=cameraL(:,:,1);

frac1=parameters(1);
frac2=parameters(2); 
dmd1=parameters(3);
dmd2=parameters(4); 

%-------------------------------------------------------------------------------------
%get the 4 points on the edges
% filt = spatMod_medianfilt(cameraL);
% bw = spatMod_edgeDetect(filt);
% bw = spatMod_medianfilt(bw);
% columnMax = max(bw, [], 1);
% rowMax = max(bw, [], 2);
% left = find(columnMax~=0, 1, 'first');
% col=bw(:,left);
% p(1,:)=[round(mean(find(col==max(col)))),left];
% right = find(columnMax~=0, 1, 'last');
% col=bw(:,right);
% p(2,:)=[round(mean(find(col==max(col)))),right];
% top = find(rowMax~=0, 1, 'first');
% row=bw(top,:);
% p(3,:)=[top,round(mean(find(row==max(row))))];
% bottom = find(rowMax~=0, 1, 'last');
% row=bw(bottom,:);
% p(4,:)=[bottom,round(mean(find(row==max(row))))];

%[left,right,top,bottom]=spatMod_edgeDetectL(cameraL);
[left,right,top,bottom,~]=spatMod_beamEdge(cameraL,1.5);
cameraL=medfilt2(cameraL);
col=cameraL(:,left);
if length(find(col==max(col)))>2
    p(1,:)=[round(mean(find(col==max(col),2,'first'))),left];
else
    p(1,:)=[round(mean(find(col==max(col)))),left];
end
col=cameraL(:,right);
if length(find(col==max(col)))>2
    p(2,:)=[round(mean(find(col==max(col),2,'first'))),right];
else
    p(2,:)=[round(mean(find(col==max(col)))),right];
end
row=cameraL(top,:); if max(row(:))==0; row=cameraL(top+1,:);end
if length(find(row==max(row)))>2
    p(3,:)=[top,round(mean(find(row==max(row),2,'first')))];
else
    p(3,:)=[top,round(mean(find(row==max(row))))];
end

row=cameraL(bottom,:); if max(row(:))==0; row=cameraL(bottom-1,:);end
if length(find(row==max(row)))>2
    p(4,:)=[bottom,round(mean(find(row==max(row),2,'first')))];
else
    p(4,:)=[bottom,round(mean(find(row==max(row))))];
end
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

%-------------------------------------------------------------------------------------
%determine the ratio
long=sqrt((s2_h-scom_h)^2+(s2_v-scom_v)^2);
short=sqrt((s1_h-scom_h)^2+(s1_v-scom_v)^2);
ratio1=short/(dmd1/frac1);
ratio2=long/(dmd2/frac2);
%-------------------------------------------------------------------------------------
%determine handedness
%handedness=1 means a normal L, handedness=0 means a flipped L
if scom_v<s2_v
    if s1_h<scom_h
        handedness=1;
    else
        handedness=0;
    end
elseif scom_v>s2_v
    if s1_h>scom_h
        handedness=1;
    else
        handedness=0;
    end
end
%-------------------------------------------------------------------------------------
%determine rotational degree
%if the handedness is flipped, first flip the image then find the angle
%handedness=0;%REMOVE!!!
if handedness==0
    cameraL=spatMod_flipLeftRight(cameraL);
    s1_h=size(cameraL,2)-s1_h+1;
    s2_h=size(cameraL,2)-s2_h+1;
    scom_h=size(cameraL,2)-scom_h+1;
    left=size(cameraL,2)-left+1;
    right=size(cameraL,2)-right+1;
    out_img=cameraL;
end
%fit the lines to get the angle
%the shorter line
%line1=[];
% for i=min(s1_h,scom_h):max(s1_h,scom_h)
%     for j=min(s1_v,scom_v):max(s1_v,scom_v)
%         if bw(j,i)==1
%             line1=[line1; [i j]];
%         end
%     end
% end
% seg=cameraL(min(s1_v,scom_v):max(s1_v,scom_v),min(s1_h,scom_h):max(s1_h,scom_h));
% ind=find(seg>max(seg(:))/2);
% [y,x]=ind2sub(size(seg),ind);
% line1=[x,y];
% pfit1=polyfit(line1(:,1),line1(:,2),1);
% ang1=-atand(pfit1(1));%the minus sign takes care of the fact that the vertical axis points downward


ang1=-atand((s1_v-scom_v)/(s1_h-scom_h));%the minus sign takes care of the fact that the vertical axis points downward
%the longer line
line2=[];
% for i=min(s2_h,scom_h):max(s2_h,scom_h)
%     for j=min(s2_v,scom_v):max(s2_v,scom_v)
%         if bw(j,i)==1
%             line2=[line2; [i,j]];
%         end
%     end
% end
seg=cameraL(min(s2_v,scom_v):max(s2_v,scom_v),min(s2_h,scom_h):max(s2_h,scom_h));
ind=find(seg>max(seg(:))/2);
[y,x]=ind2sub(size(seg),ind);
line2=[x,y];
pfit2=polyfit(line2(:,1),line2(:,2),1);
ang2=-atand(pfit2(1));%the minus sign takes care of the fact that the vertical axis points downward
if scom_v<s2_v
    if ang2<0 && ang1>0
        deg=(abs(ang1)+90-abs(ang2))/2+90;
    elseif ang2>0 && ang1<0
        deg=(abs(ang2)+90-abs(ang1))/2;
    else
        return
    end
elseif scom_v>s2_v
    if ang2>0 && ang1<0
        deg=-((abs(ang1)+90-abs(ang2))/2+90);
    elseif ang2<0 && ang1>0
        deg=-(abs(ang2)+90-abs(ang1))/2;
    else
        return
    end
end
%if deg is negative, it means camera -> image needs (first flip or not
%depends on handedness) rotation ccw by abs(deg) angle.

%---------------------------------------------------------------------------------
%determine the DMD center on camera image
% mid1_h=(s1_h+scom_h)/2;mid2_h=(s2_h+scom_h)/2;
% mid1_v=(s1_v+scom_v)/2;mid2_v=(s2_v+scom_v)/2;
% rCenter2=round((mid1_v-pfit2(1)*mid1_h-mid2_v+pfit1(1)*mid2_h)/(pfit1(1)-pfit2(1)));
% rCenter1=round(pfit1(1)*rCenter2+mid2_v-pfit1(1)*mid2_h);
rCenter1=round((s1_v+s2_v)/2);
rCenter2=round((s1_h+s2_h)/2);

fileID=fopen('par1.txt','a');
%ciris:
%deg=-136;ratio1=0.21;ratio2=0.21;handedness=0;rCenter1=218;rCenter2=198; %REMOVE!!!!!
%vcc:
%deg=22.7;ratio1=0.25;ratio2=0.3;handedness=0;rCenter1=138;rCenter2=300; %REMOVE!!!!!
%deg=-136.8;ratio1=0.20;ratio2=0.21;handedness=0;rCenter1=336;rCenter2=322; %REMOVE!!!!!
out_img = cameraL; %REMOVE!!!!
par1=[deg,ratio1,ratio2,rCenter1,rCenter2,dmd1,dmd2,handedness];
time=clock;
fprintf(fileID,'\n%g %g %g %g %g',time(1:5));
fprintf(fileID,'\n%g %g %g %g %g %g %g %g',par1);
fclose(fileID);

outputs=[handedness,deg,rCenter1,rCenter2,ratio1,ratio2];
end




