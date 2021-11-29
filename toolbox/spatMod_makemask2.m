function [mask]=spatMod_makemask2(DMDimg_norm,DMDgoal,par2,secLength)
%on the dmd image DMDimg, split pixels into macropixel sections. Find 
%the mask for each section, then combine to get the mask that can be loaded
%on to the DMD.

x01=par2(3);x02=par2(4);y01=par2(5);y02=par2(6);

skirt=4;% the extra skirt is to make sure the mask covers the whole beam
mask=ones(size(DMDimg_norm,1),size(DMDimg_norm,2));
for i=-skirt:1:(ceil((x02-x01)/secLength)+skirt)
    rightInd=x02-(i-1)*secLength;%as i increases, we move from right to left
    leftInd=rightInd-secLength+1;
    if rightInd > size(DMDimg_norm,2), rightInd = size(DMDimg_norm,2); end
    if leftInd<1,leftInd=1;end
    for j=-skirt:1:(ceil((y02-y01)/secLength)+skirt)
        bottomInd=y02-(j-1)*secLength;%as j increases, move from bottom to top
        topInd=bottomInd-secLength+1;
        if bottomInd > size(DMDimg_norm,1), bottomInd = size(DMDimg_norm,1); end
        if topInd<1,topInd=1;end
        section = DMDimg_norm(topInd:bottomInd, leftInd:rightInd);
        capValue=mean(mean(DMDgoal(topInd:bottomInd,leftInd:rightInd)));
        %maskSec = getMask(section, capValue);
        maskSec = getMask_smooth(section,capValue);
        mask(topInd:bottomInd, leftInd:rightInd) = maskSec(1:(bottomInd-topInd+1),1:(rightInd-leftInd+1));
    end
end

%blackout region outside beam
c1=y01+round((y02-y01)/2);
c2=x01+round((x02-x01)/2);
x=-c2:size(mask,2)-c2-1;
y=-c1:size(mask,1)-c1-1;
[X,Y]=meshgrid(x,y);
[~,rho]=cart2pol(X,Y);
radius=round((x02-x01)/2);
mask(rho>(radius+3))=0;
end



function mask = getMask_smooth(section, capValue)
%This is a back up function for getMask in case getMask produces a mask
%that is noisy. getMask_smooth basically goes through all possible cases to
%produce a smoothly distributed mask for each case. *It only applies to the
%case when secLength=5.
mask=ones(5,5);
value = mean(mean(section));
if value~=0
    maskFrac=capValue/value;
    pixelsOff=ceil(25 * (1 - maskFrac));
    if pixelsOff==1;
        mask(randperm(25,1))=0;
    elseif pixelsOff==2;
        mask(randperm(10,1))=0;
        mask(16+randperm(9,1))=0;
    elseif pixelsOff==3;
        mask(13)=0;
        mask(randperm(5,1))=0;
        mask(20+randperm(5,1))=0;
    elseif pixelsOff==4;
        mask(round(rand(1,1)+1),round(rand(1,1)+1))=0;
        mask(round(rand(1,1)+1),round(rand(1,1)+4))=0;
        mask(round(rand(1,1)+4),round(rand(1,1)+1))=0;
        mask(round(rand(1,1)+4),round(rand(1,1)+4))=0;
    elseif pixelsOff==5;
        mask(13)=0;
        mask(round(rand(1,1)+1),round(rand(1,1)+1))=0;
        mask(round(rand(1,1)+1),round(rand(1,1)+4))=0;
        mask(round(rand(1,1)+4),round(rand(1,1)+1))=0;
        mask(round(rand(1,1)+4),round(rand(1,1)+4))=0;
    elseif pixelsOff==6;
        mask(round(rand(1,1)+4),1)=0;
        mask(round(rand(1,1)+1),2)=0;
        mask(round(rand(1,1)+3),3)=0;
        mask(round(rand(1,1)+2),4)=0;
        mask(round(rand(1,1)+1),5)=0;
        mask(5,round(rand(1,1)+4))=0;
    elseif pixelsOff==7;
        mask(2,round(rand(1,1)+1))=0;
        mask(round(rand(1,1)+4),1)=0;
        mask(5,round(rand(1,1)+2))=0;
        mask(round(rand(1,1)+1),3)=0;
        mask(3,round(rand(1,1)+3))=0;
        mask(round(rand(1,1)+1),5)=0;
        mask(round(rand(1,1)+4),5)=0;
    elseif pixelsOff==8;
        mask(1,round(rand(1,1)+1))=0;
        mask(1,round(rand(1,1)+4))=0;
        mask(2,round(rand(1,1)+3))=0;
        mask(3,round(rand(1,1)+2))=0;
        mask(3,round(rand(1,1)+4))=0;
        mask(4,round(rand(1,1)+1))=0;
        mask(round(rand(1,1)+4),3)=0;
        mask(round(rand(1,1)+4),5)=0;
    elseif pixelsOff==9;
        mask(1,round(rand(1,1)+3))=0;
        mask(2,round(rand(1,1)+3))=0;
        mask(5,round(rand(1,1)+1))=0;
        mask(5,round(rand(1,1)+3))=0;
        mask(round(rand(1,1)+1),2)=0;
        mask(round(rand(1,1)+1),5)=0;
        mask(round(rand(1,1)+3),1)=0;
        mask(round(rand(1,1)+3),3)=0;
        mask(round(rand(1,1)+3),5)=0;
    elseif pixelsOff==10;
        mask(1,round(rand(1,1)+1))=0;
        mask(1,round(rand(1,1)+4))=0;
        mask(2,round(rand(1,1)+3))=0;
        mask(3,round(rand(1,1)+2))=0;
        mask(4,round(rand(1,1)+4))=0;
        mask(5,round(rand(1,1)+1))=0;
        mask(5,round(rand(1,1)+4))=0;
        mask(round(rand(1,1)+3),1)=0;
        mask(round(rand(1,1)+4),3)=0;
        mask(round(rand(1,1)+2),5)=0;
    elseif pixelsOff==11;
        mask(1,round(rand(1,1)+2))=0;
        mask(2,round(rand(1,1)+2))=0;
        mask(3,round(rand(1,1)+3))=0;
        mask(round(rand(1,1)+2),1)=0;
        mask(round(rand(1,1)+4),1)=0;
        mask(round(rand(1,1)+3),2)=0;
        mask(round(rand(1,1)+4),3)=0;
        mask(round(rand(1,1)+1),4)=0;
        mask(round(rand(1,1)+4),4)=0;
        mask(round(rand(1,1)+2),5)=0;
        mask(round(rand(1,1)+4),5)=0;
     elseif pixelsOff==12;
        mask(1,round(rand(1,1)+3))=0;
        mask(2,round(rand(1,1)+2))=0;
        mask(2,round(rand(1,1)+4))=0;
        mask(3,round(rand(1,1)+1))=0;
        mask(4,round(rand(1,1)+2))=0;
        mask(5,round(rand(1,1)+2))=0;
        mask(5,round(rand(1,1)+4))=0;
        mask(round(rand(1,1)+1),1)=0;
        mask(round(rand(1,1)+4),1)=0;
        mask(round(rand(1,1)+3),4)=0;
        mask(round(rand(1,1)+1),5)=0;
        mask(round(rand(1,1)+3),5)=0;
    elseif pixelsOff==13;
        mask=zeros(5,5);
        mask(1,round(rand(1,1)+3))=1;
        mask(2,round(rand(1,1)+2))=1;
        mask(2,round(rand(1,1)+4))=1;
        mask(3,round(rand(1,1)+1))=1;
        mask(4,round(rand(1,1)+2))=1;
        mask(5,round(rand(1,1)+2))=1;
        mask(5,round(rand(1,1)+4))=1;
        mask(round(rand(1,1)+1),1)=1;
        mask(round(rand(1,1)+4),1)=1;
        mask(round(rand(1,1)+3),4)=1;
        mask(round(rand(1,1)+1),5)=1;
        mask(round(rand(1,1)+3),5)=1;
    elseif pixelsOff==14;
        mask=zeros(5,5);
        mask(1,round(rand(1,1)+2))=1;
        mask(2,round(rand(1,1)+2))=1;
        mask(3,round(rand(1,1)+3))=1;
        mask(round(rand(1,1)+2),1)=1;
        mask(round(rand(1,1)+4),1)=1;
        mask(round(rand(1,1)+3),2)=1;
        mask(round(rand(1,1)+4),3)=1;
        mask(round(rand(1,1)+1),4)=1;
        mask(round(rand(1,1)+4),4)=1;
        mask(round(rand(1,1)+2),5)=1;
        mask(round(rand(1,1)+4),5)=1;
    elseif pixelsOff==15;
        mask=zeros(5,5);
        mask(1,round(rand(1,1)+1))=1;
        mask(1,round(rand(1,1)+4))=1;
        mask(2,round(rand(1,1)+3))=1;
        mask(3,round(rand(1,1)+2))=1;
        mask(4,round(rand(1,1)+4))=1;
        mask(5,round(rand(1,1)+1))=1;
        mask(5,round(rand(1,1)+4))=1;
        mask(round(rand(1,1)+3),1)=1;
        mask(round(rand(1,1)+4),3)=1;
        mask(round(rand(1,1)+2),5)=1;
    elseif pixelsOff==16;
        mask=zeros(5,5);
        mask(1,round(rand(1,1)+3))=1;
        mask(2,round(rand(1,1)+3))=1;
        mask(5,round(rand(1,1)+1))=1;
        mask(5,round(rand(1,1)+3))=1;
        mask(round(rand(1,1)+1),2)=1;
        mask(round(rand(1,1)+1),5)=1;
        mask(round(rand(1,1)+3),1)=1;
        mask(round(rand(1,1)+3),3)=1;
        mask(round(rand(1,1)+3),5)=1;
    elseif pixelsOff==17;
        mask=zeros(5,5);
        mask(1,round(rand(1,1)+1))=1;
        mask(1,round(rand(1,1)+4))=1;
        mask(2,round(rand(1,1)+3))=1;
        mask(3,round(rand(1,1)+2))=1;
        mask(3,round(rand(1,1)+4))=1;
        mask(4,round(rand(1,1)+1))=1;
        mask(round(rand(1,1)+4),3)=1;
        mask(round(rand(1,1)+4),5)=1;
    elseif pixelsOff==18;
        mask=zeros(5,5);
        mask(2,round(rand(1,1)+1))=1;
        mask(round(rand(1,1)+4),1)=1;
        mask(5,round(rand(1,1)+2))=1;
        mask(round(rand(1,1)+1),3)=1;
        mask(3,round(rand(1,1)+3))=1;
        mask(round(rand(1,1)+1),5)=1;
        mask(round(rand(1,1)+4),5)=1;
    elseif pixelsOff==19;
        mask=zeros(5,5);
        mask(round(rand(1,1)+4),1)=1;
        mask(round(rand(1,1)+1),2)=1;
        mask(round(rand(1,1)+3),3)=1;
        mask(round(rand(1,1)+2),4)=1;
        mask(round(rand(1,1)+1),5)=1;
        mask(5,round(rand(1,1)+4))=1;
    elseif pixelsOff==20;
        mask=zeros(5,5);
        mask(13)=1;
        mask(round(rand(1,1)+1),round(rand(1,1)+1))=1;
        mask(round(rand(1,1)+1),round(rand(1,1)+4))=1;
        mask(round(rand(1,1)+4),round(rand(1,1)+1))=1;
        mask(round(rand(1,1)+4),round(rand(1,1)+4))=1;
    elseif pixelsOff==21;
        mask=zeros(5,5);
        mask(round(rand(1,1)+1),round(rand(1,1)+1))=1;
        mask(round(rand(1,1)+1),round(rand(1,1)+4))=1;
        mask(round(rand(1,1)+4),round(rand(1,1)+1))=1;
        mask(round(rand(1,1)+4),round(rand(1,1)+4))=1;
    elseif pixelsOff==22;
        mask=zeros(5,5);
        mask(13)=1;
        mask(randperm(5,1))=1;
        mask(20+randperm(5,1))=1;
    elseif pixelsOff==23;
        mask=zeros(5,5);
        mask(randperm(10,1))=1;
        mask(16+randperm(9,1))=1;
    elseif pixelsOff==24;
        mask=zeros(5,5);
        mask(randperm(25,1))=1;
    elseif pixelsOff==25;
        mask=zeros(5,5);
    end
end
end


function mask = getMask(section, capValue)

% GETMASK    Creates a mask of ones and zeroes for an image section.

%

%   Reduces the average value across the section to below the capValue by

%   turning off specific pixels to a value of 0. Returns a mask that is all

%   ones except for zeroes where the pixels have been turned off.

% on the DMD, 1 is for on, 0 is for off. In matlab 1 is white, 0 is black.

[i, j] = size(section);

mask = ones(i, j);

value = mean(mean(section));

%value=min(section(:));

% if value==0

%     mask=ones(i,j);

%     %mask=zeros(i,j);

% end

if value~=0
    
    maskFrac=capValue/value;
    
    % if maskFrac>0 && maskFrac<1
    
    if maskFrac>0 && maskFrac<1
        
        pixels = i * j;
        
        pixelsOff = ceil(pixels * (1 - maskFrac));
        
        %         if pixelsOff>pixels
        
        %             pixelsOff=pixels;
        
        %         end
        
        %         dim_num = 1; step = 0; seed = 1; leap = 1; base = 5;
        
        %         ham_rand = i_to_hammersley_sequence(dim_num, pixelsOff, step, seed, leap, base);
        
        %         r = round(pixels.*(ham_rand));
        
        %r = randi(pixels, 1, pixelsOff); %returns a 1xpixelsOff random numbers between 1 and pixels
        
        r=randperm(pixels,pixelsOff);
        
        for k = 1:size(r, 2)
            
            ind = r(k);
            
            mask(ind) = 0;
            
        end
        
    elseif maskFrac==0
        
        mask=zeros(i,j);
        
    end
    
end



end