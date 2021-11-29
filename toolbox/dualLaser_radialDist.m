function [radial,gh,theta,balance]= dualLaser_radialDist(img,width ,isPlot)
%function computes the radial distribution of an image
%Input 
    % img - beam image e.g. 
        %load ProfMon-CAMR_IN20_186-2016-03-24-163227.mat
        %example radialDist =  beamAnalysis_radialDist(data.img)
    % isPlot - plots radial distribution w/ 

[img] = util_cropImage(img);

rr=length(img);


[x1,y] = meshgrid(linspace(-1,1,rr));
x1 = x1(:);
y = y(:);
[th,rh] = cart2pol(x1,y); 

range = 0:0.01:1.5;
[n, bin] = histc(rh,range);



s=zeros(1, length(n));

for i = 1:length(n)
   
    idx = find( bin == i);
    
    s(i) = mean(img(idx));
    
end
   
radial=s;

s(s == 0) = NaN;

realNums=~isnan(s);
firstRealNum=find(realNums,1,'first');
lastRealNum=find(realNums,1,'last');

% center_max = mean(s(firstRealNum:firstRealNum+width));
center_max = max(s(:));
edge_max = mean(s(lastRealNum-2*width:lastRealNum-width));
gh = (center_max - edge_max) / edge_max;

if isPlot
    figure;
    plot(range', s,'r')
    xlabel('mm')
    ylabel('Intensity Arb. Units')
    hold on
    plot(range', center_max) 
    plot(range', edge_max)
end



range_th=-pi:pi/50:pi;  
[n_th, bin_th] = histc(th,range_th);
s_th=zeros(1, length(n_th));

for i = 1:length(n_th)
    idx = find(bin_th == i);
    s_th(i) = mean(img(idx));
end

theta=s_th;
realNums_th=~isnan(s_th);
lastRealNum_th=find(realNums_th,1,'last');
firstRealNum_th=find(realNums_th,1,'first');
balance=mean(s_th(firstRealNum_th:lastRealNum_th));

if isPlot
    figure;
    plot(range_th', s_th,'r')
    title('Angular Sum 50 bins')
    xlabel('Radians')
    ylabel('Intensity Arb. Units')
    hold on
    plot(range_th', balance) 
end


