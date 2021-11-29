function [left,right,top,bottom]=spatMod_edgeDetectL(dat)

[m,n]=size(dat);

% subtract average background
projx = sum(dat,1);
projy = sum(dat,2);

% take medfilt of average
projx_m = medfilt_1D(projx,3);
projy_m = medfilt_1D(projy,3);

%figure(1);plot(projx);
%figure(2);plot(projx_m);
%figure(3);plot(projy);
%figure(4);plot(projy_m);

nthresh_x = 0.1*max(projx_m);
nthresh_y = 0.06*max(projy_m);

% edges are beginning and end of region above noise level
left=find(projx_m>nthresh_x,1,'first');
right=find(projx_m>nthresh_x,1,'last');
top=find(projy_m>nthresh_y,1,'first');
bottom=find(projy_m>nthresh_y,1,'last');

function ymed=medfilt_1D(y,N)

% note: might be faster to implement with conv() and a step function if
% conv() is optimized.

% make column vector
[n1,n2]=size(y);
if n2>n1
    y=y';
end

Y=zeros(length(y),2*N+1);
Y(:,1)=y;
for j=1:N
    Y(:,2*j)=circshift(y,[j 0]);
    Y(:,2*j+1)=circshift(y,[-j 0]);
end

ymed=median(Y,2);

if n2>n1
    ymed=ymed';
end


function smooth_dat=smooth(data,N)

% flip data if necessary
was_flipped=0;
if size(data,1) > size(data,2)
    data=data.';
    was_flipped=1;
end

tempdat=zeros(N,length(data));

if mod(N,2)==1
    mymin=-(N-1)/2; mymax=(N-1)/2;
else
    mymin=-N/2+1; mymax=N/2;
end
    
for j=mymin:mymax
    tempdat(j-mymin+1,:)=circshift(data,[0 j]);
end

smooth_dat=mean(tempdat,1);

% flip back if necessary;
if was_flipped
    smooth_dat=smooth_dat.';
end
