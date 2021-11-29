function [croppedImage] = util_circleFinder(image)
L=colfilt(image,[10 10], 'sliding', @mean);
[LL,~]=bwlabel(L, 8);
props = regionprops(LL, 'all');

len=length(props);

area=zeros(len,1);
for i=1:len
    area(i)=props(i).Area;
end
[area, index]=max(area);

xCenter = round(props(index).Centroid(1));
yCenter = round(props(index).Centroid(2));
[sx,sy] = size(props(index).Image);
range=[xCenter-sx/2, xCenter+sx/2, yCenter-sy/2, yCenter+sy/2]; 
range=round(range);
data.xMin = range(1);
data.xMax = range(2);
data.yMin = range(3);
data.yMax = range(4);

croppedImage = image(data.yMin:data.yMax, data.xMin:data.xMax);