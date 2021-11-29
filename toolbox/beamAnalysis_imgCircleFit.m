function [c_norm, imgC, imgZ, resp] = beamAnalysis_imgCircleFit(img, nCoeff, ph)

if nargin < 3, ph=0;end
if nargin < 2, nCoeff=45;end

img=sqrt(double(img));
b=max(img(:))/4;
im2=min(img,b);
px=sum(im2,1);
py=sum(im2,2)';

usex=find(px > max(px)/3);
par=polyfit(usex,px(usex).^2,2);
x0=-par(2)/par(1)/2;
dx=sqrt((par(2)/par(1))^2-4*par(3)/par(1));

usey=find(py > max(py)/3);
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

ch1=[usex < 0 usey < 0];
ch2=[maxx > sx maxy > sy];
check=sum(ch1(:))+sum(ch2(:));

if check > 0
    c_norm=zeros(1,nCoeff);
    imgC=zeros(size(img));
    imgZ=zeros(size(img));
    resp=zeros(1,4);

else
%     disp('---')
%     size(img)
%     size(usex)
%     size(usey)
%     disp('---')
    imgC=double(img(usey,usex));
    [coeff,imgZ]=zernikeImg(imgC,nCoeff,ph);

    %-----------
    c_norm=coeff./coeff(1);

    angl_mode0_coeffs=c_norm([5 13 25 41]);
    c_norm2=c_norm;
    c_norm2([1 5 13 25 41])=0;
    av_nFRS=sum(abs(angl_mode0_coeffs));
    nFRS=sum(angl_mode0_coeffs.^2); %power in non-flat radial symmetric modes
    av_nRS=sum(abs(c_norm2));
    nRS=sum(c_norm2.^2);
    resp=[ nFRS nRS av_nFRS av_nRS];
    %----------

end


function [x0, dx] = fitParab(p)

use=find(p > max(p)/3);
par=polyfit(use,p(use).^2,2);
x0=-par(2)/par(1)/2;
dx=sqrt((par(2)/par(1))^2-4*par(3)/par(1));


function [c, imgc, z] = zernikeImg(img, nCoeff, ph)

j=1:nCoeff;
nList=ceil(-.5+sqrt(2*j+1/4)-1);
mList=(j-1)*2-nList.*(nList+2);

z=zeros([size(img) nCoeff]);
imgc=zeros(size(img));
for k=j
    z(:,:,k)=zernike2D(nList(k),mList(k),size(img,1));
end
c=img(:)'*reshape(z,[],nCoeff)*(2/size(img,1))^2;
if ph, c=zernikeRot(c,ph);end
imgc(:)=reshape(z,[],nCoeff)*c';


function [z, r, th] = zernike2D(n, m, num)

x0=linspace(-1+1/num,1-1/num,num);
[x,y]=meshgrid(x0,x0);
[th,r]=cart2pol(x,y);

[p,l]=zernike(n,m,r);
z=sqrt((2*n+2)/pi/(1+(m == 0)))*l.*(cos(m*th)*(m >= 0)+sin(m*th)*(m < 0)).*(r < 1); % Should be sin(-m*th), but leave for old data's sake


function co = zernikeRot(c, ph)

nCoeff=numel(c);
j=1:nCoeff;
nList=ceil(-.5+sqrt(2*j+1/4)-1);
mList=(j-1)*2-nList.*(nList+2);

co=c;

k=0;
for n=0:max(nList)
    for m=-n:2:n
        k=k+1;
        if m > -1, continue, end
        co([k k-m])=[cosd(m*ph) sind(abs(m)*ph);-sind(abs(m*ph)) cosd(m*ph)]*co([k k-m])';
    end
end
