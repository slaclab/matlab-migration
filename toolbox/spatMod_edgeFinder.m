function [Z_measN, vars, Z_meas] = spatMod_edgeFinder(DMDimg)

%the first block finds accurate edges when there are no random pixels 
%around the beam. But it takes longer. About 15seconds for 1 iteration.
% OUTPUTS: 
% Z_measN - Normalized
% Z_meas - Raw image
% Vars



% projx=sum(DMDimg,1);
% [x01,x02]=spatMod_edgeDetect1d(projx);
% projy=sum(DMDimg,2)';
% [y01,y02]=spatMod_edgeDetect1d(projy);
[x01,x02,y01,y02,~]=spatMod_beamEdge(DMDimg,3);
Center1=round((y01+y02)/2);
Center2=round((x01+x02)/2);
%x01=410;x02=540;y01=162;y02=285;

%this block finds approximate edges but may not be accurate. It's faster
%than the previous method.

%then find the edges of the beam on DMD
% px=sum(DMDimg,1);
% py=sum(DMDimg,2)';
% usex=find(px > max(px)/4);
% parx=polyfit(usex,px(usex),2);
% Center2=round(-parx(2)/2/parx(1));%beam center on DMD
% x01=round((-parx(2)+sqrt(parx(2)^2-4*parx(1)*parx(3)))/(2*parx(1)));%find left edge
% x02=round((-parx(2)-sqrt(parx(2)^2-4*parx(1)*parx(3)))/(2*parx(1)));%find right edge
% usey=find(py > max(py)/3);
% pary=polyfit(usey,py(usey),2);
% Center1=round(-pary(2)/2/pary(1));%beam center on DMD
% 
% y01=round((-pary(2)+sqrt(pary(2)^2-4*pary(1)*pary(3)))/(2*pary(1)));%find top edge
% y02=round((-pary(2)-sqrt(pary(2)^2-4*pary(1)*pary(3)))/(2*pary(1)));%find right edge

%get a cut, squared and normalized input DMD image
N=round(max(x02-x01,y02-y01)/2);%find approximate radius

offsetHoriz=Center1-N;
offsetVert = Center2 -N;

if offsetHoriz < 0 || offsetVert < 0
    offset=abs(min([offsetHoriz offsetVert]))+1;
    N=N-offset;
end

x=-N:1:N; y=-N:1:N;
[X,Y]=meshgrid(x,y);
Z_meas=DMDimg(max(Center1-N,1):min(Center1+N,size(DMDimg,1)),max(Center2-N,1):min(Center2+N,size(DMDimg,2)));
%Z_measure should have dimension (2N+1)x(2N+1). The lines below fix that,
%incase mapping sends the beam off the range.
if size(Z_meas,1)<length(y)
    Z_meas=cat(1,Z_meas,zeros(length(y)-size(Z_meas,1),size(Z_meas,2)));
elseif size(Z_meas,1)>length(y)
    Z_meas=Z_meas(1:length,:);
end
if size(Z_meas,2)<length(x)
    Z_meas=cat(2,Z_meas,zeros(size(Z_meas,1),length(x)-size(Z_meas,2)));
elseif size(Z_meas,2)>length(x)
    Z_meas=Z_meas(:,1:length(x));
end
Z_measN = Z_meas/Z_meas(x==0,y==0); %normalized

%second set of parameters includes: beam center on DMD, beam edges on DMD,
%dimension of the cut normalized image.
vars=[Center1,Center2,x01,x02,y01,y02,N];