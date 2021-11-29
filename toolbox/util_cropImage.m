function [imgC] = util_cropImage(img)
%function crops the image
img=double(img);

b=max(img(:))/4;
im2=min(img,b);
px=sum(im2,1);   
py=sum(im2,2)';

c=max(px)/3;
usex=find(px > max(px)/3);
zx=length(usex);
par=polyfit(usex,px(usex).^2,2);
x0=-par(2)/par(1)/2;
dx=sqrt((par(2)/par(1))^2-4*par(3)/par(1));
usey=find(py > max(py)/3);
zy=length(usey);
par=polyfit(usey,py(usey).^2,2);
y0=-par(2)/par(1)/2;
dy=sqrt((par(2)/par(1))^2-4*par(3)/par(1));
c=round([x0 y0]);
d=round(mean([dx dy]));
usex=round(x0+(-d/2:d/2));
usey=round(y0+(-d/2:d/2));

%perform checks
maxx=max(usex);
maxy=max(usey);
[sx,sy]=size(img);

ch1=zeros(2,length(usex));
ch1=[usex<0 usey<0];
ch2=[maxx>sx maxy>sy];
check=sum(ch1(:))+sum(ch2(:));


if check > 0
    try 
    c_norm=zeros(1,nCoeff);
    catch me
    end
    disp(me)
    imgC=zeros(size(img));
    
else

try 
imgC=double(img(usey,usex));
catch me
    disp(me)
    imgC=zeros(size(img));
end
end    