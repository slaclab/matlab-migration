function [left,right,top,bottom,img]=spatMod_beamEdge(img,threshold)
%This function returns the four edge points of any beam profile. It
%utilizes matlab's image processing toolbox's median filter and edge finder
%functions.
%the threshold determines the edges. the bw image is only 0,1, so the
%threshold should be on the order of 1~10. For L shape, we use 1.5, for
%beam profile, we use 3.
%it also outputs the median filtered image.

img=medfilt2(img);
%bw=edge(img);
bw=edge(img,'Canny',0.5);
projx=sum(bw,1);
left=find(projx>threshold,1,'first');
right=find(projx>threshold,1,'last');
projy=sum(bw,2);
top=find(projy>threshold,1,'first');
bottom=find(projy>threshold,1,'last');

end